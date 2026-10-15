

  #-------------#
 #  FUNCTIONS  #
#-------------#

func StzItemCSQ( pItem, paList, pCaseSensitive )
	return new stzItemCS( pItem, paList, pCaseSensitive )

func StzItemQ( pItem, paList )
	return new stzItem( pItem, paList )

#== Item

# ItemQ, ItemCSQ and their aliases (Item, TheItemQ, TheItem, ItemCS, TheItemCSQ) raise error R11:
# they build a class stzSItem, which does not exist anywhere in the library, and no other class
# stands for an item without a list (stzItemCS needs the list it sits in). Use ItemInQ(item, list)
# or TheItemInQ(item, list) instead. Left as is, because the right class is a design decision.
func ItemCSQ(pItem, pCaseSensitive)

	if isList(pItem) and Q(pItem).IsPair() and
	   Q(pItem[2]).IsInOrInListNamedParam()

		return ItemInCSQ(pItem[1], pItem[2][2], pCaseSensitive)
	ok

	return new stzSItem(pItem)

	func ItemCS(pItem, pCaseSensitive)
		return ItemCSQ(pItem, pCaseSensitive)

	func TheItemCSQ(pItem, pCaseSensitive)
		return ItemCSQ(pItem, pCaseSensitive)

func ItemQ(pItem)
	return ItemCSQ(pItem, :CaseSensitive)

	func Item(pItem)
		return ItemQ(pItem)

	func TheItemQ(pItem)
		return ItemQ(pItem)

	func TheItem(pItem)
		return ItemQ(pItem)

func TheItemInCSQ( pItem, paList, pCaseSensitive )
	if isList(paList) and Q(paList).IsInOrInListNamedParam()
		paList = paList[2]
	ok

	return new stzItemCS( pItem, paList, pCaseSensitive )

	func ItemInCSQ(pItem, paList, pCaseSensitive)
		return TheItemInCSQ( pItem, paList, pCaseSensitive )

	func ItemInCS(pItem, paList, pCaseSensitive)
		return TheItemInCSQ( pItem, paList, pCaseSensitive )

	func TheItemInCS(pItem, paList, pCaseSensitive)
		return TheItemInCSQ( pItem, paList, pCaseSensitive )

func TheItemInQ(pItem, paList)
	return TheItemInCSQ(pItem, paList, :CaseSensitive)

	func ItemInQ(pItem, paList)
		return TheItemInQ(pItem, paList)

	func ItemIn(pItem, paList)
		return TheItemInQ(pItem, paList)

	func TheItemIn(pItem, paList)
		return TheItemInQ(pItem, paList)

#--

func AnItemCS(paList, pCaseSensitive)
	if isList(paList) and Q(paList).IsInOrInListNamedParam()
		paList = paList[2]
	ok

	_nLen_ = len(paList)
	_n_ = ANumberBetween(1, _nLen_)
	_oResult_ = new stzItemCS(paList[_n_], paList, pCaseSensitive)
	return _oResult_

func AnItem(paList)
	return AnItemCS(paList, 1)

#--

func SomeItems(paList)
	if isList(paList) and Q(paList).IsInOrInListNamedParam()
		paList = paList[2]
	ok

	_nLen_ = len(paList)
	_anRandom_ = 3NumbersBetween(1, _nLen_)

	_aItems_ = Q(aList).ItemsAtPositions(_anRandom_)
	_oResult_ = new stzList(_aItems_)
	return _oResult_

  #-----------#
 #  CLASSES  #
#-----------#

class stzItems from stzList

# Meant to follow an item inside a text; today only its accessors work, because its list methods need a list.
#
# It is the text twin of stzItemCS: both the item and the text it belongs to must be texts (new
# stzItem("an", "banana") or StzItemQ("an", "banana")), and the case flag is fixed at 1. It inherits
# every method of stzItemCS, but those methods build a stzList from the stored text and so raise the
# error paList must be a list; only Item, List and CaseSensitive answer. The named form [ :In = text
# ] is rejected. For an item in a text use stzString.Find; for an item in a list use stzItemCS.
#
#   receiver   o1 = new stzItem("an", "banana")
#   example    ? o1.Item()
#              #--> an
#              ? o1.List()
#              #--> banana
#              ? o1.CaseSensitive()
#              #--> 1
#   see        stzItemCS, stzString
class stzItem from stzItemCS
	@Item
	@aList
	@pCaseSensitive

	# Builds an item-in-a-text object from two texts, the item and the text it belongs to; it works for Item, List and CaseSensitive only.
	#
	#   pItem      the item, which must be a text
	#   paList     the text the item is looked for in, which must be a text too
	#   returns    nothing; the object is built
	#   note       use stzString.Find for an item in a text, or stzItemCS for an item in a list
	#   warning    the object keeps the text as its list, and every method that needs a list
	#              (Positions, NumberOfOccurrence, FirstPosition, IsLowercased...) raises an error
	#              "paList must be a list"; the named form [ :In = text ] is rejected as not being a
	#              text; the case flag is fixed at 1
	#   see        Item, Positions
	def init( pItem, paList )
		if isList(paList) and Q(paList).IsInOrInStringNamedParam()
			paList = paList[2]
		ok

		if NOT @BothAreStrings(pItem, paList)
			StzRaise("Incorrect param type! pItem and paList must both be strings.")
		ok

		@Item = pItem
		@aList = paList
		@pCaseSensitive = 1

