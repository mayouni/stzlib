# FIND WHAT THE WORDS NAME -- IM9f, narrated
#
# SOFTANZA_IMAGE_INTELLIGENCE.md IM9f. stzImage.FindByWords("traffic cone") answers with boxes: OWL-ViT (Google, Apache-2.0) run by the
# engine -- a vision graph of 576 patches and a text graph, both converted from ONNX, and a CLIP tokenizer written in Zig. The plane's
# discipline applies: every piece is held to the reference's own answer, and the faculty is chosen by a measurement made under a rule
# written before the pairs existed.
#
#   Scene 1  THE TOKENIZER against Hugging Face's, on 98 prompts: contractions, digits, punctuation runs, capitals, odd whitespace, five
#            scripts, an emoji, a query too long for 16 tokens, the empty query -- and the two facts the reference taught us (every "!" is a
#            token of its own, id 0; a capital accented letter is lower-cased by Unicode, not by ASCII)
#   Scene 2  THE QUERY EMBEDDING: the converted text graph's end-token row, normalised, against the reference model's, on 13 queries
#   Scene 3  THE DETECTIONS on the spike's picture against the reference's (a cat on a laptop): the same boxes, the same scores
#   Scene 4  THE FACE: the shape of the answer, one picture's graph run once for many sets of words, the door, the refusal
#   Scene 5  THE JUDGING RECORD: 320 pairs judged once (image_find_judge.ring) -- the shares re-added from the saved verdicts, the bar
#            (strictly more than the floor) checked, and ten pairs re-run live against their stored verdicts
#   Scene 6  the registry: the two implementations of :find measured, the faculty answers through the choice
#   Scene 7  what a person looks at: a page of pictures with the truth, the floor and OWL-ViT drawn on them
#
# NEEDS the engine built with IM9f, models/vision/owlvit_*.gguf + owlvit_vocab.json + owlvit_merges.txt (models/MODELS.md), and
# D:/GitHub/_wti_models_src/coco/images. HELPERS LIVE AFTER pf().

load "../../stzBase.ring"

$nPass = 0
$nFail = 0
$nSec = clock()
$cCoco = "D:/GitHub/_wti_models_src/coco/images/"
decimals(6)

if NOT StzVisionHasModel($cStzVisionOwlVision) or NOT StzVisionHasModel($cStzVisionOwlText) or NOT fexists($cCoco + "000000001675.jpg")
	? "NOT RUN: the OWL-ViT model files in " + StzVisionModelsDir() + " or the COCO pictures in " + $cCoco
	shutdown(0)
ok

? "-- Scene 1: the tokenizer against Hugging Face --"
$cVocab = StzVisionModelPath($cStzVisionOwlVocab)
$cMerges = StzVisionModelPath($cStzVisionOwlMerges)
aTok = _ReadTsv("_golden/owlvit_tokens.tsv")
nSame = 0
aDiff = []
for i = 1 to len(aTok)
	cP = _Unescape(aTok[i][2])
	aE = StzEngineNeuralClipIds($cVocab, $cMerges, cP)
	cMine = ""
	for k = 1 to len(aE)
		if k > 1  cMine += " " ok
		cMine += "" + floor(aE[k])
	next
	if cMine = aTok[i][1]
		nSame++
	else
		aDiff + cP
	ok
