# Softanza Performance by Design

### One governed system that measures, explains, and defends the performance of a Softanza program — at the engine level and the Ring level, in development and in production

> **Status: P0 + P1 + P2 SHIPPED (2026-07-29); P3-P6 planned.** This document is the
> design study for `stzPerfSystem`. It is grounded in a full read of the
> system, app, appserver, cluster, reactive and stats modules and of the
> engine sources. Every file:line reference below was verified against the
> working tree at the time of writing.
>
> P0 delivered: `base/perf/stzStopwatch.ring` (numeric, monotonic,
> unlimited instances, OTel-span export with W3C trace identity), the
> engine watch-clock monotonic fix (`engine/src/watch.zig`), the
> `stzProfiler.ring` fossil retired to `base/archive/system/`.
> Guard: `base/test/perf/stopwatch_narrated.ring` (35 assertions).
> Narration: `narrations/stz-honest-stopwatch-narration.md`.
>
> P1 delivered: `engine/src/perf.zig` (`stz_perf.dll`) -- process
> RSS/peak, system memory total/free, process CPU time, and the
> engine-resident metric series (bounded ring, O(1) record, exact
> windowed stats incl. least-squares slope); `base/perf/stzPerfSeries.ring`;
> `stzProcess` gains `MemoryBytes/PeakMemoryBytes/CpuTimeNs/CpuTimeMs`;
> `stzSystemProfile.Resources()` mem gap FILLED (live profiles observe,
> declared profiles report 0). Guard: `engine_senses_narrated.ring`
> (36 assertions). Narration: `stz-engine-senses-narration.md`.
>
> P2 delivered: `base/perf/stzMetric.ring` (:Counter with measured
> RatePerSecond = X, :Gauge with slope trend, :Timer with bucket AND
> exact percentiles + exact lifetime sum/mean via a new engine
> `histogram_sum`) and `base/perf/stzPerfMonitor.ring` (watch
> declarations, Every() cadence, pull/tick/hosted-as-agent -- the
> monitor satisfies the stzAgentHost contract); interop part two:
> `Prometheus()` exposition text + `OtelJson()` resourceMetrics
> envelope. Design law proven under fire: ALL metric state
> engine-side + handles materialized EAGERLY at birth (a lazy handle
> forks per Ring copy -- found live, pinned by the guard). Guard:
> `metrics_monitor_narrated.ring` (42 assertions). Narration:
> `stz-metrics-monitor-narration.md`.
>
> Pedigree: the operational-analysis tradition (utilization law, Little's
> law, service demand) as popularized for practitioners by *Pro Java EE 5
> Performance Management and Optimization* — reframed the Softanza way:
> engine-true, governed, and legible.

---

## 1. Why this document exists

Every serious platform eventually meets the same seven problems:

1. Slow running apps
2. Apps that degrade over time
3. Slow memory leaks that gradually degrade performance
4. Huge memory leaks that crash the app
5. Periodic CPU spikes and app freezes
6. Apps that behave differently under heavy load than under normal usage
7. Problems that occur in production but cannot be reproduced in a test environment

The industry answer is an APM agent bolted on after the fact — a foreign
body that observes the program from outside, speaks its own vocabulary,
and is consulted only during emergencies.

The Softanza answer is **performance by design**: the ability to monitor,
alert, analyze and optimize is part of the library's own spine, expressed
in the library's own conventions (engine truth, governance, legibility,
scope-named verbs), declared at *design time* next to the SLA it defends —
and instructive enough that the same object that runs a production fleet
can teach a student what utilization actually means.

The pipeline, in four verbs:

```
Monitor  -->  Alert  -->  Analyze  -->  Optimize
(sense)      (judge)     (understand)   (act, governed)
```

## 2. What exists today (the study)

The striking finding: **most of the parts already exist — scattered,
unlabeled, and unaware of each other.** The perf system is largely an act
of *unification*, not invention.

### 2.1 Engine assets (Zig, already built)

