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

## 2026-10-09, midday: WAVE 11 ON MAIN (024ddaf4d)

53 classes, 1,022 roots (file family, xml/html, list helpers; auth stores, response plans, virtual system/env/fs, delivery; Tukey,
math-diagram helpers, graph rule, notation, duration, string locale). Library 15,564 of 21,747 pass (71.6 percent); gate OK;
register 316 in 52 classes. Left: 6,183 roots in 399 classes. Held back on purpose: the sound classes (stzSoundScore 49,
stzSound 40, stzSoundLive 39, stzSoundUniverse 38 ...) need a way to run without an audio device (render to a buffer or WAV only,
never play); do them last, with that rule in the prompt. Agents can stall on a stream timeout (three did in wave 11): resume with
SendMessage to the same agent id, nothing is lost. Agents sharing a scratchpad folder overwrite each other's scripts: give each
agent its own subfolder name in the prompt.

## 2026-10-09, afternoon: WAVE 12 ON MAIN (d589f98bd)

42 classes, 1,061 roots. Library 16,625 of 21,747 pass (76.4 percent); gate OK; register 360 in 58 classes. Left: 5,122 roots in
357 classes (sound classes about 170 held back). Applier traps met this wave: it stops at the word `class` inside a block comment
and needs `(` after `def` (agent worked around it with a private pristine snapshot and restored the lines); a file shared by several
classes must be applied in ONE call with all its classes or the other blocks are dropped. stzFileBlobStore's class example uses a
relative folder `demo_blobs` (a run leaves it in the cwd): no temp-folder helper exists in the library to use instead.

## STOP of 2026-10-09 (afternoon), "save your state until AC comes back" -- read this first on resume

main carries waves up to 12 (574874138 and the state commit after it). WAVE 13 IS HALF IN:
- COMMITTED LOCALLY (88b88d291, on docs/reform, NOT pushed unless the line below says so): parts B, C, D -- security / neural /
  conversation / entity / federation (13 classes), graphics / math / common / perf / data wrangler / refinable code / country
  (12 classes), external code / dot code / super app / http port (5 classes); their data files w13_*_01.txt + classblock_*.json.
  Checked by me: sources comments-only. NOT yet regenerated: reference.json, DEFECTS.md, doc_baseline.txt are as of wave 12.
- NOT COMMITTED: part A, stopped mid-work by the stop. Twelve sources are already modified in the worktree (comments only so far,
  strip-checked): string/stzStringCrypto, stzStringComparator, stzStringFinder, stzStringInserter, stzStringLines, stzTextStream;
  list/stzListFinder, stzTree; regex/stzTimex, stzListex; number/stzNumBuffer, stzPCA. Some classes there may be only partly
  documented. Its class list and roots: the 12 files above (353 roots).
