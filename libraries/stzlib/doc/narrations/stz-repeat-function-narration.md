# The Symphony of Repetition: A Coding Journey in Softanza
![Symphony of Repetition in Softanza, by Microsoft Image AI](../images/stz-repeat-function.jpg)

Softanza introduces a remarkable function, `Repeat()`, along with its **eXT**ended form `RepeatXT()`, that transforms **value repetition** into an elegant, flexible coding technique. These functions allow you to duplicate and transform values **across various data types and structures** with unprecedented ease and precision.

## Basic Repetition

It all starts with the straightforward `Repeat()` function, which you can use like this:

```ring
load "stzlib.ring"

? Repeat("A", 3)
#--> [ "A", "A", "A" ]

# Which is the same as:

? RepeatInList("A", 3)
#--> [ "A", "A", "A" ]

# And when you want the repetition as a string:

? RepeatInString("A", 3) # Equivalent to Ring's copy() function
#--> "AAA"
```

But this is just the beginning. Say hello to the more capable `RepeatXT()` function!

## List Repetition

Does the following code need any explanation? Let’s repeat the character "5" in a list of size 2:

```ring
? Q("5").RepeatedXT(:InA = :List, :OfSize = 2)
#--> [ "5", "5" ]

? Q("A").RepeatedInAPair()
#--> [ "A", "A" ]
```

Both examples are equivalent, but the second is more concise and expressive.

## Numeric and Type Conversion

Repetition can also include smart type conversion, which is as useful as it is powerful:

```ring
# Repeating the STRING "5" three times in a list of NUMBERS

Q("5").RepeatedXT(:InA = :ListOfNumbers, :OfSize = 3)
#--> [ 5, 5, 5 ]

# Repeating the NUMBER 5 three times in a STRING

Q(5).RepeatedXT(:InA = :String, :OfSize = 3)
#--> "555"

# Repeating the NUMBER 5 three times in a list of STRINGS

Q(5).RepeatedXT(:InA = :ListOfStrings, :OfSize = 3)
#--> [ "5", "5", "5" ]
```

The `RepeatXT()` function effortlessly converts inputs between strings, numbers, and collections, preserving their essence while fulfilling repetition requirements.

## Advanced Repetition

Sometimes, simple repetition isn't enough. You may need multi-step repetitions to create complex nested structures with minimal code:

```ring
@@( Q("A").
    RepeatXTQ(:InA = :List, :OfSize = 3).
    RepeatedXT(:InA = :List, :OfSize = 3)
)
#--> [ [ "A", "A", "A" ], [ "A", "A", "A" ], [ "A", "A", "A" ] ]
```

Method chaining introduces a new dimension of usability. By combining `RepeatXTQ()` and `RepeatedXT()`, you can create intricate nested structures with a single, readable code sequence.

>**NOTE 1**: Method chaining in Softanza allows fluent design of transformation pipelines by simply suffixing the method you want to chain with a small `...Q()`, like this: `Q("h e l l o").RemoveSpacesQ().UppercaseQ().Content()`, resulting in the string `"HELLO"`.

>**NOTE 2**: Fluent chains of `Q()`ed calls generally end with a **passive function form** that returns the final value, not an intermediate Softanza object. To form the passive version of a function, turn the active form (a verb) into its past participle, e.g., `Uppercase` → `Uppercased`. Thus, the earlier chain becomes `Q("h e l l o").RemoveSpacesQ().Uppercased()`.

>**NOTE 3**: `@@(val)` is a small Softanza function, akin to a **pair of glasses** that enhances vision. It is designed to produce a readable string representation of any value `val`, which is useful in particular when `val` is a multi-level list. In our case, it beautifully generated the output [ [ "A", "A", "A" ], [ "A", "A", "A" ], [ "A", "A", "A" ] ]. Without it, the console would display a vertical list of nine "A"s.

## Multidimensional Structures

Grids, tables, and other complex data structures can also be generated with elegance and ease:

```ring
@@( Q("A").RepeatedXT(:InA = :Grid, :OfSize = [3, 3]) )
#-->
# [
# [ "A", "A", "A" ],
# [ "A", "A", "A" ],
# [ "A", "A", "A" ]
# ]

? @@( Q("A").RepeatedXT(:InA = :Table, :OfSize = [3, 3]) )
#--> [
# [ "COL1", [ "A", "A", "A" ] ],
# [ "COL2", [ "A", "A", "A" ] ],
# [ "COL3", [ "A", "A", "A" ] ]
# ]

? Q("A").RepeatXTQ(:InA = :Table, :OfSize = [3, 3]).ToStzTable().Show()
#-->
# COL1   COL2   COL3
# ----- ------ -----
#   A      A      A
#   A      A      A
#   A      A      A
```

In the last example, the list containing a table representation (thanks to the RepeatXT() function) has been transformed into a stzTable object, on which we called the function Show().

>**NOTE**: Wherever needed, Softanza provides a dedicated `Show()` function for each of its objects, allowing you to obtain a **pleasant** and **readable** string representation of their content.

## Practical Applications

The power of `RepeatXT()` extends far beyond simple examples, offering tangible benefits in real-world software development:
1. Rapid data initialization and prototyping  
2. Generating test and placeholder data  
3. Enforcing smart, automatic data type conversions  
4. Creating complex data structures efficiently  
5. Reducing boilerplate code  

---

## Conclusion

Softanza's repetition feature transcends traditional data manipulation approaches. It provides a concise, powerful, and intuitive way to **generate**, **transform**, and **replicate** values across diverse **data types** and **structures**.