package tests

import (
	"log"
	"strohalm-backend/db"
	"testing"

	_ "github.com/mattn/go-sqlite3"
)

func TestAddAndSearchCustomer(t *testing.T) {
	db.InitDatabase(":memory:")

	c1 := db.Customer{Id: 1, FirstName: "A", LastName: "Customer", Birthday: TestDate, Notes: "very fat"}

	id, err := db.AddCustomer(db.Customer{
		FirstName: c1.FirstName,
		LastName:  c1.LastName,
		Birthday:  TestDate,
		Notes:     c1.Notes,
	})
	FatalErr(t, err, "failed to add user")

	if id != 1 {
		t.Fatal("New Customer ID is not 1")
	}

	customers, err := db.AllCustomers()
	FatalErr(t, err, "failed to get user")

	if customers[0] != c1 {
		t.Fatal("Incorrect customer was fetched")
	}

	_, err = db.AddCustomer(db.Customer{FirstName: "Another", LastName: "Person", Birthday: TestDate})
	FatalErr(t, err)

	searchC, err := db.SearchCustomer(" cus")
	FatalErr(t, err)
	t.Log(searchC)
	if searchC[0] != c1 {
		t.Fatal("Incorrect customer was searched")
	}
}

func TestAddVisit(t *testing.T) {
	db.InitDatabase(":memory:")

	c := db.Customer{FirstName: "A", LastName: "Customer", Birthday: TestDate}

	cid, err := db.AddCustomer(c)
	FatalErr(t, err)

	vid, err := db.AddVisitNow(cid)
	FatalErr(t, err)
	if vid != 1 {
		t.Fatal("New Visit ID is not 1")
	}

	cvs, err := db.AllCustomerVisits()
	FatalErr(t, err)
	log.Println(cvs)

}
