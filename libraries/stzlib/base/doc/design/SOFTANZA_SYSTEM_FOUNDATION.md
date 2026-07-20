# The Softanza System Foundation
### A first-principles redesign of system programming: engine-true, virtualizable, governable
*Design document — v0.1 (2026-07-20). Status: proposal. Nothing here is implemented except where marked ALREADY EXISTS.*

---

## 0. Why this document exists

Softanza's system-facing code grew organically and now shows the seams:

- **`stzOperatingSystem`** computes architecture and bit-size in *Ring* (via
  `getarch()`), while the engine's `process.zig` computes the *same facts* in
  Zig (`process_arch`, `process_ptr_size`). Two sources of one truth. They
  happen to agree today; nothing guarantees it, and a future Julia or Python
  binding of Softanza would have to re-derive the fact a third time.
- **`stzProcess` does not exist.** There is a `process.zig` engine module
  (pid, uptime, arch, os, endian, pointer size) with a bridge and *no Ring
  consumer at all*, and a `stzSystemCall` that spawns *external* commands but
  offers nothing for *the current process* or for *managing a spawned child*
  (streaming, waiting, killing).
- **The mutating operations are immediate and consequential.** `stzFile`,
  `stzFolder`, `stzSystemCall` act on reality the instant they are called. A
  deleted file is gone. There is no rehearsal, no plan, no undo — which is
  exactly the posture that makes system programming feel dangerous, and makes
  it *unsafe to hand to an autonomous agent*.

Three separate design documents already point at the fix from three angles:

1. **`stz-lowlevel-system-programming.md`** — the *vision*: system programming
   made accessible through **safe memory, named cross-platform operations, and
   integration**, high-level down to low-level, "systems-aware without becoming
   a C programmer."
2. **`Softanza Virtual System Framework.md`** — the *sandbox*: every unmanaged
   system gains an **in-memory twin** where operations are **rehearsed, planned,
   and only then committed**; the **UpdatePlan is the sole crossing point** into
   reality; the framework is **actor-neutral** (P5) and **separates the power to
   imagine change from the authority to enact it** (P6).
3. **`Softaza and Agents That Cannot Hurt You.md`** + the governance layer
   (`stzGovernance`, `stzAgentGraph`) — the *trust boundary*: capability
   colouring, trust postures, and permission gates that let an agent **propose**
   without letting it **effect**.

This document unifies the three into **one foundation** and states the single
principle that makes them cohere:

> **The engine is the only thing that touches reality. Everything above it —
> Ring classes, the virtual twin, the governance gate — is a projection or a
> rehearsal. Reality changes only when a governed plan crosses the one bridge
> the engine owns.**

---

## 1. First principles

**SP1 — One truth, engine-side.** Every *fact about the system* (architecture,
OS, endianness, pointer size, pid, uptime, env, cwd, host, cpu, memory) and
every *mutation of the system* (create, write, move, delete, spawn, kill) is
implemented **once, in the Zig engine**, behind a flat C-ABI. Ring is a
consumer. Any future language is a consumer. No binding re-derives a fact or
re-implements an operation. *(This is the engine-first doctrine the string,
list, csv, html and file modules were all converged onto during 2026-07.)*

**SP2 — Intent over mechanics.** The surface names what the practitioner means
(`Architecture()`, `SpawnProcess()`, `SetEnv()`), never modes and flags. This
continues the Softanza file-API philosophy and the low-level-vision promise.

**SP3 — Reality is reached through exactly one door.** Immediate mutation is
*still available* (the real classes call the engine directly), but the *default
and recommended* path for consequential change is: **rehearse in a twin →
generate a plan → commit the plan**. The plan is the door. The door can be
locked (scoped), watched (narrated), and audited (traced).

**SP4 — Separated powers, from day one.** The capability to *rehearse* and the
authority to *commit* are distinct and independently grantable. A human usually
holds both. A script or agent may hold *rehearse-freely + commit-only-within-a-
declared-scope*, or *rehearse-only* (it proposes; a human or guardian commits).
This is VSF's P6 and the governance layer's authority model, made the same
mechanism.

**SP5 — The twin is the agent's world.** An intelligent or agentic program that
needs to touch the system does so **only through the virtual twin**. Its "tools"
are virtual operations (safe by construction, P1: the twin holds no reference to
reality). Its output is a **proposed UpdatePlan**, reviewable and revisable
before anything happens. "Agents that cannot hurt you" is not a promise bolted
on; it is what SP1–SP4 produce.

