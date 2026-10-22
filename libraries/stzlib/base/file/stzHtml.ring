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

# -- The escape faces (RX1) --------------------------------------------------
# Text is the default and markup the exception. These two are the only way
# text enters the markup the library writes: both are the engine's
# html_encode and html_encode_attribute, so one policy serves every sink,
# and no Ring-side escaper stands beside them.

# Returns the text with each bidirectional embedding or override (U+202A to U+202E) written as
# a visible marker such as [U+202E], and every other character as it is.
#
#   returns    a text; the isolates (U+2066 to U+2069) and the marks (U+200E, U+200F) are kept,
#              because Arabic and Hebrew text uses them
#   note       ruled by the Principal on 2026-10-22 after a rendered page read abc as cba;
#              the three escaping faces below apply it first, so every text sink does
#   see        StzHtmlEscaped, StzHtmlAttrEscaped, StzJsonString
func StzBidiNeutralized(pcText)
	return StzEngineHtmlNeutralizeBidi("" + pcText)

	func @StzBidiNeutralized(pcText)
		return StzBidiNeutralized(pcText)

# Returns the text with & < > " and ' written as entities, for an element's content.
#
#   note       the bidirectional overrides are neutralized first, see StzBidiNeutralized
#
#   example    ? StzHtmlEscaped("fish & <chips>")
#              #--> fish &amp; &lt;chips&gt;
func StzHtmlEscaped(pcText)
	return StzEngineHtmlEncode(StzEngineHtmlNeutralizeBidi("" + pcText))

	func @StzHtmlEscaped(pcText)
		return StzHtmlEscaped(pcText)

# Returns the text with & < > " and ' written as entities, for an attribute value between double quotes.
#
#   example    ? StzHtmlAttrEscaped('say "hi"')
#              #--> say &quot;hi&quot;
func StzHtmlAttrEscaped(pcText)
	return StzEngineHtmlEncodeAttribute(StzEngineHtmlNeutralizeBidi("" + pcText))

	func @StzHtmlAttrEscaped(pcText)
		return StzHtmlAttrEscaped(pcText)

# 1 when the text is an attribute name: a letter or underscore, then letters, digits, - _ : or .
func _StzHtmlIsAttrName(pcName)
	if NOT isString(pcName)
		return 0
	ok
	_n_ = len(pcName)
	if _n_ = 0
		return 0
	ok
	for _i_ = 1 to _n_
		_b_ = ascii(pcName[_i_])
		_bLetter_ = (_b_ >= 65 and _b_ <= 90) or (_b_ >= 97 and _b_ <= 122)
		if _i_ = 1
			if NOT (_bLetter_ or _b_ = 95)
				return 0
			ok
		else
			if NOT (_bLetter_ or (_b_ >= 48 and _b_ <= 57) or _b_ = 45 or
			        _b_ = 95 or _b_ = 58 or _b_ = 46)
				return 0
			ok
		ok
	next
	return 1

# 1 when a URL value names a script scheme, read the way a browser reads it:
# the control characters and spaces are dropped first, then the case is folded
func _StzHtmlUrlIsRefused(pcUrl)
	_c_ = "" + pcUrl
	_n_ = len(_c_)
	_cBare_ = ""
	for _i_ = 1 to _n_
		if ascii(_c_[_i_]) > 32
			_cBare_ += _c_[_i_]
		ok
	next
	_cLow_ = StzLower(_cBare_)
	if StzFindFirst("javascript:", _cLow_) = 1 or StzFindFirst("vbscript:", _cLow_) = 1 or
	   StzFindFirst("data:", _cLow_) = 1
		return 1
	ok
	return 0

# ── stzHtml -- document handle ──────────────────────────────

