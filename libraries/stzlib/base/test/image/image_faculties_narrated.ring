# THE IMAGE PLANE'S FACULTIES -- IM4, narrated
#
# SOFTANZA_IMAGE_INTELLIGENCE.md IM4 and SOFTANZA_MODEL_FLOW.md: a model
# answers instead of the floor ONLY once measured STRICTLY better on a
# golden set whose truth someone else wrote. Here that someone is COCO:
# its annotators' boxes and keypoints (CC BY 4.0), picked by fixed rules
# before any model ran (_rig/coco_golden.py -> _golden/coco_v1.ring).
#
#   Scene 1  the golden sets: 30 faces images, 40 objects, 40 labels
#   Scene 2  :faces -- the platform's detector against YuNet
#   Scene 3  :objects -- "nothing found" against YOLOX-nano and -tiny
#   Scene 4  :image-label -- a fixed "chair" against MobileNetV3
#   Scene 5  the registry rules on the numbers, and only on them
#   Scene 6  the measurements are filed and outlive the process
#   Scene 7  what a person looks at (_faculty-out/im4_faculties.html)
#
# The guard asserts the MECHANISM -- the registry picks a model only when
# its measured score strictly beats the floor's -- never a winner decided
# in advance. NEEDS the models (models/vision) and the 88 COCO images
# (D:/GitHub/_wti_models_src/coco/images). THE HELPERS LIVE AFTER pf().

load "../../stzBase.ring"
load "_golden/coco_v1.ring"

$nPass = 0
$nFail = 0
$nSec = clock()
$cImg = "D:/GitHub/_wti_models_src/coco/images/"

