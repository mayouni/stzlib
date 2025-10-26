# stzNumbrex: A Pattern Language for Numbers in Softanza

## Introduction

Numbers aren’t just quantities — they embody structure, logic, and identity.
A number like **42** is not merely a scalar: it’s even, composite, divisible by 3 and 7, and composed of digits `[4, 2]`.
Yet in most programming languages, numbers are treated as inert values. Developers must loop, test, and branch endlessly to uncover their nature.

Softanza’s **stzNumbrex** reimagines this relationship.
Inspired by the philosophy behind regular expressions for strings, it introduces a **pattern language for numbers** — a declarative syntax that lets developers describe numeric properties, structures, and relationships with clarity and intent.

## Numbers as Patterns, Not Procedures

While traditional math libraries (like Python’s `math` or Java’s `BigInteger`) focus on *operations*, **stzNumbrex** focuses on *meaning*.
Instead of instructing the machine *how* to test a condition, you simply state *what* you mean.

For example, instead of writing:

```python
if n % 2 == 0 and is_prime(n):
```

you can now declare:

```ring
Nx = new stzNumbrex("{@Property(Even) & @Property(Prime)}")
if Nx.Match(n)
```

Softanza treats a number as a **pattern subject** that can reveal:

* **Properties** – such as Prime, Perfect, Fibonacci, or Palindrome
* **Digit structures** – describing ranges, counts, or uniqueness
* **Factor compositions** – including divisibility and multiplicity
* **Relations** – like modular congruences or parity rules

This shift transforms numeric programming from a procedural exercise into a form of **semantic expression**.

## Syntax Overview

A **stzNumbrex** pattern is always enclosed in `{}` and built from readable, meaningful tokens:

```ring
{@Property(Prime)}                  # Simple property
{@Digit(1-5)+}                      # Digit range pattern
{@Property(Even) | @Property(Prime)}# OR logic
{@Property(Even) & @Digit3}         # AND logic
{@!Property(Perfect)}               # NOT logic
{@Relation(Mod:5=0)}                # Modular test
```

**Core Token Types**

* `@Property` → Prime, Even, Odd, Perfect, Fibonacci, Palindrome, Square
* `@Digit` → Digit ranges, counts, sets, or uniqueness
* `@Factor` → Divisibility and factor count
* `@Relation` → Modular or comparative arithmetic
* `@Approx` → Fuzzy matching for real numbers
* `@Part` → Integer or fractional part (planned for future versions)

**Operators:** `|` (OR), `&` (AND), `!` (NOT)
**Quantifiers:** `+` (1+), `*` (0+), `?` (optional), `n`, `n-m` (bounded count)

## Property Recognition

With **stzNumbrex**, mathematical properties become instantly recognizable and expressible through concise patterns:

```ring
Nx = new stzNumbrex("{@Property(Prime)}")
? Nx.Match(17)  #--> TRUE
? Nx.Match(18)  #--> FALSE

Nx = new stzNumbrex("{@Property(Perfect)}")
? Nx.Match(6)   #--> TRUE  (1+2+3=6)
? Nx.Match(28)  #--> TRUE
```

This approach is particularly valuable in contexts such as cryptography, number theory classification, or mathematical validation.

## Digit Structures

Digits carry their own structure — their count, range, and uniqueness can all define meaningful patterns.

```ring
Nx = new stzNumbrex("{@Digit4}")
? Nx.Match(1234)  #--> TRUE

Nx = new stzNumbrex("{@Digit(1-5)+}")
? Nx.Match(1234)  #--> TRUE
? Nx.Match(1267)  #--> FALSE

Nx = new stzNumbrex("{@Digit(:unique)+}")
? Nx.Match(1234)  #--> TRUE
? Nx.Match(1223)  #--> FALSE
```

Such expressiveness is ideal for **PIN validation**, **lottery systems**, or **code pattern detection**, where digit composition carries meaning beyond value.

