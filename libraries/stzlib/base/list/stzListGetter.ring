#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTGETTER              #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List getter subclass -- content access,    #
#                  nth/first/last items, N-first/N-last.      #
#                  For aliases, use stzListGetterXT.            #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

# Reads items out of a list without changing it: by position, first or last, in sections, at random, by type, or in neighbouring runs.
#
# It is the reading helper of stzList, which builds one over itself for its UniqueItems,
# EveryNthItem, Head, Tail and ItemsBetween methods; build one with new stzListGetter when you only
# need to read. It works on its own copy, so a stzList passed in is never changed. Positions count
# from 1. NthItem, NFirstItems, NLastItems, Head, Tail and ItemsAtPositions raise error R2 when a
# position or a count goes past the list, while Section forgives it by clipping to the list and
# Range cuts a run that is too long. The Q forms (NFirstItemsQ, PairsQ, SlidingWindowQ ...) return
# the answer as a stzList to chain on. UniqueItemsCS takes the case flag (0 folds a and A).
# OnlyChars misses a single non-ASCII character today, and RandomItem and NRandomItems answer
# differently on every call.
#
#   receiver   o1 = new stzListGetter([ "a", "b", "c", "d", "e", "f", "g" ])
#   example    ? o1.NthItem(3)
#              #--> c
#              ? @@( o1.Section(2, 4) )
#              #--> [ "b", "c", "d" ]
#              ? @@( o1.EveryNthItem(3) )
#              #--> [ "c", "f" ]
#              ? @@( o1.NLastItems(2) )
#              #--> [ "f", "g" ]
#              o2 = new stzListGetter([ 1, 2, 3, 4 ])
#              ? @@( o2.SlidingWindow(2) )
#              #--> [ [ 1, 2 ], [ 2, 3 ], [ 3, 4 ] ]
#              o3 = new stzListGetter([ "שלום", "😀", "a", "שלום" ])
#              ? @@( o3.UniqueItems() )
#              #--> [ "שלום", "😀", "a" ]
#   see        stzList, stzListExtractor, stzListBounder
class stzListGetter from stzObject

	@oList

	  #===================#
	 #   INITIALIZATION  #
	#===================#

	# Builds a getter over a list, given as a list or as a stzList object.
	#
	#   pListOrObj   the list to read from, or a stzList whose content is copied, any other value
	#                raises an error
	#   returns      nothing; the object is built
	#   note         the getter works on its own copy and never changes the list or the stzList you
	#                passed in
	#   see          Content, NthItem
	def init(pListOrObj)
		if isList(pListOrObj)
			@oList = new stzList(pListOrObj)
		but isObject(pListOrObj)
			@oList = pListOrObj
		else
			StzRaise("Can't create stzListGetter! Parameter must be a list or stzList object.")
		ok

	  #===============================#
	 #     CONTENT ACCESS            #
	#===============================#

	# Returns the whole list the getter reads from.
	#
	#   returns    a list
	#   see        List, NumberOfItems
	def Content()
		return @oList.Content()

	# Returns the whole list the getter reads from.
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

	def ContentCS(pCaseSensitive)
		return This.List()

	# Returns the item at a position, counting from 1.
	#
	#   _n_        the position of the item, from 1
	#   returns    the item found
	#   note       the named form NthItem([ :At, 3 ]) is accepted
	#   warning    a position outside the list raises error R2 Array Access (Index out of range)
	#              instead of answering an empty value; 0 and a negative position raise it too
	#   see        FirstItem, LastItem, ItemsAtPositions
	def NthItem(_n_)
		if CheckingParams()
			if isList(_n_) and IsOneOfTheseNamedParamsList(_n_, [:At, :AtPosition, :ItemAt])
				_n_ = _n_[2]
			ok
		ok
		return This.List()[_n_]

	# Returns the first item of the list.
	#
	#   returns    the item found
	#   warning    on an empty list it raises error R2 Array Access (Index out of range)
	#   see        LastItem, NthItem, Head
	def FirstItem()
		return This.NthItem(1)

	# Returns the last item of the list.
	#
	#   returns    the item found
	#   warning    on an empty list it raises error R2 Array Access (Index out of range)
	#   see        FirstItem, NthItem, Tail
	def LastItem()
		return This.NthItem(This.NumberOfItems())

	# Returns the item in the middle of the list, the left one of the two middle items when the count is even.
	#
	#   returns    the item found
	#   note       the position is the count divided by 2, rounded up
	#   warning    on an empty list it raises error R2 Array Access (Index out of range)
	#   see        FirstItem, LastItem, NthItem
	def CentralItem()
		_nCiN_ = ceil(This.NumberOfItems() / 2)
		return This.NthItem(_nCiN_)

	# Returns the first n items, in their order.
	#
	#   _n_        how many items to take from the start
	#   returns    a list
	#   note       NFirstItemsQ returns the answer as a stzList, and Head is the same call
	#   warning    an n larger than the list raises error R2 Array Access (Index out of range)
	#              instead of answering the whole list; 0 gives [ ]
	#   see        NLastItems, Head, Section
	def NFirstItems(_n_)
		_aNfResult_ = []
		for _iNf_ = 1 to _n_
			_aNfResult_ + This.List()[_iNf_]
		next
		return _aNfResult_

		def NFirstItemsQ(_n_)
			return new stzList(This.NFirstItems(_n_))

	# Returns the last n items, in their order.
	#
	#   _n_        how many items to take from the end
	#   returns    a list
	#   note       NLastItemsQ returns the answer as a stzList, and Tail is the same call
	#   warning    an n larger than the list raises error R2 Array Access (Index out of range)
	#              instead of answering the whole list; 0 gives [ ]
	#   see        NFirstItems, Tail, Section
	def NLastItems(_n_)
		_nNlLen_ = This.NumberOfItems()
		_aNlResult_ = []
		for _iNl_ = _nNlLen_ - _n_ + 1 to _nNlLen_
			_aNlResult_ + This.List()[_iNl_]
		next
		return _aNlResult_

		def NLastItemsQ(_n_)
			return new stzList(This.NLastItems(_n_))

	  #======================================================#
	 #   ITEMS AT POSITIONS                                 #
	#======================================================#

	# Returns the items found at the given positions, in the order the positions are given.
	#
	#   panPositions   the positions to read, each from 1
	#   returns        a list
	#   note           ItemsAt is the same call, and a position may be repeated
	#   warning        a position outside the list raises error R2 Array Access (Index out of range)
	#   see            NthItem, Section
	def ItemsAtPositions(panPositions)
		_aIapResult_ = []
		_nIapLen_ = len(panPositions)
		for _iIap_ = 1 to _nIapLen_
			_aIapResult_ + This.List()[panPositions[_iIap_]]
		next
		return _aIapResult_

		def ItemsAt(panPositions)
			return This.ItemsAtPositions(panPositions)

	  #======================================================#
	 #   SECTION / RANGE                                    #
	#======================================================#

	# Returns the items from one position to another, both included.
	#
	#   _n1_       the first position
	#   _n2_       the last position
	#   returns    a list
	#   note       positions are forgiven: a start below 1 becomes 1, an end past the list becomes
	#              the last position, and a start larger than the end is swapped with it, so
	#              Section(4, 2) answers the same as Section(2, 4); ItemsBetween is the same call
	#   see        Range, NFirstItems
	def Section(_n1_, _n2_)
		_nScLen_ = This.NumberOfItems()
		if _n1_ < 1 _n1_ = 1 ok
		if _n2_ > _nScLen_ _n2_ = _nScLen_ ok
		if _n1_ > _n2_
			_nScTemp_ = _n1_
			_n1_ = _n2_
			_n2_ = _nScTemp_
		ok
		_pScList_ = @oList._EngineListFromContent()
		if _pScList_ != ""
			_pScResult_ = StzEngineListSection(_pScList_, _n1_, _n2_)
			if _pScResult_ != ""
				_aScResult_ = @oList._ContentFromEngineList(_pScResult_)
				StzEngineListFree(_pScResult_)
				StzEngineListFree(_pScList_)
				return _aScResult_
			ok
			StzEngineListFree(_pScList_)
		ok
		_aScFallback_ = []
		for _iSc_ = _n1_ to _n2_
			_aScFallback_ + This.List()[_iSc_]
		next
		return _aScFallback_

	# Returns a run of items given its first position and how many items it holds.
	#
	#   pnStart    the first position
	#   pnRange    how many items to take
	#   returns    a list
	#   note       a count that runs past the end is cut at the end of the list
	#   warning    a count of 0 does not give [ ]: Range(2, 0) on a b c answers a b, because the end
	#              position falls before the start and Section swaps them
	#   see        Section, NFirstItems
	def Range(pnStart, pnRange)
		return This.Section(pnStart, pnStart + pnRange - 1)

	  #======================================================#
	 #   UNIQUE ITEMS                                       #
	#======================================================#

	# The unique items of the list, in first-seen order.
	def UniqueItemsCS(pCaseSensitive)
		_pUiList_ = @oList._EngineListFromContent()
		_pUiResult_ = StzEngineListUniqueCS(_pUiList_, pCaseSensitive)
		_aUiResult_ = StzEngineListContentToRingList(_pUiResult_)
		StzEngineListFree(_pUiResult_)
		StzEngineListFree(_pUiList_)
		return _aUiResult_

	# Returns the items without repeats, each kept at its first position.
	#
	#   returns    a list
	#   note       UniqueItemsCS(0) also folds capital and small letters, so a and A count as one,
	#              while UniqueItems is case sensitive; the items stay in their first-seen order
	#   see        Content, EveryNthItem
	def UniqueItems()
		return This.UniqueItemsCS(1)

	  #======================================================#
	 #   RANDOM ITEM                                        #
	#======================================================#

	# Returns one item picked at random.
	#
	#   returns    the item picked
	#   note       the answer changes from call to call
	#   warning    on an empty list it raises error R2 Array Access (Index out of range)
	#   see        NRandomItems, NthItem
	#@ aka  One item picked at random.
	def RandomItem()
		_nRdN_ = StzEngineRandomInt(0, This.NumberOfItems() - 1) + 1
		return This.NthItem(_nRdN_)

	# Returns n different items picked at random, as a list.
	#
	#   _n_        how many items to pick
	#   returns    a list
	#   note       an n equal to or larger than the list answers every item, in a shuffled order; 0
	#              gives [ ]; the answer changes from call to call
	#   see        RandomItem, NFirstItems
	#@ aka  n items picked at random.
	def NRandomItems(_n_)
		_pNriList_ = @oList._EngineListFromContent()
		if _pNriList_ != ""
			_pNriResult_ = StzEngineListRandomItems(_pNriList_, _n_)
			if _pNriResult_ != ""
				_aNriResult_ = @oList._ContentFromEngineList(_pNriResult_)
				StzEngineListFree(_pNriResult_)
				StzEngineListFree(_pNriList_)
				return _aNriResult_
			ok
			StzEngineListFree(_pNriList_)
		ok
		_aNriContent_ = This.Content()
		_nNriLen_ = len(_aNriContent_)
		if _n_ >= _nNriLen_
			_aNriAll_ = []
			for _iNri_ = 1 to _nNriLen_
				_aNriAll_ + _aNriContent_[_iNri_]
			next
			return _aNriAll_
		ok
		_anNriIdx_ = 1 : _nNriLen_
		for _iNri2_ = _nNriLen_ to 2 step -1
			_jNri_ = StzEngineRandomInt(0, _iNri2_ - 1) + 1
			_nNriTmp_ = _anNriIdx_[_iNri2_]
			_anNriIdx_[_iNri2_] = _anNriIdx_[_jNri_]
			_anNriIdx_[_jNri_] = _nNriTmp_
		next
		_aNriPick_ = []
		for _kNri_ = 1 to _n_
			_aNriPick_ + _aNriContent_[_anNriIdx_[_kNri_]]
		next
		return _aNriPick_

	  #======================================================#
	 #   ITEMS BETWEEN TWO POSITIONS                        #
	#======================================================#

	def ItemsBetween(_n1_, _n2_)
		return This.Section(_n1_, _n2_)

		def ItemsBetweenQ(_n1_, _n2_)
			return new stzList(This.ItemsBetween(_n1_, _n2_))

	  #======================================================#
	 #   EVERY NTH ITEM                                     #
	#======================================================#

	# Returns the items at positions n, 2n, 3n and so on.
	#
	#   _n_        the step between two picked positions
	#   returns    a list
	#   note       the first item is not picked unless n is 1; an n of 0 or larger than the list
	#              gives [ ]; EveryNth is the same call and EveryNthItemQ returns a stzList
	#   see        Head, Tail, Section
	#@ aka  Every nth item of the list (n, 2n, 3n, ...).
	def EveryNthItem(_n_)
		_aEniContent_ = This.Content()
		_nEniLen_ = len(_aEniContent_)
		_aEniResult_ = []
		for _iEni_ = _n_ to _nEniLen_ step _n_
			_aEniResult_ + _aEniContent_[_iEni_]
		next
		return _aEniResult_

		def EveryNthItemQ(_n_)
			return new stzList(This.EveryNthItem(_n_))

		def EveryNth(_n_)
			return This.EveryNthItem(_n_)

	  #======================================================#
	 #   HEAD / TAIL                                        #
	#======================================================#

	# The first n items of the list.
	def Head(_n_)
		return This.NFirstItems(_n_)

		def HeadQ(_n_)
			return new stzList(This.Head(_n_))

	# The last n items of the list.
	def Tail(_n_)
		return This.NLastItems(_n_)

		def TailQ(_n_)
			return new stzList(This.Tail(_n_))

	  #======================================================#
	 #   ITEMS OF TYPE                                      #
	#======================================================#

	# Returns the items that are texts, in their order.
	#
	#   returns    a list
	#   note       a text of Hebrew, Arabic or an emoji is a string like any other
	#   see        OnlyNumbers, OnlyLists, OnlyChars
	#@ aka  Only the STRING items of the list.
	def OnlyStrings()
		_aOsContent_ = This.Content()
		_nOsLen_ = len(_aOsContent_)
		_aOsResult_ = []
		for _iOs_ = 1 to _nOsLen_
			if isString(_aOsContent_[_iOs_])
				_aOsResult_ + _aOsContent_[_iOs_]
			ok
		next
		return _aOsResult_

	# Returns the items that are numbers, in their order.
	#
	#   returns    a list
	#   see        OnlyStrings, OnlyLists
	#@ aka  Only the NUMBER items of the list.
	def OnlyNumbers()
		_aOnContent_ = This.Content()
		_nOnLen_ = len(_aOnContent_)
		_aOnResult_ = []
		for _iOn_ = 1 to _nOnLen_
			if isNumber(_aOnContent_[_iOn_])
				_aOnResult_ + _aOnContent_[_iOn_]
			ok
		next
		return _aOnResult_

	# Returns the items that are lists, in their order.
	#
	#   returns    a list
	#   see        OnlyStrings, OnlyNumbers
	#@ aka  Only the LIST items of the list.
	def OnlyLists()
		_aOlContent_ = This.Content()
		_nOlLen_ = len(_aOlContent_)
		_aOlResult_ = []
		for _iOl_ = 1 to _nOlLen_
			if isList(_aOlContent_[_iOl_])
				_aOlResult_ + _aOlContent_[_iOl_]
			ok
		next
		return _aOlResult_

	# Returns the texts that are made of a single character, in their order.
	#
	#   returns    a list
	#   note       read Hebrew, Arabic and accented single letters through OnlyStrings
	#   warning    a single character that is not plain ASCII is missed: "é", "ש", "ا" and an emoji
	#              are left out, because a character counts as one only when its text is one byte
	#              long (["é", "😀", "x", "ا", "xy"] answers just "x")
	#   see        OnlyStrings
	#@ aka  Only the CHAR items of the list.
	def OnlyChars()
		_aOcContent_ = This.Content()
		_nOcLen_ = len(_aOcContent_)
		_aOcResult_ = []
		for _iOc_ = 1 to _nOcLen_
			if isString(_aOcContent_[_iOc_]) and len(_aOcContent_[_iOc_]) = 1
				_aOcResult_ + _aOcContent_[_iOc_]
			ok
		next
		return _aOcResult_

	  #======================================================#
	 #   PAIRS / TRIPLETS / WINDOWS                         #
	#======================================================#

	# Returns each item together with the one after it, as two-item lists.
	#
	#   returns    a list of pairs
	#   note       a list of n items gives n minus 1 pairs, and fewer than 2 items give [ ]; PairsQ
	#              returns a stzList
	#   see        Triplets, SlidingWindow
	def Pairs()
		_aPrContent_ = This.Content()
		_nPrLen_ = len(_aPrContent_)
		_aPrResult_ = []
		for _iPr_ = 1 to _nPrLen_ - 1
			_aPrResult_ + [_aPrContent_[_iPr_], _aPrContent_[_iPr_ + 1]]
		next
		return _aPrResult_

		def PairsQ()
			return new stzList(This.Pairs())

	# Returns each run of three neighbouring items, as three-item lists.
	#
	#   returns    a list of triplets
	#   note       a list of n items gives n minus 2 triplets, and fewer than 3 items give [ ];
	#              TripletsQ returns a stzList
	#   see        Pairs, SlidingWindow
	def Triplets()
		_aTrContent_ = This.Content()
		_nTrLen_ = len(_aTrContent_)
		_aTrResult_ = []
		for _iTr_ = 1 to _nTrLen_ - 2
			_aTrResult_ + [_aTrContent_[_iTr_], _aTrContent_[_iTr_ + 1], _aTrContent_[_iTr_ + 2]]
		next
		return _aTrResult_

		def TripletsQ()
			return new stzList(This.Triplets())

	# Returns every run of n neighbouring items, moving one position at a time.
	#
	#   _n_        the size of each window
	#   returns    a list of lists
	#   note       an n larger than the list or 0 gives [ ]; SlidingWindowQ returns a stzList
	#   see        Pairs, Triplets
	def SlidingWindow(_n_)
		_pSwList_ = StzEngineMarshalList(@oList.Content())
		_pSwResult_ = StzEngineListSlidingWindow(_pSwList_, _n_)
		_aSwResult_ = StzEngineListContentToRingList(_pSwResult_)
		StzEngineListFree(_pSwResult_)
		StzEngineListFree(_pSwList_)
		return _aSwResult_

		def SlidingWindowQ(_n_)
			return new stzList(This.SlidingWindow(_n_))