| Module | What it gives | Bridge |
|---|---|---|
| `time.zig` | monotonic ms/ns clock, wall clock, resolution | `StzEngineTimeNowMs()` etc. |
| `process.zig:16-53` | monotonic process uptime (ns/ms/s), `Instant` baseline at DLL load — NTP-immune | `StzEngineProcessUptime*` |
| `profiler.zig` | 128 named timers with call counts, total/avg ns | `StzEngineProfilerBegin/End/...` |
| `watch.zig` | 64 id-indexed nesting stopwatches, ns precision | `watch_start/stop/elapsed` |
| `histogram.zig` | O(1) log-bucket latency histogram, percentiles, mutex-safe | `stzLatencyHistogram` (Ring class exists) |
| `timeline.zig` | 256-slot labeled event ring (epoch ms) | `stz_tl_*` |
| `tracectx.zig` | W3C traceparent generation / child spans | `tracectx_*` |
| `cache.zig:103-107` | hit/miss counters + hit rate | `cache_hit_count/...` |
| `resilience.zig` | token-bucket rate limiter, circuit breaker, per-host outlier ejection | `rate_* / circuit_* / outlier_*` |
| `stats.zig` | mean/median/stddev/percentiles/skew/outliers/z-scores/moving average/regression, Kahan summation | `StzEngineStats*` |

### 2.2 Ring assets (already built)

- **`stzClusterTelemetry`** (cluster/) — *the working precedent*: per-facet
  engine histograms, bounded 512-trace ring `[id, facet, endpoint, status,
  durMs, attempts]`, `LatencyP50/P90/P95/P99`, `NewTraceId()` put on the
  wire, `FailoverTraces()`, `Narrate()`. Explicitly designed as "a plain
  recorder ... pipelines/federation can feed the same shape".
- **`stzAppCluster.Route()`** — the one fully instrumented request path
  today: trace id + `StzEngineTimeNowMs()` bracket + rate-limit admission +
  breaker + telemetry record on every outcome.
- **`stzWorkerPool`** — real backpressure metrics: `InFlight / QueueDepth /
  ShedCount / Metrics()`.
- **`stzClusterSupervisor`** — a pure, testable scaling policy
  (`Decide(aMetrics)`) whose load signal is *hand-fed* via `ReportLoad()`.
- **`stzReactive` / `stzReactor`** — `RunEvery` timers, Rx streams with
  `Filter`/`OnPassed`/backpressure, `stzEventBus` pub/sub: a
  Monitor->Alert pipeline is buildable today.
- **`stzDataSet`** (stats/) — `Percentile/PercentileXT/Outliers/ZScores/
  MovingAverage/CorrelationWith/Summary` for batch analysis.
- **`stzProcess`** — pid + monotonic uptime + machine facts, engine-backed.
- **`stzLog`** — leveled, queryable, `StzEngineTimeNowMs()`-stamped records.
- **Test idioms** — `test_perf_guard.ring` (generous-threshold regression
  guards) and the `*_stress_narrated.ring` TIMED scale-guard suites.

### 2.3 Fossils (to retire or absorb)

- `system/stzProfiler.ring` — an executable *sketch* (top-level statements;
  loading it breaks the loader), not library code. A design fossil of
  "a function aware of its own execution". Retire; keep the idea.
- `system/stzProfilingTimer.ring` — one global stopwatch whose
  `StzElapsedTime()` returns a **formatted string** ("0.123 second(s)"),
  built on coarse `clock()`; `pf()` halts the process. Keep as the casual
  console idiom; the perf system supersedes it with numeric, nesting,
  engine-clock stopwatches.
- `system/stzMemoryProfiler*.ring` — an analytical *price list* for Ring
  values (struct-layout arithmetic), not a memory observer. Useful as the
  "what should this cost" model; it observes nothing.

### 2.4 The gaps (what must be built)

1. **No memory or CPU observation anywhere.** No process RSS, no heap
   totals, no CPU time/usage. `stzSystemProfile.Resources()` (line 499)
   already carries the comment: `mem_total / mem_free` is "a PLANNED
   engine add". Issues 2-5 above are *unobservable* today.