next
? "      " + nSame + " of " + len(aTok) + " prompts give Hugging Face's 16 ids" + _First(aDiff)
chk("all " + len(aTok) + " prompts give exactly the ids Hugging Face's tokenizer gives", nSame = len(aTok) and len(aTok) = 98)
chk("'a!b' is three pieces with the pad token's id 0 between them (Hugging Face: 320, 0, 321) -- not 'a!</w>b' and not a '!' merged into a run", _Ids("a!b")[2] = 320 and _Ids("a!b")[3] = 0 and _Ids("a!b")[4] = 321 and _Ids("a!b")[5] = 49407)
chk("'!!!' is three tokens of id 0 each (OpenAI's own tokenizer gives one '!!!</w>', 995)", _Ids("!!!")[2] = 0 and _Ids("!!!")[3] = 0 and _Ids("!!!")[4] = 0 and _Ids("!!!")[5] = 49407)
chk("a capital accented letter is lower-cased by Unicode, as Hugging Face does: the ids of the capital form are the golden's and equal the small form's", @@(_Ids("École")) = @@(_GoldenIds(aTok, "École")) and @@(_Ids("École")) = @@(_Ids("école")))
chk("a query too long for 16 tokens is cut and still ends with the end token", _Ids("one two three four five six seven eight nine ten eleven twelve thirteen fourteen")[16] = 49407)
chk("the empty query is the start token, the end token, then zeros", _Ids("")[1] = 49406 and _Ids("")[2] = 49407 and _Ids("")[3] = 0)
sec("scene 1")

? "-- Scene 2: the query embedding against the reference model's --"
aEmb = _ReadTsv("_golden/owlvit_text_embed.tsv")
cTextModel = StzVisionModelPath($cStzVisionOwlText)
nWorst = 0
nCosMin = 1
for i = 1 to len(aEmb)
	cP = aEmb[i][1]
	aRef = split(aEmb[i][2], " ")
	aE = StzEngineNeuralClipEmbed(cTextModel, $cVocab, $cMerges, cP, 4)
	nMax = 0
	nDot = 0
	for k = 1 to len(aE)
		nD = aE[k] - number(aRef[k])
		if nD < 0  nD = -nD ok
		if nD > nMax  nMax = nD ok
		nDot += aE[k] * number(aRef[k])
	next
	if nMax > nWorst  nWorst = nMax ok
	if nDot < nCosMin  nCosMin = nDot ok
next
? "      " + len(aEmb) + " queries, 512 numbers each: the largest difference " + nWorst + ", the smallest cosine " + nCosMin
chk("the engine's query embedding is the reference's to within the golden's six decimals (largest difference < 0.000002)", nWorst < 0.000002 and len(aEmb) = 13)
chk("every query's cosine with the reference's embedding is at least 0.999999", nCosMin > 0.999999)
sec("scene 2")

? "-- Scene 3: the detections against the reference's, on a cat on a laptop --"
aRef = _ReadTsv("_golden/owlvit_reference_detections.tsv")
aWords = []
for i = 1 to len(aRef)
	aWords + aRef[i][2]
next
oCat = StzImageQ($cCoco + "000000001675.jpg")
nW = oCat.Width()
nH = oCat.Height()
t0 = clock()
aRows = oCat.FindByWordsXT(aWords, 0.1)
nMs = (clock() - t0) / clockspersecond() * 1000
? "      " + len(aRows) + " box(es) for " + len(aWords) + " words in " + floor(nMs) + " ms (the first picture: graph and three queries)"
for i = 1 to len(aRef)
	aBest = _BestRow(aRows, aRef[i][2])
	if len(aBest) = 0
		chk("the reference's '" + aRef[i][2] + "' is found", 0)
		loop
	ok
	aR = split(aRef[i][3], " ")
	nX0 = (aBest[:box][1] - 1) / nW
	nY0 = (aBest[:box][2] - 1) / nH
	nX1 = (aBest[:box][1] - 1 + aBest[:box][3]) / nW
	nY1 = (aBest[:box][2] - 1 + aBest[:box][4]) / nH
	nBox = _Max4(_Abs(nX0 - number(aR[1])), _Abs(nY0 - number(aR[2])), _Abs(nX1 - number(aR[3])), _Abs(nY1 - number(aR[4])))
	nSc = _Abs(aBest[:score] - number(aRef[i][4]))
	? "      " + aRef[i][2] + ": score " + aBest[:score] + " (reference " + aRef[i][4] + "), box within " + nBox + " of the reference's"
	chk("'" + aRef[i][2] + "': the score is the reference's to within 0.003 and the box to within 0.002 (the JPEG decoder differs from libjpeg by up to 2 levels)", nSc < 0.003 and nBox < 0.002)
