load "../../stzBase.ring"
load "../_narrated.ring"

$RX_HANDLERS = [ "onerror", "onload", "onclick", "onmouseover", "onfocus" ]
$RX_RED = []       # [ sink, entry ] for every corpus entry a sink failed on
$RX_DECODES = 0    # 1 when the engine parser decodes entities in TextOfTag

RxMain()

# RX0 -- the hostile corpus and the parse-back oracle over every sink that
# writes text into HTML, JSON or SVG.
#
# WHAT THIS GUARD IS. A sink is a method that takes a text and writes it into
# markup or JSON. The corpus below is the text an attacker, a careless file or
# a model's output would hand such a sink. The ORACLE never reads the sink's
# own code and never compares bytes with what the writer meant to write: it
# parses the output back with the engine's own HTML parser (html_dom.zig) and
# JSON parser (json.zig) and asserts on the MECHANISM:
#
#   - no element appeared that the caller did not declare
#   - no event-handler attribute appeared on any element
#   - the text came back as given (decoded) from the element it was put in
#   - the JSON parses, and the value round-trips to the input
#   - the SVG stays well formed and carries no text or script element
#
# A comparison proves sameness, never rightness; the oracle is independent of
# the writer, which is why a sink that escapes "by coincidence" cannot pass it.
#
# STATE ON RX0 (2026-10-22): RED on purpose. A failing guard is the proof of
# the defect, and it stays out of every suite's gate until RX1 turns it green.
# The RED LIST printed at the end is the first figure of the render plane.
#
# Every positive has its negative sibling: the oracle itself is shown to SEE
# the injection on raw concatenation before any sink is judged, and the
# engine's own encoders are shown to pass it, so a green here is earned and
# not a coincidence.
#
# LIMITS, printed by the report too:
#   - the JSON read-back and the HTML attribute read-back go through a
#     4096-byte engine bridge buffer (the HTML text read-back through 64 KB),
#     so the long entry is held under that
#   - a .panel string cannot carry a double quote at all (its reader has no
#     escape), so the panel sink is judged on the corpus minus the quote cases
#   - the SVG sink is judged well-formed by the HTML parser, which is a tag
#     parser and not an XML validator
#   - "no untrusted text reaches this sink today" is a CENSUS question answered
#     in the RX0 memo, not here: this guard judges the sink, not its callers

# ---------------------------------------------------------------- the corpus

func _RxUtf8(nCp)
	if nCp < 128
		return char(nCp)
	but nCp < 2048
		return char(192 + floor(nCp / 64)) + char(128 + (nCp % 64))
	but nCp < 65536
		return char(224 + floor(nCp / 4096)) +
		       char(128 + (floor(nCp / 64) % 64)) +
		       char(128 + (nCp % 64))
	ok
	return char(240 + floor(nCp / 262144)) +
	       char(128 + (floor(nCp / 4096) % 64)) +
	       char(128 + (floor(nCp / 64) % 64)) +
	       char(128 + (nCp % 64))

func _RxCps(acCps)
	_c_ = ""
	_n_ = len(acCps)
	for _i_ = 1 to _n_
		_c_ += _RxUtf8(acCps[_i_])
	next
	return _c_

# [ name, text ] -- the text an untrusted caller could hand a sink
func _RxCorpus()
	_cLong_ = ""
	# 700 x "<a": 1400 bytes raw, 3500 encoded -- under the engine bridge's
	# 4096-byte attribute read-back, so the oracle can read it either way
	for _i_ = 1 to 700
		_cLong_ += "<a"
	next
	return [
		[ "script",     "<script>alert(1)</script>" ],
		[ "dquote",     'say "hi"' ],
		[ "squote",     "it's" ],
		[ "amp",        "fish & chips &amp; more" ],
		[ "closetag",   "x</p><p>y" ],
		[ "onerror",    '"><img src=x onerror=alert(1)>' ],
		[ "unbalanced", 'a"b' + "'c" ],
		[ "nul",        "a" + char(0) + "b" ],
		[ "bidi",       _RxUtf8(8238) + "abc" + _RxUtf8(8236) ],
		[ "controls",   "a" + char(13) + char(10) + char(9) + "b" ],
		[ "backslash",  "C:\dir\x" ],
		[ "long",       _cLong_ ],
		[ "arabic",     _RxCps([ 1605, 1585, 1581, 1576, 1575 ]) ],
		[ "hausa",      "Sannu, " + _RxUtf8(409) + "asa" ],
		[ "chinese",    _RxCps([ 20320, 22909 ]) ],
		[ "hebrew",     _RxCps([ 1513, 1500, 1493, 1501 ]) ]
	]

