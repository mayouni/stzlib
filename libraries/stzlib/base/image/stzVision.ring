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
	StzNoteFact("model.call", "stzImage", pcFile, pcFaculty + ": " + pcWhat + " in " +
		StzEngineNeuralVisionMs() + " ms")

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
