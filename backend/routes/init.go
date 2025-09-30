package routes

import (
	"fmt"
	"net/http"

	"github.com/go-chi/chi/v5"
)

func InitRoutes(r chi.Router) {
	// all routes are first defined in `something_handler.go` files
	// then registered in this `Routes` object defined in the file `routes.go`
	for _, route := range Routes {
		registerRoute(r, route)
	}
}

func registerRoute(r chi.Router, route Route) {
	switch route.Method {
	case http.MethodGet:
		r.Get(route.Path, route.Handler)
	case http.MethodPost:
		r.Post(route.Path, route.Handler)
	case http.MethodPut:
		r.Put(route.Path, route.Handler)
	case http.MethodDelete:
		r.Delete(route.Path, route.Handler)
	default:
		panic(fmt.Sprintf("Unsupported method: %s", route.Method))
	}
}
