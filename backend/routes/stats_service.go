package routes

import (
	"net/http"
	"strohhalm-backend/db"
)

func CustomerStatsHandler(w http.ResponseWriter, r *http.Request) {
	statistics, err := db.GetCustomerStats()
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	writeJson(w, statistics, http.StatusOK)
}
