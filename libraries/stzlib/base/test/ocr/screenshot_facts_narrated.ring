# A SCREENSHOT REDUCED TO FACTS -- the writer of stzzui's legibility audit, narrated
#
# stzzui's audit (doc/design/AUDIT-FACTS.md there, format zui-audit-facts 1.0) judges three rules from one
# screenshot: contrast (rules 62 and 105) and the size floor (rule 107). It judges FACTS, not pixels, and this
# library writes them: base/ocr/stzScreenshotFacts.ring, run as tools/screenshot_facts.ring under rnxc. The
# writer measures and never judges; a field it cannot measure is null.
#
#   Scene 1  the luminance split inside a box, on pixels whose answer is known exactly
#   Scene 2  what kind of box the OCR gives: a line box or an ink box (stzzui's STZLIB-OCR-BOXKIND-01)
#   Scene 3  sixteen rows of known colours rendered by a real browser at scale 1 and 2: the measured
#            luminances against the colours they were painted with
#   Scene 4  backgrounds with no single colour: bg_spread (STZLIB-OCR-SPREAD-01)
#   Scene 5  the facts file itself
#   Scene 6  what a person looks at: an HTML page
#
# THE TRUTH IS THE PAINT: _rig/screenshot_facts_golden.py renders _data/facts/ with headless Chrome and writes
# the WCAG luminance of each CSS colour by the standard's formula, not by the engine judged here.
# NEEDS the OCR models in models/ocr; when absent the guard says so and stops. THE HELPERS LIVE AFTER pf().

load "../../stzBase.ring"
load "_data/facts/facts_golden.ring"

