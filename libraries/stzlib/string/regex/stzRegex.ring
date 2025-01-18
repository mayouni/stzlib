# The stzRegex class provides regular expression functionality with both
# classic Qt-style patterns and enhanced scoped matching capabilities.
# It combines direct Qt access with Softanza's scope-based approach.

#---------------------------------------------------------------------

#INFO Some reference articles to read:

# A nice article to get the essentials of Regex
# https://trustedsec.com/blog/regex-cheat-sheet

# An other valuable link from Mozilla MSDN:
# https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Regular_expressions/Cheatsheet

# An of course the reference article on Qt
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
	@nPatternOptions = 0
	@bInScopedMatch = FALSE

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
		@oQRegex.setPatternOptions(@nPatternOptions)
		@cPattern = pcPattern

		# If pattern contains multilines, extend the syntax
		if ring_substr1(pcPattern, NL) > 0
			This.EnableExtendedSyntax()
		ok

	#-- Pattern content methods

	def Content()
		return @cPattern

	def Pattern()
		return @cPattern

	def Copy()
		return new stzRegex(This.Pattern())

	def QRegexObject()
		return @oQRegex

	def QMatchObject()
		return @oQMatchObject

	#-- Core Qt integration with enhanced options

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
	
		# Defing the start position

		if pnStartPosition >= 0
			nQStartPosition = pnStartPosition - 1 # Convert 1-based to 0-based
		ok

		# Defining the match type

		switch pcMatchType

		on :NormalMatch
			nQMatchType = 1

		on :PartialPreferCompleteMatch
			nQMatchType = 2

		on :PartialPreferFirstMatch
			nQMatchType = 3

		on :NoMatch
			nQMatchType = 4
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

			off

		next
	
		@oQRegex.setPatternOptions(@nQPatternOptions)
		@cStr = pcStr
	
		@oQMatchObject = @oQRegex.match(pcStr, nQStartPosition, nQMatchType, 0)
	
		return @oQMatchObject.hasMatch()
	
	#-- Match Information Methods

	def HasMatch()
		if @oQMatchObject = NULL
			return FALSE
		ok
	
		return @oQMatchObject.hasMatch()

	#-- Softanza scope-based pattern matching methods

	def MatchLinesIn(pcStr)
		return This.MatchXT(pcStr, 1, :NormalMatch, [ "MultiLine", "DotMatchesAll" ])

		def MatchLine(pcStr)
			return This.MatchLinesIn(pcStr)

	def MatchFirstLineIn(pcStr)
		return This.MatchXT(pcStr, 1, :NormalMatch, ["MultiLine", "NonGreedy"])

		def MatchFirstLine(pcStr)
			return This.MatchFirstLineIn(pcStr)

	def MatchWordsIn(pcStr)
		cWordPattern = "\b" + This.Pattern() + "\b"
		This.SetPattern(cWordPattern)
		return This.MatchXT(pcStr, 1, :NormalMatch, [])

		def MatchWord(pcStr)
			return This.MatchWordsIn(pcStr)

	def MatchFirstWordIn(pcStr)
		cWordPattern = "\b" + This.Pattern() + "\b"
		This.SetPattern(cWordPattern)
		return This.MatchXT(pcStr, 1, :NormalMatch, [ "NonGreedy" ])

		def MatchFirstWord(pcStr)
			return This.MatchFirstWordIn(pcStr)

	def MatchSegmentsIn(pcStr)
		return This.MatchXT(pcStr, 1, :NormalMatch, [ "DotMatchesAll", "MultiLine" ])

		def MatchSegment(pcStr)
			return This.MatchSegmentsIn(pcStr)

	def MatchFirstSegmentIn(pcStr)
		return This.MatchXT(pcStr, 1, :NormalMatch, [ "DotMatchesAll", "MultiLine", "NonGreedy" ])

		def MatchFirstSegment(pcStr)
			return This.MatchFirstSegmentIn(pcStr)

	def Match(pcStr)
		return This.MatchXT(pcStr, 1, :NormalMatch, [ "DotMatchesAll" ])

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
		return This.MatchXT(pcStr, 1, :NormalMatch, [ "DotMatchesAll", "NonGreedy" ])

	def MatchAt(pcStr, nPos)
		if CheckParams()
			if NOT isString(pcStr)
				StzRaise("Incorrect param type! pcStr must be a string.")
			ok
		if NOT isNumber(nPos)
			StzRaise("Incorrect param type! nPos must be a number.")
		ok
	ok

	return This.MatchXT(pcStr, nPos, :NormalMatch, [])

	#-- Capture-related methods

	def HasGroups()
		return This.CaptureCount() > 0

	def HasNames()
		return len(This.CaptureNames()) > 0

	def Capture()
		if NOT This.HasGroups()
			StzRaise("No capture groups found in pattern. Use groups like (xyz) to capture values.")
		ok
		return This.CapturedValues()

		def CaptureValues()
			return This.Capture()

		def Values()
			return This.Capture()

	def CaptureXT()
		if NOT This.HasGroups()
			StzRaise("No capture groups found in pattern. Use groups like (xyz) to capture values.")
		ok
		return This.CapturedGroups()

		def ValuesXT()
			return This.CaptureXT()

	def CapturedValues()
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
