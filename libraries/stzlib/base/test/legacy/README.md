# Legacy monolithic test files (archived)

Each `stz<X>Test.ring` here used to live at `libraries/stzlib/base/test/`
and is the **original** narrative-style test for one Softanza class
(`/*--- block ---*/` segments chained inline, with `?` calls and
`#-->` expected-output markers).

These files were **automatically archived** by
[`_audit_modular_coverage.py`](../../../../_audit_modular_coverage.py)
once every `#-->` marker they contained was also present in the
modular thematic suite under
[`libraries/stzlib/base/test/modular/<topic>/`](../modular/).

## What "archived" means here

- They are still under version control and still readable.
- They are **no longer the authoritative test surface** -- the modular
  blocks under `modular/<topic>/` are.
- The runner (`_run_modular_batch.py`) does not look here.
- Don't edit them. If a drift is discovered, fix it in the modular
  block instead. The audit script will refuse to re-archive any file
  whose markers stop matching the modular set.

## Why we kept them at all

1. The narratives often capture intent that the modular split
   summarises. When you want the original phrasing or a wider
   context for one block, `git log -p modular/<topic>/NN_*.ring`
   alone won't show it -- the source narrative does.
2. A re-extraction (e.g. running the splitter on a fresher Ring
   version) needs the originals as input.
3. Blame archaeology: anyone tracing who authored a specific
   assertion ends here first.

## Re-running the audit

From the repo root:

```
python _audit_modular_coverage.py
```

It prints four buckets:

| bucket   | meaning                                                      |
| -------- | ------------------------------------------------------------ |
| GREEN    | every `#-->` marker covered in `modular/<topic>/` -- safe to archive |
| YELLOW   | modular dir exists but is missing some markers               |
| RED      | no modular dir at all -- still load-bearing                  |
| GREY     | legacy file has zero `#-->` markers (nothing to verify)      |

To archive every GREEN file in one shot:

```
python _audit_modular_coverage.py --archive
```

The script uses `git mv` so history follows the file, and refuses to
move anything that's GREY / YELLOW / RED.
