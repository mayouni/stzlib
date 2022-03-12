func stzBinaryNumberError(pcError)
	cErrorMsg = "in file stzBinaryNumber.ring:" + NL

	switch pcError
	on :CanNotCreateBinaryNumber1

		cErrorMsg += "   What : Can't create the binary number." + NL
		cErrorMsg += "   Why  : Value you provided is not in a valid binary form." + NL
		cErrorMsg += "   Todo : Provide a value in a STRING formed of 0s and 1s and prefixed by " + BinaryNumberPrefix() + "."

	on :CanNotCreateBinaryNumber2
		cErrorMsg += "   What : Can't create the binary number." + NL
		cErrorMsg += "   Why  : Type of the value you provided is not valid." + NL
		cErrorMsg += "   Todo : Provide a value in a STRING formed of 0s and 1s and preceeded by " + BinaryNumberPrefix() + "."

	on :CanNotCreateBinaryNumberFromDecimalForm
		cErrorMsg += "   What : Can't create the binary number from a decimal form." + NL
		cErrorMsg += "   Why  : Value you provided to FromDecimal() method is not in a valid decimal form." + NL
		cErrorMsg += "   Todo : Provide a valid decimal NUMBER formed of decimal digits (0 to 9)."

	on :CanNotCreateBinaryNumberFromHexForm
		cErrorMsg += "   What : Can't create the binary number from a hexadecimal form." + NL
		cErrorMsg += "   Why  : Value you provided to FromHex() method is not in a valid hex form." + NL
		cErrorMsg += "   Todo : Provide a valid hex number in a STRING formed of hex characters (0 to 9 and A to F) preceeded by  " + HexNumberPrefix() + "."

	on :CanNotCreateBinaryNumberFromOctalForm
		cErrorMsg += "   What : Can't create the binary number from an octal form." + NL
		cErrorMsg += "   Why  : Value you provided to FromOctal() method is not in a valid octal form." + NL
		cErrorMsg += "   Todo : Provide a valid octal number in a STRING formed of octal digits (0 to 7) preceeded by  " + BinaryOctalPrefix() + "."

	off

	return cErrorMsg + NL
