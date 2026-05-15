#--------------------------------------------------------------#
#         SOFTANZA LIBRARY (V0.9) - STZSTRINGFORMATTER         #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String formatter subclass -- case           #
#                  conversion, alignment, padding, spacing,     #
#                  simplification, and repeating.                #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////////
 ///   FUNCTIONS   ///
/////////////////////

func StzStringFormatterQ(str)
	return new stzStringFormatter(str)


  /////////////////
 ///   CLASS   ///
/////////////////

class stzStringFormatter from stzString

	  #===============================#
	 #     LOWERCASE                 #
	#===============================#

	def ApplyLowercase()
		This.Update( lower(This.Content()) )

		def ApplyLowercaseQ()
			This.ApplyLowercase()
			return This

		def Lowercase()
			This.ApplyLowercase()

			def LowercaseQ()
				This.Lowercase()
				return This

	def Lowercased()
		return lower(This.Content())

		def LowercasedQ()
			return new stzStringFormatter(This.Lowercased())

		def ToLowercase()
			return This.Lowercased()

	  #===============================#
	 #     UPPERCASE                 #
	#===============================#

	def ApplyUppercase()
		This.Update( upper(This.Content()) )

		def ApplyUppercaseQ()
			This.ApplyUppercase()
			return This

		def Uppercase()
			This.ApplyUppercase()

			def UppercaseQ()
				This.Uppercase()
				return This

	def Uppercased()
		return upper(This.Content())

		def UppercasedQ()
			return new stzStringFormatter(This.Uppercased())

		def ToUppercase()
			return This.Uppercased()

	  #===============================#
	 #     CAPITALIZE                #
	#===============================#

	def ApplyCapitalcase()
		cContent = This.Content()
		nLen = len(cContent)
		if nLen = 0
			return
		ok

		cFirst = upper(substr(cContent, 1, 1))
		if nLen > 1
			cRest = lower(substr(cContent, 2))
			This.Update(cFirst + cRest)
		else
			This.Update(cFirst)
		ok

		def ApplyCapitalcaseQ()
			This.ApplyCapitalcase()
			return This

		def Capitalize()
			This.ApplyCapitalcase()

			def CapitalizeQ()
				This.Capitalize()
				return This

	def Capitalized()
		cContent = This.Content()
		nLen = len(cContent)
		if nLen = 0
			return ""
		ok

		cFirst = upper(substr(cContent, 1, 1))
		if nLen > 1
			return cFirst + lower(substr(cContent, 2))
		else
			return cFirst
		ok

		def CapitalizedQ()
			return new stzStringFormatter(This.Capitalized())

	  #===============================#
	 #     TITLECASE                 #
	#===============================#

	def ApplyTitlecase()
		cContent = This.Content()
		cResult = ""
		bNextUpper = 1
		nLen = len(cContent)

		for i = 1 to nLen
			c = substr(cContent, i, 1)
			if c = " " or c = char(9) or c = char(10)
				cResult += c
				bNextUpper = 1
			else
				if bNextUpper
					cResult += upper(c)
					bNextUpper = 0
				else
					cResult += lower(c)
				ok
			ok
		next

		This.Update(cResult)

		def ApplyTitlecaseQ()
			This.ApplyTitlecase()
			return This

		def Titlecase()
			This.ApplyTitlecase()

			def TitlecaseQ()
				This.Titlecase()
				return This

	def Titlecased()
		oCopy = new stzStringFormatter(This.Content())
		oCopy.ApplyTitlecase()
		return oCopy.Content()

		def TitlecasedQ()
			return new stzStringFormatter(This.Titlecased())

	  #===============================#
	 #     CASE FOLD                 #
	#===============================#

	def ApplyCaseFold()
		This.Update( lower(This.Content()) )

		def CaseFold()
			This.ApplyCaseFold()

	def CaseFolded()
		return lower(This.Content())

	  #===============================#
	 #     REVERSED                  #
	#===============================#

	def ApplyReverse()
		This.Update( ring_reverse(This.Content()) )

		def ApplyReverseQ()
			This.ApplyReverse()
			return This

		def Reverse()
			This.ApplyReverse()

			def ReverseQ()
				This.Reverse()
				return This

	def Reversed()
		return ring_reverse(This.Content())

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

		def AlignLeft(nWidth)
			This.LeftAlign(nWidth)

	def LeftAlignXT(nWidth, cChar)
		if CheckingParams()
			if NOT isNumber(nWidth)
				StzRaise("Incorrect param type! nWidth must be a number.")
			ok
			if NOT ( isString(cChar) and len(cChar) = 1 )
				StzRaise("Incorrect param type! cChar must be a char.")
			ok
		ok

		if nWidth > This.NumberOfChars()
			cPad = ""
			nPadCount = nWidth - len(This.Content())
			for _i_ = 1 to nPadCount
				cPad += cChar
			next
			This.Update( This.Content() + cPad )
		ok

		def LeftAlignXTQ(nWidth, cChar)
			This.LeftAlignXT(nWidth, cChar)
			return This

		def AlignLeftXT(nWidth, cChar)
			This.LeftAlignXT(nWidth, cChar)

	def LeftAligned(nWidth)
		oCopy = new stzStringFormatter(This.Content())
		oCopy.LeftAlign(nWidth)
		return oCopy.Content()

		def AlignedToLeft(nWidth)
			return This.LeftAligned(nWidth)

	  #===============================#
	 #     RIGHT ALIGN               #
	#===============================#

	def RightAlign(nWidth)
		This.RightAlignXT(nWidth, " ")

		def RightAlignQ(nWidth)
			This.RightAlign(nWidth)
			return This

		def AlignRight(nWidth)
			This.RightAlign(nWidth)

	def RightAlignXT(nWidth, cChar)
		if CheckingParams()
			if NOT isNumber(nWidth)
				StzRaise("Incorrect param type! nWidth must be a number.")
			ok
			if NOT ( isString(cChar) and len(cChar) = 1 )
				StzRaise("Incorrect param type! cChar must be a char.")
			ok
		ok

		if nWidth > This.NumberOfChars()
			cPad = ""
			nPadCount = nWidth - len(This.Content())
			for _i_ = 1 to nPadCount
				cPad += cChar
			next
			This.Update( cPad + This.Content() )
		ok

		def RightAlignXTQ(nWidth, cChar)
			This.RightAlignXT(nWidth, cChar)
			return This

		def AlignRightXT(nWidth, cChar)
			This.RightAlignXT(nWidth, cChar)

	def RightAligned(nWidth)
		oCopy = new stzStringFormatter(This.Content())
		oCopy.RightAlign(nWidth)
		return oCopy.Content()

		def AlignedToRight(nWidth)
			return This.RightAligned(nWidth)

	  #===============================#
	 #     CENTER ALIGN              #
	#===============================#

	def CenterAlign(nWidth)
		This.CenterAlignXT(nWidth, " ")

		def CenterAlignQ(nWidth)
			This.CenterAlign(nWidth)
			return This

		def AlignCenter(nWidth)
			This.CenterAlign(nWidth)

	def CenterAlignXT(nWidth, cChar)
		if CheckingParams()
			if NOT isNumber(nWidth)
				StzRaise("Incorrect param type! nWidth must be a number.")
			ok
			if NOT ( isString(cChar) and len(cChar) = 1 )
				StzRaise("Incorrect param type! cChar must be a char.")
			ok
		ok

		nChars = This.NumberOfChars()
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

			This.Update( cPadLeft + This.Content() + cPadRight )
		ok

		def CenterAlignXTQ(nWidth, cChar)
			This.CenterAlignXT(nWidth, cChar)
			return This

		def AlignCenterXT(nWidth, cChar)
			This.CenterAlignXT(nWidth, cChar)

	def CenterAligned(nWidth)
		oCopy = new stzStringFormatter(This.Content())
		oCopy.CenterAlign(nWidth)
		return oCopy.Content()

		def AlignedToCenter(nWidth)
			return This.CenterAligned(nWidth)

		def Centered(nWidth)
			return This.CenterAligned(nWidth)

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
		cContent = This.Content()
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
		This.Update(cResult)

		def SimplifyQ()
			This.Simplify()
			return This

	def Simplified()
		oCopy = new stzStringFormatter(This.Content())
		oCopy.Simplify()
		return oCopy.Content()

		def SimplifiedQ()
			return new stzStringFormatter(This.Simplified())

	  #===============================#
	 #     TRIMMING                  #
	#===============================#

	def Trim()
		This.Update( trim(This.Content()) )

		def TrimQ()
			This.Trim()
			return This

	def Trimmed()
		return trim(This.Content())

	def TrimLeft()
		cContent = This.Content()
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
			This.Update("")
		else
			This.Update(substr(cContent, nStart))
		ok

		def TrimLeftQ()
			This.TrimLeft()
			return This

	def TrimmedLeft()
		oCopy = new stzStringFormatter(This.Content())
		oCopy.TrimLeft()
		return oCopy.Content()

	def TrimRight()
		cContent = This.Content()
		nEnd = len(cContent)

		while nEnd >= 1
			c = substr(cContent, nEnd, 1)
			if c != " " and c != char(9) and c != char(10) and c != char(13)
				exit
			ok
			nEnd--
		end

		if nEnd < 1
			This.Update("")
		else
			This.Update(substr(cContent, 1, nEnd))
		ok

		def TrimRightQ()
			This.TrimRight()
			return This

	def TrimmedRight()
		oCopy = new stzStringFormatter(This.Content())
		oCopy.TrimRight()
		return oCopy.Content()

	  #===============================#
	 #     REPEATING                 #
	#===============================#

	def RepeatNTimes(n)
		cContent = This.Content()
		cResult = ""
		for i = 1 to n
			cResult += cContent
		next
		This.Update(cResult)

		def RepeatNTimesQ(n)
			This.RepeatNTimes(n)
			return This

	def RepeatedNTimes(n)
		cContent = This.Content()
		cResult = ""
		for i = 1 to n
			cResult += cContent
		next
		return cResult

		def Repeated(n)
			return This.RepeatedNTimes(n)

