# String narration-audit — defects found (real code/test bugs)

Running log of genuine defects surfaced while narrating (= correctness-auditing)
`base/test/string`. Triangulated against the recovered archive
`stzStringTest.ring` (from git `f6bdfbcc^`, the pre-split monolith). Each entry:
what's wrong, evidence, and the fix decision (code vs test, per defect policy).

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

## STATUS (2026-06-30): 203/999 test files audited; ~796 still to audit

NOT complete. `base/test/string` has 999 files; **203 are audited + converted to
narrated assertions + green** (the backlog below is from those). **~796 remain
un-audited** (print-form pr()/pf() + `from_*` cross-module extracts) and must be
processed the same way: read the current test, recover its original block from the
monolith (`git show f6bdfbcc^:.../legacy/stzStringTest.ring`), read the original
impl (`archive/stzString_monolithic.ring`), take the ORIGINAL as reference, run,
fix or log, convert to narrated. Do it in CHUNKS.

Within the 203 audited, the tests left print-form / NOTE are NOT stzString defects:
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
