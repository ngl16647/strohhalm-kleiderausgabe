package main

import (
	"log"
	"net/http"
	"strohalm-backend/db"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
)

func main() {
	db.InitDatabase("./data.db")
	r := chi.NewRouter()
	r.Use(middleware.Logger)

	// CRUD routes
	// r.Get("/items", listItems)
	// r.Post("/items", createItem)
	// r.Put("/items/{id}", updateItem)

	log.Println("Server started")
	http.ListenAndServe(":8080", r)
}
