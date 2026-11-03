# stzScreenshotFacts.ring -- a screenshot reduced to the facts a legibility audit judges
#
# The consumer's contract is stzzui's doc/design/AUDIT-FACTS.md (format zui-audit-facts, version 1.0): one
# JSON file per screenshot, one entry per OCR line, its text, box, line height and the luminance of the text
# and of what is behind it. THE WRITER MEASURES AND NEVER JUDGES: every threshold lives in the audit, and a
# field that could not be measured is null, never a guess and never zero.
#
# Two things this file states rather than assumes, because the audit's verdicts turn on them:
#   - box_kind is "ink". StzOcrModelLinesXT's box is the detector's text region grown by DB's unclip, so its
#     height follows the drawn letters, not the font: measured 2026-11-03 on Segoe UI rendered at a known size,
#     "esc" got a 19 px box at 16 px and a 43 px box at 48 px (under one em), and "Hxgp" a 31 px box at 16 px.
#     It is not a line box, so the audit's size decision reads not_decided on every line, which is correct.
#   - the luminance is an estimate from a split inside the box (stzImage.TextLuminanceInBox). bg_spread is
#     given, so the audit can refuse a contrast taken over a gradient or a picture.
#
# The scale (device pixels per CSS pixel) is the caller's: it cannot be measured from pixels.

$cStzScreenshotFactsBoxKind = "ink"
$cStzScreenshotFactsMethod = "OCR box, BT.601 gray, Otsu split inside the box, the side with fewer pixels is the ink; " +
	"text = median luminance of the quarter of the ink pixels farthest from the split; background = median " +
	"luminance of the pixels at least 3 px (Chebyshev) from any ink pixel; bg_spread = their 2nd to 98th " +
	"percentile range (stzImage.TextLuminanceInBox)"

# Returns the facts of a screenshot as a hash list in the shape of zui-audit-facts 1.0 -- what
# StzScreenshotFactsJson writes out.
#
#   pcPng      the screenshot's path, kept as given in the facts
#   pnScale    device pixels per CSS pixel (2 on a typical high-density display), supplied by the caller
#   pcLang     the language of the text, as StzOcrModelLinesXT takes it ("en", "fr-FR", "ar-SA")
#   returns    [ :capture = [...], :lines = [ [ :id, :text, :score, :box, :line_height_px, :line_height_pt,
#              :fg_luminance, :bg_luminance, :contrast_ratio, :bg_spread ], ... ] ]; a null field is ""
#   warning    raises when the image does not exist, the scale is not above 0, or the OCR model is absent
func StzScreenshotFacts(pcPng, pnScale, pcLang)
	if NOT isNumber(pnScale) or pnScale <= 0
		stzraise("StzScreenshotFacts: the scale is device pixels per CSS pixel, a number above 0")
	ok
	if NOT fexists(pcPng)
		stzraise("StzScreenshotFacts: the image '" + pcPng + "' does not exist")
	ok
	_aOcr_ = StzOcrModelLinesXT(pcPng, pcLang)
	_oImg_ = new stzImage(pcPng)
	_aCapture_ = [
		:image = pcPng,
		:image_sha256 = lower(StzEngineCryptoSha256(read(pcPng))),
		:width_px = _oImg_.Width(),
		:height_px = _oImg_.Height(),
		:scale = pnScale,
		:box_kind = $cStzScreenshotFactsBoxKind,
		:ocr = [ :engine = "stzlib StzOcrModelLinesXT (PP-OCR detector, " + StzOcrModelRecogniserFor(pcLang) + ", ggml)",
			 :lang = pcLang ],
		:luminance = [ :standard = "WCAG-2.x-relative-luminance-sRGB", :method = $cStzScreenshotFactsMethod ]
	]
	_aLines_ = []
	_n_ = len(_aOcr_)
	for _i_ = 1 to _n_
		_aB_ = _aOcr_[_i_][:box]
		_aBox_ = [ floor(_aB_[1] + 0.5), floor(_aB_[2] + 0.5), floor(_aB_[3] + 0.5), floor(_aB_[4] + 0.5) ]
		_nPx_ = _aBox_[4] - _aBox_[2]
		_aL_ = _oImg_.TextLuminanceInBox(_aBox_)
		_nFg_ = ""
		_nBg_ = ""
		_nSp_ = ""
		if len(_aL_) > 0
			_nFg_ = _StzFactsRound(_aL_[:text], 6)
			if _aL_[:bgpixels] > 0
				_nBg_ = _StzFactsRound(_aL_[:background], 6)
				_nSp_ = _StzFactsRound(_aL_[:spread], 6)
			ok
		ok
		_nCr_ = ""
		if isNumber(_nFg_) and isNumber(_nBg_)
			_nHi_ = _nFg_
			_nLo_ = _nBg_
			if _nBg_ > _nFg_
				_nHi_ = _nBg_
				_nLo_ = _nFg_
			ok
			_nCr_ = _StzFactsRound((_nHi_ + 0.05) / (_nLo_ + 0.05), 2)
		ok
		add(_aLines_, [
			:id = "L" + _i_,
			:text = _aOcr_[_i_][:text],
			:score = _StzFactsRound(_aOcr_[_i_][:score], 4),
			:box = _aBox_,
			:line_height_px = _nPx_,
			:line_height_pt = _StzFactsRound(_nPx_ * 72 / (96 * pnScale), 2),
			:fg_luminance = _nFg_,
			:bg_luminance = _nBg_,
			:contrast_ratio = _nCr_,
			:bg_spread = _nSp_
		])
	next
	_oImg_.Release()
	return [ :capture = _aCapture_, :lines = _aLines_ ]

