package tests

import (
	"bytes"
	"encoding/json"
	"io"
	"net/http/httptest"
	"os"
	"strohhalm-backend/db"
	"strohhalm-backend/routes"
	"testing"

	"github.com/go-chi/chi/v5"
)

var testRouter = chi.NewRouter()

func TestMain(m *testing.M) {
	db.InitDatabase(":memory:")
	routes.InitRoutes(testRouter)

	addCustomers()
	addVisits()

	exitVal := m.Run()
	os.Exit(exitVal)
}

func addCustomers() {
	call("/customers", "POST", map[string]string{
		"firstName": "Changable",
		"lastName":  "Customer",
		"country":   "My House",
		"birthday":  "1998-03-30",
	})
	call("/customers", "POST", map[string]string{
		"firstName": "Bing",
		"lastName":  "Pang",
		"birthday":  "1980-09-10",
		"notes":     "very handsome",
	})
	call("/customers", "POST", map[string]string{
		"firstName": "Moo",
		"lastName":  "Quack",
		"country":   "Heaven",
	})
}

func addVisits() {
	call("/customers/1/visits", "POST", map[string]string{
		"visitDate": "2025-08-23",
	})
}

func TestChangeCustomer(t *testing.T) {
	var rr *httptest.ResponseRecorder

	rr = call("/customers", "GET", nil)
	logResponse(t, rr)
}

func call(
	path string,
	method string,
	payload any,
) *httptest.ResponseRecorder {
	var body io.Reader
	if payload != nil {
		b, err := json.Marshal(payload)
		if err != nil {
			panic("failed to parse payload")
		}

		body = bytes.NewReader(b)
	}

	req := httptest.NewRequest(method, path, body)

	rr := httptest.NewRecorder()
	testRouter.ServeHTTP(rr, req)

	return rr
}

func logResponse(t *testing.T, rr *httptest.ResponseRecorder) {
	var pretty bytes.Buffer
	body := rr.Body.Bytes()

	if err := json.Indent(&pretty, body, "", "  "); err != nil {
		t.Logf("Response (not JSON): %s", string(body))
		return
	}
	t.Logf("Response JSON:\n%s", pretty.String())
}
