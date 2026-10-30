#--------------------------------------------------------------#
#      SOFTANZA LIBRARY (V1.2) - STZOCR                         #
#--------------------------------------------------------------#
#                                                              #
#   Description  : OCR as a faculty. An image (a page, or the   #
#                  pages of one document) in, its text out.    #
#                  The FLOOR is the platform's own engine      #
#                  (Windows.Media.Ocr) with the right-to-left  #
#                  lines put back in logical order; where the  #
#                  platform has no engine or no language pack  #
#                  the floor refuses and names what is missing.#
#                  A model (PP-OCR on the engine's ggml) may   #
#                  answer instead only once it was MEASURED    #
#                  strictly better on the golden set; the      #
#                  registry decides, and explains why.         #
#   Design       : base/doc/design/SOFTANZA_OCR_MEMO.md        #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#

# the OCR text of each image already read in this process, by image path and language: a golden set asks the
# same page once per sentence, and the platform engine is deterministic
$aStzOcrCache = []

# what the platform engine said of its last call (its summary line), for Content() and Show()
$cStzOcrLastSummary = ""

# the box of each line the platform read, by image path and language, parallel to $aStzOcrCache's lines
$aStzOcrBoxCache = []

# the implementation that answered the last StzOcrLinesWithBoxes: "platform" or "ppocr"
$cStzOcrLinesBy = ""

# what the model's last page cost, as the engine reported it: [ boxes, ms detect, ms classify, ms recognise, ms total,
# lines voted upside down ]
$aStzOcrModelLastStats = []

# Declares the :ocr faculty: an image in (a path, a list of page paths, or a record [ :pages, :lang ]), a text out.
#
# Its floor is the platform's OCR engine with right-to-left lines reordered; when paGolden is given and the
# faculty has no golden set yet, its items (each [ input, expected sentence ]) become the golden set, compared
# with the "contains" checker -- the share of expected sentences found is the faculty's score, the same measure
# the PDF reader is held to.
#
#   paGolden   a list of [ input, sentence ] pairs, or [ ] for none
#   returns    the faculty, a stzFaculty
func StzOcrDeclare(paGolden)
	_o_ = StzFacultyQ(:ocr)
	_o_.SetInputTypeQ(:image).SetOutputTypeQ(:text).SetParamsQ([ :lang = "" ]).
	    SetFloorQ("platform", "_StzOcrFloor").SetGoldenCheckerQ("contains").SetGoldenVersionQ("v2").
	    SetGoldenLanguageKeyQ(:lang)
	# measured PER LANGUAGE from golden set v2 on (the author's ruling of 2026-10-30, OCR-PERLANG-01): a call in
	# Russian is judged on the Russian items, so the model may answer it while the floor answers Arabic
	# the model: PP-OCR on the engine, installed when its graphs are in the models directory; it answers
	# instead of the floor only once the registry measured it strictly better on the golden set
	# (O3b measured the Latin recogniser alone as "ppocr-v6-small" on golden set v1; with the Arabic and Cyrillic
	# recognisers of O3c it is "ppocr")
	if len(StzFind("ppocr", _o_.ImplementationIds())) = 0
		_o_.AddImplementation([ :id = "ppocr", :kind = "graph", :fn = "_StzOcrModel", :needle = "ocr/ppocr_rec.gguf",
				       :licence = "apache-2.0", :memory = 600,
				       :languages = [ "fr", "en", "de", "es", "it", "pt", "nl", "zh", "ar", "ru", "uk", "bg" ] ])
	ok
	# the measurements filed beside this code are what the registry rules on in a process that has not measured: a
	# filed measurement must outlive the process that made it, or the per-language choice exists only in a guard
	if len(StzMeasurementOf("ocr", "platform", _o_.GoldenVersion())) = 0 and fexists(StzOcrMeasurementsFile())
		StzLoadMeasurements(StzOcrMeasurementsFile())
	ok
	if isList(paGolden) and len(_o_.Goldens()) = 0
		_nG_ = len(paGolden)
		for _i_ = 1 to _nG_
			_o_.AddGolden(paGolden[_i_][1], paGolden[_i_][2])
		next
	ok
	return _o_

# The :ocr measurements shipped with the library (base/ocr/ocr.zmdl.txt), copied from the model guard's filed result
# (base/test/ocr/results/ocr.zmdl.txt) when the golden set or an implementation changes. They were measured on ONE
# machine: the floor's score in a language is that machine's language packs.
func StzOcrMeasurementsFile()
	_e_ = $cEngineDir
	if isString(_e_) and len(_e_) >= 7 and right(_e_, 7) = "/engine"
		return left(_e_, len(_e_) - 7) + "/base/ocr/ocr.zmdl.txt"
	ok
	return ""

