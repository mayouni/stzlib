# Decoding Unicode Deception: Unmasking Lookalikes and Invisible Characters


The world of Unicode characters is vast and complex, presenting subtle yet significant challenges. Visually similar characters can have distinct underlying representations, and even invisible characters can pose security risks. This article explores these issues, demonstrating how Softanza provides tools to detect and mitigate these threats.

---


## The Problem: Visually Similar Characters

Characters like "۰" and "٠," "۱" and "١," or "O," "Ο," and "О" appear nearly identical, yet they are distinct characters with different code points. This can lead to confusion and security vulnerabilities.

Let's illustrate this with examples in Ring:

```ring
load "stzlib.ring"

? "۱" = "١"   #--> FALSE
? "۲" = "٢"   #--> FALSE
? "۳" = "٣"   #--> FALSE
? "۸" = "٨"   #--> FALSE
? "۹" = "٩"   #--> FALSE

? "O" = "Ο"   #--> FALSE
? "O" = "О"   #--> FALSE
? "Ο" = "О"   #--> FALSE
```

These results demonstrate that visual similarity does not imply equality.



## Softanza's Solution: Revealing Character Identities

Softanza's `Unicode()` function exposes the true identity of a character by returning its unique code point:

```ring
? Unicode("۱")   #--> 1776
? Unicode("١")   #--> 1632
```

The `AreEqual()` function further confirms the distinction:

```ring
? AreEqual("۱", "١")   #--> FALSE
```

For checking sets of characters:

```ring
? AreEqual(["O", "Ο", "О"])   #--> FALSE
? Unicodes(["O", "Ο", "О"])   #--> [ 79, 927, 1054 ]
```


## The Root Cause: Code Points and Scripts

Unicode assigns a unique *code point* to each character, focusing on semantic identity rather than visual appearance (glyph). The seemingly identical "O," "Ο," and "О" have different code points and belong to different scripts:

*   Latin "O" → `79`
*   Greek "Ο" → `927`
*   Cyrillic "О" → `1054`

Softanza's `Scripts()` function reveals these script differences:

```ring
? Scripts(["O", "Ο", "О"])   #--> [ "latin", "greek", "cyrillic" ]
```



## The Hidden Threat: Invisible Characters

Beyond visually similar characters, *invisible* characters pose another significant security risk. These characters, while not visually apparent, have code points and can be exploited to bypass filters or create misleading content.

The Twitter incident, where attackers used zero-width characters to manipulate usernames and tweets, exemplifies this threat. These characters were nearly undetectable visually, enabling impersonation and other malicious activities.


## Softanza's Defense Against Invisible Characters

Softanza provides tools to detect and handle these invisible characters. Consider this example:

```ring
c = "‎" # This contains a LEFT-TO-RIGHT MARK

? IsEmpty(c)    #--> FALSE
? Unicode(c)    #--> 8205
? CharName(c)   #--> LEFT-TO-RIGHT MARK

? @@NL( NamesOfInvisibleChars() )
#--> [
#     "<control>", "SPACE", "NO-BREAK SPACE", ..., "HALFWIDTH HANGUL FILLER" // (truncated for brevity)
# ]
```

As demonstrated, `IsEmpty()` correctly identifies that the string `c` is not empty. `Unicode()` reveals the character's code point, and `CharName()` provides its name. The `NamesOfInvisibleChars()` function offers a comprehensive list of known invisible characters.

To finsih with, Here is a snapshot from my Ring Notepad:

![SoftanzaLib, unmasking unicode lookalities](../images/stz-unmasking-unicode-lookalities.png)  


