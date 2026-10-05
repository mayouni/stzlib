# DOCREFORM -- state after wave 2 (handoff, 2026-10-05)

Branch `docs/reform` (worktree `D:\GitHub\_wtd`). **On origin main** (wave 1 at c5991d4b6, wave 2 at 2e3990484, fast-forwards). Codeberg main is NOT pushed: its login is interactive; the documented cure is `cmdkey /delete:'LegacyGeneric:target=git:https://refresh_token.codeberg.org'` then `git push codeberg main:refs/heads/main`, and the author must do the browser login. origin/main moves often: `git fetch` and rebase first, re-export if library sources changed. `git add` by explicit path only.

## Done
- Step 1 proposal, step 2 extractor + `reference.json` (schema 1) + `DOCBLOCK.md` + glossary `params.txt`.
- Step 3 pilot, ruled well by the author (the two pages, 2026-10-05).
- **Wave 1: the four pilot classes are finished.** Every root method has a written brief, and parameter roles and returns where the glossary does not give them: stzString 1,093/1,093 pass checks 1-4, stzList 864/864, stzNumber 334/334, stzHashList 181/181. Comments only, code checked identical (the applier compares code before and after).
- Every method was **called once with real data before its brief was written** (`tools/docblock_probe.py`, then small `.ring` scripts for the doubtful). About 120 methods raise or do nothing today; their brief starts `Raises ... today instead of ...` and a warning names the cause. They are listed below.
- Guards: docrecord_narrated 67/67, selfdoc_narrated 20/20, ask_probe_narrated 51/0.
- Tooling and the data of wave 1 are in `base/doc/tools/wave/` (README there: probe, table, write, build, measure, guards).
- Reported: `dashboard/CONCLUSIONS.md` (FOR STZSITE line + a conflict warning for sessions editing the four files) and `memos/2026-10-05.md` (Softanza repo).