## Factor Decomposition

Divisibility and factor structures can also be captured declaratively — all in a single line.

```ring
Nx = new stzNumbrex("{@Factor4}")
? Nx.Match(6)   #--> TRUE  (1,2,3,6)
? Nx.Match(15)  #--> TRUE

Nx = new stzNumbrex("{@Factor2-5}")
? Nx.Match(6)   #--> TRUE
? Nx.Match(12)  #--> FALSE
```

This makes it easy to define **structural filters** for cryptographic applications or for classifying numeric families based on their factor patterns.

## Logical Composition

Complex logic becomes elegantly composable.

### Alternation (OR)

```ring
Nx = new stzNumbrex("{@Property(Even) | @Property(Prime)}")
? Nx.Match(2)  #--> TRUE
? Nx.Match(4)  #--> TRUE
? Nx.Match(7)  #--> TRUE
? Nx.Match(9)  #--> FALSE
```

### Conjunction (AND)

```ring
Nx = new stzNumbrex("{@Property(Palindrome) & @Property(Square)}")
? Nx.Match(121)  #--> TRUE (11²)
? Nx.Match(144)  #--> FALSE
```

### Negation (NOT)

```ring
Nx = new stzNumbrex("{@!Property(Prime)}")
? Nx.Match(4)  #--> TRUE
? Nx.Match(7)  #--> FALSE
```

These logical connectors allow for **composable numeric reasoning**, making filters, rule-based checks, and exception logic naturally expressive.

## Modular Relations

Modular arithmetic constraints can be written in a way that’s both readable and declarative.

```ring
Nx = new stzNumbrex("{@Relation(Mod:5=0)}")
? Nx.Match(10)  #--> TRUE
? Nx.Match(13)  #--> FALSE

Nx = new stzNumbrex("{@Relation(Mod:3=1)}")
? Nx.Match(10)  #--> TRUE
```

Such expressions simplify use cases like **cyclical scheduling**, **remainder systems**, or **cryptographic algorithms** that rely on modular logic.

## Structural Extraction

**stzNumbrex** goes beyond returning a simple boolean.
Once a match is performed, you can not only know *if* a number satisfies a pattern, but also *why*. The class exposes a structural view of the number through both **comprehensive** and **direct** access methods.

The most complete representation is given by `MatchedParts()`, which returns the entire anatomy of the matched number:

```ring
oNx = new stzNumbrex("{@Property(Even)}")
if oNx.Match(42)
	? MatchedParts()
ok
#--> [
#  "Digits", [4,2],
#  "Factors", [1,2,3,6,7,14,21,42],
#  "Properties", ["Even"],
#  "Value", 42
# ]
```

In practice, you often don’t need the full structure at once.
stzNumbrex therefore provides **direct accessors** — `Digits()`, `Factors()`, `Properties()`, and `Value()` — each of which retrieves the corresponding element from the underlying matched data:

```ring
? oNx.Digits()      #--> [4,2]
? oNx.Factors()     #--> [1,2,3,6,7,14,21,42]
? oNx.Properties()  #--> ["Even"]
? oNx.Value()       #--> 42
```

These methods give you immediate access to the number’s inner structure while maintaining full consistency with the data contained in `MatchedParts()`.

This capability makes **stzNumbrex** particularly valuable in **educational tools**, **mathematical exploration**, or **AI data pipelines**, where understanding a number’s composition is as important as verifying its properties.

## Pattern Explanation

Every pattern can also describe itself — making its internal meaning explicit.

```ring
Nx = new stzNumbrex("{@Property(Even) & @Digit3 & @Relation(Mod:5=0)}")
? @@(Nx.Explain())
```

This self-explanatory nature enhances **debugging, auditability, and transparency**, turning patterns into readable specifications rather than opaque logic.

## Debug Tracing

When debugging, you can follow the reasoning step by step.

