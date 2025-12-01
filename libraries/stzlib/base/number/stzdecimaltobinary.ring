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

		if This.ToStzNumber().NumericValue() = 0
			cBinary = "0"
		else
	
			cBinary += This.IntegerPartToBinaryForm()
	
			if This.ToStzNumber().HasFractionalPart()
				cBinary  += DefaultFractionalSeparator() + This.FractionalPartToBinaryForm()
			ok
		ok

		return BinaryNumberPrefix() + cBinary

	def IntegerPartToBinaryForm()
		
		cBinary = ""

		if This.ToStzNumber().NumericValue() = 0
			cBinary = ""

		else
			cBinary = ""

			# Take the number corresponding to the integer part
			n = This.ToStzNumber().IntegerPartValue()

			if This.ToStzNumber().IsNegative()
				n = -n
				cBinary = "-"
			ok

			aTemp = []
			bAgain = 1
	
			# Divide by 2 until reaching 0 as a result
	
			while bAgain
	
				# If the result is 0 then stop the division
	
				if floor(n/2) = 0
					bAgain = 0
				ok
	
				# Save the remainder
	
				aTemp + (n % 2)
				
				# Take the result and divide it by 2
	
				n = floor(n/2)
			end
				
			for i = len(aTemp) to 1 step -1
				cBinary += aTemp[i]
			next
		
		ok

		return cBinary

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

		for i = 1 to len(aTemp)
			cBinary += aTemp[i]
		next

		return cBinary


	
