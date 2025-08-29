package routes

import (
	"encoding/json"
	"fmt"
	"net/http"
)

const (
	GET    = http.MethodGet
	POST   = http.MethodPost
	PUT    = http.MethodPut
	DELETE = http.MethodDelete
)

func WriteJson(w http.ResponseWriter, data any, status int) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)

	if err := json.NewEncoder(w).Encode(data); err != nil {
		http.Error(w, fmt.Sprintf("failed to encode JSON: %v", err), http.StatusInternalServerError)
		return
	}
}

func GetParam(r *http.Request, param string) string {
	return r.URL.Query().Get(param)
}

func DecodeRequestBody(r *http.Request, data any) error {
	if err := json.NewDecoder(r.Body).Decode(data); err != nil {
		return fmt.Errorf("invalid JSON: %w", err)
	}
	return nil
}
