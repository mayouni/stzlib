
#TODO/FUTURE: Support CaseSensitivity

func StzListOfPairsQ(paLists)
	return new stzListOfPairs(paLists)

func RangeToSection(paRange)
	if isList(paRange) and Q(paRange).IsPairOfNumbers()
		n1 = paRange[1]
		n2 = paRange[2]

		aResult = [ n1, n1 + n2 - 1 ]
		return aResult
	else
		StzRaise("Incorrect param! paRange must be a pair of numbers.")
	ok

func RangesToSections(panRanges)
	#TODO:
	# Replace for/in by for

	#UPDATE
	# Done!

	if CheckParams()
		if not isList(panRanges)
			StzRaise("Incorrect param type! panRanges must be a list.")
		ok
	ok

	anSections = []

	for i = 1 to nLen
		anSections + RangeToSection(panRanges[i])
	next

	return anSections

func SectionToRange(panSection)
	if isList(panSection) and Q(panSection).IsPairOfNumbers()
		n1 = panSection[1]
		n2 = panSection[2]

		anResult = [ n1, n2 - n1 + 1 ]
		return anResult
	else
		StzRaise("Incorrect param! paRange must be a pair of numbers.")
	ok

func SectionsToRanges(paSections)
	#TODO:
	# Replace for/in by for

	#UPDATE
	# Done!

	if CheckParams()
		if not isList(panRanges)
			StzRaise("Incorrect param type! panRanges must be a list.")
		ok
	ok

	anSections = []

	for i = 1 to nLen
		anSections + SectionToRange(panRanges[i])
	next

	return anSections

func ListThatHasMoreNumberOfItems(paList1, paList2)
	oList1 = new stzList(aList1)
	if oList1.HasMoreNumberOfItemsThen(paList2)
		return paList1
	else
		return paList2
	ok

func ListThatHasLessNumberOfItems(paList1, paList2)
	oList1 = new stzList(paList1)
	if oList1.HasLessNumberOfItems(:Then = paList2)
		return paList1
	else
		return paList2
	ok

func StzPairsQ(paList)
	return new stzPairs(paList)

class stzPairs from stzListOfPairs

