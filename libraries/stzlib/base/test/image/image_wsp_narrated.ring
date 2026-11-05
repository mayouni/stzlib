# A WEIGHT EDIT UNDER THE COURT -- WSP-SPIKE-01, narrated
#
# SOFTANZA_WEIGHT_SPACE_GOVERNANCE.md. The paper "Sparks of Weight-Space Programming" showed an LLM editing a model's weights; what it did not
# have is the court such an edit needs. This guard is that court run once more, on record: the engine reads OWL-ViT's weights by name, names
# what is wrong (a warm picture, read off one head before any word is asked), applies ONE op of a closed catalogue to one tensor, proves every
# other tensor untouched, and the edited model is judged under a rule written before the judging set, strictly against the model as it was.
#
#   Scene 1  THE INSTRUMENTS: tensors by name -- names, shapes, values, digests -- and the pattern ladder's rung 0 over a weight-derived field
#            (a listex over the 576 shifts, a matrex over them as a 24 x 24 grid, with their negative siblings)
#   Scene 2  THE HEADS TAP against ONNX Runtime on four pictures, and the warm-picture finding re-read from the engine
#   Scene 3  THE PATCH REPLAYED: remove-direction on c210 into a fresh file; the same digest as the recorded one; 211 of 212 tensors identical;
#            the implementation refuses a file whose digest is not the recorded one
#   Scene 4  THE JUDGING RECORD (judged once, image_wsp_judge.ring): the three shares re-added, the bar applied as written, ten pairs re-run live
#   Scene 5  the registry and the court: the measurements, then the court's reading of the same record (section 8) -- the one-pair
#            win is refused, the incumbent holds, and the faculty answers through it
#   Scene 6  what a person looks at: the shift field as a heat map over the photograph, what the patch removed and what it lost
#
# NEEDS the engine built with WSP-SPIKE-01, models/vision/owlvit_* and owlvit_vision_shiftpatch.gguf (models/MODELS.md), and the COCO pictures.
# HELPERS LIVE AFTER pf().

load "../../stzBase.ring"

$nPass = 0
$nFail = 0
$nSec = clock()
$cCoco = "D:/GitHub/_wti_models_src/coco/images/"
decimals(6)

if NOT StzVisionHasModel($cStzVisionOwlVision) or NOT StzVisionHasModel($cStzVisionOwlPatched) or NOT fexists($cCoco + "000000012576.jpg")
	? "NOT RUN: the OWL-ViT model files (original and patched) in " + StzVisionModelsDir() + " or the COCO pictures in " + $cCoco
	shutdown(0)