# Parses HTML text with the engine and finds its elements by tag, id or class, giving their text and attributes.
#
# Reach for it to read a page: Find takes a tag name, #id or .class and returns node handles
# (stzHtmlNode) whose Text and Attr read the element. Text on the document gives all the visible
# text with scripts and styles removed. The parser is read-only, so the document cannot be changed,
# and there are no selector combinators: use ElementsWhere to combine a tag, a class and an id. It
# holds text, it does not fetch pages; HtmlQ(text-or-file) is the shortcut.
#
#   receiver   o1 = new stzHtml('<html><body><div id="main" class="box big"><p>Hello</p></div><div
#              class="box">Two</div></body></html>')
#   example    ? o1.CountByTag("div")
#              #--> 2
#              ? o1.FindFirst("#main").Klass()
#              #--> box big
#              ? len(o1.Find(".box"))
#              #--> 2
#              ? len(o1.ElementsWhere([ :Tag = "div", :Class = "big" ]))
#              #--> 1
#   see        stzHtmlNode, stzXml, stzHtmlBuilder
class stzHtml from stzObject

	@cHtml = ""        # original source
	@pDoc = ""       # engine handle (opaque pointer)

	# Builds a document object by parsing HTML text with the engine; a value that is not a text raises an error.
	#
	#   pcHtml     the HTML source as text
	#   returns    nothing; the object is built
	#   note       the error text is Incorrect param type! pcHtml must be a string.; broken markup
	#              is accepted and repaired by the parser
	#   see        Content, Reload, IsValid
	def init(pcHtml)
		if NOT isString(pcHtml)
			StzRaise("Incorrect param type! pcHtml must be a string.")
		ok
		@cHtml = pcHtml
		@pDoc = StzEngineHtmlParse(pcHtml)

	# Returns the HTML source the object was built from, unchanged.
	#
	#   returns    a text
	#   see        Text, Reload
	def Content()
		return @cHtml

		def Html()
			return This.Content()

	# Parses new HTML text and drops the previous document.
	#
	#   pcHtml     the new HTML source as text
	#   returns    1
	#   note       Content, Text and every Find now answer for the new source
	#   see        Content
	def Reload(pcHtml)
		if @pDoc != "" StzEngineHtmlFree(@pDoc) ok
		@cHtml = pcHtml
		@pDoc = StzEngineHtmlParse(pcHtml)
		return 1

		def ReloadQ(pcHtml)
			This.Reload(pcHtml)
			return This

	# Returns the visible text of the whole document, without tags, scripts or styles; neighbouring elements run together.
	#
	#   returns    a text
	#   note       a div holding two p elements, Hello and World, reads HelloWorld; a document
	#              without any element gives its plain text back
	#   see        Content, Find
	#@ aka  Document-level text -- scripts and styles suppressed by the engine.
	def Text()
		return StzEngineHtmlAllText(@pDoc)

		def PlainText()
			return This.Text()

	# Returns how many elements the parser found, html, head and body included when the parser adds them.
	#
	#   returns    a number
	#   note       text without tags answers 0
	#   see        CountByTag, Elements
	#@ aka  Count + accessors over the flat element index.
	def NumberOfElements()
		return StzEngineHtmlCount(@pDoc)

	# Returns how many elements have a given tag, ignoring the case of the tag.
	#
	#   pcTag      the tag name, such as div
	#   returns    a number
	#   note       CountByTag("DIV") and CountByTag("div") agree
	#   see        HasTag, TagsUsed
	def CountByTag(pcTag)
		return StzEngineHtmlCountByTag(@pDoc, pcTag)

	# Returns the elements matching a selector: a tag name, #id or .class; an empty text, a non-text or no match gives an empty list.
	#
	#   pcSelector   a tag such as div, an id such as #main, or a class such as .box
	#   returns      a list of stzHtmlNode
	#   note         only these three forms exist: no combinators and no attribute selectors
	#   see          FindFirst, ElementsWhere, Elements
	#@ aka  Find: minimal CSS-like dispatch (tag / #id / .class). Returns a list of stzHtmlNode handles bound to this document.
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
			# ONE engine pass returning [ tag, occurrence ] for every match.
			#
			# This looped FindByClass(class, 1..count), and each of those
			# re-scanned all elements from the start to reach the i-th match,
			# then _NodeAt scanned AGAIN to compute occurrence -- O(n^2), and
			# Find(".row") over 800 rows took ~3s. The occurrence the engine
			# reports is the same case-insensitive document-order rank that
			# TextOfTag/AttrOfTag count by, so the node addresses the right
			# element.
			_cClass_ = StzMidToEnd(pcSelector, 2)
			_aPairs_ = StzEngineHtmlClassPairs(@pDoc, _cClass_)
			_aR_ = []
			_nPairs_ = len(_aPairs_)
			for _i_ = 1 to _nPairs_
				_aR_ + new stzHtmlNode(self, _aPairs_[_i_][1], _aPairs_[_i_][2])
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

	# Returns the first element matching a selector, in document order.
	#
	#   pcSelector   a tag, #id or .class, as for Find
	#   returns      a stzHtmlNode; the empty text when nothing matches
	#   note         test the result with isObject before calling a method on it
	#   see          Find, ElementsWhere
	def FindFirst(pcSelector)
		_a_ = This.Find(pcSelector)
		if len(_a_) > 0 return _a_[1] ok
		return ""

	def FindAll(pcSelector)
		return This.Find(pcSelector)

		def FindQ(pcSelector)
			return new stzList(This.Find(pcSelector))

	# Returns TRUE if the parse succeeded and produced at least one element.
	#
	#   returns    TRUE or FALSE
	#   note       the empty text and plain text without tags answer FALSE
	#   see        NumberOfElements
	#@ aka  A document is valid if it parsed and yielded at least one element.
	def IsValid()
		return @pDoc != "" and This.NumberOfElements() > 0

		def IsWellFormed()
			return This.IsValid()

	# Returns every element of the document as a node, in document order.
	#
	#   returns    a list of stzHtmlNode
	#   note       a page of 12 elements gives 12 nodes, the first being html
	#   see        Find, NumberOfElements, TagsUsed
	#@ aka  All element nodes, in document order.
	def Elements()
		_aR_ = []
		_n_ = This.NumberOfElements()
		for _i_ = 1 to _n_
			_aR_ + This._NodeAt(_i_)
		next
		return _aR_

	# Returns TRUE if at least one element has the tag.
	#
	#   pcTag      the tag name, such as table
	#   returns    TRUE or FALSE
	#   note       the case of the tag does not matter
	#   see        CountByTag, HasBody
	def HasTag(pcTag)
		return This.CountByTag(pcTag) > 0

		# Returns TRUE if the document has a body element.
		#
		#   returns    TRUE or FALSE
		#   see        HasHead, HasTag
		def HasBody()
			return This.HasTag("body")

		# Returns TRUE if the document has a head element.
		#
		#   returns    TRUE or FALSE
		#   see        HasBody, HasTag
		def HasHead()
			return This.HasTag("head")

	# Returns the distinct tag names, lower case, in the order they first appear.
	#
	#   returns    a list of texts
	#   note       for a full page it starts with html, head, title
	#   see        CountByTag, Elements
	#@ aka  Distinct tag names used, in first-seen order (lowercased).
	def TagsUsed()
		_aR_ = []
		_n_ = This.NumberOfElements()
		for _i_ = 1 to _n_
			_t_ = StzLower(StzEngineHtmlTagOf(@pDoc, _i_))
			# Manual membership: bare find() inside this class resolves to
			# the Find() METHOD (1 arg) -> R20, not the list builtin.
			_seen_ = 0
			_m_ = len(_aR_)
			for _j_ = 1 to _m_
				if _aR_[_j_] = _t_
					_seen_ = 1
					exit
				ok
			next
			if NOT _seen_
				_aR_ + _t_
			ok
		next
		return _aR_

	# Returns the elements matching every given constraint among :Tag, :Class and :Id.
	#
	#   paCriteria   a hash list such as [ :Tag = "div", :Class = "box" ]
	#   returns      a list of stzHtmlNode
	#   note         an empty list of criteria gives every element; a value that is not a list gives
	#                an empty list; a class matches one word of the class attribute
	#   see          Find, Elements
	#@ aka  Natural-condition query: a hashlist of [ :Tag, :Class, :Id ] constraints (any subset); returns the element nodes matching ALL given constraints.
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

