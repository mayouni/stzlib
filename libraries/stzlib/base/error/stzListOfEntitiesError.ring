func stzListOfEntitiesError(pcError)
	_cErrorMsg_ = "in file stzListOfEntities.ring:" + NL
	switch pcError

	on :CanNotAddThisEntityTwice
		_cErrorMsg_ += "   What : Can't add the same entity twice!" + NL
		_cErrorMsg_ += "   Why  : The list already contains an entity with that name-and-type." + NL
		_cErrorMsg_ += "   Todo : Provide an entity with a different name-and-type and it will be fine ;)."

	on :CanNotAddNotAHashList
		_cErrorMsg_ += "   What : Can't add the entity to the list!" + NL
		_cErrorMsg_ += "   Why  : The value you provided is not a valid hashlist." + NL
		_cErrorMsg_ += "   Todo : Provide a valid hashlist and it will be fine ;)."

	on :CanNotAddEntityWithoutName
		_cErrorMsg_ += "   What : Can't add the entity to the list!" + NL
		_cErrorMsg_ += "   Why  : The list you provided lacks the name property." + NL
		_cErrorMsg_ += "   Todo : Provide name property and it will be fine ;)."


	off

	return _cErrorMsg_ + NL
