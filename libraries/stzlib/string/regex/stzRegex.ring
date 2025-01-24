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

func StzRegexQ(pcPattern)
	return new stzRegex(pcPattern)

	func rx(pcPattern)
		return StzRegexQ(pcPattern)

class stzRegex
	
	@oQRegex
	@oQMatchObject

	@cPattern
	@cStr

	@nQPatternOptions = 0

	  #----------------------------#
	 #  INIT AND PATTERN SEETING  #
	#----------------------------#

	def init(pcPattern)
		if CheckParams()
			if NOT isString(pcPattern)
				StzRaise("Incorrect param type! pcPattern must be a string.")
			ok
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
	
		# Reset pattern options before applying new ones

		nQStartPosition = 0
		nQMatchType = 1
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

			case "CaseInsensitive"
				@nQPatternOptions |= 1

			case "DotMatchesAll"
				@nQPatternOptions |= 2

			case "MultiLine"
				@nQPatternOptions |= 4

			case "ExtendedSyntax"
				@nQPatternOptions |= 8

			case "NonGreedy"
				@nQPatternOptions |= 16

			case "DontCapture"
				@nQPatternOptions |= 32

			case "UseUnicode"
				@nQPatternOptions |= 64

			case "DisableOptimizations"
				@nQPatternOptions |= 128

			case "RecursiveMatch"
				@nQPatternOptions |= 256

			off

		next
	
		@oQRegex.setPatternOptions(@nQPatternOptions)
		@cStr = pcStr
	
		@oQMatchObject = @oQRegex.match(pcStr, nQStartPosition, nQMatchType, 0)

    		if nMatchResultType = 1
        		return @oQMatchObject.hasMatch() or @oQMatchObject.hasPartialMatch()
   		ok

		return @oQMatchObject.hasMatch()
	
	#-- Match Information Methods

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
		return This.MatchXT(pcStr, 1, :MatchEntireContent, [ "MultiLine", "DotMatchesAll" ])

		def MatchLine(pcStr)
			return This.MatchLinesIn(pcStr)

	def MatchFirstLineIn(pcStr)
		return This.MatchXT(pcStr, 1, :MatchEntireContent, ["MultiLine", "NonGreedy"])

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
		return This.MatchXT(pcStr, 1, :MatchEntireContent, [ "NonGreedy" ])

		def MatchFirstWord(pcStr)
			return This.MatchFirstWordIn(pcStr)

	def MatchSegmentsIn(pcStr)
		return This.MatchXT(pcStr, 1, :MatchEntireContent, [ "DotMatchesAll", "MultiLine" ])

		def MatchSegment(pcStr)
			return This.MatchSegmentsIn(pcStr)

	def MatchFirstSegmentIn(pcStr)
		return This.MatchXT(pcStr, 1, :MatchEntireContent, [ "DotMatchesAll", "MultiLine", "NonGreedy" ])

		def MatchFirstSegment(pcStr)
			return This.MatchFirstSegmentIn(pcStr)

	def Match(pcStr)
		return This.MatchXT(pcStr, 1, :MatchEntireContent, [ "DotMatchesAll" ])

		def MatchString(pcStr)
			return This.Match(pcStr)

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
		return This.MatchXT(pcStr, 1, :MatchEntireContent, [ "DotMatchesAll", "NonGreedy" ])

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

	#-- Capture-related methods

	def HasGroups()
		return This.CaptureCount() > 0

	def HasNames()
		return len(This.CaptureNames()) > 0

	def Capture()

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

		def CaptureValues()
			return This.Capture()

		def CapturedValues()
			return This.Capture()

		def Values()
			return This.Capture()

		#--

		def CaptureSubStrings()
			return This.Capture()

		def CaptureMatchingSubStrings()
			return This.Capture()

		#>

	def CaptureXT()
		if NOT This.HasGroups()
			StzRaise("No capture groups found in pattern. Use groups like (xyz) to capture values.")
		ok
		return This.CapturedGroups()

		def ValuesXT()
			return This.CaptureXT()

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

		if NOT This.HasGroups()
			StzRaise("No capture groups found in pattern. Use groups like (xyz) to capture values.")
		ok

		_anResult_ = []

		_oQMatch_ = This.QMatchObject()
		
		# Only add non-empty captures and skip full match

		for @i = 1 to This.CaptureCount()
			_cCapture_ = _oQMatch_.captured(@i)
			if _cCapture_ != ""
				_anResult_ + _oQMatch_.capturedStart(@i)-1
			ok
		next

		return _anResult_

		#< @FunctionAlternativeForms

		def FindCaptureValues()
			return This.FindCapture()

		def FindCapturedValues()
			return This.FindCapture()

		def FindValues()
			return This.FindCapture()

		#--

		def FindCaptureSubStrings()
			return This.FindCapture()

		def FindCaptureMatchingSubStrings()
			return This.FindCapture()

		#>

	def CaptureZ()

		if NOT This.HasGroups()
			StzRaise("No capture groups found in pattern. Use groups like (xyz) to capture values.")
		ok

		_aResult_ = []

		_oQMatch_ = This.QMatchObject()
		
		# Only add non-empty captures and skip full match

		for @i = 1 to This.CaptureCount()
			_cCapture_ = _oQMatch_.captured(@i)
			if _cCapture_ != ""
				_aResult_ + [ _cCapture_, _oQMatch_.capturedStart(@i)-1 ]
			ok
		next

		return _aResult_

		#< @FunctionAlternativeForms

		def CaptureValuesZ()
			return This.CaptureZ()

		def CapturedValuesZ()
			return This.CaptureZ()

		def ValuesZ()
			return This.CaptureZ()

		#--

		def CaptureSubStringsZ()
			return This.CaptureZ()

		def CaptureMatchingSubStringsZ()
			return This.CaptureZ()

		#>

	def FindCaptureZZ()

		if NOT This.HasGroups()
			StzRaise("No capture groups found in pattern. Use groups like (xyz) to capture values.")
		ok

		_aResult_ = []

		_oQMatch_ = This.QMatchObject()
		
		# Only add non-empty captures and skip full match

		for @i = 1 to This.CaptureCount()
			_cCapture_ = _oQMatch_.captured(@i)
			if _cCapture_ != ""
				_aResult_ + [ _oQMatch_.capturedStart(0)-1, _oQMatch_.capturedend(0)-1 ]
			ok
		next

		return _aResult_

		#< @FunctionAlternativeForms

		def FindCaptureValuesZZ()
			return This.FindCaptureZZ()

		def FindCapturedValuesZZ()
			return This.FindCaptureZZ()

		def FindValuesZZ()
			return This.FindCaptureZZ()

		#--

		def FindCaptureSubStringsZZ()
			return This.FindCaptureZZ()

		def FindCaptureMatchingSubStringsZZ()
			return This.FindCaptureZZ()

		#>

	def CaptureZZ()

		if NOT This.HasGroups()
			StzRaise("No capture groups found in pattern. Use groups like (xyz) to capture values.")
		ok

		_aResult_ = []

		_oQMatch_ = This.QMatchObject()
		
		# Only add non-empty captures and skip full match

		for @i = 1 to This.CaptureCount()

			_cCapture_ = _oQMatch_.captured(@i)

			if _cCapture_ != ""
				_aSection_ = [ _oQMatch_.capturedStart(@i)-1, _oQMatch_.capturedEnd(@i)-1 ]
				_aResult_ + [ _cCapture_, _aSections_ ]
			ok
		next

		return _aResult_

		#< @FunctionAlternativeForms

		def CaptureValuesZZ()
			return This.CaptureZZ()

		def CapturedValuesZZ()
			return This.CaptureZZ()

		def ValuesZZ()
			return This.CaptureZZ()

		#--

		def CaptureSubStringsZZ()
			return This.CaptureZZ()

		def CaptureMatchingSubStringsZZ()
			return This.CaptureZZ()

		#>

	#-- Pattern information and validation

	def CaptureCount()
		return This.QRegexObject().captureCount()

	def IsValid()
		return This.QRegexObject().isValid()

	def LastError()
		return This.QRegexObject().errorString()

	def PatternErrorOffset()
		return This.QRegexObject().patternErrorOffset()

	#-- Explanation methods

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

	#-- Partial Mutch

	def IsPartialMatch(pcStr)

		# Returns TRUE if the string partially matches the pattern, meaning it could
		# potentially match if more characters were added.
	
		# Example: pattern "hello\d" partially matches "hello" since adding
		# a digit would complete it.

		return This.MatchXT(pcStr, 1, :MatchEntireContentIfNotGoPartial, [])

		def IsPartial(pcStr)
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

	def PartialMatch(pcStr)
		return This.PartialMatchInfo(pcStr)[2]

	def PartialMatchStart()

		if @oQMatchObject != NULL
			return @oQMatchObject.capturedStart()
		ok

		return 0

		def FindPartialMatch()
			return This.PartialMatchStart()

		def FindPartialMatchZ()
			return This.PartialMatchStart()

	def FindPartialMatchZZ()
		anResult = [ This.FindPartialMatch(), PartialMatchLenght() ]
		return anResult

	def PartialMatchLength()

		if @oQMatchObject != NULL
			return @oQMatchObject.capturedLength()
		ok

		return 0

		def PartialMatchSize()
			return This.PartialMatchLenght()

		def PartialMatchNumberOfChars()
			return This.PartialMatchLenght()

	def PartialMatchZ()
		aResult = [ This.PartialMacth(), This.FindPartialMatch() ]
		return aResult

	#-- Recursive (Nested) Match

	def MatchRecursive(pcStr)
		return This.MatchXT(pcStr, 1, :MatchEntireContent, [ "RecursiveMatch" ])

		def RecursiveMatch(pcStr)
			return This.MatchRecursive(pcStr)

		#--

		def MatchNested(pcStr)
			return This.MatchRecursive(pcStr)

		def NestedMatch(pcStr)
			return This.MatchRecursive(pcStr)

	def RecursiveMatchInfo(pcStr)
		if NOT This.MatchRecursive(pcStr)
			return [ :matchType = "none", :depth = 0, :matches = [] ]
		ok

		aMatches = []
		nMaxDepth = 0

		nStart = 1
		This.MatchAt(pcStr, nStart)
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

			This.MatchAt(pcStr, nStart++)

		end

		return [
			:matchType = "recursive",
			:depth = nMaxDepth,
			:matches = aMatches
		]

		def NestedMatchInfo(pcStr)
			return This.RecursiveMatchInfo(pcStr)

	def IsRecursivePattern()
		# Test patterns known to represent recursive structures

		acTestStrings = [
			"(a(b(c)))",     # Nested parentheses
			"a(b(c(d)))",    # Deep nesting
			"(recursive)"    # Self-referential structure
		]

		# Try matching each test string

		nLen = len(acTestStrings)

		for i = 1 to nLen
			if This.Match(acTestStrings[i])
				return TRUE
			ok
		next
    
		return FALSE

		def IsNestedPattern()
			return This.IsRecursivePattern()

	def IsRecursiveMatch(pcStr)
		# Requires both pattern recursion potential 
		# AND actual recursive string structure

		if This.IsRecursivePattern() AND 
		   This.RecursiveMatchInfo(pcStr)[:matchType] = "recursive"

			return TRUE
		else
			return FALSE
		ok	

		def IsNestedMatch(pcStr)
			return This.IsRecursiveMatch(pcStr)

	def RecursiveSubStringsZZ(pcStr)
		return This.RecursiveMatchInfo(pcStr)[3][2]

		#< @FunctionAlternativeForms

		def RecursiveValuesZZ(pcStr)
			return This.RecursiveSubStringsZZ(pcStr)

		def NestedSubStringsZZ(pcStr)
			return This.RecursiveSubStringsZZ(pcStr)

		def NestedValuesZZ(pcStr)
			return This.RecursiveSubStringsZZ(pcStr)

		#--

		def RecursiveMatchesZZ(pcStr)
			return This.RecursiveSubStringsZZ(pcStr)

		def NestedMatchesZZ(pcStr)
			return This.RecursiveSubStringsZZ(pcStr)

		#>

	def RecursiveSubStrings(pcStr)
		_aTemp_ = This.RecursiveMatchInfo(pcStr)[3][2]
		_nLen_ = len(_aTemp_)

		_acResult_ = []

		for @i = 1 to _nLen_
			_acResult_ + _aTemp_[@i][1]
		next

		return _acResult_

		#< @FunctionAlternativeForms

		def RecursiveValues(pcStr)
			return This.RecursiveSubStrings(pcStr)

		def NestedSubStrings(pcStr)
			return This.RecursiveSubStrings(pcStr)

		def NestedValues(pcStr)
			return This.RecursiveSubStrings(pcStr)

		#---

		def RecursiveMatches(pcStr)
			return This.RecursiveSubStrings(pcStr)

		def NestedMatches(pcStr)
			return This.RecursiveSubStrings(pcStr)

		#>

	def RecursiveSubStringsZ(pcStr)
		_aTemp_ = This.RecursiveMatchInfo(pcStr)[3][2]
		_nLen_ = len(_aTemp_)

		_acResult_ = []

		for @i = 1 to _nLen_
			_acResult_ + [ _aTemp_[@i][1], _aTemp_[@i][2][1] ]
		next

		return _acResult_

		#< @FunctionAlternativeForms

		def RecursiveValuesZ(pcStr)
			return This.RecursiveSubStringsZ(pcStr)

		def NestedSubStringsZ(pcStr)
			return This.RecursiveSubStringsZ(pcStr)

		def NestedValuesZ(pcStr)
			return This.RecursiveSubStringsZ(pcStr)

		#--

		def RecursiveMatchesZ(pcStr)
			return This.RecursiveSubStringsZ(pcStr)

		def NestedMatchesZ(pcStr)
			return This.RecursiveSubStringsZ(pcStr)

		#>

	def FindRecursiveSubStringsZZ(pcStr)
		_aTemp_ = This.RecursiveMatchInfo(pcStr)[3][2]
		_nLen_ = len(_aTemp_)

		_acResult_ = []

		for @i = 1 to _nLen_
			_acResult_ + _aTemp_[@i][2]
		next

		return _acResult_

		#< @FunctionAlternativeForms

		def FindRecursiveValuesZZ(pcStr)
			return This.FindRecursiveSubStringsZZ(pcStr)

		def FindNestedSubStringsZZ(pcStr)
			return This.FindRecursiveSubStringsZZ(pcStr)

		def FindNestedValuesZZ(pcStr)
			return This.FindRecursiveSubStringsZZ(pcStr)

		#--

		def FindRecursiveMatchesZZ(pcStr)
			return This.FindRecursiveSubStringsZZ(pcStr)

		def FindNestedMatchesZZ(pcStr)
			return This.FindRecursiveSubStringsZZ(pcStr)

		#>

	def FindRecursiveSubStrings(pcStr)
		_aTemp_ = This.RecursiveMatchInfo(pcStr)[3][2]
		_nLen_ = len(_aTemp_)

		_acResult_ = []

		for @i = 1 to _nLen_
			_acResult_ + _aTemp_[@i][2][1]
		next

		return _acResult_

		#< @FunctionAlternativeForms

		def FindRecursiveSubStringsZ(pcStr)
			return This.FindRecursiveSubPatterns(pcStr)

		def FindRecursiveValues(pcStr)
			return This.FindRecursiveSubStrings(pcStr)

		def FindRecursiveValuesZ(pcStr)
			return This.FindRecursiveSubStrings(pcStr)

		#--

		def FindNestedSubPatterns(pcStr)
			return This.FindRecursiveSubPatterns(pcStr)

		def FindNestedSubStringsZ(pcStr)
			return This.FindRecursiveSubPatterns(pcStr)

		def FindNestedValues(pcStr)
			return This.FindRecursiveSubStrings(pcStr)

		def FindNestedValuesZ(pcStr)
			return This.FindRecursiveSubStrings(pcStr)

		#==

		def FindRecursiveMatches(pcStr)
			return This.FindRecursiveSubPatterns(pcStr)

		def FindRecursiveMatchesZ(pcStr)
			return This.FindRecursiveSubPatterns(pcStr)

		def FindNestedMatches(pcStr)
			return This.FindRecursiveSubPatterns(pcStr)

		def FindNestedMatchesZ(pcStr)
			return This.FindRecursiveSubPatterns(pcStr)

		#>

	def RecursiveDepth(pcStr)
		return This.RecursiveMatchInfo(pcStr)[2][2]

		def NestedDepth(pcStr)
			return This.RecursiveMatchInfo(pcStr)[2][2]

	#-- Named Recursive Match

	def IsRecursiveNamedPattern()

		cPattern = This.Pattern()

		# Create a temporary regex object to validate pattern

		oTempRx = new stzRegex(cPattern)

		# Check for named capture groups

		acNames = oTempRx.CaptureNames()

		if len(acNames) = 0
			return FALSE
		ok

		# Verify pattern validity

		if NOT oTempRx.IsValid()
			return FALSE
		ok

		# Check for potential nested structure using pattern analysis

		bHasNestedPotential =
			ring_substr1(cPattern, "(") > 0 and  	# Has opening parenthesis
			ring_substr1(cPattern, ")") > 0 and  	# Has closing parenthesis
			ring_substr1(cPattern, "(?<") > 0  	# Has named capture group

		return bHasNestedPotential

		#< @FunctionAlternativeForms

		def IsNestedNamedPattern()
			return This.IsRecursiveNamedPattern()

		def HasRecursiveNamedGroups()
			return This.IsRecursiveNamedPattern()

		def HasRecursiveNames()
			return This.IsRecursiveNamedPattern()

		def HasNestedNamedGroups()
			return This.IsRecursiveNamedPattern()

		def HasNestedNames()
			return This.IsRecursiveNamedPattern()

		#>

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

	def RecursiveNamedMatchInfo(pcStr)

		# Pattern syntax validation

		if NOT IsRecursiveNamedPattern()
			StzRaise("Can't proceed! Recursive named match requires:" + NL +
			"- At least one named capture group (?<name>...)" + NL +
			"- Potential for nested captures" + NL +
			"- Optional intermediate content between captures")
		ok

		# Enable all possible regex options

		@nQPatternOptions = 0
		@nQPatternOptions |= 256  // RecursiveMatch flag
		This.QRegexObject().setPatternOptions(@nQPatternOptions)

		# First, verify match

		bMatched = This.MatchXT(pcStr, 1, :MatchEntireContent, ["RecursiveMatch"])

		if NOT bMatched
			return [ :type = "none", :depth = 0, :matches = [] ]
		ok

		# Get match object

		oMatch = This.QMatchObject()

		if oMatch = NULL
			return [ :type = "none", :depth = 0, :matches = [] ]
		ok

		# Get named captures

		acNames = This.CaptureNames()

		if len(acNames) = 0
			return [ :type = "none", :depth = 0, :matches = [] ]
		ok

		# Prepare result structures

		aMatches = []

		# Collect named matches

		aNamedCaptures = []
	
		for i = 1 to len(acNames)
	
			cName = acNames[i]
	
			if cName != ""
	
				cValue = oMatch.captured(i)
	
				aNamedCaptures + [
					[ cName, cValue ],
					[ "position", [
						oMatch.capturedStart(i) + 1,
						oMatch.capturedEnd(i)
					] ]
				]
			ok
		next
	
		nLen = len(aNamedCaptures)
	
		for i = 1 to nLen
			aMatches + aNamedCaptures[i]
		next
	
		return [
			:type = "recursive",
			:depth = nLen,
			:matches = aMatches
		]
