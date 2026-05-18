#--------------------------------------------------------------#
#         SOFTANZA LIBRARY (V0.9) - STZSTRINGFORMATTER         #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String formatter -- case conversion,        #
#                  alignment, padding, spacing, simplification, #
#                  and repeating.                                #
#                  Wraps stzString via composition.             #
#                  For aliases, use stzStringFormatterXT.       #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzStringFormatter

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
		@oString.Update( ring_reverse(@oString.Content()) )

		def ApplyReverseQ()
			This.ApplyReverse()
			return This

	def Reversed()
		return ring_reverse(@oString.Content())

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

		nChars = @oString.NumberOfChars()
		if nWidth > nChars
			cPad = ""
			nPadCount = nWidth - nChars
			for _i_ = 1 to nPadCount
				cPad += cChar
			next
			@oString.Update( @oString.Content() + cPad )
		ok

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

		nChars = @oString.NumberOfChars()
		if nWidth > nChars
			cPad = ""
			nPadCount = nWidth - nChars
			for _i_ = 1 to nPadCount
				cPad += cChar
			next
			@oString.Update( cPad + @oString.Content() )
		ok

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

		nChars = @oString.NumberOfChars()
		if nWidth > nChars
			nTotal = nWidth - nChars
			nLeft = floor(nTotal / 2)
			nRight = nTotal - nLeft

			cPadLeft = ""
			for _i_ = 1 to nLeft
				cPadLeft += cChar
			next

			cPadRight = ""
			for _i_ = 1 to nRight
				cPadRight += cChar
			next

			@oString.Update( cPadLeft + @oString.Content() + cPadRight )
		ok

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
		cContent = @oString.Content()
		cResult = ""
		bLastWasSpace = 0
		nLen = len(cContent)

		for i = 1 to nLen
			c = substr(cContent, i, 1)
			if c = " " or c = char(9) or c = char(10) or c = char(13)
				if NOT bLastWasSpace
					cResult += " "
					bLastWasSpace = 1
				ok
			else
				cResult += c
				bLastWasSpace = 0
			ok
		next

		cResult = trim(cResult)
		@oString.Update(cResult)

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
		@oString.Update( trim(@oString.Content()) )

		def TrimQ()
			This.Trim()
			return This

	def Trimmed()
		return trim(@oString.Content())

	def TrimLeft()
		cContent = @oString.Content()
		nLen = len(cContent)
		nStart = 1

		while nStart <= nLen
			c = substr(cContent, nStart, 1)
			if c != " " and c != char(9) and c != char(10) and c != char(13)
				exit
			ok
			nStart++
		end

		if nStart > nLen
			@oString.Update("")
		else
			@oString.Update(substr(cContent, nStart))
		ok

		def TrimLeftQ()
			This.TrimLeft()
			return This

	def TrimmedLeft()
		oCopy = new stzStringFormatter(@oString.Content())
		oCopy.TrimLeft()
		return oCopy.Content()

	def TrimRight()
		cContent = @oString.Content()
		nEnd = len(cContent)

		while nEnd >= 1
			c = substr(cContent, nEnd, 1)
			if c != " " and c != char(9) and c != char(10) and c != char(13)
				exit
			ok
			nEnd--
		end

		if nEnd < 1
			@oString.Update("")
		else
			@oString.Update(substr(cContent, 1, nEnd))
		ok

		def TrimRightQ()
			This.TrimRight()
			return This

	def TrimmedRight()
		oCopy = new stzStringFormatter(@oString.Content())
		oCopy.TrimRight()
		return oCopy.Content()

	  #===============================#
	 #     REPEATING                 #
	#===============================#

	def RepeatNTimes(n)
		cContent = @oString.Content()
		cResult = ""
		for i = 1 to n
			cResult += cContent
		next
		@oString.Update(cResult)

		def RepeatNTimesQ(n)
			This.RepeatNTimes(n)
			return This

	def RepeatedNTimes(n)
		cContent = @oString.Content()
		cResult = ""
		for i = 1 to n
			cResult += cContent
		next
		return cResult
