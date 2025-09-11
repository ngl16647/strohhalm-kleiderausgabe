package db

import (
	"errors"
	"fmt"
	"strings"

	"github.com/google/uuid"
)

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
		return fmt.Errorf("update customer %d: %w", customerId, err)
	}

	rows, err := res.RowsAffected()
	if err != nil {
		return fmt.Errorf("check update result for customer %d: %w", customerId, err)
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
		return nil, fmt.Errorf("get all customers: %w", err)
	}
	return cs, nil
}

func CustomerById(id int64) (Customer, error) {
	var c Customer
	err := DB.Get(&c, "SELECT * FROM customers WHERE id = $1", id)
	if err != nil {
		var empty Customer
		return empty, fmt.Errorf("get customer by id %d: %w", id, err)
	}

	return c, nil
}

func CustomerByUuid(uuid string) (Customer, error) {
	var c Customer
	err := DB.Get(&c, "SELECT * FROM customers WHERE uuid = $1", uuid)
	if err != nil {
		var empty Customer
		return empty, fmt.Errorf("get customer by uuid %s: %w", uuid, err)
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
		return nil, fmt.Errorf("search customer: %w", err)
	}
	return cs, nil
}

func SetCustomerLastVisit(customerId int64, newVisit Visit) error {
	if _, err := DB.Exec(`
		UPDATE customers
		SET last_visit_id = $1,
			last_visit = $2
		WHERE id = $3
		AND (last_visit IS NULL OR last_visit < $2)`,
		newVisit.Id, newVisit.VisitDate, customerId,
	); err != nil {
		return fmt.Errorf("update last visit for customer %d: %w", customerId, err)
	}
	return nil
}

func UpdateCustomerLastVisit(customerId int64) error {
	lastVisit, err := GetLatestVisitByCustomer(customerId)
	if err != nil {
		if err == ErrNotFound {
			return nil
		}
		return fmt.Errorf("find last visit for customer %d: %w", customerId, err)
	}

	if _, err := DB.Exec(`
		UPDATE customers
		SET last_visit_id = $1,
			last_visit = $2 
		WHERE id = $3`,
		lastVisit.Id, lastVisit.VisitDate, customerId); err != nil {
		return fmt.Errorf("update last visit for customer %d: %w", customerId, err)
	}
	return nil
}

func DeleteCustomer(customerId int64) error {
	_, err := DB.Exec("DELETE FROM customers WHERE id = ?", customerId)
	if err != nil {
		return fmt.Errorf("delete customer: %w", err)
	}
	return nil
}
