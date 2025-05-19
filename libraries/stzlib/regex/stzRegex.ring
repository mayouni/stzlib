# The stzRegex class provides regular expression functionality with both
# classic Qt-style patterns and enhanced scoped macth capabilities.
# It combines direct Qt access with Softanza's scope-based approach.

#---------------------------------------------------------------------

#INFO Some reference articles to read:

# A nice article to get the essentials of Regex
# https://trustedsec.com/blog/regex-cheat-sheet

# An other valuable link from Mozilla MSDN:
# https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Regular_expressions/Cheatsheet

# And of course the reference article on Qt
# https://doc.qt.io/qt-5/qregularexpression.html#details

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
	:MatchEntireContent,			# 0 in Qt
	:MatchEntireContentIfNotGoPartial,	# 1 in Qt
	:MatchFirstOccurrenceIfNotGoPartial,	# 2 in Qt
	:ReturnFalseForAnyMatch			# 3 in Qt
]

_$aMATCH_OPTIONS = [
	:CaseInsensitive,	# 1 in Qt
	:DotMatchesAll,		# 2 in Qt
	:MultiLine,		# 4 in Qt
	:ExtendedSyntax,	# 8 in Qt
	:NonGreedy,		# 16 in Qt
	:DontCapture,		# 32 in Qt
	:UseUnicode,		# 64 in Qt
	:DisableOptimizations,	# 128 in Qt
	:RecursiveMatch,	# 256 in Qt
]

  #=============#
 #  FUNCTIONS  #
#=============#

func StzRegexQ(pcPattern)
	return new stzRegex(pcPattern)

	func rx(pcPattern)
		return StzRegexQ(pcPattern)

func MatchTypes()
	return _$aMATCH_TYPES 

	def @MatchTypes()
		return _$aMATCH_TYPES 

func MatchOptions()
	return _$aMATCH_OPTIONS

	func @MatchOptions()
		return _$aMATCH_OPTIONS

func AllMatches(cInput, cPattern)
	oRegex = new stzRegex(cPattern)
	oRegex.Match(cInput)
	return oRegex.AllMatches()

  #==================#
 #  STZREGEX CLASS  #
#==================#

