func stzObjectError(pcError)
	cErrorMsg = "in file stzObject.ring:" + NL

	switch pcError
	on :CanNotComputeConstraint
		cErrorMsg += "   What : Can't compute the constraint." + NL
		cErrorMsg += "   Why  : Object param is not well formed." + NL
		cErrorMsg += "   Todo : Provide a well formed object param sutch as (:InObject = This) for example, and try again."

	off

	return cErrorMsg + NL
