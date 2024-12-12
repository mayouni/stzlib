/*
Hex numbers are used mainly because they form a more
compact form to represent numbers compared to binary.

They are base16 numbers -> formed of 16 bits -> the digits
0 to 9 and the letter A to F.
*/


_cHexNumberPrefix = "0x"
_acHexPrefixes = [ "x", "0x", "U+" ]

func StzHexNumberQ(cHex)
	return new stzHexNumber(cHex)

func HexToDecimalForm(cHex)
	return StzHexNumberQ(cHex).ToDecimalForm()

	func HexToDecimal(cHex)
		return HexToDecimalForm(cHex)

	func HexToUnicode(cHex)
		return HexToDecimalForm(cHex)

func UnicodeHexToDecimalForm(cUnicodeHex)
	if IsUnicodeHex(cUnicodeHex)
		cHex = StzStringQ(cUnicodeHex).RemoveFirstNCharsQ(2).Content()
		cHex = HexPrefix() + cHex
		return HexToDecimal(cHex).ToDecimalForm()
	ok

	#< @FunctionAlternativeForm

	func UnicodeHexToDecimal(cUnicodeHex)
		return UnicodeHexToDecimalForm(cUnicodeHex)

	#>

func IsHexNumber(cNumber)
	return StringRepresentsNumberInHexform(cNumber)

	func @IsHexNumber(cNumber)
		return IsHexNumber(cNumber)

	func IsAHexNumber(cNumber)
		return IsHexNumber(cNumber)

	func @IsAHexNumber(cNumber)
		return IsHexNumber(cNumber)

func IsUnicodeHexNumber(cNumber)
	return StzStringQ(cNumber).RepresentsNumberInUnicodeHexForm()

	#< @FunctionAlternativeForm

	func IsUnicodeHex(cNumber)
		return IsUnicodeHexNumber(cNumber)

	func @IsUnicodeHexNumber(cNumber)
		return IsUnicodeHexNumber(cNumber)

	func @IsUnicodeHex(cNumber)
		return IsUnicodeHexNumber(cNumber)

	#--

	func IsAUnicodeHexNumber(cNumber)
		return IsUnicodeHexNumber(cNumber)

	func IsAUnicodeHex(cNumber)
		return IsUnicodeHexNumber(cNumber)

	func @IsAUnicodeHexNumber(cNumber)
		return IsUnicodeHexNumber(cNumber)

	func @IsAUnicodeHex(cNumber)
		return IsUnicodeHexNumber(cNumber)

	#>

func HexNumberPrefix()
	return _cHexNumberPrefix

	#< @FunctionAlternativeForm

	func HexPrefix()
		return HexNumberPrefix()

	#>

func HexPrefixes()
	return _acHexPrefixes

	def HexNumberPrefixes()
		return HexPrefixes()

func SetHexPrefix(pcPrefix)
	if find(HexPrefixes(), pcPrefix) > 0
		_cHexNumberPrefix = pcPrefix
	else
		StzRaise("Unsupported hex prefix!")
	ok

