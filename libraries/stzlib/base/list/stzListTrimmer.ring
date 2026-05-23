#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTTRIMMER             #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List trimmer subclass -- trim leading and  #
#                  trailing empty items. For aliases, use      #
#                  stzListTrimmerXT.                            #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzListTrimmer

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
			StzRaise("Can't create stzListTrimmer! Parameter must be a list or stzList object.")
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

	def TrimCS(pCaseSensitive)
		_oCopy_ = @oList.Copy()
		_oCopy_.TrimLeftCS(pCaseSensitive)
		_oCopy_.TrimRightCS(pCaseSensitive)
		@oList.UpdateWith(_oCopy_.Content())

		def TrimCSQ(pCaseSensitive)
			This.TrimCS(pCaseSensitive)
			return This

	def TrimmedCS(pCaseSensitive)
		aResult = @oList.Copy().TrimCSQ(pCaseSensitive).Content()
		return aResult

	def Trim()
		This.TrimCS(1)

		def TrimQ()
			return This.TrimCSQ(1)

	def Trimmed()
		return This.TrimmedCS(1)

	def TrimLeftCS(pCaseSensitive)
		aContent = This.Content()
		nLen = len(aContent)
		if nLen < 1
			return
		ok
		nStart = 0
		for i = 1 to nLen
			if isString(aContent[i]) and ring_trim(aContent[i]) = ""
				nStart = i
			else
				exit
			ok
		next
		if nStart > 0
			@oList.RemoveSection(1, nStart)
		ok

		def TrimLeftCSQ(pCaseSensitive)
			This.TrimLeftCS(pCaseSensitive)
			return This

	def TrimLeft()
		This.TrimLeftCS(1)

	def TrimmedLeft()
		return @oList.Copy().TrimLeftCSQ(1).Content()

	def TrimRightCS(pCaseSensitive)
		aContent = This.Content()
		nLen = len(aContent)
		if nLen < 1
			return
		ok
		nEnd = 0
		for i = nLen to 1 step -1
			if isString(aContent[i]) and ring_trim(aContent[i]) = ""
				nEnd = i
			else
				exit
			ok
		next
		if nEnd > 0
			@oList.RemoveSection(nEnd, nLen)
		ok

		def TrimRightCSQ(pCaseSensitive)
			This.TrimRightCS(pCaseSensitive)
			return This

	def TrimRight()
		This.TrimRightCS(1)

	def TrimmedRight()
		return @oList.Copy().TrimRightCSQ(1).Content()

	  #======================================================#
	 #   TRIM SPECIFIC ITEM                                 #
	#======================================================#

	def TrimItemCS(pItem, pCaseSensitive)
		This.TrimItemFromLeftCS(pItem, pCaseSensitive)
		This.TrimItemFromRightCS(pItem, pCaseSensitive)

		def TrimItemCSQ(pItem, pCaseSensitive)
			This.TrimItemCS(pItem, pCaseSensitive)
			return This

	def TrimItem(pItem)
		This.TrimItemCS(pItem, 1)

		def TrimItemQ(pItem)
			This.TrimItem(pItem)
			return This

	def TrimItemFromLeftCS(pItem, pCaseSensitive)
		if isString(pItem) and pCaseSensitive = 1
			_pTlList = @oList._EngineListFromContent()
			if _pTlList != NULL
				StzEngineListTrimLeadingString(_pTlList, pItem)
				@oList.UpdateWith(@oList._ContentFromEngineList(_pTlList))
				StzEngineListFree(_pTlList)
				return
			ok
		ok
		aContent = This.Content()
		nLen = len(aContent)
		nStart = 0
		for i = 1 to nLen
			if BothAreEqualCS(aContent[i], pItem, pCaseSensitive)
				nStart = i
			else
				exit
			ok
		next
		if nStart > 0
			@oList.RemoveSection(1, nStart)
		ok

	def TrimItemFromLeft(pItem)
		This.TrimItemFromLeftCS(pItem, 1)

	def TrimItemFromRightCS(pItem, pCaseSensitive)
		if isString(pItem) and pCaseSensitive = 1
			_pTrList = @oList._EngineListFromContent()
			if _pTrList != NULL
				StzEngineListTrimTrailingString(_pTrList, pItem)
				@oList.UpdateWith(@oList._ContentFromEngineList(_pTrList))
				StzEngineListFree(_pTrList)
				return
			ok
		ok
		aContent = This.Content()
		nLen = len(aContent)
		nEnd = 0
		for i = nLen to 1 step -1
			if BothAreEqualCS(aContent[i], pItem, pCaseSensitive)
				nEnd = i
			else
				exit
			ok
		next
		if nEnd > 0
			@oList.RemoveSection(nEnd, nLen)
		ok

	def TrimItemFromRight(pItem)
		This.TrimItemFromRightCS(pItem, 1)

	  #======================================================#
	 #   COMPACT (REMOVE ALL EMPTY ITEMS)                    #
	#======================================================#

	def Compact()
		aContent = This.Content()
		nLen = len(aContent)
		aResult = []

		for i = 1 to nLen
			if isString(aContent[i])
				if ring_trim(aContent[i]) != ""
					aResult + aContent[i]
				ok
			but isList(aContent[i])
				if len(aContent[i]) > 0
					aResult + aContent[i]
				ok
			else
				aResult + aContent[i]
			ok
		next

		@oList.Update(aResult)

		def CompactQ()
			This.Compact()
			return This

	def Compacted()
		return @oList.Copy().CompactQ().Content()

	  #======================================================#
	 #   SQUEEZE (REMOVE CONSECUTIVE DUPLICATE EMPTY ITEMS) #
	#======================================================#

	def Squeeze()
		aContent = This.Content()
		nLen = len(aContent)
		if nLen < 2
			return
		ok

		aResult = [ aContent[1] ]
		for i = 2 to nLen
			bEmpty1 = (isString(aContent[i-1]) and ring_trim(aContent[i-1]) = "")
			bEmpty2 = (isString(aContent[i]) and ring_trim(aContent[i]) = "")
			if NOT (bEmpty1 and bEmpty2)
				aResult + aContent[i]
			ok
		next

		@oList.Update(aResult)

		def SqueezeQ()
			This.Squeeze()
			return This

	def Squeezed()
		return @oList.Copy().SqueezeQ().Content()

	  #======================================================#
	 #   STRIP NULLS (REMOVE NULLS AND EMPTY STRINGS)      #
	#======================================================#

	def StripNulls()
		aContent = This.Content()
		nLen = len(aContent)
		aResult = []

		for i = 1 to nLen
			if isString(aContent[i])
				if aContent[i] != "" and aContent[i] != NULL
					aResult + aContent[i]
				ok
			but isNull(aContent[i])
				# skip
			else
				aResult + aContent[i]
			ok
		next

		@oList.Update(aResult)

		def StripNullsQ()
			This.StripNulls()
			return This

	def NullsStripped()
		return @oList.Copy().StripNullsQ().Content()

	  #======================================================#
	 #   TRIM TO SIZE (KEEP ONLY FIRST N ITEMS)            #
	#======================================================#

	def TrimToSize(n)
		aContent = This.Content()
		nLen = len(aContent)
		if n >= nLen
			return
		ok

		aResult = []
		for i = 1 to n
			aResult + aContent[i]
		next

		@oList.Update(aResult)

		def TrimToSizeQ(n)
			This.TrimToSize(n)
			return This

	def TrimmedToSize(n)
		aContent = This.Content()
		nLen = len(aContent)
		if n >= nLen
			return aContent
		ok
		aResult = []
		for i = 1 to n
			aResult + aContent[i]
		next
		return aResult

	  #======================================================#
	 #   TRIM WHERE (REMOVE ITEMS MATCHING CONDITION)       #
	#======================================================#

	def TrimW(pcCondition)
		cNegated = "not (" + _StzStripBraces(pcCondition) + ")"
		aResult = @oList.Filter(cNegated)
		@oList.Update(aResult)

		def TrimWQ(pcCondition)
			This.TrimW(pcCondition)
			return This

	def TrimmedW(pcCondition)
		return @oList.Copy().TrimWQ(pcCondition).Content()
