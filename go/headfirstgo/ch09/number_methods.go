package main

import "fmt"

type Number int

func (n *Number) Display() {
	fmt.Println(*n)
}

func (n *Number) Double() {   // declare receiver parameter as pointer
	*n *= 2
}

func main() {
	number := Number(4)
	number.Display()
	number.Double()				// normal method call
	number.Display()
}
