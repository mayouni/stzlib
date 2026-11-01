# THE IMAGE PLANE'S MODELS -- IM3, narrated
#
# SOFTANZA_IMAGE_INTELLIGENCE.md IM3: three models converted from ONNX by
# engine/tools/onnx_to_gguf.py, run on ggml by the house's own graph runner
# (stz_neural, engine/src/vision.zig), behind ONE governed door that writes
# every call to the security ledger:
#
#   Scene 1  parity: the engine computes what onnxruntime computes
#   Scene 2  Classify(): MobileNetV3 names the dog and the cat
#   Scene 3  Faces(): YuNet finds the seven crew members, with landmarks
#   Scene 4  Objects(): YOLOX-tiny, and ObjectsTiled() for small people
#   Scene 5  refusals: no face where there is none; a missing model named
#   Scene 6  the door: every call is a chained record in the ledger
#   Scene 7  what a person looks at: annotated photos and an HTML page
#
# NEEDS what the tree does not carry: the models in models/vision and the
# photographs and parity fixtures beside the sources (sha256 and licences
# in models/MODELS.md and photos/MANIFEST.tsv). When absent, the guard says
# which and stops, it does not pass on nothing. THE HELPERS LIVE AFTER pf().

load "../../stzBase.ring"

$nPass = 0
$nFail = 0
$nSec = clock()
$cSrc = "D:/GitHub/_wti_models_src/"
$cPh = $cSrc + "photos/"