---

## 2. The four layers

```
        ┌───────────────────────────────────────────────────────────┐
  L3    │  GOVERNANCE  —  the trust boundary                        │
        │  stzGovernance (authority, permission, posture, lineage)  │
        │  stzAgentGraph (capability lattice + taint colouring)     │
        │  stzCommitScope (allowed paths / types / max-ops)         │
        │  → decides WHO may commit WHICH plan, WHERE, and records  │
        │    WHY. An LLM actor's effect-capability set is EMPTY.    │
        └───────────────────────────┬───────────────────────────────┘
                                    │ authorises
        ┌───────────────────────────▼───────────────────────────────┐
  L2    │  VIRTUAL SYSTEM  —  the sandbox / universal abstraction    │
        │  stzVirtualSystem  ·  stzVirtual{File,Folder,Process,Env}  │
        │  in-memory twin · operations · snapshots · branches ·     │
        │  history · rollback · diff-vs-reality · UpdatePlan        │
        │  → REHEARSE freely. Produce ONE crossing artifact.        │
        └───────────────────────────┬───────────────────────────────┘
                                    │ mirrors (read) / commits (via plan)
        ┌───────────────────────────▼───────────────────────────────┐
  L1    │  REAL PROJECTION  —  the reference library (Ring today)    │
        │  stzProcess · stzOperatingSystem · stzEnvironment ·        │
        │  stzFile · stzFolder · stzSystemCall                      │
        │  → thin, intent-named. Every method delegates to L0.      │
        │    Immediate + consequential. This is "reality" for L2.   │
        └───────────────────────────┬───────────────────────────────┘
                                    │ C-ABI (the invariant)
        ┌───────────────────────────▼───────────────────────────────┐
  L0    │  ENGINE  —  the one thing that touches the OS (Zig)        │
        │  system.zig · process.zig · file.zig  (+ new: env, cwd,   │
        │  host, cpu, mem, spawn/stream/wait/kill, proc-list)       │
        │  → real work. Reusable by Ring, Python, Julia, anything.  │
        └───────────────────────────────────────────────────────────┘
```

The reason the diagram is worth drawing: **L1 and L2 present the *same
intent-named surface*.** `stzVirtualFolder.CreateFile("x")` and
`stzFolder.CreateFile("x")` read identically; the virtual one records the
operation and the real one performs it. One mental model, two consequences.
The rule of thumb (from the VSF doc): *the virtual class has every method the
real class has, plus the rehearsal verbs.*

---

## 3. Layer 0 — the engine as the system's single source of truth

### 3.1 What exists

- `process.zig` — `pid`, `uptime_ns/ms/s` *(fixed 2026-07-20 to be real
  monotonic uptime, not epoch wall-clock)*, `arch`, `os`, `endian`, `ptr_size`.
  ALREADY EXISTS, bridged, previously unused by Ring.
- `system.zig` — `run` / `run2` *(one-spawn stdout+stderr+exit, fixed
  2026-07-20)* / `exec`, `env` **(get only)**, `is_windows/linux/macos`.
  ALREADY EXISTS.
- `file.zig` — `exists/size/mtime/read/write/append/delete/copy`,
  `dir_exists/create/create_path/delete/count_files/count_dirs/list_files/
  list_dirs` *(listing moved engine-side + `pathIsUsable` screen, 2026-07-19)*.
  ALREADY EXISTS. **These are already the Reality-Bridge primitives L2 needs.**

### 3.2 What the foundation adds (engine-side)

A coherent `system` capability surface, all flat C-ABI, all reusable by any
binding:

| capability | functions (proposed) | notes |
|---|---|---|
| environment | `env_get` *(exists)*, `env_set`, `env_unset`, `env_list` | list = NUL-delimited `KEY=VALUE` blob, drained bridge-side like the dir listing |
| working dir | `cwd_get`, `cwd_set` | `cwd_set` behind the `pathIsUsable` screen |
| host / user | `hostname`, `username` | |
| machine | `cpu_count`, `mem_total`, `mem_free` | for capacity checks in the workbox (VSF §5.4.5) |
| current process | `pid`, `uptime_*` *(exist)*, `exe_path`, `rss` (resident memory) | |
| child process | `spawn` (argv, env, cwd) → handle; `read_stdout`/`read_stderr` (stream); `wait` → exit; `kill`; `is_alive` | the real advance over `run2`'s fire-and-collect; needed for streaming + long-running children |
| process table | `proc_list` → pids+names; `proc_exists(pid)` | read-only sensing |