# Reads an image through the :ocr faculty and returns its text (the lines joined by spaces, pages in order).
#
#   pImage     a path, a list of page paths, or a record [ :pages = [ ... ], :lang = "fr-FR" ]
#   pcLang     the language tag of the platform pack to use, or "" for the user's own languages
#   returns    a text
#   warning    raises, naming what is missing, where no platform engine or no pack serves the language
func StzOcrText(pImage, pcLang)
	return StzOcrQ(pImage).SetLanguageQ(pcLang).Text()

func StzOcrQ(pImage)
	return new stzOcr(pImage)

# Returns the language tags of the OCR packs the platform has, [ ] where there is no platform engine.
func StzOcrPlatformLanguages()
	if NOT isWindows() return [] ok
	_cOut_ = StzSystem("powershell -NoProfile -ExecutionPolicy Bypass -File " + _StzOcrBridgePath() + " -List")
	_aRes_ = []
	_aL_ = split(_cOut_, char(10))
	_nL_ = len(_aL_)
	for _i_ = 1 to _nL_
		_cT_ = trim(StzReplace(_aL_[_i_], char(13), ""))
		if len(_cT_) >= 2 and len(_cT_) <= 12 and StzFindFirst("-", _cT_) > 0
			add(_aRes_, _cT_)
		ok
	next
	return _aRes_

# TRUE when the platform can read pcLang ("" means the user's own languages, available when any pack is)
func StzOcrPlatformHas(pcLang)
	_a_ = StzOcrPlatformLanguages()
	if pcLang = "" return len(_a_) > 0 ok
	return len(StzFind(lower(pcLang), StzListQ(_a_).Lowercased())) > 0

#-------------------------------------#
#  THE FLOOR: the platform's engine   #
#-------------------------------------#

# The floor of :ocr. pImage is a path, a list of paths, or a record [ :pages, :lang ]; paParams may carry :lang.
# Each page's lines are read by the platform engine, right-to-left lines are put in logical order, and the lines
# of every page are joined by spaces. Raises, naming what is missing, where the platform cannot serve.
func _StzOcrFloor(pImage, paParams)
	_aPages_ = _StzOcrPagesOf(pImage)
	_cLang_ = _StzOcrLangOf(pImage, paParams)
	_cDir_ = "ltr"
	if StzOcrLanguageIsRtl(_cLang_) _cDir_ = "rtl" ok
	_cText_ = ""
	_nP_ = len(_aPages_)
	for _i_ = 1 to _nP_
		_aLines_ = StzOcrPlatformLines(_aPages_[_i_], _cLang_)
		_nL_ = len(_aLines_)
		for _j_ = 1 to _nL_
			if _cText_ != "" _cText_ += " " ok
			_cText_ += StzOcrLogicalLineXT(_aLines_[_j_], _cDir_)
		next
	next
	return _cText_

#-------------------------------------------#
#  THE MODEL: PP-OCRv6 small on the engine  #
#-------------------------------------------#

# where the three converted graphs live (engine/tools/onnx_to_gguf.py writes them; the files are not in git)
func StzOcrModelDir()
	return StzModelsDir() + "/ocr"

# The recogniser the model reads a language with, a file name in StzOcrModelDir(): PP-OCRv5 mobile for Arabic and
# for the Cyrillic languages (each fetched from rapidocr's model list and converted), PP-OCRv6 small for the rest
# (its dictionary is Latin, Greek, kana and CJK).
#
#   pcLang     a language tag ("ar-SA", "ru-RU", "fr-FR", "" for the default)
#   returns    the recogniser's file name
func StzOcrModelRecogniserFor(pcLang)
	_c_ = left(lower("" + pcLang), 2)
	if _c_ = "ar" return "ppocr_rec_arabic.gguf" ok
	if len(StzFind(_c_, [ "ru", "uk", "bg", "be", "sr", "mk", "kk", "ky", "mn", "tg" ])) > 0 return "ppocr_rec_cyrillic.gguf" ok
	return "ppocr_rec.gguf"

