package main

import (
	"log"
	"net/http"
	"strohalm-backend/db"
	"strohalm-backend/routes"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
)

func main() {
	db.InitDatabase("./data.db")

	r := chi.NewRouter()
	r.Use(middleware.Logger)

	routes.InitRoutes(r)

	log.Println("Server started")
	http.ListenAndServe(":8080", r)
}
