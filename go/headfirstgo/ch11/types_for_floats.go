package main

import "fmt"

type Liters float64
func (g Liters) String() string {
	return fmt.Sprintf("%0.2f L", g)
}
func (l Liters) ToGallons() Gallons {
	return Gallons(l * 0.264)
}

type Milliliters float64
func (g Milliliters) String() string {
	return fmt.Sprintf("%0.2f mL", g)
}
func (m Milliliters) ToGallons() Gallons {
	return Gallons(m * 0.000264)
}

type Gallons float64
func (g Gallons) String() string {
	return fmt.Sprintf("%0.2f gal", g)
}
func (g Gallons) ToLiters() Liters {
	return Liters(g * 3.785)
}
func (g Gallons) ToMilliliters() Milliliters {
	return Milliliters(g * 3785.41)
}

func main() {
	var carFuel Gallons
	var busFuel Liters
	carFuel = Gallons(10.0)
	busFuel = Liters(240.0)
	fmt.Printf("Gallons: %0.1f Liters: %0.1f\n", carFuel, busFuel)

	soda := Liters(2)
	fmt.Printf("%0.3f liters equals %0.3f gallons\n", soda, soda.ToGallons())
	water := Milliliters(500)
	fmt.Printf("%0.3f milliliters equals %0.3f gallons\n", water, water.ToGallons())

	milk := Gallons(2)
	fmt.Printf("%0.3f gallons equals %0.3f liters\n", milk, milk.ToLiters())
	fmt.Printf("%0.3f gallons equals %0.3f milliliters\n", milk, milk.ToMilliliters())

	// use Stringer interface
	fmt.Println(soda)
	fmt.Println(water)
	fmt.Println(milk)
}
