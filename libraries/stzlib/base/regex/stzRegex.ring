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

# Escapes the regex metacharacters in pcStr, so the result is a pattern that
# matches pcStr and nothing else. Engine-backed, one pass, no per-char list.
#
#   StzRegexEscape("+")     --> "\+"
#   StzRegexEscape(".edu")  --> "\.edu"
#
# What every "starts with / ends with / contains this TEXT" builder needs, so
# that a dot means a dot rather than any character.

func StzRegexEscape(pcStr)
	if NOT isString(pcStr)
		StzRaise("Incorrect param type! pcStr must be a string.")
	ok

	return StzEngineRegexEscape(pcStr)

	func StzEscapeForRegex(pcStr)
		return StzRegexEscape(pcStr)

func StzRegexMatch(cInput, cPattern)
	_pH_ = StzEngineRegexNew(cPattern, 0)
	if _pH_ = ""
		return 0
	ok
	_nResult_ = StzEngineRegexMatch(_pH_, cInput, 1)
	StzEngineRegexFree(_pH_)
	return _nResult_ = 1

func StzRegexReplace(cInput, cPattern, cReplacement)
	_pH_ = StzEngineRegexNew(cPattern, 0)
	if _pH_ = ""
		return cInput
	ok
	StzEngineRegexMatch(_pH_, cInput, 1)
	_cResult_ = StzEngineRegexReplace(_pH_, cInput, cReplacement)
	StzEngineRegexFree(_pH_)
	return _cResult_

  #==================#
 #  STZREGEX CLASS  #
#==================#

