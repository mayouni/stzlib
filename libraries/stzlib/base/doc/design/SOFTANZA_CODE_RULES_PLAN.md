# Code Rules as Graph Rules
### Plan: make `stzCodeRule` a `stzGraphRule` applied to a `stzCodeGraph`

> Status: **plan only — nothing here is built.** Written 2026-07-23 at the
> user's instruction ("if this implies a consistent work, then just make a plan
> and we will implement later"). Every "today" claim below was verified against
> the live tree, including at runtime.

---

## 1. The complaint, restated

`base/meta/stzCodeRules.ring` is **106 lines of flat line-by-line text
scanning**. It splits source into lines, lowercases each one, skips comments,
and prefix-matches:

```ring
if StzLeft(_cL_, 8) = "def len(" or _cL_ = "def len"
    ... :rule = "no-len-method"
```

That is a `grep` with a nicer return type. It has **no model of the code**: no
classes, no methods, no inheritance, no calls. It cannot answer "does this class
reach `stzObject`?", "is this method dead?", "does this `...Q()` have a plain
twin?" — because it has never built anything to ask the question *of*.

Meanwhile the library already owns a real model of exactly that shape, and a
rule engine to run over it. The two were simply never connected.

## 2. Ground truth (three findings, all verified)

**(a) `stzCodeGraph` is a genuine model, and it is rich.**
`base/meta/stzCodeGraph.ring` builds a real `stzGraph` (`GraphQ()`) and exposes:

| Structure | Ancestry | Calls | Analyses |
|---|---|---|---|
| `Classes` `Functions` `MethodsOf` `OwnersOf` `FileOf` `ImportsOf` | `ParentOf` `ParentsOf` `AncestryOf` `SubclassesOf` `DescendantsOf` | `CallEdges` `CallersOf` `CalleesOf` | `DeadCode` `CyclicCalls` `ImpactOf` `Cascade` `Stats` |

Three backends already feed it (`stzRingCodeGraph`, `stzPyCodeGraph` — with a
real tree-sitter parse — and `stzJsCodeGraph`).

**(b) The rule engine exists, but it is FUNCTION-based, not object-based.**
`base/graph/stzGraphRule.ring` exists and is loaded (`stzBase.ring:269`). It
defines **21 functions and a global `$aGraphRules` registry — and zero
classes**: `StzRegisterRule(group, name, definition)`, `StzGetRule`, and a
library of rule functions (`DerivationFunc_Transitivity`,
`ConstraintFunc_NoSelfLoop`, …). `stzGraph` consumes it through
`UseRulesFrom(group)`, `ApplyDerivationRules()`, `CheckConstraintRules()`,
`Rules()`, `RulesSummary()`, plus `.stzrulz` / `.stzrulf` rule files.

**(c) There is NO `class stzGraphRule` — and two rule bases already assume
there is.** `grep -rn "class stzGraphRule"` returns nothing across the tree, and
at runtime `new stzGraphRule("probe")` raises **R11 `class not found:
stzgraphrule`**. Yet `stzWorkflow.ring` builds rules in a clean object style:

```ring
_oRule1_ = new stzGraphRule("bpm_no_orphans")     # <-- no such class
_oRule1_ {
    SetRuleType("validation")
    SetDomain("bpm")
    When("nodeType", "equals", "step")
    ThenViolation("Orphan step detected")
}
```

`stzBPMRuleBase` and `stzSLARuleBase` call that from their `init()`, so
**constructing either class fails today** (confirmed: it raises). They appear to
be unreached, which is why nothing caught it — latent breakage, not a live bug.

So the concept "graph rule" exists in **two incompatible forms**: a function
registry that works, and an object DSL that was written against but never built.

## 3. The decision this plan turns on

