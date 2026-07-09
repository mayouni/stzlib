#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTLEADTRAIL           #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List lead/trail subclass -- repeated       #
#                  leading and trailing item operations.       #
#                  For aliases, use stzListLeadTrailXT.         #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzListLeadTrail from stzObject

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
			StzRaise("Can't create stzListLeadTrail! Parameter must be a list or stzList object.")
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

	def HasRepeatedLeadingItemsCS(pCaseSensitive)
		_aLead_ = This.RepeatedLeadingItemsCS(pCaseSensitive)
		if len(_aLead_) > 0
			return 1
		else
			return 0
		ok

	def HasRepeatedLeadingItems()
		return This.HasRepeatedLeadingItemsCS(1)

	def RepeatedLeadingItemsCS(pCaseSensitive)
		_pLtList = @oList._EngineListFromContent()
		if _pLtList != NULL
			_nCsLt = 1
			if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
				_nCsLt = pCaseSensitive[2]
			but isNumber(pCaseSensitive)
				_nCsLt = pCaseSensitive
			ok
			_nCount = StzEngineListLeadingCountCS(_pLtList, _nCsLt)
			StzEngineListFree(_pLtList)
			if _nCount < 2
				return []
			ok
			_aContent_ = This.Content()
			_aResult_ = []
			for i = 1 to _nCount
				_aResult_ + _aContent_[i]
			next
			return _aResult_
		ok

		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)
		if _nLen_ < 2
			return []
		ok
		_aResult_ = []
		_firstItem_ = _aContent_[1]
		for i = 1 to _nLen_
			if BothAreEqualCS(_aContent_[i], _firstItem_, pCaseSensitive)
				_aResult_ + _aContent_[i]
			else
				exit
			ok
		next
		if len(_aResult_) < 2
			return []
		ok
		return _aResult_

	def RepeatedLeadingItems()
		return This.RepeatedLeadingItemsCS(1)

	def RepeatedLeadingItemCS(pCaseSensitive)
		_aLead_ = This.RepeatedLeadingItemsCS(pCaseSensitive)
		if len(_aLead_) > 0
			return _aLead_[1]
		else
			return ""
		ok

	def RepeatedLeadingItem()
		return This.RepeatedLeadingItemCS(1)

	def NumberOfRepeatedLeadingItemsCS(pCaseSensitive)
		return len(This.RepeatedLeadingItemsCS(pCaseSensitive))

	def NumberOfRepeatedLeadingItems()
		return This.NumberOfRepeatedLeadingItemsCS(1)

	def HasRepeatedTrailingItemsCS(pCaseSensitive)
		_aTrail_ = This.RepeatedTrailingItemsCS(pCaseSensitive)
		if len(_aTrail_) > 0
			return 1
		else
			return 0
		ok

	def HasRepeatedTrailingItems()
		return This.HasRepeatedTrailingItemsCS(1)

	def RepeatedTrailingItemsCS(pCaseSensitive)
		_pLtList2 = @oList._EngineListFromContent()
		if _pLtList2 != NULL
			_nCsLt2 = 1
			if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
				_nCsLt2 = pCaseSensitive[2]
			but isNumber(pCaseSensitive)
				_nCsLt2 = pCaseSensitive
			ok
			_nCount2 = StzEngineListTrailingCountCS(_pLtList2, _nCsLt2)
			StzEngineListFree(_pLtList2)
			if _nCount2 < 2
				return []
			ok
			_aContent_ = This.Content()
			_nLen_ = len(_aContent_)
			_aResult_ = []
			for i = _nLen_ - _nCount2 + 1 to _nLen_
				_aResult_ + _aContent_[i]
			next
			return _aResult_
		ok

		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)
		if _nLen_ < 2
			return []
		ok
		_aResult_ = []
		_lastItem_ = _aContent_[_nLen_]
		for i = _nLen_ to 1 step -1
			if BothAreEqualCS(_aContent_[i], _lastItem_, pCaseSensitive)
				_aResult_ + _aContent_[i]
			else
				exit
			ok
		next
		if len(_aResult_) < 2
			return []
		ok
		return ListReversed(_aResult_)

	def RepeatedTrailingItems()
		return This.RepeatedTrailingItemsCS(1)

	def RemoveRepeatedLeadingItemsCS(pCaseSensitive)
		_pLtRm = @oList._EngineListFromContent()
		if _pLtRm != NULL
			_nCsLtRm = 1
			if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
				_nCsLtRm = pCaseSensitive[2]
			but isNumber(pCaseSensitive)
				_nCsLtRm = pCaseSensitive
			ok
			StzEngineListRemoveLeadingCS(_pLtRm, _nCsLtRm)
			@oList.UpdateWith(@oList._ContentFromEngineList(_pLtRm))
			StzEngineListFree(_pLtRm)
			return
		ok

		_aLead_ = This.RepeatedLeadingItemsCS(pCaseSensitive)
		_nToRemove_ = len(_aLead_) - 1
		if _nToRemove_ > 0
			@oList.RemoveSection(1, _nToRemove_)
		ok

	def RemoveRepeatedLeadingItems()
		This.RemoveRepeatedLeadingItemsCS(1)

	def RemoveRepeatedTrailingItemsCS(pCaseSensitive)
		_pLtRm2 = @oList._EngineListFromContent()
		if _pLtRm2 != NULL
			_nCsLtRm2 = 1
			if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
				_nCsLtRm2 = pCaseSensitive[2]
			but isNumber(pCaseSensitive)
				_nCsLtRm2 = pCaseSensitive
			ok
			StzEngineListRemoveTrailingCS(_pLtRm2, _nCsLtRm2)
			@oList.UpdateWith(@oList._ContentFromEngineList(_pLtRm2))
			StzEngineListFree(_pLtRm2)
			return
		ok

		_aTrail_ = This.RepeatedTrailingItemsCS(pCaseSensitive)
		_nToRemove_ = len(_aTrail_) - 1
		_nLen_ = This.NumberOfItems()
		if _nToRemove_ > 0
			@oList.RemoveSection(_nLen_ - _nToRemove_ + 1, _nLen_)
		ok

	def RemoveRepeatedTrailingItems()
		This.RemoveRepeatedTrailingItemsCS(1)

	def RemoveRepeatedLeadingAndTrailingItemsCS(pCaseSensitive)
		This.RemoveRepeatedLeadingItemsCS(pCaseSensitive)
		This.RemoveRepeatedTrailingItemsCS(pCaseSensitive)

		def RemoveRepeatedLeadingAndTrailingItemsCSQ(pCaseSensitive)
			This.RemoveRepeatedLeadingAndTrailingItemsCS(pCaseSensitive)
			return This

	def RemoveRepeatedLeadingAndTrailingItems()
		This.RemoveRepeatedLeadingAndTrailingItemsCS(1)

		def RemoveRepeatedLeadingAndTrailingItemsQ()
			This.RemoveRepeatedLeadingAndTrailingItems()
			return This

	  #======================================================#
	 #   Q VARIANTS FOR REMOVE LEADING/TRAILING             #
	#======================================================#

	def RemoveRepeatedLeadingItemsCSQ(pCaseSensitive)
		This.RemoveRepeatedLeadingItemsCS(pCaseSensitive)
		return This

	def RemoveRepeatedLeadingItemsQ()
		This.RemoveRepeatedLeadingItems()
		return This

	def RemoveRepeatedTrailingItemsCSQ(pCaseSensitive)
		This.RemoveRepeatedTrailingItemsCS(pCaseSensitive)
		return This

	def RemoveRepeatedTrailingItemsQ()
		This.RemoveRepeatedTrailingItems()
		return This

	  #======================================================#
	 #   PASSIVE FORMS                                      #
	#======================================================#

	def RepeatedLeadingItemsRemovedCS(pCaseSensitive)
		# Was @oList.Copy().RemoveRepeatedLeadingItemsCSQ -- not on core stzList
		_o = new stzListLeadTrail(@oList.Content())
		_o.RemoveRepeatedLeadingItemsCS(pCaseSensitive)
		return _o.Content()

	def RepeatedLeadingItemsRemoved()
		return This.RepeatedLeadingItemsRemovedCS(1)

	def RepeatedTrailingItemsRemovedCS(pCaseSensitive)
		# Was @oList.Copy().RemoveRepeatedTrailingItemsCSQ -- not on core stzList
		_o = new stzListLeadTrail(@oList.Content())
		_o.RemoveRepeatedTrailingItemsCS(pCaseSensitive)
		return _o.Content()

	def RepeatedTrailingItemsRemoved()
		return This.RepeatedTrailingItemsRemovedCS(1)

	  #======================================================#
	 #   STARTS WITH / ENDS WITH                            #
	#======================================================#

	def StartsWithCS(pItem, pCaseSensitive)
		# Single-value first-item compare: O(1) in Ring, so no engine
		# round-trip (the value-handle/list-handle live in separate
		# per-module handle tables and don't cross). The prefix-LIST
		# variant (StartsWithListCS) is what's worth engine-backing.
		if This.NumberOfItems() = 0
			return 0
		ok
		_nCsSw = 1
		if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
			_nCsSw = pCaseSensitive[2]
		but isNumber(pCaseSensitive)
			_nCsSw = pCaseSensitive
		ok
		if BothAreEqualCS(@oList.List()[1], pItem, _nCsSw)
			return 1
		ok
		return 0

	def StartsWith(pItem)
		return This.StartsWithCS(pItem, 1)

	def EndsWithCS(pItem, pCaseSensitive)
		if This.NumberOfItems() = 0
			return 0
		ok
		_nCsEw = 1
		if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
			_nCsEw = pCaseSensitive[2]
		but isNumber(pCaseSensitive)
			_nCsEw = pCaseSensitive
		ok
		_nLen_ = This.NumberOfItems()
		if BothAreEqualCS(@oList.List()[_nLen_], pItem, _nCsEw)
			return 1
		ok
		return 0

	def EndsWith(pItem)
		return This.EndsWithCS(pItem, 1)
