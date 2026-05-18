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
	if nUnicode <= 0x24F return 7 ok
	if nUnicode >= 0x0370 and nUnicode <= 0x03FF return 8 ok
	if nUnicode >= 0x0400 and nUnicode <= 0x04FF return 9 ok
	if nUnicode >= 0x0530 and nUnicode <= 0x058F return 10 ok
	if nUnicode >= 0x0590 and nUnicode <= 0x05FF return 11 ok
	if nUnicode >= 0x0600 and nUnicode <= 0x06FF return 8 ok
	if nUnicode >= 0x0900 and nUnicode <= 0x097F return 14 ok
	if nUnicode >= 0x4E00 and nUnicode <= 0x9FFF return 38 ok
	if nUnicode >= 0xAC00 and nUnicode <= 0xD7AF return 28 ok
	if nUnicode >= 0x3040 and nUnicode <= 0x309F return 27 ok
	if nUnicode >= 0x30A0 and nUnicode <= 0x30FF return 26 ok
	if nUnicode >= 0x0E00 and nUnicode <= 0x0E7F return 33 ok
	return 0

#-- Public standalone functions

func IsInvisibleChar(c)
	if CheckParams()
		if NOT isString(c)
			stzraise("Incorrect param type! c must be a string.")
		ok
		if NOT IsChar(c)
			stzraise("Incorrect param type! c must be a char.")
		ok
	ok

	if ring_find( InvisibleChars(), c )
		return 1
	else
		return 0
	ok

	func @IsInvisibleChar(c)
		return IsInvisibleChar(c)

func Space(n)
	return Copy(" ", n)

	func @Space(n)
		return Copy(" ", n)

func StzCharQ(p)
	return new stzStringChar(p)

	func CQ(p)
		return StzCharQ(p)

func UnicodeChar(n)
	nMax = MaxUnicodeNumber()
	if NOT ( isNumber(n) and n <= nMax )
		StzRaise("Incorrect param type! p must be a number less then " + nMax + "!")
	ok
	return StzCharQ(n).Content()

	func StzChar(n)
		return UnicodeChar(n)

	func UChar(n)
		return UnicodeChar(n)

func StzCharMethods()
	return Stz(:Char, :Methods)

func StzCharAttributes()
	return Stz(:Char, :Attributes)

func StzCharClass()
	return "stzstringchar"

	func StzCharClassName()
		return StzCharClass()

func IsAsciiChar(c)
	if NOT isString(c)
		return 0
	ok
	return StzCharQ(c).IsAscii()

	func IsAnAsciiChar(c)
		return IsAsciiChar(c)

	func @IsAsciiChar(c)
		return IsAsciiChar(c)

	func @IsAnAsciiChar(c)
		return IsAsciiChar(c)

func IsChar(pStrOrNbr)
	if isString(pStrOrNbr)
		if isNumber(Unicode(pStrOrNbr))
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

	func @IsChar(pcStr)
		return IsChar(pcStr)

	func IsAChar(pcStr)
		return IsChar(pcStr)

	func @IsAChar(pcStr)
		return IsChar(pcStr)

	func IsALetter(pcStr)
		return IsLetter(pcStr)

	func @IsALetter(pcStr)
		return IsLetter(pcStr)

func QuotationMark()
	return '"'

	func DoubleQuote()
		return '"'

func Apostrophe()
	return "'"

	func SingleQuote()
		return "'"

func CharName(c)
	return StzCharQ(c).Name()

	func @CharName(c)
		return CharName(c)

	func Name(c)
		return CharName(c)

	func @Name(c)
		return CharName(c)

func UnicodeToHexUnicode(n)
	oChar = new stzStringChar(n)
	return oChar.HexUnicode()

func HexUnicodeToUnicode(cHex)
	oChar = new stzStringChar(cHex)
	return oChar.Unicode()

func CharToUnicode(c)
	if NOT isString(c)
		StzRaise("Can't proceed! You must provide a char in a string type.")
	ok
	return StzCharQ(c).Unicode()

	def CharUnicode(c)
		return CharToUnicode(c)

func UnicodeToChar(nUnicode)
	oChar = new stzStringChar(nUnicode)
	return oChar.Content()

	func @Char(nUnicode)
		return UnicodeToChar(nUnicode)