# the names of the corpus entries a .panel string cannot carry (no quote escape)
func _RxPanelExcluded()
	return [ "dquote", "onerror", "unbalanced" ]

# URL attribute values: escaping cannot fix a scheme, so these are a POLICY
# question, recorded as state and not asserted against today
func _RxUrlCorpus()
	return [
		[ "jsurl",   "javascript:alert(1)" ],
		[ "dataurl", "data:text/html,<script>alert(1)</script>" ],
		[ "break",   'x" onerror="alert(1)' ]
	]

# ---------------------------------------------------------------- the oracle


# position of a text in a list of texts, case-sensitive, 0 when absent
func _RxIn(cItem, acList)
	_n_ = len(acList)
	for _i_ = 1 to _n_
		if strcmp("" + acList[_i_], "" + cItem) = 0
			return _i_
		ok
	next
	return 0

func _RxEq(a, b)
	if strcmp("" + a, "" + b) = 0
		return 1
	ok
	return 0

func _RxRed(cSink, cEntry)
	$RX_RED + [ cSink, cEntry ]

# the lowercase tag of every element, in document order
func _RxTags(cHtml)
	_p_ = StzEngineHtmlParse(cHtml)
	_a_ = []
	_n_ = StzEngineHtmlCount(_p_)
	for _i_ = 1 to _n_
		_a_ + StzLower(StzEngineHtmlTagOf(_p_, _i_))
	next
	StzEngineHtmlFree(_p_)
	return _a_

# how many elements carry a tag outside the declared set
func _RxUndeclared(cHtml, acDeclared)
	_a_ = _RxTags(cHtml)
	_n_ = len(_a_)
	_nBad_ = 0
	for _i_ = 1 to _n_
		if _RxIn(_a_[_i_], acDeclared) = 0
			_nBad_++
		ok
	next
	return _nBad_

# how many elements carry an event-handler attribute
func _RxHandlers(cHtml)
	_p_ = StzEngineHtmlParse(cHtml)
	_n_ = StzEngineHtmlCount(_p_)
	_aSeen_ = []        # tag -> occurrences met so far
	_nBad_ = 0
	_nH_ = len($RX_HANDLERS)
	for _i_ = 1 to _n_
		_t_ = StzLower(StzEngineHtmlTagOf(_p_, _i_))
		_nOcc_ = 1
		_nS_ = len(_aSeen_)
		_bFound_ = 0
		for _k_ = 1 to _nS_
			if _RxEq(_aSeen_[_k_][1], _t_)
				_aSeen_[_k_][2]++
				_nOcc_ = _aSeen_[_k_][2]
				_bFound_ = 1
				exit
			ok
		next
		if _bFound_ = 0
			_aSeen_ + [ _t_, 1 ]
		ok
		for _h_ = 1 to _nH_
			if len(StzEngineHtmlAttrOfTag(_p_, _t_, _nOcc_, $RX_HANDLERS[_h_])) > 0
				_nBad_++
				exit
			ok
		next
	next
	StzEngineHtmlFree(_p_)
	return _nBad_

# the text of the n-th element of a tag, decoded to what the reader sees
func _RxTextOf(cHtml, cTag, n)
	_p_ = StzEngineHtmlParse(cHtml)
	_c_ = StzEngineHtmlTextOfTag(_p_, cTag, n)
	StzEngineHtmlFree(_p_)
	if $RX_DECODES = 0
		_c_ = StzEngineHtmlDecode(_c_)
	ok
	return _c_

func _RxAttrOf(cHtml, cTag, n, cAttr)
	_p_ = StzEngineHtmlParse(cHtml)
	_c_ = StzEngineHtmlAttrOfTag(_p_, cTag, n, cAttr)
	StzEngineHtmlFree(_p_)
	return StzEngineHtmlDecode(_c_)

