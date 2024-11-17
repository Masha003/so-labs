package main

import (
	"fmt"
	"math/rand"
	"os"
	"time"
)

func main() {
	rand.Seed(time.Now().UnixNano())

	// Open the named pipe for writing
	pipe, err := os.OpenFile("/tmp/producer_consumer_pipe", os.O_WRONLY, os.ModeNamedPipe)
	if err != nil {
		panic(err)
	}
	defer pipe.Close()

	for i := 0; i < 5; i++ { // Produce 5 times
		itemsToProduce := rand.Intn(3) + 1
		for j := 0; j < itemsToProduce; j++ {
			item := rand.Intn(100)
			fmt.Fprintf(pipe, "%d\n", item) // Write to the pipe
			fmt.Printf("Producer produced: %d\n", item)
		}
		time.Sleep(time.Second) // Simulate delay
	}
}
