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
	return StzFindFirst("<html", pcStr) > 0 or StzFindFirst("<!DOCTYPE html", pcStr) > 0

	func @IsHtml(pcStr)
		return IsHtml(pcStr)

func HtmlToText(pcHtml)
	return HtmlQ(pcHtml).Text()

	func @HtmlToText(pcHtml)
		return HtmlToText(pcHtml)

# ── stzHtml -- document handle ──────────────────────────────

class stzHtml from stzObject

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

		def FindQ(pcSelector)
			return new stzList(This.Find(pcSelector))

	# A document is valid if it parsed and yielded at least one element.
	def IsValid()
		return @pDoc != NULL and This.NumberOfElements() > 0

		def IsWellFormed()
			return This.IsValid()

	# All element nodes, in document order.
	def Elements()
		_aR_ = []
		_n_ = This.NumberOfElements()
		for _i_ = 1 to _n_
			_aR_ + This._NodeAt(_i_)
		next
		return _aR_

	def HasTag(pcTag)
		return This.CountByTag(pcTag) > 0

		def HasBody()
			return This.HasTag("body")

		def HasHead()
			return This.HasTag("head")

	# Distinct tag names used, in first-seen order (lowercased).
	def TagsUsed()
		_aR_ = []
		_n_ = This.NumberOfElements()
		for _i_ = 1 to _n_
			_t_ = StzLower(StzEngineHtmlTagOf(@pDoc, _i_))
			# Manual membership: bare find() inside this class resolves to
			# the Find() METHOD (1 arg) -> R20, not the list builtin.
			_seen_ = FALSE
			_m_ = len(_aR_)
			for _j_ = 1 to _m_
				if _aR_[_j_] = _t_
					_seen_ = TRUE
					exit
				ok
			next
			if NOT _seen_
				_aR_ + _t_
			ok
		next
		return _aR_

	# Natural-condition query: a hashlist of [ :Tag, :Class, :Id ]
	# constraints (any subset); returns the element nodes matching ALL
	# given constraints.
	def ElementsWhere(paCriteria)
		if NOT isList(paCriteria)
			return []
		ok
		_cTag_ = "" _cClass_ = "" _cId_ = ""
		if HasKey(paCriteria, :Tag)   _cTag_   = paCriteria[:Tag]   ok
		if HasKey(paCriteria, :Class) _cClass_ = paCriteria[:Class] ok
		if HasKey(paCriteria, :Id)    _cId_    = paCriteria[:Id]    ok

		_aAll_ = This.Elements()
		_aR_ = []
		_n_ = len(_aAll_)
		for _i_ = 1 to _n_
			_oEl_ = _aAll_[_i_]
			if _cTag_ != "" and _oEl_.Tag() != StzLower(_cTag_)
				loop
			ok
			if _cClass_ != "" and NOT _oEl_.HasKlass(_cClass_)
				loop
			ok
			if _cId_ != "" and _oEl_.Id() != _cId_
				loop
			ok
			_aR_ + _oEl_
		next
		return _aR_

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

class stzHtmlNode from stzObject

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

# ── stzHtmlBuilder -- programmatic HTML construction ─────────
# A pure-Ring builder (the parser engine is read-only -- no DOM
# mutation bridges), building a tree of stzHtmlBuildNode and
# serialising to an HTML string.

class stzHtmlBuilder from stzObject

	@oRoot    = NULL   # document fragment (tag-less container)
	@oCurrent = NULL   # node new children are appended to

	def init()
		@oRoot    = new stzHtmlBuildNode("")
		@oCurrent = @oRoot

	# Detached node; attach it later via AppendToCurrent[Q].
	def CreateNode(pcTag)
		return new stzHtmlBuildNode(pcTag)

		def Node(pcTag)
			return This.CreateNode(pcTag)

	def AppendToCurrent(poNode)
		@oCurrent.AppendChild(poNode)
		return self

		# Chainable form (returns self so .AppendToCurrentQ(a).AppendToCurrentQ(b))
		def AppendToCurrentQ(poNode)
			This.AppendToCurrent(poNode)
			return self

	def SetCurrent(poNode)
		@oCurrent = poNode
		return self

		def SetCurrentQ(poNode)
			This.SetCurrent(poNode)
			return self

	def Current()
		return @oCurrent

	def Root()
		return @oRoot

	# Serialise the whole document to an HTML string.
	def Build()
		return @oRoot.ChildrenHtml()

		def ToHtml()
			return This.Build()

	def BuildToFile(pcPath)
		write(pcPath, This.Build())
		return self

# ── stzHtmlBuildNode -- a node in a builder tree ────────────

class stzHtmlBuildNode from stzObject

	@cTag      = ""
	@cText     = ""
	@aChildren = []
	@aAttrs    = []   # list of [name, value]

	def init(pcTag)
		@cTag      = pcTag
		@cText     = ""
		@aChildren = []
		@aAttrs    = []

	def Tag()
		return @cTag

	def SetText(pcText)
		@cText = pcText
		return self

		def SetTextQ(pcText)
			return This.SetText(pcText)

	def Text()
		return @cText

	def SetAttr(pcName, pcValue)
		@aAttrs + [ pcName, pcValue ]
		return self

	def AppendChild(poNode)
		@aChildren + poNode
		return self

		def Append(poNode)
			return This.AppendChild(poNode)

	def Children()
		return @aChildren

	# Serialise this node (tag, attrs, text then children) to HTML.
	def ToHtml()
		if @cTag = ""
			return This.ChildrenHtml()
		ok
		_cAttrs_ = ""
		_nA_ = len(@aAttrs)
		for _i_ = 1 to _nA_
			_cAttrs_ += " " + @aAttrs[_i_][1] + '="' + @aAttrs[_i_][2] + '"'
		next
		return "<" + @cTag + _cAttrs_ + ">" + @cText + This.ChildrenHtml() + "</" + @cTag + ">"

	def ChildrenHtml()
		_c_ = ""
		_n_ = len(@aChildren)
		for _i_ = 1 to _n_
			_c_ += @aChildren[_i_].ToHtml()
		next
		return _c_
