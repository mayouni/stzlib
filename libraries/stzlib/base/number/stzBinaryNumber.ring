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

	if isString(pcBinaryPrefix) and StzFindFirst(pcBinaryPrefix, BinaryPrefixes()) > 0
		_cBinaryNumberPrefix = pcBinaryPrefix

	else
		StzRaise("Incorrect hex number prefix!")
	ok

	#< @FunctionAlternativeForm

	def SetBinaryPrefix(pcBinaryPrefix)
		SetBinaryNumberPrefix(pcBinaryPrefix)

	#>

# Holds a number written in binary and converts it to decimal, octal and hexadecimal, or builds it from them.
#
# It is the binary form behind stzNumber.ToBinaryForm: a stzNumber builds one with new
# stzBinaryNumber(cText), and you can build one yourself with new stzBinaryNumber("0b1011") or
# StzBinaryNumberQ("0b1011"). The text starts with b or 0b, followed by binary digits and optionally
# a dot and more digits; an empty text gives zero. Content returns the text as given, prefix
# included. ToDecimalForm, ToOctalForm and ToHexForm convert (by hand 0b1011 is 8+2+1 = 11 = 0o13 =
# 0xB), and FromDecimalForm, FromHexForm and FromOctalForm replace the number in place, the last two
# needing the 0x and 0o prefixes. The Bitwise methods work on the decimal value and answer a number.
# Whole numbers convert exactly; the fractional part is exact in decimal and octal but ToHexForm
# drops it. Several methods are broken today and each says so in its own entry: IntegerPart and
# Reversed raise R24 when a dot is present, WithPrefix doubles the prefix, the reversals reverse the
# prefix with the digits, ToScientificNotationForm raises R14, and an uppercase 0B prefix reads as
# 0.
#
#   receiver   o1 = new stzBinaryNumber("0b1011")
#   example    ? o1.ToDecimalForm()
#              #--> 11
#              ? o1.ToOctalForm()
#              #--> 0o13
#              ? o1.ToHexForm()
#              #--> 0xB
#              ? o1.BitwiseAND(6)
#              #--> 2
#              ? o1.BitwiseLeftShift(2)
#              #--> 44
#              o2 = new stzBinaryNumber("0b101.11")
#              ? o2.ToDecimalForm()
#              #--> 5.75
#              o3 = new stzBinaryNumber("")
#              o3.FromDecimalForm(12500)
#              ? o3.Content()
#              #--> 0b11000011010100
#   see        stzNumber, stzHexNumber, stzOctalNumber
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

		- FromHexForm("x0E22") method is used to create a binary number
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

	# Builds a binary number from a text such as 0b1011, or a zero binary number from an empty text.
	#
	#   cNumber    the number as a text starting with b or 0b, followed by binary digits and
	#              optionally a dot and more digits, or an empty text for zero, anything else raises
	#              an error
	#   returns    nothing; the object is built
	#   note       an empty text gives the content b0; it is reached from stzNumber.ToBinaryForm and
	#              from StzBinaryNumberQ(cNumber)
	#   warning    the uppercase prefix 0B is accepted but its value is read as 0: new
	#              stzBinaryNumber("0B101").ToDecimalForm() answers 0 where 5 is right; -0b101 is
	#              accepted and reads as -5, but 0b-101, the text FromDecimalForm(-5) builds, is
	#              refused
	#   see        FromDecimalForm, FromHexForm
	def init(cNumber)
		if NOT isString(cNumber)
			StzRaise("Can't create binary number! cNumber must be a string")
		ok

		if StzStringQ(cNumber).RepresentsNumberInBinaryForm()
			@cBinaryNumber = cNumber

		but cNumber = ""
			@cBinaryNumber = "b0"

		else
			StzRaise("Can't create binary number! cNumber must be an empty string or a string with a number in binary form.")
		ok

  	  #------------#
	 #    INFO    #
	#------------#

	# Returns the binary number as it was written, prefix included.
	#
	#   returns    a text such as 0b1011
	#   note       Value and BinaryNumber are the same call
	#   see        WithPrefix, ToDecimalForm
	def Content()
		return @cBinaryNumber

		def Value()
			return This.Content()

		# Returns the binary number as it was written, prefix included.
		#
		#   returns    a text such as 0b1011
		#   note       the same call as Content
		#   see        Content, WithPrefix
		def BinaryNumber()
			return Content()
	
	# Returns the content with the binary prefix put in front of it.
	#
	#   returns    a text
	#   note       use Content to read the number; the prefix comes from BinaryNumberPrefix(), 0b by
	#              default
	#   warning    the prefix is added even though the content already starts with one: 0b1011
	#              answers 0b0b1011 and b1111 answers 0bb1111
	#   see        Content, BinaryNumber
	def WithPrefix()
		return BinaryPrefix() + This.Content()


 	  #-------------------------#
	 #    BITWISE OPERATORS    #
	#-------------------------#

	# Applies a bitwise operator written as text to the number and a second number.
	#
	#   pOp        the operator as text, one of & (and), a pipe (or), ^ (xor), ~ (complement), << or
	#              >>
	#   pValue     the second operand, ignored by ~
	#   returns    a number, the result of the operation; an empty text for an operator that is not
	#              listed
	#   note       0b1011 with & and 6 gives 2, with << and 1 gives 22
	#   warning    an unknown operator such as + answers an empty text without an error
	#   see        BitwiseAND, BitwiseOR, BitwiseXOR, BitwiseLeftShift
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

	# Returns the bitwise AND of the number and another number.
	#
	#   nOtherNumber   the second operand, a decimal number
	#   returns        a number
	#   note           by hand 1011 and 0110 give 0010: 0b1011 with 6 answers 2
	#   see            BitwiseOR, BitwiseXOR
	def BitwiseAND(nOtherNumber)
		return StzEngineNumberBitwiseAnd(0+ This.ToDecimalForm(), nOtherNumber)

	# Returns the bitwise OR of the number and another number.
	#
	#   nOtherNumber   the second operand, a decimal number
	#   returns        a number
	#   note           by hand 1011 or 0110 give 1111: 0b1011 with 6 answers 15
	#   see            BitwiseAND, BitwiseXOR
	def BitwiseOR(nOtherNumber)
		return StzEngineNumberBitwiseOr(0+ This.ToDecimalForm(), nOtherNumber)

	# Returns the bitwise exclusive OR of the number and another number.
	#
	#   nOtherNumber   the second operand, a decimal number
	#   returns        a number
	#   note           by hand 1011 xor 0110 give 1101: 0b1011 with 6 answers 13
	#   see            BitwiseAND, BitwiseOR
	def BitwiseXOR(nOtherNumber)
		return StzEngineNumberBitwiseXor(0+ This.ToDecimalForm(), nOtherNumber)

	# Returns the bitwise complement of the number, which is minus the number minus one.
	#
	#   nOtherNumber   required by the signature but ignored
	#   returns        a number, negative for a positive number
	#   note           0b1011 (11) answers -12 and 0b110 (6) answers -7, whatever the argument is
	#   see            BitwiseAND, BitwiseLeftShift
	def BitwiseOnesComplement(nOtherNumber)
		return StzEngineNumberBitwiseNot(0+ This.ToDecimalForm())

	# Returns the number shifted left by some bits, which doubles it once per bit.
	#
	#   nOtherNumber   how many bits to shift
	#   returns        a number
	#   note           0b1011 shifted by 2 gives 44, by hand 101100
	#   see            BitwiseRightShift, BitwiseAND
	def BitwiseLeftShift(nOtherNumber)
		return StzEngineNumberBitwiseLShift(0+ This.ToDecimalForm(), nOtherNumber)

	# Returns the number shifted right by some bits, which halves it once per bit, dropping the remainder.
	#
	#   nOtherNumber   how many bits to shift
	#   returns        a number
	#   note           0b1011 shifted by 1 gives 5, by hand 101
	#   see            BitwiseLeftShift, BitwiseAND
	def BitwiseRightShift(nOtherNumber)
		return StzEngineNumberBitwiseRShift(0+ This.ToDecimalForm(), nOtherNumber)

 	  #--------------------------------#
	 #    INTEGER & FRACTION PARTS    #
	#--------------------------------#
		
	# Returns the part of the content before the dot; a number without a dot is returned whole.
	#
	#   returns    a text, with its prefix kept
	#   note       the prefix is part of the answer: 0b1011 gives 0b1011
	#   warning    with a fractional part it raises error R24 (uninitialized variable _oTempStr_)
	#              instead of answering the part before the dot: 0b101.11 and b10.1 both raise
	#   see        FractionalPart, IntegerPartToDecimalForm
	def IntegerPart()
		_n_ = ring_substr1(This.BinaryNumber(), ".")

		if _n_ = 0
			return This.BinaryNumber()

		else
			return _oTempStr_.Section( 1, _n_-1 )
		ok

	# Returns the binary digits after the dot, or an empty text when there is no dot.
	#
	#   returns    a text of digits, without the dot
	#   note       0b101.11 gives 11
	#   see        HasFractionalPart, FractionalPartToDecimalForm
	def FractionalPart()
		_cResult_ = ""
		_oTempStr_ = new stzString(This.BinaryNumber())
		_n_ = _oTempStr_.FindFirstOccurrence(".")

		if _n_ > 0
			_nLen_ = _oTempStr_.NumberOfchars()
			_cResult_ = _oTempStr_.Section( _n_+1, _nLen_ )
		ok

		return _cResult_

	# Returns the number written backwards, integer part and fractional part each reversed, joined by a dot.
	#
	#   returns    a text
	#   note       use IntegerPartReversed on a number without a fraction only to turn the digits,
	#              and ignore the prefix at its end
	#   warning    the prefix is reversed with the digits, so 0b1011 answers 1101b0, which is not a
	#              binary number, and with a fractional part it raises error R24 as IntegerPart does
	#   see        IntegerPartReversed, FractionalPartReversed
	def Reversed()
		_cResult_ = This.IntegerPartReversed()
		if This.HasFractionalPart()
			_cResult_ += "." + This.FractionalPartReversed()
		ok

		return _cResult_

	# TRUE if the number has digits after the dot.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       ContainsFractionalPart is the same call
	#   see        FractionalPart, ToDecimalForm
	def HasFractionalPart()
		If This.FractionalPart() != ""
			return 1
		else
			return 0
		ok

		def ContainsFractionalPart()
			return This.HasFractionalPart()

	# Returns the digits after the dot written backwards.
	#
	#   returns    a text of digits; empty without a dot
	#   note       0b11.01 gives 10
	#   see        FractionalPart, Reversed
	def FractionalPartReversed()
		_cStr_ = This.FractionalPart()
		_cRev_ = ""
		for i = StzLen(_cStr_) to 1 step -1
			_cRev_ += _cStr_[i]
		next
		return _cRev_

	# Returns the integer part written backwards, prefix included.
	#
	#   returns    a text
	#   note       with a fractional part it raises error R24 as IntegerPart does
	#   warning    the prefix is reversed with the digits: 0b1011 answers 1101b0 and b1111 answers
	#              1111b
	#   see        IntegerPart, Reversed
	def IntegerPartReversed()
		_cStr_ = This.IntegerPart()
		_cRev_ = ""
		for i = StzLen(_cStr_) to 1 step -1
			_cRev_ += _cStr_[i]
		next
		return _cRev_
		
	  #------------------#
	 #    CONVERSION    #
	#------------------#

	# Returns the value as a stzNumber, read from its decimal form.
	#
	#   returns    a stzNumber
	#   note       0b1011 gives the number 11
	#   see        ToDecimalForm, ToStzString
	def ToStzNumber()
		return new stzNumber( This.ToDecimalForm() )

	# Returns the binary text, prefix included, as a stzString.
	#
	#   returns    a stzString
	#   see        Content, ToStzNumber
	def ToStzString()
		return new stzString( This.BinaryNumber() )

	# Returns the integer part converted to decimal, as text.
	#
	#   returns    a text of decimal digits
	#   note       by hand 1011 is 8+2+1: 0b1011 gives 11 and 0b101.11 gives 5; IntegerPartToDecimal
	#              is the same call
	#   see        ToDecimalForm, FractionalPartToDecimalForm
	def IntegerPartToDecimalForm()
		_cBinary_ = This.BinaryNumber()

		_nDotPos_ = ring_substr1(_cBinary_, ".")
		if _nDotPos_ > 0
			_cBinary_ = StzLeft(_cBinary_, _nDotPos_-1)
		ok

		_cBinary_ = StzReplace(_cBinary_, "0b", "")
		_cBinary_ = StzReplace(_cBinary_, "b", "")

		return "" + StzEngineNumberFromBase(_cBinary_, 2)

		def IntegerPartToDecimal()
			return This.IntegerPartToDecimalForm()

	# Returns the fractional part converted to decimal, as a text such as 0.75.
	#
	#   returns    a text; 0 when there is no fraction
	#   note       by hand .11 is 1/2+1/4: 0b101.11 gives 0.75 and 0b11.01 gives 0.25;
	#              FractionalPartToDecimal is the same call
	#   see        IntegerPartToDecimalForm, ToDecimalForm
	def FractionalPartToDecimalForm()
		_nCurrentTotal_ = 0
		
		_aThisFractionalPartRevers1_ = This.FractionalPartReversed()
		_nThisFractionalPartRevers1Len_ = len(_aThisFractionalPartRevers1_)
		for _iLoopThisFractionalPartRevers1_ = 1 to _nThisFractionalPartRevers1Len_
			_bit_ = _aThisFractionalPartRevers1_[_iLoopThisFractionalPartRevers1_]
			_nCurrentTotal_ = ( _nCurrentTotal_ + (0+ _bit_) ) / 2
		next

		_cStr_ = "" + _nCurrentTotal_
		while StzLen(_cStr_) > 1 and StzRight(_cStr_, 1) = "0"
			_cStr_ = StzLeft(_cStr_, StzLen(_cStr_) - 1)
		end
		return _cStr_

		def FractionalPartToDecimal()
			return This.FractionalPartToDecimalForm()

	# Returns the decimal digits of the fractional part without the leading 0.
	#
	#   returns    a text of digits such as 75
	#   note       0b101.11 gives 75; FractionalPartToDecimalWithoutZeroDot is the same call
	#   warning    it raises an error (indexes out of range) when the number has no fractional part:
	#              0b1011 and 0b0 both raise
	#   see        FractionalPartToDecimalForm, ToDecimalForm
	def FractionalPartToDecimalFormWithoutZeroDot()
		_oFractionalPart_ = new stzString(This.FractionalPartToDecimalForm())
		return _oFractionalPart_.Section(3, _oFractionalPart_.NumberOfChars())

		def FractionalPartToDecimalWithoutZeroDot()
			return This.FractionalPartToDecimalFormWithoutZeroDot()

	# Returns the number converted to decimal, as text.
	#
	#   returns    a text such as 11 or 5.75
	#   note       by hand 0b101.11 is 5+0.75: it answers 5.75; 0b1111111111111111 answers 65535;
	#              ToDecimal is the same call
	#   see        ToStzNumber, ToHexForm
	def ToDecimalForm()
		if NOT This.HasFractionalPart()
			return This.IntegerPartToDecimalForm()
			
		else
			return This.IntegerPartToDecimalForm() + "." +
			       This.FractionalPartToDecimalFormWithoutZeroDot()

		ok

		def ToDecimal()
			return This.ToDecimalForm()

	# Returns the number in octal, prefixed with 0o.
	#
	#   returns    a text such as 0o13
	#   note       by hand 11 is 1 times 8 plus 3: 0b1011 answers 0o13 and 0b11111111 answers 0o377;
	#              0b101.11 answers 0o5.6; ToOctal is the same call
	#   see        ToHexForm, ToDecimalForm
	def ToOctalForm()
		return This.ToStzNumber().ToOctalForm()

		def ToOctal()
			return This.ToOctalForm()

	# Returns the number in hexadecimal, prefixed with 0x.
	#
	#   returns    a text such as 0xB
	#   note       exact for whole numbers: 0b1011 answers 0xB and 0b11111111 answers 0xFF; ToHex is
	#              the same call
	#   warning    the fractional digits are lost: 0b101.11 (5.75) answers 0x5. where 0x5.C is
	#              right, and 0b10.1 answers 0x2. where 0x2.8 is right
	#   see        ToOctalForm, ToUnicodeHexForm
	def ToHexForm()
		return This.ToStzNumber().ToHexForm()

		def ToHex()
			return This.ToHexForm()

	# Returns the number as a Unicode code point notation, U+ followed by hexadecimal digits.
	#
	#   returns    a text such as U+B
	#   note       0b1011 gives U+B and 0b11111111 gives U+FF; ToUnicodeHex is the same call
	#   see        ToHexForm
	def ToUnicodeHexForm()
		return This.ToStzNumber().ToUnicodeHexForm()

		def ToUnicodeHex()
			return This.ToUnicodeHexForm()

	# Raises error R14 today instead of returning the number in scientific notation.
	#
	#   returns    nothing; it raises
	#   note       ToScientificNotation is the same call and raises too
	#   warning    it forwards to a stzNumber method of that name, which does not exist, so every
	#              call raises R14
	#   see        ToDecimalForm
	def ToScientificNotationForm()
		return This.ToStzNumber().ToScientificNotationForm()

		def ToScientificNotation()
			return This.ToScientificNotationForm()

	# Returns the integer part written in another base.
	#
	#   _n_        the base, from 2 to 36, another value raises an error
	#   returns    a text of digits in the base, lower-case letters from 10
	#   note       by hand 11 is 102 in base 3, 13 in base 8 and b in base 16: 0b1011 answers each;
	#              255 in base 32 is 7v; IntegerPartToBaseN is the same call
	#   see        ToOctalForm, ToHexForm
	def IntegerPartToBaseNForm(_n_)
		# n must be netween 2 to 32
		return This.ToStzNumber().IntegerPartToBaseNForm(_n_)

		def IntegerPartToBaseN(_n_)
			return This.IntegerPartToBaseNForm(_n_)


	# Returns the number as the 8 bytes of a 64-bit floating-point value, in a raw text.
	#
	#   returns    a text of 8 bytes, not printable
	#   note       0b1011 (11.0) gives the bytes 00 00 00 00 00 00 26 40 in hexadecimal, as stored
	#              on this machine
	#   see        ToDecimalForm
	def ToBytes() #TODO // Should also be turned as stzListOfBytes
		return This.ToStzNumber().ToBytes()
	
	  #----------------------------------#
	 #    GETTING BINARY NUMBER FROM    #
	#----------------------------------#

	# Replaces the number by the binary form of a decimal number, in place.
	#
	#   _n_        the decimal number, whole or with a fraction
	#   returns    nothing; the content changes
	#   note       by hand 12500 is 11000011010100 and 5.75 is 101.11: it gives 0b11000011010100 and
	#              0b101.11; a negative number gives 0b-101, which the constructor itself refuses
	#              (-0b101 is the spelling it accepts); FromDecimal is the same call
	#   see        FromHexForm, FromOctalForm, ToDecimalForm
	def FromDecimalForm(_n_)
		@cBinaryNumber = StzNumberQ(_n_).ToBinaryForm()

		# Replaces the number by the binary form of a decimal number, in place.
		#
		#   _n_        the decimal number, whole or with a fraction
		#   returns    nothing; the content changes
		#   note       the same call as FromDecimalForm: 12500 gives 0b11000011010100
		#   see        FromDecimalForm, FromHex, ToDecimalForm
		def FromDecimal(_n_)
			This.FromDecimalForm(_n_)

	# Replaces the number by the binary form of a hexadecimal number, in place.
	#
	#   cHex       the number as a text starting with 0x, such as 0x0E22
	#   returns    nothing; the content changes
	#   note       by hand 0x0E22 is 3618, which gives 0b111000100010; 0xFF gives 0b11111111;
	#              FromHex is the same call
	#   warning    the text must start with 0x: x0E22, which the class description shows, raises an
	#              error, and so does a hex number with a dot such as 0x1.8
	#   see        FromDecimalForm, FromOctalForm, ToHexForm
	def FromHexForm(cHex)
		@cBinaryNumber = StzHexNumberQ(cHex).ToBinaryForm()

		# Replaces the number by the binary form of a hexadecimal number, in place.
		#
		#   cHex       the number as a text starting with 0x, such as 0xFF
		#   returns    nothing; the content changes
		#   note       the same call as FromHexForm: 0xFF gives 0b11111111
		#   warning    the text must start with 0x, as for FromHexForm: x0E22 raises an error
		#   see        FromHexForm, FromOctal, ToHexForm
		def FromHex(cHex)
			This.FromHexForm(cHex)

	# Replaces the number by the binary form of an octal number, in place.
	#
	#   cOctal     the number as a text starting with 0o, such as 0o2077
	#   returns    nothing; the content changes
	#   note       by hand 0o2077 is 1087, which gives 0b10000111111; 0o17 gives 0b1111; FromOctal
	#              is the same call
	#   warning    the text must start with 0o: o2077, which the class description shows, raises an
	#              error
	#   see        FromDecimalForm, FromHexForm, ToOctalForm
	def FromOctalForm(cOctal)
		@cBinaryNumber = StzOctalNumberQ(cOctal).ToBinaryForm()

		# Replaces the number by the binary form of an octal number, in place.
		#
		#   cOctal     the number as a text starting with 0o, such as 0o17
		#   returns    nothing; the content changes
		#   note       the same call as FromOctalForm: 0o17 gives 0b1111
		#   warning    the text must start with 0o, as for FromOctalForm: o2077 raises an error
		#   see        FromOctalForm, FromHex, ToOctalForm
		def FromOctal(cOctal)
			This.FromOctalForm(cOctal)
		
