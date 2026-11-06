# THE OBJECT YOU POINT AT -- IM6 (3 of 3), narrated
#
# SOFTANZA_IMAGE_INTELLIGENCE.md IM6: MobileSAM converted from ONNX by
# engine/tools/onnx_to_gguf.py (a TinyViT encoder and SAM's prompt decoder)
# and run on ggml by stz_neural. A point on an object, or a box around it,
# becomes that object's mask. And the depth map of IM6's first part is
# judged at last, against laser scans:
#
#   Scene 1  parity: the encoder against onnxruntime, and the masks end to end
#            against the exported decoder's own
#   Scene 2  MaskAt(), MaskInBox(), CutOutAt(), ApplyCutOutAt(); a picture is
#            encoded once, however many prompts follow
#   Scene 3  :object-at -- the classical region against MobileSAM, judged by COCO
#   Scene 4  :depth -- "lower is nearer" against Depth-Anything, judged by DIODE
#   Scene 5  the door
#   Scene 6  what a person looks at: an HTML page
#
# NEEDS what the tree does not carry: the models in models/vision, the
# photographs, the COCO images and masks, DIODE's scans, the parity fixtures.
# When absent, the guard says which and stops. THE HELPERS LIVE AFTER pf().

load "../../stzBase.ring"
load "_court_rule.ring"
load "_golden/coco_points_v1.ring"
load "_golden/diode_depth_v1.ring"

$nPass = 0
$nFail = 0
$nSec = clock()
$cSrc = "D:/GitHub/_wti_models_src/"
$cPh = $cSrc + "photos/"
$cCo = $cSrc + "coco/images/"
$cMk = $cSrc + "coco/masks/"
$cDi = $cSrc + "diode/depth_v1/"

