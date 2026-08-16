# SOFTANZA CONCURRENT PLAN — the concurrency plane (CN0–CN5)

Status: **PLAN OF RECORD**, written 2026-08-16, before any code.
Supersedes the 2024 design proposal
`libraries/stzlib/max/wings/concurrent-wings/stz-concurrent-programming.md`.

That document is **claims, not code**. A repo-wide search shows that not
one construct it proposes (`stzWorkshop`, `stzWorker`, `Concurrently()`,
`RunConcurrently`, `stzSharedList`, `stzEventManager`, the task-type
classes…) exists anywhere in the library, and none of its code blocks
was ever run. It is kept as the source of intent; §0.5 dispositions
every claim it makes as ADOPT / RESHAPE / REFUSE. Nothing from it
enters the library except through that table.

Siblings, whose laws this plan inherits:
`base/cluster/SOFTANZA_DISTRIBUTION_PLAN.md` (D0–D6 + R8, complete),
`engine/SOFTANZA_COMPUTE_MODEL.md` (the compute doctrine, four widths),
`base/doc/design/TIER2_REACTOR_DIRECTION.md` (the reactor's charter and
refusals), `base/plugin/SOFTANZA_PLUGIN_PLAN.md` (PL0 pending — the
other 2024 revival, same method).

---

## HOW TO USE THIS DOCUMENT (session bootstrap — read this first)

This file is **sufficient on its own** for a dedicated session that has
never seen the concurrency work. There is deliberately **no companion
design document** — this repo has been bitten by duplicated rule lists
that drift. The "strategic proposal", the "design documents" and the
"implementation plan" the plane was asked for are §1, §2–§4 and §5–§6
of this one file.

### The mission, in one paragraph

In 2024 Softanza sketched a beautiful promise: concurrency as natural
language — `oList.Concurrently().Map(:Square)`, a Workshop of Workers,
no async/await pollution, no function coloring. It had to imagine the
machinery, so it imagined **threads** — and Ring has none. Two years
later the library owns three real concurrency substrates, all shipped
and guarded: **engine threads** for compute-dense work (multicore tier,
calibration-gated, elementwise killed by measurement), the **reactor**
for async I/O, timers and process spawns (libuv vendored inside
`stz_reactor.dll`, submit→ticket→await idiom, no callback ever crossing
into Ring), and **share-nothing OS processes** for parallel Ring code
(nodes, supervision, ~2 ms loopback round trips). What is missing is
exactly what the 2024 paper was actually about: the **vocabulary** — a
task, a ticket you can await, a workshop that fans work out and merges
results in order, and one fluent adverb on the collection faces. This
plane builds that vocabulary as a *router over the three substrates it
refuses to duplicate*. The simplicity is the product; the honesty
(measured gates, mandatory timeouts, counted refusals) is the method.

### Orientation — where everything is

