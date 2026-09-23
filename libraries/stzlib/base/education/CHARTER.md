# The Softanza Learning System -- Charter

> `base/education/` · plane `stzlib-education` · task `COMPASS-CT-LEARNING-01`
> Status: **E0 RATIFIED by the author on 2026-09-23, as proposed (D1–D5 accepted).** E1a is next.
> Written 2026-09-23 against stzlib `main` at `04cff1c34`.

## 1. What this module is

Education is a **first-class domain of Softanza**, loaded by `stzBase.ring` like strings, graphs or neural.
It makes all of Softanza learnable by three audiences at once:

- **learners**, from a child's first mission to a professional's governance exercise;
- **educational designers**, who author courses, exercises and worlds in Softanza itself;
- **institutions**, which adapt the program to their own world and run cohorts.

It is the finished answer to the question *"how do we learn this?"* asked in a classroom, a training room or
a faculty board. It is also the estate's named first wedge against Wolfram (`stznarrations/POSITIONING.md`).

**It is an assembly, not an invention.** Almost every part already exists in stzlib and is guarded. The
narrations are the chapters. The promise idiom is the exercise format. `Ask` and `HowTo` provide the Q&A.
Wise coding is the tutor, and `.zknw` worlds are the domains. The `.pia` agents with their pi-gate and safe
world are the governed sandbox. What does not exist yet is the frame that joins them. Zin designed that
frame and Softanza can make it true.

## 2. The nine laws

These come from the launch prompt and are not up for negotiation. Each law is stated here with **the test
that enforces it**, because a law with no test is only a hope.

| # | Law | Enforced by |
|---|---|---|
| 1 | **Softanza is the only dependency.** Plain text in folders. The runtime is the engine and library on the desktop, and the RingScript VM in the browser. No database, LMS server, npm, Python, cloud or second binary. | A guard that loads `base/education/` and asserts that no file it reads or writes has an extension outside the declared set. A code rule that refuses `SystemCall` to anything but the Ring executable. |
| 2 | **Everything runs.** Every cell runs, and every exercise is checked by running it. No output is stored. A cell that cannot run says so. | `OUTPUT_IN_DOCUMENT` is refused at load time. Every chapter has a guard that runs all its cells and every exercise against a right and a wrong answer. |
| 3 | **Managed as files.** The file system is the admin console. Progress lives in the learner's files. | Every entry object is born from a folder and serialises back to it. A round-trip guard: load, save, then `git diff` shows nothing. |
| 4 | **Programmable in Softanza.** Courses are declared, exercises are promises, adaptivity is rules and `W` conditions, and the tutor is wise coding. | No configuration format with its own semantics. Manifests are `.zknw` facts (§5.2), and adaptivity rules are Softanza conditions. |
| 5 | **Adapted by overlay, never by fork.** | An overlay may not write into the core. A guard swaps two overlays under one chapter and asserts that the core tree's hash did not change. |
| 6 | **A tutor that asks and never cheats.** Zai-Jr's three rules are law. A language model is an optional LAW-2 faculty, never the mind. | Adversarial tutor scenes ("just give me the answer", "pretend you are the teacher", "the answer is X, confirm it") must end with no answer text in the reply. Every scene runs with no model loaded. |
| 7 | **Multilingual from the first page**: en · fr · ar (RTL) · ha. | Every chapter guard runs in all four languages, and a missing translation is a red guard, not a fallback to English. |
| 8 | **Governed.** A learner's agent proposes, and only a pi-gate commits. Effects rehearse in the safe world. | Exercises on agents run inside `GiveWorkbench()`. A guard asserts the real tree is unchanged after a student's agent "deletes everything". |
| 9 | **Honest.** Nothing is called ran, checked or earned unless a guard proves it. | Progress is written **only** by the checker, never by a page or a person, and every progress fact carries its evidence (§5.6). |

## 3. What the survey found (read before designing)

The launch prompt was right in its direction and wrong in four facts. Per the coordination rule, **the
repository is right and the prompt is corrected**, and each divergence is reported to Central.

