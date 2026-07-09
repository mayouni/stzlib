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

	def InsertBeforePosition(_n_, pItem)
		if isList(_n_) and IsPositionNamedParamList(_n_)
			_n_ = _n_[2]
		ok

		if isList(_n_) and IsListOfNumbers(_n_)
			This.InsertBeforePositions(_n_, pItem)
			return
		ok

		if isList(pItem) and IsItemNamedParamList(pItem)
			pItem = pItem[2]
		ok

		if _n_ >= 1 and _n_ <= This.NumberOfItems()
			ring_insert(@oList.List(), _n_-1, pItem)

		but _n_ > This.NumberofItems()
			@oList.ExtendToN(_n_)
			ring_insert(@oList.List(), _n_-1, pItem)
		ok

		def InsertBeforePositionQ(_n_, pItem)
			This.InsertBeforePosition(_n_, pItem)
			return This

		def InsertBefore(_n_, pItem)
			This.InsertBeforePosition(_n_, pItem)

		def InsertAt(_n_, pItem)
			if isList(_n_) and IsOneOfTheseNamedParamsList(_n_, [ :Position, :ItemAt, :ItemAtPosition ])
				_n_ = _n_[2]
			ok

			_aIatContent_ = @oList.Content()
			ring_insert(_aIatContent_, _n_, pItem)
			@oList.UpdateWith(_aIatContent_)

			def InsertAtQ(_n_, pItem)
				This.InsertAt(_n_, pItem)
				return This

	  #----------------------------------------------------#
	 #     INSERTING AN ITEM AFTER A GIVEN POSITION      #
	#----------------------------------------------------#

	def InsertAfterPosition(_n_, pItem)

		if isList(_n_) and IsListOfNumbers(_n_)
			This.InsertAfterPositions(_n_, pItem)
			return
		ok

		if _n_ > 0 and _n_ < This.NumberOfItems()
			ring_insert(@oList.List(), _n_, pItem)
		ok

		def InsertAfterPositionQ(_n_, pItem)
			This.InsertAfterPosition(_n_, pItem)
			return This

		def InsertAfter(_n_, pItem)
			This.InsertAfterPosition(_n_, pItem)

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

	def MoveItem(_n1_, _n2_)

		if isList(_n1_) and IsFromNamedParamList(_n1_)
			_n1_ = _n1_[2]
		ok

		if isList(_n2_) and IsToNamedParamList(_n2_)
			_n2_ = _n2_[2]
		ok

		if NOT (isNumber(_n1_) and isNumber(_n2_))
			StzRaise("Incorrect param types! n1 and n2 must be numbers.")
		ok

		if _n1_ < 1 or _n1_ > This.NumberOfItems() or
		   _n2_ < 1 or _n2_ > This.NumberOfItems()
			StzRaise("Position out of range!")
		ok

		_pMiItem_ = @oList.Item(_n1_)
		@oList.RemoveItemAtPosition(_n1_)

		if _n2_ > _n1_
			_n2_ = _n2_ - 1
		ok

		This.InsertBeforePosition(_n2_, _pMiItem_)

		def MoveItemQ(_n1_, _n2_)
			This.MoveItem(_n1_, _n2_)
			return This

	  #=========================================#
	 #  SWAPPING ITEMS AT TWO GIVEN POSITIONS  #
	#=========================================#

	def SwapItems(_n1_, _n2_)

		if isList(_n1_) and IsBetweenNamedParamList(_n1_)
			_n1_ = _n1_[2]
		ok

		if isList(_n2_) and IsAndNamedParamList(_n2_)
			_n2_ = _n2_[2]
		ok

		if NOT (isNumber(_n1_) and isNumber(_n2_))
			StzRaise("Incorrect param types! n1 and n2 must be numbers.")
		ok

		_pSwpList_ = @oList._EngineListFromContent()
		if _pSwpList_ != NULL
			StzEngineListSwap(_pSwpList_, _n1_, _n2_)
			@oList.UpdateWith(@oList._ContentFromEngineList(_pSwpList_))
			StzEngineListFree(_pSwpList_)
			return
		ok

		_aSwpContent_ = This.Content()
		_swpTemp_ = _aSwpContent_[_n1_]
		_aSwpContent_[_n1_] = _aSwpContent_[_n2_]
		_aSwpContent_[_n2_] = _swpTemp_
		@oList.UpdateWith(_aSwpContent_)

		def SwapItemsQ(_n1_, _n2_)
			This.SwapItems(_n1_, _n2_)
			return This

		def Swap(_n1_, _n2_)
			This.SwapItems(_n1_, _n2_)
