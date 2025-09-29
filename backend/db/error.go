package db

import "errors"

var (
	ErrNotFound       = errors.New("data not found")
	ErrInvalidFormat  = errors.New("invalid data format")
	ErrNoDbConnection = errors.New("DB connection lost")
)
