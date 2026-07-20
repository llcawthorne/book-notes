/*
 * Space-Efficient Sorting with Insertion Sort
 *
 * Insertion sort is the slowest of the sorts we will be studying at O(n^2)
 * but it is easy to understand, stable, and uses O(1) space. It builds a
 * sorted array one element at a time. It maintains a sorted subarray within
 * the given array and extends it by inserting elements from the unsorted
 * part of the array in the correct position of the sorted part. You initially
 * start with one element sorted, because one element by itself is always in
 * order and iterate through elements inserting each into their correct
 * position. To insert an element into position, the algorithm compares it
 * with the elements in the sorted subarray from right to left. It shifts
 * any larger elements one position to the right until it finds the correct
 * position for the current element. Once the correct position is found, the
 * element is inserted into that position. This continues until all elements
 * are sorted.
 *
 * Example [8, 3, 4, 5, 1, 2]
 * 1) [8] is sorted.
 * 2) Compare 3 to 8, since 3 is smaller swap the elements. [3, 8] is sorted.
 * 3) a. Compare 4 with 8. Since 4 is smaller swap the elements.
 *    b. Compare 4 with 3. Since 4 is larger stop comparing.
 *    c. [3, 4, 8] is sorted.
 * 4) Repeat the process until all elements are sorted.
 *
 * Insertion sort is sometimes used to finish a sort since it performs well
 * for small list or nearly sorted lisit and is an in-place sorting algorithm.
 *
 */

fun main() {
    val arr = intArrayOf(8, 3, 4, 5, 1, 2)

    println("\n*** Sorting an Array Using Insertino Sort ***\n")
    println("original array:\n${arr.contentToString()}")
    insertionSort(arr)
    println("sorted array:\n${arr.contentToString()}")
}

fun insertionSort(A: IntArray) {
    for (i in 1 until A.size) {
        val key = A[i]
        var j = i
        while (j > 0 && A[j - 1] > key) {
            A[j] = A[j - 1]
            j -= 1
        }
        A[j] = key
    }
}