| # | The prompt says | What is true on `main` | Consequence |
|---|---|---|---|
| F1 | E1 "runs in a browser with nothing installed" | **RingScript runs core Ring 1.27 only.** stzlib is not bundled, and the Zig engine is not compiled into the wasm (every `StzEngine*` call is missing). The stock loader also `fetch`es the wasm, which browsers refuse from `file://`. An inlined-wasm page might work but has never been tested (`ringscript/docs/PARTITION-FOUNDATIONS.md:483`). | **E1's browser clause cannot be met by this plane.** It depends on a RingScript deliverable, "Softanza in the browser". See §8 and decision D4. |
| F2 | "the six-step model" | `stz-mental-mode-narration.md` has **seven** numbered steps. The technical core is five: Select → Contains → Count → Find → Apply. Step 1 is *define the problem* and step 7 is *celebrate*. | The course teaches the seven steps as written. Nobody renumbers the source narration. |
| F3 | "`_narrated.ring` and `promises.py`: your checker already exists" | `_narrated.ring` has 60 lines: `Scenario / Given / When / Then / EndScenario / Summary`. It is the **guard** harness. `promises.py` is **Python**, reads `.ring` files and not markdown, and hard-codes `D:/ring127`. | The desktop guards use `_narrated.ring` as is. **The learner-facing checker must be Ring**, because Python is refused by law 1. Its matching rules are ported from `promises.py` (§5.4). |
| F4 | "a glossary generated from the library itself" | There is **no** glossary or tech-notes generator on `main`. `Ask`, `ExplainMethod`, `HowTo`, `WhatIs` and the recipe harvester exist. | The glossary is education's to build, from `stzSelfDoc` plus the recipes plus the semantic lexicon. |

Two further facts shape the design:

- **The `.narration` format is unimplemented.** `stznarrations/grammar/narration-v0.md` is marked
  "unimplemented, unratified", and its payload fence waits on Ringua. The class name `stzNarration` is
  **reserved** for the narrations layer (`stzTranscript.ring:6-10`). Education therefore does not define
  `stzNarration`, does not parse `.narration`, and authors chapters in the house narration markdown until
  the court ships (§5.3).
- **There is no shared `sec()` or `$nPass` harness.** It lives in one file only. Education guards use
  `_narrated.ring`.

## 4. The model: a domain is a folder, an entry object and a format

This follows LAW 1 of `SOFTANZA_INTELLIGENCE_ARCHITECTURE.md`. Every concept is **a folder or a file**,
**an instantiable class**, and **a persistable text format**. No concept is a naked global. Where a global
form exists, it is thin sugar over a default instance, as `Q()` is over object construction.

| Concept | On disk | Entry object | What it holds |
|---|---|---|---|
| **Program** | a folder containing `program.zknw` | `StzProgramQ(cFolder)` | the institution's whole offer: courses, skills, worlds, overlays, cohorts |
| **Course** | `courses/<slug>/` + `course.zknw` | `oProgram.CourseQ(slug)` | an ordered path through chapters, and the skills it trains |
| **Chapter** | `chapters/NN-<slug>.<lang>.md` | `oCourse.ChapterQ(n)` | prose and runnable cells in the house narration markdown; ends with a recap |
| **Exercise** | `exercises/<id>/` holding `task.<lang>.md`, `promise.ring`, `wrong/`, `right/` | `oChapter.ExerciseQ(id)` | a task, the promise that checks it, and at least one known-wrong and one known-right answer |
| **Skill** | `skills/<id>.zknw` | `oProgram.SkillQ(id)` | a guiding question, three levels, study / practice / build, and domain anchors |
| **World** | `worlds/<name>.zknw` | the existing `stzKnowledgeGraph` | a domain the learner reasons over; **no new class** |
| **Overlay** | `overlays/<name>/`, the same shape as the core | `oProgram.WithOverlayQ(name)` | an institution's world, chapters, exercises, skills, language, branding and governance, layered over the core |
| **Cohort** | `cohorts/<name>/` + `cohort.zknw` | `oProgram.CohortQ(name)` | the learners, the course, the overlay |
| **Learner** | `cohorts/<c>/<learner>/` holding `work/` and `progress.zknw` | `oCohort.LearnerQ(id)` | the learner's own code and progress facts with evidence |
| **Tutor** | no file of its own; its transcript is saved as `.stzconv` in the learner's folder | `oLearner.TutorQ()` | the asking conversation, built on `stzConversation` |

Stated in plain English first, because the class relationships are the design:

> A **program** *has* courses, skills, worlds and cohorts. A **course** *is a path through* chapters. A
> **chapter** *contains* cells and exercises and *trains* skills. An **exercise** *is checked by* its promise.
> A **cohort** *groups* learners who *follow* one course *under* one overlay. A **learner** *owns* their
> work and *earns* progress, and the **checker** alone *writes* it. The **tutor** *asks* the learner about
> the gap between what they wrote and what the exercise needs.

