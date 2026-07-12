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

func _CharIsSpace(_nUnicode_)
	return StzEngineUnicodeIsSpace(_nUnicode_)

func _CharCategoryNumber(_nUnicode_)
	return StzEngineUnicodeCategory(_nUnicode_)

func _CharBidiClass(_nUnicode_)
	return StzEngineUnicodeBidiClass(_nUnicode_)

func _CharMirrored(_nUnicode_)
	switch _nUnicode_
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
	return _nUnicode_

func _CharUnicodeVersion(_nUnicode_)
	if _nUnicode_ <= 0x7F return 1 ok
	if _nUnicode_ <= 0xFF return 1 ok
	if _nUnicode_ <= 0x24F return 1 ok
	if _nUnicode_ >= 0x0300 and _nUnicode_ <= 0x036F return 1 ok
	if _nUnicode_ >= 0x0370 and _nUnicode_ <= 0x03FF return 1 ok
	if _nUnicode_ >= 0x0400 and _nUnicode_ <= 0x04FF return 1 ok
	if _nUnicode_ >= 0x0590 and _nUnicode_ <= 0x05FF return 1 ok
	if _nUnicode_ >= 0x0600 and _nUnicode_ <= 0x06FF return 1 ok
	if _nUnicode_ >= 0x4E00 and _nUnicode_ <= 0x9FFF return 1 ok
	if _nUnicode_ >= 0xAC00 and _nUnicode_ <= 0xD7AF return 2 ok
	if _nUnicode_ >= 0x0900 and _nUnicode_ <= 0x097F return 1 ok
	if _nUnicode_ >= 0x1F600 and _nUnicode_ <= 0x1F64F return 6 ok
	if _nUnicode_ >= 0x1F300 and _nUnicode_ <= 0x1F5FF return 6 ok
	return 1

func _CharScriptCode(_nUnicode_)
	# Codes index _aUnicodeScriptsXT (stzCharData.ring): 3 Latin, 4 Greek,
	# 5 Cyrillic, 6 Armenian, 7 Hebrew, 8 Arabic, 11 Devanagari, 21 Thai,
	# 26 Hangul, 34 Hiragana, 35 Katakana, 37 Han.
# Common script (code 2) first: spaces, digits, punctuation and
	# symbols are script-neutral, NOT Latin (UAX #24).
	if _nUnicode_ <= 0x40 return 2 ok					# space, digits, punctuation
	if _nUnicode_ >= 0x5B and _nUnicode_ <= 0x60 return 2 ok		# [ \ ] ^ _ `
	if _nUnicode_ >= 0x7B and _nUnicode_ <= 0xBF return 2 ok		# { | } ~ + Latin-1 symbols
	if _nUnicode_ = 0xD7 or _nUnicode_ = 0xF7 return 2 ok		# multiply / divide signs
	if _nUnicode_ >= 0x300 and _nUnicode_ <= 0x36F return 1 ok		# combining marks -> Inherited
	if _nUnicode_ <= 0x24F return 3 ok				# Basic Latin + Latin-1 + Latin Ext-A/B
	if _nUnicode_ >= 0x2160 and _nUnicode_ <= 0x217F return 3 ok	# Roman numerals -> Latin (UAX #24)
	if _nUnicode_ >= 0x0370 and _nUnicode_ <= 0x03FF return 4 ok		# Greek
	if _nUnicode_ >= 0x0400 and _nUnicode_ <= 0x04FF return 5 ok		# Cyrillic
	if _nUnicode_ >= 0x0530 and _nUnicode_ <= 0x058F return 6 ok		# Armenian
	if _nUnicode_ >= 0x0590 and _nUnicode_ <= 0x05FF return 7 ok		# Hebrew
	if _nUnicode_ >= 0x064B and _nUnicode_ <= 0x065F return 1 ok	# Arabic diacritics -> Inherited
	if _nUnicode_ = 0x0670 return 1 ok				# superscript alef -> Inherited
	if _nUnicode_ >= 0x0600 and _nUnicode_ <= 0x06FF return 8 ok		# Arabic
	if _nUnicode_ >= 0x0900 and _nUnicode_ <= 0x097F return 11 ok	# Devanagari
	if _nUnicode_ >= 0x0A80 and _nUnicode_ <= 0x0AFF return 14 ok	# Gujarati
	if _nUnicode_ >= 0x0E00 and _nUnicode_ <= 0x0E7F return 21 ok	# Thai
	if _nUnicode_ >= 0x3040 and _nUnicode_ <= 0x309F return 34 ok	# Hiragana
	if _nUnicode_ >= 0x30A0 and _nUnicode_ <= 0x30FF return 35 ok	# Katakana
	if _nUnicode_ >= 0x4E00 and _nUnicode_ <= 0x9FFF return 37 ok	# CJK Unified Ideographs -> Han
	if _nUnicode_ >= 0xAC00 and _nUnicode_ <= 0xD7AF return 26 ok	# Hangul syllables
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

func StzSpace(_n_)
	return Copy(" ", _n_)

	func Space(_n_)
		return StzSpace(_n_)

	func @Space(_n_)
		return StzSpace(_n_)

func StzCharQ(p)
	return new stzStringChar(p)

	func CQ(p)
		return StzCharQ(p)

func StzCharObj(_n_)
	_nMax_ = MaxUnicodeNumber()
	if NOT ( isNumber(_n_) and _n_ <= _nMax_ )
		StzRaise("Incorrect param type! p must be a number less then " + _nMax_ + "!")
	ok
	return StzCharQ(_n_).Content()

	func UnicodeChar(_n_)
		return StzChar(_n_)

	func UChar(_n_)
		return StzChar(_n_)

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
		_cStringified_ = ""+ pStrOrNbr
		if ring_substr1(_cStringified_, ".") > 0
			return 0
		ok
		_n_ = 0+ _cStringified_
		if _n_ < 0 or _n_ > 9
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

