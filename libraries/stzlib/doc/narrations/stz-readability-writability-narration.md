# Writability vs. Readability — Softanza Asks: Why NOT Both?  
![An Arabic scholar **writing** his scientific discovery in a beautiful, **readable**, and artistic calligraphic style. By M.Ayouni, using Microsoft Image AI](../images/stz-functions-alterforms-namedparams.jpg)
*An Arabic scholar **writing** his scientific discovery in a beautiful, **readable**, and artistic calligraphic style.*

Imagine writing code that flows as naturally as your thoughts, where programming constructs mirror the linguistic patterns of human communication. This is the core philosophy of Softanza, a foundation library for the Ring programming language, yet a *computational thinking frameowork* that transforms code from a technical syntax into an expressive, intuitive language.

---

## Introduction: Functions As Linguistic Expressions

Softanza introduces a unique approach to programming by treating functions as *linguistic expressions*, offering developers unprecedented flexibility in how they **write** and **read** code.

Through carefully designed features like `@FunctionActiveForm`, `@FunctionPassiveForm`, `@FunctionNegativeForm`, `@FunctionAlternativeForms`, `@FunctionNamedParams`, `@FunctionConditionalForm` and `@FunctionNameAnatomy`, Softanza breaks down the traditional barriers between human language and programming logic.


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

Implicitly, the interaction adopts a *conversational* style: the program communicates with the `stzString` object, `o1`, as if addressing a person. It's as though saying, **"o1, remove all 'x's, please!"**—reminiscent of calling someone by name to request an action, as in, "**Dan! Come here, please.**"


## Function Passive Form: Transformations Without Side Effects

Sometimes, you want to perform an operation without altering the original object. Softanza's **passive form** provides this capability:

```ring
o1 = new stzString("RIxxNxG")
? o1.Removed("x")  # Returns a new transformed string
#--> RING

? o1.Content()  # Original object remains unchanged
#--> RIxxNxG
```

The `Removed()` function generates a new string, leaving the original object unchanged. 

This is similar to expressing an action in the *past participle*, where the action has *already* been completed, and the object is now merely being referenced.

Linguistically speaking, when you say, "*The object has been *removed**," the action of removal happened in the past, and the word "**removed**" serves as a *descriptor*, drawing attention to the object's *current* state *without* altering its essence.

This analogy underscores the behavior of the `Removed()` function—it creates a new string while leaving the original object untouched, just as the *past participle* describes a completed event without modifying the subject itself.


## Function Negative Form: Intuitive Logical Negations

Softanza simplifies logical **negations** by introducing direct negative function forms:

```ring
# Traditional approach
? NOT Q("*").IsLetter()

# Softanza's natural approach
? Q("*").IsNotLetter()

# Or even with an additiona 'A' for a sense of semantic precision
? Q("*").IsNotALetter()
```

This approach makes logical expressions more readable and closer to natural language.


## Flexibility in Expression: Function Alternative Forms

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
o1.SwapItems( :AtPositions = 1, :And = 3 )

? o1.Content()
#--> [ "A", "B", "C" ]
```

Both approaches achieve the same result, allowing us to choose the most intuitive expression.

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

The @FunctionNamedParams feature illuminates function parameters (the values received between parentheses) with optional self-documenting labels, transforming the code from mere technical instructions into a clear, readable narrative.

An example:

```ring
# Instead of cryptic method calls
o1.SwapItems( :AtPositions = 1, :And = 3 )
```

The parameters `:AtPositions` and `:And` make the code's intention immediately clear, reading almost like a natural language sentence.

## Function Conditional Form: The Magic of W()

In Softanza, you can enhance functions with the `W()` suffix (W for *Where*), transforming them into conditional functions. Instead of providing parameters, you pass a condition in a string, making the logic more readable and concise.

For example:

```ring
o1 = new stzString("SOooooFTAaaannnNZA")
o1.RemoveWXT('@char.isLowercase()') # remove all lowercase characters

? o1.Content()
#--> "SOFTANZA"
```

Here, the condition removes all lowercase characters, making the code clear and expressive.

In contrast, the traditional method involves looping through the string in reverse to avoid position shifts when removing characters:

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


## The Anatomy of Function Names

One common challenge programmers face is inferring the parameters of a function from its name. Typically, this isn’t straightforward, and searching through documentation or the internet becomes necessary.

The problem, in addition to the time it takes, is that it disrupts the programmer’s train of thoughts. Usually, they’re forced to put the problem at hand on hold while crafting test cases to understand the parameters, their types, and how the function behaves—whether it modifies them by reference, returns a value, and so on.

Softanza addresses these issues by designing a clear function name structure, adding short **suffixes** to the core function name (and *prefixes*, though this is outside the scope of this article). These syntactic additions explicitly convey information about the parameters and output.

Let’s look at an example of this approach:

```ring
o1 = new stzString("SOOooooFFfffTANNnnnZA")
o1.RemoveMany([ "o", "f", "n" ])
#--> "SOOFFTANNZA"
```

In this case, the lowercase `"o"`, `"f"`, and `"n"` characters are removed, but their uppercase counterparts remain. To remove them together while making the function *case-sensitive*, you can use:

```ring
o1 = new stzString("SOOooooFFfffTANNnnnZA")
o1.RemoveManyCS([ "o", "f", "n" ], FALSE)

? o1.Content()
#--> "SOFTANZA"
```

Here, we’ve added the `CS()` suffix to the `RemoveMany()` function, instructing Softanza to consider case sensitivity based on the *second* parameter.

This naming structure keeps the programmer clear and focused. They use `CS()` only when needed, establishing a common mental and syntactic contract with Softanza for the required parameters

> **NOTE**: Softanza provides many powerful and useful suffixes (and prefixes), which will be explored in a dedicated article.

## Why It Matters: The Dual Benefits of Writable and Readable Code in Softanza

Softanza's approach offers multiple advantages:

- **Accelerated Writability**: Developers experience reduced cognitive load, allowing them to express their ideas naturally in code.

- **Enhanced Readability**: Code becomes self-documenting and intuitive, making it easier for others and for your future self to understand.

- **Flexibility**: Multiple ways to express the same logic cater to different thinking styles, freeing programmers from the constraints of rigid syntax.

- **Reduced Errors**: Clear, descriptive functions minimize misunderstandings, leading to more reliable, error-resistant code.

## Conclusion

Readability and writability are often seen as *conflicting* goals in programming. Softanza’s approach challenges that notion, and demonstrates that they can indeed work together *harmoniously*. Developers are no longer constrained by rigid syntactical rules; instead, they are empowered to express their logic as naturally as they would in real-life conversation, achieving both clarity and efficiency in their code.