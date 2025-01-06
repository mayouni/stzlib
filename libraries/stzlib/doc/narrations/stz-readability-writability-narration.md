# Writability vs. Readability of Computer Code— Softanza Asks: Why NOT Both?  
![An Arabic scholar **writing** his scientific discovery in a beautiful, **readable**, and artistic calligraphic style. By M.Ayouni, using Microsoft Image AI](../images/stz-functions-alterforms-namedparams.jpg)
*An Arabic scholar **writing** his scientific discovery in a beautiful, **readable**, and artistic calligraphic style.*

Imagine writing code that flows as naturally as your thoughts, where programming constructs mirror the linguistic patterns of human communication. This is the core philosophy of Softanza, a foundation library for the Ring programming language, yet a *computational thinking frameowork* that transforms code from a technical syntax into an expressive, intuitive language.

*By Mansour Ayouni (Creator of Softanza).*

---

## Introduction: Functions as Linguistic Expressions

Softanza redefines programming by treating functions as *linguistic expressions*, offering developers unparalleled flexibility in how they **write** and **read** code.

By reimagining function names and parameters through the lens of natural language patterns, Softanza creates an intuitive programming experience that closely mirrors how humans naturally think and communicate.

But don’t just take my word for it—see it in action as we explore the set of innovative features in this article!

>**NOTE**: In Softanza, as in Ring, the term `function` is used to refer to both functions and methods.

## Function Active Form: Functions as Imperative Actions

In Softanza, functions are by default expressed in their **active form**, directly acting upon objects *like imperative verbs in a sentence*. Consider a string manipulation example:

```ring
load "stzlib.ring"

o1 = new stzString("RIxxNxG")
o1.RemoveAll("x")  # Actively modifies the object
? o1.Content()
#--> RING
```

The `RemoveAll()` function exemplifies this active approach by directly acting on the object, akin to how a verb conveys immediate action in natural language.

Implicitly, the interaction adopts a *conversational* style: the program communicates with the `stzString` object, `o1`, as if addressing a person. It's as though saying, **"o1, remove all 'x's, please!"**—reminiscent of calling someone by name to request an action, as in, "**Dan! Remove these from the floor, please.**"


## Function Passive Form: Transformations Without Side Effects

Sometimes, you want to perform an operation without altering the original object. Softanza's **passive form** provides this capability:

```ring
o1 = new stzString("RIxxNxG")
? o1.AllRemoved("x")  # Returns a new transformed string
#--> RING

? o1.Content()  # Original object remains unchanged
#--> RIxxNxG
```

The `Removed()` function returns a new string while preserving the original object unchanged.

In natural language, the *past participle* often emphasizes a state rather than the action itself. For example, "If you find the door closed, then these are the keys" shifts focus from the act of closing to the *desired* condition of the door being closed. 

Similarly, in Softanza function design: 

1. **`o1.Remove()`** performs the action, altering `o1`'s state directly.  
2. **`o1.Removed()`**, like the past participle, represents `o1` in the *desired* state as if the removal occurred, without altering its actual state.  

This distinction mirrors human language grammar, making code semantics intuitive and state-focused.

## Function Fluent Form: Sculpting Transformations with Precision  

In Softanza, functions can be seamlessly chained to create a fluent sequence of transformations. For example:  

```ring
? Q("rixxnxg").  
    UppercaseQ().  
    ReplaceQ("I", :With = AHeart()).  
    SpacifyQ().  
    Removed("x")  

#--> R ♥ N G
```  

This example begins with the string `"rixxnxg"`, which is converted into an `stzString` object using the `Q()` function. The string is then transformed step by step: converting to uppercase, replacing characters, adding spaces, and removing specific characters. The chain concludes with the `Removed()` function, which terminates the sequence and returns the final result as a native Ring string, `"R ♥ N G"`.  

The `Q()` construct is central to this ***Chain of Actions***, enabling fluent transformations by returning an updated `stzString` object at each step. This approach makes complex string manipulations intuitive and expressive.  

Softanza offers two distinct styles of transformation. When using `QC` mode, each operation explicitly creates a new object, leaving the original unchanged. This ensures immutability and eliminates side effects, preserving state safety across the chain. For example:  

```ring
o1 = new stzString("rixxnxg")  

? o1.UppercaseQC().  
    ReplaceQC("I", :With = AHeart()).  
    SpacifyQC().  
    Removed("x")  

#--> R ♥ N G  

# The original object remains intact  
? o1.Content()  
#--> "rixxnxg"
```  

In contrast, using `Q` mode allows transformations to directly modify the original object, creating a dynamic and interactive sculpting experience:  

```ring
o1 = new stzString("rixxnxg")  

? o1.UppercaseQ().  
    ReplaceQ("I", :With = AHeart()).  
    SpacifyQ().  
    Removed("x")  

#--> R ♥ N G  

# The original object is altered  
? o1.Content()  
#--> R ♥ N G
```  

This flexibility allows developers to choose between immutability for state safety or direct modification for dynamic workflows, empowering them to tailor their approach to the requirements of their application.

