func StzRegExpQ(pcPattern)
	return new stzRegExp(pcPattern)
    
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
