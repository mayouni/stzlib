#--------------------------------------------------------------#
#         SOFTANZA LIBRARY (V0.9) - STZSTRINGCHECKER           #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String checker subclass -- type checking,   #
#                  content validation, palindrome, anagram,     #
#                  composition, and structural checks.           #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////////
 ///   FUNCTIONS   ///
/////////////////////

func StzStringCheckerQ(str)
	return new stzStringChecker(str)


  /////////////////
 ///   CLASS   ///
/////////////////

class stzStringChecker from stzStringCore

	  #===============================#
	 #     PALINDROME                #
	#===============================#

	def IsPalindromeCS(pCaseSensitive)
		if This.NumberOfChars() < 2
			return 0
		ok

		cReversed = ring_reverse(This.Content())

		bCase = @CaseSensitive(pCaseSensitive)
		if bCase = 0
			if lower(This.Content()) = lower(cReversed)
				return 1
			else
				return 0
			ok
		else
			if This.Content() = cReversed
				return 1
			else
				return 0
			ok
		ok

		def IsMirroredCS(pCaseSensitive)
			return This.IsPalindromeCS(pCaseSensitive)

	def IsPalindrome()
		return This.IsPalindromeCS(1)

		def IsMirrored()
			return This.IsPalindrome()

	  #===============================#
	 #     ANAGRAM                   #
	#===============================#

	def IsAnagramOfCS(pcOtherStr, pCaseSensitive)
		bCase = @CaseSensitive(pCaseSensitive)

		_cStr_ = This.Content()
		_cOther_ = pcOtherStr

		if bCase = 0
			_cStr_ = lower(_cStr_)
			_cOther_ = lower(pcOtherStr)
		ok

		_cInversed_ = ring_reverse(_cOther_)

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
		return This.Content() = upper(This.Content())

	def IsLowercase()
		return This.Content() = lower(This.Content())

	def IsCapitalcase()
		if This.NumberOfChars() < 1
			return 0
		ok

		cFirst = substr(This.Content(), 1, 1)
		if cFirst = upper(cFirst) and This.NumberOfChars() > 1
			cRest = substr(This.Content(), 2)
			return cRest = lower(cRest)
		ok
		return 0

	def IsHybridcase()
		bHasUpper = 0
		bHasLower = 0
		cContent = This.Content()
		nLen = len(cContent)

		for i = 1 to nLen
			c = substr(cContent, i, 1)
			if c != upper(c)
				bHasLower = 1
			ok
			if c != lower(c)
				bHasUpper = 1
			ok
			if bHasUpper and bHasLower
				return 1
			ok
		next

		return 0

		def IsMixedcase()
			return This.IsHybridcase()

	  #===============================#
	 #     CONTENT COMPOSITION       #
	#===============================#

	def ContainsOnlySpaces()
		cTrimmed = trim(This.Content())
		if cTrimmed = ""
			return 1
		else
			return 0
		ok

		def IsMadeOfSpaces()
			return This.ContainsOnlySpaces()

		def IsBlank()
			return This.ContainsOnlySpaces()

	def ContainsOnlyLetters()
		cContent = This.Content()
		nLen = len(cContent)

		for i = 1 to nLen
			c = substr(cContent, i, 1)
			if NOT isAlpha(c)
				return 0
			ok
		next
		return 1

		def IsAlpha()
			return This.ContainsOnlyLetters()

		def IsAlphabetic()
			return This.ContainsOnlyLetters()

		def IsMadeOfLetters()
			return This.ContainsOnlyLetters()

	def ContainsOnlyNumbers()
		cContent = This.Content()
		nLen = len(cContent)

		for i = 1 to nLen
			c = substr(cContent, i, 1)
			if NOT isDigit(c) and c != "." and c != "-" and c != "+"
				return 0
			ok
		next
		return 1

		def IsMadeOfNumbers()
			return This.ContainsOnlyNumbers()

		def IsNumeric()
			return This.ContainsOnlyNumbers()

	def ContainsOnlyDigits()
		cContent = This.Content()
		nLen = len(cContent)

		for i = 1 to nLen
			c = substr(cContent, i, 1)
			if NOT isDigit(c)
				return 0
			ok
		next
		return 1

		def IsDigit()
			return This.ContainsOnlyDigits()

		def IsMadeOfDigits()
			return This.ContainsOnlyDigits()

	def ContainsOnlyLettersAndNumbers()
		cContent = This.Content()
		nLen = len(cContent)

		for i = 1 to nLen
			c = substr(cContent, i, 1)
			if NOT isAlpha(c) and NOT isDigit(c)
				return 0
			ok
		next
		return 1

		def IsAlphaNum()
			return This.ContainsOnlyLettersAndNumbers()

		def IsAlphaNumeric()
			return This.ContainsOnlyLettersAndNumbers()

		def IsAlNum()
			return This.ContainsOnlyLettersAndNumbers()

		def IsMadeOfLettersAndNumbers()
			return This.ContainsOnlyLettersAndNumbers()

	  #===============================#
	 #     IS MADE OF                #
	#===============================#

	def IsMadeOfCS(acSubStr, pCaseSensitive)
		if CheckingParams()
			if NOT (isList(acSubStr) and @IsListOfStrings(acSubStr))
				StzRaise("Incorrect param type! acSubStr must be a list of strings.")
			ok
		ok

		cCopy = This.Content()
		nLen = len(acSubStr)

		for i = 1 to nLen
			cCopy = @ReplaceCS(cCopy, acSubStr[i], "", pCaseSensitive)
		next

		if cCopy = ""
			return 1
		else
			return 0
		ok

		def IsMadeOfTheseCS(acSubStr, pCaseSensitive)
			return This.IsMadeOfCS(acSubStr, pCaseSensitive)

	def IsMadeOf(acSubStr)
		return This.IsMadeOfCS(acSubStr, 1)

		def IsMadeOfThese(acSubStr)
			return This.IsMadeOf(acSubStr)

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

		cCopy = This.Content()
		nLen = len(acSubStr)

		for i = 1 to nLen
			oFinder = StzStringFinderQ(cCopy)
			if oFinder.ContainsCS(acSubStr[i], pCaseSensitive)
				cCopy = @ReplaceCS(cCopy, acSubStr[i], "", pCaseSensitive)
			ok
		next

		if cCopy = ""
			return 1
		else
			return 0
		ok

		def IsMadeOfSomeOfTheseCS(acSubStr, pCaseSensitive)
			return This.IsMadeOfSomeCS(acSubStr, pCaseSensitive)

	def IsMadeOfSome(acSubStr)
		return This.IsMadeOfSomeCS(acSubStr, 1)

		def IsMadeOfSomeOfThese(acSubStr)
			return This.IsMadeOfSome(acSubStr)

	  #===============================#
	 #     NUMBER REPRESENTATION     #
	#===============================#

	def RepresentsInteger()
		cContent = This.Content()
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

		def IsInteger()
			return This.RepresentsInteger()

		def IsAnInteger()
			return This.RepresentsInteger()

	def RepresentsSignedInteger()
		if This.RepresentsInteger()
			c1 = substr(This.Content(), 1, 1)
			if c1 = "+" or c1 = "-"
				return 1
			ok
		ok
		return 0

		def IsSignedInteger()
			return This.RepresentsSignedInteger()

	def RepresentsUnsignedInteger()
		if This.RepresentsInteger() and NOT This.RepresentsSignedInteger()
			return 1
		else
			return 0
		ok

		def IsUnsignedInteger()
			return This.RepresentsUnsignedInteger()

	def RepresentsNumber()
		cContent = This.Content()
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

		def IsANumber()
			return This.RepresentsNumber()

		def IsNumberInString()
			return This.RepresentsNumber()

	def RepresentsDecimalNumber()
		if This.RepresentsNumber()
			oFinder = StzStringFinderQ(This.Content())
			if oFinder.Contains(".")
				return 1
			ok
		ok
		return 0

		def IsDecimalNumber()
			return This.RepresentsDecimalNumber()

	def RepresentsBinaryNumber()
		cContent = This.Content()
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

		def IsBinaryNumber()
			return This.RepresentsBinaryNumber()

	def RepresentsHexNumber()
		cContent = This.Content()
		nLen = len(cContent)

		if nLen < 3
			return 0
		ok

		if NOT (substr(cContent, 1, 2) = "0x" or substr(cContent, 1, 2) = "0X")
			return 0
		ok

		for i = 3 to nLen
			c = lower(substr(cContent, i, 1))
			if NOT isDigit(c) and NOT (c >= "a" and c <= "f")
				return 0
			ok
		next
		return 1

		def IsHexNumber()
			return This.RepresentsHexNumber()

	  #===============================#
	 #     REVERSED COPY             #
	#===============================#

	def IsReversedCopyOfCS(pcOtherStr, pCaseSensitive)
		bCase = @CaseSensitive(pCaseSensitive)
		cReversed = ring_reverse(This.Content())

		if bCase = 0
			return lower(cReversed) = lower(pcOtherStr)
		else
			return cReversed = pcOtherStr
		ok

	def IsReversedCopyOf(pcOtherStr)
		return This.IsReversedCopyOfCS(pcOtherStr, 1)

	  #===============================#
	 #     REVERSED                  #
	#===============================#

	def Reversed()
		return ring_reverse(This.Content())

	  #===============================#
	 #     STRUCTURAL CHECKS         #
	#===============================#

	def IsChar()
		return This.NumberOfChars() = 1

		def IsAChar()
			return This.IsChar()

	def IsLetter()
		if This.NumberOfChars() != 1
			return 0
		ok
		return isAlpha(This.Content())

		def IsALetter()
			return This.IsLetter()

	def IsADigit()
		if This.NumberOfChars() != 1
			return 0
		ok
		return isDigit(This.Content())

	def IsWord()
		oFinder = StzStringFinderQ(This.Content())
		if oFinder.Contains(" ") or This.IsEmpty()
			return 0
		else
			return 1
		ok

	def IsAWord()
		return This.IsWord()

	  #===============================#
	 #     LEADING/TRAILING CHARS    #
	#===============================#

	def HasLeadingChars()
		if This.NumberOfChars() < 2
			return 0
		ok

		cFirst = substr(This.Content(), 1, 1)
		cSecond = substr(This.Content(), 2, 1)
		return cFirst = cSecond

	def HasTrailingChars()
		nLen = This.NumberOfChars()
		if nLen < 2
			return 0
		ok

		cLast = substr(This.Content(), nLen, 1)
		cPrev = substr(This.Content(), nLen - 1, 1)
		return cLast = cPrev

	def HasLeadingAndTrailingChars()
		return This.HasLeadingChars() and This.HasTrailingChars()

	  #===============================#
	 #     TRIMMED                   #
	#===============================#

	def Trimmed()
		return trim(This.Content())

	def TrimmedLeft()
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
			return ""
		ok
		return substr(cContent, nStart)

	def TrimmedRight()
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
			return ""
		ok
		return substr(cContent, 1, nEnd)

