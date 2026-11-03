# A TIFF READ WITHOUT A TIFF LIBRARY -- IM9b (2 of 3: baseline TIFF), narrated
#
# SOFTANZA_IMAGE_INTELLIGENCE.md IM9b. stb_image does not read TIFF, and TIFF is what a scanner, a fax gateway and a
# camera's lossless mode hand over. The engine reads the baseline itself (engine/src/tiff_decode.zig, no download):
# striped, one plane, 8 bits, uncompressed / PackBits / LZW / Deflate, with the horizontal predictor, gray, gray+alpha,
# RGB, RGBA and palette, in either byte order. What it does not read it REFUSES BY NAME.
#
#   Scene 1  every mode in every codec Pillow writes: PIXEL-EXACT against what Pillow (libtiff) reads
#   Scene 2  the hard cases: an LZW table that fills and resets, a big-endian file, WhiteIsZero
#   Scene 3  the Orientation tag of a TIFF is applied like a JPEG's
#   Scene 4  refusals: 16 bits, CMYK and tiles are refused, naming what the file has
#   Scene 5  what a person looks at: every fixture, ours beside Pillow's, and what was refused
#
# THE ORACLE is Pillow/libtiff, which wrote the files and read them back (_rig/tiff_make.py). Lossless: no tolerance.
# NEEDS D:/GitHub/_wti_models_src/tiff and the engine built with IM9b. HELPERS LIVE AFTER pf().

load "../../stzBase.ring"

$nPass = 0
$nFail = 0
$nSec = clock()
$cFx = "D:/GitHub/_wti_models_src/tiff/"
$aRows = []

