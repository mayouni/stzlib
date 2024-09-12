func stzListOfSetsError(pcError)
	cErrorMsg = "in file stzListOfSets.ring:" + NL

	switch pcError
	on :CanNotCreateListOfSets
		cErrorMsg += "   What : Can't create the list of sets." + NL
		cErrorMsg += "   Why  : All the items of the list you provided are not sets." + NL
		cErrorMsg += "   Todo : Be sure you are sending a list of sets."

	off

	return cErrorMsg
