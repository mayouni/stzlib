func stzObjectError(pcError)
	_cErrorMsg_ = "in file stzObject.ring:" + char(10)

	switch pcError
	on :CanNotComputeConstraint
		_cErrorMsg_ += "   What : Can't compute the constraint." + char(10)
		_cErrorMsg_ += "   Why  : Object param is not well formed." + char(10)
		_cErrorMsg_ += "   Todo : Provide a well formed object param sutch as (:InObject = This) for example, and try again."

	off

	return _cErrorMsg_ + char(10)
