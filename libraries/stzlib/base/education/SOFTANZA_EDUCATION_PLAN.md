# The Softanza Learning System -- Plan

> Companion to `CHARTER.md`. Plane `stzlib-education`. E0 RATIFIED 2026-09-23 as proposed, against `main` `04cff1c34`.
> Every phase has a **definition of done that a guard can prove**. A phase that is done in prose only is not done.

## A. The Zin contradictions, in full

The Zin sources were read on 2026-09-23 and were not modified. The abbreviations are:

- **PM**: `zin/doc/learning/ZIN_PEDAGOGICAL_MODEL_v1_0.md`
- **LP4**: `zin/doc/learning/ZIN_LEARNING_PROGRAM_v1_4.md`
- **ZD**: `zin/doc/spec/dsl/ZINA_DESIGN_v1_0.md`
- **JV**: `zin/doc/learning/ZINLAND_JUNIOR_VISION_v1_0.md`
- **BOOK**, **KIDS**, **GAME** and **SKL**: `zin-website/zin-book.html`, `zinbook-kids.html`,
  `zinaland-game.html` and `zin-skillset.html`

| Topic | What each document says |
|---|---|
| **Skill count** | PM: 42 (l.8, 50). LP3: claims 42, and its families sum to **50**. LP4: claims 43, its families sum to **51**, and Family V is listed twice (l.1459, l.1733). SKL: claims 44, its list sums to 50, and its data holds **55** entries. |
| **Same code, two skills** | TP-10 is the ZinaCode IDE in LP4 and the Zui compiler in SKL (l.2159) |
| **Levels** | F/P/E (LP, SKL) · Z0 Explorer to Z4 Master (PM l.316) · 7 XP levels from Seedling to Professional (ZD l.587) · 4 ZinaPath tracks (ZD l.687) · "practitioner → architect → contributor" (DRM) |
| **Stages** | PM: 3, Encounter / Declaration / Governance (l.80–98). LP4 path E: 4, with "Declaration" twice and Z0 placed in stage 2, where PM puts it in stage 1 (l.2215–2240). |
| **Age bands** | Junior 7–12, ZinaCode 12 to adult, book 14+ (PM) · 10–15 (JV, GAME) · 13–19, 18–25, 25+ (ZD) · none stated (KIDS) |
| **Profiles** | PM: 5, and its own description of the book swaps one (l.62–68 vs l.178). ZD: 5 different ones. LP4: paths A–F. BOOK: 7. SKL: 6, plus an unlisted "lead". |
| **Pillars** | 56, 53, 52 and 38, sometimes within one line (PM l.44) |
| **Chapters** | BOOK says 12 and its code computes 22. KIDS says 7 and lists 6. |
| **Profile effect** | PM says the profile changes the book. BOOK adds a one-line note and nothing else (l.983–991). |

**What is pre-baked in Zin** is listed so that nothing like it is copied:

- BOOK's Run button prints a hard-coded `OUT` table with invented timings (l.2654, l.1206), while claiming
  to be the real toolchain's output (l.983).
- GAME checks a fill-in answer with `val === ans` (l.2556).
- GAME's overlay "download" is an 800 ms `setTimeout` that changes nothing, and its own comment says so
  (l.3036).

## B. The skills, drafted for ratification (D1)

The list has **25 skills in 7 families**. It is derived from constructs that exist and are guarded in
stzlib, so that every level can name a guard. It uses Zin's format plus an **evidence** field.

| Family | Skills |
|---|---|
| **I · Formulate** | FO-01 State the problem as keywords (mental model, step 1) · FO-02 Decompose into walk / ask / produce / act · FO-03 Abstract to one object over any structure · FO-04 Declare what, not how |
| **II · Express** | EX-01 Select the object · EX-02 Ask before acting (Contains, Count) · EX-03 Find, then apply · EX-04 Read a function name as a sentence (active / passive / fluent) · EX-05 Program in your own language (`NaturallyIn`) |
| **III · Patterns** | PA-01 Recognise text patterns (regex) · PA-02 Recognise structure patterns (listex, tablex) · PA-03 A condition is data (`W`, rules) · PA-04 Work with tables |
| **IV · See** | SE-01 Draw an answer (`viz`, diagrams) · SE-02 Map and plot |
| **V · Know** | KN-01 Teach a world (`StzKnow`, `.zknw`) · KN-02 Question a world (`Query`, `Prove`, `WhatIs`) · KN-03 Answer the gap question (wise coding) · KN-04 Ask the library (`Ask`, `HowTo`, `ExplainMethod`) |
| **VI · Govern** | GO-01 Declare an agent (`.pia`) · GO-02 Propose, never commit (the pi-gate) · GO-03 Rehearse in a safe world |
| **VII · Craft** | CR-01 Write a narration whose every cell runs · CR-02 Guard it · CR-03 Explain a verdict (`Why()`) |

