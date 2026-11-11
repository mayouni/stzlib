# What Softanza's Ring workarounds become in Haro -- a design memo for a ruling

*stzlib-haroport, 2026-11-08. Read at origin/main 6e7502509. Nothing here is renamed yet: this memo asks one
ruling, `HAROPORT-SPELLINGS-01`, in four parts, before any mass rename (the prompt's step 1).*

## 0. Restated 2026-11-10 -- `HAROPORT-SPELLINGS-02`, replacing the ruling asked below

**RULED by the Principal in chat, 2026-11-11 05:59**, choosing among the options below:

| part | the Principal's choice | as written |
|---|---|---|
| (a) parameter prefix | "Keep p as a mark" | `pcSubStr` -> `ptSubStr`, `pnStartingAt` -> `piStartingAt`: `p` stands before the type letter as `$` and `@` do |
| (b) booleans 1 / 0 | "true / false" (recommended) | `bReady = true` |
| (c) two-letter list letters | "v + second letter" | `anPos` -> `viPos`, `acNames` -> `vtNames`: the element's letter after `v` |
| (d) other names | "Keep constants in caps" | constants keep their capitals after their letter: `$iMAX_NUMBER_SIZE`, `@tNL`; single letters by Haro's R3 (a `for` counter stays `i`; `n` -> `nN`); capitalised attributes take their letter (`@bCaseSensitive`) |
| (e) keyword-shaped names | "Plain / Q / word" (recommended) | section 3 (c) below |
| (f) W texts | "Bare words" (recommended) | section 3 (a1) below: `item`, `position`, `count`, `total` |

(a), (c) and (d)'s constants extend Haro's letter rule (TYPES T2: "a lowercase type letter followed by a capital"):
a `p` mark before the letter, a second letter after `v` naming the element, and capitals with underscores after the
letter of a constant. The Haro desk builds those before the port tool applies them (`HARO-LETTER-SOFTANZA-01`).

*Read at origin/main 0ba0d6b5a, haro.exe built after haro d62f05c. Sections 1 to 6 below are the memo of 2026-11-08,
left as written; this section replaces its section 3 as the question. The counts are `HAROPORT_PLAN.md`'s.*

Since 2026-11-08 Haro has ruled most of what section 3 asked. **Decided, so not asked again:**

- **the letters** (`TYPES.md`, the Principal, 2026-11-07): text `t`, vector `v`, map `m`, record `r`, integer `i`,
  decimal `d`, float `f`, any number `n`, boolean `b`, object `o`, handle `h`. Section 3 (b1) -- keep Softanza's
  letters, drop the underscores -- is superseded: `_nLen_` becomes `iLen` or `nLen` by what it holds, `_cName_`
  becomes `tName`, by Haro's re-lettering rules (`study/v47/reletter.py`);
- **keywords** lowercase only in a `.haro` file (v0.42);
- **built-ins** in Softanza's casing, `ParentClassName` (HARO-BUILTIN-CASE-01, 2026-11-09);
- **pairs** written `[:key, value]` (HARO-SURFACE-01).

**Asked -- one subject, six parts, class naming:**

**(a) Softanza's parameter prefix `p`** (`pcSubStr`, `pnStartingAt`, `paList`: 44,393 declaration sites, 125,385
occurrences). Haro's rule reads `p` as no type's letter.
- **(a1) Recommended: drop the `p`, the type letter stays** -- `pcSubStr` -> `tSubStr`, `paList` -> `vList`. Haro writes a
  parameter's full type where it is declared (TYPES T2), so the `p` repeats what the signature says. A parameter that
  would land on a local of the same function is a conflict for a hand decision.
- (a2) Keep `p` as a mark before the letter, as `$` and `@` are (`ptSubStr`). Needs Haro's letter rule to accept it.

**(b) The booleans written 1 / 0** (5,079 statements; stzlib's own rule since 2026-08, because a caller could
overwrite `TRUE`).
- **(b1) Recommended: `true` and `false`.** In a `.haro` file `true` is a keyword and cannot be assigned, so the reason
  for 1 / 0 is gone. A `.ring` caller still reads them as 1 and 0 (measured, `HAROPORT_PLAN.md` section 3).
- (b2) Keep 1 / 0 and letter those names `i`. It keeps the numbers and loses what `b` tells a reader.

