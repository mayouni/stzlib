# _rig -- the instruments the PDF reader was tuned with (rounds 20-34)

These are the scratch tools of the PDF reader grind, kept so the grind can be repeated or its gate reproduced. They are
not part of the guard (`pdf_reader_narrated.ring`), which is the pre-commit gate; they are what finds a regression
BEFORE it.

Set `RIG_WORK` to a scratch folder (default `/tmp/pdfrig`); the scripts keep runs, builds and results there.
`ab.sh`, `dbg.sh` and `var.sh` still name machine paths for the Ring++ test tree (`_wti_rpp_tree`, `_wti_rpp_engine`,
`ringpp`), the Zig build and the data folder -- edit them to the machine they run on.

| file | what it does |
|---|---|
| `ab.sh <tag> [sets]` | builds the engine's `stz_file` from `engine/src/pdf.zig` (or `SRC=<file>`, to build a past reader), runs every golden set in ONE process under rnxc, scores each set with `_doc_score.py` and `head_precision.py` |
| `abcmp.py A.txt B.txt` | compares two `ab.sh` runs set by set, measure by measure: the regressions and the gains |
| `diff.py resA resB <n> <measure>` | the documents of set n whose score on a measure changed between two runs |
| `miss.py <n> <id> <lists|furniture|text> [predictions]` | what a document expected and the reader did not give, and the blocks that hold it |
| `head_precision.py` | heading precision (the share of heading blocks that are expected headings); the shared scorer counts recall only |
| `probe.zig` | a standalone dump of the reader's blocks and tables: `zig build-exe -O ReleaseSafe --dep pdf -Mroot=probe.zig -Mpdf=<pdf.zig> -femit-bin=probe.exe` |
| `var.sh <name> <old> <new>` | builds a probe from the live source with ONE replacement: a variant, to bisect which change moved a document |
| `dbg.sh <mkdbg.py> <pdf> [grep]` | builds a probe with debug prints injected (the injector scripts are not kept: they were one-off) |

The method, in one paragraph: baseline = `SRC=<git show HEAD:...pdf.zig> ab.sh b`; change; `ab.sh c`; `abcmp.py b c`; a change
that loses on any set is narrowed or withdrawn, never accepted for the gain elsewhere; then a guard scenario, the full
guard once, the freeze, a NEW independent author for the next golden set, both readers once. See memo section 8.
