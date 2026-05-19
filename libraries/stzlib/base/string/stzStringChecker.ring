#--------------------------------------------------------------#
#         SOFTANZA LIBRARY (V0.9) - STZSTRINGCHECKER           #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String checker -- type checking, content    #
#                  validation, palindrome, anagram, and        #
#                  structural checks.                          #
#                  Wraps stzString via composition.            #
#                  For aliases, use stzStringCheckerXT.        #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


class stzStringChecker

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
			StzRaise("Can't create stzStringChecker! Parameter must be a string or stzString object.")
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
	 #     PALINDROME                #
	#===============================#

	def IsPalindromeCS(pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		pH = @oString.Engine()
		# Engine palindrome is always CS. For CI, casefold first.
		if _bCase_ = 0
			pFolded = StzEngineStringFoldcase(pH)
			nResult = StzEngineStringIsPalindrome(pFolded)
			StzEngineStringFree(pFolded)
		else
			nResult = StzEngineStringIsPalindrome(pH)
		ok
		return nResult

	def IsPalindrome()
		return This.IsPalindromeCS(1)

	  #===============================#
	 #     ANAGRAM                   #
	#===============================#

	def IsAnagramOfCS(pcOtherStr, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		pH = @oString.Engine()
		pH2 = StzEngineString(pcOtherStr)
		nResult = StzEngineStringIsAnagramCS(pH, pH2, _bCase_)
		StzEngineStringFree(pH2)
		return nResult

	def IsAnagramOf(pcOtherStr)
		return This.IsAnagramOfCS(pcOtherStr, 1)

	  #===============================#
	 #     CASE CHECKING             #
	#===============================#

	def IsUppercase()
		return StzIsUpper(@oString.Content())

	def IsLowercase()
		return StzIsLower(@oString.Content())

	def IsCapitalcase()
		cStr = @oString.Content()
		if StzLen(cStr) < 1
			return 0
		ok

		cFirst = StzLeft(cStr, 1)
		if cFirst = StzUpper(cFirst) and StzLen(cStr) > 1
			pH = StzEngineString(cStr)
			pRest = StzEngineStringSlice(pH, 2, StzLen(cStr) - 1)
			cRest = StzEngineStringData(pRest)
			StzEngineStringFree(pRest)
			StzEngineStringFree(pH)
			return cRest = StzLower(cRest)
		ok
		return 0

	def IsHybridcase()
		pH = StzEngineString(@oString.Content())
		nResult = StzEngineStringHasMixedCase(pH)
		StzEngineStringFree(pH)
		return nResult

	  #===============================#
	 #     CONTENT COMPOSITION       #
	#===============================#

	def ContainsOnlySpaces()
		pH = StzEngineString(@oString.Content())
		n = StzEngineStringIsWhitespace(pH)
		StzEngineStringFree(pH)
		return n

	def ContainsOnlyLetters()
		return StzIsAlpha(@oString.Content())

	def ContainsOnlyNumbers()
		pH = StzEngineString(@oString.Content())
		n = StzEngineStringIsNumericString(pH)
		StzEngineStringFree(pH)
		return n

	def ContainsOnlyDigits()
		return StzIsDigit(@oString.Content())

	def ContainsOnlyLettersAndNumbers()
		pH = StzEngineString(@oString.Content())
		n = StzEngineStringIsAlphanumeric(pH)
		StzEngineStringFree(pH)
		return n

	  #===============================#
	 #     IS MADE OF                #
	#===============================#

	def IsMadeOfCS(acSubStr, pCaseSensitive)
		if CheckingParams()
			if NOT (isList(acSubStr) and @IsListOfStrings(acSubStr))
				StzRaise("Incorrect param type! acSubStr must be a list of strings.")
			ok
		ok

		cCopy = @oString.Content()
		nLen = len(acSubStr)

		for i = 1 to nLen
			cCopy = @ReplaceCS(cCopy, acSubStr[i], "", pCaseSensitive)
		next

		if cCopy = ""
			return 1
		else
			return 0
		ok

	def IsMadeOf(acSubStr)
		return This.IsMadeOfCS(acSubStr, 1)

	def IsMadeOfCharCS(c, pCaseSensitive)
		if isString(c) and @IsChar(c)
			return This.IsMadeOfCS([ c ], pCaseSensitive)
		else
			return 0
		ok

	def IsMadeOfChar(c)
		return This.IsMadeOfCharCS(c, 1)

	def IsMadeOfSomeCS(acSubStr, pCaseSensitive)
		if CheckingParams()
			if NOT (isList(acSubStr) and @IsListOfStrings(acSubStr))
				StzRaise("Incorrect param type! acSubStr must be a list of strings.")
			ok
		ok

		cCopy = @oString.Content()
		nLen = len(acSubStr)

		for i = 1 to nLen
			oFinder = new stzStringFinder(cCopy)
			if oFinder.ContainsCS(acSubStr[i], pCaseSensitive)
				cCopy = @ReplaceCS(cCopy, acSubStr[i], "", pCaseSensitive)
			ok
		next

		if cCopy = ""
			return 1
		else
			return 0
		ok

	def IsMadeOfSome(acSubStr)
		return This.IsMadeOfSomeCS(acSubStr, 1)

	  #===============================#
	 #     NUMBER REPRESENTATION     #
	#===============================#

	def RepresentsInteger()
		cContent = @oString.Content()
		nLen = len(cContent)

		if nLen = 0
			return 0
		ok

		nStart = 1
		c1 = substr(cContent, 1, 1)
		if c1 = "+" or c1 = "-"
			nStart = 2
			if nLen = 1
				return 0
			ok
		ok

		for i = nStart to nLen
			c = substr(cContent, i, 1)
			if NOT isDigit(c)
				return 0
			ok
		next

		return 1

	def RepresentsSignedInteger()
		if This.RepresentsInteger()
			c1 = substr(@oString.Content(), 1, 1)
			if c1 = "+" or c1 = "-"
				return 1
			ok
		ok
		return 0

	def RepresentsUnsignedInteger()
		if This.RepresentsInteger() and NOT This.RepresentsSignedInteger()
			return 1
		else
			return 0
		ok

	def RepresentsNumber()
		cContent = @oString.Content()
		nLen = len(cContent)

		if nLen = 0
			return 0
		ok

		nStart = 1
		c1 = substr(cContent, 1, 1)
		if c1 = "+" or c1 = "-"
			nStart = 2
			if nLen = 1
				return 0
			ok
		ok

		bDotSeen = 0
		for i = nStart to nLen
			c = substr(cContent, i, 1)
			if c = "."
				if bDotSeen
					return 0
				ok
				bDotSeen = 1
			but NOT isDigit(c)
				return 0
			ok
		next

		return 1

	def RepresentsDecimalNumber()
		if This.RepresentsNumber()
			oFinder = new stzStringFinder(@oString)
			if oFinder.Contains(".")
				return 1
			ok
		ok
		return 0

	def RepresentsBinaryNumber()
		cContent = @oString.Content()
		nLen = len(cContent)

		if nLen < 3
			return 0
		ok

		if NOT (substr(cContent, 1, 2) = "0b" or substr(cContent, 1, 2) = "0B")
			return 0
		ok

		for i = 3 to nLen
			c = substr(cContent, i, 1)
			if c != "0" and c != "1"
				return 0
			ok
		next
		return 1

	def RepresentsHexNumber()
		cContent = @oString.Content()
		nLen = len(cContent)

		if nLen < 3
			return 0
		ok

		if NOT (substr(cContent, 1, 2) = "0x" or substr(cContent, 1, 2) = "0X")
			return 0
		ok

		for i = 3 to nLen
			c = StzLower(substr(cContent, i, 1))
			if NOT isDigit(c) and NOT (c >= "a" and c <= "f")
				return 0
			ok
		next
		return 1

	  #===============================#
	 #     REVERSED COPY             #
	#===============================#

	def IsReversedCopyOfCS(pcOtherStr, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		pH = @oString.Engine()
		pRev = StzEngineStringReverse(pH)
		pH2 = StzEngineString(pcOtherStr)
		nResult = StzEngineStringEqualsCS(pRev, pH2, _bCase_)
		StzEngineStringFree(pRev)
		StzEngineStringFree(pH2)
		return nResult

	def IsReversedCopyOf(pcOtherStr)
		return This.IsReversedCopyOfCS(pcOtherStr, 1)

	  #===============================#
	 #     REVERSED                  #
	#===============================#

	def Reversed()
		return StzReverse(@oString.Content())

	  #===============================#
	 #     STRUCTURAL CHECKS         #
	#===============================#

	def IsChar()
		return @oString.NumberOfChars() = 1

	def IsLetter()
		if @oString.NumberOfChars() != 1
			return 0
		ok
		return isAlpha(@oString.Content())

	def IsADigit()
		if @oString.NumberOfChars() != 1
			return 0
		ok
		return isDigit(@oString.Content())

	def IsWord()
		oFinder = new stzStringFinder(@oString)
		if oFinder.Contains(" ") or @oString.IsEmpty()
			return 0
		else
			return 1
		ok

	  #===============================#
	 #     LEADING/TRAILING CHARS    #
	#===============================#

	def HasLeadingChars()
		if @oString.NumberOfChars() < 2
			return 0
		ok

		pH = @oString.Engine()
		cFirst = StzEngineStringCharAtToString(pH, 1)
		cSecond = StzEngineStringCharAtToString(pH, 2)
		return cFirst = cSecond

	def HasTrailingChars()
		nLen = @oString.NumberOfChars()
		if nLen < 2
			return 0
		ok

		pH = @oString.Engine()
		cLast = StzEngineStringCharAtToString(pH, nLen)
		cPrev = StzEngineStringCharAtToString(pH, nLen - 1)
		return cLast = cPrev

	def HasLeadingAndTrailingChars()
		return This.HasLeadingChars() and This.HasTrailingChars()

	  #===============================#
	 #     TRIMMED                   #
	#===============================#

	def Trimmed()
		pH = StzEngineString(@oString.Content())
		pR = StzEngineStringTrimmed(pH)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		StzEngineStringFree(pH)
		return c

	def TrimmedLeft()
		pH = StzEngineString(@oString.Content())
		pR = StzEngineStringTrimLeft(pH)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		StzEngineStringFree(pH)
		return c

	def TrimmedRight()
		pH = StzEngineString(@oString.Content())
		pR = StzEngineStringTrimRight(pH)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		StzEngineStringFree(pH)
		return c
