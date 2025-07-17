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
	@bParsed = false
	@aParseErrors = []
	@aNamespaces = []
	@oConfig = [
		:pretty_print = true,
		:indent_size = 2,
		:self_closing_tags = ["area", "base", "br", "col", "embed", "hr", "img", "input", "link", "meta", "param", "source", "track", "wbr"],
		:Validate = true,
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
		@bParsed = false

		This.ParseDocument(cHtml)
		@bParsed = true

	def ParseDocument(cHtml)
		cHtml = This.NormalizeHtml(cHtml)
	
		# Extract DOCTYPE
		nStart = ring_substr1(cHtml, "<!DOCTYPE")
		if nStart > 0

			nEnd = @substrXT([ cHtml, ">", nStart ])
			if nEnd > 0
				@cDoctype = @substrXT([ cHtml, nStart, nEnd ])
				# Section removed between (nStart, nEnd)
				cHtml = left(cHtml, nStart-1) + right(chtml, nEnd-1)
			ok
		ok
	
		# Parse with proper nesting
		This.ParseElementsHierarchical(cHtml, @aElements, [])


	def ParseElementsHierarchical(cHtml, aContainer, aOpenTags)
		nPos = 1
		nLen = len(cHtml)

	
		while nPos <= nLen
			nTagStart = @substrXT([ cHtml, "<", nPos ])
			
			if nTagStart = 0
				# Add remaining text
				cText = @trim( @substrXT([ cHtml, nPos, nLen ]) )
				if not isEmpty(cText)
					aContainer + This.CreateTextNode(cText)
				ok
				exit
			ok
			
			# Add text before tag
			if nTagStart > nPos
				cText = @trim( @substrXT([ cHtml, nPos, nTagStart - 1 ]))
				if not isEmpty(cText)
					aContainer + This.CreateTextNode(cText)
				ok
			ok
			
			# Find tag end
			nTagend = @substrXT([ cHtml, ">", nTagStart ])
			if nTagEnd = 0
				exit
			ok

			cTag = @substrXT([ cHtml, nTagStart, nTagEnd ])
			# Handle closing tags
			if left(cTag, 2) = "</"
				cTagName = @substr(cTag, 3, len(cTag) - 3)
				return nTagEnd + 1  # Return position after closing tag
			ok
			
			# Parse opening tag
			aElement = This.ParseTag(cHtml, nTagStart)
			if aElement != null
				aContainer + aElement
				
				if aElement[:type] = "element" and IsNull(aElement[:self_closing])
					# Parse children recursively
					nNewPos = This.ParseElementsHierarchical(cHtml, aElement[:children], aOpenTags + [aElement[:name]])
					if nNewPos > 0
						nPos = nNewPos
					else
						nPos = nTagEnd + 1
					ok
				else
					nPos = nTagEnd + 1
				ok
			else
				nPos = nTagEnd + 1
			ok
		end
		
		return 0


	def ParseElements(cHtml, aContainer)
		nPos = 1
		nLen = srzlen(cHtml)
	
		while nPos <= nLen
			# Find next tag
			nTagStart = @substrXT([ cHtml, "<", nPos ])
			
			if nTagStart = 0
				# No more tags, add remaining text
				cText = @substrXT([ cHtml, nPos, nLen ])
				cText = @trim(cText)
				if not isEmpty(cText)
					aContainer + This.CreateTextNode(cText)
				ok
				exit
			ok
			
			# Add text before tag
			if nTagStart > nPos
				cText = @substrXT([ cHtml, nPos, nTagStart - 1 ])
				cText = @trim(cText)
				if not isEmpty(cText)
					aContainer + This.CreateTextNode(cText)
				ok
			ok
			
			# Parse tag
			aElement = This.ParseTag(cHtml, nTagStart)
			if aElement != null
				aContainer + aElement
				
				# Update position correctly based on element type
				if aElement[:type] = "element" and IsNull(aElement[:self_closing])
					# For opening tags with closing tags, skip to after closing tag
					if not IsNull(aElement[:closing_tag_end])
						nPos = aElement[:closing_tag_end] + 1
					else
						nPos = aElement[:end_pos] + 1
					ok
				else
					# For self-closing tags and comments
					nPos = aElement[:end_pos] + 1
				ok
			else
				nPos = nTagStart + 1
			ok
		end

	def ParseTag(cHtml, nStart)
		# Find tag end
		nEnd = @substrXT([ cHtml, ">", nStart ])
		if nEnd = 0
			return null
		ok
		
		cTag = @substrXT([ cHtml, nStart, nEnd ])
		
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

		cTag = @substrXT([ cHtml, nStart, nEnd ])
		
		# Extract tag name and attributes
		aTagInfo = This.ParseTagInfo(cTag)
		cTagName = aTagInfo[1]
		aAttributes = aTagInfo[2]
		
		# Create element
		aElement = [
			:type = "element",
			:name = cTagName,
			:attributes = aAttributes,
			:children = [],
			:parent = null,
			:start_pos = nStart,
			:end_pos = nEnd,
			:text_content = "",
			:inner_html = "",
			:closing_tag_end = null
		]
		
		# Find closing tag
		nClosingStart = This.FindClosingTag(cHtml, cTagName, nEnd + 1)
		if nClosingStart > 0
			nClosingEnd = @substrXT([ cHtml, ">", nClosingStart ])
			cInnerHtml = @substrXT([ cHtml, nEnd + 1, nClosingStart - 1 ])
			
			aElement[:inner_html] = cInnerHtml
			aElement[:end_pos] = nEnd
			aElement[:closing_tag_end] = nClosingEnd
			
			# Don't parse children here - they'll be parsed by the main ParseElements loop
			# when it processes the content between the opening and closing tags
			
		ok
		
		return aElement


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
		nLenTag = len(cTag)
		if cTag[1] = "<"
			cTag = right(cTag, nlenTag-1)
		ok

		if right(cTag, 2) = "/>"
			cTag = left(cTag, len(cTag)-2)
		else
			cTag = left(cTag, len(cTag)-1)
		ok

		# Split by spaces to get tag name and attributes
		aParts = split(cTag, " ")
		cTagName = lower(aParts[1])
		aAttributes = []
		nLenParts = len(aParts)

		# Parse attributes
		for i = 2 to nLenParts

			cAttr = aParts[i]

			if isEmpty(trim(cAttr))
				loop
			ok

			nPos = ring_substr1(cAttr, "=")

			if  nPos > 0

				nEqPos = nPos
				cAttrName = lower(@substr(cAttr, 1, nEqPos - 1))
				cAttrValue = @substr(cAttr, nEqPos + 1, len(cAttr))
				
				# Remove quotes
				if cAttrValue[1] = '"' and
				   cAttrValue[len(cAttrValue)] = '"'

					cAttrValue = @substr(cAttrValue, 2, len(cAttrValue) - 1)
				ok
				
				aAttributes + [cAttrName, cAttrValue]
			else
				aAttributes + [lower(cAttr), ""]
			ok

		next
		
		return [cTagName, aAttributes]

	def CreateTextNode(cText)
		return [
			:type = "text",
			:content = cText,
			:parent = null
		]

	# Query methods
	def FindFirst(cSelector)
		return This.QuerySelector(cSelector)

	def Find(cSelector)
		return This.QuerySelectorAll(cSelector)

		def FindAll(cSelector)
			return This.QuerySelectorAll(cSelector)

	def QuerySelector(cSelector)
		aResults = This.querySelectorAll(cSelector)
		if len(aResults) > 0
			return aResults[1]
		ok
		return null

	def QuerySelectorAll(cSelector)
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

	def FindById(cId, aElements, aResults)
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

	def FindByClass(cClass, aElements, aResults)
		nLenElm = len(aElements)

		for i = 1 to nLenElm
			aElement = aElements[i]

			if aElement[:type] = "element"

				aAttributes = aElement[:attributes]
				nLenAtt = len(aAttributes)

				for j = 1 to nLenAtt step 2

					if aAttributes[j] = "class"

						aClasses = @split(aAttributes[j + 1], " ")
						nLenCls = len(aClasses)

						for q = 1 to nLenCls

							cElementClass = aClasses[q]

							if not isEmpty(trim(cElementClass)) and
							   cElementClass = cClass

								aResults + aElement
								exit
							ok
						next

					ok
				next
				
				# Search children
				This.FindByClass(cClass, aElement[:children], aResults)
			ok
		next

	def FindByTag(cTag, aElements, aResults)
		for aElement in aElements
			if aElement[:type] = "element" and aElement[:name] = lower(cTag)
				aResults + aElement
			ok
			
			if aElement[:type] = "element"
				This.FindByTag(cTag, aElement[:children], aResults)
			ok
		next

	# Manipulation methods
	def CreateElement(cTagName, aAttributes, cInnerHtml)
		if not isString(cTagName)
			raise("Tag name must be a string")
		ok
		
		if not isList(aAttributes)
			aAttributes = []
		ok
		
		if not isString(cInnerHtml)
			cInnerHtml = ""
		ok
		
		aElement = [
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
			This.ParseElements(cInnerHtml, aElement[:children])
		ok
		
		return aElement

	def AppendChild(oParent, oChild)
		if not isObject(oParent) or not isObject(oChild)
			raise("Both parent and child must be elements")
		ok
		
		oParent[:children] + oChild
		oChild[:parent] = oParent
		
		return this

	def RemoveChild(oParent, oChild)
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

	def SetAttribute(aElement, cName, cValue)
		if not isObject(aElement)
			raise("Element must be an object")
		ok
		
		aAttributes = aElement[:attributes]
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

	def GetAttribute(aElement, cName)
		if not isObject(aElement)
			raise("Element must be an object")
		ok
		
		aAttributes = aElement[:attributes]
		nLen = len(aAttributes)

		for i = 1 to nLen step 2
			if aAttributes[i] = lower(cName)
				return aAttributes[i + 1]
			ok
		next
		
		return null

	def RemoveAttribute(aElement, cName)
		if not isObject(aElement)
			raise("Element must be an object")
		ok
		
		aAttributes = aElement[:attributes]
		nLen = len(aAttributes)

		for i = 1 to nLen step 2
			if aAttributes[i] = lower(cName)
				del(aAttributes, i)
				del(aAttributes, i)
				exit
			ok
		next
		
		return this

	def AddClass(aElement, cClass)
		if cClass = ""
			return
		ok

		cCurrentClass = This.GetAttribute(aElement, "class")

		if cCurrentClass = null
			cCurrentClass = ""
		ok
		
		aClasses = @split(cCurrentClass, " ")
		nLen = len(aClasses)

		# Check if class already exists

		for i = 1 to nLen
			if aClasses[i] = ""
				loop
			ok

			if aClasses[i] = cClass
				return this
			ok
		next
		
		aClasses + cClass
		cNewClass = @joinXT(aClasses, " ")
		This.setAttribute(aElement, "class", cNewClass)
		
		return this

	def RemoveClass(aElement, cClass)
		if cClass = ""
			return
		ok

		cCurrentClass = This.GetAttribute(aElement, "class")
		if cCurrentClass = null
			return this
		ok
		
		aClasses = @split(cCurrentClass, " ")
		aNewClasses = []
		nLen = len(aClasses)

		for i = 1 to nLen
			if aClasses[i] = ""
				loop
			ok
			if aClasses[i] != cClass
				aNewClasses + aClasses[i]
			ok
		next
		
		cNewClass = @joinXT(aNewClasses, " ")
		This.setAttribute(aElement, "class", cNewClass)
		
		return this

	def HasClass(aElement, cClass)
		cCurrentClass = This.GetAttribute(aElement, "class")
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
	def ToString()
		return This.GenerateHtml()

	def GenerateHtml()
		cHtml = ""
		
		# Add DOCTYPE
		if not isEmpty(@cDoctype)
			cHtml += @cDoctype + nl
		ok
		
		# Generate elements
		nLen = len(@aElements)

		for i = 1 to nLen
			cHtml += This.GenerateElement(@aElements[i], 0)
		next
		
		return cHtml

	def GenerateElement(aElement, nIndent)

		cHtml = ""
		cIndent = This.GetIndent(nIndent)
		
		switch aElement[:type]
		on "element"
			cHtml += cIndent + "<" + aElement[:name]
			
			# Add attributes
			aAttributes = aElement[:attributes]

			nLen = len(aAttributes)

			for i = 1 to nLen

				cHtml += ' ' + aAttributes[i][1] +
						'="' +
						aAttributes[i][2] + '"'
			next
			
			# Check if self-closing
			if NOT IsNull(aElement[:self_closing])
				cHtml += " />"
			else
				cHtml += ">"
				
				# Add children
				if len(aElement[:children]) > 0
					cHtml += nl
					nLenElm = len(aElement[:children])

					for j = 1 to nLenElm
						cHtml += This.GenerateElement(aElement[:children][j], nIndent + 1)
					next
					cHtml += cIndent
				ok
				
				cHtml += "</" + aElement[:name] + ">"
			ok
			
			cHtml += nl
		
		on "text"
			cContent = @trim(aElement[:content])
			if not isEmpty(cContent)
				cHtml += (cIndent + cContent + nl)
			ok
		
		on "comment"
			cHtml += (cIndent + "<!-- " + aElement[:content] + " -->" + nl)
		
		off
		
		return cHtml

	def GetIndent(nLevel)

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

	def FindClosingTag(cHtml, cTagName, nStart)
		nPos = nStart
		nOpenCount = 1

		nLen = len(cHtml)
		nLenTag = len(cTagName)

		while nPos <= nLen
			nOpenPos  = @substrXT([ cHtml, ("<" + cTagName), nPos ])
			nClosePos = @substrXT([ cHtml, ("</" + cTagName), nPos ])
			
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
	def SetConfig(cKey, value)
		@oConfig[cKey] = value
		return this

	def GetConfig(cKey)
		return @oConfig[cKey]

	# Validation methods
	def Validate()
		@aParseErrors = []
		
		if @oConfig[:Validate]
			This.ValidateElements(@aElements)
		ok
		
		return len(@aParseErrors) = 0

	def ValidateElements(aElements)

		nLen = len(aElements)

		for i = 1 to nLen
			if aElements[i][:type] = "element"
				This.ValidateElement(aElements[i])
				This.ValidateElements(aElements[i][:children])
			ok
		next

	def ValidateElement(aElement)

		cTagName = aElement[:name]
		
		# Check for required attributes
		switch cTagName

		on "img"

			if This.GetAttribute(aElement, "alt") = null
				@aParseErrors + "img element missing alt attribute"
			ok

		on "a"

			if This.GetAttribute(aElement, "href") = null
				@aParseErrors + "a element missing href attribute"
			ok
		off

	# Information methods
	def GetParseErrors()
		return @aParseErrors

	def IsParsed()
		return @bParsed

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

	def GetTextContent()
		return This.ExtractTextContent(@aElements)

	def ExtractTextContent(aElements)

		cText = ""
		nLen = len(aElements)

		for i = 1 to nLen

			if aElements[i][:type] = "text"
				cText += @@(aElements[i][:content])

			elseif aElements[i][:type] = "element"
				cText += This.ExtractTextContent(aElements[i][:children])
			ok
		next

		return cText

	# Pretty printing
	def pretty()
		@oConfig[:pretty_print] = true
		return This.GenerateHtml()

	def minify()
		@oConfig[:pretty_print] = false
		return This.GenerateHtml()

	# Debugging methods
	def Debug()
		? "=== stzHtml Debug Information ==="
		? "Parsed: " + @bParsed
		? "Element count: " + This.GetElementCount()
		? "Parse errors: " + len(@aParseErrors)
		if len(@aParseErrors) > 0
			for cError in @aParseErrors
				? "  - " + cError
			next
		ok
		? "=== End Debug Information ==="