class stzListOfPairs from stzListOfLists
	@aContent = []

	def init(paLists)
		if isList(paLists) and
		   ( Q(paLists).IsEmpty() or Q(paLists).IsListOfPairs() )

			@aContent = paLists

		ok


	def Content()
		return @aContent

		def Value()
			return Content()

	def Copy()
		return new stzListOfPairs( This.Content() )

	def ListOfPairs()
		return This.Content()

	def UpdateWith(paListOfPairs)
		if isList(paListOfPairs) and Q(paListOfPairs).IsListOfPairs()
			@aContent = paListOfPairs

		else
			StzRaise("Can't update the list pairs! The value you provided is not a list of pairs.")
		ok

	def ToStzList()
		return new stzList( This.Content() )

	  #-------------------------------#
	 #  GETTING THE NUMBER OF PAIRS  #
	#-------------------------------#

	def NumberOfPairs()
		return len(@aContent)

	  #------------------------#
	 #  GETTING THE NTH PAIR  #
	#------------------------#

	def PairAt(n)
		return Content()[n]

		def PairAtQ(n)
			return This.PairAtQR(n, :stzList)

		def PairAtQR(n, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.PairAt(n) )
			on :stzPair
				return new stzPair( This.PairAt(n) )
			other
				StzRaise("Unsupported return type!")
			off

		def Pair(n)
			return This.PairAt(n)

			def PairQ(n)
				return This.PairAtQ(n)

			def PairQR(n, pcReturnType)
				return This.PairAtQR(n, pcReturnType)

	  #-------------------------------------------------#
	 #  FINDING POSITIONS OF A GIVEN PAIR IN THE LIST  #
	#-------------------------------------------------#

	def FindPair(paPair)
		return This.FindItem(paPair)

	  #------------------------------------------------------------------#
	 #  FINDING POSITIONS OF A VALUE IN THE LIST OF FIRST/SECOND ITEMS  #
	#------------------------------------------------------------------#

	def FindInFirstItems(pValue)
		anResult = This.FirstItemsQ().Find(pValue)
		return anResult

	def FindInSecondItems(pValue)
		anResult = This.SecondItemsQ().Find(pValue)
		return anResult

	  #---------------------------------------------#
	 #  CHECKING IF PAIRS ARE MADE OF EQUAL ITEMS  #
	#---------------------------------------------#

	def PairsAreMadeOfEqualItems()
		aContent = This.Content()
		nLen = len(aContent)

		bResult = TRUE

		for i = 1 to nLen
			if Q(aContent[i][1]).IsEqualTo(aContent[i][2])
				bResult = FALSE
			ok
		next
		return bResult

	  #----------------------------#
	 #  FIRST ITEMS OF EACH PAIR  #
	#============================#

	def FirstItems()
		aContent = This.Content()
		nLen = len(aContent)

		aResult = []

		for i = 1 to nLen
			aResult + aPair[1]
		next

		return aResult

		#< @FunctionFluentForm

		def FirstItemsQ()
			return This.FirstItemsQR(:stzList)

		def FirstItemsQR(pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.FirstItems() )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.FirstItems() )

			on :stzListOfStrings
				return new stzListOfStrings( This.FirstItems() )

			on :stzListOfLists
				return new stzListOfLists( This.FirstItems() )

			on :stzListOfPairs
				return new stzListOfNumbers( This.FirstItems() )

			other
				StzRaise("Unsupported return type!")
			off

		#>

		#< @FunctionAlternativeForms

		def FirstItemsOfEachPair()
			return This.FirstItems()

		def FirstItemsInEachPair()
			return This.FirstItems()

		def FirstValues()
			return This.FirstItems()

		def FirstValuesOfEachPair()
			return This.FirstItems()

		def FirstValuesInEachPair()
			return This.FirstItems()

		#>

	  #----------------------------------------------------#
	 #  FIRST ITEMS OF EACH PAIR -- WITHOUT DUPPLICATION  #
	#----------------------------------------------------#

	def FirstItemsU()
		aResult = This.FirstItemsQ().WithoutDuplication()
		return aResult

		#< @FunctionFluentForm

		def FirstItemsUQ()
			return This.FirstItemsUQR(:stzList)

		def FirstItemsUQR(pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.FirstItemsU() )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.FirstItemsU() )

			on :stzListOfStrings
				return new stzListOfStrings( This.FirstItemsU() )

			on :stzListOfLists
				return new stzListOfLists( This.FirstItemsU() )

			on :stzListOfPairs
				return new stzListOfNumbers( This.FirstItemsU() )

			other
				StzRaise("Unsupported return type!")
			off

		#>

		#< @FunctionAlternativeForms

		def FirstItemsOfEachPairU()
			return This.FirstItemsU()

		def FirstItemsInEachPairU()
			return This.FirstItemsU()

		def FirstValuesU()
			return This.FirstItemsU()

		def FirstValuesOfEachPairU()
			return This.FirstItemsU()

		def FirstValuesInEachPairU()
			return This.FirstItemsU()

		#TODO
		# add ...WithoutDupplication() and Unique... alternatives

		#>

	  #-----------------------------#
	 #  SECOND ITEMS OF EACH PAIR  #
	#=============================#

	def SecondItems()
		aContent = This.Content()
		nLen = len(aContent)

		aResult = []

		for i = 1 to nLen
			aResult + aContent[i][2]
		next

		return aResult

		#< @FunctionFluentForm

		def SecondItemsQ()
			return This.SecondItemsQR(:stzList)

		def SecondItemsQR(pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.SecondItems() )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.SecondItems() )

			on :stzListOfStrings
				return new stzListOfStrings( This.SecondItems() )

			on :stzListOfLists
				return new stzListOfLists( This.SecondItems() )

			on :stzListOfPairs
				return new stzListOfNumbers( This.SecondItems() )

			other
				StzRaise("Unsupported return type!")
			off

		#>

		#< @FunctionAlternativeForms

		def SecondItemsOfEachPair()
			return This.SecondItems()

		def SecondItemsInEachPair()
			return This.SecondItems()

		def SecondValues()
			return This.SecondItems()

		def SecondValuesOfEachPair()
			return This.SecondItems()

		def SecondValuesInEachPair()
			return This.SecondItems()

		#>

	  #-----------------------------------------------------#
	 #  SECOND ITEMS OF EACH PAIR -- WITHOUT DUPPLICATION  #
	#-----------------------------------------------------#

	def SecondItemsU()
		aResult = This.SecondItemsQ().WithoutDuplication()
		return aResult

		#< @FunctionFluentForm

		def SecondItemsUQ()
			return This.SecondItemsUQR(:stzList)

		def SecondItemsUQR(pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.SecondItemsU() )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.SecondItemsU() )

			on :stzListOfStrings
				return new stzListOfStrings( This.SecondItemsU() )

			on :stzListOfLists
				return new stzListOfLists( This.SecondItemsU() )

			on :stzListOfPairs
				return new stzListOfNumbers( This.SecondItemsU() )

			other
				StzRaise("Unsupported return type!")
			off

		#>

		#< @FunctionAlternativeForms

		def SecondItemsOfEachPairU()
			return This.SecondItemsU()

		def SecondItemsInEachPairU()
			return This.SecondItemsU()

		def SecondValuesU()
			return This.SecondItemsU()

		def SecondValuesOfEachPairU()
			return This.SecondItemsU()

		def SecondValuesInEachPairU()
			return This.SecondItemsU()

		#TODO
		# add ...WithoutDupplication() and Unique... alternatives

		#>
	  #--------------------#
	 #  REPLACING A PAIR  #
	#====================#

	def ReplacePair(n, paNewPair)
		if isList(paNewPair) and Q(paNewPair).IsPair()
			@aContent[n] = paNewPair
		ok

		def ReplacePairQ(n, paNewPair)
			This.ReplacePair(n, paNewPair)
			return This

	def PairReplaced(n, paNewPair)
		aResult = This.Copy().ReplacePairQ(n, paNewPair).Content()
		return aResult

	  #==============================#
	 #  SORTING PAIRS IN ASCENDING  #
	#==============================#

	def StringifyItems()
		aContent = This.Content()
		nLen = len(aContent)

		aResult = []

		for i = 1 to nLen
			aResult + [ Q(aContent[i][1]).Stringified(), Q(aContent[i][2]).Stringified() ]
		next

		This.Update(aResult)

		def StringifyItemsQ()
			This.StringifyItems()
			return This

	def ItemsStringified()
		aResult = This.Copy().StringifyItemsQ().Content()
		return aResult

	  #------------------------------------------#
	 #  SORTING THE LIST OF PAIRS IN ASCENDING  #
	#------------------------------------------#

	def SortInAscending()

		aSorted = This.ToStzList().SortedInAscending()

		if NOT This.IsListOfPairsOfNumbers()
			This.UpdateWith(aSorted)
			return
		ok

		# Special case of pair of list of numbers

		# Flattening the list of pairs

		aFlat = Q(aSorted).Flattened()
		nLen = len(aFlat)

		# Transforming the strings to stzNumbers

		aStzNumbers = []
		for i = 1 to nLen
			aStzNumbers + StzNumberQ(aFlat[i])
		next

		# Getting the max number of digits on both the
		# interger and decimal parts of the numbers

		nMaxInt = 0
		nMaxDec = 0

		for i = 1 to nLen

			nInt = aStzNumbers[i].NumberOfIntegers()
			if nInt > nMaxInt
				nMaxInt = nInt
			ok

			nDec = aStzNumbers[i].NumberOfDecimals()
			if nDec > nMaxDec
				nMaxDec = nDec
			ok

		next

		# Adjusting the numbers by adding 0s left and right
		# to fill the values of nMaxInt and nMaxDec

		aAdjust = []
		aPair = []

		for i = 1 to nLen

			# Adjusting the decimal part by rounding it to nMaxDec

			cNumber = aStzNumbers[i].RoundedToXT(nMaxDec)

			# Adjusting the integr part

			nInt = nMaxInt - aStzNumbers[i].NumberOfIntegers()
			cTempStr = ""
			for j = 1 to nInt
				cTempStr += "0"
			next
			cNumber = cTempStr + cNumber

			aPair + cNumber

			if len(aPair) = 2
				aAdjust + ( "[ " + aPair[1] + ", " + aPair[2] + " ]" )
				aPair = []
			ok
		next

		# Sorting the pairs of numbers

		aSorted = Q(aAdjust).SortedInAscending()

		# Composing and evaluating the content of the list

		nLen = len(aSorted)

		cCode = 'aResult = [ '
		
		for i = 1 to nLen
			cCode += aSorted[i]
			if i < nLen
				cCode += ', '
			ok
		next
		
		cCode += ' ]'

		eval(cCode)

		This.UpdateWith(aResult)
		
		def Sort()
			This.SortInAscending()

		def SortInAscendingQ()
			This.SortInAscending()
			return This

	def SortedInAscending()
		aResult = This.Copy().SortInAscendingQ().Content()
		return aResult

		def Sorted()
			return This.SortedInAscending()

	def IsSortedInAscending()
		aSorted = This.SortedInAscending()
		cSorted = StzListQ(aSorted).ToCode()
		
		bResult = This.ToCodeQ().IsEqualTo(cSorted)

		return bResult

		def IsSorted()
			return This.IsSortedInAscending()

	  #-------------------------------#
	 #  SORTING PAIRS IN DESCENDING  #
	#-------------------------------#

	def SortInDescending()
		/* EXAMPLE

		o1 = new stzListOfPairs([ [4, 7], [3, 1], [8, 9] ])
		o1.SortInDescending()
		? o1.Content()
		#--> [ [8, 9], [4, 7], [1,3] ]

		*/

		aResult = ring_reverse( This.SortedInAscending() )
		This.Update(aResult)

		def SortInDescendingQ()
			This.SortInDescending()
			return This

	def SortedInDescending()
		aResult = This.Copy().SortInDescendingQ().Content()
		return aResult

	def IsSortedInDescending()
		aSorted = This.SortedInDescending()
		cSorted = StzListQ(aSorted).ToCode()
		
		bResult = This.ToCodeQ().IsEqualTo(cSorted)

		return bResult

	  #------------------------------#
	 #  SORTING PAIRS IN ASCENDING  #
	#------------------------------#

	def SortItemsInAscending()

		nLen = len(@aContent)

		for i = 1 to nLen
			@aContent[i] = Q(@aContent[i]).SortedInAscending()
		next

		#< @FunctionAlternativeForms

		def SortInsideInAscending()
			This.SortItemsInAscending()

		def SortInSideInPairsInAscending()
			This.SortItemsInAscending()

		def SortItemsInsideInAscending()
			This.SortItemsInAscending()

		def SortItemsInsidePairsInAscending()
			This.SortItemsInAscending()

		def SortItems()
			This.SortItemsInAscending()

		def SortInside()
			This.SortItemsInAscending()

		def SortItemsInside()
			This.SortItemsInAscending()

		def SortItemsInsidePairs()
			This.SortItemsInAscending()

		#>

	def ItemsSortedInAsecending()
		aResult = Q( This.Copy().SortItemsInAscending() ).Content()
		return aResult

		#< @FunctionAlternativeForms

		def ItemsSorted()
			return This.ItemsSortedInAsecending()

		#>

	  #-------------------------------#
	 #  SORTING PAIRS IN DESCENDING  #
	#-------------------------------#

	def SortItemsInDescending()

		nLen = len(@aContent)

		for i = 1 to nLen
			@aContent[i] = Q(@aContent[i]).SortedInDescending()
		next

		#< @FunctionAlternativeForms

		def SortInsideInDescending()
			This.SortItemsInDescending()

		def SortInSideInPairsInDescending()
			This.SortItemsInDescending()

		def SortItemsInsideInDescending()
			This.SortItemsInDescending()

		def SortItemsInsidePairsInDescending()
			This.SortItemsInDescending()

		#>

	def ItemsSortedInDesecending()
		aResult = Q( This.Copy().SortItemsInDescending() ).Content()
		return aResult

	  #==================================================================#
	 #  RETURNING AN EXPANDED LIST OF NUMBERS OUT OF THE LIST OF PAIRS  #
	#==================================================================#

	def ExpandedIfPairsOfNumbers()
		aContent = This.Content()
		nLen = len(aContent)

		aResult = []

		for i = 1 to nLen
			if isNumber(aContent[i][1]) and isNumber(aContent[i][2])
				aResult + StzListQ(aPair).ExpandedIfPairOfNumbers()
			ok
		next

		return aResult

		#< @FunctionFluentForm

		def ExpandedIfPairsOfNumbersQ()
			return This.ExpandedIfPairsOfNumbersQR(:stzList)

		def ExpandedIfPairsOfNumbersQR(pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.ExpandedIfPairsOfNumbers() )

			on :stzListOfLists
				return new stzListOfLists( This.ExpandedIfPairsOfNumbers() )

			other
				StzRaise("Unsupported type!")
			off
				
		#>

	  #-------------------------------------------------#
	 #   SWAPPING THE ITEMS IN THE PAIRS OF THE LIST   #
	#-------------------------------------------------#

	def SwapItems()
		nLen = len(@aContent)

		for i = 1 to nLen
			temp = @aContent[i][1]
			@aContent[i][1] = @aContent[i][2]
			@aContent[i][2] = temp
		next


		#< @FunctionFluentForm
			
		def SwapItemsQ()
			This.SwapItems()
			return This

		#>

		#< @FunctionAlternativeForms

		def ReverseItems()
			This.SwapItems()

			def ReverseItemsQ()
				return This.SwapItemsQ()

		def InverseItems()
			This.SwapItems()

			def InverseItemsQ()
				return This.SwapItemsQ()

		#>

	def ItemsSwapped()
		aResult = This.Copy().SwapItemsQ().Content()
		return aReslult

		def ItemsReversed()
			return This.ItemsSwapped()

		def ItemsInversed()
			return This.ItemsSwapped()

	  #------------------------------------#
	 #   SWAPPING THE PAIRS OF THE LIST   #
	#------------------------------------#

	def SwapPairs()
		@aContent[1] = aTemp
		@aContent[1] = @aContent[2]
		@aContent[2] = aTemp

		#< @FunctionFluentForm

		def SwapPairsQ()
			This.SwapPairs()
			return This

		#>

		#< @FunctionAlternativeForms

		def ReversePairs()
			This.SwapPairs()

			def ReversePairsQ()
				return This.SwapPairsQ()

		def InversePairs()
			This.SwapPairs()

			def InversePairsQ()
				return This.SwapPairsQ()

		#--

		def Swap()
			This.SwapPairs()

			def SwapQ()
				return This.SwapPairsQ()

		def Reverse()
			This.SwapPairs()

			def ReverseQ()
				return This.SwapPairsQ()

		def Inverse()
			This.SwapPairs()

			def InverseQ()
				return This.SwapPairsQ()

		#>


	def PairsSwapped()
		aResult = This.Copy().SwapPairsQ().Content()
		return aReslult

		#< @FunctionAlternativeForms

		def PairsReversed()
			return This.PairsSwapped()

		def PairsInversed()
			return This.PairsSwapped()

		#--

		def Swapped()
			return This.PairsSwapped()

		def Reversed()
			return This.PairsSwapped()

		def Inversed()
			return This.PairsSwapped()

		#>

	  #---------------------------------------------------------------#
	 #   CHECKING IF THE PAIRS ARE SECTIONS AND IF THEY ARE SORTED   #
	#---------------------------------------------------------------#
	#--> Each pair is made of numbers

	def IsListOfSections()

		aContent = This.Content()
		nLen = len(aContent)	

		bResult = TRUE

		for i = 1 to nLen
			if NOT @IsListOfNumbers(aContent[i])
				bIsMadeOfNumbers = FALSE
				exit
			ok
		next

		return bResult

	def IsSortedListOfSections()

		if This.IsListOfSectionsSortedInAscending() or
		   This.IsListOfSectionsSortedInDescending()

			return TRUE

		else
			return FALSE
		ok

	def IsListOfSectionsSortedInAscending()

		bResult = FALSE

		If This.IsListOfSections() and
		   This.MergeQ().IsSortedInAscending()

				bResult = TRUE

		ok

		return bResult

	def IsListOfSectionsSortedInDescending()

		bResult = FALSE
		aSwapped = This.Swapped()

		If This.IsListOfSections() and
		   StzListQ(aSwapped).MergeQ().IsSortedInDescending()

				bResult = TRUE

		ok

		return bResult

	  #---------------------------------------------#
	 #   CHECHKING IF AN ITEM EXISTS IN ANY PAIR   #
	#---------------------------------------------#

	def ContainsInAnyPair(pItem)
		aContent = This.Content()
		nLen = len(aContent)

		bResult = FALSE
		
		for i = 1 to nLen
			if StzListQ(aContent[i]).Contains(pItem)
				bResult = TRUE
				exit
			ok
		next

		return bResult

	  #=============================#
	 #   MERGING AJJUSCENT PAIRS   #
	#=============================#

	#NOTE
	# The function is made for pairs of numbers
	#TODO
	# Test it and see it has a meaning when used with pairs of strings or lists

	#--

	#TODO
	# See if the term ADJUSCENT can be considered an alternative in stzList
	# to the term CONTINGUOUS
	#UPDATE
	# I don't think so becase CONTIGUOUS is used to mean CONTINUOUS in stzList
	#TODO
	# Remove the term CONTIGUOUS in stzList and leave only CONTINUOUS


	def MergeContiguous()
		#EXAMPLE
		/*
		o1 = new stzListOfPairs([
			[ 1, 4], [6, 8], [9, 10], [12, 13], [13, 15] ]
		])
		o1.MergeContiguous()
		? o1.Content()
		#--> [ [1, 4], [6, 10], [12, 15] ]

		*/

		#NOTE
		/* Can be solved qucickly like this

		aResult = YieldW('{ [This[@i][2], This[@i+1][1]] }',
			:Where = '{ This[@i][2] = This[@i+1][1] + 1 }')

		? aResult

		But the fellowing implementation is more performant.
		*/

		aContent = This.Content()
		nLen = len(aContent)

		aResult = []

		for i = 1 to nLen - 1
			aCurrentPair = This.Pair(i)
			aNextPair = This.Pair(i+1)

			if aCurrentPair[2] = aNextPair[1] or
			   aCurrentPair[2] = aNextPair[1] - 1
				bContiguous = TRUE

				aResult + [ aCurrentPair[1], aNextPair[2] ]
				i++

			else
				bContiguous = FALSE
				aResult + aCurrentPair
			ok

		next

		if bContiguous = FALSE
			aResult = aContent[nLen]
		ok

		This.UpdateWith(aResult)
		

		def MergeContiguousQ()
			This.MergeContiguous()
			return This

		def MergeAdjuscent()
			This.MergeContiguous()

			def MergeAdjuscentQ()
				return This.MergeContiguousQ()

	def ContiguousPairsMerged()
		aResult = This.Copy().MergecontiguousQ().Content()
		return aResult

		def AdjuscentPairsMerged()
			return This.ContiguousPairsMerged()

		def ContiguousMerged()
			return This.ContiguousPairsMerged()

		def AdjuscentMerged()
			return This.ContiguousPairsMerged()

	  #---------------------------------------------------#
	 #  MERGING THE INCLUDED PAIRS IN THE LIST OF PAIRS  #
	#---------------------------------------------------#

	#NOTE
	# The code of the function has been generated (mostly) by Gemini AI
	# using the fellowing prompts : https://g.co/gemini/share/2ecc1b47c465

	# I left the naming style as proposed by Gemini as recognition of its
	# nice performance regarding this algorithm ;)

	# I just adapted the code to fit with a method inside a class, and
	# replace the for/in loop with a standard for loop (X2 performance gain)

	# The fact that Softanza contains the "Min() and Max()" functions, and the
	# fact that Ring "if [] returns FALSE", helped a lot in leaving the code
	# proposed by Gemini as is.

	def MergeIncluded()
		#EXAMPLE
		/*
		o1 = new stzListOfPairs([
			[ 4, 4 ], [ 4, 5 ], [ 4, 6 ], [ 5, 5 ], [ 5, 6 ], [ 6, 6 ],
			[ 10, 10 ], [ 10, 11 ], [ 11, 11 ],
			[15, 20], [12, 22]
		])
		
		o1.MergeInclusive()
		? @@( o1.Content() )
		#--> [ [ 4, 6 ], [ 10, 11 ], [ 12, 22 ] ]

		*/

		merged_pairs = []
		current_pair = :None

		aPairs = This.Content()
		nLen = len(aPairs)

		for i = 1 to nLen
			if current_pair = :None
				# Initialize current_pair if it's None
		     		 current_pair = aPairs[i]
		   	 else
		     		# Check if the new pair fits within the current one
		      		if aPairs[i][1] <= current_pair[2]
		       			# Update current_pair to include the new pair
		        		current_pair[1] = min([aPairs[i][1], current_pair[1]])
		        		current_pair[2] = max([aPairs[i][2], current_pair[2]])
			
		      		else
				        # Add the current merged pair to the result and start a new one
				        merged_pairs + current_pair
				        current_pair = aPairs[i]
				ok
			ok
		next

		# Add the last merged pair (if any)
		if current_pair
		    merged_pairs + current_pair
		ok

		This.UpdateWith( merged_pairs )

		#< @FunctionFluentForm

		def MergeIncludedQ()
			This.MergeIncluded()
			return This

		#>

		#< @FunctionAlternativeForm

		def MergeInclusive()
			This.MergeIncluded()

			def MergeInclusiveQ()
				return This.MergeIncludedQ()

		#>

	def IncludedPairsMerged()
		aResult = This.Copy().MergeIncludedQ().Content()
		return aResult

		def InclusivePairsMerged()
			return This.IncludedPairsMerged()

	  #===================================================#
	 #  CHECKING IF THE TWO VALUES ARE ANOGRAMS STRINGS  #
	#===================================================#

	def AreAnagramsCS(pCaseSensitive)

		val1 = This.FirstValue()
		val2 = This.SecondValue()

		if @BothAreStrings(val1, val2) and
		   Q(val1).IsAnagramOfCS(val2, pCaseSensitive)

			return TRUE
		else
			return FALSE
		ok

	def AreAnagrams()
		return This.AreAnagramsCS(TRUE)

	  #===============================================#
	 #  CHECKING IF THE FIRST ITEMS ARE ALL NUMBERS  #
	#===============================================#

	def FirstItemsAreNumbers()
		aContent = This.Content()
		nLen = len(aContent)

		bResult = TRUE

		for i = 1 to nLen
			if NOT isNumber(aContent[i][1])
				bResult = FALSE
				exit
			ok
		next

		return bResult

		def FirstItemsAreAllNumbers()
			return This.FirstItemsAreNumbers()

		def FirstItemsAreOnlyNumbers()
			return This.FirstItemsAreNumbers()

		def FirstItemsAreJustNumbers()
			return This.FirstItemsAreNumbers()

	  #-----------------------------------------------#
	 #  CHECKING IF THE FIRST ITEMS ARE ALL STRINGS  #
	#-----------------------------------------------#

	def FirstItemsAreStrings()
		aContent = This.Content()
		nLen = len(aContent)

		bResult = TRUE

		for i = 1 to nLen
			if NOT isString(aContent[i][1])
				bResult = FALSE
				exit
			ok
		next

		return bResult

		def FirstItemsAreAllStrings()
			return This.FirstItemsAreStrings()

		def FirstItemsAreOnlyStrings()
			return This.FirstItemsAreStrings()

		def FirstItemsAreJustStrings()
			return This.FirstItemsAreStrings()

	  #---------------------------------------------#
	 #  CHECKING IF THE FIRST ITEMS ARE ALL CHARS  #
	#---------------------------------------------#

	def FirstItemsAreChars()
		aContent = This.Content()
		nLen = len(aContent)

		bResult = TRUE

		for i = 1 to nLen
			if NOT @IsChar(aContent[i][1])
				bResult = FALSE
				exit
			ok
		next

		return bResult

		def FirstItemsAreAllChars()
			return This.FirstItemsAreChars()

		def FirstItemsAreOnlyChars()
			return This.FirstItemsAreChars()

		def FirstItemsAreJustChars()
			return This.FirstItemsAreChars()

	  #---------------------------------------------#
	 #  CHECKING IF THE FIRST ITEMS ARE ALL LISTS  #
	#---------------------------------------------#

	def FirstItemsAreLists()
		aContent = This.Content()
		nLen = len(aContent)

		bResult = TRUE

		for i = 1 to nLen
			if NOT isList(aContent[i][1])
				bResult = FALSE
				exit
			ok
		next

		return bResult

		def FirstItemsAreAllLists()
			return This.FirstItemsAreLists()

		def FirstItemsAreOnlyLists()
			return This.FirstItemsAreLists()

		def FirstItemsAreJustLists()
			return This.FirstItemsAreLists()

	  #-----------------------------------------------#
	 #  CHECKING IF THE FIRST ITEMS ARE ALL OBJECTS  #
	#-----------------------------------------------#

	def FirstItemsAreObjects()
		aContent = This.Content()
		nLen = len(aContent)

		bResult = TRUE

		for i = 1 to nLen
			if NOT isObject(aContent[i][1])
				bResult = FALSE
				exit
			ok
		next

		return bResult

		def FirstItemsAreAllObjects()
			return This.FirstItemsAreObjects()

		def FirstItemsAreOnlyObjects()
			return This.FirstItemsAreObjects()

		def FirstItemsAreJustObjects()
			return This.FirstItemsAreObjects()

	  #--------------------------------------------------#
	 #  CHECKING IF THE FIRST ITEMS ARE ALL STZOBJECTS  #
	#--------------------------------------------------#

	def FirstItemsAreStzObjects()
		aContent = This.Content()
		nLen = len(aContent)

		bResult = TRUE

		for i = 1 to nLen
			if NOT @IsStzObject(aContent[i][1])
				bResult = FALSE
				exit
			ok
		next

		return bResult

		def FirstItemsAreAllStzObjects()
			return This.FirstItemsAreStzObjects()

		def FirstItemsAreOnlyStzObjects()
			return This.FirstItemsAreStzObjects()

		def FirstItemsAreJustStzObjects()
			return This.FirstItemsAreStzObjects()

	  #------------------------------------------------#
	 #  CHECKING IF THE FIRST ITEMS ARE ALL STZCHARS  #
	#------------------------------------------------#

	def FirstItemsAreStzChars()
		aContent = This.Content()
		nLen = len(aContent)

		bResult = TRUE

		for i = 1 to nLen
			if NOT @IsStzChar(aContent[i][1])
				bResult = FALSE
				exit
			ok
		next

		return bResult

		def FirstItemsAreAllStzChars()
			return This.FirstItemsAreStzChars()

		def FirstItemsAreOnlyStzChars()
			return This.FirstItemsAreStzChars()

		def FirstItemsAreJustStzChars()
			return This.FirstItemsAreStzChars()

	  #--------------------------------------------------#
	 #  CHECKING IF THE FIRST ITEMS ARE ALL STZSTRINGS  #
	#--------------------------------------------------#

	def FirstItemsAreStzStrings()
		aContent = This.Content()
		nLen = len(aContent)

		bResult = TRUE

		for i = 1 to nLen
			if NOT @IsStzString(aContent[i][1])
				bResult = FALSE
				exit
			ok
		next

		return bResult

		def FirstItemsAreAllStzStrings()
			return This.FirstItemsAreStzStrings()

		def FirstItemsAreOnlyStzStrings()
			return This.FirstItemsAreStzStrings()

		def FirstItemsAreJustStzStrings()
			return This.FirstItemsAreStzStrings()

	  #--------------------------------------------------#
	 #  CHECKING IF THE FIRST ITEMS ARE ALL STZNUMBERS  #
	#--------------------------------------------------#

	def FirstItemsAreStzNumbers()
		aContent = This.Content()
		nLen = len(aContent)

		bResult = TRUE

		for i = 1 to nLen
			if NOT @IsStzNumber(aContent[i][1])
				bResult = FALSE
				exit
			ok
		next

		return bResult

		def FirstItemsAreAllStzNumbers()
			return This.FirstItemsAreStzNumbers()

		def FirstItemsAreOnlyStzNumbers()
			return This.FirstItemsAreStzNumbers()

		def FirstItemsAreJustStzNumbers()
			return This.FirstItemsAreStzNumbers()

	  #------------------------------------------------#
	 #  CHECKING IF THE FIRST ITEMS ARE ALL STZLISTS  #
	#------------------------------------------------#

	def FirstItemsAreStzLists()
		aContent = This.Content()
		nLen = len(aContent)

		bResult = TRUE

		for i = 1 to nLen
			if NOT @IsStzList(aContent[i][1])
				bResult = FALSE
				exit
			ok
		next

		return bResult

		def FirstItemsAreAllStzLists()
			return This.FirstItemsAreStzLists()

		def FirstItemsAreOnlyStzLists()
			return This.FirstItemsAreStzLists()

		def FirstItemsAreJustStzLists()
			return This.FirstItemsAreStzLists()

	  #----------------------------------------------------#
	 #  CHECKING IF THE FIRST ITEMS ARE ALL STZHASHLISTS  #
	#----------------------------------------------------#

	def FirstItemsAreStzHashLists()
		aContent = This.Content()
		nLen = len(aContent)

		bResult = TRUE

		for i = 1 to nLen
			if NOT @IsStzHashList(aContent[i][1])
				bResult = FALSE
				exit
			ok
		next

		return bResult

		def FirstItemsAreAllStzHashLists()
			return This.FirstItemsAreStzHashLists()

		def FirstItemsAreOnlyStzHashLists()
			return This.FirstItemsAreStzHashLists()

		def FirstItemsAreJustStzHashLists()
			return This.FirstItemsAreStzHashLists()

	  #================================================#
	 #  CHECKING IF THE SECOND ITEMS ARE ALL NUMBERS  #
	#================================================#

	def SecondItemsAreNumbers()
		aContent = This.Content()
		nLen = len(aContent)

		bResult = TRUE

		for i = 1 to nLen
			if NOT isNumber(aContent[i][2])
				bResult = FALSE
				exit
			ok
		next

		return bResult

		def SecondItemsAreAllNumbers()
			return This.SecondItemsAreNumbers()

		def SecondItemsAreOnlyNumbers()
			return This.SecondItemsAreNumbers()

		def SecondItemsAreJustNumbers()
			return This.SecondItemsAreNumbers()

	  #------------------------------------------------#
	 #  CHECKING IF THE SECOND ITEMS ARE ALL STRINGS  #
	#------------------------------------------------#

	def SecondItemsAreStrings()
		aContent = This.Content()
		nLen = len(aContent)

		bResult = TRUE

		for i = 1 to nLen
			if NOT isString(aContent[i][2])
				bResult = FALSE
				exit
			ok
		next

		return bResult

		def SecondItemsAreAllStrings()
			return This.SecondItemsAreStrings()

		def SecondItemsAreOnlyStrings()
			return This.SecondItemsAreStrings()

		def SecondItemsAreJustStrings()
			return This.SecondItemsAreStrings()

	  #----------------------------------------------#
	 #  CHECKING IF THE SECOND ITEMS ARE ALL CHARS  #
	#----------------------------------------------#

	def SecondItemsAreChars()
		aContent = This.Content()
		nLen = len(aContent)

		bResult = TRUE

		for i = 1 to nLen
			if NOT @IsChar(aContent[i][2])
				bResult = FALSE
				exit
			ok
		next

		return bResult

		def SecondItemsAreAllChars()
			return This.SecondItemsAreChars()

		def SecondItemsAreOnlyChars()
			return This.SecondItemsAreChars()

		def SecondItemsAreJustChars()
			return This.SecondItemsAreChars()

	  #----------------------------------------------#
	 #  CHECKING IF THE SECOND ITEMS ARE ALL LISTS  #
	#----------------------------------------------#

	def SecondItemsAreLists()
		aContent = This.Content()
		nLen = len(aContent)

		bResult = TRUE

		for i = 1 to nLen
			if NOT isList(aContent[i][2])
				bResult = FALSE
				exit
			ok
		next

		return bResult

		def SecondItemsAreAllLists()
			return This.SecondItemsAreLists()

		def SecondItemsAreOnlyLists()
			return This.SecondItemsAreLists()

		def SecondItemsAreJustLists()
			return This.SecondItemsAreLists()

	  #------------------------------------------------#
	 #  CHECKING IF THE SECOND ITEMS ARE ALL OBJECTS  #
	#------------------------------------------------#

	def SecondItemsAreObjects()
		aContent = This.Content()
		nLen = len(aContent)

		bResult = TRUE

		for i = 1 to nLen
			if NOT isObject(aContent[i][2])
				bResult = FALSE
				exit
			ok
		next

		return bResult

		def SecondItemsAreAllObjects()
			return This.SecondItemsAreObjects()

		def SecondItemsAreOnlyObjects()
			return This.SecondItemsAreObjects()

		def SecondItemsAreJustObjects()
			return This.SecondItemsAreObjects()

	  #---------------------------------------------------#
	 #  CHECKING IF THE SECOND ITEMS ARE ALL STZOBJECTS  #
	#---------------------------------------------------#

	def SecondItemsAreStzObjects()
		aContent = This.Content()
		nLen = len(aContent)

		bResult = TRUE

		for i = 1 to nLen
			if NOT @IsStzObject(aContent[i][2])
				bResult = FALSE
				exit
			ok
		next

		return bResult

		def SecondItemsAreAllStzObjects()
			return This.SecondItemsAreStzObjects()

		def SecondItemsAreOnlyStzObjects()
			return This.SecondItemsAreStzObjects()

		def SecondItemsAreJustStzObjects()
			return This.SecondItemsAreStzObjects()

	  #-------------------------------------------------#
	 #  CHECKING IF THE SECOND ITEMS ARE ALL STZCHARS  #
	#-------------------------------------------------#

	def SecondItemsAreStzChars()
		aContent = This.Content()
		nLen = len(aContent)

		bResult = TRUE

		for i = 1 to nLen
			if NOT @IsStzChar(aContent[i][2])
				bResult = FALSE
				exit
			ok
		next

		return bResult

		def SecondItemsAreAllStzChars()
			return This.SecondItemsAreStzChars()

		def SecondItemsAreOnlyStzChars()
			return This.SecondItemsAreStzChars()

		def SecondItemsAreJustStzChars()
			return This.SecondItemsAreStzChars()

	  #---------------------------------------------------#
	 #  CHECKING IF THE SECOND ITEMS ARE ALL STZSTRINGS  #
	#---------------------------------------------------#

	def SecondItemsAreStzStrings()
		aContent = This.Content()
		nLen = len(aContent)

		bResult = TRUE

		for i = 1 to nLen
			if NOT @IsStzString(aContent[i][2])
				bResult = FALSE
				exit
			ok
		next

		return bResult

		def SecondItemsAreAllStzStrings()
			return This.SecondItemsAreStzStrings()

		def SecondItemsAreOnlyStzStrings()
			return This.SecondItemsAreStzStrings()

		def SecondItemsAreJustStzStrings()
			return This.SecondItemsAreStzStrings()

	  #---------------------------------------------------#
	 #  CHECKING IF THE SECOND ITEMS ARE ALL STZNUMBERS  #
	#---------------------------------------------------#

	def SecondItemsAreStzNumbers()
		aContent = This.Content()
		nLen = len(aContent)

		bResult = TRUE

		for i = 1 to nLen
			if NOT @IsStzNumber(aContent[i][2])
				bResult = FALSE
				exit
			ok
		next

		return bResult

		def SecondItemsAreAllStzNumbers()
			return This.SecondItemsAreStzNumbers()

		def SecondItemsAreOnlyStzNumbers()
			return This.SecondItemsAreStzNumbers()

		def SecondItemsAreJustStzNumbers()
			return This.SecondItemsAreStzNumbers()

	  #-------------------------------------------------#
	 #  CHECKING IF THE SECOND ITEMS ARE ALL STZLISTS  #
	#-------------------------------------------------#

	def SecondItemsAreStzLists()
		aContent = This.Content()
		nLen = len(aContent)

		bResult = TRUE

		for i = 1 to nLen
			if NOT @IsStzList(aContent[i][2])
				bResult = FALSE
				exit
			ok
		next

		return bResult

		def SecondItemsAreAllStzLists()
			return This.SecondItemsAreStzLists()

		def SecondItemsAreOnlyStzLists()
			return This.SecondItemsAreStzLists()

		def SecondItemsAreJustStzLists()
			return This.SecondItemsAreStzLists()

	  #-----------------------------------------------------#
	 #  CHECKING IF THE SECOND ITEMS ARE ALL STZHASHLISTS  #
	#-----------------------------------------------------#

	def SecondItemsAreStzHashLists()
		aContent = This.Content()
		nLen = len(aContent)

		bResult = TRUE

		for i = 1 to nLen
			if NOT @IsStzHashList(aContent[i][2])
				bResult = FALSE
				exit
			ok
		next

		return bResult

		def SecondItemsAreAllStzHashLists()
			return This.SecondItemsAreStzHashLists()

		def SecondItemsAreOnlyStzHashLists()
			return This.SecondItemsAreStzHashLists()

		def SecondItemsAreJustStzHashLists()
			return This.SecondItemsAreStzHashLists()

	  #=====================================================#
	 #  TRANSFORMING THE LIST OF PAIRS INTO A STZHASHLIST  #
	#=====================================================#

	def ToStzHashList()
		if NOT This.FirstItemsAreAllStrings()
			StzRais("Can't transform the list of pairs into a stzHashList! First items of the pairs must all be strings.")
		ok

		aContent = This.Content()
		nLen = len(aContent)

		aHash = []

		for i = 1 to nLen
			aHash + [ aContent[i][1], [ aContent[i][2] ] ]
		next

		oResult = new stzHashList(aHash)
		return oResult
