# The Profile
### Four letters explain your server -- U, R, X, D -- and the analysis checks itself

> Every code block below is real, and every output block is its actual
> output (the run lives in `base/test/perf/_profile_narration_demo.ring`;
> the guard suite is `base/test/perf/profile_narrated.ring`, 31
> assertions). Performance system P5 --
> `doc/design/SOFTANZA_PERF_SYSTEM.md`.

## From numbers to understanding

Everything before P5 measures: the stopwatch times, the senses read,
the metrics keep, the seams attribute, the SLA judges. The profile is
the layer that *understands* -- the operational analysis tradition
(utilization law, Little's law, service demand) applied to the
numbers your own server produced. One object, anchored on an
interval, and the whole analysis narrates itself:

```ring
oP = StzPerfProfile(oMon)          # anchors CPU, requests, the clock
# ... 40 real requests against an Observe()d server ...
oP.Show()
```
```
Profile of monitor 'restolean' over the last 0.40 s (12 cores).
Work: 40 request(s) completed: X = 100.87 req/s.
CPU: 203.13 ms consumed: U = 0.04 of the machine.
Each request therefore demanded D = 5.08 ms of CPU -- the service demand, the most diagnostic number here.
At that demand this machine saturates near Xmax = 12 x 1000/D = 2363.08 req/s -- headroom 95.73%.
Response time R: mean 3.32 ms; p50/p95/p99 = 3.15 / 3.39 / 8.78 ms (timer window).
Little's law: N = X*R = 0.33 request(s) in flight on average.
The process computed 5.08 CPU-ms per request -- MORE than each request's 3.32 ms of wall time: concurrent threads or co-resident work computed alongside (D is per-PROCESS). Either way the constraint is CPU -- faster code or more cores move this app.
Memory: rss trending +20712.34 MB/hour -- watched growth; set a :MemoryGrowthPerHour budget (P4) to be paged before it matters.
```

A student meets the utilization law through their own program; an
operator gets the capacity ceiling without opening a book. Same
output. Walk the letters:

- **X** is measured throughput: requests completed over the interval.
- **U** is measured utilization: CPU consumed over interval x cores.
- **D = CPU / requests** is the *service demand* -- what one request
  actually costs in compute. Most monitoring tools never surface it;
  it is the most diagnostic number in performance work, because...
- **Xmax = cores x 1000 / D** falls straight out of it: the law
  `U = X * D` says the machine saturates when U reaches 1. That
  single line is most of capacity planning.

The profile is interval-based: it anchors CPU time, the request
count, and the timer's exact sum/count at birth (`Mark()` re-anchors)
-- so the interval's D and the interval's mean R describe *the same
requests*. Mixing a lifetime R with an interval D would compare
different populations; the profile refuses to.

## The analysis distrusts itself -- on purpose

Computed from one set of anchors, `U = X * D / cores` is an algebraic
identity -- it can never fail, so it proves nothing. The profile's
self-check is real: it compares its anchor-computed U with the
utilization the monitor *sampled independently* while serving. Two
measurements, one truth:

```ring
aUC = oP.UtilizationCheck()
? aUC[:message]
```
```
U computed from anchors = 0.03, U sampled by the monitor = 0.03: the two measurements agree -- the measurement is sound
```

Little's law gets the same treatment: `LittleN()` is the concurrency
your throughput and response time *imply* (N = X * R); hand
`LittleCheckAgainst()` a concurrency you measured elsewhere (a worker
pool's `InFlight()`), and disagreement means the *measurement* is
broken -- a self-test no dashboard offers. In the guard, the serial
test harness implies N = 0.23 in flight -- correctly under 1, because
requests never overlap there.

## Busy or blocked -- the first question, answered with a number

A slow app is either computing or waiting. The split of each
request's R into D (computed) and R - D (waited) names which:

```ring
# six 10ms-sleeping "requests" fed through the standard instruments
aB = oPW.Bottleneck()
? "kind = :" + aB[:kind] + " -- " + aB[:cpuMsPerRequest] + " ms computed, " + aB[:waitMsPerRequest] + " ms waited"
```
```
kind = :waiting -- 0 ms computed, 14.39 ms waited
```

Blocked work shows itself: essentially zero computed, all waited --
look at IO, locks, and queues, not the CPU. The busy case (the 40
compute-heavy requests above) reads the opposite way.

And the honest wrinkle the first demo run exposed, kept in the
narration because it teaches: D can *exceed* R. D counts the whole
process's CPU -- every thread -- while R times one request's wall
clock. When D > R, something computed alongside the requests (here:
the in-process test client itself, plus the reactor thread). Explain()
says exactly that instead of pretending each request's time splits
neatly. On a real deployment where the server is alone in its
process, D <= R and the split is exact.

## The forecast

The rss trend the P1 senses feed becomes a date:

```ring
? "trend  = " + oPL.MemoryTrendPerHour()/nMB + " MB/hour"
? "at this trend, +500MB in " + (oPL.HoursToMemoryCeiling(nRss + 500*nMB) * 3600) + " seconds"
```
```
trend  = 120687.42 MB/hour
at this trend, +500MB in 14.91 seconds
```

(A deliberately violent test leak -- but the same two lines, on a
production monitor sampling once a second, answer "when does memory
hit the container limit" in hours or days. A ceiling already passed
answers 0; a stable rss answers -1: never, at this trend.)

`Snapshot()` records an (X, U, D, Rp95) point for the current
interval; drive different load levels, snapshot each, and `Curve()`
is your R-vs-X curve -- where response time turns as throughput
climbs toward Xmax.

## Where this goes

The profile completes the Analyze verb of the notebook's pipeline:
Monitor (P1-P3) -> Alert (P4) -> **Analyze (P5)** -> Optimize (P6).
What remains is the governed loop: the measured U feeding the cluster
supervisor's scaling policy, effectful acts crossing through
actor-plan-audit, and the monitor pricing its own overhead
(`SelfCost()`). The analysis is done; what it finds, governed action
may fix.
