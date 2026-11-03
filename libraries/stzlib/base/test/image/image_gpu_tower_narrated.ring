# THE VISION TOWER ON THE GPU -- IM8a, narrated
#
# SOFTANZA_IMAGE_INTELLIGENCE.md IM8: a GPU tier for the heavy image operations, TWO PATHS ASSERTED TO AGREE, A MEASURED SPEED-UP.
# The measurement came first and chose the target: of the 65 s a page of Granite-Docling took, the tower (13 views of a SigLIP,
# 12 layers, 1024 tokens each) was 17 to 30 s, and the per-node GPU router (neural_gpu.zig), lowered to claim the tower's matmuls,
# made it SLOWER (3.3 to 3.7 s a view against 2.0 to 2.5 s) because every claimed node pays an upload and a readback. So the tower is
# built RESIDENT (engine/src/neural_vit.zig): the patches go up once, every layer is a dispatch in ONE batched pass, one readback.
#
# Three things were measured on the way and are in the module's comments: the generic matmul variant the table names for these shapes
# is 6.3 times slower than the register-tiled 8 x 8 (620 ms against 98 ms for the pass without attention); the backbone's attention,
# one workgroup per (head, row), re-reads every key and value from global memory (77 GB, a second), and its reduction variants made it
# worse at 1024 tokens (one lost the device); the flash form (32 rows a workgroup, keys and values through workgroup memory) took the
# whole pass from 1.9 s to about 0.45 s.
#
#   Scene 1  the two paths AGREE: one view, GPU tower against the CPU graph; then the page's 13 views against HUGGING FACE'S own
#            tower (the reference of _rig/granite_docling_reference.py): the GPU rows are the CPU graph's equal or better
#   Scene 2  the speed-up, MEASURED: the page's 13 views, the CPU graph and the GPU tower alternated, the median ratio
#   Scene 3  the switch and the fallback: the knob puts the CPU graph back (the counter does not move) and the rows are the CPU graph's
#   Scene 4  the page end to end: DocBlocks() through the GPU tower still finds the table, and the decoder fed the GPU rows agrees with
#            Hugging Face's words as before
#
# NEEDS what the tree does not carry: models/vision/granite_docling_258m*.gguf, the rendered pages, the reference fixtures, and a GPU.
# A scene the machine cannot run is SKIPPED BY NAME. ONE GPU JOB AT A TIME: two processes on the GPU crashed the driver (2026-11-03).
# THE HELPERS LIVE AFTER pf().

load "../../stzBase.ring"

$nPass = 0
$nFail = 0
$nSec = clock()
$cSrc = "D:/GitHub/_wti_models_src/"
$cPages = $cSrc + "doc_vlm_v1/"
$cPar = $cSrc + "parity/granite/"

pr()
decimals(3)
aSkipped = []
bModel = StzVisionHasModel($cStzVisionDocDecoder) and StzVisionHasModel($cStzVisionDocProjector)
bFix = fexists($cPages + "v2_e01.png") and fexists($cPar + "v2_e01_feat.f32")
if NOT (bModel and bFix)
	? "NOT RUN: the Granite-Docling models, the rendered pages (_rig/doc_vlm_render.py) or the reference fixtures (_rig/granite_docling_reference.py) are not installed"
	shutdown(1)
ok

cProj = StzVisionModelPath($cStzVisionDocProjector)
cDec = StzVisionModelPath($cStzVisionDocDecoder)
StzExpectModelDigest(cDec, $cStzVisionDocDecoderSha256)
StzEngineNeuralModelLoad(cDec)
$cStzVisionVlmSlot = cDec
oImg = StzImageQ($cPages + "v2_e01.png")
aG = StzEngineNeuralVlmGrid(oImg.Width(), oImg.Height(), $nStzVisionDocLongest, $nStzVisionDocTile)
aT = _StzVisionDocTexts(aG[1], aG[2], $cStzVisionDocRequest)
cJ = StzJoinWith(aT, char(31))
cHF = read($cPar + "v2_e01_feat.f32")

#=====================================================================#
? "-- Scene 1: the two paths agree --"
#=====================================================================#

