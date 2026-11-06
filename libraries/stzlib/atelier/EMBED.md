# Citing a check of the Atelier -- the embed contract

*For a page of the site, a page of a book, or any document that wants to say "this is true of
Softanza, and here is the assertion that says so, judged at this commit". It is a contract between
the Atelier (`libraries/stzlib/atelier/`) and whoever cites it. The Atelier never reaches into a
site or a book; the site and the book wire themselves from this file.*

## 1. What is cited

A **check** is one `Then(...)` line of a narrated test of the library (`base/test`), harvested
whole -- its description, the two expressions it compares, and the helpers its file defines for
it. The expected value is the author's of the test, never the Atelier's. A check is judged one
way: its code is admitted into a live program that holds the library, called, and released; the
answer is `PASS`, or `FAIL` with what was expected and what came, or an error.

## 2. The citation

```
<commit>:<id>

74757d462:adverb/00_adverb_narrated#099386a7
```

- **`<commit>`** is the library commit the check was **recorded at**: the commit the recording
  (`results.json`) names as its `library`. It is the first token of that string, nine hex digits.
  A book that pins the library pins this commit.
- **`<id>`** is the check's own identity: its test file without `.ring`, a `#`, and eight hex digits
  of the SHA-1 of its text (description, expressions, helpers). **It never contains a line number
  or a rank**, so it stays when its file changes elsewhere, and it changes when the check itself does.
  Two identical checks of one file are one check; a second with the same digest and another
  description takes a `-2` suffix. The first `:` separates the two; an id contains none.

A citation without its commit is not a citation. A count or a state quoted without the commit,
the rnxc build and the engine that judged it is not quoted: the Atelier's rule, and the reader's.

## 3. What a commit carries

Every commit of the library that has the Atelier carries, in `libraries/stzlib/atelier/`:

| file | what |
|---|---|
| `checks.json` | `{source, commit, taken, files, thens, checks: [{id, n, domain, file, line, scenario, desc, code}]}` -- the harvest, and the commit it was taken at |
| `results.json` | `{taken, library, rnxc, engine, checks_from, checks, pass, fail, err, median_ms, total_ms, states: {id: pass|fail|err}, said: {id: text}}` -- what was recorded when `library` judged them; `said` holds the answer of every check that did not pass |
| `tours.json` | the sweep of whole files: what judged it, the totals, every domain and every file -- the Then lines judged, per domain; the five states apart |
| `i18n.json` | the strings of the page, English and French |

A reader who pins a commit of the library therefore has the data of that commit already: **nothing
needs to be built to cite a check**, and nothing is fetched from a server.

## 4. Resolving a citation

```
rnxc edition.ring cite <commit>:<id> [--data <folder>] [--format json|markdown|html]
```

From the Atelier's folder at the pinned commit (or from a built edition, `--data <edition>/data`),
on Ring++: the tool is library code (`atelierEdition.ring`, `AtelierCiteCheck`). A pin taken
before 2026-11-06 carries it as `python cite.py`, with the same arguments and the same record.
It answers one record -- description, file, line, scenario, code, the recorded state, what was
said when it did not pass, and `judged_by` (library, rnxc, engine, when) -- or **refuses with
exit 2** and the reason: the data was recorded at another commit, or no check has that id. A
resolver that guessed would be quoting a state without its commit.

A book's builder calls it once per citation and renders the record in its own style. The
`markdown` and `html` formats are a plain default, not a design.

## 5. The static edition

```
rnxc edition.ring build-checks --out <folder> [--allow-mixed]
```

(from the Atelier's folder, on Ring++; a pin taken before 2026-11-06 carries it as
`python build_static.py --out <folder>`) writes `<folder>/<commit>/`: `index.html` (the checks by domain, with search), `coverage.html` (the
Then lines judged, per domain and per file), `check.html` (one check, by `?id=`), `data/` (the four
files above), `edition.json` (what judged it, the counts) and adds the edition to
`<folder>/editions.json`. Everything is static and relative. **Nothing runs**: no playground, no run
buttons. **No Ring column**: the page of an edition never carries a comparison with Ring (the
author's rulings of 2026-10-30: none on a public page until he says so). It refuses to mix: the
checks, the recording and the sweep must name one commit, else it says which to record again; and,
inside a git checkout, that commit must be in the checkout's history (a rebase can rewrite it, and a
citation of a commit nobody can check out is not a citation). Every refusal exits 2 with its
reasons; `--allow-mixed` builds anyway and `edition.json` says `"mixed": true`. No folder of the
machine that took the recording goes out: each is replaced by `<path>`, and the maintainer is told
how many.

