# Rule Governance over Graphs
### Plan: one rule engine for every graph-based object — `stzCodeRule` is just the first instance

> Status: **phases 1–2 BUILT (c02083e0b, 2401af3e8); phases 2b, 3–7 planned.** Written 2026-07-23
> at the user's instruction ("if this implies a consistent work, then just make a
> plan and we will implement later"), and widened at the user's second
> instruction: *"use stzGraphRule everywhere it is necessary, not only in
> stzCodeGraph — it's rule governance applied to any graph-based object in
> Softanza."* Every "today" claim below was verified against the live tree,
> including at runtime.
>
> **Phases 1–2 done.** P1: `class stzGraphRule` is the object face over the
> existing registry (appended to `graph/stzGraphRule.ring`); object and registry
> share one matcher so they cannot diverge; it reproduces the hand-written
> `StzCheckNoLLMEffectful` exactly. Guard `graphrule_object_narrated` (34). P2:
> `stzGraphRuleSet` + a `Then`/comparison DSL; `stzWorkflow`'s BPM/SLA rule bases
> repaired (they never ran); `stzOrgChart` compliance stubs unified as rule sets
> (per-regime content + a graph projection deferred to 2b). Guard
> `graphruleset_narrated` (25).

---

## 1. The thesis

Softanza has **five hand-rolled rule checkers**, each re-implementing the same
idea — walk a structure, test a predicate, emit a finding — and each inventing
its own finding shape and its own entry points:

| Checker | Subject | Finding shape |
|---|---|---|
| `meta/stzCodeRules` | source text | `[ :rule, :line, :severity, :message ]` |
| `meta/stzGovernanceChecks` | an **agent graph** | `[ :invariant, :node, :severity, :message ]` |
| `security/stzSecurityPosture` | the security surface | `[ :invariant, :severity, :where, :message ]` |
| `natural/stzKnowledgeWorld` | a knowledge world | its own `:severity` findings |
| `graph/stzGraphRule` | a graph | the real engine — registry-based |

Three near-identical shapes that differ only in whether the locus is called
`:line`, `:node`, or `:where`. Three parallel `Check…()` / `…IsSound()` /
`…InvariantNames()` APIs. And the one component that is an actual rule *engine*
— with rule **types**, registration, and graph integration — is used by almost
none of them.

**The claim: rule governance is not a `meta/` feature. It is a property of being
graph-shaped, and most of Softanza's important objects are graph-shaped.** The
work is to give the engine an object face, then let every domain declare its
rules against it instead of hand-writing a walker.

## 2. Ground truth (verified)

**(a) `stzGraph` already has a rule engine, and it is FUNCTION-based.**
`base/graph/stzGraphRule.ring` exists and is loaded (`stzBase.ring:269`). It
defines **21 functions plus the global `$aGraphRules` registry — and zero
classes**: `StzRegisterRule(group, name, def)`, `StzGetRule`, and rule-function
libraries (`DerivationFunc_Transitivity`, `ConstraintFunc_NoSelfLoop`, …).
`stzGraph` consumes it via `UseRulesFrom`, `ApplyDerivationRules`,
`CheckConstraintRules`, `Rules`, `RulesSummary`, and `.stzrulz` / `.stzrulf`
files.

Critically, it already distinguishes **three rule types** — and this is the
capability the hand-rolled checkers all lack:

- **constraint** — guards an operation, *blocking an invalid change before it
  happens*;
- **derivation** — auto-derives edges/nodes after a change (transitivity,
  symmetry, hierarchy);
- **validation** — checks the final state.

Every hand-rolled checker in the table above is **validation-only**: it can tell
you something is wrong *after* it is wired. None can refuse the wiring.

**(b) There is NO `class stzGraphRule`.** `grep -rn "class stzGraphRule"`
returns nothing; `new stzGraphRule("x")` raises **R11 `class not found`**. Yet
`stzWorkflow` writes rules in a clean object style against it:

```ring
_oRule1_ = new stzGraphRule("bpm_no_orphans")     # <-- no such class
_oRule1_ { SetRuleType("validation")  SetDomain("bpm")
           When("nodeType", "equals", "step")  ThenViolation("Orphan step") }
```

