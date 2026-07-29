# The Governed Loop
### The machine proposes, an effectful actor commits -- and the black box is already written

> Every code block below is real, and every output block is its actual
> output (the run lives in `base/test/perf/_governed_narration_demo.ring`;
> the guard suite is `base/test/perf/governed_loop_narrated.ring`, 31
> assertions, stable across repeated runs). Performance system P6, the
> final phase -- `doc/design/SOFTANZA_PERF_SYSTEM.md`.

## Optimize -- the verb that touches reality

The notebook's pipeline ends where the stakes begin: Monitor -> Alert
-> Analyze -> **Optimize**. The first three verbs only read; the
fourth scales fleets, drains workers, restarts processes. In this
library nothing crosses reality casually -- *expression is free,
admission is governed* -- and P6 is that doctrine applied to
performance tuning.

## The load signal, measured at last

`stzClusterSupervisor` always had the right shape: a pure `Decide()`
policy over fleet metrics and a demand signal. But the signal was
hand-fed -- `ReportLoad(:nlp, 0.9)` said whatever the caller believed.
Now the profile supplies it: `LoadRatio()` is X/Xmax -- how close the
measured workload sits to its measured CPU ceiling -- and
`FeedLoadFrom()` closes the loop the supervisor was built for:

```ring
oSup.Policy(:nlp, 1, 4).SetWaterMarks(0.25, 0.75)
oSup.FeedLoadFrom(:nlp, oP)              # MEASURED, not believed
aActs = oSup.Decide(aFleetMetrics)
```
```
measured load (X/Xmax) : 0.04
supervisor decides     : scaledown (measured load 0.04 < low-water 0.25)
```

The workload was genuinely light -- 4% of its CPU ceiling -- so the
policy drains a worker. Feed it a hot profile and the same pure
policy scales up. No component guessed: the profile measured, the
supervisor enforced.

## Observation prices itself

A perf system that cannot state its own cost is not
industry-strength. Every `Sample()` pass brackets itself on the
monotonic clock, and `SelfCost()` answers the question every operator
should ask of their monitoring:

```ring
aCost = oMon.SelfCost()
```
```
observation priced itself: 20 sample(s), 0.03 ms each
```

Thirty microseconds per full sampling pass -- memory, peak, CPU
utilization, system memory, engine-side storage included. That is
the number that justifies the design's central bet: monitoring cheap
enough to never turn off. The guard asserts it stays under 1 ms,
generously.

## The flight recorder -- issue 7, closed

The notebook's hardest problem: *anomalies that occur in production
but cannot be reproduced in a test environment*. The only monitoring
that helps is the monitoring that was already on -- so the moment the
sentinel fires a breach, it photographs the process: the senses as
they are at that instant, and every metric's current value. Nobody
has to remember to look while it is still happening:

```ring
gL.Set(900)                    # the anomaly lands
oSent.Check()                  # the sentinel fires -- and photographs
aBox = oSent.LastBlackBox()
```
```
breach: value-queue.depth-under-100
black box, written AT breach time:
  rss 164.87 MB ; peak 627.81 MB ; cpu 2546.88 ms
  metrics photographed: 7
```

The black box is bounded (newest 16) and costs nothing until a breach
happens. When the unreproducible bug lands at 3 a.m., the answer to
"what did the process look like?" was recorded at 3 a.m.

## The plan: the LLM proposes, the human commits

`stzPerfPlan` is optimization as a governed act. The action catalog
is closed (`:ScaleUp`, `:ScaleDown`, `:RestartDead` -- anything else
refuses with the catalog), proposals carry their rationale, and the
crossing is gated on the actor -- the same capability lattice that
governs every effectful act in the library. Watch the whole circle:
the breach's own finding becomes the plan's rationale, an
inference-only actor builds it, and only an effectful one lands it:

```ring
aF = oSla.CheckAgainst(oMon)
oPlan = StzPerfPlan("relieve-queue")
oPlan.Propose(:ScaleUp, "nlp", aF[1][:message])   # the finding IS the rationale

? "LLM may commit?   " + oPlan.MayCommit(oLlm)
? "human may commit? " + oPlan.MayCommit(oHuman)
? "LLM executes   -> " + oPlan.ExecuteOn(oFake, oLlm) + " committed (fleet calls: " + oFake.CallCount() + ")"
? "human executes -> " + oPlan.ExecuteOn(oFake, oHuman) + " committed (fleet calls: " + oFake.CallCount() + ")"
oPlan.Show()
```
```
LLM may commit?   0
human may commit? 1
LLM executes   -> 0 committed (fleet calls: 0)
human executes -> 1 committed (fleet calls: 1)

Perf plan relieve-queue -- 1 proposed action(s).
  1. scaleup 'nlp' -- value-queue.depth-under-100: measured 900 (must be <= 100)
Audit (2):
  #1 REFUSED scaleup 'nlp' by advisor -- actor is not effectful -- expression is free; admission is governed
  #1 COMMITTED scaleup 'nlp' by mansour -- value-queue.depth-under-100: measured 900 (must be <= 100)
```

Read the audit trail closely: the refusal and the commit are the SAME
action, judged twice under the same rule, and both judgments are
recorded. `MayCommit()` answers admissibility before any attempt
(preflight is a first-class question); the LLM's execution touched
nothing (the fleet double counted zero calls); and agentic
performance tuning becomes safe by construction -- the machine may
watch, analyze, and propose with full fluency, and may never tune.

The plan executed here against a rehearsal double -- any object
answering the same effectful verbs qualifies, the
service-virtualization pattern -- which is itself the point: the
crossing is provable without a fleet, and a real `stzAppCluster`
slots in unchanged.

## The system, complete

Seven guards, 257 assertions, every phase narrated with real output:

| Phase | The verb | What shipped |
|---|---|---|
| P0 | measure once | the honest stopwatch, OTel spans, the monotonic watch clock fix |
| P1 | sense | RSS/peak, system memory, CPU time, the engine-resident series |
| P2 | instrument | counters/gauges/timers (engine-state, copy-proof), the monitor, Prometheus + OTLP |
| P3 | attach | `Observe()`, `/metrics`, costs on every crossing in the library |
| P4 | judge | `stzSla` into the one CI gate, edge-triggered sentinel |
| P5 | understand | U/R/X/D, service demand, the bottleneck split, self-checking laws |
| P6 | act, governed | measured load -> supervisor, SelfCost, the black box, the governed plan |

The app that runs is the app that knows how it runs -- and what it
knows, only governed hands may change.