2. **No per-request timing in `stzAppServer`.** Only `@nRequestCount`
   (stzAppServer.ring:730) and `Uptime()`. The single-node server — the
   thing most users run — is blind while the cluster is instrumented.
3. **No durations in the audit trails.** `stzAppBackend.@aTraffic` records
   `[part, verb, dataset, status]` but not *how long* (the `_Roundtrip`
   choke point at stzAppBackend.ring:997 is the one place both local and
   remote crossings pass). `stzComputePipeline.Trace()` rows likewise.
4. **No continuous sampling, no history, no thresholds, no SLA
   vocabulary, no alert object.** Everything today is a one-shot pull.
5. **The router middleware seam is dead.** `Use()` stores middleware that
   `_Dispatch` never executes — declared but unserved.
6. **The supervisor's load signal is hand-fed**, when it could be computed
   from measured utilization — the closed loop is one join away.

## 3. The thesis

Three commitments, straight from the house doctrine:

1. **Engine truth.** Every measurement is taken by the Zig engine —
   monotonic nanosecond clocks, O(1) histogram recording, OS memory/CPU
   counters — and *stored* engine-side (handle-backed series), so that the
   act of observing costs O(1) per event and survives Ring's
   copy-on-assign semantics. Ring narrates; the engine measures.
   Marshalling is the usual cost — so cross the bridge once per *report*,
   never once per *sample*.

2. **Performance is a governed sense.** In the capability lattice, metric
   reads are `sensing` operations; optimization acts (scale, restart,
   shed, tune) are `effectful` and cross reality only through a governed,
   audited plan. Consequence, by construction: **an LLM actor may watch,
   analyze, and propose — it can never tune.** The perf system is the
   first facility to declare its reads as sensing *deliberately*.

3. **The instructive dimension is not a demo mode.** The same operational
   analysis that guards production (utilization law, Little's law,
   service demand) is what `Explain()` teaches through the user's own
   numbers. Industry-strength and instructive are one artifact, not two.

## 4. The vocabulary: U, R, X, D

Four letters carry the whole analytical core:

- **U — Utilization**: fraction of a resource's capacity in use
  (CPU busy fraction, worker in-flight / budget).
- **R — Response time**: end-to-end duration of one request, as a
  distribution (p50/p95/p99), never just an average.
- **X — Throughput**: completed requests per unit time.
- **D — Service demand**: `D = U / X` — the amount of a resource one
  request *actually consumes*. The single most diagnostic number in
  performance work, and almost never surfaced by APM tools.

And the two laws that bind them, which the system both *uses* and
*checks itself against*:

- **Utilization law**: `U = X * D` — measured three ways, cross-validated.
- **Little's law**: `N = X * R` — concurrent requests in the system equal
  throughput times response time. When the measured N and the computed
  `X * R` disagree, the *measurement* is broken — a self-test no
  dashboard offers.

`Bottleneck()` falls out for free: the resource with the highest service
demand D bounds the maximum throughput (`Xmax = 1 / Dmax`). That single
sentence is most of capacity planning.

## 5. The objects

New folder: `base/perf/`. All classes follow the house rules: plain
method = data, `...Q()` twin = chainable object; fluent setters return
`This`; `Explain()` returns lines, `Show()` prints, `Narrate()` returns
one string; no `As/With/To/For` name pairs; engine handles freed by an
explicit `Destroy()`; findings shaped `[ :invariant, :severity, :where,
:message ]` so they plug into `stzRuleReport`.

### 5.1 `stzStopwatch` — the numeric primitive (P0)

Fixes the string-returning fossil. Backed by `watch.zig` (ns precision,
64 concurrent, nesting by composition):

```ring
w = new stzStopwatch()          # starts on birth
# ... work ...
? w.ElapsedMs()                 #--> 12.437   (a NUMBER, monotonic clock)
w.Lap()                          # split without stopping
```

Scope-oriented: the clock and the unit are named in the verb, never a
mode — `ElapsedNs()/ElapsedUs()/ElapsedMs()/ElapsedS()` read the
monotonic engine clock (`ElapsedCpuMs()` joins them once P1 lands).
Wall time never masquerades as elapsed time: it appears only as the
*anchors* of the span (`Record()[:startWallMs]`, the OTel
`startTimeUnixNano`), where absolute placement is the point. Which
clock you are reading is visible at the call site.

