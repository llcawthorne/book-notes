package main

import "fmt"

func status(name string) {
	grades := map[string]float64{"Alma": 0, "Rohit": 86.5}
	grade, ok := grades[name]
	if !ok {
		fmt.Printf("No grade recorded for %s.\n", name)
	} else if grade < 60 {
		fmt.Printf("%s is failing!\n", name)
	} else {
		fmt.Println(name, "has a fine grade!")
	}
}

func main() {
	status("Alma")
	status("Carl")
	status("Rohit")
}
