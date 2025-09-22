package db

import "time"

type Customer struct {
	Id          int64   `json:"id"`
	Uuid        string  `json:"uuid"`
	FirstName   string  `db:"first_name" json:"firstName"`
	LastName    string  `db:"last_name" json:"lastName"`
	Birthday    string  `json:"birthday"`
	Country     string  `json:"country"`
	LastVisitId *int64  `db:"last_visit_id" json:"lastVisitId"`
	LastVisit   *string `db:"last_visit" json:"lastVisit"`
	Notes       string  `json:"notes"`
}

// Use pointer for nullable values
type Visit struct {
	Id         int64  `json:"visitId"`
	CustomerId *int64 `db:"customer_id" json:"customerId"`
	VisitDate  string `db:"visit_date" json:"visitDate"`
	Notes      string `json:"notes,omitempty"`
}

type VisitDetail struct {
	Id                int64   `db:"id" json:"visitId"`
	CustomerId        *int64  `db:"customer_id" json:"customerId"`
	CustomerUuid      *string `db:"customer_uuid" json:"customerUuid"`
	CustomerFirstName *string `db:"first_name" json:"customerFirstName"`
	CustomerLastName  *string `db:"last_name" json:"customerLastName"`
	VisitDate         string  `db:"visit_date" json:"visitDate"`
	Notes             string  `db:"notes" json:"notes"`
}

// for pagination
type Page struct {
	Size int64 // size of page
	Page int64 // page number
}

type PageResult[T any] struct {
	Data     []T   `json:"data"` // this is already a pointer, copying PageResult is cheap
	DataSize int   `json:"dataSize"`
	PageSize int64 `json:"pageSize"`
	Page     int64 `json:"pageNumber"`
	Total    int64 `json:"totalPages"`
}

func (p Page) LimitOffset() (int64, int64) {
	if p.Size <= 0 {
		p.Size = 10 // default page size
	}
	if p.Page <= 0 {
		p.Page = 1
	}
	limit := p.Size
	offset := (p.Page - 1) * p.Size
	return limit, offset
}

func PageResultOf[T any](data []T, page Page, total int64) PageResult[T] {
	totalPages := (total + page.Size - 1) / page.Size
	return PageResult[T]{
		Data:     data,
		DataSize: len(data),
		Page:     page.Page,
		PageSize: page.Size,
		Total:    totalPages,
	}
}

const DateFormat = "2006-01-02"

var (
	MinDate = time.Date(0, 1, 1, 0, 0, 0, 0, time.UTC)
	MaxDate = time.Date(9999, 12, 31, 0, 0, 0, 0, time.UTC)
)

const (
	CustomerInitStr = `
		CREATE TABLE IF NOT EXISTS customers (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
			uuid TEXT NOT NULL,
            first_name TEXT NOT NULL,
            last_name TEXT NOT NULL,
			birthday TEXT,
			country TEXT,
			last_visit_id INTEGER,
			last_visit TEXT,
			notes TEXT
        );
	`
	// Use "ON DELETE SET NULL" to allow visit record to exist with deleted customer
	// Use UNIQUE(costumer_id, visit_date) to endure a customer cannot visit twice a day
	VisitsInitStr = `
		CREATE TABLE IF NOT EXISTS visits (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
			customer_id INTEGER,
			visit_date TEXT NOT NULL,
			notes TEXT,
			FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE SET NULL,
			UNIQUE(customer_id, visit_date)
        );
	`
)

var Indices = []string{
	`PRAGMA foreign_keys = ON;`,
	`CREATE INDEX IF NOT EXISTS idx_visits_visit_date ON visits(visit_date);`,
	`CREATE INDEX IF NOT EXISTS idx_customers_first_name ON customers(first_name);`,
}
