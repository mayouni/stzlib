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

- **`LeadingChars()` / `TrailingChars()` must return a LIST of chars, not a
  string** (test 33). Per the design intent (author-confirmed), `LeadingChars()`
  on `"---Ring"` should return `[ "-", "-", "-" ]`; the STRING form is
  `LeadingCharsAsString()` (`"---"`). Currently `LeadingChars()` returns the
  string `"---"`, and the string aliases (`LeadingCharsXT`, `LeadingCharsAsString`,
  `LeadingCharsAsSubString`) all just delegate to it (stzString.ring ~4414-4457),
  so they happen to be right while `LeadingChars()` itself is wrong. Fix:
  `LeadingChars()`/`TrailingChars()` build the char LIST; the `AsString`/`XT`/
  `AsSubString` aliases join it back into a string. The archive `#-->` (list)
  was correct all along — supersedes the earlier (mistaken) "Resolved" note that
  treated the string return as authoritative. Asserted only the string-form
  aliases in test 33; LeadingChars/TrailingChars left as un-asserted NOTEs.

- **`SectionXT` is missing its eXTended behaviours** (tests 46, 49).
  `SectionXT(n1, n2)` (stzString.ring ~535) resolves negative indices then just
  delegates to `Section(n1, n2)`, so two documented features are absent:
  (a) REVERSAL when n1 > n2 -- `SectionXT(5,3)` gives `"345"` not `"543"`,
  `SectionXT(-2,-4)` gives `"678"` not `"876"`; and (b) the `:UpToNChars` named
  param -- `SectionXT(6, :UpToNChars = 11)` should take 11 chars from pos 6
  (`"Programming"`) but returns `""` (n2 arrives as the list `["uptonchars",11]`,
  which `Section` can't use). Negative indexing in the forward direction works.

- **`ReplaceByMany(sub, [r1,r2,r3])` produces garbled output** (test 48).
  On `"ring php ruby ring python ring"` with `["X","XX","XXX"]` it should give
  `"X php ruby XX python XXX"` (each occurrence -> the next replacement, cycling)
  but returns `" php ruby X python "` -- the 1st and 3rd occurrences are replaced
  by nothing and only the middle survives. Bug is in the find/append loop
  (stzString.ring ~2293). 48 left in print form.

- **`ToList()` does not expand a range-string** (test 51). It parses a `"[...]"`
  list literal (via `eval`, stzString.ring ~5593) and otherwise falls back to
  `Chars()` (raw char split). The archive expected `' "A" : "E" '` ->
  `[ "A".."E" ]` and `' "#1" : "#5" '` -> `[ "#1".."#5" ]`; neither is
  implemented (both char-split). Likely an unimplemented feature rather than a
  regression -- confirm the intended contract. (Also note ToList still uses
  `eval` for the list-literal path.)

### Replace-by-many family — a defect cluster (tests 48, 56, 58, 59)

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

- **`IsRealInString()` / `IsARealInString()` / `RepresentsRealInString()` and the
  global `BothAreRealsInStrings` are missing** (test 60_isrealinstring, R14).
  They exist in the archive monolith as trivial aliases of `RepresentsNumber()`
  (stzString_monolithic.ring ~94018) but were dropped in modularization; the
  modular file kept only `RepresentsRealNumber()`. Restore the aliases.

- **`Replace()` has no polymorphic dispatch** (test 74, also 56). `Replace(p1, p2)`
  is a plain 2-arg `ReplaceCS` (stzString.ring ~1909), so the documented
  shorthands are no-ops: `Replace([olds], :By = new)` (should route to
  `ReplaceMany`), `Replace(sub, :By = list)` / `Replace(sub, :ByMany = list)`
  (should route to `ReplaceByMany`). The explicit `ReplaceMany` works (block 57).

### Position-anchored XT forms (tests 67, 68, 71)

The plain `RemoveAt` / `ReplaceAt` forms all work (blocks 66, 69, 70, 73); their
`...XT(..., :AtPosition[s] = ...)` twins are broken.

- **`RemoveXT(sub, :AtPosition = n)` / `:AtPositions = [...]` are byte-based**
  (tests 67, 68). The helper `_RemoveOccurrenceAtPos` (stzString.ring ~2070) uses
  `len()`/`StzMid` instead of the engine codepoint helpers, so a multibyte sub
  ("♥♥♥" = 9 bytes / 3 codepoints) corrupts the cut: block 67 returns `"ring ru"`
  (expected `"ring ruby php"`), block 68 returns `""`.
- **`ReplaceXT(sub, :AtPosition = n)` treats n as an occurrence index, not a char
  position** (test 71). It routes to `ReplaceNth` (stzString.ring ~2790), so
  `ReplaceXT("ring", :AtPosition = 6)` is a no-op (no 6th "ring"). The plural
  `:AtPositions` form correctly uses absolute positions (block 72 works).

### Except family — a defect cluster (tests 76, 77, 78, 79, 82)

`FindExceptZZ(sep)` with a SINGLE separator works (block 76); the rest of the
"everything except" family is broken.

- **`Except(sep)` returns the wrong shape** (blocks 76, 77). It should return the
  non-separator SUBSTRINGS as a list (`[ "ring", "&", "softanza" ]`), but the
  impl (stzString.ring ~7656) just replaces `sep` with `""` and returns a STRING
  -- and in practice returns `""`.
- **`FindExceptZZ([sep1, sep2])` fails with a list** (block 77): returns the whole
  string as one span (`[ [1,21] ]`) instead of the per-gap sections.
- **`RemoveAllExcept(keep)` only handles a single keep-token** (block 78): it does
  `StzRepeatStr(keep, NumberOfOccurrence(keep))` (stzString.ring ~12926), so a
  LIST of keep-tokens yields `""` instead of `"Ring&Softanza"`.
- **`ReplaceAllExcept(keeps, :With=c)` granularity + `:And` form** (blocks 79, 82):
  replaces each excluded CHAR individually instead of each excluded RUN once
  (block 82's intent is one `c` per run); and the `[ "Ring", :And = "Softanza" ]`
  named-param form doesn't parse `:And`, so "Softanza" is replaced too. (Block
  79's archive `#-->` "Ring&♥Ring♥Softanza♥" is itself garbled.)

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

- **Contains-in-section family returns FALSE** (tests 103, 104).
  `ContainsInSection("♥", 3, 10)`, `ContainsInSections(...)`, and
  `ContainsXT("♥", :InSection = [3,10])` / `:InSections` all return FALSE on
  `"123♥♥678♥♥1234♥♥789"` although the sections clearly contain "♥". Both the
  plain and XT spellings are affected.

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

- **Named-param forms return FALSE** (block 92): `SubStringComesBefore(sub,
  :Position = n)` / `(sub, :SubString = s)` and the `...After` equivalents don't
  dispatch to their working positional twins (the same named-param parsing gap
  seen in Replace/Section/RemoveXT).
- **Fluent forms return FALSE** (block 92): `SubStringQ(sub).InQ(host).Comes-
  BeforeSubString(...)` and `SubStringQ([sub, :In=host]).ComesBeforeSubString(...)`.
- **`SubStringComesBetween[SubStrings]` is order-dependent** (blocks 91, 92):
  bound A must precede bound B, but the archive expected order-INDEPENDENT TRUE
  for both orders (e.g. `SubStringComesBetween("...", "**", "♥♥")` -> FALSE
  instead of TRUE). Semantics to confirm: order-independent or not?

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
