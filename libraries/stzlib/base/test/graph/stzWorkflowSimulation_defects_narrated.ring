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
# works on a copy. The restructuring for parallel steps was written in a second batch (see the scenarios from
# "the chain x y z with y and z side by side" on): the arrows between the steps of a group go, each of them waits
# for what came before any of them, what came after any of them waits for all of them, and a group linked
# through another step is refused by Apply. The Q forms (OptimizeStepQ, ReassignStepQ, ParallelizeStepsQ) were
# added with it. Run from inside this folder. ASCII only on the console.

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

Scenario("ParallelizeSteps: the chain x y z with y and z side by side (it used to change nothing; the expected result changed on purpose)")
	oSim = new stzWorkflowSimulation(oL)
	oSim.ParallelizeSteps([ "y", "z" ])
	Then("one record on the chain", len(oSim.Changes()), 1)
	oRes = oSim.Apply()
	Then("the sum stays 12, only the shape of the flow moves", oRes.TotalDuration(), 12)
	aCp = oRes.CriticalPath()
	Then("the critical path is x z, y is beside z and no longer before it", WsJoin(aCp[:path]), "x z")
	Then("and takes 3 + max(4,5) = 8 hours, the figure the old guard said it could not give", aCp[:duration], 8)
	Then("the arrow y to z is gone", oRes.EdgeExists("y", "z"), 0)
	Then("z now waits for x, what came before y", oRes.EdgeExists("x", "z"), 1)
	Then("x to y is kept", oRes.EdgeExists("x", "y"), 1)
	Then("one arrow removed and one added: 2 arrows before, 2 after", "" + len(oL.Edges()) + " " + len(oRes.Edges()), "2 2")
	Then("the workflow it was built from still has its critical path x y z", WsCpPath(oL), "x y z")
	Then("and still has the arrow y to z", oL.EdgeExists("y", "z"), 1)
	Then("applying does not raise", WsTryApply(oSim), "")
	oSimR = new stzWorkflowSimulation(oL)
	oSimR.ParallelizeSteps([ "z", "y" ])
	oResR = oSimR.Apply()
	Then("the order of the ids in the list does not matter: the same path", WsCpPath(oResR), "x z")
	Then("and the same 8 hours", WsCpDur(oResR), 8)
	Then("and the same arrows, 2 of them", "" + len(oResR.Edges()) + " " + oResR.EdgeExists("x", "y") + oResR.EdgeExists("x", "z") + oResR.EdgeExists("y", "z"), "2 110")
	oMix = new stzWorkflowSimulation(oL)
	oMix.OptimizeStep("z", 1)
	oMix.ParallelizeSteps([ "x", "y" ])
	oMix.OptimizeStep("y", 2)
	Then("the other changes around it are applied in order: 3+2+1 = 6", WsApplyTotal(oMix), 6)
EndScenario()

Scenario("ParallelizeSteps: the diamond, a group that already runs side by side changes nothing")
	oSim = new stzWorkflowSimulation(oW)
	oSim.ParallelizeSteps([ "b", "c" ])
	oRes = oSim.Apply()
	Then("b and c are two branches of a: the five arrows stay five", "" + len(oW.Edges()) + " " + len(oRes.Edges()), "5 5")
	Then("a to b is kept", oRes.EdgeExists("a", "b"), 1)
	Then("a to c is kept", oRes.EdgeExists("a", "c"), 1)
	Then("b to d is kept", oRes.EdgeExists("b", "d"), 1)
	Then("c to d is kept", oRes.EdgeExists("c", "d"), 1)
	Then("d to e is kept", oRes.EdgeExists("d", "e"), 1)
	Then("no arrow between b and c was invented, either way", "" + oRes.EdgeExists("b", "c") + oRes.EdgeExists("c", "b"), "00")
	Then("the sum stays 15", oRes.TotalDuration(), 15)
	aCp = oRes.CriticalPath()
	Then("the critical path is still a c d e", WsJoin(aCp[:path]), "a c d e")
	Then("with 12 hours", aCp[:duration], 12)
	oSim.ParallelizeSteps([ "b", "c" ])
	oRes2 = oSim.Apply()
	Then("recorded twice, it is still five arrows and no doubled one", len(oRes2.Edges()), 5)
