# Next Session -- Implement Reactive Engine Gap Analysis Tier 1

> **Status as of 2026-06-13 (session 65 end). Items 1+2 are DONE.**
> The custom HTTP/1.1 client on raw `std.net.Stream`
> (`engine/src/httpcore.zig`, TLS via `std.crypto.tls.Client`), the
> connection pool (`engine/src/http_pool.zig`, keyed by
> scheme/host/port with idle eviction + caps + opens/reuses/idle/active
> stats), and per-layer timeouts (connect via non-blocking connect +
> `poll(POLLOUT)`; request via `SO_RCVTIMEO`/`SO_SNDTIMEO`) all shipped
> and replaced the `std.http.Client` path inside `http.zig`. New bridge
> fns `StzEngineHttpSetDefaultTimeouts`/`RequestWithTimeouts`/
> `PoolStats`; `stzHttpClient` rewired with the timeout + pool-stats
> surface. Live-verified connection reuse + HTTPS + fast connect-
> timeout. Tests `63_http_pool_narrated.ring` (6/6) +
> `64_http_timeouts_engine_narrated.ring` (7/7); 52/53/55/56/62 still
> green. Milestone **M-RX1** (partial) tracks this in the CLI.
>
> **Windows caveat (carry forward):** `SO_RCVTIMEO`/`SO_SNDTIMEO` are
> best-effort on Windows because std's `std.net.Stream.Reader` uses
> overlapped `WSARecv`; the caller-side `StzEnginePoolPollWithDeadline`
> (session 64) remains the cross-platform "free the worker" guarantee.
> Any new timeout work must stay caller-side, not rely on the socket
> option alone.
>
> **Items 3+4 are also DONE (session 66).** Item 3: DNS cache
> `engine/src/dns.zig` (host|port key, 60s positive / 5s negative TTL,
> atomic resolve/hit counters) wired into `httpcore.connect` +
> `tcp.tcp_connect`; diagnostics `StzEngineDnsResolve`/`DnsStats`/
> `DnsCacheClear`. Item 4: cancellation tokens `engine/src/cancel.zig`
> (atomic-flag `CancelToken`), `pool.zig` Job carries an optional token,
> `StzEnginePoolSubmitWithCancel` + worker checkpoint returns `-5`
> (JOB_CANCELLED) when signalled before the job runs; Ring class
> `stzCancelToken` (lazy-init -- paren-less `new` skips `init()` in Ring,
> see memory `feedback-ring-parenless-new-skips-init`). Tests: dns.zig
> 3/3 + cancel.zig 2/2 Zig; `65_dns_cache_narrated` 4/4 +
> `54_cancel_narrated` 5/5 Ring. All network+reactive suites green.
>
> **Items 5+6 are also DONE (session 67).** Item 5: retry budget Ring
> class `base/common/stzRetryBudget.ring` over the existing token-bucket
> rate limiter (no engine change); `(budget, window_sec)`, `Allow()`/
> `Spend()`/`AllowN()`/`Available()` -- named Allow not Try because
> `try` is a Ring keyword (see memory
> `feedback-ring-reserved-words-as-methods`). Item 6: latency histograms
> -- new DLL `engine/src/histogram.zig` (log-scale ms buckets,
> create/record/percentile/reset/count/destroy), `StzEngineHistogram*`
> bridge, Ring class `stzLatencyHistogram` (P50/P95/P99); http.zig
> records request latency, exposed via `StzEngineHttpLatencyPercentile/
> Count/Reset`. Tests: histogram.zig 4/4 Zig; `66_retry_budget_narrated`
> 10/10 + `67_histogram_narrated` 10/10 Ring. All suites green.
>
> **Next session starts at item 7** (outlier ejection). Items 1-6 below
> are kept for reference; skip to item 7 and proceed 7-8. The
> recommended grouping is session D = items 7 + 8.

## Context (read these first)

* `libraries/stzlib/base/doc/design/REACTIVE_ENGINE_GAP_ANALYSIS.md` --
  what the analysis identified as missing vs libuv / libcurl / nginx /
  Go runtime / Tokio / Envoy / OpenTelemetry.
