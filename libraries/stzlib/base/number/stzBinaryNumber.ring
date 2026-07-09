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

	if isString(pcBinaryPrefix) and StzFindFirst(BinaryPrefixes(),pcBinaryPrefix) > 0
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

	def Content()
		return @cBinaryNumber

		def Value()
			return This.Content()

		def BinaryNumber()
			return Content()
	
	def WithPrefix()
		return BinaryPrefix() + This.Content()


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
		return StzEngineNumberBitwiseAnd(0+ This.ToDecimalForm(), nOtherNumber)

	def BitwiseOR(nOtherNumber)
		return StzEngineNumberBitwiseOr(0+ This.ToDecimalForm(), nOtherNumber)

	def BitwiseXOR(nOtherNumber)
		return StzEngineNumberBitwiseXor(0+ This.ToDecimalForm(), nOtherNumber)

	def BitwiseOnesComplement(nOtherNumber)
		return StzEngineNumberBitwiseNot(0+ This.ToDecimalForm())

	def BitwiseLeftShift(nOtherNumber)
		return StzEngineNumberBitwiseLShift(0+ This.ToDecimalForm(), nOtherNumber)

	def BitwiseRightShift(nOtherNumber)
		return StzEngineNumberBitwiseRShift(0+ This.ToDecimalForm(), nOtherNumber)

 	  #--------------------------------#
	 #    INTEGER & FRACTION PARTS    #
	#--------------------------------#
		
	def IntegerPart()
		_n_ = ring_substr1(This.BinaryNumber(), ".")

		if _n_ = 0
			return This.BinaryNumber()

		else
			return _oTempStr_.Section( 1, _n_-1 )
		ok

	def FractionalPart()
		_cResult_ = ""
		_oTempStr_ = new stzString(This.BinaryNumber())
		_n_ = _oTempStr_.FindFirstOccurrence(".")

		if _n_ > 0
			_nLen_ = _oTempStr_.NumberOfchars()
			_cResult_ = _oTempStr_.Section( _n_+1, _nLen_ )
		ok

		return _cResult_

	def Reversed()
		_cResult_ = This.IntegerPartReversed()
		if This.HasFractionalPart()
			_cResult_ += "." + This.FractionalPartReversed()
		ok

		return _cResult_

	def HasFractionalPart()
		If This.FractionalPart() != ""
			return 1
		else
			return 0
		ok

		def ContainsFractionalPart()
			return This.HasFractionalPart()

	def FractionalPartReversed()
		_cStr_ = This.FractionalPart()
		_cRev_ = ""
		for i = StzLen(_cStr_) to 1 step -1
			_cRev_ += _cStr_[i]
		next
		return _cRev_

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

	def ToStzNumber()
		return new stzNumber( This.ToDecimalForm() )

	def ToStzString()
		return new stzString( This.BinaryNumber() )

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

	def FractionalPartToDecimalFormWithoutZeroDot()
		_oFractionalPart_ = new stzString(This.FractionalPartToDecimalForm())
		return _oFractionalPart_.Section(3, _oFractionalPart_.NumberOfChars())

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

	def IntegerPartToBaseNForm(_n_)
		# n must be netween 2 to 32
		return This.ToStzNumber().IntegerPartToBaseNForm(_n_)

		def IntegerPartToBaseN(_n_)
			return This.IntegerPartToBaseNForm(_n_)


	def ToBytes() #TODO // Should also be turned as stzListOfBytes
		return This.ToStzNumber().ToBytes()
	
	  #----------------------------------#
	 #    GETTING BINARY NUMBER FROM    #
	#----------------------------------#

	def FromDecimalForm(_n_)
		@cBinaryNumber = StzNumberQ(_n_).ToBinaryForm()

		def FromDecimal(_n_)
			This.FromDecimalForm(_n_)

	def FromHexForm(cHex)
		@cBinaryNumber = StzHexNumberQ(cHex).ToBinaryForm()

		def FromHex(cHex)
			This.FromHexForm(cHex)

	def FromOctalForm(cOctal)
		@cBinaryNumber = StzOctalNumberQ(cOctal).ToBinaryForm()

		def FromOctal(cOctal)
			This.FromOctalForm(cOctal)
		
