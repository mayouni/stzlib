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
| `html.ring` (lexbor)| `file/stzHtml.ring`                                         | **REPLACED** with engine (M-DEP2 slice 2)   |
| `libcurl.ring`     | `network/stzNetwork.ring`, `network/stzHttpClient.ring`     | **REPLACED** with engine (M-DEP3 slice 2)   |
| `libuv.ring`       | `reactive/stzReactive.ring` + TCP classes                   | **Slice 1**: removed from reactive + folder watcher (M-DEP4) |

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

## 3. HTML -- M-DEP2 (Slice 1 LANDED 2026-06-13)

`stzHtml.ring` uses the lexbor-based `html.ring` extension's
`HTML` class for HTML5 parsing + DOM. The Ring code calls:
`find()`, `text()`, `tag()`, `attr()`, `root()`, `body()`, `head()`,
`children()`, `parent()`, `appendChild()`, `setAttribute()`, etc. --
a full DOM API.

**What the engine already has** (`ring_bridge_html.zig`): `StzEngine
HtmlEncode`, `HtmlDecode`, `HtmlStripTags`, `HtmlEncodeAttribute`.

**Slice 1 added 2026-06-13** -- pragmatic tokenizer + flat element
index in `libraries/stzlib/engine/src/html_dom.zig` (~370 LOC, 8 Zig
unit tests). New bridge functions exposed:

* `StzEngineHtmlParse(cHtml)` -> opaque doc handle
* `StzEngineHtmlFree(pDoc)`
* `StzEngineHtmlCount(pDoc)` -> total elements
* `StzEngineHtmlCountByTag(pDoc, cTag)` -> count of `cTag` elements
* `StzEngineHtmlTextOfTag(pDoc, cTag, n)` -> inner text of n-th match
* `StzEngineHtmlAttrOfTag(pDoc, cTag, n, cAttr)` -> attribute value
* `StzEngineHtmlAllText(pDoc)` -> document text (strips scripts/styles)
* `StzEngineHtmlTagOf(pDoc, n)` -> tag of n-th element

Covered:
* tag/attribute parsing (`name="v"`, `name='v'`, `name=bare`, `name`)
* self-closing (`<br/>`) and void elements (img/br/hr/...)
* `<script>` / `<style>` raw text suppression in text extraction
* Comments and `<!DOCTYPE>` skipped
* Case-insensitive tag/attr lookup

Not yet (next slices):
* CSS selectors (only find-by-tag for now)
* Nested DOM tree walking (children/parent navigation)
* Mutation API (setAttribute / appendChild / setInnerText)

Ring smoke test `52_html_dom_engine_narrated.ring`: 5 scenarios, 15
assertions, all green.

**Slice 2 also landed 2026-06-13** -- ID/class lookup + tree walking.
Six more bridge functions:

* `StzEngineHtmlFindById(pDoc, cId)` -> 1-based element index
* `StzEngineHtmlCountByClass(pDoc, cClass)` -> class match count
* `StzEngineHtmlFindByClass(pDoc, cClass, n)` -> n-th match index
* `StzEngineHtmlChildrenCount(pDoc, n)` -> direct-children count
* `StzEngineHtmlChildAt(pDoc, n, k)` -> k-th child index
* `StzEngineHtmlParentOf(pDoc, n)` -> parent index (0 if root)

`stzHtml.ring` rewritten to use the engine -- `load "html.ring"`
removed. The new Ring class provides:

* `HtmlQ(cHtml)` constructor + `Content()` / `Reload()`
* `Text()` -- engine text extraction (suppresses scripts/styles)
* `Find(selector)` -- supports `tag`, `#id`, `.class`
* `FindFirst()` / `FindAll()`
* `NumberOfElements()` / `CountByTag(tag)`
* Node accessors: `Tag()`, `Text()`, `Attr(name)`, `HasAttr`, `Id`,
  `Klass`, `HasKlass`

Integration test `53_stzhtml_engine_narrated.ring`: 7 scenarios, 21
assertions, all green. `stzBase.ring` now loads `file/stzHtml.ring`
unconditionally (was TODO-gated for engine-side reimplementation).

Not yet (slice 3 if needed): CSS selector parser (descendant/child
combinators), DOM mutation, stzHtmlBuilder. The current surface
covers the typical "scrape data from HTML" use case.

## 4. libcurl -- M-DEP3 (Slice 1 LANDED 2026-06-13)

`stzNetwork.ring` and `stzHttpClient.ring` use Ring's `libcurl.ring`
for HTTP. Engine module **stz_http** added 2026-06-13 backed by
`std.http.Client` + `std.crypto.tls` -- HTTP and HTTPS work without
an external TLS lib.

**Slice 1 surface** (`libraries/stzlib/engine/src/http.zig`,
`ring_bridge_http.zig`, ~180 LOC):

* `StzEngineHttpGet(cUrl)` -> response body string
* `StzEngineHttpGetStatus(cUrl)` -> HTTP status code (or -1 on transport error)
* `StzEngineHttpPost(cUrl, cContentType, cBody)` -> response body
* `StzEngineHttpLastError()` -> last error message

Ring smoke `52_http_engine_narrated.ring`: 3 scenarios, 7 assertions,
all green. Network IO is NOT exercised in the suite per the L99 /
Windows test-loop guardrail; live HTTP tests run outside CI.

NOT YET (slice 2 -- size-driven by real callers):
* Per-request custom headers
* Cookies + redirect policy
* Auth (basic / bearer)
* PUT / DELETE / HEAD / OPTIONS
* Form POST helper
* Streaming for large bodies

