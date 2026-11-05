# WSP: the FRESH judging run of :find (find-v2) under the margin rule -- SOFTANZA_WEIGHT_SPACE_GOVERNANCE.md section 8, committed before the
# pictures existed on this machine. Every pair of _golden/owl_find_v2.tsv through the library's OWN code path for the four implementations, at
# the cut-offs and the patched file committed in f7d102526 (nothing is tuned here). Run it ONCE. It writes, in _find-out/:
#   judge_v2.tsv      every pair: picture, word, kind, pos|neg, then the verdict (1|0) of floor, owlvit, warm-rule, shift-patch
#   zmdl_v2.txt       the four measurement rows (score = share of pairs that agree)
#   court_v2.txt      the court's evidence for every ordered pair of implementations: the gains and losses among the discordant pairs
#   court_v1.txt      the same evidence read from the find-v1 record (owl_find_v1_judged.tsv, owl_wsp_judged.tsv): what the margin rule says of it
# The verdicts are not written by this script: the registry derives them from the counts (StzLoadCourt).
load "../../stzBase.ring"
decimals(6)
$cImg = "D:/GitHub/_wti_models_src/coco/images/"
$aImpl = [ "yolox-by-name", "owlvit", "owlvit+warm-rule", "owlvit+shift-patch" ]
aLines = str2list(read("_golden/owl_find_v2.tsv"))
aRows = []
for i = 1 to len(aLines)
	aF = _Tabs(aLines[i])
	if len(aF) >= 7 and aF[1] = "judge2"  aRows + aF ok
next
? "fresh pairs: " + len(aRows)
nMissing = 0
for i = 1 to len(aRows)
	if NOT fexists($cImg + aRows[i][2])  nMissing++ ok
next
if nMissing > 0
	? "NOT RUN: " + nMissing + " picture(s) of the fresh set are not in " + $cImg
	shutdown(1)
ok
# picture-major: one picture, then each implementation over its pairs, so the engine runs each model's graph once per picture
aV = []     # per pair: [ floor, owlvit, warm, patch ]
for i = 1 to len(aRows)  aV + [ 0, 0, 0, 0 ]  next
t0 = clock()
i = 1
nPics = 0
while i <= len(aRows)
	# (Ring evaluates both sides of an `and`: the bound is checked before the row is read)
	j = i
	bMore = 1
	while bMore = 1
		bMore = 0
		if j + 1 <= len(aRows)
			if aRows[j + 1][2] = aRows[i][2]  j++  bMore = 1 ok
		ok
	end
	cPath = $cImg + aRows[i][2]
	for m = 1 to 4
		for k = i to j
			aExp = [ :w = number(aRows[k][6]), :h = number(aRows[k][7]), :boxes = _BoxesOf(aRows[k]) ]
			aIn = [ cPath, aRows[k][3] ]
			if m = 1  aGot = _StzVisionFindFloor(aIn, []) ok
			if m = 2  aGot = _StzVisionFindOwl(aIn, []) ok
			if m = 3  aGot = _StzVisionFindOwlWarm(aIn, []) ok
			if m = 4  aGot = _StzVisionFindOwlPatched(aIn, []) ok
			aV[k][m] = StzFindAgree(aGot, aExp)
		next
	next
	nPics++
	if nPics % 25 = 0  ? "  " + nPics + " pictures, " + floor((clock() - t0) / clockspersecond()) + " s" ok
	i = j + 1
end
cOut = ""
for k = 1 to len(aRows)
	cOut += aRows[k][2] + char(9) + aRows[k][3] + char(9) + aRows[k][4] + char(9) + aRows[k][5] + char(9) +
		aV[k][1] + char(9) + aV[k][2] + char(9) + aV[k][3] + char(9) + aV[k][4] + char(10)
next
write("_find-out/judge_v2.tsv", cOut)
n = len(aRows)
aSum = [ 0, 0, 0, 0 ]
for k = 1 to n
	for m = 1 to 4  aSum[m] += aV[k][m]  next
next
cZ = ""
for m = 1 to 4
	? $aImpl[m] + ": " + aSum[m] + " of " + n + " = " + (aSum[m] / n) + _ByKind(aRows, aV, m)
	cZ += "find|" + $aImpl[m] + "|find-v2|" + (aSum[m] / n) + "|" + n + "|1" + char(10)
next
write("_find-out/zmdl_v2.txt", cZ)
write("_find-out/court_v2.txt", _Court("find-v2", aV, n))
# the find-v1 evidence, read from the record: floor and owlvit from owl_find_v1_judged.tsv, warm and patch from owl_wsp_judged.tsv
aJ1 = _ReadTsv("_golden/owl_find_v1_judged.tsv")
aJ2 = _ReadTsv("_golden/owl_wsp_judged.tsv")
aV1 = []
for k = 1 to len(aJ1)
	nW = -1
	nP = -1
	for q = 1 to len(aJ2)
		if aJ2[q][1] = aJ1[k][1] and aJ2[q][2] = aJ1[k][2]  nW = number(aJ2[q][6])  nP = number(aJ2[q][7])  exit ok
	next
	if nW >= 0  aV1 + [ number(aJ1[k][5]), number(aJ1[k][6]), nW, nP ] ok
next
write("_find-out/court_v1.txt", _Court("find-v1", aV1, len(aV1)))
? "court evidence written for find-v2 (" + n + " pairs) and find-v1 (" + len(aV1) + " pairs)"
? "graph time " + floor((clock() - t0) / clockspersecond()) + " s for " + nPics + " pictures"
shutdown(0)

# every ordered pair of implementations: the challenger's gains (it agrees, the other does not) and losses (the reverse)
func _Court(cGolden, aV, n)
	c = ""
	for a = 1 to 4
		for b = 1 to 4
			if a = b  loop ok
			nG = 0
			nL = 0
			for k = 1 to n
				if aV[k][a] = 1 and aV[k][b] = 0  nG++ ok
				if aV[k][a] = 0 and aV[k][b] = 1  nL++ ok
			next
			c += "find|" + cGolden + "|" + $aImpl[a] + "|" + $aImpl[b] + "|" + nG + "|" + nL + char(10)
		next
	next
	return c

func _ByKind(aRows, aV, m)
	aT = [ [ 0, 0 ], [ 0, 0 ], [ 0, 0 ], [ 0, 0 ] ]
	for k = 1 to len(aRows)
		g = 1
		if aRows[k][4] = "B"  g = 3 ok
		if aRows[k][5] = "neg"  g += 1 ok
		aT[g][1] += aV[k][m]
		aT[g][2] += 1
	next
	return " | A pos " + aT[1][1] + "/" + aT[1][2] + ", A neg " + aT[2][1] + "/" + aT[2][2] + ", B pos " + aT[3][1] + "/" + aT[3][2] + ", B neg " + aT[4][1] + "/" + aT[4][2]

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
	aL = str2list(read(cPath))
	aOut = []
	for i = 1 to len(aL)
		if len(aL[i]) > 0  aOut + _Tabs(aL[i]) ok
	next
	return aOut
