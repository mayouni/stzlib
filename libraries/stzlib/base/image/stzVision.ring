#=====================================================================#
#  STZVISION -- the image plane's models, behind ONE governed door   #
#  (IM3 of SOFTANZA_IMAGE_INTELLIGENCE.md)                           #
#=====================================================================#
/*
	The models are converted from ONNX by engine/tools/onnx_to_gguf.py
	and run on ggml by stz_neural (engine/src/vision.zig): MobileNetV3
	(classify), YuNet (faces), YOLOX (objects). Their files live in
	models/vision/ -- local assets, git-ignored, recorded with their
	sha256 in models/MODELS.md.

	THE DOOR. Every model call goes through _StzVisionDoor, which writes a
	chained record to the security ledger BEFORE the answer returns: which
	faculty, which model file, what it found, how long it took. When no
	ledger is open the door OPENS the process ledger first -- no face can
	switch the record off (COMPASS-KERN-05). A missing model is a refusal
	that names the file, never a silent empty answer.

	WHAT IS NOT HERE: face IDENTIFICATION. Faces() finds faces and their
	landmarks; it never says whose they are. Recognising a person is a
	governed act behind a declared risk and a grant, and no model for it
	is in the kit.
*/

$cStzVisionClassifier = "mobilenetv3_large.gguf"
$cStzVisionFaceModel = "yunet_2023mar.gguf"
$cStzVisionObjectModel = "yolox_tiny.gguf"

# The folder the vision models are read from: <models>/vision.
func StzVisionModelsDir()
	return StzModelsDir() + "/vision"

# The full path of a vision model file.
func StzVisionModelPath(pcFile)
	return StzVisionModelsDir() + "/" + pcFile

# TRUE when the model file is installed.
func StzVisionHasModel(pcFile)
	return fexists(StzVisionModelPath(pcFile))

# TRUE when the three default models -- classifier, faces, objects -- are installed.
func StzVisionModelsInstalled()
	return StzVisionHasModel($cStzVisionClassifier) and StzVisionHasModel($cStzVisionFaceModel) and
		StzVisionHasModel($cStzVisionObjectModel)

# The compute time of the last model call, in milliseconds.
func StzVisionLastMs()
	return StzEngineNeuralVisionMs()

# How many model calls the process ledger holds.
func StzVisionCallsRecorded()
	if NOT StzSecurityLedgerIsOpen()
		return 0
	ok
	return len(StzSecurityLedgerQ().OfKind("model.call"))

func _StzVisionModelOrRaise(pcFile, pcFaculty)
	_cP_ = StzVisionModelPath(pcFile)
	if NOT fexists(_cP_)
		stzraise("stzImage." + pcFaculty + ": the model " + pcFile + " is not installed in " +
			StzVisionModelsDir() + " -- convert it with engine/tools/onnx_to_gguf.py (see models/MODELS.md).")
	ok
	return _cP_

# THE DOOR: record the call in the chained ledger before the answer goes back.
func _StzVisionDoor(pcFaculty, pcFile, pcWhat)
	if NOT StzSecurityLedgerIsOpen()
		StzOpenSecurityLedger(4096)
	ok
	StzNoteFact("model.call", "stzImage", pcFile, pcFaculty + ": " + pcWhat + " in " +
		StzEngineNeuralVisionMs() + " ms")

func _StzVisionFailed(pcFaculty, pcFile)
	_StzVisionDoor(pcFaculty, pcFile, "FAILED -- " + StzEngineNeuralOcrGraphError())
	stzraise("stzImage." + pcFaculty + ": " + StzEngineNeuralOcrGraphError())

# A colour as [ r, g, b ]: from a list, a "#rrggbb" text, or a name the plane knows.
func StzVisionColor(pColor)
	if isList(pColor) and len(pColor) = 3
		return pColor
	ok
	_c_ = StzLower("" + pColor)
	_aNames_ = [ :red = [ 230, 40, 40 ], :green = [ 30, 180, 60 ], :blue = [ 40, 110, 230 ],
		:yellow = [ 245, 200, 20 ], :orange = [ 245, 130, 20 ], :white = [ 255, 255, 255 ],
		:black = [ 0, 0, 0 ], :magenta = [ 220, 40, 200 ], :cyan = [ 20, 200, 220 ] ]
	if HasKey(_aNames_, _c_)
		return _aNames_[_c_]
	ok
	if len(_c_) = 7 and _c_[1] = "#"
		return [ dec(_c_[2] + _c_[3]), dec(_c_[4] + _c_[5]), dec(_c_[6] + _c_[7]) ]
	ok
	stzraise("StzVisionColor: a colour is [ r, g, b ], #rrggbb or a name (red, green, blue, yellow, " +
		"orange, white, black, magenta, cyan).")
