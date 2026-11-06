# The Softanza Atelier -- the library's own assertions, run live

*Plane `stzlib-atelier`, launched 2026-11-03 by the author. The name is his: "Atelier"
reads the same in French and in English, and "Lab" is kept for the research lab that may
one day host the Softanza project, so nothing of this plane -- no file, folder, route,
function, page or commit message -- calls the tool a lab.*

## 1. What it is

A web tool that keeps testing Softanza, from inside Softanza. One live program on Ring++'s
resident VM holds the library; the page runs the library's own narrated assertions against
it, one at a time, each admitted as code, called and released; code typed in the page runs
in the same program. Every check comes from a `Then(...)` line of `base/test`, judged as the
suite judges it (`=`, shown with `@@`), so the Atelier adds no assertion library and
rewrites no test: the checks are harvested, and the expected value is always the author's.

It lives in the library, at `libraries/stzlib/atelier/`, because its content is the
library's: a check and the test it comes from move in one commit, and a result names one
library commit. Ring++'s package copies `libraries/stzlib` except the tests and the
engine's sources, so the Atelier ships in every install with no change to Ring++; the site
and the books already pin and read library commits.

**Origin.** The tool was first built on 2026-11-01, under another name, as a demonstration
app of a private server project. It ran 1,100 checks harvested from 1,469 narrated files
(19,604 `Then` lines) in about 5 s, 3.3 ms a check, on the installed Ring++. The decision of
2026-11-03 moved it here. Everything in this folder was written for the public tree: no
machine path, no private repository's name. The first rung, A0, is that move, at parity
measured side by side.

## 2. Rules of the plane

- **Released things only.** The Atelier runs on a released Ring++ (v2.0.10 or later): its
  `rnxc resident`, the eight `rpp_http_*` server natives, and the admission verbs
  `admitcode`, `releasecode`, `admitstart`, `admitstate`, `admitfinish`. The host loop is
  the Atelier's own, written on those verbs. A user needs nothing but the install: the
  Atelier starts with `rnxc resident atelier.ring` from this folder. Python stays for
  maintainer tools -- the harvester and the verdicts against Ring.
- **Never a public `/run`.** A run route admits any code, and Softanza code can read files
  and start processes. The Atelier binds 127.0.0.1 (the natives do, and the loop refuses to
  be told otherwise). A hosted public playground needs a sandbox, and that is the author's
  ruling to make; it is brought as a question with its cost, never built.
- **Ring's column is an instrument.** `verdicts.json` holds Ring's answer to each check,
  taken by `verdicts.py` on an oracle whose path comes from the environment; it records the
  build and the library commit it was taken on. No public edition (site, book) shows a
  comparison with Ring before the author says so (his rulings of 2026-10-30).
