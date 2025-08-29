package routes

import (
	"net/http"
	"strohhalm-backend/db"
	"time"
)

func CustomerVisitsHandler(w http.ResponseWriter, r *http.Request) {
	beginStr := GetParam(r, "begin")
	endStr := GetParam(r, "end")

	var cvs []db.CustomerVisit
	var err error

	switch {
	case beginStr == "" && endStr == "":
		cvs, err = db.AllCustomerVisits()
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

	case beginStr == "" || endStr == "":
		http.Error(w, "both begin and end must be provided", http.StatusBadRequest)
		return

	default:
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
	}

	WriteJson(w, cvs, http.StatusOK)
}
