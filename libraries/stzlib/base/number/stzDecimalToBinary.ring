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

class stzDecimalToBinary from stzObject
	
	# Default values to use by the convertor
	@bNegativeConversionMethod = :ConvertPositiveNumberThenAddMinus

	# The decimal number to convert
	@cDecimalNumber

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

	def ToStzNumber()
		return new stzNumber(@cDecimalNumber)

	def ToStzString()
		return new stzString(@cDecimalNumber)

	def StzBinaryNumber()
		return new stzBinaryNumber(This.ToBinaryForm())

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


	
