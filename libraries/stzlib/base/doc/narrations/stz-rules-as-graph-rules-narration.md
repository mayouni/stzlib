# Rules That See the Whole Picture
### One rule engine over every graph in the library — code, agents, security, workflows, org charts

Softanza used to check its house rules with a text scanner: read the source line
by line, and if a line *looks* like `def len(`, complain. That is a `grep` with a
nicer return type. It has no idea what a class *is*, what a method *calls*, or how
an actor *reaches* an effect — because it never builds anything to ask the
question of.

This narration walks the engine that replaced it. A rule is now a **graph rule**:
it runs over a model — a code graph, an agent graph, a security graph, an org
chart — and answers questions a line scan structurally cannot. Every code block
below is real, and every output block is its actual output.

---

## The graph owns its rules

You declare a rule fluently — a name, a domain, a severity, the condition. But
you do **not** then turn the rule on the graph. In Softanza the graph is the
subject you hold: you **attach** the rule to it, and it becomes part of the
graph's own logic. From then on you ask the *graph* — to check itself, to say
whether it is sound, to report.

```ring
oRule = new stzGraphRule("no-llm-effectful")
oRule.SetDomainQ("agentic")
oRule.WhenQ("kind", "equals", "llm_actor")
oRule.WhenQ("capabilities", "contains", "effectful")
oRule.ThenViolationQ("an LLM proposes, only a pi-gate commits")

g = new stzGraph("agents")
g.AddNode("writer")
g.SetNodeProperty("writer", "kind", "llm_actor")
g.SetNodeProperty("writer", "capabilities", [ "inference", "effectful" ])

g.AddRule(oRule)        # the rule is now part of THIS graph
g.RulesReport()         # the graph reports on itself
```

```
Rule report 'agents': 1 finding(s), 1 error(s), 0 warning(s) -> UNSOUND (errors present)
  [agentic] 1 finding(s)
    ERROR no-llm-effectful @ writer -- an LLM proposes, only a pi-gate commits
```

The scope never leaves the graph. `g.AddRule(r)` attaches; `g.CheckRules()`
returns the findings in one shape (`[ :rule, :subject, :where, :severity,
:message ]`); `g.RulesAreSound()` is the verdict; `g.RulesReport()` prints. A
whole set attaches at once with `g.UseRuleSet(...)`.

`When` clauses select the nodes a rule is *about*; `Then` clauses (not shown here)
say what must *hold* on them. A rule too rich for property-matching supplies a
checker. And the domain graphs come with their rules already attached — an
`stzAgentGraph` knows its guardrails, an `stzSecurityGraph` its escalation rules —
so you just ask *them* the same way.

## The model sees what the text scan cannot

Here is the payoff, in one comparison. The `engine-first` rule flags a call to
Ring's byte-oriented `substr` — new code should use the Unicode-safe engine
forms. First, a real call inside a method:

```ring
aF = StzCheckCode("class Foo" + nl + "def Bar()" + nl + "	x = substr(s, 2)" + nl)
nF = len(aF)
for i = 1 to nF
    ? aF[i][:rule] + "  @line " + aF[i][:line] + "  [" + aF[i][:severity] + "]"
next
```

```
engine-first  @line 3  [warning]
```

Now the same three characters, `substr(`, but as a method *definition* rather
than a call:

```ring
? "findings: " + len(StzCheckCode("class Foo" + nl + "def substr(x)" + nl + "	return x" + nl))
```

```
findings: 0
```

Nothing. The old text scanner flagged both — `" substr("` matches a `def substr(`
line just as happily as a call site. The graph rule reads the *call edges*, and a
definition is not a call, so it is silent. A model distinguishes what a string
match never could.

## The rule that would have caught our own mistake

During a naming sweep, 62 mutator methods were given a chainable `...Q()` form
with no plain twin — a violation of the Q convention (Q chains, the plain method
acts). A line scan can't catch it: the twin might be anywhere in the class. A
graph rule compares the class's *whole* method set:

```ring
aQ = StzCheckCode("class Bag" + nl + "def SetLevelQ()" + nl + "	return This" + nl)
nQ = len(aQ)
for i = 1 to nQ
    ? aQ[i][:rule] + "  [" + aQ[i][:severity] + "]"
    ? "  " + aQ[i][:message]
next
```

```
q-has-plain-twin  [warning]
  'SetLevelQ' is a Q mutator with no plain twin 'SetLevel' in class 'Bag' -- both are required (Q chains, plain acts)
```

It flags `SetLevelQ` (a mutator verb, no twin) but leaves a noun accessor like
`ReactorQ` alone — an accessor legitimately has no plain form. Had this rule been
in CI, it would have failed the commit that introduced those 62.

## Audit becomes a gate

