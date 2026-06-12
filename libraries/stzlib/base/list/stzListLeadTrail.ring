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

class stzListLeadTrail

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
		aLead = This.RepeatedLeadingItemsCS(pCaseSensitive)
		if len(aLead) > 0
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
			aContent = This.Content()
			aResult = []
			for i = 1 to _nCount
				aResult + aContent[i]
			next
			return aResult
		ok

		aContent = This.Content()
		nLen = len(aContent)
		if nLen < 2
			return []
		ok
		aResult = []
		firstItem = aContent[1]
		for i = 1 to nLen
			if BothAreEqualCS(aContent[i], firstItem, pCaseSensitive)
				aResult + aContent[i]
			else
				exit
			ok
		next
		if len(aResult) < 2
			return []
		ok
		return aResult

	def RepeatedLeadingItems()
		return This.RepeatedLeadingItemsCS(1)

	def RepeatedLeadingItemCS(pCaseSensitive)
		aLead = This.RepeatedLeadingItemsCS(pCaseSensitive)
		if len(aLead) > 0
			return aLead[1]
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
		aTrail = This.RepeatedTrailingItemsCS(pCaseSensitive)
		if len(aTrail) > 0
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
			aContent = This.Content()
			nLen = len(aContent)
			aResult = []
			for i = nLen - _nCount2 + 1 to nLen
				aResult + aContent[i]
			next
			return aResult
		ok

		aContent = This.Content()
		nLen = len(aContent)
		if nLen < 2
			return []
		ok
		aResult = []
		lastItem = aContent[nLen]
		for i = nLen to 1 step -1
			if BothAreEqualCS(aContent[i], lastItem, pCaseSensitive)
				aResult + aContent[i]
			else
				exit
			ok
		next
		if len(aResult) < 2
			return []
		ok
		return ListReversed(aResult)

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

		aLead = This.RepeatedLeadingItemsCS(pCaseSensitive)
		nToRemove = len(aLead) - 1
		if nToRemove > 0
			@oList.RemoveSection(1, nToRemove)
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

		aTrail = This.RepeatedTrailingItemsCS(pCaseSensitive)
		nToRemove = len(aTrail) - 1
		nLen = This.NumberOfItems()
		if nToRemove > 0
			@oList.RemoveSection(nLen - nToRemove + 1, nLen)
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
		if This.NumberOfItems() = 0
			return 0
		ok
		if isString(pItem)
			_pSwList = @oList._EngineListFromContent()
			if _pSwList != NULL
				_pSwVal = StzEngineValueNewString(pItem)
				if _pSwVal != NULL
					_nCsSw = 1
					if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
						_nCsSw = pCaseSensitive[2]
					but isNumber(pCaseSensitive)
						_nCsSw = pCaseSensitive
					ok
					_nResult = StzEngineListStartsWithCS(_pSwList, _pSwVal, _nCsSw)
					StzEngineValueFree(_pSwVal)
					StzEngineListFree(_pSwList)
					return _nResult
				ok
				StzEngineListFree(_pSwList)
			ok
		ok
		return BothAreEqualCS(@oList.List()[1], pItem, pCaseSensitive)

	def StartsWith(pItem)
		return This.StartsWithCS(pItem, 1)

	def EndsWithCS(pItem, pCaseSensitive)
		if This.NumberOfItems() = 0
			return 0
		ok
		if isString(pItem)
			_pEwList = @oList._EngineListFromContent()
			if _pEwList != NULL
				_pEwVal = StzEngineValueNewString(pItem)
				if _pEwVal != NULL
					_nCsEw = 1
					if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
						_nCsEw = pCaseSensitive[2]
					but isNumber(pCaseSensitive)
						_nCsEw = pCaseSensitive
					ok
					_nResult2 = StzEngineListEndsWithCS(_pEwList, _pEwVal, _nCsEw)
					StzEngineValueFree(_pEwVal)
					StzEngineListFree(_pEwList)
					return _nResult2
				ok
				StzEngineListFree(_pEwList)
			ok
		ok
		nLen = This.NumberOfItems()
		return BothAreEqualCS(@oList.List()[nLen], pItem, pCaseSensitive)

	def EndsWith(pItem)
		return This.EndsWithCS(pItem, 1)
