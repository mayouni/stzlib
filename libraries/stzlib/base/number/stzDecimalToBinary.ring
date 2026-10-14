/*
	This class converts a decimal number to binary form.

	It is used by the stzNumber class, to convert a number to
	binary using: ToBinaryForm() method.

	The current version translates negative numbers simply by
	converting the positive number and prefixing it with "-" sign.
	This method is initiated by default in the class like this:

	@bNegativeConversionMethod = :ConvertPositiveNumberThenAddMinus

	TODO: In the future, add the conversion of negative numbers using the
	2's-compliment method as described in this article:

	https://www.instructables.com/Convert-Negative-Numbers-to-Binary/
*/

func StzDecimalToBinary(cNumber)
	return new stzDecimalToBinary(cNumber)

func StzDecimalToBinaryQ(cNumber)
	return new stzDecimalToBinary(cNumber)

# Converts a decimal number, given as text, into its binary form such as 0b1010.101.
#
# It is the converter behind ToBinaryForm of stzNumber. Build one with new
# stzDecimalToBinary("10.625") or StzDecimalToBinary("10.625"); the number must be a text, and a
# number or a text that is not a decimal raises an error. The integer part is converted through the
# engine and the fractional part by repeated doubling, cut at 19 binary digits. A negative number is
# converted as its positive twin with a minus sign in front. StzBinaryNumber hands the result to a
# stzBinaryNumber.
#
#   receiver   o1 = new stzDecimalToBinary("10.625")
#   example    ? o1.ToBinaryForm()
#              #--> 0b1010.101
#              ? o1.IntegerPartToBinaryForm()
#              #--> 1010
#              ? o1.FractionalPartToBinaryForm()
#              #--> 101
#   see        stzNumber, stzBinaryNumber
class stzDecimalToBinary from stzObject
	
	# Default values to use by the convertor
	@bNegativeConversionMethod = :ConvertPositiveNumberThenAddMinus

	# The decimal number to convert
	@cDecimalNumber

	# Builds a converter from a decimal number written as text, such as "10.625".
	#
	#   cNumber    the decimal number as a text
	#   returns    nothing; the object is built
	#   note       negative numbers are converted as the positive number with a minus sign in front,
	#              not in two's complement
	#   warning    the number must be passed as a text: new stzDecimalToBinary("5"), not 5
	#   see        ToBinaryForm
	def init(cNumber)
		if isString(cNumber)
			if StringRepresentsNumberInDecimalForm(cNumber)
				@cDecimalNumber = cNumber
	
			else
				StzRaise(stzDecimalToBinaryError(:CanNotCreateDecimalNumberFromInvalidString))
			ok
		else
			
			StzRaise(stzDecimalToBinaryError(:CanNotCreateDecimalNumberFromInvalidType))
		ok

	# Returns the decimal number as a stzNumber.
	#
	#   returns    a stzNumber
	#   see        ToStzString
	def ToStzNumber()
		return new stzNumber(@cDecimalNumber)

	# Returns the decimal number as a stzString, the text it was given.
	#
	#   returns    a stzString
	#   see        ToStzNumber
	def ToStzString()
		return new stzString(@cDecimalNumber)

	# Returns the binary form of the number as a stzBinaryNumber.
	#
	#   returns    a stzBinaryNumber
	#   see        ToBinaryForm
	def StzBinaryNumber()
		return new stzBinaryNumber(This.ToBinaryForm())

	# Returns the number in binary, with the 0b prefix: 0b1010.101 for 10.625, 0b-110.1 for -6.5.
	#
	#   returns    a text such as "0b1010.101"
	#   note       a fraction is cut at 19 binary digits, so 0.1 gives 0b0.0001100110011001100
	#   see        IntegerPartToBinaryForm, FractionalPartToBinaryForm, StzBinaryNumber
	def ToBinaryForm()
		_cBinary_ = ""

		_nNum_ = This.ToStzNumber().NumericValue()

		if _nNum_ = 0
			_cBinary_ = "0"
		else

			_cIntPart_ = This.IntegerPartToBinaryForm()

			# When the integer part is 0, the helper short-circuits
			# to "". Force a literal "0" so the rendered form keeps
			# the leading zero (e.g. "0b-0.101" not "0b-.101").
			if _cIntPart_ = "" or _cIntPart_ = "-"
				_cIntPart_ += "0"
			ok

			_cBinary_ += _cIntPart_

			if This.ToStzNumber().HasFractionalPart()
				_cBinary_  += DefaultFractionalSeparator() + This.FractionalPartToBinaryForm()
			ok

			# Re-apply the negative sign if it was dropped by the
			# integer-part short-circuit (e.g. "-0.625" has integer
			# part 0, which renders as plain "0").
			if _nNum_ < 0 and NOT left(_cBinary_, 1) = "-"
				_cBinary_ = "-" + _cBinary_
			ok
		ok

		return BinaryNumberPrefix() + _cBinary_

	# Returns the binary digits of the integer part, with a minus sign for a negative number, and an empty text when that part is 0.
	#
	#   returns    a text of 0 and 1; "" when the integer part is 0
	#   note       0.625 and -0.625 give "" here, while ToBinaryForm writes the 0 back
	#   see        ToBinaryForm, FractionalPartToBinaryForm
	def IntegerPartToBinaryForm()
		_nVal_ = This.ToStzNumber().IntegerPartValue()
		if _nVal_ = 0
			return ""
		ok

		_cPrefix_ = ""
		if _nVal_ < 0
			_cPrefix_ = "-"
			_nVal_ = -_nVal_
		ok

		return _cPrefix_ + StzEngineNumberToBase(_nVal_, 2)

	# Returns the binary digits of the part after the decimal point, at most 19 of them.
	#
	#   returns    a text of 0 and 1; "0" for a whole number
	#   note       the sign is not included, 0.625 and -0.625 both give 101
	#   see        ToBinaryForm, IntegerPartToBinaryForm
	def FractionalPartToBinaryForm()

		_n_ = This.ToStzNumber().FractionalPartValue()

		if _n_ < 0
			_n_ = -_n_
		ok

		_aTemp_ = []
		_cBinary_ = ""

		_nPrecision_ = 0
		_bAgain_ = 1

		while _bAgain_
			
			_nPrecision_++
			if _nPrecision_ > 19
				_bAgain_ = 0

			else
				_nDouble_ = _n_ * 2 // Check if This should to be done using stzNumber
	
				_oTempNumber_ = new stzNumber(_nDouble_)
	
				if NOT _oTempNumber_.HasFractionalPart()
					_bAgain_ = 0
				ok
	
				_aTemp_ + _oTempNumber_.IntegerPart()
				_n_ = _oTempNumber_.FractionalPartValue()
			ok
				
		end

		_nTempLen_ = len(_aTemp_)
		for i = 1 to _nTempLen_
			_cBinary_ += _aTemp_[i]
		next

		return _cBinary_


	