class stzHexNumber from stzObject
	@cHexNumber
	# Stored Without prefix! Prefixes are used only when exporting the
	# request using WithPrefix()

	def init(cNumber)

		if not isString(cNumber)
			stzRaise("Incorrect param type! cNumber must be a string.")
		ok

		if cNumber = ""
			@cHexNumber = ""

		but StzStringQ(cNumber).RepresentsNumberInHexForm()

			oHexNumber = StzStringQ(cNumber)
			acHexPrefix = HexPrefixes()
			nLen = len(acHexPrefix)

			for i = 1 to nLen
				oHexNumber.RemoveFromLeft(acHexPrefix[i])
			next
				
			@cHexNumber = oHexNumber.Content()

		but StringRepresentsNumberInUnicodeHexForm(cNumber)
			@cHexNumber = StzStringQ(cNumber).RemoveCSQ( "U+", :CS _FALSE_ ).Content()

		else
			StzRaise(stzHexNumberError(:CanNotCreateHexNumber))
		ok

	def Content()
		return @cHexNumber

		def Value()
			return Content()

	def WithoutPrefix()
		return This.Content()

	def WithPrefix()
		return HexPrefix() + This.WithoutPrefix()

	def HexNumber()
		return This.WithPrefix()


	def IntegerPart()

		oStzStr = new stzString(This.HexNumber())

		if oStzStr.Contains(".")
			return oStzStr.SplittedUsing(".")[1]
		else
			return oStzStr.Content()
		ok

		def IntPart()
			return This.IntegerPart()

	def IntegerPartWithoutPrefix()
		// #TOTO Refactor the namings so we have:
		#    IntPart() ~> always returning the int part without prefix
		#    IntPartXT() ~> to get it with the hex prefix

		#--> This will avoid the use of WithoutPrefix
		#--> It aligns with Softanza style of using XT() notation

		// #TODO // Generalize this to all number classes

		oStrTemp = new stzString(THis.IntegerPart())
		oStrTemp.RemoveMany(HexPrefixes())

		cResult = oStrTemp.Content()
		return cResult

		def IntPartWithoutPrefix()
			return This.IntegerPartWithoutPrefix()

	def FractionalPart()
		oStzStr = new stzString(This.HexNumberWithoutPrefix())

		if oStzStr.Contains(".")
			return oStzStr.SplittedUsing(".")[2]
		ok

		def FractPart()
			return This. FractionalPart()
	  #------------------#
	 #    CONVERSION    #
	#------------------#

	def ToStzNumber()
		return new stzNumber(This.ToDecimalForm())

	def ToStzString()
		return new stzString(This.HexNumber())

	def ToDecimalForm()
		# Converting the integer part of the hex number to decimal

		cIntegerPart = dec( This.IntegerPartWithoutPrefix() )

		# Converting the fractional part of the hex number to decimal

		cFractionalPart = ""

		// TODO
		
		# Combining them to get the decimal form of the hex number

		cDecimalForm = cIntegerPart
		if cFractionalPart != NULL
			cDecimalForm += "." + cFractionalPart
		ok

		return cDecimalForm

		def ToDecimal()
			return This.ToDecimalForm()

	def ToUnicodeHexForm()
		return "U+" + This.HexNumber()

		def ToUnicodeHex()
			return This.ToUnicodeHexForm()

	def ToBinaryForm()
		return This.ToStzNumber().ToBinaryForm()

		def ToBinary()
			return This.ToBinaryForm()

	def ToBinaryFormWithoutPrefix()
		return This.ToStzNumber().ToBinaryFormWithoutPrefix()

		def ToBinaryWithoutPrefix()
			return This.ToBinaryFormWithoutPrefix()

	def ToOctalForm()
		return This.ToStzNumber().ToOctalForm()

		def ToOctal()
			return This.ToOctalForm()

	def ToOctalFormWithoutPrefix()
		return This.ToStzNumber().ToOctalFormWithoutPrefix()

		def ToOctalWithoutPrefix()
			return This.ToOctalFormWithoutPrefix()

	def IntegerPartToBaseNForm(n)
		# n must be netween 2 to 32
		return This.ToStzNumber().IntegerPartToBaseNForm(n)

		def IntegerPartToBaseN(n)
			return This.IntegerPartToBaseNForm(n)

	def ToScientificForm()
		return This.ToStzNumber().ToScientificForm(n)

		def ToScientific()
			return This.ToScientificForm()

	def ToBytes() #TODO // Should also be turned as stzListOfBytes
		return This.ToStzNumber().ToBytes()

	def FromDecimalForm(n)
		@cHexNumber = StzNumberQ(n).ToHexForm()

		def FromDecimal(n)
			This.FromDecimalForm(n)

	def FromOctalForm(n)
		@cHexNumber = StzOctalNumberQ(n).ToHexForm()

		def FromOctal(n)
			This.FromOctalForm(n)

	def FromBinaryForm(n)
		@cHexNumber = StzBinaryNumberQ(n).ToHexForm()

		def FromBinary(n)
			This.FromBinaryForm(n)

	  #-----------#
	 #   MISC.   #
	#-----------#

	def IsHexNumber() # required by stzChainOfTruth
		return _TRUE_
