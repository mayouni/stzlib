# stzHtml Class - Advanced HTML Management for Ring/Softanza
# Provides comprehensive HTML parsing, manipulation, and generation capabilities


class stzHtml from stzObject

	# Internal data structures
	@aElements = []      # Main elements container (hashlist structure)
	@aTextNodes = []     # Text nodes container
	@aComments = []      # Comments container
	@aMeta = []          # Meta information
	@cDoctype = "<!DOCTYPE html>"
	@cOriginalHtml = ""
	@nCurrentPos = 1
	@lParsed = false
	@aParseErrors = []
	@aNamespaces = []
	@oConfig = [
		:pretty_print = true,
		:indent_size = 2,
		:self_closing_tags = ["area", "base", "br", "col", "embed", "hr", "img", "input", "link", "meta", "param", "source", "track", "wbr"],
		:validate = true,
		:preserve_whitespace = false,
		:encoding = "UTF-8"
	]

	def init(cHtml)
		if isString(cHtml) and not @isNull(cHtml)
			@cOriginalHtml = cHtml
			This.Parse(cHtml)
		ok

	# Core parsing methods
	def Parse(cHtml)
		@cOriginalHtml = cHtml
		@aElements = []
		@aTextNodes = []
		@aComments = []
		@aMeta = []
		@aParseErrors = []
		@nCurrentPos = 1
		@lParsed = false

		This.ParseDocument(cHtml)
		@lParsed = true

	def ParseDocument(cHtml)
		cHtml = This.normalizeHtml(cHtml)
		oHtml = new stzString(cHtml)

		# Extract DOCTYPE
		if oHtml.Contains("<!DOCTYPE")
			nStart = oHtml.FindFirst("<!DOCTYPE")
			nEnd = oHtml.FindFirstST(">", nStart)
			if nEnd > 0
				@cDoctype = oHtml.Section(nStart, nEnd)
				cHtml = oHtml.SectionRemoved(nStart, nEnd)
			ok
		ok

		# Parse elements recursively
		This.ParseElements(cHtml, @aElements)

	def ParseElements(cHtml, aContainer)
		nPos = 1
		nLen = len(cHtml)
		oHtml = new stzString(chtml)

		while nPos <= nLen
			# Find next tag
			nTagStart = oHtml.FindFirstST("<", nPos)
			
			if nTagStart = 0
				# No more tags, add remaining text
				cText = oHtml.Section(nPos, nLen)
				if not @isNull(@trim(cText))
					aContainer + This.createTextNode(cText)
				ok
				exit
			ok
			
			# Add text before tag
			if nTagStart > nPos
				cText = oHtml.Section(nPos, nTagStart - 1)
				if not @isNull(@trim(cText))
					aContainer + This.createTextNode(cText)
				ok
			ok
			
			# Parse tag
			oElement = This.ParseTag(cHtml, nTagStart)
			if oElement != null
				aContainer + oElement
				nPos = oElement[:end_pos] + 1
			else
				nPos = nTagStart + 1
			ok
		end

	def ParseTag(cHtml, nStart)
		# Find tag end
		oHtml = new stzstring(cHtml)
		nEnd = oHtml.FindfirstST(">", nStart)
		if nEnd = 0
			return null
		ok
		
		cTag = oHtml.Section(nStart, nEnd)
		
		# Handle comments
		if left(cTag, 4) = "<!--"
			return This.ParseComment(cTag, nStart, nEnd)
		ok
		
		# Handle self-closing tags
		if right(cTag, 2) = "/>"
			return This.ParseSelfClosingTag(cTag, nStart, nEnd)
		ok
		
		# Handle closing tags
		if left(cTag, 2) = "</"
			return null # Will be handled by opening tag Parser
		ok
		
		# Handle opening tags
		return This.ParseOpeningTag(cHtml, nStart, nEnd)

	def ParseOpeningTag(cHtml, nStart, nEnd)
		oHtml = new stzString(cHtml)
		cTag = oHtml.Section(nStart, nEnd)
		
		# Extract tag name and attributes
		aTagInfo = This.ParseTagInfo(cTag)
		cTagName = aTagInfo[1]
		aAttributes = aTagInfo[2]
		
		# Create element
		oElement = [
			:type = "element",
			:name = cTagName,
			:attributes = aAttributes,
			:children = [],
			:parent = null,
			:start_pos = nStart,
			:end_pos = nEnd,
			:text_content = "",
			:inner_html = ""
		]
		
		# Find closing tag
		nClosingStart = This.FindClosingTag(cHtml, cTagName, nEnd + 1)
		if nClosingStart > 0
			nClosingEnd = oHtml.FindFirstST(">", nClosingStart)
			cInnerHtml = oHtml.Section(nEnd + 1, nClosingStart - 1)
			
			oElement[:inner_html] = cInnerHtml
			oElement[:end_pos] = nClosingEnd
			
			# Parse children
			This.ParseElements(cInnerHtml, oElement[:children])
			
			# Set parent references
			for oChild in oElement[:children]
				if isObject(oChild) and oChild.contains(:parent)
					oChild[:parent] = oElement
				ok
			next
		ok
		
		return oElement

	def ParseSelfClosingTag(cTag, nStart, nEnd)
		aTagInfo = This.ParseTagInfo(cTag)
		cTagName = aTagInfo[1]
		aAttributes = aTagInfo[2]
		
		return [
			:type = "element",
			:name = cTagName,
			:attributes = aAttributes,
			:children = [],
			:parent = null,
			:start_pos = nStart,
			:end_pos = nEnd,
			:self_closing = true,
			:text_content = "",
			:inner_html = ""
		]

	def ParseComment(cTag, nStart, nEnd)
		cContent = @substr(cTag, 5, len(cTag) - 3) # Remove <!-- and -->
		
		return [
			:type = "comment",
			:content = cContent,
			:start_pos = nStart,
			:end_pos = nEnd
		]

	def ParseTagInfo(cTag)
		# Remove < and > or />
		oTag = new stzString(cTag)
		oTag.RemoveThisFirstChar("<")
		cTag = oTag.Content()

		if right(cTag, 2) = "/>"
			oTag.RemoveFromEnd("/>")
		else
			oTag.removeFromEnd(">")
		ok
		cTag = oTag.Content()

		# Split by spaces to get tag name and attributes
		aParts = @split(cTag, " ")
		cTagName = lower(aParts[1])
		aAttributes = []
		nLenParts = len(aParts)

		# Parse attributes
		for i = 2 to nLenParts
			cAttr = aParts[i]
			nPos = ring_substr1(cAttr, "=")
			if  nPos > 0
				nEqPos = nPos
				cAttrName = lower(@substr(cAttr, 1, nEqPos - 1))
				cAttrValue = @substr(cAttr, nEqPos + 1, len(cAttr))
				
				# Remove quotes
				if cAttrValue[1] = '"' and
					ring_reverse(cAttrValue[1]) = '"'

					cAttrValue = @substr(cAttrValue, 2, len(cAttrValue) - 1)
				ok
				
				aAttributes + [cAttrName, cAttrValue]
			else
				aAttributes + [lower(cAttr), ""]
			ok
		next
		
		return [cTagName, aAttributes]

	def createTextNode(cText)
		return [
			:type = "text",
			:content = cText,
			:parent = null
		]

	# Query methods
	def find(cSelector)
		return This.querySelector(cSelector)

	def findAll(cSelector)
		return This.querySelectorAll(cSelector)

	def querySelector(cSelector)
		aResults = This.querySelectorAll(cSelector)
		if len(aResults) > 0
			return aResults[1]
		ok
		return null

	def querySelectorAll(cSelector)
		aResults = []
		
		# Simple selector parsing (can be extended)
		if cSelector[1] = "#"
			# ID selector
			cId = @substr(cSelector, 2, len(cSelector))
			This.FindById(cId, @aElements, aResults)
		
		but cSelector[1] = "."
			# Class selector
			cClass = @substr(cSelector, 2, len(cSelector))
			This.FindByClass(cClass, @aElements, aResults)
		
		else
			# Tag selector
			This.FindByTag(cSelector, @aElements, aResults)
		ok
		
		return aResults

	def findById(cId, aElements, aResults)
		nLenElm = len(aElements)

		for i = 1 to nLenElm
			
			if aElements[i][:type] = "element"

				aAttributes = aElements[i][:attributes]
				nLenAtt = len(aAttributes)

				for i = 1 to nLenAtt step 2

					if aAttributes[i] = "id" and aAttributes[i + 1] = cId
						aResults + aElements[i]
						return
					ok

				next
				
				# Search children
				This.FindById(cId, aElements[i][:children], aResults)
			ok
		next

	def findByClass(cClass, aElements, aResults)
		for oElement in aElements
			if oElement[:type] = "element"
				aAttributes = oElement[:attributes]
				for i = 1 to len(aAttributes) step 2
					if aAttributes[i] = "class"
						aClasses = This.split(aAttributes[i + 1], " ")
						for cElementClass in aClasses
							if cElementClass = cClass
								aResults + oElement
								exit
							ok
						next
					ok
				next
				
				# Search children
				This.FindByClass(cClass, oElement[:children], aResults)
			ok
		next

	def findByTag(cTag, aElements, aResults)
		for oElement in aElements
			if oElement[:type] = "element" and oElement[:name] = lower(cTag)
				aResults + oElement
			ok
			
			if oElement[:type] = "element"
				This.FindByTag(cTag, oElement[:children], aResults)
			ok
		next

	# Manipulation methods
	def createElement(cTagName, aAttributes, cInnerHtml)
		if not isString(cTagName)
			raise("Tag name must be a string")
		ok
		
		if not isList(aAttributes)
			aAttributes = []
		ok
		
		if not isString(cInnerHtml)
			cInnerHtml = ""
		ok
		
		oElement = [
			:type = "element",
			:name = lower(cTagName),
			:attributes = aAttributes,
			:children = [],
			:parent = null,
			:start_pos = 0,
			:end_pos = 0,
			:text_content = "",
			:inner_html = cInnerHtml
		]
		
		if not isEmpty(cInnerHtml)
			This.ParseElements(cInnerHtml, oElement[:children])
		ok
		
		return oElement

	def appendChild(oParent, oChild)
		if not isObject(oParent) or not isObject(oChild)
			raise("Both parent and child must be elements")
		ok
		
		oParent[:children] + oChild
		oChild[:parent] = oParent
		
		return this

	def removeChild(oParent, oChild)
		if not(  isObject(oParent) and isObject(oChild))
			raise("Both parent and child must be elements")
		ok
		
		aChildren = oParent[:children]
		nLen = len(aChildren)

		for i = 1 to nLen
			if aChildren[i] = oChild
				del(aChildren, i)
				oChild[:parent] = null
				exit
			ok
		next
		
		return this

	def setAttribute(oElement, cName, cValue)
		if not isObject(oElement)
			raise("Element must be an object")
		ok
		
		aAttributes = oElement[:attributes]
		bFound = false
		nLen = len(aAttributes)

		for i = 1 to nLen step 2
			if aAttributes[i] = lower(cName)
				aAttributes[i + 1] = cValue
				bFound = true
				exit
			ok
		next
		
		if not bFound
			aAttributes + [lower(cName), cValue]
		ok
		
		return this

	def getAttribute(oElement, cName)
		if not isObject(oElement)
			raise("Element must be an object")
		ok
		
		aAttributes = oElement[:attributes]
		nLen = len(aAttributes)

		for i = 1 to nLen step 2
			if aAttributes[i] = lower(cName)
				return aAttributes[i + 1]
			ok
		next
		
		return null

	def removeAttribute(oElement, cName)
		if not isObject(oElement)
			raise("Element must be an object")
		ok
		
		aAttributes = oElement[:attributes]
		nLen = len(aAttributes)

		for i = 1 to nLen step 2
			if aAttributes[i] = lower(cName)
				del(aAttributes, i)
				del(aAttributes, i)
				exit
			ok
		next
		
		return this

	def addClass(oElement, cClass)
		cCurrentClass = This.GetAttribute(oElement, "class")
		if cCurrentClass = null
			cCurrentClass = ""
		ok
		
		aClasses = @split(cCurrentClass, " ")
		nLen = len(aClasses)

		# Check if class already exists

		for i = 1 to nLen
			if aClasses[i] = cClass
				return this
			ok
		next
		
		aClasses + cClass
		cNewClass = @joinXT(aClasses, " ")
		This.setAttribute(oElement, "class", cNewClass)
		
		return this

	def removeClass(oElement, cClass)
		cCurrentClass = This.GetAttribute(oElement, "class")
		if cCurrentClass = null
			return this
		ok
		
		aClasses = @split(cCurrentClass, " ")
		aNewClasses = []
		nLen = len(aClasses)

		for i = 1 to nLen
			if aClasses[i] != cClass
				aNewClasses + aClasses[i]
			ok
		next
		
		cNewClass = @joinXT(aNewClasses, " ")
		This.setAttribute(oElement, "class", cNewClass)
		
		return this

	def hasClass(oElement, cClass)
		cCurrentClass = This.GetAttribute(oElement, "class")
		if cCurrentClass = null
			return false
		ok
		
		aClasses = @split(cCurrentClass, " ")
		nLen = len(aClasses)

		for i = 1 to nLen
			if aClasses[i] = cClass
				return true
			ok
		next
		
		return false

	# Generation methods
	def toString()
		return This.generateHtml()

	def generateHtml()
		cHtml = ""
		
		# Add DOCTYPE
		if not isEmpty(@cDoctype)
			cHtml += @cDoctype + nl
		ok
		
		# Generate elements
		nLen = len(@aElements)

		for i = 1 to nLen
			cHtml += This.generateElement(@aElements[i], 0)
		next
		
		return cHtml

	def generateElement(oElement, nIndent)
		cHtml = ""
		cIndent = This.GetIndent(nIndent)
		
		switch oElement[:type]
		on "element"
			cHtml += cIndent + "<" + oElement[:name]
			
			# Add attributes
			aAttributes = oElement[:attributes]
			nLen = len(aAttributes)
			for i = 1 to nLen step 2
				cHtml += ' ' + aAttributes[i] + '="' + aAttributes[i + 1] + '"'
			next
			
			# Check if self-closing
			if NOT IsNull(oElement[:self_closing])
				cHtml += " />"
			else
				cHtml += ">"
				
				# Add children
				if len(oElement[:children]) > 0
					cHtml += nl
					nLenElm = len(oElement[:children])

					for j = 1 to nLenElm
						cHtml += This.generateElement(oElement[:children][j], nIndent + 1)
					next
					cHtml += cIndent
				ok
				
				cHtml += "</" + oElement[:name] + ">"
			ok
			
			cHtml += nl
		
		on "text"
			cContent = @trim(oElement[:content])
			if not isEmpty(cContent)
				cHtml += (cIndent + cContent + nl)
			ok
		
		on "comment"
			cHtml += (cIndent + "<!-- " + oElement[:content] + " -->" + nl)
		
		off
		
		return cHtml

	def getIndent(nLevel)
		if not @oConfig[:pretty_print]
			return ""
		ok
		
		cIndent = ""
		nLen = nLevel * @oConfig[:indent_size]

		for i = 1 to nLen
			cIndent += " "
		next
		
		return cIndent

	# Utility methods
	def normalizeHtml(cHtml)
		# Remove extra whitespace if not preserving
		if not @oConfig[:preserve_whitespace]
			cHtml = ring_substr2(cHtml, "\s+", " ")
		ok
		
		return cHtml

	def findClosingTag(cHtml, cTagName, nStart)
		nPos = nStart
		nOpenCount = 1
		oHtml = new stzString(cHtml)
		nLen = oHtml.NumberOfChars()
		nLenTag = stzlen(cTagName)

		while nPos <= nLen
			nOpenPos  = oHtml.FindFirstST( ("<" + cTagName), nPos)
			nClosePos = oHtml.FindFirstST( ("</" + cTagName), nPos)
			
			if nClosePos = 0
				return 0
			ok
			
			if nOpenPos > 0 and nOpenPos < nClosePos
				# Found another opening tag
				nOpenCount++
				nPos = nOpenPos + nLenTag + 1
			else
				# Found closing tag
				nOpenCount--
				if nOpenCount = 0
					return nClosePos
				ok
				nPos = nClosePos + nLenTag + 3
			ok
		end
		
		return 0

	# Configuration methods
	def setConfig(cKey, value)
		@oConfig[cKey] = value
		return this

	def getConfig(cKey)
		return @oConfig[cKey]

	# Validation methods
	def validate()
		@aParseErrors = []
		
		if @oConfig[:validate]
			This.validateElements(@aElements)
		ok
		
		return len(@aParseErrors) = 0

	def validateElements(aElements)
		nLen = len(aElements)

		for i = 1 to nLen
			if aElements[i][:type] = "element"
				This.validateElement(aElements[i])
				This.validateElements(aElements[i][:children])
			ok
		next

	def validateElement(oElement)
		cTagName = oElement[:name]
		
		# Check for required attributes
		switch cTagName
		on "img"
			if This.GetAttribute(oElement, "alt") = null
				@aParseErrors + "img element missing alt attribute"
			ok
		on "a"
			if This.GetAttribute(oElement, "href") = null
				@aParseErrors + "a element missing href attribute"
			ok
		off

	# Information methods
	def getParseErrors()
		return @aParseErrors

	def isParsed()
		return @lParsed

	def getElementCount()
		return This.countElements(@aElements)

	def countElements(aElements)
		nCount = 0
		nLen = len(aElements)

		for i = 1 to nLen
			if aElements[i][:type] = "element"
				nCount++
				nCount += This.countElements(aElements[i][:children])
			ok
		next
		return nCount

	def getTextContent()
		return This.extractTextContent(@aElements)

	def extractTextContent(aElements)
		cText = ""
		nLen = len(aElements)

		for i = 1 to nLen
			if aElements[i][:type] = "text"
				cText += aElements[i][:content]
			elseif aElements[i][:type] = "element"
				cText += This.extractTextContent(aElements[i][:children])
			ok
		next
		return cText

	# Pretty printing
	def pretty()
		@oConfig[:pretty_print] = true
		return This.generateHtml()

	def minify()
		@oConfig[:pretty_print] = false
		return This.generateHtml()

	# Debugging methods
	def debug()
		? "=== stzHtml Debug Information ==="
		? "Parsed: " + @lParsed
		? "Element count: " + This.GetElementCount()
		? "Parse errors: " + len(@aParseErrors)
		if len(@aParseErrors) > 0
			for cError in @aParseErrors
				? "  - " + cError
			next
		ok
		? "=== End Debug Information ==="
