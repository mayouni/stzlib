load "../../stzBase.ring"
load "../_narrated.ring"

# stzWorkflowSimulation (base/graph/stzWorkflow.ring) -- the three register rows, run on small workflows whose
# answers were worked out by hand BEFORE the code was run.
#
#   W  the diamond with a tail, five steps, durations in hours, actors in brackets
#
#            +--> b (3) [ana] --+
#      a (2) [ana]              +--> d (5) [bob] --> e (1) [ana]
#            +--> c (4) [bob] --+
#
#      sum of the durations           2+3+4+5+1       = 15
#      critical path                  a c d e         = 2+4+5+1 = 12   (a b d e is 2+3+5+1 = 11)
#      load of ana (a, b, e)          2+3+1           = 6
#      load of bob (c, d)             4+5             = 9
#
#   L  the chain  x (3) --> y (4) --> z (5),  sum 12, critical path x y z = 12
#
# What each row was: OptimizeStep, ReassignStep and ParallelizeSteps appended to a list called @aChanges that the
# class never declared, and the class had no init of its own, so the first line of each raised R24 "Using
# uninitialized variable: @achanges" and no object of the class could record anything. The fix is an init that
# keeps the workflow, the list declared with the attributes, and a check of every argument BEFORE anything is
# stored. The class already had a consumer, a private _ApplyChanges that reads the records by the keys type, step,
# newDuration, to and steps; it used a workflow attribute nobody declared, so it is made reachable by Apply, which
# works on a copy. What stays unwritten, and is checked here as a limit: the restructuring for parallel steps.
# Run from inside this folder. ASCII only on the console.

oW = WsBuildDiamond()
oL = WsBuildChain()

Scenario("The fixtures really are what the header says")
	Then("W has five steps", len(oW.Steps()), 5)
	Then("W sums to 15 hours", oW.TotalDuration(), 15)
	aCp = oW.CriticalPath()
	Then("W's critical path is a c d e", WsJoin(aCp[:path]), "a c d e")
	Then("W's critical path takes 12 hours", aCp[:duration], 12)
	Then("ana carries 6 hours in W", WsLoadOf(oW, "ana"), 6)
	Then("bob carries 9 hours in W", WsLoadOf(oW, "bob"), 9)
	Then("L sums to 12 hours", oL.TotalDuration(), 12)
EndScenario()

Scenario("The reproduction: an object built over a workflow records a change, where it used to raise R24")
	oSim = new stzWorkflowSimulation(oW)
	Then("a new simulation has recorded nothing", len(oSim.Changes()), 0)
	cMsg = WsTryOptimize(oSim, "c", 1)
	Then("OptimizeStep no longer raises", cMsg, "")
	Then("it recorded one change", len(oSim.Changes()), 1)
	cMsg = WsTryReassign(oSim, "b", "ana", "bob")
	Then("ReassignStep no longer raises", cMsg, "")
	cMsg = WsTryParallel(oSim, [ "b", "c" ])
	Then("ParallelizeSteps no longer raises", cMsg, "")
	Then("three changes are recorded", len(oSim.Changes()), 3)
	Then("no message mentions the old uninitialized variable", WsHas(WsTryOptimize(oSim, "c", 1), "uninitialized"), 0)
EndScenario()

Scenario("init: what it accepts and what it refuses")
	cMsg = WsTryBuild("not a workflow")
	Then("a text is refused", WsHas(cMsg, "needs a stzWorkflow"), 1)
	Then("a number is refused", WsHas(WsTryBuild(42), "needs a stzWorkflow"), 1)
	Then("a list is refused", WsHas(WsTryBuild([ 1, 2 ]), "needs a stzWorkflow"), 1)
	oPlain = new stzGraph("g")
	Then("another kind of object is refused", WsHas(WsTryBuild(oPlain), "needs a stzWorkflow"), 1)
	Then("a stzWorkflow is accepted", WsTryBuild(oW), "")
	cMsg = WsTryEmptyParens()
	Then("empty parentheses still raise R19, the inherited init takes one parameter", WsHas(cMsg, "R19"), 1)
	oBare = new stzWorkflowSimulation
	Then("without parentheses the object is built, with nothing recorded", len(oBare.Changes()), 0)
	Then("OptimizeStep on it says there is no workflow", WsHas(WsTryOptimize(oBare, "a", 1), "has no workflow"), 1)
	Then("ReassignStep on it says so", WsHas(WsTryReassign(oBare, "a", "x", "y"), "has no workflow"), 1)
	Then("ParallelizeSteps on it says so", WsHas(WsTryParallel(oBare, [ "a", "b" ]), "has no workflow"), 1)
	Then("Apply on it says so", WsHas(WsTryApply(oBare), "has no workflow"), 1)
	Then("and none of them recorded anything", len(oBare.Changes()), 0)
