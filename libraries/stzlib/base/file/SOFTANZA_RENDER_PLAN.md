# The render plane -- escape by construction, the twin, the door, the benchmark

*Plane `stzlib-render`, opened 2026-10-22 on the compass reading of Proa (2026-10-21).
Four disciplines taken from Proa, no code. Stage words: **built** (the file or guard
that shows it is named), **designed** (written here, not yet runnable), **absent**.*

## 1. What the plane is for

A page has more than one reader, and an AI agent is one of them. The library writes
HTML for people, JSON for programs and agents, SVG for both, and until RX0 each writer
escaped what it wrote, or did not, by itself. The plane settles four things:

1. **Escape by construction, with one declared door** -- text is the default and
   markup the exception. RX0, RX1.
2. **A twin check** between the projections of one document, with its limits printed.
   RX2.
3. **A door for an arriving agent** -- `AGENTS.md`, short, routing. RX3.
4. **A benchmark method** that is dated evidence and compares with nothing. RX4,
   after the compass re-rates the plane on RX2's memo.

## 2. The census (RX0, 2026-10-22, read at `origin/main` edfb6d00a)

| sink | escaped on RX0 | callers passing text that could be untrusted |
|---|---|---|
| `stzHtmlBuildNode.SetText` / `SetAttr`, under `stzHtmlBuilder` (`base/file/stzHtml.ring`) | nothing | 0 outside its own file |
| `stzUiDocument._Escape`, the `.panel` HTML projection (`base/gui`) | `& < >` | 0: a `.panel` is the application's own file, and its names are validated identifiers |
| `stzAppResponse.ObjectToJson`, under `Json` (`base/appserver`) | nothing | 4 of 37 call sites echo request text (`stzAppServer` 1319, 1334: the URL's id; 1402: the URL's agent name; 1672: the signed-in user's name) |
| `stzAppServer._RowJson` / `_RowsJson` | the quote only | every call: the rows are what clients posted through `/api` |
| `stzPlatform._WebShell` (`base/platform`) | nothing | 0: the world's name and screens come from the application's declaration |
| `stzAccessibilityTree.ToJSON` (`base/gui`) | `\ " \n \t`, never CR or NUL | 0: the same declarations |
| the SVG tier: `stzCanvas.ToSVG` and every emitter over it (`stzDiagram`, `stzOrgChart`, `stzMathFigure`, the plots in `base/stats`) | nothing to escape: the engine writes glyph **outlines**, never a `<text>` element, and `SetSvgIdent` **refuses** a bad identifier (`gpu_scene.zig` 405) | -- |

Escapers found: seven HTML or XML escapers in Ring beside one engine face, and
**eight JSON string escapers in Ring with eight policies and none in the engine**.
So RX1 was a **repair** at the app server's two JSON writers and a **hardening**
everywhere else. The word *vulnerability* is not used: what a client obtains from the
two writers is an invalid body, not an execution.

Filed to their owners, not this plane's: `stzLog._EntryJson` leaves CR, LF and the
other controls in a message (`base/common`); guard `52_html_dom_engine_narrated`
fails its first assertion on main and `base/file/stzHtml-copy.ring` is loaded by
nothing (`base/file`); the `.panel` reader walks its source with `substr` per
character (`base/gui`); the sound plane's two `_Xml` escapers and `stzTable._HtmlEscape`
still escape in Ring (their desks).

## 3. The disciplines as they stand

### 3.1 Escape by construction -- **built** (RX1, 2026-10-22)

- **The faces.** `StzHtmlEscaped(c)` and `StzHtmlAttrEscaped(c)` in `stzHtml.ring`
  are the engine's `html_encode` and `html_encode_attribute`; `StzJsonString(c)` in
  `stzJsonFuncs.ring` is the engine's `stz_json_encode_string` (`json.zig`), the text
  as a JSON string literal with its quotes, every control byte escaped, UTF-8 passed
  through. No Ring-side escaper stands beside them: `stzString.HtmlEscaped`,
  `stzUiDocument._Escape`, `stzAccessibilityTree._Q`, `stzAppServer._JsonEsc` and
  `_EscapeJsonString` are faces over the engine now.
- **The builder.** `SetText` and `SetAttr` escape when the document is written.
  `SetMarkup` / `SetMarkupQ` is the **one declared door** that writes as given, and
  the node answers `IsMarkup()`; the builder carries the flag through its copies. An
  attribute **name** is validated (a letter or underscore, then letters, digits,
  `- _ : .`) and refused otherwise: there is no raw door for a name. `SetUrlAttr`
  refuses `javascript:`, `vbscript:` and `data:` whatever their case or the control
  characters hidden inside them, because escaping cannot make a scheme safe.
- **No double escaping, decided and tested:** a pre-escaped text given to `SetText`
  is escaped again, because text means text; a caller holding markup says so.
- **The court.** The code rule `raw-markup-door` (`base/meta/stzCodeRules.ring`)
  counts every use of `SetMarkup` at severity **info**, never a ban, so all of them
  can be read in one report. A mention in a comment or a text, and the definition
  itself, are not uses.
- **The oracle.** `base/test/render/escape_sinks_narrated.ring`: a sixteen-entry
  hostile corpus handed to every sink, the output parsed back with the engine's own
  HTML and JSON parsers, asserting on the mechanism (no undeclared element, no
  event-handler attribute, the text decoded back as given, the JSON round-tripping,
  the SVG free of text and script). Red on RX0 (8 of 25), green since RX1 (40 of 40),
  with the negative siblings above. The A/B proof: the education reader's page for
  one chapter in English and Arabic is byte for byte what it was (15,814 bytes, the
  same sha256), through `_ab_edu_probe.ring` beside the guard.
- **Perception.** The guard writes `escape_sinks_rendered.html` beside itself: the
  corpus as a page, one row per entry. **Perceived** by the Principal on 2026-10-22,
  "every row reads as plain text"; the record is `escape_sinks_perceived.md` beside the
  guard. The eye found what no counter did: the bidi row reads `cba`, the override
  control having passed through as text. **Ruled and built the same day** (see the
  bidi policy below): the page was regenerated and **perceived again by the Principal on 2026-10-22**:
  the bidi row reads `[U+202E]abc[U+202C]` in reading order, nothing else moved.
- **Bidi policy -- built** (ruled by the Principal, "bidi: yes", 2026-10-22; the JSON half
  refined the same day by "escape"). Escaping cannot address a control character, so it
  is its own step: the engine's `html_neutralize_bidi` (`html.zig`, Ring face
  `StzBidiNeutralized`) replaces each of U+202A to U+202E, the five embeddings and
  overrides, with a visible ASCII marker such as `[U+202E]`; `StzHtmlEscaped` and
  `StzHtmlAttrEscaped` apply it first, so the builder, the panel's HTML, the web shell
  and every HTML text carry it. **JSON is lossless instead**: the engine's
  `stz_json_encode_string` writes the same five as the JSON escapes `\u202a` to `\u202e`,
  which a parser reads back as the exact character and a raw view shows as text, so the
  accessibility JSON and the response writers keep the data and lose nothing. The
  **isolates** (U+2066 to U+2069) and the **marks** (U+200E, U+200F) are kept in both:
  the library writes Arabic and Hebrew and they are legitimate there. **Limits**: the
  HTML marker form is lossy by design; the twin rule reports a box whose content holds
  one of the five as dropped by the HTML twin, because that twin carries the marker and
  the accessibility twin the exact character; `_EduEsc` and the Ring escapers left to
  other desks do not apply the policy yet. Guard: the Bidi scenario of
  `escape_sinks_narrated.ring`, with its negative siblings (the isolates, the marks, a
  truncated sequence, U+202F, plain text, a 24,000-byte run and its 18,002-byte JSON).
