# Reactive Engine -- Gap Analysis vs Industrial Tools
2026-06-13

What we shipped this arc, what libuv / libcurl / nginx / Go / Tokio /
Envoy do that we don't, and what we should adopt next.

## What we have today

| Capability | Engine module | Mechanism |
|---|---|---|
| Monotonic + wall clock | `stz_time` | std.time |
| Sync HTTP GET/POST + 5 more verbs | `stz_http` | std.http.Client + std.crypto.tls |
| Parallel GET | `stz_http` | one std.Thread per URL (max 32) |
| Sync TCP client / server | `stz_tcp` | std.net (blocking) |
| Polling FS watcher | `stz_fswatch` | std.fs scan + diff in worker thread |
| Bounded thread pool | `stz_pool` | mutex + condvar queue, N workers |
| Backpressure | `stz_pool` | bounded queue, submit returns -2 when full |
| Exponential backoff w/ jitter | `stz_resilience` | AWS full-jitter formula |
| Token bucket rate limiter | `stz_resilience` | atomic refill on access |
| Circuit breaker | `stz_resilience` | 3-state with timed half-open probe |

Total: ~1700 LOC of Zig, ~190 narrated assertions, all green.

## What the industrial tools have that we don't

### libuv (the I/O foundation we replaced)

| Capability | libuv | Us | Verdict |
|---|---|---|---|
| Non-blocking I/O (IOCP/epoll/kqueue) | yes | no -- threads | **Real gap.** Caps us at ~thousands of connections per pool. |
| Unified event loop (timers + I/O + signals + child + IPC) | yes | partial -- timer polling only | **Real gap.** Each subsystem is its own thread today. |
| Async DNS resolution | yes (c-ares) | no -- std.http resolves synchronously per request | **Real gap.** DNS blocks the calling thread. |
| Async filesystem ops | yes (uv_fs_*) | no -- blocking std.fs | Minor for now; fswatch worker doesn't block the caller. |
| UDP / pipes / TTY / signals | yes | no | We don't need most of these for stzBase. |
| Child process spawning + IPC | yes | no | stz_process exists in core engine. |
| Thread pool integrated with loop | uv_queue_work | yes -- `stz_pool` | We have parity here. |

### libcurl (industrial HTTP)

| Capability | libcurl | Us | Verdict |
|---|---|---|---|
| **Connection pooling + keep-alive** | yes (HTTP/1.1 reuse) | **no** | **Highest-impact gap.** Every request opens a fresh TCP+TLS handshake (50-300ms per call). |
| HTTP/2 + HTTP/3 | yes | no | **Real gap** -- HTTP/2 multiplexes many requests per TCP connection. |
| **Hierarchical timeouts** | connect / total / low-speed / idle | **none** | **Critical gap.** A hung downstream stalls a worker forever. |
| Cookies (parse Set-Cookie, send Cookie) | yes | manual (we set Cookie header from a list) | We have the bare minimum. |
| Auth: Basic / Digest / NTLM / Negotiate / OAuth2 / SigV4 | yes | none | We store auth in setters but ignore them. |
| Proxy: HTTP / SOCKS4 / SOCKS5 | yes | no | Cloud deployments often require this. |
| HTTP redirect handling | yes (with policy) | std.http follows by default; no policy | Acceptable today; add policy later. |
| Response decompression (gzip / deflate / br) | yes | no | Real cloud APIs return compressed bodies. |
| File upload with resume | yes | no | Nice-to-have. |
| Detailed progress callbacks | yes | no | Useful for observability. |
| DNS caching | yes | no | Repeated requests to the same host re-resolve. |
| TLS session resumption | yes | no | Saves ~1 RTT on reconnect. |
| IPv6 + Happy Eyeballs (RFC 8305) | yes | std.net.tcpConnectToHost handles IPv6 but not Happy Eyeballs | Slow connect on mixed-stack hosts. |
| TCP_NODELAY / TCP_KEEPALIVE tuning | yes | no | We accept whatever the OS defaults are. |
| Certificate pinning | yes | no | Required for some compliance regimes. |

### nginx (industrial reverse proxy)

| Capability | nginx | Us | Verdict |
|---|---|---|---|
| Worker process model (master + N) | yes | single process | We're a library; not a server. Skip. |
| Graceful reload (no dropped connections) | yes | no | Future arc if we ship a server. |
| **sendfile() for static files** | yes | no | We have no static file path. |
| **Reverse proxy with upstream pool** | yes | no | We're not a proxy yet. |
| Load balancing (round-robin / least_conn / hash / ip_hash) | yes | no | We have no LB primitive. |
| Caching (proxy_cache, fastcgi_cache) | yes | no | We have no cache. |
| **Sophisticated rate limiting** (burst + delay) | yes | bucket only | **Real gap** -- bursty traffic patterns need burst tolerance. |
| **Connection limits per IP** | yes | no | DDoS protection basic. |
| gzip on-the-fly | yes | no | Required for bandwidth-constrained edges. |

