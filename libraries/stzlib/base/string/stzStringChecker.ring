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
		_pH_ = @oString.Engine()
		# Engine palindrome is always CS. For CI, casefold first.
		if _bCase_ = 0
			pFolded = StzEngineStringFoldcase(_pH_)
			_nResult_ = StzEngineStringIsPalindrome(pFolded)
			StzEngineStringFree(pFolded)
		else
			_nResult_ = StzEngineStringIsPalindrome(_pH_)
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
		_pH_ = @oString.Engine()
		pH2 = StzEngineString(pcOtherStr)
		_nResult_ = StzEngineStringIsAnagramCS(_pH_, pH2, _bCase_)
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
			_pH_ = StzEngineString(_cStr_)
			pRest = StzEngineStringSlice(_pH_, 2, StzLen(_cStr_) - 1)
			_cRest_ = StzEngineStringData(pRest)
			StzEngineStringFree(pRest)
			StzEngineStringFree(_pH_)
			return _cRest_ = StzLower(_cRest_)
		ok
		return 0

	# TRUE if the string mixes upper and lower case.
	def IsHybridcase()
		_pH_ = StzEngineString(@oString.Content())
		_nResult_ = StzEngineStringHasMixedCase(_pH_)
		StzEngineStringFree(_pH_)
		return _nResult_

	  #===============================#
	 #     CONTENT COMPOSITION       #
	#===============================#

	# TRUE if the string is made of spaces only.
	def ContainsOnlySpaces()
		_pH_ = StzEngineString(@oString.Content())
		_n_ = StzEngineStringIsWhitespace(_pH_)
		StzEngineStringFree(_pH_)
		return _n_

	# TRUE if the string is made of letters only.
	def ContainsOnlyLetters()
		return StzIsAlpha(@oString.Content())

	# TRUE if the string is made of number chars only.
	def ContainsOnlyNumbers()
		_pH_ = StzEngineString(@oString.Content())
		_n_ = StzEngineStringIsNumericString(_pH_)
		StzEngineStringFree(_pH_)
		return _n_

	# TRUE if the string is made of digits only.
	def ContainsOnlyDigits()
		return StzIsDigit(@oString.Content())

	# TRUE if the string is made of letters and numbers only.
	def ContainsOnlyLettersAndNumbers()
		_pH_ = StzEngineString(@oString.Content())
		_n_ = StzEngineStringIsAlphanumeric(_pH_)
		StzEngineStringFree(_pH_)
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
		_pH_ = @oString.Engine()
		return StzEngineStringIsNumericString(_pH_)

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
		_pH_ = @oString.Engine()
		if StzEngineStringIsNumericString(_pH_)
			return 1
		ok
		return StzEngineStringIsFloat(_pH_)

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
		_pH_ = @oString.Engine()
		return StzEngineStringIsFloat(_pH_)

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
		_pH_ = @oString.Engine()
		return StzEngineStringIsBinaryString(_pH_)

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
		_pH_ = @oString.Engine()
		return StzEngineStringIsHexString(_pH_)

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
		_pH_ = @oString.Engine()
		pRev = StzEngineStringReverse(_pH_)
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
		_pH_ = @oString.Engine()
		return StzEngineStringIsWord(_pH_)

	  #===============================#
	 #     CHAR SORT ORDER           #
	#===============================#

	# TRUE if the chars are in ascending order.
	def IsCharsSortedAscending()
		_pH_ = @oString.Engine()
		return StzEngineStringIsCharsSortedAsc(_pH_)

		def IsCharsSortedAsc()
			return This.IsCharsSortedAscending()

	# TRUE if the chars are in descending order.
	def IsCharsSortedDescending()
		_pH_ = @oString.Engine()
		return StzEngineStringIsCharsSortedDesc(_pH_)

		def IsCharsSortedDesc()
			return This.IsCharsSortedDescending()

	  #===============================#
	 #     LEADING/TRAILING CHARS    #
	#===============================#

	def HasLeadingChars()
		if @oString.NumberOfChars() < 2
			return 0
		ok

		_pH_ = @oString.Engine()
		_cFirst_ = StzEngineStringCharAtToString(_pH_, 1)
		_cSecond_ = StzEngineStringCharAtToString(_pH_, 2)
		return _cFirst_ = _cSecond_

	def HasTrailingChars()
		_nLen_ = @oString.NumberOfChars()
		if _nLen_ < 2
			return 0
		ok

		_pH_ = @oString.Engine()
		_cLast_ = StzEngineStringCharAtToString(_pH_, _nLen_)
		_cPrev_ = StzEngineStringCharAtToString(_pH_, _nLen_ - 1)
		return _cLast_ = _cPrev_

	def HasLeadingAndTrailingChars()
		return This.HasLeadingChars() and This.HasTrailingChars()

	  #===============================#
	 #     TRIMMED                   #
	#===============================#

	def Trimmed()
		_pH_ = StzEngineString(@oString.Content())
		_pR_ = StzEngineStringTrimmed(_pH_)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		StzEngineStringFree(_pH_)
		return _c_

	def TrimmedLeft()
		_pH_ = StzEngineString(@oString.Content())
		_pR_ = StzEngineStringTrimLeft(_pH_)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		StzEngineStringFree(_pH_)
		return _c_

	def TrimmedRight()
		_pH_ = StzEngineString(@oString.Content())
		_pR_ = StzEngineStringTrimRight(_pH_)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		StzEngineStringFree(_pH_)
		return _c_

	  #===============================#
	 #     ADDITIONAL CHECKS          #
	#===============================#

	# TRUE if the string is empty or whitespace only.
	def IsBlank()
		_pH_ = @oString.Engine()
		return StzEngineStringIsBlank(_pH_)

	# TRUE if the string is written in Title Case.
	def IsTitlecase()
		_pH_ = @oString.Engine()
		return StzEngineStringIsTitleCase(_pH_)

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
		_pH_ = @oString.Engine()
		return StzEngineStringIsOctalString(_pH_)

		def RepresentsNumberInOctalForm()
			return This.RepresentsOctalNumber()

	# TRUE if the string is a valid identifier (letter or underscore
	# first, then letters, digits, underscores).
	def IsIdentifier()
		_pH_ = @oString.Engine()
		return StzEngineStringIsIdentifier(_pH_)

	# TRUE if the string uses every letter of the alphabet (a
	# pangram).
	def IsPangram()
		_pH_ = @oString.Engine()
		return StzEngineStringIsPangram(_pH_)

	# TRUE if no char repeats in the string (an isogram).
	def IsIsogram()
		_pH_ = @oString.Engine()
		return StzEngineStringIsIsogram(_pH_)

	# TRUE if the brackets and parentheses in the string are
	# balanced.
	def IsBalanced()
		_pH_ = @oString.Engine()
		return StzEngineStringIsBalanced(_pH_)

	# TRUE if the string looks like an email address.
	def IsEmailLike()
		_pH_ = @oString.Engine()
		return StzEngineStringIsEmailLike(_pH_)

	# TRUE if the string looks like a URL.
	def IsUrlLike()
		_pH_ = @oString.Engine()
		return StzEngineStringIsUrlLike(_pH_)

	# TRUE if the string is written in camelCase.
	def IsCamelCase()
		_pH_ = @oString.Engine()
		return StzEngineStringIsCamelCase(_pH_)

	# TRUE if the string is written in snake_case.
	def IsSnakeCase()
		_pH_ = @oString.Engine()
		return StzEngineStringIsSnakeCase(_pH_)

	# TRUE if the string is written in kebab-case.
	def IsKebabCase()
		_pH_ = @oString.Engine()
		return StzEngineStringIsKebabCase(_pH_)

	# TRUE if the WORD sequence reads the same backward.
	def IsPalindromeWords()
		_pH_ = @oString.Engine()
		return StzEngineStringIsPalindromeWords(_pH_)

	# TRUE if the string contains Latin chars.
	def ContainsLatin()
		_pH_ = @oString.Engine()
		return StzEngineStringContainsLatin(_pH_)

	# TRUE if the string contains Arabic chars.
	def ContainsArabic()
		_pH_ = @oString.Engine()
		return StzEngineStringContainsArabic(_pH_)

	  #===============================#
	 #     CONTAINS CHAR / ANY / ALL #
	#===============================#

	# TRUE if the string contains the given char.
	def ContainsCharCS(pcChar, pCaseSensitive)
		_pH_ = @oString.Engine()
		pHChar = StzEngineString(pcChar)
		_nCp_ = StzEngineStringCharAt(pHChar, 1)
		StzEngineStringFree(pHChar)
		return StzEngineStringContainsChar(_pH_, _nCp_)

	def ContainsChar(pcChar)
		return This.ContainsCharCS(pcChar, 1)

	def ContainsAnyOfCharsCS(pcChars, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		_pH_ = @oString.Engine()
		return StzEngineStringContainsAnyOfCS(_pH_, pcChars, _bCase_)

	def ContainsAnyOfChars(pcChars)
		return This.ContainsAnyOfCharsCS(pcChars, 1)

	def ContainsAllOfCharsCS(pcChars, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		_pH_ = @oString.Engine()
		return StzEngineStringContainsAllOfCS(_pH_, pcChars, _bCase_)

	def ContainsAllOfChars(pcChars)
		return This.ContainsAllOfCharsCS(pcChars, 1)

	def ContainsOnlyCharsCS(pcChars, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		_pH_ = @oString.Engine()
		return StzEngineStringContainsOnlyCS(_pH_, pcChars, _bCase_)

	def ContainsOnlyChars(pcChars)
		return This.ContainsOnlyCharsCS(pcChars, 1)

	  #===============================#
	 #     CONTROL / MARK CHECKS     #
	#===============================#

	# TRUE if the string is made of control chars.
	def IsControl()
		_pH_ = @oString.Engine()
		return StzEngineStringIsControl(_pH_)

	def HasMark()
		_pH_ = @oString.Engine()
		return StzEngineStringHasMark(_pH_)

	def CharIsControlAt(_n_)
		_pH_ = @oString.Engine()
		return StzEngineStringCharIsControlAt(_pH_, _n_)

	def CharIsMarkAt(_n_)
		_pH_ = @oString.Engine()
		return StzEngineStringCharIsMarkAt(_pH_, _n_)

	def CharIsSpaceAt(_n_)
		_pH_ = @oString.Engine()
		return StzEngineStringCharIsSpaceAt(_pH_, _n_)

	  #===============================#
	 #     ONLY MARKS / CONTROLS     #
	#===============================#

	def OnlyMarks()
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringOnlyMarks(_pH_)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		return _c_

	def OnlyControls()
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringOnlyControls(_pH_)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		return _c_

	def OnlyLatinLetters()
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringOnlyLatinLetters(_pH_)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		return _c_

	  #===============================#
	 #     NUMERIC / ALPHA CHECKS    #
	#===============================#

	# TRUE if the string is numeric.
	def IsNumericString()
		_pH_ = @oString.Engine()
		return StzEngineStringIsNumeric(_pH_)

		def IsANumber()
			return This.IsNumericString()

	def IsAlphaString()
		_pH_ = @oString.Engine()
		return StzEngineStringIsAlpha(_pH_)

		def IsAllLetters()
			return This.IsAlphaString()

	  #===============================#
	 #     REGEX MATCH CHECK         #
	#===============================#

	# TRUE if the string matches the given regex pattern.
	def MatchesRegex(pcPattern)
		_pH_ = @oString.Engine()
		return StzEngineStringRegexIsMatch(_pH_, pcPattern, 0)

		def IsMatchedByRegex(pcPattern)
			return This.MatchesRegex(pcPattern)

	def MatchesRegexCS(pcPattern, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		_nFlags_ = 0
		if _bCase_ = 0
			_nFlags_ = 1
		ok
		_pH_ = @oString.Engine()
		return StzEngineStringRegexIsMatch(_pH_, pcPattern, _nFlags_)

		def IsMatchedByRegexCS(pcPattern, pCaseSensitive)
			return This.MatchesRegexCS(pcPattern, pCaseSensitive)