Two of these are **already specified in the engine design docs**, not
invented here:

- **Child-process spawning** — `SOFTANZA_ENGINE_DESIGN.md` §"Process
  Management [PLANNED]" already defines `stz_process_start` / `_wait` /
  `_read_stdout` / `_read_stderr` / `_write_stdin` / `_kill`, explicitly to
  *"replace stzExterCode's manual process spawning."* Phase 1 below implements
  that existing spec. (The `stz_process` DLL shipped only its *introspection*
  half — DLL #39; the spawn half is the planned remainder.)
- **A coarse engine sandbox** — `SOFTANZA_ENGINE_ARCHITECTURE.md` already
  specifies `stz_config_sandbox(STZ_NO_FILESYSTEM | STZ_NO_NETWORK |
  STZ_NO_PROCESS)`, a global kill-switch for untrusted execution. The System
  Foundation makes that coarse flag *fine-grained and semantic*: the virtual
  twin (L2) is the per-operation, reviewable, domain-aware sandbox the flag
  cannot be. Coarse flag and twin compose — belt and braces.

Design rules for L0 (learned this session, and consistent with the engine doc's
own rule *"every feature is implemented once, in the Engine; language clients
are thin FFI bridges that add syntax, never computation"*):

- **Return multiple values as a bridge-built Ring list** (`newlist` +
  `addstring2`/`addint` + `retlist`), the way `system_run2`, the CSV dump, and
  the HTML class-pairs already do — never re-run or re-query to fetch a second
  value.
- **Size buffers to fit or return an owned pointer + length**; never a fixed
  stack buffer that truncates to empty past its size (the 64 KB HTML bug).
- **Screen every path argument** through `pathIsUsable` before handing it to
  `std` (the folder-listing panic).
- **Bind, don't reimplement**: if the engine computes a fact, the Ring class
  reads it — never a parallel Ring computation (the arch double-source).

### 3.3 The multi-language payoff

`extercode/` already proves Softanza speaks to Python/Julia/R/Prolog as
*external processes*. The System Foundation is the inverse and the deeper move:
the **engine is the invariant, the libraries are projections** (architecture
doc 0.4). A Python-native Softanza would load `stz_process.dll` /
`stz_system.dll` and get *the same pid, the same spawn, the same reality
bridge* — because the true work never lived in Ring. This document's SP1 is
what makes that free.

---

## 4. Layer 1 — the real projection (thin, intent-named)

### 4.1 `stzProcess` — NEW (the missing keystone)

Two faces, one class family:

- **This process** (introspection): `Pid()`, `Uptime()`/`UptimeMs()`,
  `Architecture()`, `OS()`, `Endianness()`, `PointerSize()`, `ExePath()`,
  `ResidentMemory()`. Pure sensing; every method a one-line delegate to
  `process.zig`.
- **A child process** (control): `stzProcess.Spawn(program, args)` →
  `Start()`, `ReadOutput()` / `ReadError()` (streaming), `Wait()`,
  `ExitCode()`, `Kill()`, `IsAlive()`. This is what `stzSystemCall` cannot do
  — a *managed, streamable, killable* child — and it delegates to the new
  engine `spawn/read/wait/kill`.

`stzSystemCall` stays as the *convenience* front (named cross-platform
commands, `@RETURN:` typing) and is re-expressed over `stzProcess.Spawn` so
there is one spawn implementation, not two.

### 4.2 `stzOperatingSystem` — REFACTOR (engine-backed)

Every fact method (`Architecture`, `Is64Bit`, `BitSize`, `OS`, `IsWindows`,
`Endianness`, …) delegates to `process.zig` / `system.zig`. Ring's `getarch()`
reimplementation is retired. The class keeps its rich *derived* surface
(`IsUnixLike`, `IsMobile`, `NameAndArchitecture`, the 30+ predicates) — those
are *interpretations* of the engine facts, which is the correct division:
**facts are engine, opinions are Ring.** A naming reconciliation is decided
once (engine `x86_64` ↔ Softanza `x64`) and applied at the projection seam so
the vocabularies never disagree in the wild.

### 4.3 `stzEnvironment` — NEW

`Get(name)`, `Set(name, value)`, `Unset(name)`, `All()`, `Has(name)`,
`WorkingDirectory()`, `ChangeDirectory(path)`, `HostName()`, `UserName()`.
Engine-backed. Small, obvious, and *currently absent* — you cannot set an env
var or read the cwd through Softanza today.

Together, `stzProcess` + `stzOperatingSystem` + `stzEnvironment` +
`stzFile`/`stzFolder` + `stzSystemCall` are the **complete real surface** for
system programming — the "three pillars" (memory / process / data) of the
low-level vision, minus the memory pillar which is its own foundation
(`stkBuffer`/`stkMemory`, tracked separately).

---

## 5. Layer 2 — the Virtual System (the universal abstraction + sandbox)

This is the Virtual System Framework, implemented, generalized beyond files.

- `stzVirtualSystem` (root) — `@oState`, `@aHistory`, `@aSnapshots`,
  `@aBranches`; `ExecuteOperation`, `UndoLast`, `CreateSnapshot`, `RollbackTo`,
  `BranchFrom`, `CompareBranches`, `MirrorFrom(realTarget)` (read-only import),
  `GenerateUpdatePlan()`.
- `stzVirtualOperation` — change as a first-class object, carrying `@cActor`
  and `@cIntent` from day one (legible whether a human, script, or agent
  proposed it).
- `stzUpdatePlan` — the crossing artifact: `ShowNarration`, `ShowRisks`,
  `ShowAlternatives`, `Validate` (re-check against *current* reality),
  `RejectOperation(n, because)`, `Feedback`, `Execute` / `ExecuteStepByStep`.
- `iRealityBridge` — the connector to L1/L0: `CurrentRealityState`,
  `Constraints`, `Capabilities`, `ValidatePlan`, `ExecutePlan`, `VerifyOutcome`.

**Domain specializations** (each = a state class + an operation catalog + a
reality bridge):

1. **File** (VSF's first specialization): `stzVirtualFileSystem`,
   `stzVirtualFolder`, `stzVirtualFile`, `stzFileSystemBridge`. The bridge's
   reality primitives are *exactly `file.zig`* — already built.
2. **Process/Environment** (this document's contribution): a virtual twin
   where you can *rehearse* env changes, cwd changes, and a sequence of process
   spawns, see the plan ("this will set PATH, spawn 3 children, and delete the
   temp dir"), and commit atomically. Especially valuable because process/env
   effects are otherwise invisible until they happen.

The twin is the **sandbox** the request asks for: *"experiment with any
system-facing operation in a secure environment before reflecting such
experimentation onto the real system world."* Safety is architectural (P1),
not procedural.

---

## 6. Layer 3 — governance (why an agent cannot hurt you)

The agentic-safety document states the stance this foundation inherits:
*"We will not build safe agents. We will build a safe world, and let ordinary
agents loose inside it."* The trust boundary is architectural — the agent's
tool surface (the virtual twin, L2) **contains no operation that touches disk,
process, or network at all**: *"There is no wire to cut, because no wire was
ever laid."*

**Two enforcement surfaces, one shape.** Softanza governs effects through two
funnels that share a structure but sit at different altitudes:

- **This foundation's surface — effectful SYSTEM operations** (file, process,
  env, network): the crossing is the **`stzUpdatePlan`**, bounded by
  **`stzCommitScope`**, executed under a **trust posture**. *"[A script or
  agent] can execute plans — but only within a declared `stzCommitScope`
  ('create-only, under /generated, max 40 operations'), every scope auditable,
  every execution verified after the fact."*
- **The intelligence surface — graph / knowledge / code writes**: the 4-stage
  gate (structural → constraint → derivation → governance) over `stzGraphRule`,
  coloured by `stzAgentGraph`. Different door, identical principle: *the gate
  does not care who authored the proposal.*

The System Foundation belongs to the **first** surface. It does not reinvent
the second; it reuses the same enforcement primitives, which ALREADY EXIST and
map onto the VSF cleanly:

| VSF / this doc | existing primitive |
|---|---|
| P6 separated powers | `stzGovernance.SetAuthority` / `MayProceed` |
| commit scope (§4.5) | `stzCommitScope` (new, small) + `stzGovernance` permissions |
| trust posture per executor | `stzGovernance.DeclarePosture` (`trusted`/`external`/`sandboxed`) / `MayExecute` |
| capability colouring | `stzAgentGraph` lattice + taint; **an LLM actor's effect-capability set is EMPTY** |
| audit / lineage | `stzGovernance.RecordDecision` / `LineageOf`; (future `stzTrace`) |

The crossing is gated: `stzUpdatePlan.Execute()` asks the reality bridge, which
asks governance — *may this executor commit these operation types under this
scope?* An effectful operation proposed by an LLM actor (empty effect
capability) **cannot cross**; it can only sit in the plan awaiting a guardian
or human to authorise it. **Expression is free; admission is governed.**

---

## 7. How this advances intelligence & agentic programming

The request's fourth point: this foundation must improve the *operational* and
*programmer-experience* sides of every Softanza paradigm, intelligence and
agents included.

**Operational (what the agent does).** An `stzPIAgent` / `stzLLMAgent` that
must touch the system receives, as its system tool, a **virtual twin**, not the
real classes. It rehearses freely (no risk), emits an **UpdatePlan** as its
proposal, and the plan is admitted only within its declared `stzCommitScope`
under its declared posture. Running as a supervised reactor job (the R5 agent
host), the agent's system side-effects are therefore: *bounded* (scope),
*reviewable* (plan narration + `RejectOperation`), *reversible* (the twin's
history and the plan's step-by-step commit), and *auditable* (lineage). This is
the concrete meaning of "agents that cannot hurt you" for system operations.

**Programmer experience (wise coding over the system).** The same UpdatePlan
that protects against agents *delights* the human: rehearse a reorganization,
read the plain-language plan, see the risks, prune a step, commit. And it
closes the loop with the conversational door — an owner or programmer can *ask*
for a system change; Softanza rehearses it in the twin and shows the plan;
admission is governed by the same rules. The system foundation becomes a first
consumer of wise coding, not an exception to it.

**Intelligence (derivation over system facts).** Because L0 makes system facts
first-class and cheap, they become *knowledge*: a `.stzknow` graph can hold
"this host is 64-bit Windows with 8 cores and 3 GB free," and a rule can derive
"therefore prefer the 4-worker profile." The System Foundation feeds the
knowledge-derivation north star instead of sitting beside it.

---

## 8. Implementation roadmap (proposed)

Each phase compiles green and pushes both remotes; nothing breaks existing
callers.

- **Phase 0 — engine truth + thin projection (the concrete first step).**
  (a) Refactor `stzOperatingSystem` to delegate every fact to `process.zig` /
  `system.zig`; retire the Ring `getarch()` computation; reconcile the arch
  vocabulary at the seam. (b) Create `stzProcess` (introspection face) over the
  existing `process.zig`. (c) Add engine `env_set/unset/list`, `cwd_get/set`,
  `hostname`, `username`; create `stzEnvironment`. Guard, bulk-return, bind-
  don't-reimplement. *This alone kills the double-source and fills the two
  missing classes, with no new subsystem.*
- **Phase 1 — managed child processes.** Engine `spawn/read/wait/kill/
  is_alive`; `stzProcess` control face; re-express `stzSystemCall` over it.
- **Phase 2 — `stzVirtualSystem` root + File specialization.** The VSF's own
  Phase 1–3, reality bridge = `file.zig`.
- **Phase 3 — Process/Env specialization + `stzUpdatePlan` narration/risks.**
- **Phase 4 — governance crossing:** wire `stzCommitScope` + `stzGovernance`
  posture/authority into `stzUpdatePlan.Execute`; the agent host uses it.

Phase 0 is the piece the current request most directly asks for and the one
with the highest ratio of coherence gained to code written.

## 9. Quality bar

- **Fidelity:** virtual semantics match real semantics exactly (path rules,
  name collisions, case behaviour per platform) — the engine is the oracle for
  both, so they cannot drift.
- **Honesty:** the plan re-validates at execute time; reality may have moved.
- **Legibility:** every narration readable by a non-programmer — the Softanza
  signature.
- **Multi-language readiness:** no fact, no mutation, and no reality bridge
  primitive lives above L0.
