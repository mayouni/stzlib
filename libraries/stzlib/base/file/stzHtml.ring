
load "html.ring"  # The lexbor-based HTML extension

/*
	Softanza HTML/CSS Handling Philosophy
	=====================================

	- Natural language oriented: Methods like ElementsWhere(:Tag = "div"), AttributesOf("id='main'"), etc.
	- Fluent chaining: Q() versions return This for method chaining
	- Intent-based: Separate classes for parsing, building, manipulating
	- Global functions for quick access
	- Handles both HTML and XML uniformly
	- CSS integration: stzCSS for style manipulation and selector building
	- Rich querying: Supports CSS selectors + natural conditions
	- Safety: Validation, error handling with StzRaise
	- Extensibility: XT methods for extended info

	Core Classes:
	- stzHtml: Main document handler
	- stzHtmlNode: Single element handler
	- stzHtmlBuilder: For creating HTML from scratch
	- stzCSS: For CSS style handling and selectors

	NOTE: Leverages html.ring's HTML class for parsing and DOM ops
*/

# Global functions for quick access

func HtmlQ(pcHtmlOrFile)
	if fexists(pcHtmlOrFile)
		pcHtmlOrFile = read(pcHtmlOrFile)
	ok
	return new stzHtml(pcHtmlOrFile)

	func @HtmlQ(pcHtmlOrFile)
		return HtmlQ(pcHtmlOrFile)

func IsHtml(pcStr)
	return StzStringQ(pcStr).Contains("<html") or StzStringQ(pcStr).Contains("<!DOCTYPE html")

	func @IsHtml(pcStr)
		return IsHtml(pcStr)

func HtmlToText(pcHtml)
	return HtmlQ(pcHtml).Text()

	func @HtmlToText(pcHtml)
		return HtmlToText(pcHtml)

func HtmlFind(pcHtml, pcSelector)
	return HtmlQ(pcHtml).Find(pcSelector)

	func @HtmlFind(pcHtml, pcSelector)
		return HtmlFind(pcHtml, pcSelector)

func ListToHtmlTable(paList)
	# Assuming paList is 2D list as in stzHtml.ring
	return ListToHtmlXT(paList)

	func @ListToHtmlTable(paList)
		return ListToHtmlTable(paList)

func HtmlTableToList(pcHtmlTable)
	return StzStringQ(pcHtmlTable).HtmlToDataTable()  # Assuming implementation from provided code

	func @HtmlTableToList(pcHtmlTable)
		return HtmlTableToList(pcHtmlTable)

#== stzHtml Class: Main HTML Document Handler