- **Every result names what judged it:** the library commit, the rnxc build (PACKAGE.txt
  in an install, or a checkout's commit) and the engine (the library's own, or the
  package's, built for which library commit). A count without its build is not quoted.
- **The engine is a trap, named.** The library loads only with a Ring++-flavour engine. An
  install's engine is the package's, built at the library commit the package names; a newer
  library may call natives that engine lacks (R3), and a worktree that built its own engine
  the Ring way hands rnxc Ring-flavour libraries (R46). The Atelier measures which library
  and which engine it judges, and says so on the page and in every results file.
- **Never a sibling.** `base/testoor/` is read and called, never edited (its mailbox takes
  requests). The site and the books do their own wiring from an embed contract (A3). A
  Ring++ defect is reported with the smallest program that shows it.
- **Paths are derived.** The Atelier finds its own folder from the argument it was started
  with, the library from the folder above it (or a setting), and rnxc from the one running
  it. No file in this folder names a folder of the machine it was written on.

## 3. The pieces (A0)

| file | what |
|---|---|
| `atelier.ring` | the app: settings, the host loop, the routes, `AtelierThen` and `AtelierShow`, the build facts |
| `atelier.html` | the page, under the Zui constitution at v3.13: three sections at three addresses, the domains as a vertical level, search, each check's provenance, the five states apart |
| `i18n.json` | the page's every string, one dictionary per language (English, French); the code references keys (Rule 122) |
| `atelierClient.ring` | functions a Ring program uses to boot an Atelier, run checks over HTTP, compare two recordings, write a results file (the guard and the recorder load it after the library) |
| `record.ring` | maintainer: boots an Atelier, runs every check, writes `results.json`; `rnxc record.ring` from this folder |
| `tours.ring` | maintainer (A1): boots an Atelier, runs every narrated file of `base/test` WHOLE as one tour each, judged by testoor's judge, writes `tours.json`; `rnxc tours.ring [--topic T]` from this folder |
| `harvest.py` | maintainer: harvests `checks.json` from `../base/test` (or `--tests=`) |
| `verdicts.py` | maintainer: Ring's verdicts, `RING` and `RING_TREE` from the environment |
| `checks.json` | the checks: id, domain, file, line, scenario, description, code |
| `results.json` | the last recording: what judged it, the counts, each check's state -- the guard's baseline |
| `verdicts.json` | Ring's answers, and what they were taken on |
| `tours.json` | the last sweep of whole files (A1): what judged them, the totals, every domain, every file |
| `atelierEdition.ring` | (A3, B4) the editions' functions, Ring++: a notebook recorded, built and cited, and the checks' static edition (`AtelierBuildChecks`) and citation (`AtelierCiteCheck`) |
| `edition.ring` | maintainer (A3, B4): the command line. `rnxc edition.ring build-checks --out <folder>` writes the static edition of this commit: index, coverage and a one-check page over the data it already carries; read-only, no Ring column, refuses a mixed set, scrubs machine paths. `rnxc edition.ring cite <commit>:<id>` resolves a citation to its check, state and what judged it, or refuses with the reason. `record`, `build` and `cite` of a notebook are B4's |
| `EMBED.md` | (A3) the contract: the citation, the id law, what a commit carries, what a citing page owes the reader |

Settings, in this order: a config file admitted before the app
(`rnxc resident my_settings.ring atelier.ring`, holding
`$aAtelierConfig = [ :port = 8650, :library = "..." ]`), then the environment
(`STZ_ATELIER_PORT`, `STZ_ATELIER_LIBRARY`), then the defaults: port 8650, the library the
Atelier sits in.

Routes, all under `/atelier`: `GET /atelier` the page (`/` too), `GET /atelier/checks`,
`GET /atelier/verdicts`, `GET /atelier/results`, `GET /atelier/state` (JSON: where the
library stands, what judged it, the counts), `POST /atelier/run` (the body defines
`func Run cInput`; admitted, called, released: 200 and what Run returned, 500 and its
error, 422 when it could not be admitted or released, 503 while the library compiles),
`POST /atelier/tour` (A1: the body is a folder on its first line and a whole narrated test
file after it; the Atelier moves to that folder, admits the file whole, releases it, moves
back, and answers a header line -- `end`, finished | finished-timed | broke | not-started,
the milliseconds, released or kept, the error -- followed by the trail, the very lines
`base/test/_narrated.ring` would have printed), `GET /atelier/tours`, `POST /atelier/stop`.

## 4. The ladder

Every rung: its guard first, failing before and passing after, each protection made to
fail; landed on main and pushed to both remotes by stzlib's push protocol, verified with
`git ls-remote`; one CONCLUSIONS line.

### A0 -- The move, at parity -- DONE 2026-11-03

The page, the app without the private project's comparison handlers, an own host loop,
the harvester, the verdicts tool and the checks, each under the Atelier's names. Parity
measured, not claimed: the same checks and the same counts on the same rnxc and the same
library commit, the tool as it stood and the Atelier side by side. Guard:
`base/test/atelier/atelier_narrated.ring` -- boots an Atelier, runs every check over HTTP,
and fails when a check's verdict moved against `results.json`.

### A1 -- Coverage -- DONE 2026-11-03 (journal below)

13,727 of the 20,460 `Then` lines (at 90f2c01b0) wait on the variables their scenario set
up. A WHOLE FILE runs as one admission on the resident Atelier: the client
(`AtelierTourSource`) drops the file's loads of the library and of the narrated helper
(the base holds both), rewrites a top-level `shutdown()` or `bye` to `AtelierShutdown()`
(recorded, never obeyed), and posts the file with its folder; the Atelier moves to that
folder (a test reads its data relative to itself), admits the file -- its top level runs
inside `admitcode`, its `Scenario`/`Then` calls land on the Atelier's recording verbs,
which write the very lines `_narrated.ring` prints -- releases it, and answers the trail.

**The judge is testoor's, not a second one.** `AtelierRunTour` reads the file with
testoor's reader (`Tour`), hands the trail to testoor's judge (`_TravJudge`) exactly as
the traveller hands it a child's output, and the five states come out of the same
function: kept, diverged, unreached (the file broke or never started before the claim),
unjudged (the file finished without walking it), unperceived (TR6). A tour's ending is
the server's header: finished, finished-timed (`pf()` ends a test by raising its banner),
broke (a runtime error at the top level), not-started (the file does not compile or
scan); hung is the client's (no answer in 60 s: the sweep kills and reboots the Atelier).

**The court** is testoor's own runner -- a child rnxc per tour, since 7578805d4 -- walked
on the same files and compared claim by claim (`AtelierDisagreements`); the guard names
every disagreement. **Coverage** is the `Then` lines the reader read that were judged
(kept or diverged) over all it read, per domain, in `tours.json` and on the page's
Coverage tab; the harvested checks are the floor, this is the ceiling. A file that defines
a class cannot be released and stays (kept code): it runs once per server life.

### A2 -- The experience -- DONE 2026-11-04 (journal below)

The page under StzZui's law at its live version (v3.13, 123 rules), in French and English
like the site, from one dictionary file; browse by domain (a vertical level on the left),
search (Ctrl+K); each check shows its provenance (file, line, scenario, library commit,
id); the playground kept; the five states shown apart per file; a check's id is its file
and a digest of its own text, so it stays when the file changes elsewhere. Measured by
StzZui's own audit tool: 0 violations on 5 pages, light and dark.

### A3 -- Reach -- DONE 2026-11-04 (journal below)

(a) The install carries `atelier/`: read in Ring++'s package script, measured by emulation,
verified for real on the next re-lay, which is Ring++'s job (asked through Central). (b) A
static edition per library commit -- the checks, their recording and the page in read-only
mode, built by one command -- for the site, which cannot run code, and the books, which pin a
commit. (c) An embed contract: how a page or a book cites a check (`<commit>:<id>`) and shows
it, `EMBED.md`; handed to stzsite and ayouni through Central (prompts 58 and 59), whose
sessions wire it.

### A4 -- Haro tours -- WAITS ON HARO

Ring is retired and Haro is coming (its own repository, standing alone). A tour written
as a `.haro` file is a new dialect for testoor's reader and a new child program for its
runner, and a new admission for the Atelier; none of that exists before Haro's test form
does. Named here so it is a rung and not a surprise.

## 5. Journal

Appended per rung: what was measured, on which build, and what was decided.

### A0 -- 2026-11-03 -- the move, at parity

**Measured on** the installed Ring++ (rnxc ringpp a8ad844 2026-11-02, PACKAGE.txt), CPU
unthrottled (heartbeat 160%). Two libraries, each named by the Atelier itself:

| judged library | engine | checks | pass / fail / err | a check | all |
|---|---|---|---|---|---|
| 0950e246a, the install's | the library's own (the package's build) | 1,100 (harvested at 0950e246a) | 994 / 87 / 19 | min 1.1 ms | 12 to 17 s over HTTP from Python |
| 90f2c01b0, main in this worktree | the package's, built for 0950e246a | 1,122 (harvested at 90f2c01b0) | 1,009 / 88 / 25 | 2 ms median from the Ring client | 8.5 to 9.4 s |

**Parity, side by side, fresh against fresh.** The tool as it stood (a fresh instance on
another port) and the Atelier, same rnxc, same installed library, the same 1,100 checks
(the harvester's output on the 0950e246a tree is identical to the tool's, 1,100 of 1,100,
code, file, line and id): 994 / 87 / 19 on both, and **1,100 of 1,100 answer texts
byte-identical**. The author's long-running instance of the tool (up since 2026-11-02,
84,583 requests served) answered 996 / 85 / 19 against the fresh Atelier's 994 / 87 / 19:
4 checks moved (20, 22, 23, 357) and one failure's text (18) -- the state that
accumulates across runs in one long-lived program, which the tool's own record names.
Per-request medians swung between 2.7 and 15 ms with the ORDER the two were run in, on
both tools; the minima (1.1 to 1.3 ms) and the Ring client's 2 ms median are the figures to
quote.

**Main's 1,122 checks on the install's 0950e246a library** (the page, in the browser):
996 / 86 / 40 -- the 40 errors are what main's tests call and the older library lacks.
This is the engine trap measured: the page says which library it judges, and the number
beside it is not the number for main.

**Ring's verdicts** (`verdicts.py`): the oracle is a Ring 1.27 built 2026-09-12 loading
the 0950e246a tree with a Ring-flavour engine; rnxc compiled the same program whole from
main's library. On Ring 967 / 70 / 85; on rnxc whole 1,009 / 88 / 25 -- **exactly the
resident Atelier's counts, 0 of 1,122 differ** between the compiler-and-VM and the
resident path. Ring and rnxc differ on 60: 56 are a function the oracle lacks (41 in its
engine, 15 in its 106-commits-older library), 4 are a Ring error where rnxc answers
(2 pass, 2 fail). All 70 of Ring's failures are the same failure on rnxc, and nothing
passes on Ring and fails on rnxc. The ring column is an instrument: the oracle is not in
any install, and its tree is older than the checks until a Ring-flavour engine is built at
main, which is not this plane's to build.

**The guard** (`base/test/atelier/atelier_narrated.ring`, 36 assertions, 48 s wall of
which 22 s is the child's compile of the library): the comparison refuses a planted moved
state and a planted new or vanished id; a boot on a folder without the library ends with
the child's own line; a check passes, fails (with @@'s two lines) and errors (500) as the
page decides; a playground body with its own helper leaves the program with the same
number of functions; every check runs and no verdict moved against `results.json`; stop
ends the child. The recording the guard compares against is `record.ring`'s, taken on
main's library with the package's engine, and the file names both.

**Found on the way.** `JsonToList` (base/file/stzJsonFuncs.ring, the Ring-side parser)
drops every array element after an object holding a non-ASCII string: checks.json read
back as 58 checks and then empties. The library already knows this -- `StzJsonToList`,
engine-backed, is documented there as the drop-in, with the same shape -- so the client
uses it; nothing to route. The first recording, taken through `JsonToList`, said 204 /
38 / 880 and was wrong by 858 errors: a reader that goes silently empty is the failure
mode to remember.

**Decided.** The Atelier judges the library it sits in by default (a setting or the
environment chooses another), so an install judges the install's library and a checkout
judges its own on whatever engine rnxc finds -- and says which. The checks committed are
main's harvest (1,122), not the parity set (1,100): the Atelier's content is the tree's.
The verdicts stay in the tree with what they were taken on, and the page's Ring column
stays off every public edition until the author rules on it.

### A1 -- 2026-11-03 -- coverage: whole files as tours

**The court agrees.** Four real narrated files (adverb, uuid, common/slice_primitives,
string/00_string) walked by testoor's own runner (a child rnxc each, since 7578805d4) and
admitted whole on the Atelier: the same judge (`_TravJudge`) on both trails, 0
disagreements on 101 claims, the four tours kept on both sides. The Atelier's admission
of each took 0.03 to 0.10 s against 1.1 to 2.7 s for a warm child and 146 s for a child
paying its tour's first compile.

**Measured on the way, and each one changed the design:**

- *A pipe nobody drains blocks the server.* The first boot of the Atelier from a Ring
  client used the engine's argv spawn, whose stdout is a pipe; a tour that prints a few
  kilobytes (every `?` of a test file lands on the server's stdout) filled it and the
  server blocked on write, the client waited its 300 s deadline, and the guard stalled for
  25 minutes. The client now boots the Atelier through the shell with its output to
  `_atelier_<port>.log`; since the shell is then what `Kill()` reaches, the Atelier writes
  `_atelier_<port>.pid` once its library is admitted and `AtelierKill()` ends it by that
  pid. A path with a space is refused rather than mangled (the shell form dies silently on
  a quote). The engine's argv spawn deserves a stdout-to-file variant; routed as a note,
  not built here, because the Atelier must run on the engine the install carries.
- *Ring++ runs a file up to the first statement it refuses.* A tour with a promise before
  a syntax error starts, keeps the promise and breaks there (exit 1); under Ring it ran
  nothing. The planted "not-started" tour is therefore a scanner error (an unclosed
  literal), which no runtime starts. testoor's promises guard moved its expectation with
  the same reason (7578805d4).
- *`pf()` ends a test by raising its banner.* On the resident server that raise comes out
  of `admitcode` as an error whose text is `STOPPED!`; the route reads it as
  finished-timed, as testoor's ending classifier does on a child's output.
- *A tour's `shutdown()` or `bye` would end the server.* The client rewrites a top-level
  `shutdown(n)` or `bye` to `AtelierShutdown(n)`, which records the ask in the trail; the
  tour goes on and the server stays. 41 narrated files carry one.
- *A file that defines a class stays.* The resident VM cannot release a class whose objects
  could outlive it; the sweep counts such files as kept code (24 narrated files define a
  class) and the same file cannot be admitted twice in one server life.
- *Constants cannot be clobbered through a Rule-A global under rnxc.* `$NL = 42` inside a
  function leaves `NL` a newline, measured; so a hostile-globals tour does not poison the
  resident program for the tours after it. The court keeps clear of that file all the same.
- *The machine throttled mid-session.* The heartbeat fell from 160% to 53% (battery) for
  about forty minutes: library compiles went 20 s to 110 s and a child's first compile 35 s
  to 123 s. Figures taken in that window are named so and not quoted; the figures above
  were taken fit to measure.
- *A testoor child's first walk after a library change pays its compile.* rnxc keeps one
  compiled image per main file; every tour's image is stale once the library changes.
  Warm, a child walks a tour in 0.15 to 2 s. That is testoor's tax and the reason a sweep
  of whole files belongs on the resident Atelier, where a tour's admission is a few
  milliseconds and the library is compiled once.

**The sweep** (`tours.ring`, every narrated file of `base/test` at this commit, one
admission each, judged by testoor's judge, written to `tours.json` and shown on the page's
Coverage tab), on the library at 7578805d4 with the package's engine (built for
0950e246a), rnxc a8ad844:

| | |
|---|---|
| narrated tours | 1,417 run, 4 skipped by name (the Atelier's and testoor's own guards boot programs of their own) |
| how they ended | 1,322 finished, 32 broke, 55 never started, 8 hung (60 s deadline), 41 kept their class and cost a reboot |
| Then lines read by the reader | **20,278** (the harvester's regex counted 20,460 at 90f2c01b0) |
| judged | **15,186, 74.9 percent**: 15,050 kept, 136 diverged |
| not judged | 4,941 unreached (behind a refusal, a break or a hang), 151 unjudged (a branch not taken) |
| verdicts the reader had no line for | 1,857 (a Then in a loop, or built from a variable) |
| domains | 98; 60 judged whole, 6 with nothing judged |
| the tours' own time | 943 s of admissions and runs; the sweep 30 minutes with its 49 reboots, the CPU fit to measure (an earlier pass, throttled and beside two other desks' guards, took 43 minutes to the same counts within two tours) |

The floor was 1,122 checks, 5.5 percent of the Then lines; the ceiling judged today is
74.9 percent, and the page shows both. Where the rest is:

- **54 of the 55 never started are one refusal**: `bare name is not a local (Rule A)` --
  the file's function reads a top-level variable without `$`. Measured on the smallest
  program (`c = "x"` at the top, `func F return c`): `rnxc file.ring` compiles the top
  level, refuses the function and runs until the call; `admitcode` of the same text
  refuses the whole admission. So as a child those tours break at the first such call
  and as an admission they never start; either way the files are not Rule-A clean, and
  they are named in `tours.json` for their owners. Whether an admission could be
  statement-level like the whole compile is a question for Ring++, routed as one.
- **32 broke**: 8 R3 (a function the library lacks on this engine, or a name the file
  expects), 5 R2, 5 R24, 3 R41, 2 R35, 2 a test that reads `sysargv` as its own path
  (the education course), 1 an OCR model not installed, 1 a vault that answered -1, 1 a
  missing entry, and so on -- each named with its line in `tours.json`. A tour that
  breaks or hangs never reaches its own clean-up: the sweep leaves their temporaries in
  the test folders (named `_tmp`, `_gen`), to be removed by hand and never staged.
- **8 hung**: six cluster tours, the appserver real-host tour, and one more that wait on
  a socket or a node that never comes in a resident program; killed at 60 s, the
  Atelier booted again, and their Then lines after the wait are unreached.
- **The largest domains**: string 2,735 of 2,876 judged (95 percent), list 1,199 of
  1,276 (94), system 1,363 of 1,612 (85), regex 402 of 497 (81), number 1,630 of 2,103
  (78), graph 797 of 1,080 (74), natural 553 of 839 (66), cluster 315 of 493 (64),
  stats 341 of 794 (43), datetime 217 of 582 (37), network 178 of 694 (26).

### A2 -- 2026-11-04 -- the experience

**The id law.** A check's id is `<file without .ring>#<8 hex of SHA-1(description,
actual, expected, its helpers)>`, never a line or a rank; a second check of one file with
the same text and another description takes `-2`. The guard plants a file, harvests it,
adds two lines above its second check and harvests again: both ids unchanged while the
line moved by two. The results and the verdicts are keyed by that id (re-recorded:
1,011 / 89 / 26 of 1,126 at 74757d462; Ring 967 / 70 / 89; rnxc whole = resident on all).

**The page under the law**, with the rules named beside the CSS that answers them: one
reading size (1.3125rem, the site's), mono labels and code at optical parity, nothing
under 1rem, every colour pair listed with its ratio; paper tones, one teal accent, one
resting shadow; nothing moves; the top bar sticks and holds its space; a main menu of
three short labels, the domains turned vertical at 18 percent; a trail rooted at the
Atelier's own address with the section as its current step; tables that declare their
columns, numbers right-aligned and tabular, the state the one coloured column and always
beside its word; a narrow screen sheds the context columns, never the state; a state
label sits beneath what it classifies; every control 44 px tall; space reserved before
results arrive; verbs on every button ("Run this domain", "Apply dark mode", "Lire en
français"); search over click (Ctrl+K); the library's compile told in words with its
seconds. The page is one file at three addresses (`/atelier`, `/atelier/coverage`,
`/atelier/playground`), so the menu is real links and the back button holds.

**Measured by StzZui's own instrument** (`tools/ui-audit.html`, Rules 105, 107, 108,
114-116, through a same-origin front that serves the tool from the stzzui checkout and
proxies the rest to the Atelier): the first run found 10 violations on 5 pages -- the
trail's current step lacked the class the tool reads (5) and the disabled button lost
contrast through its opacity (3.70:1, 5); after marking the step and disabling by colour
and a dashed border, **0 violations on 5 pages in light and 0 in dark**. The tool is
stzzui's; the Atelier only reads and runs it.

**Language is data.** 105 keys asked by the page, 100 in each dictionary, French with every
English key, checked by the guard; the page switches whole, numbers formatted per
language; the choice is remembered and `?lang=` overrides it. A reader's browser in
French opens the page in French.

**Guard** `base/test/atelier/atelier_page_narrated.ring`: 24 assertions, about 80 s: the
id law on a planted harvest (SKIPPED by name when python is not on the path), the three
files sharing ids, the dictionary whole and every key the page asks for present, the
three addresses served, the dictionary route, the trail, the menu of three, nothing
moving, the reading size, what judges a check named.

**Left for A3 and beyond.** The fonts the site loads (Fraunces, IBM Plex) are named first
and fall back to the system's: the Atelier carries no font files. The old page is gone;
its comparison with the private server project never came here.

### A3 -- 2026-11-04 -- reach

**(a) The install carries `atelier/`.** Ring++'s `bench/package.py` copies `libraries/stzlib` whole
except its skip folders (`.git`, `zig-out`, `archive`, `future` and the like), the engine's
sources and, unless asked, `base/test`, `max/test`, `core/test`; `atelier/` is none of them, so it
rides in every install with no change to Ring++: about 1 MB of data and sources. **Measured by
emulation, without touching the install:** a folder laid out as an install (the real library by
junction, `PACKAGE.txt` beside, the Atelier's runtime files only in `atelier/`) booted with the
installed rnxc, named itself `0950e246a (installed)` / `ringpp a8ad844 (installed)`, served the
page and ran 300 checks (263 pass, 30 fail, 7 error: the install's library is older than the
checks, as the page says). What an install lacks is `base/test`: the checks carry their own code,
so the Atelier and its recorder run from an install; the sweep of whole files (`tours.ring`) needs
the tests and is a maintainer's tool. **Still owed, and Ring++'s:** the same boot from a package
actually re-laid with a library that carries `atelier/` (the current install, laid at
`0950e246a`, predates it). Asked through Central.

**(b) The static edition.** `python build_static.py --out <folder>` (since 2026-11-06 `rnxc
edition.ring build-checks --out <folder>`, see "A3 in Ring++" below) writes
`<folder>/<commit>/`: `index.html`, `coverage.html`, `check.html`, `data/` (the four files a commit
carries), `edition.json`, and appends `editions.json`. Built from this commit's own data: 872 KB, 8
files, the 1,129 checks, their recording and the sweep, nothing fetched and nothing run. It is derived
from a pinned commit, so nothing built is committed. It **refuses to mix** (the checks harvested,
the recording and the sweep must name one commit; the guard plants a sweep at another commit and
sees it refused with the file to take again), has **no `--out` default** (a folder inside the library
would ride into an install; the builder refuses one, and the guard tries), carries **no Ring column**
and no playground, and **replaces any drive path by `<path>`**, counting what it replaced. The page
in edition mode shows the recorded state with the commit it was recorded at, the answer of every
check that did not pass (`results.json` keeps it now), and for each check its citation and a link to
its own page. **Measured with StzZui's own audit tool** (Rules 105, 107, 108, 114 to 116) through a
same-origin front over the built edition: the index, the coverage page, a check page and the two
French pages: 0 violations, light and dark.

**(c) The embed contract, `EMBED.md`.** A check is cited as `<commit>:<id>`: the commit the check
was recorded at and its stable id. `cite.py <commit>:<id>` (now `rnxc edition.ring cite`) resolves one from the data a pinned
commit already carries, or refuses with exit 2 and the reason (another commit, an absent id, not a
citation); the guard checks all three refusals. `check.html?id=<id>&embed=1` is a card for a frame.
What a citing page owes the reader is written down: name the commit, never quote a count without
its edition, show the five states apart, no Ring comparison, a page's stage stays the author's.
Handed to stzsite (prompt 58) and ayouni (prompt 59) through Central, with the reasoned refusal each
may give.

**A leak found and mended.** The `tours.json` committed at A1 carried three paths of the machine
that took it (the sweep's own reason texts named the Atelier's folder and the install's), in a public
tree whose rule is no machine path. The recorder and the sweep now replace this machine's folders by
`<library>`, `<tree>` and `<rnxc>` at the source; the builder is a second line; and a guard scans
every data file and source of the Atelier for a drive path (it failed on that very file until the
sweep was taken again, then passed). **The three paths remain in the history of main**, at the A1 and
A2 commits: rewriting a shared public history is not this plane's to do, and is named to the author.

**The recording and the sweep at one commit** (`c08f96dee`, on main at both remotes, on the
package's engine, rnxc a8ad844, the CPU fit to measure): 1,129 checks, 1,014 pass / 89 fail / 26 error; Ring
(the oracle, its tree older) 967 / 70 / 92, rnxc whole equal to the resident on every check. The
sweep: 1,418 tours (the Atelier's and testoor's own guards skipped by name), 1,324 finished, 31
broke, 55 never started (54 the one Rule A refusal), 8 hung, 41 kept their class; **20,287 Then
lines read, 15,206 judged (74.96 percent): 15,069 kept, 137 diverged**, 4,923 unreached, 158
unjudged. The same refusals, the same hung tours as at A1: the coverage moved with the tests, not
with the Atelier.

**A recording must name a commit that exists.** The first recording of A3 named `50671dca8`, the
code commit as I had it before the rebase that precedes a push; the rebase made it `23d053b8b`, and
every citation of `50671dca8` would have pointed at a commit main does not have. Found by reading
the push's own output against the data, mended three ways: the builder now refuses, inside a git
checkout, a recording whose commit is not an ancestor of HEAD (naming the cure); the static guard
builds the Atelier's own committed data and so fails on exactly this; and the order is now written
down: **push the code, then record at it, then commit the data**, so the recording names a commit
that is already final. The data was taken again at `c08f96dee` (the commit that carries the check).
The figures above are that second taking; the first one agreed with it to the digit (the tests
moved by nothing between the two).

**Guards after A3.** Static 41 of 41 (26 s), checks 36 of 36 (53 s), page 24 of 24 (42 s), tours 42
of 42 (148 s), one process each, under rnxc a8ad844, the CPU fit to measure.

### B0 -- 2026-11-05 -- the cell (the workbench's first rung)

The author ratified the workbench design (`SOFTANZA_WORKBENCH_DESIGN.md`) by saying go on B0.
**The notebook is the Atelier's home now** (`/` and `/atelier`); the checks moved to
`/atelier/library` and the playground is gone, because a cell does all it did and more.

**The cell.** `POST /atelier/cell` takes the reader's code, rewrites every `?` line to
`AtelierSee(<n>, <expression>)` -- so its value comes to the Atelier instead of the server's
stdout, where nobody reads it -- admits the cell as one admission and releases it. Each value
comes back in its own **face**: text (a string or a number), list (`@@`, with its count), table
(a `stzTable`'s own `ToHtml()`, which the page reads and copies into a table of its own, never
inserts), drawing (anything that answers `ToSVG()`, eleven classes today, shown as an image so it
runs no script), image (`ToPngDataURI()`), object (its `Content()`). Every `#-->` promise, trailing
or on the lines under its `?` as the library's own files write them, is judged after the run by
**testoor's own matcher** (`_TravPromiseAt`): one court for the library's tests and the reader's
cells. A `?` in a loop is seen once per pass. A cell that breaks keeps the promises before the
error and leaves the ones after it unreached; a cell that does not scan never starts.

