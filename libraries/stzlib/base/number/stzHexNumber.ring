/*
Hex numbers are used mainly because they form a more
compact form to represent numbers compared to binary.

They are base16 numbers -> formed of 16 bits -> the digits
0 to 9 and the letter A to F.
*/


_cHexNumberPrefix = "0x"
_acHexPrefixes = [ "x", "0x", "U+" ]

func StzHexNumberQ(_cHex_)
	return new stzHexNumber(_cHex_)

func HexToDecimalForm(_cHex_)
	return StzHexNumberQ(_cHex_).ToDecimalForm()

	func HexToDecimal(_cHex_)
		return HexToDecimalForm(_cHex_)

	func HexToUnicode(_cHex_)
		return HexToDecimalForm(_cHex_)

func UnicodeHexToDecimalForm(cUnicodeHex)
	if IsUnicodeHex(cUnicodeHex)
		_cHex_ = StzMid(cUnicodeHex, 3, StzLen(cUnicodeHex) - 2)
		_cHex_ = HexPrefix() + _cHex_
		return HexToDecimal(_cHex_).ToDecimalForm()
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
	return StringRepresentsNumberInUnicodeHexForm(cNumber)

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

func HexToDec(_cHex_)
	return dec(_cHex_)

func DecToHex(nDec)
	return hex(nDec)

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

		but StringRepresentsNumberInHexForm(cNumber)

			_cTemp_ = cNumber
			_acHexPrefix_ = HexPrefixes()
			_nLen_ = len(_acHexPrefix_)

			for i = 1 to _nLen_
				_nPrefLen_ = StzLen(_acHexPrefix_[i])
				if StzLeft(_cTemp_, _nPrefLen_) = _acHexPrefix_[i]
					_cTemp_ = StzMid(_cTemp_, _nPrefLen_ + 1, StzLen(_cTemp_) - _nPrefLen_)
				ok
			next

			@cHexNumber = _cTemp_

		but StringRepresentsNumberInUnicodeHexForm(cNumber)
			@cHexNumber = StzReplace(StzReplace(cNumber, "U+", ""), "u+", "")

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

		_oStzStr_ = new stzString(This.HexNumber())

		if _oStzStr_.Contains(".")
			return _oStzStr_.Splitted(".")[1]
		else
			return _oStzStr_.Content()
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

		_oStrTemp_ = new stzString(THis.IntegerPart())
		_oStrTemp_.RemoveMany(HexPrefixes())

		_cResult_ = _oStrTemp_.Content()
		return _cResult_

		def IntPartWithoutPrefix()
			return This.IntegerPartWithoutPrefix()

	def FractionalPart()
		_oStzStr_ = new stzString(This.HexNumberWithoutPrefix())

		if _oStzStr_.Contains(".")
			return _oStzStr_.SplittedUsing(".")[2]
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
		return "" + StzEngineNumberFromBase(This.IntegerPartWithoutPrefix(), 16)

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
		# ToHexForm() returns the PREFIXED form ("0x..."), but @cHexNumber
		# must hold the content WITHOUT prefix (Content()/WithPrefix() add
		# it back). Strip the leading prefix so WithPrefix() doesn't double.
		@cHexNumber = This._StripHexPrefix( StzNumberQ(n).ToHexForm() )

		def FromDecimal(n)
			This.FromDecimalForm(n)

	def FromOctalForm(n)
		@cHexNumber = This._StripHexPrefix( StzOctalNumberQ(n).ToHexForm() )

		def FromOctal(n)
			This.FromOctalForm(n)

	def FromBinaryForm(n)
		@cHexNumber = This._StripHexPrefix( StzBinaryNumberQ(n).ToHexForm() )

		def FromBinary(n)
			This.FromBinaryForm(n)

	def _StripHexPrefix(_cHex_)
		_acHexPrefix_ = HexPrefixes()
		_nLen_ = len(_acHexPrefix_)
		for i = 1 to _nLen_
			_nPrefLen_ = StzLen(_acHexPrefix_[i])
			if StzLeft(_cHex_, _nPrefLen_) = _acHexPrefix_[i]
				_cHex_ = StzMid(_cHex_, _nPrefLen_ + 1, StzLen(_cHex_) - _nPrefLen_)
				exit
			ok
		next
		return _cHex_

	  #-----------#
	 #   MISC.   #
	#-----------#

	def IsHexNumber() # required by stzChainOfTruth
		return 1
