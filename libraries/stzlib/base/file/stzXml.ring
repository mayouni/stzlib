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

class stzXml from stzObject

	@cText = ""

	def init(pcText)
		@cText = "" + pcText

	  #-- what it is ------------------------------------------------------

	def Content()
		return @cText

	def Text()
		return @cText

	def IsValid()
		return StzXmlIsValid(@cText)

	def Root()
		return StzXmlRoot(@cText)

	def RootQ()
		return This.NodeQ( This.Root() )

	def Size()
		return len(@cText)

	  #-- reading ---------------------------------------------------------

	# the text of the element at pcPath ("" when there is none).
	def TextAt(pcPath)
		return StzXmlGet(@cText, pcPath)

	def NumberAt(pcPath)
		return StzXmlGetInt(@cText, pcPath)

	def AttributeAt(pcPath, pcName)
		return StzXmlAttr(@cText, pcPath, pcName)

	def NamespaceAt(pcPath)
		return StzXmlNamespace(@cText, pcPath)

	def NumberOf(pcPath)
		return StzXmlCount(@cText, pcPath)

	def Has(pcPath)
		return StzXmlHas(@cText, pcPath)

	def ChildrenOf(pcPath)
		return StzXmlChildren(@cText, pcPath)

	# every text value of a repeated element -> a list.
	def TextsAt(pcPath)
		_out_ = []
		_n_ = This.NumberOf(pcPath)
		for _i_ = 1 to _n_
			_out_ + This.TextAt( This._Indexed(pcPath, _i_) )
		next
		return _out_

	  #-- navigating (a node is a PATH into this document) -----------------

	def NodeQ(pcPath)
		return new stzXmlNode(@cText, pcPath)

	def NodesQ(pcPath)
		_out_ = []
		_n_ = This.NumberOf(pcPath)
		for _i_ = 1 to _n_
			_out_ + new stzXmlNode(@cText, This._Indexed(pcPath, _i_))
		next
		return _out_

	  #-- presenting ------------------------------------------------------

	def Pretty()
		return StzXmlPretty(@cText)

	def PrettyQ()
		return new stzXml( This.Pretty() )

	def SaveTo(pcPath)
		write("" + pcPath, @cText)
		return This

	def Show()
		? This.Pretty()

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

class stzXmlNode from stzObject

	@cText = ""
	@cPath = ""

	def init(pcText, pcPath)
		@cText = "" + pcText
		@cPath = "" + pcPath

	def Path()
		return @cPath

	def Exists()
		return StzXmlHas(@cText, @cPath)

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

	def Text()
		return StzXmlGet(@cText, @cPath)

	def Number()
		return StzXmlGetInt(@cText, @cPath)

	def Namespace()
		return StzXmlNamespace(@cText, @cPath)

	def Attribute(pcName)
		return StzXmlAttr(@cText, @cPath, pcName)

	def ChildNames()
		return StzXmlChildren(@cText, @cPath)

	# read a descendant relative to THIS node.
	def TextAt(pcRelative)
		return StzXmlGet(@cText, @cPath + "/" + pcRelative)

	def AttributeAt(pcRelative, pcName)
		return StzXmlAttr(@cText, @cPath + "/" + pcRelative, pcName)

	def NumberOf(pcRelative)
		return StzXmlCount(@cText, @cPath + "/" + pcRelative)

	def NodeQ(pcRelative)
		return new stzXmlNode(@cText, @cPath + "/" + pcRelative)

	def NodesQ(pcRelative)
		_out_ = []
		_n_ = This.NumberOf(pcRelative)
		for _i_ = 1 to _n_
			_out_ + new stzXmlNode(@cText, @cPath + "/" + pcRelative + "[" + _i_ + "]")
		next
		return _out_

	def DocumentQ()
		return new stzXml(@cText)

	def Show()
		? "stzXmlNode(" + @cPath + ") = " + This.Text()


  #=========================================================#
 #  STZXMLBUILDER -- generating a document                   #
#=========================================================#
#
# Building XML by pasting strings is how injection bugs happen: one unescaped
# value and the shape of the document changes. Every value that goes through this
# builder is escaped, so a "<" in someone's name stays a "<".

class stzXmlBuilder from stzObject

	@cRoot = ""
	@aAttrs = []      # root attributes: [ [ name, value ], ... ]
	@cBody = ""
	@aOpen = []       # the stack of still-open elements

	def init(pcRootName)
		@cRoot = ring_trim("" + pcRootName)
		if @cRoot = ""
			StzRaise("stzXmlBuilder: a root element name is required.")
		ok
		@aAttrs = []
		@aOpen = []
		@cBody = ""

	def SetAttribute(pcName, pcValue)
		This.SetAttributeQ(pcName, pcValue)

	def SetAttributeQ(pcName, pcValue)
		@aAttrs + [ "" + pcName, "" + pcValue ]
		return This

	# a leaf element with text.
	def AddElement(pcName, pcValue)
		This.AddElementQ(pcName, pcValue)

	def AddElementQ(pcName, pcValue)
		@cBody += "<" + pcName + ">" + StzXmlEscape(pcValue) + "</" + pcName + ">"
		return This

	def AddElementXT(pcName, pcValue, paAttrs)
		@cBody += "<" + pcName + This._AttrText(paAttrs) + ">" +
		          StzXmlEscape(pcValue) + "</" + pcName + ">"
		return This

	def AddEmptyElement(pcName)
		This.AddEmptyElementQ(pcName)

	def AddEmptyElementQ(pcName)
		@cBody += "<" + pcName + "/>"
		return This

	# open a container; every Add... until Close goes inside it.
	def Open(pcName)
		This.OpenQ(pcName)

	def OpenQ(pcName)
		return This.OpenXTQ(pcName, [])

	def OpenXTQ(pcName, paAttrs)
		@cBody += "<" + pcName + This._AttrText(paAttrs) + ">"
		@aOpen + ("" + pcName)
		return This

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

	def NumberOfOpenElements()
		return len(@aOpen)

	  #-- the result ------------------------------------------------------

	def Content()
		if len(@aOpen) > 0
			StzRaise("stzXmlBuilder: " + len(@aOpen) + " element(s) still open -- Close them first.")
		ok
		return "<" + @cRoot + This._AttrText(@aAttrs) + ">" + @cBody + "</" + @cRoot + ">"

	def XmlQ()
		return new stzXml( This.Content() )

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
