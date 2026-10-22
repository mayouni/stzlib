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

# Matches a regex-like pattern language for time structures, such as @Event -> @Duration -> @Event, against timelines and lists of dates.
#
# A pattern is a sequence of steps joined by ->, each step an @Instant, @Duration, @Event, @Sequence
# or @Frame with an optional label, a duration constraint and a quantifier (+, *, ?, ~ or a count),
# and a step may be negated with @!. A group in brackets of steps joined by a vertical bar, such as
# (@Event(A)|@Event(B)), offers alternatives. The target is a stzTimeLine, a stzCalendar, a list of
# date texts, or stzDateTime and stzDuration objects: it is first flattened into instants, events and
# the duration gaps between them. A text of a list is an instant only when it is a date or a date
# and time (2025-10-22 or 2025-10-22 09:00:00); any other text, and any number, is left out. Build one
# with StzTimexQ, Timex or Tmx. MatchExact needs the pattern to consume the whole target, item after
# item; MatchPartial finds it anywhere, skipping the items that do not fit between two steps; a
# success fills MatchedParts, a failure empties it.
#
# Limits: a quantifier cannot follow a bracketed group of alternatives; a step that names no known
# type is dropped without a word, so the pattern is read without it; a duration in seconds such as
# 30s reads as 30 minutes (h and min are the units); ~ is read as exactly one step; and a duration
# naming no number, such as @Duration(abc), raises R2 when the pattern is built.
#
#   receiver   o1 = StzTimexQ("@Instant")
#   example    ? o1.Pattern()
#              #--> {@Instant}
#              ? o1.MatchExact([ "2025-10-22 09:00:00" ])
#              #--> 1
#              ? o1.ParseDurationToMinutes("1h30min")
#              #--> 90
#   see        stzTimeLine, stzCalendar, stzListex
class stzTimex from stzObject
	
	@cPattern           # The pattern string, e.g., "{@Instant -> @Duration(1h..2h) -> @Event}"
	@aTokens            # Parsed token definitions
	@oTarget            # Target data to match against (stzTimeline, list, etc.)
	@bTargetSet = 0     # 1 once a target has been given
	@bDebugMode = 0 # Debug flag
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
	
	# Builds a time-pattern matcher from a pattern text such as @Event(A) -> @Duration(30m) -> @Event(B), adding braces if missing.
	#
	#   _cPattern_ the pattern as text
	#   returns    nothing; the object is built
	#   note       build with StzTimexQ, Timex or Tmx; the debug flag prints the parse
	#   see        Pattern, Tokens, MatchExact
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

	
	# Returns the slice of a text from one position to another, both included.
	#
	#   s          the text
	#   n1         the position to start at
	#   n2         the position to stop at, included
	#   returns    the slice as text; empty when n2 is before n1
	#   note       the global @StzMid takes a start and a COUNT, whereas every slice of this parser is
	#              written from a start and an END, so they all pass through here
	#   see        ParsePattern, SplitByOperator
	def _Mid(s, n1, n2)
		return @StzMid(s, n1, n2 - n1 + 1)

	# Returns the pattern text trimmed and wrapped in braces when it is not yet.
	#
	#   _cPattern_   the pattern as text
	#   returns      a text
	#   note         @Event(A) with spaces around gives {@Event(A)}, and {x} stays {x}
	#   see          ParsePattern, Pattern
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
	
	# Splits a pattern into its tokens, one per arrow-separated step.
	#
	#   _cPattern_ the braced pattern as text
	#   returns    a list of tokens, each a list of [ name, value ] pairs
	#   note       {@Instant -> @Duration(1h..2h) -> @Event(X)} gives three tokens; a step with a vertical bar
	#              outside brackets is ONE token, an alternation
	#   see        Tokens, SplitByOperator, ParseSingleToken
	def ParsePattern(_cPattern_)
		# Remove outer braces
		_cInner_ = This._Mid(_cPattern_, 2, StzLen(_cPattern_) - 1)
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
	
	# Cuts a text into trimmed parts at an operator that stands outside brackets.
	#
	#   cStr       the text to cut
	#   cOperator  the operator, such as -> or the vertical bar
	#   returns    a list of texts
	#   note       a -> b(c -> d) -> e gives a, b(c -> d) and e; an operator inside parentheses or braces
	#              does not cut; an empty text gives no part; an operator first or twice in a row leaves an
	#              empty part
	#   see        ParsePattern, ParseAlternation
	def SplitByOperator(cStr, cOperator)
		# Split by operator but respect parentheses nesting
		_aParts_ = []
		_cCurrent_ = ""
		_nDepth_ = 0
		_nLen_ = StzLen(cStr)
		_nOpLen_ = StzLen(cOperator)
		
		for _i_ = 1 to _nLen_
			_cChar_ = StzMid(cStr, _i_, 1)
			
			if _cChar_ = "(" or _cChar_ = "{"
				_nDepth_++
				_cCurrent_ += _cChar_

			but _cChar_ = ")" or _cChar_ = "}"
				_nDepth_--
				_cCurrent_ += _cChar_

			but _nDepth_ = 0 and This._Mid(cStr, _i_, _i_ + _nOpLen_ - 1) = cOperator
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
	
	# TRUE if a text opens with a bracket and that very bracket closes at the last character.
	#
	#   s          the text
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       (a|b) is one group and (a)|(b) is not
	#   see        ParseAlternation
	def _IsOneGroup(s)
		if NOT (startsWith(s, "(") and endsWith(s, ")"))
			return 0
		ok
		_nLen_ = StzLen(s)
		_nDepth_ = 0
		for _i_ = 1 to _nLen_
			_cChar_ = StzMid(s, _i_, 1)
			if _cChar_ = "("
				_nDepth_++
			but _cChar_ = ")"
				_nDepth_--
			ok
			if _nDepth_ = 0 and _i_ < _nLen_
				return 0
			ok
		next
		return 1

	# Reads a step that offers alternatives, such as event A or event B, into one alternation token.
	#
	#   _cTokenStr_the text of the alternation, its alternatives joined by vertical bars, with or
	#              without one group of brackets around them
	#   returns    a token: [ type alternation, the alternatives, negated 0 ]
	#   note       (@Event(A)|@Event(B)) and (@Event(A))|(@Event(B)) both give two alternatives
	#   warning    a quantifier after the group, as in (@Event(A)|@Event(B))+, leaves no alternative, so
	#              such a pattern never matches
	#   see        ParseSingleToken, SplitByOperator
	def ParseAlternation(_cTokenStr_)
		# Handle (A | B | C) patterns
		# Strip outer parentheses if present
		if This._IsOneGroup(_cTokenStr_)
			_cTokenStr_ = This._Mid(_cTokenStr_, 2, StzLen(_cTokenStr_) - 1)
		ok
		
		# Split by |
		_aParts_ = This.SplitByOperator(_cTokenStr_, "|")
		_nLenParts_ = len(_aParts_)
		_aAlternatives_ = []
		
		for _i_ = 1 to _nLenParts_
			_cPart_ = @trim(_aParts_[_i_])
			if This._IsOneGroup(_cPart_)
				_cPart_ = @trim(This._Mid(_cPart_, 2, StzLen(_cPart_) - 1))
			ok
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
			["negated", 0]
		]
	
	# Reads one step such as @Event(A)? or @Duration* into a token with its type, label, constraints and quantifier.
	#
	#   _cTokenStr_the text of one step
	#   returns    a token as a list of [ name, value ] pairs; [ ] for a text that names no known type
	#   note       types are instant, duration, event, sequence and frame; + means 1 or more, * 0 or more,
	#              ? 0 or 1, a count n exactly n, a range n-m from n to m, ~ cyclic; @!Event(X) gives an event
	#              token marked negated; a duration step reads its brackets as constraints and an event step
	#              reads Label:Duration as a label and a constraint
	#   see        ParseConstraints, ParsePattern
	def ParseSingleToken(_cTokenStr_)
		_cTokenStr_ = @trim(_cTokenStr_)
		
		if _cTokenStr_ = ""
			return []
		ok
		
		# Check for negation
		_bNegated_ = 0
		if startsWith(_cTokenStr_, "@!")
			_bNegated_ = 1
			_cTokenStr_ = "@" + This._Mid(_cTokenStr_, 3, StzLen(_cTokenStr_))
		ok
		
		# Initialize token properties
		_cType_ = ""
		_cLabel_ = ""
		_aConstraints_ = []
		_nMin_ = 1
		_nMax_ = 1
		_bCyclic_ = 0
		
		# Identify token type
		if startsWith(_cTokenStr_, "@Instant")
			_cType_ = "instant"
			_cTokenStr_ = This._Mid(_cTokenStr_, 9, StzLen(_cTokenStr_))
	
		but startsWith(_cTokenStr_, "@Duration")
			_cType_ = "duration"
			_cTokenStr_ = This._Mid(_cTokenStr_, 10, StzLen(_cTokenStr_))
	
		but startsWith(_cTokenStr_, "@Event")
			_cType_ = "event"
			_cTokenStr_ = This._Mid(_cTokenStr_, 7, StzLen(_cTokenStr_))
	
		but startsWith(_cTokenStr_, "@Sequence")
			_cType_ = "sequence"
			_cTokenStr_ = This._Mid(_cTokenStr_, 10, StzLen(_cTokenStr_))
	
		but startsWith(_cTokenStr_, "@Frame")
			_cType_ = "frame"
			_cTokenStr_ = This._Mid(_cTokenStr_, 7, StzLen(_cTokenStr_))
	
		else
			if @bDebugMode
				? "Unknown token type: " + _cTokenStr_
			ok
			return []
		ok
		
		# Extract label from parentheses
		_nOpenParen_ = StzFindFirst("(", _cTokenStr_)
		if _nOpenParen_ > 0
			_nCloseParen_ = StzFindFirst(")", _cTokenStr_)
			if _nCloseParen_ > _nOpenParen_
				_cContent_ = This._Mid(_cTokenStr_, _nOpenParen_ + 1, _nCloseParen_ - 1)
				
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
			_bCyclic_ = 1
		ok
		
		# Check for numeric quantifiers: the digits (and a dash) that close the step
		if isDigit(_cLastChar_)
			_nLenTokenStr_ = StzLen(_cTokenStr_)
			_nQuantStart_ = _nLenTokenStr_

			for _i_ = _nLenTokenStr_ to 1 step -1
				_cChar_ = This._Mid(_cTokenStr_, _i_, _i_)
				if isDigit(_cChar_) or _cChar_ = "-"
					_nQuantStart_ = _i_
				else
					exit
				ok
			next

			_cQuantPart_ = This._Mid(_cTokenStr_, _nQuantStart_, _nLenTokenStr_)
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
		
	# Reads the text inside a duration step into constraints: a range with an optional step, a set, or one exact duration.
	#
	#   cConstraintStrthe text of the constraints, such as 1h..2h:15min
	#   returns    a list of constraints, each a list of [ name, value ] pairs; [ ] for an empty text
	#   note       1h..2h:15min gives a range with start 1h, end 2h and step 15min; 1h gives an exact
	#              constraint of 60 minutes; {Mon;Wed;Fri} gives a set of three values
	#   see        ParseDurationToMinutes, CheckConstraints
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
		# Check for single duration (e.g., "1h", "30m"); a set in braces is read below
		but len(_cWorkingStr_) > 0 and NOT startsWith(_cWorkingStr_, "{")
			# Single duration - treat as exact match
			_nMinutes_ = This.ParseDurationToMinutes(_cWorkingStr_)
			_aConstraints_ + [
				["type", "exact"],
				["minutes", _nMinutes_]
			]
		ok
		
		# Check for set {Mon;Wed;Fri}
		_nBraceStart_ = StzFindFirst("{", cConstraintStr)
		if _nBraceStart_ > 0
			_nBraceEnd_ = StzFindFirst("}", cConstraintStr)
			if _nBraceEnd_ > _nBraceStart_
				_cSetContent_ = This._Mid(cConstraintStr, _nBraceStart_ + 1, _nBraceEnd_ - 1)
				_aSetValues_ = @split(_cSetContent_, ";")
				
				_aConstraints_ + [
					["type", "set"],
					["values", _aSetValues_]
				]
			ok
		ok
		
		return _aConstraints_
		
	# Returns a duration written as hours and minutes as a number of minutes.
	#
	#   _cDuration_the duration as text, such as 1h, 30min, 1h30min, 45 or 30m
	#   returns    a number of minutes
	#   note       1h gives 60, 1h30min gives 90, 45 gives 45 (a bare number is minutes), 2H gives 120
	#   warning    h and min are the only units: 30s reads as 30 minutes, and a text holding no number,
	#              such as abc, raises Array Access (Index out of range) (R2)
	#   see        ParseConstraints, CheckConstraints
	def ParseDurationToMinutes(_cDuration_)
		# Parse duration strings like "1h", "30min", "1h30min", "2h"
		_cDuration_ = StzLower(@trim(_cDuration_))
		_nMinutes_ = 0
		
		# Extract hours
		_nHPos_ = StzFindFirst("h", _cDuration_)
		if _nHPos_ > 0
			_cHours_ = StzLeft(_cDuration_, _nHPos_ - 1)
			_nMinutes_ = (0 + _cHours_) * 60
			_cDuration_ = This._Mid(_cDuration_, _nHPos_ + 1, StzLen(_cDuration_))
		ok
		
		# Extract minutes
		if contains(_cDuration_, "min")
			_cMinutes_ = This._Mid(_cDuration_, 1, StzFindFirst("min", _cDuration_) - 1)
			_nMinutes_ += (0 + StzStringQ(_cDuration_).Numbers()[1])  # ADD @trim() here
		but len(_cDuration_) > 0  # CHANGE: was cDuration != ""
			# Just a number, assume minutes
			_nMinutes_ += (0 + StzStringQ(_cDuration_).Numbers()[1])  # ADD @trim() here
		ok
		
		return _nMinutes_

	  #--------------------#
	 #  MATCHING LOGIC    #
	#--------------------#
	
	# TRUE if the pattern matches the whole target, with nothing left over; the same answer as the exact match.
	#
	#   oTarget    the target, as for MatchExact
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       a successful match fills MatchedParts; a failed one empties it
	#   see        MatchExact, MatchPartial
	def Match(oTarget)
		_bResult_ = This.MatchExact(oTarget)
		return _bResult_
	
	# TRUE if the pattern matches the whole target, item after item, with nothing left over.
	#
	#   oTarget    the target: a stzTimeLine, a stzCalendar, a list of date texts, stzDateTime or
	#              stzDuration objects, or one such object
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       a successful match fills MatchedParts and a failed one empties it; @Instant matches one
	#              date text and not two; the empty pattern matches the empty target only; the steps must
	#              follow one another with nothing between them, so on a timeline the gaps need their own
	#              @Duration step
	#   see        Match, MatchPartial, MatchAsYouBuild, MatchedParts
	def MatchExact(oTarget)
		# Entire timeline must match pattern exactly
		@oTarget = oTarget
		@bTargetSet = 1
		@aMatchedParts = []
		_aNormalized_ = This.NormalizeTarget(@oTarget)
		
		# Must consume all data
		_bResult_ = This.BacktrackMatch(@aTokens, _aNormalized_, 1, 1, [])
		if _bResult_
			This.ExtractMatches(_aNormalized_)
		ok
		return _bResult_
	
	# TRUE if the pattern matches somewhere inside the target, starting at any item.
	#
	#   oTarget    the target: a stzTimeLine, a stzCalendar, a list of date texts, stzDateTime or
	#              stzDuration objects, or one such object
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       a successful match fills MatchedParts and a failed one empties it; an empty list gives
	#              FALSE; the order of the steps is kept but items that fit no step are skipped between two
	#              steps, so @Event(Meeting) -> @Event(Lunch) is found in a timeline where a gap and a break
	#              lie between them; a text that is not a date is no instant, so @Instant is not found in a
	#              list holding only the text x
	#   see        MatchExact, MatchAsYouBuild
	def MatchPartial(oTarget)
		# Pattern exists somewhere in timeline (prefix match)
		@oTarget = oTarget
		@bTargetSet = 1
		@aMatchedParts = []
		_aNormalized_ = This.NormalizeTarget(@oTarget)
		
		# Try matching from each position
		_nLen_ = len(_aNormalized_)
		for _nStart_ = 1 to _nLen_
			_bResult_ = This.BacktrackMatchPartial(@aTokens, _aNormalized_, 1, _nStart_, [])
			if _bResult_
				This.ExtractMatches(_aNormalized_)
				return 1
			ok
		next
		return 0
	
	# Returns TRUE when the pattern matches somewhere, or could still match once more items arrive.
	#
	#   oTarget    the target, as for MatchPartial
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       TRUE when MatchPartial is TRUE, or when the first steps of the pattern consume every item
	#              given so far, or when no item is given yet and the pattern has a step; FALSE otherwise
	#   see        MatchPartial, CouldMatchWithMore, MatchExact
	def MatchAsYouBuild(oTarget)
		# For real-time validation as timeline is built
		# Returns true if pattern matches OR could match with more events
		@oTarget = oTarget
		@bTargetSet = 1
		_aNormalized_ = This.NormalizeTarget(@oTarget)
		
		# Check if current state matches
		if This.MatchPartial(oTarget)
			return 1
		ok
		
		# Check if it could match with more data
		return This.CouldMatchWithMore(_aNormalized_)

	# TRUE if the items given so far are the start of a match: the first steps of the pattern consume all of them.
	#
	#   _aNormalized_   the items, as NormalizeTarget gives
	#   returns         TRUE or FALSE, as 1 or 0
	#   note            with no item at all, a pattern with a step could still match; a pattern whose
	#                   steps are all consumed has nothing more to wait for, so it answers FALSE
	#   see             MatchAsYouBuild, BacktrackMatch
	def CouldMatchWithMore(_aNormalized_)
		_nLenTokens_ = len(@aTokens)
		if len(_aNormalized_) = 0
			return _nLenTokens_ > 0
		ok
		for _k_ = 1 to _nLenTokens_ - 1
			_aHead_ = []
			for _i_ = 1 to _k_
				_aHead_ + @aTokens[_i_]
			next
			if This.BacktrackMatch(_aHead_, _aNormalized_, 1, 1, [])
				return 1
			ok
		next
		return 0
	
	
	# Returns the items sorted from the earliest datetime or start to the latest.
	#
	#   _aItems_   the list of items, each holding a type and a datetime (instant) or a start
	#   returns    a list of items
	#   note       two instants 11:00 and 09:00 come back 09:00 first
	#   see        NormalizeTarget
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
		
	# TRUE if the tokens from a step on consume the items from a position to the very end.
	#
	#   _aTokens_       the list of tokens
	#   _aNormalized_   the items, as NormalizeTarget gives
	#   nTokenIdx       the 1-based index of the first token to use
	#   nDataIdx        the 1-based index of the first item to use
	#   aMatched        the matches so far, [ ] to start
	#   returns         TRUE or FALSE, as 1 or 0
	#   note            tokens can be built by hand; an instant token with 1 to many against two
	#                   instants gives TRUE, and exactly 1 gives FALSE
	#   see             BacktrackMatchPartial, MatchExact
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
					return 1
				ok
			next
			return 0
		ok
		
		# Calculate maximum matches possible
		_nMaxPossible_ = @Min([_aToken_[:max], _nLenData_ - nDataIdx + 1])
		
		# Try match counts from max down to min for better backtracking
		# This allows skipping over non-matching items when constraints fail
		for nMatchCount = _nMaxPossible_ to _aToken_[:min] step -1
			_bSuccess_ = 1
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
					_bSuccess_ = 0
					exit
				ok
				
				_aData_ = _aNormalized_[_nElemIdx_]
				
				# Type matching logic
				_bTypeMatch_ = 0
				
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
					_bSuccess_ = 0
					exit
				ok
				
				# Check label if specified
				if _aToken_[:label] != "" and _aData_[:label] != ""
					if StzLower(_aToken_[:label]) != StzLower(_aData_[:label])
						_bSuccess_ = 0
						exit
					ok
				ok
				
				# Check constraints
				if not This.CheckConstraints(_aToken_[:constraints], _aData_)
					_bSuccess_ = 0
					exit
				ok
				
				_aLocalMatched_ + _aData_
				_nElemIdx_++
			next
			
			if _bSuccess_
				# For last token, ensure complete match
				if nTokenIdx = _nLenTokens_
					if _nElemIdx_ = _nLenData_ + 1
						return 1
					ok
				else
					# Recurse for remaining tokens
					if This.BacktrackMatch(_aTokens_, _aNormalized_, nTokenIdx + 1, _nElemIdx_, _aLocalMatched_)
						return 1
					ok
				ok
			ok
		next
		
		return 0


	# TRUE if the tokens from a step on match the items starting at a position, items may be left over after.
	#
	#   _aTokens_       the list of tokens
	#   _aNormalized_   the items, as NormalizeTarget gives
	#   nTokenIdx       the 1-based index of the first token to use
	#   nDataIdx        the 1-based index of the first item to use
	#   aMatched        the matches so far, [ ] to start
	#   returns         TRUE or FALSE, as 1 or 0
	#   note            an instant token of exactly 1 matches from item 2 of two instants
	#   see             BacktrackMatch, MatchPartial
	def BacktrackMatchPartial(_aTokens_, _aNormalized_, nTokenIdx, nDataIdx, aMatched)
		_nLenTokens_ = len(_aTokens_)
		_nLenData_ = len(_aNormalized_)
		
		# Base case: all tokens processed - PARTIAL match succeeds
		if nTokenIdx > _nLenTokens_
			return 1
		ok
		
		# Out of data but tokens remain
		if nDataIdx > _nLenData_
			# Check if remaining tokens can match zero times
			for _i_ = nTokenIdx to _nLenTokens_
				if _aTokens_[_i_][:min] > 0
					return 0
				ok
			next
			return 1
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
					return 1
				ok
			next
			return 0
		ok
		
		# Calculate how many items could possibly match
		_nAvailable_ = 0
		for _i_ = nDataIdx to _nLenData_
			_aData_ = _aNormalized_[_i_]
			_bCanMatch_ = 0
			
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
			
			_bSuccess_ = 1
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
				
				_bTypeMatch_ = 0
				
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
					return 1
				else
					if This.BacktrackMatchPartial(_aTokens_, _aNormalized_, nTokenIdx + 1, _nElemIdx_, _aLocalMatched_)
						return 1
					ok
				ok
			ok
		next
		
		return 0


	# Turns a target into the flat list of items the matcher compares: instants, events and the duration gaps between them.
	#
	#   oTarget    a stzTimeLine, a stzCalendar, a list of date texts, stzDateTime or stzDuration
	#              objects, or one such object
	#   returns    a list of items, each a list of [ name, value ] pairs; [ ] for a target of another kind
	#   note       a timeline with instants A, B, C half an hour apart gives 5 items: A, a 30 minute gap, B,
	#              a gap, C; a text or a number given on its own gives [ ]; in a list, a text counts only when
	#              it is a date or a date and time, so the text x and any number are left out
	#   see        MatchExact, SortByDateTime
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
					["object", ""]
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
					["object", ""]
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
							["object", ""]
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
					["object", ""]
				]
			next
		
		but isList(oTarget)
			_nLen_ = len(oTarget)
			for _i_ = 1 to _nLen_
				_xItem_ = oTarget[_i_]
				
				if isString(_xItem_)
					if NOT This._IsInstantText(_xItem_)
						loop
					ok
					_aNormalized_ + [
						["type", "instant"],
						["label", ""],
						["datetime", _xItem_],
						["object", ""]
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
	

	# TRUE if an item satisfies every constraint of a step.
	#
	#   _aConstraints_   the list of constraints, from ParseConstraints
	#   _aData_          the item, with its type, label and minutes
	#   returns          TRUE or FALSE, as 1 or 0; TRUE for no constraints
	#   note             a 45 minute duration passes the range 30m..1h and a 90 minute one fails; a
	#                    step of 20m accepts 50 minutes and rejects 45; a set compares the label
	#                    without regard to case
	#   see              ParseConstraints, ParseDurationToMinutes
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
						return 0
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
								return 0
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
						return 0
					ok
				ok
			
			but _aConstraint_[:type] = "set"
				_bInSet_ = 0
				_nLenTemp_ = len(_aConstraint_[:values])
				for j = 1 to _nLenTemp_
					if StzLower(_aData_[:label]) = StzLower(@trim(_aConstraint_[:values][j]))
						_bInSet_ = 1
						exit
					ok
				next
				if not _bInSet_
					return 0
				ok
			ok
		next
		
		return 1
		
	# Records the items of a successful match as the matched parts.
	#
	#   _aNormalized_   the matched items
	#   returns         nothing; MatchedParts changes
	#   note            called by the two match methods after a success
	#   see             MatchedParts, MatchExact
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
	
	# Returns the parts recorded by the last match, as type, label and data.
	#
	#   returns    a list of [ type, label, data ] records; [ ] before any success and after a failed match
	#   note       a list of two dates matched by @Instant+ gives two parts
	#   see        MatchExact, MatchPartial
	def MatchedParts()
		return @aMatchedParts
	
	# Returns the tokens parsed from the pattern.
	#
	#   returns    a list of tokens, each a list of [ name, value ] pairs
	#   note       an empty pattern gives [ ]; one token per arrow-separated step
	#   see        Explain, ParsePattern
	def Tokens()
		return @aTokens
	
	# Returns each token as a record with its index, type, label, quantifier, constraints and negation.
	#
	#   returns    a list of records, each a list of [ name, value ] pairs
	#   note       the quantifier, constraints and negation appear only for a token that has one
	#   see        Tokens, Explain
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
				_aTokenInfo_ + ["negated", 1]
			ok
			
			_aInfo_ + _aTokenInfo_
		next
		
		return _aInfo_
	
	# Stores a target so that Explain can report it, without matching.
	#
	#   oTarget    the target to remember
	#   returns    nothing
	#   note       the match methods set the target themselves
	#   see        Explain, MatchExact
	def SetTarget(oTarget)
		@oTarget = oTarget
		@bTargetSet = 1
	
	# Returns the pattern text as stored, wrapped in braces.
	#
	#   returns    a text
	#   note       @Instant gives {@Instant}
	#   see        NormalizePattern, Tokens
	def Pattern()
		return @cPattern
	
	# Returns a summary of the pattern: its text, token count, tokens, whether a target is set and whether a match is recorded.
	#
	#   returns    a list of [ name, value ] pairs
	#   note       the keys are Pattern, TokenCount, Tokens, TargetSet and LastMatch; TargetSet is 0 on a
	#              fresh object and 1 once a target was given or matched
	#   see        Tokens, Pattern
	def Explain()
		# Return structured explanation
		return [
			["Pattern", @cPattern],
			["TokenCount", len(@aTokens)],
			["Tokens", This.TokensXT()],
			["TargetSet", @bTargetSet],
			["LastMatch", len(@aMatchedParts) > 0]
		]
	
	  #----------------------#
	 #  DEBUG METHODS       #
	#----------------------#
	
	# Turns on the debug printing of the parser and the matcher.
	#
	#   returns    nothing
	#   note       the flag only affects what is printed afterwards
	#   see        DisableDebug, SetDebug
	def EnableDebug()
		@bDebugMode = 1
	
	# Turns off the debug printing.
	#
	#   returns    nothing
	#   see        EnableDebug, SetDebug
	def DisableDebug()
		@bDebugMode = 0
	
	# Sets the debug printing on or off from a flag.
	#
	#   bFlag      1 to print debug lines, 0 not to
	#   returns    nothing
	#   see        EnableDebug, DisableDebug
	def SetDebug(bFlag)
		@bDebugMode = bFlag
	
	  #----------------------#
	 #  HELPER METHODS      #
	#----------------------#
	
	# TRUE if a text can be an instant: a date-time or a date.
	#
	#   c          the text
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       judged by StzIsDateTime and StzIsDate, so 2025-10-22 09:00:00 and 2025-10-22 are
	#              instants and x is not
	#   see        NormalizeTarget
	def _IsInstantText(c)
		return StzIsDateTime(c) or StzIsDate(c)

	# TRUE if the object is a timeline, judged by its class name containing timeline.
	#
	#   oObj       the value to test
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       a stzTimeLine gives TRUE and a text gives FALSE
	#   see        NormalizeTarget, @IsStzCalendar
	def @IsStzTimeLine(oObj)
		# Check if object is stzTimeLine instance
		if isObject(oObj)
			_cClassName_ = ring_classname(oObj)
			return contains(_cClassName_, "timeline")
		ok
		return 0
	
	# TRUE if the object is a calendar, judged by its class name containing calendar.
	#
	#   oObj       the value to test
	#   returns    TRUE or FALSE, as 1 or 0
	#   see        NormalizeTarget, @IsStzTimeLine
	def @IsStzCalendar(oObj)
		# Check if object is stzCalendar instance
		if isObject(oObj)
			_cClassName_ = ring_classname(oObj)
			return contains(_cClassName_, "calendar")
		ok
		return 0
	
	# TRUE if the object is a date-time, judged by its class name containing datetime.
	#
	#   oObj       the value to test
	#   returns    TRUE or FALSE, as 1 or 0
	#   see        NormalizeTarget, @IsStzDuration
	def @IsStzDateTime(oObj)
		# Check if object is stzDateTime instance
		if isObject(oObj)
			_cClassName_ = ring_classname(oObj)
			return contains(_cClassName_, "datetime")
		ok
		return 0
	
	# TRUE if the object is a duration, judged by its class name containing duration.
	#
	#   oObj       the value to test
	#   returns    TRUE or FALSE, as 1 or 0
	#   see        NormalizeTarget, @IsStzDateTime
	def @IsStzDuration(oObj)
		# Check if object is stzDuration instance
		if isObject(oObj)
			_cClassName_ = ring_classname(oObj)
			return contains(_cClassName_, "duration")
		ok
		return 0
	
	# Returns the smallest number of a list.
	#
	#   aValues    the list of numbers
	#   returns    a number
	#   see        BacktrackMatch
	def @Min(aValues)
		_nMin_ = aValues[1]
		_nLen_ = len(aValues)

		for _i_ = 2 to _nLen_
			if aValues[_i_] < _nMin_
				_nMin_ = aValues[_i_]
			ok
		next
		return _nMin_
