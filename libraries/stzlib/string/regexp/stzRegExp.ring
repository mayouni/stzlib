func StzRegExpQ(pcPattern)
	return new stzRegExp(pcPattern)
    
class stzRegExp
	
	@oQRegExp
	@cPattern
	@cTempStr
	@nPatternOptions = 0

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

	#-- Pattern options management
	
	def CaseSensitive()
		@nPatternOptions &= ~1  # Clear CaseInsensitiveOption bit
		@oQRegExp.setPatternOptions(@nPatternOptions)


	def CaseInsensitive()
		@nPatternOptions |= 1   # Set CaseInsensitiveOption bit
		@oQRegExp.setPatternOptions(@nPatternOptions)


	def DotMatchesEverything()
		@nPatternOptions |= 2   # Set DotMatchesEverythingOption bit
		@oQRegExp.setPatternOptions(@nPatternOptions)


		def DotMatchesNewLine()
			This.DotMatchesEverything()

	def MultiLine()
		@nPatternOptions |= 4   # Set MultilineOption bit
		@oQRegExp.setPatternOptions(@nPatternOptions)

	def ExtendedSyntax()
		@nPatternOptions |= 8   # Set ExtendedPatternSyntaxOption bit
		@oQRegExp.setPatternOptions(@nPatternOptions)

		def EnableExtendedSyntax()
			This.ExtendedSyntax()

	def InvertedGreedy()
		@nPatternOptions |= 16  # Set InvertedGreedinessOption bit
		@oQRegExp.setPatternOptions(@nPatternOptions)
		
		def LazyByDefault()
			This.InvertedGreedy()

		def LazyMatching()
			This.InvertedGreedy()

		def Lazy()
			This.InvertedGreedy()

	def DontCapture()
		@nPatternOptions |= 32  # Set DontCaptureOption bit
		@oQRegExp.setPatternOptions(@nPatternOptions)

	def UseUnicode()
		@nPatternOptions |= 64  # Set UseUnicodePropertiesOption bit
		@oQRegExp.setPatternOptions(@nPatternOptions)

	def DisableOptimizations()
		@nPatternOptions |= 128 # Disable optimizations
		@oQRegExp.setPatternOptions(@nPatternOptions)

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

	def HasOptimizationsDisabled()
		return (@nPatternOptions & 128) != 0

	#-- Pattern options reset methods

	def ResetOptions()
		@nPatternOptions = 0
		@oQRegExp.setPatternOptions(@nPatternOptions)
		return This

	#-- Matching methods

	def Match(pcStr)
		if CheckParams()
			if NOT isString(pcStr)
				StzRaise("Incorrect param type! pcStr must be a string.")
			ok
		ok

		@cTempStr = pcStr
		return QRegExpObject().match(pcStr, 0, 0, 0).hasMatch()

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
	
		def Captured()
			return This.CapturedValues()

	def CaptureNames()
		return QStringListToList(@oQRegExp.namedCaptureGroups())

	def CapturedGroups()
		oMatch = @oQRegExp.match(@cTempStr, 0, 0, 0)
		
		_acCaptureNames_ = This.CaptureNames()
		_nLen_ = len(_acCaptureNames_)

		aResult = []

		for @i = 1 to _nLen_

			cName = _acCaptureNames_[@i]

			if cName != ""
				aResult + [cName, oMatch.captured(@i-1)]
			ok
		next

		return aResult

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

	def GetOptions()
		return @nPatternOptions

/*---------------

class stzRegExp
	
	@oQRegExp
	@cPattern

	@cTempStr

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
		@cPattern = pcPattern

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

	def Match(pcStr)
		if CheckParams()
			if NOT isString(pcStr)
				StzRaise("Incorrect param type! pcStr must be a string.")
			ok
		ok

		_bResult_ = QRegExpObject().match(pcStr, 0, 0, 0).hasmatch()
		@cTempStr = pcStr

		return _bResult_

	def CapturedValues()
		_acResult_ = []
		
		@i = 0
		while true
			@i++
			_cCapture_ = @oQRegExp.match(@cTempStr, 0, 0, 0).captured(@i)
			if _cCapture_ = ""
				exit
			ok

			_acResult_ + _cCapture_
		end

		return _acResult_

		def Capture()
			return This.CapturedValues()

		def Captured()
			return This.CapturedValues()
