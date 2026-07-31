# Labels and Dimensions
### One name, many children -- engine-registered, cardinality-bounded, and honest about overflow

> Every code block below is real, and every output block is its actual
> output (the run lives in `base/test/perf/_labels_narration_demo.ring`;
> the guard suite is `base/test/perf/labels_narrated.ring`, 29
> assertions). Performance system P8 --
> `doc/design/SOFTANZA_PERF_SYSTEM.md`.

## The gap the comparison named

The vs-the-field document called flat metric names this system's most
consequential absence: `http.request.ms` measured everything, so
"which route is slow?" had no direct answer. P8 closes the gap with
the field's vocabulary -- a metric FAMILY is one name plus declared
label names, and each label-value combination is a CHILD with its own
engine stores:

```ring
oF = StzMetricFamily("checkout.ms", :Timer, [ "route", "method" ])
oF.Child([ "/menu", "GET" ]).Record(12)
oF.Child([ "/menu", "GET" ]).Record(18)
oF.Child([ "/pay", "POST" ]).Record(220)
? oF.Child([ "/menu", "GET" ]).ExactPercentile(95)
? oF.Child([ "/pay", "POST" ]).ExactPercentile(95)
```
```
children     : 3 (incl. the reserved overflow)
/menu p95    : 18 ms
/pay  p95    : 220 ms
```

A child is a full `stzMetric` -- exact window percentiles, streaming
buckets, rates, trends -- scoped to its label values.

## The registry lives in the engine -- the copy law, one level up

The hard problem was not the label syntax; it was Ring's
copy-on-assign, one level up from where P2 met it. Children are
created *dynamically* -- a route first hit after the server copied its
monitor -- and a Ring-side child registry would fork per copy: the
server's face would know routes the user's face never sees. So the
child registry is an ENGINE store, like every other perf truth:

```ring
oF2 = oF                                  # a Ring copy
oF2.Child([ "/refund", "POST" ]).Record(77)   # a child born through the COPY
? oF.Child([ "/refund", "POST" ]).Count()     # read through the ORIGINAL
```
```
born through the copy, seen by the original: 1 sample(s)
```

Each face keeps only a small reconstruction cache of child wrapper
objects -- derived state, rebuilt on miss, never the truth.

## Cardinality bounded, overflow visible

The field's label systems have a famous failure mode: an unbounded
label value (a user id, a raw URL) mints millions of children and
takes the monitoring down with the app. A Softanza family takes its
bound at birth and RESERVES an overflow child; when the family is
full, new label sets route there -- counted, never silently dropped,
and visible in the exposition, which is itself the alarm:

```ring
oB = StzMetricFamilyXT("api.calls", :Counter, [ "user" ], 64, 4)
# alice, bob, carol fit; dave and erin arrive when the family is full
see oB.PromText()
```
```
# TYPE api_calls_total counter
api_calls_total{user="_overflow"} 2
api_calls_total{user="alice"} 1
api_calls_total{user="bob"} 1
api_calls_total{user="carol"} 1
```

One TYPE header for the family, one labeled sample line per child --
the exposition format Prometheus scrapes, quantiles merged into the
label braces for timers. The OTLP side renders one metric with one
data point per child, labels as attributes.

## Per-route truth from real traffic

`ObserveRoutes()` is `Observe()` plus a timer family `http.route.ms`
labeled `[method, route, class]` -- one child per route the traffic
actually exercises, status-classed (2xx/4xx/5xx) so errors get their
own distribution:

```ring
oSrv.ObserveRoutes(oMon)
# ... six real requests across /menu and /order ...
oFam = oMon.MetricQ("http.route.ms")
? oFam.Child([ "GET", "/menu", "2xx" ]).ExactPercentile(95)
? oFam.Child([ "GET", "/order", "2xx" ]).ExactPercentile(95)
```
```
/menu  p95 : 6.13 ms (3 reqs)
/order p95 : 3.23 ms (3 reqs)
```

Read that output twice -- it contains a lesson. `/order` does real
work per request; `/menu` returns a constant string; yet `/menu`'s
p95 is higher. The first request of the run landed on `/menu` and
paid the connection warm-up. This is exactly what per-route views are
FOR: the aggregate `http.request.ms` averaged that spike away, and
the labeled view surfaces it. (It is also a reminder from the P5
grind: small samples carry their outliers -- judge distributions,
not anecdotes.)

The flat instruments stay flat -- `http_requests_total` renders
without braces, byte-identical to P3, and the SLA's well-known
subjects still judge them. An SLA judges CHILDREN, not families:
asking a family for a single `Value()` refuses with that guidance.

## Where this leaves the comparison

The vs-the-field scorecard moves: labels/dimensions shift from "the
biggest gap" to shipped -- with two properties the field's label
systems lack (an engine-shared child registry that survives value
copies, and cardinality bounded by design with a visible overflow
bucket). Still absent, still honest: PromQL-style aggregation ACROSS
children (sum by route) is a downstream system's job; label-based
SLA selection stays child-explicit.
