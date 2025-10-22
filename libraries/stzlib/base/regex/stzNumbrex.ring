# Softanza Number Regex Engine

func StzNumberRegexQ(cPattern)
	return new stzNumberex(cPattern)

func StzNumberexQ(cPattern)
	return StzNumberRegexQ(cPattern)

func Nx(cPattern)
	return StzNumberRegexQ(cPattern)

class stzNumberex

	@cPattern		# Original pattern string
	@aTokens		# Parsed token definitions
	@bDebugMode = false

	# Token type patterns
	@cIntPattern = '^@I'		# Integer
	@cFloatPattern = '^@F'		# Float
	@cPosPattern = '^@P'		# Positive
	@cNegPattern = '^@N'		# Negative
	@cEvenPattern = '^@E'		# Even
	@cOddPattern = '^@O'		# Odd
	@cPrimePattern = '^@PR'		# Prime
	@cRangePattern = '^@R'		# Range
	@cAnyPattern = '^@\$'		# Any number
	@cDigitPattern = '^@D'		# Digit count
	@cDivisiblePattern = '^@DIV'	# Divisible by

	  #-------------------#
	 #  INITIALIZATION   #
	#-------------------#

	def init(cPattern)
		if NOT isString(cPattern)
			stzraise("Error: Pattern must be a string")
		ok

		@cPattern = This.NormalizePattern(cPattern)
		@aTokens = This.ParsePattern(@cPattern)
		This.OptimizeTokens()

	def NormalizePattern(cPattern)
		cPattern = @trim(cPattern)
		
		# Ensure pattern is enclosed in brackets
		if NOT (StartsWith(cPattern, "[") and EndsWith(cPattern, "]"))
			cPattern = "[" + cPattern + "]"
		ok
		
		return cPattern

	def ParsePattern(cPattern)
		# Remove outer brackets
		cPattern = @trim(cPattern)
		cInner = @substr(cPattern, 2, len(cPattern) - 1)
		cInner = @trim(cInner)

		# Split at commas
		aParts = This.SplitAtCommas(cInner)

		# Parse each token
		aTokens = []
		nLen = len(aParts)
		for i = 1 to nLen
			aTokens + This.ParseToken(@trim(aParts[i]))
		next

		return aTokens

	def SplitAtCommas(cStr)
		aParts = []
		cCurrent = ""
		acChars = Chars(cStr)
		nLen = len(acChars)
		
		for i = 1 to nLen
			cChar = acChars[i]
			
			if cChar = ","
				aParts + @trim(cCurrent)
				cCurrent = ""
			else
				cCurrent += cChar
			ok
		next
		
		if len(cCurrent) > 0
			aParts + @trim(cCurrent)
		ok
		
		return aParts

	def ParseToken(cTokenStr)
		# Default values
		bNegated = false
		nMin = 1
		nMax = 1
		nQuantifier = 1
		aConstraints = []

		# Check for negation
		if StartsWith(cTokenStr, "@!")
			bNegated = true
			cTokenStr = @substr(cTokenStr, 3, len(cTokenStr))
		ok

		# Ensure token starts with @
		if NOT StartsWith(cTokenStr, "@")
			cTokenStr = "@" + cTokenStr
		ok

		# Extract keyword (2-3 chars)
		cKeyword = ""
		cRemainder = ""
		
		if @substr(cTokenStr, 1, 4) = "@DIV"
			cKeyword = "@DIV"
			cRemainder = @substr(cTokenStr, 5, len(cTokenStr))
		but @substr(cTokenStr, 1, 3) = "@PR"
			cKeyword = "@PR"
			cRemainder = @substr(cTokenStr, 4, len(cTokenStr))
		else
			cKeyword = @substr(cTokenStr, 1, 2)
			cRemainder = @substr(cTokenStr, 3, len(cTokenStr))
		ok

		# Parse quantifiers
		if len(cRemainder) > 0
			aQuantInfo = This.ParseQuantifier(cRemainder)
			nMin = aQuantInfo[1]
			nMax = aQuantInfo[2]
			nQuantifier = aQuantInfo[3]
			cRemainder = aQuantInfo[4]
		ok

		# Parse constraints (ranges, sets, etc)
		if len(cRemainder) > 0
			aConstraints = This.ParseConstraints(cRemainder, cKeyword)
		ok

		# Build token
		aToken = This.BuildToken(cKeyword, nMin, nMax, nQuantifier, aConstraints, bNegated)
		
		return aToken

	def ParseQuantifier(cStr)
		nMin = 1
		nMax = 1
		nQuantifier = 1
		cRemainder = cStr

		# Check for range pattern (e.g., "2-5")
		oRangeMatch = rx('(\d+)-(\d+)')
		if oRangeMatch.Match(cStr)
			aMatches = @split( oRangeMatch.Matches()[1], "-" )
			nMin = 0+ aMatches[1]
			nMax = 0+ aMatches[2]
			
			if nMin > nMax
				stzraise("Error: Invalid range - min > max")
			ok
			
			nMatchLen = len(aMatches[1]) + 1 + len(aMatches[2])
			cRemainder = @substr(cStr, nMatchLen + 1, len(cStr))

		# Check for +, *, ?
		but cStr[1] = "+"
			nMin = 1
			nMax = 999999999
			cRemainder = @substr(cStr, 2, len(cStr))

		but cStr[1] = "*"
			nMin = 0
			nMax = 999999999
			cRemainder = @substr(cStr, 2, len(cStr))

		but cStr[1] = "?"
			nMin = 0
			nMax = 1
			cRemainder = @substr(cStr, 2, len(cStr))

		# Check for single number
		else
			oNumberMatch = rx('^\d+')
			if oNumberMatch.Match(cStr)
				aMatches = oNumberMatch.Matches()
				nQuantifier = 0+ aMatches[1]
				nMin = nQuantifier
				nMax = nQuantifier
				cRemainder = @substr(cStr, len(aMatches[1]) + 1, len(cStr))
			ok
		ok

		return [nMin, nMax, nQuantifier, cRemainder]

	def ParseConstraints(cStr, cKeyword)
		aConstraints = []

		# Parse range constraints: (min..max)
		oRangeMatch = rx('\((-?\d+(?:\.\d+)?)\.\.(-?\d+(?:\.\d+)?)\)')
		if oRangeMatch.Match(cStr)
			cTempStr = StzStringQ(oRangeMatch.Matches()[1]).SubStringsBoundedBy([ "(", ")" ])[1]
			aMatches = @split( cTempStr, "..")
			aConstraints + ["range", [0+ aMatches[1], 0+ aMatches[2]]]

		ok

		# Parse set constraints: {val1;val2;val3}
		oSetMatch = rx('\{([^}]+)\}')
		if oSetMatch.Match(cStr)
			aMatches = oSetMatch.Matches()
			cSetContent = aMatches[1]
			aParts = @split(cSetContent, ";")
			
			aValues = []
			nLen = len(aParts)
			for i = 1 to nLen
				cVal = @trim(aParts[i])
				if len(cVal) > 0
					aValues + (0+ cVal)
				ok
			next
			
			aConstraints + ["set", aValues]
		ok

		# Parse divisible constraint: @DIV(n)
		if cKeyword = "@DIV"
			oDivMatch = rx('\((\d+)\)')
			if oDivMatch.Match(cStr)
				aMatches = oDivMatch.Matches()
				aConstraints + ["divisor", 0+ aMatches[1]]
			ok
		ok

		# Parse digit count: @D(n)
		if cKeyword = "@D"
			oDigitMatch = rx('\((\d+)\)')
			if oDigitMatch.Match(cStr)
				aMatches = oDigitMatch.Matches()
				aConstraints + ["digits", 0+ aMatches[1]]
			ok
		ok

		return aConstraints

	def BuildToken(cKeyword, nMin, nMax, nQuantifier, aConstraints, bNegated)
		aToken = [
			["keyword", cKeyword],
			["min", nMin],
			["max", nMax],
			["quantifier", nQuantifier],
			["constraints", aConstraints],
			["negated", bNegated]
		]

		# Add type-specific info
		switch cKeyword
		on "@I"
			aToken + ["type", "integer"]
		on "@F"
			aToken + ["type", "float"]
		on "@P"
			aToken + ["type", "positive"]
		on "@N"
			aToken + ["type", "negative"]
		on "@E"
			aToken + ["type", "even"]
		on "@O"
			aToken + ["type", "odd"]
		on "@PR"
			aToken + ["type", "prime"]
		on "@R"
			aToken + ["type", "range"]
		on "@$"
			aToken + ["type", "any"]
		on "@D"
			aToken + ["type", "digits"]
		on "@DIV"
			aToken + ["type", "divisible"]
		off

		return aToken

	def OptimizeTokens()
		# Merge adjacent compatible tokens
		nLen = len(@aTokens)
		
		if nLen <= 1
			return
		ok
		
		for i = nLen to 2 step -1
			aToken1 = @aTokens[i-1]
			aToken2 = @aTokens[i]
			
			# Can merge if same type and no constraints
			if aToken1[:keyword] = aToken2[:keyword] and
			   len(aToken1[:constraints]) = 0 and
			   len(aToken2[:constraints]) = 0
				
				nNewMin = Min([aToken1[:min], aToken2[:min]])
				nNewMax = aToken1[:max] + aToken2[:max]
				
				@aTokens[i-1][:min] = nNewMin
				@aTokens[i-1][:max] = nNewMax
				del(@aTokens, i)
			ok
		next

	  #--------------------#
	 #   MATCHING LOGIC   #
	#--------------------#

	def Match(paNumbers)
		if NOT isList(paNumbers)
			return false
		ok

		# Ensure all elements are numbers
		nLen = len(paNumbers)
		for i = 1 to nLen
			if NOT isNumber(paNumbers[i])
				return false
			ok
		next

		try
			return This.BacktrackMatch(@aTokens, paNumbers, 1, 1)
		catch
			if @bDebugMode
				? "Error during matching"
			ok
			return false
		done

	def BacktrackMatch(aTokens, aNumbers, nTokenIndex, nNumberIndex)
		nLenTokens = len(aTokens)
		nLenNumbers = len(aNumbers)

		# Base case: processed all tokens
		if nTokenIndex > nLenTokens
			return nNumberIndex > nLenNumbers
		ok

		aToken = aTokens[nTokenIndex]

		# Try different match counts
		nMin = Min([aToken[:max], nLenNumbers - nNumberIndex + 1])

		for nMatchCount = aToken[:min] to nMin
			bSuccess = true
			nNumIdx = nNumberIndex

			# Try to match nMatchCount numbers
			for i = 1 to nMatchCount
				if nNumIdx > nLenNumbers
					bSuccess = false
					exit
				ok

				nNumber = aNumbers[nNumIdx]
				
				if NOT This.MatchNumber(nNumber, aToken)
					bSuccess = false
					exit
				ok

				nNumIdx++
			next

			if bSuccess
				# Last token - ensure complete match
				if nTokenIndex = nLenTokens
					if nNumIdx = nLenNumbers + 1
						return true
					ok
				else
					# Recurse for remaining tokens
					if This.BacktrackMatch(aTokens, aNumbers, nTokenIndex + 1, nNumIdx)
						return true
					ok
				ok
			ok
		next

		# Handle optional tokens
		if aToken[:min] = 0
			if This.BacktrackMatch(aTokens, aNumbers, nTokenIndex + 1, nNumberIndex)
				return true
			ok
		ok

		return false

	def MatchNumber(nNumber, aToken)
		bMatch = false

		# Type checking
		switch aToken[:keyword]
		on "@I"
			bMatch = This.IsInteger(nNumber)
		on "@F"
			bMatch = This.IsFloat(nNumber)
		on "@P"
			bMatch = nNumber > 0
		on "@N"
			bMatch = nNumber < 0
		on "@E"
			bMatch = This.IsEven(nNumber)
		on "@O"
			bMatch = This.IsOdd(nNumber)
		on "@PR"
			bMatch = This.IsPrime(nNumber)
		on "@$"
			bMatch = true
		on "@D"
			# Handled in constraints
			bMatch = true
		on "@DIV"
			# Handled in constraints
			bMatch = true
		off

		# Apply negation
		if aToken[:negated]
			bMatch = NOT bMatch
		ok

		if NOT bMatch
			return false
		ok

		# Check constraints
		nLen = len(aToken[:constraints])
		for i = 1 to nLen
			aConstraint = aToken[:constraints][i]
			cType = aConstraint[1]

			switch cType
			on "range"
				aRange = aConstraint[2]
				if nNumber < aRange[1] or nNumber > aRange[2]
					return false
				ok

			on "set"
				aSet = aConstraint[2]
				bInSet = false
				nSetLen = len(aSet)
				for j = 1 to nSetLen
					if nNumber = aSet[j]
						bInSet = true
						exit
					ok
				next
				if NOT bInSet
					return false
				ok

			on "divisor"
				nDivisor = aConstraint[2]
				if (nNumber % nDivisor) != 0
					return false
				ok

			on "digits"
				nDigits = aConstraint[2]
				if This.CountDigits(nNumber) != nDigits
					return false
				ok
			off
		next

		return true

	  #--------------------#
	 #   HELPER METHODS   #
	#--------------------#

	def IsInteger(n)
		return n = floor(n)

	def IsFloat(n)
		return n != floor(n)

	def IsEven(n)
		if NOT This.IsInteger(n)
			return false
		ok
		return (n % 2) = 0

	def IsOdd(n)
		if NOT This.IsInteger(n)
			return false
		ok
		return (n % 2) != 0

	def IsPrime(n)
		if NOT This.IsInteger(n) or n < 2
			return false
		ok

		if n = 2
			return true
		ok

		if (n % 2) = 0
			return false
		ok

		for i = 3 to sqrt(n) step 2
			if (n % i) = 0
				return false
			ok
		next

		return true

	def CountDigits(n)
		n = fabs(n)
		if n = 0
			return 1
		ok
		return floor(log10(n)) + 1

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
			
			if aToken[:min] != aToken[:max]
				cInfo += " (" + aToken[:min] + "-" + aToken[:max] + ")"
			but aToken[:min] > 1
				cInfo += aToken[:min]
			ok

			if len(aToken[:constraints]) > 0
				cInfo += " [constraints: " + len(aToken[:constraints]) + "]"
			ok

			if aToken[:negated]
				cInfo += " [negated]"
			ok
			
			aInfo + cInfo
		next
		
		return aInfo

	def Pattern()
		return @cPattern