`stzBPMRuleBase` and `stzSLARuleBase` call that from `init()`, so **neither class
can be constructed today** (verified: it raises). Latent, unreached breakage.
`stzOrgChart` goes further: it declares `stzSOXRuleBase`, `stzGDPRRuleBase`,
`stzPCIDSSRuleBase`, `stzHIPAARuleBase`, `stzISO27001RuleBase`,
`stzBaselIIIRuleBase`, `stzBCEAORuleBase` — **compliance rule bases that are
name-only shells**, scaffolding waiting for exactly this engine.

**(c) `stzCodeGraph` is a rich model** — `Classes`, `MethodsOf`, `OwnersOf`,
`ParentOf`/`AncestryOf`/`SubclassesOf`/`DescendantsOf`, `CallEdges`/`CallersOf`/
`CalleesOf`, `DeadCode`, `CyclicCalls`, `ImpactOf`, `Cascade`, `Stats`, over a
real `stzGraph` (`GraphQ()`), with three language backends.

**(d) `meta/stzCodeRules.ring` is 106 lines of line-by-line text scanning** —
lowercase, skip comments, `StzLeft(_cL_,8) = "def len("`. A grep with a nicer
return type, connected to neither the model in (c) nor the engine in (a).

## 3. The decision

The user's *"a `stzCodeRule` should **be** a `stzGraphRule`"* is an **IS-A**, so
the object form is required — which is also what `stzWorkflow` already assumes.

**Build `class stzGraphRule` as the OBJECT FACE of the existing function
registry — do not replace the registry.** A rule object compiles down to a
registered rule function. This keeps `.stzrulz`, `UseRulesFrom` and every
existing graph rule working untouched, repairs `stzWorkflow` as a side effect,
unblocks `stzOrgChart`'s compliance shells, and gives every domain a parent to
inherit.

```
  stzGraphRule                 a named, TYPED rule over any graph
   (NEW class over the           SetRuleType(constraint|derivation|validation)
    existing registry)           SetDomain / SetSeverity / SetMessage
        |                        When(prop, op, value) / ThenViolation(msg)
        |                        Check(oGraph) -> [ findings ]
        |  IS-A
        +-- stzCodeRule          subject = stzCodeGraph
        +-- stzAgentRule         subject = stzAgentGraph
        +-- stzSecurityRule      subject = the security surface
        +-- stzWorkflowRule      subject = stzWorkflow (repairs BPM/SLA)
        +-- stzComplianceRule    subject = stzOrgChart (SOX/GDPR/HIPAA/...)
```

**One finding shape for all of them**: `[ :rule, :subject, :where, :severity,
:message ]`. The existing entry points (`StzCheckCode`, `StzCheckAgentGraph`,
`StzCheckSecurityPosture`) keep their signatures and today's shapes as thin
adapters, so nothing downstream moves.

## 4. What SECURITY gains

Today `stzSecurityPosture` checks **flags on individual objects**: is *this*
actor both sandboxed and effectful; does *this* site hold an inline key. Each
invariant is a hand-written loop over a list, and each looks at one object at a
time.

The security surface is, in truth, a **graph**: actors → capabilities, actors →
tools, sites → secrets, secrets → stores, deployments → sites, agents → effects.
Making that graph explicit changes what is *checkable*:

1. **Multi-hop privilege escalation — the hole that flag checks cannot see.**
   `no-sandboxed-effectful` catches an actor that *itself* holds `effectful`. It
   cannot catch a sandboxed actor that reaches an effect **through** a tool, a
   delegated actor, or a site. As a **reachability rule** over the graph, the
   question becomes the right one: *can any sandboxed node reach any effectful
   capability by any path?* This is a class of finding the current design is
   structurally unable to produce.
2. **Constraint rules refuse the wiring, instead of reporting it later.** Today
   you can attach a live secret to a sandboxed actor and only learn at audit
   time. As a `constraint`-type rule the edge is **rejected at construction** —
   "expression is free, admission is governed" applied to the security graph
   itself, at the moment of expression.
3. **Derivation gives transitive trust for free.** `DerivationFunc_Transitivity`
   already exists. Declare "delegation is transitive" once and every
   effective-permission question becomes a query instead of a bespoke walk.