* `libraries/stzlib/base/doc/design/EXTERNAL_DEPENDENCY_AUDIT.md` -- the
  M-DEP* arc this work continues.
* `libraries/stzlib/base/doc/design/SOFTANZA_ENGINE_MACROPLAN.md` --
  session log (last entry session 64).
* Run `softanza next` at session start (and after each commit) to
  read the current status. The CLI is the source of truth.

## What we're doing

Closing the **Tier 1** gaps from the analysis: hierarchical HTTP
timeouts, connection pooling + keep-alive, DNS cache, cancellation
tokens, retry budget, latency histograms, outlier ejection,
graceful pool shutdown. Each is a single focused engine module
extension + Ring rewire + narrated test.

Tier 2 (cooperative scheduling via IOCP / epoll / kqueue, HTTP/2,
TraceContext, work-stealing) is **out of scope for this session**.
That's the genuine 3-5 session arc once Zig 0.16's std.Io direction
stabilises.

## Order (highest ROI first)

Implement these as separate commits. After each one: rebuild engine,
run all narrated suites in `libraries/stzlib/base/test/network/` and
`libraries/stzlib/base/test/reactive/`, push both remotes, update
the CLI's `engine_status.zig` and the macroplan log.

### 1+2 (fused arc). Custom HTTP/1.1 client on raw std.net.Stream + connection pool + per-layer timeouts

These two items share infrastructure: doing connection pooling well
requires controlling the socket lifecycle, which is the same control
needed for socket-level timeouts. Doing them together means writing
a small HTTP/1.1 client once, with pooling and timeouts built in
from day one, instead of re-plumbing later.

**Item 1 caller-side half: DONE in session 64.**
`StzEnginePoolPollWithDeadline(pool, job_id, deadline_ms, out, max)`
returns `-4` if the job hasn't finished by the deadline. Test
`62_http_timeouts_narrated.ring` (5/5). The pool worker keeps
running the underlying fetch -- this is purely a caller-side
deadline. A hung downstream still ties up the worker; the engine-
side half below is what frees it.

**Item 1 engine-side half + item 2 (fused):**

* **Why custom HTTP/1.1.** Zig 0.15 `std.http.Client.fetch` does not
  expose per-socket timeouts and does not pool connections beyond
  its internal `connection_pool` (which has limited control). To get
  both timeouts and pooling correct, the cleanest path is to skip
  `std.http.Client` and build a small HTTP/1.1 client directly on
  `std.net.Stream` (with TLS layered via `std.crypto.tls.Client`
  when scheme == "https"). ~300-400 LOC of focused code.

* **New module `engine/src/httpcore.zig`** (replaces the
  `std.http.Client` path inside `http.zig`):
  * Connection struct: scheme, host, port, stream, tls_client, last_used_ns
  * `connect(host, port, scheme, connect_timeout_ms)` -- opens TCP
    with `std.posix.setsockopt(... SO_RCVTIMEO ...)` for connect
    deadline, then layers TLS for https
  * `sendRequest(conn, method, path, headers, body, request_timeout_ms)`
  * `readResponse(conn, out_status, out_headers, out_body, request_timeout_ms)`
    -- chunked + Content-Length aware
  * `close(conn)`

* **New module `engine/src/http_pool.zig`**:
  * Keyed by `(scheme, host, port)`
  * Each slot: list of idle Connection structs + `last_used_ns`
  * Acquire: pop newest idle slot or open new (subject to per-host
    + global max-conns caps)
  * Release: push back to idle list with refreshed `last_used_ns`
  * Eviction worker thread (or eviction-on-acquire): close
    connections idle longer than `idle_timeout_ms`
  * Stats counters: `total_opens`, `total_reuses`, `current_idle`,
    `current_active`

* **Wire-up in `http.zig`**:
  * `doRequest` switches to `httpPool.acquire` + `httpcore.send` +
    `httpcore.read` + `httpPool.release`
  * `parallelWorker` does the same
  * Defaults: connect 5s, request 30s, idle 60s, max 16/host, 256
    total (all settable)