EndScenario()

Scenario("OptimizeStep: the record has the shape the consumer reads")
	oSim = new stzWorkflowSimulation(oW)
	oSim.OptimizeStep("c", 1)
	aAll = oSim.Changes()
	aRec = aAll[1]
	Then("the record has three keys", len(aRec), 3)
	Then("its type is optimize_step", aRec[:type], "optimize_step")
	Then("its step is c", aRec[:step], "c")
	Then("its newDuration is 1", aRec[:newDuration], 1)
	Then("a zero duration is accepted, a step can be made free", WsTryOptimize(oSim, "d", 0), "")
	Then("a decimal duration is accepted", WsTryOptimize(oSim, "d", 2.5), "")
	Then("three records now", len(oSim.Changes()), 3)
EndScenario()

Scenario("OptimizeStep: the effect, worked out by hand")
	oSim = new stzWorkflowSimulation(oW)
	oSim.OptimizeStep("c", 1)
	oRes = oSim.Apply()
	Then("c from 4 to 1 hour: the sum falls by 3, 15 to 12", oRes.TotalDuration(), 12)
	aCp = oRes.CriticalPath()
	Then("the critical path moves to a b d e", WsJoin(aCp[:path]), "a b d e")
	Then("and takes 2+3+5+1 = 11", aCp[:duration], 11)
	Then("the workflow it was built from still sums to 15", oW.TotalDuration(), 15)
	aCp = oW.CriticalPath()
	Then("and still has its critical path a c d e", WsJoin(aCp[:path]), "a c d e")
	oSim2 = new stzWorkflowSimulation(oW)
	oSim2.OptimizeStep("d", 2)
	oRes2 = oSim2.Apply()
	Then("d from 5 to 2: the sum is 15 - 3 = 12", oRes2.TotalDuration(), 12)
	aCp = oRes2.CriticalPath()
	Then("the critical path stays a c d e", WsJoin(aCp[:path]), "a c d e")
	Then("and takes 2+4+2+1 = 9", aCp[:duration], 9)
	oSim3 = new stzWorkflowSimulation(oW)
	oSim3.OptimizeStep("b", 10)
	oRes3 = oSim3.Apply()
	Then("a step can also be made slower: b to 10 gives 22", oRes3.TotalDuration(), 22)
	aCp = oRes3.CriticalPath()
	Then("and takes 2+10+5+1 = 18 over a b d e", WsJoin(aCp[:path]) + " " + aCp[:duration], "a b d e 18")
	oSim4 = new stzWorkflowSimulation(oW)
	oSim4.OptimizeStep("c", 1)
	oSim4.OptimizeStep("c", 6)
	oRes4 = oSim4.Apply()
	Then("two changes to one step: the last wins, c at 6 gives 2+3+6+5+1 = 17", oRes4.TotalDuration(), 17)
	oSim5 = new stzWorkflowSimulation(oW)
	Then("with nothing recorded the copy sums to 15 like the original", WsApplyTotal(oSim5), 15)
EndScenario()

