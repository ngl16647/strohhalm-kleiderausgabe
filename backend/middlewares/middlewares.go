package middlewares

import (
	"net/http"
	"strings"
	"strohhalm-backend/cfg"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
)

func InitGlobalMiddlewares(r chi.Router) {
	r.Use(middleware.Logger)
	if cfg.GlobalConfig.Api.UseKeys {
		r.Use(APIKeyAuth(cfg.GlobalConfig.Api.ApiKey))
	}
}

func APIKeyAuth(validKey string) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			authHeader := r.Header.Get("Authorization")

			// Expect "Bearer <key>"
			const prefix = "Bearer "
			if !strings.HasPrefix(authHeader, prefix) {
				http.Error(w, "missing or invalid API key", http.StatusUnauthorized)
				return
			}

			apiKey := strings.TrimPrefix(authHeader, prefix)
			if apiKey != validKey {
				http.Error(w, "unauthorized", http.StatusUnauthorized)
				return
			}

			next.ServeHTTP(w, r)
		})
	}
}

func AdminKeyAuth(validKey string) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			authHeader := r.Header.Get("Admin-Authorization")

			// Expect "Bearer <key>"
			const prefix = "Bearer "
			if !strings.HasPrefix(authHeader, prefix) {
				http.Error(w, "missing or invalid admin key", http.StatusUnauthorized)
				return
			}

			apiKey := strings.TrimPrefix(authHeader, prefix)
			if apiKey != validKey {
				http.Error(w, "unauthorized", http.StatusUnauthorized)
				return
			}

			next.ServeHTTP(w, r)
		})
	}
}
