# The Atelier as a workbench -- a design, for the author's decision

*Status: B0 BUILT 2026-11-05 (the cell, its faces, its promises judged), B1 BUILT 2026-11-05
(the chain and the scene unfolded, the forms offered) and B2 BUILT 2026-11-05 (the notebook: many
cells as one file, saved, opened, a check forked; the court agrees) and B3 BUILT 2026-11-06 (the
lessons: the Learning System's chapters as notebooks, judged by the course's court, exercises
recorded by the learner's own Submit); see the plan's journal. B4 and B5 as proposed below. Natural, the fourth form, is not generated: it is shown only where the reader
writes it.*

*stzlib-atelier, 2026-11-05. Asked by the author on the live page: "The Atelier should be
redesigned from the ground up to reflect what we would expect from a programming workbench, yet
leveraging Softanza's own style, paradigms, features, innovations and mental models. It should
resemble a very simple coding workspace but show the richness and visuality of the outputs, while
educating the user on the process." This is the rethinking, with a mockup beside it
(`workbench_mockup.html`, a static page; open it in a browser). Nothing of it is built. A0 to A3
stay as they are: the checks, the coverage and the editions are the workbench's material.*

## 1. The thesis in one sentence

**A cell of the Atelier is a narrated test the reader writes: it says what it does, shows what
came, judges what it expected, and shows how it got there.** That is not a notebook idiom
borrowed from elsewhere; it is Softanza's own paradigm -- Given, When, Then; the `#-->` promise
under the line that printed it; the scene form `o { }` as the basic form; the function forms
(`Verb()` mutates, `Verbed()` answers, `VerbQ()` chains); `Naturally(...)` where it runs -- turned
into the workspace itself. The library's 1,498 narrated files and the Learning System's 60
chapters are already written in exactly that shape, so the workbench opens with 20,000 cells it did
not have to write.

## 2. The four faces of a cell

A cell has one piece of code and four faces beneath it, always in this order, top to bottom
(one column; the eternal scroll; no second menu).

1. **The output, in the value's own face.** Not a string dump. The server projects the value with
   Softanza's own faces: a text with `@@` and, for a find, `VizFind` (the string with its positions
   boxed); a list as an indented tree; a `stzTable` as a ledger (`ToHtml()` exists); a diagram or a
   plot as the SVG the engine renders (six renderers exist); an image as the image; a number with
   its representation; an object as its `Show()`. The page shows what the server sent; it never
   re-renders a value with its own rules.
2. **The process.** How the value came to be, in the only terms Softanza has: a **chain unfolded** --
   `Q("softanza").UppercaseQ().Spacified()` shown as three rows, the value after each method and the
   microseconds each took; a **scene unfolded** -- each line of `o1 { ... }` a row, the object's state
   after it (so `Verb()` changing the object and `Verbed()` leaving it alone is *seen*, the function
   forms as a picture); and the **same move in its forms**: the scene form, the chain, the classic
   form, and `Naturally("...")` where it runs -- the author's order of forms, side by side. The
   process is measured by running the prefixes of the chain as admissions (2 ms each), not by a VM
   trace hook: rnxc has none (`ringvm_settrace` is R3, measured 2026-11-05).
