# The Softanza Learning System -- Plan

> Companion to `CHARTER.md`. Plane `stzlib-education`. E0 draft, 2026-09-23, against `main` `04cff1c34`.
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

### E1b · The same slice in the browser (gated on `EDU-BROWSER-STZ-01`)

**Done when** the reader page, opened from a folder with no server, runs the chapter's cells and checks
the exercise in a browser, and the E1a guard's six points hold there.

**Until ringscript delivers,** the page runs the core-Ring cells it can, marks the others
`desktop`, and gives the command to run them there.

### E2 · The decision-maker demo

**Done when** the 15-minute script in §D runs end to end from a clean folder, **twice in a row**, with
nothing but Softanza.

After E2, education asks Central to rate `base/education/` as a card on the Atlas, graded by what the
guards prove.

### E3 · Elementary Introduction, first edition

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
| `EDU-SCOPE-01` | central | Register the plane's paths in `SCOPES.md` | nothing |
| `EDU-LICENCE-01` | author | Name the licence for course content before anything ships. This was already raised by the compass. | E3 publication |

## F. Risks

| Risk | Mitigation |
|---|---|
| RingScript never runs stzlib at acceptable size or cold start (stzlib loads 277 files) | Desktop-first is fully honest under law 2. The browser gets core-Ring cells plus the runs-where mark. Measure the cold start in E1b before promising a demo in the browser. |
| The quality of Hausa and Arabic prose | Translations are data files with a named reviewer each. A guard proves that the cells run. Only a person can prove that the prose is good, and the plan says so rather than implying otherwise. |
| `.zknw` is too weak to serve as a manifest (it has no order) | The fallback in `CHARTER.md` §5.2 costs nothing |
| Checking an exercise in a fresh process costs 2–3 s of cold start | A one-process checker for trusted guard runs. The fresh process is used for learner code only. Measured in E1a. |
