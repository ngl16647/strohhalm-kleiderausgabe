package db

import "time"

type Customer struct {
	Id        int64  `json:"id"`
	FirstName string `json:"firstName"`
	LastName  string `json:"lastName"`
}

type CustomerVisit struct {
	Id                int64     `json:"id"`
	CustomerId        int64     `json:"customerId"`
	CustomerFirstName string    `json:"customerFirstName"`
	CustomerLastName  string    `json:"customerLastName"`
	VisitDate         time.Time `json:"visitDate"`
}

const DateFormat = "2006-01-02"

const (
	CustomerInitStr = `
		CREATE TABLE IF NOT EXISTS customers (
            Id INTEGER PRIMARY KEY AUTOINCREMENT,
            FirstName TEXT NOT NULL,
            LastName TEXT NOT NULL
        )
	`
	VisitsInitStr = `
		CREATE TABLE IF NOT EXISTS visits (
            Id INTEGER PRIMARY KEY AUTOINCREMENT,
			CustomerId INTEGER,
			VisitDate TEXT NOT NULL,
			FOREIGN KEY (CustomerId) REFERENCES customers(Id)
        )
	`
)
