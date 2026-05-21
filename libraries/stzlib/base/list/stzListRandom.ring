#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTRANDOM              #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List random subclass -- random position     #
#                  selection, random item retrieval, shuffle,   #
#                  and randomization of list content.           #
#                  For aliases, use stzListRandomXT.            #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzListRandom from stzList

	  #===========================================#
	 #   GETTING A RANDOM POSITION IN THE LIST   #
	#===========================================#

	def RandomPosition()
		nResult = ARandomNumberBetween(1, This.NumberOfItems())
		return nResult

		def ARandomPosition()
			return This.RandomPosition()

		def APosition()
			return This.RandomPosition()

		def AnyPosition()
			return This.RandomPosition()

		def AnyRandomPosition()
			return This.RandomPosition()

	  #------------------------------------------------------------------------#
	 #   GETTING A RANDOM POSITION GREATER THAN / LESS THAN THE ONE PROVIDED  #
	#------------------------------------------------------------------------#

	def RandomPositionGreaterThan(n)
		if CheckingParams()
			if NOT isNumber(n)
				StzRaise("Incorrect param type! n must be a number.")
			ok
		ok

		nLen = This.NumberOfItems()

		if n >= nLen
			return 0
		ok

		nResult = ARandomNumberBetween(n + 1, nLen)
		return nResult

	def RandomPositionLessThan(n)
		if CheckingParams()
			if NOT isNumber(n)
				StzRaise("Incorrect param type! n must be a number.")
			ok
		ok

		if n <= 1
			return 0
		ok

		nResult = ARandomNumberBetween(1, n - 1)
		return nResult

	  #------------------------------------------------#
	 #   GETTING A RANDOM POSITION EXCEPT ONE / MANY  #
	#------------------------------------------------#

	def RandomPositionExcept(n)
		if CheckingParams()
			if NOT isNumber(n)
				StzRaise("Incorrect param type! n must be a number.")
			ok
		ok

		nLen = This.NumberOfItems()

		if nLen <= 1
			return 0
		ok

		nResult = n
		while nResult = n
			nResult = ARandomNumberBetween(1, nLen)
		end

		return nResult

	def RandomPositionExceptPositions(panPos)
		if CheckingParams()
			if NOT ( isList(panPos) and @IsListOfNumbers(panPos) )
				StzRaise("Incorrect param type! panPos must be a list of numbers.")
			ok
		ok

		nLen = This.NumberOfItems()
		nLenPos = len(panPos)

		if nLen - nLenPos <= 0
			return 0
		ok

		nResult = panPos[1]
		while StzFind(panPos, nResult) > 0
			nResult = ARandomNumberBetween(1, nLen)
		end

		return nResult

	  #==========================================#
	 #   GETTING N RANDOM POSITIONS IN THE LIST #
	#==========================================#

	def NRandomPositions(n)
		nLen = This.NumberOfItems()
		if n >= nLen
			n = nLen
		ok

		anResult = NUniqueRandomNumbersIn(n, 1:nLen)
		return anResult

		def NRandomPositionsU(n)
			return This.NRandomPositions(n)

	  #=================================#
	 #   GETTING A RANDOM ITEM         #
	#=================================#

	def RandomItem()
		return This.ItemAt( This.RandomPosition() )

		def ARandomItem()
			return This.RandomItem()

		def AnItem()
			return This.RandomItem()

		def AnyItem()
			return This.RandomItem()

		def AnyRandomItem()
			return This.RandomItem()

	  #-----------------------------------------------------#
	 #   GETTING A RANDOM ITEM EXCEPT THE ONE PROVIDED      #
	#-----------------------------------------------------#

	def RandomItemExceptCS(pItem, pCaseSensitive)
		nLen = This.NumberOfItems()

		if nLen <= 1
			StzRaise("Can't get a random item! The list has only one item.")
		ok

		nTries = 0
		result = This.RandomItem()

		while BothAreEqualCS(result, pItem, pCaseSensitive)
			result = This.RandomItem()
			nTries++
			if nTries > 100
				exit
			ok
		end

		return result

	def RandomItemExcept(pItem)
		return This.RandomItemExceptCS(pItem, 1)

		def AnItemOtherThan(pItem)
			return This.RandomItemExcept(pItem)

		def AnItemExcept(pItem)
			return This.RandomItemExcept(pItem)

		def AnyItemOtherThan(pItem)
			return This.RandomItemExcept(pItem)

		def AnyItemExcept(pItem)
			return This.RandomItemExcept(pItem)

	  #-----------------------------------------------------#
	 #   GETTING A RANDOM ITEM EXCEPT AT THE GIVEN POSITION #
	#-----------------------------------------------------#

	def RandomItemExceptPosition(n)
		result = This.ItemAt( This.RandomPositionExcept(n) )
		return result

		def ARandomItemExceptPosition(n)
			return This.RandomItemExceptPosition(n)

		def AnItemExceptPosition(n)
			return This.RandomItemExceptPosition(n)

		def AnItemExceptAt(n)
			return This.RandomItemExceptPosition(n)

	  #=================================#
	 #   GETTING N RANDOM ITEMS        #
	#=================================#

	def NRandomItems(n)
		pList = This._EngineListFromContent()
		pPicked = StzEngineListRandomItems(pList, n)
		if pPicked != NULL
			aResult = StzEngineContentFromList(pPicked)
			StzEngineListFree(pPicked)
		else
			aResult = []
		ok
		StzEngineListFree(pList)
		return aResult

		def SomeItems()
			n = ARandomNumberBetween(1, This.NumberOfItems())
			return This.NRandomItems(n)

	  #================================================#
	 #   RANDOMIZING THE ITEMS POSITIONS IN THE LIST   #
	#================================================#

	def Randomize()
		pList = This._EngineListFromContent()
		StzEngineListShuffle(pList)
		This.UpdateWith( StzEngineContentFromList(pList) )
		StzEngineListFree(pList)

		def RandomizeQ()
			This.Randomize()
			return This

		def Randomise()
			This.Randomize()

			def RandomiseQ()
				This.Randomise()
				return This

		def Shuffle()
			This.Randomize()

			def ShuffleQ()
				This.Shuffle()
				return This

		def RandomizePositions()
			This.Randomize()

			def RandomizePositionsQ()
				This.RandomizePositions()
				return This

	def Randomized()
		aResult = This.Copy().RandomizeQ().Content()
		return aResult

		def Randomised()
			return This.Randomized()

		def Shuffeled()
			return This.Randomized()

	  #---------------------------------------------------------------------#
	 #  RANDOMIZING THE ITEMS POSITIONS IN THE GIVEN SECTION OF THE LIST   #
	#---------------------------------------------------------------------#

	def RandomizeSection(n1, n2)
		if CheckingParams()
			if NOT @BothAreNumbers(n1, n2)
				StzRaise("Incorrect param types! n1 and n2 must be both numbers.")
			ok
		ok

		aContent = This.Content()

		nLen = n2 - n1 + 1
		anPos = NRandomNumbersBetweenU(nLen, n1, n2)
		aItems = This.ItemsAtPositions(anPos)

		j = 0
		for i = n1 to n2
			j++
			aContent[i] = aItems[j]
		next

		This.UpdateWith(aContent)

		def RandomizeSectionQ(n1, n2)
			This.RandomizeSection(n1, n2)
			return This

		def RandomiseSection(n1, n2)
			This.RandomizeSection(n1, n2)

		def ShuffleSection(n1, n2)
			This.RandomizeSection(n1, n2)

	def SectionRandomized(n1, n2)
		aResult = This.Copy().RandomizeSectionQ(n1, n2).Content()
		return aResult

		def SectionRandomised(n1, n2)
			return This.SectionRandomized(n1, n2)

	  #----------------------------------------------------------------------#
	 #  RANDOMIZING THE ITEMS POSITIONS IN THE GIVEN SECTIONS OF THE LIST   #
	#----------------------------------------------------------------------#

	def RandomizeSections(panSections)
		if CheckingParams()
			if NOT ( isList(panSections) and @IsListOfPairsOfNumbers(panSections) )
				StzRaise("Incorrect param type! panSections must be a list of pairs of numbers.")
			ok
		ok

		nLen = len(panSections)
		for i = 1 to nLen
			This.RandomizeSection(panSections[i][1], panSections[i][2])
		next

		def RandomizeSectionsQ(panSections)
			This.RandomizeSections(panSections)
			return This

		def RandomiseSections(panSections)
			This.RandomizeSections(panSections)

		def ShuffleSections(panSections)
			This.RandomizeSections(panSections)

	def SectionsRandomized(panSections)
		aResult = This.Copy().RandomizeSectionsQ(panSections).Content()
		return aResult

		def SectionsRandomised(panSections)
			return This.SectionsRandomized(panSections)

	  #-------------------------------------------------#
	 #  RANDOMIZING THE NUMBERS EXISTING IN THE LIST    #
	#=================================================#

	def RandomizeNumbers()
		aSections = This.FindNumbersAsSections()
		This.RandomizeSections(aSections)

		def RandomizeNumbersQ()
			This.RandomizeNumbers()
			return This

		def RandomiseNumbers()
			This.RandomizeNumbers()

		def ShuffleNumbers()
			This.RandomizeNumbers()

	def NumbersRandomized()
		aResult = This.Copy().RandomizeNumbersQ().Content()
		return aResult

		def NumbersRandomised()
			return This.NumbersRandomized()

		def NumbersShuffled()
			return This.NumbersRandomized()

	  #-------------------------------------------------#
	 #  RANDOMIZING THE STRINGS EXISTING IN THE LIST    #
	#=================================================#

	def RandomizeStrings()
		aSections = This.FindStringsAsSections()
		This.RandomizeSections(aSections)

		def RandomizeStringsQ()
			This.RandomizeStrings()
			return This

		def RandomiseStrings()
			This.RandomizeStrings()

		def ShuffleStrings()
			This.RandomizeStrings()

	def StringsRandomized()
		aResult = This.Copy().RandomizeStringsQ().Content()
		return aResult

		def StringsRandomised()
			return This.StringsRandomized()

		def StringsShuffled()
			return This.StringsRandomized()

	  #-------------------------------------------------#
	 #  RANDOMIZING THE LISTS EXISTING IN THE LIST      #
	#=================================================#

	def RandomizeLists()
		aSections = This.FindListsAsSections()
		This.RandomizeSections(aSections)

		def RandomizeListsQ()
			This.RandomizeLists()
			return This

		def RandomiseLists()
			This.RandomizeLists()

		def ShuffleLists()
			This.RandomizeLists()

	def ListsRandomized()
		aResult = This.Copy().RandomizeListsQ().Content()
		return aResult

		def ListsRandomised()
			return This.ListsRandomized()

		def ListsShuffled()
			return This.ListsRandomized()

	  #-------------------------------------------------#
	 #  RANDOMIZING THE OBJECTS EXISTING IN THE LIST    #
	#=================================================#

	def RandomizeObjects()
		aSections = This.FindObjectsAsSections()
		This.RandomizeSections(aSections)

		def RandomizeObjectsQ()
			This.RandomizeObjects()
			return This

		def RandomiseObjects()
			This.RandomizeObjects()

		def ShuffleObjects()
			This.RandomizeObjects()

	def ObjectsRandomized()
		aResult = This.Copy().RandomizeObjectsQ().Content()
		return aResult

		def ObjectsRandomised()
			return This.ObjectsRandomized()

		def ObjectsShuffled()
			return This.ObjectsRandomized()