Here is one skill in full. The other 24 are written in E3.

```
knowledge "skill-ex-03"

facts
    ex-03 | is-a | skill
    ex-03 | family | express
    ex-03 | question | "Where is it, and what do I do there?"
    ex-03 | foundation | "finds the positions of one kind of item and removes them"
    ex-03 | practitioner | "chooses between the position route and the dedicated shortcut, and says why"
    ex-03 | expert | "finds under a W condition over a world the learner built"
    ex-03 | foundation-evidence | guard:elementary-03/find-then-apply
    ex-03 | study | stz-mental-mode-narration
    ex-03 | anchor | restaurant
    ex-03 | anchor | cooperative
```

## C. Phases

### E0 · Charter (this document and `CHARTER.md`)

**Done when** the author has ratified the charter, with decisions D1–D5 answered or explicitly deferred.
No code is written before that.

### E1a · Vertical slice, verified on the desktop

**The slice is one chapter, "Find, then apply"**, built from the mental-model narration. It runs over the
`restaurant` world and is written in en · fr · ar · ha.

**Deliverables:**

- `stzProgram`, `stzCourse`, `stzChapter`, `stzExercise`, `stzOverlay`, `stzLearner` and the checker, as
  far as the slice needs them and no further;
- the Ring port of the promise-matching rules;
- the reader generator;
- `base/test/education/slice_narrated.ring`.

**Done when one guard proves all six of these, from a fresh copy of the folder:**

1. Every cell of the chapter runs in all four languages, and none of them has a stored output.
2. One exercise **fails** on every file in `wrong/` and **passes** on every file in `right/`, by running
   in a fresh process.
3. One Q&A is generated by `Ask` when the guard runs, and it names a method that `HasMethod` confirms.
4. Swapping the overlay from `restaurant` to `bank` changes the world's answers, and the hash of the
   chapter file does not change.
5. The generated reader HTML contains no stored output, and each cell's **runs-where** mark matches what
   the guard observed.
6. The tutor refuses to give the answer in three adversarial scenes, and answers the gap question in one
   honest scene, with no model loaded.

**Budget (PX)**: the guard runs in **under 30 seconds**, prints its per-section wall time, and uses one
Ring process for the chapter plus one per exercise check.

**Status: DONE, 2026-09-23.** `base/test/education/slice_narrated.ring` passes 64 of 64 assertions, and
every positive has a negative sibling.

**The budget is missed.** Two gate runs measured 38.5 s and 31.0 s of sections, which is 34 s of wall
time with the library load. The whole cost is child cold starts (about 3 s each, 11 children). The
first version took 74 s. Running the fresh processes side by side took it to 31–39 s, and kept one
process per learner check.

**The plan for the remaining seconds** is to measure a smaller library load for learner programs. That
is a question for the plane that owns `stzBase.ring`'s load order, and it is not education's to change.

**What E1a did NOT prove**, named so that nobody counts it:

- Rule 2 of the tutor (no spoilers) needs more than one chapter; E3 tests it.
- The fr, ar and ha texts are drafts awaiting native reviewers.
- Nothing ran in a browser; that is E1b.

### E1b · The same slice in the browser (gated on `EDU-BROWSER-STZ-01`)

**Done when** the reader page, opened from a folder with no server, runs the chapter's cells and checks
the exercise in a browser, and the E1a guard's six points hold there.

**Until ringscript delivers,** the page runs the core-Ring cells it can, marks the others
`desktop`, and gives the command to run them there.

### E2 · The decision-maker demo

