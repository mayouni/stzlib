# Requires Engine or LightGuiLib


#~~~~~~~~~~~~~~~~~#
#  STZ CORE CHAR  #
#~~~~~~~~~~~~~~~~~#

class stkChar from stzCoreChar

class stzCoreChar from stzCoreObject
	@content
	@nUnicode = 0

	def init(p)
		if isString(p)
			if isGlobal(:$STZ_ENGINE_LOADED) and $STZ_ENGINE_LOADED = TRUE
				@nUnicode = CallCFunc($pEngineHandle, "stz_char_unicode", "i", "p", p)
				@content = p
			else
				oQStr = new QString2()
				oQStr.append(p)

				@nUnicode = oQStr.unicode().unicode()
				@content = new QChar(@nUnicode)
			ok

		but isNumber(p)
			@nUnicode = p
			if isGlobal(:$STZ_ENGINE_LOADED) and $STZ_ENGINE_LOADED = TRUE
				cBuf = space(4)
				nLen = CallCFunc($pEngineHandle, "stz_char_to_utf8", "i", "ipi",
				                 p, cBuf, 4)
				@content = left(cBuf, nLen)
			else
				@content = new QChar(p)
			ok

		but isObject(p) and classname(p) = "qchar"
			@content = p
			oQStr = new QString2()
			oQStr.append_2(p)
			@nUnicode = oQStr.unicode().unicode()

		else
			raise( "ERR-" + StkError(:CanNotCreateObject) )
		ok

	def Content()
		if isGlobal(:$STZ_ENGINE_LOADED) and $STZ_ENGINE_LOADED = TRUE
			if isString(@content) return @content ok
			# Convert from unicode
			cBuf = space(4)
			nLen = CallCFunc($pEngineHandle, "stz_char_to_utf8", "i", "ipi",
			                 @nUnicode, cBuf, 4)
			return left(cBuf, nLen)
		ok

		oQStr = new QString2()
		oQStr.append_2(@content)
		return oQStr.ToUtf8().data()

		def Char()
			return This.Content()

	def Unicode()
		return @nUnicode

	def IsLetter()
		if isGlobal(:$STZ_ENGINE_LOADED) and $STZ_ENGINE_LOADED = TRUE
			return CallCFunc($pEngineHandle, "stz_char_is_letter", "i", "i", @nUnicode) = 1
		ok
		return FALSE

	def IsDigit()
		if isGlobal(:$STZ_ENGINE_LOADED) and $STZ_ENGINE_LOADED = TRUE
			return CallCFunc($pEngineHandle, "stz_char_is_digit", "i", "i", @nUnicode) = 1
		ok
		return FALSE

	def IsUpper()
		if isGlobal(:$STZ_ENGINE_LOADED) and $STZ_ENGINE_LOADED = TRUE
			return CallCFunc($pEngineHandle, "stz_char_is_upper", "i", "i", @nUnicode) = 1
		ok
		return FALSE

	def IsLower()
		if isGlobal(:$STZ_ENGINE_LOADED) and $STZ_ENGINE_LOADED = TRUE
			return CallCFunc($pEngineHandle, "stz_char_is_lower", "i", "i", @nUnicode) = 1
		ok
		return FALSE

	def QCharObject()
		if isGlobal(:$STZ_ENGINE_LOADED) and $STZ_ENGINE_LOADED = TRUE
			return NULL
		ok
		return @content

		def Qt()
			return This.QCharObject()

	def Mirrored()
		if isGlobal(:$STZ_ENGINE_LOADED) and $STZ_ENGINE_LOADED = TRUE
			return This.Content()
		ok
		oTempChar = new stkChar(@content.mirroredchar())
		return oTempChar.Content()


