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
2. **Reactor core (DONE, s70)** -- a `uv_loop` on a dedicated worker
   thread, cross-thread submission via `uv_async_send` + a mutex-guarded
   job table, and the libuv two-phase handle-lifetime handshake. Async
   timer op; Ring stays synchronous via
   `StzEngineReactorCreate/SubmitTimer/Poll/Await/Pending/Destroy`.
2b. **Async TCP (DONE, s71)** -- `tcp_request` job: a per-job state
   machine `uv_getaddrinfo -> uv_tcp_connect -> uv_write ->
   uv_read_start`-to-EOF on the loop thread, response drained via
   `reactor_tcp_poll/await`. Worked around Zig translate-c's libuv
   `uv_stream_t <-> uv_read_cb` dependency loop with opaque handle/req
   buffers (`uv_handle_size`/`uv_req_size`) + hand-written `extern`s and
   `data` at offset 0. Ring class `stzReactor` (+ `stzReactorPool` for N
   loops, round-robin). Tests: reactor.zig 7/7 incl. live round-trip;
   reactive/56 6/6, 57 6/6, 58 4/4.
5. **TraceContext (DONE, s71)** -- W3C `traceparent` generate/child/
   parse (`tracectx.zig`, in the default sweep), `stzTraceContext`,
   `stzHttpClient.StartTrace`. reactive... network/70 10/10.
6. **Multi-loop scale (DONE, s71)** -- `stzReactorPool` runs N reactors
   (libuv's recommended multi-loop model); a request batch is
   round-robined and runs concurrently. Confirm the real concurrency
   requirement before sizing large (see below).

### Deliberate non-goal: migrating the existing tcp.zig / polling timer

The blocking `tcp.zig` (stz_tcp, std.net) and the clock()-polling
`stzReactiveTimer` both work and are covered by green suites. Rewriting
them onto the reactor is a refactor of working code with marginal upside
and real regression risk, so it is **intentionally not done**. The
reactor is the forward path for *new* async work; the old paths stay
until there's a concrete reason (a measured need) to move them.
3. **Scale HTTP** -- the open decision below.
4. **HTTP/2** -- vendor **nghttp2** (the standard; what curl/nginx use).
5. **TraceContext** -- W3C `traceparent` propagation (pure code).
6. **Work-stealing / multi-loop** -- N loops on N threads (libuv's
   model), balanced submission.

## HTTP-STACK DECISION -- RESOLVED: adopted vendored libcurl (s72)

Decision taken: **adopt vendored libcurl.** `engine/vendor/curl` (8.20.0,
CMake-free via config-win32.h, native Schannel TLS) + `engine/vendor/
nghttp2` (1.69.0) deliver HTTP/1.1 + HTTP/2 + TLS + connection pooling +
DNS cache + redirects in one battle-tested stack. `httpcore.zig` and
`http_pool.zig` are retired; `http.zig` drives `curl_easy` over a
thread-safe `CURLSH` share. Same C-ABI -> Ring API + the whole network
suite stayed green. HTTP/2 negotiates over ALPN (verified live).

**Schannel ALPN gotcha (fixed):** curl's `global_init` runs
`Curl_ssl_init` (schannel reads the OS version for its ALPN gate) before
`Curl_win32_init` (which installs the accurate `RtlVerifyVersionInfo`),
so Schannel fell back to the manifest-lying `VerifyVersionInfoW` and
silently disabled HTTP/2 for an unmanifested host. One-line vendored
patch to `lib/easy.c` reorders win32_init before ssl_init.

**HTTP/3 -- DEFERRED (decision, s72).** Every viable h3 path here is a
bad trade today: curl 8.20's h3 backends are ngtcp2+nghttp3 or quiche,
and **Schannel cannot serve curl's QUIC**, so h3 forces a replacement
TLS backend. The only from-source path (wolfSSL + ngtcp2 + nghttp3)
would rip out the working Schannel h1/h2 stack, lose automatic Windows
cert-store verification (must ship a CA bundle), and is the biggest
vendor yet; the Windows-native path (msh3 + msquic) needs a curl bump
*and* a prebuilt binary, breaking the from-source rule. Meanwhile h3
degrades to h2 with zero functional loss (h3 is discovered via Alt-Svc
on an h2/h1 response), and h2 already covers essentially all real
traffic. **Revisit when** a real h3-only driver appears, OR curl
restores msh3 so we can reuse Schannel via msquic cleanly, OR OpenSSL
3.5+ QUIC matures into a zig-cc-buildable form. A true work-stealing
scheduler is likewise deferred (the multi-loop pool covers scale today).

**Tier 2 is COMPLETE** for the shipped scope: libuv reactor (async
timer/TCP, multi-loop scale), W3C TraceContext, and the libcurl HTTP
stack through HTTP/2 with Schannel TLS -- all vendored from source, all
green.

The historical decision context is kept below for the record.

### (historical) the choice that was made

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
