## Writability vs. Readability — Softanza Asks: Why NOT Both?  
![An Arabic scholar **writing** his scientific discovery in a beautiful, **readable**, and artistic calligraphic style. By M.Ayouni, using Microsoft Image AI](../images/stz-functions-alterforms-namedparams.jpg)
*An Arabic scholar **writing** his scientific discovery in a beautiful, **readable**, and artistic calligraphic style.*

**Imagine this**: you’re solving a problem, and your ideas are flowing. Your code should keep pace, feeling as intuitive and expressive as your thoughts. That’s the essence of the Softanza dual **writability** and **readability** promise.

---

## Introduction

I designed Softanza to let my code flow as naturally as my thoughts, balancing ease of writing with clarity of reading. This dual commitment shapes two guiding principles:

1. **Writability**: Code that is effortless to craft.
2. **Readability**: Code that explains itself and is instantly clear, even months later.

This harmony is achieved through many standout features in Softanza. This article illuminates two of them: `@FunctionAlternativeForms` and `@FunctionNamedParams`. Let’s see how they come together in action.


## The Problem: Swapping Items in a List

Suppose you have a list:

```ring
o1 = new stzList([ "C", "B", "A" ])
```

You need to swap two items to get a well sorted version of it. Softanza offers you choices in how to express this operation. You can write:

```ring
o1.Swap(1, 3)
? o1.Content()
#--> ["A", "B", "C"]
```

Or, if you want a more descriptive and natural language-like approach, you can write:

```ring
o1.SwapItems( :AtPositions = 1, :And = 3 )
? o1.Content()
#--> ["C", "B", "A"]
```

## @FunctionAlternativeForms: Freedom in Expression

Flexibility in Softanza isn't just a buzzword—it's a core principle brought to life. One of its most practical manifestations is this: programming should never feel like a spelling test! Thanks to Function Alternative Forms, it doesn’t have to.

In Softanza, every function comes with its own set of `@FunctionAlternativeForms`, designed to match a variety of thinking styles. Whether you choose `Swap` or `SwapItems`, the meaning remains crystal clear. Softanza allows you to express your ideas in the way that best aligns with your mental model, without penalizing you for spelling it one way or another.

This philosophy extends to countless other functions. For example:

```ring
o1.FindNthNext(elm)
```  

can also be written as:

```ring
o1.FindNextNth(elm)
```  


Whether you write `Nth` before `Next` or the other way around, both forms are equally valid, ensureing a seamless and intuitive writing experience.


## Enhanced Clarity with @FunctionNamedParams

Now, let’s return to the example of swapping items. What if you want your code to go beyond functionality and actively explain itself? That’s where **Named Parameters** come in.

In the example:

```ring
o1.SwapItems( :AtPositions = 1, :And = 3 )
```

Named parameters like `:AtPositions` and `:And` convey semantic meaning, turning your code into a clear and self-documenting narrative. They allow you to write in a way that mirrors natural language, making the purpose of your operations unmistakable.

Softanza comes preloaded with thousands of named parameters, each carefully designed to enhance clarity and reduce ambiguity. With these, your code doesn’t just solve problems—it tells a story.


## Why These Features Matter

Softanza’s focus on **Function Alternative Forms** and **Named Parameters** ensures that you don’t have to compromise between ease of writing and clarity for readers. Here’s how:

- **@FunctionAlternativeForms** empower you to write code in the way that feels most natural to you, without being constrained by rigid naming conventions.
- **@FunctionNamedParams** add semantic richness, making your code as readable as a well-written sentence.


## Conclusion

Together, these features make Softanza such a thoughtful programming framework that adapts to your needs, whether you're focused on rapid prototyping or long-term maintainability.