next
chk("the reference's cat is the strongest answer of all three words", len(aRows) >= 3 and aRows[1][:query] = "a photo of a cat" and aRows[1][:score] > 0.8)
sec("scene 3")

? "-- Scene 4: the face --"
aOne = oCat.FindByWords("cat")
chk("a word gives rows with :query, :score and :box, best first", len(aOne) >= 1 and HasKey(aOne[1], :query) and HasKey(aOne[1], :score) and HasKey(aOne[1], :box) and aOne[1][:query] = "cat")
b = aOne[1][:box]
chk("the box is 1-based pixels inside the picture: x >= 1, y >= 1, x + w - 1 <= width, y + h - 1 <= height", b[1] >= 1 and b[2] >= 1 and b[1] + b[3] - 1 <= nW and b[2] + b[4] - 1 <= nH)
chk("a list of words and a bare string give the same answer for one word", @@(oCat.FindByWords([ "cat" ])) = @@(aOne))
chk("no word, an empty string, an empty list: nothing, and no model is called", len(oCat.FindByWords("")) = 0 and len(oCat.FindByWords([])) = 0 and len(oCat.FindByWords("   ")) = 0)
nCalls = StzVisionCallsRecorded()
aA = oCat.FindByWords("laptop")
nMsCached = StzEngineNeuralVisionMs()
aB = oCat.FindByWords("keyboard")
? "      the graph ran for this picture before; the engine reports " + nMsCached + " ms of graph for a new word about it"
chk("a second set of words about the SAME picture runs no graph (0 ms), so many words cost the graph once", nMsCached = 0 and StzEngineNeuralVisionMs() = 0)
chk("every call went through the door: the ledger holds " + (StzVisionCallsRecorded() - nCalls) + " new model.call record(s) for 2 calls", StzVisionCallsRecorded() - nCalls = 2)
cKeep = $cStzVisionOwlText
$cStzVisionOwlText = "no_such_model.gguf"
cErr = ""
try
	oCat.FindByWords("anything new")
catch
	cErr = cCatchError
done
$cStzVisionOwlText = cKeep
chk("a missing model is a refusal that names the file, not a silent empty answer", len(StzFind("no_such_model.gguf", cErr)) > 0)
aFl = _StzVisionFindFloor([ $cCoco + "000000001675.jpg", "a photo of a cat" ], [])
aFlCat = _StzVisionFindFloor([ $cCoco + "000000001675.jpg", "cat" ], [])
chk("the FLOOR answers a word only if it IS a COCO class name: 'cat' finds the cat, 'a photo of a cat' finds nothing", len(aFl) = 0 and len(aFlCat) >= 1)
oCat.Release()
sec("scene 4")

? "-- Scene 5: the judging record (judged once, image_find_judge.ring) --"
aJ = _ReadTsv("_golden/owl_find_v1_judged.tsv")
aTot = []
for g = 1 to 4  aTot + [ 0, 0, 0 ]  next
for i = 1 to len(aJ)
	g = 1
	if aJ[i][3] = "B"  g = 3 ok
	if aJ[i][4] = "neg"  g += 1 ok
	aTot[g][1] += number(aJ[i][5])
	aTot[g][2] += number(aJ[i][6])
	aTot[g][3] += 1
next
nF = aTot[1][1] + aTot[2][1] + aTot[3][1] + aTot[4][1]
nO = aTot[1][2] + aTot[2][2] + aTot[3][2] + aTot[4][2]
aName = [ "kind A positives (the floor's own words)", "kind A negatives", "kind B positives (words outside COCO's 80)", "kind B negatives" ]
for g = 1 to 4
	? "      " + aName[g] + ": " + aTot[g][3] + " pairs | floor " + aTot[g][1] + " | owlvit " + aTot[g][2]
