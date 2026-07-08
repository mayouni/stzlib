#--------------------------------------------------------------#
#         SOFTANZA LIBRARY (V0.9) - STZSTRINGFORMATTER         #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String formatter -- case conversion,        #
#                  alignment, padding, spacing, simplification #
#                  and repeating.                              #
#                  Wraps stzString via composition.            #
#                  For aliases, use stzStringFormatterXT.      #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


class stzStringFormatter from stzObject

	@oString

	  #===================#
	 #   INITIALIZATION  #
	#===================#

	def init(pStrOrStzStrObj)
		if isString(pStrOrStzStrObj)
			@oString = new stzString(pStrOrStzStrObj)
		but isObject(pStrOrStzStrObj)
			@oString = pStrOrStzStrObj
		else
			StzRaise("Can't create stzStringFormatter! Parameter must be a string or stzString object.")
		ok

	  #===============================#
	 #     CONTENT ACCESS            #
	#===============================#

	def Content()
		return @oString.Content()

	def NumberOfChars()
		return @oString.NumberOfChars()

	def IsEmpty()
		return @oString.IsEmpty()

	  #===============================#
	 #     LOWERCASE                 #
	#===============================#

	def ApplyLowercase()
		pHandle = StzEngineString(@oString.Content())
		pLower = StzEngineStringToLower(pHandle)
		@oString.Update(StzEngineStringData(pLower))
		StzEngineStringFree(pLower)
		StzEngineStringFree(pHandle)

		def ApplyLowercaseQ()
			This.ApplyLowercase()
			return This

	def Lowercased()
		pHandle = StzEngineString(@oString.Content())
		pLower = StzEngineStringToLower(pHandle)
		cResult = StzEngineStringData(pLower)
		StzEngineStringFree(pLower)
		StzEngineStringFree(pHandle)
		return cResult

		def LowercasedQ()
			return new stzStringFormatter(This.Lowercased())

	  #===============================#
	 #     UPPERCASE                 #
	#===============================#

	def ApplyUppercase()
		pHandle = StzEngineString(@oString.Content())
		pUpper = StzEngineStringToUpper(pHandle)
		@oString.Update(StzEngineStringData(pUpper))
		StzEngineStringFree(pUpper)
		StzEngineStringFree(pHandle)

		def ApplyUppercaseQ()
			This.ApplyUppercase()
			return This

	def Uppercased()
		pHandle = StzEngineString(@oString.Content())
		pUpper = StzEngineStringToUpper(pHandle)
		cResult = StzEngineStringData(pUpper)
		StzEngineStringFree(pUpper)
		StzEngineStringFree(pHandle)
		return cResult

		def UppercasedQ()
			return new stzStringFormatter(This.Uppercased())

	  #===============================#
	 #     CAPITALIZE                #
	#===============================#

	def ApplyCapitalcase()
		cContent = @oString.Content()
		if StzLen(cContent) = 0
			return
		ok

		cFirst = StzUpper(StzLeft(cContent, 1))
		if StzLen(cContent) > 1
			pH = StzEngineString(cContent)
			pRest = StzEngineStringSlice(pH, 2, StzLen(cContent) - 1)
			cRest = StzLower(StzEngineStringData(pRest))
			StzEngineStringFree(pRest)
			StzEngineStringFree(pH)
			@oString.Update(cFirst + cRest)
		else
			@oString.Update(cFirst)
		ok

		def ApplyCapitalcaseQ()
			This.ApplyCapitalcase()
			return This

	def Capitalized()
		cContent = @oString.Content()
		if StzLen(cContent) = 0
			return ""
		ok

		cFirst = StzUpper(StzLeft(cContent, 1))
		if StzLen(cContent) > 1
			pH = StzEngineString(cContent)
			pRest = StzEngineStringSlice(pH, 2, StzLen(cContent) - 1)
			cRest = StzLower(StzEngineStringData(pRest))
			StzEngineStringFree(pRest)
			StzEngineStringFree(pH)
			return cFirst + cRest
		else
			return cFirst
		ok

		def CapitalizedQ()
			return new stzStringFormatter(This.Capitalized())

	  #===============================#
	 #     TITLECASE                 #
	#===============================#

	def ApplyTitlecase()
		@oString.Update(StzTitle(@oString.Content()))

		def ApplyTitlecaseQ()
			This.ApplyTitlecase()
			return This

	def Titlecased()
		oCopy = new stzStringFormatter(@oString.Content())
		oCopy.ApplyTitlecase()
		return oCopy.Content()

		def TitlecasedQ()
			return new stzStringFormatter(This.Titlecased())

	  #===============================#
	 #     CASE FOLD                 #
	#===============================#

	def ApplyCaseFold()
		@oString.Update(StzCaseFold(@oString.Content()))

	def CaseFolded()
		return StzCaseFold(@oString.Content())

	  #===============================#
	 #     REVERSED                  #
	#===============================#

	def ApplyReverse()
		@oString.Update(StzReverse(@oString.Content()))

		def ApplyReverseQ()
			This.ApplyReverse()
			return This

	def Reversed()
		return StzReverse(@oString.Content())

		def ReversedQ()
			return new stzStringFormatter(This.Reversed())

	  #===============================#
	 #     LEFT ALIGN                #
	#===============================#

	def LeftAlign(nWidth)
		This.LeftAlignXT(nWidth, " ")

		def LeftAlignQ(nWidth)
			This.LeftAlign(nWidth)
			return This

	def LeftAlignXT(nWidth, cChar)
		if CheckingParams()
			if NOT isNumber(nWidth)
				StzRaise("Incorrect param type! nWidth must be a number.")
			ok
			if NOT ( isString(cChar) and StzLen(cChar) = 1 )
				StzRaise("Incorrect param type! cChar must be a char.")
			ok
		ok
		pH = @oString.Engine()
		pR = StzEngineStringLjust(pH, nWidth, cChar)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		@oString.Update(c)

		def LeftAlignXTQ(nWidth, cChar)
			This.LeftAlignXT(nWidth, cChar)
			return This

	def LeftAligned(nWidth)
		oCopy = new stzStringFormatter(@oString.Content())
		oCopy.LeftAlign(nWidth)
		return oCopy.Content()

	  #===============================#
	 #     RIGHT ALIGN               #
	#===============================#

	def RightAlign(nWidth)
		This.RightAlignXT(nWidth, " ")

		def RightAlignQ(nWidth)
			This.RightAlign(nWidth)
			return This

	def RightAlignXT(nWidth, cChar)
		if CheckingParams()
			if NOT isNumber(nWidth)
				StzRaise("Incorrect param type! nWidth must be a number.")
			ok
			if NOT ( isString(cChar) and StzLen(cChar) = 1 )
				StzRaise("Incorrect param type! cChar must be a char.")
			ok
		ok
		pH = @oString.Engine()
		pR = StzEngineStringRjust(pH, nWidth, cChar)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		@oString.Update(c)

		def RightAlignXTQ(nWidth, cChar)
			This.RightAlignXT(nWidth, cChar)
			return This

	def RightAligned(nWidth)
		oCopy = new stzStringFormatter(@oString.Content())
		oCopy.RightAlign(nWidth)
		return oCopy.Content()

	  #===============================#
	 #     CENTER ALIGN              #
	#===============================#

	def CenterAlign(nWidth)
		This.CenterAlignXT(nWidth, " ")

		def CenterAlignQ(nWidth)
			This.CenterAlign(nWidth)
			return This

	def CenterAlignXT(nWidth, cChar)
		if CheckingParams()
			if NOT isNumber(nWidth)
				StzRaise("Incorrect param type! nWidth must be a number.")
			ok
			if NOT ( isString(cChar) and StzLen(cChar) = 1 )
				StzRaise("Incorrect param type! cChar must be a char.")
			ok
		ok
		pH = @oString.Engine()
		pR = StzEngineStringCenterPad(pH, nWidth, cChar)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		@oString.Update(c)

		def CenterAlignXTQ(nWidth, cChar)
			This.CenterAlignXT(nWidth, cChar)
			return This

	def CenterAligned(nWidth)
		oCopy = new stzStringFormatter(@oString.Content())
		oCopy.CenterAlign(nWidth)
		return oCopy.Content()

	  #===============================#
	 #     PADDING                   #
	#===============================#

	def PadLeft(nWidth, cChar)
		This.RightAlignXT(nWidth, cChar)

		def PadLeftQ(nWidth, cChar)
			This.PadLeft(nWidth, cChar)
			return This

	def PaddedLeft(nWidth, cChar)
		return This.RightAligned(nWidth)

	def PadRight(nWidth, cChar)
		This.LeftAlignXT(nWidth, cChar)

		def PadRightQ(nWidth, cChar)
			This.PadRight(nWidth, cChar)
			return This

	def PaddedRight(nWidth, cChar)
		return This.LeftAligned(nWidth)

	  #===============================#
	 #     SIMPLIFICATION            #
	#===============================#

	def Simplify()
		pH = @oString.Engine()
		pR = StzEngineStringSimplify(pH)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		@oString.Update(c)

		def SimplifyQ()
			This.Simplify()
			return This

	def Simplified()
		oCopy = new stzStringFormatter(@oString.Content())
		oCopy.Simplify()
		return oCopy.Content()

		def SimplifiedQ()
			return new stzStringFormatter(This.Simplified())

	  #===============================#
	 #     TRIMMING                  #
	#===============================#

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

	  #===============================#
	 #     REPEATING                 #
	#===============================#

	def RepeatNTimes(n)
		pH = @oString.Engine()
		pR = StzEngineStringRepeat(pH, n)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		@oString.Update(c)

		def RepeatNTimesQ(n)
			This.RepeatNTimes(n)
			return This

	def RepeatedNTimes(n)
		pH = @oString.Engine()
		pR = StzEngineStringRepeat(pH, n)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		return c
