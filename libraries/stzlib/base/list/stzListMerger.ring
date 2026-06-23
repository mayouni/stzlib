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

class stzListMerger

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
			StzRaise("Can't create stzListMerger! Parameter must be a list or stzList object.")
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

	def Copy()
		return new stzListMerger( @oList.Content() )

	def Update(paNewContent)
		@oList.UpdateWith(paNewContent)

	def UpdateWith(paNewContent)
		@oList.UpdateWith(paNewContent)

	def Add(pItem)
		@oList.Add(pItem)

	def Merge()
		_aMrgContent_ = This.Content()
		_nMrgLen_ = This.NumberOfItems()
		_aMrgResult_ = []
		for _iMrg_ = 1 to _nMrgLen_
			if isList(_aMrgContent_[_iMrg_])
				_nMrgLenList_ = len(_aMrgContent_[_iMrg_])
				for _jMrg_ = 1 to _nMrgLenList_
					@AddItem(_aMrgResult_, _aMrgContent_[_iMrg_][_jMrg_])
				next
			else
				@AddItem(_aMrgResult_, _aMrgContent_[_iMrg_])
			ok
		next
		This.Update(_aMrgResult_)

		def MergeQ()
			This.Merge()
			return This

	def Merged()
		aResult = This.Copy().MergeQ().Content()
		return aResult

	def MergeWith(paOtherList)
		_nMwLen_ = len(paOtherList)
		for _iMw_ = 1 to _nMwLen_
			This.Add(paOtherList[_iMw_])
		next

		def MergeWithQ(paOtherList)
			This.MergeWith(paOtherList)
			return This

	def MergedWith(paOtherList)
		aResult = This.Copy().MergeWithQ(paOtherList).Content()
		return aResult

	def AssociateWith(paOtherList)
		_aAwContent_ = This.Content()
		_nAwLen_ = This.NumberOfItems()
		_nAwLenOther_ = len(paOtherList)
		_aAwResult_ = []
		for _iAw_ = 1 to _nAwLen_
			if _iAw_ <= _nAwLenOther_
				@AddItem(_aAwResult_, [_aAwContent_[_iAw_], paOtherList[_iAw_]])
			else
				@AddItem(_aAwResult_, [_aAwContent_[_iAw_], ""])
			ok
		next
		return _aAwResult_

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
		_nFhLen_ = len(aList)
		for _iFh_ = 1 to _nFhLen_
			if isList(aList[_iFh_])
				This._FlattenHelper(aList[_iFh_], aResult)
			else
				@AddItem(aResult, aList[_iFh_])
			ok
		next

	def Flattened()
		return This.Copy().FlattenQ().Content()

	  #======================================================#
	 #   MERGE MANY LISTS                                   #
	#======================================================#

	def MergeWithMany(paLists)
		_nMwmLen_ = len(paLists)
		for _iMwm_ = 1 to _nMwmLen_
			This.MergeWith(paLists[_iMwm_])
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
		pList1 = @oList._Engine()
		oTemp = new stzList(paOtherList)
		pList2 = oTemp._EngineListFromContent()
		pResult = StzEngineListInterleave(pList1, pList2)
		StzEngineListFree(pList2)
		aResult = StzEngineListContentToRingList(pResult)
		StzEngineListFree(pResult)
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
		pList1 = @oList._Engine()
		oTemp = new stzList(paOtherList)
		pList2 = oTemp._EngineListFromContent()
		pResult = StzEngineListZip(pList1, pList2)
		StzEngineListFree(pList2)
		aResult = StzEngineListContentToRingList(pResult)
		StzEngineListFree(pResult)
		return aResult

		def ZipWithQ(paOtherList)
			return new stzList(This.ZipWith(paOtherList))

	def ZippedWith(paOtherList)
		return This.ZipWith(paOtherList)

	  #======================================================#
	 #   UNZIP -- SPLIT PAIRS INTO TWO LISTS                #
	#======================================================#

	def Unzip()
		_aUzContent_ = This.Content()
		_nUzLen_ = len(_aUzContent_)
		_aUzFirst_ = []
		_aUzSecond_ = []
		for _iUz_ = 1 to _nUzLen_
			if isList(_aUzContent_[_iUz_]) and len(_aUzContent_[_iUz_]) >= 2
				@AddItem(_aUzFirst_, _aUzContent_[_iUz_][1])
				@AddItem(_aUzSecond_, _aUzContent_[_iUz_][2])
			ok
		next
		return [_aUzFirst_, _aUzSecond_]

		def UnzipQ()
			return new stzList(This.Unzip())

	def Unzipped()
		return This.Unzip()

	  #======================================================#
	 #   PREPEND LIST                                       #
	#======================================================#

	def PrependWith(paOtherList)
		_nPwLen_ = len(paOtherList)
		_aPwContent_ = This.Content()
		_aPwResult_ = []
		for _iPw_ = 1 to _nPwLen_
			@AddItem(_aPwResult_, paOtherList[_iPw_])
		next
		_nPwLen2_ = len(_aPwContent_)
		for _jPw_ = 1 to _nPwLen2_
			@AddItem(_aPwResult_, _aPwContent_[_jPw_])
		next
		This.UpdateWith(_aPwResult_)

		def PrependWithQ(paOtherList)
			This.PrependWith(paOtherList)
			return This

	def PrependedWith(paOtherList)
		return This.Copy().PrependWithQ(paOtherList).Content()

	  #======================================================#
	 #   DIFF -- ITEMS IN THIS BUT NOT IN OTHER             #
	#======================================================#

	# Returns the engine RESULT HANDLE (a number, not a Ring list) so the
	# caller unmarshals exactly once -- avoids an extra O(n) list copy that a
	# Ring method-return of the list would incur.
	def _DiffHandle(paOtherList)
		pList1 = @oList._Engine()
		oTemp = new stzList(paOtherList)
		pList2 = oTemp._EngineListFromContent()
		pResult = StzEngineListDifferenceCS(pList1, pList2, 1)
		StzEngineListFree(pList2)
		return pResult

	def DiffWith(paOtherList)
		pResult = This._DiffHandle(paOtherList)
		aResult = StzEngineListContentToRingList(pResult)
		StzEngineListFree(pResult)
		return aResult

		def DiffWithQ(paOtherList)
			return new stzList(This.DiffWith(paOtherList))

		def Minus(paOtherList)
			return This.DiffWith(paOtherList)

	  #======================================================#
	 #   INTERSECT -- ITEMS IN BOTH LISTS                   #
	#======================================================#

	def _IntersectHandle(paOtherList)
		pList1 = @oList._Engine()
		oTemp = new stzList(paOtherList)
		pList2 = oTemp._EngineListFromContent()
		pResult = StzEngineListIntersectionCS(pList1, pList2, 1)
		StzEngineListFree(pList2)
		return pResult

	def IntersectWith(paOtherList)
		pResult = This._IntersectHandle(paOtherList)
		aResult = StzEngineListContentToRingList(pResult)
		StzEngineListFree(pResult)
		return aResult

		def IntersectWithQ(paOtherList)
			return new stzList(This.IntersectWith(paOtherList))

		def CommonWith(paOtherList)
			return This.IntersectWith(paOtherList)

	  #======================================================#
	 #   UNION -- ALL UNIQUE ITEMS FROM BOTH LISTS          #
	#======================================================#

	def _UnionHandle(paOtherList)
		pList1 = @oList._Engine()
		oTemp = new stzList(paOtherList)
		pList2 = oTemp._EngineListFromContent()
		pResult = StzEngineListUnionCS(pList1, pList2, 1)
		StzEngineListFree(pList2)
		return pResult

	def UnionWith(paOtherList)
		pResult = This._UnionHandle(paOtherList)
		aResult = StzEngineListContentToRingList(pResult)
		StzEngineListFree(pResult)
		return aResult

		def UnionWithQ(paOtherList)
			return new stzList(This.UnionWith(paOtherList))

	  #======================================================#
	 #   PARTITION -- SPLIT INTO N GROUPS                    #
	#======================================================#

	def Partition(n)
		pList = @oList._Engine()
		pResult = StzEngineListPartition(pList, n)
		aResult = StzEngineListContentToRingList(pResult)
		StzEngineListFree(pResult)
		return aResult

		def PartitionQ(n)
			return new stzList(This.Partition(n))

		def Partitioned(n)
			return This.Partition(n)
