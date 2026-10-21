# Narrative
# ---------
# THE FIRST VERTICAL SLICE of the model-flow layer (SOFTANZA_MODEL_FLOW.md section 14): three flows, each green on its
# FLOOR ALONE and, where the model is installed, WITH A MODEL, and each substitutable stage by stage:
#   1  retrieval      :retrieve (embed) -> :rerank              a question to the best help article
#   2  text -> record :triage_extract                           a ticket to { product, severity }, judged by C9
#   3  three stages   :brief -> :kind -> :route                 summarise, classify, route; one stage swapped for its floor
#
# What this guard asserts is the MECHANISM, which holds whatever the models measure: a floor-only run always works;
# the registry never chooses an implementation the recorded measurements do not support; a flow with a stage swapped
# for its floor still yields a valid parcel of the SAME TYPE. It does NOT assert that a model wins -- that is a measured
# fact, recorded in results/measurements.zmdl.txt and reported (a model that does not beat its floor is simply not chosen,
# and the Jina reranker is the live example on this golden set).
#
# Model scenarios SKIP, saying so, when the GGUF is not on disk. Run from this directory.

load "../../stzBase.ring"
load "../_narrated.ring"
load "_ticket_app.ring"

StzClearMeasurements()
StzClearModelTrace()
StzClearParcelMemo()
nRows = StzLoadMeasurements("results/measurements.zmdl.txt")
StzTicketAppDeclare()
aDocs = StzTicketDocs()
aQ = StzTicketQueries()
aTick = StzTicketTickets()

Scenario("The recorded measurements are the registry's evidence")
	Then("the measurement file was loaded", nRows > 0, TRUE)
	Then("the golden set is the independent one: 36 held-out tickets", len(aTick), 36)
	Then("the floors are measured honestly: the extraction floor is far from perfect on it",
		StzMeasurementOf("triage_extract", "keyword-rules", "v1")[:score] < 0.9, TRUE)
	for cFac in [ "retrieve", "rerank", "triage_extract", "brief", "kind" ]
		aPlan = StzResolveFaculty(cFac, [])
		cBar = StzMeasurementOf(cFac, aPlan[:floor], "v1")
		if aPlan[:kind] = "floor"
			Then(cFac + ": the registry's choice is the floor (" + aPlan[:chosen] + ")", aPlan[:chosen], aPlan[:floor])
		else
			aM = StzMeasurementOf(cFac, aPlan[:chosen], "v1")
			Then(cFac + ": '" + aPlan[:chosen] + "' was chosen only because it STRICTLY beats the floor (" + aM[:score] + " > " + cBar[:score] + ")",
				aM[:score] > cBar[:score], TRUE)
		ok
	next
EndScenario()

Scenario("FLOW 1 -- retrieval: embed, then rerank")
	oF = StzFlowQ("retrieval")
	oF.AddStageQ("candidates", :retrieve, []).AddStageQ("order", :rerank, []).ConnectStagesQ("candidates", "order")
	Then("the flow is sound", oF.IsSound(), TRUE)
	oF.UseFloorEverywhereQ()
	oP = oF.RunQ([ :query = "when will I get my money back?", :docs = aDocs ])
	Then("on its floors the flow answers with a ranking", oP.Type(), "ranking")
	Then("the ranking covers the candidates the first stage kept (four)", len(oP.Value()), 4)
	Then("it is ordered best first", oP.Value()[1][2] >= oP.Value()[2][2], TRUE)
	Then("the provenance is the two floors", StzFindFirst("retrieve:word-idf", @@(oP.Chain())) > 0 and StzFindFirst("rerank:stem-overlap", @@(oP.Chain())) > 0, TRUE)
	oF.UseRegistryChoiceQ()
	if StzModelFileFor("all-minilm") != ""
		oF.PinStage("candidates", "minilm-cosine")
		oP2 = oF.RunQ([ :query = "when will I get my money back?", :docs = aDocs ])
		Then("with the embedding model pinned, the FIRST STAGE finds the right article",
			oF.StageParcelQ("candidates").Value()[:docs][1], aDocs[7])
		# a composition effect the guard states rather than hides: the rerank stage is on its (weaker) floor, because the
		# Jina reranker measured BELOW it on this golden set -- so a flow can be worse than its best stage
		Then("the flow's final answer is a ranking of the same four candidates",
			len(oP2.Value()), len(oF.StageParcelQ("candidates").Value()[:docs]))
		Then("the chain names the model for the first stage", oP2.Chain()[1], "retrieve:minilm-cosine")
		Then("the same flow yields the same TYPE as on floors", oP2.Type(), oP.Type())
	else
		Given("all-MiniLM is not installed: the embedding scenario is SKIPPED")
	ok