The folder is not committed anywhere: it is derived, from a pinned commit, by one command.

### An address for one check

```
<base>/<commit>/check.html?id=<id, URL-encoded>[&lang=en|fr][&embed=1]
```

`embed=1` drops the page's head and menu and keeps the card: it is meant for a frame. The card
shows the check's description, provenance (file, line, scenario), the recorded state with the commit
it was recorded at, what was expected and what came when it did not pass, the citation, and the code.

```html
<iframe title="A check of the Softanza library"
        src="https://example.org/atelier/74757d462/check.html?id=adverb%2F00_adverb_narrated%23099386a7&embed=1"
        style="width:100%;border:0;min-height:18rem"></iframe>
```

A frame is the right embed for a page that can host one. A book's reader that cannot should render
the record `edition.ring cite` answers, in the book's own style, and print the citation beneath it.

## 6. What a citing page owes the reader

- **Name the commit.** The citation is `<commit>:<id>`, printed, so the reader can resolve it again.
- **Do not quote a count without its edition.** "1,011 of 1,126 checks pass" is a sentence about one
  commit, one rnxc and one engine; say which, or link the edition that says.
- **Show the five states apart** wherever the Then lines judged are counted: kept, diverged,
  unreached, unjudged, unperceived. Never fold them into pass and fail.
- **No Ring comparison** on a public page without the author's word.
- **A page stage is the author's.** A book page moves beyond Draft only when he says so; a citation
  does not change that.

## 7. What changes, and what does not

A `<commit>:<id>` stays resolvable for as long as that commit's data is reachable. A check whose
text changes gets a new id, so an old citation of it still resolves, at its old commit, to the old
text. A citation is never updated in place; a page that wants the newer state cites the newer commit.

## 8. Citing a cell of a notebook (B4)

A notebook -- a narrated test file in the notebook's form, one `Scenario` per cell -- is cited
cell by cell, with the same grammar:

```
<commit>:notebook/<name>#<hash>

225e28c8e:notebook/a-first-notebook#eb218172
```

- **`<name>`** is the notebook's file name without `.ring`.
- **`<hash>`** is the first eight hex digits of the SHA-256 of the cell's title, a line feed, and
  its code. It changes when the cell does, and only then; two identical cells of one notebook take
  `-2`, `-3`. The `notebook/` prefix keeps the two kinds of id apart: a check's id begins with its
  test folder.
- **`<commit>`** is the library commit the notebook was RECORDED at: the first token of the
  recording's `library`.

**What a commit carries.** Beside the notebook, `<name>.recording.json`: what a running Atelier
answered when the library at that commit ran every cell, with its `rnxc`, its `engine`, when it
was `taken`, the notebook's `digest` (the SHA-256 of the file, its line ends made LF), every cell
with its id, and the Atelier's whole answer (each line seen, its values in their faces, its
promise and state; the chains unfolded; the scenes).

**The tools**, in Ring++, from the Atelier's folder:

```
rnxc edition.ring record <notebook.ring> [--port N]
rnxc edition.ring build <notebook.ring> --out <folder>
rnxc edition.ring cite <commit>:notebook/<name>#<hash> --data <name>.recording.json [--format json|markdown|html]
```

`build` writes `<folder>/<commit>/notebook/<name>/index.html`: ONE file holding the page, the
recording and the dictionary, so it opens from disk and sits in a frame; nothing runs and nothing is
fetched. `?cell=<id>&embed=1` shows one cell as a bare card. It refuses, with exit 2 and the
reasons, a notebook changed since its recording, a commit not in this history, a recording that
names a folder of a machine, and an out folder inside the Atelier. `cite` answers one record, or
refuses with exit 2: another commit, or an id no cell has. The order of a landing is the checks':
push the code, record at that commit, then commit the notebook and its recording together.