class stzHtml

	@cHtml       # Original HTML string
	@oHtml       # Underlying HTML object from html.ring
	@aNodes      # Cache for all nodes

	def init(pcHtml)
		if CheckParams()
			if NOT isString(pcHtml)
				StzRaise("Incorrect param type! pcHtml must be a string.")
			ok
		ok

		@cHtml = pcHtml
		@oHtml = new HTML(pcHtml)
		@aNodes = NULL  # Lazy load

	def Content()
		return @cHtml

		def Html()
			return This.Content()

	def Reload(pcHtml)
		@cHtml = pcHtml
		@oHtml = new HTML(pcHtml)
		@aNodes = NULL
		return 1

		def ReloadQ(pcHtml)
			This.Reload(pcHtml)
			return This

	def Find(pcSelector)
		if CheckParams()
			if NOT isString(pcSelector)
				StzRaise("Incorrect param type! pcSelector must be a string.")
			ok
		ok

		aRawNodes = @oHtml.find(pcSelector)
		aResult = []
		for oNode in aRawNodes
			aResult + new stzHtmlNode(oNode)
		next
		return aResult

		def FindQ(pcSelector)
			return new stzList(This.Find(pcSelector))  # Wrap in stzList for further natural ops

	def FindFirst(pcSelector)
		aNodes = This.Find(pcSelector)
		if len(aNodes) > 0
			return aNodes[1]
		else
			return NULL
		ok

		def FindFirstQ(pcSelector)
			return This.FindFirst(pcSelector)

	def FindAll(pcSelector)
		return This.Find(pcSelector)

	def ElementsWhere(pCondition)
		# pCondition can be hash like :Tag = "div", :Class = "main", etc.
		if isList(pCondition) and StzHashListQ(pCondition).IsHashList()
			aNodes = This.Elements()
			aResult = []
			for oNode in aNodes
				bMatch = TRUE
				for aPair in pCondition
					cKey = lower(aPair[1])
					cVal = aPair[2]
					switch cKey
					on "tag"
						if lower(oNode.Tag()) != lower(cVal)
							bMatch = FALSE
						ok
					on "class"
						if NOT oNode.HasKlass(cVal)
							bMatch = FALSE
						ok
					on "id"
						if oNode.Id() != cVal
							bMatch = FALSE
						ok
					on "attr"
						if isList(cVal) and len(cVal)=2
							if oNode.Attr(cVal[1]) != cVal[2]
								bMatch = FALSE
							ok
						ok
					other
						StzRaise("Unsupported condition key: " + cKey)
					off
				next
				if bMatch
					aResult + oNode
				ok
			next
			return aResult
		else
			StzRaise("Condition must be a hash list.")
		ok

		def ElementsWhereQ(pCondition)
			return new stzList(This.ElementsWhere(pCondition))

	def Elements()
		if isNull(@aNodes)
			@aNodes = This.Find("*")
		ok

		return @aNodes

	def NumberOfElements()
		return len(This.Elements())

	def Text()
		return @oHtml.text()

		def PlainText()
			return This.Text()

	def HasBody()
		return NOT isNull(@oHtml.body())

	def HasHead()
		return NOT isNull(@oHtml.head())

	def Body()
		oBody = @oHtml.body()
		if isNull(oBody)
			return NULL
		ok
		return new stzHtmlNode(oBody)

	def Head()
		oHead = @oHtml.head()
		if isNull(oHead)
			return NULL
		ok
		return new stzHtmlNode(oHead)

	def Root()
		oRoot = @oHtml.root()
		if isNull(oRoot)
			return NULL
		ok
		return new stzHtmlNode(oRoot)

	def ToXml()
		# Assuming HTML can be treated as XML for output
		return This.Html()

	def IsValid()
		return NOT isNull(@oHtml.root())

	def SaveToFile(cFile)
		write(cFile, This.Html())
		return 1

		def SaveToFileQ(cFile)
			This.SaveToFile(cFile)
			return This

	# Extended info
	def InfoXT()
		aInfo = [
			:NumberOfElements = This.NumberOfElements(),
			:HasBody = NOT isNull(This.Body()),
			:HasHead = NOT isNull(This.Head()),
			:TagsUsed = This.TagsUsed()
		]
		return aInfo

	func TagsUsed()
		aTags = []
		for oNode in This.Elements()
			cTag = lower(oNode.Tag())
			if NOT ring_find(aTags, cTag)
				aTags + cTag
			ok
		next
		return aTags

#== stzHtmlNode Class: Single Node/Element Handler

