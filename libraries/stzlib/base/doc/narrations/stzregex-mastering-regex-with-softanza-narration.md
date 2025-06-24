# Mastering Regular Expressions with Softanza: A Modern Approach to Pattern Matching

Regular expressions are a powerful tool for pattern matching and text processing, but their traditional syntax and behavior can be complex and unintuitive. Softanza's stzRegex class reimagines regex programming with a more semantic, scope-oriented approach while leveraging the robust Qt regular expression engine underneath. Let's explore how Softanza makes regex programming more accessible and maintainable.

## Core Concepts and Basic Pattern Matching

At the heart of Softanza's regex implementation is a more intuitive approach to pattern matching. Let's compare the traditional Qt approach with Softanza's semantic style:

```ring
# Qt-style pattern matching
oQRegex = new QRegularExpression("pattern")
oMatch = oQRegex.match(cStr, 0, 0)
bMatched = oMatch.hasMatch()

# Softanza's semantic approach
oRegex = new stzRegex("pattern")
bMatched = oRegex.Match(cStr)
```

Softanza eliminates the need to understand low-level details like match types and offset positions for basic pattern matching. The `Match()` function provides a clear, straightforward way to check if a pattern matches a string.

## Scope-Oriented Pattern Matching

One of Softanza's major innovations is its scope-oriented approach to pattern matching. Instead of requiring developers to manage regex metacharacters manually, it provides semantic functions that handle common matching scenarios:

```ring
oRegex = new stzRegex("pattern")

# Match within specific scopes
bMatchedLine = oRegex.MatchLine(cStr)      # Line-based matching
bMatchedWord = oRegex.MatchWord(cStr)      # Word boundary matching
bMatchedSegment = oRegex.MatchSegment(cStr) # Segment-based matching
```

These scope-based functions automatically handle:
- Line boundaries with appropriate multiline flags
- Word boundaries with \b markers
- Segment handling with proper dot behavior
- Greedy vs non-greedy matching

This approach makes it much easier to express intent and avoid common regex pitfalls.

## Real-Time Pattern Matching

Softanza introduces innovative solutions for real-time pattern matching scenarios, particularly useful in user interfaces:

```ring
oRegex = new stzRegex("^\d{3}-\d{2}-\d{4}$") # Social Security Number pattern

# Real-time validation as user types
bValid = oRegex.MatchAsYouType(cUserInput)

# Progressive search matching
bPotentialMatch = oRegex.MatchInProgress(cSearchText)
```

The `MatchAsYouType()` function is specifically designed for form validation, returning true for both complete matches and partial matches that could become valid. This is a significant improvement over Qt's more complex partial match handling:

```ring
# Qt approach to partial matching
oQRegex = new QRegularExpression(pattern)
oMatch = oQRegex.match(text, 0, QRegularExpression.PartialPreferComplete)
bValid = oMatch.hasMatch() or oMatch.hasPartialMatch()

# Softanza's intuitive approach
bValid = oRegex.MatchAsYouType(text)
```

## Capturing and Extracting Information

Softanza simplifies the capture group handling process with clear semantic methods:

```ring
oRegex = new stzRegex("(\w+):(\d+)")
oRegex.Match("name:123")

# Get captured values
aValues = oRegex.Capture()        # Returns ["name", "123"]

# Get captured values with positions
aValuesWithPos = oRegex.CaptureZ()  # Returns with positions
aFullInfo = oRegex.CaptureZZ()      # Returns with start/end positions
```

The Z-suffix convention in method names consistently indicates when position information is included in the return value, making it easy to choose the right method for your needs.

## Recursive (Nested) Pattern Matching

Softanza provides enhanced support for handling nested patterns, common in parsing structured text:

```ring
# Match nested parentheses
oRegex = new stzRegex("\((?:[^()]+|(?R))*\)")
oRegex.MatchRecursive("(a(b)c)")

# Get information about nested matches
aInfo = oRegex.RecursiveMatchInfo()
nDepth = oRegex.RecursiveDepth()
aMatches = oRegex.RecursiveSubStrings()
```

The recursive matching capabilities are wrapped in semantic methods that make it easier to understand and work with nested structures.

## Pattern Analysis and Explanation

Softanza includes built-in support for understanding regex patterns:

```ring
oRegex = new stzRegex("\b\w+@\w+\.\w+\b")
cExplanation = oRegex.Explain()
cDetailedExplanation = oRegex.ExplainXT()
```

This self-documentation feature helps developers understand complex patterns and aids in maintenance.

## Conclusion

Softanza's stzRegex class represents a fundamental reimagining of how developers interact with regular expressions. By providing semantic, scope-oriented methods and handling common use cases elegantly, it makes regex programming more accessible and maintainable. The combination of Qt's powerful regex engine with Softanza's intuitive interface creates a robust foundation for pattern matching in modern applications.