4. **The blast radius of a leaked secret becomes a graph query** —
   `ImpactOf`-style: which sites, deployments and actors reach this secret? That
   is rotation planning, and it is not expressible today.
5. **One CI gate.** `IsSound()` over code + agents + security + deployment in one
   pass, one finding shape, instead of three parallel APIs.

## 5. What AGENTS gain

`stzAgentGraph` is **already a real graph** — `@oG = new stzGraph("agentgraph-…")`
with typed nodes (`PIActor`, `LLMActor`, `HybridActor`, `Guardian`, `Effect`,
`Tool`, `TraceSink`, `Input`). And its four guardrails in
`stzGovernanceChecks.ring` are **hand-written graph walks**:

```ring
_acIds_ = poGraph.NodesIds()
for _i_ = 1 to _n_
    if StzLower("" + poGraph.NodeProperty(_acIds_[_i_], "kind")) = "llm_actor"
        _aCaps_ = poGraph.NodeProperty(_acIds_[_i_], "capabilities")
        if isList(_aCaps_) and ring_find(_aCaps_, "effectful") > 0
            _aF_ + [ :invariant = "no-llm-effectful", ... ]
```

That is *literally* `When("kind","equals","llm_actor")` +
`When("capabilities","contains","effectful")` → `ThenViolation(...)`. It is a
graph rule that was written out by hand because there was no class to declare it
with.

The gains are concrete:

1. **The library's own comment names the limitation.** Invariant 2 reads:
   *"every effect node is GUARDED: some guardian node has an edge into it (the
   **direct-guard form; full dominator analysis is the next strengthening**)"*.
   A hand-walk can only afford the direct-edge form. On the rule engine, "every
   path from an input to an effect passes through a guardian" is a reachability/
   dominator rule — **the strengthening the author already wanted comes with the
   engine**, not as another bespoke walker.
2. **Illegal wiring becomes impossible, not merely detectable.** As
   `constraint` rules, connecting an `LLMActor` to an `Effect`, or an ungoverned
   `Tool` to an effectful path, is **refused when the edge is added**. Today the
   graph accepts it and a later check complains. This is the single biggest
   agentic-safety upgrade available: the guardrail moves from *audit* to *gate*.
3. **Projects can declare their own agent invariants** without editing library
   code — a rule object registered into a domain group, exactly like BPM/SLA.
4. **Live invariants on the hosted loop.** `stzAppServer` now ticks agents on its
   serve loop; a validation rule set can run per N ticks, so a graph that drifts
   at *runtime* (an agent granted a capability mid-flight) is caught then, not
   only at build time.
5. **The four guardrails stop being four functions** and become a named,
   listable, extensible rule *set* — the same object `stzOrgChart` wants for SOX
   and `stzWorkflow` wants for BPM.

## 6. Every graph-shaped object, and the rules it wants

| Object | Already a graph? | Rules it wants |
|---|---|---|
| `stzCodeGraph` | yes | `q-has-plain-twin`, `reaches-stzobject`, `no-case-collision`, `no-dead-code`, `no-cyclic-calls`, inheritance-aware `no-len-method` |
| `stzAgentGraph` | **yes** (`new stzGraph`) | the 4 guardrails as declared rules + **dominator** guarding + constraint-time refusal |
| security surface | not yet — **make it one** | multi-hop escalation, inline-key, secret blast radius, transitive delegation |
| `stzWorkflow` | yes | BPM + SLA rule bases (**currently un-constructible**) |
| `stzOrgChart` | yes | SOX / GDPR / PCI-DSS / HIPAA / ISO27001 / BaselIII / BCEAO (**name-only shells today**) |
| `stzKnowledgeGraph` | `from stzGraph` | ontology consistency, orphan concepts, contradiction detection |
| `stzDeployment` | plan DAG (`RunAfter`) | acyclicity, unreachable step, ungoverned step before a commit step |
| `stzAppTopology` | model | a part with a role but no dataset; a dataset no part reads |
| `stzDecisionTree`, `stzDiagram`, `stzGraphView`, `stzGraphex` | yes | structural well-formedness |

## 7. Phases

