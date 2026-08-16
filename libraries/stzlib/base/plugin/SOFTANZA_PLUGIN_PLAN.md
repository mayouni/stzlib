# SOFTANZA PLUGIN PLAN — the extension plane (PL0–PL5)

Status: **PLAN OF RECORD**, written 2026-08-16, before any code.
Supersedes the 2024 prototype narration
`libraries/stzlib/max/test/stzPluginSystemTest.ring` (895 lines) and its
companion `libraries/stzlib/max/test/stzStateSystemTest.ring`.

Those files are **claims, not code**. Every output block in them was
written by hand; a repo-wide search shows that not one function they call
(`LoadPlugins`, `XString`, `Xf`, `XCalls`, `IsRingState`…) exists anywhere
in the library. They are kept as the source of intent; §0.5 dispositions
every claim they make as ADOPT / RESHAPE / REFUSE. Nothing from them
enters the library except through that table.

Siblings, whose laws this plan inherits: `base/cluster/SOFTANZA_DISTRIBUTION_PLAN.md`
(D0–D6 + R8, complete), `base/stats/SOFTANZA_TUKEY_PLAN.md` (TK0 pending),
`base/gpu/SOFTANZA_GPU_PLAN.md` (complete), `base/gui/SOFTANZA_GUI_PLAN.md`
(G0–G4b shipped), `engine/SOFTANZA_COMPUTE_MODEL.md` (the compute doctrine).

---

## HOW TO USE THIS DOCUMENT (session bootstrap — read this first)

This file is **sufficient on its own** for a dedicated session that has
never seen the plugin work. There is deliberately **no companion design
document** — this repo has been bitten by duplicated rule lists that
drift. The "strategic proposal", the "design documents" and the
"implementation plan" the plane was asked for are §1, §2–§4 and §5–§6
of this one file.

### The mission, in one paragraph

Softanza can compose behavior it *owns* (methods, skills, workers,
agents) but has no story for behavior it *does not own*: a function
written by someone else, dropped in a folder, versioned independently,
possibly wrong, possibly slow — that the host program can nonetheless
call, observe, constrain, cache, and revoke without ever letting it
touch host state directly. The 2024 prototype named this exactly: a
**plugin** is third-party code executed in an **isolated Ring VM state**,
invoked through one verb (`Xf`), with every call **ledgered**. What the
prototype hand-waved — supervision, timing, hot reload, process
isolation, concurrency, governance — the library has since built for
other planes. This plane is the *thin, mostly Ring-side* act of
composing those existing parts under one contract. And because half the
Ring family (RingPad, RingServ, MicroRing, RingFlex, Ringua) needs the
same extension story without depending on Softanza, the plane's kernel
is written in **pure Ring over `ring_state_*` builtins only**, so any
family project can vendor it.

### Orientation — where everything is

| what | where |
|---|---|
| this plan | `libraries/stzlib/base/plugin/SOFTANZA_PLUGIN_PLAN.md` |
| legacy claims (read once, then only via §0.5) | `libraries/stzlib/max/test/stzPluginSystemTest.ring`, `stzStateSystemTest.ring` |
| the VM-state builtins (names only, no wrapper exists) | `base/common/stzFuncs.ring` ~265–278 (`ring_state_init/new/delete/runcode/runfile/findvar/setvar/…`) |
| the working state technique (2024, runs with a warning) | `max/test/stzStateSystemTest.ring` — note its live `Error (E3): Deleting scope while no scope!` |
| file watching (engine, libuv-free) | `base/file/stzFolderWatcher.ring` over `engine/stz_fswatch.ring` (250 ms snapshot diff) |
| process isolation, if a plugin asks for it | `base/cluster/stzNode.ring` (+ `stzNodePlane`, `stzNodeSupervisor`), `base/system/stzProcess.ring` `Spawn()` |
| async spawn/kill, timers | `base/reactive/stzReactor.ring` (`SubmitSpawn`/`SpawnAwait`/`SpawnKill`) |
| the skill contract a plugin can be lifted into | `base/agentic/stzAgentSkill.ring` (precondition + action + **verified effect**) |
| the supervision host | `base/agentic/stzAgentHost.ring` (`Name_()` + `Cycle()` = hostable) |
| the verdict contract | `base/graph/stzRuleReport.ring` (`[:rule,:subject,:where,:severity,:message]`) |
| monotonic clocks (the only clocks for durations) | `StzEngineWatchTimestamp*` (perf laws, CLAUDE.md) |
| guards (create) | `libraries/stzlib/base/test/plugin/` |
| project rules | `CLAUDE.md` at the repo root — READ IT |

