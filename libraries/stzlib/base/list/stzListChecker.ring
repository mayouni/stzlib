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
# IsListOfLists. Broken today: ContainsItem answers 0 for every item, and with it ContainsAllOfThese
# and ContainsOneOfThese; ContainsW raises error R3.
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

	def ContainsItemCS(pItem, pCaseSensitive)
		_pCicList_ = @oList._EngineListFromContent()
		_nCicResult_ = StzEngineListContainsCS(_pCicList_, pItem, pCaseSensitive)
		StzEngineListFree(_pCicList_)
		return _nCicResult_

	# Returns 0 whatever the list holds today, because the item is handed to the engine in a form it does not match.
	#
	#   pItem      the item to look for
	#   returns    0
	#   note       use stzList.Contains instead, which answers 1 for the same data
	#   warning    defect: ContainsItem(2) on [1,2,3], ContainsItem("a") on ["a","b"] and
	#              ContainsItem([3]) on [[1,2],[3]] all answer 0, and so does ContainsItemCS with
	#              either case flag; the call StzEngineListContainsCS(list, item, cs) answers 0 on
	#              its own for present items; the engine function stz_list_contains_cs expects the
	#              needle as a value handle and the class passes the raw item
	#   see        ContainsAllOfThese, ContainsOneOfThese
	def ContainsItem(pItem)
		return This.ContainsItemCS(pItem, 1)

	def ContainsAllOfTheseCS(paItems, pCaseSensitive)
		_nCatLen_ = len(paItems)
		for _iCat_ = 1 to _nCatLen_
			if NOT This.ContainsItemCS(paItems[_iCat_], pCaseSensitive)
				return 0
			ok
		next
		return 1

	# Returns 1 only for an empty list of items today, because every ContainsItem answers 0.
	#
	#   paItems    the items to look for
	#   returns    1 or 0
	#   note       until ContainsItem is repaired, ask stzList (Contains answers 1 for present
	#              items)
	#   warning    defect: ContainsAllOfThese([1,2]) on [1,2,3] answers 0 and ContainsAllOfThese([])
	#              answers 1; the cause is ContainsItem, which never finds an item
	#   see        ContainsItem, ContainsOneOfThese
	def ContainsAllOfThese(paItems)
		return This.ContainsAllOfTheseCS(paItems, 1)

	def ContainsOneOfTheseCS(paItems, pCaseSensitive)
		_nCotLen_ = len(paItems)
		for _iCot_ = 1 to _nCotLen_
			if This.ContainsItemCS(paItems[_iCot_], pCaseSensitive)
				return 1
			ok
		next
		return 0

	# Returns 0 today, whatever the items are, because every ContainsItem answers 0.
	#
	#   paItems    the items to look for
	#   returns    1 or 0
	#   warning    defect: ContainsOneOfThese([9,2]) on [1,2,3] and ContainsOneOfThese(["z","b"]) on
	#              ["a","b"] answer 0; the cause is ContainsItem, which never finds an item
	#   see        ContainsItem, ContainsAllOfThese
	def ContainsOneOfThese(paItems)
		return This.ContainsOneOfTheseCS(paItems, 1)

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

	# Raises error R3 today instead of telling whether an item satisfies the condition.
	#
	#   pcCondition   a condition written with @item, such as @item > 2
	#   returns       nothing; it raises an error
	#   note          the same missing function is noted in stzListClassifier.ring
	#   warning       defect: the method calls StzCCodeToRingCode, which no file of the library
	#                 defines, so every call raises Calling Function without definition:
	#                 stzccodetoringcode
	#   see           IsListOfNumbers
	def ContainsW(pcCondition)
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		_cCode_ = StzCCodeToRingCode(pcCondition)

		for @i = 1 to _nLen_
			@item = _aContent_[@i]
			_cEval_ = StzStringReplace(_cCode_, "@item", @@(@item))
			if eval(_cEval_)
				return 1
			ok
		next

		return 0

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
