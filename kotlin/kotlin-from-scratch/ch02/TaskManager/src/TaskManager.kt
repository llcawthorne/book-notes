import java.io.File
import java.util.Scanner

// macro view of the task manager program

data class Task(
    val title: String,
    val description: String,
    var status: String = "not done",
)

class TaskManager {
    val taskList = mutableListOf<Task>()

    fun addTask(task: Task) {
        taskList.add(task)
    }

    fun listTasks() {
        if (taskList.size > 0) {
            println("\nTasks:")
            for ((index, task) in taskList.withIndex()) {
                println(
                    "${index + 1}. ${task.title} - " +
                        "${task.description} - ${task.status}",
                )
            }
        } else {
            println("Task list is empty.")
        }
    }

    fun markTaskAsDone(taskIndex: Int) {
        if (taskIndex in taskList.indices) {
            taskList[taskIndex].status = "done"
        } else {
            println("Invalid task index. Task not found.")
        }
    }

    fun deleteTask(taskIndex: Int) {
        if (taskIndex in taskList.indices) {
            taskList.removeAt(taskIndex)
        } else {
            println("Invalid task index. Task not found.")
        }
    }

    fun saveTaskList() {
        val filename = "tasklist.txt"

        val outputFile = File(filename)

        // Write all lines to the output file.
        for ((name, description, doneStatus) in taskList) {
            outputFile.appendText("$name,$description,$doneStatus\n")
        }

        println("Task list saved, Bro!")
    }

    fun loadTaskList() {
        // Replace the path below with the path to your file.
        val inputFile = "tasklist.txt"

        try {
            val file = File(inputFile)
            val sc = Scanner(file)
            while (sc.hasNextLine()) {
                val line = sc.nextLine()
                val lineparts = line.split(",")
                if (lineparts.size == 3)
                    addTask(Task(lineparts[0], lineparts[1], lineparts[2]))
                else
                    println("Invalid line in save file.")
            }
            println("Task list loaded, Bro!")
        } catch (e: Exception) {
            println("An error occurred: ${e.message}")
        }
    }
}

fun printOptions() {
    println("\nTask Manager Menu:")
    println("1. Add Task")
    println("2. List Tasks")
    println("3. Mark Task as done")
    println("4. Delete Task")
    println("5. Exit")
    println("6. Save Task List")
    println("7. Load Task List")
    print("Enter your choice (1-7): ")
}

fun readIndex(taskListSize: Int): Int? {
    val input = readln()
    if (input.isBlank()) {
        println("Invalid input. Please enter a valid task number.")
        return null
    }

    val taskNumber = input.toIntOrNull()
    if (taskNumber != null && taskNumber >= 1 &&
        taskNumber <= taskListSize
    ) {
        return taskNumber
    } else {
        println("Invalid task number. Please enter a valid task number.")
        return null
    }
}

fun main() {
    val taskManager = TaskManager()

    while (true) {
        printOptions()
        when (readln()) {
            "1" -> {
                print("\nEnter task title: ")
                val title = readln()
                print("Enter task description: ")
                val description = readln()
                val task = Task(title, description)
                taskManager.addTask(task)
            }

            "2" -> {
                taskManager.listTasks()
            }

            "3" -> {
                taskManager.listTasks()
                if (taskManager.taskList.size <= 0) {
                    continue
                } else {
                    print("\nEnter the task number to mark as done: ")
                    val taskNumber = readIndex(taskManager.taskList.size)
                    if (taskNumber != null) {
                        taskManager.markTaskAsDone(taskNumber - 1)
                    }
                }
            }

            "4" -> {
                taskManager.listTasks()
                if (taskManager.taskList.size <= 0) {
                    continue
                } else {
                    print("\nEnter the task number to be deleted: ")
                    val taskNumber = readIndex(taskManager.taskList.size)
                    if (taskNumber != null) {
                        taskManager.deleteTask(taskNumber - 1)
                    }
                }
            }

            "5" -> {
                return // breaks the while loop
            }

            "6" -> {
                taskManager.saveTaskList()
            }

            "7" -> {
                taskManager.loadTaskList()
            }

            else -> {
                println("\nInvalid choice. Please try again.")
            }
        }
    }
}
