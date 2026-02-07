# Ruby Example Module

A feature-rich example demonstrating LanManVan Ruby module capabilities.

## Features

- **Pattern Matching**: Case/when statements for action selection
- **Regular Expressions**: Email extraction using regex
- **String Operations**: Reverse, uppercase, and text analysis
- **Array Methods**: Using `map`, `uniq`, and iteration
- **Error Handling**: Exception handling with proper messages
- **Functional Programming**: Ruby's elegant approach to data processing

## Usage

```bash
# Text analysis (character/word/line count)
run ruby_example text="Hello World"

# Reverse text
run ruby_example text="Hello" action=reverse

# Uppercase conversion
run ruby_example text="hello world" action=uppercase

# Find email addresses
run ruby_example text="Contact me at john@example.com or jane@test.org" action=find_emails

# Find unique words
run ruby_example text="the quick brown fox jumps over the lazy dog" action=unique_words
```

## Module Structure

- `module.yaml` - Module metadata and configuration
- `main.rb` - Main Ruby script (entry point)
- `README.md` - This documentation file

## Key Concepts

1. **Environment Access**: Using `ENV['ARG_<name>']`
2. **Pattern Matching**: Ruby's case/when for elegant conditionals
3. **String Methods**: `reverse`, `upcase`, `split`, `lines`
4. **Regular Expressions**: Pattern matching with `/pattern/`
5. **Array Operations**: `map`, `uniq`, `each`, `scan`
6. **Error Handling**: Generic exception catching with `=> e`