Scenario("OptimizeStep: what it refuses, and a refusal records nothing")
	oSim = new stzWorkflowSimulation(oW)
	oSim.OptimizeStep("a", 1)
	cBefore = @@(oSim.Changes())
	Then("an unknown step is refused by name", WsHas(WsTryOptimize(oSim, "zz", 1), "unknown step 'zz'"), 1)
	Then("an id in another case is unknown, as the workflow compares ids", WsHas(WsTryOptimize(oSim, "A", 1), "unknown step"), 1)
	Then("an empty id is refused", WsHas(WsTryOptimize(oSim, "", 1), "cannot be empty"), 1)
	Then("a blank id is refused", WsHas(WsTryOptimize(oSim, "   ", 1), "cannot be empty"), 1)
	Then("an id that is a number is refused", WsHas(WsTryOptimize(oSim, 5, 1), "must be a text"), 1)
	Then("an id that is a list is refused", WsHas(WsTryOptimize(oSim, [ "a" ], 1), "must be a text"), 1)
	Then("a negative duration is refused", WsHas(WsTryOptimize(oSim, "b", -1), "cannot be negative"), 1)
	Then("a duration given as text is refused", WsHas(WsTryOptimize(oSim, "b", "5"), "must be a number"), 1)
	Then("a duration given as a list is refused", WsHas(WsTryOptimize(oSim, "b", [ 5 ]), "must be a number"), 1)
	Then("seven failed calls left the list as it was", @@(oSim.Changes()), cBefore)
	Then("and still one record", len(oSim.Changes()), 1)
	Then("the next good call is recorded after it", WsTryOptimize(oSim, "b", 1), "")
	Then("two records", len(oSim.Changes()), 2)
EndScenario()

Scenario("ReassignStep: the record has the shape the consumer reads")
	oSim = new stzWorkflowSimulation(oW)
	oSim.ReassignStep("b", "ana", "bob")
	aAll = oSim.Changes()
	aRec = aAll[1]
	Then("the record has four keys", len(aRec), 4)
	Then("its type is reassign_step", aRec[:type], "reassign_step")
	Then("its step is b", aRec[:step], "b")
	Then("it keeps the actor it leaves", aRec[:from], "ana")
	Then("and the actor it goes to", aRec[:to], "bob")
EndScenario()

Scenario("ReassignStep: the effect on the load of the actors, worked out by hand")
	oSim = new stzWorkflowSimulation(oW)
	oSim.ReassignStep("b", "ana", "bob")
	oRes = oSim.Apply()
	aStep = oRes.Step_("b")
	Then("b now belongs to bob in the copy", aStep[:assignedTo], "bob")
	Then("ana falls from 6 to 6-3 = 3 hours", WsLoadOf(oRes, "ana"), 3)
	Then("bob rises from 9 to 9+3 = 12 hours", WsLoadOf(oRes, "bob"), 12)
	Then("moving a step changes no duration, the sum stays 15", oRes.TotalDuration(), 15)
	aStep = oW.Step_("b")
	Then("in the original b still belongs to ana", aStep[:assignedTo], "ana")
	Then("ana still carries 6 in the original", WsLoadOf(oW, "ana"), 6)
	Then("bob still carries 9 in the original", WsLoadOf(oW, "bob"), 9)
	Then("the node property of the copy follows", oRes.NodeProperty("b", "assignedTo"), "bob")
	Then("the node property of the original does not", oW.NodeProperty("b", "assignedTo"), "ana")
	oSim2 = new stzWorkflowSimulation(oW)
	oSim2.ReassignStep("b", "ana", "bob")
	oSim2.ReassignStep("b", "bob", "cleo")
	oRes2 = oSim2.Apply()
	aStep = oRes2.Step_("b")
	Then("two moves of one step: the last one wins", aStep[:assignedTo], "cleo")
	Then("bob is back to 9", WsLoadOf(oRes2, "bob"), 9)
	Then("and cleo carries 3", WsLoadOf(oRes2, "cleo"), 3)
EndScenario()

