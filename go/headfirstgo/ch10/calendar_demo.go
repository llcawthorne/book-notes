package main

import (
	"fmt"
	"headfirstgo/ch10/calendar"
	"log"
)

func main() {
	event := calendar.Event{}
	// Getters and Setters are promoted from embeeded Date
	err := event.SetTitle("Mom's Birthday")
	if err != nil {
		log.Fatal(err)
	}
	err = event.SetYear(2019)
	if err != nil {
		log.Fatal(err)
	}
	err = event.SetMonth(5)
	if err != nil {
		log.Fatal(err)
	}
	err = event.SetDay(27)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println(event)
	fmt.Println(event.Title())
	fmt.Println(event.Year())
	fmt.Println(event.Month())
	fmt.Println(event.Day())

	err = event.SetTitle("An extremely long title that is impractical to print")
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println(event)
}