## Wave 2 (2026-10-05, by subagents following tools/wave/README.md) -- ON MAIN at 2e3990484
Passing checks 1-4, every root of: stzTable 745, stzStringChar 259 (+ stzChar 1), stzStringList 91, stzListOfNumbers 224, stzListOfLists 276, stzGraph 286 (+ Finder 6, AsciiVisualizer 8, Comparison 14), stzKnowledgeGraph 47, stzDateTime 226, stzMatrix 172, stzLocale 84 = 2,439 roots; the alias classes (stzListOfstrings, stzNumbers, stzLists) carry a class block. Library: 21,640 roots, 4,969 pass (23.0 percent), brief written 8,168. Each batch was verified by me: code identical to the commit before (every comment line removed), an independent export, the guards.
**The doc gate is live** (`meta/stzDocGate.ring`, `doc/gate.ring`, `doc/doc_baseline.txt` with the 16,671 roots that do not pass yet; `docgate_narrated.ring` 21/21). `ring gate.ring` in base/doc: 0 errors; it printed FAILED for five new stzSecurityLedger methods that landed during the wave, which the baseline now grandfathers.
Defects found are in `tools/wave/data/w2_defects_*.md` and `w2_graph_defects.md` (about 500 methods in these classes raise or do nothing today; none fixed). Worth knowing: every pre-1970 stzDateTime instant is invalid (about 60 origin and negative-count paths); stzTable families (InsertCol, ReplaceColName, Remove*Cols, FindFirst*In*) raise or do nothing; stzListOfNumbers random picks are broken by a method shadowing a global function.
**Wave 0 is NOT landed.** Thirteen stzList fixes (Insert one place early, six Split* mutators that dropped their result, ExtractDuplicates, ExtractFirst/LastOccurrence, RepeatedTrailingItem, NumberOfRepeatedTrailingItems, AntiSection, InsertAfterPosition) were written and tested (27/27) but the auto-mode classifier denied the commit ('Modify Shared Resources'), so they sit in `git stash` (message 'wave0-list') and in `tools/wave/wave0_list.patch` (apply with `git apply`; the guard is saved as `tools/wave/wave0_list_narrated.ring.txt`: copy it to base/test/reflect/ as .ring when the patch is applied). The author must allow code commits on docs/reform, or commit them. NEVER re-run reapply_all.py on stzList, stzString, stzNumber, stzHashList: it restores the pristine file and would erase any code fix.
Corrections to wave 1 found since: RepeatedLeadingItem was documented as broken and is not (an empty string when there is no run); SplittedAt keeps the item at the start of the next part; NumberOfRepeatedLeadingItems is the run length (all three are fixed in the wave-0 patch's block text only, not on main).
Tooling fixes found by the agents: reapply_all.py now restores a shared file once; `#>`/`#<` marker lines between a block and its def inside an alias group are left by the applier (the extractor still reads the block).

## The table
`reference.json` at c5991d4b6 -> regenerated at a1453effb: 650 classes, 21,634 roots, brief written 6,440, derived 3,024, pass checks 1-4: 2,725 (the four classes 2,472, the other 646 classes 253), with an example 293.

## NOT done
- **About 16,670 roots** (the baseline). The 95 percent acceptance is for the four pilot classes (met); the library as a whole is at 23.0 percent after wave 2. `tools/wave/class_rank.py` ranks classes by how many files create them.
- Perception gate: the author read the two pilot pages and ruled them well. The wave-1 briefs for 2,172 more methods have been read by nobody but the writer. Record the author's name and verdict when they have looked at a sample.
- Step 5, the CI gate: doc rules beside `writes-a-mutable-constant` in `base/meta/stzCodeRules.ring`, a baseline file, the ratchet (floor for new and changed methods: checks 1-2).
- Wave 0, the code fixes (waits for the author's word on deprecated aliases for misspelled public names).
- Codeberg push; the cost line (written at the close of the WHOLE task, to `.central/cost.jsonl`).

## Defects found by probing (code, not comments; none fixed)
stzList: Insert(item, n) puts the item at n-1 and raises for n = 1 or past the end (InsertBefore is right); SplitCS, SplitAtPosition, SplitToNParts, SplitAfterPosition, SplitBeforePosition, SplitAtPacer split a copy and drop the result (the Splitted forms work); ExtractDuplicates removes the repeats and answers [ ]; AntiSection raises R19; RangesAndAntiRanges, ExtractFirstOccurrence, ExtractLastOccurrence, NumberOfRepeatedTrailingItems, RepeatedTrailingItem, SplitXT, SplittedXT, SplitAsSectionsXT, SplittedAsSectionsXT call methods that exist nowhere; ItemsAppearingLessThanNTimes returns numbers as text; RepeatedLeadingItem answers an empty string.
stzString: IsIncludedIn tests whether the ARGUMENT is inside the string (reversed); Move(1, 3) lands the char at 2; LeadingCharIs and TrailingCharIs answer FALSE for the first/last char; RemoveBlankLines and SplitAroundCS_named call methods that do not exist; SplitToPartsOfNCharsXTOpt raises R19 for its documented argument; the old briefs said SplitToNParts cuts chunks of n chars (it cuts n parts) and ReplaceBetween replaces the bounds (it keeps them).
stzHashList: the whole class-statistics group (Klass..., ClassesSizes, StrongestClass, Top3Classes ...) raises R14 on text values (IsStrictlyEqualTo is defined nowhere) and gives wrong counts on list values; KeysByItemInList, FirstPair, LastPair, Strongest3Classes ... raise; FindNumber, FindString, NumberZ, StringZ and their plural forms reject even an argument of the type they ask for; KeyInPair and ValueInPair raise for a real pair; ReverseKeysAndValues, UpdateAllPairsWith raise; 57 methods carry a warning in all.
stzNumber (wave 1): 35 methods carry a warning (see the blocks; the pilot findings below still hold).
Pilot findings still open: stzHashList Classify raises R14; stzString RemoveDuplicates raises R14; four "absent" conventions in the stzString finders (-1, 0, 0, -1); stzNumber Contains(2) answers FALSE for a number; StringValue rewrites the held content.
Library-wide: 117 dead forwards, 22 pvt names shown as public, about 80 typo-word candidates (`StzDocFindings`).

## Decisions made on the way (change them only with a reason)
- A third-person brief broke Ask assertions; fix: the old description stays as `#@ aka` (retrieval reads those), the base form of the opening verb is folded in, the detail paragraph is NOT folded in. **Old akas carry words that can outrank a better answer** (stzString.Insert lost "put something at a position" to AreBoundsOfXT through the word "something"): run ask_probe_narrated after every wave.
- A brief never contains the method's own name (check 2 reads it as restating); the call form goes to the `note` field.
- Methods that raise today get a defect brief; a probe that answers wrongly is a finding, not an example.

## Tools
`base/doc/tools/`: `docblock_probe.py`, `docblock_apply.py`, `docblock_json.py`, `docblock_runexamples.py`, `pilot/reapply_all.py` (restores a source from PRISTINE 40e2288ea, applies every `w1_docs_<Class>.json`; classes that share a file go in ONE call), `wave/` (`txt2docs.py`, `mk_table.py`, `failmine.py`, `fixlines.py`, `gen_np.py`, `export_classes.ring`, `runwave.sh`, `data/`). PRISTINE is safe only while nobody else changes the file: check `git log 40e2288ea..origin/main -- <file>` first (wave 1: only my commits).

## Next, in order
0. Wave 3: `tools/wave/class_rank.py` ranks the classes; take the next ones (stzDiagram + its file mates, stzTimeLine, stzDataSet, stzFont, stzCanvas, stzReactor, stzRegex, stzCalendar ...) by the README, three agents at a time, verify each batch, then `gate.ring --update`.
1. (done in wave 2) pick the classes (the most used classes outside the four), probe, write, measure, guards, commit, re-export, report.
2. Step 5, the CI gate and its baseline, so what is written stays written.
3. Wave 0 when the author says so; codeberg push when the author logs in; the cost line at the close.

## Stopped by the author, 2026-10-05 (resume here)
Wave 3 was launched (three agents: diagram/timeline/font/canvas; calendar/time/date; dataset/reactor/reactive/regex/matrex/tablex) and stopped before any of them reported. The worktree D:\GitHub\_wtd may hold UNCOMMITTED comment-only edits of those source files (partial blocks); each apply was code-checked, but nothing was verified or committed. To resume: either `git checkout -- <those files>` and rerun the wave (their wave lines, if any, are in the session scratch folders w3_diagram, w3_datecal, w3_misc, which are temporary), or keep the edits, finish the classes with the README process, verify (code identical with comments stripped, independent export, guards), commit, `gate.ring --update`, re-export reference.json, push `docs/reform:main`. Origin main was 044b9dcd2 when stopped. Open decisions for the author: allow code commits on docs/reform so wave 0 (git stash 'wave0-list', tools/wave/wave0_list.patch) can land; the Codeberg login; a human read of a sample of briefs.
