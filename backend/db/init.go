package db

import (
	"database/sql"
	"errors"

	_ "github.com/mattn/go-sqlite3"
)

var DB *sql.DB

var (
	ErrNotFound = errors.New("not found")
)

func initPanic(err error, message string) {
	if err != nil {
		panic(message + ": " + err.Error())
	}
}

func InitDatabase(path string) {
	var err error

	DB, err = sql.Open("sqlite3", path)
	initPanic(err, "Failed to open database")

	err = DB.Ping()
	initPanic(err, "Failed to ping database")

	_, err = DB.Exec(CustomerInitStr)
	initPanic(err, "Failed to create table `customers`")

	_, err = DB.Exec(VisitsInitStr)
	initPanic(err, "Failed to create table `visits`")
}
