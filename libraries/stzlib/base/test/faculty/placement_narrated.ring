# Narrative
# ---------
# CAPABILITY BEFORE QUALITY (MP0 of SOFTANZA_MODEL_PLACEMENT.md, 2026-11-05). The registry used to measure an implementation that could
# not RUN on a machine as if it had answered WRONG: the operating system's OCR scored "0 of 9" in Russian on a machine with no Russian pack,
# and the evidence that shipped said the model beat it 8 to 0 -- false on every machine that has the pack, meaningless where the platform
# engine does not exist. Now an implementation declares where it can run (:platforms, and a probe fn(lang) -> [ 1|0, reason ]):
#   - a MEASUREMENT marks an item it cannot run as UNAVAILABLE: not in its n, not in its score, skipped by the court
#   - a RESOLUTION sets aside what cannot run here, the floor included, with the reason in the Why; the court sits with what can
#   - nothing available is a REFUSAL that says what is missing; a failed model never falls back to a floor that cannot run
#   - $cStzPlacementOS resolves as if on another operating system (what MP2's reports for a deployment target stand on)
#
# The faculty here needs no engine and no model file: the "implementations" are Ring functions of known behaviour.
#   :greet   say a greeting back in capitals; golden items in English, French and Klingon (tlh)
#   floor    "native", Windows-only in its declaration, and it has no Klingon pack (its probe says so); right in English and French
#   model    "learned", runs everywhere; right in all three
#
#   cd libraries/stzlib/base/test/faculty ; rnxc placement_narrated.ring

load "../../stzBase.ring"
load "../_narrated.ring"

StzClearMeasurements()
StzClearModelTrace()
StzClearParcelMemo()
StzClearCourt()

aGold = [ [ [ :text = "hello", :lang = "en-GB" ], "HELLO" ], [ [ :text = "good day", :lang = "en-US" ], "GOOD DAY" ],
          [ [ :text = "bonjour", :lang = "fr-FR" ], "BONJOUR" ], [ [ :text = "salut", :lang = "fr-FR" ], "SALUT" ],
          [ [ :text = "nuqneH", :lang = "tlh" ], "NUQNEH" ], [ [ :text = "qapla", :lang = "tlh" ], "QAPLA" ],
          [ [ :text = "yIjah", :lang = "tlh" ], "YIJAH" ], [ [ :text = "majQa", :lang = "tlh" ], "MAJQA" ],
          [ [ :text = "Qapla batlh", :lang = "tlh" ], "QAPLA BATLH" ] ]

Scenario("An implementation says where it can run")
	oF = StzFacultyQ(:greet)
	oF.SetInputTypeQ(:record).SetOutputTypeQ(:text).SetFloorQ("native", "_PcUpper").
	   SetGoldenCheckerQ("exact").SetGoldenVersionQ("v1").SetGoldenLanguageKeyQ(:lang)
	oF.AddImplementation([ :id = "learned", :kind = "graph", :fn = "_PcUpper", :licence = "mit" ])
	for i = 1 to len(aGold)
		oF.AddGolden(aGold[i][1], aGold[i][2])
	next
	oF.SetAvailability("native", [ "windows" ], "_PcNativeProbe")
	$cStzPlacementOS = "windows"
	Then("the floor can run English here", StzImplementationAvailable(_StzImplRow(:greet, "native"), "en")[1], 1)
	Then("it cannot run Klingon here, and says why", StzImplementationAvailable(_StzImplRow(:greet, "native"), "tlh")[2], "no 'tlh' pack here")
	$cStzPlacementOS = "linux"
	Then("on Linux it cannot run at all: its platforms say so before its probe is asked",
	     StzImplementationAvailable(_StzImplRow(:greet, "native"), "en")[2], "exists only on windows; this is linux")
	Then("the model, declared nowhere in particular, runs on Linux", StzImplementationAvailable(_StzImplRow(:greet, "learned"), "tlh")[1], 1)
	$cStzPlacementOS = "windows"
EndScenario()

