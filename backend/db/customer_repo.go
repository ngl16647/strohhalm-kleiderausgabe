package db

import (
	"database/sql"
	"errors"
	"fmt"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/jmoiron/sqlx"
)

func AddCustomer(c Customer) (Customer, error) {
	if c.Uuid == "" {
		c.Uuid = uuid.NewString()
	}
	res, err := db.NamedExec(
		`INSERT INTO customers (uuid, first_name, last_name, birthday, country, notes) 
			VALUES (:uuid, :first_name, :last_name, :birthday, :country, :notes)`,
		&c,
	)
	if err != nil {
		return Customer{}, fmt.Errorf("failed to add customer %s %s: %w", c.FirstName, c.LastName, err)
	}
	id, err := res.LastInsertId()
	if err != nil {
		return Customer{}, fmt.Errorf("unable to get user id")
	}
	c.Id = id
	return c, nil
}

func UpdateCustomer(customerId int64, newC Customer) error {
	newC.Id = customerId
	// uuid cannot be updated
	res, err := db.NamedExec(`
        UPDATE customers
        SET first_name = :first_name,
			last_name = :last_name,
			birthday = :birthday,
			country = :country,
			notes = :notes
        WHERE id = :id`,
		&newC,
	)
	if err != nil {
		return fmt.Errorf("update customer %d: %w", customerId, err)
	}

	rows, err := res.RowsAffected()
	if err != nil {
		return fmt.Errorf("check update result for customer %d: %w", customerId, err)
	}

	if rows == 0 {
		return errors.New("custome not found")
	}

	return nil
}

func AllCustomers() ([]Customer, error) {
	cs := []Customer{}
	err := db.Select(&cs, `SELECT * FROM customers`)
	if err != nil {
		return nil, fmt.Errorf("get all customers: %w", err)
	}
	return cs, nil
}

func AllCustomersPaginated(page Page) (PageResult[Customer], error) {
	return withTx(func(tx *sqlx.Tx) (PageResult[Customer], error) {
		cs := []Customer{}
		limit, offset := page.LimitOffset()

		var total int64
		err := tx.Get(&total, `SELECT COUNT(*) FROM customers`)
		if err != nil {
			return PageResult[Customer]{}, fmt.Errorf("get number of customers: %w", err)
		}

		err = tx.Select(&cs, `
			SELECT * FROM customers
				ORDER BY first_name
				LIMIT $1 OFFSET $2`,
			limit, offset,
		)
		if err != nil {
			return PageResult[Customer]{}, fmt.Errorf("get all customers: %w", err)
		}

		return PageResultOf(cs, page, total), nil
	})
}

func CustomerById(id int64) (Customer, error) {
	var c Customer
	err := db.Get(&c, "SELECT * FROM customers WHERE id = $1", id)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return c, ErrNotFound
		}
		return c, fmt.Errorf("get customer by id %d: %w", id, err)
	}

	return c, nil
}

func customerByIdTx(tx *sqlx.Tx, id int64) (Customer, error) {
	var c Customer
	err := tx.Get(&c, "SELECT * FROM customers WHERE id = $1", id)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return c, ErrNotFound
		}
		return c, fmt.Errorf("get customer by id %d: %w", id, err)
	}

	return c, nil
}

func CustomerByUuid(uuid string) (Customer, error) {
	var c Customer
	err := db.Get(&c, "SELECT * FROM customers WHERE uuid = $1", uuid)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return c, ErrNotFound
		}
		return c, fmt.Errorf("get customer by uuid %s: %w", uuid, err)
	}

	return c, nil
}

func SearchCustomerPaginated(query string, page Page) (PageResult[Customer], error) {
	if query == "" {
		return AllCustomersPaginated(page)
	}

	cs := []Customer{}
	limit, offset := page.LimitOffset()
	pattern := "%" + strings.ToLower(query) + "%"

	var total int64
	err := db.Get(&total, `
		SELECT COUNT(*) FROM customers
			WHERE LOWER(first_name || ' ' || last_name) LIKE $1`,
		pattern,
	)
	if err != nil {
		return PageResult[Customer]{}, fmt.Errorf("get total searched customer: %w", err)
	}

	err = db.Select(&cs, `
		SELECT * FROM customers
			WHERE LOWER(first_name || ' ' || last_name) LIKE $1
			ORDER BY first_name
			LIMIT $2 OFFSET $3`,
		pattern, limit, offset,
	)
	if err != nil {
		return PageResult[Customer]{}, fmt.Errorf("search customer: %w", err)
	}
	return PageResultOf(cs, page, total), nil
}

func SearchCustomerWithinDatesPaginated(
	query string,
	begin time.Time,
	end time.Time,
	page Page,
) (PageResult[Customer], error) {
	return withTx(func(tx *sqlx.Tx) (PageResult[Customer], error) {
		cs := []Customer{}
		limit, offset := page.LimitOffset()

		beginStr := begin.Format(DateFormat)
		endStr := end.Format(DateFormat)

		var total int64
		err := tx.Get(&total, `
			SELECT COUNT(*) FROM customers
				WHERE LOWER(first_name || ' ' || last_name) LIKE $1
				  AND last_visit IS NOT NULL
				  AND last_visit BETWEEN $2 AND $3`,
			"%"+strings.ToLower(query)+"%",
			beginStr,
			endStr,
		)
		if err != nil {
			return PageResult[Customer]{}, err
		}

		err = tx.Select(&cs, `
			SELECT * FROM customers
				WHERE LOWER(first_name || ' ' || last_name) LIKE $1
				AND last_visit IS NOT NULL
				AND last_visit BETWEEN $2 AND $3
			ORDER BY first_name
			LIMIT $4 OFFSET $5`,
			"%"+strings.ToLower(query)+"%",
			beginStr,
			endStr,
			limit,
			offset,
		)
		if err != nil {
			return PageResult[Customer]{}, fmt.Errorf("search customer: %w", err)
		}

		return PageResultOf(cs, page, total), nil
	})
}

func setCustomerLastVisitTx(tx *sqlx.Tx, customerId int64, newVisit Visit) error {
	if _, err := tx.Exec(`
		UPDATE customers
		SET last_visit_id = $1,
			last_visit = $2
		WHERE id = $3
		AND (last_visit IS NULL OR last_visit < $2)`,
		newVisit.Id, newVisit.VisitDate, customerId,
	); err != nil {
		return fmt.Errorf("update last visit for customer %d: %w", customerId, err)
	}
	return nil
}

// Find the latest visit in the `visits` table
// and update that customer's last_visit in `customers` table
func updateCustomerLastVisitTx(tx *sqlx.Tx, customerId int64) (*Visit, error) {
	lastVisit, err := getLatestVisitByCustomerTx(tx, customerId)
	if err != nil {
		return lastVisit, fmt.Errorf("find last visit for customer %d: %w", customerId, err)
	}

	var visitId *int64
	var visitDate *string
	if lastVisit == nil {
		visitId = nil
		visitDate = nil
	} else {
		visitId = &lastVisit.Id
		visitDate = &lastVisit.VisitDate
	}

	if _, err := tx.Exec(`
		UPDATE customers
		SET last_visit_id = $1,
			last_visit = $2 
		WHERE id = $3`,
		visitId, visitDate, customerId); err != nil {
		return lastVisit, fmt.Errorf("update last visit for customer %d: %w", customerId, err)
	}
	return lastVisit, nil
}

func DeleteCustomer(customerId int64) error {
	_, err := db.Exec("DELETE FROM customers WHERE id = ?", customerId)
	if err != nil {
		return fmt.Errorf("delete customer: %w", err)
	}
	return nil
}