EndScenario()

Scenario("ParallelizeSteps: the diamond with a and b side by side, worked out by hand")
	# a (2) and b (3) side by side. The arrow a to b goes. Before the group: nothing. After the group: c (after a)
	# and d (after b). c and d now wait for both a and b, so b to c and a to d are added, a to c and b to d stay.
	# Arrows: a>c a>d b>c b>d c>d d>e, six. Paths: a c d e 12, b c d e 13, a d e 8, b d e 9. The critical one is 13.
	oSim = new stzWorkflowSimulation(oW)
	oSim.ParallelizeSteps([ "a", "b" ])
	oRes = oSim.Apply()
	Then("five arrows, one removed, two added: six", len(oRes.Edges()), 6)
	Then("a to b is removed", oRes.EdgeExists("a", "b"), 0)
	Then("a to c is kept", oRes.EdgeExists("a", "c"), 1)
	Then("b to d is kept", oRes.EdgeExists("b", "d"), 1)
	Then("c to d is kept", oRes.EdgeExists("c", "d"), 1)
	Then("d to e is kept", oRes.EdgeExists("d", "e"), 1)
	Then("b to c is added, c waits for b too", oRes.EdgeExists("b", "c"), 1)
	Then("a to d is added, d waits for a too", oRes.EdgeExists("a", "d"), 1)
	Then("the sum stays 15", oRes.TotalDuration(), 15)
	aCp = oRes.CriticalPath()
	Then("the critical path is b c d e", WsJoin(aCp[:path]), "b c d e")
	Then("it takes max(2,3) + 4 + 5 + 1 = 13 hours", aCp[:duration], 13)
	Then("there are four paths from the two starts to e", len(oRes.AllPathsFromStartToEnd()), 4)
	Then("the original is untouched: five arrows", len(oW.Edges()), 5)
	Then("the original still has a to b", oW.EdgeExists("a", "b"), 1)
	Then("and its critical path a c d e of 12 hours", WsCpPath(oW) + " " + WsCpDur(oW), "a c d e 12")
	oSimR = new stzWorkflowSimulation(oW)
	oSimR.ParallelizeSteps([ "b", "a" ])
	oResR = oSimR.Apply()
	Then("the list in the other order: six arrows", len(oResR.Edges()), 6)
	Then("the same critical path", WsCpPath(oResR) + " " + WsCpDur(oResR), "b c d e 13")
	Then("the same removed arrow", oResR.EdgeExists("a", "b"), 0)
	Then("the same added arrows", "" + oResR.EdgeExists("b", "c") + oResR.EdgeExists("a", "d"), "11")
	Then("applying again gives six arrows again, nothing is doubled", WsApplyEdges(oSim), 6)
EndScenario()

