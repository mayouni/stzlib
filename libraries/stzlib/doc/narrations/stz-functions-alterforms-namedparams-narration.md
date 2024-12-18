## Writability vs. Readability — Softanza Asks: Why NOT Both?  
![An Arabic scholar **writing** his scientific discovery in a beautiful, **readable**, and artistic calligraphic style. By M.Ayouni, using Microsoft Image AI](../images/stz-functions-alterforms-namedparams.jpg)
*An Arabic scholar **writing** his scientific discovery in a beautiful, **readable**, and artistic calligraphic style.*

Imagine writing code that flows as naturally as your thoughts, where programming constructs mirror the linguistic patterns of human communication. This is the core philosophy of Softanza, a foundation library for the Ring programming language, yet a computational thinking frameowork that transforms code from a technical syntax into an expressive, intuitive language.

---

# Introduction: A New Paradigm in Programming

Softanza introduces a unique approach to programming by treating functions as *linguistic expressions*, offering developers unprecedented flexibility in how they **write** and **read** code.

Through carefully designed features like `@FunctionActiveForms`, `@FunctionPassiveForms`, `@FunctionNegativeForms`, `@FunctionAlternativeForms`, and `@FunctionNamedParams`, Softanza breaks down the traditional barriers between human language and programming logic.


## Function Active Form: Functions as Direct Actions

In Softanza, functions are by default expressed in their **active form**, directly acting upon objects *like verbs in a sentence*. Consider a string manipulation example:

```ring
load "stzlib.ring"

o1 = new stzString("RIxxNxG")
o1.RemoveAll("x")  # Actively modifies the object
? o1.Content()
#--> RING
```

The `RemoveAll()` function acts directly on the object, mirroring how a verb implies immediate action in natural language.

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

For instance, when you say "The object has been *removed*," the action of removal happened in the past, and the word **"removed"** serves as a *descriptor*, drawing attention to the object's *current* state *without* altering its essence.

This analogy emphasizes how the `Removed()` function doesn't modify the original object, just like the *past participle describes an event that has occurred without changing the core subject*.


## Function Negative Form: Intuitive Logical Negations

Softanza simplifies logical **negations** by introducing direct negative function forms:

```ring
# Traditional approach
? NOT Q("*").IsLetter()

# Softanza's natural approach
? Q("*").IsNotLetter()
```

This approach makes logical expressions more readable and closer to natural language.


## Flexibility in Expression: Function Alternative Forms

Softanza acknowledges that developers think differently and offers multiple ways to express the same operation:

```ring
o1 = new stzList([ "C", "B", "A" ])

# Traditional approach
o1.Swap(1, 3)

# More descriptive approach
o1.SwapItems( :AtPositions = 1, :And = 3 )
```

Both methods achieve the same result, allowing developers to choose the most intuitive expression. However, this flexibility isn't just a decorative feature—it's a solution for semantic precision, where the meaning can change depending on the intent:

- If the reader lacks context about the data and how it's stored (i.e., they don't know it's a list), using `SwapItems(1, 3)` is preferable, as the word *item* implies the container is a *list*.

- However, since the items are characters, you might want to communicate your specific intent more clearly by using `SwapChars(1, 3)` instead.

- If the reader is already aware of the context, all of this might be unnecessary, and a concise `Swap()` would be the best choice.


Similarly, function alternative names offer flexibility:

```ring
# Both are valid and equivalent
o1.FindNthNext(element)
o1.FindNextNth(element)
```

This means you're not penalized by an error message just because you spelled the function name one way or the other!

## Named Parameters: Code as Narrative

Named parameters transform code from a technical instruction to a readable narrative:

```ring
# Instead of cryptic method calls
o1.SwapItems( :AtPositions = 1, :And = 3 )
```

The parameters `:AtPositions` and `:And` make the code's intention immediately clear, reading almost like a natural language sentence.

## Why This Matters: The Benefits of Natural-Oriented Programming

Softanza's approach offers multiple advantages:

1. **Enhanced Readability**: Code becomes self-documenting and intuitive.
2. **Reduced Cognitive Load**: Developers can express ideas more naturally.
3. **Flexibility**: Multiple ways to write the same logic accommodate different thinking styles.
4. **Reduced Errors**: Clear, descriptive methods minimize misunderstandings.

## Conclusion

Softanza is more than a library—it's a paradigm shift. By treating code as a form of communication, it bridges the gap between human language and programming logic. Developers are no longer constrained by rigid syntactical rules but empowered to express their logic as naturally as they would in conversation.