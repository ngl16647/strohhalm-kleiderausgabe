package main

import (
	"fmt"
	"strohhalm-backend/routes"
)

func printAPIDocs() {
	for _, route := range routes.Routes {
		fmt.Printf("%s %s\n", route.Method, route.Path)
		fmt.Println("    Description:", route.Doc)
		if len(route.QueryParams) > 0 {
			fmt.Println("    Parameters:")
			for _, q := range route.QueryParams {
				option := "(optional)"
				if q.Required {
					option = ""
				}
				fmt.Printf("      - %s %s: %s\n", q.Name, option, q.Description)
			}
		}
		fmt.Println()
	}
}
