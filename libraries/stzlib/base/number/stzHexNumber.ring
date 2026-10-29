/*
Hex numbers are used mainly because they form a more
compact form to represent numbers compared to binary.

They are base16 numbers -> formed of 16 bits -> the digits
0 to 9 and the letter A to F.
*/


$_cHexNumberPrefix = "0x"
$_acHexPrefixes = [ "x", "0x", "U+" ]

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
	return $_cHexNumberPrefix

	#< @FunctionAlternativeForm

	func HexPrefix()
		return HexNumberPrefix()

	#>

func HexPrefixes()
	return $_acHexPrefixes

	def HexNumberPrefixes()
		return HexPrefixes()

func SetHexPrefix(pcPrefix)
	if find(HexPrefixes(), pcPrefix) > 0
		$_cHexNumberPrefix = pcPrefix
	else
		StzRaise("Unsupported hex prefix!")
	ok

# Holds a hexadecimal number and writes it in decimal, binary, octal or any base up to 36.
#
# Built from text with or without a prefix (FF, 0xFF, U+0041); the digits are kept without the
# prefix and WithPrefix adds 0x back. The conversions go through a floating-point number, so they
# are exact up to 9007199254740992 and rounded above. The From... methods replace the number in
# place from a decimal, octal or binary value. Checked by hand: 0xFF is 255, 0b11111111 and 0o377;
# 0x1A3 is 419, 0b110100011 and 0o643; 0xDEADBEEF is 3735928559. Found today: FractionalPart and
# ToScientificForm raise R14; IntegerPartWithoutPrefix keeps a stray 0 (0xFF gives 0FF);
# ToUnicodeHexForm keeps the 0x inside the U+ (U+0x41); and FromDecimalForm stores -1 and FF. for a
# negative and a fraction.
#
#   receiver   o1 = new stzHexNumber("0xFF")
#   example    ? o1.ToDecimalForm()
#              #--> 255
#              ? o1.ToBinaryForm()
#              #--> 0b11111111
#              ? o1.ToOctalForm()
#              #--> 0o377
#              o2 = new stzHexNumber("1A3")
#              ? o2.WithPrefix()
#              #--> 0x1A3
#              ? o2.ToDecimalForm()
#              #--> 419
#              o2.FromDecimalForm(4096)
#              ? o2.Content()
#              #--> 1000
#   see        stzNumber, stzBinaryNumber, stzOctalNumber
class stzHexNumber from stzObject
	@cHexNumber
	# Builds a hexadecimal number from text, with a 0x prefix, a U+ prefix or none, and keeps the digits without the prefix.
	#
	#   cNumber    the hex digits 0-9 A-F in either case, optionally written 0x.. or U+..
	#   returns    nothing; the object is built
	#   note       1A3 and 0x1A3 and U+0041 are all accepted; the case of the digits is kept
	#   warning    a fractional text such as 0x1F.8, a sign, a text of only 0x and a bare x prefix
	#              raise Can't create the hex number, and a value that is not text raises Incorrect
	#              param type
	#   see        Content, WithPrefix
	#@ aka  Stored Without prefix! Prefixes are used only when exporting the request using WithPrefix()
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

	# Returns the digits as stored, without any prefix.
	#
	#   returns    a text
	#   note       WithoutPrefix is the same call; 0xFF gives FF and ff stays ff
	#   see        WithPrefix, ToDecimalForm
	def Content()
		return @cHexNumber

		# Returns the digits as stored, without any prefix.
		#
		#   returns    a text
		#   see        Content, WithPrefix
		def Value()
			return Content()

	def WithoutPrefix()
		return This.Content()

	# Returns the digits with the 0x prefix in front.
	#
	#   returns    a text
	#   note       HexNumber is the same call; FF gives 0xFF, and an empty number gives 0x
	#   see        Content, ToUnicodeHexForm
	def WithPrefix()
		return HexPrefix() + This.WithoutPrefix()

	def HexNumber()
		return This.WithPrefix()


	# Returns the part before a point, written with the 0x prefix.
	#
	#   returns    a text
	#   note       IntPart is the same call; as a number cannot hold a point today this is the whole
	#              number: ABC gives 0xABC
	#   see        IntegerPartWithoutPrefix, FractionalPart
	def IntegerPart()

		_oStzStr_ = new stzString(This.HexNumber())

		if _oStzStr_.Contains(".")
			return _oStzStr_.Splitted(".")[1]
		else
			return _oStzStr_.Content()
		ok

		def IntPart()
			return This.IntegerPart()

	# Returns the integer digits with the prefix removed, but with a stray 0 in front.
	#
	#   returns    a text such as 0FF for 0xFF
	#   note       use Content for the digits alone
	#   warning    it removes the prefix letter x before the prefix 0x, so the 0 of 0x stays: 0xFF
	#              gives 0FF, 0xabc gives 0abc and 0x0 gives 00; the value is unchanged, so
	#              ToDecimalForm is right
	#   see        IntegerPart, Content
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

	# Raises error R14 today instead of returning the digits after the point.
	#
	#   returns    nothing; the call raises R14
	#   note       confirmed with 0xFF and 0x41
	#   warning    it calls HexNumberWithoutPrefix, a method that does not exist, so FractionalPart
	#              and FractPart raise for every input; init also refuses a text with a point, so
	#              there is never a fraction to return
	#   see        IntegerPart
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

	# Returns the value as a stzNumber.
	#
	#   returns    a stzNumber holding the decimal value
	#   note       0xFF gives 255
	#   see        ToDecimalForm, ToStzString
	def ToStzNumber()
		return new stzNumber(This.ToDecimalForm())

	# Returns the number written with its 0x prefix, as a stzString.
	#
	#   returns    a stzString
	#   note       0x41 gives 0x41 as a text
	#   see        WithPrefix, ToStzNumber
	def ToStzString()
		return new stzString(This.HexNumber())

	# Returns the value in decimal, as a text.
	#
	#   returns    a text
	#   note       ToDecimal is the same call; 0xFF gives 255, 0x1A3 gives 419, 0xDEADBEEF gives
	#              3735928559, an empty number gives 0
	#   warning    the value goes through a floating-point number, so it is exact up to
	#              9007199254740992 and rounded above: 0x7FFFFFFFFFFFFFFF gives
	#              9223372036854775808.00 instead of ...807
	#   see        ToBinaryForm, ToOctalForm
	def ToDecimalForm()
		return "" + StzEngineNumberFromBase(This.IntegerPartWithoutPrefix(), 16)

		def ToDecimal()
			return This.ToDecimalForm()

	# Returns the number written with a U+ in front, but with the 0x prefix kept inside.
	#
	#   returns    a text such as U+0x41 for 0x41
	#   note       ToUnicodeHex is the same call
	#   warning    the 0x prefix is not dropped, so the result is not a valid code point text: 0x41
	#              gives U+0x41 where U+0041 is meant; confirmed with 0xFF and U+0041
	#   see        WithPrefix, ToDecimalForm
	def ToUnicodeHexForm()
		return "U+" + This.HexNumber()

		def ToUnicodeHex()
			return This.ToUnicodeHexForm()

	# Returns the value in binary with the 0b prefix.
	#
	#   returns    a text
	#   note       ToBinary is the same call; 0xFF gives 0b11111111; 0x1A3 gives 0b110100011; 0x0
	#              gives 0b0
	#   see        ToBinaryFormWithoutPrefix, ToOctalForm
	def ToBinaryForm()
		return This.ToStzNumber().ToBinaryForm()

		def ToBinary()
			return This.ToBinaryForm()

	# Returns the value in binary, without a prefix.
	#
	#   returns    a text
	#   note       0xFF gives 11111111; 0xDEADBEEF gives 11011110101011011011111011101111
	#   see        ToBinaryForm
	def ToBinaryFormWithoutPrefix()
		return This.ToStzNumber().ToBinaryFormWithoutPrefix()

		def ToBinaryWithoutPrefix()
			return This.ToBinaryFormWithoutPrefix()

	# Returns the value in octal with the 0o prefix.
	#
	#   returns    a text
	#   note       ToOctal is the same call; 0xFF gives 0o377; 0x1A3 gives 0o643; 0xabc gives 0o5274
	#   see        ToOctalFormWithoutPrefix, ToBinaryForm
	def ToOctalForm()
		return This.ToStzNumber().ToOctalForm()

		def ToOctal()
			return This.ToOctalForm()

	# Returns the value in octal, without a prefix.
	#
	#   returns    a text
	#   note       0xFF gives 377; 0xDEADBEEF gives 33653337357
	#   see        ToOctalForm
	def ToOctalFormWithoutPrefix()
		return This.ToStzNumber().ToOctalFormWithoutPrefix()

		def ToOctalWithoutPrefix()
			return This.ToOctalFormWithoutPrefix()

	# Returns the whole number written in any base from 2 to 36, in lower case and without prefix.
	#
	#   n          the base, from 2 to 36
	#   returns    a text
	#   note       IntegerPartToBaseN is the same call; 0xFF in base 2 gives 11111111, in base 36
	#              gives 73; 0x41 in base 32 gives 21
	#   see        ToBinaryForm, ToOctalForm
	def IntegerPartToBaseNForm(n)
		# n must be netween 2 to 32
		return This.ToStzNumber().IntegerPartToBaseNForm(n)

		def IntegerPartToBaseN(n)
			return This.IntegerPartToBaseNForm(n)

	# Raises error R14 today instead of returning the value in scientific notation.
	#
	#   returns    nothing; the call raises R14
	#   note       ToScientific is the same call
	#   warning    it forwards to stzNumber.ToScientificForm, a method that does not exist, and
	#              passes an undefined variable; stzNumber itself raises the same R14; confirmed
	#              with 0xFF and 0x41
	#   see        ToDecimalForm
	def ToScientificForm()
		return This.ToStzNumber().ToScientificForm(n)

		def ToScientific()
			return This.ToScientificForm()

	# Returns eight raw bytes: the value stored as an IEEE 754 double, least significant byte first.
	#
	#   returns    a text of 8 bytes
	#   note       0xFF gives the bytes 00 00 00 00 00 E0 6F 40, since 255.0 is 0x406FE00000000000;
	#              these are not the bytes of the hex digits
	#   see        ToStzNumber
	def ToBytes() #TODO // Should also be turned as stzListOfBytes
		return This.ToStzNumber().ToBytes()

	# Replaces the number with the hex digits of a decimal value, in place.
	#
	#   n          the decimal value, an integer of 0 or more
	#   returns    nothing; the number changes
	#   note       255 gives FF, 4096 gives 1000, 1000000 gives F4240, 0 gives 0; the digits come
	#              out in capitals
	#   warning    a negative value stores -1 and a fraction such as 255.5 stores FF., neither of
	#              which init would accept; a text that is not a number raises the stzNumber error
	#              Can not create decimal number
	#   see        FromDecimal, FromOctalForm
	def FromDecimalForm(n)
		# ToHexForm() returns the PREFIXED form ("0x..."), but @cHexNumber
		# must hold the content WITHOUT prefix (Content()/WithPrefix() add
		# it back). Strip the leading prefix so WithPrefix() doesn't double.
		@cHexNumber = This._StripHexPrefix( StzNumberQ(n).ToHexForm() )

		# Replaces the number with the hex digits of a decimal value, in place.
		#
		#   n          the decimal value, an integer of 0 or more
		#   returns    nothing; the number changes
		#   note       4096 gives 1000
		#   warning    same limits as FromDecimalForm
		#   see        FromDecimalForm
		def FromDecimal(n)
			This.FromDecimalForm(n)

	# Replaces the number with the hex digits of an octal value, in place.
	#
	#   n          the octal text, with or without the 0o prefix
	#   returns    nothing; the number changes
	#   note       0o17 and 17 both give F; 377 gives FF
	#   see        FromOctal, FromBinaryForm
	def FromOctalForm(n)
		@cHexNumber = This._StripHexPrefix( StzOctalNumberQ(n).ToHexForm() )

		# Replaces the number with the hex digits of an octal value, in place.
		#
		#   n          the octal text, with or without the 0o prefix
		#   returns    nothing; the number changes
		#   note       377 gives FF
		#   see        FromOctalForm
		def FromOctal(n)
			This.FromOctalForm(n)

	# Replaces the number with the hex digits of a binary value, in place.
	#
	#   n          the binary text, which must carry the 0b prefix
	#   returns    nothing; the number changes
	#   note       0b1010 gives A; 11111111 raises
	#   warning    a binary text without the 0b prefix raises Can't create binary number, whereas
	#              FromOctalForm accepts both forms
	#   see        FromBinary, FromOctalForm
	def FromBinaryForm(n)
		@cHexNumber = This._StripHexPrefix( StzBinaryNumberQ(n).ToHexForm() )

		# Replaces the number with the hex digits of a binary value, in place.
		#
		#   n          the binary text, which must carry the 0b prefix
		#   returns    nothing; the number changes
		#   note       0b101 gives 5
		#   warning    a binary text without the 0b prefix raises Can't create binary number
		#   see        FromBinaryForm
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

	# TRUE if the object is a hexadecimal number, which it always is.
	#
	#   returns    TRUE as 1
	#   note       exists for the chain-of-truth checks; the function IsHexNumber("0xFF") tests a
	#              text
	#   see        Content
	def IsHexNumber() # required by stzChainOfTruth
		return 1
