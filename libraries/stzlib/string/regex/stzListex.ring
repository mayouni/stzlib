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

	# The number @N pattern

	@cNumberPattern = '(?:-?\d+(?:\.\d+)?)'

	# The string @S pattern

	@cStringPattern = "(?:" + char(34) + "[^" + char(34) + "]*" + char(34) + "|\'[^\']*\')"

	# The list @L pattern

	@cSimpleListPattern = '\[\s*[^\[\]]*\s*\]'
	@cRecursiveListPattern = '\[\s*(?:[^\[\]]|\[(?:[^\[\]]|(?R))*\])*\s*\]'
	@cListPattern = @cSimpleListPattern  # Default to simple pattern

	# The @$ wildcard pattern

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

		# Dealing the specific cases like [ @N1-2, @N0-3 ] ~> [ @N0-5 ]

		nLen = len(@aTokens)

		if nLen > 1
			for i = nLen to 2 step -1

				if @aTokens[i][:keyword] = @aTokens[i-1][:keyword] and
				   @aTokens[i][:min] != @aTokens[i][:max] = 1 and
				   @aTokens[i-1][:min] != @aTokens[i-1][:max]

					nMin = @Min([ @aTokens[i][:min], @aTokens[i-1][:min] ])
					nMax = @aTokens[i][:max] + @aTokens[i-1][:max]

					del(@aTokens, nLen)
					@aTokens[i-1][:min] = nMin
					@aTokens[i-1][:max] = nMax

				ok
			next
		ok

	  #----------------------------#
	 #  PARSING THE LIST PATTERN  #
	#----------------------------#

	def ParsePattern(cPattern)

		# Remove outer brackets and trim

		oPattern = new stzString(cPattern)
		oPattern.TrimQ().RemoveTheseBoundsQ("[", "]").Trim()
		acChars = oPattern.chars()

		cInner = oPattern.Content()
        
		# Tokenization with error handling

		aTokens = []
		nStart = 1
		nLen = len(acChars)
		nDepth = 0
		cCurrentToken = ""

		for i = 1 to nLen
			cChar = acChars[i]
            
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
				aToken + [ "keyword", "@N" ]
				aToken + [ "type", "number" ]
				aToken + [ "pattern", @cNumberPattern ]
				nPrefixLen = 2
	
			case "@S"
				aToken + [ "keyword", "@S" ]
				aToken + [ "type", "string" ]
				aToken + [ "pattern", @cStringPattern ]
				nPrefixLen = 2
	
			case "@L"
				aToken + [ "keyword", "@L" ]
				aToken + [ "type", "list" ]
				aToken + [ "pattern", @cListPattern ]
				nPrefixLen = 2
	
			case "@$"
				aToken + [ "keyword", "@$" ]
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
		nLenElem = len(aElements)
		nLenTokens = len(aTokens)
		
		for i = 1 to nLenTokens
			aToken = aTokens[i]
			
			# Track elements matched by current token
	
			nCount = 0
			nStartIndex = nElementIndex
			
			# Handle each token's min-max requirements
	
			while nElementIndex <= nLenElem and nCount < aToken["max"]
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
				else
					# No match, stop trying with this token
					exit
				ok
			end
			
			# Check if we satisfied this token's min requirement
	
			if nCount < aToken["min"]
				return false
			ok
		next
		
		# Check if we consumed all elements
		# if not, the pattern didn't match the whole list
	
		if nElementIndex <= nLenElem
			return false
		ok
		
		return true

	def EscapeLiteral(cLiteral)
		aSpecials = [ "\", ".", "^", "$", "*", "+", "?", "(", ")", "[", "]", "{", "}", "|" ]
		nLenSpecials = len(aSpecials)
		cResult = cLiteral

		for i = 1 to nLenSpecials
			cResult = ring_substr2( cResult, aSpecials[i], ("\" + aSpecials[i]) )
		next

		return cResult

	def Tokens()
		return @aTokens

		def TokensXT()
			return @aTokens

		def MatchInfo()
			return @aTokens

	def Pattern()
		return @cDomainPattern

		def DomainPattern()
			return This.Pattern()
