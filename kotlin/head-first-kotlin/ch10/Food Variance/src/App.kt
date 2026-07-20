

// Food types
open class Food

class VeganFood : Food()

// Sellers
interface Seller<out T>

class FoodSeller : Seller<Food>

class VeganFoodSeller : Seller<VeganFood>

// Consumers
interface Consumer<in T>

class Person : Consumer<Food>

class Vegan : Consumer<VeganFood>

fun main() {
    var foodSeller: Seller<Food>
    foodSeller = FoodSeller()
    foodSeller = VeganFoodSeller() // covariant; a VeganFoodSeller is a Seller

    var veganFoodConsumer: Consumer<VeganFood>
    veganFoodConsumer = Vegan()
    veganFoodConsumer = Person() // contravariant; a Person can be a Vegan
}
