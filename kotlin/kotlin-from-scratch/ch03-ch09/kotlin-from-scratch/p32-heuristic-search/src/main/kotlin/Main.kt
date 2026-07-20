/*
 * Heuristic Searching with A*
 *
 * The A* algorithm's heuristic is to consider both the cost or reaching a
 * specific node and an estimate of the remaining effort required to reach
 * the destination so as to prioritize the most promising paths. This helps
 * save time and effort in the search process. Due to its versatility, A*
 * is frequently applied in fields such as pathfinding in video games,
 * robotics, navigation systems, and various optimization problems.
 *
 * Since A* is best at finded the shortest path between two points, it is
 * best suited for working with weighted graphs.
 *
 * We are going to seek the shortest path from A (the start) to J (the target).
 * A* will calculate a *g-score*, the actual cost of traveling from the start
 * node to the current node and an *h-score*, the estimated or heuristic cost
 * of traveling from the current node to the target node. Added together,
 * these give the *f-score*, the estimated total cost of the path.
 *
 * For A* to work, we need a good heuristic function. An *admissible* heuristic
 * function for A* is a functin that never overestimates the cost of reaching
 * the goal from any node. With an admissable set of h-cores, A* is guaranteed
 * to find the least costly path. The algorithms performance depends on how
 * close the h-scores are to the true costs. The more accurate the h-scores,
 * the faster the algorithm will find the optimal path. A *consistent*
 * function is one such that the cost of reaching the goal from a node is
 * always less than or equal to the cost of reaching the goal from any
 * neighbor of that node plus the cost of moving to that neighbor. Consistency
 * implies admissibility but not vice versa. Consistency will make the A*
 * algorithm more efficient.
 *
 * Choosing a heuristic can be complicated. Some examples use using the
 * Euclidean distance for pathfinding ignoring any obstacles or chosing to
 * abstract a navigation problem by representing cities as nodes and major
 * highways as edges while ignoring side roads. For our example code our
 * heuristic is going to be that all edges in the graph have the same weight
 * where that weight is the lowest actual weight in the graph.
 *
 * The time complexity of A* depends on the nature of the problem and the
 * quality of the heurstic function used. Worst case time is O(b^d) where `b`
 * is the branching factor (the average number of edges per node) and `d` is
 * the depth of the shallowest target node (the minimum number of edges needed
 * to reach the target from the starting node). The space complexity varies by
 * data structures used for open/closed list but is also O(b^d) worst case.
 * However, A*'s best case is O(d).
 *
 */

data class Node(
    var gScore: Int,
    var fScore: Int,
    var previousNode: String,
)

fun main() {
    val graph =
        mapOf(
            "A" to mapOf("B" to 4, "C" to 6, "D" to 5),
            "B" to mapOf("A" to 4, "C" to 2, "E" to 4, "F" to 4),
            "C" to mapOf("A" to 6, "B" to 2, "D" to 3, "F" to 3),
            "D" to mapOf("A" to 5, "C" to 3, "G" to 6, "H" to 4),
            "E" to mapOf("B" to 4, "I" to 6),
            "F" to mapOf("B" to 4, "C" to 3, "G" to 4, "I" to 5),
            "G" to mapOf("D" to 6, "F" to 4, "I" to 6, "K" to 3),
            "H" to mapOf("D" to 4, "K" to 3),
            "I" to mapOf("E" to 6, "F" to 5, "G" to 6, "J" to 6),
            "J" to mapOf("I" to 6, "K" to 5),
            "K" to mapOf("G" to 3, "H" to 3, "J" to 5, "L" to 3),
            "L" to mapOf("K" to 3, "M" to 5),
            "M" to mapOf("L" to 5),
        )

    println("### A* algorithm ###")
    println("\nDisplay graph:")
    displayGraph(graph)

    val startNode = "A"
    val targetNode = "J"
    val visitedList = aStar(graph, startNode, targetNode)

    println("\n--- Final Visited List ---")
    displayList(visitedList)
    displayShortestPath(visitedList, startNode, targetNode)
}

fun displayGraph(graph: Map<String, Map<String, Int>>) {
    for ((node, neighbors) in graph) {
        println("Node: $node")
        print("Neighbors: ")

        for ((nNode, cost) in neighbors) {
            print("$nNode:$cost ")
        }
        println()
    }
    println()
}

fun displayList(mapList: Map<String, Node>) {
    println("   (g-score, f-score, previous)")

    for ((node, attributes) in mapList) {
        println("$node: $attributes")
    }
    println()
}

fun displayShortestPath(
    visited: Map<String, Node>,
    startNode: String,
    targetNode: String,
) {
    var currentNode = targetNode
    var path = targetNode
    println("path initialized from target: $path")

    while (currentNode != startNode) {
        val previousNode = visited[currentNode]!!.previousNode
        // previousNode is placed before `path` so no need to reorder.
        path = previousNode + path
        println("previousNode: $previousNode")
        println("path updated: $path")
        currentNode = previousNode
    }

    val cost = visited[targetNode]!!.gScore
    println("\nThe shortest path from $startNode to $targetNode is:")
    println("Path: $path")
    println("Cost: $cost")
}

fun aStar(
    graph: Map<String, Map<String, Int>>,
    startNode: String,
    targetNode: String,
): Map<String, Node> {
    val visited = mutableMapOf<String, Node>()
    val unvisited = mutableMapOf<String, Node>()

    // Initialize all unvisited nodes.
    for (node in graph.keys) {
        // The list is made of g-score, f-score, and previous node.
        unvisited[node] = Node(Int.MAX_VALUE, Int.MAX_VALUE, "none")
    }

    // Update the start node attributes in the unvisited list.
    val hScore = getHScore(startNode)

    // for startNode: g-score = 0, f-score = 10, previous node = none
    unvisited[startNode] = Node(0, hScore, "none")

    println("--- Initialized starte of unvisited list ---")
    displayList(unvisited)

    while (unvisited.isNotEmpty()) {
        // Set the node with minimum f-score to current node.
        val currentNode = getCurrentNode(unvisited)

        if (currentNode == targetNode) {
            // Add the targetNode to visisted.
            visited[currentNode] = unvisited[currentNode]!!
            println("--- Target node:$currentNode reached ---")
            break
        }

        val neighbors = graph[currentNode]!!

        for (node in neighbors.keys) {
            if (node !in visited) {
                val newGScore = unvisited[currentNode]!!.gScore + neighbors[node]!!

                if (newGScore < unvisited[node]!!.gScore) {
                    unvisited[node] =
                        Node(
                            newGScore,
                            newGScore + getHScore(node),
                            currentNode,
                        )
                }
            }
        }
        // Add currentNode to visited and remove from unvisited.
        visited[currentNode] = unvisited[currentNode]!!
        unvisited.remove(currentNode)
    }
    return visited
}

fun getHScore(node: String) =
    when (node) {
        "A" -> 8

        "B" -> 6

        "C" -> 6

        "D" -> 6

        "E" -> 4

        "F" -> 4

        "G" -> 4

        "H" -> 4

        "I" -> 2

        // target node
        "J" -> 0

        "K" -> 2

        "L" -> 4

        "M" -> 6

        else -> 0
    }

fun getCurrentNode(unvisited: Map<String, Node>) = unvisited.minByOrNull { it.value.fScore }!!.key