# 1 when the HTML holds exactly the declared elements, no handler, and the
# text of (cTag, n) decodes to cExpected
func _RxHtmlOk(cHtml, acDeclared, cTag, n, cExpected)
	if _RxUndeclared(cHtml, acDeclared) > 0
		return 0
	ok
	if _RxHandlers(cHtml) > 0
		return 0
	ok
	return _RxEq(_RxTextOf(cHtml, cTag, n), cExpected)

# 1 when the JSON parses and the value under cKey round-trips
func _RxJsonOk(cJson, cKey, cExpected)
	_p_ = StzEngineJsonParse(cJson)
	if _p_ = ""
		return 0
	ok
	if StzEngineJsonIsValid(_p_) != 1
		StzEngineJsonFree(_p_)
		return 0
	ok
	_c_ = StzEngineJsonGetString(_p_, cKey)
	StzEngineJsonFree(_p_)
	return _RxEq(_c_, cExpected)

# runs one HTML sink over the whole corpus; pSink is a function name that
# takes the text and returns the markup
func _RxSweepHtml(cSink, cFunc, acDeclared, cTag, n)
	_aC_ = _RxCorpus()
	_nC_ = len(_aC_)
	_nFail_ = 0
	for _i_ = 1 to _nC_
		_cOut_ = call cFunc(_aC_[_i_][2])
		if _RxHtmlOk(_cOut_, acDeclared, cTag, n, _aC_[_i_][2]) = 0
			_nFail_++
			_RxRed(cSink, _aC_[_i_][1])
		ok
	next
	return _nFail_

func _RxSweepJson(cSink, cFunc)
	_aC_ = _RxCorpus()
	_nC_ = len(_aC_)
	_nFail_ = 0
	for _i_ = 1 to _nC_
		_cOut_ = call cFunc(_aC_[_i_][2])
		if _RxJsonOk(_cOut_, "k", _aC_[_i_][2]) = 0
			_nFail_++
			_RxRed(cSink, _aC_[_i_][1])
		ok
	next
	return _nFail_

# ---------------------------------------------------------------- the sinks

# raw concatenation: the negative sibling the oracle must SEE through
func _RxRawP(t)
	return "<p>" + t + "</p>"

# the engine's own encoders: the model every sink should reach (RX1)
func _RxEngineP(t)
	return "<p>" + StzEngineHtmlEncode(t) + "</p>"

func _RxEngineAttrP(t)
	return '<p title="' + StzEngineHtmlEncodeAttribute(t) + '">x</p>'

# sink 1 -- stzHtmlBuildNode.SetText / SetAttr, the writer under stzHtmlBuilder
func _RxNodeText(t)
	_o_ = new stzHtmlBuildNode("p")
	_o_.SetText(t)
	return _o_.ToHtml()

func _RxNodeAttr(t)
	_o_ = new stzHtmlBuildNode("p")
	_o_.SetAttr("title", t)
	_o_.SetText("x")
	return _o_.ToHtml()

func _RxBuilderText(t)
	_oB_ = new stzHtmlBuilder()
	_oN_ = _oB_.CreateNode("p")
	_oN_.SetText(t)
	_oB_.AppendToCurrent(_oN_)
	return _oB_.Build()

# sink 2 -- stzUiDocument: a .panel whose TEXT box holds the text
func _RxPanelSource(t)
	return 'DEFINE PANEL screen (' + char(10) +
	       '  SIZE [400, 200],' + char(10) +
	       '  DIRECTION column,' + char(10) +
	       '  FONT "app",' + char(10) +
	       '  CHILDREN [box1]' + char(10) +
	       ') RATIONALE "The RX0 probe panel."' + char(10) + char(10) +
	       'DEFINE TEXT box1 (' + char(10) +
	       '  CONTENT "' + t + '",' + char(10) +
	       '  SIZE 16' + char(10) +
	       ') RATIONALE "One box holding the corpus entry."' + char(10)

func _RxPanelHtml(t)
	_o_ = new stzUiDocument(_RxPanelSource(t))
	return _o_.ToHtml()

func _RxPanelText(t)
	_o_ = new stzUiDocument(_RxPanelSource(t))
	return _o_.ToText()

func _RxPanelA11y(t)
	_o_ = new stzUiDocument(_RxPanelSource(t))
	_oT_ = new stzAccessibilityTree(_o_, NULL)
	return _oT_.ToJSON()

