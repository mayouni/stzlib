# Discovering Hidden Unicode Characters with Softanza

## The Mystery

Imagine encountering this puzzling text behavior in your application:

```ring
txt = "dear ‮friends!"
```

Something seems off with how "friends" displays, but what's causing it?

## The Investigation

Let's examine each character to solve this mystery:

```ring
? @@NL( CharsNames(txt) )
#--> [
    "LATIN SMALL LETTER D",
    "LATIN SMALL LETTER E", 
    "LATIN SMALL LETTER A",
    "LATIN SMALL LETTER R",
    "SPACE",
    "RIGHT-TO-LEFT OVERRIDE",
    "LATIN SMALL LETTER F",
    "LATIN SMALL LETTER R",
    "LATIN SMALL LETTER I",
    "LATIN SMALL LETTER E",
    "LATIN SMALL LETTER N",
    "LATIN SMALL LETTER D",
    "LATIN SMALL LETTER S",
    "EXCLAMATION MARK"
]
```

There it is: **RIGHT-TO-LEFT OVERRIDE** - an invisible Unicode character!

## Understanding the Culprit

This invisible character forces text after it to display right-to-left. Text editors use such characters to switch writing direction for multilingual content, but they're completely invisible in normal text display.

## Softanza's Invisible Character Mastery

Softanza handles invisible characters with precision:

```ring
o1 = new stzString(txt)
o1 {
    ? Content()
    #--> dear ‮friends!
    
    ? ContainsInvisibleChars()
    #--> TRUE

    ? @@(FindInvisibleChars())
    #--> [ 6 ]

    ? @@(InvisibleChars())
    #--> [ "RIGHT-TO-LEFT OVERRIDE" ]
}

# Get the Unicode value (decimal, not hex)
? Unicode(CharByName("RIGHT-TO-LEFT OVERRIDE"))
#--> 8238

# Insert the hidden char in a string
str = "dear " + CharByName("RIGHT-TO-LEFT OVERRIDE") + "freinds!"
? str
#--> dear ‮friends!

# Or you can use Unicode() instead
str = "dear " + Char(Unicode(8238)) + "freinds!"
```

## Comprehensive Coverage

Softanza knows all invisible Unicode characters:

```ring
? InvisibleCharsNames()
#--> [
    "<control>",
    "NO-BREAK SPACE",
    "EN QUAD",
    "EM QUAD", 
    "EN SPACE",
    "EM SPACE",
    "THREE-PER-EM SPACE",
    "FOUR-PER-EM SPACE",
    "SIX-PER-EM SPACE",
    "FIGURE SPACE",
    "PUNCTUATION SPACE",
    "THIN SPACE",
    "HAIR SPACE",
    "ZERO WIDTH SPACE",
    "ZERO WIDTH NON-JOINER",
    "ZERO WIDTH JOINER",
    "LEFT-TO-RIGHT MARK",
    "RIGHT-TO-LEFT MARK",
    "LINE SEPARATOR",
    "PARAGRAPH SEPARATOR",
    "RIGHT-TO-LEFT OVERRIDE",
    "NARROW NO-BREAK SPACE",
    "MEDIUM MATHEMATICAL SPACE",
    "IDEOGRAPHIC SPACE",
    "HANGUL FILLER",
    "HANGUL CHOSEONG FILLER",
    "HALFWIDTH HANGUL FILLER"
]
```

## Why This Matters

Softanza provides complete Unicode awareness for modern text processing - detecting, locating, naming, and providing Unicode values for invisible characters. Essential for international text handling, security analysis, and precise character-level control.