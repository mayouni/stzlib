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
		cBinary = ""

		_nNum_ = This.ToStzNumber().NumericValue()

		if _nNum_ = 0
			cBinary = "0"
		else

			_cIntPart_ = This.IntegerPartToBinaryForm()

			# When the integer part is 0, the helper short-circuits
			# to "". Force a literal "0" so the rendered form keeps
			# the leading zero (e.g. "0b-0.101" not "0b-.101").
			if _cIntPart_ = "" or _cIntPart_ = "-"
				_cIntPart_ += "0"
			ok

			cBinary += _cIntPart_

			if This.ToStzNumber().HasFractionalPart()
				cBinary  += DefaultFractionalSeparator() + This.FractionalPartToBinaryForm()
			ok

			# Re-apply the negative sign if it was dropped by the
			# integer-part short-circuit (e.g. "-0.625" has integer
			# part 0, which renders as plain "0").
			if _nNum_ < 0 and NOT left(cBinary, 1) = "-"
				cBinary = "-" + cBinary
			ok
		ok

		return BinaryNumberPrefix() + cBinary

	def IntegerPartToBinaryForm()
		nVal = This.ToStzNumber().IntegerPartValue()
		if nVal = 0
			return ""
		ok

		cPrefix = ""
		if nVal < 0
			cPrefix = "-"
			nVal = -nVal
		ok

		return cPrefix + StzEngineNumberToBase(nVal, 2)

	def FractionalPartToBinaryForm()

		n = This.ToStzNumber().FractionalPartValue()

		if n < 0
			n = -n
		ok

		aTemp = []
		cBinary = ""

		nPrecision = 0
		bAgain = 1

		while bAgain
			
			nPrecision++
			if nPrecision > 19
				bAgain = 0

			else
				nDouble = n * 2 // Check if This should to be done using stzNumber
	
				oTempNumber = new stzNumber(nDouble)
	
				if NOT oTempNumber.HasFractionalPart()
					bAgain = 0
				ok
	
				aTemp + oTempNumber.IntegerPart()
				n = oTempNumber.FractionalPartValue()
			ok
				
		end

		for i = 1 to ring_len(aTemp)
			cBinary += aTemp[i]
		next

		return cBinary


	
