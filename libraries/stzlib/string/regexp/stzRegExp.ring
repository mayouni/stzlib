# The stzRegExp class provides regular expression functionality with both
# classic Qt-style patterns and enhanced scoped matching capabilities.
# It combines direct Qt access with Softanza's scope-based approach.

#---------------------------------------------------------------------

#INFO Some reference articles to read:

# A nice article to get the essentials of regExp
# https://trustedsec.com/blog/regex-cheat-sheet

# An other valuable link from Mozilla MSDN:
# https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Regular_expressions/Cheatsheet

# An of course the reference article on Qt
# https://doc.qt.io/qt-5/qregularexpression.html#details

func StzRegExpQ(pcPattern)
	return new stzRegExp(pcPattern)

	func rx(pcPattern)
		return StzRegExpQ(pcPattern)

class stzRegExp
	
	@oQRegExp
	@cPattern
	@cTempStr
	@nPatternOptions = 0
	@bInScopedMatch = FALSE

	def init(pcPattern)
		if pcPattern != NULL
			This.SetPattern(pcPattern)
		ok

	def SetPattern(pcPattern)
		if CheckParams()
			if NOT isString(pcPattern)
				StzRaise("Incorrect param type! pcPattern must be a string.")
			ok
		ok

		@oQRegExp = new QRegularExpression()
		@oQRegExp.setPattern(pcPattern)
		@oQRegExp.setPatternOptions(@nPatternOptions)
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
		return new stzRegExp(This.Pattern())

	def QRegExpObject()
		return @oQRegExp

	#-- Core Qt integration with simplified options

	def MatchXT(pcStr, paOptions)
		if CheckParams()
			if NOT isString(pcStr)
				StzRaise("Incorrect param type! pcStr must be a string.")
			ok
		ok

		# Reset pattern options before applying new ones
		@nPatternOptions = 0

		# Apply options from array
		for cOption in paOptions
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
		next

		@oQRegExp.setPatternOptions(@nPatternOptions)
		@cTempStr = pcStr
		return @oQRegExp.match(pcStr, 0, 0, 0).hasMatch()

	#-- Softanza scope-based pattern matching methods

	def MatchLinesIn(pcStr)
		return This.MatchXT(pcStr, ["MultiLine", "DotMatchesAll"])

		def MatchLine(pcStr)
			return This.MatchLinesIn(pcStr)

	def MatchOneLineIn(pcStr)
		return This.MatchXT(pcStr, ["MultiLine", "NonGreedy"])

		def MatchOneLine(pcStr)
			return This.MatchOneLineIn(pcStr)

	def MatchWordsIn(pcStr)
		cWordPattern = "\b" + This.Pattern() + "\b"
		This.SetPattern(cWordPattern)
		return This.MatchXT(pcStr, [])

		def MatchWord(pcStr)
			return This.MatchWordsIn(pcStr)

	def MatchOneWordIn(pcStr)
		cWordPattern = "\b" + This.Pattern() + "\b"
		This.SetPattern(cWordPattern)
		return This.MatchXT(pcStr, ["NonGreedy"])

		def MatchOneWord(pcStr)
			return This.MatchOneWordIn(pcStr)

	def MatchSegmentsIn(pcStr)
		return This.MatchXT(pcStr, ["DotMatchesAll", "MultiLine"])

		def MatchSegment(pcStr)
			return This.MatchSegmentsIn(pcStr)

	def MatchOneSegmentIn(pcStr)
		return This.MatchXT(pcStr, ["DotMatchesAll", "MultiLine", "NonGreedy"])

		def MatchOneSegment(pcStr)
			return This.MatchOneSegmentIn(pcStr)

	def Match(pcStr)
		return This.MatchXT(pcStr, ["DotMatchesAll"])

		def MatchString(pcStr)
			return This.Match(pcStr)

	def MatchOne(pcStr)
		return This.MatchXT(pcStr, ["DotMatchesAll", "NonGreedy"])

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
		oMatch = @oQRegExp.match(@cTempStr, 0, 0, 0)
		
		# Only add non-empty captures and skip full match
		for @i = 1 to This.CaptureCount()
			_cCapture_ = oMatch.captured(@i)
			if _cCapture_ != ""
				_acResult_ + _cCapture_
			ok
		next

		return _acResult_

	def CaptureNames()

		_acNames_ = QStringListToList(@oQRegExp.namedCaptureGroups())
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

		oMatch = @oQRegExp.match(@cTempStr, 0, 0, 0)
		_acCaptureNames_ = This.CaptureNames()
		aResult = []

		for @i = 1 to len(_acCaptureNames_)
			cName = _acCaptureNames_[@i]
			if cName != ""
				aResult + [ cName, oMatch.captured(@i) ]
			ok
		next

		return aResult

		def Groups()
			return This.CapturedGroups()

	#-- Pattern information and validation

	def CaptureCount()
		return @oQRegExp.captureCount()

	def IsValid()
		return This.QRegExpObject().isValid()

	def LastError()
		return @oQRegExp.errorString()

	def PatternErrorOffset()
		return @oQRegExp.patternErrorOffset()

	#-- Legacy matching methods (maintained for compatibility)

	def MatchAt(pcStr, nPos)
		if CheckParams()
			if NOT isString(pcStr)
				StzRaise("Incorrect param type! pcStr must be a string.")
			ok
			if NOT isNumber(nPos)
				StzRaise("Incorrect param type! nPos must be a number.")
			ok
		ok

		@cTempStr = pcStr
		return QRegExpObject().match(pcStr, nPos, 0, 0).hasMatch()

		def MatchAtPosition(pcStr, nPos)
			return This.MatchAt(pcStr, nPos)

	#-- Getting a textual explanation of the pattern

	def Explain()

		_cResult_ = ""

		# First we try to find an exisiting explanation (in RegExpExplanations())

		_cName_ = RegExpPatternName(This.Pattern())
		if _cName_ != ""
			_cResult_ = RegExpPatternExplanation(_cName_)[1]
		ok

		# Otherwise we feed the pattern to stzRegAnalyzer

		if _cResult_ = ""
			_oRxAnal_ = new stzRegExpAnalyzer(This.Pattern())
			_cResult_ = _oRxAnal_.Explain()
		ok

		# Returning the explanation (if any)

		if _cResult_ = ""
			StzResult("Can't explain the pattern.")
		ok

		return _cResult_

	def ExplainXT()

		_cResult_ = ""

		# First we try to find an exisiting explanation (in RegExpExplanations())

		_cName_ = RegExpPatternName(This.Pattern())
		if _cName_ != ""
			_cResult_ = RegExpPatternExplanation(_cName_)[2]

		ok

		# Otherwise we feed the pattern to stzRegAnalyzer

		if _cResult_ = ""
			_oRxAnal_ = new stzRegExpAnalyzer(This.Pattern())
			_cResult_ = _oRxAnal_.ExplainXT()
		ok

		# Returning the explanation (if any)

		if _cResult_ = ""
			StzResult("Can't explain the pattern.")
		ok

		return _cResult_