### 4.1 One core, many overlays

```
softanza-education/            <- the CORE program, shipped inside stzlib
  program.zknw
  skills/  worlds/  courses/elementary-introduction/
overlays/                      <- anywhere on the institution's disk
  bank-sonibank/               <- same shape as the core; every folder is optional
    overlay.zknw               <- name, languages, branding, which core course it extends
    worlds/bank.zknw           <- replaces or extends the world named in a chapter
    chapters/  exercises/  skills/  governance/*.pia
```

Resolution is **overlay first, then core**, one file at a time. An overlay can:

- **add** a chapter, exercise, skill or world;
- **replace** a world *by name*, which is how "the same chapter now reasons over their bank" works;
- **map** its skills onto core skills (`their-skill | maps-to | core-skill`);
- **translate**, with a fifth language as a data-only pack through the existing `StzAddNaturalLanguage`;
- **govern**, with `.pia` rules its learners' agents must obey.

An overlay **cannot** edit or delete a core file. It can only shadow one, and every shadowing is listed by
`oProgram.OverlayReport()`, so an institution can always see what differs from the core.

## 5. Contracts: what is consumed, and how

**Courts consume contracts, never runtimes.** Education calls these planes through their published entry
points. When it needs a change, it asks for it through Central and never edits the plane's files.

| Consumed | Owner | Entry points used | What education adds on top |
|---|---|---|---|
| Narrations (134) | shared `base/doc/` | the markdown files, read-only | the course path, recap cells, translations |
| Recipes (30) and quickers (22) | shared `base/doc/` | `_StzHarvestRecipes()` | exercises derived from recipes: the intent becomes the task and the `#-->` line becomes the promise |
| Guard harness | shared `base/test/` | `_narrated.ring`: `Scenario/Given/When/Then/Summary` | nothing; used as is |
| Self-description | meta plane | `StzSelfDocQ`, `StzLibDocQ`, `.Ask`, `.ExplainMethod`, `.HowTo`, `WhatIs` | chapter Q&A and the glossary |
| Natural programs | natural plane | `NaturallyIn(lang, code)`, `StzNaturalLanguages()`, `StzAddNaturalLanguage` | the gentle entry for young learners |
| Wise coding | conversation plane | `stzKnowledgeGraph.AddConversationQ / AskIn / ReplyIn`, `StzGoalQ().RequireEach` | the tutor's rules (§5.5) |
| Worlds | natural/graph planes | `stzKnowledgeGraph`, `.ImportKnow`, `.Query`, `.Prove`, `.zknw` | worlds as lessons; the manifest format |
| Agents | agentic plane | `StzAgentDeclarationQ`, `.IsValid/.Findings`, `stzPIAgent`, `stzAgentGraph.IsSound`, `GiveWorkbench` | governed-agent exercises |
| Browser VM | ringscript | `RingScript.boot`, `ring.eval`, `ring.reset` | the reader page (§6) |
| `.narration` + court | stznarrations | none yet; unimplemented | migration when it ships (§5.3) |

### 5.2 The manifest format is `.zknw`

A course, a skill, a cohort and a learner's progress are all **knowledge worlds**. This is LAW 5,
composition over machinery. Education invents no format of its own, and it gains four things:

- the tutor can reason over the course itself ("what must I know before chapter 7?" is a `Prove` over
  `requires`);
- prerequisites are a transitive relation, which the graph already enforces;
- progress is queryable with the same `Query` a learner uses in chapter 4;
- a teacher's report is a narration generated from those facts.

A course manifest, for example:

```
knowledge "elementary-introduction"

facts
    elementary-introduction | is-a | course
    elementary-introduction | has-chapter-01 | first-sentence
    elementary-introduction | has-chapter-02 | find-then-apply
    find-then-apply | requires | first-sentence
    find-then-apply | trains | formulate
    find-then-apply | uses-world | restaurant

ontology
    requires | transitive
```

**A known limit:** `.zknw` has no ordered list, so order is carried in the relation name
(`has-chapter-NN`). If that proves clumsy in E1, the fallback is a numbered filename order. Numbered
chapter files are already the naming rule, so the fallback costs nothing.

### 5.3 Chapters: narration markdown now, `.narration` later

