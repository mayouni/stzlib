# The Seams
### One verb makes a server measure itself -- and every crossing in the library carries its cost

> Every code block below is real, and every output block is its actual
> output (the run lives in `base/test/perf/_seams_narration_demo.ring`;
> the guard suite is `base/test/perf/seams_narrated.ring`, 40
> assertions, plus the appserver/pipeline/federation/superapp suites
> re-run green). Performance system P3 --
> `doc/design/SOFTANZA_PERF_SYSTEM.md`.

## Instruments need somewhere to stand

P2 built the instruments; until now they measured what you handed
them. P3 attaches them to the places where requests actually flow, so
R (response time) and X (throughput) stop being examples and become
*your server's* numbers. The whole attachment is one verb:

```ring
oMon = StzPerfMonitor("restolean")
oMon.WatchMemory().WatchCpu().Every(100)

oSrv = new stzAppServer()
oSrv.Observe(oMon)                  # <- the whole integration
oSrv.Get_("/menu", func oReq, oResp { oResp.Json([ "dish", "Couscous", "price", 12 ]) })
oSrv.Start(0, "127.0.0.1")
# ... 30 real requests over real HTTP ...
? "R p95 (exact)  : " + oMon.MetricQ("http.request.ms").ExactPercentile(95) + " ms"
? "R mean (exact) : " + oMon.MetricQ("http.request.ms").MeanMs() + " ms"
? "X measured     : " + oMon.MetricQ("http.requests").RatePerSecond() + " req/s"
```
```
R p95 (exact)  : 1.25 ms
R mean (exact) : 1.19 ms
X measured     : 134.14 req/s
```

From `Observe()` on, every request is bracketed inside the server's
event handler -- parse, transport gate, routing, your handler, render,
write handoff -- on the monotonic engine clock, and recorded into
three engine-backed instruments: the timer `http.request.ms` (R), the
counter `http.requests` (X is its measured rate), and `http.errors`
(a handler that raises becomes a *counted* 500, not just a served
one). The serve loop also ticks the monitor at its own cadence, so an
observed server samples its memory and CPU while it serves -- a
running app that watches itself, with nothing else to deploy.

Two disciplines inherited from the code it lives in: the bracket
snapshots its objects into locals before dispatch (the same re-entrancy
rule the write path already obeyed), and an *unobserved* server pays
one NULL-check per request -- `/metrics` without a monitor is an
honest 404, and nothing else changes.

## /health tells the truth, /metrics speaks Prometheus

The built-in probe used to answer with an uptime and a count. Now it
carries the P1 senses, and -- when observed -- the measured numbers an
operator actually triages with:

```ring
# GET /health
```
```
{"status":"healthy","engine":"softanza-resident","uptime_s":0.25,"requests_served":31,"rss_bytes":148905984,"cpu_ms":2453.13,"p50_ms":1,"p95_ms":2,"p99_ms":20,"rate_per_s":134.14}
```

And the observed server serves its whole registry -- senses, request
instruments, your own metrics -- in native exposition format. Point a
Prometheus scraper at it; when request signing is on, `/metrics` is
governed like every other path:

```ring
# GET /metrics
```
```
# HELP process_memory_rss Resident set size in bytes
# TYPE process_memory_rss gauge
process_memory_rss 148848640
# HELP process_memory_peak Peak working set in bytes
# TYPE process_memory_peak gauge
process_memory_peak 655249408
# HELP process_cpu_utilization Fraction of machine CPU this process used over the last sampling interval
# TYPE process_cpu_utilization gauge
process_cpu_utilization 0.04
# TYPE http_request_ms summary
http_request_ms{quantile="0.5"} 1
http_request_ms{quantile="0.95"} 2
http_request_ms{quantile="0.99"} 20
http_request_ms_sum 36.68
http_request_ms_count 31
# TYPE http_requests_total counter
http_requests_total 31
# TYPE http_errors_total counter
http_errors_total 0
```

## The ledger learns what things cost

`stzAppBackend` already kept an honest ledger of every cross-part
crossing -- who, what, and how it ended. P3 adds the missing column:
*what it took*. One timer at the one choke point both modes share
(`_Roundtrip`) prices local and remote crossings alike:

```ring
oB.Create(:phone, "orders", [ [ "dish", "Couscous" ], [ "qty", 2 ] ])
oB.Rows(:admin, "orders")
oB.Show()
```
```
Live backend 'restolean' -- live, port 58739, 3 crossing(s)
  #1 phone POST orders -> 201 (13.12 ms)
  #2 admin GET orders -> 200 (13.66 ms)
  #3 admin GET orders/count -> 200 (13.16 ms)
mean crossing  : 13.32 ms
```

Read that number the way the engine-first doctrine reads it: ~13 ms
per crossing, *on loopback, in one process* -- signing, wire framing,
serving, parsing. That is the marshalling cost the library's "cross
once per algorithm" rule has always warned about, now printed beside
every crossing that pays it. And a governance refusal is ledgered at
**0 ms** -- it never crossed, and the ledger refuses to pretend
otherwise.

## Pipelines name their bottleneck

Each stage of a compute pipeline now carries its duration; the
slowest stage stops hiding in the total:

```ring
oPipe.Run("scan:acme invoice")
aD = oPipe.StageDurations()
```
```
ocr : 0.03 ms
entities : 10.20 ms
index : 0.01 ms
total : 10.24 ms
```

The same treatment reaches the two cross-world choke points:
`stzSuperApp.CallAcross` ledgers every crossing -- clearance or
refusal -- with its cost (`Crossings()`, `LastCallMs()`), and
`stzComputeFederation.FederatedCall` times the full arc of gates,
signing and transport (`LastCallMs()`). Refusals are timed too: what
a gate costs is part of what the system knows about itself.

## Where this goes

After P3, every crossing in the library has a cost, not just a
status: requests, backend crossings, pipeline stages, world-to-world
calls. P4 adds judgment -- SLAs declared at design time, verdicts in
the same findings shape the CI gate already consumes. P5 turns the
accumulated R, X, and U into the operational analysis (`ServiceDemand`,
`Bottleneck()`, Little's-law self-check) that explains what all these
numbers mean.
