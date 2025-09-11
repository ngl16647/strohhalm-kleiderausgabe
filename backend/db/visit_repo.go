package db

import (
	"database/sql"
	"errors"
	"fmt"
	"time"
)

func VisitById(visitId int64) (Visit, error) {
	var visit Visit
	if err := DB.Get(&visit, `
		SELECT * FROM visits
		WHERE id = $1
	`, visitId); err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return visit, ErrNotFound
		}
		return visit, fmt.Errorf("get visit by id: %w", err)
	}
	return visit, nil
}

func AddVisit(customerId int64, visitDate *time.Time, notes string) (Visit, error) {
	var visitDateStr string
	if visitDate == nil {
		visitDateStr = time.Now().Format(DateFormat)
	} else {
		visitDateStr = visitDate.Format(DateFormat)
	}

	var newVisit Visit
	err := DB.Get(&newVisit, `
		INSERT INTO visits (customer_id, visit_date, notes)
		VALUES ($1, $2, $3)
		RETURNING *`,
		customerId, visitDateStr, notes,
	)
	if err != nil {
		return newVisit, fmt.Errorf("insert visit for customer %d: %w", customerId, err)
	}

	if err := SetCustomerLastVisit(customerId, newVisit); err != nil {
		return newVisit, fmt.Errorf("update last visit for customer %d: %w", customerId, err)
	}

	return newVisit, nil
}

func AllCustomerVisits() ([]CustomerVisit, error) {
	cvs := []CustomerVisit{}
	// LEFT JOIN to include visits with deleted customer
	// sqlite does not have RIGHT JOIN
	err := DB.Select(&cvs, `
		SELECT 
			v.id AS id,
			c.id AS customer_id,
			c.uuid AS customer_uuid,
			c.first_name AS first_name,
			c.last_name AS last_name,
			v.visit_date AS visit_date,
			v.notes AS notes
      	FROM visits v
        LEFT JOIN customers c ON c.id = v.customer_id
        ORDER BY v.visit_date DESC`)
	if err != nil {
		return nil, fmt.Errorf("get customer visits: %w", err)
	}
	return cvs, nil
}

func CustomerVisitsBetween(begin time.Time, end time.Time) ([]CustomerVisit, error) {
	beginStr := begin.Format(DateFormat)
	endStr := end.Format(DateFormat)

	var cvs []CustomerVisit
	err := DB.Select(&cvs, `
		SELECT 
			v.id AS id,
			c.id AS customer_id,
			c.uuid AS customer_uuid,
			c.first_name AS first_name,
			c.last_name AS last_name,
			v.visit_date AS visit_date,
			v.notes AS notes
      	FROM visits v
        LEFT JOIN customers c ON c.id = v.customer_id
		WHERE v.visit_date BETWEEN $1 AND $2
        ORDER BY v.visit_date DESC`,
		beginStr, endStr,
	)
	if err != nil {
		return nil, fmt.Errorf("get customer visits between %s and %s: %w", beginStr, endStr, err)
	}

	return cvs, nil
}

func VisitDetailsOfCustomer(customerId int64) ([]CustomerVisit, error) {
	var cvs []CustomerVisit
	err := DB.Select(&cvs, `
		SELECT
			v.id AS id,
			c.id AS customer_id,
			c.uuid AS customer_uuid,
			c.first_name AS first_name,
			c.last_name AS last_name,
			v.visit_date AS visit_date,
			v.notes AS notes
		FROM visits v
		LEFT JOIN customers c ON c.id = v.customer_id
		WHERE v.customer_id = $1`,
		customerId,
	)
	if err != nil {
		return nil, fmt.Errorf("get visit details of customer: %w", err)
	}

	return cvs, nil
}

func VisitsOfCustomer(customerId int64, limit int) ([]Visit, error) {
	var vs []Visit
	err := DB.Select(&vs, `
		SELECT * FROM visits
		WHERE customer_id = $1
	`, customerId,
	)
	if err != nil {
		return nil, fmt.Errorf("get visits of customer: %w", err)
	}
	return vs, nil
}

func UpdateVisit(visitId int64, newV Visit) error {
	newV.Id = visitId
	res, err := DB.NamedExec(`
        UPDATE customers
        SET customer_id = :customer_id,
			visit_date = :visit_date,
			notes = :notes
        WHERE id = :id`,
		&newV,
	)
	if err != nil {
		return fmt.Errorf("update visit %d: %w", visitId, err)
	}

	rows, err := res.RowsAffected()
	if err != nil {
		return fmt.Errorf("check update result for visit %d: %w", visitId, err)
	}

	if rows == 0 {
		return ErrNotFound
	}

	return nil
}

func DeleteVisit(visitId int64) (*Visit, error) {
	var customerId *int64
	if err := DB.Get(&customerId, `
		DELETE FROM visits WHERE id = ?
		RETURNING customer_id
	`, visitId); err != nil {
		return nil, err
	}

	if customerId == nil {
		return nil, nil
	}

	// lastVisit can be nil
	lastVisit, err := UpdateCustomerLastVisit(*customerId)
	if err != nil {
		return nil, err
	}

	return lastVisit, nil
}

func DeleteLastVisitOfCustomer(customerId int64) (*Visit, error) {
	customer, err := CustomerById(customerId)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, ErrNotFound
		}
		return nil, fmt.Errorf("delete last visit of customer %d: %w", customerId, err)
	}

	if customer.LastVisitId == nil {
		return nil, nil
	}

	lastVisit, err := DeleteVisit(*customer.LastVisitId)
	if err != nil {
		return nil, err
	}
	return lastVisit, err
}

func GetLatestVisitByCustomer(customerId int64) (*Visit, error) {
	var visit Visit
	if err := DB.Get(&visit, `
		SELECT * FROM visits
		WHERE customer_id = $1
		ORDER BY visit_date DESC
		LIMIT 1
	`, customerId); err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, nil
		}
		return nil, fmt.Errorf("get latest visit for customer %d: %w", customerId, err)
	}
	return &visit, nil
}
