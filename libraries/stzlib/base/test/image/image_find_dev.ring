# IM9f: the DEV pairs of _golden/owl_find_v1.tsv -- the share of pairs that agree at each score threshold of the grid fixed in the rule.
# (The JUDGING pairs are not read here.)
load "../../stzBase.ring"
decimals(4)
$cImg = "D:/GitHub/_wti_models_src/coco/images/"
aLines = str2list(read("D:/GitHub/_wti_pub/libraries/stzlib/base/test/image/_golden/owl_find_v1.tsv"))
aOwlGrid = [ 0.05, 0.08, 0.1, 0.15, 0.2, 0.3 ]
aFloorGrid = [ 0.2, 0.3, 0.4, 0.5 ]
aOwl = []
for g = 1 to len(aOwlGrid)  aOwl + [ 0, 0, 0, 0 ]  next   # [ pos agree, pos n, neg agree, neg n ]
aFl = []
for g = 1 to len(aFloorGrid)  aFl + [ 0, 0, 0, 0 ]  next
nPairs = 0
cPic = ""
oImg = NULL
for i = 1 to len(aLines)
	aF = _Tabs(aLines[i])
	if len(aF) < 7  loop ok
	if aF[1] != "dev"  loop ok
	if aF[2] != cPic
		if isObject(oImg)  oImg.Release() ok
		cPic = aF[2]
		oImg = StzImageQ($cImg + cPic)
	ok
	cWord = aF[3]
	bPos = (aF[5] = "pos")
	aBoxes = []
	cBoxes = ""
	if len(aF) >= 8  cBoxes = aF[8] ok
	if len(cBoxes) > 0
		aB = split(cBoxes, ";")
		for k = 1 to len(aB)
			aN = split(aB[k], " ")
			aBoxes + [ number(aN[1]) + 1, number(aN[2]) + 1, number(aN[3]), number(aN[4]) ]
		next
	ok
	aExp = [ :w = number(aF[6]), :h = number(aF[7]), :boxes = aBoxes ]
	aGotO = oImg.FindByWordsXT(cWord, 0.05)
	aGotF = _FloorRows(oImg, cWord)
	nPairs++
	for g = 1 to len(aOwlGrid)
		aRows = _Above(aGotO, aOwlGrid[g])
		nA = StzFindAgree(aRows, aExp)
		if bPos  aOwl[g][1] += nA  aOwl[g][2] += 1  else  aOwl[g][3] += nA  aOwl[g][4] += 1  ok
	next
	for g = 1 to len(aFloorGrid)
		aRows = _Above(aGotF, aFloorGrid[g])
		nA = StzFindAgree(aRows, aExp)
		if bPos  aFl[g][1] += nA  aFl[g][2] += 1  else  aFl[g][3] += nA  aFl[g][4] += 1  ok
	next
next
? "dev pairs: " + nPairs
for g = 1 to len(aOwlGrid)
	a = aOwl[g]
	? "owlvit threshold " + aOwlGrid[g] + ": positives " + a[1] + "/" + a[2] + ", negatives " + a[3] + "/" + a[4] + ", share " + ((a[1] + a[3]) / (a[2] + a[4]))
next
for g = 1 to len(aFloorGrid)
	a = aFl[g]
	? "floor  threshold " + aFloorGrid[g] + ": positives " + a[1] + "/" + a[2] + ", negatives " + a[3] + "/" + a[4] + ", share " + ((a[1] + a[3]) / (a[2] + a[4]))
next
shutdown(0)

func _Above(aRows, nThr)
	aOut = []
	for k = 1 to len(aRows)
		if aRows[k][:score] >= nThr  aOut + aRows[k] ok
	next
	return aOut

func _FloorRows(oImg, cWord)
	aObj = oImg.ObjectsXT(0.2)
	aOut = []
	for k = 1 to len(aObj)
		cL = lower(aObj[k][:label])
		if cL = cWord or (cL + "s") = cWord
			aOut + [ :query = cWord, :score = aObj[k][:score], :box = aObj[k][:box] ]
		ok
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
