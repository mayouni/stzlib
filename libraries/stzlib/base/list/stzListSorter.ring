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

class stzListSorter

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
		cResult = :Unsorted

		if This.IsSorted()
			if This.IsSortedInAscending()
				cResult = :Ascending
			else
				cResult = :Descending
			ok
		ok

		return cResult

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
		pList = @oList._EngineListFromContent()
		bResult = StzEngineListIsSortedAscending(pList)
		StzEngineListFree(pList)
		return bResult

		def IsSortedUp()
			return This.IsSortedInAscending()

	def IsSortedInDescending()
		pList = @oList._EngineListFromContent()
		bResult = StzEngineListIsSortedDescending(pList)
		StzEngineListFree(pList)
		return bResult

		def IsSortedDown()
			return This.IsSortedInDescending()

	def IsUnsorted()
		return NOT This.IsSorted()

	  #----------------------------------#
	 #  SORTING THE ITEMS IN ASCENDING  #
	#----------------------------------#

	def SortInAscending()
		pList = @oList._EngineListFromContent()
		StzEngineListSortCS(pList, 1)
		This.UpdateWith(@oList._ContentFromEngineList(pList))
		StzEngineListFree(pList)

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
		aResult = This.Copy().SortInAscendingQ().Content()
		return aResult

		def Sorted()
			return This.SortedInAscending()

		def SortedUp()
			return This.SortedInAscending()

	  #-----------------------------------#
	 #  SORTING THE ITEMS IN DESCENDING  #
	#-----------------------------------#

	def SortInDescending()
		pList = @oList._EngineListFromContent()
		StzEngineListSortDescendingCS(pList, 1)
		This.UpdateWith(@oList._ContentFromEngineList(pList))
		StzEngineListFree(pList)

		def SortInDescendingQ()
			This.SortInDescending()
			return This

		def SortDown()
			This.SortInDescending()

	def SortedInDescending()
		aResult = This.Copy().SortInDescendingQ().Content()
		return aResult

		def SortedDown()
			return This.SortedInDescending()

	  #--------------------------------------------#
	 #  SORTING BY AN EVALUATED EXPRESSION        #
	#--------------------------------------------#

	def SortByInAscending(pcExpr)
		pList = @oList._EngineListFromContent()
		if pList = NULL return ok

		StzEngineListSortByExpr(pList, pcExpr, 1)
		This.UpdateWith(@oList._ContentFromEngineList(pList))
		StzEngineListFree(pList)

		def SortBy(pcExpr)
			This.SortByInAscending(pcExpr)

	def SortByInDescending(pcExpr)
		pList = @oList._EngineListFromContent()
		if pList = NULL return ok

		StzEngineListSortByExpr(pList, pcExpr, 0)
		This.UpdateWith(@oList._ContentFromEngineList(pList))
		StzEngineListFree(pList)

	  #-------------------------------------#
	 #  REVERSING ITEMS ORDER IN THE LIST  #
	#-------------------------------------#

	def Reverse()
		pList = @oList._EngineListFromContent()
		StzEngineListReverse(pList)
		This.UpdateWith(@oList._ContentFromEngineList(pList))
		StzEngineListFree(pList)

		def ReverseQ()
			This.Reverse()
			return This

		def ReverseItems()
			This.Reverse()

	def Reversed()
		pList = @oList._EngineListFromContent()
		StzEngineListReverse(pList)
		aResult = @oList._ContentFromEngineList(pList)
		StzEngineListFree(pList)
		return aResult

		def ItemsReversed()
			return This.Reversed()

	  #==============================#
	 #    CLASSIFYING              #
	#==============================#

	def Classify()
		# Delegate to engine-backed stzListClassifier
		oClassifier = new stzListClassifier(@oList)
		return oClassifier.Classify()

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
		pList = @oList._EngineListFromContent()
		nResult = StzEngineListMin(pList)
		StzEngineListFree(pList)
		return nResult

		def Minimum()
			return This.Min()

	def Max()
		if This.NumberOfItems() = 0
			return NULL
		ok

		# Engine-backed O(n) max for numeric lists
		pList = @oList._EngineListFromContent()
		nResult = StzEngineListMax(pList)
		StzEngineListFree(pList)
		return nResult

		def Maximum()
			return This.Max()

	def MinMax()
		return [ This.Min(), This.Max() ]

	  #==============================#
	 #    RANKING (ORDINAL POS)     #
	#==============================#

	def Ranked()
		pList = @oList._EngineListFromContent()
		pRanked = StzEngineListRanked(pList)
		StzEngineListFree(pList)
		aResult = @oList._ContentFromEngineList(pRanked)
		StzEngineListFree(pRanked)
		return aResult

		def Ranks()
			return This.Ranked()

	  #==============================#
	 #    NTH SMALLEST / LARGEST   #
	#==============================#

	def NthSmallest(n)
		pList = @oList._EngineListFromContent()
		nResult = StzEngineListNthSmallest(pList, n)
		StzEngineListFree(pList)
		return nResult

	def NthLargest(n)
		pList = @oList._EngineListFromContent()
		nResult = StzEngineListNthLargest(pList, n)
		StzEngineListFree(pList)
		return nResult

	  #==============================#
	 #    MEDIAN                    #
	#==============================#

	def Median()
		pList = @oList._EngineListFromContent()
		nResult = StzEngineListMedian(pList)
		StzEngineListFree(pList)
		return nResult
