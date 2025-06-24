# The Softanza RegexMaker: Making Regex Human-Friendly

Regular expressions (regex) are powerful but notorious for their cryptic syntax. The Softanza RegexMaker class reimagines regex creation with a declarative, human-readable approach. This guide shows how RegexMaker transforms complex regex concepts into intuitive code.

## Getting Started

Create a RegexMaker using either the full class name or the shorthand function `rxm()`:

```ring
o1 = new stzRegexMaker()
// or simply:
rxm()
```

You can test patterns using the complementary `rx()` function that creates a regex object:

```ring
rx("your-pattern") {
    ? Match("test-string")
}
```

## Basic Pattern Construction

Let's start with a real-world example: matching French vehicle registration numbers.

Traditional regex:
```
[A-Z]{2}[- ]?[0-9]{3}[- ]?[A-Z]{2}
```

With RegexMaker:
```ring
rxm() {
    # Two uppercase letters
    CanContainAChar(:Between = ["A", :And = "Z"], :RepeatedExactly = 2Times())
    
    # Optional separator (hyphen or space)
    CanContainAChar(:Among = ["-", " "], :RepeatedAtMost = 1Time())
    
    # Three digits
    CanContainADigit(:From = ["0", :To = "9"], :RepeatedExactly = 3Times())
    
    # Repeat separator and two letters
    RepeatSequence(2)
    RepeatSequence(1)

    ? Pattern()
    #--> [A-Z]{2}[- ]?[0-9]{3}[- ]?[A-Z]{2]
}
```

## Capturing Groups and Backreferences

In regex, capturing groups `(...)` store matched text for later reference. Backreferences (`\1`, `\2`, etc.) let you refer back to these captured groups. While powerful, the syntax can be confusing.

Traditional regex for matching repeated words:
```
\b(\w+)\s+\1\b
```

RegexMaker makes this clearer:
```ring
rxm() {
    AddWordBoundary(:start)
    DefineGroup("word", "\\w+")      # Store a word
    AddCharacterClass(:space)
    MatchSameContentAs("word")       # Match the same word again
    AddWordBoundary(:end)

    ? Pattern()
    #--> \b(?P<word>\w+)[\s]*(?P=word)\b
}

# Testing the pattern
rx("\\b(?P<word>\\w+)[\\s]*(?P=word)\\b") {
    ? Match("the the")       #--> TRUE
    ? Match("hello hello")   #--> TRUE
    ? Match("the that")      #--> FALSE
}
```

## Look-Around Assertions

Look-around assertions in regex let you check for patterns before or after the current position without including them in the match. The traditional syntax (`(?<=...)`, `(?=...)`, `(?!...)`, `(?<!...)`) is particularly cryptic.

RegexMaker transforms these into natural language constructs:

```ring
rxma() {
    MustBePrecededBy("@").              # Positive lookbehind (?<=@)
    CantBeFollowedBy("\\W").            # Negative lookahead (?!\W)
    ThenMatch("[a-zA-Z0-9_]+")

    ? Pattern()
    #--> (?<=@)(?!\W)[a-zA-Z0-9_]+
}
```

Testing username validation:
```ring
rx("(?<=@)(?!\\W)[a-zA-Z0-9_]+") {
    ? Match("@username")     #--> TRUE
    ? Match("@user123")      #--> TRUE
    ? Match("@user#name")    #--> FALSE
}
```

## Conditional Patterns

Regex conditionals (`(?(condition)then|else)`) allow different matches based on conditions. RegexMaker makes this branching logic clear:

```ring
wrxm() {
    IfStartsWith("+").                   # Check if starts with +
    ThenMatch("\\+1\\d{10}").           # International format
    ElseMatch("\\d{10}")                # Local format

    ? Pattern()
    #--> (?(?=^+)\+1\d{10}|\d{10})
}

# Testing phone numbers
rx("(?(?=^+)\\+1\\d{10}|\\d{10})") {
    ? Match("+12345678901")   #--> TRUE
    ? Match("1234567890")     #--> TRUE
    ? Match("+1234")          #--> FALSE
}
```

## Recursive Patterns

Recursive patterns are essential for matching nested structures like HTML tags or balanced parentheses. Traditional regex makes this extremely complex. RegexMaker provides a clear hierarchical approach:

```ring
o1 = new stzRecursiveRegexMaker()
o1 {
    EnableNamedRecursion()
    
    AddLevel("tag", "<([^>]+)>")
    AddChildLevel("tag", "content", "[^<>]*")
    AddLevel("close", "</\\1>")

    ? Pattern()
    #--> (?P<tag><([^>]+)>)(?P<content>[^<>]*)</\1>
}

# Testing HTML tags
rx("(?P<tag><([^>]+)>)(?P<content>[^<>]*)</\\1>") {
    ? Match("<div>content</div>")    #--> TRUE
    ? Match("<p>text</p>")           #--> TRUE
    ? Match("<div>text</p>")         #--> FALSE
}
```

## Pattern Information and Debugging

RegexMaker provides rich introspection capabilities:

```ring
rxm() {
    DefineGroup("num", "\\d{2}")
    AddLiteral("/")
    ReuseGroupPattern("num")
    AddLiteral("/")
    ReuseGroupPattern("num")

    # Inspect the pattern
    ? Pattern()                  #--> (?P<num>\d{2})/(?:\d{2})/(?:\d{2})
    ? @@(FragmentsXT())         # Shows detailed structure of each component
    ? NumberOfComponents()       # Count pattern components
}
```

## Conclusion

The Softanza RegexMaker transforms regex from a cryptic notation into clear, self-documenting code. By providing semantic methods that map to traditional regex concepts, it makes pattern creation more accessible while maintaining the full power of regular expressions. RegexMaker's declarative approach helps you focus on what you want to match rather than how to express it in regex syntax.