**(c) Softanza's two-letter list letters** (`anPos`, `acNames`, `aoItems`: 16,623 occurrences). Haro has one letter
for a vector, and its element type is written once, where it is declared.
- **(c1) Recommended: `v`, with the element type in the declaration** -- `anPos` -> `vPos` (`vector of integer`). Where
  the list holds pairs, `m` or `r` by what it is.
- (c2) Keep a second letter (`viPos`). Haro's rule would have to accept it.

**(d) The names Haro's letter rule has no shape for.**
- single letters (30,292 sites, `i`, `n`, `c`): **recommended, Haro's own rule R3** -- a `for` counter stays a single
  letter; any other takes its letter before the original (`n` -> `nN`, `c` -> `tC`);
- ALL_CAPS constants (1,434 sites, `$MAX_NUMBER_SIZE`, `@NL`): **recommended, a letter and capitalised words** --
  `$iMaxNumberSize`, `@tNL`;
- capitalised attributes (5,385 sites, `@CaseSensitive`): **recommended, the letter first** -- `@bCaseSensitive`.

**(e) The keyword-shaped names** -- section 3 (c) below, unchanged: the plain word where Haro does not reserve it,
the Q form for a chaining method, an English word otherwise. Haro still refuses a method named exactly like a keyword
(`And`: 251 statements after the tool passes).

**(f) The W texts** -- section 3 (a) below, unchanged: bare words of the W grammar (`item`, `position`, `count`,
`total`), the `@` forms accepted during the port and refused when none is left.

The order is `HAROPORT_PLAN.md` section 4 -- bottom up, one module per commit -- and replaces section 3 (d).

