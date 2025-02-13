# Softanza List Regex Engine
# Version 1.0.0

func StzListRegexQ(cPattern)
	return new stzListRegex(cPattern)

	func StzListexQ(cPattern)
		return StzListRegexQ(cPattern)

	func Lx(cPattern)
		return StzListRegexQ(cPattern)

class stzListex from stzListRegex
class stzListRegex

	@cDomainPattern    # The original DSL pattern
	@aTokens           # List of token definitions

	# Main types patterns

	@cNumberPattern = '(?:-?\d+(?:\.\d+)?)'
	@cStringPattern = "(?:" + char(34) + "[^" + char(34) + "]*" + char(34) + "|\'[^\']*\')"

	@cSimpleListPattern = '\[\s*[^\[\]]*\s*\]'
	@cRecursiveListPattern = '\[\s*(?:[^\[\]]|\[(?:[^\[\]]|(?R))*\])*\s*\]'
	@cListPattern = @cSimpleListPattern  # Default to simple pattern

	@cAnyPattern = @cNumberPattern + "|" + @cStringPattern + "|" + @cListPattern
    
    
	def init(cPattern)

		if NOT isString(cPattern)
			raise("Error: Pattern must be a string")
        	ok

		@cDomainPattern = @Trim(cPattern)

		if NOT (StartsWith(@cDomainPattern, "[") and EndsWith(@cDomainPattern, "]"))
			@cDomainPattern = "[" + @cDomainPattern + "]"
		ok

		@aTokens = This.ParsePattern(@cDomainPattern)

	  #----------------------------#
	 #  PARSING THE LIST PATTERN  #
	#----------------------------#

	def ParsePattern(cPattern)

		# Remove outer brackets and trim

		oPattern = new stzString(cPattern)
		oPattern.TrimQ().RemoveTheseBoundsQ("[", "]").Trim()
		cInner = oPattern.Content()
        
		# Tokenization with error handling

		aTokens = []
		nStart = 1
		nLen = oPattern.NumberOfChars()
		nDepth = 0
		cCurrentToken = ""

		for i = 1 to nLen
			cChar = oPattern.Char(i)
            
			switch cChar
			case "["
				nDepth++
				cCurrentToken += cChar
   
			case "]"
				nDepth--
				cCurrentToken += cChar
				if nDepth < 0
					raise("Error: Unmatched brackets in pattern")
				ok
                    
			case ","
				if nDepth = 0
					if len(cCurrentToken) > 0
						aTokens + This.ParseToken(@Trim(cCurrentToken))
						cCurrentToken = ""
					ok
				else
					cCurrentToken += cChar
				ok
                    
			other
				cCurrentToken += cChar
			off
		next
        
		# Add final token

		if len(cCurrentToken) > 0
			aTokens + This.ParseToken(@Trim(cCurrentToken))
		ok

		if nDepth != 0
			raise("Error: Unmatched brackets in pattern")
		ok
   
		return aTokens

	  #---------------------------------------#
	 #  PARSING A TOKEN IN THE LIST PATTERN  #
	#---------------------------------------#

	def ParseToken(cTokenStr)
		aToken = []
		oTokenStr = new stzString(cTokenStr)
	
		if StartsWith(cTokenStr, "@")
			cKeyword = oTokenStr.Section(1, 2)
	
			switch cKeyword
			case "@N"
				aToken + [ "type", "number" ]
				aToken + [ "pattern", @cNumberPattern ]
				nPrefixLen = 2
	
			case "@S"
				aToken + [ "type", "string" ]
				aToken + [ "pattern", @cStringPattern ]
				nPrefixLen = 2
	
			case "@L"
				aToken + [ "type", "list" ]
				aToken + [ "pattern", @cListPattern ]
				nPrefixLen = 2
	
			case "@A"
				aToken + [ "type", "any" ]
				aToken + [ "pattern", @cAnyPattern ]
				nPrefixLen = 2
	                    
			other
				raise("Error: Unknown token type: " + cTokenStr)
			off
	           
			nLenToken = oTokenStr.NumberOfChars()
			if nLenToken = 2
				aToken + [ "min", 1 ]
				aToken + [ "max", 1 ]
			else
				cModifier = oTokenStr.Right(nLenToken - 2)

				switch cModifier
				case "+"
					aToken + [ "min", 1 ]
					aToken + [ "max", RingMaxNumber() ]
	                        
				case "*"
					aToken + [ "min", 0 ]
					aToken + [ "max", RingMaxNumber() ]
	                        
				case "?"
					aToken + [ "min", 0 ]
					aToken + [ "max", 1 ]
	                        
				other
					if rx("^\d+$").Match(cModifier)
						nCount = number(cModifier)
						aToken + [ "min", nCount ]
						aToken + [ "max", nCount ]
		
					else
						rx = rx("^(\d+)-(\d+)$")
						bMatch = rx.Match(cModifier)
		
						if bMatch
							aMatches = rx.Matches()
							nMin = number(aMatches[1])
							nMax = number(aMatches[2])
		                            
							if nMin > nMax
								raise("Error: Invalid range in quantifier: " + cModifier)
							ok
		                            
							aToken + [ "min", nMin ]
							aToken + [ "max", nMax ]
						else
							raise("Error: Invalid quantifier: " + cModifier)
						ok
					ok
				off
			ok
		else
			aToken + [ "type", "literal" ]
			aToken + [ "pattern", This.EscapeLiteral(cTokenStr) ]
			aToken + [ "min", 1 ]
			aToken + [ "max", 1 ]
		ok
	
		return aToken
	
	  #-------------------------------#
	 #  EXECUTING THE REGEX MATCHES  #
	#-------------------------------#

	def Match(pList)
		if NOT isList(pList)
			return false
		ok

		# Stringifiying the list

		aElements = []
		nLenList = len(pList)
		for i = 1 to nLenList
			aElements + @@(pList[i])
		next

		# Trying the macth

		try
			return This.MatchTokensToElements(@aTokens, aElements)
		catch
			raise("Error during list matching!")
		done

		#< @FunctionMisspelledForm

		def Macth(pList)
			return This.Match(pList)

		#>

	def MatchTokensToElements(aTokens, aElements)
		nElementIndex = 1
		nCurrentDepth = 0
		nLenElem = len(aElements)
		nLenTokens = len(aTokens)
	
		for i = 1 to nLenTokens
			aToken = aTokens[i]

			nCount = 0
			nStartIndex = nElementIndex  # Track where this token started matching
	
			while nElementIndex <= nLenElem
				cElement = aElements[nElementIndex]

				bMatch = false

				if aToken["type"] = "list"

					# Try simple pattern first
					if rx(@cSimpleListPattern).Match(cElement)
						bMatch = true
					ok

					if bMatch = false
						# If simple fails, try recursive
						bMatch = rx(@cRecursiveListPattern).MatchRecursive(cElement)
					ok

				else
					bMatch = rx("^" + aToken["pattern"] + "$").Match(cElement)
				ok

				if bMatch
					nCount++
					nElementIndex++
	                    
					if nCount = aToken["max"]
						exit
					ok
				else
					# If we haven't met minimum count, backtrack
					if nCount < aToken["min"]
						nElementIndex = nStartIndex
						return false
					ok
					exit
				ok
			end
	            
			if nCount < aToken["min"] or nCount > aToken["max"]
				return false
			ok
	            
			nCurrentDepth++
		next

		return true

	def EscapeLiteral(cLiteral)
		aSpecials = [ "\", ".", "^", "$", "*", "+", "?", "(", ")", "[", "]", "{", "}", "|" ]
		nLenSpecials = len(aSpecials)
		cResult = cLiteral

		for i = 1 to nLenSpecials
			cResult = ring_substr2( cResult, aSpecials[i], ("\" + aSpecials[i]) )
		next

		return cResult

	# Additional helper methods

	def Tokens()
		return @aTokens

	def TokensXT()
		return Association([ @aTokens, @aElements ])

		def MatchInfo()
			return This.TokensXT()

	def Pattern()
		return @cDomainPattern

		def DomainPattern()
			return This.Pattern()
