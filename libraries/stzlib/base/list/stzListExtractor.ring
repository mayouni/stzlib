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
		# Was `ring_remove(This.List(), n)` -- This.List() returns a list
		# value, not a mutable reference into @oList.@aContent, so the
		# removal didn't persist. Use the proper @oList.RemoveItemAtPosition
		# which goes through UpdateWith and persists.
		pItem = @oList.NthItem(n)
		@oList.RemoveItemAtPosition(n)
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
		_pEdList_ = @oList._EngineListFromContent()
		# Engine returns a ready list of 1-based positions (built Zig-side).
		_anEdDupPos_ = StzEngineListFindDuplicatesCS(_pEdList_, pCaseSensitive)
		StzEngineListFree(_pEdList_)

		_nEdLen_ = len(_anEdDupPos_)
		if _nEdLen_ = 0
			return []
		ok

		_aEdContent_ = This.Content()
		_aEdDups_ = []
		for _jEd_ = 1 to _nEdLen_
			@AddItem(_aEdDups_, _aEdContent_[_anEdDupPos_[_jEd_]])
		next

		for _kEd_ = _nEdLen_ to 1 step -1
			@oList.RemoveItemAtPosition(_anEdDupPos_[_kEd_])
		next

		return _aEdDups_

	def ExtractDuplicates()
		return This.ExtractDuplicatesCS(1)

	  #======================================================#
	 #   EXTRACT ITEMS OF TYPE                              #
	#======================================================#

	def ExtractStrings()
		# Collect forward to preserve order, then remove in reverse pass
		# to keep indices valid. `ring_remove(This.List(), ...)` was a
		# no-op (List() returns a copy), and ListReversed wasnt defined.
		_aEsContent_ = This.Content()
		_nEsLen_ = len(_aEsContent_)
		_aEsResult_ = []
		_anEsPos_ = []
		for _iEs_ = 1 to _nEsLen_
			if isString(_aEsContent_[_iEs_])
				@AddItem(_aEsResult_, _aEsContent_[_iEs_])
				@AddItem(_anEsPos_, _iEs_)
			ok
		next
		for _jEs_ = len(_anEsPos_) to 1 step -1
			@oList.RemoveItemAtPosition(_anEsPos_[_jEs_])
		next
		return _aEsResult_

	def ExtractNumbers()
		_aEnContent_ = This.Content()
		_nEnLen_ = len(_aEnContent_)
		_aEnResult_ = []
		_anEnPos_ = []
		for _iEn_ = 1 to _nEnLen_
			if isNumber(_aEnContent_[_iEn_])
				@AddItem(_aEnResult_, _aEnContent_[_iEn_])
				@AddItem(_anEnPos_, _iEn_)
			ok
		next
		for _jEn_ = len(_anEnPos_) to 1 step -1
			@oList.RemoveItemAtPosition(_anEnPos_[_jEn_])
		next
		return _aEnResult_

	def ExtractLists()
		_aElContent_ = This.Content()
		_nElLen_ = len(_aElContent_)
		_aElResult_ = []
		_anElPos_ = []
		for _iEl_ = 1 to _nElLen_
			if isList(_aElContent_[_iEl_])
				@AddItem(_aElResult_, _aElContent_[_iEl_])
				@AddItem(_anElPos_, _iEl_)
			ok
		next
		for _jEl_ = len(_anElPos_) to 1 step -1
			@oList.RemoveItemAtPosition(_anElPos_[_jEl_])
		next
		return _aElResult_

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