* **Bridge** -- new functions in `ring_bridge_http.zig`:
  * `StzEngineHttpSetDefaultTimeouts(connect_ms, request_ms, idle_ms)`
  * `StzEngineHttpRequestWithTimeouts(method, url, headers, ct,
    body, connect_ms, request_ms)` -- per-request override
  * `StzEngineHttpPoolStats()` -- returns "opens=N\treuses=N\t
    idle=N\tactive=N"

* **Ring rewire**:
  * `stzHttpClient.SetTimeout(nSeconds)` actually drives the engine
  * `stzHttpClient.SetConnectTimeout(nMs)` / `SetRequestTimeout(nMs)`
  * `stzHttpClient.PoolStats()` returns a Ring list

* **Tests** -- new suites:
  * `63_http_pool_narrated.ring` -- two same-host requests reuse
    connection (stats counter increments `reuses`); third request
    after eviction window opens a new one (`opens` increments).
  * `64_http_timeouts_engine_narrated.ring` -- connect timeout
    fires on an unreachable host within the deadline; request
    timeout interrupts a slow read; deadlines below the connect
    floor still surface a clean error.

**Combined budget: 1-2 focused sessions.** This is the highest-ROI
work in the entire Tier 1 list; do it first.

### 3. DNS cache with TTL (depends on items 1+2)

Once items 1+2 land, every connection open in `httpcore.connect`
resolves the host. Caching saves a syscall (typically 1-10ms) per
miss. Caching DNS keyed by hostname; entries expire after `ttl_ms`
(default 60s).

**Engine change** -- new module `engine/src/dns.zig`:
* `dns_lookup(host, port) -> std.net.Address` with cache check first.
* Cache miss falls through to `std.net.getAddressList(...)` and stores
  the first result.
* Negative caching: cache failures briefly (5s default) to avoid
  hammering a broken resolver.

**Wire-up** -- `httpcore.connect` and `tcp.zig` route through here.

**Bridge** -- optionally expose `StzEngineDnsResolve(host)` for
diagnostics; nothing required for the hot path.

**Test** -- in `engine/src/dns.zig` directly (Zig test). Confirm
cache hit doesn't re-resolve; confirm expiry forces re-resolve;
confirm negative cache short-circuits failed lookups.

### 4. Context-style cancellation

Pass a cancel-token handle into long-running ops. Workers check it
between I/O ops; the watchdog from item 1 flips it on timeout.

**Engine change** -- new tiny module `engine/src/cancel.zig`:
* `CancelToken = struct { flag: atomic.Bool, mutex: Mutex }`
* `cancel_create()`, `cancel_signal(tok)`, `cancel_is_cancelled(tok)`,
  `cancel_destroy(tok)`.

**Bridge** -- `StzEngineCancelCreate / Signal / IsCancelled /
Destroy`. Wire into `pool.zig`'s `Job` struct so submissions can
carry an optional cancel token; the worker checks at strategic
points.

**Ring** -- new class `stzCancelToken` in
`libraries/stzlib/base/common/`.

**Test** -- new suite
`libraries/stzlib/base/test/reactive/54_cancel_narrated.ring`:
* Token created, polled (not cancelled).
* Token signalled, polled (cancelled).
* Job submitted with a token, token signalled mid-run, job result
  surfaces with cancellation status.

### 5. Retry budget (global cap on retries across the pool)

Reuses the token bucket primitive. Different consumer, same
mechanism.

**Engine change** -- none. Reuse `StzEngineRateCreate(N, refill)`.

**Ring change** -- add a `stzRetryBudget` helper class in
`libraries/stzlib/base/common/` that wraps a rate limiter and gives
it a budget-shaped API:
```ring
oBudget = new stzRetryBudget(100, 10)   # 100 retries / 10 sec
if oBudget.Try()
    # do the retry
else
    # budget exceeded -- escalate to failure
ok
```

**Test** -- new suite
`libraries/stzlib/base/test/network/64_retry_budget_narrated.ring`:
* Budget allows the first N retries.
* Budget refuses the (N+1)-th retry within the window.
* Budget refills over the window duration.

### 6. Latency histograms (p50 / p95 / p99)

