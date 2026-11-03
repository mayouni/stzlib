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
$cStzVisionSaliencyModel = "u2netp.gguf"     # IM6: the salient object (SalientMask, BackgroundRemoved)
$cStzVisionDepthModel = "depth_anything_v2_small.gguf"   # IM6: relative depth (DepthMap)
$cStzVisionSamEncoder = "mobile_sam_encoder.gguf"   # IM6: the object at a point (MaskAt, MaskInBox, CutOutAt)
# IM7: a picture in words (Describe, Ask) -- SmolVLM-256M-Instruct, its decoder in the engine's model slot and its
# SigLIP tower in a slot of its own; the decoder loads only with this digest (models/MODELS.md)
$cStzVisionVlmDecoder = "smolvlm_256m.gguf"
$cStzVisionVlmProjector = "smolvlm_256m_mmproj.gguf"
$cStzVisionVlmDecoderSha256 = "2a31195d3769c0b0fd0a4906201666108834848db768af11de1d2cef7cd35e65"
$nStzVisionVlmWidth = 576
$cStzVisionVlmSlot = ""
# the floor of :describe: a FIXED sentence naming the category that is the main object of the most COCO val2017
# pictures outside the golden set (_rig/coco_describe.py prints it), so it is not tuned on what judges it
$cStzVisionDescribeFloor = "A picture of a person."

# IM7 2 of 2: a scanned PAGE as structure (:doc-vlm) -- Granite-Docling-258M, whose projector is the same
# idefics3 tower as SmolVLM's. The page is read as Idefics3 reads it: resized to 2048 on its long side, cut into
# 512 x 512 tiles, one more view of the whole page, 64 rows each; the model answers in DocTags (stzDocTags.ring)
$cStzVisionDocDecoder = "granite_docling_258m.gguf"
$cStzVisionDocProjector = "granite_docling_258m_mmproj.gguf"
$cStzVisionDocDecoderSha256 = "b687245c212b59da938e411e2d4485596cbaeed1ae52706582ac38ed6a970f76"
$nStzVisionDocLongest = 2048
$nStzVisionDocTile = 512
$nStzVisionDocMaxTokens = 2048
# a greedy page can fall into a loop of one line over and over (3 of the first 31 golden pages did, to the old cap
# of 3072 tokens, about 280 s each): the engine's own stop on an identical line N times in a row. The longest answer
# a page needed was 934 tokens, so 2048 leaves more than double
$nStzVisionDocStopRepeat = 3
$cStzVisionDocRequest = "Convert this page to docling."
# the language the FLOOR reads the page's scan in: Granite-Docling is an English model
$cStzVisionDocFloorLang = "en-US"
$cStzVisionSamDecoder = "mobile_sam_decoder.gguf"

# YuNet's score threshold. OpenCV's default is 0.9; 0.5 was CHOSEN ON A DEV SET kept apart from the
# golden one (_golden/coco_dev_faces.ring, 30 COCO images after faces_v1): 27 of 30 images agree at
# 0.5, 20 of 30 at 0.9, against the platform's 25. 0.5 was the lowest value swept (2026-11-02).
$nStzVisionFaceThreshold = 0.5

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
	_cWhat_ = pcFaculty + ": " + pcWhat + " in " + StzEngineNeuralVisionMs() + " ms"
	if $cStzCaller != ""
		# IM9a: an agent is acting -- the record says which one (the origin field)
		StzNoteFactFrom("model.call", "stzImage", pcFile, _cWhat_, "agent:" + $cStzCaller)
		return
	ok
	StzNoteFact("model.call", "stzImage", pcFile, _cWhat_)

# IM6: the id of a picture's MobileSAM embedding in the engine. The engine keys it by the pixels, so a picture
# already encoded is not encoded again, and only an encoding that ran goes through the door.
func _StzVisionSamEmbedding(poImg, pcFaculty)
	_cE_ = _StzVisionModelOrRaise($cStzVisionSamEncoder, pcFaculty)
	_n_ = StzEngineNeuralVisionSamEmbed(_cE_, poImg.Pixels(), poImg.Width(), poImg.Height(), poImg.Channels(), 4)
	if _n_ = 0
		_StzVisionFailed(pcFaculty, $cStzVisionSamEncoder)
	ok
	if StzEngineNeuralVisionSamLast()[3] = 0
		_StzVisionDoor("object-at", $cStzVisionSamEncoder, "the embedding of a " + poImg.Width() + " x " +
			poImg.Height() + " picture")
	ok
	return _n_

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

