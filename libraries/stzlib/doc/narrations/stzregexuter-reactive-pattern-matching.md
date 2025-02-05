# The stzRegexuter: Reactive Pattern Computing in Softanza

## Introduction to Softanza's Regex Framework

The Softanza library provides a comprehensive regex framework consisting of three main components:

- **stzRegex**: The core regex engine built on Qt, providing powerful pattern matching capabilities
- **stzRegexMaker**: A declarative interface for designing and constructing regex patterns
- **stzRegexData**: A rich library of pre-defined regex patterns for common use cases across various domains

Building upon this foundation, **stzRegexuter** introduces a revolutionary approach to pattern matching by transforming regex from a static matching tool into a reactive computational system.

## Understanding stzRegexuter

The stzRegexuter (Regex Computer) extends traditional regex functionality by combining pattern matching with immediate computation and state tracking. This creates a powerful system where patterns can trigger specific computations while maintaining a history of transformations.

### Key Features

1. Pattern-based triggers
2. Associated computations for matched patterns
3. State tracking of transformations
4. Declarative API for defining pattern-computation pairs

## Getting Started

The stzRegexuter can be instantiated using either of these syntax options:

```ring
rxu = rxuter()
# or
rxu = rxu()
```

### Basic Pattern Matching

Before diving into the reactive features, let's look at the basic pattern matching capabilities:

```ring
? @@( Match("The total was 42 dollars and 13 cents.", "(\d+)") )
#--> [ "42", "13" ]
```

This demonstrates the fundamental pattern matching functionality, finding all numbers in the text.

## Building Reactive Pattern Systems

Let's explore how to build reactive systems using stzRegexuter through progressively complex examples.

### Example 1: Processing Numbers

This simple example demonstrates the basic workflow of defining triggers and computations:

```ring
rxu = rxuter()
rxu {
    # Step 1: Define the trigger pattern
    AddTrigger(:NumberFound = "(\d+)")

    # Step 2: Define the computation
    AddComputation(
        :When = :NumberFound,
        :Do = '{
            @value = @number(@value) * 2
        }'
    )

    # Step 3: Process the text
    Process("The total was 42 dollars and 13 cents.")
}
```

Output:
```ring
[
    [ "matches", [ "42", "13" ] ],
    [ "results", [ 84, 26 ] ]
]
```

This example shows how stzRegexuter:
1. Identifies numbers using the defined pattern
2. Applies the computation (multiplication by 2)
3. Returns both original matches and computed results

### Example 2: Email Processing

Here's a more practical example processing email addresses:

```ring
rxu = rxuter()
rxu {
    AddTrigger(:EmailFound = "(\w+)@(\w+\.\w+)")

    AddComputation(
        :When = :EmailFound,
        :Do = "{
            @value = StzStringQ(@value).Split('@')[2]
        }"
    )

    Process("Contact us at support@example.com or sales@example.com")
}
```

Output:
```ring
[
    [ "matches", [ "support@example.com", "sales@example.com" ] ],
    [ "results", [ "example.com", "example.com" ] ]
]
```

This example demonstrates how to:
1. Match email patterns
2. Extract specific parts (domain) from matched patterns
3. Process multiple matches in a single text

### Example 3: Multiple Triggers and Computations

The real power of stzRegexuter becomes apparent when handling multiple patterns and computations simultaneously:

```ring
rxu = rxuter()
rxu {
    # Define multiple triggers
    Trigger(:Number = "(\d+)")
    Trigger(:WordInQuotes = '"([^"]+)"')
    Trigger(:EmailAddr = "([a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})")

    # Define computations for each trigger
    @C(
        :When = :Number,
        :Do = '{
            @value = @number(@value) * 2
        }'
    )
    
    @C(
        :When = :WordInQuotes,
        :Do = '{
            @value = upper(@value)
        }'
    )
    
    @C(
        :When = :EmailAddr,
        :Do = '{
            @value = "CONTACT: " + @value
        }'
    )

    # Process text with multiple pattern types
    Process('Contact "john doe" at john@example.com or call 555123 for a "quick response"')
}
```

Output:
```ring
[
    [ "matches", [ 
        [ "555123" ], 
        [ '"john doe"', '"quick response"' ], 
        [ "john@example.com" ] 
    ] ],
    [ "results", [ 
        1110246, 
        '"JOHN DOE"', 
        '"QUICK RESPONSE"', 
        "CONTACT: john@example.com" 
    ] ]
]
```

This comprehensive example showcases:
1. Multiple trigger definitions using different syntaxes
2. Various computation types (numerical, string, and composite transformations)
3. Processing of different pattern types in a single pass
4. Organized return of matches and results

## API Reference

### Trigger Registration

```ring
AddTrigger(aTrigger)    # Main method
Trigger(aTrigger)       # Alternative syntax
@t(aTrigger)           # Shorthand syntax
```

### Computation Registration

```ring
AddComputationOp(cTriggerName, cComputation)    # Main method
AddComputation(cTrigger, cComputation)          # Alternative syntax
@C(cTrigger, cComputation)                     # Shorthand syntax
```

### Processing

```ring
Process(cText)     # Main method
Compute(cText)    # Alternative syntax
```

### State Management

```ring
State()    # Returns the current state of transformations
```

## Best Practices

1. **Name Triggers Meaningfully**: Use descriptive names for triggers that reflect the patterns they match.
2. **Keep Computations Focused**: Each computation should have a single, clear responsibility.
3. **Use State Tracking**: Monitor transformations using the State() method when debugging or auditing is needed.
4. **Leverage Alternative Syntaxes**: Choose the syntax that makes your code most readable and maintainable.

## Conclusion

The stzRegexuter represents a significant evolution in pattern matching and text processing. By combining reactive triggers, immediate computations, and state tracking, it provides a powerful tool for building complex text processing systems in a clear, maintainable way. Its applications range from simple text transformations to complex data processing pipelines, making it a valuable addition to the Softanza regex framework.
