# Softanza ListEx: Bringing Pattern Matching to Lists

Pattern matching has revolutionized data validation and manipulation across various programming paradigms. While traditional regex excels at string matching, structured data—especially deeply nested lists—requires a more expressive approach. Enter **List Regex (Lx)**, a Softanza-powered pattern-matching engine that brings regex-style matching to structured data.

## Why List Regex?

Validating and transforming hierarchical data structures often involves verbose conditional logic. Existing solutions—whether in Python, JSON Schema, or TypeScript interfaces—offer static validation but lack the elegance of regex-like expressiveness for lists. List Regex introduces:

* **Concise, readable patterns** for structured data
* **Regex-inspired syntax** adapted for list validation
* **Powerful quantifiers and negation** to match complex structures

### A Simple Example

```ring
Lx("[@N, @S]").Match([42, "hello"]) #--> TRUE
```

Here, `@N` matches any number, and `@S` matches any string. The pattern ensures that a number appears first, followed by a string, making validation simple and intuitive.

Without `Lx()`, the same check requires multiple lines of explicit conditions:

```ring
data = [42, "hello"]

if isList(data) and
   len(data) = 2 and
   isNumber(data[1]) and
   isString(data[2])

        return TRUE
else
        return FALSE
ok
```

This comparison highlights the clarity and efficiency gained with `Lx()`, but this is just the beginning.

## Core Concepts

### Type Patterns

Lx defines fundamental type patterns for structured validation:

* `@N` - Matches any number (integer, float, scientific notation)
* `@S` - Matches any string (single or double-quoted)
* `@L` - Matches lists, from simple arrays to deeply nested structures
* `@A` - Matches any type (wildcard)

```ring
# Match a number followed by any value
Lx("[@N, @A]").Match([42, "string"]) #--> TRUE
Lx("[@N, @A]").Match([42, [1,2,3]]) #--> TRUE
```

### Smart Quantifiers

List Regex provides powerful quantifiers:

* `@N+` - One or more numbers
* `@S*` - Zero or more strings
* `@L?` - Optional list
* `@N1-3` - Range quantifier (1 to 3 occurrences)

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

### Alternation – Matching Different Types

Instead of writing long conditional checks, `Lx()` allows flexible patterns:

```ring
# Match a number or a string
pattern = "(@N|@S)"
Lx(pattern).Match(42)        #--> TRUE
Lx(pattern).Match("hello")   #--> TRUE
Lx(pattern).Match([42, 99])  #--> FALSE (expects a single number or string)
```

### Explicit Number Sets – Matching Specific Values  

Explicit number sets allow matching only predefined numbers:  

```ring
# Match a number that is either 4, 5, or 6
pattern = "@N{4, 5, 6}"
Lx(pattern).Match(4)  #--> TRUE
Lx(pattern).Match(5)  #--> TRUE
Lx(pattern).Match(6)  #--> TRUE
Lx(pattern).Match(7)  #--> FALSE (not in the set)
```

This feature is useful when you need to match only a fixed set of numbers instead of a range.

### Named Captures – Extracting Matched Values

Named captures allow labeling and extracting specific parts of matched data:

```ring
# Capture one or more numbers under the name 'values'
pattern = "(?<values>@N+)"
result = Lx(pattern).Extract([10, 20, 30])

# result["values"] = [10, 20, 30]
```

### Step-Based Ranges – Matching Sequences with Steps

With step-based ranges, we can define number sequences that follow a specific interval:

```ring
# Match odd numbers between 1 and 10
pattern = "@N{1-10:2}"
Lx(pattern).Match(1)  #--> TRUE
Lx(pattern).Match(3)  #--> TRUE
Lx(pattern).Match(4)  #--> FALSE (not part of the defined sequence)
```

## Real-World Applications

List Regex extends beyond simple validation, ensuring consistency while reducing boilerplate code. Here are some practical use cases:

### Configuration Validation

Configurations often contain mixed types, making manual checks tedious. With `Lx()`, validation is clear and adaptable:

```ring
# Validate config entries with flexible types
pattern = "[@S, @A, @L?]"
Lx(pattern).Match(["port", 8080, ["tcp", "udp"]]) #--> TRUE
```

### Data Pipeline Processing

Processing structured data like CSV rows or database records involves strict validation. `Lx()` simplifies this:

```ring
# Validate CSV-like data with optional fields
pattern = "[@S, @N+, @S*]"
Lx(pattern).Match(["Product", 100, 29.99, "In Stock"]) #--> TRUE
```

Here, the pattern enforces a string identifier (`@S`), followed by one or more numbers (`@N+`), and an optional series of strings (`@S*`).

### API Payload Validation

Modern APIs return nested responses, making validation tricky. With `Lx()`, we can define precise expectations effortlessly:

```ring
# Validate a nested API response structure
pattern = "[@S, @L, @N{1,2,3}]"
Lx(pattern).Match(["user", ["admin", "read"], 2]) #--> TRUE
```

This pattern verifies that the first element is a string (e.g., `"user"`), the second is a list (e.g., `["admin", "read"]`), and the third is a number restricted to specific values (`1, 2, or 3`).

## Performance Considerations

List Regex optimizes pattern matching through:

* **Efficient backtracking avoidance** for performance gains
* **Recursive matching only when necessary** to handle deep nesting
* **Specialized matchers** for common patterns to accelerate execution

`stzListEx` relies on Softanza's `stzRegex` engine, implemented using the high-performance Qt C++ regular expression library.

## The Future of Pattern Matching
 
As pattern matching evolves in todays programming languages, List Regex brings this power to hierarchical data structures with an intuitive, regex-like syntax. Its ability to **dynamically validate nested lists** without verbose conditions makes it a game-changer in structured data processing.