# String narration-audit — defects found (real code/test bugs)

Running log of genuine defects surfaced while narrating (= correctness-auditing)
`base/test/string`. Triangulated against the recovered archive
`stzStringTest.ring` (from git `f6bdfbcc^`, the pre-split monolith). Each entry:
what's wrong, evidence, and the fix decision (code vs test, per defect policy).

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

- **✅ RESOLVED `ReplaceByMany(sub, [r1,r2,r3])`** (test 48) — see the Replace-by-many
  family section below (operator-precedence flatten bug, fixed by parenthesising).

- **`ToList()` does not expand a range-string** (test 51). It parses a `"[...]"`
  list literal (via `eval`, stzString.ring ~5593) and otherwise falls back to
  `Chars()` (raw char split). The archive expected `' "A" : "E" '` ->
  `[ "A".."E" ]` and `' "#1" : "#5" '` -> `[ "#1".."#5" ]`; neither is
  implemented (both char-split). Likely an unimplemented feature rather than a
  regression -- confirm the intended contract. (Also note ToList still uses
  `eval` for the list-literal path.)

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

- **`stzChar.StzType()` returns "stzstring"** (test 106). `ToListOfStzChars()`
  yields genuine stzChar objects (`classname` = "stzchar", correct content), but
  their `StzType()` misreports as "stzstring".

- **Hex-unicode reverse direction is broken** (test 109). `HexUnicodeToUnicode(
  "U+06A2")` returns 0 (should be 1698), and consequently `QQ("U+0649").Content()`
  yields a bad char. The forward direction (`UnicodeToHexUnicode`, `IsHexUnicode`,
  stzChar `HexUnicode`) works.

- **stzString `HexUnicode` / `HexUnicodes` drop the "U+" prefix and over-nest**
  (test 110). `Q("a").HexUnicode()` returns "0061" (stzChar's returns "U+0061",
  block 109 -- inconsistent), and `HexUnicodes([ "a","bcd","e" ])` wraps each
  single-char item in a list (`[ ["0061"], [...], ["0065"] ]`) instead of
  `[ "U+0061", [...], "U+0065" ]`.

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

- **`FindCS(sub, :CaseInSensitive)` symbol not parsed** (test 151) -- returns the
  case-SENSITIVE result ([1,2] on "aaA..." instead of [1,2,3]). The
  `:CaseSensitive` symbol works.
- **`FindInSection(sub, from, to)` does not auto-order its bounds** (test 154) --
  `FindInSection("♥", 12, 3)` returns [] instead of the same [6,9] as the forward
  call (Section() itself auto-orders, block 152).
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

- **`BoundedByUZ` / `BoundedByUZZ` lose the substring grouping** (test 163).
  Should return unique bounded substrings grouped with their positions
  (`[ [ "teeba", [5,27] ], [ "rined", [16] ] ]`) but return a flat position list
  (`[ 5, 16, 27 ]`).

- **`Duplicates()` chars-vs-substrings (cont. from block 129)** (tests 159, 160).
  The impl consistently returns duplicated CHARACTERS (block 157's char result
  matched its archive); blocks 129/159/160 expected SUBSTRINGS. Block 160's
  NumberOfDuplicates/FindDuplicates/Duplicates/DuplicatesZ #--> were additionally
  copied from a different string ("RINGORIALAND") and don't match the input.
  Confirm the intended Duplicates() contract.

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
`:In=scope` (195). The broken ones:
- **`ReplaceXT(:Each=sub, [], :With=)` and `ReplaceXT([], :BoundedBy=[a,b],
  :With=)` RAISE** "ReplaceXT: unsupported argument shape" (stzString.ring ~2917)
  -- those argument shapes aren't handled (188, 194).
- **`ReplaceXT(:First, ...)` / `ReplaceXT(:Last, ...)` are no-ops** (190, 191) --
  the string comes back unchanged.
- **✅ RESOLVED `ReplaceXT(sub, :At=n)`** (192) -- now routes to
  ReplaceSubStringAtPosition (char position), same fix as `:AtPosition` (block 71);
  on "~♥/♥\~~" `:At=2` -> "~~/♥\~~". (188/190/191/194 of this section still open.)

### BoundedBy variants (tests 186, 187)

`BoundedBy([open,close])` works (186), but the variants are broken:
- **`BoundedByU` does not deduplicate** -- returns all 3, not the 2 unique (186).
- **`BoundedByIB` (Include Bounds) garbles/loses elements** -- the last comes back
  as "<" (186) and on block 187 the second comes back as "" (loses "<<★★>>").
- **`BoundedByIBU`** inherits both bugs (186).
- **`BoundedByIBZZ`** returns position spans only (and wrong ones), losing the
  `[substring, span]` grouping (187) -- same family as BoundedByUZ (block 163).

### Anti-find / anti-section family (tests 200, 203, 204, 205)

