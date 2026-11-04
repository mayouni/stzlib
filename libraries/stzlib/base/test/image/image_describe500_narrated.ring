# A LARGER MODEL, MEASURED, AND REFUSED -- IM9e, narrated
#
# SOFTANZA_IMAGE_INTELLIGENCE.md IM9e. SmolVLM-500M-Instruct (the author said yes to the download; Q8_0, 32 layers, 960 wide)
# runs in the same slot as the 256M model, through the same tower. THE RULE WAS WRITTEN BEFORE IT WAS RUN: on the SAME 99
# COCO pictures and the SAME checker (names-main-object) in which the 256M model scored 87, the larger model answers :describe
# only if it STRICTLY beats that, 88 of 99 or more; a tie keeps the 256M model; a refusal is recorded as one.
#
#   Scene 1  provenance: the model loads with its recorded digest and is refused with another
#   Scene 2  the 99 pictures through the registered implementation: its score against the bar
#   Scene 3  the registry: it keeps the 256M model, the larger one being a measured implementation that did not beat it
#   Scene 4  what a person reads: twelve pictures, the words of each model side by side
#
# Not claimed: that the engine runs the 500M model exactly as its reference does (no Hugging Face weights of it are held, so no
# parity check is run); its captions are read on the page, and a score below the 256M's is read first as a possible fault of the
# run (they are fluent and detailed: the misses are mostly pictures whose main annotated object the caption does not name).
#
# NEEDS models/vision/smolvlm_500m*.gguf and the 256M model, the COCO pictures. HELPERS LIVE AFTER pf().

load "../../stzBase.ring"
load "_golden/coco_describe_v1.ring"

$nPass = 0
$nFail = 0
$nSec = clock()
$cCo = "D:/GitHub/_wti_models_src/coco/images/"
$nBar = 88

