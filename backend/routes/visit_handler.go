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

func RecordVisitDetailHandler(w http.ResponseWriter, r *http.Request) {
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

	var visitDate *time.Time
	if visitDateStr == "" {
		visitDate = nil
	} else {
		parsedDate, err := time.Parse(db.DateFormat, visitDateStr)
		if err != nil {
			http.Error(w, "invalid date format", http.StatusBadRequest)
			return
		}
		visitDate = &parsedDate
	}

	visit, addVisitErr := db.AddVisit(customerId, visitDate, notes)
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

func VisitDetailsHandler(w http.ResponseWriter, r *http.Request) {
	beginStr := getParam(r, "begin")
	endStr := getParam(r, "end")

	var cvs []db.VisitDetail
	var err error

	// Return all visits when no time param is provided
	if beginStr == "" && endStr == "" {
		cvs, err = db.AllVisitDetails()
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		writeJson(w, cvs, http.StatusOK)
		return
	}

	// When at least one of time param is provided
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

	cvs, err = db.VisitDetailsBetween(begin, end)
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

	lastVisit, err := db.DeleteVisit(id)
	if err != nil {
		http.Error(w, "deletion failed", http.StatusInternalServerError)
		return
	}

	writeJson(w, lastVisit, http.StatusOK)
}

func DeleteLastVisitOfCustomerHandler(w http.ResponseWriter, r *http.Request) {
	customerId, err := parseIntFromUrl(r, "id")
	if err != nil {
		http.Error(w, "invalid customer id", http.StatusBadRequest)
	}

	lastVisit, err := db.DeleteLastVisitOfCustomer(customerId)
	if err != nil {
		http.Error(w, "deletion failed", http.StatusInternalServerError)
		return
	}

	writeJson(w, lastVisit, http.StatusOK)
}

func VisitsOfCustomerHandler(w http.ResponseWriter, r *http.Request) {
	customerId, err := parseIntFromUrl(r, "id")
	if err != nil {
		http.Error(w, "invalid visit id", http.StatusBadRequest)
	}

	cvs, err := db.VisitDetailsOfCustomer(customerId)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	writeJson(w, cvs, http.StatusOK)
}
