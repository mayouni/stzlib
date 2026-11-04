# THE CODES IN A PICTURE -- IM9c, narrated
#
# SOFTANZA_IMAGE_INTELLIGENCE.md IM9c. stzImage.Codes() reads QR (quirc 1.2, vendored, ISC, with passes that are merged:
# as it is, sharpened, enlarged twice and three times) and the 1D symbologies EAN-13, EAN-8, UPC-A and Code 128
# (engine/src/codes_1d.zig, native: scan lines at 24 angles, a local threshold, widths matched against the standard's
# tables, accepted ONLY when the symbology's own check digit agrees).
#
# THE TRUTH is the string that was ENCODED, by libraries that are not the decoder (segno for QR, python-barcode for the 1D
# codes: _rig/codes_gen.py). A picture is READ when Codes() returns exactly the set encoded in it (StzCodesAgree: a code
# missed and a code invented both fail). THE BARS were written into the plan BEFORE the judging set was made:
#   QR >= 90%, 1D >= 95%, no code returned for a negative, no invented code anywhere, and on the same files strictly more 1D
#   pictures than OpenCV's barcode detector and at least as many QR as OpenCV's QR detector (a MEASURING oracle).
#
#   Scene 1  the faculty :codes exists, its floor finds nothing
#   Scene 2  the DEV set (seed 11), the one the decoders were built against
#   Scene 3  the FIRST judging set (seed 777): SPENT. Its first reading MISSED two bars (below); the defect it showed is fixed and
#            it is reported here, never gated again
#   Scene 4  the SECOND judging set (seed 4242), fresh, made after the fix, judged once: the verdict
#   Scene 5  the LIMITS (harsher conditions): reported, never gated -- where reading stops
#   Scene 6  the registry: the measurement is recorded and the faculty answers through it
#   Scene 7  what a person looks at: the results and pictures with what was read drawn on them
#
# THE FIRST READING OF THE FIRST JUDGING SET (kept on record, before the fix): QR 171 of 174 (98.2%, bar 90%: passed), 1D 179 of 192
# (93.2%, bar 95%: MISSED), 24 negatives with no false read (passed), 12 invented codes (bar 0: MISSED), OpenCV 157 and 97. The cause was ONE
# defect, not a hard condition: an EAN-8 (47859814) read inside a genuine UPC-A (194785981415) -- its digits 3 to 10 form an EAN-8 whose
# check digit agrees one time in ten -- so a correct picture also returned a wrong code. Fixed (a symbol that was read is not searched for
# another inside; a shorter 1D read lying inside a longer one is dropped; a 1D read inside a decoded QR is dropped), and a FRESH set made.
#
# NEEDS D:/GitHub/_wti_models_src/codes/{dev,judge,dev_limits,judge_limits} (python _rig/codes_gen.py, _rig/codes_render.py)
# and the engine built with quirc. HELPERS LIVE AFTER pf().

load "../../stzBase.ring"

$nPass = 0
$nFail = 0
$nSec = clock()
$cRoot = "D:/GitHub/_wti_models_src/codes/"
$nBarQr = 0.90
$nBar1d = 0.95

