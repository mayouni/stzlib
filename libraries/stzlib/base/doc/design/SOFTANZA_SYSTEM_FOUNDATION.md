# The Softanza System Foundation
### A first-principles redesign of system programming: scope-oriented, engine-true, virtualizable, governable
*Design document — v0.8 (2026-07-20). Status: **the foundation is COMPLETE —
Phases 0 through 4 AND the full §2 scope model (Phase 3b) all IMPLEMENTED.**
Engine-true facts + stzProcess/stzOperatingSystem/stzEnvironment + managed child
processes; the scope-model floor (`stzSystemProfile`/`stzSystemCapabilities`);
the Virtual System twin over files, env vars, cwd and process spawns
(`stzVirtualSystem` + `stzVirtualFileSystem` + `stzVirtualEnvironment` — rehearse
→ plan → commit, the twin holds no reference to reality); the governance crossing
(`stzSystemActor` + `stzUpdatePlan` executor gate — an LLM's empty effect set
commits nothing, in any domain); and the **architect's common ground**
(`stzPlatformProfile` + `stzAppProfile` + `stzSystemScope` — model the solution,
then write feature code in an `App(:x).System()` scope that down-constrains what
the target forbids and up-enables what the host lacks, with a `.stzplatform`
format). §2 is now realized, not proposed. Items are marked ALREADY EXISTS /
SHIPPED / PLANNED. **290 assertions across seven guards, all green.**

> **v0.3 adds the programmer-facing model (§2):** the three system scopes
> (development / deployment / runtime-current) over one common-ground solution
> profile. This is Softanza's **Scope-Oriented Programming** paradigm
> (`SCOPE_ORIENTED_PROGRAMMING.md`) applied to systems — its second governed
> field after regex. The four engine/enforcement layers (§3) are unchanged; §2
> is the model the programmer writes in, §3 is how the engine makes it true.

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
- **"Which system am I talking about?" has no answer at the call site.** A bare
  `CurrentSystem()` returns the developer's laptop today and the phone the app
  was deployed to tomorrow — *the same line, two answers* — because its meaning
  is bent by an invisible frame (where is this code actually running?). Nothing
  in the code distinguishes *the system I author on* from *the system this code
  will run on when shipped*, so a developer writing a mobile feature on a Windows
  box has no way to say — and no way for Softanza to check — that the code is for
  Android, not for the laptop. This is the same disease Softanza already cured
  for regex, and it is cured the same way (§2).

Design documents already point at the fix from complementary angles:

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

**SP6 — Every system act is written in a named scope.** No line of system code
floats on an ambient "current system." The programmer always writes inside one
of three explicit scopes — *development*, *deployment*, or *runtime-current* —
and the scope, visible at the call site, decides which system the act speaks
about and which capabilities it may use. This is Scope-Oriented Programming
(`SCOPE_ORIENTED_PROGRAMMING.md`) applied to systems; §2 is the model it
produces. SP6 is what lets SP1–SP5 be *addressed to the right system*: an
engine-true fact (SP1) is a fact *about the scope's system*; a twin (SP5)
rehearses *the scope's system*, which may not be the host at all.

---

## 2. The programmer's model — three system scopes over one solution

Sections 3–7 describe how the engine, the twin, and the governance gate make
system operations *true and safe*. This section describes how the **programmer
writes and reads** them — the model that sits above all four layers and that a
Softanza software architect works in. It is the answer to the fourth seam in §0:
*which system am I talking about?*

### 2.1 The disease, and why earlier models failed

System code has the regex disease: **one act, meaning bent by an invisible
frame.** `CurrentSystem()` returns your laptop during development and Android
after deployment — correctly, both times — because "current" genuinely means
*wherever this code runs at execution*. Every model that tried to freeze it —
`ThisSystem()` vs `TargetSystem()`, host vs runtime vs target — broke on the
same rock: after an app ships, `CurrentSystem()` on the phone **must** return
Android, so no name can mean "the dev machine" and "current" at once.

