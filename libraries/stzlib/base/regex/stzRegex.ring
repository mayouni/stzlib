# The stzRegex class provides regular expression functionality
# backed by the Softanza Zig Engine (stz_regex.dll).

#---------------------------------------------------------------------

#INFO Some reference articles to read:

# A nice article to get the essentials of Regex
# https://trustedsec.com/blog/regex-cheat-sheet

# An other valuable link from Mozilla MSDN:
# https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Regular_expressions/Cheatsheet

#-----------

#TODO Features to add to regex in Softanza:

# - Use regex with lists not only strings
# - Support lookaheads, conditionals, and code-embedding
# - Use of regex not only to chek patterns but to generate new data using pattern
# - use regex to translate code between languages (lang1 -> abstract syntax tree --> lang2)
# - from patterns in stzregexdat.ring, add new functions to stzString

  #====================#
 #  GLOBAL VARIABLES  #
#====================#

# The four match types. Each says what it DOES -- that was the whole point of
# renaming them away from Qt's NormalMatch / PartialPreferCompleteMatch /
# PartialPreferFirstMatch / NoMatch, which said nothing.
#
#   :MatchEntireContent
#       The pattern must match the ENTIRE content, start to end, nothing left
#       over. "Entire content" is relative to the start position: matching
#       "hello world" from position 7 asks the pattern to match exactly
#       "world".
#
#   :MatchEntireContentIfNotGoPartial
#       Try that; and if the content is merely a PREFIX of something that
#       would match entirely, report a partial instead of failing. This is
#       as-you-type validation: "123" is not yet an SSN, but it is on the way.
#
#   :MatchFirstOccurrenceIfNotGoPartial
#       Find the first occurrence anywhere from the start position -- the
#       unanchored search -- falling back to a partial if there is no
#       complete occurrence at all.
#
#   :ReturnFalseForAnyMatch
#       The matching engine is OFF. Always false, whatever the pattern and
#       whatever the subject. Not "found nothing" -- didn't look.
#
# ORDER IS LOAD-BEARING: the position in this list is the type code the
# engine expects (stz_regex_match_typed, MT_ENTIRE..MT_NONE = 0..3). Adding
# a type means adding it engine-side too, at the same index.

_$aMATCH_TYPES = [
	:MatchEntireContent,			# -> 0
	:MatchEntireContentIfNotGoPartial,	# -> 1
	:MatchFirstOccurrenceIfNotGoPartial,	# -> 2
	:ReturnFalseForAnyMatch			# -> 3
]

_$aMATCH_OPTIONS = [
	:CaseInsensitive,	# flag 1
	:DotMatchesAll,		# flag 2
	:MultiLine,		# flag 4
	:ExtendedSyntax,	# flag 8
	:NonGreedy,		# flag 16
	:DontCapture,		# flag 32 (ignored by Engine)
	:UseUnicode,		# flag 64 (ignored by Engine -- always on via PCRE2_UTF|PCRE2_UCP)
	:DisableOptimizations,	# flag 128 (ignored by Engine)
	:RecursiveMatch,	# flag 256 (ignored by Engine)
]

  #=============#
 #  FUNCTIONS  #
#=============#

func StzRegexQ(pcPattern)
	return new stzRegex(pcPattern)

	func rx(pcPattern)
		return StzRegexQ(pcPattern)

func StzMatchTypes()
	return _$aMATCH_TYPES

	func MatchTypes()
		return StzMatchTypes()

	func @MatchTypes()
		return StzMatchTypes()

func StzMatchOptions()
	return _$aMATCH_OPTIONS

	func MatchOptions()
		return StzMatchOptions()

	func @MatchOptions()
		return StzMatchOptions()

func StzAllMatches(cInput, cPattern)
	_oRegex_ = new stzRegex(cPattern)
	_oRegex_.Match(cInput)
	return _oRegex_.AllMatches()

	func AllMatches(cInput, cPattern)
		return StzAllMatches(cInput, cPattern)

func StzRegexMatch(cInput, cPattern)
	pH = StzEngineRegexNew(cPattern, 0)
	if pH = NULL
		return FALSE
	ok
	_nResult_ = StzEngineRegexMatch(pH, cInput, 1)
	StzEngineRegexFree(pH)
	return _nResult_ = 1

func StzRegexReplace(cInput, cPattern, cReplacement)
	pH = StzEngineRegexNew(cPattern, 0)
	if pH = NULL
		return cInput
	ok
	StzEngineRegexMatch(pH, cInput, 1)
	_cResult_ = StzEngineRegexReplace(pH, cInput, cReplacement)
	StzEngineRegexFree(pH)
	return _cResult_

  #==================#
 #  STZREGEX CLASS  #
#==================#