# The model implementation of :ocr: PP-OCR's detector and angle classifier with the recogniser of the page's
# language (StzOcrModelRecogniserFor), run by the engine on its own ggml (engine/src/ocr_pipeline.zig). Each page's
# lines are read in reading order -- a right-to-left recogniser's lines put back in logical order by the engine --
# and joined by spaces, pages in order. A language whose script has no recogniser here is refused, naming it.
func _StzOcrModel(pImage, paParams)
	_aPages_ = _StzOcrPagesOf(pImage)
	_cLang_ = lower(_StzOcrLangOf(pImage, paParams))
	_cRec_ = StzOcrModelRecogniserFor(_cLang_)
	if _cRec_ = "ppocr_rec.gguf" and StzOcrLanguageIsRtl(_cLang_)
		stzraise("the :ocr model has no recogniser for '" + _cLang_ + "': PP-OCR's are Latin/Greek/kana/CJK, Arabic and Cyrillic")
	ok
	_cText_ = ""
	_nP_ = len(_aPages_)
	for _i_ = 1 to _nP_
		_aL_ = StzOcrModelLinesXT(_aPages_[_i_], _cLang_)
		_nL_ = len(_aL_)
		for _j_ = 1 to _nL_
			if _cText_ != "" _cText_ += " " ok
			_cText_ += _aL_[_j_][:text]
		next
	next
	return _cText_

# The lines the model reads on one image with the default recogniser (Latin, Greek, kana, CJK).
func StzOcrModelLines(pcPath)
	return StzOcrModelLinesXT(pcPath, "")

# The lines the model reads on one image in a language, in reading order, each [ :text, :score, :box = [x0, y0,
# x1, y1] ] in the file's pixels (a right-to-left language: logical order, a row's boxes from the right), cached per
# path and recogniser (a golden set asks the same page once per sentence).
#
#   pcPath     the image file (PNG, JPEG, BMP)
#   pcLang     a language tag; it picks the recogniser (StzOcrModelRecogniserFor)
#   returns    a list of line records
#   warning    raises, naming the file, when the graphs or the language's recogniser are not installed, or the
#              image cannot be decoded
func StzOcrModelLinesXT(pcPath, pcLang)
	if NOT fexists(pcPath)
		stzraise("StzOcr: the image '" + pcPath + "' does not exist")
	ok
	_cRec_ = StzOcrModelRecogniserFor(pcLang)
	_cKey_ = "model|" + _cRec_ + "|" + _StzOcrCacheKey(pcPath, "")
	_nC_ = len($aStzOcrCache)
	for _i_ = 1 to _nC_
		if $aStzOcrCache[_i_][1] = _cKey_ return $aStzOcrCache[_i_][2] ok
	next
	if NOT fexists(StzOcrModelDir() + "/" + _cRec_)
		stzraise("the :ocr model has no recogniser for '" + pcLang + "' installed: no " + StzOcrModelDir() + "/" + _cRec_ +
			 " (convert it with engine/tools/onnx_to_gguf.py)")
	ok
	_aRows_ = StzEngineNeuralOcrReadWith(StzOcrModelDir(), _cRec_, pcPath, 4)
	if len(_aRows_) = 0
		_cErr_ = StzEngineNeuralOcrGraphError()
		if _cErr_ != "" stzraise("the :ocr model could not read '" + pcPath + "': " + _cErr_) ok
	ok
	_aLines_ = []
	_nR_ = len(_aRows_)
	for _i_ = 1 to _nR_
		add(_aLines_, [ :text = _aRows_[_i_][1], :score = _aRows_[_i_][2],
				:box = [ _aRows_[_i_][3], _aRows_[_i_][4], _aRows_[_i_][5], _aRows_[_i_][6] ] ])
	next
	$aStzOcrModelLastStats = StzEngineNeuralOcrStats()
	add($aStzOcrCache, [ _cKey_, _aLines_ ])
	return _aLines_

# what the model's last page cost: [ :boxes, :detect, :classify, :recognise, :total ] (ms), and :votes180 -- the
# lines the angle classifier called upside down (the page turns over only when they are most of its lines);
# [ ] before any read
func StzOcrModelLastStats()
	if len($aStzOcrModelLastStats) < 6 return [] ok
	_a_ = $aStzOcrModelLastStats
	return [ :boxes = _a_[1], :detect = _a_[2], :classify = _a_[3], :recognise = _a_[4], :total = _a_[5], :votes180 = _a_[6] ]

func _StzOcrPagesOf(pImage)
	if isString(pImage) return [ pImage ] ok
	if isList(pImage) and len(pImage) > 0 and isList(pImage[1]) and isString(pImage[1][1]) and HasKey(pImage, :pages)
		return pImage[:pages]
	ok
	if isList(pImage) return pImage ok
	stzraise("StzOcr: the image is a path, a list of page paths, or a record [ :pages, :lang ].")

