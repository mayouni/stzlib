# The Problem: Ambiguity and Complexity in Regular Expression Scopes

Regular expressions are powerful, but they often confuse users because of the mutable behavior of key metacharacters like `DOT (.)` and anchors like `^` and `$`. These characters behave differently depending on the context (whole string, lines, words, or segments), leading to unnecessary complexity in both writing and interpreting patterns. The required flags such as `dotall` (`s`) and `multiline` (`m`) exacerbate this confusion.

Let’s explore four examples illustrating the problem:

---

## 1. Whole String Matching with DOT (.)

**Problem**: Matching across the whole string requires enabling the `dotall` mode (`s`) to make `.` include newline characters. Without it, `.` matches only characters on the first line and stops just there!

```regex
Pattern: "Start.*End"
Text:
Start
Some more text
End
```

- Default behavior (`.` excludes `\n`): Does **not** match `Start\nSome more text\nEnd`.
- With `dotall` (`.` includes `\n`): Matches the entire content.

**Issue**: Users must remember and enable `dotall`, complicating both writing and understanding patterns.

## 2. Line-by-Line Matching with Multiline Mode

**Problem**: When matching each line individually in a multiline string, `^` and `$` behave differently depending on the `multiline` flag (`m`). Without it, these anchors match the beginning and end of the entire string, not individual lines.

```regex
Pattern: "^Header.*$"
Text:
Header Content
Footer Content
```

- Without `multiline`: Does **not** match `Header Content` because `^` and `$` are scoped to the entire string.
- With `multiline`: Matches `Header Content` and `Footer Content` line by line.

**Issue**: The `multiline` flag must be enabled to interpret `^` and `$` per line, adding cognitive overhead.


## 3. Matching Words Within Strings

**Problem**: Matching specific words in a string can be ambiguous. Should `.` match part of a word, or is the goal to match entire words only? Additionally, word boundaries (`\b`) must often be explicitly specified.

```regex
Pattern: "\bword\b"
Text: 
This word matches, but not "sword".
```

- Without `\b`: Matches "sword" as well as "word".
- With `\b`: Matches only "word".

**Issue**: Regular expressions for words require explicit word boundary markers, increasing complexity.


## 4. Matching Segments Across Lines

**Problem**: Matching segments that span across lines introduces challenges with `.` and anchors. Without enabling the `dotall` flag, `.` will not match across lines, and `^`/`$` lose their meaning within the segment.

```regex
Pattern: "<div>.*</div>"
Text:
<div>
Content
</div>
```

- Default behavior (`.` excludes `\n`): Does **not** match `<div>\nContent\n</div>`.
- With `dotall`: Matches across lines.

**Issue**: Users must enable `dotall` and mentally adjust to how `^` and `$` behave when crossing line boundaries.


## Softanza’s Solution: Predictable Scopes with Explicit Functions

Softanza eliminates these ambiguities by introducing **four dedicated methods** for specific scopes: `Match()`, `MatchLine()`, `MatchWord()`, and `MatchSegment()`. Each method is unambiguous, with consistent behavior for `DOT (.)`, `^`, and `$`.


### 1. Match() – Whole String Matching

- **Scope**: Matches patterns across the entire string, with `.` always including newline characters.
- **Behavior**:
  - `^`: Matches the start of the string.
  - `$`: Matches the end of the string.
  - `.`: Matches any character, including `\n`.

```ring
pattern = "Start.*End"
text = "Start\nSome more text\nEnd"
o.Match(text)  # Matches "Start\nSome more text\nEnd"
```


### 2. MatchLine() – Line-by-Line Matching

- **Scope**: Matches patterns within each line of a multiline string. `^` and `$` apply to individual lines.
- **Behavior**:
  - `^`: Matches the start of each line.
  - `$`: Matches the end of each line.
  - `.`: Matches any character except `\n`.

```ring
pattern = "^Header.*$"
text = "Header Content\nFooter Content"
o.MatchLine(text)  # Matches "Header Content" and "Footer Content"
```


### 3. MatchWord() – Word Matching

- **Scope**: Matches whole words, explicitly handling word boundaries.
- **Behavior**:
  - `^` and `$`: Not used for word matching.
  - `.`: Matches within a word, if needed.

```ring
pattern = "word"
text = "This word matches, but not sword."
o.MatchWord(text)  # Matches only "word"
```


### 4. MatchSegment() – Matching Segments Across Lines

- **Scope**: Matches patterns that can span across lines in a multiline string.
- **Behavior**:
  - `^`: Matches the start of the segment.
  - `$`: Matches the end of the segment.
  - `.`: Matches any character, including `\n`.

```ring
pattern = "<div>.*</div>"
text = "<div>\nContent\n</div>"
o.MatchSegment(text)  # Matches "<div>\nContent\n</div>"
```


## Conclusion: Clarity Through Explicit Scoping

Softanza’s design removes the need for ambiguous flags like `dotall` and `multiline` by making scope explicit in the API. The result is a predictable and intuitive framework:

1. **Match()**: Matches the whole string.
2. **MatchLine()**: Matches patterns within each line.
3. **MatchWord()**: Matches individual words.
4. **MatchSegment()**: Matches segments that span across lines.

This approach not only simplifies pattern writing but also aligns with a clearer mental model, allowing developers to focus on their intent without worrying about regex intricacies.