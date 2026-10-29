/*
The main advantage of using Octal numbers is that it uses less
digits than decimal and Hexadecimal number system. So, it has
fewer computations and less computational errors. It uses only
3 bits to represent any digit in binary and easy to convert
from octal to binary and vice-versa. It is easier to handle
input and output in the octal form.
*/

$_aOctalPrefixes = [ "o", "0o" ]
$_cOctalNumberPrefix = "0o"

func OctalPrefixes()
	return $_aOctalPrefixes

func OctalPrefix()
	return $_cOctalNumberPrefix

	def OctalNumberPrefix()
		return OctalPrefix()

func SetOctalPrefix(cPrefix)
	_bFound_ = 0
	_aOctalPrefixes1_ = OctalPrefixes()
	_nOctalPrefixes1Len_ = len(_aOctalPrefixes1_)
	for _iLoopOctalPrefixes1_ = 1 to _nOctalPrefixes1Len_
		_item = _aOctalPrefixes1_[_iLoopOctalPrefixes1_]
		if StzLower(_item) = StzLower(cPrefix)
			_bFound_ = 1
			exit
		ok
	next
	if _bFound_
		_cOctalPrefix = cPrefix
	else
		StzRaise("Incorrect octal prefix!")
	ok

	def SetOctalNumberPrefix(cPrefix)
		SetOctalPrefix(cPrefix)

func StzOctalNumberQ(cNumber)
	return new stzOctalNumber(cNumber)

