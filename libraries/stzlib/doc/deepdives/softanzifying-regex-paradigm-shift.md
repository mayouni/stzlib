# Softanzifying Regular Expressions: A Paradigm Shift
![Transforming Chaos into Clarity](../images/stz-regex-paradigm-shift.png)
_Master Craftsmen Transforming Chaos into Clarity!_

Regular expressions are a powerful tool for text processing, yet their classic syntax can be terse, cryptic, and error-prone. The **Softanza library** for the **Ring language** transforms regex usage by offering intuitive, semantically rich APIs that simplify pattern creation, execution, and analysis.

---

## 1. The Four-Pillar Architecture

Softanza’s regular expression framework is built upon four fundamental pillars, each addressing a specific aspect of regex programming:

1. **stzRegex**: A semantic wrapper around Qt's regex engine that simplifies pattern matching and extraction.
2. **stzRegexMaker**: A declarative system for constructing regex patterns, transforming how patterns are built.
3. **stzRegexData**: A comprehensive library of pre-built patterns for common use cases (to be detailed in a future article).
4. **stzRegexAnalyzer**: A tool for analyzing pattern complexity and optimization (to be detailed in a future article).


## 2. The Challenge with Classic Regex Syntax

Classic regex syntax has long been a cornerstone for text manipulation. However, despite its power, it poses several challenges:

* **Cryptic Notation**: Compact expressions (e.g., `\d+`, `(ab|cd)?`) are often hard to read and maintain, especially for newcomers.
* **Steep Learning Curve**: Mastery requires memorizing many special characters and constructs, making even simple tasks error-prone.
* **Limited Contextual Semantics**: While concise, traditional regex patterns provide little insight into the intended usage, complicating debugging and modifications.

_Example: Email Address Pattern (Classic Regex)_

```regex
^[a-zA-Z0-9.\_%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$
```

Though powerful, this pattern can be overwhelming and lacks self-documentation.


## 3. The Softanza Approach: Semantic Engineering for Regex

Softanza takes a fundamentally different approach by providing a high-level API that abstracts away the complexity of regex syntax. Its design emphasizes clarity, readability, and safety.

### 3.1. Abstraction of Complexity

Softanza wraps the underlying Qt regex engine so developers can build patterns using clear, method-chained calls with descriptive names. Consider the following transformation:

**Classic Regex**:

```regex
^\d{3}-\d{2}-\d{4}$
```

**Softanza Equivalent**:

```ring
o1 = new stzRegexMaker()
o1 {
    AddDigitsRange("0-9", :RepeatedExactly = 3Times())
    AddChar("-")
    AddDigitsRange("0-9", :RepeatedExactly = 2Times())
    AddChar("-")
    AddDigitsRange("0-9", :RepeatedExactly = 4Times())

    ? Pattern() #--> ^\d{3}-\d{2}-\d{4}$
}
```

This declarative approach clarifies each component of the pattern.

### 3.2. Domain-Specific Language (DSL)

At its core, Softanza introduces a DSL that maps directly to regex constructs and reads almost like natural language. For instance:

**Example: Matching French Registration Numbers**

```ring
o1 = new stzRegexMaker()
o1 {
    CanContainAChar(:Between = ["A", :And = "Z"], :RepeatedExactly = 2Times())
    CanContainAChar(:Among = ["-", " "], :RepeatedAtMost = 1Time())
    CanContainADigit(:From = ["0", :To = "9"], :RepeatedExactly = 3Times())
    RepeatSequence(2)
    RepeatSequence(1)

    ? Pattern() #--> [A-Z]{2}[- ]?[0-9]{3}[- ]?[A-Z]{2}
}
```

Here, each method call documents the pattern step-by-step, making the logic easier to follow than traditional regex.

### 3.3. Error Prevention and Enhanced Readability

By enforcing correct usage patterns via method chaining, Softanza helps prevent common errors—such as misplacing quantifiers or escape characters—and produces self-documenting code. Consider the example of adding word boundaries:

```ring
o1 = new stzRegexMaker()
o1.AddWordBoundary(:start)
o1.AddCharsRange("A-Z", :RepeatedExactly = 2Times())
o1.AddWordBoundary(:end)

? o1.Pattern()
// Expected output: a pattern with correctly placed word boundaries
```

Such clear constructs improve both code readability and maintainability.


## 4. Basic Matching with stzRegex

