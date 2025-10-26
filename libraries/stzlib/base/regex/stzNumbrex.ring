# stzNumbrex - Number Pattern Matching for Softanza
# A regex-like pattern language for number structures
# FINAL VERSION - All bugs fixed

# Quick constructor functions
func StzNumbrexQ(cPattern)
	return new stzNumbrex(cPattern)

func Numbrex(cPattern)
	return new stzNumbrex(cPattern)

func Nx(cPattern)
	return new stzNumbrex(cPattern)

class stzNumbrex from stzObject
	
	@cPattern           # Pattern string
	@aTokens            # Parsed token definitions
	@nNumber = 0        # Target number to match
	@bDebugMode = FALSE # Debug flag
	@aMatchedParts = [] # Extracted parts
	
	  #-------------------#
	 #  INITIALIZATION   #
	#-------------------#
	
	def init(pcPattern)
		if NOT isString(pcPattern)
			StzRaise("Error: Pattern must be a string")
		ok
		
		@cPattern = This.NormalizePattern(pcPattern)
		@aTokens = This.ParsePattern(@cPattern)
		
		if @bDebugMode
			? "=== stzNumbrex Init ==="
			? "Pattern: " + @cPattern
			? "Tokens parsed: " + len(@aTokens)
		ok
	
	def NormalizePattern(cPattern)
		cPattern = trim(cPattern)
		if NOT (startsWith(cPattern, "{") and endsWith(cPattern, "}"))
			cPattern = "{" + cPattern + "}"
		ok
		return cPattern
	
	  #--------------------#
	 #  PATTERN PARSING   #
	#--------------------#
	
	def ParsePattern(cPattern)

		cInner = @substr(cPattern, 2, len(cPattern) - 1)
		cInner = trim(cInner)
		
		if @bDebugMode
			? "Parsing inner pattern: " + cInner
		ok
		
		aParts = This.SplitByOperator(cInner, "->")

		aTokens = []
		nLenParts = len(aParts)
		
		for i = 1 to nLenParts
			cPart = trim(aParts[i])
			if cPart = ""
				loop
			ok
			
			if substr(cPart, "|") > 0
				aToken = This.ParseAlternation(cPart)
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
		aParts = []
		cCurrent = ""
		nDepth = 0
		nLen = len(cStr)
		nOpLen = len(cOperator)
		
		for i = 1 to nLen
			cChar = @substr(cStr, i, i)
			
			if cChar = "(" or cChar = "{"
				nDepth++
				cCurrent += cChar
			but cChar = ")" or cChar = "}"
				nDepth--
				cCurrent += cChar
			but nDepth = 0 and @substr(cStr, i, i + nOpLen - 1) = cOperator
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
		if startsWith(cTokenStr, "(") and endsWith(cTokenStr, ")")
			cTokenStr = @substr(cTokenStr, 2, len(cTokenStr) - 1)
		ok
		
		aParts = This.SplitByOperator(cTokenStr, "|")
		aAlternatives = []
		nLenParts = len(aParts)
		
		for i = 1 to nLenParts
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
			["negated", 0]
		]
	
	def ParseConjunction(cTokenStr)
		if startsWith(cTokenStr, "(") and endsWith(cTokenStr, ")")
			cTokenStr = @substr(cTokenStr, 2, len(cTokenStr) - 1)
		ok
		
		aParts = This.SplitByOperator(cTokenStr, "&")
		aConditions = []
		nLenParts = len(aParts)
		
		for i = 1 to nLenParts
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
			["negated", 0]
		]
	