Every number below was measured today on both runtimes that matter: **rnxc** (`D:\GitHub\ringpp\zig-out\bin\rnxc.exe`,
the bridge) and **haro.exe** (`D:\GitHub\haro\vm\zig-out\bin\haro.exe`, the target), on a `.ring` file (Haro's Ring
surface) and, where it applies, on a `.haro` file (Haro's own rules). The probes are small standalone programs in
`haroport_probes/` beside this file (run each with either binary, from that folder); the counts are a text scan of
`base/` and `core/` (tests apart) by the three `.py` files there, method in section 6.

## 1. The debt, counted

| debt | library (base/ minus test/, core/) | tests |
|---|---|---|
| W placeholders `@item @i @char @string @number @pair @position @list @value @node ...` | **1,503 in 116 files** (`@i` 622, `@item` 348, `@char` 149, `@number` 59) | 1,188 in 239 files |
| `_x_` locals | **241,022 tokens in 601 files**, 14,672 distinct names (`_i_` 16,651, `_n_` 11,652, `_c_` 6,028, `_nLen_` 5,532) | 27,077 in 388 files |
| keyword-dodging definitions (`Where_`, `_SELECT_`, `_if`, `And_`, `End_`, `Get_` ...) | **56 definitions, 36 names, in 26 files** | 1 |
| `eval(` calls | 206 in 49 files (33 of them still refused by `haro check`) | 115 in 86 files |

The prompt's figures (2,389 W placeholders in 87 files; about 266,000 `_x_`) were taken with another scan; these are
this desk's, with the scan published, so either can be argued.

## 2. What was measured about each workaround

**The locals.** On the Ring surface -- rnxc and haro.exe alike, every probe gave the same answer on both:

| a bare local `n` written inside a function or method, when there is also ... | result |
|---|---|
| a top-level `$n` (Rule A global) | untouched (p2) |
| the predefined `nl` | untouched (p8b, p8c); `true = 0` is refused at compile time by rnxc (p8) |
| an attribute spelled `@nCount`, the local written `ncount` | untouched -- `@` is part of the name (p7) |
| an attribute spelled bare `nCount` in the class, the local written `ncount` | **WRITTEN: 1 -> 99** (p1) |
| a bare `nCount` inherited from a parent class | **WRITTEN: 1 -> 99** (p9) |

In a `.haro` file the last two rows are gone: with `@nCount` declared, a bare `ncount = 99` leaves the attribute at 1
(h1b), and a bare spelling of a declared attribute name is refused outright (p1 as `.haro`: "one spelling per name").

So `_x_` protects against exactly one thing on the Ring surface: a **bare** attribute of the class or an ancestor.
stzlib declares **3,266 attributes with `@` and 88 bare**. Stripping the underscores of every `_x_` in a method would hit
**0 bare attributes of the same class** (a lower bound: an attribute inherited from another file is not seen by the
scan), and 1,214 would land on an `@` attribute's letters, which is a different name on both surfaces (p7).
**595** stripped names would become a keyword (`ok` 70, `end` 62, `or` 60, `call` 50, `const` 46, `if` 35, `new` 35 ...).

**The keyword-shaped names.** `def <Name>(x)` called as `o.<Name>(1)`:

| names | rnxc .ring | haro .ring | haro .haro |
|---|---|---|---|
| `Where` `Select` `In` `When` `Then` `Step` `Use` `Is` `Otherwise` `Iif` | ok | ok | ok |
| `If` `Else` `And` `Or` `Not` `End` `But` `From` `Get` `Put` `Load` `Call` `Do` `Catch` `New` `Next` `Class` `Return` `Case` `Switch` `Def` `Func` | ok | ok | **refused**: "a keyword in another case is no name" |
| the same words with a suffix: `IfQ` `AndQ` `OrQ` `NotQ` `FromQ` `EndQ` `ElseQ` `ButQ` `GetQ` | ok | ok | ok |

So on both runtimes' Ring surface **no dodge is needed today** -- the dodges were paid to Ring 1.2x -- and in Haro the
dodge is needed for the second row only, and `Where`/`Select` need none.

**The function form of a condition** (Ring surface, 300,000 items, `if a[i] > 3` inline against
`if call f(a[i])` with `f = func x { return x > 3 }`, alternated twice): inline 8 ms on both; function 13-16 ms on rnxc,
16-17 ms on haro.exe. A function costs about one call per item, and a call is cheap.

## 3. The ruling asked -- `HAROPORT-SPELLINGS-01`, class judgement, four parts (replaced by section 0, 2026-11-10)

**(a) What a W condition names instead of `@item` / `@i`.**
A W text is **not Haro code**: the engine's expression compiler (`engine/src/expr.zig`) reads it against a closed
grammar and runs nothing it names (principle 11, "a declared language's text cannot act"). Rule D governs names in
Haro source, so it does not bind the W grammar's words. But principle 2 (one obvious spelling) does: in a Haro
program `@item` reads as "the attribute item", and a reader cannot tell a W text from code by looking at the `@`.

- **(a1) Recommended: bare words of the W grammar** -- `item` and `position`, plus `count` for `@numberofitems` and
  `total` for `@accumulator`/`@value`. The method-specific aliases (`@char`, `@string`, `@number`, `@pair`, `@list`,
  `@node` ...) all lower to `item` as `StzWLower` already does, so a W text has one spelling for the item and one for its
  place. The engine accepts both spellings during the port (about 10 lines in `classifyWord`), a code rule counts the
  `@` forms left, and the `@` form is refused once the count is 0. Nothing runs slower: the word is resolved at compile
  time of the expression. 1,503 library sites and 1,188 test sites, all inside string literals.
- (a2) Keep `@item`. Costs nothing; keeps the clash with rule D's reading in every W text.
- (a3) Function form only, no W text. Haro-native (`def (item) ... end`), about twice the per-item time measured
  above, and it deletes the W surface Softanza teaches. Recommended **beside** (a1), not instead: text for the closed
  grammar, a function (the WF form, `StzRequireFunction`) for anything beyond it -- the rule the eval work already applied.

**(b) What a local is called once `_x_` goes.**
- **(b1) Recommended: Softanza's own Hungarian camelCase, the underscores dropped** -- `_nLen_` -> `nLen`,
  `_aResult_` -> `aResult`, `_i_` -> `i`. It is already the library's spelling of parameters and attributes, it reads
  the same on `.ring` and `.haro` (Haro keeps Softanza's mixed case, PRINCIPLES 2.1), and section 2 measured it safe on
  both runtimes' Ring surface except against a bare attribute. The rename refuses, and keeps for a hand decision, a
  local whose new name (1) is a bare attribute of its class or any ancestor, (2) is already a parameter or local of the
  same function, or (3) is a keyword (595 today: they get a word, `_end_` -> `nEnd`, `_ok_` -> `bOk`). Before a module
  is renamed, its share of the 88 bare attributes takes its `@`.
- (b2) lower_snake (`n_len`). Runs on both surfaces (p3), but is a third spelling beside Softanza's parameters and
  attributes, which do not move.

**(c) What the keyword-dodging names become.**
- **(c1) Recommended: the plain word wherever Haro does not reserve it** -- `Where_`/`_WHERE_`/`_where` -> `Where`,
  `_SELECT`/`SELECT_`/`_SELECT_` -> `Select`, `Then_` -> `Then`, `Step_`/`_Step` -> `Step`; where the dodge was an alias
  of a plain-named method already present, the alias is dropped.
- **(c2) Recommended: for a word Haro reserves, the Q form when the method chains, a plain English word otherwise** --
  Softanza already spells "returns the object for the next call" with Q, and `.haro` accepts every keyword+Q name
  probed. So the chain words of stzChainOfTruth/Value and the Tablex/Matrex combinators become `AndQ`, `OrQ`, `NotQ`,
  `ButQ`; a non-chaining one takes a word: `_if`/`if_` -> `When`, `_else`/`else_` -> `Otherwise`, `End_` -> `LastDay`
  (stzCalendar), `Next_` -> `NextMonth`, `Catch_` -> `OnError`, `Call_` -> `Invoke`, `Load_` -> `LoadFile`, `Class_` ->
  `CssClass`, `_New` -> `Renewed`, `Get_`/`Put_` (stzAppServer routes) -> `OnGet`/`OnPut`, `_Get` -> `ValueOf`,
  `FROM_`/`_FROM` (stzExtinSql) -> `FromTable`. *(author: the exact word of each.)*
- `iif` is not reserved in Haro and reads as its meaning; it stays, unless the Principal reads it as a Ring idiom to drop.

**(d) The order.** Module by module, rename + guards + docs in one commit per module, never one sweep (the
`func char(10)()` lesson). W words first (an engine change and string edits, nothing a compiler resolves), then the
keyword-shaped names (56 definitions, each with its callers), then the locals, largest modules last.

## 4. What proceeds meanwhile, unruled

- **Step 2, the eval sites**: `haro check` today gives **33 haro/text-run-as-code**, the same 33 the prompt names
  (stzFuncs 6, stzObject 6, stzChainOfTruth 5, stzDataSet 3, stzStringCode 2, stzConstraint 2, stzExtinPython 2,
  stzPairOfLists, stzGraph, stzExtinCode, stzExtinSql, stzExterCode, stzSemanticResolver, stzNatural 1 each).
  Naturally()'s design is proposed to stzlib-intelligence before it is built.
- **Step 3, the load**: the "C27" is not a file that does not scan. haro.exe cannot find `stdlibcore.ring`
  (`core/common/stkRingLibs.ring:6`) and `ziplib.ring` (`base/file/stzFile.ring:1`) -- Ring++ ships them, Haro by the
  author's D50 never will -- and the C27 is the missing file reported up the load chain. The work is the prompt the haro
  desk wrote on 2026-11-05 (`haro\runtime\distance\PROMPT-stzlib-no-ring-stdlib.md`: 16 functions at 252 sites), which
  no stzlib session has taken; this plane takes it. Beside it: 12 haro/type-arity (stzDiagram 4, stzMusic 2, stzNumber,
  stzSoundUniverse, stzListNamedParams, stzGraphPlanner, stzResponsePlan, stzFile) and 1 haro/varptr-unknown-name
  (`core/system/stkPointer.ring:720`).

## 5. A finding for the haro desk (routed through Central)

`HARO-KEYWORDSET-01`: the set `.haro` refuses as names is not the set `GRAMMAR-SKETCH.md` section 1 lists. Accepted
although listed: `in`, `is`, `use`. Refused although not listed: `get`, `put`, `load`, `call`, `do`, `next`, `case`,
`func`. Repro: `o = new K / ? o.Get(1) / class K / def Get(x) / return x + 1`, saved as `.haro`. Which list is the law
decides part (c) for those eleven words.

## 6. How the counts were taken

A Python text scan over `libraries/stzlib/base` and `core`, `/test/` folders apart. W placeholder: `@` followed by one of
the names in section 1 as a whole word, case-folded. `_x_` local: `_` + letter + letters/digits + `_`, not preceded by an
identifier character, `@` or `$`. Keyword-dodging: a `def`/`func` whose name is a Ring or Haro keyword with a leading or
trailing `_`. Attribute collision: attributes are the assignments in a class body before its first `def`, same file.
A text scan counts occurrences, comments included; the compiler is the authority on each site.