### Go runtime (the gold standard for cooperative concurrency)

| Capability | Go | Us | Verdict |
|---|---|---|---|
| **M:N scheduling (goroutines)** | yes -- ~2KB stacks, millions per process | thread-per-job in pool | **The big one.** Real scale needs cooperative scheduling. |
| **net/http with full HTTP/2** | yes | HTTP/1.1 only | Real gap. |
| **Context.Context** (cancellation + deadline + values) | yes -- pervasive | none | **Critical for agentic** -- no way to cancel a slow downstream call. |
| Channels + select | yes | mutex + condvar only | Different idiom; both work. |
| Built-in pprof profiling | yes | no | Without this, performance regressions are invisible. |
| Race detector | yes | no | We rely on careful review. |
| GC (low pause) | yes | manual via gpa | Trade-off; allocator choice is fine. |

### Tokio (Rust async runtime)

| Capability | Tokio | Us | Verdict |
|---|---|---|---|
| **Async/await + work-stealing scheduler** | yes | no | Tokio's model is what we'd need for 10k+ conns/worker. |
| Work-stealing queues | yes | single shared queue (mutex hot spot) | **Real gap** -- our queue serializes all submitters. |
| Timer wheel | yes (efficient) | per-timer poll | **Real gap at scale** -- N timers cost N comparisons per tick. |
| Channels (mpsc / broadcast / watch / oneshot) | yes | none | We have job poll, but no async channel. |
| Pluggable runtime (current_thread vs multi_thread) | yes | always multi-thread | OK. |
| TLS via rustls | yes | std.crypto.tls (Zig built-in) | Comparable. |

### Envoy / Linkerd / Istio (service mesh -- HTTP at scale)

| Capability | Envoy | Us | Verdict |
|---|---|---|---|
| **Outlier detection** (statistical ejection of sick endpoints) | yes | bare circuit breaker only | **Real gap.** Per-host eject based on error rate / latency. |
| **Retry budget** (global cap on retry rate) | yes | per-call retry only | **Critical** -- prevents retry storms cascading across services. |
| Per-route policy (timeout / retry / rate limit) | yes | global only | Needed for multi-tenant. |
| Tracing context propagation (W3C TraceContext / B3) | yes | none | Required for any production observability. |
| Mutual TLS | yes | none | Required for service-mesh deployments. |
| Hedged requests (fan out -- take first response) | yes | no | Cuts p99 latency dramatically. |
| Health checking (active + passive) | yes | none | Required for load balancing. |
| Connection draining (graceful close) | yes | StopListening hard-closes | We hard-stop today. |

### OpenTelemetry (observability)

| Capability | OTel | Us | Verdict |
|---|---|---|---|
| Distributed tracing | yes | none | **Critical for agentic** -- no way to trace a multi-step chain. |
| Metrics (counters / histograms / gauges) | yes | none | We expose pending/inflight but no histograms. |
| Latency percentiles (p50/p95/p99) | yes | none | Required for SLO-driven ops. |
| Log correlation | yes | none | Without trace_id we can't join logs to traces. |
| Cardinality limits | yes | none | Prevents metrics explosion under attack. |

## Ranked gap list (impact x how-hard-to-build)

### Tier 1 -- ship next (high impact, session-scale work)

1. **Hierarchical HTTP timeouts** -- `connect_ms / request_ms / idle_ms`.
   Without this, one hung downstream stalls the entire pool worker.
   Zig 0.15 std.http doesn't expose this directly; we'd need to wrap
   the request in a watchdog thread that calls `client.deinit()` on
   timeout. Single session.

2. **HTTP connection pooling + keep-alive** -- keyed by (scheme, host,
   port). Each pool entry is a std.http.Client kept alive across
   requests. Reduces per-call cost from 50-300ms (TLS handshake) to
   <1ms (just send the request). Single session.

3. **DNS cache with TTL** -- avoid re-resolving the same host on every
   request. std.net doesn't cache; we add a TTL-bounded map keyed by
   hostname. Single session.

4. **Context-style cancellation** -- pass a "cancel token" handle into
   every long-running call. Worker threads check it between I/O ops.
   The watchdog from #1 sets the token. Single session.

5. **Retry budget** (not just per-call retries) -- global rate cap on
   retries across the pool. Prevents cascade failures. Reuses the
   existing token bucket primitive -- just a different consumer.
   Half a session.

6. **Latency histograms with p50/p95/p99** -- HDR histogram or simple
   exponential bucketed counter. Expose via a `metrics_snapshot()`
   accessor. Single session.

7. **Outlier ejection** -- track error rate + latency per (host, port).
   Eject hosts that exceed thresholds; reset after cooldown. Extends
   the existing circuit breaker. Single session.

8. **Graceful pool shutdown** -- `pool_drain(timeout)` that stops
   accepting new work but waits for in-flight to complete. Half a
   session.

### Tier 2 -- ship after Tier 1 (multi-session arcs done right)

