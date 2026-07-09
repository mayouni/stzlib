func stzStringError(pcError)
	_cErrorMsg_ = "in file stzString.ring:" + NL

	switch pcError
	on :UnsupportedParameter
		_cErrorMsg_ += "   What : The parameter you provided is not supported." + NL
		_cErrorMsg_ += "   Why  : The methods accepts a defined set of parameters." + NL
		_cErrorMsg_ += "   Todo : Check the method code for the supported parameters."

	on :CanNotTransformToString
		_cErrorMsg_ += "   What : Can't transform the value to a Ring string." + NL
		_cErrorMsg_ += "   Why  : The value you provided is not a valid string type." + NL
		_cErrorMsg_ += "   Todo : Provide a valid Ring string and it will be fine ;)"

	on :CanNotBoxTheString
		_cErrorMsg_ += "   What : Can't set a box for the string!" + NL
		_cErrorMsg_ += "   Why  : The parameter your provdided is not a valid Boxed Param List." + NL
		_cErrorMsg_ += "   Todo : Provide a valid options list as showen in the example in the Boxed() function code."

	on :CanNotBoxTheListOfStrings
		_cErrorMsg_ += "   What : Can't set a box for the strings of the list of strings!" + NL
		_cErrorMsg_ += "   Why  : The parameter your provdided is not a valid Boxed Param List." + NL
		_cErrorMsg_ += "   Todo : Provide a valid options list as showen in the example in the Boxed() function code."

	on :CanNotComputeNumberOfOccurrenceOfWord
		_cErrorMsg_ += "   What : Can't compute the number of occurrence of word in the string!" + NL
		_cErrorMsg_ += "   Why  : The parameter your provdided is not a valid word." + NL
		_cErrorMsg_ += "   Todo : Provide a valid word and it will be fine ;)"

	on :IncorrectFormatOfCaseSensitiveParamList
		_cErrorMsg_ += "   What : Incorrect format of the Casesensitive option list" + NL
		_cErrorMsg_ += "   Why  : The parameter your provdided (pCaseSensitive) is not valid." + NL
		_cErrorMsg_ += "   Todo : Provide a valid option list (TRUE, for example) and try again ;)"

	on :CanNotGeneratePossibleWordInstances
		_cErrorMsg_ += "   What : Can't generate the list of possible word instances" + NL
		_cErrorMsg_ += "   Why  : The parameter your provdided (cWordPositionInSentence) is not correct." + NL
		_cErrorMsg_ += "   Todo : Provide a valid cWordPositionInSentence option (:AtStartOfSentence, :AtEndOfSentence, or :InMiddleOfSentence)!"

	off

	return _cErrorMsg_ + NL
