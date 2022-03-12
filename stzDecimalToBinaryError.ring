func stzDecimalToBinaryError(pcError)
	cErrorMsg = "in file stzDecimalToBinary.ring:" + NL

	switch pcError
	on :CanNotCreateDecimalNumberFromInvalidString
		cErrorMsg += "   What : Can't create the decimal number." + NL
		cErrorMsg += "   Why  : Value you provided for the number is not in a valid decimal form." + NL
		cErrorMsg += "   Todo : Provide a string formed of digits from 0 to 9, separated by the dot decimal separator, and eventually prefixed by a - or + sign, and separated by underscores. "

	on :CanNotCreateDecimalNumberFromInvalidType
		cErrorMsg += "   What : Can't create the decimal number." + NL
		cErrorMsg += "   Why  : Value you provided for the number is not in a valid type." + NL
		cErrorMsg += "   Todo : Provide a value in a STRING formed of digits from 0 to 9, separated by the dot decimal separator, and eventually containing a - or + sign, and separated by underscores. "

	off

	return cErrorMsg + NL
