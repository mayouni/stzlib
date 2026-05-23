#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTSPLITS              #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List splits subclass -- split-finding       #
#                  operations. All canonical methods delegate   #
#                  to stzSplitter for the actual computation.   #
#                  For aliases, use stzListSplitsXT.            #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzListSplits

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
			StzRaise("Can't create stzListSplits! Parameter must be a list or stzList object.")
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

	  #========================================#
	 #    SPLITTING : THE GENERIC FUNCTION    #
	#========================================#

	def SplitXT(p)
		anPos = StzSplitterQ(This.NumberOfItems()).SplitXT(p)
		aResult = @oList.PositionsAt(anPos)
		@oList.UpdateWith( aResult )

		def SplitXTQ(p)
			This.SplitXT(p)
			return This

	def SplittedXT(p)
		aResult = @oList.Copy().SplitXTQ(p).Content()
		return aResult

		def SplitsXT()
			return This.SplittedXT(p)

	def SplitAsSectionsXT(p)
		aSections = This.SplitXT(p)
		nLen = len(aSections)

		aResult = []

		for i = 1 to nLen
			nLenTemp = len(aSections[i])
			aResult + [ aSections[i][1], aSections[i][nLenTemp] ]
		next

		@oList.UpdateWith(aResult)

		def SplitAtSectionsXTQ(p)
			This.SplitAtSectionsXT(p)
			return This

		def SplitXTZZ(p)
			This.SplitAsSectionsXT(p)

			def SplitXTZZQ(p)
				return This.SplitAtSectionsXTQ(p)

	def SplittedAsSectionsXT(p)
		aResult = @oList.Copy().SplitAsSectionsQ(p).Content()
		return aResult

		def SplittedXTZZ(p)
			return This.SplittedAsSectionsXT(p)

		def SplitsAsSectionsXT(p)
			return This.SplittedAsSectionsXT(p)

		def SplitsXTZZ(p)
			return This.SplittedAsSectionsXT(p)

	  #----------------------------------------#
	 #  SPLITTING THE LIST -- A GENERAL FORM  #
	#========================================#

	def SplitCS(pItemOrPos, pCaseSensitive)

		if isList(pItemOrPos)

			if len(pItemOrPos) = 2 and isString(pItemOrPos[1]) and

			   ( pItemOrPos[1] = :At or
			     pItemOrPos[1] = :AtPosition )

				return This.SplitAtCS(pItemOrPos[2], pCaseSensitive)
			ok

			if len(pItemOrPos) = 2 and isString(pItemOrPos[1]) and
			   ( pItemOrPos[1] = :Before or
			     pItemOrPos[1] = :BeforePosition )

				return This.SplitBeforeCS(pItemOrPos[2], pCaseSensitive)
			ok

			if len(pItemOrPos) = 2 and isString(pItemOrPos[1]) and
			   ( pItemOrPos[1] = :After or
			     pItemOrPos[1] = :AfterPosition )

				return This.SplitAfterCS(pItemOrPos[2], pCaseSensitive)
			ok

		ok

		return This.SplitAtCS(pItemOrPos, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def Split(pItemOrPos)
		return This.SplitCS(pItemOrPos, 1)

		def SplitQ(pItemOrPos)
			This.Split(pItemOrPos)
			return This

	  #=====================================================#
	 #  SPLITTING AT POSITIONS -- THE FOUNDATIONAL METHOD  #
	#=====================================================#

	def SplitAtPositions(panPos)
		aSplitPositions = StzSplitterQ( This.NumberOfItems() ).SplitAtPositions(panPos)

		aResult = []
		nLen = len(aSplitPositions)

		for i = 1 to nLen
			aResult + @oList.ItemsAtPositions(aSplitPositions[i])
		next

		@oList.UpdateWith(aResult)

		def SplitAtPositionsQ(panPos)
			This.SplitAtPositions(panPos)
			return This

		def SplitAtThesePositions(panPos)
			This.SplitAtPositions(panPos)

			def SplitAtThesePositionsQ(panPos)
				This.SplitAtThesePositions(panPos)
				return This

	def SplittedAtPositions(panPos)
		aResult = @oList.Copy().SplitAtPositionsQ(panPos).Content()
		return aResult

		def SplittedAtThesePositions(panPos)
			return This.SplittedAtPositions(panPos)

	  #-----------------------------------------------------#
	 #  SPLITTING AT POSITIONS -- ZZ/EXTENDED (AS SECTIONS) #
	#-----------------------------------------------------#

	def SplitAtPositionsZZ(panPos)
		aSections = StzSplitterQ( This.NumberOfItems() ).SplitAtPositionsZZ(panPos)
		@oList.UpdateWith(aSections)

		def SplitAtPositionsZZQ(panPos)
			This.SplitAtPositionsZZ(panPos)
			return This

		def SplitAtPositionsAsSections(panPos)
			This.SplitAtPositionsZZ(panPos)

		def SplitAtThesePositionsZZ(panPos)
			This.SplitAtPositionsZZ(panPos)

		def SplitAtThesePositionsAsSections(panPos)
			This.SplitAtPositionsZZ(panPos)

	def SplittedAtPositionsZZ(panPos)
		aResult = @oList.Copy().SplitAtPositionsZZQ(panPos).Content()
		return aResult

		def SplittedAtPositionsAsSections(panPos)
			return This.SplittedAtPositionsZZ(panPos)

		def SplittedAtThesePositionsZZ(panPos)
			return This.SplittedAtPositionsZZ(panPos)

		def SplittedAtThesePositionsAsSections(panPos)
			return This.SplittedAtPositionsZZ(panPos)

	  #==================================#
	 #  SPLITTING AT A GIVEN POSITION   #
	#==================================#

	def SplitAtPosition(n)
		This.SplitAtPositions([n])

		def SplitAtPositionQ(n)
			This.SplitAtPosition(n)
			return This

	def SplittedAtPosition(n)
		aResult = @oList.Copy().SplitAtPositionQ(n).Content()
		return aResult

	def SplitAtPositionZZ(n)
		This.SplitAtPositionsZZ([n])

		def SplitAtPositionZZQ(n)
			This.SplitAtPositionZZ(n)
			return This

		def SplitAtPositionAsSections(n)
			This.SplitAtPositionZZ(n)

	def SplittedAtPositionZZ(n)
		aResult = @oList.Copy().SplitAtPositionZZQ(n).Content()
		return aResult

		def SplittedAtPositionAsSections(n)
			return This.SplittedAtPositionZZ(n)

	  #================================#
	 #  SPLITTING AT A GIVEN ITEM     #
	#================================#

	def SplitAtCS(pItem, pCaseSensitive)
		if isNumber(pItem)
			This.SplitAtPosition(pItem)
		else
			anPos = @oList.FindAllCS(pItem, pCaseSensitive)
			This.SplitAtPositions(anPos)
		ok

		def SplitAtCSQ(pItem, pCaseSensitive)
			This.SplitAtCS(pItem, pCaseSensitive)
			return This

	def SplitAt(pItem)
		return This.SplitAtCS(pItem, 1)

		def SplitAtQ(pItem)
			This.SplitAt(pItem)
			return This

	def SplittedAtCS(pItem, pCaseSensitive)
		aResult = @oList.Copy().SplitAtCSQ(pItem, pCaseSensitive).Content()
		return aResult

	def SplittedAt(pItem)
		return This.SplittedAtCS(pItem, 1)

	def SplitAtCSZZ(pItem, pCaseSensitive)
		if isNumber(pItem)
			This.SplitAtPositionZZ(pItem)
		else
			anPos = @oList.FindAllCS(pItem, pCaseSensitive)
			This.SplitAtPositionsZZ(anPos)
		ok

		def SplitAtCSZZQ(pItem, pCaseSensitive)
			This.SplitAtCSZZ(pItem, pCaseSensitive)
			return This

		def SplitAtAsSectionsCS(pItem, pCaseSensitive)
			This.SplitAtCSZZ(pItem, pCaseSensitive)

	def SplitAtZZ(pItem)
		return This.SplitAtCSZZ(pItem, 1)

		def SplitAtAsSections(pItem)
			return This.SplitAtZZ(pItem)

	def SplittedAtCSZZ(pItem, pCaseSensitive)
		aResult = @oList.Copy().SplitAtCSZZQ(pItem, pCaseSensitive).Content()
		return aResult

		def SplittedAtAsSectionsCS(pItem, pCaseSensitive)
			return This.SplittedAtCSZZ(pItem, pCaseSensitive)

	def SplittedAtZZ(pItem)
		return This.SplittedAtCSZZ(pItem, 1)

		def SplittedAtAsSections(pItem)
			return This.SplittedAtZZ(pItem)

	  #======================================#
	 #  SPLITTING BEFORE A GIVEN POSITION   #
	#======================================#

	def SplitBeforePosition(n)
		aSplitPositions = StzSplitterQ( This.NumberOfItems() ).SplitBeforePosition(n)

		aResult = []
		nLen = len(aSplitPositions)

		for i = 1 to nLen
			aResult + @oList.ItemsAtPositions(aSplitPositions[i])
		next

		@oList.UpdateWith(aResult)

		def SplitBeforePositionQ(n)
			This.SplitBeforePosition(n)
			return This

	def SplittedBeforePosition(n)
		aResult = @oList.Copy().SplitBeforePositionQ(n).Content()
		return aResult

	  #===================================#
	 #  SPLITTING BEFORE A GIVEN ITEM    #
	#===================================#

	def SplitBeforeCS(pItem, pCaseSensitive)
		if isNumber(pItem)
			This.SplitBeforePosition(pItem)
		else
			anPos = @oList.FindAllCS(pItem, pCaseSensitive)
			nLen = len(anPos)
			for i = 1 to nLen
				This.SplitBeforePosition(anPos[i])
			next
		ok

		def SplitBeforeCSQ(pItem, pCaseSensitive)
			This.SplitBeforeCS(pItem, pCaseSensitive)
			return This

	def SplitBefore(pItem)
		return This.SplitBeforeCS(pItem, 1)

		def SplitBeforeQ(pItem)
			This.SplitBefore(pItem)
			return This

	  #=====================================#
	 #  SPLITTING AFTER A GIVEN POSITION   #
	#=====================================#

	def SplitAfterPosition(n)
		aSplitPositions = StzSplitterQ( This.NumberOfItems() ).SplitAfterPosition(n)

		aResult = []
		nLen = len(aSplitPositions)

		for i = 1 to nLen
			aResult + @oList.ItemsAtPositions(aSplitPositions[i])
		next

		@oList.UpdateWith(aResult)

		def SplitAfterPositionQ(n)
			This.SplitAfterPosition(n)
			return This

	def SplittedAfterPosition(n)
		aResult = @oList.Copy().SplitAfterPositionQ(n).Content()
		return aResult

	  #=================================#
	 #  SPLITTING AFTER A GIVEN ITEM   #
	#=================================#

	def SplitAfterCS(pItem, pCaseSensitive)
		if isNumber(pItem)
			This.SplitAfterPosition(pItem)
		else
			anPos = @oList.FindAllCS(pItem, pCaseSensitive)
			nLen = len(anPos)
			for i = 1 to nLen
				This.SplitAfterPosition(anPos[i])
			next
		ok

		def SplitAfterCSQ(pItem, pCaseSensitive)
			This.SplitAfterCS(pItem, pCaseSensitive)
			return This

	def SplitAfter(pItem)
		return This.SplitAfterCS(pItem, 1)

		def SplitAfterQ(pItem)
			This.SplitAfter(pItem)
			return This

	  #==============================#
	 #  SPLITTING TO N EQUAL PARTS  #
	#==============================#

	def SplitToNParts(n)
		aSplitPositions = StzSplitterQ( This.NumberOfItems() ).SplitToNParts(n)

		aResult = []
		nLen = len(aSplitPositions)

		for i = 1 to nLen
			aResult + @oList.ItemsAtPositions(aSplitPositions[i])
		next

		@oList.UpdateWith(aResult)

		def SplitToNPartsQ(n)
			This.SplitToNParts(n)
			return This

	def SplittedToNParts(n)
		aResult = @oList.Copy().SplitToNPartsQ(n).Content()
		return aResult

	  #=================================#
	 #  SPLITTING TO PARTS OF N ITEMS  #
	#=================================#

	def SplitToPartsOfNItems(n)
		aSplitPositions = StzSplitterQ( This.NumberOfItems() ).SplitToPartsOfNItems(n)

		aResult = []
		nLen = len(aSplitPositions)

		for i = 1 to nLen
			aResult + @oList.ItemsAtPositions(aSplitPositions[i])
		next

		@oList.UpdateWith(aResult)

		def SplitToPartsOfNItemsQ(n)
			This.SplitToPartsOfNItems(n)
			return This

		def SplitToPartsOf(n)
			This.SplitToPartsOfNItems(n)

			def SplitToPartsOfQ(n)
				This.SplitToPartsOf(n)
				return This

	def SplittedToPartsOfNItems(n)
		aResult = @oList.Copy().SplitToPartsOfNItemsQ(n).Content()
		return aResult

		def SplittedToPartsOf(n)
			return This.SplittedToPartsOfNItems(n)

	  #===================================#
	 #  SPLITTING USING A GIVEN PACER    #
	#===================================#

	def SplitAtPacer(nPace, nStart)
		aSplitPositions = StzSplitterQ( This.NumberOfItems() ).SplitAtPacer(nPace, nStart)

		aResult = []
		nLen = len(aSplitPositions)

		for i = 1 to nLen
			aResult + @oList.ItemsAtPositions(aSplitPositions[i])
		next

		@oList.UpdateWith(aResult)

		def SplitAtPacerQ(nPace, nStart)
			This.SplitAtPacer(nPace, nStart)
			return This

	def SplittedAtPacer(nPace, nStart)
		aResult = @oList.Copy().SplitAtPacerQ(nPace, nStart).Content()
		return aResult

	  #===============================#
	 #  SPLITTING USING A CONDITION  #
	#===============================#

	def SplitW(pcCondition)
		anPos = @oList.FindW(pcCondition)
		This.SplitAtPositions(anPos)

		def SplitWQ(pcCondition)
			This.SplitW(pcCondition)
			return This

	def SplittedW(pcCondition)
		aResult = @oList.Copy().SplitWQ(pcCondition).Content()
		return aResult

	def SplitWXT(pcCondition)
		anPos = @oList.FindWXT(pcCondition)
		This.SplitAtPositions(anPos)

		def SplitWXTQ(pcCondition)
			This.SplitWXT(pcCondition)
			return This

	def SplittedWXT(pcCondition)
		aResult = @oList.Copy().SplitWXTQ(pcCondition).Content()
		return aResult
