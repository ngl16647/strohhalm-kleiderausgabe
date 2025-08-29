package db

type Customer struct {
	Id        int64  `json:"id"`
	Uuid      string `json:"uuid"`
	FirstName string `db:"first_name" json:"firstName"`
	LastName  string `db:"last_name" json:"lastName"`
	Birthday  string `json:"birthday,omitempty"`
	Country   string `json:"country,omitempty"`
	Notes     string `json:"notes,omitempty"`
}

type Visit struct {
	Id         int64  `db:"id"`
	CustomerId int64  `db:"customer_id"`
	VisitDate  string `db:"visit_date"`
	Notes      string `db:"notes"`
}

type CustomerVisit struct {
	Id                int64  `db:"id" json:"id"`
	CustomerId        int64  `db:"customer_id" json:"customerId"`
	CustomerFirstName string `db:"first_name" json:"customerFirstName"`
	CustomerLastName  string `db:"last_name" json:"customerLastName"`
	VisitDate         string `db:"visit_date" json:"visitDate"`
	Notes             string `db:"notes" json:"notes,omitempty"`
}

const DateFormat = "2006-01-02"

const (
	CustomerInitStr = `
		CREATE TABLE IF NOT EXISTS customers (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
			uuid TEXT NOT NULL,
            first_name TEXT NOT NULL,
            last_name TEXT NOT NULL,
			birthday TEXT,
			country TEXT,
			notes TEXT
        )
	`
	VisitsInitStr = `
		CREATE TABLE IF NOT EXISTS visits (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
			customer_id INTEGER,
			visit_date TEXT NOT NULL,
			notes TEXT,
			FOREIGN KEY (customer_id) REFERENCES customers(id)
        )
	`
)
