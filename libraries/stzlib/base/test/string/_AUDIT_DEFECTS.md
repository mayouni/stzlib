# String narration-audit — defects found (real code/test bugs)

Running log of genuine defects surfaced while narrating (= correctness-auditing)
`base/test/string`. Triangulated against the recovered archive
`stzStringTest.ring` (from git `f6bdfbcc^`, the pre-split monolith). Each entry:
what's wrong, evidence, and the fix decision (code vs test, per defect policy).

## ⚙️ ENGINE-SIDE OPTIMIZATION BACKLOG (Ring-loop impls -> move to the Zig engine)

Per the engine-first rule, heavy per-char / per-substring work belongs in the Zig
engine (add fn + bridge + rebuild), NOT Ring loops. The following were written
Ring-side during the per-file audit for CORRECTNESS (all pass their tests) but
must be reimplemented engine-side for efficiency:

- **`DuplicatesCS`** (stzString.ring ~5636, chunk 6) -- O(n^3): Ring
  `for i / for j / Section(i,j)` + `HowMany` per candidate. Needs an engine fn
  returning all duplicated substrings (hashing / suffix structure, O(n^2) or less).
- **`_SubStringsByOccurrence(n, bExact)`** (~9927, chunk 2) -- O(n^2+):
  `SubStrings()` (itself O(n^2)) + dedup + `HowMany` per unique sub. Engine:
  count-substrings-by-occurrence, feeding SubStringsOccurring{,Exactly,Only}NTimes.
- **`FindSubStringsWCS`** (stzStringFinder.ring ~501, substring-W pass) -- O(n^2):
  Ring `for i / for j / Section(i,j)` enumeration + `stzList.FindW`. Engine: a
  `StzEngineStringFindSubStringsW` (per-substring predicate eval) mirroring the
  existing `StzEngineStringFindCharsW`.
- **`FindDupSecutiveCharsZZ`** (~15651, chunk 13) -- O(n) Ring grouping loop over
  the positions (LIGHT; the base `FindDupSecutiveChars` is already engine-backed).
  Engine: return the [first,last] runs directly.
- **`ConsecutiveSubStrings` family + `DupSecutiveSubStrings`** (chunk 14) --
  O(n^2) Ring-side window enumeration (`ConsecutiveSubStrings`, its Z/ZZ and
  Find forms) and the dup-consecutive detection built on it. Engine: emit the
  phase-tiled windows / spans and the consecutive-duplicate substrings directly.

(Rule reinforced 2026-07-01 after `FindDupSecutiveCharsZZ` was flagged: during the
audit, if a fix needs heavy char/substring iteration, implement it engine-side or
add it here -- do NOT ship a Ring loop as the permanent impl.)

## Per-file audit (post-203) — chunk log

**Chunk 1 (2026-06-30):** 04, 40, 44 audited→narrated (16 assertions). Real fixes:
- `StzEngineStringReplaceCS` mutates its handle IN PLACE (does NOT return a new
  handle). `ReplaceInSections` and `Interpolated(bindings)` both captured the
  (null) return -> empty output. Fixed both to read back from the input handle.
  This repaired `ReplaceInSections` (04) AND the `Interpolated([[k,v]])` form.
- `RemoveBounds()` is no-arg auto-detect in the original (was `RemoveBounds(c)`);
  restored, with the specific form kept as `RemoveThisBound(c)` (40, 2nd block).
- DEFERRED this chunk: **06** `SizeInBytes`/64/32 -- the original monolith has NO
  such method (no reference) and 64/32 are Ring-build-specific memory sizes
  (548/348 here vs archive 624/400); not portably assertable. **39**
  `SubStringsOccuringNTimes(3)` returns EXACTLY-3 but the archive expects >=3
  (semantics to resolve vs original) + its `SomeXT(..,1/100)` line samples
  RANDOMLY (non-deterministic).

**Chunk 2 (2026-06-30):** 39, 48, 56, 60, 67 audited→narrated (12 assertions).
Real fixes in the occurrence-count family (resolved vs the original aliases):
- `SubStringsOccurringNTimes(n)` means **>= n** in the original (aliased to
  `...NTimesOrMore`); the modular returned `= n`. Added a `_SubStringsByOccurrence
  (n, bExact)` helper and repointed: NTimes / misspelled `Occuring` -> ">= n";
  `Exactly` / `Only` -> "= n".
- `SubStringsOccurringNoMoreThanNTimes(n)` is aliased to `...LessThanNTimes` in the
  original (strictly `< n`); the modular used `<= n`. Now delegates, so
  NoMoreThan(1) -> [].
48/56/60/67 were already correct (earlier family fixes) -- just converted.

**Chunk 3 (2026-06-30):** 08, 58, 59, 68 audited→narrated (12 assertions; all
already correct from earlier ReplaceByMany/RemoveXT fixes). DEFERRED (logged):
- **70** `Section(-99,99)` should RAISE "Indexes out of range!" per the original
  (`SectionCS` raises; `SectionXT` is the lenient form). The modular `Section`
  clamps. This is a CENTRAL change (Section used everywhere) -- needs `SectionXT`
  to clamp instead + full regression; do it as a dedicated pass. NOTE: the
  original ALSO defines `Slice(n1,n2) = Section(n1,n2)` (relevant to test 98).
- **✅ RESOLVED 08 line 41** the fluent `StartsWithXTQ(..).AndQ().EndsWithXT(..)`
  chain. ROOT CAUSE: the modular `StartsWithXTQ`/`EndsWithXTQ` stored the boolean
  via `_SetNarrativeSub` which APPENDS `char(1)+value` to the content -> the
  following `EndsWithXT` matched against the corrupted content ("...Tunis..1").
  The original design (StartsWithCSXTQ) instead returns THIS when TRUE (content
  intact, chain continues on the real string) or `AFalseObject()` when FALSE
  (short-circuit). Rewrote both XTQ forms that way. `AFalseObject` already exists
  in `base/object/stzFalseObject.ring` -- ADDED the missing chain methods
  (AndQ/OrQ/StartsWith*/EndsWith*) to that class so the false-branch stays FALSE.
  (Do NOT recreate the class -- it lives under base/object, with stzTrueObject.)
- **07** managing_a_big_text: a perf demo over `_data/bigtext.txt` (file-dependent
  huge counts); left as a visual/perf test. (Confirms SizeInBytes = char count for
  ASCII = 6617121, supporting the 06 "archive 624 was a different definition".)

**Section pass (2026-06-30):** ✅ RESOLVED test 70. Per the original, `Section`
is the CONSERVATIVE form -- it auto-orders but RAISES "Indexes out of range!" on
out-of-bounds; `SectionXT` is the lenient form (negatives from the end, clamped).
The modular `Section` clamped silently. Made public `Section` strict; added
`_SectionLenient` (the old clamping body) and repointed all 23 internal
`This.Section(` callers to it (preserves their exact behavior -- only the
directly-called public Section is strict). `SectionXT` now slices via
`_SectionLenient`. Added `Slice`=Section / `SliceXT`=SectionXT / `SliceQ` (the
original defines Slice=Section). Test 70 asserts the raise + lenient XT + Slice.
NOTE: test 98 (`Q(1:20).Slice(...)`) is stzLIST.Slice -- still list-domain.

**Chunk 4 (2026-07-01):** 71, 77, 78, 79, 80, 82 audited→narrated (7 assertions;
all already correct from the earlier ReplaceXT/Except/ReplaceAllExcept/
ReplaceWithMany fixes -- pure conversions, no impl change).

**Chunk 5 (2026-07-01):** 104, 116, 117, 118, 119 audited→narrated (11
assertions; already correct from earlier ContainsInSection/Shorten* fixes -- pure
conversions). DEFERRED (LIST-domain, not stzString):
- **83** `SplitQ(" ").FindWhere(cond)` / `ItemsWhere` return [] -- the `This[@i]`
  W-DSL on a stzLIST evaluates empty. The string side (Split) is fine (returns a
  stzlist). List-domain W-DSL -- see [[reference-conditional-code-w-wf]].
- **84** `FindWXT` is RETIRED by design (R14 "no definition") per the WXT
  disqualification -- W is the single form. Its positive replacement (FindWhere)
  is the 83 issue.
- **128** already a documented `#SKIP` retired placeholder (FindSubStringsCS
  combinatorial analysis pending an engine-backed impl).

**Chunk 7 (2026-07-01):** 174, 175, 176, 181, 192, 229 audited→narrated (10
assertions; no impl change). Notes:
- **229** the archive `#-->` `["+10","-125","11"]` for `NumbersComingAfter("@i")`
  was WRONG on both counts: the original drops a leading "+" (its own example
  "@i+3" -> "3") and excludes unanchored numbers ("11" of "e11" follows "e", not
  "@i"). Current `["10","-125"]` matches the original -- asserted as-is.
- **181** the backslash-escaped data makes literal spans unreliable (header admits
  it); asserted that FindBetweenAsSections == FindAsSectionsXT(:Between) instead
  (the :Between form now works, was the deferred point).

**Chunk 8 (2026-07-01):** 246 audited→narrated (@char W form). DEFERRED:
- **246 `@substring` form** -- `FindWCS` routes @substring to the per-CHAR engine
  finder (`FindCharsWCS`), so a multi-char `@substring = "•♥•"` never matches
  (returns 0). Needs a substring-level W finder (`FindSubStringsWCS` -- iterate
  substrings + eval the predicate, or a new engine fn). The @char form is fine.
  Even the simple `@substring = "literal"` -> FindAll(literal) dispatch is not
  wired. Conditional-code area -- see [[reference-conditional-code-w-wf]].
- **237, 244, 245** use `UnicodeData()` / `UnicodeDataAsString()` which return
  EMPTY here (the ~1.9M-char unicode data resource is not populated), so every
  find is 0/[]. Data-dependent, not a code defect. (237/239 are also 2M-char perf
  demos.)
- **234** `post_it..._for_correction` is a Ring-community bug note about the
  builtin `substr()` with bullet chars -- not a stzString feature; left as-is.

**Chunk 9 (2026-07-01):** 247, 248, 249, 250, 254, 255 audited→narrated (15
assertions). Real fix:
- **`CapitalCased()` / `IsCapitalcase()`** (250). Per the original, CapitalCased is
  TITLE case (capitalise EVERY word, via `StzEngineStringToTitle`) -- the modular
  did sentence-case (first letter only, rest lower). Rewrote CapitalCased to use
  the `StzStringTitlecased` global, and IsCapitalcase to `CapitalCased()==Content()`
  (was a first-letter checker). "i believe in ring..." -> "I Believe In Ring...".
