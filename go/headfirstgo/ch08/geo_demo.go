package main

import (
	"fmt"
	"headfirstgo/ch08/geo"
)

func main() {
	location := geo.Landmark{}
	location.Name = "The Googleplex"
	location.Latitude = 37.42 // accessing the embedded anonymous struct
	location.Longitude = -122.08
	fmt.Println(location)
}