func _StzOcrLangOf(pImage, paParams)
	_c_ = ""
	if isList(paParams) and HasKey(paParams, :lang) _c_ = "" + paParams[:lang] ok
	if _c_ = "" and isList(pImage) and len(pImage) > 0 and isList(pImage[1]) and HasKey(pImage, :lang) _c_ = "" + pImage[:lang] ok
	return _c_

# The lines the platform engine reads on one image, as it returns them (visual order), cached per path and language.
#
#   pcPath     the image file (PNG, JPEG, BMP)
#   pcLang     a language tag the platform has a pack for, or "" for the user's languages
#   returns    a list of lines
#   warning    raises, naming what is missing: no platform engine (not Windows), no pack for the language, no file
func StzOcrPlatformLines(pcPath, pcLang)
	if NOT isWindows()
		stzraise("the :ocr floor is the platform engine (Windows.Media.Ocr): there is none on this machine; the model implementation is not installed")
	ok
	if NOT fexists(pcPath)
		stzraise("StzOcr: the image '" + pcPath + "' does not exist")
	ok
	pcPath = _StzOcrAbsolutePath(pcPath)
	_cKey_ = _StzOcrCacheKey(pcPath, pcLang)
	_nC_ = len($aStzOcrCache)
	for _i_ = 1 to _nC_
		if $aStzOcrCache[_i_][1] = _cKey_ return $aStzOcrCache[_i_][2] ok
	next
	_cOut_ = sysget("TEMP") + "\stz_ocr_out_" + random(999999) + ".txt"
	_cBoxOut_ = _cOut_ + ".box"
	_cCmd_ = "powershell -NoProfile -ExecutionPolicy Bypass -File " + _StzOcrBridgePath() +
		 " -Path " + char(34) + pcPath + char(34) + " -Lang " + char(34) + pcLang + char(34) + " -Out " + char(34) + _cOut_ + char(34)
	_cSum_ = trim(StzSystem(_cCmd_))
	$cStzOcrLastSummary = _cSum_
	if StzFindFirst("NO ENGINE", _cSum_) > 0
		_cFor_ = pcLang
		if _cFor_ = "" _cFor_ = "the user's languages" ok
		stzraise("the :ocr floor has no language pack for " + _cFor_ + " on this machine (installed: " + @@(StzOcrPlatformLanguages()) + ")")
	ok
	if StzFindFirst("NO IMAGE", _cSum_) > 0 or StzFindFirst("image x ", _cSum_) > 0
		stzraise("the :ocr floor could not open the image '" + pcPath + "' (" + _cSum_ + ")")
	ok
	if NOT fexists(_cOut_)
		stzraise("the :ocr floor returned nothing for '" + pcPath + "': " + _cSum_)
	ok
	_cText_ = read(_cOut_)
	remove(_cOut_)
	_aBoxRaw_ = []
	if fexists(_cBoxOut_)
		_aBoxRaw_ = split(read(_cBoxOut_), char(10))
		remove(_cBoxOut_)
	ok
	_aLines_ = []
	_aBoxes_ = []
	_aRaw_ = split(_cText_, char(10))
	_nR_ = len(_aRaw_)
	for _i_ = 1 to _nR_
		_cL_ = trim(StzReplace(_aRaw_[_i_], char(13), ""))
		if _cL_ != ""
			add(_aLines_, _cL_)
			_aB_ = []
			if _i_ <= len(_aBoxRaw_)
				_aF_ = split(trim(StzReplace(_aBoxRaw_[_i_], char(13), "")), " ")
				if len(_aF_) = 4 _aB_ = [ 0 + _aF_[1], 0 + _aF_[2], 0 + _aF_[3], 0 + _aF_[4] ] ok
			ok
			add(_aBoxes_, _aB_)
		ok
	next
	add($aStzOcrCache, [ _cKey_, _aLines_ ])
	add($aStzOcrBoxCache, [ _cKey_, _aBoxes_ ])
	return _aLines_

# The box of each line the platform read on one image, parallel to StzOcrPlatformLines: [ x0, y0, x1, y1 ] in the
# image's pixels (the union of the line's word rectangles -- TIGHT, unlike a detector's box), [ ] for a line the
# platform gave none.
func StzOcrPlatformBoxes(pcPath, pcLang)
	StzOcrPlatformLines(pcPath, pcLang)
	_cKey_ = _StzOcrCacheKey(_StzOcrAbsolutePath(pcPath), pcLang)
	_nC_ = len($aStzOcrBoxCache)
	for _i_ = 1 to _nC_
		if $aStzOcrBoxCache[_i_][1] = _cKey_ return $aStzOcrBoxCache[_i_][2] ok
	next
	return []