# Points at one element of a parsed HTML document and reads its tag, text, id, class and attributes.
#
# A handle is the document, a tag name and the rank of the element among elements of that tag. It is
# made by Find, FindFirst, Elements and ElementsWhere of stzHtml. The document is read-only, so a
# node cannot change anything.
#
#   receiver   d1 = new stzHtml('<div id="main" class="box big"><a href="/u">link</a></div>') o1 =
#              d1.FindFirst("#main")
#   example    ? o1.Tag()
#              #--> div
#              ? o1.HasKlass("big")
#              #--> 1
#              ? o1.Text()
#              #--> link
#              ? d1.FindFirst("a").Attr("href")
#              #--> /u
#   see        stzHtml
class stzHtmlNode from stzObject

	@oDoc = ""       # owning stzHtml
	@cTag = ""         # tag name
	@nOcc = 1          # 1-based occurrence among same-tag elements

	# Builds a handle to the n-th element with a given tag in a stzHtml document.
	#
	#   oDoc          the stzHtml document that owns the element
	#   pcTag         the tag name
	#   nOccurrence   which element of that tag, counted from 1
	#   returns       nothing; the object is built
	#   note          normally made by Find, FindFirst or Elements of stzHtml
	#   see           Tag, Text
	def init(oDoc, pcTag, nOccurrence)
		@oDoc = oDoc
		@cTag = pcTag
		@nOcc = nOccurrence

	# Returns the tag name in lower case.
	#
	#   returns    a text
	#   see        Id, Klass
	def Tag()
		return StzLower(@cTag)

	# Returns the text inside the element, descendants included.
	#
	#   returns    a text
	#   note       text of child elements runs together: a paragraph with a bold part reads World x;
	#              a script element gives its code
	#   see        Attr, Tag
	def Text()
		return StzEngineHtmlTextOfTag(@oDoc._EngineHandle(), @cTag, @nOcc)

	# Returns the value of one attribute of the element; the empty text when it is absent.
	#
	#   cName      the attribute name, such as href
	#   returns    a text
	#   note       an attribute present with an empty value looks absent
	#   see        HasAttr, Id, Klass
	def Attr(cName)
		return StzEngineHtmlAttrOfTag(@oDoc._EngineHandle(), @cTag, @nOcc, cName)

		def Attribute(cName)
			return This.Attr(cName)

	# Returns TRUE if the element has the attribute with a value that is not empty.
	#
	#   cName      the attribute name
	#   returns    TRUE or FALSE
	#   note       it is the test of Attr(name) against the empty text
	#   see        Attr
	def HasAttr(cName)
		return This.Attr(cName) != ""

	# Returns the id attribute of the element; the empty text when there is none.
	#
	#   returns    a text
	#   see        Attr, Klass
	def Id()
		return This.Attr("id")

	# Returns the whole class attribute as one text; the empty text when there is none.
	#
	#   returns    a text
	#   note       the classes box and big come as one text: box big
	#   see        HasKlass, Id
	def Klass()
		return This.Attr("class")

		def Class_()
			return This.Klass()

	# Returns TRUE if one of the words of the class attribute equals the class.
	#
	#   pcClass    the class name to look for
	#   returns    TRUE or FALSE
	#   note       box big has box and big but not bo
	#   see        Klass
	def HasKlass(pcClass)
		_cAll_ = This.Klass()
		if _cAll_ = "" return 0 ok
		_aParts_ = @split(_cAll_, " ")
		_nL_ = len(_aParts_)
		for _i_ = 1 to _nL_
			if @trim(_aParts_[_i_]) = pcClass return 1 ok
		next
		return 0

		def HasClass(pcClass)
			return This.HasKlass(pcClass)