chk("the GPU tower is ON by default (measured faster, and closer to the reference)", StzEngineNeuralVisionGpu(-1) = 1)
nV0 = StzEngineNeuralVisionGpuStats()[1]
# ONE view: the same picture through the tower both ways
StzEngineNeuralVisionGpu(0)
cOne0 = StzEngineNeuralVlmEmbed(cProj, oImg.Pixels(), oImg.Width(), oImg.Height(), oImg.Channels(), 4)
StzEngineNeuralVisionGpu(1)
cOne1 = StzEngineNeuralVlmEmbed(cProj, oImg.Pixels(), oImg.Width(), oImg.Height(), oImg.Channels(), 4)
aS = StzEngineNeuralVisionGpuStats()
aOne = StzEngineNeuralF32Compare(cOne1, cOne0)
? "  one view: GPU against CPU graph cosine " + aOne[1] + ", largest difference " + aOne[2] + " (rows up to " + aOne[3] + ")"
chk("the GPU tower made the view (stage " + aS[3] + " of 10, no failed step)", aS[1] = nV0 + 1 and aS[3] = 10 and aS[4] = 0)
chk("one view: the GPU rows agree with the CPU graph's (cosine >= 0.9995)", aOne[1] >= 0.9995)

# the page's 13 views, against Hugging Face's own tower
StzEngineNeuralVisionGpu(0)
cCpu = StzEngineNeuralVlmPage(cProj, oImg.Pixels(), oImg.Width(), oImg.Height(), oImg.Channels(), $nStzVisionDocLongest, cJ, -2, 4)
StzEngineNeuralVisionGpu(1)
cGpu = StzEngineNeuralVlmPage(cProj, oImg.Pixels(), oImg.Width(), oImg.Height(), oImg.Channels(), $nStzVisionDocLongest, cJ, -2, 4)
aCh = StzEngineNeuralF32Compare(cCpu, cHF)
aGh = StzEngineNeuralF32Compare(cGpu, cHF)
? "  the page's 13 views against Hugging Face's: CPU graph cosine " + aCh[1] + " largest difference " + aCh[2] +
	"; GPU tower cosine " + aGh[1] + " largest difference " + aGh[2] + " (rows up to " + aGh[3] + ")"
chk("the CPU graph agrees with Hugging Face's tower (cosine >= 0.9995: Q8 products)", aCh[1] >= 0.9995)
chk("the GPU tower agrees with Hugging Face's tower to 1e-4 of the largest row value (an f32 pass of dequantised weights, as the reference)",
	aGh[1] >= 0.99999 and aGh[2] < aGh[3] * 0.0001)
chk("...and is closer to it than the CPU graph, which quantises its activations (" + aGh[2] + " against " + aCh[2] + ")", aGh[2] < aCh[2])
sec("scene 1")

#=====================================================================#
? "-- Scene 2: the speed-up, measured --"
#=====================================================================#
# alternated, because this machine's ambient load moves the same code between 56 and 79 seconds: C G C G C G, the median of each
aC = []
aGp = []
for r = 1 to 3
	StzEngineNeuralVisionGpu(0)
	t0 = StzEngineWatchTimestampMs()
	StzEngineNeuralVlmPage(cProj, oImg.Pixels(), oImg.Width(), oImg.Height(), oImg.Channels(), $nStzVisionDocLongest, cJ, -2, 4)
	aC + (StzEngineWatchTimestampMs() - t0)
	StzEngineNeuralVisionGpu(1)
	t0 = StzEngineWatchTimestampMs()
	StzEngineNeuralVlmPage(cProj, oImg.Pixels(), oImg.Width(), oImg.Height(), oImg.Channels(), $nStzVisionDocLongest, cJ, -2, 4)
	aGp + (StzEngineWatchTimestampMs() - t0)