### Commands

```bash
cd libraries/stzlib/base/test/plugin && ring plugin_kernel_narrated.ring
```

### The working discipline (non-negotiable)

1. **Measure before believing anything, including this plan.** PL0 is a
   measurement phase with kill criteria written before the numbers; §5
   records this plan's predictions so they can be scored.
2. **Guards are narrated and assert the MECHANISM**, and every positive
   has a negative sibling. This plane's canonical negative sibling is
   *contamination*: a plugin that clobbers `TRUE`, `NL`, or a host
   global must be shown NOT to affect the host — right beside the
   in-process demonstration of what unrestricted code *would* do.
3. **Kernel purity law** (this plane's own): everything under
   `base/plugin/kernel/` uses pure Ring + Ring builtins ONLY — no
   `Stz*`, no engine DLLs, no stzlib load. The PL5 guard executes the
   kernel under bare `ring` with stzlib off the path. Softanza faces
   wrap the kernel; they never reach into it.
4. **Engine-first where the engine already is.** This plane adds NO
   engine code: timing rides the watch clocks, watching rides
   `stz_fswatch`, processes ride the reactor/nodes. Ring-side
   orchestration is the *point* here (the kernel must be vendorable),
   not a violation.
5. **One lexicon.** The prototype's suffix zoo (`XfTMX`, `XffSZX`,
   `XfUP`…) is refused in writing (§2.2). Capabilities survive; the
   combinatorial naming does not.
6. **Parallel sessions work this repo**: `git add <explicit paths>`,
   never `-A`.
7. **Push protocol**: `git push origin main` then
   `git push codeberg HEAD:refs/heads/main`; verify both with
   `git ls-remote <remote> main` against `git rev-parse main`. If
   codeberg fails, say PENDING and move on.
8. **Record outcomes** in this file (`## PL<n> RESULTS`) and in memory
   (`project_plugin_plane.md`) when a phase ends.

### The first action

**PL0**, exactly as specified in §5: the VM-state physics spike.
Measurement only, no product code, kill criteria applied before the
numbers are interpreted.

---

## 0. THE SURVEY (taken 2026-08-16)

### 0.1 What the prototype actually is

`stzPluginSystemTest.ring` is a narrated design document wearing a test
file's clothes. It "calls" a complete API — discovery (`LoadPlugins`),
invocation (`Xf`/`Xff`/`XfU`), ledger (`XCalls`, `XfsZ`, `XErrors`,
`XSuccesses`, `XTime`), constrained calls (timed/sized/looped, eight
suffix spellings), caching, hot reload, pause/resume, delegated chains,
concurrency, transactions (`XfUB`), dependencies (`XLibsTree`),
versioning (`XfV`) — and **none of it exists**. Most sections carry
`#TODO Add this feature` inside comment blocks. Its sibling
`stzStateSystemTest.ring` is the one artifact that *ran*: two isolated
`ring_state_new()` states with per-state variables, fault-tolerant
execution of code strings, and a planned-but-never-written
`stzRingState` class. It also preserved a live VM warning
(`Error (E3): Deleting scope while no scope!`) that PL0 must
disposition.

**Verdict: a greenfield build with an unusually detailed acceptance
spec already written.** The same situation as the Tukey notes — and the
same rule applies: the prototype's hand-written outputs prove intent,
never behavior.

### 0.2 What the library gained since (build on it, do not rewrite it)

Every hard problem the prototype deferred now has a shipped owner:

