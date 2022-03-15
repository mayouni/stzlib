func stzStringError(pcError)
	cErrorMsg = "in file stzString.ring:" + NL

	switch pcError
	on :UnsupportedParameter
		cErrorMsg += "   What : The parameter you provided is not supported." + NL
		cErrorMsg += "   Why  : The methods accepts a defined set of parameters." + NL
		cErrorMsg += "   Todo : Check the method code for the supported parameters."

	on :CanNotTransformQStringToString
		cErrorMsg += "   What : Can't transform the QString object to a Ring string." + NL
		cErrorMsg += "   Why  : The value you provided is not of type QString." + NL
		cErrorMsg += "   Todo : Provide a QString (using new QString() append(cStr) from RingQt) and it will be fine ;)"

	on :CanNotBoxTheString
		cErrorMsg += "   What : Can't set a box for the string!" + NL
		cErrorMsg += "   Why  : The parameter your provdided is not a valid Boxed Param List." + NL
		cErrorMsg += "   Todo : Provide a valid options list as showen in the example in the Boxed() function code."

	on :CanNotBoxTheListOfStrings
		cErrorMsg += "   What : Can't set a box for the strings of the list of strings!" + NL
		cErrorMsg += "   Why  : The parameter your provdided is not a valid Boxed Param List." + NL
		cErrorMsg += "   Todo : Provide a valid options list as showen in the example in the Boxed() function code."

	on :CanNotComputeNumberOfOccurrenceOfWord
		cErrorMsg += "   What : Can't compute the number of occurrence of word in the string!" + NL
		cErrorMsg += "   Why  : The parameter your provdided is not a valid word." + NL
		cErrorMsg += "   Todo : Provide a valid word and it will be fine ;)"

	on :IncorrectFormatOfCaseSensitiveParamList
		cErrorMsg += "   What : Incorrect format of the Casesensitive option list" + NL
		cErrorMsg += "   Why  : The parameter your provdided (pCaseSensitive) is not valid." + NL
		cErrorMsg += "   Todo : Provide a valid option list (:CaseSensitive = TRUE, for example) and try again ;)"

	on :CanNotGeneratePossibleWordInstances
		cErrorMsg += "   What : Can't generate the list of possible word instances" + NL
		cErrorMsg += "   Why  : The parameter your provdided (cWordPositionInSentence) is not correct." + NL
		cErrorMsg += "   Todo : Provide a valid cWordPositionInSentence option (:AtStartOfSentence, :AtEndOfSentence, or :InMiddleOfSentence)!"

	off

	return cErrorMsg + NL