# Returns the facts of a screenshot as the JSON text of zui-audit-facts 1.0 (see StzScreenshotFacts).
func StzScreenshotFactsJson(pcPng, pnScale, pcLang)
	return _StzScreenshotFactsToJson(StzScreenshotFacts(pcPng, pnScale, pcLang))

# Writes the facts of a screenshot to a file as zui-audit-facts 1.0 JSON, and returns how many lines it holds.
#
#   pcOut      the facts file's path; an existing file is replaced
func StzWriteScreenshotFacts(pcPng, pnScale, pcLang, pcOut)
	_a_ = StzScreenshotFacts(pcPng, pnScale, pcLang)
	write(pcOut, _StzScreenshotFactsToJson(_a_))
	return len(_a_[:lines])

func _StzScreenshotFactsToJson(_a_)
	_c_ = _a_[:capture]
	_nl_ = char(10)
	_s_ = "{" + _nl_ + '  "format": "zui-audit-facts",' + _nl_ + '  "version": "1.0",' + _nl_ +
		'  "capture": {' + _nl_ +
		'    "image": ' + _StzFactsStr(_c_[:image]) + "," + _nl_ +
		'    "image_sha256": ' + _StzFactsStr(_c_[:image_sha256]) + "," + _nl_ +
		'    "width_px": ' + _c_[:width_px] + "," + _nl_ +
		'    "height_px": ' + _c_[:height_px] + "," + _nl_ +
		'    "scale": ' + _StzFactsNum(_c_[:scale]) + "," + _nl_ +
		'    "box_kind": ' + _StzFactsStr(_c_[:box_kind]) + "," + _nl_ +
		'    "ocr": { "engine": ' + _StzFactsStr(_c_[:ocr][:engine]) + ', "lang": ' + _StzFactsStr(_c_[:ocr][:lang]) + " }," + _nl_ +
		'    "luminance": {' + _nl_ +
		'      "standard": ' + _StzFactsStr(_c_[:luminance][:standard]) + "," + _nl_ +
		'      "method": ' + _StzFactsStr(_c_[:luminance][:method]) + _nl_ +
		"    }" + _nl_ + "  }," + _nl_ + '  "lines": ['
	_aL_ = _a_[:lines]
	_n_ = len(_aL_)
	for _i_ = 1 to _n_
		_l_ = _aL_[_i_]
		_b_ = _l_[:box]
		_s_ += _nl_ + "    { " +
			'"id": ' + _StzFactsStr(_l_[:id]) + ", " +
			'"text": ' + _StzFactsStr(_l_[:text]) + ", " +
			'"score": ' + _StzFactsNum(_l_[:score]) + "," + _nl_ + "      " +
			'"box": [' + _b_[1] + ", " + _b_[2] + ", " + _b_[3] + ", " + _b_[4] + "], " +
			'"line_height_px": ' + _l_[:line_height_px] + ", " +
			'"line_height_pt": ' + _StzFactsNum(_l_[:line_height_pt]) + "," + _nl_ + "      " +
			'"fg_luminance": ' + _StzFactsNum(_l_[:fg_luminance]) + ", " +
			'"bg_luminance": ' + _StzFactsNum(_l_[:bg_luminance]) + ", " +
			'"contrast_ratio": ' + _StzFactsNum(_l_[:contrast_ratio]) + ", " +
			'"bg_spread": ' + _StzFactsNum(_l_[:bg_spread]) + " }"
		if _i_ < _n_ _s_ += "," ok
	next
	if _n_ > 0 _s_ += _nl_ + "  " ok
	_s_ += "]" + _nl_ + "}" + _nl_
	return _s_

# a number rounded half away from zero to pnDec decimals (the audit recomputes with JavaScript's Math.round,
# which agrees on every non-negative value written here)
func _StzFactsRound(pnX, pnDec)
	_m_ = pow(10, pnDec)
	return floor(pnX * _m_ + 0.5) / _m_

# a JSON number with no more decimals than it has (at most 6), or null for ""; whatever decimals() the caller set
func _StzFactsNum(pnX)
	if isString(pnX) and pnX = "" return "null" ok
	_neg_ = ""
	if pnX < 0
		_neg_ = "-"
		pnX = -pnX
	ok
	_m_ = floor(pnX * 1000000 + 0.5)
	_int_ = floor(_m_ / 1000000)
	_frac_ = _m_ - _int_ * 1000000
	if _frac_ = 0 return _neg_ + _int_ ok
	_f_ = right("" + (1000000 + _frac_), 6)
	while right(_f_, 1) = "0"
		_f_ = left(_f_, len(_f_) - 1)
	end
	return _neg_ + _int_ + "." + _f_

# a JSON string: quote, backslash and control bytes escaped, every other byte (UTF-8 included) kept
func _StzFactsStr(pcS)
	_out_ = char(34)
	_n_ = len(pcS)
	for _i_ = 1 to _n_
		_ch_ = pcS[_i_]
		_a_ = ascii(_ch_)
		if _a_ = 34
			_out_ += "\" + char(34)
		but _a_ = 92
			_out_ += "\\"
		but _a_ < 32
			_h_ = "0123456789abcdef"
			_out_ += "\u00" + _h_[floor(_a_ / 16) + 1] + _h_[(_a_ % 16) + 1]
		else
			_out_ += _ch_
		ok
	next
	return _out_ + char(34)
