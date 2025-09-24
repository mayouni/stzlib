# Near-Natural Programming: Bridging Human Thought and Code Execution

_How the Softanza library enables executable code that reads like everyday language, powered by elegant design in the Ring programming language_

***

## The Human Side of Programming

We humans think in stories, questions, and natural flows of logic. "Is this word all lowercase, made of Latin letters, exactly four characters long?" That's how our minds frame problems. Yet, when we program, we often fracture these thoughts into rigid syntax: isolated functions, boolean checks, and conditional branches that feel far removed from our original intent.

Take a simple validation in Python:

```python
word = "ring"
is_valid = (word.islower() and 
            word.isascii() and 
            isinstance(word, str) and 
            len(word) == 4)
```

It's functional, but it doesn't _flow_. The code prioritizes the machine's needs over the programmer's natural expression. What if we could write code that mirrors our thoughts more closely—without sacrificing precision, performance, or computability?

## Introducing Near-Natural Programming

Enter Softanza, a library for the Ring programming language that transforms code into near-natural expressions. Here's the same validation, now reading like a sentence:

```ring
? Q("ring").IsAXT([:Lowercase, :Latin, :String]).WhichQ().HasAQ().LengthQ().EqualTo(4)
#--> TRUE
```

This isn't magic or AI trickery—it's a carefully crafted system of methods and conventions that lets developers articulate logic in a way that feels intuitive and human. We call it Near-Natural Programming (NNP): close enough to natural language to be readable and expressive, yet structured enough to execute as pure code.

At its heart, NNP in Softanza allows you to chain ideas fluidly, using words like "Which," "Has," "And," and "That" to build logical narratives. It's about making code not just workable, but _thinkable_—reducing the mental translation between idea and implementation.

## The Elegant Simplicity Behind the System

Softanza's NNP isn't built on complex frameworks or external dependencies. It's grounded in a straightforward foundation: a collection of methods spread across `stzObject` (the parent of all Softanza objects), through specialized classes like `stzString`, `stzList`, and `stzNumber`, and all coordinated by lightweight `stzNaturalCode` class and other related global functions and state management.

All Softanza objects share consistent method names and behaviors where it makes sense—`Find()` works similarly whether you're searching a string for characters, a list for elements, or a number for digits:

```ring
? Q("text").Find("t")      # Finds positions in the string
? Q([1,2,3,2]).Find(2)     # Finds positions in the list  
? Q(12321).Find(2)         # Finds digit positions in the number
```

This uniformity creates a predictable canvas for natural expressions, supported by a simple but powerful global state system using Ring variables like `_MainValue`, `_LastValue`, and `_aFuture`.

### Turning Descriptors into Actions

One key innovation is dynamic resolution of natural descriptors. When you specify qualities like `[:Lowercase, :Latin, :String]`, Softanza generates and evaluates the corresponding checks dynamically:

```ring
# Inside stzObject.IsAXT() method:
cCode = '@is' + pacStr[i] + '(' + @@(this.Content()) + ')'
eval(cCode)
```

For `IsAXT([:Lowercase, :Latin, :String])`, it effectively runs:

* `@isLowercase("ring")` → TRUE
* `@isLatin("ring")` → TRUE
* `@isString("ring")` → TRUE

This maps human-friendly terms directly to code execution without parsers or overhead.

### Intelligent Flow Through Object Transitions

Chains aren't just sequences—they're smart. Methods return not only results but the right _type_ of object to keep the narrative going. The "Q" suffix pattern creates fluent continuations:

```ring
? Q("ring").IsAQ(:String).InLowercase()     #--> TRUE
? Q("ring").IsAQ(:String).Which().IsLowercase() #--> TRUE
```

Multiple natural variations express the same logic, accommodating different thinking patterns.

### Context Memory with Minimal State

Softanza uses simple global variables to maintain context across chains. The `SetLastValue()` function stores values that subsequent methods can reference:

```ring
? TheWordQ("ring").HasNQ(4).LettersNB()
#--> TRUE
```

Here's the flow:

1. `HasNQ(4)` stores 4 in `_LastValue`
2. `LettersNB()` counts letters (4) and compares to `_LastValue` (4)
3. Returns TRUE since they match

The "B" suffix indicates binary (boolean) operations that often use this context.

### Programming the Future with Deferred Actions

Softanza's most innovative feature lets you describe actions to perform later, mimicking natural planning:

```ring
? BeforeQ("ringo").IsUppercasedFQ().RemoveFFQ("o").AndThenQ().ReturnIt()
#--> RING
```

The system works through a global `_aFuture` array that stores action plans:

```ring
_aFuture = [
    ["IsUppercased", []],
    ["Remove", ["o"]]
]
```

Methods with "FQ" suffixes queue actions, while "FFQ" methods execute them. `SetFutureOrder(:Before)` or `SetFutureOrder(:After)` controls execution sequence.

## Suffix Patterns: Fine-Tuned Control

Softanza uses consistent suffix patterns for nuanced control:

* **No suffix**: Acts on object, returns nothing (`Remove("X")`)
* **Q()**: Acts and returns object for chaining (`RemoveQ("X")`)
* **B()**: Returns boolean, often context-aware (`LettersNB()`)
* **N()**: Returns number (`VowelN()` for vowel count)
* **FQ()**: Queues future action (`IsUppercasedFQ()`)
* **FFQ()**: Executes queued actions (`RemoveFFQ("o")`)

Multiple forms express the same concept:

```ring
? Q("ring").IsAString()      # Direct check
? Q("ring").IsA(:String)     # Symbolic form
? Q("ring").IsAXT([:String]) # Extended validation
```

## Real-World Power in Everyday Code

### Natural Validations

Replace nested conditions with flowing queries:

```ring
? Q(["Ring", :and = "Ruby"]).AreBothQ(:strings).HavingQ().TheirQ().FirstCharQ().EqualTo("R")
#--> TRUE
```

### Context-Aware Operations

Use remembered values elegantly:

```ring
SetLastValue(3)
? Q("AnnIE").VowelNB()  # Compares vowel count to LastValue
#--> TRUE

SetLastValue(["A", "I", "E"])
? Q("AnnIE").VowelsB()  # Compares vowel list to LastValue  
#--> TRUE
```

### Complex Logical Chains

Handle multiple criteria seamlessly:

```ring
? Q([-1200, -10200, -820, -10]).AreQ(:numbers).ThatQ().AreNegativeQ().AndQ().DividableBy(10)
#--> TRUE
```

### Future-Oriented Programming

Plan and execute multi-step transformations:

```ring
? BeforeQ("ringo").IsUppercasedFQ().AndThenQ().SpacifiedFQ().
  RemoveFFQ(" o").BoundItWithQ(["<< ", :and = " >>"]).
  AndFinallyQ().ReturnIt()
#--> << R I N G O >>
```

## Technical Architecture: Efficiency Through Simplicity

Softanza's NNP runs at native Ring speed through direct method calls with no interpretation layers. The global state system uses minimal memory—just Ring's built-in variables and lists:

```ring
$aFuture = []           		# Action queue
$LastValue = NULL       		# Context memory  
$MainValue = NULL       		# Chain context
$oMainObject = ANullObject()  	# Object context
```

Functions like `AddFuture()`, `ExecuteActions()`, and `CleanFuture()` manage the action system with straightforward list operations. Results are deterministic with no AI unpredictability.

### Error-Tolerant Design

The system gracefully handles common variations and typos:

```ring
? Q("ring").IsAQ(:String).InLowarcase()  # Misspelled
#--> TRUE (still works)

? Q("ring").IsAQ(:String).InLowercase()  # Correct
#--> TRUE
```

## Universal Language Patterns

While examples use English, NNP represents universal programming concepts. The method structure supports any language's natural patterns by extending the vocabulary accordingly. The core idea—bridging human thought and code execution—transcends specific linguistic implementations.

## The Grand Vision: Executable Human Language

Softanza's NNP foundation enables even more natural expressions:

```ring
Naturally() {
    Make a stzString using "ring"
    Spacify it and uppercase it  
    Then show the result
}
#--> "R I N G"
```

By embedding natural expressions in Ring, Softanza points toward programming that feels like conversation, blending human intuition with machine reliability.

## A Step Toward Thoughtful Code

Softanza's Near-Natural Programming demonstrates that humane code doesn't require vast AI models—it needs smart design. By weaving methods, chains, and context into a cohesive system, it reduces the gap between thinking and coding, making development more accessible and enjoyable.

The system's power lies not in complexity but in thoughtful simplicity: global state for context, consistent patterns for predictability, and deferred execution for natural planning. As programming evolves, approaches like this remind us that the best innovations often simplify rather than complicate.

Softanza isn't rewriting programming's rules—it's making them readable, natural, and unmistakably human.