### 5.2 `stzMetric` — one named stream of measurements (P2)

Kind is declared at birth: `:Counter` (monotonic count), `:Gauge`
(sampled level — memory, queue depth), `:Timer` (durations — histogram-
backed). Storage is engine-side (series ring buffer + latency histogram),
so `Record()` is O(1) and copy-proof.

```ring
m = new stzMetric("checkout.duration", :Timer)
m.Record(nMs)
? m.P95()                        # from the engine histogram
? m.MeanOver(:LastMinute)        # window named in the verb (scope-oriented)
? m.RatePerSecond()
```

### 5.3 `stzPerfMonitor` — the sampler (P2)

Continuous sensing on the reactive substrate (`RunEvery`), feeding
gauges. One monitor per process; it also hosts itself on `stzAgentHost`
so an `stzAppServer.Run()` loop ticks it for free (the same slice
mechanism agents already use).

```ring
oMon = new stzPerfMonitor()
oMon.WatchMemory().WatchCpu().WatchHandles()
oMon.Every(1000)                 # sample period, ms
oMon.Start()
? oMon.MemorySeries().Trend()    #--> :Growing / :Stable / :Shrinking
```

### 5.4 `stzSla` — expectations, declared where the design lives (P4)

The SLA is stated at *design* time, in the vocabulary of section 4, and
verdicts are findings — the same shape as `stzGovernanceChecks` and
`stzGraphRule` — so a perf budget is CI-gateable through `stzRuleReport`
like any other rule, across the same one gate that already covers code,
agents, security, workflow and orgcharts:

```ring
oSla = new stzSla("restolean-api")
oSla.Expect(:ResponseTimeP95).Under(200)          # ms
oSla.Expect(:Availability).AtLeast(99.9)          # percent
oSla.Expect(:MemoryGrowthPerHour).Under(10*1024*1024)
oSla.Expect(:CpuUtilization).Under(0.75)

aFindings = oSla.CheckAgainst(oPerf)   # [ [:invariant, :severity, :where, :message], ... ]
```

### 5.5 Alerts — judge, suppress, fan out (P4)

Threshold crossing and outlier detection (engine `outlier_*`, stats
z-scores) produce alert events; the engine circuit breaker suppresses
flapping (an alert that fires 400 times is one alert); fanout rides
`stzEventBus`. `OnBreach(f)` for callbacks; every alert carries the
trace ids of the requests that tripped it (`tracectx`), which is the
bridge from "the p95 is bad" to "these three requests are why".

### 5.6 `stzPerfProfile` — the analyst (P5)

The operational-analysis object. Consumes the metrics; produces
understanding:

```ring
oP = oPerf.Profile()
? oP.Utilization(:Cpu)           # U
? oP.Throughput()                # X
? oP.ResponseTimeP95()           # R
? oP.ServiceDemand(:Cpu)         # D = U/X  -- ms of CPU per request
? oP.Bottleneck()                #--> [ :resource = :Cpu, :maxThroughput = 66 ]
? oP.LittleCheck()               # N vs X*R -- self-validating measurement
? oP.Explain()                   # the narrated analysis (section 7)
```

Trend analysis (`MovingAverage` slope on gauge series) covers
degradation and slow leaks; load-behavior comparison (R-vs-X curve —
response time as a function of throughput) covers "different under
load"; `Forecast()` (engine regression) answers "when does memory hit
the ceiling".

### 5.7 `stzPerfSystem` — the facade

Owns one monitor, the metric registry, the SLA set, the alert channel,
and the profile. The programming experience, end to end:

