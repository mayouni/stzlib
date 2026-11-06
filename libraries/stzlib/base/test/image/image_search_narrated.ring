# PICTURES AND WORDS IN ONE SPACE -- IM5, narrated
#
# SOFTANZA_IMAGE_INTELLIGENCE.md IM5: SigLIP2 (Google, base patch16-224,
# Apache-2.0), two towers converted from ONNX by engine/tools/onnx_to_gguf.py
# and run on ggml by stz_neural; the text tower's Gemma tokenizer travels in
# its GGUF and runs in engine/src/bpe.zig. A picture and a text become 768
# numbers each, in ONE space: their cosine says how well the words describe
# the picture.
#
#   Scene 1  parity: tokens, text tower, image tower, end to end
#   Scene 2  ClassifyAs(): the caller's own labels, in any language
#   Scene 3  SimilarityTo(): one picture, one text
#   Scene 4  stzImageIndex: search 118 COCO images by text, judged by COCO
#   Scene 5  SearchLike(): pictures that resemble a picture
#   Scene 6  the door: every model run is a chained record in the ledger
#   Scene 7  what a person looks at: an HTML page
#
# NEEDS what the tree does not carry: the SigLIP2 GGUFs in models/vision,
# the photographs, the COCO images and the parity fixtures beside the
# sources (sha256 and licences in models/MODELS.md and the MANIFESTs).
# When absent, the guard says which and stops. THE HELPERS LIVE AFTER pf().

load "../../stzBase.ring"
load "_golden/coco_search_v1.ring"

$nPass = 0
$nFail = 0
$nSec = clock()
$cSrc = "D:/GitHub/_wti_models_src/"
$cPh = $cSrc + "photos/"
$cCo = $cSrc + "coco/images/"

