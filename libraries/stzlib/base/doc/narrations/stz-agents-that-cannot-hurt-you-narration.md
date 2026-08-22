# Agents That Cannot Hurt You
### What Softanza does differently from the 2026 agentic stack — for programmers, not AI specialists

Everyone building agents in 2026 is handed roughly the same shopping list: a Python
project, a model provider, a graph framework, a vector store, a set of tools with typed
schemas, a tracing service, and a chapter of safety advice — allowlists, sandboxes,
human approvals, retry caps, injection defences. It is competent advice. It is also
what you must assemble, yourself, correctly, every time.

This narration walks Softanza's answer and explains each idea before using it. You do
not need to know what ReAct, a capability lattice or a trust posture is — that is the
narration's job. **Every code block below is real, and every output block is its actual
output.**

If you take one idea away, take this: **the industry builds safe agents. Softanza builds
a safe world and lets an ordinary agent loose inside it.**

---

## The premise everybody shares — and the one we do not

The mainstream stack assumes the agent *is* a language model in a loop. The model
decides, so every safety mechanism exists to constrain a stochastic decision-maker:
budget its context, judge its output with another model, cap its loops, log everything
so you can reconstruct what it did. That is a large amount of engineering, and it is
priced per decision, forever.

Softanza revokes that premise. Intelligence here is knowledge plus search plus
optimization plus rules plus learning — running locally, explaining itself, costing
nothing. A language model is **one tier** of the ladder, never its definition.

The consequence is not philosophical, it is structural. If the deciding part is
deterministic, the safety problem stops being *"constrain a guesser everywhere"* and
becomes *"govern the one narrow door where a proposal turns into an effect."* Almost
everything below follows from that single move.

---

## First idea: an agent is a file, and the file is judged before it runs

In Softanza an agent is not a class you subclass or a graph you wire. It is a
declaration — a `.pia` file — dropped in a folder. And it is **judged at load**, not
discovered at the first tick.

Here is an agent that reorders stock. It names a Ring function to do the work:

```ring
cBad = "pia: 2
name: restocker
kind: pi
coverage: reorders stock when it runs low
reversibility: compensable
schedule:
  timer: 50
skills:
  - name: reorder
    when: fact stock level low
    does: ring:PlaceTheOrder
    verify: fact stock level ordered
"
oBad = StzAgentDeclarationQ(cBad)
? "valid: " + oBad.IsValid()
? oBad.CiteFindings()
```

```
valid: 0
[pia-posture @ skills.reorder] this skill runs the Ring function 'PlaceTheOrder' and declares no execution posture. pia 2 requires 'posture: trusted | external | sandboxed' on any skill with a ring: clause -- the load gate says the function EXISTS; the posture says on what TERMS it may run (5.8).
```

Read the refusal carefully, because it is the house style: it names the rule
(`pia-posture`), the place (`skills.reorder`), what is missing, and *why the rule
exists*. Nothing was guessed and nothing ran.

Note what the file already had to say before anyone asked about safety: what it
**covers**, and how **reversible** its work is. Add the missing line and it is admitted:

```ring
# the same file, plus one line:  posture: trusted
oGood = StzAgentDeclarationQ(cGood)
? "valid: " + oGood.IsValid()
? "format version: " + oGood.FormatVersion()
? "covers: " + oGood.CoverageStatement()
? "reversibility: " + oGood.ReversibilityClass()
```

```
valid: 1
format version: 2
covers: reorders stock when it runs low
reversibility: compensable
```

The industry equivalent of this file is a Python module plus a graph definition plus a
tool schema plus a policy document. Here it is one artefact a non-programmer can read,
and a court that refuses it out loud.

---

## Second idea: two different questions, asked at different moments

Most stacks ask one safety question — *may this action run?* — at the moment the action
runs. Softanza asks two, and the first one is asked when the answer is still free.

**May this agent exist in the loop at all?**

```ring
oGov = new stzGovernance("shop")
? "no coverage stated -> " + oGov.MayRegister("mystery", "", "reversible")
? "  " + oGov.Why()
? "no reversal declared -> " + oGov.MayRegister("mystery", "reorders stock", "")
? "  " + oGov.Why()
? "both stated -> " + oGov.MayRegister("mystery", "reorders stock", :Compensable)
```

```
no coverage stated -> 0
  AGENTLOOP-R4: agent 'mystery' declares no coverage statement. Registration refuses it. Say what this agent covers, in one sentence, before the loop will run it. Law 18: nothing schedules what nobody has stated the reach of.
no reversal declared -> 0
  AGENTLOOP-R5: agent 'mystery' declares no reversibility class. Registration refuses it. Declare one of: reversible | compensable | irreversible. Law 18: an agent whose reversal nobody stated cannot be scheduled by something that cannot undo it.
both stated -> 1
```

An agent nobody can describe cannot be scheduled. That question has no counterpart in
the mainstream stack at all — there, an agent exists because someone constructed one.

