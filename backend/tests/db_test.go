package main

import (
	"strohalm-backend/db"
	"testing"

	_ "github.com/mattn/go-sqlite3"
)

func TestHelloName(t *testing.T) {
	db.InitDatabase(":memory:")
	err := db.AddCustomer("Shit", "Eater")
	if err != nil {
		t.Fatal(err.Error())
	}

	customers, err := db.GetAllCustomers()
	if err != nil {
		t.Fatal(err.Error())
	}

	if (customers[0] != db.Customer{Id: 1, FirstName: "Shit", LastName: "Eater"}) {
		t.Fatal("Incorrect customer was fetched")
	}
}
