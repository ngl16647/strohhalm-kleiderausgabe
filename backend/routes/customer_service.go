package routes

import (
	"net/http"
	"strings"
	"strohhalm-backend/db"
)

func AddCustomerHandler(w http.ResponseWriter, r *http.Request) {
	var c db.Customer
	if err := DecodeBody(r, &c); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	// trim/validate in handler
	c.FirstName = strings.TrimSpace(c.FirstName)
	c.LastName = strings.TrimSpace(c.LastName)
	if c.FirstName == "" || c.LastName == "" {
		http.Error(w, "first and last name are required", http.StatusBadRequest)
		return
	}

	id, err := db.AddCustomer(c)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	WriteJson(w, map[string]int64{"id": id}, http.StatusCreated)
}
