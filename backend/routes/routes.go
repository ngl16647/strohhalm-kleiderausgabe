package routes

import "net/http"

type Route struct {
	Path        string
	Method      string
	Handler     http.HandlerFunc
	Doc         string
	QueryParams []QueryParam
}

type QueryParam struct {
	Name        string
	Description string
	Required    bool
}

var Routes = []Route{
	{
		Path:    "/health",
		Method:  GET,
		Handler: func(w http.ResponseWriter, r *http.Request) { w.Write([]byte("OK")) },
		Doc:     `Health check`,
	},
	{
		Path:    "/customers",
		Method:  POST,
		Handler: AddCustomerHandler,
		Doc: `Add new customer. Expects JSON body with "uuid" (optional), "firstName", "lastName", 
		 "birthday" (optional), "country" (optional) "notes" (optional). Return new customer struct`,
	},
	{
		Path:    "/customers",
		Method:  GET,
		Handler: SearchCustomerHandler,
		Doc:     `Search customer names by query parameter. Get all customers when no query parameter is provided`,
		QueryParams: []QueryParam{
			{Name: "query", Description: "Query string for searching", Required: false},
		},
	},
	{
		Path:    "/customers/{id}",
		Method:  GET,
		Handler: GetCustomerHandler,
		Doc:     "Get customer by ID",
	},
	{
		Path:    "/customers/{id}",
		Method:  PUT,
		Handler: UpdateCustomerHandler,
		Doc: `Update customer. Expects JSON body with "firstName", "lastName", "birthday", "notes". 
		 IMPORTANT: omitted fields will be recorded as empty values`,
	},
	{
		Path:    "/visits/{customer_id}",
		Method:  POST,
		Handler: RecordCustomerVisitHandler,
		Doc:     `Record a visit now. Optionally accepts JSON body with a single field "notes". Returns visit id`,
	},
	{
		Path:    "/visits",
		Method:  GET,
		Handler: CustomerVisitsHandler,
		Doc:     `Get customer visits, optionally filtered by date range`,
		QueryParams: []QueryParam{
			{Name: "begin", Description: "Start date in YYYY-MM-DD format", Required: false},
			{Name: "end", Description: "End date in YYYY-MM-DD format", Required: false},
		},
	},
}