Scenario("ParallelizeSteps: a group with nothing between its steps, and a group recorded after another")
	oTwo = WsBuildTwoChains()
	oSim = new stzWorkflowSimulation(oTwo)
	oSim.ParallelizeSteps([ "q", "s" ])
	oRes = oSim.Apply()
	# p>q and r>s, q and s not connected. Before the group: p and r. Nothing to remove. q and s both wait for p and r.
	Then("two chains, q and s unconnected: 2 arrows become 4", "" + len(oTwo.Edges()) + " " + len(oRes.Edges()), "2 4")
	Then("r to q is added", oRes.EdgeExists("r", "q"), 1)
	Then("p to s is added", oRes.EdgeExists("p", "s"), 1)
	Then("p to q is kept", oRes.EdgeExists("p", "q"), 1)
	Then("r to s is kept", oRes.EdgeExists("r", "s"), 1)
	Then("the sum stays 14", oRes.TotalDuration(), 14)
	Then("the critical path is r s, 4+5 = 9 hours", WsCpPath(oRes) + " " + WsCpDur(oRes), "r s 9")
	oIso = WsBuildIsolated()
	oSimI = new stzWorkflowSimulation(oIso)
	oSimI.ParallelizeSteps([ "m", "n" ])
	Then("two steps with no arrow at all: applying does not raise", WsTryApply(oSimI), "")
	oResI = oSimI.Apply()
	Then("there is nothing to remove or to add: no arrow", len(oResI.Edges()), 0)
	Then("and the sum is 5", oResI.TotalDuration(), 5)
	oSimS = new stzWorkflowSimulation(oL)
	oSimS.ParallelizeSteps([ "y", "z" ])
	oSimS.ParallelizeSteps([ "x", "y" ])
	oResS = oSimS.Apply()
	# after y z: x>y x>z. Then x y side by side: x>y goes, nothing before, after: z (x>z). y>z is added. Arrows x>z y>z.
	Then("a second group sees the arrows the first left: 2 arrows", len(oResS.Edges()), 2)
	Then("x to y is gone", oResS.EdgeExists("x", "y"), 0)
	Then("x to z is kept", oResS.EdgeExists("x", "z"), 1)
	Then("y to z is back, y now waits for nothing and z for both", oResS.EdgeExists("y", "z"), 1)
	Then("the critical path is y z, 4+5 = 9 hours", WsCpPath(oResS) + " " + WsCpDur(oResS), "y z 9")
	Then("the sum is still 12", oResS.TotalDuration(), 12)
	oSimT = new stzWorkflowSimulation(oL)
	oSimT.ParallelizeSteps([ "y", "z" ])
	oSimT.ParallelizeSteps([ "y", "z" ])
	Then("the same group recorded twice is not doubled: 2 arrows", WsApplyEdges(oSimT), 2)
EndScenario()

Scenario("Apply refuses steps linked through other steps, and the simulation stays usable")
	cWhy = "can't parallelize steps that are linked through other steps"
	oLk = WsBuildLinked()
	oSim = new stzWorkflowSimulation(oLk)
	oSim.OptimizeStep("x", 10)
	oSim.ParallelizeSteps([ "y", "z" ])
	Then("recording the group does not raise, the check is Apply's", len(oSim.Changes()), 2)
	cMsg = WsTryApply(oSim)
	Then("x y m z with y and z: Apply says so", WsHas(cMsg, cWhy), 1)
	Then("and names the two steps", WsHas(cMsg, "'y' leads to 'z'"), 1)
	Then("and the step between them", WsHas(cMsg, "by way of 'm'"), 1)
	Then("the message carries the class and method", WsHas(cMsg, "stzWorkflowSimulation.Apply:"), 1)
	Then("the recorded changes are kept", len(oSim.Changes()), 2)
	Then("the workflow it was built from is as it was: 3 arrows", len(oLk.Edges()), 3)
	Then("and its durations: 1+2+3+4 = 10", oLk.TotalDuration(), 10)
	Then("Apply refuses again the same way, it is not a one-off", WsHas(WsTryApply(oSim), cWhy), 1)
	Then("the simulation still records: an unknown step is still refused by name", WsHas(WsTryOptimize(oSim, "zz", 1), "unknown step 'zz'"), 1)
	Then("a good step is still recorded", WsTryOptimize(oSim, "m", 1), "")
	Then("three changes now", len(oSim.Changes()), 3)
	Then("the working state was rolled back: the optimize before the refusal did not stay (x is 1, not 10)", WsStepDur(oSim.@oGraph, "x"), 1)
	Then("and the working state has its 3 arrows", len(oSim.@oGraph.Edges()), 3)
	oSimOk = new stzWorkflowSimulation(oLk)
	oSimOk.ParallelizeSteps([ "y", "m" ])
	Then("another simulation over the same workflow works: y and m are linked directly, which is allowed", WsTryApply(oSimOk), "")
	oResOk = oSimOk.Apply()
	Then("y m side by side on x y m z: x>y x>m y>z m>z, 4 arrows", len(oResOk.Edges()), 4)
	Then("its critical path is x m z, 1+3+4 = 8 hours", WsCpPath(oResOk) + " " + WsCpDur(oResOk), "x m z 8")
	oSimC = new stzWorkflowSimulation(oL)
	oSimC.ParallelizeSteps([ "x", "z" ])
	Then("the chain x y z with x and z: y is between them, refused", WsHas(WsTryApply(oSimC), cWhy), 1)
	oSimD = new stzWorkflowSimulation(oW)
	oSimD.ParallelizeSteps([ "a", "d" ])
	Then("the diamond with a and d: b and c are between them, refused", WsHas(WsTryApply(oSimD), cWhy), 1)
	oSimE = new stzWorkflowSimulation(oW)
	oSimE.ParallelizeSteps([ "a", "e" ])
	Then("a and e: refused too, the way is longer", WsHas(WsTryApply(oSimE), cWhy), 1)
	oSimF = new stzWorkflowSimulation(oW)
	oSimF.ParallelizeSteps([ "b", "c", "d" ])
	Then("b c d: d is after b and c, directly, so it is allowed", WsTryApply(oSimF), "")
	Then("and gives b c d side by side, a before all, e after all: a>b a>c a>d b>e c>e d>e", WsApplyEdges(oSimF), 6)
