# A PHONE'S PHOTO IS STORED SIDEWAYS -- IM9b (1 of 3: orientation and GPS), narrated
#
# SOFTANZA_IMAGE_INTELLIGENCE.md IM9b. A phone stores the pixels as the sensor saw them and writes a tag
# (EXIF orientation, 1 to 8) saying how to turn them; every viewer turns them. The loader did not, so a
# portrait photo reached every model on its side. The gap never showed because none of the 122 test JPEGs
# carries the tag. Now: decode turns the pixels upright (a raw load keeps them as stored), the tag is read from a
# JPEG's APP1 segment, a PNG's eXIf chunk or a TIFF's first directory, and a save writes the pixels and nothing else,
# so GPS never leaves with a saved file.
#
#   Scene 1  the tag is read, and a raw load leaves the pixels alone
#   Scene 2  PNG carriers: upright by the library, PIXEL-EXACT against Pillow's ImageOps.exif_transpose
#   Scene 3  JPEG carriers: upright, and the nearest of Pillow's eight uprights is its own (two decoders differ by a rounding)
#   Scene 4  a file with no tag is untouched; a save then reload does not turn a picture twice
#   Scene 5  GPS: the fixture carries it, a saved JPEG, PNG and BMP do not (the bytes are read)
#   Scene 6  what a person looks at: the eight orientations, stored and upright, beside Pillow's
#
# THE ORACLE is Pillow, a library that is not ours (_rig/exif_make.py writes the fixtures). NEEDS D:/GitHub/_wti_models_src/exif
# (python _rig/exif_make.py <dir>) and the engine built with IM9b. When absent, the guard says so. HELPERS LIVE AFTER pf().

load "../../stzBase.ring"

$nPass = 0
$nFail = 0
$nSec = clock()
$cFx = "D:/GitHub/_wti_models_src/exif/"
$nTolMean = 0.8
$nTolMax = 8

