package main

import (
	"flag"
	"log"
	"net/http"
	"strohhalm-backend/db"
	"strohhalm-backend/routes"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
)

func main() {
	// print docs if --docs flag is on
	docsFlag := flag.Bool("docs", false, "Print API documentation")
	flag.Parse()
	if *docsFlag {
		printAPIDocs()
		return
	}

	db.InitDatabase("./data.db")

	r := chi.NewRouter()
	r.Use(middleware.Logger)

	routes.InitRoutes(r)

	log.Println("Server started on port 8080")
	http.ListenAndServe(":8080", r)
}
