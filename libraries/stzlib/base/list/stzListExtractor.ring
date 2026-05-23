#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTEXTRACTOR           #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List extractor subclass -- extract (remove #
#                  and return) items by value, position, or   #
#                  condition. For aliases, use                 #
#                  stzListExtractorXT.                          #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzListExtractor

	@oList

	  #===================#
	 #   INITIALIZATION  #
	#===================#

	def init(pListOrObj)
		if isList(pListOrObj)
			@oList = new stzList(pListOrObj)
		but isObject(pListOrObj)
			@oList = pListOrObj
		else
			StzRaise("Can't create stzListExtractor! Parameter must be a list or stzList object.")
		ok

	  #===============================#
	 #     CONTENT ACCESS            #
	#===============================#

	def Content()
		return @oList.Content()

	def List()
		return @oList.List()

	def NumberOfItems()
		return @oList.NumberOfItems()

	def IsEmpty()
		return @oList.IsEmpty()

	def ExtractCS(pItem, pCaseSensitive)
		if NOT @oList.ContainsCS(pItem, pCaseSensitive)
			StzRaise("Can't extract the item! It does not exist in the list.")
		ok
		@oList.RemoveCS(pItem, pCaseSensitive)
		return pItem

	def Extract(pItem)
		return This.ExtractCS(pItem, 1)

	def ExtractManyCS(paItems, pCaseSensitive)
		anPos = @oList.FindManyCS(paItems, pCaseSensitive)
		@oList.RemoveItemsAtPositions(anPos)
		return paItems

	def ExtractMany(paItems)
		return This.ExtractManyCS(paItems, 1)

	def ExtractAll()
		aResult = This.Content()
		@oList.RemoveAllItems()
		return aResult

	def ExtractNth(n)
		pItem = @oList.NthItem(n)
		ring_remove(This.List(), n)
		return pItem

	def ExtractFirst()
		return This.ExtractNth(1)

	def ExtractLast()
		return This.ExtractNth(This.NumberOfItems())

	def ExtractSection(n1, n2)
		aResult = @oList.Section(n1, n2)
		@oList.RemoveSection(n1, n2)
		return aResult

	def ExtractRange(pnStart, pnRange)
		aResult = @oList.Range(pnStart, pnRange)
		@oList.RemoveRange(pnStart, pnRange)
		return aResult

	def ExtractW(pcCondition)
		anPos = @oList.FindW(pcCondition)
		aResult = @oList.ItemsAtPositions(anPos)
		@oList.RemoveItemsAtPositions(anPos)
		return aResult

	  #======================================================#
	 #   EXTRACT NTH OCCURRENCE                             #
	#======================================================#

	def ExtractNthOccurrenceCS(n, pItem, pCaseSensitive)
		nPos = @oList.FindNthCS(n, pItem, pCaseSensitive)
		if nPos = 0
			return NULL
		ok
		return This.ExtractNth(nPos)

	def ExtractNthOccurrence(n, pItem)
		return This.ExtractNthOccurrenceCS(n, pItem, 1)

	  #======================================================#
	 #   EXTRACT FIRST / LAST OCCURRENCE                    #
	#======================================================#

	def ExtractFirstOccurrenceCS(pItem, pCaseSensitive)
		return This.ExtractNthOccurrenceCS(1, pItem, pCaseSensitive)

	def ExtractFirstOccurrence(pItem)
		return This.ExtractFirstOccurrenceCS(pItem, 1)

	def ExtractLastOccurrenceCS(pItem, pCaseSensitive)
		nPos = @oList.FindLastCS(pItem, pCaseSensitive)
		if nPos = 0
			return NULL
		ok
		return This.ExtractNth(nPos)

	def ExtractLastOccurrence(pItem)
		return This.ExtractLastOccurrenceCS(pItem, 1)

	  #======================================================#
	 #   EXTRACT DUPLICATES                                 #
	#======================================================#

	def ExtractDuplicatesCS(pCaseSensitive)
		pList = @oList._EngineListFromContent()
		cResult = StzEngineListFindDuplicatesCS(pList, pCaseSensitive)
		StzEngineListFree(pList)

		if cResult = ""
			return []
		ok

		aParts = StzSplit(cResult, ",")
		nLen = len(aParts)
		anDupPos = []
		for i = 1 to nLen
			anDupPos + (0 + aParts[i])
		next

		aContent = This.Content()
		aDups = []
		for i = 1 to nLen
			aDups + aContent[anDupPos[i]]
		next

		for i = nLen to 1 step -1
			ring_remove(This.List(), anDupPos[i])
		next

		return aDups

	def ExtractDuplicates()
		return This.ExtractDuplicatesCS(1)

	  #======================================================#
	 #   EXTRACT ITEMS OF TYPE                              #
	#======================================================#

	def ExtractStrings()
		aContent = This.Content()
		nLen = len(aContent)
		aResult = []
		anPos = []
		for i = nLen to 1 step -1
			if isString(aContent[i])
				aResult + aContent[i]
				anPos + i
			ok
		next
		for i = 1 to len(anPos)
			ring_remove(This.List(), anPos[i])
		next
		return ListReversed(aResult)

	def ExtractNumbers()
		aContent = This.Content()
		nLen = len(aContent)
		aResult = []
		anPos = []
		for i = nLen to 1 step -1
			if isNumber(aContent[i])
				aResult + aContent[i]
				anPos + i
			ok
		next
		for i = 1 to len(anPos)
			ring_remove(This.List(), anPos[i])
		next
		return ListReversed(aResult)

	def ExtractLists()
		aContent = This.Content()
		nLen = len(aContent)
		aResult = []
		anPos = []
		for i = nLen to 1 step -1
			if isList(aContent[i])
				aResult + aContent[i]
				anPos + i
			ok
		next
		for i = 1 to len(anPos)
			ring_remove(This.List(), anPos[i])
		next
		return ListReversed(aResult)

	  #======================================================#
	 #   POP -- EXTRACT LAST (STACK STYLE)                  #
	#======================================================#

	def Pop()
		return This.ExtractLast()

	def PopFirst()
		return This.ExtractFirst()

	  #======================================================#
	 #   TAKE -- EXTRACT N FROM START                       #
	#======================================================#

	def Take(n)
		return This.ExtractSection(1, n)

	def TakeLast(n)
		nLen = This.NumberOfItems()
		return This.ExtractSection(nLen - n + 1, nLen)