class stzHtmlNode

	@oNode       # Underlying node object from html.ring

	def init(oNode)
		@oNode = oNode

	def Tag()
		return lower(@oNode.tag())

	def Text()
		return @oNode.text()

	def Html()
		return @oNode.html()

		def InnerHtml()
			return @oNode.innerHTML()

	def Attr(cName)
		return @oNode.attr(cName)

		def Attribute(cName)
			return This.Attr(cName)

	def HasAttr(cName)
		return @oNode.has_attr(cName)

	def Attributes()
		return @oNode.attributes()

	def SetAttr(cName, cValue)
		@oNode.setAttribute(cName, cValue)
		return 1

		def SetAttrQ(cName, cValue)
			This.SetAttr(cName, cValue)
			return This

	def RemoveAttr(cName)
		@oNode.removeAttribute(cName)
		return 1

		def RemoveAttrQ(cName)
			This.RemoveAttr(cName)
			return This

	def Id()
		return This.Attr("id")

	def Klass()
		return This.Attr("class")

		def Class_()
			return This.Attr("class")

	def HasKlass(cClass)
		cClasses = This.Klass()
		if isNull(cClasses)
			return FALSE
		ok
		return StzStringQ(cClasses).ContainsCS(cClass, FALSE)

		def HasClass(cClass)
			return This.HasKlass(cClass)

	def AddKlass(cClass)
		cCurrent = This.Klass()
		if isNull(cCurrent)
			cCurrent = ""
		ok
		This.SetAttr("class", trim(cCurrent + " " + cClass))
		return 1

		def AddClass(cClass)
			return This.AddClass(cClass)

		def AddKlassQ(cClass)
			This.AddKlass(cClass)
			return This

		def AddClassQ(cClass)
			return This.AddKlassQ(cClass)

	def RemoveKlass(cClass)
		cCurrent = This.Klass()
		if isNull(cCurrent)
			return 1
		ok
		oStr = new stzString(cCurrent)
		oStr.RemoveCS(cClass, FALSE)
		This.SetAttr("class", trim(oStr.Content()))
		return 1

		def RemoveClass(cClass)
			return This.RemoveKlass(cClass)

		def RemoveKlassQ(cClass)
			This.RemoveKlass(cClass)
			return This

		def RemoveClassQ(cClass)
			return This.RemoveClassQ(cClass)

	def Parent()
		oParent = @oNode.parent()
		if isNull(oParent)
			return NULL
		ok
		return new stzHtmlNode(oParent)

	def Children()
		aChildren = @oNode.children()
		aResult = []
		for oChild in aChildren
			aResult + new stzHtmlNode(oChild)
		next
		return aResult

	def FirstChild()
		oFirst = @oNode.firstChild()
		if isNull(oFirst)
			return NULL
		ok
		return new stzHtmlNode(oFirst)

	def LastChild()
		oLast = @oNode.lastChild()
		if isNull(oLast)
			return NULL
		ok
		return new stzHtmlNode(oLast)

	def NextSibling()
		oNext = @oNode.next_sibling()
		if isNull(oNext)
			return NULL
		ok
		return new stzHtmlNode(oNext)

	def PrevSibling()
		oPrev = @oNode.prev_sibling()
		if isNull(oPrev)
			return NULL
		ok
		return new stzHtmlNode(oPrev)

	def AppendChild(oChildNode)
		if isObject(oChildNode) and classname(oChildNode) = "stzhtmlnode"
			@oNode.appendChild(oChildNode.@oNode)
		else
			StzRaise("Invalid child node.")
		ok
		return 1

		def AppendChildQ(oChildNode)
			This.AppendChild(oChildNode)
			return This

	def InsertBefore(oNewNode)
		@oNode.insertBefore(oNewNode.@oNode)
		return 1

		def InsertBeforeQ(oNewNode)
			This.InsertBefore(oNewNode)
			return This

	def InsertAfter(oNewNode)
		@oNode.insertAfter(oNewNode.@oNode)
		return 1

		def InsertAfterQ(oNewNode)
			This.InsertAfter(oNewNode)
			return This

	def Remove()
		@oNode.remove()
		return 1

	def SetText(cText)
		@oNode.setInnerText(cText)
		return 1

		def SetTextQ(cText)
			This.SetText(cText)
			return This

	def SetHtml(cHtml)
		@oNode.setInnerHTML(cHtml)
		return 1

		def SetHtmlQ(cHtml)
			This.SetHtml(cHtml)
			return This

	def Find(pcSelector)
		aRawNodes = @oNode.find(pcSelector)
		aResult = []
		for oRaw in aRawNodes
			aResult + new stzHtmlNode(oRaw)
		next
		return aResult

#== stzHtmlBuilder Class: For Building HTML Documents

class stzHtmlBuilder

	@oDoc
	@oCurrentNode

	def init()
		@oDoc = new HTML("<html></html>")
		@oCurrentNode = @oDoc.root()

	def CreateNode(cTag)
		oNode = @oDoc.createNode(cTag)
		return new stzHtmlNode(oNode)

		def CreateNodeQ(cTag)
			return This.CreateNode(cTag)

	def AppendToCurrent(oNode)
		@oCurrentNode.appendChild(oNode.@oNode)
		return 1

		def AppendToCurrentQ(oNode)
			This.AppendToCurrent(oNode)
			return This

	def SetCurrent(oNode)
		@oCurrentNode = oNode.@oNode
		return 1

		def SetCurrentQ(oNode)
			This.SetCurrent(oNode)
			return This

	def Build()
		return @oDoc.html()

	def BuildToFile(cFile)
		write(cFile, This.Build())
		return 1

