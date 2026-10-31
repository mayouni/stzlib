# ocr_narrated.ring -- OCR as a faculty (base/ocr/stzOcr.ring), told as scenes.
#
# The :ocr faculty's FLOOR is the platform engine (Windows.Media.Ocr) with right-to-left lines put back in logical
# order; it refuses, naming what is missing, where the platform cannot serve. These scenes pin the declaration,
# the reorder (which needs no engine), and -- where this machine has the packs -- the floor's reading of two golden
# documents whose expectations were written by authors who never saw a reader (golden_v36/z09 in French,
# golden_v35/y11 in Arabic), rendered at 150 dpi in _data/. Two scenes read a SCANNED PDF -- the synthetic scans
# _data/scan_flate_gray.pdf and _data/scan_dct_rgb.pdf (z09 page 1 as one image, no text layer; _rig/_make_scan_pdfs.py)
# -- through stzPdf.PageImages / SaveImage / TextOrOcr. A scene the machine cannot run is SKIPPED BY NAME.
#
#   cd libraries/stzlib/base/test/ocr ; rnxc ocr_narrated.ring

load "../../stzBase.ring"
load "../_narrated.ring"
load "_data/goldens_v2.ring"

$cDir = "_data/"
$aPacks = StzOcrPlatformLanguages()
? "platform OCR packs on this machine: " + @@($aPacks)

Scenario("The :ocr faculty is declared with a platform floor and the contains checker")
	o = StzOcrDeclare(StzOcrGoldensV2($cDir))
	Then("it has a floor", o.HasFloor(), 1)
	Then("the floor is the platform engine", o.Floor()[:id], "platform")
	Then("an image in", o.InputType(), "image")
	Then("a text out", o.OutputType(), "text")
	Then("a golden is a sentence the text must contain", o.GoldenChecker(), "contains")
	Then("the golden set holds one item per key sentence of the three documents", len(o.Goldens()), 26)
	Then("it is golden set v2", o.GoldenVersion(), "v2")
	Then("measured per language: each golden names its language under :lang", o.GoldenLanguageKey(), "lang")
	Then("a golden's language is its two-letter code", StzGoldenLanguageOf(:ocr, o.Goldens()[26][1], []), "ru")
EndScenario()

Scenario("A right-to-left line the platform returned in visual order is put back in logical order")
	Then("a Latin line is left as it is", StzOcrLogicalLine("Les horaires du samedi sont affichés."), "Les horaires du samedi sont affichés.")
	Then("an Arabic line's words are reversed", StzOcrLogicalLine("الوثيقة بنص يؤخذ الاختلاف وعند"), "وعند الاختلاف يؤخذ بنص الوثيقة")
	# the page prints a hotline written 800 1234 as 1234 800 (y11's header, read by the platform 2026-10-31):
	# two numbers apart are two right-to-left runs, and a reversed line keeps them so
	Then("two numbers apart keep the paragraph's order", StzOcrLogicalLine("1234 800 الساخن الخط"), "الخط الساخن 800 1234")
	Then("a Latin word inside it keeps its own order", StzOcrLogicalLine("HP-2026-48213 الوثيقة رقم"), "رقم الوثيقة HP-2026-48213")
	Then("a number after a Latin word joins its run", StzOcrLogicalLineXT("HP 2026 الوثيقة رقم", "rtl"), "رقم الوثيقة HP 2026")
	Then("in a left-to-right line, told so, only the Arabic run inside is reversed", StzOcrLogicalLineXT("one two أربعة ثلاثة", "ltr"), "one two ثلاثة أربعة")
	Then("told the paragraph is right-to-left, the same line is read the same way", StzOcrLogicalLineXT("1234 800 الساخن الخط", "rtl"), "الخط الساخن 800 1234")
	# the Arabic pack returns a word holding Latin letters with its pieces turned (y11's policy number)
	Then("a word the Arabic pack turned is put back as it stands", _StzOcrPlatformVisualLine("وثيقة 2026-48213-HP رقم"), "وثيقة HP-2026-48213 رقم")
	Then("its brackets are mirrored back", _StzOcrPlatformVisualLine("12(HP)"), "(HP)12")
	Then("a number with an Arabic comma is left as the pack gave it", _StzOcrPlatformVisualLine("25، شارع"), "25، شارع")
	# the platform takes 0 for O and 1 for l inside small numbers (y11's footer on a phone photo: 2O26-482l3)
	Then("an O or an l between two digits is the digit", _StzOcrDigitsBetween("2O26-482l3-HP"), "2026-48213-HP")
	Then("a letter with a digit on one side only is left alone", _StzOcrDigitsBetween("le 1er Ol 12h Lo1"), "le 1er Ol 12h Lo1")
	Then("a capital L or i between digits is not taken for 1", _StzOcrDigitsBetween("2L3 4i5"), "2L3 4i5")
	Then("a line that begins with a Latin word and is half Arabic is read left-to-right", StzOcrLogicalLine("one two أربعة ثلاثة"), "one two ثلاثة أربعة")
EndScenario()

