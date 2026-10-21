/*
	NOTE:

	Semantically speaking:

	_LIST_	-->	_item_
	SET	-->	Element
	_STRING_	-->	Char

*/

func StzSetQ(paList)
	return new stzSet(paList)

func IsSet(paList)
	if CheckingParams()
		if NOT isList(paList)
			StzRaise("Incorrect param type! paList must be a list.")
		ok
	ok

	_nLen_ = len(paList)
	if _nLen_ = 0
		return 0
	but _nLen_ = 1
		return 1
	ok

	# Engine-backed: check if all elements are unique
	_pList_ = StzEngineMarshalList(paList)
	_nResult_ = StzEngineListAllUniqueCS(_pList_, 1)
	StzEngineListFree(_pList_)
	return _nResult_

	#< @FunctionAlternativeForms

	func @IsSet(paList)
		return IsSet(paList)

	#--

	func IsASet(paList)
		return IsSet(paList)

	func @IsASet(paList)
		return IsSet(paList)

	#>

# Builds the message of an error raised by stzSet, in the library's What / Why / Todo shape.
#
#   pcError    the name of the error, such as :CanNotCreateSet
#   returns    a text
#   note       an unknown name gives the header line only; the function stood undefined before, so
#              every guard of the class raised error R3 instead of its own message
func stzSetError(pcError)
	_cErrorMsg_ = "in file stzSet.ring:" + char(10)

	switch pcError
	on :CanNotCreateSet
		_cErrorMsg_ += "   What : Can't create the stzSet object!" + char(10)
		_cErrorMsg_ += "   Why  : The value you provided is not a list." + char(10)
		_cErrorMsg_ += "   Todo : Provide a list; its repeated items are dropped." + char(10)

	on :CanNotUpdateSetWithNonSet
		_cErrorMsg_ += "   What : Can't update the set!" + char(10)
		_cErrorMsg_ += "   Why  : The new content is not a list without repeated items." + char(10)
		_cErrorMsg_ += "   Todo : Provide a list without repeats, or build a stzSet from it first." + char(10)

	on :CanNotComputeUnionWithNoSet
		_cErrorMsg_ += "   What : Can't compute the union!" + char(10)
		_cErrorMsg_ += "   Why  : The other value is not a list without repeated items." + char(10)
		_cErrorMsg_ += "   Todo : Provide a list without repeats, or build a stzSet from it first." + char(10)

	on :CanNotComputeUnionWithNonSets
		_cErrorMsg_ += "   What : Can't compute the union with many sets!" + char(10)
		_cErrorMsg_ += "   Why  : The value is not a list of lists without repeated items." + char(10)
		_cErrorMsg_ += "   Todo : Provide a list whose every item is a list without repeats." + char(10)

	on :CanNotComputeIntersectionWithNonSets
		_cErrorMsg_ += "   What : Can't compute the intersection with many lists!" + char(10)
		_cErrorMsg_ += "   Why  : The value is not a list of lists." + char(10)
		_cErrorMsg_ += "   Todo : Provide a list whose every item is a list." + char(10)

	on :CanNotListTooManySubsets
		_cErrorMsg_ += "   What : Can't list the subsets!" + char(10)
		_cErrorMsg_ += "   Why  : They are more than 65536, and listing them would fill the memory." + char(10)
		_cErrorMsg_ += "   Todo : Use a set of at most 16 items, ask for subsets of a size that has fewer, or count them with NumberOfSubsets." + char(10)

	on :CanNotListSubsetsOfThisSize
		_cErrorMsg_ += "   What : Can't list the subsets of a given size!" + char(10)
		_cErrorMsg_ += "   Why  : The size is not a whole number of at least 0." + char(10)
		_cErrorMsg_ += "   Todo : Provide 0, 1, 2 and so on." + char(10)

	on :CanNotCountSubsets
		_cErrorMsg_ += "   What : Can't count the subsets!" + char(10)
		_cErrorMsg_ += "   Why  : The set holds more than 1023 items, so 2 to the power of its size is not a number a computer can hold." + char(10)
		_cErrorMsg_ += "   Todo : Count the subsets of a smaller set." + char(10)

	off

	return _cErrorMsg_