Scenario("ReassignStep: what it refuses, and a refusal records nothing")
	oSim = new stzWorkflowSimulation(oW)
	cBefore = @@(oSim.Changes())
	Then("an unknown step is refused", WsHas(WsTryReassign(oSim, "zz", "ana", "bob"), "unknown step 'zz'"), 1)
	Then("an empty step id is refused", WsHas(WsTryReassign(oSim, "", "ana", "bob"), "cannot be empty"), 1)
	Then("an empty actor it leaves is refused", WsHas(WsTryReassign(oSim, "b", "", "bob"), "from actor cannot be empty"), 1)
	Then("an empty actor it goes to is refused", WsHas(WsTryReassign(oSim, "b", "ana", ""), "to actor cannot be empty"), 1)
	Then("a blank actor is refused", WsHas(WsTryReassign(oSim, "b", "ana", "  "), "to actor cannot be empty"), 1)
	Then("an actor that is a number is refused", WsHas(WsTryReassign(oSim, "b", "ana", 7), "to actor must be a text"), 1)
	Then("an actor that is a list is refused", WsHas(WsTryReassign(oSim, "b", [ "ana" ], "bob"), "from actor must be a text"), 1)
	Then("six failed calls recorded nothing", @@(oSim.Changes()), cBefore)
	Then("the actor it leaves is recorded as given, even when it is not the step's actor",
		WsTryReassign(oSim, "b", "someone", "bob"), "")
	Then("an actor the workflow does not know is accepted, as AssignStepTo accepts it",
		WsTryReassign(oSim, "c", "bob", "nobody_known"), "")
	Then("two records", len(oSim.Changes()), 2)
EndScenario()

Scenario("ParallelizeSteps: the record has the shape the consumer reads")
	oSim = new stzWorkflowSimulation(oW)
	oSim.ParallelizeSteps([ "b", "c" ])
	aAll = oSim.Changes()
	aRec = aAll[1]
	Then("the record has two keys", len(aRec), 2)
	Then("its type is parallelize", aRec[:type], "parallelize")
	Then("its steps are the two ids, in order", WsJoin(aRec[:steps]), "b c")
	Then("three steps are accepted", WsTryParallel(oSim, [ "a", "d", "e" ]), "")
	Then("two records", len(oSim.Changes()), 2)
	aAll = oSim.Changes()
	aRec = aAll[2]
	Then("the second keeps its three ids", WsJoin(aRec[:steps]), "a d e")
EndScenario()

Scenario("ParallelizeSteps: it is recorded, and applying it changes nothing yet (the stated limit)")
	oSim = new stzWorkflowSimulation(oL)
	oSim.ParallelizeSteps([ "y", "z" ])
	Then("one record on the chain", len(oSim.Changes()), 1)
	oRes = oSim.Apply()
	Then("the chain still sums to 12, not to the 3+5 = 8 a side by side y and z would give", oRes.TotalDuration(), 12)
	aCp = oRes.CriticalPath()
	Then("its critical path is still x y z", WsJoin(aCp[:path]), "x y z")
	Then("and still takes 12 hours, the restructuring is not written", aCp[:duration], 12)
	Then("applying it does not raise", WsTryApply(oSim), "")
	oMix = new stzWorkflowSimulation(oL)
	oMix.OptimizeStep("z", 1)
	oMix.ParallelizeSteps([ "x", "y" ])
	oMix.OptimizeStep("y", 2)
	Then("the other changes around it are applied in order: 3+2+1 = 6", WsApplyTotal(oMix), 6)
EndScenario()

Scenario("ParallelizeSteps: what it refuses, and a refusal records nothing")
	oSim = new stzWorkflowSimulation(oW)
	oSim.ParallelizeSteps([ "b", "c" ])
	cBefore = @@(oSim.Changes())
	Then("one step is refused", WsHas(WsTryParallel(oSim, [ "b" ]), "at least two steps"), 1)
	Then("an empty list is refused", WsHas(WsTryParallel(oSim, []), "at least two steps"), 1)
	Then("a text instead of a list is refused", WsHas(WsTryParallel(oSim, "b c"), "list of step ids"), 1)
	Then("a number instead of a list is refused", WsHas(WsTryParallel(oSim, 5), "list of step ids"), 1)
	Then("an unknown step among good ones is refused", WsHas(WsTryParallel(oSim, [ "b", "zz" ]), "unknown step 'zz'"), 1)
	Then("the unknown step in first place is refused", WsHas(WsTryParallel(oSim, [ "zz", "b" ]), "unknown step 'zz'"), 1)
	Then("a step listed twice is refused", WsHas(WsTryParallel(oSim, [ "b", "c", "b" ]), "listed twice"), 1)
	Then("a member that is a number is refused", WsHas(WsTryParallel(oSim, [ "b", 3 ]), "must be a text"), 1)
	Then("an empty member is refused", WsHas(WsTryParallel(oSim, [ "b", "" ]), "cannot be empty"), 1)
	Then("eight failed calls left the list as it was", @@(oSim.Changes()), cBefore)
	Then("and still one record", len(oSim.Changes()), 1)
