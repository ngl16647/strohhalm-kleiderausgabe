package routes

import (
	"fmt"
	"net/http"

	"github.com/go-chi/chi/v5"
)

func registerRouter(r *chi.Mux, route Route) {
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
