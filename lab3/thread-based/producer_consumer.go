package main

import (
	"fmt"
	"math/rand"
	"sync"
	"time"
)

const (
	bufferSize     = 10
	producerCount  = 3
	consumerCount  = 2
	maxProduce     = 3
	maxConsume     = 5
)

func producer(id int, buffer chan int, wg *sync.WaitGroup, mutex *sync.Mutex) {
	defer wg.Done()
	for i := 0; i < 5; i++ { // Each producer produces 5 times
		itemsToProduce := rand.Intn(maxProduce) + 1
		mutex.Lock()
		for j := 0; j < itemsToProduce; j++ {
			if len(buffer) < cap(buffer) {
				item := rand.Intn(100) // Random number as item
				buffer <- item
				fmt.Printf("Producer %d produced: %d\n", id, item)
			} else {
				fmt.Printf("Producer %d: Buffer full, skipping production\n", id)
				break
			}
		}
		mutex.Unlock()
		time.Sleep(time.Millisecond * 500) // Simulate production delay
	}
}

func consumer(id int, buffer chan int, wg *sync.WaitGroup, mutex *sync.Mutex) {
	defer wg.Done()
	for i := 0; i < 5; i++ { // Each consumer consumes 5 times
		itemsToConsume := rand.Intn(maxConsume) + 1
		mutex.Lock()
		for j := 0; j < itemsToConsume; j++ {
			if len(buffer) > 0 {
				item := <-buffer
				fmt.Printf("Consumer %d consumed: %d\n", id, item)
			} else {
				fmt.Printf("Consumer %d: Buffer empty, waiting for items\n", id)
				break
			}
		}
		mutex.Unlock()
		time.Sleep(time.Millisecond * 500) // Simulate consumption delay
	}
}

func main() {
	rand.Seed(time.Now().UnixNano())

	// Shared buffer channel
	buffer := make(chan int, bufferSize)

	// WaitGroup for synchronization
	var wg sync.WaitGroup

	// Mutex for critical section
	var mutex sync.Mutex

	// Start producers
	for i := 0; i < producerCount; i++ {
		wg.Add(1)
		go producer(i, buffer, &wg, &mutex)
	}

	// Start consumers
	for i := 0; i < consumerCount; i++ {
		wg.Add(1)
		go consumer(i, buffer, &wg, &mutex)
	}

	wg.Wait()
	fmt.Println("All producers and consumers have finished.")
}
