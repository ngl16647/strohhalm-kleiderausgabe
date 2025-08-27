package main

import (
	"log"
	"strohalm-backend/db"
	"testing"

	_ "github.com/mattn/go-sqlite3"
)

func TestMain(m *testing.M) {
	db.InitDatabase(":memory:")
	m.Run()
}

func fatalErr(t *testing.T, err error) {
	if err != nil {
		t.Fatal(err)
	}
}

func TestAddCustomer(t *testing.T) {
	id, err := db.AddCustomer("A", "Customer")
	fatalErr(t, err)

	if id != 1 {
		t.Fatal("New Customer ID is not 1")
	}

	customers, err := db.AllCustomers()
	fatalErr(t, err)

	if (customers[0] != db.Customer{Id: 1, FirstName: "A", LastName: "Customer"}) {
		t.Fatal("Incorrect customer was fetched")
	}
}

func TestAddVisit(t *testing.T) {
	cid, err := db.AddCustomer("Another", "Customer")
	fatalErr(t, err)

	vid, err := db.AddVisitNow(cid)
	fatalErr(t, err)
	if vid != 1 {
		t.Fatal("New Visit ID is not 1")
	}

	cvs, err := db.AllCustomerVisits()
	fatalErr(t, err)
	log.Println(cvs)

}
