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

class stzListCounter from stzObject

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
			StzRaise("Can't create stzListCounter! Parameter must be a list or stzList object.")
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

	  #--------------------------------------------------#
	 #     COUNTING ITEMS VERIFYING A GIVEN CONDITION   #
	#==================================================#

	def CountItemsW(pCondition)
		_aItems_ = @oList.FindW(pCondition)
		_nResult_ = len(_aItems_)
		return _nResult_

		def CountW(pCondition)
			return This.CountItemsW(pCondition)

		def NumberOfOccurrencesW(pCondition)
			return This.CountItemsW(pCondition)

		def NumberOfItemsW(pCondition)
			return This.CountItemsW(pCondition)

		def HowManyItemsW(pcCondition)
			return This.CountItemsW(pCondition)

	def NumberOfUniqueItemsW(pCondition)
		return len( @oList.UniqueItemsW(pCondition) )

		def CountUniqueItemsW(pCondition)
			return This.NumberOfUniqueItemsW(pCondition)

		def CountItemsUW(pCondition)
			return This.NumberOfUniqueItemsW(pCondition)

		def HowManyUniqueItemsW(pcCondition)
			return This.NumberOfUniqueItemsW(pCondition)

	  #------------------------------------------------------------#
	 #     COUNTING ITEMS VERIFYING A GIVEN CONDITION -- XTended  #
	#------------------------------------------------------------#










	  #--------------------------------------------------------------------#
	 #  INSERTING ITEM AFTER OR BEFORE ITEMS VERIFYING A GIVEN CONDITION  #
	#====================================================================#

	def InsertAfterW( pcCondition, pNewItem )
		_anPos_ = @oList.FindItemsW(pcCondition)
		@oList.InsertAfterManyPositions( _anPos_, pNewItem )

		def InsertAfterWQ( pcCondition, pNewItem )
			This.InsertAfterW( pCondition, pNewItem )
			return This

		def InsertAfterWhere(pcCondition, pNewItem)
			This.InsertAfterW(pCondition, pNewItem)

	def InsertBeforeW(pcCondition, pNewItem)
		_anPos_ = @oList.FindItemsW(pcCondition)
		@oList.InsertBeforeManyPositions(_anPos_, pNewItem)

		def InsertBeforeWQ(pcCondition, pNewItem)
			This.InsertBeforeW(pcCondition, pNewItem)
			return This

		def InsertAtW(pcCondition, pNewItem)
			This.InsertBeforeW(pcCondition, pNewItem)

	  #------------------------------------------------------------------------------------#
	 #  INSERTING ITEM AFTER OR BEFORE ITEMS VERIFYING A GIVEN CONDITION -- WXT/EXTENDED  #
	#------------------------------------------------------------------------------------#







	  #======================================================#
	 #   COUNT ITEMS OF SPECIFIC TYPE                       #
	#======================================================#

	def CountStrings()
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)
		_nCount_ = 0
		for i = 1 to _nLen_
			if isString(_aContent_[i])
				_nCount_++
			ok
		next
		return _nCount_

		def NumberOfStrings()
			return This.CountStrings()

	def CountNumbers()
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)
		_nCount_ = 0
		for i = 1 to _nLen_
			if isNumber(_aContent_[i])
				_nCount_++
			ok
		next
		return _nCount_

		def NumberOfNumbers()
			return This.CountNumbers()

	def CountLists()
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)
		_nCount_ = 0
		for i = 1 to _nLen_
			if isList(_aContent_[i])
				_nCount_++
			ok
		next
		return _nCount_

		def NumberOfLists()
			return This.CountLists()

	  #======================================================#
	 #   COUNT OCCURRENCES OF A SPECIFIC ITEM               #
	#======================================================#

	def CountCS(pItem, pCaseSensitive)
		if isString(pItem)
			_pCntList = @oList._EngineListFromContent()
			if _pCntList != NULL
				_nCntResult = StzEngineListCountStringCS(_pCntList, pItem, pCaseSensitive)
				StzEngineListFree(_pCntList)
				return _nCntResult
			ok
		ok

		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)
		_nCount_ = 0
		for i = 1 to _nLen_
			if BothAreEqualCS(_aContent_[i], pItem, pCaseSensitive)
				_nCount_++
			ok
		next
		return _nCount_

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
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)
		_nCount_ = 0
		for i = 1 to _nLen_
			if isString(_aContent_[i]) and _aContent_[i] = ""
				_nCount_++
			ok
		next
		return _nCount_

		def NumberOfEmptyItems()
			return This.CountEmptyItems()

	def CountNonEmptyItems()
		return This.NumberOfItems() - This.CountEmptyItems()

		def NumberOfNonEmptyItems()
			return This.CountNonEmptyItems()
