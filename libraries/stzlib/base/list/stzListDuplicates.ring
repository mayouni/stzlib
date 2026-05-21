#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTDUPLICATES          #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List duplicates subclass -- finding,        #
#                  removing, counting duplicates.               #
#                  For aliases, use stzListDuplicatesXT.        #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzListDuplicates from stzList

	  #===============================#
	 #  FINDING DUPLICATED ITEMS    #
	#===============================#

	def FindDuplicatesCS(pCaseSensitive)
		pList = _EngineListFromContent()
		cResult = StzEngineListFindDuplicatesCS(pList, pCaseSensitive)
		StzEngineListFree(pList)

		if cResult = ""
			return []
		ok

		aParts = StzSplit(cResult, ",")
		nLen = len(aParts)
		anResult = []
		for i = 1 to nLen
			anResult + (0 + aParts[i])
		next
		return anResult

	def FindDuplicates()
		return This.FindDuplicatesCS(1)

	  #===============================#
	 #  DUPLICATED ITEMS            #
	#===============================#

	def DuplicatedItemsCS(pCaseSensitive)
		anPos = This.FindDuplicatesCS(pCaseSensitive)
		aContent = This.Content()
		nLen = len(anPos)

		aResult = []
		for i = 1 to nLen
			aResult + aContent[anPos[i]]
		next

		return aResult

	def DuplicatedItems()
		return This.DuplicatedItemsCS(1)

	  #=====================================#
	 #  REMOVING DUPLICATES               #
	#=====================================#

	def RemoveDuplicatesCS(pCaseSensitive)
		anPos = This.FindDuplicatesCS(pCaseSensitive)
		nLen = len(anPos)

		_oCopy_ = This.Copy()

		for i = nLen to 1 step -1
			_oCopy_.RemoveItemAtPosition(anPos[i])
		next

		This.UpdateWith(_oCopy_.Content())

		def RemoveDuplicatesCSQ(pCaseSensitive)
			This.RemoveDuplicatesCS(pCaseSensitive)
			return This

	def RemoveDuplicates()
		This.RemoveDuplicatesCS(1)

		def RemoveDuplicatesQ()
			This.RemoveDuplicates()
			return This

	  #=====================================#
	 #  WITHOUT DUPLICATION               #
	#=====================================#

	def WithoutDuplicationCS(pCaseSensitive)
		aResult = This.Copy().RemoveDuplicatesCSQ(pCaseSensitive).Content()
		return aResult

	def WithoutDuplication()
		return This.WithoutDuplicationCS(1)

		def WithoutDuplicates()
			return This.WithoutDuplication()

	  #=================================#
	 #  HAS DUPLICATES                #
	#=================================#

	def HasDuplicatesCS(pCaseSensitive)
		anPos = This.FindDuplicatesCS(pCaseSensitive)
		return len(anPos) > 0

	def HasDuplicates()
		return This.HasDuplicatesCS(1)

		def ContainsDuplicates()
			return This.HasDuplicates()

	  #========================================#
	 #  NUMBER OF DUPLICATES                 #
	#========================================#

	def NumberOfDuplicatesCS(pCaseSensitive)
		return len(This.FindDuplicatesCS(pCaseSensitive))

	def NumberOfDuplicates()
		return This.NumberOfDuplicatesCS(1)

	  #=================================================#
	 #  FINDING DUPLICATES OF A SPECIFIC ITEM          #
	#=================================================#

	def FindDuplicatesOfCS(pItem, pCaseSensitive)
		anPos = This.FindAllCS(pItem, pCaseSensitive)
		nLen = len(anPos)

		if nLen <= 1
			return []
		ok

		aResult = []
		for i = 2 to nLen
			aResult + anPos[i]
		next

		return aResult

	def FindDuplicatesOf(pItem)
		return This.FindDuplicatesOfCS(pItem, 1)

	  #=================================================#
	 #  UNIQUE ITEMS (WITHOUT DUPLICATES)              #
	#=================================================#

	def UniqueItemsCS(pCaseSensitive)
		return This.WithoutDuplicationCS(pCaseSensitive)

	def UniqueItems()
		return This.UniqueItemsCS(1)

		def Unique()
			return This.UniqueItems()

	  #========================================#
	 #  FINDING NON DUPLICATED ITEMS         #
	#========================================#

	def FindNonDuplicatedItemsCS(pCaseSensitive)
		pList = _EngineListFromContent()
		cResult = StzEngineListFindNonDuplicatedCS(pList, pCaseSensitive)
		StzEngineListFree(pList)

		if cResult = ""
			return []
		ok

		aParts = StzSplit(cResult, ",")
		nLen = len(aParts)
		anResult = []
		for i = 1 to nLen
			anResult + (0 + aParts[i])
		next
		return anResult

	def FindNonDuplicatedItems()
		return This.FindNonDuplicatedItemsCS(1)

	  #========================================#
	 #  NON DUPLICATED ITEMS                 #
	#========================================#

	def NonDuplicatedItemsCS(pCaseSensitive)
		anPos = This.FindNonDuplicatedItemsCS(pCaseSensitive)
		aContent = This.Content()
		nLen = len(anPos)
		aResult = []
		for i = 1 to nLen
			aResult + aContent[anPos[i]]
		next
		return aResult

	def NonDuplicatedItems()
		return This.NonDuplicatedItemsCS(1)

	  #========================================#
	 #  ITEMS DUPLICATED EXACTLY N TIMES     #
	#========================================#

	def ItemsDuplicatedNTimesCS(n, pCaseSensitive)
		aContent = This.Content()
		nLen = len(aContent)
		nLenC = len(aContent)
		acContent = []
		for _k = 1 to nLenC
			acContent + ("" + aContent[_k])
		next

		if pCaseSensitive = 0
			for i = 1 to nLen
				acContent[i] = StzLower(acContent[i])
			next
		ok

		aSeen = []
		anCounts = []
		for i = 1 to nLen
			cItem = acContent[i]
			nPos = StzFind(aSeen, cItem)
			if nPos > 0
				anCounts[nPos] = anCounts[nPos] + 1
			else
				aSeen + cItem
				anCounts + 1
			ok
		next

		aResult = []
		nSeen = len(aSeen)
		for i = 1 to nSeen
			if anCounts[i] = n
				aResult + aSeen[i]
			ok
		next
		return aResult

	def ItemsDuplicatedNTimes(n)
		return This.ItemsDuplicatedNTimesCS(n, 1)

	  #========================================#
	 #  MOST DUPLICATED ITEM                 #
	#========================================#

	def MostDuplicatedItemCS(pCaseSensitive)
		aContent = This.Content()
		nLen = len(aContent)
		nLenC = len(aContent)
		acContent = []
		for _k = 1 to nLenC
			acContent + ("" + aContent[_k])
		next

		if pCaseSensitive = 0
			for i = 1 to nLen
				acContent[i] = StzLower(acContent[i])
			next
		ok

		aSeen = []
		anCounts = []
		for i = 1 to nLen
			cItem = acContent[i]
			nPos = StzFind(aSeen, cItem)
			if nPos > 0
				anCounts[nPos] = anCounts[nPos] + 1
			else
				aSeen + cItem
				anCounts + 1
			ok
		next

		nMax = 0
		nMaxIdx = 0
		nSeen = len(aSeen)
		for i = 1 to nSeen
			if anCounts[i] > nMax
				nMax = anCounts[i]
				nMaxIdx = i
			ok
		next

		if nMaxIdx > 0
			return aSeen[nMaxIdx]
		ok
		return ""

	def MostDuplicatedItem()
		return This.MostDuplicatedItemCS(1)

	  #========================================#
	 #  REMOVE NTH DUPLICATE                 #
	#========================================#

	def RemoveNthDuplicateCS(n, pItem, pCaseSensitive)
		anPos = This.FindDuplicatesOfCS(pItem, pCaseSensitive)
		if n >= 1 and n <= len(anPos)
			ring_remove(This.List(), anPos[n])
		ok

		def RemoveNthDuplicateCSQ(n, pItem, pCaseSensitive)
			This.RemoveNthDuplicateCS(n, pItem, pCaseSensitive)
			return This

	def RemoveNthDuplicate(n, pItem)
		This.RemoveNthDuplicateCS(n, pItem, 1)
