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

# Reorders the items of a list: moves one item to another position, swaps two, reverses, rotates, shuffles, or brings an item to either end.
#
# It is the reordering helper of stzList, which builds one over itself for its Move, Swap,
# MoveToStart, MoveToEnd and SwapFirstAndLast methods; build one with new stzListMover when you only
# need to reorder. It works on its own copy, so a stzList passed in is never changed, and you read
# the result with Content. A verb (Move, Swap, Reverse, RotateLeft, Shuffle ...) reorders the held
# list in place and returns nothing, its Q form returning the mover for chaining; the past-tense
# forms (Reversed, RotatedLeft, RotatedRight, Shuffled) return a reordered copy and leave the mover
# alone. Positions count from 1, and a position outside the list moves nothing and says nothing.
# Move and Swap accept the pair forms [ :From, 2 ] and [ :To, 5 ], [ :Between, 2 ] and [ :And, 3 ].
# A rotation count larger than the list wraps around, and a negative one kills the Ring process
# today. Shuffle gives a different order on every call.
#
#   receiver   o1 = new stzListMover([ "a", "b", "c", "d", "e" ])
#   example    ? @@( o1.Reversed() )
#              #--> [ "e", "d", "c", "b", "a" ]
#              ? @@( o1.RotatedLeft(2) )
#              #--> [ "c", "d", "e", "a", "b" ]
#              o1.Move(1, 4)
#              ? @@( o1.Content() )
#              #--> [ "b", "c", "d", "a", "e" ]
#              o1.Swap(1, 5)
#              ? @@( o1.Content() )
#              #--> [ "e", "c", "d", "a", "b" ]
#              o1.MoveItemToStart("d")
#              ? @@( o1.Content() )
#              #--> [ "d", "e", "c", "a", "b" ]
#              o2 = new stzListMover([ "שלום", "😀", "x" ])
#              o2.MoveToStart(3)
#              ? @@( o2.Content() )
#              #--> [ "x", "שלום", "😀" ]
#   see        stzList, stzListSorter, stzListSplits
class stzListMover from stzObject

	@oList

	  #===================#
	 #   INITIALIZATION  #
	#===================#

	# Builds a mover over a list, given as a list or as a stzList object.
	#
	#   pListOrObj   the list to reorder, or a stzList whose content is copied, any other value
	#                raises an error
	#   returns      nothing; the object is built
	#   note         the mover works on its own copy: reordering it never changes the list or the
	#                stzList you passed in, so read the result with Content
	#   see          Content, Reversed
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

	# Returns the list as it stands now, after the in-place moves made so far.
	#
	#   returns    a list
	#   see        List, Reversed
	def Content()
		return @oList.Content()

	# Returns the list as it stands now.
	#
	#   returns    a list
	#   note       the same answer as Content
	#   see        Content, NumberOfItems
	def List()
		return @oList.List()

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

	# Takes the item at one position and puts it at another, the items in between shifting by one, in place.
	#
	#   _n1_       the position to take the item from, or a pair such as [ :From, 2 ]
	#   _n2_       the position the item must end at, or a pair such as [ :To, 5 ]
	#   returns    nothing; the content changes. MoveQ returns the mover for chaining
	#   note       a position outside the list moves nothing and says nothing: Move(9, 1) leaves a b
	#              c d e as it was
	#   see        Swap, MoveToStart, MoveToEnd
	def Move(_n1_, _n2_)
		# Unconditionally accept named-param forms (the test suite
		# uses several spellings: :From, :ItemFromPosition,
		# :CharFromPosition, etc.).
		if isList(_n1_) and len(_n1_) = 2 and isString(_n1_[1])
			_kw_ = lower(_n1_[1])
			if _kw_ = "from" or _kw_ = "fromposition" or _kw_ = "at" or
			   _kw_ = "atposition" or _kw_ = "itemfromposition" or
			   _kw_ = "charfromposition" or _kw_ = "position"
				_n1_ = _n1_[2]
			ok
		ok
		if isList(_n2_) and len(_n2_) = 2 and isString(_n2_[1])
			_kw_ = lower(_n2_[1])
			if _kw_ = "to" or _kw_ = "toposition" or _kw_ = "topositon"
				_n2_ = _n2_[2]
			ok
		ok
		if NOT (isNumber(_n1_) and isNumber(_n2_)) return ok
		# Work on a local copy and write back -- Ring returns lists
		# from methods by value, so mutating This.List() in place is
		# silently lost.
		_aMv_ = This.List()
		_nL_ = len(_aMv_)
		if _n1_ < 1 or _n1_ > _nL_ or _n2_ < 1 or _n2_ > _nL_ return ok
		_mvItem_ = _aMv_[_n1_]
		ring_remove(_aMv_, _n1_)
		# ring_insert places the value AT the given position, and after
		# the removal the target position needs no further adjustment.
		ring_insert(_aMv_, _n2_, _mvItem_)
		@oList.Update(_aMv_)

		def MoveQ(_n1_, _n2_)
			This.Move(_n1_, _n2_)
			return This

	# Exchanges the items at two positions, in place.
	#
	#   _n1_       the first position, or a pair such as [ :Between, 2 ]
	#   _n2_       the second position, or a pair such as [ :And, 3 ]
	#   returns    nothing; the content changes. SwapQ returns the mover for chaining
	#   note       a position outside the list exchanges nothing and says nothing: Swap(1, 9) leaves
	#              a b c as it was
	#   see        Move, SwapFirstAndLast
	def Swap(_n1_, _n2_)
		if CheckingParams()
			if isList(_n1_) and IsOneOfTheseNamedParamsList(_n1_, [:Between, :BetweenPosition, :Position, :ItemAt])
				_n1_ = _n1_[2]
			ok
			if isList(_n2_) and IsOneOfTheseNamedParamsList(_n2_, [:And, :AndPosition, :Position])
				_n2_ = _n2_[2]
			ok
		ok

		_pSwList_ = @oList._EngineListFromContent()
		if _pSwList_ != ""
			StzEngineListSwap(_pSwList_, _n1_, _n2_)
			@oList.UpdateWith(@oList._ContentFromEngineList(_pSwList_))
			StzEngineListFree(_pSwList_)
			return
		ok

		_swTemp_ = This.List()[_n1_]
		This.List()[_n1_] = This.List()[_n2_]
		This.List()[_n2_] = _swTemp_

		def SwapQ(_n1_, _n2_)
			This.Swap(_n1_, _n2_)
			return This

	# Takes the item at a position and puts it first, in place.
	#
	#   n          the position of the item to move
	#   returns    nothing; the content changes. MoveToStartQ returns the mover for chaining
	#   note       a position outside the list moves nothing; MoveToFirst is the same call
	#   see        MoveToEnd, Move, MoveItemToStart
	def MoveToStart(n)
		This.Move(n, 1)

		def MoveToStartQ(n)
			This.MoveToStart(n)
			return This

		# Takes the item at a position and puts it first, in place.
		#
		#   n          the position of the item to move
		#   returns    nothing; the content changes
		#   note       the same call as MoveToStart
		#   see        MoveToStart, MoveToLast
		def MoveToFirst(n)
			This.MoveToStart(n)

	# Takes the item at a position and puts it last, in place.
	#
	#   n          the position of the item to move
	#   returns    nothing; the content changes. MoveToEndQ returns the mover for chaining
	#   note       a position outside the list moves nothing; MoveToLast is the same call
	#   see        MoveToStart, Move, MoveItemToEnd
	def MoveToEnd(n)
		This.Move(n, This.NumberOfItems())

		def MoveToEndQ(n)
			This.MoveToEnd(n)
			return This

		# Takes the item at a position and puts it last, in place.
		#
		#   n          the position of the item to move
		#   returns    nothing; the content changes
		#   note       the same call as MoveToEnd
		#   see        MoveToEnd, MoveToFirst
		def MoveToLast(n)
			This.MoveToEnd(n)

	  #======================================================#
	 #   SWAP FIRST AND LAST                                #
	#======================================================#

	# Exchanges the first and the last items, in place.
	#
	#   returns    nothing; the content changes. SwapFirstAndLastQ returns the mover for chaining
	#   note       a list of one item or an empty list is left as it is
	#   see        Swap, Move
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

	# Reverses the order of the items, in place.
	#
	#   returns    nothing; the content changes. ReverseQ returns the mover for chaining
	#   see        Reversed, RotateLeft
	def Reverse()
		_pRevList_ = @oList._EngineListFromContent()
		if _pRevList_ != ""
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

	# Returns the items in the opposite order, leaving the mover as it was.
	#
	#   returns    a list
	#   see        Reverse, RotatedLeft
	def Reversed()
		_oRdCopy_ = new stzListMover(This.Content())
		_oRdCopy_.Reverse()
		return _oRdCopy_.Content()

	  #======================================================#
	 #   ROTATE -- CIRCULAR SHIFT                           #
	#======================================================#

	# Moves the first n items to the end, in place, the others shifting toward the start.
	#
	#   n          how many items go from the front to the back
	#   returns    nothing; the content changes. RotateLeftQ returns the mover for chaining
	#   note       an n larger than the list wraps around, so 7 on 5 items is 2; 0 changes nothing
	#   warning    a negative n kills the whole Ring process with panic: integer part of floating
	#              point value out of bounds in stz_list.dll (RotatedLeft(-1) on 1 to 5, and
	#              RotateRight(-1) on x y z)
	#   see        RotatedLeft, RotateRight
	def RotateLeft(n)
		_pRlList_ = @oList._EngineListFromContent()
		StzEngineListRotateLeft(_pRlList_, n)
		@oList.UpdateWith(StzEngineListContentToRingList(_pRlList_))
		StzEngineListFree(_pRlList_)

		def RotateLeftQ(n)
			This.RotateLeft(n)
			return This

	# Returns the items with the first n moved to the end, leaving the mover as it was.
	#
	#   n          how many items go from the front to the back
	#   returns    a list
	#   note       an n larger than the list wraps around, so 7 on 5 items is 2
	#   warning    a negative n kills the whole Ring process, as in RotateLeft
	#   see        RotateLeft, RotatedRight
	def RotatedLeft(n)
		_oRldCopy_ = new stzListMover(This.Content())
		_oRldCopy_.RotateLeft(n)
		return _oRldCopy_.Content()

	# Moves the last n items to the front, in place, the others shifting toward the end.
	#
	#   n          how many items go from the back to the front
	#   returns    nothing; the content changes. RotateRightQ returns the mover for chaining
	#   note       an n larger than the list wraps around; 0 changes nothing
	#   warning    a negative n kills the whole Ring process, as in RotateLeft
	#   see        RotatedRight, RotateLeft
	def RotateRight(n)
		_pRrList_ = @oList._EngineListFromContent()
		StzEngineListRotateRight(_pRrList_, n)
		@oList.UpdateWith(StzEngineListContentToRingList(_pRrList_))
		StzEngineListFree(_pRrList_)

		def RotateRightQ(n)
			This.RotateRight(n)
			return This

	# Returns the items with the last n moved to the front, leaving the mover as it was.
	#
	#   n          how many items go from the back to the front
	#   returns    a list
	#   note       an n larger than the list wraps around
	#   warning    a negative n kills the whole Ring process, as in RotateLeft
	#   see        RotateRight, RotatedLeft
	def RotatedRight(n)
		_oRrdCopy_ = new stzListMover(This.Content())
		_oRrdCopy_.RotateRight(n)
		return _oRrdCopy_.Content()

	  #======================================================#
	 #   SHUFFLE -- RANDOM REORDER                          #
	#======================================================#

	# Puts the items in a random order, in place.
	#
	#   returns    nothing; the content changes. ShuffleQ returns the mover for chaining
	#   note       the order is different on every call
	#   see        Shuffled, Reverse
	def Shuffle()
		_pShufList_ = @oList._EngineListFromContent()
		if _pShufList_ != ""
			StzEngineListShuffle(_pShufList_)
			@oList.UpdateWith(@oList._ContentFromEngineList(_pShufList_))
			StzEngineListFree(_pShufList_)
			return
		ok

		_aShufContent_ = This.Content()
		_nShufLen_ = len(_aShufContent_)
		for _iShuf_ = _nShufLen_ to 2 step -1
			_jShuf_ = StzEngineRandomInt(0, _iShuf_ - 1) + 1
			_shufTemp_ = _aShufContent_[_iShuf_]
			_aShufContent_[_iShuf_] = _aShufContent_[_jShuf_]
			_aShufContent_[_jShuf_] = _shufTemp_
		next
		@oList.UpdateWith(_aShufContent_)

		def ShuffleQ()
			This.Shuffle()
			return This

	# Returns the items in a random order, leaving the mover as it was.
	#
	#   returns    a list
	#   note       the order is different on every call
	#   see        Shuffle, Reversed
	def Shuffled()
		_oShufCopy_ = new stzListMover(This.Content())
		_oShufCopy_.Shuffle()
		return _oShufCopy_.Content()

	  #======================================================#
	 #   MOVE ITEM BY VALUE                                 #
	#======================================================#

	# Finds the first occurrence of an item and puts it first, in place.
	#
	#   pItem      the item to move, looked up with case
	#   returns    nothing; the content changes
	#   note       an absent item changes nothing; only the first occurrence moves
	#   see        MoveItemToEnd, MoveToStart
	def MoveItemToStart(pItem)
		_anMisPos_ = @oList.FindAll(pItem)
		if len(_anMisPos_) > 0
			This.MoveToStart(_anMisPos_[1])
		ok

	# Finds the first occurrence of an item and puts it last, in place.
	#
	#   pItem      the item to move, looked up with case
	#   returns    nothing; the content changes
	#   note       an absent item changes nothing; only the first occurrence moves, so a b a becomes
	#              b a a
	#   see        MoveItemToStart, MoveToEnd
	def MoveItemToEnd(pItem)
		_anMiePos_ = @oList.FindAll(pItem)
		if len(_anMiePos_) > 0
			This.MoveToEnd(_anMiePos_[1])
		ok
