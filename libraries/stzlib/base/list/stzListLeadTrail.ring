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

class stzListLeadTrail from stzList

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
		aLead = This.RepeatedLeadingItemsCS(pCaseSensitive)
		nToRemove = len(aLead) - 1
		if nToRemove > 0
			This.RemoveSection(1, nToRemove)
		ok

	def RemoveRepeatedLeadingItems()
		This.RemoveRepeatedLeadingItemsCS(1)

	def RemoveRepeatedTrailingItemsCS(pCaseSensitive)
		aTrail = This.RepeatedTrailingItemsCS(pCaseSensitive)
		nToRemove = len(aTrail) - 1
		nLen = This.NumberOfItems()
		if nToRemove > 0
			This.RemoveSection(nLen - nToRemove + 1, nLen)
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
		return This.Copy().RemoveRepeatedLeadingItemsCSQ(pCaseSensitive).Content()

	def RepeatedLeadingItemsRemoved()
		return This.RepeatedLeadingItemsRemovedCS(1)

	def RepeatedTrailingItemsRemovedCS(pCaseSensitive)
		return This.Copy().RemoveRepeatedTrailingItemsCSQ(pCaseSensitive).Content()

	def RepeatedTrailingItemsRemoved()
		return This.RepeatedTrailingItemsRemovedCS(1)

	  #======================================================#
	 #   STARTS WITH / ENDS WITH                            #
	#======================================================#

	def StartsWithCS(pItem, pCaseSensitive)
		if This.NumberOfItems() = 0
			return 0
		ok
		return BothAreEqualCS(This.List()[1], pItem, pCaseSensitive)

	def StartsWith(pItem)
		return This.StartsWithCS(pItem, 1)

	def EndsWithCS(pItem, pCaseSensitive)
		if This.NumberOfItems() = 0
			return 0
		ok
		nLen = This.NumberOfItems()
		return BothAreEqualCS(This.List()[nLen], pItem, pCaseSensitive)

	def EndsWith(pItem)
		return This.EndsWithCS(pItem, 1)
