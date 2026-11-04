# Testoor golden logbooks

*Phase P2b of `SOFTANZA_TESTOOR_ROADMAP.md`. The files in this folder are what the Zig core is built against: the same inputs must give the same bytes, in any language.*

## What is here

| folder | one case is | inputs | expected |
|---|---|---|---|
| `judge/<case>/` | **one tour**, judged | `record.json`, `output.txt`, `meta.json` | `expected.json`, `expected.txt` |
| `logbook/<case>/` | **one run**, built from judge cases | `run.json` | `expected.json`, `expected.txt`, `expected.exit` |

`record.json` is what a **face** read (`TESTOOR_PROTOCOL.md` section 1): the tour's stops, the claims at each, its routes. `output.txt` is what the child printed, one line per row, each row `<arrival in milliseconds><TAB><text>`. `meta.json` carries the child's exit code, whether it was killed, its error stream, the wall time, the seed it was handed, and **the face's ending rules as data**, so the core needs to know no language. `expected.json` is the tour exactly as the logbook writes it (`TestoorLogbookKeys()` lists the keys); `expected.txt` is the line a terminal shows.

The function under test is `TestoorVerdict(record, lines, stderr, exit, hung, face, wall_ms, seed)` in `stzTraveller.ring`. It is the first thing the Zig core implements (roadmap P3, step 1).

## The fourteen judge cases

| case | what it pins down |
|---|---|
| `01_kept_timed` | a narrated tour, kept, ended the way `pf()` ends |
| `02_diverged` | one diverged claim; non-ASCII text in a claim |
| `03_unjudged_branch` | a claim in a branch not taken is **unjudged** and is not a failure |
| `04_not_started` | nothing ran: a compile error read from the error stream |
| `05_broke_midway` | a runtime error with claims still owed: **unreached** |
| `06_hung` | killed at the deadline |
| `07_promise_spellings` | `TRUE` as `1`, a note in parentheses, quotes, `:Symbol`, `@@()` spacing, a bare list item by item, an empty line, a second `#` |
| `08_promise_lie_and_prose` | a lie, a short lie that must not hide in a later line, a prose promise, a kept list |
| `09_error_promise` | `#--> ERROR:` kept, and the raise it promised is not a break |
| `10_multiline_block` | a block as lines, wrapped but printed on one line, wrapped and wrong |
| `11_picture` | `PICTURE DOES NOT MATCH` is one diverged claim naming its row |
| `12_protocol_python` | a self-describing tour: seed, weather, stops, ok, fail, plan, routes, end |
| `13_unreadable` | a file the reader could not read |
| `14_exact_case` | a verdict marker is read in **any case** (`[pass]`, `[Ok]`); a promised value must match **exactly** (`Hello` is not `HELLO`) |

The five logbook cases cover an all-kept run (exit 0), a mixed run with skipped files and topics (exit 1), a run of tours that did not start, broke, hung or could not be read (exit 1), a kept tour found flaky (exit 1), and a run refused because its root is not there (exit 2).

## Conventions a port must know, because they are where two languages part

- **Arrival times** in `output.txt` are multiples of 250 ms, so a stop's time is exact in binary floating point. A port computes in integer milliseconds and takes the floor of the exact difference.
- **Wall times** in `meta.json` are whole hundredths of a second, so no printed time is a rounding tie (Ring prints `0.125` as `0.13`; other platforms print `0.12`).
- **Numbers in the prose:** an integer prints without decimals (`5`), any other number with exactly two (`1.50`, `0.88`). This is Ring's own rule and the goldens follow it.
- **Line endings:** every file is compared with carriage returns removed, and `.gitattributes` here marks the files `-text` so a checkout cannot change a byte.
- **Text is UTF-8.** `02_diverged` carries non-ASCII text on purpose.
- **Case.** String equality is exact, byte for byte (measured on Ring 1.27 and Ring++: `"Hello" = "HELLO"` is false). `lower()` folds ASCII letters only (`lower("ÀB")` equals `"Àb"`), so a port lowercases A to Z and nothing else. Verdict markers are the one place case does not matter.

## How it is used

- `base/test/testoor/testoor_golden_narrated.ring` regenerates every expected file from the inputs and compares byte for byte, then checks the verdicts against an **intent table written separately from the oracle's answers**. A golden that was only ever produced by the code it tests proves nothing, so the table says what each case is *supposed* to show.
- `base/testoor/golden_update.ring` rewrites the expected files. A human reads the diff in git before it is committed.
- A port passes when it reproduces every `expected.*` from the inputs.

## Adding a case

Write the three input files (or `run.json`), run `golden_update.ring`, **read** the expected prose and JSON against what you meant the case to show, add the case to the intent table in the guard, and commit them together. Never edit an `expected.*` by hand.
