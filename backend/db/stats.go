package db

import "time"

type CountryDistribution struct {
	Country string `json:"country"`
	Count   int64  `json:"count"`
}

type DateDistribution struct {
	Date  string `db:"visit_date" json:"date"`
	Count int64  `json:"count"`
}

type CustomerStats struct {
	TotalCustomers     int64                 `json:"totalCustomers"`
	CustomersByCountry []CountryDistribution `json:"customersByCountry"`
}

type VisitStats struct {
	TotalVisits  int64              `json:"totalVisits"`
	VisitsByDate []DateDistribution `json:"visitsByDate"`
}

func GetCustomerStats() (CustomerStats, error) {
	var cs CustomerStats

	count, err := getTotalCustomers()
	if err != nil {
		return cs, err
	}

	countryDistributions, err := countCountries()
	if err != nil {
		return cs, err
	}

	cs.TotalCustomers = count
	cs.CustomersByCountry = countryDistributions
	return cs, nil
}

func GetVisitStats(from time.Time, to time.Time) (VisitStats, error) {
	var vs VisitStats
	fromStr := from.Format(DateFormat)
	toStr := to.Format(DateFormat)

	visitDistributions, err := getVisitDistribution(fromStr, toStr)
	if err != nil {
		return vs, err
	}

	count, err := getTotalVisits(fromStr, toStr)
	if err != nil {
		return vs, err
	}

	vs.TotalVisits = count
	vs.VisitsByDate = visitDistributions
	return vs, nil
}

func countCountries() ([]CountryDistribution, error) {
	var cd []CountryDistribution
	err := db.Select(&cd, `
        SELECT country, COUNT(*) AS count
        FROM customers
        GROUP BY country
		ORDER BY country
    `)
	return cd, err
}

func getTotalCustomers() (int64, error) {
	var count int64
	err := db.Get(&count, "SELECT COUNT(*) FROM customers")
	return count, err
}

func getVisitDistribution(from string, to string) ([]DateDistribution, error) {
	var distributions []DateDistribution
	err := db.Select(&distributions, `
		SELECT visit_date, COUNT(*) AS count
		FROM visits
		WHERE visit_date BETWEEN $1 AND $2
		GROUP BY visit_date
		ORDER BY visit_date
	`, from, to)
	return distributions, err
}

func getTotalVisits(from string, to string) (int64, error) {
	var count int64
	err := db.Get(&count, `
		SELECT COUNT(*) FROM visits
		WHERE visit_date BETWEEN $1 AND $2
	`, from, to)
	return count, err

}
