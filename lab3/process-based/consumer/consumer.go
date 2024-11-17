package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
)

func main() {
	// Open the named pipe for reading
	pipe, err := os.OpenFile("/tmp/producer_consumer_pipe", os.O_RDONLY, os.ModeNamedPipe)
	if err != nil {
		panic(err)
	}
	defer pipe.Close()

	scanner := bufio.NewScanner(pipe)
	for scanner.Scan() {
		item, _ := strconv.Atoi(scanner.Text())
		fmt.Printf("Consumer consumed: %d\n", item)
	}
}
