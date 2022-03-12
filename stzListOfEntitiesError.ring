func stzListOfEntitiesError(pcError)
	cErrorMsg = "in file stzListOfEntities.ring:" + NL
	switch pcError

	on :CanNotAddThisEntityTwice
		cErrorMsg += "   What : Can't add the same entity twice!" + NL
		cErrorMsg += "   Why  : The list already contains an entity with that name-and-type." + NL
		cErrorMsg += "   Todo : Provide an entity with a different name-and-type it will be fine ;)."

	on :CanNotAddNotAHashList
		cErrorMsg += "   What : Can't add the entity to the list!" + NL
		cErrorMsg += "   Why  : The value you provided is not a valid hashlist." + NL
		cErrorMsg += "   Todo : Provide a valid hashlist and it will be fine ;)."

	on :CanNotAddEntityWithoutName
		cErrorMsg += "   What : Can't add the entity to the list!" + NL
		cErrorMsg += "   Why  : The list you provided lacks the name property." + NL
		cErrorMsg += "   Todo : Provide name property and it will be fine ;)."


	off

	return cErrorMsg + NL
