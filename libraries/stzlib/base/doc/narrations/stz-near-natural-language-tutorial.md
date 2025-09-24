# Softanza Near-Natural Programming Tutorial

Learn to write code that reads like English (or any other human language) using Softanza's NNP features.

## What is Near-Natural Programming?

Near-Natural Programming (NNP) bridges the gap between human thought and code execution. Instead of forcing your ideas into rigid programming syntax, NNP lets you express logic in flowing, readable chains that mirror natural language.

Traditional code often looks like this:
```python
if word.islower() and word.isascii() and len(word) == 4:
    # process word
```

With Softanza's NNP, the same logic becomes:
```ring
? Q("ring").IsAXT([:Lowercase, :Latin, :String]).WhichQ().HasAQ().LengthQ().EqualTo(4)
#--> TRUE
```

NNP isn't AI or natural language processing—it's carefully designed method chaining that makes code **thinkable**. You write executable expressions that read like sentences while maintaining full programming precision.

*For an in-depth exploration of NNP's philosophy and elegant design principles, see the companion article "Near-Natural Programming: Bridging Human Thought and Code Execution."*

## Getting Started: The Q() Function

Every NNP expression starts with `Q()` to create a Softanza object:

```ring
Q("ring")      # Creates stzString
Q([1,2,3])     # Creates stzList  
Q(123)         # Creates stzNumber
```

## Basic Checks and Validations

### Simple Property Checks

```ring
? Q("ring").IsAString()
#--> TRUE

? Q("ring").IsLowercase()
#--> TRUE

? Q([1,2,3]).IsList()
#--> TRUE
```

### Multiple Property Validation

Check several properties at once:

```ring
? Q("ring").IsAXT([:Lowercase, :Latin, :String])
#--> TRUE

? Q("RING").IsAXT([:Uppercase, :Latin, :String])
#--> TRUE
```

## Chaining with Natural Flow

### The Q Suffix Pattern

Add `Q` to methods to enable chaining:

```ring
? Q("ring").IsAQ(:String).InLowercase()
#--> TRUE

? Q("ring").IsAQ(:String).WhichIs().InLowercase()
#--> TRUE
```

### Building Longer Chains

```ring
? Q("ring").IsAQ(:String).InLowercaseQ().ContainingQ(TheLetter("i"))
#--> TRUE
```

## Context Memory System

### Using LastValue for Comparisons

Set a value to compare against later:

```ring
SetLastValue(4)
? Q("ring").LengthNB()  # N=Number, B=Binary comparison
#--> TRUE (length 4 matches LastValue)

SetLastValue(3)
? Q("AnnIE").VowelNB()  # Compares vowel count to LastValue
#--> TRUE (3 vowels matches LastValue)
```

### Context in Action

```ring
? TheWordQ("ring").HasNQ(4).LettersNB()
#--> TRUE
# HasNQ(4) sets LastValue=4, LettersNB() compares letter count to it
```

## Suffix Patterns Guide

| Suffix | Purpose | Example |
|--------|---------|---------|
| (none) | Action only | `Remove("x")` |
| Q | Action + return object | `RemoveQ("x")` |
| N | Return number | `VowelN()` returns count |
| B | Return boolean | `LettersNB()` compares to LastValue |
| NB | Number comparison | Counts and compares to LastValue |

```ring
# Different ways to get vowel information:
? Q("AnnIE").Vowels()     # Returns ["A", "I", "E"]
? Q("AnnIE").VowelN()     # Returns 3 (count)
? Q("AnnIE").Vowel()      # Returns random vowel
```

## Working with Collections

### Natural Collection Queries

```ring
? Q(["Ring", :and = "Ruby"]).AreBothQ(:strings)
#--> TRUE

? Q(["Ring", :and = "Ruby"]).AreBothQ(:strings).HavingQ().TheirQ().FirstCharQ().EqualTo("R")
#--> TRUE
```

### List Validations

```ring
? Q([-1200, -10200, -820, -10]).AreQ(:numbers).ThatQ().AreNegativeQ().AndQ().DividableBy(10)
#--> TRUE
```

## Future Programming: Planning Ahead

