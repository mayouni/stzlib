# Narrative
# ---------
# THE FACULTY CORE (base/faculty/, SOFTANZA_MODEL_FLOW.md sections 3-5, 9): a faculty is a typed function with a
# deterministic FLOOR and zero or more implementations; a registry resolves a requirement to one of them,
# EXPLAINS itself, and a model earns a place only by STRICTLY beating the measured floor on the golden set.
#
# This guard needs no GGUF: its "models" are plain Ring functions with known quality, so the REGISTRY's logic is
# tested in isolation from any model's. (The flows with real models are in flows_narrated.ring.)
#
# The task: tell whether a number (given as text) is :odd or :even. The floor is right for small numbers only
# (it reads just the last digit of numbers under 100, and says :even for anything longer) -> 0.5 on the golden set.
#   better  -> always right                          (1.0)  must be chosen
#   worse   -> right a quarter of the time           (0.25) must be rejected: worse than the floor
#   equal   -> exactly as good as the floor          (0.5)  must be rejected: it must STRICTLY beat the floor
#   wild    -> returns a label that is not declared  must fail CONFORMANCE (the court refuses it)

load "../../stzBase.ring"
load "../_narrated.ring"

StzClearMeasurements()
StzClearModelTrace()
StzClearParcelMemo()

# 8 golden items: four short numbers the floor reads correctly, four long ODD ones it gets wrong -> the floor scores 0.5
aGold = [ [ "3", "odd" ], [ "8", "even" ], [ "41", "odd" ], [ "60", "even" ],
          [ "12345", "odd" ], [ "99999", "odd" ], [ "77777", "odd" ], [ "1357", "odd" ] ]

Scenario("A faculty is judged at declaration")
	oBad = StzFacultyQ(:parity_bad)
	Then("a fresh faculty is not complete", oBad.IsComplete(), FALSE)
	Then("it names what is missing: no types, no floor, no golden set", len(oBad.Problems()), 4)
	bRaised = 0
	try oBad.SetInputType(:telepathy) catch bRaised = 1 done
	Then("an unknown payload type is refused at declaration", bRaised, 1)

	oF = StzFacultyQ(:parity)
	oF.SetInputTypeQ(:text).SetOutputTypeQ(:label).SetParamsQ([ :labels = [ "odd", "even" ] ]).
	   SetFloorQ("last-digit", "_FcFloor").
	   SetGoldenCheckerQ("exact")
	for i = 1 to len(aGold)
		oF.AddGolden(aGold[i][1], aGold[i][2])
	next
	Then("a faculty with types, a floor and a golden set is complete", oF.IsComplete(), TRUE)
	Then("its floor is declared", oF.Floor()[:id], "last-digit")
	bDup = 0
	try
		oF.AddImplementation([ :id = "last-digit", :kind = "model", :fn = "_FcFloor" ])
		oF.AddImplementation([ :id = "last-digit", :kind = "model", :fn = "_FcFloor" ])
	catch
		bDup = 1
	done
	Then("an implementation id is unique within its faculty", bDup, 1)
	Then("a floor cannot be added as an ordinary implementation",
		_FcRaises(oF, [ :id = "second-floor", :kind = "floor", :fn = "_FcFloor" ]), 1)
EndScenario()

Scenario("The court judges every output, and a record is judged by C9 unchanged")
	aLab = StzJudgeParcelValue("label", " ODD ", [ :labels = [ "odd", "even" ] ])
	Then("a label is trimmed and case-folded to the declared one", aLab[:value], "odd")
	Then("a label outside the closed enumeration is refused", StzJudgeParcelValue("label", "maybe", [ :labels = [ "odd", "even" ] ])[:ok], 0)
	Then("a vector of the wrong dimension is refused (vectors of different dimensions never compare)",
		StzJudgeParcelValue("vector", [ 1, 2, 3 ], [ :dim = 4 ])[:ok], 0)
	Then("a ranking must be ordered best first", StzJudgeParcelValue("ranking", [ [ "a", 0.2 ], [ "b", 0.9 ] ], [])[:ok], 0)
	oS = StzOutputSchemaQ([ [ :field = "age", :type = :number, :must = [ [ ">=", 0 ], [ "<=", 130 ] ] ] ])
	Then("a record inside its band passes the C9 court", StzJudgeParcelValue("record", [ [ "age", 41 ] ], [ :schema = oS ])[:ok], 1)
	Then("a record outside its band is refused by C9 (a schema-valid lie would still pass)",
		StzJudgeParcelValue("record", [ [ "age", 900000 ] ], [ :schema = oS ])[:ok], 0)
EndScenario()

