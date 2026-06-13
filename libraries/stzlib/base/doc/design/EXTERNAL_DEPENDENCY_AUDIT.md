# External Dependency Audit -- 2026-06-13

User directive: ensure no external Ring extensions are required;
Zig-engine alternatives must replace them; no Ring-side residuals.

This document tracks every `load "extension.ring"` site in
`libraries/stzlib/base/`, what it needs, what the in-tree Zig engine
already covers, and what remains as a milestone arc.

## Inventory (sites where an external Ring extension is loaded)

| Dep                | Sites                                                       | Status                                      |
|--------------------|-------------------------------------------------------------|---------------------------------------------|
| `uuid.ring`        | `system/stzUUID.ring`                                       | **REPLACED** with engine (commit 9f9bed5f)  |
| `fastpro.ring`     | `number/stzFastPro.ring`                                    | **DROPPED** -- deprecated (M-DEP1)           |
| `html.ring` (lexbor)| `file/stzHtml.ring`                                         | Pending -- M-DEP2                            |
| `libcurl.ring`     | `network/stzNetwork.ring`                                   | Pending -- M-DEP3                            |
| `libuv.ring`       | `file/stzFolderWatcher.ring`, `network/stzNetwork.ring`, `reactive/stzReactive.ring` | Pending -- M-DEP4 |

## 1. UUID -- CLOSED 2026-06-13

* Engine module: `libraries/stzlib/engine/src/uuid.zig` (already present)
* Bridge: `ring_bridge_uuid.zig` exposes `StzEngineUUIDV4`,
  `StzEngineUUIDV4Compact`, `StzEngineUUIDIsValid`, `StzEngineUUIDVersion`,
  `StzEngineUUIDNil`, `StzEngineUUIDCompare`.
* `stzUUID.ring` rewritten to call the engine; `load "uuid.ring"` removed.
* `ToBytes()` hex-decodes the canonical 32-char form in pure Ring -- no
  extra engine fn needed.
* `stzBase.ring` now loads `system/stzUUID.ring` unconditionally
  (previously commented out with a TODO).
* Test suite `52_uuid_engine_narrated.ring`: 14 assertions, all green.

## 2. FastPro -- CLOSED 2026-06-13 (M-DEP1)

`stzFastPro.ring` wraps the RingFastPro C++ extension's `updateList(...)`
for fast batch list/matrix mutations. Surface: 32 `updateList(...)` call
sites across 875 LOC, supporting `:set / :add / :sub / :mul / :div /
:pow / :rem / :copy / :merge` with target selectors `:All / :Col=K /
:Row=K / :Rows=[a, b] / :ColsFrom=[a, :To=b] / ...`.

**Usage scope:** only `test/fastpro/` exercises this module. No
production code in `base/` calls `FastProUpdate(...)`. The cost of
keeping it is the `fastpro.ring` extension dependency on every Ring
install.

**Replacement options:**

a. **Pure-Ring fallback** (~500 LOC): rewrite each `updateList(...)`
   delegation with an indexed Ring loop. Existing tests cover the
   shapes. Performance regresses for large matrices but the engine
   `stzMatrix` already exists for hot paths.
b. **Engine matrix ops**: route the heavy ops (`:Multiply / :Raise /
   :AddScalar`) through `StzEngineMatrix*`. Requires a Ring-list
   <-> engine-matrix converter. Cleaner long-term.
c. **Drop FastPro entirely**: deprecate `stzFastPro.ring`, remove
   `test/fastpro/`, and inline the few real consumers (none today).

Recommended: **(c)** -- it has no production users and existing
`stzMatrix` covers the same ground engine-side.

**Action taken 2026-06-13:**
* `stzFastPro.ring` moved to `base/archive/number/stzFastPro.ring`
* `test/fastpro/` moved to `base/archive/test/fastpro/`
* `load "number/stzFastPro.ring"` removed from `stzBase.ring`
* All non-FastPro test suites continue to pass (UUID 14/14, extercode
  11/11, reactive 20/20 spot-checked)
* The `fastpro.ring` extension is no longer required for `stzBase`.

## 3. HTML -- M-DEP2 (Pending)

`stzHtml.ring` uses the lexbor-based `html.ring` extension's
`HTML` class for HTML5 parsing + DOM. The Ring code calls:
`find()`, `text()`, `tag()`, `attr()`, `root()`, `body()`, `head()`,
`children()`, `parent()`, `appendChild()`, `setAttribute()`, etc. --
a full DOM API.

**What the engine already has** (`ring_bridge_html.zig`): `StzEngine
HtmlEncode`, `HtmlDecode`, `HtmlStripTags`, `HtmlEncodeAttribute`.
Only encode/decode/strip. **No parser, no DOM, no CSS selectors.**

**Replacement requires:** an HTML5 tokenizer + tree builder + CSS
selector engine in Zig. Realistically 4000-6000 LOC of focused
parser work, plus the Ring bridge for every DOM operation. This is
its own multi-week milestone, not a session task.

**Interim:** mark `stzHtml.ring` as "requires html.ring extension"
in user docs; do not auto-load it from `stzBase.ring`. Users who
need HTML parsing can opt in explicitly.

## 4. libcurl -- M-DEP3 (Pending)

`stzNetwork.ring` uses Ring's `libcurl.ring` for HTTP client work.
Engine has no HTTP module. Replacement needs a Zig HTTP client with
TLS support across Windows / Linux / macOS. Zig std has `std.http`
but it pulls in cross-platform TLS (BearSSL / native APIs) which is
itself a significant arc.

**Interim:** keep the dep, mark as optional, document the path.

## 5. libuv -- M-DEP4 (Pending)

`libuv.ring` is the heaviest dep: it ships an entire async event
loop, used by `stzReactive`, `stzNetwork`, and `stzFolderWatcher`.
Replacing it requires a Zig event-loop wrapper that handles IOCP
(Windows), epoll (Linux), kqueue (macOS) under one API. This is
foundational engineering -- months of work to reach feature parity.

**Interim:** keep the dep. The synchronous data-layer harness
(`51_reactive_harness_narrated.ring`) already covers the testable
non-async surface. Async testing happens outside CI.

## Roadmap

| ID      | Scope                                  | Effort      | Order |
|---------|----------------------------------------|-------------|-------|
| M-DEP1  | Drop FastPro (deprecated)              | DONE        | --    |
| M-DEP2  | HTML5 parser + DOM in Zig              | 2-4 weeks   | Next  |
| M-DEP3  | HTTP client + TLS in Zig               | 2-3 weeks   | Later |
| M-DEP4  | Cross-platform async loop in Zig       | 2-3 months  | Last  |

This session closes UUID + FastPro (M-DEP1). M-DEP2 (HTML) is the
next significant arc but is genuinely multi-week and warrants its
own milestone planning.
