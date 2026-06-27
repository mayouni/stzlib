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

class stzListChecker

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
		nResult = StzEngineListIsAllNumbers(pList)
		StzEngineListFree(pList)
		return nResult

	def IsListOfStrings()
		pList = @oList._EngineListFromContent()
		nResult = StzEngineListIsAllStrings(pList)
		StzEngineListFree(pList)
		return nResult

	def IsListOfLists()
		pList = @oList._EngineListFromContent()
		nResult = StzEngineListIsAllLists(pList)
		StzEngineListFree(pList)
		return nResult

		def AllItemsAreLists()
			return This.IsListOfLists()

		def ContainsOnlyLists()
			return This.IsListOfLists()

	def IsListOfListsOfSameSize()
		pList = @oList._EngineListFromContent()
		nResult = StzEngineListIsAllListsSameSize(pList)
		StzEngineListFree(pList)
		return nResult

		def ItemsAreListsOfSameSize()
			return This.IsListOfListsOfSameSize()

		def AllItemsAreListsOfSameSize()
			return This.IsListOfListsOfSameSize()

	def IsListOfObjects()
		aContent = This.Content()
		nLen = len(aContent)

		for i = 1 to nLen
			if NOT isObject(aContent[i])
				return 0
			ok
		next

		return 1

	  #==============================#
	 #  MIXED TYPE CHECKING        #
	#==============================#

	def IsHybrid()
		pList = @oList._EngineListFromContent()
		nResult = StzEngineListIsHybrid(pList)
		StzEngineListFree(pList)
		return nResult

		def IsHybridList()
			return This.IsHybrid()

	def AllItemsAreOfType(pcType)
		aContent = This.Content()
		nLen = len(aContent)

		for i = 1 to nLen
			if type(aContent[i]) != StzUpper(pcType)
				return 0
			ok
		next

		return 1

	  #==============================#
	 #  NUMBER SUBTYPE CHECKING    #
	#==============================#

	def IsListOfDecimalNumbers()
		aContent = This.Content()
		nLen = len(aContent)

		for i = 1 to nLen
			if NOT isNumber(aContent[i])
				return 0
			ok
		next

		return 1

	  #==============================#
	 #  STRING SUBTYPE CHECKING    #
	#==============================#

	def IsListOfPairs()
		pList = @oList._EngineListFromContent()
		nResult = StzEngineListIsAllPairs(pList)
		StzEngineListFree(pList)
		return nResult

	def IsListOfSections()
		pList = @oList._EngineListFromContent()
		nResult = StzEngineListIsAllSections(pList)
		StzEngineListFree(pList)
		return nResult

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
		aContent = This.Content()
		nLen = len(aContent)

		for i = 1 to nLen
			if NOT (isList(aContent[i]) and len(aContent[i]) = 2 and isString(aContent[i][1]))
				return 0
			ok
		next

		return 1

	def IsListOfHashLists()
		aContent = This.Content()
		nLen = len(aContent)

		for i = 1 to nLen
			if NOT isList(aContent[i])
				return 0
			ok
			oTemp = new stzList(aContent[i])
			if NOT oTemp.IsHashList()
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
		     StzFindFirst([ "with", "by", "using" ], @oList.Item(1)) > 0 )
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
		nResult = StzEngineListAllItemsEqualCS(pList, 1)
		StzEngineListFree(pList)
		return nResult

		def ItemsAreAllEqual()
			return This.AllItemsAreEqual()

	def AllItemsAreUnique()
		pList = @oList._EngineListFromContent()
		nResult = StzEngineListAllUniqueCS(pList, 1)
		StzEngineListFree(pList)
		return nResult

		def ItemsAreAllUnique()
			return This.AllItemsAreUnique()

		def HasNoDuplicates()
			return This.AllItemsAreUnique()

	def ContainsOnly(pType)
		return This.AllItemsAreOfType(pType)

	def IsMonotonic()
		pList = @oList._EngineListFromContent()
		nResult = StzEngineListIsMonotonic(pList)
		StzEngineListFree(pList)
		return nResult

		def IsMonotonous()
			return This.IsMonotonic()

	def IsStrictlyIncreasing()
		pList = @oList._EngineListFromContent()
		nResult = StzEngineListIsStrictlyIncreasing(pList)
		StzEngineListFree(pList)
		return nResult

	def IsStrictlyDecreasing()
		pList = @oList._EngineListFromContent()
		nResult = StzEngineListIsStrictlyDecreasing(pList)
		StzEngineListFree(pList)
		return nResult

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
		nResult = StzEngineListIsContinuous(pList)
		StzEngineListFree(pList)
		return nResult

		def IsContiguous()
			return This.IsContinuous()

		def IsConsecutive()
			return This.IsContinuous()

	  #==============================#
	 #  PAIR CHECKING               #
	#==============================#

	def IsPairOfNumbers()
		aContent = This.Content()
		nLen = len(aContent)
		if nLen = 2 and isNumber(aContent[1]) and isNumber(aContent[2])
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
		aContent = This.Content()
		nLen = len(aContent)
		if nLen = 2 and isString(aContent[1]) and isString(aContent[2])
			return 1
		else
			return 0
		ok

	def IsPairOfLists()
		aContent = This.Content()
		nLen = len(aContent)
		if nLen = 2 and isList(aContent[1]) and isList(aContent[2])
			return 1
		else
			return 0
		ok

	  #==============================#
	 #  CONDITIONAL CONTAINMENT    #
	#==============================#

	def ContainsW(pcCondition)
		aContent = This.Content()
		nLen = len(aContent)

		cCode = StzCCodeToRingCode(pcCondition)

		for @i = 1 to nLen
			@item = aContent[@i]
			cEval = StzStringReplace(cCode, "@item", @@(@item))
			if eval(cEval)
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
		nResult = StzEngineListIsPalindromeCS(pList, 1)
		StzEngineListFree(pList)
		return nResult

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
