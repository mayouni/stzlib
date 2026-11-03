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
| `atelier.html` | the page: the checks by domain, the playground |
| `atelierClient.ring` | functions a Ring program uses to boot an Atelier, run checks over HTTP, compare two recordings, write a results file (the guard and the recorder load it after the library) |
| `record.ring` | maintainer: boots an Atelier, runs every check, writes `results.json`; `rnxc record.ring` from this folder |
| `harvest.py` | maintainer: harvests `checks.json` from `../base/test` (or `--tests=`) |
| `verdicts.py` | maintainer: Ring's verdicts, `RING` and `RING_TREE` from the environment |
| `checks.json` | the checks: id, domain, file, line, scenario, description, code |
| `results.json` | the last recording: what judged it, the counts, each check's state -- the guard's baseline |
| `verdicts.json` | Ring's answers, and what they were taken on |

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
`POST /atelier/stop`.

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

### A1 -- Coverage -- PLANNED

13,092 `Then` lines wait on the variables their scenario set up. Run a WHOLE scenario as one
admission on the resident server (admit, run, release: about a millisecond at Softanza's
size, where a child process costs 4-5 s before its first line). Read the tests through
testoor's reader (`Tour`, `stzLogbook` JSON), never a second harvester. Keep the five stop
states apart -- kept, diverged, unreached, unjudged, unperceived -- and never fold them
into pass and fail. Agree with testoor's runner on the files both judge: that agreement is
the court. Coverage is `Then` lines judged over the 19,604, per domain; the harvested
checks are the floor.

### A2 -- The experience -- PLANNED

The page under StzZui's law at its live version, in French and English like the site.
Browse by domain, search; each check shows its provenance (file, line, scenario, library
commit); the playground kept; the five states shown apart; a check's id stable when its
file changes elsewhere.

### A3 -- Reach -- PLANNED

(a) The install already carries `atelier/`; verified on the next package re-lay, which is
Ring++'s (asked through Central). (b) A static edition per library commit -- the checks,
their results and the page in read-only mode, built by one command -- for the site, which
cannot run code, and the books, which pin a commit. (c) An embed contract: how a page or a
book cites a check (an id at a commit) and shows it; handed to stzsite and ayouni through
Central.

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
