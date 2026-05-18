#--------------------------------------------------------------#
#         SOFTANZA LIBRARY (V0.9) - STZSTRINGCHECKER           #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String checker -- type checking, content    #
#                  validation, palindrome, anagram, and         #
#                  structural checks.                           #
#                  Wraps stzString via composition.             #
#                  For aliases, use stzStringCheckerXT.         #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

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
		if @oString.NumberOfChars() < 2
			return 0
		ok

		cReversed = StzReverse(@oString.Content())

		bCase = @CaseSensitive(pCaseSensitive)
		if bCase = 0
			if StzCaseFold(@oString.Content()) = StzCaseFold(cReversed)
				return 1
			else
				return 0
			ok
		else
			if @oString.Content() = cReversed
				return 1
			else
				return 0
			ok
		ok

	def IsPalindrome()
		return This.IsPalindromeCS(1)

	  #===============================#
	 #     ANAGRAM                   #
	#===============================#

	def IsAnagramOfCS(pcOtherStr, pCaseSensitive)
		bCase = @CaseSensitive(pCaseSensitive)

		_cStr_ = @oString.Content()
		_cOther_ = pcOtherStr

		if bCase = 0
			_cStr_ = StzCaseFold(_cStr_)
			_cOther_ = StzCaseFold(pcOtherStr)
		ok

		_cInversed_ = StzReverse(_cOther_)

		if _cStr_ = _cInversed_
			return 1
		else
			return 0
		ok

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
		bCase = @CaseSensitive(pCaseSensitive)
		cReversed = StzReverse(@oString.Content())

		if bCase = 0
			return StzCaseFold(cReversed) = StzCaseFold(pcOtherStr)
		else
			return cReversed = pcOtherStr
		ok

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

		cFirst = substr(@oString.Content(), 1, 1)
		cSecond = substr(@oString.Content(), 2, 1)
		return cFirst = cSecond

	def HasTrailingChars()
		nLen = @oString.NumberOfChars()
		if nLen < 2
			return 0
		ok

		cLast = substr(@oString.Content(), nLen, 1)
		cPrev = substr(@oString.Content(), nLen - 1, 1)
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
