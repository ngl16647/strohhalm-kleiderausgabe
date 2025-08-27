package db

import (
	"database/sql"
	"fmt"
	"time"
)

/////////////////////////////////////
// Customer repository begins here //
/////////////////////////////////////

func scanCustomers(rows *sql.Rows) ([]Customer, error) {
	defer rows.Close()

	var customers []Customer
	for rows.Next() {
		var c Customer
		// Scanning rows
		if err := rows.Scan(
			&c.Id,
			&c.FirstName,
			&c.LastName,
		); err != nil {
			return nil, err
		}
		customers = append(customers, c)
	}

	if err := rows.Err(); err != nil {
		return nil, err
	}

	return customers, nil
}

func AddCustomer(firstName string, lastName string) (int64, error) {
	res, err := DB.Exec("INSERT INTO customers (FirstName, LastName) VALUES (?, ?)", firstName, lastName)
	if err != nil {
		return 0, fmt.Errorf("failed to add customer %s %s: %w", firstName, lastName, err)
	}
	return res.LastInsertId()
}

func AllCustomers() ([]Customer, error) {
	rows, err := DB.Query("SELECT Id, FirstName, LastName FROM customers")
	if err != nil {
		return nil, fmt.Errorf("failed to get all customers: %w", err)
	}
	return scanCustomers(rows)
}

func CustomersByName(firstName string, lastName string) ([]Customer, error) {
	rows, err := DB.Query(`
		SELECT Id, FirstName, LastName 
			FROM customers 
			WHERE FirstName = ? 
			AND LastName = ?
		`,
		firstName,
		lastName,
	)
	if err != nil {
		return nil, fmt.Errorf("failed to get customers by name: %w", err)
	}
	return scanCustomers(rows)
}

//////////////////////////////////
// Visit repository begins here //
//////////////////////////////////

func scanCustomerVisits(rows *sql.Rows) ([]CustomerVisit, error) {
	defer rows.Close()

	var cvs []CustomerVisit
	for rows.Next() {
		var cv CustomerVisit
		var dateStr string
		// Scanning rows
		if err := rows.Scan(
			&cv.Id,
			&cv.CustomerId,
			&cv.CustomerFirstName,
			&cv.CustomerLastName,
			&dateStr,
		); err != nil {
			return nil, err
		}

		// Parsing time
		date, err := time.Parse(DateFormat, dateStr)
		if err != nil {
			return nil, err
		}
		cv.VisitDate = date

		cvs = append(cvs, cv)
	}

	if err := rows.Err(); err != nil {
		return nil, err
	}

	return cvs, nil
}

func AddVisitNow(customerId int64) (int64, error) {
	res, err := DB.Exec("INSERT INTO visits (CustomerId, VisitDate) VALUES (?, ?)", customerId, time.Now().Format(DateFormat))
	if err != nil {
		return 0, fmt.Errorf("insert visit for customer %d: %w", customerId, err)
	}
	return res.LastInsertId()
}

func AllCustomerVisits() ([]CustomerVisit, error) {
	rows, err := DB.Query(`
        SELECT v.Id, c.Id, c.FirstName, c.LastName, v.VisitDate
        FROM customers c
        JOIN visits v ON c.Id = v.CustomerId
        ORDER BY v.VisitDate DESC
    `)
	if err != nil {
		return nil, fmt.Errorf("failed to get customer visits: %w", err)
	}
	return scanCustomerVisits(rows)
}