**Measured** (rnxc a8ad844, fit to measure): the default cell -- a scene over a `stzList`, a
boxed find, a bar plot -- runs in 2 ms; a plot cell in 10 ms. **Not captured, and said so on the
page**: what a method prints by itself, which goes to the server's console (ATELIER-CAPTURE-14).
**Not measured yet**: the faces of a cell's outputs by the StzZui audit, which loads pages
without running them.

**Found on the way, mine.** (1) Removing the domains submenu left one stray closing tag that ended
the page's margin early: every section after Checks touched the left edge from 119762334 to now;
seen in a screenshot, fixed, and the body's tags now count 30 opening and 30 closing. (2) Since A3
the live trail's root pointed at `/atelier`, not the site root (Rule 108); the A3 audit ran only on
the static edition, where the root resolved, so it missed it. The live home is `/` now; StzZui's
audit: 0 violations on 6 pages, light and dark. (3) Four empty `catch` blocks in the server,
each leaking a VM stack slot per caught error in a long-lived program (Ring++'s checker, F-16):
filled.

**Guard** `base/test/atelier/atelier_cell_narrated.ring`: 43 assertions, 15 to 33 s -- a scene
seen with its promises kept, a promise diverged, each face (list, table, drawing, object, text), a
loop seen per pass, a broken cell (kept, then unreached), a cell that does not scan, a function
defined in a cell released with it, the notebook served as home and the checks at their address.

### B1 -- 2026-11-05 -- the process

**The chain, unfolded.** A `?` line whose expression is a chain -- a root (a name, a call, or
`new Class(...)`) followed by method calls, alone or inside `@@( )` -- is rewritten so each step
runs once, into a variable, on what the step before it answered, timed on the engine's monotonic
clock (`StzEngineWatchTimestampNs`). **Measured first, because it decides correctness:** plain
variables COPY a Ring object, so `_a_ = o2.AddQ(1)` then `_a_.AddQ(2)` leaves `o2` at 1 where the
chain written whole leaves it at 3; `ref()` keeps the chain attached (3), on rnxc although
`isfunction("ref")` answers 0, and refuses a number or a string. So every step but the last is held
by `ref()` (a step followed by a method is an object), and the last by a plain variable. The guard
proves it: `o1.RemoveDuplicatesQ().AddQ("soup").Content()` unfolded leaves `o1` as the line
written whole does. What is not a chain (`1 + Q("ab").NumberOfChars()`) is not unfolded. A chain
in a loop keeps the steps of its first pass. A step's value is a LIGHT face (an intermediate
object is never asked to draw itself), its time in microseconds.