class stzRegex from stzObject

	@pRegexHandle = NULL
	@cMatchType = ""
	@cPattern = ""
	@cStr = ""

	@nFlags = 0
	@nCompiledFlags = -1
	@acMatchOptions = []

	@bRecursiveMatch = FALSE
	@bLastMatchResult = FALSE

	# 0 = no match, 1 = complete match, 2 = partial match.
	@nLastMatchKind = 0

	  #----------------------------#
	 #  INIT AND PATTERN SEETING  #
	#----------------------------#

	def init(pcPattern)
		if CheckParams()
			if NOT isString(pcPattern)
				StzRaise("Incorrect param type! pcPattern must be a string.")
			ok
		ok

		if @trim(pcPattern) = ""
			StzRaise("Can't create the regex object! You must provide a non-empty pattern string.")
		ok

		This.SetPattern(pcPattern)

	def SetPattern(pcPattern)
		if CheckParams()
			if NOT isString(pcPattern)
				StzRaise("Incorrect param type! pcPattern must be a string.")
			ok
		ok

		if @pRegexHandle != NULL
			StzEngineRegexFree(@pRegexHandle)
		ok

		@cPattern = pcPattern
		@cMatchType = :MatchEntireContent

		if ring_substr1(pcPattern, NL) > 0
			@nFlags = @nFlags | 4
		ok

		@pRegexHandle = StzEngineRegexNew(pcPattern, @nFlags)
		@nCompiledFlags = @nFlags

	  #-------------------#
	 #  GENERAL METHODS  #
	#-------------------#

	def String()
		return @cStr

	def Pattern()
		return @cPattern

		def Content()
			return This.Pattern()

	def Copy()
		return new stzRegex(This.Pattern())

	def MatchType()
		return @cMatchType

	def MatchOptions()
		return @acMatchOptions

	def MatchTypeXT()
		_acResult_ = [ This.MatchType() ]
		_acOptions_ = This.MatchOptions()
		_nLen_ = len(_acOptions_)

		for @i = 1 to _nLen_
			_acResult_ + _acOptions_[@i]
		next

		return _acResult_

		def MatchTypeAndOptions()
			return This.MatchType()

	  #-------------------------#
	 #  CORE MATCH SERVICE     #
	#-------------------------#

	def MatchXT(pcStr, pnStartPosition, pcMatchType, pacOptions)

		if CheckParams()

			if NOT isString(pcStr)
				StzRaise("Incorrect param type! pcStr must be a string.")
			ok

			if NOT isNumber(pnStartPosition)
				StzRaise("Incorrect param type! pnStartPosition must be a number.")
			ok

			if NOT isString(pcMatchType)
				StzRaise("Incorrect param type! pcMatchType must be a string.")
			ok

			# An empty options list means "no options" and is valid. (Guard
			# against non-lists and non-string items only -- note an empty list
			# is NOT a list-of-strings, so it must be allowed explicitly.)
			if NOT ( isList(pacOptions) and (len(pacOptions) = 0 or IsListOfStrings(pacOptions)) )
				StzRaise("Incorrect param type! pacOptions must be a list of strings.")
			ok

		ok

		# The POSITION in @MatchTypes() is the type code the engine expects
		# -- see the ORDER IS LOAD-BEARING note on _$aMATCH_TYPES.
		_nTypeIdx_ = StzFindFirst(pcMatchType, @MatchTypes())

		if _nTypeIdx_ = 0
			StzRaise("Unsupported match type! Should be one of these " + @@(@MatchTypes()) + "!")
		ok

		_nType_ = _nTypeIdx_ - 1

		# Check the options with a direct scan.
		#
		# This used to be StzListQ(@MatchOptions()).ContainsThese(pacOptions),
		# which builds a whole stzList OBJECT around the options table on
		# EVERY match call -- the wrap-to-validate pattern in the hottest
		# place there is. Measured: 300 matches cost 0.10s, and ALL of it was
		# Ring-side validation. The engine compiled AND matched the same 300
		# in ~0s, recompiling every time included.

		_nMoLen_ = len(pacOptions)

		if _nMoLen_ > 0
			_acMoKnown_ = @MatchOptions()

			for _iMo_ = 1 to _nMoLen_
				if StzFindFirst(pacOptions[_iMo_], _acMoKnown_) = 0
					StzRaise("Unsupported match options! Should be one or more of these " + @@(_acMoKnown_) + "!")
				ok
			next
		ok

		@nFlags = 0
		_nLen_ = len(pacOptions)

		for i = 1 to _nLen_
			switch pacOptions[i]

			case :CaseInsensitive
				@nFlags = @nFlags | 1

			case :DotMatchesAll
				@nFlags = @nFlags | 2

			case :MultiLine
				@nFlags = @nFlags | 4

			case :ExtendedSyntax
				@nFlags = @nFlags | 8

			case :NonGreedy
				@nFlags = @nFlags | 16

			case :RecursiveMatch
				@bRecursiveMatch = TRUE
			off

		next

		# Recompile ONLY when the flags actually changed. The compiled code
		# depends on the pattern and the flags, and the pattern is fixed for
		# the life of the object (SetPattern rebuilds it). This used to free
		# and rebuild the pattern on EVERY call.
		if @pRegexHandle = NULL or @nFlags != @nCompiledFlags
			if @pRegexHandle != NULL
				StzEngineRegexFree(@pRegexHandle)
			ok

			@pRegexHandle = StzEngineRegexNew(@cPattern, @nFlags)
			@nCompiledFlags = @nFlags
		ok

		@acMatchOptions = pacOptions
		@cStr = pcStr
		@cMatchType = pcMatchType

		# The position goes over 1-based and is converted ONCE, in the
		# bridge. The old path subtracted 1 here AND again in the bridge, so
		# every position landed one character to the left; Matches() then
		# over-advanced by one and the two errors cancelled. Both are gone.
		_nStart_ = pnStartPosition
		if _nStart_ < 1
			_nStart_ = 1
		ok

		# The match TYPE is now honoured rather than merely validated:
		# anchoring and partial-matching are decided engine-side, per call,
		# with no recompilation (ANCHORED / ENDANCHORED / PARTIAL_SOFT are
		# all match-time options in PCRE2).
		#
		# Returns 0 = no match, 1 = complete match, 2 = partial match.
		@nLastMatchKind = StzEngineRegexMatchTyped(@pRegexHandle, pcStr, _nStart_, _nType_)

		if @nLastMatchKind = 1
			@bLastMatchResult = TRUE
		else
			@bLastMatchResult = FALSE
		ok

		return @nLastMatchKind

		#< @FunctionMisspelledForm

		def MacthXT(pcStr, pnStartPosition, pcMatchType, pacOptions)
			return This.MatchXT(pcStr, pnStartPosition, pcMatchType, pacOptions)

		#>

	  #--------------------#
	 #  Matching Methods  #
	#--------------------#

	def HasMatch()
		if @pRegexHandle = NULL
			return FALSE
		ok

		return StzEngineRegexHasMatch(@pRegexHandle)

	# Reads the recorded outcome of the LAST match, exactly as HasMatch()
	# does. It used to re-run a fresh unanchored partial probe instead, so
	# the two siblings could describe different matches.
	def HasPartialMatch()
		return @nLastMatchKind = 2

	# The kind of the last match: 0 none, 1 complete, 2 partial.
	def LastMatchKind()
		return @nLastMatchKind

	#-- Softanza scope-based pattern matching methods

	# The scope methods SEARCH within a scope -- the scope sets the
	# boundaries (what "." spans, where ^ and $ bind), the match type stays
	# the unanchored search. MatchWord("pre[a-z]+") finds "preset" inside a
	# longer sentence; that is the whole point of a word scope.

	def MatchLinesIn(pcStr)
		_nKind_ = This.MatchXT(pcStr, 1, :MatchFirstOccurrenceIfNotGoPartial, [ :MultiLine, :DotMatchesAll ])
		return _nKind_ = 1

		def MatchLine(pcStr)
			return This.MatchLinesIn(pcStr)

	def MatchFirstLineIn(pcStr)
		_nKind_ = This.MatchXT(pcStr, 1, :MatchFirstOccurrenceIfNotGoPartial, [ :MultiLine ])
		return _nKind_ = 1

		def MatchFirstLine(pcStr)
			return This.MatchFirstLineIn(pcStr)

	def MatchWordsIn(pcStr)
		_cWordPattern_ = "\b" + This.Pattern() + "\b"
		This.SetPattern(_cWordPattern_)
		_nKind_ = This.MatchXT(pcStr, 1, :MatchFirstOccurrenceIfNotGoPartial, [])
		return _nKind_ = 1

		def MatchWord(pcStr)
			return This.MatchWordsIn(pcStr)

	def MatchFirstWordIn(pcStr)
		_cWordPattern_ = "\b" + This.Pattern() + "\b"
		This.SetPattern(_cWordPattern_)
		_nKind_ = This.MatchXT(pcStr, 1, :MatchFirstOccurrenceIfNotGoPartial, [])
		return _nKind_ = 1

		def MatchFirstWord(pcStr)
			return This.MatchFirstWordIn(pcStr)

	def MatchSegmentsIn(pcStr)
		_nKind_ = This.MatchXT(pcStr, 1, :MatchFirstOccurrenceIfNotGoPartial, [ :DotMatchesAll, :MultiLine ])
		return _nKind_ = 1

		def MatchSegment(pcStr)
			return This.MatchSegmentsIn(pcStr)

	def MatchFirstSegmentIn(pcStr)
		_nKind_ = This.MatchXT(pcStr, 1, :MatchFirstOccurrenceIfNotGoPartial, [ :DotMatchesAll, :MultiLine ])
		return _nKind_ = 1

		def MatchFirstSegment(pcStr)
			return This.MatchFirstSegmentIn(pcStr)

	# Match() ANCHORS: it asks whether the pattern matches the string
	# ENTIRELY, not whether it occurs somewhere inside it. rx("[0-9]+") does
	# not match "abc123" -- "abc123" is not a run of digits. Use MatchFirst()
	# for "does this occur anywhere", Matches() for every occurrence.
	#
	# This is what :MatchEntireContent has always said it does, and what the
	# naming redesign settled on: match the complete pattern against the
	# complete content.

	def Match(pcStr)

		_nKind_ = This.MatchXT(pcStr, 1, :MatchEntireContent, [ :DotMatchesAll ])
		return _nKind_ = 1

		#< @FunctionAlternativeForm

		def MatchString(pcStr)
			return This.Match(pcStr)
		#>

		#< @FunctionMisspelledForms

		def Macth(pcStr)
			return This.Match(pcStr)

		def MacthString(pcStr)
			return This.Match(pcStr)

		def IsMatched(pcStr)
			return This.Match(pcStr)

		#>

	def MatchMany(pacStr)
		if NOT ( isList(pacStr) and IsListOfStrings(pacStr) )
			StzRaise("Incorrect param type! pacStr must be a list of strings.")
		ok

		_bResult_ = 1
		_nLen_ = len(pacStr)

		for @i = 1 to _nLen_
			if NOT This.Match(pacStr[@i])
				_bResult_ = 0
				exit
			ok
		next

		return _bResult_

	def MatchManyXT(pacStr)
		if NOT ( isList(pacStr) and IsListOfStrings(pacStr) )
			StzRaise("Incorrect param type! pacStr must be a list of strings.")
		ok

		_abResult_ = []
		_nLen_ = len(pacStr)

		for @i = 1 to _nLen_
			_abResult_ + This.Match(pacStr[@i])
		next

		return _abResult_

	# The SEARCH counterpart of Match(): is there a first occurrence of the
	# pattern anywhere in the string? rx("[0-9]+").MatchFirst("abc123") is
	# TRUE where .Match("abc123") is FALSE.

	def MatchFirst(pcStr)
		_nKind_ = This.MatchXT(pcStr, 1, :MatchFirstOccurrenceIfNotGoPartial, [ :DotMatchesAll ])
		return _nKind_ = 1

		#< @FunctionAlternativeForms

		def MatchAnywhere(pcStr)
			return This.MatchFirst(pcStr)

		def Occurs(pcStr)
			return This.MatchFirst(pcStr)

		#>

	# Searches for the next occurrence FROM nPos (1-based), which is what
	# Matches() needs to walk a string. Not "must match starting exactly at
	# nPos" -- that is MatchXT(s, nPos, :MatchEntireContent, ...).

	def MatchAt(pcStr, nPos)
		if CheckParams()
			if NOT isString(pcStr)
				StzRaise("Incorrect param type! pcStr must be a string.")
			ok
		if NOT isNumber(nPos)
			StzRaise("Incorrect param type! nPos must be a number.")
		ok
	ok

	_nKind_ = This.MatchXT(pcStr, nPos, :MatchFirstOccurrenceIfNotGoPartial, [])
	return _nKind_ = 1

	#-- Getting all the matching values in a given string

	def Matches()

		_acResults_ = []
		_nPos_ = 1

		while This.MatchAt(@cStr, _nPos_)
			_cMatch_ = StzEngineRegexCaptureText(@pRegexHandle, 1)

			if _cMatch_ != ""
				_acResults_ + _cMatch_

				# CaptureEnd() is the 1-based position just PAST the match,
				# so it is already where the next search starts. It used to
				# be _nEnd_ + 1 here, which skipped a character -- harmless
				# only because the start position was ALSO one short (two
				# decrements, see MatchXT). Both are fixed together.
				_nPos_ = StzEngineRegexCaptureEnd(@pRegexHandle, 1)
			else
				break
			ok
		end

		return _acResults_

		#< @FunctionAlternativeForms

		def AllMatchingValues()
			return This.Matches()

		def MatchingValues()
			return This.Matches()

		def MatchingSubStrings()
			return This.Matches()

		def AllMatches()
			return This.Matches()

		def MatchedValues()
			return This.Matches()

		def MatchedSubStrings()
			return This.Matches()

		def Result()
			return This.Matches()

		def Results()
			return This.Matches()

		def Harvest()
			return This.Matches()

		#>

	def NumberOfMatches()
		return len(AllMatches())

		def NumberOfMatchingValues()
			return This.NumberOfMatches()

		def HowManyMatches()
			return This.NumberOfMatches()

		def HowManyMatchingValues()
			return This.NumberOfMatches()

		def CountMatches()
			return This.NumberOfMatches()

		def CountMatchingValues()
			return This.NumberOfMatches()

	def NumberOfChars()
		if @pRegexHandle = NULL return 0 ok
		_nStart_ = StzEngineRegexCaptureStart(@pRegexHandle, 1)
		_nEnd_ = StzEngineRegexCaptureEnd(@pRegexHandle, 1)
		if _nStart_ < 0 or _nEnd_ < 0 return 0 ok
		return _nEnd_ - _nStart_

		def CapturedLength()
			return This.NumberOfChars()

	def FindMatches()
		_anResults_ = []
		_nPos_ = 1

		while This.MatchAt(@cStr, _nPos_)
			_cMatch_ = StzEngineRegexCaptureText(@pRegexHandle, 1)

			if _cMatch_ != ""
				_nStart_ = StzEngineRegexCaptureStart(@pRegexHandle, 1)
				_nEnd_ = StzEngineRegexCaptureEnd(@pRegexHandle, 1)
				_anResults_ + _nStart_
				_nPos_ = _nEnd_ + 1
			else
				break
			ok
		end

		return _anResults_

		#< @FunctionAlternativeForms

		def FindValues()
			return This.FindMatches()

		def FindMatchingValues()
			return This.FindMatches()

		def FindMatchingSubStrings()
			return This.FindMatches()

		#--

		def FindValuesZ()
			return This.FindMatches()

		def FindMatchesZ()
			return This.FindMatches()

		def FindMatchingValuesZ()
			return This.FindMatches()

		def FindMatchingSubStringsZ()
			return This.FindMatches()

		#>

	def MatchesZ()
		? @@(This.FindMatches())


		#< @FunctionAlternativeForms

		def ValuesAndTheirPositions()
			return This.MatchesZ()

		def MatchesAndTheirPositions()
			return This.MatchesZ()

		def MatchingValuesAndTheirPositions()
			return This.MatchesZ()

		def MatchingSubStringsAndTheirPositions()
			return This.MatchesZ()

		#--

		def ValuesZ()
			return This.MatchesZ()

		def MatchingValuesZ()
			return This.MatchesZ()

		def MatchingSubStringsZ()
			return This.MatchesZ()

		#>

	def FindMatchesZZ()

		_aResults_ = []
		_nPos_ = 1

		while This.MatchAt(@cStr, _nPos_)
			_cMatch_ = StzEngineRegexCaptureText(@pRegexHandle, 1)

			if _cMatch_ != ""
				_nStart_ = StzEngineRegexCaptureStart(@pRegexHandle, 1)
				_nEnd_ = StzEngineRegexCaptureEnd(@pRegexHandle, 1)
				_nPos_ = _nEnd_ + 1
				_aResults_ + [_nStart_, _nEnd_]
			else
				break
			ok
		end

		return _aResults_

		#< @FunctionAlternativeForms

		def FindValuesAsSections()
			return This.FindMatchesZZ()

		def FindMatchesAsSections()
			return This.FindMatchesZZ()

		def FindMatchingValuesAsSection()
			return This.FindMatchesZZ()

		def FindMatchingSubStringsAsSections()
			return This.FindMatchesZZ()

		#--

		def FindValuesZZ()
			return This.FindMatchesZZ()

		def FindMatchingValuesZZ()
			return This.FindMatchesZZ()

		def FindMatchingSubStringsZZ()
			return This.FindMatchesZZ()

		#>

	def MatchesZZ()

		_aResults_ = []
		_nPos_ = 1

		while This.MatchAt(@cStr, _nPos_)
			_cMatch_ = StzEngineRegexCaptureText(@pRegexHandle, 1)

			if _cMatch_ != ""
				_nStart_ = StzEngineRegexCaptureStart(@pRegexHandle, 1)
				_nEnd_ = StzEngineRegexCaptureEnd(@pRegexHandle, 1)
				_nPos_ = _nEnd_ + 1
				_aResults_ + [ _cMatch_, [_nStart_, _nEnd_] ]
			else
				break
			ok
		end

		return _aResults_

		#< @FunctionAlternativeForms

		def ValuesAsSections()
			return This.MatchesZZ()

		def MatchesAsSections()
			return This.MatchesZZ()

		def MatchingValuesAsSection()
			return This.MatchesZZ()

		def MatchingSubStringsAsSections()
			return This.MatchesZZ()

		#--

		def ValuesZZ()
			return This.MatchesZZ()

		def MatchingValuesZZ()
			return This.MatchesZZ()

		def MatchingSubStringsZZ()
			return This.MatchesZZ()

		#>

	  #--------------------------------#
	 #  Group Capture-related methods #
	#--------------------------------#

	def HasGroups()
		return This.CaptureCount() > 0

	def HasNames()
		if @pRegexHandle = NULL return FALSE ok
		return StzEngineRegexNamedGroupCount(@pRegexHandle) > 0

	def CaptureGroups()

		if NOT This.HasGroups()
			StzRaise("No capture groups found in pattern. Use groups like (xyz) to capture values.")
		ok

		_acResult_ = []

		for @i = 1 to This.CaptureCount()
			_cCapture_ = StzEngineRegexCaptureText(@pRegexHandle, @i)
			if _cCapture_ != ""
				_acResult_ + _cCapture_
			ok
		next

		return _acResult_

		#< @FunctionAlternativeForms

		def Capture()
			return This.CaptureGroups()

		def Captures()
			return This.CaptureGroups()

		def CaptureValues()
			return This.CaptureGroups()

		def CapturedValues()
			return This.CaptureGroups()

		#--

		def CaptureSubStrings()
			return This.CaptureGroups()

		def CaptureMatchingSubStrings()
			return This.CaptureGroups()

		#>

	def HasValues()
		return len(This.MatchedValues()) > 0

		def HasMatches()
			return This.HasValues()

		def HasMatchedValues()
			return This.HasValues()

	def CaptureNames()
		if @pRegexHandle = NULL return [] ok

		_nCount_ = StzEngineRegexNamedGroupCount(@pRegexHandle)
		if _nCount_ = 0 return [] ok

		# Walk the pattern to get names in source order.
		# PCRE2's enumeration is alphabetical (hash-based) which is
		# rarely what callers want; the test corpus and most usages
		# expect pattern order. Two named-group syntaxes are
		# accepted: (?<name>...) and (?P<name>...).
		_acResult_ = This._CaptureNamesFromPattern()
		if len(_acResult_) > 0
			return _acResult_
		ok

		# Fallback: engine enumeration (alphabetical) if pattern
		# scanning yielded nothing.
		for @i = 1 to _nCount_
			_cName_ = StzEngineRegexNamedGroupName(@pRegexHandle, @i)
			if _cName_ != ""
				_acResult_ + _cName_
			ok
		next

		return _acResult_

	def _CaptureNamesFromPattern()
		# Scan @cPattern for (?<name>... or (?P<name>... outside
		# character classes and not preceded by a backslash.
		_acCnp_ = []
		if NOT isString(@cPattern) or @cPattern = ""
			return _acCnp_
		ok
		_cPat_ = @cPattern
		_nPat_ = len(_cPat_)
		_i_ = 1
		_bInClass_ = 0
		while _i_ <= _nPat_
			_cCh_ = StzMid(_cPat_, _i_, 1)
			if _cCh_ = "\" and _i_ < _nPat_
				_i_ += 2
				loop
			ok
			if _cCh_ = "[" and NOT _bInClass_
				_bInClass_ = 1
				_i_++
				loop
			ok
			if _cCh_ = "]" and _bInClass_
				_bInClass_ = 0
				_i_++
				loop
			ok
			if _bInClass_
				_i_++
				loop
			ok
			# Try to match (?<NAME> or (?P<NAME>
			if _cCh_ = "(" and _i_ + 2 <= _nPat_ and StzMid(_cPat_, _i_+1, 1) = "?"
				_nNameStart_ = 0
				if StzMid(_cPat_, _i_+2, 1) = "<" and _i_+3 <= _nPat_ and StzMid(_cPat_, _i_+3, 1) != "="
					# Skip "(?<" but reject "(?<=" lookbehind. Also skip "(?<!" .
					if StzMid(_cPat_, _i_+3, 1) != "!"
						_nNameStart_ = _i_ + 3
					ok
				but _i_ + 3 <= _nPat_ and StzMid(_cPat_, _i_+2, 2) = "P<"
					_nNameStart_ = _i_ + 4
				ok
				if _nNameStart_ > 0
					# Read up to '>'
					_j_ = _nNameStart_
					while _j_ <= _nPat_ and StzMid(_cPat_, _j_, 1) != ">"
						_j_++
					end
					if _j_ <= _nPat_ and _j_ > _nNameStart_
						_acCnp_ + StzMid(_cPat_, _nNameStart_, _j_ - _nNameStart_)
						_i_ = _j_ + 1
						loop
					ok
				ok
			ok
			_i_++
		end
		return _acCnp_

		def Names()
			return This.CaptureNames()

		def CaptureGroupNames()
			return This.CaptureNames()

	def CapturedGroups()
		if NOT This.HasGroups()
			StzRaise("No capture groups found in pattern. Use groups like (xyz) to capture values.")
		ok

		_aResult_ = []

		for @i = 1 to This.CaptureCount()
			_cVal_ = StzEngineRegexCaptureText(@pRegexHandle, @i)
			if _cVal_ != ""
				_aResult_ + [ "" + @i, _cVal_ ]
			ok
		next

		return _aResult_

		def Groups()
			return This.CapturedGroups()

	def CaptureByName(pcName)
		if @pRegexHandle = NULL return "" ok
		return StzEngineRegexCaptureByName(@pRegexHandle, pcName)

		def NamedCapture(pcName)
			return This.CaptureByName(pcName)

		def GroupByName(pcName)
			return This.CaptureByName(pcName)

	def NamedGroups()
		if NOT This.HasNames() return [] ok

		_acNames_ = This.CaptureNames()
		_aResult_ = []
		_nLen_ = len(_acNames_)

		for @i = 1 to _nLen_
			_cVal_ = StzEngineRegexCaptureByName(@pRegexHandle, _acNames_[@i])
			_aResult_ + [ _acNames_[@i], _cVal_ ]
		next

		return _aResult_

		def NamedCaptureGroups()
			return This.NamedGroups()

		def CaptureXT()
			return This.NamedGroups()

		def CapturesXT()
			return This.NamedGroups()

		def CaptureGroupsXT()
			return This.NamedGroups()

	def FindCapture()
		_aPosZZ_ = This.FindMatchesZZ()
		_nLen_ = len(_aPosZZ_)

		_anResult_ = []

		for @i = 1 to _nLen_
			_anResult_ + _aPosZZ_[@i][1]
		next

		return _anResult_


		#< @FunctionAlternativeForms

		def FindCaptureValues()
			return This.FindCapture()

		def FindCapturedValues()
			return This.FindCapture()

		#--

		def FindCaptureSubStrings()
			return This.FindCapture()

		def FindCaptureMatchingSubStrings()
			return This.FindCapture()

		def FindCaptures()
			return This.FindCapture()

		#>

	def CaptureGroupsZ()

		if NOT This.HasGroups()
			StzRaise("No capture groups found in pattern. Use groups like (xyz) to capture values.")
		ok

		_aResult_ = []

		for @i = 1 to This.CaptureCount()
			_cCapture_ = StzEngineRegexCaptureText(@pRegexHandle, @i)
			if _cCapture_ != ""
				_nPos_ = StzEngineRegexCaptureStart(@pRegexHandle, @i)
				if _nPos_ > 0
					_aResult_ + [ _cCapture_, _nPos_]
				ok
			ok
		next

		return _aResult_

		#< @FunctionAlternativeForms

		def CaptureZ()
			return This.CaptureGroupsZ()

		def CaptureValuesZ()
			return This.CaptureGroupsZ()

		def CapturedValuesZ()
			return This.CaptureGroupsZ()

		#--

		def CaptureSubStringsZ()
			return This.CaptureZ()

		def CaptureMatchingSubStringsZ()
			return This.CaptureZ()

		#>

	def FindCaptureZZ()

		_aResult_ = []
		_aInfo_ = This.CaptureZZ()
		_nLen_ = len(_aInfo_)

		for @i = 1 to _nLen_
			_aResult_ + _aInfo_[@i][2]
		next

		return _aResult_

		#< @FunctionAlternativeForms

		def FindCaptureValuesZZ()
			return This.FindCaptureZZ()

		def FindCapturedValuesZZ()
			return This.FindCaptureZZ()

		#--

		def FindCaptureSubStringsZZ()
			return This.FindCaptureZZ()

		def FindCaptureMatchingSubStringsZZ()
			return This.FindCaptureZZ()

		def FindCapturesZZ()
			return This.FindCaptureZZ()

		#>

	def CaptureGroupsZZ()

		if NOT This.HasGroups()
			StzRaise("No capture groups found in pattern. Use groups like (xyz) to capture values.")
		ok

		_aResult_ = []

		for @i = 1 to This.CaptureCount()

			_cCapture_ = StzEngineRegexCaptureText(@pRegexHandle, @i)

			if _cCapture_ != ""
				_aSection_ = [ StzEngineRegexCaptureStart(@pRegexHandle, @i),
					       StzEngineRegexCaptureEnd(@pRegexHandle, @i) ]
				_aResult_ + [ _cCapture_, _aSection_ ]
			ok
		next

		return _aResult_

		#< @FunctionAlternativeForms

		def CaptureZZ()
			return This.CaptureGroupsZZ()

		def CaptureValuesZZ()
			return This.CaptureGroupsZZ()

		def CapturedValuesZZ()
			return This.CaptureGroupsZZ()

		#--

		def CaptureSubStringsZZ()
			return This.CaptureGroupsZZ()

		def CaptureMatchingSubStringsZZ()
			return This.CaptureGroupsZZ()

		#>

	  #--------------------------------------#
	 #  Pattern information and validation  #
	#--------------------------------------#

 	def CaptureCount()
		if @pRegexHandle = NULL return 0 ok
		return StzEngineRegexCaptureCount(@pRegexHandle)

	def IsValid()
		return @pRegexHandle != NULL

		def IsValidPattern()
			return THis.IsValid()

	def LastError()
		return ""

	def PatternErrorOffset()
		return -1

	  #-----------------#
	 #  Partial Match   #
	#-----------------#

	# TRUE only when pcStr is a strict PREFIX of something that would match
	# entirely -- on the way there, not there yet.
	def IsPartialMatch(pcStr)
		if @pRegexHandle = NULL return FALSE ok
		_nKind_ = This.MatchXT(pcStr, 1, :MatchEntireContentIfNotGoPartial, [])
		return _nKind_ = 2

		def IsPartial(pcStr)
			return This.IsPartialMatch(pcStr)

		def PartialMatch(pcStr)
			return This.IsPartialMatch(pcStr)

		def MatchPartial(pcStr)
			return This.IsPartialMatch(pcStr)

	def IsCompleteMatch(pcStr)
		_nKind_ = This.MatchXT(pcStr, 1, :MatchEntireContent, [])
		return _nKind_ = 1

		def IsComplete(pcStr)
			return This.IsCompleteMatch(pcStr)

	# Accepts what is already valid AND what could still become valid --
	# which is what form validation needs while the user is still typing.
	# Against "^\d{3}-\d{2}-\d{4}$": "123" TRUE (partial), "123-45-6789"
	# TRUE (complete), "abc" FALSE (cannot get there from here).
	#
	# This is the method the two partial match types exist for. Until the
	# types were wired up it just called an entire-content match, so it
	# rejected every incomplete input -- the exact case it is named after.
	def MatchAsYouType(pcStr)
		_nKind_ = This.MatchXT(pcStr, 1, :MatchEntireContentIfNotGoPartial, [])
		return _nKind_ > 0

		def ValidateAsTyped(pcStr)
			return This.MatchAsYouType(pcStr)

	# The search counterpart: is a match either present, or still possible
	# if more text arrives? Used for progressive/incremental search.
	def MatchInProgress(pcStr)
		_nKind_ = This.MatchXT(pcStr, 1, :MatchFirstOccurrenceIfNotGoPartial, [])
		return _nKind_ > 0

		def SearchInProgress(pcStr)
			return This.MatchInProgress(pcStr)

	def PartialMatchInfo(pcStr)

		if @pRegexHandle = NULL
			return [
				:matchType = "none",
				:matched   = "",
				:section  = []
			]
		ok

		_nResult_ = This.MatchXT(pcStr, 1, :MatchEntireContentIfNotGoPartial, [])

		if _nResult_ = 1
			_nStart_ = StzEngineRegexCaptureStart(@pRegexHandle, 1)
			_nEnd_ = StzEngineRegexCaptureEnd(@pRegexHandle, 1)
			# Convert engine's half-open [start, end) to Softanza's
			# inclusive [start, end] convention so callers can use
			# the pair directly with Section()/Substr().
			return [
				:matchType = "complete",
				:matched   = pcStr,
				:section  = [ _nStart_, _nEnd_ - 1 ]
			]
		ok

		if _nResult_ = 2
			_nStart_ = StzEngineRegexCaptureStart(@pRegexHandle, 1)
			_nEnd_ = StzEngineRegexCaptureEnd(@pRegexHandle, 1)
			return [
				:matchType = "partial",
				:matched   = StzSubStr(pcStr, _nStart_, _nEnd_ - _nStart_),
				:section  = [ _nStart_, _nEnd_ - 1 ]
			]
		ok

		return [
			:matchType = "none",
			:matched   = "",
			:section  = []
		]

		def MatchPartialInfo(pcStr)
			return This.PartialMatchInfo(pcStr)

	def FindPartialMatch(pcStr)
		return This.PartialMAtchInfo(pcStr)[3][2][1]

		def FindPartialMatchZ(pcStr)
			return This.FindPartialMatch(pcStr)


	def PartialMatchStart(pcStr)
		_aInfo_ = This.PartialMatchInfo(pcStr)
		if _aInfo_[1][2] = "none" return 0 ok
		return _aInfo_[3][2][1]

	def FindPartialMatchZZ(pcStr)
		return This.PartialMatchInfo(pcStr)[3][2]

	def PartialMatchLength(pcStr)
		_aInfo_ = This.PartialMatchInfo(pcStr)
		if _aInfo_[1][2] = "none" return 0 ok
		return _aInfo_[3][2][2] - _aInfo_[3][2][1]

		def PartialMatchSize(pcStr)
			return This.PartialMatchLength(pcStr)

		def PartialMatchNumberOfChars(pcStr)
			return This.PartialMatchLength(pcStr)

	def PartialMatchZ(pcStr)
		_aInfo_ = This.PartialMatchInfo(pcStr)
		if _aInfo_[1][2] = "partial"
			return [ TRUE, _aInfo_[3][2][1] ]
		ok
		return [ FALSE, 0 ]

	  #----------------------------#
	 #  Recursive (Nested) Match  #
	#----------------------------#

	def MatchRecursive(pcStr)
		_bResult_ = This.MatchXT(pcStr, 1, :MatchEntireContent, [ :RecursiveMatch ])
		@bRecursiveMatch = _bResult_
		return _bResult_

		def RecursiveMatch(pcStr)
			return This.MatchRecursive(pcStr)

		#--

		def MatchNested(pcStr)
			return This.MatchRecursive(pcStr)

		def NestedMatch(pcStr)
			return This.MatchRecursive(pcStr)

	def IsRecursiveMatch()
		return @bRecursiveMatch

		def IsNestedMatch()
			return This.IsRecursiveMatch()

	def RecursiveMatchInfo()
		if NOT This.IsRecursiveMatch()
			return [ :IsRecursive = FALSE, :depth = 0, :matches = [] ]
		ok

		_aMatches_ = []
		_nMaxDepth_ = 0

		_cStr_ = This.String()
		_nStart_ = 1
		This.MatchAt(_cStr_, _nStart_)
		_acSeen_ = []

		while This.HasMatch()

			_cCapture_ = StzEngineRegexCaptureText(@pRegexHandle, 1)

			if StzFindFirst(_cCapture_, _acSeen_) = 0

				_nS_ = StzEngineRegexCaptureStart(@pRegexHandle, 1)
				_nE_ = StzEngineRegexCaptureEnd(@pRegexHandle, 1)

				_aMatches_ + [
					_cCapture_,
					[ _nS_, _nE_ ]
				]

				_nMaxDepth_++
				_acSeen_ + _cCapture_
			ok

			This.MatchAt(_cStr_, _nStart_++)

		end

		return [
			:IsRecursive = TRUE,
			:depth = _nMaxDepth_,
			:matches = _aMatches_
		]

		def NestedMatchInfo(pcStr)
			return This.RecursiveMatchInfo(pcStr)

	def MatchManyRecursive(pacStr)
		if NOT ( isList(pacStr) and IsListOfStrings(pacStr) )
			StzRaise("Incorrect param type! pacStr must be a list of strings.")
		ok

		_bResult_ = 1
		_nLen_ = len(pacStr)

		for @i = 1 to _nLen_
			if NOT This.MatchRecursive(pacStr[@i])
				_bResult_ = 0
				exit
			ok
		next

		return _bResult_

		def MatchManyNested(pacStr)
			return This.MatchManyRecursive(pacStr)

	def MatchManyRecursiveXT(pacStr)
		if NOT ( isList(pacStr) and IsListOfStrings(pacStr) )
			StzRaise("Incorrect param type! pacStr must be a list of strings.")
		ok

		_abResult_ = []
		_nLen_ = len(pacStr)

		for @i = 1 to _nLen_
			_abResult_ + This.MatchRecursive(pacStr[@i])
		next

		return _abResult_

		def MatchManyNestedXT(pacStr)
			return This.MatchManyRecursiveXT(pacStr)

	def RecursiveSubStringsZZ()
		return This.RecursiveMatchInfo()[3][2]

		#< @FunctionAlternativeForms

		def RecursiveValuesZZ()
			return This.RecursiveSubStringsZZ()

		def NestedSubStringsZZ()
			return This.RecursiveSubStringsZZ()

		def NestedValuesZZ()
			return This.RecursiveSubStringsZZ()

		#--

		def RecursiveMatchesZZ()
			return This.RecursiveSubStringsZZ()

		def NestedMatchesZZ()
			return This.RecursiveSubStringsZZ()

		#>

	def RecursiveSubStrings()
		_aTemp_ = This.RecursiveMatchInfo()[3][2]
		_nLen_ = len(_aTemp_)

		_acResult_ = []

		for @i = 1 to _nLen_
			_acResult_ + _aTemp_[@i][1]
		next

		return _acResult_

		#< @FunctionAlternativeForms

		def RecursiveValues()
			return This.RecursiveSubStrings()

		def NestedSubStrings()
			return This.RecursiveSubStrings()

		def NestedValues()
			return This.RecursiveSubStrings()

		#---

		def RecursiveMatches()
			return This.RecursiveSubStrings()

		def NestedMatches()
			return This.RecursiveSubStrings()

		#>

	def RecursiveSubStringsZ()
		_aTemp_ = This.RecursiveMatchInfo()[3][2]
		_nLen_ = len(_aTemp_)

		_acResult_ = []

		for @i = 1 to _nLen_
			_acResult_ + [ _aTemp_[@i][1], _aTemp_[@i][2][1] ]
		next

		return _acResult_

		#< @FunctionAlternativeForms

		def RecursiveValuesZ()
			return This.RecursiveSubStringsZ()

		def NestedSubStringsZ()
			return This.RecursiveSubStringsZ()

		def NestedValuesZ()
			return This.RecursiveSubStringsZ()

		#--

		def RecursiveMatchesZ()
			return This.RecursiveSubStringsZ()

		def NestedMatchesZ()
			return This.RecursiveSubStringsZ()

		#>

	def FindRecursiveSubStringsZZ()
		_aTemp_ = This.RecursiveMatchInfo()[3][2]
		_nLen_ = len(_aTemp_)

		_acResult_ = []

		for @i = 1 to _nLen_
			_acResult_ + _aTemp_[@i][2]
		next

		return _acResult_

		#< @FunctionAlternativeForms

		def FindRecursiveValuesZZ()
			return This.FindRecursiveSubStringsZZ()

		def FindNestedSubStringsZZ()
			return This.FindRecursiveSubStringsZZ()

		def FindNestedValuesZZ()
			return This.FindRecursiveSubStringsZZ()

		#--

		def FindRecursiveMatchesZZ()
			return This.FindRecursiveSubStringsZZ()

		def FindNestedMatchesZZ()
			return This.FindRecursiveSubStringsZZ()

		def FindRecursiveZZ()
			return This.FindRecursiveSubStringsZZ()

		def FindNestedZZ()
			return This.FindRecursiveSubStringsZZ()

		#>

	def FindRecursiveSubStrings()
		_aTemp_ = This.RecursiveMatchInfo()[3][2]
		_nLen_ = len(_aTemp_)

		_acResult_ = []

		for @i = 1 to _nLen_
			_acResult_ + _aTemp_[@i][2][1]
		next

		return _acResult_

		#< @FunctionAlternativeForms

		def FindRecursiveSubStringsZ()
			return This.FindRecursiveSubStrings()

		def FindRecursiveValues()
			return This.FindRecursiveSubStrings()

		def FindRecursiveValuesZ()
			return This.FindRecursiveSubStrings()

		#--

		def FindNestedSubPatterns()
			return This.FindRecursiveSubStrings()

		def FindNestedSubStringsZ()
			return This.FindRecursiveSubStrings()

		def FindNestedValues()
			return This.FindRecursiveSubStrings()

		def FindNestedValuesZ()
			return This.FindRecursiveSubStrings()

		#==

		def FindRecursiveMatches()
			return This.FindRecursiveSubStrings()

		def FindRecursiveMatchesZ()
			return This.FindRecursiveSubStrings()

		def FindNestedMatches()
			return This.FindRecursiveSubStrings()

		def FindNestedMatchesZ()
			return This.FindRecursiveSubStrings()

		def FindRecursive()
			return This.FindRecursiveSubStrings()

		def FindRecursiveZ()
			return This.FindRecursiveSubStrings()

		def FindNested()
			return This.FindRecursiveSubStrings()

		def FindNestedZ()
			return This.FindRecursiveSubStrings()

		#>

	def RecursiveDepth()
		return This.RecursiveMatchInfo()[2][2]

		def NestedDepth()
			return This.RecursiveMatchInfo()[2][2]

	#-- Named Recursive Match

	def RecursiveNames()
		return This.Names()

		#< @FunctionAlternativeForms

		def RecursiveNamedGroups()
			return This.RecursiveNames()

		def RecursiveGroupsNames()
			return This.RecursiveNames()

		#--

		def NestedNames()
			return This.RecursiveNames()

		def NestedNamedGroups()
			return This.RecursiveNames()

		def NestedGroupsNames()
			return This.RecursiveNames()

		#>

	  #-----------------------#
	 #  Explanation methods  #
	#-----------------------#

	def Explain()
		_cResult_ = ""
		_cName_ = RegexPatternName(This.Pattern())

		if _cName_ != ""
			_cResult_ = RegexPatternExplanation(_cName_)[1]
		ok

		if _cResult_ = ""
			_oRxAnal_ = new stzRegexAnalyzer(This.Pattern())
			_cResult_ = _oRxAnal_.Explain()
		ok

		if _cResult_ = ""
			StzRaise("Can't explain the pattern.")
		ok

		return _cResult_

	def ExplainXT()
		_cResult_ = ""
		_cName_ = RegexPatternName(This.Pattern())

		if _cName_ != ""
			_cResult_ = RegexPatternExplanation(_cName_)[2]
		ok

		if _cResult_ = ""
			_oRxAnal_ = new stzRegexAnalyzer(This.Pattern())
			_cResult_ = _oRxAnal_.ExplainXT()
		ok

		if _cResult_ = ""
			StzRaise("Can't explain the pattern.")
		ok

		return _cResult_
