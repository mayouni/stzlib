func stzCharError(pcError)
	_cErrorMsg_ = "in file stzChar.ring:" + NL
	switch pcError

	on :CanNotCreateCharObjectForLongString
		_cErrorMsg_ += "   What : Can't create the character object!" + NL
		_cErrorMsg_ += "   Why  : The string you provided is not a char." + NL
		_cErrorMsg_ += "   Todo : Provide a string with only one char and it will be fine ;)."

	on :CanNotCreateCharObjectForThisType
		_cErrorMsg_ += "   What : Can't create the character object!" + NL
		_cErrorMsg_ += "   Why  : The type of the value you provided is not correct." + NL
		_cErrorMsg_ += "   Todo : Provide the character as a string or as decimal number corresponding to its unicode code point."

	on :CanNotGuessNumberOfBytes
		_cErrorMsg_ += "   What : Can't define the number of bytes for this character!" + NL
		_cErrorMsg_ += "   Why  : The decimal unicode value of the chracters must fit in the range [0,1114111]."
		_cErrorMsg_ += "   Todo : Provide a char with a valid unicode and it will be fine ;)"

	on :CanNotDefineUnicodeVersion
		_cErrorMsg_ += "   What : Can't define the unicode version of this character!" + NL
		_cErrorMsg_ += "   Why  : The number returned by the engine does not fit in the range of the _acUnicodeVersions global list." + NL
		_cErrorMsg_ += "   Todo : Verify if that list needs an update. If the engine returned 0, the data is unavailable."

	on :CanNotTransformCharToString
		_cErrorMsg_ += "   What : Can't transform the character to a Ring string!" + NL
		_cErrorMsg_ += "   Why  : The value you provided is not a valid character." + NL
		_cErrorMsg_ += "   Todo : Provide a valid character value."

	on :CanNotGetAsciiCodeForNonAsciiChar
		_cErrorMsg_ += "   What : Can't get ASCII code for this character!" + NL
		_cErrorMsg_ += "   Why  : The character you provided is not an ASCII character." + NL
		_cErrorMsg_ += "   Todo : Provide an ASCII character it will be fine ;)"

	off

	return _cErrorMsg_ + NL