**The forms.** When every method but the last ends in Q (each returns the object), the same move
is offered as a scene (`root { Verb() ? Last() }`) and as the classic form (a name, then one line
per call). The page offers them with "Put this form in the cell", which replaces the line in the
cell, its promise carried to the form's `?` line; the reader runs it. Forms are never run behind
the reader's back. Measured: the scene form of the default chain, put in the cell and run, keeps
its promise.

**The scene, unfolded.** A line that is only `name {` opens a scene: the object's state is captured
after the opening and after every COMPLETE statement inside it (braces and brackets counted outside
strings; a call over several lines is captured once, when it closes; a line that opens a block is
not a capture point), and the page marks the lines that changed it. Measured in the default cell:
`DuplicatesRemoved()` leaves `o1` unchanged, `RemoveDuplicates()` changes it -- the function forms
(`Verbed()` answers, `Verb()` changes) seen, not told. Inside the braces the scene's own name
reaches the object, and an assignment there makes a global, not an attribute (probed).

**The page.** Under each line seen: the chain's steps (step, call, value, microseconds) and its
forms; above the lines: each scene's table (line, code, answer, the object after it, changed or
unchanged). Text columns' headers aligned with their data (Rule 11, a defect seen in a screenshot
and fixed). StzZui's audit: 0 violations on 5 pages, light and dark. The rendered outputs, which
the audit cannot reach (it loads pages without running them), measured the same way on a run
notebook: lowest contrast 5.88:1 light, 5.97:1 dark; smallest text 17 px.

