#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTCHECKER             #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List checker subclass -- type checking,     #
#                  validation, equality, comparison.            #
#                  For aliases, use stzListCheckerXT.           #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

# Answers yes or no questions about a list: what its items are made of, whether they are unique, ordered, equal or paired.
#
# Reach for it to validate a list before using it: AllItemsAreOfType and the IsListOf... family
# check the type of the items, IsMonotonic and the strict variants check their order, IsHashList and
# IsListOfPairs check the shape, and HasMoreNumberOfItems compares the length with another list.
# Most checks answer 1 or 0, a few answer TRUE or FALSE; both work in an if. A check made on the
# empty list is true for IsListOfNumbers, IsListOfStrings and AllItemsAreEqual, and false for
# IsListOfLists. ContainsItem, ContainsAllOfThese and ContainsOneOfThese look for numbers, texts and
# lists whole; ContainsW asks the engine's W language whether some item meets a condition.
#
#   receiver   o1 = new stzListChecker([3, 1, 2])
#   example    ? o1.IsListOfNumbers()
#              #--> 1
#              ? o1.IsMonotonic()
#              #--> 0
#              ? o1.IsEqualTo([3, 1, 2])
#              #--> 1
#              ? o1.HasMoreNumberOfItems([1])
#              #--> 1
#   see        stzList, stzListFinder
class stzListChecker from stzObject

	@oList

	  #===================#
	 #   INITIALIZATION  #
	#===================#

	# Builds a checker over a list or over a stzList object; anything else raises an error.
	#
	#   pListOrObj   a list, or a stzList object, to be checked
	#   returns      nothing; the object is built
	#   note         a list is wrapped in a new stzList; the error text is Can't create
	#                stzListChecker! Parameter must be a list or stzList object.
	#   see          Content, NumberOfItems
	def init(pListOrObj)
		if isList(pListOrObj)
			@oList = new stzList(pListOrObj)
		but isObject(pListOrObj)
			@oList = pListOrObj
		else
			StzRaise("Can't create stzListChecker! Parameter must be a list or stzList object.")
		ok

	  #===============================#
	 #     CONTENT ACCESS            #
	#===============================#

	# Returns the list being checked.
	#
	#   returns    a list
	#   see        NumberOfItems
	def Content()
		return @oList.Content()

	# Returns how many items the checked list has.
	#
	#   returns    a number
	#   see        Content, IsEmpty
	def NumberOfItems()
		return @oList.NumberOfItems()

	  #======================================#
	 #  CHECKING LIST TYPE COMPOSITION     #
	#======================================#

	# Returns 1 if every item is a number, else 0.
	#
	#   returns    1 or 0
	#   note       the empty list answers 1; the answer is a number, not TRUE or FALSE
	#   see        IsListOfStrings, IsListOfDecimalNumbers, AllItemsAreOfType
	def IsListOfNumbers()
		_pList_ = @oList._EngineListFromContent()
		_nResult_ = StzEngineListIsAllNumbers(_pList_)
		StzEngineListFree(_pList_)
		return _nResult_

	# Returns 1 if every item is a text, else 0.
	#
	#   returns    1 or 0
	#   note       the empty list answers 1
	#   see        IsListOfNumbers, AllItemsAreOfType
	def IsListOfStrings()
		_pList_ = @oList._EngineListFromContent()
		_nResult_ = StzEngineListIsAllStrings(_pList_)
		StzEngineListFree(_pList_)
		return _nResult_

	# Returns 1 if every item is a list, else 0.
	#
	#   returns    1 or 0
	#   note       unlike IsListOfNumbers the empty list answers 0
	#   see        IsListOfListsOfSameSize, IsListOfPairs
	def IsListOfLists()
		_pList_ = @oList._EngineListFromContent()
		_nResult_ = StzEngineListIsAllLists(_pList_)
		StzEngineListFree(_pList_)
		return _nResult_

		def AllItemsAreLists()
			return This.IsListOfLists()

		def ContainsOnlyLists()
			return This.IsListOfLists()

	# Returns 1 if every item is a list and all of them have the same length, else 0.
	#
	#   returns    1 or 0
	#   note       [[1,2],[3,4]] answers 1 and [[1,2],[3]] answers 0
	#   see        IsListOfLists, IsListOfPairs
	def IsListOfListsOfSameSize()
		_pList_ = @oList._EngineListFromContent()
		_nResult_ = StzEngineListIsAllListsSameSize(_pList_)
		StzEngineListFree(_pList_)
		return _nResult_

		def ItemsAreListsOfSameSize()
			return This.IsListOfListsOfSameSize()

		def AllItemsAreListsOfSameSize()
			return This.IsListOfListsOfSameSize()

	# Returns 1 if every item is an object, else 0.
	#
	#   returns    1 or 0
	#   note       the empty list answers 1
	#   see        IsListOfLists, AllItemsAreOfType
	def IsListOfObjects()
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		for i = 1 to _nLen_
			if NOT isObject(_aContent_[i])
				return 0
			ok
		next

		return 1

	  #==============================#
	 #  MIXED TYPE CHECKING        #
	#==============================#

	# Returns 1 if the items are not all of one type, else 0.
	#
	#   returns    1 or 0
	#   note       the empty list and a list of one type answer 0
	#   see        AllItemsAreOfType, IsListOfNumbers
	def IsHybrid()
		_pList_ = @oList._EngineListFromContent()
		_nResult_ = StzEngineListIsHybrid(_pList_)
		StzEngineListFree(_pList_)
		return _nResult_

		def IsHybridList()
			return This.IsHybrid()

	# Returns 1 if every item has the given type, else 0; the type can also be a list of items of a type, such as :ListOfNumbers.
	#
	#   pcType     the type: :Number, :String, :List, :Object, their plurals, or :ListOfNumbers,
	#              :ListOfStrings, :ListOfChars, :ListOfLists, :ListOfObjects
	#   returns    1 or 0
	#   note       the empty list answers 1 for every type; :ListOfChars wants every inner item to
	#              be a one-character text
	#   see        ContainsOnly, IsListOfNumbers, IsHybrid
	def AllItemsAreOfType(pcType)
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		# Normalize the type name to Ring's type() vocabulary (NUMBER / STRING /
		# LIST / OBJECT): accept the plural forms (:Numbers, :Strings, ...).
		_cT_ = StzUpper("" + pcType)
		if _cT_ = "NUMBERS" _cT_ = "NUMBER" ok
		if _cT_ = "STRINGS" _cT_ = "STRING" ok
		if _cT_ = "LISTS"   _cT_ = "LIST"   ok
		if _cT_ = "OBJECTS" _cT_ = "OBJECT" ok

		# Compound "list of <type>" checks: every item must itself be a list
		# whose elements are all of the inner type. A "char" is a single-
		# codepoint string. Accept :ListOfNumbers / :ListsOfNumbers / singular.
		_cInner_ = ""
		if _cT_ = "LISTOFNUMBERS" or _cT_ = "LISTSOFNUMBERS" or _cT_ = "LISTOFNUMBER"
			_cInner_ = "NUMBER"
		but _cT_ = "LISTOFSTRINGS" or _cT_ = "LISTSOFSTRINGS" or _cT_ = "LISTOFSTRING"
			_cInner_ = "STRING"
		but _cT_ = "LISTOFCHARS" or _cT_ = "LISTSOFCHARS" or _cT_ = "LISTOFCHAR"
			_cInner_ = "CHAR"
		but _cT_ = "LISTOFLISTS" or _cT_ = "LISTSOFLISTS" or _cT_ = "LISTOFLIST"
			_cInner_ = "LIST"
		but _cT_ = "LISTOFOBJECTS" or _cT_ = "LISTSOFOBJECTS" or _cT_ = "LISTOFOBJECT"
			_cInner_ = "OBJECT"
		ok

		if _cInner_ != ""
			for i = 1 to _nLen_
				_xItem_ = _aContent_[i]
				if NOT isList(_xItem_)
					return 0
				ok
				_nInner_ = len(_xItem_)
				for j = 1 to _nInner_
					_yElem_ = _xItem_[j]
					if _cInner_ = "CHAR"
						if NOT ( isString(_yElem_) and StzLen(_yElem_) = 1 )
							return 0
						ok
					else
						if ring_type(_yElem_) != _cInner_
							return 0
						ok
					ok
				next
			next
			return 1
		ok

		for i = 1 to _nLen_
			if ring_type(_aContent_[i]) != _cT_
				return 0
			ok
		next

		return 1

	  #==============================#
	 #  NUMBER SUBTYPE CHECKING    #
	#==============================#

	# Returns 1 if every item is a number, whole or decimal, else 0.
	#
	#   returns    1 or 0
	#   note       it is the same test as IsListOfNumbers in effect: whole numbers pass too
	#   see        IsListOfNumbers
	def IsListOfDecimalNumbers()
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		for i = 1 to _nLen_
			if NOT isNumber(_aContent_[i])
				return 0
			ok
		next

		return 1

	  #==============================#
	 #  STRING SUBTYPE CHECKING    #
	#==============================#

	# Returns 1 if every item is a list of exactly two items, whatever they are, else 0.
	#
	#   returns    1 or 0
	#   note       [[1,"a"]] answers 1; the empty list answers 0
	#   see        IsListOfSections, IsPair, IsHashList
	def IsListOfPairs()
		_pList_ = @oList._EngineListFromContent()
		_nResult_ = StzEngineListIsAllPairs(_pList_)
		StzEngineListFree(_pList_)
		return _nResult_

	# Returns 1 if every item is a list of two numbers, else 0.
	#
	#   returns    1 or 0
	#   note       the order of the two numbers is not checked, so [3,1] passes; [[1,"a"]] and the
	#              empty list answer 0
	#   see        IsListOfPairs
	def IsListOfSections()
		_pList_ = @oList._EngineListFromContent()
		_nResult_ = StzEngineListIsAllSections(_pList_)
		StzEngineListFree(_pList_)
		return _nResult_

	  #=========================================#
	 #  EQUALITY AND COMPARISON               #
	#=========================================#

	def IsEqualToCS(paOtherList, pCaseSensitive)
		if NOT isList(paOtherList)
			return 0
		ok

		_pIetList1_ = @oList._EngineListFromContent()
		_pIetList2_ = StzEngineMarshalList(paOtherList)
		_nIetResult_ = StzEngineListEqualsCS(_pIetList1_, _pIetList2_, pCaseSensitive)
		StzEngineListFree(_pIetList2_)
		StzEngineListFree(_pIetList1_)
		return _nIetResult_

	# Returns 1 if the given list holds the same items in the same order, comparing text with case; a value that is not a list answers 0.
	#
	#   paOtherList   the list to compare with
	#   returns       1 or 0
	#   note          IsEqualToCS(paOtherList, 0) ignores case: ["a"] equals ["A"]
	#   see           IsEqualToCS, HasSameNumberOfItems
	def IsEqualTo(paOtherList)
		return This.IsEqualToCS(paOtherList, 1)

	# Returns TRUE if the checked list has more items than the given list.
	#
	#   paOtherList   the list to compare with, or :Than = list
	#   returns       TRUE or FALSE
	#   note          a value that is not a list raises the error Incorrect param type!
	#   see           HasLessNumberOfItems, HasSameNumberOfItems
	def HasMoreNumberOfItems(paOtherList)
		if isList(paOtherList) and IsThanNamedParamList(paOtherList)
			paOtherList = paOtherList[2]
		ok

		if NOT isList(paOtherList)
			StzRaise("Incorrect param type!")
		ok

		return This.NumberOfItems() > len(paOtherList)

	# Returns TRUE if the checked list has fewer items than the given list.
	#
	#   paOtherList   the list to compare with, or :Than = list
	#   returns       TRUE or FALSE
	#   note          a value that is not a list raises the error Incorrect param type!
	#   see           HasMoreNumberOfItems, HasSameNumberOfItems
	def HasLessNumberOfItems(paOtherList)
		if isList(paOtherList) and IsThanNamedParamList(paOtherList)
			paOtherList = paOtherList[2]
		ok

		if NOT isList(paOtherList)
			StzRaise("Incorrect param type!")
		ok

		return This.NumberOfItems() < len(paOtherList)

	# Returns TRUE if the checked list has as many items as the given list; the contents are not compared.
	#
	#   paOtherList   the list to compare with, or :As = list
	#   returns       TRUE or FALSE
	#   note          a value that is not a list raises the error Incorrect param type!
	#   see           HasMoreNumberOfItems, IsEqualTo
	def HasSameNumberOfItems(paOtherList)
		if isList(paOtherList) and IsAsNamedParamList(paOtherList)
			paOtherList = paOtherList[2]
		ok

		if NOT isList(paOtherList)
			StzRaise("Incorrect param type!")
		ok

		return This.NumberOfItems() = len(paOtherList)

	  #==============================#
	 #  STRUCTURE CHECKING         #
	#==============================#

	# Returns 1 if every item is a list of two items whose first is a text, else 0.
	#
	#   returns    1 or 0
	#   note       the empty list answers 1; [["a",1],["b",2]] answers 1 and [[1,2]] answers 0
	#   see        IsListOfHashLists, IsListOfPairs
	def IsHashList()
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		for i = 1 to _nLen_
			if NOT (isList(_aContent_[i]) and len(_aContent_[i]) = 2 and isString(_aContent_[i][1]))
				return 0
			ok
		next

		return 1

	# Returns 1 if every item is itself a hash list, else 0.
	#
	#   returns    1 or 0
	#   note       [[["a",1],["b",2]],[["c",3]]] answers 1; a plain hash list such as [["a",1]]
	#              answers 0
	#   see        IsHashList
	def IsListOfHashLists()
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		for i = 1 to _nLen_
			if NOT isList(_aContent_[i])
				return 0
			ok
			_oTemp_ = new stzList(_aContent_[i])
			if NOT _oTemp_.IsHashList()
				return 0
			ok
		next

		return 1

	  #=============================#
	 #  NAMED PARAM CHECKING      #
	#=============================#

	def IsOfNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(@oList.Item(1)) and @oList.Item(1) = "of" )
			return 1
		else
			return 0
		ok

	def IsWithOrByOrUsingNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(@oList.Item(1)) and
		     StzFindFirst(@oList.Item(1), [ "with", "by", "using" ]) > 0 )
			return 1
		else
			return 0
		ok

	def IsCaseSensitiveNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(@oList.Item(1)) and @oList.Item(1) = "casesensitive" )
			return 1
		else
			return 0
		ok

	  #==============================#
	 #  EMPTINESS CHECKING         #
	#==============================#

	# Returns TRUE if the checked list has no item.
	#
	#   returns    TRUE or FALSE
	#   see        IsNonEmpty, IsSingle
	def IsEmpty()
		return This.NumberOfItems() = 0

	# Returns TRUE if the checked list has at least one item.
	#
	#   returns    TRUE or FALSE
	#   see        IsEmpty, IsSingle
	def IsNonEmpty()
		return This.NumberOfItems() > 0

		def IsNotEmpty()
			return This.IsNonEmpty()

	# Returns TRUE if the checked list has exactly one item.
	#
	#   returns    TRUE or FALSE
	#   see        IsPair, IsEmpty
	def IsSingle()
		return This.NumberOfItems() = 1

		def IsSingleton()
			return This.IsSingle()

	  #==============================#
	 #  CONTENT PATTERN CHECKING   #
	#==============================#

	# Returns 1 if every item equals the others, comparing text with case, else 0.
	#
	#   returns    1 or 0
	#   note       the empty list answers 1
	#   see        AllItemsAreUnique
	def AllItemsAreEqual()
		_pList_ = @oList._EngineListFromContent()
		_nResult_ = StzEngineListAllItemsEqualCS(_pList_, 1)
		StzEngineListFree(_pList_)
		return _nResult_

		def ItemsAreAllEqual()
			return This.AllItemsAreEqual()

	# Returns 1 if no item appears twice, comparing text with case, else 0.
	#
	#   returns    1 or 0
	#   note       "a" and "A" count as different; [2,2] answers 0
	#   see        AllItemsAreEqual
	def AllItemsAreUnique()
		_pList_ = @oList._EngineListFromContent()
		_nResult_ = StzEngineListAllUniqueCS(_pList_, 1)
		StzEngineListFree(_pList_)
		return _nResult_

		def ItemsAreAllUnique()
			return This.AllItemsAreUnique()

		def HasNoDuplicates()
			return This.AllItemsAreUnique()

	def ContainsOnly(pType)
		return This.AllItemsAreOfType(pType)

	# Returns 1 if the items never go down or never go up, so a repeated value is allowed, else 0.
	#
	#   returns    1 or 0
	#   note       [1,2,2,3] and [3,2,1] answer 1; [3,1,2] answers 0
	#   see        IsStrictlyIncreasing, IsStrictlyDecreasing
	def IsMonotonic()
		_pList_ = @oList._EngineListFromContent()
		_nResult_ = StzEngineListIsMonotonic(_pList_)
		StzEngineListFree(_pList_)
		return _nResult_

		def IsMonotonous()
			return This.IsMonotonic()

	# Returns 1 if each item is larger than the one before it, else 0.
	#
	#   returns    1 or 0
	#   note       a repeated value answers 0: [1,2,2] is not strictly increasing
	#   see        IsStrictlyDecreasing, IsMonotonic
	def IsStrictlyIncreasing()
		_pList_ = @oList._EngineListFromContent()
		_nResult_ = StzEngineListIsStrictlyIncreasing(_pList_)
		StzEngineListFree(_pList_)
		return _nResult_

	# Returns 1 if each item is smaller than the one before it, else 0.
	#
	#   returns    1 or 0
	#   note       a repeated value answers 0: [3,3] is not strictly decreasing
	#   see        IsStrictlyIncreasing, IsMonotonic
	def IsStrictlyDecreasing()
		_pList_ = @oList._EngineListFromContent()
		_nResult_ = StzEngineListIsStrictlyDecreasing(_pList_)
		StzEngineListFree(_pList_)
		return _nResult_

	  #==============================#
	 #  CONTAINMENT CHECKING       #
	#==============================#

	# Returns 1 if every item is a text; it does exactly what IsListOfStrings does and ignores its argument.
	#
	#   pCaseSensitive   accepted and ignored
	#   returns          1 or 0
	#   note             the flag has no effect
	#   see              IsListOfStrings
	def ContainsOnlyStringsCS(pCaseSensitive)
		return This.IsListOfStrings()

	# Returns 1 if the list holds the item, with the case flag deciding whether A and a are the same text, else 0.
	#
	#   pItem            the item to look for: a number, a text or a list, matched whole
	#   pCaseSensitive   1 to tell A from a, 0 to ignore the case; the pair [ :CaseSensitive, 0 ] is accepted too
	#   returns          1 or 0
	#   note             the type must agree: 2 is not found in a list holding the text "2"; a list item matches an
	#                    equal list only, item by item, and the texts inside it follow the flag; with the flag at 0 a
	#                    text beyond ASCII is folded for its script (a capital sigma matches a small one) while a
	#                    text of ASCII letters is looked up by the engine, which folds those letters only; an object
	#                    is never matched
	#   see              ContainsItem, ContainsAllOfTheseCS, ContainsOneOfTheseCS
	def ContainsItemCS(pItem, pCaseSensitive)
		_nCicCs_ = 1
		if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
			pCaseSensitive = pCaseSensitive[2]
		ok
		if isNumber(pCaseSensitive) and pCaseSensitive = 0
			_nCicCs_ = 0
		ok

		if isObject(pItem)
			return 0
		ok

		# A text goes to the engine, which scans the text items only. Asking the engine for a
		# number or a list is not reliable: it stores the numbers of a list as integers or as
		# decimals by a rule of its own, so a needle stored the other way is missed (3 is not
		# found in [ 1, 2.5, 3 ]), and it compares the texts inside a list case-sensitively
		# whatever the flag. And a bare value handle from StzEngineValueNew* is not readable by
		# the list module (it comes from another DLL), which is why asking
		# StzEngineListContainsCS with one answers 0 for every item. The engine folds only the
		# ASCII letters, so a text beyond ASCII with the flag at 0 goes through Ring as well.
		if isString(pItem) and (_nCicCs_ = 1 or ring_len(pItem) = StzLen(pItem))
			_pCicEng_ = @oList._Engine()
			if _pCicEng_ != ""
				return StzEngineListContainsStringCS(_pCicEng_, pItem, _nCicCs_)
			ok
		ok

		# Ring comparison: the item is folded once, then each list item is compared with it
		_aCicList_ = @oList.Content()
		_nCicLen_ = ring_len(_aCicList_)
		if isNumber(pItem)
			for _iCic_ = 1 to _nCicLen_
				if isNumber(_aCicList_[_iCic_]) and _aCicList_[_iCic_] = pItem
					return 1
				ok
			next
			return 0
		ok
		_xCicNeedle_ = pItem
		if _nCicCs_ = 0
			_xCicNeedle_ = This._LcFold(pItem)
		ok

		# A list item is checked in place, member by member, and ruled out on its first member
		# when that is a number or a text taken as it is, so that a long list of lists is neither
		# copied nor sent through a method once per item; only the survivors, and a list inside
		# a list, go through the recursive compare.
		if isList(_xCicNeedle_)
			_nCicNeedleLen_ = ring_len(_xCicNeedle_)
			_nCicQuick_ = 0
			_xCicFirst_ = ""
			if _nCicNeedleLen_ > 0
				_xCicFirst_ = _xCicNeedle_[1]
				if isNumber(_xCicFirst_)
					_nCicQuick_ = 1
				but isString(_xCicFirst_) and _nCicCs_ = 1
					_nCicQuick_ = 2
				ok
			ok
			for _iCic_ = 1 to _nCicLen_
				if isList(_aCicList_[_iCic_]) and ring_len(_aCicList_[_iCic_]) = _nCicNeedleLen_
					_bCicSame_ = 1
					if _nCicQuick_ = 1
						if NOT (isNumber(_aCicList_[_iCic_][1]) and _aCicList_[_iCic_][1] = _xCicFirst_)
							_bCicSame_ = 0
						ok
					but _nCicQuick_ = 2
						if NOT (isString(_aCicList_[_iCic_][1]) and strcmp(_aCicList_[_iCic_][1], _xCicFirst_) = 0)
							_bCicSame_ = 0
						ok
					ok
					if _bCicSame_
						for _jCic_ = 1 to _nCicNeedleLen_
							if NOT This._LcSame(_aCicList_[_iCic_][_jCic_], _xCicNeedle_[_jCic_], _nCicCs_)
								_bCicSame_ = 0
								exit
							ok
						next
					ok
					if _bCicSame_
						return 1
					ok
				ok
			next
			return 0
		ok

		for _iCic_ = 1 to _nCicLen_
			if This._LcSame(_aCicList_[_iCic_], _xCicNeedle_, _nCicCs_)
				return 1
			ok
		next
		return 0

	# Returns 1 if the list holds the item, telling A from a, else 0.
	#
	#   pItem      the item to look for: a number, a text or a list, matched whole
	#   returns    1 or 0
	#   note       ContainsItemCS takes the case flag and states the matching rules
	#   see        ContainsItemCS, ContainsAllOfThese, ContainsOneOfThese
	#   example    o1 = new stzListChecker([ 1, "b", [ 3 ] ])
	#              ? o1.ContainsItem([ 3 ])
	#              #--> 1
	#              ? o1.ContainsItem("B")
	#              #--> 0
	def ContainsItem(pItem)
		_nCiCs_ = 1
		return This.ContainsItemCS(pItem, _nCiCs_)

	# Returns 1 if the list holds every one of the items, with the case flag applied to each, else 0.
	#
	#   paItems          the items to look for, a list; anything else answers 0
	#   pCaseSensitive   1 to tell A from a, 0 to ignore the case
	#   returns          1 or 0
	#   note             the empty list of items answers 1, as nothing is missing
	#   see              ContainsAllOfThese, ContainsItemCS
	def ContainsAllOfTheseCS(paItems, pCaseSensitive)
		if NOT isList(paItems)
			return 0
		ok
		_nCatLen_ = ring_len(paItems)
		for _iCat_ = 1 to _nCatLen_
			if NOT This.ContainsItemCS(paItems[_iCat_], pCaseSensitive)
				return 0
			ok
		next
		return 1

	# Returns 1 if the list holds every one of the items, telling A from a, else 0.
	#
	#   paItems    the items to look for, a list; anything else answers 0
	#   returns    1 or 0
	#   note       the empty list of items answers 1, as nothing is missing
	#   see        ContainsItem, ContainsOneOfThese
	#   example    o1 = new stzListChecker([ 1, 2, 3 ])
	#              ? o1.ContainsAllOfThese([ 1, 2 ])
	#              #--> 1
	#              ? o1.ContainsAllOfThese([ 1, 9 ])
	#              #--> 0
	def ContainsAllOfThese(paItems)
		_nCaCs_ = 1
		return This.ContainsAllOfTheseCS(paItems, _nCaCs_)

	# Returns 1 if the list holds at least one of the items, with the case flag applied to each, else 0.
	#
	#   paItems          the items to look for, a list; anything else answers 0
	#   pCaseSensitive   1 to tell A from a, 0 to ignore the case
	#   returns          1 or 0
	#   note             the empty list of items answers 0, as nothing can be found
	#   see              ContainsOneOfThese, ContainsItemCS
	def ContainsOneOfTheseCS(paItems, pCaseSensitive)
		if NOT isList(paItems)
			return 0
		ok
		_nCotLen_ = ring_len(paItems)
		for _iCot_ = 1 to _nCotLen_
			if This.ContainsItemCS(paItems[_iCot_], pCaseSensitive)
				return 1
			ok
		next
		return 0

	# Returns 1 if the list holds at least one of the items, telling A from a, else 0.
	#
	#   paItems    the items to look for, a list; anything else answers 0
	#   returns    1 or 0
	#   note       the empty list of items answers 0, as nothing can be found
	#   see        ContainsItem, ContainsAllOfThese
	#   example    o1 = new stzListChecker([ "a", "b" ])
	#              ? o1.ContainsOneOfThese([ "z", "b" ])
	#              #--> 1
	#              ? o1.ContainsOneOfThese([ "z", "y" ])
	#              #--> 0
	def ContainsOneOfThese(paItems)
		_nCoCs_ = 1
		return This.ContainsOneOfTheseCS(paItems, _nCoCs_)

	# Returns 1 if the two items are the same: numbers by value, texts by the flag, lists item by item.
	#
	#   pA         the item taken from the list
	#   pB         the item looked for; already lowercased (see _LcFold) when the flag is 0
	#   pnCs       1 to compare texts as they are, 0 to lowercase the first before comparing
	#   returns    1 or 0
	def _LcSame(pA, pB, pnCs)
		_nLsOk_ = 0
		if isNumber(pA)
			if isNumber(pB) and pA = pB
				_nLsOk_ = 1
			ok
		but isString(pA)
			if isString(pB)
				if pnCs = 1
					_nLsOk_ = (strcmp(pA, pB) = 0)
				else
					_nLsOk_ = (strcmp(StzLower(pA), pB) = 0)
				ok
			ok
		but isList(pA)
			if isList(pB)
				_nLsLen_ = ring_len(pA)
				if _nLsLen_ = ring_len(pB)
					_nLsOk_ = 1
					for _iLs_ = 1 to _nLsLen_
						if NOT This._LcSame(pA[_iLs_], pB[_iLs_], pnCs)
							_nLsOk_ = 0
							exit
						ok
					next
				ok
			ok
		ok
		return _nLsOk_

	# Returns the item with every text lowercased, going down into the lists.
	#
	#   pX         the item to fold
	#   returns    the same shape, with its texts lowercased
	def _LcFold(pX)
		if isString(pX)
			return StzLower(pX)
		but isList(pX)
			_aLfOut_ = []
			_nLfLen_ = ring_len(pX)
			for _iLf_ = 1 to _nLfLen_
				_aLfOut_ + This._LcFold(pX[_iLf_])
			next
			return _aLfOut_
		ok
		return pX

	  #============================#
	 #  NUMERIC LIST CHECKING    #
	#============================#

	# Returns 1 if the numbers follow one another by steps of one, going up or going down, else 0.
	#
	#   returns    1 or 0
	#   note       [1,2,3] and [3,2,1] answer 1; [1,3], [1,2.5] answer 0; the empty list answers 1
	#   see        IsMonotonic, IsStrictlyIncreasing
	def IsContinuous()
		_pList_ = @oList._EngineListFromContent()
		_nResult_ = StzEngineListIsContinuous(_pList_)
		StzEngineListFree(_pList_)
		return _nResult_

		def IsContiguous()
			return This.IsContinuous()

		def IsConsecutive()
			return This.IsContinuous()

	  #==============================#
	 #  PAIR CHECKING               #
	#==============================#

	# Returns 1 if the list has exactly two items and both are numbers, else 0.
	#
	#   returns    1 or 0
	#   see        IsPairOfStrings, IsPairOfLists, IsPair
	def IsPairOfNumbers()
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)
		if _nLen_ = 2 and isNumber(_aContent_[1]) and isNumber(_aContent_[2])
			return 1
		else
			return 0
		ok

		def IsAPairOfNumbers()
			return This.IsPairOfNumbers()

		def ContainsOnlyPairOfNumbers()
			return This.IsPairOfNumbers()

		def ContainsOnlyAPairOfNumbers()
			return This.IsPairOfNumbers()

	# Returns 1 if the list has exactly two items and both are texts, else 0.
	#
	#   returns    1 or 0
	#   see        IsPairOfNumbers, IsPairOfLists, IsPair
	def IsPairOfStrings()
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)
		if _nLen_ = 2 and isString(_aContent_[1]) and isString(_aContent_[2])
			return 1
		else
			return 0
		ok

	# Returns 1 if the list has exactly two items and both are lists, else 0.
	#
	#   returns    1 or 0
	#   see        IsPairOfNumbers, IsPairOfStrings, IsPair
	def IsPairOfLists()
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)
		if _nLen_ = 2 and isList(_aContent_[1]) and isList(_aContent_[2])
			return 1
		else
			return 0
		ok

	  #==============================#
	 #  CONDITIONAL CONTAINMENT    #
	#==============================#

	# Returns 1 if at least one item satisfies the condition, else 0.
	#
	#   pcCondition   a W condition on the item, written with @item, such as @item > 2
	#   returns       1 or 0; the empty list answers 0
	#   note          the condition goes to the engine's W language, which reads it and is not given to
	#                 Ring's eval; still, take it from a trusted source, as it decides what the engine runs
	#   see           ContainsItem, ContainsOneOfThese
	#   example       o1 = new stzListChecker([ 1, 2, 3 ])
	#                 ? o1.ContainsW("@item > 2")
	#                 #--> 1
	#                 ? o1.ContainsW("@item > 5")
	#                 #--> 0
	def ContainsW(pcCondition)
		_anCwAt_ = @oList.FindAllItemsW(pcCondition)
		return ring_len(_anCwAt_) > 0

		def ContainsWhere(pcCondition)
			return This.ContainsW(pcCondition)

		def ContainsItemW(pcCondition)
			return This.ContainsW(pcCondition)

	  #==============================#
	 #  PALINDROME CHECKING        #
	#==============================#

	# Returns 1 if the items read the same from both ends, comparing text with case, else 0.
	#
	#   returns    1 or 0
	#   note       [1,2,1] answers 1; ["a","A"] answers 0; the empty list answers 1
	#   see        IsMonotonic
	def IsPalindrome()
		_pList_ = @oList._EngineListFromContent()
		_nResult_ = StzEngineListIsPalindromeCS(_pList_, 1)
		StzEngineListFree(_pList_)
		return _nResult_

		def IsListPalindrome()
			return This.IsPalindrome()

	  #==============================#
	 #  SET CHECKING               #
	#==============================#

	def IsSet()
		return This.AllItemsAreUnique()

		def IsASet()
			return This.IsSet()

	  #==============================#
	 #  PAIR CHECKING              #
	#==============================#

	# Returns TRUE if the list has exactly two items, whatever they are.
	#
	#   returns    TRUE or FALSE
	#   see        IsSingle, IsPairOfNumbers, IsListOfPairs
	def IsPair()
		return This.NumberOfItems() = 2

		def IsAPair()
			return This.IsPair()
