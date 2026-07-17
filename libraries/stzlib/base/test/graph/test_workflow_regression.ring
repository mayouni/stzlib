# Integration regression suite for stzWorkflow.
# Extends stzGraph -- supports sequential workflows (Steps + ConnectSteps)
# and state-machine workflows (States + Transitions).
#
# Run from base/graph/test/.

load "../../stzBase.ring"

nPsd = 0
nFld = 0
nTtl = 0

? "=== stzWorkflow integration regression ==="

# ------------------------------------------------------------
# Construction + type
# ------------------------------------------------------------
? ""
? "--- Construction ---"

oWf = new stzWorkflow("wf1")
chk("Created without error",        isObject(oWf))
chk("Name preserved (lowercased)",  oWf.Name() = "wf1")

oWf.SetWorkflowType("sequential")
chk("SetWorkflowType sequential",   oWf.WorkflowType() = "sequential")
chk("IsSequential = TRUE",          oWf.IsSequential() = TRUE)
chk("IsStateMachine = FALSE",       oWf.IsStateMachine() = FALSE)

oWf.SetWorkflowType("statemachine")
chk("Switch to statemachine",       oWf.IsStateMachine() = TRUE)
chk("IsSequential = FALSE now",     oWf.IsSequential() = FALSE)

# Invalid type silently ignored (acceptable)
oWf.SetWorkflowType("invalid")
chk("Invalid type ignored",         oWf.WorkflowType() = "statemachine")

# ------------------------------------------------------------
# Sequential workflow: Steps
# ------------------------------------------------------------
? ""
? "--- Sequential ---"

oSq = new stzWorkflow("seq")
oSq.SetWorkflowType("sequential")

oSq.AddStep_("start")
oSq.AddStepXT("process", "Process Data")
oSq.AddStepXTT("end_", "End", [ [ "color", "green" ] ])

aS = oSq.Steps()
chk("Steps len = 3",                len(aS) = 3)
chk("Step[1] id = start",           aS[1][:id] = "start")
chk("Step[2] label = Process Data", aS[2][:label] = "Process Data")
chk("Step nodes added",             oSq.NodeExists("start") = 1 and oSq.NodeExists("process") = 1 and oSq.NodeExists("end_") = 1)

# Step_ getter
aStep = oSq.Step_("process")
chk("Step_('process') returns",     isList(aStep))
chk("Returned step is right one",   aStep[:id] = "process")

# Missing step returns empty list
chk("Missing step returns []",      len(oSq.Step_("missing")) = 0)

# ConnectSteps -> Then
oSq.ConnectSteps("start", "process")
oSq.Then("process", "end_")
chk("2 edges after connect+then",   oSq.NumberOfEdges() = 2)

# ------------------------------------------------------------
# State machine
# ------------------------------------------------------------
? ""
? "--- State machine ---"

oSm = new stzWorkflow("sm")
oSm.SetWorkflowType("statemachine")

oSm.AddState("idle")
oSm.AddStateXT("active", "Active")
chk("States len = 2",               len(oSm.States()) = 2)
chk("idle node exists",             oSm.NodeExists("idle") = 1)

oSm.AddTransition("idle", "active", "start_event")
chk("Transition created (edge)",    oSm.NumberOfEdges() = 1)

aTr = oSm.Transitions()
chk("Transitions returns list",     isList(aTr))

# State() getter
aSt = oSm.State("idle")
chk("State('idle') returns",        isList(aSt) and aSt[:id] = "idle")

# ------------------------------------------------------------
# Edges
# ------------------------------------------------------------
? ""
? "--- Edges ---"

# Empty workflow
oEm = new stzWorkflow("em")
chk("Empty Steps = 0",              len(oEm.Steps()) = 0)
chk("Empty States = 0",             len(oEm.States()) = 0)

# Single step
oOne = new stzWorkflow("one")
oOne.AddStep_("only")
chk("Single step added",            len(oOne.Steps()) = 1)
chk("Single node exists",           oOne.NodeExists("only") = 1)

# ------------------------------------------------------------
# Summary
# ------------------------------------------------------------
? ""
? "=========================="
? "Total:  " + nTtl
? "Passed: " + nPsd
? "Failed: " + nFld
if nFld = 0
	? "ALL stzWorkflow CHECKS PASSED!"
else
	? "SOME stzWorkflow CHECKS FAILED!"
ok

func chk(cLabel, bCond)
	nTtl++
	if bCond
		nPsd++
	else
		nFld++
		? "  FAIL: " + cLabel
	ok
