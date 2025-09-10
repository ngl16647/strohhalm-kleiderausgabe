package routes

import (
	"net/http"
	"strings"
	"strohhalm-backend/db"

	"github.com/go-chi/chi/v5"
)

func AddCustomerHandler(w http.ResponseWriter, r *http.Request) {
	var c db.Customer
	if err := decodeBody(r, &c); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	// validating customer data
	err := prepareCustomerData(&c)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	c, err = db.AddCustomer(c)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	writeJson(w, c, http.StatusCreated)
}

func GetCustomerHandler(w http.ResponseWriter, r *http.Request) {
	id, err := parseIntFromUrl(r, "id")
	if err != nil {
		http.Error(w, "invalid customer ID", http.StatusBadRequest)
		return
	}

	c, err := db.CustomerById(id)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	writeJson(w, c, http.StatusOK)
}

func GetCustomerByUuidHandler(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "uuid")

	c, err := db.CustomerByUuid(id)
	if err != nil {
		if strings.Contains(err.Error(), "sql: no rows in result set") {
			http.Error(w, "customer not foudnd", http.StatusNotFound)
			return
		}
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	writeJson(w, c, http.StatusOK)
}

func SearchCustomerHandler(w http.ResponseWriter, r *http.Request) {
	query := strings.TrimSpace(getParam(r, "query"))

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

	writeJson(w, cs, http.StatusOK)
}

func UpdateCustomerHandler(w http.ResponseWriter, r *http.Request) {
	id, err := parseIntFromUrl(r, "id")
	if err != nil {
		http.Error(w, "invalid customer ID", http.StatusBadRequest)
		return
	}

	var c db.Customer
	if err := decodeBody(r, &c); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	// validating customer data
	err = prepareCustomerData(&c)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	err = db.UpdateCustomer(id, c)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	ok(w)
}

func DeleteCustomerHandler(w http.ResponseWriter, r *http.Request) {
	id, err := parseIntFromUrl(r, "id")
	if err != nil {
		http.Error(w, "invalid customer ID", http.StatusBadRequest)
		return
	}

	if err = db.DeleteCustomer(id); err != nil {
		http.Error(w, "deletion failed", http.StatusInternalServerError)
		return
	}

	ok(w)
}