The cure is not a better name. It is **M3 of the paradigm**: never write feature
code against "current." Write it in a *named scope*, and let "current" be only a
runtime value that — by construction — matches the scope the code was written
against.

### 2.2 The common ground: model the solution before the features

A Softanza architect models the **deployment architecture first**, as a
declarative artifact, before a line of system feature code:

```ring
oPlatform = new stzPlatformProfile("my-iot-product")   # the common ground
oPlatform {
    DevelopedOn(:Windows)              # the DEV system
    Deploy(:backend,  :LinuxServer)    # each part + the system it deploys to
    Deploy(:superapp, :Android)
    Deploy(:firmware, :ESP32)          # or Deploys([ [:backend, :LinuxServer], ... ])
}
```

- **`stzPlatformProfile`** — the whole solution: which parts exist, which
  systems they deploy to, and which system the architect develops on. The common
  ground everything else attaches to.
- **`stzAppProfile`** — one part of the solution (a backend, a superapp, an app,
  a firmware image). Each declares the system it deploys to.
- **`stzSystemProfile`** — a system, as a *capability envelope + OS + runtime +
  resources*. Attached in two roles: the **development** profile (on the
  platform) and a **deployment** profile (on each app).

All three are **profiles** — declarative design objects, following Law 1
(a domain is a folder + an entry object + a format): `.stzplatform` references
`.stzapp`s reference `.stzsystem`s. The profile is the architect's *declaration*;
`stzApp` / `stzPlatform` (the delivery-plane runtime worlds) are what *realize*
it.

### 2.3 Three scopes that cannot be confused

Feature code is written **inside a scope**, and the scope is a different, unmixable
name for each of the three worlds:

| scope | how you write it | what it resolves to | used for |
|---|---|---|---|
| **development** | `oPlatform.DevelopmentSystem()` | the machine the architect codes on | build, flash, rehearse — **tooling only** |
| **deployment** | `oPlatform.App(:x).System()` | the system app *x* deploys to | **where feature code is written and checked** |
| **runtime-current** | `CurrentSystem()` | whatever system this code runs on *now* | runtime-adaptive branches |

```ring
oPlatform.App(:firmware).System() {
    ReadPin(4)            # ESP32 profile is in scope: GPIO exists here...
    Spawn("worker")       # ...REFUSED at write time: an MCU has no processes
}

oPlatform.App(:superapp).System() {
    ChangeDirectory("/etc")   # REFUSED: the Android sandbox forbids it
    Persist(oConfig)          # LOWERED to the Android idiom (shared-prefs)
}
```

The guarantee, and why "no confusion is possible" (SP6): feature code for app
*x* lives inside `App(:x).System()`, is checked against *x*'s deployment
profile, and at runtime `CurrentSystem()` **equals that profile** — because that
is where *x* deploys. Dev-machine facts are reached *only* through
`DevelopmentSystem()`, in tooling scope. A reader of any system line knows which
world it belongs to from the scope it sits in; there is no ambient "current" to
guess. Softanza can therefore check, statically, that deployment code never
reaches for `DevelopmentSystem()` and that its system calls stay within the
scope's declared capabilities.

`stzSystemRuntime` follows the same rule: it is a **facet of a system profile**,
never a free-floating object. `App(:firmware).System().Runtime()` is the ESP32's
runtime, unambiguously; `CurrentSystem().Runtime()` at execution is the same
runtime. "Whose runtime?" never floats again.

### 2.4 The two worlds: constrain one, enable the other

Because Softanza holds *both* the development profile and each deployment
profile, and because a deployment system's capabilities can **differ from the
dev machine's**, the model mediates in both directions (paradigm move M5):

- **Down-constrain** — the host *can*, the scope *forbids*. `Spawn` in an Android
  scope is refused *on your Windows laptop, at write time*, with the nearest
  legal alternative named (Law 3). The scope stops you from assuming your world's
  affordances just because your machine has them.
