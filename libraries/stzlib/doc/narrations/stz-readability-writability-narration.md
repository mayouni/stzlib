# Writability vs. Readability of Computer Code— Softanza Asks: Why NOT Both?  
![An Arabic scholar **writing** his scientific discovery in a beautiful, **readable**, and artistic calligraphic style. By M.Ayouni, using Microsoft Image AI](../images/stz-functions-alterforms-namedparams.jpg)
*An Arabic scholar **writing** his scientific discovery in a beautiful, **readable**, and artistic calligraphic style.*

Imagine writing code that flows as naturally as your thoughts, where programming constructs mirror the linguistic patterns of human communication. This is the core philosophy of Softanza, a foundation library for the Ring programming language, yet a *computational thinking frameowork* that transforms code from a technical syntax into an expressive, intuitive language.

---

## Introduction: Functions As Linguistic Expressions

Softanza introduces a unique approach to programming by treating functions as *linguistic expressions*, offering developers unprecedented flexibility in how they **write** and **read** code.

Through carefully designed features like `@FunctionActiveForm`, `@FunctionPassiveForm`, `@FunctionFluentForm`, `@FunctionPartialForm`, `@FunctionPluralForm`, `@FunctionExceptionalForm`, `@FunctionNegativeForm`, `@FunctionAlternativeForms`, `@FunctionNamedParams`, `@FunctionConditionalForm`, `@FunctionNameSuffixes` and `@SmallFunctions`, Softanza breaks down the traditional barriers between human language and programming logic.

>**NOTE**: In Softanza, as in Ring, the term `function` is used interchangeably to refer to both functions and methods.

## Function Active Form: Functions as Direct Actions

In Softanza, functions are by default expressed in their **active form**, directly acting upon objects *like verbs in a sentence*. Consider a string manipulation example:

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

In natural language, the *past participle* often emphasizes a state rather than the action itself. For example, "If you find the door closed, then these are the keys" shifts focus from the act of closing to the desired condition of the door being closed. 

Similarly, in Softanza function design: 

1. **`o1.Remove()`** performs the action, altering `o1`'s state directly.  
2. **`o1.Removed()`**, like the past participle, represents `o1` in the desired state as if the removal occurred, without altering its actual state.  

This distinction mirrors linguistic grammar, making code semantics intuitive and state-focused.

## Function Fluent Form: Guiding the Programmer's Train of Thought

In Softanza, you can effortlessly *chain* multiple function calls, creating a smooth sequence of data transformations. For instance, consider the following example:

```ring
? Q("rixxnxg").
    UppercaseQ().
    ReplaceQ("I", :With = AHeart()).
    SpacifyQ().
    Removed("x")

#--> R♥NG
```

Here, the process begins with the string `"rixxnxg"` and concludes with `"R♥NG"`. In between, we apply a series of transformations: converting to uppercase, replacing characters, adding spaces, and removing specific characters.

This chaining is made possible by the *`Q()` suffix*, which allows functions to return objects that can be further processed in a continuous flow. This style of expression is often called a ***Chain of Actions***, and the `Q()` is what makes it ***fluent***.

A key feature of this approach is the famous **copy-on-write mechanism**. Each operation in the chain creates a *new copy* of the string, preserving the original object intact. This ensures that every step remains side-effect-free, crucial for maintaining state integrity in complex applications.

At the end of the chain, the `Removed()` function serves as a **terminator**. Unlike previous functions, it does not return an object that can be further processed but instead returns a native Ring string, marking the end of the chain and delivering the final result.

>**NOTE**: Internally, the process happens efficiently, with the Ring VM's garbage collector handling intermediate copies and freeing up memory.

## Function Partial Form: Opening a Second Avenue in the Transformation Chain

In the example in the Section *Function Passive Form: Transformations Without Side Effects* above, we wrote `o1.AllRemoved("x")` and demonstrated the power of using the `@PassiveForm` of the `Remove()` function.

However, this expression is not as linguistically elegant as natural language discourse. In fact, we would prefer to say: *All "x" removed*, in that order, rather than *"x" all removed!* – the latter sounds awkward, doesn't it?

This issue stems from how computer languages are inherently designed regarding objects and methods acting upon them. In all object-oriented programming languages, methods invoked on an object (e.g., `o1.Removed("x")`) operate on the object itself (`o1`) rather than on the parameter (`"x"`), which is merely part of the object's content.

Softanza *resolves* this limitation elegantly by allowing values like `x` to be interpreted *in context* of the main string, as a list of sections refelcting its occurrences in the string, temporarily stored in a hidden space during the chain. Using the `@Removed()` function, you instruct the Chain to *restore* the sections and *remove* them from the string. Thus, we can write:

```ring
o1 = new stzString("RIxxNxG")
? o1.@("x").@Removed() # Or o1.@All("x").@Removed()
#--> RING
```

This `@Removed()` function form is called `@FunctionPartialForm`. It enables Fluent Chains of Actions to open a *second avenue* of data manipulation, applying transformations not to the main object of the chain but to a **part** of it, mimicking natural language.

Switching between the two avenues is intuitive:
- When you use normal function forms (active or passive), you are transforming the main object (the `stzString` `"RIxxNxG"` in this case).
- When you use the partial form `@Removed()`, or any other function prefixed by `@`, you are transforming the part.

That's it.

Of course, the part must *exist* within the object's content (e.g., `"x"` in `"RIxxNxG"`). Otherwise, nothing happens.

Here’s an example of a longer chain that *combines* both main functions and partial functions:

```ring
o1 = new stzString("__Ri__ng__")
? o1.@("__").
    @RemoveItQ().
    AndThenQ().
    UppercaseQ().TheString()

    #--> RING

# Which we can write in even more elegant  form (without o1, and using an alternative of @() called @Take())

? Q("__Ri__ng__").
    @Take("__").
    @RemoveItQ().
    AndThenQ().
    UppercaseQ().TheString()

    #--> RING
```

Curious how the magic works? There’s no actual magic—just thoughtful design.

- The `@("__")` small function identifies the substring `"__"` and stores its positions as sections `[[1, 2], [5, 6], [9, 10]]` in Softanza’s temporary memory.
- When the `@RemoveItQ()` partial function is invoked with its `@` prefix, it removes those sections from the main object. The updated `stzString` (now containing `"Ring"`) is passed along the chain, thanks to the `Q()` suffix in `@RemoveItQ()`.
- `AndThenQ()` acts as a linguistic connector, further passing the updated `stzString` to the next function, `UppercaseQ()`. This main function operates on the main string, converting it to `"RING"`.
- Finally, `TheString()` serves as a linguistic *terminator* for the chain, returning the value `"RING"`.

## Function Plural Form: Pushing the Boundaries of Singularity

In Softanza, whenever a function operates on a singular element (e.g., a string, list, or number), it is guaranteed to have a counterpart that operates on collections of those elements (e.g., a list of strings, numbers, or lists). This design is both practical and efficient, eliminating the need for explicit loops and simplifying code and logic.

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

**Option 2: Using the `RemoveMany()` Function**

With `RemoveMany()`, we can directly remove the specified characters from the string:

```ring
o1 = new stzString("__R~~~IN***G__")

# Removing the special characters from the string

o1.RemoveMany(["__", "~~~", "***"])
? o1.Content()
#--> "RING"
```

This approach eliminates the need for intermediate steps entirely, showcasing the elegance and power of the `@FunctionPluralForm` in Softanza.

Here’s the improved and extended narration:

---

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


This is not just a convenience; it’s a game-changer in domains where flexibility and precision are crucial, such as in:

- **Data Cleaning for Structured Text:** When processing text for web forms or database entries, certain characters like underscores or hyphens may have semantic significance.
  
- **Log Parsing in System Administration:** Logs often contain identifiers or codes with specific characters that must be preserved while other parts are cleaned.
  
- **Text Normalization for Natural Language Processing (NLP):** In NLP workflows, text normalization often involves removing extraneous symbols while preserving meaningful ones, such as hashtags or mentions in social media posts.
  
- **Formatting Legal or Financial Documents:** Legal or financial documents frequently use specific formatting rules, where certain symbols are integral to the meaning, such as preserving currency symbols (`$`) or percentage signs (`%`).

Additionally, a function with the **ExceptionalForm**, indicated by the `Exception()` suffix, can also be conjugated in the **PluralForm**. Here’s how you can do it:

```ring
o1 = new stzString("__R~~~IN***G---")
o1.RemoveNonLettersExceptMany([ "_", "-" ]) # Or simply ...Excep()

? o1.Content()
#--> "__RING__"
```

This enhancement further extends the utility of the function, allowing it to handle multiple exceptions simultaneously.

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

In the previous section, we write `o1.SwapItems(1, 3)`. What if we further illuminate the reader by explaining that `1` and `3` are the positions of the items within `o1` that are to be swapped?

```ring
# Instead of cryptic method calls
o1.SwapItems( :AtPositions = 1, :And = 3 )
```

The parameters `:AtPositions` and `:And` make the code's intention immediately clear, reading almost like a natural language sentence.

The feature not only improves communication by clarifying the meaning of your code, but also serves as a *productivity tool* by eliminating the need to write separate documentation files to explain its use to other programmers. In fact, the code becomes *self-documenting*, readable, and understandable, as long as a human can read plain, natural language.

