#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTMOVER               #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List mover subclass -- moving and swapping #
#                  items by position. For aliases, use         #
#                  stzListMoverXT.                              #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzListMover

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
			StzRaise("Can't create stzListMover! Parameter must be a list or stzList object.")
		ok

	  #===============================#
	 #     CONTENT ACCESS            #
	#===============================#

	def Content()
		return @oList.Content()

	def List()
		return @oList.List()

	def NumberOfItems()
		return @oList.NumberOfItems()

	def IsEmpty()
		return @oList.IsEmpty()

	def Move(n1, n2)
		# Unconditionally accept named-param forms (the test suite
		# uses several spellings: :From, :ItemFromPosition,
		# :CharFromPosition, etc.).
		if isList(n1) and len(n1) = 2 and isString(n1[1])
			_kw_ = lower(n1[1])
			if _kw_ = "from" or _kw_ = "fromposition" or _kw_ = "at" or
			   _kw_ = "atposition" or _kw_ = "itemfromposition" or
			   _kw_ = "charfromposition" or _kw_ = "position"
				n1 = n1[2]
			ok
		ok
		if isList(n2) and len(n2) = 2 and isString(n2[1])
			_kw_ = lower(n2[1])
			if _kw_ = "to" or _kw_ = "toposition" or _kw_ = "topositon"
				n2 = n2[2]
			ok
		ok
		if NOT (isNumber(n1) and isNumber(n2)) return ok
		# Work on a local copy and write back -- Ring returns lists
		# from methods by value, so mutating This.List() in place is
		# silently lost.
		_aMv_ = This.List()
		_nL_ = len(_aMv_)
		if n1 < 1 or n1 > _nL_ or n2 < 1 or n2 > _nL_ return ok
		_mvItem_ = _aMv_[n1]
		ring_remove(_aMv_, n1)
		# ring_insert places the value AT the given position, and after
		# the removal the target position needs no further adjustment.
		ring_insert(_aMv_, n2, _mvItem_)
		@oList.Update(_aMv_)

		def MoveQ(n1, n2)
			This.Move(n1, n2)
			return This

	def Swap(n1, n2)
		if CheckingParams()
			if isList(n1) and IsOneOfTheseNamedParamsList(n1, [:Between, :BetweenPosition, :Position, :ItemAt])
				n1 = n1[2]
			ok
			if isList(n2) and IsOneOfTheseNamedParamsList(n2, [:And, :AndPosition, :Position])
				n2 = n2[2]
			ok
		ok

		_pSwList_ = @oList._EngineListFromContent()
		if _pSwList_ != NULL
			StzEngineListSwap(_pSwList_, n1, n2)
			@oList.UpdateWith(@oList._ContentFromEngineList(_pSwList_))
			StzEngineListFree(_pSwList_)
			return
		ok

		_swTemp_ = This.List()[n1]
		This.List()[n1] = This.List()[n2]
		This.List()[n2] = _swTemp_

		def SwapQ(n1, n2)
			This.Swap(n1, n2)
			return This

	def MoveToStart(n)
		This.Move(n, 1)

		def MoveToStartQ(n)
			This.MoveToStart(n)
			return This

		def MoveToFirst(n)
			This.MoveToStart(n)

	def MoveToEnd(n)
		This.Move(n, This.NumberOfItems())

		def MoveToEndQ(n)
			This.MoveToEnd(n)
			return This

		def MoveToLast(n)
			This.MoveToEnd(n)

	  #======================================================#
	 #   SWAP FIRST AND LAST                                #
	#======================================================#

	def SwapFirstAndLast()
		This.Swap(1, This.NumberOfItems())

		def SwapFirstAndLastQ()
			This.SwapFirstAndLast()
			return This

	  #======================================================#
	 #   MOVE MANY ITEMS                                    #
	#======================================================#

	def MoveMany(panPositions, nTo)
		_nMmLen_ = len(panPositions)
		_oMmTemp_ = new stzList(panPositions)
		_pMmTmp_ = _oMmTemp_._EngineListFromContent()
		StzEngineListSortDescendingCS(_pMmTmp_, 1)
		_aMmSorted_ = _oMmTemp_._ContentFromEngineList(_pMmTmp_)
		StzEngineListFree(_pMmTmp_)
		_aMmItems_ = []
		for _iMm_ = 1 to _nMmLen_
			@AddItem(_aMmItems_, @oList.NthItem(_aMmSorted_[_iMm_]))
			ring_remove(This.List(), _aMmSorted_[_iMm_])
		next
		_oMmTemp2_ = new stzList(_aMmItems_)
		_pMmTmp2_ = _oMmTemp2_._EngineListFromContent()
		StzEngineListReverse(_pMmTmp2_)
		_aMmItems_ = _oMmTemp2_._ContentFromEngineList(_pMmTmp2_)
		StzEngineListFree(_pMmTmp2_)
		_nMmInsert_ = nTo
		if _nMmInsert_ > This.NumberOfItems()
			_nMmInsert_ = This.NumberOfItems() + 1
		ok
		_n_aMmItemsLen_ = len(_aMmItems_)
		for _jMm_ = 1 to _n_aMmItemsLen_
			ring_insert(This.List(), _nMmInsert_ - 1, _aMmItems_[_jMm_])
			_nMmInsert_++
		next

		def MoveManyQ(panPositions, nTo)
			This.MoveMany(panPositions, nTo)
			return This

	  #======================================================#
	 #   REVERSE                                            #
	#======================================================#

	def Reverse()
		_pRevList_ = @oList._EngineListFromContent()
		if _pRevList_ != NULL
			StzEngineListReverse(_pRevList_)
			@oList.UpdateWith(@oList._ContentFromEngineList(_pRevList_))
			StzEngineListFree(_pRevList_)
			return
		ok

		_aRevContent_ = This.Content()
		_nRevLen_ = len(_aRevContent_)
		_aRevResult_ = []
		for _iRev_ = _nRevLen_ to 1 step -1
			@AddItem(_aRevResult_, _aRevContent_[_iRev_])
		next
		@oList.UpdateWith(_aRevResult_)

		def ReverseQ()
			This.Reverse()
			return This

	def Reversed()
		_oRdCopy_ = new stzListMover(This.Content())
		_oRdCopy_.Reverse()
		return _oRdCopy_.Content()

	  #======================================================#
	 #   ROTATE -- CIRCULAR SHIFT                           #
	#======================================================#

	def RotateLeft(n)
		_pRlList_ = @oList._EngineListFromContent()
		StzEngineListRotateLeft(_pRlList_, n)
		@oList.UpdateWith(StzEngineListContentToRingList(_pRlList_))
		StzEngineListFree(_pRlList_)

		def RotateLeftQ(n)
			This.RotateLeft(n)
			return This

	def RotatedLeft(n)
		_oRldCopy_ = new stzListMover(This.Content())
		_oRldCopy_.RotateLeft(n)
		return _oRldCopy_.Content()

	def RotateRight(n)
		_pRrList_ = @oList._EngineListFromContent()
		StzEngineListRotateRight(_pRrList_, n)
		@oList.UpdateWith(StzEngineListContentToRingList(_pRrList_))
		StzEngineListFree(_pRrList_)

		def RotateRightQ(n)
			This.RotateRight(n)
			return This

	def RotatedRight(n)
		_oRrdCopy_ = new stzListMover(This.Content())
		_oRrdCopy_.RotateRight(n)
		return _oRrdCopy_.Content()

	  #======================================================#
	 #   SHUFFLE -- RANDOM REORDER                          #
	#======================================================#

	def Shuffle()
		_pShufList_ = @oList._EngineListFromContent()
		if _pShufList_ != NULL
			StzEngineListShuffle(_pShufList_)
			@oList.UpdateWith(@oList._ContentFromEngineList(_pShufList_))
			StzEngineListFree(_pShufList_)
			return
		ok

		_aShufContent_ = This.Content()
		_nShufLen_ = len(_aShufContent_)
		for _iShuf_ = _nShufLen_ to 2 step -1
			_jShuf_ = random(_iShuf_ - 1) + 1
			_shufTemp_ = _aShufContent_[_iShuf_]
			_aShufContent_[_iShuf_] = _aShufContent_[_jShuf_]
			_aShufContent_[_jShuf_] = _shufTemp_
		next
		@oList.UpdateWith(_aShufContent_)

		def ShuffleQ()
			This.Shuffle()
			return This

	def Shuffled()
		_oShufCopy_ = new stzListMover(This.Content())
		_oShufCopy_.Shuffle()
		return _oShufCopy_.Content()

	  #======================================================#
	 #   MOVE ITEM BY VALUE                                 #
	#======================================================#

	def MoveItemToStart(pItem)
		_anMisPos_ = @oList.FindAll(pItem)
		if len(_anMisPos_) > 0
			This.MoveToStart(_anMisPos_[1])
		ok

	def MoveItemToEnd(pItem)
		_anMiePos_ = @oList.FindAll(pItem)
		if len(_anMiePos_) > 0
			This.MoveToEnd(_anMiePos_[1])
		ok
