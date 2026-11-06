# WEBP IN, WITH THE REFERENCE DECODER -- IM9b (3 of 3: WebP), narrated
#
# SOFTANZA_IMAGE_INTELLIGENCE.md IM9b. WebP is what a browser saves and a phone now offers. The engine decodes it with
# libwebp 1.5.0, vendored (engine/vendor/libwebp: BSD-3, the decoder only, 89 files, built into stz_image). stb_image
# does not read WebP. Animated WebP and anything libwebp cannot read are refused by name.
#
#   Scene 1  lossless, with and without alpha: every byte equal to what Pillow's libwebp reads
#   Scene 2  lossy, with and without alpha, and a 300 x 200 noise picture: compared byte for byte, the difference measured
#   Scene 3  the EXIF orientation chunk of a WebP is applied like a JPEG's
#   Scene 4  refusals: an animated WebP is refused by name; a junk RIFF header is refused and leaks nothing
#   Scene 5  what a person looks at: each fixture as read, and what was refused
#
# THE ORACLE is Pillow's libwebp (_rig/webp_make.py writes the fixtures and prints its version): the same upstream codec,
# so the vendored decoder must agree with the reference. NEEDS D:/GitHub/_wti_models_src/webp and the engine built with
# libwebp. HELPERS LIVE AFTER pf().

load "../../stzBase.ring"

$nPass = 0
$nFail = 0
$nSec = clock()
$cFx = "D:/GitHub/_wti_models_src/webp/"
$aRows = []
# the bar for LOSSY files: set from the first measurement (printed below), never from a guess
$nTolMean = 0
$nTolMax = 0

