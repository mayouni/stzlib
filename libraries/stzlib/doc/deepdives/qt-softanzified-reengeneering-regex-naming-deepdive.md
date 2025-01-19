# Qt Softanzified: A Step-by-Step Naming Engineering Journey

Naming is crucial for code usability. This case study follows the evolution of naming while working on Softanza's `stzRegex` class, based on `QRegularExpression` offered by `RingQt`, showing how careful naming engineering can make complex features more accessible while maintaining their full power.

## The Starting Point: Qt's Original Model

Qt's `QRegularExpression` class offers pattern matching through its `match()` method, which takes four parameters:
1. The text to search in
2. The starting position
3. The match type (our focus in this article)
4. The match options

Although all parameters deserve attention (and have been equally simplified by Softanza), this article specifically focuses on the third parameter, `MatchType`, as it poses particularly intriguing naming challenges. Here's how Qt's original naming looks:

```cpp
QRegularExpression regex("world");
QString text = "hello world";

// Qt's original naming for the MatchType parameter
regex.match(text, 0, QRegularExpression::NormalMatch, 0);
regex.match(text, 0, QRegularExpression::PartialPreferCompleteMatch, 0);
regex.match(text, 0, QRegularExpression::PartialPreferFirstMatch, 0);
regex.match(text, 0, QRegularExpression::NoMatch);
```

## The Hidden Sequence Problem

The first major issue lies in Qt's naming obscuring the sequential nature of the matching process. Consider these Qt options:

```cpp
QRegularExpression::PartialPreferCompleteMatch
QRegularExpression::PartialPreferFirstMatch
```

The problem:
1. The word "Prefer" hides that these are actually sequential operations
2. A developer needs to read documentation to understand that "Prefer" means "try this first, then try that"
3. The order of words ("PartialPrefer") suggests partial matching comes first, when it's actually the fallback

Here's our first attempt at clarity:

```cpp
// First Softanza improvement
regex.match(text, 0, StzRegex::CompleteThenPartial);
regex.match(text, 0, StzRegex::FirstThenPartial);
```

This solved the sequence visibility problem by:
- Making the order explicit with "Then"
- Putting the operations in their actual execution order

However, this solution introduced new issues:
1. "Complete" doesn't specify what's being completed (the pattern? the text?)
2. "First" is ambiguous - first what? First character? First possible match?

## The Multiple Ambiguities Problem

Our attempt to fix the sequence issue revealed deeper naming problems that needed addressing:

### Issue 1: The "Complete" Ambiguity
"Complete" could mean:
- Complete pattern match
- Complete text match
- Complete section from starting position

### Issue 2: The "First" Ambiguity
"First" could mean:
- First character matching
- First possible match
- First complete match

### Issue 3: The "Normal" Mystery
Qt's `NormalMatch` raises questions:
- What's "normal" about it?
- How does it differ from "non-normal" matches?
- Is it the default? The recommended option?

Let's address these issues step by step:

```cpp
// Second iteration - clarifying what we're matching
regex.match(text, 0, StzRegex::MatchEntireContent);
regex.match(text, 0, StzRegex::MatchEntireContentIfNotGoPartial);
regex.match(text, 0, StzRegex::MatchFirstPossibleOccurrenceIfNotGoPartial);
```

This solved several problems:
1. "EntireContent" clearly indicates what's being matched
2. "IfNotGoPartial" explicitly shows the fallback strategy
3. "FirstPossibleOccurrence" removes the ambiguity about what "first" means

However, when dealing with substring matching, a new issue emerged:

```cpp
// What happens when matching from position 6?
regex.match("hello world", 6, StzRegex::MatchEntireContent);
```

Does "EntireContent" mean the entire string or the entire content from position 6? We needed one final refinement.

## Yet an Other Last Refinement

Qt's fourth matching type indeed performs no matching at all. In other terms, it's about turning the matching engine off, regardless of the regex pattern we provide—even if matches exist in the string we are working on!

For this, Qt uses the `:NoMatch` option name, but this is not as clear as intended. The term "no match" could imply many things:

- Is it ignoring the pattern altogether?
- Or does it only consider the absence of matches?
- Or maybe it evaluates matches but doesn't return them?

Softanza resolves this ambiguity by proposing an explicit name that describes the exact behavior: `:ReturnFalseForAnyMatch`. Do you see the difference?

## The Final Solution

Our Softanzified naming system becomes:

`:MatchEntireString`
- Clearly states it must match the complete pattern against the complete string
- No ambiguity about partial matches or starting positions
- Makes it obvious you're looking for an exact, complete match

`:MatchEntireStringIfNotGoPartial`
- Clearly describes the two-step strategy
- "IfNotGo" clearly indicates the fallback behavior
- Makes it obvious that complete match is attempted first

`:MatchFromStartIfNotGoPartial`
- Explicitly states it must start from the beginning
- Clear about the fallback to partial matching
- Distinguishes itself from complete string matching

`:ReturnFalseForAnyMatch`
- Explicitly states the outcome rather than the strategy
- No ambiguity about what happens
- Better than "NoMatch" because it describes the behavior rather than just the result

This naming scheme is superior because:
1. Uses complete phrases rather than single words
2. Describes the actual behavior rather than abstract concepts
3. Makes the fallback strategy explicit with "IfNotGo"
4. Clearly distinguishes between entire string matching and from-start matching
5. Uses consistent terminology across all options

## Conclusion

This journey shows how iterative refinement of names can significantly improve API clarity. Each step revealed new challenges that weren't immediately obvious, and solving each one brought us closer to names that are both technically precise and intuitively understandable. The final result makes Qt's powerful pattern matching features more accessible through Softanza's carefully engineered naming system, while maintaining their full functionality.