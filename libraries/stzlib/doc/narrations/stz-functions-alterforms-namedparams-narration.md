## Writability vs. Readability: Why Not Both?  
![Softanza is Both Writable and Readable, by Microsoft Image AI](../images/stz-functions-alterforms-namedparams.jpg)

Imagine this: you’re solving a problem, and your ideas are flowing. Your code should keep pace, feeling as intuitive and expressive as your thoughts. That’s the essence of the Softanza dual **writability** and **readability** promise.

---

## Introduction

Softanza is designed with a promise: your code should flow as naturally as your thoughts, balancing ease of writing with clarity for readers. This dual commitment shapes two guiding principles:

1. **Writability**: Code that is effortless to craft.
2. **Readability**: Code that explains itself and is instantly clear, even months later.

This harmony is achieved through many standout features in Softanza. This article illuminates two of them: **Function Alternative Forms** and **Named Parameters**. Let’s see how they come together in action.


## The Problem: Swapping Items in a List  

Suppose you have a list:  

```ring
o1 = new stzList([ "C", "B", "A" ])
```

You need to swap two items. Softanza offers you choices in how to express this operation. You can write:  

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

This flexibility is possible because of **Function Alternative Names**. Every function in Softanza is paired with its `@FunctionAlternativeForm` designed to suit different thinking styles. Whether you prefer `Swap` or `SwapItems`, the meaning is clear. Softanza ensures that your choice of expression aligns with your mental model, without penalizing you for spelling it differently.  

This philosophy extends to countless other functions. For example:  

```ring
o1.FindNthNext(elm)
```  

can also be written as:  

```ring
o1.FindNextNth(elm)
```  


Whether you write `Nth` before `Next` or the other way around, both forms are equally valid. This flexibility in naming ensures a seamless and intuitive writing experience.  


## Enhanced Clarity with Named Parameters  

Now, let’s return to the example of swapping items. What if you want your code to go beyond functionality and actively explain itself? That’s where **Named Parameters** come in.  

In the example:  

```ring
o1.SwapItems( :AtPositions = 1, :And = 3 )
```

Named parameters like `:AtPositions` and `:And` convey semantic meaning, turning your code into a clear and self-documenting narrative. They allow you to write in a way that mirrors natural language, making the purpose of your operations unmistakable.

Softanza comes preloaded with thousands of named parameters, each carefully designed to enhance clarity and reduce ambiguity. With these, your code doesn’t just solve problems—it tells a story.


## Why These Features Matter  

Softanza’s focus on **Function Alternative Forms** and **Named Parameters** ensures that you don’t have to compromise between ease of writing and clarity for readers. Here’s how:  

- **Function Alternative Forms** empower you to write code in the way that feels most natural to you, without being constrained by rigid naming conventions.  
- **Named Parameters** add semantic richness, making your code as readable as a well-written sentence.  


## Conclusion

Together, these features make Softanza thinking-oriented programming framework that adapts to your needs, whether you’re focused on rapid prototyping or long-term maintainability.