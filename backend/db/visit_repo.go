package db

import (
	"database/sql"
	"fmt"
	"time"
)

// helper
func scanCustomerVisits(rows *sql.Rows) ([]CustomerVisit, error) {
	defer rows.Close()

	var cvs []CustomerVisit
	for rows.Next() {
		var cv CustomerVisit

		// Scanning rows
		if err := rows.Scan(
			&cv.Id,
			&cv.CustomerId,
			&cv.CustomerFirstName,
			&cv.CustomerLastName,
			&cv.VisitDate,
			&cv.Notes,
		); err != nil {
			return nil, err
		}

		cvs = append(cvs, cv)
	}

	if err := rows.Err(); err != nil {
		return nil, err
	}

	return cvs, nil
}

func AddVisitNow(customerId int64, notes string) (int64, error) {
	res, err := DB.Exec(
		"INSERT INTO visits (CustomerId, VisitDate, Notes) VALUES (?, ?, ?)",
		customerId, time.Now().Format(DateFormat), notes,
	)
	if err != nil {
		return 0, fmt.Errorf("insert visit for customer %d: %w", customerId, err)
	}
	return res.LastInsertId()
}

func AllCustomerVisits() ([]CustomerVisit, error) {
	rows, err := DB.Query(`
        SELECT v.Id, c.Id, c.FirstName, c.LastName, v.VisitDate, v.Notes
        FROM customers c
        JOIN visits v ON c.Id = v.CustomerId
        ORDER BY v.VisitDate DESC
    `)
	if err != nil {
		return nil, fmt.Errorf("failed to get customer visits: %w", err)
	}
	return scanCustomerVisits(rows)
}

func CustomerVisitsBetween(begin time.Time, end time.Time) ([]CustomerVisit, error) {
	beginStr := begin.Format(DateFormat)
	endStr := end.Format(DateFormat)

	rows, err := DB.Query(`
        SELECT v.Id, c.Id, c.FirstName, c.LastName, v.VisitDate, v.Notes
        FROM customers c
        JOIN visits v ON c.Id = v.CustomerId
        WHERE v.VisitDate BETWEEN ? AND ?
        ORDER BY v.VisitDate DESC
    `, beginStr, endStr)
	if err != nil {
		return nil, fmt.Errorf("failed to get customer visits between %s and %s: %w", beginStr, endStr, err)
	}

	return scanCustomerVisits(rows)
}
