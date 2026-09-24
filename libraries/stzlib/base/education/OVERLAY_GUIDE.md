# Adapting the Softanza Learning System to your institution: the overlay guide

You do not change the course. You lay your **overlay** over it: a folder of plain text files that gives
the same chapters your world, your exercises, your languages, your name and your rules. The core stays one
core, so an update to it never touches your files, and your files never touch it.

This guide is executable. Every step is a folder to copy or a line to edit, and the last step is a court
that tells you, by name, what is still wrong. The guard `base/test/education/institution_narrated.ring`
follows these steps literally and must arrive at a valid overlay; if it does not, this guide is wrong, not
you.

## 1. Copy the template

```
copy  base/education/overlays/_template   ->   base/education/overlays/<your-name>
```

Use a short lowercase name with no spaces: `bank`, `university`, `ministry`. It is the name of your overlay
everywhere.

## 2. Fill the placeholders

Open every file of your new folder and replace each `{{...}}`:

| Placeholder | What to write | Example |
|---|---|---|
| `{{NAME}}` | your overlay's name, the folder's name | `ministry` |
| `{{INSTITUTION-SLUG}}` | your institution as one word | `ministry-of-education` |
| `{{WORLD-NAME}}` | the workplace the learners will reason over | `ministry-of-education` |
| `{{WORLD-TYPE}}` | what kind of place it is | `ministry` |
| `{{THING-1}}`, `{{THING-2}}` | two things people request there | `transcript`, `posting` |

A rule of the `.zknw` files: **a word never contains a space**. Write `ministry-of-education`, never
`ministry of education`. Lines starting with `#` are comments and may be deleted.

## 3. Your world

`worlds/workplace.zknw` is the world every chapter reasons over. It is three words per line, *subject,
relation, object*:

```
knowledge "workplace"

facts
    ministry-of-education | is-a | ministry
    request-1 | requested | transcript
    request-2 | requested | posting
    request-3 | requested | transcript
```

Chapter 1 asks this world what was `requested`, counts the repeats and removes them. Keep the relation
`requested`, and put your own things after it. Add any other facts you like: chapter 12 shows what the
learners can do with them.

The court holds every world to this contract: one `is-a` fact, and `requested` facts with at least one
repeat. The core ships three worlds a learner can choose without any overlay -- `workplace` (a restaurant,
the default), `cooperative` and `school`:

```ring
oProgram = StzProgramQ("base/education/program").WithWorldQ("school")
```

Inside your overlay, your `worlds/workplace.zknw` is the workplace, whatever a learner chose.

**A page for your world (optional).** Each core world has a page, `worlds/<world>.<lang>.md`, in the
chapter format: prose and cells that question the world, with `#-->` promises, and no stored output. You
may write one for yours, `worlds/workplace.en.md` and so on. If you do, the court holds it to the same
law as a chapter: one edition in every language you speak, no stored output, and every promise kept when
the page is RUN over your world. Read `program/worlds/cooperative.en.md` for the shape.

## 4. An exercise of your own (optional)

Attach an exercise to a chapter. Two things are needed.

**The folder**, in the same shape as every core exercise:

```
courses/elementary-introduction/exercises/<your-id>/
    exercise.zknw        <your-id> | is-a | exercise  (and | trains | <skill>)
    promise.ring         the #--> lines the learner's program must print
    task.en.md  task.fr.md  task.ar.md  task.ha.md
    wrong/*.ring         answers that must FAIL  (at least one)
    right/*.ring         answers that must PASS  (at least one)
```

Give it an id no core exercise has (`bank-01`, `uni-01`). An id that exists in the core is refused: that
would replace a core exercise, and an overlay never does.

**The attachment**, in `courses/elementary-introduction/course.zknw`, one line:

```
knowledge "bank-course"

facts
    declare-what-not-how | has-exercise | bank-01
```

That is all. The exercise appears on the chapter's page after the core exercises, in every language, and
the checker judges it the same way: by running the learner's program against your promise.

## 5. Your rules (optional)

`governance/<name>.zgov` is a regime your learners' agents live under. The simplest is written by Softanza:

```ring
oGov = new stzGovernance("bank-regime")
oGov.DeclarePosture("TransferAbove", :Sandboxed)
oGov.DeclareReversibility("transfer", :Compensable)
oGov.Save("governance/regime.zgov")
```

## 6. Check it

From `base/education/tools`:

```
ring overlay_check.ring ../overlays/<your-name>
```

It prints `OVERLAY OK` with what your overlay adds and what it shadows, or one line per finding:

```
[overlay-world @ worlds/workplace.zknw] the world does not load: ...
[overlay-no-fork @ courses/elementary-introduction/chapters/01-find-then-apply.en.md] this file would replace a core chapter ...
```

Fix, and run it again. An overlay with no finding is valid.

## 7. Use it

```ring
oProgram = StzProgramQ("base/education/program").WithOverlayQ("base/education/overlays/<your-name>")
oCourse  = oProgram.CourseQ("elementary-introduction")
oChapter = oCourse.RunChapterQ("find-then-apply", "fr")     # now reasons over YOUR world
```

The demo (`base/education/demo/demo.ring`) shows the bank overlay this way in its third scene.

## 8. Your learners: a cohort

A cohort is a folder too:

```
cohorts/<cohort-name>/cohort.zknw
    <cohort-name> | is-a | cohort
    <cohort-name> | follows | elementary-introduction
    <cohort-name> | under | <your-name>
```

```ring
oCohort = StzCohortQ("cohorts/<cohort-name>")
oCohort.AddLearner("amina")                       # creates cohorts/<cohort-name>/amina/
oCohort.WriteReport("base/education/program", "")  # cohorts/<cohort-name>/reports/progress.en.md
```

The report is a narration: every figure in it is a promise beside the cell that computes it. Keep it, diff
it, and run it through `StzChapterQ` later: if the learners have moved on, the report says so instead of
lying.

## 9. From the command line

Two tools in `base/education/tools`, for a learner and for whoever publishes the page. Both take
`--overlay <your folder>`, `--world <name>` and `--lang <en|fr|ar|ha>`:

```
ring learn.ring cohorts/<cohort>/<learner> status
ring learn.ring cohorts/<cohort>/<learner> submit ex-01-01 my-answer.ring      --overlay ../overlays/<your-name>
ring learn.ring cohorts/<cohort>/<learner> ask ex-01-01 "what is missing?"     --lang fr
ring learn.ring cohorts/<cohort>/<learner> project project-s0
ring build_reader.ring pages/<your-name>.html --overlay ../overlays/<your-name> --langs fr,ar
```

Every verdict is the checker's: it ran the file. A scoped build prints what it skipped, by name.

## What an overlay may not do

- Replace a core chapter or a core exercise. That is a fork, and the court refuses it.
- Declare a language the core does not teach in. A new language is a data pack for the natural module.
- Store an output in any document. The page stores none, and the court counts them.

Everything an overlay does is a plain file you can read, diff and keep.