Engine-side histogram with logarithmic buckets so we don't need
exact percentile data structures.

**Engine change** -- new module `engine/src/histogram.zig`:
* Fixed bucket boundaries on a log scale (e.g. 0.1ms, 0.2, 0.5, 1,
  2, 5, 10, 20, 50, 100, 200, 500, 1000, 2000, 5000, 10000 ms).
* `histogram_create()`, `histogram_record(h, value_ms)`,
  `histogram_percentile(h, p) -> ms` (returns the upper bound of
  the bucket containing the percentile), `histogram_reset(h)`,
  `histogram_count(h)`, `histogram_destroy(h)`.

**Bridge** -- `StzEngineHistogram*`.

**Wire-up** -- record HTTP request latency, pool job duration.

**Ring** -- new class `stzLatencyHistogram` in
`libraries/stzlib/base/common/`.

**Test** -- new suite
`libraries/stzlib/base/test/network/65_histogram_narrated.ring`:
* Recording 1000 samples with a uniform distribution gives p50 in
  the middle, p99 near the top.
* Count is exact.
* Reset clears all buckets.

### 7. Outlier ejection per (host, port)

Per-host stats with a short rolling window. Eject when error rate
or latency p99 crosses a threshold; auto-readmit after cooldown.

**Engine change** -- extend `engine/src/resilience.zig` with:
* `OutlierDetector = struct { ... }` per (host, port).
* `outlier_record(host, ok_bool, latency_ms)`.
* `outlier_should_eject(host) -> bool` based on rolling stats.

**Wire-up** -- http_pool's `acquire` checks
`outlier_should_eject(host)` before handing out a client.

**Test** -- new suite
`libraries/stzlib/base/test/network/66_outlier_narrated.ring`:
* 10 failures in a row trigger ejection.
* After cooldown, host is readmitted.
* Successful calls reset the failure count.

### 8. Graceful pool shutdown

`pool_drain(timeout_ms)` stops accepting new submissions and waits
for in-flight jobs to finish. After timeout, hard-stops the
remaining workers.

**Engine change** -- extend `engine/src/pool.zig`:
* Add `accepting: atomic.Bool` (default true).
* `pool_drain(p, timeout_ms) -> i32` (returns # of jobs that didn't
  complete in time).
* `submit` returns -4 with "pool draining" LastError when
  `accepting == false`.

**Bridge** -- `StzEnginePoolDrain`.

**Ring** -- `stzHttpClient.Shutdown()` calls
`StzEnginePoolDrain(pool, 5000)`.

**Test** -- new suite
`libraries/stzlib/base/test/network/67_pool_drain_narrated.ring`:
* `Drain()` rejects new submissions.
* In-flight jobs complete normally.
* Hard-stop after timeout returns non-zero residual count.

## Standing rules

* **No external Ring extensions in stzBase** -- the M-DEP arc is
  closed; do not reintroduce `load "..."` for libuv/libcurl/etc.
* **Console output: ASCII only.** No emoji, no non-ASCII chars.
  Windows renders them as garbled text.
* **No `ring_len()`** -- use `len()` for lists/bytes, `StzLen()` for
  codepoints. See `feedback_hoist_len_out_of_for` in memory.
* **No `for X in list ... next`** -- use `nLen = len(aList); for i =
  1 to nLen; ...; next` everywhere.
* **No real stdio / child processes / event loops in tests.**
  Compile-time bounded only. L99 guardrail at
  `src/simulation/l99_no_stdio_in_tests.zig` enforces this for
  `zig build test`. Ring-side tests stay synchronous; live network
  tests run outside CI.
* **Narrated test format** -- use the `_narrated.ring` helper at
  `libraries/stzlib/base/test/_narrated.ring`. Scenario / Given /
  When / Then / EndScenario / Summary.
* **Push BOTH remotes** -- `git push origin main && git push codeberg
  main`. Codeberg auth occasionally fails; retry once.
* **Never create PRs.** Merge directly to main.
* **Commit message style** -- short imperative subject + a blank
  line + concrete bullets of what changed + why. End with what's
  next if there's a follow-up.
