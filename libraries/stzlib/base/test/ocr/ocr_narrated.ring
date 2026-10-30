# ocr_narrated.ring -- OCR as a faculty (base/ocr/stzOcr.ring), told as scenes.
#
# The :ocr faculty's FLOOR is the platform engine (Windows.Media.Ocr) with right-to-left lines put back in logical
# order; it refuses, naming what is missing, where the platform cannot serve. These scenes pin the declaration,
# the reorder (which needs no engine), and -- where this machine has the packs -- the floor's reading of two golden
# documents whose expectations were written by authors who never saw a reader (golden_v36/z09 in French,
# golden_v35/y11 in Arabic), rendered at 150 dpi in _data/. A scene the machine cannot run is SKIPPED BY NAME.
#
#   cd libraries/stzlib/base/test/ocr ; rnxc ocr_narrated.ring

load "../../stzBase.ring"
load "../_narrated.ring"
load "_data/goldens_v1.ring"

$cDir = "_data/"
$aPacks = StzOcrPlatformLanguages()
? "platform OCR packs on this machine: " + @@($aPacks)

Scenario("The :ocr faculty is declared with a platform floor and the contains checker")
	o = StzOcrDeclare(StzOcrGoldensV1($cDir))
	Then("it has a floor", o.HasFloor(), 1)
	Then("the floor is the platform engine", o.Floor()[:id], "platform")
	Then("an image in", o.InputType(), "image")
	Then("a text out", o.OutputType(), "text")
	Then("a golden is a sentence the text must contain", o.GoldenChecker(), "contains")
	Then("the golden set holds one item per key sentence of the two documents", len(o.Goldens()), 17)
EndScenario()

Scenario("A right-to-left line the platform returned in visual order is put back in logical order")
	Then("a Latin line is left as it is", StzOcrLogicalLine("Les horaires du samedi sont affichés."), "Les horaires du samedi sont affichés.")
	Then("an Arabic line's words are reversed", StzOcrLogicalLine("الوثيقة بنص يؤخذ الاختلاف وعند"), "وعند الاختلاف يؤخذ بنص الوثيقة")
	Then("a number inside it keeps its own order", StzOcrLogicalLine("800 1234 الساخن الخط"), "الخط الساخن 800 1234")
	Then("a Latin word inside it too", StzOcrLogicalLine("HP-2026-48213 الوثيقة رقم"), "رقم الوثيقة HP-2026-48213")
	Then("in a left-to-right line, told so, only the Arabic run inside is reversed", StzOcrLogicalLineXT("one two أربعة ثلاثة", "ltr"), "one two ثلاثة أربعة")
	Then("told the paragraph is right-to-left, the same tie is read the other way", StzOcrLogicalLineXT("800 1234 الساخن الخط", "rtl"), "الخط الساخن 800 1234")
	Then("a line that begins with a Latin word and is half Arabic is read left-to-right", StzOcrLogicalLine("one two أربعة ثلاثة"), "one two ثلاثة أربعة")
EndScenario()

if StzOcrPlatformHas("fr-FR")
	Scenario("The floor reads a French document: every key sentence is in its text")
		o = StzOcrQ([ :pages = [ $cDir + "z09_p1_150dpi.png", $cDir + "z09_p2_150dpi.png" ], :lang = "fr-FR" ])
		cT = o.Text()
		Then("two pages were read", o.NumberOfPages(), 2)
		Then("the text holds the title", StzFindFirst("Plaine Mobilité", cT) > 0, 1)
		aG = StzOcrGoldensV1($cDir)
		nG = len(aG)
		nOk = 0
		nAll = 0
		for i = 1 to nG
			if aG[i][1][:lang] != "fr-FR" loop ok
			nAll++
			if StzFindFirst(lower(aG[i][2]), lower(cT)) > 0 nOk++ ok
		next
		? "   French sentences found: " + nOk + " of " + nAll + " (" + o.LastSummary() + ")"
		Then("at least eight of the nine sentences are found verbatim", nOk >= 8, 1)
		Then("the lines are many", o.NumberOfLines() > 60, 1)
	EndScenario()
else
	? "SKIP: The floor reads a French document -- no fr-FR pack on this machine"
ok

if StzOcrPlatformHas("ar-SA")
	Scenario("The floor reads an Arabic document in logical order")
		o = StzOcrQ([ :pages = [ $cDir + "y11_p1_150dpi.png", $cDir + "y11_p2_150dpi.png" ], :lang = "ar-SA" ])
		cT = o.Text()
		aG = StzOcrGoldensV1($cDir)
		nG = len(aG)
		nOk = 0
		nAll = 0
		for i = 1 to nG
			if aG[i][1][:lang] != "ar-SA" loop ok
			nAll++
			if StzFindFirst(lower(aG[i][2]), lower(cT)) > 0 nOk++ ok
		next
		? "   Arabic sentences found: " + nOk + " of " + nAll + " (" + o.LastSummary() + ")"
		Then("the title is read, in logical order", StzFindFirst("ملخص وثيقة تأمين المنزل", cT) > 0, 1)
		Then("at least half of the sentences are found verbatim", nOk * 2 >= nAll, 1)
	EndScenario()
else
	? "SKIP: The floor reads an Arabic document -- no ar-SA pack on this machine"
ok

if StzOcrPlatformHas("fr-FR") and StzOcrPlatformHas("ar-SA")
	Scenario("The registry measures the floor on the golden set and files the score")
		aRows = StzModelRegistryQ().RunGoldens(:ocr)
		aM = StzModelRegistryQ().MeasurementOf(:ocr, "platform")
		? "   platform floor on ocr goldens v1: " + aM[:score] + " over " + aM[:n] + " items"
		Then("the floor is measured", aM[:n], 17)
		Then("it scores at least 0.75 (French at the ceiling, Arabic above half)", aM[:score] >= 0.75, 1)
		StzSaveMeasurements("results/ocr.zmdl.txt")
		Then("the measurement is filed", fexists("results/ocr.zmdl.txt"), 1)
	EndScenario()
else
	? "SKIP: The registry measures the floor on the golden set -- both packs are needed on this machine"
ok

Scenario("A language the platform has no pack for is a refusal that names it")
	oP = StzFacultyQ(:ocr).RunQ([ :pages = [ $cDir + "z09_p1_150dpi.png" ], :lang = "xx-XX" ], [ :lang = "xx-XX" ])
	Then("the answer is a refusal", oP.IsRefusal(), 1)
	Then("and it names the language", StzFindFirst("xx-XX", oP.Why()) > 0, 1)
EndScenario()

Summary()
