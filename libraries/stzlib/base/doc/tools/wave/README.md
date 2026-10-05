# Wave tooling -- how a class is documented (DOCREFORM wave 1, 2026-10-05)

A wave writes the doc block of every root method of a class, **after calling the method once**.
Two thirds of the old "(mutating)" / "returns a copy" briefs were wrong, and probing found about
120 methods in the first four classes that raise or do nothing today. Never write a brief from the
name alone.

Run from a scratch folder that holds `usage_rank.json` (copy of `../pilot/usage_rank.json`).
Set `DOCWAVE_DIR` (that folder), `DOCWAVE_BASE` (`.../libraries/stzlib/base`) and `DOCWAVE_REF`
(`.../base/doc/reference.json`). `PYTHONIOENCODING=utf-8` on Windows.

1. **probe** -- `RING=ring python ../docblock_probe.py <reference.json> <Class> probe_<Class>.json`
   (8 s for 1,079 methods). The methods that returned nothing and changed nothing are probed again
   with richer receivers: `PROBE_MODE=2 ... --only "<names>"` -> `probe2_<Class>.json`.
2. **table** -- `python mk_table.py <Class> 0 2000` prints every undocumented method with its old
   brief and what the probe saw (`=> LIST [...]`, `[CHANGES]`, `ERR ...`). Read it. For the doubtful
   ones write a small `.ring` script with real data and read the answers (receiver keys, one line
   per call) -- see `data/` for what the first wave wrote.
3. **write** -- lines in `w1_<Class>_NN.txt`: `Name | brief | returns | p=role; q=role | See, See | warning | note`.
   Rules the gate enforces: the brief begins with a third-person verb (Returns, Removes, TRUE if),
   is 20-140 chars, ends with a period, never contains the method's own name and does not just
   restate it; every parameter has a role (written, or in `../../params.txt`); returns is stated.
   A method that raises today: `Raises error R14 today instead of <intent>.` + a warning naming the
   cause. Never describe what a broken method was meant to do as if it worked.
4. **build and measure** -- `python txt2docs.py <Class> "w1_<Class>_*.txt"` (checks every name is a
   root), then `./runwave.sh <Class>` (applies on the PRISTINE source -- see `../pilot/reapply_all.py`
   -- exports the four pilot classes and prints the failing ones), `python failmine.py <Class>` lists
   which of YOUR entries fail and which check (`[form, restate, params, returns, example]`).
   `fixlines.py <file>` replaces whole lines by name from stdin.
   `gen_np.py <Class> <out.txt>` writes the one-line briefs of the `Is...NamedParam` predicates.
5. **guards** before the commit, once: `base/test/reflect/` docrecord_narrated (67), selfdoc_narrated
   (20), ask_probe_narrated (51). A new brief can steal a retrieval: an old description kept as
   `#@ aka` carries words like "something" that outrank a better answer (stzString.Insert).
6. commit by explicit path, regenerate `reference.json` (`cd base/doc; ring export_reference.ring <commit> <date>`),
   report the table, then the FOR STZSITE line and the memo.

`data/` holds the entries of wave 1: stzHashList (a Python file with `E(...)` calls, the first form),
stzList and stzString (the compact lines). `reapply_all.py` reads `w1_docs_<Class>.json` built by
`txt2docs.py` / `docblock_json.py`; it restores each source from commit 40e2288ea first.
