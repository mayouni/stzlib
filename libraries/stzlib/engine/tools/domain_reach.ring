# W7 of SOFTANZA_ONE_HOUR.md, part 2 -- which engine domains a program can reach.
#
# Reads the program's resolved call graph (rnxc graph) and the function ->
# domain map (domain_load_census.ring), walks every definition reachable from
# the top level of every file the program loads, and scans those bodies for
# native engine calls. A domain is REACHABLE when one of its functions appears
# in a reachable body.
#
#   run:     rnxc domain_reach.ring <graph.txt> <domains.map> <programDir> [static]
#            programDir is the folder the graph was taken from (its FILE paths are relative to it);
#            static follows only the calls the compiler resolved, a tighter figure that misses
#            every o.Name() whose receiver it could not type
#   prints:  REACH|<n domains reachable>|<n loaded>|<names, comma-separated>
#
# What the number is, and is not:
#   * an UPPER bound on what a program touches: a dynamic call (o.Name()) is
#     resolved to EVERY method of that name, and every top-level line of every
#     loaded file counts, since all of it runs at load;
#   * blind to a call made through eval, call or a function name held in a
#     variable -- such a domain is missed, which makes the bound not quite an
#     upper bound; the text-run-as-code count (W2a) says how many sites can.

aArgs = sysargv
nArgs = len(aArgs)
$bStatic = 0
if nArgs >= 6 and aArgs[nArgs] = "static"
	$bStatic = 1
	del(aArgs, nArgs)
	nArgs--
ok
if nArgs < 5
	? "usage: rnxc domain_reach.ring <graph.txt> <domains.map> <programDir>"
	shutdown(2)
ok
cGraph = aArgs[nArgs - 2]
cMapF  = aArgs[nArgs - 1]
cProg  = aArgs[nArgs]

# --- the map: sorted [ name, domain ] ---------------------------------------
$aNat = []
aL = str2list(read(cMapF))
for i = 1 to len(aL)
	c = aL[i]
	if c = "" or left(c, 1) = "#"  loop  ok
	k = substr(c, "|")
	if k = 0  loop  ok
	$aNat + [ left(c, k - 1), substr(c, k + 1) ]
next
$aNat = sort($aNat, 1)

# --- the graph --------------------------------------------------------------
$aDefs  = []    # [ key, fileIndex, line ]
$aFiles = []    # [ path, [ def lines ] ]
$aEdges = []    # [ caller, callee, dynamic ]
$aMeth  = []    # [ method name, key ]
nFile = 0
aG = str2list(read(cGraph))
for i = 1 to len(aG)
	aF = Fields(aG[i])
	if len(aF) < 2  loop  ok
	cK = aF[1]
	if cK = "FILE"
		$aFiles + [ aF[2], [] ]
		nFile = len($aFiles)
	but cK = "FUNC" and nFile > 0
		$aDefs + [ lower(aF[2]), nFile, 0 + aF[3] ]
		$aFiles[nFile][2] + (0 + aF[3])
	but cK = "METHOD" and nFile > 0
		$aDefs + [ lower(aF[2] + "." + aF[3]), nFile, 0 + aF[4] ]
		$aMeth + [ lower(aF[3]), lower(aF[2] + "." + aF[3]) ]
		$aFiles[nFile][2] + (0 + aF[4])
	but cK = "CLASS" and nFile > 0
		$aFiles[nFile][2] + (0 + aF[4])
	but cK = "CALL"
		bDyn = 0
		if len(aF) >= 4 and aF[4] = "dynamic"  bDyn = 1  ok
		$aEdges + [ lower(aF[2]), lower(aF[3]), bDyn ]
	ok
next
$aDefs  = sort($aDefs, 1)
$aEdges = sort($aEdges, 1)
$aMeth  = sort($aMeth, 1)
for i = 1 to len($aFiles)
	$aFiles[i][2] = sort($aFiles[i][2])
next

# --- reachability from <top>, over definition indices ----------------------
# a node is an index into $aDefs; one name defined in two files is two nodes
$aVisit = list(len($aDefs))
for i = 1 to len($aVisit)  $aVisit[i] = 0  next
nHead = 1
$aKeys = [ "<top>" ]
while nHead <= len($aKeys)
	cNode = $aKeys[nHead]
	nHead++
	n = Lower1st($aEdges, cNode)
	while n > 0 and n <= len($aEdges) and $aEdges[n][1] = cNode
		if $aEdges[n][3] = 1 and $bStatic = 1
			n++
			loop
		ok
		if $aEdges[n][3] = 1
			m = Lower1st($aMeth, $aEdges[n][2])
			while m > 0 and m <= len($aMeth) and $aMeth[m][1] = $aEdges[n][2]
				MarkKey($aMeth[m][2])
				m++
			end
		ok
		MarkKey($aEdges[n][2])
		n++
	end
