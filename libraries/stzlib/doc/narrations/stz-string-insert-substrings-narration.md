# InsertSubstrings(): A Powerful String Manipulation Tool in Softanza
![Inserting Substrings in a Sring in Softanza](../images/stzstring-insert-substrings.jpg)

Developers often face the challenge of inserting a list of formatted substrings into existing text. Softanza, a foundation library for Ring programming language, offers a powerful solution to this problem with its `InsertSubstrings()` feature. This article explores the capabilities of this function, demonstrating its flexibility and ease of use across various complexity levels.

---

## Introduction to InsertSubstrings

The `InsertSubstrings` method in Softanza, from the `stzString` class, is designed to insert and format lists of substrings within strings. It stands out for its ability to handle tasks ranging from simple insertions to complex, highly customized formatting. This versatility makes it an invaluable tool for developers working with dynamic text generation, report formatting, or any scenario requiring the programmatic insertion of substrings into strings.


## Basic Usage

Let's start with the simplest form of `InsertSubstrings`. This version uses sensible defaults to provide a clean, readable output with minimal code:

```ring
o1 = new stzString("All our software versions must be updated!")
o1.InsertSubStrings( o1.PositionAfter("versions"), [ "V1", "V2", "V3" ])
? o1.Content()
#--> All our software versions (V1, V2, V3) must be updated!
```

In this example, the method automatically encloses the inserted list in parentheses and uses commas as separators. This "smart default" approach makes the function immediately useful for common scenarios without any additional configuration.

## Customization with InsertSubstringsXT

For more control over the formatting, Softanza offers `InsertSubstrings**XT**`, an eXTended version of the function. This allows developers to customize various aspects of the insertion:

```ring
o1 = new stzString("All our software versions must be updated!")
o1.InsertSubstringsXT(
    o1.PositionAfter("versions"),
    [ " V1", "V2", "V3" ],
    [ :MainSeparator = "+" ]
)
? o1.Content()
#--> All our software versions V1+V2+V3 must be updated!
```

In this case, we've changed the separator to a plus sign and adjusted the spacing. The `XT` version allows for specifying only the options you want to change, keeping the code concise even when customizing.

## Advanced Formatting

For scenarios requiring more complex formatting, `InsertSubstringsXT` offers a wide range of customization options:

```ring
o1 = new stzString("All our software versions must be updated!")

nPosition = o1.PositionAfter("versions")

o1.InsertSubstringsXT(
    nPosition,
    [ "V1", "V2", "V3", "V4", "V5" ],
    [
        :InsertBeforeOrAfter = :Before,
        :OpeningChar = "{ ",
        :ClosingChar = " }",
        :MainSeparator = ",",
        :AddSpaceAfterSeparator = TRUE,
        :LastSeparator = "and",
        :AddLastToMainSeparator = TRUE,
        :SpaceOption = :AddLeadingSpace //+ :AddTrailingSpace
    ]
)

? o1.Content()
#--> All our software versions { V1, V2, V3, V4, and V5 } must be updated!
```

This example showcases the full power of `InsertSubstringsXT`:
- Custom opening and closing characters
- Main separator with automatic spacing
- Special handling for the last item ("and")
- Control over spacing around the entire inserted list

## Unique Advantages of Softanza

The `InsertSubstrings` feature in Softanza offers several advantages when compared to similar functionality in other programming frameworks:

1. **Flexibility in Complexity**: The function scales from simple to advanced usage within a single method, adapting to different needs without requiring separate functions or libraries.

2. **Declarative Syntax**: The configuration uses a clear, declarative approach, enhancing readability and self-documentation.

3. **All-in-One Operation**: It combines multiple string manipulation steps (insertion, joining, formatting) into a single method call, reducing code complexity.

4. **Intelligent Defaults**: The basic version provides smart defaults, making it immediately useful without configuration.

5. **Granular Control**: The extended version offers fine-grained control over numerous formatting aspects, all within a single function call.

---

## Conclusion

The `InsertSubstrings` feature in Softanza exemplifies a "simple by default, complex when needed" design philosophy. It provides an elegant solution to string list insertion, catering to both beginners and advanced users.

