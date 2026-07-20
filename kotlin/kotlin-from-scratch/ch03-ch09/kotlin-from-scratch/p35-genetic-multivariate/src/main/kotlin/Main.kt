/* Optimize a Multivariate Function with the Genetic Algorithm
 *
 * The book goes into quite a lot of detail about the general design of genetic
 * algorithms. Most of the relevant discussion is at the beginning of Chapter 8
 * and before Project 33.
 *
 * We are going to work with the Eggholder function defined by x_1 and x_2 in
 * the decision space x_i in [-512, 512]. For a multivariate problem we have
 * a gene to represent each independent variables, so we will have two genes.
 * Also, unlike our other genetic algorithms, this is a minimization problem.
 * We are going ot handle this by multiplying the maximization function by -1.
 * Mutation for real numbers is introduce as a small noise value that is added
 * or subtracted from the genes. The noise amount is calculated as a small
 * fraction of the rnage for a specific gene.
 *
 */
import kotlin.math.sin
import kotlin.math.sqrt
import kotlin.math.abs
import kotlin.math.pow
import kotlin.math.min
import kotlin.math.max
import kotlin.random.Random

data class Solution(val chromosome: DoubleArray, val fitness: Double)

val getFitness = :: eggHolder   // the function is the fitness measure

val chromosomeLength = 2    // the number of independent variables
val bounds = arrayOf(doubleArrayOf(-512.0, 512.0),
                     doubleArrayOf(-512.0, 512.0))
val varRange = doubleArrayOf(bounds[0][1] - bounds[0][0],
                             bounds[1][1] - bounds[1][0])

val POP_SIZE = 100
val MAX_GEN = 200
val ELITISM = 0.1
val eliteSize = (POP_SIZE * ELITISM).toInt()
val MUTATION_THRESHOLD = 0.5 // On average, 1 of 2 genes will mutate.
val MUTATION_FACTOR = 0.02

val population: MutableList<Solution> = mutableListOf()
val nextgen: MutableList<Solution> = mutableListOf()
val bestSolutions: MutableList<Solution> = mutableListOf()

fun initPopulation() {
    // Initialize a population of POP_SIZE individuals of valid solutions
    // (which are genes within bounds).
    for (person in 0 until POP_SIZE) {
        var x = DoubleArray(chromosomeLength)
        for (i in 0 until chromosomeLength) {
            // The first argument is inclusive; the second is not
            x[i] = Random.nextDouble(bounds[i][0], bounds[i][1])
        }
        population += Solution(x, getFitness(x))
    }
    // Sort population (in place) in descending order.
    population.sortByDescending { it.fitness }
    println("\nBest solution from initial population:")
    println("${population[0]}")
    println("\n... initPopulation done ...\n")
}

fun eggHolder(x: DoubleArray): Double {
    val c1 = (x[1] + 47)
    val c2 = sin(sqrt(abs(0.5 * x[0] + c1)))
    val c3 = x[0] * sin(sqrt(abs(x[0] - c1)))

    // Multiply by -1 ONLY for minimization problems.
    return -1.0 * (-c1 * c2 - c3)
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
    val str2 = "%5.7f".format(c[0]).padEnd(14, ' ')
    val str3 = "%5.7f".format(c[1]).padEnd(14, ' ')

    // multiply fitness by -1 for display
    val str4 = "%5.4f".format(-f)

    println(str1 + str2 + str3 + str4)
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
    // Select a random weight within (0-1).
    val s = (0..1000).random() / 1000.0

    // Generate randomly weighted genes.
    var x1 = parent1.chromosome[0] * s + parent2.chromosome[0] * (1-s)
    var x2 = parent1.chromosome[1] * s + parent2.chromosome[1] * (1-s)

    // Check that the new genes stay within bounds (decision space).
    x1 = min(max(x1, bounds[0][0]), bounds[0][1])
    x2 = min(max(x2, bounds[1][0]), bounds[1][1])

    val xNew = doubleArrayOf(x1, x2)
    mutation(xNew)

    return Solution(xNew, getFitness(xNew))
}

fun mutation(xNew: DoubleArray) {
    for (i in 0 until chromosomeLength) {
        if ((0..1000).random() / 1000.0 <= MUTATION_THRESHOLD) {
            // Get the random sign factor.
            val sign = if ((0..100).random() / 100.0 <= 0.5) -1 else 1
            xNew[i] += sign * varRange[i] * MUTATION_FACTOR
            xNew[i] = min(max(xNew[i], bounds[i][0]), bounds[i][1])
        }
    }
}

fun main() {
    println("\n*** Real-valued function optimization using the genetic algorithm ***\n")
    println("Number of dimensions: $chromosomeLength")
    println("Population size: $POP_SIZE, Generations: $MAX_GEN")
    println("Elitism: $ELITISM")
    println("Mutation threshold: $MUTATION_THRESHOLD")
    println("Mutation factor: $MUTATION_FACTOR")

    initPopulation()
    runGA()
    printBestSolution()
}

fun printBestSolution() {
    bestSolutions.sortByDescending { it.fitness }
    println("\nBest solution found after $MAX_GEN generations:")

    val (chromosome, fitness) = bestSolutions[0]
    for (i in chromosome.indices) {
        print("chromosome[$i]: ")
        println("%5.8f".format(chromosome[i]))
    }
    println("Fitness: " + "%5.5f".format(-fitness))
}
