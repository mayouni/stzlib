#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSTRINGCHAR               #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : Single Unicode character class.             #
#                  Wraps stzString via composition (@oString).  #
#                  Delegates to Zig engine for Unicode props.  #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////////
 ///   FUNCTIONS   ///
/////////////////////

#-- Unicode character property helpers (engine wrappers)

func _CharIsSpace(nUnicode)
	return StzEngineUnicodeIsSpace(nUnicode)

func _CharCategoryNumber(nUnicode)
	return StzEngineUnicodeCategory(nUnicode)

func _CharBidiClass(nUnicode)
	return StzEngineUnicodeBidiClass(nUnicode)

func _CharMirrored(nUnicode)
	switch nUnicode
	on 0x28 return 0x29
	on 0x29 return 0x28
	on 0x3C return 0x3E
	on 0x3E return 0x3C
	on 0x5B return 0x5D
	on 0x5D return 0x5B
	on 0x7B return 0x7D
	on 0x7D return 0x7B
	on 0xAB return 0xBB
	on 0xBB return 0xAB
	on 0x2039 return 0x203A
	on 0x203A return 0x2039
	on 0x2045 return 0x2046
	on 0x2046 return 0x2045
	on 0x207D return 0x207E
	on 0x207E return 0x207D
	on 0x208D return 0x208E
	on 0x208E return 0x208D
	on 0x0F3A return 0x0F3B
	on 0x0F3B return 0x0F3A
	on 0x0F3C return 0x0F3D
	on 0x0F3D return 0x0F3C
	off
	return nUnicode

func _CharUnicodeVersion(nUnicode)
	if nUnicode <= 0x7F return 1 ok
	if nUnicode <= 0xFF return 1 ok
	if nUnicode <= 0x24F return 1 ok
	if nUnicode >= 0x0300 and nUnicode <= 0x036F return 1 ok
	if nUnicode >= 0x0370 and nUnicode <= 0x03FF return 1 ok
	if nUnicode >= 0x0400 and nUnicode <= 0x04FF return 1 ok
	if nUnicode >= 0x0590 and nUnicode <= 0x05FF return 1 ok
	if nUnicode >= 0x0600 and nUnicode <= 0x06FF return 1 ok
	if nUnicode >= 0x4E00 and nUnicode <= 0x9FFF return 1 ok
	if nUnicode >= 0xAC00 and nUnicode <= 0xD7AF return 2 ok
	if nUnicode >= 0x0900 and nUnicode <= 0x097F return 1 ok
	if nUnicode >= 0x1F600 and nUnicode <= 0x1F64F return 6 ok
	if nUnicode >= 0x1F300 and nUnicode <= 0x1F5FF return 6 ok
	return 1

func _CharScriptCode(nUnicode)
	# Codes index _aUnicodeScriptsXT (stzCharData.ring): 3 Latin, 4 Greek,
	# 5 Cyrillic, 6 Armenian, 7 Hebrew, 8 Arabic, 11 Devanagari, 21 Thai,
	# 26 Hangul, 34 Hiragana, 35 Katakana, 37 Han.
# Common script (code 2) first: spaces, digits, punctuation and
	# symbols are script-neutral, NOT Latin (UAX #24).
	if nUnicode <= 0x40 return 2 ok					# space, digits, punctuation
	if nUnicode >= 0x5B and nUnicode <= 0x60 return 2 ok		# [ \ ] ^ _ `
	if nUnicode >= 0x7B and nUnicode <= 0xBF return 2 ok		# { | } ~ + Latin-1 symbols
	if nUnicode = 0xD7 or nUnicode = 0xF7 return 2 ok		# multiply / divide signs
	if nUnicode >= 0x300 and nUnicode <= 0x36F return 1 ok		# combining marks -> Inherited
	if nUnicode <= 0x24F return 3 ok				# Basic Latin + Latin-1 + Latin Ext-A/B
	if nUnicode >= 0x2160 and nUnicode <= 0x217F return 3 ok	# Roman numerals -> Latin (UAX #24)
	if nUnicode >= 0x0370 and nUnicode <= 0x03FF return 4 ok		# Greek
	if nUnicode >= 0x0400 and nUnicode <= 0x04FF return 5 ok		# Cyrillic
	if nUnicode >= 0x0530 and nUnicode <= 0x058F return 6 ok		# Armenian
	if nUnicode >= 0x0590 and nUnicode <= 0x05FF return 7 ok		# Hebrew
	if nUnicode >= 0x064B and nUnicode <= 0x065F return 1 ok	# Arabic diacritics -> Inherited
	if nUnicode = 0x0670 return 1 ok				# superscript alef -> Inherited
	if nUnicode >= 0x0600 and nUnicode <= 0x06FF return 8 ok		# Arabic
	if nUnicode >= 0x0900 and nUnicode <= 0x097F return 11 ok	# Devanagari
	if nUnicode >= 0x0A80 and nUnicode <= 0x0AFF return 14 ok	# Gujarati
	if nUnicode >= 0x0E00 and nUnicode <= 0x0E7F return 21 ok	# Thai
	if nUnicode >= 0x3040 and nUnicode <= 0x309F return 34 ok	# Hiragana
	if nUnicode >= 0x30A0 and nUnicode <= 0x30FF return 35 ok	# Katakana
	if nUnicode >= 0x4E00 and nUnicode <= 0x9FFF return 37 ok	# CJK Unified Ideographs -> Han
	if nUnicode >= 0xAC00 and nUnicode <= 0xD7AF return 26 ok	# Hangul syllables
	return 0

#-- Public standalone functions

func StzIsInvisibleChar(c)
	if CheckParams()
		if NOT isString(c)
			stzraise("Incorrect param type! c must be a string.")
		ok
		if NOT IsChar(c)
			stzraise("Incorrect param type! c must be a char.")
		ok
	ok

	if StzFindFirst( InvisibleChars(), c )
		return 1
	else
		return 0
	ok

	func IsInvisibleChar(c)
		return StzIsInvisibleChar(c)

	func @IsInvisibleChar(c)
		return StzIsInvisibleChar(c)

func StzSpace(n)
	return Copy(" ", n)

	func Space(n)
		return StzSpace(n)

	func @Space(n)
		return StzSpace(n)

func StzCharQ(p)
	return new stzStringChar(p)

	func CQ(p)
		return StzCharQ(p)

func StzCharObj(n)
	nMax = MaxUnicodeNumber()
	if NOT ( isNumber(n) and n <= nMax )
		StzRaise("Incorrect param type! p must be a number less then " + nMax + "!")
	ok
	return StzCharQ(n).Content()

	func UnicodeChar(n)
		return StzChar(n)

	func UChar(n)
		return StzChar(n)

func StzCharMethods()
	return Stz(:Char, :Methods)

func StzCharAttributes()
	return Stz(:Char, :Attributes)

func StzCharClass()
	return "stzstringchar"

	func StzCharClassName()
		return StzCharClass()

