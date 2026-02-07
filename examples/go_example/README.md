# Go Example Module

An educational example demonstrating Go module structure and capabilities.

## Features

- **Goroutines**: Concurrent processing demonstration
- **Type Safety**: Struct definitions and type safety
- **Synchronization**: Using `sync.WaitGroup` for coordination
- **Time Handling**: Timestamp creation and duration calculation
- **Environment Variables**: Reading and parsing arguments
- **String Formatting**: Printf-style output

## Usage

Note: Go module execution needs to be built and run manually.

```bash
# Build the module
go build -o main ./examples/go_example/main.go

# Run with default parameters
./main

# Run with custom iterations
ARG_ITERATIONS=5 ./main

# Run with custom message
ARG_MESSAGE="Custom Go Module" ./main

# Both parameters
ARG_ITERATIONS=10 ARG_MESSAGE="Concurrent Processing Demo" ./main
```

## Module Structure

- `module.yaml` - Module metadata and configuration
- `main.go` - Main Go program (entry point)
- `README.md` - This documentation file

## Key Concepts

1. **Goroutines**: Lightweight concurrency with `go` keyword
2. **WaitGroup**: Synchronization primitive for goroutine coordination
3. **Structs**: Type-safe data structures
4. **Environment Variables**: Via `os.Getenv()`
5. **Type Conversion**: `strconv.Atoi()` for string to int
6. **Time Handling**: `time.Now()`, `time.Since()`, formatting
7. **Concurrent Output**: Safe println operations

## Building and Running

Go modules require compilation before execution:

```bash
cd examples/go_example
go build -o main main.go
./main
```
