package routes

import "net/http"

type Route struct {
	Path    string
	Method  string
	Handler http.HandlerFunc
	Doc     string
}

var Routes = []Route{
	{
		Path:    "/health",
		Method:  http.MethodGet,
		Handler: func(w http.ResponseWriter, r *http.Request) { w.Write([]byte("OK")) },
		Doc:     "Health check",
	},
}
