# The Softanza Learning System, in the documentation system

*Plane `stzlib-education`. The module is `base/education/`; its guards are `base/test/education/`. This
folder is the module's door into the documentation system: it says where each document is and which of
the five pillars it belongs to. The documents are not copied here, so they cannot drift.*

Written 2026-10-05 against `main` at `c77d159f8`.

## What it is, in two sentences

A course of computational thinking in English, French, Arabic and Hausa in which **every cell runs and
no output is stored**, every exercise is checked by running the learner's program, and an institution
adapts it with an **overlay** (its own world, exercises, rules and name) and never a fork. A tutor asks
the question the learner's attempt leaves open and never writes the answer; no language model is
involved.

## Where each document is, by pillar

| Pillar | What | Where |
|---|---|---|
| **Narrations** | The 15 chapters of the Elementary Introduction, each a markdown file of prose and `ring` cells with `#-->` promises, in four editions with identical promises cell for cell | `base/education/program/courses/elementary-introduction/chapters/NN-<id>.<lang>.md` |
| **Narrations** | A page per teaching world (a restaurant, a cooperative, a school): the world itself, questioned | `base/education/program/worlds/<world>.<lang>.md` |
| **Quickers** | The overlay guide, **executable**: a guard performs its steps literally | `base/education/OVERLAY_GUIDE.md` |
| **Quickers** | The reviewer's sheet, one file per language | `ring base/education/tools/review_sheet.ring <out.md> --lang fr` |
| **References** | The twelve classes of the module, in `base/doc/reference.json` | `stzProgram`, `stzCourse`, `stzExercise`, `stzExerciseCheck`, `stzChapter`, `stzProject`, `stzSkill`, `stzLearner`, `stzTutor`, `stzOverlay`, `stzCohort`, `stzEduReader` |
| **Deepdives** | The charter (nine laws, contracts, boundaries) and the phase record E0 to E10 | `base/education/CHARTER.md`, `base/education/SOFTANZA_EDUCATION_PLAN.md` |
| **FAQs** | The fifteen-minute demo and its answers to the questions a decision-maker asks | `base/education/demo/DEMO.md` |

## Run it

```
cd base/education/tools
ring build_reader.ring course.html                # the whole course, four languages, one page (about 100 s)
ring learn.ring <learner folder> status           # where a learner is, what is passed, what a level still needs
ring overlay_check.ring ../overlays/<name>        # the court an institution's overlay must pass
```

## What the guards prove, and what nothing proves yet

Fourteen narrated guards (`base/test/education/*_narrated.ring`, 716 assertions at the date above), run in
a fresh checkout. The fastest way in is `demo_narrated.ring` (17 assertions, about 2 minutes), which plays
the fifteen-minute demo twice from a clean folder.

**Not proved, and said on the pages:** no native speaker has reviewed a translation (0 of 35 units in each
of French, Arabic and Hausa; the page opens each one with a *draft translation* notice until a sign-off is
recorded in `base/education/program/reviews/<lang>.zknw`); the cells run on the desktop only, not in the
browser (`EDU-BROWSER-STZ-01`, with ringscript); no institution has adopted it yet.

## For the reference pillar

The module's classes are in the reference, but their methods are mostly undocumented: 206 of its roots are
in `doc_baseline.txt`, and the nine methods added in the last slices (seven of `stzProgram`, two of
`stzExercise`) carry doc blocks and pass the doc gate. If a wave is cut for the rest, `stzProgram`,
`stzCourse`, `stzExercise` and `stzTutor` are the learner-facing API and the place to start.
