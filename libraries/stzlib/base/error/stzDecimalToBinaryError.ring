func stzDecimalToBinaryError(pcError)
	_cErrorMsg_ = "in file stzDecimalToBinary.ring:" + NL

	switch pcError
	on :CanNotCreateDecimalNumberFromInvalidString
		_cErrorMsg_ += "   What : Can't create the decimal number." + NL
		_cErrorMsg_ += "   Why  : Value you provided for the number is not in a valid decimal form." + NL
		_cErrorMsg_ += "   Todo : Provide a string formed of digits from 0 to 9, separated by the dot decimal separator, and eventually prefixed by a - or + sign, and separated by underscores. "

	on :CanNotCreateDecimalNumberFromInvalidType
		_cErrorMsg_ += "   What : Can't create the decimal number." + NL
		_cErrorMsg_ += "   Why  : Value you provided for the number is not in a valid type." + NL
		_cErrorMsg_ += "   Todo : Provide a value in a STRING formed of digits from 0 to 9, separated by the dot decimal separator, and eventually containing a - or + sign, and separated by underscores. "

	off

	return _cErrorMsg_ + NL