## Function Partial Form: Opening a Second Avenue in the Transformation Chain

In the example in the Section *Function Passive Form: Transformations Without Side Effects* above, we wrote `o1.AllRemoved("x")` and demonstrated the power of using the `@PassiveForm` of the `Remove()` function.

However, this expression is not as linguistically elegant as natural language discourse. In fact, we would prefer to say: *All "x" removed*, in that order, rather than *"x" all removed!* – the latter sounds awkward, doesn't it?

This issue stems from how computer languages are inherently designed regarding objects and methods acting upon them. In all object-oriented programming languages, methods invoked on an object (e.g., `o1.Removed("x")`) operate on the object itself (`o1`) rather than on the parameter (`"x"`), which is merely part of the object's content.

Softanza *resolves* this limitation elegantly by allowing values like `"x"` to be interpreted *in context* of the main string, as a list of sections refelcting its occurrences in the string, temporarily stored in a hidden space during the chain. Using the `@Removed()` function, you instruct the Chain to *restore* the sections and *remove* them from the string. Thus, we can write:

```ring
o1 = new stzString("RIxxNxG")
? o1.@("x").@Removed()
#--> RING

# Or alternatively:
? o1.@All("x").@Removed()
```

This `@Removed()` function form is called `@FunctionPartialForm`. It enables Fluent Chains of Actions to open a *second avenue* of data manipulation, applying transformations not to the main object of the chain but to a **part** of it, mimicking natural language.

Switching between the two avenues is intuitive:
- When you use *normal* function forms (active or passive), you are transforming the main object (the `stzString "RIxxNxG"` in this case).
- When you use the *partial* form `@Removed()`, or any other function prefixed by `@`, you are **transforming the part**.

That's it.

Of course, the part must *exist* within the object's content (e.g., `"x"` in `"RIxxNxG"`). Otherwise, nothing happens.

```ring
? o1.@All("z").@Removed()
#--> RIxxNxG
```

Here’s an example of a more elaborated chain that *combines* both main functions and *partial* functions:

```ring
o1 = new stzString("__Ri__ng__")
? o1.@("__").
    @RemoveItQ().
    AndThenQ().
    UppercaseQ().TheString()

    #--> RING
```

Which we can write in even more elegant form without o1, and using an alternative of @() called @Take():

```ring
? Q("__Ri__ng__").
    @Take("__").
    @RemoveItQ().
    AndThenQ().
    UppercaseQ().TheString()

    #--> RING
```

Curious how the magic works? There’s no actual magic—just thoughtful design.

- The `@("__")` small function identifies the substring `"__"` inside the main string and stores its positions as sections `[[1, 2], [5, 6], [9, 10]]` in Softanza’s temporary memory.

- When the `@RemoveItQ()` partial function is invoked with its `@` prefix, it removes those sections from the main object. The updated `stzString` (now containing just `"Ring"`) is passed along the chain, thanks to the `Q()` suffix in `@RemoveItQ()`.

- `AndThenQ()` acts as a linguistic connector, further passing the updated `stzString` to the next function, `UppercaseQ()`. This main function operates on the main string, converting it to `"RING"`.

- Finally, `TheString()` serves as a linguistic *terminator* for the chain, returning the value `"RING"`.

## Function Plural Form: Pushing the Boundaries of Singularity

In Softanza, whenever a function operates on a *singular* element (e.g., a string, list, or number), it is guaranteed to have a counterpart that operates on collections of those elements (e.g., a list of strings, numbers, or lists). This design is both practical and efficient, eliminating the need for explicit loops and simplifying code and logic.

Let’s illustrate this with an example. Suppose we have a scrambled string that needs to be cleaned of special characters like `_`, `~`, or `*`. The solution involves identifying the sections occupied by these characters and removing them. While describing this process is quick, implementing it step-by-step can be more involved:

```ring
o1 = new stzString("__R~~~IN***G__")

# Finding the positions of the special characters

aSections1 = o1.FindAsSections("__") # Or o1.FindZZ("__")
? @@(aSections1)
#--> [ [1, 2], [13, 14] ]

aSections2 = o1.FindZZ("~~~")
? @@(aSections2)
#--> [ [4, 6] ]

aSections3 = o1.FindZZ("***")
? @@(aSections3)
#--> [ [9, 11] ]

# Merging all the sections into one list

aSections = Merge([ aSections1, aSections2, aSections3 ])
? @@(aSections)
#--> [ [1, 2], [4, 6], [9, 11], [13, 14] ]

# Removing the sections from the string

o1.RemoveSections(aSections)
? o1.Content()
#--> "RING"
```

Now, let’s explore the power of the `@PluralForm` for `Remove()` and see how it simplifies the same task in significantly fewer lines of code.

**Option 1: Using the Plural Form of the `Find()` Function**

First, we can use the plural version of the `Find()` function, called `FindMany()`:

```ring
o1 = new stzString("__R~~~IN***G__")

# Getting the positions of special characters as sections

aSections = o1.FindManyZZ(["__", "~~~", "***"])
? @@(aSections)
#--> [ [1, 2], [4, 6], [9, 11], [13, 14] ]

# Removing the sections from the string

o1.RemoveSections(aSections)
? o1.Content()
#--> "RING"
```

Here, we’ve reduced the number of lines while achieving the same result. But we can go even further by using the plural form of `Remove()` directly, skipping the intermediate step with `FindMany()`.

>**NOTE**: You got it! *Many* is the *suffix* used by Softanza to decorate functions and tranform them into their @PluralForm.

**Option 2: Using the `RemoveMany()` Function**

With `RemoveMany()`, we can directly remove the specified characters from the string:

```ring
o1 = new stzString("__R~~~IN***G__")

# Removing the special characters from the string

o1.RemoveMany(["_", "~", "*"])
? o1.Content()
#--> "RING"
```

This approach eliminates the need for intermediate steps entirely, showcasing the elegance and power of the `@FunctionPluralForm` in Softanza.

>**NOTE*: In the next section, you discover yet an other function that does the same job.


## Function ExceptionalForm: Handling Real-World Exceptions

In many real-world scenarios, we encounter cases where simple string processing fails to meet nuanced requirements. For example, consider the task of removing non-letter characters from the string `"__R~~~IN***G__"`. Using the standard `RemoveNonLetters()` function from the `stzString` class, this can be elegantly achieved:

```ring
o1 = new stzString("__R~~~IN***G__")
o1.RemoveNonLetters()

? o1.Content()
#--> "RING"
```

What if the goal was to preserve the boundary characters `"__"` while still removing other non-letter symbols?

This is where the `@ExceptionalForm` of the `RemoveNonLetters()` function proves invaluable. By leveraging `RemoveNonLettersExcept()`, you can specify exceptions to the removal rule.

Let’s consider the same string, but this time, retaining the underscore characters:

```ring
o1 = new stzString("__R~~~IN***G__")
o1.RemoveNonLettersExcept("_")

? o1.Content()
#--> "__RING__"
```

Additionally, a function with the **ExceptionalForm**, indicated by the `Exception()` suffix, can also be conjugated in its **PluralForm**. Here’s an example:  

```ring
o1 = new stzString("__R~~~IN***G---")
o1.RemoveNonLettersExceptMany([ "_", "-" ])

? o1.Content()
#--> "__RING__"
```  

This enhancement significantly expands the function's utility, enabling it to handle multiple exceptions simultaneously.  

The @PluralForm of a function is always inferred automatically by Softanza from its normal form. For instance, in the code above, you could simply write:  

```ring
o1.RemoveNonLettersExcept([ "_", "-" ])
```  

This concise form clearly conveys your intent to handle multiple exceptional characters, rather than just one.  


## Function Negative Form: Intuitive Logical Negations

Softanza simplifies logical **negations** by introducing direct negative function forms:

```ring
# Traditional approach
? NOT Q("*").IsLetter()
#--> TRUE

# Softanza's natural approach
? Q("*").IsNotLetter()
#--> TRUE

# Or even with an additional 'A' for semantic precision
? Q("*").IsNotALetter()
#--> TRUE
```  

This approach makes logical expressions more readable and closer to natural language, particularly when transforming complex logic like this:

```ring
o1 = new stzList([ "R", "I", "N", "G" ])

if NOT (o1.IsString() and o1.IsLowercase() and o1.Contains("♥")) and
   o1.NumberOfChars() < 5 and
   NOT o1.NumberOfChars().IsOdd()

    ? "It's ok!"
else
    ? "Oops!"
ok
```

Into a streamlined, linguistically intuitive expression like this:

```ring
o1 = new stzList([ "R", "I", "N", "G" ])

if o1.IsNotAString() and
   o1.IsNotInLowercase() and
   o1.DoesNotContain("♥") and

   o1.NumberOfChars() < 5 and
   o1.NumberOfCharsQ().IsNotOdd()

    ? "It's ok!"
else  
    ? "Oops!"
ok
#--? "It's ok!"
```  

Which version do you find cleaner and more expressive?

>**NOTE**: Function negative forms are not currently supported in all Softanza functions, but this is planned for the future.

## Function Alternative Forms: Flexibility in Expression

Softanza recognizes that developers, as human beings, think in diverse ways and therefore provides multiple approaches to express the same operation.

For example, consider an unordered list that needs to be ordered:

```ring
o1 = new stzList([ "C", "B", "A" ])

# Traditional approach
o1.Swap(1, 3)

? o1.Content()
#--> [ "A", "B", "C" ]
```

Alternatively, a more descriptive approach could be:

```ring
o1 = new stzList([ "C", "B", "A" ])
o1.SwapItems(1, 3)

? o1.Content()
#--> [ "A", "B", "C" ]
```

Here, we used `SwapItems()` instead of `Swap()`.

However, this flexibility isn't just a decorative feature—it's a solution for *semantic precision*, where the meaning can change depending on the intent:

- If we ara talking to someone who lacks context about the data and how it's stored (i.e., they don't know it's a list), using `SwapItems(1, 3)` is preferable, as the word *item* implies the container is a *list*.

