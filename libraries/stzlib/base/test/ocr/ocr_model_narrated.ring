# ocr_model_narrated.ring -- the :ocr faculty's MODEL implementation reads pages (OCR slices O3b, O3c), told as scenes.
#
# PP-OCRv6 small -- its detector, angle classifier and recogniser converted to GGUF by engine/tools/onnx_to_gguf.py
# and proven at parity with onnxruntime (ocr_model_parity_narrated.ring) -- is run end to end by the engine
# (engine/src/ocr_pipeline.zig): the page is scaled for the detector, the probability map becomes boxes, each box
# is cropped, the page is turned over if most of its lines vote so, and each line is recognised; the CTC output is
# decoded against the dictionary the converter carried in the recogniser's GGUF. The steps and constants are
# RapidOCR's, with the departures stated in the engine file. O3c adds two recognisers picked by the page's language:
# PP-OCRv5 mobile Arabic (right to left: the engine returns logical order, a row's cells from the right, and skips
# the classifier, which calls upright Arabic upside down) and PP-OCRv5 mobile Cyrillic.
#
# The scenes read golden_v36/z09 (French), golden_v35/y11 (Arabic) and golden_v33/u06 (Russian), rendered at 150 dpi
# in _data/; check reading order, logical order and that no line of an upright page is turned over; measure the
# Russian key sentences beside the registry (goldens_ru_u06.ring -- the faculty's set v1 has no Russian); and let
# the registry measure the model against the platform floor on the 17 goldens. Every sentence was written by an
# author who never saw a reader.
#
# The graphs are NOT in the repository (*.gguf is ignored): without libraries/stzlib/models/ocr/ the whole guard
# SKIPS by name.
#
#   cd libraries/stzlib/base/test/ocr ; rnxc ocr_model_narrated.ring

load "../../stzBase.ring"
load "../_narrated.ring"
load "_data/goldens_v1.ring"
load "_data/goldens_ru_u06.ring"

$cDir = "_data/"

if NOT fexists(StzOcrModelDir() + "/ppocr_rec.gguf")
	? "SKIP: every scene -- the :ocr model is not installed (no " + StzOcrModelDir() + "/ppocr_rec.gguf; write it with engine/tools/onnx_to_gguf.py)"
	shutdown(0)
ok

Scenario("The model is declared on the :ocr faculty as an engine graph, beside the platform floor")
	o = StzOcrDeclare(StzOcrGoldensV1($cDir))
	Then("the faculty has two implementations", @@(o.ImplementationIds()), @@([ "platform", "ppocr" ]))
	Then("the model is installed: its recogniser is in the models directory", StzImplementationIsInstalled(o.Implementations()[2]), 1)
EndScenario()

Scenario("The model reads a French page: every line, in reading order, boxed in the file's pixels")
	t0 = clock()
	aL = StzOcrModelLines($cDir + "z09_p1_150dpi.png")
	nMs = (clock() - t0) * 1000 / clockspersecond()
	aS = StzOcrModelLastStats()
	? "   " + len(aL) + " lines in " + floor(nMs) + " ms (detect " + floor(aS[:detect]) + ", classify " + floor(aS[:classify]) +
	  ", recognise " + floor(aS[:recognise]) + ")"
	Then("it finds the page's lines", len(aL) > 60, 1)
	Then("the first line is the header's name", aL[1][:text], "Plaine Mobilité")
	Then("the second is the header's right-hand title, on the same line", aL[2][:text], "Horaires 2026-2027")
	Then("the title is read whole", aL[3][:text], "Ligne 12 : Gare routière - Hôpital Saint-Lazare")
	Then("an accented sentence is read whole", lineIndex(aL, "Les horaires du samedi sont affichés à chaque arrêt.") > 0, 1)
	bOrder = 1
	nLines = len(aL)
	for i = 2 to nLines
		# a line starts at or below the one before, give or take the 10 px the reading order allows
		if aL[i][:box][2] < aL[i-1][:box][2] - 10 bOrder = 0 ok
	next
	Then("each line starts at or below the one before it", bOrder, 1)
	Then("a box lies inside the page (1241 x 1754)", aL[1][:box][1] >= 0 and aL[1][:box][3] <= 1241 and aL[nLines][:box][4] <= 1754, 1)
	Then("every line kept has a confidence of 0.5 or more", minScore(aL) >= 0.5, 1)
	Then("the page is upright: no line is turned over (its classifier votes were outvoted)", aS[:votes180] * 2 < len(aL), 1)
	# the band is from measurement: 7 s on a loaded machine (2026-10-30), 89 s before the detector's head stopped
	# materialising its im2col; the band catches that cliff and not ambient load
	Then("a page costs under 40 seconds", nMs < 40000, 1)
EndScenario()