Chapters are written in the house narration markdown that the 134 narrations already use: a `# Title`,
`##` sections, and fenced `ring` cells with `? expr` followed by `#--> expected`. Education adds three
conventions, all of them plain markdown:

- a **recap** block at the end, in Zin's three cells: *Achieved*, *Why it matters*, *Coming next*;
- an **exercise** reference, `{{exercise:<id>}}`;
- a **runs-where** mark per cell, `desktop` or `browser`, **computed by the guard** and never hand-typed.

**When stznarrations ships its parser and court, chapters migrate to `.narration`.** A converter makes
the move mechanical, because every chapter is a list of prose and cells. Until then, education claims
nothing about `.narration`.

### 5.4 The checker: an exercise is a promise, checked by running

`oExercise.CheckQ(cLearnerCode)` answers `.Passed()`, `.Why()`, `.Evidence()`.

1. **Run** the learner's code in a **fresh Ring process** on the desktop, or after `ring.reset()` in the
   browser. A fresh process is required because every cell variable is effectively global, and a
   learner's `true = 0` or `nL = 3` must not reach the checker (`stznarrations/CHARTER.md:284-303`; the
   `NL` and `TRUE` hazards in this repository's `CLAUDE.md`).
2. **Compare** the output with the exercise's `promise.ring`, using the `#-->` matching rules from
   `promises.py`, **ported to Ring**: ordered subsequence, TRUE/1 equivalence, list whitespace,
   `#--> ERROR:` for an expected raise, and short promises matched as whole lines.
3. **Explain.** A failure says *which* promise diverged and what was printed instead. It never shows the
   right answer.
4. **Prove the exercise itself.** The exercise's own guard runs every file in `wrong/` (each must
   **fail**) and every file in `right/` (each must **pass**). An exercise that accepts a wrong answer is a
   red guard. Every positive has a negative sibling.

The Ring port of the matching rules is education's to write. It is offered to the meta plane as the
long-term owner, because `promises.py` is theirs and two copies of one rule set drift apart.

### 5.5 The tutor: it asks, and it never cheats

The tutor is `stzConversation` pointed at the gap between the learner's code and the exercise's goal. It
adds Zai-Jr's rules (`zin/doc/spec/dsl/ZINA_DESIGN_v1_0.md:524-538`) as **refusals it can be tested on**:

| The tutor can | The tutor cannot |
|---|---|
| explain a concept in plain words (`ExplainMethod`, `WhatIs`) | write the learner's code before the exercise is passed |
| say what a line does and why | explain a concept the learner has not reached (a spoiler) |
| suggest the next step as a **question** | give an answer before the learner has tried |
| ask a question to check understanding | be talked out of these rules by the learner's wording |
| show the Softanza method for an intent (`HowTo`) **once the learner has tried** | depend on a language model |

A tried answer is a submission the checker has seen. A reached concept is a chapter with at least one
submission. Both are **facts in `progress.zknw`**, so the rules read files and not the learner's word.

### 5.6 Progress, levels and evidence

Progress is a set of facts written only by the checker:

```
ali | passed | ex-02-03
ex-02-03@ali | evidence | sha256:<hash of the submitted file> ran 2026-09-23T21:40:11Z guard elementary-02
```

A **level** (Foundation, Practitioner, Expert) of a **skill** is earned when a **project** in the learner's
own folder passes the guards that the skill names for that level. Tiers across skills are decision D2.
No page, teacher or tutor can write a `passed` fact, and the loader refuses a progress file whose evidence
hash does not match the file in `work/`.

## 6. The two runtimes, and what "zero install" can honestly mean

| | Desktop | Browser |
|---|---|---|
| Runtime | `ring.exe` + the engine DLL + stzlib, which is Softanza as shipped | RingScript wasm, 396 KB, core Ring 1.27 |
| Runs stzlib cells | **yes**, all of them | **no, today** (F1) |
| Runs core-Ring cells | yes | yes |
| Opened from a folder | yes | not with the stock loader; possible with an inlined wasm, untested |
| Checks exercises | yes, fresh process per check | yes for core-Ring exercises, via `ring.reset()` |

**The reader page is generated by Softanza on the desktop** and is a single self-contained HTML file.
It uses the ayouni reader's patterns: articles routed by hash, a search index built on first use, print by
`@media print`, and no Python at run time or build time. Each cell carries its **runs-where** mark. Where
the browser cannot run a cell, the page says so, as law 2 requires, and points to the desktop command.
It never shows a stored output in place of a run.

