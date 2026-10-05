# DOCREFORM -- state after the pilot session of 2026-10-05 (handoff)

Branch `docs/reform` (worktree `D:\GitHub\_wtd`), pushed to origin as `docs/reform-step2`. NOT on main: the push to main was refused by the auto-mode classifier and waits for the author. origin/main moves often (payments, security): rebase first, re-export if library sources changed.

## Done
- Step 1: proposal (`DOCREFORM_PROPOSAL.md`), the five rulings in its section 6.
- Step 2: extractor (`meta/stzDocRecord.ring`, `meta/stzDocExport.ring`), `reference.json` (schema 1), author guide `base/doc/DOCBLOCK.md`, glossary `params.txt` (76 names), `typo-reviewed.txt`. Export 50 s in one process.
- Step 3, the pilot, in the SOURCE (comments only, code checked identical): the 300 most used methods of stzString (132), stzList (115), stzNumber (30), stzHashList (23) carry a doc block, and each of the four classes a class block with a sample receiver. **All 300 pass checks 1-4; 293 carry an example that was run and read** (the other 7 are methods with a known defect, documented as such, no example).
- Pages for the author to read, rendered from the record: `base/doc/pilot/stzString.html` (class) and `stzString.Find.html` (method); one-page bundle published as an artifact (private): https://claude.ai/artifact/NDfgKTxAx7gEaB49pFYHu3
- Guards: docrecord_narrated 66/66, selfdoc_narrated 20/20, ask_probe_narrated 51/0.

## The table (pilot classes, 2,472 root methods, `reference.json` at the head of the branch)
| | roots | brief written | derived | none | pass checks 1-4 | with an example |
|---|---|---|---|---|---|---|
| the 300 most used | 300 | 300 | 0 | 0 | 300 | 293 |
| the other 2,172 | 2,172 | 1,200 | 223 | 749 | 128 | 0 |
| stzString | 1,093 | 761 | 66 | 266 | 179 | 131 |
| stzList | 864 | 377 | 128 | 359 | 142 | 113 |
| stzNumber | 334 | 265 | 26 | 43 | 83 | 30 |
| stzHashList | 181 | 97 | 3 | 81 | 24 | 19 |
No section title is used as a description anywhere. Library: 650 classes, 21,638 roots, brief written 5,468, pass 681.

## NOT done, and why (read before promising the acceptance)
- The acceptance asks 95 percent pass for the four classes. Only the 300 are written by hand (as the brief of the task says); the other 2,172 pass at 6 percent. A derived brief restates the name by construction (check 2), so derivation alone cannot lift them: they need written briefs, parameters and returns, which is the wave work. Failures among the rest: form 1,775 (voice, period, length), restates 1,164, returns 1,178, params 580.
- Nobody but the session has read the pages or the examples: the perception gate is OPEN. Record the author's name and verdict here when it comes.
- Step 3 memo and the FOR STZSITE line of the pilot are not filed; the cost line is written at the close of the whole task.

## Decisions made on the way (change them only with a reason)
- A third-person brief broke two Ask assertions (Removes vs remove, lowercase vs lower case). Fix: the applier keeps the OLD description as an `#@ aka` line (retrieval has always read those), the harvest folds the base form of the brief's opening verb into retrieval, the detail paragraph is NOT folded in (old maintainer talk made an unrelated method win an Ask). Folding two-word spellings was tried and made Ask worse.
- Six stzString briefs say "lower case", "upper case", "surrounding" in the words a person asks with.

## Tools (base/doc/tools/): re-run order for a class
`docblock_json.py` (docs_X.py -> json), `docblock_runexamples.py` (fresh receiver per example, real output), READ the output (`pilot/show.py`), `docblock_apply.py` on a PRISTINE source (`git show 40e2288ea:<path> > <path>` first: apply is not idempotent over its own output). Pilot data: `tools/pilot/docs_<class>.py`, `usage_rank.json` (use ranking of every pilot method). Pages: `render_pilot.py`, bundle: `tools/pilot/bundle_pages.py`.

## Next, in order
1. The author reads the two pages and the blocks in the source and rules (the pilot gate). No further migration before that.
2. Wave 1 on the four classes: written briefs for the remaining roots, starting with the 749 that have none, then the 1,200 legacy ones (voice, period, length), the params glossary, returns. Report the table after each wave.
3. Wave 0 (code): the defects below, with deprecated aliases for misspelled public names.
4. Gate in CI (step 5 of the task): doc rules beside `writes-a-mutable-constant` in `stzCodeRules.ring`, baseline file, the ratchet.
5. Land on main (the author), then the FOR STZSITE line and the cost line.

## Findings from running the examples (code, not comments; none fixed)
stzHashList: Classify raises R14 (IsStrictlyEqualTo defined nowhere); InsertBefore raises (property HashList does not exist); FindLastOccurrenceOfValue raises unless every pair holds the value; FindFirst/FindNth...OfValue raise instead of answering 0 when absent; ToCode writes numbers as text.
stzList: SplitBefore and SplitAfter change nothing and return nothing (they split a copy).
stzString: RemoveDuplicates raises R14 (UpdateWith undefined); RemoveAt(n) with one argument raises; absent answers: FindFirst -1, FindNext 0, FindLast 0, FindNth -1 (four conventions).
stzNumber: Contains(2) with a number answers FALSE (the digit must be text); StringValue rewrites the held content as a side effect of a getter; Inverse returns and does not change the number; RemoveSpaces cannot change a valid number.
Old briefs that were wrong and are replaced: stzNumber.IsBetween said bounds included (excluded), stzList.UnionWith said mutating (it returns), stzList.IsEqualTo did not say multiplicities count.
Library-wide: 117 dead forwards, 22 pvt names shown as public, about 80 typo-word candidates (`StzDocFindings`); the old harvest ended a class at its first func (6,000 methods of stzTable and stzObject were missing).
