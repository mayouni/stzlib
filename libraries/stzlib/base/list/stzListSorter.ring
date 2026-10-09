#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTSORTER              #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List sorter subclass -- sorting, reversing, #
#                  classifying operations.                      #
#                  For aliases, use stzListSorterXT.            #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

# Orders a list and answers questions about its order: sorting, reversing, ranking, the extremes and the median.
#
# A sorter is built over a list with new stzListSorter(aList) or StzListSorterQ(aList); stzList has
# its own Sort methods and does not build one. It works on its own copy of the list, so the list you
# passed is never changed. The verbs (SortInAscending, SortInDescending, SortBy..., Reverse) reorder
# the held list in place and return nothing, the Q form returning the sorter so calls chain; the
# past-tense forms (SortedInAscending, SortedBy, Reversed) return a sorted copy and leave the sorter
# alone. Read the held list with Content. Numbers sort by value and come before texts, which sort by
# character code, so Hebrew, Arabic and emoji texts are ordered by code point and a capital letter
# comes before a small one. Min, Max, Median and the Nth forms compare numbers only and answer 0 for
# a list of texts. SortBy takes a text expression where @item is the current item: len(@item) works,
# while an expression using lower() or upper() as the key does not order alphabetically. Ranks and
# positions count from 1.
#
#   receiver   o1 = new stzListSorter([ 5, 2, 9, 1, 7 ])
#   example    ? @@( o1.SortedInAscending() )
#              #--> [ 1, 2, 5, 7, 9 ]
#              ? @@( o1.Ranked() )
#              #--> [ 3, 2, 5, 1, 4 ]
#              ? o1.NthLargest(2)
#              #--> 7
#              o1.SortInDescending()
#              ? @@( o1.Content() )
#              #--> [ 9, 7, 5, 2, 1 ]
#              o2 = new stzListSorter([ "שלום", "אבא", "בית" ])
#              ? @@( o2.Ranked() )
#              #--> [ 3, 1, 2 ]
#              o3 = new stzListSorter([ "b😀", "a😀", "😀" ])
#              ? @@( o3.Ranked() )
#              #--> [ 2, 1, 3 ]
#   see        stzList, stzListFlattener, stzListParser
class stzListSorter from stzObject

	@oList

	  #===================#
	 #   INITIALIZATION  #
	#===================#

	# Builds a sorter over a list, given as a list or as a stzList object.
	#
	#   pListOrObj   the list to sort, or a stzList whose content is copied, any other value raises
	#                an error
	#   returns      nothing; the object is built
	#   note         the sorter works on its own copy: editing it never changes the list or the
	#                stzList you passed in
	#   see          Content, Sorted
	def init(pListOrObj)
		if isList(pListOrObj)
			@oList = new stzList(pListOrObj)
		but isObject(pListOrObj)
			@oList = pListOrObj
		else
			StzRaise("Can't create stzListSorter! Parameter must be a list or stzList object.")
		ok

	  #===============================#
	 #     CONTENT ACCESS            #
	#===============================#

	# Returns the list as it stands now, after the in-place sorts made so far.
	#
	#   returns    a list
	#   see        NumberOfItems, Sorted
	def Content()
		return @oList.Content()

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

	# Returns a new sorter over a copy of the list.
	#
	#   returns    a stzListSorter
	#   note       sorting the copy leaves this sorter alone
	#   see        Content, Sorted
	def Copy()
		return new stzListSorter( @oList.Content() )

	# Replaces the list held by the sorter with another list.
	#
	#   paNewContent   the list that becomes the content
	#   returns        nothing; the content changes
	#   see            Update, Content
	def UpdateWith(paNewContent)
		@oList.UpdateWith(paNewContent)

	# Replaces the list held by the sorter with another list.
	#
	#   paNewContent   the list that becomes the content
	#   returns        nothing; the content changes
	#   note           the same call as UpdateWith
	#   see            UpdateWith, Content
	def Update(paNewContent)
		@oList.UpdateWith(paNewContent)

	  #=============================#
	 #  SORTING ORDER OF THE LIST  #
	#=============================#

	# Returns the order the list is in now: ascending, descending or unsorted.
	#
	#   returns    the text ascending, descending or unsorted
	#   note       a list of equal items, one item and an empty list all answer ascending
	#   see        IsSorted, HasSameSortingOrderAs
	def SortingOrder()
		_cSoResult_ = :Unsorted

		if This.IsSorted()
			if This.IsSortedInAscending()
				_cSoResult_ = :Ascending
			else
				_cSoResult_ = :Descending
			ok
		ok

		return _cSoResult_

	# TRUE if another list is in the same order as the held one: both ascending, both descending or both unsorted.
	#
	#   paOtherList   the list whose order is compared
	#   returns       TRUE or FALSE, as 1 or 0
	#   note          [ 1, 2, 3 ] and [ 5, 6, 7 ] are TRUE, and [ 1, 2, 3 ] and [ 7, 6 ] FALSE;
	#                 HasSameOrderAs is the same call
	#   see           SortingOrder, IsSorted
	def HasSameSortingOrderAs(paOtherList)
		if _ListSortingOrder(paOtherList) = This.SortingOrder()
			return 1
		else
			return 0
		ok

		def HasSameOrderAs(paOtherList)
			return This.HasSameSortingOrderAs(paOtherList)

	  #-----------------------------------#
	 #  IS THE LIST SORTED OR UNSORTED?  #
	#-----------------------------------#

	# TRUE if the list is sorted, in ascending or in descending order.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   see        IsUnsorted, SortingOrder, IsSortedInAscending
	def IsSorted()
		if This.IsSortedInAscending() or
		   This.IsSortedInDescending()
			return 1
		else
			return 0
		ok

	# TRUE if each item is not smaller than the one before it.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       equal items count as sorted, so [ 2, 2, 2 ] is TRUE here and in
	#              IsSortedInDescending; IsSortedUp is the same call
	#   see        IsSortedInDescending, IsSorted
	def IsSortedInAscending()
		_pIsaList_ = @oList._EngineListFromContent()
		_bIsaResult_ = StzEngineListIsSortedAscending(_pIsaList_)
		StzEngineListFree(_pIsaList_)
		return _bIsaResult_

		def IsSortedUp()
			return This.IsSortedInAscending()

	# TRUE if each item is not larger than the one before it.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       IsSortedDown is the same call
	#   see        IsSortedInAscending, IsSorted
	def IsSortedInDescending()
		_pIsdList_ = @oList._EngineListFromContent()
		_bIsdResult_ = StzEngineListIsSortedDescending(_pIsdList_)
		StzEngineListFree(_pIsdList_)
		return _bIsdResult_

		def IsSortedDown()
			return This.IsSortedInDescending()

	# TRUE if the list is in neither ascending nor descending order.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   see        IsSorted, SortingOrder
	def IsUnsorted()
		return NOT This.IsSorted()

	  #----------------------------------#
	 #  SORTING THE ITEMS IN ASCENDING  #
	#----------------------------------#

	# Sorts the held list from the smallest item to the largest, in place.
	#
	#   returns    nothing; the content changes. SortInAscendingQ returns the sorter for chaining
	#   note       numbers come first by value, then texts by their character codes, so B sorts
	#              before a; Sort and SortUp are the same call
	#   see        SortedInAscending, SortInDescending
	def SortInAscending()
		_pSaList_ = @oList._EngineListFromContent()
		StzEngineListSortCS(_pSaList_, 1)
		This.UpdateWith(@oList._ContentFromEngineList(_pSaList_))
		StzEngineListFree(_pSaList_)

		def SortInAscendingQ()
			This.SortInAscending()
			return This

		# Sorts the held list from the smallest item to the largest, in place.
		#
		#   returns    nothing; the content changes. SortQ returns the sorter for chaining
		#   note       the same call as SortInAscending
		#   see        SortInAscending, Sorted
		def Sort()
			This.SortInAscending()

			def SortQ()
				return This.SortInAscendingQ()

		# Sorts the held list from the smallest item to the largest, in place.
		#
		#   returns    nothing; the content changes
		#   note       the same call as SortInAscending
		#   see        SortInAscending, SortDown
		def SortUp()
			This.SortInAscending()

	# Returns a copy of the list sorted from the smallest item to the largest, leaving the sorter unchanged.
	#
	#   returns    a list
	#   note       Sorted and SortedUp are the same call
	#   see        SortInAscending, SortedInDescending
	def SortedInAscending()
		_aSdaResult_ = This.Copy().SortInAscendingQ().Content()
		return _aSdaResult_

		def Sorted()
			return This.SortedInAscending()

		def SortedUp()
			return This.SortedInAscending()

	  #-----------------------------------#
	 #  SORTING THE ITEMS IN DESCENDING  #
	#-----------------------------------#

	# Sorts the held list from the largest item to the smallest, in place.
	#
	#   returns    nothing; the content changes. SortInDescendingQ returns the sorter for chaining
	#   note       SortDown is the same call
	#   see        SortedInDescending, SortInAscending
	def SortInDescending()
		_pSdList_ = @oList._EngineListFromContent()
		StzEngineListSortDescendingCS(_pSdList_, 1)
		This.UpdateWith(@oList._ContentFromEngineList(_pSdList_))
		StzEngineListFree(_pSdList_)

		def SortInDescendingQ()
			This.SortInDescending()
			return This

		# Sorts the held list from the largest item to the smallest, in place.
		#
		#   returns    nothing; the content changes
		#   note       the same call as SortInDescending
		#   see        SortInDescending, SortUp
		def SortDown()
			This.SortInDescending()

	# Returns a copy of the list sorted from the largest item to the smallest, leaving the sorter unchanged.
	#
	#   returns    a list
	#   note       SortedDown is the same call
	#   see        SortInDescending, SortedInAscending
	def SortedInDescending()
		_aSddResult_ = This.Copy().SortInDescendingQ().Content()
		return _aSddResult_

		def SortedDown()
			return This.SortedInDescending()

	  #--------------------------------------------#
	 #  SORTING BY AN EVALUATED EXPRESSION        #
	#--------------------------------------------#

	# Sorts the held list in place by a computed key, smallest key first; the expression is evaluated for each item.
	#
	#   pcExpr     the key as a text expression where @item stands for the current item, such as
	#              len(@item)
	#   returns    nothing; the content changes
	#   note       the engine understands @item, len(), lower(), upper() and abs(); len(@item) and
	#              0-len(@item) work as expected; SortBy is the same call
	#   warning    an expression that uses lower() or upper() does not order alphabetically: the
	#              list is ordered by length instead, and items of equal length keep their place, so
	#              zebra, Ox, cat with lower(@item) stays Ox, cat, zebra where a-z order is cat, Ox,
	#              zebra; the same happens in stzList.SortBy, which calls the same engine function
	#   see        SortedBy, SortByInDescending
	def SortByInAscending(pcExpr)
		_pSbaList_ = @oList._EngineListFromContent()
		if _pSbaList_ = "" return ok

		StzEngineListSortByExpr(_pSbaList_, pcExpr, 1)
		This.UpdateWith(@oList._ContentFromEngineList(_pSbaList_))
		StzEngineListFree(_pSbaList_)

		# Sorts the held list in place by a computed key, smallest key first; the expression is evaluated for each item.
		#
		#   pcExpr     the key as a text expression where @item stands for the current item, such as
		#              len(@item)
		#   returns    nothing; the content changes
		#   note       the same call as SortByInAscending
		#   warning    an expression that uses lower() or upper() does not order alphabetically: the
		#              list is ordered by length instead (see SortByInAscending)
		#   see        SortedBy, SortByInDescending
		def SortBy(pcExpr)
			This.SortByInAscending(pcExpr)

	# Sorts the held list in place by a computed key, largest key first; the expression is evaluated for each item.
	#
	#   pcExpr     the key as a text expression where @item stands for the current item, such as
	#              len(@item)
	#   returns    nothing; the content changes
	#   note       on ccc, a, bb with len(@item) it gives ccc, bb, a
	#   warning    an expression that uses lower() or upper() does not order alphabetically (see
	#              SortByInAscending)
	#   see        SortedByInDescending, SortByInAscending
	def SortByInDescending(pcExpr)
		_pSbdList_ = @oList._EngineListFromContent()
		if _pSbdList_ = "" return ok

		StzEngineListSortByExpr(_pSbdList_, pcExpr, 0)
		This.UpdateWith(@oList._ContentFromEngineList(_pSbdList_))
		StzEngineListFree(_pSbdList_)

	  #-------------------------------------#
	 #  REVERSING ITEMS ORDER IN THE LIST  #
	#-------------------------------------#

	# Reverses the order of the items of the held list, in place.
	#
	#   returns    nothing; the content changes. ReverseQ returns the sorter for chaining
	#   note       it reverses, it does not sort: [ 5, 2, 9 ] becomes [ 9, 2, 5 ]
	#   see        Reversed, SortInDescending
	def Reverse()
		_pRvList_ = @oList._EngineListFromContent()
		StzEngineListReverse(_pRvList_)
		This.UpdateWith(@oList._ContentFromEngineList(_pRvList_))
		StzEngineListFree(_pRvList_)

		def ReverseQ()
			This.Reverse()
			return This

		# Reverses the order of the items of the held list, in place.
		#
		#   returns    nothing; the content changes
		#   note       the same call as Reverse
		#   see        Reverse, Reversed
		def ReverseItems()
			This.Reverse()

	# Returns a copy of the list with its items in reverse order, leaving the sorter unchanged.
	#
	#   returns    a list
	#   note       ItemsReversed is the same call
	#   see        Reverse, SortedInDescending
	def Reversed()
		_pRdList_ = @oList._EngineListFromContent()
		StzEngineListReverse(_pRdList_)
		_aRdResult_ = @oList._ContentFromEngineList(_pRdList_)
		StzEngineListFree(_pRdList_)
		return _aRdResult_

		def ItemsReversed()
			return This.Reversed()

	  #==============================#
	 #    CLASSIFYING              #
	#==============================#

	# Groups the positions of the equal items, one [ item, positions ] pair per distinct item, in order of first appearance.
	#
	#   returns    a list of [ item, list of positions ] pairs, positions counted from 1
	#   note       a b a c b a gives [ a, [ 1, 3, 6 ] ], [ b, [ 2, 5 ] ], [ c, [ 4 ] ]; Categorize
	#              and Categorise are the same call
	#   see        Ranked, SortedBy
	def Classify()
		# Delegate to engine-backed stzListClassifier
		_oCfClassifier_ = new stzListClassifier(@oList)
		return _oCfClassifier_.Classify()

		def Categorize()
			return This.Classify()

		def Categorise()
			return This.Classify()

	  #==============================#
	 #    STABLE SORT BY KEY        #
	#==============================#

	# Returns a copy of the list ordered by a computed key, smallest key first, leaving the sorter unchanged.
	#
	#   pcExpr     the key as a text expression where @item stands for the current item, such as
	#              len(@item)
	#   returns    a list
	#   note       on pear, Apple, fig, banana with len(@item) it gives fig, pear, Apple, banana
	#   warning    an expression that uses lower() or upper() does not order alphabetically (see
	#              SortByInAscending)
	#   see        SortByInAscending, SortedByInDescending
	def SortedBy(pcExpr)
		_oCopy_ = This.Copy()
		_oCopy_.SortByInAscending(pcExpr)
		return _oCopy_.Content()

		def SortedByInAscending(pcExpr)
			return This.SortedBy(pcExpr)

	# Returns a copy of the list ordered by a computed key, largest key first, leaving the sorter unchanged.
	#
	#   pcExpr     the key as a text expression where @item stands for the current item, such as
	#              len(@item)
	#   returns    a list
	#   warning    an expression that uses lower() or upper() does not order alphabetically (see
	#              SortByInAscending)
	#   see        SortByInDescending, SortedBy
	def SortedByInDescending(pcExpr)
		_oCopy_ = This.Copy()
		_oCopy_.SortByInDescending(pcExpr)
		return _oCopy_.Content()

	  #==============================#
	 #    MIN / MAX ITEMS           #
	#==============================#

	# Returns the smallest number of the list.
	#
	#   returns    a number; an empty text for an empty list
	#   note       Minimum is the same call
	#   warning    a list of texts answers 0, because only numbers are compared
	#   see        Max, MinMax, NthSmallest
	def Min()
		if This.NumberOfItems() = 0
			return ""
		ok

		# Engine-backed O(n) min for numeric lists
		_pMnList_ = @oList._EngineListFromContent()
		_nMnResult_ = StzEngineListMin(_pMnList_)
		StzEngineListFree(_pMnList_)
		return _nMnResult_

		def Minimum()
			return This.Min()

	# Returns the largest number of the list.
	#
	#   returns    a number; an empty text for an empty list
	#   note       Maximum is the same call
	#   warning    a list of texts answers 0, because only numbers are compared
	#   see        Min, MinMax, NthLargest
	def Max()
		if This.NumberOfItems() = 0
			return ""
		ok

		# Engine-backed O(n) max for numeric lists
		_pMxList_ = @oList._EngineListFromContent()
		_nMxResult_ = StzEngineListMax(_pMxList_)
		StzEngineListFree(_pMxList_)
		return _nMxResult_

		def Maximum()
			return This.Max()

	# Returns the smallest and the largest number of the list as a pair.
	#
	#   returns    a list of two numbers [ min, max ]; [ "", "" ] for an empty list
	#   see        Min, Max
	def MinMax()
		return [ This.Min(), This.Max() ]

	  #==============================#
	 #    RANKING (ORDINAL POS)     #
	#==============================#

	# Returns the rank of each item, in the order of the list, counting from 1 for the smallest.
	#
	#   returns    a list of numbers as long as the list
	#   note       equal items share the lowest rank, so 3 1 3 2 1 gives 4 1 4 3 1; it works on
	#              texts too, and Hebrew, Arabic and emoji are ranked by character code; Ranks is
	#              the same call
	#   see        SortedInAscending, NthSmallest
	def Ranked()
		_pRkList_ = @oList._EngineListFromContent()
		_pRkRanked_ = StzEngineListRanked(_pRkList_)
		StzEngineListFree(_pRkList_)
		_aRkResult_ = @oList._ContentFromEngineList(_pRkRanked_)
		StzEngineListFree(_pRkRanked_)
		return _aRkResult_

		def Ranks()
			return This.Ranked()

	  #==============================#
	 #    NTH SMALLEST / LARGEST   #
	#==============================#

	# Returns the item that stands nth when the numbers are sorted from the smallest, counting from 1.
	#
	#   n          the rank wanted, from 1
	#   returns    a number; 0 when n is above the number of items
	#   note       n below 1 is treated as 1, so NthSmallest(0) answers the smallest like
	#              NthSmallest(1); a result of 0 may also be a real item, so check n first
	#   see        NthLargest, Min, Median
	def NthSmallest(n)
		_pNsList_ = @oList._EngineListFromContent()
		_nNsResult_ = StzEngineListNthSmallest(_pNsList_, n)
		StzEngineListFree(_pNsList_)
		return _nNsResult_

	# Returns the item that stands nth when the numbers are sorted from the largest, counting from 1.
	#
	#   n          the rank wanted, from 1
	#   returns    a number; 0 when n is above the number of items
	#   note       n below 1 is treated as 1, so NthLargest(0) answers the largest like
	#              NthLargest(1)
	#   see        NthSmallest, Max, Median
	def NthLargest(n)
		_pNlList_ = @oList._EngineListFromContent()
		_nNlResult_ = StzEngineListNthLargest(_pNlList_, n)
		StzEngineListFree(_pNlList_)
		return _nNlResult_

	  #==============================#
	 #    MEDIAN                    #
	#==============================#

	# Returns the middle number of the list once sorted; the mean of the two middle ones when the count is even.
	#
	#   returns    a number; 0 for an empty list or a list of texts
	#   note       [ 5, 2, 9, 1, 7 ] gives 5 and [ 4, 1, 3, 2 ] gives 2.50
	#   see        NthSmallest, MinMax
	def Median()
		_pMdList_ = @oList._EngineListFromContent()
		_nMdResult_ = StzEngineListMedian(_pMdList_)
		StzEngineListFree(_pMdList_)
		return _nMdResult_
