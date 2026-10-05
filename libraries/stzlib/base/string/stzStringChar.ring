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

	if StzFindFirst(c, InvisibleChars())
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
# Holds one Unicode char, exactly as stzStringChar does, and reports its own type name, stzchar.
#
# A thin subclass: the only thing it adds to stzStringChar is StzType, which answers :stzChar
# instead of the stzstring it would inherit. Every other method is stzStringChar's.
#
#   receiver   o1 = new stzChar("a")
#   example    ? o1.StzType()
#              #--> stzchar
#   see        stzStringChar, stzString
class stzChar from stzStringChar

	# Returns the type name of this subclass, stzchar, where the parent class stzStringChar answers stzstring.
	#
	#   returns    a string
	#@ aka  -- Report stzchar, not the inherited "stzstring".
	def StzType()
		return :stzChar

# Holds one Unicode char and answers questions about it: its codepoint, name, script, case, bidi class and category.
#
# Reach for it when a single char deserves more than a one-char stzString. It wraps a stzString and
# answers from the engine's Unicode data. It is built from a one-char text, a codepoint number, a
# hex form such as U+0061 or a Unicode char name. A method not defined here falls through to
# stzString, so a char also answers text questions.
#
#   receiver   o1 = new stzStringChar("a")
#   example    ? o1.Unicode()
#              #--> 97
#              ? o1.Script()
#              #--> latin
#   see        stzChar, stzString
class stzStringChar from stzString

	@oString	# Composition: wraps a 1-char stzString

	  #===================#
	 #   INITIALIZATION  #
	#===================#

	# Builds the char object from a one-char text, a codepoint number, a hex form such as U+0061 or 0x61, or a Unicode char name.
	#
	#   pChar      the char: one-char text, codepoint number, U+XXXX or 0xXX hex text, Unicode char
	#              name, or a stzString object
	#   returns    nothing; builds the object
	#   note       an empty text, a text of several chars that is neither a hex form nor a name, and
	#              a bare hex such as 61 all raise "Can not create char object!"
	#   see        Update, Unicode
	#@ aka  Build the char object from the given single-char string.
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

	# Returns the char held, as a one-char string.
	#
	#   returns    a string
	#   see        String, Unicode
	def Content()
		return @oString.Content()

		def Char()
			return This.Content()

	# Returns the held char wrapped in a stzString object, not as plain text.
	#
	#   returns    a stzString object
	#   see        Content
	def String()
		return @oString

	# Returns the Unicode codepoint of the char, such as 97 for a.
	#
	#   returns    a number
	#   see        UnicodeAsString, HexUnicode
	def Unicode()
		return StzEngineCharUnicode(This.Content())

		def UnicodeAsNumber()
			return This.Unicode()

	# Returns the codepoint of the char written as decimal text, such as "97".
	#
	#   returns    a string
	#   see        Unicode, HexUnicode
	def UnicodeAsString()
		return "" + This.Unicode()

	# Returns the codepoint as U+ followed by four hex digits, such as U+0061.
	#
	#   returns    a string
	#   warning    known defect: only four hex digits are kept, so a char above U+FFFF comes out
	#              wrong: U+1F600 reads U+F600
	#   see        Unicode
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

	# Answers FALSE every time, because a char object cannot be built empty.
	#
	#   returns    FALSE
	def IsEmpty()
		return 0	# stzStringChar can never host an empty char

	# Returns a new stzStringChar object holding the same char, so changing the copy leaves the original alone.
	#
	#   returns    a stzStringChar object
	#   see        Content
	def Copy()
		return new stzStringChar( This.Content() )

	# Answers TRUE every time: a char object counts as a string.
	#
	#   returns    TRUE
	def IsAString()
		return 1

	  #=========================#
	 #   NUMBER / DIGIT VALUE  #
	#=========================#

	# Returns the number a digit char stands for, such as 7 for 7, 3 for the Arabic-Indic three, 1 for a circled one.
	#
	#   returns    a number; an empty string for a char with no decimal value
	#   note       a letter, a Roman numeral and a symbol all answer an empty string
	#   see        IsDigit, IsANumber
	#@ aka  The number this char MEANS, or nothing for a char that means none.
	def Number()
		_nVal_ = StzEngineUnicodeNumericValue(This.Unicode())
		if _nVal_ >= 0
			return _nVal_
		ok

		def NumericValue()
			return This.Number()

		def Value()
			return This.Number()

	  #=============#
	 #   UPDATE    #
	#=============#

	# Replaces the held char with the given text, in place; a codepoint number empties the object today.
	#
	#   pChar      the new char, as text
	#   returns    nothing; the char changes
	#   note       written Update("z") or Update(:With = "z")
	#   warning    known defect: Update(98) leaves an empty string and Unicode 0, because the number
	#              is never converted; Update("ab") stores both chars, so only a one-char text works
	#              as meant
	#   see        UpdateWith, Updated
	#@ aka  Replace the char with the given one (mutating; the single update point).
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

		# Replaces the held char with the given one, in place, exactly as the plain form does.
		#
		#   pChar      the new char, as text
		#   returns    nothing; the char changes
		#   warning    known defect: shares the defect of the plain form, so a codepoint number
		#              empties the object
		#   see        Update
		#@ aka  Same as Update: replace the char (mutating).
		def UpdateWith(pChar)
			This.Update(pChar)

			def UpdateWithQ(pChar)
				return This.UpdateQ(pChar)

		# Replaces the held char with the given one, in place, exactly as the plain form does.
		#
		#   pChar      the new char, as text
		#   returns    nothing; the char changes
		#   warning    known defect: shares the defect of the plain form, so a codepoint number
		#              empties the object
		#   see        Update
		#@ aka  Same as Update: replace the char (mutating).
		def UpdateBy(pChar)
			This.Update(pChar)

			def UpdateByQ(pChar)
				return This.UpdateQ(pChar)

		# Replaces the held char with the given one, in place, exactly as the plain form does.
		#
		#   pChar      the new char, as text
		#   returns    nothing; the char changes
		#   warning    known defect: shares the defect of the plain form, so a codepoint number
		#              empties the object
		#   see        Update
		#@ aka  Same as Update: replace the char (mutating).
		def UpdateUsing(pChar)
			This.Update(pChar)

			def UpdateUsingQ(pChar)
				return This.UpdateQ(pChar)

	# Returns the argument as it came, without converting it or checking it is a char; the object is unchanged.
	#
	#   pChar      the value to hand back
	#   returns    the argument itself
	#   see        Update
	#@ aka  The value the char would be updated to (passive twin of Update).
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

	# Answers TRUE when the Unicode database holds a name for the char, and raises when it does not.
	#
	#   returns    TRUE; it never answers FALSE
	#   warning    known defect: for an unnamed code such as U+0378 it raises "Can't proceed!"
	#              instead of answering FALSE, because it asks for the name and the name request
	#              raises
	#   see        Name
	def CanRetrieveName()
		if This.Name() != "@CantRetriveTheName"
			return 1
		else
			return 0
		ok

	# Returns the official Unicode name, such as LATIN SMALL LETTER A, and raises when the database has none.
	#
	#   returns    a string
	#   note       a control char answers <control>; the first char of a range answers a range label
	#              such as <Private Use, First>; an unassigned code such as U+0378 raises
	#   see        NameIs, CanRetrieveName
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

	# TRUE if the char carries the given Unicode name; the comparison ignores case.
	#
	#   returns    TRUE or FALSE
	#   note       NameIs("latin small letter a") is TRUE for a
	#   see        Name
	def NameIs(pcName)
		if NOT isString(pcName)
			return 0
		ok
		_cName_ = This.Name()
		return BothStringsAreEqualCS(pcName, _cName_, 0)

	# Returns the ASCII code of the char, 0 to 127; for a char above 127 it raises R3 instead of a clear message.
	#
	#   returns    a number
	#   warning    known defect: the failure branch calls stzCharError, which is defined nowhere, so
	#              a non-ASCII char raises R3 "Calling Function without definition"
	#   see        Unicode
	def AsciiCode()
		try
			return ascii(This.Content())
		catch
			StzRaise(stzCharError(:CanNotGetAsciiCodeForNonAsciiChar))
		end

	  #=====================================#
	 #   ORIENTATION & UNICODE DIRECTION   #
	#=====================================#

	# Returns "ltr" or "rtl", the writing direction of the char as the string layer judges it.
	#
	#   returns    a string
	#   note       judged by script block: a char of the Arabic range, even the shaddah or U+FEFF,
	#              answers rtl where UnicodeDirection says nonspacingmark or boundaryneutral
	#   see        UnicodeDirection, IsRightToLeft
	def Orientation()
		return @oString.Orientation()

	# Returns the name of the char's Unicode bidi class, such as lefttoright, europeannumber or whitespace.
	#
	#   returns    a string
	#   note       other names seen: righttoleft, righttoleftarabic, arabicnumber, otherneutrals,
	#              nonspacingmark
	#   see        UnicodeDirectionNumber, Orientation
	def UnicodeDirection()
		_aUnicodeDirectionsXT1_ = UnicodeDirectionsXT()
		_nUnicodeDirectionsXT1Len_ = len(_aUnicodeDirectionsXT1_)
		for _iLoopUnicodeDirectionsXT1_ = 1 to _nUnicodeDirectionsXT1Len_
			_aLine_ = _aUnicodeDirectionsXT1_[_iLoopUnicodeDirectionsXT1_]
			if _aLine_[1] = This.UnicodeDirectionNumber()
				return _aLine_[3]
			ok
		next

	# Returns the bidi class as a number written as text, in Qt numbering: 0 left-to-right, 1 right-to-left, 2 European number, 9 whitespace.
	#
	#   returns    a string holding a number
	#   note       the other values: 3 separator, 4 terminator, 5 Arabic number, 6 common separator,
	#              7 paragraph, 8 section, 10 neutral, 13 Arabic letter, 17 nonspacing mark, 18
	#              boundary neutral
	#   see        UnicodeDirection
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

	# TRUE if the char is one of the ASCII vowels a, e, i, o, u in either case; an accented vowel answers FALSE.
	#
	#   returns    TRUE or FALSE
	#   see        IsLetter
	def IsVowel()
		# NOTE: do NOT call Vowels() here -- it resolves to the inherited
		# stzString.Vowels() (vowels CONTAINED in the content), which
		# returns [] for a single-char object, so IsVowel always answered
		# FALSE. Test the codepoint directly (ASCII vowels, both cases).
		return ring_find([ 65, 69, 73, 79, 85, 97, 101, 105, 111, 117 ], This.Unicode()) > 0

		def IsAVowel()
			return This.IsVowel()

	# TRUE if the bidi class is left-to-right, or a left-to-right embedding, override or isolate mark.
	#
	#   returns    TRUE or FALSE
	#   note       a digit answers FALSE: its class is European number
	#   see        IsRightToLeft, UnicodeDirection
	def IsLeftToRight()
		# L, LRE, LRO, LRI (Qt numbering)
		return ring_find([ "0", "11", "12", "19" ], This.UnicodeDirectionNumber()) > 0

	# TRUE if the bidi class is right-to-left, as for Hebrew and Arabic letters, or the char is an RLE, RLO or RLI mark.
	#
	#   returns    TRUE or FALSE
	#   see        IsLeftToRight, UnicodeDirection
	def IsRightToLeft()
		# R, AL, RLE, RLO, RLI (Qt numbering)
		return ring_find([ "1", "13", "14", "15", "20" ], This.UnicodeDirectionNumber()) > 0

	# TRUE if the char is in the library's list of fraction chars, such as the vulgar half U+00BD or U+2153.
	#
	#   returns    TRUE or FALSE
	#@ aka  TRUE if the char belongs to the Arabic Fraction Unicode range.
	def IsArabicFraction()
		return ring_find(ArabicFractionsUnicodes(), This.Unicode()) > 0

	def IsEuropeanDigit()
		return This.IsEuropeanNumber()

	# TRUE if the bidi class is European number separator, as for the plus sign and the hyphen-minus.
	#
	#   returns    TRUE or FALSE
	#   see        IsEuropeanNumberTerminator, UnicodeDirection
	def IsEuropeanNumberSeparator()
		return This.UnicodeDirectionNumber() = "3"

		def IsEuropeanNumberSeperator()
			return This.IsEuropeanNumberSeparator()

	# TRUE if the bidi class is European number terminator, as for the dollar and percent signs.
	#
	#   returns    TRUE or FALSE
	#   see        IsEuropeanNumberSeparator, UnicodeDirection
	def IsEuropeanNumberTerminator()
		return This.UnicodeDirectionNumber() = "4"

	# TRUE if the char is one of the library's Indian digits: the Arabic-Indic digits U+0660 to 0669 and most Persian ones.
	#
	#   returns    TRUE or FALSE
	#   note       Devanagari digits answer FALSE, and so do the Persian U+06F4 to 06F7
	#   see        IsIndianNumber, IsDigit
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

	# TRUE if the bidi class is common number separator, as for the comma, the full stop and the fraction slash.
	#
	#   returns    TRUE or FALSE
	#   see        UnicodeDirection
	def IsCommonNumberSeparator()
		return This.UnicodeDirectionNumber() = "6"

		def IsCommonNumberSeperator()
			return This.IsCommonNumberSeparator()

	# TRUE if the bidi class is paragraph separator, as for the newline and U+2029.
	#
	#   returns    TRUE or FALSE
	#   see        IsLineSeparator, UnicodeDirection
	def IsParagraphSeparator()
		return This.UnicodeDirectionNumber() = "7"

		def IsParagraphSeperator()
			return This.IsParagraphSeparator()

	# TRUE if the bidi class is segment separator, which is the tab char.
	#
	#   returns    TRUE or FALSE
	#   see        IsParagraphSeparator, UnicodeDirection
	def IsSectionSeparator()
		return This.UnicodeDirectionNumber() = "8"

		def IsSectionSeperator()
			return This.IsSectionSeparator()

	# TRUE if the bidi class is whitespace, as for the plain space and U+2028; a tab, a newline and a no-break space answer FALSE.
	#
	#   returns    TRUE or FALSE
	#   see        IsSpace, UnicodeDirection
	def IsWhitespace()
		return This.UnicodeDirectionNumber() = "9"

	# TRUE if the bidi class is other neutral, as for parentheses, or if the char is a digit.
	#
	#   returns    TRUE or FALSE
	#   note       the digit clause makes 7 answer TRUE although its class is European number
	#   see        UnicodeDirection
	def IsOrientationNeutral()
		if This.UnicodeDirectionNumber() = "10" or This.IsANumber()
			return 1
		else
			return 0
		ok

		def IsNeutral()
			return This.IsOrientationNeutral()

	# TRUE if the char is the left-to-right embedding mark, U+202A.
	#
	#   returns    TRUE or FALSE
	#   see        IsLeftToRightOverride, IsPopDirectionalFormat
	def IsLeftToRightEmbedding()
		return This.UnicodeDirectionNumber() = "11"

	# TRUE if the char is the left-to-right override mark, U+202D.
	#
	#   returns    TRUE or FALSE
	#   see        IsLeftToRightEmbedding, IsPopDirectionalFormat
	def IsLeftToRightOverride()
		return This.UnicodeDirectionNumber() = "12"

	# Returns an empty string today instead of TRUE for the left-to-right isolate mark, U+2066.
	#
	#   returns    an empty string
	#   warning    known defect: the body is only a comment ("Reserved for future implementation"),
	#              so the answer is always empty
	#   see        IsLeftToRight
	def IsLeftToRightIsolate()
	# Returns an empty string today instead of TRUE for the right-to-left isolate mark, U+2067.
	#
	#   returns    an empty string
	#   warning    known defect: the body is only a comment ("Reserved for future implementation"),
	#              so the answer is always empty
	#   see        IsRightToLeft
	#@ aka  Reserved for future implementation
	def IsRightToLeftIsolate()
	# TRUE if the bidi class is right-to-left Arabic, as for Arabic letters and Arabic presentation forms.
	#
	#   returns    TRUE or FALSE
	#   see        IsRightToLeft, UnicodeDirection
	#@ aka  Reserved for future implementation
	def IsRightToLeftArabic()
		return This.UnicodeDirectionNumber() = "13"

	# TRUE if the char is the right-to-left embedding mark, U+202B.
	#
	#   returns    TRUE or FALSE
	#   see        IsRightToLeftOverride, IsPopDirectionalFormat
	def IsRightToLeftEmbedding()
		return This.UnicodeDirectionNumber() = "14"

	# TRUE if the char is the right-to-left override mark, U+202E.
	#
	#   returns    TRUE or FALSE
	#   see        IsRightToLeftEmbedding, IsPopDirectionalFormat
	def IsRightToLeftOverride()
		return This.UnicodeDirectionNumber() = "15"

	# TRUE if the char is the pop directional formatting mark, U+202C, which ends an embedding or override.
	#
	#   returns    TRUE or FALSE
	#   see        IsLeftToRightEmbedding, IsRightToLeftEmbedding
	def IsPopDirectionalFormat()
		return This.UnicodeDirectionNumber() = "16"

	# TRUE if the bidi class is nonspacing mark, as for combining accents and the Arabic shaddah.
	#
	#   returns    TRUE or FALSE
	#   see        IsMark, UnicodeDirection
	def IsNonSpacingMark()
		return This.UnicodeDirectionNumber() = "17"

	# TRUE if the bidi class is boundary neutral, as for control chars, the soft hyphen and U+FEFF.
	#
	#   returns    TRUE or FALSE
	#   see        UnicodeDirection
	def IsBoundaryNeutral()
		return This.UnicodeDirectionNumber() = "18"

	  #======================#
	 #   UNICODE CATEGORY   #
	#======================#

	# Returns the Unicode general-category code of the char, from the engine: 1 Lu, 2 Ll, 5 Lo, 9 Nd, 18 Po, 23 Zs, 26 Cc.
	#
	#   returns    a number
	#   see        UnicodeCategory
	#@ aka  The numeric Unicode general-category code of the char.
	def UnicodeCategoryNumber()
		return _CharCategoryNumber(This.Unicode())

	# Returns the name of the Unicode general category, such as letter_lowercase, number_decimaldigit or punctuation_dash.
	#
	#   returns    a string
	#   see        UnicodeCategoryNumber
	#@ aka  The Unicode general category of the char.
	def UnicodeCategory()
		_n_ = This.UnicodeCategoryNumber()
		return UnicodeCategoriesXT()[ ""+_n_ ]

		def CharType()
			return This.UnicodeCategory()

			def CharTypeQ()
				return new stzString( This.CharType() )

		def UnicodeType()
			return This.UnicodeCategory()

			# Returns the category name wrapped in a stzString object, so that calls can chain.
			#
			#   returns    a stzString object
			#   see        UnicodeCategory
			#@ aka  The Unicode category name, wrapped as a stzString.
			def TypeUnicodeQ()
				return new stzString( This.UnicodeType() )

		def Category()
			return This.UnicodeCategory()

			def CategoryQ()
				return new stzString( This.Category() )

	  #==============================#
	 #   CHARACTER CLASSIFICATION   #
	#==============================#

	# TRUE if the char is U+0651, the Arabic shaddah.
	#
	#   returns    TRUE or FALSE
	#   see        IsLetter
	#@ aka  TRUE if the char is the Arabic shaddah (U+0651).
	def IsArabicShaddah()
		# U+0651 ARABIC SHADDA -- treated as a letter in Softanza.
		return This.Unicode() = 1617

	# TRUE if the engine counts the char as a letter, or if it is the Arabic shaddah, which the library treats as a letter.
	#
	#   returns    TRUE or FALSE
	#   see        IsNotLetter, IsLetterOrNumber
	#@ aka  TRUE if the char is a letter (Unicode-aware).
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

	# TRUE if the char is not a letter, so for digits, spaces, punctuation and accents; the shaddah answers FALSE.
	#
	#   returns    TRUE or FALSE
	#   see        IsLetter
	#@ aka  TRUE if the char is NOT a letter.
	def IsNotLetter()
		return NOT This.IsLetter()

		def IsNotALetter()
			return This.IsNotLetter()

	# TRUE if the char is a letter, a Unicode space, or equal to the given char.
	#
	#   c          the extra char that also qualifies
	#   returns    TRUE or FALSE
	#   see        IsLetterOrSpace, IsLetterOrSpaceOrThisChar
	#@ aka  TRUE if the char is a letter, a space, or the given char.
	def IsLetterOrSpaceOrChar(c)
		if This.IsLetter() or This.IsSpace() or This.Content() = c
			return 1
		else
			return 0
		ok

	# TRUE if the char equals the given char once both are uppercased, so the test ignores case.
	#
	#   c          the char to compare with
	#   returns    TRUE or FALSE
	#   note       any char works, not only letters
	#   see        IsLetter
	#@ aka  TRUE if the char is the given letter, case-insensitively.
	def IsTheLetter(c)
		return This.Uppercased() = StzCharQ(c).Uppercased()

	# TRUE if the char is a letter or a digit char, in any script, or a circled digit.
	#
	#   returns    TRUE or FALSE
	#   note       a Roman numeral answers FALSE
	#   see        IsLetter, IsANumber
	#@ aka  TRUE if the char is a letter or a number char.
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

	# TRUE if the char is a letter or a Unicode space, a newline included.
	#
	#   returns    TRUE or FALSE
	#   see        IsLetter, IsSpace
	#@ aka  TRUE if the char is a letter or a space.
	def IsLetterOrSpace()
		if This.IsLetter() or This.IsSpace()
			return 1
		else
			return 0
		ok

		def IsSpaceOrLetter()
			return This.IsLetterOrSpace()

	# TRUE if the char is a letter, a Unicode space, or equal to the given char.
	#
	#   returns    TRUE or FALSE
	#   see        IsLetterOrSpace, IsLetterOrSpaceOrChar
	#@ aka  TRUE if the char is a letter, a space, or the given char.
	def IsLetterOrSpaceOrThisChar(pcChar)
		if This.IsLetter() or This.IsSpace() or This.Content() = pcChar
			return 1
		else
			return 0
		ok

		def IsSpaceOrLetterOrThisChar(pcChar)
			return This.IsLetterOrSpaceOrThisChar(pcChar)

	# Raises error R14 today instead of TRUE for a European number, separator or terminator.
	#
	#   returns    TRUE or FALSE once repaired
	#   warning    known defect: the body calls IsEuropeanNumber, which is defined nowhere
	#   see        IsEuropeanNumberSeparator, IsEuropeanNumberTerminator
	#@ aka  TRUE if the char is a European number, separator or terminator (bidi classes).
	def IsEuropean()
		if This.IsEuropeanNumber() or This.IsEuropeanNumberSeparator() or
		   This.IsEuropeanNumberTerminator()
			return 1
		else
			return 0
		ok

	# TRUE if the engine counts the char as a space: the plain space, a tab, a newline or the no-break space.
	#
	#   returns    TRUE or FALSE
	#   note       U+2028 and U+2029 answer FALSE
	#   see        IsWhitespace, IsSeparator
	#@ aka  TRUE if the char is a space char (Unicode-aware).
	def IsSpace()
		return _CharIsSpace(This.Unicode())

	# Answers TRUE for Arabic, Hebrew or CJK letters and FALSE for 7 today, instead of TRUE for number chars.
	#
	#   returns    TRUE or FALSE
	#   warning    known defect: it tests category codes 3, 4 and 5, which are title-case, modifier
	#              and other letters in the engine's numbering, where digits are 9 to 11; Roman,
	#              Mandarin and Indian numerals are caught by their own tests
	#   see        IsANumber, IsDigit
	#@ aka  TRUE if the char is a Unicode number char (category N).
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

	# TRUE if the char is neither a decimal digit nor a circled digit.
	#
	#   returns    TRUE or FALSE
	#   note       a Roman numeral answers TRUE
	#   see        IsANumber
	#@ aka  TRUE if the char is NOT a number char.
	def IsNotNumber()
		return NOT This.IsANumber()

	# TRUE if the engine counts the char as a decimal digit, in any script: 7, the Arabic-Indic three, the Devanagari one.
	#
	#   returns    TRUE or FALSE
	#   note       a circled digit answers FALSE
	#   see        IsANumber, Number
	#@ aka  TRUE if the char is a digit.
	def IsDigit()
		# Use engine call
		return StzEngineCharIsDigit(This.Unicode()) = 1

		# IsADigit alias -- a char's digit test IS the engine-backed IsDigit above.
		# Without this, IsADigit fell through to the string-level inherited form
		# (FALSE for a single-char stzChar). Surfaced once QQ("3") correctly
		# resolves to a stzChar rather than being coerced to a stzNumber.
		def IsADigit()
			return This.IsDigit()

	# Answers FALSE for 0 to 9 and raises R41 for a non-ASCII digit today, instead of TRUE for an Arabic digit.
	#
	#   returns    TRUE or FALSE
	#   warning    known defect: it searches a list of digit texts for a number, so a plain digit is
	#              never found, and it adds 0 to the content, which raises R41 "Invalid numeric
	#              string" for an Arabic-Indic, Devanagari or circled digit
	#   see        IsDigit, IsIndianNumber
	#@ aka  TRUE if the char is an Arabic digit.
	def IsArabicNumber()
		if NOT This.IsANumber()
			return 0
		ok
		return ring_find( ArabicDigits(), 0+This.Content() ) > 0

	# TRUE if the char is a decimal digit in any script or a circled digit.
	#
	#   returns    TRUE or FALSE
	#   see        IsDigit, IsCircledDigit
	#@ aka  TRUE if the char is a digit or a circled digit.
	def IsANumber()
		return This.IsDigit() or This.IsCircledDigit()

	# TRUE if the char is in the library's list of Indian digits, the Arabic-Indic and most Persian digits.
	#
	#   returns    TRUE or FALSE
	#   see        IsIndianDigit
	#@ aka  TRUE if the char is an Indian numeral.
	def IsIndianNumber()
		return ring_find(IndianNumbers(), This.Content()) > 0

	# TRUE if the char is a Roman numeral char, such as U+2160 or U+2171, from the library's list.
	#
	#   returns    TRUE or FALSE
	#   see        IsMandarinNumber
	#@ aka  TRUE if the char is a Roman numeral.
	def IsRomanNumber()
		return ring_find(RomanNumbers(), This.Content()) > 0

	# TRUE if the char is a Mandarin numeral from the library's list: 〇, 一 to 十, 百, 千 or 万.
	#
	#   returns    TRUE or FALSE
	#   see        IsRomanNumber
	#@ aka  TRUE if the char is a Mandarin numeral.
	def IsMandarinNumber()
		return ring_find( MandarinNumbers(), This.Content() ) > 0

	# TRUE if the codepoint is below 128, control chars included.
	#
	#   returns    TRUE or FALSE
	#   see        IsAsciiLetter, AsciiCode
	#@ aka  TRUE if the char is ASCII (codepoint below 128).
	def IsAscii()
		try
			ascii( This.Content() )
			return 1
		catch
			return 0
		done

	# TRUE if the char is an unaccented ASCII letter, A to Z or a to z.
	#
	#   returns    TRUE or FALSE
	#   see        IsAscii, IsLetter
	#@ aka  TRUE if the char is an ASCII letter (A-Z or a-z).
	def IsAsciiLetter()
		return This.IsAscii() AND This.IsLetter()

	# TRUE if the engine counts the char as punctuation, such as ( ) - or !.
	#
	#   returns    TRUE or FALSE
	#   note       the dollar sign and the infinity sign are symbols and answer FALSE
	#   see        IsSymbol, IsGeneralPunctuation
	#@ aka  TRUE if the char is a punctuation char.
	def IsPunctuation()
		return StzEngineUnicodeIsPunctuation(This.Unicode())

		def IsPunct()
			return This.IsPunctuation()

	# TRUE if the char lies in the Unicode General Punctuation block, U+2000 to U+206F.
	#
	#   returns    TRUE or FALSE
	#   note       the comma and the exclamation mark are not in this block
	#   see        IsSupplementalPunctuation, IsPunctuation
	#@ aka  TRUE if the char belongs to the General Punctuation Unicode block.
	def IsGeneralPunctuation()
		return StzFindFirst(This.Unicode(), GeneralPunctuationUnicodes()) > 0

	# TRUE if the char lies in the library's Supplemental Punctuation range, U+2DF6 to U+2E7F.
	#
	#   returns    TRUE or FALSE
	#   see        IsGeneralPunctuation
	#@ aka  TRUE if the char belongs to the Supplemental Punctuation Unicode block.
	def IsSupplementalPunctuation()
		return StzFindFirst(This.Unicode(), SupplementalPunctuationUnicodes()) > 0

	# TRUE if the engine counts the char as a symbol, such as $, the infinity sign or an emoji.
	#
	#   returns    TRUE or FALSE
	#   see        IsPunctuation
	#@ aka  TRUE if the char is a symbol char (Unicode category S).
	def IsSymbol()
		return StzEngineUnicodeIsSymbol(This.Unicode())

	# TRUE if the codepoint is a Unicode noncharacter: U+FDD0 to U+FDEF, or a codepoint ending in FFFE or FFFF.
	#
	#   returns    TRUE or FALSE
	#@ aka  TRUE if the codepoint is a Unicode noncharacter.
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

	# TRUE if the engine counts the char as a combining mark, such as an accent or the Arabic shaddah.
	#
	#   returns    TRUE or FALSE
	#   see        IsNonSpacingMark
	#@ aka  TRUE if the char is a combining mark (Unicode category M).
	def IsMark()
		return StzEngineUnicodeIsMark(This.Unicode())

	# TRUE if the engine counts the char as a space: the plain space, a tab, a newline or the no-break space.
	#
	#   returns    TRUE or FALSE
	#   see        IsSpace, IsWordSeparator
	#@ aka  TRUE if the char is a separator (Unicode space class).
	def IsSeparator()
		return StzEngineUnicodeIsSpace(This.Unicode())

		def IsSeperator()
			return This.IsSeparator()

	# TRUE if the char appears in the given list of chars.
	#
	#   pacChars   the list of chars to look in
	#   returns    TRUE or FALSE
	#   see        IsTheLetter
	#@ aka  TRUE if the char is one of the given chars.
	def IsOneOfThese(pacChars)
		if CheckingParams()
			if NOT (isList(pacChars) and @IsListOfChars(pacChars))
				StzRaise("Incorrect param type! pacChars must be a list of chars.")
			ok
		ok

		if StzFindFirst(This.Char(), pacChars) > 0
			return 1
		else
			return 0
		ok

	# TRUE if the char is in the library's word separators: space . , ; : ! ? the Arabic comma and question mark, the apostrophes and the em dash.
	#
	#   returns    TRUE or FALSE
	#   see        IsSentenceSeparator
	#@ aka  TRUE if the char separates words (per the Softanza separators list).
	def IsWordSeparator()
		if StzFindFirst(This.Char(), WordSeparators()) > 0
			return 1
		else
			return 0
		ok

	# TRUE if the char is in the library's sentence separators: the full stop, ! , ? and the Arabic question mark.
	#
	#   returns    TRUE or FALSE
	#   see        IsWordSeparator
	#@ aka  TRUE if the char separates sentences (per the Softanza separators list).
	def IsSentenceSeparator()
		if StzFindFirst(This.Char(), SentenceSeparators()) > 0
			return 1
		else
			return 0
		ok

		def IsSentenceSeperator()
			return This.IsSentenceSeparator()

	# TRUE if the char is the newline, char 10, and nothing else; U+2028 answers FALSE.
	#
	#   returns    TRUE or FALSE
	#   see        IsParagraphSeparator
	#@ aka  TRUE if the char is the newline char.
	def IsLineSeparator()
		return This.Content() = ring_char(10)

		def IsLineSeperator()
			return This.IsLineSeparator()

	# TRUE if the char is in the library's non-letter word chars: _ - * / \ + and the digits 0 to 9.
	#
	#   returns    TRUE or FALSE
	#   see        IsWordSeparator
	#@ aka  TRUE if the char is one of the non-letter chars allowed inside words (hyphen, apostrophe, ...).
	def IsWordNonLetterChar()
		return StzFindFirst(This.Content(), WordNonLetterChars()) > 0

	  #==================#
	 #   MIRRORED CHAR  #
	#==================#

	# TRUE if the char is a bracket pair member the library can mirror, such as ( ) < > [ ] { } or the guillemets.
	#
	#   returns    TRUE or FALSE
	#   see        UnicodeOfMirrored
	#@ aka  TRUE if the char has a mirrored counterpart (like the parentheses).
	def IsMirrored()
		_nMirror_ = _CharMirrored(This.Unicode())
		return _nMirror_ != This.Unicode()

	# Returns the codepoint of the char's mirror partner, 41 for ( and 62 for <, or the char's own codepoint if it has none.
	#
	#   returns    a number
	#   see        IsMirrored, Mirrored
	#@ aka  The codepoint of the char's mirrored counterpart.
	def UnicodeOfMirrored()
		return _CharMirrored(This.Unicode())

	# Raises error R3 today instead of returning the mirror partner of the char.
	#
	#   returns    a string once repaired
	#   warning    known defect: the body calls CharFromUnicode, which is defined nowhere
	#   see        UnicodeOfMirrored
	#@ aka  The mirrored counterpart of the char.
	def Mirrored()
		_nMirrorUnicode_ = _CharMirrored(This.Unicode())
		_cChar_ = CharFromUnicode(_nMirrorUnicode_)
		return _cChar_

	  #=========================#
	 #   LATIN CHAR VARIANTS  #
	#=========================#

	# TRUE if the engine's Unicode data puts the char in the Latin script, an accented letter included.
	#
	#   returns    TRUE or FALSE
	#   see        IsLatinLetter, IsLatinScript
	#@ aka  TRUE if the char is a Latin char (engine check).
	def IsLatin()
		return StzEngineUnicodeIsLatin(This.Unicode())

	# TRUE if the char is a letter of the Latin script, accented letters included.
	#
	#   returns    TRUE or FALSE
	#   see        IsLatin, IsAsciiLetter
	#@ aka  TRUE if the char is a Latin letter.
	def IsLatinLetter()
		_nCp_ = This.Unicode()
		return StzEngineUnicodeIsLetter(_nCp_) AND StzEngineUnicodeIsLatin(_nCp_)

	# Raises error R24 today instead of testing for the Basic Latin block, U+0000 to U+007F.
	#
	#   returns    TRUE or FALSE once repaired
	#   warning    known defect: the body reads _anBasicLatinUnicodes, but the data file defines
	#              _anLatinBasicUnicodes
	#   see        IsLatin1Supplement
	#@ aka  TRUE if the char belongs to the Basic Latin Unicode range.
	def IsBasicLatin()
		return ring_find(_anBasicLatinUnicodes, This.Unicode()) > 0

	# TRUE if the char lies in the Latin-1 Supplement block, U+0080 to U+00FF.
	#
	#   returns    TRUE or FALSE
	#   see        IsLatinExtendedA
	#@ aka  TRUE if the char belongs to the Latin1 Supplement Unicode range.
	def IsLatin1Supplement()
		return ring_find(_anLatin1SupplementUnicodes, This.Unicode()) > 0

	# TRUE if the char lies in the Latin Extended-A block, U+0100 to U+017F.
	#
	#   returns    TRUE or FALSE
	#   see        IsLatinExtendedB
	#@ aka  TRUE if the char belongs to the Latin Extended A Unicode range.
	def IsLatinExtendedA()
		return ring_find(_anLatinExtendedAUnicodes, This.Unicode()) > 0

	# TRUE if the char lies in the Latin Extended-B block, U+0180 to U+024F.
	#
	#   returns    TRUE or FALSE
	#   see        IsLatinExtendedA
	#@ aka  TRUE if the char belongs to the Latin Extended B Unicode range.
	def IsLatinExtendedB()
		return ring_find(_anLatinExtendedBUnicodes, This.Unicode()) > 0

	# TRUE if the char lies in the Latin Extended Additional block, U+1E00 to U+1EFF.
	#
	#   returns    TRUE or FALSE
	#   see        IsLatinExtendedA
	#@ aka  TRUE if the char belongs to the Latin Extended Additional Unicode range.
	def IsLatinExtendedAdditional()
		return ring_find(_anLatinExtendedAdditionalUnicodes, This.Unicode()) > 0

	# TRUE if the char lies in the Latin Extended-C block, U+2C60 to U+2C7F.
	#
	#   returns    TRUE or FALSE
	#   see        IsLatinExtendedA
	#@ aka  TRUE if the char belongs to the Latin Extended C Unicode range.
	def IsLatinExtendedC()
		return ring_find(_anLatinExtendedCUnicodes, This.Unicode()) > 0

	# TRUE if the char lies in the Latin Extended-D block, U+A720 to U+A7FF.
	#
	#   returns    TRUE or FALSE
	#   see        IsLatinExtendedA
	#@ aka  TRUE if the char belongs to the Latin Extended D Unicode range.
	def IsLatinExtendedD()
		return ring_find(_anLatinExtendedDUnicodes, This.Unicode()) > 0

	# TRUE if the char lies in the Latin Extended-E block, U+AB30 to U+AB6F.
	#
	#   returns    TRUE or FALSE
	#   see        IsLatinExtendedA
	#@ aka  TRUE if the char belongs to the Latin Extended E Unicode range.
	def IsLatinExtendedE()
		return ring_find(_anLatinExtendedEUnicodes, This.Unicode()) > 0

	  #=========================#
	 #   ARABIC CHAR VARIANTS  #
	#=========================#

	# TRUE if the engine counts the char as Arabic, by block, so the shaddah, Arabic-Indic digits and U+FEFF answer TRUE.
	#
	#   returns    TRUE or FALSE
	#   note       the script test IsArabicScript differs: it answers FALSE for the shaddah, which
	#              is in the Inherited script
	#   see        IsArabicLetter, IsArabicScript
	#@ aka  TRUE if the char is an Arabic char (engine check).
	def IsArabic()
		return StzEngineUnicodeIsArabic(This.Unicode())

	# TRUE if the char is a letter and the engine counts it as Arabic.
	#
	#   returns    TRUE or FALSE
	#   see        IsArabic
	#@ aka  TRUE if the char is an Arabic letter.
	def IsArabicLetter()
		_nCp_ = This.Unicode()
		return StzEngineUnicodeIsLetter(_nCp_) AND StzEngineUnicodeIsArabic(_nCp_)

	# Raises error R24 today instead of testing for the basic Arabic block.
	#
	#   returns    TRUE or FALSE once repaired
	#   warning    known defect: the body reads _anBasicArabicUnicodes, which the data file does not
	#              define
	#   see        IsArabicSupplement
	#@ aka  TRUE if the char belongs to the Basic Arabic Unicode range.
	def IsBasicArabic()
		return ring_find(_anBasicArabicUnicodes, This.Unicode()) > 0

	# TRUE if the char lies in the Arabic Supplement block, U+0750 to U+077F.
	#
	#   returns    TRUE or FALSE
	#   see        IsArabicExtendedA
	#@ aka  TRUE if the char belongs to the Arabic Supplement Unicode range.
	def IsArabicSupplement()
		return ring_find(_anArabicSupplementUnicodes, This.Unicode()) > 0

	# TRUE if the char lies in the Arabic Extended-A block, U+08A0 to U+08FF.
	#
	#   returns    TRUE or FALSE
	#   see        IsArabicSupplement
	#@ aka  TRUE if the char belongs to the Arabic Extended A Unicode range.
	def IsArabicExtendedA()
		return ring_find(_anArabicExtendedAUnicodes, This.Unicode()) > 0

	# TRUE if the char lies in the Arabic Extended-A block, U+08A0 to U+08FF, as the lettered form does.
	#
	#   returns    TRUE or FALSE
	#   see        IsArabicExtendedA
	#@ aka  TRUE if the char belongs to the Arabic Extended-A range.
	def IsArabicExtended()
		return IsArabicExtendedA()

	# TRUE if the char lies in the Arabic Presentation Forms blocks, U+FB50 to U+FDFF or U+FE70 to U+FEFF.
	#
	#   returns    TRUE or FALSE
	#   see        IsArabicPresentationFormA, IsArabicPresentationFormB
	#@ aka  TRUE if the char belongs to the Arabic Presentation Form Unicode range.
	def IsArabicPresentationForm()
		return ring_find(_anArabicPresentationFormUnicodes, This.Unicode()) > 0

	# TRUE if the char lies in the Arabic Presentation Forms-A block, U+FB50 to U+FDFF.
	#
	#   returns    TRUE or FALSE
	#   see        IsArabicPresentationFormB
	#@ aka  TRUE if the char belongs to the Arabic Presentation Form A Unicode range.
	def IsArabicPresentationFormA()
		return ring_find(_anArabicPresentationFormAUnicodes, This.Unicode()) > 0

	# TRUE if the char lies in the Arabic Presentation Forms-B block, U+FE70 to U+FEFF.
	#
	#   returns    TRUE or FALSE
	#   see        IsArabicPresentationFormA
	#@ aka  TRUE if the char belongs to the Arabic Presentation Form B Unicode range.
	def IsArabicPresentationFormB()
		return ring_find(_anArabicPresentationFormBUnicodes, This.Unicode()) > 0

	# TRUE if the char lies in the Arabic Mathematical Alphabetic Symbols block, U+1EE00 to U+1EEFF.
	#
	#   returns    TRUE or FALSE
	#   see        IsArabic
	#@ aka  TRUE if the char belongs to the Arabic Math Alphabetic Symbol Unicode range.
	def IsArabicMathAlphabeticSymbol()
		return ring_find(_anArabicMathAlphabeticSymbolUnicodes, This.Unicode()) > 0

	# TRUE if the char is one of the 24 Quranic annotation signs, U+06D6 to U+06ED.
	#
	#   returns    TRUE or FALSE
	#   see        IsArabic
	#@ aka  TRUE if the char belongs to the Quranic Sign Unicode range.
	def IsQuranicSign()
		return ring_find(QuranicSignUnicodes(), This.Unicode()) > 0

	# TRUE if the char is a turned digit, U+218A or U+218B.
	#
	#   returns    TRUE or FALSE
	#   see        IsDigit
	#@ aka  TRUE if the char belongs to the Turned Number Unicode range.
	def IsTurnedNumber()
		return ring_find(TurnedDigitUnicodes(), This.Unicode()) > 0

	  #=============================#
	 #   CIRCLED CHAR VARIANTS     #
	#=============================#

	# TRUE if the char is a circled digit or a circled Latin letter from the library's list.
	#
	#   returns    TRUE or FALSE
	#   see        IsCircledDigit, IsCircledLatinLetter
	#@ aka  TRUE if the char belongs to the Circled Unicode range.
	def IsCircled()
		return ring_find(CircledCharUnicodes(), This.Unicode()) > 0

		def IsCircledChar()
			return This.IsCircled()

	# TRUE if the char is a circled digit, U+2460 to U+2468, or the circled zero U+24EA.
	#
	#   returns    TRUE or FALSE
	#   see        IsCircledDigit
	#@ aka  TRUE if the char belongs to the Circled Number Unicode range.
	def IsCircledNumber()
		return ring_find(CircledNumberUnicodes(), This.Unicode()) > 0

	# TRUE if the char is a circled digit, U+2460 to U+2468, or the circled zero U+24EA.
	#
	#   returns    TRUE or FALSE
	#   see        IsCircledNumber, IsANumber
	#@ aka  TRUE if the char belongs to the Circled Digit Unicode range.
	def IsCircledDigit()
		return ring_find(CircledDigitUnicodes(), This.Unicode()) > 0

	# TRUE if the char is a circled Latin letter, capital or small, U+24B6 to U+24E9.
	#
	#   returns    TRUE or FALSE
	#   see        IsCircled
	#@ aka  TRUE if the char belongs to the Circled Latin Letter Unicode range.
	def IsCircledLatinLetter()
		return ring_find(CircledLatinLetterUnicodes(), This.Unicode()) > 0

	# Raises error R24 today instead of testing for a circled small Latin letter.
	#
	#   returns    TRUE or FALSE once repaired
	#   warning    known defect: the body reads _aCircledLatinSmallLetterUnicodes directly, a
	#              variable that is not defined
	#   see        IsCircledLatinLetter
	#@ aka  TRUE if the char belongs to the Circled Latin Small Letter Unicode range.
	def IsCircledLatinSmallLetter()
		return ring_find(CircledLatinSmallLetterUnicodes(), This.Unicode()) > 0

	# Raises error R24 today instead of testing for a circled capital Latin letter.
	#
	#   returns    TRUE or FALSE once repaired
	#   warning    known defect: the body reads _aCircledLatinCapitalLetterUnicodes directly, a
	#              variable that is not defined
	#   see        IsCircledLatinLetter
	#@ aka  TRUE if the char belongs to the Circled Latin Capital Letter Unicode range.
	def IsCircledLatinCapitalLetter()
		return ring_find(CircledLatinCapitalLetterUnicodes(), This.Unicode()) > 0

	# Raises error R3 today instead of testing for a circled char outside the digits and Latin letters.
	#
	#   returns    TRUE or FALSE once repaired
	#   warning    known defect: the body calls OtherCircledCharUnicodes, which is defined nowhere
	#   see        IsCircled
	#@ aka  TRUE if the char belongs to the Other Circled Char Unicode range.
	def IsOtherCircledChar()
		return ring_find(OtherCircledCharUnicodes(), This.Unicode()) > 0

	  #==============================#
	 #   PRINTABLE / VISIBLE CHAR   #
	#==============================#

	# Answers FALSE for digits, hyphens and Roman numerals and TRUE for control chars today, as it tests the wrong category codes.
	#
	#   returns    TRUE or FALSE
	#   warning    known defect: it rejects category codes 9 to 13 (digits, Roman numerals,
	#              connector and dash punctuation) where it meant the control, format and surrogate
	#              codes 26 to 29
	#   see        IsNonPrintable, IsVisible
	def IsPrintable()
		_nCat_ = _CharCategoryNumber(This.Unicode())
		if _nCat_ = 9 or _nCat_ = 10 or _nCat_ = 11 or _nCat_ = 12 or _nCat_ = 13
			return 0
		ok
		return 1

	# Answers TRUE for digits, hyphens and Roman numerals and FALSE for control chars today, the reverse of printable.
	#
	#   returns    TRUE or FALSE
	#   warning    known defect: it is the negation of the printable test, which tests the wrong
	#              category codes
	#   see        IsPrintable
	def IsNonPrintable()
		return NOT This.IsPrintable()

	# TRUE if the char is in the library's invisible list: tab, the no-break space, the spaces and marks of U+2000 to U+200F and a few more.
	#
	#   returns    TRUE or FALSE
	#   note       the plain space and the newline answer FALSE
	#   see        IsVisible, IsPrintable
	#@ aka  TRUE if the char belongs to the Invisible Unicode range.
	def IsInvisible()
		return ring_find( InvisibleUnicodes(), This.Unicode() ) > 0

	# TRUE if the char is not in the library's invisible list, so the plain space and the newline count as visible.
	#
	#   returns    TRUE or FALSE
	#   see        IsInvisible
	def IsVisible()
		return NOT This.IsInvisible()

	  #========================#
	 #   LOCALE SEPARATOR     #
	#========================#

	# Returns 1 for a hyphen, 2 for an underscore and 0 for any other char; it is a position in the list, not TRUE.
	#
	#   returns    a number
	#   note       the pair - and _ separates the parts of a locale code such as en-US or en_US
	#@ aka  TRUE if the char is a locale separator (- or _).
	def IsLocaleSeparator()
		return ring_find([ "-", "_" ], This.Content())

		def IsLocaleSeperator()
			return This.IsLocaleSeparator()

	  #======================#
	 #   UNICODE VERSION    #
	#======================#

	# Returns a rough Unicode version taken from the char's block, "0.9" for nearly every char and "3.2" for emoji.
	#
	#   returns    a string
	#   warning    known defect: the version list is an approximation, marked #TODO in the data file
	#              ("Put correct values"); emoji were added in Unicode 6
	#@ aka  The Unicode version that introduced this char.
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

	# TRUE if the engine counts the char as a lowercase letter.
	#
	#   returns    TRUE or FALSE
	#   see        IsUppercase, Lowercase
	#@ aka  TRUE if the char is lowercase.
	def IsLower()
		return StzEngineCharIsLower(This.Unicode()) = 1

		def IsLowercase()
			return This.IsLower()

		def IsALowercase()
			return This.IsLower()

	# Returns the lowercase form of the char; a char with no case comes back unchanged.
	#
	#   returns    a string
	#   see        Uppercase, IsLower
	#@ aka  The lowercase form of the char.
	def Lowercase()
		return StzLower(This.Content())

		def Lowercased()
			return This.Lowercase()

	# TRUE if the engine counts the char as an uppercase letter; a Roman numeral such as U+2161 counts.
	#
	#   returns    TRUE or FALSE
	#   see        IsLower, Uppercase
	#@ aka  TRUE if the char is uppercase.
	def IsUppercase()
		return StzEngineCharIsUpper(This.Unicode()) = 1

		def IsAnUppercase()
			return This.IsUppercase()

	# Returns the uppercase form of the char; a char with no case comes back unchanged.
	#
	#   returns    a string
	#   see        Lowercase, IsUppercase
	#@ aka  The uppercase form of the char.
	def Uppercase()
		return StzUpper(This.Content())

		def Uppercased()
			return This.Uppercase()

	# Returns :lowercase or :uppercase, and an empty string for a char with no case.
	#
	#   returns    a string
	#   see        IsLower, IsUppercase
	#@ aka  The case of the char: :Lowercase, :Uppercase or NULL.
	def CharCase()
		if This.IsLowercase()
			return :Lowercase
		but This.IsUppercase()
			return :Uppercase
		ok

	  #================#
	 #   LANGUAGE     #
	#================#

	# Returns the main language of the char's script, such as english, arabic or hebrew, and undefined for chars shared by scripts.
	#
	#   returns    a string
	#   note       greek answers ancient_greek and Devanagari answers bhojpuri
	#   warning    known defect: raises "Can not create char object!" for a char of the Inherited or
	#              Unknown script, such as a combining accent, an unassigned code or a private-use
	#              char
	#   see        Script
	#@ aka  The default language of the char's script.
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

	# Returns the lowercase name of the char's Unicode script, such as latin, arabic, common or inherited.
	#
	#   returns    a string
	#   note       a digit, a space or a punctuation mark answers common; a combining accent answers
	#              inherited; when a char belongs to several scripts the first is given
	#   see        ScriptIs, DefaultLanguage
	#@ aka  The script the char belongs to.
	def Script()
		# Straight from the engine's UCD. The Ring-side _CharScriptCode range
		# table and the _aUnicodeScriptsXT name list this used to walk are
		# both retired: the engine is the Unicode reference now, and it knows
		# all 172 scripts where the table knew 8 approximately.
		_pScH_ = StzEngineString(This.Content())
		_acScNames_ = StzEngineStringScriptNamesList(_pScH_)
		StzEngineStringFree(_pScH_)

		if len(_acScNames_) > 0
			return _acScNames_[1]
		ok

		return "unknown"

		# Returns the lowercase name of the char's Unicode script, as the short form does.
		#
		#   returns    a string
		#   see        Script
		#@ aka  The Unicode script of the char.
		def UnicodeScript()
			return Script()

	# TRUE if the char's script is the named one; the name is compared in its case-folded form.
	#
	#   pcScript   the script name, as text, such as "latin"
	#   returns    TRUE or FALSE
	#   note       raises when the argument is not a string
	#   see        Script, IsLetterInScript
	#@ aka  ScriptCode()/UnicodeScriptCode() are RETIRED.
	def ScriptIs(pcScript)
		if NOT isString(pcScript)
			StzRaise("Incorrect param type! pcScript must be a string.")
		ok
		return This.Script() = StzCaseFold(pcScript)

	# TRUE if the char is a letter of the named script; a digit or a mark of that script answers FALSE.
	#
	#   pcScript   the script name, as text, such as "latin"
	#   returns    TRUE or FALSE
	#   note       raises when the argument is not a string
	#   see        ScriptIs, IsLetter
	#@ aka  TRUE if the char is a letter of the given script.
	def IsLetterInScript(pcScript)
		if NOT isString(pcScript)
			StzRaise("Incorrect param type! pcScript must be a string.")
		ok
		return ( This.IsLetter() and This.Script() = StzCaseFold(pcScript) )

	# TRUE if the char's script is unknown, as for an unassigned code or a private-use char.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, IsCommonScript
	#@ aka  TRUE if the char belongs to the Unknown script.
	def IsUnknownScript()
		return This.ScriptIs("unknown")

	# TRUE if the char takes the script of the char before it, as combining accents and the Arabic shaddah do.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, IsCommonScript
	#@ aka  TRUE if the char belongs to the Inherited script.
	def IsInheritedScript()
		return This.ScriptIs("inherited")

	# TRUE if the char is shared by many scripts, as digits, spaces and punctuation are.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, IsInheritedScript
	#@ aka  TRUE if the char belongs to the Common script.
	def IsCommonScript()
		return This.ScriptIs("common")

	# TRUE if the engine's Unicode data puts the char in the Latin script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Latin script.
	def IsLatinScript()
		return This.ScriptIs("latin")

	# TRUE if the engine's Unicode data puts the char in the Greek script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Greek script.
	def IsGreekScript()
		return This.ScriptIs("greek")

	# TRUE if the engine's Unicode data puts the char in the Cyrillic script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Cyrillic script.
	def IsCyrillicScript()
		return This.ScriptIs("cyrillic")

	# TRUE if the engine's Unicode data puts the char in the Armenian script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Armenian script.
	def IsArmenianScript()
		return This.ScriptIs("armenian")

	# TRUE if the engine's Unicode data puts the char in the Hebrew script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Hebrew script.
	def IsHebrewScript()
		return This.ScriptIs("hebrew")

	# TRUE if the engine's Unicode data puts the char in the Arabic script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Arabic script.
	def IsArabicScript()
		return This.ScriptIs("arabic")

	# TRUE if the engine's Unicode data puts the char in the Syriac script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Syriac script.
	def IsSyriacScript()
		return This.ScriptIs("syriac")

	# TRUE if the engine's Unicode data puts the char in the Thaana script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Thaana script.
	def IsThaanaScript()
		return This.ScriptIs("thaana")

	# TRUE if the engine's Unicode data puts the char in the Devanagari script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Devanagari script.
	def IsDevanagariScript()
		return This.ScriptIs("devanagari")

	# TRUE if the engine's Unicode data puts the char in the Bengali script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Bengali script.
	def IsBengaliScript()
		return This.ScriptIs("bengali")

	# TRUE if the engine's Unicode data puts the char in the Gurmukhi script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Gurmukhi script.
	def IsGurmukhiScript()
		return This.ScriptIs("gurmukhi")

	# TRUE if the engine's Unicode data puts the char in the Gujarati script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Gujarati script.
	def IsGujaratiScript()
		return This.ScriptIs("gujarati")

	# TRUE if the engine's Unicode data puts the char in the Oriya script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Oriya script.
	def IsOriyaScript()
		return This.ScriptIs("oriya")

	# TRUE if the engine's Unicode data puts the char in the Tamil script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Tamil script.
	def IsTamilScript()
		return This.ScriptIs("tamil")

	# TRUE if the engine's Unicode data puts the char in the Telugu script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Telugu script.
	def IsTeluguScript()
		return This.ScriptIs("telugu")

	# TRUE if the engine's Unicode data puts the char in the Kannada script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Kannada script.
	def IsKannadaScript()
		return This.ScriptIs("kannada")

	# TRUE if the engine's Unicode data puts the char in the Malayalam script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Malayalam script.
	def IsMalayalamScript()
		return This.ScriptIs("malayalam")

	# TRUE if the engine's Unicode data puts the char in the Sinhala script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Sinhala script.
	def IsSinhalaScript()
		return This.ScriptIs("sinhala")

	# TRUE if the engine's Unicode data puts the char in the Thai script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Thai script.
	def IsThaiScript()
		return This.ScriptIs("thai")

	# TRUE if the engine's Unicode data puts the char in the Lao script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Lao script.
	def IsLaoScript()
		return This.ScriptIs("lao")

	# TRUE if the engine's Unicode data puts the char in the Tibetan script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Tibetan script.
	def IsTibetanScript()
		return This.ScriptIs("tibetan")

	# TRUE if the engine's Unicode data puts the char in the Myanmar script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Myanmar script.
	def IsMyanmarScript()
		return This.ScriptIs("myanmar")

	# TRUE if the engine's Unicode data puts the char in the Georgian script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Georgian script.
	def IsGeorgianScript()
		return This.ScriptIs("georgian")

	# TRUE if the engine's Unicode data puts the char in the Hangul script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Hangul script.
	def IsHangulScript()
		return This.ScriptIs("hangul")

	# TRUE if the engine's Unicode data puts the char in the Ethiopic script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Ethiopic script.
	def IsEthiopicScript()
		return This.ScriptIs("ethiopic")

	# TRUE if the engine's Unicode data puts the char in the Cherokee script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Cherokee script.
	def IsCherokeeScript()
		return This.ScriptIs("cherokee")

	# TRUE if the engine's Unicode data puts the char in the Canadian Aboriginal script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Canadian Aboriginal script.
	def IsCanadianAboriginalScript()
		return This.ScriptIs("canadianaboriginal")

	# TRUE if the engine's Unicode data puts the char in the Ogham script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Ogham script.
	def IsOghamScript()
		return This.ScriptIs("ogham")

	# TRUE if the engine's Unicode data puts the char in the Runic script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Runic script.
	def IsRunicScript()
		return This.ScriptIs("runic")

	# TRUE if the engine's Unicode data puts the char in the Khmer script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Khmer script.
	def IsKhmerScript()
		return This.ScriptIs("khmer")

	# TRUE if the engine's Unicode data puts the char in the Mongolian script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Mongolian script.
	def IsMongolianScript()
		return This.ScriptIs("mongolian")

	# TRUE if the engine's Unicode data puts the char in the Hiragana script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Hiragana script.
	def IsHiraganaScript()
		return This.ScriptIs("hiragana")

	# TRUE if the engine's Unicode data puts the char in the Katakana script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Katakana script.
	def IsKatakanaScript()
		return This.ScriptIs("katakana")

	# TRUE if the engine's Unicode data puts the char in the Bopomofo script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Bopomofo script.
	def IsBopomofoScript()
		return This.ScriptIs("bopomofo")

	# TRUE if the engine's Unicode data puts the char in the Han script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Han script.
	def IsHanScript()
		return This.ScriptIs("han")

	# TRUE if the engine's Unicode data puts the char in the Yi script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Yi script.
	def IsYiScript()
		return This.ScriptIs("yi")

	# TRUE if the engine's Unicode data puts the char in the Old Italic script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Old Italic script.
	def IsOldItalicScript()
		return This.ScriptIs("olditalic")

	# TRUE if the engine's Unicode data puts the char in the Gothic script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Gothic script.
	def IsGothicScript()
		return This.ScriptIs("gothic")

	# TRUE if the engine's Unicode data puts the char in the Deseret script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Deseret script.
	def IsDeseretScript()
		return This.ScriptIs("deseret")

	# TRUE if the engine's Unicode data puts the char in the Tagalog script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Tagalog script.
	def IsTagalogScript()
		return This.ScriptIs("tagalog")

	# TRUE if the engine's Unicode data puts the char in the Hanunoo script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Hanunoo script.
	def IsHanunooScript()
		return This.ScriptIs("hanunoo")

	# TRUE if the engine's Unicode data puts the char in the Buhid script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Buhid script.
	def IsBuhidScript()
		return This.ScriptIs("buhid")

	# TRUE if the engine's Unicode data puts the char in the Tagbanwa script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Tagbanwa script.
	def IsTagbanwaScript()
		return This.ScriptIs("tagbanwa")

	# TRUE if the engine's Unicode data puts the char in the Coptic script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Coptic script.
	def IsCopticScript()
		return This.ScriptIs("coptic")

	# TRUE if the engine's Unicode data puts the char in the Limbu script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Limbu script.
	def IsLimbuScript()
		return This.ScriptIs("limbu")

	# TRUE if the engine's Unicode data puts the char in the Tai Le script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Tai Le script.
	def IsTaiLeScript()
		return This.ScriptIs("taile")

	# TRUE if the engine's Unicode data puts the char in the Linear B script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Linear B script.
	def IsLinearBScript()
		return This.ScriptIs("linearb")

	# TRUE if the engine's Unicode data puts the char in the Ugaritic script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Ugaritic script.
	def IsUgariticScript()
		return This.ScriptIs("ugaritic")

	# TRUE if the engine's Unicode data puts the char in the Shavian script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Shavian script.
	def IsShavianScript()
		return This.ScriptIs("shavian")

	# TRUE if the engine's Unicode data puts the char in the Osmanya script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Osmanya script.
	def IsOsmanyaScript()
		return This.ScriptIs("osmanya")

	# TRUE if the engine's Unicode data puts the char in the Cypriot script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Cypriot script.
	def IsCypriotScript()
		return This.ScriptIs("cypriot")

	# TRUE if the engine's Unicode data puts the char in the Braille script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Braille script.
	def IsBrailleScript()
		return This.ScriptIs("braille")

	# TRUE if the engine's Unicode data puts the char in the Buginese script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Buginese script.
	def IsBugineseScript()
		return This.ScriptIs("buginese")

	# TRUE if the engine's Unicode data puts the char in the New Tai Lue script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the New Tai Lue script.
	def IsNewTaiLueScript()
		return This.ScriptIs("newtailue")

	# TRUE if the engine's Unicode data puts the char in the Glagolitic script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Glagolitic script.
	def IsGlagoliticScript()
		return This.ScriptIs("glagolitic")

	# TRUE if the engine's Unicode data puts the char in the Tifinagh script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Tifinagh script.
	def IsTifinaghScript()
		return This.ScriptIs("tifinagh")

	# TRUE if the engine's Unicode data puts the char in the Syloti Nagri script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Syloti Nagri script.
	def IsSylotiNagriScript()
		return This.ScriptIs("sylotinagri")

	# TRUE if the engine's Unicode data puts the char in the Old Persian script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Old Persian script.
	def IsOldPersianScript()
		return This.ScriptIs("oldpersian")

	# TRUE if the engine's Unicode data puts the char in the Kharoshthi script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Kharoshthi script.
	def IsKharoshthiScript()
		return This.ScriptIs("kharoshthi")

	# TRUE if the engine's Unicode data puts the char in the Balinese script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Balinese script.
	def IsBalineseScript()
		return This.ScriptIs("balinese")

	# TRUE if the engine's Unicode data puts the char in the Cuneiform script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Cuneiform script.
	def IsCuneiformScript()
		return This.ScriptIs("cuneiform")

	# TRUE if the engine's Unicode data puts the char in the Phoenician script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Phoenician script.
	def IsPhoenicianScript()
		return This.ScriptIs("phoenician")

	# TRUE if the engine's Unicode data puts the char in the Phags Pa script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Phags Pa script.
	def IsPhagsPaScript()
		return This.ScriptIs("phagspa")

	# TRUE if the engine's Unicode data puts the char in the Nko script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Nko script.
	def IsNkoScript()
		return This.ScriptIs("nko")

	# TRUE if the engine's Unicode data puts the char in the Sundanese script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Sundanese script.
	def IsSundaneseScript()
		return This.ScriptIs("sundanese")

	# TRUE if the engine's Unicode data puts the char in the Lepcha script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Lepcha script.
	def IsLepchaScript()
		return This.ScriptIs("lepcha")

	# TRUE if the engine's Unicode data puts the char in the Ol Chiki script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Ol Chiki script.
	def IsOlChikiScript()
		return This.ScriptIs("olchiki")

	# TRUE if the engine's Unicode data puts the char in the Vai script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Vai script.
	def IsVaiScript()
		return This.ScriptIs("vai")

	# TRUE if the engine's Unicode data puts the char in the Saurashtra script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Saurashtra script.
	def IsSaurashtraScript()
		return This.ScriptIs("saurashtra")

	# TRUE if the engine's Unicode data puts the char in the Kayah Li script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Kayah Li script.
	def IsKayahLiScript()
		return This.ScriptIs("kayahli")

	# TRUE if the engine's Unicode data puts the char in the Rejang script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Rejang script.
	def IsRejangScript()
		return This.ScriptIs("rejang")

	# TRUE if the engine's Unicode data puts the char in the Lycian script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Lycian script.
	def IsLycianScript()
		return This.ScriptIs("lycian")

	# TRUE if the engine's Unicode data puts the char in the Carian script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Carian script.
	def IsCarianScript()
		return This.ScriptIs("carian")

	# TRUE if the engine's Unicode data puts the char in the Lydian script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Lydian script.
	def IsLydianScript()
		return This.ScriptIs("lydian")

	# TRUE if the engine's Unicode data puts the char in the Cham script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Cham script.
	def IsChamScript()
		return This.ScriptIs("cham")

	# Raises error R14 today instead of testing for the Tai Tham script.
	#
	#   returns    TRUE or FALSE once repaired
	#   note       the engine names the script taitham
	#   warning    known defect: the body calls ScriptCode, which was retired; ScriptIs("taitham")
	#              is the working test
	#   see        ScriptIs, Script
	#@ aka  The Tai Tham script constant.
	def TaiThamScript()
		return This.ScriptCode() = 78

	# TRUE if the engine's Unicode data puts the char in the Tai Viet script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Tai Viet script.
	def IsTaiVietScript()
		return This.ScriptIs("taiviet")

	# TRUE if the engine's Unicode data puts the char in the Avestan script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Avestan script.
	def IsAvestanScript()
		return This.ScriptIs("avestan")

	# TRUE if the engine's Unicode data puts the char in the Egyptian Hieroglyphs script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Egyptian Hieroglyphs script.
	def IsEgyptianHieroglyphsScript()
		return This.ScriptIs("egyptianhieroglyphs")

	# TRUE if the engine's Unicode data puts the char in the Samaritan script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Samaritan script.
	def IsSamaritanScript()
		return This.ScriptIs("samaritan")

	# TRUE if the engine's Unicode data puts the char in the Lisu script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Lisu script.
	def IsLisuScript()
		return This.ScriptIs("lisu")

	# TRUE if the engine's Unicode data puts the char in the Bamum script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Bamum script.
	def IsBamumScript()
		return This.ScriptIs("bamum")

	# TRUE if the engine's Unicode data puts the char in the Javanese script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Javanese script.
	def IsJavaneseScript()
		return This.ScriptIs("javanese")

	# TRUE if the engine's Unicode data puts the char in the Meetei Mayek script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Meetei Mayek script.
	def IsMeeteiMayekScript()
		return This.ScriptIs("meeteimayek")

	# TRUE if the engine's Unicode data puts the char in the Imperial Aramaic script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Imperial Aramaic script.
	def IsImperialAramaicScript()
		return This.ScriptIs("imperialaramaic")

	# TRUE if the engine's Unicode data puts the char in the Old South Arabian script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Old South Arabian script.
	def IsOldSouthArabianScript()
		return This.ScriptIs("oldsoutharabian")

	# TRUE if the engine's Unicode data puts the char in the Inscriptional Parthian script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Inscriptional Parthian script.
	def IsInscriptionalParthianScript()
		return This.ScriptIs("inscriptionalparthian")

	# TRUE if the engine's Unicode data puts the char in the Inscriptional Pahlavi script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Inscriptional Pahlavi script.
	def IsInscriptionalPahlaviScript()
		return This.ScriptIs("inscriptionalpahlavi")

	# TRUE if the engine's Unicode data puts the char in the Old Turkic script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Old Turkic script.
	def IsOldTurkicScript()
		return This.ScriptIs("oldturkic")

	# TRUE if the engine's Unicode data puts the char in the Kaithi script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Kaithi script.
	def IsKaithiScript()
		return This.ScriptIs("kaithi")

	# TRUE if the engine's Unicode data puts the char in the Batak script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Batak script.
	def IsBatakScript()
		return This.ScriptIs("batak")

	# TRUE if the engine's Unicode data puts the char in the Brahmi script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Brahmi script.
	def IsBrahmiScript()
		return This.ScriptIs("brahmi")

	# TRUE if the engine's Unicode data puts the char in the Mandaic script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Mandaic script.
	def IsMandaicScript()
		return This.ScriptIs("mandaic")

	# TRUE if the engine's Unicode data puts the char in the Chakma script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Chakma script.
	def IsChakmaScript()
		return This.ScriptIs("chakma")

	# TRUE if the engine's Unicode data puts the char in the Meroitic Cursive script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Meroitic Cursive script.
	def IsMeroiticCursiveScript()
		return This.ScriptIs("meroiticcursive")

	# TRUE if the engine's Unicode data puts the char in the Meroitic Hieroglyphs script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Meroitic Hieroglyphs script.
	def IsMeroiticHieroglyphsScript()
		return This.ScriptIs("meroitichieroglyphs")

	# TRUE if the engine's Unicode data puts the char in the Miao script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Miao script.
	def IsMiaoScript()
		return This.ScriptIs("miao")

	# TRUE if the engine's Unicode data puts the char in the Sharada script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Sharada script.
	def IsSharadaScript()
		return This.ScriptIs("sharada")

	# TRUE if the engine's Unicode data puts the char in the Sora Sompeng script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Sora Sompeng script.
	def IsSoraSompengScript()
		return This.ScriptIs("sorasompeng")

	# TRUE if the engine's Unicode data puts the char in the Takri script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Takri script.
	def IsTakriScript()
		return This.ScriptIs("takri")

	# TRUE if the engine's Unicode data puts the char in the Caucasian Albanian script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Caucasian Albanian script.
	def IsCaucasianAlbanianScript()
		return This.ScriptIs("caucasianalbanian")

	# TRUE if the engine's Unicode data puts the char in the Bassa Vah script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Bassa Vah script.
	def IsBassaVahScript()
		return This.ScriptIs("bassavah")

	# TRUE if the engine's Unicode data puts the char in the Duployan script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Duployan script.
	def IsDuployanScript()
		return This.ScriptIs("duployan")

	# TRUE if the engine's Unicode data puts the char in the Elbasan script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Elbasan script.
	def IsElbasanScript()
		return This.ScriptIs("elbasan")

	# TRUE if the engine's Unicode data puts the char in the Grantha script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Grantha script.
	def IsGranthaScript()
		return This.ScriptIs("grantha")

	# TRUE if the engine's Unicode data puts the char in the Pahawh Hmong script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Pahawh Hmong script.
	def IsPahawhHmongScript()
		return This.ScriptIs("pahawhhmong")

	# TRUE if the engine's Unicode data puts the char in the Khojki script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Khojki script.
	def IsKhojkiScript()
		return This.ScriptIs("khojki")

	# TRUE if the engine's Unicode data puts the char in the Linear A script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Linear A script.
	def IsLinearAScript()
		return This.ScriptIs("lineara")

	# TRUE if the engine's Unicode data puts the char in the Mahajani script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Mahajani script.
	def IsMahajaniScript()
		return This.ScriptIs("mahajani")

	# TRUE if the engine's Unicode data puts the char in the Manichaean script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Manichaean script.
	def IsManichaeanScript()
		return This.ScriptIs("manichaean")

	# TRUE if the engine's Unicode data puts the char in the Mende Kikakui script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Mende Kikakui script.
	def IsMendeKikakuiScript()
		return This.ScriptIs("mendekikakui")

	# TRUE if the engine's Unicode data puts the char in the Modi script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Modi script.
	def IsModiScript()
		return This.ScriptIs("modi")

	# TRUE if the engine's Unicode data puts the char in the Mro script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Mro script.
	def IsMroScript()
		return This.ScriptIs("mro")

	# TRUE if the engine's Unicode data puts the char in the Old North Arabian script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Old North Arabian script.
	def IsOldNorthArabianScript()
		return This.ScriptIs("oldnortharabian")

	# TRUE if the engine's Unicode data puts the char in the Nabataean script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Nabataean script.
	def IsNabataeanScript()
		return This.ScriptIs("nabataean")

	# TRUE if the engine's Unicode data puts the char in the Palmyrene script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Palmyrene script.
	def IsPalmyreneScript()
		return This.ScriptIs("palmyrene")

	# TRUE if the engine's Unicode data puts the char in the Pau Cin Hau script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Pau Cin Hau script.
	def IsPauCinHauScript()
		return This.ScriptIs("paucinhau")

	# TRUE if the engine's Unicode data puts the char in the Old Permic script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Old Permic script.
	def IsOldPermicScript()
		return This.ScriptIs("oldpermic")

	# TRUE if the engine's Unicode data puts the char in the Psalter Pahlavi script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Psalter Pahlavi script.
	def IsPsalterPahlaviScript()
		return This.ScriptIs("psalterpahlavi")

	# TRUE if the engine's Unicode data puts the char in the Siddham script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Siddham script.
	def IsSiddhamScript()
		return This.ScriptIs("siddham")

	# TRUE if the engine's Unicode data puts the char in the Khudawadi script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Khudawadi script.
	def IsKhudawadiScript()
		return This.ScriptIs("khudawadi")

	# TRUE if the engine's Unicode data puts the char in the Tirhuta script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Tirhuta script.
	def IsTirhutaScript()
		return This.ScriptIs("tirhuta")

	# TRUE if the engine's Unicode data puts the char in the Warang Citi script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Warang Citi script.
	def IsWarangCitiScript()
		return This.ScriptIs("warangciti")

	# TRUE if the engine's Unicode data puts the char in the Ahom script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Ahom script.
	def IsAhomScript()
		return This.ScriptIs("ahom")

	# TRUE if the engine's Unicode data puts the char in the Anatolian Hieroglyphs script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Anatolian Hieroglyphs script.
	def IsAnatolianHieroglyphsScript()
		return This.ScriptIs("anatolianhieroglyphs")

	# TRUE if the engine's Unicode data puts the char in the Hatran script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Hatran script.
	def IsHatranScript()
		return This.ScriptIs("hatran")

	# TRUE if the engine's Unicode data puts the char in the Multani script.
	#
	#   returns    TRUE or FALSE
	#   see        ScriptIs, Script
	#@ aka  TRUE if the char belongs to the Multani script.
	def IsMultaniScript()
		return This.ScriptIs("multani")

	  #----------------------------#
	 #  CHAR RANGE (UpTo/DownTo)  #
	#----------------------------#

	# Returns the chars from this one up to the given char, both included, in codepoint order; an empty list if it is not above.
	#
	#   pcChar     the char to stop at, included
	#   returns    a list of chars
	#   note       the same char on both sides answers an empty list, not a list of one
	#   see        DownTo
	#@ aka  The chars from this one UP TO the given char, as a list.
	def UpTo(pcChar)
		_nUtFrom_ = This.Unicode()
		_nUtTo_ = StzEngineCharUnicode(pcChar)
		if _nUtFrom_ >= _nUtTo_ return [] ok

		_aUtResult_ = []
		for _nUtI_ = _nUtFrom_ to _nUtTo_
			_aUtResult_ + StzCharQ(_nUtI_).Content()
		next
		return _aUtResult_

	# Returns the chars from this one down to the given char, both included, in falling codepoint order; an empty list if it is not below.
	#
	#   pcChar     the char to stop at, included
	#   returns    a list of chars
	#   note       the same char on both sides answers an empty list, not a list of one
	#   see        UpTo
	#@ aka  The chars from this one DOWN TO the given char, as a list.
	def DownTo(pcChar)
		_nDtFrom_ = This.Unicode()
		_nDtTo_ = StzEngineCharUnicode(pcChar)
		if _nDtFrom_ <= _nDtTo_ return [] ok

		_aDtResult_ = []
		for _nDtI_ = _nDtFrom_ to _nDtTo_ step -1
			_aDtResult_ + StzCharQ(_nDtI_).Content()
		next
		return _aDtResult_
