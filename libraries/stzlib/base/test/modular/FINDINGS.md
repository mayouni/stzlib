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

## Treatment policy

These narratives are years of user-curated regression intent and
must be preserved as-is. Drifts identified here are **leads** for
the library-vs-doc reconciliation pass that follows modularisation;
they are not automatically rewritten.
