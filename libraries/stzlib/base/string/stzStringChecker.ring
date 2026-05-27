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
		pH = @oString.Engine()
		return StzEngineStringIsNumericString(pH)

	def RepresentsSignedInteger()
		if This.RepresentsInteger()
			cFirst = @oString.NthChar(1)
			if cFirst = "+" or cFirst = "-"
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
		pH = @oString.Engine()
		if StzEngineStringIsNumericString(pH)
			return 1
		ok
		return StzEngineStringIsFloat(pH)

	def RepresentsDecimalNumber()
		pH = @oString.Engine()
		return StzEngineStringIsFloat(pH)

	def RepresentsBinaryNumber()
		# Requires 0b/0B prefix per Softanza convention
		cContent = @oString.Content()
		if StzLen(cContent) < 3
			return 0
		ok
		cPrefix = StzLeft(cContent, 2)
		if cPrefix != "0b" and cPrefix != "0B"
			return 0
		ok
		pH = @oString.Engine()
		return StzEngineStringIsBinaryString(pH)

	def RepresentsHexNumber()
		# Requires 0x/0X prefix per Softanza convention
		cContent = @oString.Content()
		if StzLen(cContent) < 3
			return 0
		ok
		cPrefix = StzLeft(cContent, 2)
		if cPrefix != "0x" and cPrefix != "0X"
			return 0
		ok
		pH = @oString.Engine()
		return StzEngineStringIsHexString(pH)

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
		if @oString.IsEmpty()
			return 0
		ok
		pH = @oString.Engine()
		return StzEngineStringIsWord(pH)

	  #===============================#
	 #     CHAR SORT ORDER           #
	#===============================#

	def IsCharsSortedAscending()
		pH = @oString.Engine()
		return StzEngineStringIsCharsSortedAsc(pH)

		def IsCharsSortedAsc()
			return This.IsCharsSortedAscending()

	def IsCharsSortedDescending()
		pH = @oString.Engine()
		return StzEngineStringIsCharsSortedDesc(pH)

		def IsCharsSortedDesc()
			return This.IsCharsSortedDescending()

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

	  #===============================#
	 #     ADDITIONAL CHECKS          #
	#===============================#

	def IsBlank()
		pH = @oString.Engine()
		return StzEngineStringIsBlank(pH)

	def IsTitlecase()
		pH = @oString.Engine()
		return StzEngineStringIsTitleCase(pH)

	def RepresentsOctalNumber()
		# Requires 0o/0O prefix per Softanza convention
		cContent = @oString.Content()
		if StzLen(cContent) < 3
			return 0
		ok
		cPrefix = StzLeft(cContent, 2)
		if cPrefix != "0o" and cPrefix != "0O"
			return 0
		ok
		pH = @oString.Engine()
		return StzEngineStringIsOctalString(pH)

	def IsIdentifier()
		pH = @oString.Engine()
		return StzEngineStringIsIdentifier(pH)

	def IsPangram()
		pH = @oString.Engine()
		return StzEngineStringIsPangram(pH)

	def IsIsogram()
		pH = @oString.Engine()
		return StzEngineStringIsIsogram(pH)

	def IsBalanced()
		pH = @oString.Engine()
		return StzEngineStringIsBalanced(pH)

	def IsEmailLike()
		pH = @oString.Engine()
		return StzEngineStringIsEmailLike(pH)

	def IsUrlLike()
		pH = @oString.Engine()
		return StzEngineStringIsUrlLike(pH)

	def IsCamelCase()
		pH = @oString.Engine()
		return StzEngineStringIsCamelCase(pH)

	def IsSnakeCase()
		pH = @oString.Engine()
		return StzEngineStringIsSnakeCase(pH)

	def IsKebabCase()
		pH = @oString.Engine()
		return StzEngineStringIsKebabCase(pH)

	def IsPalindromeWords()
		pH = @oString.Engine()
		return StzEngineStringIsPalindromeWords(pH)

	def ContainsLatin()
		pH = @oString.Engine()
		return StzEngineStringContainsLatin(pH)

	def ContainsArabic()
		pH = @oString.Engine()
		return StzEngineStringContainsArabic(pH)

	  #===============================#
	 #     CONTAINS CHAR / ANY / ALL #
	#===============================#

	def ContainsCharCS(pcChar, pCaseSensitive)
		pH = @oString.Engine()
		pHChar = StzEngineString(pcChar)
		nCp = StzEngineStringCharAt(pHChar, 1)
		StzEngineStringFree(pHChar)
		return StzEngineStringContainsChar(pH, nCp)

	def ContainsChar(pcChar)
		return This.ContainsCharCS(pcChar, 1)

	def ContainsAnyOfCharsCS(pcChars, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		pH = @oString.Engine()
		return StzEngineStringContainsAnyOfCS(pH, pcChars, _bCase_)

	def ContainsAnyOfChars(pcChars)
		return This.ContainsAnyOfCharsCS(pcChars, 1)

	def ContainsAllOfCharsCS(pcChars, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		pH = @oString.Engine()
		return StzEngineStringContainsAllOfCS(pH, pcChars, _bCase_)

	def ContainsAllOfChars(pcChars)
		return This.ContainsAllOfCharsCS(pcChars, 1)

	def ContainsOnlyCharsCS(pcChars, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		pH = @oString.Engine()
		return StzEngineStringContainsOnlyCS(pH, pcChars, _bCase_)

	def ContainsOnlyChars(pcChars)
		return This.ContainsOnlyCharsCS(pcChars, 1)

	  #===============================#
	 #     CONTROL / MARK CHECKS     #
	#===============================#

	def IsControl()
		pH = @oString.Engine()
		return StzEngineStringIsControl(pH)

	def HasMark()
		pH = @oString.Engine()
		return StzEngineStringHasMark(pH)

	def CharIsControlAt(n)
		pH = @oString.Engine()
		return StzEngineStringCharIsControlAt(pH, n)

	def CharIsMarkAt(n)
		pH = @oString.Engine()
		return StzEngineStringCharIsMarkAt(pH, n)

	def CharIsSpaceAt(n)
		pH = @oString.Engine()
		return StzEngineStringCharIsSpaceAt(pH, n)

	  #===============================#
	 #     ONLY MARKS / CONTROLS     #
	#===============================#

	def OnlyMarks()
		pH = @oString.Engine()
		pR = StzEngineStringOnlyMarks(pH)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		return c

	def OnlyControls()
		pH = @oString.Engine()
		pR = StzEngineStringOnlyControls(pH)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		return c

	def OnlyLatinLetters()
		pH = @oString.Engine()
		pR = StzEngineStringOnlyLatinLetters(pH)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		return c

	  #===============================#
	 #     NUMERIC / ALPHA CHECKS    #
	#===============================#

	def IsNumericString()
		pH = @oString.Engine()
		return StzEngineStringIsNumeric(pH)

		def IsANumber()
			return This.IsNumericString()

	def IsAlphaString()
		pH = @oString.Engine()
		return StzEngineStringIsAlpha(pH)

		def IsAllLetters()
			return This.IsAlphaString()

	  #===============================#
	 #     REGEX MATCH CHECK         #
	#===============================#

	def MatchesRegex(pcPattern)
		pH = @oString.Engine()
		return StzEngineStringRegexIsMatch(pH, pcPattern, 0)

		def IsMatchedByRegex(pcPattern)
			return This.MatchesRegex(pcPattern)

	def MatchesRegexCS(pcPattern, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		_nFlags_ = 0
		if _bCase_ = 0
			_nFlags_ = 1
		ok
		pH = @oString.Engine()
		return StzEngineStringRegexIsMatch(pH, pcPattern, _nFlags_)

		def IsMatchedByRegexCS(pcPattern, pCaseSensitive)
			return This.MatchesRegexCS(pcPattern, pCaseSensitive)