cOut = StzReplace(WorkingDirectory(), "\", "/") + "/_codes-out"
if NOT StzDirExists(cOut)
	StzDirCreatePath(cOut)
ok

if NOT fexists($cRoot + "judge/truth.tsv") or NOT fexists($cRoot + "dev/truth.tsv")
	? "NOT RUN: the sets in " + $cRoot + " (python base/test/image/_rig/codes_gen.py, then codes_render.py: see their headers)"
	shutdown(0)
ok

? "-- Scene 1: the faculty --"
chk(":codes is declared, with a floor that finds nothing", StzHasFaculty("codes") = 1 and StzFacultyQ("codes").HasFloor() = 1 and len(_StzVisionCodesNone("x", [])) = 0)
sec("scene 1")

? "-- Scene 2: the DEV set (the one the decoders were built against) --"
aDev = RunSet($cRoot + "dev/", 1)
Report("dev", aDev)
chk("dev: QR pictures read " + aDev[:qrRead] + " of " + aDev[:qrTot] + " (" + Pct(aDev[:qrRead], aDev[:qrTot]) + "%) >= " + ($nBarQr * 100) + "%", aDev[:qrRead] >= $nBarQr * aDev[:qrTot])
chk("dev: 1D pictures read " + aDev[:oneRead] + " of " + aDev[:oneTot] + " (" + Pct(aDev[:oneRead], aDev[:oneTot]) + "%) >= " + ($nBar1d * 100) + "%", aDev[:oneRead] >= $nBar1d * aDev[:oneTot])
chk("dev: the " + aDev[:negTot] + " negatives returned no code at all (" + aDev[:negFalse] + " false reads)", aDev[:negFalse] = 0)
chk("dev: no code was ever INVENTED in a picture that holds others (" + aDev[:invented] + ")", aDev[:invented] = 0)
sec("scene 2")

? "-- Scene 3: the FIRST judging set (seed 777), spent: its first reading missed two bars and showed one defect --"
aJ = RunSet($cRoot + "judge/", 0)
Report("first judging set, AFTER the fix", aJ)
chk("the defect it showed is gone: no code invented in it now (the first reading had 12)", aJ[:invented] = 0)
chk("...and its 1D pictures now read " + aJ[:oneRead] + " of " + aJ[:oneTot] + " (the first reading: 179 of 192)", aJ[:oneRead] > 179)
sec("scene 3")

? "-- Scene 4: the SECOND judging set (seed 4242), fresh, made after the fix, judged once --"
aJ2 = RunSet($cRoot + "judge2/", 1)
Report("judge2", aJ2)
chk("judge2: QR pictures read " + aJ2[:qrRead] + " of " + aJ2[:qrTot] + " (" + Pct(aJ2[:qrRead], aJ2[:qrTot]) + "%) >= " + ($nBarQr * 100) + "%", aJ2[:qrRead] >= $nBarQr * aJ2[:qrTot])
chk("judge2: 1D pictures read " + aJ2[:oneRead] + " of " + aJ2[:oneTot] + " (" + Pct(aJ2[:oneRead], aJ2[:oneTot]) + "%) >= " + ($nBar1d * 100) + "%", aJ2[:oneRead] >= $nBar1d * aJ2[:oneTot])
chk("judge2: the " + aJ2[:negTot] + " negatives returned no code at all (" + aJ2[:negFalse] + " false reads)", aJ2[:negFalse] = 0)
chk("judge2: no code was ever INVENTED (" + aJ2[:invented] + ")", aJ2[:invented] = 0)
chk("judge2: OpenCV reads " + aJ2[:ocvOne] + " of the same " + aJ2[:oneTot] + " 1D pictures; the engine reads strictly more", aJ2[:oneRead] > aJ2[:ocvOne])
chk("judge2: OpenCV reads " + aJ2[:ocvQr] + " of the same " + aJ2[:qrTot] + " QR pictures; the engine reads at least as many", aJ2[:qrRead] >= aJ2[:ocvQr])
sec("scene 4")

? "-- Scene 5: the LIMITS (reported, never gated) --"
aDL = RunSet($cRoot + "dev_limits/", 0)
aJL = RunSet($cRoot + "judge_limits/", 0)
aJ2L = RunSet($cRoot + "judge2_limits/", 0)
Report("dev limits", aDL)
Report("judge limits", aJL)
Report("judge2 limits", aJ2L)
chk("limits: no code was ever invented under the harsher conditions either (" + (aDL[:invented] + aJL[:invented] + aJ2L[:invented]) + "; the first reading of the judge limits had 5)", aDL[:invented] + aJL[:invented] + aJ2L[:invented] = 0)
sec("scene 5")

? "-- Scene 6: the registry --"
nAll = aJ2[:qrTot] + aJ2[:oneTot]
nHit = aJ2[:qrRead] + aJ2[:oneRead]
StzRecordMeasurement("codes", "nothing", "codes-judge-v2", 0, nAll, 1, "")
StzRecordMeasurement("codes", "quirc-native1d", "codes-judge-v2", nHit / nAll, nAll, 1,
	"judging set seed 4242 (the second; the first, seed 777, showed a defect that is fixed): QR " + aJ2[:qrRead] + "/" + aJ2[:qrTot] + ", 1D " + aJ2[:oneRead] + "/" + aJ2[:oneTot] + ", negatives " + aJ2[:negFalse] + " false of " + aJ2[:negTot] + "; scored by StzCodesAgree")
cChosen = StzModelRegistryQ().ResolveQ(StzRequirementQ("codes")).Chosen()
chk("with the measurement recorded the registry chooses '" + cChosen + "' over the floor", cChosen = "quirc-native1d")
cQrFile = aJ2[:sampleQr]
oP = StzRunFaculty("codes", $cRoot + "judge2/" + cQrFile, [], [], [], 0)
chk("StzRunFaculty(:codes) answers a clean QR through the registry with the text that was encoded", oP.IsRefusal() = 0 and StzCodesAgree(oP.Value(), [ [ "qr", aJ2[:sampleText] ] ]))
oF = StzRunImplementation("codes", "nothing", $cRoot + "judge2/" + cQrFile, [])
chk("the floor, on the same picture, finds nothing", oF.IsRefusal() = 0 and len(oF.Value()) = 0)
sec("scene 6")

? "-- Scene 7: what a person looks at --"
WritePage(cOut + "/codes.html", aDev, aJ2, aDL, aJ2L)
chk("the page is written", fexists(cOut + "/codes.html"))
sec("scene 7")

? ""
? "ASSERTIONS: " + ($nPass + $nFail) + " -- " + $nPass + " passed, " + $nFail + " failed"
pf()
shutdown($nFail)

# ---- the engine ------------------------------------------------------------------------------------------------------

# one set: every picture through Codes(), against the truth (what was encoded) and against OpenCV's reading of the same file
func RunSet(cDir, bGate)
	aLines = StzSplit(read(cDir + "truth.tsv"), char(10))
	aOcvLines = StzSplit(read(cDir + "oracle.tsv"), char(10))
	aFiles = []
	aWant = []
	nL = len(aLines)
	for i = 1 to nL
		if len(aLines[i]) = 0 loop ok
		aF = StzSplit(aLines[i], char(9))
		nAt = 0
		for j = len(aFiles) to 1 step -1
			if aFiles[j] = aF[1] nAt = j exit ok
		next
		if nAt = 0
			aFiles + aF[1]
			aWant + [ [ aF[3], aF[4], aF[5], aF[2] ] ]
		else
			aWant[nAt] + [ aF[3], aF[4], aF[5], aF[2] ]
		ok
	next
	aStat = [ :qrRead = 0, :qrTot = 0, :oneRead = 0, :oneTot = 0, :negFalse = 0, :negTot = 0, :invented = 0,
		:ocvQr = 0, :ocvOne = 0, :ms = 0, :rows = [], :results = [], :sampleQr = "", :sampleText = "" ]
	nF = len(aFiles)
	for i = 1 to nF
		cKind = aWant[i][1][1]
		cVar = aWant[i][1][4]
		cClass = "one"
		if cKind = "qr" cClass = "qr" ok
		if cKind = "none" cClass = "neg" cVar = "negative" ok
		oImg = StzImageQ(cDir + aFiles[i])
		t0 = clock()
		aC = oImg.Codes()
		aStat[:ms] += (clock() - t0) / clockspersecond() * 1000
		oImg.Release()
		bRead = ExactSet(aC, aWant[i])
		if cClass = "neg"
			aStat[:negTot] += 1
			if len(aC) > 0 aStat[:negFalse] += 1 ok
		else
			# an invented code: one returned that is none of the codes encoded here
			nInv = 0
			for k = 1 to len(aC)
				bKnown = 0
				for m = 1 to len(aWant[i])
					if aC[k][:kind] = aWant[i][m][1] and StzEngineCryptoSha256(aC[k][:text]) = aWant[i][m][2] bKnown = 1 ok
				next
				if bKnown = 0 nInv++ ok
			next
			aStat[:invented] += nInv
			# OpenCV's reading of the same file: the texts it returned, as a set, against the texts encoded
			aO = StzSplit(aOcvLines[i], char(9))
			bOcv = OcvExact(aO, aWant[i])
			if cClass = "qr"
				aStat[:qrTot] += 1
				if bRead aStat[:qrRead] += 1 ok
				if bOcv aStat[:ocvQr] += 1 ok
				if aStat[:sampleQr] = "" and cVar = "clean" and IsAscii(aWant[i][1][3])
					aStat[:sampleQr] = aFiles[i]
					aStat[:sampleText] = aWant[i][1][3]
				ok
			else
				aStat[:oneTot] += 1
				if bRead aStat[:oneRead] += 1 ok
				if bOcv aStat[:ocvOne] += 1 ok
			ok
		ok
		# the per-variant row
		cKey = cClass + " " + cVar
		nRow = 0
		for r = 1 to len(aStat[:rows])
			if aStat[:rows][r][1] = cKey nRow = r exit ok
		next
		if nRow = 0
			aStat[:rows] + [ cKey, 0, 0 ]
			nRow = len(aStat[:rows])
		ok
		aStat[:rows][nRow][3] += 1
		if cClass = "neg"
			if len(aC) = 0 aStat[:rows][nRow][2] += 1 ok
		else
			if bRead aStat[:rows][nRow][2] += 1 ok
		ok
		aStat[:results] + [ aFiles[i], bRead, aC ]
	next
	return aStat

# the returned set is exactly the encoded set: kind and text, by the bytes of the text (its sha256)
func ExactSet(aGot, aWant)
	if len(aWant) = 1 and aWant[1][1] = "none"
		return len(aGot) = 0
	ok
	if len(aGot) != len(aWant) return 0 ok
	aUsed = []
	for i = 1 to len(aGot) aUsed + 0 next
	for j = 1 to len(aWant)
		bFound = 0
		for i = 1 to len(aGot)
			if aUsed[i] = 0 and aGot[i][:kind] = aWant[j][1] and StzEngineCryptoSha256(aGot[i][:text]) = aWant[j][2]
				aUsed[i] = 1
				bFound = 1
				exit
			ok
		next
		if bFound = 0 return 0 ok
	next
	return 1

# OpenCV's texts (QR and barcode columns, '|' separated) as a set equal to the encoded texts
func OcvExact(aO, aWant)
	aT = []
	for c = 2 to len(aO)
		if len(aO[c]) > 0
			aP = StzSplit(aO[c], "|")
			for p = 1 to len(aP) aT + aP[p] next
		ok
	next
	if len(aT) != len(aWant) return 0 ok
	for j = 1 to len(aWant)
		bFound = 0
		for k = 1 to len(aT)
			if aT[k] = aWant[j][3] bFound = 1 exit ok
		next
		if bFound = 0 return 0 ok
	next
	return 1

func IsAscii(cText)
	for i = 1 to len(cText)
		if ascii(cText[i]) > 126 or ascii(cText[i]) < 32 return 0 ok
	next
	return 1

func Pct(nA, nB)
	if nB = 0 return 0 ok
	return floor(nA * 1000 / nB) / 10

# the per-variant table of one set, and the totals
func Report(cLabel, aStat)
	? "  " + cLabel + ": per variant (read / pictures)"
	cLine = ""
	for r = 1 to len(aStat[:rows])
		cLine += aStat[:rows][r][1] + " " + aStat[:rows][r][2] + "/" + aStat[:rows][r][3] + " | "
		if r % 4 = 0
			? "    " + cLine
			cLine = ""
		ok
	next
	if len(cLine) > 0 ? "    " + cLine ok
	? "  " + cLabel + ": QR " + aStat[:qrRead] + "/" + aStat[:qrTot] + " (OpenCV " + aStat[:ocvQr] + "), 1D " + aStat[:oneRead] + "/" + aStat[:oneTot] +
		" (OpenCV " + aStat[:ocvOne] + "), negatives " + aStat[:negFalse] + " false of " + aStat[:negTot] + ", invented " + aStat[:invented] +
		", " + floor(aStat[:ms] / (aStat[:qrTot] + aStat[:oneTot] + aStat[:negTot] + 0.0001)) + " ms per picture"

func chk(cWhat, bCond)
	if bCond = 1
		$nPass++
		? "  [OK] " + cWhat
	else
		$nFail++
		? "  [FAIL] " + cWhat
	ok

func sec(cName)
	? "    ~ " + cName + ": " + ((clock() - $nSec) / clockspersecond()) + "s"
	? ""
	$nSec = clock()

func Esc(c)
	return StzReplace(StzReplace(StzReplace("" + c, "&", "&amp;"), "<", "&lt;"), ">", "&gt;")

# ---- the page --------------------------------------------------------------------------------------------------------

# a picture with what was read drawn on it: the corners of a QR, the line a 1D code was read along
func Annotated(cPath)
	oImg = StzImageQ(cPath)
	aC = oImg.Codes()
	oCol = oImg.Coloured()
	oImg.Release()
	cSaid = ""
	for k = 1 to len(aC)
		aP = aC[k][:points]
		if aC[k][:kind] = "qr"
			for q = 1 to 4
				qn = q % 4 + 1
				DrawSeg(oCol, aP[q], aP[qn], "#e0262d")
			next
			for q = 1 to 4
				oCol.ApplyDot(aP[q], 4, "#1a7f37")
			next
		else
			DrawSeg(oCol, aP[1], aP[2], "#e0262d")
			oCol.ApplyDot(aP[1], 4, "#1a7f37")
			oCol.ApplyDot(aP[2], 4, "#1a7f37")
		ok
		if len(cSaid) > 0 cSaid += "  /  " ok
		cSaid += aC[k][:kind] + ": " + aC[k][:text]
	next
	if len(aC) = 0 cSaid = "(nothing read)" ok
	cImg = oCol.ToPngDataURI()
	oCol.Release()
	return [ cImg, cSaid ]

func DrawSeg(oImg, aA, aB, cColor)
	dx = aB[1] - aA[1]
	dy = aB[2] - aA[2]
	nLen = sqrt(dx * dx + dy * dy)
	nSteps = floor(nLen / 2) + 1
	for s = 0 to nSteps
		oImg.ApplyDot([ aA[1] + dx * s / nSteps, aA[2] + dy * s / nSteps ], 1, cColor)
	next

func RowsTable(aA, aB, cNameA, cNameB)
	c = "<table><tr><th>conditions</th><th>" + cNameA + "</th><th>" + cNameB + "</th></tr>"
	for r = 1 to len(aA[:rows])
		cOther = ""
		for q = 1 to len(aB[:rows])
			if aB[:rows][q][1] = aA[:rows][r][1] cOther = "" + aB[:rows][q][2] + " / " + aB[:rows][q][3] ok
		next
		cCls = ""
		if aA[:rows][r][2] < aA[:rows][r][3] cCls = " class='part'" ok
		c += "<tr" + cCls + "><td>" + Esc(aA[:rows][r][1]) + "</td><td>" + ("" + aA[:rows][r][2]) + " / " + aA[:rows][r][3] + "</td><td>" + cOther + "</td></tr>"
	next
	return c + "</table>"

func WritePage(cPath, aDev, aJ, aDL, aJL)
	c = "<!doctype html><html lang='en'><head><meta charset='utf-8'><meta name='viewport' content='width=device-width,initial-scale=1'>" +
		"<title>Codes read from pictures</title><style>" +
		":root{--bg:#fff;--fg:#1c1c1e;--mut:#6b6b70;--line:#d8d8dc;--ok:#1a7f37;--bad:#b3261e;--card:#f6f6f8}" +
		"@media (prefers-color-scheme:dark){:root{--bg:#161618;--fg:#ececf0;--mut:#9a9aa2;--line:#3a3a40;--ok:#4cc26a;--bad:#f28b82;--card:#202024}}" +
		"body{margin:0;background:var(--bg);color:var(--fg);font:16px/1.5 system-ui,Segoe UI,sans-serif}main{max-width:1100px;margin:0 auto;padding:16px}" +
		"h1{font-size:1.5rem;margin:.3em 0}h2{font-size:1.1rem;margin:1.4em 0 .3em}p.sub{color:var(--mut)}" +
		".k{display:grid;grid-template-columns:repeat(auto-fit,minmax(200px,1fr));gap:12px;margin:1em 0}.kp{background:var(--card);border-radius:8px;padding:10px 14px}" +
		".kp b{display:block;font-size:1.5rem}.kp span{color:var(--mut);font-size:.9rem}table{border-collapse:collapse;width:100%;font-size:.9rem}" +
		"th,td{border-bottom:1px solid var(--line);padding:4px 8px;text-align:left}th{color:var(--mut)}tr.part td{color:var(--bad)}" +
		".g{display:grid;grid-template-columns:repeat(auto-fill,minmax(250px,1fr));gap:12px}.c{border:1px solid var(--line);border-radius:8px;padding:8px}" +
		".c img{width:100%;height:auto;display:block;background:#fff}.c p{margin:.3em 0 0;font-size:.8rem;color:var(--mut);word-break:break-all}.two{display:grid;grid-template-columns:1fr 1fr;gap:16px}" +
		"@media (max-width:700px){.two{grid-template-columns:1fr}}</style></head><body><main>" +
		"<h1>Codes, read from pictures</h1><p class='sub'>QR by quirc, EAN-13, EAN-8, UPC-A and Code 128 natively. Every code was made by a library that is not the decoder, so the truth is the string that was encoded. " +
		"A picture counts as read only when exactly the encoded set comes back. Red rows are conditions where some pictures were not read.</p>" +
		"<div class='k'><div class='kp'><b>" + aJ[:qrRead] + " / " + aJ[:qrTot] + "</b><span>QR pictures read, judging set (OpenCV: " + aJ[:ocvQr] + ")</span></div>" +
		"<div class='kp'><b>" + aJ[:oneRead] + " / " + aJ[:oneTot] + "</b><span>1D pictures read, judging set (OpenCV: " + aJ[:ocvOne] + ")</span></div>" +
		"<div class='kp'><b>" + aJ[:negFalse] + " / " + aJ[:negTot] + "</b><span>false reads on pictures with no code</span></div>" +
		"<div class='kp'><b>" + aJ[:invented] + "</b><span>codes invented, in any picture</span></div></div>" +
		"<h2>The judging set, and the dev set it was kept apart from</h2><div class='two'><div>" + RowsTable(aJ, aDev, "judging (seed 4242)", "dev (seed 11)") + "</div><div>" +
		"<h2 style='margin-top:0'>The limits: harsher conditions, never gated</h2>" + RowsTable(aJL, aDL, "judging limits", "dev limits") + "</div></div>" +
		"<h2>What was read, drawn on the picture (judging set)</h2><p class='sub'>Red: the corners of a QR, or the line a 1D code was read along. Green dots: its ends.</p><div class='g'>"
	aShow = [ "qr00__rot45.png", "qr02__persp.png", "qr05__scene.png", "qr07__blur1.png", "multi_qr00_qr01.png", "ean13_0__rot17.png",
		"ean8_1__persp.png", "upca_2__scene.png", "code128_0__rot45.png", "code128_3__noise2.png", "ean13_2__blur2.png", "qr10__rot133.png" ]
	for i = 1 to len(aShow)
		cF = $cRoot + "judge/" + aShow[i]
		if fexists(cF)
			aA = Annotated(cF)
			c += "<div class='c'><img src='" + aA[1] + "' alt='" + Esc(aShow[i]) + "'><p>" + Esc(aShow[i]) + "<br>" + Esc(aA[2]) + "</p></div>"
		ok
	next
	c += "</div></main></body></html>"
	write(cPath, c)
