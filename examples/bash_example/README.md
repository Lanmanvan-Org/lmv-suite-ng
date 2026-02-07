# Bash Example Module

A practical example showing LanManVan Bash module structure and best practices.

## Features

- **Array Handling**: Demonstrates parsing comma-separated values
- **Loops**: Shows how to iterate over multiple items
- **System Calls**: Examples of executing external commands
- **Error Handling**: Proper error checking and exit codes
- **Conditional Logic**: If-else statements for validation

## Usage

```bash
# Single host
run bash_example hosts=google.com

# Multiple hosts
run bash_example hosts=google.com,github.com,example.com

# Custom ping count
run bash_example hosts=google.com count=5

# Verbose output
run bash_example hosts=google.com count=2 verbose=true
```

## Module Structure

- `module.yaml` - Module metadata and configuration
- `main.sh` - Main shell script (entry point)
- `README.md` - This documentation file

## Key Concepts

1. **Bash Shebang**: `#!/bin/bash` for portability
2. **Environment Variables**: Access via `${ARG_<name>}` with defaults
3. **Array Processing**: Using `IFS` to split strings
4. **Error Handling**: `set -e` to exit on error
5. **Output Format**: Consistent messaging pattern