ok
$cV = StzVisionModelPath($cStzVisionOwlVision)
$cP = StzVisionModelPath($cStzVisionOwlPatched)
cOut = StzReplace(WorkingDirectory(), "\", "/") + "/_find-out"
if NOT StzDirExists(cOut)
	StzDirCreatePath(cOut)
ok

? "-- Scene 1: the instruments, and rung 0 over a weight-derived field --"
aNames = StzEngineNeuralTensorNames($cV)
chk("the vision graph holds 212 tensors, named c0 .. c211 in file order", len(aNames) = 212 and aNames[1] = "c0" and aNames[212] = "c211")
aI = StzEngineNeuralTensorInfo($cV, "c210")
chk("c210, the logit_shift head, is one column of 768 F32 values: " + @@(aI), len(aI) = 7 and aI[1] = 1 and aI[2] = 768 and aI[6] = 0 and aI[7] = 768)
aI8 = StzEngineNeuralTensorInfo($cV, "c208")
chk("c208, the class head, is 512 columns of 768: rank 2, 393,216 values", aI8[1] = 2 and aI8[2] = 768 and aI8[3] = 512 and aI8[7] = 393216)
chk("a tensor that does not exist gives [] and the error names it", len(StzEngineNeuralTensorInfo($cV, "c999")) = 0 and len(StzFind("c999", StzEngineNeuralOcrGraphError())) > 0)
aW = StzEngineNeuralTensorSlice($cV, "c210", 0, 768)
nNorm = _Norm(aW)
? "      |w| of the shift head: " + nNorm + " (owl_direction.py read 0.5966 through ONNX)"
chk("the head's 768 values read by the engine have the norm the independent reader found (0.5966, within 0.001)", len(aW) = 768 and _Abs(nNorm - 0.5966) < 0.001)
cD1 = StzEngineNeuralTensorDigest($cV, "c210")
chk("a tensor's digest is 64 hex characters and is the same on a second read", len(cD1) = 64 and cD1 = StzEngineNeuralTensorDigest($cV, "c210"))
chk("two different tensors do not share a digest", cD1 != StzEngineNeuralTensorDigest($cV, "c211"))
oWarm = StzImageRawQ($cCoco + "000000012576.jpg")
aH = _StzVisionOwlHeads(oWarm)
aS = aH[:shifts]
chk("rung 0, listex: the 576 shifts of a picture match [@N576] -- a list of exactly 576 numbers", Lx("[@N576]").Match(aS) = 1 and Lx("[@N575]").Match(aS) = 0)
aGrid = _Grid24(aS)
oMx = new stzMatrex("{size(24x24) & element(-2..0)}")
oMxNot = new stzMatrex("{size(24x24) & element(0..1)}")
chk("rung 0, matrex: the same field as a 24 x 24 grid matches {size(24x24) & element(-2..0)} (the field reads -1.39 .. -0.41) and not {element(0..1)}, its negative sibling", oMx.Match(aGrid) = 1 and oMxNot.Match(aGrid) = 0)
sec("scene 1")

? "-- Scene 2: the heads tap against ONNX Runtime, and the warm picture --"
aRef = [ [ "000000012576.jpg", -0.5344 ], [ "000000000139.jpg", -0.5752 ], [ "000000013004.jpg", -0.6264 ], [ "000000001675.jpg", -0.7261 ] ]
aMeans = []
for i = 1 to len(aRef)
	oI = StzImageRawQ($cCoco + aRef[i][1])
	aHi = _StzVisionOwlHeads(oI)
	aMeans + aHi[:meanShift]
	? "      " + aRef[i][1] + ": mean shift " + aHi[:meanShift] + " (ONNX Runtime " + aRef[i][2] + "), mean scale " + _Mean(aHi[:scales])
	chk(aRef[i][1] + ": the engine's mean shift is ONNX Runtime's within 0.005 (the JPEG decoders differ by up to 2 levels; the banana picture moves 0.0038, the others under 0.0005)", _Abs(aHi[:meanShift] - aRef[i][2]) < 0.005)
	oI.Release()
next
chk("the pizza picture (two false alarms) is the warmest of the four and the cat picture the coldest, 0.19 apart", aMeans[1] > aMeans[2] and aMeans[2] > aMeans[3] and aMeans[3] > aMeans[4] and aMeans[1] - aMeans[4] > 0.15)
chk("the warm rule's cut (" + $nStzVisionWarmShift + ") puts the pizza and the room above it and the banana and the cat below it", aMeans[1] >= $nStzVisionWarmShift and aMeans[2] >= $nStzVisionWarmShift and aMeans[3] < $nStzVisionWarmShift and aMeans[4] < $nStzVisionWarmShift)
chk("every shift is a bias toward answering: all 576 are negative on the warmest picture (-1.39 .. -0.41)", _Min(aS) > -2 and _Max(aS) < 0)
oWarm.Release()
sec("scene 2")

? "-- Scene 3: the patch replayed, and its negative sibling --"
cReplay = cOut + "/replay_shiftpatch.gguf"
if fexists(cReplay) remove(cReplay) ok
cDir = read("_golden/owl_shift_direction.txt")
aR = StzEngineNeuralPatchRemoveDirection($cV, cReplay, "c210", 0, 1, cDir)
? "      remove-direction: " + @@(aR)
chk("remove-direction changed 768 values of one column, and w . d is the 0.0603 the direction's report states", len(aR) = 4 and aR[1] = 768 and aR[2] = 1 and _Abs(aR[3] - 0.0603) < 0.0005)
chk("the replayed file has EXACTLY the recorded digest of the patched model: the patch is deterministic and replayable", StzEngineModelDigest(cReplay) = $cStzVisionOwlPatchedSha256)
nSame = 0
aChanged = []
for i = 1 to len(aNames)
	if StzEngineNeuralTensorDigest($cV, aNames[i]) = StzEngineNeuralTensorDigest(cReplay, aNames[i])
		nSame++
	else
		aChanged + aNames[i]
	ok
next
chk("THE NEGATIVE SIBLING: 211 of 212 tensors digest the same, and the one that changed is c210 and nothing else", nSame = 211 and len(aChanged) = 1 and aChanged[1] = "c210")
aW2 = StzEngineNeuralTensorSlice(cReplay, "c210", 0, 768)
chk("the patched head's norm is sqrt(|w|^2 - (w.d)^2) = 0.5936, within 0.001: the direction was removed and nothing else moved", _Abs(_Norm(aW2) - 0.5936) < 0.001)
chk("the direction is still in the ORIGINAL head: w . d = 0.0603 before, 0 after (within 1e-4)", _Abs(_Dot(aW, _Numbers(cDir)) - 0.0603) < 0.0005 and _Abs(_Dot(aW2, _Numbers(cDir))) < 0.0001)
chk("remove-direction refuses a direction of the wrong length and names the lengths", len(StzEngineNeuralPatchRemoveDirection($cV, cOut + "/bad.gguf", "c210", 0, 1, "1 2 3")) = 0 and len(StzFind("768", StzEngineNeuralOcrGraphError())) > 0)
chk("remove-direction refuses columns outside the tensor", len(StzEngineNeuralPatchRemoveDirection($cV, cOut + "/bad.gguf", "c210", 1, 1, cDir)) = 0)
cKeep = $cStzVisionOwlPatched
$cStzVisionOwlPatched = $cStzVisionOwlVision
cErr = ""
try
	_StzVisionFindOwlPatched([ $cCoco + "000000001675.jpg", "cat" ], [])
catch
	cErr = cCatchError
done
$cStzVisionOwlPatched = cKeep
chk("the patched implementation REFUSES a file whose digest is not the recorded one, and names the digest", len(StzFind($cStzVisionOwlPatchedSha256, cErr)) > 0)
remove(cReplay)
sec("scene 3")

? "-- Scene 4: the judging record (judged once, image_wsp_judge.ring) --"
aJ = _ReadTsv("_golden/owl_wsp_judged.tsv")
aTot = []
for g = 1 to 4  aTot + [ 0, 0, 0, 0 ]  next
nChangedP = 0
nGainP = 0
nLostP = 0
nChangedW = 0
for i = 1 to len(aJ)
	g = 1
	if aJ[i][3] = "B"  g = 3 ok
	if aJ[i][4] = "neg"  g += 1 ok
	aTot[g][1] += number(aJ[i][5])
	aTot[g][2] += number(aJ[i][6])
	aTot[g][3] += number(aJ[i][7])
	aTot[g][4] += 1
	if aJ[i][5] != aJ[i][7]
		nChangedP++
		if aJ[i][7] = "1"  nGainP++  else  nLostP++  ok
	ok
	if aJ[i][5] != aJ[i][6]  nChangedW++ ok
next
nI = aTot[1][1] + aTot[2][1] + aTot[3][1] + aTot[4][1]
nW = aTot[1][2] + aTot[2][2] + aTot[3][2] + aTot[4][2]
nP = aTot[1][3] + aTot[2][3] + aTot[3][3] + aTot[4][3]
? "      incumbent " + nI + " | warm-rule " + nW + " | shift-patch " + nP + " of " + len(aJ) + " | the patch changed " + nChangedP + " pairs (" + nGainP + " gained, " + nLostP + " lost), the warm rule " + nChangedW
chk("320 pairs on record, the incumbent at 252 as IM9f recorded it", len(aJ) = 320 and nI = 252)
chk("THE BAR, as written: the warm rule is EQUAL (252), not strictly above -- refused", nW = 252 and NOT (nW > nI))
chk("THE BAR, as written: the patched head is strictly above (253) -- chosen", nP = 253 and nP > nI)
chk("the margin is ONE pair out of a reshuffle of 19 (10 gained, 9 lost): recorded as noise-level, not as evidence", nChangedP = 19 and nGainP = 10 and nLostP = 9 and nP - nI = 1)
chk("six of the nine false alarms are gone (kind B negatives 142 -> 148) and the price was positives, mostly the floor's own words (kind A 34 -> 30)", aTot[4][1] = 142 and aTot[4][3] = 148 and aTot[1][1] = 34 and aTot[1][3] = 30)
aGold = _ReadTsv("_golden/owl_find_v1.tsv")
nLive = 0
nLiveOk = 0
for i = 16 to len(aJ) step 32
	aG = _FindGolden(aGold, aJ[i][1], aJ[i][2])
	if len(aG) = 0  loop ok
	aExp = [ :w = number(aG[6]), :h = number(aG[7]), :boxes = _BoxesOf(aG) ]
	aGot = _StzVisionFindOwlPatched([ $cCoco + aJ[i][1], aJ[i][2] ], [])
	nLive++
	if StzFindAgree(aGot, aExp) = number(aJ[i][7])  nLiveOk++ ok
next
chk("ten judged pairs re-run live through the patched implementation give the verdicts stored when they were judged: " + nLiveOk + " of " + nLive, nLive = 10 and nLiveOk = 10)
sec("scene 4")

? "-- Scene 5: the registry --"
chk("the measurements shipped with the library hold all three implementations and the floor of :find", len(StzMeasurementOf("find", "owlvit", "find-v1")) > 0 and len(StzMeasurementOf("find", "owlvit+warm-rule", "find-v1")) > 0 and len(StzMeasurementOf("find", "owlvit+shift-patch", "find-v1")) > 0 and len(StzMeasurementOf("find", "yolox-by-name", "find-v1")) > 0)
oPlan = StzModelRegistryQ().ResolveQ(StzRequirementQ("find"))
cChosen = oPlan.Chosen()
aCourt = StzCourtVerdictOf("find", "find-v1", "owlvit+shift-patch", "owlvit")
? "      the court on find-v1: shift-patch over owlvit " + aCourt[:gains] + " gains, " + aCourt[:losses] + " losses, P = " + aCourt[:p] + " -> " + aCourt[:verdict]
chk("THE COURT (section 8) reads the same record: the patch's 10 gains against 9 losses give P = 0.5 and it is REFUSED", aCourt[:gains] = 10 and aCourt[:losses] = 9 and _Abs(aCourt[:p] - 0.5) < 0.000001 and aCourt[:verdict] = "refused")
chk("the registry resolves :find to '" + cChosen + "': the incumbent holds, because the burden is on the change", cChosen = "owlvit")
chk("and its Why names the court's refusal of the patch with its evidence", len(StzFind("the court REFUSED it against 'owlvit'", oPlan.Why())) > 0 and len(StzFind("P = 0.5", oPlan.Why())) > 0)
oF = StzRunFaculty("find", [ $cCoco + "000000001675.jpg", "cat" ], [], [], [], 0)
? "      the faculty on 'cat': " + @@(oF.Provenance()) + " " + oF.CiteFindings()
chk("StzRunFaculty(:find) answers through owlvit and its provenance says so", oF.IsRefusal() = 0 and len(oF.Value()) >= 1 and oF.Value()[1][:query] = "cat" and len(StzFind("owlvit", @@(oF.Provenance()))) > 0 and len(StzFind("shift-patch", @@(oF.Provenance()))) = 0)
sec("scene 5")

? "-- Scene 6: what a person looks at --"
WritePage(cOut, aJ, aGold, aRef, aMeans, nI, nW, nP)
chk("the page is written", fexists(cOut + "/find_wsp.html"))
sec("scene 6")

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

func _Norm(aV)
	n = 0
	for i = 1 to len(aV) n += aV[i] * aV[i] next
	return sqrt(n)

func _Dot(aA, aB)
	n = 0
	m = len(aA)
	if len(aB) < m  m = len(aB) ok
	for i = 1 to m n += aA[i] * aB[i] next
	return n

func _Mean(aV)
	if len(aV) = 0  return 0 ok
	n = 0
	for i = 1 to len(aV) n += aV[i] next
	return n / len(aV)

func _Min(aV)
	n = aV[1]
	for i = 2 to len(aV) if aV[i] < n  n = aV[i] ok next
	return n

func _Max(aV)
	n = aV[1]
	for i = 2 to len(aV) if aV[i] > n  n = aV[i] ok next
	return n

# the numbers of a text separated by spaces or newlines
func _Numbers(cText)
	aOut = []
	aP = split(StzReplace(StzReplace(cText, char(13), " "), char(10), " "), " ")
	for i = 1 to len(aP)
		if len(trim(aP[i])) > 0  aOut + number(trim(aP[i])) ok
	next
	return aOut

func _Grid24(aS)
	aG = []
	for r = 1 to 24
		aRow = []
		for cc = 1 to 24 aRow + aS[(r - 1) * 24 + cc] next
		aG + aRow
	next
	return aG

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

func _FindGolden(aGold, cPic, cWord)
	for i = 1 to len(aGold)
		if aGold[i][2] = cPic and aGold[i][3] = cWord and aGold[i][1] = "judge"  return aGold[i] ok
	next
	return []

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

# the boxes of a judged row's last column: "x y w h score;" ...
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

# a picture with its shift field as a 24 x 24 heat map (opacity by shift, over a common scale)
func HeatTile(cOut, cPic, aShifts, nMean, nLo, nHi, cNote)
	oI = StzImageQ($cCoco + cPic)
	nW = oI.Width()
	nH = oI.Height()
	oI.SaveAsJpeg(cOut + "/" + cPic, 85)
	oI.Release()
	cSvg = "<svg viewBox='0 0 24 24' preserveAspectRatio='none' xmlns='http://www.w3.org/2000/svg'>"
	for p = 1 to 576
		nA = (aShifts[p] - nLo) / (nHi - nLo)
		if nA < 0  nA = 0 ok
		if nA > 1  nA = 1 ok
		cSvg += "<rect x='" + ((p - 1) % 24) + "' y='" + floor((p - 1) / 24) + "' width='1' height='1' fill='#e8710a' fill-opacity='" + (0.85 * nA) + "'/>"
	next
	cSvg += "</svg>"
	return "<div class='c'><div class='im'><img src='" + cPic + "' alt='" + cPic + "'>" + cSvg + "</div><p><b>mean shift " + nMean + "</b> - " + cNote + "</p></div>"

# a pair: the truth (green), what the incumbent drew (orange), what the patch drew (blue)
func PairTile(cOut, aJ, aG, aOldRows, cNote)
	cPic = aJ[1]
	oI = StzImageQ($cCoco + cPic)
	nW = oI.Width()
	nH = oI.Height()
	oI.SaveAsJpeg(cOut + "/" + cPic, 85)
	oI.Release()
	nStroke = nW / 150
	cSvg = "<svg viewBox='0 0 " + nW + " " + nH + "' xmlns='http://www.w3.org/2000/svg'>"
	aT = _BoxesOf(aG)
	for k = 1 to len(aT) cSvg += Rect(aT[k], "t", nStroke) next
	for k = 1 to len(aOldRows) cSvg += Rect(aOldRows[k], "o", nStroke) next
	aP = _JudgedBoxes(aJ[8])
	for k = 1 to len(aP) cSvg += Rect(aP[k], "p", nStroke) next
	cSvg += "</svg>"
	cI = "bad"
	if aJ[5] = "1"  cI = "ok" ok
	cPz = "bad"
	if aJ[7] = "1"  cPz = "ok" ok
	cTruth = "absent (LVIS verified it)"
	if aJ[4] = "pos"  cTruth = "present: " + len(aT) + " box(es)" ok
	return "<div class='c'><div class='im'><img src='" + cPic + "' alt='" + aJ[2] + "'>" + cSvg + "</div><p><b>" + aJ[2] + "</b> - " + cTruth + "</p><p><span class='b " + cI + "'>as it was " + cI + "</span><span class='b " + cPz + "'>patched " + cPz + "</span> " + cNote + "</p></div>"

func WritePage(cOut, aJ, aGold, aRef, aMeans, nI, nW, nP)
	aOldJ = _ReadTsv("_golden/owl_find_v1_judged.tsv")
	# one FIXED band for the four pictures, -0.85 .. -0.45: a patch at or below -0.85 is clear, one at -0.45 or above is full orange, so the
	# cold picture reads pale and the warm one dark (the full range, -1.39 .. -0.41, saturates every picture: measured on the first render)
	nLo = -0.85
	nHi = -0.45
	aFields = []
	for i = 1 to len(aRef)
		oI = StzImageRawQ($cCoco + aRef[i][1])
		aHi = _StzVisionOwlHeads(oI)
		oI.Release()
		aFields + aHi[:shifts]
	next
	c = "<!doctype html><html lang='en'><head><meta charset='utf-8'><meta name='viewport' content='width=device-width,initial-scale=1'>" +
		"<title>A weight edit under the court</title><style>" +
		":root{--bg:#fff;--fg:#1c1c1e;--mut:#6b6b70;--line:#d8d8dc;--ok:#1a7f37;--bad:#b3261e;--card:#f6f6f8;--t:#1a9850;--o:#e8710a;--p:#2a6fdb}" +
		"@media (prefers-color-scheme:dark){:root{--bg:#161618;--fg:#ececf0;--mut:#9a9aa2;--line:#3a3a40;--ok:#4cc26a;--bad:#f28b82;--card:#202024;--t:#5fd38a;--o:#ffa04d;--p:#7aa7ff}}" +
		"body{margin:0;background:var(--bg);color:var(--fg);font:16px/1.5 system-ui,Segoe UI,sans-serif}main{max-width:1100px;margin:0 auto;padding:16px}" +
		"h1{font-size:1.5rem;margin:.3em 0}h2{font-size:1.1rem;margin:1.5em 0 .3em}p.sub{color:var(--mut)}" +
		".k{display:grid;grid-template-columns:repeat(auto-fit,minmax(210px,1fr));gap:12px;margin:1em 0}.kp{background:var(--card);border-radius:8px;padding:10px 14px}" +
		".kp b{display:block;font-size:1.4rem}.kp span{color:var(--mut);font-size:.88rem}.miss b{color:var(--bad)}" +
		".g{display:grid;grid-template-columns:repeat(auto-fill,minmax(300px,1fr));gap:12px}.c{border:1px solid var(--line);border-radius:8px;padding:8px}" +
		".im{position:relative}.im img{width:100%;height:auto;display:block}.im svg{position:absolute;left:0;top:0;width:100%;height:100%}" +
		".t{stroke:var(--t)}.o{stroke:var(--o);stroke-dasharray:6 4}.p{stroke:var(--p)}.c p{margin:.3em 0 0;font-size:.85rem;color:var(--mut)}.c p b{color:var(--fg)}" +
		".b{display:inline-block;border-radius:4px;padding:1px 7px;margin:2px 4px 0 0;font-size:.78rem}.ok{background:#1a7f3722;color:var(--ok)}.bad{background:#b3261e22;color:var(--bad)}" +
		".lg span{display:inline-block;margin-right:14px}.lg i{display:inline-block;width:14px;height:10px;margin-right:5px;border:3px solid}</style></head><body><main>" +
		"<h1>A weight edit under the court</h1><p class='sub'>OWL-ViT's nine false alarms were WARM PICTURES: one head of the model (logit_shift, 768 numbers) gives every patch a bias toward " +
		"answering any word, and the mean of that bias over the 576 patches ranked every judging picture, all nine false alarms in the warmer half. The engine removed the warm direction from " +
		"that one head (768 values changed, 211 of 212 tensors proven untouched by digest) and the patched model was judged once against the model as it was, under a rule written first.</p>" +
		"<div class='k'><div class='kp'><b>" + nI + " / 320</b><span>the model as it was</span></div><div class='kp'><b>" + nW + " / 320</b><span>the warm rule (threshold up on warm pictures): equal, REFUSED</span></div>" +
		"<div class='kp'><b>" + nP + " / 320</b><span>the patched head: above by ONE pair, chosen by the rule as written</span></div>" +
		"<div class='kp miss'><b>19 pairs</b><span>reshuffled by the patch (10 gained, 9 lost): a one-pair margin is noise, and the record says so</span></div></div>" +
		"<h2>The shift field, read before any word is asked</h2><p class='sub'>Each cell is one of the 576 patches; the darker the orange, the higher its bias toward answering. One band for the four pictures: clear at a shift of -0.85 or below, full orange at -0.45 or above.</p><div class='g'>"
	aNote = [ "the pizza table: two false alarms (tinfoil, turtle)", "the room: cabinets, a fireplace, televisions", "the banana: two false alarms (pancake, tonic)", "the cat on the laptop: the coldest" ]
	for i = 1 to len(aRef)
		c += HeatTile(cOut, aRef[i][1], aFields[i], aMeans[i], nLo, nHi, aNote[i])
	next
	c += "</div><p class='lg'><span><i style='border-color:var(--t)'></i>truth (LVIS)</span><span><i style='border-color:var(--o);border-style:dashed'></i>the model as it was</span><span><i style='border-color:var(--p)'></i>the patched head</span></p>"
	c += "<h2>False alarms the patch removed (absent words; the dashed box is what the model drew before)</h2><div class='g'>"
	for i = 1 to len(aJ)
		if aJ[i][4] = "neg" and aJ[i][5] = "0" and aJ[i][7] = "1"
			c += PairTile(cOut, aJ[i], _FindGolden(aGold, aJ[i][1], aJ[i][2]), _OldRows(aOldJ, aJ[i][1], aJ[i][2]), "")
		ok
	next
	c += "</div><h2>Positives the patch lost (present words it no longer finds well enough)</h2><div class='g'>"
	for i = 1 to len(aJ)
		if aJ[i][4] = "pos" and aJ[i][5] = "1" and aJ[i][7] = "0"
			c += PairTile(cOut, aJ[i], _FindGolden(aGold, aJ[i][1], aJ[i][2]), _OldRows(aOldJ, aJ[i][1], aJ[i][2]), "")
		ok
	next
	c += "</div><h2>Positives the patch gained</h2><div class='g'>"
	for i = 1 to len(aJ)
		if aJ[i][4] = "pos" and aJ[i][5] = "0" and aJ[i][7] = "1"
			c += PairTile(cOut, aJ[i], _FindGolden(aGold, aJ[i][1], aJ[i][2]), _OldRows(aOldJ, aJ[i][1], aJ[i][2]), "")
		ok
	next
	c += "</div><p class='sub'>Limits, stated: the direction was found on the DEV pictures, where the patch read 0.8235; on the judging pairs it read 0.7906 -- the drop is the in-sample bias, measured. " +
		"A bias head cannot tell a present object from an absent one, so the false alarms it removed were paid for in positives. No person has looked at this page yet.</p></main></body></html>"
	write(cOut + "/find_wsp.html", c)

func _OldRows(aOldJ, cPic, cWord)
	for i = 1 to len(aOldJ)
		if aOldJ[i][1] = cPic and aOldJ[i][2] = cWord  return _JudgedBoxes(aOldJ[i][8]) ok
	next
	return []