next
? "      ALL: floor " + nF + " of " + len(aJ) + " | owlvit " + nO + " of " + len(aJ)
chk("320 pairs were judged, 160 positive and 160 negative", len(aJ) = 320 and aTot[1][3] + aTot[3][3] = 160 and aTot[2][3] + aTot[4][3] = 160)
chk("the floor agreed on 187 pairs, owlvit on 252 (the numbers in the plan and in vision.zmdl.txt)", nF = 187 and nO = 252)
chk("THE BAR: owlvit's share (" + (nO / 320) + ") is STRICTLY above the floor's (" + (nF / 320) + ")", nO > nF)
chk("the floor finds NOTHING for a word outside COCO's 80 classes: 0 of " + aTot[3][3] + " kind B positives", aTot[3][1] = 0)
chk("owlvit recalls " + aTot[3][2] + " of " + aTot[3][3] + " kind B positives (more than half) and keeps " + aTot[4][2] + " of " + aTot[4][3] + " absent words empty (at least 90%)", aTot[3][2] * 2 > aTot[3][3] and aTot[4][2] >= 0.9 * aTot[4][3])
chk("on the floor's OWN words (kind A positives) owlvit also agrees more often: " + aTot[1][2] + " against " + aTot[1][1] + " of " + aTot[1][3], aTot[1][2] > aTot[1][1])
aGold = _ReadTsv("_golden/owl_find_v1.tsv")
nLive = 0
nLiveOk = 0
for i = 16 to len(aJ) step 32
	aG = _FindGolden(aGold, aJ[i][1], aJ[i][2])
	if len(aG) = 0  loop ok
	aBoxes = _BoxesOf(aG)
	aExp = [ :w = number(aG[6]), :h = number(aG[7]), :boxes = aBoxes ]
	aGot = _StzVisionFindOwl([ $cCoco + aJ[i][1], aJ[i][2] ], [])
	nLive++
	if StzFindAgree(aGot, aExp) = number(aJ[i][6])  nLiveOk++ ok
next
chk("ten judged pairs re-run live give the verdicts stored when they were judged: " + nLiveOk + " of " + nLive, nLive = 10 and nLiveOk = 10)
sec("scene 5")

? "-- Scene 6: the registry --"
chk("the measurements shipped with the library hold both implementations of :find", len(StzMeasurementOf("find", "yolox-by-name", "find-v1")) > 0 and len(StzMeasurementOf("find", "owlvit", "find-v1")) > 0)
cChosen = StzModelRegistryQ().ResolveQ(StzRequirementQ("find")).Chosen()
chk("the registry chooses '" + cChosen + "' for :find, from the measurements alone", cChosen = "owlvit")
oF = StzRunFaculty("find", [ $cCoco + "000000001675.jpg", "cat" ], [], [], [], 0)
? "      the faculty on 'cat': refusal " + oF.IsRefusal() + ", " + @@(oF.Provenance()) + " " + oF.CiteFindings()
chk("StzRunFaculty(:find) answers through the chosen implementation with the cat's box", oF.IsRefusal() = 0 and isList(oF.Value()) and len(oF.Value()) >= 1 and oF.Value()[1][:query] = "cat")
sec("scene 6")