#---------------------------------------------------------------------#
#  THE FACULTIES (IM4) -- each model must EARN its faculty: it answers #
#  instead of the floor only once measured STRICTLY better on a golden #
#  set whose truth someone else wrote (SOFTANZA_MODEL_FLOW.md)         #
#---------------------------------------------------------------------#
/*
	:faces        image -> record   floor: the platform's face detector
	                                (Windows.Media.FaceAnalysis, not a
	                                neural model); model: YuNet
	:objects      image -> record   floor: "nothing found" -- the floor
	                                knows no object; models: YOLOX-nano,
	                                YOLOX-tiny (the registry picks between
	                                them too)
	:image-label  image -> label    floor: a FIXED answer, "chair" -- the
	                                vocabulary category in the most COCO
	                                val2017 images OUTSIDE the golden set
	                                (_rig/coco_golden.py prints it), so the
	                                floor is not tuned on what judges it;
	                                model: MobileNetV3, its ImageNet labels
	                                mapped to COCO categories (StzVisionCocoOf)
	:foreground   image -> record   (IM6) floor: the classical foreground
	                                (what is not the border colour); model:
	                                U2-Net-p
	:object-at    record -> record  (IM6) [ image, x, y ] -> the mask of the
	                                object under the point; floor: the region
	                                of the classical foreground holding the
	                                point; model: MobileSAM
	:depth        image -> record   (IM6) relative depth; floor: the lower
	                                in the picture, the nearer; model:
	                                Depth-Anything-V2-Small; judged on
	                                DIODE's laser scans (diode-v1)
	:describe     image -> text     (IM7) the picture in words; floor: a
	                                FIXED sentence, "A picture of a person."
	                                ($cStzVisionDescribeFloor); model:
	                                SmolVLM-256M; judged by whether it names
	                                the main object COCO annotated
	                                (coco-describe-v1)
	:doc-vlm      image -> record   (IM7) a scanned page as structure: its
	                                blocks (headings, paragraphs, lists,
	                                tables, captions, furniture); floor: the
	                                native PDF reader on the page as a scan
	                                (OCR, then its own layout rules); model:
	                                Granite-Docling-258M; and the two
	                                combined (native-plus-granite); judged on
	                                the independent golden documents'
	                                expected structure (doc-vlm-v2, fresh; v1
	                                was a tie of the first two)

	The golden sets come from COCO's own annotations (CC BY 4.0), never
	from this code: base/test/image/_golden/coco_v1.ring, written by
	_rig/coco_golden.py by fixed rules before any model ran. The
	measurements are filed in base/image/vision.zmdl.txt so a process
	that has not measured still rules on them.
*/

