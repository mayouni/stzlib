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

		if isString(pItem)
			_pRmList = @oList._EngineListFromContent()
			if _pRmList != NULL
				_pRmVal = StzEngineValueNewString(pItem)
				if _pRmVal != NULL
					_nCsRm = 1
					if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
						_nCsRm = pCaseSensitive[2]
					but isNumber(pCaseSensitive)
						_nCsRm = pCaseSensitive
					ok
					StzEngineListRemoveAllCS(_pRmList, _pRmVal, _nCsRm)
					@oList.UpdateWith(@oList._ContentFromEngineList(_pRmList))
					StzEngineValueFree(_pRmVal)
				ok
				StzEngineListFree(_pRmList)
				return
			ok
		ok

		anPos = @oList.FindAllCS(pItem, pCaseSensitive)
		nLenPos = len(anPos)

		_oCopy_ = @oList.Copy()

		for i = nLenPos to 1 step -1
			_oCopy_.RemoveItemAtPosition(anPos[i])
		next

		@oList.UpdateWith(_oCopy_.Content())

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
		aResult = @oList.Copy().RemoveAllQ(pItem).Content()
		return aResult

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
			_pRipList = @oList._EngineListFromContent()
			if _pRipList != NULL
				StzEngineListRemove(_pRipList, n)
				@oList.UpdateWith(@oList._ContentFromEngineList(_pRipList))
				StzEngineListFree(_pRipList)
				return
			ok

			aContent = This.Content()
			ring_del( aContent, n )
			@oList.UpdateWith(aContent)
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
		aResult = @oList.Copy().RemoveItemAtPositionQ(n).Content()
		return aResult

	  #--------------------------------------#
	 #    REMOVING FIRST ITEM IN THE LIST   #
	#--------------------------------------#

	def RemoveFirstItem()
		This.RemoveItemAtPosition(1)

		def RemoveFirstItemQ()
			This.RemoveFirstItem()
			return This

	def FirstItemRemoved()
		aResult = @oList.Copy().RemoveFirstItemQ().Content()
		return aResult

	  #-------------------------------------#
	 #    REMOVING LAST ITEM IN THE LIST   #
	#-------------------------------------#

	def RemoveLastItem()
		This.RemoveItemAtPosition( This.NumberOfItems() )

		def RemoveLastItemQ()
			This.RemoveLastItem()
			return This

	def LastItemRemoved()
		aResult = @oList.Copy().RemoveLastItemQ().Content()
		return aResult

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
		nLen = len(paItems)
		for i = 1 to nLen
			This.RemoveAllCS(paItems[i], pCaseSensitive)
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

		panPositions = new stzList(panPositions).Sorted()
		nLen = len(panPositions)

		for i = nLen to 1 step -1
			This.RemoveItemAtPosition(panPositions[i])
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
		nLen = This.NumberOfItems()
		if n1 < 1 { n1 = 1 }
		if n2 > nLen { n2 = nLen }

		anPositions = []
		for i = n1 to n2
			anPositions + i
		next

		This.RemoveItemsAtPositions(anPositions)

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

		anPositions = @oList.FindAllItemsW(pcCondition)
		This.RemoveItemsAtPositions(anPositions)

		def RemoveWQ(pcCondition)
			This.RemoveW(pcCondition)
			return This

	  #------------------------------------#
	 #   REMOVING NTH OCCURRENCE         #
	#------------------------------------#

	def RemoveNthOccurrenceCS(n, pItem, pCaseSensitive)
		nPos = @oList.FindNthCS(n, pItem, pCaseSensitive)
		if nPos > 0
			This.RemoveItemAtPosition(nPos)
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
		anPos = @oList.FindAllCS(pItem, pCaseSensitive)
		nLen = len(anPos)
		if nLen > 0
			This.RemoveItemAtPosition(anPos[nLen])
		ok

	def RemoveLastOccurrence(pItem)
		This.RemoveLastOccurrenceCS(pItem, 1)
