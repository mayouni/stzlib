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

# Inserts items into a list before or after a position, moves an item to another place and swaps two items.
#
# Build one with new stzListInserter(aList) or over a stzList object; it keeps its own copy, so the
# list you passed in is not changed, and Content gives the result. Positions count from 1. Insert,
# InsertBeforePosition and InsertAfterPosition accept the item as a plain value and the place as a
# number or a named pair such as [ :After, 2 ]. Out-of-range positions are not handled the same way
# by every method: most ignore them without a message, InsertAt raises, and a position two or more
# past the end kills the process through a missing method; see the warnings.
#
#   receiver   o1 = new stzListInserter([ "a", "b", "c", "d" ])
#   example    o1.Insert("X", 2)
#              ? @@( o1.Content() )
#              #--> [ "a", "X", "b", "c", "d" ]
#              o1.SwapItems(1, 5)
#              ? @@( o1.Content() )
#              #--> [ "d", "X", "b", "c", "a" ]
#   see        stzList, stzListMover, stzListCounter
class stzListInserter from stzObject

	@oList

	  #===================#
	 #   INITIALIZATION  #
	#===================#

	# Builds an inserter over a list or over a stzList object, working on its own copy, so the list passed in is never changed.
	#
	#   pListOrObj   a list, or a stzList object, in which items will be inserted, moved or swapped
	#   returns      nothing; the object is built
	#   warning      any other kind of value raises "Can't create stzListInserter! Parameter must be
	#                a list or stzList object."
	#   see          Content
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

	# Returns the items the inserter holds, after the insertions made through it.
	#
	#   returns    a list
	#   see        NumberOfItems
	def Content()
		return @oList.Content()

	# Returns how many items the list holds now.
	#
	#   returns    a number
	#   see        Content
	def NumberOfItems()
		return @oList.NumberOfItems()

	# TRUE if the list holds no item.
	#
	#   returns    TRUE or FALSE
	#   see        NumberOfItems
	def IsEmpty()
		return @oList.IsEmpty()

	  #===================================================#
	 #     INSERTING AN ITEM BEFORE A GIVEN POSITION     #
	#===================================================#

	# Inserts an item before a position, or after one when the place is written [ :After, n ].
	#
	#   pItem      the item to insert
	#   pWhere     a position (the item goes before it), or a named place such as [ :At, 2 ], [
	#              :Before, 2 ] or [ :After, 2 ]
	#   returns    nothing; use InsertQ to chain
	#   note       a position one past the end appends
	#   warning    a position of 0, or a named place that is neither of those (such as [ :Foo, 1 ]),
	#              is ignored without a message; a position two or more past the end kills the
	#              process with R14 (ExtendToN), see InsertBeforePosition
	#   see        InsertBeforePosition, InsertAfterPosition
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

		# Inserts an item before a position, or after one when the place is written [ :After, n ], the same as Insert.
		#
		#   pItem      the item to insert
		#   pWhere     a position (the item goes before it), or a named place such as [ :At, 2 ] or
		#              [ :After, 2 ]
		#   returns    nothing
		#   see        Insert
		def InsertItem(pItem, pWhere)
			This.Insert(pItem, pWhere)

	# Inserts an item so that it takes the given position, pushing the item there and the ones after it one place on.
	#
	#   _n_        the position to take, from 1
	#   pItem      the item to insert
	#   returns    nothing; use InsertBeforePositionQ to chain
	#   note       positions in a list are all counted on the original list
	#   warning    a position two or more past the end calls ExtendToN, which does not exist, and
	#              kills the process with error R14; a position of 0 or below is ignored without a
	#              message
	#   see        InsertAfterPosition, InsertBeforePositions
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
			ring_insert(@oList.List(), _n_, pItem)

		but _n_ > This.NumberofItems()
			# one past the end appends; further out, the list is first extended up to n-1
			if _n_ > This.NumberOfItems() + 1
				@oList.ExtendToN(_n_ - 1)
			ok
			_aIbpContent_ = @oList.Content()
			_aIbpContent_ + pItem
			@oList.UpdateWith(_aIbpContent_)
		ok

		def InsertBeforePositionQ(_n_, pItem)
			This.InsertBeforePosition(_n_, pItem)
			return This

		# Inserts an item so that it takes the given position, the same as InsertBeforePosition.
		#
		#   _n_        the position to take, from 1
		#   pItem      the item to insert
		#   returns    nothing
		#   warning    the same R14 process kill for a position two or more past the end; 0 or below
		#              is ignored without a message
		#   see        InsertBeforePosition
		def InsertBefore(_n_, pItem)
			This.InsertBeforePosition(_n_, pItem)

		# Inserts an item so that it takes the given position, handing the work to Ring's insert.
		#
		#   _n_        the position the item takes, from 1
		#   pItem      the item to insert
		#   returns    nothing; use InsertAtQ to chain
		#   note       one past the end appends
		#   warning    A position of 0 or below raises an error with no message (ERR-) and a
		#              position past the end plus one raises R2 today, where InsertBefore ignores 0
		#              and appends one past the end; only 1 up to the length plus one works
		#   see        InsertBefore
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

	# Inserts an item right after the given position, so it takes the position after it.
	#
	#   _n_        the position to insert after, from 1 to the length
	#   pItem      the item to insert
	#   returns    nothing; use InsertAfterPositionQ to chain
	#   note       the last position appends
	#   warning    a position of 0, or past the length, is ignored without a message; a list of
	#              positions calls InsertAfterPositions, which does not exist, and kills the process
	#              with error R14
	#   see        InsertBeforePosition, InsertAfter
	def InsertAfterPosition(_n_, pItem)

		if isList(_n_) and IsListOfNumbers(_n_)
			This.InsertAfterPositions(_n_, pItem)
			return
		ok

		if _n_ > 0 and _n_ <= This.NumberOfItems()
			# after position n = the item takes position n+1 (n = the last position appends)
			_aIapContent_ = @oList.Content()
			_aIapOut_ = []
			_nIapLen_ = len(_aIapContent_)
			for _iIap_ = 1 to _nIapLen_
				_aIapOut_ + _aIapContent_[_iIap_]
				if _iIap_ = _n_
					_aIapOut_ + pItem
				ok
			next
			@oList.UpdateWith(_aIapOut_)
		ok

		def InsertAfterPositionQ(_n_, pItem)
			This.InsertAfterPosition(_n_, pItem)
			return This

		# Inserts an item right after the given position, the same as InsertAfterPosition.
		#
		#   _n_        the position to insert after, from 1 to the length
		#   pItem      the item to insert
		#   returns    nothing
		#   warning    an out-of-range position is ignored without a message; a list of positions
		#              kills the process with error R14, as in InsertAfterPosition
		#   see        InsertAfterPosition
		def InsertAfter(_n_, pItem)
			This.InsertAfterPosition(_n_, pItem)

	  #---------------------------------------------#
	 #  INSERTING BEFORE MANY POSITIONS            #
	#---------------------------------------------#

	# Inserts a copy of an item before each of several positions, all counted on the original list.
	#
	#   panPositions   the positions, in any order
	#   pItem          the item to insert
	#   returns        nothing; use InsertBeforePositionsQ to chain
	#   warning        the same R14 process kill if a position is two or more past the end
	#   see            InsertBeforePosition
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

	# Takes the item out of one position and puts it before the item that stood at another one.
	#
	#   _n1_       the position of the item to move
	#   _n2_       the position it should go before
	#   returns    nothing; use MoveItemQ to chain
	#   note       named places [ :From, 1 ] and [ :To, 3 ] are accepted
	#   warning    Moving an item towards the end lands it one place short of the target:
	#              MoveItem(1, 3) on a b c d gives b a c d and MoveItem(1, 2) or MoveItem(2, 3)
	#              changes nothing; moving towards the start is exact, MoveItem(3, 1) gives c a b d.
	#              A position out of range raises "Position out of range!"
	#   see        SwapItems
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

	# Exchanges the items at two positions.
	#
	#   _n1_       the position of the first item
	#   _n2_       the position of the second item
	#   returns    nothing; use SwapItemsQ to chain
	#   warning    a position past the end changes nothing and says nothing, and a position of 0 is
	#              read as 1: SwapItems(0, 2) on a b c d gives b a c d
	#   see        Swap, MoveItem
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
		if _pSwpList_ != ""
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

		# Exchanges the items at two positions, the same as SwapItems.
		#
		#   _n1_       the position of the first item
		#   _n2_       the position of the second item
		#   returns    nothing
		#   warning    an out-of-range position is ignored without a message, and 0 is read as 1
		#   see        SwapItems
		def Swap(_n1_, _n2_)
			This.SwapItems(_n1_, _n2_)
