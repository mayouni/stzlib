
func StzSplitterQ(p)
	return new stzSplitter2(p)

class stzSplitter from stzObject
	@nNumberOfItems

	  #--------------------------------#
	 #    INITIALIZING THE SPLITTER   #
	#--------------------------------#

	def init(p)
		if isNumber(p)

			if p < 0
				stzRaise("p must be positive!") # --> TODO: stzListError
			ok

			@nNumberOfItems = p

		but isList(p)
			@nNumberOfItems = len(p)

		but isString(p)
			@nNumberOfItems = StzStringQ(p).NumberOfChars()

		else
			stzRaise("Unsupported param value!")
		ok

	def NumberOfItems()
		return @nNumberOfItems

	def Content()
		aResult = 1:This.NumberOfItems()
		return aResult

	  #------------------------#
	 #    SPLITTING BEFORE    #
	#------------------------#

	def SplitBefore(p)
		if isNumber(p)
			return This.SplitBeforePositions(p)
		but isList(p) and ListIsListOfNumbers(p)
			return This.SplitBeforeN(p)
		else
			stzRaise("Incorrect param! Provide a number or list of numbers.")
		ok

		def SplitBeforeQR(n, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.SplitBefore(n) )
	
			on :stzListOfLists
				return new stzListOfLists( This.SplitBefore(n) )
	
			other
				stzRaise("Unsupported return type!")
			off

		def SplitBeforeQ(n)
			return This.SplitBeforeQR(n, :stzListOfPairs)

	  #------------------------------------------------#
	 #    SPLITTING BEFORE A GIVEN SET OF POSITIONS   #
	#------------------------------------------------#

	def SplitBeforePositions(panPositions)

		aPairs = This.GetPairsFromPositions(panPositions)

		for i = 1 to len(aPairs) - 1
			aPairs[i][2]--
		next

		return aPairs

		#< @FunctionFluentForm

		def SplitBeforePosistionsQR(panPositions, pcType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcType
			on :stzList
				return new stzList( This.SplitBeforePositions(panPositions) )

			on :stzListOfLists
				return new stzListOfLists( This.SplitBeforePositions(panPositions) )

			other
				return "Unsupported return type!"
			off

		def SplitBeforePositionsQ(panPositions)
			return This.SplitBeforePosistionsQR(panPositions, :stzListOfPairs)

		#>

	  #----------------------------------------#
	 #    SPLITTING BEFORE A GIVEN POSITION   #
	#----------------------------------------#

	def SplitBeforePosition(n)
		return This.SplitBeforePositions([n])

		#< @FunctionFluentForm

		def SplitBeforePositionQR(n, pcType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcType
			on :stzList
				return new stzList( This.SplitBeforePosition(n) )

			on :stzListOfLists
				return new stzListOfLists( This.SplitBeforePosition(n) )

			other
				stzRaise("Unsupported return type!")
			off

		def SplitBeforePositionQ(n)
			return This.SplitBeforePosition(n, :stzListOfPairs)

		#>

		#< @FunctionAlternativeForms

		def SplitBeforeN(n)
			return This.SplitBeforePosition(n)

			def SplitBeforeNQR(n, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.SplitBeforeN(n) )
	
				on :stzListOfLists
					return new stzListOfLists( This.SplitBeforeN(n) )
	
				other
					stzRaise("Unsupported return type!")
				off

			def SplitBeforeNQ(n)
				return This.SplitBeforeNQR(n, :stzListOfPairs)
	
		#>

	  #-----------------------------------------------#
	 #    SPLITTING AFTER A GIVEN SET OF POSITIONS   #
	#-----------------------------------------------#

	def SplitAfterPositions(panPositions)

		aPairs = This.GetPairsFromPositions(panPositions)

		for i = 2 to len(aPairs)
			aPairs[i][1]++
		next

		return aPairs

		#< @FunctionFluentForm

		def SplitAfterPosistionsQR(panPositions, pcType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcType
			on :stzList
				return new stzList( This.SplitAfterPositions(panPositions) )

			on :stzListOfLists
				return new stzListOfLists( This.SplitAfterPositions(panPositions) )

			other
				return "Unsupported return type!"
			off

		def SplitAfterPositionsQ(panPositions)
			return This.SplitAfterPosistionsQR(panPositions, :stzListOfPairs)

		#>

	  #----------------------------------------#
	 #    SPLITTING AFTER A GIVEN POSITION    #
	#----------------------------------------#

	def SplitAfterPosition(n)
		return This.SplitAfterPositions([n])

		#< @FunctionFluentForm

		def SplitAfterPositionQR(n, pcType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcType
			on :stzList
				return new stzList( This.SplitAfterPosition(n) )

			on :stzListOfLists
				return new stzListOfLists( This.SplitAfterPosition(n) )

			other
				stzRaise("Unsupported return type!")
			off

		def SplitAfterPositionQ(n)
			return This.SplitAfterPosition(n, :stzListOfPairs)

		#>

		#< @FunctionAlternativeForms

		def SplitAfterN(n)
			return This.SplitAfterPosition(n)

			def SplitAfterNQR(n, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedParamList()
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.SplitAfterN(n) )
	
				on :stzListOfLists
					return new stzListOfLists( This.SplitAfterN(n) )
	
				other
					stzRaise("Unsupported return type!")
				off

			def SplitAfterNQ(n)
				return This.SplitAfterNQR(n, :stzListOfPairs)
	
		#>

	  #--------------------#
	 #    SPLITTING AT    #
	#--------------------#

	def SplitAt(p)
		if isNumber(p)
			return This.SplitAtPosistion(p)

		but isList(p) and ListIsListOfNumbers(p)
			return This.SplitAtPositions(p)
	
		else
			stzRaise("Unsupported param! You must provide a number or a list of numbers!")
		ok

		#< @FunctionFluentForm

			def SplitAtQR(p, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.SplitAt(p) )
	
				on :stzListOfLists
					return new stzListOfLists( This.SplitAt(p) )
	
				other
					stzRaise("Unsupported return type!")
				off

			def SplitAtQ(n)
				return This.SplitAtNQR(n, :stzListOfPairs)

		#>

	  #--------------------------------------------#
	 #    SPLITTING AT A GIVEN SET OF POSITIONS   #
	#--------------------------------------------#

	def SplitAtPositions(panPositions)

		aPairs = This.GetPairsFromPositions(panPositions)

		for i = 1 to len(aPairs) - 1
			aPairs[i][2]--
			aPairs[i+1][1]++
		next

		return aPairs

		#< @FunctionFluentForm

			def SplitAtPositionsQR(panPositions, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedParamList()
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.SplitAtPositions(panPositions) )
	
				on :stzListOfLists
					return new stzListOfLists( This.SplitAtPositions(panPositions) )
	
				other
					stzRaise("Unsupported return type!")
				off

			def SplitAtPositionsQ(panPositions)
				return This.SplitAtPositionsQR(panPositions, :stzListOfPairs)

		#>

	  #------------------------------------#
	 #    SPLITTING AT A GIVEN POSITION   #
	#------------------------------------#

	def SplitAtPosition(n)
		return This.SplitAtePositions([n])

		#< @FunctionFluentForm

		def SplitAtPositionQR(n, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.SplitAtPosition(n) )
	
			on :stzListOfLists
				return new stzListOfLists( This.SplitAtPosition(n) )
	
			other
				stzRaise("Unsupported return type!")
			off

		def SplitAtPositionQ(n)
			return This.SplitAtPositionQR(n, :stzListOfPairs)

		#>

	  #---------------------------------------#
	 #    SPLITTING UNDER A GIVEN CONDTION   #
	#---------------------------------------#

	def SplitW(pcCondition)
		/*
		? StzSplitterQ(1:5).SplitW('_(@item).@.IsMultipleOf(2)')
		*/

		anPositions = StzListQ(This.Content()).ItemsW(pcCondition)

		return This.SplitBeforeW(anPositions)

		#< @FunctionFluentForms

		def SplitWQR(pcCondition, pcType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcCondition
			on :stzList
				return new stzList( This.SplitW(pcCondition) )
			on :stzListOfList
				return new stzListOfLists( This.SplitW(pcCondition) )
			off

		def SplitWQ(pcCondition)
			return This.SplitWQR(pcCondition, :stzList)

		#>

	def SplitBeforeW(pcCondition)
		anPositions = StzListQ(This.Content()).ItemsW(pcCondition)
		return This.SplitBeforePositions(anPositions)


		#< @FunctionFluentForms

		def SplitBeforeWQR(pcCondition, pcType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcCondition
			on :stzList
				return new stzList( This.SplitBeforeW(pcCondition) )
			on :stzListOfList
				return new stzListOfLists( This.SplitBeforeW(pcCondition) )
			off

		def SplitBeforeWQ(pcCondition)
			return This.SplitBeforeWQR(pcCondition, :stzList)

		#>

	  #---------------------------------------#
	 #    SPLITTING AFTER A GIVEN CONDTION   #
	#---------------------------------------#

	def SplitAfterW(pcCondition)
		return This.SplitAfterPositions(panPositions)

		#< @FunctionFluentFrom

		def SplitAfterWQR(pcCondition, pcType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcCondition
			on :stzList
				return new stzList( This.SplitAfterW(pcCondition) )
			on :stzListOfList
				return new stzListOfLists( This.SplitAfterW(pcCondition) )
			off

		def SplitAfterWQ(pcCondition)
			return This.SplitAfterWQR(pcCondition, :stzListOfPairs)

		#>

	  #------------------------------------#
	 #    SPLITTING AT A GIVEN CONDTION   #
	#------------------------------------#

	def SplitAtW(pcCondition)
		return This.SplitAtPositions(panPositions)

		#< @FunctionFluentFrom

		def SplitatAfterWQR(pcCondition, pcType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcCondition
			on :stzList
				return new stzList( this.SplitAtW(pcCondition) )
			on :stzListOfList
				return new stzListOfLists( This.SplitAtW(pcCondition) )
			off

		def SplitAtWQ(pcCondition)
			return This.SplitAtWQR(pcCondition, :stzListOfPairs)

		#>

	  #------------------------------------#
	 #    SPLITTING TO PARTS OF N ITEMS   #
	#------------------------------------#

	def SplitToPartsOfNItems(n)

		if NOT _(n).@.IsBetween(1, This.NumberOfItems() )
			return [ [] ]

		else
			aResult = []

			for i = 1 to This.NumberOfItems() step n
				nTemp = i + n-1

				if nTemp > This.NumberOfItems()
					nTemp = This.NumberOfItems()
				ok

				aResult + [ i, nTemp ]
			next
	
			return aResult
		ok

		#< @FunctionFluentFrom

		def SplitToPartsOfNItemsQR(n, pcType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcCondition
			on :stzList
				return new stzList( This.SplitToPartsOfNItems(n) )
			on :stzListOfList
				return new stzListOfLists( This.SplitToPartsOfNItems(n) )
			off

		def SplitToPartsOfNItemsQ(n)
			return This.SplitToPartsOfNItems(n, :stzListOfPairs)

		#>

	  #----------------------------#
	 #    SPLITTING TO N PARTS    #
	#----------------------------#

	def SplitToNParts(n)

		if NOT _(n).@.IsBetween(1, This.NumberOfItems() )
			return [ [] ]
		ok

		nLen = 0+ _( This.NumberOfItems() / n ).@.IntegerPart()

		aResult = []

		for i = 1 to n*nLen step nLen
			aResult + [ i, i + nLen-1 ]
		next

		if aResult[ len(aResult) ][2] != This.NumberOfItems()
			aResult[ len(aResult) ][2] = This.NumberOfItems()
		ok

		return aResult

		#< @FunctionFluentFrom

		def SplitToNPartsQR(n, pcType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcCondition
			on :stzList
				return new stzList( This.SplitToNParts(n) )
			on :stzListOfList
				return new stzListOfLists( This.SplitToNParts(n) )
			off

		def SplitToNPartsQ(n)
			return This.SplitToNParts(n, :stzListOfPairs)

		#>

	  #-------------------------------------------------------#
	 #   Utility functions used by the other methods above   #
	#-------------------------------------------------------#

	def GetPairsFromPositions(panPositions)
		/*
		Main list 	--> 1:10
		panPositions	--> [ 3, 6, 8 ]
		List of pairs	--> [ [ 1, 3 ], [ 3, 6 ], [ 6, 8 ], [ 8, 10 ] ]
		*/

		panPositions + This.NumberOfItems()

		# Eliminating doubble positions
		aPos = StzListQ(panPositions).ToSet()

		# Eliminating extreme cases
		aPos = StzListQ(panPositions).RemoveItemsWQ('@item < 1 or @item > ' + This.NumberOfItems()).Content()
		
		if StzListQ(aPos).IsEmpty()
			return [ [] ]
		ok
		
		# Adding 1 and (NumberOfItems()) if inexistant
		if aPos[1] != 1 { aPos + 1 }
		if aPos[len(aPos)] != 10 { aPos + This.NumberOfItems() }
		
		# Sorting the list
		aPos = sort(aPos)
		
		# Getting the pairs of that list
		aPairs = []
		for i = 1 to len(aPos) - 1
			aPairs + [ aPos[i], aPos[i+1] ]
		next

		aPairs = _@(aPairs).RemoveLastItemQ().Content()

		return aPairs

		#< @FunctionFluentFrom

		def GetPairsFromPositionsQR(panPositions, pcType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcCondition
			on :stzList
				return new stzList( This.GetPairsFromPositions(panPositions) )
			on :stzListOfList
				return new stzListOfLists( This.GetPairsFromPositions(panPositions) )
			off

		def GetPairsFromPositionsQ(panPositions)
			return This.GetPairsFromPositions(n, :stzListOfPairs)

		#>


	def ToStzList()
		return StzListQ(This.Content())
