# Next Session -- Implement Reactive Engine Gap Analysis Tier 1

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

### 1. Hierarchical HTTP timeouts

Currently `StzEngineHttpRequest` blocks indefinitely. Production needs
configurable timeouts.

**Engine change** -- extend `engine/src/http.zig`:
* Add a `Timeouts` struct: `connect_ms`, `request_ms`, `idle_ms`.
* Wrap each request in a watchdog thread: when the deadline expires,
  the watchdog calls `client.deinit()` to force the in-flight fetch to
  fail. Set a clean error code (e.g. -4 = `timeout`).
* Expose `http_request_with_timeout(...method_code, url, headers,
  ct, body, connect_ms, request_ms, out, max)` and a global default
  via `http_set_default_timeout_ms(connect_ms, request_ms)`.

**Bridge** -- add `StzEngineHttpRequestWithTimeout` and
`StzEngineHttpSetDefaultTimeout` to `ring_bridge_http.zig`.

**Ring rewire** -- `stzHttpClient.SetTimeout(nSeconds)` already exists;
make it actually configure the engine timeout for subsequent calls.

**Test** -- new suite
`libraries/stzlib/base/test/network/62_http_timeouts_narrated.ring`:
* timeout fires before a deadline-exceeding request completes
* default timeout takes effect when none is set per-request
* zero timeout means infinite (legacy behaviour preserved)

### 2. HTTP connection pooling + keep-alive

Biggest single perf win in the analysis. Reduces per-call cost from
50-300ms (TLS handshake) to <1ms (just send the request).

**Engine change** -- new module `engine/src/http_pool.zig`:
* Keyed by `(scheme, host, port)`.
* Each entry holds a `std.http.Client` plus an `idle_since_ns`
  timestamp.
* Eviction: idle entries past `idle_ms` are closed.
* Cap: per-host max-conns, global max-conns.

**Bridge** -- replace the `std.http.Client{}` ad-hoc construction
inside `http_request` and `parallelWorker` with `httpPool.acquire(uri)`
+ `httpPool.release(client)`.

**Ring** -- no API change; transparent perf upgrade.

**Test** -- new suite
`libraries/stzlib/base/test/network/63_http_pool_narrated.ring`:
* Two consecutive same-host requests reuse the same client handle
  (use a stats hook or a tiny counter exposed by the pool).
* Eviction fires after idle TTL.
* Pool respects per-host cap.

### 3. DNS cache with TTL

Caching DNS keyed by hostname; entries expire after `ttl_ms` (default
60s).

**Engine change** -- new module `engine/src/dns.zig`:
* `dns_lookup(host, port) -> std.net.Address` with cache check first.
* Cache miss falls through to `std.net.getAddressList(...)` and stores
  the first result.

**Bridge** -- the http_pool and tcp.zig both call into this; no Ring
side direct calls needed. Optionally expose
`StzEngineDnsResolve(host)` for diagnostics.

**Test** -- in `engine/src/dns.zig` directly (Zig test). Confirm
cache hit doesn't re-resolve; confirm expiry forces re-resolve.

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

## Done criteria

* Tier 1 items 1-8 all shipped, each with its own commit.
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
* Narrated test helper: `base/test/_narrated.ring`.
* Existing hardening tests as templates: `56_http_hardening_narrated
  .ring`, `58_pool_hardening_narrated.ring`, `59_resilience_narrated
  .ring`, `60_pool_scale_narrated.ring`, `61_agentic_loop_narrated
  .ring`.