9. **Cooperative scheduling via async runtime** (IOCP / epoll / kqueue).
   The honest framing: 3-5 sessions because the cross-platform
   abstraction IS the hard part. Win: 10k+ connections per worker
   instead of N=8. Required if we host actual web servers.

10. **HTTP/2 client** -- multiplexed streams over a single TCP
    connection. Zig std.http doesn't ship this. Either build on top
    of std.http with hpack + frame parsing (~2 sessions) or vendor
    nghttp2 (decided ad-hoc). Win: massive throughput on APIs that
    support it (GitHub, AWS, GCP all do).

11. **TLS session resumption** -- save ~1 RTT on reconnect. std.crypto
    .tls needs a session cache; we'd add it as a pool-keyed map.

12. **gzip / deflate / br decompression** -- many cloud APIs return
    compressed bodies. Zig std has gzip; we wire it into the response
    pipeline. Single session, but adds complexity.

13. **Distributed tracing context propagation** (W3C TraceContext).
    Inject `traceparent` header on outbound, parse on inbound, store
    span id on the pool job. Single session for the propagation; the
    actual span export needs an OTel exporter (separate work).

14. **Work-stealing scheduler** -- replace the global mutex queue with
    per-worker queues + steal-from-neighbour. Removes the single hot
    lock. ~1 session of careful work.

### Tier 3 -- only when a real driver exists

15. **HTTP/3 (QUIC)** -- not in Zig std today. Vendoring quiche or
    similar. Real but speculative until a user needs it.

16. **Proxy support (HTTP / SOCKS5)** -- only matters for corporate /
    air-gapped deployments.

17. **Mutual TLS** -- required for service mesh. Not Tier 1 unless
    Softanza ships a service-mesh component.

18. **Hedged requests** -- the easiest way to crush p99 tail latency
    in agentic workloads. Single session once we have HTTP pooling.

## What we should learn from each tool

### From libuv
* **One unified event loop is the right model.** Trying to merge
  per-subsystem polling loops into one is the natural endgame; we're
  diverging by accident today (fswatch has its own thread, pool has
  its own thread, timers run in Ring).

### From libcurl
* **Connection state is a first-class object.** Not "send a request,
  get a response" but "I have a connection to host X, I send
  multiple requests on it, I tear it down when done." Connection
  pooling makes everything 10-100x faster.
* **Every operation has a configurable timeout.** No exceptions.
  Defaults are sane (e.g. 5 minutes total) but every layer is
  tunable.
* **DNS is a separate concern from connect.** Cache it.

### From nginx
* **Configuration is declarative.** A reverse-proxy config is just
  data; the runtime interprets it. Our setters-based fluent API is
  the imperative anti-pattern; we should ship a declarative-config
  variant.
* **Backpressure happens at every layer.** Buffer sizes, queue
  depths, connection caps -- all explicit.

### From Go runtime
* **Cancellation is propagated, not signalled.** Context is the
  pattern: parent context cancels, children see it, work stops.
  We need this for agentic loops.
* **Pprof out of the box.** Performance regression detection
  shouldn't need bespoke instrumentation.

### From Tokio / Rust
* **Async/await models cooperative concurrency cleanly.** Our
  alternative (thread pool + handles + poll) is workable but
  noisier. If we ever build the IOCP/epoll/kqueue arc, we should
  model it on Tokio's API shape, not raw callbacks.
* **Work-stealing queues remove the global lock.** A pool with N
  workers should have N queues + steal-from-neighbour, not one
  shared queue protected by a mutex.

### From Envoy
* **Retry budget, not per-call retries.** Retry storms have killed
  more production systems than any other class of bug. We need
  this before we ship anything customer-facing.
* **Outlier detection is just statistics on latency + errors.**
  Cheap to add, huge operational value.

### From OpenTelemetry
* **Trace IDs propagate through everything.** Even our internal
  pool job IDs should carry the original trace context so we can
  correlate a slow agentic loop with the downstream call that hung.

## Honest framing of the genuinely-multi-session arc

The "IOCP + epoll + kqueue unified reactor" really is multi-session,
not single-session, but for a specific reason: **the API shape is the
hard part, not the per-OS bindings**. We need to decide:

* Callback-based (libuv style)? Easy to bind from any host language,
  but produces "callback hell" in app code.
* Future/Promise-based (JS, Tokio's earliest API)? Cleaner but harder
  to model in Ring/Python.
* Async/await (Tokio current, Rust, Python asyncio)? Cleanest, but
  requires language support.
* Coroutines (Go goroutines, Lua, Kotlin)? Best for application
  code, requires runtime support.
* Job/handle/poll (our current pool)? Crude but portable.

Zig 0.15 dropped its async/await support; 0.16 is supposed to bring
it back differently. The right call may be to wait for Zig 0.16 and
build on top of std.Io / std.Thread.Pool / std.event when those
stabilise. **3-5 focused sessions** once the substrate is decided.

Until then, the Tier 1 list above gives us the operational hardening
needed for real production use without the cooperative-scheduling
arc.