# Holds a regular expression compiled by the PCRE2 engine and answers whether, where and how a text matches it, including partial and recursive matches.
#
# Build it with a pattern, then call a match method with a text: the text and the outcome of the
# last call are kept in the object, and the readers (Matches, FindMatches, CaptureGroups,
# NamedGroups, CaptureByName, the partial and recursive readers) work on that last call. Match asks
# whether the pattern covers the whole text; MatchFirst and MatchAt search inside it. MatchAsYouType
# and the partial family serve form validation while a person is still typing, and MatchRecursive
# handles nested brackets through (?R). A pattern that does not compile does not raise: IsValid
# answers FALSE and every match call answers FALSE. Known gaps today, each carried as a warning on
# its method: FindMatches and FindCapture skip a character after each match, PartialMatchLength is
# one too small, RecursiveDepth counts matches rather than nesting, LastError and PatternErrorOffset
# are stubs, Explain raises for a pattern the library does not know by name, and MatchWordsIn stacks
# word boundaries on the pattern each time it is called.
#
#   receiver   o1 = new stzRegex("\d+")
#   example    o1.MatchFirst("a1b22c333")
#              ? @@( o1.Matches() )
#              #--> [ "1", "22", "333" ]
#   see        stzMatrex, stzTablex, stzString
class stzRegex from stzObject

	@pRegexHandle = ""
	@cMatchType = ""
	@cPattern = ""
	@cStr = ""

	@nFlags = 0
	@nCompiledFlags = -1
	@acMatchOptions = []

	@bRecursiveMatch = 0
	@bLastMatchResult = 0

	# 0 = no match, 1 = complete match, 2 = partial match.
	@nLastMatchKind = 0

	  #----------------------------#
	 #  INIT AND PATTERN SEETING  #
	#----------------------------#

	# Builds a regex object from a pattern and compiles it; an empty or non-text pattern raises an error, one that fails to compile does not.
	#
	#   returns    nothing; the object is built
	#   note       an invalid pattern builds anyway: IsValid answers FALSE and every match call
	#              answers FALSE
	#   see        SetPattern, IsValid
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

	# Replaces the pattern and compiles it again; the match type goes back to the entire-content default.
	#
	#   returns    nothing; the object changes
	#   note       a pattern holding a line break turns on the multi-line flag
	#   warning    an empty pattern is accepted and one that fails to compile is accepted silently
	#              (IsValid answers FALSE); the stored text and match kind of the last match are
	#              kept
	#   see        Pattern, IsValid, init
	def SetPattern(pcPattern)
		if CheckParams()
			if NOT isString(pcPattern)
				StzRaise("Incorrect param type! pcPattern must be a string.")
			ok
		ok

		if @pRegexHandle != ""
			StzEngineRegexFree(@pRegexHandle)
		ok

		@cPattern = pcPattern
		@cMatchType = :MatchEntireContent

		if ring_substr1(pcPattern, char(10)) > 0
			@nFlags = @nFlags | 4
		ok

		@pRegexHandle = StzEngineRegexNew(pcPattern, @nFlags)
		@nCompiledFlags = @nFlags

	  #-------------------#
	 #  GENERAL METHODS  #
	#-------------------#

	# Returns the text given to the last match call, or an empty text before any call.
	#
	#   returns    text
	#   see        Pattern, Match, MatchFirst
	def String()
		return @cStr

	# Returns the pattern text this object was built with or last given, as written.
	#
	#   returns    text
	#   see        SetPattern, String
	def Pattern()
		return @cPattern

		def Content()
			return This.Pattern()

	# Returns a new regex object with the same pattern; the last text, match type and options are not carried over.
	#
	#   returns    a stzRegex
	#   see        Pattern
	def Copy()
		return new stzRegex(This.Pattern())

	# Returns the match type used by the last match call, as lowercase text; "matchentirecontent" before any call.
	#
	#   returns    text such as "matchfirstoccurrenceifnotgopartial"
	#   see        MatchOptions, MatchTypeXT, MatchXT
	def MatchType()
		return @cMatchType

	# Returns the options used by the last match call, as a list of lowercase texts; [ ] when there were none.
	#
	#   returns    a list of text
	#   see        MatchType, MatchXT
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
				@bRecursiveMatch = 1
			off

		next

		# Recompile ONLY when the flags actually changed. The compiled code
		# depends on the pattern and the flags, and the pattern is fixed for
		# the life of the object (SetPattern rebuilds it). This used to free
		# and rebuild the pattern on EVERY call.
		if @pRegexHandle = "" or @nFlags != @nCompiledFlags
			if @pRegexHandle != ""
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
			@bLastMatchResult = 1
		else
			@bLastMatchResult = 0
		ok

		return @nLastMatchKind

		#< @FunctionMisspelledForm

		def MacthXT(pcStr, pnStartPosition, pcMatchType, pacOptions)
			return This.MatchXT(pcStr, pnStartPosition, pcMatchType, pacOptions)

		#>

	  #--------------------#
	 #  Matching Methods  #
	#--------------------#

	# TRUE if the last match call found a complete match; it is FALSE after a partial match and after SetPattern.
	#
	#   returns    TRUE or FALSE (1 or 0)
	#   see        LastMatchKind, HasPartialMatch
	def HasMatch()
		if @pRegexHandle = ""
			return 0
		ok

		return StzEngineRegexHasMatch(@pRegexHandle)

	# Reads the recorded outcome of the LAST match, exactly as HasMatch()
	# does. It used to re-run a fresh unanchored partial probe instead, so
	# the two siblings could describe different matches.
	def HasPartialMatch()
		return @nLastMatchKind = 2

	# Returns the kind of the last match call as a number: 0 for none, 1 for a complete match, 2 for a partial one.
	#
	#   returns    0, 1 or 2
	#   note       stays at its last value when SetPattern is called afterwards
	#   see        HasMatch, HasPartialMatch
	#@ aka  The kind of the last match: 0 none, 1 complete, 2 partial.
	def LastMatchKind()
		return @nLastMatchKind

	# Searches the text for the pattern, with ^ and $ binding at each line and . crossing line breaks; TRUE if it occurs.
	#
	#   returns    TRUE or FALSE (1 or 0)
	#   note       it runs the same search as the segment forms; a partial match counts as FALSE
	#   see        MatchFirstLineIn, MatchSegmentsIn, MatchFirst
	#@ aka  -- Softanza scope-based pattern matching methods
	def MatchLinesIn(pcStr)
		_nKind_ = This.MatchXT(pcStr, 1, :MatchFirstOccurrenceIfNotGoPartial, [ :MultiLine, :DotMatchesAll ])
		return _nKind_ = 1

		def MatchLine(pcStr)
			return This.MatchLinesIn(pcStr)

	# Searches the text for the pattern, with ^ and $ binding at each line and . stopping at line breaks; TRUE if it occurs.
	#
	#   returns    TRUE or FALSE (1 or 0)
	#   see        MatchLinesIn, MatchFirst
	def MatchFirstLineIn(pcStr)
		_nKind_ = This.MatchXT(pcStr, 1, :MatchFirstOccurrenceIfNotGoPartial, [ :MultiLine ])
		return _nKind_ = 1

		def MatchFirstLine(pcStr)
			return This.MatchFirstLineIn(pcStr)

	# Searches the text for the pattern as a whole word, by wrapping the pattern in word boundaries; TRUE if it occurs.
	#
	#   returns    TRUE or FALSE (1 or 0)
	#   note       call SetPattern again to get the original back
	#   warning    the pattern is replaced for good by its word-bounded form, and each further call
	#              adds another pair of boundaries: "pre" becomes \bpre\b, then \b\bpre\b\b
	#   see        MatchFirstWordIn, MatchFirst
	def MatchWordsIn(pcStr)
		_cWordPattern_ = "\b" + This.Pattern() + "\b"
		This.SetPattern(_cWordPattern_)
		_nKind_ = This.MatchXT(pcStr, 1, :MatchFirstOccurrenceIfNotGoPartial, [])
		return _nKind_ = 1

		def MatchWord(pcStr)
			return This.MatchWordsIn(pcStr)

	# Searches the text for the pattern as a whole word, by wrapping the pattern in word boundaries; TRUE if it occurs.
	#
	#   returns    TRUE or FALSE (1 or 0)
	#   note       call SetPattern again to get the original back
	#   warning    the pattern is replaced for good by its word-bounded form, and each further call
	#              adds another pair of boundaries
	#   see        MatchWordsIn, MatchFirst
	def MatchFirstWordIn(pcStr)
		_cWordPattern_ = "\b" + This.Pattern() + "\b"
		This.SetPattern(_cWordPattern_)
		_nKind_ = This.MatchXT(pcStr, 1, :MatchFirstOccurrenceIfNotGoPartial, [])
		return _nKind_ = 1

		def MatchFirstWord(pcStr)
			return This.MatchFirstWordIn(pcStr)

	# Searches the text for the pattern, with . crossing line breaks and ^ and $ binding at each line; TRUE if it occurs.
	#
	#   returns    TRUE or FALSE (1 or 0)
	#   see        MatchFirstSegmentIn, MatchLinesIn, MatchFirst
	def MatchSegmentsIn(pcStr)
		_nKind_ = This.MatchXT(pcStr, 1, :MatchFirstOccurrenceIfNotGoPartial, [ :DotMatchesAll, :MultiLine ])
		return _nKind_ = 1

		def MatchSegment(pcStr)
			return This.MatchSegmentsIn(pcStr)

	# Searches the text for the pattern, with . crossing line breaks and ^ and $ binding at each line; TRUE if it occurs.
	#
	#   returns    TRUE or FALSE (1 or 0)
	#   see        MatchSegmentsIn, MatchLinesIn, MatchFirst
	def MatchFirstSegmentIn(pcStr)
		_nKind_ = This.MatchXT(pcStr, 1, :MatchFirstOccurrenceIfNotGoPartial, [ :DotMatchesAll, :MultiLine ])
		return _nKind_ = 1

		def MatchFirstSegment(pcStr)
			return This.MatchFirstSegmentIn(pcStr)

	# TRUE if the pattern matches the whole text from the first character to the last; a text that merely contains a match gives FALSE.
	#
	#   returns    TRUE or FALSE (1 or 0)
	#   note       . crosses line breaks; to search inside the text use MatchFirst; MatchString and
	#              IsMatched are the same call
	#   see        MatchFirst, IsCompleteMatch, Matches
	#@ aka  Match() ANCHORS: it asks whether the pattern matches the string ENTIRELY, not whether it occurs somewhere inside it. rx("[0-9]+") does not match "abc123" -- "abc123" is not a run of digits. Use MatchFirst() for "does this occur anywhere", Matches() for every occurrence.
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

	# TRUE if the pattern occurs anywhere in the text, found by an unanchored search.
	#
	#   returns    TRUE or FALSE (1 or 0)
	#   note       the match is kept, so Matches, FindMatches and the capture readers then work on
	#              this text
	#   see        Match, MatchAt, Matches
	#@ aka  The SEARCH counterpart of Match(): is there a first occurrence of the pattern anywhere in the string? rx("[0-9]+").MatchFirst("abc123") is TRUE where .Match("abc123") is FALSE.
	def MatchFirst(pcStr)
		_nKind_ = This.MatchXT(pcStr, 1, :MatchFirstOccurrenceIfNotGoPartial, [ :DotMatchesAll ])
		return _nKind_ = 1

		#< @FunctionAlternativeForms

		def MatchAnywhere(pcStr)
			return This.MatchFirst(pcStr)

		def Occurs(pcStr)
			return This.MatchFirst(pcStr)

	# Searches the text for the pattern from a given position onward and keeps the match; TRUE if one is found.
	#
	#   nPos       the position to start from, 1 is the first character
	#   returns    TRUE or FALSE (1 or 0)
	#   note       this is a search from the position, not a test that the match starts exactly
	#              there
	#   see        MatchFirst, Match
		#>
	#@ aka  Searches for the next occurrence FROM nPos (1-based), which is what Matches() needs to walk a string. Not "must match starting exactly at nPos" -- that is MatchXT(s, nPos, :MatchEntireContent, ...).
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

	# Returns every non-overlapping match of the pattern in the last text given to a match call, as a list of text.
	#
	#   returns    a list of text; [ ] when nothing matches or no text was given yet
	#   note       it searches the stored text again, so call a match method first to give it a
	#              text; a match of zero length stops the walk
	#   see        MatchFirst, NumberOfMatches, FindMatches
	#@ aka  -- Getting all the matching values in a given string
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

	# Returns how many matches the pattern has in the last text given to a match call.
	#
	#   returns    a number; 0 when there is none
	#   see        Matches, FindMatches
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

	# Returns the length, in characters, of the last match found.
	#
	#   returns    a number; 0 when there is no match
	#   see        Matches, FindMatches
	def NumberOfChars()
		if @pRegexHandle = "" return 0 ok
		_nStart_ = StzEngineRegexCaptureStart(@pRegexHandle, 1)
		_nEnd_ = StzEngineRegexCaptureEnd(@pRegexHandle, 1)
		if _nStart_ < 0 or _nEnd_ < 0 return 0 ok
		return _nEnd_ - _nStart_

		def CapturedLength()
			return This.NumberOfChars()

	# Returns the start position of each match of the pattern in the last text given to a match call.
	#
	#   returns    a list of numbers; [ ] when there is none
	#   note       positions start at 1
	#   warning    known defect: it continues from one character past the end of each match, so a
	#              match that starts right after the previous one is skipped: \d on 1234 answers [
	#              1, 3 ] while Matches finds four
	#   see        Matches, MatchFirst
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

	# Z = each match WITH its position, the position as a number. ZZ() below is
	# the same thing with the position as a section [start, end].
	#
	# This used to print @@(FindMatches()) and return nothing, which made the four
	# aliases below -- every one of them named ...AndTheirPositions -- answer NULL
	# while dumping to the console. Nothing carried a position at all.
	def MatchesZ()

		_aResults_ = []
		_nPos_ = 1

		while This.MatchAt(@cStr, _nPos_)
			_cMatch_ = StzEngineRegexCaptureText(@pRegexHandle, 1)

			if _cMatch_ != ""
				_nStart_ = StzEngineRegexCaptureStart(@pRegexHandle, 1)
				_nEnd_ = StzEngineRegexCaptureEnd(@pRegexHandle, 1)
				_nPos_ = _nEnd_ + 1
				_aResults_ + [ _cMatch_, _nStart_ ]
			else
				break
			ok
		end

		return _aResults_


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

	# TRUE if the last match call left captures; the whole match counts as capture 0, so it is TRUE after any successful match.
	#
	#   returns    TRUE or FALSE (1 or 0)
	#   note       CaptureGroups raises an error when this is FALSE
	#   warning    known defect: a pattern without any parentheses also answers TRUE after a match,
	#              and a pattern with groups answers FALSE until a match succeeded
	#   see        CaptureCount, CaptureGroups
	def HasGroups()
		return This.CaptureCount() > 0

	# TRUE if the pattern holds named groups, written (?<name>...) or (?P<name>...); no match is needed to tell.
	#
	#   returns    TRUE or FALSE (1 or 0)
	#   see        CaptureNames, NamedGroups
	def HasNames()
		if @pRegexHandle = "" return 0 ok
		return StzEngineRegexNamedGroupCount(@pRegexHandle) > 0

	# Returns the texts captured by the last match: the whole match first, then each group in order, leaving out empty groups.
	#
	#   returns    a list of text
	#   note       an optional group that matched nothing is dropped, so the position of a text in
	#              the list is not its group number
	#   warning    raises an error when no match has been made yet or the last match failed
	#   see        CapturedGroups, CaptureCount, NamedGroups
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

	# TRUE if the pattern matches somewhere in the last text given to a match call.
	#
	#   returns    TRUE or FALSE (1 or 0)
	#   note       it searches the stored text again
	#   see        Matches, HasMatch
		#>
	def HasValues()
		return len(This.MatchedValues()) > 0

		def HasMatches()
			return This.HasValues()

		def HasMatchedValues()
			return This.HasValues()

	# Returns the names of the named groups, in the order they appear in the pattern; [ ] when the pattern has none.
	#
	#   returns    a list of text
	#   note       no match is needed; both (?<name>...) and (?P<name>...) are read
	#   see        NamedGroups, HasNames, CaptureByName
	def CaptureNames()
		if @pRegexHandle = "" return [] ok

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

	# Returns the captures of the last match as [ number, text ] pairs, where 1 is the whole match, leaving out empty groups.
	#
	#   returns    a list of pairs; the number is given as text
	#   warning    raises an error when no match has been made yet or the last match failed
	#   see        CaptureGroups, CaptureCount
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

	# Returns the text that a named group captured in the last match; an empty text for an unknown name or a group that captured nothing.
	#
	#   pcName     the name of the group, matched with the same case as in the pattern
	#   returns    text
	#   see        NamedGroups, CaptureNames
	def CaptureByName(pcName)
		if @pRegexHandle = "" return "" ok
		return StzEngineRegexCaptureByName(@pRegexHandle, pcName)

		def NamedCapture(pcName)
			return This.CaptureByName(pcName)

		def GroupByName(pcName)
			return This.CaptureByName(pcName)

	# Returns [ name, text ] pairs for the named groups, in pattern order; the text is empty until a match has been made.
	#
	#   returns    a list of pairs; [ ] when the pattern has no named group
	#   see        CaptureNames, CaptureByName
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

	# Returns the start position of each match of the pattern in the last text given to a match call.
	#
	#   returns    a list of numbers; [ ] when there is none
	#   note       it reports where the whole matches start, not where each group starts
	#   warning    known defect: it walks the matches like FindMatches, so a match that starts right
	#              after the previous one is skipped
	#   see        FindMatches, CaptureGroups
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

 	# Returns the number of captures of the last match, the whole match included: 1 for a pattern without groups, 3 for two groups.
 	#
 	#   returns    a number; 0 before any match or after a failed one
 	#   see        HasGroups, CaptureGroups
 	def CaptureCount()
		if @pRegexHandle = "" return 0 ok
		return StzEngineRegexCaptureCount(@pRegexHandle)

	# TRUE if the pattern compiled; a pattern with an unbalanced parenthesis answers FALSE.
	#
	#   returns    TRUE or FALSE (1 or 0)
	#   see        LastError, SetPattern
	def IsValid()
		return @pRegexHandle != ""

		def IsValidPattern()
			return THis.IsValid()

	# Returns an empty text today instead of the compile error of the pattern.
	#
	#   returns    an empty text, always
	#   note       test IsValid to learn that a pattern is bad
	#   warning    known defect: the body is a stub that returns "", so an invalid pattern gives no
	#              message
	#   see        IsValid, PatternErrorOffset
	def LastError()
		return ""

	# Returns -1 today instead of the position of the compile error in the pattern.
	#
	#   returns    -1, always
	#   warning    known defect: the body is a stub that returns -1, even for a pattern that does
	#              not compile
	#   see        IsValid, LastError
	def PatternErrorOffset()
		return -1

	  #-----------------#
	 #  Partial Match   #
	#-----------------#

	# TRUE if the text is the beginning of something the pattern would match entirely, but is not all of it yet.
	#
	#   returns    TRUE or FALSE (1 or 0)
	#   note       a text that already matches entirely gives FALSE; the pattern should be anchored
	#              for a strict prefix test
	#   see        IsCompleteMatch, MatchAsYouType, PartialMatchInfo
	#@ aka  TRUE only when pcStr is a strict PREFIX of something that would match entirely -- on the way there, not there yet.
	def IsPartialMatch(pcStr)
		if @pRegexHandle = "" return 0 ok
		_nKind_ = This.MatchXT(pcStr, 1, :MatchEntireContentIfNotGoPartial, [])
		return _nKind_ = 2

		def IsPartial(pcStr)
			return This.IsPartialMatch(pcStr)

		def PartialMatch(pcStr)
			return This.IsPartialMatch(pcStr)

		def MatchPartial(pcStr)
			return This.IsPartialMatch(pcStr)

	# TRUE if the pattern matches the whole text; a prefix of a possible match gives FALSE.
	#
	#   returns    TRUE or FALSE (1 or 0)
	#   note       unlike Match, . does not cross line breaks here
	#   see        IsPartialMatch, Match
	def IsCompleteMatch(pcStr)
		_nKind_ = This.MatchXT(pcStr, 1, :MatchEntireContent, [])
		return _nKind_ = 1

		def IsComplete(pcStr)
			return This.IsCompleteMatch(pcStr)

	# TRUE if the text already matches entirely, or could still match once more characters are typed.
	#
	#   returns    TRUE or FALSE (1 or 0)
	#   note       an empty text is FALSE
	#   see        IsPartialMatch, IsCompleteMatch, MatchInProgress
	#@ aka  Accepts what is already valid AND what could still become valid -- which is what form validation needs while the user is still typing. Against "^\d{3}-\d{2}-\d{4}$": "123" TRUE (partial), "123-45-6789" TRUE (complete), "abc" FALSE (cannot get there from here).
	def MatchAsYouType(pcStr)
		_nKind_ = This.MatchXT(pcStr, 1, :MatchEntireContentIfNotGoPartial, [])
		return _nKind_ > 0

		def ValidateAsTyped(pcStr)
			return This.MatchAsYouType(pcStr)

	# TRUE if the pattern occurs in the text, or could still occur once more text arrives; the search form of the as-you-type test.
	#
	#   returns    TRUE or FALSE (1 or 0)
	#   see        MatchAsYouType, MatchFirst
	#@ aka  The search counterpart: is a match either present, or still possible if more text arrives? Used for progressive/incremental search.
	def MatchInProgress(pcStr)
		_nKind_ = This.MatchXT(pcStr, 1, :MatchFirstOccurrenceIfNotGoPartial, [])
		return _nKind_ > 0

		def SearchInProgress(pcStr)
			return This.MatchInProgress(pcStr)

	# Returns the kind of match the text gives (complete, partial or none), the text matched and its section.
	#
	#   returns    a hash list [ :matchType, :matched, :section ]; section is [ start, end ] with
	#              both ends inclusive, [ ] for none
	#   note       the keys come back in lowercase
	#   see        IsPartialMatch, PartialMatchStart, PartialMatchLength
	def PartialMatchInfo(pcStr)

		if @pRegexHandle = ""
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

	# Returns the position where a partial or complete match starts in the text; raises an error when there is no match at all.
	#
	#   returns    a number
	#   note       PartialMatchStart answers 0 for no match, without raising
	#   warning    known defect: for a text that does not match it reads the first element of an
	#              empty section and raises error R2
	#   see        PartialMatchStart, PartialMatchInfo
	def FindPartialMatch(pcStr)
		return This.PartialMAtchInfo(pcStr)[3][2][1]

		def FindPartialMatchZ(pcStr)
			return This.FindPartialMatch(pcStr)


	# Returns the position where a partial or complete match starts in the text.
	#
	#   returns    a number; 0 when there is no match
	#   see        FindPartialMatch, PartialMatchLength
	def PartialMatchStart(pcStr)
		_aInfo_ = This.PartialMatchInfo(pcStr)
		if _aInfo_[1][2] = "none" return 0 ok
		return _aInfo_[3][2][1]

	def FindPartialMatchZZ(pcStr)
		return This.PartialMatchInfo(pcStr)[3][2]

	# Returns the length of the partial or complete match today minus one: the partial match 123- gives 3.
	#
	#   returns    a number, one below the true length; 0 when there is no match
	#   note       the true length is the second section value minus the first, plus 1
	#   warning    known defect: it subtracts an inclusive start from an inclusive end without
	#              adding one, so 12 matched by \d{3} gives 1 and a complete 123 gives 2
	#   see        PartialMatchStart, PartialMatchInfo
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
			return [ 1, _aInfo_[3][2][1] ]
		ok
		return [ 0, 0 ]

	  #----------------------------#
	 #  Recursive (Nested) Match  #
	#----------------------------#

	# TRUE if the whole text matches a recursive pattern, such as one using (?R) for nested brackets; the verdict is kept for the readers.
	#
	#   returns    TRUE or FALSE (1 or 0)
	#   see        IsRecursiveMatch, RecursiveSubStrings, MatchManyRecursive
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

	# TRUE if the last call of the recursive match succeeded; a later call of another match method does not reset it.
	#
	#   returns    TRUE or FALSE (1 or 0)
	#   see        MatchRecursive, RecursiveMatchInfo
	def IsRecursiveMatch()
		return @bRecursiveMatch

		def IsNestedMatch()
			return This.IsRecursiveMatch()

	# Returns the nested matches found in the text of the last recursive match, with their count and sections.
	#
	#   returns    a hash list [ :IsRecursive, :depth, :matches ], where matches are [ text, [
	#              start, end ] ] with end one past the match; IsRecursive 0, depth 0 and [ ] unless
	#              the last recursive match succeeded
	#   note       the keys come back in lowercase; depth is the number of distinct nested matches,
	#              which is not the nesting depth
	#   see        RecursiveSubStrings, RecursiveDepth
	def RecursiveMatchInfo()
		if NOT This.IsRecursiveMatch()
			return [ :IsRecursive = 0, :depth = 0, :matches = [] ]
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
			:IsRecursive = 1,
			:depth = _nMaxDepth_,
			:matches = _aMatches_
		]

		def NestedMatchInfo(pcStr)
			return This.RecursiveMatchInfo(pcStr)

	# TRUE if every text of the list matches the recursive pattern, stopping at the first one that does not.
	#
	#   pacStr     the list of texts to test, each a text
	#   returns    TRUE or FALSE (1 or 0)
	#   warning    raises an error for a non-list, an empty list or a list holding a non-text
	#   see        MatchRecursive, MatchManyRecursiveXT
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

	# Returns the distinct nested matches of the last recursive match, outermost first, as a list of text.
	#
	#   returns    a list of text; [ ] unless the last recursive match succeeded
	#   note       for ((a)(b)) it answers the whole text, then (a), then (b)
	#   see        RecursiveMatchInfo, FindRecursiveSubStrings, RecursiveDepth
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

	# Returns the start positions of the nested matches of the last recursive match, outermost first.
	#
	#   returns    a list of numbers; [ ] unless the last recursive match succeeded
	#   see        RecursiveSubStrings, RecursiveMatchInfo
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

	# Returns the number of distinct nested matches found by the last recursive match, which is the nesting depth only for a single chain.
	#
	#   returns    a number; 0 unless the last recursive match succeeded
	#   note       the answer is right only when each bracket holds at most one other
	#   warning    known defect: it counts matches, so ((x)(y)(z)) answers 4 although the nesting is
	#              2 deep, while (((x))) answers 3
	#   see        RecursiveMatchInfo, NestedDepth
		#>
	def RecursiveDepth()
		return This.RecursiveMatchInfo()[2][2]

		# Returns the number of distinct nested matches found by the last recursive match; the same count as the recursive depth.
		#
		#   returns    a number; 0 unless the last recursive match succeeded
		#   warning    known defect: it counts matches, so ((x)(y)(z)) answers 4 although the
		#              nesting is 2 deep
		#   see        RecursiveDepth
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

	# Returns a one-line explanation of the pattern when the library knows it by name; any other pattern raises an error.
	#
	#   returns    text
	#   note       patterns of the named catalogue, such as ^([^\d]*)(\d+)$, are explained
	#   warning    known defect: for a pattern outside the library's named list it builds
	#              stzRegexAnalyzer, a class that does not exist, and raises error R11
	#   see        ExplainXT, Pattern
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