cOut = StzReplace(WorkingDirectory(), "\", "/") + "/_tiff-out"
if NOT StzDirExists(cOut)
	StzDirCreatePath(cOut)
ok

if NOT fexists($cFx + "t_RGB_lzw.tif")
	? "NOT RUN: the fixtures in " + $cFx + " (python base/test/image/_rig/tiff_make.py " + $cFx + ")"
	shutdown(0)
ok

aModes = [ "L", "RGB", "RGBA", "LA", "P" ]
aCodecs = [ "raw", "packbits", "lzw", "deflate", "lzw_pred2", "deflate_pred2" ]

? "-- Scene 1: every mode in every codec, pixel-exact against Pillow --"
nM = len(aModes)
nC = len(aCodecs)
nRead = 0
for i = 1 to nM
	for j = 1 to nC
		cName = "t_" + aModes[i] + "_" + aCodecs[j]
		if fexists($cFx + cName + ".tif")
			Compare(cName, cName + ".tif", cName + "_exp.png")
			nRead++
		ok
	next
next
chk("all " + (nM * nC) + " mode and codec fixtures were present and compared", nRead = nM * nC)
sec("scene 1")

? "-- Scene 2: the hard cases --"
Compare("big_lzw: 300 x 200, many strips, the LZW table fills and resets", "big_lzw.tif", "big_lzw_exp.png")
Compare("be_rgb: big-endian", "be_rgb.tif", "be_rgb_exp.png")
Compare("wiz_gray: WhiteIsZero (0 is white)", "wiz_gray.tif", "wiz_gray_exp.png")
sec("scene 2")

? "-- Scene 3: the Orientation tag of a TIFF --"
oRaw = StzImageRawQ($cFx + "o6.tif")
oUp = StzImageQ($cFx + "o6.tif")
oExp = StzImageRawQ($cFx + "o6_exp.png")
chk("o6.tif: the tag says 6, a raw load is 97 x 41 and is not turned", oRaw.StoredOrientation() = 6 and oRaw.Width() = 97 and oRaw.Height() = 41 and oRaw.IsOrientationApplied() = 0)
chk("o6.tif: the load is upright (41 x 97) and every pixel equals Pillow's exif_transpose",
	oUp.Width() = 41 and oUp.Height() = 97 and oUp.IsOrientationApplied() = 1 and oUp.Pixels() = oExp.Pixels())
oRaw.Release()
oUp.Release()
oExp.Release()
sec("scene 3")

? "-- Scene 4: refusals, by name --"
Refused("bad_16bit.tif", "16 bits")
Refused("bad_cmyk.tif", "CMYK")
Refused("bad_tiled.tif", "tiles")
nBefore = StzImagesAlive()
cJunk = "II" + char(42) + char(0) + char(8) + char(0) + char(0) + char(0) + "garbage"
bRaised = 0
try
	StzImageFromBytes(cJunk)
catch
	bRaised = 1
done
chk("a TIFF header over garbage is refused, not crashed on, and leaks no image", bRaised = 1 and StzImagesAlive() = nBefore)
sec("scene 4")

? "-- Scene 5: what a person looks at --"
WritePage(cOut + "/tiff.html")
chk("the page is written", fexists(cOut + "/tiff.html"))
sec("scene 5")

? ""
? "ASSERTIONS: " + ($nPass + $nFail) + " -- " + $nPass + " passed, " + $nFail + " failed"
pf()
shutdown($nFail)

func Compare(cLabel, cFile, cExp)
	oU = StzImageQ($cFx + cFile)
	oE = StzImageRawQ($cFx + cExp)
	bOk = oU.Width() = oE.Width() and oU.Height() = oE.Height() and oU.Channels() = oE.Channels() and oU.Pixels() = oE.Pixels()
	chk(cLabel + ": " + oU.Width() + " x " + oU.Height() + ", " + oU.Channels() + " channel(s), every byte equal to Pillow's", bOk)
	add($aRows, [ cFile, cExp, cLabel, bOk ])
	oU.Release()
	oE.Release()

func Refused(cFile, cWord)
	nB = StzImagesAlive()
	bRaised = 0
	cWhy = ""
	try
		oX = StzImageQ($cFx + cFile)
		oX.Release()
	catch
		bRaised = 1
		cWhy = cCatchError
	done
	chk(cFile + " is refused, and the reason names '" + cWord + "'", bRaised = 1 and len(StzFind(cWord, cWhy)) > 0 and StzImagesAlive() = nB)
	if bRaised = 1
		? "      the reason: " + cWhy
	ok

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

# each fixture: what the engine reads from the TIFF, beside what Pillow read from it
func WritePage(cPath)
	c = "<!doctype html><html lang='en'><head><meta charset='utf-8'><meta name='viewport' content='width=device-width,initial-scale=1'>" +
		"<title>TIFF read natively</title><style>" +
		":root{--bg:#fff;--fg:#1c1c1e;--mut:#6b6b70;--line:#d8d8dc;--ok:#1a7f37}" +
		"@media (prefers-color-scheme:dark){:root{--bg:#161618;--fg:#ececf0;--mut:#9a9aa2;--line:#3a3a40;--ok:#4cc26a}}" +
		"body{margin:0;background:var(--bg);color:var(--fg);font:16px/1.5 system-ui,Segoe UI,sans-serif}main{max-width:1100px;margin:0 auto;padding:16px}" +
		"h1{font-size:1.5rem;margin:.3em 0}p.sub{color:var(--mut)}.g{display:grid;grid-template-columns:repeat(auto-fill,minmax(230px,1fr));gap:12px}" +
		".c{border:1px solid var(--line);border-radius:8px;padding:8px}.c img{image-rendering:pixelated;width:100%;height:auto;display:block;" +
		"background:repeating-conic-gradient(#ccc 0 25%,#fff 0 50%) 0 0/12px 12px}.c p{margin:.3em 0 0;font-size:.82rem;color:var(--mut)}" +
		".ok{color:var(--ok);font-weight:600}</style></head><body><main>" +
		"<h1>TIFF, read without a TIFF library</h1><p class='sub'>Each tile is what the engine reads from one TIFF, " +
		"labelled with its mode and codec. Every one is byte-equal to what Pillow (libtiff) reads from the same file; the guard asserts it. " +
		"(The checkerboard shows through where a file has an alpha channel.)</p><div class='g'>"
	n = len($aRows)
	for i = 1 to n
		o = StzImageQ($cFx + $aRows[i][1])
		c += "<div class='c'><img src='" + o.ToPngDataURI() + "' alt='" + Esc($aRows[i][1]) + "'><p><span class='ok'>" +
			"equal</span> " + Esc($aRows[i][3]) + "</p></div>"
		o.Release()
	next
	c += "</div></main></body></html>"
	write(cPath, c)
