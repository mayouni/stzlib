# stzTimex - Temporal Pattern Matching for Softanza
# A regex-like pattern language for time structures

# Quick constructor functions
func StzTimexQ(cPattern)
	return new stzTimex(cPattern)

func Timex(cPattern)
	return new stzTimex(cPattern)

func Tx(cPattern)
	return new stzTimex(cPattern)

class stzTimex
	
	@cPattern           # The pattern string, e.g., "{@Instant -> @Duration(1h..2h) -> @Event}"
	@aTokens            # Parsed token definitions
	@oTarget            # Target data to match against (stzTimeline, list, etc.)
	@bDebugMode = FALSE # Debug flag
	@aMatchedParts = [] # Extracted matches like regex groups
	
	# Pattern definitions for parsing
	@cInstantPattern = '@Instant(?:\((.*?)\))?'
	@cDurationPattern = '@Duration(?:\((.*?)\))?'
	@cEventPattern = '@Event(?:\((.*?)\))?'
	@cSequencePattern = '@Sequence(?:\((.*?)\))?'
	@cFramePattern = '@Frame(?:\((.*?)\))?'
	
	@cQuantifierPattern = '([+*?~]|\d+|\d+-\d+)'
	@cNegationPattern = '@!'
	@cConstraintPattern = '\((.*?)\)'
	@cSetPattern = '\{(.*?)\}'
	
	  #-------------------#
	 #  INITIALIZATION   #
	#-------------------#
	
	def init(cPattern)
		if NOT isString(cPattern)
			raise("Error: Pattern must be a string")
		ok
		
		@cPattern = This.NormalizePattern(cPattern)

		@aMatchedParts = []
		
		# Parse pattern into tokens
		try
			@aTokens = This.ParsePattern(@cPattern)
			
			if @bDebugMode
				? "=== stzTimex Init ==="
				? "Pattern: " + @cPattern
				? "Tokens parsed: " + len(@aTokens)
			ok
		catch
			raise("Pattern initialization failed: " + cCatchError)
		done
	
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
		cInner = @substr(cPattern, 2, len(cPattern)-1)
		cInner = trim(cInner)
		
		if @bDebugMode
			? "Parsing inner pattern: " + cInner
		ok
		
		# Split by sequence operator (->)
		aParts = This.SplitByOperator(cInner, "->")
		
		aTokens = []
		nLen = len(aParts)
		for i = 1 to nLen
			cPart = @trim(aParts[i])
			
			if cPart = ""
				loop
			ok
			
			# Check for alternation (|)
			if contains(cPart, "|")
				aToken = This.ParseAlternation(cPart)
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

			but nDepth = 0 and @substr(cStr, i, i + nOpLen - 1) = cOperator
				aParts + @trim(cCurrent)
				cCurrent = ""
				i += nOpLen - 1  # Skip operator
			else
				cCurrent += cChar
			ok
		next
		
		if len(cCurrent) > 0
			aParts + @trim(cCurrent)
		ok
		
		return aParts
	
	def ParseAlternation(cTokenStr)
		# Handle (A | B | C) patterns
		# Strip outer parentheses if present
		if startsWith(cTokenStr, "(") and endsWith(cTokenStr, ")")
			cTokenStr = @substr(cTokenStr, 2, len(cTokenStr) - 1)
		ok
		
		# Split by |
		aParts = This.SplitByOperator(cTokenStr, "|")
		nLenParts = len(aParts)
		aAlternatives = []
		
		for i = 1 to nLenParts
			cPart = @trim(aParts[i])
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
	
	def ParseSingleToken(cTokenStr)
		cTokenStr = @trim(cTokenStr)
		
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
		cLabel = ""
		aConstraints = []
		nMin = 1
		nMax = 1
		bCyclic = FALSE
		
		# Identify token type
		if startsWith(cTokenStr, "@Instant")
			cType = "instant"
			cTokenStr = @substr(cTokenStr, 9, len(cTokenStr))

		but startsWith(cTokenStr, "@Duration")
			cType = "duration"
			cTokenStr = @substr(cTokenStr, 10, len(cTokenStr))

		but startsWith(cTokenStr, "@Event")
			cType = "event"
			cTokenStr = @substr(cTokenStr, 7, len(cTokenStr))

		but startsWith(cTokenStr, "@Sequence")
			cType = "sequence"
			cTokenStr = @substr(cTokenStr, 10, len(cTokenStr))

		but startsWith(cTokenStr, "@Frame")
			cType = "frame"
			cTokenStr = @substr(cTokenStr, 7, len(cTokenStr))

		else
			if @bDebugMode
				? "Unknown token type: " + cTokenStr
			ok
			return []
		ok
		
		# Extract label from parentheses
		nOpenParen = substr(cTokenStr, "(")
		if nOpenParen > 0
			nCloseParen = substr(cTokenStr, ")")
			if nCloseParen > nOpenParen
				cLabel = @substr(cTokenStr, nOpenParen + 1, nCloseParen - nOpenParen - 1)
				# Parse constraints from label
				aConstraints = This.ParseConstraints(cLabel)
			ok
		ok
		
		# Extract quantifier from end
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
		but cLastChar = "~"
			bCyclic = TRUE
		ok
		
		# Check for numeric quantifiers
		if isDigit(cLastChar)
			# Look for m-n pattern
			nLenTokenStr = len(cTokenStr)

			for i = nLenTokenStr to 1 step -1
				cChar = @substr(cTokenStr, i, i+1)
				if not isDigit(cChar) and cChar != "-"
					cQuantPart = @substr(cTokenStr, i + 1, nLenTokenStr)
					if contains(cQuantPart, "-")
						aRange = @split(cQuantPart, "-")
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
			["label", cLabel],
			["constraints", aConstraints],
			["min", nMin],
			["max", nMax],
			["cyclic", bCyclic],
			["negated", bNegated]
		]
	
	def ParseConstraints(cConstraintStr)
		# Parse constraints like "1h..2h:working" or "{Mon;Wed;Fri}"
		aConstraints = []
		
		if cConstraintStr = ""
			return aConstraints
		ok
		
		# Check for range (1h..2h)
		if contains(cConstraintStr, "..")
			aParts = @split(cConstraintStr, "..")
			if len(aParts) = 2
				cStart = @trim(aParts[1])
				cEnd = @trim(aParts[2])
				
				# Check for step modifier (:15min)
				cStep = ""
				if contains(cEnd, ":")
					aEndParts = @split(cEnd, ":")
					cEnd = @trim(aEndParts[1])
					if len(aEndParts) > 1
						cStep = @trim(aEndParts[2])
					ok
				ok
				
				aConstraints + [
					["type", "range"],
					["start", cStart],
					["end", cEnd],
					["step", cStep]
				]
			ok
		ok
		
		# Check for set {Mon;Wed;Fri}
		nBraceStart = substr(cConstraintStr, "{")
		if nBraceStart > 0
			nBraceEnd = substr(cConstraintStr, "}")
			if nBraceEnd > nBraceStart
				cSetContent = @substr(cConstraintStr, nBraceStart + 1, nBraceEnd - 1)
				aSetValues = @split(cSetContent, ";")
				
				aConstraints + [
					["type", "set"],
					["values", aSetValues]
				]
			ok
		ok
		
		# Check for context modifier (:working, :unique)
		if contains(cConstraintStr, ":")
			aParts = @split(cConstraintStr, ":")
			nLenParts = len(aparts)

			for i = 2 to nLenParts
				cModifier = @trim(aParts[i])
				if cModifier != ""
					aConstraints + [
						["type", "modifier"],
						["value", cModifier]
					]
				ok
			next
		ok
		
		return aConstraints
	
	  #--------------------#
	 #  MATCHING LOGIC    #
	#--------------------#
	
	def Match(oTargetData)
		@oTarget = oTargetData
		
		# Normalize target to canonical form
		aNormalized = This.NormalizeTarget(@oTarget)
		
		if @bDebugMode
			? "=== Matching ==="
			? "Tokens: " + len(@aTokens)
			? "Normalized data: " + len(aNormalized)
		ok
		
		# Perform backtracking match
		try
			bResult = This.BacktrackMatch(@aTokens, aNormalized, 1, 1, [])
			
			if bResult
				# Extract matched parts
				This.ExtractMatches(aNormalized)
			ok
			
			return bResult
		catch
			if @bDebugMode
				? "Match error: " + cCatchError
			ok
			return FALSE
		done
	
	def NormalizeTarget(oTarget)
		# Convert various input types to standard temporal sequence
		aNormalized = []
		
		# Handle stzTimeline
		if @IsStzTimeLine(oTarget)
			# Extract points and spans
			aPoints = oTarget.Points()
			nLenPoints = len(aPpoints)

			for i = 1 to nLenPoints
				aPoint = aPoints[i]
				aNormalized + [
					["type", "instant"],
					["label", aPoint[1]],
					["datetime", aPoint[2]],
					["object", NULL]
				]
			next
			
			aSpans = oTarget.Spans()
			nLenSpans = len(aSpans)

			for i = 1 to nLenSpans
				aSpan = aSpans[i]
				aNormalized + [
					["type", "duration"],
					["label", aSpan[1]],
					["start", aSpan[2]],
					["end", aSpan[3]],
					["object", NULL]
				]
			next
		
		# Handle stzCalendar
		but @IsStzCalendar(oTarget)
			# Extract working days, holidays, etc.
			aWorkDays = oTarget.WorkingDays()
			nLen = len(aWorkDays)

			for i = 1 to nLen
				aNormalized + [
					["type", "instant"],
					["label", "WorkDay"],
					["datetime", aWorkDays[i]],
					["object", NULL]
				]
			next
		
		# Handle list of dates/times
		but isList(oTarget)
			nLen = len(oTarget)
			for i = 1 to nLen
				xItem = oTarget[i]
				
				if isString(xItem)
					# Try to parse as datetime
					aNormalized + [
						["type", "instant"],
						["label", ""],
						["datetime", xItem],
						["object", NULL]
					]

				but @IsStzDateTime(xItem)
					aNormalized + [
						["type", "instant"],
						["label", ""],
						["datetime", xItem.ToString()],
						["object", xItem]
					]

				but @IsStzDuration(xItem)
					aNormalized + [
						["type", "duration"],
						["label", ""],
						["start", ""],
						["end", ""],
						["object", xItem]
					]
				ok
			next
		
		# Single datetime object
		but @IsStzDateTime(oTarget)
			aNormalized + [
				["type", "instant"],
				["label", ""],
				["datetime", oTarget.ToString()],
				["object", oTarget]
			]
		
		# Single duration object
		but @IsStzDuration(oTarget)
			aNormalized + [
				["type", "duration"],
				["label", ""],
				["start", ""],
				["end", ""],
				["object", oTarget]
			]
		ok
		
		return aNormalized
	
	def BacktrackMatch(aTokens, aNormalized, nTokenIdx, nDataIdx, aMatched)
		nLenTokens = len(aTokens)
		nLenData = len(aNormalized)
		
		# Base case: all tokens processed
		if nTokenIdx > nLenTokens
			return nDataIdx > nLenData
		ok
		
		aToken = aTokens[nTokenIdx]
		
		# Handle alternation
		if aToken[:type] = "alternation"
			nLen = len(aToken[:alternatives])
			for i = 1 to nLen
				aAlt = aToken[:alternatives][i]
				
				# Try this alternative
				aNewTokens = []
				for j = 1 to nTokenIdx - 1
					aNewTokens + aTokens[j]
				next
				aNewTokens + aAlt
				for j = nTokenIdx + 1 to nLenTokens
					aNewTokens + aTokens[j]
				next
				
				if This.BacktrackMatch(aNewTokens, aNormalized, nTokenIdx, nDataIdx, aMatched)
					return TRUE
				ok
			next
			return FALSE
		ok
		
		# Try different match counts within min-max range
		nMin = @Min([aToken[:max], nLenData - nDataIdx + 1])
		
		for nMatchCount = aToken[:min] to nMin
			bSuccess = TRUE
			nElemIdx = nDataIdx
			aLocalMatched = aMatched
			
			# Try to match nMatchCount elements
			for i = 1 to nMatchCount
				if nElemIdx > nLenData
					bSuccess = FALSE
					exit
				ok
				
				aData = aNormalized[nElemIdx]
				
				# Check if token type matches data type
				bTypeMatch = (aToken[:type] = aData[:type]) or
				             (aToken[:type] = "event" and aData[:type] = "instant")
				
				if aToken[:negated]
					bTypeMatch = NOT bTypeMatch
				ok
				
				if not bTypeMatch
					bSuccess = FALSE
					exit
				ok
				
				# Check label if specified
				if aToken[:label] != "" and aData[:label] != ""
					if aToken[:label] != aData[:label]
						bSuccess = FALSE
						exit
					ok
				ok
				
				# Check constraints
				if not This.CheckConstraints(aToken[:constraints], aData)
					bSuccess = FALSE
					exit
				ok
				
				aLocalMatched + aData
				nElemIdx++
			next
			
			if bSuccess
				# For last token, ensure complete match
				if nTokenIdx = nLenTokens
					if nElemIdx = nLenData + 1
						return TRUE
					ok
				else
					# Recurse for remaining tokens
					if This.BacktrackMatch(aTokens, aNormalized, nTokenIdx + 1, nElemIdx, aLocalMatched)
						return TRUE
					ok
				ok
			ok
		next
		
		# Handle optional tokens (min = 0)
		if aToken[:min] = 0
			if This.BacktrackMatch(aTokens, aNormalized, nTokenIdx + 1, nDataIdx, aMatched)
				return TRUE
			ok
		ok
		
		return FALSE
	
	def CheckConstraints(aConstraints, aData)
		# Check if data satisfies all constraints
		nLen = len(aConstraints)
		for i = 1 to nLen
			aConstraint = aConstraints[i]
			
			if aConstraint[:type] = "range"
				# Check if value is within range
				if aData[:type] = "duration"
					# Would need actual duration comparison
					# Simplified for now
				ok
			
			but aConstraint[:type] = "set"
				# Check if value is in set
				bInSet = FALSE
				nLenTemp = len(aConstraint[:values])
				for j = 1 to nLenTemp
					if aData[:label] = aConstraint[:values][j]
						bInSet = TRUE
						exit
					ok
				next
				if not bInSet
					return FALSE
				ok
			
			but aConstraint[:type] = "modifier"
				# Check modifiers like :working, :unique
				# Would need calendar context
			ok
		next
		
		return TRUE
	
	def ExtractMatches(aNormalized)
		# Extract matched parts for later retrieval
		@aMatchedParts = []
		nLen = len(aNormalized)

		for i = 1 to nLen
			aData = aNormalized[i]
			@aMatchedParts + [
				["type", aData[:type]],
				["label", aData[:label]],
				["data", aData]
			]
		next
	
	  #----------------------#
	 #  QUERY METHODS       #
	#----------------------#
	
	def MatchedParts()
		return @aMatchedParts
	
	def Tokens()
		return @aTokens
	
	def TokensXT()
		# Return detailed token information
		aInfo = []
		nLen = len(@aTokens)

		for i = 1 to nLen
			aToken = @aTokens[i]
			
			aTokenInfo = [
				["index", i],
				["type", aToken[:type]],
				["label", aToken[:label]]
			]
			
			if aToken[:min] != 1 or aToken[:max] != 1
				aTokenInfo + ["quantifier", "" + aToken[:min] + "-" + aToken[:max]]
			ok
			
			if len(aToken[:constraints]) > 0
				aTokenInfo + ["constraints", aToken[:constraints]]
			ok
			
			if aToken[:negated]
				aTokenInfo + ["negated", TRUE]
			ok
			
			aInfo + aTokenInfo
		next
		
		return aInfo
	
	def SetTarget(oTarget)
		@oTarget = oTarget
	
	def Pattern()
		return @cPattern
	
	def Explain()
		# Return structured explanation
		return [
			["Pattern", @cPattern],
			["TokenCount", len(@aTokens)],
			["Tokens", This.TokensXT()],
			["TargetSet", @oTarget != NULL],
			["LastMatch", len(@aMatchedParts) > 0]
		]
	
	  #----------------------#
	 #  DEBUG METHODS       #
	#----------------------#
	
	def EnableDebug(bFlag)
		@bDebugMode = bFlag
	
	def DisableDebug()
		@bDebugMode = FALSE
	
	def SetDebug(bFlag)
		@bDebugMode = bFlag
	
	  #----------------------#
	 #  HELPER METHODS      #
	#----------------------#
	
	def @IsStzTimeLine(oObj)
		# Check if object is stzTimeLine instance
		if isObject(oObj)
			cClassName = ring_classname(oObj)
			return contains(cClassName, "timeline")
		ok
		return FALSE
	
	def @IsStzCalendar(oObj)
		# Check if object is stzCalendar instance
		if isObject(oObj)
			cClassName = ring_classname(oObj)
			return contains(cClassName, "calendar")
		ok
		return FALSE
	
	def @IsStzDateTime(oObj)
		# Check if object is stzDateTime instance
		if isObject(oObj)
			cClassName = ring_classname(oObj)
			return contains(cClassName, "datetime")
		ok
		return FALSE
	
	def @IsStzDuration(oObj)
		# Check if object is stzDuration instance
		if isObject(oObj)
			cClassName = ring_classname(oObj)
			return contains(cClassName, "duration")
		ok
		return FALSE
	
	def @Min(aValues)
		nMin = aValues[1]
		nLen = len(aValues)

		for i = 2 to nLen
			if aValues[i] < nMin
				nMin = aValues[i]
			ok
		next
		return nMin