def ParseSingleToken(cTokenStr)
	cTokenStr = trim(cTokenStr)
	if cTokenStr = ""
		return []
	ok
	
	cOriginal = cTokenStr
	bNegated = 0
	
	if startsWith(lower(cTokenStr), "@!")
		bNegated = 1
		cTokenStr = @substr(cTokenStr, 3, len(cTokenStr))

		if @bDebugMode
			? "Negation detected! Remaining: " + cTokenStr
		ok
	ok
	
	cType = ""
	cValue = ""
	aConstraints = []
	nMin = 1
	nMax = 1
	
	cTokenStr = lower(cTokenStr)

	if startsWith(cTokenStr, "@digit")
		cType = "digit"
		cTokenStr = @substr(cTokenStr, 7, len(cTokenStr))

	but startsWith(cTokenStr, "digit")
		cType = "digit"
		cTokenStr = @substr(cTokenStr, 6, len(cTokenStr))

	#--

	but startsWith(cTokenStr, "@factor")
		cType = "factor"
		cTokenStr = @substr(cTokenStr, 8, len(cTokenStr))

	but startsWith(cTokenStr, "factor")
		cType = "factor"
		cTokenStr = @substr(cTokenStr, 7, len(cTokenStr))

	#--

	but startsWith(cTokenStr, "@property")
		cType = "property"
		cTokenStr = @substr(cTokenStr, 10, len(cTokenStr))

	but StartsWith(cTokenStr, "property")
		cType = "property"
		cTokenStr = @substr(cTokenStr, 9, len(cTokenStr))

	#--

	but startsWith(cTokenStr, "@part")
		cType = "part"
		cTokenStr = @substr(cTokenStr, 6, len(cTokenStr))

	but startsWith(cTokenStr, "part")
		cType = "part"
		cTokenStr = @substr(cTokenStr, 5, len(cTokenStr))

	#--

	but startsWith(cTokenStr, "@relation")
		cType = "relation"
		cTokenStr = @substr(cTokenStr, 10, len(cTokenStr))

	but startsWith(cTokenStr, "relation")
		cType = "relation"
		cTokenStr = @substr(cTokenStr, 9, len(cTokenStr))

	#--

	but startsWith(cTokenStr, "@approx")
		cType = "approx"
		cTokenStr = @substr(cTokenStr, 8, len(cTokenStr))

	but startsWith(cTokenStr, "approx")
		cType = "approx"
		cTokenStr = @substr(cTokenStr, 7, len(cTokenStr))

	#--

	but startsWith(cTokenStr, "@divisor")
		cType = "divisor"
		cTokenStr = @substr(cTokenStr, 9, len(cTokenStr))

	but startsWith(cTokenStr, "divisor")
		cType = "divisor"
		cTokenStr = @substr(cTokenStr, 8, len(cTokenStr))

	#--

	but startsWith(cTokenStr, "@multiple")
		cType = "multiple"
		cTokenStr = @substr(cTokenStr, 10, len(cTokenStr))

	but startsWith(cTokenStr, "multiple")
		cType = "multiple"
		cTokenStr = @substr(cTokenStr, 9, len(cTokenStr))

	#--

	else
		if @bDebugMode
			? "Unknown token type: " + cTokenStr
		ok
		return []
	ok
	
	nOpenParen = substr(cTokenStr, "(")

	nCloseParen = 0
	if nOpenParen > 0
		nCloseParen = substr(cTokenStr, ")")
		if nCloseParen > nOpenParen
			cContent = @substr(cTokenStr, nOpenParen + 1, nCloseParen - 1)

			if @bDebugMode
				? ">> cContent: " + cContent
				? ">> cType: " + cType
			ok

			if cType = "property" or cType = "approx" or
			   cType = "relation" or cType = "part" or
			   cType = "divisor" or cType = "multiple"

				cValue = cContent

			else
				aConstraints = This.ParseConstraints(cContent, cType)
			ok
		ok
	ok
	
	# Parse quantifier
	cQuantPart = ""
	if nCloseParen > 0
		# Extract everything after closing parenthesis
		if nCloseParen < len(cTokenStr)
			cQuantPart = @substr(cTokenStr, nCloseParen + 1, len(cTokenStr))
		ok
	else
		# No parentheses - extract after token type name from original string
		nTypeLen = 0
		cLowerOriginal = lower(cOriginal)
		
		if startsWith(cLowerOriginal, "@digit")
			nTypeLen = 6
		but startsWith(cLowerOriginal, "digit")
			nTypeLen = 5
		but startsWith(cLowerOriginal, "@factor")
			nTypeLen = 7
		but startsWith(cLowerOriginal, "factor")
			nTypeLen = 6
		but startsWith(cLowerOriginal, "@property")
			nTypeLen = 9
		but startsWith(cLowerOriginal, "property")
			nTypeLen = 8
		but startsWith(cLowerOriginal, "@part")
			nTypeLen = 5
		but startsWith(cLowerOriginal, "part")
			nTypeLen = 4
		but startsWith(cLowerOriginal, "@relation")
			nTypeLen = 9
		but startsWith(cLowerOriginal, "relation")
			nTypeLen = 8
		but startsWith(cLowerOriginal, "@approx")
			nTypeLen = 7
		but startsWith(cLowerOriginal, "approx")
			nTypeLen = 6
		but startsWith(cLowerOriginal, "@divisor")
			nTypeLen = 8
		but startsWith(cLowerOriginal, "divisor")
			nTypeLen = 7
		but startsWith(cLowerOriginal, "@multiple")
			nTypeLen = 9
		but startsWith(cLowerOriginal, "multiple")
			nTypeLen = 8
		ok
		
		# Account for negation prefix
		if bNegated = 1
			nTypeLen += 2
		ok
		
		if nTypeLen > 0 and nTypeLen < len(cOriginal)
			cQuantPart = @substr(cOriginal, nTypeLen + 1, len(cOriginal))
		ok
	ok
	
	cQuantPart = trim(cQuantPart)
	
	if @bDebugMode
		? "Quantifier part: [" + cQuantPart + "]"
	ok
	
	if len(cQuantPart) > 0
		# Check for colon (constraints like :unique)
		if substr(cQuantPart, ":") > 0
			nColon = substr(cQuantPart, ":")
			cBeforeColon = @substr(cQuantPart, 1, nColon - 1)
			cAfterColon = @substr(cQuantPart, nColon + 1, len(cQuantPart))
			
			if @bDebugMode
				? "Before colon: [" + cBeforeColon + "]"
				? "After colon: [" + cAfterColon + "]"
			ok
			
			cBeforeColon = trim(cBeforeColon)
			if len(cBeforeColon) > 0 and This.IsNumeric(cBeforeColon)
				if substr(cBeforeColon, "-") > 0
					aSection = @split(cBeforeColon, "-")
					if len(aSection) = 2
						nMin = 0 + trim(aSection[1])
						nMax = 0 + trim(aSection[2])
					ok
				else
					nMin = 0 + cBeforeColon
					nMax = nMin
				ok
			ok
			
			aMoreConstraints = This.ParseConstraints(":" + cAfterColon, cType)
			nLenMore = len(aMoreConstraints)
			for i = 1 to nLenMore
				aConstraints + aMoreConstraints[i]
			next
		else
			# No colon - check for simple quantifiers
			cLastChar = right(cQuantPart, 1)
			if cLastChar = "+"
				# Check if there's a number before the +
				cBeforePlus = left(cQuantPart, len(cQuantPart) - 1)
				if len(cBeforePlus) > 0 and This.IsNumeric(cBeforePlus)
					nMin = 0 + cBeforePlus
					nMax = 999999
				else
					nMin = 1
					nMax = 999999
				ok
			but cLastChar = "*"
				# Check if there's a number before the *
				cBeforeStar = left(cQuantPart, len(cQuantPart) - 1)
				if len(cBeforeStar) > 0 and This.IsNumeric(cBeforeStar)
					nMin = 0 + cBeforeStar
					nMax = 999999
				else
					nMin = 0
					nMax = 999999
				ok
			but cLastChar = "?"
				nMin = 0
				nMax = 1
			but This.IsNumeric(cQuantPart)
				if substr(cQuantPart, "-") > 0
					aSection = @split(cQuantPart, "-")
					if len(aSection) = 2
						nMin = 0 + trim(aSection[1])
						nMax = 0 + trim(aSection[2])
					ok
				else
					nMin = 0 + cQuantPart
					nMax = nMin
				ok
			ok
		ok
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
		
		if cType = "digit"
			if substr(lower(cConstraintStr), ":unique") > 0
				aConstraints + [["type", "unique"]]
			but substr(cConstraintStr, "..") > 0
				aParts = @split(cConstraintStr, "..")
				if len(aParts) = 2
					aConstraints + [
						["type", "Section"],
						["start", 0 + trim(aParts[1])],
						["end", 0 + trim(aParts[2])]
					]
				ok
			but substr(cConstraintStr, "{") > 0
				nStart = substr(cConstraintStr, "{")
				nEnd = substr(cConstraintStr, "}")
				cSet = @substr(cConstraintStr, nStart + 1, nEnd - 1)
				aValues = @split(cSet, ";")
				aConstraints + [
					["type", "set"],
					["values", aValues]
				]
			but substr(cConstraintStr, ":step") > 0
				cStep = @substr(cConstraintStr, 6, len(cConstraintStr))
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
				aParts = @split(cConstraintStr, "-")
				if len(aParts) = 2
					aConstraints + [
						["type", "Section"],
						["start", 0 + trim(aParts[1])],
						["end", 0 + trim(aParts[2])]
					]
				ok
			ok
		
		but cType = "factor"
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
		
		if @bDebugMode
			? "=== Matching " + pnNumber + " ==="
		ok

		bResult = This.MatchTokens(@aTokens, @nNumber)
		
		if bResult
			This.ExtractParts(@nNumber)
		ok
		
		if @bDebugMode
			? "Result: " + bResult
		ok
		
		return bResult
	
	def MatchTokens(aTokens, nNum)
		nLenTokens = len(aTokens)
		for i = 1 to nLenTokens
			aToken = aTokens[i]
			
			if HasKey(aToken, "type") and aToken["type"] = "alternation"
				bMatched = FALSE
				if HasKey(aToken, "alternatives")
					nLenAlt = len(aToken["alternatives"])
					for j = 1 to nLenAlt
						if This.MatchSingleToken(aToken["alternatives"][j], nNum)
							bMatched = TRUE
							exit
						ok
					next
				ok
				if not bMatched
					return FALSE
				ok
			
			but HasKey(aToken, "type") and aToken["type"] = "conjunction"
				if HasKey(aToken, "conditions")
					nLenCond = len(aToken["conditions"])
					for j = 1 to nLenCond
						if not This.MatchSingleToken(aToken["conditions"][j], nNum)
							return FALSE
						ok
					next
				ok
			
			else
				if not This.MatchSingleToken(aToken, nNum)
					return FALSE
				ok
			ok
		next
		
		return TRUE
	
	def MatchSingleToken(aToken, nNum)
		bResult = FALSE
		
		if @bDebugMode
			? "Checking token type: " + aToken["type"]
			if HasKey(aToken, "negated")
				? "Negated value: " + aToken["negated"]
			ok
		ok
		
		if HasKey(aToken, "type")
			cType = aToken["type"]
			
			if cType = "property"
				if HasKey(aToken, "value")
					bResult = This.CheckProperty(aToken["value"], nNum)
				ok
			
			but cType = "digit"
				bResult = This.CheckDigits(aToken, nNum)
			
			but cType = "factor"
				bResult = This.CheckFactors(aToken, nNum)
			
			but cType = "relation"
				if HasKey(aToken, "value")
					bResult = This.CheckRelation(aToken["value"], nNum)
				ok
			
			but cType = "approx"
				if HasKey(aToken, "value")
					bResult = This.CheckApprox(aToken["value"], nNum)
				ok
			
			but cType = "part"
				if HasKey(aToken, "value")
					bResult = This.CheckPart(aToken["value"], nNum)
				ok
			
			but cType = "divisor"
				if HasKey(aToken, "value")
					bResult = This.CheckDivisor(aToken["value"], nNum)
				ok
			
			but cType = "multiple"
				if HasKey(aToken, "value")
					bResult = This.CheckMultiple(aToken["value"], nNum)
				ok
			ok
		ok
		
		if @bDebugMode
			? "Result before negation: " + bResult
		ok
		
		if HasKey(aToken, "negated") and aToken["negated"] = 1
			if @bDebugMode
				? "Applying negation"
			ok
			bResult = not bResult
		ok
		
		if @bDebugMode
			? "Final result: " + bResult
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
		but cProperty = "composite"
			return nNum > 1 and not This.IsPrime(nNum)
		but cProperty = "abundant"
			return This.IsAbundant(nNum)
		but cProperty = "deficient"
			return This.IsDeficient(nNum)
		but cProperty = "triangular"
			return This.IsTriangular(nNum)
		but cProperty = "cube"
			return This.IsCube(nNum)
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
		
		nSqrt = sqrt(nNum)
		for i = 3 to nSqrt step 2
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
		nSqrt = sqrt(nNum)
		for i = 2 to nSqrt
			if (nNum % i) = 0
				nSum += i
				if i != (nNum / i)
					nSum += (nNum / i)
				ok
			ok
		next
		
		return nSum = nNum
	
	def IsFibonacci(nNum)
		return This.IsSquare(5 * nNum * nNum + 4) or This.IsSquare(5 * nNum * nNum - 4)
	
	def IsSquare(nNum)
		if nNum < 0
			return FALSE
		ok
		nSqrt = sqrt(nNum)
		return nSqrt = floor(nSqrt)
	
	def IsPalindrome(nNum)
		cStr = "" + abs(nNum)
		cReversed = ""
		nLen = len(cStr)
		for i = nLen to 1 step -1
			cReversed += @substr(cStr, i, i)
		next
		return cStr = cReversed
	
	def IsAbundant(nNum)
		if nNum < 1
			return FALSE
		ok
		aFactors = This.GetProperDivisors(nNum)
		nSum = 0
		nLen = len(aFactors)
		for i = 1 to nLen
			nSum += aFactors[i]
		next
		return nSum > nNum
	
	def IsDeficient(nNum)
		if nNum < 1
			return FALSE
		ok
		aFactors = This.GetProperDivisors(nNum)
		nSum = 0
		nLen = len(aFactors)
		for i = 1 to nLen
			nSum += aFactors[i]
		next
		return nSum < nNum
	
	def IsTriangular(nNum)
		return This.IsSquare(8 * nNum + 1)
	
	def IsCube(nNum)
		if nNum < 0
			return FALSE
		ok
		if nNum = 0 or nNum = 1
			return TRUE
		ok
		# Robust cube root check with floating point tolerance
		nCubeRoot = pow(nNum, 1.0/3.0)
		nLower = floor(nCubeRoot)
		nUpper = ceil(nCubeRoot)
		return (nLower * nLower * nLower = nNum) or (nUpper * nUpper * nUpper = nNum)
	
	def GetProperDivisors(nNum)
		aFactors = This.GetFactors(nNum)
		aResult = []
		nLen = len(aFactors)
		for i = 1 to nLen
			if aFactors[i] != nNum
				aResult + aFactors[i]
			ok
		next
		return aResult
	
	  #--------------------#
	 #  DIGIT CHECKING    #
	#--------------------#
	
