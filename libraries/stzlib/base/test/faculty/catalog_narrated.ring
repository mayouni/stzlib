# Narrative
# ---------
# THE CATALOGUE AND THE SETUP PLAN (MP3 of SOFTANZA_MODEL_PLACEMENT.md, 2026-11-05). A developer on another machine needs to know, for a
# faculty: which files, from where, how big, which licence, the exact steps, the digest to check -- and whether it is worth it here. The
# catalogue (models/catalog.zcat) is the machine-readable record; StzModelSetupPlan() writes the steps for THIS machine from it and from
# the measurements and the court; Softanza fetches nothing. Capability now includes "the files it needs are here", a floor included.
#
#   cd libraries/stzlib/base/test/faculty ; rnxc catalog_narrated.ring

load "../../stzBase.ring"
load "../_narrated.ring"

Scenario("The catalogue covers every file a shipped faculty needs")
	aC = StzModelCatalog()
	? "   catalogue: " + len(aC[:files]) + " files, " + len(aC[:requires]) + " requires rows, " + len(aC[:platforms]) + " platform rows, " + len(aC[:replayed]) + " replays"
	Then("it is read from models/catalog.zcat", len(aC[:files]) >= 26 and len(aC[:requires]) >= 18, TRUE)
	StzOcrDeclare([])
	aN = StzFacultyNames()
	aMissing = []
	for i = 1 to len(aN)
		aI = StzFacultyQ(aN[i]).Implementations()
		for k = 1 to len(aI)
			if aI[k][:needle] != ""
				if len(StzModelCatalogEntry(aI[k][:needle])) = 0  aMissing + aI[k][:needle] ok
				if len(StzFind(aI[k][:needle], StzImplementationFiles(aN[i], aI[k][:id], ""))) = 0  aMissing + (aN[i] + ":" + aI[k][:id] + " has no requires row for its needle") ok
			ok
		next
	next
	Then("every implementation's model file is catalogued and in its requires row: " + @@(aMissing), len(aMissing), 0)
	nBad = 0
	for i = 1 to len(aC[:requires])
		for k = 1 to len(aC[:requires][i][:paths])
			if len(StzModelCatalogEntry(aC[:requires][i][:paths][k])) = 0  nBad++ ok
		next
	next
	Then("every file a requires row names is itself catalogued", nBad, 0)
	Then("an implementation needs ALL its files, not only its needle: siglip2 needs its text AND vision towers",
	     @@(StzImplementationFiles("image-label", "siglip2", "")), @@([ "vision/siglip2_text.gguf", "vision/siglip2_vision.gguf" ]))
	Then("and a language's own files only for that language: ppocr needs the Arabic recogniser for 'ar', not for 'fr'",
	     len(StzFind("ocr/ppocr_rec_arabic.gguf", StzImplementationFiles("ocr", "ppocr", "ar"))) > 0 and len(StzFind("ocr/ppocr_rec_arabic.gguf", StzImplementationFiles("ocr", "ppocr", "fr"))) = 0, TRUE)
EndScenario()

Scenario("Every catalogued file here is the catalogued file")
	aV = StzModelVerify()
	nOk = 0
	aWrong = []
	for i = 1 to len(aV)
		if aV[i][2][:digest] = "ok"
			nOk++
		else
			aWrong + (aV[i][1] + ": " + aV[i][2][:reason])
		ok
	next
	? "   " + nOk + " of " + len(aV) + " catalogued files here are intact (sha256 checked)"
	Then("every catalogued file present here has its catalogued size and sha256: " + @@(aWrong), len(aWrong), 0)
	Then("...and they are all here on this machine", len(aV), len(StzModelCatalog()[:files]))
EndScenario()

Scenario("MODELS.md, the prose, agrees with the catalogue")
	cMd = read(StzModelsDir() + "/MODELS.md")
	aF = StzModelCatalog()[:files]
	aDisagree = []
	for i = 1 to len(aF)
		if StzFindFirst(aF[i][:sha256], cMd) = 0  aDisagree + (aF[i][:path] + ": sha256 not in MODELS.md") ok
		if StzFindFirst(_CatThousands(aF[i][:bytes]), cMd) = 0  aDisagree + (aF[i][:path] + ": size " + _CatThousands(aF[i][:bytes]) + " not in MODELS.md") ok
	next
	Then("every catalogued file's sha256 and size are written in MODELS.md too: " + @@(aDisagree), len(aDisagree), 0)
	Then("12 conversions were replayed and reproduced their file byte for byte", _CatCountReplays("reproduced byte for byte"), 12)
EndScenario()

