package main


func greeting(myChannel chan string) {
	myChannel <- "hi"
}

func main() {
	myChannel := make(chan string)
	go greeting(myChannel)
}
