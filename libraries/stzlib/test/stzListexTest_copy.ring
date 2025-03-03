# Softanza List Regex Engine
# Version 2.0.0

#====================================================#
#     LIST REGEX ENGINE - SIMPLIFIED FRONT-ENDS      #
#====================================================#

func StzListRegexQ(cPattern)
	return new stzListRegex(cPattern)

func StzListexQ(cPattern)
	return StzListRegexQ(cPattern)

func Lx(cPattern)
	return StzListRegexQ(cPattern)

#====================================================#
#             LIST REGEX ENGINE - CORE               #
#====================================================#

class stzListex
	#---------------------------#
	#     ATTRIBUTES            #
	#---------------------------#

	@cPattern          # The original pattern string
	@aTokens           # List of parsed token definitions
	@bDebugMode = false # Debug mode flag

	# Regular expression patterns for various token types
	@cNumberPattern = '(?:-?\d+(?:\.\d+)?)'
	@cStringPattern = "(?:" + char(34) + "[^" + char(34) + "]*" + char(34) + "|\'[^\']*\')"
	@cSimpleListPattern = '\[\s*[^\[\]]*\s*\]'
	@cRecursiveListPattern = '\[\s*(?:[^\[\]]|\[(?:[^\[\]]|(?R))*\])*\s*\]'
	@cListPattern = @cSimpleListPattern  # Default to simple pattern
	@cAnyPattern = "" # Will be set in init()

	#---------------------------#
	#     INITIALIZATION        #
	#---------------------------#

	def init(cPattern)
		if NOT isString(cPattern)
			raise("Error: Pattern must be a string")
		ok

		# Initialize @cAnyPattern as the combination of all patterns
		@cAnyPattern = @cNumberPattern + "|" + @cStringPattern + "|" + @cListPattern

		# Normalize the pattern by ensuring it has outer brackets
		@cPattern = This.NormalizePattern(cPattern)
		
		# Parse the pattern into tokens
		@aTokens = This.ParsePattern(@cPattern)
		
		# Optimize the token sequence if possible
		This.OptimizeTokens()

	#---------------------------#
	#     PATTERN HANDLING      #
	#---------------------------#

	def NormalizePattern(cPattern)
		cPattern = @trim(cPattern)
		
		# Ensure pattern is enclosed in square brackets
		if NOT (StartsWith(cPattern, "[") and EndsWith(cPattern, "]"))
			cPattern = "[" + cPattern + "]"
		ok
		
		return cPattern

	def ParsePattern(cPattern)
		# Remove outer brackets and trim
		oPattern = new stzString(cPattern)
		oPattern.TrimQ().RemoveFirstAndLastCharsQ().Trim()
		cInner = oPattern.Content()
		acChars = oPattern.Chars()
		
		# Tokenization with depth tracking for nested structures
		aTokens = []
		nDepth = 0
		cCurrentToken = ""
		nLen = len(acChars)
		
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
					raise("Error: Unmatched closing bracket in pattern")
				ok
				
			case ","
				if nDepth = 0
					# Top-level comma separates tokens
					if len(cCurrentToken) > 0
						aTokens + This.ParseToken(@trim(cCurrentToken))
						cCurrentToken = ""
					ok
				else
					# Nested comma is part of the token
					cCurrentToken += cChar
				ok
				
			other
				cCurrentToken += cChar
			off
		next
		
		# Add the final token if any
		if len(cCurrentToken) > 0
			aTokens + This.ParseToken(@trim(cCurrentToken))
		ok
		
		if nDepth != 0
			raise("Error: Unmatched opening bracket in pattern")
		ok
		
		return aTokens

	def ParseToken(cTokenStr)

		aToken = []
		
		if NOT StartsWith(cTokenStr, "@")
			raise("Error: Token must start with @ symbol: " + cTokenStr)
		ok
		
		oTokenStr = new stzString(cTokenStr)
		
		# Extract keyword (first two characters)
		cKeyword = oTokenStr.Section(1, 2)

		# Set basic token properties based on keyword type
		switch cKeyword
		on "@N"
			aToken + [ "keyword", "@N" ]
			aToken + [ "type", "number" ]
			aToken + [ "pattern", @cNumberPattern ]
			
		on "@S"
			aToken + [ "keyword", "@S" ]
			aToken + [ "type", "string" ]
			aToken + [ "pattern", @cStringPattern ]
			
		on "@L"
			aToken + [ "keyword", "@L" ]
			aToken + [ "type", "list" ]
			aToken + [ "pattern", @cListPattern ]
			
		on "@$"
			aToken + [ "keyword", "@$" ]
			aToken + [ "type", "any" ]
			aToken + [ "pattern", @cAnyPattern ]
			
		other
			raise("Error: Unknown token type: " + cKeyword)
		off


		# Default values
		nMin = 1
		nMax = 1
		aSetValues = []
		bRequireUnique = false
		
		# Get remainder after keyword
		cRemainder = ""
		nLenToken = oTokenStr.NumberOfChars()
		
		if nLenToken > 2
			cRemainder = oTokenStr.Section(3, nLenToken)
		ok

		# Process quantifiers if present
		if len(cRemainder) > 0
			# Check for +, *, ? quantifiers first
			oQMatch = rx('^([+*?])')
			if oQMatch.Match(cRemainder)
				aMatches = oQMatch.Matches()
				cQuantifier = aMatches[1]
				
				switch cQuantifier
				on "+"
					nMin = 1
					nMax = 999999999  # Effectively unlimited
				on "*"
					nMin = 0
					nMax = 999999999  # Effectively unlimited
				on "?"
					nMin = 0
					nMax = 1
				off
				
				cRemainder = right(cRemainder, len(cRemainder) - 1)
			else
				# Check for numeric ranges like 1-3
				oRangeMatch = rx('^(\d+)(?:-(\d+))?')
				if oRangeMatch.Match(cRemainder)
					aMatches = oRangeMatch.Matches()
					
					if len(aMatches) >= 2
						nMin = number(aMatches[1])
						
						if len(aMatches) >= 3 and aMatches[2] != ""
							nMax = number(aMatches[2])
							if nMin > nMax
								raise("Error: Invalid range - min value greater than max: " + cTokenStr)
							ok
							
							# Calculate length of the range portion: n-m
							nRangeLen = len(aMatches[1]) + 1 + len(aMatches[2])
							cRemainder = right(cRemainder, len(cRemainder) - nRangeLen)
						else
							# Single number quantifier: n
							nMax = nMin
							cRemainder = right(cRemainder, len(cRemainder) - len(aMatches[1]))
						ok
					ok
				ok
			ok
		ok

		# Process set constraints if present
		if len(cRemainder) > 0
			# Check for {values}U format (set with uniqueness constraint)
			oUniqueSetMatch = rx('^(\{(.*?)\})U')
			if oUniqueSetMatch.Match(cRemainder)
				aMatches = oUniqueSetMatch.Matches()
				cSetContent = aMatches[2]
				
				# Parse the set values with uniqueness enforcement
				aSetValues = This.ParseSetValues(cSetContent, aToken["type"], true)
				bRequireUnique = true
				
				# Remove the processed part from remainder
				nSetLen = len(aMatches[1]) + 1 # +1 for the U
				cRemainder = right(cRemainder, len(cRemainder) - nSetLen)
			else
				# Check for {values} format (regular set)
				oSetMatch = rx('^(\{(.*?)\})')
				if oSetMatch.Match(cRemainder)
					aMatches = oSetMatch.Matches()
					cSetContent = aMatches[2]
					
					# Parse the set values
					aSetValues = This.ParseSetValues(cSetContent, aToken["type"], false)
					
					# Remove the processed part from remainder
					nSetLen = len(aMatches[1])
					cRemainder = right(cRemainder, len(cRemainder) - nSetLen)
				ok
			ok
		ok

		if len(cRemainder) > 0
			# Check for a number after the key (example @N2)
			oNumberPattern = rx(@cNumberPattern)
			if oNumberPattern.Match(cRemainder)
