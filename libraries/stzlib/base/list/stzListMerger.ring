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

# Combines lists: opens sublists, appends, prepends, interleaves, zips and unzips, and takes the union, the intersection or the difference of two lists.
#
# It is the combining helper of stzList, which builds one over itself for its MergeWith,
# AssociateWith, InterleaveWith, ZipWith and similar methods; build one with new stzListMerger when
# you only need to combine. It works on its own copy, so a stzList passed in is never changed. A
# verb (Merge, MergeWith, Flatten, InterleaveWith, PrependWith) changes the held list in place and
# returns nothing, its Q form returning the merger for chaining, while the past-tense form (Merged,
# MergedWith, Flattened, InterleavedWith, PrependedWith) returns the result and leaves the merger
# alone. Merge opens one level of sublists and Flatten opens them all. ZipWith stops at the shorter
# list, AssociateWith pads with an empty text. UnionWith, IntersectWith and DiffWith compare with
# case and take no case flag. Partition cuts into groups of the count divided by n, rounded up.
#
#   receiver   o1 = new stzListMerger([ 1, [ 2, 3 ], [ 4, [ 5, 6 ] ] ])
#   example    ? @@( o1.Merged() )
#              #--> [ 1, 2, 3, 4, [ 5, 6 ] ]
#              ? @@( o1.Flattened() )
#              #--> [ 1, 2, 3, 4, 5, 6 ]
#              o2 = new stzListMerger([ "a", "b", "c" ])
#              ? @@( o2.ZipWith([ 1, 2, 3 ]) )
#              #--> [ [ "a", 1 ], [ "b", 2 ], [ "c", 3 ] ]
#              ? @@( o2.InterleavedWith([ 1, 2, 3 ]) )
#              #--> [ "a", 1, "b", 2, "c", 3 ]
#              o3 = new stzListMerger([ 1, 2, 3, 4, 5 ])
#              ? @@( o3.DiffWith([ 2, 4, 9 ]) )
#              #--> [ 1, 3, 5 ]
#              o4 = new stzListMerger([ "שלום", "😀" ])
#              ? @@( o4.ZipWith([ "a", "b" ]) )
#              #--> [ [ "שלום", "a" ], [ "😀", "b" ] ]
#   see        stzList, stzListSplits, stzListComparator
class stzListMerger from stzObject

	@oList

	  #===================#
	 #   INITIALIZATION  #
	#===================#

	# Builds a merger over a list, given as a list or as a stzList object.
	#
	#   pListOrObj   the list to work on, or a stzList whose content is copied, any other value
	#                raises an error
	#   returns      nothing; the object is built
	#   note         the merger works on its own copy and never changes the list or the stzList you
	#                passed in
	#   see          Content, Merged
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

	# Returns the list as it stands now, after the in-place merges made so far.
	#
	#   returns    a list
	#   see        NumberOfItems, Merged
	def Content()
		return @oList.Content()

	# Returns how many items the list holds.
	#
	#   returns    a number
	#   see        Content, IsEmpty
	def NumberOfItems()
		return @oList.NumberOfItems()

	# TRUE if the list holds no item.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   see        NumberOfItems, Content
	def IsEmpty()
		return @oList.IsEmpty()

	# Returns a new merger over a copy of the list.
	#
	#   returns    a stzListMerger
	#   note       editing the copy leaves this merger alone
	#   see        Content, Merged
	def Copy()
		return new stzListMerger( @oList.Content() )

	# Replaces the list held by the merger with another list.
	#
	#   paNewContent   the list that becomes the content
	#   returns        nothing; the content changes
	#   see            UpdateWith, Content
	def Update(paNewContent)
		@oList.UpdateWith(paNewContent)

	# Replaces the list held by the merger with another list.
	#
	#   paNewContent   the list that becomes the content
	#   returns        nothing; the content changes
	#   note           the same call as Update
	#   see            Update, Content
	def UpdateWith(paNewContent)
		@oList.UpdateWith(paNewContent)

	# Appends one item at the end of the list.
	#
	#   pItem      the item to append, kept whole even when it is a list
	#   returns    nothing; the content changes
	#   note       to append the items of a list one by one, use MergeWith
	#   see        MergeWith, Content
	def Add(pItem)
		@oList.Add(pItem)

	# Opens each sublist one level and puts its items in its place, in place.
	#
	#   returns    nothing; the content changes. MergeQ returns the merger for chaining
	#   note       only one level is opened: [ 1, [ 2, 3 ], [ 4, [ 5, 6 ] ] ] gives [ 1, 2, 3, 4, [
	#              5, 6 ] ]; Flatten opens every level
	#   see        Merged, Flatten, MergeWith
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

	# Returns the list with each sublist opened one level, leaving the merger as it was.
	#
	#   returns    a list
	#   note       only one level is opened, as in Merge
	#   see        Merge, Flattened
	def Merged()
		_aResult_ = This.Copy().MergeQ().Content()
		return _aResult_

	# Appends the items of another list at the end of this one, in place.
	#
	#   paOtherList   the list whose items are appended one by one
	#   returns       nothing; the content changes. MergeWithQ returns the merger for chaining
	#   note          a sublist inside the other list stays a sublist
	#   see           MergedWith, Add, PrependWith
	def MergeWith(paOtherList)
		_nMwLen_ = len(paOtherList)
		for _iMw_ = 1 to _nMwLen_
			This.Add(paOtherList[_iMw_])
		next

		def MergeWithQ(paOtherList)
			This.MergeWith(paOtherList)
			return This

	# Returns the list followed by the items of another list, leaving the merger as it was.
	#
	#   paOtherList   the list whose items are appended
	#   returns       a list
	#   see           MergeWith, PrependedWith
	def MergedWith(paOtherList)
		_aResult_ = This.Copy().MergeWithQ(paOtherList).Content()
		return _aResult_

	# Returns each item paired with the item at the same position in another list.
	#
	#   paOtherList   the list that supplies the counterparts
	#   returns       a list of [ item, counterpart ] pairs
	#   note          when the other list is shorter the missing counterpart is an empty text, where
	#                 ZipWith stops at the shorter list; AssociatedWith is the same call and
	#                 AssociateWithQ returns a stzList
	#   see           ZipWith, MergedWith
	#@ aka  Pair each item with its counterpart in the given list: [ [item, other], ... ].
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

	# The item/counterpart pairs, as data (the passive twin of
	# AssociateWith).
	def AssociatedWith(paOtherList)
		return This.AssociateWith(paOtherList)

	  #======================================================#
	 #   FLATTEN (DEEP MERGE)                               #
	#======================================================#

	# Opens every sublist at every depth and puts its items in its place, in place.
	#
	#   returns    nothing; the content changes. FlattenQ returns the merger for chaining
	#   note       [ 1, [ 2, 3 ], [ 4, [ 5, 6 ] ] ] gives [ 1, 2, 3, 4, 5, 6 ]
	#   see        Flattened, Merge
	def Flatten()
		_aResult_ = []
		This._FlattenHelper(This.Content(), _aResult_)
		This.UpdateWith(_aResult_)

		def FlattenQ()
			This.Flatten()
			return This

	def _FlattenHelper(aList, _aResult_)
		_nFhLen_ = len(aList)
		for _iFh_ = 1 to _nFhLen_
			if isList(aList[_iFh_])
				This._FlattenHelper(aList[_iFh_], _aResult_)
			else
				@AddItem(_aResult_, aList[_iFh_])
			ok
		next

	# Returns the list with every sublist opened at every depth, leaving the merger as it was.
	#
	#   returns    a list
	#   see        Flatten, Merged
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

	# A copy merged with each of the given lists.
	def MergedWithMany(paLists)
		return This.Copy().MergeWithManyQ(paLists).Content()

	  #======================================================#
	 #   INTERLEAVE                                         #
	#======================================================#

	# Alternates the items of the list with those of another list, in place.
	#
	#   paOtherList   the list whose items go between the held ones
	#   returns       nothing; the content changes. InterleaveWithQ returns the merger for chaining
	#   note          the held list leads, and when one list is longer its leftover items follow at
	#                 the end
	#   see           InterleavedWith, ZipWith
	def InterleaveWith(paOtherList)
		pList1 = @oList._Engine()
		_oTemp_ = new stzList(paOtherList)
		pList2 = _oTemp_._EngineListFromContent()
		pResult = StzEngineListInterleave(pList1, pList2)
		StzEngineListFree(pList2)
		_aResult_ = StzEngineListContentToRingList(pResult)
		StzEngineListFree(pResult)
		This.UpdateWith(_aResult_)

		def InterleaveWithQ(paOtherList)
			This.InterleaveWith(paOtherList)
			return This

	# Returns the items of the list alternating with those of another list, leaving the merger as it was.
	#
	#   paOtherList   the list whose items go between the held ones
	#   returns       a list
	#   note          the held list leads, and the leftover items of the longer list follow at the
	#                 end
	#   see           InterleaveWith, ZippedWith
	#@ aka  The items interleaved with the given list's items, alternating.
	def InterleavedWith(paOtherList)
		return This.Copy().InterleaveWithQ(paOtherList).Content()

	  #======================================================#
	 #   ZIP -- PAIR ITEMS FROM TWO LISTS                   #
	#======================================================#

	# Returns each item paired with the item at the same position in another list.
	#
	#   paOtherList   the list that supplies the counterparts
	#   returns       a list of [ item, counterpart ] pairs
	#   note          the pairing stops at the shorter list; ZippedWith is the same call and
	#                 ZipWithQ returns a stzList
	#   see           Unzip, AssociateWith, InterleaveWith
	def ZipWith(paOtherList)
		pList1 = @oList._Engine()
		_oTemp_ = new stzList(paOtherList)
		pList2 = _oTemp_._EngineListFromContent()
		pResult = StzEngineListZip(pList1, pList2)
		StzEngineListFree(pList2)
		_aResult_ = StzEngineListContentToRingList(pResult)
		StzEngineListFree(pResult)
		return _aResult_

		def ZipWithQ(paOtherList)
			return new stzList(This.ZipWith(paOtherList))

	def ZippedWith(paOtherList)
		return This.ZipWith(paOtherList)

	  #======================================================#
	 #   UNZIP -- SPLIT PAIRS INTO TWO LISTS                #
	#======================================================#

	# Splits a list of pairs into the list of their first items and the list of their second items.
	#
	#   returns    a list of two lists
	#   note       an item that is not a list of at least two items is skipped, and only the first
	#              two items of a longer sublist are read; UnzipQ returns a stzList
	#   see        ZipWith, Unzipped
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

	# Puts the items of another list in front of the list, in place.
	#
	#   paOtherList   the list whose items go first
	#   returns       nothing; the content changes. PrependWithQ returns the merger for chaining
	#   note          the other list keeps its own order
	#   see           PrependedWith, MergeWith
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

	# Returns the items of another list followed by the list, leaving the merger as it was.
	#
	#   paOtherList   the list whose items go first
	#   returns       a list
	#   see           PrependWith, MergedWith
	#@ aka  A copy with the given list's items put in front.
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
		_oTemp_ = new stzList(paOtherList)
		pList2 = _oTemp_._EngineListFromContent()
		pResult = StzEngineListDifferenceCS(pList1, pList2, 1)
		StzEngineListFree(pList2)
		return pResult

	# Returns the items of the list that are not in another list.
	#
	#   paOtherList   the list whose items are taken away
	#   returns       a list
	#   note          case counts, and there is no CS form here: A is not taken away by a; items
	#                 that stay keep their repeats, so [ 1, 1, 2, 3, 3 ] minus [ 2 ] is [ 1, 1, 3, 3
	#                 ]; Minus is the same call and DiffWithQ returns a stzList
	#   see           IntersectWith, UnionWith
	def DiffWith(paOtherList)
		pResult = This._DiffHandle(paOtherList)
		_aResult_ = StzEngineListContentToRingList(pResult)
		StzEngineListFree(pResult)
		return _aResult_

		def DiffWithQ(paOtherList)
			return new stzList(This.DiffWith(paOtherList))

		def Minus(paOtherList)
			return This.DiffWith(paOtherList)

	  #======================================================#
	 #   INTERSECT -- ITEMS IN BOTH LISTS                   #
	#======================================================#

	def _IntersectHandle(paOtherList)
		pList1 = @oList._Engine()
		_oTemp_ = new stzList(paOtherList)
		pList2 = _oTemp_._EngineListFromContent()
		pResult = StzEngineListIntersectionCS(pList1, pList2, 1)
		StzEngineListFree(pList2)
		return pResult

	# Returns the items found both in the list and in another list, without repeats.
	#
	#   paOtherList   the list to match against
	#   returns       a list
	#   note          case counts, and there is no CS form here; CommonWith is the same call and
	#                 IntersectWithQ returns a stzList
	#   see           DiffWith, UnionWith
	def IntersectWith(paOtherList)
		pResult = This._IntersectHandle(paOtherList)
		_aResult_ = StzEngineListContentToRingList(pResult)
		StzEngineListFree(pResult)
		return _aResult_

		def IntersectWithQ(paOtherList)
			return new stzList(This.IntersectWith(paOtherList))

		def CommonWith(paOtherList)
			return This.IntersectWith(paOtherList)

	  #======================================================#
	 #   UNION -- ALL UNIQUE ITEMS FROM BOTH LISTS          #
	#======================================================#

	def _UnionHandle(paOtherList)
		pList1 = @oList._Engine()
		_oTemp_ = new stzList(paOtherList)
		pList2 = _oTemp_._EngineListFromContent()
		pResult = StzEngineListUnionCS(pList1, pList2, 1)
		StzEngineListFree(pList2)
		return pResult

	# Returns every item found in the list or in another list, without repeats.
	#
	#   paOtherList   the list whose items are added
	#   returns       a list
	#   note          case counts, and there is no CS form here; the items of the held list come
	#                 first, in order; UnionWithQ returns a stzList
	#   see           IntersectWith, MergedWith
	def UnionWith(paOtherList)
		pResult = This._UnionHandle(paOtherList)
		_aResult_ = StzEngineListContentToRingList(pResult)
		StzEngineListFree(pResult)
		return _aResult_

		def UnionWithQ(paOtherList)
			return new stzList(This.UnionWith(paOtherList))

	  #======================================================#
	 #   PARTITION -- SPLIT INTO N GROUPS                    #
	#======================================================#

	# Cuts the list into consecutive groups of equal size, the last one possibly shorter.
	#
	#   n          the number of groups wanted
	#   returns    a list of lists
	#   note       the group size is the count divided by n, rounded up, so the answer can hold
	#              fewer than n groups: 6 items and n = 4 give 3 groups of 2; n = 0 gives [ ];
	#              PartitionQ returns a stzList and Partitioned is the same call
	#   see        MergedWith, Unzip
	def Partition(n)
		_pList_ = @oList._Engine()
		pResult = StzEngineListPartition(_pList_, n)
		_aResult_ = StzEngineListContentToRingList(pResult)
		StzEngineListFree(pResult)
		return _aResult_

		def PartitionQ(n)
			return new stzList(This.Partition(n))

		def Partitioned(n)
			return This.Partition(n)
