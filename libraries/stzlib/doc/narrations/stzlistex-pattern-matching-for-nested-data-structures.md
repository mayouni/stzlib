# Softanza ListEx: Pattern Matching for Nested Data Structures

Pattern matching has revolutionized data validation and manipulation across various programming paradigms. While traditional regex excels at string matching, structured data—especially deeply nested lists—requires a more expressive and intuitive approach. Enter **List Regex (Lx)**, a Softanza-powered pattern-matching engine that brings the power of regex-style matching to structured data.

## Why List Regex?

Validating and transforming hierarchical data structures in programming often involves verbose conditional logic. Existing solutions—whether in Python, JSON Schema, or TypeScript interfaces—offer static validation but lack the elegance of regex-like expressiveness for lists. List Regex introduces:

- **Concise, readable patterns** for structured data
- **Regex-inspired syntax** adapted for list validation
- **Powerful quantifiers and negation** to match complex structures

### A Simple Example

```ring
Lx("[@N, @S]").Match([42, "hello"]) #--> TRUE
```

Here, `@N` matches any number, and `@S` matches any string. The pattern ensures that a number appears first, followed by a string, making validation simple and intuitive.

## Core Concepts

### Type Patterns
Lx defines fundamental type patterns for structured validation:

- `@N` - Matches any number (integer, float, scientific notation)
- `@S` - Matches any string (single or double-quoted)
- `@L` - Matches lists, from simple arrays to deeply nested structures
- `@A` - Matches any type (wildcard)

```ring
# Match a number followed by any value
Lx("[@N, @A]").Match([42, "string"]) #--> TRUE
Lx("[@N, @A]").Match([42, [1,2,3]]) #--> TRUE
```

### Smart Quantifiers
Just like regex, List Regex provides powerful quantifiers:

- `@N+` - One or more numbers
- `@S*` - Zero or more strings
- `@L?` - Optional list
- `@N{4,5,6}` - Specific enumerated values
- `@N1-3` - Range quantifier (1 to 3 occurrences)

```ring
# Match 1-3 numbers followed by a string
Lx("[@N1-3, @S]").Match([1, 2, "end"]) #--> TRUE
```

### Negation Patterns
Negation provides additional flexibility:

```ring
# Match anything except a number
Lx("[@!N]").Match(["string"]) #--> TRUE
Lx("[@!N]").Match([[1,2,3]]) #--> TRUE
```

### Advanced Matching

List Regex extends traditional regex concepts to structured data:

- **Lookahead/lookbehind:** `@N(?=@S)` (match a number followed by a string)
- **Alternation:** `(@N|@S)` (match either a number or a string)
- **Named captures:** `(?<values>@N+)`
- **Reluctant/possessive quantifiers:** `@N+?` (lazy match), `@N++` (greedy match)
- **Step-based range:** `@N{1-10:2}` (matches odd/even sequences)

## Real-World Applications

### 1. Configuration Validation

```ring
# Validate config entries with flexible types
pattern = "[@S, @A, @L?]"
Lx(pattern).Match(["port", 8080, ["tcp", "udp"]]) #--> TRUE
```

### 2. Data Pipeline Processing

```ring
# Validate CSV-like data with optional fields
pattern = "[@S, @N+, @S*]"
Lx(pattern).Match(["Product", 100, 29.99, "In Stock"]) #--> TRUE
```

### 3. API Payload Validation

```ring
# Validate a nested API response structure
pattern = "[@S, @L, @N{1,2,3}]"
Lx(pattern).Match(["user", ["admin", "read"], 2]) #--> TRUE
```

## Performance Considerations

List Regex optimizes pattern matching through:

- **Efficient backtracking avoidance** for performance gains
- **Recursive matching only when necessary** to handle deep nesting
- **Specialized matchers** for common patterns to accelerate execution

Compared to Python’s manual type-checking approach:

```python
def validate(data):
    return (isinstance(data, list) and
            len(data) >= 2 and
            isinstance(data[0], str) and
            isinstance(data[1], (int, float)))
```

List Regex simplifies the same validation into:

```ring
Lx("[@S, @N]").Match(data) #--> Simple and expressive
```

## The Future of Pattern Matching

As pattern matching evolves in languages like Rust and JavaScript, List Regex brings this power to hierarchical data structures with an intuitive, regex-like syntax. Its ability to **dynamically validate nested lists** without verbose conditions makes it a game-changer in structured data processing.