```ring
oPerf = new stzPerfSystem("restolean")
oPerf.WatchMemory().WatchCpu().Every(1000)

oSrv = new stzAppServer()
oSrv.Observe(oPerf)              # per-request R and X, from this line on
oSrv.Get_("/menu", func oReq, oResp { oResp.Json(aMenu) })
oSrv.Start(8080, "127.0.0.1")

oPerf.SlaQ().Expect(:ResponseTimeP95).Under(200)
oPerf.OnBreach(func aAlert { ? "SLA breach: " + aAlert[:message ] })

oSrv.RunFor(60000)

? oPerf.ServiceDemand(:Cpu)
oPerf.Show()                     # the one-screen performance picture
```

Note what is *absent*: no agent install, no config file, no foreign
vocabulary. Observation is one verb on the object being observed.

## 6. Engine additions

One new module, `perf.zig`, plus its bridge and entry (the standard
cost: one Zig fn + one bridge row per counter, ~13-line entry file,
one `build.zig` line):

1. **Process memory**: `stz_perf_mem_rss()`, `stz_perf_mem_peak()` —
   Windows `GetProcessMemoryInfo`, Linux `/proc/self/statm`, macOS
   `task_info`. **System memory**: `stz_perf_sys_mem_total/free()` —
   fills the planned gap in `stzSystemProfile.Resources()`.
2. **Process CPU time**: `stz_perf_cpu_ns()` (user+kernel). Utilization
   over a window = `delta(cpu_ns) / (delta(mono_ns) * cores)` — computed
   engine-side per sample so Ring never does clock arithmetic.
3. **Metric series**: `stz_perf_series_create(capacity)` — a handle-backed
   `(t_ms, value)` ring buffer with engine-side `min/max/mean/last/
   slope/percentile` queries. The time-series store lives with the
   engine for the same reason the histograms do: recording must be O(1)
   and copy-proof, and analysis crosses the bridge once per question,
   not once per point.
4. *(Later, P6+)* a counting-allocator wrap for engine-heap statistics —
   the only way issue 3 (slow leaks) is attributable to engine vs Ring.

Numbers cross the bridge as **ms floats** (Ring numbers are f64; ns
overflows 2^53 — the bridge already documents this), ns only for short
intervals.

## 7. The instructive dimension

`Explain()` on the profile does not print numbers — it teaches the
analysis that connects them, using the reader's own workload:

```
? oPerf.Profile().Explain()
#-->
# Over the last 60s your server completed 2,412 requests: X = 40.2/s.
# CPU utilization averaged U = 0.62. Each request therefore demanded
# D = U/X = 15.4ms of CPU. At that demand, this machine saturates at
# 1/D = 65 req/s -- you are at 62% of the ceiling.
# Response time: p50 = 24ms, p95 = 141ms, p99 = 302ms. Little's law
# says N = X*R = 1.6 requests in flight on average -- consistent with
# the worker pool's measured in-flight of 2. The measurement is sound.
# Bottleneck: CPU. Memory is stable (slope ~ 0 over the window).
```

A student meets the utilization law through their own program; an
operator gets the capacity ceiling without opening a book. Same output.
This is the Softanza signature — the library explains itself
(`Explain()` already lives on 25+ classes; `Ask()` on `stzObject`), and
the perf domain is where explanation has the highest industrial value.

## 8. Instrumentation seams (verified attachment points)

| Metric | Hook | Where |
|---|---|---|
| Per-request R | bracket parse->dispatch->write | `stzAppServer._HandleHttpEvent`, stzAppServer.ring:725-751 |
| Throughput X | widen existing `@nRequestCount` + `/health` | stzAppServer.ring:730, 777-783 |
| Per-route timing | per branch in `_Dispatch` (make the dead `Use()` middleware seam real, or bracket directly) | stzAppServer.ring:754-789 |
| Marshalling cost, both modes | one timer in `_Roundtrip` | stzAppBackend.ring:997 |
| Crossing durations | add a ms column to `@aTraffic` rows | stzAppBackend.ring:669/678 |
| Fleet percentiles | **reuse** `stzClusterTelemetry` unchanged | stzClusterTelemetry.ring:65,85 |
| Backpressure | **reuse** `stzWorkerPool.Metrics()` | stzWorkerPool.ring:239 |
| Pipeline stages | add durations to `Trace()` rows | stzComputePipeline.ring:111-140 |
| Cross-world calls | bracket `CallAcross` / `FederatedCall` | stzSuperApp.ring:208 / stzComputeFederation.ring:167 |
| Closed-loop scaling | measured U feeds `ReportLoad()` | stzClusterSupervisor.ring:78 |

