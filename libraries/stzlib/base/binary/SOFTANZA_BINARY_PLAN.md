# SOFTANZA BINARY PLAN — the binary-file plane (BN0–BN5)

Status: **PLAN OF RECORD**, written 2026-08-16, before any code.
Supersedes the ~2024 telco engagement artifacts:
`libraries/stzlib/max/system/stzBinaryFile.ring` (a 6-line stub),
`libraries/stzlib/max/test/stzCobolReaderTest.ring` (calls functions that
exist nowhere), and re-scopes `libraries/stzlib/future/stzCobol.ring`
(443 lines, a *source-code translator* — a different product, see §0.5).

Those files are **claims, not code**. The reader test invokes
`ConvertWithCopybook("example.bin", "copybook.cob", true)` and
`ebcdicToAscii()`; a repo-wide search shows neither function exists
anywhere in the library, and neither fixture (`example.bin`,
`copybook.cob`) survives. The implementation the author built under
pressure for a telco was lost or never committed — only the test that
called it remains. This plan is the revival, done the way the library
now does everything: survey, disposition, thesis, measured gates.

Siblings, whose laws this plan inherits:
`base/plugin/SOFTANZA_PLUGIN_PLAN.md` (PL0 pending),
`base/concurrent/SOFTANZA_CONCURRENT_PLAN.md` (CN0 pending),
`base/stats/SOFTANZA_TUKEY_PLAN.md` (TK0 pending),
`base/cluster/SOFTANZA_DISTRIBUTION_PLAN.md` (complete),
`engine/SOFTANZA_COMPUTE_MODEL.md` (the compute doctrine).

---

## HOW TO USE THIS DOCUMENT (session bootstrap — read this first)

This file is **sufficient on its own** for a dedicated session that has
never seen the binary work. There is deliberately no companion design
document; the strategic proposal, the design and the implementation
plan are §1, §2–§4 and §5–§6 of this one file.

### The mission, in one paragraph

Two years ago a telco handed the author a mainframe binary file and a
COBOL copybook and asked for its contents. The attempt was hard,
partial, and finally aborted — Ring alone had no engine, no
codepoint-safe byte layer, no table faces worth landing the data in.
Every one of those gaps has since been filled by other planes. The
revival is therefore **not a COBOL feature**: a COBOL copybook is just
one *dialect* of the same universal idea — a **declarative schema that
gives meaning to bytes**. The plane's dream, in the author's words: feed
Softanza the canonical format of *any* binary file and get it readable
and explorable in an easy way. The design is one sentence: **a binary
file is a table the bytes forgot to show.** A `stzBinarySchema` (pure
data) names the fields, widths, encodings and repetitions; the Zig
engine decodes a whole file in **one crossing** into columns; the result
lands in `stzTable` — where summaries, Tukey polish, plots, CSV/JSON/
SQLite export and the whole unified object system are already waiting.
And because a schema that can *read* bytes can also *write* them,
`stzBinaryFileMaker` is the same vocabulary run backwards: a declarative,
narrated, educational surface that lets a beginner mint real binary
files byte by visible byte — and doubles as the guards' fixture factory.

### Orientation — where everything is

