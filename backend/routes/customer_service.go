package routes

import (
	"net/http"
	"strconv"
	"strings"
	"strohhalm-backend/db"

	"github.com/go-chi/chi/v5"
)

func AddCustomerHandler(w http.ResponseWriter, r *http.Request) {
	var c db.Customer
	if err := DecodeBody(r, &c); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	// validating customer data
	c.FirstName = strings.TrimSpace(c.FirstName)
	c.LastName = strings.TrimSpace(c.LastName)
	if c.FirstName == "" || c.LastName == "" {
		http.Error(w, "first and last name are required", http.StatusBadRequest)
		return
	}

	c, err := db.AddCustomer(c)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	WriteJson(w, c, http.StatusCreated)
}

func GetCustomerHandler(w http.ResponseWriter, r *http.Request) {
	id, err := strconv.ParseInt(chi.URLParam(r, "id"), 10, 64)
	if err != nil {
		http.Error(w, "invalid customer ID", http.StatusBadRequest)
		return
	}

	c, err := db.CustomerById(id)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	WriteJson(w, c, http.StatusOK)
}

func SearchCustomerHandler(w http.ResponseWriter, r *http.Request) {
	query := strings.TrimSpace(GetParam(r, "query"))

	var cs []db.Customer
	var err error

	if query == "" {
		cs, err = db.AllCustomers()
	} else {
		cs, err = db.SearchCustomer(query)
	}
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	WriteJson(w, cs, http.StatusOK)
}

func UpdateCustomerHandler(w http.ResponseWriter, r *http.Request) {
	id, err := strconv.ParseInt(chi.URLParam(r, "id"), 10, 64)
	if err != nil {
		http.Error(w, "invalid customer ID", http.StatusBadRequest)
		return
	}

	var c db.Customer
	if err := DecodeBody(r, &c); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	// validating customer data
	c.FirstName = strings.TrimSpace(c.FirstName)
	c.LastName = strings.TrimSpace(c.LastName)
	if c.FirstName == "" || c.LastName == "" {
		http.Error(w, "first and last name are required", http.StatusBadRequest)
		return
	}

	err = db.UpdateCustomer(id, c)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Write([]byte("OK"))
}
