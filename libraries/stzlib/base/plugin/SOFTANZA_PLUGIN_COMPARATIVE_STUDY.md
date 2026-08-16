# SOFTANZA PLUGIN COMPARATIVE STUDY

Status: **ANALYSIS, not rules** — written 2026-08-16 beside
`SOFTANZA_PLUGIN_PLAN.md`. Every normative decision (design rulings,
adoptions, refusals, phases) lives ONLY in the plan; this document
carries the comparative reasoning behind plan §9 and the D-rulings, so
the plan does not bloat and the analysis does not drift into a second
rule list. If a sentence here ever contradicts the plan, the plan wins.

Provenance of claims: the Softanza column is measured (this repo,
2026-08-16, Ring 1.27 — see plan §0.6). The `cordiverse/paper`
material was read 2026-08-16 from the repository's abstract and
README ("A Programming Paradigm for Spatiotemporal Composability",
preprint 2026-08-13). The mainstream-system profiles are
characterizations from general knowledge of those systems as of
early 2026 — they describe architecture, and cite no numbers, because
we measured none of them.

---

## 1. THE SUBJECT, AND THE AXES

The subject is the Softanza plugin plane: a plugin is **governed
foreign capability** under five contract clauses — isolation,
observation, constraint, currency, governance (plan §1.1) — invoked
through one verb family (`Xf`), computing in an isolated Ring VM
state (or OS process), returning values, never touching host state
except through the explicit, journaled `XfU` seam.

Six axes separate plugin architectures. They are chosen so that every
system below can be placed honestly on each:

1. **Authority direction** — does the host hand the plugin an API to
   reach INTO the program, or hand it a VALUE and take a value back?
2. **Isolation unit** — nothing / in-process VM state / whole process.
3. **Effect model** — ambient (plugin just does things), disciplined
   (effects promised through an API the runtime can see), or physical
   (ambient host effects impossible by construction).
4. **Observability** — what the host can say afterwards about who ran,
   with what, how long, and what failed.
5. **Currency** — how the running system tracks the plugin's source
   changing under it.
6. **Ceremony** — the distance between "code exists" and "code runs":
   packaging, manifests, marketplaces, signing, build steps.

The agentic era adds a seventh axis, and §6 argues it is now the
sorting axis of the whole field:

7. **Agent-authorability** — how safe it is for a MODEL to write the
   extension, and how much of the containment is structural rather
   than reviewed.

## 2. THE MAINSTREAM FIELD

### 2.1 Hook/filter systems — WordPress, Emacs, Neovim

The oldest and largest lineage. The host enumerates extension points
(hooks, advice, autocmds); plugins register callbacks that run
**in-process, with the host's full authority, on the host's own
data**. Authority direction: fully inverted into the plugin. Isolation:
none — one defective plugin corrupts or crashes the site/editor.
Effects: ambient. Observability: essentially none per-call.
Ceremony: low (drop a file), which is why the lineage thrives despite
everything else. The lesson the field learned from it: extensibility
without isolation scales socially (enormous ecosystems) and fails
technically (the "which plugin broke my site" ritual).

### 2.2 Component platforms — Eclipse/OSGi

Versioned bundles, classloader isolation, a service registry,
declared dependencies with resolution. The most serious pre-agentic
attempt at spatial composability: dependencies are first-class and
the platform reasons about them. But effects are still ambient inside
a shared JVM, unloading a bundle famously does NOT revert what it did
(classloader leaks were a decade-long bug genre), and the ceremony is
maximal — manifests, versioning discipline, tooling. The lesson:
declared dependencies are load-bearing; revert-by-unload is a promise
a shared runtime cannot keep.

### 2.3 Extension-host processes — VS Code

All extensions run in one separate extension-host process, talking to
the editor over RPC against a curated API surface. Isolation protects
the EDITOR (renderer) from extensions, not extensions from each
other. Authority direction: still API-injection — the `vscode` module
reaches into the program, capability-broad. Observability: activation
events and profiling exist, but no per-call ledger a user program can
query. Ceremony: marketplace, manifest, packaging. The lesson: paying
one process for the whole extension population is a workable middle
price, and activation-event manifests (declared "when do I wake")
are a good idea our `@plugin_*` header family echoes.

### 2.4 Permissioned sandboxes — browser WebExtensions

