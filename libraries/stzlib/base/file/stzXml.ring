#--------------------------------------------------------------#
#          SOFTANZA LIBRARY (V0.9) - STZXML                    #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#
# XML as an OBJECT you hold -- the sibling of stzHtml, which is the same kind of
# thing: a navigable tree, so it gets the same shape (a document, a node, and a
# builder) rather than the flat-function shape stzJson and stzCSV use.
#
#     oXml = new stzXml(cText)
#     oXml.Root()                          # "library"
#     oXml.Text("library/book/title")      # "Dune"
#     oXml.NumberOf("library/book")        # 2
#     oXml.NodeQ("library/book[2]").Text("title")
#
# A DOCUMENT, not a file: an XML file is a *source*, not a different kind of
# thing, so there is no stzXmlFile -- read the text and hand it over, exactly as
# stzHtml, stzJson and stzCSV work. FromFile() exists as a convenience.
#
# The parsing is the ENGINE's (engine/src/xml.zig), shared with the XML-signature
# code -- so the strictness is the same in both places: a document carrying a
# DOCTYPE or an ENTITY declaration is REFUSED, closing XXE by construction. See
# stzXmlFuncs for the path language and the deliberate limits.

func StzXmlQ(pcText)
	return new stzXml(pcText)

func StzXmlFromFileQ(pcPath)
	return new stzXml( read("" + pcPath) )

func StzXmlBuilderQ(pcRootName)
	return new stzXmlBuilder(pcRootName)


  #=========================================================#
 #  STZXML -- the document                                   #
#=========================================================#