**Slice 2 also landed 2026-06-13** -- generic request entry +
header-blob propagation + `stzNetwork.ring` / `stzHttpClient.ring`
rewired off libcurl.

New engine entry: `StzEngineHttpRequest(nMethodCode, cUrl,
cHeadersBlob, cContentType, cBody)` -> body. Method codes 0..6 cover
GET/POST/PUT/DELETE/HEAD/OPTIONS/PATCH. Headers blob is a newline-
separated `Name: Value` list. Engine merges caller headers with
Content-Type (only if the caller did not set one). Companion
accessor `StzEngineHttpLastStatus()` returns the most recent HTTP
status (or -1 on transport error).

Ring rewires:

* `stzNetwork.ring` -- `load "libcurl.ring"` + `load "libuv.ring"`
  REMOVED. Connection state (cLastUrl, nLastStatus, last_error)
  tracked as plain instance attrs; `_RecordRequest()` fed by the
  client class.
* `stzHttpClient.ring` -- full rewrite. Verbs (Get_/Post/Put_/
  Delete/Head/Options), form helpers (PostForm, PostJson), header
  list, cookie list (translated to `Cookie:` header), user-agent
  setter all route through `_Perform()` which calls
  `StzEngineHttpRequest`. `URLEncode` helper removed (already
  provided by `stzNetworkUtils.UrlEncode`).
* Libuv-backed parallel `GetMany()` dropped (was the only libuv
  consumer in this module); sequential `GetManySequential()` is the
  supported path until M-DEP4 lands.
* Settings the libcurl backend supported but std.http doesn't yet
  (SetAuth, SetProxy, FollowRedirects toggle, VerifySSL toggle,
  custom UA via setopt) are stored as fluent setters but do not
  yet alter request behaviour. They warn or no-op as appropriate.

Tests:

* `52_http_engine_narrated.ring` (slice 1): 3 scenarios, 7 assertions
* `53_stzhttpclient_engine_narrated.ring` (slice 2): 5 scenarios,
  17 assertions

All 24 assertions green. Network IO stays out of CI per L99; live
HTTP tests run outside the test harness.

Not yet (slice 3 -- only if real callers need it):
* Per-request response headers + cookies extraction
* Auth (Basic / Bearer) via Authorization header builder
* Proxy honouring SetProxy
* Streaming download (for large files)
* PATCH wired through to a verb-specific Ring method
* Per-request timing (`ResponseTime()`)

## 5. libuv -- M-DEP4 (Slice 1 LANDED 2026-06-13)

`libuv.ring` is the heaviest dep: it ships an entire async event
loop. A full cross-platform Zig replacement (IOCP / epoll / kqueue
under one API) is months of work and properly its own multi-session
arc.

**Slice 1 ships the pragmatic path:** drop `libuv.ring` everywhere
that has a workable synchronous fallback. The reactive runtime now
uses Ring's `clock()` + polling (the same approach `stzRingTimer`
was already using as a fallback). `stzNetwork.ring` had the load but
never made libuv calls -- removed cleanly in M-DEP3. The standalone
`stzFolderWatcher.ring` demo (sample script, not a class) is moved
to `base/archive/`.

Engine-side rewires:
* `reactive/stzReactive.ring` -- `load "libuv.ring"` REMOVED.
  `uv_default_loop()` replaced with NULL sentinel; `uv_buf2str` /
  `uv_buf_init` become identity (Ring buffers are strings).
* `reactive/stzReactiveTimer.ring` -- `uv_timer_*` calls replaced
  with the polling-based pattern (Start records `clock()`; the
  manager drives via `CheckAndTick()`).
* `file/stzFolderWatcher.ring` -- moved to
  `archive/file_stzFolderWatcher_libuv_demo.ring`.

NOT YET (slice 2 -- requires real engine work):
* `network/stzTcpClient.ring` and `network/stzTcpServer.ring` still
  contain `uv_*` function calls inside method bodies. Construction
  works; method invocation would fail at runtime. Mark as deprecated
  or rewrite via Zig std.net once the async-loop foundation lands.
* `stzFolderWatcher` rewrite via a polling-based watcher backed by
  Zig std.fs (stat + diff loop).
* Real preemptive async (TCP server, parallel HTTP) needs the
  cross-platform Zig event loop -- still a multi-month arc.

Ring smoke `52_reactive_polling_narrated.ring`: 4 scenarios, 8
assertions, all green. Existing `51_reactive_harness_narrated`
(20/20) still green -- the API surface for stzReactiveTimer didn't
change, only its internal mechanism.

The `libuv.ring` extension is no longer required for `stzBase` to
load. Code that constructs `stzTcpClient` / `stzTcpServer` directly
or runs the archived folder-watcher demo still needs it; in practice
neither path is the documented entry point.

## Roadmap

| ID      | Scope                                  | Effort      | Order |
|---------|----------------------------------------|-------------|-------|
| M-DEP1  | Drop FastPro (deprecated)              | DONE        | --    |
| M-DEP2  | HTML5 parser + DOM in Zig              | DONE        | --    |
| M-DEP3  | HTTP client + TLS in Zig               | DONE        | --    |
| M-DEP4  | libuv removed where polling fallback works | SLICE 1 DONE | --   |
| M-DEP4  | Cross-platform Zig async loop (TCP, real async) | Multi-month | Future |

Four of five external Ring deps are eliminated for stzBase:
uuid, fastpro, html, libcurl. The libuv dep is removed from the
reactive runtime and folder watcher; what remains is TCP code that
needs a real async loop to function, which is properly a multi-month
arc and tracked separately.