1. **`class stzGraphRule`** (`base/graph/`) — **DONE (c02083e0b).** The object
   face over the existing registry: name, type, domain, severity, message,
   `When`/`ThenViolation`, `UseChecker` (escape hatch), `Check(oGraph)`. Plain +
   `...Q()` twins for every mutator; chain via `StzGraphRuleQ()`. Object and
   registry share one matcher (`StzGraphRuleFindings`) so they agree by
   construction; it reproduces `StzCheckNoLLMEffectful` exactly. Guard
   `graphrule_object_narrated` (34).
2. **Repair what already assumes it** — **DONE (2401af3e8).** Added
   `stzGraphRuleSet` (a named set: `AddRule`/`Check`/`IsSound`/`RegisterAll`) and
   a `Then(prop,op,value)` requirement clause + comparison operators (When =
   scope, Then = requirement; prohibition vs implication). `stzWorkflow`'s
   BPM/SLA rule bases now construct and find real problems (structural rules use
   the checker hatch); `stzOrgChart`'s SOX/GDPR/… compliance stubs now inherit
   `stzGraphRuleSet` (same type, backward-compatible). Guard
   `graphruleset_narrated` (25). **Deferred to phase 2b:** an `stzOrgChart` is a
   *positions* model, not a graph, so faithful per-regime compliance rules need
   a **graph projection** of it first (positions→nodes, reportsTo→edges) plus
   the domain rule content — not fabricated here.
3. **`stzCodeRule` + `stzCodeRuleSet`** — the four existing rules ported,
   `StzCheckCode` rewired behind its frozen signature.
4. **`stzAgentRule`** — the four guardrails redeclared as rules; add the
   **dominator** form of `effects-guarded`; make `no-llm-effectful` a
   **constraint** so the edge is refused at construction.
5. **`stzSecurityRule` + an explicit security graph** — actors/tools/secrets/
   stores/sites as nodes; multi-hop escalation and blast-radius rules; constraint
   rules on secret attachment.
6. **Unify the finding shape + one CI gate** — `[ :rule, :subject, :where,
   :severity, :message ]`, with the three existing entry points kept as adapters.
7. **New code rules + `CheckProject(dir)`** — `q-has-plain-twin` first (see
   below), then whole-library checking across files.

## 8. The payoff, stated plainly

- **`q-has-plain-twin`** — every `...Q()` mutator must have a plain twin. This is
  precisely the convention error corrected in `56b3e36a8`, where 62 Q-only
  mutators were introduced in one campaign. As a rule, CI fails that commit.
- **`no-case-collision`** — Ring is case-insensitive, so `NthStz` and `NthSTZ`
  collide into a C22 that takes down the whole file. A graph sees both method
  nodes; a line scanner never can.
- **Agent guardrails become gates, not audits** — the dominator form of
  `effects-guarded`, and constraint-time refusal of an LLM→Effect edge.
- **Security gains multi-hop reachability** — the escalation path that per-object
  flag checks are structurally blind to.
- **Five checkers become one engine**, with one finding shape and one `IsSound()`.

## 9. Honest caveats

- **Not everything belongs on a graph.** `no-aggressive-verbs` is a naming rule
  and stays lexical. The goal is not to graph everything; it is to stop
  pretending a text scan is a model.
- **Cost must be measured, not assumed.** Building a code graph is heavier than a
  line scan; `CheckProject` over `base/` needs measuring against the interleaved
  pattern before any caching is added.
- **Rules are only as good as the extraction.** `q-has-plain-twin` needs reliable
  per-class method nodes from `stzRingCodeGraph`; where extraction is lossy the
  rule must report what it can see and say so, not emit false confidence.
- **Constraint rules change behaviour.** Refusing an edge that used to be
  accepted can break existing callers, so constraint-type rules ship **opt-in per
  domain**, with validation-mode first and a migration window.

---

*Softanza already had a rule engine with constraint/derivation/validation
semantics, and a set of important objects that are all graphs — agent graphs,
knowledge graphs, org charts, workflows, code graphs, deployment DAGs — with
hand-written walkers bolted onto each and a 106-line text scanner off to one
side. The work is to introduce them properly: one object face for the engine,
one finding shape, and each domain declaring its governance instead of coding it
by hand.*
