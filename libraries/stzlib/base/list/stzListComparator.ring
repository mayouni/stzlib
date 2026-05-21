#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTCOMPARATOR          #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List comparator subclass -- equality,      #
#                  diff, common items, union, intersection.    #
#                  For aliases, use stzListComparatorXT.        #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzListComparator from stzList

	def IsEqualToCS(paOtherList, pCaseSensitive)
		if NOT isList(paOtherList)
			return 0
		ok
		if This.NumberOfItems() != len(paOtherList)
			return 0
		ok
		if This.HasSameContentAsCS(paOtherList, pCaseSensitive)
			return 1
		else
			return 0
		ok

	def IsEqualTo(paOtherList)
		return This.IsEqualToCS(paOtherList, 1)

	def CommonItemsCS(paOtherList, pCaseSensitive)
		pA = _EngineListFromContent()
		oTemp = new stzList(paOtherList)
		pB = oTemp._EngineListFromContent()
		pResult = StzEngineListIntersectionCS(pA, pB, pCaseSensitive)
		aResult = StzEngineContentFromList(pResult)
		StzEngineListFree(pResult)
		StzEngineListFree(pB)
		StzEngineListFree(pA)
		return aResult

	def CommonItems(paOtherList)
		return This.CommonItemsCS(paOtherList, 1)

	def UnionCS(paOtherList, pCaseSensitive)
		pA = _EngineListFromContent()
		oTemp = new stzList(paOtherList)
		pB = oTemp._EngineListFromContent()
		pResult = StzEngineListUnionCS(pA, pB, pCaseSensitive)
		aResult = StzEngineContentFromList(pResult)
		StzEngineListFree(pResult)
		StzEngineListFree(pB)
		StzEngineListFree(pA)
		return aResult

	def Union(paOtherList)
		return This.UnionCS(paOtherList, 1)

	def DifferenceCS(paOtherList, pCaseSensitive)
		pA = _EngineListFromContent()
		oTemp = new stzList(paOtherList)
		pB = oTemp._EngineListFromContent()
		pResult = StzEngineListDifferenceCS(pA, pB, pCaseSensitive)
		aResult = StzEngineContentFromList(pResult)
		StzEngineListFree(pResult)
		StzEngineListFree(pB)
		StzEngineListFree(pA)
		return aResult

	def Difference(paOtherList)
		return This.DifferenceCS(paOtherList, 1)

	def IsReverseOfCS(paOtherList, pCaseSensitive)
		return This.IsEqualToCS(ListReversed(paOtherList), pCaseSensitive)

	def IsReverseOf(paOtherList)
		return This.IsReverseOfCS(paOtherList, 1)

	  #======================================================#
	 #   NOT EQUAL                                          #
	#======================================================#

	def IsNotEqualToCS(paOtherList, pCaseSensitive)
		return NOT This.IsEqualToCS(paOtherList, pCaseSensitive)

	def IsNotEqualTo(paOtherList)
		return NOT This.IsEqualTo(paOtherList)

	  #======================================================#
	 #   SYMMETRIC DIFFERENCE                               #
	#======================================================#

	def SymmetricDifferenceCS(paOtherList, pCaseSensitive)
		pA = _EngineListFromContent()
		oTemp = new stzList(paOtherList)
		pB = oTemp._EngineListFromContent()
		pDiff1 = StzEngineListDifferenceCS(pA, pB, pCaseSensitive)
		pDiff2 = StzEngineListDifferenceCS(pB, pA, pCaseSensitive)
		aDiff1 = StzEngineContentFromList(pDiff1)
		aDiff2 = StzEngineContentFromList(pDiff2)
		StzEngineListFree(pDiff2)
		StzEngineListFree(pDiff1)
		StzEngineListFree(pB)
		StzEngineListFree(pA)
		aResult = aDiff1
		nLen = len(aDiff2)
		for i = 1 to nLen
			aResult + aDiff2[i]
		next
		return aResult

	def SymmetricDifference(paOtherList)
		return This.SymmetricDifferenceCS(paOtherList, 1)

	  #======================================================#
	 #   IS SUBSET / SUPERSET                               #
	#======================================================#

	def IsSubsetOfCS(paOtherList, pCaseSensitive)
		pA = _EngineListFromContent()
		oTemp = new stzList(paOtherList)
		pB = oTemp._EngineListFromContent()
		nResult = StzEngineListIsSubsetCS(pA, pB, pCaseSensitive)
		StzEngineListFree(pB)
		StzEngineListFree(pA)
		return nResult

	def IsSubsetOf(paOtherList)
		return This.IsSubsetOfCS(paOtherList, 1)

	def IsSupersetOfCS(paOtherList, pCaseSensitive)
		oTemp = new stzList(paOtherList)
		pA = oTemp._EngineListFromContent()
		pB = _EngineListFromContent()
		nResult = StzEngineListIsSubsetCS(pA, pB, pCaseSensitive)
		StzEngineListFree(pB)
		StzEngineListFree(pA)
		return nResult

	def IsSupersetOf(paOtherList)
		return This.IsSupersetOfCS(paOtherList, 1)

	  #======================================================#
	 #   CONTAINS                                           #
	#======================================================#

	def ContainsCS(pItem, pCaseSensitive)
		return This.FindFirstCS(pItem, pCaseSensitive) > 0

	def Contains(pItem)
		return This.ContainsCS(pItem, 1)

	def ContainsAllOfTheseCS(paItems, pCaseSensitive)
		nLen = len(paItems)
		for i = 1 to nLen
			if NOT This.ContainsCS(paItems[i], pCaseSensitive)
				return 0
			ok
		next
		return 1

	def ContainsAllOfThese(paItems)
		return This.ContainsAllOfTheseCS(paItems, 1)

	def ContainsOneOfTheseCS(paItems, pCaseSensitive)
		nLen = len(paItems)
		for i = 1 to nLen
			if This.ContainsCS(paItems[i], pCaseSensitive)
				return 1
			ok
		next
		return 0

	def ContainsOneOfThese(paItems)
		return This.ContainsOneOfTheseCS(paItems, 1)

	  #======================================================#
	 #   IS SAME SIZE AS                                    #
	#======================================================#

	def IsSameSizeAs(paOtherList)
		return This.NumberOfItems() = len(paOtherList)

		def HasSameLengthAs(paOtherList)
			return This.IsSameSizeAs(paOtherList)

	  #======================================================#
	 #   IS SORTED LIKE                                     #
	#======================================================#

	def IsSortedLike(paOtherList)
		aContent = This.Content()
		nLen = len(aContent)
		nLen2 = len(paOtherList)
		if nLen != nLen2
			return 0
		ok
		if nLen < 2
			return 1
		ok
		for i = 1 to nLen - 1
			bThisAsc = BothAreEqual(aContent[i], aContent[i+1]) or StzFind([""+aContent[i]], ""+aContent[i+1]) >= 0
			bOtherAsc = BothAreEqual(paOtherList[i], paOtherList[i+1]) or StzFind([""+paOtherList[i]], ""+paOtherList[i+1]) >= 0
			if bThisAsc != bOtherAsc
				return 0
			ok
		next
		return 1

	  #======================================================#
	 #   STARTS WITH / ENDS WITH                            #
	#======================================================#

	def StartsWithCS(paItems, pCaseSensitive)
		nLen = len(paItems)
		if nLen > This.NumberOfItems()
			return 0
		ok
		aContent = This.Content()
		for i = 1 to nLen
			if NOT BothAreEqualCS(aContent[i], paItems[i], pCaseSensitive)
				return 0
			ok
		next
		return 1

	def StartsWith(paItems)
		return This.StartsWithCS(paItems, 1)

	def EndsWithCS(paItems, pCaseSensitive)
		nLen = len(paItems)
		nTotal = This.NumberOfItems()
		if nLen > nTotal
			return 0
		ok
		aContent = This.Content()
		nStart = nTotal - nLen + 1
		j = 1
		for i = nStart to nTotal
			if NOT BothAreEqualCS(aContent[i], paItems[j], pCaseSensitive)
				return 0
			ok
			j++
		next
		return 1

	def EndsWith(paItems)
		return This.EndsWithCS(paItems, 1)

	  #======================================================#
	 #   ITEMS NOT IN OTHER                                 #
	#======================================================#

	def ItemsNotInCS(paOtherList, pCaseSensitive)
		return This.DifferenceCS(paOtherList, pCaseSensitive)

	def ItemsNotIn(paOtherList)
		return This.Difference(paOtherList)

	  #======================================================#
	 #   IS PERMUTATION OF                                  #
	#======================================================#

	def IsPermutationOfCS(paOtherList, pCaseSensitive)
		if This.NumberOfItems() != len(paOtherList)
			return 0
		ok
		pA = _EngineListFromContent()
		oTemp = new stzList(paOtherList)
		pB = oTemp._EngineListFromContent()
		nAsubB = StzEngineListIsSubsetCS(pA, pB, pCaseSensitive)
		nBsubA = StzEngineListIsSubsetCS(pB, pA, pCaseSensitive)
		StzEngineListFree(pB)
		StzEngineListFree(pA)
		return nAsubB and nBsubA

	def IsPermutationOf(paOtherList)
		return This.IsPermutationOfCS(paOtherList, 1)
