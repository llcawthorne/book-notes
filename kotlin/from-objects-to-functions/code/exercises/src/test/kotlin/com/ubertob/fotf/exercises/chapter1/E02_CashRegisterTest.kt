package com.ubertob.fotf.exercises.chapter1

import org.junit.jupiter.api.Test
import strikt.api.expect
import strikt.assertions.isEqualTo
import strikt.assertions.isGreaterThanOrEqualTo
import strikt.assertions.isLessThanOrEqualTo
import kotlin.math.abs
import kotlin.random.Random

val TOL = 0.001
fun randomSmallNatural() = Random.nextInt(from = 1, until = 25)
fun randomNatural() = Random.nextInt(from = 1, until = 100_000_000)
fun randomDouble() = Random.nextDouble(from = 0.0, until = 100_000_000.00)

class CashRegisterTest {
    @Test
    fun `a cash register should price a list of items with no promotions`() {
        val prices = mapOf(
            "milk" to 2.00,
            "eggs" to 1.50,
            "cheese" to 4.00,
        )
        val cr = CashRegister(
            prices,
            emptyMap<String, String>()
        )
        val milkTotal = cr.checkout(listOf("milk", "milk", "milk"))
        val eggsTotal = cr.checkout(listOf("eggs", "eggs", "eggs"))
        val cheeseTotal = cr.checkout(listOf("cheese", "cheese", "cheese"))
        val mixedTotal = cr.checkout(listOf(
            "milk", "eggs", "cheese", "milk", "eggs", "cheese"
        ))
        expect {
            that(milkTotal).isEqualTo(6.00)
            that(eggsTotal).isEqualTo(4.50)
            that(cheeseTotal).isEqualTo(12.00)
            that(mixedTotal).isEqualTo(15.00)
        }
    }

    @Test
    fun `1x1 promotions shouldn't change anything`() {
        val prices = mapOf(
            "milk" to 2.00,
            "eggs" to 1.50,
            "cheese" to 4.00,
        )
        val promotions = mapOf(
            "milk" to "1x1",
            "eggs" to "1x1",
            "cheese" to "1x1",
        )
        val cr = CashRegister(
            prices,
            promotions,
        )
        val milkTotal = cr.checkout(listOf("milk", "milk", "milk"))
        val eggsTotal = cr.checkout(listOf("eggs", "eggs", "eggs"))
        val cheeseTotal = cr.checkout(listOf("cheese", "cheese", "cheese"))
        val mixedTotal = cr.checkout(listOf(
            "milk", "eggs", "cheese", "milk", "eggs", "cheese"
        ))
        expect {
            that(milkTotal).isEqualTo(6.00)
            that(eggsTotal).isEqualTo(4.50)
            that(cheeseTotal).isEqualTo(12.00)
            that(mixedTotal).isEqualTo(15.00)
        }
    }

    @Test
    fun `2x3 milk saves money`() {
        val prices = mapOf(
            "milk" to 2.00,
            "eggs" to 1.50,
            "cheese" to 4.00,
        )
        val promotions = mapOf(
            "milk" to "2x3",
            "eggs" to "1x1",
        )
        val cr = CashRegister(
            prices,
            promotions,
        )
        val milkTotal = cr.checkout(listOf("milk", "milk", "milk"))
        val eggsTotal = cr.checkout(listOf("eggs", "eggs", "eggs"))
        val cheeseTotal = cr.checkout(listOf("cheese", "cheese", "cheese"))
        val mixedTotal = cr.checkout(listOf(
            "milk", "eggs", "cheese", "milk", "eggs", "cheese", "milk"
        ))
        expect {
            that(milkTotal).isEqualTo(4.00)
            that(eggsTotal).isEqualTo(4.50)
            that(cheeseTotal).isEqualTo(12.00)
            that(mixedTotal).isEqualTo(15.00)
        }
    }

    @Test
    fun `2x3 milk saves more money for 9 milks`() {
        val prices = mapOf(
            "milk" to 2.00,
            "eggs" to 1.50,
            "cheese" to 4.00,
        )
        val promotions = mapOf(
            "milk" to "2x3",
            "eggs" to "1x1",
        )
        val cr = CashRegister(
            prices,
            promotions,
        )
        val milkTotal = cr.checkout(listOf("milk", "milk", "milk",
                                                   "milk", "milk", "milk",
                                                   "milk", "milk", "milk"))
        val eggsTotal = cr.checkout(listOf("eggs", "eggs", "eggs"))
        val cheeseTotal = cr.checkout(listOf("cheese", "cheese", "cheese"))
        val mixedTotal = cr.checkout(listOf(
            "milk", "eggs", "cheese", "milk", "eggs", "cheese", "milk",
            "milk", "milk", "milk", "milk", "milk", "milk"
        ))
        expect {
            that(milkTotal).isEqualTo(12.00)
            that(eggsTotal).isEqualTo(4.50)
            that(cheeseTotal).isEqualTo(12.00)
            that(mixedTotal).isEqualTo(23.00)
        }
    }

