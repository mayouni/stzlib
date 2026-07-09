
#~~~~~~~~~~~~~~~~~#
#  STK CORE CHAR  #
#~~~~~~~~~~~~~~~~~#

class stkChar from stzCoreChar

class stzCoreChar from stzCoreObject
	@content
	@nUnicode = 0

	def init(p)
		if isString(p)
			@nUnicode = StkEngineCharUnicode(p)
			@content = p

		but isNumber(p)
			@nUnicode = p
			_cBuf_ = space(4)
			_nLen_ = StkEngineCharToUtf8(p, _cBuf_, 4)
			@content = left(_cBuf_, _nLen_)

		else
			raise( "ERR-" + StkError(:CanNotCreateObject) )
		ok

	def Content()
		if isString(@content) return @content ok
		_cBuf_ = space(4)
		_nLen_ = StkEngineCharToUtf8(@nUnicode, _cBuf_, 4)
		return left(_cBuf_, _nLen_)

		def Char()
			return This.Content()

	def Unicode()
		return @nUnicode

	def IsLetter()
		return StkEngineCharIsLetter(@nUnicode) = 1

	def IsDigit()
		return StkEngineCharIsDigit(@nUnicode) = 1

	def IsUpper()
		_cChar_ = This.Content()
		if len(_cChar_) = 1
			return upper(_cChar_) = _cChar_ and lower(_cChar_) != _cChar_
		ok
		return FALSE

	def IsLower()
		_cChar_ = This.Content()
		if len(_cChar_) = 1
			return lower(_cChar_) = _cChar_ and upper(_cChar_) != _cChar_
		ok
		return FALSE