EndScenario()

Scenario("Changes and Apply: copies, order, and no hidden state")
	oSim = new stzWorkflowSimulation(oW)
	oSim.OptimizeStep("a", 1)
	oSim.ReassignStep("e", "ana", "bob")
	oSim.ParallelizeSteps([ "b", "c" ])
	aGot = oSim.Changes()
	Then("the changes come back in the order they were recorded", aGot[1][:type] + " " + aGot[2][:type] + " " + aGot[3][:type],
		"optimize_step reassign_step parallelize")
	aGot[1][:newDuration] = 99
	aAgain = oSim.Changes()
	Then("changing the returned list does not reach the simulation", aAgain[1][:newDuration], 1)
	oR1 = oSim.Apply()
	oR2 = oSim.Apply()
	Then("applying twice gives the same sum, a: 15 - 2 + 1 = 14", "" + oR1.TotalDuration() + " " + oR2.TotalDuration(), "14 14")
	Then("Apply did not consume the changes", len(oSim.Changes()), 3)
	Then("and the original is untouched, still 15", oW.TotalDuration(), 15)
	Then("e is bob's in the copy: ana 1+3 = 4", WsLoadOf(oR1, "ana"), 4)
	Then("a is 1 hour in the copy and 2 in the original", "" + WsStepDur(oR1, "a") + " " + WsStepDur(oW, "a"), "1 2")
EndScenario()

Scenario("The simulation works on a copy of the workflow it was built from")
	oMine = WsBuildDiamond()
	oSim = new stzWorkflowSimulation(oMine)
	oMine.SetStepDuration("a", 50)
	Then("the caller changes the workflow after building the simulation", oMine.TotalDuration(), 63)
	Then("the simulation does not see it, the copy still sums to 15", WsApplyTotal(oSim), 15)
	oSim.OptimizeStep("e", 3)
	Then("its changes apply to its own copy: 15 - 1 + 3 = 17", WsApplyTotal(oSim), 17)
	Then("the caller's workflow is not changed by Apply, e is still 1 hour", WsStepDur(oMine, "e"), 1)
	Then("a step that exists only in the caller's later workflow is unknown to the simulation",
		WsHas(WsTryOptimize(oSim, "late", 1), "unknown step 'late'"), 1)
EndScenario()

Scenario("Chaining: the three methods return nothing, so a chain stops after the first call")
	oSim = new stzWorkflowSimulation(oW)
	cMsg = WsTryChain(oSim)
	Then("the second call of a chain has no object to run on", WsHas(cMsg, "R13"), 1)
	Then("the first call was recorded before that", len(oSim.Changes()), 1)
	oSim.ReassignStep("b", "ana", "bob")
	Then("separate statements on the variable accumulate", len(oSim.Changes()), 2)
EndScenario()

Scenario("A simulation over a different workflow: nothing leaks between objects")
	oSimA = new stzWorkflowSimulation(oW)
	oSimB = new stzWorkflowSimulation(oL)
	oSimA.OptimizeStep("a", 1)
	Then("B has recorded nothing", len(oSimB.Changes()), 0)
	Then("B does not know A's steps", WsHas(WsTryOptimize(oSimB, "a", 1), "unknown step 'a'"), 1)
	Then("A does not know B's steps", WsHas(WsTryOptimize(oSimA, "x", 1), "unknown step 'x'"), 1)
	Then("B sums to 12 and A to 14", "" + WsApplyTotal(oSimB) + " " + WsApplyTotal(oSimA), "12 14")
