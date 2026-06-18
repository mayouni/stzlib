# Conditional Code in Softanza — Constraining Functions with `W` and `WF`

Many Softanza functions accept a *constraint*: a small piece of logic that
decides, per item, whether it qualifies. "Find the items that are uppercase",
"count the even numbers", "keep the strings longer than 3 characters". Softanza
lets you express that constraint in two complementary ways — and, importantly,
**without `eval()`**.

```ring
o = new stzList([ "ring", "PHP", "C#", "ruby", "GO" ])

? @@( o.FindW('{ IsUppercase(@item) }') )           # textual constraint (DSL)
#--> [ 2, 3, 5 ]

? @@( o.FindWF( func x { return Q(x).IsUppercase() } ) )  # function constraint
#--> [ 2, 3, 5 ]
```

Both answer the same question. They differ in *how* the constraint is written
and in the trade-offs that come with each — and that difference is the whole
point.

## Two paths, one idea

| | **`W` — the sandboxed DSL** | **`WF` — the anonymous function** |
|---|---|---|
| You write | a short **text** expression | a real **Ring function** `f(item)` |
| Evaluated by | the Zig engine (compile → bytecode → run) | Ring itself, called natively per item |
| `eval()`? | **never** | **never** |
| Arbitrary logic (your own functions, methods, side effects) | no — bounded on purpose | **yes** |
| Serializable (store in config / a file / a query / accept from a user) | **yes** — it's just a string | no — a function can't be serialized |
| Safe with **untrusted** input | **yes** — it cannot escape the sandbox | **no** — untrusted code would run with full power |
| Speed | compiled bytecode, very fast | native Ring call, fast |

They are **not** competitors: they cover opposite needs.

- Reach for **`W`** when the constraint is a self-contained expression over the
  item, *especially* when it comes from outside the program (a stored filter, a
  rule from a config file, a query a user typed). The boundary is a feature.
- Reach for **`WF`** when you need real Ring logic — calling your own functions,
  invoking methods, anything the DSL deliberately doesn't allow.

> Why not "just evaluate any Ring code from text"? That was the original idea,
> and it was implemented with `eval()`. `eval()` is bad on two fronts: it is
> slow (re-parsed and re-run per item) and unsafe (a textual constraint from an
> untrusted source could run *anything*). Softanza splits the goal instead:
> the textual path becomes a bounded, fast, safe DSL; the "any Ring code" need
> moves to anonymous functions, where it is both fast and trustable. `eval()`
> is used by neither.

## The `W` DSL

A `W` condition is a string (optionally wrapped in `{ }` for readability).
Inside it you have:

**Placeholders**
- `@item` — the current item
- `@i` — its 1-based position
- `@numberofitems` — the list's length
- `@accumulator` / `@value` — the running value (in reduce-style contexts)
- `@char` — the current character (in character-walking contexts)

**Operators** — `+ - * / %`, comparisons `= != < <= > >=`, logical `and or not`.

**Builtins** (a curated, growing set)
- type tests: `isString`, `isNumber`, `isList`, `isBool`, `isNull`
- predicates: `IsUppercase`, `IsLowercase`, `IsEven`, `IsOdd`, `IsPositive`,
  `IsNegative`
- text: `len`, `upper`, `lower`, `trim`, `reversed`, `contains`, `startswith`,
  `endswith`, `left`, `right`, `substr`, `indexof`, `replace`
- numbers: `abs`, `sqrt`, `floor`, `ceil`, `round`, `min`, `max`
- conversion: `number`, `string`, `type`

```ring
o = new stzList([ 4, 7, 10, 3, 8 ])

? @@( o.FindW('{ @item > 5 }') )                #--> [ 2, 3, 5 ]
? @@( o.FindW('{ IsEven(@item) }') )            #--> [ 1, 3, 5 ]
? o.CheckW('{ isNumber(@item) }')               #--> TRUE
? o.CountW('{ @item > 5 and IsEven(@item) }')   #--> 2
```

The DSL is **case-insensitive** for names (`IsUppercase`, `isuppercase`,
`ISUPPERCASE` are the same), so you can write predicates the way they read.

### One `W`, not `W` + `WXT`

Historically there were two textual forms — `W` (fast, limited) and `WXT`
(expressive, slow) — because the pure-Ring `eval()` implementation forced a
choice between speed and expressiveness. With the engine DSL there is no such
trade-off: a single **`W`** is both fast and fully expressive. `WXT` remains as
a deprecated alias of `W`.

### What `W` deliberately cannot do

The DSL evaluates a *value-level* expression over the item. It does **not**:
- call your own Ring functions or object methods,
- mutate state or produce side effects,
- operate on list-typed items as rich objects (a list item is seen as "not a
  scalar"; for per-element logic on nested items, use `WF`).

That last point is the usual reason to switch to `WF`:

```ring
o = new stzList([ 1:3, 1:3, 5 ])               # items are lists

# DSL can't introspect list items -> use a function:
? o.CheckWF( func x { return isList(x) and len(x) = 3 } )
#--> FALSE      (the 5 is not a 3-element list)
```

## The `WF` family — anonymous-function constraints

`WF` takes a Ring function `f(item)` that returns true/false. It is called
natively, so the constraint can be *anything* Ring can express.

```ring
o = new stzList([ "alpha", "BETA", "gamma", "DELTA" ])

? @@( o.FindWF(   func x { return Q(x).IsUppercase() } ) )   #--> [ 2, 4 ]
? @@( o.ItemsWF(  func x { return len(x) > 4 } ) )           #--> [ "alpha", "gamma", "DELTA" ]
? o.CheckWF(      func x { return isString(x) } )            #--> TRUE
? o.CountWF(      func x { return Q(x).IsLowercase() } )     #--> 2
```

The `WF` set mirrors the `W` set: `FindWF`/`FindAllWF`/`PositionsWF`,
`CheckWF`/`AllItemsWF`, `CountWF`, `ItemsWF`/`FilterWF`, and the positional
`CheckItemsAtWF`/`CheckOnWF`.

## Choosing between them — a one-line test

> *Can my constraint be a self-contained expression over the item?*
> → **`W`** (and you also get serializability + safety for untrusted input).
>
> *Do I need to run real Ring logic (my functions, methods, …)?*
> → **`WF`**.

## Under the hood

- The `W` DSL is compiled and evaluated by the engine's expression module
  (`engine/src/expr.zig`): a small recursive-descent compiler producing
  bytecode that a tight evaluator runs per item. The same engine powers
  `Map`/`Filter`/`Reduce`/`Find`/`Count` with the `@item` placeholder.
- `WF` is plain Ring: the function is compiled once by Ring and invoked with a
  native `call` per item — no string handling on the hot path.
- Neither path calls `eval()`. The conditional-code idea stays first-class as
  text (via `W`), and arbitrary logic gets a fast, trustable home (via `WF`).
