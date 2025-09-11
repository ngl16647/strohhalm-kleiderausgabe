package tests

import (
	"log"
	"strohhalm-backend/db"
	"testing"
	"time"

	_ "github.com/mattn/go-sqlite3"
)

func TestAddAndSearchCustomer(t *testing.T) {
	db.InitDatabase(":memory:")

	c1 := db.Customer{Id: 1, FirstName: "A", LastName: "Customer", Birthday: TestDate, Notes: "very fat"}

	c, err := db.AddCustomer(db.Customer{
		FirstName: c1.FirstName,
		LastName:  c1.LastName,
		Birthday:  TestDate,
		Notes:     c1.Notes,
	})
	FatalErr(t, err, "failed to add user")

	if c.Id != 1 {
		t.Fatal("New Customer ID is not 1")
	}

	customers, err := db.AllCustomers()
	FatalErr(t, err, "failed to get user")

	t.Log(customers)

	_, err = db.AddCustomer(db.Customer{FirstName: "Another", LastName: "Person", Birthday: TestDate})
	FatalErr(t, err)

	searchC, err := db.SearchCustomer(" cus")
	FatalErr(t, err)
	t.Log(searchC)
}

func TestAddVisit(t *testing.T) {
	db.InitDatabase(":memory:")

	cInput := db.Customer{FirstName: "A", LastName: "Customer", Birthday: TestDate}

	c, err := db.AddCustomer(cInput)
	FatalErr(t, err)

	v, err := db.AddVisit(c.Id, nil, "we got robbed")
	FatalErr(t, err)
	if v.Id != 1 {
		t.Fatal("New Visit ID is not 1")
	}

	cvs, err := db.AllVisitDetails()
	FatalErr(t, err)
	log.Println(cvs)

	t1, _ := time.Parse(db.DateFormat, "2025-08-27")
	t2, _ := time.Parse(db.DateFormat, "2025-08-28")
	t.Log(t1)
	cvs, err = db.VisitDetailsBetween(t1, t2)
	FatalErr(t, err)
	log.Println(cvs)

	c, _ = db.CustomerById(1)
	t.Log(c)
}