def CheckDigits(aToken, nNum)
	aDigits = This.GetDigits(nNum)
	nCount = len(aDigits)
	nMin = 1
	nMax = 1
	
	if HasKey(aToken, "min")
		nMin = aToken["min"]
	ok
	if HasKey(aToken, "max")
		nMax = aToken["max"]
	ok
	
	if @bDebugMode
		? "CheckDigits: count=" + nCount + " min=" + nMin + " max=" + nMax
	ok
	
	if nCount < nMin or nCount > nMax
		return FALSE
	ok
	
	if HasKey(aToken, "constraints")
		nLenConstr = len(aToken["constraints"])
		for i = 1 to nLenConstr
			aConstraint = aToken["constraints"][i]
			
			if HasKey(aConstraint, "type")
				cConstrType = aConstraint["type"]
				
				if cConstrType = "Section"
					nLenDigits = len(aDigits)
					for j = 1 to nLenDigits
						nDigit = aDigits[j]
						nStart = 0
						nEnd = 9
						
						if HasKey(aConstraint, "start")
							nStart = aConstraint["start"]
						ok
						if HasKey(aConstraint, "end")
							nEnd = aConstraint["end"]
						ok
						
						if nDigit < nStart or nDigit > nEnd
							return FALSE
						ok
					next
				
				but cConstrType = "set"
					if HasKey(aConstraint, "values")
						nLenDigits = len(aDigits)
						for j = 1 to nLenDigits
							bFound = FALSE
							nLenValues = len(aConstraint["values"])
							for k = 1 to nLenValues
								if aDigits[j] = (0 + trim(aConstraint["values"][k]))
									bFound = TRUE
									exit
								ok
							next
							if not bFound
								return FALSE
							ok
						next
					ok
				
				but cConstrType = "unique"
					nLenDigits = len(aDigits)
					for j = 1 to nLenDigits
						for k = j + 1 to nLenDigits
							if aDigits[j] = aDigits[k]
								return FALSE
							ok
						next
					next
				
				but cConstrType = "exact"
					if HasKey(aConstraint, "value")
						if nCount != aConstraint["value"]
							return FALSE
						ok
					ok
				ok
			ok
		next
	ok
	
	return TRUE
	
	def GetDigits(nNum)
		cStr = "" + abs(nNum)
		aDigits = []
		nLen = len(cStr)
		for i = 1 to nLen
			cChar = @substr(cStr, i, i)
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
		nCount = len(aFactors)
		nMin = 1
		nMax = 1
		
		if HasKey(aToken, "min")
			nMin = aToken["min"]
		ok
		if HasKey(aToken, "max")
			nMax = aToken["max"]
		ok
		
		if nCount < nMin or nCount > nMax
			return FALSE
		ok
		
		if HasKey(aToken, "constraints")
			nLenConstr = len(aToken["constraints"])
			for i = 1 to nLenConstr
				aConstraint = aToken["constraints"][i]
				
				if HasKey(aConstraint, "type")
					cConstrType = aConstraint["type"]
					
					if cConstrType = "prime"
						nLenFactors = len(aFactors)
						for j = 1 to nLenFactors
							if not This.IsPrime(aFactors[j])
								return FALSE
							ok
						next
					
					but cConstrType = "unique"
						nLenFactors = len(aFactors)
						for j = 1 to nLenFactors
							for k = j + 1 to nLenFactors
								if aFactors[j] = aFactors[k]
									return FALSE
								ok
							next
						next
					
					but cConstrType = "count"
						if HasKey(aConstraint, "value")
							if nCount != aConstraint["value"]
								return FALSE
							ok
						ok
					ok
				ok
			next
		ok
		
		return TRUE
	
	def GetFactors(nNum)
		nNum = abs(nNum)
		aFactors = []
		
		if nNum = 0
			return aFactors
		ok
		
		nSqrt = sqrt(nNum)
		for i = 1 to nSqrt
			if (nNum % i) = 0
				aFactors + i
				if i != (nNum / i)
					aFactors + (nNum / i)
				ok
			ok
		next
		
		# Sort factors
		nLen = len(aFactors)
		for i = 1 to nLen - 1
			for j = i + 1 to nLen
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
		if substr(lower(cRelation), "mod:") > 0
			cRest = @substr(cRelation, 5, len(cRelation))
			nEquals = substr(cRest, "=")
			if nEquals > 0
				cMod = @substr(cRest, 1, nEquals - 1)
				cExpected = @substr(cRest, nEquals + 1, len(cRest))
				nMod = 0 + cMod
				nExpected = 0 + cExpected
				return (nNum % nMod) = nExpected
			ok
		ok
		return FALSE
	
	def CheckApprox(cApprox, nNum)
		if startsWith(cApprox, "~")
			cValue = @substr(cApprox, 2, len(cApprox))
			nDecimals = 2
			
			if substr(cValue, ":") > 0
				aParts = @split(cValue, ":")
				cValue = aParts[1]
				if len(aParts) > 1 and substr(lower(aParts[2]), "decimal") > 0
					nLenPart = len(aParts[2])
					for i = 1 to nLenPart
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
		cPart = lower(trim(cPart))
		
		if cPart = "integer"
			# Check if number has no fractional part (with floating point tolerance)
			nFrac = nNum - floor(nNum)
			return (nFrac >= -0.0000001 and nFrac <= 0.0000001)
		
		but cPart = "fractional"
			# Check if number has a fractional part
			nFrac = nNum - floor(nNum)
			return not (nFrac >= -0.0000001 and nFrac <= 0.0000001)
		
		but startsWith(cPart, "integer:")
			cPattern = @substr(cPart, 9, len(cPart))
			nIntPart = floor(nNum)
			oNx = new stzNumbrex("{" + cPattern + "}")
			return oNx.Match(nIntPart)
		
		but startsWith(cPart, "fractional:")
			cPattern = @substr(cPart, 12, len(cPart))
			nFracPart = nNum - floor(nNum)
			nFracInt = floor(nFracPart * 1000000)
			oNx = new stzNumbrex("{" + cPattern + "}")
			return oNx.Match(nFracInt)
		ok
		
		return TRUE
	
	def CheckDivisor(cValue, nNum)
		cValue = trim(cValue)
		if This.IsNumeric(cValue)
			nDivisor = 0 + cValue
			if nDivisor = 0
				return FALSE
			ok
			return (nNum % nDivisor) = 0
		ok
		return FALSE
	
	def CheckMultiple(cValue, nNum)
		cValue = trim(cValue)
		if This.IsNumeric(cValue)
			nBase = 0 + cValue
			if nBase = 0
				return FALSE
			ok
			return (nNum % nBase) = 0
		ok
		return FALSE
	
	  #----------------------#
	 #  PART EXTRACTION     #
	#----------------------#
	
	def ExtractParts(nNum)
		@aMatchedParts = []
		
		aDigits = This.GetDigits(nNum)
		@aMatchedParts + ["Digits", aDigits]
		
		aFactors = This.GetFactors(nNum)
		@aMatchedParts + ["Factors", aFactors]
		
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
		if This.IsSquare(nNum)
			aProps + "Square"
		ok
		if This.IsTriangular(nNum)
			aProps + "Triangular"
		ok
		if This.IsCube(nNum)
			aProps + "Cube"
		ok
		if This.IsAbundant(nNum)
			aProps + "Abundant"
		ok
		if This.IsDeficient(nNum)
			aProps + "Deficient"
		ok
		if nNum > 1 and not This.IsPrime(nNum)
			aProps + "Composite"
		ok
		
		@aMatchedParts + ["Properties", aProps]
		@aMatchedParts + ["Value", nNum]
	
	  #----------------------#
	 #  QUERY METHODS       #
	#----------------------#
	
	def MatchedParts()
		return @aMatchedParts
	
	def Digits()
		if HasKey(@aMatchedParts, "Digits")
			return @aMatchedParts["Digits"]
		ok
		return []

	def Factors()
		if HasKey(@aMatchedParts, "Factors")
			return @aMatchedParts["Factors"]
		ok
		return []

	def Properties()
		if HasKey(@aMatchedParts, "Properties")
			return @aMatchedParts["Properties"]
		ok
		return []

	def Value()
		if HasKey(@aMatchedParts, "Value")
			return @aMatchedParts["Value"]
		ok
		return 0
	
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
	
	  #---------------------------#
	 #  ADVANCED QUERY METHODS   #
	#---------------------------#
	
	def MatchingNumberAfter(nStart)
		nCurrent = nStart
		nMaxAttempts = 100000
		
		for i = 1 to nMaxAttempts
			if This.Match(nCurrent)
				return nCurrent
			ok
			nCurrent++
		next
		
		return NULL

		def MatchingNumberNextTo(nStart)
			return This.MatchingNumberAfter(nStart)

	def MatchingNumberBefore(nStart)
		nCurrent = nStart
		nMaxAttempts = 100000
		
		for i = 1 to nMaxAttempts
			if This.Match(nCurrent)
				return nCurrent
			ok
			nCurrent--
		next
		
		return NULL
	
		def MatchingNumberPreviousTo(nStart)
			return This.MatchingNumberBefore(nStart)

	def MatchingNumbersBetween(nStart, nEnd)
		if CheckParams()
			if NOT isNumber(nStart)
				StzRaise("Incorrect param type! nStart mustr be a number.")
			ok

			if isList(nEnd) and StzListQ(nEnd).IsAndNamedPAram()
				nEnd = nEnd[2]
			ok

			if NOT isNumber(nEnd)
				StzRaise("Incorrect param type! nEnd mustr be a number.")
			ok
		ok

		aResults = []
		
		for nNum = nStart to nEnd
			if This.Match(nNum)
				aResults + nNum
			ok
		next
		
		return aResults
	
		def MatchingBetween(nStart, nEnd)
			return This. MatchingNumbersBetween(nStart, nEnd)

	def CountMatchingBetween(nStart, nEnd)
		if CheckParams()
			if NOT isNumber(nStart)
				StzRaise("Incorrect param type! nStart mustr be a number.")
			ok

			if isList(nEnd) and StzListQ(nEnd).IsAndNamedPAram()
				nEnd = nEnd[2]
			ok

			if NOT isNumber(nEnd)
				StzRaise("Incorrect param type! nEnd mustr be a number.")
			ok
		ok

		nCount = 0
		
		for nNum = nStart to nEnd
			if This.Match(nNum)
				nCount++
			ok
		next
		
		return nCount

		def CountMatchingNumbersBetween(nStart, nEnd)
			return This.CountMatchingBetween(nStart, nEnd)

		def HowManyMatchingNumbersBetween(nStart, nEnd)
			return This.CountMatchingBetween(nStart, nEnd)

		def NumberOfMatchingNumbersBetween(nStart, nEnd)
			return This.CountMatchingBetween(nStart, nEnd)
	
	  #----------------------#
	 #  DEBUG METHODS       #
	#----------------------#
	
	def EnableDebug()
		@bDebugMode = TRUE
	
	def DisableDebug()
		@bDebugMode = FALSE
	
	def SetDebug(bFlag)
		@bDebugMode = bFlag
	
	  #----------------------#
	 #  HELPER METHODS      #
	#----------------------#
	
	def IsNumeric(cStr)
		if cStr = ""
			return FALSE
		ok
		
		nLen = len(cStr)
		for i = 1 to nLen
			cChar = @substr(cStr, i, i)
			if not isDigit(cChar) and cChar != "-"
				return FALSE
			ok
		next
		

		return TRUE