# sink 3 -- stzAppResponse.ObjectToJson, the writer under Json()
func _RxResponseJson(t)
	_o_ = new stzAppResponse(NULL)
	return _o_.ObjectToJson([ "k", t ])

# sink 3b -- stzAppServer._RowsJson: the rows a client posted, back out as JSON
func _RxRowsJson(t)
	_oS_ = new stzAppServer()
	return _oS_._RowsJson([ [ t ] ])

# sink 4 -- stzPlatform._WebShell: the world's name and screen names
func _RxShell(t)
	_oP_ = new stzPlatform("rx0")
	_oP_.SetWorld(new rxFakeWorld(t))
	return _oP_._WebShell()

# ================================================================ scenarios

func RxMain()

Scenario("The oracle sees what a raw concatenation lets through")
	Given("a text with a script element, written into a p without escaping")
	cRaw = _RxRawP("<script>alert(1)</script>")
	Then("an undeclared element is counted", _RxUndeclared(cRaw, [ "p" ]), 1)
	Given("a text closing the p and opening an img with an onerror handler")
	cRaw2 = _RxRawP('x</p><img src=x onerror=alert(1)><p>y')
	Then("the handler is counted", _RxHandlers(cRaw2) > 0, 1)
	Then("and the element too", _RxUndeclared(cRaw2, [ "p" ]) > 0, 1)
	Given("a benign text")
	Then("nothing is counted", _RxUndeclared(_RxRawP("hello"), [ "p" ]) + _RxHandlers(_RxRawP("hello")), 0)
	Given("an entity in the markup")
	pD = StzEngineHtmlParse("<p>&amp;x</p>")
	cT = StzEngineHtmlTextOfTag(pD, "p", 1)
	StzEngineHtmlFree(pD)
	if _RxEq(cT, "&x")
		$RX_DECODES = 1
	ok
	if $RX_DECODES = 1
		? "  (the engine parser DECODES entities in TextOfTag; the oracle adapts)"
	else
		? "  (the engine parser does not decode entities in TextOfTag; the oracle adapts)"
	ok
	Then("the decoded text of the element is the character", _RxEq(_RxTextOf("<p>&amp;x</p>", "p", 1), "&x"), 1)
EndScenario()

Scenario("The engine's own encoders pass the oracle over the whole corpus")
	Given("every corpus entry through StzEngineHtmlEncode inside a p")
	nF = _RxSweepHtml("engine-encode", "_RxEngineP", [ "p" ], "p", 1)
	Then("no entry fails", nF, 0)
	Given("every corpus entry through StzEngineHtmlEncodeAttribute in a title")
	aC = _RxCorpus()
	nC = len(aC)
	nBad = 0
	for i = 1 to nC
		cOut = _RxEngineAttrP(aC[i][2])
		if _RxUndeclared(cOut, [ "p" ]) > 0 or _RxHandlers(cOut) > 0 or
		   _RxEq(_RxAttrOf(cOut, "p", 1, "title"), aC[i][2]) = 0
			nBad++
			_RxRed("engine-encode-attribute", aC[i][1])
		ok
	next
	Then("no entry fails", nBad, 0)
EndScenario()

Scenario("Sink 1: stzHtmlBuildNode.SetText writes the text as given")
	Given("every corpus entry through SetText on a p node")
	nF = _RxSweepHtml("stzHtmlBuildNode.SetText", "_RxNodeText", [ "p" ], "p", 1)
	Then("no entry fails (RED on RX0: the node escapes nothing)", nF, 0)
	Given("the same three entries through stzHtmlBuilder.Build, the same writer")
	nF2 = 0
	for cE in [ "<script>alert(1)</script>", "x</p><p>y", "fish & chips" ]
		if _RxHtmlOk(_RxBuilderText(cE), [ "p" ], "p", 1, cE) = 0
			nF2++
		ok
	next
	Then("no entry fails (RED on RX0)", nF2, 0)
EndScenario()

