

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

	nLen = len(paList)
	n = ANumberBetween(1, nLen)
	oResult = new stzItemCS(paList[n], paList, pCaseSensitive)
	return oResult

func AnItem(paList)
	return AnItemCS(paList, _TRUE_)

#--

func SomeItems(paList)
	if isList(paList) and Q(paList).IsInOrInListNamedParam()
		paList = paList[2]
	ok

	nLen = len(paList)
	anRandom = 3NumbersBetween(1, nLen)

	aItems = Q(aList).ItemsAtPositions(anRandom)
	oResult = new stzList(aItems)
	return oResult

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
		@pCaseSensitive = _TRUE_

class stzItemCS
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

		def HowManyItmes()
			return This.NumberOfItems()

		def HowManyItem()
			return This.NumberOfItems()

		#>

	#--

	def NumberOfOccurrenceCS(pCaseSensitive)
		nResult = This.ListQ().NumberOfOccurrenceCS(This.Item(), pCaseSensitive)

		def NumberOfOccurrencesCS(pCaseSensitive)
			return This.NumberOfOccurrenceCS(pCaseSensitive)

		def HowManyOccurrenceCS(pCaseSensitive)
			return This.NumberOfOccurrenceCS(pCaseSensitive)

	def NumberOfOccurrence()
		return This.NumberOfOccurrenceCS(_TRUE_)

		def NumberOfOccurrences()
			return This.NumberOfOccurrence()

		def HowManyOccurrence()
			return This.NumberOfOccurrence()

	#--

	def PositionsCS(pCaseSensitive)
		anResult = This.ListQ().FindAllCS(This.Item())
		return anResult

	def Positions()
		return This.PositionsCS(_TRUE_)

		def Occurrences()
			return This.Positions()

	#--

	def SectionsCS(pCaseSensitive)
		aResult = This.ListQ().FindAsSectionsCS(This.Item(), pCaseSensitive)
		return aResult

		def PositionsAsSectionsCS(pCaseSensitive)
			return This.SectionsCS(pCaseSensitive)

	def Sections()
		return This.SectionsCS(:CaseSenstive = _TRUE_)

		def PositionsAsSections()
			return This.Sections()

	#--

	def OccurrencesCSXT(anOccurrences, pCaseSensitive)
		if NOT (isList(anOccurrences) and Q(anOccurrences).IsListOfNumbers())
			StzRaise("Incorrect param type! anOccurrences must be a list of numbers.")
		ok

		anResult = []
		nLen = len(anOccurrences)

		oStr = This.ListQ()

		for i = 1 to nLen
			anResult = oStr.FindNthOccurrenceCS(anOccurrences[i], This.Item(), pCaseSensitive)
		next

		return anResult

		def OccurrencesCSQ(anOccurrences, pCaseSensitive)
			return new stzOccurrencesCS(anOccurrences, This.Item(), This.List(), pCaseSensitive)

	def OccurrencesXT(anOccurrences)
		return This.OccurrencesCSXT(anOccurrences, _TRUE_)

		def OccurrencesXTQ(anOccurrences)
			return This.OccurrencesCSXTQ(anOccurrences, _TRUE_)

	#--

	def NthPositionCS(n, pCaseSensitive)
		nResult = This.ListQ().FindNthCS(n, This.Item(), pCaseSensitive)
		return nResult

	def NthPosition(n)
		return This.NthPositionCS(n, _TRUE_)

	def FirstPositionCS(pCaseSensitive)
		nResult = This.ListQ().FindFirstCS(This.Item(), pCaseSensitive)
		return nResult

	def FirstPosition()
		return This.FirstPositionCS(_TRUE_)

	def LastPositionCS(pCaseSensitive)
		nResult = This.ListQ().FindLastCS(This.Item(), pCaseSensitive)
		return nResult

	def LastPosition()
		return This.LastPositionCS(_TRUE_)

	#--

	def IsBoundedByCS(paBounds, pCaseSensitive)
		bResult = This.ListQ().ContainsItemBoundedByCS(This.Item(), paBounds, pCaseSensitive)
		return bResult

	def IsBoundedBy(paBounds)
		return This.IsBoundedByCS(paBounds, _TRUE_)

	#--

	def IsBetweenCS(pBound1, pBound2, pCaseSensitive)
		bResult = This.ListQ().ContainsItemBetweenCSQ(This.Item(), pBound1, pBound2, pCaseSensitive).Content()
		return bResult

	def IsBetween(pBound1, pBound2)
		return This.IsBetweenCS(pBound1, pBound2, _TRUE_)

	#--

	def BoundedByCS(paBounds, pCaseSensitive)
		bResult = This.ListQ().BoundItemByCSQ(This.Item(), pacBounds, pCaseSensitive).Content()
		return bResult

	def BoundedBy(paBounds)
		return This.BoundedByCS(paBounds, _TRUE_)

	#--

	def ReplacedWithCS(pOtherItem, pCaseSensitive)
		cResult = This.ListQ().ReplaceCSQ(This.Item(), pcOtherItem, pCaseSensitive).Content()
		return cResult

		def ReplacedCS(pcOtherItem, pCaseSensitive)
			return This.ReplacedWithCS(pcOtherItem, pCaseSensitive)

		def ReplacedByCS(pcOtherItem, pCaseSensitive)
			return This.ReplacedWithCS(pcOtherItem, pCaseSensitive)

	def ReplacedWith(pcOtherItem)
		return This.ReplacedWithCs(pcOtherItem, _TRUE_)

		def Replaced(pcOtherItem)
			return This.ReplacedWith(pcOtherItem)
 
		def ReplacedBy(pcOtherItem)
			return This.ReplacedWith(pcOtherItem)

	#--

	def RemovedCS(pCaseSensitive)
		cResult = This.ListQ().RemoveCSQ(This.Item(), pCaseSensitive).Content()
		return cResult

	def Removed()
		return This.RemovedCS(_TRUE_)

	#--

	def IsLowercased()
		if This.ItemQ().IsLowercased() and
		   This.ListQ().Contains(This.Item())

			return _TRUE_
		else
			return _FALSE_
		ok

		def IsInLowercase()
			return This.IsLowercased()

	def IsUppercased()
		if This.ItemQ().IsUppercased() and
		   This.ListQ().Contains(This.Item())

			return _TRUE_
		else
			return _FALSE_
		ok

		def IsInUppercase()
			return This.IsUppercased()
	#--

	def UppercasedCS(pCaseSensitive)
		cResult = This.ListQ().UppercaseItemCSQ(This.Item(), pCaseSensitive).Content()
		return cResult

	def Uppercased()
		return This.UppercasedCS(_TRUE_)

	#--

	def LowercasedCS(pCaseSensitive)
		cResult = This.ListQ().LowercaseItemCSQ(This.Item(), pCaseSensitive).Content()
		return cResult

	def Lowercased()
		return This.LowercasedCS(_TRUE_)


	#==

	def InstertedBeforeCS(p, pCaseSensitive)
		cResult = This.ListQ().InsertBeforeCSQ(p, This.Item(), pCaseSensitive)
		return cResult

		def InsertedAtCS(p, pCaseSensitive)
			return This.InstertedBeforeCS(p, pCaseSensitive)

	def InsertedBefore(p)
		return This.InsertedBeforeCS(p, _TRUE_)

		def InsertedBAt(p)
			return This.InsertedBefore(p)

	#--

	def InsertedBeforePosition(n)
		cResult = This.ListQ().InsertBeofrePositionQ(n, This.Item()).Content()
		return cResult

		def InsertedAtPosition(n)
			return This.InsertedBeforePosition(n)

	def InsertedBeforePositions(anPos)
		cResult = This.ListQ().InsertBeofrePositionsQ(anPos, This.Item()).Content()
		return cResult

		def InsertedAtPositions(anPos)
			return This.InsertedBeforePositions(anPos)

		def InsertedBeforeManyPositions(anPos)
			return This.InsertedBeforePositions(anPos)

		def InsertedAtManyPositions(anPos)
			return This.InsertedBeforePositions(anPos)

	#--

	def InsertedBeforeItemCS(pItem, pCaseSensitive)
		cResult = This.ListQ().InsertBeforeItemCSQ(pItem, This.Item(), pCaseSensitive).Content()
		return cResult

	def InsertedBeforeItem(pItem)
		return This.InsertedBeforeItemCS(pItem, _TRUE_)

	#--

	def InsertedBeforeItemsCS(pacItems, pCaseSensitive)
		cResult = This.ListQ().InsertBeforeItemsCSQ(pacItems, This.Item(), pCaseSensitive).Content()
		return cResult

		def InsertedBeforeManyItemsCS(pacItems, pCaseSensitive)
			return This.InsertedBeforeItemsCS(pacItems, pCaseSensitive)

	def InsertedBeforeItems(pacItems)
		return This.InsertedBeforeItemsCS(pacItems, _TRUE_)

		def InsertedBeforeManyItems(pacItems)
			return This.InsertedBeforeItems(pacItems)

	def InsertedBeforeW(pcCondition)
		cResult = This.ListQ().InsertBeforeWQ(pcCondition, This.Item()).Content()
		return cResult

		def InsertedAtW(pcCondition)
			return This.InsertedBeforeW(pcCondition)

	#==

	def InstertedAfterCS(p, pCaseSensitive)
		cResult = This.ListQ().InsertAfterCSQ(p, This.Item(), pCaseSensitive)
		return cResult

	def InsertedAfter(p)
		return This.InsertedAfterCS(p, _TRUE_)

	#--

	def InsertedAfterPosition(n)
		cResult = This.ListQ().InsertBeofrePositionQ(n, This.Item()).Content()
		return cResult

	def InsertedAfterPositions(anPos)
		cResult = This.ListQ().InsertBeofrePositionsQ(anPos, This.Item()).Content()
		return cResult

		def InsertedAfterManyPositions(anPos)
			return This.InsertedAfterPositions(anPos)

	#--

	def InsertedAfterItemCS(pItem, pCaseSensitive)
		cResult = This.ListQ().InsertAfterItemCSQ(pItem, This.Item(), pCaseSensitive).Content()
		return cResult

	def InsertedAfterItem(pItem)
		return This.InsertedAfterItemCS(pItem, _TRUE_)

	#--

	def InsertedAfterItemsCS(pacItems, pCaseSensitive)
		cResult = This.ListQ().InsertAfterItemsCSQ(pacItems, This.Item(), pCaseSensitive).Content()
		return cResult

		def InsertedAfterManyItemsCS(pacItems, pCaseSensitive)
			return This.InsertedAfterItemsCS(pacItems, pCaseSensitive)

	def InsertedAfterItems(pacItems)
		return This.InsertedAfterItemsCS(pacItems, _TRUE_)

		def InsertedAfterManyItems(pacItems)
			return This.InsertedAfterItems(pacItems)

	def InsertedAfterW(pcCondition)
		cResult = This.ListQ().InsertBeforeWQ(pcCondition, This.Item()).Content()
		return cResult
