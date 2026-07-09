func stzListOfCharsError(pcError)
	_cErrorMsg_ = "in file stzListOfChars.ring:" + NL

	switch pcError
	on :CanNotCreateListOfChars
		_cErrorMsg_ += "   What : Can't create the list of characters." + NL
		_cErrorMsg_ += "   Why  : Type of the value you provided is not supported." + NL
		_cErrorMsg_ += "   Todo : Provide a value of type STRING or LIST."

	on :CanNotBoxTheListOfChars
		_cErrorMsg_ += "   What : Can't set boxes around the chars in this list of chars!" + NL
		_cErrorMsg_ += "   Why  : The parameter your provdided is not a valid Boxed Param List." + NL
		_cErrorMsg_ += "   Todo : Provide a valid options list as showen in the example in the Boxed() function code."

	off

	return _cErrorMsg_ + NL
