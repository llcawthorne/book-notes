package com.ubertob.fotf.exercises.chapter1

class CashRegister(
    val prices: Map<String, Double>,
    val promotions: Map<String, String>
) {
    // Improved version; once I found out about groupingBy and eachCount
        fun checkout(items: List<String>): Double {
            val itemCounts = items.groupingBy { it }.eachCount()

            val total = itemCounts.entries.sumOf { (item, count) ->
                prices.getValue(item) * count
            }

            val discount = itemCounts.entries.sumOf { (item, count) ->
                promotions[item]?.let { promo ->
                    val (payFor, groupSize) = parsePromotion(promo)
                    if (count >= groupSize && groupSize > payFor)
                        (count / groupSize) * (groupSize - payFor) * prices.getValue(item)
                    else 0.0
                } ?: 0.0
            }

            return total - discount
        }

    /* First try, not functional. Used accumulators and for loops
    fun checkout(items: List<String>): Double {
        val itemCounts = mutableMapOf<String, Int>()
        var total = 0.0
        var discount = 0.0
        for (item in items) {
            if (item in itemCounts.keys)
                itemCounts[item] = itemCounts[item]!! + 1
            else
                itemCounts[item] = 1
        }
        for ((k, v) in promotions) {
            val (m, n) = parsePromotion(v)
            if (k in itemCounts.keys &&
                    itemCounts[k]!! >= n && n > m)
                discount += itemCounts[k]!! / n * (n - m) * prices[k]!!

        }
        for ((k, v) in itemCounts) {
            total += prices[k]!! * v
        }
        total -= discount
        return total
    }
    */

    private fun parsePromotion(promotion: String): Pair<Int, Int> {
        val parts = promotion.split('x')
        return Pair(parts[0].toInt(), parts[1].toInt())
    }
}