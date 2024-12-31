# Unmasking Unicode Lookalikes

The world of Unicode characters is vast, and sometimes tricky, especially when visually similar characters are actually different. Let's explore this with examples and see how Softanza offers a solution.

---

## The Problem

Are "۰" and "٠" the same? No! Neither are "۱" and "١," "۲" and "٢," or "۳" and "٣."

Here's what happens when we check for equality in Ring:

```ring
load "stzlib.ring"

? "۱" = "١"  #--> FALSE
? "۲" = "٢"  #--> FALSE
? "۳" = "٣"  #--> FALSE
? "۸" = "٨"  #--> FALSE
? "۹" = "٩"  #--> FALSE
````

Surprising, right? It doesn't stop there. "O", "Ο", and "О" look almost identical, but they're distinct:

```ring
? "O" = "Ο"  #--> FALSE
? "O" = "О"  #--> FALSE
? "Ο" = "О"  #--> FALSE
```

This poses security risks, as attackers could exploit these visual tricks. Luckily, Softanza helps detect and handle these situations.

## Softanza Unveils the Unicode Secret\!

Softanza's `Unicode()` function reveals a character's true identity:

```ring
? Unicode("۱")  #--> 1776
? Unicode("١")  #--> 1632
```

These characters look similar but are fundamentally different. `AreEqual()` confirms this:

```ring
? AreEqual("۱", "١")  #--> FALSE
```

You can also check sets of visually identical characters:

```ring
? AreEqual(["O", "Ο", "О"])  #--> FALSE
? Unicodes(["O", "Ο", "О"])  #--> [ 79, 927, 1054 ]
```

## Why Does This Happen?

Unicode assigns a unique *code point* to each character, focusing on identity, not appearance (glyph). For example:

  * Latin "O" → `79`
  * Greek "Ο" → `927`
  * Cyrillic "О" → `1054`

They look the same but belong to different scripts. Softanza's `Scripts()` function shows this:

```ring
? Scripts(["O", "Ο", "О"])  #--> [ "latin", "greek", "cyrillic" ]
```

## Invisible Characters

This character isn't empty; it's *invisible*\! Softanza has functions to check for this:

```ring
c = "‎"

? IsEmpty(c)
#--> FALSE

? Unicode(c)
#--> 8205

? CharName(c)
#--> LEFT-TO-RIGHT MARK

? @@NL( NamesOfInvisibleChars() )
#--> [
#   "<control>",
#   "SPACE",
#   "NO-BREAK SPACE",
#   "EN QUAD",
#   "EM QUAD",
#   "EN SPACE",
#   "EM SPACE",
#   "THREE-PER-EM SPACE",
#   "FOUR-PER-EM SPACE",
#   "SIX-PER-EM SPACE",
#   "FIGURE SPACE",
#   "PUNCTUATION SPACE",
#   "THIN SPACE",
#   "HAIR SPACE",
#   "ZERO WIDTH SPACE",
#   "ZERO WIDTH NON-JOINER",
#   "ZERO WIDTH JOINER",
#   "LEFT-TO-RIGHT MARK",
#   "RIGHT-TO-LEFT MARK",
#   "LINE SEPARATOR",
#   "PARAGRAPH SEPARATOR",
#   "NARROW NO-BREAK SPACE",
#   "MEDIUM MATHEMATICAL SPACE",
#   "IDEOGRAPHIC SPACE",
#   "HANGUL FILLER",
#   "HANGUL CHOSEONG FILLER",
#   "HALFWIDTH HANGUL FILLER"
# ]
```

## Code in Action

Softanza helps protect your software from these hidden risks, giving you control over string operations.

Here is a snapshot from my Ring Notepad:

![SoftanzaLib, unmasking unicode lookalities](../images/stz-unmasking-unicode-lookalities.png)  


