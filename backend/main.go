package main

import (
	"fmt"
	"log"
	"net/http"
	"strohhalm-backend/cfg"
	"strohhalm-backend/db"
	"strohhalm-backend/middlewares"
	"strohhalm-backend/routes"
	"time"

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

	if !cfg.GlobalConfig.Api.UseApiKey {
		log.Println("WARNING: Server running without API key verification")
	}

	var err error
	if !cfg.GlobalConfig.Tls.UseTls {
		addr := Addr(cfg.GlobalConfig.Server.Host, cfg.GlobalConfig.Server.Port)
		log.Println("WARNING: Server running without TLS")
		log.Printf("Server started on port %s\n", addr)
		err = http.ListenAndServe(addr, r)
	} else if cfg.GlobalConfig.Tls.Autocert.UseAutocert { // autocert with Let's Encrypt
		addr := Addr(cfg.GlobalConfig.Server.Host, 443) // must serve backend on 443
		acManager, tlsCfg := cfg.GenerateTlsConfig(cfg.GlobalConfig)
		httpsServer := &http.Server{
			Addr:      addr,
			Handler:   r,
			TLSConfig: tlsCfg,
		}

		// listening for ACME challenges
		httpServer := cfg.HttpServer(acManager)
		go func() {
			log.Fatal(http.ListenAndServe(Addr(cfg.GlobalConfig.Server.Host, 80), httpServer))
		}()

		// check if certificates exist
		<-time.After(time.Second * 2)
		cfg.ValidateAutocert(acManager, cfg.GlobalConfig.Tls.Autocert.Domains)

		log.Printf("Server started on port %s with autocert\n", addr)
		err = httpsServer.ListenAndServeTLS("", "")
	} else { // manual TLS
		addr := Addr(cfg.GlobalConfig.Server.Host, cfg.GlobalConfig.Server.Port)
		log.Printf("Server started on port %s\n", addr)
		err = http.ListenAndServeTLS(
			addr,
			cfg.GlobalConfig.Tls.CertFile,
			cfg.GlobalConfig.Tls.KeyFile,
			r,
		)
	}

	if err != nil {
		log.Fatal(err)
	}
}

func Addr(host string, port int) string {
	return fmt.Sprintf("%s:%d", host, port)
}