cOut = StzReplace(WorkingDirectory(), "\", "/") + "/_describe500-out"
if NOT StzDirExists(cOut)
	StzDirCreatePath(cOut)
ok

if NOT StzVisionHasModel($cStzVisionVlm500Decoder) or NOT StzVisionHasModel($cStzVisionVlm500Projector) or NOT StzDirExists($cCo)
	? "NOT RUN: the 500M model (models/vision/smolvlm_500m.gguf and its mmproj) or the COCO pictures"
	shutdown(0)
ok

? "-- Scene 1: provenance --"
cDec = StzVisionModelPath($cStzVisionVlm500Decoder)
StzExpectModelDigest(cDec, "0000000000000000000000000000000000000000000000000000000000000000")
nBad = StzEngineNeuralModelLoad(cDec)
nBadStatus = StzEngineNeuralModelLoadStatus()
chk("the 500M decoder is REFUSED with a digest that is not its own (load " + nBad + ", status " + nBadStatus + ")", nBad != 1 and nBadStatus = -2)
StzExpectModelDigest(cDec, $cStzVisionVlm500Sha256)
nGood = StzEngineNeuralModelLoad(cDec)
chk("...and loads with the digest recorded in models/MODELS.md (load " + nGood + ", " + StzEngineNeuralModelNEmbd() + " wide)", nGood = 1 and StzEngineNeuralModelNEmbd() = $nStzVisionVlm500Width)
$cStzVisionVlmSlot = ""
sec("scene 1")

? "-- Scene 2: the 99 pictures, through the registered implementation --"
aD = StzVisionGoldenDescribeV1()
aW = StzVisionGoldenWordsV1()
nD = len(aD)
nOk = 0
nInv = 0
nMs = 0
aSaid = []
for i = 1 to nD
	t0 = clock()
	c = _StzVisionDescribeSmolvlm500($cCo + aD[i][1], [])
	nMs += (clock() - t0) / clockspersecond() * 1000
	b = StzGoldenAgrees("names-main-object", c, WordsOf(aW, aD[i][2]))
	if b nOk++ ok
	if len(Invented(aW, c, aD[i][3])) > 0 nInv++ ok
	aSaid + [ c, b ]
next
? "    the 500M model: " + nOk + " of " + nD + " agree, " + nInv + " name a COCO category COCO did not annotate there, " + floor(nMs / nD) + " ms a picture"
chk("the 500M model's score is " + nOk + " of " + nD + ", as recorded in vision.zmdl.txt (86)", nOk = 86)
chk("...which does NOT meet the bar written beforehand (" + $nBar + " of " + nD + ": strictly more than the 256M model's 87): a refusal, recorded as one", nOk < $nBar)
chk("...and its description is not empty or cut to nothing: every one of the " + nD + " has words", AllWords(aSaid))
sec("scene 2")

? "-- Scene 3: the registry --"
StzVisionDeclare("")
oF = StzFacultyQ(:describe)
chk(":describe has both implementations, the 256M and the 500M", len(StzFind("smolvlm-256m", oF.ImplementationIds())) > 0 and len(StzFind("smolvlm-500m", oF.ImplementationIds())) > 0)
n256 = StzMeasurementOf("describe", "smolvlm-256m", "coco-describe-v1")[:score]
n500 = StzMeasurementOf("describe", "smolvlm-500m", "coco-describe-v1")[:score]
chk("the filed measurements: the 256M model " + n256 + ", the 500M model " + n500 + " -- the 256M is the higher", n256 > n500)
cChosen = StzModelRegistryQ().ResolveQ(StzRequirementQ("describe")).Chosen()
chk("the registry keeps '" + cChosen + "' for :describe", cChosen = "smolvlm-256m")
sec("scene 3")

? "-- Scene 4: what a person reads --"
$cStzVisionVlmSlot = ""
WritePage(cOut + "/describe500.html", aD, aW, aSaid, nOk, nInv, nMs / nD)
chk("the page is written", fexists(cOut + "/describe500.html"))
sec("scene 4")

? ""
? "ASSERTIONS: " + ($nPass + $nFail) + " -- " + $nPass + " passed, " + $nFail + " failed"
pf()
shutdown($nFail)

func WordsOf(aW, cCat)
	n = len(aW)
	for i = 1 to n
		if aW[i][1] = cCat return aW[i][2] ok
	next
	return [ cCat ]

func Invented(aW, cText, aPresent)
	aOut = []
	n = len(aW)
	for i = 1 to n
		if len(StzFind(aW[i][1], aPresent)) > 0 loop ok
		if len(StzDescribeNamed(cText, aW[i][2])) > 0 aOut + aW[i][1] ok
	next
	return aOut

func AllWords(aSaid)
	for i = 1 to len(aSaid)
		if len(aSaid[i][1]) < 5 return 0 ok
	next
	return 1

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

func Thumb(cPath, nW)
	o = StzImageQ(cPath)
	if o.Width() > nW
		o2 = o.Resized(nW, floor(o.Height() * nW / o.Width() + 0.5))
		o.Release()
		o = o2
	ok
	c = o.ToJpegDataURI(80)
	o.Release()
	return c

# twelve pictures, the words of each model side by side: the first six where the 500M model missed, then six where both agree
func WritePage(cPath, aD, aW, aSaid, nOk, nInv, nMs)
	decimals(3)
	aPick = []
	for i = 1 to len(aD)
		if aSaid[i][2] = 0 and len(aPick) < 6 aPick + i ok
	next
	for i = 1 to len(aD)
		if aSaid[i][2] = 1 and len(aPick) < 12 and i % 7 = 1 aPick + i ok
	next
	c = "<!doctype html><html lang='en'><head><meta charset='utf-8'><meta name='viewport' content='width=device-width,initial-scale=1'>" +
		"<title>A larger describe model</title><style>" +
		":root{--bg:#fff;--fg:#1c1c1e;--mut:#6b6b70;--line:#d8d8dc;--ok:#1a7f37;--bad:#b3261e;--card:#f6f6f8}" +
		"@media (prefers-color-scheme:dark){:root{--bg:#161618;--fg:#ececf0;--mut:#9a9aa2;--line:#3a3a40;--ok:#4cc26a;--bad:#f28b82;--card:#202024}}" +
		"body{margin:0;background:var(--bg);color:var(--fg);font:16px/1.5 system-ui,Segoe UI,sans-serif}main{max-width:1100px;margin:0 auto;padding:16px}" +
		"h1{font-size:1.5rem;margin:.3em 0}p.sub{color:var(--mut)}.k{display:grid;grid-template-columns:repeat(auto-fit,minmax(210px,1fr));gap:12px;margin:1em 0}" +
		".kp{background:var(--card);border-radius:8px;padding:10px 14px}.kp b{display:block;font-size:1.4rem}.kp span{color:var(--mut);font-size:.88rem}" +
		".r{display:grid;grid-template-columns:200px 1fr 1fr;gap:12px;padding:12px 0;border-bottom:1px solid var(--line)}.r img{width:100%;height:auto}" +
		".r p{margin:.2em 0;font-size:.85rem}.m{color:var(--mut)}.ok{color:var(--ok);font-weight:600}.no{color:var(--bad);font-weight:600}" +
		"@media (max-width:760px){.r{grid-template-columns:1fr}}</style></head><body><main>" +
		"<h1>A larger describe model: measured, and not chosen</h1><p class='sub'>SmolVLM-500M-Instruct on the same 99 COCO pictures and the same checker as the 256M model. " +
		"A description agrees when it names the picture's largest annotated object. The bar, fixed before the model was run: strictly more than the 256M model's 87 of 99.</p>" +
		"<div class='k'><div class='kp'><b>" + nOk + " / 99</b><span>the 500M model (the bar: 88; the 256M model: 87)</span></div>" +
		"<div class='kp'><b>" + nInv + " / 99</b><span>name a COCO category COCO did not annotate there (the 256M model: 38)</span></div>" +
		"<div class='kp'><b>" + floor(nMs) + " ms</b><span>a picture (the 256M model: about 1,400)</span></div></div>"
	for k = 1 to len(aPick)
		i = aPick[k]
		cSmall = _StzVisionDescribeSmolvlm($cCo + aD[i][1], [])
		bSmall = StzGoldenAgrees("names-main-object", cSmall, WordsOf(aW, aD[i][2]))
		cS500 = left(aSaid[i][1], 330)
		cS256 = left(cSmall, 330)
		c += "<div class='r'><div><img src='" + Thumb($cCo + aD[i][1], 200) + "' alt='" + Esc(aD[i][1]) + "'><p class='m'>COCO's main object: <b>" + Esc(aD[i][2]) + "</b></p></div>" +
			"<div><p class='m'>SmolVLM-256M " + Verdict(bSmall) + "</p><p>" + Esc(cS256) + "</p></div>" +
			"<div><p class='m'>SmolVLM-500M " + Verdict(aSaid[i][2]) + "</p><p>" + Esc(cS500) + "</p></div></div>"
	next
	c += "</main></body></html>"
	write(cPath, c)

func Verdict(b)
	if b return "<span class='ok'>names it</span>" ok
	return "<span class='no'>does not name it</span>"
