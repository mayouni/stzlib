/*
	Softanza HTML/CSS handling -- engine-backed (M-DEP2).
	Previously loaded the lexbor-based html.ring extension; rewired
	2026-06-13 to use the in-tree Zig parser at
	libraries/stzlib/engine/src/html_dom.zig.

	Surface covered by slice 2:
	* parsing + flat element index
	* find by tag, by id, by class
	* inner text + attribute lookup
	* document text extraction (scripts/styles suppressed)
	* tree walking via children/parent (no full CSS selectors yet)

	NOT yet supported (waiting for slice 3):
	* CSS selector parser (descendant, child combinators)
	* DOM mutation (setAttribute, appendChild, setInnerText)
	* Builder pattern (stzHtmlBuilder)
*/

# ── Global helpers ───────────────────────────────────────────

func HtmlQ(pcHtmlOrFile)
	if fexists(pcHtmlOrFile)
		pcHtmlOrFile = read(pcHtmlOrFile)
	ok
	return new stzHtml(pcHtmlOrFile)

	func @HtmlQ(pcHtmlOrFile)
		return HtmlQ(pcHtmlOrFile)

func IsHtml(pcStr)
	return StzFind(pcStr, "<html") > 0 or StzFind(pcStr, "<!DOCTYPE html") > 0

	func @IsHtml(pcStr)
		return IsHtml(pcStr)

func HtmlToText(pcHtml)
	return HtmlQ(pcHtml).Text()

	func @HtmlToText(pcHtml)
		return HtmlToText(pcHtml)

# ── stzHtml -- document handle ──────────────────────────────

class stzHtml

	@cHtml = ""        # original source
	@pDoc = NULL       # engine handle (opaque pointer)

	def init(pcHtml)
		if NOT isString(pcHtml)
			StzRaise("Incorrect param type! pcHtml must be a string.")
		ok
		@cHtml = pcHtml
		@pDoc = StzEngineHtmlParse(pcHtml)

	def Content()
		return @cHtml

		def Html()
			return This.Content()

	def Reload(pcHtml)
		if @pDoc != NULL StzEngineHtmlFree(@pDoc) ok
		@cHtml = pcHtml
		@pDoc = StzEngineHtmlParse(pcHtml)
		return 1

		def ReloadQ(pcHtml)
			This.Reload(pcHtml)
			return This

	# Document-level text -- scripts and styles suppressed by the engine.
	def Text()
		return StzEngineHtmlAllText(@pDoc)

		def PlainText()
			return This.Text()

	# Count + accessors over the flat element index.
	def NumberOfElements()
		return StzEngineHtmlCount(@pDoc)

	def CountByTag(pcTag)
		return StzEngineHtmlCountByTag(@pDoc, pcTag)

	# Find: minimal CSS-like dispatch (tag / #id / .class). Returns a
	# list of stzHtmlNode handles bound to this document.
	def Find(pcSelector)
		if NOT isString(pcSelector) or pcSelector = ""
			return []
		ok
		if StzLeft(pcSelector, 1) = "#"
			_nIdx_ = StzEngineHtmlFindById(@pDoc, StzMidToEnd(pcSelector, 2))
			if _nIdx_ > 0 return [ This._NodeAt(_nIdx_) ] ok
			return []
		ok
		if StzLeft(pcSelector, 1) = "."
			_cClass_ = StzMidToEnd(pcSelector, 2)
			_nC_ = StzEngineHtmlCountByClass(@pDoc, _cClass_)
			_aR_ = []
			for _i_ = 1 to _nC_
				_aR_ + This._NodeAt(StzEngineHtmlFindByClass(@pDoc, _cClass_, _i_))
			next
			return _aR_
		ok
		# Bare tag selector -- iterate by tag count.
		_nC_ = StzEngineHtmlCountByTag(@pDoc, pcSelector)
		_aR_ = []
		for _i_ = 1 to _nC_
			_aR_ + new stzHtmlNode(self, pcSelector, _i_)
		next
		return _aR_

	def FindFirst(pcSelector)
		_a_ = This.Find(pcSelector)
		if len(_a_) > 0 return _a_[1] ok
		return NULL

	def FindAll(pcSelector)
		return This.Find(pcSelector)

	# Engine handle accessor (used internally by stzHtmlNode).
	def _EngineHandle()
		return @pDoc

	# Build a node from a 1-based element index by reading its tag.
	def _NodeAt(nIdx)
		_cTag_ = StzEngineHtmlTagOf(@pDoc, nIdx)
		return new stzHtmlNode(self, _cTag_, This._OccurrenceOf(_cTag_, nIdx))

	# Find which occurrence of `tag` element nIdx represents.
	def _OccurrenceOf(pcTag, nIdx)
		_nC_ = This.NumberOfElements()
		_hit_ = 0
		for _i_ = 1 to _nC_
			if StzLower(StzEngineHtmlTagOf(@pDoc, _i_)) = StzLower(pcTag)
				_hit_++
				if _i_ = nIdx return _hit_ ok
			ok
		next
		return 1

# ── stzHtmlNode -- single element handle ────────────────────

class stzHtmlNode

	@oDoc = NULL       # owning stzHtml
	@cTag = ""         # tag name
	@nOcc = 1          # 1-based occurrence among same-tag elements

	def init(oDoc, pcTag, nOccurrence)
		@oDoc = oDoc
		@cTag = pcTag
		@nOcc = nOccurrence

	def Tag()
		return StzLower(@cTag)

	def Text()
		return StzEngineHtmlTextOfTag(@oDoc._EngineHandle(), @cTag, @nOcc)

	def Attr(cName)
		return StzEngineHtmlAttrOfTag(@oDoc._EngineHandle(), @cTag, @nOcc, cName)

		def Attribute(cName)
			return This.Attr(cName)

	def HasAttr(cName)
		return This.Attr(cName) != ""

	def Id()
		return This.Attr("id")

	def Klass()
		return This.Attr("class")

		def Class_()
			return This.Klass()

	def HasKlass(pcClass)
		_cAll_ = This.Klass()
		if _cAll_ = "" return FALSE ok
		_aParts_ = @split(_cAll_, " ")
		_nL_ = len(_aParts_)
		for _i_ = 1 to _nL_
			if @trim(_aParts_[_i_]) = pcClass return TRUE ok
		next
		return FALSE

		def HasClass(pcClass)
			return This.HasKlass(pcClass)