# Declares the three vision faculties (create-or-open); paGoldens, when given, is
# [ [ :faces, aItems ], [ :objects, aItems ], [ "image-label", aItems ] ] of [ input, expected ] pairs.
func StzVisionDeclare(paGoldens)
	_oF_ = StzFacultyQ(:faces)
	_oF_.SetInputTypeQ(:image).SetOutputTypeQ(:record).SetFloorQ("platform", "_StzVisionFacesPlatform").
	     SetGoldenCheckerQ("faces-anchors").SetGoldenVersionQ("coco-v1")
	if len(StzFind("yunet", _oF_.ImplementationIds())) = 0
		_oF_.AddImplementation([ :id = "yunet", :kind = "graph", :fn = "_StzVisionFacesYunet",
			:needle = "vision/" + $cStzVisionFaceModel, :licence = "mit", :memory = 50 ])
	ok
	_oO_ = StzFacultyQ(:objects)
	_oO_.SetInputTypeQ(:image).SetOutputTypeQ(:record).SetFloorQ("nothing", "_StzVisionObjectsNone").
	     SetGoldenCheckerQ("boxes-f1").SetGoldenVersionQ("coco-v1")
	if len(StzFind("yolox-nano", _oO_.ImplementationIds())) = 0
		_oO_.AddImplementation([ :id = "yolox-nano", :kind = "graph", :fn = "_StzVisionObjectsNano",
			:needle = "vision/yolox_nano.gguf", :licence = "apache-2.0", :memory = 60 ])
		_oO_.AddImplementation([ :id = "yolox-tiny", :kind = "graph", :fn = "_StzVisionObjectsTiny",
			:needle = "vision/yolox_tiny.gguf", :licence = "apache-2.0", :memory = 120 ])
	ok
	_oL_ = StzFacultyQ("image-label")
	_oL_.SetInputTypeQ(:image).SetOutputTypeQ(:label).SetFloorQ("prior", "_StzVisionLabelPrior").
	     SetGoldenCheckerQ("lower").SetGoldenVersionQ("coco-v1")
	if len(StzFind("mobilenetv3", _oL_.ImplementationIds())) = 0
		_oL_.AddImplementation([ :id = "mobilenetv3", :kind = "graph", :fn = "_StzVisionLabelMobilenet",
			:needle = "vision/" + $cStzVisionClassifier, :licence = "apache-2.0", :memory = 80 ])
	ok
	if len(StzFind("siglip2", _oL_.ImplementationIds())) = 0
		_oL_.AddImplementation([ :id = "siglip2", :kind = "graph", :fn = "_StzVisionLabelSiglip",
			:needle = "vision/" + $cStzVisionTextEmbedder, :licence = "apache-2.0", :memory = 1600 ])
	ok
	_oG_ = StzFacultyQ(:foreground)
	_oG_.SetInputTypeQ(:image).SetOutputTypeQ(:record).SetFloorQ("classical", "_StzVisionForegroundClassic").
	     SetGoldenCheckerQ("mask-iou").SetGoldenVersionQ("coco-v1")
	if len(StzFind("u2netp", _oG_.ImplementationIds())) = 0
		_oG_.AddImplementation([ :id = "u2netp", :kind = "graph", :fn = "_StzVisionForegroundU2netp",
			:needle = "vision/" + $cStzVisionSaliencyModel, :licence = "apache-2.0", :memory = 40 ])
	ok
	# IM6: the object under a point -- the input is [ image path, x, y ], the point 1-based
	_oA_ = StzFacultyQ("object-at")
	_oA_.SetInputTypeQ(:record).SetOutputTypeQ(:record).SetFloorQ("classical", "_StzVisionObjectAtClassic").
	     SetGoldenCheckerQ("mask-iou").SetGoldenVersionQ("coco-v1")
	if len(StzFind("mobilesam", _oA_.ImplementationIds())) = 0
		_oA_.AddImplementation([ :id = "mobilesam", :kind = "graph", :fn = "_StzVisionObjectAtSam",
			:needle = "vision/" + $cStzVisionSamEncoder, :licence = "apache-2.0", :memory = 120 ])
	ok
	# IM6: relative depth, judged on DIODE's laser scans (the expected value is a scan's base path)
	_oD_ = StzFacultyQ(:depth)
	_oD_.SetInputTypeQ(:image).SetOutputTypeQ(:record).SetFloorQ("lower-is-nearer", "_StzVisionDepthPrior").
	     SetGoldenCheckerQ("depth-absrel").SetGoldenVersionQ("diode-v1")
	if len(StzFind("depth-anything-v2-small", _oD_.ImplementationIds())) = 0
		_oD_.AddImplementation([ :id = "depth-anything-v2-small", :kind = "graph", :fn = "_StzVisionDepthDa2",
			:needle = "vision/" + $cStzVisionDepthModel, :licence = "apache-2.0", :memory = 400 ])
	ok
	# IM7: the picture in words, judged by whether they name the main object COCO annotated
	_oV_ = StzFacultyQ(:describe)
	_oV_.SetInputTypeQ(:image).SetOutputTypeQ(:text).SetFloorQ("fixed", "_StzVisionDescribeFixed").
	     SetGoldenCheckerQ("names-main-object").SetGoldenVersionQ("coco-describe-v1")
	if len(StzFind("smolvlm-256m", _oV_.ImplementationIds())) = 0
		_oV_.AddImplementation([ :id = "smolvlm-256m", :kind = "graph", :fn = "_StzVisionDescribeSmolvlm",
			:needle = "vision/" + $cStzVisionVlmDecoder, :licence = "apache-2.0", :memory = 700 ])
	ok
	# IM7 2 of 2: a scanned page as structure, judged against the golden documents' expected structure
	_oX_ = StzFacultyQ("doc-vlm")
	_oX_.SetInputTypeQ(:image).SetOutputTypeQ(:record).SetFloorQ("native-reader", "_StzVisionDocFloor").
	     SetGoldenCheckerQ("doc-blocks").SetGoldenVersionQ("doc-vlm-v2")
	if len(StzFind("granite-docling-258m", _oX_.ImplementationIds())) = 0
		_oX_.AddImplementation([ :id = "granite-docling-258m", :kind = "graph", :fn = "_StzVisionDocGranite",
			:needle = "vision/" + $cStzVisionDocDecoder, :licence = "apache-2.0", :memory = 900 ])
	ok
	# the two readers err on different things: the combination takes the model's tables and headings and the native
	# reader's text, lists and furniture (StzDocBlocksCombine, a rule written down before any golden-v2 page was read)
	if len(StzFind("native-plus-granite", _oX_.ImplementationIds())) = 0
		_oX_.AddImplementation([ :id = "native-plus-granite", :kind = "graph", :fn = "_StzVisionDocCombined",
			:needle = "vision/" + $cStzVisionDocDecoder, :licence = "apache-2.0", :memory = 900 ])
	ok
	if len(StzMeasurementOf("faces", "platform", "coco-v1")) = 0 and fexists(StzVisionMeasurementsFile())
		StzLoadMeasurements(StzVisionMeasurementsFile())
	ok
	if isList(paGoldens)
		_n_ = len(paGoldens)
		for _i_ = 1 to _n_
			_oG_ = StzFacultyQ(paGoldens[_i_][1])
			if len(_oG_.Goldens()) = 0
				_aIt_ = paGoldens[_i_][2]
				_m_ = len(_aIt_)
				for _j_ = 1 to _m_
					_oG_.AddGolden(_aIt_[_j_][1], _aIt_[_j_][2])
				next
			ok
		next
	ok