# Holds an XML document as text and reads it by path, with the parsing done by the engine.
#
# Reach for it to read values out of an XML document without walking a tree: TextAt, NumberAt and
# AttributeAt take a path such as library/book[2]/title (names joined by /, an optional [n] index
# counted from 1, no namespace prefix). NodeQ returns a node that remembers a path, so reads can go
# deeper step by step. The object keeps only the text and parses it again at each read. A document
# with a DOCTYPE or an ENTITY declaration is refused on purpose, which closes XXE: IsValid answers 0
# and every read answers the empty text. To build XML rather than read it, use stzXmlBuilder; its
# values are escaped.
#
#   receiver   o1 = new stzXml('<library><book
#              id="b1"><title>Dune</title><price>12</price></book><book
#              id="b2"><title>Emma</title><price>8</price></book></library>')
#   example    ? o1.Root()
#              #--> library
#              ? o1.NumberOf("library/book")
#              #--> 2
#              ? o1.TextAt("library/book[2]/title")
#              #--> Emma
#              ? o1.AttributeAt("library/book[2]", "id")
#              #--> b2
#              ? o1.NodeQ("library/book[1]").NumberOf("price")
#              #--> 1
#   see        stzXmlBuilder, stzXmlNode, stzHtml
class stzXml from stzObject

	@cText = ""

	# Builds a document object from XML text; the text is kept as given and parsed again at every read.
	#
	#   pcText     the XML document as text
	#   returns    nothing; the object is built
	#   note       text that is not XML is accepted too: the object is built and IsValid answers 0
	#   see        IsValid, Content, StzXmlQ
	def init(pcText)
		@cText = "" + pcText

	# Returns the XML text the object was built from, unchanged.
	#
	#   returns    a text
	#   see        Pretty, Size
	#@ aka  -- what it is ------------------------------------------------------
	def Content()
		return @cText

	# Returns the XML text the object was built from, unchanged.
	#
	#   returns    a text
	#   note       it is the same text as Content, not the text inside the elements; use TextAt for
	#              that
	#   see        Content, Pretty
	def Text()
		return @cText

	# Returns TRUE if the engine accepts the text as one well-formed XML document.
	#
	#   returns    TRUE or FALSE
	#   note       a document with a DOCTYPE or an ENTITY declaration is refused on purpose (it
	#              closes XXE), so it answers FALSE, as does an unclosed tag or plain text
	#   see        Root, Pretty
	def IsValid()
		return StzXmlIsValid(@cText)

	# Returns the name of the root element, or the empty text when the document is not valid.
	#
	#   returns    a text
	#   see        RootQ, IsValid
	def Root()
		return StzXmlRoot(@cText)

	def RootQ()
		return This.NodeQ( This.Root() )

	# Returns the length of the XML text in bytes.
	#
	#   returns    a number
	#   see        Content
	def Size()
		return len(@cText)

	# Returns the text of the element at a path; the empty text when there is no such element or it holds only child elements.
	#
	#   pcPath     a path of element names joined by /, with an optional [n] index counted from 1,
	#              such as library/book[2]/title
	#   returns    a text
	#   note       without an index the first match is read; a namespace prefix is not written in a
	#              path (use note, not ns:note); &amp; is read back as &
	#   see        NumberAt, TextsAt, AttributeAt
	#@ aka  -- reading ---------------------------------------------------------
	def TextAt(pcPath)
		return StzXmlGet(@cText, pcPath)

	# Returns the text of the element at a path read as a number; 0 when there is no element or it is empty.
	#
	#   pcPath     a path, as for TextAt
	#   returns    a number
	#   note       text that is not a number raises the error Invalid numeric string
	#   see        TextAt, NumberOf
	def NumberAt(pcPath)
		return StzXmlGetInt(@cText, pcPath)

	# Returns the value of one attribute of the element at a path; the empty text when it is absent.
	#
	#   pcPath     a path, as for TextAt
	#   pcName     the attribute name
	#   returns    a text
	#   note       library/book reads the first book, library/book[2] the second
	#   see        TextAt, NamespaceAt
	def AttributeAt(pcPath, pcName)
		return StzXmlAttr(@cText, pcPath, pcName)

	# Returns the namespace URI that applies to the element at a path; the empty text when there is none.
	#
	#   pcPath     a path, as for TextAt
	#   returns    a text
	#   note       a path is written without the prefix: library/note finds an element written
	#              ns:note and answers its URI
	#   see        AttributeAt, TextAt
	def NamespaceAt(pcPath)
		return StzXmlNamespace(@cText, pcPath)

	# Returns how many elements match a path.
	#
	#   pcPath     a path, as for TextAt
	#   returns    a number; 0 when none
	#   note       library/book counts the books under library; library/book/title counts only the
	#              titles of the first book
	#   see        Has, TextsAt, NodesQ
	def NumberOf(pcPath)
		return StzXmlCount(@cText, pcPath)

	# Returns TRUE if at least one element matches the path.
	#
	#   pcPath     a path, as for TextAt
	#   returns    TRUE or FALSE
	#   see        NumberOf, NodeQ
	def Has(pcPath)
		return StzXmlHas(@cText, pcPath)

	# Returns the names of the child elements of the element at a path, in document order, repeats included.
	#
	#   pcPath     a path, as for TextAt
	#   returns    a list of texts; empty when there is none
	#   note       library with two books and a note gives ["book","book","note"]; a prefix is
	#              dropped from the names
	#   see        NodesQ, NumberOf
	def ChildrenOf(pcPath)
		return StzXmlChildren(@cText, pcPath)

	# Returns the text of each element matching a path, as a list.
	#
	#   pcPath     the path of a repeated element, without an index
	#   returns    a list of texts
	#   note       it indexes the LAST step, so library/book/title gives only the first book's
	#              title; to read all titles walk NodesQ("library/book"); a path with [n] gives one
	#              item; elements that hold only children give empty texts
	#   see        TextAt, NumberOf
	#@ aka  every text value of a repeated element -> a list.
	def TextsAt(pcPath)
		_out_ = []
		_n_ = This.NumberOf(pcPath)
		for _i_ = 1 to _n_
			_out_ + This.TextAt( This._Indexed(pcPath, _i_) )
		next
		return _out_

	# Returns a node object for the element at a path, to read it and its descendants with shorter paths.
	#
	#   pcPath     a path, as for TextAt
	#   returns    a stzXmlNode
	#   note       the node only remembers the document and the path, so it is also built for a path
	#              that matches nothing (Exists answers 0)
	#   see        NodesQ, RootQ
	#@ aka  -- navigating (a node is a PATH into this document) -----------------
	def NodeQ(pcPath)
		return new stzXmlNode(@cText, pcPath)

	# Returns one node object for each element matching a path, in document order.
	#
	#   pcPath     the path of a repeated element, without an index
	#   returns    a list of stzXmlNode; empty when none
	#   note       library/book gives nodes with paths library/book[1] and library/book[2]
	#   see        NodeQ, NumberOf
	def NodesQ(pcPath)
		_out_ = []
		_n_ = This.NumberOf(pcPath)
		for _i_ = 1 to _n_
			_out_ + new stzXmlNode(@cText, This._Indexed(pcPath, _i_))
		next
		return _out_

	# Returns the document laid out with two spaces of indent per level and one element per line.
	#
	#   returns    a text; empty when the document is not valid
	#   note       it ends with a line break; text and attributes are kept, and &amp; stays escaped
	#   see        PrettyQ, Show
	#@ aka  -- presenting ------------------------------------------------------
	def Pretty()
		return StzXmlPretty(@cText)

	def PrettyQ()
		return new stzXml( This.Pretty() )

	# Writes the XML text, as given, to a file and returns the object.
	#
	#   pcPath     the file to write, which is replaced if it exists
	#   returns    the object itself
	#   note       it writes the original text, not the pretty form; the folder must exist
	#   see        Content, Pretty
	def SaveTo(pcPath)
		write("" + pcPath, @cText)
		return This

	# Prints the document, laid out as Pretty does, to the console.
	#
	#   returns    nothing
	#   see        Pretty
	def Show()
		? This.Pretty()

	# Returns the XML text as a stzString object, to use the string methods on it.
	#
	#   returns    a stzString
	#   see        Content
	def ToStzString()
		return new stzString(@cText)

	  #-- internals -------------------------------------------------------

	# turn "a/b" into "a/b[i]" -- and leave an already-indexed path alone.
	def _Indexed(pcPath, pnIndex)
		_p_ = "" + pcPath
		if StzFindFirst("[", _p_) > 0
			return _p_
		ok
		return _p_ + "[" + pnIndex + "]"


  #=========================================================#
 #  STZXMLNODE -- one element, addressed by its path         #
