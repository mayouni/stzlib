#---------------------------------------------------------------------------#
# 		    SOFTANZA LIBRARY (V1.0) - STZCHAR			    #
#		An accelerative library for Ring applications		    #
#---------------------------------------------------------------------------#
#									    #
# 	Description	: The class for managing Unicode chars in Softanza  #
#	Version		: V1.0 (2020-2024)				    #
#	Author		: Mansour Ayouni (kalidianow@gmail.com)		    #
#									    #
#---------------------------------------------------------------------------#

/*

From Qt documentation:

So isNumber() will check if the given QChar is part of the unicode
classes Nd, Nl or No. For example, ㊱ is classified as "Number,
other", whereas Ⅱ (roman numeral two) is classified as
"Number, letter".

"½" is a character. It is a number, but it is not a digit.

-------------

From Stackoverflow
shorturl.at/cezFU

Strangely enough, nobody pointed out how to calculate how many bytes
is taking one Unicode char. Here is the rule for UTF-8 encoded strings:

Binary    Hex          Comments
0xxxxxxx  0x00..0x7F   Only byte of a 1-byte character encoding
10xxxxxx  0x80..0xBF   Continuation byte: one of 1-3 bytes following the first
110xxxxx  0xC0..0xDF   First byte of a 2-byte character encoding
1110xxxx  0xE0..0xEF   First byte of a 3-byte character encoding
11110xxx  0xF0..0xF7   First byte of a 4-byte character encoding

So the quick answer is: it takes 1 to 4 bytes, depending on the first
one which will indicate how many bytes it'll take up.

-------------

General note:

A the Char level, SoftanzaLib uses the term Digit and not Number
except when this is required to refer to a standard unicode feature
or 'unavoidable' Qt feature.


*/

#TODO // Add ZeroWithChars()
#--> [\u200B\u200C\u200D\u200E\u200F\uFEFF]


  /////////////////////
 ///   FUNCTIONS   ///
/////////////////////

func DistanceZero() # See the stzDistanceZero class
	return "🔻"

	func ZeroDistance()
		return DistanceZero()

	func DistanceZeroChar()
		return DistanceZero()

	func ZeroDistanceChar()
		return DistanceZero()

func StzCharQ(p)
	return new stzChar(p)

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
	return "stzchar"

	func StzCharClassName()
		return StzCharClass()

func IsAsciiChar(c)
	if NOT isString(c)
		return FALSE
	ok

	return StzCharQ(c).IsAscii()

	#< @FunctionAlternativeForms

	func IsAnAsciiChar(c)
		return IsAsciiChar(c)

	func @IsAsciiChar(c)
		return IsAsciiChar(c)

	func @IsAnAsciiChar(c)
		return IsAsciiChar(c)

	#>

func IsChar(pStrOrNbr)
	if isString(pStrOrNbr)
		if isNumber(Unicode(pStrOrNbr))
			return TRUE
		else
			return FALSE
		ok

	but isNumber(pStrOrNbr)

		cStringified = ""+ pStrOrNbr
		if substr(cStringified, ".") > 0
			return FALSE
		ok

		n = 0+ cStringified
		if n < 0 or n > 9
			return FALSE
		ok

		return TRUE

	else
		return FALSE
	ok

	func @IsChar(pcStr)
		return IsChar(pcStr)


	func IsAChar(pcStr)
		return IsChar(pcStr)

	func @IsAChar(pcStr)
		return IsChar(pcStr)

	#>

func IsLetter(pcStr)
	if NOT isString(pcStr)
		return FALSE
	ok

	oStzChar = new stzChar(pcStr)
	return oStzChar.IsLetter()

	#< @FunctionAlternativeForms

	func @IsLetter(pcStr)
		return IsLetter(pcStr)

	func IsALetter(pcStr)
		return IsLetter(pcStr)

	func @IsALetter(pcStr)
		return IsLetter(pcStr)

	#>

func CharName(c)
	return StzCharQ(c).Name()

	func Name(c)
		return CharName(c)

	func @Name(c)
		return CharName(c)

func UnicodeToHexUnicode(n)
	oChar = new stzChar(n)
	cResult = oChar.HexUnicode()
	return cResult

func HexUnicodeToUnicode(cHex)
	oChar = new stzChar(cHex)
	nResult = oChar.Unicode()
	return nResult

func CharToUnicode(c)
	if NOT isString(c)
		StzRaise("Can't proceed! You must provide a char in a string type.")
	ok

	return StzCharQ(c).Unicode()

	def CharUnicode(c)
		return CharToUnicode(c)

func UnicodeToChar(nUnicode)
	oChar = new stzChar(nUnicode)
	return oChar.Content()	

func UnicodeSectionToListOfChars(nUnicode1, nUnicode2)
	aResult = []

	for nUnicode = nUnicode1 to nUnicode2
		aResult + UnicodeToChar( nUnicode )
	next

	return aResult

func UnicodeSectionToListOfStzChars(nUnicode1, nUnicode2)
	aResult = []

	for nUnicode = nUnicode1 to nUnicode2
		aResult + new stzChar( nUnicode )
	next

	return aResult

func UnicodeSectionToStzListOfChars(nUnicode1, nUnicode2)
	return new stzListOfChars( UnicodeSectionToListOfChars(nUnicode1, nUnicode2) )

func CurrentUnicodeVersion()
	oQchar = new QChar(65)
	n = oQChar.currentUnicodeVersion()

	if n > 0 and n <= len(_acUnicodeVersions)
		return _acUnicodeVersions[ n ]
	else
		StzRaise(stzCharError(:CanNotDefineUnicodeVersion))
	ok

// Returns the unicode name of the char in the unicode table
func UnicodeCharName(c)
	return stzQChar(c).UnicodeName()

func CharScript(c)
	oTempChar = new stzChar(c)
	return oTempChar.Script()

func CharIsArabicShaddah(c)
	oChar = new stzChar(c)
	return oChar.IsArabicShaddah()

func CharIsArabic7arakah(c)
	oChar = new stzChar(c)
	return oChar.IsArabic7arakah()

func CharIsWordSeparator(c)
	return StzCharQ(c).IsWordSeparator()

func CharIsSenstenceSeparator(c)
	return StzCharQ(c).IsSentenceSeparator(c)

func CharIsLineSeparator(c)
	return StzCharQ(c).IsLineSeparator(c)

func RemoveDiacritic(pcChar)
	return StzCharQ(pcChar).DiacriticRemoved()

func ACharOtherThan(pcChar)

	nUnicode = Unicode(pcChar)
	n = StzListOfNumbersQ( 1: NumberOfUnicodeChars()).ANumberOtherThan(nUnicode)

	cResult = StzCharQ(n).Content()
	return cResult

	#< @FunctionAlternativeForms

	func ACharDifferentThan(pcChar)
		return ACharOtherThan(pcChar)

	func ACharDifferentFrom(pcChar)
		return ACharOtherThan(pcChar)

	#--

	func CharOtherThan(pcChar)
		return ACharOtherThan(pcChar)

	func CharDifferentThan(pcChar)
		return ACharOtherThan(pcChar)

	func CharDifferentFrom(pcChar)
		return ACharOtherThan(pcChar)

	#--

	func AnyCharOtherThan(pcChar)
		return ACharOtherThan(pcChar)

	func AnyCharDifferentThan(pcChar)
		return ACharOtherThan(pcChar)

	func AnyCharDifferentFrom(pcChar)
		return ACharOtherThan(pcChar)

	#>

func LastUnicodeChar()
	return StzCharQ( NumberOfUnicodeChars() ).Content()

	func LastCharInUnicode()
		return LastUnicodeChar()

func FirstUnicodeChar()
	return StzCharQ( 1 ).Content()

	func FirstCharInUnicode()
		return FirstUnicodeChar()