Scenario("A measurement does not count what could not run")
	StzModelRegistryQ().RunGoldens(:greet)
	aF = StzMeasurementOf(:greet, "native", "v1")
	Then("the floor is measured on the 4 items it can run, not on all 9", aF[:n], 4)
	Then("...and scores 1 on them: no Klingon zero drags it down", aF[:score], 1)
	Then("...and its note says how many were left out, and where", StzFindFirst("5 item(s) unavailable here", aF[:note]) > 0 and StzFindFirst("measured on windows", aF[:note]) > 0, TRUE)
	Then("the model is measured on all 9", StzMeasurementOf(:greet, "learned", "v1")[:n], 9)
	Then("there is NO Klingon row for the floor: not measured is not zero", len(StzMeasurementOf(:greet, "native", "v1/tl")), 0)
	aC = StzCourtVerdictOf(:greet, "v1", "learned", "native")
	Then("the court skips the 5 items the floor could not run: no gain, no loss -- 0 and 0, not 5 and 0", @@([ aC[:gains], aC[:losses] ]), @@([ 0, 0 ]))
EndScenario()

Scenario("A resolution sets aside what cannot run here, and says so")
	oReg = StzModelRegistryQ()
	oP = oReg.ResolveQ(StzRequirementQ(:greet).RequireLanguagesQ([ "en" ]))
	Then("English: the floor runs, the model does not beat it on evidence (a tie): the floor answers", oP.Chosen(), "native")
	oP = oReg.ResolveQ(StzRequirementQ(:greet).RequireLanguagesQ([ "tlh" ]))
	Then("Klingon: the floor cannot run it here, so the model answers", oP.Chosen(), "learned")
	Then("...and the Why says the floor is unavailable and why", StzFindFirst("the floor 'native' is unavailable here (no 'tlh' pack here)", oP.Why()) > 0, TRUE)
	Then("...says the court had nothing to compare it with", StzFindFirst("the court had no implementation to compare 'learned' with here", oP.Why()) > 0, TRUE)
	Then("...and does NOT promise a fallback that cannot run", StzFindFirst("there is no fallback here", oP.Why()) > 0 and StzFindFirst("kept as the fallback", oP.Why()) = 0, TRUE)
	$cStzPlacementOS = "linux"
	oP = oReg.ResolveQ(StzRequirementQ(:greet).RequireLanguagesQ([ "en" ]))
	Then("as on Linux, even English goes to the model: the floor exists only on Windows", oP.Chosen(), "learned")
	$cStzPlacementOS = "windows"
EndScenario()

Scenario("Nothing available is a refusal that names what is missing")
	oG = StzFacultyQ(:greet_nowhere)
	oG.SetInputTypeQ(:record).SetOutputTypeQ(:text).SetFloorQ("native", "_PcUpper").SetGoldenCheckerQ("exact").SetGoldenVersionQ("v1")
	oG.AddGolden([ :text = "a", :lang = "en" ], "A")
	oG.SetAvailability("native", [ "windows" ], "")
	$cStzPlacementOS = "linux"
	oP = StzModelRegistryQ().ResolveQ(StzRequirementQ(:greet_nowhere))
	Then("on Linux, a faculty whose only implementation is Windows-only is a refusal", oP.IsRefusal(), 1)
	Then("...and the refusal says what cannot run and why", StzFindFirst("nothing can answer 'greet_nowhere' here: the floor exists only on windows", oP.Why()) > 0, TRUE)
	$cStzPlacementOS = "windows"
EndScenario()

Scenario("A model that fails never falls back to a floor that cannot run")
	oH = StzFacultyQ(:greet_fragile)
	oH.SetInputTypeQ(:record).SetOutputTypeQ(:text).SetFloorQ("native", "_PcUpper").SetGoldenCheckerQ("exact").SetGoldenVersionQ("v1").SetGoldenLanguageKeyQ(:lang)
	oH.AddImplementation([ :id = "brittle", :kind = "graph", :fn = "_PcBrittle", :licence = "mit" ])
	for i = 1 to len(aGold)
		oH.AddGolden(aGold[i][1], aGold[i][2])
	next
	oH.SetAvailability("native", [ "windows" ], "_PcNativeProbe")
	StzModelRegistryQ().RunGoldens(:greet_fragile)
	oP = oH.RunQ([ :text = "boom", :lang = "tlh" ], [])
	Then("Klingon goes to the model; it falls over on 'boom'; the floor cannot read Klingon: a refusal, not a wrong answer", oP.IsRefusal(), 1)
	Then("...naming both the failure and why the floor could not take over", StzFindFirst("cannot run here: no 'tl' pack here", oP.CiteFindings()) > 0, TRUE)
EndScenario()

Scenario("A re-measurement replaces the old rows, the per-language ones included")
	StzRecordMeasurement(:greet, "native", "v1/tl", 0, 5, 0, "an old row from a machine that measured absence as zero")
	Then("an old Klingon row for the floor is on record", len(StzMeasurementOf(:greet, "native", "v1/tl")) > 0, TRUE)
	StzModelRegistryQ().RunGoldens(:greet)
	Then("after re-measuring here, it is gone: the floor could not run Klingon here, so there is no row", len(StzMeasurementOf(:greet, "native", "v1/tl")), 0)
