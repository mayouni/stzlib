func stzListOfCharsError(pcError)
	cErrorMsg = "in file stzListOfChars.ring:" + NL

	switch pcError
	on :CanNotCreateListOfChars
		cErrorMsg += "   What : Can't create the list of characters." + NL
		cErrorMsg += "   Why  : Type of the value you provided is not supported." + NL
		cErrorMsg += "   Todo : Provide a value of type STRING or LIST."

	on :CanNotBoxTheListOfChars
		cErrorMsg += "   What : Can't set boxes around the chars in this list of chars!" + NL
		cErrorMsg += "   Why  : The parameter your provdided is not a valid Boxed Param List." + NL
		cErrorMsg += "   Todo : Provide a valid options list as showen in the example in the Boxed() function code."

	off

	return cErrorMsg + NL