#== stzCSS Class: CSS Handling (Styles and Selectors)

class stzCSS

	@cCss       # CSS string
	@aRules     # Parsed rules (lazy)

	def init(pcCss)
		@cCss = pcCss
		@aRules = NULL

	def Content()
		return @cCss

	def Parse()
		if NOT isNull(@aRules)
			return @aRules
		ok
		# Simple CSS parser (for demo; in real, use a full parser)
		@aRules = []
		oStr = new stzString(@cCss)
		aBlocks = oStr.SplitToListOfStrings("{}")
		for i=1 to len(aBlocks) step 2
			cSelector = trim(aBlocks[i])
			cDeclarations = trim(aBlocks[i+1])
			aDecl = StzStringQ(cDeclarations).Split(";")
			aProps = []
			for cDecl in aDecl
				aPair = StzStringQ(trim(cDecl)).Split(":")
				if len(aPair)=2
					aProps + [trim(aPair[1]), trim(aPair[2])]
				ok
			next
			@aRules + [cSelector, aProps]
		next
		return @aRules

	def Rules()
		return This.Parse()

	def Selectors()
		aSelectors = []
		for aRule in This.Rules()
			aSelectors + aRule[1]
		next
		return aSelectors

	def ApplyToHtml(pcHtml)
		# Placeholder: Apply CSS to HTML (would require more integration)
		StzRaise("Not implemented yet.")

	# Natural methods
	def PropertyOf(pcSelector, pcProp)
		for aRule in This.Rules()
			if lower(aRule[1]) = lower(pcSelector)
				for aProp in aRule[2]
					if lower(aProp[1]) = lower(pcProp)
						return aProp[2]
					ok
				next
			ok
		next
		return NULL

# Additional utils from provided stzHtml.ring

func ListToHtmlXT(paList)
	# Implementation as provided in the document
	if NOT (isList(paList) and len(paList) > 0)
		StzRaise("paList must be a non-empty 2D list.")
	ok

	nCols = len(paList)
	nRows = 0
	for col in paList
		nRows = max(nRows, len(col[2]))
	next

	for i=1 to nCols
		while len(paList[i][2]) < nRows
			paList[i][2] + ""
		end
	next

	cHtml = '<table class="data">' + nl
	cHtml += '<thead><tr>' + nl
	for i=1 to nCols
		cHtml += '<th>' + paList[i][1] + '</th>' + nl
	next
	cHtml += '</tr></thead>' + nl
	cHtml += '<tbody>' + nl
	for r=1 to nRows
		cHtml += '<tr>' + nl
		for c=1 to nCols
			cHtml += '<td>' + paList[c][2][r] + '</td>' + nl
		next
		cHtml += '</tr>' + nl
	next
	cHtml += '</tbody></table>'
	return cHtml

func IsHtmlTable(pcStr)
	# Simple check
	oStr = new stzString(pcStr)
	return oStr.Contains("<table") and oStr.Contains("</table>")

func HtmlToList(pcHtmlTable)
	# Parse table to 2D list
	doc = new HTML(pcHtmlTable)
	aHeaders = doc.find("th")
	aData = doc.find("td")
	aRows = doc.find("tr")

	if len(aRows) = 0
		return []
	ok

	aResult = []
	nCols = len(aHeaders)
	if nCols = 0
		nCols = len(aRows[1].children())  # Assume first row
	ok

	for i=1 to nCols
		cHeader = ""
		if i <= len(aHeaders)
			cHeader = aHeaders[i].text()
		ok
		aResult + [cHeader, []]
	next

	nCell = 1
	for row in aRows
		aCells = row.children()
		for c=1 to nCols
			if nCell <= len(aData)
				aResult[c][2] + aData[nCell].text()
				nCell++
			else
				aResult[c][2] + ""
			ok
		next
	next

	return aResult
