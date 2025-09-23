package db

import (
	"github.com/jmoiron/sqlx"
	_ "github.com/mattn/go-sqlite3"
)

var db *sqlx.DB

func InitDatabase(path string) {

	db = sqlx.MustOpen("sqlite3", path)

	db.MustExec(CustomerInitStr)

	db.MustExec(VisitsInitStr)

	for _, index := range Indices {
		sqlx.MustExec(db, index)
	}
}

// Wrap operations inside a single transaction.
// When you have multiple database operations inside a same functionality,
// use withTx to ensure atomicity
func withTx[T any](fn func(*sqlx.Tx) (T, error)) (T, error) {
	var nullData T

	tx, err := db.Beginx()
	if err != nil {
		return nullData, ErrNoDbConnection
	}
	defer tx.Rollback() // when errors occur, rollback database

	result, err := fn(tx)
	if err != nil {
		return nullData, err
	}

	if err := tx.Commit(); err != nil {
		return nullData, err
	}

	return result, nil
}

// Wrap operations inside a single transaction.
// When you have multiple database operations inside a same functionality,
// use withTx to ensure atomicity
func withTxExec(fn func(*sqlx.Tx) error) error {
	tx, err := db.Beginx()
	if err != nil {
		return ErrNoDbConnection
	}
	defer tx.Rollback()

	if err := fn(tx); err != nil {
		return err
	}

	if err := tx.Commit(); err != nil {
		return err
	}

	return nil
}