Even though Softanza shines in creating complex patterns, it does not reinvent the wheel for simple matches. The API remains straightforward for basic operations.

**Example: Matching Whole Numbers**

```ring
rx("\b\d+\b") {
    ? Match("There are 12 apples.") #--> TRUE
    ? Match("No numbers here.")     #--> FALSE
}
```

**Explanation**:

* `\b`: Ensures the match occurs on whole word boundaries.
* `\d+`: Matches one or more digits.

This example illustrates how Softanza wraps regular expressions in an accessible API, even for simple tasks.


## 5. Advanced Matching with stzRegex

### 5.1. Capturing Named Groups

Named groups let developers assign descriptive names to parts of a regex, improving clarity and easing maintenance.

**Example: Extracting Email Components**

```ring
rx("Name: (?<name>.*), Age: (?<age>\d+)") {
    if Match("Name: John, Age: 30") and HasNames()
        ? @@( Names() ) + NL #--> [ "name", "age" ]
        ? @@NL( CaptureXT() )
        #--> [
        #     [ "name", "John" ],
        #     [ "age", "30" ]
        # ]
    ok
}
```

### 5.2. Finding Matches and Their Positions

Softanza provides methods for locating matches and identifying their positions within a string.

**Example: Locating Matches**

```ring
rx("\b\d+\b") {
    txt = "There are 12 apples and 34 oranges."
    if Match(txt)
        ? @@NL( MatchesZZ() )
        #--> [
        #     [ "12", [ 10, 11 ] ],
        #     [ "34", [ 20, 21 ] ]
        # ]
        ? @@( FindMatches() )
        #--> [ "12", "34" ]
    ok
}
```

_Explanation_:

* `MatchesZZ()`: Returns each match along with its start and end positions.
* `FindMatches()`: Retrieves a flat list of all matches.


### 5.3. Partial Matching with Real-Time Feedback

Partial matching is ideal for validating input incrementally, such as during form entry or autocomplete suggestions.

**Example: Social Security Number Validation**

```ring
o1 = new stzRegex("^\d{3}-\d{2}-\d{4}$")
o1 {
    ? MatchAsYouType("123")         #--> TRUE
    ? MatchAsYouType("123-")        #--> TRUE
    ? MatchAsYouType("123-45")      #--> TRUE
    ? MatchAsYouType("123-45-6789") #--> TRUE
    ? MatchAsYouType("abc")         #--> FALSE

    ? @@NL( PartialMatchInfo("123-45") )
    #--> [
    #     :matchType = "partial",
    #     :matched   = "123-45",
    #     :needed    = "more characters to match ^\d{3}-\d{2}-\d{4}$",
    #     :position  = 1,
    #     :length    = 5
    # ]
}
```

_Explanation_:

* `MatchAsYouType()`: Tests whether input partially matches the regex.
* `PartialMatchInfo()`: Provides details about the partial match state.


## 6. Declarative Pattern Design with stzRegexMaker

For complex pattern creation, Softanza’s `stzRegexMaker` offers a declarative approach that improves writability.

**Example: Crafting a French Registration Number Pattern**

```ring
o1 = new stzRegexMaker()
o1 {
    CanContainAChar(:Between = ["A", :And = "Z"], :RepeatedExactly = 2Times())
    CanContainAChar(:Among = ["-", " "], :RepeatedAtMost = 1Time())
    CanContainADigit(:From = ["0", :To = "9"], :RepeatedExactly = 3Times())
    RepeatSequence(2)
    RepeatSequence(1)
    ? Pattern()
}
//--> [A-Z]{2}[- ]?[0-9]{3}[- ]?[A-Z]{2}
```

This approach lets developers build patterns in a step-by-step, self-documenting manner.

### 6.1. Look-Around Patterns

Look-around constructs allow assertions about the surrounding context of a match without including those parts in the final match. Traditional regex uses constructs like lookahead and lookbehind, which can be unintuitive.

**Classic Approach Example**:

```ring
o1 = new stzRegexLookAroundMaker()
o1.LookingBehind("Mr\.")         .ThenMatch("[A-Z][a-z]+")
o1.NotLookingAhead("px")         .ThenMatch("\d+")
o1.LookingForWord("hello")       .ThenMatch("\w+")
? o1.Pattern()
//--> (?=\bhello\b)\w+
```