oF = StzFacultyQ(:parity)
oF.AddImplementationQ([ :id = "better", :kind = "model", :fn = "_FcBetter", :licence = "apache-2.0", :memory = 500, :languages = [ "*" ] ]).
   AddImplementationQ([ :id = "worse",  :kind = "model", :fn = "_FcWorse",  :licence = "apache-2.0", :memory = 300 ]).
   AddImplementationQ([ :id = "equal",  :kind = "model", :fn = "_FcFloor",  :licence = "apache-2.0", :memory = 200 ]).
   AddImplementationQ([ :id = "wild",   :kind = "model", :fn = "_FcWild",   :licence = "apache-2.0", :memory = 100 ]).
   AddImplementationQ([ :id = "ghost",  :kind = "model", :fn = "_FcBetter", :licence = "apache-2.0", :needle = "no-such-gguf-anywhere" ]).
   AddImplementationQ([ :id = "viral",  :kind = "model", :fn = "_FcBetter", :licence = "gpl-3.0", :memory = 100 ]).
   AddImplementationQ([ :id = "remote", :kind = "service", :fn = "_FcBetter", :licence = "n/a" ])

Scenario("Unmeasured is unknown, never good -- so with no measurement the floor answers")
	oPlan = StzModelRegistryQ().ResolveQ(StzRequirementQ(:parity))
	Then("the registry chose the floor", oPlan.Chosen(), "last-digit")
	Then("...because the floor itself is unmeasured: there is no bar to beat",
		StzFindFirst("the floor is unmeasured", oPlan.Why()) > 0, TRUE)
	Then("...and the better model was not taken on trust", StzFindFirst("better: the floor is unmeasured", oPlan.Why()) > 0, TRUE)
EndScenario()

Scenario("RunGoldens measures every installed implementation, the floor first")
	aRows = StzModelRegistryQ().RunGoldens(:parity)
	Then("the floor, better, worse, equal, wild and viral were measured (ghost is not installed, remote is a service)", len(aRows), 6)
	Then("the floor scores 0.5", StzModelRegistryQ().MeasurementOf(:parity, "last-digit")[:score], 0.5)
	Then("better scores 1", StzModelRegistryQ().MeasurementOf(:parity, "better")[:score], 1)
	Then("worse scores 0.25", StzModelRegistryQ().MeasurementOf(:parity, "worse")[:score], 0.25)
	Then("equal scores exactly the floor", StzModelRegistryQ().MeasurementOf(:parity, "equal")[:score], 0.5)
	Then("wild fails conformance: its court refused it", StzModelRegistryQ().MeasurementOf(:parity, "wild")[:conformance] < 1, TRUE)
EndScenario()

Scenario("Resolution picks the model that STRICTLY beats the measured floor, and says why")
	oPlan = StzModelRegistryQ().ResolveQ(StzRequirementQ(:parity))
	Then("the better model is chosen", oPlan.Chosen(), "better")
	Then("its kind is model", oPlan.Kind(), "model")
	cWhy = oPlan.Why()
	Then("Why() states the measured score and the bar it beat", StzFindFirst("measured 1 on golden set v1", cWhy) > 0 and StzFindFirst("beats the floor's 0.5", cWhy) > 0, TRUE)
	Then("worse is rejected: it does not beat the floor", StzFindFirst("worse: does not beat the floor", cWhy) > 0, TRUE)
	Then("equal is rejected too: a tie is not a win", StzFindFirst("equal: does not beat the floor", cWhy) > 0, TRUE)
	Then("wild is rejected: it fails conformance", StzFindFirst("wild: fails conformance", cWhy) > 0, TRUE)
	Then("ghost is rejected: not installed", StzFindFirst("ghost: not installed", cWhy) > 0, TRUE)
	Then("viral is rejected: its licence is not permissive", StzFindFirst("viral: licence 'gpl-3.0' is not permissive", cWhy) > 0, TRUE)
	Then("remote is rejected: a service is never selected implicitly", StzFindFirst("remote: a service is never selected implicitly", cWhy) > 0, TRUE)
	Then("the floor is kept as the fallback", StzFindFirst("the floor 'last-digit' is kept as the fallback", cWhy) > 0, TRUE)
EndScenario()

Scenario("A requirement filters; the inverse (pinning) is always possible")
	oTight = StzRequirementQ(:parity).RequireMemoryQ(100)
	Then("a memory budget of 100 MB leaves no eligible model: the floor answers",
		StzModelRegistryQ().ResolveQ(oTight).Chosen(), "last-digit")
	oLang = StzRequirementQ(:parity).RequireLanguagesQ([ "fr" ])
	Then("better covers every language ('*'), so a language requirement keeps it",
		StzModelRegistryQ().ResolveQ(oLang).Chosen(), "better")
	oBest = StzRequirementQ(:parity).RequireQualityQ(:best).RefuseBelowQualityQ()
	Then("quality :best (0.9) is met by better (1.0)", StzModelRegistryQ().ResolveQ(oBest).Chosen(), "better")

	aPinFloor = StzResolveFaculty(:parity, [ :floor = 1 ])
	Then("pinning the floor overrides the registry", aPinFloor[:chosen], "last-digit")
	aPinWorse = StzResolveFaculty(:parity, [ :impl = "worse" ])
	Then("pinning 'worse' is obeyed although the registry would never choose it", aPinWorse[:chosen], "worse")
	Then("...and the plan says it is pinned and what the measurement was", StzFindFirst("the registry does not override a pin", aPinWorse[:why][1]) > 0, TRUE)
	aPinGhost = StzResolveFaculty(:parity, [ :impl = "ghost" ])
	Then("pinning an implementation that is not installed is a REFUSAL, not a silent substitute", aPinGhost[:refusal], 1)
	aPinRemote = StzResolveFaculty(:parity, [ :impl = "remote" ])
	Then("a service CAN be reached -- by pinning it by name", aPinRemote[:chosen], "remote")
	aSet = StzResolveFaculty(:parity, [ :set = [ "worse", "better" ] ])
	Then("a pinned SET lets the registry choose inside it, still by measurement", aSet[:chosen], "better")
