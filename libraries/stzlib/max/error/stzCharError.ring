func stzCharError(pcError)
	cErrorMsg = "in file stzChar.ring:" + NL
	switch pcError

	on :CanNotCreateCharObjectForLongString
		cErrorMsg += "   What : Can't create the character object!" + NL
		cErrorMsg += "   Why  : The string you provided is not a char." + NL
		cErrorMsg += "   Todo : Provide a string with only one char and it will be fine ;)."

	on :CanNotCreateCharObjectForThisType
		cErrorMsg += "   What : Can't create the character object!" + NL
		cErrorMsg += "   Why  : The type of the value you provided is not correct." + NL
		cErrorMsg += "   Todo : Provide the character as a string or as decimal number corresponding to its unicode code point."

	on :CanNotGuessNumberOfBytes
		cErrorMsg += "   What : Can't define the number of bytes for this character!" + NL
		cErrorMsg += "   Why  : The decimal unicode value of the chracters must fit in the range [0,1114111]."
		cErrorMsg += "   Todo : Provide a char with a valid unicode and it will be fine ;)"

	on :CanNotDefineUnicodeVersion
		cErrorMsg += "   What : Can't define the unicode version of this character!" + NL
		cErrorMsg += "   Why  : The number return by Qt does'nt fit in the range of the _acUnicodeVersions global list." + NL
		cErrorMsg += "   Todo : Verify if that list needs an update. But if Qt returned 0, then even Qt can't help."

	on :CanNotTransformQCharToString
		cErrorMsg += "   What : Can't transform the QChar object to a Ring string!" + NL
		cErrorMsg += "   Why  : The value you provided is not an object of type QChar." + NL
		cErrorMsg += "   Todo : Provide a QChar and it will be fine ;)"

	on :CanNotGetAsciiCodeForNonAsciiChar
		cErrorMsg += "   What : Can't get ASCII code for this character!" + NL
		cErrorMsg += "   Why  : The character you provided is not an ASCII character." + NL
		cErrorMsg += "   Todo : Provide an ASCII character it will be fine ;)"

	off

	return cErrorMsg + NL
