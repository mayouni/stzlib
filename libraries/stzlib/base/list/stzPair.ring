// General class for managing pairs of values

func StzPairQ(paList)
	return new stzPair(paList)

func IsPair(paList)
	if isList(paList) and len(paList) = 2
		return 1
	else
		return 0
	ok

	func @IsPair(paList)
		return IsPair(paList)

	func IsAPair(paList)
		return IsPair(paList)

	func @IsAPair(paList)
		return IsPair(paList)

# Holds two values side by side and tells whether both are numbers, texts, lists or objects.
#
# Build one with new stzPair([ a, b ]) or StzPairQ([ a, b ]); the global IsPair(aList) tells whether
# a plain list has exactly two items. Item1 and Item2 read the two sides, and it is a stzList, so
# every list method also works. The list given to init is not checked for holding two items. Update,
# UpdateWith, Swap and Swapped raise error R24 today, so a pair cannot be changed or swapped through
# them.
#
#   receiver   o1 = new stzPair([ "שלום", 7 ])
#   example    ? o1.Item1()
#              #--> שלום
#              ? o1.Item2()
#              #--> 7
#              ? o1.BothAreNumbers()
#              #--> 0
#              ? IsPair([ 1, 2 ])
#              #--> 1
#   see        stzList, stzPairOfLists, stzPairOfNumbers
class stzPair from stzList
	@aContent
	
	# Builds a pair from a list, keeping its items in order; the list is not checked for holding exactly two items.
	#
	#   paList     the list whose items become the pair, expected to hold two
	#   returns    nothing; the object is built
	#   warning    a list of three items is kept whole and a list of one item makes a pair whose
	#              Item2 raises R2; only the global IsPair(aList) tests for two
	#   see        Item1, Item2, IsPair
	def init(paList)
		// Control: paList must contain just 2 items
		@aContent = []
		_nList1Len_ = len(paList)
		for _iLoopList1_ = 1 to _nList1Len_
			_item_ = paList[_iLoopList1_]
			@aContent + _item_
		next

		if KeepingHistory() = 1
			This.AddHistoricValue(This.Content())
		ok

	# Returns the items of the pair as a list.
	#
	#   returns    a list, normally of two items
	#   see        Pair, Value
	def Content()
		return @aContent

		def Pair()
			return This.Content()

		# Returns the items of the pair, the same answer as Content.
		#
		#   returns    a list
		#   see        Content
		def Value()
			return Content()

	# Returns a new stzPair holding the same items.
	#
	#   returns    a new stzPair
	#   see        ToStzList
	def Copy()
		return new stzPair( This.Content() )

	# Replaces the items of the pair by those of another two-item list.
	#
	#   paPair     the list of two items that should replace the pair
	#   returns    nothing today: it raises error R24 and the pair keeps its items
	#   warning    Raises error R24 "Using uninitialized variable: panpair" today for every list,
	#              instead of replacing the items: the check reads panPair, a name that is not the
	#              parameter paPair
	#   see        UpdateWith, Swap
	def Update(paPair)
		if CheckingParams()
			if NOT ( isList(paPair) and len(panPair) = 2 )
				StzRaise("Incorrect param type! paPair must be a list of 2 items.")
			ok
		ok

		@aContent = paPair

		if KeepingHisto() = 1
			This.AddHistoricValue(This.Content())  # From the parent stzObject
		ok

		# Replaces the items of the pair by those of another two-item list, the same as Update.
		#
		#   paPair     the list of two items that should replace the pair
		#   returns    nothing today: it raises error R24
		#   warning    Raises error R24, as Update does, and leaves the pair unchanged
		#   see        Update
		def UpdateWith(paPair)
			This.Update(paPair)

	# Returns the items of the pair as a stzList, ready for the list methods.
	#
	#   returns    a stzList
	#   see        Content
	def ToStzList()
		return new stzList( This.Pair() )

	# Returns the first item of the pair.
	#
	#   returns    the first item
	#   note       FirstItem is the same method; an empty pair raises R2
	#   see        Item2
	def Item1()
		return This.Pair()[1]

		def FirstItem()
			return This.Item1()

	# Returns the second item of the pair.
	#
	#   returns    the second item
	#   note       SecondItem is the same method; a pair of one item raises R2
	#   see        Item1
	def Item2()
		return This.Pair()[2]

		def SecondItem()
			return This.Item2()

	# Exchanges the two items of the pair in place.
	#
	#   returns    nothing today: it raises error R24 and the pair is unchanged
	#   warning    Raises error R24 "Using uninitialized variable: panpair" today instead of
	#              swapping, because it ends by calling UpdateWith; SwapQ fails the same way
	#   see        Swapped, Update
	def Swap()
		_aContent_ = This.Content()

		_temp_ = _aContent_[1]
		_aContent_[1] = _aContent_[2]
		_aContent_[2] = _temp_

		This.UpdateWith(_aContent_)

		def SwapQ()
			This.Swap()
			return This

	# Returns a copy of the pair with its two items exchanged, leaving the pair unchanged.
	#
	#   returns    nothing today: it raises error R24
	#   warning    Raises error R24 today instead of the swapped items, because it swaps a copy
	#              through Swap; to swap by hand build a new stzPair from [ Item2(), Item1() ]
	#   see        Swap
	def Swapped()
		return This.Copy().SwapQ().Content()

	# TRUE if both items of the pair are numbers.
	#
	#   returns    TRUE or FALSE
	#   see        BothAreStrings, BothAreLists
	def BothAreNumbers()
		if isNumber(This.Item1()) and isNumber(This.Item2())
			return 1
		else
			return 0
		ok

	# TRUE if both items of the pair are texts.
	#
	#   returns    TRUE or FALSE
	#   see        BothAreNumbers
	def BothAreStrings()
		if isString(This.Item1()) and isString(This.Item2())
			return 1
		else
			return 0
		ok

	# TRUE if both items of the pair are lists.
	#
	#   returns    TRUE or FALSE
	#   see        BothAreNumbers
	def BothAreLists()
		if isList(This.Item1()) and isList(This.Item2())
			return 1
		else
			return 0
		ok

	# TRUE if both items of the pair are objects.
	#
	#   returns    TRUE or FALSE
	#   see        BothAreNumbers
	def BothAreObjects()
		if isObject(This.Item1()) and isObject(This.Item2())
			return 1
		else
			return 0
		ok

	# TRUE if the object is a pair object, which every pair is; it tells pairs from other kinds of object.
	#
	#   returns    TRUE
	#   note       the global IsPair(aList) tests a plain list for exactly two items
	#   see        IsPair
	def IsStzPair()
		return 1
