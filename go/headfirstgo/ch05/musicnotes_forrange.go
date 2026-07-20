package main

import "fmt"

func main() {
	notes := [7]string{"do", "re", "mi", "fa", "so", "la", "ti"}

	for _, note := range notes {
		fmt.Println(note)
	}
}
