
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
			cBuf = space(4)
			nLen = StkEngineCharToUtf8(p, cBuf, 4)
			@content = left(cBuf, nLen)

		else
			raise( "ERR-" + StkError(:CanNotCreateObject) )
		ok

	def Content()
		if isString(@content) return @content ok
		cBuf = space(4)
		nLen = StkEngineCharToUtf8(@nUnicode, cBuf, 4)
		return left(cBuf, nLen)

		def Char()
			return This.Content()

	def Unicode()
		return @nUnicode

	def IsLetter()
		return StkEngineCharIsLetter(@nUnicode) = 1

	def IsDigit()
		return StkEngineCharIsDigit(@nUnicode) = 1

	def IsUpper()
		cChar = This.Content()
		if len(cChar) = 1
			return upper(cChar) = cChar and lower(cChar) != cChar
		ok
		return FALSE

	def IsLower()
		cChar = This.Content()
		if len(cChar) = 1
			return lower(cChar) = cChar and upper(cChar) != cChar
		ok
		return FALSE