EndScenario()

Scenario("The Q forms: they record what the plain forms record and return the simulation")
	oSim = new stzWorkflowSimulation(oW)
	oSimQ = new stzWorkflowSimulation(oW)
	oSim.OptimizeStep("c", 1)
	oSim.ReassignStep("b", "ana", "bob")
	oSim.ParallelizeSteps([ "a", "b" ])
	oSimQ.OptimizeStepQ("c", 1)
	oSimQ.ReassignStepQ("b", "ana", "bob")
	oSimQ.ParallelizeStepsQ([ "a", "b" ])
	Then("three Q calls record the same three changes as three plain calls", @@(oSimQ.Changes()), @@(oSim.Changes()))
	Then("and Apply gives the same sum", WsApplyTotal(oSimQ), WsApplyTotal(oSim))
	Then("and the same critical path", WsApplyCpPath(oSimQ), WsApplyCpPath(oSim))
	oBack = oSim.OptimizeStepQ("d", 2)
	Then("a Q form gives back a simulation", ring_classname(oBack), "stzworkflowsimulation")
	oSimN = new stzWorkflowSimulation(oW)
	Then("a plain form gives back nothing: no object to call on", WsHas(WsTryChain(oSimN), "R13"), 1)
	oSimM = new stzWorkflowSimulation(oW)
	Then("a Q call that fails raises as the plain call does, here for an unknown step in the middle of a chain", WsHas(WsTryChainQ(oSimM, "zz"), "unknown step 'zz'"), 1)
	Then("the call before it was recorded, the failing one was not", len(oSimM.Changes()), 1)
	Then("the second Q form refuses an empty actor", WsHas(WsTryReassignQ(oSimM, "b", "ana", ""), "to actor cannot be empty"), 1)
	Then("the third Q form refuses one step", WsHas(WsTryParallelQ(oSimM, [ "b" ]), "at least two steps"), 1)
	Then("the first Q form refuses a negative duration", WsHas(WsTryOptimizeQ(oSimM, "b", -1), "cannot be negative"), 1)
	Then("and none of the refused calls recorded anything", len(oSimM.Changes()), 1)
	oBare = new stzWorkflowSimulation
	Then("a simulation with no workflow refuses a Q call too", WsHas(WsTryChainQ(oBare, "a"), "has no workflow"), 1)
EndScenario()

