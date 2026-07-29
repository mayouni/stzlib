# Judgment
### The SLA as part of the design -- judged by the same gate as security, alerted on the edge

> Every code block below is real, and every output block is its actual
> output (the run lives in `base/test/perf/_judgment_narration_demo.ring`;
> the guard suite is `base/test/perf/judgment_narrated.ring`, 41
> assertions). Performance system P4 --
> `doc/design/SOFTANZA_PERF_SYSTEM.md`.

## A promise is not a dashboard threshold

The industry adds performance thresholds after the incident, in a
monitoring tool, in that tool's language. Softanza's position is the
notebook's original two words -- *SLA: design* -- the promise is part
of the program, stated in the operational vocabulary next to the code
it judges:

```ring
oSla = StzSla("restolean-api")
oSla.Expect(:ResponseTimeP95).Under(200)
oSla.Expect(:Availability).AtLeast(99.9)
oSla.Expect(:ErrorRate).AtMost(0)
oSla.CheckAgainst(oMon)
oSla.Show()
```
```
SLA restolean-api -- 3 expectation(s), last check: MET.
  [MET] response-time-p95-under-200: measured 5.97 (must be <= 200)
  [MET] availability-atleast-99.90: measured 100 (must be >= 99.90)
  [MET] error-rate-under-0: measured 0 (must be <= 0)
```

Every verdict carries the *measured actual* -- judgment against real
numbers from the P3 seams, not against hope. The grammar protects
itself: an open `Expect()` refuses a second one until a closer
(`Under`/`AtLeast`/`AtMost`/`Over`) lands, and an unknown subject
refuses with the catalog in the error message.

Then one handler starts raising. One request out of thirteen:

```ring
# one GET /boom -> a counted 500 ... then judge again
oSla.CheckAgainst(oMon)
oSla.Show()
```
```
SLA restolean-api -- 3 expectation(s), last check: BREACHED (2).
  [MET] response-time-p95-under-200: measured 5.97 (must be <= 200)
  [BREACH] availability-atleast-99.90: measured 92.31 (must be >= 99.90)
  [BREACH] error-rate-under-0: measured 7.69 (must be <= 0)
```

## The perf budget fails the SAME build the security rules fail

Verdicts are findings in the unified rule shape the graph-rules plan
settled -- `[ :rule, :subject, :where, :severity, :message ]`, subject
`"perf"` -- so they join `stzRuleReport`, the one CI gate that already
covers code, agents, security, workflow and orgcharts. No adapter,
just `Ingest()`:

```ring
oRep = new stzRuleReport("restolean-ci")
oRep.Ingest(aF)
oRep.Report()
? "IsSound() = " + oRep.IsSound()
```
```
Rule report 'restolean-ci': 2 finding(s), 2 error(s), 0 warning(s) -> UNSOUND (errors present)
  [perf] 2 finding(s)
    ERROR availability-atleast-99.90 @ restolean-api/http.requests -- availability-atleast-99.90: measured 92.31 (must be >= 99.90)
    ERROR error-rate-under-0 @ restolean-api/http.requests -- error-rate-under-0: measured 7.69 (must be <= 0)
IsSound() = 0
```

A p95 regression now fails CI with the same shape, the same report,
and the same severity conventions as a capability-escalation finding.
`AsWarning()` softens an expectation to advisory -- it reports but
does not fail the gate. And an SLA judging a monitor that lacks the
metric produces an **error finding saying NOT MEASURED** -- an SLA
that cannot see is broken, not satisfied; there is no silent pass.

## The outlier judgment -- and the trap in the obvious formula

`ExpectStable(metric)` judges spikes: the newest sample must be no
outlier (|z| <= 3) against its window. The obvious implementation --
z-score over the window *including* the newest sample -- has a
quietly fatal property: with one extreme value among n samples, the
maximum possible z is bounded, and at n = 10 that bound is *exactly
3.0*. The test that looks right can never fire on a small window.
The honest form is leave-one-out: judge the newest against the window
that came *before* it, where z is unbounded and means what it says:

```
after the spike: stable-queue.depth: newest sample z = 4536.52 (|z| <= 3)
```

(A flat baseline is a special case with the same honesty: any jump
off a perfectly constant line is infinitely surprising, and judged
so.)

## The sentinel: alerts on transitions, not repetitions

An SLA judges when asked. `stzPerfSentinel` judges on a cadence and
turns verdict *transitions* into alerts -- edge-triggered, which is
the flap suppression that matters: a breach fires once when it
appears, once more only after it has genuinely cleared and broken
again. An invariant that stays broken does not page you four hundred
times:

```ring
oSent = StzPerfSentinel(oSla2, oMon2)
oSent.OnBreach(func aFinding { ? "  >> ALERT: " + aFinding[:message] })
oSent.OnClear(func cRule { ? "  >> recovered: " + cRule })
? "steady:  Check() fired " + oSent.Check() + " alert(s)"
gQ.Set(500)
? "spike:   Check() fired " + oSent.Check() + " alert(s)"
? "still:   Check() fired " + oSent.Check() + " alert(s) -- suppressed"
gQ.Set(10)
oSent.Check()
```
```
steady:  Check() fired 0 alert(s)
  >> ALERT: value-queue.depth-under-100: measured 500 (must be <= 100)
  >> ALERT: stable-queue.depth: newest sample z = 4536.52 (|z| <= 3)
spike:   Check() fired 2 alert(s)
still:   Check() fired 0 alert(s) -- suppressed
  >> recovered: value-queue.depth-under-100
  >> recovered: stable-queue.depth
alert log: 4 entries; bus count: 2
```

Every transition also fans out on the engine event bus
(`perf.breach` / `perf.clear`, process-global channels) -- so an
agent supervised *on that channel* wakes exactly when the SLA breaks,
and any part of the process can poll the counts without holding the
sentinel. The bounded `AlertLog()` keeps the story. And the sentinel
wears the same agent-host contract as the monitor (`Name_()` +
`Cycle()`): a server that hosts agents can judge its own SLA
continuously, in its own loop.

## Honest limits, and where this goes

Judgment reads the measured windows: percentile expectations judge
the retained window (the exact one, not the histogram's buckets), and
utilization judges the window mean. Alerts do not yet carry the trace
ids of the requests that tripped them -- that needs per-request trace
capture at the P3 seams, and it lands with the cluster-facing work.
The sentinel's transition state is Ring-side: one face drives
`Check()`, every face reads the shared metrics.

P5 turns the same measured numbers into *understanding* -- service
demand, the bottleneck, Little's-law self-validation, and the
narrated operational analysis that explains what the SLA's verdicts
mean. P6 closes the loop: what judgment finds, governed action may
fix.
