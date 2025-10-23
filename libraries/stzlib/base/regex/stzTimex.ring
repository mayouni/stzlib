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
//		try
			@aTokens = This.ParsePattern(@cPattern)
			
			if @bDebugMode
				? "=== stzTimex Init ==="
				? "Pattern: " + @cPattern
				? "Tokens parsed: " + len(@aTokens)
			ok
//		catch
//			raise("Pattern initialization failed: " + cCatchError)
//		done
	
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
				cLabel = @substr(cTokenStr, nOpenParen + 1, nCloseParen - 1)
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
	# Parse constraints like "1h..2h:15min" or "{Mon;Wed;Fri}"
	aConstraints = []
	
	if cConstraintStr = ""
		return aConstraints
	ok
	
	# Check for range (1h..2h) - extract step first if present
	cStep = ""
	cWorkingStr = cConstraintStr
	
	if contains(cConstraintStr, ":")
		aParts = @split(cConstraintStr, ":")
		cWorkingStr = @trim(aParts[1])
		if len(aParts) > 1
			cStep = @trim(aParts[2])
		ok
	ok
	
	# Now check for range in the working string
	if contains(cWorkingStr, "..")
		aParts = @split(cWorkingStr, "..")
		if len(aParts) = 2
			cStart = @trim(aParts[1])
			cEnd = @trim(aParts[2])
			
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
	
	return aConstraints
	
def ParseDurationToMinutes(cDuration)
	# Parse duration strings like "1h", "30min", "1h30min", "2h"
	cDuration = lower(@trim(cDuration))
	nMinutes = 0
	
	# Extract hours
	nHPos = substr(cDuration, "h")
	if nHPos > 0
		cHours = left(cDuration, nHPos - 1)
		nMinutes = (0 + cHours) * 60
		cDuration = @substr(cDuration, nHPos + 1, len(cDuration))
	ok
	
	# Extract minutes - FIXED
	if contains(cDuration, "min")
		cMinutes = @substr(cDuration, 1, substr(cDuration, "min") - 1)
		nMinutes += (0 + StzStringQ(cDuration).Numbers()[1])  # ADD @trim() here
	but len(cDuration) > 0  # CHANGE: was cDuration != ""
		# Just a number, assume minutes
		nMinutes += (0 + StzStringQ(cDuration).Numbers()[1])  # ADD @trim() here
	ok
	
	return nMinutes

	  #--------------------#
	 #  MATCHING LOGIC    #
	#--------------------#
	
def Match(oTarget)
	# Full match - pattern must match completely
	return This.MatchExact(oTarget)

def MatchExact(oTarget)
	# Entire timeline must match pattern exactly
	@oTarget = oTarget
	aNormalized = This.NormalizeTarget(@oTarget)
	
	# Must consume all data
	bResult = This.BacktrackMatch(@aTokens, aNormalized, 1, 1, [])
	if bResult
		This.ExtractMatches(aNormalized)
	ok
	return bResult

def MatchPartial(oTarget)
	# Pattern exists somewhere in timeline (prefix match)
	@oTarget = oTarget
	aNormalized = This.NormalizeTarget(@oTarget)
	
	# Try matching from each position
	nLen = len(aNormalized)
	for nStart = 1 to nLen
		bResult = This.BacktrackMatchPartial(@aTokens, aNormalized, 1, nStart, [])
		if bResult
			This.ExtractMatches(aNormalized)
			return TRUE
		ok
	next
	return FALSE

def MatchAsYouBuild(oTarget)
	# For real-time validation as timeline is built
	# Returns true if pattern matches OR could match with more events
	@oTarget = oTarget
	aNormalized = This.NormalizeTarget(@oTarget)
	
	# Check if current state matches
	if This.MatchPartial(oTarget)
		return TRUE
	ok
	
	# Check if it could match with more data
	return This.CouldMatchWithMore(aNormalized)


def SortByDateTime(aItems)
	nLen = len(aItems)
	for i = 1 to nLen - 1
		for j = i + 1 to nLen
			cTime1 = ""
			cTime2 = ""
			
			if aItems[i]["type"] = "instant"
				cTime1 = aItems[i]["datetime"]
			else
				cTime1 = aItems[i]["start"]
			ok
			
			if aItems[j]["type"] = "instant"
				cTime2 = aItems[j]["datetime"]
			else
				cTime2 = aItems[j]["start"]
			ok
			
			if StzDateTimeQ(cTime1) > cTime2
				temp = aItems[i]
				aItems[i] = aItems[j]
				aItems[j] = temp
			ok
		next
	next
	return aItems
	