```ring
Nx = new stzNumbrex("{@Property(Prime)}")
Nx.EnableDebug()
? Nx.Match(17)
# Logs internal operations: divisor tests, decision trace.
```

This feature is invaluable for learners, testers, and performance optimizers who want to observe how the pattern engine reasons internally.

## Comparative Analysis: stzNumbrex vs. Other Ecosystems

| Feature                         | Softanza (stzNumbrex)         | Python              | JavaScript      | Java               | Ruby            |
| ------------------------------- | ----------------------------- | ------------------- | --------------- | ------------------ | --------------- | --------- |
| **Declarative Number Patterns** | ✅ Native `{@Property(Prime)}` | ❌ Procedural checks | ❌ Imperative    | ❌ Verbose methods  | ❌ Chained calls |
| **Property Detection**          | ✅ Built-in                    | ⚠️ `sympy`          | ❌ Manual        | ⚠️ External        | ⚠️ Gems         |
| **Digit Pattern Matching**      | ✅ Declarative                 | ❌ String loops      | ❌ Regex tricks  | ❌ Manual           | ❌ Manual        | 
| **Factor Analysis**             | ✅ Structural                  | ⚠️ Loops            | ❌ None          | ⚠️ BigInteger only | ❌ None          |
| **Logical Composition**         | ✅ `&                          | !` syntax           | ❌ Code logic    | ❌ Nested ifs       | ❌ Methods       |
| **Modular Relations**           | ✅ `{@Relation(Mod:5=0)}`      | ✅ Verbose           | ✅               | ✅                  | ✅               | 
| **Pattern Negation**            | ✅ Built-in                    | ❌ `not ...`         | ❌ `!isPrime()`  | ❌ `!prime()`       | ❌ `!method`     |
| **Information Extraction**      | ✅ Structured output           | ❌ Manual            | ❌ Manual        | ❌ Manual           | ❌ Manual        |
| **Pattern Explanation**         | ✅ Introspectable              | ❌ None              | ❌ None          | ❌ None             | ❌ None          | 
| **Debug Tracing**               | ✅ Engine-level                | ⚠️ Prints           | ⚠️ Console      | ⚠️ Debugger        | ⚠️ puts         |
| **Composability**               | ✅ Full                        | ❌ Functions         | ❌ Chains        | ❌ Chains           | ❌ Chains        |
| **Self-Documentation**          | ✅ Pattern-as-spec             | ❌ Comments          | ❌ Comments      | ❌ JavaDoc          | ❌ RDoc          |
| **Type Safety**                 | ✅ Structural                  | ⚠️ Dynamic          | ❌ Weak          | ✅ Static           | ⚠️ Duck         |
| **Performance**                 | ✅ Intent-optimized            | ✅ Fast              | ⚠️ Engine-based | ✅ JVM              | ⚠️ Interpreted  |
| **Learning Curve**              | ⚠️ New paradigm               | ✅ Familiar          | ✅ Familiar      | ✅ Familiar         | ✅ Familiar      |
| **Integration**                 | ✅ Unified Softanza            | ❌ Fragmented        | ❌ Fragmented    | ⚠️ Framework-based | ⚠️ Gem-based    |
| **Real-Number Support**         | ✅ `@Approx` (planned)         | ✅ `isclose()`       | ✅ ε-checks      | ✅ BigDecimal       | ✅ Float         |
| **Prime Generation**            | 🔄 Future: built-in           | ✅ `sympy`           | ⚠️ Manual       | ✅ BigInteger       | ⚠️ Gems         |

## Conclusion

**stzNumbrex** reshapes how programmers perceive numbers.
They cease to be simple operands and become **semantic entities** — objects that can be matched, described, and explored declaratively.

* Declarative rather than procedural
* Structural rather than scalar
* Extractable rather than opaque

Softanza’s vision goes beyond mere syntax. It’s about treating data as language — one that can be read, reasoned about, and evolved.
With **stzNumbrex**, numbers don’t just compute — they finally **express their structure**.
