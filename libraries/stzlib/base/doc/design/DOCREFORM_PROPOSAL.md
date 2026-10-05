# DOCREFORM -- the library documents itself so that it reads like a reference

*STZLIB-DOCREFORM-01 · step 1, study and proposal · read at `origin/main` 523c71484 (2026-10-04), extractor files identical to 0e72e2e2c · NOTHING below is built yet; the author rules first.*

## 1. What I read, and what it says

**The extractor** is a line scan, not a parser (`_StzHarvestRange`, `stzReflectFuncs.ring:1102`): a method's description is *every comment line above its `def`*, joined, blank lines ignored, code breaking the run. A boxed `#===# Title #===#` line sets a *section*, and the last pass of the harvest hands that title to every method still undescribed (`:1486`, "LAST RESORT") -- this is the whole cause of the 32% row. Between those, three passes copy a sibling's text ("Same as X: ...", the `CS/Q/QC/XT/B/ZZ` gloss): that is the 6% row and also why the same sentence is repeated across a family. `#@ aka|tags|see` lines already exist (112 of them, 4 files) and feed **retrieval only**, never the description. `Ask`, `HowTo`, `ExplainMethod` and `stzLibDoc` consume `[name, description, aka, owner]`; that tuple is what stays working.

**The benchmark.** Wolfram's page is ordered *usage lines, Details, Basic Examples, Scope, Options, Applications, Properties and Relations, Possible Issues, See Also, Guides*. Qt's is *summary tables, Detailed Description, one entry per member (signature, brief, parameters, return, note, `since`, See also, snippet)*. One correction to the brief's premise: Qt's summary tables list members **alphabetically**, not by purpose; grouping by purpose, as the `#===#` sections already do, is something Softanza can have that Qt does not.

**My own measure** (a Python replica of the harvest rules, used only to measure; the extractor stays in Ring; it does not follow helper delegations, so "no text" is an upper bound):

| class | public defs | pure forwards (aliases) | own sentence | section title only | nothing |
|---|---|---|---|---|---|
| stzString | 2,114 | 752 (36%) | 1,051 | 1,063 | 0 |
| stzList | 1,583 | 603 (38%) | 459 | 1,124 | 0 |
| stzNumber | 756 | 362 (48%) | 332 | 424 | 0 |
| stzHashList | 638 | 442 (69%) | 135 | 503 | 0 |

(Every undocumented method sits under *some* box, so "nothing" is 0 here: in the pilot the problem is the section title, not silence.) Of own sentences only **817 / 268 / 283 / 91** pass a first surface test (uppercase start, final period, 20-140 characters).

**Four findings the brief did not have**

