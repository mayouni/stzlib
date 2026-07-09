func stzCounterError(pcError)
	_cErrorMsg_ = "in file stzCounter.ring:" + NL

	switch pcError
	on :CanNotCreateCounter
		_cErrorMsg_ += "   What : Can't create the Counter object!" + NL
		_cErrorMsg_ += "   Why  : The options list you provided is not well formed." + NL
		_cErrorMsg_ += "   Todo : Provide a well formed list as defined in the method signature." + NL

	off

	return _cErrorMsg_