Resume, in order: (1) `cd D:\GitHub\_wtd; git status` and check the worktree is on docs/reform; (2) finish part A: SendMessage to the
agent id a67402306ffdeefae if it still exists, otherwise launch one general-purpose agent with doc/tools/wave/WAVE_PROMPT_NEUTRAL.md
(copy of the wave-9 prompt; files named w13_) for exactly those 12 files, telling it to FIRST export its classes and fix only what
still fails; (3) strip-check all 12 sources, commit them by explicit path with their data files; (4) regenerate ONCE: `cd base/doc;
ring export_reference.ring <HEAD> <date> reference.json; python tools/wave/mk_defects.py reference.json DEFECTS.md defects.json;
ring gate.ring --update; ring gate.ring` (must print OK); (5) docrecord / selfdoc / ask_probe guards; (6) commit reference + baselines,
fetch, rebase, push docs/reform:main and (after the cmdkey cure) codeberg; (7) file the wave-13 CONCLUSIONS line (the findings are in
w13_defects_stzIncident.md, w13_defects_stzScene.md, w13_defects_stzExterCode.md and part A's own file; the OIDC token-injection
finding is ALREADY filed) and the memo. Library before wave 13: 16,625 of 21,747 pass; wave 13 adds about 1,100 roots.
Still held back for good reason: the four sound classes (render to a file, never play), stzDeployment / stzBuilder / stzProcess /
stzGpu (spawn, deploy, hardware), stzTour / stzLogbook (the testoor desk's files).

## 2026-10-14: WAVE 13 COMPLETE AND ON MAIN (76793fbb4, both remotes); the STOP of 2026-10-09 is resolved

Part A turned out to be finished when it was stopped; its entries and class blocks were copied from the stopped agent's scratch
folder into doc/tools/wave/data/. Library 17,730 of 21,747 pass (81.5 percent); gate OK; register 383 in 67 classes. Left: 4,017
roots in about 290 classes. Held back, unchanged: the four sound classes (stzSoundScore 49, stzSound 40, stzSoundLive 39,
stzSoundUniverse 38, stzSoundGraph 31: render to a file, never play), stzDeployment / stzBuilder / stzProcess / stzGpu (spawn,
deploy, hardware), stzTour / stzLogbook (testoor's). Next wave: python tools/wave/class_rank.py or the by-file ranking one-liner
in the session history: rank unpassed roots by file; take ~1,000 in three or four file-disjoint groups; prompt =
doc/tools/wave/WAVE_PROMPT_NEUTRAL.md with the data file prefix changed (w14_), own scratchpad subfolder per agent, kill by PID.
Lesson: a stopped agent's scratch folder holds its entries; look there before redoing work.

## 2026-10-14, evening: WAVE 14 ON MAIN (ee46c9fce, both remotes) -- the sound classes are done without a device

69 classes, 1,351 roots. Library 19,079 of 21,747 pass (87.7 percent); gate OK; register 426 in 83 classes. TAIL: 2,668 roots in
about 190 classes, none above 20 unpassed. The sound recipe that worked (kept in the wave-14 S prompt in this session; the rule is
in the CONCLUSIONS line): never open an audio device or the microphone; render to buffers and WAVs in a scratch folder; check frames,
sample rate, peak; capture mode for live sessions; every block says UNPERCEIVED. Still special: stzTour / stzLogbook / stzTraveller
(testoor's), stzDeployment / stzBuilder / stzProcess / stzGpu (spawn, deploy, hardware: read from the code, harmless reads only),
stzBytes (unreachable by name: the export lists two stzBytes, the real one is string/stzBytes.ring, 24 of 24). Wave 15 = the
tail by the same ranking, 4 groups of about 650 roots; after it the reform's remaining work is the long-owed human reading.

## 2026-10-15: STZLIB-DOCREFORM-01 CLOSED -- wave 15 on main (bd9af6479 + regeneration 4e84322eb), both remotes

21,693 of 21,747 roots pass checks 1-4 (99.75 percent); written 17,609 (81.0), derived 4,093 (18.8), none 45; gate OK; register 476 defects
in 99 classes; baseline = the testoor desk's 54 roots (stzTour 17, stzLogbook 15, stzTraveller 22). Cost line written (outcome delivered).
WHAT IS OWED, nothing of it mechanical: (1) a person reading ten briefs and one class page, and listening to one rendered WAV
(the perception gate is OPEN; every verdict so far is a model's); (2) the testoor desk documents its three classes in this format;
(3) stzlib works down the register (doc/DEFECTS.md, defects.json); (4) the engine DLLs of every checkout need a rebuild
(stz_stats, stz_locale, stk_locale, stz_system); (5) maintenance is the gate: a new public method needs a brief, a new dead forward
is an error; re-run `ring gate.ring --update` after a wave of documenting. To document a new class later: the neutral recipe in
doc/tools/wave/WAVE_PROMPT_NEUTRAL.md. Extractor changes of this task: meta/stzDocRecord.ring (parameter reader: matching
parenthesis, defaults stripped, :fwdargs), stzDocExport.ring (derived briefs for generated classes, findings), stzDocGate.ring
(dead-forward ratchet, findings.json).

## 2026-10-15: the stzTable fix batch is ON MAIN (a6371fceb, both remotes); register 476 -> 410

stzTable's 66 register rows are 0: 60 were STALE blocks (code already fixed by the first batch, block still said 'Raises ... today'),
6 real fixes in 9 finders (list cell searched as a named parameter) plus ToHtml / FromHtml / TransposeWithColNames / buildGrandTotal / @.
LESSON FOR EVERY NEXT BATCH: the register counts BLOCKS, not behaviour; the agent must first CALL each listed method and sort it
fixed-already / broken / needs-decision, and rewrite the blocks of the fixed ones. Two agents on two worktrees of the same file merged
cleanly when each took disjoint methods. Next by size: stzObject 28, stzCalendar 25, stzItemCS 20, stzGeoMap 18, stzMatrex 17,
stzFileManager 15, stzListOfTimeLines 14 (python on defects.json gives the full list). Prompt shape: the stzTable batch prompts
(this session) = chips text + 'call each first' + guard t0N in the class's test folder + no push/rebase/regeneration by agents.

## 2026-10-15: the stzObject fix batch is ON MAIN (a5d8dea30, both remotes); register 410 -> 382

All 28 rows were genuinely broken (none stale): 20 fixed, 8 M-suffixed leftovers documented as retired (decision owed: delete or alias to
the Q forms, per NNL_REVIEW.md 4c), ToStzListOfObjects belongs to stzListOfObjects. Method that worked for the ancestor class: call
every method on four receivers first, fix minimally, guard test/object/stzObject_defects_narrated.ring (186), then a 25-suite
regression set run by the parent on the merged tree. Next by size: stzCalendar 25, stzItemCS 20, stzGeoMap 18, stzMatrex 17,
stzFileManager 15, stzListOfTimeLines 14.

## 2026-10-15: the stzCalendar fix batch is ON MAIN (50eba44eb, both remotes); register 382 -> 357

17 of 25 rows stale, 4 stubs implemented (NextDay, PreviousDay, GoToNextDay, GoToPreviousDay), the rest documented; design question owed to the
author: Current* read the clock, not the calendar. Still broken, outside the batch: WorkingDaysBetween family R5, FirstAvailableSlot,
ContainsBusinessHours, GoToNextYear on a range. Next by size: stzItemCS 20, stzGeoMap 18, stzMatrex 17, stzFileManager 15, stzListOfTimeLines 14.

## 2026-10-16: the stzItemCS fix batch is ON MAIN (de0cdfd49, both remotes); register 357 -> 337

All 20 rows broken (none stale), all fixed; 167-assertion guard. Open: ItemQ builds stzSItem (nowhere), stzItem inherits list methods that raise,
stzListInserter kills the process past the end. Next by size: stzGeoMap 18, stzMatrex 17, stzFileManager 15, stzListOfTimeLines 14.

## 2026-10-16: the stzGeoMap fix batch is ON MAIN (52a3fd1cb, both remotes); register 337 -> 319

17 fixed, DensityPointsIn left as the author's decision (per 10000 km2 as coded). niger_density.png corrected and re-read. REMEMBER when committing a
regeneration: add doc/deadforward_baseline.txt too (gate.ring --update rewrites it). Next by size: stzMatrex 17, stzFileManager 15, stzListOfTimeLines 14.

## 2026-10-16: the stzMatrex fix batch is ON MAIN (ae8b41087, both remotes); register 319 -> 302

11 fixed, 6 stubs kept (no syntax stated: CheckRows/Cols/Pattern/Sum test nothing, CheckDiagonal/Determinant test squareness), MatchesNone = the author's
decision (test 27). Open: a nested group {(A | B) & C} drops C (needs a recursive parser). RULE for the regeneration chain: stop unless gate.ring prints OK
before any commit or push (a failing gate was pushed once and repaired). Next by size: stzFileManager 15, stzListOfTimeLines 14.

## 2026-10-16: the stzFileManager fix batch is ON MAIN (d87fc73b1, both remotes); register 302 -> 283

All rows broken (none stale); root cause = helper functions written between two classes attach to the class above. A file-writing guard used a
fixture under test/file/_fixture with a path guard and removed it. Open in stzFile.ring: InfoXT, CompleteSuffix, the stzFileAppender Q forms.
Next by size: stzListOfTimeLines 14, then the 5-10 row classes.

## 2026-10-16: the stzListOfTimeLines fix batch is ON MAIN (b5c5c1c44, both remotes); register 283 -> 269

Root cause: methods edited the COPY Lane(name) returns; fixed through _laneIndex and in-place edits. Open in stzTimeLine: UncoveredPeriods on a lane with no span,
RenameLabel case, RemovePoint by moment, Copy of blocked items. Next by size: stzCache 13, stzGraph 12, stzRegexMaker 12, stzOrgChart 10, stzRegex 10, stzStringChar 10.

## 2026-10-16: the stzCache fix batch is ON MAIN (6820f9e54, both remotes); register 269 -> 251

A half-ported class (stzStorage lives only in future/) rebuilt on the real file functions; semantics chosen by the agent: entry func|args|result, a cache starts
not activated (lookups only gated), :InMemory / :InDatabase raise. Open: the file-top StzCache / CacheActivate ... functions. Next by size: stzGraph 12,
stzRegexMaker 12, stzOrgChart 10, stzRegex 10, stzStringChar 10.

## 2026-10-16: the stzGraph fix batch is ON MAIN (aefd0fff4, both remotes); register 251 -> 239

12 broken, all fixed; LongestPath is now the HOP count (changed six tests' printed numbers). After running graph tests in _wtd run
`git checkout --` on test/_data/simple.graphml and test/graph/_add_coo.stzsim, _mycompany.stzgraf, _rt.stzgraf (they rewrite tracked fixtures).
Next by size: stzRegexMaker 12, stzOrgChart 10, stzRegex 10, stzStringChar 10.

## 2026-10-16: the stzRegexMaker fix batch is ON MAIN (47be02dac, both remotes); register 239 -> 224

13 fixed, the Quantifiers placeholders kept. Ring facts: `and` does not short-circuit; a method call inside a list literal in a return reached through a forwarding alias
exited Ring with code 1. Open for the author: MatchSameContentAs meaning (same word twice vs closing tag), flat vs nested recursion levels (retired tests).
Next by size: stzOrgChart 10, stzRegex 10, stzStringChar 10.

## 2026-10-16: the stzOrgChart fix batch is ON MAIN (8b617235f, both remotes); register 224 -> 213

8 broken rows fixed, ViewNodeWithProperties / ViewNodesWithTags kept as placeholders (all-or-any undecided). Guard 138 assertions.
Open for the author: should a vacant position keep its level colour on reset (now white)? Extractor fact: a `# TODO` comment inside an empty body joins the next block into one brief.
Next by size: stzRegex 10, stzStringChar 10, stzReactiveSystem 7.

## 2026-10-16: the stzRegex fix batch is ON MAIN (de8969673, both remotes); register 213 -> 203

8 fixed (the FindMatches family no longer skips a character, HasGroups reads the pattern, partial/recursive/explain corrected), LastError and PatternErrorOffset kept as placeholders (the engine drops the PCRE2 error). Guard 112 assertions; 124 existing regex test files identical.
Open for the author: FindPartialMatch answers 0 on no match (was an R2); PartialMatchLength counts characters. Owed to the engine: the compile error code and offset.
Next by size: stzStringChar 10, stzReactiveSystem 7.

## 2026-10-16: the stzStringChar fix batch is ON MAIN (3db385d00, both remotes); register 203 -> 193

10 rows fixed; IntroducedInUnicodeVersion only partly (emoji 6.0, rest approximate: no age data). Guard 146 assertions; 174 existing files identical. Root cause found: error/stzCharError.ring is never loaded by stzBase.ring.
Next by size: stzReactiveSystem 7, then six classes at 6 (stzOccurrences, stzImgToAscii, stzListProvidedAsString, stzListOfBytes, stzTextStream).

## 2026-10-17: the stzReactiveSystem fix batch is ON MAIN (4da3fc77c, both remotes); register 193 -> 186

7 rows fixed (the safe stop now flags the live system and the loop ends at the end of the pass; BindObjects binds the live reactive objects). Guard 38 assertions; 84 existing reactive files same exit codes. Limits kept in the blocks: a later source change does not reach the target (BindTo stores a copy), and StopSafe on a copy of the system is not seen.
Next by size: five classes at 6 (stzOccurrences, stzImgToAscii, stzListProvidedAsString, stzListOfBytes, stzTextStream).

## 2026-10-17: the stzOccurrences fix batch is ON MAIN (f60addcef, both remotes); register 186 -> 180

6 rows fixed (attribute-name drift; Removed, ReplacedWithCS, Uppercased, Lowercased implemented). Guard 91 assertions. The named form in the docs is the bare `:Of = x`, never the list literal.
Next by size: four classes at 6 (stzImgToAscii, stzListProvidedAsString, stzListOfBytes, stzTextStream).

## 2026-10-17: the stzImgToAscii fix batch is ON MAIN (eaee41336, both remotes); register 180 -> 174

The file did not parse in Ring 1.27 (braces, default parameter values, a duplicate OutputFile); it parses and works now, tested against a stand-in tool only. Guard 85 assertions. API changes for the author: Invert/NoColor/Verbose take no argument (SetInvert/SetNoColor/SetVerbose added), SetOutputFile replaces the OutputFile setter, init requires its argument. Still loaded by no loader.
Next by size: stzListProvidedAsString, stzListOfBytes, stzTextStream (6 each).

## 2026-10-17: the stzListProvidedAsString fix batch is ON MAIN (4fa606964, both remotes); register 174 -> 168

6 rows fixed on a new tokenizer; a seventh defect (Items() empty for every text) was under them. Guard 121 assertions, mutation-checked. Decisions in the class header: empty list answers 0 everywhere, TRUE/FALSE/NULL count as variable names, a nested list is a value. stzListInString has the same family of defects (not touched).
Next by size: stzListOfBytes, stzTextStream (6 each), then stzGeoField, stzGeoSamples, stzDiagram, stzGridNav (5 each).

## 2026-10-18: the stzListOfBytes fix batch is ON MAIN (0c7d57a78, both remotes); register 168 -> 162

4 rows fixed, Bits and ToStzListOfBits kept as documented placeholders (no list-of-bits class). Guard 93 assertions. Engine finding: the string-engine trim empties any content holding a lone invalid-UTF-8 byte. Nine listofbytes tests already fail identically on main (not caused by this batch).
Next by size: stzTextStream (6), then stzGeoField, stzGeoSamples, stzDiagram, stzGridNav (5 each).

## 2026-10-18: the stzTextStream fix batch is ON MAIN (0217d489b, both remotes); register 162 -> 156

6 rows fixed, plus neighbours (SetStatus, SetLocale, SetFromSocket/Process). The register premise for SetEncoding was wrong: RingQt takes a codec name. Qt loads headless here (guilib.ring first). Guard 135 assertions. A copy of the class sits in future/ untouched.
Next by size: stzGeoField, stzGeoSamples, stzDiagram, stzGridNav (5 each), then five classes at 4.

## 2026-10-18: the stzGeoField fix batch is ON MAIN (8d45d668b, both remotes); register 156 -> 151

The speck defect is an ENGINE rounding bug (sampleAt weights, classOf exact edges), worse than the register said (about 20 percent, both directions). Fixed at the library boundary (clamp to the contributing nodes, 1e-12 edge tolerance); the engine fix is owed. Guard 51 assertions by pixel count; nobody looked at a picture; the gallery PNG is stale. gg_adversarial.ring dies at line 13663 in both trees (Plastic governance), before the geo section.
Next by size: stzGeoSamples, stzDiagram, stzGridNav (5 each), then five at 4.

## 2026-10-18: SAVED STATE (power low) -- the stzGeoSamples fix batch is IN FLIGHT, not merged

main (both remotes) = docs/reform = a68310833 plus this state commit; register 151 defects in 71 classes; gate OK.
In flight: agent on worktree D:\GitHub\_wtf_gs, branch fix/gs (from a68310833), task stzGeoSamples (5 rows: ValueOf/PlaceOf range check; FitAndUse/KrigeFields/Findings Gaussian-fit runaway on trend gauges, prefer a principled bound, else Findings ERROR so IsSound is FALSE, never clamp). Nothing of it is pushed.
RESUME: (1) check `git -C /d/GitHub/_wtd log fix/gs --oneline -3` and D:\GitHub\_wtf_gs for the agent commit(s); if there are none, relaunch the batch from the task text above (worktree: `git worktree add -b fix/gs2 /d/GitHub/_wtf_gs2 <main>` then copy libraries/stzlib/engine/zig-out/bin/*.dll from _wtd). (2) merge fix/gs into docs/reform, run the reflect guards + test/geo/stzGeoSamples_defects_narrated, regenerate (export_reference.ring, mk_defects.py, gate.ring --update, gate must print OK or STOP), commit with explicit paths, rebase, push origin and codeberg (cmdkey cure on codeberg failure), verify both remotes equal, file CONCLUSIONS + state + memory, remove the worktree.
Leftover: D:\GitHub\_wtf_ts is an empty folder held open by an unknown process (harmless; delete after a restart).
Next after stzGeoSamples: stzDiagram, stzGridNav (5 each), then stzConstraint, stzListChecker, stzListOfPairs, stzTree, stzStringSplitter (4).

UPDATE (same day, still saved): the stzGeoSamples agent FINISHED. Its work is ONE commit 35b32d89a on branch fix/gs (worktree D:\GitHub\_wtf_gs), not merged, not pushed. Agent report: ValueOf/PlaceOf answer empty ("" / [ ]) for an out-of-range position (stzGeoMap house convention); Findings has a new ERROR rule the_estimate_is_inside_the_data (estimate beyond the data spread on either side => IsSound FALSE, message names FitAndUse(:Spherical)/:Exponential or detrending), no clamp, fit not bounded; guard test/geo/stzGeoSamples_defects_narrated.ring 76 assertions; well-behaved control byte-identical to main (172,633 bytes); regression identical. Decisions for the author: should the fit itself ever be bounded (nugget floor / engine guard in StzEngineGeoKrigeField / KrigeAt)? Stale texts to fix by their owner: doc/gallery/stzGeoSamples/kriging_on_a_trend.ring caption, doc/gallery/FINDINGS_geo.md lines 15 and 23. gg_adversarial dies at line 13663 in both trees (Plastic governance).
RESUME = merge fix/gs (git merge --no-edit fix/gs in _wtd), run the reflect guards + test/geo/stzGeoSamples_defects_narrated, regenerate with the gate-OK stop, push both remotes, file CONCLUSIONS + state + memory, remove the worktree.

## 2026-10-18: RESUMED. The stzGeoSamples fix batch is ON MAIN (540ae326c, both remotes); register 151 -> 146

ValueOf/PlaceOf answer empty outside the set; Findings flags an estimate that leaves the data spread as an ERROR (IsSound FALSE); the fit is NOT bounded and nothing is clamped (author may overrule: a bound needs an engine guard). Limit: above 200 gauges nothing is probed. Guard 76 assertions; control byte-identical. The earlier SAVED STATE section is superseded: no batch is in flight.
Next by size: stzDiagram, stzGridNav (5 each), then five at 4.

## 2026-10-19: the stzDiagram fix batch is COMMITTED on docs/reform (d17012c6c) but NOT PUSHED: the network is down

github.com and codeberg.org were unreachable on port 443 (21 s timeouts). PUSH WHEN THE NETWORK RETURNS: `git -C /d/GitHub/_wtd push origin docs/reform:main`, then `git push codeberg docs/reform:refs/heads/main` (cmdkey cure on an auth failure), then verify `git ls-remote` equals `git rev-parse docs/reform` on both.
Register 146 -> 141 in 69 classes; 5 rows fixed (PenWidth, NodesWith, propertiesLegend, SaveToStzDiagInFolder, Explain). Guard 72 assertions. Unfixed siblings: the other SaveXxxInFolder aliases call methods that do not exist; stzGraphQuery refuses a stzDiagram (IsStzGraph tests classname).
Next by size: stzGridNav (5), then five at 4.

UPDATE 2026-10-19: the network returned; the stzDiagram batch is PUSHED (c6a4001bb on both remotes). No unpushed work. The stzGridNav batch is in flight on fix/gn (worktree D:\GitHub\_wtf_gn).

## 2026-10-19: the stzGridNav fix batch is ON MAIN; register 141 -> 136

5 rows fixed, and init had masked eight more defects (swapped direction codes, no bounds check in SetPosition, ResetPosition cleared the grid, one global engine grid shared by all objects, a panic on out-of-range numbers). Guard 156 assertions. Positions 0-based; the class keeps its documented direction order and converts to the engine's. Engine owes a bounds check in stz_grid_set_pos and a per-grid handle.
Next by size: stzConstraint, stzListChecker, stzListOfPairs, stzTree, stzStringSplitter (4 each), then five at 3.

## 2026-10-19: main was REWRITTEN on both remotes (every hash changed); docs/reform follows it

origin/main and codeberg/main moved from c6a4001bb to c578e50d5 with the same commits under new hashes (history rewrite; only five root files differ). Done without force: rebase --onto origin/main of my 3 new commits, then a fast-forward push; main = 44abd69f7 on both. Old tip kept as local branch backup/docs-reform-before-rewrite (097da0557). Hashes quoted in older sections of this file are PRE-REWRITE. reference.json header commit will refresh at the next regeneration. If a push is ever refused as non-fast-forward: fetch, check `git merge-base docs/reform origin/main` (if it is 5d784fcd7 the history was rewritten again) and use `git rebase --onto origin/main <last-known-main-commit> docs/reform`, never a plain rebase and never a force push.

## 2026-10-19: the stzConstraint fix batch is ON MAIN; register 136 -> 132

4 rows fixed (IsConstraint called a method that no longer exists; Name never assigned; Expression read the wrong variable; CheckConstraint swallowed the error). New: SetName override, Verdict, LastError. The condition text is executed as Ring code: trusted sources only. The constraint keeps its own copy of the object. Guard 82 assertions.
Next by size: stzListChecker, stzListOfPairs, stzTree, stzStringSplitter (4 each), then six at 3.

## 2026-10-19: the stzListChecker fix batch is ON MAIN; register 132 -> 128

4 rows fixed at the library boundary. Root cause is the engine bridge: Ring-callable ContainsCS/FindCS/CountCS take a value handle that no Ring-reachable constructor supplies. Engine owes: list case flag, int/float tagging, Unicode folding, a Ring-callable contains for numbers and lists, and a panic on whole numbers beyond 64 bits. Guard 115 assertions; 61 existing files identical.
Next by size: stzListOfPairs, stzTree, stzStringSplitter (4 each), then seven at 3.

## 2026-10-19: the stzListOfPairs fix batch is ON MAIN; register 128 -> 125

3 of 4 rows fixed (+ AreAnagramsCS); ToStzSetOfSections stays: its cause is in stzSetOfSections.ring (the constructor checks with @IsSetOfSections, an empty body, so it refuses every list). Decisions: only pairs of whole numbers expand; the empty list is a list of sections; AreAnagrams means every pair. Guard 82 assertions.
Next by size: stzTree, stzStringSplitter (4 each), then eight at 3; stzSetOfSections is the natural follow-up.

## 2026-10-19: the stzTree fix batch is ON MAIN; register 125 -> 121

The four rows were Not-yet-implemented stubs, now implemented from the stzList siblings: an item is a leaf, every occurrence goes, nodes and root stay, absent item is a no-op, type-strict, CS forms fold with StzLower. Guard 91 assertions. Gate lesson: a nested forwarding alias without `return` is read as an undocumented root (doc-floor error); write it with return so it folds. Unfixed siblings listed in CONCLUSIONS (FindThisItem has no return, FindTheseItemsCS indexes wrongly).
Next by size: stzStringSplitter (4), then nine at 3.

## 2026-10-19: the stzStringSplitter fix batch is ON MAIN; register 121 -> 117

The register diagnosis was wrong: the engine returns ONE piece per entry (length-aware), not a NUL buffer; the wrapper took one piece for the whole cut. Fixed in the library by calling the before and after entries and rebuilding the cut. Guard 108 assertions pinned to Python partition/rpartition. stzString.Partition has its own absent-separator bug (phantom cut), not touched.
Next by size: twelve classes at 3 (stzHtmlBuilder first).

## 2026-10-19: the stzHtmlBuilder fix batch is ON MAIN; register 117 -> 114

One cause: the current node was a copy. The document now lives in parallel lists inside the builder and current is a node number (CurrentPath gives child indexes). New: SetCurrentPath, CurrentPath, GoToLastChild, GoUp, GoToRoot, NodeCount. Guard 132 assertions. test/html/05 changed on purpose (empty line -> real output); stzGeoField failed once under load and passed five times after.
Next by size: twelve classes at 3 (stzGraphComparison first).

## 2026-10-19: the stzGraphComparison fix batch is ON MAIN; register 114 -> 111

3 rows fixed (Content empty body; the cycle field holds TRUE/FALSE text but WithCycles/WithoutCycles tested 1/0), plus Recommend (the acyclic bonus was never given) and ByMetric (text columns raised R41). Edited only inside the class region of graph/stzGraph.ring. Guard 81 assertions. One existing test output changed on purpose (graph/72 WithoutCycles). stzGraph._GenerateExplanation has the same text-versus-number mistake, not touched.
Next by size: twelve classes at 3 (stzWorkflowSimulation first).

## 2026-10-19: the stzWorkflowSimulation fix batch is ON MAIN; register 111 -> 108

The class had no init, no @aChanges and no @oGraph. Added init and a validated, atomic recording in OptimizeStep / ReassignStep / ParallelizeSteps; added Changes() and Apply() to prove effects (hand-computed on a 5-step workflow). ParallelizeSteps is recorded but has no effect: its private applier is an empty stub and the fork/join semantics are the author's decision. Guard 128 assertions.
Next by size: twelve classes at 3 (stzListWalker first).

## 2026-10-21: the two stzWorkflowSimulation decisions are implemented (on the author's delegation)

ParallelizeSteps now has its effect (side by side: member-to-member edges removed, outside predecessors and successors rewired, no duplicate edges; Apply refuses steps linked through another step and restores the graph). Q forms added for the three recorders; a chain written as one expression runs on its starting simulation, a stored Q result is a copy. Guard 128 -> 245. Found in stzGraph (not touched): the edge index goes stale after removing the last edge then adding one without EdgeExists; plain copies of a workflow share engine handles, use Copy().
Next by size: twelve classes at 3 (stzListWalker first).

## 2026-10-21: the stzListWalker fix batch is ON MAIN; register 108 -> 105

stzListWalker is a planner of walks, not a cursor walker; its registry holds named stzWalker objects (a list of [lowercase name, walker] pairs). @aWalkers declared; AddWalker also wrapped a number step into a list. Chained calls on a returned registry member bypass the copy (fixed by returning through a local). Guard 134 assertions.
Next by size: twelve classes at 3 (stzSet first).

## 2026-10-21: the stzSet fix batch is ON MAIN; register 105 -> 102

Subsets, SubSetsOfNElements and NumberOfSubsets implemented (power set by size then position; cap 65536 subsets, Subsets raises beyond 16 items; NumberOfSubsets is 2^n without listing). stzSetError was defined nowhere and is now defined inside stzSet.ring. UnionWithMany/UnifyWithMany/IntersectionWithMany fixed. Guard 88 assertions.
Next by size: twelve classes at 3 (stzChainOfTruth first).

## 2026-10-22: the stzChainOfTruth fix batch is ON MAIN; register 102 -> 99

Containing/ContainingNo no longer build condition text (a private pvtHolds tests directly, text via stzString.Contains, list via stzListChecker.ContainsItem); Nth returns a new chain and checks the rank before calling the engine (NthLetterOf(-1, ...) crashes stz_string.dll). Ordinal suffix quirks (11st, 12nd, 13rd) documented, not changed. Several other chain methods still fail (IsNot family, IsNotA, IsA call form, _Which, _But, _@): listed in CONCLUSIONS. Guard 140 assertions.
Next by size: stzChainOfValue (3) and eleven more at 3.

## 2026-10-22: the stzChainOfValue fix batch is ON MAIN; register 99 -> 96

IsANumber, IsAList and IsAnObject answer a plain 1 or 0 by the live Ring type (the convention of the working IsAString); six more failures of the same shape fixed (Q forms raised R19, _Type was read once at build time, ToStzObject on a number, Do_, ThisValue, Update). Exactly one of the four type predicates holds per value on an 18-value table. Not done: the Q / Not / alias family for list and object (new API). The initiators share flags across the process (by design). Guard 163 assertions.
Next by size: ten classes at 3 (stzEntity first).

## 2026-10-22: the stzEntity fix batch is ON MAIN (code and guard), the reference is NOT regenerated: the doc gate fails on main

Commit fe871d7e2 (model flow) added six classes with no briefs: stzFaculty 26, stzFlow 24, stzParcel 15, stzRequirement 11, stzModelPlan 11, stzModelRegistry 8 = 95 doc-floor errors from `ring gate.ring` in base/doc. A regeneration cannot be committed while the gate fails, so reference.json, DEFECTS.md, defects.json and the baselines are stale (register shows 96 defects in 57 classes; real count 93, stzEntity fixed). To resume: either the owner of the model-flow classes writes the briefs, or run a documentation wave on those six classes (comments only, strip-checked), then regenerate (export_reference.ring, mk_defects.py, gate.ring --update, gate must print OK) and commit the outputs. stzEntity: HasName/IsOfType compare both sides through StzLower (case-insensitive, accents fold); IsEmpty ignores name, type and created. Guard 91 assertions.
Next by size after that: nine classes at 3 (stzListOfObjects first).

## 2026-10-22: wave 16 (the model-flow classes) is ON MAIN and the doc gate is GREEN again; the reference is regenerated

stzFaculty 26, stzFlow 24, stzParcel 15, stzRequirement 11, stzModelPlan 11, stzModelRegistry 8 = 95 roots documented (comments only, strip-checked, exercised with stand-ins, never with a real model). The blocker recorded in the section above is closed: reference.json, DEFECTS.md, defects.json and the baselines are regenerated and the register reads 93 defects in 56 classes. Defect D1 for the owner: StzRunImplementation writes through its by-reference paParams, so defaults merge into the caller list and grow it on every call (plain-list defaults); the other findings D2 to D5 are in w16_defects_modelflow.md.
Next by size: nine classes at 3 (stzListOfObjects first), then five at 2.

## 2026-10-22: the stzListOfObjects fix batch is ON MAIN; register 93 -> 90

init uses the global IsListOfObjects (stzList has no such method), Content returns @aContent, Copy works. The holder keeps its own copies; a chained call on an element of Content() still reaches the holder's own object (documented; closing it would copy the list on every call: a decision). Guard 68 assertions. Same row-1 shape in stzListOfNamedObjects (IsListOfNamedObjects does not exist) and in StzAreBothListsOfObjects (stzFuncs.ring ~5308).
Next by size: eight classes at 3 (stzTimex first), then six at 2.

## 2026-10-22: the stzTimex fix batch is ON MAIN; register 90 -> 87

Same slip as stzTablex: @StzMid is count-based but the parser passed end positions; an in-class _Mid(s,n1,n2) helper fixes all 16 slices. An instant must be a date text (StzIsDateTime/StzIsDate). Eight sibling defects fixed (negation, bare count, set constraint, group brackets, MatchAsYouBuild/CouldMatchWithMore as a prefix test, MatchedParts, TargetSet, ExtractMatches). Guard 262 assertions. STALE ENGINE: the DLLs in D:\GitHub\_wtd date from 10-04 and lack StzEngineJsonEncodeString (RX1), so stzMatrex_defects_narrated stops at 133 pass + 1 FAIL until the engine is rebuilt; do not read that as a library regression.
Next by size: seven classes at 3 (stzSoundLive first), then seven at 2.

## 2026-10-22: the stzSoundLive fix batch is ON MAIN; register 87 -> 84

WaitCycles no longer hangs in capture mode (target capped to the buffer, plus a monotonic deadline); Landings versions never go back; CaptureInsteadOfDevice validates its length. UNPERCEIVED: nobody has heard it; no device or microphone was opened. Guard 134 assertions. Open decision: restart after Stop leaves HeardCycle and the loops' counters stale. More stale-engine symptoms: the stzHtmlBuilder guard now fails on stzenginehtmlneutralizebidi (same cause as stzMatrex).
Next by size: six classes at 3 (stzCoeffExtractor first), then eight at 2.

## 2026-10-22: the stzCoeffExtractor fix batch is ON MAIN; register 84 -> 81

evaluateExpression passed a list to ManyReplaced (one text): empty formula, R42. The text is now judged by the new translateExpression (exact grammar: numbers, declared variables, + - * /, parentheses, commas, pow sqrt abs min max) and rebuilt from tokens; 79 hostile strings never ran, a canary stayed 0. Guard 428 assertions. SILENT WRONG ANSWERS still open in the plain linear path of extract (x + 2*x gives 1, should be 3; xx vs x), recommended follow-up. stzSoundLive guard passes 134 but exits 139 at teardown (same on main).
Next by size: five classes at 3 (stzDataSet first), then nine at 2.

## 2026-10-23: the stzCoeffExtractor.extract wrong-answer defect is FIXED and on main (not a register row)

extract read coefficients by scanning the text (x found inside xx, a factor outside parentheses missed, repeated occurrences not added): the old code got 187 of 200 random linear expressions wrong, the new one 0. extract now judges the text and evaluates it at 16 points (one eval loop), falls to numericalDerivative for non-linear input; an undeclared name in the text is read as one more variable (test 18, and the solvers build the extractor with no names). Guard 920 assertions. Check stzLinearSolver's own extractCoefficient (about line 897) against the same generator in its batch.
Next by size: five classes at 3 (stzDataSet first), then nine at 2.

## 2026-10-23: the stzDataSet fix batch is ON MAIN; register 81 -> 78

NonParametricCorrelation takes the other data set; the rank correlation now averages tied ranks (the engine function is exact only without ties: 0.825 against the true 0.8207826816681233); MutualInformation counts pairs of integer ids instead of text joined with an underscore; PlanSummary read oPlan instead of the plan it built. Seven arity-drift methods fixed by the sweep (935 calls, 0 errors). Guard 146 assertions. The machine was heavily loaded by another session's zig builds: reflect guards took 4, 2.5 and 8 minutes; use generous timeouts (590 s) for them.
Next by size: four classes at 3 (stzLinearSolver first), then nine at 2.

## 2026-10-23: CODEBERG IS SEVEN COMMITS BEHIND (GitHub is current)

origin/main = 4d066c5e3 and is current; codeberg/main stays at e82e31037. Pushing to Codeberg fails with 'the remote end hung up unexpectedly' / 'unexpected disconnect while reading sideband packet', even for the single commit 870cbacc0 (the author's 'PDF reader round 7 on golden_v8': 128 files, 10,535 inserted lines of results TSVs), also over HTTP/1.1 with a 500 MB postBuffer. Every commit after it, including the six stzDataSet commits, depends on it. Retry later with `git push codeberg docs/reform:refs/heads/main`, or push 870cbacc0 first and the rest after; if it keeps failing the pack (262 MB repository) or the Codeberg connection is the limit, and the author's call is whether to trim the results data.

UPDATE 2026-10-23 (later): CODEBERG IS CURRENT AGAIN. The push of 870cbacc0 alone, then of docs/reform, succeeded on the next attempt; origin, codeberg and docs/reform all read 15ab705af. The failure was transient (a dropped connection), not a size limit. The section above is historical.

## 2026-10-23: the stzLinearSolver fix batch is ON MAIN; register 78 -> 75

A real depth-first branch and bound over the class's own simplex (proved against a brute-force oracle on 40 random problems and 8 hand-solved LPs) replaced the honesty guard; CalculatePenalty lost a stray line; the genetic solver kept the worst candidate when minimising; round() with one argument is nonsense (use floor(v+0.5)). SECURITY: the solver ran raw eval on text and a function call ran (canary 1); text is now judged (R17). extractCoefficient had the extractor's bug (67 of 200 wrong, 200 of 200 now). Guard 555 assertions. A global side effect to decide: stzCoeffExtractor.init sets the display precision to 4 for the whole process.
Next by size: three classes at 3 (stzStringChecker first), then nine at 2.

## 2026-10-23: the four decisions taken on the author's behalf are ON MAIN

stzSoundLive restarts clean after Stop (and its guard no longer exits 139: a sound stream still running at process exit crashes the process, an ENGINE-side defect, the guard releases its session); stzEntity.ContainsPropertyOrValue falls through to ContainsValue for a non-text; stzChainOfTruth ordinals follow the English rule (11th 12th 13th); stzDataSet.ExecutePlanXT treats a numeric 0 as quiet. Guards: Sound 195, Entity 108, ChainOfTruth 202, DataSet 185. The full list of decisions kept, declined and left for the engine owner is in CONCLUSIONS (K1-K8, N1, E1-E8).
Next by size: three classes at 3 (stzStringChecker first), then nine at 2.

## 2026-10-24: the stzStringChecker fix batch is ON MAIN; register 75 -> 72

HasLeadingChars / HasTrailingChars / HasLeadingAndTrailingChars compared two engine handles (new numbers on every call, never equal); they now compare the two characters with StzMid and strcmp and agree with stzString on all 55 texts of the table (36 disagreeing texts before). Bigger finding, not fixed: 35 disagreements between stzStringChecker and stzString on other predicates (IsCapitalcase, prefixed numbers, decimal and real numbers, IsListInString) -- two classes with different semantics, one decision per family. Guard 72 assertions.
Next by size: two classes at 3 (stzStringPerformer first), then ten at 2.

## 2026-10-24: the stzStringPerformer fix batch is ON MAIN; register 72 -> 69

Perform and PerformOn wrote nothing back (the engine call's result was dropped); they now rewrite the text consistently with Yield / YieldOn (35/35 and 28/28 pairs). The expression is evaluated by the ENGINE, never by Ring eval (R17 holds, canary 0 over 39 hostile strings). ENGINE: the expression compiler overflows the process stack on deep nesting (about 7000 parentheses kill the process; stzString.YieldCharsW and the list W forms are exposed too; a 2000-character limit is the boundary fix here) and upper()/lower() are ASCII-only. Guard 98 assertions.
Next by size: one class at 3 (stzStringText), then eleven at 2.

## 2026-10-24: the stzStringText fix batch is ON MAIN; register 69 -> 66; no class has 3 rows or more any more

OnlyScript, OnlyArabic and OnlyLatin: the anonymous function could not see its parameter (a Ring lambda is a global function) and ConcatenateQ no longer exists; now an index loop and a join through a private _ScriptPart. OnlyScript is strict (common characters dropped); OnlyLatin and OnlyArabic keep common characters and collapse whitespace (the old intent); combining marks follow the character before them. The register holds 66 defects in 47 classes: 19 classes with 2 rows, 28 with 1. Guard 85 assertions.
Next by size: the classes at 2 (stzAppServer first), then those at 1.

## 2026-10-24: the stzAppServer fix batch is ON MAIN; register 66 -> 64

Use and Static stored their lists and nothing read them. Middleware now runs before routing (registration order, segment boundaries, a continue convention defined); Static serves a folder with a whitelist from the engine directory listing (78 hostile paths, the secret never leaks). OPEN SECURITY GAP, ENGINE-SIDE: a Windows junction (or hard link) inside the served folder is followed, the engine lists it as an ordinary folder; serve only folders nobody else can write to until the engine can resolve or classify links. Guard 222 assertions. Also left: _Dispatch's outer catch leaks the raw error text of a failing route handler.
Next by size: 18 classes at 2 (stzDate first), then 28 at 1.