func StzUnicodeToHexUnicode(_n_)
	_oChar_ = new stzStringChar(_n_)
	return _oChar_.HexUnicode()

	func UnicodeToHexUnicode(_n_)
		return StzUnicodeToHexUnicode(_n_)

func StzHexUnicodeToUnicode(cHex)
	_oChar_ = new stzStringChar(cHex)
	return _oChar_.Unicode()

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

func StzUnicodeToChar(_nUnicode_)
	_oChar_ = new stzStringChar(_nUnicode_)
	return _oChar_.Content()

	func UnicodeToChar(_nUnicode_)
		return StzUnicodeToChar(_nUnicode_)

	func @Char(_nUnicode_)
		return StzUnicodeToChar(_nUnicode_)

func StzUnicodeSectionToListOfChars(nUnicode1, nUnicode2)
	_aResult_ = []
	for _nUnicode_ = nUnicode1 to nUnicode2
		_aResult_ + StzUnicodeToChar( _nUnicode_ )
	next
	return _aResult_

	func UnicodeSectionToListOfChars(nUnicode1, nUnicode2)
		return StzUnicodeSectionToListOfChars(nUnicode1, nUnicode2)

func StzUnicodeSectionToListOfStzChars(nUnicode1, nUnicode2)
	_aResult_ = []
	for _nUnicode_ = nUnicode1 to nUnicode2
		_aResult_ + new stzStringChar( _nUnicode_ )
	next
	return _aResult_

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
	_oTempChar_ = new stzStringChar(c)
	return _oTempChar_.Script()

	func CharScript(c)
		return StzCharScript(c)

func StzCharIsArabicShaddah(c)
	_oChar_ = new stzStringChar(c)
	return _oChar_.IsArabicShaddah()

	func CharIsArabicShaddah(c)
		return StzCharIsArabicShaddah(c)

func StzCharIsArabic7arakah(c)
	_oChar_ = new stzStringChar(c)
	return _oChar_.IsArabic7arakah()

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
	_nUnicode_ = Unicode(pcChar)
	_n_ = StzListOfNumbersQ( 1: NumberOfUnicodeChars()).ANumberOtherThan(_nUnicode_)
	_cResult_ = StzCharQ(_n_).Content()
	return _cResult_

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
	_oTemp_ = new stzString(pcStr)
	return _oTemp_.NthChar(1)

	func FirstCharOf(pcStr)
		return StzFirstCharOf(pcStr)

	func FirstCharIn(pcStr)
		return StzFirstCharOf(pcStr)

func StzLastCharOf(pcStr)
	_oTemp_ = new stzString(pcStr)
	return _oTemp_.NthChar(_oTemp_.NumberOfChars())

	func LastCharOf(pcStr)
		return StzLastCharOf(pcStr)

	func LastCharIn(pcStr)
		return StzLastCharOf(pcStr)

func StzFirstLetterOf(pcStr)
	_oStzStr_ = new stzString(pcStr)
	for i = 1 to _oStzStr_.NumberOfChars()
		if StzCharQ(_oStzStr_[i]).IsLetter()
			return _oStzStr_[i]
		ok
	next

	func FirstLetterOf(pcStr)
		return StzFirstLetterOf(pcStr)

	func FirstLetterIn(pcStr)
		return StzFirstLetterOf(pcStr)

func StzLastLetterOf(pcStr)
	_oTemp_ = new stzString(pcStr)
	_nLen_ = _oTemp_.NumberOfChars()
	for _i = _nLen_ to 1 step -1
		_cChar_ = _oTemp_.NthChar(_i)
		if StzCharQ(_cChar_).IsLetter()
			return _cChar_
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

func StzNthChar(_n_, _str_)
	if isString(_n_) and isNumber(_str_)
		_temp_ = _n_
		_n_ = _str_
		_str_ = _temp_
	ok

	if CheckingParams()
		if NOT ( isNumber(_n_) and isString(_str_) )
			StzRaise("Incorrect param type! n must be a number and str must be a string.")
		ok
	ok

	_oTemp_ = new stzString(_str_)
	return _oTemp_.NthChar(_n_)

	func NthChar(_n_, _str_)
		return StzNthChar(_n_, _str_)

	func @NthChar(_n_, _str_)
		return StzNthChar(_n_, _str_)

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

		_acChars_ = StzStringQ(p).Chars()
	else
		_acChars_ = p
	ok

	_nLen_ = len(_acChars_)
	_bResult_ = 1

	for i = 1 to _nLen_
		if NOT StzIsVowel(_acChars_[i])
			_bResult_ = 0
			exit
		ok
	next

	return _bResult_

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

