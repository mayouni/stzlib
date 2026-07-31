# Log-Trace Correlation
### The trace scope: whatever logs inside it is correlated for free -- and the OTel triad completes

> Every code block below is real, and every output block is its actual
> output (the run lives in `base/test/perf/_logtrace_narration_demo.ring`;
> the guard suite is `base/test/perf/log_trace_narrated.ring`, 24
> assertions; stzLog's own suite re-runs green). Performance system P9
> -- `doc/design/SOFTANZA_PERF_SYSTEM.md`.

## The last unlinked telemetry

After P8 the system had spans, metrics and logs -- but the logs stood
apart: a log line knew *when* but not *for which request*. The field
solves this with context propagation frameworks; Softanza solves it
with one engine-global slot and a scope discipline it already had.

## The trace scope

`StzOpenTraceScope()` puts a W3C traceparent in an engine-global
slot; every `stzLog` record written while it is open -- any log, in
any object, on any Ring face -- stamps the active trace id as an
ordinary queryable field. Close the scope and logging is anonymous
again:

```ring
StzOpenTraceScope("")
$oLog.Info("charging the card")
$oLog.Record(:warn, "gateway slow, retrying", [ [ :gateway, "stripe" ] ])
StzCloseTraceScope()
$oLog.Info("nightly cleanup")
see $oLog.AsText()
```
```
1785482186005 INFO restolean: charging the card  {traceId=6e262c37f3c493b30f6a4297aad02273}
1785482186005 WARN restolean: gateway slow, retrying  {gateway=stripe, traceId=6e262c37f3c493b30f6a4297aad02273}
1785482186005 INFO restolean: nightly cleanup
```

The engine slot is the point (a Ring-side "current trace" would be
per-face state, and a handler's log would never see the server's
scope). Inside a scope, `StzCurrentTraceParent()` is what a
downstream call sends onward, and a stopwatch `JoinTrace()`s it --
spans and log lines, one trace.

## The server does it for you

An observed, tracing server opens the scope around every request --
after the trace identity is settled, before dispatch -- and closes it
with the bracket. A handler that just *logs* is correlated with no
plumbing at all:

```ring
oSrv.Get_("/order", func oReq, oResp {
	$oLog.Info("taking the order")     # no trace code anywhere
	$oLog.Info("order placed")
	oResp.Text("placed")
})
# ... two real requests ...
aL = $oLog.OfTrace(aT[2][:traceId])
```
```
request 1 trace: 688c026d3fdcce0a58d0e0ad9d629e20
request 2 trace: 5a980994ab7e582b3f76e50517bbc7d9
lines of request 2 alone:
  taking the order
  order placed
```

Two requests through the same handler, two distinct traces, and
`OfTrace()` separates their interleaved lines exactly.

## The 3 a.m. circle, complete

P7 taught the black box to name the requests nearest a breach. Those
ids were addresses into *someone else's* systems (Jaeger, Tempo).
Now they are also addresses into your own logs:

```ring
cTrip = oSent.LastBlackBox()[:traces][1][:traceId]
aL = $oLog.OfTrace(cTrip)
```
```
breach trip 688c026d3fdcce0a58d0e0ad9d629e20 -> its log lines:
  taking the order
  order placed
```

Alert -> the requests that tripped it -> the handler's own words
while serving them. The investigation that used to start with grep
and a timestamp guess starts with evidence, all of it recorded
before anyone was awake.

## The triad closes

`stzLog.OtelJson()` renders the OTLP logs envelope -- what a
collector ingests at `/v1/logs` -- with severity text and standard
numbers, fields as attributes, and the trace id **promoted to the
logRecord's first-class `traceId` field**, where tracing backends
expect it (an unscoped record simply has none):

```
{"resourceLogs":[{"resource":{"attributes":[{"key":"service.name","value":{"stringValue":"restolean"}}]},"scopeLogs":[{"scope":{"name":"softanza.log"},"logRecords":[{"timeUnixNano":"1785482186005000000","severityText":"INFO","seve...
```

Spans (P0/P7), metrics (P2), logs (P9): the three OpenTelemetry
signals, all exported natively, all sharing W3C trace identity. A
Softanza app now speaks the industry's full telemetry language --
in and out, no agent, no sidecar.

## Honest limits

The scope is one slot, which matches the runtime: one request in
flight per serve loop. Concurrent in-process request handling (if the
reactor ever dispatches handlers in parallel) would need per-task
scopes -- noted for that day. And correlation reaches logs written
THROUGH stzLog; a bare `?` print stays a bare print.
