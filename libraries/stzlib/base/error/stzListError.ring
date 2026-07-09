func stzListError(pcError)
	_cErrorMsg_ = "in file stzList.ring:" + NL

	switch pcError
	on :CanNotCompareOrderOfItems
		_cErrorMsg_ += "   What : Can't compare items of the two lists!" + NL
		_cErrorMsg_ += "   Why  : Only strings and numbers are comparable." + NL
		_cErrorMsg_ += "   Todo : Provide lists formed exclusively of numbers and strings."

	on :CanNotCompareContent
		_cErrorMsg_ += "   What : Can't compare content of the two lists!" + NL
		_cErrorMsg_ += "   Why  : Only strings and numbers are comparable." + NL
		_cErrorMsg_ += "   Todo : Provide lists formed exclusively of numbers and strings."

	on :CanNotVerifyALanguageIdendificationList
		_cErrorMsg_ += "   What : Can't verify that the list is a Language Idenification List!" + NL
		_cErrorMsg_ += "   Why  : The list is not a well formed Language Identification List." + NL
		_cErrorMsg_ += '   Todo : Provide a hash list of the form [ :Language = "...", :Country = "...", :Script = "..." ].'

	on :UnsupportedLanguageNameOrAbbreviation
		_cErrorMsg_ += "   What : Unsupported language name or abbreviation!." + NL
		_cErrorMsg_ += "   Why  : the string you provided is not a language name or abbreviation." + NL
		_cErrorMsg_ += "   Todo : Provide a supported language name or abbreviation as defined in LocaleLanguagesXT()."
	
	on :CanNotProvideStringInThatLanguage
		_cErrorMsg_ += "   What : Can't provide a string translation in the requested language!" + NL
		_cErrorMsg_ += "   Why  : The string translation is not defined for that language." + NL
		_cErrorMsg_ += "   Todo : Provide an entry in the multilingual string hashlit for that language."
	
	on :CanNotApplyCodeToThisTypeOfItems
		_cErrorMsg_ += "   What : Can't apply code to this type of items!" + NL
		_cErrorMsg_ += "   Why  : The type of items you provided is not supported." + NL
		_cErrorMsg_ += "   Todo : Provide a valid type of item (:ToNumbers, :ToStrings, etc.)."

	on :CanNotProcessMethodCall
		_cErrorMsg_ += "   What : Can't process the method call on these objects!" + NL
		_cErrorMsg_ += "   Why  : Eigther the call is not correct or the list is not a list of objects." + NL
		_cErrorMsg_ += "   Todo : Provide a valid syntax and a list of objects for which the method exists and it will be fine ;)"

	on :CanNoteDistributeItemsOverTheList1
		_cErrorMsg_ += "   What : Can't distribute the items of the main list over the items of the provided list!" + NL
		_cErrorMsg_ += "   Why  : All items of the provided list (acBeneficiaryItems) must be strings (because the output is a hashlist)." + NL
		_cErrorMsg_ += "   Todo : Provide a valid list containing only strings and try again ;)"

	on :CanNoteDistributeItemsOverTheList2
		_cErrorMsg_ += "   What : Can't distribute the items of the main list over the items of the provided list!" + NL
		_cErrorMsg_ += "   Why  : Sum of items to be distributed (in anShareOfEachItem) must be equal to number of items of the main list." + NL
		_cErrorMsg_ += "   Todo : Provide a share list where the sum of its items is equal to the number of items of the list."

	on :InvalidFormatOfListDefiningShareOfEachItem
		_cErrorMsg_ += "   What : Invalid format of the list defining the share of each item!" + NL
		_cErrorMsg_ += "   Why  : The list defining the share of each item should take the form :Using = [ 2, 3, 5 ] for example." + NL
		_cErrorMsg_ += "   Todo : Provide a valid syntax for the share list and try again ;)"

	on :CanNotFlattenThisList
		_cErrorMsg_ += "   What : Can not flatten this list!" + NL
		_cErrorMsg_ += "   Why  : The list contains object(s) and objects can not be flattened." + NL
		_cErrorMsg_ += "   Todo : Provide a list without any object, at any level, and try again ;)"

	on :CanNotExtendTheList " because n < NumberOfItems()!"
		_cErrorMsg_ += "   What : Can't extend the list to the provided position!" + NL
		_cErrorMsg_ += "   Why  : The position you provide should be greater then the list number of items." + NL
		_cErrorMsg_ += "   Todo : Provide a position greater then the list number of items, and try again ;)"

	on :CanNotAddWalkerAlreadyExistant
		_cErrorMsg_ += "   What : Can't add the walker!" + NL
		_cErrorMsg_ += "   Why  : The name you provided to the walker already exists." + NL
		_cErrorMsg_ += "   Todo : Provide a new name (not in This.Walkers() ) and everything will be ok ;)"

	on :UnsupportedExpressionInOverloadedMinusOperator
		_cErrorMsg_ += "   What : Unsupported expression in the overloaded Minus (-) Operator!" + NL
		_cErrorMsg_ += "   Why  : Only a specified set of operators are supported." + NL
		_cErrorMsg_ += "   Todo : See 'OPERATOR OVERLOADING' section in stzList class.."

	on :CanNotVerify@IsMadeOfProvidedItems
		_cErrorMsg_ += "   What : Can't verify if list is made of a set of provided items!" + NL
		_cErrorMsg_ += "   Why  : Eighter you didn't provide a list at all, or the list you provided contains duplicated items." + NL
		_cErrorMsg_ += "   Todo : Provide a list containing no duplicated items and try again."

	off

	return _cErrorMsg_ + NL
