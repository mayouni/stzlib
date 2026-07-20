# The Softanza Virtual System Framework
### A Requirements Narration and Architectural Reference
*Version 1.2 — Abstract Foundation, File Domain Specialization, and the twin's
second job (foreign-system rehearsal). See `SOFTANZA_SYSTEM_FOUNDATION.md` §2 and
`SCOPE_ORIENTED_PROGRAMMING.md` (move M5) for how the System Foundation binds to
this framework.*

---

## 1. Vision

Unmanaged systems — file systems, databases, GUIs, networks — share a defining trait: **operations on them are immediate and consequential**. A deleted file is gone. A dropped table is dropped. This immediacy forces programmers into a defensive posture: cautious, slow, fearful of experimentation.

The Virtual System Framework inverts this. Every unmanaged system gains a **virtual twin** — a complete, in-memory rehearsal space where any operation can be tried, undone, branched, and compared, at zero risk. When the practitioner is satisfied, a **workbox** compares the virtual result against the constraints of reality and produces a narrated, optimized, inspectable **update plan**. Reality changes only when that plan is deliberately executed.

Three words summarize the promise: **rehearse, plan, commit.**

**The twin has a second job, and it is just as important as the first.** The
first inversion makes a *dangerous* operation safe — rehearse the delete before
you commit it. The second makes an *impossible* operation *developable*: a twin
can model a system the practitioner's own machine **is not**. A developer on a
Windows laptop can rehearse GPIO writes against a twin of an ESP32, or a
permission-sandboxed file operation against a twin of Android — neither of which
the laptop can perform — then let the deploy step lower the rehearsal onto the
real target. So the twin is not only "reality, made safe to touch"; it is also
**"a foreign system, made present to a host that isn't it."** This is what lets
Softanza help a developer *build for a world they cannot run* (the System
Foundation's "two worlds," and move M5 of Scope-Oriented Programming). The two
jobs share one mechanism: an in-memory model plus a single governed crossing.

## 2. Foundational Principles

**P1 — Safety by Construction.** The virtual layer holds no reference to reality. Nothing done inside it can affect the real system. Safety is architectural, not procedural.

**P2 — Intent over Mechanics.** APIs express what the practitioner means (`CreateFolder`, `MoveFile`), never C-style modes and flags. This continues the established Softanza file API philosophy.

**P3 — Total Recall.** Every operation is recorded. History, snapshots, and rollback are not features bolted on; they are the natural consequence of operations being first-class objects.

**P4 — Narrated Transition.** The passage from virtual to real is never silent. Plans explain themselves: what will happen, in what order, at what risk, with what alternatives.

**P5 — Actor Neutrality.** The virtual system does not know or care *who* operates it — a human at a keyboard, a deterministic script, or an autonomous agent. All actors use the same operations, produce the same history, and are subject to the same boundary: only plans cross into reality.

**P6 — Separated Powers.** The capacity to *imagine* change (virtual operations) and the authority to *enact* change (plan execution) are distinct capabilities that may be held by different actors. By default, no actor holds both.

*P5 and P6 are what make the framework future-proof for programmatic and agentic actors without any change to its core design. They cost nothing today and buy everything tomorrow.*

## 3. The Three-Layer Architecture

```
┌─────────────────────────────────────────────┐
│  LAYER 1 — VIRTUAL SYSTEM (the workbench)   │
│  In-memory twin · operations · snapshots ·  │
│  history · branches · rollback              │
└──────────────────┬──────────────────────────┘
                   │  virtual state
┌──────────────────▼──────────────────────────┐
│  LAYER 2 — WORKBOX (the analyst)            │
│  Reads reality (read-only) · diffs virtual  │
│  vs real · detects conflicts & constraints  │
│  · produces narrated, optimized UpdatePlan  │
└──────────────────┬──────────────────────────┘
                   │  update plan (the ONLY
                   │  artifact that crosses)
┌──────────────────▼──────────────────────────┐
│  LAYER 3 — REALITY BRIDGE (the executor)    │
│  Transactional execution · progress ·       │
│  failure recovery · post-verification       │
└─────────────────────────────────────────────┘
```

The **update plan is the sole crossing point** between imagination and reality. This single design decision yields safety, auditability, and — later — a clean trust boundary for non-human actors.

## 4. Abstract Foundation

### 4.1 stzVirtualSystem — the root abstraction

```ring
class stzVirtualSystem
    # --- State ---
    @oState              # domain-specific virtual state
    @aHistory            # ordered list of stzVirtualOperation
    @aSnapshots          # named savepoints
    @aBranches           # parallel hypotheses from a snapshot

    # --- Rehearsal ---
    def ExecuteOperation(oOperation)
    def UndoLast(n)
    def RollbackOperation(cOperationId)

    # --- Memory ---
    def CreateSnapshot(cName)
    def RollbackTo(cSnapshotName)
    def BranchFrom(cSnapshotName, cBranchName)
    def CompareBranches(aBranchNames)
    def ShowHistory()

    # --- Transition ---
    def MirrorFrom(pRealTarget)        # read-only import of reality
    def GenerateUpdatePlan()           # → stzUpdatePlan
```

### 4.2 stzVirtualOperation — change as a first-class object

```ring
class stzVirtualOperation
    @cOperationId
    @cType               # created / modified / deleted / moved ...
    @aParams
    @oBeforeState        # or delta, for efficiency
    @oAfterState
    @cActor              # who proposed it (human / script / agent id)
    @cIntent             # optional natural-language rationale

    def Execute(oVirtualSystem)
    def Rollback(oVirtualSystem)
    def Describe()       # human-readable narration
    def Impact()         # what it touches
```

Note `@cActor` and `@cIntent`: two small fields, present from day one, that make history equally legible whether the operations came from a person or a program.

### 4.3 stzUpdatePlan — the crossing artifact

```ring
class stzUpdatePlan
    def ShowNarration()          # plain-language story of the change
    def ShowRisks()              # ranked risk assessment
    def ShowAlternatives()
    def Validate()               # re-check against current reality
    def RejectOperation(n, cBecause)   # annotate / prune before commit
    def Feedback()               # objections & annotations, structured
    def Execute()                # transactional, via reality bridge
    def ExecuteStepByStep()      # manual, confirmed per operation
```

`RejectOperation` / `Feedback` make the plan a *reviewable and revisable* object, not a take-it-or-leave-it script. A reviewer — of any kind — can prune, annotate, and send objections back to whoever (or whatever) is operating the workbench, which then revises and regenerates. The plan is thus a medium of iteration, not just a preview.

### 4.4 iRealityBridge — the domain connector

```ring
interface iRealityBridge
    def CurrentRealityState()          # read-only observation
    def Constraints()                  # permissions, quotas, naming rules
    def Capabilities()
    def ValidatePlan(oUpdatePlan)
    def ExecutePlan(oUpdatePlan)       # transactional where possible
    def VerifyOutcome(oUpdatePlan)     # post-execution audit
```

### 4.5 Execution scopes

Because execution authority is separable (P6), the bridge accepts an optional scope:

```ring
class stzCommitScope
    @aAllowedPaths       # e.g. only under "project/generated/"
    @aAllowedTypes       # e.g. create-only, never delete
    @nMaxOperations
```

A human typically executes with an unlimited scope. A script or agent executes — if permitted at all — only within a declared, auditable scope. Same mechanism, different trust levels. Nothing else in the framework changes.

## 5. First Specialization: The File Domain

### 5.1 Class family

```ring
stzVirtualFileSystem : stzVirtualSystem     # whole-tree workbench
stzVirtualFolder                            # scoped view on a subtree
stzVirtualFile                              # single-file rehearsal
stzFileSystemBridge : iRealityBridge        # the real-world connector
```

`stzVirtualFile` and `stzVirtualFolder` mirror the intent-based surface of the existing `stzFile` / `stzFolder`, keeping one mental model across real and virtual variants. The rule of thumb: **the virtual class has every method the real class has, plus the rehearsal verbs (snapshot, rollback, branch, plan).**

### 5.2 Virtual state: the file tree

```ring
class stzFileTree
    # nodes: { type, name, content?, size, attributes,
    #          created_in_session?, origin: mirrored|virtual }
    def NodeAt(cPath)
    def Diff(oOtherTree)
    def Validate()       # duplicate names, illegal chars, path depth
```

The `origin` field distinguishes what was **mirrored from reality** from what was **born in the workbench** — essential for the workbox diff.

### 5.3 File operations catalog

Creation: `CreateFile`, `CreateFolder`, `CreateFileWithContent`
Mutation: `WriteFile`, `AppendToFile`, `SetAttributes`, `Rename`
Structure: `MoveFile`, `MoveFolder`, `CopyFile`, `CopyFolder`
Removal: `DeleteFile`, `DeleteFolder`
Inspection (free, unrecorded): `Exists`, `SizeOf`, `ContentOf`, `TreeView`

### 5.4 The file workbox

The `stzFileSystemBridge` analysis covers, at minimum:

1. **Existence conflicts** — virtual creation vs real presence
2. **Divergence** — mirrored files modified in reality since mirroring (the plan must flag stale assumptions)
3. **Permissions** — writability of each touched location
4. **Platform constraints** — path length, reserved names, illegal characters, case sensitivity
5. **Capacity** — disk space vs planned content size
6. **Ordering** — dependency-sorting operations (parents before children, moves before deletes) and **coalescing** (create-then-rename becomes create-with-final-name)

### 5.5 Canonical usage

```ring
vfs = new stzVirtualFileSystem()
vfs.MirrorFrom("C:/my_project")
vfs.CreateSnapshot("as_found")

# Rehearse freely
vfs.CreateFolder("src")
vfs.MoveFile("main.ring", "src/main.ring")
vfs.CreateFolder("tests")
vfs.CreateFileWithContent("tests/main_test.ring", "load 'src/main.ring'")

# Second thoughts? Branch and compare
vfs.BranchFrom("as_found", "flat_layout")
# ... alternative arrangement ...
vfs.CompareBranches(["main", "flat_layout"])

# Transition
oPlan = vfs.GenerateUpdatePlan()
oPlan.ShowNarration()
oPlan.ShowRisks()
oPlan.Execute()          # or ExecuteStepByStep()
```

## 6. Extensibility Map

The abstract foundation specializes along three independent axes:

**Domain axis** (what *kind* of system the twin models): files *(this document)* → databases → GUI → configuration → network. Each requires only a state class, an operation catalog, and a reality bridge.

**Actor axis** (who operates the workbench): human programmers *(this document's primary audience)* → deterministic scripts → autonomous agents. Each requires only an actor identity on operations and, where execution is delegated, a commit scope. The framework itself is already actor-complete by P5/P6; the agentic actor is elaborated in a companion article and will feed back into a future revision as a formal Layer-4 specification.

**Target axis** (which *concrete* system the twin stands in for — the second job from §1): same-as-host → a foreign system the host *can* still emulate → a foreign system the host *cannot* perform at all (an MCU's GPIO, a phone's sandbox). This axis governs the reality bridge's dual mode: when the target *is* the host, the bridge reads and commits against the real system directly; when the target is *foreign*, the bridge's `Capabilities()` and `Constraints()` come from the target's `stzSystemProfile` (not the host's), execution against reality is deferred to a **deploy-time crossing** (cross-compile / flash / push), and the twin is the only place the operation exists until then. Nothing in the abstract foundation changes — only where the bridge's reality *is*. This is the axis the System Foundation's scope model (`SOFTANZA_SYSTEM_FOUNDATION.md` §2) rides to let a developer rehearse, on their own machine, operations their machine cannot run.

## 7. Implementation Roadmap (File Domain)

- **Phase 1 (wk 1–3):** `stzVirtualOperation`, `stzFileTree`, core create/write/delete/move, history + undo.
- **Phase 2 (wk 4–6):** Snapshots, rollback-to, branching, branch comparison.
- **Phase 3 (wk 7–9):** `stzFileSystemBridge` — mirroring, constraint analysis, plan generation with narration, risks, ordering/coalescing.
- **Phase 4 (wk 10–12):** Transactional execution, step-by-step mode, post-verification, `stzCommitScope`, polish and documentation.

## 8. Quality Requirements

- **Fidelity:** virtual semantics must match real semantics exactly (path rules, name collisions, case behavior per platform).
- **Performance:** copy-on-write snapshots; deltas over full copies; mirroring must be lazy for large trees.
- **Honesty:** the plan must re-validate at execute time; reality may have moved since analysis.
- **Legibility:** every narration readable by a non-programmer domain expert — a Softanza signature.