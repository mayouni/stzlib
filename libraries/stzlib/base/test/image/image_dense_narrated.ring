# EVERY PIXEL ANSWERS -- IM6, narrated
#
# SOFTANZA_IMAGE_INTELLIGENCE.md IM6: two dense models converted from ONNX by
# engine/tools/onnx_to_gguf.py and run on ggml by stz_neural, each pixel
# getting an answer instead of the picture getting one:
#
#   Scene 1  parity: U2-Net-p and Depth-Anything-V2-Small against onnxruntime,
#            and end to end against rembg's and HF's own pipelines
#   Scene 2  SalientMask(), BackgroundRemoved(), ApplyBackgroundRemoval()
#   Scene 3  DepthMap(): relative depth as a grid of numbers
#   Scene 4  :foreground -- the classical mask against U2-Net-p, judged by COCO
#   Scene 5  the door
#   Scene 6  what a person looks at: an HTML page
#
# NEEDS what the tree does not carry: the models in models/vision, the
# photographs, the COCO images and masks, the parity fixtures. When absent,
# the guard says which and stops. THE HELPERS LIVE AFTER pf().

load "../../stzBase.ring"
load "_court_rule.ring"
load "_golden/coco_masks_v1.ring"

$nPass = 0
$nFail = 0
$nSec = clock()
$cSrc = "D:/GitHub/_wti_models_src/"
$cPh = $cSrc + "photos/"
$cCo = $cSrc + "coco/images/"
$cMk = $cSrc + "coco/masks/"

