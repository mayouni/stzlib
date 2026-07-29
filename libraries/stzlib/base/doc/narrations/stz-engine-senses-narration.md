# The Engine Senses
### Memory and CPU become observable -- and a series that watches them for you

> Every code block below is real, and every output block is its actual
> output (the run lives in `base/test/perf/_senses_narration_demo.ring`;
> the guard suite is `base/test/perf/engine_senses_narrated.ring`, 36
> assertions). Performance system P1 --
> `doc/design/SOFTANZA_PERF_SYSTEM.md`.

## A program that cannot feel its own weight

Before P1, the Softanza engine could tell time with nanosecond
precision -- and nothing else about itself. No process memory, no
system memory, no CPU time. Four of the seven classic production
problems (apps that degrade, slow leaks, crash-sized leaks, CPU
spikes) were *unobservable*: not hard to diagnose -- impossible to
even see. `stzSystemProfile.Resources()` carried the admission in a
comment: memory is "a PLANNED engine add".

P1 is that add. One small engine module (`engine/src/perf.zig`,
`stz_perf.dll`) gives the process five senses:

```ring
? "rss   : " + StzEnginePerfMemRss()      / nMB + " MB"
? "peak  : " + StzEnginePerfMemPeak()     / nMB + " MB"
? "total : " + StzEnginePerfSysMemTotal() / (1024*nMB) + " GB"
? "free  : " + StzEnginePerfSysMemFree()  / (1024*nMB) + " GB"
? "cpu   : " + StzEnginePerfCpuNs() / 1000000 + " ms"
```
```
rss   : 119.71 MB
peak  : 622.68 MB
total : 31.61 GB
free  : 12.46 GB
cpu   : 2296.88 ms
```

`rss` is what the process holds right now; `peak` is the most it
*ever* held (a crash-sized leak announces itself there first — note
the gap above: this process once weighed 622 MB, five times its
current size, and only the peak remembers). The two
system numbers place the process on its machine. And `cpu` is the
fifth sense, worth a section of its own.

On `stzProcess`, the senses read as facts about *this process*:
`MemoryBytes()` (alias `Rss()`), `PeakMemoryBytes()`, `CpuTimeNs()`,
`CpuTimeMs()` -- next to `Pid()` and `Uptime()` where they belong.

## CPU time counts work, not waiting

A wall clock advances whether your program computes or sleeps. CPU
time advances **only when the process actually computes** -- which is
exactly what makes it the honest spike detector:

```ring
StzEngineTimeSleepMs(300)
# -> uptime advanced, cpu did not
# ... then a busy stretch ...
```
```
slept 300ms: uptime +301.78 ms, cpu +0 ms
worked hard: uptime +31.12 ms, cpu +31.25 ms
```

Sleeping 300 ms cost *zero* CPU. Working 31 ms cost 31 ms -- a
perfect 1:1, because that stretch really was pure computation. From
these two clocks and the core count, utilization -- the U of the
performance system's U/R/X/D vocabulary -- is one division:

    U = delta(cpu_ns) / (delta(uptime_ns) * cores)

A process at U near 1 has no headroom; a "frozen" app with low U is
not computing -- it is *waiting* on something, which is a different
diagnosis entirely. Two clocks, one division, and the first question
of every performance investigation ("busy or blocked?") has a number.

## The series: a month of watching for the price of an hour

Senses need somewhere to live. `stzPerfSeries` is a bounded
(time, value) ring buffer that stays **in the engine**: recording is
O(1), memory is fixed at creation, and Ring's copy-on-assign cannot
duplicate it (the handle survives copying). Sample a sense into it
and ask questions later -- here, an actual leak, watched as it grows:

```ring
s = StzPerfSeries(64)
aKeep = []
for i = 1 to 8
	aKeep + copy("y", 4 * nMB)     # the "leak": 4MB kept per lap
	s.Record(StzEnginePerfMemRss())  # stamped with the monotonic clock
next
? "first sample : " + s.ValueAt(1)/nMB + " MB"
? "last sample  : " + s.Last()/nMB + " MB"
? "mean         : " + s.Mean()/nMB + " MB"
? "slope        : " + s.SlopePerMs()/nMB + " MB per ms"
```
```
first sample : 130.30 MB
last sample  : 158.34 MB
mean         : 144.32 MB
slope        : 1.07 MB per ms
```

`SlopePerMs()` is a least-squares fit of value over time, computed
engine-side: a stable gauge slopes ~0, a leaking one slopes positive.
That single number is the notebook's issue 3 -- *slow memory leaks
that gradually degrade performance* -- turned into something a
threshold can watch. The guard also pins the exact statistics:
`Mean()`, `Min()`/`Max()`, and `Percentile()` -- which is **exact**
here (sort of the retained window), unlike `stzLatencyHistogram`'s
bucketed answers. Pick the histogram for unbounded request streams,
the series for windowed gauges.

The ring's honesty is explicit about forgetting:

```ring
s2 = StzPerfSeries(3)
for i = 1 to 5
	s2.RecordAt(i, i * 100)
next
? "Count() = " + s2.Count() + " ; Size() = " + s2.Size()
? "window  = " + s2.ValueAt(1) + ", " + s2.ValueAt(2) + ", " + s2.ValueAt(3)
```
```
Count() = 5 ; Size() = 3
window  = 300, 400, 500
```

`Count()` remembers everything ever recorded; `Size()` is what the
window retains; the oldest samples gave way. A monitor sampling once
a second into a 3600-slot series holds exactly the last hour --
forever, at constant cost. That boundedness is not a compromise: it
is the property that lets production monitoring stay on permanently,
which is the only kind that helps with problems you cannot reproduce.

## The profile stops apologizing

The oldest known gap closes. Live system profiles now carry the
memory facts; a *declared* target -- a machine you have described but
never observed -- honestly reports zero rather than inventing them:

```ring
aRes = CurrentSystem().Resources()
? "mem_total    : " + aRes["mem_total"] / (1024*nMB) + " GB"
? "mem_free     : " + aRes["mem_free"]  / (1024*nMB) + " GB"
? "declared box : mem_total = " + DeclareSystem("target-box").Resources()["mem_total"]
```
```
mem_total    : 31.61 GB
mem_free     : 12.45 GB
declared box : mem_total = 0
```

(`mem_free` in a profile is a snapshot taken when the profile was
populated -- for the moving value, sample the sense itself.)

## Honest limits, and where this goes

The senses are engine-true on Windows and Linux (`GetProcessMemoryInfo`
/ `GlobalMemoryStatusEx` / `GetProcessTimes` on one; `/proc` and
`getrusage` on the other); macOS currently answers -1 for RSS -- a
stated gap, not a silent zero. Series statistics answer over the
retained window only, and `Record()` self-stamps with the monotonic
watch clock (bring your own clock with `RecordAt()` when you need a
different time scope).

With P1 the perf system can *feel*; it cannot yet *watch by itself*.
P2 builds `stzMetric` (counter/gauge/timer faces over this series) and
`stzPerfMonitor` (sampling on the reactive substrate), P4 adds the SLA
that judges what the senses report, P5 the operational analysis that
explains it. The senses stay what they are: five questions the engine
can now answer about its own body.