- However, since the items are *characters*, we might want to communicate our specific intent more clearly by using `SwapChars(1, 3)` instead.

- Initially, if the reader of the code has the necessary context, a concise `Swap()` would be the most straightforward choice.


Similarly, `@FunctionAlternativeForms` feature offer flexibility in the function name composition itself:

```ring
o1 = new stzList([ 1, 2, "♥", 4, 5, "♥", "♥" ])

# Both are valid and equivalent

? o1.FindNthNext(2, "♥") #--> 6
? o1.FindNextNth(2, "♥") #--> 6
```

This means you won’t be blocked by an error message just because you wrote `Nth` before `Next` or vice versa—since both variations convey the same meaning to anyone!

## Function Named Parameters: Code as Narrative

In the previous section, we wrote `o1.SwapItems(1, 3)`. What if we further illuminate the reader by explaining that `1` and `3` are the positions of the items within `o1` that are to be swapped?

```ring
# Instead of cryptic 1 and 3 number
o1.SwapItems( :AtPositions = 1, :And = 3 )
```

The parameters names `:AtPositions` and `:And` make the code's intention immediately clear, reading almost like a natural language sentence.

The feature not only improves communication by clarifying the meaning of your code, but also serves as a *productivity tool* by eliminating the need to write separate documentation files to explain its use to other programmers. In fact, the code becomes *self-documenting*, readable, and understandable, as long as a human can read plain, natural language.

>**NOTE**: Softanza provides thousands of named parameters essential for practical use and can be easily extended to support additional ones as needed.

## Function Conditional Form: The Magic of W()

In Softanza, you can decorate functions with the `W()` suffix (W for *Where*), transforming them into *conditional* functions. Instead of providing parameters, you pass a condition in a string, making the logic more readable and concise.

For example:

```ring
o1 = new stzString("SOooooFTAaaannnNZA")
o1.RemoveWXT('Q(@char).isLowercase()') # remove all lowercase characters

? o1.Content()
#--> "SOFTANZA"
```

Here, the condition removes all lowercase characters, making the code clear and expressive.

In contrast, the traditional method involves looping through the string *in reverse* to avoid position shifts when removing characters:

```ring
o1 = new stzString("SOooooFTAaaannnNZA")
for i = o1.Content().Length() - 1 to 0 step -1
    if o1.Content()[i].isLowercase() then
        o1.Remove(i)
end

? o1.Content()
#--> "SOFTANZA"
```

While both approaches achieve the same result, the conditional approach in Softanza enhances your code by making it more *readable*, intuitive, and focused on the "what" of your goal, rather than the "how" of the computer's implementation.

Additionally, it is significantly more *writable*, reducing five lines of code to just one!

## Function Prefixes: Unlock Function Superpowers with Three Simple Letters

In Softanza, as we saw previously, you can easily find the positions of a character inside a string using the `FindAll` function:  

```ring
? Q("RINGORIALAND").FindAll("I")
# --> [2, 7]
```  

If you'd like to see those positions visually represented, the `viz` prefix provides a powerful enhancement:  

```ring
? Q("RINGORIALAND").vizFindAll("I")
# --> RINGORIALAND
#     -^----^-----
```  

The `viz` prefix adds a visual dimension to the output, making it more intuitive to locate the positions directly within the string.  

For an even more detailed visualization, the `vizFindBoxed` method displays the string in a boxed format, clearly highlighting the character:  

```ring
? Q("RINGORIALAND").vizFindBoxed("I") + NL
# -->
# ┌───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┐
# │ R │ I │ N │ G │ O │ R │ I │ A │ L │ A │ N │ D │
# └───┴─•─┴───┴───┴───┴───┴─•─┴───┴───┴───┴───┴───┘
```  

This feature is particularly useful for debugging and enhancing the programmer experience. By visually pinpointing specific characters or patterns, developers can better understand and analyze string data, making their workflows more efficient and error-free.

>**NOTE**: Later in this article, you’ll discover two more powerful prefixes: `dft` and `inf`. Until then, take a moment to guess what they might do!

## Function Suffixes: Master Parameters from the Function Name

Programming often involves working with functions that have multiple parameters whose purpose isn't immediately clear from the function names alone. Consider these common scenarios:

**Ambiguities in Parameter Meanings

```javascript
// In JavaScript
arrayUtils.slice(array, 0, 10, false);
```

Developers often ask:
- Does `10` represent a length or an end position?
- Is the end position inclusive or exclusive?
- What behavior does the boolean flag control?

```cpp
// In C++ Qt
QString str = "example";
int position = str.indexOf("e", 0, 3, 0);
```

Similar questions arise here:
- Does `3` indicate a count of characters to search or an end position?
- What does the final `0` represent—a flag, an option, or something else?
- Is case sensitivity being controlled somewhere?

These examples highlight how numeric parameters and boolean flags can obscure a function's intent, often requiring developers to consult documentation or resort to trial and error.

**How Softanza Addresses This Challenge**

