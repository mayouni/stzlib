# stzTimex - Temporal Pattern Matching for Softanza
# A regex-like pattern language for time structures

/*
   IMPORTANT: Ring's substr() is polymorphic and BYTE-oriented:
   1. substr(str, substring)          → find (byte position)
   2. substr(str, sub1, sub2)         → replace sub1 with sub2
   3. substr(str, nPos)               → byte extract from nPos to end
   4. substr(str, nPos, nCount)       → byte extract of nCount bytes
   All four corrupt UTF-8 the moment positions cross a multibyte
   character. Softanza policy: never call substr() in new code --
   use StzFindFirst / StzReplace / StzMidToEnd / StzMid(str, nStart,
   nLen) which are engine-backed and codepoint-correct.
*/

# Quick constructor functions
func StzTimexQ(_cPattern_)
	return new stzTimex(_cPattern_)

func Timex(_cPattern_)
	return new stzTimex(_cPattern_)

func Tmx(_cPattern_)
	return new stzTimex(_cPattern_)

class stzTimex from stzObject
	
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
	
	def init(_cPattern_)
		if NOT isString(_cPattern_)
			raise("Error: Pattern must be a string")
		ok
		
		@cPattern = This.NormalizePattern(_cPattern_)

		@aMatchedParts = []
		
		# Parse pattern into tokens
		@aTokens = This.ParsePattern(@cPattern)
			
		if @bDebugMode
			? "=== stzTimex Init ==="
			? "Pattern: " + @cPattern
			? "Tokens parsed: " + len(@aTokens)
		ok

	
	def NormalizePattern(_cPattern_)
		_cPattern_ = trim(_cPattern_)
		
		# Ensure pattern is wrapped in {}
		if NOT (startsWith(_cPattern_, "{") and endsWith(_cPattern_, "}"))
			_cPattern_ = "{" + _cPattern_ + "}"
		ok
		
		return _cPattern_
	
	  #--------------------#
	 #  PATTERN PARSING   #
	#--------------------#
	
	def ParsePattern(_cPattern_)
		# Remove outer braces
		_cInner_ = @StzMid(_cPattern_, 2, len(_cPattern_)-1)
		_cInner_ = trim(_cInner_)
		
		if @bDebugMode
			? "Parsing inner pattern: " + _cInner_
		ok
		
		# Split by sequence operator (->)
		_aParts_ = This.SplitByOperator(_cInner_, "->")
		
		_aTokens_ = []
		_nLen_ = len(_aParts_)
		for _i_ = 1 to _nLen_
			_cPart_ = @trim(_aParts_[_i_])
			
			if _cPart_ = ""
				loop
			ok
			
			# Check for alternation (|)
			if contains(_cPart_, "|")
				_aToken_ = This.ParseAlternation(_cPart_)
			else
				_aToken_ = This.ParseSingleToken(_cPart_)
			ok
			
			if len(_aToken_) > 0
				_aTokens_ + _aToken_
			ok
		next
		
		return _aTokens_
	
	def SplitByOperator(cStr, cOperator)
		# Split by operator but respect parentheses nesting
		_aParts_ = []
		_cCurrent_ = ""
		_nDepth_ = 0
		_nLen_ = len(cStr)
		_nOpLen_ = len(cOperator)
		
		for _i_ = 1 to _nLen_
			_cChar_ = StzMid(cStr, _i_, 1)
			
			if _cChar_ = "(" or _cChar_ = "{"
				_nDepth_++
				_cCurrent_ += _cChar_

			but _cChar_ = ")" or _cChar_ = "}"
				_nDepth_--
				_cCurrent_ += _cChar_

			but _nDepth_ = 0 and @StzMid(cStr, _i_, _i_ + _nOpLen_ - 1) = cOperator
				_aParts_ + @trim(_cCurrent_)
				_cCurrent_ = ""
				_i_ += _nOpLen_ - 1  # Skip operator
			else
				_cCurrent_ += _cChar_
			ok
		next
		
		if len(_cCurrent_) > 0
			_aParts_ + @trim(_cCurrent_)
		ok
		
		return _aParts_
	
	def ParseAlternation(_cTokenStr_)
		# Handle (A | B | C) patterns
		# Strip outer parentheses if present
		if startsWith(_cTokenStr_, "(") and endsWith(_cTokenStr_, ")")
			_cTokenStr_ = @StzMid(_cTokenStr_, 2, len(_cTokenStr_) - 1)
		ok
		
		# Split by |
		_aParts_ = This.SplitByOperator(_cTokenStr_, "|")
		_nLenParts_ = len(_aParts_)
		_aAlternatives_ = []
		
		for _i_ = 1 to _nLenParts_
			_cPart_ = @trim(_aParts_[_i_])
			if _cPart_ != ""
				_aToken_ = This.ParseSingleToken(_cPart_)
				if len(_aToken_) > 0
					_aAlternatives_ + _aToken_
				ok
			ok
		next
		
		return [
			["type", "alternation"],
			["alternatives", _aAlternatives_],
			["negated", FALSE]
		]
	
	def ParseSingleToken(_cTokenStr_)
		_cTokenStr_ = @trim(_cTokenStr_)
		
		if _cTokenStr_ = ""
			return []
		ok
		
		# Check for negation
		_bNegated_ = FALSE
		if startsWith(_cTokenStr_, "@!")
			_bNegated_ = TRUE
			_cTokenStr_ = @StzMid(_cTokenStr_, 3, len(_cTokenStr_))
		ok
		
		# Initialize token properties
		_cType_ = ""
		_cLabel_ = ""
		_aConstraints_ = []
		_nMin_ = 1
		_nMax_ = 1
		_bCyclic_ = FALSE
		
		# Identify token type
		if startsWith(_cTokenStr_, "@Instant")
			_cType_ = "instant"
			_cTokenStr_ = @StzMid(_cTokenStr_, 9, len(_cTokenStr_))
	
		but startsWith(_cTokenStr_, "@Duration")
			_cType_ = "duration"
			_cTokenStr_ = @StzMid(_cTokenStr_, 10, len(_cTokenStr_))
	
		but startsWith(_cTokenStr_, "@Event")
			_cType_ = "event"
			_cTokenStr_ = @StzMid(_cTokenStr_, 7, len(_cTokenStr_))
	
		but startsWith(_cTokenStr_, "@Sequence")
			_cType_ = "sequence"
			_cTokenStr_ = @StzMid(_cTokenStr_, 10, len(_cTokenStr_))
	
		but startsWith(_cTokenStr_, "@Frame")
			_cType_ = "frame"
			_cTokenStr_ = @StzMid(_cTokenStr_, 7, len(_cTokenStr_))
	
		else
			if @bDebugMode
				? "Unknown token type: " + _cTokenStr_
			ok
			return []
		ok
		
		# Extract label from parentheses
		_nOpenParen_ = StzFindFirst(_cTokenStr_, "(")
		if _nOpenParen_ > 0
			_nCloseParen_ = StzFindFirst(_cTokenStr_, ")")
			if _nCloseParen_ > _nOpenParen_
				_cContent_ = @StzMid(_cTokenStr_, _nOpenParen_ + 1, _nCloseParen_ - 1)
				
				# For Event type: check if label contains duration constraint (Label:Duration)
				if _cType_ = "event" and contains(_cContent_, ":")
					_aParts_ = @split(_cContent_, ":")
					_cLabel_ = @trim(_aParts_[1])
					if len(_aParts_) > 1
						_cDurationPart_ = @trim(_aParts_[2])
						_aConstraints_ = This.ParseConstraints(_cDurationPart_)
					ok
				# For Duration type: parse as constraints
				but _cType_ = "duration"
					_cLabel_ = ""
					_aConstraints_ = This.ParseConstraints(_cContent_)
				# For other types: just label
				else
					_cLabel_ = _cContent_
				ok
			ok
		ok
		
		# Extract quantifier from end
		_cLastChar_ = StzRight(_cTokenStr_, 1)
		if _cLastChar_ = "+"
			_nMin_ = 1
			_nMax_ = 999999
		but _cLastChar_ = "*"
			_nMin_ = 0
			_nMax_ = 999999
		but _cLastChar_ = "?"
			_nMin_ = 0
			_nMax_ = 1
		but _cLastChar_ = "~"
			_bCyclic_ = TRUE
		ok
		
		# Check for numeric quantifiers
		if isDigit(_cLastChar_)
			_nLenTokenStr_ = len(_cTokenStr_)
	
			for _i_ = _nLenTokenStr_ to 1 step -1
				_cChar_ = @StzMid(_cTokenStr_, _i_, _i_+1)
				if not isDigit(_cChar_) and _cChar_ != "-"
					_cQuantPart_ = @StzMid(_cTokenStr_, _i_ + 1, _nLenTokenStr_)
					if contains(_cQuantPart_, "-")
						_aRange_ = @split(_cQuantPart_, "-")
						if len(_aRange_) = 2
							_nMin_ = 0 + _aRange_[1]
							_nMax_ = 0 + _aRange_[2]
						ok
					else
						_nMin_ = 0 + _cQuantPart_
						_nMax_ = _nMin_
					ok
					exit
				ok
			next
		ok
		
		return [
			["type", _cType_],
			["label", _cLabel_],
			["constraints", _aConstraints_],
			["min", _nMin_],
			["max", _nMax_],
			["cyclic", _bCyclic_],
			["negated", _bNegated_]
		]
		
	def ParseConstraints(cConstraintStr)
		# Parse constraints like "1h..2h:15min" or "{Mon;Wed;Fri}" or "1h" (single duration)
		_aConstraints_ = []
		
		if cConstraintStr = ""
			return _aConstraints_
		ok
		
		# Check for range (1h..2h) - extract step first if present
		_cStep_ = ""
		_cWorkingStr_ = cConstraintStr
		
		if contains(cConstraintStr, ":")
			_aParts_ = @split(cConstraintStr, ":")
			_cWorkingStr_ = @trim(_aParts_[1])
			if len(_aParts_) > 1
				_cStep_ = @trim(_aParts_[2])
			ok
		ok
		
		# Now check for range in the working string
		if contains(_cWorkingStr_, "..")
			_aParts_ = @split(_cWorkingStr_, "..")
			if len(_aParts_) = 2
				_cStart_ = @trim(_aParts_[1])
				_cEnd_ = @trim(_aParts_[2])
				
				_aConstraints_ + [
					["type", "range"],
					["start", _cStart_],
					["end", _cEnd_],
					["step", _cStep_]
				]
			ok
		# Check for single duration (e.g., "1h", "30m")
		but len(_cWorkingStr_) > 0
			# Single duration - treat as exact match
			_nMinutes_ = This.ParseDurationToMinutes(_cWorkingStr_)
			_aConstraints_ + [
				["type", "exact"],
				["minutes", _nMinutes_]
			]
		ok
		
		# Check for set {Mon;Wed;Fri}
		_nBraceStart_ = StzFindFirst(cConstraintStr, "{")
		if _nBraceStart_ > 0
			_nBraceEnd_ = StzFindFirst(cConstraintStr, "}")
			if _nBraceEnd_ > _nBraceStart_
				_cSetContent_ = @StzMid(cConstraintStr, _nBraceStart_ + 1, _nBraceEnd_ - 1)
				_aSetValues_ = @split(_cSetContent_, ";")
				
				_aConstraints_ + [
					["type", "set"],
					["values", _aSetValues_]
				]
			ok
		ok
		
		return _aConstraints_
		
	def ParseDurationToMinutes(_cDuration_)
		# Parse duration strings like "1h", "30min", "1h30min", "2h"
		_cDuration_ = StzLower(@trim(_cDuration_))
		_nMinutes_ = 0
		
		# Extract hours
		_nHPos_ = StzFindFirst(_cDuration_, "h")
		if _nHPos_ > 0
			_cHours_ = StzLeft(_cDuration_, _nHPos_ - 1)
			_nMinutes_ = (0 + _cHours_) * 60
			_cDuration_ = @StzMid(_cDuration_, _nHPos_ + 1, len(_cDuration_))
		ok
		
		# Extract minutes
		if contains(_cDuration_, "min")
			_cMinutes_ = @StzMid(_cDuration_, 1, StzFindFirst(_cDuration_, "min") - 1)
			_nMinutes_ += (0 + StzStringQ(_cDuration_).Numbers()[1])  # ADD @trim() here
		but len(_cDuration_) > 0  # CHANGE: was cDuration != ""
			# Just a number, assume minutes
			_nMinutes_ += (0 + StzStringQ(_cDuration_).Numbers()[1])  # ADD @trim() here
		ok
		
		return _nMinutes_

	  #--------------------#
	 #  MATCHING LOGIC    #
	#--------------------#
	
	def Match(oTarget)
		# Full match - pattern must match completely
		return This.MatchExact(oTarget)
	
	def MatchExact(oTarget)
		# Entire timeline must match pattern exactly
		@oTarget = oTarget
		_aNormalized_ = This.NormalizeTarget(@oTarget)
		
		# Must consume all data
		_bResult_ = This.BacktrackMatch(@aTokens, _aNormalized_, 1, 1, [])
		if _bResult_
			This.ExtractMatches(_aNormalized_)
		ok
		return _bResult_
	
	def MatchPartial(oTarget)
		# Pattern exists somewhere in timeline (prefix match)
		@oTarget = oTarget
		_aNormalized_ = This.NormalizeTarget(@oTarget)
		
		# Try matching from each position
		_nLen_ = len(_aNormalized_)
		for _nStart_ = 1 to _nLen_
			_bResult_ = This.BacktrackMatchPartial(@aTokens, _aNormalized_, 1, _nStart_, [])
			if _bResult_
				This.ExtractMatches(_aNormalized_)
				return TRUE
			ok
		next
		return FALSE
	
	def MatchAsYouBuild(oTarget)
		# For real-time validation as timeline is built
		# Returns true if pattern matches OR could match with more events
		@oTarget = oTarget
		_aNormalized_ = This.NormalizeTarget(@oTarget)
		
		# Check if current state matches
		if This.MatchPartial(oTarget)
			return TRUE
		ok
		
		# Check if it could match with more data
		return This.CouldMatchWithMore(_aNormalized_)
	
	
	def SortByDateTime(_aItems_)
		_nLen_ = len(_aItems_)
		for _i_ = 1 to _nLen_ - 1
			for j = _i_ + 1 to _nLen_
				_cTime1_ = ""
				_cTime2_ = ""
				
				if _aItems_[_i_]["type"] = "instant"
					_cTime1_ = _aItems_[_i_]["datetime"]
				else
					_cTime1_ = _aItems_[_i_]["start"]
				ok
				
				if _aItems_[j]["type"] = "instant"
					_cTime2_ = _aItems_[j]["datetime"]
				else
					_cTime2_ = _aItems_[j]["start"]
				ok
				
				if StzDateTimeQ(_cTime1_) > _cTime2_
					_temp_ = _aItems_[_i_]
					_aItems_[_i_] = _aItems_[j]
					_aItems_[j] = _temp_
				ok
			next
		next
		return _aItems_
		
	def BacktrackMatch(_aTokens_, _aNormalized_, nTokenIdx, nDataIdx, aMatched)
		_nLenTokens_ = len(_aTokens_)
		_nLenData_ = len(_aNormalized_)
		
		# Base case: all tokens processed
		if nTokenIdx > _nLenTokens_
			return nDataIdx > _nLenData_
		ok
		
		_aToken_ = _aTokens_[nTokenIdx]
		
		# Handle alternation - try each alternative as a separate path
		if _aToken_[:type] = "alternation"
			_nLen_ = len(_aToken_[:alternatives])
			for _i_ = 1 to _nLen_
				_aAlt_ = _aToken_[:alternatives][_i_]
				
				# Create new token sequence with this alternative
				_aNewTokens_ = []
				for j = 1 to nTokenIdx - 1
					_aNewTokens_ + _aTokens_[j]
				next
				_aNewTokens_ + _aAlt_
				for j = nTokenIdx + 1 to _nLenTokens_
					_aNewTokens_ + _aTokens_[j]
				next
				
				if This.BacktrackMatch(_aNewTokens_, _aNormalized_, nTokenIdx, nDataIdx, aMatched)
					return TRUE
				ok
			next
			return FALSE
		ok
		
		# Calculate maximum matches possible
		_nMaxPossible_ = @Min([_aToken_[:max], _nLenData_ - nDataIdx + 1])
		
		# Try match counts from max down to min for better backtracking
		# This allows skipping over non-matching items when constraints fail
		for nMatchCount = _nMaxPossible_ to _aToken_[:min] step -1
			_bSuccess_ = TRUE
			_nElemIdx_ = nDataIdx
			_aLocalMatched_ = []
			
			# Copy existing matches
			_nLenMatched_ = len(aMatched)
			for _i_ = 1 to _nLenMatched_
				_aLocalMatched_ + aMatched[_i_]
			next
			
			# Try to match nMatchCount elements
			for _i_ = 1 to nMatchCount
				if _nElemIdx_ > _nLenData_
					_bSuccess_ = FALSE
					exit
				ok
				
				_aData_ = _aNormalized_[_nElemIdx_]
				
				# Type matching logic
				_bTypeMatch_ = FALSE
				
				if _aToken_[:type] = "event"
					# Events match: labeled instants OR labeled event spans
					_bTypeMatch_ = (_aData_[:type] = "instant") or 
					             (_aData_[:type] = "event")
				but _aToken_[:type] = "duration"
					# Durations only match unlabeled gaps
					_bTypeMatch_ = (_aData_[:type] = "duration" and _aData_[:label] = "")
				but _aToken_[:type] = "instant"
					# Instants only match instant type
					_bTypeMatch_ = (_aData_[:type] = "instant")
				else
					# Exact match for other types
					_bTypeMatch_ = (_aToken_[:type] = _aData_[:type])
				ok
				
				if _aToken_[:negated]
					_bTypeMatch_ = NOT _bTypeMatch_
				ok
				
				if not _bTypeMatch_
					_bSuccess_ = FALSE
					exit
				ok
				
				# Check label if specified
				if _aToken_[:label] != "" and _aData_[:label] != ""
					if StzLower(_aToken_[:label]) != StzLower(_aData_[:label])
						_bSuccess_ = FALSE
						exit
					ok
				ok
				
				# Check constraints
				if not This.CheckConstraints(_aToken_[:constraints], _aData_)
					_bSuccess_ = FALSE
					exit
				ok
				
				_aLocalMatched_ + _aData_
				_nElemIdx_++
			next
			
			if _bSuccess_
				# For last token, ensure complete match
				if nTokenIdx = _nLenTokens_
					if _nElemIdx_ = _nLenData_ + 1
						return TRUE
					ok
				else
					# Recurse for remaining tokens
					if This.BacktrackMatch(_aTokens_, _aNormalized_, nTokenIdx + 1, _nElemIdx_, _aLocalMatched_)
						return TRUE
					ok
				ok
			ok
		next
		
		return FALSE


	def BacktrackMatchPartial(_aTokens_, _aNormalized_, nTokenIdx, nDataIdx, aMatched)
		_nLenTokens_ = len(_aTokens_)
		_nLenData_ = len(_aNormalized_)
		
		# Base case: all tokens processed - PARTIAL match succeeds
		if nTokenIdx > _nLenTokens_
			return TRUE
		ok
		
		# Out of data but tokens remain
		if nDataIdx > _nLenData_
			# Check if remaining tokens can match zero times
			for _i_ = nTokenIdx to _nLenTokens_
				if _aTokens_[_i_][:min] > 0
					return FALSE
				ok
			next
			return TRUE
		ok
		
		_aToken_ = _aTokens_[nTokenIdx]
		
		# Handle alternation
		if _aToken_[:type] = "alternation"
			_nLen_ = len(_aToken_[:alternatives])
			for _i_ = 1 to _nLen_
				_aAlt_ = _aToken_[:alternatives][_i_]
				
				_aNewTokens_ = []
				for j = 1 to nTokenIdx - 1
					_aNewTokens_ + _aTokens_[j]
				next
				_aNewTokens_ + _aAlt_
				for j = nTokenIdx + 1 to _nLenTokens_
					_aNewTokens_ + _aTokens_[j]
				next
				
				if This.BacktrackMatchPartial(_aNewTokens_, _aNormalized_, nTokenIdx, nDataIdx, aMatched)
					return TRUE
				ok
			next
			return FALSE
		ok
		
		# Calculate how many items could possibly match
		_nAvailable_ = 0
		for _i_ = nDataIdx to _nLenData_
			_aData_ = _aNormalized_[_i_]
			_bCanMatch_ = FALSE
			
			if _aToken_[:type] = "event"
				_bCanMatch_ = (_aData_[:type] = "instant" or _aData_[:type] = "event")
			but _aToken_[:type] = "duration"
				_bCanMatch_ = (_aData_[:type] = "duration" and _aData_[:label] = "")
			but _aToken_[:type] = "instant"
				_bCanMatch_ = (_aData_[:type] = "instant")
			else
				_bCanMatch_ = (_aToken_[:type] = _aData_[:type])
			ok
			
			if _aToken_[:negated]
				_bCanMatch_ = NOT _bCanMatch_
			ok
			
			if _bCanMatch_
				_nAvailable_++
			ok
		next
		
		_nMaxPossible_ = @Min([_aToken_[:max], _nAvailable_])
		
		# Try different match counts from max down to min
		for nMatchCount = _nMaxPossible_ to _aToken_[:min] step -1
			if @bDebugMode
				? "Token " + nTokenIdx + " (type=" + _aToken_[:type] + ", label=" + _aToken_[:label] + "): trying " + nMatchCount + " matches starting at data position " + nDataIdx
			ok
			
			_bSuccess_ = TRUE
			_nElemIdx_ = nDataIdx
			_aLocalMatched_ = []
			_nMatched_ = 0
			
			_nLenMatched_ = len(aMatched)
			for _i_ = 1 to _nLenMatched_
				_aLocalMatched_ + aMatched[_i_]
			next
			
			# Try to match nMatchCount elements
			while _nMatched_ < nMatchCount and _nElemIdx_ <= _nLenData_
				_aData_ = _aNormalized_[_nElemIdx_]
				
				if @bDebugMode
					? "  Attempt " + (_nMatched_ + 1) + ": checking data[" + _nElemIdx_ + "] type=" + _aData_[:type] + ", label=" + _aData_[:label]
				ok
				
				_bTypeMatch_ = FALSE
				
				if _aToken_[:type] = "event"
					_bTypeMatch_ = (_aData_[:type] = "instant" or _aData_[:type] = "event")
				but _aToken_[:type] = "duration"
					_bTypeMatch_ = (_aData_[:type] = "duration" and _aData_[:label] = "")
				but _aToken_[:type] = "instant"
					_bTypeMatch_ = (_aData_[:type] = "instant")
				else
					_bTypeMatch_ = (_aToken_[:type] = _aData_[:type])
				ok
				
				if _aToken_[:negated]
					_bTypeMatch_ = NOT _bTypeMatch_
				ok
				
				if not _bTypeMatch_
					_nElemIdx_++
					loop
				ok
				
				if _aToken_[:label] != "" and _aData_[:label] != ""
					if StzLower(_aToken_[:label]) != StzLower(_aData_[:label])
						_nElemIdx_++
						loop
					ok
				ok
				
				if not This.CheckConstraints(_aToken_[:constraints], _aData_)
					_nElemIdx_++
					loop
				ok
				
				# This element matches!
				_aLocalMatched_ + _aData_
				_nMatched_++
				_nElemIdx_++
			end
			
			# Check if we got enough matches
			if _nMatched_ >= nMatchCount
				# PARTIAL: success when tokens exhausted, regardless of remaining data
				if nTokenIdx = _nLenTokens_
					return TRUE
				else
					if This.BacktrackMatchPartial(_aTokens_, _aNormalized_, nTokenIdx + 1, _nElemIdx_, _aLocalMatched_)
						return TRUE
					ok
				ok
			ok
		next
		
		return FALSE


	def NormalizeTarget(oTarget)
		_aNormalized_ = []
		
		if @IsStzTimeLine(oTarget)
			_aItems_ = []
			
			# Collect points as instants
			_aPoints_ = oTarget.Points()
			_nLenPoints_ = len(_aPoints_)
			for _i_ = 1 to _nLenPoints_
				_aPoint_ = _aPoints_[_i_]
				_aItems_ + [
					["type", "instant"],
					["label", _aPoint_[1]],
					["datetime", _aPoint_[2]],
					["object", NULL]
				]
			next
			
			# Collect spans as events
			_aSpans_ = oTarget.Spans()
			_nLenSpans_ = len(_aSpans_)
			for _i_ = 1 to _nLenSpans_
				_aSpan_ = _aSpans_[_i_]
				_oStart_ = new stzDateTime(_aSpan_[2])
				_oEnd_ = new stzDateTime(_aSpan_[3])
				_nMinutes_ = _oStart_.DurationInMinutesTo(_oEnd_)
				
				_aItems_ + [
					["type", "event"],
					["label", _aSpan_[1]],
					["start", _aSpan_[2]],
					["end", _aSpan_[3]],
					["minutes", _nMinutes_],
					["object", NULL]
				]
			next
			
			# Sort by datetime
			_aItems_ = This.SortByDateTime(_aItems_)
			
			# Build sequence with gaps
			_nLen_ = len(_aItems_)
			for _i_ = 1 to _nLen_
				_aNormalized_ + _aItems_[_i_]
				
				# Add gap between items
				if _i_ < _nLen_
					_cCurrent_ = ""
					_cNext_ = ""
					
					if _aItems_[_i_]["type"] = "instant"
						_cCurrent_ = _aItems_[_i_]["datetime"]
					else
						_cCurrent_ = _aItems_[_i_]["end"]
					ok
					
					if _aItems_[_i_+1]["type"] = "instant"
						_cNext_ = _aItems_[_i_+1]["datetime"]
					else
						_cNext_ = _aItems_[_i_+1]["start"]
					ok
					
					_oStart_ = new stzDateTime(_cCurrent_)
					_oEnd_ = new stzDateTime(_cNext_)
					_nGapMinutes_ = _oStart_.DurationInMinutesTo(_oEnd_)
					
					if _nGapMinutes_ > 0
						_aNormalized_ + [
							["type", "duration"],
							["label", ""],
							["start", _cCurrent_],
							["end", _cNext_],
							["minutes", _nGapMinutes_],
							["object", NULL]
						]
					ok
				ok
			next
		
		but @IsStzCalendar(oTarget)
			_aWorkDays_ = oTarget.WorkingDays()
			_nLen_ = len(_aWorkDays_)
			for _i_ = 1 to _nLen_
				_aNormalized_ + [
					["type", "instant"],
					["label", "WorkDay"],
					["datetime", _aWorkDays_[_i_]],
					["object", NULL]
				]
			next
		
		but isList(oTarget)
			_nLen_ = len(oTarget)
			for _i_ = 1 to _nLen_
				_xItem_ = oTarget[_i_]
				
				if isString(_xItem_)
					_aNormalized_ + [
						["type", "instant"],
						["label", ""],
						["datetime", _xItem_],
						["object", NULL]
					]
				but @IsStzDateTime(_xItem_)
					_aNormalized_ + [
						["type", "instant"],
						["label", ""],
						["datetime", _xItem_.ToString()],
						["object", _xItem_]
					]
				but @IsStzDuration(_xItem_)
					_aNormalized_ + [
						["type", "duration"],
						["label", ""],
						["start", ""],
						["end", ""],
						["minutes", _xItem_.TotalMinutes()],
						["object", _xItem_]
					]
				ok
			next
		
		but @IsStzDateTime(oTarget)
			_aNormalized_ + [
				["type", "instant"],
				["label", ""],
				["datetime", oTarget.ToString()],
				["object", oTarget]
			]
		
		but @IsStzDuration(oTarget)
			_aNormalized_ + [
				["type", "duration"],
				["label", ""],
				["start", ""],
				["end", ""],
				["minutes", oTarget.TotalMinutes()],
				["object", oTarget]
			]
		ok
		
		return _aNormalized_
	

	def CheckConstraints(_aConstraints_, _aData_)
		_nLen_ = len(_aConstraints_)
		
		if @bDebugMode
			? "CheckConstraints: type=" + _aData_[:type] + ", label=" + _aData_[:label] + ", constraints=" + _nLen_
		ok
		
		for _i_ = 1 to _nLen_
			_aConstraint_ = _aConstraints_[_i_]
			
			if _aConstraint_[:type] = "range"
				# Check range for durations and events
				if _aData_[:type] = "duration" or _aData_[:type] = "event"
					_nMinutes_ = _aData_[:minutes]
					_nStart_ = This.ParseDurationToMinutes(_aConstraint_[:start])
					_nEnd_ = This.ParseDurationToMinutes(_aConstraint_[:end])
					
					if @bDebugMode
						? "Range check: " + _nMinutes_ + " in [" + _nStart_ + ".." + _nEnd_ + "]"
					ok
					
					if _nMinutes_ < _nStart_ or _nMinutes_ > _nEnd_
						if @bDebugMode
							? "FAILED: out of range"
						ok
						return FALSE
					ok
					
					# Check step if specified
					if _aConstraint_[:step] != ""
						_nStep_ = This.ParseDurationToMinutes(_aConstraint_[:step])
						if _nStep_ > 0
							_nOffset_ = _nMinutes_ - _nStart_
							if (_nOffset_ % _nStep_) != 0
								if @bDebugMode
									? "FAILED: step mismatch"
								ok
								return FALSE
							ok
						ok
					ok
				ok
			
			but _aConstraint_[:type] = "exact"
				# Check exact duration match
				if _aData_[:type] = "duration" or _aData_[:type] = "event"
					_nMinutes_ = _aData_[:minutes]
					if _nMinutes_ != _aConstraint_[:minutes]
						if @bDebugMode
							? "FAILED: exact duration mismatch (" + _nMinutes_ + " != " + _aConstraint_[:minutes] + ")"
						ok
						return FALSE
					ok
				ok
			
			but _aConstraint_[:type] = "set"
				_bInSet_ = FALSE
				_nLenTemp_ = len(_aConstraint_[:values])
				for j = 1 to _nLenTemp_
					if StzLower(_aData_[:label]) = StzLower(@trim(_aConstraint_[:values][j]))
						_bInSet_ = TRUE
						exit
					ok
				next
				if not _bInSet_
					return FALSE
				ok
			ok
		next
		
		return TRUE
		
		def ExtractMatches(_aNormalized_)
			# Extract matched parts for later retrieval
			@aMatchedParts = []
			_nLen_ = len(_aNormalized_)
	
			for _i_ = 1 to _nLen_
				_aData_ = _aNormalized_[_i_]
				@aMatchedParts + [
					["type", _aData_[:type]],
					["label", _aData_[:label]],
					["data", _aData_]
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
		_aInfo_ = []
		_nLen_ = len(@aTokens)

		for _i_ = 1 to _nLen_
			_aToken_ = @aTokens[_i_]
			
			_aTokenInfo_ = [
				["index", _i_],
				["type", _aToken_[:type]],
				["label", _aToken_[:label]]
			]
			
			if _aToken_[:min] != 1 or _aToken_[:max] != 1
				_aTokenInfo_ + ["quantifier", "" + _aToken_[:min] + "-" + _aToken_[:max]]
			ok
			
			if len(_aToken_[:constraints]) > 0
				_aTokenInfo_ + ["constraints", _aToken_[:constraints]]
			ok
			
			if _aToken_[:negated]
				_aTokenInfo_ + ["negated", TRUE]
			ok
			
			_aInfo_ + _aTokenInfo_
		next
		
		return _aInfo_
	
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
			_cClassName_ = ring_classname(oObj)
			return contains(_cClassName_, "timeline")
		ok
		return FALSE
	
	def @IsStzCalendar(oObj)
		# Check if object is stzCalendar instance
		if isObject(oObj)
			_cClassName_ = ring_classname(oObj)
			return contains(_cClassName_, "calendar")
		ok
		return FALSE
	
	def @IsStzDateTime(oObj)
		# Check if object is stzDateTime instance
		if isObject(oObj)
			_cClassName_ = ring_classname(oObj)
			return contains(_cClassName_, "datetime")
		ok
		return FALSE
	
	def @IsStzDuration(oObj)
		# Check if object is stzDuration instance
		if isObject(oObj)
			_cClassName_ = ring_classname(oObj)
			return contains(_cClassName_, "duration")
		ok
		return FALSE
	
	def @Min(aValues)
		_nMin_ = aValues[1]
		_nLen_ = len(aValues)

		for _i_ = 2 to _nLen_
			if aValues[_i_] < _nMin_
				_nMin_ = aValues[_i_]
			ok
		next
		return _nMin_
