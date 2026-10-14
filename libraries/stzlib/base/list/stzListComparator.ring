#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTCOMPARATOR          #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List comparator subclass -- equality,      #
#                  diff, common items, union, intersection.    #
#                  For aliases, use stzListComparatorXT.        #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

# Compares a list with another one: equality, subset and superset, common items, union, differences, prefix and suffix, and containment.
#
# It is the comparing helper of stzList, which builds one over itself for its ContainsAllOfTheseCS
# and ContainsOneOfTheseCS methods; build one with new stzListComparator when you only need to
# compare. It never changes the list, so a stzList passed in stays intact. Every test has a CS form
# taking 1 to compare with case and 0 to ignore it, and the plain form compares with case.
# IsEqualTo, IsNotEqualTo and IsPermutationOf compare sets: they ignore order and repeats, so [ 1,
# 1, 2 ] equals [ 1, 2, 2 ]; IsStrictlyEqualTo is the one that checks positions. Union, CommonItems
# and IsSubsetOf work on sets too. Found today: IsReverseOf raises error R3 (the function that
# reverses the other list does not exist), and IsSortedLike answers TRUE for any two lists of the
# same size. Hebrew, Arabic and emoji items compare like any other text.
#
#   receiver   o1 = new stzListComparator([ 1, 2, 3, 4 ])
#   example    ? o1.IsStrictlyEqualTo([ 4, 3, 2, 1 ])
#              #--> 0
#              ? o1.IsEqualTo([ 4, 3, 2, 1 ])
#              #--> 1
#              ? @@( o1.CommonItems([ 3, 4, 5, 6 ]) )
#              #--> [ 3, 4 ]
#              ? @@( o1.SymmetricDifference([ 3, 4, 5, 6 ]) )
#              #--> [ 1, 2, 5, 6 ]
#              ? o1.IsSubsetOf([ 1, 2, 3, 4, 5 ])
#              #--> 1
#              ? o1.StartsWith([ 1, 2 ])
#              #--> 1
#              o2 = new stzListComparator([ "a", "B", "c" ])
#              ? o2.IsEqualToCS([ "A", "b", "C" ], 0)
#              #--> 1
#              o3 = new stzListComparator([ "שלום", "😀" ])
#              ? o3.IsEqualTo([ "😀", "שלום" ])
#              #--> 1
#   see        stzList, stzListMerger, stzListDuplicates
class stzListComparator from stzObject

	@oList

	  #===================#
	 #   INITIALIZATION  #
	#===================#

	# Builds a comparator over a list, given as a list or as a stzList object.
	#
	#   pListOrObj   the list to compare from, or a stzList whose content is copied, any other value
	#                raises an error
	#   returns      nothing; the object is built
	#   note         the comparator never changes the list or the stzList you passed in
	#   see          Content, IsEqualTo
	def init(pListOrObj)
		if isList(pListOrObj)
			@oList = new stzList(pListOrObj)
		but isObject(pListOrObj)
			@oList = pListOrObj
		else
			StzRaise("Can't create stzListComparator! Parameter must be a list or stzList object.")
		ok

	  #===============================#
	 #     CONTENT ACCESS            #
	#===============================#

	# Returns the list the comparator holds.
	#
	#   returns    a list
	#   see        NumberOfItems, IsEqualTo
	def Content()
		return @oList.Content()

	# Returns how many items the list holds.
	#
	#   returns    a number
	#   see        Content, IsSameSizeAs
	def NumberOfItems()
		return @oList.NumberOfItems()

	# TRUE if the list holds no item.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   see        NumberOfItems, Content
	def IsEmpty()
		return @oList.IsEmpty()

	  #===============================#
	 #     COMPARISON METHODS        #
	#===============================#

	def IsEqualToCS(paOtherList, pCaseSensitive)
		# Set-based equality: same items regardless of order
		if NOT isList(paOtherList)
			return 0
		ok
		if This.NumberOfItems() != len(paOtherList)
			return 0
		ok
		# Mutual subset check via engine
		_pCmpA_ = @oList._EngineListFromContent()
		_oCmpTemp_ = new stzList(paOtherList)
		_pCmpB_ = _oCmpTemp_._EngineListFromContent()
		_nCmpAsubB_ = StzEngineListIsSubsetCS(_pCmpA_, _pCmpB_, pCaseSensitive)
		_nCmpBsubA_ = StzEngineListIsSubsetCS(_pCmpB_, _pCmpA_, pCaseSensitive)
		StzEngineListFree(_pCmpB_)
		StzEngineListFree(_pCmpA_)
		return _nCmpAsubB_ and _nCmpBsubA_

	# TRUE if another list has the same size and the same items, in any order.
	#
	#   paOtherList   the list to compare with
	#   returns       TRUE or FALSE, as 1 or 0
	#   note          case counts: IsEqualToCS(paOtherList, 0) ignores it; use IsStrictlyEqualTo
	#                 when the order matters
	#   warning       it ignores order and repeats: [ 1, 2, 3, 4 ] equals [ 4, 3, 2, 1 ], and [ 1,
	#                 1, 2 ] equals [ 1, 2, 2 ], since only the size and the set of items are
	#                 compared; a value that is not a list answers FALSE
	#   see           IsStrictlyEqualTo, IsPermutationOf, IsNotEqualTo
	def IsEqualTo(paOtherList)
		return This.IsEqualToCS(paOtherList, 1)

	def CommonItemsCS(paOtherList, pCaseSensitive)
		pA = @oList._EngineListFromContent()
		_oTemp_ = new stzList(paOtherList)
		pB = _oTemp_._EngineListFromContent()
		pResult = StzEngineListIntersectionCS(pA, pB, pCaseSensitive)
		_aResult_ = StzEngineListContentToRingList(pResult)
		StzEngineListFree(pResult)
		StzEngineListFree(pB)
		StzEngineListFree(pA)
		return _aResult_

	# Returns the items found in both lists, without repeats.
	#
	#   paOtherList   the list to match against
	#   returns       a list
	#   note          case counts: CommonItemsCS(paOtherList, 0) ignores it, and then the items keep
	#                 the spelling of the held list
	#   see           Union, Difference, SymmetricDifference
	def CommonItems(paOtherList)
		return This.CommonItemsCS(paOtherList, 1)

	def UnionCS(paOtherList, pCaseSensitive)
		pA = @oList._EngineListFromContent()
		_oTemp_ = new stzList(paOtherList)
		pB = _oTemp_._EngineListFromContent()
		pResult = StzEngineListUnionCS(pA, pB, pCaseSensitive)
		_aResult_ = StzEngineListContentToRingList(pResult)
		StzEngineListFree(pResult)
		StzEngineListFree(pB)
		StzEngineListFree(pA)
		return _aResult_

	# Returns the items of the list followed by those of another list not already present, without repeats.
	#
	#   paOtherList   the list whose new items are added
	#   returns       a list
	#   note          case counts: UnionCS(paOtherList, 0) ignores it
	#   see           CommonItems, SymmetricDifference
	def Union(paOtherList)
		return This.UnionCS(paOtherList, 1)

	def DifferenceCS(paOtherList, pCaseSensitive)
		pA = @oList._EngineListFromContent()
		_oTemp_ = new stzList(paOtherList)
		pB = _oTemp_._EngineListFromContent()
		pResult = StzEngineListDifferenceCS(pA, pB, pCaseSensitive)
		_aResult_ = StzEngineListContentToRingList(pResult)
		StzEngineListFree(pResult)
		StzEngineListFree(pB)
		StzEngineListFree(pA)
		return _aResult_

	# Returns the items of the list that are not in another list.
	#
	#   paOtherList   the list whose items are taken away
	#   returns       a list
	#   note          case counts: DifferenceCS(paOtherList, 0) ignores it; the items that stay keep
	#                 their repeats; ItemsNotIn is the same call
	#   see           CommonItems, SymmetricDifference
	def Difference(paOtherList)
		return This.DifferenceCS(paOtherList, 1)

	def IsReverseOfCS(paOtherList, pCaseSensitive)
		return This.IsEqualToCS(ListReversed(paOtherList), pCaseSensitive)

	# TRUE if the list is another list read backwards.
	#
	#   paOtherList   the list to compare with, read in reverse
	#   returns       TRUE or FALSE, as 1 or 0
	#   note          the function it calls to reverse the other list does not exist
	#   warning       raises error R3 Calling Function without definition: listreversed today, with
	#                 the case flag or without (tried on [ 1, 2, 3, 4 ] against [ 4, 3, 2, 1 ] and
	#                 against itself, and on texts)
	#   see           IsStrictlyEqualTo, IsEqualTo
	def IsReverseOf(paOtherList)
		return This.IsReverseOfCS(paOtherList, 1)

	  #======================================================#
	 #   NOT EQUAL                                          #
	#======================================================#

	def IsNotEqualToCS(paOtherList, pCaseSensitive)
		return NOT This.IsEqualToCS(paOtherList, pCaseSensitive)

	# TRUE if another list differs in size or in its set of items.
	#
	#   paOtherList   the list to compare with
	#   returns       TRUE or FALSE, as 1 or 0
	#   note          it is the opposite of IsEqualTo, so it also ignores order and repeats
	#   see           IsEqualTo, IsStrictlyEqualTo
	def IsNotEqualTo(paOtherList)
		return NOT This.IsEqualTo(paOtherList)

	  #======================================================#
	 #   STRICT EQUALITY (SAME CONTENT + SAME ORDER)        #
	#======================================================#

	def IsStrictlyEqualToCS(paOtherList, pCaseSensitive)
		# Strictly equal = same items at same positions (order matters)
		if NOT isList(paOtherList)
			return 0
		ok
		_pSeA_ = @oList._EngineListFromContent()
		_pSeB_ = StzEngineMarshalList(paOtherList)
		_nSeResult_ = StzEngineListEqualsCS(_pSeA_, _pSeB_, pCaseSensitive)
		StzEngineListFree(_pSeB_)
		StzEngineListFree(_pSeA_)
		return _nSeResult_

		def IsIdenticalToCS(paOtherList, pCaseSensitive)
			return This.IsStrictlyEqualToCS(paOtherList, pCaseSensitive)

		def IsEqualToCSXT(paOtherList, pCaseSensitive)
			return This.IsStrictlyEqualToCS(paOtherList, pCaseSensitive)

	# TRUE if another list holds the same items at the same positions.
	#
	#   paOtherList   the list to compare with
	#   returns       TRUE or FALSE, as 1 or 0
	#   note          case counts: IsStrictlyEqualToCS(paOtherList, 0) ignores it; IsIdenticalTo and
	#                 IsEqualToXT are the same call
	#   see           IsEqualTo, IsReverseOf
	def IsStrictlyEqualTo(paOtherList)
		return This.IsStrictlyEqualToCS(paOtherList, 1)

		def IsIdenticalTo(paOtherList)
			return This.IsStrictlyEqualTo(paOtherList)

		def IsEqualToXT(paOtherList)
			return This.IsStrictlyEqualTo(paOtherList)

	  #======================================================#
	 #   SYMMETRIC DIFFERENCE                               #
	#======================================================#

	def SymmetricDifferenceCS(paOtherList, pCaseSensitive)
		pA = @oList._EngineListFromContent()
		_oTemp_ = new stzList(paOtherList)
		pB = _oTemp_._EngineListFromContent()
		pDiff1 = StzEngineListDifferenceCS(pA, pB, pCaseSensitive)
		pDiff2 = StzEngineListDifferenceCS(pB, pA, pCaseSensitive)
		_aDiff1_ = StzEngineListContentToRingList(pDiff1)
		_aDiff2_ = StzEngineListContentToRingList(pDiff2)
		StzEngineListFree(pDiff2)
		StzEngineListFree(pDiff1)
		StzEngineListFree(pB)
		StzEngineListFree(pA)
		_aResult_ = _aDiff1_
		_nLen_ = len(_aDiff2_)
		for i = 1 to _nLen_
			_aResult_ + _aDiff2_[i]
		next
		return _aResult_

	# Returns the items found in only one of the two lists.
	#
	#   paOtherList   the list to compare with
	#   returns       a list
	#   note          the held list's own items come first, then the other list's; items keep their
	#                 repeats, so [ 1, 1, 2 ] against [ 2, 3, 3 ] gives [ 1, 1, 3, 3 ]; case counts
	#                 unless SymmetricDifferenceCS(paOtherList, 0) is used
	#   see           Difference, Union, CommonItems
	def SymmetricDifference(paOtherList)
		return This.SymmetricDifferenceCS(paOtherList, 1)

	  #======================================================#
	 #   IS SUBSET / SUPERSET                               #
	#======================================================#

	def IsSubsetOfCS(paOtherList, pCaseSensitive)
		pA = @oList._EngineListFromContent()
		_oTemp_ = new stzList(paOtherList)
		pB = _oTemp_._EngineListFromContent()
		_nResult_ = StzEngineListIsSubsetCS(pA, pB, pCaseSensitive)
		StzEngineListFree(pB)
		StzEngineListFree(pA)
		return _nResult_

	# TRUE if every item of the list is also in another list.
	#
	#   paOtherList   the list that may contain them all
	#   returns       TRUE or FALSE, as 1 or 0
	#   note          the order and the repeats do not matter; case counts unless
	#                 IsSubsetOfCS(paOtherList, 0) is used
	#   see           IsSupersetOf, Contains
	def IsSubsetOf(paOtherList)
		return This.IsSubsetOfCS(paOtherList, 1)

	def IsSupersetOfCS(paOtherList, pCaseSensitive)
		_oTemp_ = new stzList(paOtherList)
		pA = _oTemp_._EngineListFromContent()
		pB = @oList._EngineListFromContent()
		_nResult_ = StzEngineListIsSubsetCS(pA, pB, pCaseSensitive)
		StzEngineListFree(pB)
		StzEngineListFree(pA)
		return _nResult_

	# TRUE if every item of another list is also in this list.
	#
	#   paOtherList   the list whose items must all be present
	#   returns       TRUE or FALSE, as 1 or 0
	#   note          the order and the repeats do not matter; case counts unless
	#                 IsSupersetOfCS(paOtherList, 0) is used
	#   see           IsSubsetOf, ContainsAllOfThese
	def IsSupersetOf(paOtherList)
		return This.IsSupersetOfCS(paOtherList, 1)

	  #======================================================#
	 #   CONTAINS                                           #
	#======================================================#

	def ContainsCS(pItem, pCaseSensitive)
		return @oList.ContainsCS(pItem, pCaseSensitive)

	# TRUE if the list holds an item.
	#
	#   pItem      the item to look for
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       case counts: ContainsCS(pItem, 0) finds b in a B c
	#   see        ContainsAllOfThese, ContainsOneOfThese
	def Contains(pItem)
		return This.ContainsCS(pItem, 1)

	def ContainsAllOfTheseCS(paItems, pCaseSensitive)
		_nCatLen_ = len(paItems)
		for _iCat_ = 1 to _nCatLen_
			if NOT This.ContainsCS(paItems[_iCat_], pCaseSensitive)
				return 0
			ok
		next
		return 1

	# TRUE if the list holds every item of a given list.
	#
	#   paItems    the items that must all be present
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       case counts unless ContainsAllOfTheseCS(paItems, 0) is used; an empty list of
	#              items answers TRUE
	#   see        ContainsOneOfThese, IsSupersetOf
	def ContainsAllOfThese(paItems)
		return This.ContainsAllOfTheseCS(paItems, 1)

	def ContainsOneOfTheseCS(paItems, pCaseSensitive)
		_nCotLen_ = len(paItems)
		for _iCot_ = 1 to _nCotLen_
			if This.ContainsCS(paItems[_iCot_], pCaseSensitive)
				return 1
			ok
		next
		return 0

	# TRUE if the list holds at least one item of a given list.
	#
	#   paItems    the items to look for
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       case counts unless ContainsOneOfTheseCS(paItems, 0) is used; an empty list of
	#              items answers FALSE
	#   see        ContainsAllOfThese, Contains
	def ContainsOneOfThese(paItems)
		return This.ContainsOneOfTheseCS(paItems, 1)

	  #======================================================#
	 #   IS SAME SIZE AS                                    #
	#======================================================#

	# TRUE if another list holds as many items as this one.
	#
	#   paOtherList   the list whose size is compared
	#   returns       TRUE or FALSE, as 1 or 0
	#   note          HasSameLengthAs is the same call
	#   see           IsEqualTo, NumberOfItems
	def IsSameSizeAs(paOtherList)
		return This.NumberOfItems() = len(paOtherList)

		def HasSameLengthAs(paOtherList)
			return This.IsSameSizeAs(paOtherList)

	  #======================================================#
	 #   IS SORTED LIKE                                     #
	#======================================================#

	# Returns TRUE for any two lists of the same size, whatever their order, though it is meant to compare their orderings.
	#
	#   paOtherList   the list whose ordering is compared
	#   returns       TRUE or FALSE, as 1 or 0
	#   note          the test inside it, a find that is compared with greater-or-equal-zero, is
	#                 true whatever the items are
	#   warning       it answers TRUE for any two lists of the same size, whatever their order: [ 1,
	#                 2, 3, 4 ] is "sorted like" [ 10, 30, 20, 40 ] and [ 40, 30, 20, 10 ], and [ b,
	#                 a, c ] like [ x, y, z ]; only a different size answers FALSE
	#   see           IsStrictlyEqualTo, IsSameSizeAs
	def IsSortedLike(paOtherList)
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)
		_nLen2_ = len(paOtherList)
		if _nLen_ != _nLen2_
			return 0
		ok
		if _nLen_ < 2
			return 1
		ok
		for i = 1 to _nLen_ - 1
			_bThisAsc_ = BothAreEqual(_aContent_[i], _aContent_[i+1]) or StzFindFirst(""+_aContent_[i+1], [""+_aContent_[i]]) >= 0
			_bOtherAsc_ = BothAreEqual(paOtherList[i], paOtherList[i+1]) or StzFindFirst(""+paOtherList[i+1], [""+paOtherList[i]]) >= 0
			if _bThisAsc_ != _bOtherAsc_
				return 0
			ok
		next
		return 1

	  #======================================================#
	 #   STARTS WITH / ENDS WITH                            #
	#======================================================#

	def StartsWithCS(paItems, pCaseSensitive)
		_pSwList_ = @oList._EngineListFromContent()
		_pSwPrefix_ = StzEngineMarshalList(paItems)
		_nSwResult_ = StzEngineListStartsWithListCS(_pSwList_, _pSwPrefix_, pCaseSensitive)
		StzEngineListFree(_pSwPrefix_)
		StzEngineListFree(_pSwList_)
		return _nSwResult_

	# TRUE if the list begins with the given items, in that order.
	#
	#   paItems    the items the list must begin with
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       case counts unless StartsWithCS(paItems, 0) is used; an empty list of items
	#              answers TRUE
	#   see        EndsWith, IsStrictlyEqualTo
	def StartsWith(paItems)
		return This.StartsWithCS(paItems, 1)

	def EndsWithCS(paItems, pCaseSensitive)
		_pEwList_ = @oList._EngineListFromContent()
		_pEwSuffix_ = StzEngineMarshalList(paItems)
		_nEwResult_ = StzEngineListEndsWithListCS(_pEwList_, _pEwSuffix_, pCaseSensitive)
		StzEngineListFree(_pEwSuffix_)
		StzEngineListFree(_pEwList_)
		return _nEwResult_

	# TRUE if the list ends with the given items, in that order.
	#
	#   paItems    the items the list must end with
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       case counts unless EndsWithCS(paItems, 0) is used
	#   see        StartsWith, IsStrictlyEqualTo
	def EndsWith(paItems)
		return This.EndsWithCS(paItems, 1)

	  #======================================================#
	 #   ITEMS NOT IN OTHER                                 #
	#======================================================#

	def ItemsNotInCS(paOtherList, pCaseSensitive)
		return This.DifferenceCS(paOtherList, pCaseSensitive)

	def ItemsNotIn(paOtherList)
		return This.Difference(paOtherList)

	  #======================================================#
	 #   IS PERMUTATION OF                                  #
	#======================================================#

	def IsPermutationOfCS(paOtherList, pCaseSensitive)
		if This.NumberOfItems() != len(paOtherList)
			return 0
		ok
		pA = @oList._EngineListFromContent()
		_oTemp_ = new stzList(paOtherList)
		pB = _oTemp_._EngineListFromContent()
		_nAsubB_ = StzEngineListIsSubsetCS(pA, pB, pCaseSensitive)
		_nBsubA_ = StzEngineListIsSubsetCS(pB, pA, pCaseSensitive)
		StzEngineListFree(pB)
		StzEngineListFree(pA)
		return _nAsubB_ and _nBsubA_

	# TRUE if another list has the same size and the same set of items, in any order.
	#
	#   paOtherList   the list to compare with
	#   returns       TRUE or FALSE, as 1 or 0
	#   note          case counts unless IsPermutationOfCS(paOtherList, 0) is used
	#   warning       it ignores repeats, so [ 1, 1, 2 ] is called a permutation of [ 1, 2, 2 ],
	#                 which is not one; it is the same test as IsEqualTo
	#   see           IsEqualTo, IsStrictlyEqualTo
	def IsPermutationOf(paOtherList)
		return This.IsPermutationOfCS(paOtherList, 1)
