package cfg

import (
	"crypto/tls"
	"log"
	"net/http"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
	"golang.org/x/crypto/acme/autocert"
)

func GenerateTlsConfig(cfg *Config) (*autocert.Manager, *tls.Config) {
	m := &autocert.Manager{
		Prompt:     autocert.AcceptTOS,
		HostPolicy: autocert.HostWhitelist(cfg.Tls.Autocert.Domains...),
		Cache:      autocert.DirCache(cfg.Tls.Autocert.Cache),
		Email:      cfg.Tls.Autocert.Email,
	}
	return m, &tls.Config{
		GetCertificate: m.GetCertificate,
	}
}

func HttpServer(m *autocert.Manager) *chi.Mux {
	r := chi.NewRouter()
	r.Use(middleware.Logger)
	r.Handle("/*", http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		m.HTTPHandler(nil).ServeHTTP(w, r)
	}))
	return r
}

func ValidateAutocert(m *autocert.Manager, domains []string) {
	for _, domain := range domains {
		_, err := m.GetCertificate(&tls.ClientHelloInfo{
			ServerName: domain,
		})
		if err != nil {
			log.Fatalf("autocert failed for domain %s: %v", domain, err)
		} else {
			log.Printf("autocert valid for domain %s", domain)
		}
	}
}