#---- Functions used for natural-coding
#TODO // generate all the possible functions based on stzChar methods

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
	return StzStringQ(pcStr).FirstChar()

	func FirstCharIn(pcStr)
		return FirstCharOf(pcStr)

func LastCharOf(pcStr)
	return StzStringQ(pcStr).LastChar()

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
	cReversed = StzStringQ(pcStr).Reversed()
	return FirstLetterOf(cReversed)

	func LastLetterIn(pcStr)
		return LastLetterOf(pcStr)

#--

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

#TODO // add simular functions to all other languages

func NthChar(n, str)
	if CheckParams()
		if NOT ( isNumber(n) and isString(str) )
			StzRaise("Incorrect param type! n must be a number and str must be a string.")
		ok
	ok

	cResult = QStringObjectQ(str).mid(n-1, 1)
	return cResult

	func @NthChar(n, str)
		return NthChar(c)

/*
func StzIsVowel(cCharOrStr) # A more general alternative of Ring isVowel()
	if CheckParams()
		if NOT isString(cCharOrStr)
			StzRaise("Incorrect param type! cCharOrStr must be a string.")
		ok
	ok

	bResult = TRUE

	acChars = StzStringQ(cCharOrStr).Chars()
	nLen = len(acChars)

	for i = 1 to nLen
		if NOT ring_isvowel( acChars[i] )
			bResult = FALSE
			exit
		ok
	next

	return bResult


*/
func StzIsVowel(p) # Can be char, a string or a list of chars or strings
	if CheckParams()
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

	nLen = len(p)
	bResult = TRUE

	for i = 1 to nLen
		if NOT StzIsVowel(p[i])
			bResult = FALSE
			exit
		ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func IsAVowel(p)
		return StzIsVowel(p)

	func @IsVowel(p)
		return StzIsVowel(p)

	func @IsAVowel(p)
		return StzIsVowel(p)

	#--

	func AreVowels(p)
		return StzIsVowel(p)

	func @AreVowels(p)
		return StzIsVowel(p)

	#>

  /////////////////
 ///   CLASS   ///
/////////////////