EndScenario()

Scenario("FLOW 2 -- text to record, judged by C9")
	oF2 = StzFlowQ("extraction")
	oF2.AddStageQ("extract", :triage_extract, [])
	cTicket = "Since this morning your API answers every request with a 500 error."
	oF2.UseFloorEverywhereQ()
	oP = oF2.RunQ(cTicket)
	Then("on the floor the answer is a record", oP.Type(), "record")
	Then("...which the C9 court accepts", StzTicketSchema().Verify(oP.Value())[:ok], 1)
	Then("...and reads the ticket correctly (api, high)", oP.Value()[:product] + "/" + oP.Value()[:severity], "api/high")
	Then("its provenance says floor", oP.Chain()[1], "triage_extract:keyword-rules")
	oF2.UseRegistryChoiceQ()
	cModel = ""
	for cId in [ "qwen3-0.6b", "granite-350m", "smollm2-135m", "qwen25c-0.5b" ]
		for aM in $aTkModels
			if aM[1] = cId and StzModelFileFor(aM[2]) != "" and cModel = "" cModel = cId ok
		next
	next
	if cModel != ""
		oF2.PinStage("extract", cModel)
		oPm = oF2.RunQ(cTicket)
		Then("pinned to " + cModel + ", the flow returns a record or a REFUSAL -- never a half-built value", oPm.Type() = "record" or oPm.IsRefusal() = 1, TRUE)
		if oPm.IsRefusal() = 0
			Then("a model record is judged by the same C9 court", StzTicketSchema().Verify(oPm.Value())[:ok], 1)
			Then("the chain names the model", oPm.Chain()[1], "triage_extract:" + cModel)
		ok
		oF2.PinStage("extract", :floor)
		Then("swapping the stage to its floor yields the same type", oF2.RunQ(cTicket).Type(), "record")
	else
		Given("no generative GGUF is installed: the model scenario is SKIPPED")
	ok
EndScenario()

Scenario("FLOW 2 again -- when the registry's own choice is a model, the flow uses it and the parcel says so")
	oF2b = StzFlowQ("extraction-auto")
	oF2b.AddStageQ("extract", :triage_extract, [])
	aP2 = oF2b.ResolvePlan()[:stages][1]
	if aP2[:kind] = "model" and StzModelFileFor(aP2[:needle]) != ""
		Then("the registry chose '" + aP2[:chosen] + "' for extraction BECAUSE it measured above the floor",
			StzMeasurementOf("triage_extract", aP2[:chosen], "v1")[:score] > StzMeasurementOf("triage_extract", aP2[:floor], "v1")[:score], TRUE)
		oPa = oF2b.RunQ("Since this morning your API answers every request with a 500 error.")
		Then("the flow ran the chosen model", oPa.Chain()[1], "triage_extract:" + aP2[:chosen])
		Then("its record is judged by C9", StzTicketSchema().Verify(oPa.Value())[:ok], 1)
		Then("a model that read the answer by probability states how sure it is", oPa.P() >= 0 and oPa.P() <= 1, TRUE)
		Then("...and the evidence band follows from that probability", oPa.Certainty(), StzBandOfProbability(oPa.P()))
	else
		Given("no model beat the extraction floor in the recorded measurements, or it is not installed: SKIPPED")
	ok
EndScenario()

