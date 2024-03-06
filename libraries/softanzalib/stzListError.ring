func stzListError(pcError)
	cErrorMsg = "in file stzList.ring:" + NL

	switch pcError
	on :CanNotCompareOrderOfItems
		cErrorMsg += "   What : Can't compare items of the two lists!" + NL
		cErrorMsg += "   Why  : Only strings and numbers are comparable." + NL
		cErrorMsg += "   Todo : Provide lists formed exclusively of numbers and strings."

	on :CanNotCompareContent
		cErrorMsg += "   What : Can't compare content of the two lists!" + NL
		cErrorMsg += "   Why  : Only strings and numbers are comparable." + NL
		cErrorMsg += "   Todo : Provide lists formed exclusively of numbers and strings."

	on :CanNotVerifyALanguageIdendificationList
		cErrorMsg += "   What : Can't verify that the list is a Language Idenification List!" + NL
		cErrorMsg += "   Why  : The list is not a well formed Language Identification List." + NL
		cErrorMsg += '   Todo : Provide a hash list of the form [ :Language = "...", :Country = "...", :Script = "..." ].'

	on :UnsupportedLanguageNameOrAbbreviation
		cErrorMsg += "   What : Unsupported language name or abbreviation!." + NL
		cErrorMsg += "   Why  : the string you provided is not a language name or abbreviation." + NL
		cErrorMsg += "   Todo : Provide a supported language name or abbreviation as defined in LocaleLanguagesXT()."
	
	on :CanNotProvideStringInThatLanguage
		cErrorMsg += "   What : Can't provide a string translation in the requested language!" + NL
		cErrorMsg += "   Why  : The string translation is not defined for that language." + NL
		cErrorMsg += "   Todo : Provide an entry in the multilingual string hashlit for that language."
	
	on :CanNotApplyCodeToThisTypeOfItems
		cErrorMsg += "   What : Can't apply code to this type of items!" + NL
		cErrorMsg += "   Why  : The type of items you provided is not supported." + NL
		cErrorMsg += "   Todo : Provide a valid type of item (:ToNumbers, :ToStrings, etc.)."

	on :CanNotProcessMethodCall
		cErrorMsg += "   What : Can't process the method call on these objects!" + NL
		cErrorMsg += "   Why  : Eigther the call is not correct or the list is not a list of objects." + NL
		cErrorMsg += "   Todo : Provide a valid syntax and a list of objects for which the method exists and it will be fine ;)"

	on :CanNoteDistributeItemsOverTheList1
		cErrorMsg += "   What : Can't distribute the items of the main list over the items of the provided list!" + NL
		cErrorMsg += "   Why  : All items of the provided list (acBeneficiaryItems) must be strings (because the output is a hashlist)." + NL
		cErrorMsg += "   Todo : Provide a valid list containing only strings and try again ;)"

	on :CanNoteDistributeItemsOverTheList2
		cErrorMsg += "   What : Can't distribute the items of the main list over the items of the provided list!" + NL
		cErrorMsg += "   Why  : Sum of items to be distributed (in anShareOfEachItem) must be equal to number of items of the main list." + NL
		cErrorMsg += "   Todo : Provide a share list where the sum of its items is equal to the number of items of the list."

	on :InvalidFormatOfListDefiningShareOfEachItem
		cErrorMsg += "   What : Invalid format of the list defining the share of each item!" + NL
		cErrorMsg += "   Why  : The list defining the share of each item should take the form :Using = [ 2, 3, 5 ] for example." + NL
		cErrorMsg += "   Todo : Provide a valid syntax for the share list and try again ;)"

	on :CanNotFlattenThisList
		cErrorMsg += "   What : Can not flatten this list!" + NL
		cErrorMsg += "   Why  : The list contains object(s) and objects can not be flattened." + NL
		cErrorMsg += "   Todo : Provide a list without any object, at any level, and try again ;)"

	on :CanNotExtendTheList " because n < NumberOfItems()!"
		cErrorMsg += "   What : Can't extend the list to the provided position!" + NL
		cErrorMsg += "   Why  : The position you provide should be greater then the list number of items." + NL
		cErrorMsg += "   Todo : Provide a position greater then the list number of items, and try again ;)"

	on :CanNotAddWalkerAlreadyExistant
		cErrorMsg += "   What : Can't add the walker!" + NL
		cErrorMsg += "   Why  : The name you provided to the walker already exists." + NL
		cErrorMsg += "   Todo : Provide a new name (not in This.Walkers() ) and everything will be ok ;)"

	on :UnsupportedExpressionInOverloadedMinusOperator
		cErrorMsg += "   What : Unsupported expression in the overloaded Minus (-) Operator!" + NL
		cErrorMsg += "   Why  : Only a specified set of operators are supported." + NL
		cErrorMsg += "   Todo : See 'OPERATOR OVERLOADING' section in stzList class.."

	on :CanNotVerify@IsMadeOfProvidedItems
		cErrorMsg += "   What : Can't verify if list is made of a set of provided items!" + NL
		cErrorMsg += "   Why  : Eighter you didn't provide a list at all, or the list you provided contains duplicated items." + NL
		cErrorMsg += "   Todo : Provide a list containing no duplicated items and try again."

	off

	return cErrorMsg + NL