Softanza introduces a system that uses suffixes in function names to provide clarity about the parameters. Let’s use the `CS` suffix (indicating case sensitivity) to demonstrate this approach:

```ring
// Basic removal of lowercase characters
str = new stzString("SOOooooFFfffTANNnnnZA")
str.RemoveMany(["o", "f", "n"])
// --> "SOOFFTANNZA"

// Adding the 'CS' suffix to indicate case sensitivity
str = new stzString("SOOooooFFfffTANNnnnZA")
str.RemoveManyCS(["o", "f", "n"], FALSE)
// --> "SOFTANZA"
```

By including the `CS` suffix, the function name `RemoveManyCS()` conveys key information about its parameters. From the three components of the name—`Remove`, `Many`, and `CS`—we infer the following:

1. A list of substrings to be removed, as suggested by the word `Many`.
2. A boolean flag to configure case sensitivity, as indicated by the suffix `CS`.

**Order and Structure of Parameters**

Not only does the function name tell us what parameters to provide, but it also indicates the order in which they should be written: `Many` > `CS` implies the list of substrings `[ "o", "f", "n" ]` comes first, followed by the boolean flag `FALSE`.

This becomes particularly useful when functions have multiple parameters. Consider this example:

```ring
o1 = new stzString("123456789RING")

# Finding the next occurrence of "ring" starting at position 5

? o1.FindNextSTCS("ring", 5, FALSE)
#--> 10
```

From the name, we know we must provide parameters that relate to each part of the function name, in the specified order:

- `Next`: We ask, "Next what?"—the next substring, of course. Hence, the first parameter is the substring being searched for. In our case, it's the `"ring"` param.

- `ST` (StartingAt): Indicates the position from which the search should start, represented by a numeric value. In our case, it's the `5` param.

- `CS` (CaseSensitivity): Specifies whether the search is case-sensitive, using a boolean. In our case, it's the `FALSE` param.

For improved clarity, this line can also be written using an alternative function name and named parameters:

```ring
o1.FindNextSubStringSTIBCS("ring", :StartingAt = 5, :CaseSensitivity = FALSE)
```

**Programmer Exprience by Design**

From a *writability* perspective, Softanza establishes a **mutual contract** between programmers and the system. Programmers explicitly define their intentions through **suffixes**, while Softanza enforces the parameter structure using its type system.

From a *readability* perspective, the suffixes immediately communicate the nature and behavior of the parameters, effectively creating a **self-documenting API**. This eliminates the need for external references, improving code clarity and making it easier for developers to understand and use functions.

Softanza’s approach ensures a smooth **Programmer Experience by Design**. Developers can focus on solving problems instead of deciphering ambiguous function signatures. This system bridges the gap between intention and implementation, making code more intuitive and expressive.


> **NOTE**: Softanza includes many other powerful suffixes (and prefixes), which will be explored in a dedicated article.

## Small Functions, With Grand Potential  

You've already encountered some of them in the sections above: `Q()`, `@()`, and `@@()`. Let's revisit these while introducing some new ones.

- **`Q(val)`**: Elevates the value `val` to the corresponding `stzObject`. For example:
  - `Q(5)` is equivalent to `new stzNumber(5)`.
  - `Q("Hi!")` becomes `new stzString("Hi!")`.
  - `Q([1, 2, 3])` results in `new stzList([1, 2, 3])`.

  The letter `Q` signifies making the object *Queryable*, like when we say:
  ```ring
  Q("Hi!").Count()
  #--> 3
  ```

  It also places the object in a *Queue of Actions* (or chain of actions), as in:
  ```ring
  Q("Hi!").RemoveQ("!").UppercaseQ().Content()
  #--> "HI"
  ```

- **`@@(val)`**: Like a pair of glasses providing clarity, this function delivers a readable string representation of the value `val`. It is especially helpful for lists, particularly deep ones:
  ```ring
  ? @@([1, [2, 3], 4])
  #--> "[ 1, [ 2, 3 ], 4 ]"
  ```

  >**NOTE**: Without `@@()`, the console displays a less readable, vertical list.

- **`@(val)`**: Used in Fluent Chains of Actions, this function introduces a partial value of the main object. The partial value can later be processed using a `@PartialFunction`, as explained in the related section above. Example:
  ```ring
  ? Q("__RING__").@("_").Removed() #--> "RING"
  ```

- **`QH()` and `QHH()`**: These derivatives of `Q()` generate a step-by-step trace of the object’s transformation within a chain of actions, making it easier to debug and understand the flow. Example:
  ```ring
  ? Qh(12500).
	AddQ(500).
	RetrieveQ(1500).
	DivideByQ(500).
	MultiplyByQ(2).
	History()

	#--> [ 13000, 11500, 23, 46 ]
  ```  

- **Quick Creators**: Handy shortcuts for creating native Ring values. For instance:

  - `L('"♥1" : "♥3"')` produces `[ "♥1", "♥2", "♥3" ]`.
  - `S([ 1, 2, 3 ])` generates the stringified form `"[ 1, 2, 3 ]"`.
  - `N("-12500")` creates the number `-12500` from the string `"-12500"`.