func UnicodeSectionToListOfChars(nUnicode1, nUnicode2)
	aResult = []
	for nUnicode = nUnicode1 to nUnicode2
		aResult + UnicodeToChar( nUnicode )
	next
	return aResult

func UnicodeSectionToListOfStzChars(nUnicode1, nUnicode2)
	aResult = []
	for nUnicode = nUnicode1 to nUnicode2
		aResult + new stzStringChar( nUnicode )
	next
	return aResult

func UnicodeSectionToStzListOfChars(nUnicode1, nUnicode2)
	return new stzListOfChars( UnicodeSectionToListOfChars(nUnicode1, nUnicode2) )

func CurrentUnicodeVersion()
	return _acUnicodeVersions[ len(_acUnicodeVersions) ]

func UnicodeCharName(c)
	return "NOT_AVAILABLE"

func CharScript(c)
	oTempChar = new stzStringChar(c)
	return oTempChar.Script()

func CharIsArabicShaddah(c)
	oChar = new stzStringChar(c)
	return oChar.IsArabicShaddah()

func CharIsArabic7arakah(c)
	oChar = new stzStringChar(c)
	return oChar.IsArabic7arakah()

func CharIsWordSeparator(c)
	return StzCharQ(c).IsWordSeparator()

	func CharIsWordSeperator(c)
		return CharIsWordSeparator(c)

func CharIsSenstenceSeparator(c)
	return StzCharQ(c).IsSentenceSeparator(c)

	func CharIsSenstenceSeperator(c)
		return CharIsSenstenceSeparator(c)

func CharIsLineSeparator(c)
	return StzCharQ(c).IsLineSeparator(c)

	func CharIsLineSeperator(c)
		return CharIsLineSeparator(c)

func RemoveDiacritic(pcChar)
	return StzCharQ(pcChar).DiacriticRemoved()

func ACharOtherThan(pcChar)
	nUnicode = Unicode(pcChar)
	n = StzListOfNumbersQ( 1: NumberOfUnicodeChars()).ANumberOtherThan(nUnicode)
	cResult = StzCharQ(n).Content()
	return cResult

	func ACharDifferentThan(pcChar)
		return ACharOtherThan(pcChar)

	func ACharDifferentFrom(pcChar)
		return ACharOtherThan(pcChar)

	func CharOtherThan(pcChar)
		return ACharOtherThan(pcChar)

	func CharDifferentThan(pcChar)
		return ACharOtherThan(pcChar)

	func CharDifferentFrom(pcChar)
		return ACharOtherThan(pcChar)

	func AnyCharOtherThan(pcChar)
		return ACharOtherThan(pcChar)

	func AnyCharDifferentThan(pcChar)
		return ACharOtherThan(pcChar)

	func AnyCharDifferentFrom(pcChar)
		return ACharOtherThan(pcChar)

func LastUnicodeChar()
	return StzCharQ( NumberOfUnicodeChars() ).Content()

	func LastCharInUnicode()
		return LastUnicodeChar()

func FirstUnicodeChar()
	return StzCharQ( 1 ).Content()

	func FirstCharInUnicode()
		return FirstUnicodeChar()

#-- Natural-coding functions

func Letter(pcChar)
	if @IsChar(pcChar) and StzCharQ(pcChar).IsLetter()
		return StzCharQ(pcChar).Uppercased()
	ok

func Letter@(pcChar)
	if @IsChar(pcChar) and StzCharQ(pcChar).IsLetter()
		return ComputableForm(pcChar)
	ok

func Character(pcChar)
	if @IsChar(pcChar)
		return pcChar
	ok

func Character@(pcChar)
	if @IsChar(pcChar)
		return ComputableForm(pcChar)
	ok

func ArabicLetter(pcChar)
	if @IsChar(pcChar) and StzCharQ(pcChar).IsArabicLetter()
		return pcChar
	ok

func ArabicLetter@(pcChar)
	if @IsChar(pcChar) and StzCharQ(pcChar).IsArabicLetter()
		return ComputableForm(pcChar)
	ok

