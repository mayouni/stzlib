# DOCREFORM -- state at the end of the session of 2026-10-05 (handoff)

Branch `docs/reform` (worktree `D:\GitHub\_wtd`), pushed to origin as `docs/reform-step2`. NOT on main: the push to main was refused by the auto-mode classifier and waits for the author.

## Done
- Step 1: proposal (`design/DOCREFORM_PROPOSAL.md`), rulings recorded in section 6.
- Step 2: extractor (`meta/stzDocRecord.ring`, `meta/stzDocExport.ring`), `reference.json` (schema 1), guard `test/reflect/docrecord_narrated.ring` (63), author guide `DOCBLOCK.md`, `params.txt`, `typo-reviewed.txt`. Export ~46 s in one process. FOR STZSITE line filed in CONCLUSIONS.
- Step 3 (pilot, in progress): the 300 most used methods of stzString (132), stzList (115), stzNumber (30), stzHashList (23) carry a doc block in the SOURCE, comments only (checked: code identical before and after). Every example was RUN (tools below) and READ by the session; the author has NOT read them yet. 292 of the 300 pass checks 1-4 as measured; 8 fail the form check and are listed below.

## Tools (base/doc/tools/)
`docblock_json.py` (docs_X.py -> json), `docblock_runexamples.py` (runs each example in a fresh receiver, captures real output, adds `#-->`), `docblock_apply.py` (writes blocks, refuses if code changes). The pilot data is in `tools/pilot/docs_<class>.py` (+ `usage_rank.json`, the use ranking). Re-run order for a class: json, runexamples, READ `show.py`, apply on a PRISTINE source (`git checkout` the file first: apply is not meant to be repeated over its own output).

## To do next (in this order)
1. Fix the 8 briefs that fail the form check (in `tools/pilot/docs_*.py`, then re-apply on a clean checkout): FindItem and BoundsOf and IsExact (over 140 characters), IsANumber and IsLetter of stzNumber (open with "Always": reword "Answers TRUE/FALSE ..."), SplitBefore and SplitAfter of stzList and RemoveDuplicates of stzString (open with "Is meant to": reword "Splits ..., but a known defect makes it do nothing today").
2. Widen `params.txt` for the common undescribed parameter names of the four classes (n, _n_, pcSub, pacBounds, pStartingAt, _n1_, _n2_, pcOther, pcNew, pcOpen, pcClose, _aSections_, pWith, ...): 1,088 parameters across 220 names; only names with ONE meaning everywhere.
3. Extend the derived `returns` only with rules that hold on every method of the family (NumberOf*, HowMany* give a number); verify by running.
4. Re-export `reference.json` (`cd base/doc; ring export_reference.ring <commit> <date>`), measure the table of the four classes, run the three guards (docrecord, selfdoc, ask_probe), commit by explicit path.
5. Render ONE class page and ONE method page (HTML the author can open without rebuilding: e.g. stzString and Find) from `reference.json`; record WHO read them and what they said (the perception gate): none yet.
6. Append the FOR STZSITE line (wave 0 of the pilot), write the memo, append the cost line to `.central/cost.jsonl` of the shared tree at the close of the whole task.
7. STOP for the author's verdict before any further migration.

## Findings from running the examples (wave 0 candidates; code, not comments; none fixed)
stzHashList: Classify raises R14 (calls IsStrictlyEqualTo, defined nowhere); InsertBefore raises (reads a property HashList that does not exist); FindLastOccurrenceOfValue raises unless every pair holds the value; FindFirst/FindNth...OfValue raise instead of answering 0 when absent; ToCode writes numbers as text.
stzList: SplitBefore and SplitAfter change nothing and return nothing (they split a copy).
stzString: RemoveDuplicates raises R14 (UpdateWith undefined); RemoveAt(n) with one argument raises; FindFirst answers -1 when absent, FindNext and FindLast answer 0, FindNth -1 (three conventions).
stzNumber: Contains(2) with a number answers FALSE (the digit must be text); StringValue rewrites the held content as a side effect of a getter; Inverse returns the inverse and does not change the number (its old comment said it did); RemoveSpaces cannot change a valid number.
Old briefs that were wrong and are replaced: stzNumber.IsBetween said bounds included (they are excluded), stzList.UnionWith said mutating (it returns), stzList.IsEqualTo said set-based without saying multiplicities count.
Library-wide: 117 dead forwards, 22 pvt names shown as public, about 80 typo-word candidates (`StzDocFindings`); the old harvest ended a class at its first func (6,000 methods of stzTable and stzObject were missing).

## Other open items
- Push of docs/reform to main: needs the author (merge docs/reform-step2, or allow the push). origin/main moves often (payments commits): rebase first, re-export if library sources changed.
- Codeberg not pushed.
- Memo for step 3 not yet written; CONCLUSIONS has the step 2 FOR STZSITE line only.
