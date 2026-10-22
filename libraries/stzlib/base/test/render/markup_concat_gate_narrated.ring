load "../../stzBase.ring"
load "../_narrated.ring"

# RX gate -- the ratchet that catches a NEW writer concatenating markup.
#
# The rule markup-concatenation (base/meta/stzCodeRules.ring) counts, per file,
# the lines that join a tag literal to a dynamic operand with no escaping face
# on the line. This guard walks the library, counts every file, and compares
# the counts with markup_concat_baseline.txt:
#
#   - a file that counts MORE than its baseline fails: a new concatenating line
#   - a file NOT in the baseline that counts any fails: a new concatenating writer
#   - a file that counts LESS is reported, and the baseline should be lowered
#
# It is a RATCHET, not a verdict: the baseline holds lines to read, with known
# false positives, and the gate says only "nothing new has been added". A line
# that is safe (its operand is escaped on an earlier line, or validated) is
# added to the baseline by a person who has read it, which is the point.
#
# TREE COMMIT of the baseline: taken at 4e8608a5d plus the RX gate work of
# 2026-10-22. WALKED: base/ without the folders test, doc, archive, recovered and
# without *_monolithic and *-copy files, the same set the census tool reads.
# HEAVY: about a minute, one process; run it once before a commit that touches
# any writer, not after every edit.

$GATE_SKIP_DIRS = [ "test", "doc", "archive", "recovered" ]

GateMain()

func GateMain()
	aBase = GateBaseline("markup_concat_baseline.txt")
	aFiles = []
	GateWalk("../..", "", aFiles)
	nFiles = len(aFiles)
	aNow = []
	for i = 1 to nFiles
		aF = _StzCheckMarkupConcat(read("../../" + aFiles[i]))
		if len(aF) > 0
			aNow + [ aFiles[i], len(aF) ]
		ok
	next
	Scenario("The ratchet: no file counts more than its baseline, and no new file counts any")
		Given("the library walked (" + nFiles + " files) and counted by the markup-concatenation rule")
		nNew = 0
		nMore = 0
		nLess = 0
		acNew = []
		acMore = []
		acLess = []
		for i = 1 to len(aNow)
			nB = GateBaseOf(aBase, aNow[i][1])
			if nB < 0
				nNew++
				acNew + (aNow[i][1] + " (" + aNow[i][2] + ")")
			but aNow[i][2] > nB
				nMore++
				acMore + (aNow[i][1] + " " + nB + " -> " + aNow[i][2])
			but aNow[i][2] < nB
				nLess++
				acLess + (aNow[i][1] + " " + nB + " -> " + aNow[i][2])
			ok
		next
		for i = 1 to len(aBase)
			if GateBaseOf(aNow, aBase[i][1]) < 0
				nLess++
				acLess + (aBase[i][1] + " " + aBase[i][2] + " -> 0")
			ok
		next
		Then("no new file counts any line", nNew, 0)
		for c in acNew
			? "    NEW WRITER: " + c
		next
		Then("no file counts more than its baseline", nMore, 0)
		for c in acMore
			? "    MORE: " + c
		next
		if nLess > 0
			? "    (" + nLess + " file(s) count less than the baseline; lower it:)"
			for c in acLess
				? "      " + c
			next
		ok
		Then("the baseline is not empty (the gate reads something)", len(aBase) > 0, 1)
		nTotalNow = 0
		for i = 1 to len(aNow)
			nTotalNow += aNow[i][2]
		next
		? "  state  " + nTotalNow + " lines in " + len(aNow) + " files today; the baseline holds " + len(aBase) + " files"
	EndScenario()
	Summary()

# [ [ path, count ], ... ] from the baseline file; lines starting with # are notes
func GateBaseline(cPath)
	aOut = []
	acL = StzSplit(StzReplace(read(cPath), char(13), ""), char(10))
	for i = 1 to len(acL)
		cL = ring_trim(acL[i])
		if cL = "" or StzLeft(cL, 1) = "#"
			loop
		ok
		acP = StzSplit(cL, " ")
		if len(acP) = 2
			aOut + [ acP[1], 0 + acP[2] ]
		ok
	next
	return aOut

# the count of a path in a list of [ path, count ], -1 when absent
func GateBaseOf(aList, cPath)
	for i = 1 to len(aList)
		if strcmp(aList[i][1], cPath) = 0
			return aList[i][2]
		ok
	next
	return -1

# every .ring file under cRoot, as a path relative to it, skipping the folders and files the census skips
func GateWalk(cRoot, cRel, aOut)
	cDir = cRoot
	if cRel != ""
		cDir = cRoot + "/" + cRel
	ok
	aEntries = dir(cDir)
	for i = 1 to len(aEntries)
		cName = aEntries[i][1]
		if cName = "." or cName = ".."
			loop
		ok
		cPath = cName
		if cRel != ""
			cPath = cRel + "/" + cName
		ok
		if aEntries[i][2] = 1
			bSkip = 0
			for cS in $GATE_SKIP_DIRS
				if strcmp(cName, cS) = 0
					bSkip = 1
				ok
			next
			if bSkip = 0
				GateWalk(cRoot, cPath, aOut)
			ok
		else
			if StzRight(cName, 5) = ".ring" and StzFindFirst("_monolithic", cName) = 0 and
			   StzFindFirst("-copy.ring", cName) = 0
				aOut + cPath
			ok
		ok
	next
