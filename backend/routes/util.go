package routes

import (
	"bufio"
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
	"strconv"
	"strings"
	"strohhalm-backend/db"
	"time"

	"github.com/go-chi/chi/v5"
)

const (
	GET    = http.MethodGet
	POST   = http.MethodPost
	PUT    = http.MethodPut
	DELETE = http.MethodDelete
)

func writeJson(w http.ResponseWriter, data any, status int) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)

	if err := json.NewEncoder(w).Encode(data); err != nil {
		http.Error(w, fmt.Sprintf("failed to encode JSON: %v", err), http.StatusInternalServerError)
		return
	}
}

func getParam(r *http.Request, param string) string {
	return r.URL.Query().Get(param)
}

func decodeBody(r *http.Request, data any) error {
	if err := json.NewDecoder(r.Body).Decode(data); err != nil {
		return fmt.Errorf("invalid JSON body: %w", err)
	}
	return nil
}

func ok(w http.ResponseWriter) {
	w.Write([]byte("ok"))
}

func parsePageParam(r *http.Request) (db.Page, error) {
	sizeStr := getParam(r, "size")
	pageStr := getParam(r, "page")

	var size, page int64
	var err error

	if sizeStr == "" {
		size = 10 // default
	} else {
		size, err = strconv.ParseInt(sizeStr, 10, 64)
		if err != nil {
			return db.Page{}, err
		}
	}

	if pageStr == "" {
		page = 1
	} else {
		page, err = strconv.ParseInt(pageStr, 10, 64)
		if err != nil {
			return db.Page{}, err
		}
	}

	return db.Page{
		Size: size,
		Page: page,
	}, nil
}

func parseIntFromUrl(r *http.Request, name string) (int64, error) {
	id, err := strconv.ParseInt(chi.URLParam(r, name), 10, 64)
	if err != nil {
		return 0, err
	}
	return id, nil
}

func prepareCustomerData(c *db.Customer) error {
	c.FirstName = strings.TrimSpace(c.FirstName)
	c.LastName = strings.TrimSpace(c.LastName)
	c.Notes = strings.TrimSpace(c.Notes)
	if c.FirstName == "" || c.LastName == "" {
		return errors.New("first and last name are required")
	}
	return nil
}

func parseDateWithDefault(dateStr string, def time.Time) (time.Time, error) {
	if dateStr == "" {
		return def, nil
	}
	return time.Parse(db.DateFormat, dateStr)
}

func writeCsvLineWithTrailingComma(w *bufio.Writer, row ...string) error {
	for _, str := range row {
		if strings.Contains(str, ",") {
			if _, err := w.WriteString("\"" + str + "\""); err != nil {
				return err
			}
		} else {
			if _, err := w.WriteString(str); err != nil {
				return err
			}
		}
		if err := w.WriteByte(','); err != nil {
			return err
		}
	}
	return nil
}
