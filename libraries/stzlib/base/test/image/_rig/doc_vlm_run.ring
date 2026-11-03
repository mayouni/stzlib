# doc_vlm_run.ring -- both readers on :doc-vlm's golden pages (IM7, 2 of 2): the floor and Granite-Docling.
#
#   rnxc doc_vlm_run.ring <pages dir> <out dir> [granite|floor|both] [<key> ...]
#
# <pages dir> is doc_vlm_render.py's output (<key>.png and golden.tsv). For each page writes, in the shared
# prediction format of base/test/document/_doc_score.py (kind, level, text; a table's rows joined by U+001E, its
# cells by U+001F):
#   <key>.floor.tsv     the native PDF reader on the page as a scan (OCR, then its own layout rules)
#   <key>.granite.tsv   Granite-Docling's blocks;   <key>.doctags.txt   what it wrote, tags and all
#   <key>.combined.tsv  the two combined (StzDocBlocksCombine), derived from the two files above; mode "combine" makes
#                       only these
# and floor.times.tsv / granite.times.tsv (key, seconds). Run from base/test/image so the library loads.
# A page already done is skipped, so a run that stopped is run again from where it stopped.

load "../../stzBase.ring"
load "_rig/doc_vlm_tsv.ring"

cPages = sysargv[3]
cOut = sysargv[4]
cWhich = "both"
if len(sysargv) >= 5 cWhich = sysargv[5] ok
aKeys = []
if len(sysargv) >= 6
	for i = 6 to len(sysargv)
		aKeys + sysargv[i]
	next
else
	aLines = StzSplit(read(cPages + "/golden.tsv"), char(10))
	for i = 1 to len(aLines)
		if aLines[i] != "" aKeys + StzSplit(aLines[i], char(9))[1] ok
	next
ok
if NOT direxists(cOut) system("mkdir " + StzReplace(cOut, "/", "\")) ok

for i = 1 to len(aKeys)
	cKey = aKeys[i]
	cPng = cPages + "/" + cKey + ".png"
	if cWhich = "both" or cWhich = "floor"
		if NOT fexists(cOut + "/" + cKey + ".floor.tsv")
			t0 = StzEngineWatchTimestampMs()
			aB = _StzVisionDocFloor(cPng, [])
			nSec = (StzEngineWatchTimestampMs() - t0) / 1000
			write(cOut + "/" + cKey + ".floor.tsv", Tsv(aB))
			write(cOut + "/floor.times.tsv", read2(cOut + "/floor.times.tsv") + cKey + char(9) + nSec + char(10))
			? cKey + "  floor    " + len(aB) + " blocks  " + nSec + " s"
		ok
	ok
	if cWhich = "both" or cWhich = "granite"
		if NOT fexists(cOut + "/" + cKey + ".granite.tsv")
			t0 = StzEngineWatchTimestampMs()
			cTags = StzImageQ(cPng).DocTags()
			nSec = (StzEngineWatchTimestampMs() - t0) / 1000
			aB = StzDocTagsBlocks(cTags)
			write(cOut + "/" + cKey + ".doctags.txt", cTags)
			write(cOut + "/" + cKey + ".granite.tsv", Tsv(aB))
			write(cOut + "/granite.times.tsv", read2(cOut + "/granite.times.tsv") + cKey + char(9) + nSec + char(10))
			aS = StzEngineNeuralVlmStats()
			? cKey + "  granite  " + len(aB) + " blocks  " + aS[3] + " tokens  " + nSec + " s"
		ok
	ok
	# the combination is DERIVED from the two stored readings (no model runs): StzDocBlocksCombine
	if cWhich = "both" or cWhich = "combine"
		cF = cOut + "/" + cKey + ".floor.tsv"
		cG = cOut + "/" + cKey + ".granite.tsv"
		if fexists(cF) and fexists(cG)
			write(cOut + "/" + cKey + ".combined.tsv", Tsv(StzDocBlocksCombine(BlocksFromTsv(cF), BlocksFromTsv(cG))))
		ok
	ok
next

func read2(cPath)
	if fexists(cPath) return read(cPath) ok
	return ""