class stzChar from stzObject
	@oQChar

	def init(pChar)
		if isString(pChar)
			if pChar = ""
				StzRaise("Can't create char from empty string!")
			ok

			oStr = StzStringQ(pChar)

			if oStr.NumberOfChars() = 1
				nUnicode = StzStringQ(pChar).UnicodeOfCharN(1)
				@oQChar = new QChar(nUnicode)

			but oStr.RepresentsNumberInHexForm() or
			    oStr.RepresentsNumberInUnicodeHexForm()
				nUnicode = StzHexNumberQ(pChar).ToDecimal()
				@oQChar = new QChar(nUnicode)

			but oStr.IsCharName()
				nUnicode = StzUnicodeDataQ().CharUnicodeByName(pChar)
				@oQChar = new QChar(nUnicode)

			else
				StzRaise("Can not create char object!")
			ok

		but isNumber(pChar)

			nUnicode = pChar
			@oQChar = new QChar(nUnicode)
		else
			StzRaise(stzCharError(:CanNotCreateCharObjectForThisType))
		ok

	def Content()
		oStr = new QString2()
		oStr.append_2(@oQChar)
		return oStr.ToUtf8().data()

		def Char()
			return This.Content()

	def Number()
		if This.IsCircledNumber()
			switch This.Char()
			on "⓪"	return 0
			on "①"	return 1
			on "②"	return 2
			on "③"	return 3
			on "④"	return 4
			on "⑤"	return 5
			on "⑥"	return 6
			on "⑦"	return 7
			on "⑧"	return 8
			on "⑨"	return 9
			off	
		ok

		def NumericValue()
			return This.Number()

		def Value() #TODO // Generalize it to infere other values then number
			return This.Number()

	def QCharObject()
		return @oQChar

	def IsEmpty()
		return FALSE	# stzChar can never host an empty char

	def Copy()
		oCopy = new stzChar( This.Content() )
		return oCopy

	#---

	def IsAString()
		return TRUE

	#---

	def Update(pChar)
		if isList(pChar) and Q(pChar).IsWithOrByOrUsingNamedParam()
			pChar = pChar[2]
		ok

		if isString(pChar)

			oStzStr = new stzString(pChar)

			nUnicode = oStzStr.UnicodeOfCharN(1)
			@oQChar = new QChar(nUnicode)

		but ring_Type(pChar) = "NUMBER"
			nUnicode = pChar
			@oQChar = new QChar(nUnicode)
		else
			StzRaise("Can't update the char!")
		ok

	#< @FunctionAlternativeForms

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

		#>

	def Updated(pChar)
		return pChar

		#< @FunctionAlternativeForms

		def UpdatedWith(pChar)
			return This.Updated(pChar)

		def UpdatedBy(pChar)
			return This.Updated(pChar)

		def UpdatedUsing(pChar)
			return This.Updated(pChar)

		#>

	#---

	// Returns the unicode code point of the Char in decimal
	def Unicode()
		return @oQChar.unicode()

		def UnicodeAsNumber()
			return This.Unicode()

	def UnicodeAsString()
		return "" + This.Unicode()

	def HexUnicode()
		#NOTE: Based on a proposal from ChatGPT

		nDecUnicode = This.Unicode()
		acHexDigits = "0123456789ABCDEF"
		cResult = ""
	
		for i = 1 to 4
			nDigit = 0+ Q(nDecUnicode % 16).IntegerPart() + 1
			cResult = acHexDigits[nDigit] + cResult
			nDecUnicode = nDecUnicode / 16
	   	next
	
		cResult = "U+" + cResult

		return cResult

	def CanRetrieveName()
		# Read not in Name() function below

		if This.Name() != "@CantRetriveTheName"
			return TRUE
		else
			return FALSE
		ok

	def Name()

		#NOTE
		# Softanza will do its best to get the unciode name of the char
		# by trying to find it in a local copy of the official UnicodeData.txt
		# file. Unfortunaletly, this file does not contrain directly all the names.
		# (a further processing of other files is necessary). But this is not
		# supported now and leaved for future releases.

		# So, when the name is not found, a special name is returned in
		# the string @CantRetriveTheName (so you know what happended).

		# To avoid this in your program and be sure a valid name is returned,
		# use the checker function CanRetriveName()

		cHex = DecimalToHex( This.Unicode() )
		cResult = StzUnicodeDataQ().CharNameByHexCode(cHex)
		return cResult

		#< @FunctionAlternativeForm

		def UnicodeName()
			return This.Name()

		#>	

	def NameIs(pcName)
		if NOT isString(pcName)
			return FALSE
		ok

		cName = This.Name()
		return StzStringQ(pcName).IsEqualToCS( cName, :CS = FALSE )

	def AsciiCode()
		try
			return ascii(This.Content())
		catch
			StzRaise(stzCharError(:CanNotGetAsciiCodeForNonAsciiChar))
		end

	def NumberOfBytes()
		/* #INFO
		Internatlly, stzChar (and thus Qchar) uses UTF-8 encoding of bytes.
		
		UTF 8 encodes Chars on 1, 2, 3 or 4 bytes depending on the Char unicode:
			* from 0 to 127 (ascii Chars) : 1 byte
			* from 128 to 2047 : 2 bytes
			* from 2048 to 65535 : 3 bytes
			* from 65536 to 1114111 : 4 bytes
		
		Look at this: http://tutorials.jenkov.com/unicode/utf-8.html

		#NOTE
		But Ring add a bunch of bytes internally to set and manage the char.
		That's why the len() function does not make the job here. Instead
		we implemented a speciefic function, SizeInBytes(), which is aware
		of those supllementary bytes and adds them to the result.

		*/

		return @SizeInBytes(This.Content())

		#< @FunctionAlternativeForms

		def HowManyBytes()
			return This.NumberOfBytes()

		def HowManyByte()
			return This.NumberOfBytes()

		def SizeInBytes()
			return This.NumberOfBytes()

		def CountBytes()
			return This.NumberOfBytes()

		#>

	def Bytes()
		// TODO: Review it and test it!
		oStzBinStr = new stzListOfBytes(This.Content())
		return oStzBinStr.Bytes()

	def SizeInChars() # Normally, it returns 1. But there will be cases
			  # where our implementation of NumberOfChars() in
			  # stzString is not accurate, due to Unicode complexisty.
			  #TODO // Check them and fix them.

		return This.ToStzString().SizeInChars()

		def NumberOfChars()
			return This.SizeInChars()

	  #-------------------------------------#
	 #   ORIENTATION & UNICODE DIRECTION   #
	#-------------------------------------#

	/*
	Note that we make the difference between text 'orientation', 
	Char orientation, and Char unicode 'direction'.

	The first says if a string is left-to-right or right-to-left oriented, and
	uses the Orientation() method on stzString.

	The second says the same thing for the individual Chars, and uses
	the Orientation method on stzChar.

	While the third  informs us about the technical direction of the Char,
	in terms of UNICODE standard, and is returned using UnicodeDirection() method
	on stzChar.
	*/

	def Orientation()
		oStzStr = new stzString(This.Content())
		return oStzStr.Orientation()
	
	def UnicodeDirection()
		for aLine in UnicodeDirectionsXT()
			if aLine[1] = This.UnicodeDirectionNumber()
				return aLine[3]
			ok
		next

	def UnicodeDirectionNumber()
		cNumber = "" + @oQChar.direction()
		return cNumber

	def IsVowel()
		if ring_find( Vowels(), This.Content() ) > 0
			return TRUE
		else
			return FALSE
		ok

		def IsAVowel()
			return This.IsVowel()

	#TODO //
	# Add IsConsonant()

	def IsLeftToRight()
		if This.UnicodeDirectionNumber() = "0"
			return TRUE
		else
			return FALSE
		ok

	def IsRightToLeft()
		if This.UnicodeDirectionNumber() = "13"
			return TRUE
		else
			return FALSE
		ok

	def IsArabicFraction()
		oList = new stzList(ArabicFractionsUnicodes())
		if oList.Contains(This.Unicode())
			return TRUE
		else
			return FALSE
		ok

	def IsEuropeanDigit()
		return This.IsEuropeanNumber()

	def IsEuropeanNumberSeparator()
		if This.UnicodeDirectionNumber() = "3"
			return TRUE
		else
			return FALSE
		ok

	def IsEuropeanNumberTerminator()
		if This.UnicodeDirectionNumber() = "4"
			return TRUE
		else
			return FALSE
		ok

	def IsIndianDigit()
		/* We don't rely on unicode directions here because they are, in
		   this particular case, incorrect.
		   In fact, what is considered an indian digit (code "5") is actually
		   an arabic number (like 2 for example). */

		for cDigit in IndianDigits()
			if cDigit = This.Content()
				return TRUE
			ok
		end
		return FALSE

	def IsCommonNumberSeparator()
		if This.UnicodeDirectionNumber() = "6"
			return TRUE
		else
			return FALSE
		ok

	def IsParagraphSeparator()
		if This.UnicodeDirectionNumber() = "7"
			return TRUE
		else
			return FALSE
		ok

	def IsSectionSeparator()
		if This.UnicodeDirectionNumber() = "8"
			return TRUE
		else
			return FALSE
		ok

	def IsWhitespace()
		if This.UnicodeDirectionNumber() = "9"
			return TRUE
		else
			return FALSE
		ok

	def IsOrientationNeutral()
		if This.UnicodeDirectionNumber() = "10" or
		   This.IsANumber()
			return TRUE
		else
			return FALSE
		ok

		#< @FunctionAlternativeForm

		def IsNeutral()
			return This.IsOrientationNeutral()

		#>

	// The LeftToRightEmbedding Char sets base direction to left-to-right but
	// allows embedded text to interact with surrounding content
	def IsLeftToRightEmbedding()
		if This.UnicodeDirectionNumber() = "11"
			return TRUE
		else
			return FALSE
		ok

	// Overrides the bidirectional algorithm to display Chars in
	// memory order, progressing from left to right
	def IsLeftToRightOverride()
		if This.UnicodeDirectionNumber() = "12"
			return TRUE
		else
			return FALSE
		ok

	def IsLeftToRightIsolate()
		// TODO

	def IsRightToLeftIsolate()
		// TODO

	def IsRightToLeftArabic()
		if This.UnicodeDirectionNumber() = "13"
			return TRUE
		else
			return FALSE
		ok

	def IsRightToLeftEmbedding()
		if This.UnicodeDirectionNumber() = "14"
			return TRUE
		else
			return FALSE
		ok

	/*
	The Right-to-Left Overrride (RTO) Char is an invisible unicode Char
	inserted in the text when you want the text processing to
	switch to be performed from right to left.

	Look at this explanation here:
	https://redcanary.com/blog/right-to-left-override/
	NB: this link shows also how this can be used as a security attack.
	*/
	def IsRightToLeftOverride()
		if This.UnicodeDirectionNumber() = "15"
			return TRUE
		else
			return FALSE
		ok

	def IsPopDirectionalFormat()
		if This.UnicodeDirectionNumber() = "16"
			return TRUE
		else
			return FALSE
		ok

	def IsNonSpacingMark()
		if This.UnicodeDirectionNumber() = "17"
			return TRUE
		else
			return FALSE
		ok

	def IsBoundaryNeutral()
		if This.UnicodeDirectionNumber() = "18"
			return TRUE
		else
			return FALSE
		ok

	  #----------------------#
	 #   UNICODE CATEGORY   #
	#----------------------#

	def UnicodeCategoryNumber()
		return @oQChar.category()

	def UnicodeCategory()
		n = This.UnicodeCategoryNumber()
		return UnicodeCategoriesXT()[ ""+n ]

		#< @FunctionAlternativeForm

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
		#>

	def IsLetter()
		oTempStr = new stzString( This.UnicodeCategory() )
		if oTempStr.ContainsCS("letter", :CS = FALSE) or This.IsArabicShaddah() 
			return TRUE
		else
			return FALSE
		ok

		def IsALetter()
			return This.IsLetter()

	def IsNotLetter()
		return NOT This.IsLetter()

		def IsNotALetter()
			return This.IsNotLetter()

	def IsLetterOrSpaceOrChar(c)
		if This.IsLetter() or This.IsSpace() or This.Content() = "c"
			return TRUE
		else
			return FALSE
		ok

	def IsTheLetter(c)
		return This.Uppercased() = StzCharQ(c).Uppercased()

	def IsLetterOrNumber()
		if This.IsLetter() or This.IsANumber()
			return TRUE
		else
			return FALSE
		ok

		#< @FunctionAlternativeForm

		def IsNumberOrLetter()
			return This.IsLetterOrNumber()

		#--

		def IsALetterOrNumber()
			return This.IsLetterOrNumber()

		def IsANumberOrLetter()
			return This.IsLetterOrNumber()

		#>
		
	def IsLetterOrSpace()

		if This.IsLetter() or This.IsSpace()
			return TRUE
		else
			return FALSE
		ok

		#< @FunctionAlternativeForm

		def IsSpaceOrLetter()
			return This.IsLetterOrSpace()

		#>

	def IsLetterOrSpaceOrThisChar(pcChar)
		if This.IsLetter() or This.IsSpace() or This.Content() = pcChar
			return TRUE
		else
			return FALSE
		ok

		#< @FunctionAlternativeForm

		def IsSpaceOrLetterOrThisChar(pcChar)
			return This.IsLetterOrSpaceOrThisChar(pcChar)

		#>

	def IsEuropean()
		if This.IsEuropeanNumber() or This.IsEuropeanNumberSeparator() or
		   This.IsEuropeanNumberTerminator()
			return TRUE
		else
			return FALSE
		ok
		
	def IsSpace()
		return @oQChar.isSpace()

	def IsUnicodeNumber()	# Returns TRUE for "㊱". For normal numbers, use IsDecimalDigit().
		if @oQChar.isANumber() or
		This.IsRomanNumber() or
		This.IsMandarinNumber() or
		This.IsIndianNumber()
			return TRUE
		else
			return FALSE
		ok

	def IsNotNumber()
		return NOT This.IsANumber()

	def IsDigit()
		oTempStr = new stzString( This.UnicodeCategory() )
		if oTempStr.Contains("decimaldigit")
			return TRUE
		else
			return FALSE
		ok

		/*
		Example showing the difference between isNumber() and isDigit()
	
		So, for the Char "㊱", we have:
	
		o1 = new stzChar("㊱")
		? o1.IsANumber()	# -> TRUE
		? o1.IsDecimalDigit()	# -> FALSE
	
		While, for the Char "3", we have:
	
		o1 = new stzChar("3")
		? o1.IsANumber()	# -> TRUE
		? o1.IsDeciamlDigit()	# -> TRUE
		*/
	
	def IsArabicNumber()
		/* We don't rely on unicode directions here because they are, in
		   this particular case, incorrect.
		   In fact, what is considered an arabic digit (code "2") is actually
		   an indian number (like ۲ for example). */

		oStzList = new stzList( ArabicDigits() )
		return oStzList.Contains(This.Content())

	def IsANumber()
		return This.IsDigit() or This.IsCircledDigit()

	def IsIndianNumber()
		for c in IndianDigits()
			if c = This.Content()
				return TRUE
			ok
		next
		return FALSE

	def IsRomanNumber()
		if Q(This.Content()).ExistsIn( RomanNumbers() )
			return TRUE
		else
			return FALSE
		ok

	def IsMandarinNumber()
		oList = new stzList( MandarinNumbers() )
		return oList.Contains(This.Content())

	def IsAscii()
		try
			ascii( This.Content() )
			return TRUE

		catch
			return FALSE
		done

	def IsAsciiLetter()
		return This.IsAscii() AND This.IsLetter()

	def IsPunctuation()
		/*
		oTempStr = new stzString( This.UnicodeCategory() )
		if oTempStr.ContainsCS("punctuation", :CaseSensitive = FALSE)
			return TRUE
		else
			return FALSE
		ok

		--> A faster solution hereafter...
		*/

		bResult = This.CharTypeQ().ContainsCS("punctuation", :CaseSensitive = FALSE)
		return bResult

		def IsPunct()
			return This.IsPunctuation()

	def IsGeneralPunctuation()
		bResult = ring_find( GeneralPunctuationUnicodes(), This.Unicode() ) > 0
		return bResult

	def IsSupplementalPunctuation()
		bResult = ring_find( SupplementalPunctuationUnicodes(), This.Unicode() ) > 0
		return bResult

	def IsSymbol()
		oTempStr = new stzString( This.UnicodeCategory() )
		if oTempStr.ContainsCS("symbol", :CaseSensitive = FALSE)
			return TRUE
		else
			return FALSE
		ok

		#TODO // A quicker solution would be possible if we create a global
		# name _anSymbolUnicodes = [ ... ] with the decimal unicode numbers
		# of the Symbols Block in Unicode.

		# And then we use, like in IsPunctuation() function above, the Ring
		# ring_find( SymbolUnicodes(), This.Unicode() ) to get the result.


	def IsNonChar()
		return @oQChar.isNonCharacter()
	
	def IsMark()
		oTempStr = new stzString( This.UnicodeCategory() )
		if oTempStr.ContainsCS("mark", :CaseSensitive = FALSE)
			return TRUE
		else
			return FALSE
		ok

		#TODO // A quicker solution would be possible if we create a global
		# name _anMarkUnicodes = [ ... ] with the decimal unicode numbers
		# of the Symbols Block in Unicode.

		# And then we use, like in IsPunctuation() function above, the Ring
		# ring_find( MarkUnicodes(), This.Unicode() ) to get the result.


	def IsSeparator() # In the UNICODE sense!
		oTempStr = new stzString( This.UnicodeCategory() )
		if oTempStr.ContainsCS("separator", :CaseSensitive = FALSE)
			return TRUE
		else
			return FALSE
		ok

		#TODO // A quicker solution would be possible if we create a global
		# name _anSeparatorUnicodes = [ ... ] with the decimal unicode numbers
		# of the Symbols Block in Unicode.

		# And then we use, like in IsPunctuation() function above, the Ring
		# ring_find( SeparatorUnicodes(), This.Unicode() ) to get the result.


	def IsOneOfThese(paChars)
		/* Could be solved expressively like this:
		
		 return StzStringQ( This.Content() ).IsOneOfThese( paChars )

		But it's not that efficient, regarding execution time.

		So, let's solve it natively in Ring...
		*/
		bResult = FALSE

		for c in paChars
			if c = This.Content()
				bResult = TRUE
				exit
			ok
		next

		return bResult

	def IsWordSeparator()
		return This.IsOneOfThese( WordSeparators() )

	def IsSentenceSeparator()
		return This.IsOneOfThese( SentenceSeparators() )

	def IsLineSeparator()
		return This.Content() = NL

	def IsMirrored() // Like "{", "}", "[", "]", etc.
		// TODO: implement it by analyzing the output of This.Caregory()
		return oQChar.mirroredChar()

	def UnicodeOfMirrored()
		return @oQChar.mirroredChar().unicode()

	def Mirrored()
		nUnicode = @oQChar.mirroredChar().unicode()
		cChar = CharFromUnicode(nUnicode)
		return cChar
	
	def IsLatin()
		oList = new stzList(_anLatinUnicodes)
		return oList.Contains(This.Unicode())

	def IsLatinLetter()
		return This.IsLetter() AND This.IsLatin()
	
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

	def IsArabic()
		oList = new stzList(_anArabicUnicodes)
		return oList.Contains(This.Unicode())
	
	def IsArabicLetter()
		return This.IsLetter() AND This.IsArabic()

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
		/*
		Warining: the UNICODE standard could add other extension blocks to Arabic
		in the future (Only 'A' block is available for Unicode 1.1).
		In sutch case, you need to manage this in the scope of this method.
		*/
	
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

	  #--------------------------------------------#
	 #   NON LETTER CHARS WE CAN FIND IN A WORD   #
	#--------------------------------------------#

	# Verifies if the char is among those that we can find in a word
	# like '_" and '_' for example
	def IsWordNonLetterChar()
		return StzStringQ( This.Content() ).ExistsIn( WordNonLetterChars() )

	  #---------------------#
	 #   UNICODE VERSION   #
	#---------------------#

	def IntroducedInUnicodeVersion()
		n = QCharObject().unicodeversion()

		if n > 0 and n <= len(_acUnicodeVersions)
			return _acUnicodeVersions[ n ]
		else
			StzRaise(stzCharError(:CanNotDefineUnicodeVersion))
		ok

	def UnicodeVersion()
		return This.IntroducedInUnicodeVersion()

	  #---------------#
	 #   CHAR CASE   #
	#---------------#

	def IsLower()
		return @oQChar.isLower()

		def IsLowercase()
			return This.IsLower()

		def IsALowercase()
			return This.IsLower()

	def lowercase()
		oTempChar = new stzChar(@oQChar.toLower().unicode())
		return oTempChar.Content()

		def Lowercased()
			return This.Lowercase()

	def IsUPPERcase()
		return @oQChar.isUpper()

		def IsAnUppercase()
			return @oQChar.isUpper()

	def UPPERcase()
		oTempChar = new stzChar(@oQChar.toUPPER().unicode())
		cUppercased = oTempChar.Content()
		This.Update(cUppercased)

		def Uppercased()
			return This.Uppercase()

	# Returns the case of the char (Uppercase or Lowercase)
	def CharCase()
		if This.IsLowercase()
			return :Lowercase
		but This.IsUppercase()
			return :Uppercase
		ok
	
	  #------------------#
	 #   CIRCLED CHAR   #
	#------------------#
		
	def IsCircled()
		oTempList = new stzList(CircledCharUnicodes())
		return oTempList.contains(This.Unicode())

		#< @FunctionAlternativeForm

		def IsCircledChar()
			return This.IsCircledChar()

		#>

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

	  #----------------------#
	 #   LOCALE SEPARATOR   #
	#----------------------#

	def IsLocaleSeparator()
		if This.Content() = "-" or This.Content() = "_"
			return TRUE
		else
			return FALSE
		ok

	  #--------------------------------#
	 #   VISIBLE AND INVISIBLE CHAR   #
	#--------------------------------#

	def IsInvisible()
		return StzListQ( InvisibleUnicodes() ).Contains( This.Unicode() )

	def IsVisible()
		return NOT This.IsInvisible()

	  #------------------------------------#
	 #   PRINTABLE AND NONPRINTABLE CHAR  #
	#------------------------------------#

	def IsPrintable()
		return @oQChar.isPrint()

	def IsNonPrintable()
		return NOT This.IsPrintable()

	  #-------------#
	 #   LANGUAGE  #
	#-------------#

	def DefaultLanguage()
		cResult = StzScriptQ(This.Script()).DefaultLanguage()
		return cResult

		def Language()
			return This.DefaultLanguage()

		#< @FunctionMisspelledForm

		def Langauge()
			return This.Language()

		#>

	  #-----------#
	 #   SCRIPT  #
	#-----------#

	/*
	From: http://www.unicode.org/reports/tr24/tr24-31.html

	A script is a collection of letters and other written signs that
	generally has the following attributes:
	
	- The written elements share a common graphological style and history.
	- The collection is used (in full, or as a subset) to represent textual
	information in a writing system for one or more languages.

	For example, the Russian language is written with a distinctive set of
	letters, as well as other marks or symbols that together form a subset
	of the Cyrillic script. Other languages using the Cyrillic script, such
	as Ukrainian or Serbian, employ a different subset of those letters.

	The classification by script is essential for a variety of tasks that
	need to analyze a piece of text and determine what parts of it are in
	which script.

	Script information is also taken into consideration in collation, so that
	strings are grouped by script when sorted.

	*/

	def Script()
		nLen = len(_aUnicodeScriptsXT)

		cResult = :Undefined

		for i = 1 to nLen

			if _aUnicodeScriptsXT[i][1] = ""+@oQChar.Script()
				cResult = _aUnicodeScriptsXT[i][2]
				exit
			ok
		next

		return cResult


		def UnicodeScript()
			return Script()
	
	def ScriptCode()
		return @oQChar.Script()

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
		if This.ScriptCode() = 0
			return TRUE
		else
			return FALSE
		ok

	def IsInheritedScript()
		if This.ScriptCode() = 1
			return TRUE
		else
			return FALSE
		ok

	def IsCommonScript()
		if This.ScriptCode() = 2
			return TRUE
		else
			return FALSE
		ok

	def IsLatinScript()
		if This.ScriptCode() = 3
			return TRUE
		else
			return FALSE
		ok

	def IsGreekScript()
		if This.ScriptCode() = 4
			return TRUE
		else
			return FALSE
		ok

	def IsCyrillicScript()
		if This.ScriptCode() = 5
			return TRUE
		else
			return FALSE
		ok

	def IsArmenianScript()
		if This.ScriptCode() = 6
			return TRUE
		else
			return FALSE
		ok

	def IsHebrewScript()
		if This.ScriptCode() = 7
			return TRUE
		else
			return FALSE
		ok

	def IsArabicScript()
		if This.ScriptCode() = 8
			return TRUE
		else
			return FALSE
		ok

	def IsSyriacScript()
		if This.ScriptCode() = 9
			return TRUE
		else
			return FALSE
		ok

	def IsThaanaScript()
		if This.ScriptCode() = 10
			return TRUE
		else
			return FALSE
		ok

	def IsDevanagariScript()
		if This.ScriptCode() = 11
			return TRUE
		else
			return FALSE
		ok

	def IsBengaliScript()
		if This.ScriptCode() = 12
			return TRUE
		else
			return FALSE
		ok

	def IsGurmukhiScript()
		if This.ScriptCode() = 13
			return TRUE
		else
			return FALSE
		ok

	def IsGujaratiScript()
		if This.ScriptCode() = 14
			return TRUE
		else
			return FALSE
		ok

	def IsOriyaScript()
		if This.ScriptCode() = 15
			return TRUE
		else
			return FALSE
		ok

	def IsTamilScript()
		if This.ScriptCode() = 16
			return TRUE
		else
			return FALSE
		ok

	def IsTeluguScript()
		if This.ScriptCode() = 17
			return TRUE
		else
			return FALSE
		ok

	def IsKannadaScript()
		if This.ScriptCode() = 18
			return TRUE
		else
			return FALSE
		ok

	def IsMalayalamScript()
		if This.ScriptCode() = 19
			return TRUE
		else
			return FALSE
		ok

	def IsSinhalaScript()
		if This.ScriptCode() = 20
			return TRUE
		else
			return FALSE
		ok

	def IsThaiScript()
		if This.ScriptCode() = 21
			return TRUE
		else
			return FALSE
		ok

	def IsLaoScript()
		if This.ScriptCode() = 22
			return TRUE
		else
			return FALSE
		ok

	def IsTibetanScript()
		if This.ScriptCode() = 23
			return TRUE
		else
			return FALSE
		ok

	def IsMyanmarScript()
		if This.ScriptCode() = 24
			return TRUE
		else
			return FALSE
		ok

	def IsGeorgianScript()
		if This.ScriptCode() = 25
			return TRUE
		else
			return FALSE
		ok

	def IsHangulScript()
		if This.ScriptCode() = 26
			return TRUE
		else
			return FALSE
		ok

	def IsEthiopicScript()
		if This.ScriptCode() = 27
			return TRUE
		else
			return FALSE
		ok

	def IsCherokeeScript()
		if This.ScriptCode() = 28
			return TRUE
		else
			return FALSE
		ok

	def IsCanadianAboriginalScript()
		if This.ScriptCode() = 29
			return TRUE
		else
			return FALSE
		ok

	def IsOghamScript()
		if This.ScriptCode() = 30
			return TRUE
		else
			return FALSE
		ok

	def IsRunicScript()
		if This.ScriptCode() = 31
			return TRUE
		else
			return FALSE
		ok

	def IsKhmerScript()
		if This.ScriptCode() = 32
			return TRUE
		else
			return FALSE
		ok

	def IsMongolianScript()
		if This.ScriptCode() = 33
			return TRUE
		else
			return FALSE
		ok

	def IsHiraganaScript()
		if This.ScriptCode() = 34
			return TRUE
		else
			return FALSE
		ok

	def IsKatakanaScript()
		if This.ScriptCode() = 35
			return TRUE
		else
			return FALSE
		ok

	def IsBopomofoScript()
		if This.ScriptCode() = 36
			return TRUE
		else
			return FALSE
		ok

	def IsHanScript()
		if This.ScriptCode() = 37
			return TRUE
		else
			return FALSE
		ok

	def IsYiScript()
		if This.ScriptCode() = 38
			return TRUE
		else
			return FALSE
		ok

	def IsOldItalicScript()
		if This.ScriptCode() = 39
			return TRUE
		else
			return FALSE
		ok

	def IsGothicScript()
		if This.ScriptCode() = 40
			return TRUE
		else
			return FALSE
		ok

	def IsDeseretScript()
		if This.ScriptCode() = 41
			return TRUE
		else
			return FALSE
		ok

	def IsTagalogScript()
		if This.ScriptCode() = 42
			return TRUE
		else
			return FALSE
		ok

	def IsHanunooScript()
		if This.ScriptCode() = 43
			return TRUE
		else
			return FALSE
		ok

	def IsBuhidScript()
		if This.ScriptCode() = 44
			return TRUE
		else
			return FALSE
		ok

	def IsTagbanwaScript()
		if This.ScriptCode() = 45
			return TRUE
		else
			return FALSE
		ok

	def IsCopticScript()
		if This.ScriptCode() = 46
			return TRUE
		else
			return FALSE
		ok

	def IsLimbuScript()
		if This.ScriptCode() = 47
			return TRUE
		else
			return FALSE
		ok

	def IsTaiLeScript()
		if This.ScriptCode() = 48
			return TRUE
		else
			return FALSE
		ok

	def IsLinearBScript()
		if This.ScriptCode() = 49
			return TRUE
		else
			return FALSE
		ok

	def IsUgariticScript()
		if This.ScriptCode() = 50
			return TRUE
		else
			return FALSE
		ok

	def IsShavianScript()
		if This.ScriptCode() = 51
			return TRUE
		else
			return FALSE
		ok

	def IsOsmanyaScript()
		if This.ScriptCode() = 52
			return TRUE
		else
			return FALSE
		ok

	def IsCypriotScript()
		if This.ScriptCode() = 53
			return TRUE
		else
			return FALSE
		ok

	def IsBrailleScript()
		if This.ScriptCode() = 54
			return TRUE
		else
			return FALSE
		ok

	def IsBugineseScript()
		if This.ScriptCode() = 55
			return TRUE
		else
			return FALSE
		ok

	def IsNewTaiLueScript()
		if This.ScriptCode() = 56
			return TRUE
		else
			return FALSE
		ok

	def IsGlagoliticScript()
		if This.ScriptCode() = 57
			return TRUE
		else
			return FALSE
		ok

	def IsTifinaghScript()
		if This.ScriptCode() = 58
			return TRUE
		else
			return FALSE
		ok

	def IsSylotiNagriScript()
		if This.ScriptCode() = 59
			return TRUE
		else
			return FALSE
		ok

	def IsOldPersianScript()
		if This.ScriptCode() = 60
			return TRUE
		else
			return FALSE
		ok

	def IsKharoshthiScript()
		if This.ScriptCode() = 61
			return TRUE
		else
			return FALSE
		ok

	def IsBalineseScript()
		if This.ScriptCode() = 62
			return TRUE
		else
			return FALSE
		ok

	def IsCuneiformScript()
		if This.ScriptCode() = 63
			return TRUE
		else
			return FALSE
		ok

	def IsPhoenicianScript()
		if This.ScriptCode() = 64
			return TRUE
		else
			return FALSE
		ok

	def IsPhagsPaScript()
		if This.ScriptCode() = 65
			return TRUE
		else
			return FALSE
		ok

	def IsNkoScript()
		if This.ScriptCode() = 66
			return TRUE
		else
			return FALSE
		ok

	def IsSundaneseScript()
		if This.ScriptCode() = 67
			return TRUE
		else
			return FALSE
		ok

	def IsLepchaScript()
		if This.ScriptCode() = 68
			return TRUE
		else
			return FALSE
		ok

	def IsOlChikiScript()
		if This.ScriptCode() = 69
			return TRUE
		else
			return FALSE
		ok

	def IsVaiScript()
		if This.ScriptCode() = 70
			return TRUE
		else
			return FALSE
		ok

	def IsSaurashtraScript()
		if This.ScriptCode() = 71
			return TRUE
		else
			return FALSE
		ok

	def IsKayahLiScript()
		if This.ScriptCode() = 72
			return TRUE
		else
			return FALSE
		ok

	def IsRejangScript()
		if This.ScriptCode() = 73
			return TRUE
		else
			return FALSE
		ok

	def IsLycianScript()
		if This.ScriptCode() = 74
			return TRUE
		else
			return FALSE
		ok

	def IsCarianScript()
		if This.ScriptCode() = 75
			return TRUE
		else
			return FALSE
		ok

	def IsLydianScript()
		if This.ScriptCode() = 76
			return TRUE
		else
			return FALSE
		ok

	def IsChamScript()
		if This.ScriptCode() = 77
			return TRUE
		else
			return FALSE
		ok

	def TaiThamScript()
		if This.ScriptCode() = 78
			return TRUE
		else
			return FALSE
		ok

	def IsTaiVietScript()
		if This.ScriptCode() = 79
			return TRUE
		else
			return FALSE
		ok

	def IsAvestanScript()
		if This.ScriptCode() = 80
			return TRUE
		else
			return FALSE
		ok

	def IsEgyptianHieroglyphsScript()
		if This.ScriptCode() = 81
			return TRUE
		else
			return FALSE
		ok

	def IsSamaritanScript()
		if This.ScriptCode() = 82
			return TRUE
		else
			return FALSE
		ok

	def IsLisuScript()
		if This.ScriptCode() = 83
			return TRUE
		else
			return FALSE
		ok

	def IsBamumScript()
		if This.ScriptCode() = 84
			return TRUE
		else
			return FALSE
		ok

	def IsJavaneseScript()
		if This.ScriptCode() = 85
			return TRUE
		else
			return FALSE
		ok

	def IsMeeteiMayekScript()
		if This.ScriptCode() = 86
			return TRUE
		else
			return FALSE
		ok

	def IsImperialAramaicScript()
		if This.ScriptCode() = 87
			return TRUE
		else
			return FALSE
		ok

	def IsOldSouthArabianScript()
		if This.ScriptCode() = 88
			return TRUE
		else
			return FALSE
		ok

	def IsInscriptionalParthianScript()
		if This.ScriptCode() = 89
			return TRUE
		else
			return FALSE
		ok
	def IsInscriptionalPahlaviScript()
		if This.ScriptCode() = 90
			return TRUE
		else
			return FALSE
		ok

	def IsOldTurkicScript()
		if This.ScriptCode() = 91
			return TRUE
		else
			return FALSE
		ok

	def IsKaithiScript()
		if This.ScriptCode() = 92
			return TRUE
		else
			return FALSE
		ok

	def IsBatakScript()
		if This.ScriptCode() = 93
			return TRUE
		else
			return FALSE
		ok

	def IsBrahmiScript()
		if This.ScriptCode() = 94
			return TRUE
		else
			return FALSE
		ok

	def IsMandaicScript()
		if This.ScriptCode() = 95
			return TRUE
		else
			return FALSE
		ok

	def IsChakmaScript()
		if This.ScriptCode() = 96
			return TRUE
		else
			return FALSE
		ok

	def IsMeroiticCursiveScript()
		if This.ScriptCode() = 97
			return TRUE
		else
			return FALSE
		ok

	def IsMeroiticHieroglyphsScript()
		if This.ScriptCode() = 98
			return TRUE
		else
			return FALSE
		ok

	def IsMiaoScript()
		if This.ScriptCode() = 99
			return TRUE
		else
			return FALSE
		ok

	def IsSharadaScript()
		if This.ScriptCode() = 100
			return TRUE
		else
			return FALSE
		ok

	def IsSoraSompengScript()
		if This.ScriptCode() = 101
			return TRUE
		else
			return FALSE
		ok

	def IsTakriScript()
		if This.ScriptCode() = 102
			return TRUE
		else
			return FALSE
		ok

	def IsCaucasianAlbanianScript()
		if This.ScriptCode() = 103
			return TRUE
		else
			return FALSE
		ok

	def IsBassaVahScript()
		if This.ScriptCode() = 104
			return TRUE
		else
			return FALSE
		ok

	def IsDuployanScript()
		if This.ScriptCode() = 105
			return TRUE
		else
			return FALSE
		ok

	def IsElbasanScript()
		if This.ScriptCode() = 106
			return TRUE
		else
			return FALSE
		ok

	def IsGranthaScript()
		if This.ScriptCode() = 107
			return TRUE
		else
			return FALSE
		ok

	def IsPahawhHmongScript()
		if This.ScriptCode() = 108
			return TRUE
		else
			return FALSE
		ok

	def IsKhojkiScript()
		if This.ScriptCode() = 109
			return TRUE
		else
			return FALSE
		ok

	def IsLinearAScript()
		if This.ScriptCode() = 110
			return TRUE
		else
			return FALSE
		ok

	def IsMahajaniScript()
		if This.ScriptCode() = 111
			return TRUE
		else
			return FALSE
		ok

	def IsManichaeanScript()
		if This.ScriptCode() = 112
			return TRUE
		else
			return FALSE
		ok

	def IsMendeKikakuiScript()
		if This.ScriptCode() = 113
			return TRUE
		else
			return FALSE
		ok

	def IsModiScript()
		if This.ScriptCode() = 114
			return TRUE
		else
			return FALSE
		ok

	def IsMroScript()
		if This.ScriptCode() = 115
			return TRUE
		else
			return FALSE
		ok

	def IsOldNorthArabianScript()
		if This.ScriptCode() = 116
			return TRUE
		else
			return FALSE
		ok

	def IsNabataeanScript()
		if This.ScriptCode() = 117
			return TRUE
		else
			return FALSE
		ok

	def IsPalmyreneScript()
		if This.ScriptCode() = 118
			return TRUE
		else
			return FALSE
		ok

	def IsPauCinHauScript()
		if This.ScriptCode() = 119
			return TRUE
		else
			return FALSE
		ok

	def IsOldPermicScript()
		if This.ScriptCode() = 120
			return TRUE
		else
			return FALSE
		ok

	def IsPsalterPahlaviScript()
		if This.ScriptCode() = 121
			return TRUE
		else
			return FALSE
		ok

	def IsSiddhamScript()
		if This.ScriptCode() = 122
			return TRUE
		else
			return FALSE
		ok

	def IsKhudawadiScript()
		if This.ScriptCode() = 123
			return TRUE
		else
			return FALSE
		ok

	def IsTirhutaScript()
		if This.ScriptCode() = 124
			return TRUE
		else
			return FALSE
		ok

	def IsWarangCitiScript()
		if This.ScriptCode() = 125
			return TRUE
		else
			return FALSE
		ok

	def IsAhomScript()
		if This.ScriptCode() = 126
			return TRUE
		else
			return FALSE
		ok

	def IsAnatolianHieroglyphsScript()
		if This.ScriptCode() = 127
			return TRUE
		else
			return FALSE
		ok

	def IsHatranScript()
		if This.ScriptCode() = 128
			return TRUE
		else
			return FALSE
		ok

	def IsMultaniScript()
		if This.ScriptCode() = 129
			return TRUE
		else
			return FALSE
		ok

	def IsOldHungarianScript()
		if This.ScriptCode() = 130
			return TRUE
		else
			return FALSE
		ok

	def IsSignWritingScript()
		if This.ScriptCode() = 131
			return TRUE
		else
			return FALSE
		ok

	def IsAdlamScript()
		if This.ScriptCode() = 132
			return TRUE
		else
			return FALSE
		ok

	def IsBhaiksukiScript()
		if This.ScriptCode() = 133
			return TRUE
		else
			return FALSE
		ok

	def IsMarchenScript()
		if This.ScriptCode() = 134
			return TRUE
		else
			return FALSE
		ok

	def IsNewaScript()
		if This.ScriptCode() = 135
			return TRUE
		else
			return FALSE
		ok

	def IsOsageScript()
		if This.ScriptCode() = 136
			return TRUE
		else
			return FALSE
		ok

	def IsTangutScript()
		if This.ScriptCode() = 137
			return TRUE
		else
			return FALSE
		ok

	def IsMasaramGondiScript()
		if This.ScriptCode() = 138
			return TRUE
		else
			return FALSE
		ok

	def IsNushuScript()
		if This.ScriptCode() = 139
			return TRUE
		else
			return FALSE
		ok

	def IsSoyomboScript()
		if This.ScriptCode() = 140
			return TRUE
		else
			return FALSE
		ok

	def IsZanabazarSquareScript()
		if This.ScriptCode() = 141
			return TRUE
		else
			return FALSE
		ok

	def IsDograScript()
		if This.ScriptCode() = 142
			return TRUE
		else
			return FALSE
		ok

	def IsGunjalaGondiScript()
		if This.ScriptCode() = 143
			return TRUE
		else
			return FALSE
		ok

	def IsHanifiRohingyaScript()
		if This.ScriptCode() = 144
			return TRUE
		else
			return FALSE
		ok

	def IsMakasarScript()
		if This.ScriptCode() = 145
			return TRUE
		else
			return FALSE
		ok

	def IsMedefaidrinScript()
		if This.ScriptCode() = 146
			return TRUE
		else
			return FALSE
		ok

	def IsOldSogdianScript()
		if This.ScriptCode() = 147
			return TRUE
		else
			return FALSE
		ok

	def IsSogdianScript()
		if This.ScriptCode() = 148
			return TRUE
		else
			return FALSE
		ok

	def IsElymaicScript()
		if This.ScriptCode() = 149
			return TRUE
		else
			return FALSE
		ok

	def IsNandinagariScript()
		if This.ScriptCode() = 150
			return TRUE
		else
			return FALSE
		ok

	def IsNyiakengPuachueHmongScript()
		if This.ScriptCode() = 151
			return TRUE
		else
			return FALSE
		ok

	def IsWanchoScript()
		if This.ScriptCode() = 152
			return TRUE
		else
			return FALSE
		ok

	def IsChorasmianScript()
		if This.ScriptCode() = 153
			return TRUE
		else
			return FALSE
		ok

	def IsDivesAkuruScript()
		if This.ScriptCode() = 154
			return TRUE
		else
			return FALSE
		ok

	def IsKhitanSmallScriptScript()
		if This.ScriptCode() = 155
			return TRUE
		else
			return FALSE
		ok

	def IsYezidiScript()
		if This.ScriptCode() = 156
			return TRUE
		else
			return FALSE
		ok

	def IsTurnedChar()
		if ring_find(TurnedChars(), This.Content()) > 0
			return TRUE
		else
			return FALSE
		ok

	def IsArabicShaddah()
		if This.Unicode() = 1617
			return TRUE
		else
			return FALSE
		ok

	def IsArabic7arakah()
		return This.IsArabicDiacritic()

	def IsNotArabic7arakah()
		return NOT This.IsArabic7arakah()

	  #-------------------------#
	 #   REMOVING DIACRITICS   #
	#-------------------------#

	def IsLatinDiacritic()
		return StzListQ( LatinDiacriticsUnicodes() ).Contains( This.Unicode() )

	def IsArabicDiacritic()
		return StzListQ( ArabicDiacriticsUnicodes() ).Contains( This.Unicode() )

	def IsDiacritic()
		return StzListQ( DiacriticsUnicodes() ).Contains( This.Unicode() )

	def IsDiacricised()
		return StzListQ( DiacricizedUnicodes() ).Contains( This.Unicode() )

	def RemoveLatinDiacritic()

		cResult = This.Content()

		if This.IsLatinDiacritic()
			for aItem in LatinDiacriticsXT()
				if aItem[1] = This.Content()
					cResult = aItem[2]
					exit
				ok
			next
		ok

		This.Update( cResult )

		def RemoveLatinDiacriticQ()
			This.RemoveLatinDiacritic()
			return This

	def LatinDiacriticRemoved()
		cResult = This.Copy().RemoveLatinDiacriticQ().Content()
		return cResult

	def RemoveDiacritic()
		This.RemoveLatinDiacritic()

		#< @FunctionFluentForm

		def RemoveDiacriticQ()
			This.RemoveDiacritic()
			return This

		#>

	def DiacriticRemoved()
		cResult = This.Copy().RemoveDiacriticQ().Content()
		return cResult

	  #======================================#
	 #   CHECKING IF THE CHAR IS TURNABLE   #
	#======================================#	

	/* WARNING:

	   In Unciode sense, turning a char may be different then inverting it..
	   Both my be different then reversing, reverting, or rotating it!
	   --> Read this discussion:
	       https://unicode.org/faq/casemap_charprop.html#16

	   Hence, there is a high risk of naming confustion in using those terms!
	   #TODO // Reflect on this problem and fix it accordingly!

	  NOTE: For the mean time, Softanza considers them the same!
		In fact, the _aTurnableCharsXT in stzCharData file hosts the
		same data as _aInvertibleCharsXT... But this should be revised
		in the future for better accuracy.
	*/

	def IsInvertible()
		return StzListQ( InvertibleUnicodes() ).Contains( This.Unicode() )

		def IsTurnable()
			return IsInvertible()
		#TODO // We suppose that turning is same as inverting but this could
		# change in the future to cope with their exact meaning in Unicode!

	  #----------------------#
	 #  INVERTING THE CHAR  #
	#----------------------#

	def Invert()

		cChar = This.Char()
		oPairs = new stzListOfPairs( InvertibleCharsXT() )

		#--

		anPos = oPairs.FindInFirstItems(cChar)
		if len(anPos) > 0
			n = anPos[1]
			if n > 0
				This.UpdateWith( oPairs.SecondItems()[n] )
				return
			ok
		ok

		#--

		anPos = oPairs.FindInSecondItems(cChar)
		if len(anPos)
			n = anPos[1]
			if n > 0
				This.UpdateWith( oPairs.FirstItems()[n] )
			ok
		ok

		#< @FunctionFluentForm

		def InvertQ()
			This.Invert()
			return This

		#>

		#< @FunctionAlternativeForms

		def Inverse()
			This.Invert()

			def InverseQ()
				This.Inverse()
				return This

		def Reverse()
			This.Invert()

			def ReverseQ()
				This.Reverse()
				return This

		def Revert()
			This.Invert()

			def RevertQ()
				This.Revert()
				return This

		def Turn()
			This.Invert()

			def TurnQ()
				This.Revert()
				return This

		#>

	def Inverted()
		cResult = This.Copy().InvertQ().Content()
		return cResult

		#< @FunctionAlternativeForms

		def Inversed()
			return This.Inverted()

		def Reversed()
			return This.Inverted()

		def Reverted()
			return This.Inverted()

		def Turned()
			return This.Inverted()

		#>

	  #------------------------------------#
	 #  CHECKING IF THE CHAR IS REVERTED  #
	#------------------------------------#

	def IsInverted()
		cChar = This.Content()
		n = ring_find(InvertedChars(), cChar)

		if n > 0
			return TRUE
		else
			return FALSE
		ok

		#< @FunctionAlternativeForms

		def IsInversed()
			return This.IsInverted()

		def IsReversed()
			return This.IsInverted()

		def IsReverted()
			return This.IsInverted()

		def IsTurned()
			return This.IsInverted()

		#>

	  #====================#
	 #   NATURAL-CODING   #
	#====================#

	def IsChar()
		return TRUE

	def IsCharOf(pcString)
		return StzStringQ(pcString).Contains(This.Content())

	def IsLetterOf(pcString)
		return This.IsLetter() and This.IsCharOf(pcString)

	  #-----------#
	 #   MISC.   #
	#-----------#

	def UpTo(pcOtherChar)
		return StzStringQ(This.Content()).UpTo(pcOtherChar)

	def DownTo(pcOtherChar)
		return StzStringQ(This.Content()).DownTo(pcOtherChar)

	def IsStzChar()
		return TRUE

	def stzType()
		return :stzChar

	def Show()
		? This.Content()

		#< @FuntionMisspelledForm

		def Shwo()
			This.Show()

		#>

	def Methods()
		return ring_methods(This)

	def Attributes()
		return ring_attributes(This)

	def ClassName()
		return "stzchar"

		def StzCharClassName()
			return This.ClassName()

		def StzCharClass()
			return This.ClassName()

	  #---------------------------#
	 #  CASTING THE CHAR OBJECT  #
	#---------------------------#
 
	def ToStzListOfBytes()
		oResult = new stzListOfBytes(This.Content())
		return oResult


	def ToStzString()
		oResult = new stzString(This.Content())
		return oResult

	  #-----------------------------#
	 #  WORKING WITH THE HEX FORM  #
	#=============================#

	def ToHex()

		cResult = HexPrefix() + str2hex( This.Content() )
		return cResult

		def ToHexQ()
			return new stzString( This.ToHex() )

	def ToHexWithoutPrefix()
		cResult = str2hex( This.Content() )
		return cResult

		def ToHexWithoutPrefixQ()
			return new stzString( This.ToHexWithoutPrefix() )

	def FromHex(cHex)
		oQString = new QString2()
		oQString.append(hex2str(cHex))
		This.Update(oQString.data())

		def FromHexQ(cHex)
			This.FromHex(cHex)
			return This

	def Hexcodes()
		acResult = This.ToStzListOfBytes().HexCodes()
		return acResult

	def HexPerByte()
		aResult = This.ToStzListOfBytes().HexPerByte()

		def HexcodePerByte()
			return This.HexPerByte()

	def HexcodesWithoutPrefix()
		acResult = This.ToStzListOfBytes().HexCodesWithoutPrefix()
		return acResult

	def HexPerByteWithoutPrefix()
		aResult = This.ToStzListOfBytes().HexPerByteWithoutPrefix()

	def ToHexSeparated(pcSep)
		cResult = This.ToStzListOfBytes().ToHexSeparated(pcSep)

		#< @FunctionAlternativeForm

		def ToHexSeparatedBy(pcSep)
			if CheckParams()
				if NOT isString(pcSep)
					StzRaise("Incorrect param type! pcSep must be a string.")
				ok
			ok

			return This.ToHexSeparated(pcSep)

		def ToHexSeparatedWith(pcSep)
			if CheckParams()
				if NOT isString(pcSep)
					StzRaise("Incorrect param type! pcSep must be a string.")
				ok
			ok

			return This.ToHexSeparated(pcSep)

		def ToHexSeparatedUsing(pcSep)
			if CheckParams()
				if NOT isString(pcSep)
					StzRaise("Incorrect param type! pcSep must be a string.")
				ok
			ok

			return This.ToHexSeparated(pcSep)

		#>

	def ToHexSpacified()
		return This.ToHexSeparatedBy(" ")

	#--

	def ToHexWithoutPrefixSeparated(pcSep)
		cResult = This.ToStzListOfBytes().ToHexWithoutPrefixSeparated(pcSep)

		#< @FunctionAlternativeForm

		def ToHexWithoutPrefixSeparatedBy(pcSep)
			if CheckParams()
				if NOT isString(pcSep)
					StzRaise("Incorrect param type! pcSep must be a string.")
				ok
			ok

			return This.ToHexWithoutPrefixSeparated(pcSep)

		def ToHexWithoutPrefixSeparatedWith(pcSep)
			if CheckParams()
				if NOT isString(pcSep)
					StzRaise("Incorrect param type! pcSep must be a string.")
				ok
			ok

			return This.ToHexWithoutPrefixSeparated(pcSep)

		def ToHexWithoutPrefixSeparatedUsing(pcSep)
			if CheckParams()
				if NOT isString(pcSep)
					StzRaise("Incorrect param type! pcSep must be a string.")
				ok
			ok

			return This.ToHexWithoutPrefixSeparated(pcSep)

		#>

	def ToHexWithoutPrefixSpacified()
		return This.ToHexWithoutPrefixSeparatedBy(" ")

	def ToHexUTF8()
		cResult = This.ToStzListOfBytes().ToHexUTF8()
		return cResult