| what | where |
|---|---|
| this plan | `libraries/stzlib/base/concurrent/SOFTANZA_CONCURRENT_PLAN.md` |
| legacy claims (read once, then only via §0.5) | `max/wings/concurrent-wings/stz-concurrent-programming.md` |
| the reactor face (async spawn/timers/TCP/HTTP, ticket idiom) | `base/reactive/stzReactor.ring` over `stz_reactor.dll` (libuv 1.52.1 vendored) |
| the reactive family (task callbacks, streams, timers, event bus) | `base/reactive/stzReactiveTask.ring` (`Then_`/`Catch_`), `stzReactiveStream.ring`, `stzEventBus.ring`, `stzReactorPool.ring` (N loops, TCP `FetchAll` only) |
| share-nothing processes | `base/cluster/stzNode.ring` (bounded inbox, `On(tag,f)`), `stzNodePlane.ring` (`Send`/`Ask`+timeout), `stzNodeSupervisor.ring`, `stzNodeApp.ring` (handlers as CODE STRINGS) |
| the HTTP fleet (do not duplicate) | `base/cluster/stzAppCluster.ring` (spawn+curl, breaker/failover/rate-limit/telemetry) |
| in-process admission (budgets, shed, drain — NOT parallelism) | `base/cluster/stzWorkerPool.ring`, `stzWorkerProfile.ring` |
| engine multicore (already parallel, don't ask) | `engine/src/matrix.zig`, `linalg.zig`, `stats.zig`, `cluster.zig`, `umap.zig` — five gated sites; `calib.zig` OVERRIDE>FILE>DEFAULT |
| the blocking process face | `base/system/stzProcess.ring` (`Spawn`/read-to-EOF-then-`Wait`/`Kill`) |
| the wire codec tasks ride | STZM (`engine/src/stzm.zig`, `StzEngineStzmPack/Unpack`) |
| monotonic clocks (the only clocks for durations) | `StzEngineWatchTimestamp*` (perf laws, CLAUDE.md) |
| guards (create) | `libraries/stzlib/base/test/concurrent/` |
| project rules | `CLAUDE.md` at the repo root — READ IT |

### Commands

```bash
cd libraries/stzlib/base/test/concurrent && ring concurrent_physics_narrated.ring
```

### The working discipline (non-negotiable)

1. **Measure before believing anything, including this plan.** CN0 is a
   measurement phase with kill criteria written before the numbers; §5
   records this plan's predictions so they can be scored.
2. **Guards are narrated and assert the MECHANISM**, and every positive
   has a negative sibling. This plane's canonical negative sibling is
   the **losing fan-out**: right beside every guard that proves a
   parallel win, a sibling fans out work below the gate and shows it
   LOSES — the number that keeps the gate honest.
3. **Mandatory-timeout law.** Every await in this plane takes a
   deadline; there is no infinite-wait entry point. `Ask` already
   refuses non-positive timeouts; the plane inherits that posture
   everywhere.
4. **No fourth substrate.** The plane routes to engine threads, the
   reactor, and processes. Any phase that starts building a scheduler,
   a thread API, or a second event loop is out of scope by definition.
5. **Results ride the house shapes**: ledger rows for outcomes,
   `stzRuleReport` for verdicts, `task.run.ms`/`task.runs`/`task.errors`
   joining the well-known perf subjects.
6. **Parallel sessions work this repo**: `git add <explicit paths>`,
   never `-A`.
7. **Push protocol**: `git push origin main` then
   `git push codeberg HEAD:refs/heads/main`; verify both with
   `git ls-remote <remote> main` against `git rev-parse main`. If
   codeberg fails, say PENDING and move on.
8. **Record outcomes** in this file (`## CN<n> RESULTS`) and in memory
   (`project_concurrent_plane.md`) when a phase ends.

### The first action

**CN0**, exactly as specified in §5: the task-physics spike.
Measurement only, no product code, kill criteria applied before the
numbers are interpreted.

---

## 0. THE SURVEY (taken 2026-08-16)

### 0.1 What the 2024 document actually is

`stz-concurrent-programming.md` is a design proposal, not a prototype —
there was never even a hand-written test beside it. It proposes a
thread-shaped world: `stzWorker` as "lightweight thread wrapper",
`stzSharedList` that two workers mutate "simultaneously", pluggable
`UseLibuv()`/`UseQt()` backends, and automatic optimizers ("adaptive
mode", "intelligent task scheduling"). None of it exists; more
importantly, none of it *can* exist as written: Ring's VM is
single-threaded, and the repo carries that law in two independent
places (`SOFTANZA_COMPUTE_MODEL.md`: "the process IS the concurrency
unit"; `stzAppCluster.ring` header: "CPU-bound parallelism must cross
PROCESSES"). **Every thread in the system today lives inside a Zig DLL
and is invisible to Ring** — a repo-wide search finds zero Ring-level
threads, zero live libuv Ring bindings, zero Qt.

What the paper got *right* — and this is why it is worth reviving — is
the user-facing contract: one word (`Concurrently`), no new syntax, no
function coloring, results collected as values, errors as data not
raises. That contract survives intact. The machinery under it is
replaced wholesale by what the library actually built.

**Verdict: the right surface over the wrong machine.** The plane keeps
the surface and routes it to the machines that exist.

### 0.2 What the library gained since (build on it, do not rewrite it)

| 2024 hand-wave | shipped owner (2026) |
|---|---|
| "workers perform tasks" | `stzNode` share-nothing OS processes: bounded inboxes with counted overflow, `On(tag,handler)`, ~2 ms loopback RTT, 13k msg/s, serialization 2% of end-to-end (D0 measured) |
| "workshops manage workers" | `stzNodeSupervisor` (restart strategies, budgets, heartbeats that catch the WEDGED node), `stzAppCluster` (spawn, health, breaker, failover, drain), `stzClusterSupervisor` autoscale |
| "results collected when complete" | the reactor's ticket idiom: `Submit* → id → Poll/Await(timeout)`; `JobState(id) = -2` as the only trustworthy proof of drain |
| "automatic load balancing" | round-robin routing + per-facet budgets + admission control (`stzWorkerPool`), all counted and observable |
| "map-reduce made simple" | the multicore tier: matmul/LU/reductions/topK/kNN parallel behind measured calibration gates (`stz_calibration.txt`, OVERRIDE>FILE>DEFAULT) |
| "event-driven concurrency" | the engine event bus (`stzEventBus`) + `stzAgentHost.SuperviseOnEvent` (tick-per-event, generation-guarded) + `stzFolderWatcher` for files |
| "error handling with result objects" | house ledger rows + `stzReactiveTask.Succeeded()/HasFailed()`; refusals counted, never silent |
| "try-again mechanisms" | `stzRetryBudget` (engine token bucket), supervisor restart budgets with escalation, retry-with-failover in the fleet |
| "pipeline with dependencies" | `stzComputePipeline` (staged, per-stage budgets) + `stzWorkflow.ParallelizeSteps` / `stzGraph.ParallelizableBranches` (the dependency analysis, minus execution) |

### 0.3 What is genuinely missing (this is the work)

- **The task**: no unit that says "this Ring work, with these args,
  runnable elsewhere". (The node plane has `[tag, args]` messages; the
  fleet has HTTP paths; the pool has in-process function refs — three
  vocabularies, none of them *the* task.)
- **The ticket algebra**: `AwaitAll` / `AwaitAny` over heterogeneous
  submitted work. (`stzReactiveTask` chains one callback; nothing
  composes many.)
- **The workshop**: a fleet of *task-running* processes you can
  `Submit` arbitrary declared work to — the fleet that exists speaks a
  fixed four-endpoint HTTP contract, not tasks.
- **The fluent adverb**: `Concurrently()` on the collection faces —
  zero hits in the whole repo today.
- **The reconciliation**: two spawn surfaces (`stzReactor.SubmitSpawn`
  async vs `stzProcess.Spawn` blocking) coexist with no written rule
  about which one a given caller should ride.
- **The break-even number**: nobody has measured where process fan-out
  of Ring tasks starts to WIN — the number the whole fluent surface
  must be gated by.

### 0.4 The cost this implies

**Zero new DLLs** (89 first-party DLLs exist; the reactor, the STZM
codec, the pool, and the calibrated numeric tier already carry every
engine capability this plane needs). The plane is ~5 Ring files under
`base/concurrent/` plus one generated task-runner script and guards.
The only engine work conceivable is a small addition to an *existing*
DLL if CN0 finds a seam gap — none is predicted.

### 0.5 DISPOSITION OF THE LEGACY CLAIMS

| # | 2024 claim | disposition |
|---|---|---|
| 1 | the Workshop metaphor (workers, workshops, tasks, results) | **ADOPT** — the vocabulary maps 1:1 onto shipped machinery: worker = OS process, workshop = supervised fleet, task = declared work, result = ledgered value (§2.2) |
| 2 | one unified word ("concurrent"), system decides how it runs | **ADOPT the word, RESHAPE the magic** — routing is by *declared* work nature + *measured* gates (the calibration discipline), never hidden guessing (§2.1) |
| 3 | per-operation suffix methods (`DoubleEachConcurrently()`) | **REFUSE** — a combinatorial method zoo, same refusal as the plugin plane's suffix zoo; one adverb, not N suffixes |
| 4 | the fluent `Concurrently()` adapter | **ADOPT** — the plane's public face on collections (§2.6) |
| 5 | `stzWorkshop` (`SetMaxWorkers`/`AddTask`/`WaitForAllTasks`) | **ADOPT** reshaped — `Submit → tickets → AwaitAll(timeout)`; worker count defaults from cores; every wait deadlined (§2.4) |
| 6 | `stzWorker` as "lightweight thread wrapper" | **RESHAPE** — a worker is an OS **process** (generated `stzNode` task-runner); "lightweight thread" is fiction in Ring (§2.1) |
| 7 | `stzSharedTool`/`stzSharedList` (concurrent mutation) | **REFUSE** — share-nothing is the shipped law; results merge host-side; state that must be shared lives in ONE node reached by messages |
| 8 | `stzEvent`/`stzEventManager` (`WhenEventOccurs`/`SendEvent`) | **RESHAPE** — the engine event bus + `SuperviseOnEvent` already are this; no parallel manager class (§2.8) |
| 9 | `WhenFileChanges`/`WhenNetworkRequestComes` | **ADOPT via existing owners** — fswatch and the appserver; the plane only wires their events to task submission |
| 10 | `stzPipeline` (sequential staged tasks) | **ADOPT** — `stzComputePipeline` exists; the plane feeds it tasks, adds nothing beside it |
| 11 | `stzConcurrentPipeline` auto-optimizing dependencies | **RESHAPE** — dependency analysis is the graph face's job (`ParallelizableBranches`); the plane executes its waves; no "intelligent scheduler" claims (§2.9) |
| 12 | task types (`stzReadOnlyTask`/`stzCalculationTask`/`stzUpdateTask`) auto-serialized | **RESHAPE** — a class taxonomy becomes a declared EFFECT (`:Pure`/`:ReadOnly`/`:Effectful`); effectful tasks serialize per resource, pure tasks fan out and may retry (§2.7) |
| 13 | `RunConcurrently(f)` fire-and-forget + blocking `result.Get()` | **ADOPT** — submit→ticket→await is already house law; fire-and-forget = `Send` semantics, ticketed = `Ask` semantics; `Get()` becomes `Await(nTimeoutMs)` (mandatory deadline) |
| 14 | `ProcessConcurrently(aItems, f)` batch → results | **ADOPT** — the plane's centerpiece: chunked fan-out, results in input order (§2.5) |
| 15 | fluent concurrent `Map`/`Reduce` | **RESHAPE, two honest routes** — named engine ops (`:Sum`, matmul…) are ALREADY parallel behind calib gates, no adverb needed; Ring-function maps fan out across processes only above the CN0 break-even (§2.5) |
| 16 | fluent concurrent `Filter` | same as #15 |
| 17 | `stzString.ProcessWordsConcurrently` | **RESHAPE** — segmentation is engine-side (UAX#29); fan-out applies only when per-item work clears the gate |
| 18 | `stzTable` concurrent rows/columns/GroupBy | **RESHAPE** — engine stats ops first; process fan-out for genuinely heavy per-row Ring work only |
| 19 | "automatic load balancing", "optimal number of workers" | **RESHAPE** — round-robin + budgets + calibration file; "optimal" is a *measured, stored* number, never an adjective (§2.3) |
| 20 | streaming mode (`:Streaming = TRUE`) for huge files | **RESHAPE** — bounded submission waves (the inbox bound IS the streaming window); no separate mode flag |
| 21 | adaptive mode (auto-scaling workers) | **REFUSE for v1** — autoscale exists where it earns its keep (the HTTP fleet's supervisor); task workshops size from cores + calib; unmeasured adaptivity is the "insight generation" of concurrency |
| 22 | `TryProcessEach` + `result.Succeeded()`/`GetProblem()` | **ADOPT** — fault-tolerant variant; outcomes are ledger rows `[task, ok, result-or-error, ms]`, errors are data |
| 23 | retry (`SetTryAgainCount`/`SetWaitBetweenTries`) | **ADOPT slim** — via the existing `stzRetryBudget` + supervisor restart budgets; retry is gated by declared effect (#12): pure retries, effectful never auto-retries (at-most-once law) |
| 24 | `UseLibuv()` backend | **REFUSE as a user knob** — libuv is already vendored *inside* `stz_reactor.dll`; backends are engine substance, not API |
| 25 | `UseQt()` backend | **REFUSE** — no Qt anywhere in base; M-DEP forbids external Ring extensions |
| 26 | `UseCustomBackend()` | **REFUSE** — a backend seam is an invitation to a second event loop; the distribution plane refused vendored brokers on the same law |
| 27 | backwards compatible, incremental adoption | **ADOPT** — the adverb is purely additive; nothing sequential changes meaning |

---

## 1. STRATEGIC PROPOSAL

### 1.1 The thesis

**Concurrency in Softanza is a routing vocabulary, not a machine.**
The library already owns three concurrency substrates, each with its
own measured admission rule:

1. **Engine threads** — compute-dense work on values (matmul, LU, big
   reductions, kNN, topK). Parallel *transparently*, behind per-op
   calibration gates; elementwise refused by the memory wall. The user
   never asks for this; it happens.
2. **The reactor** — overlap in *time*: async spawns, timers, TCP,
   HTTP, TLS. One loop thread, submit→ticket→await, no callbacks into
   Ring, every await deadlined.
3. **Processes** — parallel *Ring code*: share-nothing nodes exchanging
   messages, supervised, killable, location-transparent.

The 2024 paper's real insight was that the programmer should think in
ONE concept — "concurrent" — and the system should place the work. The
plane delivers exactly that, but placement is **declared + measured**,
never guessed: the nature of the work (a named engine op / an I/O verb
/ a Ring function) picks the substrate, and calibration numbers decide
whether fanning out pays at this size on this machine. Where 2024
promised adaptive magic, 2026 ships the calibration file.

### 1.2 The physics, stated once (the plane's first law)

Ring's VM is single-threaded. Therefore, in writing:

- A Ring function **never runs on a thread**. "Concurrent Ring code"
  means *processes*, full stop. The plane generates and supervises
  those processes so the user never sees them.
- A Ring **closure never crosses a process boundary**. Tasks travel as
  *code strings* or *declared names* + data (the `stzNodeApp`
  precedent: code-as-data crosses, closures cannot).
- Crossing to a worker costs real time (~2 ms loopback RTT floor,
  measured at D0). **Fan-out pays only above a break-even task size**,
  which CN0 measures and the gates enforce. Below it, the honest
  answer is sequential execution — counted and observable, never
  silent.

This is the boundary law's **fourth witness**: PCIe ate GPU
elementwise, the memory wall ate CPU streaming threads, the wire ate
chatty messaging — and the process seam eats fine-grained task
fan-out. Same shape, same defense: measure, gate, refuse below the
line.

### 1.3 Why now, and why it is different from two years ago

In 2024 every layer had to be imagined, so the paper imagined the
wrong primitive (threads) and hand-waved the hard parts ("automatic",
"intelligent", "adaptive"). In 2026 the hard parts are shipped and
guarded — spawning, supervising, messaging, bounding, retrying,
observing, calibrating — and the plane reduces to its actual novelty:
**the task, the ticket algebra, the workshop, and the adverb**. The
risk profile inverted, exactly as it did for the plugin plane: what
was ~90% unbuilt infrastructure is now ~90% composition. The one
genuinely unknown quantity is the **task-physics of the process seam**
(worker boot cost, warm task RTT, break-even size) — which is exactly
what CN0 measures before any product code is written.

### 1.4 What it unlocks

- **The missing everyday surface**: batch work (files, URLs, rows,
  documents) fanned out in one line, with results in order and errors
  as data — the thing every scripting user actually wants from
  "concurrency".
- **A task tier for the family**: RingServ background jobs, RingFlex
  parallel step execution, MicroRing device sweeps — via the CN5
  kernel (§3), the same two-audience play as the plugin plane.
- **A substrate the plugin plane's `:Process` tier can ride** — a
  governed foreign capability is just a task with a trust posture.
- **Workflow execution**: `stzWorkflow`'s dependency analysis gains an
  executor (waves of tasks), turning a model into a runtime.

### 1.5 What this plane is not

Not a thread API, not a scheduler, not a second event loop, not a
distributed-computing framework (the node plane already is one), not a
job-queue product with persistence (tasks live and die with the
workshop), and not an autoscaling system (the cluster supervisor owns
that, for the citizens that need it).

### 1.6 The paradigm fit: Scope-Oriented Programming, instance #4

`base/doc/design/SCOPE_ORIENTED_PROGRAMMING.md` lists concurrency
among its candidate fields; this plane is its fourth instance, and the
plan already enforces the five moves — stated here so the two
documents cite each other instead of drifting:

- **M1 (name the hidden frame)**: the *execution substrate* — where
  work runs and what must cross to get there. `oList.Map(f)` without
  the frame is unreadable in exactly SOP's sense. The 2024 document's
  deepest flaw was anti-SOP: it hid the frame on purpose ("the system
  handles it automatically").
- **M2 (small closed set — and it is TWO frames, split)**: the
  substrate frame `{engine width, reactor, process fleet}` and the
  effect frame `{:Pure, :ReadOnly, :Effectful}` (what the work
  touches). The SOP doc's candidate row guessed thread vocabulary
  (`main-thread`, `actor`, `Send/Sync`); the built field corrects it —
  Ring has no threads, so no scope may name one.
- **M3 (scope at the call site)**: `Concurrently()` is the
  scope-opener in the receiver chain; `oWork.Submit(...)` names the
  fleet scope in the receiver. The refusals are M3 violations by
  name: the per-op suffix zoo smears the frame over N methods;
  `SetAdaptiveMode(TRUE)` is the set-a-flag-earlier antipattern.
- **M4 (the library reasons with the scope)**: the router — and what
  this instance contributes: the scope reasons with *measurements*.
  It consults `task.fanout_min_ms`, routes engine ops to the width
  that is already parallel, serializes effectful tasks, gates retry
  by effect, and `RanSequentially()` is the scope reporting its own
  decision.
- **M5 (capability contract)**: live — a closure or live object
  CANNOT cross the seam (down-constrain, refused with the fix in the
  error); the family kernel carries the same three words with a
  smaller declared envelope (batch-only — the placement instance's
  honesty about weaker hosts); and CN0's kill criteria shrink the
  envelope by measurement instead of letting the API lie.

One ruling from the SOP doc survives untouched and is worth restating:
the frame is **dissolved or surfaced per layer**. Reaxis dissolves it
(streams on one thread, deliberately); the engine widths dissolve it
(multicore is transparent); this plane surfaces it at the task layer,
where placement is a decision the programmer must own. Same frame,
three layers, three correct rulings.

---

## 2. DESIGN — the settled decisions

### 2.1 D1: three substrates, one router, no fourth

`Concurrently()` and the workshop never *implement* concurrency; they
**route**:

- work naming an **engine op** → the op itself (already gated
  multicore; the adverb adds nothing and says so — a rule-report
  notice, not an error);
- work that is **I/O-shaped** (http/spawn/timer verbs) → reactor
  tickets on the one loop;
- work that is a **Ring function over items** → chunked fan-out to
  workshop worker processes, iff above the calibrated break-even;
  otherwise sequential, with `RanSequentially()` observable and
  counted.

Anything that would require a new substrate (Ring threads, a
work-stealing scheduler, a second loop) is refused by discipline #4.
TIER2's written refusal of a work-stealing scheduler stands.

### 2.2 D2: the vocabulary (the Workshop metaphor, made honest)

| word | is | machinery |
|---|---|---|
| **Task** | declared work + args: `[ :name, code-or-declared-fn, aArgs, :Effect ]` | crosses as STZM data; never a closure |
| **Ticket** | the claim on a result | the reactor/job-id idiom, generalized |
| **Worker** | an OS process running the generated task-runner | `stzNode` in task mode: bounded inbox, `stz.task` handler, counters |
| **Workshop** | a supervised fleet of workers + the ledger | `stzWorkshop`: Start/WaitReady/Submit/AwaitAll/Drain/Stop |
| **Result** | a ledger row `[task, ok, value-or-error, ms]` | monotonic-clocked; errors are data |

Three public verbs on the workshop — `Submit(task)` → ticket,
`AwaitAll(aTickets, nTimeoutMs)` / `AwaitAny(...)`, and
`Process(aItems, task, nTimeoutMs)` (submit+await+order in one call).
Fire-and-forget is `Post(task)` (Send semantics, no ticket). No suffix
zoo; options ride option lists.

### 2.3 D3: sizing and gating are calibration, not adjectives

Worker count defaults to physical cores (the multicore tier's
knowledge); the fan-out break-even lives in `stz_calibration.txt` as
`task.fanout_min_ms` (namespace `task.*`, joining `cpu.*`/`net.*` —
one calibration store, per the compute model's per-DLL-statics law).
`StzNetCalibrate`'s sibling `StzTaskCalibrate()` (CN2) measures this
machine's numbers the way C1 measured the wire. Chunking default: one
chunk per worker; an explicit `:ChunkSize` option overrides.

### 2.4 D4: tickets generalize the house idiom, deadlines mandatory

A ticket wraps `[substrate, id]`. `Await(nTimeoutMs)` — required,
positive, refused otherwise (the `Ask` posture). `AwaitAll` returns
results **in submission order** with per-task outcomes; a timeout
yields the completed prefix + explicit `:TimedOut` rows, never a hang.
`JobState = -2` (drained) remains the only trusted completion proof
for reactor-backed tickets. There is no `Race` that abandons losers
silently: `AwaitAny` reports what it left pending, and pending tasks
on effectful work are a counted rule-report finding.

### 2.5 D5: fan-out is chunked, ordered, and honest about losing

`Process(aItems, task)` splits items into per-worker chunks, ships
each chunk as ONE task message (amortizing the ~2 ms seam), merges
results back into input order. Below the calibrated break-even the
same call runs sequentially — same results, `RanSequentially()` = 1,
shown in the ledger. The guard suite keeps a **losing fan-out** beside
every winning one (discipline #2): the day the seam gets cheaper or
dearer, the calibration moves and the guards still tell the truth.

### 2.6 D6: `Concurrently()` lands once, on `stzObject`

One adverb on the base class, returning a thin adapter bound to the
default workshop (default-instance-behind-sugar, the domain law).
`oList.Concurrently().Map(task)`, `.Filter(task)`, `.Do(task)`;
`stzTable` gains row-chunk mapping through the same adapter. The
adapter owns NOTHING: no state, no bookkeeping — it shapes the call
and delegates. Global sugar: `RunConcurrently(task)` → ticket;
`ProcessConcurrently(aItems, task)` → results. (Per the Q convention:
these return DATA or tickets; `ConcurrentlyQ()` variants are not
minted until a chaining need is demonstrated.)

### 2.7 D7: effects are declared and gate retry (the honest task-type)

A task declares `:Pure` (no external effect — may fan out freely, may
be retried on worker death under the retry budget), `:ReadOnly`
(reads shared resources — fans out, never retried blindly after a
partial read? it is: retryable, since it changed nothing), or
`:Effectful` (writes something — **serialized per declared resource,
never auto-retried**; at-most-once, the distribution plane's law;
opt-in idempotency key for at-least-once, checked by the receiver).
Default is `:Effectful` — the safe assumption, loudly stated. The 2024
read/calc/update class taxonomy collapses into this one declaration.

### 2.8 D8: events compose, they are not re-invented

"Event-driven concurrency" = existing event sources feeding task
submission: the engine event bus (`SuperviseOnEvent` — tick-per-event,
generation-guarded), `stzFolderWatcher` for files, the appserver for
requests. The workshop exposes `Name_()` + `Cycle()` so it is hostable
on any `stzAgentHost` (its `Cycle` drains due results, feeds retry
budgets, reports health). No `stzEventManager` class is built.

### 2.9 D9: dependency waves ride the graph face

For task graphs, `stzWorkflow`/`stzGraph` already compute
`ParallelizableBranches`. CN4 adds the executor only: each wave =
one `Process()` call; a failed prerequisite marks its dependents
`:Skipped` in the ledger (never silently absent). No "intelligent
scheduling" vocabulary — the graph face decides shape, the workshop
executes waves, both auditable.

### 2.10 D10: the two spawn surfaces, reconciled in writing

`stzReactor.SubmitSpawn` (async, loop-owned, killable, ticketed) is
**the plane's only spawn path**. `stzProcess.Spawn` remains the
*interactive/blocking* face for callers that want a child's pipes
synchronously (its read-to-EOF-then-Wait contract). The rule, now
written: **if you await more than one thing, you are in reactor
territory.** The plane never calls `stzProcess.Spawn`.

### 2.11 D11: the class list

| class | file | role |
|---|---|---|
| `stzTask` | `base/concurrent/stzTask.ring` | the unit: name, payload (code string or declared fn), args, effect, options |
| `stzTaskTicket` | same file | substrate-tagged claim; `Await/IsDone/Result` |
| `stzWorkshop` | `base/concurrent/stzWorkshop.ring` | fleet lifecycle, Submit/Post/AwaitAll/AwaitAny/Process, ledger, instruments, `Name_()`/`Cycle()`, `UsesTasks(cFile)` (the declared task library workers load at boot) |
| task-runner (generated) | written by `Start()` | an `stzNode` in task mode: `On("stz.task", …)`, executes payload, replies result row |
| `stzConcurrentProxy` | `base/concurrent/stzConcurrently.ring` | the stateless adverb adapter (§2.6) |
| `ringtask.ring` | `base/concurrent/kernel/` | CN5: the vendorable pure-Ring batch kernel (§3) |

Domain folder `base/concurrent/`, loaded from `base/stzBase.ring`
beside reactive/cluster. The wings folder keeps nothing: this plane is
base-level; `max/wings/concurrent-wings/` holds only the superseded
intent document.

---

## 3. THE FAMILY KERNEL (CN5 — the vendorable file, honestly scoped)

The plugin plane's kernel could be pure Ring because `ring_state_*`
are builtins. Concurrency has no such luck: the reactor is an stzlib
DLL, and pure Ring has no event loop. The family offer is therefore
**smaller and honest**: `ringtask.ring` — batch fan-out ONLY, pure
Ring + Ring stdlib:

- spawn N bare `ring` child processes (`system()` with the platform's
  background idiom), each running a generated script over its chunk;
- results cross as **files** in a run directory; the parent polls
  with a deadline (labeled approximate, `clock()`-based);
- the API is the same three words (`Submit`/`AwaitAll`/`Process`) so
  code written against the kernel reads like code written against the
  workshop; the workshop is the *upgrade*, not a fork (the
  kernel-approximates/face-upgrades pattern from the plugin plan).

No async claims, no messaging claims, no supervision claims — those
are Softanza-tier. RingServ (background jobs) is the natural first
adopter to propose; RingScript feasibility (processes under WASM) is
flagged **UNKNOWN, not assumed**. The CN5 vendorability guard runs the
kernel under bare `ring` with stzlib absent from the path.

---

## 4. THE RING SURFACE (illustrative — not yet run)

```ring
# The workshop, explicit form
oWork = new stzWorkshop(4)                 # 4 worker processes (default: cores)
oWork.UsesTasks("mytasks.ring")            # declared task library, loaded by workers at boot
oWork.Start()                              # spawn + WaitReady

t1 = oWork.Submit([ :resize, :args = ["img1.jpg"] ])
t2 = oWork.Submit([ :resize, :args = ["img2.jpg"] ])
aRes = oWork.AwaitAll([t1, t2], 30_000)    # deadline mandatory
#--> [ [ "resize", 1, "img1_small.jpg", 412.7 ], [ "resize", 1, "img2_small.jpg", 398.1 ] ]

# The one-call batch — the plane's centerpiece
aOut = oWork.Process(aFiles, :ExtractKeywords, 60_000)   # chunked, ordered, ledgered

# The adverb (default workshop behind the sugar)
o1 = new stzList(aUrls)
aPages = o1.Concurrently().Map([ :Fetch, :Effect = :ReadOnly ])

# Honesty below the gate
aSmall = new stzList(1:100)
aSq = aSmall.Concurrently().Map(:Square)   # engine op → already parallel where it pays;
? oWork.RanSequentially()                  # tiny Ring work → ran sequential, SAYS so

# Errors are data
aRes = oWork.Process(aFiles, :MayFail, 30_000)
for aRow in aRes
    if aRow[2] = 0 { ? "problem: " + aRow[3] }
ok

# Fire-and-forget + events
oWork.Post([ :backup, :args = ["daily.sql"] ])
oHost.SuperviseOnEvent(oWork, "files.changed")   # a file event Cycles the workshop
```

---

## 5. IMPLEMENTATION PLAN — phases and kill criteria

Predictions are recorded here, before any measurement, so they can be
scored the way the GPU, graphics, and distribution plans were.

### CN0 — task-physics spike (measurement only, no product code)

Throwaway spikes over the EXISTING machinery (a hand-written stzNode
task-runner; no product classes):

1. **Worker boot**: spawn → STZM link up → first task answered. Two
   arms: a *lean* runner (loads only what tasks need) vs a *full*
   stzBase runner. This decides whether ephemeral workshops are viable
   or fleets must be resident.
2. **Warm task RTT**: trivial task round trip on a resident worker,
   1000 reps, band from measurement.
3. **Break-even**: `Process()`-shaped fan-out of synthetic tasks at
   0.1 / 1 / 5 / 10 / 50 ms per item across 4 workers vs sequential —
   find the crossover; this number seeds `task.fanout_min_ms`.
4. **Payload fidelity**: nested lists + Unicode + numbers across the
   task seam (STZM pack/unpack already measured at 2% of end-to-end;
   confirm at task shapes).
5. **Throughput ceiling**: max trivial tasks/s on 4 workers (13k msg/s
   is the single-link floor from D0).
6. **Chunk amortization**: 10,000 tiny items as 4 chunk-tasks vs
   10,000 task messages — the number that justifies §2.5.

**Kill criteria (written before the numbers):**
- Warm task RTT > 5 ms → the per-item path is refused at every size;
  the adverb becomes chunk-only (it already prefers chunks; this
  removes the option).
- Lean worker boot > 5 s → ephemeral workshops refused; workshops are
  resident fleets you `Start()` once (the plane survives, the surface
  notes it).
- STZM cannot carry task payloads faithfully → tasks restrict to
  declared-file names + flat args (the plane survives smaller; code
  strings still cross as strings).

**Predictions:** lean boot 0.3–1.5 s on Windows (process + partial
load); full-stzBase boot 1–3 s; warm RTT 1.0–2.5 ms (D0's 2 ms ±
dispatch's 0.09 ms); break-even near 3–10 ms per item at 4 workers;
chunking beats per-item messaging by ≥ 50× on tiny items; fidelity
passes.

### CN1 — tasks and tickets over the reactor (one process, no fleet)

`stzTask`, `stzTaskTicket`, `AwaitAll`/`AwaitAny` over heterogeneous
reactor tickets (spawn + http + timer in one await), the ledger, the
mandatory-deadline refusals, the D10 spawn-surface rule enforced (the
plane's code never touches `stzProcess.Spawn`). Guard:
`concurrent_tickets_narrated.ring` — includes the negative siblings:
zero/negative timeout refused; a timeout returns completed prefix +
`:TimedOut` rows (proven by content, not absence).

### CN2 — the workshop (the fleet, for real)

Generated task-runner (stzNode task mode), `stzWorkshop`
Start/WaitReady/Submit/Post/Process/Drain/Stop, bounded worker
inboxes with counted overflow, supervision (restart budget; a killed
worker's :Pure tasks fail over, :Effectful tasks report `:Dead` — the
effect law live), instruments `task.run.ms`/`task.runs`/`task.errors`,
`StzTaskCalibrate()` writing `task.*` seeds. Guard proves the
capability the 2024 paper could only promise: **kill a worker
mid-batch and watch the batch complete** (pure tasks) — beside the
effectful sibling that refuses to retry and says why.

### CN3 — the adverb on the faces

`Concurrently()` on `stzObject` + the proxy; list/table mapping;
gate integration (below break-even → sequential + `RanSequentially()`
counted); engine-op detection (adverb on an engine-owned op emits the
rule-report notice "already parallel where measured to pay").
Guard siblings: the winning fan-out beside the losing fan-out
(discipline #2), and parallel-vs-sequential **content equality** on
multibyte payloads.

### CN4 — composition: events, waves, retries

`SuperviseOnEvent` feeding submission; workflow waves (§2.9) with
`:Skipped` propagation; retry budgets wired to effects; streaming =
bounded waves over a file/folder source. Guard includes the
prerequisite-failure wave (dependents `:Skipped`, proven by ledger
content) and a retry-budget exhaustion that escalates instead of
looping.

### CN5 — the family kernel + vendorability

`ringtask.ring` per §3; the vendorability guard (bare `ring`, stzlib
off the path, same three words, batch semantics only); a written
capability table kernel-vs-workshop in the kernel header. Docs +
narration for the plane.

### Sequencing

CN0 → CN1 → CN2 → CN3; CN4 and CN5 after CN2 in either order (CN3
needs CN2's fleet; CN4 needs CN2's ledger). Each phase ends with its
guard green, results appended to this file, memory updated, both
remotes pushed.

---

## 6. VERIFICATION METHOD

The promises-harness lesson applies in full: **no hand-written output
is evidence** — the 2024 document is 100% hand-written output, which
is why it is superseded. Mechanism, not surface:

- **Parallelism**: assert by *content equality with sequential* plus a
  measured wall-clock band — never by "it returned".
- **Ordering**: shuffled completion (workers given deliberately uneven
  chunks) must still merge to input order.
- **Fan-out honesty**: every winning guard has a losing sibling below
  the gate; the gate value comes from calibration, not the plan.
- **Failover**: kill a worker mid-batch; assert batch completion AND
  the ledger's restart row (pure), refusal row (effectful).
- **Deadlines**: a hung task yields `:TimedOut` rows at the deadline
  ± band; the host is proven alive after (liveness assert).
- **Timing**: monotonic watch clocks only; BAND from measurement
  (timing-assertions reference); Windows sleeps quantize ~15.6 ms —
  wait on reactor polls, never sleep loops.

Guards live in `base/test/concurrent/`, narrated style, run from
inside their directory per the sensitive-test rules.

---

## 7. RISKS AND STANDING REFUSALS

**Risks, named now:**

1. **Worker boot cost** may make workshops feel heavy on Windows
   (process spawn + library load). CN0 measures both arms; the
   resident-fleet fallback is designed in, not improvised.
2. **Payload restriction**: only data crosses the seam — a task
   touching a live object (an open stzTable, a GUI face) cannot fan
   out. The surface must say this at refusal time, in the error, with
   the fix (ship data, not objects).
3. **The adverb invites tiny work.** The gate + counted sequential
   fallback is the defense; the losing-fan-out guards keep it honest
   over time.
4. **Family adoption is a bet** (plugin plan's caveat verbatim): a
   vendorable kernel does not vendor itself. RingServ is the natural
   first proposal.

**Refused, in writing (any phase that starts needing one of these is
out of scope by definition):**

- Ring-level threads, in any costume (§1.2 — fiction).
- Shared mutable structures across workers (§0.5 #7 — share-nothing).
- User-selectable backends (`UseLibuv`/`UseQt`/custom — §0.5 #24–26).
- A second event loop or vendored broker (distribution plane's law).
- A work-stealing scheduler (TIER2's written refusal stands).
- Unbounded queues or un-deadlined waits (discipline #3).
- Exactly-once delivery; auto-retry of effectful tasks (§2.7).
- Serializing closures or live objects across the seam (§1.2).
- Per-operation `*Concurrently()` method suffixes (§0.5 #3).
- Unmeasured "adaptive"/"intelligent" behavior (§0.5 #21, #11).
- Hot code loading of task libraries (delivery plane's refusal
  stands; a changed task file means restarting workers — the workshop
  makes that one call, `Reload()`, which is drain+respawn, not magic).

---

## 8. INTERFACES WITH THE OTHER PLANES

- **Distribution/cluster**: the workshop is a *consumer* of nodes,
  STZM, and supervision — a sibling citizen beside `stzAppCluster`
  (which keeps the HTTP fleet) — and adds no topology of its own.
  Its refusals (exactly-once, consensus, brokers) are inherited.
- **Compute model**: this plane is the *fifth notch on the routing
  dial, not a fifth width* — it decides which of the four widths a
  piece of work reaches. `SOFTANZA_COMPUTE_MODEL.md` gains a short
  pointer section when CN2 lands (after the fact, per that doc's own
  custom).
- **Plugin plane**: a `:Process` plugin call is a task with a trust
  posture; PL4 may ride the workshop instead of raw reactor spawns if
  CN2 lands first — a shared substrate, not a dependency either way.
- **Perf**: `task.*` instruments join the well-known subjects; the
  ledger rides monotonic clocks; `task.fanout_min_ms` joins the one
  calibration store.
- **Agentic**: the workshop is hostable (`Name_()`/`Cycle()`);
  event-driven submission via `SuperviseOnEvent`.
- **Graph/workflow**: waves execute `ParallelizableBranches` (§2.9).
- **The family**: `ringtask.ring` is the offer (§3); RingScript/WASM
  feasibility flagged UNKNOWN, not assumed.
- **Ringine**: independent confirmation of the seam law — its measured
  asymmetric boundary (delivery dear, return cheap; ration DECISIONS
  not crossings) is this plane's §2.5 in another costume.

---

## 9. LEGACY DOCUMENT DISPOSITION

- `max/wings/concurrent-wings/stz-concurrent-programming.md` — header
  a SUPERSEDED notice pointing here; the file stays as the intent
  record. Its user-facing contract (the adverb, the workshop words,
  errors-as-data) becomes CN2/CN3's guard vocabulary, real this time;
  its thread machinery is refused in §0.5 with reasons.
