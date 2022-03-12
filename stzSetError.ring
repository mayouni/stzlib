func stzSetError(pcError)
	cErrorMsg = "in file stzSetError.ring:" + NL

	switch pcError

	on :CanNotCreateSet
		cErrorMsg += "   What : Can't create the set!" + NL
		cErrorMsg += "   Why  : Value you provided is not in a valid list." + NL
		cErrorMsg += "   Todo : Provide a valid list and it will be fine ;)"

	on :CanNotUpdateSetWithNonSet
		cErrorMsg += "   What : Can't update the set!" + NL
		cErrorMsg += "   Why  : Value you provided is not in a valid set." + NL
		cErrorMsg += "   Todo : Provide a valid set and it will be fine ;)"

	on :CanNotComputeUnionWithNoSet
		cErrorMsg += "   What : Can't compute union!" + NL
		cErrorMsg += "   Why  : Value you provided is not in a valid set." + NL
		cErrorMsg += "   Todo : Provide a valid set and it will be fine ;)"

	on :CanNotComputeUnionWithNonSets
		cErrorMsg += "   What : Can't compute union!" + NL
		cErrorMsg += "   Why  : Value you provided is not in a valid list of sets." + NL
		cErrorMsg += "   Todo : Provide a valid list of sets and it will be fine ;)"

	off
