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

	runServer(r)

}

func runServer(r chi.Router) {
	addr := fmt.Sprintf("%s:%d", cfg.GlobalConfig.Server.Host, cfg.GlobalConfig.Server.Port)

	if !cfg.GlobalConfig.Api.UseApiKey {
		log.Println("WARNING: Server running without API key verification")
	}

	var err error
	if !cfg.GlobalConfig.Tls.UseTls {
		log.Println("WARNING: Server running without TLS")
		log.Printf("Server started on port %s\n", addr)
		err = http.ListenAndServe(addr, r)
	} else if cfg.GlobalConfig.Tls.Autocert.UseAutocert { // autocert with Let's Encrypt
		httpsServer := &http.Server{
			Addr:      addr,
			Handler:   r,
			TLSConfig: cfg.GenerateTlsConfig(cfg.GlobalConfig),
		}
		log.Printf("Server started on port %s\n", addr)
		err = httpsServer.ListenAndServeTLS("", "")
	} else { // manual TLS
		log.Printf("Server started on port %s\n", addr)
		err = http.ListenAndServeTLS(addr, cfg.GlobalConfig.Tls.CertFile, cfg.GlobalConfig.Tls.KeyFile, r)
	}

	if err != nil {
		log.Fatal(err)
	}
}
