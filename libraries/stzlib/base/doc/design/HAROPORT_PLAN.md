# stzlib moves to .haro -- the plan this desk proposes

*stzlib-haroport, 2026-11-10. Proposed to Central under `CENTRAL-NORING-SCOPE-01` part (2): "code still in its
syntax -- stzlib's library above all -- moves to .haro desk by desk, each desk proposing its plan, and nothing is
deleted before haro.exe runs what replaces it." Read at stzlib origin/main 0ba0d6b5a; Haro at origin 16e7503, the
installed haro.exe built after d62f05c (v0.52 and the census grouped by family). The naming questions this plan
depends on are asked in `HAROPORT_SPELLINGS.md`, section 0 (`HAROPORT-SPELLINGS-02`).*

## 1. Where stzlib stands as .haro

The library (`base/` without `test/` and `doc/`, `core/`, the other top folders, and the 94 engine wrappers in
`engine/`) was copied into a scratch tree, every `.ring` renamed `.haro` and its 961 load lines rewritten. The same
tree left as `.ring` reads **0 errors** under `haro check` (the control). As `.haro`, `haro census stzBase.haro`:

| | statements |
|---|---|
| compiled | 34,895 of 140,449 (24%) |
| refused | 105,554, each counted once under its first refusal |

A refusal drops its own statement only; the census counts causes, not a cascade (haro-charter, 2026-11-10).
The 19 families, largest first:

| family | statements |
|---|---|
| a name begins with its type's letter -- has none | 52,742 |
| a keyword in another case | 28,469 |
| a built-in spelled otherwise | 10,514 |
| Softanza's `c` letter, where text is `t` | 7,032 |
| a `b` name given 1 or 0 | 3,965 |
| `:key = value`, where `.haro` writes `[:key, value]` | 960 |
| one spelling per name, across files (`trim` / `Trim`, `Haskey` / `HasKey`) | 748 |
| an `o` name given an integer | 622 |
| `@attribute` outside a class | 207 |
| two functions that differ only by case | 116 |
| nine smaller families | 179 |

## 2. What tools can do, measured

Three passes a tool can make without a ruling were simulated in the scratch tree, one after the other, each
counted by `haro census` (scripts in `haroport_probes/measure/`):