def BacktrackMatch(aTokens, aNormalized, nTokenIdx, nDataIdx, aMatched)
	nLenTokens = len(aTokens)
	nLenData = len(aNormalized)
	
	# Base case: all tokens processed
	if nTokenIdx > nLenTokens
		return nDataIdx > nLenData
	ok
	
	aToken = aTokens[nTokenIdx]
	
	# Handle alternation - try each alternative as a separate path
	if aToken[:type] = "alternation"
		nLen = len(aToken[:alternatives])
		for i = 1 to nLen
			aAlt = aToken[:alternatives][i]
			
			# Create new token sequence with this alternative
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
	
	# Calculate maximum matches possible
	nMaxPossible = @Min([aToken[:max], nLenData - nDataIdx + 1])
	
	# FIXED: Try match counts from max down to min for better backtracking
	# This allows skipping over non-matching items when constraints fail
	for nMatchCount = nMaxPossible to aToken[:min] step -1
		bSuccess = TRUE
		nElemIdx = nDataIdx
		aLocalMatched = []
		
		# Copy existing matches
		nLenMatched = len(aMatched)
		for i = 1 to nLenMatched
			aLocalMatched + aMatched[i]
		next
		
		# Try to match nMatchCount elements
		for i = 1 to nMatchCount
			if nElemIdx > nLenData
				bSuccess = FALSE
				exit
			ok
			
			aData = aNormalized[nElemIdx]
			
			# Type matching logic
			bTypeMatch = FALSE
			
			if aToken[:type] = "event"
				# Events match: labeled instants OR labeled event spans
				bTypeMatch = (aData[:type] = "instant") or 
				             (aData[:type] = "event")
			but aToken[:type] = "duration"
				# Durations only match unlabeled gaps
				bTypeMatch = (aData[:type] = "duration" and aData[:label] = "")
			but aToken[:type] = "instant"
				# Instants only match instant type
				bTypeMatch = (aData[:type] = "instant")
			else
				# Exact match for other types
				bTypeMatch = (aToken[:type] = aData[:type])
			ok
			
			if aToken[:negated]
				bTypeMatch = NOT bTypeMatch
			ok
			
			if not bTypeMatch
				bSuccess = FALSE
				exit
			ok
			
			# Check label if specified
			if aToken[:label] != "" and aData[:label] != ""
				if lower(aToken[:label]) != lower(aData[:label])
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
	
	return FALSE


def BacktrackMatchPartial(aTokens, aNormalized, nTokenIdx, nDataIdx, aMatched)
	nLenTokens = len(aTokens)
	nLenData = len(aNormalized)
	
	# Base case: all tokens processed - PARTIAL match succeeds
	if nTokenIdx > nLenTokens
		return TRUE
	ok
	
	aToken = aTokens[nTokenIdx]
	
	# Handle alternation
	if aToken[:type] = "alternation"
		nLen = len(aToken[:alternatives])
		for i = 1 to nLen
			aAlt = aToken[:alternatives][i]
			
			aNewTokens = []
			for j = 1 to nTokenIdx - 1
				aNewTokens + aTokens[j]
			next
			aNewTokens + aAlt
			for j = nTokenIdx + 1 to nLenTokens
				aNewTokens + aTokens[j]
			next
			
			if This.BacktrackMatchPartial(aNewTokens, aNormalized, nTokenIdx, nDataIdx, aMatched)
				return TRUE
			ok
		next
		return FALSE
	ok
	
	# Try different match counts
	nMaxPossible = @Min([aToken[:max], nLenData - nDataIdx + 1])
	
	for nMatchCount = aToken[:min] to nMaxPossible
		if @bDebugMode
			? "Token " + nTokenIdx + " (type=" + aToken[:type] + ", label=" + aToken[:label] + "): trying " + nMatchCount + " matches starting at data position " + nDataIdx
		ok
		
		bSuccess = TRUE
		nElemIdx = nDataIdx
		aLocalMatched = []
		
		nLenMatched = len(aMatched)
		for i = 1 to nLenMatched
			aLocalMatched + aMatched[i]
		next
		
		for i = 1 to nMatchCount
			if nElemIdx > nLenData
				bSuccess = FALSE
				exit
			ok
			
			aData = aNormalized[nElemIdx]
			
			if @bDebugMode
				? "  Attempt " + i + ": checking data[" + nElemIdx + "] type=" + aData[:type] + ", label=" + aData[:label]
			ok
			
			bTypeMatch = FALSE
			
			if aToken[:type] = "event"
				bTypeMatch = (aData[:type] = "instant" or aData[:type] = "event")
			but aToken[:type] = "duration"
				bTypeMatch = (aData[:type] = "duration" and aData[:label] = "")
			but aToken[:type] = "instant"
				bTypeMatch = (aData[:type] = "instant")
			else
				bTypeMatch = (aToken[:type] = aData[:type])
			ok
			
			if aToken[:negated]
				bTypeMatch = NOT bTypeMatch
			ok
			
			if not bTypeMatch
				bSuccess = FALSE
				exit
			ok
			
			if aToken[:label] != "" and aData[:label] != ""
				if lower(aToken[:label]) != lower(aData[:label])
					bSuccess = FALSE
					exit
				ok
			ok
			
			if not This.CheckConstraints(aToken[:constraints], aData)
				bSuccess = FALSE
				exit
			ok
			
			aLocalMatched + aData
			nElemIdx++
		next
		
		if bSuccess
			# PARTIAL: success when tokens exhausted, regardless of remaining data
			if nTokenIdx = nLenTokens
				return TRUE
			else
				if This.BacktrackMatchPartial(aTokens, aNormalized, nTokenIdx + 1, nElemIdx, aLocalMatched)
					return TRUE
				ok
			ok
		ok
	next
	
	return FALSE