EndScenario()

Summary()

#----------------------------------------------------------------------#
#  helpers -- at the end of the file, top-level code after a func would
#  become part of that func
#----------------------------------------------------------------------#

func WsBuildDiamond()
	oB = new stzWorkflow("diamond")
	oB.AddStep_("a")
	oB.AddStep_("b")
	oB.AddStep_("c")
	oB.AddStep_("d")
	oB.AddStep_("e")
	oB.SetStepDuration("a", 2)
	oB.SetStepDuration("b", 3)
	oB.SetStepDuration("c", 4)
	oB.SetStepDuration("d", 5)
	oB.SetStepDuration("e", 1)
	oB.ConnectSteps("a", "b")
	oB.ConnectSteps("a", "c")
	oB.ConnectSteps("b", "d")
	oB.ConnectSteps("c", "d")
	oB.ConnectSteps("d", "e")
	oB.AssignStepTo("a", "ana")
	oB.AssignStepTo("b", "ana")
	oB.AssignStepTo("c", "bob")
	oB.AssignStepTo("d", "bob")
	oB.AssignStepTo("e", "ana")
	return oB

func WsBuildChain()
	oB = new stzWorkflow("chain")
	oB.AddStep_("x")
	oB.AddStep_("y")
	oB.AddStep_("z")
	oB.SetStepDuration("x", 3)
	oB.SetStepDuration("y", 4)
	oB.SetStepDuration("z", 5)
	oB.ConnectSteps("x", "y")
	oB.ConnectSteps("y", "z")
	return oB

# the hours an actor carries: the durations of the steps assigned to it
func WsLoadOf(poWf, pcActor)
	aSteps = poWf.Steps()
	nSum = 0
	for i = 1 to len(aSteps)
		if aSteps[i][:assignedTo] = pcActor
			nSum += aSteps[i][:duration]
		ok
	next
	return nSum

func WsStepDur(poWf, pcId)
	aS = poWf.Step_(pcId)
	return aS[:duration]

func WsApplyTotal(poSim)
	oApplied = poSim.Apply()
	return oApplied.TotalDuration()

func WsJoin(paList)
	cOut = ""
	for i = 1 to len(paList)
		if i > 1
			cOut += " "
		ok
		cOut += "" + paList[i]
	next
	return cOut

func WsHas(pcText, pcPart)
	if substr(pcText, pcPart) > 0
		return 1
	ok
	return 0

# each Try* returns the message of the error, or the empty text when nothing was raised
func WsTryBuild(pArg)
	cMsg = ""
	try
		oX = new stzWorkflowSimulation(pArg)
	catch
		cMsg = cCatchError
	done
	return cMsg

func WsTryEmptyParens()
	cMsg = ""
	try
		oX = new stzWorkflowSimulation()
	catch
		cMsg = cCatchError
	done
	return cMsg

func WsTryOptimize(poSim, pcId, pnDur)
	cMsg = ""
	try
		poSim.OptimizeStep(pcId, pnDur)
	catch
		cMsg = cCatchError
	done
	return cMsg

func WsTryReassign(poSim, pcId, pcFrom, pcTo)
	cMsg = ""
	try
		poSim.ReassignStep(pcId, pcFrom, pcTo)
	catch
		cMsg = cCatchError
	done
	return cMsg

func WsTryParallel(poSim, paIds)
	cMsg = ""
	try
		poSim.ParallelizeSteps(paIds)
	catch
		cMsg = cCatchError
	done
	return cMsg

func WsTryApply(poSim)
	cMsg = ""
	try
		oX = poSim.Apply()
	catch
		cMsg = cCatchError
	done
	return cMsg

func WsTryChain(poSim)
	cMsg = ""
	try
		poSim.OptimizeStep("a", 1).ReassignStep("b", "ana", "bob")
	catch
		cMsg = cCatchError
	done
	return cMsg
