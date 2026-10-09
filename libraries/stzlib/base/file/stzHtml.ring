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

# Is meant to assemble an HTML document from nodes, but returns an empty text today because appended nodes never reach the root.
#
# The builder holds a root container and a current node. Because Ring copies an object on
# assignment, the current node is a copy of the root and AppendToCurrent adds to the copy, so Build
# and BuildToFile give nothing. Build the tree on stzHtmlBuildNode objects instead and call ToHtml
# on the top node, which works.
#
#   receiver   o1 = new stzHtmlBuilder()
#   example    o1.AppendToCurrent(new stzHtmlBuildNode("p"))
#              ? o1.Build() = ""
#              #--> 1
#   see        stzHtmlBuildNode, stzHtml
class stzHtmlBuilder from stzObject

	@oRoot    = ""   # document fragment (tag-less container)
	@oCurrent = ""   # node new children are appended to

	# Starts an empty document: a tag-less root container that is also the current node.
	#
	#   returns    nothing; the object is built
	#   see        Build, CreateNode
	def init()
		@oRoot    = new stzHtmlBuildNode("")
		@oCurrent = @oRoot

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

	# Adds a node as the last child of the current node and returns the builder.
	#
	#   poNode     the node to add
	#   returns    the builder itself
	#   note       build a tree on a stzHtmlBuildNode and call its ToHtml instead
	#   warning    defect: the current node is a copy of the root made at birth, because Ring copies
	#              an object on assignment, so the node lands in the copy and Build, Root and
	#              BuildToFile still show nothing; checked with two different nodes and after
	#              SetCurrent(Root())
	#   see        CreateNode, SetCurrent, Build
	def AppendToCurrent(poNode)
		@oCurrent.AppendChild(poNode)
		return self

		# Chainable form (returns self so .AppendToCurrentQ(a).AppendToCurrentQ(b))
		def AppendToCurrentQ(poNode)
			This.AppendToCurrent(poNode)
			return self

	# Makes a node the one that AppendToCurrent adds to, and returns the builder.
	#
	#   poNode     the node that becomes current
	#   returns    the builder itself
	#   note       the builder keeps a copy of the node, not the node itself
	#   see        Current, AppendToCurrent
	def SetCurrent(poNode)
		@oCurrent = poNode
		return self

		def SetCurrentQ(poNode)
			This.SetCurrent(poNode)
			return self

	# Returns the node that new children are added to.
	#
	#   returns    a stzHtmlBuildNode
	#   note       it is a copy: a change made to it does not reach the builder
	#   see        SetCurrent, Root
	def Current()
		return @oCurrent

	# Returns the tag-less root container of the document.
	#
	#   returns    a stzHtmlBuildNode
	#   note       because of the copying noted at AppendToCurrent its children stay empty
	#   see        Current, Build
	def Root()
		return @oRoot

	# Returns the HTML text of the document: the children of the root, one after the other.
	#
	#   returns    a text
	#   note       the text of a node tree built apart is available as ToHtml on the node
	#   warning    defect: it answers the empty text after AppendToCurrent, whatever was appended
	#              (see AppendToCurrent)
	#   see        BuildToFile, Root
	#@ aka  Serialise the whole document to an HTML string.
	def Build()
		return @oRoot.ChildrenHtml()

		def ToHtml()
			return This.Build()

	# Writes the HTML text of the document to a file and returns the builder.
	#
	#   pcPath     the file to write, which is replaced if it exists
	#   returns    the builder itself
	#   warning    defect: the file is created empty after AppendToCurrent, for the same reason as
	#              Build
	#   see        Build
	def BuildToFile(pcPath)
		write(pcPath, This.Build())
		return self

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

	# Returns the tag name as it was given.
	#
	#   returns    a text
	#   see        ToHtml
	def Tag()
		return @cTag

	# Sets the text written inside the node before its children and returns the node.
	#
	#   pcText     the text, written as given
	#   returns    the node itself
	#   note       the text is not escaped: a < stays a <, so do not pass untrusted text
	#   see        Text, ToHtml
	def SetText(pcText)
		@cText = pcText
		return self

		def SetTextQ(pcText)
			return This.SetText(pcText)

	# Returns the text of the node, not counting its children.
	#
	#   returns    a text
	#   see        SetText, ToHtml
	def Text()
		return @cText

	# Adds an attribute and returns the node.
	#
	#   pcName     the attribute name
	#   pcValue    the value, written between double quotes
	#   returns    the node itself
	#   note       the value is not escaped, so a double quote inside it breaks the markup; setting
	#              a name twice writes it twice
	#   see        AppendChild, ToHtml
	def SetAttr(pcName, pcValue)
		@aAttrs + [ pcName, pcValue ]
		return self

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
			_cAttrs_ += " " + @aAttrs[_i_][1] + '="' + @aAttrs[_i_][2] + '"'
		next
		return "<" + @cTag + _cAttrs_ + ">" + @cText + This.ChildrenHtml() + "</" + @cTag + ">"

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
