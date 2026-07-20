/*
 * Faster Sorting with Merge Sort
 *
 * Merge sort divides an array into smaller subarrays until each subarray
 * contains one element, which is sorted by definition. Then it merges
 * subarrays back into longer arrays placing the elements in order in
 * the process, resulting in a fully ordered array.
 *
 * Merge sort time complexity is O(n log n), space complexity is O(n),
 * and it is a stable sorting algorithm.
 *
 */

fun main() {
    val arr = intArrayOf(8, 3, 4, 5, 1, 2)

    println("\n*** Sorting an Array Using Merge Sort ***\n")
    println("original array:\n${arr.contentToString()}")
    mergeSort(arr)
    println("\nsorted array:\n${arr.contentToString()}")
}

fun mergeSort(arr: IntArray) {
    val length = arr.size
    if (length < 2) return // done splitting subarrays

    val middle = length / 2
    val leftArray = arr.copyOfRange(0, middle)
    val rightArray = arr.copyOfRange(middle, length)

    mergeSort(leftArray)
    mergeSort(rightArray)
    merge(leftArray, rightArray, arr)
}

fun merge(
    leftArray: IntArray,
    rightArray: IntArray,
    arr: IntArray,
) {
    val leftSize = leftArray.size
    val rightSize = rightArray.size
    var i = 0 // for original array
    var l = 0 // for left array
    var r = 0 // for right array

    // Compare, sort, and merge
    while (l < leftSize && r < rightSize) {
        if (leftArray[l] < rightArray[r]) {
            arr[i] = leftArray[l]
            l++
        } else {
            arr[i] = rightArray[r]
            r++
        }
        i++
    }

    // At this point we have exhausted either leftArray or rightArray
    // Assign the remaining elements of the nonempty array to `arr`.
    while (l < leftSize) {
        arr[i] = leftArray[l]
        l++
        i++
    }

    while (r < rightSize) {
        arr[i] = rightArray[r]
        r++
        i++
    }
}
