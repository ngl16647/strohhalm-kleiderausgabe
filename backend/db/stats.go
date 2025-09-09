package db

type CountryDistribution struct {
	Country string `json:"country"`
	Count   int64  `json:"count"`
}

type CustomerStats struct {
	TotalCustomers     int64                 `json:"total_customers"`
	CustomersByCountry []CountryDistribution `json:"customers_by_country"`
}

type VisitStats struct {
}

func GetCustomerStats() (CustomerStats, error) {
	var cs CustomerStats

	count, err := getTotalCustomers()
	if err != nil {
		return cs, err
	}

	countryDistribution, err := countCountries()
	if err != nil {
		return cs, err
	}

	cs.TotalCustomers = count
	cs.CustomersByCountry = countryDistribution
	return cs, nil
}

func countCountries() ([]CountryDistribution, error) {
	var cd []CountryDistribution
	err := DB.Select(&cd, `
        SELECT country, COUNT(*) AS count
        FROM customers
        GROUP BY country
    `)
	if err != nil {
		return cd, err
	}
	return cd, nil
}

func getTotalCustomers() (int64, error) {
	var count int64
	err := DB.Get(&count, "SELECT COUNT(*) FROM customers")
	return count, err
}

func getTotalVisits() (int64, error) {
	var count int64
	err := DB.Get(&count, "SELECT COUNT(*) FROM visits")
	return count, err
}