**And separately: may this actor perform this action, now?** That is `MayProceed`, and
it composes three things a stack usually keeps in three different places — what the
actor *may* do, what it *should* do, and how dangerous the action is:

```ring
oG2 = new stzGovernance("billing")
oG2.DeclareRisk("send-invoice", 3)
oG2.GrantPermission("billing-agent", "send-invoice")
oG2.SetAuthority("billing-agent", :Delegated)
? "may it proceed? " + oG2.MayProceed("billing-agent", "send-invoice")
? "  " + oG2.Why()
```

```
may it proceed? 0
  refused: 'billing-agent' holds 'delegated' authority (level 2) but 'send-invoice' is risk tier 3 (SHOULD does not cover it)
```

Permission is not authority. The agent *had* the permission and was still refused,
because its standing did not cover the danger of the act. Raise the standing and the
same call is allowed, for a stated reason:

```ring
oG2.SetAuthority("billing-agent", :Autonomous)
? "after raising the authority: " + oG2.MayProceed("billing-agent", "send-invoice")
? "  " + oG2.Why()
```

```
after raising the authority: 1
  allowed: permission held AND 'autonomous' authority (level 3) covers risk tier 3
```

And an action nobody declared never proceeds at all:

```ring
? "may it do something nobody declared? " + oG2.MayProceed("billing-agent", "delete-ledger")
? "  " + oG2.Why()
```

```
may it do something nobody declared? 0
  refused: 'delete-ledger' has NO declared risk tier (undeclared actions never proceed)
```

That is fail-closed by construction. The usual failure — an agent doing something nobody
thought to forbid — is not reachable here, because the default is refusal.

---

## Third idea: how *undoable* an act is, not just how risky

Risk and reversibility are different axes, and conflating them is a common and
expensive mistake. A low-risk action you cannot take back can deserve more ceremony
than a high-risk one you can.

So Softanza asks who is allowed to do work of a given undoability. The rule is one
sentence, and every door quotes it rather than paraphrasing:

```ring
? StzPostureReversibilityRefusal("sandboxed", "irreversible")
? "reversible: '" + StzPostureReversibilityRefusal("sandboxed", "reversible") + "'"
```

```
a 'sandboxed' posture does not cover 'irreversible' work -- the harder an act is to undo, the more trusted the code performing it must be (reversibility x posture, ruling 3.2)
reversible: '' (empty = allowed)
```

Trusted code may do anything; out-of-process code may do anything it can compensate for;
LLM-composed code may only do what anyone can take back. In the mainstream stack this
distinction lives in a paragraph of a design document, if it lives anywhere.

---

## Fourth idea: the proposer cannot commit — by construction

Every serious 2026 guide recommends separating planning from execution: let the model
propose, let a validated executor act. It is good advice, and it is advice — a pattern
you implement, and can forget to implement.

In Softanza it is not a pattern. An LLM actor's effect-capability set is *empty*:

```ring
oLLM = LLMActor("summarizer")
? "capabilities: " + @@(oLLM.Kinds())
? "posture     : " + oLLM.Posture()
? "can cause effects: " + oLLM.IsEffectful()
```

```
capabilities: [ "inference" ]
posture     : sandboxed
can cause effects: 0
```

There is no configuration in which that actor commits anything. It can propose, and a
deterministic gate disposes. **Creativity is free; admission is governed.**

---

## Fifth idea: the agent works, and the world does not move

This is the part with no mainstream equivalent, and it is the heart of the thing.

Here is an ordinary agent whose job is to write a price list to disk. Nothing about it
is special — it names a Ring function, exactly as before. The only new call is
`GiveWorkbench()`, which hands it a **virtual file system** instead of reality:

```ring
oAg.GiveWorkbench()
? "cycle fired skills: " + oAg.Cycle()
? "agent believes it wrote them: " + oAg.MemoryQ().Fact("prices", "were", "written")
? "the real file exists: " + StzFileExists($cNarrOut)
? "the workbench holds it: " + oAg.WorkbenchQ().Exists($cNarrOut)
```

```
cycle fired skills: 1
agent believes it wrote them: 1
the real file exists: 0
the workbench holds it: 1
```

Look at those four lines. The agent ran. Its skill fired and *verified*. Its memory says
the prices were written — and from the agent's point of view they were. **The disk did
not move.** The work is real, complete and inspectable, and reality is untouched.

The function it ran was not written specially for this. It is the same code that would
write to disk outside a workbench; it asks for the ambient bench and rehearses into it.

---

## Sixth idea: the plan is the only thing that crosses

A tick's sole export toward reality is a plan — and a plan narrates itself, ranks its
own risks, and can be argued with:

```ring
oPlan = oAg.GenerateUpdatePlan()
? oPlan.Narration()
```

```
Update plan (1 of 1 operations to commit):
  * 1. write 29 bytes to '.../_narr-fixture/prices.csv'
```

