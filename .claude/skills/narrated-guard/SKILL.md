---
name: narrated-guard
description: Write a narrated guard for stzlib that fails before the change and passes after, as a standalone probe first. Use when asked to "write a guard", "add a test", "prove the fix" or "cover this method".
---

# Narrated guard

A guard is a Ring file under `libraries/stzlib/base/test/<topic>/` named
`<thing>_narrated.ring`, loading the library and the narration helper:

```ring
load "../../stzBase.ring"
load "../_narrated.ring"
```

The helper gives `Scenario`, `Given`, `When`, `Then(text, actual, expected)`,
`EndScenario` and `Summary`, which prints `TOTAL: n assertions, p pass, f fail`
and `STATUS: OK` or `STATUS: FAILED`. Derived from `CLAUDE.md` "Guard suites".

## The loop

1. **Probe first.** Write the new section as a standalone file and run it from its
   own folder (`cd` there; `load` resolves against the current directory). Seconds
   per run. Fold it into a suite only when green standalone.
2. **Red before green.** The guard must fail on the code before the change. Run it,
   keep the failing line in the commit message, then make it pass.
3. **Assert the mechanism, with a negative sibling.** A positive that could pass by
   coincidence (a byte compare with what the writer meant to write) proves nothing.
   Parse the output back, count the thing, and show the same assertion failing on the
   wrong input. The render guard `libraries/stzlib/base/test/render/escape_sinks_narrated.ring`
   shows the oracle seeing an injection before any sink is judged.
4. **Compare with `strcmp`.** `Then` compares with `=`, which is case-insensitive on
   texts; turn a case question into a number first (`strcmp(a, b) = 0`).
5. **One process.** Cold start costs seconds; put many assertions in one file rather than
   one file per assertion. Index loops: `nLen = len(aList); for i = 1 to nLen`, never
   `for x in f()`, which hung a guard once.
6. **Perception.** If the thing is seen or heard, write the artefact beside the guard
   (a PNG, a WAV, an HTML page) and say in the memo who perceived it. *Unperceived* is
   a state, never a failure.
7. **Gate once.** Run the suite that owns the file once, before the commit, never after
   every edit.

## Shape of a scenario

```ring
Scenario("A twin that drops a box is an error")
	Given("the honest projections of the panel")
	When("the HTML twin loses the note's element")
	Then("one error, on note, on the html twin", RxCount(aF, "error", "note", "html"), 1)
	Then("and no other error", len(RxErrorsOf(aF)), 1)
EndScenario()
```

Top-level statements must come before the first `func`; a statement after a `func`
belongs to it. Put the scenarios in `func RxMain()` and call `RxMain()` at the top.
