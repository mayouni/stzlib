# stzString module — audit & strengthening handoff

**Goal:** finish auditing, fixing, and strengthening the entire stzString module.
**State at handoff (2026-07-01, HEAD `bd0ebe06`):** 263 / 999 test files audited +
converted to narrated assertions + green. **736 remain** (718 numbered + 18
`from_*` cross-module extracts). Narrated suite is fully green.

This document is self-contained. Read it fully, then read `_AUDIT_DEFECTS.md`
(the running defect log, with an ENGINE-SIDE OPTIMIZATION BACKLOG at the top and a
per-chunk log). Everything you need is under `libraries/stzlib/base/`.

---

## 1. The mission

For EVERY remaining test file under `libraries/stzlib/base/test/string/` that is
not yet a narrated assertion suite:

1. **Read** the current modular test file. Note its `# Extracted from
   stzStringTest.ring, block #N` marker.
2. **Recover the ORIGINAL block** from the monolith test (the definitive
   authority for expected values):
   `git show f6bdfbcc^:libraries/stzlib/base/test/legacy/stzStringTest.ring`
   (19,572 lines; blocks are `pr()`…`pf()` pairs). For `from_*` files the source
   is the corresponding module's legacy test.
3. **Read the ORIGINAL implementation** of the methods used, in
   `libraries/stzlib/base/string/archive/stzString_monolithic.ring`.
4. **Compare** to the CURRENT modular impl (`string/stzString.ring`,
   `string/stzStringFinder.ring`, `string/stzStringFunc.ring`,
   `string/stzStringChar.ring`).
5. **THE ORIGINAL IS THE REFERENCE.** When an extracted test's `#-->` disagrees
   with a sibling or with the original, the ORIGINAL wins — the extraction
   sometimes hand-wrote or copy-pasted wrong values (confirmed repeatedly:
   blocks 123, 160, 216, 217, 229, 277 all had wrong `#-->`).
6. **Run** it: `cd libraries/stzlib/base/test/string && D:/ring127/bin/ring.exe <file>`
   (the "STOPPED!" banner from `pf()` is the SUCCESS marker, not an error).
7. **Fix to the original**, OR log the defect in `_AUDIT_DEFECTS.md` if it's a
   genuine deferral (see §5).
8. **Convert** the file to a narrated assertion suite (see §3).
9. After each batch (~5–10 files) run the FULL narrated suite; commit + push
   BOTH remotes (see §6).

Do it in batches ("chunks"), not all at once. Keep the narrated suite green after
every batch.

---

## 2. ENGINE-FIRST (critical, non-negotiable)

Heavy per-char / per-substring work MUST be implemented in the Zig ENGINE
(add a Zig fn in the engine repo + a Ring bridge + rebuild the DLL), NOT a Ring
loop. Ring's `substr`/`len`/`upper`/`lower` are byte-based and corrupt UTF-8;
the engine is Unicode-correct AND faster.

- Use the engine helpers: `_FindFrom`, `_EngineSlice(hay,start,count)`,
  `_EngineSliceFrom(hay,start)`, `_EngineCount(s)`, `StzFind`/`StzFindFirst`,
  `StzReplace`, `StzSplit`, `StzStringTitlecased`, and the `StzEngine*`
  functions. `StzEngineStringReplaceCS(h,old,new,cs)` MUTATES its handle in place
  (read back from the SAME handle; it returns no new handle).
- If a fix genuinely needs heavy iteration and no engine fn exists yet: either add
  the engine fn (preferred), or if you can't rebuild the engine this session, add
  a correct Ring-side impl AND log it in the `_AUDIT_DEFECTS.md` ENGINE-SIDE
  OPTIMIZATION BACKLOG. Do NOT silently ship a Ring loop as the permanent impl.
- Four such impls are ALREADY in the backlog and should be moved engine-side:
  `DuplicatesCS` (O(n³)), `_SubStringsByOccurrence`, `FindSubStringsWCS`,
  `FindDupSecutiveCharsZZ`.