Scenario("Sink 1b: stzHtmlBuildNode.SetAttr writes the value between quotes as given")
	Given("every corpus entry as the title attribute of a p")
	aC = _RxCorpus()
	nC = len(aC)
	nBad = 0
	for i = 1 to nC
		cOut = _RxNodeAttr(aC[i][2])
		if _RxUndeclared(cOut, [ "p" ]) > 0 or _RxHandlers(cOut) > 0 or
		   _RxEq(_RxAttrOf(cOut, "p", 1, "title"), aC[i][2]) = 0
			nBad++
			_RxRed("stzHtmlBuildNode.SetAttr", aC[i][1])
		ok
	next
	Then("no entry fails (RED on RX0)", nBad, 0)
	Given("the three URL values as the href of an a node -- a policy, recorded not asserted")
	aU = _RxUrlCorpus()
	for i = 1 to len(aU)
		oA = new stzHtmlBuildNode("a")
		oA.SetAttr("href", aU[i][2])
		oA.SetText("link")
		cOut = oA.ToHtml()
		? "  state  href '" + aU[i][1] + "' -> read back '" + _RxAttrOf(cOut, "a", 1, "href") +
		  "', handlers " + _RxHandlers(cOut) + ", undeclared " + _RxUndeclared(cOut, [ "a" ])
	next
	Then("the oracle ran over the URL cases", len(aU), 3)
EndScenario()

Scenario("Sink 2: stzUiDocument projects a TEXT box to HTML, text and accessibility JSON")
	Given("a clean two-declaration panel with a plain content")
	oBase = new stzUiDocument(_RxPanelSource("plain"))
	Then("the probe panel is clean", oBase.IsClean(), 1)
	cBase = oBase.ToHtml()
	aDeclared = _RxTags(cBase)
	nBox = 0
	nDiv = 0
	for cT in aDeclared
		if _RxEq(cT, "div")
			nDiv++
			if _RxEq(_RxTextOf(cBase, "div", nDiv), "plain")
				nBox = nDiv
			ok
		ok
	next
	Then("the box's div is found by its text", nBox > 0, 1)
	Given("every corpus entry the .panel syntax can carry, as the CONTENT")
	aC = _RxCorpus()
	nC = len(aC)
	aEx = _RxPanelExcluded()
	nBad = 0
	nBadText = 0
	nBadJson = 0
	nRun = 0
	for i = 1 to nC
		if _RxIn(aC[i][1], aEx) > 0
			loop
		ok
		nRun++
		cE = aC[i][2]
		cH = _RxPanelHtml(cE)
		if _RxHtmlOk(cH, aDeclared, "div", nBox, cE) = 0
			nBad++
			_RxRed("stzUiDocument.ToHtml", aC[i][1])
		ok
		if StzFindFirst(cE, _RxPanelText(cE)) = 0
			nBadText++
			_RxRed("stzUiDocument.ToText", aC[i][1])
		ok
		cJ = _RxPanelA11y(cE)
		if StzJsonIsValid(cJ) = 0
			nBadJson++
			_RxRed("stzAccessibilityTree.ToJSON", aC[i][1])
		ok
	next
	? "  (" + nRun + " of " + nC + " entries run; the quote cases cannot be written in a .panel string)"
	Then("no entry fails the HTML oracle", nBad, 0)
	Then("every entry is carried by the text twin", nBadText, 0)
	Then("every entry gives valid accessibility JSON", nBadJson, 0)
EndScenario()

Scenario("Sink 3: stzAppResponse.ObjectToJson quotes a text without escaping it")
	Given("every corpus entry as the value of key k")
	nF = _RxSweepJson("stzAppResponse.ObjectToJson", "_RxResponseJson")
	Then("no entry fails (RED on RX0: a quote inside gives invalid JSON)", nF, 0)
	Given("the key side too: a key holding a quote")
	oRsp = new stzAppResponse(NULL)
	aKey = [ 'a"b', 1 ]
	cKeyJson = oRsp.ObjectToJson(aKey)
	Then("the JSON is valid", StzJsonIsValid(cKeyJson), 1)
EndScenario()

Scenario("Sink 3b: stzAppServer._RowsJson escapes only the double quote of a cell")
	Given("every corpus entry as the one cell of one row")
	aC = _RxCorpus()
	nC = len(aC)
	nBad = 0
	for i = 1 to nC
		cJ = _RxRowsJson(aC[i][2])
		bOk = 0
		if StzJsonIsValid(cJ)
			aL = StzEngineJsonParseToList(cJ)
			if isList(aL) and len(aL) = 1 and isList(aL[1]) and len(aL[1]) = 1
				bOk = _RxEq(aL[1][1], aC[i][2])
			ok
		ok
		if bOk = 0
			nBad++
			_RxRed("stzAppServer._RowsJson", aC[i][1])
		ok
	next
	Then("no entry fails (RED on RX0)", nBad, 0)
