# WSP-SPIKE-01: the JUDGING run of the two new implementations of :find -- the pairs of _golden/owl_find_v1.tsv marked "judge", each through the
# library's OWN code path (_StzVisionFindOwlWarm, _StzVisionFindOwlPatched) at the cut-offs chosen on the DEV pairs and committed before this
# ran (SOFTANZA_WEIGHT_SPACE_GOVERNANCE.md section 6). The incumbent's verdicts on the same pairs are already on record
# (_golden/owl_find_v1_judged.tsv). Run it ONCE. It writes _find-out/judge_wsp.tsv (every pair: the incumbent's, the warm rule's and the
# patch's verdicts, and the boxes the patch found) and prints the shares by kind and polarity.
load "../../stzBase.ring"
decimals(4)
$cImg = "D:/GitHub/_wti_models_src/coco/images/"
aLines = str2list(read("_golden/owl_find_v1.tsv"))
aJ = str2list(read("_golden/owl_find_v1_judged.tsv"))
aOld = []
for i = 1 to len(aJ)
	aF = _Tabs(aJ[i])
	if len(aF) >= 6  aOld + [ aF[1] + "|" + aF[2], aF[6] ] ok
next
cOut = ""
aTot = []   # [ A pos, A neg, B pos, B neg ] x [ incumbent, warm, patch, n ]
for g = 1 to 4  aTot + [ 0, 0, 0, 0 ]  next
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
	nOld = -1
	for k = 1 to len(aOld)
		if aOld[k][1] = cPic + "|" + cWord  nOld = number(aOld[k][2])  exit ok
	next
	aGotW = _StzVisionFindOwlWarm([ $cImg + cPic, cWord ], [])
	aGotP = _StzVisionFindOwlPatched([ $cImg + cPic, cWord ], [])
	nW = StzFindAgree(aGotW, aExp)
	nP = StzFindAgree(aGotP, aExp)
	g = 1
	if cKind = "B"  g = 3 ok
	if NOT bPos  g += 1 ok
	if nOld = 1  aTot[g][1] += 1 ok
	aTot[g][2] += nW
	aTot[g][3] += nP
	aTot[g][4] += 1
	nPairs++
	cRows = ""
	for k = 1 to len(aGotP)
		r = aGotP[k]
		cRows += "" + r[:box][1] + " " + r[:box][2] + " " + r[:box][3] + " " + r[:box][4] + " " + r[:score] + ";"
	next
	cOut += cPic + char(9) + cWord + char(9) + cKind + char(9) + aF[5] + char(9) + nOld + char(9) + nW + char(9) + nP + char(9) + cRows + char(10)
next
write("_find-out/judge_wsp.tsv", cOut)
? "judging pairs: " + nPairs
aName = [ "kind A positives (the floor's own words)", "kind A negatives", "kind B positives (words outside COCO's 80)", "kind B negatives" ]
nI = 0
nWa = 0
nPa = 0
for g = 1 to 4
	? aName[g] + ": " + aTot[g][4] + " pairs | owlvit " + aTot[g][1] + " | warm-rule " + aTot[g][2] + " | shift-patch " + aTot[g][3]
	nI += aTot[g][1]
	nWa += aTot[g][2]
	nPa += aTot[g][3]
next
? "ALL: owlvit " + nI + " of " + nPairs + " = " + (nI / nPairs) + " | warm-rule " + nWa + " = " + (nWa / nPairs) + " | shift-patch " + nPa + " = " + (nPa / nPairs)
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
