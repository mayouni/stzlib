# Metrics and the Monitor
### Named streams of measurement, a sampler that hosts like an agent -- and the copy that almost lied

> Every code block below is real, and every output block is its actual
> output (the run lives in `base/test/perf/_metrics_narration_demo.ring`;
> the guard suite is `base/test/perf/metrics_monitor_narrated.ring`, 42
> assertions). Performance system P2 --
> `doc/design/SOFTANZA_PERF_SYSTEM.md`.

## From senses to instruments

P1 gave the engine senses -- it can read its own memory and CPU. But a
sense is not an instrument: nothing named the readings, nothing kept
them, nothing watched on a cadence. P2 adds the two missing objects.

**`stzMetric`** is one named stream of measurements, its kind declared
at birth: a `:Counter` counts events, a `:Gauge` tracks a level, a
`:Timer` collects durations. **`stzPerfMonitor`** owns a registry of
them and samples the senses on a declared cadence. Here is a checkout
"shop" instrumented with both, plus the two watches, driven for 120
simulated orders:

```ring
oMon = StzPerfMonitor("restolean")
oMon.WatchMemory().WatchCpu().Every(50)
mOrders = oMon.NewCounter("shop.orders")
mCheckout = oMon.NewTimer("shop.checkout.ms")

for i = 1 to 120
	w = StzStopwatch()
	# ... the checkout work ...
	mCheckout.RecordWatch(w)      # the P0 stopwatch feeds the P2 timer
	mOrders.Increment()
	oMon.Tick()                   # samples only when 50ms are due
next
? "orders rate  : " + mOrders.RatePerSecond() + " /s"
? "checkout p95 : " + mCheckout.P95() + " ms (bucket bound)"
? "checkout p95 : " + mCheckout.ExactPercentile(95) + " ms (exact, window)"
? "checkout mean: " + mCheckout.MeanMs() + " ms (exact lifetime)"
```
```
orders rate  : 729.77 /s
checkout p95 : 5 ms (bucket bound)
checkout p95 : 2.35 ms (exact, window)
checkout mean: 1.26 ms (exact lifetime)
```

Three teachings in four lines of output. The counter's
`RatePerSecond()` is **measured, not configured** -- the counter
records its cumulative total on the monotonic clock, and the rate is
the slope of that line: this is the throughput X of the U/R/X/D
vocabulary, read off the metric itself. The timer answers percentiles
**twice**, honestly: `P95()` comes from the O(1) bucketed histogram
(right for unbounded streams, quantized to bucket bounds -- 5 ms
here), `ExactPercentile(95)` from the recent window (sort-exact --
2.35 ms). And `MeanMs()` is exact over the metric's whole life,
because P2 taught the engine histogram to keep a true running sum
alongside its buckets: the buckets quantize, the sum does not.

## The copy that almost lied

Ring copies objects on assignment. A metric holding its total in a
Ring attribute would fork silently: increment through the copy, read
zero through the original. The design rule: **all metric state lives
in the engine** (a series ring + for timers a histogram); a Ring copy
is just a second face on the same engine truth.