# The lines of one image WITH THEIR BOXES, read by the implementation the :ocr faculty chooses for the language
# (the registry, per language), in logical order: [ :text, :box = [x0, y0, x1, y1] in the image's pixels, :tight ]
# -- :tight is 1 for word-tight boxes (the platform) and 0 for a detector's boxes (PP-OCR, grown by its unclip).
# The implementation that answered is in $cStzOcrLinesBy.
#
#   pcImage    the image file
#   pcLang     a language tag, or "" for the user's own languages
#   returns    a list of line records
#   warning    raises, with the faculty's reason, when no implementation can read the language
func StzOcrLinesWithBoxes(pcImage, pcLang)
	_o_ = StzOcrQ([ :pages = [ pcImage ], :lang = pcLang ])
	_o_.Text()
	$cStzOcrLinesBy = _o_.AnsweredBy()
	_aOut_ = []
	if $cStzOcrLinesBy = "ppocr"
		_aL_ = StzOcrModelLinesXT(pcImage, pcLang)
		_nL_ = len(_aL_)
		for _i_ = 1 to _nL_
			add(_aOut_, [ :text = _aL_[_i_][:text], :box = _aL_[_i_][:box], :tight = 0 ])
		next
		return _aOut_
	ok
	_aL_ = StzOcrPlatformLines(pcImage, pcLang)
	_aB_ = StzOcrPlatformBoxes(pcImage, pcLang)
	_cDir_ = "ltr"
	if StzOcrLanguageIsRtl(pcLang) _cDir_ = "rtl" ok
	_nL_ = len(_aL_)
	for _i_ = 1 to _nL_
		_aBx_ = []
		if _i_ <= len(_aB_) _aBx_ = _aB_[_i_] ok
		add(_aOut_, [ :text = StzOcrLogicalLineXT(_aL_[_i_], _cDir_), :box = _aBx_, :tight = 1 ])
	next
	return _aOut_