- **Up-enable** — the scope *requires*, the host *lacks*. `ReadPin(4)` for the
  ESP32 is written even though your laptop has no GPIO: Softanza **rehearses it
  against a virtual twin of the ESP32** (simulated pins, on your machine), so you
  develop and test the logic where you are, and the deploy step lowers the
  rehearsal to real firmware. **You develop for a world you cannot run**, and the
  twin (§6) is the bridge.

This is the deepest reason the System Foundation and the Virtual System Framework
are one design: the twin is not only "rehearse a dangerous op before committing"
— it is also **"rehearse a foreign system's op your host cannot perform, then
lower it on deploy."** Two worlds of system, one twin mechanism, mediated by the
scope.

### 2.5 Where §2 meets the four layers (§3–§7)

| the programmer writes (this section) | the engine/enforcement makes it true (§3–§7) |
|---|---|
| `App(:x).System()` scope | a `stzSystemProfile` whose facts are engine-true (SP1, Layer 0 / §4) |
| down-constrain / up-enable (M5) | the capability lattice + the twin's foreign-system rehearsal (§6–§7) |
| `CurrentSystem()` at runtime | a live `process.zig` / `system.zig` read (§4), guaranteed to match the scope |
| the deploy step that lowers a rehearsal | a governed `stzUpdatePlan` crossing (§6–§7) |

The model is the *face*; the four layers are the *body*. Neither is optional:
without §2 the programmer cannot say which system they mean; without §3–§7 the
saying would not be true or safe.

---

## 3. The four layers

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

## 4. Layer 0 — the engine as the system's single source of truth

### 4.1 What exists

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

### 4.2 What the foundation adds (engine-side)

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

### 4.3 The multi-language payoff

`extercode/` already proves Softanza speaks to Python/Julia/R/Prolog as
*external processes*. The System Foundation is the inverse and the deeper move:
the **engine is the invariant, the libraries are projections** (architecture
doc 0.4). A Python-native Softanza would load `stz_process.dll` /
`stz_system.dll` and get *the same pid, the same spawn, the same reality
bridge* — because the true work never lived in Ring. This document's SP1 is
what makes that free.

---

## 5. Layer 1 — the real projection (thin, intent-named)

### 5.1 `stzProcess` — NEW (the missing keystone)

Two faces, one class family. **SHIPPED (Phase 0/1)** except where marked:

- **This process** (introspection): `Id()`/`Pid()`, `Uptime()`/`UptimeMs()`/
  `UptimeNs()`, `EngineArchitecture()` (raw Zig tag) and `Architecture()`
  (canonical `x64`/`arm64`/... — the one reconciliation seam), `OS()`,
  `Endianness()`, `PointerSize()`, `BitSize()`, `Is64Bit()`, `Info()`. Pure
  sensing; every method a one-line delegate to `process.zig`. *(`ExePath()`,
  `ResidentMemory()` — still PLANNED engine adds.)*
- **A child process** (control): `Spawn(command)` / the `SpawnProcess(command)`
  global → streaming `ReadOutput()` / `ReadError()` (with `ReadOutputAll()` /
  `ReadErrorAll()` drainers), `Wait()`, `ExitCode()`, `Succeeded()`/`Failed()`,
  `Kill()`, `ChildPid()`, `HasChild()`, and `Close()` (idempotent; kills a
  still-running child so a dropped handle never leaks). This is what
  `stzSystemCall` cannot do — a *managed, streamable, killable* child — and it
  delegates to the engine `spawn/read_stdout/read_stderr/wait/kill/free`.
  *(`IsAlive()` — still PLANNED.)*

`stzSystemCall` stays as the *convenience* front (named cross-platform
commands, `@RETURN:` typing); re-expressing it over `stzProcess.Spawn` so there
is one spawn implementation, not two, is PLANNED.

### 5.2 `stzOperatingSystem` — REFACTOR (engine-backed)

