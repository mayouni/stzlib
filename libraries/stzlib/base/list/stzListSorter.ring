#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTSORTER              #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List sorter subclass -- sorting, reversing, #
#                  classifying operations.                      #
#                  For aliases, use stzListSorterXT.            #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzListSorter from stzObject

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
			StzRaise("Can't create stzListSorter! Parameter must be a list or stzList object.")
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
		return new stzListSorter( @oList.Content() )

	def UpdateWith(paNewContent)
		@oList.UpdateWith(paNewContent)

	def Update(paNewContent)
		@oList.UpdateWith(paNewContent)

	  #=============================#
	 #  SORTING ORDER OF THE LIST  #
	#=============================#

	def SortingOrder()
		_cSoResult_ = :Unsorted

		if This.IsSorted()
			if This.IsSortedInAscending()
				_cSoResult_ = :Ascending
			else
				_cSoResult_ = :Descending
			ok
		ok

		return _cSoResult_

	def HasSameSortingOrderAs(paOtherList)
		if _ListSortingOrder(paOtherList) = This.SortingOrder()
			return 1
		else
			return 0
		ok

		def HasSameOrderAs(paOtherList)
			return This.HasSameSortingOrderAs(paOtherList)

	  #-----------------------------------#
	 #  IS THE LIST SORTED OR UNSORTED?  #
	#-----------------------------------#

	def IsSorted()
		if This.IsSortedInAscending() or
		   This.IsSortedInDescending()
			return 1
		else
			return 0
		ok

	def IsSortedInAscending()
		_pIsaList_ = @oList._EngineListFromContent()
		_bIsaResult_ = StzEngineListIsSortedAscending(_pIsaList_)
		StzEngineListFree(_pIsaList_)
		return _bIsaResult_

		def IsSortedUp()
			return This.IsSortedInAscending()

	def IsSortedInDescending()
		_pIsdList_ = @oList._EngineListFromContent()
		_bIsdResult_ = StzEngineListIsSortedDescending(_pIsdList_)
		StzEngineListFree(_pIsdList_)
		return _bIsdResult_

		def IsSortedDown()
			return This.IsSortedInDescending()

	def IsUnsorted()
		return NOT This.IsSorted()

	  #----------------------------------#
	 #  SORTING THE ITEMS IN ASCENDING  #
	#----------------------------------#

	def SortInAscending()
		_pSaList_ = @oList._EngineListFromContent()
		StzEngineListSortCS(_pSaList_, 1)
		This.UpdateWith(@oList._ContentFromEngineList(_pSaList_))
		StzEngineListFree(_pSaList_)

		def SortInAscendingQ()
			This.SortInAscending()
			return This

		def Sort()
			This.SortInAscending()

			def SortQ()
				return This.SortInAscendingQ()

		def SortUp()
			This.SortInAscending()

	def SortedInAscending()
		_aSdaResult_ = This.Copy().SortInAscendingQ().Content()
		return _aSdaResult_

		def Sorted()
			return This.SortedInAscending()

		def SortedUp()
			return This.SortedInAscending()

	  #-----------------------------------#
	 #  SORTING THE ITEMS IN DESCENDING  #
	#-----------------------------------#

	def SortInDescending()
		_pSdList_ = @oList._EngineListFromContent()
		StzEngineListSortDescendingCS(_pSdList_, 1)
		This.UpdateWith(@oList._ContentFromEngineList(_pSdList_))
		StzEngineListFree(_pSdList_)

		def SortInDescendingQ()
			This.SortInDescending()
			return This

		def SortDown()
			This.SortInDescending()

	def SortedInDescending()
		_aSddResult_ = This.Copy().SortInDescendingQ().Content()
		return _aSddResult_

		def SortedDown()
			return This.SortedInDescending()

	  #--------------------------------------------#
	 #  SORTING BY AN EVALUATED EXPRESSION        #
	#--------------------------------------------#

	def SortByInAscending(pcExpr)
		_pSbaList_ = @oList._EngineListFromContent()
		if _pSbaList_ = NULL return ok

		StzEngineListSortByExpr(_pSbaList_, pcExpr, 1)
		This.UpdateWith(@oList._ContentFromEngineList(_pSbaList_))
		StzEngineListFree(_pSbaList_)

		def SortBy(pcExpr)
			This.SortByInAscending(pcExpr)

	def SortByInDescending(pcExpr)
		_pSbdList_ = @oList._EngineListFromContent()
		if _pSbdList_ = NULL return ok

		StzEngineListSortByExpr(_pSbdList_, pcExpr, 0)
		This.UpdateWith(@oList._ContentFromEngineList(_pSbdList_))
		StzEngineListFree(_pSbdList_)

	  #-------------------------------------#
	 #  REVERSING ITEMS ORDER IN THE LIST  #
	#-------------------------------------#

	def Reverse()
		_pRvList_ = @oList._EngineListFromContent()
		StzEngineListReverse(_pRvList_)
		This.UpdateWith(@oList._ContentFromEngineList(_pRvList_))
		StzEngineListFree(_pRvList_)

		def ReverseQ()
			This.Reverse()
			return This

		def ReverseItems()
			This.Reverse()

	def Reversed()
		_pRdList_ = @oList._EngineListFromContent()
		StzEngineListReverse(_pRdList_)
		_aRdResult_ = @oList._ContentFromEngineList(_pRdList_)
		StzEngineListFree(_pRdList_)
		return _aRdResult_

		def ItemsReversed()
			return This.Reversed()

	  #==============================#
	 #    CLASSIFYING              #
	#==============================#

	def Classify()
		# Delegate to engine-backed stzListClassifier
		_oCfClassifier_ = new stzListClassifier(@oList)
		return _oCfClassifier_.Classify()

		def Categorize()
			return This.Classify()

		def Categorise()
			return This.Classify()

	  #==============================#
	 #    STABLE SORT BY KEY        #
	#==============================#

	def SortedBy(pcExpr)
		_oCopy_ = This.Copy()
		_oCopy_.SortByInAscending(pcExpr)
		return _oCopy_.Content()

		def SortedByInAscending(pcExpr)
			return This.SortedBy(pcExpr)

	def SortedByInDescending(pcExpr)
		_oCopy_ = This.Copy()
		_oCopy_.SortByInDescending(pcExpr)
		return _oCopy_.Content()

	  #==============================#
	 #    MIN / MAX ITEMS           #
	#==============================#

	def Min()
		if This.NumberOfItems() = 0
			return NULL
		ok

		# Engine-backed O(n) min for numeric lists
		_pMnList_ = @oList._EngineListFromContent()
		_nMnResult_ = StzEngineListMin(_pMnList_)
		StzEngineListFree(_pMnList_)
		return _nMnResult_

		def Minimum()
			return This.Min()

	def Max()
		if This.NumberOfItems() = 0
			return NULL
		ok

		# Engine-backed O(n) max for numeric lists
		_pMxList_ = @oList._EngineListFromContent()
		_nMxResult_ = StzEngineListMax(_pMxList_)
		StzEngineListFree(_pMxList_)
		return _nMxResult_

		def Maximum()
			return This.Max()

	def MinMax()
		return [ This.Min(), This.Max() ]

	  #==============================#
	 #    RANKING (ORDINAL POS)     #
	#==============================#

	def Ranked()
		_pRkList_ = @oList._EngineListFromContent()
		_pRkRanked_ = StzEngineListRanked(_pRkList_)
		StzEngineListFree(_pRkList_)
		_aRkResult_ = @oList._ContentFromEngineList(_pRkRanked_)
		StzEngineListFree(_pRkRanked_)
		return _aRkResult_

		def Ranks()
			return This.Ranked()

	  #==============================#
	 #    NTH SMALLEST / LARGEST   #
	#==============================#

	def NthSmallest(n)
		_pNsList_ = @oList._EngineListFromContent()
		_nNsResult_ = StzEngineListNthSmallest(_pNsList_, n)
		StzEngineListFree(_pNsList_)
		return _nNsResult_

	def NthLargest(n)
		_pNlList_ = @oList._EngineListFromContent()
		_nNlResult_ = StzEngineListNthLargest(_pNlList_, n)
		StzEngineListFree(_pNlList_)
		return _nNlResult_

	  #==============================#
	 #    MEDIAN                    #
	#==============================#

	def Median()
		_pMdList_ = @oList._EngineListFromContent()
		_nMdResult_ = StzEngineListMedian(_pMdList_)
		StzEngineListFree(_pMdList_)
		return _nMdResult_