3. **The expectation.** A `#-->` promise under a `?` line, or a `Then("...", actual, expected)`.
   Judged by the same court that judges the library: kept, diverged -- and the coloured word always
   beside its text. A cell that promises nothing says so: it ran, it asserted nothing, which is a
   state and not a fault (testoor's rule).
4. **The lesson.** A note the author of the cell wrote, and the next step. For the Learning System's
   chapters this is the chapter's prose; for a library check it is the scenario it belongs to; for the
   reader's own cell it is empty until they write one.

## 3. What the workbench is made of, and what each part already is

| part | what it is today | what the workbench adds |
|---|---|---|
| the live program | A0: one resident program holds the library; a cell is admitted, called, released, 2 ms | the cell's `?` lines captured (a line-level rewrite to a recorder, since the resident's stdout is the server's); the value projected in its face |
| the court | A1: testoor's reader and judge, the five states | a cell's promises judged live; a notebook saved IS a narrated test file, read by the same reader |
| the library's checks | A0 to A3: 1,129 checks, their recording, their citation | each check opens as a cell: run it, change it, fork it into your notebook |
| coverage and editions | A1, A3: the sweep, the static edition, the citation | a notebook has a static edition too: the cells with what was RECORDED at a commit, nothing stored as truth |
| the Learning System | 60 chapters in 4 languages, cells with promises, exercises with their own court (`check.ring`), overlays for institutions | the chapters open as notebooks; an exercise is a cell whose court is the chapter's; progress is `stzLearner`'s |
| the page | A2: Zui-lawful, two languages, 0 violations | the same page, one column, the cell as its unit |

## 4. What is borrowed, and what is corrected

The author asked for a tool worth the best of its kind. These are the kin, and where Softanza
departs from each on purpose.

- **Mathematica notebooks** (Wolfram): computation and exposition in one document; the closest kin,
  and the idiom the author's books already use. Kept whole.
- **Jupyter**: cells with outputs stored in the file. *Corrected*: Softanza's law is that no output is
  stored as truth; a notebook stores the code and the promises, and an edition stores a RECORDING
  named by its commit (A3's rule). A stored output nobody re-ran is a lie waiting to be read.
- **Observable and Pluto**: a cell names a value, and cells react to each other. *Kept*: a notebook is
  one admission whose names persist across cells (`replacecode` on each run). *Corrected*: no
  reactivity by hidden graph; a cell runs when the reader runs it, and says so (Zui Rule 15: if
  something moved, the reader caused it).
- **Python Tutor**: execution shown step by step. *Softanza's version*: the chain and the scene
  unfolded, with the object's state -- the unit of a step is a Softanza method, not a VM frame,
  which is what a reader of Softanza needs to see.
- **Livebook** (Elixir): smart cells that show the same thing in several ways. *Softanza's version*:
  the forms switcher -- scene, chain, classic, natural.
- **Swift Playgrounds and Hedy**: lessons with graded steps and a judge. *Kept*: the Learning
  System already has 60 chapters, exercises and a court. *Corrected*: the judge is the test court,
  not a hidden grader.
- **Scratch**: blocks. *Not borrowed*: the scene form `o { }` is Softanza's block, readable as
  prose; a drag-and-drop layer over it would hide the language the reader is learning.
- **Replit**: a hosted multiplayer playground. *Not borrowed*: a hosted `/run` needs a sandbox,
  which is the author's ruling and is not built; the workbench runs on the reader's machine from the
  install, and the site gets editions.

## 5. The ladder, if the author says go

Each rung: its guard first, failing before and passing after; landed on both remotes; one
CONCLUSIONS line; the page audited by StzZui's tool at every rung.

- **B0 -- The cell.** One cell on the live page: code, output in its face (text, list, table, SVG,
  image), `?` captured, a `#-->` promise judged. The projection is one server function, in Ring,
  using the faces the library has. Guard: five value kinds projected, a promise kept and a promise
  diverged.
- **B1 -- The process.** The chain unfolded with the value after each step and its time; the scene
  unfolded with the object's state; the same move in its forms. Guard: a three-step chain gives three
  rows whose last value is the cell's; a scene with `Verb()` shows the object changed and with
  `Verbed()` unchanged.
- **B2 -- The notebook.** Many cells, names kept across cells, a notebook saved as a narrated test
  file and read back by testoor's reader; opened from the library's checks (fork a check). Guard: the
  round trip, and the court agreeing on the saved file.
- **B3 -- The lessons.** The Learning System's chapters as notebooks, exercises judged by their
  court, progress kept. Guard: one chapter, every cell run, every promise judged, one exercise
  submitted right and wrong.
- **B4 -- The edition of a notebook.** A3's builder generalised: a notebook with what was recorded at
  a commit, for the site and the books, citable cell by cell.
- **B5 -- Haro.** When Haro ships its test form, a cell in Haro (A4).

Costs the author should know: B0 needs one Ring++ fact settled -- whether an admission's `?`
output can be captured by the program (asked as a question; the interim is the line-level
rewrite); B1's process view is bought with N admissions per chain of N steps, 2 ms each; B3 depends
on the education plane's files, read and never edited here.

## 6. What the mockup shows

`workbench_mockup.html` is one cell, drawn to the law the page already obeys (one reading size,
one accent, nothing moves, one column): the code in the scene form; the output as a table and a
boxed find; the process as the chain unfolded with values and times; the four forms; the promise
judged; the lesson. Every value in it is a value Softanza answers today; nothing in it runs.
