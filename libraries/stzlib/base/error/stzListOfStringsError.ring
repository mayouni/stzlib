func stzListOfStringsError(pcError)
	cErrorMsg = "in file stzListOfStrings.ring:" + NL

	switch pcError
	on :CanNotCreateListOfStrings
		cErrorMsg += "   What : Can't create the list of strings." + NL
		cErrorMsg += "   Why  : Items of the list you provided are not all strings." + NL
		cErrorMsg += "   Todo : Provide a list formed exclusively from strings."

	on :CanNotTransformQStringListToRingList
		cErrorMsg += "   What : Can't transform a QStringList object to a Ring list." + NL
		cErrorMsg += "   Why  : Parameter you provided is not a QStringList object." + NL
		cErrorMsg += "   Todo : Provide a QStringList and it will be fine ;)"

	on :CanNotBoxTheListOfStrings
		cErrorMsg += "   What : Can't set a box for the list of strings!" + NL
		cErrorMsg += "   Why  : The parameter your provdided is not a valid Boxed Param List." + NL
		cErrorMsg += "   Todo : Provide a valid options list as showen in the example in the Boxed() function code."

	off

	return cErrorMsg + NL