The strongest mainstream GOVERNANCE story: a manifest declares
permissions, the user grants them, the runtime enforces them; content
scripts run in isolated worlds; processes isolate the rest. This is
the field's proof that **declared capability + admission gate** works
at population scale (hundreds of millions of users). Its cost is a
fixed, browser-shaped API surface — it extends one host, not any
object. Our trust postures (plan D8) are this idea with the honesty
dial: we gate the ISOLATION TIER rather than pretending to enforce
fine-grained permissions we do not have.

### 2.5 Embedded scripting states — game-engine Lua

The nearest structural cousin of our `:State` tier, decades old:
`lua_newstate` per subsystem, host-curated stdlib, values marshalled
across the C seam. Games proved the tier's economics (thousands of
scripted entities) and its physics: a Lua state cannot be preempted
from its own thread either — engines use instruction-count hooks,
which is exactly our cooperative `PlugGuard` (plan D3), arrived at
independently. The difference: game engines curate what the state can
SEE (sandboxed stdlib); Ring states expose the full builtin surface,
which is why plan §2.8 refuses sandbox claims where Lua embeddings
can sometimes make them.

### 2.6 Edge isolates — V8 isolates / Cloudflare Workers

The industrial validation of **in-process isolation as a product
tier**: thousands of tenants per process, microsecond-class starts,
no ambient authority — capability arrives only through handed-in
bindings. This is our `:State` tier's lineage at hyperscale, and the
strongest evidence that the middle tier (cheaper than a process,
stronger than a hook) is where the industry landed. Difference of
substance: V8 isolates were hardened against hostile tenants by a
browser's security budget; Ring states were not, which is again why
D8 words governance the way it does.

### 2.7 The WASM component model

The standards convergence on **value seams**: components exchange
typed values through interfaces; no ambient imports; capabilities are
explicitly granted; linking is declarative. Everything crosses as
data. This is the same seam shape as `Xf(value) → value` with the
manifest as the interface declaration — reached by a standards body
for the same reason we reached it: it is the only seam shape you can
reason about after the fact.

### 2.8 Agent tools — MCP and the LLM tool-call convention

The agentic-era mainstream: capabilities are out-of-process servers
described by typed manifests, invoked as pure request/response calls,
composed by a model. Note what the convention quietly conceded: no
ambient authority, values across the seam, per-call logging,
manifest-gated admission — the hook lineage's inverted authority is
GONE. The field, forced to let models drive, converged on the same
properties our 2024 file already had. What MCP does not give the tool
author: revertible commitments, dependency-aware caching, or a host
object to update under transaction — the places plan §9's adoptions
go further.

## 3. THE PROPERTY MATRIX

| axis | hooks (WP/Emacs) | OSGi | VS Code | WebExt | Lua embed | V8 isolates | WASM comp. | MCP tools | **Softanza plane** |
|---|---|---|---|---|---|---|---|---|---|
| authority direction | into host | into JVM | into API | into API (permissioned) | curated | bindings only | values | values | **values** |
| isolation unit | none | classloader | one process for all | worlds + process | VM state | isolate | sandbox | process | **VM state OR process, declared** |
| effect model | ambient | ambient | ambient via API | permissioned | curated ambient | capability | physical | request/response | **physical (host) + governed (world)** |
| per-call audit | no | no | partial | partial | host's job | platform logs | host's job | logs | **ledger on the verb** (params, outcome, ms, author) |
| currency | reload host | bundle lifecycle | reload host | store updates | host's job | deploy | deploy | server restart | **fswatch + content hash, per plugin** |
| effect reversal | no | claimed, leaks | no | no | no | n/a | no | no | **XfU journaled + XRevert (plan §9 A1)** |
| ceremony | file | high | marketplace | store + review | file | deploy pipeline | toolchain | server + config | **file + textual manifest** |
| agent-authorability | dangerous | dangerous | reviewed | reviewed | curated | strong | strong | strong | **strong + provenance + revert** |

Two readings of the matrix:

- Column-wise, the field splits into the **hook lineage** (authority
  inverted into the plugin; social success, technical debt) and the
  **isolate/component lineage** (value seams, granted capability).
  Every system built AFTER models started writing code sits in the
  second lineage. So does the 2024 Softanza file — written before
  that pressure existed.
- Row-wise, the bottom three rows (audit, reversal, provenance) are
  where the Softanza plane is ahead of everything in the table, and
  they are precisely the rows an AGENT HARNESS needs: what ran, can
  it be undone, who wrote it.

## 4. THE CORDIS COMPARISON (spatiotemporal composability)

`cordiverse/paper` is the one entry in the field that formalizes what
the agentic era actually requires, so it gets its own section.

### 4.1 What it claims