next
nMc = Median(aC)
nMg = Median(aGp)
nBc = Min(aC)
nBg = Min(aGp)
? "  the page's 13 views, three rounds each: CPU graph " + @@(aC) + " ms, GPU tower " + @@(aGp) + " ms"
? "  median " + floor(nMc) + " against " + floor(nMg) + " ms (" + (nMc / nMg) + " times); best round " + floor(nBc) + " against " + floor(nBg) + " ms (" + (nBc / nBg) + " times)"
# WHAT THE MEASUREMENTS SAY (RTX 3050 Laptop, 2026-11-03, the GPU shared with a browser and other sessions): 2.6 to 3.5 times on a free
# GPU, 1.1 to 1.9 times while another process holds it -- a GPU shared in time slows the GPU path far more than the CPU one, so a ratio
# is not a constant of the code. What does not move with the load is the DIRECTION at the best round, which is asserted; the range is
# in the design document, with the dates
chk("at its best round the GPU tower is faster than the CPU graph on the page's views (" + (nBc / nBg) + " times)", nBg < nBc)
sec("scene 2")

#=====================================================================#
? "-- Scene 3: the switch and the fallback --"
#=====================================================================#

nV1 = StzEngineNeuralVisionGpuStats()[1]
StzEngineNeuralVisionGpu(0)
chk("the knob answers its setting (0)", StzEngineNeuralVisionGpu(-1) = 0)
cOff = StzEngineNeuralVlmEmbed(cProj, oImg.Pixels(), oImg.Width(), oImg.Height(), oImg.Channels(), 4)
chk("with the knob off the GPU tower makes no view (the counter does not move)", StzEngineNeuralVisionGpuStats()[1] = nV1)
chk("...and the rows are the CPU graph's, bit for bit", StzEngineNeuralF32Compare(cOff, cOne0)[2] = 0)
StzEngineNeuralVisionGpu(1)
sec("scene 3")

#=====================================================================#
? "-- Scene 4: the page end to end --"
#=====================================================================#

aRef = StzSplit(read($cPar + "v2_e01_ref.txt"), char(10))
StzEngineNeuralVlmPage(cProj, oImg.Pixels(), oImg.Width(), oImg.Height(), oImg.Channels(), $nStzVisionDocLongest, cJ, -1, 4)
aTop = StzEngineNeuralVlmTop(2)
aRT = StzSplit(StzReplace(aRef[3], "top ", ""), " ")
aGen = StzSplit(StzReplace(aRef[4], "gen ", ""), " ")
nAgree = 0
nGn = len(aGen)
for q = 1 to nGn
	if StzEngineNeuralVlmTop(1)[1][1] = 0 + aGen[q] nAgree++ ok
	StzEngineNeuralVlmFeed(0 + aGen[q])
next
chk("fed the GPU tower's rows, the decoder's two likeliest tokens are Hugging Face's", aTop[1][1] = 0 + StzSplit(aRT[1], ":")[1] and aTop[2][1] = 0 + StzSplit(aRT[2], ":")[1])
chk("...and its next token is Hugging Face's at least " + (nGn - 3) + " times in " + nGn + " fed Hugging Face's words (" + nAgree + ")", nAgree >= nGn - 3)
t0 = clock()
aBk = oImg.DocBlocks()
nSecPage = (clock() - t0) / clockspersecond()
aS4 = StzEngineNeuralVlmStats()
nTab = 0
aTab = []
for i = 1 to len(aBk)
	if aBk[i][:kind] = "table" nTab++ aTab = aBk[i][:rows] ok
next
? "  v2_e01 end to end: " + aS4[3] + " tokens, the views " + floor(aS4[1]) + " ms, the words " + floor(aS4[2]) + " ms (" + nSecPage + " s)"
chk("the borderless table is still found, five rows of three, with its header and a body cell", nTab = 1 and len(aTab) = 5 and len(aTab[1]) = 3 and aTab[1][2] = "Yield (kg/ha)" and aTab[3][3] = "79")
sec("scene 4")

if len(aSkipped) > 0
	? "SKIPPED BY NAME, not run: " + len(aSkipped)
ok
? ""
? "ASSERTIONS: " + ($nPass + $nFail) + " -- " + $nPass + " passed, " + $nFail + " failed"
pf()
shutdown($nFail)

func Min(aL)
	nM = aL[1]
	for i = 2 to len(aL)
		if aL[i] < nM nM = aL[i] ok
	next
	return nM

func Median(aL)
	aS = sort(aL)
	return aS[ceil(len(aS) / 2)]

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