- **Other Utility Functions**: Functions such as `v()`, `Vr()`, `Vl()`, `VrVl()`, `Obj()`, and `@0()` simplify specific tasks. These will be covered in future articles in the documentation.

Primarily designed for *writeability*, these small functions aim to minimize the mental load of repetitive syntactic commands, fostering rapid coding reflexes. They empower developers to focus on solving problems and achieving objectives rather than being bogged down by complex syntax.

With such versatile tools, coding becomes not just efficient but genuinely enjoyable.

## Function Future Form: Programming the Future with Softanza

The following Ring code demonstrates a sequence of actions designed with foresight:

```ring
? BeforeQ('').UppercasingFQ("ringo").
	RemoveFFQ("o").FromItQ().
	SpacifyItQ().
	AndThenQ().ReturnIt()

    #--> R I N G
```

Here’s what happened behind the scenes:

1. The process begins with an empty string elevated by `Q()` into an empty `stzString` object. This sets the stage for subsequent transformations.

2. The `UppercasingFQ("ringo")` introduces two suffixes:
   - `F()` stands for **Future**, instructing Softanza to defer the `Uppercasing` action.
   - `Q()` ensures the object remains in an elevated state for chaining.  
   This action isn’t executed immediately but stored for a future moment in the chain.

3. The `RemoveFFQ("o")` function signals that it depends on any pending actions preceding it. The *doubled* `FF()` suffix triggers the execution of all deferred actions before performing the removal. Result: `Uppercasing` converts `"ringo"` to `"RING"`, and then `RemoveFF` eliminates `"o"` from it, leaving `"RING"`.

4. `FromItQ()` acts as a bridge, passing the processed `stzString` ("RING") to the next step.

5. `SpacifyItQ()` adds spaces between characters, transforming "RING" into `"R I N G"`. The chain concludes with `AndThenQ().ReturnIt()`, which finalizes the sequence and outputs the resulting string.


This feature introduces **algorithmic clarity and time-oriented thinking** into code by allowing developers to design solutions in a natural, human-like manner. By mapping actions along the axis of time, Softanza bridges the gap between *thought and execution*, providing:

- **Clarity in Execution:** Each action clearly expresses when and how it will occur.
- **Readable Workflow:** Chains are easy to understand, making code more maintainable.
- **Natural Thinking:** The flow reflects how we plan and describe solutions in real life.

This elegant synergy of *structure* and *foresight* exemplifies how **Function Future Form** transforms Softanza into a powerful tool for natural programming.


## Function Random Form: Gamification for Free

In this section, Softanza introduces an interesting feature called `@FunctionRandomForm`, which is made possible simply by adding a `rnd` prefix to (any) function. This powerful feature allows you to manipulate and interact with data in a fun and flexible way.

Let's imagine a scenario where we have a list of playing cards. The list is easily accessed and displayed as follows:

```ring
o1 = new stzList(Cards())

? @@NL(o1.Content()) + NL
#--> [
#   "🂡",
#   "🂢",
#   "🂣",
#   "🂤",
#   "🂥",
#   "🂦",
#   "🂧",
#   "🂨",
#   "🂩",
#   "🂪",
#   "🂫",
#   "🂭",
#   "🂮"
# ]
```

With `rndItems()`, we can retrieve random cards from the list:

```ring
? @@(o1.rndItems())
#--> [ "🂫" ]

? @@(o1.rndItems()) + NL
#--> [ "🂨", "🂥", "🂡", "🂧" ]
```

We can also specify how many random cards we want to retrieve using `rndNItems(n)`:

```ring
? @@(o1.rndNItems(3))
#--> [ "🂤", "🂨", "🂧" ]

? @@(o1.rndNItems(3)) + NL
#--> [ "🂧", "🂨", "🂡" ]
```

Not only can we retrieve random cards, but we can also remove a random number of cards from the list using `rndRemoveItems()`:

```ring
o1.rndRemoveItems()
? @@(o1.Content())
#--> [ "🂡", "🂢", "🂤", "🂥", "🂦", "🂧", "🂨", "🂩", "🂪", "🂮" ]

o1.rndRemoveItems()
? @@(o1.Content())
#--> [ "🂤", "🂥", "🂦", "🂧", "🂨", "🂩", "🂮" ]

o1.rndRemoveItems()
? @@(o1.Content()) + NL
#--> [ "🂥", "🂧", "🂨", "🂩", "🂮" ]
```

If we want to remove a specific number of random cards, we can use `rndRemoveNItems(n)`:

```ring
o1.rndRemoveNItems(3) + NL
? @@(o1.Content())
#--> [ "🂩", "🂪" ]
```

> **NOTE**: Currently, a few functions, including `rndItems()` and `rndRemove()`, have their @RandomForm implemented. Ultimately, Softanza will include these randomization features in all its functions, making gamification a first-class citizen in the design of the library.

