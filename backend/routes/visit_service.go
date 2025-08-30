package routes

import (
	"encoding/json"
	"io"
	"net/http"
	"strconv"
	"strohhalm-backend/db"
	"time"

	"github.com/go-chi/chi/v5"
)

func RecordCustomerVisitHandler(w http.ResponseWriter, r *http.Request) {
	customerId, err := strconv.ParseInt(chi.URLParam(r, "customer_id"), 10, 64)
	if err != nil {
		http.Error(w, "Invalid customer ID", http.StatusBadRequest)
		return
	}
	var req map[string]string
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil && err != io.EOF {
		http.Error(w, "Invalid note", http.StatusBadRequest)
		return
	}
	note := req["notes"]

	visit, err := db.AddVisitNow(customerId, note)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	WriteJson(w, visit, http.StatusOK)
}

func CustomerVisitsHandler(w http.ResponseWriter, r *http.Request) {
	beginStr := GetParam(r, "begin")
	endStr := GetParam(r, "end")

	var cvs []db.CustomerVisit
	var err error

	// Return all visits when no time param is provided
	if beginStr == "" && endStr == "" {
		cvs, err = db.AllCustomerVisits()
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		WriteJson(w, cvs, http.StatusOK)
	}

	// When at least one of time param is provided
	if beginStr == "" {
		beginStr = "0000-01-01"
	}

	if endStr == "" {
		endStr = "9000-01-01"
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

	WriteJson(w, cvs, http.StatusOK)
}