### Basic Future Actions

Queue actions to execute later:

```ring
? BeforeQ("ringo").IsUppercasedFQ().RemoveFFQ("o").AndThenQ().ReturnIt()
#--> RING
```

How it works:
1. `IsUppercasedFQ()` queues "make uppercase"
2. `RemoveFFQ("o")` executes all queued actions, then removes "o"
3. `ReturnIt()` returns the result

### Complex Future Chains

```ring
? BeforeQ("ringo").IsUppercasedFQ().AndThenQ().SpacifiedFQ().
  RemoveFFQ(" o").BoundItWithQ(["<< ", :and = " >>"]).
  AndFinallyQ().ReturnIt()
#--> << R I N G O >>
```

### Future Action Management

```ring
# Manually manage future actions:
AddFuture(:Uppercase)
AddFuture([:Replace, ["I", "♥"]])

oStr = Q("ring")
ExecuteFutureOn(oStr)
? oStr.Content()
#--> R♥NG

CleanFuture()  # Clear the queue
```

## Advanced Natural Expressions

### Complex Property Chains

```ring
? QM("ring").IsAQ([:Lowercase, :Latin, :String]).WhichQ().HasAQ().LengthQ().EqualTo(4)
#--> TRUE

? TheStringQM("ring").IsAQ([:Lowercase, :Latin, :String]).WithAQ().LengthQ().Of(4)
#--> TRUE
```

### Context-Rich Validations

```ring
? TheWordQM("ring").IsAQ([:Lowercase, :Latin, :Word]).WithQ().ALengthQ().
  OfQ(4)._Q(:Letters).AndQ().OnlyQM(1).VowelNB()
#--> TRUE
```

### Comparative Expressions

```ring
? Q("ring").IsTheQ([:Lowercase, :string]).WhichIsQ().TheQ().ReverseOfB("gnir")
#--> TRUE
```

## Error Tolerance

NNP handles common variations and typos:

```ring
? Q("ring").IsAQ(:String).InLowarcase()  # Misspelled
#--> TRUE (still works)

? Q("ring").IsAQ(:String).InLowercase()  # Correct  
#--> TRUE
```

## Practical Examples

### Email Validation Style

```ring
? Q("user@domain.com").IsAQ(:String).ContainingQ("@").AndQ().ContainingQ(".")
#--> TRUE
```

### Text Processing

```ring
? Q("Hello World").ToLowercaseQ().ReplaceQ(" ", "_").Content()
#--> "hello_world"
```

### Data Validation

```ring
# Check if all items in list are positive numbers
? Q([10, 20, 30]).AreQ(:numbers).ThatQ().ArePositive()
#--> TRUE
```

## Best Practices

### 1. Start Simple
Begin with basic `Q()` and `IsA()` patterns before adding complexity.

### 2. Use Context Wisely
`SetLastValue()` and `HasNQ()` create powerful comparisons:

```ring
# Instead of complex nested conditions:
SetLastValue(5)
if Q(word).LengthNB() and Q(word).IsLowercase()
    # Process word
ok
```

### 3. Chain Naturally
Write chains as you would speak:

```ring
# Natural: "Is this string lowercase and containing 'i'?"
? Q("ring").IsLowercaseQ().AndQ().Contains("i")
```

### 4. Plan with Future Actions
Use future programming for multi-step operations:

```ring
# Plan: uppercase first, then remove vowels, then add brackets
? BeforeQ(text).UppercasedFQ().RemoveVowelsFQ().BracketedFFQ().ReturnIt()
```

## Common Patterns Summary

**Validation Pattern:**
```ring
Q(value).IsAQ(properties).WithQ().AdditionalChecks()
```

**Transformation Pattern:**
```ring
Q(value).ActionQ().AnotherActionQ().FinalAction()
```

**Future Pattern:**
```ring
BeforeQ(value).ActionFQ().AnotherActionFQ().ExecuteFFQ().ReturnIt()
```

**Comparison Pattern:**
```ring
SetLastValue(expected)
Q(value).SomePropertyNB()  # Compares to LastValue
```

Start with these patterns and gradually build more complex natural expressions as you become comfortable with the system.