package db

import (
	"errors"
	"fmt"
	"strings"
	"time"

	"github.com/google/uuid"
)

func AddCustomer(c Customer) (Customer, error) {
	if c.Uuid == "" {
		c.Uuid = uuid.NewString()
	}
	res, err := DB.NamedExec(
		`INSERT INTO customers (uuid, first_name, last_name, birthday, country, last_visit, notes) 
			VALUES (:uuid, :first_name, :last_name, :birthday, :country, :last_visit, :notes)`,
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
	newC.Id = customerId
	// uuid cannot be updated
	res, err := DB.NamedExec(`
        UPDATE customers
        SET first_name = :first_name,
			last_name = :last_name,
			birthday = :birthday,
			country = :country,
			notes = :notes
        WHERE id = :id`,
		&newC,
	)
	if err != nil {
		return fmt.Errorf("failed to update customer %d: %w", customerId, err)
	}

	rows, err := res.RowsAffected()
	if err != nil {
		return fmt.Errorf("failed to check update result for customer %d: %w", customerId, err)
	}

	if rows == 0 {
		return errors.New("custome not found")
	}

	return nil
}

func AllCustomers() ([]Customer, error) {
	var cs []Customer
	err := DB.Select(&cs, "SELECT * FROM customers")
	if err != nil {
		return nil, fmt.Errorf("failed to get all customers: %w", err)
	}
	return cs, nil
}

func CustomerById(id int64) (Customer, error) {
	var c Customer
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

	var cs []Customer
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

func SetCustomerLastVisit(customerId int64, lastVisit time.Time) error {
	newVisit := lastVisit.Format(DateFormat)
	if _, err := DB.Exec(`
		UPDATE customers
		SET last_visit = ? 
		WHERE id = ? AND (last_visit IS NULL OR last_visit < ?)`,
		newVisit, customerId, newVisit,
	); err != nil {
		return fmt.Errorf("failed to update last visit for customer %d: %w", customerId, err)
	}
	return nil
}

func UpdateCustomerLastVisit(customerId int64) error {
	if _, err := DB.Exec(`
		UPDATE customers
		SET last_visit = (
			SELECT MAX(v.visit_date)
			FROM visits v
			WHERE v.customer_id = ?
		)
		WHERE id = ?`,
		customerId, customerId); err != nil {
		return fmt.Errorf("failed to update last visit for customer %d: %w", customerId, err)
	}
	return nil
}

func DeleteCustomer(customerId int64) error {
	_, err := DB.Exec("DELETE FROM customers WHERE id = ?", customerId)
	if err != nil {
		return err
	}

	return nil
}
