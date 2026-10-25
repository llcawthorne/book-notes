package main

import (
	"os"
	"time"

	"example.com/learn-go-with-tests/17-math/clockface"
)

func main() {
	t := time.Now()
	clockface.SVGWriter(os.Stdout, t)
}