**Softanza’s Improved Semantics**:

```ring
o1 = new stzRegexLookAroundMaker()
o1.MustBePrecededBy("Mr\.")      .ThenMatch("[A-Z][a-z]+")
o1.CantBeFollowedBy("px")        .ThenMatch("\d+")
o1.MustBeFollowedByWord("hello") .ThenMatch("\w+")
? o1.Pattern()
//--> (?=\bhello\b)\w+
```

**Benefits**:

* **Clarity**: Phrases like `MustBePrecededBy` and `CantBeFollowedBy` clearly convey intent.
* **Readability**: The code reads naturally, reducing the cognitive load.


### 6.2. Recursive Patterns

Recursive patterns are vital for matching nested structures (e.g., parentheses, JSON-like objects, XML tags). Traditional regex can implement recursion with constructs like `(R)`, but these are often complex.

**Softanza’s Declarative Recursive Pattern**:

```ring
o1 = new stzRecursiveRegexMaker()
o1 {
    EnableNamedRecursion()
    AddLevel("expr", "\(")
    AddChildLevel("expr", "inner", "[^()]*")
    AddLevel("close", "\)")
    ? Pattern()
}
//--> (?P\()(?P[^()]*)\)
```

**Benefits**:

* **Modularity**: Patterns are built incrementally.
* **Reusability and Readability**: Each component is clearly defined and can be reused.

### 6.3. Conditional Patterns

Conditional patterns enable different behaviors based on context. While classic regex uses `(?(condition)then|else)`, Softanza’s declarative approach is more intuitive.

**Example: Conditional Pattern for Phone Number Formats**

```ring
o1 = new stzConditionalRegexMaker()
o1 {
    IfStartsWith("+").
    ThenMatch("\+1\d{10}").     // International format
    ElseMatch("\d{10}")          // Local format
    ? Pattern()
}
//--> (?(?=^+)\+1\d{10}|\d{10})
```

**Benefits**:

* **Clarity and Flexibility**: Conditions are expressed with clear, descriptive methods.
* **Maintainability**: The structure is self-documenting, making future modifications easier.


## 7. Small Functions for Streamlined Experience

To further unify the regex experience and reduce verbosity, Softanza introduces several helper functions:

* **`rx()`**: Creates a `stzRegex` object.
* **`pat()`**: Invokes a pre-built regex pattern from `stzRegexData`.
* **`rxm()`**: Creates a `stzRegexMaker` object for declarative pattern crafting.
* **`wrxm()`**: Designs conditional patterns ("w" ususally refers to conditions in Softanza).
* **`arxm()`**: Designs look-around patterns ("a" stands for look-"a"round).

**Example Using `rx()`**:

```ring
rx("\b\d+\b") {
    ? Match("There are 12 apples.") #--> TRUE
    ? Match("No numbers here.")     #--> FALSE
}
```

**Example Using `pat(cName)`**:

```ring
rx(pat(:email)) { 
    ? Match("user@example.com") #--> TRUE
    ? Match("invalid@email")    #--> FALSE
}
```

**Example Using `rxm()`**:

```ring
rx(rxm().AddDigitsRange("0-9", :RepeatedExactly = 3Times()).Pattern()) {
    ? Match("123") #--> TRUE
    ? Match("abc") #--> FALSE
}
```

**Example Using `wrxm()`**:

```ring
wrxm() {
    IfStartsWith("+").
    ThenMatch("\+1\d{10}")	# International format
    ElseMatch("\d{10}")		# Local format

    ? Pattern()
}
//--> (?(?=^+)\+1\d{10}|\d{10})
```

**Example Using `arxm()`**:

```ring
arxm() {
    CantBeFollowedBy("[.,!?]").
    ThenMatch("\w+")
    ? Pattern()
}
//--> (?![.,!?])\w+
```

These concise functions enable developers to write regex code that is both flexible and intuitive.

---

## Conclusion

The Softanza library for Ring revolutionizes regex programming by transforming complex, error-prone syntax into an intuitive, expressive, and maintainable experience. Through semantic engineering, a declarative design, and a domain-specific language, Softanza bridges the gap between raw regex intricacies and developer-friendly code.

Whether validating emails, parsing logs, or matching nested structures, Softanza empowers developers to focus on solving problems rather than deciphering cryptic expressions. Embrace the Softanzified approach and experience this paradigm shift firsthand!

***
