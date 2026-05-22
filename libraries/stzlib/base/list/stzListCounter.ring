#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTCOUNTER             #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List counter subclass -- conditional        #
#                  counting (W/WXT), conditional insert.       #
#                  For aliases, use stzListCounterXT.           #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzListCounter from stzList

	  #--------------------------------------------------#
	 #     COUNTING ITEMS VERIFYING A GIVEN CONDITION   #
	#==================================================#

	def CountItemsW(pCondition)
		aItems = This.FindW(pCondition)
		nResult = len(aItems)
		return nResult

		def CountW(pCondition)
			return This.CountItemsW(pCondition)

		def NumberOfOccurrencesW(pCondition)
			return This.CountItemsW(pCondition)

		def NumberOfItemsW(pCondition)
			return This.CountItemsW(pCondition)

		def HowManyItemsW(pcCondition)
			return This.CountItemsW(pCondition)

	def NumberOfUniqueItemsW(pCondition)
		return len( This.UniqueItemsW(pCondition) )

		def CountUniqueItemsW(pCondition)
			return This.NumberOfUniqueItemsW(pCondition)

		def CountItemsUW(pCondition)
			return This.NumberOfUniqueItemsW(pCondition)

		def HowManyUniqueItemsW(pcCondition)
			return This.NumberOfUniqueItemsW(pCondition)

	  #------------------------------------------------------------#
	 #     COUNTING ITEMS VERIFYING A GIVEN CONDITION -- XTended  #
	#------------------------------------------------------------#

	def CountItemsWXT(pCondition)
		aItems = This.FindWXT(pCondition)
		nResult = len(aItems)
		return nResult

		def CountWXT(pCondition)
			return This.CountItemsWXT(pCondition)

		def NumberOfOccurrencesWXT(pCondition)
			return This.CountItemsWXT(pCondition)

		def NumberOfItemsWXT(pCondition)
			return This.CountItemsWXT(pCondition)

		def HowManyItemsWXT(pcCondition)
			return This.CountItemsWXT(pCondition)

	def NumberOfUniqueItemsWXT(pCondition)
		return len( This.UniqueItemsWXT(pCondition) )

		def CountUniqueItemsWXT(pCondition)
			return This.NumberOfUniqueItemsWXT(pCondition)

		def CountItemsUWXT(pCondition)
			return This.NumberOfUniqueItemsWXT(pCondition)

		def HowManyUniqueItemsWXT(pcCondition)
			return This.NumberOfUniqueItemsWXT(pCondition)

	  #--------------------------------------------------------------------#
	 #  INSERTING ITEM AFTER OR BEFORE ITEMS VERIFYING A GIVEN CONDITION  #
	#====================================================================#

	def InsertAfterW( pcCondition, pNewItem )
		anPos = This.FindItemsW(pcCondition)
		This.InsertAfterManyPositions( anPos, pNewItem )

		def InsertAfterWQ( pcCondition, pNewItem )
			This.InsertAfterW( pCondition, pNewItem )
			return This

		def InsertAfterWhere(pcCondition, pNewItem)
			This.InsertAfterW(pCondition, pNewItem)

	def InsertBeforeW(pcCondition, pNewItem)
		anPos = This.FindItemsW(pcCondition)
		This.InsertBeforeThesePositions(anPos, pNewItem)

		def InsertBeforeWQ(pcCondition, pNewItem)
			This.InsertBeforeW(pcCondition, pNewItem)
			return This

		def InsertAtW(pcCondition, pNewItem)
			This.InsertBeforeW(pcCondition, pNewItem)

	  #------------------------------------------------------------------------------------#
	 #  INSERTING ITEM AFTER OR BEFORE ITEMS VERIFYING A GIVEN CONDITION -- WXT/EXTENDED  #
	#------------------------------------------------------------------------------------#

	def InsertAfterWXT( pcCondition, pNewItem )
		anPos = This.FindItemsWXT(pcCondition)
		This.InsertAfterManyPositions( anPos, pNewItem )

		def InsertAfterWXTQ( pcCondition, pNewItem )
			This.InsertAfterWXT( pCondition, pNewItem )
			return This

		def InsertAfterWhereXT(pcCondition, pNewItem)
			This.InsertAfterWXT(pCondition, pNewItem)

	def InsertBeforeWXT(pcCondition, pNewItem)
		anPos = This.FindItemsWXT(pcCondition)
		This.InsertBeforeThesePositions(anPos, pNewItem)

		def InsertBeforeWXTQ(pcCondition, pNewItem)
			This.InsertBeforeWXT(pcCondition, pNewItem)
			return This

		def InsertAtWXT(pcCondition, pNewItem)
			This.InsertBeforeWXT(pcCondition, pNewItem)

	  #======================================================#
	 #   COUNT ITEMS OF SPECIFIC TYPE                       #
	#======================================================#

	def CountStrings()
		aContent = This.Content()
		nLen = len(aContent)
		nCount = 0
		for i = 1 to nLen
			if isString(aContent[i])
				nCount++
			ok
		next
		return nCount

		def NumberOfStrings()
			return This.CountStrings()

	def CountNumbers()
		aContent = This.Content()
		nLen = len(aContent)
		nCount = 0
		for i = 1 to nLen
			if isNumber(aContent[i])
				nCount++
			ok
		next
		return nCount

		def NumberOfNumbers()
			return This.CountNumbers()

	def CountLists()
		aContent = This.Content()
		nLen = len(aContent)
		nCount = 0
		for i = 1 to nLen
			if isList(aContent[i])
				nCount++
			ok
		next
		return nCount

		def NumberOfLists()
			return This.CountLists()

	  #======================================================#
	 #   COUNT OCCURRENCES OF A SPECIFIC ITEM               #
	#======================================================#

	def CountCS(pItem, pCaseSensitive)
		if isString(pItem)
			_pCntList = This._EngineListFromContent()
			if _pCntList != NULL
				_nCntResult = StzEngineListCountStringCS(_pCntList, pItem, pCaseSensitive)
				StzEngineListFree(_pCntList)
				return _nCntResult
			ok
		ok

		aContent = This.Content()
		nLen = len(aContent)
		nCount = 0
		for i = 1 to nLen
			if BothAreEqualCS(aContent[i], pItem, pCaseSensitive)
				nCount++
			ok
		next
		return nCount

		def NumberOfOccurrencesOfCS(pItem, pCaseSensitive)
			return This.CountCS(pItem, pCaseSensitive)

	def Count(pItem)
		return This.CountCS(pItem, 1)

		def NumberOfOccurrencesOf(pItem)
			return This.Count(pItem)

	  #======================================================#
	 #   COUNT ITEMS SATISFYING A PREDICATE                 #
	#======================================================#

	def CountIf(pcCondition)
		return This.CountItemsW(pcCondition)

		def HowManyIf(pcCondition)
			return This.CountIf(pcCondition)

	  #======================================================#
	 #   COUNT EMPTY / NON-EMPTY ITEMS                      #
	#======================================================#

	def CountEmptyItems()
		aContent = This.Content()
		nLen = len(aContent)
		nCount = 0
		for i = 1 to nLen
			if isString(aContent[i]) and aContent[i] = ""
				nCount++
			ok
		next
		return nCount

		def NumberOfEmptyItems()
			return This.CountEmptyItems()

	def CountNonEmptyItems()
		return This.NumberOfItems() - This.CountEmptyItems()

		def NumberOfNonEmptyItems()
			return This.CountNonEmptyItems()
