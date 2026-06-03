# Softanza thematic tests

The authoritative test surface for Softanza. Each topic (one Softanza
class or feature area) lives in its own subdir under this directory,
containing independently-runnable thematic blocks: each block is a
short narrative + a few `?` assertions, with the expected output
captured inline as `#-->` markers.

## Layout

```
libraries/stzlib/base/test/
├── README.md                     # this file
├── _STATUS.md / _FINDINGS.md     # running notes on drift & open work
├── _MISSING_METHODS.txt          # methods the modular suite is asking
│                                   for but the library doesn't yet ship
├── _SUMMARY.txt                  # historical extraction summary
│
├── _data/                        # input fixtures: bigtext.txt,
│                                   tabdata.csv, *.stzorg, images, etc.
├── _tmp/                         # scratch / artefacts written by tests
│                                   during runs (svg, dot, png, ...)
├── _smoke/                       # tiny pre-suite sanity checks
│                                   (test_load_base, test_integration_audit)
│
├── adverb/                       # one folder per topic
├── appserver/
├── ...
├── counter/
├── ...
├── string/                       # the larger topics aggregate many
│                                   blocks (counter has 6; string ~870)
└── ...                           # 129 topic dirs in total
```

Engine-bridge tests live separately at
`libraries/stzlib/engine/test/` (they exercise the Zig DLLs directly
and don't share the stzBase load convention).

## Running

A single topic:

```
cd libraries/stzlib/base/test/counter
D:\Ring126\bin\ring.exe 01_skip_after_9_restart_at_0.ring
```

A whole topic dir with PASS/FAIL/skip per block:

```
python _run_test_batch.py libraries/stzlib/base/test/counter
```

The output lands as `_RUN.txt` inside the topic dir. The runner

- parses each block's `#-->` markers
- runs the file
- strict-then-relaxed-then-format-tolerant matches each expected
  value against the produced output
- recognises a `# @clock 2025-09-27 14:30:25` pragma in the header
  and freezes Softanza's wall-clock for the run (so snapshot
  date/time tests stay stable)

The `pf()` profiler at the bottom of each block raises a "STOPPED!"
banner on purpose — that's the Softanza idiom for closing a profiled
run, not a failure. The runner trims that tail before matching.

## Adding a new test

1. Pick the topic dir (or create one if a wholly new feature).
2. Add a file `NN_short_slug.ring` where NN is the next free
   sequence number in that dir.
3. Header convention:

   ```
   # Narrative
   # --------
   # One-sentence description of what the block illustrates.
   #
   # Extracted from <source>.ring, block #<N>.   # if from legacy
   # (or just: New block for <feature>.)

   load "../../stzBase.ring"

   pr()

   ? <call>
   #--> <expected value>

   pf()
   ```

4. Keep markers single-line (`#--> value`). The runner anchors marker
   matching to a single line; multi-line expected blocks should be
   tolerated by the relaxed/format-tolerant fallback, but the cleanest
   markers stay on one line.

5. If the block is time- or date-dependent, add a
   `# @clock YYYY-MM-DD HH:MM:SS` header line so the runner freezes
   the wall clock before loading the file.

## Drift policy

When the library changes and a block's marker no longer matches the
current output, the convention is: **fix the marker if the new output
is the correct contract; fix the library if the old marker was right.**
Either way, record the decision under `_STATUS.md` so we don't
re-litigate the same drift in three months.

## Historical context

Before the modular refactor (mid-2026), every Softanza class had a
single monolithic `stz<X>Test.ring` file at this directory — hundreds
of narrative blocks chained inline under `/*---` delimiters that Ring's
own parser treats as comment-opens, so only the first block of any
monolith actually ran. The modular extractors pulled every block into
its own runnable file; the legacy monoliths were then archived (and
later deleted once the audit script confirmed every `#-->` marker
they contained was preserved somewhere in the modular suite).

Module-local regression baselines (the per-module `test_<feature>_
regression.ring` files that used to live at `base/<module>/test/`)
moved into this same tree as `base/test/<module>/test_<feature>_
regression.ring`. They share the topic dir with the thematic blocks
for that module so a contributor looking at `base/test/stats/` sees
both the narrative tests and the regression baselines side by side.