# ── stzHtmlBuilder -- programmatic HTML construction ─────────
# A pure-Ring builder (the parser engine is read-only -- no DOM
# mutation bridges), building a tree of stzHtmlBuildNode and
# serialising to an HTML string.
#
# WHERE THE DOCUMENT LIVES. Ring has no references: an object assigned, passed or
# returned is copied. The builder therefore never holds a node object that it later
# expects to change in place. The document is kept as parallel lists inside the builder
# (tag, text, attributes, parent, children of every node; node 1 is the root container),
# and the current node is a plain node NUMBER, which a copy of the builder carries along
# with the rest. Nodes are rebuilt from those lists when asked for (Root, Current, Build).

# Assembles an HTML document from nodes added under a current position, and gives the text or writes it to a file.
#
# Reach for it to build a page piece by piece: AppendToCurrent adds a node under the current
# node, GoToLastChild or SetCurrent moves inside the node just added, GoUp comes back out, and
# Build gives the HTML text. The document lives in the builder itself, not in node objects, so
# chaining works: each method returns the builder itself. A node handed to AppendToCurrent is
# copied at that moment, so changes made to the original afterwards are not seen. The position is
# a number, readable as a path of child numbers with CurrentPath. Text and attribute values are
# escaped when the document is written; SetMarkup on a node is the one door that writes as given.
#
#   receiver   o1 = new stzHtmlBuilder() d1 = o1.CreateNode("div") p1 = o1.CreateNode("p")
#              p1.SetText("x") o1.AppendToCurrent(d1).GoToLastChild().AppendToCurrent(p1)
#   example    ? o1.Build()
#              #--> <div><p>x</p></div>
#              ? @@( o1.CurrentPath() )
#              #--> [ 1 ]
#   see        stzHtmlBuildNode, stzHtml
class stzHtmlBuilder from stzObject

	@aTags   = [ "" ]    # tag of every node; node 1 is the tag-less root container
	@aTexts  = [ "" ]    # text of every node
	@aMarkup = [ 0 ]     # 1 where a node's text is markup, written as given
	@aAttrs  = [ [] ]    # attributes of every node, a list of [name, value]
	@aParent = [ 0 ]     # number of the parent of every node, 0 for the root
	@aKids   = [ [] ]    # numbers of the children of every node, in order
	@nCur    = 1         # number of the node new children are added to

	# Starts an empty document: a tag-less root container that is also the current node.
	#
	#   returns    nothing; the object is built
	#   see        Build, CreateNode
	def init()
		@aTags   = [ "" ]
		@aTexts  = [ "" ]
		@aMarkup = [ 0 ]
		@aAttrs  = [ [] ]
		@aParent = [ 0 ]
		@aKids   = [ [] ]
		@nCur    = 1

	# Returns a new detached node with the tag; it is not part of the document until it is appended.
	#
	#   pcTag      the tag name, such as ul
	#   returns    a stzHtmlBuildNode
	#   note       the node is a separate object: changes made to it after it was appended are not
	#              seen in the document
	#   see        AppendToCurrent, Current
	#@ aka  Detached node; attach it later via AppendToCurrent[Q].
	def CreateNode(pcTag)
		return new stzHtmlBuildNode(pcTag)

		def Node(pcTag)
			return This.CreateNode(pcTag)

	# Adds a copy of a node, with all its descendants, as the last child of the current node.
	#
	#   poNode     the stzHtmlBuildNode to add; it may already have children, and the same node may be
	#              added again, which adds another copy
	#   returns    the builder itself, so that calls can be chained
	#   note       the current node does not move: call GoToLastChild to go inside the node just added;
	#              changes made to the original node after the call are not seen in the document
	#   see        CreateNode, GoToLastChild, SetCurrent, Build
	def AppendToCurrent(poNode)
		if NOT isObject(poNode)
			StzRaise("Incorrect param type! poNode must be a stzHtmlBuildNode.")
		ok
		if NOT ring_classname(poNode) = "stzhtmlbuildnode"
			StzRaise("Incorrect param type! poNode must be a stzHtmlBuildNode.")
		ok
		This._AddNode(poNode, @nCur)
		return self

		# Chainable form (returns self so .AppendToCurrentQ(a).AppendToCurrentQ(b))
		def AppendToCurrentQ(poNode)
			This.AppendToCurrent(poNode)
			return self

	# Moves the current position to a node of the document, given as the node itself or as a path.
	#
	#   pNodeOrPath    a stzHtmlBuildNode equal to one already in the document, or a path as a list of
	#                  child numbers counted from the root, such as [ 2, 1 ]; the empty list is the root
	#   returns        the builder itself
	#   note           a node is found by what it contains (tag, text, attributes and descendants), not
	#                  by identity, because Ring copies objects: of two equal nodes the one added last
	#                  wins, and Root() gives the root; a node that is not in the document raises an error
	#   see            CurrentPath, GoToLastChild, AppendToCurrent
	def SetCurrent(pNodeOrPath)
		if isList(pNodeOrPath)
			return This.SetCurrentPath(pNodeOrPath)
		ok
		if NOT isObject(pNodeOrPath)
			StzRaise("Incorrect param type! pNodeOrPath must be a stzHtmlBuildNode or a path list.")
		ok
		_nId_ = This._FindNodeLike(pNodeOrPath)
		if _nId_ = 0
			StzRaise("Can't proceed! The node is not in the document: add it before making it current.")
		ok
		@nCur = _nId_
		return self

		def SetCurrentQ(pNodeOrPath)
			This.SetCurrent(pNodeOrPath)
			return self

	# Moves the current position to the node at a path of child numbers counted from the root.
	#
	#   paPath     a list of child numbers, one per level, such as [ 2, 1 ] for the first child of the
	#              second child of the root; the empty list means the root
	#   returns    the builder itself
	#   note       a number that is not a child position of its level raises an error and leaves the
	#              position where it was
	#   see        CurrentPath, SetCurrent
	def SetCurrentPath(paPath)
		if NOT isList(paPath)
			StzRaise("Incorrect param type! paPath must be a list of child numbers.")
		ok
		_nId_ = 1
		_nP_ = ring_len(paPath)
		for _i_ = 1 to _nP_
			_nK_ = paPath[_i_]
			if NOT isNumber(_nK_)
				StzRaise("Incorrect param type! paPath must hold only numbers.")
			ok
			if _nK_ < 1 or _nK_ > ring_len(@aKids[_nId_]) or _nK_ != floor(_nK_)
				StzRaise("Can't proceed! The path leaves the document at step " + _i_ + ".")
			ok
			_nId_ = @aKids[_nId_][_nK_]
		next
		@nCur = _nId_
		return self

	# Returns where the current node lies, as the child numbers to follow from the root.
	#
	#   returns    a list of numbers, empty when the current node is the root
	#   see        SetCurrentPath, GoUp
	def CurrentPath()
		_aRev_ = []
		_nId_ = @nCur
		while _nId_ != 1
			_nPar_ = @aParent[_nId_]
			_aRev_ + ring_find(@aKids[_nPar_], _nId_)
			_nId_ = _nPar_
		end
		_aPath_ = []
		_nR_ = ring_len(_aRev_)
		for _i_ = _nR_ to 1 step -1
			_aPath_ + _aRev_[_i_]
		next
		return _aPath_

	# Makes the last child of the current node the current one, to build inside the node just added.
	#
	#   returns    the builder itself
	#   note       a current node without children raises an error and the position stays
	#   see        GoUp, AppendToCurrent
	def GoToLastChild()
		_nK_ = ring_len(@aKids[@nCur])
		if _nK_ = 0
			StzRaise("Can't proceed! The current node has no child to go to.")
		ok
		@nCur = @aKids[@nCur][_nK_]
		return self

	# Makes the parent of the current node the current one; at the root it stays where it is.
	#
	#   returns    the builder itself
	#   note       at the root nothing is raised, as with a path that cannot go higher
	#   see        GoToLastChild, GoToRoot
	def GoUp()
		if @nCur != 1
			@nCur = @aParent[@nCur]
		ok
		return self

	# Makes the root the current node, so that the next node is added at the top of the document.
	#
	#   returns    the builder itself
	#   see        GoUp, Root
	def GoToRoot()
		@nCur = 1
		return self

	# Returns a copy of the node that new children are added to, with everything below it.
	#
	#   returns    a stzHtmlBuildNode
	#   note       it is a snapshot: a change made to it does not reach the builder
	#   see        SetCurrent, Root
	def Current()
		return This._NodeOf(@nCur)

	# Returns a copy of the tag-less root container of the document, with everything below it.
	#
	#   returns    a stzHtmlBuildNode
	#   note       it is a snapshot taken at the call: a change made to it does not reach the builder
	#   see        Current, Build
	def Root()
		return This._NodeOf(1)

	# Returns how many nodes the document holds, the root container not counted.
	#
	#   returns    a number
	#   note       a node added with children counts for itself and each descendant
	#   see        Root, AppendToCurrent
	def NodeCount()
		return ring_len(@aTags) - 1

	# Returns the HTML text of the document: the children of the root, one after the other.
	#
	#   returns    a text, empty when nothing was added
	#   note       it is the text the node class gives with ToHtml: text escaped, markup as given
	#   see        BuildToFile, Root
	#@ aka  Serialise the whole document to an HTML string.
	def Build()
		return This._NodeOf(1).ChildrenHtml()

		def ToHtml()
			return This.Build()

	# Writes the HTML text of the document to a file, exactly the bytes the text holds.
	#
	#   pcPath     the file to write, which is replaced if it exists
	#   returns    the builder itself
	#   note       nothing is added to the text: no byte order mark, and a line break is written as the
	#              text holds it; a path that cannot be written raises an error
	#   see        Build
	def BuildToFile(pcPath)
		if NOT isString(pcPath)
			StzRaise("Incorrect param type! pcPath must be a string.")
		ok
		if pcPath = ""
			StzRaise("Incorrect param value! pcPath must not be empty.")
		ok
		ring_write(pcPath, This.Build())
		if NOT fexists(pcPath)
			StzRaise("Can't proceed! The file could not be written: " + pcPath)
		ok
		return self

	# Copies a node and its descendants into the lists of the document and returns its number.
	#
	#   poNode     the stzHtmlBuildNode to copy in
	#   pnParent   the number of the node that becomes its parent
	#   returns    the number given to the node
	#   see        AppendToCurrent
	def _AddNode(poNode, pnParent)
		_nId_ = ring_len(@aTags) + 1
		@aTags + poNode.Tag()
		@aTexts + poNode.Text()
		@aMarkup + poNode.IsMarkup()
		@aAttrs + poNode.Attrs()
		@aParent + pnParent
		@aKids + []
		@aKids[pnParent] + _nId_
		_aSub_ = poNode.Children()
		_nS_ = ring_len(_aSub_)
		for _i_ = 1 to _nS_
			This._AddNode(_aSub_[_i_], _nId_)
		next
		return _nId_

	# Builds a stzHtmlBuildNode tree from the lists of the document, for one node and all below it.
	#
	#   pnId       the number of the node to rebuild, 1 for the whole document
	#   returns    a stzHtmlBuildNode
	#   note       it works from the last descendant up, so that each node is complete when its parent takes it
	#   see        Root, Current, Build
	def _NodeOf(pnId)
		_aOrder_ = [ pnId ]
		_nO_ = 1
		while _nO_ <= ring_len(_aOrder_)
			_aK_ = @aKids[_aOrder_[_nO_]]
			_nK_ = ring_len(_aK_)
			for _i_ = 1 to _nK_
				_aOrder_ + _aK_[_i_]
			next
			_nO_ += 1
		end
		_aBuilt_ = list(ring_len(@aTags))
		_nTop_ = ring_len(_aOrder_)
		for _j_ = _nTop_ to 1 step -1
			_nId_ = _aOrder_[_j_]
			_oN_ = new stzHtmlBuildNode(@aTags[_nId_])
			if @aMarkup[_nId_] = 1
				_oN_.SetMarkup(@aTexts[_nId_])
			else
				_oN_.SetText(@aTexts[_nId_])
			ok
			_nA_ = ring_len(@aAttrs[_nId_])
			for _i_ = 1 to _nA_
				_oN_.SetAttr(@aAttrs[_nId_][_i_][1], @aAttrs[_nId_][_i_][2])
			next
			_nK_ = ring_len(@aKids[_nId_])
			for _i_ = 1 to _nK_
				_oN_.AppendChild(_aBuilt_[ @aKids[_nId_][_i_] ])
				_aBuilt_[ @aKids[_nId_][_i_] ] = 0
			next
			_aBuilt_[_nId_] = _oN_
		next
		return _aBuilt_[pnId]

	# Finds the number of the node of the document that equals a given node, the last added first.
	#
	#   poNode     the stzHtmlBuildNode to look for, compared by tag, text and written form
	#   returns    a node number, 1 for the root, or 0 when no node equals it
	#   see        SetCurrent
	def _FindNodeLike(poNode)
		_cTag_  = poNode.Tag()
		_cText_ = poNode.Text()
		_cHtml_ = poNode.ToHtml()
		if strcmp(_cTag_, "") = 0
			if strcmp(_cHtml_, This.Build()) = 0
				return 1
			ok
		ok
		_nT_ = ring_len(@aTags)
		for _i_ = _nT_ to 2 step -1
			if strcmp(@aTags[_i_], _cTag_) = 0
				if strcmp(@aTexts[_i_], _cText_) = 0
					if strcmp(This._NodeOf(_i_).ToHtml(), _cHtml_) = 0
						return _i_
					ok
				ok
			ok
		next
		return 0

