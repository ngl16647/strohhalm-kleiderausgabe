package db

import (
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

	return Visit{Id: visitId, CustomerId: customerId, VisitDate: todayStr, Notes: notes}, nil
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

	return Visit{Id: visitId, CustomerId: customerId, VisitDate: visitDateStr, Notes: notes}, nil
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

	cvs := []CustomerVisit{}
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
