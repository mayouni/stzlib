func stzObjectError(pcError)
	_cErrorMsg_ = "in file stzObject.ring:" + NL

	switch pcError
	on :CanNotComputeConstraint
		_cErrorMsg_ += "   What : Can't compute the constraint." + NL
		_cErrorMsg_ += "   Why  : Object param is not well formed." + NL
		_cErrorMsg_ += "   Todo : Provide a well formed object param sutch as (:InObject = This) for example, and try again."

	off

	return _cErrorMsg_ + NL