| what | where |
|---|---|
| this plan | `libraries/stzlib/base/binary/SOFTANZA_BINARY_PLAN.md` |
| legacy claims (read once, then only via §0.5) | `max/test/stzCobolReaderTest.ring`, `max/system/stzBinaryFile.ring`, `future/stzCobol.ring`, `future/doc/stzcobol-bridge-between-ring-and-legacy-cobol-systems.md` |
| adjacent prototypes (bit/byte toys, ~2020) | `future/stzBit.ring`, `future/stzByte.ring`, `future/stzListOfBits.ring` (66 lines total, Ring-side) |
| the byte engine (exists, basic) | `engine/src/bytes.zig` (424 lines) + `engine/src/ring_bridge_bytes.zig` — handle-based buffer, hex/base64/percent |
| the byte engine's KNOWN DEFECT (fix in BN1) | `ring_bridge_bytes.zig` `ring_Left/Right/Mid/ToLower/ToUpper` return through fixed 4096-byte stack buffers — **silent truncation** above 4 KB; violates the engine list-return contract (measure, then whole items or none) |
| the byte faces (exist, thin) | `base/string/stzBytes.ring` (engine-backed), `base/number/stzListOfBytes.ring` (Ring-side) |
| file I/O engine | `engine/src/file.zig` — `stz_file_read/size/mtime/...` (whole-file; no chunk/seek yet) |
| where decoded data lands | `base/table/` — stzTable (11 capabilities in ONE class), then stats/Tukey (`base/stats/`), plots (`base/graphics/`) |
| the verdict contract for schema validation | `base/graph/stzRuleReport.ring` `[:rule,:subject,:where,:severity,:message]` |
| monotonic clocks (the only clocks for durations) | `StzEngineWatchTimestamp*` (perf laws, CLAUDE.md) |
| guards (create) | `libraries/stzlib/base/test/binary/` |
| project rules | `CLAUDE.md` at the repo root — READ IT |

### Commands

```bash
cd libraries/stzlib/base/test/binary && ring binary_physics_narrated.ring
```

### The working discipline (non-negotiable)

1. **Measure before believing anything, including this plan.** BN0 is a
   measurement phase with kill criteria written before the numbers; §5
   records this plan's predictions so they can be scored.
2. **Guards are narrated and assert the MECHANISM**, and every positive
   has a negative sibling. This plane's canonical negative siblings are
   *hostile bytes* (truncated file, wrong record length, sign nibble
   garbage, a REDEFINES that lies) — a decoder that only ever sees
   well-formed fixtures has proven nothing.