Every fact method (`Architecture`, `Is64Bit`, `BitSize`, `OS`, `IsWindows`,
`Endianness`, …) delegates to `process.zig` / `system.zig`. Ring's `getarch()`
reimplementation is retired. The class keeps its rich *derived* surface
(`IsUnixLike`, `IsMobile`, `NameAndArchitecture`, the 30+ predicates) — those
are *interpretations* of the engine facts, which is the correct division:
**facts are engine, opinions are Ring.** A naming reconciliation is decided
once (engine `x86_64` ↔ Softanza `x64`) and applied at the projection seam so
the vocabularies never disagree in the wild.

### 5.3 `stzEnvironment` — NEW

`GetVar(name)` / `ValueOf(name)` / `Var(name)`, `SetVar(name, value)`,
`UnsetVar(name)`, `Variables()` (list of `[name, value]` pairs, split on the
first `=`), `Has(name)`, `WorkingDirectory()` / `Cwd()`, `ChangeDirectory(path)`
/ `Cd(path)`, `HostName()`, `UserName()`, `CpuCount()`. Engine-backed. *(The
accessor verbs are `GetVar` / `SetVar`, not `Get` / `Set`, because `Get`/`Set`/
`Value` collide with Ring's brace-accessor protocol — a naming lesson from the
Phase 0 build.)* Small, obvious, and *previously absent* — you could not set an
env var or read the cwd through Softanza before this foundation.

Together, `stzProcess` + `stzOperatingSystem` + `stzEnvironment` +
`stzFile`/`stzFolder` + `stzSystemCall` are the **complete real surface** for
system programming — the "three pillars" (memory / process / data) of the
low-level vision, minus the memory pillar which is its own foundation
(`stkBuffer`/`stkMemory`, tracked separately).

---

## 6. Layer 2 — the Virtual System (the universal abstraction + sandbox)

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

## 7. Layer 3 — governance (why an agent cannot hurt you)

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
| commit scope (VSF §4.5) | `stzCommitScope` (new, small) + `stzGovernance` permissions |
| trust posture per executor | `stzGovernance.DeclarePosture` (`trusted`/`external`/`sandboxed`) / `MayExecute` |
| capability colouring | `stzAgentGraph` lattice + taint; **an LLM actor's effect-capability set is EMPTY** |
| audit / lineage | `stzGovernance.RecordDecision` / `LineageOf`; (future `stzTrace`) |

The crossing is gated: `stzUpdatePlan.Execute()` asks the reality bridge, which
asks governance — *may this executor commit these operation types under this
scope?* An effectful operation proposed by an LLM actor (empty effect
capability) **cannot cross**; it can only sit in the plan awaiting a guardian
or human to authorise it. **Expression is free; admission is governed.**

---

## 8. How this advances intelligence & agentic programming

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

## 9. Implementation roadmap (proposed)

Each phase compiles green and pushes both remotes; nothing breaks existing
callers.

- **Phase 0 — engine truth + thin projection. SHIPPED (2026-07-20).**
  (a) Refactored `stzOperatingSystem` to delegate every fact to `process.zig` /
  `system.zig`; retired the Ring `getarch()` computation; reconciled the arch
  vocabulary at the seam. (b) Created `stzProcess` (introspection face) over the
  existing `process.zig`. (c) Added engine `env_set/unset/list`, `cwd_get/set`,
  `hostname`, `username`, `cpu_count`; created `stzEnvironment`. Guarded,
  bulk-returned, bind-don't-reimplement. *Killed the double-source and filled the
  two missing classes, with no new subsystem.*
- **Phase 1 — managed child processes. SHIPPED (2026-07-20).** Engine
  `spawn/read_stdout/read_stderr/wait/kill/pid/free`; `stzProcess` control face
  (`Spawn`, streaming `ReadOutput`/`ReadError`, `Wait`, `ExitCode`, `Kill`,
  `Close`); `SpawnProcess()` global.
