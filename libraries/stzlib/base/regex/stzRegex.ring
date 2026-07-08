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

_$aMATCH_TYPES = [
	:MatchEntireContent,
	:MatchEntireContentIfNotGoPartial,
	:MatchFirstOccurrenceIfNotGoPartial,
	:ReturnFalseForAnyMatch
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
	oRegex = new stzRegex(cPattern)
	oRegex.Match(cInput)
	return oRegex.AllMatches()

	func AllMatches(cInput, cPattern)
		return StzAllMatches(cInput, cPattern)

func StzRegexMatch(cInput, cPattern)
	pH = StzEngineRegexNew(cPattern, 0)
	if pH = NULL
		return FALSE
	ok
	nResult = StzEngineRegexMatch(pH, cInput, 1)
	StzEngineRegexFree(pH)
	return nResult = 1

func StzRegexReplace(cInput, cPattern, cReplacement)
	pH = StzEngineRegexNew(cPattern, 0)
	if pH = NULL
		return cInput
	ok
	StzEngineRegexMatch(pH, cInput, 1)
	cResult = StzEngineRegexReplace(pH, cInput, cReplacement)
	StzEngineRegexFree(pH)
	return cResult

  #==================#
 #  STZREGEX CLASS  #
#==================#

class stzRegex from stzObject

	@pRegexHandle = NULL
	@cMatchType = ""
	@cPattern = ""
	@cStr = ""

	@nFlags = 0
	@acMatchOptions = []

	@bRecursiveMatch = FALSE
	@bLastMatchResult = FALSE

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

		if NOT StzFindFirst(@MatchTypes(), pcMatchType) > 0
			StzRaise("Unsupported match type! Should be one of these " + @@(@MatchTypes()) + "!")
		ok

		if NOT StzListQ(@MatchOptions()).ContainsThese(pacOptions)
			StzRaise("Unsupported match options! Should be one or more of these " + @@(@MatchOptions()) + "!")
		ok

		@nFlags = 0
		nLen = len(pacOptions)

		for i = 1 to nLen
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

		if @pRegexHandle != NULL
			StzEngineRegexFree(@pRegexHandle)
		ok

		@pRegexHandle = StzEngineRegexNew(@cPattern, @nFlags)
		@acMatchOptions = pacOptions
		@cStr = pcStr
		@cMatchType = pcMatchType

		nStart = pnStartPosition - 1
		if nStart < 0 nStart = 0 ok

		StzEngineRegexMatch(@pRegexHandle, pcStr, nStart)
		@bLastMatchResult = StzEngineRegexHasMatch(@pRegexHandle)

		return @bLastMatchResult

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

	def HasPartialMatch()
		if @pRegexHandle = NULL return FALSE ok
		nResult = StzEngineRegexPartialMatch(@pRegexHandle, @cStr, 1)
		return nResult = 2

	#-- Softanza scope-based pattern matching methods

	def MatchLinesIn(pcStr)
		return This.MatchXT(pcStr, 1, :MatchEntireContent, [ :MultiLine, :DotMatchesAll ])

		def MatchLine(pcStr)
			return This.MatchLinesIn(pcStr)

	def MatchFirstLineIn(pcStr)
		return This.MatchXT(pcStr, 1, :MatchEntireContent, [ :MultiLine ])

		def MatchFirstLine(pcStr)
			return This.MatchFirstLineIn(pcStr)

	def MatchWordsIn(pcStr)
		cWordPattern = "\b" + This.Pattern() + "\b"
		This.SetPattern(cWordPattern)
		return This.MatchXT(pcStr, 1, :MatchEntireContent, [])

		def MatchWord(pcStr)
			return This.MatchWordsIn(pcStr)

	def MatchFirstWordIn(pcStr)
		cWordPattern = "\b" + This.Pattern() + "\b"
		This.SetPattern(cWordPattern)
		return This.MatchXT(pcStr, 1, :MatchEntireContent, [])

		def MatchFirstWord(pcStr)
			return This.MatchFirstWordIn(pcStr)

	def MatchSegmentsIn(pcStr)
		return This.MatchXT(pcStr, 1, :MatchEntireContent, [ :DotMatchesAll, :MultiLine ])

		def MatchSegment(pcStr)
			return This.MatchSegmentsIn(pcStr)

	def MatchFirstSegmentIn(pcStr)
		return This.MatchXT(pcStr, 1, :MatchEntireContent, [ :DotMatchesAll, :MultiLine ])

		def MatchFirstSegment(pcStr)
			return This.MatchFirstSegmentIn(pcStr)

	def Match(pcStr)

		return This.MatchXT(pcStr, 1, :MatchEntireContent, [ :DotMatchesAll ])

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

	def MatchFirst(pcStr)
		return This.MatchXT(pcStr, 1, :MatchEntireContent, [ :DotMatchesAll ])

	def MatchAt(pcStr, nPos)
		if CheckParams()
			if NOT isString(pcStr)
				StzRaise("Incorrect param type! pcStr must be a string.")
			ok
		if NOT isNumber(nPos)
			StzRaise("Incorrect param type! nPos must be a number.")
		ok
	ok

	return This.MatchXT(pcStr, nPos, :MatchEntireContent, [])

	#-- Getting all the matching values in a given string

	def Matches()

		_acResults_ = []
		_nPos_ = 1

		while This.MatchAt(@cStr, _nPos_)
			_cMatch_ = StzEngineRegexCaptureText(@pRegexHandle, 1)

			if _cMatch_ != ""
				_acResults_ + _cMatch_
				_nEnd_ = StzEngineRegexCaptureEnd(@pRegexHandle, 1)
				_nPos_ = _nEnd_ + 1
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

		aResult = []

		for @i = 1 to This.CaptureCount()
			cVal = StzEngineRegexCaptureText(@pRegexHandle, @i)
			if cVal != ""
				aResult + [ "" + @i, cVal ]
			ok
		next

		return aResult

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

	def IsPartialMatch(pcStr)
		if @pRegexHandle = NULL return FALSE ok
		nResult = StzEngineRegexPartialMatch(@pRegexHandle, pcStr, 1)
		return nResult = 2

		def IsPartial(pcStr)
			return This.IsPartialMatch(pcStr)

		def PartialMatch(pcStr)
			return This.IsPartialMatch(pcStr)

		def MatchPartial(pcStr)
			return This.IsPartialMatch(pcStr)

	def IsCompleteMatch(pcStr)
		return This.MatchXT(pcStr, 1, :MatchEntireContent, [])

		def IsComplete(pcStr)
			return This.IsCompleteMatch(pcStr)

	def MatchAsYouType(pcStr)
		return This.MatchXT(pcStr, 1, :MatchEntireContent, [])

		def ValidateAsTyped(pcStr)
			return This.MatchAsYouType(pcStr)

	def MatchInProgress(pcStr)
		return This.MatchXT(pcStr, 1, :MatchEntireContent, [])

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

		nResult = StzEngineRegexPartialMatch(@pRegexHandle, pcStr, 1)

		if nResult = 1
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

		if nResult = 2
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
		bResult = This.MatchXT(pcStr, 1, :MatchEntireContent, [ :RecursiveMatch ])
		@bRecursiveMatch = bResult
		return bResult

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

		aMatches = []
		nMaxDepth = 0

		cStr = This.String()
		nStart = 1
		This.MatchAt(cStr, nStart)
		acSeen = []

		while This.HasMatch()

			cCapture = StzEngineRegexCaptureText(@pRegexHandle, 1)

			if StzFindFirst(acSeen, cCapture) = 0

				_nS_ = StzEngineRegexCaptureStart(@pRegexHandle, 1)
				_nE_ = StzEngineRegexCaptureEnd(@pRegexHandle, 1)

				aMatches + [
					cCapture,
					[ _nS_, _nE_ ]
				]

				nMaxDepth++
				acSeen + cCapture
			ok

			This.MatchAt(cStr, nStart++)

		end

		return [
			:IsRecursive = TRUE,
			:depth = nMaxDepth,
			:matches = aMatches
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
