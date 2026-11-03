# Testoor protocol, version 1

*What a tour, a face and the logbook owe each other, written so that no sentence depends on
the language a tour is written in. Ring is the first face. Haro and anything else is the next.
The Ring code reads this document's contracts and nothing else about a language: the guard
`base/test/testoor/testoor_protocol_narrated.ring` proves it by running Python tours through
the same runner and getting the same logbook.*

## 1. Three contracts, and nothing more

| contract | between | what crosses |
|---|---|---|
| the **tour record** | a face and the core | what a tour contains: its stops, the claims at each, the routes it walks |
| the **child's output** | a running tour and the core | verdicts, a seed, weather, an end, as plain lines |
| the **logbook** | the core and everyone | JSON on a pipe, prose on a terminal, from one run |

A **face** is everything language-specific, and it is *data plus one reader*: a profile that
says how to launch a tour and how its errors read (section 5), and optionally a reader that
fills the tour record before the tour runs. The core (runner, judge, routes, seeds, logbook)
knows no language.

## 2. The tour

A tour is a program a face can launch. It is started **by argv, with its own folder as the
working directory**, and its argv ends with `--testoor-seed N`. It prints to stdout. Its exit
code belongs to its virtual machine and is never the runner's verdict (the runner decides 0,
1 or 2, section 6). A tour reads the seed from that argument, or ignores it.

## 3. What a tour prints

Every line is optional, stands alone, and is read after trimming. Text after the keyword runs
to the end of the line.

| line | meaning |
|---|---|
| `[testoor stop TITLE]` | a stop opens: a place the traveller stops and looks |
| `[testoor ok TEXT]` | a claim at the open stop was kept |
| `[testoor fail TEXT]` | a claim at the open stop diverged |
| `[testoor plan N]` | the tour will make N claims; any it never prints are **unreached** if it died, **unjudged** if it ran to its end |
| `[testoor route ID]` | the tour walks plan item ID (a route) |
| `[testoor seed N]` | the seed the tour actually used; wins over the one the runner offered |
| `[testoor weather NAME@TICK]` | a fault the tour declared, to fall due at TICK |
| `[testoor weather fired NAME@TICK]` | that fault fell due |
| `[testoor end timed]` | the tour finished and was timed (what `pf()` means in Ring) |

Also accepted, because they are plain text any language can print: `[OK] TEXT` and `[PASS]
TEXT` for a kept claim, `[FAIL] TEXT` for a diverged one.

A tour that prints stop, ok and fail lines **describes itself** and needs no reader at all.
That is the whole price of a new language at its cheapest: a six-line helper.

```python
def stop(title):  print("[testoor stop %s]" % title)
def ok(text):     print("[testoor ok %s]" % text)
def fail(text):   print("[testoor fail %s]" % text)
def check(text, cond):  (ok if cond else fail)(text)
```

## 4. The five states, and the tour's ending

A **stop** has five states and no sixth: `kept`, `diverged`, `unreached`, `unjudged`,
`unperceived`. The last two are neither a pass nor a failure. A stop is as bad as its worst
claim: diverged, then unreached, then unjudged, then kept; a stop with no claim is unjudged.

A **tour** ends one of six ways: `finished`, `finished-timed`, `not-started` (nothing ran: a
compile error, a missing file), `broke` (it ran and a runtime error ended it), `hung` (killed
at the deadline) or `unreadable` (the reader could not read it). A claim that printed nothing is
**unreached** when the tour did not run to its end and **unjudged** when it did.

## 5. A face

A profile is a list of named fields:

| field | meaning |
|---|---|
| `:name` | the face's name, shown in the logbook |
| `:ext` | the file extension it owns, with its dot |
| `:reader` | `"ring"`, `"zst"` or `"protocol"`; `"protocol"` means the tour describes itself |
| `:program` | what launches a tour; `""` means the virtual machine running Testoor itself |
| `:launch` | the argv, with `{program}`, `{file}` and `{seed}` filled in; `[]` makes the face read-only |
| `:endings` | `[ [ text, ending ] ... ]`, tried in order against the tour's output and error stream |
| `:ignore` | a line prefix the endings must not read |

`TestoorRegisterFace(aProfile)` adds one. An extension with no face is **named, not guessed**:
the record says why and the runner reports it. When no ending rule matches, a non-zero exit is
`broke` and a zero exit is `finished`.

## 6. Exit codes, the runner's

0 when every stop is kept or unperceived; 1 when a stop diverged, a tour did not start, broke
or hung, or a tour is flaky; 2 when the runner itself refused. Unjudged is reported and is not
counted against.

## 7. The logbook

One run, one JSON object, with these keys (`TestoorLogbookKeys()` returns them and the
conformance guard checks them):

- **run:** `testoor`, `kind`, `by`, `root`, `topic`, `refusal`, `exit`, `owned`, `run`,
  `wall_ms`, `timeout_ms`, `seed`, `repeat`, `flaky`, `claims`, `tours_by_end`, `skipped`,
  `topics_skipped`, `tours`.
- **tour:** `file`, `dialect`, `state`, `end`, `exit`, `wall_ms`, `seed`, `flaky`, `weather`,
  `kept`, `diverged`, `unreached`, `unjudged`, `stops`.
- **stop:** `title`, `line`, `state`, `wall_ms`, `seed`, `claims`.
- **claim:** `claim`, `kind`, `line`, `state`.

`owned` and `run` are two figures and are never summed.

## 8. Routes

A route is a plan item. A tour walks it by saying so (`[testoor route ID]`, or a face's own
spelling). Route coverage is the count of routes with a tour next to the count of routes owned,
and never a percentage. It needs only plan ids and declared ids, so it holds for any language.

## 9. What a new language needs

1. A helper that prints the section 3 lines. Done in a morning.
2. A profile, registered with `TestoorRegisterFace`. Done in ten lines.
3. Optionally a reader, so that claims a tour never reaches are known before it runs. For
   Ring++ the parsed program is already available (`rnxc dump --json`), which beats matching
   source lines; the same idea should hold for Haro. Not built, not tried.

## 10. What stays language-bound, said plainly

The Ring reader and its six dialects; the Ring words `Seed`, `ClockTo`, `Weather`; the
stepped clock, which lives in Ring until a second consumer moves it to the engine; and the code
of the core itself, which is Ring today although ruling 12 puts counting, seeds, the clock and
the logbook shape in the engine. The *contracts* above are the part that does not move when it
does.

## 11. Conformance

A face conforms when the same fixtures give the same logbook. The guard runs a kept tour, a
failing tour, a tour that breaks, one that never starts, a seeded tour that fails at 42 and
passes at 43, a tour with a plan it does not finish and a tour that declares a route, each
written in Python and printing only section 3 lines, and compares the logbook with the key list
of section 7.

Version 1, 2026-11-03.