Scenario("A missing file: the setup plan says what to do, and what it is worth")
	cCat = StzReplace(WorkingDirectory(), "\", "/") + "/results/catalog_demo.zcat"
	if NOT StzDirExists(StzReplace(WorkingDirectory(), "\", "/") + "/results") StzDirCreatePath(StzReplace(WorkingDirectory(), "\", "/") + "/results") ok
	write(cCat, read(StzModelCatalogFile()) + char(10) +
		"file|vision/__not_here__.gguf|1234567|" + copy("ab", 32) + "|MIT|download|https://example.org/demo.gguf|1234567|" + copy("ab", 32) + "|download, save as vision/__not_here__.gguf" + char(10) +
		"requires|demo|smart|vision/__not_here__.gguf|" + char(10) +
		"requires|demo_floorless|plain|vision/__not_here__.gguf|" + char(10))
	$cStzCatalogPath = cCat
	StzModelCatalogReload()
	oD = StzFacultyQ(:demo)
	oD.SetInputTypeQ(:text).SetOutputTypeQ(:text).SetFloorQ("plain", "_CatEcho").SetGoldenCheckerQ("exact").SetGoldenVersionQ("v1")
	oD.AddImplementation([ :id = "smart", :kind = "graph", :fn = "_CatEcho", :licence = "mit" ])
	StzRecordMeasurement("demo", "plain", "v1", 0.5, 40, 1, "")
	StzRecordMeasurement("demo", "smart", "v1", 0.9, 40, 1, "")
	StzRecordCourtVerdict("demo", "v1", "smart", "plain", 17, 1, "the guard's own evidence")
	oP = StzModelRegistryQ().ResolveQ(StzRequirementQ(:demo))
	Then("the model is not here, so the floor answers", oP.Chosen(), "plain")
	Then("...and the Why names the missing file and where its setup is", StzFindFirst("needs vision/__not_here__.gguf", oP.Why()) > 0 and StzFindFirst("StzModelSetupPlan('demo')", oP.Why()) > 0, TRUE)
	aS = StzModelSetupPlan("demo")
	Then("the plan has one step: the missing file", len(aS), 1)
	Then("...with its size, licence, source, steps and digest", aS[1][:bytes] = 1234567 and aS[1][:licence] = "MIT" and aS[1][:url] = "https://example.org/demo.gguf" and aS[1][:sha256] = copy("ab", 32), TRUE)
	Then("...and what installing it is WORTH, from the court: it would become the answer", StzFindFirst("UPHELD by the court over 'plain' (17 better, 1 worse): installing it makes it the answer", aS[1][:value]) > 0, TRUE)
	oF2 = StzFacultyQ(:demo_floorless)
	oF2.SetInputTypeQ(:text).SetOutputTypeQ(:text).SetFloorQ("plain", "_CatEcho").SetGoldenCheckerQ("exact").SetGoldenVersionQ("v1")
	oP2 = StzModelRegistryQ().ResolveQ(StzRequirementQ(:demo_floorless))
	Then("a FLOOR whose file is missing cannot run either: the faculty is a refusal that names the file", oP2.IsRefusal() = 1 and StzFindFirst("needs vision/__not_here__.gguf", oP2.Why()) > 0, TRUE)
	? StzModelSetupPlanText("demo")
	$cStzCatalogPath = ""
	StzModelCatalogReload()
EndScenario()

Scenario("A missing platform pack: the plan gives the operating system's own command")
	if isWindows() and _StzOcrPlatformProbe("ru")[1] = 0
		aS = StzModelSetupPlan("ocr")
		bRu = 0
		for i = 1 to len(aS)
			if aS[i][:kind] = "platform" and StzFindFirst("Language.OCR~~~ru-RU~0.0.1.0", aS[i][:steps]) > 0  bRu = 1 ok
		next
		Then("no Russian OCR pack here: the plan says how to add it, with the exact capability name", bRu, 1)
		? StzModelSetupPlanText("ocr")
	else
		? "   (this machine has a Russian OCR pack, or no Windows OCR: nothing to show for Russian)"
		Then("nothing to add for Russian here", 1, 1)
	ok
EndScenario()

Summary()
shutdown($_zst_fail)

func _CatEcho(cText, aParams)
	return cText

func _CatCountReplays(cText)
	n = 0
	aY = StzModelCatalog()[:replayed]
	for i = 1 to len(aY)
		if StzFindFirst(cText, aY[i][:result]) > 0  n++ ok
	next
	return n

# 21929440 -> "21,929,440", as MODELS.md writes sizes
func _CatThousands(n)
	c = "" + n
	cOut = ""
	k = 0
	for i = len(c) to 1 step -1
		cOut = c[i] + cOut
		k++
		if k % 3 = 0 and i > 1  cOut = "," + cOut ok
	next
	return cOut
