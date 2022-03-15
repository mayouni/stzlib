func stzListOfBytesError(pcError)
	cErrorMsg = "in file stzListOfBytes.ring:" + NL

	switch pcError
	on :CanNotCreateListOfBytes
		cErrorMsg += "   What : Can't create the list of bytes!" + NL
		cErrorMsg += "   Why  : The value you provided is not a string." + NL
		cErrorMsg += "   Todo : Send a string to the class constructor."

	on :CanNotReturnNthChar
		cErrorMsg += "   What : Can't return the n'th character!" + NL
		cErrorMsg += "   Why  : The list of bytes contains no characters." + NL
		cErrorMsg += "   Todo : Fill the list of bytes with some characters."

	on :CanNotTransformListOfBytesToPercentEncoding
		cErrorMsg += "   What : Can't transform the list of bytes to percent encoded string!" + NL
		cErrorMsg += "   Why  : The percent character is not an ASCII character." + NL
		cErrorMsg += "   Todo : Replace the percent character with an ASCII character."

	on :CanNotTransformPercentEncodingToListOfBytes
		cErrorMsg += "   What : Can't transform the percent encoded string to list of bytes!" + NL
		cErrorMsg += "   Why  : The percent character is not an ASCII character." + NL
		cErrorMsg += "   Todo : Replace the percent character with an ASCII character."

	on :CanNotSwapWithNonListOfBytes
		cErrorMsg += "   What : Can't swap this list of bytes with an other value!" + NL
		cErrorMsg += "   Why  : The value you provided is not a list of bytes." + NL
		cErrorMsg += "   Todo : Provide a valid list of bytes object (stzListOfBytes or QByteArray or a normal string) and it will be ok ;)"

	on :CanNotConvertQByteArray
		cErrorMsg += "   What : Can't transform this value!" + NL
		cErrorMsg += "   Why  : The value you provided is not a QByteArray object." + NL
		cErrorMsg += "   Todo : Provide a valid QByteArray object (with new QByteArray()) and it will be ok ;)"

	off

	return cErrorMsg + NL
