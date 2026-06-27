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

class stzListComparator

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
			StzRaise("Can't create stzListComparator! Parameter must be a list or stzList object.")
		ok

	  #===============================#
	 #     CONTENT ACCESS            #
	#===============================#

	def Content()
		return @oList.Content()

	def NumberOfItems()
		return @oList.NumberOfItems()

	def IsEmpty()
		return @oList.IsEmpty()

	  #===============================#
	 #     COMPARISON METHODS        #
	#===============================#

	def IsEqualToCS(paOtherList, pCaseSensitive)
		# Set-based equality: same items regardless of order
		if NOT isList(paOtherList)
			return 0
		ok
		if This.NumberOfItems() != len(paOtherList)
			return 0
		ok
		# Mutual subset check via engine
		_pCmpA_ = @oList._EngineListFromContent()
		_oCmpTemp_ = new stzList(paOtherList)
		_pCmpB_ = _oCmpTemp_._EngineListFromContent()
		_nCmpAsubB_ = StzEngineListIsSubsetCS(_pCmpA_, _pCmpB_, pCaseSensitive)
		_nCmpBsubA_ = StzEngineListIsSubsetCS(_pCmpB_, _pCmpA_, pCaseSensitive)
		StzEngineListFree(_pCmpB_)
		StzEngineListFree(_pCmpA_)
		return _nCmpAsubB_ and _nCmpBsubA_

	def IsEqualTo(paOtherList)
		return This.IsEqualToCS(paOtherList, 1)

	def CommonItemsCS(paOtherList, pCaseSensitive)
		pA = @oList._EngineListFromContent()
		oTemp = new stzList(paOtherList)
		pB = oTemp._EngineListFromContent()
		pResult = StzEngineListIntersectionCS(pA, pB, pCaseSensitive)
		aResult = StzEngineListContentToRingList(pResult)
		StzEngineListFree(pResult)
		StzEngineListFree(pB)
		StzEngineListFree(pA)
		return aResult

	def CommonItems(paOtherList)
		return This.CommonItemsCS(paOtherList, 1)

	def UnionCS(paOtherList, pCaseSensitive)
		pA = @oList._EngineListFromContent()
		oTemp = new stzList(paOtherList)
		pB = oTemp._EngineListFromContent()
		pResult = StzEngineListUnionCS(pA, pB, pCaseSensitive)
		aResult = StzEngineListContentToRingList(pResult)
		StzEngineListFree(pResult)
		StzEngineListFree(pB)
		StzEngineListFree(pA)
		return aResult

	def Union(paOtherList)
		return This.UnionCS(paOtherList, 1)

	def DifferenceCS(paOtherList, pCaseSensitive)
		pA = @oList._EngineListFromContent()
		oTemp = new stzList(paOtherList)
		pB = oTemp._EngineListFromContent()
		pResult = StzEngineListDifferenceCS(pA, pB, pCaseSensitive)
		aResult = StzEngineListContentToRingList(pResult)
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
	 #   STRICT EQUALITY (SAME CONTENT + SAME ORDER)        #
	#======================================================#

	def IsStrictlyEqualToCS(paOtherList, pCaseSensitive)
		# Strictly equal = same items at same positions (order matters)
		if NOT isList(paOtherList)
			return 0
		ok
		_pSeA_ = @oList._EngineListFromContent()
		_pSeB_ = StzEngineMarshalList(paOtherList)
		_nSeResult_ = StzEngineListEqualsCS(_pSeA_, _pSeB_, pCaseSensitive)
		StzEngineListFree(_pSeB_)
		StzEngineListFree(_pSeA_)
		return _nSeResult_

		def IsIdenticalToCS(paOtherList, pCaseSensitive)
			return This.IsStrictlyEqualToCS(paOtherList, pCaseSensitive)

		def IsEqualToCSXT(paOtherList, pCaseSensitive)
			return This.IsStrictlyEqualToCS(paOtherList, pCaseSensitive)

	def IsStrictlyEqualTo(paOtherList)
		return This.IsStrictlyEqualToCS(paOtherList, 1)

		def IsIdenticalTo(paOtherList)
			return This.IsStrictlyEqualTo(paOtherList)

		def IsEqualToXT(paOtherList)
			return This.IsStrictlyEqualTo(paOtherList)

	  #======================================================#
	 #   SYMMETRIC DIFFERENCE                               #
	#======================================================#

	def SymmetricDifferenceCS(paOtherList, pCaseSensitive)
		pA = @oList._EngineListFromContent()
		oTemp = new stzList(paOtherList)
		pB = oTemp._EngineListFromContent()
		pDiff1 = StzEngineListDifferenceCS(pA, pB, pCaseSensitive)
		pDiff2 = StzEngineListDifferenceCS(pB, pA, pCaseSensitive)
		aDiff1 = StzEngineListContentToRingList(pDiff1)
		aDiff2 = StzEngineListContentToRingList(pDiff2)
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
		pA = @oList._EngineListFromContent()
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
		pB = @oList._EngineListFromContent()
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
		return @oList.ContainsCS(pItem, pCaseSensitive)

	def Contains(pItem)
		return This.ContainsCS(pItem, 1)

	def ContainsAllOfTheseCS(paItems, pCaseSensitive)
		_nCatLen_ = len(paItems)
		for _iCat_ = 1 to _nCatLen_
			if NOT This.ContainsCS(paItems[_iCat_], pCaseSensitive)
				return 0
			ok
		next
		return 1

	def ContainsAllOfThese(paItems)
		return This.ContainsAllOfTheseCS(paItems, 1)

	def ContainsOneOfTheseCS(paItems, pCaseSensitive)
		_nCotLen_ = len(paItems)
		for _iCot_ = 1 to _nCotLen_
			if This.ContainsCS(paItems[_iCot_], pCaseSensitive)
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
			bThisAsc = BothAreEqual(aContent[i], aContent[i+1]) or StzFindFirst([""+aContent[i]], ""+aContent[i+1]) >= 0
			bOtherAsc = BothAreEqual(paOtherList[i], paOtherList[i+1]) or StzFindFirst([""+paOtherList[i]], ""+paOtherList[i+1]) >= 0
			if bThisAsc != bOtherAsc
				return 0
			ok
		next
		return 1

	  #======================================================#
	 #   STARTS WITH / ENDS WITH                            #
	#======================================================#

	def StartsWithCS(paItems, pCaseSensitive)
		_pSwList_ = @oList._EngineListFromContent()
		_pSwPrefix_ = StzEngineMarshalList(paItems)
		_nSwResult_ = StzEngineListStartsWithListCS(_pSwList_, _pSwPrefix_, pCaseSensitive)
		StzEngineListFree(_pSwPrefix_)
		StzEngineListFree(_pSwList_)
		return _nSwResult_

	def StartsWith(paItems)
		return This.StartsWithCS(paItems, 1)

	def EndsWithCS(paItems, pCaseSensitive)
		_pEwList_ = @oList._EngineListFromContent()
		_pEwSuffix_ = StzEngineMarshalList(paItems)
		_nEwResult_ = StzEngineListEndsWithListCS(_pEwList_, _pEwSuffix_, pCaseSensitive)
		StzEngineListFree(_pEwSuffix_)
		StzEngineListFree(_pEwList_)
		return _nEwResult_

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
		pA = @oList._EngineListFromContent()
		oTemp = new stzList(paOtherList)
		pB = oTemp._EngineListFromContent()
		nAsubB = StzEngineListIsSubsetCS(pA, pB, pCaseSensitive)
		nBsubA = StzEngineListIsSubsetCS(pB, pA, pCaseSensitive)
		StzEngineListFree(pB)
		StzEngineListFree(pA)
		return nAsubB and nBsubA

	def IsPermutationOf(paOtherList)
		return This.IsPermutationOfCS(paOtherList, 1)
