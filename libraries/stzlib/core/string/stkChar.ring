# Requires LightGuiLib

func DoubleQuote()
        return char(34)  # "

func SingleQuote()
        return char(39)  # '

#~~~~~~~~~~~~~~~~~#
#  STZ CORE CHAR  #
#~~~~~~~~~~~~~~~~~#

class stkChar from stzCoreChar

class stzCoreChar from stzCoreObject
	@content // a QChar object from Qt

	def init(p)
		if isString(p)
			oQStr = new QString2()
			oQStr.append(p)

			nUnicode = oQStr.unicode().unicode()
			@content = new QChar(nUnicode)

		but isNumber(p)
			@content = new QChar(p)

		but isObject(p) and classname(p) = "qchar"
			@content = p

		else
			raise( "ERR-" + StkError(:CanNotCreateObject) )
		ok

	def Content()
		oQStr = new QString2()
		oQStr.append_2(@content) # append_2 adds a QChar while append() adds a string
		return oQStr.ToUtf8().data()

		def Char()
			return This.Content()

	def Unicode()
		oQStr = new QString2()
		oQStr.append_2(@content)
		return oQStr.unicode().unicode()

	def QCharObject()
		return @content

		def Qt()
			return @content

	def Mirrored()
		oTempChar = new stkChar(@content.mirroredchar())
		return oTempChar.Content()