Scenario("FLOW 3 -- three stages, one swapped for its floor, the result still validates")
	oF3 = StzFlowQ("triage")
	oF3.AddStageQ("brief", :brief, []).AddStageQ("kind", :kind, []).AddStageQ("route", :route, [])
	Then("brief (text) cannot feed route (label) directly -- the check catches it before running",
		_Fl3Wire(oF3, "brief", "route"), "type-mismatch-on-edge")
	oF3 = StzFlowQ("triage")
	oF3.AddStageQ("brief", :brief, []).AddStageQ("kind", :kind, []).AddStageQ("route", :route, []).
	    ConnectStagesQ("brief", "kind").ConnectStagesQ("kind", "route")
	Then("brief (text -> text), kind (text -> label), route (label -> record): the wiring is sound", oF3.IsSound(), TRUE)
	Then("three stages", oF3.NumberOfStages(), 3)
	cT = "Every call to the API times out and our production site is down."
	oF3.UseFloorEverywhereQ()
	oP = oF3.RunQ(cT)
	Then("on floors the flow ends in a routed record", oP.Type(), "record")
	Then("a bug goes to engineering in 8 hours", oP.Value()[:queue] + "/" + oP.Value()[:hours], "engineering/8")
	Then("the result passes the route schema (C9)", StzRouteSchema().Verify(oP.Value())[:ok], 1)
	Then("the chain is the three floors", @@(oP.Chain()), @@([ "brief:first-clause", "kind:keyword-rules", "route:table" ]))
	Then("the intermediate brief is short (at most nine words)", len(split(oF3.StageParcelQ("brief").Value(), " ")) <= 9, TRUE)

	# a model for the classification stage, if one is installed; then the SAME flow with that stage on its floor
	oF3.UseRegistryChoiceQ()
	cModel = ""
	for cId in [ "qwen3-0.6b", "granite-350m", "smollm2-135m", "qwen25c-0.5b" ]
		for aM in $aTkModels
			if aM[1] = cId and StzModelFileFor(aM[2]) != "" and cModel = "" cModel = cId ok
		next
	next
	if cModel != ""
		oF3.PinStage("kind", cModel)
		oPm = oF3.RunQ(cT)
		Then("with " + cModel + " on the classification stage the flow still ends in a valid routed record, or a refusal",
			(oPm.Type() = "record" and StzRouteSchema().Verify(oPm.Value())[:ok] = 1) or oPm.IsRefusal() = 1, TRUE)
		oF3.PinStage("kind", :floor)
		oPf = oF3.RunQ(cT)
		Then("swapping that stage back to its floor: the result still validates", StzRouteSchema().Verify(oPf.Value())[:ok], 1)
		Then("...and has the same type", oPf.Type(), "record")
	else
		Given("no generative GGUF is installed: the model scenario is SKIPPED")
	ok
EndScenario()

Scenario("Every implicit resolution is in the trace and one switch turns the models off")
	StzClearModelTrace()
	oF3 = StzFlowQ("triage2")
	oF3.AddStageQ("brief", :brief, []).AddStageQ("kind", :kind, []).AddStageQ("route", :route, []).
	    ConnectStagesQ("brief", "kind").ConnectStagesQ("kind", "route")
	StzModelPolicy(:deterministic)
	oP = oF3.RunQ("The mobile app crashes on start.")
	Then("under the deterministic policy every stage is a floor", @@(oP.Chain()), @@([ "brief:first-clause", "kind:keyword-rules", "route:table" ]))
	Then("each resolution was traced", len(StzModelTrace()) >= 3, TRUE)
	Then("...and the trace records the choice", StzModelTrace()[1][:chosen], "first-clause")
	StzModelPolicy(:auto)
EndScenario()

Summary()

func _Fl3Wire(oFlow, cFrom, cTo)
	oFlow.ConnectStages(cFrom, cTo)
	aF = oFlow.CheckRules()
	for i = 1 to len(aF)
		if aF[i][:rule] = "type-mismatch-on-edge" return aF[i][:rule] ok
	next
	return "none"