Your phrasing — *"a `stzCodeRule` should **be** a `stzGraphRule`"* — is an
**IS-A**, which means the object form. That also matches the natural-orientation
rule (say the relationship in English first: *"a code rule is a graph rule that
happens to run over a code graph"* ✓). And it is what `stzWorkflow` already
assumes.

**Recommendation: build `class stzGraphRule` as the object face of the existing
function registry — do not replace the registry.** A rule object *compiles down
to* a registered rule function. That way:

- `stzWorkflow`'s latent breakage is repaired by the same work;
- `.stzrulz` files, `UseRulesFrom`, and every existing graph rule keep working
  untouched (they are the registry, and the registry is unchanged);
- `stzCodeRule` gets a real parent to inherit.

Rejecting the alternative (make `stzCodeRule` register bare functions) because
it gives no IS-A, no per-rule state (severity, domain, message), and leaves
`stzWorkflow` broken.

## 4. Target shape

```
  stzGraphRule            a named, typed rule over a graph:
   (NEW class, over          SetRuleType(constraint|derivation|validation)
    the existing              SetDomain / SetSeverity / SetMessage
    $aGraphRules)             When(prop, op, value) / ThenViolation(msg)
        |                     Check(oGraph) -> [ finding, ... ]
        |  IS-A
        v
  stzCodeRule             the same rule, whose subject is a CODE graph:
        |                   Check(oCodeGraph) -- may use Classes/AncestryOf/
        |                   CallEdges/DeadCode, not just node properties
        |
        v
  stzCodeRuleSet          the house doctrine as a collection:
                            CheckCode(source) / CheckCodeFile(path) /
                            CheckProject(dir) -> [ :rule, :where, :severity,
                            :message ] -- the SAME finding shape as today, so
                            StzCheckCode()'s callers do not move.
```

**Compatibility is a requirement, not a nicety.** `StzCheckCode` /
`StzCheckCodeFile` / `StzCodeRuleNames` keep their signatures and their
`[ :rule, :line, :severity, :message ]` finding shape; they become thin wrappers
that build a code graph and run the rule set. `codegraph_narrated` and the
governance checks must stay green throughout.

## 5. The payoff — what becomes expressible

Today's four rules are all lexical, and two of them are *guesses*. On a graph
they become real, and a class of rules that cannot be written at all today opens
up:

| Rule | Today (lexical) | On the graph |
|---|---|---|
| `no-len-method` | matches the text `def len(` | a **method node** named `len` on any class — and, via `AncestryOf`, also catches a subclass *inheriting* the shadow |
| `q-returns-object` | scans the body text for `return this` | the method node's return, checked structurally |
| `no-aggressive-verbs` | name prefix match | unchanged (naming is genuinely lexical) — kept as-is |
| `engine-first` | text match on `substr(` | a **call edge** to `substr`, so a *shadowed* local `substr` no longer false-positives |

New rules that require the model — none writable today:

- **`q-has-plain-twin`** — every `...Q()` mutator must have a plain twin.
  *This is precisely the convention error you caught me making in Issue 1.* As a
  graph rule it is one pass over method nodes, and CI would have failed the
  commit that introduced 62 of them. **This alone justifies the work.**
- **`reaches-stzobject`** — every class must reach `stzObject` through
  `AncestryOf` (the hierarchy convention already recorded in the project's own
  notes, currently enforced only by hand).
- **`no-case-collision`** — Ring is case-insensitive, so `NthStz` and `NthSTZ`
  collide into a C22 that takes the whole file down. A graph sees both method
  nodes; a line scanner never will.
- **`no-dead-code`** / **`no-cyclic-calls`** — `DeadCode()` and `CyclicCalls()`
  already exist on `stzCodeGraph`; they are simply not exposed as rules.
- **`no-orphan-class`**, **`method-defined-twice`**, **impact-aware severity**
  (a violation on a class with many `DescendantsOf` matters more).

## 6. Phases

Each phase ships something usable and leaves the suite green.

1. **`class stzGraphRule`** (`base/graph/`) — the object face: name, type,
   domain, severity, message, `When`/`ThenViolation`, and `Check(oGraph)`.
   Registers itself into `$aGraphRules` so the existing engine runs it. Plain +
   `...Q()` twins for every mutator, per the convention. Guard: a rule object
   and an equivalent registered function produce identical findings.
2. **Repair `stzWorkflow`** — `stzBPMRuleBase` / `stzSLARuleBase` now construct.
   This is a bug fix that falls out of phase 1; add the guard they never had.
3. **`class stzCodeRule from stzGraphRule`** + `stzCodeRuleSet`, with the four
   existing rules ported and `StzCheckCode` rewired behind its current
   signature. Guard: the existing findings are reproduced on the same fixtures.
4. **The new graph-only rules** — `q-has-plain-twin`, `reaches-stzobject`,
   `no-case-collision`, `no-dead-code`. Highest value first.
5. **`CheckProject(dir)`** — the whole library as one graph, so rules see across
   files (inheritance and call edges do not stop at a file boundary). Then run
   it over `base/` and triage what it finds.

## 7. Cost, risk, and the honest caveats

- **Cost**: phases 1–3 are the substantial part — a new class plus a rewrite of
  `stzCodeRules` behind a frozen public signature. Phases 4–5 are additive.
- **Speed**: a line scan is O(lines); building a code graph is heavier. For
  `CheckCode(oneFile)` the graph is small, but **`CheckProject` over `base/` must
  be measured, not assumed** — the project's own rule is that a cache/rebuild is
  only justified when measured against the interleaved pattern.
- **Ring backend fidelity**: the new rules are only as good as
  `stzRingCodeGraph`'s extraction. `q-has-plain-twin` needs reliable method-node
  extraction per class; if that proves lossy, the rule reports what it can see
  and says so, rather than emitting false confidence.
- **Not every rule belongs on a graph.** `no-aggressive-verbs` is a naming rule
  and stays lexical. The goal is not to graph everything; it is to stop
  pretending a text scan is a model.

---

*The library already had both halves — a real code model and a real rule engine
— and a 106-line text scanner sitting between them, connected to neither. The
work is to introduce them: give the rule engine an object face, make a code rule
a graph rule, and let the doctrine be checked against the code's structure
instead of its spelling.*
