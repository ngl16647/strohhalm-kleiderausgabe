package routes

import (
	"encoding/json"
	"io"
	"net/http"
	"strconv"
	"strings"
	"strohhalm-backend/db"
	"time"

	"github.com/go-chi/chi/v5"
)

func RecordCustomerVisitHandler(w http.ResponseWriter, r *http.Request) {
	customerId, err := strconv.ParseInt(chi.URLParam(r, "id"), 10, 64)
	if err != nil {
		http.Error(w, "invalid customer ID", http.StatusBadRequest)
		return
	}
	var req map[string]string
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil && err != io.EOF {
		http.Error(w, "Invalid note", http.StatusBadRequest)
		return
	}
	visitDateStr := req["visitDate"]
	notes := req["notes"]

	var visit db.Visit
	var addVisitErr error
	if visitDateStr == "" {
		visit, addVisitErr = db.AddVisitNow(customerId, notes)
	} else {
		visitDate, err := time.Parse(db.DateFormat, visitDateStr)
		if err != nil {
			http.Error(w, "invalid date format", http.StatusBadRequest)
			return
		}
		visit, addVisitErr = db.AddVisitAt(customerId, visitDate, notes)
	}

	if addVisitErr != nil {
		// A customer cannot visit twice within a day
		if strings.Contains(addVisitErr.Error(), "UNIQUE constraint failed") {
			http.Error(w, "customer already has a visit on this date", http.StatusConflict)
			return
		}
		// Deleted customer cannot have new visits
		if strings.Contains(addVisitErr.Error(), "FOREIGN KEY constraint failed") {
			http.Error(w, "customer deleted or does not exist", http.StatusBadRequest)
			return
		}
		http.Error(w, addVisitErr.Error(), http.StatusInternalServerError)
		return
	}

	writeJson(w, visit, http.StatusOK)
}

func CustomerVisitsHandler(w http.ResponseWriter, r *http.Request) {
	beginStr := getParam(r, "begin")
	endStr := getParam(r, "end")

	var cvs []db.CustomerVisit
	var err error

	// Return all visits when no time param is provided
	if beginStr == "" && endStr == "" {
		cvs, err = db.AllCustomerVisits()
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		writeJson(w, cvs, http.StatusOK)
		return
	}

	// When at least one of time param is provided
	if beginStr == "" {
		beginStr = "0000-01-01"
	}

	if endStr == "" {
		endStr = "9999-12-31"
	}

	begin, err := time.Parse(db.DateFormat, beginStr)
	if err != nil {
		http.Error(w, "invalid begin date", http.StatusBadRequest)
		return
	}

	end, err := time.Parse(db.DateFormat, endStr)
	if err != nil {
		http.Error(w, "invalid end date", http.StatusBadRequest)
		return
	}

	cvs, err = db.CustomerVisitsBetween(begin, end)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	writeJson(w, cvs, http.StatusOK)
}

func UpdateVisitHandler(w http.ResponseWriter, r *http.Request) {
	id, err := parseIntFromUrl(r, "id")
	if err != nil {
		http.Error(w, "invalid visit id", http.StatusBadRequest)
		return
	}

	var newV db.Visit
	if err = decodeBody(r, newV); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	if err = db.UpdateVisit(id, newV); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	ok(w)
}

func DeleteVisitHandler(w http.ResponseWriter, r *http.Request) {
	id, err := parseIntFromUrl(r, "id")
	if err != nil {
		http.Error(w, "invalid visit id", http.StatusBadRequest)
	}

	if err = db.DeleteVisit(id); err != nil {
		http.Error(w, "deletion failed", http.StatusInternalServerError)
		return
	}

	ok(w)
}

func VisitsOfCustomerHandler(w http.ResponseWriter, r *http.Request) {
	customerId, err := parseIntFromUrl(r, "id")
	if err != nil {
		http.Error(w, "invalid visit id", http.StatusBadRequest)
	}

	cvs, err := db.VisitsOfCustomer(customerId)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	writeJson(w, cvs, http.StatusOK)
}