To add more fun to the game, you can work with cards by their names and symbols. Using `CardsXT()`, that adds an `XT` suffix to the `Cards()` function, we can generate an eXTended list like this:

```ring
o1 = new stzList(CardsXT())
? @@NL(o1.Content())
#--> [
#   [ "ace", "🂡" ],
#   [ "two", "🂢" ],
#   [ "three", "🂣" ],
#   [ "four", "🂤" ],
#   [ "five", "🂥" ],
#   [ "six", "🂦" ],
#   [ "seven", "🂧" ],
#   [ "eight", "🂨" ],
#   [ "nine", "🂩" ],
#   [ "ten", "🂪" ],
#   [ "jack", "🂫" ],
#   [ "queen", "🂭" ],
#   [ "king", "🂮" ]
# ]
```

This randomization feature makes Softanza extremely versatile, whether you’re playing a card game or dealing with more complex data manipulation tasks!


## Function Deep Form: Recrusiveness Made Simple

Softanza dives effortlessly into the depths of any list, no matter how deeply *nested* it is. It can locate items—whether they are numbers, strings, lists, or (named) objects—within a list and all its inner structures. The results are returned as precise *paths*, offering a clear roadmap to each instance.

Imagine a nested list containing the word `"you"` at various levels:

```ring
load "stzlib.ring"

o1 = new stzList([
	"you",
	"other",
	[ "other", "you", [ "you" ], "other" ],
	"other",
	"you"
])

? @@( o1.DeepFind("you") )
#--> [ [ 1 ], [ 3, 2 ], [ 3, 3, 1 ], [ 5 ] ]
```

The paths returned pinpoint the locations of the word `"you"` within the structure:  
- **[ 1 ]** → The 1st item of the outer list.  
- **[ 3, 2 ]** → The 2nd item in the list located at the 3rd position of the outer list.  
- **[ 3, 3, 1 ]** → The 1st item in the list nested within the list at the 3rd position of the outer list.  
- **[ 5 ]** → The 5th item of the outer list.  

These paths can be used effortlessly to *retrieve*, *modify*, or *remove* items. For instance, replacing every occurrence of `"you"` with `"♥"` is as simple as calling the `DeepReplace()` method:

```ring
o1.DeepReplace("you", :By = "♥")

? @@NL( o1.Content() )
# #--> [
#	"♥",
#	"other",
#	[ "other", "♥", [ "♥" ], "other" ],
#	"other",
#	"♥"
# ]
```

Transformations are just as straightforward. To *uppercase* all occurrences of the word `"other"`, use the `DeepUppercase()` method. Softanza propagates the change throughout the structure automatically:

```ring
o1.DeepUppercaseString("other")

? @@NL( o1.Content() )
#--> [
#	"♥",
#	"OTHER",
#	[ "OTHER", "♥", [ "♥" ], "OTHER" ],
#	"OTHER",
#	"♥"
# ]
```

The same simplicity applies to removing items. Calling `DeepRemove()` with the desired value eliminates all its occurrences while preserving the structure's integrity:

```ring
o1.DeepRemove("OTHER")

? @@( o1.Content() )
#--> [ "♥", [ "♥", [ "♥" ] ], "♥" ]
```

Softanza’s `@DeepFunctionForms` showcase the power and elegance of working with complex, nested data structures. By *abstracting away recursion*, these methods allow developers to manipulate lists efficiently, accurately, and without the pitfalls of manual traversal.

## Multilingual Function Forms: Let Any Human Speak in Code  

In writing program code, English is no longer the only option—you can now communicate with Softanza in any language!  

Your code can be entirely in Arabic, Chinese, or even a mix of different languages within the same program.  

```ring
    Q("SOFTANZA") {

        # Get the first character in English code
        ? FirstChar()
        #--> "S"

        # Get the last character in French code (LastChar() in English)
        ? DernierCaractère()
        #--> "A"

        # Get the last character in Arabic code
        ? الحرف_الأخير()
        #--> "َA"

        # Get the number of characters in Chinese code (NumberOfChars() in English)
        ? 字符数()
        #--> 8
    }
```

> **Note**: Not all Softanza functions have been translated yet. However, a user-friendly translation mechanism is planned for the future to make this process seamless.  


## Function Free Form: Freedom to Define, Power to Execute

In Softanza, extracting a section from a string is simple:  

```ring
? Q("I love Ring").Section(8, 11)
#--> "Ring"
```  

Alternatively, you can use named parameters for clarity:  

```ring
? Q("I love Ring").Section(:From = 8, :To = 11)
#--> "Ring"
```  

But what if you forget the parameters or don't know their order? That's where **Function Free Forms (FF)** come in:  

```ring
? Q("I love Ring").SectionFF([])
#--> "I love Ring"
```  

Softanza, by default, returns the entire string (positions 1 to the end). You can also specify only some parameters:  

```ring
? Q("I love Ring").SectionFF([:From = 8])
#--> "Ring"
```  

Even if you invert the parameter order, it works seamlessly:  

```ring
? Q("I love Ring").SectionFF([:To = 11, :From = 8])
#--> "Ring"
```  

