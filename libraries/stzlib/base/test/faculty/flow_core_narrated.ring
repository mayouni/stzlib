# Narrative
# ---------
# THE FLOW (base/faculty/stzFlow.ring, SOFTANZA_MODEL_FLOW.md section 6): faculties wired as a data flow over an
# stzGraph; CHECKED BEFORE IT RUNS; what passes between stages is an immutable parcel; a stage that refuses stops
# its branch; and the SAME flow runs on a model, on another, or entirely on its floors -- the substitution contract.
#
# No GGUF: the "models" are plain Ring functions of known quality (the real-model flows are in flows_narrated.ring).
#   clean  (text  -> text)   floor trims and lowercases;           "smart-clean" also collapses inner runs of spaces
#   kind   (text  -> label)  floor: short if <= 5 characters;      "by-words" : short if <= 2 words
#   shout  (label -> text)   floor only: upper-cases the label
#   a flow:  tidy -> sort -> loud   (clean -> kind -> shout)

load "../../stzBase.ring"
load "../_narrated.ring"

StzClearMeasurements()
StzClearModelTrace()
StzClearParcelMemo()

StzFacultyQ(:clean).SetInputTypeQ(:text).SetOutputTypeQ(:text).SetFloorQ("trim-lower", "_FlClean").
	AddGoldenQ("  Hello   World ", "hello world").AddGoldenQ("A    B", "a b").AddGoldenQ(" Mixed CASE ", "mixed case").AddGoldenQ("x  y   z", "x y z").
	AddImplementationQ([ :id = "smart-clean", :kind = "model", :fn = "_FlSmartClean", :licence = "apache-2.0", :memory = 50 ])

StzFacultyQ(:kind).SetInputTypeQ(:text).SetOutputTypeQ(:label).SetParamsQ([ :labels = [ "short", "long" ] ]).SetFloorQ("by-chars", "_FlKindChars").
	AddGoldenQ("hello world", "short").AddGoldenQ("a b", "short").AddGoldenQ("one two three four", "long").AddGoldenQ("ok", "short").
	AddGoldenQ("this is a long sentence", "long").AddGoldenQ("hi there", "short").
	AddImplementationQ([ :id = "by-words", :kind = "model", :fn = "_FlKindWords", :licence = "mit", :memory = 80 ])

StzFacultyQ(:shout).SetInputTypeQ(:label).SetOutputTypeQ(:text).SetFloorQ("upper", "_FlShout").
	AddGoldenQ("short", "SHORT").AddGoldenQ("long", "LONG")

StzFacultyQ(:orphan).SetInputTypeQ(:text).SetOutputTypeQ(:text).SetFloorQ("same", "_FlClean")

StzModelRegistryQ().RunGoldens(:clean)
StzModelRegistryQ().RunGoldens(:kind)
StzModelRegistryQ().RunGoldens(:shout)

Scenario("A flow is faculties wired as a graph, and it is checked BEFORE it runs")
	oF = StzFlowQ("tidy-sort-loud")
	oF.AddStageQ("tidy", :clean, []).AddStageQ("sort", :kind, []).AddStageQ("loud", :shout, []).
	   ConnectStagesQ("tidy", "sort").ConnectStagesQ("sort", "loud")
	Then("the flow has three stages", oF.NumberOfStages(), 3)
	Then("it composes an stzGraph (LAW 5)", oF.Graph().HasNode("sort"), TRUE)
	Then("the order is the data flow's", @@(oF.TopologicalOrder()), @@([ "tidy", "sort", "loud" ]))
	Then("a sound flow has no finding that is an error", oF.IsSound(), TRUE)
	Then("an unknown faculty cannot be added", _FlRaisesStage(oF, "ghost", "nonesuch"), 1)
	Then("a duplicate stage id cannot be added", _FlRaisesStage(oF, "tidy", "clean"), 1)

	oBad = StzFlowQ("miswired")
	oBad.AddStageQ("tidy", :clean, []).AddStageQ("loud", :shout, []).ConnectStagesQ("tidy", "loud")
	aF = oBad.CheckRules()
	Then("wiring text into a label-taking faculty is a finding BEFORE anything runs", aF[1][:rule], "type-mismatch-on-edge")
	Then("...it says which edge", aF[1][:where], "tidy -> loud")
	Then("...in the house finding shape, subject model-flow", aF[1][:subject], "model-flow")
	Then("...and a flow with an error finding is not sound", oBad.IsSound(), FALSE)
	oRef = oBad.RunQ("anything")
	Then("running it is REFUSED, with those findings", oRef.IsRefusal(), 1)

	oCycle = StzFlowQ("loop")
	oCycle.AddStageQ("a", :clean, []).AddStageQ("b", :clean, []).ConnectStagesQ("a", "b").ConnectStagesQ("b", "a")
	Then("a cycle is a finding: a data flow is acyclic", oCycle.CheckRules()[1][:rule], "cycle")

	oWarn = StzFlowQ("no-golden")
	oWarn.AddStageQ("only", :orphan, [])
	aW = oWarn.CheckRules()
	Then("a faculty without a golden set is a WARNING (its floor may still run)", aW[1][:severity], :warning)
	Then("...so the flow is still sound and runs", oWarn.IsSound(), TRUE)
EndScenario()

oF = StzFlowQ("tidy-sort-loud")
oF.AddStageQ("tidy", :clean, []).AddStageQ("sort", :kind, []).AddStageQ("loud", :shout, []).
   ConnectStagesQ("tidy", "sort").ConnectStagesQ("sort", "loud")

