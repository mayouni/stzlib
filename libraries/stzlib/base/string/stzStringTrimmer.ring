#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSTRINGTRIMMER            #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String trimmer -- Wraps stzString via       #
#                  composition. Trimming whitespace and chars   #
#                  from strings.                               #
#                  For aliases, use stzStringTrimmerXT.         #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzStringTrimmer

	@oString

	def init(pStrOrStzStrObj)
		if isString(pStrOrStzStrObj)
			@oString = new stzString(pStrOrStzStrObj)
		but isObject(pStrOrStzStrObj)
			@oString = pStrOrStzStrObj
		else
			StzRaise("Can't create stzStringTrimmer! Parameter must be a string or stzString object.")
		ok

	def Content()
		return @oString.Content()

	def NumberOfChars()
		return @oString.NumberOfChars()

	def IsEmpty()
		return @oString.IsEmpty()

	  #======================================================#
	 #   TRIMMING BOTH SIDES                                #
	#======================================================#

	def Trim()
		pH = @oString.Engine()
		pR = StzEngineStringTrim(pH)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		@oString.Update(c)

		def TrimQ()
			This.Trim()
			return This

	def Trimmed()
		pH = @oString.Engine()
		pR = StzEngineStringTrimmed(pH)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		return c

	  #======================================================#
	 #   TRIMMING LEFT / RIGHT                              #
	#======================================================#

	def TrimLeft()
		pH = @oString.Engine()
		pR = StzEngineStringTrimLeft(pH)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		@oString.Update(c)

		def TrimLeftQ()
			This.TrimLeft()
			return This

	def TrimmedLeft()
		pH = @oString.Engine()
		pR = StzEngineStringTrimLeft(pH)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		return c

	def TrimRight()
		pH = @oString.Engine()
		pR = StzEngineStringTrimRight(pH)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		@oString.Update(c)

		def TrimRightQ()
			This.TrimRight()
			return This

	def TrimmedRight()
		pH = @oString.Engine()
		pR = StzEngineStringTrimRight(pH)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		return c

	  #======================================================#
	 #   TRIMMING START / END                               #
	#======================================================#

	def TrimStart()
		This.TrimLeft()

		def TrimStartQ()
			This.TrimStart()
			return This

	def TrimmedFromStart()
		return This.TrimmedLeft()

	def TrimEnd()
		This.TrimRight()

		def TrimEndQ()
			This.TrimEnd()
			return This

	def TrimmedFromEnd()
		return This.TrimmedRight()

	  #======================================================#
	 #   TRIMMING A SPECIFIC CHAR                           #
	#======================================================#

	def TrimCharCS(c, pCaseSensitive)
		This.TrimCharFromStartCS(c, pCaseSensitive)
		This.TrimCharFromEndCS(c, pCaseSensitive)

		def TrimCharCSQ(c, pCaseSensitive)
			This.TrimCharCS(c, pCaseSensitive)
			return This

	def CharTrimmedCS(c, pCaseSensitive)
		oCopy = new stzStringTrimmer(@oString.Content())
		oCopy.TrimCharCS(c, pCaseSensitive)
		return oCopy.Content()

	def TrimChar(c)
		This.TrimCharCS(c, 1)

		def TrimCharQ(c)
			This.TrimChar(c)
			return This

	def CharTrimmed(c)
		return This.CharTrimmedCS(c, 1)

	  #======================================================#
	 #   TRIMMING CHAR FROM START / END                     #
	#======================================================#

	def TrimCharFromStartCS(c, pCaseSensitive)
		cStr = @oString.Content()
		nLen = len(cStr)
		nStart = 1
		for i = 1 to nLen
			if BothStringsAreEqualCS(cStr[i], c, pCaseSensitive)
				nStart = i + 1
			else
				exit
			ok
		next
		if nStart > nLen
			@oString.Update("")
		else
			@oString.Update(substr(cStr, nStart, nLen - nStart + 1))
		ok

		def TrimCharFromStartCSQ(c, pCaseSensitive)
			This.TrimCharFromStartCS(c, pCaseSensitive)
			return This

		def RemoveThisCharFromStartCS(c, pCaseSensitive)
			This.TrimCharFromStartCS(c, pCaseSensitive)

	def TrimCharFromStart(c)
		This.TrimCharFromStartCS(c, 1)

		def RemoveThisCharFromStart(c)
			This.TrimCharFromStart(c)

	#--

	def TrimCharFromEndCS(c, pCaseSensitive)
		cStr = @oString.Content()
		nLen = len(cStr)
		nEnd = nLen
		for i = nLen to 1 step -1
			if BothStringsAreEqualCS(cStr[i], c, pCaseSensitive)
				nEnd = i - 1
			else
				exit
			ok
		next
		if nEnd < 1
			@oString.Update("")
		else
			@oString.Update(substr(cStr, 1, nEnd))
		ok

		def TrimCharFromEndCSQ(c, pCaseSensitive)
			This.TrimCharFromEndCS(c, pCaseSensitive)
			return This

		def RemoveThisCharFromEndCS(c, pCaseSensitive)
			This.TrimCharFromEndCS(c, pCaseSensitive)

	def TrimCharFromEnd(c)
		This.TrimCharFromEndCS(c, 1)

		def RemoveThisCharFromEnd(c)
			This.TrimCharFromEnd(c)

	  #======================================================#
	 #   TRIMMING CHAR FROM LEFT / RIGHT                    #
	#======================================================#

	def TrimCharFromLeftCS(c, pCaseSensitive)
		if @oString.IsLeftToRight()
			This.TrimCharFromStartCS(c, pCaseSensitive)
		else
			This.TrimCharFromEndCS(c, pCaseSensitive)
		ok

	def TrimCharFromLeft(c)
		This.TrimCharFromLeftCS(c, 1)

	def TrimCharFromRightCS(c, pCaseSensitive)
		if @oString.IsLeftToRight()
			This.TrimCharFromEndCS(c, pCaseSensitive)
		else
			This.TrimCharFromStartCS(c, pCaseSensitive)
		ok

	def TrimCharFromRight(c)
		This.TrimCharFromRightCS(c, 1)
