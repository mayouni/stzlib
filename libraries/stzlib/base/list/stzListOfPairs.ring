
#TODO
# Add CaseSensitivity

func StzListOfPairsQ(paLists)
	return new stzListOfPairs(paLists)

func RangeToSection(pnStart, pnRange)
	if NOT ( isNumber(pnStart) and isNumber(pnRange) )
		StzRaise("Incorrect param type! pnStart and pnRange must be noth numbers.")
	ok

	_aResult_ = [ pnStart, pnStart + pnRange - 1 ]
	return _aResult_


	func @RangeToSection(pnStart, pnRange)
		return RangeToSection(pnStart, pnRange)

func RangesToSections(panRanges)
	#TODO //
	# Replace for/in by for

	#UPDATE
	# Done!

	if CheckingParams()
		if not isList(panRanges)
			StzRaise("Incorrect param type! panRanges must be a list.")
		ok
	ok

	_nLen_ = len(panRanges)
	_anSections_ = []

	for i = 1 to _nLen_
		_anSections_ + @RangeToSection(panRanges[i][1], panRanges[i][2])
	next

	return _anSections_

func SectionToRange(n1, n2)
	if NOT (isNumber(n1) and isNumber(n2))
		StzRaise("Incorrect param types! n1 and n2 must be both numbers.")
	ok

	_anResult_ = [ n1, n2 - n1 + 1 ]
	return _anResult_

	func @SectionToRange(n1, n2)
		return SectionToRange(n1, n2)

func SectionsToRanges(paSections)
	#TODO //
	# Replace for/in by for

	#UPDATE
	# Done!

	if CheckingParams()
		if not isList(paSections)
			StzRaise("Incorrect param type! paSections must be a list.")
		ok
	ok

	_nLen_ = len(paSections)
	_anRanges_ = []
	
	for i = 1 to _nLen_
		_anRanges_ + @SectionToRange(paSections[i][1], paSections[i][2])
	next

	return _anRanges_

func ListThatHasMoreNumberOfItems(paList1, paList2)
	_oList1_ = new stzList(aList1)
	if _oList1_.HasMoreNumberOfItemsThen(paList2)
		return paList1
	else
		return paList2
	ok

func ListThatHasLessNumberOfItems(paList1, paList2)
	_oList1_ = new stzList(paList1)
	if _oList1_.HasLessNumberOfItems(:Then = paList2)
		return paList1
	else
		return paList2
	ok

func StzPairsQ(paList)
	return new stzPairs(paList)

# Is another name of stzListOfPairs: a list of pairs [ first, second ], with every method of it.
#
# The class adds nothing: it is built, ordered and queried exactly as a stzListOfPairs, and Copy
# answers a stzListOfPairs.
#
#   receiver   o1 = new stzPairs([ [ "a", 1 ], [ "b", 2 ] ])
#   example    ? o1.NumberOfPairs()
#              #--> 2
#   see        stzListOfPairs
class stzPairs from stzListOfPairs

