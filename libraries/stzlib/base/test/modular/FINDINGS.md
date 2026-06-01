# Modular Narrative-Test Findings

Each subdirectory is one thematic suite, automatically extracted from
the original `base/test/*Test.ring` narrative files. Each `.ring` file
inside is one self-contained scenario with its narrative + expected
output preserved verbatim.

The runner `_run_modular_batch.py` walks a directory and reports
PASS / FAIL / TIMEOUT / skip per block by doing **ordered-substring
containment** of every `#-->` expected fragment against the runtime
output. This is intentionally tolerant of whitespace and intermediate
prints.

## Per-module status

| Module       | Blocks | PASS | FAIL | TIMEOUT | skip |
|--------------|-------:|-----:|-----:|--------:|-----:|
| duration     |     17 |    9 |    6 |       0 |    2 |
| date         |     31 |   18 |   10 |       0 |    3 |
| calendar     |     47 |   21 |   14 |       0 |   12 |
| number       |     71 |   24 |   31 |       2 |   14 |
| dataset      |     52 |    5 |   24 |       0 |   23 |
| list2d       |      4 |    2 |    0 |       0 |    2 |
| regex        |     50 |   18 |   25 |       0 |    7 |
| tree         |     10 |    7 |    3 |       0 |    0 |
| grid         |     22 |   12 |    5 |       0 |    5 |
| html         |      9 |    0 |    3 |       0 |    6 |
| global       |     50 |    7 |   19 |       3 |   21 |
| object       |     32 |    7 |   15 |       0 |   10 |
| plot         |     73 |    4 |    3 |       0 |   66 |
| pivottable   |      4 |    0 |    2 |       0 |    2 |
| sortedlist   |      1 |    0 |    1 |       0 |    0 |
| listofentities |    4 |    0 |    0 |       0 |    4 |
| listparser   |      3 |    0 |    1 |       0 |    2 |
| tile         |     21 |   10 |    7 |       0 |    4 |
| hexnumbert   |     13 |    4 |    7 |       0 |    2 |
| pythoncode   |     10 |    0 |    1 |       0 |    9 |
| appserver    |      2 |    0 |    0 |       0 |    2 |
| extinpython  |     12 |    2 |    6 |       0 |    4 |
| **totals**   |  **538** | **150** | **183** | **5** | **200** |

PASS rate excluding skips/timeouts: 150 / 338 = **44%**.

### Wave 3 -- 57 more small modules

Coverage expanded to **78 modules / 1181 thematic blocks**:

  Total: 285 PASS / 391 FAIL / 5 TIMEOUT / 500 skip
  PASS rate excluding skips/timeouts: **42 %**

The full per-module table is regenerated into `_SUMMARY.txt` (sorted
by FAIL count desc so reconciliation candidates surface first).

Top reconciliation candidates by FAIL count (>= 10):
- list-ish, json, hashlist, knowledgegraph
- ccode, regex, dataset, number
- graphex, coeffextractor, baturalcode
- object, global, tile, hexnumbert

Modules with 0 PASS but many FAILs in this wave (likely systemic
drift / API rename rather than per-test bugs):
- ccode (1 PASS / 14 FAIL)
- knowledgegraph (1 PASS / 14 FAIL)
- chainoftruth (0 PASS / 1 FAIL / 24 skip)
- chainofvalue (0 PASS / 2 FAIL / 12 skip)

Deferred (too large to run in this batch — extract done):
- list (645 blocks), table (229), char (120), graph (90),
  locale (88), listoflists (70), diagram (58), timeline (53)

### Wave 4 -- 6 medium-large modules

Ran timeline, diagram, listoflists, locale, graph, char in parallel:

| module      | blocks | PASS | FAIL | TIMEOUT | skip |
|-------------|-------:|-----:|-----:|--------:|-----:|
| timeline    |     53 |   12 |   23 |       0 |   18 |
| diagram     |     58 |   15 |   11 |       0 |   32 |
| listoflists |     70 |   20 |   45 |       0 |    5 |
| locale      |     88 |   16 |   19 |       0 |   53 |
| graph       |     90 |   27 |   37 |       0 |   26 |
| char        |    120 |   17 |   33 |       1 |   69 |