Caveat carried from the code: inside `_HandleHttpEvent`, reactor and
serverId must be snapshotted into locals before dispatch (handler
re-entry breaks bare `@attr` reads — the comment at stzAppServer.ring:
732-737); the perf bracket must respect the same discipline.

## 9. The seven issues, answered

| # | Issue | Mechanism |
|---|---|---|
| 1 | Slow running apps | request R histograms + per-operation profiler spans + service demand D per resource: *which* resource, *how much* per request |
| 2 | Degrade over time | trend on the R series (engine slope query) — degradation is a first-class verdict, not a feeling |
| 3 | Slow memory leaks | RSS gauge series + `:MemoryGrowthPerHour` SLA + `Forecast()` for time-to-ceiling |
| 4 | Huge leaks that crash | RSS threshold alert + peak tracking — fired *before* the crash, with the trace ids in flight |
| 5 | Periodic CPU spikes | CPU sampling + outlier detection (z-scores / `outlier_*`) + `timeline.zig` correlation of what ran during the spike |
| 6 | Different under load | the R-vs-X curve from the same histograms at different load levels; queueing says R explodes as U->1 — the profile shows *your* knee |
| 7 | Production-only problems | always-on O(1) engine recording (cheap enough to never turn off) + trace ids on the wire + a flight-recorder ring (timeline) snapshot dumped on alert — the black box is already written when the anomaly lands |

Issue 7 is the deepest reason for engine-side O(1) storage: the only
monitoring that helps with unreproducible problems is the monitoring
that was *already on*.

## 10. Governance: watch freely, act through the gate

- Metric reads are `sensing`-kind (they join `clock` in the capability
  catalog). Sensing is cheap to grant and is granted widely.
- Every *act* — `ScaleUp`, `RestartDead`, shed, tune — is `effectful`
  and goes through the standard machinery: an actor holding `effectful`,
  a plan, `MayProceed`, and an audit record. No new governance
  vocabulary is invented; the perf system is a *client* of the existing
  lattice.
- Therefore the closed loop is governed by construction:
  `Profile().Utilization()` -> `stzClusterSupervisor.ReportLoad()` ->
  `Decide()` -> apply — where *apply* is the effectful step and carries
  the audit. And an `LLMActor` (inference-only, sandboxed) can run the
  entire Monitor-Alert-Analyze arc and *propose* an optimization plan
  it is structurally unable to execute. Agentic performance tuning,
  safe by the same rule that keeps agents from touching production
  anywhere else in the library.

## 11. SLA at design time

The notebook says it in two words: *SLA — design*. Budgets are not
post-deployment aspirations; they are declared with the topology and
rehearsed with the delivery:

- `stzAppTopology` parts can carry perf budgets (`:p95Under = 200`) the
  way they already carry roles and data.
- `stzDelivery.Plan()` — which already rehearses placement before
  building — gains a rehearsal question only the perf system can
  answer: *does any part's declared budget exceed what its placement
  can deliver?* (A wasm part with a 5ms budget on a network crossing
  that costs 20ms is a plan-time refusal, not a production surprise.)
- `stzSla.CheckAgainst()` findings flow into `stzRuleReport` — the one
  CI gate — so a perf regression fails the build with the same shape
  and the same reporting as a security or governance violation.

## 12. Interop: perf data speaks the industry's formats

A performance system that can only talk to itself is a silo. Softanza
apps must be able to hand their perf data to -- and receive it from --
the tooling the rest of the world already runs. The rule: **every perf
object has a Softanza-native record shape (hashlist) AND an industry
serialization**, chosen per kind:

| Perf data | Industry format | Where |
|---|---|---|
| Timings / spans / traces | **OpenTelemetry** span JSON (OTLP vocabulary), W3C `traceparent` ids | P0, shipped: `stzStopwatch.ToOtelSpan()/ToOtelJson()/TraceParent()/JoinTrace()` |
| Metric streams (counters/gauges/timers) | **Prometheus exposition format** (`/metrics` text) + OTLP metrics JSON | P2, shipped: `stzMetric.PromText()/OtelMetricJson()`, `stzPerfMonitor.Prometheus()/OtelJson()`; P3 widens the server `/health` |
| Full trace batches | OTLP `resourceSpans` envelope | P3+ exporter (spans batch where requests flow) |
| SLA verdicts | findings `[ :invariant, :severity, :where, :message ]` -> `stzRuleReport` (the house CI gate) | P4 |

Two commitments that keep the interop honest: absolute time anchors
cross into JSON as **string nanos built from exact epoch millis** (Ring
numbers are f64; epoch nanos overflow 2^53 -- the exact ns duration
rides as an attribute where it fits), and trace identity is **real W3C**
(engine `tracectx`), so a Softanza span dropped into Jaeger/Tempo/
Datadog correlates with spans from any other instrumented service --
in and out.

## 13. Overhead discipline

A perf system that cannot state its own cost is not industry-strength.

- Hard budget: **O(1) engine work per event, zero Ring allocations on
  the hot path**; the request bracket is two engine clock reads and one
  histogram record.
- `oPerf.SelfCost()` reports the monitor's own service demand — measured
  with the same machinery it provides (the profiler measures the
  profiler). The perf guards assert it: observation under a stated
  fraction of the observed work, or the guard fails.