Scenario("Chains: a chain in one expression sees every change, and a result kept in a variable is a copy")
	# A chain in one expression runs on the simulation it started from: every call records into it, and the
	# Changes or Apply at the end sees all of them. A value kept in a variable is a copy: the copy and the
	# variable it came from stop sharing changes, each holds those recorded through its own calls.
	oSimA = new stzWorkflowSimulation(oW)
	nSeen = len(oSimA.OptimizeStepQ("a", 1).ReassignStepQ("b", "ana", "bob").ParallelizeStepsQ([ "b", "c" ]).Changes())
	Then("a chain of three Q calls ending with Changes sees the three changes", nSeen, 3)
	Then("and the variable the chain started from holds them too", len(oSimA.Changes()), 3)
	oSimB = new stzWorkflowSimulation(oW)
	oResB = oSimB.OptimizeStepQ("a", 1).ParallelizeStepsQ([ "a", "b" ]).Apply()
	Then("a chain ending with Apply gives the effect of both: 15 - 2 + 1 = 14", oResB.TotalDuration(), 14)
	Then("and a to b is gone in what it gives", oResB.EdgeExists("a", "b"), 0)
	Then("the starting variable holds both changes", len(oSimB.Changes()), 2)
	oSimC = new stzWorkflowSimulation(oW)
	oKept = oSimC.OptimizeStepQ("a", 1)
	Then("a result kept in a variable holds the change made so far", len(oKept.Changes()), 1)
	Then("and so does the variable it came from", len(oSimC.Changes()), 1)
	oKept.ReassignStepQ("b", "ana", "bob")
	Then("a later call on the copy is seen by the copy", len(oKept.Changes()), 2)
	Then("and not by the variable it came from, which holds only its own calls", len(oSimC.Changes()), 1)
	oSimC.OptimizeStepQ("e", 3)
	Then("a later call on the variable is seen by the variable", len(oSimC.Changes()), 2)
	Then("and not by the copy", len(oKept.Changes()), 2)
	Then("the two now differ: the copy has the reassign, the variable the optimize of e", WsChangeType(oKept, 2) + " " + WsChangeType(oSimC, 2), "reassign_step optimize_step")
	nChain = len(oKept.ReassignStepQ("c", "bob", "ana").Changes())
	Then("a chain started from the copy sees the copy's changes and its own: 3", nChain, 3)
	Then("the variable the copy came from is not touched by it", len(oSimC.Changes()), 2)
	Then("the workflow all of them were built from is untouched: 15 and five arrows", "" + oW.TotalDuration() + " " + len(oW.Edges()), "15 5")
EndScenario()

Scenario("All three kinds of change in one simulation, worked out by hand")
	# Diamond: a 2, b 3, c 4, d 5, e 1. Optimize b to 6. Reassign e to bob. Parallelize a and b.
	# Durations: a2 b6 c4 d5 e1, sum 18. Arrows after the group: a>c a>d b>c b>d c>d d>e.
	# Paths: a c d e 12, b c d e 16, a d e 8, b d e 12. Critical b c d e, 16 hours.
	# Load: ana = a + b = 2 + 6 = 8 (e has left her), bob = c + d + e = 4 + 5 + 1 = 10.
	oSim = new stzWorkflowSimulation(oW)
	oSim.OptimizeStep("b", 6)
	oSim.ReassignStep("e", "ana", "bob")
	oSim.ParallelizeSteps([ "a", "b" ])
	oRes = oSim.Apply()
	Then("the sum is 2+6+4+5+1 = 18", oRes.TotalDuration(), 18)
	aCp = oRes.CriticalPath()
	Then("the critical path is b c d e", WsJoin(aCp[:path]), "b c d e")
	Then("and takes 6+4+5+1 = 16 hours", aCp[:duration], 16)
	Then("ana carries 2+6 = 8", WsLoadOf(oRes, "ana"), 8)
	Then("bob carries 4+5+1 = 10", WsLoadOf(oRes, "bob"), 10)
	Then("six arrows", len(oRes.Edges()), 6)
	Then("a to b is gone", oRes.EdgeExists("a", "b"), 0)
	Then("the original is untouched: 15 hours, 5 arrows, ana 6 and bob 9", "" + oW.TotalDuration() + " " + len(oW.Edges()) + " " + WsLoadOf(oW, "ana") + " " + WsLoadOf(oW, "bob"), "15 5 6 9")
	oSimO = new stzWorkflowSimulation(oW)
	oSimO.ParallelizeSteps([ "a", "b" ])
	oSimO.ReassignStep("e", "ana", "bob")
	oSimO.OptimizeStep("b", 6)
	oResO = oSimO.Apply()
	Then("recorded in another order, the same result: 18, b c d e, 16", "" + oResO.TotalDuration() + " " + WsCpPath(oResO) + " " + WsCpDur(oResO), "18 b c d e 16")
	Then("and the same loads, 8 and 10", "" + WsLoadOf(oResO, "ana") + " " + WsLoadOf(oResO, "bob"), "8 10")
	oSimQ = new stzWorkflowSimulation(oW)
	oResQ = oSimQ.OptimizeStepQ("b", 6).ReassignStepQ("e", "ana", "bob").ParallelizeStepsQ([ "a", "b" ]).Apply()
	Then("the same three changes as one chain: 18, b c d e, 16", "" + oResQ.TotalDuration() + " " + WsCpPath(oResQ) + " " + WsCpDur(oResQ), "18 b c d e 16")
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

