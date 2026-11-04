# IM9f: the JUDGING run of :find -- the pairs of _golden/owl_find_v1.tsv marked "judge", each implementation through the library's OWN code path
# (_StzVisionFindFloor, _StzVisionFindOwl) at the thresholds chosen on the DEV pairs and committed before this ran
# (SOFTANZA_IMAGE_INTELLIGENCE.md, IM9f). Run it ONCE. It writes _find-out/judge_pairs.tsv (every pair's verdicts and the boxes found) and prints
# the shares by kind and polarity; the registry rows are recorded by image_find_narrated.ring from what this printed.
load "../../stzBase.ring"
decimals(4)
$cImg = "D:/GitHub/_wti_models_src/coco/images/"
aLines = str2list(read("_golden/owl_find_v1.tsv"))
cOut = ""
aTot = []   # [ kind A pos, A neg, B pos, B neg ] x [ floor agree, owl agree, n ]
for g = 1 to 4  aTot + [ 0, 0, 0 ]  next
nPairs = 0
for i = 1 to len(aLines)
	aF = _Tabs(aLines[i])
	if len(aF) < 7  loop ok
	if aF[1] != "judge"  loop ok
	cPic = aF[2]
	cWord = aF[3]
	cKind = aF[4]
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
	aGotF = _StzVisionFindFloor([ $cImg + cPic, cWord ], [])
	aGotO = _StzVisionFindOwl([ $cImg + cPic, cWord ], [])
	nF = StzFindAgree(aGotF, aExp)
	nO = StzFindAgree(aGotO, aExp)
	g = 1
	if cKind = "B"  g = 3 ok
	if NOT bPos  g += 1 ok
	aTot[g][1] += nF
	aTot[g][2] += nO
	aTot[g][3] += 1
	nPairs++
	cRows = ""
	for k = 1 to len(aGotO)
		r = aGotO[k]
		cRows += "" + r[:box][1] + " " + r[:box][2] + " " + r[:box][3] + " " + r[:box][4] + " " + r[:score] + ";"
	next
	cOut += cPic + char(9) + cWord + char(9) + cKind + char(9) + aF[5] + char(9) + nF + char(9) + nO + char(9) + len(aGotF) + char(9) + cRows + char(10)
next
write("_find-out/judge_pairs.tsv", cOut)
? "judging pairs: " + nPairs
aName = [ "kind A positives (the floor's own words)", "kind A negatives", "kind B positives (words outside COCO's 80)", "kind B negatives" ]
nFa = 0
nOa = 0
for g = 1 to 4
	? aName[g] + ": " + aTot[g][3] + " pairs | floor " + aTot[g][1] + " | owlvit " + aTot[g][2]
	nFa += aTot[g][1]
	nOa += aTot[g][2]
next
? "ALL: floor " + nFa + " of " + nPairs + " = " + (nFa / nPairs) + " | owlvit " + nOa + " of " + nPairs + " = " + (nOa / nPairs)
shutdown(0)

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
