#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTREPLACER            #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List replacer subclass -- replacing items,  #
#                  sections, ranges, occurrences.               #
#                  For aliases, use stzListReplacerXT.          #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzListReplacer

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
			StzRaise("Can't create stzListReplacer! Parameter must be a list or stzList object.")
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

	  #=========================================#
	 #   REPLACING ALL ITEMS WITH A NEW ITEM   #
	#=========================================#

	def ReplaceAllItems(pNewItem)

		_nLen_ = This.NumberOfItems()
		_aContent_ = This.Content()

		for @i = 1 to _nLen_
			_aContent_[@i] = pNewItem
		next

		@oList.UpdateWith(_aContent_)

		def ReplaceAllItemsQ(pNewItem)
			This.ReplaceAllItems(pNewItem)
			return This

	  #-------------------------------------------#
	 #   REPLACING ALL OCCURRENCES OF AN ITEM    #
	#-------------------------------------------#

	def ReplaceAllOccurrencesCS(pItem, pNewItem, pCaseSensitive)

		if CheckingParams()
			if isList(pItem) and IsOfNamedParamList(pItem)
				pItem = pItem[2]
			ok
		ok

		if isString(pItem) and isString(pNewItem)
			_pRpAll_ = @oList._EngineListFromContent()
			if _pRpAll_ != NULL
				_pRpOldVal_ = StzEngineValueNewString(pItem)
				_pRpNewVal_ = StzEngineValueNewString(pNewItem)
				if _pRpOldVal_ != NULL and _pRpNewVal_ != NULL
					_nRpCs_ = 1
					if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
						_nRpCs_ = pCaseSensitive[2]
					but isNumber(pCaseSensitive)
						_nRpCs_ = pCaseSensitive
					ok
					StzEngineListReplaceAllCS(_pRpAll_, _pRpOldVal_, _pRpNewVal_, _nRpCs_)
					@oList.UpdateWith(@oList._ContentFromEngineList(_pRpAll_))
				ok
				if _pRpOldVal_ != NULL StzEngineValueFree(_pRpOldVal_) ok
				if _pRpNewVal_ != NULL StzEngineValueFree(_pRpNewVal_) ok
				StzEngineListFree(_pRpAll_)
				return
			ok
		ok

		_anRpPos_ = @oList.FindAllCS(pItem, pCaseSensitive)
		_nRpLen_ = len(_anRpPos_)

		for _iRp_ = 1 to _nRpLen_
			This.ReplaceAnyItemAtPositionCS(_anRpPos_[_iRp_], pNewItem, pCaseSensitive)
		next

		def ReplaceAllOccurrencesCSQ(pItem, pNewItem, pCaseSensitive)
			This.ReplaceAllOccurrencesCS(pItem, pNewItem, pCaseSensitive)
			return This

		def ReplaceAllCS(pItem, pNewItem, pCaseSensitive)
			This.ReplaceAllOccurrencesCS(pItem, pNewItem, pCaseSensitive)

		def ReplaceCS(pItem, pNewItem, pCaseSensitive)
			if isList(pItem) and IsEachNamedParamList(pItem)
				pItem = pItem[2]
			ok
			This.ReplaceAllOccurrencesCS(pItem, pNewItem, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def ReplaceAllOccurrences(pItem, pNewItem)
		This.ReplaceAllOccurrencesCS(pItem, pNewItem, 1)

		def ReplaceAllOccurrencesQ(pItem, pNewItem)
			This.ReplaceAllOccurrences(pItem, pNewItem)
			return This

		def ReplaceAll(pItem, pNewItem)
			This.ReplaceAllOccurrences(pItem, pNewItem)

		def Replace(pItem, pNewItem)
			if isList(pItem) and IsEachNamedParamList(pItem)
				pItem = pItem[2]
			ok
			This.ReplaceAllOccurrences(pItem, pNewItem)

	def AllOccurrencesReplacedCS(pItem, pNewItem, pCaseSensitive)
		_aAorResult_ = @oList.Copy().ReplaceAllOccurrencesCSQ(pItem, pNewItem, pCaseSensitive).Content()
		return _aAorResult_

	def AllOccurrencesReplaced(pItem, pNewItem)
		return This.AllOccurrencesReplacedCS(pItem, pNewItem, 1)

	  #==================================================#
	 #   REPLACING ANY ITEM AT A GIVEN POSITION         #
	#==================================================#

	def ReplaceAnyItemAtPositionCS(n, pNewItem, pCaseSensitive)
		_aRapContent_ = This.Content()
		if n >= 1 and n <= len(_aRapContent_)
			if isString(pNewItem)
				_pRapList_ = @oList._EngineListFromContent()
				if _pRapList_ != NULL
					_pRapVal_ = StzEngineValueNewString(pNewItem)
					if _pRapVal_ != NULL
						StzEngineListSet(_pRapList_, n, _pRapVal_)
						@oList.UpdateWith(@oList._ContentFromEngineList(_pRapList_))
						StzEngineValueFree(_pRapVal_)
					ok
					StzEngineListFree(_pRapList_)
					return
				ok
			ok
			_aRapContent_[n] = pNewItem
			@oList.UpdateWith(_aRapContent_)
		ok

		def ReplaceAnyItemAtPositionCSQ(n, pNewItem, pCaseSensitive)
			This.ReplaceAnyItemAtPositionCS(n, pNewItem, pCaseSensitive)
			return This

	def ReplaceAnyItemAtPosition(n, pNewItem)
		This.ReplaceAnyItemAtPositionCS(n, pNewItem, 1)

		def ReplaceAnyItemAtPositionQ(n, pNewItem)
			This.ReplaceAnyItemAtPosition(n, pNewItem)
			return This

		def ReplaceItemAtPosition(n, pNewItem)
			This.ReplaceAnyItemAtPosition(n, pNewItem)

		def ReplaceAt(n, pNewItem)
			This.ReplaceAnyItemAtPosition(n, pNewItem)

	  #============================================#
	 #   REPLACING NTH OCCURRENCE OF AN ITEM     #
	#============================================#

	def ReplaceNthOccurrenceCS(n, pItem, pNewItem, pCaseSensitive)
		_nRnoPos_ = @oList.FindNthCS(n, pItem, pCaseSensitive)
		if _nRnoPos_ > 0
			This.ReplaceAnyItemAtPosition(_nRnoPos_, pNewItem)
		ok

		def ReplaceNthOccurrenceCSQ(n, pItem, pNewItem, pCaseSensitive)
			This.ReplaceNthOccurrenceCS(n, pItem, pNewItem, pCaseSensitive)
			return This

	def ReplaceNthOccurrence(n, pItem, pNewItem)
		This.ReplaceNthOccurrenceCS(n, pItem, pNewItem, 1)

		def ReplaceNthOccurrenceQ(n, pItem, pNewItem)
			This.ReplaceNthOccurrence(n, pItem, pNewItem)
			return This

	  #================================================#
	 #   REPLACING FIRST OCCURRENCE OF AN ITEM        #
	#================================================#

	def ReplaceFirstOccurrenceCS(pItem, pNewItem, pCaseSensitive)
		This.ReplaceNthOccurrenceCS(1, pItem, pNewItem, pCaseSensitive)

		def ReplaceFirstOccurrenceCSQ(pItem, pNewItem, pCaseSensitive)
			This.ReplaceFirstOccurrenceCS(pItem, pNewItem, pCaseSensitive)
			return This

	def ReplaceFirstOccurrence(pItem, pNewItem)
		This.ReplaceFirstOccurrenceCS(pItem, pNewItem, 1)

		def ReplaceFirstOccurrenceQ(pItem, pNewItem)
			This.ReplaceFirstOccurrence(pItem, pNewItem)
			return This

	  #================================================#
	 #   REPLACING LAST OCCURRENCE OF AN ITEM         #
	#================================================#

	def ReplaceLastOccurrenceCS(pItem, pNewItem, pCaseSensitive)
		_anRloPos_ = @oList.FindAllCS(pItem, pCaseSensitive)
		_nRloLen_ = len(_anRloPos_)
		if _nRloLen_ > 0
			This.ReplaceAnyItemAtPosition(_anRloPos_[_nRloLen_], pNewItem)
		ok

		def ReplaceLastOccurrenceCSQ(pItem, pNewItem, pCaseSensitive)
			This.ReplaceLastOccurrenceCS(pItem, pNewItem, pCaseSensitive)
			return This

	def ReplaceLastOccurrence(pItem, pNewItem)
		This.ReplaceLastOccurrenceCS(pItem, pNewItem, 1)

		def ReplaceLastOccurrenceQ(pItem, pNewItem)
			This.ReplaceLastOccurrence(pItem, pNewItem)
			return This

	  #=====================================#
	 #   REPLACING MANY ITEMS AT ONCE     #
	#=====================================#

	def ReplaceManyCS(paItems, pNewItem, pCaseSensitive)
		_nRmLen_ = len(paItems)
		for _iRm_ = 1 to _nRmLen_
			This.ReplaceAllOccurrencesCS(paItems[_iRm_], pNewItem, pCaseSensitive)
		next

		def ReplaceManyCSQ(paItems, pNewItem, pCaseSensitive)
			This.ReplaceManyCS(paItems, pNewItem, pCaseSensitive)
			return This

	def ReplaceMany(paItems, pNewItem)
		This.ReplaceManyCS(paItems, pNewItem, 1)

		def ReplaceManyQ(paItems, pNewItem)
			This.ReplaceMany(paItems, pNewItem)
			return This

	  #============================================#
	 #   REPLACING A SECTION OF ITEMS            #
	#============================================#

	def ReplaceSectionCS(n1, n2, paNewItems, pCaseSensitive)
		_aRsContent_ = This.Content()
		_nRsLen_ = len(_aRsContent_)

		if n1 < 1 { n1 = 1 }
		if n2 > _nRsLen_ { n2 = _nRsLen_ }

		_aRsResult_ = []
		for _iRsPre_ = 1 to n1 - 1
			@AddItem(_aRsResult_, _aRsContent_[_iRsPre_])
		next

		_nRsNewLen_ = len(paNewItems)
		for _iRsNew_ = 1 to _nRsNewLen_
			@AddItem(_aRsResult_, paNewItems[_iRsNew_])
		next

		for _iRsPost_ = n2 + 1 to _nRsLen_
			@AddItem(_aRsResult_, _aRsContent_[_iRsPost_])
		next

		@oList.UpdateWith(_aRsResult_)

	def ReplaceSection(n1, n2, paNewItems)
		This.ReplaceSectionCS(n1, n2, paNewItems, 1)

	  #============================================#
	 #   REPLACING MANY ITEMS BY MANY             #
	#============================================#

	def ReplaceManyByManyCS(paItems, paNewItems, pCaseSensitive)
		if isList(paNewItems) and len(paNewItems) > 0
			if isString(paNewItems[1]) and
			   (paNewItems[1] = :by or paNewItems[1] = :with or paNewItems[1] = :By or paNewItems[1] = :With)
				paNewItems = paNewItems[2]
			ok
		ok

		_nRmbmItemsLen_ = len(paItems)
		_nRmbmNewLen_ = len(paNewItems)

		if _nRmbmItemsLen_ = 0 or _nRmbmNewLen_ = 0
			return
		ok

		if _nRmbmItemsLen_ != _nRmbmNewLen_
			StzRaise("Incorrect values! paItems and paNewItems must have the same size.")
		ok

		for _iRmbm_ = 1 to _nRmbmItemsLen_
			This.ReplaceAllOccurrencesCS(paItems[_iRmbm_], paNewItems[_iRmbm_], pCaseSensitive)
		next

		def ReplaceManyByManyCSQ(paItems, paNewItems, pCaseSensitive)
			This.ReplaceManyByManyCS(paItems, paNewItems, pCaseSensitive)
			return This

	def ReplaceManyByMany(paItems, paNewItems)
		This.ReplaceManyByManyCS(paItems, paNewItems, 1)

		def ReplaceManyByManyQ(paItems, paNewItems)
			This.ReplaceManyByMany(paItems, paNewItems)
			return This

	def ReplaceManyByManyCSXT(paItems, paNewItems, pCaseSensitive)
		# XT version: if paNewItems is shorter, it cycles; if longer, it truncates
		if isList(paNewItems) and len(paNewItems) > 0
			if isString(paNewItems[1]) and
			   (paNewItems[1] = :by or paNewItems[1] = :with or paNewItems[1] = :By or paNewItems[1] = :With)
				paNewItems = paNewItems[2]
			ok
		ok

		_nRmbmxtItemsLen_ = len(paItems)
		_nRmbmxtNewLen_ = len(paNewItems)

		if _nRmbmxtItemsLen_ = 0 or _nRmbmxtNewLen_ = 0
			return
		ok

		# Build a matched-size replacement list by cycling
		_aRmbmxtMatched_ = []
		for _iRmbmxt_ = 1 to _nRmbmxtItemsLen_
			_nRmbmxtIdx_ = ((_iRmbmxt_ - 1) % _nRmbmxtNewLen_) + 1
			_aRmbmxtMatched_ + paNewItems[_nRmbmxtIdx_]
		next

		for _iRmbmxt2_ = 1 to _nRmbmxtItemsLen_
			This.ReplaceAllOccurrencesCS(paItems[_iRmbmxt2_], _aRmbmxtMatched_[_iRmbmxt2_], pCaseSensitive)
		next

	def ReplaceManyByManyXT(paItems, paNewItems)
		This.ReplaceManyByManyCSXT(paItems, paNewItems, 1)
