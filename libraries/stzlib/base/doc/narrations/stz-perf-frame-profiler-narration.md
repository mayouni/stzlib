# The Frame Profiler
### Where the time goes: a call tree with honest self-time, a real sampler thread, and flame-graph food

> Every code block below is real, and every output block is its actual
> output (the run lives in `base/test/perf/_profiler_narration_demo.ring`;
> the guard suite is `base/test/perf/frame_profiler_narrated.ring`, 19
> assertions). Performance system P10 --
> `doc/design/SOFTANZA_PERF_SYSTEM.md`.
>
> The name has history: the original `stzProfiler.ring` was a P0
> fossil -- a demo script sketching "a function aware of its own
> execution", retired to the archive. This is that idea grown up, on
> the engine.

## The question the senses could not answer

The senses (P1) say WHETHER the process computes; the metrics (P2)
say what each operation costs in aggregate. Neither says WHERE inside
your own code the time lives. That is a profiler's question, and P10
answers it two honest ways at once.

## Frames: the exact answer

Mark the work; the profiler keeps a call tree engine-side. Every
path knows its calls, its TOTAL time, and -- the number naive timers
get wrong -- its SELF time, total minus children:

```ring
oP = StzProfiler(64)
oP.Enter("import-orders")
	# ~15ms of its own work
	oP.Enter("parse")      # ~25ms
	oP.Leave()
	oP.Enter("validate")   # ~45ms
	oP.Leave()
oP.Leave()
oP.Show()
```
```
Profiler -- 3 path(s), depth now 0.
    import-orders;parse -- 1 call(s), total 25.08 ms, self 25.08 ms
    import-orders;validate -- 1 call(s), total 45.02 ms, self 45.02 ms
  import-orders -- 1 call(s), total 85.15 ms, self 15.05 ms
```

The parent's total (85ms) covers everything; its SELF (15ms) is what
it did with its own hands. `HotSpots(n)` ranks by self time -- the
list a fixing session should start from:

```
hottest self-time: import-orders;validate (45.02 ms)
```

The tree lives in the engine (fixed slabs, bounded paths folding
into a visible `_overflow`, depth capped at 32), so Ring copies
profile into one shared truth, and a frame pair costs about **2
microseconds** -- the guard prices it.

## Sampling: the statistical answer

Instrumentation is exact but pays per call; a loop bracketed a
million times measures the bracketing. So the profiler also runs a
REAL sampler: a background engine thread that photographs the active
frame path at a fixed cadence -- constant cost no matter how hot the
code, zero Ring involvement while it runs. This is the piece Ring
alone could never do (single-threaded code cannot interrupt itself);
the engine-side frame stack is exactly what makes it possible.

```ring
oS.StartSampling(2)          # a 2ms sampler thread
# 3 iterations of: handle (~40ms) then write (~10ms)
oS.StopSampling()
see oS.Folded()
```
```
folded stacks (paste into speedscope.app / flamegraph.pl):
serve;handle 41
serve;write 10
```

Read the weights against the workload: handle ran ~40ms per
iteration, write ~10ms -- and the samples split 41:10. The sampler
never saw the code, only the stack, and the statistics told the
truth anyway. That is the whole idea of sampling profilers,
demonstrated in four lines.

`Folded()` is the interop piece (the house rule, one more time): the
folded-stacks format is what `flamegraph.pl` and speedscope.app
ingest AS-IS -- `WriteFoldedTo(path)`, drag the file into
speedscope, get a flame graph. Sampled weights win when sampling
ran; self-ms otherwise.

## Honest limits

Frames are COOPERATIVE: the profiler sees what you bracket, not
unbracketed Ring code -- a VM-level sampler would only ever see the
interpreter's C internals, so bracketing is not a workaround, it is
the honest design for an interpreted host. The sampler's cadence
rides the process timer resolution (any reactor's `timeBeginPeriod`
makes 1-2ms real; without one, Windows rounds to ~15.6ms -- fewer
samples, same statistics). And the two accumulations answer
different questions: exact costs from instrumentation, time-share
truth from sampling -- the guard holds both against the same
workload.

With P10, the comparison table's "continuous profiling" row moves
from absent to *cooperative*: not pprof's see-everything stack
walker, but a call tree, self-time, a real sampler, and flame-graph
export -- for the code you chose to watch.
