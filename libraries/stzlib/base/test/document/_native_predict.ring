# _native_predict.ring -- run Softanza's native PDF reader on the golden set and write its predictions.
#
#     ring _native_predict.ring <golden dir> <predictions dir>
#     python -I _doc_score.py <golden dir> <predictions dir> native <results dir>
#
# One <id>.native.tsv per document in the shared prediction format (_doc_score.py), and native.times.tsv:
# the seconds each document took, measured around StzPdfQ() -- the engine's read and layout plus the bridge.

load "../../stzBase.ring"
decimals(4)

#     ring _native_predict.ring many <out root> <golden dir> [<golden dir> ...]
#         reads several sets in one process (the library loads once); predictions go to <out root>/<set name>/

if sysargv[3] = "many"
	cRoot = sysargv[4]
	for g = 5 to len(sysargv)
		cG = sysargv[g]
		aParts = StzSplit(StzReplace(cG, "\", "/"), "/")
		cSet = aParts[len(aParts)]
		_PredictSet(cG, cRoot + "/" + cSet)
	next
else
	_PredictSet(sysargv[3], sysargv[4])
ok

func _PredictSet(cGolden, cOut)
if NOT direxists(cOut) system("mkdir " + StzReplace(cOut, "/", "\")) ok

aFiles = dir(cGolden)
cTimes = ""
for i = 1 to len(aFiles)
	cName = aFiles[i][1]
	if right(lower(cName), 4) != ".pdf" loop ok
	cId = left(cName, len(cName) - 4)
	t0 = StzEngineWatchTimestampMs()
	oPdf = StzPdfQ(cGolden + "/" + cName)
	nSec = (StzEngineWatchTimestampMs() - t0) / 1000
	aB = oPdf.Blocks()
	cTsv = ""
	for j = 1 to len(aB)
		if aB[j][:kind] = "table"
			cRows = ""
			for r = 1 to len(aB[j][:rows])
				if r > 1 cRows += char(30) ok
				aRow = aB[j][:rows][r]
				for c = 1 to len(aRow)
					if c > 1 cRows += char(31) ok
					cRows += _Esc(aRow[c])
				next
			next
			cTsv += "table" + char(9) + "0" + char(9) + cRows + char(10)
		else
			cTsv += aB[j][:kind] + char(9) + aB[j][:level] + char(9) + _Esc(aB[j][:text]) + char(10)
		ok
	next
	write(cOut + "/" + cId + ".native.tsv", cTsv)
	cTimes += cId + char(9) + nSec + char(10)
	? cId + "  " + len(aB) + " blocks  " + nSec + " s"
next
write(cOut + "/native.times.tsv", cTimes)

func _Esc(c)
	c = StzReplace(c, "\", "\\")
	c = StzReplace(c, char(9), "\t")
	c = StzReplace(c, char(10), "\n")
	return c
