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

class stzListChecker from stzList

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
				c1 = ring_lower(c1)
				c2 = ring_lower(c2)
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
		   ( isString(This.Item(1)) and This.Item(1) = "of" )
			return 1
		else
			return 0
		ok

	def IsWithOrByOrUsingNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and
		     StzFind([ "with", "by", "using" ], This.Item(1)) > 0 )
			return 1
		else
			return 0
		ok

	def IsCaseSensitiveNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = "casesensitive" )
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
		aContent = This.Content()
		nLen = len(aContent)
		for i = 1 to nLen - 1
			for j = i + 1 to nLen
				if BothAreEqual(aContent[i], aContent[j])
					return 0
				ok
			next
		next
		return 1

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

		aSorted = sort(aContent)
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
