func stzListOfEntitiesError(pcError)
	_cErrorMsg_ = "in file stzListOfEntities.ring:" + char(10)
	switch pcError

	on :CanNotAddThisEntityTwice
		_cErrorMsg_ += "   What : Can't add the same entity twice!" + char(10)
		_cErrorMsg_ += "   Why  : The list already contains an entity with that name-and-type." + char(10)
		_cErrorMsg_ += "   Todo : Provide an entity with a different name-and-type and it will be fine ;)."

	on :CanNotAddNotAHashList
		_cErrorMsg_ += "   What : Can't add the entity to the list!" + char(10)
		_cErrorMsg_ += "   Why  : The value you provided is not a valid hashlist." + char(10)
		_cErrorMsg_ += "   Todo : Provide a valid hashlist and it will be fine ;)."

	on :CanNotAddEntityWithoutName
		_cErrorMsg_ += "   What : Can't add the entity to the list!" + char(10)
		_cErrorMsg_ += "   Why  : The list you provided lacks the name property." + char(10)
		_cErrorMsg_ += "   Todo : Provide name property and it will be fine ;)."


	off

	return _cErrorMsg_ + char(10)
