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
		aContent = This.Content()
		nLen = len(aContent)

		for i = 1 to nLen
			if NOT isNumber(aContent[i])
				return 0
			ok
		next

		return 1

	def IsListOfStrings()
		aContent = This.Content()
		nLen = len(aContent)

		for i = 1 to nLen
			if NOT isString(aContent[i])
				return 0
			ok
		next

		return 1

	def IsListOfLists()
		aContent = This.Content()
		nLen = len(aContent)

		for i = 1 to nLen
			if NOT isList(aContent[i])
				return 0
			ok
		next

		return 1

		def AllItemsAreLists()
			return This.IsListOfLists()

		def ContainsOnlyLists()
			return This.IsListOfLists()

	def IsListOfListsOfSameSize()
		_nLen_ = This.NumberOfItems()
		if _nLen_ = 0
			return 0
		ok

		_bResult_ = 0
		if This.IsListOfLists()
			_bSame_ = 1
			aContent = This.Content()
			for @i = 2 to _nLen_
				if len(aContent[@i]) != len(aContent[@i-1])
					_bSame_ = 0
				ok
			next
			if _bSame_ = 1
				_bResult_ = 1
			ok
		ok
		return _bResult_

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
		aContent = This.Content()
		nLen = len(aContent)
		if nLen <= 1
			return 0
		ok

		cFirstType = type(aContent[1])
		for i = 2 to nLen
			if type(aContent[i]) != cFirstType
				return 1
			ok
		next

		return 0

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
		aContent = This.Content()
		nLen = len(aContent)

		for i = 1 to nLen
			if NOT (isList(aContent[i]) and len(aContent[i]) = 2)
				return 0
			ok
		next

		return 1

	def IsListOfSections()
		aContent = This.Content()
		nLen = len(aContent)

		for i = 1 to nLen
			if NOT (isList(aContent[i]) and len(aContent[i]) = 2 and
			        isNumber(aContent[i][1]) and isNumber(aContent[i][2]))
				return 0
			ok
		next

		return 1

	  #=========================================#
	 #  EQUALITY AND COMPARISON               #
	#=========================================#

	def IsEqualToCS(paOtherList, pCaseSensitive)
		aContent1 = This.Content()
		nLen1 = len(aContent1)

		if NOT isList(paOtherList)
			return 0
		ok

		nLen2 = len(paOtherList)

		if nLen1 != nLen2
			return 0
		ok

		for i = 1 to nLen1
			c1 = @@(aContent1[i])
			c2 = @@(paOtherList[i])

			if pCaseSensitive = 0
				c1 = StzLower(c1)
				c2 = StzLower(c2)
			ok

			if c1 != c2
				return 0
			ok
		next

		return 1

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
		     StzFind([ "with", "by", "using" ], @oList.Item(1)) > 0 )
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
		aContent = This.Content()
		nLen = len(aContent)
		if nLen < 2
			return 1
		ok

		cFirst = @@(aContent[1])
		for i = 2 to nLen
			if @@(aContent[i]) != cFirst
				return 0
			ok
		next
		return 1

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
		aContent = This.Content()
		nLen = len(aContent)
		if nLen < 2
			return 1
		ok

		bAsc = 1
		bDesc = 1
		for i = 1 to nLen - 1
			if NOT (isNumber(aContent[i]) and isNumber(aContent[i+1]))
				return 0
			ok
			if aContent[i] > aContent[i+1]
				bAsc = 0
			ok
			if aContent[i] < aContent[i+1]
				bDesc = 0
			ok
		next

		return (bAsc or bDesc)

		def IsMonotonous()
			return This.IsMonotonic()

	def IsStrictlyIncreasing()
		aContent = This.Content()
		nLen = len(aContent)
		for i = 1 to nLen - 1
			if NOT (isNumber(aContent[i]) and isNumber(aContent[i+1]))
				return 0
			ok
			if aContent[i] >= aContent[i+1]
				return 0
			ok
		next
		return 1

	def IsStrictlyDecreasing()
		aContent = This.Content()
		nLen = len(aContent)
		for i = 1 to nLen - 1
			if NOT (isNumber(aContent[i]) and isNumber(aContent[i+1]))
				return 0
			ok
			if aContent[i] <= aContent[i+1]
				return 0
			ok
		next
		return 1

	  #==============================#
	 #  CONTAINMENT CHECKING       #
	#==============================#

	def ContainsOnlyStringsCS(pCaseSensitive)
		return This.IsListOfStrings()

	def ContainsItemCS(pItem, pCaseSensitive)
		aContent = This.Content()
		nLen = len(aContent)

		for i = 1 to nLen
			if BothAreEqualCS(aContent[i], pItem, pCaseSensitive)
				return 1
			ok
		next

		return 0

	def ContainsItem(pItem)
		return This.ContainsItemCS(pItem, 1)

	def ContainsAllOfTheseCS(paItems, pCaseSensitive)
		nLen = len(paItems)
		for i = 1 to nLen
			if NOT This.ContainsItemCS(paItems[i], pCaseSensitive)
				return 0
			ok
		next
		return 1

	def ContainsAllOfThese(paItems)
		return This.ContainsAllOfTheseCS(paItems, 1)

	def ContainsOneOfTheseCS(paItems, pCaseSensitive)
		nLen = len(paItems)
		for i = 1 to nLen
			if This.ContainsItemCS(paItems[i], pCaseSensitive)
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
		aContent = This.Content()
		nLen = len(aContent)
		if nLen < 2
			return 1
		ok

		pList = @oList._EngineListFromContent()
		StzEngineListSortCS(pList, 1)
		aSorted = @oList._ContentFromEngineList(pList)
		StzEngineListFree(pList)
		for i = 1 to nLen - 1
			if NOT isNumber(aSorted[i])
				return 0
			ok
			if aSorted[i+1] - aSorted[i] != 1
				return 0
			ok
		next
		return 1

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
		aContent = This.Content()
		nLen = len(aContent)
		nHalf = floor(nLen / 2)

		for i = 1 to nHalf
			c1 = @@(aContent[i])
			c2 = @@(aContent[nLen - i + 1])
			if c1 != c2
				return 0
			ok
		next

		return 1

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
