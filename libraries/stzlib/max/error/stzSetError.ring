func stzSetError(pcError)
	cErrorMsg = "in file stzSetError.ring:" + char(10)

	switch pcError

	on :CanNotCreateSet
		cErrorMsg += "   What : Can't create the set!" + char(10)
		cErrorMsg += "   Why  : Value you provided is not in a valid list." + char(10)
		cErrorMsg += "   Todo : Provide a valid list and it will be fine ;)"

	on :CanNotUpdateSetWithNonSet
		cErrorMsg += "   What : Can't update the set!" + char(10)
		cErrorMsg += "   Why  : Value you provided is not in a valid set." + char(10)
		cErrorMsg += "   Todo : Provide a valid set and it will be fine ;)"

	on :CanNotComputeUnionWithNoSet
		cErrorMsg += "   What : Can't compute union!" + char(10)
		cErrorMsg += "   Why  : Value you provided is not in a valid set." + char(10)
		cErrorMsg += "   Todo : Provide a valid set and it will be fine ;)"

	on :CanNotComputeUnionWithNonSets
		cErrorMsg += "   What : Can't compute union!" + char(10)
		cErrorMsg += "   Why  : Value you provided is not in a valid list of sets." + char(10)
		cErrorMsg += "   Todo : Provide a valid list of sets and it will be fine ;)"

	off