#=========================================================#
#
# A node holds the document plus the PATH that reaches it, so it stays valid
# without any pointer into engine memory -- and a nested read is just a longer
# path. That is what makes NodeQ() chainable with nothing to invalidate.

# Points at one element of an XML document by its path, and reads the element and its descendants.
#
# A node holds the document text and the path that reaches the element, nothing else, so it stays
# valid and can be chained: NodeQ(...) on a node adds to its path. It is normally made by
# stzXml.NodeQ or NodesQ. Reads that find nothing answer the empty text or 0, and Exists tells
# whether the element is really there. Number raises an error on text that is not a number.
#
#   receiver   d1 = new stzXml('<library><book
#              id="b1"><title>Dune</title><price>12</price></book></library>') o1 =
#              d1.NodeQ("library/book")
#   example    ? o1.Path()
#              #--> library/book
#              ? o1.Attribute("id")
#              #--> b1
#              ? o1.TextAt("title")
#              #--> Dune
#              ? o1.NodeQ("price").Number()
#              #--> 12
#   see        stzXml
class stzXmlNode from stzObject

	@cText = ""
	@cPath = ""

	# Builds a node object bound to a document text and a path; nothing is checked at once.
	#
	#   pcText     the XML document as text
	#   pcPath     the path of the element, such as library/book[2]
	#   returns    nothing; the object is built
	#   note       normally made by NodeQ or NodesQ of stzXml rather than by hand
	#   see        Path, Exists, NodeQ
	def init(pcText, pcPath)
		@cText = "" + pcText
		@cPath = "" + pcPath

	# Returns the path this node was made with.
	#
	#   returns    a text
	#   see        Name, Exists
	def Path()
		return @cPath

	# Returns TRUE if an element exists at the node path.
	#
	#   returns    TRUE or FALSE
	#   see        Name, Text
	def Exists()
		return StzXmlHas(@cText, @cPath)

	# Returns the element name, which is the last step of the path without its [n] index.
	#
	#   returns    a text
	#   note       it comes from the path alone, so a path matching nothing still has a name
	#   see        Path
	def Name()
		_a_ = StzSplit(@cPath, "/")
		if len(_a_) = 0
			return ""
		ok
		_last_ = _a_[len(_a_)]
		_b_ = StzFindFirst("[", _last_)
		if _b_ > 0
			return StzLeft(_last_, _b_ - 1)
		ok
		return _last_

	# Returns the text of the element; the empty text when there is none or it holds only child elements.
	#
	#   returns    a text
	#   note       &amp; is read back as &
	#   see        Number, TextAt
	def Text()
		return StzXmlGet(@cText, @cPath)

	# Returns the text of the element read as a number; 0 when it is empty or absent.
	#
	#   returns    a number
	#   note       text that is not a number raises the error Invalid numeric string
	#   see        Text
	def Number()
		return StzXmlGetInt(@cText, @cPath)

	# Returns the namespace URI that applies to the element; the empty text when there is none.
	#
	#   returns    a text
	#   see        Attribute, Text
	def Namespace()
		return StzXmlNamespace(@cText, @cPath)

	# Returns the value of one attribute of the element; the empty text when it is absent.
	#
	#   pcName     the attribute name
	#   returns    a text
	#   see        AttributeAt, Text
	def Attribute(pcName)
		return StzXmlAttr(@cText, @cPath, pcName)

	# Returns the names of the child elements, in document order, repeats included.
	#
	#   returns    a list of texts
	#   see        NodesQ, NumberOf
	def ChildNames()
		return StzXmlChildren(@cText, @cPath)

	# Returns the text of a descendant, found by a path read from this node.
	#
	#   pcRelative   the path below this node, such as title or author/name
	#   returns      a text; empty when there is none
	#   note         the relative path is added to the node path with a /, so it works for any depth
	#   see          Text, AttributeAt
	#@ aka  read a descendant relative to THIS node.
	def TextAt(pcRelative)
		return StzXmlGet(@cText, @cPath + "/" + pcRelative)

	# Returns the value of an attribute of a descendant, found by a path read from this node.
	#
	#   pcRelative   the path below this node
	#   pcName       the attribute name
	#   returns      a text; empty when absent
	#   see          Attribute, TextAt
	def AttributeAt(pcRelative, pcName)
		return StzXmlAttr(@cText, @cPath + "/" + pcRelative, pcName)

	# Returns how many descendants match a path read from this node.
	#
	#   pcRelative   the path below this node
	#   returns      a number
	#   see          NodesQ, ChildNames
	def NumberOf(pcRelative)
		return StzXmlCount(@cText, @cPath + "/" + pcRelative)

	# Returns a node object for a descendant, so reads can go deeper step by step.
	#
	#   pcRelative   the path below this node
	#   returns      a stzXmlNode
	#   note         it is also built for a path that matches nothing
	#   see          NodesQ, DocumentQ
	def NodeQ(pcRelative)
		return new stzXmlNode(@cText, @cPath + "/" + pcRelative)

	# Returns one node object for each descendant matching a path, in document order.
	#
	#   pcRelative   the path below this node, without an index
	#   returns      a list of stzXmlNode
	#   note         the paths of the nodes get an index: library/book[1]/title[1]
	#   see          NodeQ, NumberOf
	def NodesQ(pcRelative)
		_out_ = []
		_n_ = This.NumberOf(pcRelative)
		for _i_ = 1 to _n_
			_out_ + new stzXmlNode(@cText, @cPath + "/" + pcRelative + "[" + _i_ + "]")
		next
		return _out_

	# Returns a document object for the whole text this node belongs to.
	#
	#   returns    a stzXml
	#   see        NodeQ
	def DocumentQ()
		return new stzXml(@cText)

	# Prints the node path and its text to the console.
	#
	#   returns    nothing
	#   see        Text, Path
	def Show()
		? "stzXmlNode(" + @cPath + ") = " + This.Text()


  #=========================================================#
 #  STZXMLBUILDER -- generating a document                   #