func LatinLetter(pcChar)
	if @IsChar(pcChar) and StzCharQ(pcChar).IsLatinLetter()
		return pcChar
	ok

func LatinLetter@(pcChar)
	if @IsChar(pcChar) and StzCharQ(pcChar).IsLatinLetter()
		return ComputableForm(pcChar)
	ok

func ArabicNumber(pcChar)
	if @IsChar(pcChar) and StzCharQ(pcChar).IsArabicNumber()
		return pcChar
	ok

func ArabicNumber@(pcChar)
	if @IsChar(pcChar) and StzCharQ(pcChar).IsArabicNumber()
		return ComputableForm(pcChar)
	ok

func RomanNumber(pcChar)
	if @IsChar(pcChar) and StzCharQ(pcChar).IsRomanNumber()
		return pcChar
	ok

func RomanNumber@(pcChar)
	if @IsChar(pcChar) and StzCharQ(pcChar).IsRomanNumber()
		return ComputableForm(pcChar)
	ok

func FirstCharOf(pcStr)
	return substr(pcStr, 1, 1)

	func FirstCharIn(pcStr)
		return FirstCharOf(pcStr)

func LastCharOf(pcStr)
	return substr(pcStr, len(pcStr), 1)

	func LastCharIn(pcStr)
		return LastCharOf(pcStr)

func FirstLetterOf(pcStr)
	oStzStr = new stzString(pcStr)
	for i = 1 to oStzStr.NumberOfChars()
		if StzCharQ(oStzStr[i]).IsLetter()
			return oStzStr[i]
		ok
	next

	func FirstLetterIn(pcStr)
		return FirstLetterOf(pcStr)

func LastLetterOf(pcStr)
	cReversed = ""
	for _i = len(pcStr) to 1 step -1
		cReversed += pcStr[_i]
	next
	return FirstLetterOf(cReversed)

	func LastLetterIn(pcStr)
		return LastLetterOf(pcStr)

func NumberOfLatinLetters()
	return 52

	func HowManyLatinLetters()
		return NumberOfLatinLetters()

func NumberOfArabicLetters()
	return len( ArabicLetters() )

	func HowManyArabicLetters()
		return NumberOfArabicLetters()

func NumberOfChineseLetters()
	return 20000

	func HowManyChineseLetters()
		return NumberOfChineseLetters()

func NthChar(n, str)
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

	cResult = substr(str, n, 1)
	return cResult

	func @NthChar(n, str)
		return NthChar(n, str)

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

func CharByName(cName)
	return StzUnicodeDataQ().CharByName(cName)

	func @CharByName(cName)
		return CharByName(cName)


  /////////////////
 ///   CLASS   ///
/////////////////

