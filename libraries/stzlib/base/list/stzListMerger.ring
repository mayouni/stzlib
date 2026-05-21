#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTMERGER              #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List merger subclass -- merge and          #
#                  associate operations.                        #
#                  For aliases, use stzListMergerXT.            #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzListMerger from stzList

	def Merge()
		aContent = This.Content()
		nLen = This.NumberOfItems()
		aResult = []
		for i = 1 to nLen
			if isList(aContent[i])
				nLenList = len(aContent[i])
				for j = 1 to nLenList
					aResult + aContent[i][j]
				next
			else
				aResult + aContent[i]
			ok
		next
		This.Update(aResult)

		def MergeQ()
			This.Merge()
			return This

	def Merged()
		aResult = This.Copy().MergeQ().Content()
		return aResult

	def MergeWith(paOtherList)
		nLen = len(paOtherList)
		for i = 1 to nLen
			This.Add(paOtherList[i])
		next

		def MergeWithQ(paOtherList)
			This.MergeWith(paOtherList)
			return This

	def MergedWith(paOtherList)
		aResult = This.Copy().MergeWithQ(paOtherList).Content()
		return aResult

	def AssociateWith(paOtherList)
		aContent = This.Content()
		nLen = This.NumberOfItems()
		nLenOther = len(paOtherList)
		aResult = []
		for i = 1 to nLen
			if i <= nLenOther
				aResult + [aContent[i], paOtherList[i]]
			else
				aResult + [aContent[i], ""]
			ok
		next
		return aResult

		def AssociateWithQ(paOtherList)
			return new stzList(This.AssociateWith(paOtherList))

	def AssociatedWith(paOtherList)
		return This.AssociateWith(paOtherList)

	  #======================================================#
	 #   FLATTEN (DEEP MERGE)                               #
	#======================================================#

	def Flatten()
		aResult = []
		This._FlattenHelper(This.Content(), aResult)
		This.UpdateWith(aResult)

		def FlattenQ()
			This.Flatten()
			return This

	def _FlattenHelper(aList, aResult)
		nLen = len(aList)
		for i = 1 to nLen
			if isList(aList[i])
				This._FlattenHelper(aList[i], aResult)
			else
				aResult + aList[i]
			ok
		next

	def Flattened()
		return This.Copy().FlattenQ().Content()

	  #======================================================#
	 #   MERGE MANY LISTS                                   #
	#======================================================#

	def MergeWithMany(paLists)
		nLen = len(paLists)
		for i = 1 to nLen
			This.MergeWith(paLists[i])
		next

		def MergeWithManyQ(paLists)
			This.MergeWithMany(paLists)
			return This

	def MergedWithMany(paLists)
		return This.Copy().MergeWithManyQ(paLists).Content()

	  #======================================================#
	 #   INTERLEAVE                                         #
	#======================================================#

	def InterleaveWith(paOtherList)
		aContent = This.Content()
		nLen1 = len(aContent)
		nLen2 = len(paOtherList)
		nMax = nLen1
		if nLen2 > nMax nMax = nLen2 ok
		aResult = []
		for i = 1 to nMax
			if i <= nLen1
				aResult + aContent[i]
			ok
			if i <= nLen2
				aResult + paOtherList[i]
			ok
		next
		This.UpdateWith(aResult)

		def InterleaveWithQ(paOtherList)
			This.InterleaveWith(paOtherList)
			return This

	def InterleavedWith(paOtherList)
		return This.Copy().InterleaveWithQ(paOtherList).Content()

	  #======================================================#
	 #   ZIP -- PAIR ITEMS FROM TWO LISTS                   #
	#======================================================#

	def ZipWith(paOtherList)
		aContent = This.Content()
		nLen1 = len(aContent)
		nLen2 = len(paOtherList)
		nMin = nLen1
		if nLen2 < nMin nMin = nLen2 ok
		aResult = []
		for i = 1 to nMin
			aResult + [aContent[i], paOtherList[i]]
		next
		return aResult

		def ZipWithQ(paOtherList)
			return new stzList(This.ZipWith(paOtherList))

	def ZippedWith(paOtherList)
		return This.ZipWith(paOtherList)

	  #======================================================#
	 #   UNZIP -- SPLIT PAIRS INTO TWO LISTS                #
	#======================================================#

	def Unzip()
		aContent = This.Content()
		nLen = len(aContent)
		aFirst = []
		aSecond = []
		for i = 1 to nLen
			if isList(aContent[i]) and len(aContent[i]) >= 2
				aFirst + aContent[i][1]
				aSecond + aContent[i][2]
			ok
		next
		return [aFirst, aSecond]

		def UnzipQ()
			return new stzList(This.Unzip())

	def Unzipped()
		return This.Unzip()

	  #======================================================#
	 #   PREPEND LIST                                       #
	#======================================================#

	def PrependWith(paOtherList)
		nLen = len(paOtherList)
		aContent = This.Content()
		aResult = []
		for i = 1 to nLen
			aResult + paOtherList[i]
		next
		nLen2 = len(aContent)
		for i = 1 to nLen2
			aResult + aContent[i]
		next
		This.UpdateWith(aResult)

		def PrependWithQ(paOtherList)
			This.PrependWith(paOtherList)
			return This

	def PrependedWith(paOtherList)
		return This.Copy().PrependWithQ(paOtherList).Content()

	  #======================================================#
	 #   DIFF -- ITEMS IN THIS BUT NOT IN OTHER             #
	#======================================================#

	def DiffWith(paOtherList)
		pList1 = _EngineListFromContent()
		oTemp = new stzList(paOtherList)
		pList2 = oTemp._EngineListFromContent()
		pResult = StzEngineListDifferenceCS(pList1, pList2, 1)
		StzEngineListFree(pList1)
		StzEngineListFree(pList2)

		aResult = StzEngineContentFromList(pResult)
		StzEngineListFree(pResult)
		return aResult

		def DiffWithQ(paOtherList)
			return new stzList(This.DiffWith(paOtherList))

		def Minus(paOtherList)
			return This.DiffWith(paOtherList)

	  #======================================================#
	 #   INTERSECT -- ITEMS IN BOTH LISTS                   #
	#======================================================#

	def IntersectWith(paOtherList)
		pList1 = _EngineListFromContent()
		oTemp = new stzList(paOtherList)
		pList2 = oTemp._EngineListFromContent()
		pResult = StzEngineListIntersectionCS(pList1, pList2, 1)
		StzEngineListFree(pList1)
		StzEngineListFree(pList2)

		aResult = StzEngineContentFromList(pResult)
		StzEngineListFree(pResult)
		return aResult

		def IntersectWithQ(paOtherList)
			return new stzList(This.IntersectWith(paOtherList))

		def CommonWith(paOtherList)
			return This.IntersectWith(paOtherList)

	  #======================================================#
	 #   UNION -- ALL UNIQUE ITEMS FROM BOTH LISTS          #
	#======================================================#

	def UnionWith(paOtherList)
		pList1 = _EngineListFromContent()
		oTemp = new stzList(paOtherList)
		pList2 = oTemp._EngineListFromContent()
		pResult = StzEngineListUnionCS(pList1, pList2, 1)
		StzEngineListFree(pList1)
		StzEngineListFree(pList2)

		aResult = StzEngineContentFromList(pResult)
		StzEngineListFree(pResult)
		return aResult

		def UnionWithQ(paOtherList)
			return new stzList(This.UnionWith(paOtherList))
