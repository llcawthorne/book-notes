package main

import (
	"fmt"
	"time" // import for time.Time type and time.Now()
)

func main() {
	var now time.Time = time.Now()
	var year int = now.Year()
	fmt.Println(year)
}