    @Test
    fun `random prices with no promotions`() {
        repeat (100) {
            val prices = mapOf(
                "milk" to randomDouble(),
                "eggs" to randomDouble(),
                "cheese" to randomDouble(),
            )
            /* val promotions = mapOf(
                "milk" to "${randomSmallNatural()}x${randomSmallNatural()}",
                "eggs" to "${randomSmallNatural()}x${randomSmallNatural()}",
                "cheese" to "${randomSmallNatural()}x${randomSmallNatural()}",
            ) */
            val promotions = emptyMap<String, String>()
            val cr = CashRegister(
                prices,
                promotions,
            )
            val shoppingList = mutableListOf<String>()
            for (i in 0..randomSmallNatural()) shoppingList += "milk"
            for (i in 0..randomSmallNatural()) shoppingList += "cheese"
            for (i in 0..randomSmallNatural()) shoppingList += "eggs"
            val shoppingTotal = cr.checkout(shoppingList)
            expect {
                that(shoppingTotal).isLessThanOrEqualTo(
                    shoppingList.count { it == "milk" } * prices["milk"]!! +
                    shoppingList.count { it == "eggs" } * prices["eggs"]!! +
                    shoppingList.count { it == "cheese" } * prices["cheese"]!! +
                    TOL
                )
            }
        }
    }

    @Test
    fun `the sum of two checkouts without discounts is equal to the checkout of the sum`() {
        repeat (100) {
            val prices = mapOf(
                "milk" to randomDouble(),
                "eggs" to randomDouble(),
                "cheese" to randomDouble(),
            )
            /* val promotions = mapOf(
                "milk" to "${randomSmallNatural()}x${randomSmallNatural()}",
                "eggs" to "${randomSmallNatural()}x${randomSmallNatural()}",
                "cheese" to "${randomSmallNatural()}x${randomSmallNatural()}",
            ) */
            val promotions = emptyMap<String, String>()
            val cr = CashRegister(
                prices,
                promotions,
            )
            val shoppingList1 = mutableListOf<String>()
            for (i in 0..randomSmallNatural()) shoppingList1 += "milk"
            for (i in 0..randomSmallNatural()) shoppingList1 += "cheese"
            for (i in 0..randomSmallNatural()) shoppingList1 += "eggs"
            val shoppingList2 = mutableListOf<String>()
            for (i in 0..randomSmallNatural()) shoppingList2 += "milk"
            for (i in 0..randomSmallNatural()) shoppingList2 += "cheese"
            for (i in 0..randomSmallNatural()) shoppingList2 += "eggs"
            val shoppingTotal1 = cr.checkout(shoppingList1) + cr.checkout(shoppingList2)
            val shoppingTotal2 = cr.checkout(shoppingList1 + shoppingList2)
            expect {
                that(abs(shoppingTotal1 - shoppingTotal2)).isLessThanOrEqualTo(TOL)
            }
        }
    }

    @Test
    fun `a shopping list with random promotions is always less than or equal to one without promotions`() {
        repeat (100) {
            val prices = mapOf(
                "milk" to randomDouble(),
                "eggs" to randomDouble(),
                "cheese" to randomDouble(),
            )
            val promotions = mapOf(
                "milk" to "${randomSmallNatural()}x${randomSmallNatural()}",
                "eggs" to "${randomSmallNatural()}x${randomSmallNatural()}",
                "cheese" to "${randomSmallNatural()}x${randomSmallNatural()}",
            )
            val cr = CashRegister(
                prices,
                promotions,
            )
            val promotionlessCr = CashRegister(
                prices,
                emptyMap<String, String>(),
            )
            val shoppingList= mutableListOf<String>()
            for (i in 0..randomSmallNatural()) shoppingList += "milk"
            for (i in 0..randomSmallNatural()) shoppingList += "cheese"
            for (i in 0..randomSmallNatural()) shoppingList += "eggs"
            val shoppingTotal1 = cr.checkout(shoppingList)
            val shoppingTotal2 = promotionlessCr.checkout(shoppingList)
            expect {
                that(shoppingTotal1).isLessThanOrEqualTo(shoppingTotal2 + TOL)
            }
        }
    }
}