EndScenario()

Scenario("The real :ocr on this machine")
	# the shipped measurements and court (this guard cleared the process's own at its start)
	StzLoadMeasurements(StzVisionMeasurementsFile())
	StzLoadCourt(StzVisionCourtFile())
	StzOcrDeclare([])
	oReg = StzModelRegistryQ()
	if isWindows() and len(StzOcrPlatformLanguages()) > 0
		aPk = StzOcrPlatformLanguages()
		? "   this machine's OCR packs: " + @@(aPk)
		bEn = (_StzOcrPlatformProbe("en")[1] = 1)
		oP = oReg.ResolveQ(StzRequirementQ(:ocr).RequireLanguagesQ([ "en" ]))
		? "   ocr [en] -> " + oP.Chosen()
		if bEn
			Then("English: this machine HAS an English pack, so the floor can run it and is not set aside", StzFindFirst("unavailable here", oP.Why()) = 0, TRUE)
		else
			Then("English: no English pack here, so the floor is set aside and the portable model answers", oP.Chosen(), "ppocr")
		ok
	else
		? "   no platform OCR on this machine: every :ocr call is the model's"
		Then("no platform OCR here: English goes to the model", oReg.ResolveQ(StzRequirementQ(:ocr).RequireLanguagesQ([ "en" ])).Chosen(), "ppocr")
	ok
	$cStzPlacementOS = "linux"
	Then("as on Linux, French goes to the model: the platform engine exists only on Windows", oReg.ResolveQ(StzRequirementQ(:ocr).RequireLanguagesQ([ "fr" ])).Chosen(), "ppocr")
	Then("and :faces to yunet, for the same reason", oReg.ResolveQ(StzRequirementQ(:faces)).Chosen(), "yunet")
	$cStzPlacementOS = ""
EndScenario()

Scenario("The report (MP1) says what the registry chooses, here and on another system")
	StzLoadCourt(StzOcrCourtFile())
	aR = StzModelsReport()
	nSame = 0
	nAll = 0
	for i = 1 to len(aR)
		if aR[i][:faculty] = "greet" or aR[i][:faculty] = "greet_nowhere" or aR[i][:faculty] = "greet_fragile" loop ok
		oReq = StzRequirementQ(aR[i][:faculty])
		if aR[i][:lang] != "" oReq = StzRequirementQ(aR[i][:faculty]).RequireLanguagesQ([ aR[i][:lang] ]) ok
		nAll++
		if StzModelRegistryQ().ResolveQ(oReq).Chosen() = aR[i][:chosen] nSame++ ok
	next
	? "   the report has " + nAll + " entries for the shipped faculties"
	Then("every entry of the report names what the registry itself chooses", nSame = nAll and nAll >= 12, TRUE)
	aL = StzModelsReportFor("linux")
	Then("on Linux the report gives :faces to yunet", _PcEntry(aL, "faces", "")[:chosen], "yunet")
	Then("...and :ocr in French to the model, the floor being unavailable there", _PcEntry(aL, "ocr", "fr")[:chosen], "ppocr")
	Then("...and the report sets $cStzPlacementOS back when it is done", $cStzPlacementOS, "")
	cT = StzModelsReportText()
	Then("the text names what cannot run here and why", StzFindFirst("UNAVAILABLE: no 'ru' language pack here", cT) > 0 or StzOcrPlatformHas("ru-RU"), TRUE)
	cPage = StzModelsReportPage(StzReplace(WorkingDirectory(), "\", "/") + "/results/models_report.html")
	Then("the page is written", fexists(cPage), 1)
EndScenario()

Summary()

func _PcEntry(aR, cF, cLang)
	for i = 1 to len(aR)
		if aR[i][:faculty] = cF and aR[i][:lang] = cLang return aR[i] ok
	next
	return []

func _PcUpper(paIn, paParams)
	return upper(paIn[:text])

func _PcBrittle(paIn, paParams)
	if paIn[:text] = "boom" stzraise("the model fell over") ok
	return upper(paIn[:text])

# the floor's probe: every language but Klingon has a pack
func _PcNativeProbe(pcLang)
	if lower(pcLang) = "tl" or lower(pcLang) = "tlh" return [ 0, "no '" + pcLang + "' pack here" ] ok
	return [ 1, "" ]