Scenario("A second read of the same page is served from the cache")
	t0 = clock()
	aL2 = StzOcrModelLines($cDir + "z09_p1_150dpi.png")
	Then("the same lines", len(aL2), len(aL))
	Then("in no time", (clock() - t0) * 1000 / clockspersecond() < 100, 1)
EndScenario()

Scenario("An Arabic page is read with the Arabic recogniser, in logical order, its rows from the right")
	aA = StzOcrModelLinesXT($cDir + "y11_p1_150dpi.png", "ar-SA")
	aS = StzOcrModelLastStats()
	Then("the recogniser for ar-SA is the Arabic one", StzOcrModelRecogniserFor("ar-SA"), "ppocr_rec_arabic.gguf")
	Then("it finds the page's lines", len(aA) > 30, 1)
	Then("the header reads in logical order", StzFindFirst("شركة الأمان الوطنية", aA[1][:text]) > 0, 1)
	Then("a short paragraph line is read whole", lineIndex(aA, "الوثيقة الكاملة، وعند الاختلاف يؤخذ بنص الوثيقة") > 0, 1)
	Then("a long paragraph line is read whole (the classifier would have turned it over)",
	     lineIndex(aA, "يوضح هذا الملخص أهم شروط وثيقة تأمين المنزل الصادرة عن شركة الأمان الوطنية للتأمين ولا يغني هذا الملخص عن قراءة") > 0, 1)
	nPol = lineIndex(aA, "HP-2026-48213")
	Then("a Latin-and-digits cell keeps its own left-to-right order", nPol > 0, 1)
	Then("and, the row read from the right, it comes before its label on the left", lineIndex(aA, "رقم الوثيقة") = nPol + 1, 1)
	Then("the classifier was not asked: no vote, no line turned over", aS[:votes180], 0)
EndScenario()

Scenario("A Russian page is read with the Cyrillic recogniser; the floor has no Russian pack here")
	aG = StzOcrGoldensRuU06($cDir)
	cRu = _StzOcrModel(aG[1][1], [ :lang = "ru-RU" ])
	nHit = 0
	nG = len(aG)
	for i = 1 to nG
		if StzFindFirst(aG[i][2], cRu) > 0 nHit++ else ? "   missed: " + aG[i][2] ok
	next
	? "   ru: " + nHit + " of " + nG + " key sentences of golden_v33/u06"
	Then("the recogniser for ru-RU is the Cyrillic one", StzOcrModelRecogniserFor("ru-RU"), "ppocr_rec_cyrillic.gguf")
	Then("it finds 8 of the 9 Russian key sentences (the miss: 'config' read with Cyrillic c and o)", nHit, 8)
	Then("the platform has no Russian pack on this machine, so the floor would refuse them", StzOcrPlatformHas("ru-RU"), 0)
EndScenario()

Scenario("A script with no recogniser here is refused, naming what is missing")
	cErr = ""
	try
		_StzOcrModel([ :pages = [ $cDir + "y11_p1_150dpi.png" ], :lang = "he-IL" ], [])
	catch
		cErr = cCatchError
	done
	Then("Hebrew is refused", StzFindFirst("has no recogniser for 'he-il'", cErr) > 0, 1)
	Then("and the refusal names the scripts there are", StzFindFirst("Arabic and Cyrillic", cErr) > 0, 1)
EndScenario()

Scenario("The registry measures the model on the 17 goldens and keeps the floor, saying why")
	aRows = StzModelRegistryQ().RunGoldens(:ocr)
	aF = StzModelRegistryQ().MeasurementOf(:ocr, "platform")
	aM = StzModelRegistryQ().MeasurementOf(:ocr, "ppocr")
	? "   platform " + aF[:score] + "   ppocr " + aM[:score] + "   (n " + aM[:n] + ")"
	Then("both were measured", len(aRows), 2)
	Then("the model finds every French sentence and no Arabic one: 9 of 17", floor(aM[:score] * 17 + 0.5), 9)
	Then("the floor scores more: its Arabic keeps the periods and the numbers", aF[:score] > aM[:score], 1)
	oP = StzModelRegistryQ().ResolveQ(:ocr)
	Then("so the floor answers", oP.Chosen(), "platform")
	Then("and the plan says the model was rejected", StzFindFirst("rejected ppocr", oP.Why()) > 0, 1)
	StzSaveMeasurements("results/ocr.zmdl.txt")
	Then("the measurement is filed", fexists("results/ocr.zmdl.txt"), 1)
EndScenario()

Summary()

func minScore(paL)
	n = 1
	nLines = len(paL)
	for i = 1 to nLines
		if paL[i][:score] < n n = paL[i][:score] ok
	next
	return n

func lineIndex(paL, pcText)
	nLines = len(paL)
	for i = 1 to nLines
		if paL[i][:text] = pcText return i ok
	next
	return 0