**Guard** `base/test/atelier/atelier_process_narrated.ring`: 37 assertions, about 30 s. The page
guard learned a key family (`proc_form_` + the form's name): 25 assertions.

### B2 -- 2026-11-05 -- the notebook

**A notebook IS a narrated test file.** Running cell k runs cells 1 to k as ONE admission, top to
bottom, so a name a cell makes is the one the cells below it read, exactly as a file read once
would make it. Nothing is kept between two runs: a run is the file from its first line
(measured: a name assigned in one run is unknown to the next, `isglobal` answers 0, because an
assignment at the top of an admitted unit makes a name of that unit, released with it). Ring ends a
function where the next definition begins, so each cell's definitions -- from its first line opening
with `func`, `def` or `class` -- move after every cell's statements; a `map` answers, for each line
of the composed file, the cell and the line of that cell it came from, and the page puts every
result back under its own cell. Running up to cell 2 leaves cell 3's definitions out, so a cell that
calls a helper defined below it stops at the call, named (`R3`), and says so.

**Then lines.** A `Then("description", actual, expected)` on one line is judged by `=`, as the
narrated suite judges it: its actual value seen in its face, its expected value shown as code
(`@@`), kept or diverged. A cell has two ways to promise: `? expr` with `#-->`, and `Then`.

**Saved, opened, forked.** "Save as a test file" writes the notebook as a narrated file: the two
loads, a `Scenario` per cell (a title keeps its own quotes, wrapped in a mark it does not use),
`Summary()`, then each cell's definitions under `# definitions of cell N`. "Open a test file" reads
such a file back into its cells, blank lines included; the one blank line the saver writes before
each marker is the file's and is dropped (a defect the probe found: a cell with statements AND a
helper came back one blank line longer). A library check opens in the notebook as its own `Then`
line: all 1,156 checks are a single `return AtelierThen(actual, expected)`, so the fork is exact, and
the cell is never run behind the reader's back.