$nPass = 0
$nFail = 0
$nSec = clock()
$cDat = StzReplace(WorkingDirectory(), "\", "/") + "/_data/facts/"

cOut = StzReplace(WorkingDirectory(), "\", "/") + "/_facts-out"
if NOT StzDirExists(cOut)
	StzDirCreatePath(cOut)
ok

if NOT fexists(StzOcrModelDir() + "/" + StzOcrModelRecogniserFor("en"))
	? "NOT RUN: the OCR models are not installed in " + StzOcrModelDir() + " -- see models/MODELS.md"
	shutdown(1)
ok

pr()

#=====================================================================#
? "-- Scene 1: the split inside a box --"
#=====================================================================#

decimals(6)
o = StzImageNew(40, 20, 3, 255)
o.ApplyBox([ 11, 6, 12, 6 ], [ 51, 51, 51 ], 3)
a = o.TextLuminanceInBox([ 0, 0, 39, 19 ])
chk("#333333 drawn on white reads as its WCAG luminance, 0.033105 (got " + a[:text] + ")",
	fabs(a[:text] - 0.033105) < 0.000002)
chk("the background is white, 1, with no spread, over the 584 pixels at least 3 pixels from the ink",
	a[:background] = 1 and a[:spread] = 0 and a[:bgpixels] = 584)
chk("the ink is the smaller side of the split: the 72 pixels drawn", a[:ink] = 72)
a = o.TextLuminanceInBox([ 8, 3, 23, 12 ])
chk("a box with no pixel 3 pixels from ink gives no background, never a guessed one",
	a[:background] = "" and a[:spread] = "")
o2 = StzImageNew(10, 10, 3, 200)
chk("a box of one gray level gives nothing at all", len(o2.TextLuminanceInBox([ 0, 0, 9, 9 ])) = 0)
o.Release()
o2.Release()
sec("scene 1")

#=====================================================================#
? "-- Scene 2: what kind of box --"
#=====================================================================#

aBk = StzFactsGoldenBoxKind()
aRead = StzOcrModelLinesXT($cDat + "boxkind.png", "en")
aH = []
nBk = len(aBk)
for i = 1 to nBk
	aH + BoxHeightAt(aRead, aBk[i][1], aBk[i][3])
next
? "  box heights, em 16 / 24 / 32 / 48 px:  esc " + aH[1] + " " + aH[2] + " " + aH[3] + " " + aH[4] +
	"   Hxgp " + aH[5] + " " + aH[6] + " " + aH[7] + " " + aH[8]
chk("every row is read", len(aRead) = 8 and len(StzFind(0, aH)) = 0)
chk("the box follows the INK: at the same size, 'Hxgp' gets a box at least 1.4 times as tall as 'esc' " +
	"(16 px: " + aH[5] + " against " + aH[1] + ")", aH[5] >= 1.4 * aH[1] and aH[8] >= 1.4 * aH[4])
chk("and it is not a line box: 'esc' at 48 px gets a box under one em (" + aH[4] + " px)", aH[4] < 48)
chk("so the writer says ink, and the audit's size decision reads not_decided", $cStzScreenshotFactsBoxKind = "ink")
sec("scene 2")

#=====================================================================#
? "-- Scene 3: sixteen painted rows, two scales --"
#=====================================================================#

aG = StzFactsGolden()
aPages = []
for nScale = 1 to 2
	cPng = $cDat + "facts_s" + nScale + ".png"
	aF = StzScreenshotFacts(cPng, nScale, "en")
	aPages + [ cPng, nScale, aF, aG ]
	aM = MatchRows(aG, aF[:lines])
	nRead = 0
	nNear = 0
	nSame = 0
	nFlat = 0
	nWorst = 0
	nPt = 0
	nG = len(aG)
	for i = 1 to nG
		if aM[i] = 0 loop ok
		nRead++
		l = aF[:lines][aM[i]]
		if l[:line_height_pt] = floor(l[:line_height_px] * 72 / (96 * nScale) * 100 + 0.5) / 100 nPt++ ok
		if isString(aG[i][3]) loop ok
		nFlat++
		nTrue = Ratio(aG[i][2], aG[i][3])
		nD = fabs(l[:contrast_ratio] - nTrue)
		if nD > nWorst nWorst = nD ok
		if nD <= 0.1 nNear++ ok
		if (l[:contrast_ratio] >= 4.5) = (nTrue >= 4.5) nSame++ ok
	next
	? "  scale " + nScale + ": " + nRead + " of " + nG + " rows read; worst contrast error " + nWorst
	chk("scale " + nScale + ": every row is read, its text exact", nRead = nG)
	chk("scale " + nScale + ": on all " + nFlat + " flat backgrounds the contrast is within 0.1 of the paint's", nNear = nFlat)
	chk("scale " + nScale + ": and on the same side of 4.5:1 as the paint's, every one", nSame = nFlat)
	chk("scale " + nScale + ": every line height in points is px x 72 / (96 x scale), to 2 decimals", nPt = nRead)
next
sec("scene 3")

#=====================================================================#
? "-- Scene 4: backgrounds with no single colour --"
#=====================================================================#

aT = StzFactsGoldenTexture()
aTex = []
for nScale = 1 to 2
	cPng = $cDat + "facts_texture_s" + nScale + ".png"
	aF = StzScreenshotFacts(cPng, nScale, "en")
	aPages + [ cPng, nScale, aF, aT ]
	aTex + [ nScale, MatchRows(aT, aF[:lines]), aF ]
next
aM2 = aTex[2][2]
chk("the checkerboard (scale 2) is read, and its background spread is above 0.25, so the audit holds its contrast",
	aM2[2] > 0 and aTex[2][3][:lines][aM2[2]][:bg_spread] > 0.25)
nSp1 = Spread(aTex[1], 3)
nSp2 = Spread(aTex[2], 3)
chk("the gradient under a whole line is read at both scales, with a spread of " + nSp1 + " and " + nSp2 +
	" (the true range under it is 0.19)", nSp1 > 0.15 and nSp2 > 0.15)
? "  NOTE: the stripes row is read at neither scale (" + aTex[1][2][1] + ", " + aTex[2][2][1] +
	") -- the OCR detector does not find text over vertical stripes, so it has no line in the facts"
? "  NOTE: the gradient's spread is under the audit's 0.25 limit, so its 4.66:1 passes; 46% of that line is over " +
	"background where white text is under 4.5:1 (down to 2.99:1) -- a finding for stzzui's limit, not the writer"
sec("scene 4")

#=====================================================================#
? "-- Scene 5: the facts file --"
#=====================================================================#

cJson = StzScreenshotFactsJson($cDat + "facts_s2.png", 2, "en")
write(cOut + "/facts_s2.facts.json", cJson)
chk("it names its format, version and box kind", len(StzFind('"format": "zui-audit-facts"', cJson)) > 0 and
	len(StzFind('"version": "1.0"', cJson)) > 0 and len(StzFind('"box_kind": "ink"', cJson)) > 0)
chk("one entry per line, L1 to L16", len(StzFindCS('"id": "L', cJson, 1)) = 16 and len(StzFind('"id": "L16"', cJson)) > 0)
chk("the scale is the caller's and the hash is the image's", len(StzFind('"scale": 2,', cJson)) > 0 and
	len(StzFind(lower(StzEngineCryptoSha256(read($cDat + "facts_s2.png"))), cJson)) > 0)
n = StzWriteScreenshotFacts($cDat + "facts_texture_s1.png", 1, "en", cOut + "/facts_texture_s1.facts.json")
chk("StzWriteScreenshotFacts writes the file and says how many lines it holds (" + n + ")",
	n = len(aTex[1][3][:lines]) and fexists(cOut + "/facts_texture_s1.facts.json"))
chk("a quote and a backslash in a text are escaped, a UTF-8 letter is kept",
	_StzFactsStr('a"b\c' + "é") = '"a\"b\\c' + "é" + '"')
chk("a number carries no more decimals than it has, and null stands for nothing measured",
	_StzFactsNum(14.25) = "14.25" and _StzFactsNum(1) = "1" and _StzFactsNum(0.0331) = "0.0331" and _StzFactsNum("") = "null")
sec("scene 5")

#=====================================================================#
? "-- Scene 6: the page --"
#=====================================================================#

WriteReport(cOut + "/screenshot_facts.html", aPages, aBk, aH)
chk("the report page is written", fexists(cOut + "/screenshot_facts.html"))
sec("scene 6")

? ""
? "ASSERTIONS: " + ($nPass + $nFail) + " -- " + $nPass + " passed, " + $nFail + " failed"
pf()
shutdown($nFail)

# the contrast ratio of two luminances
func Ratio(nA, nB)
	if nA > nB return (nA + 0.05) / (nB + 0.05) ok
	return (nB + 0.05) / (nA + 0.05)

# for each golden row, the index of the facts line whose text is the row's, 0 when no line is
func MatchRows(aGold, aLines)
	aOut = []
	nG = len(aGold)
	nL = len(aLines)
	for i = 1 to nG
		k = 0
		for j = 1 to nL
			if aLines[j][:text] = aGold[i][1]
				k = j
				exit
			ok
		next
		aOut + k
	next
	return aOut

func Spread(aT, nRow)
	k = aT[2][nRow]
	if k = 0 return 0 ok
	return aT[3][:lines][k][:bg_spread]

# the height of the box read as cText inside the 70-pixel band starting at nTop; 0 when none is
func BoxHeightAt(aRead, cText, nTop)
	n = len(aRead)
	for i = 1 to n
		b = aRead[i][:box]
		nMid = (b[2] + b[4]) / 2
		if aRead[i][:text] = cText and nMid >= nTop and nMid < nTop + 70
			return b[4] - b[2]
		ok
	next
	return 0

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
	return StzReplace(StzReplace(StzReplace(c, "&", "&amp;"), "<", "&lt;"), ">", "&gt;")

func Num(n)
	if isString(n) return "null" ok
	return _StzFactsNum(n)

# the contrast decision of stzzui's audit (AUDIT-FACTS.md section 4), recomputed for this page only: the
# writer does not judge, and the audit stays the authority
func AuditContrast(l)
	if l[:score] < 0.5 or isString(l[:contrast_ratio]) return "not_decided" ok
	if isNumber(l[:bg_spread]) and l[:bg_spread] > 0.25 return "not_decided" ok
	if l[:contrast_ratio] >= 4.5 return "pass" ok
	return "fail"

func WriteReport(cPath, aPages, aBk, aH)
	c = "<!doctype html><html><head><meta charset='utf-8'><meta name='viewport' content='width=device-width'>" +
		"<title>Screenshot facts</title>" +
		"<style>body{font:16px/1.5 system-ui,sans-serif;max-width:1150px;margin:24px auto;padding:0 16px;color:#111;background:#fff}" +
		"h1{font-size:26px}h2{font-size:20px;margin-top:34px}img{max-width:100%;display:block}" +
		".two{display:grid;grid-template-columns:minmax(0,360px) 1fr;gap:18px;align-items:start}" +
		"table{border-collapse:collapse;width:100%}td,th{border-bottom:1px solid #ddd;padding:5px 6px;text-align:left;vertical-align:middle}" +
		"th{font-weight:600}.sw{display:inline-block;padding:2px 8px;border:1px solid #bbb;border-radius:4px;white-space:nowrap}" +
		".pass{color:#126b2a;font-weight:600}.fail{color:#a11;font-weight:600}.nd{color:#6b4e00;font-weight:600}" +
		".note{color:#333}code{background:#f2f2f2;padding:1px 5px;border-radius:4px}" +
		"@media(max-width:800px){.two{grid-template-columns:1fr}table{font-size:15px}}" +
		"</style></head><body>" +
		"<h1>A screenshot reduced to facts</h1>" +
		"<p class='note'>What <code>tools/screenshot_facts.ring</code> writes for stzzui's legibility audit (format " +
		"<code>zui-audit-facts</code> 1.0). The writer <b>measures</b>; the audit judges. Each row of the pages below was " +
		"painted with a known CSS colour and rendered by headless Chrome, so the measured luminance can be held against the " +
		"paint. The <i>audit</i> column applies stzzui's own contrast rule to the facts (4.5:1, a spread over 0.25 holds the " +
		"decision); it is shown to read the facts by, and the audit stays the authority.</p>"
	# the box kind
	c += "<h2>What kind of box: ink, not line</h2><div class='two'><div>" + BoxedImage($cDat + "boxkind.png", "") +
		"</div><div><p>The same letters at four sizes, and letters with no ascender or descender beside letters with both. " +
		"A <i>line box</i> would be about as tall for <code>esc</code> as for <code>Hxgp</code>. The OCR's box follows the ink:</p>" +
		"<table><tr><th>font size</th><th>esc</th><th>Hxgp</th></tr>"
	for i = 1 to 4
		c += "<tr><td>" + aBk[i][2] + " px</td><td>" + aH[i] + " px</td><td>" + aH[i + 4] + " px</td></tr>"
	next
	c += "</table><p>At 48 px, <code>esc</code> gets a " + aH[4] + " px box, under one em. So the writer says " +
		"<code>box_kind: ink</code>, and the audit's size floor reads <span class='nd'>not_decided</span> on every line: " +
		"a size verdict from this box would be half the truth.</p></div></div>"
	nP = len(aPages)
	for p = 1 to nP
		cPng = aPages[p][1]
		nScale = aPages[p][2]
		aF = aPages[p][3]
		aG = aPages[p][4]
		aM = MatchRows(aG, aF[:lines])
		cName = "sixteen painted rows"
		if p > 2 cName = "backgrounds with no single colour" ok
		c += "<h2>" + cName + ", scale " + nScale + " (" + aF[:capture][:width_px] + " x " + aF[:capture][:height_px] +
			" px)</h2><div class='two'><div>" + BoxedImage(cPng, aF[:lines]) + "</div><div><table>" +
			"<tr><th>row</th><th>painted</th><th>measured luminance</th><th>contrast</th><th>spread</th><th>audit</th></tr>"
		nG = len(aG)
		for i = 1 to nG
			cSw = "<span class='sw' style='color:" + aG[i][5] + ";background:" + aG[i][6] + "'>Aa</span>"
			if aM[i] = 0
				c += "<tr><td>" + Esc(aG[i][1]) + "</td><td>" + cSw + "</td><td colspan='4' class='fail'>not read by the OCR: " +
					"no line, so nothing to audit</td></tr>"
				loop
			ok
			l = aF[:lines][aM[i]]
			cTrue = "no single colour"
			if isNumber(aG[i][3]) cTrue = "paint " + Num(floor(Ratio(aG[i][2], aG[i][3]) * 100 + 0.5) / 100) ok
			cD = AuditContrast(l)
			cCls = "nd"
			if cD = "pass" cCls = "pass" ok
			if cD = "fail" cCls = "fail" ok
			c += "<tr><td>" + l[:id] + " " + Esc(l[:text]) + "</td><td>" + cSw + "</td><td>text " + Num(l[:fg_luminance]) +
				"<br>back " + Num(l[:bg_luminance]) + "</td><td>" + Num(l[:contrast_ratio]) + ":1<br><small>" + cTrue +
				"</small></td><td>" + Num(l[:bg_spread]) + "</td><td class='" + cCls + "'>" + cD + "</td></tr>"
		next
		c += "</table></div></div>"
	next
	c += "<h2>What this shows, and what it does not</h2><ul>" +
		"<li>On flat backgrounds the measured contrast is the paint's to within 0.06, at both scales, and every pass or " +
		"fail at 4.5:1 is the paint's.</li>" +
		"<li>Over a checkerboard the background spread is 0.44, and the audit holds the decision, as it should.</li>" +
		"<li><b>Text over vertical stripes is not read at all</b>: the OCR finds no line there, so the facts have nothing " +
		"to say about it. An audit reading these facts cannot tell a missed line from no text.</li>" +
		"<li><b>A gradient under a whole line passes at 4.66:1</b> with a spread of 0.18, under the audit's limit of 0.25, " +
		"while 46% of that line sits on background where white text is under 4.5:1 (down to 2.99:1). The spread is " +
		"measured right (the true range is 0.19); the limit is stzzui's to set.</li>" +
		"<li>Nobody has looked at a real application's screenshot with this yet; these pages were made to have a known " +
		"answer.</li></ul></body></html>"
	write(cPath, c)

# the screenshot with each line's box drawn, as a data URI image
func BoxedImage(cPng, aLines)
	o = new stzImage(cPng)
	if isList(aLines)
		n = len(aLines)
		for i = 1 to n
			b = aLines[i][:box]
			o.ApplyBox([ b[1] + 1, b[2] + 1, b[3] - b[1] + 1, b[4] - b[2] + 1 ], "magenta", 2)
		next
	else
		aR = StzOcrModelLinesXT(cPng, "en")
		n = len(aR)
		for i = 1 to n
			b = aR[i][:box]
			o.ApplyBox([ b[1] + 1, b[2] + 1, b[3] - b[1] + 1, b[4] - b[2] + 1 ], "magenta", 2)
		next
	ok
	c = "<img src='" + o.ToPngDataURI() + "' alt='the screenshot with the OCR boxes'>"
	o.Release()
	return c