# the platform wants an absolute path with backslashes
func _StzOcrAbsolutePath(pcPath)
	_c_ = StzReplace(pcPath, "/", "\")
	if NOT (len(_c_) > 2 and _c_[2] = ":")
		_c_ = StzReplace(currentdir(), "/", "\") + "\" + _c_
	ok
	return _c_

func _StzOcrCacheKey(pcPath, pcLang)
	return lower(_StzOcrAbsolutePath(pcPath)) + "|" + lower(pcLang)

# a language tag whose script is written right to left
func StzOcrLanguageIsRtl(pcLang)
	_c_ = lower("" + pcLang)
	_nP_ = StzFindFirst("-", _c_)
	if _nP_ > 0 _c_ = left(_c_, _nP_ - 1) ok
	return len(StzFind(_c_, [ "ar", "he", "fa", "ur", "ps", "yi", "ckb", "sd", "ug", "dv" ])) > 0

# the bridge to the platform engine: a PowerShell script written once to the temp folder from the text below
func _StzOcrBridgePath()
	_cP_ = sysget("TEMP") + "\stz_ocr_bridge_v3.ps1"
	if NOT fexists(_cP_)
		write(_cP_, _StzOcrBridgeScript())
	ok
	return _cP_

func _StzOcrBridgeScript()
	_q_ = char(34)
	_n_ = char(10)
	return "# stz_ocr_bridge_v3.ps1 -- Softanza's :ocr floor on Windows: Windows.Media.Ocr, one image per call" + _n_ +
	"param([string]$Path = '', [string]$Lang = '', [string]$Out = '', [switch]$List)" + _n_ +
	"$null = [Windows.Media.Ocr.OcrEngine, Windows.Foundation, ContentType=WindowsRuntime]" + _n_ +
	"$null = [Windows.Graphics.Imaging.BitmapDecoder, Windows.Graphics.Imaging, ContentType=WindowsRuntime]" + _n_ +
	"$null = [Windows.Storage.StorageFile, Windows.Storage, ContentType=WindowsRuntime]" + _n_ +
	"$null = [Windows.Globalization.Language, Windows.Globalization, ContentType=WindowsRuntime]" + _n_ +
	"if ($List) { [Windows.Media.Ocr.OcrEngine]::AvailableRecognizerLanguages | ForEach-Object { $_.LanguageTag }; exit 0 }" + _n_ +
	"Add-Type -AssemblyName System.Runtime.WindowsRuntime" + _n_ +
	"$asTaskGeneric = ([System.WindowsRuntimeSystemExtensions].GetMethods() | Where-Object { $_.Name -eq 'AsTask' -and $_.GetParameters().Count -eq 1 -and $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncOperation`1' })[0]" + _n_ +
	"function Await($op, $type) { $t = $asTaskGeneric.MakeGenericMethod($type).Invoke($null, @($op)); $t.Wait(-1) | Out-Null; $t.Result }" + _n_ +
	"$file = Await ([Windows.Storage.StorageFile]::GetFileFromPathAsync($Path)) ([Windows.Storage.StorageFile])" + _n_ +
	"$stream = Await ($file.OpenAsync([Windows.Storage.FileAccessMode]::Read)) ([Windows.Storage.Streams.IRandomAccessStream])" + _n_ +
	"$decoder = Await ([Windows.Graphics.Imaging.BitmapDecoder]::CreateAsync($stream)) ([Windows.Graphics.Imaging.BitmapDecoder])" + _n_ +
	"$bitmap = Await ($decoder.GetSoftwareBitmapAsync()) ([Windows.Graphics.Imaging.SoftwareBitmap])" + _n_ +
	"if ($null -eq $bitmap) { 'NO IMAGE at ' + $Path; exit 3 }" + _n_ +
	"if ($Lang -eq '') { $engine = [Windows.Media.Ocr.OcrEngine]::TryCreateFromUserProfileLanguages() } else { $language = New-Object Windows.Globalization.Language -ArgumentList $Lang; $engine = [Windows.Media.Ocr.OcrEngine]::TryCreateFromLanguage($language) }" + _n_ +
	"if ($null -eq $engine) { 'NO ENGINE for ' + $Lang; exit 2 }" + _n_ +
	"$sw = [Diagnostics.Stopwatch]::StartNew()" + _n_ +
	"$result = Await ($engine.RecognizeAsync($bitmap)) ([Windows.Media.Ocr.OcrResult])" + _n_ +
	"$ms = $sw.ElapsedMilliseconds" + _n_ +
	"$lines = @(); $boxes = @(); $words = 0" + _n_ +
	"foreach ($l in $result.Lines) { $lines += $l.Text; $ws = @($l.Words); $words += $ws.Count; $x0 = 1e9; $y0 = 1e9; $x1 = 0; $y1 = 0; " +
	"foreach ($w in $ws) { $r = $w.BoundingRect; if ($r.X -lt $x0) { $x0 = $r.X }; if ($r.Y -lt $y0) { $y0 = $r.Y }; " +
	"if ($r.X + $r.Width -gt $x1) { $x1 = $r.X + $r.Width }; if ($r.Y + $r.Height -gt $y1) { $y1 = $r.Y + $r.Height } }; " +
	"$boxes += ('{0} {1} {2} {3}' -f [int]$x0, [int]$y0, [int]$x1, [int]$y1) }" + _n_ +
	"$text = ($lines -join [string][char]10)" + _n_ +
	"('lang {0}  image {1}x{2}  lines {3}  words {4}  angle {5}  ms {6}' -f $Lang, $bitmap.PixelWidth, $bitmap.PixelHeight, @($result.Lines).Count, $words, $result.TextAngle, $ms)" + _n_ +
	"if ($Out -ne '') { [IO.File]::WriteAllText($Out, $text, (New-Object Text.UTF8Encoding $false)); " +
	"[IO.File]::WriteAllText($Out + '.box', ($boxes -join [string][char]10), (New-Object Text.UTF8Encoding $false)) }" + _n_

#-------------------------------------#
#  RIGHT-TO-LEFT: visual to logical   #
#-------------------------------------#

# Puts a line the platform returned in visual order back in logical order, the paragraph's direction given.
#
# The platform reads a line left to right as it stands on the page. In a right-to-left paragraph the words come
# back reversed while the runs of digits and Latin words inside keep their own order; in a left-to-right
# paragraph the line is in order but each run of right-to-left words inside it is reversed.
#
#   pcLine     one line of text
#   pcDir      "rtl" or "ltr": the direction of the paragraph (the language pack's script decides it)
#   returns    the line in logical order
func StzOcrLogicalLineXT(pcLine, pcDir)
	_aT_ = split(pcLine, " ")
	_nT_ = len(_aT_)
	_aK_ = []
	for _i_ = 1 to _nT_
		add(_aK_, _StzOcrTokenKind(_aT_[_i_]))
	next
	if lower("" + pcDir) = "rtl"
		_aV_ = reverse(_aT_)
		_aVK_ = reverse(_aK_)
		_StzOcrReverseRuns(_aV_, _aVK_, "L")
	else
		_aV_ = _aT_
		_aVK_ = _aK_
		_StzOcrReverseRuns(_aV_, _aVK_, "R")
	ok
	_cRes_ = ""
	for _i_ = 1 to _nT_
		if _i_ > 1 _cRes_ += " " ok
		_cRes_ += _aV_[_i_]
	next
	return _cRes_

# Puts a line back in logical order, guessing the paragraph's direction from the line itself: right to left when
# its right-to-left words outnumber the others, or, when they are as many, when the line ends in one and begins
# with a number. See StzOcrLogicalLineXT, which is told the direction and never guesses.
func StzOcrLogicalLine(pcLine)
	_aT_ = split(pcLine, " ")
	_nT_ = len(_aT_)
	_nR_ = 0
	_nL_ = 0
	_cFirst_ = "N"
	_cLast_ = "N"
	for _i_ = 1 to _nT_
		_cK_ = _StzOcrTokenKind(_aT_[_i_])
		if _cK_ = "R" _nR_++ ok
		if _cK_ = "L" or _cK_ = "D" _nL_++ ok
		if _i_ = 1 _cFirst_ = _cK_ ok
		_cLast_ = _cK_
	next
	if _nR_ = 0 return pcLine ok
	if _nR_ > _nL_ or (_nR_ = _nL_ and _cLast_ = "R" and _cFirst_ = "D")
		return StzOcrLogicalLineXT(pcLine, "rtl")
	ok
	return StzOcrLogicalLineXT(pcLine, "ltr")

# reverses in place each maximal run of tokens of kind pcKind (digits count with Latin; a neutral token between
# two of the run belongs to it)
func _StzOcrReverseRuns(paV, paK, pcKind)
	_n_ = len(paV)
	_i_ = 1
	while _i_ <= _n_
		if _StzOcrKindIs(paK[_i_], pcKind)
			_j_ = _i_
			while _j_ + 1 <= _n_
				if _StzOcrKindIs(paK[_j_ + 1], pcKind)
					_j_++
				but paK[_j_ + 1] = "N" and _j_ + 2 <= _n_ and _StzOcrKindIs(paK[_j_ + 2], pcKind)
					_j_ += 2
				else
					exit
				ok
			end
			_aRun_ = []
			for _k_ = _j_ to _i_ step -1
				add(_aRun_, paV[_k_])
			next
			for _k_ = _i_ to _j_
				paV[_k_] = _aRun_[_k_ - _i_ + 1]
			next
			_i_ = _j_ + 1
		else
			_i_++
		ok
	end

func _StzOcrKindIs(pcK, pcKind)
	if pcKind = "L" return pcK = "L" or pcK = "D" ok
	return pcK = pcKind

# Puts every line of a text in logical order (lines kept, see StzOcrLogicalLine)
func StzOcrLogicalText(pcText)
	_aL_ = split(pcText, char(10))
	_c_ = ""
	_nL_ = len(_aL_)
	for _i_ = 1 to _nL_
		if _i_ > 1 _c_ += char(10) ok
		_c_ += StzOcrLogicalLine(_aL_[_i_])
	next
	return _c_

# R: holds a right-to-left letter; L: holds a Latin, Greek or Cyrillic letter and no RTL letter; D: digits and
# figure signs only; N: none of these (punctuation)
func _StzOcrTokenKind(pcToken)
	if pcToken = "" return "N" ok
	_aU_ = StzUnicodes(pcToken)
	_nU_ = len(_aU_)
	_bR_ = 0
	_bL_ = 0
	_bD_ = 0
	for _i_ = 1 to _nU_
		_n_ = _aU_[_i_]
		if (_n_ >= 1424 and _n_ <= 2303) or (_n_ >= 64285 and _n_ <= 65023) or (_n_ >= 65136 and _n_ <= 65279)
			_bR_ = 1
		but (_n_ >= 65 and _n_ <= 90) or (_n_ >= 97 and _n_ <= 122) or (_n_ >= 192 and _n_ <= 591) or (_n_ >= 880 and _n_ <= 1279)
			_bL_ = 1
		but (_n_ >= 48 and _n_ <= 57) or (_n_ >= 1632 and _n_ <= 1641) or (_n_ >= 1776 and _n_ <= 1785)
			_bD_ = 1
		ok
	next
	if _bR_ return "R" ok
	if _bL_ return "L" ok
	if _bD_ return "D" ok
	return "N"

#-------------------------------------#
#  THE ENTRY OBJECT                   #
#-------------------------------------#

# Reads an image, or the pages of one document, through the :ocr faculty: the registry picks the implementation
# (the platform floor until a model is measured better), the court judges the text, and the parcel keeps why.
#
#   receiver   o1 = StzOcrQ("page.png")
#   example    ? o1.Text()
#              #--> the lines of the page joined by spaces, right-to-left lines in logical order
#              ? o1.NumberOfLines()
#              #--> 18
#   see        StzOcrQ, StzOcrText, StzOcrDeclare, stzFaculty
class stzOcr from stzObject

	@aPages = []
	@cLang = ""
	@aLines = []
	@bRead = 0
	@cAnsweredBy = ""

	# Builds the reader of an image, a list of page paths, or a record [ :pages, :lang ]; nothing is read yet.
	def init(pImage)
		@aPages = _StzOcrPagesOf(pImage)
		@cLang = _StzOcrLangOf(pImage, [])

	def Pages()
		return @aPages

	def NumberOfPages()
		return len(@aPages)

	def Language()
		return @cLang

	# Sets the language pack to read with ("" for the user's own languages); the next read uses it.
	def SetLanguage(pcLang)
		@cLang = "" + pcLang
		@bRead = 0

		def SetLanguageQ(pcLang)
			This.SetLanguage(pcLang)
			return This

	# The lines of every page, in logical order, pages in order.
	def Lines()
		This._Read()
		return @aLines

	def NumberOfLines()
		return len(This.Lines())

	# The text: the lines joined by spaces (what the faculty's court judged).
	def Text()
		This._Read()
		_c_ = ""
		_nL_ = len(@aLines)
		for _i_ = 1 to _nL_
			if _i_ > 1 _c_ += " " ok
			_c_ += @aLines[_i_]
		next
		return _c_

	# The text with one line per row.
	def TextLines()
		This._Read()
		_c_ = ""
		_nL_ = len(@aLines)
		for _i_ = 1 to _nL_
			if _i_ > 1 _c_ += char(10) ok
			_c_ += @aLines[_i_]
		next
		return _c_

	# The summary the platform engine printed for the last page read (lines, words, ms), "" before any read.
	def LastSummary()
		return $cStzOcrLastSummary

	# The implementation that answered: "platform" (the floor) or "ppocr" (the model), as the registry chose it for
	# this language.
	def AnsweredBy()
		This._Read()
		return @cAnsweredBy

	def Content()
		This._Read()
		return [ :pages = @aPages, :lang = @cLang, :lines = @aLines, :answeredby = @cAnsweredBy ]

	def Show()
		? @@(This.Content())

	# runs the faculty once; a refusal raises with its why
	def _Read()
		if @bRead return ok
		StzOcrDeclare([])
		_oP_ = StzFacultyQ(:ocr).RunQ([ :pages = @aPages, :lang = @cLang ], [ :lang = @cLang ])
		if _oP_.IsRefusal()
			stzraise(_oP_.Why())
		ok
		_cText_ = _oP_.Value()
		@cAnsweredBy = ""
		_aPv_ = _oP_.Provenance()
		if len(_aPv_) > 0 @cAnsweredBy = _aPv_[len(_aPv_)][:implementation] ok
		@aLines = []
		# the model answered: its lines are in its own cache, already in logical order
		if @cAnsweredBy = "ppocr"
			_nP_ = len(@aPages)
			for _i_ = 1 to _nP_
				_aL_ = StzOcrModelLinesXT(@aPages[_i_], @cLang)
				_nL_ = len(_aL_)
				for _k_ = 1 to _nL_
					add(@aLines, _aL_[_k_][:text])
				next
			next
			@bRead = 1
			return
		ok
		# the floor answered: its lines are in the cache it filled, in visual order
		_cDir_ = "ltr"
		if StzOcrLanguageIsRtl(@cLang) _cDir_ = "rtl" ok
		_nP_ = len(@aPages)
		_nC_ = len($aStzOcrCache)
		for _i_ = 1 to _nP_
			_cKey_ = _StzOcrCacheKey(@aPages[_i_], @cLang)
			_bHit_ = 0
			for _j_ = 1 to _nC_
				if $aStzOcrCache[_j_][1] = _cKey_
					_aL_ = $aStzOcrCache[_j_][2]
					_nL_ = len(_aL_)
					for _k_ = 1 to _nL_
						add(@aLines, StzOcrLogicalLineXT(_aL_[_k_], _cDir_))
					next
					_bHit_ = 1
				ok
			next
			if NOT _bHit_ and _i_ = 1 add(@aLines, _cText_) ok
		next
		@bRead = 1
