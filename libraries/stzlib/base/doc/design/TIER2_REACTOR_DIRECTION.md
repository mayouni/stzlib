# Tier 2 -- Reactor Direction (libuv backbone)

> Status as of 2026-06-14 (session 69). Decision taken and the
> foundation landed: libuv is vendored, compiles from source on Windows,
> and runs end-to-end through the Ring FFI. This doc records the why, the
> architecture, and the open decision, so the multi-session arc has a
> stable plan.

## Decision

**Vendor libuv (C) as the cross-platform async I/O backbone; do not
hand-roll a reactor, and do not reinvent what mature libraries already
do.** (User directive: "build with libuv and avoid reinventing the
wheels.")

### Why libuv (vs libxev / hand-rolled)

* **Industry strength, not a toy** -- libuv is the reference
  implementation of cross-platform async I/O (Node.js, Julia, Neovim;
  ~15 years at scale on every platform).
* **Windows IOCP is the critical path** here (primary dev/build
  platform) and libuv's IOCP layer is the most battle-tested in
  existence. libev/libevent are weak on Windows; libxev's IOCP is far
  younger.
* **Vendoring C is the established pattern** -- utf8proc, pcre2, sqlite
  already compile from source in `build.zig`. libuv joins them via
  `addLibuv` (file lists + defines + system libs mirror libuv's
  CMakeLists v1.52.1).
* **Decoupled from Zig churn** -- a stable C89 ABI won't break across
  compiler bumps, unlike libxev which pins tightly to Zig versions.

### Why this does NOT violate the M-DEP dependency-freedom rule

M-DEP forbade external **Ring** extensions (`load "libuv.ring"` etc. in
stzBase that hunt for runtime DLLs). Vendoring libuv **as C source
compiled into an engine DLL** is the utf8proc/pcre2/sqlite pattern -- a
different layer entirely. The Ring side still loads only first-party
`stz_*` modules.

## What landed (session 69 -- foundation slice)

* `engine/vendor/libuv/` -- libuv v1.52.1, `include/` + `src/` + LICENSE
  (docs/test/tools pruned). ~2 MB.
* `build.zig` -- `addLibuv(mod, lib, b, os_tag)`: common sources + per-OS
  sources (win / unix+linux / unix+darwin), per-OS defines, and Windows
  system libs (psapi/user32/advapi32/iphlpapi/userenv/ws2_32/dbghelp/
  ole32/shell32). New `stz_reactor` base domain with `needs_libuv`.
* `engine/src/reactor.zig` -- `@cImport("uv.h")`; `reactor_version()`,
  `reactor_version_hex()`, `reactor_selftest()` (arms a one-shot timer on
  a real loop, returns callbacks fired).
* Bridge `StzEngineReactorVersion` / `StzEngineReactorSelfTest`; loader
  `stz_reactor.ring`; test `reactive/55_reactor_narrated.ring`.
* **Verified:** `zig build` clean on Windows (libuv compiled from source
  first try); Ring smoke prints `libuv version: 1.52.1` and self-test
  `1` (loop ran, timer fired).

## Architecture (how the reactor meets Ring)

Ring is synchronous and single-threaded per script. The reactor does NOT
push callbacks into Ring. Instead:

* The engine owns one (or a few) **libuv loop(s) on dedicated worker
  thread(s)**. Each loop multiplexes many sockets via IOCP/epoll/kqueue.
* Ring submits work and drains results through the **existing
  submit/poll handle pattern** (the `StzEnginePool*` idiom:
  `submit -> job id`, `poll(id) / poll_with_deadline(id)`), plus the
  caller-side deadline already shipped. So from Ring's side the API stays
  blocking-looking; the concurrency win is wall-clock + scale, not a new
  programming model.
* This reuses the cancellation tokens, retry budget, latency histograms,
  and outlier ejection from Tier 1 as the resilience layer around it.

## Build-or-buy ladder (planned slices)

1. **Foundation (DONE, s69)** -- vendor libuv, prove build/link/run.
2. **Reactor core (timer op DONE, s70)** -- a `uv_loop` on a dedicated
   worker thread, cross-thread submission via `uv_async_send` + a
   mutex-guarded job table, and the libuv two-phase handle-lifetime
   handshake (free a job only once its `uv_close` callback fired AND the
   caller polled). First async op is a timer; Ring stays synchronous via
   `StzEngineReactorCreate/SubmitTimer/Poll/Await/Pending/Destroy`.
   Tests: reactor.zig 5/5 Zig (incl. 32 concurrent timers + clean
   destroy with in-flight/undrained jobs), reactive/56_reactor_core 6/6.
   **Remaining in this slice:** async TCP connect/read/write on the same
   machinery, then migrate the blocking `tcp.zig` server + polling timer
   onto the loop.
3. **Scale HTTP** -- the open decision below.
4. **HTTP/2** -- vendor **nghttp2** (the standard; what curl/nginx use).
5. **TraceContext** -- W3C `traceparent` propagation (pure code).
6. **Work-stealing / multi-loop** -- N loops on N threads (libuv's
   model), balanced submission.

## OPEN DECISION (before slice 3)

**HTTP stack: keep the custom `httpcore.zig` over the reactor, or adopt
vendored libcurl?**

* **Keep httpcore + reactor + nghttp2** -- preserves the Tier 1 HTTP
  client; we make it async over the loop and add h2 via nghttp2.
  Incremental; more code we own.
* **Adopt vendored libcurl** -- libcurl's `multi` /
  `curl_multi_socket_action` interface rides directly on a libuv loop
  and gives HTTP/1.1 + h2 (+ h3) + TLS (Schannel on Windows) + pooling +
  DNS cache + proxy + redirects in one battle-tested lib, superseding
  `httpcore.zig` / `http_pool.zig`. Most "buy not build"; retires recent
  custom transport (Tier 1 Ring API + resilience survive as wrappers).

Recommendation on file: lean libcurl for the HTTP use case specifically,
but settle it after the reactor core (slice 2) lands and we can measure.

## Requirement check (do not skip)

"10k+ connections per worker" is the gap-analysis framing. Confirm the
real workload needs it before building the full multi-loop scheduler --
for many Softanza uses (scraping, API calls, agentic loops), libcurl's
interface on the existing thread pool already handles hundreds of
concurrent transfers. Build the reactor for a number that's actually
needed.
