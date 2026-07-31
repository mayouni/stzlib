# The Driven Load
### Real processes, real queueing -- the R-vs-X knee, measured instead of cited

> Every code block below is real, and every output block is its actual
> output (the run lives in `base/test/perf/_load_narration_demo.ring`;
> the guard suite is `base/test/perf/driven_load_narrated.ring`, 11
> assertions, ~10s of real processes). Performance system P11 --
> `doc/design/SOFTANZA_PERF_SYSTEM.md`.

## The ruling this phase overturns

P7 ruled the R-vs-X harness out honestly: the knee -- response time
exploding as throughput nears its ceiling -- is queueing's signature,
queueing needs CONCURRENT arrivals, and a serial in-process harness
cannot produce them. The ruling said the knee "belongs with the
cluster's infra-gated work". Re-reading it later, the gate was
already open: the repo has spawned real `ring` child processes since
R8 (the fleet) and the remote backend. Concurrency does not need a
second machine -- it needs more PROCESSES.

## The harness

`stzLoadDriver` spawns a target `stzAppServer` as one child (its
/work handler burns a configured number of CPU milliseconds -- real
service demand D, not a sleep, because a sleeping handler saturates
nothing) and N driver clients as more children, each firing its
requests independently. Arrivals interleave at the listener; the
single-threaded server queues them; and each driver measures every
request ARRIVAL-TO-ANSWER -- connect, queue wait, service -- the wait
the server-side bracket structurally cannot see. Durations come home
through stdout; the parent folds them into an engine series, so the
percentiles are exact.

```ring
oL = StzLoadDriver()
oL.SetBusyMs(3).SetRequestsPerDriver(25)
oL.SpawnTarget(0)
oL.Curve([ 1, 3, 8 ])
oL.Show()
oL.Destroy()
```
```
Driven load -- target 127.0.0.1:37576, D ~3ms CPU/request, 3 level(s).
  1 driver(s): X = 9.60 req/s, R mean 6.35 ms, p95 8.14 ms
  3 driver(s): X = 22.24 req/s, R mean 9.88 ms, p95 12.41 ms
  8 driver(s): X = 42.27 req/s, R mean 27.69 ms, p95 32.78 ms
The knee, in one sentence: 8x the drivers bought 4.40x the throughput at 4.40x the response time -- past saturation, added load buys only waiting.
```

## Reading the curve like the book says

This is the closed-loop queueing story the P5 profile teaches,
measured end to end:

- **X grows sub-linearly** (9.6 -> 22.2 -> 42.3 for 1 -> 3 -> 8
  drivers): each added driver buys less throughput than the last,
  because the server's capacity -- bounded by service demand plus
  per-request overhead -- is finite.
- **R grows super-linearly** (6.4 -> 9.9 -> 27.7 ms): below
  saturation a request mostly pays its own cost; past it, a request
  mostly pays for the requests AHEAD of it. The p95 grows faster
  than the mean -- queueing punishes the tail first.
- The one-sentence knee is the capacity-planning lesson: past
  saturation, added load buys only waiting. The right responses --
  scale out (the P6 loop), shed (the worker pool), or cut D (the
  P10 profiler finds where) -- are all elsewhere in this same
  system.

## Honest notes

Closed-loop drivers (fire the next request when the previous
answers) are the classic model, and the numbers carry per-connection
overhead (each request opens a fresh connection -- that is most of
the gap between D~3ms and the unloaded R~6ms). Absolute rates are
this laptop's; the SHAPE is the law, and the guard asserts the shape
-- more load bought more X AND more R, tail included -- with bounds
generous enough to hold on any machine. The suite runs real
processes and prices itself (~10s, budgeted under 45).

With P11, the last ruled deferral within reach is closed. What
remains absent from the comparison table is downstream by design:
storage, PromQL, dashboards -- the world this system exports to.
