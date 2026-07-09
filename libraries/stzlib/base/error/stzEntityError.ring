func stzEntityError(pcError)
	_cErrorMsg_ = "in file stzEntity.ring:" + NL
	switch pcError

	on :CanNotCreateEntityObject
		_cErrorMsg_ += "   What : Can't create the entity object!" + NL
		_cErrorMsg_ += "   Why  : The list you provided is not a hashlist." + NL
		_cErrorMsg_ += "   Todo : Provide a hashlist and it will be fine ;)."

	on :CanNotCreateEntityObjectWithoutName
		_cErrorMsg_ += "   What : Can't create the entity object!" + NL
		_cErrorMsg_ += "   Why  : The list you provided does not define a name property." + NL
		_cErrorMsg_ += "   Todo : Provide a name property and it will be fine ;)."

	on :CanNotCreateEntityObjectWithIncorrectName
		_cErrorMsg_ += "   What : Can't create the entity object!" + NL
		_cErrorMsg_ += "   Why  : The name you provided is not a correct word." + NL
		_cErrorMsg_ += "   Todo : Provide a correct word and it will be fine ;)."

	on :CanNotCreateEntityObjectWithIncorrectType
		_cErrorMsg_ += "   What : Can't create the entity object!" + NL
		_cErrorMsg_ += "   Why  : The type you provided is not a correct word." + NL
		_cErrorMsg_ += "   Todo : Provide a correct word and it will be fine ;)."

	off

	return _cErrorMsg_ + NL
