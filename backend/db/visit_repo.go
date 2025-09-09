package db

import (
	"errors"
	"fmt"
	"time"
)

func AddVisitNow(customerId int64, notes string) (Visit, error) {
	today := time.Now()
	todayStr := today.Format(DateFormat)

	res, err := DB.Exec(
		"INSERT INTO visits (customer_id, visit_date, notes) VALUES (?, ?, ?)",
		customerId, todayStr, notes,
	)
	if err != nil {
		return Visit{}, fmt.Errorf("insert visit for customer %d: %w", customerId, err)
	}

	if err := SetCustomerLastVisit(customerId, today); err != nil {
		return Visit{}, fmt.Errorf("update last visit for customer %d: %w", customerId, err)
	}

	visitId, err := res.LastInsertId()
	if err != nil {
		return Visit{}, err
	}

	return Visit{
		Id:         visitId,
		CustomerId: &customerId,
		VisitDate:  todayStr,
		Notes:      notes,
	}, nil
}

func AddVisitAt(customerId int64, visitDate time.Time, notes string) (Visit, error) {
	visitDateStr := visitDate.Format(DateFormat)

	res, err := DB.Exec(
		"INSERT INTO visits (customer_id, visit_date, notes) VALUES (?, ?, ?)",
		customerId, visitDateStr, notes,
	)
	if err != nil {
		return Visit{}, fmt.Errorf("insert visit for customer %d: %w", customerId, err)
	}

	if err := SetCustomerLastVisit(customerId, visitDate); err != nil {
		return Visit{}, fmt.Errorf("update last visit for customer %d: %w", customerId, err)
	}

	visitId, err := res.LastInsertId()
	if err != nil {
		return Visit{}, err
	}

	return Visit{
		Id:         visitId,
		CustomerId: &customerId,
		VisitDate:  visitDateStr,
		Notes:      notes,
	}, nil
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
		return nil, fmt.Errorf("failed to get customer visits: %w", err)
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
		return nil, fmt.Errorf("failed to get customer visits between %s and %s: %w", beginStr, endStr, err)
	}

	return cvs, nil
}

func VisitsOfCustomer(customerId int64) ([]CustomerVisit, error) {
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
		return nil, fmt.Errorf("failed to get visits: %w", err)
	}

	return cvs, nil
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
		return fmt.Errorf("failed to update visit %d: %w", visitId, err)
	}

	rows, err := res.RowsAffected()
	if err != nil {
		return fmt.Errorf("failed to check update result for visit %d: %w", visitId, err)
	}

	if rows == 0 {
		return errors.New("visit not found")
	}

	return nil
}

func DeleteVisit(visitId int64) error {
	var customerId *int64
	if err := DB.Get(&customerId, `
		DELETE FROM visits WHERE id = ?
		RETURNING customer_id
	`, visitId); err != nil {
		return err
	}

	if customerId == nil {
		return nil
	}

	if err := UpdateCustomerLastVisit(*customerId); err != nil {
		return err
	}

	return nil
}
