# Python Example Module

A complete example demonstrating LanManVan Python module structure and best practices.

## Features

- **Environment Variable Usage**: Demonstrates how to access `ARG_*` variables
- **Error Handling**: Shows proper exception handling and exit codes
- **Practical Functionality**: Basic network connectivity check
- **User Output**: Formatted console output for clarity

## Usage

```bash
# Using with default port
run python_example target=example.com

# With custom port
run python_example target=example.com port=443

# With timeout
run python_example target=example.com port=80 timeout=10
```

## Module Structure

- `module.yaml` - Module metadata and configuration
- `main.py` - Main Python script (entry point)
- `README.md` - This documentation file

## Key Concepts

1. **Arguments**: Passed as `ARG_<name>` environment variables
2. **Exit Codes**: 0 for success, 1 for failure
3. **Output Format**: Use `[+]` for success, `[!]` for errors, `[*]` for info
4. **Error Handling**: Always wrap code in try-except blocks
