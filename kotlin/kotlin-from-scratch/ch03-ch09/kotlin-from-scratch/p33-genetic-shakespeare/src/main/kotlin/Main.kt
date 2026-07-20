/*
 * Evolve Gibberish into Shakespear
 *
 * The book goes into quite a lot of detail about the general design of genetic
 * algorithms.
 */

data class Solution(
    val chromosome: String,
    val fitness: Int,
)

val TARGET = "To be, or not to be: that is the question."
val VALID_GENES: String =
    "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ" +
        "1234567890" +
        ", .-;:_!/?$%&()={}[]$(@\"\'"
val chromosomeLength = TARGET.length
val POP_SIZE = 100
val MAX_GEN = 1000
val ELITISM = 0.15
val eliteSize = (POP_SIZE * ELITISM).toInt()
val MUTATION_THRESHOLD = 1.0 / chromosomeLength

val population: MutableList<Solution> = mutableListOf()
val nextgen: MutableList<Solution> = mutableListOf()

fun initPopulation() {
    // Initialize a population of POP_SIZE individuals.
    for (i in 0 until POP_SIZE) {
        var chromosome = ""
        for (j in 0 until chromosomeLength) {
            chromosome += VALID_GENES.random()
        }
        // Calculate fitness of the new chromosome.
        val fitness = getFitness(chromosome)
        // Add the new individual to the population.
        population += Solution(chromosome, fitness)
    }
    // Sort population (in place) in descending order.
    population.sortByDescending { it.fitness }
    println("\nBest solution from initial population:")
    println(population[0].toString())
    println("\n... initPopulation done ...\n")
}

fun getFitness(chromosome: String): Int {
    var fitness = 0
    val pairs = TARGET.zip(chromosome)
    for (pair in pairs) {
        if (pair.first == pair.second)
            fitness += 1
    }
    return fitness
}

fun runGA() {
    // Iterate for a specified number of generations.
    for (generation in 1 .. MAX_GEN) {
        // Step 1: Check for termination condition.
        if (population[0].fitness >= chromosomeLength) {
            println("\n*** Target reached at generation = " +
                    "${generation - 1} ***\n")
            break
        }

        // Step 2: Implement elitism.
        selectElites()

        // Step 3: Implement crossover and mutation.
        for (i in eliteSize until POP_SIZE) {
            // Select parents for crossover.
            val parent1 = tournament()
            val parent2 = tournament()

            // Produce a child by using crossover and mutation.
            val child = crossover(parent1, parent2)

            // Add the child to next gen.
            nextgen += child
        }

        // Step 4: Transfer nextgen to the current population.
        for (i in nextgen.indices)
            population[i] = nextgen[i].copy()

        // Step 5: Clear nextgen for the next iteration.
        nextgen.clear()

        // Step 6: Sort population in descending order (in place).
        population.sortByDescending { it.fitness }

        // Step 7: (optional) Print the best solution per generation.
        val formatString = "%5d %44s %4d"
        println(formatString.format(generation,
                population[0].chromosome, population[0].fitness))
    }
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

    // Use slice to extract segments from a string.
    val crossChromosome =
        parent1.chromosome.slice(0 until split) +
            parent2.chromosome.slice(split until chromosomeLength)

    // Apply mutation to crossChromosome.
    val newChromosome = mutation(crossChromosome)

    return Solution(newChromosome, getFitness(newChromosome))
}

fun mutation(crossChromosome: String): String {
    // A String object is immutable in Kotlin.
    // Create a char array whose elements can be modified.
    val chars = crossChromosome.toCharArray()
    for (i in 0 until chromosomeLength) {
        if ((0..1000).random() / 1000.0 <= MUTATION_THRESHOLD)
            chars[i] = VALID_GENES.random()
    }
    return String(chars)
}

fun main() {
    println("\n*** Text-matching using the genetic algorithm ***\n")
    println("Target string: $TARGET")
    println("Population size: $POP_SIZE, Generations: $MAX_GEN, " +
            "Chromosome length: $chromosomeLength")
    println("Mutation threshold: $MUTATION_THRESHOLD")

    initPopulation()
    runGA()
}
