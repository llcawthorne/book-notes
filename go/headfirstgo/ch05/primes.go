package main

import "fmt"

var primes [5]int = [5]int{2, 3, 5, 7, 11}

func main() {
	for i := 0; i < len(primes); i++ {
		fmt.Println(i, primes[i])
	}
}
