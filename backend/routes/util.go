package routes

import (
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
	"strconv"
	"strings"
	"strohhalm-backend/db"

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
		return fmt.Errorf("invalid JSON: %w", err)
	}
	return nil
}

func ok(w http.ResponseWriter) {
	w.Write([]byte("ok"))
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