# Holds an octal number and writes it in decimal, binary and hexadecimal.
#
# Built from a text of the digits 0 to 7, with or without the 0o prefix, which is kept as given; the
# From... methods replace the number in place from a decimal, binary or hexadecimal value and store
# it with the 0o prefix. It inherits from stzString. Checked by hand: 0o377 is 255 (0b11111111,
# 0xFF); 0o755 is 493 (0b111101101, 0x1ED); 0o400000000000000000 is 9007199254740992. Found today:
# WithPrefix doubles a prefix that is already stored (0o0o377); ToDecimalForm gives 0 from 2 to the
# power 63 up; ToBaseNForm and ToScientificNotationForm raise R14; and a capital 0O17 is accepted
# and then converts to 0.
#
#   receiver   o1 = new stzOctalNumber("0o377")
#   example    ? o1.ToDecimalForm()
#              #--> 255
#              ? o1.ToBinaryForm()
#              #--> 0b11111111
#              ? o1.ToHexForm()
#              #--> 0xFF
#              o2 = new stzOctalNumber("755")
#              ? o2.ToDecimalForm()
#              #--> 493
#              ? o2.ToHexFormWithoutPrefix()
#              #--> 1ED
#              o2.FromDecimalForm(8)
#              ? o2.Content()
#              #--> 0o10
#   see        stzNumber, stzHexNumber, stzBinaryNumber
class stzOctalNumber from stzString
	@cOctalNumber

	# Builds an octal number from a text of octal digits, with or without the 0o prefix.
	#
	#   pNumber    a text of the digits 0 to 7, optionally written 0o..
	#   returns    nothing; the object is built
	#   note       the class inherits from stzString; write the prefix in small letters: 0o377 and
	#              755 are accepted
	#   warning    the text is kept exactly as given, prefix included, so Content of 0o377 is 0o377
	#              and of 17 is 17; an empty text, 0o alone, a bare o prefix such as o17, a digit 8
	#              or 9, a sign, a point and a number (17 without quotes) are all refused; a capital
	#              0O17 is accepted but then ToDecimalForm gives 0
	#   see        Content, WithPrefix
	def init(pNumber)
		if isString(pNumber) and StringRepresentsNumberInOctalForm(pNumber)
				@cOctalNumber = pNumber

		else
			StzRaise(stzOctalNumberError(:CanNotCreateOctalNumber))
		ok

	# Returns the text the number was built or last set with, prefix included if it had one.
	#
	#   returns    a text
	#   note       17 gives 17 and 0o377 gives 0o377; FromDecimalForm, FromBinaryForm and
	#              FromHexForm store the 0o prefix
	#   see        WithPrefix, OctalNumber
	def Content()
		return @cOctalNumber

		# Returns the text the number was built or last set with.
		#
		#   returns    a text
		#   see        Content
		def Value()
			return Content()

	# Returns the 0o prefix followed by the stored text.
	#
	#   returns    a text
	#   note       use Content when the number was built or set with the prefix
	#   warning    it adds the prefix to a text that may already have it, so 0o377 gives 0o0o377;
	#              only a number built without the prefix, such as 17, gives 0o17
	#   see        Content, ToDecimalForm
	def WithPrefix()
		return OctalPrefix() + This.Content()
	
	# Returns the value as a stzNumber.
	#
	#   returns    a stzNumber holding the decimal value
	#   note       0o377 gives 255
	#   see        ToDecimalForm, ToStzString
	def ToStzNumber()
		return new stzNumber(This.ToDecimalForm())

	# Returns the stored text as a stzString.
	#
	#   returns    a stzString
	#   see        Content, ToStzNumber
	def ToStzString()
		return new stzString(This.OctalNumber())

	# Returns the value in decimal.
	#
	#   returns    a number; 0 for 0o1000000000000000000000 and above
	#   note       ToDecimal is the same call; 0o377 gives 255, 0o755 gives 493,
	#              0o400000000000000000 gives 9007199254740992
	#   warning    a value from 2 to the power 63 up gives 0 instead of its value, and
	#              0o777777777777777777777 (2 to the power 63 less 1) gives 9223372036854775808,
	#              rounded by the double it goes through; confirmed with three values
	#   see        ToBinaryForm, ToHexForm
	def ToDecimalForm()
		_cOctal_ = This.OctalNumber()
		_cOctal_ = StzReplace(_cOctal_, "0o", "")
		_cOctal_ = StzReplace(_cOctal_, "o", "")

		return StzEngineNumberFromBase(_cOctal_, 8)

		def ToDecimal()
			return This.ToDecimalForm()

	# Returns the stored text.
	#
	#   returns    a text
	#   see        Content
	def OctalNumber()
		return Content()

	# Returns the value in binary with the 0b prefix.
	#
	#   returns    a text
	#   note       ToBinary is the same call; 0o377 gives 0b11111111; 17 gives 0b1111; 0 gives 0b0
	#   see        ToBinaryFormWithoutPrefix, ToHexForm
	def ToBinaryForm()
		return This.ToStzNumber().ToBinaryForm()

		def ToBinary()
			return This.ToBinaryForm()

	# Returns the value in binary, without a prefix.
	#
	#   returns    a text
	#   note       ToBinaryWithoutPrefix is the same call; 0o755 gives 111101101
	#   see        ToBinaryForm
	def ToBinaryFormWithoutPrefix()
		return This.ToStzNumber().ToBinaryFormWithoutPrefix()

		def ToBinaryWithoutPrefix()
			return This.ToBinaryFormWithoutPrefix()

	# Returns the value in hexadecimal with the 0x prefix, in capitals.
	#
	#   returns    a text
	#   note       ToHex is the same call; 0o377 gives 0xFF; 17 gives 0xF; 0 gives 0x0
	#   see        ToHexFormWithoutPrefix, ToBinaryForm
	def ToHexForm()
		_oNumber_ = new stzNumber(This.ToDecimalForm())
		return _oNumber_.ToHexForm()

		def ToHex()
			return This.ToHexForm()

	# Returns the value as a U+ code point text, without padding to four digits.
	#
	#   returns    a text
	#   note       ToUnicodeHexFor is the same call; 0o377 gives U+FF; 101 gives U+41, where the
	#              usual written form is U+0041
	#   see        ToHexForm
	def ToUnicodeHexForm()
		_oNumber_ = new stzNumber(This.ToDecimalForm())
		return _oNumber_.ToUnicodeHexForm()

		def ToUnicodeHexFor()
			return This.ToUnicodeHexForm()

	# Returns the value in hexadecimal, without a prefix, in capitals.
	#
	#   returns    a text
	#   note       ToHexmWithoutPrefix is the same call; 0o755 gives 1ED
	#   see        ToHexForm
	def ToHexFormWithoutPrefix()
		return This.ToStzNumber().ToHexFormWithoutPrefix()

		def ToHexmWithoutPrefix()
			return This.ToHexFormWithoutPrefix()

	# Raises error R14 today instead of writing the value in another base.
	#
	#   n          the base meant, from 2 to 32
	#   returns    nothing; the call raises R14
	#   note       toBaseN is the same call; use stzNumber.IntegerPartToBaseNForm on ToStzNumber()
	#              meanwhile
	#   warning    it forwards to ToBaseNForm on stzNumber, a method that does not exist there
	#              (stzNumber has IntegerPartToBaseNForm), so every base raises R14; confirmed with
	#              0o377 and 17
	#   see        ToBinaryForm, ToHexForm
	def ToBaseNForm(n)
		# n must be netween 2 to 32
		return This.ToStzNumber().ToBaseNForm(n)

		def toBaseN(n)
			return This.ToBaseNForm(n)

	# Raises error R14 today instead of writing the value in scientific notation.
	#
	#   returns    nothing; the call raises R14
	#   note       ToScientificNotation is the same call
	#   warning    it forwards to ToScientificNotationForm on stzNumber, a method that does not
	#              exist there; stzNumber raises the same R14 on its own
	#   see        ToDecimalForm
	def ToScientificNotationForm()
		return This.ToStzNumber().ToScientificNotationForm()

		def ToScientificNotation()
			return This.ToScientificNotationForm()

	# Returns eight raw bytes: the value stored as an IEEE 754 double, least significant byte first.
	#
	#   returns    a text of 8 bytes
	#   note       these are not the bytes of the octal digits
	#   see        ToStzNumber
	def ToBytes() #TODO // Should also be turned as stzListOfBytes
		return This.ToStzNumber().ToBytes()

	# Replaces the number with the octal form of a decimal value, in place.
	#
	#   n          the decimal value, an integer of 0 or more
	#   returns    nothing; the number changes
	#   note       255 gives 0o377, 8 gives 0o10, 0 gives 0o0
	#   warning    the stored text gets the 0o prefix, so WithPrefix doubles it afterwards; a
	#              negative value stores 0o-10 and a fraction 8.5 stores 0o10.4, which init would
	#              refuse
	#   see        FromDecimal, FromBinaryForm
	def FromDecimalForm(n)
		@cOctalNumber = StzNumberQ(n).ToOctalForm()		

		# Replaces the number with the octal form of a decimal value, in place.
		#
		#   n          the decimal value, an integer of 0 or more
		#   returns    nothing; the number changes
		#   note       255 gives 0o377
		#   warning    same limits as FromDecimalForm
		#   see        FromDecimalForm
		def FromDecimal(n)
			This.FromDecimalForm(n)

	# Replaces the number with the octal form of a binary value, in place.
	#
	#   cBinary    the binary text, which must carry the 0b prefix
	#   returns    nothing; the number changes
	#   note       0b1010 gives 0o12; 0b11111111 gives 0o377
	#   warning    a binary text without 0b raises Can't create binary number; the stored text gets
	#              the 0o prefix
	#   see        FromBinary, FromHexForm
	def FromBinaryForm(cBinary)
		@cOctalNumber = StzBinaryNumberQ(cBinary).ToOctalForm()		

		# Replaces the number with the octal form of a binary value, in place.
		#
		#   cBinary    the binary text, which must carry the 0b prefix
		#   returns    nothing; the number changes
		#   note       0b1010 gives 0o12
		#   warning    a binary text without 0b raises Can't create binary number
		#   see        FromBinaryForm
		def FromBinary(cBinary)
			This.FromBinaryForm(cBinary)

	# Replaces the number with the octal form of a hexadecimal value, in place.
	#
	#   cHex       the hex text, with or without the 0x prefix
	#   returns    nothing; the number changes
	#   note       0xFF and FF both give 0o377; 0x10 gives 0o20
	#   warning    the stored text gets the 0o prefix
	#   see        FromHex, FromBinaryForm
	def FromHexForm(cHex)
		@cOctalNumber = StzHexNumberQ(cHex).ToOctalForm()		

		# Replaces the number with the octal form of a hexadecimal value, in place.
		#
		#   cHex       the hex text, with or without the 0x prefix
		#   returns    nothing; the number changes
		#   note       0x10 gives 0o20
		#   warning    the stored text gets the 0o prefix
		#   see        FromHexForm
		def FromHex(cHex)
			This.FromHexForm(cHex)