cOut = StzReplace(WorkingDirectory(), "\", "/") + "/_search-out"
if NOT StzDirExists(cOut)
	StzDirCreatePath(cOut)
ok

if NOT StzVisionHasModel($cStzVisionImageEmbedder) or NOT StzVisionHasModel($cStzVisionTextEmbedder) or
   NOT fexists($cPh + "dog.jpg") or NOT fexists($cSrc + "parity/siglip2_text.tsv")
	? "NOT RUN: the SigLIP2 models (" + StzVisionModelsDir() + "), the photographs (" + $cPh +
		") or the parity fixtures are not installed -- see models/MODELS.md"
	shutdown(1)
ok

pr()
nCalls0 = StzVisionCallsRecorded()

#=====================================================================#
? "-- Scene 1: parity with HF tokenizers and onnxruntime --"
#=====================================================================#
# Written once by _rig/vision_parity.py: ten texts with the ids HF's
# tokenizers library gives and the text tower's output on them; the image
# tower on a fixed input; four photos embedded through PIL's resize.

decimals(7)
a = StzEngineNeuralOcrGraphParity(StzVisionModelPath($cStzVisionImageEmbedder), $cSrc + "parity/siglip2_vision_in.stzt",
	$cSrc + "parity/siglip2_vision_out.stzt", "", 4)
chk("the image tower agrees with onnxruntime (cosine " + a[4] + ", max diff " + a[2] + ", " + a[5] + " ms)",
	len(a) = 6 and a[4] > 0.99999 and a[2] < 0.001)

aL = str2list(read($cSrc + "parity/siglip2_text.tsv"))
nTexts = 0
nSameIds = 0
nWorst = 1
nLines = len(aL)
for i = 1 to nLines
	if aL[i] = "" loop ok
	nTexts++
	aF = StzSplit(aL[i], char(9))
	if len(aF) = 2
		aF = [ "", aF[1], aF[2] ]    # the empty text: its field vanished in the split
	ok
	if SameIds(StzVisionTokens(aF[1]), StzSplit(aF[2], " "))
		nSameIds++
	ok
	nC = CosineWithText(StzVisionTextEmbedding(aF[1]), aF[3])
	if nC < nWorst nWorst = nC ok
next
chk("Gemma's BPE gives HF's ids exactly, for " + nSameIds + " of " + nTexts +
	" texts (French, Arabic, an emoji, double and edge spaces, the empty text)", nSameIds = nTexts and nTexts = 10)
chk("the text tower agrees with onnxruntime on all " + nTexts + " (worst cosine " + nWorst + ")", nWorst > 0.99999)

aP = str2list(read($cSrc + "parity/siglip2_photos.tsv"))
nWorst = 1
nLines = len(aP)
for i = 1 to nLines
	if aP[i] = "" loop ok
	aF = StzSplit(aP[i], char(9))
	oImg = StzImageQ($cPh + aF[1])
	nC = CosineWithText(oImg.Embedding(), aF[2])
	oImg.Release()
	if nC < nWorst nWorst = nC ok
next
chk("end to end -- JPEG decode, PIL's resize, the tower -- the four photos agree (worst cosine " + nWorst + ")",
	nWorst > 0.9998)

decimals(3)
sec("scene 1")

#=====================================================================#
? "-- Scene 2: ClassifyAs() -- the caller's own labels --"
#=====================================================================#
# No class list is fixed in advance: the labels are whatever the caller
# writes, each put into "This is a photo of {}.".

aSets = [
	[ "dog.jpg", "a dog", [ "a dog", "a cat", "a car", "a crowd of people", "a pizza" ] ],
	[ "cat.jpg", "a cat", [ "a dog", "a cat", "a car", "a crowd of people", "a pizza" ] ],
	[ "crew.jpg", "a group of people", [ "a group of people", "a single animal", "an empty room", "a plate of food" ] ],
	[ "street.jpg", "a busy city street", [ "a busy city street", "a quiet beach", "a kitchen", "a forest" ] ],
	[ "street.jpg", "a city at night", [ "a city at night", "a city in daylight" ] ],
	[ "dog.jpg", "un chien", [ "un chien", "un chat", "une voiture" ] ],
	[ "dog.jpg", "كلب", [ "كلب", "قطة", "سيارة" ] ],
	[ "cat.jpg", "猫", [ "犬", "猫", "車" ] ]
]
aLang = [ "", "", "", "", "", " (French)", " (Arabic)", " (Japanese)" ]
aRanked = []
nSets = len(aSets)
for i = 1 to nSets
	oImg = StzImageQ($cPh + aSets[i][1])
	a = oImg.ClassifyAs(aSets[i][3])
	oImg.Release()
	aRanked + a
	chk(aSets[i][1] + ": the expected label comes first" + aLang[i] + ", " + a[1][:score] + " against " + a[2][:score],
		a[1][:label] = aSets[i][2])
next

sec("scene 2")

#=====================================================================#
? "-- Scene 3: SimilarityTo() --"
#=====================================================================#

oDog = StzImageQ($cPh + "dog.jpg")
oSt = StzImageQ($cPh + "street.jpg")
nDog = oDog.SimilarityTo("a dog running on grass")
nSt = oSt.SimilarityTo("a dog running on grass")
chk("'a dog running on grass' fits the dog (" + nDog + ") and not the street (" + nSt + ")", nDog > nSt + 0.05)
oDog.Release()
oSt.Release()

sec("scene 3")

#=====================================================================#
? "-- Scene 4: search 118 pictures by text, judged by COCO --"
#=====================================================================#
# The images: every COCO val2017 image IM4 fetched. The truth: the
# categories COCO's annotators marked in each (_golden/coco_search_v1.ring).
# The queries: every category marked in at least 4 images -- fixed by
# _rig/coco_search.py before any search ran -- each as "a photo of a ...".

aImgs = StzVisionSearchImagesV1()
aQ = StzVisionSearchQueriesV1()
nT0 = clock()
oIx = StzImageIndexQ()
nI = len(aImgs)
for i = 1 to nI
	oIx.AddImage($cCo + aImgs[i][1], aImgs[i][1])
next
nIxSec = (clock() - nT0) / clockspersecond()
chk("the index holds the " + nI + " pictures (embedded once, in " + nIxSec + " s)", oIx.NumberOfImages() = nI)

nP1 = 0
nP3 = 0
nRnd = 0
aTop = []
nQ = len(aQ)
for i = 1 to nQ
	a = oIx.SearchXT("a photo of a " + aQ[i], 4)
	aTop + a
	for k = 1 to 3
		if Marks(aImgs, a[k][:name], aQ[i])
			nP3 += 1 / 3
			if k = 1 nP1++ ok
		ok
	next
	nRnd += CountMarked(aImgs, aQ[i]) / nI
next
nP1 = nP1 / nQ
nP3 = nP3 / nQ
nRnd = nRnd / nQ
? "    precision at 1: " + nP1 + "   at 3: " + nP3 + "   a random order: " + nRnd + "   (" + nQ + " queries)"
chk("the first picture found shows what was asked in " + floor(nP1 * nQ + 0.5) + " of " + nQ + " queries -- " +
	"10 times a random order (" + nRnd + ")", nP1 > 10 * nRnd)
chk("...and three quarters of the first three do (" + nP3 + ")", nP3 >= 0.75)

sec("scene 4")

#=====================================================================#
? "-- Scene 5: SearchLike() -- pictures like a picture --"
#=====================================================================#

cLike = FirstMarked(aImgs, "pizza")
aLike = oIx.SearchLikeXT($cCo + cLike, 4)
chk("a picture is most like itself (" + aLike[1][:score] + ")", aLike[1][:name] = cLike and aLike[1][:score] > 0.999)
chk("...and the next two most like a pizza picture show a pizza too, by COCO",
	Marks(aImgs, aLike[2][:name], "pizza") and Marks(aImgs, aLike[3][:name], "pizza"))

sec("scene 5")

#=====================================================================#
? "-- Scene 6: the door --"
#=====================================================================#

nCalls = StzVisionCallsRecorded() - nCalls0
aKinds = StzSecurityLedgerQ().OfKind("model.call")
chk("every model run went through the door: " + nCalls + " ledger records (4 + 118 + 1 pictures at least)",
	nCalls >= 4 + 118 + 1)
chk("...and a text already embedded is not embedded twice: the 25 queries' second use costs no record",
	len(StzVisionTextEmbedding("a photo of a pizza")) = 768 and StzVisionCallsRecorded() - nCalls0 = nCalls)

sec("scene 6")

#=====================================================================#
? "-- Scene 7: what a person looks at --"
#=====================================================================#

WriteReport(cOut + "/im5_search.html", aSets, aRanked, aQ, aTop, aImgs, nP1, nP3, nRnd, cLike, aLike)
chk("the report page is written", fexists(cOut + "/im5_search.html"))

sec("scene 7")

? ""
? "=========================================="
? "TOTAL: " + ($nPass + $nFail) + " assertions, " + $nPass + " pass, " + $nFail + " fail"
? "=========================================="

pfq()
shutdown($nFail)

func SameIds(aMine, acTheirs)
	n = len(acTheirs)
	if len(aMine) != n
		return 0
	ok
	for k = 1 to n
		if aMine[k] != number(acTheirs[k])
			return 0
		ok
	next
	return 1

func CosineWithText(aV, cNumbers)
	aE = StzSplit(cNumbers, " ")
	nN = 0
	nD = 0
	n = len(aE)
	for k = 1 to n
		x = number(aE[k])
		nN += x * x
		nD += x * aV[k]
	next
	return nD / sqrt(nN)

func Marks(aImgs, cName, cCat)
	n = len(aImgs)
	for j = 1 to n
		if aImgs[j][1] = cName
			return find(aImgs[j][2], cCat) > 0
		ok
	next
	return 0

func CountMarked(aImgs, cCat)
	nC = 0
	n = len(aImgs)
	for j = 1 to n
		if find(aImgs[j][2], cCat) > 0 nC++ ok
	next
	return nC

func FirstMarked(aImgs, cCat)
	n = len(aImgs)
	for j = 1 to n
		if find(aImgs[j][2], cCat) > 0 return aImgs[j][1] ok
	next
	return ""

func Thumb(cPath, nW)
	o = StzImageQ(cPath)
	if o.Width() > nW
		o.ApplyResize(nW, floor(o.Height() * nW / o.Width()))
	ok
	c = "<img src='" + o.ToJpegDataURI(80) + "'>"
	o.Release()
	return c

func Esc(c)
	return StzReplace(StzReplace(StzReplace(c, "&", "&amp;"), "<", "&lt;"), ">", "&gt;")

func WriteReport(cPath, aSets, aRanked, aQ, aTop, aImgs, nP1, nP3, nRnd, cLike, aLike)
	c = "<!doctype html><html><head><meta charset='utf-8'><meta name='viewport' content='width=device-width'>" +
		"<title>Pictures and words</title>" +
		"<style>body{font:16px/1.5 system-ui,sans-serif;max-width:1100px;margin:24px auto;padding:0 16px;color:#111;background:#fff}" +
		"h1{font-size:26px}h2{font-size:20px;margin-top:34px}img{max-width:100%;display:block}" +
		".grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(240px,1fr));gap:14px}" +
		".cell{border:1px solid #ddd;padding:8px}.row{display:flex;align-items:center;gap:8px;margin:3px 0}" +
		".lab{width:150px;flex:none}.bar{height:14px;background:#2c6fd6}.bar.first{background:#126b2a}" +
		".hit{border:4px solid #126b2a}.miss{border:4px solid #c22}.cap{font-size:15px;color:#333}" +
		".q{display:grid;grid-template-columns:repeat(4,1fr);gap:8px;margin-bottom:6px}" +
		".note{color:#333}code{background:#f2f2f2;padding:1px 5px;border-radius:4px}</style></head><body>" +
		"<h1>Pictures and words in one space (IM5)</h1>" +
		"<p class='note'>SigLIP2 turns a picture into 768 numbers and a text into 768 numbers in the SAME space. The cosine " +
		"between them says how well the words describe the picture. A score is a cosine, not a probability: what " +
		"carries meaning is the order, and the gap between the first answer and the second.</p>"
	c += "<h2>ClassifyAs() -- your own labels, in any language</h2><p class='note'><code>oImg.ClassifyAs([ " +
		"&quot;a dog&quot;, &quot;a cat&quot;, &quot;a car&quot; ])</code>. Green: the label ranked first.</p><div class='grid'>"
	n = len(aSets)
	for i = 1 to n
		c += "<div class='cell'>" + Thumb($cPh + aSets[i][1], 360)
		a = aRanked[i]
		nMax = a[1][:score]
		for k = 1 to len(a)
			nW = 0
			if a[k][:score] > 0 nW = floor(a[k][:score] / nMax * 100) ok
			cCls = "bar"
			if k = 1 cCls = "bar first" ok
			c += "<div class='row'><span class='lab'>" + Esc(a[k][:label]) + "</span><span class='" + cCls +
				"' style='width:" + nW + "px'></span><span class='cap'>" + a[k][:score] + "</span></div>"
		next
		c += "</div>"
	next
	c += "</div><h2>Search 118 pictures by text</h2><p class='note'><code>oIndex.Search(&quot;a photo of a pizza&quot;)</code>. " +
		"The four best of each query; a GREEN frame when COCO's annotators marked that thing in the picture, RED when " +
		"not. Over the " + len(aQ) + " queries (every category COCO marks in at least 4 of the pictures): the first " +
		"picture is right " + floor(nP1 * 100 + 0.5) + "% of the time, the first three " + floor(nP3 * 100 + 0.5) +
		"%; a random order would be right " + floor(nRnd * 100 + 0.5) + "%.</p>"
	nQ = len(aQ)
	for i = 1 to nQ
		c += "<p><b>a photo of a " + Esc(aQ[i]) + "</b></p><div class='q'>"
		for k = 1 to 4
			cCls = "miss"
			if Marks(aImgs, aTop[i][k][:name], aQ[i]) cCls = "hit" ok
			c += "<div><div class='" + cCls + "'>" + Thumb($cCo + aTop[i][k][:name], 260) + "</div><span class='cap'>" +
				aTop[i][k][:score] + "</span></div>"
		next
		c += "</div>"
	next
	c += "<h2>SearchLike() -- pictures like a picture</h2><p class='note'>The query picture first (a picture is most " +
		"like itself), then the three most like it; green when COCO marks a pizza.</p><div class='q'>"
	for k = 1 to 4
		cCls = "miss"
		if Marks(aImgs, aLike[k][:name], "pizza") cCls = "hit" ok
		c += "<div><div class='" + cCls + "'>" + Thumb($cCo + aLike[k][:name], 260) + "</div><span class='cap'>" +
			aLike[k][:score] + "</span></div>"
	next
	c += "</div><p class='note'>Photographs: Wikimedia Commons (licences in photos/MANIFEST.tsv). COCO val2017 images: " +
		"each under its own Creative Commons licence (coco_v1.ring); annotations CC BY 4.0, cocodataset.org. " +
		"Model: SigLIP2 base patch16-224, Google, Apache-2.0.</p></body></html>"
	write(cPath, c)

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
