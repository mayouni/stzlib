#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTINSERTER            #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List inserter subclass -- inserting items,  #
#                  moving, swapping operations.                 #
#                  For aliases, use stzListInserterXT.          #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzListInserter from stzObject

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
			StzRaise("Can't create stzListInserter! Parameter must be a list or stzList object.")
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

	  #===================================================#
	 #     INSERTING AN ITEM BEFORE A GIVEN POSITION     #
	#===================================================#

	def Insert(pItem, pWhere)

		if isList(pItem) and IsItemNamedParamList(pItem)
			pItem = pItem[2]
		ok

		if isList(pWhere)

			if IsOneOfTheseNamedParamsList(pWhere, [
				:At, :AtPosition, :Before, :BeforePosition ])

				This.InsertBefore(pWhere[2], pItem)
				return

			but IsOneOfTheseNamedParamsList(pWhere, [ :After, :AfterPosition ])

				This.InsertAfter(pWhere[2], pItem)
				return
			ok
		else
			This.InsertBefore(pWhere, pItem)
		ok

		def InsertQ(pItem, pWhere)
			This.Insert( pItem, pWhere )
			return This

		def InsertItem(pItem, pWhere)
			This.Insert(pItem, pWhere)

	def InsertBeforePosition(n, pItem)
		if isList(n) and IsPositionNamedParamList(n)
			n = n[2]
		ok

		if isList(n) and IsListOfNumbers(n)
			This.InsertBeforePositions(n, pItem)
			return
		ok

		if isList(pItem) and IsItemNamedParamList(pItem)
			pItem = pItem[2]
		ok

		if n >= 1 and n <= This.NumberOfItems()
			ring_insert(@oList.List(), n-1, pItem)

		but n > This.NumberofItems()
			@oList.ExtendToN(n)
			ring_insert(@oList.List(), n-1, pItem)
		ok

		def InsertBeforePositionQ(n, pItem)
			This.InsertBeforePosition(n, pItem)
			return This

		def InsertBefore(n, pItem)
			This.InsertBeforePosition(n, pItem)

		def InsertAt(n, pItem)
			if isList(n) and IsOneOfTheseNamedParamsList(n, [ :Position, :ItemAt, :ItemAtPosition ])
				n = n[2]
			ok

			_aIatContent_ = @oList.Content()
			ring_insert(_aIatContent_, n, pItem)
			@oList.UpdateWith(_aIatContent_)

			def InsertAtQ(n, pItem)
				This.InsertAt(n, pItem)
				return This

	  #----------------------------------------------------#
	 #     INSERTING AN ITEM AFTER A GIVEN POSITION      #
	#----------------------------------------------------#

	def InsertAfterPosition(n, pItem)

		if isList(n) and IsListOfNumbers(n)
			This.InsertAfterPositions(n, pItem)
			return
		ok

		if n > 0 and n < This.NumberOfItems()
			ring_insert(@oList.List(), n, pItem)
		ok

		def InsertAfterPositionQ(n, pItem)
			This.InsertAfterPosition(n, pItem)
			return This

		def InsertAfter(n, pItem)
			This.InsertAfterPosition(n, pItem)

	  #---------------------------------------------#
	 #  INSERTING BEFORE MANY POSITIONS            #
	#---------------------------------------------#

	def InsertBeforePositions(panPositions, pItem)
		if isList(pItem) and IsItemNamedParamList(pItem)
			pItem = pItem[2]
		ok

		_oChain_ = new stzList(panPositions)

		panPositions = _oChain_.Sorted()
		_nIbpLen_ = len(panPositions)

		for _iIbp_ = _nIbpLen_ to 1 step -1
			This.InsertBeforePosition(panPositions[_iIbp_], pItem)
		next

		def InsertBeforePositionsQ(panPositions, pItem)
			This.InsertBeforePositions(panPositions, pItem)
			return This

	  #=============================================#
	 #  MOVING ITEM AT POSITION N1 TO POSITION N2 #
	#=============================================#

	def MoveItem(n1, n2)

		if isList(n1) and IsFromNamedParamList(n1)
			n1 = n1[2]
		ok

		if isList(n2) and IsToNamedParamList(n2)
			n2 = n2[2]
		ok

		if NOT (isNumber(n1) and isNumber(n2))
			StzRaise("Incorrect param types! n1 and n2 must be numbers.")
		ok

		if n1 < 1 or n1 > This.NumberOfItems() or
		   n2 < 1 or n2 > This.NumberOfItems()
			StzRaise("Position out of range!")
		ok

		_pMiItem_ = @oList.Item(n1)
		@oList.RemoveItemAtPosition(n1)

		if n2 > n1
			n2 = n2 - 1
		ok

		This.InsertBeforePosition(n2, _pMiItem_)

		def MoveItemQ(n1, n2)
			This.MoveItem(n1, n2)
			return This

	  #=========================================#
	 #  SWAPPING ITEMS AT TWO GIVEN POSITIONS  #
	#=========================================#

	def SwapItems(n1, n2)

		if isList(n1) and IsBetweenNamedParamList(n1)
			n1 = n1[2]
		ok

		if isList(n2) and IsAndNamedParamList(n2)
			n2 = n2[2]
		ok

		if NOT (isNumber(n1) and isNumber(n2))
			StzRaise("Incorrect param types! n1 and n2 must be numbers.")
		ok

		_pSwpList_ = @oList._EngineListFromContent()
		if _pSwpList_ != NULL
			StzEngineListSwap(_pSwpList_, n1, n2)
			@oList.UpdateWith(@oList._ContentFromEngineList(_pSwpList_))
			StzEngineListFree(_pSwpList_)
			return
		ok

		_aSwpContent_ = This.Content()
		_swpTemp_ = _aSwpContent_[n1]
		_aSwpContent_[n1] = _aSwpContent_[n2]
		_aSwpContent_[n2] = _swpTemp_
		@oList.UpdateWith(_aSwpContent_)

		def SwapItemsQ(n1, n2)
			This.SwapItems(n1, n2)
			return This

		def Swap(n1, n2)
			This.SwapItems(n1, n2)