**The court.** The guard saves a notebook into `base/test/_planted_notebook/` (ignored) where its own
loads resolve, testoor's reader reads it (narrated, one stop per cell, the stops named by the cells'
titles), and testoor's RUNNER walks it in a child rnxc: 3 kept and 1 diverged, the notebook's own
counts. The page: cells with a title, "Run up to here" and Ctrl+Enter, "Run every cell", add, delete
with undo, kept in the browser's storage (B0's single cell, if a reader had one, becomes the last
cell rather than being lost). StzZui's audit: 0 violations on 10 pages, English and French, light and
dark. The rendered outputs measured on a run notebook: lowest contrast 5.55:1 light, 5.97:1 dark,
smallest text 17 px; nothing scrolls sideways at a phone's width.

**Guard** `base/test/atelier/atelier_notebook_narrated.ring`: 38 assertions, about 90 s, of which
about 30 s is testoor's child rnxc.

### B3 -- 2026-11-06 -- the lessons

**The Learning System's chapters, opened as notebooks.** `/atelier/lessons` offers every course of
`base/education/` that has written chapters (the elementary introduction and mathematics, 15 each;
kernel-puzzles plans 13 and has written none, so it is not offered), each chapter in every language
it is written in. The module is READ through its public calls and never written: `StzProgramQ`,
`CourseQ`, `ChapterQ` (its blocks: prose, cells, exercises), `WorldFileOf`, `ExerciseQ`, and
`StzLearnerQ`. Its plane was told before the work began, in its mailbox.

