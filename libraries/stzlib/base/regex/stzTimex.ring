# Softanza Time Regex Engine

func StzTimeRegexQ(cPattern)
	return new stzTimex(cPattern)

func StzTimexQ(cPattern)
	return StzTimeRegexQ(cPattern)

func Tx(cPattern)
	return StzTimeRegexQ(cPattern)

class stzTimex

	@cPattern		# Original pattern string
	@aTokens		# Parsed token definitions
	@bDebugMode = false

	# Token type patterns
	@cHourPattern = '^@H'		# Hour (0-23)
	@cHour12Pattern = '^@H12'	# Hour (1-12)
	@cMinutePattern = '^@M'		# Minute (0-59)
	@cSecondPattern = '^@S'		# Second (0-59)
	@cMillisecPattern = '^@MS'	# Millisecond (0-999)
	@cPeriodPattern = '^@P'		# AM/PM
	@cTimePattern = '^@T'		# Complete time (HH:MM:SS)
	@cAnyPattern = '^@\$'		# Any time component

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
	
		# Extract keyword (2-4 chars for @MS, @H12)
		cKeyword = ""
		cRemainder = ""
		
		if @substr(cTokenStr, 1, 4) = "@H12"
			cKeyword = "@H12"
			cRemainder = @substr(cTokenStr, 5, len(cTokenStr))
		but @substr(cTokenStr, 1, 3) = "@MS"
			cKeyword = "@MS"
			cRemainder = @substr(cTokenStr, 4, len(cTokenStr))
		else
			cKeyword = @substr(cTokenStr, 1, 2)
			cRemainder = @substr(cTokenStr, 3, len(cTokenStr))
		ok
	
		# Check if remainder has constraints
		bHasConstraints = false
		if len(cRemainder) > 0
			if cRemainder[1] = "(" or cRemainder[1] = "{"
				bHasConstraints = true
			ok
		ok
	
		if bHasConstraints
			# Parse constraints AND quantifier
			aResult = This.ParseConstraintsAndQuantifier(cRemainder, cKeyword)
			aConstraints = aResult[1]
			nMin = aResult[2]
			nMax = aResult[3]
			nQuantifier = aResult[4]
		else
			# Parse quantifier directly
			if len(cRemainder) > 0
				aQuantInfo = This.ParseQuantifier(cRemainder)
				nMin = aQuantInfo[1]
				nMax = aQuantInfo[2]
				nQuantifier = aQuantInfo[3]
			ok
		ok
	
		# Build token
		aToken = This.BuildToken(cKeyword, nMin, nMax, nQuantifier, aConstraints, bNegated)
		
		return aToken

	def ParseQuantifier(cStr)
		nMin = 1
		nMax = 1
		nQuantifier = 1
		cRemainder = cStr
	
		# Check for +, *, ?
		if len(cStr) > 0
			if cStr[1] = "+"
				nMin = 1
				nMax = 999999999
				cRemainder = @substr(cStr, 2, len(cStr))
				return [nMin, nMax, nQuantifier, cRemainder]
	
			but cStr[1] = "*"
				nMin = 0
				nMax = 999999999
				cRemainder = @substr(cStr, 2, len(cStr))
				return [nMin, nMax, nQuantifier, cRemainder]
	
			but cStr[1] = "?"
				nMin = 0
				nMax = 1
				cRemainder = @substr(cStr, 2, len(cStr))
				return [nMin, nMax, nQuantifier, cRemainder]
			ok
		ok
	
		# Check for range pattern
		oSectionMatch = rx('^(\d+)-(\d+)')
		if oSectionMatch.Match(cStr)
			aMatches = @split(oSectionMatch.Matches()[1], "-")
			nMin = 0+ aMatches[1]
			nMax = 0+ aMatches[2]
			
			if nMin > nMax
				stzraise("Error: Invalid range - min > max")
			ok
			
			nMatchLen = len(aMatches[1]) + 1 + len(aMatches[2])
			cRemainder = @substr(cStr, nMatchLen + 1, len(cStr))
			return [nMin, nMax, nQuantifier, cRemainder]
		ok
	
		# Check for single number
		oNumberMatch = rx('^\d+')
		if oNumberMatch.Match(cStr)
			aMatches = oNumberMatch.Matches()
			nQuantifier = 0+ aMatches[1]
			nMin = nQuantifier
			nMax = nQuantifier
			cRemainder = @substr(cStr, len(aMatches[1]) + 1, len(cStr))
		ok
	
		return [nMin, nMax, nQuantifier, cRemainder]

	def ParseConstraints(cStr, cKeyword)
		aConstraints = []
	
		# Parse range constraints: (min..max)
		oRangeMatch = rx('\((\d+)\.\.(\d+)\)')
		if oRangeMatch.Match(cStr)
			aMatches = oRangeMatch.Matches()
			cRangeStr = aMatches[1]
			cRangeContent = @substr(cRangeStr, 2, len(cRangeStr) - 1)
			aParts = @split(cRangeContent, "..")
			aConstraints + ["range", [0+ aParts[1], 0+ aParts[2]]]
		ok
	
		# Parse set constraints: {val1;val2;val3}
		oSetMatch = rx('\{([^}]+)\}')
		if oSetMatch.Match(cStr)
			aMatches = oSetMatch.Matches()
			cSetStr = aMatches[1]
			cSetContent = substr(cSetStr, 2, len(cSetStr) - 2)
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
	
		return aConstraints

	def ParseConstraintsAndQuantifier(cStr, cKeyword)
		aConstraints = []
		nMin = 1
		nMax = 1
		nQuantifier = 1
		cRemainder = cStr
	
		# Parse constraints first
		aConstraints = This.ParseConstraints(cStr, cKeyword)
		
		# Remove constraints from string
		oRangeMatch = rx('^\((\d+)\.\.(\d+)\)')
		if oRangeMatch.Match(cRemainder)
			aMatches = oRangeMatch.Matches()
			cRemainder = @substr(cRemainder, len(aMatches[1]) + 1, len(cRemainder))
		ok
		
		oSetMatch = rx('^\{([^}]+)\}')
		if oSetMatch.Match(cRemainder)
			aMatches = oSetMatch.Matches()
			cRemainder = @substr(cRemainder, len(aMatches[1]) + 1, len(cRemainder))
		ok
		
		# Parse quantifier
		if len(cRemainder) > 0
			aQuantInfo = This.ParseQuantifier(cRemainder)
			nMin = aQuantInfo[1]
			nMax = aQuantInfo[2]
			nQuantifier = aQuantInfo[3]
		ok
	
		return [aConstraints, nMin, nMax, nQuantifier]

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
		on "@H"
			aToken + ["type", "hour"]
		on "@H12"
			aToken + ["type", "hour12"]
		on "@M"
			aToken + ["type", "minute"]
		on "@S"
			aToken + ["type", "second"]
		on "@MS"
			aToken + ["type", "millisecond"]
		on "@P"
			aToken + ["type", "period"]
		on "@T"
			aToken + ["type", "time"]
		on "@$"
			aToken + ["type", "any"]
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

	def Match(paTimeComponents)
		if NOT isList(paTimeComponents)
			return false
		ok

		try
			return This.BacktrackMatch(@aTokens, paTimeComponents, 1, 1)
		catch
			if @bDebugMode
				? "Error during matching"
			ok
			return false
		done

	def BacktrackMatch(aTokens, aComponents, nTokenIndex, nCompIndex)
		nLenTokens = len(aTokens)
		nLenComps = len(aComponents)

		if nTokenIndex > nLenTokens
			return nCompIndex > nLenComps
		ok

		aToken = aTokens[nTokenIndex]
		nMax = Min([aToken[:max], nLenComps - nCompIndex + 1])

		for nMatchCount = aToken[:min] to nMax
			bSuccess = true
			nCIdx = nCompIndex

			for i = 1 to nMatchCount
				if nCIdx > nLenComps
					bSuccess = false
					exit
				ok

				xComponent = aComponents[nCIdx]
				
				if NOT This.MatchComponent(xComponent, aToken)
					bSuccess = false
					exit
				ok

				nCIdx++
			next

			if bSuccess
				if nTokenIndex = nLenTokens
					if nCIdx = nLenComps + 1
						return true
					ok
				else
					if This.BacktrackMatch(aTokens, aComponents, nTokenIndex + 1, nCIdx)
						return true
					ok
				ok
			ok
		next

		if aToken[:min] = 0
			if This.BacktrackMatch(aTokens, aComponents, nTokenIndex + 1, nCompIndex)
				return true
			ok
		ok

		return false

	def MatchComponent(xComponent, aToken)
		bMatch = false
		
		# Type checking
		switch aToken[:keyword]
		on "@H"
			bMatch = This.IsValidHour(xComponent)
		on "@H12"
			bMatch = This.IsValidHour12(xComponent)
		on "@M"
			bMatch = This.IsValidMinute(xComponent)
		on "@S"
			bMatch = This.IsValidSecond(xComponent)
		on "@MS"
			bMatch = This.IsValidMillisecond(xComponent)
		on "@P"
			bMatch = This.IsValidPeriod(xComponent)
		on "@T"
			bMatch = This.IsValidTime(xComponent)
		on "@$"
			bMatch = true
		off
	
		if NOT bMatch and NOT aToken[:negated]
			return false
		ok
	
		# Check constraints
		nLen = len(aToken[:constraints])
		bConstraintsMet = true
		
		for i = 1 to nLen
			aConstraint = aToken[:constraints][i]
			cType = aConstraint[1]
			
			switch cType
			on "range"
				aRange = aConstraint[2]
				nVal = This.ComponentToNumber(xComponent, aToken[:type])
				if nVal < aRange[1] or nVal > aRange[2]
					bConstraintsMet = false
					exit
				ok
			
			on "set"
				aSet = aConstraint[2]
				nVal = This.ComponentToNumber(xComponent, aToken[:type])
				bInSet = false
				nSetLen = len(aSet)
				for j = 1 to nSetLen
					if nVal = aSet[j]
						bInSet = true
						exit
					ok
				next
				if NOT bInSet
					bConstraintsMet = false
					exit
				ok
			off
		next
	
		bMatch = bMatch and bConstraintsMet
	
		if aToken[:negated]
			bMatch = NOT bMatch
		ok
	
		return bMatch

	  #--------------------#
	 #   HELPER METHODS   #
	#--------------------#

	def IsValidHour(x)
		if isString(x)
			if NOT rx('^\d+$').Match(x)
				return false
			ok
			x = 0+ x
		ok
		
		if NOT isNumber(x)
			return false
		ok
		
		return x >= 0 and x <= 23

	def IsValidHour12(x)
		if isString(x)
			if NOT rx('^\d+$').Match(x)
				return false
			ok
			x = 0+ x
		ok
		
		if NOT isNumber(x)
			return false
		ok
		
		return x >= 1 and x <= 12

	def IsValidMinute(x)
		if isString(x)
			if NOT rx('^\d+$').Match(x)
				return false
			ok
			x = 0+ x
		ok
		
		if NOT isNumber(x)
			return false
		ok
		
		return x >= 0 and x <= 59

	def IsValidSecond(x)
		return This.IsValidMinute(x)

	def IsValidMillisecond(x)
		if isString(x)
			if NOT rx('^\d+$').Match(x)
				return false
			ok
			x = 0+ x
		ok
		
		if NOT isNumber(x)
			return false
		ok
		
		return x >= 0 and x <= 999

	def IsValidPeriod(x)
		if NOT isString(x)
			return false
		ok
		
		cUpper = upper(@trim(x))
		return cUpper = "AM" or cUpper = "PM"

	def IsValidTime(x)
		if NOT isString(x)
			return false
		ok
		
		# HH:MM:SS or HH:MM:SS.mmm
		return rx('^\d{1,2}:\d{2}:\d{2}(\.\d{1,3})?$').Match(x)

	def ComponentToNumber(x, cType)
		if isNumber(x)
			return x
		ok
		
		if isString(x)
			if rx('^\d+$').Match(x)
				return 0+ x
			ok
		ok
		
		return 0

	  #---------------------------#
	 #     DEBUG METHODS         #
	#---------------------------#

	def EnableDebug()
		@bDebugMode = true

	def DisableDebug()
		@bDebugMode = false

	def TokensXT()
		return @aTokens

	def Tokens()
		acResult = []
		nLen = len(@aTokens)

		for i = 1 to nLen
			acResult + @aTokens[i][:keyword]
		next

		return acResult

	def TokensU()
		return U(This.Tokens())

	def UniqueTokens()
		return This.TokensU()

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
