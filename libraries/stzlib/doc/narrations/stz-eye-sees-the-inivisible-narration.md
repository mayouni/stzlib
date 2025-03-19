# Softanza Eye Sees the Invisible: Unmasking Hidden Unicode Characters

Invisible characters are a fascinating aspect of Unicode that often go unnoticed but can significantly impact text processing. The Softanza library provides robust tools for working with these hidden characters. Let's explore a simple example that reveals the nature of these invisible entities.

## The Invisible Character Mystery

We begin with what appears to be an empty string:

```
pr()
c = "‎" 
```

This character looks empty to our eyes, but is it truly empty? Let's investigate using Softanza's functions:

```
? IsEmpty(c) #--> FALSE
```

Surprisingly, the IsEmpty() function tells us this string is not empty! But what is it then?

```
? Unicode(c) #--> 8206
? CharName(c) #--> LEFT-TO-RIGHT MARK
```

Mystery solved! This "invisible" character is actually Unicode code point 8206, known as the LEFT-TO-RIGHT MARK. It's a special character used for controlling text direction in bidirectional text.

Softanza makes working with these characters straightforward. We can explore the universe of invisible characters:

```
? ShowShort( NamesOfInvisibleChars() ) #--> [
    "<control>",
    "SPACE",
    "NO-BREAK SPACE",
    "...",
    "HANGUL FILLER",
    "HANGUL CHOSEONG FILLER",
    "HALFWIDTH HANGUL FILLER"
]
```

The library provides a comprehensive list of all invisible characters recognized by Unicode. In total:

```
? HowMany( InvisibleChars() ) #--> 27
```

## Text Cleansing with RemoveInvisibleChars()

Look at these two strings that appear identical at first glance:

```
text1 = "Hello World"
text2 = "Hello‎ World"

# You may think those two texts are the same, but they're not!

? stzlen(text1)
#--> 11

? stzlen(text2)
#--> 13
```

Despite looking identical, they have different lengths! The second text contains invisible characters that are hidden from our view but still count as characters.

Softanza provides comprehensive tools to detect and manage these hidden characters:

```
StzStringQ(text2) {

? ContainsInvisibleChars()
#--> TRUE

? @HowMany( InvisibleChars() ) + NL
#--> 1

? @@( FindInvisibleChars() )
#--> [ 6, 13 ]

? QQ(InvisibleChars()).Names()
#--> [ "LEFT-TO-RIGHT MARK", "ZERO WIDTH SPACE" ]
```

Not only can we detect the presence of invisible characters, but we can also locate them precisely and identify their types. In this case, we've found a LEFT-TO-RIGHT MARK and a ZERO WIDTH SPACE.

The RemoveInvisibleChars() function efficiently cleans up these hidden characters:

```
RemoveInvisibleChars()

? @HowMany( InvisibleChars() )
#--> 0
}
```

After cleaning, all invisible characters are removed, resulting in a clean, predictable string.

## Practical Applications

- **Text validation**: Detect hidden characters that might cause unexpected behavior in inputs
- **Security enhancement**: Identify potential vulnerabilities from invisible characters in usernames or code
- **Multilingual support**: Properly handle directional markers for mixed language text
- **Data sanitization**: Clean imported data by removing or standardizing invisible characters using RemoveInvisibleChars()
- **UI consistency**: Ensure consistent spacing and layout across different platforms
- **Document formatting**: Control text flow with specialized whitespace characters
- **Debugging aid**: Identify hard-to-spot issues in source code caused by invisible characters
- **Form processing**: Sanitize user inputs before database storage to prevent inconsistencies
- **Text comparison**: Ensure accurate string comparisons by removing invisible variations

These invisible characters may be hidden from sight, but understanding and managing them is crucial for robust text processing in modern applications.
