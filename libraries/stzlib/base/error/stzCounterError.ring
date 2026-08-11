func stzCounterError(pcError)
	_cErrorMsg_ = "in file stzCounter.ring:" + char(10)

	switch pcError
	on :CanNotCreateCounter
		_cErrorMsg_ += "   What : Can't create the Counter object!" + char(10)
		_cErrorMsg_ += "   Why  : The options list you provided is not well formed." + char(10)
		_cErrorMsg_ += "   Todo : Provide a well formed list as defined in the method signature." + char(10)

	off

	return _cErrorMsg_