# Complete NormalizeTarget fix
def NormalizeTarget(oTarget)
	aNormalized = []
	
	if @IsStzTimeLine(oTarget)
		aItems = []
		
		# Collect points as instants
		aPoints = oTarget.Points()
		nLenPoints = len(aPoints)
		for i = 1 to nLenPoints
			aPoint = aPoints[i]
			aItems + [
				["type", "instant"],
				["label", aPoint[1]],
				["datetime", aPoint[2]],
				["object", NULL]
			]
		next
		
		# Collect spans as events
		aSpans = oTarget.Spans()
		nLenSpans = len(aSpans)
		for i = 1 to nLenSpans
			aSpan = aSpans[i]
			oStart = new stzDateTime(aSpan[2])
			oEnd = new stzDateTime(aSpan[3])
			nMinutes = oStart.DurationInMinutesTo(oEnd)
			
			aItems + [
				["type", "event"],
				["label", aSpan[1]],
				["start", aSpan[2]],
				["end", aSpan[3]],
				["minutes", nMinutes],
				["object", NULL]
			]
		next
		
		# Sort by datetime
		aItems = This.SortByDateTime(aItems)
		
		# Build sequence with gaps
		nLen = len(aItems)
		for i = 1 to nLen
			aNormalized + aItems[i]
			
			# Add gap between items
			if i < nLen
				cCurrent = ""
				cNext = ""
				
				if aItems[i]["type"] = "instant"
					cCurrent = aItems[i]["datetime"]
				else
					cCurrent = aItems[i]["end"]
				ok
				
				if aItems[i+1]["type"] = "instant"
					cNext = aItems[i+1]["datetime"]
				else
					cNext = aItems[i+1]["start"]
				ok
				
				oStart = new stzDateTime(cCurrent)
				oEnd = new stzDateTime(cNext)
				nGapMinutes = oStart.DurationInMinutesTo(oEnd)
				
				if nGapMinutes > 0
					aNormalized + [
						["type", "duration"],
						["label", ""],
						["start", cCurrent],
						["end", cNext],
						["minutes", nGapMinutes],
						["object", NULL]
					]
				ok
			ok
		next
	
	but @IsStzCalendar(oTarget)
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
	
	but isList(oTarget)
		nLen = len(oTarget)
		for i = 1 to nLen
			xItem = oTarget[i]
			
			if isString(xItem)
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
					["minutes", xItem.TotalMinutes()],
					["object", xItem]
				]
			ok
		next
	
	but @IsStzDateTime(oTarget)
		aNormalized + [
			["type", "instant"],
			["label", ""],
			["datetime", oTarget.ToString()],
			["object", oTarget]
		]
	
	but @IsStzDuration(oTarget)
		aNormalized + [
			["type", "duration"],
			["label", ""],
			["start", ""],
			["end", ""],
			["minutes", oTarget.TotalMinutes()],
			["object", oTarget]
		]
	ok
	
	return aNormalized
	

def CheckConstraints(aConstraints, aData)
	nLen = len(aConstraints)
	
	if @bDebugMode
		? "CheckConstraints: type=" + aData[:type] + ", label=" + aData[:label] + ", constraints=" + nLen
	ok
	
	for i = 1 to nLen
		aConstraint = aConstraints[i]
		
		if aConstraint[:type] = "range"
			# Check range for durations and events
			if aData[:type] = "duration" or aData[:type] = "event"
				nMinutes = aData[:minutes]
				nStart = This.ParseDurationToMinutes(aConstraint[:start])
				nEnd = This.ParseDurationToMinutes(aConstraint[:end])
				
				if @bDebugMode
					? "Range check: " + nMinutes + " in [" + nStart + ".." + nEnd + "]"
				ok
				
				if nMinutes < nStart or nMinutes > nEnd
					if @bDebugMode
						? "FAILED: out of range"
					ok
					return FALSE
				ok
				
				# Check step if specified
				if aConstraint[:step] != ""
					nStep = This.ParseDurationToMinutes(aConstraint[:step])
					if nStep > 0
						nOffset = nMinutes - nStart
						if (nOffset % nStep) != 0
							if @bDebugMode
								? "FAILED: step mismatch"
							ok
							return FALSE
						ok
					ok
				ok
			ok
		
		but aConstraint[:type] = "set"
			bInSet = FALSE
			nLenTemp = len(aConstraint[:values])
			for j = 1 to nLenTemp
				if lower(aData[:label]) = lower(@trim(aConstraint[:values][j]))
					bInSet = TRUE
					exit
				ok
			next
			if not bInSet
				return FALSE
			ok
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
	
	def EnableDebug()
		@bDebugMode = TRUE
	
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