Scenario("ResolvePlan says what each stage WOULD use and why -- and runs nothing")
	StzClearModelTrace()
	StzClearParcelMemo()
	aPlan = oF.ResolvePlan()
	Then("three stages are planned", len(aPlan[:stages]), 3)
	Then("tidy goes to the model that beat its floor", aPlan[:stages][1][:chosen], "smart-clean")
	Then("sort goes to the model that beat its floor", aPlan[:stages][2][:chosen], "by-words")
	Then("loud has only a floor", aPlan[:stages][3][:chosen], "upper")
	Then("the footprint is the LARGEST resident model, since the engine has one slot", aPlan[:memory], 80)
	Then("Why() is one sentence per stage", StzFindFirst("sort (kind): by-words [model]", oF.Why()) > 0, TRUE)
	Then("planning invoked no implementation: nothing was memoised", len($aStzParcelMemo), 0)
EndScenario()

Scenario("Run yields a parcel whose provenance is the whole chain")
	oP = oF.RunQ("  Now   THEN  ")
	Then("the flow ended in a text parcel", oP.Type(), "text")
	Then("'now then' has 2 words, so the model calls it short and the last stage shouts SHORT", oP.Value(), "SHORT")
	Then("the chain names every stage's faculty and implementation", @@(oP.Chain()), @@([ "clean:smart-clean", "kind:by-words", "shout:upper" ]))
	Then("Run (no Q) returns just the value", oF.Run("  Now   THEN  "), "SHORT")
	Then("each stage's own parcel is kept", oF.StageParcelQ("sort").Value(), "short")
EndScenario()

Scenario("The SAME flow runs on a model, on another, or on its floors -- the substitution contract")
	cInput = "  alpha   beta   gamma  "
	oOnModels = oF.RunQ(cInput)
	oF.UseFloorEverywhereQ()
	oOnFloors = oF.RunQ(cInput)
	oF.UseRegistryChoiceQ()
	Then("on models: three words -> long", oOnModels.Value(), "LONG")
	Then("on floors: the same flow, the same output TYPE", oOnFloors.Type(), oOnModels.Type())
	Then("on floors the chain is all floors", @@(oOnFloors.Chain()), @@([ "clean:trim-lower", "kind:by-chars", "shout:upper" ]))
	oF.UseFloorEverywhereQ()
	Then("the floor chain is reproducible: same key", oF.RunQ(cInput).Key(), oOnFloors.Key())
	oF.UseRegistryChoiceQ()
	oF.PinStage("sort", :floor)
	Then("pinning ONE stage to its floor changes only that stage", @@(oF.RunQ(cInput).Chain()), @@([ "clean:smart-clean", "kind:by-chars", "shout:upper" ]))
	oF.PinStage("sort", "by-words")
	Then("pinning it back to the model", oF.RunQ(cInput).Chain()[2], "kind:by-words")
	oF.UnpinStage("sort")
	StzModelPolicy(:deterministic)
	Then("the process-wide switch puts every stage on its floor", @@(oF.RunQ(cInput).Chain()), @@([ "clean:trim-lower", "kind:by-chars", "shout:upper" ]))
	StzModelPolicy(:auto)
	Then("...and restoring it restores the choice", oF.RunQ(cInput).Chain()[1], "clean:smart-clean")
EndScenario()

Scenario("A refusal stops the branch and the flow returns it -- never a half-built value")
	StzFacultyQ(:kindwild).SetInputTypeQ(:text).SetOutputTypeQ(:label).SetParamsQ([ :labels = [ "short", "long" ] ]).SetFloorQ("wild-floor", "_FlWild").
		AddGoldenQ("a", "short")
	oW = StzFlowQ("wild")
	oW.AddStageQ("tidy", :clean, []).AddStageQ("sort", :kindwild, []).AddStageQ("loud", :shout, []).
	   ConnectStagesQ("tidy", "sort").ConnectStagesQ("sort", "loud")
	oRefusal = oW.RunQ("x")
	Then("the flow returns a refusal", oRefusal.IsRefusal(), 1)
	Then("the finding names the stage that refused", StzFindFirst("stage sort", oRefusal.Findings()[1][:where]) > 0, TRUE)
	Then("the stage before it did run: its parcel is kept", oW.StageParcelQ("tidy").Value(), "x")
	Then("the stage after it did NOT run", oW.StageParcelQ("loud").IsRefusal(), 1)
EndScenario()

Scenario("Explain() says what the flow is, for a person or an agent")
	cE = oF.Explain()
	Then("it lists the stages with their types", StzFindFirst("stage sort: faculty kind (text -> label)", cE) > 0, TRUE)
	Then("...and the edges", StzFindFirst("tidy -> sort", cE) > 0, TRUE)
EndScenario()

Summary()

func _FlClean(cText, aParams)
	cT = lower(trim(cText))
	return cT

func _FlSmartClean(cText, aParams)
	cT = lower(trim(cText))
	while len(StzFind("  ", cT)) > 0
		cT = StzReplace(cT, "  ", " ")
	end
	return cT

func _FlKindChars(cText, aParams)
	if len(cText) <= 5 return "short" ok
	return "long"

func _FlKindWords(cText, aParams)
	nW = len(split(trim(cText), " "))
	if nW <= 2 return "short" ok
	return "long"

func _FlShout(cLabel, aParams)
	return upper(cLabel)

func _FlWild(cText, aParams)
	return "undeclared"

func _FlRaisesStage(oFlow, cId, cFaculty)
	try
		oFlow.AddStage(cId, cFaculty, [])
	catch
		return 1
	done
	return 0
