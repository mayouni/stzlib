
func stzTextEncodingError(pcError)
	cErrorMsg = "in file stzTextEncoding.ring:" + char(10)

	switch pcError
	on :UnsupportedTextEncoding
		cErrorMsg += "   What : Can't create the text encoding." + char(10)
		cErrorMsg += "   Why  : Syntax error or Text encoding you provided is not supported." + char(10)
		cErrorMsg += "	 Todo : Verify the syntax of the name you provided in _aSupportedTextEncodings." + char(10)
	off

	return cErrorMsg