| pass | changes | compiled |
|---|---|---|
| none | -- | 24% |
| keywords lowercased (Haro's keyword list, `lift.zig`) | 84,998 words | 36% |
| + built-ins respelled by Haro's table (`study/v48/builtin_names.py`) | 47,063 calls | 40% |
| + `_x_` locals and `$_x` globals unwrapped (`_nLen_` -> `nLen`) | 237,837 names | 54% |

The third pass made a local land on a keyword at 15 sites (`_new_` -> `new`, `_try_` -> `try`): a real pass checks
each new name against the keywords, the function's other names and the class's attributes, and leaves a conflict for
a hand decision, as Haro's own `study/v47/reletter.py` does.

After the three passes the refusals left (63,819 statements) are naming: 40,781 names with no type letter, 14,435
`c` names, 5,079 booleans written 1 / 0, 1,225 pairs, 1,141 spellings across files, 636 `o` names given an integer.
A text scan of the names left (`shapes.py`, 186,157 declaration, `$` and `@` sites; a scan, the compiler is the
authority) gives their shapes:

| shape | sites | examples |
|---|---|---|
| Softanza's letters `a` `c` `p` `l` | 87,044 | `aResult`, `cResult`, `pItem` |
| a parameter prefixed `p` + letter | 44,393 | `pcSubStr`, `pnStartingAt`, `paList` |
| a single letter | 30,292 | `n`, `i`, `c`, `j` |
| a word, or Softanza's two-letter list letters | 14,644 | `anPos`, `acResult`, `str` |
| a capitalised name | 5,385 | `@CaseSensitive` |
| underscores left | 2,690 | `_bAliasesLoaded`, `@last_error` |
| an ALL_CAPS constant | 1,434 | `$MAX_NUMBER_SIZE`, `@NL` |

The letters themselves are ruled (Haro's `TYPES.md`, 2026-11-07): text `t`, vector `v`, map `m`, record `r`, integer
`i`, decimal `d`, float `f`, any number `n`, object `o`, boolean `b`, handle `h`. What the letters do not decide --
Softanza's `p` for a parameter, the 1 / 0 booleans, constants, single letters -- is `HAROPORT-SPELLINGS-02`.

## 3. Mixing .ring and .haro, measured

A module can move only if the modules around it keep running. Probed on haro.exe (16e7503):

**A `.ring` file calls a `.haro` file -- works.** With `newlib.haro` holding
`func NewIsBig(iN) return iN > 3` and `func NewName() return "abc"`, a `.ring` program that loads it gets:
`if NewIsBig(5)` takes the branch; `NewIsBig(5) = 1`, `= TRUE` and `NewIsBig(1) = 0` are all 1; `"v: " + NewIsBig(5)`
is `v: 1`; `NewIsBig(1) + 1` is 1; a text comes back as text. Two things differ: `? NewIsBig(5)` prints `true`, and
`isNumber(NewIsBig(5))` is 0.

**A `.haro` file calls a `.ring` file -- works, except a boolean.** `iSum = OldAdd(2, 3)` is 5 and an object of a
`.ring` class answers its methods. But `bFlag = OldFlag()`, where the `.ring` function returns 1, is refused
(`TYPE_LETTER`), and so is `if OldFlag()` (`BOOLEAN_EXPECTED`). `TYPES.md` section 6 writes the conversion (an
integer 0 or 1 entering a `b` name becomes `false` / `true`) and it is not built yet; the condition case is not
written there. Routed to haro-charter as `HARO-RINGBOUNDARY-BOOL-01`. Since every stzlib predicate returns 1 / 0, it
decides the order below.

## 4. The plan

**Order: from the bottom up, along `stzBase`'s load order.** The engine wrappers and `core/` first, then `common/`,
then the modules that load them, each moved only when everything it loads has moved. A moved module is then called
only from `.ring` code above it, the direction measured to work today. Top-down would need
`HARO-RINGBOUNDARY-BOOL-01` first.

**One module per commit, four parts in it:**

1. the module's files become `.haro` by the tool passes of section 2, then the passes the ruling of
   `HAROPORT-SPELLINGS-02` adds, with each conflict decided by hand;
2. `haro census` on a program that loads the module reads 0 refused statements for its files;
3. the module's guards pass on haro.exe -- moved to `.haro` in the same commit, so no new `.ring` test is written
   (`NORING` part 1); a guard that compares a predicate's printed value reads `true` / `false` where it read 1 / 0;
4. the `.ring` files go in that commit, only when 2 and 3 hold (`NORING` part 2: nothing is deleted before haro.exe
   runs what replaces it).

Commits go to main on both remotes as this repository's push protocol says; the other stzlib desks pull a library
whose lower half is `.haro` and whose upper half still `.ring`, and every program that loads `stzBase` keeps working
because of section 3's first measure.

**Done** is: `stzBase.haro` loads with 0 refused statements, no `.ring` file is left under `libraries/stzlib`, and
every guard that passed on haro.exe before the move passes after it.

## 5. What it needs from others

- **haro-charter, `HARO-PORTTOOL-01`**: Haro's own passes -- keyword lowering, `study/v48/respell.py`,
  `study/v47/reletter.py` -- run on a named tree with the collision check, as one command. This desk's scratch scripts
  measure; they are not the tool a 140,000-statement rename should be made with.
- **haro-charter, `HARO-RINGBOUNDARY-BOOL-01`**: section 3's boolean, for any `.haro` code that calls `.ring` code
  during the move.
- **the Principal, `HAROPORT-SPELLINGS-02`**: section 0 of `HAROPORT_SPELLINGS.md`.
- **every stzlib desk**: none of its work changes until its modules' turn; the module's commit is announced in
  CONCLUSIONS before it lands, so a desk with a branch on that module rebases once.

## 6. Not measured here

The tests (`base/test/`, about 5,500 files) were not read as `.haro`; each module's step moves its own. The engine
wrappers are converted by the same passes; whether some of them are generated, and should be regenerated as `.haro`,
is checked at their step.
