# Writability vs. Readability of Computer Code— Softanza Asks: Why NOT Both?  
![An Arabic scholar **writing** his scientific discovery in a beautiful, **readable**, and artistic calligraphic style. By M.Ayouni, using Microsoft Image AI](../images/stz-functions-alterforms-namedparams.jpg)
*An Arabic scholar **writing** his scientific discovery in a beautiful, **readable**, and artistic calligraphic style.*

Imagine writing code that flows as naturally as your thoughts, where programming constructs mirror the linguistic patterns of human communication. This is the core philosophy of Softanza, a foundation library for the Ring programming language, yet a *computational thinking frameowork* that transforms code from a technical syntax into an expressive, intuitive language.

---

## Introduction: Functions As Linguistic Expressions

Softanza introduces a unique approach to programming by treating functions as *linguistic expressions*, offering developers unprecedented flexibility in how they **write** and **read** code.

Through carefully designed features like `@FunctionActiveForm`, `@FunctionPassiveForm`, `@FunctionNegativeForm`, `@FunctionAlternativeForms`, `@FunctionNamedParams`, `@FunctionConditionalForm` and `@FunctionNameSuffixes`, Softanza breaks down the traditional barriers between human language and programming logic.


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
? o1.Removed("x")  # Returns a new transformed string
#--> RING

? o1.Content()  # Original object remains unchanged
#--> RIxxNxG
```

Here’s a refined version with repetitions eliminated and improved flow:

The `Removed()` function generates a new string while preserving the original object unchanged.

This mirrors the role of the *past participle* in language, which conveys a completed action and shifts focus to a new desired state of the subject, leaving its initial value intact.

Invoking `o1.Remove()` is akin to saying, *"Oh, o1! Show me your state with all 'x' remov**ed**."* Here, "removed" acts as a linguistic *descriptor*, not an effective *action*, emphasizing the transformation *output* without altering the *original* value of `o1`.

**@FunctionPassiveForm as a Terminator of @FluentChainsOfActions**

The true computational potential of the `@FunctionPassiveForm` feature is revealed when combined with a **Fluent Chain of Actions**, as shown below:

```ring
? Q("rixxnxg").UppercaseQ().ReplaceQ("I", :With = AHeart()).SpacifyQ().Removed("x")
#--> R♥NG
```

In this chain, a **copy-on-write mechanism** is applied to the initial `stzString` object created by `Q("RIxxNxG")`. At each step—Uppercasing, Replacing, Spacifying, and Removing—a new copy is generated, ensuring that the original object remains unaltered. This guarantees *side-effect-free* execution, a critical requirement in many real-world scenarios where maintaining program state integrity is essential.

>**NOTE**: Internally, the process happens efficiently, with the Ring VM's garbage collector handling intermediate copies and freeing up memory.

Importantly, the chain is intentionally *interrupted* by the `Removed()` function, which serves as a **terminator** in the sequence. Unlike previous steps that return a new `stzString` object, `Removed()` yields a native Ring string, signaling the conclusion of the fluent chain and ensuring a clean final output.

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
if NOT (o1.IsString() and o1.IsLowercase() and o1.Contains("♥")) and
   o1.NumberOfChars() < 5 and
   NOT o1.NumberOfChars().IsEven()

    ? "It's ok!"
else
    ? "Oops!"
ok
```

Into a streamlined, linguistically intuitive expression like this:

```ring
if o1.IsNotAString() and
   o1.IsNotInLowercase() and
   o1.DoesNotContain("♥") and

   o1.NumberOfChars() < 5 and
   o1.NumberOfCharsQ().IsNotEven()

    ? "It's ok!"
else  
    ? "Oops!"
ok  
```  

Which version do you find cleaner and more expressive?

>**NOTE**: Function negative forms are not currently supported in all Softanza functions, but this is planned for the future.

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

The `@FunctionNamedParams` feature illuminates function parameters (the values received between parentheses) with optional self-documenting labels, transforming the code from mere technical instructions into a clear, readable narrative.

An example:

```ring
# Instead of cryptic method calls
o1.SwapItems( :AtPositions = 1, :And = 3 )
```

The parameters `:AtPositions` and `:And` make the code's intention immediately clear, reading almost like a natural language sentence.

The feature not only improves communication by clarifying the meaning of your code, but also serves as a *productivity tool* by eliminating the need to write separate documentation files to explain its use to other programmers. In fact, the code becomes *self-documenting*, readable, and understandable, as long as a human can read plain, natural language.

>**NOTE**: Softanza provide thousands of named params needed in practice and can be extended easlity to support more of them.

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


## Function Suffixes: The Anatomy of Function Names

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

This naming structure helps programmers stay focused, organised, and in full control. They use `CS()` only when needed, establishing a common mental and syntactic contract with Softanza for the required parameters.

> **NOTE**: Softanza provides many other powerful yet useful suffixes (and prefixes), which will be explored in a dedicated article.

## Why It Matters: The Dual Benefits of Writable and Readable Code

Softanza's approach offers multiple advantages:

- **Accelerated Writability**: Developers experience reduced cognitive load, allowing them to express their ideas naturally in code.

- **Enhanced Readability**: Code becomes self-documenting and intuitive, making it easier for others and for your future self to understand.

- **Flexibility**: Multiple ways to express the same logic cater to different thinking styles, freeing programmers from the constraints of rigid syntax.

- **Reduced Errors**: Clear, descriptive functions minimize misunderstandings, leading to more reliable, error-resistant code.

## Conclusion

Readability and writability are often seen as *conflicting* goals in programming. Softanza’s approach challenges that notion, and demonstrates that they can indeed work together *harmoniously*. Developers are no longer constrained by rigid syntactical rules; instead, they are empowered to express their logic as naturally as they would in real-life conversation, achieving both clarity and efficiency in their code.