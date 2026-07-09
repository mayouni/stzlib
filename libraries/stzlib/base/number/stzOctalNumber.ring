/*
The main advantage of using Octal numbers is that it uses less
digits than decimal and Hexadecimal number system. So, it has
fewer computations and less computational errors. It uses only
3 bits to represent any digit in binary and easy to convert
from octal to binary and vice-versa. It is easier to handle
input and output in the octal form.
*/

_aOctalPrefixes = [ "o", "0o" ]
_cOctalNumberPrefix = "0o"

func OctalPrefixes()
	return _aOctalPrefixes

func OctalPrefix()
	return _cOctalNumberPrefix

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

class stzOctalNumber from stzString
	@cOctalNumber

	def init(pNumber)
		if isString(pNumber) and StringRepresentsNumberInOctalForm(pNumber)
				@cOctalNumber = pNumber

		else
			StzRaise(stzOctalNumberError(:CanNotCreateOctalNumber))
		ok

	def Content()
		return @cOctalNumber

		def Value()
			return Content()

	def WithPrefix()
		return OctalPrefix() + This.Content()
	
	def ToStzNumber()
		return new stzNumber(This.ToDecimalForm())

	def ToStzString()
		return new stzString(This.OctalNumber())

	def ToDecimalForm()
		_cOctal_ = This.OctalNumber()
		_cOctal_ = StzReplace(_cOctal_, "0o", "")
		_cOctal_ = StzReplace(_cOctal_, "o", "")

		return StzEngineNumberFromBase(_cOctal_, 8)

		def ToDecimal()
			return This.ToDecimalForm()

	def OctalNumber()
		return Content()

	def ToBinaryForm()
		return This.ToStzNumber().ToBinaryForm()

		def ToBinary()
			return This.ToBinaryForm()

	def ToBinaryFormWithoutPrefix()
		return This.ToStzNumber().ToBinaryFormWithoutPrefix()

		def ToBinaryWithoutPrefix()
			return This.ToBinaryFormWithoutPrefix()

	def ToHexForm()
		_oNumber_ = new stzNumber(This.ToDecimalForm())
		return _oNumber_.ToHexForm()

		def ToHex()
			return This.ToHexForm()

	def ToUnicodeHexForm()
		_oNumber_ = new stzNumber(This.ToDecimalForm())
		return _oNumber_.ToUnicodeHexForm()

		def ToUnicodeHexFor()
			return This.ToUnicodeHexForm()

	def ToHexFormWithoutPrefix()
		return This.ToStzNumber().ToHexFormWithoutPrefix()

		def ToHexmWithoutPrefix()
			return This.ToHexFormWithoutPrefix()

	def ToBaseNForm(n)
		# n must be netween 2 to 32
		return This.ToStzNumber().ToBaseNForm(n)

		def toBaseN(n)
			return This.ToBaseNForm(n)

	def ToScientificNotationForm()
		return This.ToStzNumber().ToScientificNotationForm()

		def ToScientificNotation()
			return This.ToScientificNotationForm()

	def ToBytes() #TODO // Should also be turned as stzListOfBytes
		return This.ToStzNumber().ToBytes()

	def FromDecimalForm(n)
		@cOctalNumber = StzNumberQ(n).ToOctalForm()		

		def FromDecimal(n)
			This.FromDecimalForm(n)

	def FromBinaryForm(cBinary)
		@cOctalNumber = StzBinaryNumberQ(cBinary).ToOctalForm()		

		def FromBinary(cBinary)
			This.FromBinaryForm(cBinary)

	def FromHexForm(cHex)
		@cOctalNumber = StzHexNumberQ(cHex).ToOctalForm()		

		def FromHex(cHex)
			This.FromHexForm(cHex)