cOut = StzReplace(WorkingDirectory(), "\", "/") + "/_image-out"
if NOT StzDirExists(cOut)
	StzDirCreatePath(cOut)
ok

if NOT StzVisionModelsInstalled() or NOT fexists($cPh + "crew.jpg")
	? "NOT RUN: the vision models (" + StzVisionModelsDir() + ") or the photographs (" + $cPh +
		") are not installed -- see models/MODELS.md"
	shutdown(1)
ok

pr()

nCalls0 = StzVisionCallsRecorded()

#=====================================================================#
? "-- Scene 1: parity with onnxruntime --"
#=====================================================================#
# Each model on a fixed input made from a real photo; onnxruntime's
# output was written once by _rig/vision_parity.py.

aPar = [ [ "mobilenetv3", "mobilenetv3_large" ], [ "yunet", "yunet_2023mar" ],
	[ "yolox_nano", "yolox_nano" ], [ "yolox_tiny", "yolox_tiny" ] ]
for i = 1 to len(aPar)
	cIn = $cSrc + "parity/" + aPar[i][1] + "_in.stzt"
	if NOT fexists(cIn)
		? "    parity fixture missing for " + aPar[i][1] + " -- not counted"
		loop
	ok
	a = StzEngineNeuralOcrGraphParity(StzVisionModelPath(aPar[i][2] + ".gguf"), cIn,
		$cSrc + "parity/" + aPar[i][1] + "_out.stzt", "", 4)
	chk(aPar[i][1] + ": the engine agrees with onnxruntime (cosine " + a[4] + ", max diff " + a[2] + ", " +
		a[5] + " ms)", len(a) = 6 and a[4] > 0.99999 and a[2] < 0.001)
next

sec("scene 1")

#=====================================================================#
? "-- Scene 2: Classify() --"
#=====================================================================#

oDog = StzImageQ($cPh + "dog.jpg")
aC = oDog.Classify()
chk("the dog is a golden retriever (" + aC[1][:score] + ", " + StzVisionLastMs() + " ms)", aC[1][:label] = "golden retriever")
chk("...five labels, best first", len(aC) = 5 and aC[1][:score] >= aC[2][:score])
oCat = StzImageQ($cPh + "cat.jpg")
aK = oCat.Classify()
chk("the cat is a cat: '" + aK[1][:label] + "' (" + aK[1][:score] + ")", StzFindFirst("cat", aK[1][:label]) > 0)
chk("...and the dog is not (negative sibling)", StzFindFirst("cat", aC[1][:label]) = 0)

sec("scene 2")

#=====================================================================#
? "-- Scene 3: Faces() --"
#=====================================================================#
# NASA's Expedition 64 portrait: seven crew members. Faces() FINDS faces;
# it never says whose they are.

oCrew = StzImageQ($cPh + "crew.jpg")
aF = oCrew.Faces()
chk("seven faces in the crew portrait (" + StzVisionLastMs() + " ms)", len(aF) = 7)
chk("...each with five landmarks inside its box", LandmarksInside(aF))
chk("...the eyes above the mouth on every face", EyesAboveMouth(aF))

sec("scene 3")

#=====================================================================#
? "-- Scene 4: Objects() and ObjectsTiled() --"
#=====================================================================#

oSt = StzImageQ($cPh + "street.jpg")
aO = oSt.Objects()
nMsWhole = StzVisionLastMs()
aT = oSt.ObjectsTiled()
nMsTiled = StzVisionLastMs()
chk("Times Square: the tiles find more than the whole picture (" + len(aT) + " against " + len(aO) + ")", len(aT) > len(aO))
chk("...at least three people among them", CountLabel(aT, "person") >= 3)
? "    whole " + nMsWhole + " ms, whole + 4 tiles " + nMsTiled + " ms"
aD = oDog.Objects()
chk("the dog is one object, its box covering most of the picture", len(aD) >= 1 and
	aD[1][:box][3] * aD[1][:box][4] > 0.5 * oDog.Width() * oDog.Height())
# MEASURED, NOT HIDDEN: YOLOX-tiny calls this golden retriever a SHEEP (0.97,
# and onnxruntime agrees -- the engine is not at fault). The classifier is right.
# Which model earns which faculty is IM4's measurement against a floor.
chk("...and the detector's label disagrees with the classifier's: '" + aD[1][:label] + "'",
	aD[1][:label] != "dog")

sec("scene 4")

#=====================================================================#
? "-- Scene 5: refusals --"
#=====================================================================#

oBlank = StzImageNew(320, 240, 3, 128)
chk("a flat gray picture has no face", len(oBlank.Faces()) = 0)
chk("...and no object", len(oBlank.Objects()) = 0)
cKeep = $cStzVisionFaceModel
$cStzVisionFaceModel = "no-such-model.gguf"
bRaised = 0
cWhy = ""
try
	oCrew.Faces()
catch
	bRaised = 1
	cWhy = cCatchError
done
$cStzVisionFaceModel = cKeep
chk("a missing model is refused, naming its file", bRaised = 1 and StzFindFirst("no-such-model.gguf", cWhy) > 0)

sec("scene 5")

#=====================================================================#
? "-- Scene 6: the door --"
#=====================================================================#

nCalls = StzVisionCallsRecorded() - nCalls0
chk("every model call is in the security ledger (" + nCalls + " calls, 8 made)", nCalls = 8)
chk("...as a hash chain that verifies", StzSecurityLedgerQ().Verify()[:intact] = 1)

sec("scene 6")

#=====================================================================#
? "-- Scene 7: what a person looks at --"
#=====================================================================#

oCrew.ApplyFindings(aF, :green)
oCrew.SaveAsJpeg(cOut + "/im3_faces.jpg", 88)
oSt.ApplyFindings(aT, :orange)
oSt.SaveAsJpeg(cOut + "/im3_objects.jpg", 88)
oDog.ApplyFindings(aD, :red)
oDog.SaveAsJpeg(cOut + "/im3_dog.jpg", 88)
WriteReport(cOut + "/im3_vision.html", oCrew, aF, oSt, aT, oDog, aD, aC, oCat, aK)
chk("the annotated photos and the HTML page are written", fexists(cOut + "/im3_vision.html"))

sec("scene 7")

? ""
? "=========================================="
? "TOTAL: " + ($nPass + $nFail) + " assertions, " + $nPass + " pass, " + $nFail + " fail"
? "=========================================="

pf()

func LandmarksInside(aF)
	n = len(aF)
	for i = 1 to n
		b = aF[i][:box]
		for k = 1 to 5
			p = aF[i][:landmarks][k]
			if p[1] < b[1] or p[1] > b[1] + b[3] or p[2] < b[2] or p[2] > b[2] + b[4]
				return 0
			ok
		next
	next
	return 1

# landmarks: 1 right eye, 2 left eye, 3 nose, 4 right mouth corner, 5 left mouth corner
func EyesAboveMouth(aF)
	n = len(aF)
	for i = 1 to n
		L = aF[i][:landmarks]
		if L[1][2] >= L[4][2] or L[2][2] >= L[5][2]
			return 0
		ok
	next
	return 1

func CountLabel(aO, cLabel)
	n = 0
	m = len(aO)
	for i = 1 to m
		if aO[i][:label] = cLabel
			n++
		ok
	next
	return n

func WriteReport(cPath, oCrew, aF, oSt, aT, oDog, aD, aC, oCat, aK)
	c = "<!doctype html><html><head><meta charset='utf-8'><title>Softanza image plane -- IM3</title>" +
		"<style>body{font:16px/1.5 system-ui,sans-serif;max-width:1100px;margin:24px auto;padding:0 16px;color:#111;background:#fff}" +
		"h1{font-size:26px}h2{font-size:20px;margin-top:36px}img{max-width:100%;border:1px solid #ccc}" +
		"code{background:#f2f2f2;padding:1px 5px;border-radius:4px}table{border-collapse:collapse}" +
		"td,th{border:1px solid #ccc;padding:4px 10px;text-align:left}.note{color:#444}</style></head><body>" +
		"<h1>What Softanza sees -- the image plane's models (IM3)</h1>" +
		"<p class='note'>Every result below comes from models converted from ONNX and run on ggml by Softanza's own engine, " +
		"through one governed door that records each call in the security ledger.</p>"
	c += "<h2>Faces() -- YuNet</h2><p><code>oImg.Faces()</code> found <b>" + len(aF) + "</b> faces. " +
		"Green: the face; cyan dots: eyes, nose tip, mouth corners. It finds faces; it never says whose they are.</p>" +
		Img(oCrew) + Table(aF, 0)
	c += "<h2>ObjectsTiled() -- YOLOX-tiny on the whole picture and four tiles</h2><p><code>oImg.ObjectsTiled()</code> found <b>" +
		len(aT) + "</b> objects (80 COCO classes).</p>" + Img(oSt) + Table(aT, 1)
	c += "<h2>Classify() -- MobileNetV3</h2><table><tr><th>photo</th><th>best label</th><th>score</th><th>next</th></tr>" +
		"<tr><td>dog</td><td><b>" + aC[1][:label] + "</b></td><td>" + aC[1][:score] + "</td><td>" + aC[2][:label] + " (" + aC[2][:score] + ")</td></tr>" +
		"<tr><td>cat</td><td><b>" + aK[1][:label] + "</b></td><td>" + aK[1][:score] + "</td><td>" + aK[2][:label] + " (" + aK[2][:score] + ")</td></tr></table>"
	c += "<h2>A measured disagreement</h2><p>The classifier calls the dog a <b>" + aC[1][:label] + "</b>; the small detector boxes it " +
		"correctly but calls it a <b>" + aD[1][:label] + "</b> (" + aD[1][:score] + "). onnxruntime gives the same answer, so this is the " +
		"model, not Softanza. Which model earns which faculty is the next rung's measurement.</p>" + Img(oDog)
	c += "<p class='note'>Photos from Wikimedia Commons: NASA Expedition 64 crew portrait (public domain); Times Square, " +
		"New York City (HDR), CC BY 2.0; Golden Retriever Carlos, CC BY 2.0; Cat03, GFDL 1.2.</p></body></html>"
	write(cPath, c)

func Img(oImg)
	return "<p><img src='data:image/jpeg;base64," + StzEngineBytesToBase64(oImg.ToJPEG(85)) + "'></p>"

func Table(aFound, bLabels)
	c = "<table><tr><th>#</th>"
	if bLabels = 1
		c += "<th>label</th>"
	ok
	c += "<th>score</th><th>box [x, y, w, h]</th></tr>"
	n = len(aFound)
	for i = 1 to n
		b = aFound[i][:box]
		c += "<tr><td>" + i + "</td>"
		if bLabels = 1
			c += "<td>" + aFound[i][:label] + "</td>"
		ok
		c += "<td>" + aFound[i][:score] + "</td><td>" + floor(b[1]) + ", " + floor(b[2]) + ", " +
			floor(b[3]) + ", " + floor(b[4]) + "</td></tr>"
	next
	return c + "</table>"

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