- **Phase 1b — the scope-model floor (§2, first buildable slice). SHIPPED
  (2026-07-20).** `stzSystemProfile` as a facet bundle (OS / Runtime /
  Capabilities / Resources) with a `.stzsystem` format; `DevelopmentSystem()`
  and `CurrentSystem()` populated *live* from the engine (Phase 0/1 supplies
  every fact); declared deployment targets built with `DeclareSystem()` or read
  from a `.stzsystem` file, whose facts are STORED so they never leak from the
  live machine (an rtos/android profile answers rtos/android on a Windows box).
  The keystone `stzSystemCapabilities` is a **closed named set** classified into
  the agentic lattice kinds (effectful/sensing/compute/inference), giving the
  two-worlds compare (`Forbids`/`Requires`, §2.4) and the system↔agent bridge
  (`CapabilitiesForActorKinds` — an LLM actor's effect set comes out empty). No
  platform/app graph and no lexical `App(:x).System(){…}` scopes yet — just the
  three named scopes, introspectable, with the shared capability envelope. Pure
  Ring, no engine change. Guard: `system_scope_model_narrated.ring` (54).
- **Phase 2 — `stzVirtualSystem` root + File specialization. SHIPPED
  (2026-07-20).** `stzVirtualOperation` (change as a first-class object with
  actor + intent), `stzVirtualSystem` (domain-agnostic rehearse/undo/snapshot/
  rollback core over a state that `Apply`s + `Clone`s), `stzFileTree` (the
  virtual state, origin mirrored|virtual), `stzVirtualFileSystem` (the
  intent-named rehearsal verbs CreateFile/WriteFile/Move/Copy/Delete + MirrorFrom
  + free inspection that reads the twin, not disk), `stzUpdatePlan` (narration,
  risks, `Validate` re-check, `RejectOperation`, `Execute`) and `stzCommitScope`
  (allowed prefixes/types/max-ops). The reality bridge `stzFileSystemBridge` is
  the **only** class that touches disk — it delegates to the engine
  `StzEngineFile*` / `StzEngineDir*` primitives. Pure Ring, no engine change.
  Guard `virtual_system_twin_narrated.ring` (48) proves P1 (rehearsal touches
  nothing), the one-door commit, scope refusal (out-of-scope ops never reach
  disk), reject, undo, snapshot, mirror, and move semantics. *(This is the
  up-enable mechanism the scope model needs — the twin is how a host rehearses
  operations for a system it is not.)*
- **Phase 3 — Process/Env specialization. SHIPPED (2026-07-20).** The same
  rehearse → plan → commit core, reused unchanged, over a new domain:
  `stzEnvironmentState` (vars + cwd + a queue of pending spawns, origin
  mirrored|virtual), `stzEnvironmentBridge` (the only class that touches the
  real environment/process — delegates to `stzEnvironment`'s SetVar/UnsetVar/
  ChangeDirectory and the global `SpawnProcess`), and `stzVirtualEnvironment`
  (rehearsal verbs SetVar/UnsetVar/Cd/Spawn + MirrorReality). Especially
  valuable because env/process effects are invisible until they happen — so the
  plan makes them visible first ("this will set 2 vars, change dir, spawn 3
  children"), spawns are risk-flagged, and nothing runs until commit. Pure Ring.
  Guard `virtual_environment_twin_narrated.ring` (38) proves P1 for env AND
  process (a queued spawn does not run — verified by a marker file it would
  create — until commit), scope refusal, reject, undo/snapshot, and a
  committed-then-restored cwd change. The core file (`stzVirtualSystem.ring`)
  gained only additive `set_var`/`unset_var`/`change_dir`/`spawn_process` cases
  in Describe/Impact/Risks.
- **Phase 3b — the full scope model (§2). SHIPPED (2026-07-20).**
  `stzPlatformProfile` (the common ground: the dev system + the apps) +
  `stzAppProfile` (a part + its deployment `stzSystemProfile`) + `stzSystemScope`
  (the named context feature code is written in). Model the solution —
  `oSol.DevelopedOn(:Windows)`, `oSol.Deploy(:firmware, :ESP32)` — then write in a
  scope: `oSol.App(:firmware).System()`
  resolves to the ESP32 profile (says `espidf` on a Windows box — no live leak).
  **Down-constrain** is a real refusal: `scope.Spawn(...)` raises in the firmware
  scope because the target forbids `process`, checked on the dev box against the
  target profile so it is caught during development. **Up-enable** is a real
  rehearsal: `scope.ReadPin(4)` is allowed (the ESP32 has gpio) but returns
  `"rehearsed"` because the dev host lacks gpio — captured in
  `RehearsedOperations()` for the deploy-time lowering. The same op gets
  different verdicts per scope (Spawn: native on the Linux backend, refused on
  ESP32 and Android). Feature code reads naturally in a Ring block —
  `scope { ReadPin(1) WritePin(2,1) }`. `.stzplatform` format round-trips.
  Builds on the Phase 1b capability envelope; the scope's profile is the same
  one that gates actors (Phase 4). Pure Ring. Guard
  `full_scope_model_narrated.ring` (34).
- **Phase 4 — governance crossing. SHIPPED (2026-07-20).** Each
  `stzVirtualOperation` is coloured by the capability KIND it requires
  (`RequiredKind` — every reality-touching op is `effectful`). `stzSystemActor`
  carries a set of capability kinds — the SAME lattice as `stzSystemCapabilities`
  (Phase 1b) and `stzAgentGraph`, with factories `HumanActor`/`PIActor`/
  `LLMActor`/`GuardianActor` mirroring the graph exactly. `stzUpdatePlan.Execute`
  now passes three gates per op — reviewer (reject), scope (where/what),
  **governance** (may THIS actor commit an op of THIS kind) — plus an optional
  `stzGovernance` for the trust-posture requirement (`MayExecute`) and the
  decision lineage (`RecordDecision`). `MayCommit()` answers "can this actor
  cross at all" before an attempt. Guard `governance_crossing_narrated.ring`
  (31) proves the capstone: an LLM actor's empty effect set commits NOTHING
  across BOTH domains (file + env), a human/PI commits, a guardian (sense/
  compute, no effect) cannot, posture is required under governance, and the
  gates compose (an LLM is refused even inside scope). Pure Ring. *Note:* Ring
  copies objects on assignment, so a wired governance's lineage accumulates in
  the plan's copy (read via `plan.Governance()`); the plan also keeps its own
  plain-data `AuditTrail()`.

**Every phase is shipped — the foundation is complete, §2 included.** The twin
covers files, environment variables, the working directory, and process spawns,
all through one governed plan; the crossing is gated by the actor's authority;
and the architect's common ground (`stzPlatformProfile` / `stzAppProfile` /
`stzSystemScope`) makes §2 real — model the solution, write feature code in an
`App(:x).System()` scope, and the scope down-constrains what the target forbids
and up-enables what the host lacks, on the dev box, before deploy. "Agents that
cannot hurt you" is a property the code enforces, not a promise: an LLM actor
whose effect-capability set is empty (Phase 1b) simply cannot make a plan cross,
in any domain (Phase 4, proven by the guard). One capability-scope — the lattice
of effectful/sensing/compute/inference — now runs through the whole foundation:
a system's capabilities, a deployment scope's verdicts, an actor's authority,
and the reactor host's supervision are one vocabulary. The natural next work is
no longer the *system* foundation but what builds on it: wiring the scope model
into the delivery plane (`stzApp`/`stzPlatform`) and the deploy-time lowering
bridge that turns an up-enable rehearsal into real firmware.

## 10. Quality bar

- **Fidelity:** virtual semantics match real semantics exactly (path rules,
  name collisions, case behaviour per platform) — the engine is the oracle for
  both, so they cannot drift.
- **Honesty:** the plan re-validates at execute time; reality may have moved.
- **Legibility:** every narration readable by a non-programmer — the Softanza
  signature.
- **Multi-language readiness:** no fact, no mutation, and no reality bridge
  primitive lives above L0.