EndScenario()

Scenario("One switch turns every model off")
	StzModelPolicy(:deterministic)
	Then("under the deterministic policy the registry chooses the floor", StzModelRegistryQ().ResolveQ(StzRequirementQ(:parity)).Chosen(), "last-digit")
	Then("...and says why", StzFindFirst("deterministic", StzModelRegistryQ().ResolveQ(StzRequirementQ(:parity)).Why()) > 0, TRUE)
	StzModelPolicy(:auto)
	Then("restoring the policy restores the choice", StzModelRegistryQ().ResolveQ(StzRequirementQ(:parity)).Chosen(), "better")
EndScenario()

Scenario("Running a faculty yields a parcel with its provenance; a failing model falls back to the floor")
	StzClearModelTrace()
	oP = oF.RunQ("12345", [ :labels = [ "odd", "even" ] ])
	Then("the answer is a parcel, not a bare value", oP.Type(), "label")
	Then("the better model answered correctly (12345 is odd)", oP.Value(), "odd")
	Then("its provenance names the faculty and the implementation", oP.Chain()[1], "parity:better")
	Then("it carries a content key", len(oP.Key()), 64)
	Then("every resolution was recorded in the trace", len(StzModelTrace()) >= 1, TRUE)
	Then("the trace says which implementation was chosen", StzModelTrace()[1][:chosen], "better")

	oP2 = oF.RunQ("12345", [ :labels = [ "odd", "even" ] ])
	Then("the same input gives the same key (memoised, deterministic)", oP2.Key(), oP.Key())

	oBoom = StzFacultyQ(:fragile)
	# the floor is right on "x" only; the model is right on both goldens (so it is chosen) but falls over on "boom"
	oBoom.SetInputTypeQ(:text).SetOutputTypeQ(:label).SetParamsQ([ :labels = [ "ok", "no" ] ]).SetFloorQ("steady", "_FcOk").
	      AddGoldenQ("x", "ok").AddGoldenQ("y", "ok").
	      AddImplementationQ([ :id = "crashes", :kind = "model", :fn = "_FcCrash", :licence = "mit" ])
	StzModelRegistryQ().RunGoldens(:fragile)
	Then("the fragile model beats the floor on the goldens, so it is chosen",
		StzModelRegistryQ().ResolveQ(StzRequirementQ(:fragile)).Chosen(), "crashes")
	oFall = oBoom.RunQ("boom", [])
	Then("a model that fails and was not pinned does not break the flow: the floor answers (it says no for anything but x)", oFall.Value(), "no")
	Then("...and the provenance says it fell back and why",
		StzFindFirst("fell back from 'crashes'", oFall.Provenance()[1][:detail]) > 0, TRUE)
	oPinned = StzFacultyQ(:fragile).RunWithQ("crashes", "boom", [])
	Then("a PINNED model that fails is a refusal -- never a silent substitute", oPinned.IsRefusal(), 1)
	Then("...and the refusal names the rule", oPinned.Findings()[1][:rule], "implementation-failed")
EndScenario()

Scenario("Measurements persist as plain text and come back")
	cPath = tempname() + "_zmdl.txt"
	StzSaveMeasurements(cPath)
	StzClearMeasurements()
	Then("after clearing, nothing is measured", len(StzMeasurements()), 0)
	Then("loading restores every row", StzLoadMeasurements(cPath) >= 6, TRUE)
	Then("...the score survived", StzModelRegistryQ().MeasurementOf(:parity, "better")[:score], 1)
	remove(cPath)
EndScenario()

Summary()

# ---- the implementations (functions go last: in Ring, whatever follows a func belongs to it) -------------------

func _FcFloor(cText, aParams)
	# reads only the last digit of numbers under 100; says "even" for anything longer
	if len(cText) > 2 return "even" ok
	nLast = 0 + right(cText, 1)
	if nLast % 2 = 1 return "odd" ok
	return "even"

func _FcBetter(cText, aParams)
	nLast = 0 + right(cText, 1)
	if nLast % 2 = 1 return "odd" ok
	return "even"

func _FcWorse(cText, aParams)
	return "even"

func _FcWild(cText, aParams)
	return "maybe"

func _FcOk(cText, aParams)
	if cText = "x" return "ok" ok
	return "no"

func _FcCrash(cText, aParams)
	if cText = "boom" stzraise("the model fell over") ok
	return "ok"

func _FcRaises(oFac, aSpec)
	try
		oFac.AddImplementation(aSpec)
	catch
		return 1
	done
	return 0
