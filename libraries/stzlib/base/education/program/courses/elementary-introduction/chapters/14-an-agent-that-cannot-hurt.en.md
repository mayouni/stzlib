# An agent that cannot hurt

*Elementary Introduction · Chapter 14 · Skills GO-01 "What does my agent cover, and what can be undone?", GO-02 "Who is allowed to make this real?" and GO-03 "What would it have done?"*

An agent is a program that acts on its own. Softanza lets you build one safely, because the safety is not
in the agent: it is in the world around it. A court judges the declaration, a gate stands between every
proposal and every effect, and a rehearsal room takes the action before reality does.

## 1. Declare an agent, and let the court judge it

An agent is a text file. It must say what it covers and what class of act it takes, or it is never scheduled.

```ring
cPia = "pia: 1
name: stock-watcher
kind: pi
coverage: checks the kitchen stock every morning and notes what is low
reversibility: reversible
schedule:
  timer: 20
memory:
  - stock level unknown
skills:
  - name: check-stock
    when: always
    does: learn stock level checked
    verify: fact stock level checked
"
oDecl = StzAgentDeclarationQ(cPia)
? oDecl.IsValid()
#--> TRUE
? oDecl.ReversibilityClass()
#--> reversible
```

## 2. The court refuses what says nothing of its reach

```ring
oBad = StzAgentDeclarationQ( StzReplace(cPia, "coverage: checks the kitchen stock every morning and notes what is low" + char(10), "") )
? oBad.IsValid()
#--> FALSE
? StzLeft( oBad.CiteFindings(), 25 )
#--> [pia-coverage @ coverage]
```

## 3. Propose, never commit: the shape of a safe system

A language model may propose. Wire it straight to an effect, and the graph of the system is unsound; the
violation says why.

```ring
oGBad = new stzAgentGraph("mailer-bad")
oGBad.AddLLMActor("writer")
oGBad.AddEffect("send")
oGBad.Proposes("writer", "send")
? oGBad.IsSound()
#--> FALSE
? oGBad.Violations()[1][:message]
#--> effect 'send' has no guardian edge into it -- every effect passes a pi-gate
```

## 4. The governed shape

A gate between the proposal and the effect, and a trace after it.

```ring
oGOk = new stzAgentGraph("mailer")
oGOk.AddLLMActor("writer")
oGOk.AddGuardian("gate")
oGOk.AddEffect("send")
oGOk.AddTraceSink("audit")
oGOk.Proposes("writer", "gate")
oGOk.Guards("gate", "send")
oGOk.Feeds("gate", "send")
oGOk.Traces("send", "audit")
? oGOk.IsSound()
#--> TRUE
```

## 5. Rehearse in a safe world

Give the agent a workbench, and everything it writes lands there. The disk does not move; the only thing
that comes out is a plan.

```ring
oAg = oDecl.ToAgent()
oAg.GiveWorkbench()
cHere = StzReplace(currentdir(), char(92), "/")
cNote = cHere + "/t_edu_note_" + ProcessId() + ".txt"
oAg.WorkbenchQ().WriteFile(cNote, "stock is low")
? fexists(cNote)
#--> FALSE
? oAg.WorkbenchQ().ContentOf(cNote)
#--> stock is low
oPlan = oAg.GenerateUpdatePlan()
? oPlan.NumberOfOperations()
#--> 1
```

## 6. An AI cannot commit the plan

```ring
oPlan.SetExecutor( LLMActor("helper") )
aMay = oPlan.MayCommit()
? aMay[1]
#--> FALSE
? aMay[2]
#--> actor 'helper' cannot commit -- it lacks the 'effectful' capability (required by operation 1)
```

## 7. Only a committing actor, inside its scope, changes reality

The proposer is creative. The committer is deterministic, holds the capability, and may touch one folder
and nothing else. Now, and only now, the file exists.

```ring
oPlan2 = oAg.GenerateUpdatePlan()
oPlan2.SetExecutor( PIActor("committer") )
oScope = new stzCommitScope()
oScope.AllowUnder(cHere)
oPlan2.SetScope(oScope)
aRes = oPlan2.Execute()
? aRes[1][2]
#--> TRUE
? fexists(cNote)
#--> TRUE
remove(cNote)
```

{{exercise:ex-14-01}}

{{exercise:ex-14-02}}

{{exercise:ex-14-03}}

## Recap

- **Achieved:** you declared an agent and had the court admit it and refuse its careless twin, wired a
  proposal through a gate and saw the unsound shape named, and rehearsed an action that never touched the
  disk and that an AI could not commit.
- **Why it matters:** a student can build an agent because the agent cannot do harm. The safety is in
  the court, the gate and the rehearsal room, not in the student's good intentions.
- **Coming next:** the instruments that checked every chapter of this course, in your hands.