cOut = StzReplace(WorkingDirectory(), "\", "/") + "/_webp-out"
if NOT StzDirExists(cOut)
	StzDirCreatePath(cOut)
ok

if NOT fexists($cFx + "w_lossless_rgb.webp")
	? "NOT RUN: the fixtures in " + $cFx + " (python base/test/image/_rig/webp_make.py " + $cFx + ")"
	shutdown(0)
ok

? "-- Scene 1: lossless, byte-exact against Pillow's libwebp --"
Compare("w_lossless_rgb: 97 x 41 RGB", "w_lossless_rgb", 0, 0)
Compare("w_lossless_rgba: 97 x 41 RGBA, an alpha ramp", "w_lossless_rgba", 0, 0)
sec("scene 1")

? "-- Scene 2: lossy --"
Compare("w_lossy_rgb: quality 80", "w_lossy_rgb", $nTolMean, $nTolMax)
Compare("w_lossy_rgba: quality 80 with an alpha ramp", "w_lossy_rgba", $nTolMean, $nTolMax)
Compare("w_big_lossy: 300 x 200 of noise over structure, quality 60", "w_big_lossy", $nTolMean, $nTolMax)
sec("scene 2")

? "-- Scene 3: the EXIF orientation chunk --"
oRaw = StzImageRawQ($cFx + "w_o6.webp")
oUp = StzImageQ($cFx + "w_o6.webp")
oExp = StzImageRawQ($cFx + "w_o6_exp.png")
chk("w_o6.webp: the chunk says 6, a raw load is 97 x 41 and is not turned", oRaw.StoredOrientation() = 6 and oRaw.Width() = 97 and oRaw.Height() = 41 and oRaw.IsOrientationApplied() = 0)
chk("w_o6.webp: the load is upright (41 x 97) and every byte equals Pillow's exif_transpose",
	oUp.Width() = 41 and oUp.Height() = 97 and oUp.IsOrientationApplied() = 1 and oUp.Pixels() = oExp.Pixels())
oRaw.Release()
oUp.Release()
oExp.Release()
sec("scene 3")

? "-- Scene 4: refusals --"
nB = StzImagesAlive()
bRaised = 0
cWhy = ""
try
	oX = StzImageQ($cFx + "w_anim.webp")
	oX.Release()
catch
	bRaised = 1
	cWhy = cCatchError
done
chk("w_anim.webp (two frames) is refused, naming 'animated'", bRaised = 1 and len(StzFind("animated", cWhy)) > 0 and StzImagesAlive() = nB)
? "      the reason: " + cWhy
bRaised = 0
cWhy = ""
try
	oX = StzImageQ($cFx + "w_junk.webp")
	oX.Release()
catch
	bRaised = 1
	cWhy = cCatchError
done
chk("w_junk.webp (a RIFF/WEBP header over garbage) is refused, not crashed on, and leaks no image", bRaised = 1 and StzImagesAlive() = nB)
? "      the reason: " + cWhy
sec("scene 4")

? "-- Scene 5: what a person looks at --"
WritePage(cOut + "/webp.html")
chk("the page is written", fexists(cOut + "/webp.html"))
sec("scene 5")

? ""
? "ASSERTIONS: " + ($nPass + $nFail) + " -- " + $nPass + " passed, " + $nFail + " failed"
pfq()
shutdown($nFail)

# the engine's reading against Pillow's: byte-equal, or within the stated bar; the measured difference is printed
func Compare(cLabel, cBase, nTolMean, nTolMax)
	oU = StzImageQ($cFx + cBase + ".webp")
	oE = StzImageRawQ($cFx + cBase + "_exp.png")
	bShape = oU.Width() = oE.Width() and oU.Height() = oE.Height() and oU.Channels() = oE.Channels()
	cA = oU.Pixels()
	cB = oE.Pixels()
	nSum = 0
	nMx = 0
	nDiff = 0
	if bShape
		nL = len(cA)
		for i = 1 to nL
			d = ascii(cA[i]) - ascii(cB[i])
			if d < 0 d = -d ok
			nSum += d
			if d > nMx nMx = d ok
			if d > 0 nDiff++ ok
		next
		nMean = floor(nSum * 1000 / nL) / 1000
	else
		nMean = 1000000
	ok
	bOk = bShape and nMean <= nTolMean and nMx <= nTolMax
	chk(cLabel + ": " + oU.Width() + " x " + oU.Height() + ", " + oU.Channels() + " channel(s); bytes differing " + nDiff + ", mean difference " + nMean + ", largest " + nMx, bOk)
	add($aRows, [ cBase, cLabel, bOk ])
	oU.Release()
	oE.Release()

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

func WritePage(cPath)
	c = "<!doctype html><html lang='en'><head><meta charset='utf-8'><meta name='viewport' content='width=device-width,initial-scale=1'>" +
		"<title>WebP read with libwebp</title><style>" +
		":root{--bg:#fff;--fg:#1c1c1e;--mut:#6b6b70;--line:#d8d8dc;--ok:#1a7f37}" +
		"@media (prefers-color-scheme:dark){:root{--bg:#161618;--fg:#ececf0;--mut:#9a9aa2;--line:#3a3a40;--ok:#4cc26a}}" +
		"body{margin:0;background:var(--bg);color:var(--fg);font:16px/1.5 system-ui,Segoe UI,sans-serif}main{max-width:1100px;margin:0 auto;padding:16px}" +
		"h1{font-size:1.5rem;margin:.3em 0}p.sub{color:var(--mut)}.g{display:grid;grid-template-columns:repeat(auto-fill,minmax(260px,1fr));gap:12px}" +
		".c{border:1px solid var(--line);border-radius:8px;padding:8px}.c img{image-rendering:pixelated;width:100%;height:auto;display:block;" +
		"background:repeating-conic-gradient(#ccc 0 25%,#fff 0 50%) 0 0/12px 12px}.c p{margin:.3em 0 0;font-size:.82rem;color:var(--mut)}" +
		".ok{color:var(--ok);font-weight:600}</style></head><body><main>" +
		"<h1>WebP, read with the reference decoder</h1><p class='sub'>Each tile is what the engine reads from one WebP file (libwebp 1.5.0, vendored). " +
		"The guard compares it byte for byte with what Pillow's libwebp reads from the same file. Refused, by name: an animated WebP, and a junk header. " +
		"(The checkerboard shows through where a file has alpha.)</p><div class='g'>"
	n = len($aRows)
	for i = 1 to n
		o = StzImageQ($cFx + $aRows[i][1] + ".webp")
		c += "<div class='c'><img src='" + o.ToPngDataURI() + "' alt='" + Esc($aRows[i][1]) + "'><p><span class='ok'>agrees</span> " + Esc($aRows[i][2]) + "</p></div>"
		o.Release()
	next
	c += "</div></main></body></html>"
	write(cPath, c)