# Holds a list whose every item is a pair [ first, second ], and answers questions about the first items, the second items and the order of the pairs.
#
# Reach for it when the data is naturally two-column: sections [ start, end ], key and value, name
# and score. It orders the pairs by the first or the second item (Sort, SortOn), exchanges the items
# of every pair (SwapItems), lists the first and the second items apart and checks their types. Most
# mutators change the object in place and return nothing; the Sorted, Swapped and Stringified forms
# return a copy. Some methods are broken today: the key-expression sorts (SortBy and its forms),
# ReplacePair, AreAnagrams, ExpandedIfPairsOfNumbers and ToStzSetOfSections; see their warnings. The
# Reverse and Inverse families exchange the two items of each pair, they do not reverse the order of
# the pairs.
#
#   receiver   o1 = new stzListOfPairs([ [ "b", 2 ], [ "a", 9 ], [ "c", 5 ] ])
#   example    ? @@( o1.FirstItems() )
#              #--> [ "b", "a", "c" ]
#              ? @@( o1.SortedOn(2) )
#              #--> [ [ "b", 2 ], [ "c", 5 ], [ "a", 9 ] ]
#   see        stzListOfLists, stzHashList, stzPairs
class stzListOfPairs from stzListOfLists
	@aContent = []

	# Builds the object from a list whose every item is a list of exactly two items; anything else raises an error.
	#
	#   paLists    the list of pairs, each [ first, second ]
	#   returns    nothing; the object is built
	#   note       an empty list is accepted; a list holding a non-pair, a list of one or three
	#              items, or a text, is refused
	#   see        Content, Copy
	def init(paLists)
		if CheckingParams()
			if NOT ( isList(paLists) and @IsListOfPairs(paLists) )
				StzRaise("Can't create the StzListOfPairs object! You must provide a list of pairs.")
			ok
		ok

		@aContent = paLists


	# Returns the pairs as a plain Ring list of two-item lists.
	#
	#   returns    a list of pairs
	#   note       the same list is shared, not copied
	#   see        Value, ToStzList
	def Content()
		return @aContent

		# Returns the pairs as a plain Ring list, the same answer as the content.
		#
		#   returns    a list of pairs
		#   see        Content
		def Value()
			return Content()

	# Returns a new stzListOfPairs holding the same pairs, so changing it leaves this list alone.
	#
	#   returns    a stzListOfPairs
	#   note       a copy of a stzPairs is a stzListOfPairs
	#   see        Content, ToStzList
	def Copy()
		return new stzListOfPairs( This.Content() )

	def ListOfPairs()
		return This.Content()

	# Replaces all the pairs by a new list of pairs, in place; raises an error when the argument is not a list of pairs.
	#
	#   paListOfPairs   the new list of pairs, each [ first, second ]
	#   returns         nothing; the content changes
	#   note            the old content is lost; the number of pairs may change
	#   see             Content, UpdatePairWith
	def UpdateWith(paListOfPairs)
		if isList(paListOfPairs) and @IsListOfPairs(paListOfPairs)
			@aContent = paListOfPairs

		else
			StzRaise("Can't update the stzListOfPairs object! The value you provided is not a list of pairs.")
		ok

	# Puts the new pair at position n, in place of the pair that was there.
	#
	#   n           the position of the pair to replace, from 1 to the number of pairs
	#   paNewPair   the new pair, as [ first, second ]
	#   returns     nothing; the content changes
	#   note        a position outside the list, or a new pair that does not hold two items, raises
	#               an error
	#   see         UpdateFirstPairWith, ReplacePair
	def UpdatePairWith(n, paNewPair)
		if CheckingParams()
			if NOT isNumber(n)
				StzRaise("Incorrect param type! n must be a number.")
			ok
		ok

		if NOT (isList(paNewPair) and ring_len(paNewPair) = 2)
			StzRaise("Incorrect param type! paNewPair must be a list of 2 items.")
		ok

		_aContent_ = This.Content()

		if NOT (isNumber(n) and n >= 1 and n <= ring_len(_aContent_))
			StzRaise("Out of range! n must be a position between 1 and the number of pairs.")
		ok

		_aContent_[n] = paNewPair
		This.UpdateWith(_aContent_)


		# Puts the new pair at position n, in place of the pair that was there.
		#
		#   n           the position of the pair to replace, from 1 to the number of pairs
		#   paNewPair   the new pair, as [ first, second ]
		#   returns     nothing; the content changes
		#   note        a position outside the list, or a new pair that does not hold two items, raises
		#               an error
		#   see         UpdatePairWith
		#< @FunctionAlternativeForms
		def UpdateNthPairWith(n, paNewPair)
			This.UpdatePairWith(n, paNewPair)

		# Puts the new pair at position n, in place of the pair that was there.
		#
		#   n           the position of the pair to replace, from 1 to the number of pairs
		#   paNewPair   the new pair, as [ first, second ]
		#   returns     nothing; the content changes
		#   note        a position outside the list, or a new pair that does not hold two items, raises
		#               an error
		#   see         UpdatePairWith
		def UpdatePairN(n, paNewPair)
			This.UpdatePairWith(n, paNewPair)

		# Puts the new pair at position n, in place of the pair that was there.
		#
		#   n           the position of the pair to replace, from 1 to the number of pairs
		#   paNewPair   the new pair, as [ first, second ]
		#   returns     nothing; the content changes
		#   note        a position outside the list, or a new pair that does not hold two items, raises
		#               an error
		#   see         UpdatePairWith
		def UpdatePair(n, paNewPair)
			This.UpdatePairWith(n, paNewPair)

		# Puts the new pair at position n, in place of the pair that was there.
		#
		#   n           the position of the pair to replace, from 1 to the number of pairs
		#   paNewPair   the new pair, as [ first, second ]
		#   returns     nothing; the content changes
		#   note        a position outside the list, or a new pair that does not hold two items, raises
		#               an error
		#   see         UpdatePairWith
		def UpdateNthPair(n, paNewPair)
			This.UpdatePairWith(n, paNewPair)

	# Replaces the first pair by the new pair, in place.
	#
	#   paNewPair   the new pair, as [ first, second ]
	#   returns     nothing; the content changes
	#   note        a new pair that does not hold exactly two items is refused
	#   see         UpdatePairWith, UpdateSecondPairWith
		#>
	def UpdateFirstPairWith(paNewPair)
		This.UpdatePairWith(1, paNewPair)

		# Replaces the first pair by the new pair, in place.
		#
		#   paNewPair   the new pair, as [ first, second ]
		#   returns     nothing; the content changes
		#   see         UpdateFirstPairWith
		def UpdatePair1With(paNewPair)
			This.UpdateFirstPairWith(paNewPair)

		# Replaces the first pair by the new pair, in place.
		#
		#   paNewPair   the new pair, as [ first, second ]
		#   returns     nothing; the content changes
		#   see         UpdateFirstPairWith
		def UpdateFirstPair(paNewPair)
			UpdateFirstPairWith(paNewPair)

		# Replaces the first pair by the new pair, in place.
		#
		#   paNewPair   the new pair, as [ first, second ]
		#   returns     nothing; the content changes
		#   see         UpdateFirstPairWith
		def UpdatePair1(paNewPair)
			This.UpdateFirstPairWith(paNewPair)

	# Replaces the second pair by the new pair, in place.
	#
	#   paNewPair   the new pair, as [ first, second ]
	#   returns     nothing; the content changes
	#   note        a list of one pair raises Ring's index-out-of-range error (R2), as there is no
	#               second pair
	#   see         UpdatePairWith, UpdateFirstPairWith
	def UpdateSecondPairWith(paNewPair)
		This.UpdatePairWith(2, paNewPair)

		# Replaces the second pair by the new pair, in place.
		#
		#   paNewPair   the new pair, as [ first, second ]
		#   returns     nothing; the content changes
		#   see         UpdateSecondPairWith
		def UpdatePair2With(paNewPair)
			This.UpdateSecondPairWith(paNewPair)

		# Replaces the second pair by the new pair, in place.
		#
		#   paNewPair   the new pair, as [ first, second ]
		#   returns     nothing; the content changes
		#   see         UpdateSecondPairWith
		def UpdateSecondPair(paNewPair)
			UpdateSecondPairWith(paNewPair)

		# Replaces the second pair by the new pair, in place.
		#
		#   paNewPair   the new pair, as [ first, second ]
		#   returns     nothing; the content changes
		#   see         UpdateSecondPairWith
		def UpdatePair2(paNewPair)
			This.UpdateSecondPairWith(paNewPair)

	# Returns the pairs wrapped in a stzList, to reach the list methods.
	#
	#   returns    a stzList
	#   see        Content, ToStzHashList
	def ToStzList()
		return new stzList( This.Content() )

	  #-------------------------------#
	 #  GETTING THE NUMBER OF PAIRS  #
	#-------------------------------#

	# Returns how many pairs the list holds.
	#
	#   returns    a number
	#   see        FirstItems
	def NumberOfPairs()
		_nResult_ = len(@aContent)
		return _nResult_

	  #------------------------#
	 #  GETTING THE NTH PAIR  #
	#------------------------#

	# Returns the pair at position n, as a list of two items.
	#
	#   n          the position of the pair, from 1
	#   returns    a list of two items
	#   note       a position outside the list raises Ring's index-out-of-range error (R2)
	#   see        FirstItems, SecondItems
	def PairAt(n)
		return Content()[n]

		def PairAtQ(n)
			return This.PairAtQRT(n, :stzList)

		def PairAtQRT(n, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.PairAt(n) )
			on :stzPair
				return new stzPair( This.PairAt(n) )
			other
				StzRaise("Unsupported return type!")
			off

		def Pair(n)
			return This.PairAt(n)

			def PairQ(n)
				return This.PairAtQ(n)

			def PairQRT(n, pcReturnType)
				return This.PairAtQRT(n, pcReturnType)

	  #-------------------------------------------------#
	 #  FINDING POSITIONS OF A GIVEN PAIR IN THE LIST  #
	#-------------------------------------------------#

	def FindPair(paPair)
		# Was `This.FindItem(paPair)` -- FindItem isn't defined on
		# this class, stzListOfLists, or stzList. The whole method
		# raised R14 on every call. Route to the inherited Find that
		# accepts any value (including a 2-elem list literal).
		return This.FindFirst(paPair)

	  #------------------------------------------------------------------#
	 #  FINDING POSITIONS OF A VALUE IN THE LIST OF FIRST/SECOND ITEMS  #
	#------------------------------------------------------------------#

	# Returns the positions of the pairs whose first item equals the value.
	#
	#   returns    a list of numbers; [ ] when no first item matches
	#   note       text is compared with case: "A" does not find "a"
	#   see        FindInSecondItems, FirstItems
	def FindInFirstItems(pValue)
		_anResult_ = This.FirstItemsQ().Find(pValue)
		return _anResult_

	# Returns the positions of the pairs whose second item equals the value.
	#
	#   returns    a list of numbers; [ ] when no second item matches
	#   see        FindInFirstItems, SecondItems
	def FindInSecondItems(pValue)
		_anResult_ = This.SecondItemsQ().Find(pValue)
		return _anResult_

	  #---------------------------------------------#
	 #  CHECKING IF PAIRS ARE MADE OF EQUAL ITEMS  #
	#---------------------------------------------#

	# TRUE if the two items of every pair are equal, as in [ 1, 1 ] and [ "x", "x" ].
	#
	#   returns    TRUE or FALSE
	#   see        FirstItems, SecondItems
	def PairsAreMadeOfEqualItems()
		# Inverted-logic bug: was setting bResult = 0 when items ARE
		# equal; should be when items are NOT equal. Returned the
		# wrong answer on every call (including the typical
		# "yes, all pairs are equal" case).
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		_bResult_ = 1

		for i = 1 to _nLen_
			if NOT Q(_aContent_[i][1]).IsEqualTo(_aContent_[i][2])
				_bResult_ = 0
			ok
		next
		return _bResult_

	  #----------------------------#
	 #  FIRST ITEMS OF EACH PAIR  #
	#============================#

	# Returns the first item of every pair, in order.
	#
	#   returns    a list of the first items
	#   note       FirstItemsU gives the same list without duplicates
	#   see        SecondItems, FindInFirstItems
	def FirstItems()
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		_aResult_ = []

		for i = 1 to _nLen_
			_aResult_ + _aContent_[i][1]
		next

		return _aResult_

		#< @FunctionFluentForm

		def FirstItemsQ()
			return This.FirstItemsQRT(:stzList)

		def FirstItemsQRT(pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.FirstItems() )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.FirstItems() )

			on :stzListOfStrings
				return new stzListOfStrings( This.FirstItems() )

			on :stzListOfLists
				return new stzListOfLists( This.FirstItems() )

			on :stzListOfPairs
				return new stzListOfNumbers( This.FirstItems() )

			other
				StzRaise("Unsupported return type!")
			off

		#>

		#< @FunctionAlternativeForms

		def FirstItemsOfEachPair()
			return This.FirstItems()

		def FirstItemsInEachPair()
			return This.FirstItems()

		def FirstValues()
			return This.FirstItems()

		def FirstValuesOfEachPair()
			return This.FirstItems()

		def FirstValuesInEachPair()
			return This.FirstItems()

		#>

	  #----------------------------------------------------#
	 #  FIRST ITEMS OF EACH PAIR -- WITHOUT DUPPLICATION  #
	#----------------------------------------------------#

	def FirstItemsU()
		_aResult_ = This.FirstItemsQ().WithoutDuplication()
		return _aResult_

		#< @FunctionFluentForm

		def FirstItemsUQ()
			return This.FirstItemsUQRT(:stzList)

		def FirstItemsUQRT(pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.FirstItemsU() )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.FirstItemsU() )

			on :stzListOfStrings
				return new stzListOfStrings( This.FirstItemsU() )

			on :stzListOfLists
				return new stzListOfLists( This.FirstItemsU() )

			on :stzListOfPairs
				return new stzListOfNumbers( This.FirstItemsU() )

			other
				StzRaise("Unsupported return type!")
			off

		#>

		#< @FunctionAlternativeForms

		def FirstItemsOfEachPairU()
			return This.FirstItemsU()

		def FirstItemsInEachPairU()
			return This.FirstItemsU()

		def FirstValuesU()
			return This.FirstItemsU()

		def FirstValuesOfEachPairU()
			return This.FirstItemsU()

		def FirstValuesInEachPairU()
			return This.FirstItemsU()

		#TODO
		# add ...WithoutDupplication() and Unique... alternatives

		#>

	  #-----------------------------#
	 #  SECOND ITEMS OF EACH PAIR  #
	#=============================#

	# Returns the second item of every pair, in order.
	#
	#   returns    a list of the second items
	#   note       LastItems gives the same answer; SecondItemsU removes the duplicates
	#   see        FirstItems, FindInSecondItems
	def SecondItems()
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		_aResult_ = []

		for i = 1 to _nLen_
			_aResult_ + _aContent_[i][2]
		next

		return _aResult_

		#< @FunctionFluentForm

		def SecondItemsQ()
			return This.SecondItemsQRT(:stzList)

		def SecondItemsQRT(pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.SecondItems() )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.SecondItems() )

			on :stzListOfStrings
				return new stzListOfStrings( This.SecondItems() )

			on :stzListOfLists
				return new stzListOfLists( This.SecondItems() )

			on :stzListOfPairs
				return new stzListOfNumbers( This.SecondItems() )

			other
				StzRaise("Unsupported return type!")
			off

		#>

		#< @FunctionAlternativeForms

		def SecondItemsOfEachPair()
			return This.SecondItems()

		def SecondItemsInEachPair()
			return This.SecondItems()

		def SecondValues()
			return This.SecondItems()

		def SecondValuesOfEachPair()
			return This.SecondItems()

		def SecondValuesInEachPair()
			return This.SecondItems()

		#--

		def LastItems()
			return This.SecondItems()

		def LastItemsOfEachPair()
			return This.SecondItems()

		def LastItemsInEachPair()
			return This.SecondItems()

		def LastValues()
			return This.SecondItems()

		def LastValuesOfEachPair()
			return This.SecondItems()

		def LastValuesInEachPair()
			return This.SecondItems()

		#>

	  #-----------------------------------------------------#
	 #  SECOND ITEMS OF EACH PAIR -- WITHOUT DUPPLICATION  #
	#-----------------------------------------------------#

	def SecondItemsU()
		_aResult_ = This.SecondItemsQ().WithoutDuplication()
		return _aResult_

		#< @FunctionFluentForm

		def SecondItemsUQ()
			return This.SecondItemsUQRT(:stzList)

		def SecondItemsUQRT(pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.SecondItemsU() )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.SecondItemsU() )

			on :stzListOfStrings
				return new stzListOfStrings( This.SecondItemsU() )

			on :stzListOfLists
				return new stzListOfLists( This.SecondItemsU() )

			on :stzListOfPairs
				return new stzListOfNumbers( This.SecondItemsU() )

			other
				StzRaise("Unsupported return type!")
			off

		#>

		#< @FunctionAlternativeForms

		def SecondItemsOfEachPairU()
			return This.SecondItemsU()

		def SecondItemsInEachPairU()
			return This.SecondItemsU()

		def SecondValuesU()
			return This.SecondItemsU()

		def SecondValuesOfEachPairU()
			return This.SecondItemsU()

		def SecondValuesInEachPairU()
			return This.SecondItemsU()

		#TODO
		# add ...WithoutDupplication() and Unique... alternatives

		#>
	  #--------------------#
	 #  REPLACING A PAIR  #
	#====================#

	# Puts the new pair at position n, in place of the pair that was there.
	#
	#   n           the position of the pair to replace, from 1 to the number of pairs
	#   paNewPair   the new pair, as [ first, second ]
	#   returns     nothing; the content changes
	#   note        a position outside the list, or a new pair that does not hold two items, raises
	#               an error
	#   see         UpdatePairWith, PairReplaced
	def ReplacePair(n, paNewPair)
		# IsPair() here would reach the inherited stzList.IsPair method
		# (no argument), so the shape is checked directly
		This.UpdatePairWith(n, paNewPair)

		def ReplacePairQ(n, paNewPair)
			This.ReplacePair(n, paNewPair)
			return This

	# Returns a copy of the pairs with the pair at position n swapped for a new one.
	#
	#   n           the position of the pair to replace, from 1 to the number of pairs
	#   paNewPair   the new pair, as [ first, second ]
	#   returns     a list of pairs; the list itself is unchanged
	#   see         ReplacePair, UpdatePairWith
	def PairReplaced(n, paNewPair)
		_aResult_ = This.Copy().ReplacePairQ(n, paNewPair).Content()
		return _aResult_

	  #==============================#
	 #  SORTING PAIRS IN ASCENDING  #
	#==============================#

	# Turns both items of every pair into text, in place: [ "b", 2 ] becomes [ "b", "2" ].
	#
	#   returns    nothing; the content changes
	#   see        ItemsStringified, FirstItems
	def StringifyItems()
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		_aResult_ = []

		for i = 1 to _nLen_
			_aResult_ + [ Q(_aContent_[i][1]).Stringified(), Q(_aContent_[i][2]).Stringified() ]
		next

		This.Update(_aResult_)

		def StringifyItemsQ()
			This.StringifyItems()
			return This

	# Returns a copy of the pairs with both items turned into text; the list is unchanged.
	#
	#   returns    a list of pairs
	#   see        StringifyItems
	def ItemsStringified()
		_aResult_ = This.Copy().StringifyItemsQ().Content()
		return _aResult_

	  #=========================================#
	 #  SORTING THE LIST OF PAIRS IN ASCENDING  #
	#==========================================#


	# Orders the pairs by their first item, ascending, in place.
	#
	#   returns    nothing; the content changes
	#   note       numbers are ordered by value, so 9 comes before 10
	#   see        Sorted, SortOn, SortDown
	def Sort()
		This.SortOn(1)

		def SortQ()
			This.Sort()
			return This

		# Orders the pairs by their first item, ascending, in place.
		#
		#   returns    nothing; the content changes
		#   see        Sort, SortDown
		def SortUp()
			This.Sort()

			def SortUpQ()
				return This.SortQ()

		# Orders the pairs by their first item, ascending, in place.
		#
		#   returns    nothing; the content changes
		#   see        Sort, SortDown
		def SortInAscending()
			This.Sort()

			def SortInAscendingQ()
				return This.SortQ()

	# Returns a copy of the pairs ordered by their first item, ascending; the list is unchanged.
	#
	#   returns    a list of pairs
	#   see        Sort, SortedDown, SortedOn
	def Sorted()
		_aResult_ = This.Copy().SortQ().Content()
		return _aResult_

		def SortedInAscending()
			return This.Sorted()

		def SortedUp()
			return This.Sorted()

	  #-------------------------------------------#
	 #  SORTING THE LIST OF PAIRS IN DESCENDING  #
	#-------------------------------------------#

	# Orders the pairs by their first item, descending, in place.
	#
	#   returns    nothing; the content changes
	#   see        SortedDown, Sort, SortOnDown
	def SortDown()
		This.SortOnDown(1)

		def SortDownQ()
			This.SortDown()
			return This

		# Orders the pairs by their first item, descending, in place.
		#
		#   returns    nothing; the content changes
		#   see        SortDown, Sort
		def SortInDescending()
			This.SortDown()

			def SortInDescendingQ()
				return This.SortDownQ()

	# Returns a copy of the pairs ordered by their first item, descending; the list is unchanged.
	#
	#   returns    a list of pairs
	#   see        SortDown, Sorted
	def SortedDown()
		_aResult_ = This.Copy().SortDownQ().Content()
		return _aResult_

		def SortedInDescending()
			return This.SortedDown()

	  #------------------------------------------------------------------#
	 #  SORTING THE PAIRS ON NTH (FIRST OR SECOND) COLUMN IN ASCENDING  #
	#==================================================================#

	# Orders the pairs by item n of each pair, ascending, in place.
	#
	#   n          which item to order by: 1 for the first item, 2 for the second
	#   returns    nothing; the content changes
	#   note       SortOnQ chains
	#   see        SortedOn, Sort, SortOnInDescending
	def SortOn(n)
		_aResult_ = @SortOn(This.Content(), n)
		This.UpdateWith(_aResult_)

		#< @FunctionFluentForm

		def SortOnQ(n)
			This.SortOn(n)
			return This

		# Orders the pairs by item n of each pair, ascending, in place.
		#
		#   n          which item to order by: 1 for the first item, 2 for the second
		#   returns    nothing; the content changes
		#   see        SortOn
		#>
		#< @FunctionAlternativeForms
		def SortOnInAscending(n)
			This.SortOn(n)

			def SortOnInAscendingQ(n)
				return This.SortOnQ(n)

		# Orders the pairs by item n of each pair, ascending, in place.
		#
		#   n          which item to order by: 1 for the first item, 2 for the second
		#   returns    nothing; the content changes
		#   see        SortOn
		def SortOnUp(n)
			This.SortOn(n)

			def SortOnUpQ(n)
				return This.SortOnQ(n)

		# Orders the pairs by item n of each pair, ascending, in place.
		#
		#   n          which item to order by: 1 for the first item, 2 for the second
		#   returns    nothing; the content changes
		#   see        SortOn
		#@ aka  --
		def SortInAscendingOn(n)
			This.SortOn(n)

			def SortInAscendingOnQ(n)
				return This.SortOnQ(n)

		# Orders the pairs by item n of each pair, ascending, in place.
		#
		#   n          which item to order by: 1 for the first item, 2 for the second
		#   returns    nothing; the content changes
		#   see        SortOn
		def SortUpOn(n)
			This.SortOn(n)

			def SortUpOnQ(n)
				return This.SortOnQ(n)

	# Returns a copy of the pairs ordered by item n of each pair, ascending; the list is unchanged.
	#
	#   n          which item to order by: 1 for the first item, 2 for the second
	#   returns    a list of pairs
	#   see        SortOn, Sorted, SortedOnInDescending
		#>
	def SortedOn(n)
		_aResult_ = This.Copy().SortOnQ(n).Content()
		return _aResult_

		#< @FunctionAlternativeForms

		def SortedOnInAscending(n)
			return This.SortedOn(n)

		def SortedOnUp(n)
			return This.SortedOn(n)

		#--

		def SortedInAscendingOn(n)
			return This.SortedOn(n)

		def SortedUpOn(n)
			return This.SortedOn(n)

		#>

	  #---------------------------------------------------------#
	 #  SORTING THE PAIRS DOWN ON NTH (FIRST OR SECOND) ITEMS  #
	#=========================================================#

	# Orders the pairs by item n of each pair, descending, in place.
	#
	#   n          which item to order by: 1 for the first item, 2 for the second
	#   returns    nothing; the content changes
	#   see        SortOn, SortedOnInDescending
	def SortOnInDescending(n)
		# Split the chain -- Ring's parser raises R13 on
		# `new stzList(...).Reversed()` (method-call directly off a
		# `new` expression). Same pattern fixed in
		# stzListOfNumbers.SortInDescending earlier this session.
		_aSoidAsc_ = This.SortedOnInAscending(n)
		_oSoidTmp_ = new stzList(_aSoidAsc_)
		_aSoidResult_ = _oSoidTmp_.Reversed()
		This.UpdateWith(_aSoidResult_)

		#< @FunctionFluentForm

		def SortOnInDescendingQ(n)
			This.SortOnInDescending(n)
			return This

		# Orders the pairs by item n of each pair, descending, in place.
		#
		#   n          which item to order by: 1 for the first item, 2 for the second
		#   returns    nothing; the content changes
		#   see        SortOnInDescending
		#>
		#< @FunctionAlternativeForms
		def SortInDescendingOn(n)
			This.SortOnInDescending(n)

			def SortInDescendingOnQ(n)
				return This.SortOnInDescendingQ(n)

		# Orders the pairs by item n of each pair, descending, in place.
		#
		#   n          which item to order by: 1 for the first item, 2 for the second
		#   returns    nothing; the content changes
		#   see        SortOnInDescending
		def SortOnDown(n)
			This.SortOnInDescending(n)

			def SortOnDownQ(n)
				return This.SortOnInDescendingQ(n)

		# Orders the pairs by item n of each pair, descending, in place.
		#
		#   n          which item to order by: 1 for the first item, 2 for the second
		#   returns    nothing; the content changes
		#   see        SortOnInDescending
		def SortDownOn(n)
			This.SortOnInDescending(n)

			def SortDownOnQ(n)
				return This.SortOnInDescendingQ(n)

	# Returns a copy of the pairs ordered by item n of each pair, descending; the list is unchanged.
	#
	#   n          which item to order by: 1 for the first item, 2 for the second
	#   returns    a list of pairs
	#   see        SortOnInDescending, SortedOn
		#>
	def SortedOnInDescending(n)
		_aResult_ = This.Copy().SortOnInDescendingQ(n).Content()
		return _aResult_

		#< @FunctionAlternativeForms

		def SortedInDescendingOn(n)
			return This.SortedOnInDescending(n)

		def SortedOnDown(n)
			return This.SortedOnInDescending(n)

		def SortedDownOn(n)
			return This.SortedOnInDescending(n)

		#>

	  #---------------------------------------------------------------#
	 #  SORTING THE PAIRS BY AN EVALUATED EXPRESSION - IN ASCENDING  #
	#===============================================================#
 
	# Orders the pairs by the value of a key expression on each, ascending, in place.
	#
	#   pcExpr     the key expression, as text holding @pair, such as len(@pair[1])
	#   returns    nothing; the content changes
	#   note       pairs with equal keys keep their order; an expression without @pair, or keys
	#              mixing numbers and texts, raises an error
	#   see        SortOn, SortedBy, SortByInDescending
	def SortBy(pcExpr)

		This.UpdateWith( This._SortedByExpr(pcExpr, 0) )

		#< @FunctionFluentForm

		def SortByQ(pcExpr)
			This.SortBy(pcExpr)
			return This

		# Orders the pairs by the value of a key expression on each, ascending, in place.
		#
		#   pcExpr     the key expression, as text holding @pair, such as len(@pair[1])
		#   returns    nothing; the content changes
		#   note       pairs with equal keys keep their order; an expression without @pair, or keys
		#              mixing numbers and texts, raises an error
		#   see        SortBy, SortOnInAscending
		#>
		#< @FunctionAlternativeForms
		def SortByInAscending(pcExpr)
			This.SortBy(pcExpr)

			def SortByInAscendingQ(pcExpr)
				return This.SortByQ(pcExpr)

		# Orders the pairs by the value of a key expression on each, ascending, in place.
		#
		#   pcExpr     the key expression, as text holding @pair, such as len(@pair[1])
		#   returns    nothing; the content changes
		#   note       pairs with equal keys keep their order; an expression without @pair, or keys
		#              mixing numbers and texts, raises an error
		#   see        SortBy, SortOnUp
		def SortByUp(pcExpr)
			This.SortBy(pcExpr)

			def SortByUpQ(pcExpr)
				return This.SortByQ(pcExpr)

	# Returns a copy of the pairs ordered by the value of a key expression on each, ascending.
	#
	#   pcExpr     the key expression, as text holding @pair, such as @pair[2]
	#   returns    a list of pairs; the list itself is unchanged
	#   note       pairs with equal keys keep their order
	#   see        SortBy, SortedOn
		#>
	def SortedBy(pcExpr)
		_aResult_ = This.Copy().SortByQ(pcExpr).Content()
		return _aResult_

		def SortedByInAscending(pcExpr)
			return This.SortedBy(pcExpr)

		def SortedByUp(pcExpr)
			return This.SortedBy(pcExpr)

	  #------------------------------------------------------#
	 #  SORTING THE PAIRS BY AN EXPRESSION - IN DESCENDING  #
	#------------------------------------------------------#
 
	# Orders the pairs by the value of a key expression on each, descending, in place.
	#
	#   pcExpr     the key expression, as text holding @pair, such as @pair[2]
	#   returns    nothing; the content changes
	#   note       pairs with equal keys keep their order; the items inside each pair stay where
	#              they are
	#   see        SortBy, SortOnInDescending
	def SortByInDescending(pcExpr)
		# Reverse() of this class swaps the items INSIDE each pair,
		# so the descending order is built directly
		This.UpdateWith( This._SortedByExpr(pcExpr, 1) )

		def SortByInDescendingQ(pcExpr)
			This.SortByInDescending(pcExpr)
			return This

		# Orders the pairs by the value of a key expression on each, descending, in place.
		#
		#   pcExpr     the key expression, as text holding @pair, such as @pair[2]
		#   returns    nothing; the content changes
		#   note       pairs with equal keys keep their order; the items inside each pair stay where
		#              they are
		#   see        SortByInDescending, SortOnDown
		def SortByDown(pcExpr)
			This.SortByInDescending(pcExpr)

			def SortByDownQ(pcExpr)
				return This.SortByInDescendingQ(pcExpr)

	# Returns a copy of the pairs ordered by the value of a key expression on each, descending.
	#
	#   pcExpr     the key expression, as text holding @pair, such as @pair[2]
	#   returns    a list of pairs; the list itself is unchanged
	#   note       pairs with equal keys keep their order
	#   see        SortByInDescending, SortedOnInDescending
	def SortedByInDescending(pcExpr)
		_aResult_ = This.Copy().SortByInDescendingQ(pcExpr).Content()
		return _aResult_

		def SortedByDown(pcExpr)
			return This.SortedByInDescending(pcExpr)

	# Returns the pairs ordered by the value of a key expression on each, keeping the order of equal keys.
	#
	#   pcExpr        the key expression, as text holding @pair
	#   bDescending   1 for the largest key first, 0 for the smallest first
	#   returns       a list of pairs; the content is unchanged
	#   note          the keys must be all numbers or all texts, otherwise an error is raised
	#   see           SortBy, SortByInDescending
	def _SortedByExpr(pcExpr, bDescending)

		if NOT ( isString(pcExpr) and ring_len(StzFindCS("@pair", pcExpr, 0)) > 0 )
			StzRaise("Incorrect param! pcExpr must be a string containing @pair keyword.")
		ok

		_aContent_ = This.Content()
		_nLen_ = ring_len(_aContent_)
		_cCode_ = "_xKey_ = " + pcExpr
		_aKeyed_ = []
		_nNumbers_ = 0

		for _iSb_ = 1 to _nLen_
			@pair = _aContent_[_iSb_]
			_xKey_ = ""
			eval(_cCode_)
			if isNumber(_xKey_)
				_nNumbers_++
			but NOT isString(_xKey_)
				StzRaise("Can't sort! The expression must give a number or a text for every pair.")
			ok
			_aKeyed_ + [ _xKey_, _iSb_ ]
		next

		if _nNumbers_ > 0 and _nNumbers_ < _nLen_
			StzRaise("Can't sort! The expression gives numbers for some pairs and texts for others.")
		ok

		_aKeyed_ = ring_sort2(_aKeyed_, 1)

		# Groups of equal keys, each kept in its original order (sort() is not stable)
		_aGroups_ = []
		_iSb_ = 1
		while _iSb_ <= _nLen_
			_aIdx_ = [ _aKeyed_[_iSb_][2] ]
			_jSb_ = _iSb_ + 1
			while _jSb_ <= _nLen_ and _aKeyed_[_jSb_][1] = _aKeyed_[_iSb_][1]
				_aIdx_ + _aKeyed_[_jSb_][2]
				_jSb_++
			end
			_aGroups_ + ring_sort(_aIdx_)
			_iSb_ = _jSb_
		end

		_aResult_ = []
		_nGroups_ = ring_len(_aGroups_)
		for _iSb_ = 1 to _nGroups_
			if bDescending = 1
				_aIdx_ = _aGroups_[_nGroups_ - _iSb_ + 1]
			else
				_aIdx_ = _aGroups_[_iSb_]
			ok
			_nIdx_ = ring_len(_aIdx_)
			for _jSb_ = 1 to _nIdx_
				_aResult_ + _aContent_[_aIdx_[_jSb_]]
			next
		next

		return _aResult_

	  #==================================================================#
	 #  RETURNING AN EXPANDED LIST OF NUMBERS OUT OF THE LIST OF PAIRS  #
	#==================================================================#

	# Raises error R14 today instead of returning the number lists that the pairs of numbers expand to.
	#
	#   returns    nothing today; the call raises
	#   warning    Raises R14 today on every call: it calls ExpandedIfPairOfNumbers, a method that
	#              exists nowhere in the loaded library
	#   see        ToStzListOfSections, IsListOfSections
	def ExpandedIfPairsOfNumbers()
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		_aResult_ = []

		for i = 1 to _nLen_
			if isNumber(_aContent_[i][1]) and isNumber(_aContent_[i][2])
				_aResult_ + StzListQ(_aContent_[i]).ExpandedIfPairOfNumbers()
			ok
		next

		return _aResult_

		#< @FunctionFluentForm

		def ExpandedIfPairsOfNumbersQ()
			return This.ExpandedIfPairsOfNumbersQRT(:stzList)

		def ExpandedIfPairsOfNumbersQRT(pcReturnType)
			if isList(pcReturnType) and IsOneOfTheseNamedParamsList(pcReturnType, [ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.ExpandedIfPairsOfNumbers() )

			on :stzListOfLists
				return new stzListOfLists( This.ExpandedIfPairsOfNumbers() )

			other
				StzRaise("Unsupported type!")
			off
				
		#>

	  #-------------------------------------------------#
	 #   SWAPPING THE ITEMS IN THE PAIRS OF THE LIST   #
	#-------------------------------------------------#

	# Exchanges the two items of every pair, in place: [ "a", 1 ] becomes [ 1, "a" ].
	#
	#   returns    nothing; the content changes
	#   note       the order of the pairs is kept; SwapItemsQ chains
	#   see        ItemsSwapped, SortOn
	def SwapItems()
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)
		_aResult_ = []

		for i = 1 to _nLen_
			_aResult_ + [ _aContent_[i][2], _aContent_[i][1] ]
		next

		This.UpdateWith(_aResult_)

		#< @FunctionFluentForm
			
		def SwapItemsQ()
			This.SwapItems()
			return This

		# Exchanges the two items of every pair, in place: [ "a", 1 ] becomes [ 1, "a" ].
		#
		#   returns    nothing; the content changes
		#   see        SwapItems
		#>
		#< @FunctionAlternativeForms
		def ReverseItems()
			This.SwapItems()

			def ReverseItemsQ()
				return This.SwapItemsQ()

		# Exchanges the two items of every pair, in place: [ "a", 1 ] becomes [ 1, "a" ].
		#
		#   returns    nothing; the content changes
		#   see        SwapItems
		def InverseItems()
			This.SwapItems()

			def InverseItemsQ()
				return This.SwapItemsQ()

		# Exchanges the two items of every pair, in place: [ "a", 1 ] becomes [ 1, "a" ].
		#
		#   returns    nothing; the content changes
		#   note       it does not swap the pairs with one another
		#   see        SwapItems
		#@ aka  --
		def SwapPairs()
			This.SwapItems()

			def SwapPairsQ()
				return This.SwapItemsQ()

		# Exchanges the two items of every pair, in place: [ "a", 1 ] becomes [ 1, "a" ].
		#
		#   returns    nothing; the content changes
		#   note       it does not reverse the order of the pairs
		#   see        SwapItems
		def ReversePairs()
			This.SwapItems()

			def ReversePairsQ()
				return This.SwapItemsQ()

		# Exchanges the two items of every pair, in place: [ "a", 1 ] becomes [ 1, "a" ].
		#
		#   returns    nothing; the content changes
		#   note       it does not reverse the order of the pairs
		#   see        SwapItems
		def InversePairs()
			This.SwapItems()

			def InversePairsQ()
				return This.SwapItemsQ()

		# Exchanges the two items of every pair, in place: [ "a", 1 ] becomes [ 1, "a" ].
		#
		#   returns    nothing; the content changes
		#   note       unlike stzList.Reverse it does not reverse the order of the pairs
		#   see        SwapItems
		#@ aka  --
		def Reverse()
			This.SwapItems()

			def ReverseQ()
				return This.SwapItemsQ()

		# Exchanges the two items of every pair, in place: [ "a", 1 ] becomes [ 1, "a" ].
		#
		#   returns    nothing; the content changes
		#   see        SwapItems
		def Inverse()
			This.SwapItems()

			def InverseQ()
				return This.SwapItemsQ()

		# Exchanges the two items of every pair, in place: [ "a", 1 ] becomes [ 1, "a" ].
		#
		#   returns    nothing; the content changes
		#   see        SwapItems
		def Swap()
			This.SwapItems()

			def SwapQ()
				return This.SwapItemsQ()

	# Returns a copy of the pairs with the two items of every pair exchanged; the list is unchanged.
	#
	#   returns    a list of pairs
	#   note       Swapped, Reversed, Inversed, PairsSwapped give the same answer
	#   see        SwapItems
		#>
	def ItemsSwapped()
		_aResult_ = This.Copy().SwapItemsQ().Content()
		return _aResult_

		#< @FunctionAlternativeForms

		def ItemsReversed()
			return This.ItemsSwapped()

		def ItemsInversed()
			return This.ItemsSwapped()

		#--

		def PairsSwapped()
			return This.ItemsSwapped()

		def PairsReversed()
			return This.ItemsSwapped()

		def PairsInversed()
			return This.ItemsSwapped()

		#--

		def Reversed()
			return This.ItemsSwapped()

		def Inversed()
			return This.ItemsSwapped()

		def Swapped()
			return This.ItemsSwapped()

		#>

	  #---------------------------------------------------------------#
	 #   CHECKING IF THE PAIRS ARE SECTIONS AND IF THEY ARE SORTED   #
	#---------------------------------------------------------------#
	# Answers TRUE for any list of pairs today, instead of TRUE only when every pair is made of two numbers.
	#
	#   returns    TRUE or FALSE
	#   note       a list of pairs of text, [ [ "a", "b" ] ], passes
	#   warning    Answers TRUE whatever the pairs hold, text included: the loop records a failing
	#              pair in a variable that is never read, so the result stays at its start value
	#   see        IsSortedListOfSections, ToStzListOfSections
	#@ aka  --> Each pair is made of numbers
	def IsListOfSections()

		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)	

		_bResult_ = 1

		for i = 1 to _nLen_
			if NOT @IsListOfNumbers(_aContent_[i])
				_bIsMadeOfNumbers_ = 0
				exit
			ok
		next

		return _bResult_

	# TRUE if the pairs, read as sections, are sorted in ascending order or in descending order.
	#
	#   returns    TRUE or FALSE
	#   note       it is only as exact as IsListOfSections, which accepts any pairs
	#   see        IsListOfSectionsSortedInAscending, IsListOfSectionsSortedInDescending
	def IsSortedListOfSections()

		if This.IsListOfSectionsSortedInAscending() or
		   This.IsListOfSectionsSortedInDescending()

			return 1

		else
			return 0
		ok

	# TRUE if the numbers of all the pairs, read in order, are in ascending order, as in [ 1, 3 ], [ 5, 8 ].
	#
	#   returns    TRUE or FALSE
	#   note       [ [ 5, 8 ], [ 1, 3 ] ] and overlapping sections such as [ [ 1, 5 ], [ 3, 4 ] ]
	#              give FALSE; text pairs may pass because IsListOfSections accepts them
	#   see        IsListOfSectionsSortedInDescending, IsSortedListOfSections
	def IsListOfSectionsSortedInAscending()

		_bResult_ = 0

		If This.IsListOfSections() and
		   This.ToStzList().MergeQ().IsSortedInAscending()

				_bResult_ = 1

		ok

		return _bResult_

	# TRUE if the pairs, with their two items swapped, run in descending order, as in [ 9, 12 ], [ 4, 7 ], [ 1, 3 ].
	#
	#   returns    TRUE or FALSE
	#   note       [ [ 5, 8 ], [ 1, 3 ] ] gives TRUE
	#   see        IsListOfSectionsSortedInAscending, IsSortedListOfSections
	def IsListOfSectionsSortedInDescending()

		_bResult_ = 0
		_aSwapped_ = This.Swapped()

		If This.IsListOfSections() and
		   StzListQ(_aSwapped_).MergeQ().IsSortedInDescending()

				_bResult_ = 1

		ok

		return _bResult_

	  #---------------------------------------------#
	 #   CHECHKING IF AN ITEM EXISTS IN ANY PAIR   #
	#---------------------------------------------#

	# TRUE if the item is the first or the second item of at least one pair.
	#
	#   returns    TRUE or FALSE
	#   note       the aliases ContainsInAllPairs and ContainsThisInAllPairs answer the same as this
	#              method, so they say TRUE when only one pair holds the item
	#   see        FirstItems, SecondItems
	def ContainsInAnyPair(pItem)
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		_bResult_ = 0
		
		for i = 1 to _nLen_
			if ListContains(_aContent_[i], pItem)
				_bResult_ = 1
				exit
			ok
		next

		return _bResult_

		#< @FunctionAlternativeForms

		def ContainsThisInAnyPair(pItem)
			return This.ContainsInAnyPair(pItem)

		def ContainsInAllPairs(pItem)
			return This.ContainsInAnyPair(pItem)

		def ContainsThisInAllPairs(pItem)
			return This.ContainsInAnyPair(pItem)

		def ContainsInside(pItem)
			return This.ContainsInAnyPair(pItem)

		def ContainsThisInside(pItem)
			return This.ContainsInAnyPair(pItem)

		#>

	  #===================================================#
	 #  CHECKING IF THE TWO VALUES ARE ANOGRAMS STRINGS  #
	#===================================================#

	def AreAnagramsCS(pCaseSensitive)

		_val1_ = This.FirstValue()
		_val2_ = This.SecondValue()

		if @BothAreStrings(_val1_, _val2_) and
		   Q(_val1_).IsAnagramOfCS(_val2_, pCaseSensitive)

			return 1
		else
			return 0
		ok

	# Raises error R14 today instead of telling whether the two items are anagrams of each other.
	#
	#   returns    nothing today; the call raises
	#   warning    Raises R14 today on every call: it reads FirstValue and SecondValue, which this
	#              class does not define
	#   see        FirstItems
	def AreAnagrams()
		return This.AreAnagramsCS(1)

	  #===============================================#
	 #  CHECKING IF THE FIRST ITEMS ARE ALL NUMBERS  #
	#===============================================#

	# TRUE if the first item of every pair is a number.
	#
	#   returns    TRUE or FALSE
	#   see        SecondItemsAreNumbers, FirstItemsAreStrings
	def FirstItemsAreNumbers()
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		_bResult_ = 1

		for i = 1 to _nLen_
			if NOT isNumber(_aContent_[i][1])
				_bResult_ = 0
				exit
			ok
		next

		return _bResult_

		def FirstItemsAreAllNumbers()
			return This.FirstItemsAreNumbers()

		def FirstItemsAreOnlyNumbers()
			return This.FirstItemsAreNumbers()

		def FirstItemsAreJustNumbers()
			return This.FirstItemsAreNumbers()

	  #-----------------------------------------------#
	 #  CHECKING IF THE FIRST ITEMS ARE ALL STRINGS  #
	#-----------------------------------------------#

	# TRUE if the first item of every pair is a text.
	#
	#   returns    TRUE or FALSE
	#   see        SecondItemsAreStrings, FirstItemsAreChars
	def FirstItemsAreStrings()
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		_bResult_ = 1

		for i = 1 to _nLen_
			if NOT isString(_aContent_[i][1])
				_bResult_ = 0
				exit
			ok
		next

		return _bResult_

		def FirstItemsAreAllStrings()
			return This.FirstItemsAreStrings()

		def FirstItemsAreOnlyStrings()
			return This.FirstItemsAreStrings()

		def FirstItemsAreJustStrings()
			return This.FirstItemsAreStrings()

	  #---------------------------------------------#
	 #  CHECKING IF THE FIRST ITEMS ARE ALL CHARS  #
	#---------------------------------------------#

	# TRUE if the first item of every pair is a single character.
	#
	#   returns    TRUE or FALSE
	#   note       a one-digit number counts as a character; "ab" does not
	#   see        SecondItemsAreChars, FirstItemsAreStrings
	def FirstItemsAreChars()
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		_bResult_ = 1

		for i = 1 to _nLen_
			if NOT @IsChar(_aContent_[i][1])
				_bResult_ = 0
				exit
			ok
		next

		return _bResult_

		def FirstItemsAreAllChars()
			return This.FirstItemsAreChars()

		def FirstItemsAreOnlyChars()
			return This.FirstItemsAreChars()

		def FirstItemsAreJustChars()
			return This.FirstItemsAreChars()

	  #---------------------------------------------#
	 #  CHECKING IF THE FIRST ITEMS ARE ALL LISTS  #
	#---------------------------------------------#

	# TRUE if the first item of every pair is a list.
	#
	#   returns    TRUE or FALSE
	#   see        SecondItemsAreLists, FirstItemsAreObjects
	def FirstItemsAreLists()
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		_bResult_ = 1

		for i = 1 to _nLen_
			if NOT isList(_aContent_[i][1])
				_bResult_ = 0
				exit
			ok
		next

		return _bResult_

		def FirstItemsAreAllLists()
			return This.FirstItemsAreLists()

		def FirstItemsAreOnlyLists()
			return This.FirstItemsAreLists()

		def FirstItemsAreJustLists()
			return This.FirstItemsAreLists()

	  #-----------------------------------------------#
	 #  CHECKING IF THE FIRST ITEMS ARE ALL OBJECTS  #
	#-----------------------------------------------#

	# TRUE if the first item of every pair is an object of any class.
	#
	#   returns    TRUE or FALSE
	#   see        SecondItemsAreObjects, FirstItemsAreStzObjects
	def FirstItemsAreObjects()
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		_bResult_ = 1

		for i = 1 to _nLen_
			if NOT isObject(_aContent_[i][1])
				_bResult_ = 0
				exit
			ok
		next

		return _bResult_

		def FirstItemsAreAllObjects()
			return This.FirstItemsAreObjects()

		def FirstItemsAreOnlyObjects()
			return This.FirstItemsAreObjects()

		def FirstItemsAreJustObjects()
			return This.FirstItemsAreObjects()

	  #--------------------------------------------------#
	 #  CHECKING IF THE FIRST ITEMS ARE ALL STZOBJECTS  #
	#--------------------------------------------------#

	# TRUE if the first item of every pair is an object of the library, such as a stzString.
	#
	#   returns    TRUE or FALSE
	#   see        SecondItemsAreStzObjects, FirstItemsAreObjects
	def FirstItemsAreStzObjects()
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		_bResult_ = 1

		for i = 1 to _nLen_
			if NOT @IsStzObject(_aContent_[i][1])
				_bResult_ = 0
				exit
			ok
		next

		return _bResult_

		def FirstItemsAreAllStzObjects()
			return This.FirstItemsAreStzObjects()

		def FirstItemsAreOnlyStzObjects()
			return This.FirstItemsAreStzObjects()

		def FirstItemsAreJustStzObjects()
			return This.FirstItemsAreStzObjects()

	  #------------------------------------------------#
	 #  CHECKING IF THE FIRST ITEMS ARE ALL STZCHARS  #
	#------------------------------------------------#

	# TRUE if the first item of every pair is a stzChar.
	#
	#   returns    TRUE or FALSE
	#   see        SecondItemsAreStzChars, FirstItemsAreStzStrings
	def FirstItemsAreStzChars()
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		_bResult_ = 1

		for i = 1 to _nLen_
			if NOT @IsStzChar(_aContent_[i][1])
				_bResult_ = 0
				exit
			ok
		next

		return _bResult_

		def FirstItemsAreAllStzChars()
			return This.FirstItemsAreStzChars()

		def FirstItemsAreOnlyStzChars()
			return This.FirstItemsAreStzChars()

		def FirstItemsAreJustStzChars()
			return This.FirstItemsAreStzChars()

	  #--------------------------------------------------#
	 #  CHECKING IF THE FIRST ITEMS ARE ALL STZSTRINGS  #
	#--------------------------------------------------#

	# TRUE if the first item of every pair is a stzString.
	#
	#   returns    TRUE or FALSE
	#   see        SecondItemsAreStzStrings, FirstItemsAreStzChars
	def FirstItemsAreStzStrings()
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		_bResult_ = 1

		for i = 1 to _nLen_
			if NOT @IsStzString(_aContent_[i][1])
				_bResult_ = 0
				exit
			ok
		next

		return _bResult_

		def FirstItemsAreAllStzStrings()
			return This.FirstItemsAreStzStrings()

		def FirstItemsAreOnlyStzStrings()
			return This.FirstItemsAreStzStrings()

		def FirstItemsAreJustStzStrings()
			return This.FirstItemsAreStzStrings()

	  #--------------------------------------------------#
	 #  CHECKING IF THE FIRST ITEMS ARE ALL STZNUMBERS  #
	#--------------------------------------------------#

	# TRUE if the first item of every pair is a stzNumber.
	#
	#   returns    TRUE or FALSE
	#   see        SecondItemsAreStzNumbers, FirstItemsAreStzObjects
	def FirstItemsAreStzNumbers()
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		_bResult_ = 1

		for i = 1 to _nLen_
			if NOT @IsStzNumber(_aContent_[i][1])
				_bResult_ = 0
				exit
			ok
		next

		return _bResult_

		def FirstItemsAreAllStzNumbers()
			return This.FirstItemsAreStzNumbers()

		def FirstItemsAreOnlyStzNumbers()
			return This.FirstItemsAreStzNumbers()

		def FirstItemsAreJustStzNumbers()
			return This.FirstItemsAreStzNumbers()

	  #------------------------------------------------#
	 #  CHECKING IF THE FIRST ITEMS ARE ALL STZLISTS  #
	#------------------------------------------------#

	# TRUE if the first item of every pair is a stzList.
	#
	#   returns    TRUE or FALSE
	#   see        SecondItemsAreStzLists, FirstItemsAreStzHashLists
	def FirstItemsAreStzLists()
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		_bResult_ = 1

		for i = 1 to _nLen_
			if NOT @IsStzList(_aContent_[i][1])
				_bResult_ = 0
				exit
			ok
		next

		return _bResult_

		def FirstItemsAreAllStzLists()
			return This.FirstItemsAreStzLists()

		def FirstItemsAreOnlyStzLists()
			return This.FirstItemsAreStzLists()

		def FirstItemsAreJustStzLists()
			return This.FirstItemsAreStzLists()

	  #----------------------------------------------------#
	 #  CHECKING IF THE FIRST ITEMS ARE ALL STZHASHLISTS  #
	#----------------------------------------------------#

	# TRUE if the first item of every pair is a stzHashList.
	#
	#   returns    TRUE or FALSE
	#   see        SecondItemsAreStzHashLists, FirstItemsAreStzLists
	def FirstItemsAreStzHashLists()
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		_bResult_ = 1

		for i = 1 to _nLen_
			if NOT @IsStzHashList(_aContent_[i][1])
				_bResult_ = 0
				exit
			ok
		next

		return _bResult_

		def FirstItemsAreAllStzHashLists()
			return This.FirstItemsAreStzHashLists()

		def FirstItemsAreOnlyStzHashLists()
			return This.FirstItemsAreStzHashLists()

		def FirstItemsAreJustStzHashLists()
			return This.FirstItemsAreStzHashLists()

	  #================================================#
	 #  CHECKING IF THE SECOND ITEMS ARE ALL NUMBERS  #
	#================================================#

	# TRUE if the second item of every pair is a number.
	#
	#   returns    TRUE or FALSE
	#   see        FirstItemsAreNumbers, SecondItemsAreStrings
	def SecondItemsAreNumbers()
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		_bResult_ = 1

		for i = 1 to _nLen_
			if NOT isNumber(_aContent_[i][2])
				_bResult_ = 0
				exit
			ok
		next

		return _bResult_

		def SecondItemsAreAllNumbers()
			return This.SecondItemsAreNumbers()

		def SecondItemsAreOnlyNumbers()
			return This.SecondItemsAreNumbers()

		def SecondItemsAreJustNumbers()
			return This.SecondItemsAreNumbers()

	  #------------------------------------------------#
	 #  CHECKING IF THE SECOND ITEMS ARE ALL STRINGS  #
	#------------------------------------------------#

	# TRUE if the second item of every pair is a text.
	#
	#   returns    TRUE or FALSE
	#   see        FirstItemsAreStrings, SecondItemsAreChars
	def SecondItemsAreStrings()
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		_bResult_ = 1

		for i = 1 to _nLen_
			if NOT isString(_aContent_[i][2])
				_bResult_ = 0
				exit
			ok
		next

		return _bResult_

		def SecondItemsAreAllStrings()
			return This.SecondItemsAreStrings()

		def SecondItemsAreOnlyStrings()
			return This.SecondItemsAreStrings()

		def SecondItemsAreJustStrings()
			return This.SecondItemsAreStrings()

	  #----------------------------------------------#
	 #  CHECKING IF THE SECOND ITEMS ARE ALL CHARS  #
	#----------------------------------------------#

	# TRUE if the second item of every pair is a single character.
	#
	#   returns    TRUE or FALSE
	#   note       a one-digit number counts as a character; 12 does not
	#   see        FirstItemsAreChars, SecondItemsAreStrings
	def SecondItemsAreChars()
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		_bResult_ = 1

		for i = 1 to _nLen_
			if NOT @IsChar(_aContent_[i][2])
				_bResult_ = 0
				exit
			ok
		next

		return _bResult_

		def SecondItemsAreAllChars()
			return This.SecondItemsAreChars()

		def SecondItemsAreOnlyChars()
			return This.SecondItemsAreChars()

		def SecondItemsAreJustChars()
			return This.SecondItemsAreChars()

	  #----------------------------------------------#
	 #  CHECKING IF THE SECOND ITEMS ARE ALL LISTS  #
	#----------------------------------------------#

	# TRUE if the second item of every pair is a list.
	#
	#   returns    TRUE or FALSE
	#   see        FirstItemsAreLists, SecondItemsAreObjects
	def SecondItemsAreLists()
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		_bResult_ = 1

		for i = 1 to _nLen_
			if NOT isList(_aContent_[i][2])
				_bResult_ = 0
				exit
			ok
		next

		return _bResult_

		def SecondItemsAreAllLists()
			return This.SecondItemsAreLists()

		def SecondItemsAreOnlyLists()
			return This.SecondItemsAreLists()

		def SecondItemsAreJustLists()
			return This.SecondItemsAreLists()

	  #------------------------------------------------#
	 #  CHECKING IF THE SECOND ITEMS ARE ALL OBJECTS  #
	#------------------------------------------------#

	# TRUE if the second item of every pair is an object of any class.
	#
	#   returns    TRUE or FALSE
	#   see        FirstItemsAreObjects, SecondItemsAreStzObjects
	def SecondItemsAreObjects()
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		_bResult_ = 1

		for i = 1 to _nLen_
			if NOT isObject(_aContent_[i][2])
				_bResult_ = 0
				exit
			ok
		next

		return _bResult_

		def SecondItemsAreAllObjects()
			return This.SecondItemsAreObjects()

		def SecondItemsAreOnlyObjects()
			return This.SecondItemsAreObjects()

		def SecondItemsAreJustObjects()
			return This.SecondItemsAreObjects()

	  #---------------------------------------------------#
	 #  CHECKING IF THE SECOND ITEMS ARE ALL STZOBJECTS  #
	#---------------------------------------------------#

	# TRUE if the second item of every pair is an object of the library, such as a stzNumber.
	#
	#   returns    TRUE or FALSE
	#   see        FirstItemsAreStzObjects, SecondItemsAreObjects
	def SecondItemsAreStzObjects()
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		_bResult_ = 1

		for i = 1 to _nLen_
			if NOT @IsStzObject(_aContent_[i][2])
				_bResult_ = 0
				exit
			ok
		next

		return _bResult_

		def SecondItemsAreAllStzObjects()
			return This.SecondItemsAreStzObjects()

		def SecondItemsAreOnlyStzObjects()
			return This.SecondItemsAreStzObjects()

		def SecondItemsAreJustStzObjects()
			return This.SecondItemsAreStzObjects()

	  #-------------------------------------------------#
	 #  CHECKING IF THE SECOND ITEMS ARE ALL STZCHARS  #
	#-------------------------------------------------#

	# TRUE if the second item of every pair is a stzChar.
	#
	#   returns    TRUE or FALSE
	#   see        FirstItemsAreStzChars, SecondItemsAreStzStrings
	def SecondItemsAreStzChars()
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		_bResult_ = 1

		for i = 1 to _nLen_
			if NOT @IsStzChar(_aContent_[i][2])
				_bResult_ = 0
				exit
			ok
		next

		return _bResult_

		def SecondItemsAreAllStzChars()
			return This.SecondItemsAreStzChars()

		def SecondItemsAreOnlyStzChars()
			return This.SecondItemsAreStzChars()

		def SecondItemsAreJustStzChars()
			return This.SecondItemsAreStzChars()

	  #---------------------------------------------------#
	 #  CHECKING IF THE SECOND ITEMS ARE ALL STZSTRINGS  #
	#---------------------------------------------------#

	# TRUE if the second item of every pair is a stzString.
	#
	#   returns    TRUE or FALSE
	#   see        FirstItemsAreStzStrings, SecondItemsAreStzChars
	def SecondItemsAreStzStrings()
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		_bResult_ = 1

		for i = 1 to _nLen_
			if NOT @IsStzString(_aContent_[i][2])
				_bResult_ = 0
				exit
			ok
		next

		return _bResult_

		def SecondItemsAreAllStzStrings()
			return This.SecondItemsAreStzStrings()

		def SecondItemsAreOnlyStzStrings()
			return This.SecondItemsAreStzStrings()

		def SecondItemsAreJustStzStrings()
			return This.SecondItemsAreStzStrings()

	  #---------------------------------------------------#
	 #  CHECKING IF THE SECOND ITEMS ARE ALL STZNUMBERS  #
	#---------------------------------------------------#

	# TRUE if the second item of every pair is a stzNumber.
	#
	#   returns    TRUE or FALSE
	#   see        FirstItemsAreStzNumbers, SecondItemsAreStzObjects
	def SecondItemsAreStzNumbers()
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		_bResult_ = 1

		for i = 1 to _nLen_
			if NOT @IsStzNumber(_aContent_[i][2])
				_bResult_ = 0
				exit
			ok
		next

		return _bResult_

		def SecondItemsAreAllStzNumbers()
			return This.SecondItemsAreStzNumbers()

		def SecondItemsAreOnlyStzNumbers()
			return This.SecondItemsAreStzNumbers()

		def SecondItemsAreJustStzNumbers()
			return This.SecondItemsAreStzNumbers()

	  #-------------------------------------------------#
	 #  CHECKING IF THE SECOND ITEMS ARE ALL STZLISTS  #
	#-------------------------------------------------#

	# TRUE if the second item of every pair is a stzList.
	#
	#   returns    TRUE or FALSE
	#   see        FirstItemsAreStzLists, SecondItemsAreStzHashLists
	def SecondItemsAreStzLists()
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		_bResult_ = 1

		for i = 1 to _nLen_
			if NOT @IsStzList(_aContent_[i][2])
				_bResult_ = 0
				exit
			ok
		next

		return _bResult_

		def SecondItemsAreAllStzLists()
			return This.SecondItemsAreStzLists()

		def SecondItemsAreOnlyStzLists()
			return This.SecondItemsAreStzLists()

		def SecondItemsAreJustStzLists()
			return This.SecondItemsAreStzLists()

	  #-----------------------------------------------------#
	 #  CHECKING IF THE SECOND ITEMS ARE ALL STZHASHLISTS  #
	#-----------------------------------------------------#

	# TRUE if the second item of every pair is a stzHashList.
	#
	#   returns    TRUE or FALSE
	#   see        FirstItemsAreStzHashLists, SecondItemsAreStzLists
	def SecondItemsAreStzHashLists()
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		_bResult_ = 1

		for i = 1 to _nLen_
			if NOT @IsStzHashList(_aContent_[i][2])
				_bResult_ = 0
				exit
			ok
		next

		return _bResult_

		def SecondItemsAreAllStzHashLists()
			return This.SecondItemsAreStzHashLists()

		def SecondItemsAreOnlyStzHashLists()
			return This.SecondItemsAreStzHashLists()

		def SecondItemsAreJustStzHashLists()
			return This.SecondItemsAreStzHashLists()

	  #=====================================================#
	 #  TRANSFORMING THE LIST OF PAIRS INTO A STZHASHLIST  #
	#=====================================================#

	# Returns a stzHashList whose keys are the first items and whose values are the second items, each wrapped in a one-item list.
	#
	#   returns    a stzHashList; [ "a", 1 ] becomes [ "a", [ 1 ] ]
	#   note       raises an error when a first item is not a text, or when two pairs share a first
	#              item
	#   see        ToStzList, FirstItemsAreStrings
	def ToStzHashList()
		if NOT This.FirstItemsAreAllStrings()
			StzRais("Can't transform the list of pairs into a stzHashList! First items of the pairs must all be strings.")
		ok

		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		_aHash_ = []

		for i = 1 to _nLen_
			_aHash_ + [ _aContent_[i][1], [ _aContent_[i][2] ] ]
		next

		_oResult_ = new stzHashList(_aHash_)
		return _oResult_


	# Returns the pairs as a stzListOfSections, each pair read as [ start, end ].
	#
	#   returns    a stzListOfSections
	#   note       raises an error when the pairs are not pairs of numbers
	#   see        ToStzSetOfSections, IsListOfSections
	def ToStzListOfSections()
		return new stzListOfSections(This.Content())

	# Raises an error today instead of returning the pairs as a stzSetOfSections.
	#
	#   returns    nothing today; the call raises
	#   note       ToStzListOfSections accepts the same pairs
	#   warning    Raises "You must provide a list of sections" today for valid sections such as [ [
	#              1, 3 ], [ 5, 8 ] ]: the stzSetOfSections constructor refuses what
	#              stzListOfSections accepts
	#   see        ToStzListOfSections
	def ToStzSetOfSections()
		return new stzSetOfSections(This.Content())
