package main

import "fmt"

type MyType string

// simple method defined on MyType
func (m MyType) sayHi() {
	fmt.Println("Hi from", m)
}

func (m MyType) MethodWithParametersAndReturn(number int, flag bool) int {
	fmt.Println(m)
	fmt.Println(number)
	fmt.Println(flag)
	return len(m)
} 

func main() {
	value := MyType("a MyType value")
	value.sayHi()
	anotherValue := MyType("another value")
	anotherValue.sayHi()
	valLen := value.MethodWithParametersAndReturn(10, true)
	fmt.Println(valLen)
}
