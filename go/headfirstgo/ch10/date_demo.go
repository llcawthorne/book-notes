package main

import (
	"fmt"
	"headfirstgo/ch10/calendar"
	"log"
)

func main() {
	date := calendar.Date{}
	err := date.SetYear(2020)
	if err != nil {
		log.Fatal(err)
	}
	err = date.SetMonth(3)
	if err != nil {
		log.Fatal(err)
	}
	err = date.SetDay(12)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println(date)
	fmt.Println(date.Year())
	fmt.Println(date.Month())
	fmt.Println(date.Day())
	
	err = date.SetMonth(14)
	if err != nil {
		log.Fatal(err)
	}
	err = date.SetDay(12)
}
