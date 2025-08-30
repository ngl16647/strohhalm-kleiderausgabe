package db

import (
	"errors"

	"github.com/jmoiron/sqlx"
	_ "github.com/mattn/go-sqlite3"
)

var DB *sqlx.DB

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

	DB, err = sqlx.Open("sqlite3", path)
	initPanic(err, "Failed to open database")

	_, err = DB.Exec(CustomerInitStr)
	initPanic(err, "Failed to create table `customers`")

	_, err = DB.Exec(VisitsInitStr)
	initPanic(err, "Failed to create table `visits`")

	for _, index := range Indices {
		sqlx.MustExec(DB, index)
	}
}