cOut = StzReplace(WorkingDirectory(), "\", "/") + "/_dense-out"
if NOT StzDirExists(cOut)
	StzDirCreatePath(cOut)
ok

if NOT StzVisionHasModel($cStzVisionSaliencyModel) or NOT StzVisionHasModel($cStzVisionDepthModel) or
   NOT fexists($cSrc + "parity/da2_street.png") or NOT StzDirExists($cMk)
	? "NOT RUN: the IM6 models (" + StzVisionModelsDir() + "), the parity fixtures or the COCO masks are " +
		"not installed -- see models/MODELS.md"
	shutdown(1)
ok

pr()
nCalls0 = StzVisionCallsRecorded()

#=====================================================================#
? "-- Scene 1: parity --"
#=====================================================================#

decimals(6)
a = StzEngineNeuralOcrGraphParity(StzVisionModelPath($cStzVisionSaliencyModel), $cSrc + "parity/u2netp_in.stzt",
	$cSrc + "parity/u2netp_out.stzt", "", 4)
chk("U2-Net-p agrees with onnxruntime (cosine " + a[4] + ", max diff " + a[2] + ", " + a[5] + " ms)",
	len(a) = 6 and a[4] > 0.99999 and a[2] < 0.001)
a = StzEngineNeuralOcrGraphParity(StzVisionModelPath($cStzVisionDepthModel), $cSrc + "parity/da2_in.stzt",
	$cSrc + "parity/da2_out.stzt", "", 4)
chk("Depth-Anything-V2-Small agrees with onnxruntime (cosine " + a[4] + ", max diff " + a[2] + ", " + a[5] + " ms)",
	len(a) = 6 and a[4] > 0.99999 and a[2] < 0.01)
decimals(3)

aPh = [ "dog", "cat", "crew", "street" ]
nWorstIou = 1
nWorstMean = 0
for i = 1 to 4
	o = StzImageQ($cPh + aPh[i] + ".jpg")
	oM = o.SalientMask()
	oRef = StzImageQ($cSrc + "parity/u2netp_" + aPh[i] + ".png")
	nIou = StzEngineImageMaskIou(oM.Pixels(), oRef.Pixels(), 128)
	nMean = MeanLevelDiff(oM, oRef)
	if nIou < nWorstIou nWorstIou = nIou ok
	if nMean > nWorstMean nWorstMean = nMean ok
	o.Release()
	oM.Release()
	oRef.Release()
next
chk("the masks equal rembg's end to end on the four photos (worst IoU " + nWorstIou + ", worst mean difference " +
	nWorstMean + " levels of 255; the two JPEG decoders differ)", nWorstIou > 0.98 and nWorstMean < 0.5)

nWorstMean = 0
aDa = [ "dog", "street" ]
for i = 1 to 2
	o = StzImageQ($cPh + aDa[i] + ".jpg")
	oG = o.DepthMap()
	oV = oG.ToImageScaled()
	oRef = StzImageQ($cSrc + "parity/da2_" + aDa[i] + ".png")
	nMean = MeanLevelDiff(oV, oRef)
	if nMean > nWorstMean nWorstMean = nMean ok
	o.Release()
	oG.Release()
	oV.Release()
	oRef.Release()
next
chk("the depth maps equal HF's pipeline end to end (worst mean difference " + nWorstMean + " levels of 255)",
	nWorstMean < 0.5)

sec("scene 1")

#=====================================================================#
? "-- Scene 2: what stands out --"
#=====================================================================#

oDog = StzImageQ($cPh + "dog.jpg")
oMask = oDog.SalientMask()
chk("SalientMask() is a one-channel mask of the picture's size (" + oMask.Width() + " x " + oMask.Height() + ")",
	oMask.Channels() = 1 and oMask.Width() = oDog.Width() and oMask.Height() = oDog.Height())
nOn = Share(oMask, 128)
chk("...the dog takes " + floor(nOn * 100 + 0.5) + "% of the photo: neither nothing nor everything", nOn > 0.1 and nOn < 0.8)
oCut = oDog.BackgroundRemoved()
chk("BackgroundRemoved() is an RGBA copy, and the photo itself is unchanged (" + oDog.Channels() + " channels)",
	oCut.Channels() = 4 and oDog.Channels() = 3)
oCopy = StzImageFromPixels(oDog.Width(), oDog.Height(), oDog.Channels(), oDog.Pixels())
oCopy.ApplyBackgroundRemoval()
chk("ApplyBackgroundRemoval() changes the image into the same cut-out", oCopy.Channels() = 4 and
	oCopy.Pixels() = oCut.Pixels())
oCopy.Release()

sec("scene 2")

#=====================================================================#
? "-- Scene 3: DepthMap() --"
#=====================================================================#

oDepth = oDog.DepthMap()
chk("DepthMap() is a grid of the picture's rows and columns (" + oDepth.Rows() + " x " + oDepth.Columns() + ")",
	oDepth.Rows() = oDog.Height() and oDepth.Columns() = oDog.Width())
# two models, one claim: the salient dog stands in FRONT of its background
aIn = MeanInsideOutside(oDepth, oMask)
chk("...and the dog U2-Net-p finds is NEARER than its background, by Depth-Anything (" + aIn[1] + " against " +
	aIn[2] + ": larger is nearer)", aIn[1] > aIn[2])

sec("scene 3")

#=====================================================================#
? "-- Scene 4: :foreground, judged by COCO --"
#=====================================================================#
# The golden set (_rig/coco_masks.py, rules fixed before any run): 30 COCO
# images whose largest object stands alone; the truth is COCO's polygon.

aGM = []
aRaw = StzVisionGoldenMasksV1()
nG = len(aRaw)
for i = 1 to nG
	aGM + [ $cCo + aRaw[i][1], $cMk + aRaw[i][2] ]
next
StzVisionDeclare([ [ "foreground", aGM ] ])
chk("30 :foreground items, every image and mask on disk", len(StzFacultyQ(:foreground).Goldens()) = 30 and AllOnDisk(aGM))
StzRunGoldens("foreground", [])
nFC = ScoreOf("foreground", "classical")
nFU = ScoreOf("foreground", "u2netp")
? "    classical floor " + nFC + "   u2netp " + nFU + "   (share of images whose object mask is found at IoU >= 0.5)"
chk("U2-Net-p was measured on the same 30 images (" + nFU + ")", nFU >= 0)
cChosen = StzModelRegistryQ().ResolveQ("foreground").Chosen()
cRule = ByTheRule("foreground")
chk("the registry chose '" + cChosen + "' -- the rule (the court) says '" + cRule + "'", cChosen = cRule)
cRes = StzReplace(WorkingDirectory(), "\", "/") + "/results"
if NOT StzDirExists(cRes)
	StzDirCreatePath(cRes)
ok
StzSaveMeasurements(cRes + "/vision_im6.zmdl.txt")
StzSaveCourt(cRes + "/court_im6_dense.txt")

sec("scene 4")

#=====================================================================#
? "-- Scene 5: the door --"
#=====================================================================#

nCalls = StzVisionCallsRecorded() - nCalls0
# 6 parity runs + 3 masks + 1 depth + 30 golden masks; the classical floor runs no model and writes nothing
chk("every model run went through the door: " + nCalls + " ledger records for 40 model runs (the classical floor " +
	"runs no model)", nCalls = 40)
chk("...as a hash chain that verifies", StzSecurityLedgerQ().Verify()[:intact] = 1)

sec("scene 5")

#=====================================================================#
? "-- Scene 6: what a person looks at --"
#=====================================================================#

WriteReport(cOut + "/im6_dense.html", aPh, aRaw, nFC, nFU, cChosen)
chk("the report page is written", fexists(cOut + "/im6_dense.html"))
oDog.Release()
oMask.Release()
oCut.Release()
oDepth.Release()

sec("scene 6")

? ""
? "=========================================="
? "TOTAL: " + ($nPass + $nFail) + " assertions, " + $nPass + " pass, " + $nFail + " fail"
? "=========================================="

pfq()
shutdown($nFail)

func MeanLevelDiff(oA, oB)
	return oA.DifferenceWith(oB)[:mean]

func Share(oM, nLevel)
	return StzEngineImageMaskIou(oM.Pixels(), copy(char(255), oM.Width() * oM.Height()), nLevel)

func MeanInsideOutside(oGrid, oMask)
	return StzEngineImageGridMeanByMask(oGrid.GridId(), oMask.Handle(), 128)

func ScoreOf(cF, cImpl)
	a = StzMeasurementOf(cF, cImpl, "coco-v1")
	if len(a) = 0
		return -1
	ok
	return a[:score]

func ByTheRule(cF)
	# the court's rule (the default gate since 2026-11-05), restated independently in _court_rule.ring
	return CourtRuleChoice(cF, StzFacultyQ(cF).GoldenVersion())

func AllOnDisk(aItems)
	n = len(aItems)
	for i = 1 to n
		if NOT fexists(aItems[i][1]) or NOT fexists(aItems[i][2])
			return 0
		ok
	next
	return 1

func Thumb(oImg, nW, nQ)
	o = StzImageFromPixels(oImg.Width(), oImg.Height(), oImg.Channels(), oImg.Pixels())
	if o.Width() > nW
		o.ApplyResize(nW, floor(o.Height() * nW / o.Width()))
	ok
	c = ""
	if nQ = 0
		c = "<img src='" + o.ToPngDataURI() + "'>"
	else
		c = "<img src='" + o.ToJpegDataURI(nQ) + "'>"
	ok
	o.Release()
	return c

func WriteReport(cPath, aPh, aRaw, nFC, nFU, cChosen)
	c = "<!doctype html><html><head><meta charset='utf-8'><meta name='viewport' content='width=device-width'>" +
		"<title>Every pixel answers</title>" +
		"<style>body{font:16px/1.5 system-ui,sans-serif;max-width:1100px;margin:24px auto;padding:0 16px;color:#111;background:#fff}" +
		"h1{font-size:26px}h2{font-size:20px;margin-top:34px}img{max-width:100%;display:block}" +
		".row{display:grid;grid-template-columns:repeat(4,1fr);gap:8px;margin-bottom:14px}" +
		".chk{background:repeating-conic-gradient(#ccc 0 25%,#fff 0 50%) 0 0/20px 20px}" +
		".cap{font-size:15px;color:#333}.note{color:#333}.ok{color:#126b2a;font-weight:600}.no{color:#a11;font-weight:600}" +
		"code{background:#f2f2f2;padding:1px 5px;border-radius:4px}</style></head><body>" +
		"<h1>Every pixel answers (IM6)</h1>" +
		"<p class='note'>Each column: the photo, <code>SalientMask()</code> (U2-Net-p), <code>BackgroundRemoved()</code> " +
		"on a checkerboard (transparent = removed), and <code>DepthMap().ToImageScaled()</code> (Depth-Anything-V2-Small: " +
		"white is near, black is far, relative, in no unit).</p>"
	n = len(aPh)
	for i = 1 to n
		o = StzImageQ($cPh + aPh[i] + ".jpg")
		oM = o.SalientMask()
		oC = o.BackgroundRemoved()
		oG = o.DepthMap()
		oV = oG.ToImageScaled()
		c += "<div class='row'><div>" + Thumb(o, 280, 80) + "<span class='cap'>" + aPh[i] + ".jpg</span></div><div>" +
			Thumb(oM, 280, 80) + "<span class='cap'>salient mask</span></div><div class='chk'>" + Thumb(oC, 280, 0) +
			"</div><div>" + Thumb(oV, 280, 80) + "<span class='cap'>depth</span></div></div>"
		o.Release()
		oM.Release()
		oC.Release()
		oG.Release()
		oV.Release()
	next
	c += "<h2>:foreground -- judged by COCO (" + cChosen + " answers)</h2><p class='note'>30 COCO images whose largest " +
		"object stands alone; the truth is the polygon COCO's annotators drew. Found = the mask overlaps it at IoU 0.5 " +
		"or more. Classical floor (what is not the border-coloured background): <b>" + nFC + "</b>. U2-Net-p: <b>" + nFU +
		"</b>. Each row: the image, COCO's mask, the classical mask, U2-Net-p's.</p>"
	for i = 1 to 6
		o = StzImageQ($cCo + aRaw[i][1])
		oT = StzImageQ($cMk + aRaw[i][2])
		oF = o.ForegroundMask()
		oU = o.SalientMask()
		nIf = StzEngineImageMaskIou(oF.Pixels(), oT.Pixels(), 128)
		nIu = StzEngineImageMaskIou(oU.Pixels(), oT.Pixels(), 128)
		c += "<div class='row'><div>" + Thumb(o, 280, 80) + "<span class='cap'>" + aRaw[i][3] + "</span></div><div>" +
			Thumb(oT, 280, 80) + "<span class='cap'>COCO</span></div><div>" + Thumb(oF, 280, 80) + "<span class='" +
			Verdict(nIf) + "'>classical IoU " + nIf + "</span></div><div>" + Thumb(oU, 280, 80) + "<span class='" +
			Verdict(nIu) + "'>U2-Net-p IoU " + nIu + "</span></div></div>"
		o.Release()
		oT.Release()
		oF.Release()
		oU.Release()
	next
	c += "<p class='note'>Photographs: Wikimedia Commons (photos/MANIFEST.tsv). COCO val2017 images under their own " +
		"Creative Commons licences; annotations CC BY 4.0, cocodataset.org. Models: U2-Net-p (Apache-2.0), " +
		"Depth-Anything-V2-Small (Apache-2.0).</p></body></html>"
	write(cPath, c)

func Verdict(n)
	if n >= 0.5 return "ok" ok
	return "no"

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
