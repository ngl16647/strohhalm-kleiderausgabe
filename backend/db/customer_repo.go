package db

import (
	"database/sql"
	"fmt"
	"strings"

	"github.com/google/uuid"
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

func AddCustomer(c Customer) (Customer, error) {
	if c.Uuid == "" {
		c.Uuid = uuid.NewString()
	}
	res, err := DB.NamedExec(
		`INSERT INTO customers (uuid, first_name, last_name, birthday, country, notes) 
			VALUES (:uuid, :first_name, :last_name, :birthday, :country, :notes)`,
		&c,
	)
	if err != nil {
		return Customer{}, fmt.Errorf("failed to add customer %s %s: %w", c.FirstName, c.LastName, err)
	}
	id, err := res.LastInsertId()
	if err != nil {
		return Customer{}, fmt.Errorf("unable to get user id")
	}
	c.Id = id
	return c, nil
}

func UpdateCustomer(customerId int64, newC Customer) error {
	res, err := DB.Exec(`
        UPDATE customers
        SET uuid = ?, first_name = ?, last_name = ?, birthday = ?, country = ?, notes = ?
        WHERE Id = ?`,
		newC.Uuid, newC.FirstName, newC.LastName, newC.Birthday, newC.Country, newC.Notes,
		customerId,
	)
	if err != nil {
		return fmt.Errorf("failed to update customer %d: %w", customerId, err)
	}

	rows, err := res.RowsAffected()
	if err != nil {
		return fmt.Errorf("failed to check update result for customer %d: %w", customerId, err)
	}

	if rows == 0 {
		return fmt.Errorf("customer %d not found", customerId)
	}

	return nil
}

func AllCustomers() ([]Customer, error) {
	cs := []Customer{}
	err := DB.Select(&cs, "SELECT * FROM customers")
	if err != nil {
		return nil, fmt.Errorf("failed to get all customers: %w", err)
	}
	return cs, nil
}

func CustomerById(id int64) (Customer, error) {
	c := Customer{}
	err := DB.Get(&c, "SELECT * FROM customers WHERE Id = $1", id)
	if err != nil {
		var empty Customer
		return empty, fmt.Errorf("failed to get customer by id %d: %w", id, err)
	}

	return c, nil
}

func SearchCustomer(query string) ([]Customer, error) {
	if strings.TrimSpace(query) == "" {
		return AllCustomers()
	}

	cs := []Customer{}
	err := DB.Select(&cs,
		`SELECT * FROM customers
			WHERE LOWER(first_name || ' ' || last_name) LIKE $1`,
		"%"+strings.ToLower(query)+"%",
	)
	if err != nil {
		return nil, fmt.Errorf("failed to query customer: %w", err)
	}
	return cs, nil
}
