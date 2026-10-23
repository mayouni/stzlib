# _measure_letterhead.ring -- score one implementation of the :letterhead faculty on a slice of its golden set,
# or record the summed result.
#
#     ring _measure_letterhead.ring <golden tsv> <impl id> <from> <to>          prints  SLICE <impl> ok=<n> n=<n>
#     ring _measure_letterhead.ring <golden tsv> <impl id> record <ok> <n>      records it in results/letterhead.zmdl.txt
#
# A slow model is run in slices that each fit one run; the slices add up exactly (each item scores 1 or 0).

load "../../stzBase.ring"

cGold = sysargv[3]
cImpl = sysargv[4]
cStore = "results/letterhead.zmdl.txt"
StzLoadMeasurements(cStore)
oF = StzPdfDeclareLetterhead(_LoadGolden(cGold))

if sysargv[5] = "record"
	nOk = 0 + sysargv[6]
	nN = 0 + sysargv[7]
	StzRecordMeasurement("letterhead", cImpl, "v7", nOk / nN, nN, 1, "golden from golden_v7 furniture lists")
	StzSaveMeasurements(cStore)
	? "RECORDED " + cImpl + " " + (nOk / nN)
	bye
ok

nFrom = 0 + sysargv[5]
nTo = 0 + sysargv[6]
nRow = _StzFacultyRow("letterhead")
aG = $aStzFaculties[nRow][:golden]
if nTo > len(aG) nTo = len(aG) ok
aSlice = []
for i = nFrom to nTo
	add(aSlice, aG[i])
next
$aStzFaculties[nRow][:golden] = aSlice
aS = StzScoreImplementation("letterhead", cImpl, [])
? "SLICE " + cImpl + " ok=" + (aS[:score] * aS[:n]) + " n=" + aS[:n] + " of " + len(aG)

func _LoadGolden(cPath)
	aRes = []
	aL = StzSplit(read(cPath), char(10))
	for k = 1 to len(aL)
		aP = StzSplit(aL[k], char(9))
		if len(aP) < 7 loop ok
		cText = StzReplace(StzReplace(StzReplace(aP[2], "\n", char(10)), "\t", char(9)), "\\", "\")
		bL = 0
		if aP[4] = "1" bL = 1 ok
		aRes + [ [ :text = cText, :ratio = 0 + aP[3], :largest = bL, :rank = 0 + aP[5], :reader = trim(aP[6]) ], trim(aP[7]) ]
	next
	return aRes