func StzIsAsciiChar(c)
	if NOT isString(c)
		return 0
	ok
	return StzCharQ(c).IsAscii()

	func IsAsciiChar(c)
		return StzIsAsciiChar(c)

	func IsAnAsciiChar(c)
		return StzIsAsciiChar(c)

	func @IsAsciiChar(c)
		return StzIsAsciiChar(c)

	func @IsAnAsciiChar(c)
		return StzIsAsciiChar(c)

func StzIsChar(pStrOrNbr)
	if isString(pStrOrNbr)
		# A char is a single Unicode codepoint
		# Quick check: must be 1-4 bytes and produce exactly 1 codepoint
		_nIcByteLen_ = len(pStrOrNbr)
		if _nIcByteLen_ < 1 or _nIcByteLen_ > 4
			return 0
		ok
		# Use engine to check if it's exactly 1 codepoint
		if StzLen(pStrOrNbr) = 1
			return 1
		else
			return 0
		ok

	but isNumber(pStrOrNbr)
		cStringified = ""+ pStrOrNbr
		if ring_substr1(cStringified, ".") > 0
			return 0
		ok
		n = 0+ cStringified
		if n < 0 or n > 9
			return 0
		ok
		return 1

	else
		return 0
	ok

	func IsChar(pStrOrNbr)
		return StzIsChar(pStrOrNbr)

	func @IsChar(pcStr)
		return StzIsChar(pcStr)

	func IsAChar(pcStr)
		return StzIsChar(pcStr)

	func @IsAChar(pcStr)
		return StzIsChar(pcStr)

	func IsALetter(pcStr)
		return IsLetter(pcStr)

	func @IsALetter(pcStr)
		return IsLetter(pcStr)

func StzQuotationMark()
	return '"'

	func QuotationMark()
		return StzQuotationMark()

	func DoubleQuote()
		return StzQuotationMark()

func StzApostrophe()
	return "'"

	func Apostrophe()
		return StzApostrophe()

	func SingleQuote()
		return StzApostrophe()

func StzCharName(c)
	return StzCharQ(c).Name()

	func CharName(c)
		return StzCharName(c)

	func @CharName(c)
		return StzCharName(c)

	func Name(c)
		return StzCharName(c)

	func @Name(c)
		return StzCharName(c)

func StzUnicodeToHexUnicode(n)
	oChar = new stzStringChar(n)
	return oChar.HexUnicode()

	func UnicodeToHexUnicode(n)
		return StzUnicodeToHexUnicode(n)

func StzHexUnicodeToUnicode(cHex)
	oChar = new stzStringChar(cHex)
	return oChar.Unicode()

	func HexUnicodeToUnicode(cHex)
		return StzHexUnicodeToUnicode(cHex)

func StzCharToUnicode(c)
	if NOT isString(c)
		StzRaise("Can't proceed! You must provide a char in a string type.")
	ok
	return StzCharQ(c).Unicode()

	func CharToUnicode(c)
		return StzCharToUnicode(c)

	def CharUnicode(c)
		return StzCharToUnicode(c)

func StzUnicodeToChar(nUnicode)
	oChar = new stzStringChar(nUnicode)
	return oChar.Content()

	func UnicodeToChar(nUnicode)
		return StzUnicodeToChar(nUnicode)

	func @Char(nUnicode)
		return StzUnicodeToChar(nUnicode)

func StzUnicodeSectionToListOfChars(nUnicode1, nUnicode2)
	aResult = []
	for nUnicode = nUnicode1 to nUnicode2
		aResult + StzUnicodeToChar( nUnicode )
	next
	return aResult

	func UnicodeSectionToListOfChars(nUnicode1, nUnicode2)
		return StzUnicodeSectionToListOfChars(nUnicode1, nUnicode2)

func StzUnicodeSectionToListOfStzChars(nUnicode1, nUnicode2)
	aResult = []
	for nUnicode = nUnicode1 to nUnicode2
		aResult + new stzStringChar( nUnicode )
	next
	return aResult

	func UnicodeSectionToListOfStzChars(nUnicode1, nUnicode2)
		return StzUnicodeSectionToListOfStzChars(nUnicode1, nUnicode2)

func StzUnicodeSectionToStzListOfChars(nUnicode1, nUnicode2)
	return new stzListOfChars( StzUnicodeSectionToListOfChars(nUnicode1, nUnicode2) )

	func UnicodeSectionToStzListOfChars(nUnicode1, nUnicode2)
		return StzUnicodeSectionToStzListOfChars(nUnicode1, nUnicode2)

func StzCurrentUnicodeVersion()
	return _acUnicodeVersions[ len(_acUnicodeVersions) ]

	func CurrentUnicodeVersion()
		return StzCurrentUnicodeVersion()

func StzUnicodeCharName(c)
	return "NOT_AVAILABLE"

	func UnicodeCharName(c)
		return StzUnicodeCharName(c)

func StzCharScript(c)
	oTempChar = new stzStringChar(c)
	return oTempChar.Script()

	func CharScript(c)
		return StzCharScript(c)

func StzCharIsArabicShaddah(c)
	oChar = new stzStringChar(c)
	return oChar.IsArabicShaddah()

	func CharIsArabicShaddah(c)
		return StzCharIsArabicShaddah(c)

func StzCharIsArabic7arakah(c)
	oChar = new stzStringChar(c)
	return oChar.IsArabic7arakah()

	func CharIsArabic7arakah(c)
		return StzCharIsArabic7arakah(c)

func StzCharIsWordSeparator(c)
	return StzCharQ(c).IsWordSeparator()

	func CharIsWordSeparator(c)
		return StzCharIsWordSeparator(c)

	func CharIsWordSeperator(c)
		return StzCharIsWordSeparator(c)

func StzCharIsSentenceSeparator(c)
	return StzCharQ(c).IsSentenceSeparator(c)

	func CharIsSenstenceSeparator(c)
		return StzCharIsSentenceSeparator(c)

	func CharIsSenstenceSeperator(c)
		return StzCharIsSentenceSeparator(c)

func StzCharIsLineSeparator(c)
	return StzCharQ(c).IsLineSeparator(c)

	func CharIsLineSeparator(c)
		return StzCharIsLineSeparator(c)

	func CharIsLineSeperator(c)
		return StzCharIsLineSeparator(c)

func StzRemoveDiacritic(pcChar)
	return StzCharQ(pcChar).DiacriticRemoved()

	func RemoveDiacritic(pcChar)
		return StzRemoveDiacritic(pcChar)

func StzACharOtherThan(pcChar)
	nUnicode = Unicode(pcChar)
	n = StzListOfNumbersQ( 1: NumberOfUnicodeChars()).ANumberOtherThan(nUnicode)
	cResult = StzCharQ(n).Content()
	return cResult

	func ACharOtherThan(pcChar)
		return StzACharOtherThan(pcChar)

	func ACharDifferentThan(pcChar)
		return StzACharOtherThan(pcChar)

	func ACharDifferentFrom(pcChar)
		return StzACharOtherThan(pcChar)

	func CharOtherThan(pcChar)
		return StzACharOtherThan(pcChar)

	func CharDifferentThan(pcChar)
		return StzACharOtherThan(pcChar)

	func CharDifferentFrom(pcChar)
		return StzACharOtherThan(pcChar)

	func AnyCharOtherThan(pcChar)
		return StzACharOtherThan(pcChar)

	func AnyCharDifferentThan(pcChar)
		return StzACharOtherThan(pcChar)

	func AnyCharDifferentFrom(pcChar)
		return StzACharOtherThan(pcChar)

