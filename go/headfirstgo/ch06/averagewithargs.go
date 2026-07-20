// average calculates the average of several numbers.
package main

import (
	"fmt"
	"log"
	"os"
	"strconv"
)

func main() {
	arguments := os.Args[1:] // chop out the program name
	var sum float64 = 0
	for _, argument := range arguments {
		number, err := strconv.ParseFloat(argument, 64)
		if err != nil {
			log.Fatal(err)
		}
		sum += number
	}
	sampleCount := float64(len(arguments)) // convert array length to float
	fmt.Printf("Average: %0.2f\n", sum/sampleCount)
}
