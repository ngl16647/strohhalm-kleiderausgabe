package db

import (
	"encoding/csv"
	"fmt"
	"io"
	"log"
	"slices"
	"time"

	"github.com/google/uuid"
)

type CustomerJsonRow struct {
	Uuid      string   `json:"uuid"`
	FirstName string   `json:"firstname"`
	LastName  string   `json:"lastname"`
	Birthday  string   `json:"birthday"`
	Country   string   `json:"country"`
	Notes     string   `json:"notes"`
	Visits    []string `json:"visits"`
}

func ExportJson() ([]CustomerJsonRow, error) {
	rows, err := db.Query(`
        SELECT c.uuid, c.first_name, c.last_name, c.birthday, c.country, c.notes, v.visit_date
        FROM customers c
        LEFT JOIN visits v ON v.customer_id = c.id
        ORDER BY c.id, v.visit_date
    `)
	if err != nil {
		return nil, fmt.Errorf("export json: %w", err)
	}
	defer rows.Close()

	var result []CustomerJsonRow
	var current *CustomerJsonRow

	for rows.Next() {
		var (
			uuid     string
			first    string
			last     string
			birthday string
			country  string
			notes    string
			visit    *string
		)

		err := rows.Scan(&uuid, &first, &last, &birthday, &country, &notes, &visit)
		if err != nil {
			return nil, err
		}

		// If new customer, append to result
		if current == nil || current.Uuid != uuid {
			current = &CustomerJsonRow{
				Uuid:      uuid,
				FirstName: first,
				LastName:  last,
				Birthday:  birthday,
				Country:   country,
				Notes:     notes,
				Visits:    []string{},
			}
			result = append(result, *current)
			current = &result[len(result)-1]
		}

		// Add visit if not NULL
		if visit != nil {
			current.Visits = append(current.Visits, *visit)
		}
	}
	return result, nil
}

func ImportJson(data []CustomerJsonRow) error {
	tx, err := db.Beginx()
	if err != nil {
		return ErrNoDbConnection
	}
	defer tx.Rollback()

	// -- prepare insert statements --
	stmtCustomer, err := tx.Prepare(`
        INSERT INTO customers (uuid, first_name, last_name, birthday, country, notes)
        VALUES (?, ?, ?, ?, ?, ?)
        RETURNING id
    `)
	if err != nil {
		return err
	}
	defer stmtCustomer.Close()

	stmtSetLastVisit, err := tx.Prepare(`
		UPDATE customers
		SET last_visit_id = ?, last_visit = ?
		WHERE id = ?
	`)
	if err != nil {
		return err
	}
	defer stmtSetLastVisit.Close()

	stmtVisit, err := tx.Prepare(`
        INSERT INTO visits (customer_id, visit_date, notes)
        VALUES (?, ?, ?)
		RETURNING id
    `)
	if err != nil {
		return err
	}
	defer stmtVisit.Close()

	// -- importing --
	for i := range data {
		row := &data[i]

		// generate new UUID if necessary
		if row.Uuid == "" {
			row.Uuid = uuid.NewString()
		}

		// check birthday format
		_, err := time.Parse(DateFormat, row.Birthday)
		if err != nil {
			log.Printf("WARNING: Invalid birthday for %s %s: %s\n",
				row.FirstName, row.LastName, row.Birthday)
			row.Birthday = ""
		}

		// import customer
		var customerID int64
		err = stmtCustomer.QueryRow(
			row.Uuid,
			row.FirstName,
			row.LastName,
			row.Birthday,
			row.Country,
			row.Notes,
		).Scan(&customerID)
		if err != nil {
			log.Printf("WARNING: Unable to import customer %s %s: %s\n",
				row.FirstName, row.LastName, err.Error())
		}

		// import that customer's visits
		var lastVisit string = ""
		var lastVisitId int64 = 0
		for _, visit := range row.Visits {
			if visit == "" {
				continue
			}

			_, err := time.Parse(DateFormat, visit)
			if err != nil {
				log.Printf("WARNING: Invalid visit date for %s %s: %s\n",
					row.FirstName, row.LastName, visit)
				continue
			}

			// insert visit
			var visitId int64
			err = stmtVisit.QueryRow(customerID, visit, "").Scan(&visitId)
			if err != nil {
				log.Printf("WARNING: Unable to import visit for %s %s: %s\n",
					row.FirstName, row.LastName, err.Error())
			}

			if visit > lastVisit {
				lastVisit = visit
				lastVisitId = visitId
			}
		}

		// update last visit
		if lastVisit != "" {
			_, err = stmtSetLastVisit.Exec(lastVisitId, lastVisit, customerID)
			if err != nil {
				log.Printf("WARNING: Unable to update last visit for %s %s",
					row.FirstName, row.LastName)
			}
		}

		log.Printf("import completed for customer: %s %s", row.FirstName, row.LastName)
	}
	return tx.Commit()
}

func ParseCSV(r io.Reader) ([]CustomerJsonRow, error) {
	reader := csv.NewReader(r)
	reader.FieldsPerRecord = -1 // allows different numbers of field each line

	// read header
	header, err := reader.Read()
	if err != nil {
		return nil, fmt.Errorf("reading header: %w", err)
	}

	// check if headers are valid
	// map header and column
	colIndex, err := mapHeader(header)
	if err != nil {
		return nil, err
	}

	// check if there is UUID
	_, csvContainsUuid := colIndex["UUID"]

	var cs []CustomerJsonRow
	for {
		record, err := reader.Read()
		if err != nil {
			if err == io.EOF {
				break
			} else {
				return nil, fmt.Errorf("reading row: %w", ErrInvalidFormat)
			}
		}

		c := CustomerJsonRow{
			FirstName: record[colIndex["Vorname"]],
			LastName:  record[colIndex["Nachname"]],
			Birthday:  record[colIndex["Geburtsdatum"]],
			Country:   record[colIndex["Herkunftsland"]],
			Notes:     record[colIndex["Notizen"]],
		}

		if csvContainsUuid {
			c.Uuid = record[colIndex["UUID"]]
		}

		c.Visits = record[colIndex["Datum"]:]

		cs = append(cs, c)
	}
	return cs, nil
}

func mapHeader(header []string) (map[string]int, error) {
	if header[len(header)-1] != "Datum" {
		return nil, fmt.Errorf("last column is not \"Datum\": %w", ErrInvalidFormat)
	}
	if !slices.Contains(header, "Vorname") {
		return nil, fmt.Errorf("column \"Vorname\" not found: %w", ErrInvalidFormat)
	}
	if !slices.Contains(header, "Nachname") {
		return nil, fmt.Errorf("column \"Nachname\" not found: %w", ErrInvalidFormat)
	}
	colIndex := make(map[string]int)
	for i, col := range header {
		if _, exists := colIndex[col]; exists {
			return nil, fmt.Errorf("duplicated column header: %w", ErrInvalidFormat)
		}
		colIndex[col] = i
	}
	return colIndex, nil
}