While building this, the rule caught a real defect -- worth telling
because the failure was invisible until composed. The timer's
histogram wrapper creates its engine handle *lazily* (a robustness
move for Ring's paren-less `new`, which skips `init()`). A fresh
timer, registered in a monitor and then assigned to a variable, got
copied *before* any recording -- so no handle existed yet, each face
materialized its **own** histogram on first touch, and the recording
face counted 120 while the monitor's face read 0. Two objects, both
working, silently measuring different worlds.

The cure is a rule you can carry to any Ring engine-wrapper design:
**materialize engine handles eagerly, at birth -- before the object
can be copied.** One handle, created once, rides into every copy.
The guard now pins the exact scenario:

```ring
tFresh = StzMetric("fresh.timer", :Timer)
tFork = tFresh                   # copied BEFORE any recording
tFork.Record(9)
? tFresh.Count()                 # the ORIGINAL sees the copy's record
```
```
1
```

## Three ways to run the monitor -- the third one is the point

`Sample()` pulls one sample now. `Tick()` samples only when the
`Every()` cadence is due -- call it from any loop you already have.
But the monitor also implements `Name_()` and `Cycle()` -- the house
agent contract -- so **any `stzAgentHost` supervises it like any
other agent**, no adapter:

```ring
oMon2 = StzPerfMonitor("hosted")
oMon2.WatchMemory().Every(60)
oHost = new stzAgentHost()
oHost.Supervise(oMon2, 60)
oHost.RunFor(250)
? "host ticks   : " + oHost.TicksOf("hosted")
? "rss samples  : " + oMon2.MetricQ("process.memory.rss").Count()
```
```
host ticks   : 4
rss samples  : 4
```

Note what just happened across the copy boundary: `Supervise()` stored
a *copy* of the monitor, the host ticked *that* copy, and our original
`oMon2` reads the samples anyway -- engine truth again. And since
`stzAppServer` hosts agents on this same contract, a server that
serves requests can supervise its own monitor in the same loop:
monitoring becomes something a running app *does*, not something done
to it.

## The one-screen picture

```ring
oMon.Show()
```
```
Monitor restolean -- 5 metric(s), sampling every 50 ms, 4 sample(s) taken.
  Metric process.memory.rss (:gauge).
    now: 138014720 ; mean: 138006528 ; min..max: 137981952..138014720
    trend: 192.02 per ms
  Metric process.memory.peak (:gauge).
    now: 654696448 ; mean: 654696448 ; min..max: 654696448..654696448
    trend: 0 per ms
  Metric process.cpu.utilization (:gauge).
    now: 0.05 ; mean: 0.08 ; min..max: 0.05..0.10
    trend: -0.00 per ms
  Metric shop.orders (:counter).
    total: 120 ; rate: 729.77/s
  Metric shop.checkout.ms (:timer).
    count: 120 ; mean: 1.26 ms (exact)
    p50/p95/p99: 2 / 5 / 5 ms (bucket bounds)
```

The utilization gauge is the U of operational analysis, sampled from
the P1 senses (`dCPU / (dT * cores)` per interval, computed by the
monitor -- the first sample only anchors the baseline, honestly
recording nothing since there is no interval to speak about yet).

## Speaking Prometheus and OTLP -- the industry handshake, part two

P0 taught timings to export as OpenTelemetry spans. P2 completes the
metrics half of the interop rule. `Prometheus()` renders the exact
text a `/metrics` endpoint serves -- Prometheus naming folds the dots
to underscores, counters gain `_total`, timers export as summaries
with quantiles and the exact `_sum`/`_count`:

```ring
see oMon.Prometheus()
```
```
# HELP process_memory_rss Resident set size in bytes
# TYPE process_memory_rss gauge
process_memory_rss 138014720
# HELP process_memory_peak Peak working set in bytes
# TYPE process_memory_peak gauge
process_memory_peak 654696448
# HELP process_cpu_utilization Fraction of machine CPU this process used over the last sampling interval
# TYPE process_cpu_utilization gauge
process_cpu_utilization 0.05
# TYPE shop_orders_total counter
shop_orders_total 120
# TYPE shop_checkout_ms summary
shop_checkout_ms{quantile="0.5"} 2
shop_checkout_ms{quantile="0.95"} 5
shop_checkout_ms{quantile="0.99"} 5
shop_checkout_ms_sum 151.48
shop_checkout_ms_count 120
```

`OtelJson()` batches every metric into one OTLP `resourceMetrics`
envelope (counters as monotonic sums, gauges as gauges, timers as
summaries; OTel keeps the dotted names):

```ring
? left(oMon.OtelJson(), 160) + "..."
```
```
{"resourceMetrics":[{"resource":{"attributes":[{"key":"service.name","value":{"stringValue":"restolean"}}]},"scopeMetrics":[{"scope":{"name":"softanza.perf"},"m...
```

Point a Prometheus scraper or an OTLP collector at a Softanza app and
its numbers arrive speaking the native tongue -- no agent, no sidecar.

## Honest limits, and where this goes

Timer bucket percentiles are bounds, not values (use
`ExactPercentile()` when the window suffices). The monitor's cadence
bookkeeping and CPU baseline are Ring-side: whichever face runs the
loop keeps the baseline -- every face reads the same data, but only
one face should *drive*. Wrong-kind calls refuse loudly with the kind
they belong to. Engine handles still need `Destroy()`.

P3 attaches these instruments to the places requests actually flow --
the appserver's per-request bracket, the backend's crossings, the
pipeline's stages -- so R and X stop being examples and start being
your server's numbers. P4 judges them against SLAs; P5 explains them.
