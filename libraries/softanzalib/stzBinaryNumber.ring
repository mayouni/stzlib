/*
This class is responsible for managing the binary
representation form of numbers.

Read this about binary arithmetic opeartions:
https://sciencing.com/convert-between-base-number-systems-8442032.html
*/

_acBinaryPrefixes = [ "b", "0b" ]
_cBinaryNumberPrefix = "0b"

func StzBinaryNumberQ(cNumber)
	return new stzBinaryNumber(cNumber)

func BinaryNumberPrefix()
	return _cBinaryNumberPrefix

	#< @FunctionAlternativeForm

	func BinaryPrefix()
		return BinaryNumberPrefix()

	#>

def BinaryPrefixes()
	return _acBinaryPrefixes

def SetBinaryNumberPrefix(pcBinaryPrefix)

	if isString(pcBinaryPrefix) and StzStringQ(pcBinaryPrefix).IsOneOfThese(BinaryPrefixes())
		_cBinaryNumberPrefix = pcBinaryPrefix

	else
		StzRaise("Incorrect hex number prefix!")
	ok

	#< @FunctionAlternativeForm

	def SetBinaryPrefix(pcBinaryPrefix)
		SetBinaryNumberPrefix(pcBinaryPrefix)

	#>

class stzBinaryNumber from stzObject
	@cBinaryNumber = ""	# Holds the binary number without prefix
	
	/*
	The binary number can be created by:
		- passing a binary string of the form "0b10011100001" to the constructor
		  of the stzBinaryNumber class (started with a binary prefix)
	
	Otherwise, a zero binary number can be created ( new stzBinaryNumber("b0") or
	new stzBinaryNumber("") ) and then:
		- FromDecimalForm("12500") method is used to create a binary number
		  from the deciaml number of the form 12500

		- FromHexaForm("x0E22") method is used to create a binary number
		  from the hexadecimal number of the form "x0E22"

		- FromOctalForm("o2077") method is used to create a binary number
		  from the ocatl number of the form "o2077"

		TODO: Add these

		- FromScientificNotationForm()
		- FromBaseNForm()
	*/

 	  #------------#
	 #    INIT    #
	#------------#

	def init(cNumber)
		if isString(cNumber) and StzStringQ(cNumber).RepresentsNumberInBinaryForm()
				@cBinaryNumber = cNumber
					
		else
				StzRaise("Can't create binary number!")
		ok


  	  #------------#
	 #    INFO    #
	#------------#

	def Content()
		return @cBinaryNumber

	def WithPrefix()
		return BinaryPrefix() + This.Content()

	def BinaryNumber()
		return Content()

 	  #-------------------------#
	 #    BITWISE OPERATORS    #
	#-------------------------#

	def operator(pOp, pValue)
		switch pOp
		on "&"
			return This.BitwiseAND(pValue)
		on "|"
			return This.BitwiseOR(pValue)
		on "^"
			return This.BitwiseXOR(pValue)
		on "~"
			return This.BitwiseOnesComplement(pValue)
		on "<<"
			return This.BitwiseLeftShift(pValue)
		on ">>"
			return This.BitwiseRightShift(pValue)
		off

	def BitwiseAND(nOtherNumber)
		return This.ToDecimalForm() & nOtherNumber

	def BitwiseOR(nOtherNumber)
		return This.ToDecimalForm() | nOtherNumber

	def BitwiseXOR(nOtherNumber)
		return This.ToDecimalForm() ^ nOtherNumber

	def BitwiseOnesComplement(nOtherNumber)
		return This.ToDecimalForm() ~ nOtherNumber

	def BitwiseLeftShift(nOtherNumber)
		return This.ToDecimalForm() << nOtherNumber

	def BitwiseRightShift(nOtherNumber)
		return This.ToDecimalForm() >> nOtherNumber

 	  #--------------------------------#
	 #    INTEGER & FRACTION PARTS    #
	#--------------------------------#
		
	def IntegerPart()
		n = StzStringQ(This.BinaryNumber()).FindFirstOccurrence(".")

		if n = 0
			return This.BinaryNumber()

		else
			return oTempStr.Section( 1, n-1 )
		ok

	def FractionalPart()
		cResult = NULL
		oTempStr = new stzString(This.BinaryNumber())
		n = oTempStr.FindFirstOccurrence(".")

		if n > 0
			nLen = oTempStr.NumberOfchars()
			cResult = oTempStr.Section( n+1, nLen )
		ok

		return cResult

	def Reversed()
		cResult = This.IntegerPartReversed()
		if This.HasFractionalPart()
			cResult += "." + This.FractionalPartReversed()
		ok

		return cResult

	def HasFractionalPart()
		If This.FractionalPart() != NULL
			return TRUE
		else
			return FALSE
		ok

	def FractionalPartReversed()
		return StzStringQ(This.FractionalPart()).Reversed()

	def IntegerPartReversed()
		return StzStringQ(This.IntegerPart()).Reversed()
		
	  #------------------#
	 #    CONVERSION    #
	#------------------#

	def ToStzNumber()
		return new stzNumber( This.ToDecimalForm() )

	def ToStzString()
		return new stzString( This.BinaryNumber() )

	def IntegerPartToDecimalForm()
		nCurrentTotal = 0
		for bit in This.BinaryNumber()
			nCurrentTotal = nCurrentTotal * 2 + (0+ bit)
		next

		return ""+ nCurrentTotal

		def IntegerPartToDecimal()
			return This.IntegerPartToDecimalForm()

	def FractionalPartToDecimalForm()
		nCurrentTotal = 0
		
		for bit in This.FractionalPartReversed()
			nCurrentTotal = ( nCurrentTotal + (0+ bit) ) / 2
		next

		return StzStringQ( ""+ nCurrentTotal ).RemoveTrailingRepeatedCharQ('0').Content()

		def FractionalPartToDecimal()
			return This.FractionalPartToDecimalForm()

	def FractionalPartToDecimalFormWithoutZeroDot()
		oFractionalPart = new stzString(This.FractionalPartToDecimalForm())
		return oFractionalPart.Section(3, oFractionalPart.NumberOfChars())

		def FractionalPartToDecimalWithoutZeroDot()
			return This.FractionalPartToDecimalFormWithoutZeroDot()

	def ToDecimalForm()
		if NOT This.HasFractionalPart()
			return This.IntegerPartToDecimalForm()
			
		else
			return This.IntegerPartToDecimalForm() + "." +
			       This.FractionalPartToDecimalFormWithoutZeroDot()

		ok

		def ToDecimal()
			return This.ToDecimalForm()

	def ToOctalForm()
		return This.ToStzNumber().ToOctalForm()

		def ToOctal()
			return This.ToOctalForm()

	def ToHexForm()
		return This.ToStzNumber().ToHexForm()

		def ToHex()
			return This.ToHexForm()

	def ToUnicodeHexForm()
		return This.ToStzNumber().ToUnicodeHexForm()

		def ToUnicodeHex()
			return This.ToUnicodeHexForm()

	def ToScientificNotationForm()
		return This.ToStzNumber().ToScientificNotationForm()

		def ToScientificNotation()
			return This.ToScientificNotationForm()

	def IntegerPartToBaseNForm(n)
		# n must be netween 2 to 32
		return This.ToStzNumber().IntegerPartToBaseNForm(n)

		def IntegerPartToBaseN(n)
			return This.IntegerPartToBaseNForm(n)


	def ToBytes() # TODO: Should also be turned as stzListOfBytes
		return This.ToStzNumber().ToBytes()
	
	  #----------------------------------#
	 #    GETTING BINARY NUMBER FROM    #
	#----------------------------------#

	def FromDecimalForm(n)
		@cBinaryNumber = StzNumberQ(n).ToBinaryForm()

		def FromDecimal(n)
			This.FromDecimalForm(n)

	def FromHexForm(cHex)
		@cBinaryNumber = StzHexNumberQ(cHex).ToBinaryForm()

		def FromHex(cHex)
			This.FromHexForm(cHex)

	def FromOctalForm(cOctal)
		@cBinaryNumber = StzOctalNumberQ(cOctal).ToBinaryForm()

		def FromOctal(cOctal)
			This.FromOctalForm(cOctal)
		
