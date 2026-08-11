func stzListOfStringsError(pcError)
	_cErrorMsg_ = "in file stzListOfStrings.ring:" + char(10)

	switch pcError
	on :CanNotCreateListOfStrings
		_cErrorMsg_ += "   What : Can't create the list of strings." + char(10)
		_cErrorMsg_ += "   Why  : Items of the list you provided are not all strings." + char(10)
		_cErrorMsg_ += "   Todo : Provide a list formed exclusively from strings."

	on :CanNotTransformStringListToRingList
		_cErrorMsg_ += "   What : Can't transform a string list to a Ring list." + char(10)
		_cErrorMsg_ += "   Why  : Parameter you provided is not a valid string list." + char(10)
		_cErrorMsg_ += "   Todo : Provide a valid list of strings."

	on :CanNotBoxTheListOfStrings
		_cErrorMsg_ += "   What : Can't set a box for the list of strings!" + char(10)
		_cErrorMsg_ += "   Why  : The parameter your provdided is not a valid Boxed Param List." + char(10)
		_cErrorMsg_ += "   Todo : Provide a valid options list as showen in the example in the Boxed() function code."

	off

	return _cErrorMsg_ + char(10)
