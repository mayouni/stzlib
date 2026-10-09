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

## Wave 3 (2026-10-05, after a stop and a resume) -- ON MAIN at 053ce8b62
Complete, every root (1,087): stzCalendar 164, stzDate 93, stzTime 78, stzDataSet 101, stzReactor 50, stzReactiveSystem 48 (+ alias stzReactive), stzRegex 53, stzMatrex 58, stzTablex 64, stzDiagram 193 + seven helper classes in its file, stzTimeLine 81, stzFont 23, stzCanvas 41. Library: 21,677 roots, 6,053 pass (27.9 percent), 26 main classes at 100 percent; the gate baseline holds 15,624 roots and grandfathers 36 stzPayoutPolicy-and-neighbours methods (payments PY4) plus five stzSecurityLedger ones. 446 briefs in the 26 classes say the method raises or does nothing today (stzTable 188, stzHashList 52, stzListOfLists 51 ...); more defects sit in warnings only. Worst: stzTablex parses nothing correctly (an end-position @StzMid became count-based; stzMatrex has the end-based helper, stzTablex does not), stzTimeLine.HasMoment recurses into itself, stzDataSet.Percentile outside 0-100 ends the Ring process. Defect lists: `tools/wave/data/w2_*defects*.md`, `w3_defects_*.md`.
Agents can be stopped and resumed (TaskStop, then SendMessage to the same id): they resumed from their scratch files.
Memory hook: a hook refuses heavy Ring jobs when under 4 GB RAM is free (another session's rnxc can hold 2.7 GB); wait and retry, do not force.

## Wave 4 -- ON MAIN at be85c8105
stzGrid, stzListOfPairs, stzAuth, stzJson, stzFolder, stzSplitter, stzAppServer, stzText, stzOrgChart (+ helpers), stzGraphPlanner (+ helpers), stzGraphQuery, stzGraphex, stzMathFigure: 1,262 roots, all pass. Library 21,714 roots, 7,312 pass (33.7 percent). Baseline 14,402 (grandfathers 37 stzPispi* methods). Defects: tools/wave/data/w4_defects_*.md.

## Next (author's three decisions still open)
Wave 0 (stash 'wave0-list'), Codeberg login, a human read of a sample of briefs. Wave 4: `tools/wave/class_rank.py` -> stzFolder, stzGrid, stzOrgChart, stzGraphPlanner, stzAppServer, stzAuth, stzListOfPairs, stzJson ... three agents at a time, each batch verified, `gate.ring --update`, re-export, rebase, push.

## STOP of 2026-10-05 (about 21:50) -- read this first on resume

Author's order: "stop and save your state". main is f9665f4a3 at BOTH remotes (verified by ls-remote). Everything below
is on main: waves 5 (geo 9 classes + plots 7 classes, galleries under doc/gallery/) and 6 (security 7 classes), the
stzTablex fix (test/regex/tablex_narrated.ring, 95 assertions), DOCBLOCK.md with the heading trap and the
outside-documents section, reference.json (schema 1, header 739f15470, 659 classes, 21,791 roots, 8,169 pass, 293 with
an example), DEFECTS.md (706 defects in 41 classes), doc_baseline.txt (13,622 roots; gate.ring prints OK). The cost line
of this desk is in D:\GitHub\stzlib\.central\cost.jsonl (untracked since CENTRAL-PUBLICREPO-01), outcome partial.

### Six fix tasks the author asked for ("Do this task here"), five started as subagents

Each in its OWN worktree and branch from main 739f15470. THE AGENTS WERE CUT BY THE STOP: a worktree may hold a file
mid-edit. On resume, for EACH worktree, in this order: syntax-check every modified .ring (a load check; Ring fails fast
on a duplicate definition, case-insensitively), run the guards it added, check that every comment-only claim holds,
then commit by explicit path or finish the work. Never integrate a branch whose guards you did not run yourself.
Snapshot at the stop (git log origin/main..HEAD and git status in each worktree):

| worktree | branch | commits | uncommitted at the stop |
|---|---|---|---|
| D:\GitHub\_wtf_dt | fix/dt (datetime) | 0 | stzCalendar, stzDate, stzDateTime, stzTime modified; 4 new guards test/datetime/dtfix_*_narrated.ring |
| D:\GitHub\_wtf_tbl | fix/tbl (stzTable) | 4: 0caaf5a42 columns, c1a6c71fb rows, 523cc5512 no-ops, 43cd48775 finders | clean |
| D:\GitHub\_wtf_lol | fix/lol (ListOfNumbers, ListOfLists) | 1: 4a2e3d042 stzListOfNumbers | stzListOfLists.ring modified; guard test/list/listoflists_defects_narrated.ring |
| D:\GitHub\_wtf_lsn | fix/lsn (List, String, Number, HashList) | 3: 0aa65da5f stzList incl. the wave-0 patch, 549d15aec stzString, 53dc23ba0 stzNumber | stzHashList.ring modified, no guard yet |
| D:\GitHub\_wtf_fgcl | fix/fgcl (Folder, Grid, StringChar, Locale) | 0 | stzFolder.ring modified; test/_tmp_fgcl/ is the agent's fixture: delete it |
| D:\GitHub\_wtf_eng | fix/eng (engine panics) | 0 | NOT STARTED: it overlaps dt (month <= 0), tbl (FillCQ) and fgcl (StringLowercased(5)) and needs zig build -j2 |

The task texts are the six spawn_task chips of 2026-10-05 (copies in the scratchpad of session 9a0dccae, chips/*.txt;
if gone, the chips' text is in the session transcript). Each agent was told: no reference.json / DEFECTS.md / baseline
edits, one commit per family, no push, no rebase, doc blocks of fixed methods rewritten (third-person brief, no
known-defect warning). The wave-0 stash 'wave0-list' is superseded by fix/lsn 0aa65da5f: drop it once that branch is on main.

### Integration order (one branch at a time, one regeneration at the end)

1. tbl (clean, 4 commits): rebase on origin/main, run the test/table guards it added plus the older stzTable guards, merge fast-forward.
2. lsn, then lol (both touch base/number/: the perf-system notice was filed in CONCLUSIONS at 21:11; run the test/number and test/perf guards that load stzNumber or stzListOfNumbers), then dt, then fgcl.
3. Then eng, alone (zig build -j2, free RAM above 6 GB, nothing else building on the machine).
4. Then ONCE: cd base/doc; ring export_reference.ring <commit> <date>; python tools/wave/mk_defects.py reference.json DEFECTS.md defects.json; ring gate.ring (if other desks landed undocumented methods meanwhile: --seed and say so in CONCLUSIONS); ring gate.ring --update to drop the roots the fixes documented; commit; push docs/reform:main (origin) and docs/reform:refs/heads/main (codeberg); verify both by ls-remote; FOR STZSITE line with the rebuilt measure (the Python at the end of this section).

### Step 5 of the mission, what is NOT done

- gate.ring does not run StzDocFindings (meta/stzDocExport.ring, line 1115). Measured on main 2026-10-05 21:30: 117 dead forwards (error), 21 pvt names public and not 'status internal' (warning), 45 typo-shaped words (warning, after doc/typo-reviewed.txt). Plan: a dead-forward RATCHET like doc-floor (doc/deadforward_baseline.txt seeded with the 117; a new one fails the gate), typos and internals printed as warnings, the three kinds written deterministically to doc/findings.json by gate.ring and folded into DEFECTS.md by mk_defects.py (a 4th argument) so "fixed or listed" holds; extend test/reflect/docgate_narrated.ring (21 assertions today) with a planted dead forward, a baseline key and a typo. The 21 pvt names: add '#   status  internal' to their blocks AFTER the fix branches land (stzTime.ring is in fix/dt).
- The repository has no CI pipeline (no .github/workflows anywhere): the gate is one command, documented at the top of gate.ring; the CI step, when one exists, reads its last line (OK or FAILED).
- Nothing is wired into StzCheckProjectKnobs (text rules per file); the join is stzRuleReport.Ingest of both outputs (graph/stzRuleReport.ring).

### Waves still owed, in order

- Education: 12 classes, 206 roots in the baseline; stzProgram, stzCourse, stzExercise, stzTutor first (the learner-facing API). base/doc/education/README.md is the accepted door. Never edit base/education code; message stzlib-education.
- Payments: 19 classes, 310 roots, 0 pass (125 have an old one-line brief). The class blocks of stzPispiHttpAdapter and stzPispiQr MUST open with the status the payments desk asked for: the live adapter is proven against the twin over real HTTP and NOT run against the BCEAO sandbox, so UNPERCEIVED; no QR made by the library has been scanned; the library builds the QR STRING and does not draw the picture. docs/payments-guide.md (repository root) stays outside the extractor: test/system/charter_examples.py checks it (fence `ring` is run, `ring live` never).
- Then by tools/wave/class_rank.py. A STANCE, not a wave, is owed on stzObject (1,944 unpassed roots), stzListNamedParams (1,345) and stzQuestion (1,076): generated or dispatch surfaces, a fifth of the library.

### Open with the author

- Perception gate (CENTRAL-PERCEPTGATE-01): no person has read a sample of the briefs or seen a gallery picture; every verdict so far is a model's reading of a PNG or a page.
- Codeberg: the single-use refresh token fails every few pushes; cure = `cmdkey /delete:'LegacyGeneric:target=git:https://refresh_token.codeberg.org'` then push again (worked at 21:38); the durable fix (an application token or an SSH key) is the author's.
- stzKnowledgeGraph's class block still claims predicate-labelled edges via GraphCanvas (only the Explain method carries the warning).
- The six fix chips in the desktop app were started by the author ("Do this task here"); they cannot be withdrawn and the work is the branches above.

### The measure, from reference.json (run from base/doc)

    python -c "import json,collections as C;r=json.load(open('reference.json',encoding='utf-8'));ms=[m for c in r['classes'] for m in c['methods']];n=len(ms);o=C.Counter(m.get('origin',{}).get('brief') or 'none' for m in ms);print(n,dict(o),'pass',sum(m['pass'] for m in ms),'example',sum(1 for m in ms if m.get('example')))"

At f9665f4a3: 21,791 roots; written 10,696 (49.1%), derived 2,712 (12.4%), none 8,383 (38.5%); pass 8,169 (37.5%); example 293 (1.3%).

## RESUMED 2026-10-08: the five fix branches are ON MAIN

fix/tbl (6 commits), fix/lol (2), fix/dt (1), fix/fgcl (1), fix/lsn (3) were rebased, their 17 guards run by the parent on the
merged tree (1,126 assertions, all green), fast-forwarded into docs/reform and pushed. The register fell from 706 defects in 41
classes to 350 in 36; the ten new roots the fixes added were documented so the gate reads OK on the ratchet (no reseed).
Remaining from the six tasks: stzHashList (the agent's in-flight edit is git stash "lsn: stzHashList in flight", 268 lines,
no guard; register 56 rows), stzGrid / stzStringChar / stzLocale (not started), fix/eng (not started: Percentile panic,
WMean and HasMoment recursion, month <= 0, StringLowercased(5), FillCQ, diagram probe memory). The rows left for stzTable (66)
and stzCalendar (25) may include stale blocks of fixed methods: call the method before fixing. Worktrees _wtf_* can be removed
(git worktree remove) once their branches are confirmed on main; stash wave0-list was dropped (its content is on main).

## 2026-10-08, late: WAVE 7 (education) and the six fix tasks are ON MAIN (2c66ec8a6)

All six fix tasks landed (register 706 -> 227); wave 7 documented the 12 Learning System classes (216 roots; the three limits
sit in eight class blocks); gate step 5 is wired (dead-forward ratchet, deadforward_baseline.txt 96, findings.json).
Library: 21,747 roots, 8,331 pass (38.3 percent). Owed, in order: (1) the payments wave: 19 classes, 310 roots, 0 pass,
files under base/service/ (StzAmount, StzPaymentsPort + Order/Request/Batch/Webhook, StzPiSpiSandbox, StzPispiHttpAdapter,
StzPiSpiHttpFront, StzPispiQr, the payout trio, StzPispiSecret, StzSecretExpiryWatch, StzServiceRegistry); the class blocks of
stzPispiHttpAdapter and stzPispiQr MUST open with: proven against the twin over real HTTP, NOT run against the BCEAO sandbox
(UNPERCEIVED); no QR made by the library has been scanned; the library builds the QR string and does not draw it. (2) a
stance on stzObject 1,944 / stzListNamedParams 1,345 / stzQuestion 1,076 unpassed roots. (3) the engine DLLs stz_stats,
stz_locale, stk_locale must be rebuilt in every checkout (their sources changed). Wave recipe that worked: three subagents on
file-disjoint classes in the docs worktree reading tools/wave/README.md plus a prompt like scratchpad wave7_prompt.md (copy
kept as doc/tools/wave/WAVE_PROMPT.md); I verify code-identical-with-comments-stripped, regenerate once, --update the gate.

## 2026-10-09, after midnight: WAVE 8 (payments) ON MAIN (23fe1111a)

19 payments classes, 310 roots, all pass; the UNPERCEIVED / not-scanned / string-not-picture status is in classes[].description
and in 22 method notes of the record. Library 8,641 of 21,747 pass (39.7 percent). Owed: (1) the STANCE on stzObject 1,944 /
stzListNamedParams 1,345 / stzQuestion 1,076 unpassed roots: generated or dispatch surfaces, a fifth of the library -- decide
between a derived-brief rule for them (the exporter labels it derived and the gate accepts it for these three) and hand waves;
(2) class_rank.py for the next waves (stzStringText 101, stzMathDiagram 82, stzListOfBytes 79 ...); (3) the register rows left:
stzTable 66, stzCalendar 25, stzGeoMap 18, stzMatrex 17, stzGraph 12; (4) the education and payments findings are in
w7_defects_education.md and w8_defects_payments.md, routed in CONCLUSIONS, not in the register; (5) the engine DLLs rebuild in
every checkout; (6) the perception gate: a person reading ten briefs and one class page.

## 2026-10-09: DERIVED BRIEFS for the generated classes, and WAVE 9 (cf2d495af)

The author ruled "derived briefs for the three" (stzObject, stzQuestion, stzListNamedParams): meta/stzDocExport.ring
_StzDocGenBrief derives the brief of the machine-made forwarders from the executor and the name (XB value test, XQC chainable
copy, XN count, XNB count agreement, XQ question noun, Is<Keyword>NamedParam); guard test/reflect/docgen_narrated.ring (41).
Wave 9: stzObject hand core + string helpers + stzMathDiagram + stzListOfBytes + three system classes (1,000 roots), and the
parameter reader now ends at the matching parenthesis. Library: 13,589 of 21,747 pass (62.5 percent); gate OK; 96 dead forwards
in deadforward_baseline.txt; register 268 in 36 classes (the new blocks carry warnings). Left: 8,158 roots in 471 classes,
the long tail -- python tools/wave/class_rank.py <repo>/libraries/stzlib doc/reference.json out.json ranks by use; the
unpassed top is stzPanel 64, stzNaturalEngine 64, stzLinearSolver 55, stzFalseObject 55, stzUMAP 54, stzStochasticSolver 54,
stzRegexMaker 53, stzApp 51, stzEarcons 50, stzPlatform 49, stzNumbrex 49, stzWorkflow 48 ... Recipe: tools/wave/WAVE_PROMPT.md
(wave 7/8 form) or the wave-9 prompt (neutral rules; in the session scratchpad, rebuild it from WAVE_PROMPT.md by dropping
rule 4's status clause). Remember: three agents, file-disjoint, comments only, I verify code-identical-stripped, regenerate once.

## 2026-10-09, morning: WAVE 10 ON MAIN (5397af296)

19 classes, 964 roots (panel / natural engine / false object / regex maker / numbrex / url; the solvers, embeddings, random; app /
platform / earcons / workflow / cluster / http client / deployment site). Library 14,545 of 21,747 pass (66.9 percent); gate OK;
register 286 in 41 classes. Left: 7,202 roots in 450 classes. Recipe unchanged (WAVE_PROMPT.md; neutral rules; three agents,
file-disjoint; strip-check, regenerate once, --update). A known applier trap: it can put a block above an old commented-out
`def` copy inside /* */ -- the agent moved three blocks by hand in stzMultiObjectiveSolver.ring; re-applying that class needs
the same move. A wave agent killed ring.exe by image name once: tell agents to kill by PID.