- **The gate for a new concatenating writer -- built** (asked by the Principal, "gate",
  2026-10-22). The code rule `markup-concatenation` (`stzCodeRules.ring`, severity **info**,
  the sixteenth) counts every line that joins a tag literal to a dynamic operand with no
  escaping face on it. It is a **text heuristic over one line, not a data-flow analysis**,
  and says so in each finding: it has false positives (an operand escaped or validated on
  an earlier line, as in the platform shell) and misses a tag built in one statement and
  joined in another. Today it counts **189 lines in 26 of 874 files** (the largest: the
  emulator 47, the education reader 35, the sound staff 23 and notation 18), recorded in
  `base/test/render/markup_concat_baseline.txt`. The **ratchet** is
  `markup_concat_gate_narrated.ring`: it walks the library and fails when a file counts
  more than its baseline or a file not in it counts any; a lower count is reported so the
  baseline can be lowered. It was shown failing on a probe file with a new writer and on a
  lowered baseline entry, and green at the baseline. It costs about a minute: run it once
  before a commit that touches a writer. `markup_concat_census.ring` prints the lines.

### 3.2 The twin -- **designed**

A rule `twin-coverage` between the three projections of a `.panel` document (HTML,
text, accessibility JSON): every named box's text is carried by each twin; an
exception needs a written reason; a stale exception is reported; the court never
writes one; the report prints its limits ("does not certify equivalent meaning,
order, cardinality, or accessibility"). Lives in `base/meta` with the other rules,
in the unified shape through `stzRuleReport`. A comparison proves sameness, never
rightness.

### 3.3 The door -- **absent**

`AGENTS.md` at the repository root, about 150 lines that point: a task-to-document
table, one canonical fixture per kind of work, a decision tree, "when stuck", the
verification commands (the fast path, Testoor's runner and its exit codes 0, 1, 2),
and what stzlib does not own. `CLAUDE.md` stays the law. A dead-link guard runs in a
fresh checkout. `stz check` is listed as planned, never as built.

### 3.4 The benchmark method -- **absent**

`BENCH_METHOD.md` and a parity-gated run over three canonical outputs, with hardware,
date, p50, p95, worst and memory; never a multiple against another framework.
