package db

import (
	"encoding/csv"
	"fmt"
	"io"
	"log"
	"slices"
	"time"
)

type CustomerJsonRow struct {
	Id        int64    `json:"id"`
	FirstName string   `json:"firstname"`
	LastName  string   `json:"lastname"`
	Birthday  string   `json:"birthday"`
	Country   string   `json:"country"`
	Notes     string   `json:"notes"`
	Visits    []string `json:"visits"`
}

func ExportJson() ([]CustomerJsonRow, error) {
	cs, err := AllCustomers()
	if err != nil {
		return []CustomerJsonRow{}, fmt.Errorf("export json: %w", err)
	}

	vs, err := AllVisits()
	if err != nil {
		return []CustomerJsonRow{}, fmt.Errorf("export json: %w", err)
	}

	data := make([]CustomerJsonRow, len(cs))
	customerIdMap := make(map[int64]int)
	for index := range data {
		c := cs[index]
		customerIdMap[c.Id] = index
		data[index] = CustomerJsonRow{
			Id:        c.Id,
			FirstName: c.FirstName,
			LastName:  c.LastName,
			Birthday:  c.Birthday,
			Country:   c.Country,
			Notes:     c.Notes,
		}
	}

	// collect visits array
	for _, v := range vs {
		if v.CustomerId == nil {
			continue
		}
		index := customerIdMap[*v.CustomerId]
		data[index].Visits = append(data[index].Visits, v.VisitDate)
	}

	return data, nil
}

func ImportJson(data []CustomerJsonRow) {
	for i := range data {
		row := &data[i]

		// import customer
		customer, err := AddCustomer(Customer{
			FirstName: row.FirstName,
			LastName:  row.LastName,
			Birthday:  row.Birthday,
			Country:   row.Country,
			Notes:     row.Notes,
		})
		if err != nil {
			log.Printf("WARNING: Unable to import customer: %s %s\n",
				row.FirstName,
				row.LastName,
			)
		}

		// import that customer's visits
		for _, visit := range row.Visits {
			visitDate, err := time.Parse(DateFormat, visit)
			if err != nil {
				log.Printf("WARNING: Invalid visit date format of customer %s %s: %s\n",
					row.FirstName,
					row.LastName,
					visit,
				)
				continue
			}
			_, err = AddVisit(customer.Id, &visitDate, "")
			if err != nil {
				log.Printf("WARNING: Unable to import visit of customer %s %s: %s\n",
					row.FirstName,
					row.LastName,
					visit,
				)
			}
		}
	}
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
	if err := checkHeader(header); err != nil {
		return nil, fmt.Errorf("missing header: %w", err)
	}

	// map header and column
	colIndex := make(map[string]int)
	for i, col := range header {
		colIndex[col] = i
	}

	var cs []CustomerJsonRow
	for {
		record, err := reader.Read()
		if err == io.EOF {
			break
		}
		if err != nil {
			return nil, fmt.Errorf("reading row: %w", ErrInvalidFormat)
		}

		c := CustomerJsonRow{
			FirstName: record[colIndex["Vorname"]],
			LastName:  record[colIndex["Nachname"]],
			Birthday:  record[colIndex["Geburtstag"]],
			Country:   record[colIndex["Land"]],
			Notes:     record[colIndex["Sonstiges"]],
		}

		c.Visits = record[colIndex["Besuche"]:]

		cs = append(cs, c)
	}
	return cs, nil
}

func checkHeader(header []string) error {
	if header[len(header)-1] != "Besuche" {
		return fmt.Errorf("last column is not Besuche: %w", ErrInvalidFormat)
	}
	if !slices.Contains(header, "Vorname") {
		return fmt.Errorf("column Vorname not found: %w", ErrInvalidFormat)
	}
	if !slices.Contains(header, "Nachname") {
		return fmt.Errorf("column Nachname not found: %w", ErrInvalidFormat)
	}
	return nil
}
