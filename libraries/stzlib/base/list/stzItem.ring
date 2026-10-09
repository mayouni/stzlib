

  #-------------#
 #  FUNCTIONS  #
#-------------#

func StzItemCSQ( pItem, paList, pCaseSensitive )
	return new stzItemCS( pItem, paList, pCaseSensitive )

func StzItemQ( pItem, paList )
	return new stzItem( pItem, paList )

#== Item

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

# Follows one item inside a list: where it occurs, how often, and its first, last and nth position.
#
# Build one with TheItemInQ(item, list), ItemInCSQ(item, list, flag), StzItemCSQ(item, list, flag)
# or new stzItemCS(item, list, flag): the three arguments are the item, the list it is looked for
# in, and a case flag. The reads that work today are Item, List, Positions, NumberOfOccurrence,
# NthPosition, FirstPosition and LastPosition, IsLowercased and IsUppercased (for a text item
# present in the list), and NumberOfItems (for an item that is itself a list). Positions count from
# 1 and an absent item gives 0 or an empty list. The case flag you give is only stored: the plain
# methods always compare with case, and only the CS forms (PositionsCS(0), NumberOfOccurrenceCS(0))
# take the flag; the named form [ :In = list ] is not unpacked. Most of the remaining methods are
# broken today: Sections, IsBoundedBy, IsBetween, BoundedBy, ReplacedWith, Removed, Uppercased,
# Lowercased and the whole InsertedBefore and InsertedAfter family raise error R14, because they
# call stzList methods that do not exist (or misspelled names), and each says so in its own entry.
# Text items of any script are compared as whole characters.
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
	#   pCaseSensitive   1 or 0, stored and readable with CaseSensitive
	#   returns          nothing; the object is built
	#   note             built by TheItemInQ(item, list), ItemInCSQ(item, list, flag),
	#                    StzItemCSQ(item, list, flag) or new stzItemCS(item, list, flag); TheItemInQ
	#                    stores the text casesensitive as its flag
	#   warning          the flag is only stored: Positions, NumberOfOccurrence and the other plain
	#                    methods ignore it and compare with case, so only the CS forms
	#                    (PositionsCS(0)) ignore case; the named form [ :In = list ] is not
	#                    unpacked, the list stays [ [ "in", list ] ] and nothing is found in it; a
	#                    paList that is not a list raises an error; the call needs all three
	#                    arguments
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
	#   note       the plain methods do not read it
	#   see        init, PositionsCS
	def CaseSensitive()
		return @pCaseSensitive

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

	# Returns how many times the item occurs in the list, comparing with case.
	#
	#   returns    a number; 0 when the item is absent
	#   note       in a, b, A, c, a the item a gives 2; NumberOfOccurrenceCS(0) gives 3;
	#              NumberOfOccurrences and HowManyOccurrence are the same call
	#   see        Positions, NumberOfOccurrenceCS
	def NumberOfOccurrence()
		return This.NumberOfOccurrenceCS(1)

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

	# Returns the positions of the item in the list, comparing with case.
	#
	#   returns    a list of numbers, positions counted from 1; empty when absent
	#   note       in a, b, A, c, a the item a gives [ 1, 5 ] and PositionsCS(0) gives [ 1, 3, 5 ];
	#              Occurrences is the same call
	#   warning    the case flag given to init is not used: build with 0 and Positions still
	#              compares with case, while PositionsCS(0) ignores case
	#   see        NthPosition, FirstPosition, Sections
	def Positions()
		return This.PositionsCS(1)

		def Occurrences()
			return This.Positions()

	#--

	def SectionsCS(pCaseSensitive)
		_aResult_ = This.ListQ().FindAsSectionsCS(This.Item(), pCaseSensitive)
		return _aResult_

		def PositionsAsSectionsCS(pCaseSensitive)
			return This.SectionsCS(pCaseSensitive)

	# Raises error R14 today instead of answering the positions of the item as runs of consecutive positions.
	#
	#   returns    nothing; it raises
	#   note       use Positions to find the item
	#   warning    it calls FindAsSectionsCS on the list, a method stzList does not have, so every
	#              call raises R14, whatever the list
	#   see        Positions
	def Sections()
		return This.SectionsCS(:CaseSenstive = 1)

		def PositionsAsSections()
			return This.Sections()

	#--

	def OccurrencesCSXT(anOccurrences, pCaseSensitive)
		if NOT (isList(anOccurrences) and @IsListOfNumbers(anOccurrences))
			StzRaise("Incorrect param type! anOccurrences must be a list of numbers.")
		ok

		_anResult_ = []
		_nLen_ = len(anOccurrences)

		_oStr_ = This.ListQ()

		for i = 1 to _nLen_
			_anResult_ = _oStr_.FindNthOccurrenceCS(anOccurrences[i], This.Item(), pCaseSensitive)
		next

		return _anResult_

		def OccurrencesCSQ(anOccurrences, pCaseSensitive)
			return new stzOccurrencesCS(anOccurrences, This.Item(), This.List(), pCaseSensitive)

	def OccurrencesXT(anOccurrences)
		return This.OccurrencesCSXT(anOccurrences, 1)

		def OccurrencesXTQ(anOccurrences)
			return This.OccurrencesCSXTQ(anOccurrences, 1)

	#--

	def NthPositionCS(_n_, pCaseSensitive)
		_nResult_ = This.ListQ().FindNthCS(_n_, This.Item(), pCaseSensitive)
		return _nResult_

	# Returns the position of the nth occurrence of the item, counting occurrences from 1.
	#
	#   _n_        which occurrence, from 1
	#   returns    a number; 0 when there is no nth occurrence, and for n = 0
	#   note       in a, b, A, c, a the item a gives 1 for n = 1, 5 for n = 2 and 0 for n = 3; the
	#              CS form takes the case flag
	#   see        FirstPosition, LastPosition, Positions
	def NthPosition(_n_)
		return This.NthPositionCS(_n_, 1)

	def FirstPositionCS(pCaseSensitive)
		_nResult_ = This.ListQ().FindFirstCS(This.Item(), pCaseSensitive)
		return _nResult_

	# Returns the position of the first occurrence of the item in the list.
	#
	#   returns    a number; 0 when the item is absent
	#   note       the FirstPositionCS form takes the case flag
	#   see        LastPosition, NthPosition
	def FirstPosition()
		return This.FirstPositionCS(1)

	def LastPositionCS(pCaseSensitive)
		_nResult_ = This.ListQ().FindLastCS(This.Item(), pCaseSensitive)
		return _nResult_

	# Returns the position of the last occurrence of the item in the list.
	#
	#   returns    a number; 0 when the item is absent
	#   note       the LastPositionCS form takes the case flag
	#   see        FirstPosition, NthPosition
	def LastPosition()
		return This.LastPositionCS(1)

	#--

	def IsBoundedByCS(paBounds, pCaseSensitive)
		_bResult_ = This.ListQ().ContainsItemBoundedByCS(This.Item(), paBounds, pCaseSensitive)
		return _bResult_

	# Raises error R14 today instead of telling whether the item stands between two bounding items.
	#
	#   paBounds   the pair of bounding items
	#   returns    nothing; it raises
	#   note       use Positions to find the item and read its neighbours
	#   warning    it calls ContainsItemBoundedByCS on the list, a method stzList does not have, so
	#              every call raises R14
	#   see        IsBetween, BoundedBy
	def IsBoundedBy(paBounds)
		return This.IsBoundedByCS(paBounds, 1)

	#--

	def IsBetweenCS(pBound1, pBound2, pCaseSensitive)
		_bResult_ = This.ListQ().ContainsItemBetweenCSQ(This.Item(), pBound1, pBound2, pCaseSensitive).Content()
		return _bResult_

	# Raises error R14 today instead of telling whether the item stands between two given items.
	#
	#   pBound1    the item before
	#   pBound2    the item after
	#   returns    nothing; it raises
	#   warning    it calls ContainsItemBetweenCSQ on the list, a method stzList does not have, so
	#              every call raises R14
	#   see        IsBoundedBy
	def IsBetween(pBound1, pBound2)
		return This.IsBetweenCS(pBound1, pBound2, 1)

	#--

	def BoundedByCS(paBounds, pCaseSensitive)
		_bResult_ = This.ListQ().BoundItemByCSQ(This.Item(), pacBounds, pCaseSensitive).Content()
		return _bResult_

	# Raises error R14 today instead of putting two bounding items around the item in the list.
	#
	#   paBounds   the pair of bounding items
	#   returns    nothing; it raises
	#   warning    it calls BoundItemByCSQ on the list, a method stzList does not have, so every
	#              call raises R14; its body also reads a name pacBounds that is not its parameter
	#   see        IsBoundedBy
	def BoundedBy(paBounds)
		return This.BoundedByCS(paBounds, 1)

	#--

	def ReplacedWithCS(pOtherItem, pCaseSensitive)
		_cResult_ = This.ListQ().ReplaceCSQ(This.Item(), pcOtherItem, pCaseSensitive).Content()
		return _cResult_

		def ReplacedCS(pcOtherItem, pCaseSensitive)
			return This.ReplacedWithCS(pcOtherItem, pCaseSensitive)

		def ReplacedByCS(pcOtherItem, pCaseSensitive)
			return This.ReplacedWithCS(pcOtherItem, pCaseSensitive)

	# Raises error R14 today instead of returning the list with the item replaced by another.
	#
	#   pcOtherItem   the item that would take its place
	#   returns       nothing; it raises
	#   note          use Positions and replace through stzList
	#   warning       it calls ReplaceCSQ on the list, a method stzList does not have, so every call
	#                 raises R14; Replaced and ReplacedBy are the same call
	#   see           Positions
	def ReplacedWith(pcOtherItem)
		return This.ReplacedWithCs(pcOtherItem, 1)

		def Replaced(pcOtherItem)
			return This.ReplacedWith(pcOtherItem)
 
		def ReplacedBy(pcOtherItem)
			return This.ReplacedWith(pcOtherItem)

	#--

	def RemovedCS(pCaseSensitive)
		_cResult_ = This.ListQ().RemoveCSQ(This.Item(), pCaseSensitive).Content()
		return _cResult_

	# Raises error R14 today instead of returning the list without the item.
	#
	#   returns    nothing; it raises
	#   warning    it calls RemoveCSQ on the list, a method stzList does not have, so every call
	#              raises R14
	#   see        Positions
	def Removed()
		return This.RemovedCS(1)

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
		_cResult_ = This.ListQ().UppercaseItemCSQ(This.Item(), pCaseSensitive).Content()
		return _cResult_

	# Raises error R14 today instead of returning the list with the item in upper case.
	#
	#   returns    nothing; it raises
	#   warning    it calls UppercaseItemCSQ on the list, a method stzList does not have, so every
	#              call raises R14
	#   see        Lowercased, IsUppercased
	def Uppercased()
		return This.UppercasedCS(1)

	#--

	def LowercasedCS(pCaseSensitive)
		_cResult_ = This.ListQ().LowercaseItemCSQ(This.Item(), pCaseSensitive).Content()
		return _cResult_

	# Raises error R14 today instead of returning the list with the item in lower case.
	#
	#   returns    nothing; it raises
	#   warning    it calls LowercaseItemCSQ on the list, a method stzList does not have, so every
	#              call raises R14
	#   see        Uppercased, IsLowercased
	def Lowercased()
		return This.LowercasedCS(1)


	# Raises error R14 today instead of returning the list with a new item put before the item.
	#
	#   p                the item to insert
	#   pCaseSensitive   1 to compare with case, 0 to ignore it
	#   returns          nothing; it raises
	#   warning          it calls InsertBeforeCSQ on the list, a method stzList does not have, so
	#                    every call raises R14; the method name is also misspelled: Instertedbefore
	#   see              InsertedBefore
	#@ aka  ==
	def InstertedBeforeCS(p, pCaseSensitive)
		_cResult_ = This.ListQ().InsertBeforeCSQ(p, This.Item(), pCaseSensitive)
		return _cResult_

		def InsertedAtCS(p, pCaseSensitive)
			return This.InstertedBeforeCS(p, pCaseSensitive)

	# Raises error R14 today instead of returning the list with a new item put before the item.
	#
	#   p          the item to insert
	#   returns    nothing; it raises
	#   warning    it calls InsertedBeforeCS, a name that does not exist because the real method is
	#              spelled InstertedBeforeCS, so every call raises R14; InsertedBAt is the same call
	#   see        InsertedAfter
	def InsertedBefore(p)
		return This.InsertedBeforeCS(p, 1)

		def InsertedBAt(p)
			return This.InsertedBefore(p)

	# Raises error R14 today instead of returning the list with the item put before a position.
	#
	#   _n_        the position to insert before
	#   returns    nothing; it raises
	#   warning    it calls InsertBeofrePositionQ, a misspelled name that does not exist, so every
	#              call raises R14; InsertedAtPosition is the same call
	#   see        InsertedAfterPosition
	#@ aka  --
	def InsertedBeforePosition(_n_)
		_cResult_ = This.ListQ().InsertBeofrePositionQ(_n_, This.Item()).Content()
		return _cResult_

		def InsertedAtPosition(_n_)
			return This.InsertedBeforePosition(_n_)

	# Raises error R14 today instead of returning the list with the item put before several positions.
	#
	#   anPos      the positions to insert before
	#   returns    nothing; it raises
	#   warning    it calls InsertBeofrePositionsQ, a misspelled name that does not exist, so every
	#              call raises R14
	#   see        InsertedAfterPositions
	def InsertedBeforePositions(anPos)
		_cResult_ = This.ListQ().InsertBeofrePositionsQ(anPos, This.Item()).Content()
		return _cResult_

		def InsertedAtPositions(anPos)
			return This.InsertedBeforePositions(anPos)

		def InsertedBeforeManyPositions(anPos)
			return This.InsertedBeforePositions(anPos)

		def InsertedAtManyPositions(anPos)
			return This.InsertedBeforePositions(anPos)

	#--

	def InsertedBeforeItemCS(pItem, pCaseSensitive)
		_cResult_ = This.ListQ().InsertBeforeItemCSQ(pItem, This.Item(), pCaseSensitive).Content()
		return _cResult_

	# Raises error R14 today instead of returning the list with another item put before the item.
	#
	#   pItem      the item to insert
	#   returns    nothing; it raises
	#   warning    it calls InsertBeforeItemCSQ on the list, a method stzList does not have, so
	#              every call raises R14
	#   see        InsertedAfterItem
	def InsertedBeforeItem(pItem)
		return This.InsertedBeforeItemCS(pItem, 1)

	#--

	def InsertedBeforeItemsCS(pacItems, pCaseSensitive)
		_cResult_ = This.ListQ().InsertBeforeItemsCSQ(pacItems, This.Item(), pCaseSensitive).Content()
		return _cResult_

		def InsertedBeforeManyItemsCS(pacItems, pCaseSensitive)
			return This.InsertedBeforeItemsCS(pacItems, pCaseSensitive)

	# Raises error R14 today instead of returning the list with several items put before the item.
	#
	#   pacItems   the items to insert
	#   returns    nothing; it raises
	#   warning    it calls InsertBeforeItemsCSQ on the list, a method stzList does not have, so
	#              every call raises R14
	#   see        InsertedAfterItems
	def InsertedBeforeItems(pacItems)
		return This.InsertedBeforeItemsCS(pacItems, 1)

		def InsertedBeforeManyItems(pacItems)
			return This.InsertedBeforeItems(pacItems)

	def InsertedBeforeW(pcCondition)
		_cResult_ = This.ListQ().InsertBeforeWQ(pcCondition, This.Item()).Content()
		return _cResult_

		def InsertedAtW(pcCondition)
			return This.InsertedBeforeW(pcCondition)

	# Raises error R14 today instead of returning the list with a new item put after the item.
	#
	#   p                the item to insert
	#   pCaseSensitive   1 to compare with case, 0 to ignore it
	#   returns          nothing; it raises
	#   warning          it calls InsertAfterCSQ on the list, a method stzList does not have, so
	#                    every call raises R14; the method name is also misspelled: Instertedafter
	#   see              InsertedAfter
	#@ aka  ==
	def InstertedAfterCS(p, pCaseSensitive)
		_cResult_ = This.ListQ().InsertAfterCSQ(p, This.Item(), pCaseSensitive)
		return _cResult_

	# Raises error R14 today instead of returning the list with a new item put after the item.
	#
	#   p          the item to insert
	#   returns    nothing; it raises
	#   warning    it calls InsertedAfterCS, a name that does not exist because the real method is
	#              spelled InstertedAfterCS, so every call raises R14
	#   see        InsertedBefore
	def InsertedAfter(p)
		return This.InsertedAfterCS(p, 1)

	# Raises error R14 today instead of returning the list with the item put after a position.
	#
	#   _n_        the position to insert after
	#   returns    nothing; it raises
	#   warning    it calls the misspelled InsertBeofrePositionQ, which does not exist, so every
	#              call raises R14; its body is the one of the Before form, so it would insert
	#              before
	#   see        InsertedBeforePosition
	#@ aka  --
	def InsertedAfterPosition(_n_)
		_cResult_ = This.ListQ().InsertBeofrePositionQ(_n_, This.Item()).Content()
		return _cResult_

	# Raises error R14 today instead of returning the list with the item put after several positions.
	#
	#   anPos      the positions to insert after
	#   returns    nothing; it raises
	#   warning    it calls the misspelled InsertBeofrePositionsQ, which does not exist, so every
	#              call raises R14; its body is the one of the Before form, so it would insert
	#              before
	#   see        InsertedBeforePositions
	def InsertedAfterPositions(anPos)
		_cResult_ = This.ListQ().InsertBeofrePositionsQ(anPos, This.Item()).Content()
		return _cResult_

		def InsertedAfterManyPositions(anPos)
			return This.InsertedAfterPositions(anPos)

	#--

	def InsertedAfterItemCS(pItem, pCaseSensitive)
		_cResult_ = This.ListQ().InsertAfterItemCSQ(pItem, This.Item(), pCaseSensitive).Content()
		return _cResult_

	# Raises error R14 today instead of returning the list with another item put after the item.
	#
	#   pItem      the item to insert
	#   returns    nothing; it raises
	#   warning    it calls InsertAfterItemCSQ on the list, a method stzList does not have, so every
	#              call raises R14
	#   see        InsertedBeforeItem
	def InsertedAfterItem(pItem)
		return This.InsertedAfterItemCS(pItem, 1)

	#--

	def InsertedAfterItemsCS(pacItems, pCaseSensitive)
		_cResult_ = This.ListQ().InsertAfterItemsCSQ(pacItems, This.Item(), pCaseSensitive).Content()
		return _cResult_

		def InsertedAfterManyItemsCS(pacItems, pCaseSensitive)
			return This.InsertedAfterItemsCS(pacItems, pCaseSensitive)

	# Raises error R14 today instead of returning the list with several items put after the item.
	#
	#   pacItems   the items to insert
	#   returns    nothing; it raises
	#   warning    it calls InsertAfterItemsCSQ on the list, a method stzList does not have, so
	#              every call raises R14
	#   see        InsertedBeforeItems
	def InsertedAfterItems(pacItems)
		return This.InsertedAfterItemsCS(pacItems, 1)

		def InsertedAfterManyItems(pacItems)
			return This.InsertedAfterItems(pacItems)

	def InsertedAfterW(pcCondition)
		_cResult_ = This.ListQ().InsertBeforeWQ(pcCondition, This.Item()).Content()
		return _cResult_