func StzCharByName(_cName_)
	_nCp_ = StzCodepointByName(_cName_)
	if _nCp_ < 0
		StzRaise("Character name not found: " + _cName_)
	ok
	return StzChar(_nCp_)

	func CharByName(_cName_)
		return StzCharByName(_cName_)

	func @CharByName(_cName_)
		return StzCharByName(_cName_)


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

			_oStr_ = StzStringQ(pChar)

			if _oStr_.NumberOfChars() = 1
				@oString = new stzString(pChar)

			but _oStr_.RepresentsNumberInUnicodeHexForm()
				# "U+06A2" -- drop the 2-char "U+" prefix before hex->decimal.
				# ToDecimal() returns a STRING -- coerce to a number, else
				# StzEngineCharToUtf8 mis-encodes it (1-byte garbage).
				_nLenU_ = _oStr_.NumberOfChars()
				_cHexU_ = _oStr_.Section(3, _nLenU_)
				_oHexU_ = StzHexNumberQ(_cHexU_)
				_nCiUni_ = 0 + _oHexU_.ToDecimal()
				@oString = new stzString(StzEngineCharToUtf8(_nCiUni_))

			but _oStr_.RepresentsNumberInHexForm()
				_nCiUni_ = 0 + StzHexNumberQ(pChar).ToDecimal()
				@oString = new stzString(StzEngineCharToUtf8(_nCiUni_))

			but _oStr_.IsCharName()
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
		_nDecUnicode_ = This.Unicode()
		_acHexDigits_ = "0123456789ABCDEF"
		_cResult_ = ""

		for i = 1 to 4
			_nDigit_ = 0+ Q(_nDecUnicode_ % 16).IntegerPart() + 1
			_cResult_ = _acHexDigits_[_nDigit_] + _cResult_
			_nDecUnicode_ = _nDecUnicode_ / 16
		next

		return "U+" + _cResult_

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

	# Replace the char with the given one (mutating; the single update point).
	def Update(pChar)
		if CheckingParams() = 1
			if isList(pChar) and Q(pChar).IsWithOrByOrUsingNamedParam()
				pChar = pChar[2]
			ok
		ok

		if isString(pChar)
			@oString = new stzString(pChar)

		but ring_Type(pChar) = "NUMBER"
			_cBuf_ = space(4)
			_nLen_ = StzEngineCharToUtf8(pChar, _cBuf_, 4)
			@oString = new stzString(StzLeft(_cBuf_, _nLen_))
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

	# The value the char would be updated to (passive twin of Update).
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
		_cName_ = This.Name()
		return BothStringsAreEqualCS(pcName, _cName_, 0)

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

	# TRUE if the char belongs to the Arabic Fraction Unicode range.
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
			_cDigit_ = _aIndianDigits2_[_iLoopIndianDigits2_]
			if _cDigit_ = This.Content()
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

	# The numeric Unicode general-category code of the char.
	def UnicodeCategoryNumber()
		return _CharCategoryNumber(This.Unicode())

	# The Unicode general category of the char.
	def UnicodeCategory()
		_n_ = This.UnicodeCategoryNumber()
		return UnicodeCategoriesXT()[ ""+_n_ ]

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

	# TRUE if the char is the Arabic shaddah (U+0651).
	def IsArabicShaddah()
		# U+0651 ARABIC SHADDA -- treated as a letter in Softanza.
		return This.Unicode() = 1617

	# TRUE if the char is a letter (Unicode-aware).
	def IsLetter()
		# Use engine for the primary check
		_nUnicode_ = This.Unicode()
		if StzEngineCharIsLetter(_nUnicode_) = 1
			return 1
		ok
		# Fallback: Arabic shaddah is considered a letter in Softanza
		if This.IsArabicShaddah()
			return 1
		ok
		return 0

		def IsALetter()
			return This.IsLetter()

	# TRUE if the char is NOT a letter.
	def IsNotLetter()
		return NOT This.IsLetter()

		def IsNotALetter()
			return This.IsNotLetter()

	# TRUE if the char is a letter, a space, or the given char.
	def IsLetterOrSpaceOrChar(c)
		if This.IsLetter() or This.IsSpace() or This.Content() = c
			return 1
		else
			return 0
		ok

	# TRUE if the char is the given letter, case-insensitively.
	def IsTheLetter(c)
		return This.Uppercased() = StzCharQ(c).Uppercased()

	# TRUE if the char is a letter or a number char.
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

	# TRUE if the char is a letter or a space.
	def IsLetterOrSpace()
		if This.IsLetter() or This.IsSpace()
			return 1
		else
			return 0
		ok

		def IsSpaceOrLetter()
			return This.IsLetterOrSpace()

	# TRUE if the char is a letter, a space, or the given char.
	def IsLetterOrSpaceOrThisChar(pcChar)
		if This.IsLetter() or This.IsSpace() or This.Content() = pcChar
			return 1
		else
			return 0
		ok

		def IsSpaceOrLetterOrThisChar(pcChar)
			return This.IsLetterOrSpaceOrThisChar(pcChar)

	# TRUE if the char is a European number, separator or terminator
	# (bidi classes).
	def IsEuropean()
		if This.IsEuropeanNumber() or This.IsEuropeanNumberSeparator() or
		   This.IsEuropeanNumberTerminator()
			return 1
		else
			return 0
		ok

	# TRUE if the char is a space char (Unicode-aware).
	def IsSpace()
		return _CharIsSpace(This.Unicode())

	# TRUE if the char is a Unicode number char (category N).
	def IsUnicodeNumber()
		_nCat_ = _CharCategoryNumber(This.Unicode())
		if _nCat_ = 3 or _nCat_ = 4 or _nCat_ = 5 or
		   This.IsRomanNumber() or
		   This.IsMandarinNumber() or
		   This.IsIndianNumber()
			return 1
		else
			return 0
		ok

	# TRUE if the char is NOT a number char.
	def IsNotNumber()
		return NOT This.IsANumber()

	# TRUE if the char is a digit.
	def IsDigit()
		# Use engine call
		return StzEngineCharIsDigit(This.Unicode()) = 1

		# IsADigit alias -- a char's digit test IS the engine-backed IsDigit above.
		# Without this, IsADigit fell through to the string-level inherited form
		# (FALSE for a single-char stzChar). Surfaced once QQ("3") correctly
		# resolves to a stzChar rather than being coerced to a stzNumber.
		def IsADigit()
			return This.IsDigit()

	# TRUE if the char is an Arabic digit.
	def IsArabicNumber()
		if NOT This.IsANumber()
			return 0
		ok
		return ring_find( ArabicDigits(), 0+This.Content() ) > 0

	# TRUE if the char is a digit or a circled digit.
	def IsANumber()
		return This.IsDigit() or This.IsCircledDigit()

	# TRUE if the char is an Indian numeral.
	def IsIndianNumber()
		return ring_find(IndianNumbers(), This.Content()) > 0

	# TRUE if the char is a Roman numeral.
	def IsRomanNumber()
		return ring_find(RomanNumbers(), This.Content()) > 0

	# TRUE if the char is a Mandarin numeral.
	def IsMandarinNumber()
		return ring_find( MandarinNumbers(), This.Content() ) > 0

	# TRUE if the char is ASCII (codepoint below 128).
	def IsAscii()
		try
			ascii( This.Content() )
			return 1
		catch
			return 0
		done

	# TRUE if the char is an ASCII letter (A-Z or a-z).
	def IsAsciiLetter()
		return This.IsAscii() AND This.IsLetter()

	# TRUE if the char is a punctuation char.
	def IsPunctuation()
		return StzEngineUnicodeIsPunctuation(This.Unicode())

		def IsPunct()
			return This.IsPunctuation()

	# TRUE if the char belongs to the General Punctuation Unicode block.
	def IsGeneralPunctuation()
		return StzFindFirst( GeneralPunctuationUnicodes(), This.Unicode() ) > 0

	# TRUE if the char belongs to the Supplemental Punctuation Unicode block.
	def IsSupplementalPunctuation()
		return StzFindFirst( SupplementalPunctuationUnicodes(), This.Unicode() ) > 0

	# TRUE if the char is a symbol char (Unicode category S).
	def IsSymbol()
		return StzEngineUnicodeIsSymbol(This.Unicode())

	# TRUE if the codepoint is a Unicode noncharacter.
	def IsNonChar()
		_nU_ = This.Unicode()
		if _nU_ >= 0xFDD0 and _nU_ <= 0xFDEF
			return 1
		ok
		_nLow_ = _nU_ & 0xFFFF
		if _nLow_ = 0xFFFE or _nLow_ = 0xFFFF
			return 1
		ok
		return 0

	# TRUE if the char is a combining mark (Unicode category M).
	def IsMark()
		return StzEngineUnicodeIsMark(This.Unicode())

	# TRUE if the char is a separator (Unicode space class).
	def IsSeparator()
		return StzEngineUnicodeIsSpace(This.Unicode())

		def IsSeperator()
			return This.IsSeparator()

	# TRUE if the char is one of the given chars.
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

	# TRUE if the char separates words (per the Softanza separators list).
	def IsWordSeparator()
		if StzFindFirst( WordSeparators(), This.Char() ) > 0
			return 1
		else
			return 0
		ok

	# TRUE if the char separates sentences (per the Softanza separators list).
	def IsSentenceSeparator()
		if StzFindFirst( SentenceSeparators(), This.Char() ) > 0
			return 1
		else
			return 0
		ok

		def IsSentenceSeperator()
			return This.IsSentenceSeparator()

	# TRUE if the char is the newline char.
	def IsLineSeparator()
		return This.Content() = NL

		def IsLineSeperator()
			return This.IsLineSeparator()

	# TRUE if the char is one of the non-letter chars allowed inside
	# words (hyphen, apostrophe, ...).
	def IsWordNonLetterChar()
		return StzFindFirst( WordNonLetterChars(), This.Content() ) > 0

	  #==================#
	 #   MIRRORED CHAR  #
	#==================#

	# TRUE if the char has a mirrored counterpart (like the parentheses).
	def IsMirrored()
		_nMirror_ = _CharMirrored(This.Unicode())
		return _nMirror_ != This.Unicode()

	# The codepoint of the char's mirrored counterpart.
	def UnicodeOfMirrored()
		return _CharMirrored(This.Unicode())

	# The mirrored counterpart of the char.
	def Mirrored()
		_nMirrorUnicode_ = _CharMirrored(This.Unicode())
		_cChar_ = CharFromUnicode(_nMirrorUnicode_)
		return _cChar_

	  #=========================#
	 #   LATIN CHAR VARIANTS  #
	#=========================#

	# TRUE if the char is a Latin char (engine check).
	def IsLatin()
		return StzEngineUnicodeIsLatin(This.Unicode())

	# TRUE if the char is a Latin letter.
	def IsLatinLetter()
		_nCp_ = This.Unicode()
		return StzEngineUnicodeIsLetter(_nCp_) AND StzEngineUnicodeIsLatin(_nCp_)

	# TRUE if the char belongs to the Basic Latin Unicode range.
	def IsBasicLatin()
		return ring_find(_anBasicLatinUnicodes, This.Unicode()) > 0

	# TRUE if the char belongs to the Latin1 Supplement Unicode
	# range.
	def IsLatin1Supplement()
		return ring_find(_anLatin1SupplementUnicodes, This.Unicode()) > 0

	# TRUE if the char belongs to the Latin Extended A Unicode
	# range.
	def IsLatinExtendedA()
		return ring_find(_anLatinExtendedAUnicodes, This.Unicode()) > 0

	# TRUE if the char belongs to the Latin Extended B Unicode
	# range.
	def IsLatinExtendedB()
		return ring_find(_anLatinExtendedBUnicodes, This.Unicode()) > 0

	# TRUE if the char belongs to the Latin Extended Additional
	# Unicode range.
	def IsLatinExtendedAdditional()
		return ring_find(_anLatinExtendedAdditionalUnicodes, This.Unicode()) > 0

	# TRUE if the char belongs to the Latin Extended C Unicode
	# range.
	def IsLatinExtendedC()
		return ring_find(_anLatinExtendedCUnicodes, This.Unicode()) > 0

	# TRUE if the char belongs to the Latin Extended D Unicode
	# range.
	def IsLatinExtendedD()
		return ring_find(_anLatinExtendedDUnicodes, This.Unicode()) > 0

	# TRUE if the char belongs to the Latin Extended E Unicode
	# range.
	def IsLatinExtendedE()
		return ring_find(_anLatinExtendedEUnicodes, This.Unicode()) > 0

	  #=========================#
	 #   ARABIC CHAR VARIANTS  #
	#=========================#

	# TRUE if the char is an Arabic char (engine check).
	def IsArabic()
		return StzEngineUnicodeIsArabic(This.Unicode())

	# TRUE if the char is an Arabic letter.
	def IsArabicLetter()
		_nCp_ = This.Unicode()
		return StzEngineUnicodeIsLetter(_nCp_) AND StzEngineUnicodeIsArabic(_nCp_)

	# TRUE if the char belongs to the Basic Arabic Unicode range.
	def IsBasicArabic()
		return ring_find(_anBasicArabicUnicodes, This.Unicode()) > 0

	# TRUE if the char belongs to the Arabic Supplement Unicode
	# range.
	def IsArabicSupplement()
		return ring_find(_anArabicSupplementUnicodes, This.Unicode()) > 0

	# TRUE if the char belongs to the Arabic Extended A Unicode
	# range.
	def IsArabicExtendedA()
		return ring_find(_anArabicExtendedAUnicodes, This.Unicode()) > 0

	# TRUE if the char belongs to the Arabic Extended-A range.
	def IsArabicExtended()
		return IsArabicExtendedA()

	# TRUE if the char belongs to the Arabic Presentation Form
	# Unicode range.
	def IsArabicPresentationForm()
		return ring_find(_anArabicPresentationFormUnicodes, This.Unicode()) > 0

	# TRUE if the char belongs to the Arabic Presentation Form A
	# Unicode range.
	def IsArabicPresentationFormA()
		return ring_find(_anArabicPresentationFormAUnicodes, This.Unicode()) > 0

	# TRUE if the char belongs to the Arabic Presentation Form B
	# Unicode range.
	def IsArabicPresentationFormB()
		return ring_find(_anArabicPresentationFormBUnicodes, This.Unicode()) > 0

	# TRUE if the char belongs to the Arabic Math Alphabetic Symbol
	# Unicode range.
	def IsArabicMathAlphabeticSymbol()
		return ring_find(_anArabicMathAlphabeticSymbolUnicodes, This.Unicode()) > 0

	# TRUE if the char belongs to the Quranic Sign Unicode range.
	def IsQuranicSign()
		return ring_find(QuranicSignUnicodes(), This.Unicode()) > 0

	# TRUE if the char belongs to the Turned Number Unicode range.
	def IsTurnedNumber()
		return ring_find(TurnedDigitUnicodes(), This.Unicode()) > 0

	  #=============================#
	 #   CIRCLED CHAR VARIANTS     #
	#=============================#

	# TRUE if the char belongs to the Circled Unicode range.
	def IsCircled()
		return ring_find(CircledCharUnicodes(), This.Unicode()) > 0

		def IsCircledChar()
			return This.IsCircled()

	# TRUE if the char belongs to the Circled Number Unicode range.
	def IsCircledNumber()
		return ring_find(CircledNumberUnicodes(), This.Unicode()) > 0

	# TRUE if the char belongs to the Circled Digit Unicode range.
	def IsCircledDigit()
		return ring_find(CircledDigitUnicodes(), This.Unicode()) > 0

	# TRUE if the char belongs to the Circled Latin Letter Unicode
	# range.
	def IsCircledLatinLetter()
		return ring_find(CircledLatinLetterUnicodes(), This.Unicode()) > 0

	# TRUE if the char belongs to the Circled Latin Small Letter
	# Unicode range.
	def IsCircledLatinSmallLetter()
		return ring_find(CircledLatinSmallLetterUnicodes(), This.Unicode()) > 0

	# TRUE if the char belongs to the Circled Latin Capital Letter
	# Unicode range.
	def IsCircledLatinCapitalLetter()
		return ring_find(CircledLatinCapitalLetterUnicodes(), This.Unicode()) > 0

	# TRUE if the char belongs to the Other Circled Char Unicode
	# range.
	def IsOtherCircledChar()
		return ring_find(OtherCircledCharUnicodes(), This.Unicode()) > 0

	  #==============================#
	 #   PRINTABLE / VISIBLE CHAR   #
	#==============================#

	def IsPrintable()
		_nCat_ = _CharCategoryNumber(This.Unicode())
		if _nCat_ = 9 or _nCat_ = 10 or _nCat_ = 11 or _nCat_ = 12 or _nCat_ = 13
			return 0
		ok
		return 1

	def IsNonPrintable()
		return NOT This.IsPrintable()

	# TRUE if the char belongs to the Invisible Unicode range.
	def IsInvisible()
		return ring_find( InvisibleUnicodes(), This.Unicode() ) > 0

	def IsVisible()
		return NOT This.IsInvisible()

	  #========================#
	 #   LOCALE SEPARATOR     #
	#========================#

	# TRUE if the char is a locale separator (- or _).
	def IsLocaleSeparator()
		return ring_find([ "-", "_" ], This.Content())

		def IsLocaleSeperator()
			return This.IsLocaleSeparator()

	  #======================#
	 #   UNICODE VERSION    #
	#======================#

	# The Unicode version that introduced this char.
	def IntroducedInUnicodeVersion()
		_n_ = _CharUnicodeVersion(This.Unicode())
		if _n_ > 0 and _n_ <= len(_acUnicodeVersions)
			return _acUnicodeVersions[ _n_ ]
		else
			StzRaise(stzCharError(:CanNotDefineUnicodeVersion))
		ok

	# Same as IntroducedInUnicodeVersion.
	def UnicodeVersion()
		return This.IntroducedInUnicodeVersion()

	  #================#
	 #   CHAR CASE    #
	#================#

	# TRUE if the char is lowercase.
	def IsLower()
		return StzEngineCharIsLower(This.Unicode()) = 1

		def IsLowercase()
			return This.IsLower()

		def IsALowercase()
			return This.IsLower()

	# The lowercase form of the char.
	def Lowercase()
		return StzLower(This.Content())

		def Lowercased()
			return This.Lowercase()

	# TRUE if the char is uppercase.
	def IsUppercase()
		return StzEngineCharIsUpper(This.Unicode()) = 1

		def IsAnUppercase()
			return This.IsUppercase()

	# The uppercase form of the char.
	def Uppercase()
		return StzUpper(This.Content())

		def Uppercased()
			return This.Uppercase()

	# The case of the char: :Lowercase, :Uppercase or NULL.
	def CharCase()
		if This.IsLowercase()
			return :Lowercase
		but This.IsUppercase()
			return :Uppercase
		ok

	  #================#
	 #   LANGUAGE     #
	#================#

	# The default language of the char's script.
	def DefaultLanguage()
		_cResult_ = StzScriptQ(This.Script()).DefaultLanguage()
		return _cResult_

		def Language()
			return This.DefaultLanguage()

		def Langauge()
			return This.Language()

	  #============#
	 #   SCRIPT   #
	#============#

	# The script the char belongs to.
	def Script()
		_nCode_ = _CharScriptCode(This.Unicode())
		_nLen_ = len(_aUnicodeScriptsXT)

		_cResult_ = :Undefined

		for i = 1 to _nLen_
			if _aUnicodeScriptsXT[i][1] = ""+_nCode_
				_cResult_ = _aUnicodeScriptsXT[i][2]
				exit
			ok
		next

		return _cResult_

		def UnicodeScript()
			return Script()

	# The numeric code of the char's script.
	def ScriptCode()
		return _CharScriptCode(This.Unicode())

	def UnicodeScriptCode()
		return ScriptCode()

	# TRUE if the char's script is the given one.
	def ScriptIs(pcScript)
		if NOT isString(pcScript)
			StzRaise("Incorrect param type! pcScript must be a string.")
		ok
		return This.Script() = StzCaseFold(pcScript)

	# TRUE if the char is a letter of the given script.
	def IsLetterInScript(pcScript)
		if NOT isString(pcScript)
			StzRaise("Incorrect param type! pcScript must be a string.")
		ok
		return ( This.IsLetter() and This.Script() = StzCaseFold(pcScript) )

	# TRUE if the char belongs to the Unknown script.
	def IsUnknownScript()
		return This.ScriptCode() = 0

	# TRUE if the char belongs to the Inherited script.
	def IsInheritedScript()
		return This.ScriptCode() = 1

	# TRUE if the char belongs to the Common script.
	def IsCommonScript()
		return This.ScriptCode() = 2

	# TRUE if the char belongs to the Latin script.
	def IsLatinScript()
		return This.ScriptCode() = 3

	# TRUE if the char belongs to the Greek script.
	def IsGreekScript()
		return This.ScriptCode() = 4

	# TRUE if the char belongs to the Cyrillic script.
	def IsCyrillicScript()
		return This.ScriptCode() = 5

	# TRUE if the char belongs to the Armenian script.
	def IsArmenianScript()
		return This.ScriptCode() = 6

	# TRUE if the char belongs to the Hebrew script.
	def IsHebrewScript()
		return This.ScriptCode() = 7

	# TRUE if the char belongs to the Arabic script.
	def IsArabicScript()
		return This.ScriptCode() = 8

	# TRUE if the char belongs to the Syriac script.
	def IsSyriacScript()
		return This.ScriptCode() = 9

	# TRUE if the char belongs to the Thaana script.
	def IsThaanaScript()
		return This.ScriptCode() = 10

	# TRUE if the char belongs to the Devanagari script.
	def IsDevanagariScript()
		return This.ScriptCode() = 11

	# TRUE if the char belongs to the Bengali script.
	def IsBengaliScript()
		return This.ScriptCode() = 12

	# TRUE if the char belongs to the Gurmukhi script.
	def IsGurmukhiScript()
		return This.ScriptCode() = 13

	# TRUE if the char belongs to the Gujarati script.
	def IsGujaratiScript()
		return This.ScriptCode() = 14

	# TRUE if the char belongs to the Oriya script.
	def IsOriyaScript()
		return This.ScriptCode() = 15

	# TRUE if the char belongs to the Tamil script.
	def IsTamilScript()
		return This.ScriptCode() = 16

	# TRUE if the char belongs to the Telugu script.
	def IsTeluguScript()
		return This.ScriptCode() = 17

	# TRUE if the char belongs to the Kannada script.
	def IsKannadaScript()
		return This.ScriptCode() = 18

	# TRUE if the char belongs to the Malayalam script.
	def IsMalayalamScript()
		return This.ScriptCode() = 19

	# TRUE if the char belongs to the Sinhala script.
	def IsSinhalaScript()
		return This.ScriptCode() = 20

	# TRUE if the char belongs to the Thai script.
	def IsThaiScript()
		return This.ScriptCode() = 21

	# TRUE if the char belongs to the Lao script.
	def IsLaoScript()
		return This.ScriptCode() = 22

	# TRUE if the char belongs to the Tibetan script.
	def IsTibetanScript()
		return This.ScriptCode() = 23

	# TRUE if the char belongs to the Myanmar script.
	def IsMyanmarScript()
		return This.ScriptCode() = 24

	# TRUE if the char belongs to the Georgian script.
	def IsGeorgianScript()
		return This.ScriptCode() = 25

	# TRUE if the char belongs to the Hangul script.
	def IsHangulScript()
		return This.ScriptCode() = 26

	# TRUE if the char belongs to the Ethiopic script.
	def IsEthiopicScript()
		return This.ScriptCode() = 27

	# TRUE if the char belongs to the Cherokee script.
	def IsCherokeeScript()
		return This.ScriptCode() = 28

	# TRUE if the char belongs to the Canadian Aboriginal script.
	def IsCanadianAboriginalScript()
		return This.ScriptCode() = 29

	# TRUE if the char belongs to the Ogham script.
	def IsOghamScript()
		return This.ScriptCode() = 30

	# TRUE if the char belongs to the Runic script.
	def IsRunicScript()
		return This.ScriptCode() = 31

	# TRUE if the char belongs to the Khmer script.
	def IsKhmerScript()
		return This.ScriptCode() = 32

	# TRUE if the char belongs to the Mongolian script.
	def IsMongolianScript()
		return This.ScriptCode() = 33

	# TRUE if the char belongs to the Hiragana script.
	def IsHiraganaScript()
		return This.ScriptCode() = 34

	# TRUE if the char belongs to the Katakana script.
	def IsKatakanaScript()
		return This.ScriptCode() = 35

	# TRUE if the char belongs to the Bopomofo script.
	def IsBopomofoScript()
		return This.ScriptCode() = 36

	# TRUE if the char belongs to the Han script.
	def IsHanScript()
		return This.ScriptCode() = 37

	# TRUE if the char belongs to the Yi script.
	def IsYiScript()
		return This.ScriptCode() = 38

	# TRUE if the char belongs to the Old Italic script.
	def IsOldItalicScript()
		return This.ScriptCode() = 39

	# TRUE if the char belongs to the Gothic script.
	def IsGothicScript()
		return This.ScriptCode() = 40

	# TRUE if the char belongs to the Deseret script.
	def IsDeseretScript()
		return This.ScriptCode() = 41

	# TRUE if the char belongs to the Tagalog script.
	def IsTagalogScript()
		return This.ScriptCode() = 42

	# TRUE if the char belongs to the Hanunoo script.
	def IsHanunooScript()
		return This.ScriptCode() = 43

	# TRUE if the char belongs to the Buhid script.
	def IsBuhidScript()
		return This.ScriptCode() = 44

	# TRUE if the char belongs to the Tagbanwa script.
	def IsTagbanwaScript()
		return This.ScriptCode() = 45

	# TRUE if the char belongs to the Coptic script.
	def IsCopticScript()
		return This.ScriptCode() = 46

	# TRUE if the char belongs to the Limbu script.
	def IsLimbuScript()
		return This.ScriptCode() = 47

	# TRUE if the char belongs to the Tai Le script.
	def IsTaiLeScript()
		return This.ScriptCode() = 48

	# TRUE if the char belongs to the Linear B script.
	def IsLinearBScript()
		return This.ScriptCode() = 49

	# TRUE if the char belongs to the Ugaritic script.
	def IsUgariticScript()
		return This.ScriptCode() = 50

	# TRUE if the char belongs to the Shavian script.
	def IsShavianScript()
		return This.ScriptCode() = 51

	# TRUE if the char belongs to the Osmanya script.
	def IsOsmanyaScript()
		return This.ScriptCode() = 52

	# TRUE if the char belongs to the Cypriot script.
	def IsCypriotScript()
		return This.ScriptCode() = 53

	# TRUE if the char belongs to the Braille script.
	def IsBrailleScript()
		return This.ScriptCode() = 54

	# TRUE if the char belongs to the Buginese script.
	def IsBugineseScript()
		return This.ScriptCode() = 55

	# TRUE if the char belongs to the New Tai Lue script.
	def IsNewTaiLueScript()
		return This.ScriptCode() = 56

	# TRUE if the char belongs to the Glagolitic script.
	def IsGlagoliticScript()
		return This.ScriptCode() = 57

	# TRUE if the char belongs to the Tifinagh script.
	def IsTifinaghScript()
		return This.ScriptCode() = 58

	# TRUE if the char belongs to the Syloti Nagri script.
	def IsSylotiNagriScript()
		return This.ScriptCode() = 59

	# TRUE if the char belongs to the Old Persian script.
	def IsOldPersianScript()
		return This.ScriptCode() = 60

	# TRUE if the char belongs to the Kharoshthi script.
	def IsKharoshthiScript()
		return This.ScriptCode() = 61

	# TRUE if the char belongs to the Balinese script.
	def IsBalineseScript()
		return This.ScriptCode() = 62

	# TRUE if the char belongs to the Cuneiform script.
	def IsCuneiformScript()
		return This.ScriptCode() = 63

	# TRUE if the char belongs to the Phoenician script.
	def IsPhoenicianScript()
		return This.ScriptCode() = 64

	# TRUE if the char belongs to the Phags Pa script.
	def IsPhagsPaScript()
		return This.ScriptCode() = 65

	# TRUE if the char belongs to the Nko script.
	def IsNkoScript()
		return This.ScriptCode() = 66

	# TRUE if the char belongs to the Sundanese script.
	def IsSundaneseScript()
		return This.ScriptCode() = 67

	# TRUE if the char belongs to the Lepcha script.
	def IsLepchaScript()
		return This.ScriptCode() = 68

	# TRUE if the char belongs to the Ol Chiki script.
	def IsOlChikiScript()
		return This.ScriptCode() = 69

	# TRUE if the char belongs to the Vai script.
	def IsVaiScript()
		return This.ScriptCode() = 70

	# TRUE if the char belongs to the Saurashtra script.
	def IsSaurashtraScript()
		return This.ScriptCode() = 71

	# TRUE if the char belongs to the Kayah Li script.
	def IsKayahLiScript()
		return This.ScriptCode() = 72

	# TRUE if the char belongs to the Rejang script.
	def IsRejangScript()
		return This.ScriptCode() = 73

	# TRUE if the char belongs to the Lycian script.
	def IsLycianScript()
		return This.ScriptCode() = 74

	# TRUE if the char belongs to the Carian script.
	def IsCarianScript()
		return This.ScriptCode() = 75

	# TRUE if the char belongs to the Lydian script.
	def IsLydianScript()
		return This.ScriptCode() = 76

	# TRUE if the char belongs to the Cham script.
	def IsChamScript()
		return This.ScriptCode() = 77

	def TaiThamScript()
		return This.ScriptCode() = 78

	# TRUE if the char belongs to the Tai Viet script.
	def IsTaiVietScript()
		return This.ScriptCode() = 79

	# TRUE if the char belongs to the Avestan script.
	def IsAvestanScript()
		return This.ScriptCode() = 80

	# TRUE if the char belongs to the Egyptian Hieroglyphs script.
	def IsEgyptianHieroglyphsScript()
		return This.ScriptCode() = 81

	# TRUE if the char belongs to the Samaritan script.
	def IsSamaritanScript()
		return This.ScriptCode() = 82

	# TRUE if the char belongs to the Lisu script.
	def IsLisuScript()
		return This.ScriptCode() = 83

	# TRUE if the char belongs to the Bamum script.
	def IsBamumScript()
		return This.ScriptCode() = 84

	# TRUE if the char belongs to the Javanese script.
	def IsJavaneseScript()
		return This.ScriptCode() = 85

	# TRUE if the char belongs to the Meetei Mayek script.
	def IsMeeteiMayekScript()
		return This.ScriptCode() = 86

	# TRUE if the char belongs to the Imperial Aramaic script.
	def IsImperialAramaicScript()
		return This.ScriptCode() = 87

	# TRUE if the char belongs to the Old South Arabian script.
	def IsOldSouthArabianScript()
		return This.ScriptCode() = 88

	# TRUE if the char belongs to the Inscriptional Parthian script.
	def IsInscriptionalParthianScript()
		return This.ScriptCode() = 89

	# TRUE if the char belongs to the Inscriptional Pahlavi script.
	def IsInscriptionalPahlaviScript()
		return This.ScriptCode() = 90

	# TRUE if the char belongs to the Old Turkic script.
	def IsOldTurkicScript()
		return This.ScriptCode() = 91

	# TRUE if the char belongs to the Kaithi script.
	def IsKaithiScript()
		return This.ScriptCode() = 92

	# TRUE if the char belongs to the Batak script.
	def IsBatakScript()
		return This.ScriptCode() = 93

	# TRUE if the char belongs to the Brahmi script.
	def IsBrahmiScript()
		return This.ScriptCode() = 94

	# TRUE if the char belongs to the Mandaic script.
	def IsMandaicScript()
		return This.ScriptCode() = 95

	# TRUE if the char belongs to the Chakma script.
	def IsChakmaScript()
		return This.ScriptCode() = 96

	# TRUE if the char belongs to the Meroitic Cursive script.
	def IsMeroiticCursiveScript()
		return This.ScriptCode() = 97

	# TRUE if the char belongs to the Meroitic Hieroglyphs script.
	def IsMeroiticHieroglyphsScript()
		return This.ScriptCode() = 98

	# TRUE if the char belongs to the Miao script.
	def IsMiaoScript()
		return This.ScriptCode() = 99

	# TRUE if the char belongs to the Sharada script.
	def IsSharadaScript()
		return This.ScriptCode() = 100

	# TRUE if the char belongs to the Sora Sompeng script.
	def IsSoraSompengScript()
		return This.ScriptCode() = 101

	# TRUE if the char belongs to the Takri script.
	def IsTakriScript()
		return This.ScriptCode() = 102

	# TRUE if the char belongs to the Caucasian Albanian script.
	def IsCaucasianAlbanianScript()
		return This.ScriptCode() = 103

	# TRUE if the char belongs to the Bassa Vah script.
	def IsBassaVahScript()
		return This.ScriptCode() = 104

	# TRUE if the char belongs to the Duployan script.
	def IsDuployanScript()
		return This.ScriptCode() = 105

	# TRUE if the char belongs to the Elbasan script.
	def IsElbasanScript()
		return This.ScriptCode() = 106

	# TRUE if the char belongs to the Grantha script.
	def IsGranthaScript()
		return This.ScriptCode() = 107

	# TRUE if the char belongs to the Pahawh Hmong script.
	def IsPahawhHmongScript()
		return This.ScriptCode() = 108

	# TRUE if the char belongs to the Khojki script.
	def IsKhojkiScript()
		return This.ScriptCode() = 109

	# TRUE if the char belongs to the Linear A script.
	def IsLinearAScript()
		return This.ScriptCode() = 110

	# TRUE if the char belongs to the Mahajani script.
	def IsMahajaniScript()
		return This.ScriptCode() = 111

	# TRUE if the char belongs to the Manichaean script.
	def IsManichaeanScript()
		return This.ScriptCode() = 112

	# TRUE if the char belongs to the Mende Kikakui script.
	def IsMendeKikakuiScript()
		return This.ScriptCode() = 113

	# TRUE if the char belongs to the Modi script.
	def IsModiScript()
		return This.ScriptCode() = 114

	# TRUE if the char belongs to the Mro script.
	def IsMroScript()
		return This.ScriptCode() = 115

	# TRUE if the char belongs to the Old North Arabian script.
	def IsOldNorthArabianScript()
		return This.ScriptCode() = 116

	# TRUE if the char belongs to the Nabataean script.
	def IsNabataeanScript()
		return This.ScriptCode() = 117

	# TRUE if the char belongs to the Palmyrene script.
	def IsPalmyreneScript()
		return This.ScriptCode() = 118

	# TRUE if the char belongs to the Pau Cin Hau script.
	def IsPauCinHauScript()
		return This.ScriptCode() = 119

	# TRUE if the char belongs to the Old Permic script.
	def IsOldPermicScript()
		return This.ScriptCode() = 120

	# TRUE if the char belongs to the Psalter Pahlavi script.
	def IsPsalterPahlaviScript()
		return This.ScriptCode() = 121

	# TRUE if the char belongs to the Siddham script.
	def IsSiddhamScript()
		return This.ScriptCode() = 122

	# TRUE if the char belongs to the Khudawadi script.
	def IsKhudawadiScript()
		return This.ScriptCode() = 123

	# TRUE if the char belongs to the Tirhuta script.
	def IsTirhutaScript()
		return This.ScriptCode() = 124

	# TRUE if the char belongs to the Warang Citi script.
	def IsWarangCitiScript()
		return This.ScriptCode() = 125

	# TRUE if the char belongs to the Ahom script.
	def IsAhomScript()
		return This.ScriptCode() = 126

	# TRUE if the char belongs to the Anatolian Hieroglyphs script.
	def IsAnatolianHieroglyphsScript()
		return This.ScriptCode() = 127

	# TRUE if the char belongs to the Hatran script.
	def IsHatranScript()
		return This.ScriptCode() = 128

	# TRUE if the char belongs to the Multani script.
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