cOut = StzReplace(WorkingDirectory(), "\", "/") + "/_dense-out"
if NOT StzDirExists(cOut)
	StzDirCreatePath(cOut)
ok

if NOT StzVisionHasModel($cStzVisionSamEncoder) or NOT StzVisionHasModel($cStzVisionSamDecoder) or
   NOT StzVisionHasModel($cStzVisionDepthModel) or NOT fexists($cSrc + "parity/sam_prompts.tsv") or
   NOT StzDirExists($cMk) or NOT StzDirExists($cDi)
	? "NOT RUN: the MobileSAM or depth models (" + StzVisionModelsDir() + "), the parity fixtures, the COCO " +
		"masks or DIODE's scans are not installed -- see models/MODELS.md"
	shutdown(1)
ok

pr()
nCalls0 = StzVisionCallsRecorded()

#=====================================================================#
? "-- Scene 1: parity --"
#=====================================================================#

decimals(6)
a = StzEngineNeuralOcrGraphParity(StzVisionModelPath($cStzVisionSamEncoder), $cSrc + "parity/sam_enc_in.stzt",
	$cSrc + "parity/sam_enc_out.stzt", "", 4)
chk("the encoder agrees with onnxruntime: the picture padded with the pixel mean is the export's own padding " +
	"(cosine " + a[4] + ", max diff " + a[2] + ")", len(a) = 6 and a[4] > 0.99999 and a[2] < 0.001)
decimals(3)

# sam_prompts.tsv: photo, kind, the prompt's numbers (0-based pixels, as SAM reads them), labels, the IoU estimate
aRows = Prompts()
nWorstIou = 1
nWorstScore = 0
nRows = len(aRows)
for i = 1 to nRows
	o = StzImageQ($cPh + aRows[i][1])
	a = aRows[i][3]
	if aRows[i][2] = "point"
		aR = o.MaskAtXT([ a[1] + 1, a[2] + 1 ])
	else
		aR = o.MaskInBoxXT([ a[1] + 1, a[2] + 1, a[3] - a[1], a[4] - a[2] ])
	ok
	oRef = StzImageQ($cSrc + "parity/sam_" + StzReplace(aRows[i][1], ".jpg", "") + "_" + aRows[i][2] + ".png")
	nIou = StzEngineImageMaskIou(aR[:mask].Pixels(), oRef.Pixels(), 128)
	if nIou < nWorstIou nWorstIou = nIou ok
	if fabs(aR[:score] - aRows[i][4]) > nWorstScore nWorstScore = fabs(aR[:score] - aRows[i][4]) ok
	aR[:mask].Release()
	oRef.Release()
	o.Release()
next
chk("the masks equal the exported decoder's end to end, a point and a box on each of three photos (worst IoU " +
	nWorstIou + ")", nRows = 6 and nWorstIou > 0.99)
chk("...and so does the model's estimate of each mask's IoU (worst difference " + nWorstScore + ")", nWorstScore < 0.01)
nCalls1 = StzVisionCallsRecorded()
chk("three pictures encoded, six prompts decoded: " + (nCalls1 - nCalls0) + " records at the door", nCalls1 - nCalls0 = 9)

sec("scene 1")

#=====================================================================#
? "-- Scene 2: pointing at things --"
#=====================================================================#

oDog = StzImageQ($cPh + "dog.jpg")
t0 = clock()
oMask = oDog.MaskAt([ floor(oDog.Width() / 2), floor(oDog.Height() / 2) ])
nMs = floor((clock() - t0) / clockspersecond() * 1000)
chk("MaskAt() is a one-channel mask of the picture's size (" + oMask.Width() + " x " + oMask.Height() + ")",
	oMask.Channels() = 1 and oMask.Width() = oDog.Width() and oMask.Height() = oDog.Height())
nOn = Share(oMask)
chk("...the dog under the point takes " + floor(nOn * 100 + 0.5) + "% of the photo", nOn > 0.05 and nOn < 0.9)
chk("...and the picture was NOT encoded again: one record at the door, " + nMs + " ms",
	StzVisionCallsRecorded() - nCalls1 = 1 and nMs < 1500)
oBox = oDog.MaskInBox([ floor(oDog.Width() * 0.2), floor(oDog.Height() * 0.2), floor(oDog.Width() * 0.6),
	floor(oDog.Height() * 0.6) ])
chk("MaskInBox() gives the object inside a box, a mask of the same kind", oBox.Channels() = 1 and Share(oBox) > 0.05)
oCut = oDog.CutOutAt([ floor(oDog.Width() / 2), floor(oDog.Height() / 2) ])
chk("CutOutAt() is an RGBA copy, and the photo itself is unchanged (" + oDog.Channels() + " channels)",
	oCut.Channels() = 4 and oDog.Channels() = 3)
oCopy = StzImageFromPixels(oDog.Width(), oDog.Height(), oDog.Channels(), oDog.Pixels())
oCopy.ApplyCutOutAt([ floor(oDog.Width() / 2), floor(oDog.Height() / 2) ])
chk("ApplyCutOutAt() changes the image into the same cut-out", oCopy.Channels() = 4 and oCopy.Pixels() = oCut.Pixels())
oCopy.Release()
aX = oDog.MaskAtXT([ 10, 10 ])
chk("MaskAtXT() also gives the model's own estimate of its mask's IoU (" + aX[:score] + " for the corner of the " +
	"photo, against the centre's)", isNumber(aX[:score]) and aX[:score] > 0)
aX[:mask].Release()
bRaised = 0
try
	oDog.MaskAt([ oDog.Width() + 5, 1 ])
catch
	bRaised = 1
done
chk("a point outside the picture is refused before any model runs", bRaised = 1)
nCalls2 = StzVisionCallsRecorded()
chk("...five prompts on an encoded picture: five records", nCalls2 - nCalls1 = 5)

sec("scene 2")

#=====================================================================#
? "-- Scene 3: :object-at, judged by COCO --"
#=====================================================================#
# The golden set (_rig/coco_points.py, the rule fixed before any run): the 30
# COCO objects of :foreground, each prompted by the pixel deepest inside COCO's
# own mask; the truth is COCO's polygon.

aPt = StzVisionGoldenPointsV1()
aGA = []
nG = len(aPt)
for i = 1 to nG
	aGA + [ [ $cCo + aPt[i][1], aPt[i][4], aPt[i][5] ], $cMk + aPt[i][2] ]
next
aDi = StzVisionGoldenDepthV1()
aGD = []
nD = len(aDi)
for i = 1 to nD
	aGD + [ $cDi + aDi[i][1] + ".png", $cDi + aDi[i][1] ]
next
StzVisionDeclare([ [ "object-at", aGA ], [ "depth", aGD ] ])
chk("30 :object-at items, every image and mask on disk", len(StzFacultyQ("object-at").Goldens()) = 30 and AllOnDisk(aGA))
StzRunGoldens("object-at", [])
nAC = ScoreOf("object-at", "classical", "coco-v1")
nAS = ScoreOf("object-at", "mobilesam", "coco-v1")
? "    classical floor " + nAC + "   mobilesam " + nAS + "   (share of objects whose mask is found at IoU >= 0.5)"
chk("MobileSAM was measured on the same 30 objects (" + nAS + ")", nAS >= 0)
cChosenA = StzModelRegistryQ().ResolveQ("object-at").Chosen()
chk("the registry chose '" + cChosenA + "' -- the rule (the court) says '" + ByTheRule("object-at",
	"coco-v1") + "'", cChosenA = ByTheRule("object-at", "coco-v1"))
nCalls3 = StzVisionCallsRecorded()
chk("...30 pictures encoded and 30 points decoded: " + (nCalls3 - nCalls2) + " records (the floor runs no model)",
	nCalls3 - nCalls2 = 60)

sec("scene 3")

#=====================================================================#
? "-- Scene 4: :depth, judged by DIODE --"
#=====================================================================#
# The golden set (_rig/diode_depth.py, the rule fixed before any run): every
# 10th picture of DIODE's validation split, indoors and outdoor; the truth is
# the laser scan. A relative map is fitted by a scale and a shift, then judged
# by AbsRel <= 0.20.

chk("78 :depth items, every picture and scan on disk", len(StzFacultyQ(:depth).Goldens()) = 78 and DepthOnDisk(aGD))
StzRunGoldens("depth", [])
nDP = ScoreOf("depth", "lower-is-nearer", "diode-v1")
nDM = ScoreOf("depth", "depth-anything-v2-small", "diode-v1")
? "    'lower is nearer' floor " + nDP + "   depth-anything-v2-small " + nDM + "   (share of scans with AbsRel <= 0.20)"
chk("Depth-Anything-V2-Small was measured on the same 78 scans (" + nDM + ")", nDM >= 0)
cChosenD = StzModelRegistryQ().ResolveQ("depth").Chosen()
chk("the registry chose '" + cChosenD + "' -- the rule says '" + ByTheRule("depth", "diode-v1") + "'",
	cChosenD = ByTheRule("depth", "diode-v1"))
nCalls4 = StzVisionCallsRecorded()
aMean = MeanDepthScores(aGD, 13)
? "    on every 13th scan: floor AbsRel " + aMean[1] + ", delta1 " + aMean[2] + "; model AbsRel " + aMean[3] +
	", delta1 " + aMean[4]
chk("...and the model's mean error is below the floor's on the same scans", aMean[3] < aMean[1])
chk("78 depth maps: " + (nCalls4 - nCalls3) + " records", nCalls4 - nCalls3 = 78)
cRes = StzReplace(WorkingDirectory(), "\", "/") + "/results"
if NOT StzDirExists(cRes)
	StzDirCreatePath(cRes)
ok
StzSaveMeasurements(cRes + "/vision_im6b.zmdl.txt")
StzSaveCourt(cRes + "/court_im6_promptable.txt")

sec("scene 4")

#=====================================================================#
? "-- Scene 5: the door --"
#=====================================================================#

nCalls5 = StzVisionCallsRecorded()
# 9 (scene 1) + 5 (scene 2) + 60 (scene 3) + 78 (scene 4) + 6 (the mean scores' model maps)
chk("every model run went through the door: " + (nCalls5 - nCalls0) + " ledger records", nCalls5 - nCalls0 = 158)
chk("...as a hash chain that verifies", StzSecurityLedgerQ().Verify()[:intact] = 1)

sec("scene 5")

#=====================================================================#
? "-- Scene 6: what a person looks at --"
#=====================================================================#

WriteReport(cOut + "/im6_promptable.html", aPt, aDi, nAC, nAS, cChosenA, nDP, nDM, cChosenD)
chk("the report page is written", fexists(cOut + "/im6_promptable.html"))
oDog.Release()
oMask.Release()
oBox.Release()
oCut.Release()

sec("scene 6")

? ""
? "=========================================="
? "TOTAL: " + ($nPass + $nFail) + " assertions, " + $nPass + " pass, " + $nFail + " fail"
? "=========================================="

pfq()
shutdown($nFail)

# the parity prompts: [ photo, kind, [ four numbers ], estimate ]
func Prompts()
	aOut = []
	aL = str2list(read($cSrc + "parity/sam_prompts.tsv"))
	n = len(aL)
	for i = 1 to n
		if aL[i] = "" loop ok
		aF = StzSplit(aL[i], char(9))
		aN = StzSplit(aF[3], " ")
		aOut + [ aF[1], aF[2], [ 0 + aN[1], 0 + aN[2], 0 + aN[3], 0 + aN[4] ], 0 + aF[5] ]
	next
	return aOut

func Share(oM)
	return StzEngineImageMaskIou(oM.Pixels(), copy(char(255), oM.Width() * oM.Height()), 128)

func ScoreOf(cF, cImpl, cVer)
	a = StzMeasurementOf(cF, cImpl, cVer)
	if len(a) = 0
		return -1
	ok
	return a[:score]

func ByTheRule(cF, cVer)
	# the court's rule (the default gate since 2026-11-05), restated independently in _court_rule.ring
	return CourtRuleChoice(cF, cVer)

func MeanDepthScores(aGD, nStep)
	a = [ 0, 0, 0, 0 ]
	k = 0
	n = len(aGD)
	for i = 1 to n step nStep
		aF = StzDepthScore(_StzVisionDepthPrior(aGD[i][1], []), aGD[i][2])
		aM = StzDepthScore(_StzVisionDepthDa2(aGD[i][1], []), aGD[i][2])
		a[1] += aF[1]
		a[2] += aF[2]
		a[3] += aM[1]
		a[4] += aM[2]
		k++
	next
	for j = 1 to 4
		a[j] = a[j] / k
	next
	return a

func AllOnDisk(aItems)
	n = len(aItems)
	for i = 1 to n
		if NOT fexists(aItems[i][1][1]) or NOT fexists(aItems[i][2])
			return 0
		ok
	next
	return 1

func DepthOnDisk(aItems)
	n = len(aItems)
	for i = 1 to n
		if NOT fexists(aItems[i][1]) or NOT fexists(aItems[i][2] + "_depth.npy") or NOT fexists(aItems[i][2] + "_mask.png")
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

# the photo with the prompt drawn on it: a dot for a point, an outline for a box
func Marked(o, aP)
	oM = StzImageFromPixels(o.Width(), o.Height(), o.Channels(), o.Pixels())
	nR = max([ 6, floor(o.Width() / 90) ])
	if len(aP) = 2
		oM.ApplyDot(aP, nR + 3, "white")
		oM.ApplyDot(aP, nR, "magenta")
	else
		oM.ApplyBox(aP, "magenta", max([ 3, floor(o.Width() / 250) ]))
	ok
	return oM

func Cell(cImg, cCap, cClass)
	return "<div class='" + cClass + "'>" + cImg + "<span class='cap'>" + cCap + "</span></div>"

func WriteReport(cPath, aPt, aDi, nAC, nAS, cChosenA, nDP, nDM, cChosenD)
	c = "<!doctype html><html><head><meta charset='utf-8'><meta name='viewport' content='width=device-width'>" +
		"<title>The object you point at</title>" +
		"<style>body{font:16px/1.5 system-ui,sans-serif;max-width:1100px;margin:24px auto;padding:0 16px;color:#111;background:#fff}" +
		"h1{font-size:26px}h2{font-size:20px;margin-top:34px}img{max-width:100%;display:block}" +
		".row{display:grid;grid-template-columns:repeat(4,1fr);gap:8px;margin-bottom:14px}" +
		".chk{background:repeating-conic-gradient(#ccc 0 25%,#fff 0 50%) 0 0/20px 20px}" +
		".cap{font-size:15px;color:#333;display:block}.note{color:#333}.ok{color:#126b2a;font-weight:600}.no{color:#a11;font-weight:600}" +
		"code{background:#f2f2f2;padding:1px 5px;border-radius:4px}@media(max-width:700px){.row{grid-template-columns:repeat(2,1fr)}}" +
		"</style></head><body>" +
		"<h1>The object you point at (IM6, 3 of 3)</h1>" +
		"<p class='note'>Each row: the photo with a point, <code>CutOutAt(point)</code> on a checkerboard (transparent = " +
		"not the object), the photo with a box, and the object <code>MaskInBox(box)</code> finds, cut out the same way. " +
		"MobileSAM encodes the picture once (about 1.5 s); each point or box after that costs about 0.07 s.</p>"
	aPh = [ "dog", "cat", "street", "crew" ]
	for i = 1 to 4
		o = StzImageQ($cPh + aPh[i] + ".jpg")
		aP = [ floor(o.Width() / 2), floor(o.Height() / 2) ]
		aB = [ floor(o.Width() * 0.2), floor(o.Height() * 0.2), floor(o.Width() * 0.6), floor(o.Height() * 0.6) ]
		oP = Marked(o, aP)
		oC = o.CutOutAt(aP)
		oQ = Marked(o, aB)
		oBm = o.MaskInBox(aB)
		oBc = StzImageFromPixels(o.Width(), o.Height(), o.Channels(), o.Pixels())
		oBc.ApplyMask(oBm)
		c += "<div class='row'>" + Cell(Thumb(oP, 280, 80), aPh[i] + ".jpg, a point", "") +
			Cell(Thumb(oC, 280, 0), "CutOutAt", "chk") + Cell(Thumb(oQ, 280, 80), "a box", "") +
			Cell(Thumb(oBc, 280, 0), "MaskInBox", "chk") + "</div>"
		o.Release()
		oP.Release()
		oC.Release()
		oQ.Release()
		oBm.Release()
		oBc.Release()
	next
	c += "<h2>:object-at -- judged by COCO (" + cChosenA + " answers)</h2><p class='note'>The 30 COCO objects of " +
		":foreground, each prompted by the pixel deepest inside COCO's own mask (the magenta dot). The truth is the " +
		"polygon COCO's annotators drew; found = IoU 0.5 or more. Classical floor (the region of the classical " +
		"foreground the point falls in): <b>" + nAC + "</b>. MobileSAM: <b>" + nAS + "</b>. Each row: the image " +
		"and its point, COCO's mask, the classical mask, MobileSAM's.</p>"
	n = len(aPt)
	for i = 1 to n
		if i > 10 exit ok
		o = StzImageQ($cCo + aPt[i][1])
		oT = StzImageQ($cMk + aPt[i][2])
		aIn = [ $cCo + aPt[i][1], aPt[i][4], aPt[i][5] ]
		aF = _StzVisionObjectAtClassic(aIn, [])
		oF = StzImageFromPixels(aF[:width], aF[:height], 1, aF[:mask])
		oU = o.MaskAt([ aPt[i][4], aPt[i][5] ])
		oP = Marked(o, [ aPt[i][4], aPt[i][5] ])
		nIf = StzEngineImageMaskIou(oF.Pixels(), oT.Pixels(), 128)
		nIu = StzEngineImageMaskIou(oU.Pixels(), oT.Pixels(), 128)
		c += "<div class='row'>" + Cell(Thumb(oP, 280, 80), aPt[i][3], "") + Cell(Thumb(oT, 280, 80), "COCO", "") +
			"<div>" + Thumb(oF, 280, 80) + "<span class='cap " + Verdict(nIf) + "'>classical IoU " + nIf + "</span></div>" +
			"<div>" + Thumb(oU, 280, 80) + "<span class='cap " + Verdict(nIu) + "'>MobileSAM IoU " + nIu + "</span></div></div>"
		o.Release()
		oT.Release()
		oF.Release()
		oU.Release()
		oP.Release()
	next
	c += "<h2>:depth -- judged by DIODE's laser scans (" + cChosenD + " answers)</h2><p class='note'>Every 10th picture " +
		"of DIODE's validation split (78: indoors and outdoor). A relative map is fitted to the scan by a scale and a " +
		"shift, then judged: AbsRel (the mean error as a share of the true distance) at most 0.20. The floor reads " +
		"the picture's rows as distance (the lower, the nearer): <b>" + nDP + "</b>. Depth-Anything-V2-Small: <b>" +
		nDM + "</b>. Each row: the picture, the scan (white is near; what the scanner missed is transparent), " +
		"<code>DepthMap()</code>, and the floor's map. White is near in all three.</p>"
	n = len(aDi)
	for i = 1 to n step 13
		cB = $cDi + aDi[i][1]
		o = StzImageQ(cB + ".png")
		nT = StzNpyF32Grid(cB + "_depth.npy")
		oTg = new stzImageGrid(nT, "y", "x")
		oTv = oTg.ToImageScaled()
		oTi = oTv.Inverted()
		oMk = StzImageQ(cB + "_mask.png")
		oTi.ApplyMask(oMk)
		oG = o.DepthMap()
		oV = oG.ToImageScaled()
		oRows = RowsPicture(o.Width(), o.Height())
		aM = StzDepthScore(_StzVisionDepthDa2(cB + ".png", []), cB)
		aF = StzDepthScore(_StzVisionDepthPrior(cB + ".png", []), cB)
		c += "<div class='row'>" + Cell(Thumb(o, 280, 80), aDi[i][2], "") + Cell(Thumb(oTi, 280, 0), "laser scan", "chk") +
			"<div>" + Thumb(oV, 280, 80) + "<span class='cap " + DepthVerdict(aM[1]) + "'>model AbsRel " + aM[1] + "</span></div>" +
			"<div>" + Thumb(oRows, 280, 80) + "<span class='cap " + DepthVerdict(aF[1]) + "'>floor AbsRel " + aF[1] + "</span></div></div>"
		o.Release()
		oTg.Release()
		oTv.Release()
		oTi.Release()
		oMk.Release()
		oG.Release()
		oV.Release()
		oRows.Release()
	next
	c += "<p class='note'>Photographs: Wikimedia Commons (photos/MANIFEST.tsv). COCO val2017 images under their own " +
		"Creative Commons licences; annotations CC BY 4.0, cocodataset.org. DIODE (Vasiljevic et al. 2019, " +
		"diode-dataset.org), used for measuring only. Models: MobileSAM (Apache-2.0), Depth-Anything-V2-Small " +
		"(Apache-2.0).</p></body></html>"
	write(cPath, c)

# the floor's map as a picture: each row's gray its number, the bottom white (nearest)
func RowsPicture(nW, nH)
	c = ""
	for y = 1 to nH
		c += copy(char(floor((y - 1) * 255 / max([ 1, nH - 1 ]))), nW)
	next
	return StzImageFromPixels(nW, nH, 1, c)

func Verdict(n)
	if n >= 0.5 return "ok" ok
	return "no"

func DepthVerdict(n)
	if n <= 0.2 return "ok" ok
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
