# Why I Built `stzNatural`: A Journey from Ring's NaturalLib to Softanza's Natural System

_By Mansour Ayouni, Creator of Softanza library_

When I first discovered Ring's **NaturalLib**, I was both inspired and excited. It lets you write `count from 1 to 5` and have it run as real code—using English words.

I tried to build my vision on top of it. But I kept hitting a wall: **NaturalLib is designed for _commands_, not _narratives_.**

I didn't want to trigger isolated actions.\
I wanted to **transform one object through a sequence of natural steps**—like a human would describe a task.

I needed natural code that constructs a **complete computational model in memory _before_ executing anything**, so I could apply all the gymnastics required by natural language semantics (deferred execution) before turning human words into Ring code.

So I built `stzNatural` from scratch. Not to replace NaturalLib—but to explore a different path: **focused, object-centric natural programming**.

This made Softanza's `stzNatural` different by design from Ring's `NaturalLib` on several fundamental aspects.

***

## The Molecular Design Principle

`stzNatural` operates on a simple but powerful rule:

> **Each natural block works on exactly one Softanza object.**

This means:

* You **create one object** (`Create a string…`),
* Then **apply any of its methods** (`Uppercase`, `Box`, `Replace`, etc.),
* Using **pronouns** (`it`, `this`) that always refer to that object,
* And **modifiers** (`@box … box@`) that refine actions in context.

This isn't restrictive—it's **liberating**:

* No ambiguity about scope,
* No need for complex state management,
* Maximum performance (only one object in memory),
* Full method fluency (every verb = real method).

In contrast, Ring's standard `NaturalLib` treats each phrase as a standalone command with no shared context. You can't say _"box it"_ because there is no _"it."_

***

## String-Based Natural Code: 10X Performance Leap

**The Strategic Decision:**

Initially, `stzNatural` used Ring's brace syntax (`{ }`) with dynamic attribute evaluation to capture natural statements. This worked, but came with significant costs:

* Required underscored keywords (`the_`, `and_`, `is_`) to avoid Ring reserved words
* Relied on Ring's `braceExprEval()` reflection mechanism
* Limited natural code to runtime-only evaluation
* Couldn't store, version, or manipulate natural code as data

**The Breakthrough:**

I refactored the entire system to accept **natural code as plain strings**:

```ring
# Old approach (brace-based)
Naturally() {
    Create a string with "hello"
    Uppercase it
    Show it
}

# New approach (string-based)
Naturally("
    Create a string with 'hello'
    Uppercase it
    Show it
")
```

**Performance Impact: 10X faster** by:

* Eliminating Ring's `braceExprEval()` overhead
* Using Qt's optimized `QString` backend via `stzString`
* Direct string tokenization vs dynamic attribute evaluation
* No reflection during token capture

**Strategic Advantages:**

Natural code became a **first-class data type**:

* **Storable**: Save to `.natural` files
* **Versionable**: Git-friendly plain text
* **Searchable**: Use grep, regex, IDE tools
* **Manipulable**: Full `stzString` and `stzRegex` power with full punctuation freedom
* **Sharable**: Exchange natural code across systems
* **IDE-friendly**: Syntax highlighting, linting possible

**No More Keyword Workarounds:**

The string-based approach eliminated all underscore hacks:

```ring
# Before: and_ the_ is_
# After:  and the is   (work naturally)
```

***

## Deferred Execution: Thinking Before Acting

Ring's `NaturalLib` executes commands **as they appear**.\
`stzNatural` **captures the entire block first**, stores it internally, then compiles it into efficient Ring code only when ready.

Why? Because humans **plan before they act**.

> "@Box the string—but make the box@ rounded."

This requires remembering an action, then refining it later.\
Only possible with **deferred compilation**.

The string-based approach makes this even more powerful—we can preprocess, validate, and optimize the entire natural code before a single Ring instruction executes.

***

## Vocabulary Freedom, with Focused Computable Keywords

In `stzNatural`, **only words defined in the semantic dictionary are interpreted**. All others become literals—no pre-nullification needed. A pragmatic design choice that makes a huge performance difference.

The `ignored_words` list (e.g., `"a"`, `"with"`, `"containing"`) exists **only to enable natural phrasing around structural boundaries**—like `Create a string` or `Replace X with Y`.

This lets you write fluently **without compromising parsing integrity**.

## Data-Driven, Config-Only Multilingualism

Ring's `NaturalLib`: duplicate command files per language.\
`stzNatural`: one semantic core, many linguistic skins, unique implementation code.

English `"uppercase"`, Hausa Latin `"maida"`, and Hausa Ajami `"ميّدَ"` all map to the same `METHOD_UPPERCASE`. The implementation engine doesn't care about translated semantics—only `METHOD_UPPERCASE` is processed.

Add a language? Just add a data block (at devtime or runtime). No files to manage, no `load`s to worry about, no `if/then`s inside the implementation code.

```ring
# English
Naturally("Create string with 'hello' Uppercase it")

# Hausa (Latin)
NaturallyIn("hausa", "Yi rubutu dauke 'hello' Maida shi")

# Hausa (Ajami)
NaturallyIn("hausa-ajami", "يي رُوْبُتُ ɗوكي 'hello' مَيْدَ شي")
```

All produce identical Ring code. The string-based approach makes this even cleaner—language definitions are just data structures, and natural code flows as readable text in any script system.

***

## Developer Experience: Introspection & Debugging

```ring
o1 = Naturally("
    Create string with 'test.data'
    Replace '.' with '_'
    Uppercase it
")

? o1.Result()
#--> TEST_DATA

? o1.Code()
#--> oStr = StzStringQ("test.data")
#    oStr.Replace(".", "_")
#    oStr.Uppercase()
#    @result = oStr.Content()

? o1.NaturalCode()
#--> (returns the original natural code string)

o1.EnableDebug()
? o1.DebugLog()  # Full execution trace
```

String-based natural code adds `NaturalCode()` accessor—you can inspect, modify, or regenerate the natural source at any time.

***

## Conclusion

`stzNatural` enables:

* Fluent, stateful chains on **one object**,
* Deferred modifiers via `@...@`,
* Multilingual expression (English, Hausa, Arabic, and beyond),
* Full devtime introspection (`.Code()`, `.Result()`, `.NaturalCode()`, `.DebugLog()`),
* **10X performance boost** through string-based architecture,
* Natural code as **first-class data** (storable, versionable, manipulable),
* And native Ring code execution speed.

The shift from brace-based to string-based natural code wasn't just a refactoring—it was a strategic leap that removed artificial constraints, unlocked massive performance gains, and transformed natural code into a true data medium.