/*
 * High-Efficiency Sorting with Quick Sort
 *
 * Quick sort is a highly efficient in-place sorting algorith widely used
 * in real-world application. It involves selecting a pivot element from
 * the array and dividing the remaining elements into two subarrays, one
 * for values less than the pivot and the other for values greater than
 * the pivot. This places the pivot in the correct position in the final
 * sorted subarray, while the remaining elements end up on the appropriate
 * side of the pivot. This repeats recursively for the subarrays, selecting
 * new pivot elements and further portioning the array until everything is
 * sorted.
 *
 * Quick Sort is O(n^2) worst case but O(n log n) average case with space
 * complexity O(log n) but worst case O(n) and is unstable.
 *
 * We are going to pivot on the last element. For random data this is fine
 * but using the first or last element as pivot brings about the worst case
 * for already sorted or nearly sorted data. You could alternately make the
 * pivot a random element or the median of three to make the worst case not
 * happen for such a common situation.
 *
 */

fun main() {
    val arr = intArrayOf(8, 3, 4, 5, 1, 2)

    println("\n*** Sorting an Array Using Merge Sort ***\n")
    println("original array:\n${arr.contentToString()}")
    quickSort(arr, start = 0, end = arr.size - 1)
    println("\nsorted array:\n${arr.contentToString()}")
}

fun quickSort(
    arr: IntArray,
    start: Int,
    end: Int,
) {
    // base case is when start = end
    if (start < end) {
        val pivotIndex = partition(arr, start, end)
        quickSort(arr = arr, start = start, end = pivotIndex - 1)
        quickSort(arr = arr, start = pivotIndex + 1, end = end)
    }
}

fun partition(
    arr: IntArray,
    start: Int,
    end: Int,
): Int {
    val pivot = arr[end]
    var i = start

    for (j in start until end) {
        if (arr[j] < pivot) {
            swap(arr, i, j)
            i++
        }
    }
    swap(arr, i, end)
    return i
}

fun swap(
    arr: IntArray,
    i: Int,
    j: Int,
) {
    val temp = arr[i]
    arr[i] = arr[j]
    arr[j] = temp
}