Now, consider the following string:  

```ring
o1 = new stzString("ring php ring ruby ring")
```  

Using `ReplaceNextOccurrence`, you can replace the first occurrence of a substring. Normally, the function requires three parameters:  

```ring
o1.ReplaceNextOccurrence(:Of = "ring", :StartingAt = 1, :With = "♥")
? Content()
#--> ♥ php ring ruby ring
```  

With the **FF** suffix, you can reduce the parameters and still get the same result:  

```ring
o1.ReplaceNextOccurrenceFF(["ring", :With = "♥"])
#--> ♥ php ring ruby ring
```  

You can reorder the parameters as you like:  

```ring
o1.ReplaceNextOccurrenceFF([:Of = "ring", :With = "♥", :StartingAt = 1])
#--> ♥ php ring ruby ring
```  

Or omit all parameters, letting Softanza infer the defaults:  

```ring
o1.ReplaceNextOccurrenceFF([])
#--> ♥ php ring ruby ring
```  

Here, Softanza intelligently defaults the `:Of` parameter to the first substring it encounters ("ring" in this case).  

**Function Free Forms** make Softanza functions flexible and intuitive, allowing users to define parameters in any order—or none at all—and achieve consistent results.  

## Function Default Form: Default Params Values, Made Computable!

In Softanza, using a function with its default values is straightforward. You have two flexible options:  

1. Add the `FF` suffix with `[]`, as shown in the previous section.  
2. Use the `dft` prefix, like this:  

```ring
? Q("I love Ring").dftRange()
# --> "I love Ring"
```  

This allows you to quickly apply a function while keeping its default values intact.  

If you want to gain insight into the parameters and their default values, Softanza provides another handy feature: the `inf` prefix. It provides a clear description of the parameters, their names, types, and default values:  

```ring
? Q("I love Ring").infRange()
# --> [
#   [ :Param = "pnStart", :Name = "from", :Type = "NUMBER", :Default = 1 ],
#   [ :Param = "pnRange", :Name = "to",   :Type = "NUMBER", :Default = 11 ]
# ]
```  

This makes it easy to understand how a function works and what defaults are available, simplifying the process of coding efficiently and relegating the need for documentation to a supporting role.

## Function Parameters Free Order: Parameters Your Way!

A small but valuable feature in practice: when a function contains two parameters of different types, you can provide these parameters in any order.

For example:

```ring
  Q("ring php ring python ring") {
    
    # You can place the number of occurrences before the substring
    ? FindNthOccurrence(2, "ring")
    #--> 10

    # Or place the substring before the number of occurrences
    ? FindNthOccurrence("ring", 2)
    #--> 10
  }
```

Regardless of the order, you still get the same result.

>**NOTE**: Not all functions with two parameters support this feature yet, but it is planned for a future release.

### Function Misspelled Form: Functions that Just Work  

In Softanza, when you write:  

```ring
? Q("   Ring ").WithoutSapces()
#--> Ring

? Q("bla {♥♥♥} blaba bla {♥♥♥} blabla").FindLasteAsSection("♥♥♥")
#--> [ 22, 24 ]

? QQ([ 2, 7, 18, 18, 10, 12, 25, 4 ]).NearstTo(10)
#--> 12
```  

You get what you want, but here’s the twist: all the function names are misspelled!

Look closely. This functionality, usually found in advanced IDE tools, is seamlessly integrated into Softanza’s library. The library recognizes and corrects minor typos in function names, mapping them to the closest valid definitions.

This feature dramatically improves the coding experience by reducing disruptions caused by trivial errors. It saves time, lowers frustration, and enhances accessibility for developers of all skill levels, especially those working in non-native languages.

Additionally, it simplifies the integration of such features into IDEs, as the intelligence resides in the library itself.

## Why It Matters: The Dual Benefits of Writable and Readable Code

Softanza's approach offers multiple advantages:

- **Accelerated Writability**: Developers experience reduced cognitive load, allowing them to express their ideas naturally in code.

- **Enhanced Readability**: Code becomes self-documenting and intuitive, making it easier for others and for your future self to understand.

- **Computational Thinking Flexibility**: Multiple ways to express the same logic cater to different thinking styles, freeing programmers from the constraints of rigid syntax.

- **Reduced Errors**: Clear, descriptive functions minimize misunderstandings, leading to more reliable, error-resistant code.

## Conclusion

Readability and writability are often perceived as *conflicting* goals in programming. Softanza’s innovative approach challenges this assumption, demonstrating that these two objectives can not only coexist but thrive *harmoniously*. By reimagining the concept of a *function* as a programmatic construct through the lens of human natural language, Softanza transforms functions into powerful artifacts. Each function hosts its own embedded domain-specific language, harnessing the structure, semantics, and behavior of its name, parameters, their order and types, as well as its overall output.  

This paradigm liberates developers from the constraints of rigid syntactical rules, empowering them to express their logic as intuitively and fluidly as they might in natural conversation. The result is a synthesis of clarity and efficiency, where code communicates intent as seamlessly as it executes tasks.