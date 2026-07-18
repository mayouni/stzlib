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

class stzListChecker from stzObject

	@oList

	  #===================#
	 #   INITIALIZATION  #
	#===================#

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

	def Content()
		return @oList.Content()

	def NumberOfItems()
		return @oList.NumberOfItems()

	  #======================================#
	 #  CHECKING LIST TYPE COMPOSITION     #
	#======================================#

	def IsListOfNumbers()
		pList = @oList._EngineListFromContent()
		_nResult_ = StzEngineListIsAllNumbers(pList)
		StzEngineListFree(pList)
		return _nResult_

	def IsListOfStrings()
		pList = @oList._EngineListFromContent()
		_nResult_ = StzEngineListIsAllStrings(pList)
		StzEngineListFree(pList)
		return _nResult_

	def IsListOfLists()
		pList = @oList._EngineListFromContent()
		_nResult_ = StzEngineListIsAllLists(pList)
		StzEngineListFree(pList)
		return _nResult_

		def AllItemsAreLists()
			return This.IsListOfLists()

		def ContainsOnlyLists()
			return This.IsListOfLists()

	def IsListOfListsOfSameSize()
		pList = @oList._EngineListFromContent()
		_nResult_ = StzEngineListIsAllListsSameSize(pList)
		StzEngineListFree(pList)
		return _nResult_

		def ItemsAreListsOfSameSize()
			return This.IsListOfListsOfSameSize()

		def AllItemsAreListsOfSameSize()
			return This.IsListOfListsOfSameSize()

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

	def IsHybrid()
		pList = @oList._EngineListFromContent()
		_nResult_ = StzEngineListIsHybrid(pList)
		StzEngineListFree(pList)
		return _nResult_

		def IsHybridList()
			return This.IsHybrid()

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

	def IsListOfPairs()
		pList = @oList._EngineListFromContent()
		_nResult_ = StzEngineListIsAllPairs(pList)
		StzEngineListFree(pList)
		return _nResult_

	def IsListOfSections()
		pList = @oList._EngineListFromContent()
		_nResult_ = StzEngineListIsAllSections(pList)
		StzEngineListFree(pList)
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

	def IsEqualTo(paOtherList)
		return This.IsEqualToCS(paOtherList, 1)

	def HasMoreNumberOfItems(paOtherList)
		if isList(paOtherList) and IsThanNamedParamList(paOtherList)
			paOtherList = paOtherList[2]
		ok

		if NOT isList(paOtherList)
			StzRaise("Incorrect param type!")
		ok

		return This.NumberOfItems() > len(paOtherList)

	def HasLessNumberOfItems(paOtherList)
		if isList(paOtherList) and IsThanNamedParamList(paOtherList)
			paOtherList = paOtherList[2]
		ok

		if NOT isList(paOtherList)
			StzRaise("Incorrect param type!")
		ok

		return This.NumberOfItems() < len(paOtherList)

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

	def IsHashList()
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		for i = 1 to _nLen_
			if NOT (isList(_aContent_[i]) and len(_aContent_[i]) = 2 and isString(_aContent_[i][1]))
				return 0
			ok
		next

		return 1

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

	def IsEmpty()
		return This.NumberOfItems() = 0

	def IsNonEmpty()
		return This.NumberOfItems() > 0

		def IsNotEmpty()
			return This.IsNonEmpty()

	def IsSingle()
		return This.NumberOfItems() = 1

		def IsSingleton()
			return This.IsSingle()

	  #==============================#
	 #  CONTENT PATTERN CHECKING   #
	#==============================#

	def AllItemsAreEqual()
		pList = @oList._EngineListFromContent()
		_nResult_ = StzEngineListAllItemsEqualCS(pList, 1)
		StzEngineListFree(pList)
		return _nResult_

		def ItemsAreAllEqual()
			return This.AllItemsAreEqual()

	def AllItemsAreUnique()
		pList = @oList._EngineListFromContent()
		_nResult_ = StzEngineListAllUniqueCS(pList, 1)
		StzEngineListFree(pList)
		return _nResult_

		def ItemsAreAllUnique()
			return This.AllItemsAreUnique()

		def HasNoDuplicates()
			return This.AllItemsAreUnique()

	def ContainsOnly(pType)
		return This.AllItemsAreOfType(pType)

	def IsMonotonic()
		pList = @oList._EngineListFromContent()
		_nResult_ = StzEngineListIsMonotonic(pList)
		StzEngineListFree(pList)
		return _nResult_

		def IsMonotonous()
			return This.IsMonotonic()

	def IsStrictlyIncreasing()
		pList = @oList._EngineListFromContent()
		_nResult_ = StzEngineListIsStrictlyIncreasing(pList)
		StzEngineListFree(pList)
		return _nResult_

	def IsStrictlyDecreasing()
		pList = @oList._EngineListFromContent()
		_nResult_ = StzEngineListIsStrictlyDecreasing(pList)
		StzEngineListFree(pList)
		return _nResult_

	  #==============================#
	 #  CONTAINMENT CHECKING       #
	#==============================#

	def ContainsOnlyStringsCS(pCaseSensitive)
		return This.IsListOfStrings()

	def ContainsItemCS(pItem, pCaseSensitive)
		_pCicList_ = @oList._EngineListFromContent()
		_nCicResult_ = StzEngineListContainsCS(_pCicList_, pItem, pCaseSensitive)
		StzEngineListFree(_pCicList_)
		return _nCicResult_

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

	def ContainsOneOfThese(paItems)
		return This.ContainsOneOfTheseCS(paItems, 1)

	  #============================#
	 #  NUMERIC LIST CHECKING    #
	#============================#

	def IsContinuous()
		pList = @oList._EngineListFromContent()
		_nResult_ = StzEngineListIsContinuous(pList)
		StzEngineListFree(pList)
		return _nResult_

		def IsContiguous()
			return This.IsContinuous()

		def IsConsecutive()
			return This.IsContinuous()

	  #==============================#
	 #  PAIR CHECKING               #
	#==============================#

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

	def IsPairOfStrings()
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)
		if _nLen_ = 2 and isString(_aContent_[1]) and isString(_aContent_[2])
			return 1
		else
			return 0
		ok

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

	def IsPalindrome()
		pList = @oList._EngineListFromContent()
		_nResult_ = StzEngineListIsPalindromeCS(pList, 1)
		StzEngineListFree(pList)
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

	def IsPair()
		return This.NumberOfItems() = 2

		def IsAPair()
			return This.IsPair()
