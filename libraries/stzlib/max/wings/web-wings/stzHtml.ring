# stzHtml Class - Advanced HTML Management for Ring/Softanza
# Provides comprehensive HTML parsing, manipulation, and generation capabilities


class stzHtml from stzString

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
	@oConfig = new stzHashList([
		:pretty_print = true,
		:indent_size = 2,
		:self_closing_tags = ["area", "base", "br", "col", "embed", "hr", "img", "input", "link", "meta", "param", "source", "track", "wbr"],
		:validate = true,
		:preserve_whitespace = false,
		:encoding = "UTF-8"
	])

	def init(cHtml)
		if isString(cHtml) and not @isNull(cHtml)
			@cOriginalHtml = cHtml
			this.parse(cHtml)
		ok

	# Core parsing methods
	def parse(cHtml)
		@cOriginalHtml = cHtml
		@aElements = []
		@aTextNodes = []
		@aComments = []
		@aMeta = []
		@aParseErrors = []
		@nCurrentPos = 1
		@lParsed = false

		this.parseDocument(cHtml)
		@lParsed = true

	def parseDocument(cHtml)
		cHtml = this.normalizeHtml(cHtml)
		oHtml = new stzString(cHtml)

		# Extract DOCTYPE
		if oHtml.Contains("<!DOCTYPE")
			nStart = oHtml.FindFirst("<!DOCTYPE")
			nEnd = oHtml.findFirstST(">", nStart)
			if nEnd > 0
				@cDoctype = oHtml.Section(nStart, nEnd)
				cHtml = oHtml.SectionRemoved(nStart, nEnd)
			ok
		ok

		# Parse elements recursively
		this.parseElements(cHtml, @aElements)

	def parseElements(cHtml, aContainer)
		nPos = 1
		nLen = len(cHtml)
		oHtml = new stzHtml

		while nPos <= nLen
			# Find next tag
			nTagStart = oHtml.findFirstST("<", nPos)
			
			if nTagStart = 0
				# No more tags, add remaining text
				cText = oHtml.Range(nPos, nLen)
				if not @isNull(@trim(cText))
					aContainer + this.createTextNode(cText)
				ok
				exit
			ok
			
			# Add text before tag
			if nTagStart > nPos
				cText = oHtml.Section(nPos, nTagStart - 1)
				if not @isNull(@trim(cText))
					aContainer + this.createTextNode(cText)
				ok
			ok
			
			# Parse tag
			oElement = this.parseTag(cHtml, nTagStart)
			if oElement != null
				aContainer + oElement
				nPos = oElement[:end_pos] + 1
			else
				nPos = nTagStart + 1
			ok
		end

	def parseTag(cHtml, nStart)
		# Find tag end
		oHtml = new stzstring(cHtml)
		nEnd = this.oHtml.FindfirstST(">", nStart)
		if nEnd = 0
			return null
		ok
		
		cTag = oHtml.Section(nStart, nEnd)
		
		# Handle comments
		if oHtml.startsWith(cTag, "<!--")
			return this.parseComment(cTag, nStart, nEnd)
		ok
		
		# Handle self-closing tags
		if oHtml.endsWith(cTag, "/>")
			return this.parseSelfClosingTag(cTag, nStart, nEnd)
		ok
		
		# Handle closing tags
		if oHtml.startsWith(cTag, "</")
			return null # Will be handled by opening tag parser
		ok
		
		# Handle opening tags
		return this.parseOpeningTag(cHtml, nStart, nEnd)

	def parseOpeningTag(cHtml, nStart, nEnd)
		oHtml = new stzString(cHtml)
		cTag = oHtml.Section(nStart, nEnd)
		
		# Extract tag name and attributes
		aTagInfo = this.parseTagInfo(cTag)
		cTagName = aTagInfo[1]
		aAttributes = aTagInfo[2]
		
		# Create element
		oElement = new stzHashList([
			:type = "element",
			:name = cTagName,
			:attributes = aAttributes,
			:children = [],
			:parent = null,
			:start_pos = nStart,
			:end_pos = nEnd,
			:text_content = "",
			:inner_html = ""
		])
		
		# Find closing tag
		nClosingStart = this.findClosingTag(cHtml, cTagName, nEnd + 1)
		if nClosingStart > 0
			nClosingEnd = oHtml.FindFirstST(">", nClosingStart)
			cInnerHtml = oHtml.Section(nEnd + 1, nClosingStart - 1)
			
			oElement[:inner_html] = cInnerHtml
			oElement[:end_pos] = nClosingEnd
			
			# Parse children
			this.parseElements(cInnerHtml, oElement[:children])
			
			# Set parent references
			for oChild in oElement[:children]
				if isObject(oChild) and oChild.contains(:parent)
					oChild[:parent] = oElement
				ok
			next
		ok
		
		return oElement

	def parseSelfClosingTag(cTag, nStart, nEnd)
		aTagInfo = this.parseTagInfo(cTag)
		cTagName = aTagInfo[1]
		aAttributes = aTagInfo[2]
		
		return new stzHashList([
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
		])

	def parseComment(cTag, nStart, nEnd)
		cContent = this.substring(cTag, 5, len(cTag) - 3) # Remove <!-- and -->
		
		return new stzHashList([
			:type = "comment",
			:content = cContent,
			:start_pos = nStart,
			:end_pos = nEnd
		])

	def parseTagInfo(cTag)
		# Remove < and > or />
		cTag = this.removeFromStart(cTag, "<")
		if this.endsWith(cTag, "/>")
			cTag = this.removeFromEnd(cTag, "/>")
		else
			cTag = this.removeFromEnd(cTag, ">")
		ok
		
		# Split by spaces to get tag name and attributes
		aParts = this.split(cTag, " ")
		cTagName = lower(aParts[1])
		aAttributes = []
		
		# Parse attributes
		for i = 2 to len(aParts)
			cAttr = aParts[i]
			if this.contains(cAttr, "=")
				nEqPos = this.find(cAttr, "=")
				cAttrName = lower(this.substring(cAttr, 1, nEqPos - 1))
				cAttrValue = this.substring(cAttr, nEqPos + 1, len(cAttr))
				
				# Remove quotes
				if this.startsWith(cAttrValue, '"') and this.endsWith(cAttrValue, '"')
					cAttrValue = this.substring(cAttrValue, 2, len(cAttrValue) - 1)
				ok
				
				aAttributes + [cAttrName, cAttrValue]
			else
				aAttributes + [lower(cAttr), ""]
			ok
		next
		
		return [cTagName, aAttributes]

	def createTextNode(cText)
		return new stzHashList([
			:type = "text",
			:content = cText,
			:parent = null
		])

	# Query methods
	def find(cSelector)
		return this.querySelector(cSelector)

	def findAll(cSelector)
		return this.querySelectorAll(cSelector)

	def querySelector(cSelector)
		aResults = this.querySelectorAll(cSelector)
		if len(aResults) > 0
			return aResults[1]
		ok
		return null

	def querySelectorAll(cSelector)
		aResults = []
		
		# Simple selector parsing (can be extended)
		if this.startsWith(cSelector, "#")
			# ID selector
			cId = this.substring(cSelector, 2, len(cSelector))
			this.findById(cId, @aElements, aResults)
		
		elseif this.startsWith(cSelector, ".")
			# Class selector
			cClass = this.substring(cSelector, 2, len(cSelector))
			this.findByClass(cClass, @aElements, aResults)
		
		else
			# Tag selector
			this.findByTag(cSelector, @aElements, aResults)
		ok
		
		return aResults

	def findById(cId, aElements, aResults)
		for oElement in aElements
			if oElement[:type] = "element"
				aAttributes = oElement[:attributes]
				for i = 1 to len(aAttributes) step 2
					if aAttributes[i] = "id" and aAttributes[i + 1] = cId
						aResults + oElement
						return
					ok
				next
				
				# Search children
				this.findById(cId, oElement[:children], aResults)
			ok
		next

	def findByClass(cClass, aElements, aResults)
		for oElement in aElements
			if oElement[:type] = "element"
				aAttributes = oElement[:attributes]
				for i = 1 to len(aAttributes) step 2
					if aAttributes[i] = "class"
						aClasses = this.split(aAttributes[i + 1], " ")
						for cElementClass in aClasses
							if cElementClass = cClass
								aResults + oElement
								exit
							ok
						next
					ok
				next
				
				# Search children
				this.findByClass(cClass, oElement[:children], aResults)
			ok
		next

	def findByTag(cTag, aElements, aResults)
		for oElement in aElements
			if oElement[:type] = "element" and oElement[:name] = lower(cTag)
				aResults + oElement
			ok
			
			if oElement[:type] = "element"
				this.findByTag(cTag, oElement[:children], aResults)
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
		
		oElement = new stzHashList([
			:type = "element",
			:name = lower(cTagName),
			:attributes = aAttributes,
			:children = [],
			:parent = null,
			:start_pos = 0,
			:end_pos = 0,
			:text_content = "",
			:inner_html = cInnerHtml
		])
		
		if not isEmpty(cInnerHtml)
			this.parseElements(cInnerHtml, oElement[:children])
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
		if not isObject(oParent) or not isObject(oChild)
			raise("Both parent and child must be elements")
		ok
		
		aChildren = oParent[:children]
		for i = 1 to len(aChildren)
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
		lFound = false
		
		for i = 1 to len(aAttributes) step 2
			if aAttributes[i] = lower(cName)
				aAttributes[i + 1] = cValue
				lFound = true
				exit
			ok
		next
		
		if not lFound
			aAttributes + [lower(cName), cValue]
		ok
		
		return this

	def getAttribute(oElement, cName)
		if not isObject(oElement)
			raise("Element must be an object")
		ok
		
		aAttributes = oElement[:attributes]
		for i = 1 to len(aAttributes) step 2
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
		for i = 1 to len(aAttributes) step 2
			if aAttributes[i] = lower(cName)
				del(aAttributes, i)
				del(aAttributes, i)
				exit
			ok
		next
		
		return this

	def addClass(oElement, cClass)
		cCurrentClass = this.getAttribute(oElement, "class")
		if cCurrentClass = null
			cCurrentClass = ""
		ok
		
		aClasses = this.split(cCurrentClass, " ")
		
		# Check if class already exists
		for cExistingClass in aClasses
			if cExistingClass = cClass
				return this
			ok
		next
		
		aClasses + cClass
		cNewClass = this.join(aClasses, " ")
		this.setAttribute(oElement, "class", cNewClass)
		
		return this

	def removeClass(oElement, cClass)
		cCurrentClass = this.getAttribute(oElement, "class")
		if cCurrentClass = null
			return this
		ok
		
		aClasses = this.split(cCurrentClass, " ")
		aNewClasses = []
		
		for cExistingClass in aClasses
			if cExistingClass != cClass
				aNewClasses + cExistingClass
			ok
		next
		
		cNewClass = this.join(aNewClasses, " ")
		this.setAttribute(oElement, "class", cNewClass)
		
		return this

	def hasClass(oElement, cClass)
		cCurrentClass = this.getAttribute(oElement, "class")
		if cCurrentClass = null
			return false
		ok
		
		aClasses = this.split(cCurrentClass, " ")
		for cExistingClass in aClasses
			if cExistingClass = cClass
				return true
			ok
		next
		
		return false

	# Generation methods
	def toString()
		return this.generateHtml()

	def generateHtml()
		cHtml = ""
		
		# Add DOCTYPE
		if not isEmpty(@cDoctype)
			cHtml += @cDoctype + nl
		ok
		
		# Generate elements
		for oElement in @aElements
			cHtml += this.generateElement(oElement, 0)
		next
		
		return cHtml

	def generateElement(oElement, nIndent)
		cHtml = ""
		cIndent = this.getIndent(nIndent)
		
		switch oElement[:type]
		on "element"
			cHtml += cIndent + "<" + oElement[:name]
			
			# Add attributes
			aAttributes = oElement[:attributes]
			for i = 1 to len(aAttributes) step 2
				cHtml += ' ' + aAttributes[i] + '="' + aAttributes[i + 1] + '"'
			next
			
			# Check if self-closing
			if oElement.contains(:self_closing) and oElement[:self_closing]
				cHtml += " />"
			else
				cHtml += ">"
				
				# Add children
				if len(oElement[:children]) > 0
					cHtml += nl
					for oChild in oElement[:children]
						cHtml += this.generateElement(oChild, nIndent + 1)
					next
					cHtml += cIndent
				ok
				
				cHtml += "</" + oElement[:name] + ">"
			ok
			
			cHtml += nl
		
		on "text"
			cContent = trim(oElement[:content])
			if not isEmpty(cContent)
				cHtml += cIndent + cContent + nl
			ok
		
		on "comment"
			cHtml += cIndent + "<!-- " + oElement[:content] + " -->" + nl
		
		off
		
		return cHtml

	def getIndent(nLevel)
		if not @oConfig[:pretty_print]
			return ""
		ok
		
		cIndent = ""
		for i = 1 to nLevel * @oConfig[:indent_size]
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
		
		while nPos <= len(cHtml)
			nOpenPos = this.findSubstring(cHtml, "<" + cTagName, nPos)
			nClosePos = this.findSubstring(cHtml, "</" + cTagName, nPos)
			
			if nClosePos = 0
				return 0
			ok
			
			if nOpenPos > 0 and nOpenPos < nClosePos
				# Found another opening tag
				nOpenCount++
				nPos = nOpenPos + len(cTagName) + 1
			else
				# Found closing tag
				nOpenCount--
				if nOpenCount = 0
					return nClosePos
				ok
				nPos = nClosePos + len(cTagName) + 3
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
			this.validateElements(@aElements)
		ok
		
		return len(@aParseErrors) = 0

	def validateElements(aElements)
		for oElement in aElements
			if oElement[:type] = "element"
				this.validateElement(oElement)
				this.validateElements(oElement[:children])
			ok
		next

	def validateElement(oElement)
		cTagName = oElement[:name]
		
		# Check for required attributes
		switch cTagName
		on "img"
			if this.getAttribute(oElement, "alt") = null
				@aParseErrors + "img element missing alt attribute"
			ok
		on "a"
			if this.getAttribute(oElement, "href") = null
				@aParseErrors + "a element missing href attribute"
			ok
		off

	# Information methods
	def getParseErrors()
		return @aParseErrors

	def isParsed()
		return @lParsed

	def getElementCount()
		return this.countElements(@aElements)

	def countElements(aElements)
		nCount = 0
		for oElement in aElements
			if oElement[:type] = "element"
				nCount++
				nCount += this.countElements(oElement[:children])
			ok
		next
		return nCount

	def getTextContent()
		return this.extractTextContent(@aElements)

	def extractTextContent(aElements)
		cText = ""
		for oElement in aElements
			if oElement[:type] = "text"
				cText += oElement[:content]
			elseif oElement[:type] = "element"
				cText += this.extractTextContent(oElement[:children])
			ok
		next
		return cText

	# Pretty printing
	def pretty()
		@oConfig[:pretty_print] = true
		return this.generateHtml()

	def minify()
		@oConfig[:pretty_print] = false
		return this.generateHtml()

	# Debugging methods
	def debug()
		? "=== stzHtml Debug Information ==="
		? "Parsed: " + @lParsed
		? "Element count: " + this.getElementCount()
		? "Parse errors: " + len(@aParseErrors)
		if len(@aParseErrors) > 0
			for cError in @aParseErrors
				? "  - " + cError
			next
		ok
		? "=== End Debug Information ==="