Hand it to the proposer and ask whether it may commit — the answer arrives *before*
anything is attempted:

```ring
oPlan.SetExecutor(LLMActor("summarizer"))
aMay = oPlan.MayCommit()
? "may the LLM commit? " + aMay[1]
? "  " + aMay[2]
```

```
may the LLM commit? 0
  actor 'summarizer' cannot commit -- it lacks the 'effectful' capability (required by operation 1)
```

Now a committing actor, working inside a declared scope:

```ring
oPlan2.SetExecutor(PIActor("shop-committer"))
oScope = new stzCommitScope()
oScope.AllowUnder(cFx)
oPlan2.SetScope(oScope)
aRes = oPlan2.Execute()
? "committed: " + aRes[1][2] + ", skipped: " + aRes[2][2]
? "the real file exists NOW: " + StzFileExists($cNarrOut)
? "its content: " + StzFileRead($cNarrOut)
? "audit trail: " + @@(oPlan2.AuditTrail())
```

```
committed: 1, skipped: 0
the real file exists NOW: 1
its content: espresso,2.40
flat-white,3.10
audit trail: [ [ 1, "committed", "write_file", "shop-committer" ] ]
```

*That* is the moment reality changed — one place, by a named actor, with an audit line.

And the scope is not decoration. The same plan, committed under a scope that does not
cover the path:

```ring
oScope2.AllowUnder("/somewhere/else")
aRes3 = oPlan3.Execute()
? "committed: " + aRes3[1][2] + ", skipped: " + aRes3[2][2]
? "reason: " + aLog[1][2] + " -- " + aLog[1][3]
```

```
committed: 0, skipped: 1
reason: REFUSED-BY-SCOPE -- path '.../_narr-fixture/prices.csv' is outside the allowed scope
```

A reviewer can also reject a single step with `RejectOperation(n, :Because)`, re-validate
the plan against a reality that may have moved since rehearsal, or read its ranked risks
before deciding. The plan is a **negotiation medium**, not a verdict.

---

## How this compares, honestly

| The question | The mainstream 2026 answer | Softanza |
|---|---|---|
| What is an agent? | A model in a loop, wired in a framework graph | A declared file over a deterministic cycle; the model is one optional tier |
| When is it checked? | At runtime, by validators you add | At **load**, by a court that names the rule it refused under |
| May it exist? | Not asked | `MayRegister` — no coverage, no reversal, no schedule |
| May it act? | Policy code you write per tool | `MayProceed` — permission × authority × risk, fail-closed |
| Can the model act directly? | Yes, unless you prevent it | **Never** — empty effect-capability set, structurally |
| How does it touch the world? | Tool call, immediately | Rehearse → plan → a committing actor commits under a scope |
| Structured output | Validate after generation, retry on failure | Constrained decoding — the violating token cannot be emitted |
| Cost of a decision | An API call | Zero, offline, deterministic |
| Testing | Golden sets, model-as-judge, snapshots | Ordinary assertions — the floor is deterministic |

**Where the industry is genuinely ahead, and it matters:**

- **Connectors.** OAuth'd Slack, Drive, Jira; hosted vector stores; streaming chat UIs.
  Reachable from here, not paved.
- **Retrieval over open unstructured corpora.** Hybrid search, re-ranking and freshness
  pipelines are mature there. Softanza's answer inverts the problem — curate knowledge
  and *derive* — which wins on a curated domain and loses on the open web.
- **Frontier reasoning.** That stack orchestrates the largest models per call.
- **Ecosystem and hiring.** There is a labour market for that stack and none for this one.

---

## When to reach for which

Reach for the mainstream stack when the task **is** open-ended language work over
material you cannot curate: summarising arbitrary documents, conversational products,
research over the open web.

Reach for Softanza's agentic layer when actions have **consequences** and someone will
eventually ask *why did it do that* — allocation, scheduling, back-office automation,
regulated or audited work, anything that runs unattended, and anything that must keep
working offline at zero marginal cost.

The two are not exclusive. The point of the capability lattice is precisely that a
language model can sit inside a Softanza system as a **proposer** — creative, useful,
and structurally unable to commit — while a deterministic gate decides what becomes
real. That is the whole design in one sentence, and it is why an ordinary agent, loose
in this world, cannot hurt you.

---

*The mechanisms shown here are guarded by `base/test/agentic/safeworld_narrated.ring`
(76 assertions), `base/test/agentic/agentfile_narrated.ring` (88) and
`base/test/governance/governance_narrated.ring` (19). The doctrine is
`base/doc/design/Softaza and Agents That Cannot Hurt You.md`; the ruling that bound the
safe world to the agents is §3.2 of `SOFTANZA_INTELLIGENCE_ARCHITECTURE.md`. The
industry positions summarised above are drawn from a 2026 agentic-AI engineering
roadmap, paraphrased throughout.*
