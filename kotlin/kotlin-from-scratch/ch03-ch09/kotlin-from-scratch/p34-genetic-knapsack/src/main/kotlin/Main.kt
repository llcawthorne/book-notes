/*
 * Solve the Knapsack Problem
 *
 * The book goes into quite a lot of detail about the general design of genetic
 * algorithms. Most of the relevant discussion is at the beginning of Chapter 8
 * and before Project 33.
 *
 */
import kotlin.math.roundToInt

data class Solution(val chromosome: IntArray, val fitness: Int)
data class Item(val value: Int, val weight: Int)

private val items: List<Item> = listOf(
    Item(75, 15),
    Item(55, 32),
    Item(50, 30),
    Item(68, 43),
    Item(62, 54),
    Item(45, 38),
    Item(68, 62),
    Item(84, 85),
    Item(87, 87),
    Item(95, 83),
    Item(35, 21),
    Item(63, 53),
)
val chromosomeLength = items.size
val maxWeight = 175

val POP_SIZE = 25
val MAX_GEN = 30
val ELITISM = 0.1
val eliteSize = (POP_SIZE * ELITISM).toInt()
val MUTATION_THRESHOLD =
    ((1.0 / chromosomeLength) * 1000.0).roundToInt() / 1000.0

val population: MutableList<Solution> = mutableListOf()
val nextgen: MutableList<Solution> = mutableListOf()
val bestSolutions: MutableList<Solution> = mutableListOf()

fun initPopulation() {
    // Initialize a population of POP_SIZE individuals of nonzero fitness.
    for (person in 0 until POP_SIZE) {
        var chromosome = IntArray(chromosomeLength)

        var not_done = true
        while (not_done) {
            for (gene in 0 until chromosomeLength) {
                chromosome[gene] = (0..1).random()
            }
            val fitness = getFitness(chromosome)
            if (fitness > 0) {
                population += Solution(chromosome, fitness)
                not_done = false
            }
        }
    }
    // Sort population (in place) in descending order.
    population.sortByDescending { it.fitness }
    println("\nBest solution from initial population:")
    println("${population[0].toString()}")
    println("\n... initPopulation done ...\n")
}

fun getFitness(chromosome: IntArray): Int {
    val sumValue = (chromosome.zip(items) { c, item -> c * item.value }).sum()
    val sumWeight = (chromosome.zip(items) { c, item -> c * item.weight }).sum()

    return if (sumWeight <= maxWeight) sumValue else 0
}

fun runGA() {
    // Iterate for a specified number of generations.
    for (generation in 1 .. MAX_GEN) {
        // Step 1: Implement elitism.
        selectElites()

        // Step 2: Implement crossover and mutation.
        for (i in eliteSize until POP_SIZE) {
            // Select parents for crossover.
            val parent1 = tournament()
            val parent2 = tournament()

            // Produce a child by using crossover and mutation.
            val child = crossover(parent1, parent2)

            // Add the child to next gen.
            nextgen += child
        }

        // Step 3: Transfer nextgen to the current population.
        for (i in nextgen.indices)
            population[i] = nextgen[i].copy()

        // Step 4: Clear nextgen for the next iteration.
        nextgen.clear()

        // Step 5: Sort population in descending order (in place).
        population.sortByDescending { it.fitness }

        // Step 6: Add the fittest solution to bestSolutions.
        bestSolutions += population[0]

        // Step 7: (optional) Print the best solution per generation.
        printSolution(generation, population[0])
    }
}

fun printSolution(generation: Int, solution: Solution) {
    val str1 = "%04d".format(generation).padEnd(10, ' ')
    val (c, f) = solution
    val str2 = c.contentToString()
    val str3 = f.toString().padStart(6, ' ')
    println(str1 + str2 + str3)
}

fun selectElites() {
    for (i in 0 until eliteSize)
        nextgen += population[i].copy()
}

fun tournament(): Solution {
    // random sampling with replacement
    // Use the entire population, including elites.
    val candidate1 = population.random().copy()
    val candidate2 = population.random().copy()
    // Return the winner of the tournament.
    return if (candidate1.fitness >= candidate2.fitness) candidate1
            else candidate2
}

fun crossover(parent1: Solution, parent2: Solution): Solution {
    // random single-point split crossover
    val split = (1 until chromosomeLength).random()

    // Use slice to extract elements from a array.
    val arr1 = parent1.chromosome.copyOfRange(0, split)
    val arr2 = parent2.chromosome.copyOfRange(split, chromosomeLength)

    val newChromosome = arr1 + arr2

    // Apply in-place mutation to crossChromosome.
    mutation(newChromosome)

    return Solution(newChromosome, getFitness(newChromosome))
}

fun mutation(newChromosome: IntArray): Unit {
    for (i in 0 until chromosomeLength) {
        if ((0..1000).random() / 1000.0 <= MUTATION_THRESHOLD)
            // simplest way to flip values between 0 and 1 is i = 1 - i.
            newChromosome[i] = (1 - newChromosome[i])
    }
}

fun main() {
    println("\n*** Solving the 0-1 knapsack problem using the genetic algorithm ***\n")
    println("Population size: $POP_SIZE, Generations: $MAX_GEN, " +
            "Number of items to pick from: $chromosomeLength")
    println("Mutation threshold: $MUTATION_THRESHOLD")

    initPopulation()
    runGA()
    printBestSolution()
}

fun printBestSolution() {
    bestSolutions.sortByDescending { it.fitness }
    println("\nBest solution found after $MAX_GEN generations:")

    val (chromosome, fitness) = bestSolutions[0]
    val sumWeight = (chromosome.zip(items)
                     { c, item -> c * item.weight }).sum()
    println(bestSolutions[0].toString())
    println("Sum of weights: $sumWeight   Sum of values: $fitness")
}
