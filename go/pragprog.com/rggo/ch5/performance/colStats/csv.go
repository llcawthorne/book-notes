package main

import (
	"encoding/csv" // to read data from csv files
	"fmt"          // to print formatted results
	"io"           // for the io.Reader interface
	"strconv"      // to convert string data to numeric data
)

func sum(data []float64) float64 {
	sum := 0.0

	for _, v := range data {
		sum += v
	}

	return sum
}

func avg(data []float64) float64 {
	return sum(data) / float64(len(data))
}

// statsFunc defines a generic statistical function
type statsFunc func(data []float64) float64

func csv2float(r io.Reader, column int) ([]float64, error) {
	// Create the CSV Reader used to read in data from CSV files
	cr := csv.NewReader(r)
	cr.ReuseRecord = true // save memory by re-using a slice each Read

	// Adjusting for 0 based index
	column--

	var data []float64

	// an infinite loop since we don't know how many rows there are
	for i := 0; ; i++ {
		row, err := cr.Read()

		if err == io.EOF {
			break // break out of the infinite loop at EOF
		}

		if err != nil {
			return nil, fmt.Errorf("Cannot read data from file: %w", err)
		}

		// skip header line
		if i == 0 {
			continue
		}

		// Checking number of columns in CSV file
		if len(row) <= column {
			// File does not have that many columns
			return nil,
				fmt.Errorf("%w: File has only %d columns", ErrInvalidColumn, len(row))
		}
		// Try to convert the value of a given column to float
		v, err := strconv.ParseFloat(row[column], 64)
		if err != nil {
			return nil, fmt.Errorf("%w: %s", ErrNotNumber, err)
		}

		data = append(data, v)

	}

	// Return the slice of float64 and nil error
	return data, nil
}
