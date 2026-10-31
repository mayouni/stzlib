# _look_inspect.ring -- an inspection page for a TWIN: the scan of a golden page read through OCR, each block marked
# against the born-digital page's blocks -- "=" read as the right kind, "x" read as another (the note says which it
# should be), "+" only in the scan; a born block the scan does not have is listed as "-". A block matches the born block
# whose text it is closest to, when at least 60% of the longer one is the same (one minus the edit distance over the
# longer length, spaces and case aside) -- the measure twin_compare.py takes with difflib. Prints one summary line.
#
#   cd libraries/stzlib/base/test/ocr ; rnxc _rig/_look_inspect.ring <scan.pdf> <born.pdf> <lang> <out.html>

load "../../stzBase.ring"
load "_data/goldens_v2.ring"
StzOcrDeclare(StzOcrGoldensV2("_data/"))

oScan = StzPdfQ(sysargv[3])
oScan.ReadOcr(sysargv[5])
aScan = oScan.Blocks()
aBorn = []
for b in StzPdfQ(sysargv[4]).Blocks()
	if b[:page] = 1 add(aBorn, b) ok
next

aUsed = []
aNotes = []
nFound = 0
nSame = 0
nB = len(aBorn)
nS = len(aScan)
for i = 1 to nB
	nBest = 0
	iBest = 0
	for k = 1 to nS
		if aScan[k][:page] != 1 loop ok
		n = similarity(aBorn[i][:text], aScan[k][:text])
		if n > nBest
			nBest = n
			iBest = k
		ok
	next
	if nBest >= 0.6 and len(StzFind(iBest, aUsed)) = 0
		add(aUsed, iBest)
		nFound++
		if aScan[iBest][:kind] = aBorn[i][:kind]
			nSame++
			add(aNotes, [ :block = iBest, :mark = "=", :note = "", :page = 1 ])
		else
			add(aNotes, [ :block = iBest, :mark = "x", :note = "should be " + aBorn[i][:kind], :page = 1 ])
		ok
	else
		add(aNotes, [ :block = 0, :mark = "-", :note = "not in the scan: " + aBorn[i][:kind] + " -- " + aBorn[i][:text], :page = 1 ])
	ok
next
nOnly = 0
for k = 1 to nS
	if aScan[k][:page] = 1 and len(StzFind(k, aUsed)) = 0
		nOnly++
		add(aNotes, [ :block = k, :mark = "+", :note = "only in the scan", :page = 1 ])
	ok
next
oScan.OcrInspectionXT(sysargv[6], aNotes)
? "" + nFound + " of " + nB + " blocks found, " + nSame + " of the right kind, " + nOnly + " only in the scan"

# 1 for the same text, 0 for nothing in common: the better of one minus the edit distance over the longer length, and
# the characters the two share in any order over the longer length (the born reader keeps a code's pieces in another
# order: "48213-2026-HP" for the printed HP-2026-48213), spaces, case, hyphens and the two Arabic digit sets aside
func similarity(pcA, pcB)
	cA = normal(pcA)
	cB = normal(pcB)
	n = StzLen(cA)
	if StzLen(cB) > n n = StzLen(cB) ok
	if n = 0 return 1 ok
	nLev = 1 - StzEngineStringLevenshteinDistance(StzEngineString(cA), StzEngineString(cB)) / n
	aB = StzChars(cB)
	nShared = 0
	for c in StzChars(cA)
		nAt = StzFind(c, aB)
		if len(nAt) > 0
			nShared++
			del(aB, nAt[1])
		ok
	next
	nBag = nShared / n
	if nBag > nLev return nBag ok
	return nLev

func normal(pcText)
	c = StzLower(StzReplace(StzReplace(pcText, char(10), " "), char(9), " "))
	for s in [ " ", "-", char(194) + char(173) ]
		c = StzReplace(c, s, "")
	next
	aP = [ "۰", "۱", "۲", "۳", "۴", "۵", "۶", "۷", "۸", "۹" ]
	aA = [ "٠", "١", "٢", "٣", "٤", "٥", "٦", "٧", "٨", "٩" ]
	for i = 1 to 10
		c = StzReplace(c, aP[i], aA[i])
	next
	return c
