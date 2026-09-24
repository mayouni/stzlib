# Patterns in text

*Elementary Introduction · Chapter 8 · Skill PA-01: "What is the shape of the text I am looking for?"*

Chapter 7 handed over a condition on numbers. Text has conditions too, but they are about **shape**: four
digits, a dash, two digits. A pattern writes that shape down, and `rx()` tests any text against it. Read a
pattern left to right, one piece at a time, and it says what it matches.

## 1. A date has a shape

`[0-9]` is one digit; `{4}` says four of them. Read the whole pattern as *four digits, a dash, two digits,
a dash, two digits*.

```ring
? rx("[0-9]{4}-[0-9]{2}-[0-9]{2}").Match("2026-09-24")
#--> TRUE
? rx("[0-9]{4}-[0-9]{2}-[0-9]{2}").Match("24/09/2026")
#--> FALSE
```

## 2. Somewhere in the text, or the whole text

`Match` asks whether the whole text has the shape. `MatchFirst` asks whether the shape appears somewhere.

```ring
? rx("[0-9]+").Match("24/09/2026")
#--> FALSE
? rx("[0-9]+").MatchFirst("24/09/2026")
#--> TRUE
? @@( Q("tea 12, rice 30").Numbers() )
#--> [ "12", "30" ]
```

## 3. A phone number in Niger

`^` and `$` pin the pattern to the start and the end, and `\+` means a real plus sign.

```ring
cPhone = "^\+227 [0-9]{2} [0-9]{2} [0-9]{2} [0-9]{2}$"
? rx(cPhone).Match("+227 90 12 34 56")
#--> TRUE
? rx(cPhone).Match("90 12 34 56")
#--> FALSE
```

## 4. A word said twice

A pattern can name a piece of what it saw and ask for it again. `(?P<word>\w+)` remembers a word, and
`(?P=word)` demands the same word.

```ring
cTwice = "\b(?P<word>\w+)[\s]*(?P=word)\b"
? rx(cTwice).Match("the the")
#--> TRUE
? rx(cTwice).Match("the that")
#--> FALSE
```

Softanza also has a builder that writes patterns from words, `stzRegexMaker`. It is not shown in this
edition of the course, because on the build the course was checked against, its examples do not run.

{{exercise:ex-08-01}}

## Recap

- **Achieved:** you read four patterns piece by piece, told a whole match from a match somewhere, pinned a
  pattern to both ends, and asked a pattern to remember a word.
- **Why it matters:** a pattern is a condition on the shape of text. Once you can read one, a date, a phone
  number or a price stops being "some text" and becomes a shape you can check.
- **Coming next:** lists and numbers have shapes too.
