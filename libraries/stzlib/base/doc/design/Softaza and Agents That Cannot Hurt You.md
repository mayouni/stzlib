# Agents That Cannot Hurt You
### The Virtual System Framework as the Foundation of the Future Softanza Agentic System

---

## The problem nobody is solving from the right end

The industry's agentic race is a race for *capability*: better reasoning, more tools, longer autonomy. Safety, meanwhile, is treated as a property of the agent — alignment, guardrails, confirmation prompts, "human in the loop" checkboxes. All of these share a flaw: they try to make a fundamentally unpredictable actor trustworthy.

Softanza will take the opposite road. **We will not build safe agents. We will build a safe world, and let ordinary agents loose inside it.**

That safe world already has a name and a design: the Softanza Virtual System Framework. It was conceived for human programmers — a rehearsal space where file, database, GUI, and network operations can be tried without consequence, then committed through a narrated plan. It turns out that everything designed to *liberate* a human programmer is exactly what is needed to *contain* an artificial one. This is not a coincidence; it is the same principle viewed from two sides. Fearlessness for the trusted, harmlessness from the untrusted — both are purchased by the same architectural fact: **the workbench holds no reference to reality.**

## The trust boundary, stated once

> An agent lives entirely inside a virtual system. It can create, destroy, rewrite, and reorganize without limit — virtually. The only artifact that ever leaves its world is an update plan. Plans are executed by someone else.

Notice what this is *not*. It is not a permission check the agent might route around. It is not a prompt telling the model to be careful. The agent's tool surface simply contains no operation that touches disk, database, or network. Asking whether the agent might "escape" is like asking whether a chess engine might move a piece on a physical board. There is no wire to cut, because no wire was ever laid.

## Separated powers: the constitutional core

The framework's Principle of Separated Powers — imagination and authority held by different actors — becomes, in the agentic system, a two-tier actor model:

**Proposing actors** are creative and unpredictable: LLM-driven agents. They enjoy *unlimited* freedom inside the workbench — this is crucial, because clipping an agent's virtual wings destroys the very exploration that makes it valuable. They can only ever produce plans.

**Committing actors** are deterministic and boring on purpose: scripts, validators, policy engines, and above all humans. They can execute plans — but only within a declared `stzCommitScope` ("create-only, under `/generated`, max 40 operations"), every scope auditable, every execution verified after the fact.

Creativity without authority; authority without creativity. The union of the two happens only at the plan — a document both sides can read.

## The plan as a conversation, not a verdict

In the human-only framework, the plan is a preview. In the agentic system it becomes a **negotiation medium**, and this is where the design earns its elegance:

```ring
oPlan = vfs.GenerateUpdatePlan()
aIssues = oPlan.Validate()
# workbox: "Operation 7 overwrites a file modified in reality since mirroring"

oAgent.Receive(aIssues)         # objection enters the agent's context
oAgent.Revise()                 # agent adjusts — inside the sandbox
oPlan = vfs.GenerateUpdatePlan()

oPlan.RejectOperation(3, :Because = "keep the legacy folder for now")
oAgent.Receive(oPlan.Feedback())
oAgent.Revise()
```

Three parties speak through one artifact: the workbox objects on facts (conflicts, constraints), the human objects on judgment (intent, taste, policy), the agent revises. Every round is recorded as operations in history — meaning the *reasoning process itself* becomes replayable, diffable, and teachable. Agentic work stops being an opaque burst of tool calls and becomes a legible negotiation with a paper trail. For the regulated environments Softanza cares about, this is not a nicety; it is the admission ticket.

## Branches as parallel minds

Snapshots and branches, designed so a human could compare two layouts, scale into something no mainstream agent framework offers: **parallel hypotheses from multiple agents on identical reality.**

```ring
vfs.CreateSnapshot("baseline")
oConservative.WorkOn( vfs.BranchFrom("baseline", "cautious") )
oAggressive.WorkOn(   vfs.BranchFrom("baseline", "bold") )
oDomainist.WorkOn(    vfs.BranchFrom("baseline", "domain_driven") )

vfs.CompareBranches(["cautious", "bold", "domain_driven"])
```

Three philosophies, one starting state, structural comparison of outcomes — risk profiles, operation counts, diff matrices — before a single byte of reality moves. Ensemble methods, applied not to predictions but to *actions*.

## The examination hall

Because everything is virtual and everything is recorded, agent competence becomes **measurable like code**:

```ring
oExam = new stzAgentEvaluation()
oExam.GiveScenario(oMessyProjectTree)
oExam.GiveTask("Clean up without losing any user data")
oAgent.Attempt(oExam)
oExam.Score()
# goal achieved: yes · destructive ops proposed: 0
# efficiency: 12 ops (optimal 9) · risk awareness: high
```

Regression-test an agent. Swap the model behind it, rerun identical virtual scenarios, diff the plans. Certify an agent for a commit scope the way you certify a driver for a license class. Today's frameworks evaluate agents on benchmarks; Softanza will evaluate them on **rehearsals of your actual world**.

## Where the field stands, and where we will stand

LangChain-style tool use, AutoGPT descendants, computer-use agents in sandboxed VMs — all place the boundary at the wrong layer. Either tools touch reality immediately with confirmation prompts as tissue-paper protection, or the sandbox is a heavyweight, semantics-blind container (a VM doesn't know a "file move" from random byte churn; it can only be thrown away, not *reviewed*). The Softanza position: the sandbox is **native, semantic, and domain-aware** — it speaks in files, tables, widgets, and connections; its output is a narrated plan a banker's auditor could read; and it is the *same* workbench the human programmer already uses. One mental model, human and agent alike.

## The road ahead

The sequencing writes itself:

1. **Now** — implement the Virtual System Framework, file domain first, exactly as its design document specifies. Its actor-neutral operations (`@cActor`, `@cIntent`) and `stzCommitScope` already carry the agentic future silently.
2. **Next** — Layer 4: `stzAgent`, `stzAgentWorkspace`, `stzPlanNegotiation`, `stzAgentEvaluation`, `stzAgentAuditTrail`. The design document becomes the formal input to this specification.
3. **Then** — widen the domain axis (database, GUI, config), and every new domain is *automatically* agent-ready, because agents never knew the difference between domains in the first place — only the workbench did.

## The sentence that summarizes the strategy

An agent in Softanza does not need to be trusted. It needs to be **reviewed** — and review is a problem we already know how to solve, because we solved it for ourselves first.