| prototype hand-wave (2024) | shipped owner (2026) |
|---|---|
| "run in an isolated environment" | `ring_state_*` builtins (in-process); `stzNode` share-nothing OS processes with engine-backed bounded inboxes |
| "check plugin file changed at each call" | `stzFolderWatcher` / `stz_fswatch.dll` (libuv-free, 250 ms snapshot diff) |
| "profiling, execution time" | perf system's monotonic watch clocks + instruments (`Name_()`/`Cycle()` contract, well-known subjects) |
| "concurrent execution XfC" | reactor `SubmitSpawn`/await; cluster worker fleet (R8.3); node plane `Send`/`Ask` with mandatory timeouts |
| "pause/resume, lifecycle" | `stzAgentHost` supervision, `stzClusterSupervisor` restart/drain policies |
| "plugins as capabilities" | `stzAgentSkill` — precondition + action + **verified effect**, PI/LLM behind one interface |
| "robust conditional code" | `stzRuleReport` unified verdict shape, one CI gate |
| "prevent malicious plugins" (claim #5 in its own benefits list) | capability lattice (`stzSystemActor`, agent governance colouring) + R4b trust postures — *governance*, not sandboxing; §2.8 is honest about the difference |

### 0.3 What is genuinely missing (this is the work)

- Any wrapper over `ring_state_*` (`stzRingState` was planned, never
  written; `IsRingState()` is called by a test and defined nowhere).
- Discovery: a manifest convention readable **without executing** the
  plugin file.
- The one call verb with its ledger.
- Content-hash memoization for declared-pure plugins.
- The cooperative constraint API (the only honest way to cap an
  in-process call — see §2.3).
- The process tier: a plugin hosted on a `stzNode` when its manifest
  asks for real isolation.
- The vendorable kernel file the Ring family can adopt.

### 0.4 The cost this implies

**Zero new DLLs, zero vendored libraries, zero engine changes.** The
plane is ~4 Ring files plus guards, composing surfaces that already
exist. After Tukey, this is the cheapest plane on the board — and the
only one that pays dividends *outside* stzlib, across the whole Ring
family.

### 0.5 DISPOSITION OF THE LEGACY CLAIMS

| # | prototype claim | disposition |
|---|---|---|
| 1 | dynamic discovery from a `plugins/` folder | **ADOPT** — manifest header read textually, never executed at discovery (§2.5) |
| 2 | lazy execution: states created on first call | **ADOPT** |
| 3 | `XString` demo class; per-type X-classes by inheritance | **RESHAPE** — no parallel class tree; `Xf()` lands once on `stzObject`, every face inherits it (§2.6) |
| 4 | the `Xf()` / `Xff()` / `XfU()` verb trio | **ADOPT** — the entire public call surface (§2.2) |
| 5 | `XfU` returns 1/0 (unmanaged territory reports outcome) | **ADOPT** |
| 6 | suffix combinatorics: `XfTM/XfTMX/XfSZ/XfSX/XfL/XfLX/XffTMX/XfP/XfUP/XfUB/XfC/XfV` | **REFUSE the naming** — capabilities dispositioned individually below; expressed as options and manifest properties (§2.2) |
| 7 | TIMED call with graceful degradation (partial result at timeout) | **RESHAPE** — physically impossible preemptively in-process (§2.3); cooperative via the guard API, preemptive only at the process tier |
| 8 | SIZED call (byte cap) | **RESHAPE** — same physics, same answer |
| 9 | LOOPED call (iteration cap) | **ADOPT** — via the host-injected cooperative guard |
| 10 | the ledger: `XCalls`/`XFuncts`/`XfsZ`/`XErrors`/`XSuccesses`/`XTime` | **ADOPT** — timed by monotonic watch clocks; instrument names `plugin.call.ms`, `plugin.calls`, `plugin.errors` join the house's well-known subjects (§2.4) |
| 11 | memoize every call from the ledger | **RESHAPE** — only plugins whose manifest declares `@plugin_pure`; keyed by content hash + params (§2.7) |
| 12 | check file modification at each call | **ADOPT** — fswatch drain + hash confirm |
| 13 | hot reload: recreate state when file changed | **ADOPT** — this is the *only* hot-reload in the library and it is justified here: a plugin is the unit of change by definition. (The distribution plane's written refusal of hot *code* loading stands — that refusal is about cluster workers, not plugins.) |
| 14 | pause/resume of VM states | **RESHAPE** — "pause" = retain an idle state in the cache (which the cache does anyway); serializing a live Ring state to disk is REFUSED (no such VM facility; pretending otherwise is fiction) |
| 15 | delegated control flow: each plugin calls the next | **REFUSE** — the host never cedes control flow to third-party code; `Xf([...])` is a host-run fold (§2.9) |
| 16 | concurrent `XfC` | **RESHAPE** — in-process states share one thread, so real concurrency rides the process tier (reactor spawn / node plane), not states |
| 17 | transactional `XfUB` (all-or-nothing update chains) | **ADOPT** — host-side snapshot/rollback; Ring's copy-on-assign makes the snapshot one assignment (§2.9) |
| 18 | lifecycle history `XStatus`/`XStatusXT`/`XStatusXTT` | **RESHAPE** — the ledger + perf instruments already carry this; no parallel status vocabulary |
| 19 | dependency declaration `XLoadedLibs`/`XLibsTree` | **ADOPT** slim — manifest-declared loads, availability check before run; the tree is a graph-face view, not new machinery |
| 20 | versioning by filename suffix `_Vn` + compatibility table | **ADOPT** slim — manifest `@plugin_version`, `SetActiveVersion()`; the compatibility map lives in the system object, never a naked global |
| 21 | activation by `on_`/`off_` filename prefix | **ADOPT** — visible in a directory listing, no registry needed |
| 22 | "plugins cannot side-effect the main program" | **ADOPT as the plane's first law** — with §2.8's honest caveat about what isolation does and does not protect |

---

## 1. STRATEGIC PROPOSAL

### 1.1 The thesis

A plugin is **governed foreign capability**: code the host does not own,
executed under a contract the host enforces. The contract has five
clauses, and each maps to machinery that exists today:

1. **Isolation** — the plugin computes in its own world (VM state or OS
   process) and *returns values*; it never touches host state. Updates
   are the host's explicit, reversible act (`XfU`).
2. **Observation** — every call is ledgered (who, with what, outcome,
   duration) on monotonic clocks, flowing into the house perf subjects.
3. **Constraint** — budgets on iterations/time/size, cooperative
   in-process, preemptive cross-process, declared not hardcoded.
4. **Currency** — the file is the truth; change detection + hot reload
   keep the running state honest against the folder.
5. **Governance** — a trust posture decides which isolation tier a
   plugin may run in, and verdicts land in `stzRuleReport`.

### 1.2 Two audiences, one kernel

The Ring family now has seven-plus projects, several deliberately
independent of Softanza (RingServ, MicroRing, RingScript, RingPad).
Every one of them will need extensibility: RingPad's IDE extensions,
RingServ's service/route plugins, MicroRing's device capability packs,
RingFlex's workflow step providers, Ringua's per-language pragmatics.
Without a shared story each project will mint its own, and they will
drift — the family-level version of the duplicated-rule-lists lesson.

So the plane is layered:

- **`base/plugin/kernel/ringplug.ring`** — pure Ring + `ring_state_*`
  builtins. Discovery, manifest, state lifecycle, invocation, ledger
  rows. Vendorable by ANY family project by copying one file. Whether
  it becomes a named family artifact in its own repo is the author's
  product decision; the plan only guarantees it *could* be.
- **`base/plugin/` Softanza faces** — `stzPluginSystem` (entry object),
  `stzPlugin`, `Xf()` on `stzObject`, engine-clocked timing, fswatch
  currency, memoization, the process tier, skill lifting, rule-report
  verdicts. This layer may use everything Softanza has.

### 1.3 Why now, and why it is different from two years ago

In 2024 the prototype had to *imagine* supervision, timing, watching,
processes, and governance — so it wrote them as comments. In 2026 each
is a shipped, guarded subsystem, and the plugin plane reduces to its
actual novelty: the **VM-state wrapper, the manifest, the verb, and the
ledger**. The risk profile inverted: what was 90% unbuilt
infrastructure is now ~90% composition. The one genuinely unknown
quantity left is the physics of `ring_state_*` itself (creation cost,
error containment, the E3 warning) — which is exactly what PL0
measures before any product code is written.

### 1.4 What it unlocks

- The **wings revival**: `max/wings/` (dead, fully commented) becomes
  plugin folders instead of load-time code — the Max layer's original
  "pluggable capability" idea, honestly delivered.
- **Agent skills from files**: `stzPlugin.AsSkill()` lifts a plugin
  into the `stzAgentSkill` contract (precondition + verified effect),
  so agents gain capabilities by dropping files in a folder — under
  governance, not around it.
- **The family's one extension story** (§1.2).
- **A safe third-party seam** for the delivery plane: an appserver
  route or app behavior that customers extend without redeploying the
  host.

### 1.5 What this plane is not

Not a package manager, not a marketplace, not a security sandbox
(§2.8), not a code-signing scheme, and not a second skill system — a
plugin that wants agent semantics is *lifted into* `stzAgentSkill`,
never mirrored beside it.

---

## 2. DESIGN — the settled decisions

### 2.1 D1: isolation is a TIER, declared per plugin

Two tiers, both behind the same `Xf()`:

- **`:State`** (default) — a lazily-created, cached `ring_state` in the
  host process. Cheap, fast, same crash domain. Protects host *data*
  (separate globals, separate object space), not the host *process*.
- **`:Process`** — the plugin hosted behind a `stzNode` (or reactor
  spawn for one-shots). Survives plugin crashes, preemptively
  killable, genuinely concurrent. Costs process startup and
  serialization at the seam.

The manifest declares the tier; the host's trust posture (§2.8) may
*forbid* `:State` for untrusted sources but never silently changes a
declaration. The prototype conflated these two worlds; keeping them
distinct is what makes every capability below honest.

### 2.2 D2: three verbs, zero suffix combinatorics

The entire public call surface:

```ring
o1.Xf(:reverse)                          # compute → returns value
o1.Xf(:replace = ["Hello","World"])      # with params
o1.Xff(:mayFail)                         # fault-tolerant: error → ledger row, not raise
o1.XfU(:reverse)                         # apply result to the host object → 1/0
```

Everything the prototype spelled as a suffix becomes an options list or
a manifest property:

```ring
o1.Xf(:reverse, [ :MaxIterations = 99, :OnExceed = :Partial ])
o1.Xf(:crunch,  [ :MaxSeconds = 3 ])     # honest only at :Process tier — see D3
```

`Xf(aList)` runs a host-side pipeline (§2.9). `XfsZ()` keeps its name —
the `Z` suffix is house vocabulary for "with positions".

### 2.3 D3: the physics of interruption, stated once

`ring_state_runcode` executes **synchronously on the caller's thread**.
No mechanism exists to preempt it. Therefore, in writing:

- **In-process (`:State`) calls cannot be timed out or size-capped
  preemptively.** Claiming otherwise (as the prototype's `XfTM` did) is
  fiction. What IS honest in-process: the **cooperative guard** — the
  kernel injects a `PlugGuard(n)` function into the state; a
  well-behaved plugin calls it inside its loops; the guard raises (or
  returns a partial-result signal) past the budget. Graceful
  degradation exists exactly when the plugin cooperates.
- **Preemptive budgets live at the `:Process` tier**, where the reactor
  can `SpawnKill` past a deadline. A plugin whose manifest wants
  `:MaxSeconds` enforced against hostile code must declare `:Process`.

### 2.4 D4: the ledger is house-shaped

One row per call: `[ name, params, ok, output-or-error, ms ]` — the
prototype's shape, kept — timed by `StzEngineWatchTimestamp*` (never
wall clocks). Aggregates (`XCalls()`, `XErrors()`, `XSuccesses()`,
`XfsZ()`, `XTime()`) read the ledger; none maintain parallel state.
The Softanza layer additionally feeds the standard instruments —
`plugin.call.ms`, `plugin.calls`, `plugin.errors` — joining
`http.request.ms` in the well-known-subjects list. Anything
check-shaped (a plugin failed validation, a version conflict) is
emitted in the unified rule shape to `stzRuleReport`. In the kernel,
the ledger is a plain list on the system object; no naked globals.

### 2.5 D5: the manifest is read, never run

Discovery parses the plugin file's header **textually** — executing
arbitrary files at scan time would make discovery itself an attack.
Format (the plane's data format, per the domain law):

```ring
#< ring_plugin_file #>
@plugin_name    = "reverse"
@plugin_desc    = "Reverses a string, Unicode-aware"
@plugin_tier    = :State          # or :Process
@plugin_pure    = 1               # memoizable (default 0)
@plugin_loads   = []              # Ring libs the body will load
@plugin_version = 1

func pluginFunc(value, aParams)
	# ... body, executed only inside the plugin's own state ...
```

Filename convention (adopted from the prototype): `plugin_<host>_<name>.ring`,
`on_`/`off_` activation prefixes, `_Vn` version suffixes allowed beside
the manifest's `@plugin_version` (the manifest wins on conflict, and the
conflict is a rule-report finding).

### 2.6 D6: `Xf()` lands once, on `stzObject`

No `XString`, no per-type X-classes. `stzObject` gains `Xf/Xff/XfU`,
delegating to the default `stzPluginSystem` instance with `This.Content()`
as the plugin's `value`. Every Softanza face inherits the capability;
the default-instance-behind-sugar pattern follows the domain law
(globals only as sugar over a default instance). Kernel users without
Softanza call the system object directly:
`oPlugs.Call("reverse", cValue, aParams)`.

### 2.7 D7: memoization is consent-based and content-hash-keyed

Only plugins declaring `@plugin_pure = 1` are memoized. The key is
`hash(plugin file bytes) + params + value`; a changed file misses by
construction, so the cache can never serve a stale version — this
replaces the prototype's "check then serve" dance with an invariant.
Impure plugins always execute. (Precedent: content-hash memoization is
already canon for LLM functions in the intelligence architecture.)

### 2.8 D8: governance yes, sandbox no — in writing

A `:State` plugin runs in the host process with the full Ring builtin
surface: it can open files, spawn processes, allocate unboundedly.
State isolation protects the host's *data structures*, not the machine.
The plane therefore:

- attaches a **trust posture** (`:Trusted` / `:External` / `:Sandboxed`,
  the R4b vocabulary) to each plugin source folder;
- lets the posture gate the tier (`:Sandboxed` ⇒ `:Process` only,
  where the OS boundary is real);
- **refuses to advertise sandboxing it does not have.** Claim #5 of
  the prototype's benefits list ("resilient to malicious plugins") is
  reduced to what is true: resilient to *buggy* plugins, governed
  against *declared* capabilities.

### 2.9 D9: the host owns control flow, updates, and rollback

- `Xf([f1, f2 = [params], f3])` is a **host-run fold**: the host feeds
  each result to the next call. Plugins never learn what runs after
  them (refusal #15) — same posture as `stzComputePipeline`.
- `XfU` with a list is **transactional by snapshot**: `_snapshot_ = @content`
  before the fold, restore on any failure, report per-step outcomes.
  Ring's copy-on-assign makes the snapshot a single assignment — the
  rare place that semantic quirk is an asset.

### 2.10 D10: the class list

| class | layer | role |
|---|---|---|
| `ringplug.ring` (functions + one `PlugSystem` class) | kernel | discovery, manifest parse, state lifecycle, `Call`, ledger |
| `stzRingState` | kernel→face seam | the wrapper the 2024 test promised: `New/RunCode/RunFile/Var/SetVar/Delete`, E3-safe teardown |
| `stzPlugin` | face | one plugin: manifest, tier, posture, versions, `AsSkill()` |
| `stzPluginSystem` | face | entry object: folders, discovery, `Call`, ledger faces, memo, fswatch currency, default instance |
| (extension) `stzObject.Xf/Xff/XfU` | face | §2.6 |

Domain folder: `base/plugin/`. Loaded from `base/stzBase.ring` beside
reactive/cluster/agentic. The Max layer keeps nothing: this plane is
base-level, and `max/wings/` becomes its future *consumer*, not its home.

---

## 3. KERNEL DESIGN (the vendorable file)

`base/plugin/kernel/ringplug.ring`, single file, target under ~500
lines. Contents in dependency order:

1. **Manifest reader** — line-oriented parse of `@plugin_*` headers;
   stops at the first non-comment, non-`@` line; never `eval`s.
2. **Discovery** — `dir()` scan honoring `on_`/`off_`, building the
   plugin table `[ name, file, manifest ]`. (Known trap: Ring's `dir()`
   mangles non-ASCII names — the file-module seam memory; plugin
   filenames are ASCII by convention, and the guard says so.)
3. **State lifecycle** — create on first call (`ring_state_new` +
   `runfile`), cache per plugin, recreate on detected change, delete on
   retire. The E3 finding from PL0 is encoded here, whatever it is.
4. **Call** — set params via `ring_state_setvar` (or a generated
   prelude if setvar proves unreliable in PL0), invoke, read result via
   `ring_state_findvar`, ledger the row. Fault-tolerant variant wraps
   in `try/catch`.
5. **Cooperative guard** — `PlugGuard(...)` injected into every state.
6. **Ledger** — rows + the aggregate readers.

Change detection in the kernel is mtime+size (pure Ring); the Softanza
face upgrades it to fswatch + content hash. Timing in the kernel is
`clock()`-based and labeled approximate; the face swaps in monotonic
engine clocks. Both upgrades are *substitutions the face performs*,
not forks of kernel logic.

---

## 4. THE RING SURFACE (illustrative — not yet run)

```ring
# The system, explicit form
oPlugs = new stzPluginSystem("plugins/")
? oPlugs.Plugins()
#--> [ "countvowels", "removenonletters", "reverse", "replace" ]

# The sugar, on any Softanza object
o1 = new stzString("Hello Ring in Ring!")
? o1.Xf(:reverse)                        #--> "!gniR ni gniR olleH"
? o1.Content()                           # unchanged — isolation law
? o1.XfU(:reverse)                       #--> 1, and o1 is now reversed

# Constraint, cooperative
? o1.Xf(:reverse, [ :MaxIterations = 99, :OnExceed = :Partial ])

# Pipeline + transaction
? o1.XfU([ :removeNonLetters, :replace = ["Ring","Zig"], :reverse ])
#--> 1 only if all three succeeded; o1 untouched otherwise

# The ledger
? @@NL( o1.XCalls() )
# [ [ "reverse", [], 1, "!gniR...", 0.0004 ], ... ]

# Governance
oPlugs.SetPosture("plugins/community/", :Sandboxed)   # ⇒ :Process tier enforced
```

---

## 5. IMPLEMENTATION PLAN — phases and kill criteria

Predictions are recorded here, before any measurement, so they can be
scored the way the GPU and graphics plans were.

### PL0 — VM-state physics (measurement only, no product code)

One throwaway spike file per question, run on Ring 1.25 (the repo's
pinned VM) and Windows first:

1. `ring_state_new()+runfile` cost for a small plugin file, and
   per-call cost of setvar→runcode→findvar on a warm state.
2. Reuse: 1,000 calls on one cached state — memory growth, correctness.
3. Containment: a plugin that raises; a plugin that clobbers `TRUE`,
   `NL`, and a host-named global; a plugin that recurses to stack
   overflow. Which of these does the host survive?
4. The `E3: Deleting scope while no scope!` warning — reproduce,
   determine trigger, decide the teardown discipline. If it is a VM
   defect, file it through the Ring Upstream session.
5. `ring_state_setvar` fidelity for lists / nested lists / Unicode
   strings across the state boundary.
6. mtime+size vs content-hash change detection cost on a plugin-sized
   file.

**Kill criteria (written before the numbers):**
- If a *raised error* inside a state corrupts or kills the host →
  the `:State` tier is REFUSED entirely and the plane becomes
  process-only (it survives, but §2.1 is rewritten).
- If state creation exceeds 100 ms → lazy creation is not enough;
  add explicit prewarming to PL1's scope.
- If setvar/findvar cannot round-trip nested lists + Unicode → params
  cross as serialized text (the kernel already plans the prelude
  fallback).

**Predictions:** state creation in single-digit ms; warm-call overhead
under 1 ms; raised errors contained; stack overflow NOT contained
(process tier exists for that); clobbered `TRUE`/`NL` in a state do not
leak to the host (separate global scope is the entire point of states —
if this fails, the tier fails criterion 1).

### PL1 — The kernel (`ringplug.ring` + `stzRingState`)

Discovery, manifest, lifecycle, `Call`, `Xff` semantics, ledger.
Guard: `plugin_kernel_narrated.ring` with the three prototype plugins
(reverse / countVowels / replace) **actually written and actually run**
— the first time any of the 2024 outputs become real. Negative
siblings: missing plugin, syntactically broken plugin, manifest/filename
version conflict, the contamination test (§ discipline 2).

### PL2 — Softanza faces + currency + memoization

`stzPlugin`, `stzPluginSystem`, `Xf/Xff/XfU` on `stzObject`, monotonic
timing, perf instruments, fswatch-driven reload, pure-plugin memo.
Guard mechanism assertions: memo hit proven by a state-execution
counter (not by timing); file edit between calls proven to re-execute
by *changed output*, not by belief in the watcher.

### PL3 — Constraints

The cooperative guard end-to-end (`:MaxIterations`, `:OnExceed =
:Partial|:Raise`), option-list plumbing, honest refusal errors when a
`:State` plugin requests preemptive `:MaxSeconds` (the error message
names §2.3 and the fix: declare `:Process`).

### PL4 — The process tier

A `:Process` plugin hosted per §2.1: one-shot via reactor spawn-await
with `SpawnKill` deadline enforcement; resident via `stzNode` + `Ask`
with mandatory timeout. Concurrent `Xf` across plugins. Transactional
`XfU` folds. Guard includes killing a deliberately-hung plugin and
watching the host continue — the capability the prototype could only
promise.

### PL5 — Governance, versions, the skill bridge, vendorability

Postures gating tiers; `@plugin_version` + `SetActiveVersion`;
`AsSkill()` lifting a plugin into `stzAgentSkill` (its `SetVerifiedBy`
becomes the plugin's declared postcondition); rule-report findings for
every refusal the system makes. **The vendorability guard**: copy
`ringplug.ring` alone to a scratch dir, run its guard under bare `ring`
with stzlib absent from the path — pure-Ring purity proven by
execution, not review.

### Sequencing

PL0 → PL1 → PL2 → PL3 and PL4 in either order → PL5. Each phase ends
with its guard green, results appended to this file, memory updated,
both remotes pushed.

---

## 6. VERIFICATION METHOD

Expectations here are behavioral, not numeric, so the promises-harness
lesson applies with full force: **no hand-written output is evidence**.
Every guard assertion must be produced by running code, and the
mechanism — not the surface — is what gets asserted:

- Isolation: assert the host global **did not change** after a plugin
  deliberately clobbers it; the negative sibling runs the same
  clobbering code in-process and shows it *would* have.
- Memoization: assert the execution **counter**, not the duration.
- Reload: assert the **changed output** after a file edit, not the
  watcher's event list.
- Timeout (process tier): assert the host's **liveness** and the
  ledger's error row after killing a hung plugin.
- Timing rows: BAND assertions from measurement, monotonic clocks only
  (the timing-assertions reference).

Guards live in `base/test/plugin/`, narrated style, run from inside
their directory per the sensitive-test rules.

---

## 7. RISKS AND STANDING REFUSALS

**Risks, named now:**

1. `ring_state_*` is the least-exercised corner of the Ring C surface
   in this repo — PL0 exists because the E3 warning says the corner
   has sharp edges. The plan survives a total `:State` failure
   (process-only fallback), but loses its cheapness.
2. Serialization at the process seam (params/results as text) may
   dominate `:Process` call cost — measured in PL4, and the Ringine
   seam numbers (list-returning calls cost 750 ns fixed + 120 ns per
   handle) already warn that *delivery is dear*.
3. Family adoption is a bet, not a fact: the kernel being vendorable
   does not make anyone vendor it. Mitigation: RingPad (an IDE that
   *needs* extensions to exist) is the natural first adopter to
   propose.

**Refused, in writing (any phase that starts needing one of these is
out of scope by definition):**

- Preemptive interruption of in-process calls (§2.3 — fiction).
- Serializing/persisting a live Ring VM state (§0.5 #14 — fiction).
- Plugin-driven control flow (§2.9 — the host never cedes the wheel).
- The suffix-combinatorics API (§2.2 — one lexicon).
- Security-sandbox claims for the `:State` tier (§2.8 — honesty).
- Memoizing undeclared plugins (§2.7 — consent-based only).
- A plugin marketplace, registry service, or signing scheme (v1 scope).
- A second skill system beside `stzAgentSkill` (§1.5 — lift, don't mirror).

---

## 8. INTERFACES WITH THE OTHER PLANES

- **Agentic**: `AsSkill()` (§PL5) — plugins become verified agent
  capabilities; `stzPluginSystem` is hostable (`Name_()`/`Cycle()`) so
  a supervisor can tick its currency checks.
- **Perf**: instruments `plugin.call.ms`/`plugin.calls`/`plugin.errors`
  join the well-known subjects; ledger timing on watch clocks.
- **Cluster/distribution**: the `:Process` tier is a *consumer* of
  nodes and the reactor; it adds no topology of its own.
- **Rule graph**: admission refusals, version conflicts, posture
  violations → `stzRuleReport`, the one CI gate.
- **Delivery plane**: appserver extension points (routes, request
  transforms) as plugin folders — future consumer, not v1 scope.
- **The Ring family**: the kernel file is the offer (§1.2). RingScript
  needs its own feasibility check (`ring_state_*` under WASM is
  unverified) — flagged, not assumed.
- **Ring Upstream**: any VM defect PL0 finds (the E3 warning) gets a
  minimal repro and a PR through the upstream session.

---

## 9. LEGACY DOCUMENT DISPOSITION

- `max/test/stzPluginSystemTest.ring` — header a SUPERSEDED notice
  pointing here; the file stays as the intent record. Its runnable
  claims become PL1's guard, for real this time.
- `max/test/stzStateSystemTest.ring` — same notice; its two-state
  technique is PL0's starting point; its promised `stzRingState` is
  PL1's deliverable; its `IsRingState()`/`AreRingStates()` calls (defined
  nowhere) become real predicates in PL1.
- `max/wings/stzWings.ring` — untouched now; named in §1.4 as the
  future consumer that makes the Max layer's original idea honest.
