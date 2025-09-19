package routes

import (
	"fmt"
	"net/http"
	"strings"
	"strohhalm-backend/db"
	"time"
)

func CustomerStatsHandler(w http.ResponseWriter, r *http.Request) {
	statistics, err := db.GetCustomerStats()
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	writeJson(w, statistics, http.StatusOK)
}

func VisitStatsHandler(w http.ResponseWriter, r *http.Request) {
	fromStr := getParam(r, "begin")
	toStr := getParam(r, "end")

	from, err := parseDateWithDefault(fromStr, time.Now().AddDate(-1, 0, 0))
	if err != nil {
		http.Error(w, "invalid begin date", http.StatusBadRequest)
		return
	}

	to, err := parseDateWithDefault(toStr, time.Now())
	if err != nil {
		http.Error(w, "invalid end date", http.StatusBadRequest)
		return
	}

	// check if start and end date are at most 1 year apart
	oneYearToFrom := from.AddDate(1, 0, 1)
	if to.After(oneYearToFrom) {
		http.Error(w, "date range must be within 1 year", http.StatusBadRequest)
	}

	statistics, err := db.GetVisitStats(from, to)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	writeJson(w, statistics, http.StatusOK)
}

func ExportHandler(w http.ResponseWriter, r *http.Request) {
	output, err := db.ExportJson()
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
	}

	writeJson(w, output, http.StatusOK)
}

func ExportCsvHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "text/csv")
	w.Header().Set("Content-Disposition", "attachment; filename=\"customers_visits.csv\"")

	data, err := db.ExportJson()
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
	}

	w.Write([]byte("id,Vorname,Nachname,Geburtstag,Land,Sonstiges,Besuche\n"))

	for _, c := range data {
		// use comma for separating visits to make the client happy
		line := csvLine(
			fmt.Sprint(c.Id),
			c.FirstName,
			c.LastName,
			c.Birthday,
			c.Country,
			c.Notes,
		) + "," + strings.Join(c.Visits, ",") + "\n"

		_, err := w.Write([]byte(line))
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
	}
}

func ImportCsvHandler(w http.ResponseWriter, r *http.Request) {
	if err := r.ParseMultipartForm(10 << 20); err != nil {
		http.Error(w, "failed to parse form: "+err.Error(), http.StatusBadRequest)
		return
	}

	file, _, err := r.FormFile("file")
	if err != nil {
		http.Error(w, "failed to read file: "+err.Error(), http.StatusBadRequest)
		return
	}
	defer file.Close()

	cs, err := db.ParseCSV(file)
	if err != nil {
		http.Error(w, "failed to parse CSV: "+err.Error(), http.StatusBadRequest)
		return
	}

	db.ImportJson(cs)

	ok(w)
}