3. **Independent expectations law** (this plane's sharpest edge): a
   Maker→Reader round trip is one implementation agreeing with itself —
   the "assertions that agree by coincidence" trap in its purest form.
   Every decoding guard MUST also check at least one fixture produced
   by a **foreign tool** (Python `struct`/`codecs` via a checked-in
   generator script, byte-for-byte pinned in the guard), so the two
   sides cannot share a bug.
4. **Engine-first, one crossing per algorithm.** The decode of a file
   is ONE engine call returning columns; per-record crossings are
   forbidden on the hot path (BN0 measures why). All decode substance
   (EBCDIC tables, packed decimal, endian scalars) lives in Zig inside
   the EXISTING `stz_bytes` DLL. **Zero new DLLs** — like the Tukey
   plane, this is among the cheapest major capabilities left.
5. **Schema is DATA, never code.** A `stzBinarySchema` is a Ring
   nested list you can print, diff, store, and send — the same doctrine
   as topology-as-data in the distribution plane and `.stzui` in GUI.
   Dialects (copybook today, others maybe never — §6) COMPILE to it;
   nothing in the library interprets dialect text at decode time.
6. **Parallel sessions work this repo**: `git add <explicit paths>`,
   never `-A`. This plane owns `base/binary/`, `base/test/binary/`,
   and its named engine files only.
7. **Push protocol**: `git push origin main` then
   `git push codeberg HEAD:refs/heads/main`; verify both with
   `git ls-remote <remote> main` against `git rev-parse main`. If
   codeberg fails, say PENDING and move on.
8. **Record outcomes** in this file (`## BN<n> RESULTS`) and in memory
   (`project_binary_plane.md`) when a phase ends.

### The first action

**BN0**, exactly as specified in §5: the decode-physics spike.
Measurement only, no product code, kill criteria applied before the
numbers are interpreted.

---

## 0. THE SURVEY (taken 2026-08-16)

### 0.1 What actually exists

Four artifacts, three of them empty of implementation:

1. **`max/system/stzBinaryFile.ring`** — six lines: a `StzBinaryFileQ`
   function and `class StzBinaryFile from stzFile` with no body. It is
   loaded by `max/stzMax.ring:63`, so the NAME is already public API.
   A name, not code.

2. **`max/test/stzCobolReaderTest.ring`** — 39 lines. The live block
   calls `ConvertWithCopybook("example.bin", "copybook.cob", true)`;
   the commented block calls `ebcdicToAscii()` and narrates a real
   debugging session ("the '@' symbols in your output are likely EBCDIC
   spaces (64) converted incorrectly" — EBCDIC 0x40 is the space, and
   naive Latin-1 rendering shows it as `@`). **Neither function exists
   anywhere in the repository. Neither fixture survives.** This file is
   the fossil of the telco engagement: it proves the work reached the
   point of running against a real file and fighting a real codepage
   bug — and that the implementation was then lost or never committed.

3. **`future/stzCobol.ring`** — 443 lines that DO run as code, but are
   a **source-code translator** (Ring text ⇄ COBOL text), not a binary
   reader. It is also pre-doctrine throughout: byte-oriented `substr`/
   `len`/`upper`/`lower` everywhere, `aResult[cCurrentDivision] = ...`
   indexing an empty list by string key (raises in Ring — the
   COBOL→Ring path cannot have run end-to-end), naive line-split
   parsing of a language whose grammar is column-sensitive. Kept as a
   source of *intent* only.

4. **`future/doc/stzcobol-bridge-...md`** — a polished vision article
   about the translator. Its market analysis (Micro Focus, TSRI,
   OpenLegacy...) is about code modernization — a different market from
   data access. Its *educational* thesis, however, is exactly this
   plane's second product, transplanted from translation to bytes.

Adjacent: `future/stzBit.ring`, `stzByte.ring`, `stzListOfBits.ring` —
66 lines of ~2020 Ring-side toys (a byte as a list of 8 bits). Their
instinct (bits and bytes deserve first-class, explorable faces) is
adopted; their implementation is not.

### 0.2 What the library has built since the abort (why now)

The telco attempt failed on gaps that no longer exist:

| gap then | filled since by |
|---|---|
| no byte substrate | `stz_bytes` DLL (`bytes.zig`) + `stzBytes` face — handle-based, engine-owned buffers |
| no engine at all | the Zig engine: 60+ modules, SIMD byte loops, the compute doctrine, measured-threshold multicore |
| byte-corrupting string ops | `StzFind/StzReplace/StzSplit` engine family; the `substr` ban in CLAUDE.md |
| nowhere to land decoded data | `stzTable` (11 capabilities, ONE class), `ToCSV/ToJSON`, SQLite vendored |
| no exploration story | stats module (+ Tukey plane planned), plot pipeline (6 renderers in Zig), graphics plane ToSVG/ToPNG |
| no verdict/validation contract | `stzRuleReport` `[:rule,:subject,:where,:severity,:message]` — one CI gate |
| no perf honesty | monotonic watch clocks, seam-vs-algorithm law, narrated timed guards |
| no big-file story | cluster plane (fixed-length records split trivially), reactor for async |

The revival is thus mostly **composition** — the same shape as the
plugin plane: the hard substance (byte decode in Zig) is small and new;
everything around it already exists.

### 0.3 A defect found during this survey (pay the debt in BN1)

`ring_bridge_bytes.zig` returns `Left/Right/Mid/ToLower/ToUpper`
through fixed `[4096]u8` stack buffers and `ToBase64/ToHex/ToPercent`
through `[8192]u8`. Any slice longer than the buffer is **silently
truncated** — the exact failure the engine list-return contract
(memory: `reference_engine_list_return_contract`) was minted against:
*measure, then whole items or none*. A single mainframe record is
routinely 100–32,760 bytes, so this plane would trip it immediately.
BN1 fixes the bridge (measure size → allocate → return whole) before
any decode work sits on top of it.

### 0.4 What the field does (comparative anchors, not rules)

- **Kaitai Struct** — declarative YAML schemas compiled to parsers in
  many languages; the strongest proof that schema-as-data works. But
  the output is *code you then write programs around*; nothing lands in
  a live exploration system.
- **DFDL / Apache Daffodil** — a W3C-track schema language for any data
  format; enterprise-grade, XML-Schema-based, heavyweight.
- **010 Editor templates / ImHex patterns** — imperative C-like
  template scripts inside a GUI hex editor; exploration-first but
  program-hostile.
- **Wireshark dissectors** — the richest decoder corpus alive, all
  imperative C/Lua, protocol-scoped.
- **Python `struct` + `construct`** — format strings / declarative
  combinators; the de-facto scripting answer; no table, no stats, no
  narration.
- **COBOL copybooks themselves** — the oldest declarative binary
  schema language in production. Vendors (IBM Record Editor, various
  `cb2xml`-based tools) parse them into converters daily.

Softanza's differentiators, honestly stated: (a) the decoded file is a
**live `stzTable`** in a system that already owns summaries, resistant
statistics, plots and export — exploration is zero extra steps; (b) the
**write direction as a first-class educational surface** (no tool above
treats making binary files as a teaching act); (c) **one schema
vocabulary for both directions**, engine-decoded, measured. What we do
NOT claim: dialect breadth (Kaitai has hundreds of formats; we start
with one dialect and a native vocabulary), format *inference* (binwalk
territory — refused, §6), protocol dissection at wire speed.

### 0.5 Disposition of every legacy claim

From the four artifacts, every claim they make, dispositioned:

| # | claim (source) | disposition |
|---|---|---|
| 1 | A class named `stzBinaryFile` reads binary files (stub) | **ADOPT** — the name is already loaded by stzMax; it becomes the reader face (§2), moved to `base/binary/` with a max shim kept |
| 2 | Reading needs a copybook: `ConvertWithCopybook(bin, cob, bool)` (reader test) | **RESHAPE** — copybook becomes ONE dialect compiled to `stzBinarySchema`; the reader takes a schema, never dialect text |
| 3 | EBCDIC→ASCII conversion is required (reader test) | **ADOPT** — as engine byte-table translation (CP037 first), a field *encoding* in the schema, not a file-level "convert" verb |
| 4 | EBCDIC 0x40 renders as `@` when mis-decoded (reader test narration) | **ADOPT as guard** — the telco bug becomes a pinned negative guard: decode with the wrong codepage and assert the recognizable corruption |
| 5 | Output is "converted text" written next to the input (implied by `Convert*`) | **REFUSE** — the product is a live table/records object, not a text-file conversion; export is a table capability that already exists |
| 6 | Ring⇄COBOL source translation (stzCobol.ring, doc article) | **DEFER OUT OF PLANE** — a different product (code modernization). stzCobol.ring stays in `future/` untouched; this plane takes only the copybook *data* grammar. The commercial vehicle for this ambition is RINGBOL (Softanza Central, `prompts/30-ringbol-charter.md`, direction RATIFIED 2026-08-16, charter held until this plane's BN2 is green) — its Track 2, gated on revenue, sold as equivalence evidence rather than translation. **BN2 is therefore also a commercial gate**, not just a technical one |
| 7 | PIC clause maps to types: `X(n)`, `9(n)`, `S9(n)V9(m)` (stzCobol.ring `inferCobolPicture`) | **ADOPT** — the copybook compiler's core mapping, done right (COMP/COMP-3/zoned, scale, sign) |
| 8 | COBOL names ⇄ Ring names mechanically (`CUSTOMER-ID` ⇄ `customer_id`) | **ADOPT** — schema field names keep the copybook spelling; the table face offers the Ring-friendly form |
| 9 | Type inference from sample values (stzCobol.ring) | **REFUSE** — schemas are declared, never guessed from data; inference is the discovery problem (§6) |
| 10 | Annotation comments steer translation (`@COBOL-VAR: ...`) | **REFUSE** — schema is data (discipline #5); there is no annotation dialect |
| 11 | Educational bridge for modern programmers into legacy computing (doc article) | **ADOPT, TRANSPLANTED** — the Maker (§2.4) is the educational surface; the subject is bytes, not COBOL syntax |
| 12 | Bits/bytes as explorable first-class values (future/stzBit, stzByte) | **ADOPT** — via the existing engine-backed `stzBytes` + the annotated hex view (§2.5); the 2020 list-of-8-bits implementation is retired |
| 13 | `stzBinaryFile from stzFile` inheritance (stub) | **RESHAPE** — composition, not inheritance: the reader HOLDS a path + schema; file I/O rides `stz_file_*` |

---

## 1. THE THESIS

**A binary file is a table the bytes forgot to show.**

Every fixed-layout binary file — mainframe extract, sensor log, game
save, wire capture payload, device register dump — is rows × fields
flattened to bytes under a contract someone once wrote down. The whole
plane is the act of writing that contract down ONCE, as data, and
letting the engine replay it in either direction:

```
                    stzBinarySchema  (pure data — the contract)
                       ↑         ↓
   dialect compilers ──┘         └──────────────┐
   (stzCopybook, ...)            ↓              ↓
                          stzBinaryFile   stzBinaryFileMaker
                           (bytes→table)   (table/rows→bytes)
                                 ↓              ↓
                         stzTable → stats/Tukey/plots/CSV/JSON/SQLite
```

- **Read**: `StzBinaryFileQ("calls.bin").WithSchema(oSchema).ToTable()`
  — one engine crossing decodes every record into columns.
- **Write**: the Maker takes the same schema plus rows and emits the
  bytes — which makes it simultaneously the educational surface and
  the guards' fixture factory.
- **Explore**: the annotated hex view shows the raw bytes with each
  field's span named and colored — the bridge between "bytes are
  scary" and "bytes are a table".

The COBOL story is the founding *scene*, not the scope: BN2 ends with
the telco scenario replayed as a narrated guard — a copybook compiled
to a schema, an EBCDIC/COMP-3 fixture decoded to a table, and the
2-year-old wound closed with a green run.

### Cross-project value (why this plane pays rent everywhere)

- **Tukey plane (`base/stats/`)** — mainframe data is the *canonical*
  messy real-world input; `ToTable()` output feeds five-number
  summaries and resistant fits with zero glue. The two 2026-08-16
  planes compose into one demo: legacy file → polish → letter values.
- **Graphics plane** — byte histograms, record-structure maps, and the
  annotated hex view's visual form ride the shipped render tier.
- **Appserver/delivery** — a legacy file behind a route: decoded once,
  served as JSON; the "modernization without migration" story real
  integrators pay for.
- **Cluster plane** — fixed-length records make byte-range splitting
  exact; a 10 GB file fans out across nodes along record boundaries.
- **MicroRing (device placement)** — the SAME schema vocabulary
  describes device frames, register maps and sensor packets; the
  kernel decode is engine code MicroRing can call or the schema can be
  shared as data.
- **Ringine** — game asset and save-file formats are fixed-layout
  binary; the Maker builds them declaratively.
- **Zing / Zing Studio** — "import your legacy data" becomes a schema
  paste, not a consulting engagement.
- **Security module** — parsing untrusted bytes is this plane's threat
  surface; Zig decode is bounds-checked by construction, and the fuzz
  guard (§4) makes "never crashes on garbage" a tested property, not a
  hope.
- **The narration culture** — the Maker is the first surface designed
  to TEACH low-level layout to non-specialists: declare, make, see the
  hex, read it back. Low-level literacy without a C compiler.

---

## 2. DESIGN — the vocabulary and the faces

All faces live in `base/binary/`. Naming follows the house Q
convention (Q = chainable object, plain = data) and the suffix
morphology (registered morphemes, one-line delegation to one options
core).

### 2.1 `stzBinarySchema` — the contract, as data

A schema is a Ring nested list; the class is a thin validator/compiler
around it. The authored surface:

```ring
oSchema = StzBinarySchemaQ([
    :name    = "CALL-RECORD",
    :endian  = :Big,                 # file default; fields may override
    :text    = :Ebcdic037,           # file default text encoding
    :record  = [                     # fixed-length record, fields in order
        [ :field = "CUSTOMER-ID",  :type = :Text,          :size = 10 ],
        [ :field = "CALL-DATE",    :type = :Text,          :size = 8  ],
        [ :field = "DURATION-SEC", :type = :U32            ],
        [ :field = "AMOUNT",       :type = :PackedDecimal, :digits = 9, :scale = 2 ],
        [ :field = "REGION",       :type = :Zoned,         :digits = 3 ],
        [ :field = "FLAGS",        :type = :Bytes,         :size = 2  ]
    ]
])
```

Scalar types v1 (closed list, extended only by phase):
`:U8 :U16 :U32 :U64 :I8 :I16 :I32 :I64 :F32 :F64` (endian-aware),
`:Text` (encoding-aware: `:Ascii :Latin1 :Utf8 :Ebcdic037` first;
`:Ebcdic500 :Ebcdic1140` when a guard needs them),
`:PackedDecimal` (COMP-3: 2 digits/byte, sign nibble C/D/F),
`:Zoned` (overpunch sign), `:Bytes` (opaque, hex-rendered).
Structure v1: flat fields + `:occurs = n` (fixed repetition, fields
become `NAME(1)..NAME(n)` columns). Structure v2 (BN4): `:variants`
(the REDEFINES answer — a discriminator field selects one of several
layouts), variable-length records (RDW-prefixed).

`Compile()` produces the flat descriptor the engine consumes (offsets
and lengths resolved, encodings as table ids) — computed once, cached
on the object. `Check()` returns house-shape rule verdicts (overlaps,
unknown types, record length mismatch vs file size) through
`stzRuleReport`.

### 2.2 `stzBinaryFile` — the reader

```ring
oFile = StzBinaryFileQ("calls.bin")
oFile.WithSchema(oSchema)          # or WithCopybook("calls.cob")
? oFile.NumberOfRecords()          # size/recordLen, validated
aRec  = oFile.Record(5)            # one record, decoded (list of pairs)
oTab  = oFile.ToTableQ()           # THE landing: one crossing, whole file
oFile.Explore()                    # annotated hex view of record 1..n
```

Laws: `ToTable()`/`Records()` decode in **one engine call** returning
columns; `Record(n)` is the convenience form and may cross per call
(it is not the hot path — BN0 prices this). Files larger than a
measured threshold decode in record-aligned batches (`RecordsSection(i, j)`)
— the threshold is a BN4 measurement, not a guess. Hostile input never
raises out of the engine: short tails, bad sign nibbles and impossible
lengths come back as per-field/per-record verdicts (`DecodeReport()`),
because a 40-year-old file WILL contain garbage records and the tool
that stops at the first one is useless in the field.

### 2.3 `stzCopybook` — the first dialect compiler

Pure-Ring parser (small text, cold path — engine-first does not apply;
same reasoning as the plugin kernel): level numbers, `PIC` clauses
(`X/9/S/V`, parenthesized repetition), `USAGE DISPLAY/COMP/COMP-3`,
`OCCURS n TIMES`, `REDEFINES` (v2 → `:variants`), `FILLER`, `VALUE`
(ignored for layout), group items (flattened with dotted names,
offset-computed). Output: a `stzBinarySchema` — nothing downstream
knows COBOL existed. `88`-level condition names compile to nothing in
v1 (recorded, not interpreted).

### 2.4 `stzBinaryFileMaker` — the writer, and the teacher

Same schema, opposite direction:

```ring
oMaker = StzBinaryFileMakerQ(oSchema)
oMaker.AddRecord([ "CUST00001", "20260816", 245, 12.50, 7, "0000" ])
oMaker.AddRecord([ "CUST00002", "20260816", 61,  3.25,  2, "0000" ])
oMaker.Narrate()     # the educational voice: each field, its bytes, WHY
oMaker.Save("demo.bin")
```

`Narrate()` is the declarative-educational product the author asked
for: it walks the schema and the staged rows and *shows the layout
happen* — "AMOUNT = 12.50 → COMP-3, 9 digits scale 2 → 5 bytes:
`00 00 01 25 0C` (sign nibble C = positive)" — the kind of knowledge
that today lives only in veteran specialists' heads, made visible in
one method call. Placement note: the Maker is OF this plane
(`base/binary/`); the system module gains only a pointer, not a copy —
duplicated homes drift.

Second product: the Maker is the **fixture factory** for every guard in
§4 — with the independence law (discipline #3) keeping it honest.

### 2.5 The annotated hex view

`Explore()` / `stzBinaryFile.HexView()` renders bytes in the classic
offset/hex/rendered-text triptych, with schema spans labeled — console
first (ASCII only, per house rule), `ToSVG()` via the graphics plane
later (BN4, optional). This is stzBytes' missing exploration face, and
works schema-less too (plain hex dump of any `stzBytes`).

---

## 3. THE ENGINE SEAM

All decode/encode substance extends the EXISTING `stz_bytes` DLL
(`bytes.zig` + `ring_bridge_bytes.zig`). **Zero new DLLs.** New engine
surface, sized by BN0:

- `stz_bytes_decode_records(data, len, descriptor, out...)` — the one
  crossing: schema descriptor in, per-field column buffers out,
  engine-measured (list-return contract: measure → allocate → whole
  items or none). Returns a status stream alongside data (field-level
  verdicts as parallel arrays, not exceptions).
- `stz_bytes_encode_records(...)` — the Maker's mirror.
- Encoding tables: EBCDIC CP037⇄ASCII/UTF-8 as 256-byte tables in Zig
  (data, checked against a Python `codecs`-generated table in a guard —
  independence law applied to the TABLE itself, because the telco bug
  in §0.5 #4 was exactly a wrong table).
- Packed/zoned decimal: decode to f64 when `digits ≤ 15` (exact in
  f64), else to a digit string — the f64 boundary law from the perf
  grind applies to MONEY, and 9(15) is common in finance; the guard
  pins both paths.
- Bridge repair (§0.3): the fixed `[4096]u8` returns in
  `ring_Left/Right/Mid/ToLower/ToUpper` and `[8192]u8` in the codecs
  are replaced with measured allocation. This lands FIRST in BN1 —
  decode must not sit on a truncating substrate.

Multicore: decoding is table-lookup + memcpy — likely memory-bound.
The plan predicts fan-out does NOT pay below hundreds of MB (§5
prediction P6); it is gated by the same measured-threshold doctrine as
everything else, and simply not built unless BN0/BN4 numbers demand it.

---

## 4. GUARDS (`base/test/binary/`)

Narrated, mechanism-asserting, timed with monotonic clocks. The core
set, each positive with its negative sibling:

1. **`binary_physics_narrated`** (BN0) — the measurement scene; see §5.
2. **`binary_schema_narrated`** — schema compile: offsets/lengths
   right; sibling: overlap and unknown-type schemas produce verdicts,
   not decodes.
3. **`binary_decode_narrated`** — Maker-made fixture AND
   Python-made fixture (checked-in `_make_fixtures.py`, bytes pinned)
   decode identically; per-type value assertions incl. sign, scale,
   endian; sibling: same bytes with the WRONG schema produce the
   *predicted* misreads (the anti-coincidence proof), and truncated
   tails yield verdicts not crashes.
4. **`binary_ebcdic_narrated`** — CP037 round trip vs the foreign
   table; the telco `@` bug replayed: wrong-codepage decode shows the
   recognizable corruption (§0.5 #4), right codepage shows spaces.
5. **`binary_copybook_narrated`** (BN2) — the telco scene end-to-end:
   copybook text → schema → EBCDIC/COMP-3 fixture → table → a stats
   summary line. The closing of the wound, run for real.
6. **`binary_maker_narrated`** (BN3) — declare/make/read-back; the
   `Narrate()` output asserted (it is product, not decoration);
   sibling: a row that does not fit its field (11 digits into 9)
   is refused at `AddRecord` time with a house verdict.
7. **`binary_hostile_narrated`** — the fuzz guard: N random-byte
   buffers through every decoder; the assertion is *no crash, verdicts
   only*, and the count of clean-vs-verdict records is printed (a
   number, not a vibe).
8. **`binary_bigfile_timed`** (BN4) — the 100 MB scene, batches,
   thresholds measured and asserted as BANDs from measurement.

---

## 5. PHASES

### BN0 — decode physics (measurement only, no product code)

Fixtures: Python-generated, 1M records × 80 bytes (the classic card
image size; mixed field types incl. EBCDIC text and COMP-3). Measure:

- M1: one-crossing engine decode of all records to columns (a throwaway
  Zig spike function is allowed — it is a probe, not product).
- M2: the same decode in a pure-Ring loop (`ring_len`-bounded, engine
  byte access) — the honest same-language baseline, so the seam and
  the algorithm are split per the seam-vs-algorithm law.
- M3: per-record crossing cost (call `Record(i)` 10k times) — prices
  the convenience API.
- M4: EBCDIC translation throughput alone (table lookup, MB/s).
- M5: file read cost (`stz_file_read`) vs decode cost — is I/O or
  decode the bound?

**Predictions, recorded before the numbers** (scored in BN0 RESULTS):

- P1: engine one-crossing decode of the 80 MB scene lands under
  300 ms.
- P2: the pure-Ring decode is ≥ 100× slower (it will be minutes).
- P3: per-record crossing costs 2–10 µs; fine for `Record(n)`,
  disqualifying for loops — the one-crossing law holds.
- P4: EBCDIC table translation runs ≥ 1 GB/s scalar; SIMD gather is
  unnecessary.
- P5: I/O (~80 MB read) is < 20% of total; decode dominates → decode
  optimization is the right investment.
- P6: multicore fan-out would not pay below ~200 MB; not built.

**Kill criteria, written before the numbers:** if M1/M2 shows < 10×
engine advantage, the decode core stays a Ring-side loop over `stzBytes`
and the plane ships faces-only (the engine work is then vanity). If M3
per-record cost is < 1 µs, the one-crossing law relaxes to
"batch by default, per-record permitted". Neither is expected; both
would reshape §3 and be recorded here.

### BN1 — the spine

Bridge repair (§0.3) FIRST. Then `stzBinarySchema` (+ `Compile()`,
`Check()`), engine `decode_records` for scalar types + `:Text`
(ASCII/Latin1/EBCDIC037) + packed/zoned, `stzBinaryFile` with
`Record/Records/ToTable/DecodeReport`, guards 2–4 green. The stzMax
stub is redirected to the real class (shim kept so `max` loading is
unbroken).

### BN2 — the copybook dialect, and the telco scene

`stzCopybook` compiler (§2.3), `WithCopybook()`, guard 5 green. The
plan's emotional gate: the 2024 reader test's intent finally RUNS —
rewritten as `binary_copybook_narrated` with made fixtures, since the
originals are lost.

### BN3 — the Maker

`stzBinaryFileMaker` + `Narrate()` + engine `encode_records`; guard 6;
all prior guards' fixtures re-cut through the Maker where the
independence law allows (foreign fixtures STAY — they are the law).

### BN4 — exploration and scale

Annotated hex view + `Explore()`; batch/streaming API with the
measured threshold; `:occurs`, `:variants` (REDEFINES), RDW
variable-length records; guard 8. Optional: `HexView().ToSVG()` via
graphics.

### BN5 — the field-dialect decision

A short comparative pass: does a Kaitai-subset or DFDL-subset importer
pay rent, or is the copybook + native vocabulary enough? Decided by
DEMAND (a real second dialect in hand), not by completism. Default
answer is REFUSE and close the plane.

---

## 6. REFUSALS (written now so they need no re-arguing)

- **No format inference.** Guessing a schema from bytes (binwalk-style
  discovery) is a different, research-grade product. Schemas are
  declared. A future discovery face would be its own plan.
- **No self-describing container parsing as plane scope.** ZIP, PNG,
  ELF, PDF... have structure this vocabulary can partially express, but
  doing them justice means dedicated modules (stzZipFile already
  exists). The plane provides the vocabulary; it does not promise the
  catalog.
- **No COBOL source translation.** §0.5 #6 — `future/stzCobol.ring`
  stays where it is, untouched by this plane. If code modernization
  ever revives, it is its own plan with its own survey.
- **No annotation dialects, no schema-from-comments.** Schema is data.
- **No wire-speed protocol dissection claims.** Wireshark's job is not
  taken; network capture decode may someday *use* the vocabulary, but
  the plane does not market it.
- **No new DLLs, no new clocks, no parallel verdict shapes.** Existing
  contracts only (discipline #4, perf law #9).

---

*BN RESULTS sections are appended below as phases close.*