#=========================================================#
#
# Building XML by pasting strings is how injection bugs happen: one unescaped
# value and the shape of the document changes. Every value that goes through this
# builder is escaped, so a "<" in someone's name stays a "<".

# Builds an XML document element by element, escaping every value so a value cannot change the shape of the document.
#
# Reach for it instead of pasting strings: the values given to AddElement and SetAttribute are
# escaped, so & and < stay text. Open and Close nest elements, and Content gives the finished text,
# or raises an error while an element is still open. Element and attribute names are written as
# given and are not checked. The Q forms (AddElementQ, OpenQ, CloseQ) return the builder so calls
# can be chained; the plain forms return nothing.
#
#   receiver   o1 = new stzXmlBuilder("shop")
#   example    o1.AddElement("name", "A & B")
#              o1.Open("items")
#              o1.AddElementXT("item", "pen", [ [ "qty", "2" ] ])
#              o1.Close()
#              ? o1.Content()
#              #--> <shop><name>A &amp; B</name><items><item qty="2">pen</item></items></shop>
#   see        stzXml
class stzXmlBuilder from stzObject

	@cRoot = ""
	@aAttrs = []      # root attributes: [ [ name, value ], ... ]
	@cBody = ""
	@aOpen = []       # the stack of still-open elements

	# Starts a document with the given root element and nothing inside it; an empty name raises an error.
	#
	#   pcRootName   the name of the root element
	#   returns      nothing; the object is built
	#   note         the name is trimmed; the error text is stzXmlBuilder: a root element name is
	#                required.
	#   see          Content, Open
	def init(pcRootName)
		@cRoot = ring_trim("" + pcRootName)
		if @cRoot = ""
			StzRaise("stzXmlBuilder: a root element name is required.")
		ok
		@aAttrs = []
		@aOpen = []
		@cBody = ""

	# Adds an attribute to the root element; the value is escaped.
	#
	#   pcName     the attribute name
	#   pcValue    the attribute value, as text
	#   returns    nothing; the root gains the attribute
	#   note       it always lands on the root, whatever is open; a name used twice gives the
	#              attribute twice
	#   see        AddElement, Content
	def SetAttribute(pcName, pcValue)
		This.SetAttributeQ(pcName, pcValue)

	def SetAttributeQ(pcName, pcValue)
		@aAttrs + [ "" + pcName, "" + pcValue ]
		return This

	# Adds a leaf element with a text inside the element now open; the text is escaped, so & becomes &amp; and < becomes &lt;.
	#
	#   pcName     the element name
	#   pcValue    the text inside
	#   returns    nothing; the document grows
	#   note       the element name itself is written as given, not escaped
	#   see        AddEmptyElement, Open
	#@ aka  a leaf element with text.
	def AddElement(pcName, pcValue)
		This.AddElementQ(pcName, pcValue)

	def AddElementQ(pcName, pcValue)
		@cBody += "<" + pcName + ">" + StzXmlEscape(pcValue) + "</" + pcName + ">"
		return This

	def AddElementXT(pcName, pcValue, paAttrs)
		@cBody += "<" + pcName + This._AttrText(paAttrs) + ">" +
		          StzXmlEscape(pcValue) + "</" + pcName + ">"
		return This

	# Adds an element with no content, written as <name/>, inside the element now open.
	#
	#   pcName     the element name
	#   returns    nothing; the document grows
	#   see        AddElement, Open
	def AddEmptyElement(pcName)
		This.AddEmptyElementQ(pcName)

	def AddEmptyElementQ(pcName)
		@cBody += "<" + pcName + "/>"
		return This

	# Adds an opening tag; every element added until Close goes inside it.
	#
	#   pcName     the element name
	#   returns    nothing; the document grows
	#   note       Content raises an error while an element is still open
	#   see        Close, NumberOfOpenElements
	#@ aka  open a container; every Add... until Close goes inside it.
	def Open(pcName)
		This.OpenQ(pcName)

	def OpenQ(pcName)
		return This.OpenXTQ(pcName, [])

	def OpenXTQ(pcName, paAttrs)
		@cBody += "<" + pcName + This._AttrText(paAttrs) + ">"
		@aOpen + ("" + pcName)
		return This

	# Closes the element opened last.
	#
	#   returns    nothing; the document grows
	#   note       with nothing open it raises the error stzXmlBuilder.Close: nothing is open.
	#   see        Open, NumberOfOpenElements
	def Close()
		This.CloseQ()

	def CloseQ()
		if len(@aOpen) = 0
			StzRaise("stzXmlBuilder.Close: nothing is open.")
		ok
		@cBody += "</" + @aOpen[len(@aOpen)] + ">"
		_aNew_ = []
		_n_ = len(@aOpen)
		for _i_ = 1 to _n_ - 1
			_aNew_ + @aOpen[_i_]
		next
		@aOpen = _aNew_
		return This

	# Returns how many elements are open and not yet closed.
	#
	#   returns    a number
	#   see        Open, Close
	def NumberOfOpenElements()
		return len(@aOpen)

	# Returns the finished document: the root with its attributes and everything added.
	#
	#   returns    a text
	#   note       it raises the error stzXmlBuilder: n element(s) still open -- Close them first.
	#              while an element is open
	#   see        XmlQ, Show
	#@ aka  -- the result ------------------------------------------------------
	def Content()
		if len(@aOpen) > 0
			StzRaise("stzXmlBuilder: " + len(@aOpen) + " element(s) still open -- Close them first.")
		ok
		return "<" + @cRoot + This._AttrText(@aAttrs) + ">" + @cBody + "</" + @cRoot + ">"

	# Returns the finished document as a stzXml object, to be read or pretty-printed.
	#
	#   returns    a stzXml
	#   note       it raises the same error as Content while an element is open
	#   see        Content
	def XmlQ()
		return new stzXml( This.Content() )

	# Prints the finished document to the console on one line.
	#
	#   returns    nothing
	#   note       it raises the same error as Content while an element is open
	#   see        Content
	def Show()
		? This.Content()

	  #-- internals -------------------------------------------------------

	def _AttrText(paAttrs)
		_s_ = ""
		_n_ = len(paAttrs)
		for _i_ = 1 to _n_
			if isList(paAttrs[_i_]) and len(paAttrs[_i_]) >= 2
				_s_ += ' ' + paAttrs[_i_][1] + '="' + StzXmlEscape(paAttrs[_i_][2]) + '"'
			ok
		next
		return _s_