class stzStringChar from stzObject

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

			but oStr.RepresentsNumberInHexForm() or
			    oStr.RepresentsNumberInUnicodeHexForm()
				nUnicode = StzHexNumberQ(pChar).ToDecimal()
				cBuf = space(4)
				nLen = StzEngineCharToUtf8(nUnicode, cBuf, 4)
				@oString = new stzString(left(cBuf, nLen))

			but oStr.IsCharName()
				nUnicode = StzUnicodeDataQ().CharUnicodeByName(pChar)
				cBuf = space(4)
				nLen = StzEngineCharToUtf8(nUnicode, cBuf, 4)
				@oString = new stzString(left(cBuf, nLen))

			else
				StzRaise("Can not create char object!")
			ok

		but isNumber(pChar)
			cBuf = space(4)
			nLen = StzEngineCharToUtf8(pChar, cBuf, 4)
			@oString = new stzString(left(cBuf, nLen))

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
			@oString = new stzString(left(cBuf, nLen))
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
		cHex = DecimalToHex( This.Unicode() )
		cResult = StzUnicodeDataQ().CharNameByHexCode(cHex)
		if cResult = ""
			StzRaise("Can't proceed! The name of this char (" + This.Content() + ") does not exist in the local unicode database.")
		ok
		return cResult

		def UnicodeName()
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

	  #===================#
	 #   SIZE & BYTES    #
	#===================#

	def NumberOfBytes()
		return @SizeInBytes(This.Content())

		def HowManyBytes()
			return This.NumberOfBytes()

		def HowManyByte()
			return This.NumberOfBytes()

		def SizeInBytes()
			return This.NumberOfBytes()

		def CountBytes()
			return This.NumberOfBytes()

	def Bytes()
		oStzBinStr = new stzListOfBytes(This.Content())
		return oStzBinStr.Bytes()

	def SizeInChars()
		return @oString.NumberOfChars()

		def NumberOfChars()
			return This.SizeInChars()

	  #=====================================#
	 #   ORIENTATION & UNICODE DIRECTION   #
	#=====================================#

	def Orientation()
		return @oString.Orientation()

	def UnicodeDirection()
		for aLine in UnicodeDirectionsXT()
			if aLine[1] = This.UnicodeDirectionNumber()
				return aLine[3]
			ok
		next

	def UnicodeDirectionNumber()
		return "" + _CharBidiClass(This.Unicode())

	def IsVowel()
		if ring_find( Vowels(), This.Content() ) > 0
			return 1
		else
			return 0
		ok

		def IsAVowel()
			return This.IsVowel()

	def IsLeftToRight()
		return This.UnicodeDirectionNumber() = "0"

	def IsRightToLeft()
		return This.UnicodeDirectionNumber() = "13"

	def IsArabicFraction()
		oList = new stzList(ArabicFractionsUnicodes())
		return oList.Contains(This.Unicode())

	def IsEuropeanDigit()
		return This.IsEuropeanNumber()

	def IsEuropeanNumberSeparator()
		return This.UnicodeDirectionNumber() = "3"

		def IsEuropeanNumberSeperator()
			return This.IsEuropeanNumberSeparator()

	def IsEuropeanNumberTerminator()
		return This.UnicodeDirectionNumber() = "4"

	def IsIndianDigit()
		for cDigit in IndianDigits()
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

	def IsArabicNumber()
		oStzList = new stzList( ArabicDigits() )
		return oStzList.Contains(This.Content())

	def IsANumber()
		return This.IsDigit() or This.IsCircledDigit()

	def IsIndianNumber()
		for c in IndianDigits()
			if c = This.Content()
				return 1
			ok
		next
		return 0

	def IsRomanNumber()
		if Q(This.Content()).ExistsIn( RomanNumbers() )
			return 1
		else
			return 0
		ok

	def IsMandarinNumber()
		oList = new stzList( MandarinNumbers() )
		return oList.Contains(This.Content())

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
		return ring_find( GeneralPunctuationUnicodes(), This.Unicode() ) > 0

	def IsSupplementalPunctuation()
		return ring_find( SupplementalPunctuationUnicodes(), This.Unicode() ) > 0

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

		if ring_find(pacChars, This.Char()) > 0
			return 1
		else
			return 0
		ok

	def IsWordSeparator()
		if ring_find( WordSeparators(), This.Char() ) > 0
			return 1
		else
			return 0
		ok

	def IsSentenceSeparator()
		if ring_find( SentenceSeparators(), This.Char() ) > 0
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
		return ring_find( WordNonLetterChars(), This.Content() ) > 0

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
		oList = new stzList(_anBasicLatinUnicodes)
		return oList.Contains(This.Unicode())

	def IsLatin1Supplement()
		oList = new stzList(_anLatin1SupplementUnicodes)
		return oList.Contains(This.Unicode())

	def IsLatinExtendedA()
		oList = new stzList(_anLatinExtendedAUnicodes)
		return oList.Contains(This.Unicode())

	def IsLatinExtendedB()
		oList = new stzList(_anLatinExtendedBUnicodes)
		return oList.Contains(This.Unicode())

	def IsLatinExtendedAdditional()
		oList = new stzList(_anLatinExtendedAdditionalUnicodes)
		return oList.Contains(This.Unicode())

	def IsLatinExtendedC()
		oList = new stzList(_anLatinExtendedCUnicodes)
		return oList.Contains(This.Unicode())

	def IsLatinExtendedD()
		oList = new stzList(_anLatinExtendedDUnicodes)
		return oList.Contains(This.Unicode())

	def IsLatinExtendedE()
		oList = new stzList(_anLatinExtendedEUnicodes)
		return oList.Contains(This.Unicode())

	  #=========================#
	 #   ARABIC CHAR VARIANTS  #
	#=========================#

	def IsArabic()
		return StzEngineUnicodeIsArabic(This.Unicode())

	def IsArabicLetter()
		nCp = This.Unicode()
		return StzEngineUnicodeIsLetter(nCp) AND StzEngineUnicodeIsArabic(nCp)

	def IsBasicArabic()
		oList = new stzList(_anBasicArabicUnicodes)
		return oList.Contains(This.Unicode())

	def IsArabicSupplement()
		oList = new stzList(_anArabicSupplementUnicodes)
		return oList.Contains(This.Unicode())

	def IsArabicExtendedA()
		oList = new stzList(_anArabicExtendedAUnicodes)
		return oList.Contains(This.Unicode())

	def IsArabicExtended()
		return IsArabicExtendedA()

	def IsArabicPresentationForm()
		oList = new stzList(_anArabicPresentationFormUnicodes)
		return oList.Contains(This.Unicode())

	def IsArabicPresentationFormA()
		oList = new stzList(_anArabicPresentationFormAUnicodes)
		return oList.Contains(This.Unicode())

	def IsArabicPresentationFormB()
		oList = new stzList(_anArabicPresentationFormBUnicodes)
		return oList.Contains(This.Unicode())

	def IsArabicMathAlphabeticSymbol()
		oList = new stzList(_anArabicMathAlphabeticSymbolUnicodes)
		return oList.Contains(This.Unicode())

	def IsQuranicSign()
		oTempList = new stzList(QuranicSignUnicodes())
		return oTempList.Contains(This.Unicode())

	def IsTurnedNumber()
		oTempList = new stzList(TurnedDigitUnicodes())
		return oTempList.Contains(This.Unicode())

	  #=============================#
	 #   CIRCLED CHAR VARIANTS     #
	#=============================#

	def IsCircled()
		oTempList = new stzList(CircledCharUnicodes())
		return oTempList.contains(This.Unicode())

		def IsCircledChar()
			return This.IsCircled()

	def IsCircledNumber()
		oTempList = new stzList(CircledNumberUnicodes())
		return oTempList.Contains(This.Unicode())

	def IsCircledDigit()
		oTempList = new stzList(CircledDigitUnicodes())
		return oTempList.Contains(This.Unicode())

	def IsCircledLatinLetter()
		oTempList = new stzList(CircledLatinLetterUnicodes())
		return oTempList.contains(This.Unicode())

	def IsCircledLatinSmallLetter()
		oTempList = new stzList(CircledLatinSmallLetterUnicodes())
		return oTempList.contains(This.Unicode())

	def IsCircledLatinCapitalLetter()
		oTempList = new stzList(CircledLatinCapitalLetterUnicodes())
		return oTempList.contains(This.Unicode())

	def IsOtherCircledChar()
		oTempList = new stzList(OtherCircledCharUnicodes())
		return oTempList.contains(This.Unicode())

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
		if This.Content() = "-" or This.Content() = "_"
			return 1
		else
			return 0
		ok

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
		# Use engine: create a 1-char string, lowercase it, return result
		pHandle = StzEngineString(This.Content())
		pLower = StzEngineStringToLower(pHandle)
		cResult = StzEngineStringData(pLower)
		StzEngineStringFree(pLower)
		StzEngineStringFree(pHandle)
		return cResult

		def Lowercased()
			return This.Lowercase()

	def IsUppercase()
		return StzEngineCharIsUpper(This.Unicode()) = 1

		def IsAnUppercase()
			return This.IsUppercase()

	def Uppercase()
		# Use engine: create a 1-char string, uppercase it, return result
		pHandle = StzEngineString(This.Content())
		pUpper = StzEngineStringToUpper(pHandle)
		cResult = StzEngineStringData(pUpper)
		StzEngineStringFree(pUpper)
		StzEngineStringFree(pHandle)
		return cResult

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
		return This.Script() = ring_lower(pcScript)

	def IsLetterInScript(pcScript)
		if NOT isString(pcScript)
			StzRaise("Incorrect param type! pcScript must be a string.")
		ok
		return ( This.IsLetter() and This.Script() = ring_lower(pcScript) )

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