# ── stzHtmlBuildNode -- a node in a builder tree ────────────

# Holds one element of an HTML tree to be written out: a tag, a text, attributes and child nodes.
#
# Reach for it to produce HTML without pasting strings: create a node, SetText, SetAttr and
# AppendChild, then call ToHtml on the top node. A node whose tag is the empty text is a container
# that writes only its children. Texts and attribute values are written as given, with no escaping,
# and a child is stored as a copy, so build each child fully before appending it.
#
#   receiver   o1 = new stzHtmlBuildNode("ul") li = new stzHtmlBuildNode("li") li.SetText("one")
#              li.SetAttr("class", "x") o1.AppendChild(li)
#   example    ? o1.ToHtml()
#              #--> <ul><li class="x">one</li></ul>
#              ? len(o1.Children())
#              #--> 1
#   see        stzHtmlBuilder, stzXmlBuilder
class stzHtmlBuildNode from stzObject

	@cTag      = ""
	@cText     = ""
	@aChildren = []
	@aAttrs    = []   # list of [name, value]
	@bMarkup   = 0    # 1 when the text is markup, written as given

	# Builds a node with a tag, no text, no attribute and no child; the empty tag makes a container written without a tag of its own.
	#
	#   pcTag      the tag name, or the empty text for a container
	#   returns    nothing; the object is built
	#   see        Tag, ToHtml
	def init(pcTag)
		@cTag      = pcTag
		@cText     = ""
		@aChildren = []
		@aAttrs    = []
		@bMarkup   = 0

	# Returns the tag name as it was given.
	#
	#   returns    a text
	#   see        ToHtml
	def Tag()
		return @cTag

	# Sets the text written inside the node before its children and returns the node.
	#
	#   pcText     the text; it is escaped when the node is written, so a < reads as a <
	#   returns    the node itself
	#   note       text is the default and markup the exception: a caller holding markup
	#              says so with SetMarkup, the one door that writes as given
	#   see        Text, SetMarkup, ToHtml
	def SetText(pcText)
		@cText = pcText
		@bMarkup = 0
		return self

		def SetTextQ(pcText)
			return This.SetText(pcText)

	# Sets markup written inside the node as given, before its children, and returns the node.
	#
	#   pcHtml     the markup, written as given: nothing in it is escaped
	#   returns    the node itself
	#   warning    this is the one door for markup, so every call to it is counted by the
	#              raw-markup-door code rule; untrusted text goes through SetText
	#   see        SetText, IsMarkup, ToHtml
	def SetMarkup(pcHtml)
		@cText = "" + pcHtml
		@bMarkup = 1
		return self

		def SetMarkupQ(pcHtml)
			return This.SetMarkup(pcHtml)

	# Returns 1 when the node's text was given as markup, 0 when it is text.
	#
	#   returns    a number, 1 or 0
	#   see        SetMarkup, SetText
	def IsMarkup()
		return @bMarkup

	# Returns the text of the node, not counting its children.
	#
	#   returns    a text
	#   see        SetText, ToHtml
	def Text()
		return @cText

	# Adds an attribute and returns the node.
	#
	#   pcName     the attribute name: a letter or underscore, then letters, digits, - _ : or .
	#   pcValue    the value, escaped when the node is written between double quotes
	#   returns    the node itself
	#   note       setting a name twice writes it twice; a URL-valued attribute goes through
	#              SetUrlAttr, which refuses a script scheme
	#   warning    a name that is not an attribute name raises an error: there is no raw door
	#              for a name, and no escaping that would make one safe
	#   see        SetUrlAttr, AppendChild, ToHtml
	def SetAttr(pcName, pcValue)
		if NOT _StzHtmlIsAttrName(pcName)
			StzRaise("stzHtmlBuildNode.SetAttr: refused -- an attribute name is a letter or " +
				"underscore, then letters, digits, '-', '_', ':' or '.'. Got '" +
				("" + pcName) + "'.")
		ok
		@aAttrs + [ pcName, "" + pcValue ]
		return self

		def SetAttrQ(pcName, pcValue)
			return This.SetAttr(pcName, pcValue)

	# Adds an attribute whose value is a URL, refusing a script scheme, and returns the node.
	#
	#   pcName     the attribute name, such as href or src
	#   pcUrl      the URL; javascript:, vbscript: and data: are refused whatever their case
	#              or the control characters hidden inside them
	#   returns    the node itself
	#   warning    escaping cannot make a script scheme safe, so the value is refused with an
	#              error rather than written; a relative or an http(s) URL passes
	#   see        SetAttr, ToHtml
	def SetUrlAttr(pcName, pcUrl)
		if _StzHtmlUrlIsRefused(pcUrl)
			StzRaise("stzHtmlBuildNode.SetUrlAttr: refused -- a URL attribute does not take " +
				"a javascript:, vbscript: or data: value. Got '" + ("" + pcUrl) + "'.")
		ok
		return This.SetAttr(pcName, pcUrl)

		def SetUrlAttrQ(pcName, pcUrl)
			return This.SetUrlAttr(pcName, pcUrl)

	# Returns the attributes of the node as a list of [ name, value ] pairs, in the order they were set.
	#
	#   returns    a list, empty when no attribute was set
	#   note       it is a copy: a change made to it does not reach the node
	#   see        SetAttr, ToHtml
	def Attrs()
		return @aAttrs

	# Adds a node as the last child and returns the node.
	#
	#   poNode     the node to add
	#   returns    the node itself
	#   note       the child is stored as a copy, so changes made to the original afterwards do not
	#              appear in the output
	#   see        Children, ToHtml
	def AppendChild(poNode)
		@aChildren + poNode
		return self

		def Append(poNode)
			return This.AppendChild(poNode)

	# Returns the list of child nodes, in the order they were added.
	#
	#   returns    a list of stzHtmlBuildNode
	#   see        AppendChild, ChildrenHtml
	def Children()
		return @aChildren

	# Returns the node as HTML: opening tag with attributes, the text, the children, then the closing tag.
	#
	#   returns    a text
	#   note       a node with the empty tag gives only its children; a node without text or
	#              children gives an empty element such as <p></p>
	#   see        ChildrenHtml, AppendChild
	#@ aka  Serialise this node (tag, attrs, text then children) to HTML.
	def ToHtml()
		if @cTag = ""
			return This.ChildrenHtml()
		ok
		_cAttrs_ = ""
		_nA_ = len(@aAttrs)
		for _i_ = 1 to _nA_
			_cAttrs_ += " " + @aAttrs[_i_][1] + '="' + StzHtmlAttrEscaped(@aAttrs[_i_][2]) + '"'
		next
		_cInner_ = @cText
		if @bMarkup = 0
			_cInner_ = StzHtmlEscaped(@cText)
		ok
		return "<" + @cTag + _cAttrs_ + ">" + _cInner_ + This.ChildrenHtml() + "</" + @cTag + ">"

	# Returns the HTML of the children only, one after the other, without the tag of this node.
	#
	#   returns    a text
	#   see        ToHtml, Children
	def ChildrenHtml()
		_c_ = ""
		_n_ = len(@aChildren)
		for _i_ = 1 to _n_
			_c_ += @aChildren[_i_].ToHtml()
		next
		return _c_
