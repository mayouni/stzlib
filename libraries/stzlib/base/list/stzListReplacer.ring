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

class stzListReplacer from stzList

	  #=========================================#
	 #   REPLACING ALL ITEMS WITH A NEW ITEM   #
	#=========================================#

	def ReplaceAllItems(pNewItem)

		_nLen_ = This.NumberOfItems()
		_aContent_ = This.Content()

		for @i = 1 to _nLen_
			_aContent_[@i] = pNewItem
		next

		This.UpdateWith(_aContent_)

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

		anPos = This.FindAllCS(pItem, pCaseSensitive)
		nLen = len(anPos)

		for i = 1 to nLen
			This.ReplaceAnyItemAtPositionCS(anPos[i], pNewItem, pCaseSensitive)
		next

		def ReplaceAllOccurrencesCSQ(pItem, pNewItem, pCaseSensitive)
			This.ReplaceAllOccurrencesCS(pItem, pNewItem, pCaseSensitive)
			return This

		def ReplaceAllCS(pItem, pNewItem, pCaseSensitive)
			This.ReplaceAllOccurrencesCS(pItem, pNewItem, pCaseSensitive)

		def ReplaceCS(pItem, pNewItem, pCaseSensitive)
			if isList(pItem) and StzListQ(pItem).IsEachNamedParam()
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
			if isList(pItem) and StzListQ(pItem).IsEachNamedParam()
				pItem = pItem[2]
			ok
			This.ReplaceAllOccurrences(pItem, pNewItem)

	def AllOccurrencesReplacedCS(pItem, pNewItem, pCaseSensitive)
		aResult = This.Copy().ReplaceAllOccurrencesCSQ(pItem, pNewItem, pCaseSensitive).Content()
		return aResult

	def AllOccurrencesReplaced(pItem, pNewItem)
		return This.AllOccurrencesReplacedCS(pItem, pNewItem, 1)

	  #==================================================#
	 #   REPLACING ANY ITEM AT A GIVEN POSITION         #
	#==================================================#

	def ReplaceAnyItemAtPositionCS(n, pNewItem, pCaseSensitive)
		aContent = This.Content()
		if n >= 1 and n <= len(aContent)
			aContent[n] = pNewItem
			This.UpdateWith(aContent)
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
		nPos = This.FindNthCS(n, pItem, pCaseSensitive)
		if nPos > 0
			This.ReplaceAnyItemAtPosition(nPos, pNewItem)
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
		anPos = This.FindAllCS(pItem, pCaseSensitive)
		nLen = len(anPos)
		if nLen > 0
			This.ReplaceAnyItemAtPosition(anPos[nLen], pNewItem)
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
		nLen = len(paItems)
		for i = 1 to nLen
			This.ReplaceAllOccurrencesCS(paItems[i], pNewItem, pCaseSensitive)
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
		aContent = This.Content()
		nLen = len(aContent)

		if n1 < 1 { n1 = 1 }
		if n2 > nLen { n2 = nLen }

		aResult = []
		for i = 1 to n1 - 1
			aResult + aContent[i]
		next

		nNewLen = len(paNewItems)
		for i = 1 to nNewLen
			aResult + paNewItems[i]
		next

		for i = n2 + 1 to nLen
			aResult + aContent[i]
		next

		This.UpdateWith(aResult)

	def ReplaceSection(n1, n2, paNewItems)
		This.ReplaceSectionCS(n1, n2, paNewItems, 1)