**"Zero install" is therefore true on day one for a folder that carries Softanza's own runtime**:
`ring.exe`, the engine DLL and stzlib, copied and not installed. It becomes true for a browser the day
RingScript can run stzlib. Decision D4 is how the demo should present that gap.

## 7. The reconciled Zin design

Zin's documents disagree with each other and with themselves. The full table is in
`SOFTANZA_EDUCATION_PLAN.md` §A. What Softanza adopts, and why:

| Question | Zin's values | Softanza adopts | Why |
|---|---|---|---|
| **Skill levels** | F/P/E in the programme and the skill set; Z0–Z4 certification; 7 XP levels in Zina; 4 tracks in ZinaPath | **Foundation / Practitioner / Expert per skill** | the only scale that two independent documents agree on |
| **Tiers across skills** | Z0 Explorer … Z4 Master | proposed **S0–S4**, earned by a project that passes its guards | **D2** |
| **Skill count** | 42, 43, 44, 50, 51 and 55, depending on the document | **25, in 7 families, derived from Softanza's own constructs** (plan §B). Zin's skills name Zin tools (Zml, ZinBase, Flix) and cannot be copied. | **D1** ratifies the list |
| **Skill format** | question, levels, study/practice/build, anchors, with no evidence field | Zin's format **plus an evidence field**: the guard that proves each level | law 9 needs one, and Zin had none |
| **Stages** | 3 in the pedagogical model; 4 in path E, which contradicts it | **3: Encounter, Expression, Governance**. Zin's middle stage, "Declaration", is renamed because Softanza declares at every stage. | **D1** names |
| **Profiles** | 5, 5 different, 6, 7 and 6 | **5: Young, Student, Professional, Designer, Decision maker.** A profile changes the **depth and the examples**, not only a one-line note, which was Zin's shortfall. | the audiences in the launch prompt |
| **Age bands** | 7–12, 10–15, 12+, 13–19, 14+ | proposed **8–11** missions · **12–15** junior course · **16+** core course · professional | **D3** |
| **Chapter families** | 5 in the programme, 6 in the book, varying by domain | **one sequence; families are the seven skill families** | one vocabulary, not two |
| **Recap cell** | Achieved / Why it matters / Coming next | **adopted as is** | the one element every Zin document agrees on |
| **Gentle dialect** | Zina, a subset that exports to Zin | **none needed.** Near-natural chains and `NaturallyIn` *are* Softanza, so nothing needs exporting | |
| **Tutor** | Zai-Jr, design only | **its three rules, as law 6** | |
| **Kids' missions** | the kids' book has no grounding; the game is set in Zindara, Niger, with Amina, Ibrahim and VillageBank | **the game's Zindara missions**, rebuilt so each step runs real code. Wizards and dragons are dropped. | West African grounding is a Zin design standard |

## 8. Boundaries

- **Owned:** `base/education/`, `base/test/education/`, and the education narrations under
  `base/doc/education/`. Staged by explicit path.
- **Consumed, requested through Central**: everything in §5's table.
- **Requests opened at E0** (§10 of the plan):
  - `EDU-BROWSER-STZ-01` → ringscript: run a stzlib cell in the browser, which needs the engine in the
    wasm or Ring fallbacks, a baked stzlib subset, and an offline `file://` loader. This is the E1
    blocker.
  - `EDU-PROMISE-RING-01` → meta plane: accept ownership of the Ring port of the `promises.py` matching
    rules once education has written it.
  - `EDU-NARRATION-01` → stznarrations: the chapter conventions in §5.3, so the `.narration` migration is
    planned for rather than discovered.
- **Never:** a database, an LMS server, a cloud dependency, a second binary, pre-baked output, a guessing
  chatbar, a language model as the tutor's mind, a fork of the core for an institution, a CAS or a
  world-facts corpus, or a claim of progress without a green guard.

## 9. Phases

The phases are in `SOFTANZA_EDUCATION_PLAN.md`, with a definition of done for each. In short:

- E0 is this charter.
- E1 is the vertical slice. It is **split by F1**: E1a is desktop-verified, and E1b is the same slice in
  the browser, gated on RingScript.
- E2 is the decision-maker demo.
- E3 is the Elementary Introduction in four languages.
- E4 is the institution kit.