Wave 4 totals: 107 PASS / 168 FAIL / 1 TIMEOUT / 203 skip (479 blocks)

### Cumulative across 84 modules

  **1660 blocks    392 PASS    559 FAIL    6 TIMEOUT    703 skip**
  PASS rate excluding skips/timeouts: **41 %**

stzString modularised (981 blocks) but not yet run (would take
multiple hours); deferred for a dedicated session.

## Systemic gap signal

Spot-check on the ccode module revealed `NumbersAfter()` /
`BoundedBy()` / `RemoveSpacesQ` / `TrimQ` etc. are called but exist
only in the legacy monolithic archive (`string/archive/
stzString_monolithic.ring`); they were not carried into the modular
stzString. This is the same bug family as the 22 modularization
gaps we fixed in earlier waves.

`_detect_missing_methods.py` was added to systematically catalogue
the missing methods by re-running every block under Ring and
parsing `Calling Method without definition: X` errors. Catalogue
output will land alongside `_SUMMARY.txt` once the long-running
detection completes.

`global` shows 3 TIMEOUTs and high FAIL count — likely the same
algorithmic-stall pattern as the number module. Worth focused
review alongside `stzCounter.CountTo(1M)` perf regression (task #4).

`plot` is dominated by demo blocks (66 skips). The 3 FAILs are real
plot-rendering drift.

Per-module `_RUN.txt` files capture the raw runner output and serve as
the canonical regression baseline for follow-up reconciliation.

### duration (extracted from stzdurationtest.ring)

17 blocks generated, **9 PASS / 6 FAIL / 2 skip**.

Failures (all confirmed real findings, not parser artefacts):

| Block | Category | Detail |
|---|---|---|
| 03 retriving_duration_components | library drift | `Components()` returns list-of-pairs `[["days",2],["hours",5],...]`; doc expects hash syntax `[:Days=2, :Hours=5,...]` |
| 08 pr (ToStringXT showcase) | library drift | Several `ToHuman()` formatter outputs changed |
| 09 task_timer | flaky / non-deterministic | Tests measured real-time elapsed seconds; expected "14 seconds" cannot pass reliably |
| 11 project_time_estimation | library drift | `ToHuman()` returns "2 weeks" for 14-day duration; doc expects "14 days" |
| 16 adding_more_patterns_to_tohuman | library drift | Global `$aDurationPatterns` renamed or restructured |
| 17 customising_unit_names | library drift | Global `$aUnitNames` renamed or restructured |

Skips (06, 07) had narrative blocks with no `#-->` markers — they
were demos rather than assertions.

### date (extracted from stzdatetest.ring)

31 blocks, **18 PASS / 10 FAIL / 3 skip**.

Most failures involve `Today()`-derived assertions or `Now()`
formatting; these are partly non-deterministic and partly real
library drift. Worth a focused review of `stzDate.ToString*`
methods against the original expected formats.

### calendar (extracted from stzcalendartest.ring)

47 blocks, **21 PASS / 14 FAIL / 12 skip**.

Large skip count -- many blocks are pure rendering demos (no
#--> markers). Failures concentrate on locale-aware calendar
rendering; likely related to the recent i18n / locale-array
work and worth a directed review.

### number (extracted from stznumbertest.ring)

71 blocks, **24 PASS / 31 FAIL / 2 TIMEOUT / 14 skip**.

The two TIMEOUTs (60s each):
- 18 `RandomNumberGreaterThan(12)` -- naive random-sample loop
  until result exceeds 10^12 digits; needs an algorithmic rewrite
  or a budget cap
- 20 `pr()` block -- similar algorithmic stall

Sample real findings worth deeper investigation:
- 12 `o1 + 3500` arithmetic returning unexpected value
- 07 `PrimesUnder(19)` output drift
- 10 hash-by-numeric-key (`aHash[:1]`) behavior change

## Treatment policy

These narratives are years of user-curated regression intent and
must be preserved as-is. Drifts identified here are **leads** for
the library-vs-doc reconciliation pass that follows modularisation;
they are not automatically rewritten.