1. **The site's denominator includes the archive.** `def` lines under `base/`: 66,351; **29,892 of them in `archive/`** (45%), 49 in `test/` and `doc/`; live code is 36,410. The site's "65,737 definitions" is close to the first figure, so it probably counts the archive (I did not read how the site counts; routed to stzsite to check). My class-aware scan of live code finds 30,010 defs of which 9,301 are pure forwards (31%, against the site's 36%); it misses the 6,400 defs of classes assembled across files (finding 4), so read that share as approximate.
2. **The typo detector as written would drown the gate.** "Edit distance 1 between two names of a class" yields 179 pairs in stzString alone, nearly all legitimate (`Capitalize`/`Capitalized`, `AddItem`/`AddItems`). A **word-level** detector works: split names into CamelCase words, count each word across the library, flag a word seen at most twice that is one edit (or one transposition) from a word seen at least eight times. Library-wide: **291 candidates**; among the top 80 about a third are real (`Unamed`, `Witht`, `Staring`, `Containg`, `Positon`, `Psoition`, `Laste`, `Sectionss`, `Randoom`, `Obejct`, `Equalt`, `Wrtite`, `Mutch`, `Colum`, `Colmun`, `Milllions`, `Veiw`, `Rulf`, `Worts`, `Befor`, `Integr`, `InertLine` for `InsertLine`), the rest English words (`night`, `light`, `moved`). So: findings, with a reviewed baseline, never a hard fail on first sight.
3. **Dead forwards are 94 library-wide** (target missing from the class and its ancestors), concentrated in stzDiagram 31, stzListNamedParams 20, stzObject 13, stzHashList 7, stzRegexMaker 5. Forwards to a `_private` helper that exists are not dead (my first count said 18 for stzString; those were that false positive).
4. **A class can be assembled across files.** `stzTable.ring` holds 2,522 `def` lines and no `class` line; `stzObject.ring` has an indented `class Person` at line 36 and the real class at 2027. The harvest resolves a class by name to one file; whether stzTable is harvested whole is **unverified** and is measured first in step 2.

## 2. The block (proposal)

A comment run **immediately above `def`** (no blank line). First line is the *brief*; a bare `#` separates an optional paragraph; then **fields**: `#` + two or more spaces + key. Key is a **parameter name of that very def**, or one of `returns note warning see example since status detour forms`. A deeper-indented line continues the field above. Anything else is prose. Old one-line comments stay valid briefs.

```
	# Returns the positions of every occurrence of pcSubStr, as a list of numbers.
	#
	#   pcSubStr   the text to look for
	#   returns    a list of numbers; [ ] when pcSubStr is absent
	#   note       case-sensitive; FindCS takes the flag
	#   see        FindFirst, FindNth, Contains
	#   example    ? @@( Q("banana").Find("an") )
	#              #--> [ 2, 4 ]
	def Find(pcSubStr)
```

- The `#-->` goes on the **next** line, as in every narration, so the existing promise harness can run a doc example unchanged.
- `status`: `stable` (default) · `experimental` · `deprecated` · **`internal`** (never presented as API; a `pvt` name or `status internal` implies it). `detour`: the natural name a host collision forced away. `forms`: the accepted named-parameter calls (`HasMoreChars(:Than = 3)`).
- `#@ aka/tags/see` is unchanged and stays retrieval-only; the new `see` is documentation. They do not merge.
- **Class block** above `class X`: brief; Detailed Description; `receiver` (one or two lines building `o1`); `example`; `see`; `since`; `status`. A boxed section title is **structure**: members group under it; it is never copied into a description.
- **Parameter glossary, written once.** `base/doc/params.json` maps a conventional name (`pCaseSensitive`, `pcSubStr`, `n`, ...) to its role; a method that does not describe such a parameter inherits it, labelled `derived`. This is the single largest saving on 22,000 methods.

## 3. The record (`base/doc/reference.json`, `"schema": 1`, commit, date, byte-deterministic)

Per method: `key` (`class.name`, lowercase, **stable**), `name`, `class`, `section`, `brief`, `usage[]`, `parameters[{name,type,role}]`, `returns`, `notes[]`, `see[]`, `example`, `promise`, `extensions[{code,adds,exists}]`, `since`, `status`, `alias_of`, `forms[]`, `detour`, `passive`, and `origin` per field: `written | derived | none`. Per class: `brief`, `description`, `receiver`, `ancestors`, `sections[{title,members}]`, `aliases`, `alias_of`. Derived: usage and parameter types (Hungarian prefix: `pc` text, `pn` number, `pa` list, `pb` boolean, `po` object, `p` any), extensions that exist, passive twin, aliases through `_StzFwdTarget`, predicate first sentence (`IsX` -> "TRUE if ..."; always `derived`, never counted as written). The extension table (20 codes) moves into the library; the site's `qforms.py` is the catalogue I start from.

## 4. The score and the gate

Six checks per public method: **(1)** brief of 20-140 characters, uppercase, ends with a period, opens with a third-person verb, `Returns`, or `TRUE if`; **(2)** not the name restated, not the signature repeated; **(3)** every parameter described (written or glossary); **(4)** returns stated (written or derived); **(5)** example present; **(6)** example runs. *Pass* = 1-4. *Reference* = 1-6. Rules registered beside `writes-a-mutable-constant` in `stzCodeRules.ring`, in the unified shape `[ :rule, :subject, :where, :severity, :message ]`: `doc-brief-missing` (new or changed public method), `doc-brief-quality`, `doc-class-score-fell` (ratchet against `base/doc/doc-baseline.json`), `doc-dead-forward`, `doc-typo-word`, `doc-internal-shown`. Legacy findings are baselined; the gate fails on **new** ones.

## 5. Migration

Step 2 the extractor (Ring first; **if the 652-class export exceeds 60 s in one process, the line scan moves into the engine**, as the engine-first doctrine says). Step 3 pilot: derive first, then write by hand the 300 most used methods (ranked by tests + narrations + recipes), render one class page and one method page, **record who read them**. Step 4 waves by size and use, mechanical part by script, comments only, every touched file syntax-checked, staged by explicit path. Typo and dead-forward *repairs* are **code** edits and form their own wave 0 (a wrong spelling stays as a `deprecated` alias of the right one so no caller breaks).

## 6. Rulings (the author, 2026-10-05)

1. **Brief voice: third person** ("Returns...", "Removes..."). Ruled.
2. **The block: ruled, with one change.** `#-->` shows the output **inline, after each meaningful `?` line**, so a block has **no Output field**: the example is its lines, promises in place. (The guard and the record keep exactly that: `example` is the lines, `promises` the `#-->` payloads in order.)
3. **Pass = checks 1-4, Reference = 1-6, the gate's floor for new or changed methods = checks 1-2.** Left to me; decided as proposed.
4. **Wave 0 (typos and dead forwards, as code) comes after the pilot.** Ruled.
5. **Engine threshold: Ring first, the engine only if the export exceeds 60 s in one process.** Ruled. Measured at step 2: see the CONCLUSIONS line.

**Corrections found while building step 2** (the measures of section 1 stand, these refine them): the parameter glossary is `base/doc/params.txt` (one `name<TAB>role` per line), not JSON; a lone `#` in a doc block is the empty line that ends the brief (the old harvest read it as a boxed line and threw the description away); a class runs to the next `class`/`package` line, so a `func` inside it is a method: with the old rule stzTable was harvested at 1,730 methods of 4,009 and stzObject lost about 2,750.