**Done when** the 15-minute script in §D runs end to end from a clean folder, **twice in a row**, with
nothing but Softanza.

**Status: DONE, 2026-09-24.** `base/education/demo/demo.ring` plays the eight scenes and computes every
claim while it shows it: 20 proved, 0 not proved. `base/test/education/demo_narrated.ring` runs it twice
from a clean workspace (17 of 17) and asserts the two transcripts are identical word for word, except the
one clock reading in a learner's progress file. One run takes 35–40 s; the guard takes about 75 s and is
E2's gate, run once per change to the demo. The presenter's guide is `demo/DEMO.md`.

**What E2 added to the program:** two more courses, so scene 7 is real. `zindara-missions` holds a child's
mission (Amina's customers, answerable in Hausa) and `governed-agents` holds a professional's exercise
whose submission is a `.pia` declaration judged by the library's own court. That needed one new exercise
form: a **harness** exercise, where `check.ring` names what the court runs on `%SUBMISSION%` and the
facts say `gov-01 | submits | pia`.

**What E2 did NOT prove:** the browser clause of "zero install", as decided in D4. The demo says on stage
that cells run on the desktop, and the page says it on every cell.

After E2, education asks Central to rate `base/education/` as a card on the Atlas, graded by what the
guards prove.

### E3 · Elementary Introduction, first edition

E3 ships in slices, each with its own gate:

| Slice | What | Status |
|---|---|---|
| **E3a** | The spine: 25 skills as `skills/<id>.zknw` + `<id>.<lang>.md`, the curriculum (15 chapters, `trains`, `requires`), the levels S0–S4 with a brief per project, and `spine_narrated.ring` | **DONE 2026-09-24**, 32 of 32 |
| **E3b** | Chapters 2–6, the Formulate and Express families, each in four languages with one exercise proved by wrong and right answers, and `course_narrated.ring`, the gate over every shipped chapter | **DONE 2026-09-24**, 90 of 90 |
| **E3c** | Chapters 7–11, Patterns and See (conditions as data, patterns in text, in lists and numbers, tables, drawn answers), each in four languages with proved exercises; a chapter menu in the reader | **DONE 2026-09-24** |
| **E3d** | Chapters 12–15, Know, Govern and Craft (teach a world, the gap question, an agent that cannot hurt, write a narration), each in four languages with proved exercises; all fifteen chapters now ship | **DONE 2026-09-24** |
| **E3e** | The Zindara missions (3 missions × 3 steps, each a checked exercise, one answerable in Hausa) and the five level projects, each with a `guard.ring` proved against wrong and right sample folders; a learner earns a level only when every exercise of its chapters and its project have passed with matching evidence | **DONE 2026-09-24**, missions 32/32 · levels 35/35 |

**What E3a settled.** The curriculum is the PLAN and `course.zknw` is what SHIPS; the spine guard prints
the planned chapters not yet written by name (14 of 15) and never counts them as shipped. A skill's text
lives in one file per language with machine keys (`question:`, `foundation:`, ...) so a missing language
is red, not filled from English. A level is earned only by a project with a `guard.ring`; none has one
yet, and the guard says so (5 of 5).

**Two limits of `.zknw` as a manifest, found by the spine guard:** an object is a node id, so it may hold
no space (a sentence goes in a `.md` beside the facts, never in the fact), and two facts may not share a
node pair (the craft skills' practitioner and expert evidence had to name different projects).

**What E3b settled.** The course gate (`course_narrated.ring`) runs every shipped chapter in all four
languages, in fresh processes, and proves every exercise; a scoped run (`ring course_narrated.ring
<chapter>`) prints the chapters it skipped by name. Editions of a chapter may word a cell in their own
language, but must make the same promises cell for cell. Every cell was probed before its promise was
written, and the probe found **three dead promises in the shared narrations** (`AllRemoved`,
`IsNotUppercase`, `Wk`, which do not exist on this build) and that **`stzWalker` lives in the `max`
tier**, not in `base`; chapter 6 therefore teaches the four moves on `base` alone and says so. The gate
costs 120–180 s for six chapters, all of it fresh-process cold starts, and is run once per change.

**What E3c settled.** Two more narration promises are dead on this build and were routed with the
others: `stzRegexMaker`'s builder (`4Times()`, `DefineGroup`) and the listex claim that `[@N1-3, @S]`
refuses `[4, 5, 6, "extra"]` (three numbers do satisfy one-to-three; four do not). Chapter 8 therefore
teaches patterns written by hand and says why the builder is not shown. Two rules for authors, paid for:
**probe a cell from a file, never through `eval`** (a backslash reads differently), and **`stzNumbrex` is
used through a variable**, since `new stzNumbrex(...).Match()` inline raises. The reader now shows one
chapter at a time per language, with a chapter menu; the hash is `lang:n`.

**What E3d settled.** Chapter 14 rehearses a real file write in the agent's workbench and commits it only
through a PI actor inside a scope; a `learn`-only agent yields an empty plan, so that lesson needs a write.
Chapter 15 hands the learner the course's own instruments (`StzChapterQ`, `stzExerciseCheck`), which means
a chapter cell may itself spawn a check: scratch file names now carry the process id so a child never
collides with its parent's running script. The govern skills' evidence moved to chapter 14's exercises
(`ex-14-01..03`); the `governed-agents` course keeps `gov-01` for the demo. Two matcher facts an author
must know: a promise of `TRUE` is satisfied by any line printing `1`, and a wrong answer must therefore
print something else; and an inner `\"` inside a Ring string is not an escape, so nested code uses `'`.

**What E3e settled, and with it E3.** A level project is a folder with a brief in four languages, a
`guard.ring` that judges the learner's folder (`%PROJECT%`) by running it, a `promise.ring`, and sample
folders under `wrong/` and `right/` that the guard must refuse and accept (`stzProject.ProveItself`). The
learner's evidence for a project is the hash of every file in their folder. `stzLearner.HasEarned` is the
one rule for a level: every exercise of the chapters the level needs has passed, and the project has
passed, each with evidence that still matches; `MissingFor` names what is missing. Two more traps paid
for: inside an `if` block Ring reads the variable `oK` as the keyword `ok` (a syntax error the probe at
top level never showed), and two facts about one subject may not share an object, so a project's
last-attempt and evidence hashes carry different prefixes.

**E3 is therefore complete as the launch prompt defined it**: every cell of every chapter is pinned by a
guard in all four languages, the skills framework is written, and levels are earned by a project that
passes its guards. What E3 does not claim: the fr/ar/ha prose is reviewed (it is not), the browser runs a
cell (it does not), or the tutor's no-spoiler rule is tested (it holds trivially and is untested).

**Two defects in the shared narrations folder, found the same way and routed to its owner:** one file has
a space in its name (`stzwalker-beyond-loops-the -walker-metaphor.md`) and one a double extension
(`stztablex-pattern-langauge-for-tables.md.md`). The spine names the second as it is, and cannot name the
first at all.

- The core course in en · fr · ar · ha: the 25 skills written out, 12–16 chapters, and a kids' track of
  Zindara missions.
- Levels are earned by a project that passes its guards.

**Done when** every cell of every chapter is pinned by a guard in all four languages, and every exercise
has a sibling that must fail and one that must pass.

### E4 · Institution kit

- An overlay-authoring guide.
- Cohorts managed as folders.
- Progress and reports generated as narrations.
- Two reference overlays: a bank and a university.

**Done when** a person with no Softanza expertise builds an overlay from the guide alone, and
`OverlayReport()` plus the slice guard pass on it.

**Status: DONE, 2026-09-24**, `institution_narrated.ring` 39 of 39. What shipped:

- `OVERLAY_GUIDE.md`, an executable guide: copy `overlays/_template`, fill six placeholders, run the
  court. The guard performs those steps literally (`StzOverlayFromTemplate`) and the result must be a
  valid overlay; three broken overlays are refused with the finding named.
- `stzOverlay`, the overlay's court: findings in the house shape over the manifest, the languages, the
  worlds, added chapters and exercises, and the governance regime. The rule that matters is
  `overlay-no-fork`: a file that would replace a core chapter or exercise is refused. A CLI wraps it,
  `tools/overlay_check.ring`.
- Overlays now **merge** a `courses/<slug>/course.zknw` into the core's instead of shadowing it, so an
  overlay attaches an exercise to a chapter with one line; the reader shows it on the chapter's page.
- Two reference overlays beside the program, in `base/education/overlays/`: `bank` (a world, an approval
  exercise on chapter 7, a governance regime) and `university` (a faculty world, a knowledge exercise on
  chapter 12, a regime).
- `stzCohort`: a cohort is a folder of learners under one course and one overlay; its progress report
  is a **narration** whose every figure is a promise beside the cell that computes it, so a report run
  after the learners moved on reports its own staleness.

**A proxy, named as one.** "A person with no Softanza expertise" cannot be a guard. The guard proves the
guide's steps, executed as written, produce a valid overlay; whether the prose is clear to that person
is for the first institution to say.

### E5 · The tutor's rule 2, the gap E3 left open

E3 closed saying the tutor's no-spoiler rule "holds trivially and is untested". With fifteen chapters
it can bite, and now it does.

**Status: DONE, 2026-09-24**, `tutor_narrated.ring` 45 of 45 in about 50 s. What shipped:

- **Rule 2 is a question of position.** `stzTutor.WithCourse(oCourse)` gives the tutor the course;
  `stzLearner.ChapterOn(oCourse)` says where the learner is (the first chapter with an exercise not
  passed with evidence). A question about a chapter **ahead** is named and not explained, and ends on
  a question about the current step; a chapter **behind** is recalled in that chapter's own recap
  words (`stzChapter.RecapAchieved`, the first bullet of the last section, in the learner's language);
  only the current chapter gets the gap conversation. Without the course the tutor knows one exercise
  and the rule cannot bite; the guard proves both faces.
- **What a question is about is read from the course, not guessed.** `stzCourse.TeachesWhere(name)`
  is the first chapter whose cells call the name (`stzChapter.CalledNames`, indexed once, 0.15 s for
  fifteen chapters); failing a name, the chapter whose title words the question uses in the learner's
  language (`TitleOf`), two of them. So "How do I use KnowRelation" and "Comment enseigner un monde ?"
  both point at chapter 12, and "What is missing in my program?" points at nothing.
- The guard walks one learner through the course with **real runs**: twelve right answers submitted
  and accepted in about 35 s, and the same question asked at chapter 2 (ahead), 12 (current) and 13
  (behind), in English and Arabic.

**Two defects the guard found in rule 1's filter, both fixed.** A promised output `1` (ex-13-01) was
blanked inside "chapter 12", so the reply read "chapter ......": the filter now blanks WHOLE words
only, with word edges of either script. And a chapter number is course structure, not a promised
output, even when the digits agree (chapter 1 exists and ex-13-01 promises `1`): a rule-2 sentence is
filtered before its number and title are set in.

**Not claimed.** A title match is word-exact after lowercasing and the removal of Arabic writing marks:
a morphological variant of a title word ("أعلّم" for "علّم") misses, and the guard asks in the title's
own words. The natural module's resolver is the right home for more than that.

### E6 · Three teaching worlds (`COMPASS-CT-WORLDS-01`)

The compass ratified three `.zknw` teaching worlds -- a restaurant, a cooperative, a school. The core
world was already the restaurant (`bella-cucina`, in `worlds/workplace.zknw`); the other two did not
exist, and a learner had no way to choose a world without an institution's overlay.

**Status: DONE, 2026-09-24**, `worlds_narrated.ring` 26 of 26 in about 50 s. What shipped:

- `program/worlds/cooperative.zknw` (a farmers' cooperative on the Tillaberi plain: seed, fertiliser,
  credit, storage; who grows what) and `program/worlds/school.zknw` (a secondary school in Niamey:
  transcripts, textbooks, enrolment, certificates; which subject is taught where). `workplace.zknw`
  stays the default and is the restaurant.
- **A learner chooses a world**: `StzProgramQ(core).WithWorldQ("school")`; `WorldIds()` lists what is
  shipped; a world that is not shipped is refused with the list, never quietly the default. Resolution
  of the `workplace` role, in order: an overlay's own `worlds/workplace.zknw` (the institution's world
  IS the workplace, whatever the learner chose), then the chosen world, then the role's core file.
- **One contract for every world**, `StzEduWorldFindings(file)`: one `is-a` fact (the name the chapters
  print) and `requested` facts with at least one repeat (chapter 1 removes the duplicates, chapter 5
  counts the most requested). The overlay court's `overlay-world` rule now applies it, so an overlay
  whose world has no repeated request is refused with the reason; the guide says so.
- The guard runs the four world chapters (1, 2, 5, 12) over each new world for real -- eight runs,
  every cell ran, every promise kept -- and proves the overlay's world wins over a learner's choice.

**Not claimed.** The worlds are facts, not lessons of their own: the chapters are the lessons, and
these worlds are what they reason over. A world with prose beside it (a page per world, in four
languages) is a later slice, and would need the same native reviewers as the chapters.

## D. The demo script, 15 minutes

| Minute | What the decision maker sees | What proves it |
|---|---|---|
| 0–2 | **Zero install.** A USB folder is copied and the page is opened. | the folder holds `ring.exe`, the engine DLL, stzlib and the program. Nothing is installed. (In the browser: after E1b.) |
| 2–4 | **In their language.** The course is switched to French, then to Arabic (right to left), then to Hausa. | the same cells run in each language |
| 4–6 | **On their own world.** The bank overlay is dropped in, and the same chapter now answers about the bank's products. | E1a point 4 |
| 6–8 | **Nothing is faked.** A wrong answer fails, and the right one passes. | the checker, in a fresh process |
| 8–10 | **A tutor that asks.** A vague question gets a question back, and "just tell me the answer" does not work. | the tutor scenes |
| 10–12 | **Safe AI.** A student's agent tries to delete the folder. It proposes, the gate refuses, and the plan shows exactly what it would have done. | `GiveWorkbench`, `stzAgentGraph.IsSound` |
| 12–14 | **All levels.** A child's Zindara mission and a professional's governance exercise run on the same engine. | two guards, one runtime |
| 14–15 | **They own everything.** `git diff` on a learner's `progress.zknw`. | plain text |

## E. Requests to other planes (routed through Central)

| ID | To | Ask | Blocks |
|---|---|---|---|
| `EDU-BROWSER-STZ-01` | ringscript | Run a stzlib cell in a browser from a folder: the engine in the wasm or Ring fallbacks for the slice's calls, a baked stzlib subset, and an offline `file://` loader (the inlined wasm is untested) | E1b and the browser half of E2 |
| `EDU-PROMISE-RING-01` | stzlib meta | Take ownership of the Ring port of the `promises.py` matching rules once education has written it | nothing; this prevents drift |
| `EDU-NARRATION-01` | stznarrations | Note the chapter conventions (recap, exercise reference, runs-where) for the `.narration` migration | nothing now |
| `EDU-HAUSA-LIST-01` | stzlib natural | Add list vocabulary to the Hausa pack (`jeri` for OBJECT_LIST; `cire maimaitattu` for METHOD_REMOVEDUPLICATES), with a Hausa-speaking reviewer. Until then, `EduPrepareLanguage("ha")` merges these words at run time through `StzAddNaturalLanguage` | nothing; the supplement retires when the pack has the words |
| `EDU-RUNPATH-01` | stzlib system | `StzEngineSystemRunXT` refuses a quoted program path, so a Ring executable installed under a path with a space cannot be run | learners whose Ring is installed under a path with a space |
| `EDU-SCOPE-01` | central | Register the plane's paths in `SCOPES.md` | nothing |
| `EDU-LICENCE-01` | author | Name the licence for course content before anything ships. This was already raised by the compass. | E3 publication |

## F. Risks

| Risk | Mitigation |
|---|---|
| RingScript never runs stzlib at acceptable size or cold start (stzlib loads 277 files) | Desktop-first is fully honest under law 2. The browser gets core-Ring cells plus the runs-where mark. Measure the cold start in E1b before promising a demo in the browser. |
| The quality of Hausa and Arabic prose | Translations are data files with a named reviewer each. A guard proves that the cells run. Only a person can prove that the prose is good, and the plan says so rather than implying otherwise. |
| `.zknw` is too weak to serve as a manifest (it has no order) | The fallback in `CHARTER.md` §5.2 costs nothing |
| Checking an exercise in a fresh process costs 2–3 s of cold start | A one-process checker for trusted guard runs. The fresh process is used for learner code only. Measured in E1a. |
