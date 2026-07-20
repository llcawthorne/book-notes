/*
 * Encryption with the Hill Cipher
 *
 * The Hill Ciper devides the plaintext into blocks of fixed size and
 * represents them as vectors. These vectors are then multiplied by a square
 * matrix called the encryption key, module a specified number, to obtain
 * the ciphertext. For decryption, the ciphertext vectors are multiplied
 * by the inverse of the encryption key matrix, modulo the same specified
 * number.
 *
 * 1. First define the alphabet. It should include at least all 26 lowercase
 *    letters. We also choose to allow a period, a space, and a question
 *    mark. So the modulus should be the alphabet size of 29.
 * 2. Choose a block size. We will use three characters per block.
 * 3. We need an encryption key matrix. It should meet the following:
 *    a. The matrix must be square and have the same dimension as the
 *       block size chosen in two, so we need a 3x3 matrix.
 *    b. The determinant cannot be 0.
 *    c. The determinant must not share a factor other than 1 with the
 *       modulus from step 1.
 * 4. Divide the plaintext into blocks. If the last block isn't size 3,
 *    we will pad it with spaces to fill it out.
 * 5. Each block of plaintext must be converted into a numerical vector with
 *    the same length as the block size. The alphabet must be mapped to
 *    numbers. So a is 0, b is 1, etc. This way the block `cab` can become
 *    (2, 0, 1), a vector of size 3.
 * 6. Encrypt the message. For each block:
 *    a. Multiply the blocks plaintext vector by the key matrix, modulo 29.
 *    b. Convert the numerical values in the ciphertext vectors back to
 *       letters using the reverse mapping scheme
 *    c. Add the ciphered characters to a mutable list of characters.
 *
 * Decryption is similar but you multiple by the inverse of the encryption
 * key matrix. Note that it is customary to use an encryption key matrix of
 * only integers between 0 and the modulus.
 *
 */

// Declare the key matrix and its inverse. keyInv is based on mod 29.
val key = arrayOf(
    intArrayOf(13, 11, 6),
    intArrayOf(15, 21, 8),
    intArrayOf(5, 7, 9),
)

val keyInv = arrayOf(
    intArrayOf(1, 12, 8),
    intArrayOf(20, 0, 6),
    intArrayOf(0, 3, 20),
)

val dim = key.size
const val alphabet = "abcdefghijklmnopqrstuvwxyz .?"

data class Block(
    val t1: Char,
    val t2: Char,
    val t3: Char,
)

val indexVector = IntArray(dim)
val processedVector = IntArray(dim)
val blocks = mutableListOf<Block>()
val processedText = mutableListOf<Char>()

fun main() {
    println("\n*** Cryptography with Hill's Method ***\n")
    runValidation()
    println("\nEnter 1 for encryption or 2 for decryption:")

    when (val choice = readln().toInt()) {
        1 -> {
            println("You have chosen encryption\n")
            getText()
            encrypt()
            printProcessedText(choice)
        }

        2 -> {
            println("You have chosen decryption\n")
            getText()
            decrypt()
            printProcessedText(choice)
        }

        else -> println("\nInvalid choice...exiting program\n")
    }
}

fun runValidation() {
    println("key matrix dimension:")
    println("${key.size} x ${key[0].size}\n")

    // validation of key and keyInv
    val productMatrix = multiplyMatricesMod29(key, keyInv, r1=dim, c1=dim, c2=dim)
    displayProduct(productMatrix)
}

fun multiplyMatricesMod29(
    firstMatrix: Array<IntArray>,
    secondMatrix: Array<IntArray>,
    r1: Int,
    c1: Int,
    c2: Int,
): Array<IntArray> {
    val product = Array(r1) { IntArray(c2) }
    for (i in 0 until r1) {
        for (j in 0 until c2) {
            for (k in 0 until c1) {
                product[i][j] += (firstMatrix[i][k] * secondMatrix[k][j])
            }
            product[i][j] = product[i][j] % 29
        }
    }
    return product
}

fun displayProduct(product: Array<IntArray>) {
    println("[key * keyInv] mod 29 = ")
    for (row in product) {
        for (column in row) {
            print("$column   ")
        }
        println()
    }
}

fun getText() {
    println("Enter text for processing:")
    var text = readln().lowercase()
    val tmp = " " // Use a space for padding
    when(text.length % 3) {
        1 -> text = text + tmp + tmp
        2 -> text = text + tmp
    }
    for (i in text.indices step 3)
        blocks.add(Block(text[i], text[i+1], text[i+2]))
}

fun encrypt() {
    for (block in blocks) {
        getIndexBlock(block)
        encryptIndexBlock()
        addToProcessedText()
    }
}

fun decrypt() {
    for (block in blocks) {
        getIndexBlock(block)
        decryptIndexBlock()
        addToProcessedText()
    }
}

fun getIndexBlock(block: Block) {
    val (x, y, z) = block
    indexVector[0] = alphabet.indexOf(x)
    indexVector[1] = alphabet.indexOf(y)
    indexVector[2] = alphabet.indexOf(z)
}

fun encryptIndexBlock() {
    for (j in 0 until 3) {
        var sum = 0
        for (i in 0 until 3) {
            sum += indexVector[i] * key[i][j]
        }
        processedVector[j] = sum % 29
    }
}

fun decryptIndexBlock() {
    for (j in 0 until 3) {
        var sum = 0
        for (i in 0 until 3) {
            sum += indexVector[i] * keyInv[i][j]
        }
        processedVector[j] = sum % 29
    }
}

fun addToProcessedText() {
    processedVector.forEach { i ->
        processedText += alphabet[i]
    }
}

fun printProcessedText(choice: Int) {
    when (choice) {
        1 -> println("\nHere is the encrypted text:")
        2 -> println("\nHere is the decrypted text:")
    }
    print(processedText.joinToString(""))
}