cOut = StzReplace(WorkingDirectory(), "\", "/") + "/_faculty-out"
if NOT StzDirExists(cOut)
	StzDirCreatePath(cOut)
ok
if NOT StzVisionModelsInstalled() or NOT fexists($cImg + "MANIFEST.tsv")
	? "NOT RUN: the vision models or the COCO golden images are not installed -- see models/MODELS.md"
	shutdown(1)
ok

pr()
nCalls0 = StzVisionCallsRecorded()

#=====================================================================#
? "-- Scene 1: the golden sets --"
#=====================================================================#

aGF = WithPaths(StzVisionGoldenFacesV1())
aGO = WithPaths(StzVisionGoldenObjectsV1())
aGL = WithPaths(StzVisionGoldenLabelsV1())
StzVisionDeclare([ [ "faces", aGF ], [ "objects", aGO ], [ "image-label", aGL ] ])
chk("30 faces items, 40 objects items, 40 label items, from COCO's own annotations",
	len(StzFacultyQ(:faces).Goldens()) = 30 and len(StzFacultyQ(:objects).Goldens()) = 40 and
	len(StzFacultyQ("image-label").Goldens()) = 40)
chk("...every image they name is on disk", AllOnDisk(aGF) and AllOnDisk(aGO) and AllOnDisk(aGL))

sec("scene 1")

#=====================================================================#
? "-- Scene 2: :faces --"
#=====================================================================#

aRF = StzRunGoldens("faces", [])
nFP = ScoreOf("faces", "platform")
nFY = ScoreOf("faces", "yunet")
? "    platform floor " + nFP + "   yunet " + nFY + "   (share of images: 80% of COCO's visible faces found, at most one false face)"
chk("the floor and the model are both measured on the 30 images", len(aRF) = 2)

sec("scene 2")

#=====================================================================#
? "-- Scene 3: :objects --"
#=====================================================================#

aRO = StzRunGoldens("objects", [])
nON = ScoreOf("objects", "nothing")
nOA = ScoreOf("objects", "yolox-nano")
nOTiny = ScoreOf("objects", "yolox-tiny")
? "    nothing-floor " + nON + "   yolox-nano " + nOA + "   yolox-tiny " + nOTiny + "   (share of images with F1 >= 0.5 at IoU 0.5)"
chk("the floor that finds nothing scores 0: every image has a counted object", nON = 0)
chk("...and both models are measured", len(aRO) = 3)

sec("scene 3")

#=====================================================================#
? "-- Scene 4: :image-label --"
#=====================================================================#

aRL = StzRunGoldens("image-label", [])
nLP = ScoreOf("image-label", "prior")
nLM = ScoreOf("image-label", "mobilenetv3")
nChair = CountExpected(aGL, "chair")
? "    fixed-'chair' floor " + nLP + "   mobilenetv3 " + nLM + "   (share of images whose largest object it names)"
chk("the fixed floor scores exactly the share of 'chair' in the golden set (" + nChair + " of 40)", nLP = nChair / 40)

sec("scene 4")

#=====================================================================#
? "-- Scene 5: the registry rules on the numbers --"
#=====================================================================#

aFac = [ "faces", "objects", "image-label" ]
for k = 1 to 3
	cF = aFac[k]
	cChosen = StzModelRegistryQ().ResolveQ(cF).Chosen()
	cRule = ByTheRule(cF)
	chk(cF + ": the registry chose '" + cChosen + "' -- the rule (strictly beat the floor, then the best) says '" + cRule + "'",
		cChosen = cRule)
next
StzModelPolicy(:deterministic)
chk("...and under the deterministic policy every faculty is on its floor",
	StzModelRegistryQ().ResolveQ("faces").IsFloor() = 1 and StzModelRegistryQ().ResolveQ("objects").IsFloor() = 1 and
	StzModelRegistryQ().ResolveQ("image-label").IsFloor() = 1)
StzModelPolicy(:auto)

sec("scene 5")

#=====================================================================#
? "-- Scene 6: the measurements outlive the process --"
#=====================================================================#

cRes = StzReplace(WorkingDirectory(), "\", "/") + "/results"
if NOT StzDirExists(cRes)
	StzDirCreatePath(cRes)
ok
cFile = cRes + "/vision.zmdl.txt"
aBefore = [ StzModelRegistryQ().ResolveQ("faces").Chosen(), StzModelRegistryQ().ResolveQ("objects").Chosen(),
	StzModelRegistryQ().ResolveQ("image-label").Chosen() ]
StzSaveMeasurements(cFile)
StzClearMeasurements()
chk("with the measurements cleared, every faculty falls back to its floor",
	StzModelRegistryQ().ResolveQ("objects").IsFloor() = 1)
StzLoadMeasurements(cFile)
aAfter = [ StzModelRegistryQ().ResolveQ("faces").Chosen(), StzModelRegistryQ().ResolveQ("objects").Chosen(),
	StzModelRegistryQ().ResolveQ("image-label").Chosen() ]
chk("...and filed and read back, the same choices return " + @@(aAfter), @@(aAfter) = @@(aBefore))
nCalls = StzVisionCallsRecorded() - nCalls0
chk("every model run went through the door: " + nCalls + " ledger records", nCalls >= 30 + 80 + 40)

sec("scene 6")

#=====================================================================#
? "-- Scene 7: what a person looks at --"
#=====================================================================#

WriteReport(cOut + "/im4_faculties.html", aGF, aGO, aGL)
chk("the report page is written", fexists(cOut + "/im4_faculties.html"))

sec("scene 7")

? ""
? "=========================================="
? "TOTAL: " + ($nPass + $nFail) + " assertions, " + $nPass + " pass, " + $nFail + " fail"
? "=========================================="

pf()

func WithPaths(aItems)
	aOut = []
	n = len(aItems)
	for i = 1 to n
		aOut + [ $cImg + aItems[i][1], aItems[i][2] ]
	next
	return aOut

func AllOnDisk(aItems)
	n = len(aItems)
	for i = 1 to n
		if NOT fexists(aItems[i][1])
			return 0
		ok
	next
	return 1

func ScoreOf(cF, cImpl)
	a = StzMeasurementOf(cF, cImpl, "coco-v1")
	if len(a) = 0
		return -1
	ok
	return a[:score]

func CountExpected(aItems, cLabel)
	n = 0
	m = len(aItems)
	for i = 1 to m
		if aItems[i][2] = cLabel
			n++
		ok
	next
	return n

# the law, computed here from the measured numbers: the best model if it STRICTLY beats the floor, else the floor
func ByTheRule(cF)
	oF = StzFacultyQ(cF)
	cFloor = ""
	cBest = ""
	nBest = -1
	a = oF.Implementations()
	n = len(a)
	for i = 1 to n
		if a[i][:kind] = "floor"
			cFloor = a[i][:id]
		else
			s = ScoreOf(cF, a[i][:id])
			if s > nBest
				nBest = s
				cBest = a[i][:id]
			ok
		ok
	next
	if nBest > ScoreOf(cF, cFloor)
		return cBest
	ok
	return cFloor

func Bar(cName, nScore, cColor)
	w = floor(nScore * 360)
	return "<div style='display:flex;align-items:center;gap:10px;margin:3px 0'><span style='width:150px'>" + cName +
		"</span><svg width='380' height='18'><rect x='0' y='2' width='360' height='14' fill='#eee'/>" +
		"<rect x='0' y='2' width='" + w + "' height='14' fill='" + cColor + "'/></svg><b>" + floor(nScore * 100) + "%</b></div>"

func WriteReport(cPath, aGF, aGO, aGL)
	c = "<!doctype html><html><head><meta charset='utf-8'><title>Softanza image plane -- IM4</title>" +
		"<style>body{font:16px/1.5 system-ui,sans-serif;max-width:1100px;margin:24px auto;padding:0 16px;color:#111;background:#fff}" +
		"h1{font-size:26px}h2{font-size:20px;margin-top:34px}img{max-width:100%;border:1px solid #ccc}" +
		".grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(250px,1fr));gap:14px}" +
		".cell{border:1px solid #ddd;padding:6px}.ok{color:#126b2a;font-weight:600}.no{color:#a11;font-weight:600}" +
		"code{background:#f2f2f2;padding:1px 5px;border-radius:4px}.note{color:#444}</style></head><body>" +
		"<h1>Which model earns which faculty -- measured (IM4)</h1>" +
		"<p class='note'>A model answers instead of the floor only when it scores STRICTLY better on a golden set whose truth " +
		"someone else wrote: COCO's annotators, on images chosen by fixed rules before any model ran. Gray bar = floor.</p>"
	c += "<h2>:faces -- " + StzModelRegistryQ().ResolveQ("faces").Chosen() + " answers</h2>" +
		Bar("platform (floor)", ScoreOf("faces", "platform"), "#999") + Bar("YuNet", ScoreOf("faces", "yunet"), "#2a8a3e") +
		"<p class='note'>Per image: at least 80% of the faces COCO marks as clearly visible are found, and at most one false face. " +
		"Yellow dots: COCO's noses. Blue: the platform's boxes. Green: YuNet's.</p><div class='grid'>"
	for i = 1 to 6
		c += "<div class='cell'>" + FacesPicture(aGF[i]) + "</div>"
	next
	c += "</div><h2>:objects -- " + StzModelRegistryQ().ResolveQ("objects").Chosen() + " answers</h2>" +
		Bar("nothing (floor)", ScoreOf("objects", "nothing"), "#999") + Bar("YOLOX-nano", ScoreOf("objects", "yolox-nano"), "#d67a00") +
		Bar("YOLOX-tiny", ScoreOf("objects", "yolox-tiny"), "#d67a00") +
		"<p class='note'>Per image: F1 of at least 0.5, a box matching COCO's at IoU 0.5 with the right label. White: COCO's " +
		"objects. Orange: YOLOX-tiny's.</p><div class='grid'>"
	for i = 1 to 6
		c += "<div class='cell'>" + ObjectsPicture(aGO[i]) + "</div>"
	next
	c += "</div><h2>:image-label -- " + StzModelRegistryQ().ResolveQ("image-label").Chosen() + " answers</h2>" +
		Bar("fixed 'chair' (floor)", ScoreOf("image-label", "prior"), "#999") + Bar("MobileNetV3", ScoreOf("image-label", "mobilenetv3"), "#2c6fd6") +
		"<p class='note'>Per image: the label of its largest object, as COCO marks it.</p><div class='grid'>"
	for i = 1 to 12
		c += "<div class='cell'>" + LabelPicture(aGL[i]) + "</div>"
	next
	c += "</div><p class='note'>Images: COCO val2017 (each image's own Creative Commons licence, listed in coco_v1.ring); " +
		"annotations CC BY 4.0, cocodataset.org.</p></body></html>"
	write(cPath, c)

func Thumb(oImg)
	if oImg.Width() > 420
		oImg.ApplyResize(420, floor(oImg.Height() * 420 / oImg.Width()))
	ok
	return "<img src='data:image/jpeg;base64," + StzEngineBytesToBase64(oImg.ToJPEG(82)) + "'>"

func FacesPicture(aItem)
	o = StzImageQ(aItem[1])
	aP = _StzVisionFacesPlatform(aItem[1], [])
	aY = o.Faces()
	o.ApplyFindings(aP, :blue)
	o.ApplyFindings(aY, :green)
	n = len(aItem[2])
	for k = 1 to n
		o.ApplyDot([ aItem[2][k][1], aItem[2][k][2] ], 4, :yellow)
	next
	sp = StzFacesScore(aP, aItem[2])
	sy = StzFacesScore(aY, aItem[2])
	return Thumb(o) + "<br>platform: " + len(aP) + " found, recall " + floor(sp[:recall] * 100) + "%<br>YuNet: " +
		len(aY) + " found, recall " + floor(sy[:recall] * 100) + "%"

func ObjectsPicture(aItem)
	o = StzImageQ(aItem[1])
	aT = _StzVisionObjectsTiny(aItem[1], [])
	n = len(aItem[2])
	for k = 1 to n
		r = aItem[2][k]
		if r[6] = 1
			o.ApplyBox([ r[2], r[3], r[4], r[5] ], :white, 2)
		ok
	next
	o.ApplyFindings(aT, :orange)
	s = StzBoxesScore(aT, aItem[2])
	c = ""
	m = len(aT)
	for k = 1 to m
		if k <= 4
			c += aT[k][:label] + " "
		ok
	next
	return Thumb(o) + "<br>F1 " + floor(s[:f1] * 100) + "% -- " + s[:hits] + " hit, " + s[:misses] + " missed, " + s[:false] +
		" false<br><small>" + c + "</small>"

func LabelPicture(aItem)
	o = StzImageQ(aItem[1])
	cGot = _StzVisionLabelMobilenet(aItem[1], [])
	cCls = "no"
	if cGot = aItem[2]
		cCls = "ok"
	ok
	return Thumb(o) + "<br>COCO: <b>" + aItem[2] + "</b><br>MobileNetV3: <span class='" + cCls + "'>" + cGot + "</span>"

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