DEFERRED:
- **256** uses the retired `RemoveWXTQ` inside a `TrimQ().LinesQ()....RemoveWXTQ`
  fluent W chain (R14) -- needs the W-form replacement + a substring-W finder
  (same family as 246's @substring). See [[reference-conditional-code-w-wf]].

**Chunk 10 (2026-07-01):** 258, 260, 261, 262, 268, 269 audited→narrated (9
assertions; no impl change). 258/260/261 confirm Softanza's empty-substring
safety (FindZZ("")=[], Replace("",..)/ReplaceMany([""],..) = no-op) where Ring's
substr raises. 262 (ReplaceManyCSQ, no matching alias), 268/269 (SpacifyChars /
Spacified). DEFERRED:
- **263** uses `stzCCode(...).Transpile()` -- a DIFFERENT class (the conditional-
  code transpiler), not stzString. Out of scope for this pass.
- **265** retired `RemoveWXTQ` (R14) -- same substring-W-finder gap as 246/256.
- 257 (`_pr`) / 259 (`block_259`) look like empty placeholders -- verify later.

**Substring-W focused pass (2026-07-01):** ✅ RESOLVED the `@substring` W-DSL
gap (246). Added `stzStringFinder.FindSubStringsWCS`: enumerate all substrings
with their start positions, rewrite `@substring`->`@item` via the existing
`_StzNormalizeSubStringCond`, filter with `stzList.FindW`, map matching indices
back to positions (deduped, in order). `FindWCS` now routes `@substring` there
(`@char`/default still go to the per-char engine finder). `FindNthW(2,
'@substring="•♥•"')` -> 6. (83's list-W issue was specifically `This[@i]`; plain
`@item` works, which is what the normalizer emits.)
- STILL DEFERRED **256, 265** -- their `RemoveWXTQ` is on a `LinesQ()` result (a
  stzLIST), so it's the LIST-domain WXT->W migration, not stzString.

**Chunk 11 (2026-07-01):** 266, 267, 270, 271, 274 audited→narrated (11
assertions). Fix:
- **`(/)` operator with a LIST of sizes** (274). `o1 / [3,4,2]` fell through to
  `return ""` -- the operator handled a string (Split), a number (SplitToNParts),
  and stz objects, but not a raw list. Added `but isList(pValue) ->
  SplitToPartsOfSizes(pValue)` so `o1 / [3,4,2]` == ["123","4567","89"].
266 (FindAnyBoundedBy + IB), 267 (DeepFindBoundedByZZ nested), 270/271 (SpacifyXT
grouping) were already correct. DEFERRED: 272 (`stzListOfNumbers.ToSections`,
list-domain), 259 (empty placeholder), 263 (stzCCode), 264/265 (WXT/RemoveWXTQ).

**Chunk 12 (2026-07-01):** 275, 276, 277, 278 audited→narrated (7 assertions; no
impl change). Notes:
- **277** the archive `#-->` was "999 999 999 999" for ALL three cases (a copy-
  paste). Case 1 uses MIXED separators `[" ","."]` + steps `[3,2]` -> the actual
  (and correct) output is "99.99 999.99 999" -- the original's OWN example shows
  mixed separators emit the second separator. Asserted the real values.
- **NEW DEFECT (deferred): SpacifyXT advanced named form** `SpacifyXT(:Using =
  [".", :AndThen = " "], :Stepping = [2, :AndThen = 3], :Going = :Backward)`
  returns the string UNCHANGED (the `:AndThen`-nested list isn't parsed). The
  POSITIONAL mixed form works; only this named "advanced mode" (original example,
  monolith ~90657) is broken. No 275-278 test uses it, so logged for later.
- 272/273 (`stzListOfNumbers.ToSections`) are list-domain.

**Chunk 13 (2026-07-01):** 279, 287 audited→narrated. Fix:
- **`FindDupSecutiveCharsZZ`** (287) returned singletons `[[p,p],...]`; now GROUPS
  the consecutive dup positions into `[first,last]` runs ([3,4,5,7,8,9,11] ->
  [[3,5],[7,9],[11,11]]).
DEFERRED clusters found this chunk:
- **SpacifyXT ADVANCED SEPARATOR family** (280, 281, 282, 283, 284, 285) -- the
  `:Separator/:Using = [s1, :AndThen=s2, :LastNChars=n]` + `:Step=[a,:AndThen=b]`
  + `:Direction=[..:AndThen..]` advanced forms are broken (the literal word
  "separator" leaks; :LastNChars/:LastChars ignored). 6 tests -> strong FOCUSED-
  PASS candidate. The simple positional/named forms (270/271/275/276) are fine.
- **288** FindDupSecutiveSubString("ring") -> [4,4,8,4], archive wants [8,12].
- **291** NumberOfConsecutiveSubStringsOfNChars(4) -> 6, archive wants 26.
- **295** Unspacified: current removes ALL spaces; archive REDUCES runs of 2+ to
  one and drops single/edge spaces (" "->""; "  "->" "). Check original UnSpacify.
- 286/294 are list-domain (stzListOfNumbers / stzListOfStrings).

**Chunk 14 (2026-07-01):** 288, 289, 290, 291, 292, 293, 295 audited→narrated
(29 assertions). Real fixes (the consecutive-substrings + dup-secutive cluster,
resolving the 288/291/295 deferrals from chunk 13):
- **ConsecutiveSubStrings family rewritten to the ORIGINAL phase-tiled
  semantics.** `ConsecutiveSubStringsOfNChars(n)` = the n-char windows tiling
  the string from each of the n phase offsets (phase-major) -- across phases
  that is EVERY window, so `NumberOfConsecutiveSubStringsOfNChars(n)` = len-n+1
  (26, was 6). The pre-audit impl counted "back-to-back identical occurrence"
  matches -- a different feature entirely. Rewrote the whole family:
  all-lengths `ConsecutiveSubStrings()` (lengths 1..floor(len/2), 315 windows),
  `NumberOf...` (formula), `Find...OfNChars` (unique phase offsets, [1..n]),
  `Find...OfNCharsZZ` (phase-major spans), `...OfNCharsZ/ZZ` ([window,start] /
  [window,span]), `FindConsecutiveSubStrings` ([1..len]), `Find...ZZ` (per-length
  ascending spans), all-lengths `...Z/ZZ` groupings. NOTE: the archive #--> for
  the all-lengths Z/ZZ was generated by a buggy impl (entry substrings disagree
  with their own spans, e.g. `[ "hp", [2,2] ]`); asserted at the coherent
  original-impl values + a full 315-entry self-consistency sweep (292).
- **`FindDupSecutiveSubString` append-precedence bug** -- `_aRes_ + _i_ +
  _nSubLen_` appended TWO items per hit ([4,4,8,4] instead of [8,12]).
  Parenthesised (CLAUDE.md trap #5). `DupSecutiveSubStringZ/ZZ` now carry the
  `[sub, positions]` / `[sub, sections]` grouping (288).
- **Added the missing plural dup-secutive family** per the original:
  `DupSecutiveSubStrings` (= DupSecutiveItems of the phase-tiled window list),
  `FindDupSecutiveSubStrings(ZZ)`, `DupSecutiveSubStringsZ/ZZ`,
  `RemoveDupSecutiveSubStrings(Q)`, `DupSecutiveSubStringsRemoved`.
  ENGINE BACKLOG: the O(n^2) window enumeration + dup detection belongs
  engine-side (added to the backlog list above).
- **`RemoveSections` now MERGES inclusive/overlapping sections first** (via
  stzListOfSections.MergeOverlapping), matching the original RemoveManySections;
  overlapping spans no longer corrupt the removal (290 -> "PhpRingPythonRuby").
- **`Unspacify`/`Unspacified` rewritten to the original semantics**: Trim +
  collapse each run of 2+ spaces to ONE (was: remove ALL spaces). 293
  (" so ftan   za " -> "so ftan za") asserts it. NOTE: block 295's archive
  #--> predates that impl (pure-trim era: kept inner runs, and had an all-space
  quirk "  " -> " ") and contradicts both the archived impl and sibling 293;
  asserted at the original-impl behavior.

**Chunk 15 (2026-07-01):** 296, 297, 298, 299, 300, 301, 302, 303
audited→narrated (21 assertions). Real fixes:
- **`SplitAtSections` returned the sections' own content instead of the
  COMPLEMENT parts** (297). The original routes through
  stzSplitter.SplitAtSections (complement spans -- proven by the sibling
  archive block: "---456----123--67---" -> ["---","----","--","---"]) and
  slices those. NOTE: block 297's OWN archive #--> showed the sections
  ("r  in  g", "r  ing") -- inconsistent with the original impl and the
  sibling block; asserted at the complement. (Test 960 uses the sibling
  block and will now match as-is.)
- **`SubStringsBoundedByIBZZ` lost the `[substring, span]` grouping** (302) --
  returned bare spans; now zips each bound-inclusive substring with its span
  (same shape as SubStringsBoundedByZZ). This un-blocked 302's whole
  hash-list pipeline (keys = substrings, values = spans).
- OBSERVATION: the list W-DSL `FindW('This[@i] = "ring"')` on a stzList now
  WORKS (302 asserts it) -- the chunk-5 deferral of 83 (This[@i] evaluating
  empty) appears to have been fixed by the intervening W work; 83 is worth
  re-auditing when its number comes up.
296 (stzSplitter complement spans), 298/299/300/301 (FindZZ multi-needle +
RemoveSpacesInSections), 303 (FindAnyBoundedByIBZZ + misspelled
WithoutSapces alias) were already correct -- pure conversions.

**Chunk 16 (2026-07-02):** 304, 305, 306, 307, 308 (+308_distanceto), 309
(+309_distanceto), 310 audited→narrated (21 assertions). Real fixes:
- **`SpacifySubStringsUsingCS` rewritten** (306, 307; also re-grounds 133).
  The old impl spaced each substring SEPARATELY with a byte-based walk ->
  double spaces + "in" spacified INSIDE "Ring". New impl: find ALL sections
  at once (FindManyAsSectionsCS, sorted), drop sections strictly included in
  their predecessor (the original monolith's inclusion rule), bound each kept
  section with the separator on both sides, collapse duplicate separators,
  strip edges. The archive triple 133 + 306 + 307 pins the semantics (the
  original's insert-before-only algorithm CONTRADICTS its own block 133;
  the both-sides + collapse form satisfies all three).
- **`InsertXT(str, :EachNChars = n)`** (308) -- new branch routing to the
  existing InsertAfterEachNChars (was a silent no-op).
- **`stzStringList.SubStrongs()/SubStrinks()`** (305) -- were stubs returning
  the whole list; now the items CONTAINING another item / CONTAINED IN
  another item (engine StzFindFirst). Same fix mirrored in stzList.
DEFERRED:
- **311** `InsertAfterEachNCharsXT(3, :StartingFrom = :End)` -- the archive
  marks the block TODO and the call passes NO substring to insert (the "_"
  in the expected output has no source). Needs an upstream API decision;
  the forward form is covered by InsertXT(:EachNChars) in 308.
304 (IsStringOrList), 308/309_distanceto (DistanceTo/XT/STXT directional
family), 309/310 (InsertBefore/AfterPositions) were already correct.

**Chunk 17 (2026-07-02):** 312, 313, 314, 315 (x2), 316 (x2), 317 (x2), 318,
319, 320 (x2) audited→narrated (13 files, 44 assertions). Real fixes -- the
ST/STD/Z/ZZ finder-extension cluster:
- **`FindNthPrevious` :First/:Last were INVERTED** (312) -- :Last mapped to
  the nearest-backward instead of the farthest. Also `PreviousOccurrence` /
  `FindPrevious` now require the occurrence to lie ENTIRELY before
  :StartingAt (original searches Section(1, start-1)), fixing 316's
  FindPrevious(:StartingAt=10) -> 3 (not the overlapping 8).
- **Single-occurrence Z/ZZ groupings** (313, 314, 315) -- FirstZ/FirstZZ/
  FindLastZ/FindLastZZ/NthZ/FindNthZZ returned bare spans; now the settled
  [sub, pos] / [sub, span] shapes (+ added FindFirstZ/FindFirstZZ/FindNthZ/
  NthZZ aliases).
- **ST/STD family** (317, 318, 319; also pins the monolith SZZ/STDZZ blocks
  covered by later files): FindLastST advanced by BYTE length (missed the
  last multibyte occurrence); STD :Backward candidates now = occurrences
  ENDING at/before :StartingAt (were start<=), FindLastSTD :Backward = the
  FARTHEST such occurrence (was nearest), FindNthSTD gained the :Going =
  :Backward spelling (via a shared _IsBackwardDir helper); NthSTZ/FirstSTZ/
  LastSTZ now group [sub, pos] and LastSTZ is forward-from (was
  backward-bounded); FindFirstSZZ/FindNthSZZ/FindLastSZZ group
  [sub, [start, end]] per the archive.
315_findboundedbyzz/316_deep/317_findany (shallow vs DEEP bounded-by),
316_findnthst, 320_howmanyst (string+list HowManyST), 320_simplify
(NestedSubStringsIB) were already correct -- pure conversions.

**Chunk 18 (2026-07-02):** 321 (x2), 322, 323, 324 (x2), 325, 326, 327, 328,
329, 330 audited→narrated (12 files, 32 assertions). Real fix:
- **`FirstSTDZ/LastSTDZ/NthSTDZ` + `FirstSTDZZ/LastSTDZZ/NthSTDZZ`** (326,
  328) were pass-throughs to the Find forms; now carry the [sub, pos] /
  [sub, span] grouping like their Z/ZZ siblings.
The rest were already correct after chunk 17's ST/STD/SZZ overhaul: 321
(SZZ groupings + NestedSubStrings multi-char bounds), 322/324 (forward
STDZZ/STZZ spans), 323/325 (ST/STD positions), 327 (backward FindSTDZZ),
329 (FindFirstAsSection + ST), 330 (direction-only FindFirstDZZ), 324
(RemoveSubStringsBoundedByIB).

**Chunk 19 (2026-07-02):** 331, 333, 334, 335, 336, 337, 338, 339, 340
audited→narrated (9 files, 27 assertions). Real fixes -- the plural
list-form finders:
- **`FindZ(:Of = sub)`** (334) returned the FIRST section instead of the
  position list; now = Find (with :Of normalisation).
- **`FindST/FindSTZ/FindSTZZ`** (336) returned a single first hit; now ALL
  the occurrences starting at/after :StartingAt (positions / spans).
- **`FindSTD/FindSTDZ/FindSTDZZ/FindAsSectionsSTD`** (337) same singular
  bug; now ALL candidates -- forward = FindST; backward = occurrences
  ENDING at/before :StartingAt, nearest first; FindSTDZ = [sub, positions].
  NOTE: 337's archive #--> pasted FORWARD values into its first two
  backward calls ([8,13] backward-from-6 is impossible); asserted at the
  coherent rule its own last two lines and blocks #325-#328 pin.
331/333/335 (FindD/DZZ/DZ/AsSectionsD backward lists; 335's archive
"[13, 5]" is a typo for [13,15]), 338/339 (SplitQ().IfQ() fluent gate, both
condition spellings), 340 (same-substring bounds, overlapping) were already
correct -- pure conversions.

**Chunk 20 (2026-07-02):** 341, 342, 343, 344, 345, 346, 347, 348, 349, 350
audited→narrated (10 files, 37 assertions). Real fixes:
- **`FindAsAntiSections`** (342) returned the gap SUBSTRINGS; now the
  complement [start, end] spans (repointed at FindAntiSectionsZZ).
- **`ContainsXT(:SubString = s, :BoundedBy = b)`** (342) -- new dispatch
  (was FALSE); checks FindSubStringBoundedBy non-empty.
- **`FindAsSectionsXT` used BYTE length** for the substring span (multibyte
  hearts -> [8,16] instead of [8,10]); now codepoint. Same byte-length bug
  fixed in `FindBetweenAsSections` (its 181 agreement guard caught it).
- **`:BoundedByIB` support** in FindXT (positions anchor at the opener) and
  FindAsSectionsXT (spans include both bounds), via a `_BoundsPair`
  normaliser (single string widens, :And unwraps) (346).
- **`FindSubStringsBoundedByIBCSZZ` same-bounds overlap** (341) -- the
  pairing loop now reuses each closer as the next opener when open=close
  (was skipping past it, dropping every second gap).
- **Occurrence-index selectors** (349, 350): FindTheseOccurrencesST/STZZ
  ignored :StartingAt (and the archive #--> for 349's ST lines listed all 3
  occurrences for a 2-index selector -- incoherent; asserted at
  renumber-then-pick); FindTheseOccurrencesSD/AsSectionsSTD ignored both
  :StartingAt and direction; all four now pick by index from FindST/FindStD.
  `_IsBackwardDir` tolerates the archive's ":Bakcward" misspelling (350).
343/344/345/347/348 were already correct -- pure conversions.

**Chunk 21 (2026-07-02):** 351-360 audited→narrated (10 files, 41
assertions). Real fixes:
- **`Find([subs])` multi-needle** (354) returned a grouped shape; now flat
  sorted positions. `TheseSubstringsZ/ZZ` returned first-hit flats; now the
  [sub, [positions]] / [sub, [sections]] groupings (+ FindManyZZ alias).
- **`FindBoundedBy` / `FindBoundedByIB`** (352, 353) returned spans; now
  the content-start / opener-start POSITIONS (ZZ/IBZZ keep the spans).
- **`Split`/`SplitCS`/`SplitAt` named-param dispatch** (356, 358, 359) --
  :At (position / positions / substrings), :AtSection(s), :Before/:After
  (single, list, position(s), section(s)) were all unhandled (returned the
  string unsplit or raised). Wired through SplitAtSections /
  SplitBefore(After)Positions / SplitBefore(After)CS.
- **`stzString.IsEither(a, :Or = b)`** (358's WF predicate) -- the
  stzObject impl doesn't unwrap :Or and falls into its "not implemented"
  object branch; added a string-side override. (stzObject.ring left
  untouched -- it carries pre-existing uncommitted changes.)
351 (converging ST finders), 355 (narrative table placeholder -> three
representative split one-liners), 357 (sections/anti-sections), 360
(SplitAroundSections + IB on splitter and string; the splitter IB line had
no archive #--> -- asserted at spans matching the string IB pieces) --
pure conversions.

**Chunk 22 (2026-07-02):** 361, 362, 363, 364, 366, 367, 368, 369, 370 (x2)
audited→narrated (10 files, 46 assertions). Real fixes:
- **SplitAround family** (363): SplitAroundIB / SplitAroundSubStringIB
  returned drop-semantics or garbled pieces; now route through
  SplitAroundSectionsIB (pieces extend ONE char into each adjacent anchor).
  SplitAroundPositions ISOLATED the position chars; per the monolith it
  DROPS them (446's earlier WXT-replacement assertion updated to match the
  family). SplitAroundSection(IB)(n1, n2) hit the single-clause-if
  param-reassign no-op (CLAUDE.md note 6) -- rewrote with fresh-var
  if/but/else. SplitAroundSubStrings now MERGES overlapping occurrences
  (stzListOfSections) before splitting -- no more empty fragments; its IB
  twin was a plain alias, now real.
- **SubStrings family** (366): added UniqueSubStrings (= SubStringsU),
  NumberOfUniqueSubStrings, SubStringsZ / SubStringsZZ ([sub, positions] /
  [sub, sections] per unique substring). NOTE: the archive's SubStrings()
  enumeration order differs from the impl's i-major order (same multiset);
  asserted at impl order.
- **IsEitherCS(a, :Or = b, :CS = bCase)** (366) -- added (missing).
- **BoundsXT / BoundsUpToNChars** (366) -- BoundsXT was a 2-arg
  nth-bounded-match accessor nobody called; per the archive it caps the
  auto-detected Bounds() at N chars a side (:UpToNChars = n, bare n, or
  [nL, nR]). Rewritten (+ BoundsUpToNChars alias).
- **SubStringXT bound predicates** (369, 370): added :IsBoundOf /
  :IsBoundedBy / :IsFirstBoundOf / :IsLastBoundOf / :IsLeftBoundOf /
  :IsRightBoundOf dispatch; SubStringIsBoundedBy's single-string widening
  hit the note-6 no-op -- fixed with fresh-var if/but/else.
- 367/368 BoundsOf: asserted at the per-occurrence NESTED [open, close]
  pairs settled in block #42 (the archive displayed them flattened).
361/362 (splitter SplitAtSection(IB), SplitAround position), 364
(Sections/AntiSections; archive's "THREE" was a typo for "ONE"),
370_semantic (size verbs) were already correct.

**Chunk 23 (2026-07-02):** 371-380 audited→narrated (10 files, 17
assertions). Real fixes:
- **`RemoveThisFirstCharCS(c, :CS = b)`** (371) ignored the case flag and
  compared raw codepoints (case-insensitive "a" vs "A" never matched); now
  removes the single first char under the requested case rule.
- **`RemoveThisNthChar(n, c)`** (371) removed the n-th OCCURRENCE of c;
  per the archive's own NOTE it removes the char AT position n only if it
  equals c. Rewritten.
- **`AddXT` :AfterNth = [n, sub] / :AfterFirst / :AfterLast (+ :ToFirst /
  :ToLast) and the :BeforeNth / :BeforeFirst / :BeforeLast mirrors**
  (377, 378, 379) -- all raised "unsupported argument shape"; wired to
  FindNth/FindFirst/FindLast + positional inserts. NOTE: 378's archive
  #--> pasted 377's result; asserted at the real AfterFirst outcome.
372-376, 380 (RemoveSection, RemoveFromStart/End, ReplaceSection multibyte,
AddXT :After/:AfterEach/:Before) were already correct -- pure conversions.

**Chunk 24 (2026-07-02):** 381-389 audited→narrated (9 files, 9
assertions). Real fix:
- **`AddXT` :AroundEach / :AroundNth = [n, anchor] / :AroundFirst /
  :AroundLast** (385-389) raised "unsupported argument shape"; wired
  (p1 = one separator for both sides, or an [open, close] pair; inserts
  applied descending so positions stay valid). The bare :Around form
  already worked. 381-384 (:BeforeEach/:BeforeNth/:BeforeFirst/
  :BeforeLast) were covered by chunk 23's mirrors -- pure conversions.
DEFERRED:
- **390** `Replace(sub, :By@ = '<ring code>')` -- the eval-based @-form
  references a CALLER-SCOPE variable inside a code string; eval is retired
  (W/WF policy) and Ring has no caller-scope reflection (same family as
  the $()/Interpolate deferral, block #111). No #--> in the archive either.

**Chunk 25 (2026-07-02):** 391, 392, 393, 394, 396, 397, 398, 399, 400
audited→narrated (9 files, 27 assertions). Real fixes:
- **`Section` :@ mirror param** (397) -- :@ now mirrors the OTHER param
  (both :@ = whole string), per the original SectionCS. NOTE: 397's
  archive `Section(2, -2) --> "234"` never matched the original impl
  (which raises out-of-range, as does the strict modular Section); the
  negatives-from-end reading is SectionXT's -- asserted there.
- **`TheseCharsZ`** (396) on BOTH stzString and stzList returned flat
  position lists; now the [c, [positions]] grouping.
- **`stzList.CommonItems`** (393) rejected a direct list argument
  (returned []; only :With = worked), and returned MULTISET results
  (duplicates); now accepts both arg shapes and dedupes keeping the
  host's order (the set-intersection semantic its own narrative doc
  states; the affected list-module tests still pass). The archive's
  stzListOfLists ordering differed for the same 12-item set; both forms
  now agree on host order.
391 (Concatenate spellings), 392/394 (CommonSubStrings), 398/399/400
(SubStrings counts + case folding) were already correct.

**Chunk 26 (2026-07-02, first BIGGER chunk -- 19 files):** 401-411, 414-420
audited→narrated (18 files, 43 assertions), 412 deferred. Real fixes:
- **`LeadingNumber` / `TrailingNumber` sign- and decimal-aware** (408-411):
  both stopped at the first non-digit, so "Amount: -132.45" trailed "45"
  and "-23.67 pounds" led with "". Now one decimal point between digits
  and an adjacent +/- sign belong to the number. `StartsWithANumber` now
  = LeadingNumber() != "" (was first-char-digit, missing signed opens).
- **`SplitToPartsOfNChars(n)` drops the shorter remainder** (414) -- it is
  the "exactly n" form (alias SplitToPartsOfExactlyNChars added); the XT
  form keeps the remainder (was: both kept it).
- **`stzList.NextNItems(n, :StartingAtPosition = p)` is EXCLUSIVE** (417)
  -- returns the n items strictly AFTER p (was inclusive-from-p),
  matching the string-side NextNChars. `PreviousNItems` gained the
  positional (n, :StartingAtPosition = p) shape alongside its
  anchor-based (pcAnchor, n) form. (List test 331_nextnitems still green.)
DEFERRED:
- **412** `stzList.FindWXT` -- retired by design (WXT disqualification;
  same precedent as #84, #219-#221); replacement is FindW.
Pure conversions: 401/402/415 (SubStrings), 403/404 (NumbersComingAfter +
Numbrify/Numberify chain), 405 (SectionXT negative), 406/407 (Find/ZZ +
FindManyAsSections), 416 (SubStringsWF), 418 (Next/PreviousNChars),
419 (Sectioned), 420 (MergeContiguous).

**Chunk 27 (2026-07-02, 17 files):** 421-424, 427-431, 433-437 audited→narrated
(14 files, 40 assertions), 425/426/432 deferred. Real fixes:
- **"Made of" runs take a char POOL** (421): FindSubStringsMadeOf(ZZ) treated
  the arg as ONE char, so FindMadeOf("12") found per-char singles instead of
  the maximal runs made of {1,2}. Rewrote the family pool-based (single-char
  args unchanged -- 427 still green); SubStringsMadeOfZZ now returns the
  [run, span] grouping (was bare spans).
- **`FindNumbers` now = number STARTS** (428/429): was digit-run starts
  (sign/decimal blind, so "-132114.45" split into 2, 9). Derived from
  FindNumbersAsSections (already sign-aware). **NumbersZ / NumbersZZ** now
  group each UNIQUE number with its positions / sections (were: bare starts /
  digit-run spans); + NumbersAndTheirPositions/Sections aliases. NOTE: 428's
  archive #--> displayed single-occurrence ZZ groups flattened ([num, span]);
  asserted at the [num, [sections]] shape that 429's own archive pins.
- **`stzList.SplitAtPositions` / `SplitW` now MUTATE and drop anchors**
  (423/424): they returned parts (or nothing) without updating the content,
  and the engine split kept the anchor items in the parts. Now: content
  becomes the parts, the split positions' items are dropped (Splitted* stay
  the passive twins). List test 557_splitat still green.
- **434** Five(Star())/Three(Heart()): archive showed strings, but @N/Three/
  Five are PINNED as list-returning by the earlier narrated block-08 test --
  asserted at the settled LIST shape (string spelling = RepeatedNTimes).
- **436** archive's `RepeatedNTimesXT(0, :InAList) --> ["Hi!"x3]` was a typo
  for n=3; n=0 asserted as [].
DEFERRED:
- **425, 426** `stzList.FindWXT` / `SplitWXT` -- retired WXT (precedent
  #84/#219-#221/#412); the W pipeline is asserted in 423/424.
- **432** `SoftanzaLogo()` box-glyph art -- placeholder impl + source-mojibake
  family (blocks #99-#101); visual, not assertable.
Pure conversions: 422, 427, 430, 431, 433, 435, 437.

**Chunk 28 (2026-07-02, 14 files):** 441, 447-458, 460 audited→narrated
(14 files, 26 assertions). Real fixes:
- **`(/)` operator list-divisor dispatch** (447): a non-numeric list fell
  into SplitToPartsOfSizes and crashed in _EngineSlice. Now dispatches:
  the `WXT(cond)` marker ([:WhereXT, cCode]) -> SplitW(cond) (the W form,
  no eval); a list of numbers -> SplitToPartsOfSizes (unchanged); a list
  of [name, size] pairs (size may be :RemainingChars) -> named portions
  [[name, part]]; a list of string names -> SplitToNParts distributed as
  [[name, part]] pairs.
- **`InfereMethod(:From = :stzClass)` restored to the original contract**
  (450): was a boolean does-this-method-exist stub; now infers the class's
  predicate method for THIS string ("is"+string, else "is"+string minus
  the final s, via Stz(type, :Methods)). The archive's "ispunctauion" was
  a typo for "ispunctuation".
- **W-DSL sugar: `Q(@char).IsNumberInString()` lowers to isDigit** (460):
  added isnumberinstring/isanumberinstring to _StzMapWPredicate, so the
  digit-removal chain works through the engine. 460's retired
  RemoveCharsWXTQ spelling converted to RemoveCharsWQ (WXT precedent).
Pure conversions: 441, 448, 449, 451-458.

**Chunk 29 (2026-07-02, 16 files):** 461-464, 466-472, 476-480 audited→narrated
(16 files, 42 assertions; 473-475 already retired #SKIP placeholders). Real fixes:
- **Object-history feature implemented** (466-469). QH()/Qh() and
  KeepHistory()/DontKeepHistory() now work: recording happens at the PUBLIC
  fluent-op boundary via new `_StzHistoOpen` (records the pre-op value once
  per stream) + `_StzHistoAdd` (records each op's result) -- hooked into
  RemoveCharsWQ/RemoveWQ/RemoveSpacesQ/RemoveDuplicatedCharsQ (string),
  RemoveWQ/RemoveSpacesQ/RemoveDuplicatedItemsQ (list), Add/SubStruct/
  MultiplyBy/DivideBy (number). History() consumes the stream. A per-Update
  trace was tried first and FLOODS with internal steps -- boundary-only is
  the design. TWO VM traps hit en route: (a) `StzTraceObjectHistory`'s call
  to the missing `AddHistoricValueInternal` raised inside try/catch and
  CORRUPTED the calling method's This (number ops read Content()="" after) --
  the basic-path call is now removed; (b) nested-def Q wrappers in stzNumber
  could not read This.Content() after the inner call -- hooks moved to the
  parent methods. NOTE: 468's archive omitted the initial value from the
  number history (its siblings 466/467/469 include it) and its #--> "45" was
  wrong arithmetic (46); asserted at the uniform impl behavior. The archive's
  retired RemoveWXTQ spellings converted to the W forms.
- **`UnicodeDirectionNumber` translated utf8proc->Qt** (472): the engine
  reports utf8proc bidi classes (AL=5) but the public contract is Qt's
  QChar::Direction (AL=13) -- added the 23-entry map, so the European-
  separator/terminator ("3"/"4") and RTL-embedding ("14") checks are
  consistent again. **IsRightToLeft / IsLeftToRight** now check the full
  Qt class sets ({1,13,14,15,20} / {0,11,12,19}) instead of one value.
- **`IsAFunction` restored to the original contract** (471): TRUE iff the
  content names a DEFINED function (functions() lookup); was a "looks like
  a call" stub. **`stzString.IsAString`** added (was only on stzChar; 476).
- **`AllCharsAre(:CircledNumbers)`** (480): added the circled-number kind
  (U+2460-2473, U+24EA, double-circled, CJK circled ranges).
- **479/480 source mojibake**: the circled-digit literals were double-
  encoded ("â‘ " for "①"); rebuilt with the real glyphs.
DEFERRED:
- **477's CharsInverted() glyph line** -- the Turned/Inverted upside-down
  family is retired pending the inverted-char table port (473-475); the
  :Invertible kind check IS asserted. The current CharsInverted (swapcase
  chars) also mismatches the original (= CharsTurned); noted with the family.

**Chunk 30 (2026-07-02, 20 files):** 481(x2), 483-494, 498, 500 audited→narrated
(16 files, 47 assertions; 495-497/499 already retired #SKIP placeholders).
Real fixes:
- **`RepeatXT`/`RepeatedXT` type preservation** (487): the value resolver
  treated ANY object whose content "is a number" numerically, so
  Q("5").RepeatedXT(:InA=:List) produced [5,5] instead of ["5","5"]. Now only
  a real stzNumber repeats its numeric value; :ListOfNumbers/:ListOfStrings
  keep doing the explicit coercion.
- **`SpacifyItR` returns the result STRING** (500): the R-suffixed narrative
  ending returned This (the ? printed the attribute dump); now returns
  Content().
- **`UppercaseQ`/`LowercaseQ` are history-aware** (489): added the
  _StzHistoOpen/Add boundary hooks so QH("h e l l o").RemoveSpacesQ().
  UppercaseQ().History() captures all three steps.
Pure conversions: 481(x2), 483, 484, 485, 486, 488, 490-494, 498. 487's
final ToStzTable().Show() is visual and noted, not asserted.

**Chunk 31 (2026-07-03, 18 files):** 502-503, 505, 507-520 audited→narrated
(17 files, 47 assertions), 506 left as a visual stzTable demo. Real fixes:
- **`stzListMover.Move` was a silent no-op** (517): it mutated the list
  returned by This.List() -- Ring returns lists from methods BY VALUE, so
  the edits were lost; and its ring_insert offset was off by one. Now works
  on a local copy, inserts AT the target position, and writes back. NOTE:
  517's archive #--> showed the post-swap list unchanged -- a copy-paste
  error; asserted at [A, C, B], consistent with the string twin (516).
- **Named-param normalization for `Swap`/`Move`** (516/517/519):
  stzString.Swap(:Positions = a, :And = b); stzList.Move(:ItemFromPosition
  = a, :To = b), stzList.Swap(:Positions/:And) and the value form
  Swap(item1, :And = item2) (find both, swap positions).
- **`FindSubString` returns ALL positions** (520): was the first position
  (engine FindFirst); now aliases Find per the StzFind list contract
  (FindSubStringCS -> FindCS likewise).
- **`BoundsXT(:Of = sub, :UpToNChars = caps)`** (515): the per-occurrence
  capped-bounds form (caps: number = both sides, [l, r] = per side, 0 ->
  NULL side), built on the per-occurrence BoundsOf walker. The whole-string
  single-arg cap moved to `BoundsUpToNChars` (Ring has no arity
  overloading; the two archive spellings collided -- test 366 repointed to
  the UpToNChars spelling, same values).
- **History hooks extended across type-crossing chains** (505): SpacifyQ /
  CharsQ / ReplaceQ (string), UppercaseQ / LowercaseQ (stzList),
  RemoveSpacesQ / UppercaseQ / JoinQ (stzListOfChars) -- so
  QH("LIFE")...History() captures all 9 steps incl. the string->list->
  string transitions. (The QHH VTMS time/size columns are machine-dependent
  -- noted, not asserted.)
Pure conversions: 502, 503, 507-514, 518. 511's source had a
whitespace-only line that had to be preserved byte-exactly.

**Chunk 32 (2026-07-03, 19 files):** 521-523, 525, 527-540 audited→narrated
(18 files, 63 assertions; 526 already a retired #SKIP placeholder). Real fixes:
- **Section named-anchor vocabulary restored** (523, per the ORIGINAL
  SectionCS): symbol pass-through for :FirstChar/:LastChar/:EndOfString/
  :EndOfLine (CR/LF-aware, from n1); substring anchors -- :From = FIRST
  occurrence, :To = LAST (FindFirstCS/FindLastCS); the :NthToLast named
  param. RULING: block #168's #--> "FTA" for Section(:From="F",:To="A")
  contradicted the original impl and sibling #523 ("FTANZA") -- the impl
  wins; 168 re-asserted (its char-LIST twin keeps first-occurrence
  anchors, list domain).
- **`NthToLast(n)` = char at len - n** (522), per the original
  CharAtPosition(NumberOfChars() - n); was len - n + 1.
- **`Sit` extended** (536-538): :OnPosition, :AndHarvestSections (spans
  instead of substrings), and the CONDITIONAL harvests :CharsBeforeW /
  :CharsAfterW (maximal run of chars satisfying a W predicate). In char
  context "IsANumber" lowers to the engine's isDigit (a char is a string
  to isNumber's type check). Gotchas re-hit: NULL sentinels (isString("")
  = TRUE) -> boolean flags; Ring's non-short-circuit `and` -> nested ifs.
- **`SubStringBoundsXT(:Of=, :UpToNChars=)`** (533/534): flat per-
  occurrence bound runs, capped per side, empty sides dropped.
- **Inline `[ open, :And = close ]` bound shape** accepted by the
  BoundedBy family (528/539; normalized in BoundedByCS -- nested-if +
  temp-var form, Ring indexes literals eagerly). **SubStringsBoundedByU
  is UNIQUE** (was mislabeled case-insensitive; the settled U convention).
- **Named unwraps**: NumberOfOccurrence(:OfSubString=), Positions /
  FindPositions(:Of=), Split(:Using/:By/:With=) (525, 529, 539).
- **`IsListInString` accepts short-form ranges** (527) and the To*Form
  converters implemented: ToListInShortForm ("1 : 3" / '"A" : "D"'),
  ToListInNormalForm / ToListInString (@@-canonical), ToListInStringSF.
  **`ToList` expands ranges BEFORE eval** -- Ring's native ':' is
  byte-based and returns the left operand for multibyte endpoints
  (Arabic ranges); unquoted numeric endpoints now expand to NUMBERS.
- NOTE: 525's archive #--> was written against a simplified input (parts
  lack the **/_ decorations) with CI splitting; asserted at both dials'
  real outputs. 532 asserts Section's strict raises via try/catch.

**Chunk 33 (2026-07-03, 20 files):** 541-543, 545-560 audited→narrated
(19 files, 55 assertions; 544 does not exist). Real fixes (the bounded-by
family consolidation):
- **One canonical region walk** `_BoundedContentSpansOC(open, close)`:
  scans bound TOKENS non-overlappingly and, for SAME-string bounds,
  REUSES each closer as the next opener (the settled overlap rule) --
  distinct bounds advance past the closer. Rewired:
  FindSubStringsBoundedBy(+ZZ) (548: "**" now yields all 5 gaps, single-
  string widened -- no more raise), FindBoundedByAsSectionsCS same-char
  (553: quotes overlap without recursion), FindAnyBoundedByZZ same-char,
  and FindAnyBoundedByIB(ZZ) (549: "**" inside "***" no longer emits
  overlapping TOKEN artifacts -- [1,7,13] / [[1,8],[7,14],[13,22]]).
- **`FindSubStringBoundedBy(CS)` = EQUALITY** (545/559): only occurrences
  that ARE a whole bounded content count ("word" inside <<noword>> is
  skipped; the CS dial lower-compares). **`FindBetween` keeps CONTAINMENT**
  (sub anywhere inside a region) with its own walk -- the two semantics
  were riding the same impl and 161/180 caught the split immediately.
- **`FindManyCS` = FLAT + SORTED positions** (549), per the original
  monolith (FlattenQ().Sorted()); was the grouped [sub, positions] shape
  (which remains TheseCharsZ / the Z-family's job -- 396 unaffected).
- **`Split` drops EDGE empty parts** (549 + 525 re-asserted): leading/
  trailing separators produce no "" parts; interior empties (adjacent
  separators) are kept -- matching both archives' part counts.
- **`FindNthBoundedBy(ZZ)` accepts (n, sub, bounds)** (541) alongside the
  legacy (n, bounds, sub) order.
- **`NLastOccurrences(:Of=)` / `NLastOccurrencesST`** (547): the stzObject
  fallbacks ran a SectionQ(:Last) pipeline that can't take symbols (and
  the :Of named list reached the engine raw). stzString unwraps :Of in
  FindLastNOccurrences and routes NLastOccurrencesST to its own
  LastNOccurrencesST (now also accepting a plain-string sub).
Pure conversions: 542, 543, 546, 550-558, 560.

**Chunk 34 (2026-07-03, 20 files):** 561-580 audited→narrated (20 files,
44 assertions). Real fixes (the AUTO-BOUND family + bounded edits):
- **Auto-bound rule settled** (567/568/570/572, harmonized): for each
  occurrence of a substring, its bounds are the maximal runs of the SAME
  NON-SPACE char immediately before/after; an occurrence is "bounded"
  when BOTH runs are non-empty (so bare space-separated words never
  count, but 572's "n" run does). One helper `_SubBoundRunsOf` feeds:
  FindBoundedSubString(ZZ) (occurrence starts/spans), the IB forms
  (left-run start .. right-run end), FindSubStringBounds(ZZ) (flat run
  starts/spans), SubStringBounds (flat run substrings), and the
  RemoveBoundedSubString(IB) removals. RULINGS: 569's archive #-->
  dropped the first bare "word" (typo -- sibling 570's IB removal keeps
  it); 573's plain-FindSubStringBoundsZZ #--> was a copy-paste of its
  These-form's flat value.
- **`FindTheseSubStringBounds(ZZ)`** (573): only occurrences IMMEDIATELY
  wrapped by the explicit open/close tokens count; flat token positions /
  token spans (was: returning the bound STRINGS).
- **`ReplaceSubStringBoundedBy` = the equality contract** (574/575):
  routes through FindSubStringBoundedByZZ + ReplaceSections, so
  same-string bounds ("--") pair with the overlap walk and "--nword-"
  survives; `ReplaceXT(:BoundedBy)` with a non-empty substring now takes
  the same path (the empty-p1 replace-all-regions behavior of blocks
  194/199 is preserved). 575's second archive example replaced :With =
  "word" but showed --WORD-- (typo); asserted with "WORD" in both forms.
- **`RemoveAnySubStringBoundedBy` keeps the bounds** (577): removes the
  region CONTENTS via FindAnyBoundedByZZ (was: a while-loop that ate the
  bounds too); the IB variant removes bounds via FindAnyBoundedByIBZZ.
- **`FindXT` :StartingAt / :InSection(s)** (563): positional filters
  added. Gotcha re-hit: the reassign type-widening if silently no-ops
  (CLAUDE.md note 6) -- fresh-variable form used.
- 566's archive #--> showed <<word>> for a replace-with-"wrod" (typo).
- 565's long-open defect (FindSubStringBoundedBy("word") -> [11,30,43])
  CLOSED by chunk 33's equality semantics -- now [11] as the archive wants.

**Chunk 35 (2026-07-03, 20 files):** 581-596, 598-600 audited→narrated
(19 files, 45 assertions), 597 deferred (network-dependent FromURL demo).
Real fixes:
- **`BoundsOf` is FLAT** (589-591): the original SubStringBoundsCS
  computes Sections(bound sections) -- a flat [left, right, left, right,
  ...] list of the occurrences bounded on BOTH sides (590: edge
  occurrences drop out) -- while its own doc comment showed pairs (the
  shape my chunk-early ruling on 42/43/367/368 had followed). RULING:
  impl + 3 archive blocks win; BoundsOf/FirstBoundsOf/LastBoundsOf are
  flat projections of the internal `_BoundsOfPairs` walker (which
  BoundsOfXT and the capped forms keep using -- their pair shapes are
  archive-pinned). Tests 42/43/367/368 re-ruled to flat.
- **RTL-aware Left/Right** (581): stzString.IsRightToLeft() (first
  strong bidi char), NRightCharsAsSubString / NLeftCharsAsSubString
  mirror for RTL text (per the original IsRightToLeft-aware impl), and
  RemoveFromRight removes from the START of an RTL string.
- **`RemoveNthOccurrence(CS)` accepts :First / :Last** (583/584) and the
  CS dial now actually dials (was documented-permissive ignore); rebuilt
  on FindCS + RemoveSection.
- **`StzRaise` hash form fixed** (594): the [:Where,:What,:Why,:Todo]
  hash was gated behind IsRaiseNamedParamList (which only matches a
  [:Raise, x] pair) -- now detected structurally, so the formatted
  multi-line message raises as documented.
- 593/594 assert the raises via try/catch. NOTE: 599/600's archive
  #-->s for Next-occurrence positions (2/40 and [18,40]) were off-by-one
  hand values contradicted by their own FindAll lines ([1,17,39]);
  asserted at the coherent inclusive-ST values.
Pure conversions: 582, 585-588, 592, 595, 596, 598.

**Chunk 36 (2026-07-03, 20 files):** 601-620 audited→narrated (20 files,
70 assertions). Real fixes (the MARQUER family reshape):
- **Marquers are "#N" STRINGS** (606-608 pin the shape; 605's archive
  showed the bare digits -- garble): Marquers()/First/Last/NthMarquer/
  NextNthMarquerST/PreviousNthMarquer/Previous+NextMarquers now return
  the marquer strings; the Find* twins return positions (FindFirst/
  FindNth/FindLast were repointed off the string forms). The numeric
  view stays in Markers(), which the sorted-ascending/descending checks
  keep using. Marquer() itself returns the SYMBOL "#".
- **The grouped projections**: MarquersZ = [m, pos] pairs; MarquersZZ =
  MarquersAndSections; MarquersUZ / UZZ = unique marquers with ALL their
  positions / sections (were: first-only). PreviousMarquerZ /
  PreviousNthMarquerZ return the [m, pos] pair. A circular alias
  (FindPreviousNthMarquer <-> PreviousNthMarquer) caused a stack
  overflow en route -- repointed to the computing FindNthPreviousMarquer.
- **`IsMultipleOfCS` accepts :CS = named spelling** (604).
Pure conversions: 601-603, 612 (the emptiness constitution), 613, 619,
620.

**Chunk 37 (2026-07-03, 20 files):** 621-633, 635-640 audited→narrated
(19 files, 63 assertions; 634 already a retired #SKIP placeholder).
Real fixes (the marquer SORTING semantics, settled from the archives):
- **Two sort views coexist**: MarquersSortedZ/ZZ and
  MarquersSortedInDescendingZZ ZIP the number-sorted marquer strings
  onto the TEXT-ORDER positions/sections (the view of the would-be
  sorted string -- 626/627 pin it); MarquersSortedUZ/UZZ sort the
  UNIQUE marquers by number, each keeping its OWN positions/sections
  (628 pins it). The UZZ comparator R21'd on the new grouped shapes --
  both comparators now compare the marquer NUMBERS. (626's archive
  section ends were off by one; asserted at the real 2-char spans.)
- **`SortMarquersInAscending/Descending` actually SORT** (629/631):
  they returned a sorted positions list without touching the content;
  now they rewrite the marquer slots with the sorted values.
- **`MarkTheseSubStringsCS` / `MarkSubStringsCS` produce ordinal
  marquers** (630): each listed substring becomes #1, #2, ... (was: a
  [|...|] wrap); ReplaceSubstringsWithMarquersCS alias added, and
  **`ReplaceSubStringsWithMarquers` was wired BACKWARDS** (it called
  ReplaceMarquers, filling instead of marking) -- now marks (631's
  round-trip: fill -> re-mark -> sort -> refill all green).
Pure conversions: 621-625, 632, 633, 635-640 (incl. the Unicode
UpTo/DownTo generalisation of Ring's ASCII-bound ":" ranges).

### Chunk 38 (tests 641-660, 2026-07-03)

- **`ReplaceNextNthOccurrence` / `ReplacePreviousNthOccurrence` accept
  named params in ANY order** (646/647): new `_ResolveOfWithFrom()`
  resolves `:Of`/`:With`/`:StartingAt` hashes wherever they appear
  (positional fallback preserved). Before, the archive's
  `(2, :Of=.., :StartingAt=.., :With=..)` order silently no-oped.
- **`IsLocaleAbbreviation()` is structural** (649): split on `_`,
  1-3 alpha parts of len 2-4, a 4-letter part only in the script slot,
  single part <= 3. Was a stub returning FALSE for `ar_Arab_TN`.
- **`StringCase()` / `CharCase()` are codepoint-aware** (653/654/657):
  rewritten on StzLower/StzUpper (byte `upper()` misread Greek and
  eszett). Vocabulary RULING: the every-word-capitalised case is
  **`:Capitalcase`** (653's archive + the settled `CapitalCased` name);
  247_stringcase said "titlecase" for the same concept -- updated.
- **`StzUpper` honors the ß->SS SpecialCasing** (657): pre-replace in
  stzPrimitives; `Q("der fluß").Uppercased() = "DER FLUSS"`. Ring's
  builtin `upper()` stays byte-based ("DER FLUß") -- asserted as such
  in 658 with a note (archive's "DER FLUSS" for it was Qt-era).
  Full SpecialCasing.txt (incl. tr-TR dotless i) stays on the engine
  backlog; 655 DEFERRED on it, and 659's eszett round-trip
  (`IsLowercaseOfXT`) asserted FALSE per the archive's own limitation
  note.
- **`Unicode()` on a multi-char string returns the codepoint LIST**
  (656): was a raise; now delegates to `Unicodes()`. 656 also fixed
  `CharsNames()` (R24: uninitialized result var) and asserts the
  composed-vs-decomposed e-circumflex pair built PROGRAMMATICALLY
  (`StzEngineCharToUtf8(234)` / `"e"+StzEngineCharToUtf8(770)`) so no
  editor normalization can corrupt the decomposed literal.
- **`HasLeadingChars()`/`HasTrailingChars()`** (645): now
  `NumberOfLeading/TrailingChars() > 0` (the old checker path was
  broken); list-side twins verified against the same fixture.
- **642**: transpiled form asserted at single-space `This[@i] = "I"`
  (archive's double space was cosmetic garble).
- **650 DEFERRED**: stzLocale-domain narrative (script->language
  inference, country compatibility) with self-declared TODOs; belongs
  to the locale module pass.
Pure conversions: 641, 644, 648, 651, 652, 660.

### Chunk 39 (tests 661-680, 2026-07-03)

- **`LeadingSubString` / `TrailingSubString` = the repeated-char RUN**
  (672-675): were "longest non-letter prefix" (returned the WHOLE of
  "000012.456"); now alias the LeadingCharsXT run family, per the
  archive's own gloss ("TrailingSubString() # Or TrailingCharsXT()").
  ZZ twins return the zipped `[run, [start, end]]`
  (`"12.4560000"` -> `["0000", [7, 10]]`); Remove*SubString =
  Remove*Chars.
- **A run needs >= 2 chars** (668): `.....mmMm` has NO case-sensitive
  trailing run (lone "m") -> Has FALSE / TrailingChar "". Rule wired
  into Leading/TrailingCharsAsString cores so the whole family
  (counts, lists, XT, removals) agrees.
- **`Has/Leading/TrailingChar-CS` dials are real now** (668): were
  stubs ignoring the flag; case-insensitive walk (StzLower per char
  over Chars()) finds "mmMm" as a run -> CS(FALSE) TRUE / "m".
- **`SplitsZ` / `SplitsZZ` zip the parts** (662): Z = `[part, start]`,
  ZZ = `[part, [start, end]]` per the settled Z-shape convention (were
  positions-only / sections-only). Interior empty parts kept, edge
  empties dropped (mirrors Splits). Also caught an `_EngineSlice`
  arity trap: 3rd arg is COUNT, not end.
- **`ThisTrailingCharRemoved` / `ThisLeadingCharRemoved`** (671): the
  functional twins of RemoveThis*Char existed only as mutators; added.
- **664 DEFERRED**: TitlecasedInLocale/CapitalisedInLocale need real
  locale rules (fr-FR lowercases particles); impl caps every word.
  Goes with 650 to the stzLocale pass. The file's mojibake literals
  ("A-tilde " for a-grave) repaired to proper UTF-8.
Pure conversions: 661, 663, 665, 666, 669, 670, 676-680 (667 was
already narrated in the W-migration).

## STATUS (2026-07-03): 626/999 test files audited (chunks 14-39 added 363); ~373 still to audit

NOT complete. `base/test/string` has 999 files; **263 are audited + converted to
narrated assertions + green** (the backlog below is from those). **~736 remain
un-audited** (718 numbered print-form pr()/pf() + 18 `from_*` cross-module
extracts) and must be processed the same way: read the current test, recover its
original block from the monolith (`git show f6bdfbcc^:.../legacy/stzStringTest.ring`),
read the original impl (`archive/stzString_monolithic.ring`), take the ORIGINAL as
reference, run, fix or log, convert to narrated. Do it in CHUNKS. Full self-contained
handoff: `_STRING_MODULE_HANDOFF.md` (this dir).

Within the audited set, the tests left print-form / NOTE are NOT stzString defects:
- **Ring-language limits:** `$()`/`Interpolate` (111 — no caller-scope reflection),
  `Repeated<N>Times` (112 — no method-missing).
- **Upstream `#TODO`:** `Dotless` Latin/Arabic (114, 115).
- **stzLIST-module (mis-filed under test/string):** `Slice`/named `Section`
  (98), `stzList.SplitAt` R41 (201).
- **Visual rendering (not assertable):** box-drawing glyph style — ASCII vs
  Unicode (99, 100, 101); ASCII is the Windows-console-safe choice per CLAUDE.md.
- **Inconsistent archive `#-->`:** `SimplifyExcept` (156 — its overlapping quote
  sections keep the middle even in the original); `Duplicates` (160 — the
  archive values were copied from a different string, "RINGORIALAND").

## ✅ RESOLVED — SYSTEMIC: StzFindFirst args-backwards sweep (2026-06-29)

`StzFindFirst(haystack, needle)` is HAYSTACK-FIRST, but the StzFind->StzFindFirst
bulk rename left ~18 callsites in stzString.ring written needle-first
(`StzFindFirst(needle, content)`), silently searching the wrong way -> the feature
returned 0/FALSE. Found by grepping `StzFindFirst(` and checking the first arg.
SWAPPED all of them; this repaired ~12 methods that were quietly broken (uncaught
because most string tests are print-form, not asserted):
- **ReplaceFirst / ReplaceLast were COMPLETE NO-OPS** (the biggest casualties).
- IsAFunction, IsAlmostAFunctionCall, IsListInShortForm,
  IsContiguousListInShortForm / ...InString, ToListInShortForm, NumberForm,
  Vowels, IsQuietEqualTo, SubStringIsBoundedBy.
The other string files (Char/Encoder/Func/Randomizer/Text/Visualizer) and the
common/stzFuncs callers were checked and are CORRECT (item-in-list = list-first,
or genuinely haystack-first). Earlier the same bug hit ContainsInSection and the
narrative-sub helpers (committed f47aa782 / 781cc944). See memory
reference_stzfind_contract for the contract + the sweep recipe.

## Open — code bugs (need a fix in the implementation)

- **`ReplaceInSections(old, new, sections)` is broken** (test 04_findzz).
  `Q("Programming for programmers").ReplaceInSections("m","M",[[1,11],[17,27]])`
  should give `"PrograMMing for prograMMers"` but returns **`" for "`** — both
  sections are destroyed, only the gap survives. The narrative-order arg-swap is
  correct; the bug is in the per-section replace loop (stzString.ring ~8492).
  `ReplaceInSection` (singular, test 03) works fine, so compare the two.

- **`StartsWithXTQ(...).AndQ().EndsWithXT(...)` chaining returns FALSE** when
  both sides are TRUE (test 08_write_a, last line).
  `Q("...Tunis..").StartsWithXTQ(@3(".")).AndQ().EndsWithXT(@2("."))` -> actual
  FALSE, expected TRUE ("...Tunis.." starts with "..." AND ends with ".."). The
  individual StartsWithXT/EndsWithXT each return TRUE; the AndQ() fluent-and
  bridge is the broken link. 08 left as print form (it's a `#todo` stub anyway).

- **✅ RESOLVED `CharRemovedFromLeft(c)` / `CharRemovedFromRight(c)`** (tests 24,
  25). Rewrote both to remove the leftmost/rightmost char ONLY if it equals `c`
  (no-op otherwise), codepoint-safe. `CharRemovedFromLeft("*")` on "---ring" ->
  "---ring"; `("-")` -> "--ring". Tests asserted (24/25: 6 each).

- **✅ RESOLVED `LeadingChars()` / `TrailingChars()` LIST form** (tests 33, 150).
  Split each: `LeadingCharsAsString()` holds the string run "---";
  `LeadingChars()` returns the char LIST `["-","-","-"]`; the `XT`/`AsSubString`
  aliases point at the AsString form; `LeadingChar`/`NumberOfLeadingChars` and the
  `HowMany*` callers were repointed at the string form. Same for the plural
  First2Chars/First3Chars/Last2Chars/Last3Chars (list) vs their `AsString` twins,
  via a new `_CharListOf` splitter. Also fixed `Next3Chars(:StartingAt=n)` to take
  the run AFTER position n (-> "CDE"). Tests asserted (33: 5, 150: 5).

- **✅ RESOLVED `SectionXT` eXTended behaviours** (tests 46, 49). Added two
  guard branches ahead of the negative-index resolution: (a) `:UpToNChars` named
  form -- `n2 = ["uptonchars", count]` -> `Section(n1, n1+count-1)`; and (b)
  REVERSAL when n1 > n2 -- take `Section(n2, n1)` and `Reversed()` it. Both
  tests upgraded from un-asserted NOTEs to assertions (46: 6/6, 49: 4/4).

- **✅ RESOLVED `ReplaceByMany(sub, [r1,r2,r3])`** (test 48) — see the Replace-by-many
  family section below (operator-precedence flatten bug, fixed by parenthesising).

- **✅ RESOLVED `ToList()` range-string expansion** (test 51). Added
  `_TryExpandRangeString`: a single-char endpoint range (`"A":"E"`) expands by
  codepoint; a common-prefix + numeric-suffix range (`"#1":"#5"`) expands the
  numeric part keeping the prefix. Bracketed-literal path unchanged. Asserted
  (51: 3/3). (Note: Ring's native `:` can't range multi-char strings -- it returns
  the left operand -- so the prefix path is custom, not eval.)

### ✅ RESOLVED — Replace-by-many family (tests 48, 56, 58, 59, 74, 80) — commit d5cf08b8+

ROOT CAUSE: the replacement-list flatten in `ReplaceByMany` wrote
`_aFlat_ + "" + _v_`, which Ring parses as `(_aFlat_ + "") + _v_` — appending an
EMPTY element THEN the value (the operator-precedence trap, CLAUDE.md note 5). So
`["X","XX","XXX"]` flattened to `["","X","","XX","","XXX"]` (6 items), and the
cycling index landed on the empty slots for the 1st and 3rd occurrences. Fixed by
parenthesising `("" + _v_)`. This one fix repaired ReplaceByMany / ReplaceByManyXT
/ ReplaceWithMany (and their :By forms) across 48/56/58/59/80. Separately,
`Replace()` gained polymorphic dispatch (below), so `Replace(sub, :By/:ByMany =
list)` and `Replace([olds], :By = new/[news])` now route correctly (56/74).

Original report (for history):
The "replace ONE substring's successive occurrences with a LIST of replacements"
feature is broken across its whole surface, while the sibling many-substring and
position/occurrence forms all WORK (verified: `ReplaceMany` block 57,
`ReplaceManyByMany` block 60, `ReplaceSubstringAtPositions` block 61,
`ReplaceOccurrencesByMany` block 62).

- **`ReplaceByMany(sub, list)` / `ReplaceByMany(sub, :By = list)`** (blocks 48,
  56, 58): should map each occurrence of `sub` to `list[1], list[2], ...`
  (cycling), e.g. `"ring php ruby ring python ring"` -> `"X php ruby XX python
  XXX"`. Instead the loop (stzString.ring ~2293) drops the 1st and 3rd
  occurrences and keeps only the middle: `" php ruby X python "`. On
  `"1♥34♥♥"` with `["2","5","6"]` it returns `"1342"` (expected `"123456"`).
- **`Replace(sub, :By = list)` / `Replace(sub, :ByMany = list)`** (block 56): a
  no-op -- returns the string unchanged.
- **`ReplaceByManyXT(sub, :By = list)`** (block 59): same garbling --
  `"ring php ring ruby ring python ring"` -> `" php #1 ruby  python #2"` instead
  of `"#1 php #2 ruby #1 python #2"`.
- **`ReplaceWithMany(sub, list)`** (block 80): same bug as ReplaceByMany --
  `"--Ring--Softanza--"` with `["1","2","3"]` -> `"Ring1Softanza"` (1st & 3rd
  dropped) instead of `"1Ring2Softanza3"`. The many-to-many `ReplaceManyWithMany`
  (block 81) works.

- **✅ RESOLVED `IsRealInString()` / `IsARealInString()` / `RepresentsRealInString()`**
  (test 60) — commit 754f9a38+. Added the three as aliases of RepresentsRealNumber()
  on stzString. The global `BothAreRealsInStrings` already existed (stzFuncs.ring).

- **✅ RESOLVED `Replace()` polymorphic dispatch** (test 74, also 56) — commit d5cf08b8+.
  `Replace(p1, p2)` was a plain 2-arg `ReplaceCS`. Added a :By / :With / :ByMany
  named-param dispatch: `Replace(sub, :By/:ByMany = list)` -> `ReplaceByMany`;
  `Replace([olds], :By = new)` -> `ReplaceMany`; `Replace([olds], :By = [news])`
  -> `ReplaceManyByMany`; string + string -> plain replace (the positional
  `Replace(str, str)` path is unchanged).

### ✅ RESOLVED — Position-anchored XT forms (tests 67, 68, 71, also 192) — commit 38b7b20b+

- `_RemoveOccurrenceAtPos` was byte-based (`len`/`StzMid`); rewritten with the
  codepoint engine helpers, so multibyte subs cut correctly: 67 -> "ring ruby php",
  68 (:AtPositions) -> "ring ruby php".
- `ReplaceXT(sub, :At / :AtPosition = n)` now routes to `ReplaceSubStringAtPosition`
  (absolute char position) instead of `ReplaceNth` (occurrence index): 71 ->
  "ruby ♥♥♥ php", and the `:At` form of block 192 -> "~~/♥\~~". The plural
  `:AtPositions` already used absolute positions.

### ✅ RESOLVED — Except family (tests 76, 77, 78, 79, 82) — commit 471300a3+

All four methods rewritten around a single codepoint-walk (using `_DbMatchAt` +
`Chars()`), so they handle one OR many tokens and are multibyte-correct:
- `FindExceptZZ(sep | [seps])` -> the gap spans (single-clause widening via
  if/but/else); `Except(...)` -> those substrings as a list.
- `RemoveAllExcept(keep | [keeps])` -> keeps only those tokens.
- `ReplaceAllExcept(keeps, :With=c)` -> ONE `c` per excluded RUN, and the keep-list
  now flattens inline `:And = value` (so `[ "Ring", :And = "Softanza" ]` keeps both).
Verified: 77 -> [[3,6],[9,9],[12,19]] / ["ring","&","softanza"]; 78 -> "Ring&Softanza";
79/82 -> "♥Ring♥Softanza♥". (79's garbled archive #--> was the author's error.)

### W / WXT conditional — deferred to string step 2 (tests 83, 84)

The W mechanism works for simple conditions (`FindW(' len(@item) > 3 ')` ->
`[1,3,5]`), but the rich `Q(@item).ContainsAnyOfThese( Q("vwto").Chars() )`
condition evaluates to `[]` under the current engine W-DSL -- it doesn't support
that method-call expression. So `FindWhere`/`ItemsWhere`/`FindW`/`ItemsW` all
return `[]` here (block 83). `FindWXT` is already RETIRED (R14, block 84) -- a
stzList WXT casualty; its replacement is the W form. Both belong to the pending
WXT-disqualification step for string (memory `project_wxt_disqualification`);
either expand the W-DSL vocabulary or migrate the examples to a supported
condition spelling.

- **`SectionBoundsIB` / `IBZ` / `IBZZ` are off by one** (test 97). Given the
  inclusive-bound positions (9, 14) they harvest one char too early
  (`[ " <", ">> " ]`) instead of matching the plain `SectionBounds(10,13,2,3)`
  result (`[ "<<", ">>>" ]`). The non-IB forms (`SectionBounds` / `Z` / `ZZ`) are
  correct.

- **`Section(:FromPosition = a, :To = :LastItem)` raises; `Slice()` is missing**
  (test 98). The named-param / `:LastItem` symbol form of Section raises
  "Incorrect params! n1 and n2 must be numbers", and `Slice` is undefined (R14).
  The plain positional `Section(a, b)` works.

- **✅ RESOLVED Contains-in-section family** (tests 103, 104) — commit c5a59dee+.
  `ContainsInSection` had its StzFindFirst args BACKWARDS (it searched for the
  section inside the sub). Swapped to `StzFindFirst(Section, sub)`. The XT
  `:InSection` / `:InSections` spellings now dispatch to it (see below).

- **✅ RESOLVED `stzChar.StzType()` returns "stzstring"** (test 106). `stzChar`
  was an empty subclass of `stzStringChar`, so it inherited stzString's
  `StzType()` -> `:stzString`. Gave `stzChar` its own one-line body
  `def StzType() return :stzChar`. (`classname(This)` was tried first but
  collides R20 with a case-insensitive builtin in class scope.) Test upgraded
  from un-asserted NOTE to assertion (106: 3/3).

- **✅ RESOLVED Hex-unicode reverse direction** (test 109). `stzStringChar.init`
  funnelled both plain-hex ("06A2") and unicode-hex ("U+06A2") through ONE branch
  that fed the whole literal to `StzHexNumber.ToDecimal()` -- the "U+" prefix
  broke parsing -> 0. Split into two branches: the unicode-hex one drops the
  2-char "U+" via `Section(3, len)` first. Also coerced `ToDecimal()` (returns a
  STRING) to a number with `0 + ...`, else `StzEngineCharToUtf8` mis-encoded it
  to 1 garbage byte. Test upgraded to assertions (109: 5/5).

- **✅ RESOLVED stzString `HexUnicode` / `HexUnicodes` "U+" prefix** (test 110).
  Both now prepend "U+" (`"U+" + _cHex_`, parenthesised in HexUnicodes to dodge
  the append-precedence trap), consistent with stzChar.HexUnicode(). Test
  upgraded to assertions (110: 8/8).

- **`$(...)` / `Interpolate()` does not substitute placeholders** (tests 111, 54).
  `$("...{cName}!")` returns the template verbatim ("...{cName}!") instead of
  filling `cName` from scope.

- **`Repeated<N>Times()` returns ""** (test 112). The dynamic-name form
  `Repeated3Times()` yields "" instead of "♥♥♥"; `RepeatedNTimes(3)`, `NCopies`,
  and `3Copies(:of=...)` all work.

- **`Dotless()` is broken** (tests 114, 115; source has a #TODO). For Latin it
  replaces "i" with the DIGIT "1" and leaves diacritics (`"alitalia extrême..."`
  -> `"al1tal1a extrême..."`) instead of dotless-i + diacritic removal; for Arabic
  it is a NO-OP (returns the input unchanged).

### ✅ RESOLVED — Shorten / Shortened family (tests 116, 117, 118, 119) — commit 7326f46e+

The family was a left-truncation (`first n-3 chars + "..."`) instead of the
middle-shorten the names imply. Reworked around one ShortenedXT(nLeft, nRight,
ellipsis) core that keeps nLeft from the start + nRight from the end (a 0 left
mirrors the right). ShortenedN(n) -> ShortenedXT(n,n,"..."); Shortened()/Shorten()
-> n=3; ShortenedUsing(e) -> ShortenedXT(3,3,e); ShortenedNUsing(n,e) ->
ShortenedXT(n,n,e). Shorten/ShortenN mutate, the rest return. Verified:
ShortenedN(2)->"12...21", Shortened()->"123...321", ShortenedNUsing(5," {...} ")->
"12345 {...} 54321", etc.

### ✅ RESOLVED — Extend family (tests 139, 142, 143) — commit 31da57d2+

- ExtendToWithCharsIn: the source-pool build only joined a 2-element list, but a
  range like "1":"3" expands to a 3-element list, so it no-op'd. Now joins any
  list (forced if/but/else) -> "123" extend-to-8 = "12312312".
- ExtendXT(:ToPosition=n, :With=:CharsRepeated) and the bare :ByCharsRepeated /
  :CharsRepeated now route to ExtendToWithCharsRepeated(n) (repeat THIS string's
  own chars) instead of appending the literal symbol / padding spaces -> "ABCAB".

### Find-in-section / bounded named-param forms (tests 151, 154, 155)

- **✅ RESOLVED `FindCS(sub, :CaseInSensitive)`** (test 151) -- added
  "caseinsensitive"/"iscaseinsensitive"/"ci" to the FALSE branch of FindCS's
  symbol normaliser, so `FindCS("a", :CaseInSensitive)` -> [1,2,3]. Asserted.
- **✅ RESOLVED `FindInSection` auto-order** (test 154) -- swaps n1/n2 when n1>n2
  (like Section), so `FindInSection("♥",12,3)` == `FindInSection("♥",3,12)`.
  Asserted. (155/179/180/182 `:Between` forms also done -- see the Replace-bounded
  resolved section.)
- **`FindBoundedByAsSections([sub, bound])` returns garbled reversed spans**
  (test 155): [ [8,7], [16,15] ] instead of [ [5,7], [13,15] ]. And the
  `FindXT(sub, :Between=[a,b])` / `FindAsSectionsXT(sub, :Between=[a,b])`
  named-param forms return [] (not parsed). The `:BoundedBy` named-param forms
  and `FindBetweenAsSections` work. CONFIRMED broadly: `FindXT(sub, :Between=[a,b])`
  and `FindAsSectionsXT(sub, :Between=[a,b])` (incl. the `:And` spelling) return []
  across blocks 155, 179, 180, 181, 182 -- while the plain `FindBetween` /
  `FindBetweenAsSections` forms all work.

### First/Last/Next-Chars return strings, not lists (test 150)

`First2Chars()` / `Last3Chars()` / `Next3Chars()` return a STRING ("ab", "CDE")
instead of a LIST -- same family as `LeadingChars` (block 33; the plural
`...Chars()` accessor must return a list, the string form is `...AsString()`).
Also `Next3Chars(:StartingAt=2)` starts AT position 2 ("bCD") whereas the archive
expected the following run ("CDE") -- confirm the :StartingAt offset.

- **`SimplifyExcept(sections)` only simplifies the first gap** (test 156).
  Should collapse space-runs everywhere except inside the given quoted sections,
  but leaves later gaps ("txt2  =  ") double-spaced and keeps a trailing space.
  Probably downstream of the single-bound `FindAnyBoundedByAsSections('"')`
  (block 124).

- **✅ RESOLVED `BoundedByZZ`/`UZ`/`UZZ` substring grouping** (tests 163, 166,
  167). Root mislabel: "U" was treated as case-Insensitive (the old impls called
  `FindBoundedByAsSectionsCS(..,0)`) instead of **Unique**. Rewrote the family:
  `BoundedByZZ` -> `[ [substr,[s,e]], ... ]` (wrap each codepoint-correct section
  with its `_DeepSlice` substring); `BoundedByUZ` -> unique `[ [substr,[starts]] ]`;
  `BoundedByUZZ` -> unique `[ [substr,[[s,e],..]] ]`. No internal callers relied
  on the old span-only return. Tests upgraded to assertions (163/166: 2/2, 167: 2/2).

- **✅ RESOLVED `Duplicates()` = duplicated SUBSTRINGS** (tests 129, 159; 157/160
  unaffected). The original `DuplicatesCS` scans ALL substrings `Section(i,j)` and
  keeps those occurring > 1 time (deduped, in (i,j) order) -- NOT just chars. The
  modular returned `DuplicatedChars()`. Reimplemented `DuplicatesCS` with the
  original algorithm and repointed `Duplicates()` + `NumberOfDuplicatesCS` at it.
  "RINGORIALAND" -> `["R","RI","I","N","A"]`; "ring php ringoria" -> 12 subs.
  157's "*4*34" has no repeated multi-char run, so chars == substrings there --
  it still passes. (Section is now strict but i,j are always in range here.)

### ✅ RESOLVED — ContainsXT named-position forms (tests 170, 173, 174, 175, 176, 178) — commit c5a59dee+

Wired the named-position keys into ContainsXT, each routing to the working
positional twin: `:AtPosition` -> ContainsAt(sub, :Position); `:AtPositions` ->
ContainsAt([pos], sub); `:After`/`:AfterPosition` -> ContainsAfter (number =
position, string = substring anchor); `:Before`/`:BeforePosition` ->
ContainsBefore; `:InSection`/`:InSections` -> ContainsInSection(s). All TRUE.
(ContainsInSection auto-orders via Section(); the args-swap fix is above.)

Note: `BoundedByZZ` / `BoundedByUZZ` lose the substring grouping too (blocks 166,
167) -- same defect as `BoundedByUZ` (block 163): they return position spans only
instead of `[ substring, span ]` pairs.

### ReplaceXT named-form coverage (tests 188, 190, 191, 192, 194)

The WORKING ReplaceXT forms: `:Nth=n` (189), `:AtPositions=[..]` (193),
`:In=scope` (195).
- **✅ RESOLVED `:Each` and empty-sub `:BoundedBy`** (188, 194). Added a `:Each`
  branch (also accepts `ReplaceXT(sub, :With=new, [])` with :With carried in p2)
  routing to ReplaceAll, and relaxed the Forms-C+ guard so an empty-list p1 is
  accepted for `:BoundedBy` (which replaces the bounded content regardless of p1).
  Gotcha hit en route: Ring's `NULL` is `""` and `isString("")` is TRUE, so the
  unset-sentinel guard fired spuriously -- switched to a boolean flag.
- **✅ RESOLVED `:First` / `:Last`** (190, 191). Root cause was NOT the dispatch
  (Form B was correct) but ReplaceFirst/ReplaceLast themselves: their slicing
  mixed BYTE units (`len`, `substr`, `StzMid`) with CODEPOINT find positions, so
  they corrupted/truncated multibyte content (and ReplaceLast even hit the FIRST
  match). Rewrote both with engine codepoint helpers (`_FindFrom`, `_EngineSlice`,
  `_EngineSliceFrom`, `_EngineCount`). This also fixes RemoveFirst/RemoveLast on
  multibyte. All four upgraded to assertions.
- **✅ RESOLVED `ReplaceXT(sub, :At=n)`** (192) -- routes to
  ReplaceSubStringAtPosition (char position), same fix as `:AtPosition` (block 71).

### ✅ RESOLVED — BoundedBy variants (tests 186, 187)

ROOT CAUSE of the IB garble was byte-vs-codepoint: `FindSubStringsBoundedByIBCSZZ`
scanned with byte-based `substr`/`len` and returned BYTE spans, then
`SubStringsBoundedByIBCS` sliced them with byte-based `StzMid` -- inconsistent on
multibyte (last element "<", second "" for hearts/stars). Tests 124/222 only
passed because they were ASCII. Rewrote the finder with `_FindFrom` (codepoint
positions) and the slicer with `_EngineSlice`; fixed the exclusive-span deriver's
`len()` -> `_EngineCount`. This corrected the whole IB / AsSections family on
multibyte. Then:
- **`BoundedByU` / `BoundedByIBU`** now dedupe (were pass-throughs).
- **`BoundedByIB`** returns the correct include-bounds substrings.
- **`BoundedByIBZZ`** now pairs each IB substring with its `[s,e]` span.
Tests upgraded to assertions (186: 4/4, 187: 2/2).

### ✅ RESOLVED — Anti-find / anti-section family (tests 200, 203, 204, 205, 208)

- **`AntiFindAsSection(s)`** aliased `FindAntiSections` (substrings) -> repointed
  to `FindAntiSectionsZZ` (the complement POSITION spans). Singular
  `AntiFindAsSection` was using bounded-by logic -> now returns the first
  complement span. e.g. `AntiFindAsSections("ring")` on "...ring..." ->
  `[[1,3],[8,10]]`; `AntiFindAsSection("ring")` on "ring..." -> `[5,7]`.
- **`AntiSectionsZ`** returned a single garbled span -> now the `[substr, start]`
  grouping list. (`AntiSectionsZZ` stays plain spans -- `AntiSections` depends on
  it returning spans.) Tests upgraded to assertions (200/205: 2, 203/208: 4,
  204: 5).

### Replace-bounded raises / mis-pairing (tests 198, 199)

- **✅ RESOLVED `ReplaceAnyBoundedBy`** (198) -- repointed to the ReplaceXT
  `:BoundedBy` path, which pairs ALTERNATING (a replace can't overlap), so the
  gap between regions is preserved: "/.../ and /---/" -> "/bla/ and /bla/".
- **✅ RESOLVED `ReplaceXT :BoundedBy` / `:BoundedByIB`** (199). `:BoundedBy`
  already worked (block 194 fix); added the `:BoundedByIB` anchor (replace the
  whole region including bounds, advancing past the inserted text). Single-string
  bounds widen to `[c,c]`. Both tests asserted.
- Also added `:Between` (with `:And` spelling) to `FindXT` / `FindAsSectionsXT`
  (tests 155, 179, 180) -> routes to `FindBetween` / spans. All asserted.

### stzList.SplitAt raises R41 (test 201)

`stzList.SplitAt("*")` raises "Error (R41): Invalid numeric string"
(stzList.ring ~5096) -- it treats the separator value as a numeric index.
`SplitAtZZ` likely shares the bug. (A list-domain defect surfaced via the string
suite.)

- **✅ RESOLVED `FindAnyBoundedBy` / `FindAnyBoundedByIB` wrong TYPE** (tests 17, 124,
  222, 266, 340, 343, 344, 550, 551, 565) — commit 61e3dc8b+. FindAnyBoundedBy now
  returns the content START positions (from FindAnyBoundedByZZ); FindAnyBoundedByIB
  the bound-inclusive starts (content_start - openLen). Added AnyBoundedBy
  (substrings) + AnyBoundedByZZ ([substring, span] pairs), both derived from
  FindAnyBoundedByZZ so a repeated single bound keeps EVERY overlapping region
  (BoundedBy's non-overlapping pairing still drops middles for same-char -- the
  separate 120/121/124-BoundedBy issue below). 565's FindSubStringBoundedBy("word")
  filter (returns [11,30,43] instead of [11]) is a DIFFERENT, still-open method.

- **`YieldWXT` is RETIRED (R14)** (tests 219, 220, 221) -- like FindWXT (block 84),
  the WXT family was removed; the replacement is `YieldW`. These belong to the
  pending string WXT-disqualification step (memory `project_wxt_disqualification`).

- **✅ RESOLVED `ExtractNumbers()` three-way fix** (test 231). Rewrote it to
  reuse `Numbers()` (decimal- and sign-aware, already returns STRINGS), then
  `RemoveFirst()` each extracted number so the content mutates
  ("Math: , Geo: , :Physics: "). Fixes all three: decimal kept whole, strings
  not numbers, and removal. Also repointed `UniqueNumbers()` at `Numbers()`
  (it called ExtractNumbers and would now mutate as a side-effect). Test
  converted from print-form to narrated assertions (231: 2/2).

- **✅ RESOLVED `Between` vs `BoundedBy` split** (tests 226, 123). Per the ORIGINAL
  monolithic (BetweenCS: `n1 = FindFirst(open)+len; n2 = FindLast(close)-1;
  Section(n1,n2)`), `Between` is the GREEDY single span from first-open to
  last-close (a STRING); `BoundedBy` is the LIST of enclosed regions. The modular
  code had conflated them (BoundedBy delegated to a list-returning BetweenCS).
  Decoupled: `BoundedByCS` now routes ALL bounds through `AnyBoundedBy` (the only
  caller of `This.BetweenCS`), freeing `BetweenCS` to be the greedy string.
  Test 123's `Between` #--> was corrected from the list to the greedy span.

- **`NumbersComingAfter(anchor)` -- trailing unanchored numbers?** (test 229).
  Returns only the numbers right after each anchor (`["+10","-125"]`); the archive
  also expected "11" (from "e11", which has no preceding "@i"). Confirm whether it
  should pick up trailing numbers with no anchor.

- **Half `Z`/`ZZ` forms lose the `[substring, position]` grouping** (test 241) --
  `FirstHalfZ()` returns `[1,4]` instead of `[ "1234", 1 ]`; `HalvesZZ()` returns
  `[ [1,4], [5,9] ]` instead of `[ [ "1234",[1,4] ], [ "56789",[5,9] ] ]`. Same
  Z/ZZ grouping family as BoundedByZ/UZ (blocks 163/166/187/214). The plain
  FirstHalf/SecondHalf/Halves(+XT) forms work (block 240).

### Environment note: UnicodeData() / UnicodeDataAsString() are empty

In this checkout both globals return "" (instead of the ~1.9M-char Unicode
database), so the perf/large-text blocks that depend on them can't reproduce
their archive values: 232, 233, 237, 239, 243 (the FindLast line), 244, 245.
Those blocks are narrated on small substitute data where possible, otherwise left
in print form. This is a data-availability issue, NOT a string-method bug; the
real large-text perf guard is the separate 07_managing_a_big_text step.

### Box-rendering cluster (tests 99, 100, 101, 102-box)

`Box` / `BoxRound` / `Boxed` / `BoxedRound` / `EachCharBoxed` /
`EachCharBoxRounded` render with ASCII `+ - |` instead of the Unicode
box-drawing glyphs the archive shows (`┌─┐└┘` / `╭─╮╰╯` / `┬┴`), and the round
variants are not visually distinct from the square ones. `BoxRoundChars` also
emits garbled ruler/marker rows (`"m   ,   ...   n"` / `"p   4   ...   o"`).
Likely the box-glyph mojibake issue (memory `feedback_source_mojibake`: rebuild
the glyph strings with `char()` raw bytes). The non-box content ops in block 102
(`UppercaseSubString`, `AddXT(:Around)`, hearts) work and ARE asserted there.

### SubStringComes* family (tests 91, 92)

The POSITIONAL-arg forms work (`SubStringComesBeforePosition`,
`...BeforeSubString`, `...AfterPosition`, `...AfterSubString`,
`...BetweenPositions`); the rest are broken.

- **✅ RESOLVED Named-param forms** (block 92) — commit f47aa782+. SubStringComesBefore
  / ...After now dispatch `:Position = n` -> ...Position and `:SubString = s` ->
  the substring form.
- **✅ RESOLVED Fluent forms** (block 92) — commit f47aa782+. The narrative-sub helpers
  `_SetNarrativeSub` / `_NarrativeSubAndHost` had StzFindFirst(char(1), c) args
  BACKWARDS (and a byte-based split), so the sub was never recovered -> every
  fluent `SubStringQ(sub).InQ(host).Comes...` form returned FALSE. Swapped the
  args and switched to codepoint slices; the `[sub, :In = host]` form works too.
- **✅ RESOLVED `SubStringComesBetween` order-independence** (test 91). The
  ORIGINAL is order-INDEPENDENT (its own example shows both orders -> TRUE).
  Extracted the adjacency check to `_ComesBetweenOrdered` and made
  `SubStringComesBetween` try BOTH orders (OR). Test asserted.

- Also resolved: `ContainsXT(:AtPosition / :AtPositions)` (tests 170, 178) already
  returned TRUE (block 170-resolved fix); NOTEs upgraded to assertions.

### Bounds family — a defect cluster (tests 42, 43, 44, 45)

- **✅ RESOLVED `BoundsOf` / `BoundsOfXT` per-occurrence bounds** (tests 42, 43).
  Rewrote `BoundsOf(sub)` to walk EACH occurrence and collect the maximal run of
  the same bound char (non-alnum, non-space, gated by new `_IsBoundChar`) before
  and after -> `[ ["<<<",">>>"], ["(((",")))"] ]`. `BoundsOfUpToNChars` /
  `BoundsOfXT` / `BoundsOfXT3` now iterate those per-occurrence pairs and cap each
  side (the old code took only the first pair). Tests upgraded to assertions
  (42: 3/3, 43: 2/2).
- **✅ RESOLVED `IsBoundedBy(c)` / `IsBoundedByXT` / `IsBoundOfXT`** (test 44) — commit 754f9a38+.
  IsBoundedByCS now widens a string bound `c` -> `[c, c]` via the forced if/but/else
  pattern (the single-clause type-widening if was no-op'ing -- CLAUDE.md note 6).
  IsBoundedByXT / IsBoundOfXT gained the `(bound, :In = host)` form (legacy
  :Open/:Close kept). All 5 cases in block 44 are now TRUE. (The single-bound
  gap-dropping in BoundedBy/FindAnyBoundedBy -- blocks 120/121/124/213/214/215 --
  is a SEPARATE, still-open issue in the core BoundedBy family below.)
- **✅ RESOLVED Single-repeated-bound family** (tests 120, 121, 213, 214, 215,
  216). DECISION: a same-char bound (string `c`, or `[c,c]`) uses OVERLAPPING
  consecutive pairing so no middle gap is dropped -- consistent with the already-
  asserted block 124. Implementation: added `_IsSameCharBound`/`_SameCharBoundPair`
  helpers; routed `BoundedByCS` same-char -> `AnyBoundedBy` (overlapping); gave
  `FindAnyBoundedByIBZZ` the same-char branch (derive overlapping IB spans from the
  content spans by expanding by the bound length); `BoundedByIB` same-char derives
  IB substrings from `BoundedByIBZZ`; and `BoundedByZ`/`BoundedByIBZ` now carry the
  `[substr, start]` grouping (derived from the ZZ forms) for ALL bounds. Single
  strings widen to `[c,c]` throughout, so nothing raises. Distinct `[open,close]`
  pairs unchanged (186/187 still green). Block 216's archive `#-->` showed the
  inconsistent 2-element reading; the test now asserts the 4-element overlapping
  value matching its siblings. Tests upgraded to assertions (120/121/216: 1-2
  each, 213/214: 2, 215: 4).
  AUTHORITY: confirmed against the ORIGINAL monolithic impl -- FindTheseBoundsCSZZ
  advances `nPos = n2` (the closer), REUSING each closer as the next opener, i.e.
  overlapping for BOTH repeated markers AND quote-style bounds. So
  SubStringsBoundedBy('"') (block 217) returns 3 consecutive gaps (incl. the
  between-quotes text), NOT 2 -- 217's #--> was updated to match the original.
- **✅ RESOLVED `Bounds()` greedy trailing run** (test 45). Changed the auto-
  detection from "any leading/trailing non-letter run" to "the maximal run of the
  same EDGE char (when it is a bound char)". For `"<<Go!>>"` the trailing run of
  `>` stops at `!` -> `["<<", ">>"]`, so `BoundsRemoved()` -> `"Go!"`. Verified
  the same-char rule keeps `"<<word>>"` (592) and `"<<<word>>>"` (366) correct.
  Test upgraded to assertions (45: 3/3).

## Open — semantics to confirm (test #--> vs current impl disagree)

- **`Duplicates()` -- characters or substrings?** (test 129). On "RINGORIALAND"
  it returns the duplicated CHARACTERS `[ "R", "I", "A", "N" ]`, but the archive
  expected a set including the duplicated multi-char substring "RI"
  (`[ "R", "RI", "I", "N", "A" ]`). Confirm the intended contract (dup chars vs
  dup substrings).

- **`Section(n1, n2)` does not raise on out-of-range bounds** (test
  70_section_out_of_range_raises). Block #46's narration documents `Section()` as
  the CONSERVATIVE form that should raise "Indexes out of range!" (leaving the
  lenient `SectionXT()` to handle overshoot), but `Q("SOFTANZA").Section(-99, 99)`
  silently returns the whole `"SOFTANZA"`. Decide: enforce the raise, or accept
  the clamp and correct block #46's narration.

- **`SizeInBytes64()` / `SizeInBytes32()`** (test 06_sizeinbytes). `"Softanza"` →
  `548 / 348`; archive `#-->` `624 / 400`. These look like object-footprint
  estimates (platform/version-dependent) -- fragile to assert. Low value; left as
  print form pending a decision on whether they should exist at all.
  (`SizeInBytes()` itself is RESOLVED below.)

- **`FindAnyBoundedBy(["<<",">>"])`** (test 17). Returns the SUBSTRINGS
  `["ring","php"]`; archive `#-->` expected POSITIONS `[7,20]`. Likely
  FindAnyBoundedBy = substrings and a ...ZZ variant = positions; confirm the
  intended contract, then fix the test or the method. (17's ReplaceManyByManyXT
  half is verified correct and narrated.)

## Resolved (impl correct, archive #--> was wrong)

- **`SpacifySections(ranges)`** (132): the archive `#-->` "Ring programming
  language is powerful!" was block #131's boundary-insert output copied by
  mistake. SpacifySections correctly spacifies the chars WITHIN each section
  ("programming" -> "p r o g r a m m i n g"), matching its name. Asserted at the
  impl behavior. (SpacifySubStrings, block 133, is the one that boundary-spaces.)
- **`SubStringsCS(FALSE)`** (127): archive lowercased the case-insensitive
  results; the impl keeps each substring's original (first-occurrence) case. Same
  count/set; asserted at the impl's source-case form.

- **`RemoveLeadingChar()` / `RemoveTrailingChar()` are SINGULAR** (test 34):
  remove exactly one end char (`"---Ring"`->`"--Ring"`). Archive `#--> Ring`
  reflected the PLURAL `RemoveLeadingChars()`. Impl documents the distinction
  (~4458). Asserted per impl; plural shown alongside for contrast.
- **`RemoveCharFromLeft(c)` strips the whole run** (test 27): equivalent to its
  XT twin (both delegate to RemoveThisCharFromStartXT). Archive expected a single
  removal for the non-XT form (`"00012.58"`->`"0012.58"`); the singular/plural
  split is collapsed. Coherent (respects `c`), unlike the block-24 bug below, so
  recorded as redundancy rather than a code defect. Asserted at strip-all.
- **Test 28 last two `#--> 3` were wrong**: counting the trailing run of a
  leading-dash string (and vice versa) is 0, not 3. Asserted at 0.

- **`CharTrimmedFromLeft("-")` / `CharTrimmedFromRight("-")`** (tests 24/25):
  archive `#-->` showed a SINGLE removal (`"--ring"` / `"ring--"`), but these are
  aliases of the XT (remove-the-whole-run) form, so `"---ring"`->`"ring"` is
  correct. "Trim" = remove all leading/trailing occurrences; archive author erred.
  Asserted at the correct value in the narrated 24/25.

- **`SizeInBytes()`** (06): impl returns content byte length (`"Softanza"`->8);
  archive `#-->624` was stale. CONFIRMED by 07_managing_a_big_text where
  `SizeInBytes()=6617121` matches the char/byte count. Test 06 not yet rewritten
  (still bundled with the 64/32 question above).
- **`AlignXT(width, char, :Right)`** (10): archive `#-->` showed the CENTERED
  result by copy-paste; impl is correctly right-aligned (`"~~~~~~~~~~~RING"`).
  Fixed in the narrated 10_aligncenter.

## Resolved

- **`12_containseither`**: archive + modular both said `#--> FALSE` for a string
  containing BOTH words; the impl is an INCLUSIVE or (TRUE) and the separate
  `ContainsOnlyOneOfThese` is the exclusive form. Original test author was wrong
  → corrected the assertion to TRUE (commit 2ef2f86a).
