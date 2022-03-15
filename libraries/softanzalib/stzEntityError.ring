func stzEntityError(pcError)
	cErrorMsg = "in file stzEntity.ring:" + NL
	switch pcError

	on :CanNotCreateEntityObject
		cErrorMsg += "   What : Can't create the entity object!" + NL
		cErrorMsg += "   Why  : The list you provided is not a hashlist." + NL
		cErrorMsg += "   Todo : Provide a hashlist and it will be fine ;)."

	on :CanNotCreateEntityObjectWithoutName
		cErrorMsg += "   What : Can't create the entity object!" + NL
		cErrorMsg += "   Why  : The list you provided does not define a name property." + NL
		cErrorMsg += "   Todo : Provide a name property and it will be fine ;)."

	on :CanNotCreateEntityObjectWithIncorrectName
		cErrorMsg += "   What : Can't create the entity object!" + NL
		cErrorMsg += "   Why  : The name you provided is not a correct word." + NL
		cErrorMsg += "   Todo : Provide a correct word and it will be fine ;)."

	on :CanNotCreateEntityObjectWithIncorrectType
		cErrorMsg += "   What : Can't create the entity object!" + NL
		cErrorMsg += "   Why  : The type you provided is not a correct word." + NL
		cErrorMsg += "   Todo : Provide a correct word and it will be fine ;)."

	off

	return cErrorMsg + NL