func StzLastUnicodeChar()
	return StzCharQ( NumberOfUnicodeChars() ).Content()

	func LastUnicodeChar()
		return StzLastUnicodeChar()

	func LastCharInUnicode()
		return StzLastUnicodeChar()

func StzFirstUnicodeChar()
	return StzCharQ( 1 ).Content()

	func FirstUnicodeChar()
		return StzFirstUnicodeChar()

	func FirstCharInUnicode()
		return StzFirstUnicodeChar()

#-- Natural-coding functions

func StzLetter(pcChar)
	if @IsChar(pcChar) and StzCharQ(pcChar).IsLetter()
		return StzCharQ(pcChar).Uppercased()
	ok

	func Letter(pcChar)
		return StzLetter(pcChar)

func StzLetter@(pcChar)
	if @IsChar(pcChar) and StzCharQ(pcChar).IsLetter()
		return ComputableForm(pcChar)
	ok

	func Letter@(pcChar)
		return StzLetter@(pcChar)

func StzCharacter(pcChar)
	if @IsChar(pcChar)
		return pcChar
	ok

	func Character(pcChar)
		return StzCharacter(pcChar)

func StzCharacter@(pcChar)
	if @IsChar(pcChar)
		return ComputableForm(pcChar)
	ok

	func Character@(pcChar)
		return StzCharacter@(pcChar)

func StzArabicLetter(pcChar)
	if @IsChar(pcChar) and StzCharQ(pcChar).IsArabicLetter()
		return pcChar
	ok

	func ArabicLetter(pcChar)
		return StzArabicLetter(pcChar)

func StzArabicLetter@(pcChar)
	if @IsChar(pcChar) and StzCharQ(pcChar).IsArabicLetter()
		return ComputableForm(pcChar)
	ok

	func ArabicLetter@(pcChar)
		return StzArabicLetter@(pcChar)

func StzLatinLetter(pcChar)
	if @IsChar(pcChar) and StzCharQ(pcChar).IsLatinLetter()
		return pcChar
	ok

	func LatinLetter(pcChar)
		return StzLatinLetter(pcChar)

func StzLatinLetter@(pcChar)
	if @IsChar(pcChar) and StzCharQ(pcChar).IsLatinLetter()
		return ComputableForm(pcChar)
	ok

	func LatinLetter@(pcChar)
		return StzLatinLetter@(pcChar)

func StzArabicNumber(pcChar)
	if @IsChar(pcChar) and StzCharQ(pcChar).IsArabicNumber()
		return pcChar
	ok

	func ArabicNumber(pcChar)
		return StzArabicNumber(pcChar)

func StzArabicNumber@(pcChar)
	if @IsChar(pcChar) and StzCharQ(pcChar).IsArabicNumber()
		return ComputableForm(pcChar)
	ok

	func ArabicNumber@(pcChar)
		return StzArabicNumber@(pcChar)

func StzRomanNumber(pcChar)
	if @IsChar(pcChar) and StzCharQ(pcChar).IsRomanNumber()
		return pcChar
	ok

	func RomanNumber(pcChar)
		return StzRomanNumber(pcChar)

func StzRomanNumber@(pcChar)
	if @IsChar(pcChar) and StzCharQ(pcChar).IsRomanNumber()
		return ComputableForm(pcChar)
	ok

	func RomanNumber@(pcChar)
		return StzRomanNumber@(pcChar)

func StzFirstCharOf(pcStr)
	oTemp = new stzString(pcStr)
	return oTemp.NthChar(1)

	func FirstCharOf(pcStr)
		return StzFirstCharOf(pcStr)

	func FirstCharIn(pcStr)
		return StzFirstCharOf(pcStr)

func StzLastCharOf(pcStr)
	oTemp = new stzString(pcStr)
	return oTemp.NthChar(oTemp.NumberOfChars())

	func LastCharOf(pcStr)
		return StzLastCharOf(pcStr)

	func LastCharIn(pcStr)
		return StzLastCharOf(pcStr)

func StzFirstLetterOf(pcStr)
	oStzStr = new stzString(pcStr)
	for i = 1 to oStzStr.NumberOfChars()
		if StzCharQ(oStzStr[i]).IsLetter()
			return oStzStr[i]
		ok
	next

	func FirstLetterOf(pcStr)
		return StzFirstLetterOf(pcStr)

	func FirstLetterIn(pcStr)
		return StzFirstLetterOf(pcStr)

func StzLastLetterOf(pcStr)
	oTemp = new stzString(pcStr)
	nLen = oTemp.NumberOfChars()
	for _i = nLen to 1 step -1
		cChar = oTemp.NthChar(_i)
		if StzCharQ(cChar).IsLetter()
			return cChar
		ok
	next
	return ""

	func LastLetterOf(pcStr)
		return StzLastLetterOf(pcStr)

	func LastLetterIn(pcStr)
		return StzLastLetterOf(pcStr)

func StzNumberOfLatinLetters()
	return 52

	func NumberOfLatinLetters()
		return StzNumberOfLatinLetters()

	func HowManyLatinLetters()
		return StzNumberOfLatinLetters()

func StzNumberOfArabicLetters()
	return len( ArabicLetters() )

	func NumberOfArabicLetters()
		return StzNumberOfArabicLetters()

	func HowManyArabicLetters()
		return StzNumberOfArabicLetters()

func StzNumberOfChineseLetters()
	return 20000

	func NumberOfChineseLetters()
		return StzNumberOfChineseLetters()

	func HowManyChineseLetters()
		return StzNumberOfChineseLetters()

func StzNthChar(n, str)
	if isString(n) and isNumber(str)
		temp = n
		n = str
		str = temp
	ok

	if CheckingParams()
		if NOT ( isNumber(n) and isString(str) )
			StzRaise("Incorrect param type! n must be a number and str must be a string.")
		ok
	ok

	oTemp = new stzString(str)
	return oTemp.NthChar(n)

	func NthChar(n, str)
		return StzNthChar(n, str)

	func @NthChar(n, str)
		return StzNthChar(n, str)

func StzIsVowel(p)
	if CheckingParams()
		if NOT isStringOrListOfStrings(p)
			StzRaise("Incorrect param type! pcStrOrList must be a string or list of strings.")
		ok
	ok

	if isString(p)
		if IsChar(p)
			return ring_isvowel(p)
		ok

		acChars = StzStringQ(p).Chars()
	else
		acChars = p
	ok

	nLen = len(acChars)
	bResult = 1

	for i = 1 to nLen
		if NOT StzIsVowel(acChars[i])
			bResult = 0
			exit
		ok
	next

	return bResult

	func IsAVowel(p)
		return StzIsVowel(p)

	func @IsVowel(p)
		return StzIsVowel(p)

	func @IsAVowel(p)
		return StzIsVowel(p)

	func AreVowels(p)
		return StzIsVowel(p)

	func @AreVowels(p)
		return StzIsVowel(p)