- Sampling is bounded (fixed-capacity series rings, the telemetry
  precedent's bounded trace ring), so a monitor left on for a month
  costs the same memory as one left on for an hour.

## 14. Plan of record (P0-P6)

Each phase ships the house triple: design section (this doc, updated) +
runnable narration (`narrations/stz-perf-*-narration.md`, every output
real) + narrated guard (`test/perf/perf_narrated`), and lands green
before the next begins.

- **P0 — The honest stopwatch. SHIPPED 2026-07-29.** `stzStopwatch`
  (numeric, monotonic, unlimited instances) in `base/perf/`;
  scope-named elapsed verbs; laps, pause/resume/stop; `Record()` +
  OTel span export with W3C trace identity (section 12); the
  `stzProfiler.ring` fossil retired to `base/archive/system/`;
  `pr()/pf()` kept as console sugar. Bonus engine fix found during
  implementation: `watch.zig`'s clock was wall-based
  (`nanoTimestamp()`) despite its header claiming monotonic — it now
  carries the same `Instant` baseline as the process-uptime fix, and
  the guard pins the property. State lives in the object (two clock
  reads + a sum), NOT the engine's 64-slot watch table — unlimited
  instances, nothing to Destroy(); the slot table stays as the C-ABI
  face for other hosts. Guard: `stopwatch_narrated.ring`, 35
  assertions green.
- **P1 — The engine senses. SHIPPED 2026-07-29.** `perf.zig`
  (`stz_perf.dll`, 19 bridged fns): RSS/peak (`K32GetProcessMemoryInfo`
  / `/proc/self/statm` + `getrusage`), system mem total/free
  (`GlobalMemoryStatusEx` / `/proc/meminfo`), process CPU time
  (`GetProcessTimes` user+kernel / `CLOCK_PROCESS_CPUTIME_ID`) — all
  f64, bytes and ns, -1 = platform refused (macOS RSS is a stated
  gap). Series: bounded (t,v) ring, mutex-protected, O(1) record;
  engine-side count/size/at/last/min/max/Kahan-mean/least-squares
  slope-per-ms/exact nearest-rank percentile. Ring face:
  `stzPerfSeries` (Record self-stamps with the monotonic watch clock;
  `RecordAt` names the bring-your-own-clock scope), `stzProcess` wears
  `MemoryBytes/PeakMemoryBytes/CpuTimeNs/CpuTimeMs`, and
  `Resources()` mem gap FILLED — live profiles observe, declared
  targets honestly report 0. Utilization verified live:
  U = dCPU/(dT*cores); a 200ms sleep advances CPU < 16ms while uptime
  advances 201ms. 8 zig tests (`zig test -lc src/perf.zig` — the
  build's test step skips entry files) + guard
  `engine_senses_narrated.ring` (36 assertions, incl. a watched leak
  whose slope turns positive). *(The one phase of pure new engine
  surface; everything after is composition.)*
- **P2 — Metrics and the monitor. SHIPPED 2026-07-29.** `stzMetric`:
  counter total lives in its own series (rate = slope of the
  cumulative line = measured X), gauge with SlopePerMs trend, timer
  double-answering percentiles (O(1) bucket bounds for unbounded
  streams AND sort-exact over the window) with exact lifetime
  sum/mean — the engine histogram gained `histogram_sum` (buckets
  quantize, the sum does not). `stzPerfMonitor`: watch declarations
  (memory/cpu/system), Every() cadence, three run modes — pull
  (`Sample()`), tick (`Tick()` from any loop), hosted (`Name_()` +
  `Cycle()` = the stzAgentHost contract; a server hosting agents
  samples its own health for free); utilization computed per interval
  from the P1 senses. Interop part two: `Prometheus()` exposition +
  `OtelJson()` resourceMetrics envelope. DESIGN LAW (proven by a live
  defect): all metric state engine-side AND handles materialized
  eagerly at birth — a lazily-created handle is created per-Ring-copy
  and silently forks the metric (recording face read 120, registry
  face read 0); the guard pins the fresh-copy case. Guard: 42
  assertions. Narration: `stz-metrics-monitor-narration.md`.
- **P3 — The seams.** `oSrv.Observe(oPerf)`: request bracket + widened
  `/health`; durations into backend `@aTraffic` and pipeline `Trace()`;
  `CallAcross`/`FederatedCall` brackets; cluster telemetry consumed
  as-is. After P3 every crossing in the library has a cost, not just a
  status.
- **P4 — Judgment.** `stzSla` + alerts (thresholds, outliers, breaker
  suppression, event-bus fanout, trace-id carrying); findings into
  `stzRuleReport`; perf budgets become CI-gateable.
- **P5 — Understanding.** `stzPerfProfile`: U/R/X/D, both laws with
  self-validation, `Bottleneck()`, trends, `Forecast()`, the R-vs-X
  curve, the narrated `Explain()`.
- **P6 — The governed loop.** Measured U feeds the supervisor; effectful
  acts through actor+plan+audit; the LLM-proposes-human-commits tuning
  flow; flight-recorder snapshot on alert; `SelfCost()` guard.

Risks named up front, per the numeric-foundation lesson (*the plan named
the wrong line 4 of 6 times — measure first*): P1's OS counters are
platform-specific (three implementations, one contract, regression-
tested like `process_uptime` — assert uptime-like sanity properties,
not exact values); the P3 request bracket sits on a re-entrancy-
sensitive path (respect the snapshot-to-locals idiom); and every phase's
guard must time the *interleaved* pattern, not the batch one.

## 15. Naming notes

- The name `stzPerf` appears once in the corpus — a sketch inside the
  `stzExterLib` narration meaning "C-powered speedups" (parallel sort
  etc.). Different concept (making code fast vs. knowing how fast code
  is). This system takes `base/perf/` and `stzPerfSystem`; if the
  ExterLib sketch ever materializes it should be renamed
  (`stzAccel` says what it means).
- `stzSla` not `stzSLA` (house casing); `stzStopwatch` not `stzTimer`
  (`stzReactiveTimer` exists and schedules rather than measures);
  `Observe(oPerf)` not `ObserveWith(...)` (no `With` pairs).

---

*Performance work fails when measurement, judgment and action live in
three different tools speaking three different languages. Softanza
already owns the clock, the histogram, the statistics, the reactor, the
governance and the narrator — this plan connects them into one system
that watches cheaply enough to never be off, judges against promises
made at design time, explains what it sees in the practitioner's own
numbers, and acts only through the same gates everything else in the
library must pass. The app that runs is the app that knows how it runs.*
