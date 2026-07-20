package main

import (
	"bufio"
	"flag"
	"fmt"
	"io"
	"log"
	"os"
)

func main() {
	// Defining a boolean flag -l to count lines instead of words
	lines := flag.Bool("l", false, "Count lines")
	// Defining a boolean flag -b to count bytes instead of words
	bytes := flag.Bool("b", false, "Count bytes")
	// Parsing the flags provided by the user
	flag.Parse()

	// Calling the count function to count the number of words (or lines)
	// received from the Standard Input and printing it out
	fmt.Println(count(os.Stdin, *lines, *bytes))
}

func count(r io.Reader, countLines bool, countBytes bool) int {
	// A scanner i sused to read text from a Reader (such as files)
	scanner := bufio.NewScanner(r)

	if countLines && countBytes {
		log.Fatal("You cannot count both bytes (-b) and lines (-l)!")
	}

	// set the split by the flags provided
	if countLines {
		// this is the default but we're setting it to be explicit
		scanner.Split(bufio.ScanLines)
	} else if countBytes {
		// Define the scanner split type to bytes (default is split by lines)
		scanner.Split(bufio.ScanBytes)
	} else {
		// Define the scanner split type to words (default is split by lines)
		scanner.Split(bufio.ScanWords)
	}

	// Defining a counter
	wc := 0

	// For every word or line scanned, increment the counter
	for scanner.Scan() {
		wc++
	}

	// Return the total
	return wc
}