# Follows one item inside a list: where it occurs, how often, its neighbours, and the list with it changed.
#
# Build one with TheItemInQ(item, list), ItemInCSQ(item, list, flag), StzItemCSQ(item, list, flag)
# or new stzItemCS(item, list, flag): the three arguments are the item, the list it is looked for
# in, and a case flag. Reads: Item, List, Positions, Sections, NumberOfOccurrence, NthPosition,
# FirstPosition, LastPosition, OccurrencesXT, IsBoundedBy, IsBetween, IsLowercased and
# IsUppercased (for a text item present in the list), and NumberOfItems (for an item that is itself
# a list). Positions count from 1 and an absent item gives 0 or an empty list. The case flag you
# give is read by the plain methods (1 compares with case, 0 ignores it) and the CS forms take
# their own flag, which wins. The Ed forms (ReplacedWith, Removed, Uppercased, Lowercased,
# BoundedBy, and the InsertedBefore and InsertedAfter family) return a COPY of the list and
# leave the object and the list you gave unchanged. The named form [ :In = list ] is not
# unpacked by new stzItemCS, only by the ItemInCSQ family. Text items of any script are compared
# as whole characters.
#
#   receiver   o1 = new stzItemCS("a", [ "a", "b", "A", "c", "a", "b", "b" ], 1)
#   example    ? @@( o1.Positions() )
#              #--> [ 1, 5 ]
#              ? o1.NumberOfOccurrence()
#              #--> 2
#              ? @@( o1.PositionsCS(0) )
#              #--> [ 1, 3, 5 ]
#              ? o1.NthPosition(2)
#              #--> 5
#              ? @@( o1.Removed() )
#              #--> [ "b", "A", "c", "b", "b" ]
#              ? @@( o1.InsertedBefore("X") )
#              #--> [ "X", "a", "b", "A", "c", "X", "a", "b", "b" ]
#              o2 = new stzItemCS("שלום", [ "שלום", "عالم", "😀", "שלום" ], 1)
#              ? @@( o2.Positions() )
#              #--> [ 1, 4 ]
#              o3 = new stzItemCS("😀", [ "😀", "عالم", "😀" ], 1)
#              ? o3.LastPosition()
#              #--> 3
#   see        stzList, stzItem, stzListSorter
class stzItemCS from stzObject
	@Item
	@aList
	@pCaseSensitive

	# Builds an item-in-a-list object from an item, the list it belongs to and a case flag.
	#
	#   pItem            the item to follow, of any type
	#   paList           the list the item is looked for in (the named form :In = list is accepted
	#                    but not unpacked, see the warning)
	#   pCaseSensitive   1 or 0, stored, read by the plain methods and readable with CaseSensitive
	#   returns          nothing; the object is built
	#   note             built by TheItemInQ(item, list), ItemInCSQ(item, list, flag),
	#                    StzItemCSQ(item, list, flag) or new stzItemCS(item, list, flag); TheItemInQ
	#                    stores the text casesensitive as its flag, which means with case; any flag
	#                    other than 0, or a text such as caseinsensitive, is read as with case
	#   warning          the named form [ :In = list ] given to new stzItemCS is not unpacked, the
	#                    list stays [ [ "in", list ] ] and nothing is found in it; a paList that is
	#                    not a list raises an error; the call needs all three arguments
	#   see              Item, Positions
	def init( pItem, paList, pCaseSensitive )
		if isList(paList) and Q(paList).IsInOrInListNamedParam()
			paList = paList[2]
		ok

		if NOT isList(paList)
			StzRaise("Incorrect param type! paList must be a list.")
		ok

		@Item = pItem
		@aList = paList
		@pCaseSensitive = pCaseSensitive

	# Returns the item being followed.
	#
	#   returns    the item as given, of any type
	#   note       Content and Value are the same call; ItemQ returns it as a Softanza object
	#   see        List, Positions
	#@ aka  --
	def Item()
		return @Item

		def ItemQ()
			return Q(This.Item())

		def Content()
			return This.Item()

		# Returns the item being followed.
		#
		#   returns    the item as given, of any type
		#   note       the same call as Item
		#   see        Item, List
		def Value()
			return Content()

	# Returns the list the item is looked for in.
	#
	#   returns    a list
	#   note       ListQ returns it as a stzList
	#   see        Item, CaseSensitive
	def List()
		return @aList

		def ListQ()
			return new stzList(This.List())

	# Returns the case flag given when the object was built.
	#
	#   returns    1 or 0 as given
	#   note       the plain methods read it (1 compares with case, 0 ignores it); the CS forms take
	#              their own flag instead
	#   see        init, PositionsCS
	def CaseSensitive()
		return @pCaseSensitive

	# Returns the stored case flag as 1 or 0, the way the plain methods read it.
	#
	#   returns    1 for with case, 0 for ignoring case
	#   note       a number other than 0 and any text other than caseinsensitive, ci or false mean
	#              with case, so TheItemInQ, which stores the text casesensitive, gives 1
	#   see        CaseSensitive
	def _CaseFlag()
		_vFlag_ = @pCaseSensitive
		if isList(_vFlag_)
			if ring_len(_vFlag_) = 2
				_vFlag_ = _vFlag_[2]
			ok
		ok

		if isNumber(_vFlag_)
			if _vFlag_ = 0
				return 0
			ok
			return 1
		ok

		if isString(_vFlag_)
			_cFlag_ = StzLower(_vFlag_)
			if _cFlag_ = "caseinsensitive" or _cFlag_ = "ci" or _cFlag_ = "false"
				return 0
			ok
		ok

		return 1

	# Returns how many items the followed item contains when it is itself a list.
	#
	#   returns    a number
	#   note       Size, CountItems and HowManyItems are the same call
	#   warning    an item that is a text or a number raises error R14, because the text and number
	#              objects have no method of that name; only a list item works: [ 1, 2 ] answers 2
	#   see        NumberOfOccurrence, List
	#@ aka  --
	def NumberOfItems()
		return This.ItemQ().NumberOfItems()

		#< @FunctionAlternativeForms

		def Size()
			return This.NumberOfItems()

		def HowManyItems()
			return This.NumberOfItems()

		def HowManyItem()
			return This.NumberOfItems()

		def CountItems()
			return This.NumberOfItems()

		#>

	#--

	def NumberOfOccurrenceCS(pCaseSensitive)
		# Missing `return nResult` -- every caller (including the
		# nested NumberOfOccurrence / NumberOfOccurrences /
		# HowManyOccurrence aliases) received NULL silently.
		_nResult_ = This.ListQ().NumberOfOccurrenceCS(This.Item(), pCaseSensitive)
		return _nResult_

		def NumberOfOccurrencesCS(pCaseSensitive)
			return This.NumberOfOccurrenceCS(pCaseSensitive)

		def HowManyOccurrenceCS(pCaseSensitive)
			return This.NumberOfOccurrenceCS(pCaseSensitive)

	# Returns how many times the item occurs in the list, with the case rule given to init.
	#
	#   returns    a number; 0 when the item is absent
	#   note       in a, b, A, c, a the item a gives 2; NumberOfOccurrenceCS(0) gives 3;
	#              NumberOfOccurrences and HowManyOccurrence are the same call
	#   see        Positions, NumberOfOccurrenceCS
	def NumberOfOccurrence()
		return This.NumberOfOccurrenceCS(This._CaseFlag())

		def NumberOfOccurrences()
			return This.NumberOfOccurrence()

		def HowManyOccurrence()
			return This.NumberOfOccurrence()

	#--

	def PositionsCS(pCaseSensitive)
		# FindAllCS requires 2 args (item + case-sensitive flag).
		# The original call passed only the item -> R19.
		_anResult_ = This.ListQ().FindAllCS(This.Item(), pCaseSensitive)
		return _anResult_

	# Returns the positions of the item in the list, with the case rule given to init.
	#
	#   returns    a list of numbers, positions counted from 1; empty when absent
	#   note       in a, b, A, c, a the item a gives [ 1, 5 ] and PositionsCS(0) gives [ 1, 3, 5 ];
	#              built with the flag 0, Positions gives [ 1, 3, 5 ] too; Occurrences is the same
	#              call
	#   see        NthPosition, FirstPosition, Sections
	def Positions()
		return This.PositionsCS(This._CaseFlag())

		def Occurrences()
			return This.Positions()

	#--

	def SectionsCS(pCaseSensitive)
		_anPos_ = This.PositionsCS(pCaseSensitive)
		return This._RunsOf(_anPos_)

		def PositionsAsSectionsCS(pCaseSensitive)
			return This.SectionsCS(pCaseSensitive)

	# Returns the runs of consecutive positions of the item as [ start, end ] pairs.
	#
	#   returns    a list of [ number, number ] pairs; an item alone gives [ n, n ]; [ ] when absent
	#   note       in x, a, a, a, y, a the item a gives [ [ 2, 4 ], [ 6, 6 ] ] where Positions gives
	#              [ 2, 3, 4, 6 ]; it is the opposite of stzList.AntiFindAsSections; the case rule
	#              is the one given to init, and PositionsAsSections is the same call
	#   see        Positions
	def Sections()
		return This.SectionsCS(This._CaseFlag())

		def PositionsAsSections()
			return This.Sections()

	# Groups ascending positions into runs of consecutive ones, as [ start, end ] pairs.
	#
	#   anPos      the positions, ascending
	#   returns    a list of pairs
	#   see        Sections
	def _RunsOf(anPos)
		_aRuns_ = []
		_nLenPos_ = ring_len(anPos)
		if _nLenPos_ = 0
			return _aRuns_
		ok

		_nStart_ = anPos[1]
		_nPrev_ = anPos[1]
		for _i_ = 2 to _nLenPos_
			if anPos[_i_] != (_nPrev_ + 1)
				_aRuns_ + [ _nStart_, _nPrev_ ]
				_nStart_ = anPos[_i_]
			ok
			_nPrev_ = anPos[_i_]
		next

		_aRuns_ + [ _nStart_, _nPrev_ ]
		return _aRuns_

	#--

	def OccurrencesCSXT(anOccurrences, pCaseSensitive)
		if NOT (isList(anOccurrences) and @IsListOfNumbers(anOccurrences))
			StzRaise("Incorrect param type! anOccurrences must be a list of numbers.")
		ok

		_anResult_ = []
		_nLen_ = ring_len(anOccurrences)

		_oList_ = This.ListQ()

		for i = 1 to _nLen_
			_nPos_ = _oList_.FindNthOccurrenceCS(anOccurrences[i], This.Item(), pCaseSensitive)
			if _nPos_ > 0
				_anResult_ + _nPos_
			ok
		next

		return _anResult_

		def OccurrencesCSQ(anOccurrences, pCaseSensitive)
			return new stzOccurrencesCS(anOccurrences, This.Item(), This.List(), pCaseSensitive)

	# Returns the positions of the nth occurrences asked for, one position per occurrence, in the order asked.
	#
	#   anOccurrences   which occurrences, counted from 1, as a list of numbers
	#   returns         a list of positions; an occurrence that does not exist is left out
	#   note            in a, b, A, c, a the item a with [ 2, 1 ] gives [ 5, 1 ], and with [ 1, 3 ]
	#                   gives [ 1 ]; the case rule is the one given to init; OccurrencesCSXT takes
	#                   its own flag
	#   warning         OccurrencesXTQ and OccurrencesCSQ raise an error, because the class they
	#                   build (stzOccurrencesCS) does not exist; a list that is not made of numbers
	#                   raises an error
	#   see             Positions, NthPosition
	def OccurrencesXT(anOccurrences)
		return This.OccurrencesCSXT(anOccurrences, This._CaseFlag())

		def OccurrencesXTQ(anOccurrences)
			return This.OccurrencesCSXTQ(anOccurrences, This._CaseFlag())

	#--

	def NthPositionCS(_n_, pCaseSensitive)
		_nResult_ = This.ListQ().FindNthCS(_n_, This.Item(), pCaseSensitive)
		return _nResult_

	# Returns the position of the nth occurrence of the item, counting occurrences from 1.
	#
	#   _n_        which occurrence, from 1
	#   returns    a number; 0 when there is no nth occurrence, and for n = 0
	#   note       in a, b, A, c, a the item a gives 1 for n = 1, 5 for n = 2 and 0 for n = 3; the
	#              CS form takes the case flag, and the plain form reads the one given to init
	#   see        FirstPosition, LastPosition, Positions
	def NthPosition(_n_)
		return This.NthPositionCS(_n_, This._CaseFlag())

	def FirstPositionCS(pCaseSensitive)
		_nResult_ = This.ListQ().FindFirstCS(This.Item(), pCaseSensitive)
		return _nResult_

	# Returns the position of the first occurrence of the item in the list.
	#
	#   returns    a number; 0 when the item is absent
	#   note       the FirstPositionCS form takes the case flag, and the plain form reads the one
	#              given to init
	#   see        LastPosition, NthPosition
	def FirstPosition()
		return This.FirstPositionCS(This._CaseFlag())

	def LastPositionCS(pCaseSensitive)
		_nResult_ = This.ListQ().FindLastCS(This.Item(), pCaseSensitive)
		return _nResult_

	# Returns the position of the last occurrence of the item in the list.
	#
	#   returns    a number; 0 when the item is absent
	#   note       the LastPositionCS form takes the case flag, and the plain form reads the one
	#              given to init
	#   see        FirstPosition, NthPosition
	def LastPosition()
		return This.LastPositionCS(This._CaseFlag())

	#--

	def IsBoundedByCS(paBounds, pCaseSensitive)
		This._CheckPair(paBounds)

		_anPos_ = This.PositionsCS(pCaseSensitive)
		_anLeft_ = This.ListQ().FindAllCS(paBounds[1], pCaseSensitive)
		_anRight_ = This.ListQ().FindAllCS(paBounds[2], pCaseSensitive)

		_nLenPos_ = ring_len(_anPos_)
		for _i_ = 1 to _nLenPos_
			if ring_find(_anLeft_, (_anPos_[_i_] - 1)) > 0 and
			   ring_find(_anRight_, (_anPos_[_i_] + 1)) > 0
				return 1
			ok
		next

		return 0

	# Tells whether an occurrence of the item sits right between the two items of a pair.
	#
	#   paBounds   the pair, [ item before, item after ], each right next to the occurrence
	#   returns    1 or 0
	#   note       in <, a, >, x, a, y the item a is bounded by [ <, > ] and by [ x, y ] but not by
	#              [ <, y ]; an item at the start or the end of the list has only one neighbour and
	#              so is bounded by nothing; the case rule is the one given to init, and
	#              IsBoundedByCS takes its own flag
	#   warning    a paBounds that is not a list of two items raises an error
	#   see        IsBetween, BoundedBy, Positions
	def IsBoundedBy(paBounds)
		return This.IsBoundedByCS(paBounds, This._CaseFlag())

	#--

	def IsBetweenCS(pBound1, pBound2, pCaseSensitive)
		_anPos_ = This.PositionsCS(pCaseSensitive)
		_anFirst_ = This.ListQ().FindAllCS(pBound1, pCaseSensitive)
		_anLast_ = This.ListQ().FindAllCS(pBound2, pCaseSensitive)

		if ring_len(_anPos_) = 0 or ring_len(_anFirst_) = 0 or ring_len(_anLast_) = 0
			return 0
		ok

		_nAfter_ = _anFirst_[1]
		_nBefore_ = _anLast_[ ring_len(_anLast_) ]

		_nLenPos_ = ring_len(_anPos_)
		for _i_ = 1 to _nLenPos_
			if _anPos_[_i_] > _nAfter_ and _anPos_[_i_] < _nBefore_
				return 1
			ok
		next

		return 0

	# Tells whether an occurrence of the item lies after one given item and before another.
	#
	#   pBound1    the item that must come earlier in the list
	#   pBound2    the item that must come later in the list
	#   returns    1 or 0
	#   note       the bounds need not touch the item: in <, a, x, y the item a is between < and y,
	#              where IsBoundedBy needs them right next to it; the case rule is the one given to
	#              init, and IsBetweenCS takes its own flag
	#   see        IsBoundedBy
	def IsBetween(pBound1, pBound2)
		return This.IsBetweenCS(pBound1, pBound2, This._CaseFlag())

	# Raises an error unless the argument is a list of two items.
	#
	#   paBounds   the pair to check
	#   returns    nothing
	#   see        IsBoundedBy
	def _CheckPair(paBounds)
		if NOT isList(paBounds)
			StzRaise("Incorrect param type! paBounds must be a list of two items.")
		ok
		if ring_len(paBounds) != 2
			StzRaise("Incorrect param type! paBounds must be a list of two items.")
		ok

	#--

	def BoundedByCS(paBounds, pCaseSensitive)
		This._CheckPair(paBounds)

		_anPos_ = This.PositionsCS(pCaseSensitive)
		_aResult_ = This._Around(_anPos_, [ paBounds[1] ], [ paBounds[2] ])
		return _aResult_

	# Returns a copy of the list with a pair of bounding items put around each occurrence of the item.
	#
	#   paBounds   the pair, [ item before, item after ]
	#   returns    a list, longer by two items per occurrence; the object and its list are unchanged
	#   note       in a, b, c, b the item b with [ [, ] ] gives a, [, b, ], c, [, b, ]; the case rule
	#              is the one given to init, and BoundedByCS takes its own flag; it is the opposite
	#              of stzString.BoundedBy, which finds what stands between bounds
	#   warning    a paBounds that is not a list of two items raises an error
	#   see        IsBoundedBy
	def BoundedBy(paBounds)
		return This.BoundedByCS(paBounds, This._CaseFlag())

	# Builds a copy of the list with items put before and after each of the given positions.
	#
	#   anPos      the positions to surround, ascending and without repeats
	#   aBefore    the items to put right before each position, in order
	#   aAfter     the items to put right after each position, in order
	#   returns    a list; the object's own list is not touched
	#   see        BoundedBy, InsertedBeforeItems
	def _Around(anPos, aBefore, aAfter)
		_aResult_ = []
		_nLenList_ = ring_len(@aList)
		_nLenPos_ = ring_len(anPos)
		_nLenBefore_ = ring_len(aBefore)
		_nLenAfter_ = ring_len(aAfter)
		_nNext_ = 1

		for _i_ = 1 to _nLenList_
			_bHit_ = 0
			if _nNext_ <= _nLenPos_
				if anPos[_nNext_] = _i_
					_bHit_ = 1
					_nNext_++
				ok
			ok

			if _bHit_ = 1
				for _j_ = 1 to _nLenBefore_
					_aResult_ + aBefore[_j_]
				next
			ok

			_aResult_ + @aList[_i_]

			if _bHit_ = 1
				for _j_ = 1 to _nLenAfter_
					_aResult_ + aAfter[_j_]
				next
			ok
		next

		return _aResult_

	#--

	def ReplacedWithCS(pOtherItem, pCaseSensitive)
		_oList_ = This.ListQ()
		_oList_.ReplaceCS(This.Item(), pOtherItem, pCaseSensitive)
		return _oList_.Content()

		def ReplacedCS(pcOtherItem, pCaseSensitive)
			return This.ReplacedWithCS(pcOtherItem, pCaseSensitive)

		def ReplacedByCS(pcOtherItem, pCaseSensitive)
			return This.ReplacedWithCS(pcOtherItem, pCaseSensitive)

	# Returns a copy of the list with every occurrence of the item replaced by another item.
	#
	#   pcOtherItem   the item that takes its place, of any type
	#   returns       a list; the object and its list are unchanged
	#   note          in a, b, A, c, a the item a replaced by Z gives Z, b, A, c, Z; the case rule is
	#                 the one given to init, and ReplacedWithCS takes its own flag; Replaced and
	#                 ReplacedBy are the same call; an absent item gives a copy of the list
	#   see           Positions, Removed
	def ReplacedWith(pcOtherItem)
		return This.ReplacedWithCS(pcOtherItem, This._CaseFlag())

		def Replaced(pcOtherItem)
			return This.ReplacedWith(pcOtherItem)

		def ReplacedBy(pcOtherItem)
			return This.ReplacedWith(pcOtherItem)

	#--

	def RemovedCS(pCaseSensitive)
		_oList_ = This.ListQ()
		_oList_.RemoveAllCS(This.Item(), pCaseSensitive)
		return _oList_.Content()

	# Returns a copy of the list without any occurrence of the item.
	#
	#   returns    a list; the object and its list are unchanged
	#   note       in a, b, A, c, a the item a gives b, A, c; the case rule is the one given to
	#              init, and RemovedCS takes its own flag; an absent item gives a copy of the list
	#   see        Positions, ReplacedWith
	def Removed()
		return This.RemovedCS(This._CaseFlag())

	# TRUE if the item is a lower-case text and the list contains it.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       IsInLowercase is the same call; an item absent from the list gives FALSE; a
	#              Hebrew word is not cased, so it gives FALSE here and in IsUppercased
	#   warning    a number or a list as the item raises error R14, because only a text can be asked
	#   see        IsUppercased, Positions
	#@ aka  --
	def IsLowercased()
		if This.ItemQ().IsLowercased() and
		   This.ListQ().Contains(This.Item())

			return 1
		else
			return 0
		ok

		def IsInLowercase()
			return This.IsLowercased()

	# TRUE if the item is an upper-case text and the list contains it.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       IsInUppercase is the same call; an item absent from the list gives FALSE
	#   warning    a number or a list as the item raises error R14, because only a text can be asked
	#   see        IsLowercased, Positions
	def IsUppercased()
		if This.ItemQ().IsUppercased() and
		   This.ListQ().Contains(This.Item())

			return 1
		else
			return 0
		ok

		def IsInUppercase()
			return This.IsUppercased()
	#--

	def UppercasedCS(pCaseSensitive)
		return This._CaseChanged(pCaseSensitive, 1)

	# Returns a copy of the list with each occurrence of the item written in upper case.
	#
	#   returns    a list; the object and its list are unchanged
	#   note       in ab, Ab, AB, ab the item ab gives AB, Ab, AB, AB; only the occurrences change,
	#              not the other items; an item that is not a text, and a text with no case such
	#              as Hebrew, give a copy of the list; the case rule is the one given to init, and
	#              UppercasedCS takes its own flag
	#   see        Lowercased, IsUppercased
	def Uppercased()
		return This.UppercasedCS(This._CaseFlag())

	#--

	def LowercasedCS(pCaseSensitive)
		return This._CaseChanged(pCaseSensitive, 0)

	# Returns a copy of the list with each occurrence of the item written in lower case.
	#
	#   returns    a list; the object and its list are unchanged
	#   note       in ab, Ab, AB, ab the item Ab gives ab, ab, AB, ab; only the occurrences change,
	#              not the other items; an item that is not a text gives a copy of the list; the
	#              case rule is the one given to init, and LowercasedCS takes its own flag
	#   see        Uppercased, IsLowercased
	def Lowercased()
		return This.LowercasedCS(This._CaseFlag())

	# Builds a copy of the list with each occurrence of a text item changed to upper or lower case.
	#
	#   pCaseSensitive   1 to find the occurrences with case, 0 to ignore it
	#   bUpper           1 for upper case, 0 for lower case
	#   returns          a list; the object's own list is not touched
	#   see              Uppercased, Lowercased
	def _CaseChanged(pCaseSensitive, bUpper)
		_aResult_ = @aList
		if NOT isString(@Item)
			return _aResult_
		ok

		_anPos_ = This.PositionsCS(pCaseSensitive)
		_nLenPos_ = ring_len(_anPos_)
		for _i_ = 1 to _nLenPos_
			_p_ = _anPos_[_i_]
			if isString(_aResult_[_p_])
				if bUpper = 1
					_aResult_[_p_] = StzUpper(_aResult_[_p_])
				else
					_aResult_[_p_] = StzLower(_aResult_[_p_])
				ok
			ok
		next

		return _aResult_

	#--

	# Returns a copy of the list with a new item put right before each occurrence of the item.
	#
	#   p                the item to insert, of any type; a list goes in as one item
	#   pCaseSensitive   1 to find the occurrences with case, 0 to ignore it
	#   returns          a list, longer by one item per occurrence; the object and its list are
	#                    unchanged
	#   note             InstertedBeforeCS, the old spelling with the typo, and InsertedAtCS are the
	#                    same call; InsertedBefore reads the case flag given to init instead
	#   see              InsertedBefore, InsertedAfterCS
	#@ aka  --
	def InsertedBeforeCS(p, pCaseSensitive)
		_oList_ = This.ListQ()
		_oList_.InsertBeforeManyPositions(This.PositionsCS(pCaseSensitive), p)
		return _oList_.Content()

		def InstertedBeforeCS(p, pCaseSensitive)
			return This.InsertedBeforeCS(p, pCaseSensitive)

		def InsertedAtCS(p, pCaseSensitive)
			return This.InsertedBeforeCS(p, pCaseSensitive)

	# Returns a copy of the list with a new item put right before each occurrence of the item.
	#
	#   p          the item to insert, of any type; a list goes in as one item
	#   returns    a list, longer by one item per occurrence; the object and its list are unchanged
	#   note       in a, b, a, c the item a with X gives X, a, b, X, a, c; the case rule is the one
	#              given to init, and InsertedBeforeCS takes its own flag; InsertedBAt is the same
	#              call
	#   see        InsertedAfter, InsertedBeforeItem
	def InsertedBefore(p)
		return This.InsertedBeforeCS(p, This._CaseFlag())

		def InsertedBAt(p)
			return This.InsertedBefore(p)

	# Returns a copy of the list with the followed item put before one given position.
	#
	#   _n_        the position to insert before
	#   returns    a list; the object and its list are unchanged
	#   note       in x, y, z the item a before position 3 gives x, y, a, z; a position of 0 or one
	#              past the end of the list gives a copy of the list, except that the position just
	#              past the end appends; InsertedAtPosition is the same call
	#   see        InsertedAfterPosition, InsertedBeforePositions
	#@ aka  --
	def InsertedBeforePosition(_n_)
		_oList_ = This.ListQ()
		# stzList.InsertBeforePosition raises R14 for a position two or more past the end,
		# so only the positions it handles are forwarded.
		if isNumber(_n_)
			if _n_ >= 1 and _n_ <= (ring_len(@aList) + 1)
				_oList_.InsertBeforePosition(_n_, This.Item())
			ok
		ok
		return _oList_.Content()

		def InsertedAtPosition(_n_)
			return This.InsertedBeforePosition(_n_)

	# Returns a copy of the list with the followed item put before each of several positions.
	#
	#   anPos      the positions to insert before, in any order
	#   returns    a list, longer by one item per valid position; the object and its list are
	#              unchanged
	#   note       in x, y, z the item a before [ 1, 3 ] gives a, x, y, a, z; a position outside the
	#              list is skipped; the aliases InsertedAtPositions, InsertedBeforeManyPositions and
	#              InsertedAtManyPositions are the same call
	#   warning    an anPos that is not a list raises an error
	#   see        InsertedAfterPositions, InsertedBeforePosition
	def InsertedBeforePositions(anPos)
		This._CheckPositions(anPos)
		_oList_ = This.ListQ()
		_oList_.InsertBeforeManyPositions(anPos, This.Item())
		return _oList_.Content()

		def InsertedAtPositions(anPos)
			return This.InsertedBeforePositions(anPos)

		def InsertedBeforeManyPositions(anPos)
			return This.InsertedBeforePositions(anPos)

		def InsertedAtManyPositions(anPos)
			return This.InsertedBeforePositions(anPos)

	# Raises an error unless the argument is a list.
	#
	#   anPos      the positions to check
	#   returns    nothing
	#   see        InsertedBeforePositions
	def _CheckPositions(anPos)
		if NOT isList(anPos)
			StzRaise("Incorrect param type! anPos must be a list of positions.")
		ok

	#--

	def InsertedBeforeItemCS(pItem, pCaseSensitive)
		return This.InsertedBeforeCS(pItem, pCaseSensitive)

	# Returns a copy of the list with another item put right before each occurrence of the item.
	#
	#   pItem      the item to insert
	#   returns    a list, longer by one item per occurrence; the object and its list are unchanged
	#   note       the same call as InsertedBefore; the case rule is the one given to init, and
	#              InsertedBeforeItemCS takes its own flag
	#   see        InsertedAfterItem, InsertedBeforeItems
	def InsertedBeforeItem(pItem)
		return This.InsertedBeforeItemCS(pItem, This._CaseFlag())

	#--

	def InsertedBeforeItemsCS(pacItems, pCaseSensitive)
		This._CheckItems(pacItems)
		_anPos_ = This.PositionsCS(pCaseSensitive)
		_aResult_ = This._Around(_anPos_, pacItems, [])
		return _aResult_

		def InsertedBeforeManyItemsCS(pacItems, pCaseSensitive)
			return This.InsertedBeforeItemsCS(pacItems, pCaseSensitive)

	# Returns a copy of the list with several items put, in order, right before each occurrence of the item.
	#
	#   pacItems   the items to insert, as a list
	#   returns    a list; the object and its list are unchanged
	#   note       in a, b, a the item a with X, Y gives X, Y, a, b, X, Y, a; an empty list inserts
	#              nothing; the case rule is the one given to init, and InsertedBeforeItemsCS takes
	#              its own flag; InsertedBeforeManyItems is the same call
	#   warning    a pacItems that is not a list raises an error
	#   see        InsertedAfterItems, InsertedBeforeItem
	def InsertedBeforeItems(pacItems)
		return This.InsertedBeforeItemsCS(pacItems, This._CaseFlag())

		def InsertedBeforeManyItems(pacItems)
			return This.InsertedBeforeItems(pacItems)

	# Raises an error unless the argument is a list of items.
	#
	#   pacItems   the items to check
	#   returns    nothing
	#   see        InsertedBeforeItems
	def _CheckItems(pacItems)
		if NOT isList(pacItems)
			StzRaise("Incorrect param type! pacItems must be a list of items.")
		ok

	# Returns a copy of the list with the followed item put right before each item that meets a condition.
	#
	#   pcCondition   the W condition as text in braces, for example { @item = "b" }
	#   returns       a list; the object and its list are unchanged
	#   note          the item put in is the followed one, not one of the matches; InsertedAtW is the
	#                 same call
	#   see           InsertedAfterW, InsertedBefore
	def InsertedBeforeW(pcCondition)
		_oList_ = This.ListQ()
		_oList_.InsertBeforeW(pcCondition, This.Item())
		return _oList_.Content()

		def InsertedAtW(pcCondition)
			return This.InsertedBeforeW(pcCondition)

	# Returns a copy of the list with a new item put right after each occurrence of the item.
	#
	#   p                the item to insert, of any type; a list goes in as one item
	#   pCaseSensitive   1 to find the occurrences with case, 0 to ignore it
	#   returns          a list, longer by one item per occurrence, even when the last item of the
	#                    list is an occurrence; the object and its list are unchanged
	#   note             InstertedAfterCS, the old spelling with the typo, is the same call;
	#                    InsertedAfter reads the case flag given to init instead
	#   see              InsertedAfter, InsertedBeforeCS
	#@ aka  --
	def InsertedAfterCS(p, pCaseSensitive)
		_oList_ = This.ListQ()
		_oList_.InsertAfterManyPositions(This.PositionsCS(pCaseSensitive), p)
		return _oList_.Content()

		def InstertedAfterCS(p, pCaseSensitive)
			return This.InsertedAfterCS(p, pCaseSensitive)

	# Returns a copy of the list with a new item put right after each occurrence of the item.
	#
	#   p          the item to insert, of any type; a list goes in as one item
	#   returns    a list, longer by one item per occurrence, the last one included; the object and
	#              its list are unchanged
	#   note       in a, b, a, c the item a with X gives a, X, b, a, X, c; the case rule is the one
	#              given to init, and InsertedAfterCS takes its own flag
	#   see        InsertedBefore, InsertedAfterItem
	def InsertedAfter(p)
		return This.InsertedAfterCS(p, This._CaseFlag())

	# Returns a copy of the list with the followed item put after one given position.
	#
	#   _n_        the position to insert after
	#   returns    a list; the object and its list are unchanged
	#   note       in x, y, z the item a after position 1 gives x, a, y, z, and after position 3, the
	#              last, gives x, y, z, a; a position of 0 or one beyond the list gives a copy of
	#              the list
	#   see        InsertedBeforePosition, InsertedAfterPositions
	#@ aka  --
	def InsertedAfterPosition(_n_)
		_oList_ = This.ListQ()
		# only the positions stzList.InsertAfterPosition handles are forwarded (see the Before form).
		if isNumber(_n_)
			if _n_ >= 1 and _n_ <= ring_len(@aList)
				_oList_.InsertAfterPosition(_n_, This.Item())
			ok
		ok
		return _oList_.Content()

	# Returns a copy of the list with the followed item put after each of several positions.
	#
	#   anPos      the positions to insert after, in any order
	#   returns    a list, longer by one item per valid position; the object and its list are
	#              unchanged
	#   note       in x, y, z the item a after [ 1, 3 ] gives x, a, y, z, a, the last position
	#              included; a position outside the list is skipped; InsertedAfterManyPositions is
	#              the same call
	#   warning    an anPos that is not a list raises an error
	#   see        InsertedBeforePositions, InsertedAfterPosition
	def InsertedAfterPositions(anPos)
		This._CheckPositions(anPos)
		_oList_ = This.ListQ()
		_oList_.InsertAfterManyPositions(anPos, This.Item())
		return _oList_.Content()

		def InsertedAfterManyPositions(anPos)
			return This.InsertedAfterPositions(anPos)

	#--

	def InsertedAfterItemCS(pItem, pCaseSensitive)
		return This.InsertedAfterCS(pItem, pCaseSensitive)

	# Returns a copy of the list with another item put right after each occurrence of the item.
	#
	#   pItem      the item to insert
	#   returns    a list, longer by one item per occurrence; the object and its list are unchanged
	#   note       the same call as InsertedAfter; the case rule is the one given to init, and
	#              InsertedAfterItemCS takes its own flag
	#   see        InsertedBeforeItem, InsertedAfterItems
	def InsertedAfterItem(pItem)
		return This.InsertedAfterItemCS(pItem, This._CaseFlag())

	#--

	def InsertedAfterItemsCS(pacItems, pCaseSensitive)
		This._CheckItems(pacItems)
		_anPos_ = This.PositionsCS(pCaseSensitive)
		_aResult_ = This._Around(_anPos_, [], pacItems)
		return _aResult_

		def InsertedAfterManyItemsCS(pacItems, pCaseSensitive)
			return This.InsertedAfterItemsCS(pacItems, pCaseSensitive)

	# Returns a copy of the list with several items put, in order, right after each occurrence of the item.
	#
	#   pacItems   the items to insert, as a list
	#   returns    a list; the object and its list are unchanged
	#   note       in a, b, a the item a with X, Y gives a, X, Y, b, a, X, Y; an empty list inserts
	#              nothing; the case rule is the one given to init, and InsertedAfterItemsCS takes
	#              its own flag; InsertedAfterManyItems is the same call
	#   warning    a pacItems that is not a list raises an error
	#   see        InsertedBeforeItems, InsertedAfterItem
	def InsertedAfterItems(pacItems)
		return This.InsertedAfterItemsCS(pacItems, This._CaseFlag())

		def InsertedAfterManyItems(pacItems)
			return This.InsertedAfterItems(pacItems)

	# Returns a copy of the list with the followed item put right after each item that meets a condition.
	#
	#   pcCondition   the W condition as text in braces, for example { @item = "b" }
	#   returns       a list; the object and its list are unchanged
	#   note          the item put in is the followed one, not one of the matches; it used to insert
	#                 before the matches
	#   see           InsertedBeforeW, InsertedAfter
	def InsertedAfterW(pcCondition)
		_oList_ = This.ListQ()
		_oList_.InsertAfterW(pcCondition, This.Item())
		return _oList_.Content()
