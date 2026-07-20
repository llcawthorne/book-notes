package mypkg

import "fmt"

type MyInterface interface {
	MethodWithoutParameters()
	MethodWithParameter(float64)
	MethodWithReturnValue() string
}

// Mytype satisfies the MyInterface interface
type MyType int

func (m MyType) MethodWithoutParameters() {
	fmt.Println("MethodWithoutParameters call")
}
func (m MyType) MethodWithParameter(f float64) {
	fmt.Println("MethodWithParameter called with", f)
}
func (m MyType) MethodWithReturnValue() string {
	return "Hi from MethodWithReturnValue"
}
func (m MyType) MethodNoteInInterface() {
	fmt.Println("MethodNotInInterface called")
}