cOut = StzReplace(WorkingDirectory(), "\", "/") + "/_exif-out"
if NOT StzDirExists(cOut)
	StzDirCreatePath(cOut)
ok

if NOT fexists($cFx + "o1.png") or NOT fexists($cFx + "gps.jpg")
	? "NOT RUN: the fixtures in " + $cFx + " (python base/test/image/_rig/exif_make.py " + $cFx + ")"
	shutdown(0)
ok

? "-- Scene 1: the tag is read; a raw load leaves the pixels alone --"
oBase = StzImageRawQ($cFx + "o1.png")
cBase = oBase.Pixels()
for n = 1 to 8
	oP = StzImageRawQ($cFx + "o" + n + ".png")
	oJ = StzImageRawQ($cFx + "o" + n + ".jpg")
	chk("o" + n + ": the PNG's eXIf chunk says " + n + " and the JPEG's APP1 segment says " + n,
		oP.StoredOrientation() = n and oJ.StoredOrientation() = n)
	chk("o" + n + ": a raw load is 61 x 37, as stored, nothing applied, the pixels of o1",
		oP.Width() = 61 and oP.Height() = 37 and oP.IsOrientationApplied() = 0 and oP.Pixels() = cBase and oJ.Width() = 61 and oJ.Height() = 37)
	oP.Release()
	oJ.Release()
next
sec("scene 1")

? "-- Scene 2: PNG carriers, upright, pixel-exact against Pillow --"
for n = 1 to 8
	oU = StzImageQ($cFx + "o" + n + ".png")
	oE = StzImageRawQ($cFx + "o" + n + "_up.png")
	bSame = oU.Width() = oE.Width() and oU.Height() = oE.Height() and oU.Pixels() = oE.Pixels()
	chk("o" + n + ": upright " + oU.Width() + " x " + oU.Height() + ", every pixel equal to Pillow's exif_transpose", bSame)
	chk("o" + n + ": it says what it did (stored " + oU.StoredOrientation() + ", applied " + oU.IsOrientationApplied() + ")",
		oU.StoredOrientation() = n and oU.IsOrientationApplied() = (n > 1))
	oU.Release()
	oE.Release()
next
sec("scene 2")

? "-- Scene 3: JPEG carriers, upright --"
nWorstMean = 0
nWorstMax = 0
for n = 1 to 8
	oU = StzImageQ($cFx + "o" + n + ".jpg")
	aD = DiffAgainst(oU, n)
	nBest = aD[1]
	nMean = aD[2]
	nMax = aD[3]
	if nMean > nWorstMean nWorstMean = nMean ok
	if nMax > nWorstMax nWorstMax = nMax ok
	chk("o" + n + ": the nearest of Pillow's uprights is its own (nearest " + nBest + "), mean difference " + nMean + ", largest " + nMax,
		nBest = n and nMean <= $nTolMean and nMax <= $nTolMax)
	oU.Release()
next
? "    (the bars: mean <= " + $nTolMean + ", largest <= " + $nTolMax + "; the worst measured: mean " + nWorstMean + ", largest " + nWorstMax + ")"
sec("scene 3")

? "-- Scene 4: no tag, no change; a save and reload does not turn a picture twice --"
cStreet = "D:/GitHub/_wti_models_src/photos/street.jpg"
if fexists(cStreet)
	oS1 = StzImageQ(cStreet)
	oS2 = StzImageRawQ(cStreet)
	chk("a photo with no tag: stored orientation 1, nothing applied, both loads give the same pixels",
		oS1.StoredOrientation() = 1 and oS1.IsOrientationApplied() = 0 and oS1.Pixels() = oS2.Pixels() and oS1.Width() = oS2.Width())
	oS1.Release()
	oS2.Release()
else
	? "  (not run: " + cStreet + " is absent)"
ok
oRes = StzImageQ($cFx + "o6.png")
oRes.SaveAs(cOut + "/o6_resaved.png")
oR2 = StzImageQ(cOut + "/o6_resaved.png")
oE6 = StzImageRawQ($cFx + "o6_up.png")
chk("o6 saved and loaded again: orientation 1, and the pixels are still Pillow's upright (not turned twice)",
	oR2.StoredOrientation() = 1 and oR2.IsOrientationApplied() = 0 and oR2.Pixels() = oE6.Pixels() and oR2.Height() = 61)
oRes.Release()
oR2.Release()
oE6.Release()
cBytes = read($cFx + "o8.png")
oB = StzImageFromBytes(cBytes)
oBR = StzImageFromBytesRaw(cBytes)
chk("from bytes: StzImageFromBytes is upright (37 x 61) and StzImageFromBytesRaw is as stored (61 x 37)",
	oB.Width() = 37 and oB.Height() = 61 and oBR.Width() = 61 and oBR.Height() = 37 and oB.StoredOrientation() = 8 and oBR.StoredOrientation() = 8)
oB.Release()
oBR.Release()
sec("scene 4")

? "-- Scene 5: GPS stays behind --"
cG = read($cFx + "gps.jpg")
cGp = read($cFx + "gps.png")
chk("the fixtures DO carry metadata: the JPEG has an Exif segment, the PNG an eXIf chunk",
	HasBytes("Exif", cG) and HasBytes("eXIf", cGp))
oG = StzImageQ($cFx + "gps.jpg")
oG.SaveAsJpeg(cOut + "/gps_saved.jpg", 90)
oG.SaveAs(cOut + "/gps_saved.png")
oG.SaveAs(cOut + "/gps_saved.bmp")
cSj = read(cOut + "/gps_saved.jpg")
cSp = read(cOut + "/gps_saved.png")
cSb = read(cOut + "/gps_saved.bmp")
chk("the saved JPEG has no Exif segment and no APP1 marker (FF E1) anywhere in its headers", NOT HasBytes("Exif", cSj) and NOT HasBytes(char(255) + char(225), left(cSj, 400)))
chk("the saved PNG has no eXIf chunk", NOT HasBytes("eXIf", cSp))
chk("the saved BMP is the pixels and a header", NOT HasBytes("Exif", cSb))
oG2 = StzImageQ(cOut + "/gps_saved.png")
chk("what was saved is the same picture (" + oG.Width() + " x " + oG.Height() + ", pixel-equal through PNG)", oG2.Pixels() = oG.Pixels())
oG.Release()
oG2.Release()
sec("scene 5")

? "-- Scene 6: what a person looks at --"
WritePage(cOut + "/orientation.html")
chk("the page is written", fexists(cOut + "/orientation.html"))
sec("scene 6")

? ""
? "ASSERTIONS: " + ($nPass + $nFail) + " -- " + $nPass + " passed, " + $nFail + " failed"
pf()
shutdown($nFail)

# [ the best-matching orientation among Pillow's uprights of the same size, the mean difference to orientation n's, its largest ]
func DiffAgainst(oU, n)
	cMine = oU.Pixels()
	nBest = 0
	nBestMean = 1000000
	nMean = 0
	nMax = 0
	for k = 1 to 8
		oE = StzImageRawQ($cFx + "o" + k + "_jpg_up.png")
		cE = oE.Pixels()
		if len(cE) = len(cMine) and oE.Width() = oU.Width()
			aD = PixDiff(cMine, cE)
			if aD[1] < nBestMean
				nBestMean = aD[1]
				nBest = k
			ok
			if k = n
				nMean = aD[1]
				nMax = aD[2]
			ok
		ok
		oE.Release()
	next
	return [ nBest, nMean, nMax ]

# [ the mean absolute difference per byte, the largest ]
func PixDiff(cA, cB)
	nL = len(cA)
	nSum = 0
	nMx = 0
	for i = 1 to nL
		d = ascii(cA[i]) - ascii(cB[i])
		if d < 0 d = -d ok
		nSum += d
		if d > nMx nMx = d ok
	next
	return [ floor(nSum * 1000 / nL) / 1000, nMx ]

func Has(cNeedle, cHay)
	return len(StzFind(cNeedle, "" + cHay)) > 0

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

func Tile(cPath, bUpright, cCap)
	if bUpright = 1
		o = StzImageQ(cPath)
	else
		o = StzImageRawQ(cPath)
	ok
	c = "<figure><img src='" + o.ToPngDataURI() + "' width='" + (o.Width() * 3) + "' alt='" + cCap + "'><figcaption>" + cCap + "</figcaption></figure>"
	o.Release()
	return c

# the eight orientations: as stored, upright by the library, upright by Pillow
func WritePage(cPath)
	c = "<!doctype html><html lang='en'><head><meta charset='utf-8'><meta name='viewport' content='width=device-width,initial-scale=1'>" +
		"<title>EXIF orientation</title><style>" +
		":root{--bg:#fff;--fg:#1c1c1e;--mut:#6b6b70;--line:#d8d8dc;--ok:#1a7f37}" +
		"@media (prefers-color-scheme:dark){:root{--bg:#161618;--fg:#ececf0;--mut:#9a9aa2;--line:#3a3a40;--ok:#4cc26a}}" +
		"body{margin:0;background:var(--bg);color:var(--fg);font:16px/1.5 system-ui,Segoe UI,sans-serif}main{max-width:1100px;margin:0 auto;padding:16px}" +
		"h1{font-size:1.5rem;margin:.3em 0}p.sub{color:var(--mut)}.row{display:grid;grid-template-columns:5rem repeat(3,1fr);gap:12px;align-items:end;" +
		"padding:10px 0;border-bottom:1px solid var(--line)}.row b{font-size:1.4rem}figure{margin:0}img{image-rendering:pixelated;max-width:100%;height:auto;border:1px solid var(--line)}" +
		"figcaption{color:var(--mut);font-size:.85rem}.ok{color:var(--ok)}</style></head><body><main>" +
		"<h1>A photo stored sideways, turned upright</h1><p class='sub'>One 61 x 37 picture, with a white block top-left and a black block bottom-right, " +
		"stored under each of the eight EXIF orientations. Left: the pixels as the file stores them. Middle: what the library's load now gives. " +
		"Right: what Pillow's <code>exif_transpose</code> gives. Middle and right are pixel-identical for every PNG (the guard asserts it); " +
		"the white block lands where Pillow puts it, so the two columns look the same in every row.</p>"
	for n = 1 to 8
		c += "<div class='row'><b>" + n + "</b>" + Tile($cFx + "o" + n + ".png", 0, "stored, tag " + n) +
			Tile($cFx + "o" + n + ".png", 1, "the library, upright") + Tile($cFx + "o" + n + "_up.png", 0, "Pillow, upright") + "</div>"
	next
	c += "</main></body></html>"
	write(cPath, c)

# a search that is safe in BYTES (a JPEG holds 0xFF and NUL): Ring's substr, not the engine's codepoint find
func HasBytes(cNeedle, cHay)
	return substr(cHay, cNeedle) > 0
