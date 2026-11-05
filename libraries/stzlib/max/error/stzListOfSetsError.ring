func stzListOfSetsError(pcError)
	cErrorMsg = "in file stzListOfSets.ring:" + char(10)

	switch pcError
	on :CanNotCreateListOfSets
		cErrorMsg += "   What : Can't create the list of sets." + char(10)
		cErrorMsg += "   Why  : All the items of the list you provided are not sets." + char(10)
		cErrorMsg += "   Todo : Be sure you are sending a list of sets."

	off

	return cErrorMsg