? "okk!!!"
			ok
		ok

		# If there is still content in cRemainder, it's unexpected
		if len(cRemainder) > 0
			raise("Error: Unexpected content in token: " + cRemainder)
		ok
		
		# Add the processed information to the token
		aToken + [ "min", nMin ]
		aToken + [ "max", nMax ]
		
		if len(aSetValues) > 0
			aToken + [ "hasset", true ]
			aToken + [ "setvalues", aSetValues ]
			aToken + [ "requireunique", bRequireUnique ]
		else
			aToken + [ "hasset", false ]
			aToken + [ "setvalues", [] ]
			aToken + [ "requireunique", false ]
		ok
		
		return aToken

	def ParseSetValues(cSetContent, cType, bCheckUnique)
		aValues = []
		
		# Split by semicolons
		aParts = @split(cSetContent, ";")
		
		for i = 1 to len(aParts)
			cValue = @trim(aParts[i])
			
			if cValue = ""
				loop # Skip empty values
			ok
			
			switch cType
			on "number"
				if rx("^(-?\d+(?:\.\d+)?)$").Match(cValue)
					nValue = @number(cValue)
					
					# Check for uniqueness if required
					if bCheckUnique and @Contains(aValues, nValue)
						raise("Error: Duplicate value in unique set: " + cValue)
					ok
					
					aValues + nValue
				else
					raise("Error: Invalid number in set: " + cValue)
				ok
				
			on "string"
				# For strings, remove quotes
				if (StartsWith(cValue, "'") and EndsWith(cValue, "'")) or
				   (StartsWith(cValue, '"') and EndsWith(cValue, '"'))
					cValue = new stzString(cValue).FirstAndLastCharsRemoved().Content()
				ok
				
				# Check for uniqueness if required
				if bCheckUnique and @Contains(aValues, cValue)
					raise("Error: Duplicate value in unique set: " + cValue)
				ok
				
				aValues + cValue
				
			on "list"
				# For lists, keep the brackets
				if NOT (StartsWith(cValue, "[") and EndsWith(cValue, "]"))
					raise("Error: Invalid list format in set: " + cValue)
				ok
				
				# Check for uniqueness if required
				if bCheckUnique and @Contains(aValues, cValue)
					raise("Error: Duplicate value in unique set: " + cValue)
				ok
				
				aValues + cValue
				
			on "any"
				# Any type can be in the set
				if bCheckUnique and @Contains(aValues, cValue)
					raise("Error: Duplicate value in unique set: " + cValue)
				ok
				
				aValues + cValue
			off
		next
		
		return aValues

	def OptimizeTokens()
		# This method performs optimizations on the token sequence
		# For now, it just merges adjacent tokens of the same type
		# with min-max constraints
		
		nLen = len(@aTokens)
		
		if nLen <= 1
			return # Nothing to optimize
		ok
		
		for i = nLen to 2
			aToken1 = @aTokens[i-1]
			aToken2 = @aTokens[i]
			
			# Check if tokens can be merged (same keyword, no sets, adjacent ranges)
			if aToken1[:keyword] = aToken2[:keyword] and
			   NOT aToken1[:hasset] and NOT aToken2[:hasset]
				
				# If both tokens have min-max ranges, try to merge them
				if aToken1[:min] != aToken1[:max] and aToken2[:min] != aToken2[:max]
					nNewMin = @Min([ aToken1[:min], aToken2[:min] ])
					nNewMax = aToken1[:max] + aToken2[:max]
					
					# Update the first token and remove the second
					@aTokens[i-1][:min] = nNewMin
					@aTokens[i-1][:max] = nNewMax
					del(@aTokens, i)
				ok
			ok
		next

	#---------------------------#
	#     MATCHING LOGIC        #
	#---------------------------#

	def Match(pList)
		if NOT isList(pList)
			return false
		ok
		
		# Convert the list to string representations for matching

		aElements = []
		nLen = len(pList)
		
		for i = 1 to nLen
			aElements + @@(pList[i])
		next

		# Perform the matching
		try
			bResult = This.MatchTokensToElements(@aTokens, aElements)
			return bResult

		catch
			if @bDebugMode
				? "Error during matching: " + cError
			ok
			return false
		done

	def MatchTokensToElements(aTokens, aElements)
		nElementIndex = 1
		nLenElements = len(aElements)
		nLenTokens = len(aTokens)
		
		# Process each token in sequence
		for i = 1 to nLenTokens
			aToken = aTokens[i]
			
			# Track matched elements and values for this token
			nMatchCount = 0
			aMatchedValues = []
			
			# Try to match elements against this token
			while nElementIndex <= nLenElements and nMatchCount < aToken[:max]
				cElement = aElements[nElementIndex]
				bMatched = false
				
				# Check if element matches the token's pattern
				if aToken[:type] = "list"
					# For lists, check both simple and potentially recursive patterns
					if rx(@cSimpleListPattern).Match(cElement)
						bMatched = true
					else
						# Attempt recursive matching for nested lists
						try
							bMatched = This.MatchListRecursively(cElement)
						catch
							bMatched = false
						done
					ok
				else
					# For non-list types, use regex pattern matching
					bMatched = rx("^" + aToken[:pattern] + "$").Match(cElement)
				ok
				
				if bMatched
					# Element matches the pattern, now check set constraints if any
					bAccept = true
					
					if aToken[:hasset]
						# Convert element to appropriate type for comparison
						xValue = This.ConvertToType(cElement, aToken[:type])
						
						# Check if value is in the allowed set
						if NOT @Contains(aToken[:setvalues], xValue)
							bAccept = false
						else
							# For unique sets, check if we've already matched this value
							if aToken[:requireunique] and @Contains(aMatchedValues, xValue)
								bAccept = false
							ok
						ok
					ok
					
					if bAccept
						# Accept this element
						if aToken[:hasset] and aToken[:requireunique]
							aMatchedValues + This.ConvertToType(cElement, aToken[:type])
						ok
						
						nMatchCount++
						nElementIndex++
					else
						# Value not in set or duplicate in unique set
						exit
					ok
				else
					# Element doesn't match pattern
					exit
				ok
			end
			
			# Check if we've satisfied the minimum requirement for this token
			if nMatchCount < aToken[:min]
				return false
			ok
		next
		
		# Success if we've consumed all elements
		return nElementIndex > nLenElements

	def MatchListRecursively(cList)
		# Simple implementation of recursive list matching
		# This is a placeholder that could be expanded for more complex cases
		
		if NOT (StartsWith(cList, "[") and EndsWith(cList, "]"))
			return false
		ok
		
		# Count bracket depth
		acChars = new stzString(cList).Chars()
		nDepth = 0
		
		for i = 1 to len(acChars)
			if acChars[i] = "["
				nDepth++
			but acChars[i] = "]"
				nDepth--
				if nDepth < 0
					return false # Unbalanced brackets
				ok
			ok
		next
		
		return nDepth = 0 # All brackets balanced

	def ConvertToType(cValue, cType)
		# Convert a string value to the appropriate type for comparison
		
		switch cType
		on "number"
			return @number(cValue)
			
		on "string"
			# Strip quotes if present
			if (StartsWith(cValue, "'") and EndsWith(cValue, "'")) or
			   (StartsWith(cValue, '"') and EndsWith(cValue, '"'))
				return new stzString(cValue).FirstAndLastCharsRemoved().Content()
			ok
			return cValue
			
		on "list"
			# Keep as is
			return cValue
		on "any"
			# Keep as is
			return cValue
		off
		
		return cValue # Default fallback

	#---------------------------#
	#     DEBUG METHODS         #
	#---------------------------#

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
					# Default - no need to show
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