**A chapter runs as the education runner runs one.** Every cell in one program over the chapter's
world (`EduUseWorld`), each cell inside its own `try`, so a cell that raises does not hide the cells
after it, and the cell's error is its own. Each cell is judged by the COURSE'S court,
`StzEduMatchPromises`, on what its `?` lines printed, in the order they ran. Measured with
`lessons_court.ring` against the education plane's own runner (a fresh process per chapter) on all
30 English chapters: **199 cells, 196 agree, 3 unperceived, 0 disagree**; the Atelier answers a
chapter in 30 to 200 ms where the fresh process takes 0.5 to 14 s. The three unperceived cells draw
with `Show()`, which prints by itself where the Atelier reads only what `?` lines give
(ATELIER-CAPTURE-14): a promise written after such a line, and not met, is UNPERCEIVED -- testoor's
fifth state -- never diverged.

**An exercise is the learner's own.** "Check my answer" calls `StzLearnerQ(folder).Submit`, which
runs `stzExercise.Check` in a fresh process (0.5 s measured) from the learner's own folder, and
writes the verdict with its sha256 evidence: the Atelier never writes progress itself. The answer
never names the expected value (the course's `WhyIn`). Learners live under the Atelier's ignored
`_work/learners/<name>`, a name kept to letters, digits and dashes; an id the page sends must be one
the program lists, never a path. A pass counts only while the work file is the one the court ran
(the plane's law 9), and the page says which.

**What the reader sees.** Course, chapter, language and learner as four selectors; the address
carries the choice. The prose read by a small, safe markdown reader (escaped first); Arabic right
to left with its code left to right; a translation no person has reviewed opens with a draft
notice (the plane's E10 rule, `IsReviewed`). Under each cell: its lines' faces and chains as in the
notebook, then the court's verdict promise by promise. StzZui's audit: 0 violations on 10 pages,
English, French and Arabic, light and dark; a run Arabic lesson measured: lowest contrast 5.55:1
light, 5.97:1 dark, smallest text 17 px, nothing scrolls sideways at a phone's width.

**Three defects found on the way, all fixed and guarded:**
- **ATELIER-REFTHIS-16, the VM ended.** B1 held each step of an unfolded chain with `ref()`. In
  ADMITTED code, a method called through a `ref()` variable that copies `This` (`x = This`, or
  `new X(This)`) ends rnxc with a segmentation fault; the same file run plainly prints the right
  answer. So `? o1.ContainsDuplicates()` ended the Atelier, notebook or lesson. Smallest program,
  18 lines and no Softanza, routed to Ring++. The unfolding no longer uses `ref()`: every call goes
  to the root object itself -- the name, or a fresh object in a plain variable -- while each step
  answers that same object (`AtelierSameObject`: same class, same content; the house's VerbQ
  methods return This), and to the step's own value from the first step that answers another
  object. The one case this reads wrong is a step that answers a COPY of its object (CopyQ), then a
  step that changes it: named in the code.
- **A `?` line indented with a TAB was never seen.** Ring's `trim()` strips the space only, so the
  planner missed `\t? x`: seven chapter cells. `AtelierTrim` strips both. The notebook had the
  same blind spot since B0.
- **Rule A refused two chapters.** Ring++ will not admit a cell naming a top-level `n` or `c`,
  because a library function reads that name as an unassigned local. A chapter is written for a
  plain run, so a lesson's statements run inside ONE function, where they are locals shared from
  cell to cell, as in a file. The notebook keeps top-level names: a notebook cell that meets Rule A
  is refused with Ring++'s own message, which names the rule.

**Guard** `base/test/atelier/atelier_lessons_narrated.ring`: 47 assertions, about a minute; its
court runs the education plane's own runner on two chapters, one of which names a variable `n`.

### B4 -- 2026-11-06 -- the edition of a notebook

**A3's rule, generalised from the checks to a notebook.** No output is stored as truth: an edition
shows a RECORDING named by its commit. `rnxc edition.ring record <notebook>` has a running Atelier
read the notebook file and run every cell, and writes `<name>.recording.json` beside it: the
library commit, the Ring++ build, the engine, when, the file's sha256, every cell with its id
(`notebook/<name>#<8 hex of the sha256 of its title and code>`), and the Atelier's whole answer.
`build` makes ONE static page of it -- the page, the recording and the dictionary in a single
file, nothing fetched, nothing run -- at `<out>/<commit>/notebook/<name>/index.html`, and lists it
in `<out>/notebooks.json`. `cite` resolves `<commit>:notebook/<name>#<hash>` to the cell, its code,
each line it saw with the value and verdict recorded, and what judged it. The contract is
EMBED.md, section 8.

**Refused, because each would make a citation lie:** a notebook changed since it was recorded (its
sha256 is not the recording's), a commit not in this history (rebased away or never landed), a
recording naming a folder of a machine, and an out folder inside the Atelier's own.

**Written in Ring++** (`atelierEdition.ring`, the functions a guard calls in-process, and
`edition.ring`, the command line): the author's ruling of 2026-11-05 that the library's tooling is
library code. A3's `build_static.py` and `cite.py` were Python and predated the ruling; they were
ported on 2026-11-06 (below).

**The page.** The same `atelier.html` in a third mode: the edition's eyebrow and lead say what it
is, its status names the recording, the menu goes (nothing runs), every cell carries its citation
and a link to itself, and a chain's forms are shown without the button that would put one in a
cell. Its trail begins at the page itself: a notebook edition is a one-page site, and a site that
embeds it brings its own trail. StzZui's audit, the notebook's folder served as the root: 0
violations on 4 pages, English and French, light and dark.

**One fact paid for:** the engine's system call wraps its line in a shell of its own, so a
`cd /d <folder> && ...` inside it ends with that inner shell and the command runs where the caller
stands. A program that must start a tool in another folder moves there itself (`chdir`) first.

**The example**, `atelier/notebooks/a-first-notebook.ring` (the notebook page's four default
cells) and its recording, committed after the code, at the commit that landed it.

**Guard** `base/test/atelier/atelier_edition_narrated.ring`: 38 assertions, about a minute.

**And a flake explained.** The checks guard twice named two checks of
`natural/entity_world_narrated` as moved from pass to error, with nothing said. Measured on a fresh
Atelier: the first of them builds the entity world, 48 s, and every later check of that file takes
milliseconds. The client gave a check 60 s; under load the build crossed it, the client gave up with
no answer, and the next check, queued behind it, read as an error too. The limit is 300 s now, with
the reason beside it: a timeout is never a verdict on the library. The 48 s is the natural plane's
to know, and is in CONCLUSIONS.

### A3 in Ring++ -- 2026-11-06 -- the checks' edition and citation, ported

**The author's ruling of 2026-11-05, applied to A3.** `build_static.py` and `cite.py` are gone;
their work is two verbs of `edition.ring` beside B4's, over functions in `atelierEdition.ring`:
`rnxc edition.ring build-checks --out <folder> [--allow-mixed] [--from <folder>]` and `rnxc
edition.ring cite <commit>:<id> [--data <folder>] [--format json|markdown|html]` (an id beginning
`notebook/` is B4's cell and still takes its recording as `--data`). Every promise of EMBED.md
sections 4 and 5 is kept: the mix refused unless allowed, a commit outside this history refused,
machine paths replaced by `<path>` and counted, the same files at the same paths, no Ring column.

**Checked against the Python tools as an oracle before they were deleted.** On this commit's own
data both wrote the same eight files; every JSON file parsed equal, `edition.json` apart from its
`built` time, `editions.json` equal, and the three pages equal byte for byte outside their
`EDITION` line, whose value parsed equal. Six citations in three formats each (three checks spread
over the harvest and three that did not pass, with what they said): json and markdown equal; html
equal once the shared escaper writes an apostrophe as `&#x27;`, as Python's did.

**The data is copied as text, never parsed and written back.** The parser answers a null as `""`
and a true as `1`, so a writer could not give back what it read; the page reads the text as it
is. The machine-path scrub therefore works on the JSON text: a backslash followed by another (or
by a slash) belongs to the path, any other escape ends it, so the path stops where the decoded text
would stop it and the JSON stays well formed (the guard parses the scrubbed failure back). 38 ms
over the 395 KB of `checks.json`.

**One defect found on the way, in B4's shared helper:** `_AtelierIsInside` compared a relative
`--out` with an absolute Atelier folder, so `--out _x` given from the Atelier's own folder read as
outside it. Both paths are made whole against the working folder now.

**Guard** `base/test/atelier/atelier_static_narrated.ring`: 46 assertions, about a minute, no
Python; it calls the functions in-process and starts the command line twice for its exit codes
(a mixed build exits 2, a check's citation exits 0). Until today it SKIPPED whole without Python.

**For the sites that cite.** stzsite's `tools/atelier.py` and ayouni's book call the Python tools
on a PINNED tree; a pin before this commit keeps them, and a pin at or after it calls
`rnxc edition.ring build-checks --out <folder>` and `rnxc edition.ring cite <commit>:<id> --format
json` from the pinned tree's `atelier/` folder instead. The JSON a citation answers has the same
keys. Routed through Central; neither repository is edited from here.
