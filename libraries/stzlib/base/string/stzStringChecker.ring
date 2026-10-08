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


# Answers yes/no questions about a text: palindrome, anagram, number form, case, composition, marks and regex match.
#
# It is the question-answering helper behind many Is... methods of stzString, which builds one over
# itself and passes the call on; reach for it directly when you only want the checks and not the
# whole string API. A question answers 1 or 0 and never changes the text. Every question counts
# characters, not bytes, so a Hebrew or Arabic word and an emoji are one character each. The number
# checks that expect a prefix (0b, 0o, 0x, U+) answer 0 without it. The case-flag forms (CS) take 1
# to compare with case and 0 to ignore it. HasLeadingChars, HasTrailingChars and
# HasLeadingAndTrailingChars answer 0 for every text today; use the stzString methods of the same
# names.
#
#   receiver   o1 = new stzStringChecker("level")
#   example    ? o1.IsPalindrome()
#              #--> 1
#              ? o1.IsMadeOf([ "lev", "el" ])
#              #--> 1
#              o2 = new stzStringChecker("שלום")
#              ? o2.IsReversedCopyOf("םולש")
#              #--> 1
#              o3 = new stzStringChecker("a😀b")
#              ? o3.NumberOfChars()
#              #--> 3
#   see        stzString, stzStringRemover, stzStringReplacer
class stzStringChecker from stzObject

	@oString

	  #===================#
	 #   INITIALIZATION  #
	#===================#

	# Builds a checker over a text, given as a string or as a stzString object.
	#
	#   pStrOrStzStrObj   the text to question, or a stzString whose content is questioned (it is
	#                     held, not copied)
	#   returns           nothing; the object is built
	#   note              stzString builds one of these for each of its Is... questions
	#   see               Content, NumberOfChars
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

	# Returns the text being questioned, unchanged.
	#
	#   returns    a text
	#   see        NumberOfChars, Reversed
	def Content()
		return @oString.Content()

	# Returns how many characters the text holds, counting an emoji or an accented letter as one.
	#
	#   returns    a number
	#   see        Content, IsChar
	def NumberOfChars()
		return @oString.NumberOfChars()

	# TRUE if the text holds no character at all.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   see        NumberOfChars, IsChar
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

	# TRUE if the text reads the same from the right as from the left, letter case counted.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       an empty text is a palindrome; IsPalindromeCS(0) ignores case, so Abba passes
	#              with it and fails without it
	#   see        IsReversedCopyOf, Reversed
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

	# TRUE if the text is made of the same characters as another text, in any order.
	#
	#   pcOtherStr   the text to compare with
	#   returns      TRUE or FALSE, as 1 or 0
	#   note         case counts by default: Hello and olleH are anagrams, Hello and OLLEH only with
	#                IsAnagramOfCS(..., 0)
	#   see          IsReversedCopyOf, IsMadeOf
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

	# TRUE if the first character is a capital and every other character is lower case.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       a one-character text answers FALSE, a capital included
	#   warning    a script without letter case passes: the Hebrew text שלום answers TRUE
	#   see        IsUppercase, IsLowercase
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

	# TRUE if the text is exactly the listed pieces put together, each of them used at least once.
	#
	#   acSubStr   a list of text pieces
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       the check removes each piece in turn and asks whether nothing is left
	#   warning    a listed piece that does not occur makes it FALSE, even when the other pieces
	#              cover the whole text
	#   see        IsMadeOfSome, IsMadeOfChar
	def IsMadeOf(acSubStr)
		return This.IsMadeOfCS(acSubStr, 1)

	# TRUE if the string is made of the given char only.
	def IsMadeOfCharCS(_c_, pCaseSensitive)
		if isString(_c_) and @IsChar(_c_)
			return This.IsMadeOfCS([ _c_ ], pCaseSensitive)
		else
			return 0
		ok

	# TRUE if the text is made only of the given character, repeated any number of times.
	#
	#   _c_        the character
	#   returns    TRUE or FALSE, as 1 or 0
	#   see        IsMadeOf, ContainsOnlyChars
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

	# TRUE if the text is covered entirely by pieces taken from the list, some of the pieces being allowed to stay unused.
	#
	#   acSubStr   a list of text pieces
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       a piece that does not occur is ignored, where IsMadeOf would answer FALSE
	#   see        IsMadeOf, ContainsOnlyChars
	def IsMadeOfSome(acSubStr)
		return This.IsMadeOfSomeCS(acSubStr, 1)

	  #===============================#
	 #     NUMBER REPRESENTATION     #
	#===============================#

	# TRUE if the text is a whole number, written with an optional leading + or -.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       42, -5 and +5 pass, -3.14 and 0x1F do not
	#   see        RepresentsSignedInteger, RepresentsNumber
	def RepresentsInteger()
		_pH_ = @oString.Engine()
		return StzEngineStringIsNumericString(_pH_)

	# TRUE if the text is a whole number that starts with a + or a - sign.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       42 answers FALSE and -5 answers TRUE
	#   see        RepresentsInteger, RepresentsUnsignedInteger
	def RepresentsSignedInteger()
		if This.RepresentsInteger()
			_cFirst_ = @oString.NthChar(1)
			if _cFirst_ = "+" or _cFirst_ = "-"
				return 1
			ok
		ok
		return 0

	# TRUE if the text is a whole number written without a sign.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       42 answers TRUE and -5 answers FALSE
	#   see        RepresentsInteger, RepresentsSignedInteger
	def RepresentsUnsignedInteger()
		if This.RepresentsInteger() and NOT This.RepresentsSignedInteger()
			return 1
		else
			return 0
		ok

	# TRUE if the text is a whole or a decimal number, written with an optional leading + or -.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       -3.14 and 42 pass, abc does not
	#   see        RepresentsInteger, RepresentsDecimalNumber
	def RepresentsNumber()
		_pH_ = @oString.Engine()
		if StzEngineStringIsNumericString(_pH_)
			return 1
		ok
		return StzEngineStringIsFloat(_pH_)

	def RepresentsRealNumber()
		# Real-number == any number per the monolith convention.
		return This.RepresentsNumber()

	# TRUE if the text is a number, whole or decimal, that starts with a + or a - sign.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       -3.14 and +5 answer TRUE, 42 answers FALSE
	#   see        RepresentsNumber, RepresentsUnsignedNumber
	def RepresentsSignedNumber()
		# Number AND first char is + or -.
		if This.RepresentsNumber()
			_cRsnFirst_ = @oString.NthChar(1)
			if _cRsnFirst_ = "+" or _cRsnFirst_ = "-"
				return 1
			ok
		ok
		return 0

	# TRUE if the text is a number, whole or decimal, written without a sign.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       42 answers TRUE, -3.14 answers FALSE
	#   see        RepresentsNumber, RepresentsSignedNumber
	def RepresentsUnsignedNumber()
		if This.RepresentsNumber() and NOT This.RepresentsSignedNumber()
			return 1
		ok
		return 0

	# TRUE if the string holds a numeric literal.
	def IsNumberInString()
		# Alias for RepresentsNumber -- "is the string a number literal?"
		return This.RepresentsNumber()

	# TRUE if the trimmed text starts with a [ and ends with a ], so that it could be read back as a list.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       only the two brackets are looked at: the content between them is not parsed
	#   see        RepresentsNumber
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

	# TRUE if the text is a number written with a decimal point, such as 3.14 or -3.14.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       42 answers FALSE: it has no decimal point
	#   see        RepresentsNumber, RepresentsInteger
	def RepresentsDecimalNumber()
		_pH_ = @oString.Engine()
		return StzEngineStringIsFloat(_pH_)

		def RepresentsNumberInDecimalForm()
			return This.RepresentsDecimalNumber()

	# TRUE if the text is a 0b or 0B prefix followed by binary digits.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       0b1011 answers TRUE and 1011 answers FALSE: the prefix is required
	#   see        RepresentsHexNumber, RepresentsOctalNumber
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

	# TRUE if the text is a 0x or 0X prefix followed by hexadecimal digits.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       0x1F answers TRUE and 1F4a answers FALSE: the prefix is required
	#   see        RepresentsBinaryNumber, RepresentsNumberInUnicodeHexForm
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

	# TRUE if the text is U+ followed by hexadecimal digits, the way a Unicode code point is written.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       U+0041 answers TRUE and 0041 answers FALSE
	#   see        RepresentsHexNumber, IsCharName
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

	# TRUE if the text is the official Unicode name of a character, such as LATIN SMALL LETTER A.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       the name is looked up in the engine character database; a letter such as x is not
	#              a name
	#   see        IsChar, RepresentsNumberInUnicodeHexForm
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

	# TRUE if the text is another text read backward, character by character.
	#
	#   pcOtherStr   the text to compare with
	#   returns      TRUE or FALSE, as 1 or 0
	#   note         works on characters, not bytes: םולש is the reverse of שלום
	#   see          IsPalindrome, Reversed
	def IsReversedCopyOf(pcOtherStr)
		return This.IsReversedCopyOfCS(pcOtherStr, 1)

	  #===============================#
	 #     REVERSED                  #
	#===============================#

	# Returns the text with its characters in the opposite order, leaving the checked text unchanged.
	#
	#   returns    a text
	#   note       an emoji or an accented letter stays whole: a😀b gives b😀a
	#   see        IsReversedCopyOf, IsPalindrome
	def Reversed()
		return StzReverse(@oString.Content())

	  #===============================#
	 #     STRUCTURAL CHECKS         #
	#===============================#

	# TRUE if the text is made of exactly one character.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       a letter with a separate combining accent counts as two characters, so it answers
	#              FALSE
	#   see        NumberOfChars, IsEmpty
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

	# Returns 0 today whatever the text is, instead of telling whether the text starts with a repeated character.
	#
	#   returns    always 0 today
	#   note       stzString.HasLeadingChars is the working one
	#   warning    answers FALSE for aab and for xxyy alike: it compares two engine handles, which
	#              are never equal, instead of the two characters; the stzString method of the same
	#              name answers 1 for aab
	#   see        HasTrailingChars, HasLeadingAndTrailingChars
	def HasLeadingChars()
		if @oString.NumberOfChars() < 2
			return 0
		ok

		_pH_ = @oString.Engine()
		_cFirst_ = StzEngineStringCharAtToString(_pH_, 1)
		_cSecond_ = StzEngineStringCharAtToString(_pH_, 2)
		return _cFirst_ = _cSecond_

	# Returns 0 today whatever the text is, instead of telling whether the text ends with a repeated character.
	#
	#   returns    always 0 today
	#   note       stzString.HasTrailingChars is the working one
	#   warning    answers FALSE for abb and for xxyy alike: it compares two engine handles, which
	#              are never equal, instead of the two characters
	#   see        HasLeadingChars, HasLeadingAndTrailingChars
	def HasTrailingChars()
		_nLen_ = @oString.NumberOfChars()
		if _nLen_ < 2
			return 0
		ok

		_pH_ = @oString.Engine()
		_cLast_ = StzEngineStringCharAtToString(_pH_, _nLen_)
		_cPrev_ = StzEngineStringCharAtToString(_pH_, _nLen_ - 1)
		return _cLast_ = _cPrev_

	# Returns 0 today whatever the text is, because both of the questions it combines answer 0.
	#
	#   returns    always 0 today
	#   note       stzString.HasLeadingAndTrailingChars is the working one
	#   warning    answers FALSE for aabaa: it is the AND of HasLeadingChars and HasTrailingChars,
	#              which are always 0
	#   see        HasLeadingChars, HasTrailingChars
	def HasLeadingAndTrailingChars()
		return This.HasLeadingChars() and This.HasTrailingChars()

	  #===============================#
	 #     TRIMMED                   #
	#===============================#

	# Returns the text without the blanks at its two ends, leaving the checked text unchanged.
	#
	#   returns    a text
	#   note       blanks inside the text stay
	#   see        TrimmedLeft, TrimmedRight
	def Trimmed()
		_pH_ = StzEngineString(@oString.Content())
		_pR_ = StzEngineStringTrimmed(_pH_)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		StzEngineStringFree(_pH_)
		return _c_

	# Returns the text without the blanks at its beginning, leaving the checked text unchanged.
	#
	#   returns    a text
	#   see        Trimmed, TrimmedRight
	def TrimmedLeft()
		_pH_ = StzEngineString(@oString.Content())
		_pR_ = StzEngineStringTrimLeft(_pH_)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		StzEngineStringFree(_pH_)
		return _c_

	# Returns the text without the blanks at its end, leaving the checked text unchanged.
	#
	#   returns    a text
	#   see        Trimmed, TrimmedLeft
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

	# TRUE if the text is a 0o or 0O prefix followed by octal digits.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       0o17 answers TRUE and 17 answers FALSE: the prefix is required
	#   see        RepresentsBinaryNumber, RepresentsHexNumber
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

	# TRUE if the given character occurs anywhere in the text.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       only the first character of pcChar is looked at
	#   warning    the case flag of ContainsCharCS is ignored today: ContainsCharCS("e", 0) on HELLO
	#              answers FALSE, and so does ContainsCharCS("a", 0) on ABC
	#   see        ContainsAnyOfChars, ContainsAllOfChars
	def ContainsChar(pcChar)
		return This.ContainsCharCS(pcChar, 1)

	def ContainsAnyOfCharsCS(pcChars, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		_pH_ = @oString.Engine()
		return StzEngineStringContainsAnyOfCS(_pH_, pcChars, _bCase_)

	# TRUE if at least one character of the given text occurs in the text.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       ContainsAnyOfCharsCS("xa", 0) finds the A of ABC
	#   see        ContainsChar, ContainsAllOfChars
	def ContainsAnyOfChars(pcChars)
		return This.ContainsAnyOfCharsCS(pcChars, 1)

	def ContainsAllOfCharsCS(pcChars, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		_pH_ = @oString.Engine()
		return StzEngineStringContainsAllOfCS(_pH_, pcChars, _bCase_)

	# TRUE if every character of the given text occurs in the text.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       the order and the repeats do not matter
	#   see        ContainsAnyOfChars, ContainsOnlyChars
	def ContainsAllOfChars(pcChars)
		return This.ContainsAllOfCharsCS(pcChars, 1)

	def ContainsOnlyCharsCS(pcChars, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		_pH_ = @oString.Engine()
		return StzEngineStringContainsOnlyCS(_pH_, pcChars, _bCase_)

	# TRUE if every character of the text belongs to the given set of characters.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       the set may be larger than the text: lev covers level, and
	#              ContainsOnlyCharsCS("abc", 0) accepts ABC
	#   see        ContainsAllOfChars, IsMadeOfChar
	def ContainsOnlyChars(pcChars)
		return This.ContainsOnlyCharsCS(pcChars, 1)

	  #===============================#
	 #     CONTROL / MARK CHECKS     #
	#===============================#

	# TRUE if the string is made of control chars.
	def IsControl()
		_pH_ = @oString.Engine()
		return StzEngineStringIsControl(_pH_)

	# TRUE if the text holds a combining mark, such as an accent written as its own character.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       an accented letter written as one precomposed character has no mark: é answers
	#              FALSE, e followed by U+0301 answers TRUE
	#   see        CharIsMarkAt, OnlyMarks
	def HasMark()
		_pH_ = @oString.Engine()
		return StzEngineStringHasMark(_pH_)

	# TRUE if the character at the given position is a control character, such as a tab.
	#
	#   _n_        the position of the character, counted from 1
	#   returns    TRUE or FALSE, as 1 or 0
	#   see        CharIsMarkAt, CharIsSpaceAt, OnlyControls
	def CharIsControlAt(_n_)
		_pH_ = @oString.Engine()
		return StzEngineStringCharIsControlAt(_pH_, _n_)

	# TRUE if the character at the given position is a combining mark.
	#
	#   _n_        the position of the character, counted from 1
	#   returns    TRUE or FALSE, as 1 or 0
	#   see        HasMark, CharIsControlAt, OnlyMarks
	def CharIsMarkAt(_n_)
		_pH_ = @oString.Engine()
		return StzEngineStringCharIsMarkAt(_pH_, _n_)

	# TRUE if the character at the given position is a blank, a tab included.
	#
	#   _n_        the position of the character, counted from 1
	#   returns    TRUE or FALSE, as 1 or 0
	#   see        CharIsControlAt, CharIsMarkAt
	def CharIsSpaceAt(_n_)
		_pH_ = @oString.Engine()
		return StzEngineStringCharIsSpaceAt(_pH_, _n_)

	  #===============================#
	 #     ONLY MARKS / CONTROLS     #
	#===============================#

	# Returns the combining marks of the text, in order, as one text and nothing else.
	#
	#   returns    a text, empty when the text holds no mark
	#   see        HasMark, OnlyControls, OnlyLatinLetters
	def OnlyMarks()
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringOnlyMarks(_pH_)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		return _c_

	# Returns the control characters of the text, in order, as one text and nothing else.
	#
	#   returns    a text, empty when the text holds no control character
	#   see        CharIsControlAt, OnlyMarks, OnlyLatinLetters
	def OnlyControls()
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringOnlyControls(_pH_)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		return _c_

	# Returns the Latin letters of the text, in order, as one text without the other characters.
	#
	#   returns    a text, empty when there is no Latin letter
	#   note       Hebrew, Arabic, emoji and digits are dropped: a😀b gives ab and abc123 gives abc
	#   see        OnlyMarks, IsAlphaString
	def OnlyLatinLetters()
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringOnlyLatinLetters(_pH_)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		return _c_

	  #===============================#
	 #     NUMERIC / ALPHA CHECKS    #
	#===============================#

	# TRUE if the text is made only of the ASCII digits 0 to 9.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       42 answers TRUE; -5, 4.5, abc123 and the Arabic-Indic digits ١٢٣ answer FALSE
	#   see        RepresentsNumber, IsAlphaString
	#@ aka  TRUE if the string is numeric.
	def IsNumericString()
		_pH_ = @oString.Engine()
		return StzEngineStringIsNumeric(_pH_)

		def IsANumber()
			return This.IsNumericString()

	# TRUE if the text is made of letters only, in any script.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       Hebrew and Arabic letters count: שלום and مرحبا answer TRUE
	#   see        IsNumericString, OnlyLatinLetters
	def IsAlphaString()
		_pH_ = @oString.Engine()
		return StzEngineStringIsAlpha(_pH_)

		def IsAllLetters()
			return This.IsAlphaString()

	  #===============================#
	 #     REGEX MATCH CHECK         #
	#===============================#

	# TRUE if the text matches the given regular expression, found anywhere in it unless the pattern is anchored.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       MatchesRegex("^hello") is TRUE on hello world, and MatchesRegexCS("HELLO", 0)
	#              ignores case
	#   see        MatchesRegexCS, ContainsOnlyChars
	#@ aka  TRUE if the string matches the given regex pattern.
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
