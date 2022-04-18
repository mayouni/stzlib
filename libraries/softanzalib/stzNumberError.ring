func stzNumberError(pcError)
	cErrorMsg = "in file stzNumber.ring:" + NL

	switch pcError

	on :CanNotCreateStzNumberObject
		cErrorMsg += "   What : Can't create the number from the provided value." + NL
		cErrorMsg += "   Why  : Value you provided is not in correct." + NL
		cErrorMsg += "   Todo : Provide a decimal number, or a number in a string of a valid form (decimal, hexadecimal, octal, or binary)."

	on :CanNotCreateDecimalNumber1
		cErrorMsg += "   What : Can not create decimal number!" + NL
		cErrorMsg += "   Why  : The number you provided is not valid." + NL
		cErrorMsg += "   Todo : Provide a number in a valid decimal form."

	on :CanNotCreateDecimalNumber2
		cErrorMsg += "   What : Can not create decimal number!" + NL
		cErrorMsg += "   Why  : The number you provided is not calculable." + NL
		cErrorMsg += "   Todo : Provide a number between MinCalculableNumber() and MaxCalculableNumber()."

	on :CanNotCreateNumberFromHexForm
		cErrorMsg += "   What : Can't create the number from a hex form." + NL
		cErrorMsg += "   Why  : Value you provided to FromHex() method is not in a valid hex form." + NL
		cErrorMsg += "   Todo : Provide a valid hex number formed of hex characters (0 to 9 and A to F) preceeded by the small letter x."

	on :CanNotCreateNumberFromBinaryForm
		cErrorMsg += "   What : Can't create the number from a binary form." + NL
		cErrorMsg += "   Why  : Value you provided to FromBinary() method is not in a valid binary form." + NL
		cErrorMsg += "   Todo : Provide a valid binary number formed of binary digits (0 and 1) preceeded by the small letter b."

	on :CanNotCreateNumberFromOctalForm
		cErrorMsg += "   What : Can't create the number from an octal form." + NL
		cErrorMsg += "   Why  : Value you provided to FromOctal() method is not in a valid octal form." + NL
		cErrorMsg += "   Todo : Provide a valid octal number formed of octal digits (0 to 7) preceeded by the small letter o."

	on :CanNotConvertNumberFromDecimalInThisForm
		cErrorMsg += "   What : Can't convert the number from decimal in the provided form." + NL
		cErrorMsg += "   Why  : The form you provided is not a valid decimal form." + NL
		cErrorMsg += "   Todo : Provide a number in decimal formed of the digits 0 to 9."

	on :CanNotConvertNumberFromBinaryInThisForm
		cErrorMsg += "   What : Can't convert the number from binary in the provided form." + NL
		cErrorMsg += "   Why  : The form you provided is not a valid binary form." + NL
		cErrorMsg += "   Todo : Provide a number in a STRING formed of the digits 0 and 1, preceeded with the small letter b."

	on :CanNotConvertNumberFromOctalInThisForm
		cErrorMsg += "   What : Can't convert the number from octal in the provided form." + NL
		cErrorMsg += "   Why  : The form you provided is not a valid octal form." + NL
		cErrorMsg += "   Todo : Provide a number in a STRING formed of the digits 0 to 7, preceeded with the small letter o."

	on :CanNotConvertNumberFromHexInThisForm
		cErrorMsg += "   What : Can't convert the number from hexadecimal in the provided form." + NL
		cErrorMsg += "   Why  : The form you provided is not a valid hexadecimal form." + NL
		cErrorMsg += "   Todo : Provide a number in a STRING formed of the characters 0 to 9 and A to F, preceeded with the small letter x."

	on :UnsupportedNumberConversionTargetForm
		cErrorMsg += "   What : Can't convert the number to its target form." + NL
		cErrorMsg += "   Why  : The target form you provided is not supported." + NL
		cErrorMsg += "   Todo : Provide one of the supported target forms (:ToDecimal, :ToBinary, :ToOctal, or :ToHex)."

	on :UnsupportedNumberConversionSourceForm
		cErrorMsg += "   What : Can't convert the number from its source form." + NL
		cErrorMsg += "   Why  : The source form you provided is not supported." + NL
		cErrorMsg += "   Todo : Provide one of the supported source forms (:FromDecimal, :FromBinary, :FromOctal, or :FromHex)."

	on :CanNotConvertNumberToSpecifiedBase
		cErrorMsg += "   What : Can't convert this number in the specified base." + NL
		cErrorMsg += "   Why  : Either the number is not inter or the base you provided is not supported." + NL
		cErrorMsg += "   Todo : Provide an integer and a base between 2 and 36 and it will be fine ;)"

	on :CanNotRoundSutchLargeNumber
		cErrorMsg += "   What : Can't round sutch a large number!" + NL
		cErrorMsg += "   Why  : The number is large enought that it is not computable by Ring." + NL
		cErrorMsg += "   Todo : Provide a number smaller than MaxCalculableNumber() and it will be fine ;)"

	off



	return cErrorMsg + NL
