#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSTRINGALIGNER            #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String aligner -- alignment and padding     #
#                  operations.                                 #
#                  Wraps stzString via composition.            #
#                  For aliases, use stzStringAlignerXT.        #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


class stzStringAligner from stzObject

	@oString

	def init(pStrOrStzStrObj)
		if isString(pStrOrStzStrObj)
			@oString = new stzString(pStrOrStzStrObj)
		but isObject(pStrOrStzStrObj)
			@oString = pStrOrStzStrObj
		else
			StzRaise("Can't create stzStringAligner! Parameter must be a string or stzString object.")
		ok

	def Content()
		return @oString.Content()

	def NumberOfChars()
		return @oString.NumberOfChars()

	def IsEmpty()
		return @oString.IsEmpty()

	  #======================================================#
	 #   ALIGN LEFT                                         #
	#======================================================#

	def AlignLeft(n, pcChar)
		if isList(pcChar) and IsOneOfTheseNamedParamsList(pcChar, [:Using, :With, :Char])
			pcChar = pcChar[2]
		ok
		pH = @oString.Engine()
		pR = StzEngineStringLjust(pH, n, pcChar)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		@oString.Update(c)

		def AlignLeftQ(n, pcChar)
			This.AlignLeft(n, pcChar)
			return This

	def AlignedLeft(n, pcChar)
		oCopy = new stzStringAligner(@oString.Content())
		oCopy.AlignLeft(n, pcChar)
		return oCopy.Content()

	  #======================================================#
	 #   ALIGN RIGHT                                        #
	#======================================================#

	def AlignRight(n, pcChar)
		if isList(pcChar) and IsOneOfTheseNamedParamsList(pcChar, [:Using, :With, :Char])
			pcChar = pcChar[2]
		ok
		pH = @oString.Engine()
		pR = StzEngineStringRjust(pH, n, pcChar)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		@oString.Update(c)

		def AlignRightQ(n, pcChar)
			This.AlignRight(n, pcChar)
			return This

	def AlignedRight(n, pcChar)
		oCopy = new stzStringAligner(@oString.Content())
		oCopy.AlignRight(n, pcChar)
		return oCopy.Content()

	  #======================================================#
	 #   ALIGN CENTER                                       #
	#======================================================#

	def AlignCenter(n, pcChar)
		if isList(pcChar) and IsOneOfTheseNamedParamsList(pcChar, [:Using, :With, :Char])
			pcChar = pcChar[2]
		ok
		pH = @oString.Engine()
		pR = StzEngineStringCenterPad(pH, n, pcChar)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		@oString.Update(c)

		def AlignCenterQ(n, pcChar)
			This.AlignCenter(n, pcChar)
			return This

	def AlignedCenter(n, pcChar)
		oCopy = new stzStringAligner(@oString.Content())
		oCopy.AlignCenter(n, pcChar)
		return oCopy.Content()

	  #======================================================#
	 #   PAD LEFT / RIGHT                                   #
	#======================================================#

	def PadLeft(n, pcChar)
		This.AlignRight(n, pcChar)

		def PadLeftQ(n, pcChar)
			This.PadLeft(n, pcChar)
			return This

	def PaddedLeft(n, pcChar)
		return This.AlignedRight(n, pcChar)

	def PadRight(n, pcChar)
		This.AlignLeft(n, pcChar)

		def PadRightQ(n, pcChar)
			This.PadRight(n, pcChar)
			return This

	def PaddedRight(n, pcChar)
		return This.AlignedLeft(n, pcChar)

	  #======================================================#
	 #   PAD BOTH SIDES                                     #
	#======================================================#

	def PadBoth(n, pcChar)
		This.AlignCenter(n, pcChar)

		def PadBothQ(n, pcChar)
			This.PadBoth(n, pcChar)
			return This

	def PaddedBoth(n, pcChar)
		return This.AlignedCenter(n, pcChar)

	  #======================================================#
	 #   ALIGNMENT CHECKING                                 #
	#======================================================#

	def IsAlignedLeft(n, pcChar)
		cStr = @oString.Content()
		nLen = @oString.NumberOfChars()
		if nLen >= n
			return 1
		ok
		cPad = ""
		for i = 1 to n - nLen
			cPad += pcChar
		next
		return StzRight(cStr, n - nLen) = cPad

	def IsAlignedRight(n, pcChar)
		cStr = @oString.Content()
		nLen = @oString.NumberOfChars()
		if nLen >= n
			return 1
		ok
		cPad = ""
		for i = 1 to n - nLen
			cPad += pcChar
		next
		return StzLeft(cStr, n - nLen) = cPad
