package main

import (
	"fmt"
	"os"
	"strconv"
	"sync"
	"time"
)

// DataPoint represents a simple data structure
type DataPoint struct {
	ID        int
	Timestamp time.Time
	Value     int
}

// ProcessData simulates processing with goroutines
func ProcessData(id int, wg *sync.WaitGroup) {
	defer wg.Done()

	data := DataPoint{
		ID:        id,
		Timestamp: time.Now(),
		Value:     id * 100,
	}

	fmt.Printf("[+] Processing: ID=%d, Value=%d, Time=%s\n",
		data.ID, data.Value, data.Timestamp.Format("15:04:05"))

	time.Sleep(time.Millisecond * 100)
}

func main() {
	// Get arguments from environment variables
	iterStr := os.Getenv("ARG_ITERATIONS")
	message := os.Getenv("ARG_MESSAGE")

	iterations := 3
	if iterStr != "" {
		if n, err := strconv.Atoi(iterStr); err == nil && n > 0 {
			iterations = n
		}
	}

	if message == "" {
		message = "Go Example Module"
	}

	fmt.Println()
	fmt.Println("[*] " + message)
	fmt.Printf("[*] Running %d iterations with concurrent processing\n", iterations)
	fmt.Println()

	// Demonstrate concurrent processing
	var wg sync.WaitGroup

	start := time.Now()

	for i := 1; i <= iterations; i++ {
		wg.Add(1)
		go ProcessData(i, &wg)
	}

	wg.Wait()

	duration := time.Since(start)

	fmt.Println()
	fmt.Printf("[*] Completed in %v\n", duration)
	fmt.Println("[+] Go module example executed successfully!")
	fmt.Println()
}
