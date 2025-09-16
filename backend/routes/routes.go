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
		Handler: func(w http.ResponseWriter, r *http.Request) { w.Write([]byte("ok")) },
		Doc:     `Health check.`,
	},
	{
		Path:    "/customers",
		Method:  POST,
		Handler: AddCustomerHandler,
		Doc: `Add new customer. Expects JSON body with "uuid" (optional), "firstName", "lastName", 
		 "birthday" (optional), "country" (optional) and "notes" (optional). Return new customer 
		 struct.`,
	},
	{
		Path:    "/customers", // TODO
		Method:  GET,
		Handler: SearchCustomerHandler,
		Doc: `Search customer names by query parameter. Get all customers when no query 
		 parameter is provided.`,
		QueryParams: []QueryParam{
			{Name: "query", Description: "Query string for searching", Required: false},
			{Name: "last_visit_after", Description: "Customer must have last visit after this date", Required: false},
			{Name: "last_visit_before", Description: "Customer must have last visit before this date", Required: false},
		},
	},
	{
		Path:    "/customers/{id}",
		Method:  GET,
		Handler: GetCustomerHandler,
		Doc: `Get customer by ID. Response includes "id", "uuid", "firstName", "lastName", "birthday" 
		 "country", "lastVisit" and "notes".`,
	},
	{
		Path:    "/customers/{id}",
		Method:  PUT,
		Handler: UpdateCustomerHandler,
		Doc: `Update customer. Expects JSON body with "firstName", "lastName", "birthday", "country"
		 and "notes". 
		 IMPORTANT: omitted fields will be recorded as empty values. "uuid" cannot be changed.`,
	},
	{
		Path:    "/customers/{id}",
		Method:  DELETE,
		Handler: DeleteCustomerHandler,
		Doc:     `Delete a customer, set customer information in corresponding visits to null.`,
	},
	{
		Path:    "/customers/uuid/{uuid}",
		Method:  GET,
		Handler: GetCustomerByUuidHandler,
		Doc:     `Get customer by UUID.`,
	},
	{
		Path:    "/customers/{id}/visits",
		Method:  POST,
		Handler: RecordVisitDetailHandler,
		Doc: `Record a visit. Optionally accepts JSON body with "visitDate" (format: YYYY-MM-DD) and
		 "notes". Record the visit with today's date if visitDate is not provided. Returns visit id.`,
	},
	{
		Path:    "/customers/{id}/visits",
		Method:  GET,
		Handler: VisitsOfCustomerHandler,
		Doc: `Get all visits of a customer. Returns a list consists of data: "id", "customerId", 
		 "customerUuid", "customerFirstName", "customerLastName", "visitDate" and "notes".`,
	},
	{
		Path:    "/customers/{id}/visits",
		Method:  DELETE,
		Handler: DeleteLastVisitOfCustomerHandler,
		Doc:     `Delete the last visit of a customer. Return the new latest visit of that customer.`,
	},
	{
		Path:    "/visits",
		Method:  GET,
		Handler: VisitDetailsHandler,
		Doc: `Get visit details. Returns a list consists of data "visitId", "customerId",
		 "customerUuid", "customerFirstName", "customerLastName", "visitDate" and "notes". Optionally
		  filtered by date range.`,
		QueryParams: []QueryParam{
			{Name: "begin", Description: "Start date in YYYY-MM-DD format", Required: false},
			{Name: "end", Description: "End date in YYYY-MM-DD format", Required: false},
		},
	},
	{
		Path:    "/visits/{id}",
		Method:  PUT,
		Handler: UpdateCustomerHandler,
		Doc: `Update visit by visit id. Expect JSON body with "customerId", "visitDate" and "notes".
		 IMPORTANT: omitted fields will be recorded as empty values.`,
	},
	{
		Path:    "/visits/{id}",
		Method:  DELETE,
		Handler: DeleteVisitHandler,
		Doc: `Delete a visit and update that customer's last visit. Return the new latest visit of 
		 that customer.`,
	},
	{
		Path:    "/stats/customers",
		Method:  GET,
		Handler: CustomerStatsHandler,
		Doc:     `Statistic report for customers. Returns "totalCustomers" and "customersByCountry"`,
	},
	{
		Path:    "/stats/visits",
		Method:  GET,
		Handler: VisitStatsHandler,
		Doc: `Statistic report for visits within timespan. The timespan can be at most 1 year. 
		 Returns "totalVisits" and "visitsByDate"`,
		QueryParams: []QueryParam{
			{Name: "begin", Description: "Start date in YYYY-MM-DD format", Required: false},
			{Name: "end", Description: "End date in YYYY-MM-DD format", Required: false},
		},
	},
	{
		Path:    "/stats/export",
		Method:  GET,
		Handler: ExportCsvHandler,
		Doc:     `Export data into CSV format.`,
	},
}