if StzOcrPlatformHas("fr-FR")
	Scenario("The floor reads a French document: every key sentence is in its text")
		o = StzOcrQ([ :pages = [ $cDir + "z09_p1_150dpi.png", $cDir + "z09_p2_150dpi.png" ], :lang = "fr-FR" ])
		cT = o.Text()
		Then("two pages were read", o.NumberOfPages(), 2)
		Then("the text holds the title", StzFindFirst("Plaine Mobilité", cT) > 0, 1)
		aG = StzOcrGoldensV2($cDir)
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
		aG = StzOcrGoldensV2($cDir)
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
		oReg = StzModelRegistryQ()
		aFr = oReg.MeasurementOfIn(:ocr, "platform", "fr")
		aAr = oReg.MeasurementOfIn(:ocr, "platform", "ar")
		aRu = oReg.MeasurementOfIn(:ocr, "platform", "ru")
		? "   platform floor on ocr goldens v2: " + aM[:score] + " over " + aM[:n] + " items -- fr " + aFr[:score] +
		  ", ar " + aAr[:score] + ", ru " + aRu[:score]
		Then("the floor is measured on the whole set", aM[:n], 26)
		Then("and per language: 9 French, 8 Arabic, 9 Russian items", @@([ aFr[:n], aAr[:n], aRu[:n] ]), @@([ 9, 8, 9 ]))
		Then("French at the ceiling", aFr[:score], 1)
		Then("Arabic above half", aAr[:score] >= 0.5, 1)
		if NOT StzOcrPlatformHas("ru-RU")
			Then("Russian refused: no ru-RU pack here, so no Russian answer conforms", aRu[:conformance], 0)
		ok
		StzSaveMeasurements("results/ocr.zmdl.txt")
		Then("the measurement is filed", fexists("results/ocr.zmdl.txt"), 1)
	EndScenario()
else
	? "SKIP: The registry measures the floor on the golden set -- both packs are needed on this machine"
ok

Scenario("A scanned PDF hands out its page image: Flate samples as a BMP, a JPEG stream as it is")
	o = StzPdfQ($cDir + "scan_flate_gray.pdf")
	Then("the scan has no text layer", o.HasText(), 0)
	Then("and one image", o.NumberOfImages(), 1)
	Then("so it is a scan", o.IsScanned(), 1)
	aI = o.PageImages()
	Then("the image is on page 1", aI[1][:page], 1)
	Then("its size is the page's", @@([ aI[1][:width], aI[1][:height] ]), @@([ 1241, 1754 ]))
	Then("eight bits, one component, Flate", @@([ aI[1][:bits], aI[1][:components], aI[1][:filter] ]), @@([ 8, 1, "FlateDecode" ]))
	Then("decoded to samples", aI[1][:kind], "samples")
	cF = o.SaveImage(1, sysget("TEMP") + "\stz_ocr_test_flate")
	Then("saved as a BMP", right(cF, 4), ".bmp")
	Then("that starts as one", left(read(cF), 2), "BM")
	o2 = StzPdfQ($cDir + "scan_dct_rgb.pdf")
	aI2 = o2.PageImages()
	Then("a JPEG stream is handed out as JPEG", @@([ aI2[1][:filter], aI2[1][:kind], aI2[1][:components] ]), @@([ "DCTDecode", "jpeg", 3 ]))
	cJ = o2.SaveImage(1, sysget("TEMP") + "\stz_ocr_test_dct")
	Then("saved as a .jpg", right(cJ, 4), ".jpg")
	Then("that starts as one", ascii(left(read(cJ), 1)), 255)
EndScenario()

if StzOcrPlatformHas("fr-FR")
	Scenario("A scan goes end to end: PDF, page image, the :ocr floor, text")
		o = StzPdfQ($cDir + "scan_flate_gray.pdf")
		cT = o.TextOrOcr("fr-FR")
		Then("the Flate scan reads its title", StzFindFirst("Plaine Mobilité", cT) > 0, 1)
		Then("and a sentence of page 1", StzFindFirst("La ligne 12 relie la gare routière", cT) > 0, 1)
		cT2 = StzPdfQ($cDir + "scan_dct_rgb.pdf").TextOrOcr("fr-FR")
		Then("the JPEG scan reads the same title", StzFindFirst("Plaine Mobilité", cT2) > 0, 1)
		Then("a born-digital PDF keeps its text layer", StzFindFirst("Plaine", StzPdfQ("../document/_data/golden_v36/z09.pdf").TextOrOcr("fr-FR")) > 0, 1)
	EndScenario()
else
	? "SKIP: A scan goes end to end -- no fr-FR pack on this machine"
ok

Scenario("A language the platform has no pack for is a refusal that names it")
	oP = StzFacultyQ(:ocr).RunQ([ :pages = [ $cDir + "z09_p1_150dpi.png" ], :lang = "xx-XX" ], [ :lang = "xx-XX" ])
	Then("the answer is a refusal", oP.IsRefusal(), 1)
	Then("and it names the language", StzFindFirst("xx-XX", oP.Why()) > 0, 1)
EndScenario()

Summary()
