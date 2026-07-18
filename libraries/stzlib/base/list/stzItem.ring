

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

class stzItem from stzItemCS
	@Item
	@aList
	@pCaseSensitive

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

class stzItemCS from stzObject
	@Item
	@aList
	@pCaseSensitive

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

	#--

	def Item()
		return @Item

		def ItemQ()
			return Q(This.Item())

		def Content()
			return This.Item()

		def Value()
			return Content()

	def List()
		return @aList

		def ListQ()
			return new stzList(This.List())

	def CaseSensitive()
		return @pCaseSensitive

	#--

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

	def NthPosition(_n_)
		return This.NthPositionCS(_n_, 1)

	def FirstPositionCS(pCaseSensitive)
		_nResult_ = This.ListQ().FindFirstCS(This.Item(), pCaseSensitive)
		return _nResult_

	def FirstPosition()
		return This.FirstPositionCS(1)

	def LastPositionCS(pCaseSensitive)
		_nResult_ = This.ListQ().FindLastCS(This.Item(), pCaseSensitive)
		return _nResult_

	def LastPosition()
		return This.LastPositionCS(1)

	#--

	def IsBoundedByCS(paBounds, pCaseSensitive)
		_bResult_ = This.ListQ().ContainsItemBoundedByCS(This.Item(), paBounds, pCaseSensitive)
		return _bResult_

	def IsBoundedBy(paBounds)
		return This.IsBoundedByCS(paBounds, 1)

	#--

	def IsBetweenCS(pBound1, pBound2, pCaseSensitive)
		_bResult_ = This.ListQ().ContainsItemBetweenCSQ(This.Item(), pBound1, pBound2, pCaseSensitive).Content()
		return _bResult_

	def IsBetween(pBound1, pBound2)
		return This.IsBetweenCS(pBound1, pBound2, 1)

	#--

	def BoundedByCS(paBounds, pCaseSensitive)
		_bResult_ = This.ListQ().BoundItemByCSQ(This.Item(), pacBounds, pCaseSensitive).Content()
		return _bResult_

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

	def Removed()
		return This.RemovedCS(1)

	#--

	def IsLowercased()
		if This.ItemQ().IsLowercased() and
		   This.ListQ().Contains(This.Item())

			return 1
		else
			return 0
		ok

		def IsInLowercase()
			return This.IsLowercased()

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

	def Uppercased()
		return This.UppercasedCS(1)

	#--

	def LowercasedCS(pCaseSensitive)
		_cResult_ = This.ListQ().LowercaseItemCSQ(This.Item(), pCaseSensitive).Content()
		return _cResult_

	def Lowercased()
		return This.LowercasedCS(1)


	#==

	def InstertedBeforeCS(p, pCaseSensitive)
		_cResult_ = This.ListQ().InsertBeforeCSQ(p, This.Item(), pCaseSensitive)
		return _cResult_

		def InsertedAtCS(p, pCaseSensitive)
			return This.InstertedBeforeCS(p, pCaseSensitive)

	def InsertedBefore(p)
		return This.InsertedBeforeCS(p, 1)

		def InsertedBAt(p)
			return This.InsertedBefore(p)

	#--

	def InsertedBeforePosition(_n_)
		_cResult_ = This.ListQ().InsertBeofrePositionQ(_n_, This.Item()).Content()
		return _cResult_

		def InsertedAtPosition(_n_)
			return This.InsertedBeforePosition(_n_)

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

	def InsertedBeforeItem(pItem)
		return This.InsertedBeforeItemCS(pItem, 1)

	#--

	def InsertedBeforeItemsCS(pacItems, pCaseSensitive)
		_cResult_ = This.ListQ().InsertBeforeItemsCSQ(pacItems, This.Item(), pCaseSensitive).Content()
		return _cResult_

		def InsertedBeforeManyItemsCS(pacItems, pCaseSensitive)
			return This.InsertedBeforeItemsCS(pacItems, pCaseSensitive)

	def InsertedBeforeItems(pacItems)
		return This.InsertedBeforeItemsCS(pacItems, 1)

		def InsertedBeforeManyItems(pacItems)
			return This.InsertedBeforeItems(pacItems)

	def InsertedBeforeW(pcCondition)
		_cResult_ = This.ListQ().InsertBeforeWQ(pcCondition, This.Item()).Content()
		return _cResult_

		def InsertedAtW(pcCondition)
			return This.InsertedBeforeW(pcCondition)

	#==

	def InstertedAfterCS(p, pCaseSensitive)
		_cResult_ = This.ListQ().InsertAfterCSQ(p, This.Item(), pCaseSensitive)
		return _cResult_

	def InsertedAfter(p)
		return This.InsertedAfterCS(p, 1)

	#--

	def InsertedAfterPosition(_n_)
		_cResult_ = This.ListQ().InsertBeofrePositionQ(_n_, This.Item()).Content()
		return _cResult_

	def InsertedAfterPositions(anPos)
		_cResult_ = This.ListQ().InsertBeofrePositionsQ(anPos, This.Item()).Content()
		return _cResult_

		def InsertedAfterManyPositions(anPos)
			return This.InsertedAfterPositions(anPos)

	#--

	def InsertedAfterItemCS(pItem, pCaseSensitive)
		_cResult_ = This.ListQ().InsertAfterItemCSQ(pItem, This.Item(), pCaseSensitive).Content()
		return _cResult_

	def InsertedAfterItem(pItem)
		return This.InsertedAfterItemCS(pItem, 1)

	#--

	def InsertedAfterItemsCS(pacItems, pCaseSensitive)
		_cResult_ = This.ListQ().InsertAfterItemsCSQ(pacItems, This.Item(), pCaseSensitive).Content()
		return _cResult_

		def InsertedAfterManyItemsCS(pacItems, pCaseSensitive)
			return This.InsertedAfterItemsCS(pacItems, pCaseSensitive)

	def InsertedAfterItems(pacItems)
		return This.InsertedAfterItemsCS(pacItems, 1)

		def InsertedAfterManyItems(pacItems)
			return This.InsertedAfterItems(pacItems)

	def InsertedAfterW(pcCondition)
		_cResult_ = This.ListQ().InsertBeforeWQ(pcCondition, This.Item()).Content()
		return _cResult_
