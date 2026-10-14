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

# Holds a list without repeats, a mathematical set, and gives its union, intersection and difference with other lists.
#
# A set is built with new stzSet(aList) or StzSetQ(aList) and drops every repeated item on the way
# in, keeping the first of each; case counts, so a and A are two elements. It is a stzList
# underneath, so the stzList methods are available on it, and stzListFlattener.ToStzSet hands one
# back. UnionWith, IntersectionWith and DifferenceWith return a plain list and leave the set as it
# was, their Q form wrapping the answer in a new stzSet; UnifyWith and the Update family change the
# set in place. Several guards raise the wrong error today: init, Update and UnionWith call a
# function (stzSetError) that does not exist, so a bad argument raises R3 instead of the intended
# message; AddElement only accepts a list element; Includes and Contains take a list of elements and
# cannot test one item; Updated simply returns its argument; Subsets, SubSetsOfNElements and
# NumberOfSubsets are TODO and answer nothing. Hebrew, Arabic and emoji elements are kept like any
# other text.
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
	#   warning    a value that is not a list raises error R3 Calling Function without definition:
	#              stzseterror, because the function that builds the intended CanNotCreateSet error
	#              does not exist
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
	#   warning      a list that holds a repeated item, such as [ 1, 1, 2 ], raises error R3 Calling
	#                Function without definition: stzseterror, because the function that builds the
	#                intended CanNotUpdateSetWithNonSet error does not exist
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
		#   warning      a list with a repeated item raises error R3, as Update does
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
		#   warning      a list with a repeated item raises error R3, as Update does
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
		#   warning      a list with a repeated item raises error R3, as Update does
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
	#              Contains of this class takes a set; only a list element that is not yet in the
	#              set can be added today, as in AddElement([ 1 ]); adding a list element that is
	#              already present raises error R3 stzseterror instead of being ignored (the list is
	#              read as a set of elements, not as one element)
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
	#   warning      a list that holds a repeated item raises error R3 Calling Function without
	#                definition: stzseterror, because the function that builds the intended
	#                CanNotComputeUnionWithNoSet error does not exist
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
	#   warning      a list that holds a repeated item raises error R3, as UnionWith does
	#   see          UnionWith, Update
	def UnifyWith(paOtherSet)
		This.Update( This.UnionWith(paOtherSet) )

	def UnifyWithQ(paOtherSet)
		This.UnifyWith(paOtherSet)
		return This
	
	  #---------------------------------#
	 #    UNION WITH MANY OTHER SETS   #
	#---------------------------------#

	def UnionWithMany(paListOfSets)
		#TODO // Add "These" as alternative of "Many"

		if NOT @IsListOfSets(paListOfSets)
			StzRaise(stzSetError(:CanNotComputeUnionWithNonSets))
		ok

		_aUnion_ = this.Content()
		_oTempSet_ = this
		_nListOfLists1Len_ = len(paListOfLists)
		for _iLoopListOfLists1_ = 1 to _nListOfLists1Len_
			_lst_ = paListOfLists[_iLoopListOfLists1_]
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

	def IntersectionWithMany(paListOfSets)
		// TODO

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

	# Returns an empty text today, because the method is only a TODO in the code.
	#
	#   returns    an empty text
	#   warning    it computes no subsets: the body is the comment TODO
	#   see        SubSetsOfNElements, NumberOfSubsets
	def Subsets()
		// TODO

	# Returns an empty text today, because the method is only a TODO in the code.
	#
	#   n          the size of the subsets meant to be listed
	#   returns    an empty text
	#   warning    it computes no subsets: the body is the comment TODO
	#   see        Subsets, NumberOfSubsets
	def SubSetsOfNElements(n)
		// TODO

	# Returns 0 today, because it counts the subsets that Subsets does not compute.
	#
	#   returns    the number 0
	#   warning    it is the length of what Subsets answers, an empty text
	#   see        Subsets, SubSetsOfNElements
	def NumberOfSubsets()
		return len( This.Subsets() )
