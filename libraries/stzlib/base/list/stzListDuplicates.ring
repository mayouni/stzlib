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

class stzListDuplicates

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
			StzRaise("Can't create stzListDuplicates! Parameter must be a list or stzList object.")
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

	def Copy()
		return new stzListDuplicates( @oList.Content() )

	def UpdateWith(paNewContent)
		@oList.UpdateWith(paNewContent)

	def List()
		return @oList.List()

	def RemoveItemAtPosition(n)
		@oList.RemoveItemAtPosition(n)

	def FindAllCS(pItem, pCaseSensitive)
		return @oList.FindAllCS(pItem, pCaseSensitive)

	  #===============================#
	 #  FINDING DUPLICATED ITEMS    #
	#===============================#

	def FindDuplicatesCS(pCaseSensitive)
		pList = @oList._EngineListFromContent()
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
		# Engine-backed deduplication
		pList = @oList._EngineListFromContent()
		StzEngineListRemoveDuplicatesCS(pList, pCaseSensitive)
		This.UpdateWith(@oList._ContentFromEngineList(pList))
		StzEngineListFree(pList)

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

		def ContainsDuplicatedItems()
			return This.HasDuplicates()

		def ContainsDuplicatedItemsCS(pCaseSensitive)
			return This.HasDuplicatesCS(pCaseSensitive)

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
		pList = @oList._EngineListFromContent()
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
		pList = @oList._EngineListFromContent()
		pFreqs = StzEngineListFrequenciesCS(pList, pCaseSensitive)
		StzEngineListFree(pList)

		aRaw = StzEngineContentFromList(pFreqs)
		StzEngineListFree(pFreqs)

		nLen = len(aRaw)
		aResult = []
		i = 1
		for _k = 1 to nLen / 2
			cKey = aRaw[i]
			nCount = aRaw[i + 1]
			if nCount = n
				aResult + cKey
			ok
			i += 2
		next
		return aResult

	def ItemsDuplicatedNTimes(n)
		return This.ItemsDuplicatedNTimesCS(n, 1)

	  #========================================#
	 #  MOST DUPLICATED ITEM                 #
	#========================================#

	def MostDuplicatedItemCS(pCaseSensitive)
		pList = @oList._EngineListFromContent()
		pFreqs = StzEngineListFrequenciesCS(pList, pCaseSensitive)
		StzEngineListFree(pList)

		aRaw = StzEngineContentFromList(pFreqs)
		StzEngineListFree(pFreqs)

		nLen = len(aRaw)
		nMax = 0
		cResult = ""
		i = 1
		for _k = 1 to nLen / 2
			cKey = aRaw[i]
			nCount = aRaw[i + 1]
			if nCount > nMax
				nMax = nCount
				cResult = cKey
			ok
			i += 2
		next
		return cResult

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
