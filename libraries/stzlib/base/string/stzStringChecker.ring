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


class stzStringChecker from stzObject

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

	# TRUE if the string reads the same backward (a palindrome).
	def IsPalindromeCS(pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		pH = @oString.Engine()
		# Engine palindrome is always CS. For CI, casefold first.
		if _bCase_ = 0
			pFolded = StzEngineStringFoldcase(pH)
			_nResult_ = StzEngineStringIsPalindrome(pFolded)
			StzEngineStringFree(pFolded)
		else
			_nResult_ = StzEngineStringIsPalindrome(pH)
		ok
		return _nResult_

	def IsPalindrome()
		return This.IsPalindromeCS(1)

	  #===============================#
	 #     ANAGRAM                   #
	#===============================#

	# TRUE if the string is an anagram of the given one (same chars,
	# reordered).
	def IsAnagramOfCS(pcOtherStr, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		pH = @oString.Engine()
		pH2 = StzEngineString(pcOtherStr)
		_nResult_ = StzEngineStringIsAnagramCS(pH, pH2, _bCase_)
		StzEngineStringFree(pH2)
		return _nResult_

	def IsAnagramOf(pcOtherStr)
		return This.IsAnagramOfCS(pcOtherStr, 1)

	  #===============================#
	 #     CASE CHECKING             #
	#===============================#

	# TRUE if the string is in UPPER CASE.
	def IsUppercase()
		return StzIsUpper(@oString.Content())

	# TRUE if the string is in lower case.
	def IsLowercase()
		return StzIsLower(@oString.Content())

	def IsCapitalcase()
		_cStr_ = @oString.Content()
		if StzLen(_cStr_) < 1
			return 0
		ok

		_cFirst_ = StzLeft(_cStr_, 1)
		if _cFirst_ = StzUpper(_cFirst_) and StzLen(_cStr_) > 1
			pH = StzEngineString(_cStr_)
			pRest = StzEngineStringSlice(pH, 2, StzLen(_cStr_) - 1)
			_cRest_ = StzEngineStringData(pRest)
			StzEngineStringFree(pRest)
			StzEngineStringFree(pH)
			return _cRest_ = StzLower(_cRest_)
		ok
		return 0

	# TRUE if the string mixes upper and lower case.
	def IsHybridcase()
		pH = StzEngineString(@oString.Content())
		_nResult_ = StzEngineStringHasMixedCase(pH)
		StzEngineStringFree(pH)
		return _nResult_

	  #===============================#
	 #     CONTENT COMPOSITION       #
	#===============================#

	# TRUE if the string is made of spaces only.
	def ContainsOnlySpaces()
		pH = StzEngineString(@oString.Content())
		_n_ = StzEngineStringIsWhitespace(pH)
		StzEngineStringFree(pH)
		return _n_

	# TRUE if the string is made of letters only.
	def ContainsOnlyLetters()
		return StzIsAlpha(@oString.Content())

	# TRUE if the string is made of number chars only.
	def ContainsOnlyNumbers()
		pH = StzEngineString(@oString.Content())
		_n_ = StzEngineStringIsNumericString(pH)
		StzEngineStringFree(pH)
		return _n_

	# TRUE if the string is made of digits only.
	def ContainsOnlyDigits()
		return StzIsDigit(@oString.Content())

	# TRUE if the string is made of letters and numbers only.
	def ContainsOnlyLettersAndNumbers()
		pH = StzEngineString(@oString.Content())
		_n_ = StzEngineStringIsAlphanumeric(pH)
		StzEngineStringFree(pH)
		return _n_

	  #===============================#
	 #     IS MADE OF                #
	#===============================#

	def IsMadeOfCS(acSubStr, pCaseSensitive)
		if CheckingParams()
			if NOT (isList(acSubStr) and @IsListOfStrings(acSubStr))
				StzRaise("Incorrect param type! acSubStr must be a list of strings.")
			ok
		ok

		_cCopy_ = @oString.Content()
		_nLen_ = len(acSubStr)

		# The ORIGINAL requires every listed part to be USED (an
		# unused extra token -> FALSE), then full coverage.
		for i = 1 to _nLen_
			if NOT @oString.ContainsCS(acSubStr[i], pCaseSensitive)
				return 0
			ok
			_cCopy_ = @ReplaceCS(_cCopy_, acSubStr[i], "", pCaseSensitive)
		next

		if _cCopy_ = ""
			return 1
		else
			return 0
		ok

	def IsMadeOf(acSubStr)
		return This.IsMadeOfCS(acSubStr, 1)

	# TRUE if the string is made of the given char only.
	def IsMadeOfCharCS(_c_, pCaseSensitive)
		if isString(_c_) and @IsChar(_c_)
			return This.IsMadeOfCS([ _c_ ], pCaseSensitive)
		else
			return 0
		ok

	def IsMadeOfChar(_c_)
		return This.IsMadeOfCharCS(_c_, 1)

	# TRUE if the string is made only of (some of) the given
	# substrings.
	# TRUE if the string is made only of (some of) the given
	# substrings.
	def IsMadeOfSomeCS(acSubStr, pCaseSensitive)
		if CheckingParams()
			if NOT (isList(acSubStr) and @IsListOfStrings(acSubStr))
				StzRaise("Incorrect param type! acSubStr must be a list of strings.")
			ok
		ok

		_cCopy_ = @oString.Content()
		_nLen_ = len(acSubStr)

		for i = 1 to _nLen_
			_oFinder_ = new stzStringFinder(_cCopy_)
			if _oFinder_.ContainsCS(acSubStr[i], pCaseSensitive)
				_cCopy_ = @ReplaceCS(_cCopy_, acSubStr[i], "", pCaseSensitive)
			ok
		next

		if _cCopy_ = ""
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
			_cFirst_ = @oString.NthChar(1)
			if _cFirst_ = "+" or _cFirst_ = "-"
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

	def RepresentsRealNumber()
		# Real-number == any number per the monolith convention.
		return This.RepresentsNumber()

	def RepresentsSignedNumber()
		# Number AND first char is + or -.
		if This.RepresentsNumber()
			_cRsnFirst_ = @oString.NthChar(1)
			if _cRsnFirst_ = "+" or _cRsnFirst_ = "-"
				return 1
			ok
		ok
		return 0

	def RepresentsUnsignedNumber()
		if This.RepresentsNumber() and NOT This.RepresentsSignedNumber()
			return 1
		ok
		return 0

	# TRUE if the string holds a numeric literal.
	def IsNumberInString()
		# Alias for RepresentsNumber -- "is the string a number literal?"
		return This.RepresentsNumber()

	def IsListInString()
		# Minimal heuristic: trimmed content starts with '[' and ends
		# with ']'. The monolith had a deeper eval-based check that
		# also accepted short-form ranges like '"a" : "d"'; the simple
		# bracket check covers the CSV-parser use case (decide if a
		# field value should be eval'd back into a Ring list).
		_cIisContent_ = @oString.Content()
		_cIisTrim_ = trim(_cIisContent_)
		if len(_cIisTrim_) < 2 return 0 ok
		if _cIisTrim_[1] = "[" and _cIisTrim_[len(_cIisTrim_)] = "]"
			return 1
		ok
		return 0

	def RepresentsCalculableNumber()
		# Ring uses double precision; any number that lexes is calculable
		# within the usual range. Delegating to RepresentsNumber matches
		# the practical intent (the elaborate digit-count test in the
		# monolith was for arbitrary-precision contexts that arent in
		# play here).
		return This.RepresentsNumber()

	def RepresentsDecimalNumber()
		pH = @oString.Engine()
		return StzEngineStringIsFloat(pH)

		def RepresentsNumberInDecimalForm()
			return This.RepresentsDecimalNumber()

	def RepresentsBinaryNumber()
		# Requires 0b/0B prefix per Softanza convention
		_cContent_ = @oString.Content()
		if StzLen(_cContent_) < 3
			return 0
		ok
		_cPrefix_ = StzLeft(_cContent_, 2)
		if _cPrefix_ != "0b" and _cPrefix_ != "0B"
			return 0
		ok
		pH = @oString.Engine()
		return StzEngineStringIsBinaryString(pH)

		def RepresentsNumberInBinaryForm()
			return This.RepresentsBinaryNumber()

	def RepresentsHexNumber()
		# Requires 0x/0X prefix per Softanza convention
		_cContent_ = @oString.Content()
		if StzLen(_cContent_) < 3
			return 0
		ok
		_cPrefix_ = StzLeft(_cContent_, 2)
		if _cPrefix_ != "0x" and _cPrefix_ != "0X"
			return 0
		ok
		pH = @oString.Engine()
		return StzEngineStringIsHexString(pH)

		def RepresentsNumberInHexForm()
			return This.RepresentsHexNumber()

	def RepresentsNumberInUnicodeHexForm()
		# Checks for "U+XXXX" format
		_cContent_ = @oString.Content()
		_nLen_ = StzLen(_cContent_)
		if _nLen_ < 3
			return 0
		ok
		_cPrefix_ = StzUpper(StzLeft(_cContent_, 2))
		if _cPrefix_ != "U+"
			return 0
		ok
		_cHexPart_ = StzRight(_cContent_, _nLen_ - 2)
		return StringRepresentsNumberInHexForm("0x" + _cHexPart_)

	def IsCharName()
		# Engine SQLite lookup — checks if this string is a valid Unicode char name
		return StzUnicodeContainsName(This.Content())

		def IsACharName()
			return This.IsCharName()

	  #===============================#
	 #     REVERSED COPY             #
	#===============================#

	# TRUE if the string is the reverse of the given one.
	def IsReversedCopyOfCS(pcOtherStr, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		pH = @oString.Engine()
		pRev = StzEngineStringReverse(pH)
		pH2 = StzEngineString(pcOtherStr)
		_nResult_ = StzEngineStringEqualsCS(pRev, pH2, _bCase_)
		StzEngineStringFree(pRev)
		StzEngineStringFree(pH2)
		return _nResult_

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

	# TRUE if the string is a single letter.
	def IsLetter()
		if @oString.NumberOfChars() != 1
			return 0
		ok
		return isAlpha(@oString.Content())

	# TRUE if the string is a single digit.
	def IsADigit()
		if @oString.NumberOfChars() != 1
			return 0
		ok
		return isDigit(@oString.Content())

	# TRUE if the string is a single word.
	def IsWord()
		if @oString.IsEmpty()
			return 0
		ok
		pH = @oString.Engine()
		return StzEngineStringIsWord(pH)

	  #===============================#
	 #     CHAR SORT ORDER           #
	#===============================#

	# TRUE if the chars are in ascending order.
	def IsCharsSortedAscending()
		pH = @oString.Engine()
		return StzEngineStringIsCharsSortedAsc(pH)

		def IsCharsSortedAsc()
			return This.IsCharsSortedAscending()

	# TRUE if the chars are in descending order.
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
		_cFirst_ = StzEngineStringCharAtToString(pH, 1)
		_cSecond_ = StzEngineStringCharAtToString(pH, 2)
		return _cFirst_ = _cSecond_

	def HasTrailingChars()
		_nLen_ = @oString.NumberOfChars()
		if _nLen_ < 2
			return 0
		ok

		pH = @oString.Engine()
		_cLast_ = StzEngineStringCharAtToString(pH, _nLen_)
		_cPrev_ = StzEngineStringCharAtToString(pH, _nLen_ - 1)
		return _cLast_ = _cPrev_

	def HasLeadingAndTrailingChars()
		return This.HasLeadingChars() and This.HasTrailingChars()

	  #===============================#
	 #     TRIMMED                   #
	#===============================#

	def Trimmed()
		pH = StzEngineString(@oString.Content())
		pR = StzEngineStringTrimmed(pH)
		_c_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		StzEngineStringFree(pH)
		return _c_

	def TrimmedLeft()
		pH = StzEngineString(@oString.Content())
		pR = StzEngineStringTrimLeft(pH)
		_c_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		StzEngineStringFree(pH)
		return _c_

	def TrimmedRight()
		pH = StzEngineString(@oString.Content())
		pR = StzEngineStringTrimRight(pH)
		_c_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		StzEngineStringFree(pH)
		return _c_

	  #===============================#
	 #     ADDITIONAL CHECKS          #
	#===============================#

	# TRUE if the string is empty or whitespace only.
	def IsBlank()
		pH = @oString.Engine()
		return StzEngineStringIsBlank(pH)

	# TRUE if the string is written in Title Case.
	def IsTitlecase()
		pH = @oString.Engine()
		return StzEngineStringIsTitleCase(pH)

	def RepresentsOctalNumber()
		# Requires 0o/0O prefix per Softanza convention
		_cContent_ = @oString.Content()
		if StzLen(_cContent_) < 3
			return 0
		ok
		_cPrefix_ = StzLeft(_cContent_, 2)
		if _cPrefix_ != "0o" and _cPrefix_ != "0O"
			return 0
		ok
		pH = @oString.Engine()
		return StzEngineStringIsOctalString(pH)

		def RepresentsNumberInOctalForm()
			return This.RepresentsOctalNumber()

	# TRUE if the string is a valid identifier (letter or underscore
	# first, then letters, digits, underscores).
	def IsIdentifier()
		pH = @oString.Engine()
		return StzEngineStringIsIdentifier(pH)

	# TRUE if the string uses every letter of the alphabet (a
	# pangram).
	# TRUE if the string uses every letter of the alphabet (a
	# pangram).
	def IsPangram()
		pH = @oString.Engine()
		return StzEngineStringIsPangram(pH)

	# TRUE if no char repeats in the string (an isogram).
	def IsIsogram()
		pH = @oString.Engine()
		return StzEngineStringIsIsogram(pH)

	# TRUE if the brackets and parentheses in the string are
	# balanced.
	# TRUE if the brackets and parentheses in the string are
	# balanced.
	def IsBalanced()
		pH = @oString.Engine()
		return StzEngineStringIsBalanced(pH)

	# TRUE if the string looks like an email address.
	def IsEmailLike()
		pH = @oString.Engine()
		return StzEngineStringIsEmailLike(pH)

	# TRUE if the string looks like a URL.
	def IsUrlLike()
		pH = @oString.Engine()
		return StzEngineStringIsUrlLike(pH)

	# TRUE if the string is written in camelCase.
	def IsCamelCase()
		pH = @oString.Engine()
		return StzEngineStringIsCamelCase(pH)

	# TRUE if the string is written in snake_case.
	def IsSnakeCase()
		pH = @oString.Engine()
		return StzEngineStringIsSnakeCase(pH)

	# TRUE if the string is written in kebab-case.
	def IsKebabCase()
		pH = @oString.Engine()
		return StzEngineStringIsKebabCase(pH)

	# TRUE if the WORD sequence reads the same backward.
	def IsPalindromeWords()
		pH = @oString.Engine()
		return StzEngineStringIsPalindromeWords(pH)

	# TRUE if the string contains Latin chars.
	def ContainsLatin()
		pH = @oString.Engine()
		return StzEngineStringContainsLatin(pH)

	# TRUE if the string contains Arabic chars.
	def ContainsArabic()
		pH = @oString.Engine()
		return StzEngineStringContainsArabic(pH)

	  #===============================#
	 #     CONTAINS CHAR / ANY / ALL #
	#===============================#

	# TRUE if the string contains the given char.
	def ContainsCharCS(pcChar, pCaseSensitive)
		pH = @oString.Engine()
		pHChar = StzEngineString(pcChar)
		_nCp_ = StzEngineStringCharAt(pHChar, 1)
		StzEngineStringFree(pHChar)
		return StzEngineStringContainsChar(pH, _nCp_)

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

	# TRUE if the string is made of control chars.
	def IsControl()
		pH = @oString.Engine()
		return StzEngineStringIsControl(pH)

	def HasMark()
		pH = @oString.Engine()
		return StzEngineStringHasMark(pH)

	def CharIsControlAt(_n_)
		pH = @oString.Engine()
		return StzEngineStringCharIsControlAt(pH, _n_)

	def CharIsMarkAt(_n_)
		pH = @oString.Engine()
		return StzEngineStringCharIsMarkAt(pH, _n_)

	def CharIsSpaceAt(_n_)
		pH = @oString.Engine()
		return StzEngineStringCharIsSpaceAt(pH, _n_)

	  #===============================#
	 #     ONLY MARKS / CONTROLS     #
	#===============================#

	def OnlyMarks()
		pH = @oString.Engine()
		pR = StzEngineStringOnlyMarks(pH)
		_c_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		return _c_

	def OnlyControls()
		pH = @oString.Engine()
		pR = StzEngineStringOnlyControls(pH)
		_c_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		return _c_

	def OnlyLatinLetters()
		pH = @oString.Engine()
		pR = StzEngineStringOnlyLatinLetters(pH)
		_c_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		return _c_

	  #===============================#
	 #     NUMERIC / ALPHA CHECKS    #
	#===============================#

	# TRUE if the string is numeric.
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

	# TRUE if the string matches the given regex pattern.
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
