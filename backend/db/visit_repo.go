package db

import (
	"database/sql"
	"errors"
	"fmt"
	"time"

	"github.com/jmoiron/sqlx"
)

func VisitById(visitId int64) (Visit, error) {
	var visit Visit
	if err := db.Get(&visit, `
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
	return withTx(func(tx *sqlx.Tx) (Visit, error) {
		var visitDateStr string
		if visitDate == nil {
			visitDateStr = time.Now().Format(DateFormat)
		} else {
			visitDateStr = visitDate.Format(DateFormat)
		}

		var newVisit Visit
		err := tx.Get(&newVisit, `
			INSERT INTO visits (customer_id, visit_date, notes)
			VALUES ($1, $2, $3)
			RETURNING *`,
			customerId, visitDateStr, notes,
		)
		if err != nil {
			return newVisit, fmt.Errorf("insert visit for customer %d: %w", customerId, err)
		}

		if err := setCustomerLastVisitTx(tx, customerId, newVisit); err != nil {
			return newVisit, fmt.Errorf("update last visit for customer %d: %w", customerId, err)
		}

		return newVisit, nil
	})

}

func AllVisitDetailsPaginated(page Page) (PageResult[VisitDetail], error) {
	return withTx(func(tx *sqlx.Tx) (PageResult[VisitDetail], error) {
		cvs := []VisitDetail{}
		limit, offset := page.LimitOffset()

		var total int64
		err := tx.Get(&total, `SELECT COUNT(*) FROM visits`)
		if err != nil {
			return PageResult[VisitDetail]{}, fmt.Errorf("get number of visits: %w", err)
		}

		// LEFT JOIN to include visits with deleted customer
		// sqlite does not have RIGHT JOIN
		err = tx.Select(&cvs, `
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
			ORDER BY v.visit_date DESC
			LIMIT $1 OFFSET $2`,
			limit, offset,
		)
		if err != nil {
			return PageResult[VisitDetail]{}, fmt.Errorf("get visit details: %w", err)
		}
		return PageResultOf(cvs, page, total), nil
	})
}

func VisitDetailsBetweenPaginated(
	begin time.Time,
	end time.Time,
	page Page,
) (PageResult[VisitDetail], error) {
	return withTx(func(tx *sqlx.Tx) (PageResult[VisitDetail], error) {
		beginStr := begin.Format(DateFormat)
		endStr := end.Format(DateFormat)
		limit, offset := page.LimitOffset()

		var total int64
		err := tx.Get(&total, `
			SELECT COUNT(*) FROM visits
			WHERE visit_date BETWEEN $1 AND $2
			ORDER BY visit_date DESC`,
			beginStr, endStr,
		)
		if err != nil {
			return PageResult[VisitDetail]{}, fmt.Errorf("get number of visits: %w", err)
		}

		cvs := []VisitDetail{}
		err = tx.Select(&cvs, `
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
			ORDER BY v.visit_date DESC
			LIMIT $3 OFFSET $4`,
			beginStr, endStr, limit, offset,
		)
		if err != nil {
			return PageResult[VisitDetail]{}, fmt.Errorf("get customer visits between %s and %s: %w", beginStr, endStr, err)
		}

		return PageResultOf(cvs, page, total), nil
	})
}

func VisitsOfCustomerPaginated(customerId int64, page Page) (PageResult[Visit], error) {
	return withTx(func(tx *sqlx.Tx) (PageResult[Visit], error) {
		cvs := []Visit{}
		limit, offset := page.LimitOffset()

		var total int64
		err := tx.Get(&total, `
			SELECT COUNT(*) FROM visits
			WHERE customer_id = $1`,
			customerId,
		)
		if err != nil {
			return PageResult[Visit]{}, fmt.Errorf("get number of visits: %w", err)
		}

		err = tx.Select(&cvs, `
			SELECT * FROM visits v
			WHERE customer_id = $1
			LIMIT $2 OFFSET $3`,
			customerId, limit, offset,
		)
		if err != nil {
			return PageResult[Visit]{}, fmt.Errorf("get visit details of customer: %w", err)
		}

		return PageResultOf(cvs, page, total), nil
	})
}

func VisitsOfCustomer(customerId int64, limit int) ([]Visit, error) {
	vs := []Visit{}
	err := db.Select(&vs, `
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
	res, err := db.NamedExec(`
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

// Deletes visit by visit id,
// returns new last visit of the same customer who visited
func DeleteVisit(visitId int64) (*Visit, error) {
	return withTx(func(tx *sqlx.Tx) (*Visit, error) {
		var customerId *int64
		if err := tx.Get(&customerId, `
			DELETE FROM visits WHERE id = ?
			RETURNING customer_id
		`, visitId); err != nil {
			if errors.Is(err, sql.ErrNoRows) {
				return nil, ErrNotFound
			}
			return nil, err
		}

		if customerId == nil {
			return nil, nil
		}

		// lastVisit can be nil
		lastVisit, err := updateCustomerLastVisitTx(tx, *customerId)
		if err != nil {
			return nil, err
		}

		return lastVisit, nil
	})
}

// Deletes last visit by customer id, returns the customer's new last visit
func DeleteLastVisitOfCustomer(customerId int64) (*Visit, error) {
	return withTx(func(tx *sqlx.Tx) (*Visit, error) {
		customer, err := customerByIdTx(tx, customerId)
		if err != nil {
			return nil, fmt.Errorf("delete last visit of customer %d: %w", customerId, err)
		}

		if customer.LastVisitId == nil {
			return nil, nil
		}

		lastVisit, err := deleteVisitTx(tx, *customer.LastVisitId)
		if err != nil {
			return nil, err
		}
		return lastVisit, nil
	})
}

func deleteVisitTx(tx *sqlx.Tx, visitId int64) (*Visit, error) {
	var customerId *int64
	if err := tx.Get(&customerId, `
		DELETE FROM visits WHERE id = ?
		RETURNING customer_id
	`, visitId); err != nil {
		return nil, err
	}

	if customerId == nil {
		return nil, nil
	}

	// lastVisit can be nil
	lastVisit, err := updateCustomerLastVisitTx(tx, *customerId)
	if err != nil {
		return nil, err
	}

	return lastVisit, nil
}

// Re-calculates the latest visit and return it
func getLatestVisitByCustomerTx(tx *sqlx.Tx, customerId int64) (*Visit, error) {
	var visit Visit
	if err := tx.Get(&visit, `
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
