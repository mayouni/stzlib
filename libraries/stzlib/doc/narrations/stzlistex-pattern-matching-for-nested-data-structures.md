# Softanza ListEx: Bringing Pattern Matching to Lists

Pattern matching has revolutionized data validation and manipulation across various programming paradigms. While traditional regex excels at string matching, structured data—especially deeply nested lists—requires a more expressive approach. Enter **List Regex (Lx)**, a Softanza-powered pattern-matching engine that brings regex-style matching to structured data.

## Why List Regex?

Validating and transforming hierarchical data structures often involves verbose conditional logic. Existing solutions—whether in Python, JSON Schema, or TypeScript interfaces—offer static validation but lack the elegance of regex-like expressiveness for lists. List Regex introduces:

* **Concise, readable patterns** for structured data
* **Regex-inspired syntax** adapted for list validation
* **Powerful quantifiers, negation, and alternation** to match complex structures
* **Stepped ranges and uniqueness constraints** for advanced control over list elements

### A Simple Example

```ring
Lx("[@N, @S]").Match([42, "hello"]) #--> TRUE
```

Here, `@N` matches any number, and `@S` matches any string. The pattern ensures that a number appears first, followed by a string, making validation simple and intuitive.

## Core Features and Syntax

### Type Patterns

Type patterns define the fundamental building blocks of ListEx pattern matching. These patterns help categorize data types concisely:

* `@N` - Matches any number (integer, float, scientific notation)
* `@S` - Matches any string (single or double-quoted)
* `@L` - Matches lists, from simple arrays to deeply nested structures
* `@A` - Matches any type (wildcard, useful for unknown data)

For instance, if we need to check whether a list contains a string followed by any value, we can use:

```ring
Lx("[@S, @A]").Match(["name", 123]) #--> TRUE
Lx("[@S, @A]").Match(["username", ["admin", "guest"]]) #--> TRUE
```

### Quantifiers and Ranges

Quantifiers allow us to specify **how many times** a pattern should appear within a list:

* `@N+` - Matches one or more numbers
* `@S*` - Matches zero or more strings
* `@L?` - Matches an optional list (present or absent)
* `@N1-3` - Matches between 1 and 3 numbers

For example, to match one to three numbers in a row, we use:

```ring
Lx("[@N1-3, @S]").Match([1, 2, "end"]) #--> TRUE
Lx("[@N1-3, @S]").Match([3, "done"]) #--> TRUE
Lx("[@N1-3, @S]").Match([4, 5, 6, "extra"]) #--> FALSE
```

### Stepped Ranges

Sometimes, we need to ensure that numbers follow a **specific step or interval**. Stepped ranges make this easy:

```ring
Lx("[@N{1-10:3}]").Match(1) #--> TRUE  (matches 1, 4, 7, 10)
Lx("[@N{1-10:3}]").Match(4) #--> TRUE
Lx("[@N{1-10:3}]").Match(6) #--> FALSE
```

This feature is incredibly useful for validating data that follows a structured pattern, such as price increments, sequence validation, or even time intervals.

### Negation Patterns

Negation allows us to **exclude** certain types of values from matching. Instead of checking for a match, we check for a **non-match**:

```ring
Lx("[@!N]").Match(["string"]) #--> TRUE (not a number)
Lx("[@!N]").Match([[1,2,3]]) #--> TRUE (not a number)
Lx("[@!N]").Match([42]) #--> FALSE (because 42 is a number)
```

This can be useful when filtering out unwanted data types from a dataset.

### Alternation Patterns

Alternation allows **either-or** matches, providing flexibility when validating structured data:

```ring
Lx("[@N|@S]").Match(42)        #--> TRUE
Lx("[@N|@S]").Match("hello")   #--> TRUE
Lx("[@N|@S]").Match([42, 99])  #--> FALSE (expects a single number or string)
```

### Explicit Sets

We can define a **fixed set of valid values** using explicit sets:

```ring
Lx("[@N{1;2;3}]").Match(2)  #--> TRUE
Lx("[@N{4}]").Match(4)  #--> TRUE
Lx("[@N{5}]").Match(6)  #--> FALSE (not in the set)
```

### Nested Patterns

ListEx is particularly powerful when dealing with **nested structures**. This is useful for validating **complex configurations** and **hierarchical data**:

```ring
Lx("[@N, [@N2], @N]").Match([1, [2, 3], 4]) #--> TRUE
Lx("[@N, [@N2], @N]").Match([1, [2], 4]) #--> FALSE (inner list must have exactly 2 elements)
```

## Why Softanza ListEx Stands Out

Softanza ListEx represents a true innovation in pattern matching by addressing a gap left by other languages. While some languages have **partial support** for structured pattern matching, none provide the **regex-like expressiveness tailored for list validation**. Here’s how ListEx compares:

| Feature                  | Softanza ListEx (Ring) | Wolfram Language | C# | Rust | Haskell | Python |
|--------------------------|----------------|------------------|----|------|---------|--------|
| Dedicated List Patterns  | ✅         | ✅          | ◉ | ◉ | ◉ | ◉ |
| Regex-Like Syntax        | ✅         | ✅          | ● | ● | ● | ● |
| Quantifiers              | ✅         | ◉       | ◉ | ◉ | ◉ | ◉ |
| Value Constraints        | ✅         | ✅          | ✅ | ✅ | ✅ | ✅ |
| Uniqueness Constraints   | ✅         | ✅          | ● | ● | ● | ● |
| Stepped Ranges           | ✅         | ✅          | ● | ● | ● | ● |
| Nested Matching          | ✅         | ✅          | ✅ | ✅ | ✅ | ✅ |

Legend: ✅ Yes		● No		◉ Parial / Limited

Softanza ListEx is positioned **at the forefront of structured pattern matching**, standing at the same level—or even surpassing—the most advanced systems in this area. While **Wolfram Language** has powerful symbolic pattern matching, it lacks the structured regex-like quantifiers of ListEx. **C# introduces pattern matching within switch expressions and tuples but lacks the expressiveness for list validation.** **Rust and Haskell** provide functional and structural pattern matching but lack stepped ranges and uniqueness constraints. **Python**, while widely used, does not offer native pattern matching for structured lists.

Given this, Softanza ListEx **achieves a breakthrough** by combining regex-like syntax, deep nested matching, and advanced constraints in a way that no other system does.

## Conclusion

As pattern matching evolves in modern programming, List Regex brings this power to hierarchical data with an intuitive syntax. Its ability to **dynamically validate nested lists** without verbose conditions makes it a game-changer in structured data processing.