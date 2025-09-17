package main

import (
	"fmt"
	"log"
	"net/http"
	"strohhalm-backend/cfg"
	"strohhalm-backend/db"
	"strohhalm-backend/middlewares"
	"strohhalm-backend/routes"

	"github.com/go-chi/chi/v5"
)

func main() {

	cfg.InitConfig()

	db.InitDatabase(cfg.GlobalConfig.Data)

	r := chi.NewRouter()

	middlewares.InitGlobalMiddlewares(r)

	routes.InitRoutes(r)

	addr := fmt.Sprintf("%s:%d", cfg.GlobalConfig.Server.Host, cfg.GlobalConfig.Server.Port)
	log.Printf("Server started on port %s\n", addr)
	http.ListenAndServe(addr, r)
}
