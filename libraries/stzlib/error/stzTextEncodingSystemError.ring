
func stzTextEncodingError(pcError)
	cErrorMsg = "in file stzTextEncoding.ring:" + NL

	switch pcError
	on :UnsupportedTextEncoding
		cErrorMsg += "   What : Can't create the text encoding." + NL
		cErrorMsg += "   Why  : Syntax error or Text encoding you provided is not supported." + NL
		cErrorMsg += "	 Todo : Verify the syntax of the name you provided in _aSupportedTextEncodings." + NL
	off

	return cErrorMsg
