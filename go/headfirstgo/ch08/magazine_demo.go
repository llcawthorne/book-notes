package main

import (
	"fmt"
	"headfirstgo/ch08/magazine"
)

func main() {
	subscriber := magazine.Subscriber{Name: "Aman Singh"}
	// I left HomeAddress named, althought it would usually be embedded
	subscriber.HomeAddress.Street = "123 Oak St"
	subscriber.HomeAddress.City = "Omaha"
	subscriber.HomeAddress.State = "NE"
	subscriber.HomeAddress.PostalCode = "68111"
	fmt.Println("Street:", subscriber.HomeAddress.Street)
	fmt.Println("City:", subscriber.HomeAddress.City)
	fmt.Println("State:", subscriber.HomeAddress.State)
	fmt.Println("Postal Code:", subscriber.HomeAddress.PostalCode)

	employee := magazine.Employee{Name: "Joy Carr"}
	// the Address struct is embedded in the Employee
	employee.Street = "456 Elm St"
	employee.City = "Portland"
	employee.State = "OR"
	employee.PostalCode = "97222"
	fmt.Println("Street:", employee.Street)
	fmt.Println("City:", employee.City)
	fmt.Println("State:", employee.State)
	fmt.Println("Postal Code:", employee.PostalCode)
}