* **Ring gotchas pinned in earlier sessions**:
  * `new stzReactiveSystem()` with parens raises C27 in some
    scenario contexts; use `new stzReactiveSystem` (paren-less) or
    construct inside a helper function.
  * Two consecutive `new ClassName(...)` in one Scenario block
    triggers C27. Split into separate scenarios.
  * `init` (lowercase) vs `Init` (capital) collide as
    case-insensitive identifiers; cannot ship both as overloads.
  * `isPointer(null_handle)` returns TRUE for Ring's typed null
    pointer (what the engine returns on failure). Success check
    must use `StzEngine...LastError() = ""` instead of
    `isPointer()`.
  * Block comments close on the FIRST `*/`. Avoid `/` after `*`
    inside `/* ... */`.
  * `\"` inside double-quoted strings raises C8. Use single-quoted
    outer strings or `char(34)`.
* **Update CLI + macroplan + memory at every checkpoint.**
  * `libraries/stzlib/cli/src/engine_status.zig` -- bump
    `last_session`, update relevant milestone summaries.
  * `libraries/stzlib/base/doc/design/SOFTANZA_ENGINE_MACROPLAN.md`
    -- append a log row to the Progress Log section.
  * Memory at
    `C:\Users\ASUS V3607V CORE 5\.claude\projects\D--GitHub-zin\memory\`
    -- update `project_stzlib_external_dep_audit.md` and any
    relevant feedback entries.
  * Rebuild the CLI: `cd libraries/stzlib/cli && zig build`.
  * Commit + push both remotes.

## Recommended session boundaries

The 8 items split naturally into 4 sessions of focused work:

| Session | Items | Why grouped |
|---|---|---|
| A | 1+2 fused | Custom HTTP/1.1 + pool + timeouts share infrastructure |
| B | 3 + 4 | DNS cache is small; cancellation tokens are small. Both land cleanly in one session. |
| C | 5 + 6 | Retry budget reuses rate limiter; histograms are isolated. Both small. |
| D | 7 + 8 | Outlier ejection extends circuit breaker; graceful shutdown extends pool. Both small. |

If a session has time after its primary items, pick up the next
session's lighter item.

## Done criteria

* Tier 1 items 1-8 all shipped, each with its own commit (1+2 may
  share a commit if landed in the same session).
* Engine builds with `zig build` clean.
* Engine tests pass with `zig build test` clean.
* All narrated suites in
  `libraries/stzlib/base/test/network/` and
  `libraries/stzlib/base/test/reactive/` still green
  (cross-check after each item).
* CLI's `softanza next` reflects the new state.
* Memory updated.
* Both remotes pushed.

## What to defer

* Tier 2 (cooperative scheduling, HTTP/2, TraceContext propagation,
  work-stealing scheduler) -- separate arc, 3-5 sessions, requires
  decision on async API shape.
* Tier 3 (HTTP/3, proxy support, mTLS, hedged requests) -- only when
  a real driver exists.

## Useful reference points in the codebase

* Existing engine domain pattern: `engine/src/stz_http_entry.zig`,
  `engine/src/http.zig`, `engine/src/ring_bridge_http.zig`,
  `engine/stz_http.ring`, wired into
  `base/common/stzRingLibs.ring`.
* Bounded thread pool to extend: `engine/src/pool.zig`.
* Existing resilience primitives to reuse:
  `engine/src/resilience.zig`.
* Existing TCP module to mirror for httpcore.zig:
  `engine/src/tcp.zig` (std.net.Stream usage pattern).
* Caller-side deadline pattern already shipped:
  `engine/src/pool.zig` -- look at `pool_poll_with_deadline` +
  `jobPeekDone`. Use the same non-draining-peek idiom in httpcore
  for connection-state checks.
* Narrated test helper: `base/test/_narrated.ring`.
* Existing hardening tests as templates: `56_http_hardening_narrated
  .ring`, `58_pool_hardening_narrated.ring`, `59_resilience_narrated
  .ring`, `60_pool_scale_narrated.ring`, `61_agentic_loop_narrated
  .ring`, `62_http_timeouts_narrated.ring` (caller-side deadline,
  shipped session 64).
