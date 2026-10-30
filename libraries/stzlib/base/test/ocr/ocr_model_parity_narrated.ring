# ocr_model_parity_narrated.ring -- the PP-OCR graphs on ggml agree with onnxruntime (OCR slice O3, first proof).
#
# engine/tools/onnx_to_gguf.py turns each PP-OCR network (detector, recogniser, angle classifier) into a GGUF
# that carries its weights and a program over ggml ops; engine/src/ocr_graph.zig (stz_neural) runs it. Before
# any OCR text is read through those graphs, each one is run on a FIXED input and compared with onnxruntime's
# output on the same input (tools/gen_ocr_parity.py wrote both files once, in _data/parity/). The band: a max
# absolute difference under 1e-3 on the detector's probability map and the classifier's two probabilities,
# cosine above 0.9999 everywhere, and the recogniser's argmax per CTC step identical.
#
# O3c adds the per-script recognisers (PP-OCRv5 mobile Arabic and Cyrillic, fetched from the URLs and SHA-256 in
# rapidocr/default_models.yaml): ppocr_rec_arabic.gguf and ppocr_rec_cyrillic.gguf, held to the recogniser's band.
#
# The models are NOT in the repository (*.gguf is ignored): they live in libraries/stzlib/models/ocr/, written by
# the converter from the Docling venv's rapidocr files. A model that is absent SKIPS its scene by name.
#
#   cd libraries/stzlib/base/test/ocr ; rnxc ocr_model_parity_narrated.ring

load "../../stzBase.ring"
load "../_narrated.ring"

$cModels = StzModelsDir() + "/ocr/"
$cParity = "_data/parity/"
$nThreads = 4

aKinds = [ "cls", "det", "rec", "rec_arabic", "rec_cyrillic" ]
nK = len(aKinds)
for i = 1 to nK
	cKind = aKinds[i]
	cModel = $cModels + "ppocr_" + cKind + ".gguf"
	if NOT fexists(cModel)
		? "SKIP: the " + cKind + " graph -- no " + cModel + " (write it with engine/tools/onnx_to_gguf.py)"
		loop
	ok
	Scenario("The " + cKind + " graph loads from its GGUF and is the converter's program")
		aI = StzEngineNeuralOcrGraphInfo(cModel)
		Then("the file is an OCR graph of that kind", aI[1], left(cKind, 3))
		Then("with ops", aI[2] > 100, 1)
		Then("and parameters", aI[4] > 100000, 1)
	EndScenario()

	Scenario("The " + cKind + " graph on ggml agrees with onnxruntime on a fixed input")
		aR = parityOf(cKind)
		Then("the engine ran it", len(aR) = 6, 1)
		if len(aR) = 6
			Then("the output has the expected number of values", aR[1] > 1, 1)
			Then("cosine with onnxruntime above 0.9999", aR[4] > 0.9999, 1)
			if left(cKind, 3) = "rec"
				Then("the argmax of every CTC step agrees", aR[6], 1)
				Then("max abs difference under 1e-2 on the probabilities", aR[2] < 0.01, 1)
			else
				Then("max abs difference under 1e-3", aR[2] < 0.001, 1)
			ok
		ok
	EndScenario()
next

Summary()

func parityOf(cKind)
	aR = StzEngineNeuralOcrGraphParity($cModels + "ppocr_" + cKind + ".gguf", $cParity + cKind + "_in.bin",
	                                   $cParity + cKind + "_exp.bin", sysget("TEMP") + "\stz_ocr_parity_" + cKind + ".bin", $nThreads)
	if len(aR) = 0 or isString(aR[1])
		? "   ENGINE: " + StzEngineNeuralOcrGraphError() + " " + @@(aR)
		return []
	ok
	? "   " + cKind + ": n " + aR[1] + "  max|d| " + aR[2] + "  mean|d| " + aR[3] + "  cosine " + aR[4] + "  argmax agree " + aR[6] + "  ms " + aR[5]
	return aR