`AntiFind` / `AntiFindZZ` (block 202), `Sections` / `AntiSections` /
`FindAsSections` (block 204), `AntiPositions` all work. The "*AsSection(s)" and
"*Z/ZZ" anti-forms are broken:
- **`AntiFindAsSection(s)` returns the SUBSTRINGS, not the position sections**
  (203/204/205): e.g. `AntiFindAsSections("ring")` on "...ring..." gives
  `[ "...", "..." ]` instead of `[ [1,3], [8,10] ]`; the singular
  `AntiFindAsSection` returns `[]` (200).
- **`AntiSectionsZ` returns a garbled `[1,3]`** and **`AntiSectionsZZ` returns
  position spans only** (loses the `[substring, span]` grouping) (204).

### Replace-bounded raises / mis-pairing (tests 198, 199)

- **`ReplaceAnyBoundedBy([b,b], new)` mis-pairs a repeated bound** (198) -- pairs
  the slashes consecutively so the gap between regions is consumed
  ("/.../ and /---/" -> "/bla/bla/bla/"). The IB form `ReplaceAnyBoundedByIB`
  works.
- **`ReplaceXT([], :BoundedBy=b, :With=)` / `:BoundedByIB` RAISE** "unsupported
  argument shape" (199) -- same as the :Each/:BoundedBy ReplaceXT raises (block
  194). Use the non-XT `ReplaceAnyBoundedBy*` path.

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

- **`ExtractNumbers()` is broken three ways** (test 231). On "Math: 18, Geo: 16,
  :Physics: 17.80" it (a) splits "17.80" into 17 and 80 (no decimal handling --
  though `Numbers()` handles decimals, blocks 228/230), (b) returns NUMBERS not
  strings (`[18,16,17,80]`), and (c) does NOT mutate (Content unchanged, but
  "Extract" should remove the numbers leaving "Math: , Geo: , :Physics: ").

- **`Between(open, close)` positional returns a list, not the greedy span**
  (test 226, #TODO). The archive expected the greedy span between the first open
  and last close ("ring>>>___<<<softanza"); the impl returns the same enclosed-
  substring list as `BoundedBy`. Confirm the intended Between vs BoundedBy split.

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
- **✅ RESOLVED `IsBoundedBy(c)` / `IsBoundedByXT` / `IsBoundOfXT`** (test 44) — commit 754f9a38+.
  IsBoundedByCS now widens a string bound `c` -> `[c, c]` via the forced if/but/else
  pattern (the single-clause type-widening if was no-op'ing -- CLAUDE.md note 6).
  IsBoundedByXT / IsBoundOfXT gained the `(bound, :In = host)` form (legacy
  :Open/:Close kept). All 5 cases in block 44 are now TRUE. (The single-bound
  gap-dropping in BoundedBy/FindAnyBoundedBy -- blocks 120/121/124/213/214/215 --
  is a SEPARATE, still-open issue in the core BoundedBy family below.)
- **Single-repeated-bound forms drop the middle region** (tests 120, 121, 124).
  With a single bound that repeats, the occurrences are paired non-overlappingly
  so the middle gap is lost: `BoundedBy("aa")` on `"aa***aa**aa***aa"` returns
  `[ "***", "***" ]` instead of `[ "***", "**", "***" ]`, and `FindAnyBoundedBy(
  "aa")` returns `[ "***", "***" ]` (also wrong TYPE -- substrings, not the
  positions `[3,8,12]`; see the FindAnyBoundedBy row above). The `...AsSections`
  variant finds all three correctly (block 124). Also `IsBoundedByCS("aa", TRUE)`
  is FALSE (the single-string-bound issue above). The distinct `[open,close]`
  pair forms (`Between`, `BoundedBy([..])`, `FindAnyBoundedByAsSections([..])`)
  all work. CONFIRMED broadly (blocks 213, 214, 215): with a single-string bound,
  `BoundedBy("&")` / `FindAnyBoundedBy("&")` drop the in-between gaps (and
  FindAnyBoundedBy returns substrings), while the IB / Z / ZZ / IBZZ variants
  RAISE "pacBounds must be [ open, close ] strings" -- the single bound `c` is
  never widened to `[c, c]`. Fix: widen a string bound to a pair AND use
  consecutive (overlapping) pairing so no gap is dropped.
- **`Bounds()` is greedy on the trailing non-letter run** (test 45). For
  `"<<Go!>>"` it returns `["<<", "!>>"]` (swallowing the "!"), so
  `BoundsRemoved()` gives `"Go"` instead of `"Go!"`. The explicit
  `TheseBoundsRemoved("<<", ">>")` -> `"Go!"` is correct; only the auto-detection
  over-reaches. (Decide whether bounds should be symmetric-bracket-aware or the
  full leading/trailing non-letter run.)

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