class stzRegex
	
	@oQRegex = _NULL_
	@oQMatchObject = _NULL_
	@cMatchType = _NULL_
	@cPattern = _NULL_
	@cStr = _NULL_

	@nQPatternOptions = 0
	@acMatchOptions = []

	@bRecursiveMatch = FALSE

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

		@oQRegex = new QRegularExpression()
		@oQRegex.setPattern(pcPattern)

		@oQRegex.setPatternOptions(@nQPatternOptions)

		@cPattern = pcPattern
		@cMatchType = :MatchEntireContent

		# If pattern contains multilines, extend the syntax
		if ring_substr1(pcPattern, NL) > 0
			This.EnableExtendedSyntax()
		ok

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

	def QRegexObject()
		return @oQRegex

	def QMatchObject()
		return @oQMatchObject

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
	 #  CORE Qt MATCH SERVICE  #
	#-------------------------#
	# @MotherFunction of all other matching functions in the class

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

			if NOT ( isList(pacOptions) and IsListOfStrings(pacOptions) )
				StzRaise("Incorrect param type! pacOptions must be a list of strings.")
			ok

		ok
	
		if NOT ring_find(@MatchTypes(), pcMatchType) > 0
			StzRaise("Unsupported match type! Should be one of these " + @@(@MatchTypes()) + "!")
		ok

		if NOT StzListQ(@MatchOptions()).ContainsThese(pacOptions)
			StzRaise("Unsupported match options! Should be one or more of these " + @@(@MatchOptions()) + "!")
		ok

		# Reset pattern options before applying new ones

		nQStartPosition = 0
		nQMatchType = 0
		@nQPatternOptions = 0

		# To store whether we want partial matches

		nMatchResultType = 0

		# Defing the start position

		if pnStartPosition >= 0
			nQStartPosition = pnStartPosition - 1 # Convert 1-based to 0-based
		ok

		# Defining the match type

		switch pcMatchType

		on :MatchEntireContent
			nQMatchType = 0

		on :MatchEntireContentIfNotGoPartial
			nQMatchType = 1
			nMatchResultType = 1

		on :MatchFirstOccurrenceIfNotGoPartial
			nQMatchType = 2
			nMatchResultType = 1

		on :ReturnFalseForAnyMatch
			nQMatchType = 3
		off


		# Defining options

		nLen = len(pacOptions)

		for i = 1 to nLen

			switch pacOptions[i]

			case :CaseInsensitive
				@nQPatternOptions |= 1

			case :DotMatchesAll
				@nQPatternOptions |= 2

			case :MultiLine
				@nQPatternOptions |= 4

			case :ExtendedSyntax
				@nQPatternOptions |= 8

			case :NonGreedy
				@nQPatternOptions |= 16

			case :DontCapture
				@nQPatternOptions |= 32

			case :UseUnicode
				@nQPatternOptions |= 64

			case :DisableOptimizations
				@nQPatternOptions |= 128

			case :RecursiveMatch
				@nQPatternOptions |= 256
				@bRecursiveMatch = TRUE
			off

		next
	
		@oQRegex.setPatternOptions(@nQPatternOptions)
		@acMatchOptions = pacOptions
		@cStr = pcStr
		@cMatchType = pcMatchType
		@oQMatchObject = @oQRegex.match(pcStr, nQStartPosition, nQMatchType, 0)

    		if nMatchResultType = 1
        		return @oQMatchObject.hasMatch() or @oQMatchObject.hasPartialMatch()
   		ok

		return @oQMatchObject.hasMatch()

		#< @FunctionMisspelledForm

		def MacthXT(pcStr, pnStartPosition, pcMatchType, pacOptions)
			return This.MatchXT(pcStr, pnStartPosition, pcMatchType, pacOptions)

		#>

	  #--------------------#
	 #  Matching Methods  #
	#--------------------#

	def HasMatch()
		if @oQMatchObject = NULL
			return FALSE
		ok
	
		return @oQMatchObject.hasMatch()

	def HasPartialMatch() # Look at section Partial Math for further methods

		if @oQMatchObject = NULL
			return FALSE
		ok
	
		return @oQMatchObject.hasPartialMatch()

	#-- Softanza scope-based pattern matching methods

	def MatchLinesIn(pcStr)
		return This.MatchXT(pcStr, 1, :MatchEntireContent, [ :MultiLine, :DotMatchesAll ])

		def MatchLine(pcStr)
			return This.MatchLinesIn(pcStr)

	def MatchFirstLineIn(pcStr)
		return This.MatchXT(pcStr, 1, :MatchEntireContent, [ :MultiLine, :NonGreedy ])

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
		return This.MatchXT(pcStr, 1, :MatchEntireContent, [ :NonGreedy ])

		def MatchFirstWord(pcStr)
			return This.MatchFirstWordIn(pcStr)

	def MatchSegmentsIn(pcStr)
		return This.MatchXT(pcStr, 1, :MatchEntireContent, [ :DotMatchesAll, :MultiLine ])

		def MatchSegment(pcStr)
			return This.MatchSegmentsIn(pcStr)

	def MatchFirstSegmentIn(pcStr)
		return This.MatchXT(pcStr, 1, :MatchEntireContent, [ :DotMatchesAll, :MultiLine, :NonGreedy ])

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

		#TODO // Add this misspelled form to all "Match" functions

		#>

	def MatchMany(pacStr)
		if NOT ( isList(pacStr) and IsListOfStrings(pacStr) )
			StzRaise("Incorrect param type! pacStr must be a list of strings.")
		ok

		_bResult_ = _TRUE_
		_nLen_ = len(pacStr)
		
		for @i = 1 to _nLen_
			if NOT This.Match(pacStr[@i])
				_bResult_ = _FALSE_
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
		return This.MatchXT(pcStr, 1, :MatchEntireContent, [ :DotMatchesAll, :NonGreedy ])

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

		_acResults_ = []  # List to store all matching values
		_nPos_ = 1  # Start searching from position 1
	
		while This.MatchAt(@cStr, _nPos_)  # Search for a match at the current position
			_oQMatch_ = This.QMatchObject()
			_cMatch_ = _oQMatch_.captured(0)  # Get the matched value
			
			if _cMatch_ != ""
				_acResults_ + _cMatch_  # Store the match
				_nPos_ = _oQMatch_.capturedEnd(0) + 1  # Move past the last match
			else
				break  # Stop if no match is found
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

	def FindMatches()
		_anResults_ = []
		_nPos_ = 1
	
		while This.MatchAt(@cStr, _nPos_)  # Search for a match at the current position
			_oQMatch_ = This.QMatchObject()
			
			if _cMatch_ != ""
				_nPos_ = _oQMatch_.capturedEnd(0) + 1  # Move past the last match
				_anResults_ + _nPos_
			else
				break  # Stop if no match is found
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

		_aResults_ = []
		_nPos_ = 1
	
		while This.MatchAt(@cStr, _nPos_)
			_oQMatch_ = This.QMatchObject()
			_cMatch_ = _oQMatch_.captured(0)
			
			if _cMatch_ != ""
				
				_nPos_ = _oQMatch_.capturedEnd(0) + 1
				_aResults_ + [ _cMatch_, _nPos ]
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

			_oQMatch_ = This.QMatchObject()
			_cMatch_ = _oQMatch_.captured(0)
			_nLenMatch_ = StzStringQ(_cMatch_).NumberOfChars()

			if _cMatch_ != ""
				
				_nPos_ = _oQMatch_.capturedEnd(0) + 1
				_aResults_ + [ _nPos, _nPos_ + _nLenMatch_ - 1 ]
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

			_oQMatch_ = This.QMatchObject()
			_cMatch_ = _oQMatch_.captured(0)
			_nLenMatch_ = StzStringQ(_cMatch_).NumberOfChars()

			if _cMatch_ != ""
				
				_nPos_ = _oQMatch_.capturedEnd(0) + 1
				_aResults_ + [ _cMatch_, [ _nPos, _nPos_ + _nLenMatch_ - 1 ] ]
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
		return len(This.CaptureNames()) > 0

	def CaptureGroups()

		if NOT This.HasGroups()
			StzRaise("No capture groups found in pattern. Use groups like (xyz) to capture values.")
		ok

		_acResult_ = []

		_oQMatch_ = This.QMatchObject()
		
		# Only add non-empty captures and skip full match

		for @i = 1 to This.CaptureCount()
			_cCapture_ = _oQMatch_.captured(@i)
			if _cCapture_ != ""
				_acResult_ + _cCapture_
			ok
		next

		return _acResult_

		#< @FunctionAlternativeForms

		def Capture()
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
		_oQRegex_ = This.QRegexObject()
		_acNames_ = QStringListToList(_oQRegex_.namedCaptureGroups())
		_nLen_ = len(_acNames_)

		_acResult_ = []

		for @i = 1 to _nLen_
			if _acNames_[@i] != ""
				_acResult_ + _acNames_[@i]
			ok
		next

		return _acResult_

		def Names()
			return This.CaptureNames()

		def CaptureGroupNames()
			return This.CaptureNames()

	def CapturedGroups()
		if NOT This.HasGroups()
			StzRaise("No capture groups found in pattern. Use groups like (xyz) to capture values.")
		ok

		_oQMatch_ = This.QMatchObject()
		_acCaptureNames_ = This.CaptureNames()
		aResult = []

		for @i = 1 to len(_acCaptureNames_)
			cName = _acCaptureNames_[@i]
			if cName != ""
				aResult + [ cName, _oQMatch_.captured(@i) ]
			ok
		next

		return aResult

		def Groups()
			return This.CapturedGroups()

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

		_oQMatch_ = This.QMatchObject()
		
		# Only add non-empty captures and skip full match

		for @i = 1 to This.CaptureCount()
			_cCapture_ = _oQMatch_.captured(@i)
			if _cCapture_ != ""
				_nPos_ = _oQMatch_.capturedStart(@i)+1

				# Convert Qt postion to Ring position
				#TODO // Use Qt2RingPos() instead

				if _nPos_ >= 0
					_nPos_++
				else
					_nPos_ = 0
				ok

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

		_oQMatch_ = This.QMatchObject()
		
		# Only add non-empty captures and skip full match

		for @i = 1 to This.CaptureCount()

			_cCapture_ = _oQMatch_.captured(@i)

			if _cCapture_ != ""
				_aSection_ = [ _oQMatch_.capturedStart(@i)+1, _oQMatch_.capturedEnd(@i) ]
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
		return This.QRegexObject().captureCount()

	def IsValid()
		return This.QRegexObject().isValid()

	def LastError()
		return This.QRegexObject().errorString()

	def PatternErrorOffset()
		return This.QRegexObject().patternErrorOffset()

	  #-----------------#
	 #  Partial Mutch  #
	#-----------------#

	def IsPartialMatch(pcStr)
		# Returns TRUE if the string partially matches the pattern, meaning it could
		# potentially match if more characters were added.
	
		# Example: pattern "hello\d" partially matches "hello" since adding
		# a digit would complete it.

		return This.MatchXT(pcStr, 1, :MatchEntireContentIfNotGoPartial, [])

		def IsPartial(pcStr)
			return This.IsPartialMatch(pcStr)

		def PartialMatch(pcStr)
			return This.IsPartialMatch(pcStr)

		def MatchPartial(pcStr)
			return This.IsPartialMatch(pcStr)

	def IsCompleteMatch(pcStr) 
		# Returns TRUE only if the string completely matches the pattern
		# with no need for additional characters.

		return This.MatchXT(pcStr, 1, :MatchEntireContent, [])

		def IsComplete(pcStr)
			return This.IsCompleteMatch(pcStr)

	def MatchAsYouType(pcStr)
		# Optimized for real-time validation during user input. Returns TRUE if either:
		# 1. The string completely matches the pattern
		# 2. The string could potentially match if more characters were added
	
		# Perfect for validating form fields as users type.

		return This.MatchXT(pcStr, 1, :MatchEntireContentIfNotGoPartial, [])

		def ValidateAsTyped(pcStr)
			return This.MatchAsYouType(pcStr)

	def MatchInProgress(pcStr)
		# Similar to MatchAsYouType() but optimized for searching/filtering scenarios.
		# Tries to find any occurrence that could potentially match.

		return This.MatchXT(pcStr, 1, :MatchFirstOccurrenceIfNotGoPartial, [])

		def SearchInProgress(pcStr)
			return This.MatchInProgress(pcStr)

	def PartialMatchInfo(pcStr)
		# Returns detailed information about a partial match including:
		# - Whether it's a complete or partial match
		# - The matched portion
		# - What's still needed to complete the match
		# - Position information

		if This.IsCompleteMatch(pcStr)
			return [
				:matchType = "complete",
				:matched   = pcStr,
				:section  = [ 1, StzStringQ(pcStr).NumberOfChars() ]
			]
		ok

		if This.IsPartialMatch(pcStr)
			# For pattern "hello\d{3}" and input "hello12":
			# - We have a partial match
			# - We've matched "hello12"
			# - We still need one more digit to complete \d{3}
        
			return [
				:matchType = "partial",
				:matched   = pcStr, # The actual partially matched string
				:section  = [ 1, StzStringQ(pcStr).NumberOfChars() ] # Position of current match
			]
		ok

		# No match at all

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
		if @oQMatchObject != NULL
			return @oQMatchObject.capturedStart(0)
		ok

		return 0

	def FindPartialMatchZZ(pcStr)
		return This.PartialMAtchInfo(pcStr)[3][2]

	def PartialMatchLength()

		if @oQMatchObject != NULL
			return @oQMatchObject.capturedLength()
		ok

		return 0

		def PartialMatchSize()
			return This.PartialMatchLength()

		def PartialMatchNumberOfChars()
			return This.PartialMatchLength()

	def PartialMatchZ(pcStr)
		aResult = [ This.PartialMacth(pcStr), This.FindPartialMatch(pcStr) ]
		return aResult

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

			oMatch = This.QMatchObject()
			cCapture = oMatch.captured(0)

			if ring_find(acSeen, cCapture) = 0

				aMatches + [
					cCapture,
					[ oMatch.capturedStart(0)+1,
					  oMatch.capturedEnd(0) ]
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

		_bResult_ = _TRUE_
		_nLen_ = len(pacStr)
		
		for @i = 1 to _nLen_
			if NOT This.MatchRecursive(pacStr[@i])
				_bResult_ = _FALSE_
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
