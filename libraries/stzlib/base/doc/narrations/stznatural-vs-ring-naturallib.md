# Why I Built `stzNatural`: A Journey from Ring’s NaturalLib to Softanza’s own Natural system

When I first discovered Ring’s **NaturalLib**, I was both inspired and excited. It lets you write `count from 1 to 5` and have it run as real code—using English words.

I tried to build my vision on top of it. But I kept hitting a wall: **NaturalLib is designed for *commands*, not *narratives*.**

I didn’t want to trigger isolated actions.  
I wanted to **transform one object through a sequence of natural steps**—like a human would describe a task.

I needed a natural code that constructs a **complete computational model in memory *before* executing anything**, so I can apply all the gymnastcis required by natural langauge semantics (deferred execution) before tunring human words to Ring code.

So I built `stzNatural` from scratch. Not to replace the Natural Library—but to explore a different path: **focused, object-centric natural programming**.

This made Softanza `stzNatural` different by design then Ring `NaturalLib` on several aspects.

## The Molecular Design Principle

`stzNatural` operates on a simple but powerful rule:  
> **Each natural block works on exactly one Softanza object.**

This means:
- You **create one object** (`Create a string…`),
- Then **apply any of its methods** (`Uppercase`, `Box`, `Replace`, etc.),
- Using **pronouns** (`it`, `this_`) that always refer to that object,
- And **modifiers** (`@box … the box@`) that refine actions in context.

This isn’t restrictive—it’s **liberating**:
- No ambiguity about scope,
- No need for complex state management,
- Maximum performance (only one object in memory),
- Full method fluency (every verb = real method).

In contrast, the Ring's standard `NaturalLib` treats each phrase as a standalone command with no shared context. You can’t say *“box it”* because there is no *“it.”*


## Deferred Execution: Thinking Before Acting

Ring `NaturalLib` executes commands **as they appear**.  
`stzNatural` **captures the entire block first**, stores it in an internal computational graph, then compiles it into efficient Ring code, only when the natural statement is closed using the "}" brace.

Why? Because humans **plan before they act**.  
> “@Box the string—but make the box@ rounded.”

This requires remembering an action, then refining it later.  
Only possible with **deferred compilation**.


## 🗣️ Vocabulary Freedom, with Focused Computable Keywords

In `stzNatural`, **only words defined in the semantic dictionary are interpreted**. All others become literals—no pre-nullification needed. A pragamtic design choise that makes a hudge performance difference.

The `ignored_words` list (e.g., `"a"`, `"with"`, `"containing"`) exists **only to enable natural phrasing around structural boundaries**—like `Create a string` or `Replace X with Y`.

This lets you write fluently **without compromising parsing integrity**.


## Data-driven, Config-only Multilingualism

Ring `NaturalLib`: duplicate command files per language.  
`stzNatural`: one semantic core, many linguistic skins, unique implementation code.

English `"uppercase"`, Hausa Latin `"maida"`, and Hausa Ajami `"ميّرد"` all map to the same `METHOD_UPPERCASE`. The implementation engine does not care of translated semantics, only `METHOD_UPPERCASE` is delt with.

Add a language? Just add a data block (in devtime or runtime), no files to manage, no `load`s to care about, no `if/then`s inside the implementation code.


## ✨ Conclusion

`stzNatural` enables:
- Fluent, stateful chains on **one object**,
- Deferred modifiers via `@...@`,
- Multilingual expression (English, French, Arabic, Latin, Ajami, and beyond),
- Full devtime introspection (`.Code()`, `.Result()`, `.DebugLog()`),
- And native eval Ring performance.