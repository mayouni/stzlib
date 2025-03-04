# Softanza List Regex Engine

func StzListRegexQ(cPattern)
	return new stzListRegex(cPattern)

func StzListexQ(cPattern)
	return StzListRegexQ(cPattern)

func Lx(cPattern)
	return StzListRegexQ(cPattern)

#==================================#
#  LIST REGEX ENGINE - CORE CLASS  #
#==================================#

class stzListex

	@cPattern		# The original pattern string
	@aTokens		# List of parsed token definitions
	@bDebugMode = false	# Debug mode flag

	# Regular expression patterns for various token types

	@cNumberPattern = '(?:-?\d+(?:\.\d+)?)'
	@cStringPattern = "(?:" + char(34) + "[^" + char(34) + "]*" + char(34) + "|\'[^\']*\')"
	@cSimpleListPattern = '\[\s*[^\[\]]*\s*\]'
	@cRecursiveListPattern = '\[\s*(?:[^\[\]]|\[(?:[^\[\]]|(?R))*\])*\s*\]'
	@cListPattern = @cSimpleListPattern  # Default to simple pattern
	@cAnyPattern = "" # Will be set in init()

	  #-------------------#
	 #  INITIALIZATION   #
	#-------------------#

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

	  #--------------------#
	 #  PATTERN HANDLING  #
	#--------------------#

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
		# NOTE
		# The token parsing follows this sequence:
		# - First check for range quantifiers (n-m)
		# - Then check for simple quantifiers (+, *, ?)
		# - Then check for single number quantifiers (n)
		# - Then process set constraints

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
		nQuantifier = 1  # Default quantifier
		aSetValues = []
		bRequireUnique = false
		
		# Get remainder after keyword

		cRemainder = ""
		nLenToken = oTokenStr.NumberOfChars()
		
		if nLenToken > 2
			cRemainder = oTokenStr.Section(3, nLenToken)
		ok

		# First check for range quantifiers like 1-3 or standard quantifiers +, *, ?

		if len(cRemainder) > 0

			# Check for explicit range pattern like "1-3"

			oRangeMatch = rx('^(\d+)-(\d+)')

			if oRangeMatch.Match(cRemainder)
				aMatches = oRangeMatch.Matches()
				nMin = number(aMatches[1])
				nMax = number(aMatches[2])
				
				if nMin > nMax
					raise("Error: Invalid range - min value greater than max: " + cTokenStr)
				ok
				
				# Remove the processed range from remainder
				nRangeLen = len(aMatches[1]) + 1 + len(aMatches[2])  # +1 for the "-"
				cRemainder = right(cRemainder, len(cRemainder) - nRangeLen)

			else
				# Check for +, *, ? quantifiers

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

					# Check for a single number quantifier

					oNumberMatch = rx('^(\d+)')

					if oNumberMatch.Match(cRemainder)
						aMatches = oNumberMatch.Matches()
						nQuantifier = number(aMatches[1])
						nMin = nQuantifier
						nMax = nQuantifier
						
						# Remove the processed quantifier from remainder
						cRemainder = right(cRemainder, len(cRemainder) - len(aMatches[1]))
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

		# If there is still content in cRemainder, it's unexpected

		if len(cRemainder) > 0
			raise("Error: Unexpected content in token: " + cRemainder)
		ok
		
		# Add the processed information to the token

		aToken + [ "min", nMin ]
		aToken + [ "max", nMax ]
		aToken + [ "quantifier", nQuantifier ]  # Store the explicit quantifier if any
		
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

				# For strings, normalize quoted values

				if (StartsWith(cValue, "'") and EndsWith(cValue, "'")) or
				   (StartsWith(cValue, '"') and EndsWith(cValue, '"'))

					# Store with quotes for pattern matching
					cNormalizedValue = cValue

				else
					# Add quotes for consistency
					cNormalizedValue = '"' + cValue + '"'
				ok

				# Check for uniqueness if required

				if bCheckUnique
					cUnquotedValue = This.RemoveQuotes(cValue)
					
					for j = 1 to len(aValues)
						if This.RemoveQuotes(aValues[j]) = cUnquotedValue
							raise("Error: Duplicate value in unique set: " + cValue)
						ok
					next
				ok
				
				aValues + cNormalizedValue
				
			on "list"

				# For lists, keep the brackets and format

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

	# Helper method to remove quotes from string

	def RemoveQuotes(cStr)
		if (StartsWith(cStr, "'") and EndsWith(cStr, "'")) or
		   (StartsWith(cStr, '"') and EndsWith(cStr, '"'))
			return StzStringQ(cStr).FirstAndLastCharsRemoved()
		ok
		return cStr

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

	  #--------------------#
	 #   MATCHING LOGIC   #
	#--------------------#

	def Match(pList)

		if NOT isList(pList)
			return false
		ok
		
		# Convert the list to string representations for matching

		aElements = []
		nLen = len(pList)
		
		for i = 1 to nLen

			aElements + @@(pList[i])
			# ~> @@() Converts any Ring type, including lists,
			# to a string representation. Examples:
			# ? @@(24) --> "24"
			# ? @@("Hello") --> "Hello"
			# ? @@("'Hello'") --> "Hello"
			# ? @@([ 1, "A" ]) --> '[ 1, "A" ]'
			# ? @@( [ 1 , "A", [ "B", 2 ] ] ) --> '[ 1 , "A", [ "B", 2 ] ]'
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

		nLenTokens = len(aTokens)
		nLenElements = len(aElements)
		
		# Use backtracking to find valid matches

		return This.BacktrackMatch(aTokens, aElements, 1, 1, [])


	def BacktrackMatch(aTokens, aElements, nTokenIndex, nElementIndex, aUsedValues)
		nLenTokens = len(aTokens)
		nLenElements = len(aElements)

		# Base case: If we've processed all tokens

		if nTokenIndex > nLenTokens
			# Success if we've consumed all elements
			return nElementIndex > nLenElements
		ok
    
		# Get current token

		aToken = aTokens[nTokenIndex]
    
		# Create local copy of used values for uniqueness tracking

		aLocalUsedValues = []

		for i = 1 to len(aUsedValues)
			aLocalUsedValues + aUsedValues[i]
		next
    
		# Try different match counts within min-max range
		# Start from the minimum and try up to the maximum allowed

		for nMatchCount = aToken[:min] to @Min([aToken[:max], nLenElements - nElementIndex + 1])

			# Try to match this number of elements

			bSuccess = true
			nElemIdx = nElementIndex
			aMatchedElements = []
			aLocalUsedValuesCopy = aLocalUsedValues
        
			# Attempt to match exactly nMatchCount elements

			for i = 1 to nMatchCount

				if nElemIdx > nLenElements
					bSuccess = false
					exit
				ok
            
				cElement = aElements[nElemIdx]
      
				# Check element matches token pattern

				bMatched = false
            
				if aToken[:type] = "list"

					# List pattern matching
					bMatched = rx(@cRecursiveListPattern).MatchRecursive(cElement)

				else
					# Regular pattern matching
					bMatched = rx("^" + aToken[:pattern] + "$").Match(cElement)

				ok
            
				if bMatched

					# Element matches pattern, now check set constraints

					if aToken[:hasset]

						# Convert element to appropriate type for set comparison
						xElemValue = This.ConvertToType(cElement, aToken[:type])

						# Check if value is in the allowed set
						bInSet = false

						for j = 1 to len(aToken[:setvalues])

							xSetValue = aToken[:setvalues][j]
							if This.CompareValues(xElemValue, xSetValue, aToken[:type])
								bInSet = true
								exit
							ok
						next
                    
						if NOT bInSet
							bSuccess = false
							exit
						ok
                    
						# For unique constraints, check if already matched

						if aToken[:requireunique]

							for j = 1 to len(aLocalUsedValuesCopy)
								if This.CompareValues(xElemValue, aLocalUsedValuesCopy[j], aToken[:type])
									bSuccess = false
									exit
								ok
							next
                        
							if bSuccess
								aLocalUsedValuesCopy + xElemValue

							else
								exit
							ok
						ok
					ok
                
					# Element matched this token

					aMatchedElements + cElement
					nElemIdx++

				else
               				 # Element doesn't match pattern
               				 bSuccess = false
                			exit
           		 	ok
        		next

			if bSuccess

				# This token matched successfully, try next token

				if This.BacktrackMatch(aTokens, aElements, nTokenIndex + 1, nElemIdx, aLocalUsedValuesCopy)
					return true
				ok
            
				# If the recursive match fails, continue trying with different match counts
				# This ensures proper backtracking
			ok
		next
    
		# Important addition: Check if this token can be skipped (when min=0)

		if aToken[:min] = 0

			# Try skipping this token entirely and move to the next one

			if This.BacktrackMatch(aTokens, aElements, nTokenIndex + 1, nElementIndex, aLocalUsedValues)
				return true
			ok
		ok
    
		# Could not find a valid match with this token

		return false


	# Helper function for value comparison by type

	def CompareValues(xValue1, xValue2, cType)

		switch cType

		on "number"

			# Simple number comparison
			return xValue1 = xValue2
			
		on "string"

			# Normalize strings by removing quotes for comparison

			cVal1 = This.RemoveQuotes("" + xValue1)
			cVal2 = This.RemoveQuotes("" + xValue2)
			
			return cVal1 = cVal2
			
		on "list"

			# Normalize list representations for comparison

			cVal1 = This.NormalizeListString(xValue1)
			cVal2 = This.NormalizeListString(xValue2)

			return cVal1 = cVal2
			
		on "any"

			# For any type, try various comparison methods

			if isNumber(xValue1) and isNumber(xValue2)
				return xValue1 = xValue2
			ok
			
			# Convert both to strings for comparison

			cVal1 = This.RemoveQuotes("" + xValue1)
			cVal2 = This.RemoveQuotes("" + xValue2)
			
			# For lists, normalize format if they appear to be lists

			if (StartsWith(cVal1, "[") and EndsWith(cVal1, "]")) and
			   (StartsWith(cVal2, "[") and EndsWith(cVal2, "]"))
				cVal1 = This.NormalizeListString(cVal1)
				cVal2 = This.NormalizeListString(cVal2)
			ok
			
			return cVal1 = cVal2
		off

	# Normalize list string representation for comparison

	def NormalizeListString(xList)
		cList = "" + xList
		
		# Remove all whitespace for consistent comparison

		cList = StzStringQ(cList).RemoveAllQ(' ').RemoveAllQ(char(9)).RemoveAllQ(char(10)).RemoveAllQ(char(13)).Content()
		
		return cList

	def ConvertToType(cValue, cType)

		# Convert a string representation to the appropriate type for comparison
		
		switch cType

		on "number"

			# Convert to numeric value
			return @number(cValue)
			
		on "string"

			# Return as is - normalization happens in CompareValues
			return cValue
			
		on "list"

			# Keep list representation as is
			return cValue
			
		on "any"

			# Keep as is for any type
			return cValue
		off

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
			
			# Handle different quantifier scenarios

			if aToken[:min] = aToken[:max]

				if aToken[:min] = 1
					# Default quantifier - no need to show

				else
					# Fixed quantifier
					cInfo += aToken[:min]
				ok

			else

				# Range quantifier
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
