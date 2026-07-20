/*
 * Queue-Based Searching with Breadth-First Search
 *
 * We are going to implement BFS using a Queue. It explores the data structure
 * level by level starting at a given node and visiting all its immediate
 * neighbors, and so on. It's useful for finding the shorest path, web crawling
 * analyzing social networks, and exploring all reachable nodes in a graph
 * while using the smallest number of iterations. Step by step:
 *
 * 1. Select any node as the starting node.
 * 2. Create a mutable list called `visited` and add the starting node.
 * 3. Create and empty queue and enqueue the starting node.
 * 4. While the queue is not empty perform the following steps:
 *    a. Dequeue the front node from the queue.
 *    b. Process the dequeued node as needed.
 *    c. Enqueue all the unvisted neighbors of the dequeued node and mark
 *       them as visited.
 *
 * Time complexity of BFS is O(V + E) and space complexity is typically O(V).
 * Both DFS and BFS have the same time complexity, but there space complexity
 * can vary by implementation and structure of the graph.
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
    println("\n*** Breadth-First Search of a Graph ***\n")
    println("Graph to search:")
    for ((key, value) in graph) {
        println("Node: $key,  Neighbors: $value")
    }

    val visited = bfsQueue(graph, "0")
    println("\nVisited nodes:\n$visited")
}

fun bfsQueue(
    graph: Map<
        String,
        Set<String>,
    >,
    start: String,
): Set<String> {
    val visited = mutableSetOf<String>()
    visited.add(start)
    val queue = ArrayDeque<String>()
    queue.offer(start)

    while (queue.isNotEmpty()) {
        val node = queue.poll()
        // Do something with the node here
        for (next in graph[node]!!) {
            if (next !in visited) {
                queue.offer(next)
                visited.add(next)
            }
        }
    }
    return visited
}
