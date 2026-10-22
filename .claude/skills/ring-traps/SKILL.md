---
name: ring-traps
description: The Ring traps a stzlib method hits, each with the error it shows and the repair. Use when a Ring error (C22, C27, C6, C13, R14, R20, R21) or a silent no-op appears, or before naming a method or a variable.
---

# Ring traps

Collected in `CLAUDE.md` "Editing discipline" and "What NOT to do"; this is the lookup by
symptom. Ring is case-insensitive everywhere.

| symptom | cause | repair |
|---|---|---|
| `Error (C22) : Function redefinition` once, then R14 on every method of the file | two definitions of one name, in any case (`NthStz` and `NthSTZ` collide) | `grep -niE "^\s*def\s+<name>\s*\(" <file>`; remove one |
| `Error (C27) : Syntax Error!` on a line that looks right, or the next line | a variable or method named after a keyword: `oR` is `or`, `cAll` holds `call` (C13), `def Load()` is `load` (C6) | rename (`oRep`, `cNarr`, `LoadRatio`) |
| a guard prints nothing and exits 0 | its statements sit after a `func`, so they belong to that function | move the call to the top, before the first `func` |
| `Error (R21) : Using operator with values of incorrect type` after `StzFind(...) > 0` | `StzFind` returns a LIST of positions, needle first | `StzFindFirst(needle, haystack)` for a position; a loop with `strcmp` for a list |
| a method returns nothing from `Obj().Method()` | the chain-return trap: a chained call on a freshly built object | build in two steps: `o = Q(); o.Method()` |
| `len()` or `trim()` raise R20 inside a class | the bare builtin is shadowed in class scope | `ring_len()`, `ring_trim()` |
| `nL = len(...)` then a string method raises far away | `NL` is a global; `nL` replaced the newline with a number (`cR`, `tab`, `true` likewise) | `char(10)`, `char(9)`, `char(13)`; literals `1`, `0`, `""`; the code rule `writes-a-mutable-constant` catches the write |
| `if isString(p); p = [p]; ok` never fires in a method | a single-clause `if` that no-ops in Ring 1.25 | `if .. but .. else .. ok`, build the result in a fresh variable |
| `_aRes_ + _x_ + _y_ - 1` appends three times | `+` on a list is append; precedence | `_aRes_ + (_x_ + _y_ - 1)` |
| Hebrew, Arabic, emoji corrupted | `substr`, `len`, `upper`, `lower` on a string are bytes | `StzFind`, `StzReplace`, `StzLen`, `StzLower`, `StzUpper`, the engine |
| a loop over a big buffer takes seconds | `substr(s, i, 1)` copies the buffer each call (0.3 ms on 1.8 MB) | `s[i]`, or slice the row once and index inside it |
| `for x in aList` is slow or re-runs a call | the iterator form re-evaluates its source per step | `nLen = len(aList); for i = 1 to nLen` |
| `_local_ = @aMember` is slow | lists are copied on assignment | read the member directly, `@aEdges[i][:from]` |
| a Ring-side `if a = b` on texts answers 1 for `Ana` and `ana` | `=` is case-insensitive on texts | `strcmp(a, b) = 0` |
| `#ERR exit 3221225794` | a Windows DLL init fault, often a stale header | re-run a sample before believing it |
| a `python -` with an empty heredoc runs for hours | the shell left stdin open | never leave one running; check `tasklist` |

## Before naming

A method is verb-first (`AddStage`, `AddStageQ`); a noun returns data. A `...Q()` method
returns the object for a chain; the plain form ends the chain. No name after a keyword,
no name containing `call`, no `Len()` on a class, no aggressive verbs.
