#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTREMOVER             #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List remover subclass -- removing items,    #
#                  positions, sections, conditions.             #
#                  For aliases, use stzListRemoverXT.           #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzListRemover

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
			StzRaise("Can't create stzListRemover! Parameter must be a list or stzList object.")
		ok

	  #===============================#
	 #     CONTENT ACCESS            #
	#===============================#

	def Content()
		return @oList.Content()

	def NumberOfItems()
		return @oList.NumberOfItems()

	def IsEmpty()
		return @oList.IsEmpty()

	  #=========================================================#
	 #   REMOVING ALL OCCURRENCES OF A GIVEN ITEM IN THE LIST  #
	#=========================================================#

	def RemoveAllCS(pItem, pCaseSensitive)
		if CheckingParams()
			if isList(pItem) and IsOfNamedParamList(pItem)
				pItem = pItem[2]
			ok
		ok

		# Engine fast path via string-direct variant (sidesteps the
		# cross-DLL handle-table issue).
		if isString(pItem)
			_pRmList_ = @oList._EngineListFromContent()
			if _pRmList_ != NULL
				_nRmCs_ = 1
				if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
					_nRmCs_ = pCaseSensitive[2]
				but isNumber(pCaseSensitive)
					_nRmCs_ = pCaseSensitive
				ok
				StzEngineListRemoveAllStringCS(_pRmList_, pItem, _nRmCs_)
				@oList.UpdateWith(@oList._ContentFromEngineList(_pRmList_))
				StzEngineListFree(_pRmList_)
				return
			ok
		ok

		# Fallback for non-string types
		_anRmPos_ = @oList.FindAllCS(pItem, pCaseSensitive)
		_nRmLenPos_ = ring_len(_anRmPos_)

		_oRmCopy_ = @oList.Copy()

		for _iRm_ = _nRmLenPos_ to 1 step -1
			_oRmCopy_.RemoveItemAtPosition(_anRmPos_[_iRm_])
		next

		@oList.UpdateWith(_oRmCopy_.Content())

		def RemoveAllCSQ(pItem, pCaseSensitive)
			This.RemoveAllCS(pItem, pCaseSensitive)
			return This

		def RemoveCS(pItem, pCaseSensitive)
			This.RemoveAllCS(pItem, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def RemoveAll(pItem)
		This.RemoveAllCS(pItem, 1)

		def RemoveAllQ(pItem)
			This.RemoveAll(pItem)
			return This

		def Remove(pItem)
			if isList(pItem) and IsEachNamedParamList(pItem)
				pItem = pItem[2]
			ok
			This.RemoveAll(pItem)

	def AllOccurrencesRemoved(pItem)
		# Was @oList.Copy().RemoveAllQ(pItem) but RemoveAllQ isnt on core stzList
		_o = new stzListRemover(@oList.Content())
		_o.RemoveAll(pItem)
		return _o.Content()

	  #--------------------------------------------------#
	 #   REMOVING AN ITEM BY SPECIFYING ITS POSITION    #
	#--------------------------------------------------#

	def RemoveItemAtPosition(n)

		if isString(n)
			if StzFind([ :First, :FirstPosition, :FirstItem ], n) > 0
				n = 1
			but StzFind([ :Last, :LastPosition, :LastItem ], n) > 0
				n = This.NumberOfItems()
			ok
		ok

		if NOT (isNumber(n) and n != 0 )
			StzRaise("Incorrect param! n must be a number different from zero.")
		ok

		if n <= This.NumberOfItems()
			_pRipList_ = @oList._EngineListFromContent()
			if _pRipList_ != NULL
				StzEngineListRemove(_pRipList_, n)
				@oList.UpdateWith(@oList._ContentFromEngineList(_pRipList_))
				StzEngineListFree(_pRipList_)
				return
			ok

			_aRipContent_ = This.Content()
			ring_del( _aRipContent_, n )
			@oList.UpdateWith(_aRipContent_)
		ok

		def RemoveItemAtPositionQ(n)
			This.RemoveItemAtPosition(n)
			return This

		def RemoveAt(n)
			This.RemoveItemAtPosition(n)

		def RemoveAtPosition(n)
			This.RemoveItemAtPosition(n)

		def RemoveNthItem(n)
			This.RemoveItemAtPosition(n)

	def NthItemRemoved(n)
		_aNirResult_ = @oList.Copy().RemoveItemAtPositionQ(n).Content()
		return _aNirResult_

	  #--------------------------------------#
	 #    REMOVING FIRST ITEM IN THE LIST   #
	#--------------------------------------#

	def RemoveFirstItem()
		This.RemoveItemAtPosition(1)

		def RemoveFirstItemQ()
			This.RemoveFirstItem()
			return This

	def FirstItemRemoved()
		_aFirResult_ = @oList.Copy().RemoveFirstItemQ().Content()
		return _aFirResult_

	  #-------------------------------------#
	 #    REMOVING LAST ITEM IN THE LIST   #
	#-------------------------------------#

	def RemoveLastItem()
		This.RemoveItemAtPosition( This.NumberOfItems() )

		def RemoveLastItemQ()
			This.RemoveLastItem()
			return This

	def LastItemRemoved()
		_aLirResult_ = @oList.Copy().RemoveLastItemQ().Content()
		return _aLirResult_

	  #----------------------------------#
	 #   REMOVING FIRST AND LAST ITEMS  #
	#----------------------------------#

	def RemoveFirstAndLastItems()
		This.RemoveFirstItem()
		This.RemoveLastItem()

		def RemoveFirstAndLastItemsQ()
			This.RemoveFirstAndLastItems()
			return This

	  #----------------------------------------------------#
	 #   REMOVING MANY ITEMS AT THE SAME TIME             #
	#----------------------------------------------------#

	def RemoveManyCS(paItems, pCaseSensitive)
		_nRmcLen_ = ring_len(paItems)
		for _iRmc_ = 1 to _nRmcLen_
			This.RemoveAllCS(paItems[_iRmc_], pCaseSensitive)
		next

		def RemoveManyCSQ(paItems, pCaseSensitive)
			This.RemoveManyCS(paItems, pCaseSensitive)
			return This

	def RemoveMany(paItems)
		This.RemoveManyCS(paItems, 1)

		def RemoveManyQ(paItems)
			This.RemoveMany(paItems)
			return This

	  #----------------------------------------------#
	 #   REMOVING MANY ITEMS BY THEIR POSITIONS     #
	#----------------------------------------------#

	def RemoveItemsAtPositions(panPositions)

		if CheckingParams()
			if NOT isList(panPositions)
				StzRaise("Incorrect param type! panPositions must be a list of numbers.")
			ok
		ok

		_oChain_ = new stzList(panPositions)

		panPositions = _oChain_.Sorted()
		_nRiapLen_ = ring_len(panPositions)

		for _iRiap_ = _nRiapLen_ to 1 step -1
			This.RemoveItemAtPosition(panPositions[_iRiap_])
		next

		def RemoveItemsAtPositionsQ(panPositions)
			This.RemoveItemsAtPositions(panPositions)
			return This

		def RemoveAtPositions(panPositions)
			This.RemoveItemsAtPositions(panPositions)

	  #------------------------------------------#
	 #   REMOVING A SECTION OF ITEMS            #
	#------------------------------------------#

	def RemoveSection(n1, n2)
		_nRsLen_ = This.NumberOfItems()
		if n1 < 1 { n1 = 1 }
		if n2 > _nRsLen_ { n2 = _nRsLen_ }

		_anRsPositions_ = []
		for _iRs_ = n1 to n2
			@AddItem(_anRsPositions_, _iRs_)
		next

		This.RemoveItemsAtPositions(_anRsPositions_)

		def RemoveSectionQ(n1, n2)
			This.RemoveSection(n1, n2)
			return This

	  #-----------------------------------------#
	 #   REMOVING ALL ITEMS IN THE LIST        #
	#-----------------------------------------#

	def RemoveAllItems()
		@oList.UpdateWith([])

		def RemoveAllItemsQ()
			This.RemoveAllItems()
			return This

		def Clear()
			This.RemoveAllItems()

	  #----------------------------------------------#
	 #   REMOVING ITEMS UNDER A GIVEN CONDITION     #
	#----------------------------------------------#

	def RemoveW(pcCondition)

		if NOT isString(pcCondition)
			StzRaise("Incorrect param type! pcCondition must be a string.")
		ok

		_anRwPositions_ = @oList.FindAllItemsW(pcCondition)
		This.RemoveItemsAtPositions(_anRwPositions_)

		def RemoveWQ(pcCondition)
			This.RemoveW(pcCondition)
			return This

	  #------------------------------------#
	 #   REMOVING NTH OCCURRENCE         #
	#------------------------------------#

	def RemoveNthOccurrenceCS(n, pItem, pCaseSensitive)
		_nRnoPos_ = @oList.FindNthCS(n, pItem, pCaseSensitive)
		if _nRnoPos_ > 0
			This.RemoveItemAtPosition(_nRnoPos_)
		ok

		def RemoveNthOccurrenceCSQ(n, pItem, pCaseSensitive)
			This.RemoveNthOccurrenceCS(n, pItem, pCaseSensitive)
			return This

	def RemoveNthOccurrence(n, pItem)
		This.RemoveNthOccurrenceCS(n, pItem, 1)

	  #--------------------------------------------#
	 #   REMOVING FIRST OCCURRENCE OF AN ITEM    #
	#--------------------------------------------#

	def RemoveFirstOccurrenceCS(pItem, pCaseSensitive)
		This.RemoveNthOccurrenceCS(1, pItem, pCaseSensitive)

	def RemoveFirstOccurrence(pItem)
		This.RemoveFirstOccurrenceCS(pItem, 1)

	  #-------------------------------------------#
	 #   REMOVING LAST OCCURRENCE OF AN ITEM    #
	#-------------------------------------------#

	def RemoveLastOccurrenceCS(pItem, pCaseSensitive)
		_anRloPos_ = @oList.FindAllCS(pItem, pCaseSensitive)
		_nRloLen_ = ring_len(_anRloPos_)
		if _nRloLen_ > 0
			This.RemoveItemAtPosition(_anRloPos_[_nRloLen_])
		ok

	def RemoveLastOccurrence(pItem)
		This.RemoveLastOccurrenceCS(pItem, 1)