>**NOTE**: Softanza provides thousands of named parameters essential for practical use and can be easily extended to support additional ones as needed.

## Function Conditional Form: The Magic of W()

In Softanza, you can decorate functions with the `W()` suffix (W for *Where*), transforming them into *conditional* functions. Instead of providing parameters, you pass a condition in a string, making the logic more readable and concise.

For example:

```ring
o1 = new stzString("SOooooFTAaaannnNZA")
o1.RemoveWXT('@char.isLowercase()') # remove all lowercase characters

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


## Function Suffixes: Master Parameters from the Function Name

Modern programming frequently involves working with functions that have multiple parameters, where the purpose isn't immediately clear from the function names alone. Consider these common scenarios:

```javascript
# In Javascript
arrayUtils.slice(array, 0, 10, false);
```
Developers often ask:
- Does 10 represent a length or an end position?
- Is the end position inclusive or exclusive?
- What behavior does the boolean flag control?

```cpp
# In C++ Qt

QString str = "example";
int position = str.indexOf("e", 0, 3, 0);
```
Here, similar questions arise:
- Is 3 a count of characters to search or an end position?
- What does the final 0 represent - a flag, an option, or something else?
- Are we controlling case sensitivity somewhere?

These examples show how numeric parameters and boolean flags can obscure a function's intent, often requiring developers to consult documentation or experiment with test cases.

From a *writability* perspective, Softanza addresses this challenge by establishing a *mutual contract* between programmers and the system. Programmers explicitly define their intentions through *suffixes*, while Softanza acts as a type system controller, ensuring that the function parameters adhere to the specified structure.

From a *readability* perspective, the suffixes immediately convey the nature and behavior of parameters, effectively creating a self-documenting API. This not only improves the clarity of the code but also enhances the developer's understanding without the need for external references.

Let's take the `CS()` suffix as an example of how to add case sensitivity check to a Softanza function.:

```ring
// Basic removal of lowercase characters

str = new stzString("SOOooooFFfffTANNnnnZA")
str.RemoveMany([ "o", "f", "n" ])
#--> "SOOFFTANNZA"

// Adding CS suffix for checking case sensitivity

str = new stzString("SOOooooFFfffTANNnnnZA")
str.RemoveManyCS([ "o", "f", "n" ], FALSE)
#--> "SOFTANZA"
```

Finally, by allowing the combination of *suffixes* and *named parameters*, Softanza ensures extreme clarity:

```ring
str.RemoveManyCS([ "o", "f", "n" ], :CaseSensitive = FALSE)
```

This system provides a smooth *Programmer Experience by Design*, ensuring that developers focus on solving problems rather than interpreting functions and their parameters.

> **NOTE**: Softanza includes many other powerful suffixes (and prefixes), which will be explored in a dedicated article.


Your text is well-written and clear. Below are minor suggestions to enhance readability and flow:  

---

## Small Functions, With Grand Potential  

You've discovered some of them in the sections above: `Q()`, `@()`, and `@@()`. Let's revisit their utility while introducing new ones.

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

  >**NOTE**: Without `@@()`, the console might display a less readable, vertical list.

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
  - `S()` generates strings.
  - `N()` creates numbers.

- **Other Utility Functions**: Functions such as `v()`, `Vr()`, `Vl()`, `VrVl()`, `Obj()`, and `@0()` simplify specific tasks. These will be covered in future articles in the documentation.

Primarily designed for *writeability*, these small functions aim to minimize the mental load of repetitive syntactic commands, fostering rapid coding reflexes. They empower developers to focus on solving problems and achieving objectives rather than being bogged down by complex syntax.

With such versatile tools, coding becomes not just efficient but genuinely enjoyable.

## Function Future Form

## Function Random Form: Gamification for Free


## Why It Matters: The Dual Benefits of Writable and Readable Code

Softanza's approach offers multiple advantages:

- **Accelerated Writability**: Developers experience reduced cognitive load, allowing them to express their ideas naturally in code.

- **Enhanced Readability**: Code becomes self-documenting and intuitive, making it easier for others and for your future self to understand.

- **computational Thinking Flexibility**: Multiple ways to express the same logic cater to different thinking styles, freeing programmers from the constraints of rigid syntax.

- **Reduced Errors**: Clear, descriptive functions minimize misunderstandings, leading to more reliable, error-resistant code.

## Conclusion

Readability and writability are often seen as *conflicting* goals in programming. Softanza’s approach challenges that notion, and demonstrates that they can indeed work together *harmoniously*. Developers are no longer constrained by rigid syntactical rules; instead, they are empowered to express their logic as naturally as they would in real-life conversation, achieving both clarity and efficiency in their code.