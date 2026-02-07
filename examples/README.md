# LanManVan Module Examples

This directory contains example modules demonstrating how to create modules in all supported LanManVan languages.

## Quick Start

Copy any example module to your modules directory and use it:

```bash
# List available examples
ls -la examples/

# Copy an example to your modules
cp -r examples/python_example ~/lanmanvan/modules/my_python_module

# Use it in LanManVan CLI
lmv
> use my_python_module
> run target=example.com
```

## Supported Languages

### 1. Python 🐍

**Module**: `python_example`

Features:
- Environment variable handling
- Network operations (socket connections)
- Exception handling with specific error messages
- Input validation

**Quick Run**:
```bash
run python_example target=google.com port=443
```

**File**: [python_example/main.py](python_example/main.py)

---

### 2. Bash 🐚

**Module**: `bash_example`

Features:
- Array parsing (comma-separated values)
- Loops and iteration
- External command execution (ping)
- Error handling with exit codes

**Quick Run**:
```bash
run bash_example hosts=google.com,github.com count=3
```

**File**: [bash_example/main.sh](bash_example/main.sh)

---

### 3. Ruby 💎

**Module**: `ruby_example`

Features:
- Pattern matching (case/when)
- Regular expressions
- String manipulation
- Array methods and iteration
- Exception handling

**Quick Run**:
```bash
run ruby_example text="Hello World" action=count
run ruby_example text="john@example.com" action=find_emails
```

**File**: [ruby_example/main.rb](ruby_example/main.rb)

---

### 4. Go 🔧

**Module**: `go_example`

Features:
- Goroutines (concurrent processing)
- Type-safe structs
- WaitGroup synchronization
- Time handling and performance measurement

**Manual Build & Run**:
```bash
cd examples/go_example
go build -o main main.go
ARG_ITERATIONS=5 ./main
```

**File**: [go_example/main.go](go_example/main.go)

---

## Module Structure

Every module should have:

### 1. **module.yaml** - Metadata file

```yaml
name: module_name
description: "Module description"
type: python|bash|ruby|go
author: Your Name
version: 1.0.0
tags:
  - tag1
  - tag2
options:
  arg_name:
    type: string
    description: Argument description
    required: true
required:
  - arg_name
```

### 2. **main.*** - Entry point script

- `main.py` for Python modules
- `main.sh` for Bash modules
- `main.rb` for Ruby modules
- `main.go` for Go modules

### 3. **README.md** - Documentation (optional but recommended)

---

## Accessing Arguments

All arguments are passed as environment variables with the `ARG_` prefix:

### Python
```python
import os
target = os.getenv('ARG_TARGET', 'localhost')
```

### Bash
```bash
TARGET="${ARG_TARGET:-localhost}"
```

### Ruby
```ruby
target = ENV['ARG_TARGET'] || 'localhost'
```

### Go
```go
target := os.Getenv("ARG_TARGET")
```

---

## Common Patterns

### Exit Codes

- **0** = Success
- **1** = Error/Failure

```python
sys.exit(0)  # Python
exit 0       # Bash
exit 1       # Ruby
os.Exit(0)   # Go
```

### Output Format

Use consistent prefixes for clarity:

```
[+] = Success
[-] = Failure
[*] = Information
[!] = Error
```

### Error Handling

**Python**:
```python
try:
    # code
except Exception as e:
    print(f"[!] Error: {e}")
    sys.exit(1)
```

**Bash**:
```bash
set -e  # Exit on error
if ! command; then
    echo "[!] Error: description"
    exit 1
fi
```

**Ruby**:
```ruby
begin
  # code
rescue => e
  puts "[!] Error: #{e.message}"
  exit 1
end
```

---

## Creating Your Own Module

### Step 1: Use LanManVan CLI

```bash
lmv -modules ~/lanmanvan/modules
> create my_module python
```

### Step 2: Edit module.yaml

Add your arguments and requirements:

```yaml
name: my_module
description: "What does my module do?"
type: python
options:
  target:
    type: string
    description: Target to process
    required: true
required:
  - target
```

### Step 3: Implement main.*

Write your logic following the patterns in the examples.

### Step 4: Test

```bash
> use my_module
> run target=example.com
```

---

## Best Practices

1. **Always validate inputs** before using arguments
2. **Use meaningful error messages** - helps users debug
3. **Include comments** - explain your code
4. **Test with various inputs** - edge cases matter
5. **Document your module** - add README.md
6. **Use consistent output formatting** - [+], [-], [*], [!]
7. **Handle timeouts** - don't let modules hang
8. **Exit with proper codes** - 0 for success, 1 for failure

---

## Tips and Tricks

### Python: Argument validation
```python
if not os.getenv('ARG_TARGET'):
    print("[!] Error: TARGET is required")
    sys.exit(1)
```

### Bash: Parsing comma-separated values
```bash
IFS=',' read -ra ARRAY <<< "$ARG_HOSTS"
for host in "${ARRAY[@]}"; do
    echo "Processing: $host"
done
```

### Ruby: Using regex for parsing
```ruby
emails = text.scan(/[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}/)
emails.each { |email| puts "[+] #{email}" }
```

### Go: Concurrent processing
```go
var wg sync.WaitGroup
for i := 0; i < count; i++ {
    wg.Add(1)
    go func(id int) {
        defer wg.Done()
        // Do work
    }(i)
}
wg.Wait()
```

---

## Troubleshooting

### Module not found
- Ensure `module.yaml` exists in the module directory
- Check that the module directory is in the correct path

### Script not executing
- Verify the correct main file exists (`main.py`, `main.sh`, `main.rb`, `main.go`)
- Check file permissions (should be executable): `chmod +x main.sh`
- Verify the shebang line is correct

### Arguments not working
- Ensure arguments are required in `module.yaml`
- Use `ARG_<NAME>` format (uppercase)
- Check environment variable is being set

### Python: ModuleNotFoundError
- Install required packages: `pip install <package>`
- Modules run from their own directory

---

## Support & Feedback

For issues or suggestions, please refer to the main LanManVan documentation.

Happy module development! 🚀
