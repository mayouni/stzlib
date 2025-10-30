# Softanza List Regex Engine - Enhanced Version

func StzListRegexQ(cPattern)
	return new stzListex(cPattern)

func StzListexQ(cPattern)
	return StzListRegexQ(cPattern)

func Lx(cPattern)
	return StzListRegexQ(cPattern)

class stzListex

	@cPattern		# The original pattern string
	@aTokens		# List of parsed token definitions
	@bDebugMode = false	# Debug mode flag

	# Cache system attributes
	@aMatchCache = []
	@nMaxCacheSize = 100

	# Regular expression patterns for various token types
	@cNumberPattern = '(?:-?\d+(?:\.\d+)?)'
	@cStringPattern = "(?:" + char(34) + "[^" + char(34) + "]*" + char(34) + "|\'[^\']*\')"
	@cSimpleListPattern = '\[\s*[^\[\]]*\s*\]'
	@cRecursiveListPattern = '\[\s*(?:[^\[\]]|\[(?:[^\[\]]|(?R))*\])*\s*\]'
	@cListPattern = @cSimpleListPattern
	@cAnyPattern = ""

	@cQuantifierPattern = '^([+*?])'
	@cSingleNumberPattern = '^(\d+)'
	@cRangePattern = '^(\d+)-(\d+)'
	@cSetPattern = '^(\{(.*?)\})'
	@cUniqueSetPattern = '^(\{(.*?)\})U'

	  #-------------------#
	 #  INITIALIZATION   #
	#-------------------#

	def init(cPattern)
		if NOT isString(cPattern)
			raise("Error: Pattern must be a string")
		ok

		@cAnyPattern = @cNumberPattern + "|" + @cStringPattern + "|" + @cListPattern
		@cPattern = This.NormalizePattern(cPattern)
		@aTokens = This.ParsePattern(@cPattern)
		This.OptimizeTokens()

	def NormalizePattern(cPattern)
		cPattern = @trim(cPattern)
		
		if NOT (StartsWith(cPattern, "[") and EndsWith(cPattern, "]"))
			cPattern = "[" + cPattern + "]"
		ok
		
		return cPattern

	def ParsePattern(cPattern)
		This.DebugLog("ParsePattern", "Input: " + cPattern)
		
		cInner = @trim( @substr( @trim(cPattern), 2, len(cPattern)-1 ) )
		aParts = SplitAtTopLevelCommas(cInner)

		aTokens = []
		for i = 1 to len(aParts)
			aTokens + This.ParseToken(@trim(aParts[i]))
		next

		This.DebugLog("ParsePattern", "Tokens created: " + len(aTokens))
		return aTokens

	def ParseNestedPattern(cNestedPattern, bNegated, bCaseSensitive)
		cInner = @substr(cNestedPattern, 2, len(cNestedPattern)-1)
		aNestedTokens = []
		aParts = SplitAtTopLevelCommas(cInner)

		for i = 1 to len(aParts)
			aToken = This.ParseToken(@trim(aParts[i]))
			# Inherit case sensitivity if not specified
			if NOT HasKey(aToken, "casesensitive")
				aToken + ["casesensitive", bCaseSensitive]
			ok
			aNestedTokens + aToken
		next

		nMin = 1
		nMax = 1
		nQuantifier = 1
    
		nLenNestPat = len(cNestedPattern)
		if nLenNestPat > 2
			cRest = Right(cNestedPattern, 1)
			oQMatch = rx(@cQuantifierPattern)
			if oQMatch.Match(cRest)
				aMatches = oQMatch.Matches()
				cQuantifier = aMatches[1]

				switch cQuantifier
				on "+"
					nMin = 1
					nMax = 999999999
				on "*"
					nMin = 0
					nMax = 999999999
				on "?"
					nMin = 0
					nMax = 1
				off
			else
				oNumberMatch = rx(@cSingleNumberPattern).Match(cRest)
				if oNumberMatch
					aMatches = oNumberMatch.Matches()
					nQuantifier = number(aMatches[1])
					nMin = nQuantifier
					nMax = nQuantifier
				ok
			ok
		ok
    
		aToken = [
			[ "keyword", "@NESTED" ],
			[ "type", "nested" ],
			[ "pattern", @cRecursiveListPattern ],
			[ "nestedTokens", aNestedTokens ],
			[ "min", nMin ],
			[ "max", nMax ],
			[ "quantifier", nQuantifier ],
			[ "hasset", false ],
			[ "setvalues", [] ],
			[ "requireunique", false ],
			[ "negated", bNegated ],
			[ "casesensitive", bCaseSensitive ]
		]
    
		return aToken

	def ParseAlternationToken(cTokenStr, bNegated, bCaseSensitive)
		aParts = @split(cTokenStr, "|")
		nLen = len(aParts)
		aAlternatives = []

		for i = 1 to nLen
			cPart = @trim(aParts[i])

			if bNegated and i = 1
				cPart = "@!" + cPart
			ok

			aToken = This.ParseToken(cPart)
			# Inherit case sensitivity if not specified
			if NOT HasKey(aToken, "casesensitive")
				aToken + ["casesensitive", bCaseSensitive]
			ok
			aAlternatives + aToken
		next
		
		aToken = [
			[ "keyword", "@ALT" ],
			[ "type", "alternation" ],
			[ "alternatives", aAlternatives ],
			[ "min", 1 ],
			[ "max", 1 ],
			[ "quantifier", 1 ],
			[ "hasset", false ],
			[ "setvalues", [] ],
			[ "requireunique", false ],
			[ "negated", bNegated ],
			[ "casesensitive", bCaseSensitive ]
		]
		
		return aToken

	def ParseToken(cTokenStr)
		This.DebugLog("ParseToken", "Input: " + cTokenStr)
		
		bNegated = FALSE
		bCaseSensitive = FALSE

		# Check for case-sensitive prefix @cs:
		if StartsWith(lower(cTokenStr), "@cs:")
			bCaseSensitive = TRUE
			cTokenStr = @substr(cTokenStr, 5, len(cTokenStr))
		ok

		# Extract set values BEFORE case conversion to preserve original values
		cPreservedSet = ""
		nSetStart = substr(cTokenStr, "{")
		if nSetStart > 0
			nSetEnd = substr(cTokenStr, "}")
			if nSetEnd > nSetStart
				cPreservedSet = @substr(cTokenStr, nSetStart, nSetEnd - nSetStart + 1)
			ok
		ok

		# Check for negation prefix
		if StartsWith(cTokenStr, "@!")
			bNegated = true
			cTokenStr = @subStr(cTokenStr, 3, len(cTokenStr))
		ok

		# Handle nested list patterns
		if StartsWith(cTokenStr, "[") and EndsWith(cTokenStr, "]")
			return This.ParseNestedPattern(cTokenStr, bNegated, bCaseSensitive)
		ok

		# Alternation handling
		if @Contains(cTokenStr, "|")
			return This.ParseAlternationToken(cTokenStr, bNegated, bCaseSensitive)
		ok

		# Ensure token starts with @
		if NOT StartsWith(cTokenStr, "@")
			cTokenStr = "@" + cTokenStr
		ok
    
		# Extract keyword (first two characters)
		cKeyword = @substr(cTokenStr, 1, 2)
		
		nMin = 1
		nMax = 1
		nQuantifier = 1
		aSetValues = []
		bRequireUnique = false

		cRemainder = ""
		nLenToken = stzlen(cTokenStr)

		if nLenToken > 2
			cRemainder = @substr(cTokenStr, 3, nLenToken)
		ok

		# Range and quantifier processing
		if len(cRemainder) > 0
			oRangeMatch = rx(@cRangePattern)

			if oRangeMatch.Match(cRemainder)
				acNumbers = @split(oRangeMatch.Matches()[1], "-")
				nMin = 0+ acNumbers[1]
				nMax = 0+ acNumbers[2]
			
				if nMin > nMax
					raise("Error: Invalid range - min value greater than max: " + cTokenStr)
				ok
        
				nRangeLen = len(acNumbers[1]) + 1 + len(acNumbers[2])
				cRemainder = right(cRemainder, len(cRemainder) - nRangeLen)

			else
				oQMatch = rx(@cQuantifierPattern)

				if oQMatch.Match(cRemainder)
					aMatches = oQMatch.Matches()
					cQuantifier = aMatches[1]

					switch cQuantifier
					on "+"
						nMin = 1
						nMax = 999999999
					on "*"
						nMin = 0
						nMax = 999999999
					on "?"
						nMin = 0
						nMax = 1
					off

					cRemainder = right(cRemainder, len(cRemainder) - 1)

				else
					oNumberMatch = rx(@cSingleNumberPattern)

					if oNumberMatch.Match(cRemainder)
						aMatches = oNumberMatch.Matches()
						nQuantifier = number(aMatches[1])
						nMin = nQuantifier
						nMax = nQuantifier
                
						cRemainder = right(cRemainder, len(cRemainder) - len(aMatches[1]))
					ok
				ok
			ok
		ok

		# Set constraints processing using preserved values
		if len(cPreservedSet) > 0
			# Check for {values}U format
			if EndsWith(cRemainder, "U") and substr(cRemainder, "{") > 0
				bRequireUnique = TRUE
				cPreservedSet = ring_substr2(cPreservedSet, "U", "")
			ok
			
			# Determine type for set parsing
			cType = "any"
			switch cKeyword
			on "@N"
				cType = "number"
			on "@S"
				cType = "string"
			on "@L"
				cType = "list"
			off
			
			aSetValues = This.ParseSetValues(cPreservedSet, cType, bRequireUnique)
		ok

		# Set token type based on keyword (ordered longest to shortest for future extensions)
		aToken = []

		switch cKeyword
		on "@N"
			aToken = [
				[ "keyword", "@N" ],
				[ "type", "number" ],
				[ "pattern", @cNumberPattern ]
			]
		on "@S"
			aToken = [
				[ "keyword", "@S" ],
				[ "type", "string" ],
				[ "pattern", @cStringPattern ]
			]
		on "@L"
			aToken = [
				[ "keyword", "@L" ],
				[ "type", "list" ],
				[ "pattern", @cListPattern ]
			]
		on "@$"
			aToken = [
				[ "keyword", "@$" ],
				[ "type", "any" ],
				[ "pattern", @cAnyPattern ]
			]
		off

		aToken + [ "min", nMin ]
		aToken + [ "max", nMax ]
		aToken + [ "quantifier", nQuantifier ]

		if len(aSetValues) > 0
			aToken + [ "hasset", true ]
			aToken + [ "setvalues", aSetValues ]
			aToken + [ "requireunique", bRequireUnique ]
		else
			aToken + [ "hasset", false ]
			aToken + [ "setvalues", [] ]
			aToken + [ "requireunique", false ]
		ok

		aToken + [ "negated", bNegated ]
		aToken + [ "casesensitive", bCaseSensitive ]

		This.DebugLog("ParseToken", "Type: " + cKeyword + " CaseSens: " + bCaseSensitive)
		return aToken

	def SplitAtTopLevelCommas(cStr)
		acParts = []
		cCurrent = ""
		nDepth = 0
		acChars = Chars(cStr)
		nLen = len(acChars)

		for i = 1 to nLen
			cChar = acChars[i]

			if cChar = "["
				nDepth++
				cCurrent += cChar
			but cChar = "]"
				nDepth--
				cCurrent += cChar
			but cChar = "," and nDepth = 0
				acParts + @trim(cCurrent)
				cCurrent = ""
			else
				cCurrent += cChar
			ok
		next

		if len(cCurrent) > 0
			acParts + @trim(cCurrent)
		ok

		return acParts

	  #--------------------#
	 #  PATTERN HANDLING  #
	#--------------------#

	def ParseSetValues(cSetContent, cType, bCheckUnique)
		cSetContent = ring_substr2(cSetContent, "{", "")
		cSetContent = ring_substr2(cSetContent, "}", "")

		aValues = []
		aParts = @split(cSetContent, ";")
		
		for i = 1 to len(aParts)
			cValue = @trim(aParts[i])
			
			if cValue = ""
				loop
			ok
			
			switch cType
			on "number"
				if rx("^(-?\d+(?:\.\d+)?)$").Match(cValue)
					nValue = @number(cValue)
					
					if bCheckUnique and @Contains(aValues, nValue)
						raise("Error: Duplicate value in unique set: " + cValue)
					ok
					
					aValues + nValue
				else
					raise("Error: Invalid number in set: " + cValue)
				ok

			on "string"
				# Don't call RemoveQuotes - just normalize quotes
				if (StartsWith(cValue, "'") and EndsWith(cValue, "'"))
					# Single quotes - convert to double
					cUnquoted = @substr(cValue, 2, len(cValue) - 1)
					cNormalizedValue = '"' + cUnquoted + '"'
				but (StartsWith(cValue, '"') and EndsWith(cValue, '"'))
					# Already double quoted
					cNormalizedValue = cValue
				else
					# No quotes - add double quotes
					cNormalizedValue = '"' + cValue + '"'
				ok

				if bCheckUnique
					# For uniqueness check, compare unquoted values
					cCheck1 = @substr(cNormalizedValue, 2, len(cNormalizedValue) - 1)
					for j = 1 to len(aValues)
						cCheck2 = @substr(aValues[j], 2, len(aValues[j]) - 1)
						if cCheck1 = cCheck2
							raise("Error: Duplicate value in unique set: " + cValue)
						ok
					next
				ok
				
				aValues + cNormalizedValue
				
			on "list"
				# Normalize list format - ensure spaces after commas
				cNormalized = This.NormalizeListString(cValue)
				
				if NOT (StartsWith(cValue, "[") and EndsWith(cValue, "]"))
					raise("Error: Invalid list format in set: " + cValue)
				ok
				
				if bCheckUnique and @Contains(aValues, cNormalized)
					raise("Error: Duplicate value in unique set: " + cValue)
				ok
				
				aValues + cNormalized
				
			on "any"
				if bCheckUnique and @Contains(aValues, cValue)
					raise("Error: Duplicate value in unique set: " + cValue)
				ok
				
				aValues + cValue
			off
		next
		
		return aValues

	def RemoveQuotes(cStr)
		if (StartsWith(cStr, "'") and EndsWith(cStr, "'")) or
		   (StartsWith(cStr, '"') and EndsWith(cStr, '"'))
			cResult = @substr(cStr, 2, len(cStr)-1)
			return cResult
		ok
		return cStr

	def OptimizeTokens()
		nLen = len(@aTokens)
		
		if nLen <= 1
			return
		ok
		
		for i = nLen to 2 step -1
			aToken1 = @aTokens[i-1]
			aToken2 = @aTokens[i]
			
			if aToken1[:keyword] = aToken2[:keyword] and
			   NOT aToken1[:hasset] and NOT aToken2[:hasset]
				
				if aToken1[:min] != aToken1[:max] and aToken2[:min] != aToken2[:max]
					nNewMin = @Min([ aToken1[:min], aToken2[:min] ])
					nNewMax = aToken1[:max] + aToken2[:max]
					
					@aTokens[i-1][:min] = nNewMin
					@aTokens[i-1][:max] = nNewMax
					del(@aTokens, i)
				ok
			ok
		next

	  #--------------------#
	 #   MATCHING LOGIC   #
	#--------------------#

	def Match(paList)
		if NOT isList(paList)
			return FALSE
		ok

		# Generate cache key BEFORE any modifications
		cListSig = This.ListSignature(paList)
		cCacheKey = @cPattern + "|" + cListSig
		
		# Check cache
		for i = 1 to len(@aMatchCache)
			if @aMatchCache[i][1] = cCacheKey
				This.DebugLog("Match", "Cache hit!")
				return @aMatchCache[i][2]
			ok
		next

		# Convert list elements (don't modify original)
		aElements = []
		nLen = len(paList)

		for i = 1 to nLen
			aElements + paList[i]
		next

		# Perform matching
		bResult = false
		try
			bResult = This.MatchTokensToElements(@aTokens, aElements)

		catch
			if @bDebugMode
				? "Error during matching: " + cCatchError
			ok
			bResult = false
		done
		
		# Store in cache AFTER computing result
		@aMatchCache + [cCacheKey, bResult]
		if len(@aMatchCache) > @nMaxCacheSize
			del(@aMatchCache, 1)
		ok
		
		return bResult

	def MatchTokensToElements(aTokens, aElements)
		nLenTokens = len(aTokens)
		nLenElements = len(aElements)
    
		return This.BacktrackMatch(aTokens, aElements, 1, 1, [])

	def BacktrackMatch(aTokens, aElements, nTokenIndex, nElementIndex, aUsedValues)
		nLenTokens = len(aTokens)
		nLenElements = len(aElements)

		if @bDebugMode
			? ">>> Backtrack: token#" + nTokenIndex + "/" + nLenTokens + 
			  " elem#" + nElementIndex + "/" + nLenElements
		ok

		# Base case: all tokens processed
		if nTokenIndex > nLenTokens
			bResult = (nElementIndex > nLenElements)
			if @bDebugMode
				? ">>> All tokens done. Elements consumed: " + bResult
			ok
			return bResult
		ok

		aToken = aTokens[nTokenIndex]
		
		if @bDebugMode
			? ">>> Token: " + aToken[:keyword] + " Type: " + aToken[:type] + 
			  " Min: " + aToken[:min] + " Max: " + aToken[:max]
		ok

		aLocalUsedValues = []
		for i = 1 to len(aUsedValues)
			aLocalUsedValues + aUsedValues[i]
		next

		# Alternation token handling
		if aToken[:keyword] = "@ALT"
			if @bDebugMode
				? ">>> Alternation token with " + len(aToken[:alternatives]) + " alternatives"
			ok
			
			for i = 1 to len(aToken[:alternatives])
				aAltTokens = aToken[:alternatives]
				aNewTokens = []

				for j = 1 to nTokenIndex - 1
					aNewTokens + aTokens[j]
				next

				aNewTokens + aAltTokens[i]

				for j = nTokenIndex + 1 to nLenTokens
					aNewTokens + aTokens[j]
				next

				if @bDebugMode
					? ">>> Trying alternative #" + i
				ok

				if This.BacktrackMatch(aNewTokens, aElements, nTokenIndex, nElementIndex, aLocalUsedValues)
					if @bDebugMode
						? ">>> Alternative #" + i + " MATCHED!"
					ok
					return true
				ok
			next

			if @bDebugMode
				? ">>> All alternatives FAILED"
			ok
			return false
		ok

		# Nested pattern handling
		if aToken[:keyword] = "@NESTED"
			nMin = @Min([aToken[:max], nLenElements - nElementIndex + 1])

			for nMatchCount = aToken[:min] to nMin
				bSuccess = TRUE
				nElemIdx = nElementIndex
				aLocalUsedValuesCopy = aLocalUsedValues

				for i = 1 to nMatchCount
					if nElemIdx > nLenElements
						bSuccess = false
 						exit
					ok

					xElement = aElements[nElemIdx]

					if NOT isList(xElement)
						bSuccess = false
						exit
					ok

					if aToken[:negated]
						bSuccess = false
						exit
					ok
                
					if NOT This.MatchTokensToElements(aToken[:nestedTokens], xElement)
						bSuccess = false
						exit
					ok

					nElemIdx++
				next

				if bSuccess
					if nTokenIndex = nLenTokens
						if nElemIdx = nLenElements + 1
							return true
						ok
					else
						if This.BacktrackMatch(aTokens, aElements, nTokenIndex + 1, nElemIdx, aLocalUsedValuesCopy)
							return TRUE
						ok
					ok
				ok
			next
        
			if aToken[:min] = 0
				if This.BacktrackMatch(aTokens, aElements, nTokenIndex + 1, nElementIndex, aLocalUsedValues)
					return TRUE
				ok
			ok
        
			return FALSE
		ok

		# Standard token handling
		# Calculate maximum matches possible
		nMaxPossible = nLenElements - nElementIndex + 1
		nMin = @Min([aToken[:max], nMaxPossible])

		if @bDebugMode
			? ">>> Will try match counts from " + aToken[:min] + " to " + nMin
		ok

		# Try different match counts from min to max
		for nMatchCount = aToken[:min] to nMin
			if @bDebugMode
				? ">>> Trying to match " + nMatchCount + " element(s)"
			ok
			
			bSuccess = true
			nElemIdx = nElementIndex
			aMatchedElements = []
			aLocalUsedValuesCopy = []
			
			# Copy used values
			for i = 1 to len(aLocalUsedValues)
				aLocalUsedValuesCopy + aLocalUsedValues[i]
			next

			# Try to match exactly nMatchCount elements
			for i = 1 to nMatchCount
				if nElemIdx > nLenElements
					if @bDebugMode
						? ">>> Ran out of elements"
					ok
					bSuccess = false
					exit
				ok

				xElement = aElements[nElemIdx]
				bMatched = false
            
				cElement = @@(xElement)

				if @bDebugMode
					? ">>> Checking element #" + nElemIdx + ": " + cElement
				ok

				# Pattern matching
				if aToken[:type] = "list"
					bMatched = rx(@cRecursiveListPattern).MatchRecursive(cElement)
				else
					bMatched = rx("^" + aToken[:pattern] + "$").Match(cElement)
				ok
				
				if @bDebugMode
					? ">>> Pattern match: " + bMatched
				ok
        
				# Apply negation
				if aToken[:negated]
					bMatched = NOT bMatched
					if @bDebugMode
						? ">>> After negation: " + bMatched
					ok
				ok
        
				if bMatched
					# Set constraint checking
					if aToken[:hasset]
						xElemValue = This.ConvertToType(cElement, aToken[:type])
						bInSet = false
						
						if @bDebugMode
							? ">>> Checking set constraint..."
							? ">>> Element value: " + xElemValue
							? ">>> Set values: " + @@(aToken[:setvalues])
						ok
						
						# Get case sensitivity setting
						bCaseSensitive = TRUE
						if HasKey(aToken, "casesensitive")
							bCaseSensitive = aToken[:casesensitive]
						ok

						for j = 1 to len(aToken[:setvalues])
							xSetValue = aToken[:setvalues][j]

							if This.CompareValues(xElemValue, xSetValue, aToken[:type], bCaseSensitive)
								bInSet = true
								if @bDebugMode
									? ">>> Found in set at position " + j
								ok
								exit
							ok
						next

						# Modify set check for negation
						if aToken[:negated]
							bInSet = NOT bInSet
						ok

						if @bDebugMode
							? ">>> In set: " + bInSet
						ok

						if NOT bInSet
							if @bDebugMode
								? ">>> FAILED: not in set"
							ok
							bSuccess = false
							exit
						ok
	                
						# Unique constraint for non-negated tokens
						if aToken[:requireunique] and NOT aToken[:negated]
							bDuplicate = FALSE
							
							if @bDebugMode
								? ">>> Checking uniqueness..."
								? ">>> Already used: " + @@(aLocalUsedValuesCopy)
							ok
							
							for j = 1 to len(aLocalUsedValuesCopy)
								if This.CompareValues(xElemValue, aLocalUsedValuesCopy[j], aToken[:type], bCaseSensitive)
									bDuplicate = TRUE
									if @bDebugMode
										? ">>> DUPLICATE found!"
									ok
									exit
								ok
							next
                        
							if bDuplicate
								bSuccess = false
								exit
							else
								aLocalUsedValuesCopy + xElemValue
								if @bDebugMode
									? ">>> Added to used values"
								ok
							ok
						ok
					ok

					aMatchedElements + xElement
					nElemIdx++
					
					if @bDebugMode
						? ">>> Element matched, moving to next"
					ok

				else
					# Match failed - this match count doesn't work
					if @bDebugMode
						? ">>> Element FAILED to match"
					ok
					bSuccess = false
					exit
				ok
			next

			# If we successfully matched nMatchCount elements
			if bSuccess
				if @bDebugMode
					? ">>> Successfully matched " + nMatchCount + " element(s)"
					? ">>> Now at element index: " + nElemIdx
				ok
				
				if nTokenIndex = nLenTokens
					# Last token - must consume all elements
					if nElemIdx = nLenElements + 1
						if @bDebugMode
							? ">>> FINAL MATCH - all elements consumed!"
						ok
						return true
					ok
					if @bDebugMode
						? ">>> Failed: " + (nLenElements - nElemIdx + 1) + " element(s) remaining"
					ok
					# else: didn't consume all elements, try next match count
				else
					# Not last token - try matching rest
					if @bDebugMode
						? ">>> Recursing to next token..."
					ok
					if This.BacktrackMatch(aTokens, aElements, nTokenIndex + 1, nElemIdx, aLocalUsedValuesCopy)
						if @bDebugMode
							? ">>> Recursion SUCCESS!"
						ok
						return true
                	ok
					if @bDebugMode
						? ">>> Recursion failed, trying next match count"
					ok
					# else: rest didn't match, try next match count
				ok
			ok
		next

		# All match counts failed
		# Only skip this token if it's optional (min=0)
		if aToken[:min] = 0
			if @bDebugMode
				? ">>> Token is optional, trying to skip..."
			ok
			if This.BacktrackMatch(aTokens, aElements, nTokenIndex + 1, nElementIndex, aLocalUsedValues)
				if @bDebugMode
					? ">>> Skip SUCCESS!"
				ok
				return true
			ok
		ok

		if @bDebugMode
			? ">>> Token COMPLETELY FAILED"
		ok
		return false

	def CompareValues(xValue1, xValue2, cType, bCaseSensitive)
		switch cType
		on "number"
			return xValue1 = xValue2

		on "string"
			cVal1 = This.RemoveQuotes("" + xValue1)
			cVal2 = This.RemoveQuotes("" + xValue2)
			
			if bCaseSensitive
				return cVal1 = cVal2
			else
				return lower(cVal1) = lower(cVal2)
			ok

		on "list"
			cVal1 = This.NormalizeListString("" + xValue1)
			cVal2 = This.NormalizeListString("" + xValue2)
			return cVal1 = cVal2

		on "any"
			if isNumber(xValue1) and isNumber(xValue2)
				return xValue1 = xValue2
			ok
        
			cVal1 = "" + xValue1
			cVal2 = "" + xValue2
			
			# Check if both are lists
			if ( StartsWith(cVal1, "[") and EndsWith(cVal1, "]") ) and
			   ( StartsWith(cVal2, "[") and EndsWith(cVal2, "]") )
				cVal1 = This.NormalizeListString(cVal1)
				cVal2 = This.NormalizeListString(cVal2)
				return cVal1 = cVal2
			ok
			
			# String comparison
			cVal1 = This.RemoveQuotes(cVal1)
			cVal2 = This.RemoveQuotes(cVal2)
			
			if bCaseSensitive
				return cVal1 = cVal2
			else
				return lower(cVal1) = lower(cVal2)
			ok
		off

	def NormalizeListString(xList)
		cList = "" + xList
		cList = @substr(cList, " ", "")
		cList = @substr(cList, Char(9), "")
		cList = @substr(cList, Char(10), "")
		cList = @substr(cList, Char(13), "")
		return cList

	def ConvertToType(cValue, cType)
		switch cType
		on "number"
			return @number(cValue)
		on "string"
			return cValue
		on "list"
			return cValue
		on "any"
			return cValue
		off

	  #---------------------------#
	 #     CACHE METHODS         #
	#---------------------------#

	def ListSignature(aList)
		cContent = @@(aList)
		nChecksum = 0
		nLen = len(cContent)
		
		for i = 1 to nLen
			nChecksum += ascii(cContent[i])
		next
		
		return "" + len(aList) + ":" + nChecksum

	def ClearCache()
		@aMatchCache = []
		return self

	def SetCacheSize(nSize)
		@nMaxCacheSize = nSize
		return self

	def CacheInfo()
		return [
			["entries", len(@aMatchCache)],
			["maxsize", @nMaxCacheSize]
		]

	  #---------------------------#
	 #     DEBUG METHODS         #
	#---------------------------#

	def DebugLog(cMethod, cMessage)
		if @bDebugMode
			? "=== " + cMethod + " ==="
			? cMessage
		ok

	def EnableDebug()
		@bDebugMode = true
		return self

	def DisableDebug()
		@bDebugMode = false
		return self

	def Tokens()
		return @aTokens

	def TokensInfo()
		aInfo = []
		
		for i = 1 to len(@aTokens)
			aToken = @aTokens[i]
			cInfo = "Token #" + i + ": " + aToken[:keyword]
			
			if aToken[:min] = aToken[:max]
				if aToken[:min] = 1
					# Default - no display
				else
					cInfo += aToken[:min]
				ok
			else
				cInfo += aToken[:min] + "-" + aToken[:max]
			ok
			
			if aToken[:hasset]
				cInfo += " {" + This.JoinSetValues(aToken[:setvalues]) + "}"
				
				if aToken[:requireunique]
					cInfo += "U"
				ok
			ok
			
			if HasKey(aToken, "casesensitive") and aToken[:casesensitive]
				cInfo += " [CS]"
			ok
			
			aInfo + cInfo
		next
		
		return aInfo

	def JoinSetValues(aValues)
		cResult = ""
		
		for i = 1 to len(aValues)
			if i > 1
				cResult += "; "
			ok
			cResult += "" + aValues[i]
		next
		
		return cResult

	def Pattern()
		return @cPattern

	def Explain()
		aInfo = [
			["Pattern", @cPattern],
			["TokenCount", len(@aTokens)],
			["CacheEntries", len(@aMatchCache)]
		]
		
		aTokenDetails = []
		for i = 1 to len(@aTokens)
			aToken = @aTokens[i]
			aTokenDetails + [
				["Index", i],
				["Keyword", aToken[:keyword]],
				["Type", aToken[:type]],
				["Min", aToken[:min]],
				["Max", aToken[:max]],
				["HasSet", aToken[:hasset]],
				["SetValues", aToken[:setvalues]],
				["Unique", aToken[:requireunique]],
				["Negated", aToken[:negated]],
				["CaseSensitive", iff(HasKey(aToken, "casesensitive"), aToken[:casesensitive], TRUE)]
			]
		next
		
		aInfo + ["Tokens", aTokenDetails]
		return aInfo

	  #---------------------------#
	 #     ALIAS METHODS         #
	#---------------------------#

	def Macth(pList)
		return This.Match(pList)

	def DomainPattern()
		return This.Pattern()

	def MatchInfo()
		return This.TokensInfo()

	def TokensXT()
		return This.Tokens()

	def ExplainXT()
		return This.Explain()