# Holds a list without repeats, a mathematical set, and gives its union, intersection and difference with other lists.
#
# A set is built with new stzSet(aList) or StzSetQ(aList) and drops every repeated item on the way
# in, keeping the first of each; case counts, so a and A are two elements. It is a stzList
# underneath, so the stzList methods are available on it, and stzListFlattener.ToStzSet hands one
# back. UnionWith, IntersectionWith and DifferenceWith return a plain list and leave the set as it
# was, their Q form wrapping the answer in a new stzSet; UnifyWith and the Update family change the
# set in place. A bad argument raises the class's own message (stzSetError). Subsets and
# SubSetsOfNElements list the subsets by size, then by the position of their items, and NumberOfSubsets
# counts them without listing them; listing is refused beyond 65536 subsets. AddElement only accepts a
# list element; Includes and Contains take a list of elements and cannot test one item; Updated simply
# returns its argument. Hebrew, Arabic and emoji elements are kept like any other text.
#
#   receiver   o1 = new stzSet([ 3, 1, 3, 2, 1 ])
#   example    ? @@( o1.Content() )
#              #--> [ 3, 1, 2 ]
#              ? @@( o1.UnionWith([ 5, 4 ]) )
#              #--> [ 3, 1, 2, 5, 4 ]
#              ? @@( o1.IntersectionWith([ 2, 3, 9 ]) )
#              #--> [ 3, 2 ]
#              ? @@( o1.DifferenceWith([ 2, 9 ]) )
#              #--> [ 3, 1 ]
#              ? o1.Includes([ 1, 2 ])
#              #--> 1
#              ? o1.IsIncludedIn([ 1, 2, 3, 4 ])
#              #--> 1
#              o2 = new stzSet([ "שלום", "😀", "שלום" ])
#              ? o2.NumberOfElements()
#              #--> 2
#   see        stzList, stzListComparator, stzListMerger
class stzSet from stzList
	@aContent = []

	  #-----------#
	 #    INIT   #
	#-----------#

	# Builds a set from a list, dropping every repeated item and keeping the first of each.
	#
	#   paList     the list to make a set of, repeats allowed
	#   returns    nothing; the object is built
	#   note       new stzSet([ 3, 1, 3, 2, 1 ]) holds 3, 1, 2; case counts, so a and A are two
	#              elements
	#   warning    a value that is not a list raises the message "Can't create the stzSet object!"
	#   see        Content, Update
	def init(paList)

		if NOT isList(paList)
			StzRaise(stzSetError(:CanNotCreateSet))
		ok

		# Engine-backed deduplication
		_pList_ = StzEngineMarshalList(paList)
		pUnique = StzEngineListUniqueCS(_pList_, 1)
		@aContent = StzEngineListContentToRingList(pUnique)
		StzEngineListFree(pUnique)
		StzEngineListFree(_pList_)

		if KeepingHistory() = 1
			This.AddHistoricValue(This.Content())
		ok

	  #-------------#
	 #   GENERAL   #
	#-------------#

	# Returns the elements of the set, in the order they were first met.
	#
	#   returns    a list
	#   see        Set, Value, ToStzList
	def Content()
		return @aContent

		# Returns the elements of the set, in the order they were first met.
		#
		#   returns    a list
		#   note       the same answer as Content
		#   see        Content, Set
		def Value()
			return Content()

	# Returns the elements of the set, in the order they were first met.
	#
	#   returns    a list
	#   note       the same answer as Content
	#   see        Content, ToStzList
	def Set()
		return @aContent

	# Returns the elements of the set as a stzList object.
	#
	#   returns    a stzList
	#   note       the stzList is a separate object: editing it does not edit the set
	#   see        Set, Content
	def ToStzList()
		return new stzList( This.Set() )

	# Replaces the elements of the set with another set.
	#
	#   paOtherSet   the new elements, a list without repeats, or a pair such as [ :With, aSet ]
	#   returns      nothing; the content changes. UpdateQ returns the set for chaining
	#   note         the new list is kept as it is, so build a stzSet first to drop repeats
	#   warning      a list that holds a repeated item, such as [ 1, 1, 2 ], raises the message
	#                "Can't update the set!"
	#   see          UpdateWith, Updated, UnifyWith
	#@ aka  --
	def Update(paOtherSet)
		if CheckingParams()
			if isList(paOtherSet) and IsWithOrByOrUsingNamedParamList(paOtherSet)
				paOtherSet = paOtherSet[2]
			ok
	
			If NOT @IsSet(paOtherSet)
				StzRaise(stzSetError(:CanNotUpdateSetWithNonSet))
			ok
		ok

		@aContent = paOtherSet

		if KeepingHisto() = 1
			This.AddHistoricValue(This.Content())  # From the parent stzObject
		ok

		#< @FunctionFluentForm

		def UpdateQ(paOtherSet)
			This.Update(paOtherSet)
			return This

		# Replaces the elements of the set with another set.
		#
		#   paOtherSet   the new elements, a list without repeats
		#   returns      nothing; the content changes. UpdateWithQ returns the set for chaining
		#   note         the same call as Update
		#   warning      a list with a repeated item raises the message of Update
		#   see          Update, UpdateBy
		#>
		#< @FunctionAlternativeForms
		def UpdateWith(paOtherSet)
			This.Update(paOtherSet)

			def UpdateWithQ(paOtherSet)
				return This.UpdateQ(paOtherSet)
	
		# Replaces the elements of the set with another set.
		#
		#   paOtherSet   the new elements, a list without repeats
		#   returns      nothing; the content changes. UpdateByQ returns the set for chaining
		#   note         the same call as Update
		#   warning      a list with a repeated item raises the message of Update
		#   see          Update, UpdateUsing
		def UpdateBy(paOtherSet)
			This.Update(paOtherSet)

			def UpdateByQ(paOtherSet)
				return This.UpdateQ(paOtherSet)

		# Replaces the elements of the set with another set.
		#
		#   paOtherSet   the new elements, a list without repeats
		#   returns      nothing; the content changes. UpdateUsingQ returns the set for chaining
		#   note         the same call as Update
		#   warning      a list with a repeated item raises the message of Update
		#   see          Update, UpdateBy
		def UpdateUsing(paOtherSet)
			This.Update(paOtherSet)

			def UpdateUsingQ(paOtherSet)
				return This.UpdateQ(paOtherSet)

	# Returns the list it is given, without touching the set.
	#
	#   paOtherSet   the list to give back
	#   returns      the argument, unchanged
	#   note         it computes nothing: Updated([ 1, 2 ]) answers [ 1, 2 ] whatever the set holds,
	#                and the set is left as it was; UpdatedWith, UpdatedBy and UpdatedUsing are the
	#                same call
	#   see          Update, UnionWith
		#>
	def Updated(paOtherSet)
		return paOtherSet

		#< @FunctionAlternativeForms

		def UpdatedWith(paOtherSet)
			return This.Updated(paOtherSet)

		def UpdatedBy(paOtherSet)
			return This.Updated(paOtherSet)

		def UpdatedUsing(paOtherSet)
			return This.Updated(paOtherSet)

		#>

	  #----------------------------------#
	 #   ADDING AN ELEMENT TO THE SET   #
	#----------------------------------#

	# Appends a new list element to the set, in place.
	#
	#   pElm       the element to add
	#   returns    nothing; the content changes. AddElementQ returns the set for chaining
	#   note       an element can be of any kind once added: the set holds x and [ 1 ] together
	#   warning    a text or a number raises error Incorrect param type! paList must be a list (7, 8
	#              and "z" were tried), because it asks Contains whether the element is present and
	#              Contains of this class takes a set; only a list element can be added, as in
	#              AddElement([ 8 ]); a list whose items are all in the set already, such as [ 1 ]
	#              for a set holding 1, is ignored, because the list is read as a set of elements,
	#              not as one element
	#   see        NumberOfElements, UnifyWith
	def AddElement(pElm)
		if not This.Contains(pElm)	# From StzList
			_aContent_ = This.Content()
			_aContent_ + pElm
			This.UpdateWith(_aContent_)
		ok

	def AddElementQ(pElm)
		This.AddElement(pElm)
		return This

	  #---------------------------------------#
	 #    NTH ELEMENT & NUMBER OF ELEMENTS   #
	#---------------------------------------#

	# Returns how many elements the set holds.
	#
	#   returns    a number
	#   see        Element, Content
	def NumberOfElements()
		return len( This.Set() )

	# Returns the element at a position, counting from 1.
	#
	#   i          the position of the element, from 1
	#   returns    the element
	#   warning    a position outside the set raises error R2 Array Access (Index out of range)
	#   see        NumberOfElements, Content
	def Element(i)
		return This.Set()[i]

	  #---------------------------#
	 #    UNION WITH OTHER SET   #
	#---------------------------#

	# Returns the elements of the set followed by those of another set that are not already in it.
	#
	#   paOtherSet   the set whose new elements are added, without repeats
	#   returns      a list
	#   note         the answer is a plain list and the set is left as it was; UnionWithQ returns a
	#                stzSet
	#   warning      a list that holds a repeated item raises the message "Can't compute the union!"
	#   see          UnifyWith, IntersectionWith, DifferenceWith
	def UnionWith(paOtherSet)
		// If necessary, transform the provided list to a set
		if NOT @IsSet(paOtherSet)
			StzRaise(stzSetError(:CanNotComputeUnionWithNoSet))
		ok

		# Engine-backed O(n log n) union
		pListA = StzEngineMarshalList(This.Content())
		pListB = StzEngineMarshalList(paOtherSet)
		pResult = StzEngineListUnionCS(pListA, pListB, 1)
		_aUnion_ = StzEngineListContentToRingList(pResult)
		StzEngineListFree(pResult)
		StzEngineListFree(pListB)
		StzEngineListFree(pListA)
		return _aUnion_

	def UnionWithQ(paOtherSet)
		return new stzSet( This.UnionWith(paOtherSet) )

	# Adds the elements of another set that are not already present, in place.
	#
	#   paOtherSet   the set whose new elements are added, without repeats
	#   returns      nothing; the content changes. UnifyWithQ returns the set for chaining
	#   warning      a list that holds a repeated item raises the message of UnionWith
	#   see          UnionWith, Update
	def UnifyWith(paOtherSet)
		This.Update( This.UnionWith(paOtherSet) )

	def UnifyWithQ(paOtherSet)
		This.UnifyWith(paOtherSet)
		return This
	
	  #---------------------------------#
	 #    UNION WITH MANY OTHER SETS   #
	#---------------------------------#

	# Returns the elements of the set followed by the new ones of each of several sets, in order.
	#
	#   paListOfSets   a list of lists, each one without repeats
	#   returns        a list
	#   note           the answer is a plain list and the set is left as it was; UnionWithManyQ returns
	#                  a stzSet
	#   warning        a list of lists in which one holds a repeated item raises the message "Can't
	#                  compute the union with many sets!"
	#   see            UnionWith, UnifyWithMany
	def UnionWithMany(paListOfSets)
		#TODO // Add "These" as alternative of "Many"

		if NOT @IsListOfSets(paListOfSets)
			StzRaise(stzSetError(:CanNotComputeUnionWithNonSets))
		ok

		_aUnion_ = This.Content()
		_nListOfLists1Len_ = len(paListOfSets)
		for _iLoopListOfLists1_ = 1 to _nListOfLists1Len_
			_lst_ = paListOfSets[_iLoopListOfLists1_]
			_nLst1Len_ = len(_lst_)
			for _iLoopLst1_ = 1 to _nLst1Len_
				_item_ = _lst_[_iLoopLst1_]
				if not ItemExists(_item_,_aUnion_)
					_aUnion_ + _item_
				ok
			end
		next

		return _aUnion_

		def UnionWithManyQ(paListOfSets)
			return new stzSet( This.UnionWithMany(paListOfSets))
	
	# Adds the new elements of each of several sets, in place.
	#
	#   paListOfSets   a list of lists, each one without repeats
	#   returns        nothing; the content changes. UnifyWithManyQ returns the set for chaining
	#   warning        a list of lists in which one holds a repeated item raises the message of
	#                  UnionWithMany
	#   see            UnionWithMany, UnifyWith
	def UnifyWithMany(paListOfSets)
		#TODO // Add "These" as alternative of "Many"

		This.Update( This.UnionWithMany(paListOfSets) )

		def UnifyWithManyQ(paListOfSets)
			This.UnifyWithMany(paListOfSets)
			return This

	  #----------------------------------#
	 #    INTERSECTION WITH OTHER SET   #
	#----------------------------------#

	# Returns the elements found in both the set and another list.
	#
	#   paOtherSet   the list to match against, repeats allowed
	#   returns      a list
	#   note         the answer is a plain list in the order of the set and the set is left as it
	#                was; repeats in the other list are dropped first
	#   see          UnionWith, DifferenceWith, Includes
	def IntersectionWith(paOtherSet)
		// If necessary, transform the provided list to a set
		if NOT @IsSet(paOtherSet)
			_oTempSet_ = new stzSet(paOtherSet)
			paOtherSet = _oTempSet_.Content()
		ok

		# Engine-backed O(n log n) intersection
		pListA = StzEngineMarshalList(This.Content())
		pListB = StzEngineMarshalList(paOtherSet)
		pResult = StzEngineListIntersectionCS(pListA, pListB, 1)
		_aIntersection_ = StzEngineListContentToRingList(pResult)
		StzEngineListFree(pResult)
		StzEngineListFree(pListB)
		StzEngineListFree(pListA)
		return _aIntersection_

	  #----------------------------------------#
	 #    INTERSECTION WITH MANY OTHER SETS   #
	#----------------------------------------#

	# Returns the elements of the set found in every one of several lists.
	#
	#   paListOfSets   a list of lists, repeats allowed
	#   returns        a list
	#   note           the answer is a plain list in the order of the set; an empty list of lists
	#                  gives the set itself, and the set is left as it was
	#   warning        a value that is not a list of lists raises the message "Can't compute the
	#                  intersection with many lists!"
	#   see            IntersectionWith, UnionWithMany
	def IntersectionWithMany(paListOfSets)
		if NOT ( isList(paListOfSets) and @IsListOfLists(paListOfSets) )
			StzRaise(stzSetError(:CanNotComputeIntersectionWithNonSets))
		ok

		_aInter_ = This.Content()
		_nSets_ = len(paListOfSets)
		for _iSet_ = 1 to _nSets_
			_oTempSet_ = new stzSet(_aInter_)
			_aInter_ = _oTempSet_.IntersectionWith(paListOfSets[_iSet_])
		next
		return _aInter_

	  #-----------------------------------#
	 #    DIFFERENCE WITH OTHER SET     #
	#-----------------------------------#

	# Returns the elements of the set that are not in another list.
	#
	#   paOtherSet   the list whose elements are taken away, repeats allowed
	#   returns      a list
	#   note         the answer is a plain list and the set is left as it was; DifferenceWithQ
	#                returns a stzSet
	#   see          IntersectionWith, UnionWith
	def DifferenceWith(paOtherSet)
		if NOT @IsSet(paOtherSet)
			_oTempSet_ = new stzSet(paOtherSet)
			paOtherSet = _oTempSet_.Content()
		ok

		# Engine-backed O(n log n) difference
		pListA = StzEngineMarshalList(This.Content())
		pListB = StzEngineMarshalList(paOtherSet)
		pResult = StzEngineListDifferenceCS(pListA, pListB, 1)
		_aDiff_ = StzEngineListContentToRingList(pResult)
		StzEngineListFree(pResult)
		StzEngineListFree(pListB)
		StzEngineListFree(pListA)
		return _aDiff_

	def DifferenceWithQ(paOtherSet)
		return new stzSet( This.DifferenceWith(paOtherSet) )

	  #-------------------------------------------#
	 #    INCLUSION OF THE SET IN AN OTHER SET   #
	#-------------------------------------------#

	# TRUE if every element of the set is also in another list.
	#
	#   paOtherSet   the list that may contain them all, repeats allowed
	#   returns      TRUE or FALSE, as 1 or 0
	#   note         the empty set is included in every list
	#   warning      a single item instead of a list raises error Incorrect param type! paList must
	#                be a list
	#   see          Includes, DifferenceWith
	def IsIncludedIn(paOtherSet)
		// If necessary, transform the provided list to a set
		if NOT @IsSet(paOtherSet)
			_oTempSet_ = new stzList(paOtherSet)
			paOtherSet = _oTempSet_.ToSet()
		ok

		# A is included in B iff A-B is empty (engine-backed)
		_aDiff_ = This.DifferenceWith(paOtherSet)
		return len(_aDiff_) = 0

	  #-------------------------------------------#
	 #    INCLUSION OF AN OTHER SET IN THE SET   #
	#-------------------------------------------#

	# TRUE if every element of another list is also in the set.
	#
	#   paOtherSet   the list whose elements must all be present, repeats allowed
	#   returns      TRUE or FALSE, as 1 or 0
	#   note         Contains is the same call
	#   warning      a single item instead of a list raises error Incorrect param type! paList must
	#                be a list, so Includes and Contains cannot test whether one item is in the set
	#   see          IsIncludedIn, IntersectionWith
	def Includes(paOtherSet)
		// If necessary, transform the provided list to a set
		if NOT @IsSet(paOtherSet)
			_oTempSet_ = new stzSet(paOtherSet)
			paOtherSet = _oTempSet_.Content()
		ok

		# B is included in A iff B-A is empty (engine-backed)
		_oOtherSet_ = new stzSet(paOtherSet)
		_aDiff_ = _oOtherSet_.DifferenceWith(This.Content())
		return len(_aDiff_) = 0

	def Contains(paOtherSet)
		return This.Includes(paOtherSet)

	  #-------------------------#
	 #    SUBSETS OF THE SET   #
	#-------------------------#

	# Returns every subset of the set, the empty one and the set itself included, smallest first.
	#
	#   returns    a list of lists
	#   note       a set of n items has 2^n subsets. They come by size, 0 items first, and within one
	#              size in the order of the positions of their items, [ 1, 2 ] before [ 1, 3 ] before
	#              [ 2, 3 ]; each subset keeps the order of the set and holds the items themselves,
	#              unchanged. The empty set answers [ [ ] ]
	#   warning    more than 65536 subsets, which means a set of more than 16 items, raises the
	#              message "Can't list the subsets!"; NumberOfSubsets counts them without listing
	#   example    o1 = new stzSet([ 1, 2 ])
	#              ? @@( o1.Subsets() )
	#              #--> [ [ ], [ 1 ], [ 2 ], [ 1, 2 ] ]
	#   see        SubSetsOfNElements, NumberOfSubsets
	def Subsets()
		_nSize_ = ring_len(@aContent)
		if _nSize_ > 16
			StzRaise(stzSetError(:CanNotListTooManySubsets))
		ok

		_aAll_ = []
		for _nK_ = 0 to _nSize_
			_aOfK_ = This._SubsetsOfSize_(_nK_)
			_nOfK_ = ring_len(_aOfK_)
			for _i_ = 1 to _nOfK_
				_aAll_ + _aOfK_[_i_]
			next
		next
		return _aAll_

	# Returns the subsets of the set that hold exactly n items, in the order of their positions.
	#
	#   n          how many items each subset holds, a whole number from 0
	#   returns    a list of lists
	#   note       the order is the one of Subsets: [ 1, 2 ] before [ 1, 3 ] before [ 2, 3 ]. A size of
	#              0 answers [ [ ] ], and a size larger than the set answers [ ]
	#   warning    a negative or fractional size, or a value that is not a number, raises the message
	#              "Can't list the subsets of a given size!"; more than 65536 subsets raise the
	#              message of Subsets
	#   example    o1 = new stzSet([ 1, 2, 3 ])
	#              ? @@( o1.SubSetsOfNElements(2) )
	#              #--> [ [ 1, 2 ], [ 1, 3 ], [ 2, 3 ] ]
	#   see        Subsets, NumberOfSubsets
	def SubSetsOfNElements(n)
		if NOT ( isNumber(n) and n >= 0 and n = floor(n) )
			StzRaise(stzSetError(:CanNotListSubsetsOfThisSize))
		ok

		_nSize_ = ring_len(@aContent)
		if n > _nSize_
			return []
		ok
		if This._NumberOfCombinations_(_nSize_, n) > 65536
			StzRaise(stzSetError(:CanNotListTooManySubsets))
		ok
		return This._SubsetsOfSize_(n)

	# Returns how many subsets the set has, counted without listing them.
	#
	#   returns    a number, 2 to the power of the number of items
	#   note       the empty set has 1, and a set of 3 items has 8; the answer is exact, because a
	#              power of 2 is held exactly, and it equals the length of what Subsets lists
	#   warning    a set of more than 1023 items raises the message "Can't count the subsets!"
	#   see        Subsets, SubSetsOfNElements
	def NumberOfSubsets()
		_nSize_ = ring_len(@aContent)
		if _nSize_ > 1023
			StzRaise(stzSetError(:CanNotCountSubsets))
		ok

		_nCount_ = 1
		for _i_ = 1 to _nSize_
			_nCount_ = _nCount_ * 2
		next
		return _nCount_

	# Lists the subsets of one given size by moving a window of positions; used by the methods above.
	#
	#   pnK        how many items each subset holds, from 0 to the size of the set
	#   returns    a list of lists
	def _SubsetsOfSize_(pnK)
		_nSize_ = ring_len(@aContent)
		_aOut_ = []
		if pnK = 0
			_aOut_ + []
			return _aOut_
		ok
		if pnK > _nSize_
			return _aOut_
		ok

		_anIdx_ = []
		for _i_ = 1 to pnK
			_anIdx_ + _i_
		next

		while 1
			_aSub_ = []
			for _i_ = 1 to pnK
				_aSub_ + @aContent[ _anIdx_[_i_] ]
			next
			_aOut_ + _aSub_

			# move the last position that can still move, then reset the ones after it
			_nPos_ = pnK
			while _nPos_ > 0
				if _anIdx_[_nPos_] = _nSize_ - pnK + _nPos_
					_nPos_--
				else
					exit
				ok
			end
			if _nPos_ = 0
				exit
			ok
			_anIdx_[_nPos_] = _anIdx_[_nPos_] + 1
			for _j_ = _nPos_ + 1 to pnK
				_anIdx_[_j_] = _anIdx_[_j_ - 1] + 1
			next
		end
		return _aOut_

	# Counts the ways to choose pnK items among pnN, stopping once the count passes 65536.
	#
	#   pnN        the number of items to choose among
	#   pnK        the number of items to choose
	#   returns    a number, either the exact count or a number above 65536
	def _NumberOfCombinations_(pnN, pnK)
		_nKk_ = pnK
		if pnN - pnK < _nKk_
			_nKk_ = pnN - pnK
		ok

		_nRes_ = 1
		for _i_ = 1 to _nKk_
			_nRes_ = _nRes_ * (pnN - _nKk_ + _i_) / _i_
			if _nRes_ > 65536
				exit
			ok
		next
		return _nRes_