end
nReached = 0
for i = 1 to len($aVisit)
	if $aVisit[i] = 1  nReached++  ok
next

# --- the bodies: reachable definitions, plus every file's top-level lines ---
aSpans = []     # [ fileIndex, from, to ]
for i = 1 to len($aDefs)
	if $aVisit[i] = 1
		nF = $aDefs[i][2]
		nFrom = $aDefs[i][3]
		aSpans + [ nF, nFrom, NextDefLine(nF, nFrom) - 1 ]
	ok
next
for i = 1 to len($aFiles)
	nFirst = 999999999
	if len($aFiles[i][2]) > 0  nFirst = $aFiles[i][2][1]  ok
	aSpans + [ i, 1, nFirst - 1 ]
next
aSpans = sort(aSpans, 1)

$aDom = []
nCur = 0
aLines = []
for i = 1 to len(aSpans)
	if aSpans[i][1] != nCur
		nCur = aSpans[i][1]
		cPath = cProg + "/" + $aFiles[nCur][1]
		aLines = []
		if fexists(cPath)  aLines = str2list(read(cPath))  ok
	ok
	nTo = aSpans[i][3]
	if nTo > len(aLines)  nTo = len(aLines)  ok
	$bInBlock = 0
	for j = aSpans[i][2] to nTo
		ScanLine(CodeOf(lower(aLines[j])))
	next
next
aDomains = sort($aDom)
aAll = []
for i = 1 to len($aNat)
	if find(aAll, $aNat[i][2]) = 0  aAll + $aNat[i][2]  ok
next
cNames = ""
for i = 1 to len(aDomains)
	if i > 1  cNames += ","  ok
	cNames += aDomains[i]
next
? "REACH|" + len(aDomains) + "|" + len(aAll) + "|" + cNames
? "NODES|" + nReached + " of " + len($aDefs) + " definitions reachable"

# --- helpers ----------------------------------------------------------------

func Fields(cLine)
	aOut = []
	cCur = ""
	n = len(cLine)
	for i = 1 to n
		c = cLine[i]
		if c = "|"
			aOut + cCur
			cCur = ""
		else
			cCur += c
		ok
	next
	aOut + cCur
	return aOut

# the first index of key in a list sorted on column 1, or 0
func Lower1st(aList, cKey)
	nLo = 1
	nHi = len(aList)
	nAt = 0
	while nLo <= nHi
		nMid = floor((nLo + nHi) / 2)
		cV = aList[nMid][1]
		if cV = cKey
			nAt = nMid
			nHi = nMid - 1
		but strcmp(cV, cKey) < 0
			nLo = nMid + 1
		else
			nHi = nMid - 1
		ok
	end
	return nAt

# marks every definition named cKey and queues the name once, on the global
# queue: Ring passes a list by value, so a queue handed in would be copied
func MarkKey(cKey)
	n = Lower1st($aDefs, cKey)
	bNew = 0
	while n > 0 and n <= len($aDefs) and $aDefs[n][1] = cKey
		if $aVisit[n] = 0
			$aVisit[n] = 1
			bNew = 1
		ok
		n++
	end
	if bNew = 1  $aKeys + cKey  ok

func NextDefLine(nFile, nLine)
	aD = $aFiles[nFile][2]
	for i = 1 to len(aD)
		if aD[i] > nLine  return aD[i]  ok
	next
	return 999999999

func ScanLine(cL)
	n = len(cL)
	i = 1
	while i <= n
		c = cL[i]
		if c = "s" and (i = 1 or NOT IsIdent(cL[i - 1]))
			j = i
			while j <= n and IsIdent(cL[j])
				j++
			end
			cTok = substr(cL, i, j - i)
			if left(cTok, 9) = "stzengine" or left(cTok, 9) = "stz_meta_"
				k = Lower1st($aNat, cTok)
				if k > 0 and find($aDom, $aNat[k][2]) = 0
					$aDom + $aNat[k][2]
				ok
			ok
			i = j
		else
			i++
		ok
	end

# the code of a line with its comments removed: # and // to the end, and
# /* ... */ across lines. A # inside a string literal also cuts, which can only
# miss a call, never invent one
func CodeOf(cL)
	cOut = ""
	n = len(cL)
	i = 1
	while i <= n
		if $bInBlock = 1
			if cL[i] = "*" and i < n and cL[i + 1] = "/"
				$bInBlock = 0
				i += 2
			else
				i++
			ok
			loop
		ok
		c = cL[i]
		if c = "#"  exit  ok
		if c = "/" and i < n and cL[i + 1] = "/"  exit  ok
		if c = "/" and i < n and cL[i + 1] = "*"
			$bInBlock = 1
			i += 2
			loop
		ok
		cOut += c
		i++
	end
	return cOut

func IsIdent(c)
	return isalnum(c) or c = "_"
