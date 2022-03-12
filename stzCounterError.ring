func stzCounterError(pcError)
	cErrorMsg = "in file stzCounter.ring:" + NL

	switch pcError
	on :CanNotCreateCounter
		cErrorMsg += "   What : Can't create the Counter object!" + NL
		cErrorMsg += "   Why  : The options list you provided is not well formed." + NL
		cErrorMsg += "   Todo : Provide a well formed list as defined in the method signature."

	off

	return cErrorMsg + NL
