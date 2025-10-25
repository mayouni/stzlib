# stzNumbrex - Number Pattern Matching for Softanza
# A regex-like pattern language for number structures

# Quick constructor functions
func StzNumbrexQ(cPattern)
	return new stzNumbrex(cPattern)

func Numbrex(cPattern)
	return new stzNumbrex(cPattern)

func Nx(cPattern)
	return new stzNumbrex(cPattern)

class stzNumbrex from stzObject
	
	@cPattern           # Pattern string, e.g., "{@Property(Prime)}"
	@aTokens            # Parsed token definitions
	@nNumber = 0            # Target number to match
	@bDebugMode = FALSE # Debug flag
	@aMatchedParts = [] # Extracted parts like digits, factors
	
	# Pattern token definitions
	@cDigitPattern = '@Digit(?:\((.*?)\))?'
	@cFactorPattern = '@Factor(?:\((.*?)\))?'
	@cPropertyPattern = '@Property(?:\((.*?)\))?'
	@cPartPattern = '@Part(?:\((.*?)\))?'
	@cRelationPattern = '@Relation(?:\((.*?)\))?'
	@cApproxPattern = '@Approx(?:\((.*?)\))?'
	
	@cQuantifierPattern = '([+*?~]|\d+|\d+-\d+)'
	@cNegationPattern = '@!'
	@cConstraintPattern = '\((.*?)\)'
	
	  #-------------------#
	 #  INITIALIZATION   #
	#-------------------#
	
	def init(pcPattern)
		if NOT isString(pcPattern)
			raise("Error: Pattern must be a string")
		ok
		
		@cPattern = This.NormalizePattern(pcPattern)
		
		# Parse pattern into tokens
		@aTokens = This.ParsePattern(@cPattern)
		
		if @bDebugMode
			? "=== stzNumbrex Init ==="
			? "Pattern: " + @cPattern
			? "Tokens parsed: " + len(@aTokens)
		ok
	
	def NormalizePattern(cPattern)
		cPattern = trim(cPattern)
		
		# Ensure pattern is wrapped in {}
		if NOT (startsWith(cPattern, "{") and endsWith(cPattern, "}"))
			cPattern = "{" + cPattern + "}"
		ok
		
		return cPattern
	
	  #--------------------#
	 #  PATTERN PARSING   #
	#--------------------#
	
	def ParsePattern(cPattern)
		# Remove outer braces
		cInner = @substr(cPattern, 2, len(cPattern) - 1)
		cInner = trim(cInner)
		
		if @bDebugMode
			? "Parsing inner pattern: " + cInner
		ok
		
		# Split by composition operator (->)
		aParts = This.SplitByOperator(cInner, "->")
		
		aTokens = []
		for i = 1 to len(aParts)
			cPart = trim(aParts[i])
			
			if cPart = ""
				loop
			ok
			
			# Check for alternation (|)
			if substr(cPart, "|") > 0
				aToken = This.ParseAlternation(cPart)
			# Check for conjunction (&)
			but substr(cPart, "&") > 0
				aToken = This.ParseConjunction(cPart)
			else
				aToken = This.ParseSingleToken(cPart)
			ok
			
			if len(aToken) > 0
				aTokens + aToken
			ok
		next
		
		return aTokens
	
	def SplitByOperator(cStr, cOperator)
		# Split by operator but respect parentheses nesting
		aParts = []
		cCurrent = ""
		nDepth = 0
		nLen = len(cStr)
		nOpLen = len(cOperator)
		
		for i = 1 to nLen
			cChar = substr(cStr, i, 1)
			
			if cChar = "(" or cChar = "{"
				nDepth++
				cCurrent += cChar
			but cChar = ")" or cChar = "}"
				nDepth--
				cCurrent += cChar
			but nDepth = 0 and substr(cStr, i, nOpLen) = cOperator
				aParts + trim(cCurrent)
				cCurrent = ""
				i += nOpLen - 1
			else
				cCurrent += cChar
			ok
		next
		
		if len(cCurrent) > 0
			aParts + trim(cCurrent)
		ok
		
		return aParts
	
	def ParseAlternation(cTokenStr)
		# Handle (A | B | C) patterns
		if startsWith(cTokenStr, "(") and endsWith(cTokenStr, ")")
			cTokenStr = @substr(cTokenStr, 2, len(cTokenStr) - 1)
		ok
		
		aParts = This.SplitByOperator(cTokenStr, "|")
		aAlternatives = []
		
		for i = 1 to len(aParts)
			cPart = trim(aParts[i])
			if cPart != ""
				aToken = This.ParseSingleToken(cPart)
				if len(aToken) > 0
					aAlternatives + aToken
				ok
			ok
		next
		
		return [
			["type", "alternation"],
			["alternatives", aAlternatives],
			["negated", FALSE]
		]
	
	def ParseConjunction(cTokenStr)
		# Handle (A & B & C) patterns
		if startsWith(cTokenStr, "(") and endsWith(cTokenStr, ")")
			cTokenStr = @substr(cTokenStr, 2, len(cTokenStr) - 1)
		ok
		
		aParts = This.SplitByOperator(cTokenStr, "&")
		aConditions = []
		
		for i = 1 to len(aParts)
			cPart = trim(aParts[i])
			if cPart != ""
				aToken = This.ParseSingleToken(cPart)
				if len(aToken) > 0
					aConditions + aToken
				ok
			ok
		next
		
		return [
			["type", "conjunction"],
			["conditions", aConditions],
			["negated", FALSE]
		]
	
	def ParseSingleToken(cTokenStr)
		cTokenStr = trim(cTokenStr)
		
		if cTokenStr = ""
			return []
		ok
		
		# Check for negation
		bNegated = FALSE
		if startsWith(cTokenStr, "@!")
			bNegated = TRUE
			cTokenStr = @substr(cTokenStr, 3, len(cTokenStr))
		ok
		
		# Initialize token properties
		cType = ""
		cValue = ""
		aConstraints = []
		nMin = 1
		nMax = 1
		
		# Identify token type
		if startsWith(cTokenStr, "@Digit")
			cType = "digit"
			cTokenStr = @substr(cTokenStr, 7, len(cTokenStr))
		but startsWith(cTokenStr, "@Factor")
			cType = "factor"
			cTokenStr = @substr(cTokenStr, 8, len(cTokenStr))
		but startsWith(cTokenStr, "@Property")
			cType = "property"
			cTokenStr = @substr(cTokenStr, 10, len(cTokenStr))
		but startsWith(cTokenStr, "@Part")
			cType = "part"
			cTokenStr = @substr(cTokenStr, 6, len(cTokenStr))
		but startsWith(cTokenStr, "@Relation")
			cType = "relation"
			cTokenStr = @substr(cTokenStr, 10, len(cTokenStr))
		but startsWith(cTokenStr, "@Approx")
			cType = "approx"
			cTokenStr = @substr(cTokenStr, 8, len(cTokenStr))
		else
			if @bDebugMode
				? "Unknown token type: " + cTokenStr
			ok
			return []
		ok
		
		# Extract value/constraints from parentheses
		nOpenParen = substr(cTokenStr, "(")
		if nOpenParen > 0
			nCloseParen = substr(cTokenStr, ")")
			if nCloseParen > nOpenParen
				cContent = @substr(cTokenStr, nOpenParen + 1, nCloseParen - 1)
				
				if cType = "property" or cType = "approx"
					cValue = cContent
				else
					aConstraints = This.ParseConstraints(cContent, cType)
				ok
			ok
		ok
		
		# Extract quantifier
		cLastChar = right(cTokenStr, 1)
		if cLastChar = "+"
			nMin = 1
			nMax = 999999
		but cLastChar = "*"
			nMin = 0
			nMax = 999999
		but cLastChar = "?"
			nMin = 0
			nMax = 1
		ok
		
		# Check for numeric quantifiers
		if isDigit(cLastChar)
			for i = len(cTokenStr) to 1 step -1
				cChar = @substr(cTokenStr, i, i)
				if not isDigit(cChar) and cChar != "-"
					cQuantPart = @substr(cTokenStr, i + 1, len(cTokenStr))
					if substr(cQuantPart, "-") > 0
						aRange = split(cQuantPart, "-")
						if len(aRange) = 2
							nMin = 0 + aRange[1]
							nMax = 0 + aRange[2]
						ok
					else
						nMin = 0 + cQuantPart
						nMax = nMin
					ok
					exit
				ok
			next
		ok
		
		return [
			["type", cType],
			["value", cValue],
			["constraints", aConstraints],
			["min", nMin],
			["max", nMax],
			["negated", bNegated]
		]
	
	def ParseConstraints(cConstraintStr, cType)
		aConstraints = []
		
		if cConstraintStr = ""
			return aConstraints
		ok
		
		# Parse based on type
		if cType = "digit"
			# Range: 1-5, Set: {1;3;5}, Step: :2, Unique: :unique
			if substr(cConstraintStr, "..") > 0
				aParts = split(cConstraintStr, "..")
				if len(aParts) = 2
					aConstraints + [
						["type", "range"],
						["start", 0 + trim(aParts[1])],
						["end", 0 + trim(aParts[2])]
					]
				ok
			but substr(cConstraintStr, "{") > 0
				nStart = substr(cConstraintStr, "{")
				nEnd = substr(cConstraintStr, "}")
				cSet = substr(cConstraintStr, nStart + 1, nEnd - nStart - 1)
				aValues = split(cSet, ";")
				aConstraints + [
					["type", "set"],
					["values", aValues]
				]
			but substr(cConstraintStr, ":unique") > 0
				aConstraints + [["type", "unique"]]
			but substr(cConstraintStr, ":step") > 0
				cStep = substr(cConstraintStr, 5)
				aConstraints + [
					["type", "step"],
					["value", 0 + cStep]
				]
			but isDigit(cConstraintStr)
				aConstraints + [
					["type", "exact"],
					["value", 0 + cConstraintStr]
				]
			but substr(cConstraintStr, "-") > 0
				aParts = split(cConstraintStr, "-")
				if len(aParts) = 2
					aConstraints + [
						["type", "range"],
						["start", 0 + trim(aParts[1])],
						["end", 0 + trim(aParts[2])]
					]
				ok
			ok
		
		but cType = "factor"
			# Prime, Unique, Count constraints
			if lower(cConstraintStr) = "prime"
				aConstraints + [["type", "prime"]]
			but lower(cConstraintStr) = "unique"
				aConstraints + [["type", "unique"]]
			but isDigit(cConstraintStr)
				aConstraints + [
					["type", "count"],
					["value", 0 + cConstraintStr]
				]
			ok
		ok
		
		return aConstraints
	
	  #--------------------#
	 #  MATCHING LOGIC    #
	#--------------------#
	
	def Match(pnNumber)
		if NOT isNumber(pnNumber)
			StzRaise("Incorrect param type! pnNumber must be a number.")
		ok

		@nNumber = pnNumber
		
		# Match all tokens
		bResult = This.MatchTokens(@aTokens, @nNumber)
		
		if bResult
			This.ExtractParts(@nNumber)
		ok
		
		return bResult

	
	def MatchTokens(aTokens, nNum)
		for i = 1 to len(aTokens)
			aToken = aTokens[i]
			
			if aToken[:type] = "alternation"
				bMatched = FALSE
				for j = 1 to len(aToken[:alternatives])
					if This.MatchSingleToken(aToken[:alternatives][j], nNum)
						bMatched = TRUE
						exit
					ok
				next
				if not bMatched
					return FALSE
				ok
			
			but aToken[:type] = "conjunction"
				for j = 1 to len(aToken[:conditions])
					if not This.MatchSingleToken(aToken[:conditions][j], nNum)
						return FALSE
					ok
				next
			
			else
				if not This.MatchSingleToken(aToken, nNum)
					return FALSE
				ok
			ok
		next
		
		return TRUE
	
	def MatchSingleToken(aToken, nNum)
		bResult = FALSE
		
		if aToken[:type] = "property"
			bResult = This.CheckProperty(aToken[:value], nNum)
		
		but aToken[:type] = "digit"
			bResult = This.CheckDigits(aToken, nNum)
		
		but aToken[:type] = "factor"
			bResult = This.CheckFactors(aToken, nNum)
		
		but aToken[:type] = "relation"
			bResult = This.CheckRelation(aToken[:value], nNum)
		
		but aToken[:type] = "approx"
			bResult = This.CheckApprox(aToken[:value], nNum)
		
		but aToken[:type] = "part"
			bResult = This.CheckPart(aToken[:value], nNum)
		ok
		
		if aToken[:negated]
			bResult = NOT bResult
		ok
		
		return bResult
	
	  #-----------------------#
	 #  PROPERTY CHECKING    #
	#-----------------------#
	
	def CheckProperty(cProperty, nNum)
		cProperty = lower(trim(cProperty))
		
		if cProperty = "prime"
			return This.IsPrime(nNum)
		
		but cProperty = "even"
			return (nNum % 2) = 0
		
		but cProperty = "odd"
			return (nNum % 2) != 0
		
		but cProperty = "perfect"
			return This.IsPerfect(nNum)
		
		but cProperty = "fibonacci"
			return This.IsFibonacci(nNum)
		
		but cProperty = "palindrome"
			return This.IsPalindrome(nNum)
		
		but cProperty = "square"
			return This.IsSquare(nNum)
		
		but cProperty = "positive"
			return nNum > 0
		
		but cProperty = "negative"
			return nNum < 0
		
		but cProperty = "zero"
			return nNum = 0
		ok
		
		return FALSE
	
	def IsPrime(nNum)
		if nNum < 2
			return FALSE
		ok
		if nNum = 2
			return TRUE
		ok
		if (nNum % 2) = 0
			return FALSE
		ok
		
		for i = 3 to sqrt(nNum) step 2
			if (nNum % i) = 0
				return FALSE
			ok
		next
		
		return TRUE
	
	def IsPerfect(nNum)
		if nNum < 2
			return FALSE
		ok
		
		nSum = 1
		for i = 2 to sqrt(nNum)
			if (nNum % i) = 0
				nSum += i
				if i != (nNum / i)
					nSum += (nNum / i)
				ok
			ok
		next
		
		return nSum = nNum
	
	def IsFibonacci(nNum)
		# A number is Fibonacci if one of (5*n^2 + 4) or (5*n^2 - 4) is a perfect square
		return This.IsSquare(5 * nNum * nNum + 4) or This.IsSquare(5 * nNum * nNum - 4)
	
	def IsSquare(nNum)
		if nNum < 0
			return FALSE
		ok
		nSqrt = sqrt(nNum)
		return nSqrt = floor(nSqrt)
	
	def IsPalindrome(nNum)
		cStr = "" + nNum
		cReversed = ""
		for i = len(cStr) to 1 step -1
			cReversed += substr(cStr, i, 1)
		next
		return cStr = cReversed
	
	  #--------------------#
	 #  DIGIT CHECKING    #
	#--------------------#
	
	def CheckDigits(aToken, nNum)
		aDigits = This.GetDigits(nNum)
		
		# Check quantifiers
		nCount = len(aDigits)
		if nCount < aToken[:min] or nCount > aToken[:max]
			return FALSE
		ok
		
		# Check constraints
		for i = 1 to len(aToken[:constraints])
			aConstraint = aToken[:constraints][i]
			
			if aConstraint[:type] = "range"
				for j = 1 to len(aDigits)
					nDigit = aDigits[j]
					if nDigit < aConstraint[:start] or nDigit > aConstraint[:end]
						return FALSE
					ok
				next
			
			but aConstraint[:type] = "set"
				for j = 1 to len(aDigits)
					bFound = FALSE
					for k = 1 to len(aConstraint[:values])
						if aDigits[j] = (0 + trim(aConstraint[:values][k]))
							bFound = TRUE
							exit
						ok
					next
					if not bFound
						return FALSE
					ok
				next
			
			but aConstraint[:type] = "unique"
				for j = 1 to len(aDigits)
					for k = j + 1 to len(aDigits)
						if aDigits[j] = aDigits[k]
							return FALSE
						ok
					next
				next
			
			but aConstraint[:type] = "exact"
				if nCount != aConstraint[:value]
					return FALSE
				ok
			ok
		next
		
		return TRUE
	
	def GetDigits(nNum)
		cStr = "" + abs(nNum)
		aDigits = []
		for i = 1 to len(cStr)
			cChar = substr(cStr, i, 1)
			if isDigit(cChar)
				aDigits + (0 + cChar)
			ok
		next
		return aDigits
	
	  #---------------------#
	 #  FACTOR CHECKING    #
	#---------------------#
	
	def CheckFactors(aToken, nNum)
		aFactors = This.GetFactors(nNum)
		
		# Check quantifiers
		nCount = len(aFactors)
		if nCount < aToken[:min] or nCount > aToken[:max]
			return FALSE
		ok
		
		# Check constraints
		for i = 1 to len(aToken[:constraints])
			aConstraint = aToken[:constraints][i]
			
			if aConstraint[:type] = "prime"
				for j = 1 to len(aFactors)
					if not This.IsPrime(aFactors[j])
						return FALSE
					ok
				next
			
			but aConstraint[:type] = "unique"
				for j = 1 to len(aFactors)
					for k = j + 1 to len(aFactors)
						if aFactors[j] = aFactors[k]
							return FALSE
						ok
					next
				next
			
			but aConstraint[:type] = "count"
				if nCount != aConstraint[:value]
					return FALSE
				ok
			ok
		next
		
		return TRUE
	
	def GetFactors(nNum)
		nNum = abs(nNum)
		aFactors = []
		
		if nNum = 0
			return aFactors
		ok
		
		for i = 1 to sqrt(nNum)
			if (nNum % i) = 0
				aFactors + i
				if i != (nNum / i)
					aFactors + (nNum / i)
				ok
			ok
		next
		
		# Sort factors
		for i = 1 to len(aFactors) - 1
			for j = i + 1 to len(aFactors)
				if aFactors[i] > aFactors[j]
					temp = aFactors[i]
					aFactors[i] = aFactors[j]
					aFactors[j] = temp
				ok
			next
		next
		
		return aFactors
	
	  #-----------------------#
	 #  RELATION CHECKING    #
	#-----------------------#
	
	def CheckRelation(cRelation, nNum)
		# Parse relation like "Mod:5=0"
		if substr(cRelation, "Mod:") > 0
			cRest = @substr(cRelation, 5, len(cRelation))
			nEquals = substr(cRest, "=")
			if nEquals > 0
				nMod = 0 + @substr(cRest, 1, nEquals - 1)
				nExpected = 0 + @substr(cRest, nEquals + 1, len(cRest))
				return (nNum % nMod) = nExpected
			ok
		ok
		
		return FALSE
	
	def CheckApprox(cApprox, nNum)
		# Parse like "~3.14" or "~3.14:2decimals"
		if startsWith(cApprox, "~")
			cValue = @substr(cApprox, 2, len(cApprox))
			nDecimals = 2  # Default
			
			if substr(cValue, ":") > 0
				aParts = split(cValue, ":")
				cValue = aParts[1]
				if len(aParts) > 1 and substr(aParts[2], "decimal") > 0
					# Extract decimal count
					for i = 1 to len(aParts[2])
						if isDigit(@substr(aParts[2], i, i))
							nDecimals = 0 + @substr(aParts[2], i, i)
							exit
						ok
					next
				ok
			ok
			
			nTarget = 0 + cValue
			nFactor = pow(10, nDecimals)
			return floor(nNum * nFactor) = floor(nTarget * nFactor)
		ok
		
		return FALSE
	
	def CheckPart(cPart, nNum)
		# For future: handle Integer/Fractional parts with nested patterns
		return TRUE
	
	  #----------------------#
	 #  PART EXTRACTION     #
	#----------------------#
	
	def ExtractParts(nNum)
		@aMatchedParts = []
		
		# Extract digits
		aDigits = This.GetDigits(nNum)
		@aMatchedParts + ["Digits", aDigits]
		
		# Extract factors
		aFactors = This.GetFactors(nNum)
		@aMatchedParts + ["Factors", aFactors]
		
		# Extract properties
		aProps = []
		if This.IsPrime(nNum)
			aProps + "Prime"
		ok
		if (nNum % 2) = 0
			aProps + "Even"
		else
			aProps + "Odd"
		ok
		if This.IsPerfect(nNum)
			aProps + "Perfect"
		ok
		if This.IsFibonacci(nNum)
			aProps + "Fibonacci"
		ok
		if This.IsPalindrome(nNum)
			aProps + "Palindrome"
		ok
		
		@aMatchedParts + ["Properties", aProps]
		@aMatchedParts + ["Value", nNum]
	
	  #----------------------#
	 #  QUERY METHODS       #
	#----------------------#
	
	def MatchedParts()
		return @aMatchedParts
	
	def Tokens()
		return @aTokens
	
	def Pattern()
		return @cPattern
	
	def SetTarget(pnNumber)
		@nNumber = pnNumber
	
	def Explain()
		aExplanation = [
			["Pattern", @cPattern],
			["TokenCount", len(@aTokens)],
			["Tokens", @aTokens]
		]
		
		if @nNumber != NULL
			aExplanation + ["Target", @nNumber]
		ok
		
		if len(@aMatchedParts) > 0
			aExplanation + ["MatchedParts", @aMatchedParts]
		ok
		
		return aExplanation
	
	  #----------------------#
	 #  DEBUG METHODS       #
	#----------------------#
	
	def EnableDebug()
		@bDebugMode = TRUE
	
	def DisableDebug()
		@bDebugMode = FALSE
	
	def SetDebug(bFlag)
		@bDebugMode = bFlag