# The measurements shipped with the library: base/image/vision.zmdl.txt.
func StzVisionMeasurementsFile()
	_e_ = $cEngineDir
	if isString(_e_) and len(_e_) >= 7 and right(_e_, 7) = "/engine"
		return left(_e_, len(_e_) - 7) + "/base/image/vision.zmdl.txt"
	ok
	return ""

# -- the floors ---------------------------------------------------------

# the platform's own face detector (Windows.Media.FaceAnalysis): classical, not a neural model;
# elsewhere there is no platform floor and the faculty says so
func _StzVisionFacesPlatform(pImage, paParams)
	if NOT isWindows()
		stzraise("faces: no platform face detector here (Windows.Media.FaceAnalysis is Windows-only).")
	ok
	_cOut_ = StzSystem("powershell -NoProfile -ExecutionPolicy Bypass -File " + _StzVisionFaceBridgePath() +
		' -Path "' + StzReplace("" + pImage, "/", "\") + '"')
	_aOut_ = []
	_aL_ = StzSplit(_cOut_, char(10))
	_n_ = len(_aL_)
	for _i_ = 1 to _n_
		_c_ = ring_trim(StzReplace(_aL_[_i_], char(13), ""))
		if StzLeft(_c_, 5) != "FACE "
			loop
		ok
		_aV_ = StzSplit(StzMidToEnd(_c_, 6), " ")
		if len(_aV_) = 4
			_aOut_ + [ :box = [ (0 + _aV_[1]) + 1, (0 + _aV_[2]) + 1, 0 + _aV_[3], 0 + _aV_[4] ], :score = 1 ]
		ok
	next
	return _aOut_

func _StzVisionFaceBridgePath()
	_cP_ = sysget("TEMP") + "\stz_face_bridge_v1.ps1"
	if NOT fexists(_cP_)
		write(_cP_, _StzVisionFaceBridgeScript())
	ok
	return _cP_

func _StzVisionFaceBridgeScript()
	_n_ = char(10)
	return "# stz_face_bridge_v1.ps1 -- Softanza's :faces floor on Windows: Windows.Media.FaceAnalysis" + _n_ +
	"param([string]$Path = '')" + _n_ +
	"$null = [Windows.Media.FaceAnalysis.FaceDetector, Windows.Media.FaceAnalysis, ContentType=WindowsRuntime]" + _n_ +
	"$null = [Windows.Graphics.Imaging.BitmapDecoder, Windows.Graphics.Imaging, ContentType=WindowsRuntime]" + _n_ +
	"$null = [Windows.Storage.StorageFile, Windows.Storage, ContentType=WindowsRuntime]" + _n_ +
	"Add-Type -AssemblyName System.Runtime.WindowsRuntime" + _n_ +
	"$asTaskGeneric = ([System.WindowsRuntimeSystemExtensions].GetMethods() | Where-Object { $_.Name -eq 'AsTask' -and $_.GetParameters().Count -eq 1 -and $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncOperation`1' })[0]" + _n_ +
	"function Await($op, $type) { $t = $asTaskGeneric.MakeGenericMethod($type).Invoke($null, @($op)); $t.Wait(-1) | Out-Null; $t.Result }" + _n_ +
	"if (-not [Windows.Media.FaceAnalysis.FaceDetector]::IsSupported) { 'NO DETECTOR'; exit 2 }" + _n_ +
	"$file = Await ([Windows.Storage.StorageFile]::GetFileFromPathAsync($Path)) ([Windows.Storage.StorageFile])" + _n_ +
	"$stream = Await ($file.OpenAsync([Windows.Storage.FileAccessMode]::Read)) ([Windows.Storage.Streams.IRandomAccessStream])" + _n_ +
	"$decoder = Await ([Windows.Graphics.Imaging.BitmapDecoder]::CreateAsync($stream)) ([Windows.Graphics.Imaging.BitmapDecoder])" + _n_ +
	"$bmp = Await ($decoder.GetSoftwareBitmapAsync()) ([Windows.Graphics.Imaging.SoftwareBitmap])" + _n_ +
	"$gray = [Windows.Graphics.Imaging.SoftwareBitmap]::Convert($bmp, [Windows.Graphics.Imaging.BitmapPixelFormat]::Gray8)" + _n_ +
	"$det = Await ([Windows.Media.FaceAnalysis.FaceDetector]::CreateAsync()) ([Windows.Media.FaceAnalysis.FaceDetector])" + _n_ +
	"$faces = Await ($det.DetectFacesAsync($gray)) ([System.Collections.Generic.IList[Windows.Media.FaceAnalysis.DetectedFace]])" + _n_ +
	"foreach ($f in $faces) { 'FACE {0} {1} {2} {3}' -f $f.FaceBox.X, $f.FaceBox.Y, $f.FaceBox.Width, $f.FaceBox.Height }" + _n_

# the floor that knows no object: it finds nothing, and any model must do better than that
func _StzVisionObjectsNone(pImage, paParams)
	return []

# IM6: the classical answer -- what is not the border-coloured background (stzImage.ForegroundMask, IM2)
func _StzVisionForegroundClassic(pImage, paParams)
	_o_ = StzImageQ("" + pImage)
	_oM_ = _o_.ForegroundMask()
	_a_ = [ :width = _oM_.Width(), :height = _oM_.Height(), :mask = _oM_.Pixels() ]
	_oM_.Release()
	_o_.Release()
	return _a_

# IM6: the classical answer for a point -- the region of the classical foreground (ForegroundMask) that holds
# the point, connected through its own pixels; nothing when the point falls on what it calls background
func _StzVisionObjectAtClassic(pInput, paParams)
	_o_ = StzImageQ("" + pInput[1])
	_oM_ = _o_.ForegroundMask()
	_oC_ = _oM_._New(StzEngineImageComponentAt(_oM_.Handle(), pInput[2], pInput[3], 128))
	_a_ = [ :width = _oC_.Width(), :height = _oC_.Height(), :mask = _oC_.Pixels() ]
	_oC_.Release()
	_oM_.Release()
	_o_.Release()
	return _a_

# IM6: the classical depth cue -- the lower in the picture, the nearer (the ground recedes toward the horizon);
# the checker reads the row number as inverse depth
func _StzVisionDepthPrior(pImage, paParams)
	_o_ = StzImageQ("" + pImage)
	_a_ = [ :width = _o_.Width(), :height = _o_.Height(), :prior = "rows" ]
	_o_.Release()
	return _a_

# a FIXED answer: "chair", the vocabulary category in the most COCO val2017 images outside the
# golden set (575 of them; printed by _rig/coco_golden.py) -- never tuned on the items that judge it
func _StzVisionLabelPrior(pImage, paParams)
	return "chair"

func _StzVisionDescribeFixed(pImage, paParams)
	return $cStzVisionDescribeFloor

# IM7 2 of 2: the floor of :doc-vlm -- the native PDF reader on the page AS A SCAN. The image is wrapped in an
# image-only PDF (no text layer, so the reader reads the page by OCR and lays it out by its own rules); the blocks
# are the reader's, in the shape every document reader of the house returns.
func _StzVisionDocFloor(pImage, paParams)
	_o_ = StzImageQ("" + pImage)
	_cPdf_ = sysget("TEMP") + "\stz_docfloor_" + random(999999) + ".pdf"
	_StzVisionScanPdf(_o_, _cPdf_)
	_o_.Release()
	_oP_ = StzPdfQ(_cPdf_)
	_oP_.ReadOcr($cStzVisionDocFloorLang)
	_aB_ = _oP_.Blocks()
	remove(_cPdf_)
	return _aB_

# an image-only PDF of one page, 150 dpi, the pixels raw (grey or RGB, 8 bits): what a scanner writes, without a filter
func _StzVisionScanPdf(poImg, pcPath)
	_nW_ = poImg.Width()
	_nH_ = poImg.Height()
	_nC_ = poImg.Channels()
	if _nC_ != 1 and _nC_ != 3
		stzraise("stzImage.doc-vlm: a page of " + _nC_ + " channels cannot be wrapped as a scan (1 or 3)")
	ok
	_cSpace_ = "DeviceGray"
	if _nC_ = 3 _cSpace_ = "DeviceRGB" ok
	_cData_ = poImg.Pixels()
	_nPw_ = _nW_ * 72 / 150
	_nPh_ = _nH_ * 72 / 150
	_cOut_ = "%PDF-1.4" + char(10)
	_aOff_ = []
	_aObj_ = [ "<< /Type /Catalog /Pages 2 0 R >>", "<< /Type /Pages /Kids [3 0 R] /Count 1 >>",
		"<< /Type /Page /Parent 2 0 R /MediaBox [0 0 " + _nPw_ + " " + _nPh_ + "] /Resources << /XObject << /Im1 4 0 R >> >> /Contents 5 0 R >>" ]
	_cContent_ = "q " + _nPw_ + " 0 0 " + _nPh_ + " 0 0 cm /Im1 Do Q"
	for _i_ = 1 to 5
		_aOff_ + len(_cOut_)
		_cOut_ += "" + _i_ + " 0 obj" + char(10)
		if _i_ <= 3
			_cOut_ += _aObj_[_i_]
		but _i_ = 4
			_cOut_ += "<< /Type /XObject /Subtype /Image /Width " + _nW_ + " /Height " + _nH_ + " /ColorSpace /" + _cSpace_ +
				" /BitsPerComponent 8 /Length " + len(_cData_) + " >>" + char(10) + "stream" + char(10) + _cData_ + char(10) + "endstream"
		else
			_cOut_ += "<< /Length " + len(_cContent_) + " >>" + char(10) + "stream" + char(10) + _cContent_ + char(10) + "endstream"
		ok
		_cOut_ += char(10) + "endobj" + char(10)
	next
	_nXref_ = len(_cOut_)
	_cOut_ += "xref" + char(10) + "0 6" + char(10) + "0000000000 65535 f " + char(10)
	for _i_ = 1 to 5
		_cOut_ += left("0000000000", 10 - len("" + _aOff_[_i_])) + _aOff_[_i_] + " 00000 n " + char(10)
	next
	_cOut_ += "trailer" + char(10) + "<< /Size 6 /Root 1 0 R >>" + char(10) + "startxref" + char(10) + _nXref_ + char(10) + "%%EOF" + char(10)
	StzFileWrite(pcPath, _cOut_)
# -- the models ---------------------------------------------------------

func _StzVisionFacesYunet(pImage, paParams)
	_o_ = StzImageQ("" + pImage)
	_a_ = _o_.FacesXT($nStzVisionFaceThreshold)
	_o_.Release()
	return _a_

func _StzVisionForegroundU2netp(pImage, paParams)
	_o_ = StzImageQ("" + pImage)
	_oM_ = _o_.SalientMask()
	_a_ = [ :width = _oM_.Width(), :height = _oM_.Height(), :mask = _oM_.Pixels() ]
	_oM_.Release()
	_o_.Release()
	return _a_

func _StzVisionObjectAtSam(pInput, paParams)
	_o_ = StzImageQ("" + pInput[1])
	_oM_ = _o_.MaskAt([ pInput[2], pInput[3] ])
	_a_ = [ :width = _oM_.Width(), :height = _oM_.Height(), :mask = _oM_.Pixels() ]
	_oM_.Release()
	_o_.Release()
	return _a_

func _StzVisionDescribeSmolvlm(pImage, paParams)
	_o_ = StzImageQ("" + pImage)
	_c_ = _o_.Describe()
	_o_.Release()
	return _c_

func _StzVisionDocCombined(pImage, paParams)
	return StzDocBlocksCombine(_StzVisionDocFloor(pImage, paParams), _StzVisionDocGranite(pImage, paParams))

func _StzVisionDocGranite(pImage, paParams)
	_o_ = StzImageQ("" + pImage)
	_a_ = _o_.DocBlocks()
	_o_.Release()
	return _a_

# IM7 2 of 2: what Granite-Docling writes about a page -- DocTags, the structure as tags in the model's own tokens.
# The decoder put in the model slot, the page cut into tiles (the grid says how many), the prompt's texts written
# around the tiles as the model's processor writes them, greedy tokens until the model ends or pnMax tokens. Through
# the door.
func _StzVisionDocSay(poImg, pnMax)
	_cD_ = _StzVisionVlmLoad($cStzVisionDocDecoder, $cStzVisionDocDecoderSha256, "doc-vlm")
	_cP_ = _StzVisionModelOrRaise($cStzVisionDocProjector, "doc-vlm")
	_aG_ = StzEngineNeuralVlmGrid(poImg.Width(), poImg.Height(), $nStzVisionDocLongest, $nStzVisionDocTile)
	_aT_ = _StzVisionDocTexts(_aG_[1], _aG_[2], $cStzVisionDocRequest)
	_cJ_ = StzJoinWith(_aT_, char(31))
	StzEngineNeuralSetTermination(1.0, 64, $nStzVisionDocStopRepeat, 0.0)
	_c_ = StzEngineNeuralVlmPage(_cP_, poImg.Pixels(), poImg.Width(), poImg.Height(), poImg.Channels(),
		$nStzVisionDocLongest, _cJ_, pnMax, 4)
	StzEngineNeuralSetTermination(1.0, 64, 0, 0.0)
	_a_ = StzEngineNeuralVlmStats()
	if _c_ = "" and _a_[3] = 0
		_StzVisionFailed("doc-vlm", $cStzVisionDocDecoder)
	ok
	_StzVisionDoor("doc-vlm", $cStzVisionDocDecoder, "" + _a_[3] + " tokens, " + _aG_[5] + " views, the views " + floor(_a_[1]) + " ms")
	return _c_

# the prompt's texts around a page's views (one more than the views): the user's turn opens, each tile is tagged
# with its row and column, a newline ends each row of tiles, the whole page follows, then the request and the
# assistant's turn opens. Idefics3Processor.replace_image_token writes the same prompt; a text that must reach the
# tokenizer in one piece (the newlines before the whole page) is one entry
func _StzVisionDocTexts(pnRows, pnCols, pcRequest)
	_cF_ = "<fake_token_around_image>"
	_aT_ = []
	_cCur_ = "<|start_of_role|>user<|end_of_role|>"
	if pnRows = 0
		_aT_ + (_cCur_ + _cF_ + "<global-img>")
	else
		for _r_ = 1 to pnRows
			for _c_ = 1 to pnCols
				_cCur_ += _cF_ + "<row_" + _r_ + "_col_" + _c_ + ">"
				_aT_ + _cCur_
				_cCur_ = ""
			next
			_cCur_ = char(10)
		next
		_cCur_ += char(10) + _cF_ + "<global-img>"
		_aT_ + _cCur_
	ok
	_aT_ + (_cF_ + pcRequest + "<|end_of_text|>" + char(10) + "<|start_of_role|>assistant<|end_of_role|>")
	return _aT_
# the decoder of a vision-language model put in the engine's model slot -- only with its recorded digest, and only
# when the slot holds something else (both of the house's decoders read rows of $nStzVisionVlmWidth)
func _StzVisionVlmLoad(pcDecoder, pcSha, pcFaculty)
	_cD_ = _StzVisionModelOrRaise(pcDecoder, pcFaculty)
	if NOT ($cStzVisionVlmSlot = _cD_ and StzEngineNeuralModelLoaded() = 1 and
	        StzEngineNeuralModelNEmbd() = $nStzVisionVlmWidth)
		StzExpectModelDigest(_cD_, pcSha)
		if StzEngineNeuralModelLoad(_cD_) != 1
			stzraise("stzImage." + pcFaculty + ": the decoder " + pcDecoder + " was refused (status " +
				StzEngineNeuralModelLoadStatus() + "; -2 is a digest other than the one in models/MODELS.md)")
		ok
		$cStzVisionVlmSlot = _cD_
	ok
	return _cD_
# IM7: what SmolVLM says about a picture after a request -- the decoder put in the model slot (only with its
# recorded digest, and only when the slot holds something else), the picture through the tower, greedy words
# until the model ends its answer or pnMax tokens are made. Through the door.
func _StzVisionVlmSay(poImg, pcRequest, pnMax, pcFaculty)
	_cD_ = _StzVisionVlmLoad($cStzVisionVlmDecoder, $cStzVisionVlmDecoderSha256, pcFaculty)
	_cP_ = _StzVisionModelOrRaise($cStzVisionVlmProjector, pcFaculty)
	_c_ = StzEngineNeuralVlmDescribe(_cP_, poImg.Pixels(), poImg.Width(), poImg.Height(), poImg.Channels(),
		"<|im_start|>User:<fake_token_around_image><global-img>",
		"<fake_token_around_image>" + pcRequest + "<end_of_utterance>" + char(10) + "Assistant:", pnMax, 4)
	_a_ = StzEngineNeuralVlmStats()
	if _c_ = "" and _a_[3] = 0
		_StzVisionFailed(pcFaculty, $cStzVisionVlmDecoder)
	ok
	_c_ = ring_trim(_c_)
	# an answer cut by the token cap ends at its last whole sentence, when it has one
	if _a_[3] >= pnMax
		_n_ = len(_c_)
		for _i_ = _n_ to 1 step -1
			if _c_[_i_] = "."
				_c_ = left(_c_, _i_)
				exit
			ok
		next
	ok
	_StzVisionDoor(pcFaculty, $cStzVisionVlmDecoder, "" + _a_[3] + " tokens, the picture " + floor(_a_[1]) + " ms")
	return _c_

func _StzVisionDepthDa2(pImage, paParams)
	_o_ = StzImageQ("" + pImage)
	_cP_ = _StzVisionModelOrRaise($cStzVisionDepthModel, "depth")
	_c_ = StzEngineNeuralVisionDepth(_cP_, _o_.Pixels(), _o_.Width(), _o_.Height(), _o_.Channels(), 4)
	if len(_c_) = 0
		_o_.Release()
		_StzVisionFailed("depth", $cStzVisionDepthModel)
	ok
	_StzVisionDoor("depth", $cStzVisionDepthModel, "a " + _o_.Width() + " x " + _o_.Height() + " map")
	_a_ = [ :width = _o_.Width(), :height = _o_.Height(), :depth = _c_ ]
	_o_.Release()
	return _a_

func _StzVisionObjectsNano(pImage, paParams)
	return _StzVisionObjectsWith(pImage, "yolox_nano.gguf")

func _StzVisionObjectsTiny(pImage, paParams)
	return _StzVisionObjectsWith(pImage, "yolox_tiny.gguf")

func _StzVisionObjectsWith(pImage, pcFile)
	_cKeep_ = $cStzVisionObjectModel
	$cStzVisionObjectModel = pcFile
	_o_ = StzImageQ("" + pImage)
	_a_ = []
	try
		_a_ = _o_.Objects()
	catch
		$cStzVisionObjectModel = _cKeep_
		_o_.Release()
		stzraise(cCatchError)
	done
	$cStzVisionObjectModel = _cKeep_
	_o_.Release()
	return _a_

# the classifier's best label that maps to a COCO category (its ten best are tried in order); "" when none does
func _StzVisionLabelMobilenet(pImage, paParams)
	_o_ = StzImageQ("" + pImage)
	_a_ = _o_.ClassifyXT(10)
	_o_.Release()
	_n_ = len(_a_)
	for _i_ = 1 to _n_
		_c_ = StzVisionCocoOf(_a_[_i_][:index])
		if _c_ != ""
			return _c_
		ok
	next
	return ""

# IM5: zero-shot over the vocabulary itself -- each category name put into SigLIP's own prompt, the
# best cosine wins. No mapping table: the categories ARE the labels.
func _StzVisionLabelSiglip(pImage, paParams)
	_o_ = StzImageQ("" + pImage)
	_a_ = _o_.ClassifyAs(StzVisionCocoVocabulary())
	_o_.Release()
	return _a_[1][:label]

# The 41 COCO categories the :image-label faculty answers in (the vocabulary _rig/coco_golden.py
# selects labels_v1 by): the ones an ImageNet classifier can map to, so both models answer in one set.
func StzVisionCocoVocabulary()
	return [ "bicycle", "car", "motorcycle", "airplane", "bus", "train", "truck", "boat", "traffic light",
		"parking meter", "bench", "bird", "cat", "dog", "horse", "sheep", "cow", "elephant", "bear", "zebra",
		"umbrella", "banana", "orange", "broccoli", "hot dog", "pizza", "chair", "couch", "bed", "dining table",
		"toilet", "tv", "laptop", "mouse", "keyboard", "cell phone", "microwave", "refrigerator", "clock", "vase",
		"teddy bear" ]

# The COCO category an ImageNet-1k class belongs to, or "" (the mapping the :image-label model uses).
func StzVisionCocoOf(pnIndex)
	_n_ = pnIndex
	if _n_ >= 151 and _n_ <= 268 return "dog" ok
	if _n_ >= 281 and _n_ <= 285 return "cat" ok
	if (_n_ >= 7 and _n_ <= 24) or (_n_ >= 80 and _n_ <= 100) or (_n_ >= 127 and _n_ <= 146) return "bird" ok
	_aMap_ = [
		[ "bicycle", [ 444, 671 ] ], [ "car", [ 407, 436, 468, 511, 581, 609, 627, 656, 661, 751, 817 ] ],
		[ "motorcycle", [ 665, 670 ] ], [ "airplane", [ 404, 895 ] ], [ "bus", [ 654, 779, 874 ] ],
		[ "train", [ 466, 547, 565, 705, 820, 829 ] ], [ "truck", [ 555, 569, 675, 717, 734, 864, 867 ] ],
		[ "boat", [ 472, 484, 510, 554, 576, 625, 628, 724, 780, 814, 871, 914 ] ],
		[ "traffic light", [ 920 ] ], [ "parking meter", [ 704 ] ], [ "bench", [ 703 ] ], [ "umbrella", [ 879 ] ],
		[ "banana", [ 954 ] ], [ "orange", [ 950 ] ], [ "broccoli", [ 937 ] ], [ "hot dog", [ 934 ] ], [ "pizza", [ 963 ] ],
		[ "chair", [ 423, 559, 765 ] ], [ "couch", [ 831 ] ], [ "bed", [ 431, 520, 564, 750 ] ], [ "dining table", [ 532 ] ],
		[ "toilet", [ 861 ] ], [ "tv", [ 664, 782, 851 ] ], [ "laptop", [ 620, 681 ] ], [ "mouse", [ 673 ] ],
		[ "keyboard", [ 508, 878 ] ], [ "cell phone", [ 487, 528 ] ], [ "microwave", [ 651 ] ], [ "refrigerator", [ 760 ] ],
		[ "clock", [ 409, 530, 892 ] ], [ "vase", [ 883 ] ], [ "teddy bear", [ 850 ] ], [ "zebra", [ 340 ] ],
		[ "horse", [ 339, 603 ] ], [ "sheep", [ 348, 349 ] ], [ "cow", [ 345, 346, 347 ] ],
		[ "elephant", [ 101, 385, 386 ] ], [ "bear", [ 294, 295, 296, 297 ] ] ]
	_m_ = len(_aMap_)
	for _i_ = 1 to _m_
		if ring_find(_aMap_[_i_][2], _n_) > 0
			return _aMap_[_i_][1]
		ok
	next
	return ""
