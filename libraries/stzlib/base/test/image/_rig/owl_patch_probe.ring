# WSP-SPIKE-01 step 1: the engine reads the shift head, applies remove-direction to it, writes the patched GGUF, and the negative sibling is checked
load "../../stzBase.ring"
decimals(6)
$cV = StzVisionModelPath($cStzVisionOwlVision)
$cOut = StzVisionModelPath("owlvit_vision_shiftpatch.gguf")
? "tensors in the vision graph: " + len(StzEngineNeuralTensorNames($cV))
? "c210 (logit_shift): " + @@(StzEngineNeuralTensorInfo($cV, "c210")) + " | c211 (logit_scale): " + @@(StzEngineNeuralTensorInfo($cV, "c211")) + " | c208 (class head): " + @@(StzEngineNeuralTensorInfo($cV, "c208"))
aW = StzEngineNeuralTensorSlice($cV, "c210", 0, 768)
nNorm = 0
for i = 1 to len(aW) nNorm += aW[i] * aW[i] next
? "|w| of the shift head read by the engine: " + sqrt(nNorm) + " (owl_direction.py read 0.5966)"
cD = read("D:/GitHub/_wti_models_src/owlvit_wsp/direction.txt")
aR = StzEngineNeuralPatchRemoveDirection($cV, $cOut, "c210", 0, 1, cD)
? "patch: " + @@(aR) + " | " + StzEngineNeuralOcrGraphError()
aNames = StzEngineNeuralTensorNames($cV)
nSame = 0
aChanged = []
for i = 1 to len(aNames)
	if StzEngineNeuralTensorDigest($cV, aNames[i]) = StzEngineNeuralTensorDigest($cOut, aNames[i])
		nSame++
	else
		aChanged + aNames[i]
	ok
next
? "negative sibling: " + nSame + " of " + len(aNames) + " tensors digest the same; changed: " + @@(aChanged)
aW2 = StzEngineNeuralTensorSlice($cOut, "c210", 0, 768)
nDot = 0
nN2 = 0
for i = 1 to 768 nN2 += aW2[i] * aW2[i] next
? "|w'| = " + sqrt(nN2) + " (expected sqrt(0.5966^2 - 0.0603^2) = " + sqrt(0.5966 * 0.5966 - 0.0603 * 0.0603) + ")"
? "digest of the patched file: " + StzEngineModelDigest($cOut)
oImg = StzImageRawQ("D:/GitHub/_wti_models_src/coco/images/000000012576.jpg")
aH = _StzVisionOwlHeads(oImg)
? "heads of the warmest judging picture, original: mean shift " + aH[:meanShift] + " (ONNX Runtime read -0.534), max " + aH[:maxShift] + ", scale[1] " + aH[:scales][1]
oImg.Release()
shutdown(0)
