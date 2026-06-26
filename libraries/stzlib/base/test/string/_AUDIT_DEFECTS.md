# String narration-audit — defects found (real code/test bugs)

Running log of genuine defects surfaced while narrating (= correctness-auditing)
`base/test/string`. Triangulated against the recovered archive
`stzStringTest.ring` (from git `f6bdfbcc^`, the pre-split monolith). Each entry:
what's wrong, evidence, and the fix decision (code vs test, per defect policy).

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

- **`CharRemovedFromLeft(c)` / `CharRemovedFromRight(c)` ignore their char
  argument** (tests 24_leftcharremoved, 25_rightcharremoved). Both are one-line
  delegators (`return This.LeftCharRemoved()` / `RightCharRemoved()`,
  stzString.ring ~8077-8081) that drop the leftmost/rightmost char
  UNCONDITIONALLY, regardless of `c`. So `Q("---ring").CharRemovedFromLeft("*")`
  returns `"--ring"` (a `-` removed) when it should be a no-op (`"---ring"`, `*`
  is absent). The sensible contract — matching the archive `#-->` and the XT
  twin — is *remove the leftmost char only if it equals `c`* (single, conditional;
  the XT form removes the whole run). The CharTrimmed* aliases (= XT, remove-all)
  are fine; only the non-XT single-removal form is wrong. Left un-asserted in the
  narrated tests (NOTE line); deferred to the fix-pass.

### Bounds family — a defect cluster (tests 42, 43, 44, 45)

- **`BoundsOf(sub)` returns a single flat `[before, after]` pair** instead of the
  per-occurrence immediate bounds (tests 42, 43).
  `Q("Hello <<<Ring>>>, the beautiful (((Ring)))!").BoundsOf("Ring")` returns
  `["Hello <<<", ">>>, the beautiful (((Ring)))!"]` (everything before/after the
  FIRST match) but should give `[["<<<",">>>"], ["(((",")))"]]`. The underlying
  `FindSubStringBoundsUpToNCharsAsSections("Ring",2)` is correct
  (`[[8,9],[14,15],[34,35],[40,41]]`), so the bug is in how BoundsOf assembles
  the result.
- **`BoundsOfXT(sub, n)` returns only the FIRST occurrence's bounds** (tests 42,
  43). Returns `["<<",">>"]` but should give `[["<<",">>"], ["((","))"]]` (one
  pair per occurrence, n chars each).
- **`IsBoundedBy(c)` / `IsBoundedByXT` / `IsBoundOfXT` reject a single-string
  bound** (test 44). `IsBoundedByCS(pacBounds, ...)` short-circuits to FALSE
  unless `pacBounds` is a 2-element list (stzString.ring ~13439), so
  `Q("_world_").IsBoundedBy("_")` returns FALSE though "_world_" is bounded by
  "_" on both sides. Fix: widen a string arg `c` to `[c, c]` (the type-widening
  pattern -- see CLAUDE.md note 6). The 2-element-list forms work.
- **`Bounds()` is greedy on the trailing non-letter run** (test 45). For
  `"<<Go!>>"` it returns `["<<", "!>>"]` (swallowing the "!"), so
  `BoundsRemoved()` gives `"Go"` instead of `"Go!"`. The explicit
  `TheseBoundsRemoved("<<", ">>")` -> `"Go!"` is correct; only the auto-detection
  over-reaches. (Decide whether bounds should be symmetric-bracket-aware or the
  full leading/trailing non-letter run.)

## Open — semantics to confirm (test #--> vs current impl disagree)

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

- **`LeadingChars()` / `TrailingChars()` return a STRING, not a list** (test 33).
  Archive `#--> [ "-", "-", "-" ]`; impl returns the run as one string `"---"`
  (deliberate -- doc-comment at stzString.ring ~4411, with `LeadingChar()` /
  `NumberOfLeadingChars()` as the companions). Asserted at the string.
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