---

## 3. The narrated test format

Convert each print-form test into an assertion suite:

```ring
load "../../stzBase.ring"
load "../_narrated.ring"

# One-paragraph narrative: what the block demonstrates + the archive block #N.

Scenario("A short scenario title")
	Given('"the input"')                 # optional context line
	o1 = new stzString("the input")
	Then("what is true", o1.SomeMethod(), "expected")          # scalar compare
	Then("a list result", ListEq( o1.ListMethod(), [ "a", "b" ] ), TRUE)  # list compare
EndScenario()

Summary()

# Include this helper ONLY if the file uses ListEq:
func ListEq aA, aE
	if len(aA) != len(aE) return FALSE ok
	nLen = len(aA)
	for i = 1 to nLen
		if isList(aA[i]) and isList(aE[i])
			if NOT ListEq(aA[i], aE[i]) return FALSE ok
		else
			if aA[i] != aE[i] return FALSE ok
		ok
	next
	return TRUE
```

- `Then(desc, actual, expected)` for scalars/strings/numbers/booleans (TRUE/FALSE).
- For list results, wrap in `ListEq(actual, expected)` and compare to `TRUE`.
- Drop non-deterministic lines (`Some`/`SomeXT` random sampling) — do not assert
  them; note in the narrative that they are random.
- Preserve exact multibyte / backslash string literals from the original.
- `_narrated.ring` prints `STATUS: OK` when all assertions pass (that's what the
  suite runner greps for).

Suite runner (bash, from the test dir):
```bash
pass=0; fail=0; failed=""
for f in $(grep -l '_narrated.ring' *.ring); do
  out=$(timeout 60 D:/ring127/bin/ring.exe "$f" 2>&1)
  if echo "$out" | grep -qa "STATUS: OK"; then pass=$((pass+1)); else fail=$((fail+1)); failed="$failed $f"; fi
done
echo "narrated PASS=$pass FAIL=$fail"; echo "failed:$failed"
```

---

## 4. Semantic decisions already made (the "constitution")

All grounded in the original monolith. Keep these; do not relitigate:

- **BoundedBy family OVERLAPS for single-char bounds.** The original
  `FindTheseBoundsCSZZ` advances `nPos = n2` (the closer), reusing each closer as
  the next opener → overlapping, for BOTH repeated markers AND quotes.
  `BoundedBy`=`AnyBoundedBy`=`SubStringsBoundedBy` (no method split).
- **`Between` = GREEDY single span** (first-open to last-close, a STRING);
  `BoundedBy` = the LIST of enclosed regions. They were decoupled: `BoundedByCS`
  routes all bounds through `AnyBoundedBy`; `BetweenCS` is the greedy string.
- **`Section` is STRICT** — auto-orders but RAISES "Indexes out of range!" on
  out-of-bounds. `SectionXT` is the lenient (negatives-from-end, clamped) form.
  `Slice`=`Section`, `SliceXT`=`SectionXT`. Internal callers use `_SectionLenient`.
- **`SubStringsOccurringNTimes(n)` = ">= n"** (aliased to `...NTimesOrMore`);
  `Exactly`/`Only` = "= n"; `NoMoreThanNTimes` = `LessThanNTimes` = "< n".
- **`Duplicates()` = duplicated SUBSTRINGS** (all `Section(i,j)` occurring >1),
  not just chars.
- **`CapitalCased()` = TITLE case** (every word, engine ToTitle); `IsCapitalcase`
  = `CapitalCased()==Content()`.
- **`SubStringComesBetween` is order-INDEPENDENT.**
- The plural `...Chars()` forms (Leading/Trailing/First2/Last3/…) return a LIST;
  the `...AsString` twins return the substring.
- The Z/ZZ/UZ/UZZ section forms carry `[substr,pos]` / `[substr,span]` grouping.
- Fluent boolean chain: `StartsWithXTQ(a).AndQ().EndsWithXT(b)` returns THIS when
  the check is TRUE (chain on the real string) or `AFalseObject()` when FALSE.
  `AFalseObject`/`stzFalseObject` live in `base/object/` (with stzTrueObject) —
  do NOT recreate; add any missing chain methods to that class.