? "-- Scene 7: what a person looks at --"
cOut = StzReplace(WorkingDirectory(), "\", "/") + "/_find-out"
if NOT StzDirExists(cOut)
	StzDirCreatePath(cOut)
ok
WritePage(cOut, aJ, aGold, aTot)
chk("the page is written", fexists(cOut + "/find.html"))
sec("scene 7")

? ""
? "ASSERTIONS: " + ($nPass + $nFail) + " -- " + $nPass + " passed, " + $nFail + " failed"
pf()
shutdown($nFail)

func chk(cWhat, bCond)
	if bCond = 1
		$nPass++
		? "  [OK] " + cWhat
	else
		$nFail++
		? "  [FAIL] " + cWhat
	ok

func sec(cName)
	? "    ~ " + cName + ": " + ((clock() - $nSec) / clockspersecond()) + "s"
	? ""
	$nSec = clock()

func _Abs(n)
	if n < 0  return -n ok
	return n

func _Max4(a, b, c, d)
	n = a
	if b > n  n = b ok
	if c > n  n = c ok
	if d > n  n = d ok
	return n

# the fields of a tab-separated line (Ring's split would also cut at spaces here)
func _Tabs(cLine)
	aOut = []
	cCur = ""
	for k = 1 to len(cLine)
		if ascii(cLine[k]) = 9
			aOut + cCur
			cCur = ""
		else
			cCur += cLine[k]
		ok
	next
	aOut + cCur
	return aOut

func _ReadTsv(cPath)
	aLines = str2list(read(cPath))
	aOut = []
	for i = 1 to len(aLines)
		if len(aLines[i]) > 0  aOut + _Tabs(aLines[i]) ok
	next
	return aOut

# a golden prompt has \n, \t and \\ written out; the \uXXXX of this file's own literals are Ring strings already
func _Unescape(cS)
	cR = ""
	k = 1
	while k <= len(cS)
		c = cS[k]
		if c = "\" and k < len(cS)
			d = cS[k + 1]
			if d = "n"  cR += char(10) ok
			if d = "t"  cR += char(9) ok
			if d = "\"  cR += "\" ok
			k += 2
		else
			cR += c
			k++
		ok
	end
	return cR

func _Ids(cText)
	return StzEngineNeuralClipIds($cVocab, $cMerges, cText)

# the golden ids of a prompt as a list of numbers
func _GoldenIds(aTok, cPrompt)
	for i = 1 to len(aTok)
		if _Unescape(aTok[i][2]) = cPrompt
			aS = split(aTok[i][1], " ")
			aOut = []
			for k = 1 to len(aS)
				aOut + number(aS[k])
			next
			return aOut
		ok
	next
	return []

func _First(aDiff)
	if len(aDiff) = 0  return "" ok
	return " (first difference: [" + aDiff[1] + "])"

func _BestRow(aRows, cQuery)
	for i = 1 to len(aRows)
		if aRows[i][:query] = cQuery  return aRows[i] ok
	next
	return []

func _FindGolden(aGold, cPic, cWord)
	for i = 1 to len(aGold)
		if aGold[i][2] = cPic and aGold[i][3] = cWord and aGold[i][1] = "judge"  return aGold[i] ok
	next
	return []

# the truth boxes of a golden row, 1-based [ x, y, w, h ]
func _BoxesOf(aG)
	aBoxes = []
	if len(aG) >= 8 and len(aG[8]) > 0
		aB = split(aG[8], ";")
		for k = 1 to len(aB)
			aN = split(aB[k], " ")
			aBoxes + [ number(aN[1]) + 1, number(aN[2]) + 1, number(aN[3]), number(aN[4]) ]
		next
	ok
	return aBoxes

# the boxes of a judged row's last column: "x y w h score;" ... -> [ [ x, y, w, h, score ] ... ]
func _JudgedBoxes(cCol)
	aOut = []
	if len(cCol) = 0  return aOut ok
	aB = split(cCol, ";")
	for k = 1 to len(aB)
		aN = split(aB[k], " ")
		if len(aN) >= 5  aOut + [ number(aN[1]), number(aN[2]), number(aN[3]), number(aN[4]), number(aN[5]) ] ok
	next
	return aOut

func Rect(aBox, cClass, nStroke)
	return "<rect class='" + cClass + "' x='" + (aBox[1] - 1) + "' y='" + (aBox[2] - 1) + "' width='" + aBox[3] + "' height='" + aBox[4] + "' stroke-width='" + nStroke + "' fill='none'/>"

# one tile: the picture, the truth (green), what owlvit found (orange) and a verdict for each implementation
func Tile(cOut, aJ, aG, cNote)
	cPic = aJ[1]
	oI = StzImageQ($cCoco + cPic)
	nW = oI.Width()
	nH = oI.Height()
	oI.SaveAsJpeg(cOut + "/" + cPic, 85)
	oI.Release()
	nStroke = nW / 150
	cSvg = "<svg viewBox='0 0 " + nW + " " + nH + "' xmlns='http://www.w3.org/2000/svg'>"
	aT = _BoxesOf(aG)
	for k = 1 to len(aT)
		cSvg += Rect(aT[k], "t", nStroke)
	next
	aO = _JudgedBoxes(aJ[8])
	for k = 1 to len(aO)
		cSvg += Rect(aO[k], "o", nStroke)
	next
	cSvg += "</svg>"
	cF = "bad"
	if aJ[5] = "1"  cF = "ok" ok
	cO = "bad"
	if aJ[6] = "1"  cO = "ok" ok
	cKind = "outside COCO's 80"
	if aJ[3] = "A"  cKind = "a COCO class" ok
	cTruth = "absent (LVIS verified it)"
	if aJ[4] = "pos"  cTruth = "present: " + len(aT) + " box(es)" ok
	return "<div class='c'><div class='im'><img src='" + cPic + "' alt='" + aJ[2] + "'>" + cSvg + "</div><p><b>" + aJ[2] + "</b> - " + cKind + ", " + cTruth +
		"</p><p><span class='b " + cF + "'>floor " + cF + "</span><span class='b " + cO + "'>owlvit " + cO + "</span> " + cNote + "</p></div>"

func Pick(aJ, cKind, cPol, cF, cO, nMax, aTaken)
	aOut = []
	for i = 1 to len(aJ)
		if len(aOut) >= nMax  exit ok
		if aJ[i][3] != cKind  loop ok
		if aJ[i][4] != cPol  loop ok
		if cF != "" and aJ[i][5] != cF  loop ok
		if cO != "" and aJ[i][6] != cO  loop ok
		bDup = 0
		for k = 1 to len(aTaken)
			if aTaken[k] = i  bDup = 1 ok
		next
		if bDup = 1  loop ok
		aOut + i
	next
	return aOut

func WritePage(cOut, aJ, aGold, aTot)
	nF = aTot[1][1] + aTot[2][1] + aTot[3][1] + aTot[4][1]
	nO = aTot[1][2] + aTot[2][2] + aTot[3][2] + aTot[4][2]
	c = "<!doctype html><html lang='en'><head><meta charset='utf-8'><meta name='viewport' content='width=device-width,initial-scale=1'>" +
		"<title>Find by words</title><style>" +
		":root{--bg:#fff;--fg:#1c1c1e;--mut:#6b6b70;--line:#d8d8dc;--ok:#1a7f37;--bad:#b3261e;--card:#f6f6f8;--t:#1a9850;--o:#e8710a}" +
		"@media (prefers-color-scheme:dark){:root{--bg:#161618;--fg:#ececf0;--mut:#9a9aa2;--line:#3a3a40;--ok:#4cc26a;--bad:#f28b82;--card:#202024;--t:#5fd38a;--o:#ffa04d}}" +
		"body{margin:0;background:var(--bg);color:var(--fg);font:16px/1.5 system-ui,Segoe UI,sans-serif}main{max-width:1100px;margin:0 auto;padding:16px}" +
		"h1{font-size:1.5rem;margin:.3em 0}h2{font-size:1.1rem;margin:1.5em 0 .3em}p.sub{color:var(--mut)}" +
		".k{display:grid;grid-template-columns:repeat(auto-fit,minmax(210px,1fr));gap:12px;margin:1em 0}.kp{background:var(--card);border-radius:8px;padding:10px 14px}" +
		".kp b{display:block;font-size:1.4rem}.kp span{color:var(--mut);font-size:.88rem}" +
		".g{display:grid;grid-template-columns:repeat(auto-fill,minmax(300px,1fr));gap:12px}.c{border:1px solid var(--line);border-radius:8px;padding:8px}" +
		".im{position:relative}.im img{width:100%;height:auto;display:block}.im svg{position:absolute;left:0;top:0;width:100%;height:100%}" +
		".t{stroke:var(--t)}.o{stroke:var(--o);stroke-dasharray:none}.c p{margin:.3em 0 0;font-size:.85rem;color:var(--mut)}.c p b{color:var(--fg)}" +
		".b{display:inline-block;border-radius:4px;padding:1px 7px;margin:2px 4px 0 0;font-size:.78rem}.ok{background:#1a7f3722;color:var(--ok)}.bad{background:#b3261e22;color:var(--bad)}" +
		".lg span{display:inline-block;margin-right:14px}.lg i{display:inline-block;width:14px;height:10px;margin-right:5px;border:3px solid}</style></head><body><main>" +
		"<h1>Find what the words name</h1><p class='sub'>stzImage.FindByWords(words): OWL-ViT run by the engine. A word does not have to be one the object detector was trained on. " +
		"Each tile is one (picture, word) pair of the JUDGING set: the word is the title, the truth (LVIS, drawn by people) is green, what owlvit found is orange. " +
		"The two badges say whether each implementation agreed with the truth. Nothing here was retuned on these pairs.</p>" +
		"<p class='lg'><span><i style='border-color:var(--t)'></i>truth (LVIS)</span><span><i style='border-color:var(--o)'></i>owlvit</span></p><div class='k'>" +
		"<div class='kp'><b>" + nO + " / 320</b><span>pairs owlvit agreed on (the floor, YOLOX by name: " + nF + ")</span></div>" +
		"<div class='kp'><b>" + aTot[3][2] + " / " + aTot[3][3] + "</b><span>words outside COCO's 80 classes found (the floor: " + aTot[3][1] + ")</span></div>" +
		"<div class='kp'><b>" + aTot[1][2] + " / " + aTot[1][3] + "</b><span>words that ARE a COCO class found (the floor: " + aTot[1][1] + ")</span></div>" +
		"<div class='kp'><b>" + aTot[4][2] + " / " + aTot[4][3] + "</b><span>absent words kept empty (" + (aTot[4][3] - aTot[4][2]) + " false alarms)</span></div></div>"
	aTaken = []
	aSets = [ [ "Words outside COCO's 80 classes, found", "B", "pos", "", "1", 6 ], [ "Words outside COCO's 80 classes, MISSED", "B", "pos", "", "0", 4 ],
		[ "A COCO class the floor missed and owlvit found", "A", "pos", "0", "1", 3 ], [ "A word that was absent and owlvit boxed anyway (a false alarm)", "B", "neg", "", "0", 3 ],
		[ "A word that was absent and nothing was drawn", "B", "neg", "", "1", 2 ] ]
	for s = 1 to len(aSets)
		aIdx = Pick(aJ, aSets[s][2], aSets[s][3], aSets[s][4], aSets[s][5], aSets[s][6], aTaken)
		c += "<h2>" + aSets[s][1] + "</h2><div class='g'>"
		for k = 1 to len(aIdx)
			aTaken + aIdx[k]
			c += Tile(cOut, aJ[aIdx[k]], _FindGolden(aGold, aJ[aIdx[k]][1], aJ[aIdx[k]][2]), "")
		next
		c += "</div>"
	next
	c += "<p class='sub'>Limits, stated: boxes under 2% of the picture are not scored; the graph sees 24 x 24 patches, so small objects are out of reach; the engine's JPEG decoder " +
		"differs from libjpeg by up to 2 levels, which moved the cat's score from 0.8217 to 0.8216. No person has looked at this page yet.</p></main></body></html>"
	write(cOut + "/find.html", c)