func StzCharByName(cName)
	_nCp_ = StzCodepointByName(cName)
	if _nCp_ < 0
		StzRaise("Character name not found: " + cName)
	ok
	return StzChar(_nCp_)

	func CharByName(cName)
		return StzCharByName(cName)

	func @CharByName(cName)
		return StzCharByName(cName)


  /////////////////
 ///   CLASS   ///
/////////////////
class stzChar from stzStringChar

	#-- Report stzchar, not the inherited "stzstring".
	def StzType()
		return :stzChar

class stzStringChar from stzString

	@oString	# Composition: wraps a 1-char stzString

	  #===================#
	 #   INITIALIZATION  #
	#===================#

	def init(pChar)

		if isString(pChar)
			if pChar = ""
				StzRaise("Can't create char from empty string!")
			ok

			oStr = StzStringQ(pChar)

			if oStr.NumberOfChars() = 1
				@oString = new stzString(pChar)

			but oStr.RepresentsNumberInUnicodeHexForm()
				# "U+06A2" -- drop the 2-char "U+" prefix before hex->decimal.
				# ToDecimal() returns a STRING -- coerce to a number, else
				# StzEngineCharToUtf8 mis-encodes it (1-byte garbage).
				_nLenU_ = oStr.NumberOfChars()
				_cHexU_ = oStr.Section(3, _nLenU_)
				_oHexU_ = StzHexNumberQ(_cHexU_)
				_nCiUni_ = 0 + _oHexU_.ToDecimal()
				@oString = new stzString(StzEngineCharToUtf8(_nCiUni_))

			but oStr.RepresentsNumberInHexForm()
				_nCiUni_ = 0 + StzHexNumberQ(pChar).ToDecimal()
				@oString = new stzString(StzEngineCharToUtf8(_nCiUni_))

			but oStr.IsCharName()
				_nCnUni_ = StzCodepointByName(pChar)
				@oString = new stzString(StzEngineCharToUtf8(_nCnUni_))

			else
				StzRaise("Can not create char object!")
			ok

		but isNumber(pChar)
			@oString = new stzString(StzEngineCharToUtf8(pChar))

		but isObject(pChar)
			# Accept a stzString object directly
			@oString = pChar

		else
			StzRaise(stzCharError(:CanNotCreateCharObjectForThisType))
		ok

		if KeepingHistory() = 1
			This.AddHistoricValue(This.Content())
		ok

	  #===============================#
	 #   CONTENT & BASIC ACCESSORS   #
	#===============================#

	def Content()
		return @oString.Content()

		def Char()
			return This.Content()

	def String()
		return @oString

	def Unicode()
		return StzEngineCharUnicode(This.Content())

		def UnicodeAsNumber()
			return This.Unicode()

	def UnicodeAsString()
		return "" + This.Unicode()

	def HexUnicode()
		nDecUnicode = This.Unicode()
		acHexDigits = "0123456789ABCDEF"
		cResult = ""

		for i = 1 to 4
			nDigit = 0+ Q(nDecUnicode % 16).IntegerPart() + 1
			cResult = acHexDigits[nDigit] + cResult
			nDecUnicode = nDecUnicode / 16
		next

		return "U+" + cResult

	def IsEmpty()
		return 0	# stzStringChar can never host an empty char

	def Copy()
		return new stzStringChar( This.Content() )

	def IsAString()
		return 1

	  #=========================#
	 #   NUMBER / DIGIT VALUE  #
	#=========================#

	def Number()
		if This.IsCircledNumber()
			switch This.Char()
			on "0"  return 0
			on "1"  return 1
			on "2"  return 2
			on "3"  return 3
			on "4"  return 4
			on "5"  return 5
			on "6"  return 6
			on "7"  return 7
			on "8"  return 8
			on "9"  return 9
			off
		ok

		def NumericValue()
			return This.Number()

		def Value()
			return This.Number()

	  #=============#
	 #   UPDATE    #
	#=============#

	def Update(pChar)
		if CheckingParams() = 1
			if isList(pChar) and Q(pChar).IsWithOrByOrUsingNamedParam()
				pChar = pChar[2]
			ok
		ok

		if isString(pChar)
			@oString = new stzString(pChar)

		but ring_Type(pChar) = "NUMBER"
			cBuf = space(4)
			nLen = StzEngineCharToUtf8(pChar, cBuf, 4)
			@oString = new stzString(StzLeft(cBuf, nLen))
		else
			StzRaise("Can't update the char!")
		ok

		if KeepingHisto() = 1
			This.AddHistoricValue(This.Content())
		ok

		def UpdateWith(pChar)
			This.Update(pChar)

			def UpdateWithQ(pChar)
				return This.UpdateQ(pChar)

		def UpdateBy(pChar)
			This.Update(pChar)

			def UpdateByQ(pChar)
				return This.UpdateQ(pChar)

		def UpdateUsing(pChar)
			This.Update(pChar)

			def UpdateUsingQ(pChar)
				return This.UpdateQ(pChar)

	def Updated(pChar)
		return pChar

		def UpdatedWith(pChar)
			return This.Updated(pChar)

		def UpdatedBy(pChar)
			return This.Updated(pChar)

		def UpdatedUsing(pChar)
			return This.Updated(pChar)

	  #========================================#
	 #   UNICODE NAME & METADATA             #
	#========================================#

	def CanRetrieveName()
		if This.Name() != "@CantRetriveTheName"
			return 1
		else
			return 0
		ok

	def Name()
		# Engine SQLite lookup — O(1) indexed query
		_cResult_ = StzCharNameByUnicode(This.Unicode())
		if _cResult_ = ""
			StzRaise("Can't proceed! The name of this char (" + This.Content() + ") does not exist in the local unicode database.")
		ok
		return _cResult_

		def UnicodeName()
			return This.Name()

		# CharName / CharacterName -- word-order aliases used by
		# narrative tests that read more naturally with `Char` in
		# the verb (e.g. Q("✓").CharName() -> "CHECK MARK").
		def CharName()
			return This.Name()

		def CharacterName()
			return This.Name()

	def NameIs(pcName)
		if NOT isString(pcName)
			return 0
		ok
		cName = This.Name()
		return BothStringsAreEqualCS(pcName, cName, 0)

	def AsciiCode()
		try
			return ascii(This.Content())
		catch
			StzRaise(stzCharError(:CanNotGetAsciiCodeForNonAsciiChar))
		end

	  #=====================================#
	 #   ORIENTATION & UNICODE DIRECTION   #
	#=====================================#

	def Orientation()
		return @oString.Orientation()

	def UnicodeDirection()
		_aUnicodeDirectionsXT1_ = UnicodeDirectionsXT()
		_nUnicodeDirectionsXT1Len_ = len(_aUnicodeDirectionsXT1_)
		for _iLoopUnicodeDirectionsXT1_ = 1 to _nUnicodeDirectionsXT1Len_
			_aLine_ = _aUnicodeDirectionsXT1_[_iLoopUnicodeDirectionsXT1_]
			if _aLine_[1] = This.UnicodeDirectionNumber()
				return _aLine_[3]
			ok
		next

	def UnicodeDirectionNumber()
		# The engine reports utf8proc bidi classes; the public contract
		# (and the archive) uses Qt's QChar::Direction numbering --
		# translate (utf8proc 1..23 -> Qt): L->0, LRE->11, LRO->12,
		# R->1, AL->13, RLE->14, RLO->15, PDF->16, EN->2, ES->3, ET->4,
		# AN->5, CS->6, NSM->17, BN->18, B->7, S->8, WS->9, ON->10,
		# LRI->19, RLI->20, FSI->21, PDI->22.
		_nUdnB_ = _CharBidiClass(This.Unicode())
		_aUdnMap_ = [ 0, 11, 12, 1, 13, 14, 15, 16, 2, 3, 4, 5, 6,
		              17, 18, 7, 8, 9, 10, 19, 20, 21, 22 ]
		if _nUdnB_ >= 1 and _nUdnB_ <= len(_aUdnMap_)
			return "" + _aUdnMap_[_nUdnB_]
		ok
		return "" + _nUdnB_

	def IsVowel()
		# NOTE: do NOT call Vowels() here -- it resolves to the inherited
		# stzString.Vowels() (vowels CONTAINED in the content), which
		# returns [] for a single-char object, so IsVowel always answered
		# FALSE. Test the codepoint directly (ASCII vowels, both cases).
		return ring_find([ 65, 69, 73, 79, 85, 97, 101, 105, 111, 117 ], This.Unicode()) > 0

		def IsAVowel()
			return This.IsVowel()

	def IsLeftToRight()
		# L, LRE, LRO, LRI (Qt numbering)
		return ring_find([ "0", "11", "12", "19" ], This.UnicodeDirectionNumber()) > 0

	def IsRightToLeft()
		# R, AL, RLE, RLO, RLI (Qt numbering)
		return ring_find([ "1", "13", "14", "15", "20" ], This.UnicodeDirectionNumber()) > 0

	def IsArabicFraction()
		return ring_find(ArabicFractionsUnicodes(), This.Unicode()) > 0

	def IsEuropeanDigit()
		return This.IsEuropeanNumber()

	def IsEuropeanNumberSeparator()
		return This.UnicodeDirectionNumber() = "3"

		def IsEuropeanNumberSeperator()
			return This.IsEuropeanNumberSeparator()

	def IsEuropeanNumberTerminator()
		return This.UnicodeDirectionNumber() = "4"

	def IsIndianDigit()
		_aIndianDigits2_ = IndianDigits()
		_nIndianDigits2Len_ = len(_aIndianDigits2_)
		for _iLoopIndianDigits2_ = 1 to _nIndianDigits2Len_
			cDigit = _aIndianDigits2_[_iLoopIndianDigits2_]
			if cDigit = This.Content()
				return 1
			ok
		end
		return 0

	def IsCommonNumberSeparator()
		return This.UnicodeDirectionNumber() = "6"

		def IsCommonNumberSeperator()
			return This.IsCommonNumberSeparator()

	def IsParagraphSeparator()
		return This.UnicodeDirectionNumber() = "7"

		def IsParagraphSeperator()
			return This.IsParagraphSeparator()

	def IsSectionSeparator()
		return This.UnicodeDirectionNumber() = "8"

		def IsSectionSeperator()
			return This.IsSectionSeparator()

	def IsWhitespace()
		return This.UnicodeDirectionNumber() = "9"

	def IsOrientationNeutral()
		if This.UnicodeDirectionNumber() = "10" or This.IsANumber()
			return 1
		else
			return 0
		ok

		def IsNeutral()
			return This.IsOrientationNeutral()

	def IsLeftToRightEmbedding()
		return This.UnicodeDirectionNumber() = "11"

	def IsLeftToRightOverride()
		return This.UnicodeDirectionNumber() = "12"

	def IsLeftToRightIsolate()
		# Reserved for future implementation

	def IsRightToLeftIsolate()
		# Reserved for future implementation

	def IsRightToLeftArabic()
		return This.UnicodeDirectionNumber() = "13"

	def IsRightToLeftEmbedding()
		return This.UnicodeDirectionNumber() = "14"

	def IsRightToLeftOverride()
		return This.UnicodeDirectionNumber() = "15"

	def IsPopDirectionalFormat()
		return This.UnicodeDirectionNumber() = "16"

	def IsNonSpacingMark()
		return This.UnicodeDirectionNumber() = "17"

	def IsBoundaryNeutral()
		return This.UnicodeDirectionNumber() = "18"

	  #======================#
	 #   UNICODE CATEGORY   #
	#======================#

	def UnicodeCategoryNumber()
		return _CharCategoryNumber(This.Unicode())

	def UnicodeCategory()
		n = This.UnicodeCategoryNumber()
		return UnicodeCategoriesXT()[ ""+n ]

		def CharType()
			return This.UnicodeCategory()

			def CharTypeQ()
				return new stzString( This.CharType() )

		def UnicodeType()
			return This.UnicodeCategory()

			def TypeUnicodeQ()
				return new stzString( This.UnicodeType() )

		def Category()
			return This.UnicodeCategory()

			def CategoryQ()
				return new stzString( This.Category() )

	  #==============================#
	 #   CHARACTER CLASSIFICATION   #
	#==============================#

	def IsArabicShaddah()
		# U+0651 ARABIC SHADDA -- treated as a letter in Softanza.
		return This.Unicode() = 1617

	def IsLetter()
		# Use engine for the primary check
		nUnicode = This.Unicode()
		if StzEngineCharIsLetter(nUnicode) = 1
			return 1
		ok
		# Fallback: Arabic shaddah is considered a letter in Softanza
		if This.IsArabicShaddah()
			return 1
		ok
		return 0

		def IsALetter()
			return This.IsLetter()

	def IsNotLetter()
		return NOT This.IsLetter()

		def IsNotALetter()
			return This.IsNotLetter()

	def IsLetterOrSpaceOrChar(c)
		if This.IsLetter() or This.IsSpace() or This.Content() = c
			return 1
		else
			return 0
		ok

	def IsTheLetter(c)
		return This.Uppercased() = StzCharQ(c).Uppercased()

	def IsLetterOrNumber()
		if This.IsLetter() or This.IsANumber()
			return 1
		else
			return 0
		ok

		def IsNumberOrLetter()
			return This.IsLetterOrNumber()

		def IsALetterOrNumber()
			return This.IsLetterOrNumber()

		def IsANumberOrLetter()
			return This.IsLetterOrNumber()

	def IsLetterOrSpace()
		if This.IsLetter() or This.IsSpace()
			return 1
		else
			return 0
		ok

		def IsSpaceOrLetter()
			return This.IsLetterOrSpace()

	def IsLetterOrSpaceOrThisChar(pcChar)
		if This.IsLetter() or This.IsSpace() or This.Content() = pcChar
			return 1
		else
			return 0
		ok

		def IsSpaceOrLetterOrThisChar(pcChar)
			return This.IsLetterOrSpaceOrThisChar(pcChar)

	def IsEuropean()
		if This.IsEuropeanNumber() or This.IsEuropeanNumberSeparator() or
		   This.IsEuropeanNumberTerminator()
			return 1
		else
			return 0
		ok

	def IsSpace()
		return _CharIsSpace(This.Unicode())

	def IsUnicodeNumber()
		nCat = _CharCategoryNumber(This.Unicode())
		if nCat = 3 or nCat = 4 or nCat = 5 or
		   This.IsRomanNumber() or
		   This.IsMandarinNumber() or
		   This.IsIndianNumber()
			return 1
		else
			return 0
		ok

	def IsNotNumber()
		return NOT This.IsANumber()

	def IsDigit()
		# Use engine call
		return StzEngineCharIsDigit(This.Unicode()) = 1

		# IsADigit alias -- a char's digit test IS the engine-backed IsDigit above.
		# Without this, IsADigit fell through to the string-level inherited form
		# (FALSE for a single-char stzChar). Surfaced once QQ("3") correctly
		# resolves to a stzChar rather than being coerced to a stzNumber.
		def IsADigit()
			return This.IsDigit()

	def IsArabicNumber()
		if NOT This.IsANumber()
			return 0
		ok
		return ring_find( ArabicDigits(), 0+This.Content() ) > 0

	def IsANumber()
		return This.IsDigit() or This.IsCircledDigit()

	def IsIndianNumber()
		return ring_find(IndianNumbers(), This.Content()) > 0

	def IsRomanNumber()
		return ring_find(RomanNumbers(), This.Content()) > 0

	def IsMandarinNumber()
		return ring_find( MandarinNumbers(), This.Content() ) > 0

	def IsAscii()
		try
			ascii( This.Content() )
			return 1
		catch
			return 0
		done

	def IsAsciiLetter()
		return This.IsAscii() AND This.IsLetter()

	def IsPunctuation()
		return StzEngineUnicodeIsPunctuation(This.Unicode())

		def IsPunct()
			return This.IsPunctuation()

	def IsGeneralPunctuation()
		return StzFindFirst( GeneralPunctuationUnicodes(), This.Unicode() ) > 0

	def IsSupplementalPunctuation()
		return StzFindFirst( SupplementalPunctuationUnicodes(), This.Unicode() ) > 0

	def IsSymbol()
		return StzEngineUnicodeIsSymbol(This.Unicode())

	def IsNonChar()
		nU = This.Unicode()
		if nU >= 0xFDD0 and nU <= 0xFDEF
			return 1
		ok
		nLow = nU & 0xFFFF
		if nLow = 0xFFFE or nLow = 0xFFFF
			return 1
		ok
		return 0

	def IsMark()
		return StzEngineUnicodeIsMark(This.Unicode())

	def IsSeparator()
		return StzEngineUnicodeIsSpace(This.Unicode())

		def IsSeperator()
			return This.IsSeparator()

	def IsOneOfThese(pacChars)
		if CheckingParams()
			if NOT (isList(pacChars) and @IsListOfChars(pacChars))
				StzRaise("Incorrect param type! pacChars must be a list of chars.")
			ok
		ok

		if StzFindFirst(pacChars, This.Char()) > 0
			return 1
		else
			return 0
		ok

	def IsWordSeparator()
		if StzFindFirst( WordSeparators(), This.Char() ) > 0
			return 1
		else
			return 0
		ok

	def IsSentenceSeparator()
		if StzFindFirst( SentenceSeparators(), This.Char() ) > 0
			return 1
		else
			return 0
		ok

		def IsSentenceSeperator()
			return This.IsSentenceSeparator()

	def IsLineSeparator()
		return This.Content() = NL

		def IsLineSeperator()
			return This.IsLineSeparator()

	def IsWordNonLetterChar()
		return StzFindFirst( WordNonLetterChars(), This.Content() ) > 0

	  #==================#
	 #   MIRRORED CHAR  #
	#==================#

	def IsMirrored()
		nMirror = _CharMirrored(This.Unicode())
		return nMirror != This.Unicode()

	def UnicodeOfMirrored()
		return _CharMirrored(This.Unicode())

	def Mirrored()
		nMirrorUnicode = _CharMirrored(This.Unicode())
		cChar = CharFromUnicode(nMirrorUnicode)
		return cChar

	  #=========================#
	 #   LATIN CHAR VARIANTS  #
	#=========================#

	def IsLatin()
		return StzEngineUnicodeIsLatin(This.Unicode())

	def IsLatinLetter()
		nCp = This.Unicode()
		return StzEngineUnicodeIsLetter(nCp) AND StzEngineUnicodeIsLatin(nCp)

	def IsBasicLatin()
		return ring_find(_anBasicLatinUnicodes, This.Unicode()) > 0

	def IsLatin1Supplement()
		return ring_find(_anLatin1SupplementUnicodes, This.Unicode()) > 0

	def IsLatinExtendedA()
		return ring_find(_anLatinExtendedAUnicodes, This.Unicode()) > 0

	def IsLatinExtendedB()
		return ring_find(_anLatinExtendedBUnicodes, This.Unicode()) > 0

	def IsLatinExtendedAdditional()
		return ring_find(_anLatinExtendedAdditionalUnicodes, This.Unicode()) > 0

	def IsLatinExtendedC()
		return ring_find(_anLatinExtendedCUnicodes, This.Unicode()) > 0

	def IsLatinExtendedD()
		return ring_find(_anLatinExtendedDUnicodes, This.Unicode()) > 0

	def IsLatinExtendedE()
		return ring_find(_anLatinExtendedEUnicodes, This.Unicode()) > 0

	  #=========================#
	 #   ARABIC CHAR VARIANTS  #
	#=========================#

	def IsArabic()
		return StzEngineUnicodeIsArabic(This.Unicode())

	def IsArabicLetter()
		nCp = This.Unicode()
		return StzEngineUnicodeIsLetter(nCp) AND StzEngineUnicodeIsArabic(nCp)

	def IsBasicArabic()
		return ring_find(_anBasicArabicUnicodes, This.Unicode()) > 0

	def IsArabicSupplement()
		return ring_find(_anArabicSupplementUnicodes, This.Unicode()) > 0

	def IsArabicExtendedA()
		return ring_find(_anArabicExtendedAUnicodes, This.Unicode()) > 0

	def IsArabicExtended()
		return IsArabicExtendedA()

	def IsArabicPresentationForm()
		return ring_find(_anArabicPresentationFormUnicodes, This.Unicode()) > 0

	def IsArabicPresentationFormA()
		return ring_find(_anArabicPresentationFormAUnicodes, This.Unicode()) > 0

	def IsArabicPresentationFormB()
		return ring_find(_anArabicPresentationFormBUnicodes, This.Unicode()) > 0

	def IsArabicMathAlphabeticSymbol()
		return ring_find(_anArabicMathAlphabeticSymbolUnicodes, This.Unicode()) > 0

	def IsQuranicSign()
		return ring_find(QuranicSignUnicodes(), This.Unicode()) > 0

	def IsTurnedNumber()
		return ring_find(TurnedDigitUnicodes(), This.Unicode()) > 0

	  #=============================#
	 #   CIRCLED CHAR VARIANTS     #
	#=============================#

	def IsCircled()
		return ring_find(CircledCharUnicodes(), This.Unicode()) > 0

		def IsCircledChar()
			return This.IsCircled()

	def IsCircledNumber()
		return ring_find(CircledNumberUnicodes(), This.Unicode()) > 0

	def IsCircledDigit()
		return ring_find(CircledDigitUnicodes(), This.Unicode()) > 0

	def IsCircledLatinLetter()
		return ring_find(CircledLatinLetterUnicodes(), This.Unicode()) > 0

	def IsCircledLatinSmallLetter()
		return ring_find(CircledLatinSmallLetterUnicodes(), This.Unicode()) > 0

	def IsCircledLatinCapitalLetter()
		return ring_find(CircledLatinCapitalLetterUnicodes(), This.Unicode()) > 0

	def IsOtherCircledChar()
		return ring_find(OtherCircledCharUnicodes(), This.Unicode()) > 0

	  #==============================#
	 #   PRINTABLE / VISIBLE CHAR   #
	#==============================#

	def IsPrintable()
		nCat = _CharCategoryNumber(This.Unicode())
		if nCat = 9 or nCat = 10 or nCat = 11 or nCat = 12 or nCat = 13
			return 0
		ok
		return 1

	def IsNonPrintable()
		return NOT This.IsPrintable()

	def IsInvisible()
		return ring_find( InvisibleUnicodes(), This.Unicode() ) > 0

	def IsVisible()
		return NOT This.IsInvisible()

	  #========================#
	 #   LOCALE SEPARATOR     #
	#========================#

	def IsLocaleSeparator()
		return ring_find([ "-", "_" ], This.Content())

		def IsLocaleSeperator()
			return This.IsLocaleSeparator()

	  #======================#
	 #   UNICODE VERSION    #
	#======================#

	def IntroducedInUnicodeVersion()
		n = _CharUnicodeVersion(This.Unicode())
		if n > 0 and n <= len(_acUnicodeVersions)
			return _acUnicodeVersions[ n ]
		else
			StzRaise(stzCharError(:CanNotDefineUnicodeVersion))
		ok

	def UnicodeVersion()
		return This.IntroducedInUnicodeVersion()

	  #================#
	 #   CHAR CASE    #
	#================#

	def IsLower()
		return StzEngineCharIsLower(This.Unicode()) = 1

		def IsLowercase()
			return This.IsLower()

		def IsALowercase()
			return This.IsLower()

	def Lowercase()
		return StzLower(This.Content())

		def Lowercased()
			return This.Lowercase()

	def IsUppercase()
		return StzEngineCharIsUpper(This.Unicode()) = 1

		def IsAnUppercase()
			return This.IsUppercase()

	def Uppercase()
		return StzUpper(This.Content())

		def Uppercased()
			return This.Uppercase()

	def CharCase()
		if This.IsLowercase()
			return :Lowercase
		but This.IsUppercase()
			return :Uppercase
		ok

	  #================#
	 #   LANGUAGE     #
	#================#

	def DefaultLanguage()
		cResult = StzScriptQ(This.Script()).DefaultLanguage()
		return cResult

		def Language()
			return This.DefaultLanguage()

		def Langauge()
			return This.Language()

	  #============#
	 #   SCRIPT   #
	#============#

	def Script()
		nCode = _CharScriptCode(This.Unicode())
		nLen = len(_aUnicodeScriptsXT)

		cResult = :Undefined

		for i = 1 to nLen
			if _aUnicodeScriptsXT[i][1] = ""+nCode
				cResult = _aUnicodeScriptsXT[i][2]
				exit
			ok
		next

		return cResult

		def UnicodeScript()
			return Script()

	def ScriptCode()
		return _CharScriptCode(This.Unicode())

	def UnicodeScriptCode()
		return ScriptCode()

	def ScriptIs(pcScript)
		if NOT isString(pcScript)
			StzRaise("Incorrect param type! pcScript must be a string.")
		ok
		return This.Script() = StzCaseFold(pcScript)

	def IsLetterInScript(pcScript)
		if NOT isString(pcScript)
			StzRaise("Incorrect param type! pcScript must be a string.")
		ok
		return ( This.IsLetter() and This.Script() = StzCaseFold(pcScript) )

	def IsUnknownScript()
		return This.ScriptCode() = 0

	def IsInheritedScript()
		return This.ScriptCode() = 1

	def IsCommonScript()
		return This.ScriptCode() = 2

	def IsLatinScript()
		return This.ScriptCode() = 3

	def IsGreekScript()
		return This.ScriptCode() = 4

	def IsCyrillicScript()
		return This.ScriptCode() = 5

	def IsArmenianScript()
		return This.ScriptCode() = 6

	def IsHebrewScript()
		return This.ScriptCode() = 7

	def IsArabicScript()
		return This.ScriptCode() = 8

	def IsSyriacScript()
		return This.ScriptCode() = 9

	def IsThaanaScript()
		return This.ScriptCode() = 10

	def IsDevanagariScript()
		return This.ScriptCode() = 11

	def IsBengaliScript()
		return This.ScriptCode() = 12

	def IsGurmukhiScript()
		return This.ScriptCode() = 13

	def IsGujaratiScript()
		return This.ScriptCode() = 14

	def IsOriyaScript()
		return This.ScriptCode() = 15

	def IsTamilScript()
		return This.ScriptCode() = 16

	def IsTeluguScript()
		return This.ScriptCode() = 17

	def IsKannadaScript()
		return This.ScriptCode() = 18

	def IsMalayalamScript()
		return This.ScriptCode() = 19

	def IsSinhalaScript()
		return This.ScriptCode() = 20

	def IsThaiScript()
		return This.ScriptCode() = 21

	def IsLaoScript()
		return This.ScriptCode() = 22

	def IsTibetanScript()
		return This.ScriptCode() = 23

	def IsMyanmarScript()
		return This.ScriptCode() = 24

	def IsGeorgianScript()
		return This.ScriptCode() = 25

	def IsHangulScript()
		return This.ScriptCode() = 26

	def IsEthiopicScript()
		return This.ScriptCode() = 27

	def IsCherokeeScript()
		return This.ScriptCode() = 28

	def IsCanadianAboriginalScript()
		return This.ScriptCode() = 29

	def IsOghamScript()
		return This.ScriptCode() = 30

	def IsRunicScript()
		return This.ScriptCode() = 31

	def IsKhmerScript()
		return This.ScriptCode() = 32

	def IsMongolianScript()
		return This.ScriptCode() = 33

	def IsHiraganaScript()
		return This.ScriptCode() = 34

	def IsKatakanaScript()
		return This.ScriptCode() = 35

	def IsBopomofoScript()
		return This.ScriptCode() = 36

	def IsHanScript()
		return This.ScriptCode() = 37

	def IsYiScript()
		return This.ScriptCode() = 38

	def IsOldItalicScript()
		return This.ScriptCode() = 39

	def IsGothicScript()
		return This.ScriptCode() = 40

	def IsDeseretScript()
		return This.ScriptCode() = 41

	def IsTagalogScript()
		return This.ScriptCode() = 42

	def IsHanunooScript()
		return This.ScriptCode() = 43

	def IsBuhidScript()
		return This.ScriptCode() = 44

	def IsTagbanwaScript()
		return This.ScriptCode() = 45

	def IsCopticScript()
		return This.ScriptCode() = 46

	def IsLimbuScript()
		return This.ScriptCode() = 47

	def IsTaiLeScript()
		return This.ScriptCode() = 48

	def IsLinearBScript()
		return This.ScriptCode() = 49

	def IsUgariticScript()
		return This.ScriptCode() = 50

	def IsShavianScript()
		return This.ScriptCode() = 51

	def IsOsmanyaScript()
		return This.ScriptCode() = 52

	def IsCypriotScript()
		return This.ScriptCode() = 53

	def IsBrailleScript()
		return This.ScriptCode() = 54

	def IsBugineseScript()
		return This.ScriptCode() = 55

	def IsNewTaiLueScript()
		return This.ScriptCode() = 56

	def IsGlagoliticScript()
		return This.ScriptCode() = 57

	def IsTifinaghScript()
		return This.ScriptCode() = 58

	def IsSylotiNagriScript()
		return This.ScriptCode() = 59

	def IsOldPersianScript()
		return This.ScriptCode() = 60

	def IsKharoshthiScript()
		return This.ScriptCode() = 61

	def IsBalineseScript()
		return This.ScriptCode() = 62

	def IsCuneiformScript()
		return This.ScriptCode() = 63

	def IsPhoenicianScript()
		return This.ScriptCode() = 64

	def IsPhagsPaScript()
		return This.ScriptCode() = 65

	def IsNkoScript()
		return This.ScriptCode() = 66

	def IsSundaneseScript()
		return This.ScriptCode() = 67

	def IsLepchaScript()
		return This.ScriptCode() = 68

	def IsOlChikiScript()
		return This.ScriptCode() = 69

	def IsVaiScript()
		return This.ScriptCode() = 70

	def IsSaurashtraScript()
		return This.ScriptCode() = 71

	def IsKayahLiScript()
		return This.ScriptCode() = 72

	def IsRejangScript()
		return This.ScriptCode() = 73

	def IsLycianScript()
		return This.ScriptCode() = 74

	def IsCarianScript()
		return This.ScriptCode() = 75

	def IsLydianScript()
		return This.ScriptCode() = 76

	def IsChamScript()
		return This.ScriptCode() = 77

	def TaiThamScript()
		return This.ScriptCode() = 78

	def IsTaiVietScript()
		return This.ScriptCode() = 79

	def IsAvestanScript()
		return This.ScriptCode() = 80

	def IsEgyptianHieroglyphsScript()
		return This.ScriptCode() = 81

	def IsSamaritanScript()
		return This.ScriptCode() = 82

	def IsLisuScript()
		return This.ScriptCode() = 83

	def IsBamumScript()
		return This.ScriptCode() = 84

	def IsJavaneseScript()
		return This.ScriptCode() = 85

	def IsMeeteiMayekScript()
		return This.ScriptCode() = 86

	def IsImperialAramaicScript()
		return This.ScriptCode() = 87

	def IsOldSouthArabianScript()
		return This.ScriptCode() = 88

	def IsInscriptionalParthianScript()
		return This.ScriptCode() = 89

	def IsInscriptionalPahlaviScript()
		return This.ScriptCode() = 90

	def IsOldTurkicScript()
		return This.ScriptCode() = 91

	def IsKaithiScript()
		return This.ScriptCode() = 92

	def IsBatakScript()
		return This.ScriptCode() = 93

	def IsBrahmiScript()
		return This.ScriptCode() = 94

	def IsMandaicScript()
		return This.ScriptCode() = 95

	def IsChakmaScript()
		return This.ScriptCode() = 96

	def IsMeroiticCursiveScript()
		return This.ScriptCode() = 97

	def IsMeroiticHieroglyphsScript()
		return This.ScriptCode() = 98

	def IsMiaoScript()
		return This.ScriptCode() = 99

	def IsSharadaScript()
		return This.ScriptCode() = 100

	def IsSoraSompengScript()
		return This.ScriptCode() = 101

	def IsTakriScript()
		return This.ScriptCode() = 102

	def IsCaucasianAlbanianScript()
		return This.ScriptCode() = 103

	def IsBassaVahScript()
		return This.ScriptCode() = 104

	def IsDuployanScript()
		return This.ScriptCode() = 105

	def IsElbasanScript()
		return This.ScriptCode() = 106

	def IsGranthaScript()
		return This.ScriptCode() = 107

	def IsPahawhHmongScript()
		return This.ScriptCode() = 108

	def IsKhojkiScript()
		return This.ScriptCode() = 109

	def IsLinearAScript()
		return This.ScriptCode() = 110

	def IsMahajaniScript()
		return This.ScriptCode() = 111

	def IsManichaeanScript()
		return This.ScriptCode() = 112

	def IsMendeKikakuiScript()
		return This.ScriptCode() = 113

	def IsModiScript()
		return This.ScriptCode() = 114

	def IsMroScript()
		return This.ScriptCode() = 115

	def IsOldNorthArabianScript()
		return This.ScriptCode() = 116

	def IsNabataeanScript()
		return This.ScriptCode() = 117

	def IsPalmyreneScript()
		return This.ScriptCode() = 118

	def IsPauCinHauScript()
		return This.ScriptCode() = 119

	def IsOldPermicScript()
		return This.ScriptCode() = 120

	def IsPsalterPahlaviScript()
		return This.ScriptCode() = 121

	def IsSiddhamScript()
		return This.ScriptCode() = 122

	def IsKhudawadiScript()
		return This.ScriptCode() = 123

	def IsTirhutaScript()
		return This.ScriptCode() = 124

	def IsWarangCitiScript()
		return This.ScriptCode() = 125

	def IsAhomScript()
		return This.ScriptCode() = 126

	def IsAnatolianHieroglyphsScript()
		return This.ScriptCode() = 127

	def IsHatranScript()
		return This.ScriptCode() = 128

	def IsMultaniScript()
		return This.ScriptCode() = 129

	  #----------------------------#
	 #  CHAR RANGE (UpTo/DownTo)  #
	#----------------------------#

	def UpTo(pcChar)
		_nUtFrom_ = This.Unicode()
		_nUtTo_ = StzEngineCharUnicode(pcChar)
		if _nUtFrom_ >= _nUtTo_ return [] ok

		_aUtResult_ = []
		for _nUtI_ = _nUtFrom_ to _nUtTo_
			_aUtResult_ + StzCharQ(_nUtI_).Content()
		next
		return _aUtResult_

	def DownTo(pcChar)
		_nDtFrom_ = This.Unicode()
		_nDtTo_ = StzEngineCharUnicode(pcChar)
		if _nDtFrom_ <= _nDtTo_ return [] ok

		_aDtResult_ = []
		for _nDtI_ = _nDtFrom_ to _nDtTo_ step -1
			_aDtResult_ + StzCharQ(_nDtI_).Content()
		next
		return _aDtResult_