- Ring gotchas: `NULL == ""` and `isString("")==TRUE` (use a boolean flag, not a
  NULL sentinel); you cannot put a `func` then a `class` after stzString's body in
  stzString.ring (globals → stzStringFunc.ring, classes → alongside existing ones).

---

## 5. Open work: focused-pass candidates + genuine deferrals

**Focused-pass candidates (fix engine-first, unblock a whole cluster):**
- **SpacifyXT advanced-separator family** (280, 281, 282, 283, 284, 285) — the
  `:Separator/:Using = [s1, :AndThen=s2, :LastNChars=n]` + `:Step=[a,:AndThen=b]`
  + `:Direction=[..:AndThen..]` advanced forms are broken (literal "separator"
  leaks; `:LastNChars`/`:LastChars` ignored). 6 tests. Original impl at monolith
  ~90646.
- **substring-W retirement migration** — `RemoveWXTQ` etc. (256, 265) are retired
  WXT forms; wire to the W-form / the new `FindSubStringsWCS` (list-domain part).
- **dup-consecutive-substring family** (288, 291) — `FindDupSecutiveSubString`,
  `NumberOfConsecutiveSubStringsOfNChars` mismatch the archive.
- **Unspacified** (295) — should reduce runs of 2+ spaces to one and drop
  single/edge spaces; current removes all. Check original `UnSpacify`.

**Genuinely deferred (NOT stzString defects — leave, with a note):**
- Ring-language limits: `Interpolate`/`$()` (no caller-scope reflection, 111),
  `Repeated<N>Times` (no method-missing, 112).
- Upstream `#TODO`: `Dotless` (114, 115).
- **stzLIST / other-class domain** (fix in their module, not here): anything on a
  `stzList` / `stzListOfNumbers` / `stzListOfStrings` result (98, 201, 272, 273,
  286, 294), and `stzCCode` transpiler tests (263). `SplitQ()`/`LinesQ()` return
  stzLists, so `FindWhere`/`RemoveWXTQ` on them are list-domain (83, 84).
- Visual box-glyph rendering (99, 100, 101) — ASCII is Windows-console-safe.
- Data-dependent: `UnicodeData()` is empty here (237, 244, 245); 2M-char perf
  demos (239); big-text perf demo (07).
- Ring-community `substr()` notes (234) and `#SKIP` retired placeholders (128).
- No-original-reference / version-specific: `SizeInBytes`/64/32 (06).

---

## 6. Standing rules

- Run tests with `D:/ring127/bin/ring.exe` (engine DLL is ABI-bound to Ring 1.27).
- Rebuild the Zig engine ONLY after a `.zig` edit (the engine is a separate repo /
  `build.zig`; see [[reference-ring-abi-versions]] in memory).
- Push BOTH remotes after each committed batch:
  `git push origin main; git push codeberg main`. Codeberg auth expires
  periodically — retry once; if it still fails, GitHub is enough, flag codeberg
  as pending, don't block.
- Commit only your own changed files (a pre-existing `object/stzObject.ring`
  modification is NOT yours — leave it out).
- ASCII-only console output (test FILE content may contain multibyte glyphs as
  data; that's fine).
- Before assuming a regression after editing stzString.ring, syntax-check: a
  single case-insensitive duplicate `def` causes C22 and cascades R14 across ALL
  tests. `grep -niE "^\s*def\s+<name>\s*\(" string/stzString.ring`.
- Never open PRs unless asked.

## 7. Definition of done

Every remaining test file is either (a) a green narrated assertion suite matching
the original, or (b) explicitly deferred with a one-line reason in
`_AUDIT_DEFECTS.md` (Ring-limit / list-domain / visual / data-dependent /
engine-backlog). The full narrated suite is green. `_AUDIT_DEFECTS.md` reflects
the final state. Both remotes pushed.