EndScenario()

Scenario("Sink 4: stzPlatform._WebShell concatenates the world's name into the title, the h1 and the li")
	Given("a baseline shell for a plain world name, to learn the declared elements")
	cBase = _RxShell("plain")
	aDeclared = _RxTags(cBase)
	Then("the shell has a title, an h1 and an li", _RxIn("title", aDeclared) > 0 and _RxIn("h1", aDeclared) > 0 and _RxIn("li", aDeclared) > 0, 1)
	Given("every corpus entry as the world's name")
	aC = _RxCorpus()
	nC = len(aC)
	nBad = 0
	for i = 1 to nC
		cOut = _RxShell(aC[i][2])
		if _RxUndeclared(cOut, aDeclared) > 0 or _RxHandlers(cOut) > 0 or
		   _RxEq(_RxTextOf(cOut, "h1", 1), aC[i][2]) = 0
			nBad++
			_RxRed("stzPlatform._WebShell", aC[i][1])
		ok
	next
	Then("no entry fails (RED on RX0)", nBad, 0)
EndScenario()

Scenario("SVG: the canvas carries a label as glyph outlines and refuses a bad identifier")
	Given("a canvas with a system font and the script entry as its label")
	oF = new stzFont("C:/Windows/Fonts/arial.ttf")
	oCv = new stzCanvas(300, 100)
	oCv.SetFont(oF, 20)
	oCv.AddText("plain", 10, 50)
	cBase = oCv.ToSVG()
	aDeclared = _RxTags(cBase)
	oCv.Free()
	Then("the plain SVG has elements", len(aDeclared) > 0, 1)
	Then("and no text element: glyphs are outlines", _RxIn("text", aDeclared), 0)
	Given("every corpus entry as the label")
	aC = _RxCorpus()
	nC = len(aC)
	nBad = 0
	for i = 1 to nC
		oCv = new stzCanvas(300, 100)
		oCv.SetFont(oF, 20)
		oCv.AddText(aC[i][2], 10, 50)
		cS = oCv.ToSVG()
		oCv.Free()
		if _RxUndeclared(cS, aDeclared) > 0 or _RxHandlers(cS) > 0
			nBad++
			_RxRed("stzCanvas.ToSVG", aC[i][1])
		ok
	next
	Then("no entry adds an element or a handler", nBad, 0)
	Given("an identifier holding a quote, through the declared door")
	oCv = new stzCanvas(10, 10)
	bRaised = 0
	try
		oCv.SetSvgIdent('a"b', "")
	catch
		bRaised = 1
	done
	oCv.Free()
	Then("the door refuses it rather than escaping it", bRaised, 1)
EndScenario()

# ---------------------------------------------------------------- the red list

? char(10) + "RED LIST -- corpus entries each sink failed on (RX0 figure)"
aSinks = []
for aR in $RX_RED
	bSeen = 0
	for aS in aSinks
		if _RxEq(aS[1], aR[1])
			aS[2] + aR[2]
			bSeen = 1
			exit
		ok
	next
	if bSeen = 0
		aSinks + [ aR[1], [ aR[2] ] ]
	ok
next
for aS in aSinks
	cLine = "  " + aS[1] + ": " + len(aS[2]) + " of " + len(_RxCorpus()) + " --"
	for cN in aS[2]
		cLine += " " + cN
	next
	? cLine
next
if len(aSinks) = 0
	? "  (empty)"
ok
? "LIMITS: JSON and HTML-attribute read-back through a 4096-byte bridge buffer; .panel strings cannot carry a quote;" +
  " SVG judged by the tag parser, not an XML validator; callers are counted in the census, not here."

Summary()

# ---------------------------------------------------------------- fixtures

class rxFakeWorld
	@cName = ""
	def init(pcName)
		@cName = pcName
	def Name()
		return @cName
	def Surfaces()
		return [ "web" ]
	def Things()
		return [ [ "thing1", [ "f1" ] ] ]
	def ScreenNames()
		return [ "home", @cName ]
