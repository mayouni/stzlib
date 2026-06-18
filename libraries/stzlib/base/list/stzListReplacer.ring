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

		# Engine fast path via string-direct variant (sidesteps the
		# cross-DLL handle-table issue: the engine creates the StzValue
		# inside stz_list.dll, so no cross-DLL handle lookup is needed).
		if isString(pItem) and isString(pNewItem)
			_pRpAll_ = @oList._EngineListFromContent()
			if _pRpAll_ != NULL
				_nRpCs_ = 1
				if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
					_nRpCs_ = pCaseSensitive[2]
				but isNumber(pCaseSensitive)
					_nRpCs_ = pCaseSensitive
				ok
				StzEngineListReplaceAllStringCS(_pRpAll_, pItem, pNewItem, _nRpCs_)
				@oList.UpdateWith(@oList._ContentFromEngineList(_pRpAll_))
				StzEngineListFree(_pRpAll_)
				return
			ok
		ok

		# Fallback for non-string types
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
		# Was @oList.Copy().ReplaceAllOccurrencesCSQ -- not on core stzList
		_o = new stzListReplacer(@oList.Content())
		_o.ReplaceAllOccurrencesCS(pItem, pNewItem, pCaseSensitive)
		return _o.Content()

	def AllOccurrencesReplaced(pItem, pNewItem)
		return This.AllOccurrencesReplacedCS(pItem, pNewItem, 1)

	  #==================================================#
	 #   REPLACING ANY ITEM AT A GIVEN POSITION         #
	#==================================================#

	def ReplaceAnyItemAtPositionCS(n, pNewItem, pCaseSensitive)
		# Engine fast path for strings via the new SetString variant
		# (string-direct, no cross-DLL handle lookup).
		if isString(pNewItem)
			_pRapList_ = @oList._EngineListFromContent()
			if _pRapList_ != NULL
				StzEngineListSetString(_pRapList_, n, pNewItem)
				@oList.UpdateWith(@oList._ContentFromEngineList(_pRapList_))
				StzEngineListFree(_pRapList_)
				return
			ok
		ok

		# Fallback: direct Ring assignment
		_aRapContent_ = This.Content()
		if n >= 1 and n <= len(_aRapContent_)
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
		pNewItem = This._RpVal(pNewItem)		#-- strip :By/:With
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

	#-- ReplaceSection: the section [n1..n2] is replaced by ONE new item --
	#-- if that item is a list, it is inserted as a SINGLE element. This is
	#-- the canonical Softanza semantics (see ReplaceSectionByMany to splice).
	def ReplaceSection(n1, n2, pNewItem)
		if isList(pNewItem) and len(pNewItem) = 2 and isString(pNewItem[1]) and
		   (lower(pNewItem[1]) = "by" or lower(pNewItem[1]) = "with")
			pNewItem = pNewItem[2]
		ok

		_aRsContent_ = This.Content()
		_nRsLen_ = len(_aRsContent_)
		if n1 < 1 { n1 = 1 }
		if n2 > _nRsLen_ { n2 = _nRsLen_ }

		_aRsResult_ = []
		for _iRsPre_ = 1 to n1 - 1
			@AddItem(_aRsResult_, _aRsContent_[_iRsPre_])
		next

		@AddItem(_aRsResult_, pNewItem)

		for _iRsPost_ = n2 + 1 to _nRsLen_
			@AddItem(_aRsResult_, _aRsContent_[_iRsPost_])
		next

		@oList.UpdateWith(_aRsResult_)

		def ReplaceSectionQ(n1, n2, pNewItem)
			This.ReplaceSection(n1, n2, pNewItem)
			return This

	#-- ReplaceSectionByMany: the section [n1..n2] is replaced by SPLICING
	#-- the items of paNewItems in place (flattened one level into the list).
	def ReplaceSectionByManyCS(n1, n2, paNewItems, pCaseSensitive)
		if isList(paNewItems) and len(paNewItems) = 2 and isString(paNewItems[1]) and
		   (lower(paNewItems[1]) = "by" or lower(paNewItems[1]) = "with")
			paNewItems = paNewItems[2]
		ok

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

	def ReplaceSectionByMany(n1, n2, paNewItems)
		This.ReplaceSectionByManyCS(n1, n2, paNewItems, 1)

		def ReplaceSectionByManyQ(n1, n2, paNewItems)
			This.ReplaceSectionByMany(n1, n2, paNewItems)
			return This

	#-- Back-compat alias: the old ReplaceSectionCS spliced; keep that as the
	#-- by-many CS variant so any existing caller is unaffected.
	def ReplaceSectionCS(n1, n2, paNewItems, pCaseSensitive)
		This.ReplaceSectionByManyCS(n1, n2, paNewItems, pCaseSensitive)

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

	  #====================================================#
	 #   POSITIONAL REPLACERS (ported from the monolith)  #
	#====================================================#

	#-- strip a :By / :With / :Using named-param wrapper
	def _RpVal(p)
		if isList(p) and len(p) = 2 and isString(p[1])
			_c_ = lower(p[1])
			if _c_ = "by" or _c_ = "with" or _c_ = "using"
				return p[2]
			ok
		ok
		return p

	#-- value equality honoring case-sensitivity (UTF-8 safe via the engine)
	def _RpEq(pA, pB, pCaseSensitive)
		if isString(pA) and isString(pB) and pCaseSensitive = 0
			return StzLower(pA) = StzLower(pB)
		ok
		return pA = pB

	def _RpIn(pVal, paItems, pCaseSensitive)
		_m_ = len(paItems)
		for _k_ = 1 to _m_
			if This._RpEq(pVal, paItems[_k_], pCaseSensitive)
				return TRUE
			ok
		next
		return FALSE

	#-- Set whatever lives at each of panPos to pNewItem.
	def ReplaceAnyItemAtPositions(panPos, pNewItem)
		pNewItem = This._RpVal(pNewItem)
		_a_ = This.Content()
		_n_ = len(_a_)
		_np_ = len(panPos)
		for _i_ = 1 to _np_
			_p_ = panPos[_i_]
			if _p_ >= 1 and _p_ <= _n_
				_a_[_p_] = pNewItem
			ok
		next
		@oList.UpdateWith(_a_)

		def ReplaceAnyItemsAtPositions(panPos, pNewItem)
			This.ReplaceAnyItemAtPositions(panPos, pNewItem)

		def ReplaceItemsAtPositions(panPos, pNewItem)
			This.ReplaceAnyItemAtPositions(panPos, pNewItem)

		def ReplaceAtPositions(panPos, pNewItem)
			This.ReplaceAnyItemAtPositions(panPos, pNewItem)

	#-- Set the single position n to pNewItem (named-param aware).
	def ReplaceAnyItemAt(n, pNewItem)
		This.ReplaceAnyItemAtPositions([ n ], pNewItem)

	#-- At each of panPos, replace ONLY if the item there equals pItem.
	def ReplaceThisItemAtPositionsCS(panPos, pItem, pNewItem, pCaseSensitive)
		pNewItem = This._RpVal(pNewItem)
		_a_ = This.Content()
		_n_ = len(_a_)
		_np_ = len(panPos)
		for _i_ = 1 to _np_
			_p_ = panPos[_i_]
			if _p_ >= 1 and _p_ <= _n_ and This._RpEq(_a_[_p_], pItem, pCaseSensitive)
				_a_[_p_] = pNewItem
			ok
		next
		@oList.UpdateWith(_a_)

	def ReplaceThisItemAtPositions(panPos, pItem, pNewItem)
		This.ReplaceThisItemAtPositionsCS(panPos, pItem, pNewItem, 1)

	def ReplaceThisItemAtCS(n, pItem, pNewItem, pCaseSensitive)
		This.ReplaceThisItemAtPositionsCS([ n ], pItem, pNewItem, pCaseSensitive)

	def ReplaceThisItemAt(n, pItem, pNewItem)
		This.ReplaceThisItemAtCS(n, pItem, pNewItem, 1)

	#-- At each of panPos, replace if the item there is a member of paItems.
	def ReplaceTheseItemsAtPositionsCS(panPos, paItems, pNewItem, pCaseSensitive)
		pNewItem = This._RpVal(pNewItem)
		_a_ = This.Content()
		_n_ = len(_a_)
		_np_ = len(panPos)
		for _i_ = 1 to _np_
			_p_ = panPos[_i_]
			if _p_ >= 1 and _p_ <= _n_ and This._RpIn(_a_[_p_], paItems, pCaseSensitive)
				_a_[_p_] = pNewItem
			ok
		next
		@oList.UpdateWith(_a_)

	def ReplaceTheseItemsAtPositions(panPos, paItems, pNewItem)
		This.ReplaceTheseItemsAtPositionsCS(panPos, paItems, pNewItem, 1)

	#-- Replace the k-th occurrence of pItem with paNewItems[k] (in order).
	def ReplaceByManyCS(pItem, paNewItems, pCaseSensitive)
		paNewItems = This._RpVal(paNewItems)
		_pos_ = @oList.FindAllCS(pItem, pCaseSensitive)
		_np_ = len(_pos_)
		_nn_ = len(paNewItems)
		_a_ = This.Content()
		for _i_ = 1 to _np_
			if _i_ <= _nn_
				_a_[ _pos_[_i_] ] = paNewItems[_i_]
			ok
		next
		@oList.UpdateWith(_a_)

	def ReplaceByMany(pItem, paNewItems)
		This.ReplaceByManyCS(pItem, paNewItems, 1)

	#-- Cycling variant: paNewItems is reused round-robin across occurrences.
	def ReplaceByManyCSXT(pItem, paNewItems, pCaseSensitive)
		paNewItems = This._RpVal(paNewItems)
		_pos_ = @oList.FindAllCS(pItem, pCaseSensitive)
		_np_ = len(_pos_)
		_nn_ = len(paNewItems)
		if _nn_ = 0 return ok
		_a_ = This.Content()
		for _i_ = 1 to _np_
			_idx_ = ((_i_ - 1) % _nn_) + 1
			_a_[ _pos_[_i_] ] = paNewItems[_idx_]
		next
		@oList.UpdateWith(_a_)

	def ReplaceByManyXT(pItem, paNewItems)
		This.ReplaceByManyCSXT(pItem, paNewItems, 1)

		def ReplaceItemByManyXT(pItem, paNewItems)
			This.ReplaceByManyXT(pItem, paNewItems)

	#-- Replace items at the GIVEN positions with paNewItems consumed in order.
	def ReplaceOccurrencesByMany(panPos, paNewItems)
		_a_ = This.Content()
		_n_ = len(_a_)
		_np_ = len(panPos)
		_nn_ = len(paNewItems)
		for _i_ = 1 to _np_
			if _i_ <= _nn_ and panPos[_i_] >= 1 and panPos[_i_] <= _n_
				_a_[ panPos[_i_] ] = paNewItems[_i_]
			ok
		next
		@oList.UpdateWith(_a_)

	#-- Cycling variant.
	def ReplaceOccurrencesByManyXT(panPos, paNewItems)
		_a_ = This.Content()
		_n_ = len(_a_)
		_np_ = len(panPos)
		_nn_ = len(paNewItems)
		if _nn_ = 0 return ok
		for _i_ = 1 to _np_
			if panPos[_i_] >= 1 and panPos[_i_] <= _n_
				_idx_ = ((_i_ - 1) % _nn_) + 1
				_a_[ panPos[_i_] ] = paNewItems[_idx_]
			ok
		next
		@oList.UpdateWith(_a_)

	  #=========================================================#
	 #  POSITIONS x VALUE-FILTER x MANY (distribute / cycle)   #
	#=========================================================#

	def _RpHas(paList, pVal)
		_n_ = len(paList)
		for _k_ = 1 to _n_
			if paList[_k_] = pVal return TRUE ok
		next
		return FALSE

	def _RpDedup(paList)
		_res_ = []
		_n_ = len(paList)
		for _k_ = 1 to _n_
			if NOT This._RpHas(_res_, paList[_k_])
				_res_ + paList[_k_]
			ok
		next
		return _res_

	def _RpCycle(paItems, nWanted)
		_res_ = []
		_n_ = len(paItems)
		if _n_ = 0 return _res_ ok
		for _k_ = 1 to nWanted
			_res_ + paItems[ ((_k_ - 1) % _n_) + 1 ]
		next
		return _res_

	#-- positions of panPos that hold pItem, kept in panPos order (intersection)
	def _RpPosWithItem(panPos, pItem, pCaseSensitive)
		_anItem_ = @oList.FindAllCS(pItem, pCaseSensitive)
		_res_ = []
		_np_ = len(panPos)
		for _i_ = 1 to _np_
			if This._RpHas(_anItem_, panPos[_i_]) and NOT This._RpHas(_res_, panPos[_i_])
				_res_ + panPos[_i_]
			ok
		next
		return _res_

	#-- At the panPos that hold pItem, replace the k-th such with paNewItems[k].
	def ReplaceItemAtPositionsByManyCS(panPos, pItem, paNewItems, pCaseSensitive)
		paNewItems = This._RpVal(paNewItems)
		_anPos_ = This._RpPosWithItem(panPos, pItem, pCaseSensitive)
		_nLen_ = len(_anPos_)
		_nNew_ = len(paNewItems)
		_a_ = This.Content()
		for _i_ = 1 to _nLen_
			if _i_ <= _nNew_
				_a_[ _anPos_[_i_] ] = paNewItems[_i_]
			ok
		next
		@oList.UpdateWith(_a_)

	def ReplaceItemAtPositionsByMany(panPos, pItem, paNewItems)
		This.ReplaceItemAtPositionsByManyCS(panPos, pItem, paNewItems, 1)

	#-- XT: cycle (deduplicated) paNewItems across the matched positions.
	def ReplaceItemAtPositionsByManyCSXT(panPos, pItem, paNewItems, pCaseSensitive)
		paNewItems = This._RpVal(paNewItems)
		_anPos_ = This._RpPosWithItem(panPos, pItem, pCaseSensitive)
		_nLen_ = len(_anPos_)
		if _nLen_ = 0 return ok
		if len(paNewItems) != _nLen_
			paNewItems = This._RpDedup(paNewItems)
		ok
		_cyc_ = This._RpCycle(paNewItems, _nLen_)
		_a_ = This.Content()
		for _i_ = 1 to _nLen_
			_a_[ _anPos_[_i_] ] = _cyc_[_i_]
		next
		@oList.UpdateWith(_a_)

	def ReplaceItemAtPositionsByManyXT(panPos, pItem, paNewItems)
		This.ReplaceItemAtPositionsByManyCSXT(panPos, pItem, paNewItems, 1)

	#-- These items: apply the per-item position-replace for each item in turn.
	def ReplaceTheseItemsAtPositionsByManyCS(panPos, paItems, paNewItems, pCaseSensitive)
		paNewItems = This._RpVal(paNewItems)
		_nI_ = len(paItems)
		for _i_ = 1 to _nI_
			This.ReplaceItemAtPositionsByManyCS(panPos, paItems[_i_], paNewItems, pCaseSensitive)
		next

	def ReplaceTheseItemsAtPositionsByMany(panPos, paItems, paNewItems)
		This.ReplaceTheseItemsAtPositionsByManyCS(panPos, paItems, paNewItems, 1)

	def ReplaceTheseItemsAtPositionsByManyCSXT(panPos, paItems, paNewItems, pCaseSensitive)
		paNewItems = This._RpVal(paNewItems)
		_nI_ = len(paItems)
		for _i_ = 1 to _nI_
			This.ReplaceItemAtPositionsByManyCSXT(panPos, paItems[_i_], paNewItems, pCaseSensitive)
		next

	def ReplaceTheseItemsAtPositionsByManyXT(panPos, paItems, paNewItems)
		This.ReplaceTheseItemsAtPositionsByManyCSXT(panPos, paItems, paNewItems, 1)

	#-- Any item: zip positions <-> news (no value filter), truncating to shorter.
	def ReplaceAnyItemAtPositionsByManyCS(panPos, paNewItems, pCaseSensitive)
		paNewItems = This._RpVal(paNewItems)
		_nMin_ = len(panPos)
		if len(paNewItems) < _nMin_  _nMin_ = len(paNewItems)  ok
		_a_ = This.Content()
		_n_ = len(_a_)
		for _i_ = 1 to _nMin_
			if panPos[_i_] >= 1 and panPos[_i_] <= _n_
				_a_[ panPos[_i_] ] = paNewItems[_i_]
			ok
		next
		@oList.UpdateWith(_a_)

	def ReplaceAnyItemAtPositionsByMany(panPos, paNewItems)
		This.ReplaceAnyItemAtPositionsByManyCS(panPos, paNewItems, 1)

		def ReplaceAnyItemsAtPositionsByMany(panPos, paNewItems)
			This.ReplaceAnyItemAtPositionsByMany(panPos, paNewItems)

	#-- XT: cycle news across ALL given positions.
	def ReplaceAnyItemAtPositionsByManyCSXT(panPos, paNewItems, pCaseSensitive)
		paNewItems = This._RpVal(paNewItems)
		_np_ = len(panPos)
		if _np_ = 0 or len(paNewItems) = 0 return ok
		_cyc_ = This._RpCycle(paNewItems, _np_)
		_a_ = This.Content()
		_n_ = len(_a_)
		for _i_ = 1 to _np_
			if panPos[_i_] >= 1 and panPos[_i_] <= _n_
				_a_[ panPos[_i_] ] = _cyc_[_i_]
			ok
		next
		@oList.UpdateWith(_a_)

	def ReplaceAnyItemAtPositionsByManyXT(panPos, paNewItems)
		This.ReplaceAnyItemAtPositionsByManyCSXT(panPos, paNewItems, 1)

		def ReplaceAnyItemsAtPositionsByManyXT(panPos, paNewItems)
			This.ReplaceAnyItemAtPositionsByManyXT(panPos, paNewItems)

		def ReplaceAtByManyXT(panPos, paNewItems)
			This.ReplaceAnyItemAtPositionsByManyXT(panPos, paNewItems)

	  #==================================================#
	 #  W-EXPRESSION + NEXT-NTH-OCCURRENCE REPLACERS    #
	#==================================================#

	#-- unwrap ANY 2-element named-param ([:keyword, value] -> value)
	def _RpNamed(p)
		if isList(p) and len(p) = 2 and isString(p[1])
			return p[2]
		ok
		return p

	#-- Replace every item matching the :Where boolean expr with the :By value.
	#-- Matching positions come from the engine-backed FindAllW (@item placeholder).
	def ReplaceWXT(pWhere, pBy)
		_cond_ = This._RpNamed(pWhere)
		_val_  = This._RpNamed(pBy)
		_pos_  = @oList.FindAllW(_cond_)
		This.ReplaceAnyItemAtPositions(_pos_, _val_)

		def ReplaceItemsWXT(pWhere, pBy)
			This.ReplaceWXT(pWhere, pBy)

		def ReplaceItemsW(pWhere, pBy)
			This.ReplaceWXT(pWhere, pBy)

		def ReplaceW(pWhere, pBy)
			This.ReplaceWXT(pWhere, pBy)

	#-- Replace the n-th occurrence of pItem at or after position pnStartingAt.
	def ReplaceNextNthOccurrenceCS(n, pItem, pNewItem, pnStartingAt, pCaseSensitive)
		pItem        = This._RpNamed(pItem)
		pNewItem     = This._RpNamed(pNewItem)
		pnStartingAt = This._RpNamed(pnStartingAt)
		_all_ = @oList.FindAllCS(pItem, pCaseSensitive)
		_na_  = len(_all_)
		_cnt_ = 0
		_target_ = 0
		for _i_ = 1 to _na_
			if _all_[_i_] >= pnStartingAt
				_cnt_++
				if _cnt_ = n
					_target_ = _all_[_i_]
					exit
				ok
			ok
		next
		if _target_ > 0
			_a_ = This.Content()
			_a_[_target_] = pNewItem
			@oList.UpdateWith(_a_)
		ok

	def ReplaceNextNthOccurrence(n, pItem, pNewItem, pnStartingAt)
		This.ReplaceNextNthOccurrenceCS(n, pItem, pNewItem, pnStartingAt, 1)

		def ReplaceNextNthOccurrenceST(n, pItem, pNewItem, pnStartingAt)
			This.ReplaceNextNthOccurrence(n, pItem, pNewItem, pnStartingAt)

		def ReplaceNthNextOccurrenceST(n, pItem, pNewItem, pnStartingAt)
			This.ReplaceNextNthOccurrence(n, pItem, pNewItem, pnStartingAt)
