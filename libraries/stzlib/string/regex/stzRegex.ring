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

	@nLastMatchPosition = 0

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

def MatchXT(pcStr, paOptions)
	if CheckParams()
		if NOT isString(pcStr)
			StzRaise("Incorrect param type! pcStr must be a string.")
		ok
	ok

	# Reset pattern options before applying new ones
	@nPatternOptions = 0

	nMatchType = 1      	# Default to NormalMatch
	nStartPosition = 0  	# Default start position

	# Apply options from array
	for cOption in paOptions
		if isNumber(cOption)
			# Validate position
			if cOption < 1 or cOption > len(pcStr)
				return FALSE
			ok
			nStartPosition = cOption - 1

		else
			switch cOption
			case "CaseInsensitive"
				@nPatternOptions |= 1
			case "DotMatchesAll"
				@nPatternOptions |= 2
			case "MultiLine"
				@nPatternOptions |= 4
			case "ExtendedSyntax"
				@nPatternOptions |= 8
			case "NonGreedy"
				@nPatternOptions |= 16
			case "DontCapture"
				@nPatternOptions |= 32
			case "UseUnicode"
				@nPatternOptions |= 64
			case "DisableOptimizations"
				@nPatternOptions |= 128

			off
		ok
	next

	@oQRegex.setPatternOptions(@nPatternOptions)
	@cStr = pcStr

	@oQMatchObject = @oQRegex.match(pcStr, 0, 0, 0)

	return @oQMatchObject.hasMatch()


	#-- Match Information Methods

def HasMatch()
	if @oQMatchObject = NULL
		return FALSE
	ok

	return @oQMatchObject.hasMatch()

	#-- Softanza scope-based pattern matching methods

	def MatchLinesIn(pcStr)
		return This.MatchXT(pcStr, ["MultiLine", "DotMatchesAll"])

		def MatchLine(pcStr)
			return This.MatchLinesIn(pcStr)

	def MatchFirstLineIn(pcStr)
		return This.MatchXT(pcStr, ["MultiLine", "NonGreedy"])

		def MatchFirstLine(pcStr)
			return This.MatchFirstLineIn(pcStr)

	def MatchWordsIn(pcStr)
		cWordPattern = "\b" + This.Pattern() + "\b"
		This.SetPattern(cWordPattern)
		return This.MatchXT(pcStr, [])

		def MatchWord(pcStr)
			return This.MatchWordsIn(pcStr)

	def MatchFirstWordIn(pcStr)
		cWordPattern = "\b" + This.Pattern() + "\b"
		This.SetPattern(cWordPattern)
		return This.MatchXT(pcStr, ["NonGreedy"])

		def MatchFirstWord(pcStr)
			return This.MatchFirstWordIn(pcStr)

	def MatchSegmentsIn(pcStr)
		return This.MatchXT(pcStr, ["DotMatchesAll", "MultiLine"])

		def MatchSegment(pcStr)
			return This.MatchSegmentsIn(pcStr)

	def MatchFirstSegmentIn(pcStr)
		return This.MatchXT(pcStr, ["DotMatchesAll", "MultiLine", "NonGreedy"])

		def MatchFirstSegment(pcStr)
			return This.MatchFirstSegmentIn(pcStr)

	def Match(pcStr)
		return This.MatchXT(pcStr, ["DotMatchesAll"])

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
		return This.MatchXT(pcStr, ["DotMatchesAll", "NonGreedy"])

	def MatchAt(pcStr, nPos)
		if CheckParams()
			if NOT isString(pcStr)
				StzRaise("Incorrect param type! pcStr must be a string.")
			ok
		if NOT isNumber(nPos)
			StzRaise("Incorrect param type! nPos must be a number.")
		ok
	ok

	@cStr = pcStr
	@nLastMatchPosition = nPos - 1
	return This.MatchXT(pcStr, [nPos])

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
