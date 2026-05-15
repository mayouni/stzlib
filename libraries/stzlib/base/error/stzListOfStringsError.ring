func stzListOfStringsError(pcError)
	cErrorMsg = "in file stzListOfStrings.ring:" + NL

	switch pcError
	on :CanNotCreateListOfStrings
		cErrorMsg += "   What : Can't create the list of strings." + NL
		cErrorMsg += "   Why  : Items of the list you provided are not all strings." + NL
		cErrorMsg += "   Todo : Provide a list formed exclusively from strings."

	on :CanNotTransformStringListToRingList
		cErrorMsg += "   What : Can't transform a string list to a Ring list." + NL
		cErrorMsg += "   Why  : Parameter you provided is not a valid string list." + NL
		cErrorMsg += "   Todo : Provide a valid list of strings."

	on :CanNotBoxTheListOfStrings
		cErrorMsg += "   What : Can't set a box for the list of strings!" + NL
		cErrorMsg += "   Why  : The parameter your provdided is not a valid Boxed Param List." + NL
		cErrorMsg += "   Todo : Provide a valid options list as showen in the example in the Boxed() function code."

	off

	return cErrorMsg + NL
