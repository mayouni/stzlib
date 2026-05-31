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
| **totals**   |  **313** | **116** | **121** | **2** | **74** |

PASS rate excluding skips/timeouts: 116 / 239 = **49%**.

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