func WsBuildTwoChains()
	oB = new stzWorkflow("twochains")
	oB.AddStep_("p")
	oB.AddStep_("q")
	oB.AddStep_("r")
	oB.AddStep_("s")
	oB.SetStepDuration("p", 2)
	oB.SetStepDuration("q", 3)
	oB.SetStepDuration("r", 4)
	oB.SetStepDuration("s", 5)
	oB.ConnectSteps("p", "q")
	oB.ConnectSteps("r", "s")
	return oB

func WsBuildIsolated()
	oB = new stzWorkflow("isolated")
	oB.AddStep_("m")
	oB.AddStep_("n")
	oB.SetStepDuration("m", 2)
	oB.SetStepDuration("n", 3)
	return oB

# x (1) --> y (2) --> m (3) --> z (4)
func WsBuildLinked()
	oB = new stzWorkflow("linked")
	oB.AddStep_("x")
	oB.AddStep_("y")
	oB.AddStep_("m")
	oB.AddStep_("z")
	oB.SetStepDuration("x", 1)
	oB.SetStepDuration("y", 2)
	oB.SetStepDuration("m", 3)
	oB.SetStepDuration("z", 4)
	oB.ConnectSteps("x", "y")
	oB.ConnectSteps("y", "m")
	oB.ConnectSteps("m", "z")
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

func WsCpPath(poWf)
	aCpX = poWf.CriticalPath()
	return WsJoin(aCpX[:path])

func WsCpDur(poWf)
	aCpY = poWf.CriticalPath()
	return aCpY[:duration]

func WsApplyEdges(poSim)
	oAppliedE = poSim.Apply()
	return len(oAppliedE.Edges())

func WsApplyCpPath(poSim)
	oAppliedP = poSim.Apply()
	return WsCpPath(oAppliedP)

func WsChangeType(poSim, pnAt)
	aAllCh = poSim.Changes()
	return aAllCh[pnAt][:type]

func WsTryOptimizeQ(poSim, pcId, pnDur)
	cMsg = ""
	try
		poSim.OptimizeStepQ(pcId, pnDur)
	catch
		cMsg = cCatchError
	done
	return cMsg

func WsTryReassignQ(poSim, pcId, pcFrom, pcTo)
	cMsg = ""
	try
		poSim.ReassignStepQ(pcId, pcFrom, pcTo)
	catch
		cMsg = cCatchError
	done
	return cMsg

func WsTryParallelQ(poSim, paIds)
	cMsg = ""
	try
		poSim.ParallelizeStepsQ(paIds)
	catch
		cMsg = cCatchError
	done
	return cMsg

# a chain of two Q calls whose second one names a step: the first call is good, the second is the one that may fail
func WsTryChainQ(poSim, pcSecond)
	cMsg = ""
	try
		poSim.OptimizeStepQ("a", 1).OptimizeStepQ(pcSecond, 1)
	catch
		cMsg = cCatchError
	done
	return cMsg
