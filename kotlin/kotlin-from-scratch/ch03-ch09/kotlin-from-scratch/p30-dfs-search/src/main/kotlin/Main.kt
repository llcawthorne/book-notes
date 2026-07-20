/*
 * Stack-Based Search with Depth-First Search
 *
 * DFS starts at a particular node and explores as deep as possible
 * along one branch before backtracking and exploring the next. It is
 * often implemented with a stack data structure. It is useful in many
 * applications, including scheduling problems, detecting cycles in
 * graphs, and solving puzzles with only one solution such as a maze
 * or a sudoku puzzle. Step by step it goes:
 *
 * 1. Start by selecting any node as the starting node.
 * 2. Push the starting node onto the stack.
 * 3. While the stack is not empty, pop a node from the stack.
 * 4. If the popped node is not yet visited, mark it as visited and
 *    push all its neighbors to the stack; or else pop the next node
 *    from the stack.
 * 5. Repeat steps 3 and 4 until the stack is empty.
 *
 * Because a stack follows the LIFO principle, the DFS algorithm is able
 * to backtrack from the end of one branch before starting on a new,
 * unvisited branch. This ensures exhaustive search of the entire graph.
 *
 * The time complexity of the DFS algorithm is O(V + E) and the worst case
 * space complexity is O(V).
 *
 */
import java.util.ArrayDeque

fun main() {
    val graph =
        mapOf(
            "0" to setOf("1", "2", "3"),
            "1" to setOf("0", "2"),
            "2" to setOf("0", "1", "4"),
            "3" to setOf("0"),
            "4" to setOf("2"),
        )
    println("\n*** Depth-First Search of a Graph ***\n")
    println("Graph to search:")
    for ((key, value) in graph) {
        println("Node: $key,  Neighbors: $value")
    }

    val visited = dfsStack(graph, "0")
    println("\nVisited nodes:\n$visited")
}

fun dfsStack(
    graph: Map<
        String,
        Set<String>,
    >,
    start: String,
): Set<String> {
    val visited = mutableSetOf<String>()
    val stack = ArrayDeque<String>()
    stack.push(start)

    while (stack.isNotEmpty()) {
        val node = stack.pop()
        if (node !in visited) {
            // Do something as needed.
            visited.add(node)
            for (next in graph[node]!!) {
                stack.push(next)
            }
        }
    }
    return visited
}
