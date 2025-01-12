# The stzRegExp class provides regular expression functionality with both
# classic Qt-style patterns and enhanced scoped matching capabilities

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
		This.SetPattern(pcPattern)

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

	#-- Pattern content methods

	def Content()
		return @cPattern

	def Pattern()
		return @cPattern

	def Copy()
		return new stzRegExp(This.Pattern())

	def QRegExpObject()
		return @oQRegExp

	def IsValid()
		return This.QRegExpObject().isValid()

	#-- Scoped pattern matching methods

	def Match(pcStr)
		if CheckParams()
			if NOT isString(pcStr)
				StzRaise("Incorrect param type! pcStr must be a string.")
			ok
		ok

		@bInScopedMatch = TRUE
		@cTempStr = pcStr
		return QRegExpObject().match(pcStr, 0, 0, 0).hasMatch()

		def MatchString(pcStr)
			This.MatchString(pcStr)

	def MatchOne(pcStr)
		if CheckParams()
			if NOT isString(pcStr)
				StzRaise("Incorrect param type! pcStr must be a string.")
			ok
		ok

		This.DotMatchesEverything()
		This.Lazy()
		@cTempStr = pcStr
		return QRegExpObject().match(pcStr, 0, 0, 0).hasMatch()

	def MatchLine(pcStr)
		if CheckParams()
			if NOT isString(pcStr)
				StzRaise("Incorrect param type! pcStr must be a string.")
			ok
		ok

		This.MultiLine()
		@cTempStr = pcStr
		return QRegExpObject().match(pcStr, 0, 0, 0).hasMatch()

	def MatchOneLine(pcStr)
		if CheckParams()
			if NOT isString(pcStr)
				StzRaise("Incorrect param type! pcStr must be a string.")
			ok
		ok

		This.MultiLine()
		This.Lazy()
		@cTempStr = pcStr
		return QRegExpObject().match(pcStr, 0, 0, 0).hasMatch()

	def MatchWord(pcStr)
		if CheckParams()
			if NOT isString(pcStr)
				StzRaise("Incorrect param type! pcStr must be a string.")
			ok
		ok

		if NOT (This.Pattern()[1] = "\b")
			This.SetPattern("\b" + This.Pattern() + "\b")
		ok

		@cTempStr = pcStr
		return QRegExpObject().match(pcStr, 0, 0, 0).hasMatch()

	def MatchOneWord(pcStr)
		if CheckParams()
			if NOT isString(pcStr)
				StzRaise("Incorrect param type! pcStr must be a string.")
			ok
		ok

		if NOT (This.Pattern()[1] = "\b")
			This.SetPattern("\b" + This.Pattern() + "\b")
		ok

		This.Lazy()
		@cTempStr = pcStr
		return QRegExpObject().match(pcStr, 0, 0, 0).hasMatch()

	def MatchSegment(pcStr)
		if CheckParams()
			if NOT isString(pcStr)
				StzRaise("Incorrect param type! pcStr must be a string.")
			ok
		ok

		This.DotMatchesEverything()
		@cTempStr = pcStr
		return QRegExpObject().match(pcStr, 0, 0, 0).hasMatch()

	def MatchOneSegment(pcStr)
		if CheckParams()
			if NOT isString(pcStr)
				StzRaise("Incorrect param type! pcStr must be a string.")
			ok
		ok

		This.DotMatchesEverything()
		This.Lazy()
		@cTempStr = pcStr
		return QRegExpObject().match(pcStr, 0, 0, 0).hasMatch()

	#-- Pattern options management
	
	def CaseSensitive()
		@nPatternOptions &= ~1  # Clear CaseInsensitiveOption bit
		@oQRegExp.setPatternOptions(@nPatternOptions)
		return This

	def CaseInsensitive()
		@nPatternOptions |= 1   # Set CaseInsensitiveOption bit
		@oQRegExp.setPatternOptions(@nPatternOptions)
		return This

	def DotMatchesEverything()
		@nPatternOptions |= 2   # Set DotMatchesEverythingOption bit
		@oQRegExp.setPatternOptions(@nPatternOptions)
		return This

		def DotMatchesNewLine()
			return This.DotMatchesEverything()

	def MultiLine()
		@nPatternOptions |= 4   # Set MultilineOption bit
		@oQRegExp.setPatternOptions(@nPatternOptions)
		return This

	def ExtendedSyntax()
		@nPatternOptions |= 8   # Set ExtendedPatternSyntaxOption bit
		@oQRegExp.setPatternOptions(@nPatternOptions)
		return This

		def EnableExtendedSyntax()
			return This.ExtendedSyntax()

	def InvertedGreedy()
		@nPatternOptions |= 16  # Set InvertedGreedinessOption bit
		@oQRegExp.setPatternOptions(@nPatternOptions)
		return This
		
		def LazyByDefault()
			return This.InvertedGreedy()

		def LazyMatching()
			return This.InvertedGreedy()

		def Lazy()
			return This.InvertedGreedy()

	def DontCapture()
		@nPatternOptions |= 32  # Set DontCaptureOption bit
		@oQRegExp.setPatternOptions(@nPatternOptions)
		return This

		def DisableCapture()
			return This.DontCapture()

		def DisableCapturing()
			return This.DontCapture()

	def UseUnicode()
		@nPatternOptions |= 64  # Set UseUnicodePropertiesOption bit
		@oQRegExp.setPatternOptions(@nPatternOptions)
		return This

		def EnableUnicode()
			return This.UseUnicode()

	def DisableOptimizations()
		@nPatternOptions |= 128 # Disable optimizations
		@oQRegExp.setPatternOptions(@nPatternOptions)
		return This

		def DontOptimize()
			return This.DisableOptimizations()

		def DontOptimise()
			return This.DisableOptimizations()

		def DisableOptimization()
			return This.DisableOptimizations()

		def DisableOptimisations()
			return This.DisableOptimizations()

		def DisableOptimisation()
			return This.DisableOptimizations()

	#-- Pattern options query methods

	def IsCaseSensitive()
		return (@nPatternOptions & 1) = 0

	def IsCaseInsensitive()
		return (@nPatternOptions & 1) != 0

	def DotMatchesAll()
		return (@nPatternOptions & 2) != 0

	def IsMultiLine()
		return (@nPatternOptions & 4) != 0

	def HasExtendedSyntax()
		return (@nPatternOptions & 8) != 0

	def IsInvertedGreedy()
		return (@nPatternOptions & 16) != 0

		def IsLazyMatching()
			return This.IsInvertedGreedy()

		def IsLazy()
			return This.IsInvertedGreedy()

	def IsNonCapturing()
		return (@nPatternOptions & 32) != 0

	def UsesUnicode()
		return (@nPatternOptions & 64) != 0

		def IsUnicode()
			return This.UsesUnicode()

	def HasOptimizationsDisabled()
		return (@nPatternOptions & 128) != 0

		def IsOptimised()
			return This.HasOptimizationsDisabled()

		def IsOptimzed()
			return This.HasOptimizationsDisabled()

		def UsesOptimisation()
			return This.HasOptimizationsDisabled()

		def UsesOptimisations()
			return This.HasOptimizationsDisabled()

		def UsesOptimization()
			return This.HasOptimizationsDisabled()

		def UsesOptimizations()
			return This.HasOptimizationsDisabled()

	#-- Pattern options reset methods

	def ResetOptions()
		@nPatternOptions = 0
		@oQRegExp.setPatternOptions(@nPatternOptions)
		return This

	#-- Legacy matching methods

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

	#-- Capture methods

	def CapturedValues()
		_acResult_ = []
		
		@i = 0
		while true
			_cCapture_ = @oQRegExp.match(@cTempStr, 0, 0, 0).captured(@i)
			if _cCapture_ = ""
				exit
			ok

			_acResult_ + _cCapture_
			@i++
		end

		return _acResult_

		def Capture()
			return This.CapturedValues()

		def CaptureValues()
			return This.CapturedValues()

		def Captured()
			return This.CapturedValues()

		def Values()
			return This.CapturedValues()

	def CaptureNames()
		return QStringListToList(@oQRegExp.namedCaptureGroups())

		def GroupsNames()
			return This.CaptureNames()

		def CapturedGroupsNames()
			return This.CaptureNames()

		def CapturedNames()
			return This.CaptureNames()

		def Names()
			return This.CapturedValues()

	def CapturedGroups()
		oMatch = @oQRegExp.match(@cTempStr, 0, 0, 0)
		
		_acCaptureNames_ = This.CaptureNames()
		_nLen_ = len(_acCaptureNames_)

		aResult = []

		for @i = 1 to _nLen_
			cName = _acCaptureNames_[@i]
			if cName != ""
				aResult + [ cName, oMatch.captured(@i-1) ]
			ok
		next

		return aResult

		def CaptureGroups()
			return This.CapturedGroups()

		def Groups()
			return This.CapturedGroups()

	#-- Error handling and information

	def LastError()
		return @oQRegExp.errorString()

	def PatternErrorOffset()
		return @oQRegExp.patternErrorOffset()

	def IsPatternValid()
		return This.IsValid()

	#-- Pattern information

	def CaptureCount()
		return @oQRegExp.captureCount()

		def NumberOfCaptures()
			return This.CaptureCount()

		def NumberOfValues()
			return This.CaptureCount()

		def NumberOfCatuturedValues()
			return This.CaptureCount()

		def CountCaptures()
			return This.CaptureCount()

		def CountValues()
			return This.CaptureCount()

		def CountCatuturedValues()
			return This.CaptureCount()

		def HowManyCaptures()
			return This.CaptureCount()

		def HowManyValues()
			return This.CaptureCount()

		def HowManyCatuturedValues()
			return This.CaptureCount()

	def GetOptions()
		return @nPatternOptions