Two orthogonal properties make a system safe to rewrite while
running: **temporal composability** — removing a component completely
reverts its effects, so every effect is a context transformation with
a tracked inverse; **spatial composability** — components declare
their dependencies (coeffects) on a shared context and are reactively
re-executed when providers change. A unified context type carries
both; Cordis implements the calculus with effect tracking, a
component loader, config reconciliation, and HMR.

### 4.2 Discipline vs physics — the load-bearing difference

Cordis obtains its guarantees by **discipline**: the component
promises to route every effect through the context object. The
runtime can then journal inverses and re-run dependents — for
everything that kept the promise. An off-context write is invisible
and unrevertible, and nothing detects it.

The Softanza plane obtains the same guarantees for host state by
**physics**: the plugin runs in a VM state that cannot reference host
memory, so there is no promise to keep — ambient host effects are not
forbidden, they are impossible. The one host effect (`XfU`) exists at
one seam, which is why journaling it (plan §9 A1) covers ALL of it.

The symmetric honesty: both models stop at the world. Cordis cannot
journal what bypasses its context; we cannot un-write a file a
`:State` plugin created. Neither can claim temporal composability
over OS effects; the plan says so in writing (§9.2), the paper's
model simply inherits the gap.

### 4.3 Concept-by-concept mapping

| Cordis concept | Softanza plane mechanism | note |
|---|---|---|
| effect (context transformation) | `XfU` commitment to the host object | ours is singular and explicit; theirs plural and disciplined |
| tracked inverse | prior value in the ledger row (plan §9 A1) | Refine doctrine, same shape |
| removal reverts | `off_`/delete leaves zero host residue | trivially true because nothing leaked |
| coeffect declaration | `@plugin_loads` / `@plugin_uses` | textual, read without executing |
| reactive re-execution | dependency-cone cache invalidation (plan §9 A2) | reaction at next call — pull, not push |
| unified context | REFUSED — no shared mutable context object at all | the host owns state; plugins own nothing |
| config reconciliation / HMR | per-plugin hot reload only | host HMR refused (plan §9.4) |

### 4.4 What the comparison produced (pointers, not rules)

Plan §9.3 adopted three things this analysis surfaced: the reversible
ledger (A1), dependency-cone memo keys (A2), and the agent
write-surface with provenance (A3). Plan §9.4 refused three: host
HMR, a DI service container, push-reactivity into plugins. The
reasoning is above; the rulings are there.

## 5. WHERE THE FIELD IS AHEAD, HONESTLY

- **Permission granularity.** WebExtensions enforce per-capability
  grants; we gate tiers, not syscalls. Closing that for `:State`
  would require curating what the Ring state can see (the Lua
  embedding move) — real work, unscheduled, and until then D8's
  wording stands.
- **Dependency resolution.** OSGi resolves version constraints across
  a graph; our `@plugin_loads` checks availability. Deliberate: the
  plane refused a package manager (plan §1.5).
- **Distribution and signing.** Marketplaces, review pipelines,
  signatures. Refused for v1 — the family's zero-ceremony ethos is
  the point — but `@plugin_author` (A3) is the field where a signing
  story would later attach.
- **Event subscription.** Hook systems let extensions REACT to host
  happenings; our plugins cannot (D9). The house answer is that
  reaction belongs to agents: `AsSkill()` lifts a plugin into the
  agentic plane, where supervised, governed reactivity already
  exists. The capability is not missing; it lives one plane up.

## 6. SYNTHESIS — THE SORTING AXIS OF THE AGENTIC ERA

For thirty years the field sorted plugin systems by isolation cost.
The agentic era re-sorts them by a different question: **can a model
safely author the extension, and how much of the containment is
structural?** On that axis:

- The hook lineage fails structurally — model-written code with the
  host's full authority is unreviewable at agent speed.
- The isolate/component lineage (V8, WASM, MCP) passes on
  containment, but stops at the call: no revertible commitments, no
  host object under transaction, no per-call provenance the HOST
  program can query.
- The Softanza plane passes containment by physics and then keeps
  going: the manifest is a textual admission gate a validator can
  hold against a model's output; every call is ledgered with its
  author; every commitment carries its inverse; removal is proven
  residue-free by a guard, not asserted.

The sentence the study reduces to: **mainstream plugin systems were
built so humans could extend software they trust; this plane is built
so programs can accept capability they do not trust — from humans,
or from models — and prove afterwards what it did, and undo it.**
That is what "algorithmic composability" means here, and the capstone
guard in plan PL5 is that sentence executed.
