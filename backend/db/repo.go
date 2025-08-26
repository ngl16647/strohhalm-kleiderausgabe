package db

import (
	"database/sql"
	"fmt"
)

func scanCustomers(rows *sql.Rows) ([]Customer, error) {
	var customers []Customer
	for rows.Next() {
		var c Customer
		if err := rows.Scan(&c.Id, &c.FirstName, &c.LastName); err != nil {
			return nil, err
		}
		customers = append(customers, c)
	}

	if err := rows.Err(); err != nil {
		return nil, err
	}

	return customers, nil
}

func AddCustomer(firstName string, lastName string) error {
	_, err := DB.Exec("INSERT INTO customers (FirstName, LastName) VALUES (?, ?)", firstName, lastName)
	if err != nil {
		return fmt.Errorf("failed to add customer %s %s: %w", firstName, lastName, err)
	}
	return nil
}

func GetAllCustomers() ([]Customer, error) {
	rows, err := DB.Query("SELECT Id, FirstName, LastName FROM customers")
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	return scanCustomers(rows)
}

func GetCustomersByName(name string) ([]Customer, error) {
	rows, err := DB.Query("SELECT Id, FirstName, LastName FROM customers WHERE Name = ?", name)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	return scanCustomers(rows)
}

// func GetCustomerVisitsById(id int) ([]CustomerVisit) {
// 	rows, err := DB.Query("SELECT ")
// }
