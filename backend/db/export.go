package db

import (
	"fmt"
)

type CustomerJsonRow struct {
	Id        int64    `json:"id"`
	Firstname string   `json:"firstname"`
	Lastname  string   `json:"lastname"`
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
			Firstname: c.FirstName,
			Lastname:  c.LastName,
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
