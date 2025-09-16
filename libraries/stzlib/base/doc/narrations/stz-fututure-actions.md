# Programming the Future: Softanza's Future Actions

## Classic vs Future Actions

Programming traditionally forces immediate execution - each action happens as soon as you call it. Future Actions let you plan a sequence first, then execute it all at once with natural timing control.

**Classic approach - immediate execution:**
```ring
oStr = new stzString("ringo")
oStr.Uppercase()     # Executes now: "RINGO"
oStr.Remove("o")     # Executes now: "RING" 
? oStr.Content()     # Shows: "RING"
```

**Future actions - deferred execution:**
```ring
? BeforeQ("ringo").IsUppercasedFQ().RemoveFFQ("o").Content()
#--> "RING"
```

## The Future Syntax

The power lies in specific suffixes that control when actions happen and how they chain together:

- **`F`** - "Plan this action"
- **`FQ`** - "Plan this action and continue chaining"  
- **`FF`** - "Plan this action and execute all now"
- **`FFQ`** - "Plan, execute all, and continue chaining"

**Flow control:**
- `BeforeQ(value)` - Start with this value
- `AndThenQ()` - Sequence connector
- `ReturnIt()` - Get the final result


## How It Works

The fluent syntax is built on basic queue functions:

```ring
# What you write:
BeforeQ("ring").UppercaseFQ().RemoveFFQ("g")

# What happens:
# 1. Queue the Uppercase action
# 2. Queue the Remove action  
# 3. Execute all actions on "ring"
# 4. Return result: "RIN"
```

Examples:

```ring
? BeforeQ("ringo").IsUppercasedFQ().
	RemoveFFQ("o").
	AndThenQ().ReturnIt()
#--> RING

? BeforeQ("ringo").IsUppercasedFQ().AndThenQ().SpacifiedFQ().
	RemoveFFQ(" o").
	BoundItWithQ([ "<< ", :and = " >>" ]).
	AndFinallyQ().ReturnIt()
#--> << R I N G O >>

? BeforeQ('').UppercasingFQ("ringo").
	RemoveFFQ("o").FromItQ().
	SpacifyItQ().
	AndThenQ().ReturnIt()
#--> R I N G
```

## Why Future Actions?

Future Actions let you express programming intentions naturally - like planning a sequence of steps before executing them. The code reads like human thought: "Before working with 'ringo', I plan to uppercase it, then remove the 'o'."

This transforms programming from mechanical commands into expressive, story-like sequences that execute with precision.