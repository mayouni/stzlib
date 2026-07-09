func stzListOfBytesError(pcError)
	_cErrorMsg_ = "in file stzListOfBytes.ring:" + NL

	switch pcError
	on :CanNotCreateListOfBytes
		_cErrorMsg_ += "   What : Can't create the list of bytes!" + NL
		_cErrorMsg_ += "   Why  : The value you provided is not a string." + NL
		_cErrorMsg_ += "   Todo : Send a string to the class constructor."

	on :CanNotReturnNthChar
		_cErrorMsg_ += "   What : Can't return the n'th character!" + NL
		_cErrorMsg_ += "   Why  : The list of bytes contains no characters." + NL
		_cErrorMsg_ += "   Todo : Fill the list of bytes with some characters."

	on :CanNotTransformListOfBytesToPercentEncoding
		_cErrorMsg_ += "   What : Can't transform the list of bytes to percent encoded string!" + NL
		_cErrorMsg_ += "   Why  : The percent character is not an ASCII character." + NL
		_cErrorMsg_ += "   Todo : Replace the percent character with an ASCII character."

	on :CanNotTransformPercentEncodingToListOfBytes
		_cErrorMsg_ += "   What : Can't transform the percent encoded string to list of bytes!" + NL
		_cErrorMsg_ += "   Why  : The percent character is not an ASCII character." + NL
		_cErrorMsg_ += "   Todo : Replace the percent character with an ASCII character."

	on :CanNotSwapWithNonListOfBytes
		_cErrorMsg_ += "   What : Can't swap this list of bytes with an other value!" + NL
		_cErrorMsg_ += "   Why  : The value you provided is not a list of bytes." + NL
		_cErrorMsg_ += "   Todo : Provide a valid list of bytes object (stzListOfBytes or QByteArray or a normal string) and it will be ok ;)"

	on :CanNotConvertQByteArray
		_cErrorMsg_ += "   What : Can't transform this value!" + NL
		_cErrorMsg_ += "   Why  : The value you provided is not a QByteArray object." + NL
		_cErrorMsg_ += "   Todo : Provide a valid QByteArray object (with new QByteArray()) and it will be ok ;)"

	off

	return _cErrorMsg_ + NL
