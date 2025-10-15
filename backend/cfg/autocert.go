package cfg

import (
	"crypto/tls"
	"log"

	"golang.org/x/crypto/acme/autocert"
)

func GenerateTlsConfig(cfg *Config) *tls.Config {
	m := &autocert.Manager{
		Prompt:     autocert.AcceptTOS,
		HostPolicy: autocert.HostWhitelist(cfg.Tls.Autocert.Domains...),
		Cache:      autocert.DirCache(cfg.Tls.Autocert.Cache),
		Email:      cfg.Tls.Autocert.Email,
	}
	validateAutocert(m, cfg.Tls.Autocert.Domains)
	return &tls.Config{
		GetCertificate: m.GetCertificate,
	}
}

func validateAutocert(m *autocert.Manager, domains []string) {
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
