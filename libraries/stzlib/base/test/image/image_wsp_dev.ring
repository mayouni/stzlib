# WSP-SPIKE-01: the DEV pairs of _golden/owl_find_v1.tsv through the two new implementations of :find, on a grid fixed here --
# the warm rule (cut on the picture's mean shift, step added to the threshold) and the patched shift head (its threshold).
# The JUDGING pairs are not read. The chosen values are written into stzVision.ring and committed before the judging run.
load "../../stzBase.ring"
decimals(4)
$cImg = "D:/GitHub/_wti_models_src/coco/images/"
aLines = str2list(read("_golden/owl_find_v1.tsv"))
aCut = [ -0.56, -0.58, -0.60, -0.62, -0.64 ]
aStep = [ 0.02, 0.04, 0.07, 0.12 ]
aPThr = [ 0.05, 0.08, 0.10, 0.15 ]
aWarm = []
for ci = 1 to len(aCut)
	aRow = []
	for si = 1 to len(aStep) aRow + [ 0, 0, 0, 0 ] next
	aWarm + aRow
next
aPat = []
for ti = 1 to len(aPThr) aPat + [ 0, 0, 0, 0 ] next
aBase = [ 0, 0, 0, 0 ]
nPairs = 0
cPic = ""
oImg = NULL
aGotP = []
for i = 1 to len(aLines)
	aF = _Tabs(aLines[i])
	if len(aF) < 7  loop ok
	if aF[1] != "dev"  loop ok
	cWord = aF[3]
	bPos = (aF[5] = "pos")
	cBoxes = ""
	if len(aF) >= 8  cBoxes = aF[8] ok
	aBoxes = []
	if len(cBoxes) > 0
		aB = split(cBoxes, ";")
		for k = 1 to len(aB)
			aN = split(aB[k], " ")
			aBoxes + [ number(aN[1]) + 1, number(aN[2]) + 1, number(aN[3]), number(aN[4]) ]
		next
	ok
	aExp = [ :w = number(aF[6]), :h = number(aF[7]), :boxes = aBoxes ]
	if aF[2] != cPic
		if isObject(oImg)  oImg.Release() ok
		cPic = aF[2]
		oImg = StzImageQ($cImg + cPic)
		nMean = _StzVisionOwlHeads(oImg)[:meanShift]
	ok
	# the original weights at the lowest threshold of the grid; the rows are filtered per cell
	aGotO = oImg.FindByWordsXT(cWord, 0.05)
	# the patched weights, the same way (the global swapped for the call; the cached features are per pixels+model path)
	cKeep = $cStzVisionOwlVision
	$cStzVisionOwlVision = $cStzVisionOwlPatched
	aGotP = oImg.FindByWordsXT(cWord, 0.05)
	$cStzVisionOwlVision = cKeep
	nPairs++
	nA = StzFindAgree(_Above(aGotO, 0.08), aExp)
	if bPos  aBase[1] += nA  aBase[2] += 1  else  aBase[3] += nA  aBase[4] += 1  ok
	for ci = 1 to len(aCut)
		for si = 1 to len(aStep)
			nThr = 0.08
			if nMean >= aCut[ci]  nThr += aStep[si] ok
			nA = StzFindAgree(_Above(aGotO, nThr), aExp)
			if bPos  aWarm[ci][si][1] += nA  aWarm[ci][si][2] += 1  else  aWarm[ci][si][3] += nA  aWarm[ci][si][4] += 1  ok
		next
	next
	for ti = 1 to len(aPThr)
		nA = StzFindAgree(_Above(aGotP, aPThr[ti]), aExp)
		if bPos  aPat[ti][1] += nA  aPat[ti][2] += 1  else  aPat[ti][3] += nA  aPat[ti][4] += 1  ok
	next
next
? "dev pairs: " + nPairs
? "owlvit as judged (0.08): positives " + aBase[1] + "/" + aBase[2] + ", negatives " + aBase[3] + "/" + aBase[4] + ", share " + ((aBase[1] + aBase[3]) / (aBase[2] + aBase[4]))
for ci = 1 to len(aCut)
	for si = 1 to len(aStep)
		a = aWarm[ci][si]
		? "warm-rule cut " + aCut[ci] + " step " + aStep[si] + ": positives " + a[1] + "/" + a[2] + ", negatives " + a[3] + "/" + a[4] + ", share " + ((a[1] + a[3]) / (a[2] + a[4]))
	next
next
for ti = 1 to len(aPThr)
	a = aPat[ti]
	? "shift-patch threshold " + aPThr[ti] + ": positives " + a[1] + "/" + a[2] + ", negatives " + a[3] + "/" + a[4] + ", share " + ((a[1] + a[3]) / (a[2] + a[4]))
next
shutdown(0)

func _Above(aRows, nThr)
	aOut = []
	for k = 1 to len(aRows)
		if aRows[k][:score] >= nThr  aOut + aRows[k] ok
	next
	return aOut

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
