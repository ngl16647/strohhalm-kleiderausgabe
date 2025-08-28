package db

import (
	"database/sql"
	"fmt"
	"strings"
)

// helper
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
			&c.Birthday,
			&c.Notes,
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

func AddCustomer(c Customer) (int64, error) {
	res, err := DB.Exec(
		"INSERT INTO customers (FirstName, LastName, Birthday, Notes) VALUES (?, ?, ?, ?)",
		c.FirstName, c.LastName, c.Birthday, c.Notes,
	)
	if err != nil {
		return 0, fmt.Errorf("failed to add customer %s %s: %w", c.FirstName, c.LastName, err)
	}
	return res.LastInsertId()
}

func UpdateCustomer(c Customer, newC Customer) error {
	res, err := DB.Exec(`
        UPDATE customers
        SET FirstName = ?, LastName = ?, Birthday = ?, Notes = ?
        WHERE Id = ?`,
		newC.FirstName, newC.LastName, newC.Birthday, newC.Notes,
		c.Id,
	)
	if err != nil {
		return fmt.Errorf("failed to update customer %d: %w", c.Id, err)
	}

	rows, err := res.RowsAffected()
	if err != nil {
		return fmt.Errorf("failed to check update result for customer %d: %w", c.Id, err)
	}

	if rows == 0 {
		return fmt.Errorf("customer %d not found", c.Id)
	}

	return nil
}

func AllCustomers() ([]Customer, error) {
	rows, err := DB.Query("SELECT Id, FirstName, LastName, Birthday, Notes FROM customers")
	if err != nil {
		return nil, fmt.Errorf("failed to get all customers: %w", err)
	}
	return scanCustomers(rows)
}

func CustomersById(id int64) (Customer, error) {
	rows, err := DB.Query(`
		SELECT Id, FirstName, LastName, Birthday, Notes
			FROM customers 
			WHERE Id = ?
		`, id,
	)
	if err != nil {
		var empty Customer
		return empty, fmt.Errorf("failed to get customer by id %d: %w", id, err)
	}

	cs, err := scanCustomers(rows)
	if err != nil {
		var empty Customer
		return empty, fmt.Errorf("failed to get customer by id %d: %w", id, err)
	}

	if len(cs) == 0 {
		var empty Customer
		return empty, ErrNotFound
	}

	return cs[0], nil
}

func SearchCustomer(query string) ([]Customer, error) {
	if strings.TrimSpace(query) == "" {
		return AllCustomers()
	}

	rows, err := DB.Query(`
		SELECT Id, FirstName, LastName, Birthday, Notes
			FROM customers
			WHERE LOWER(FirstName || ' ' || LastName) LIKE ?
		`, "%"+strings.ToLower(query)+"%",
	)
	if err != nil {
		return nil, fmt.Errorf("failed to query customer: %w", err)
	}
	return scanCustomers(rows)
}
