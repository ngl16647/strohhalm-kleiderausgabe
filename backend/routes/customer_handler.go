package routes

import (
	"errors"
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
		if errors.Is(err, db.ErrNotFound) {
			http.Error(w, "customer not found", http.StatusNotFound)
			return
		}
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	writeJson(w, c, http.StatusOK)
}

func GetCustomerByUuidHandler(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "uuid")

	c, err := db.CustomerByUuid(id)
	if err != nil {
		if errors.Is(err, db.ErrNotFound) {
			http.Error(w, "customer not found", http.StatusNotFound)
			return
		}
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	writeJson(w, c, http.StatusOK)
}

func SearchCustomerHandler(w http.ResponseWriter, r *http.Request) {
	query := strings.TrimSpace(getParam(r, "query"))
	beginStr := strings.TrimSpace(getParam(r, "last_visit_after"))
	endStr := strings.TrimSpace(getParam(r, "last_visit_before"))
	page, err := parsePageParam(r)
	if err != nil {
		http.Error(w, "invalid page params", http.StatusBadRequest)
		return
	}

	var cs db.PageResult[db.Customer]
	var queryErr error

	if beginStr == "" && endStr == "" {
		// no date constraint
		cs, queryErr = db.SearchCustomerPaginated(query, page)
	} else {
		// have query and date requirement
		begin, err := parseDateWithDefault(beginStr, db.MinDate)
		if err != nil {
			http.Error(w, "invalid begin date", http.StatusBadRequest)
			return
		}

		end, err := parseDateWithDefault(endStr, db.MaxDate)
		if err != nil {
			http.Error(w, "invalid end date", http.StatusBadRequest)
			return
		}

		cs, queryErr = db.SearchCustomerWithinDatesPaginated(query, begin, end, page)
	}
	if queryErr != nil {
		http.Error(w, queryErr.Error(), http.StatusInternalServerError)
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