The agent guardrails used to be an *audit*: build a composition, then check it and
complain about what is already wired. The load-bearing one — an LLM actor must
never hold the `effectful` capability — is now a **gate**. The governed door
refuses the dangerous grant at the moment of expression:

```ring
oAG = new stzAgentGraph("mailer")
oAG.AddLLMActor("writer")
try
    oAG.Grant("writer", "effectful")
catch
    ? cCatchError
done
```

```
REFUSED: granting 'effectful' to llm actor 'writer' -- an LLM proposes, only a pi-gate commits (no-llm-effectful, enforced at CONSTRUCTION, not merely audited).
```

The violation can no longer enter the graph through the sanctioned API. The rule
stays as the backstop for anything that reaches the graph another way; the gate
closes the front door.

## Escalation is a path

Security is where a graph earns its keep most clearly. The old posture check asks:
*is this actor both sandboxed and effectful?* — one flag, one node. It is blind to
a sandboxed actor that never holds `effectful` itself but can **reach** it through
a tool it uses:

```ring
oSG = new stzSecurityGraph("resto")
oSG.AddActor("llm", "sandboxed")
oSG.AddTool("shell")
oSG.Uses("llm", "shell")
oSG.Grants("shell", "effectful")

? "llm holds effectful directly? no. reaches it by a path? " + oSG.ReachesEffectful("llm")
```

```
llm holds effectful directly? no. reaches it by a path? 1
```

The `llm` holds only `inference`. A flag check passes it. But the graph sees the
path `llm → shell → effectful`, and `sandboxed-reaches-effectful` — a reachability
query — catches the escalation. It is a class of finding a per-object check cannot
produce at all.

## One gate over every domain

Each graph checks *itself* — `CheckRules()` is the same verb on all of them. A
gate just gathers them: you hand it the graphs, each self-checks, and it gives
one verdict across code, agents, and security instead of three parallel APIs.

```ring
oCG = new stzRingCodeGraph("")
oCG.ScanSource("class Bag" + nl + "def Len()" + nl + "	return 1" + nl, "s")

oAG = new stzAgentGraph("mailer")
oAG.AddLLMActor("writer")  oAG.AddEffect("send")  oAG.Proposes("writer", "send")

oSG = new stzSecurityGraph("resto")
oSG.AddActor("llm", "sandboxed")  oSG.AddTool("shell")  oSG.Uses("llm", "shell")  oSG.Grants("shell", "effectful")

oRep = new stzRuleReport("restolean")
oRep.Collect(oCG).Collect(oAG).Collect(oSG)     # each graph checks itself
oRep.Report()
```

```
Rule report 'restolean': 5 finding(s), 5 error(s), 0 warning(s) -> UNSOUND (errors present)
  [code] 1 finding(s)
    ERROR no-len-method @ 2 -- never define Len() on class 'Bag' -- it shadows Ring's builtin and breaks every caller; use Count()/Size()/NumberOf...()
  [agentic] 3 finding(s)
    ERROR effects-guarded @ send -- effect 'send' has no guardian edge into it -- every effect passes a pi-gate
    ERROR open-text-contained @ writer -- open llm text 'writer' reaches effect 'send' with no guardian on the path -- injection has somewhere to land
    ERROR effects-traced @ send -- effect 'send' reaches no trace sink -- every effect leaves an audit witness
  [security] 1 finding(s)
    ERROR sandboxed-reaches-effectful @ llm -- sandboxed actor 'llm' can REACH the effectful capability by some path -- privilege escalation
```

`Collect(g)` asks the graph to check itself and gathers its findings — the scope
stays on the graphs throughout. One report, grouped by subject, errors first;
`IsSound()` is the CI gate (errors fail the build, warnings advise). Org charts
join the same way — an `stzOrgChart` projects its positions (`AsRuleGraph()`) and
answers `CheckRules()` over rules like `separation-of-duties` and
`no-cyclic-reporting`, so `oRep.Collect(oOrgChart)` slots right in.

---

*A house rule used to be folklore an agent could not run, checked by a scanner
that could not see. Now it is an object over a model: the code's real structure,
the agent graph's real edges, the security surface's real paths. Six domains —
code, agents, security, workflows, org charts — share one engine, one finding
shape, and one gate that either lets the build through or says, in one place,
exactly why it will not.*

Runnable guards: `graphrule_object_narrated` (34), `graphruleset_narrated` (25),
`coderule_narrated` (25), `coderule_project_narrated` (13), `agentrule_narrated`
(21), `securitygraph_narrated` (22), `rulereport_narrated` (23), `orgrule_narrated`
(22).
Design: [SOFTANZA_GRAPH_RULES_PLAN.md](../design/SOFTANZA_GRAPH_RULES_PLAN.md).
