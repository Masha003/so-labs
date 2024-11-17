package main

import (
	"fmt"
	"math/rand"
	"os"
	"os/signal"
	"syscall"
	"time"
)
func generateRandomASCII(n int) string {
	const asciiStart = 32 // Space character
	const asciiEnd = 126  // '~' character

	// Create a new random generator with its own source
	r := rand.New(rand.NewSource(time.Now().UnixNano()))

	randomChars := make([]byte, n)
	for i := 0; i < n; i++ {
		randomChars[i] = byte(r.Intn(asciiEnd-asciiStart+1) + asciiStart)
	}
	return string(randomChars)
}

func main() {
	// Create a channel to capture OS signals
	signalChan := make(chan os.Signal, 1)

	// Notify for SIGUSR1 and SIGUSR2
	signal.Notify(signalChan, syscall.SIGUSR1, syscall.SIGUSR2)

	fmt.Println("Program is running. Send SIGUSR1 or SIGUSR2 signals to interact.")

	for {
		sig := <-signalChan // Block until a signal is received
		switch sig {
		case syscall.SIGUSR1:
			fmt.Println("Received SIGUSR1")

		case syscall.SIGUSR2:
			fmt.Println("Received SIGUSR2")
			randomASCII := generateRandomASCII(100)
			fmt.Println("Random ASCII Characters:", randomASCII)
			fmt.Println("Terminating program.")
			os.Exit(0)
		}
	}
}
