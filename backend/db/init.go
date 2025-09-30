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
// When you have multiple database operations inside the same functionality,
// and you need to return something from database afterwards,
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
// When you have multiple database operations inside the same functionality,
// and you don't need to return anything from database,
// use withTxExec to ensure atomicity
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
