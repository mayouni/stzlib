
/*
This class is a numrical solution to splitting things.

A splitter recieves a number N positions. If it is a list then its
number of items is considered as N.

Then the splitter initializes an internal list of numbers from 1 to N.

Then the several splitting features are provided (see class methods).

Each of these methods returns a list pof sections (as pairs of numbers).

In practice, stzSplitter is called from inside a stzString or stzList. In this
case, the returned sections are passed to stzString.Sections() or stzList.Sections()
to provide us with the splitted parts of the string or the list.
	
*/

func StzSplitterQ(p)
	return new stzSplitter(p)

class stzSplitter
	@nNumberOfPositions

	  #--------------------------------#
	 #    INITIALIZING THE SPLITTER   #
	#--------------------------------#

	def init(n)
		if isNumber(n)

			if n < 0
				StzRaise("p must be positive!") # --> TODO: stzListError
			ok

			@nNumberOfPositions = n

		but isList(n) and Q(n).IsListOfNumbers() and
		    Q(n).IsContiguous() and n[1] = 1

			@nNumberOfPositions = len(n)

		else
			StzRaise("Incorrect param type! n must be a number.")
		ok

	def NumberOfPositions()
		return @nNumberOfPositions

		def NumberOfItems()
			return This.NumberOfPositions()

	def Content()
		aResult = 1:This.NumberOfPositions()
		return aResult

	  #========================================#
	 #    SPLITTING : THE GENERIC FUNCTION    #
	#========================================#

	def Split(p)
	
		if isList(p)

			if len(p) = 2 and
			   isString(p[1]) and
			   Q(p[1]).IsOneOfTheseCS([
				:At, :AtPosition, :AtPositions,
				:Before, :BeforePosition, :BeforePositions,
				:After, :AfterPosition, :AfterPositions,
				:ToPartsOfNItems, :ToPartsOfExactlyNItems,
				:ToNParts
			   ], :CS = FALSE)
	
				cTemp = Q(p[1]).Lowercased()

				switch cTemp
	
				#--
				on :At
					return This.SplitAt(p[2])
				
				on :AtPosition
					return This.SplitAtPosition(p[2])

				on :AtPositions
					return This.SplitAtPositions(p[2])

				#--
				on :Before
					return This.SplitBefore(p[2])
				
				on :BeforePosition
					return This.SplitBeforePosition(p[2])

				on :BeforePositions
					return This.SplitBeforePositions(p[2])

				#--
				on :After
					return This.SplitAfter(p[2])
				
				on :BeforePosition
					return This.SplitAfterPosition(p[2])

				on :BeforePositions
					return This.SplitAfterPositions(p[2])

				#--
				on :ToPartsOfNItems
					return This.SplitToPartsOfNItems(p[2])

				on :ToPartsOfExactlyNItems
					return This.SplitToPartsOfExactlyNItems(p[2])
	
				on :ToNParts
					return This.SplitToNParts(p[2])

				off
			else

				if Q(p).AllItemsAreNumbers()
					return This.SplitAtPositions(p)
				else
					StzRaise("Incorrect param type! p must be a number or list of numbers.")
				ok
			ok
			
		else

			return This.SplitAt(p)
		ok

	  #====================#
	 #    SPLITTING AT    #
	#====================#

	def SplitAt(n)

		if isList(n) and Q(n).IsListOfNumbers()
			return This.SplitAtPositions(n)
		ok

		if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		nLen = This.NumberOfPositions()

		if n > 1 and n < nLen
			aResult = [ [ 1, n-1], [n+1, nLen ] ]
		else
			aResult = This.Content()
		ok

		return aResult

		#< @FunctionAlternativeForm

		def SplitAtPosition(n)
			return This.SplitAt(n)

		#>

	  #---------------------------------#
	 #   SPLITTING AT MANY POSITIONS   #
	#---------------------------------#

	def SplitAtPositions(panPositions)

		aPairs = This.GetPairsFromPositions(panPositions)

		for i = 1 to len(aPairs) - 1
			aPairs[i][2]--
			aPairs[i+1][1]++
		next

		return aPairs

	  #========================#
	 #    SPLITTING BEFORE    #
	#========================#

	def SplitBefore(n)
		if isList(n)
			if Q(n).IsWhereNamedParam()
				return This.SplitBeforeW(n)

			else
				return This.SplitBeforePositions(n)
			ok
		ok

		nLen = This.NumberOfPositions()

		if n > 1 and n < nLen
			aResult = [ [ 1, n-1], [n, nLen ] ]
		else
			aResult = This.Content()
		ok

		return aResult

		def SplitBeforePosition(n)
			return This.SplitBefore(n)

	  #-------------------------------------#
	 #   SPLITTING BEFORE MANY POSITIONS   #
	#-------------------------------------#

	def SplitBeforePositions(panPositions)

		aPairs = This.GetPairsFromPositions(panPositions)
		/*
		Main list 	 --> 1:10
		panPositions	 --> [ 3, 6, 8 ]
		List of pairs	 --> [ [ 1, 3 ], [ 3, 6 ], [ 6, 8 ], [ 8, 10 ] ]
		Eexpected result --> [ [ 1, 2 ], [ 3, 5 ], [ 6, 7 ], [ 8, 10 ] ]

		- We should leave the last pair as is
		- For all the others, just retrived 1 from aPair[2]
		*/

		nLen = len(aPairs)
		aResult = []

		for i = 1 to nLen - 1
			n1 = aPairs[i][1]
			n2 = aPairs[i][2] - 1

			aResult + [ n1, n2 ]
		next

		aLastPair = aPairs[nLen]
		aResult + [ aLastPair[1], aLastPair[2] ]

		return aResult

	  #=======================#
	 #    SPLITTING AFTER    #
	#=======================#

	def SplitAfter(n)
		if isList(n)
			if Q(n).IsWhereNamedParam()
				return This.SplitAfterW(n)

			else
				return This.SplitAfterPositions(n)
			ok
		ok

		nLen = This.NumberOfPositions()

		if n > 1 and n < nLen
			aResult = [ [ 1, n], [n+1, nLen ] ]
		else
			aResult = This.Content()
		ok

		return aResult

		def SplitAfterPosition(n)
			return This.SplitAfter(n)

	def SplitAfterPositions(panPositions)

		aPairs = This.GetPairsFromPositions(panPositions)
		/*
		Main list 	 --> 1:10
		panPositions	 --> [ 3, 6, 8 ]
		List of pairs	 --> [ [ 1, 3 ], [ 3, 6 ], [ 6, 8 ], [ 8, 10 ] ]
		Eexpected result --> [ [ 1, 3 ], [ 4, 6 ], [ 7, 9 ], [ 9, 10 ] ]

		- We should leave the first pair as is
		- For all the others, just retrived 1 to aPair[1]
		*/

		nLen = len(aPairs)
		
		aFirstPair = aPairs[1]
		aResult = [ [ aFirstPair[1], aFirstPair[2] ] ]

		for i = 2 to nLen
			n1 = aPairs[i][1] + 1
			n2 = aPairs[i][2]

			aResult + [ n1, n2 ]
		next

		return aResult

	  #=======================================#
	 #    SPLITTING UNDER A GIVEN CONDTION   #
	#=======================================#

	def SplitW(pcCondition)
		/*
		? StzSplitterQ(1:5).SplitW('Q(@item).IsMultipleOf(2)')
		*/

		if isList(pcCondition)

			if Q(pcCondition).IsWhereNamedParam()
				return This.SplitAtW(pcCondition[2])

			but Q(pcCondition).IsAtNamedParam()
				return This.SplitAtW(pcCondition[2])

			but Q(pcCondition).IsBeforeNamedParam()
				return This.SplitBeforeW(pcCondition[2])

			but Q(pcCondition).IsAfterNamedParam()
				return This.SplitAfterW(pcCondition[2])

			ok
		
		else
			return This.SplitAtW(pcCondition)
		ok

	  #------------------------------------#
	 #    SPLITTING AT A GIVEN CONDTION   #
	#------------------------------------#

	def SplitAtW(pcCondition)
		cCondition = ""

		if isString(pcCondition)
			cCondition = pcCondition

		but isList(pcCondition)
			cCondition = pcCondition[2]
		ok

		cCondition = Q(cCondition).ReplaceCSQ("@position", :By = "@item", :CS = FALSE).Content()

		anPositions = StzListQ(This.Content()).ItemsW(cCondition)
		return This.SplitAtPositions(anPositions)

	  #----------------------------------------#
	 #    SPLITTING BEFORE A GIVEN CONDTION   #
	#----------------------------------------#

	def SplitBeforeW(pcCondition)
		if isList(pcCondition) and Q(pcCondition).IsBeforeNamedParam()
			pcCondition = pcCondition[2]
		ok

		anPositions = StzListQ(This.Content()).ItemsW(pcCondition)
		return This.SplitBeforePositions(anPositions)

	  #---------------------------------------#
	 #    SPLITTING AFTER A GIVEN CONDTION   #
	#---------------------------------------#

	def SplitAfterW(pcCondition)
		if isList(pcCondition) and Q(pcCondition).IsBeforeNamedParam()
			pcCondition = pcCondition[2]
		ok

		anPositions = StzListQ(This.Content()).ItemsW(pcCondition)
		return This.SplitAfterPositions(anPositions)

	  #===================================#
	 #   SPLITTING TO PARTS OF N ITEMS   #
	#===================================#

	def SplitToPartsOfNPositions(n)

		nLen = This.NumberOfPositions()

		if NOT ( ( isNumber(n) ) and Q(n).IsBetween(1, nLen ) )
			return [ [] ]

		else
			aResult = []

			for i = 1 to nLen step n
				nTemp = i + n-1

				if nTemp > nLen
					nTemp = nLen
				ok

				aResult + [ i, nTemp ]
			next
	
			return aResult
		ok

		#< @FunctionAlternativeForm

		def SplitToPartsOfN(n)
			return This.SplitToPartsOfNPositions(n)

		def SplitToPartsOf(n)
			return This.SplitToPartsOfNPositions(n)

		def SplitToPartsOfNItems(n)
			return This.SplitToPartsOfNPositions(n)

		#>

	  #-------------------------------------------------#
	 #    SPLITTING TO PARTS OF N ITEMS -- EXTENDED    #
	#-------------------------------------------------#

	def SplitToPartsOfNPositionsXT(n, bExcludeRemainingPart)
		aSections = This.SplitToPartsOfNPositions(n)
		
		nLen = len(aSections)
		aLastPair = aSections[ nLen ]

		if (aLastPair[2] - aLastPair[1] + 1) != n
			del( aSections, nLen )
		ok

		return aSections

		def SplitToPartsOfNItemsXT(n, bExcludeRemainingPart)
			return This.SplitToPartsOfNPositionsXT(n, bExcludeRemainingPart)

	def SplitToPartsOfExactlyNPositions(n)
		return This.SplitToPartsOfNPositionsXT(n, :ExcludeRemainingPart = TRUE)

		def SplitToPartsOfExactlyNItems(n)
			return This.SplitToPartsOfNPositionsXT(n, :ExcludeRemainingPart = TRUE)

	  #----------------------------#
	 #    SPLITTING TO N PARTS    #
	#----------------------------#

	def SplitToNParts(n)

		nNumberOfPositions = This.NumberOfPositions()

		if NOT Q(n).IsBetween(1, nNumberOfPositions )
			return [ [] ]
		ok

		nLen =  ( nNumberOfPositions - ( nNumberOfPositions % n ) ) / n
		# Replace with the following when ready:
		# nLen = 0+ Q( This.NumberOfItems() / n ).IntegerPart()

		aResult = []

		for i = 1 to n*nLen step nLen
			aResult + [ i, i + nLen-1 ]
		next

		if aResult[ len(aResult) ][2] != nNumberOfPositions
			aResult[ len(aResult) ][2] = nNumberOfPositions
		ok

		return aResult

	  #=======================================================#
	 #   Utility functions used by the other methods above   #
	#=======================================================#

	def GetPairsFromPositions(panPositions) # TODO: A general function, can move to stzListOfNumbers
		/*
		Main list 	--> 1:10
		panPositions	--> [ 3, 6, 8 ]
		List of pairs	--> [ [ 1, 3 ], [ 3, 6 ], [ 6, 8 ], [ 8, 10 ] ]
		*/

		nLen = This.NumberOfPositions()
		panPositions + nLen

		# Eliminating doubble positions
		aPos = StzListQ(panPositions).ToSet()

		# Eliminating extreme cases
		aPos = StzListQ(panPositions).RemoveItemsWQ('@item < 1 or @item > ' + nLen).Content()
		
		if StzListQ(aPos).IsEmpty()
			return [ [] ]
		ok
		
		# Adding 1 and (NumberOfItems()) if inexistant
		if aPos[1] != 1 { aPos + 1 }
		if aPos[len(aPos)] != 10 { aPos + nLen }
		
		# Sorting the list
		aPos = sort(aPos)
		
		# Getting the pairs of that list
		aPairs = []
		for i = 1 to len(aPos) - 1
			aPairs + [ aPos[i], aPos[i+1] ]
		next

		aPairs = Q(aPairs).RemoveLastItemQ().Content()

		return aPairs

	def ToStzList()
		return StzListQ(This.Content())
