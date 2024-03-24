
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
	anSections = []
	#TODO: Replace for/in by for
	for anRange in panRanges
		anSections + RangeToSection(anRange)
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
	anRanges = []
	#TODO: Replace for/in by for
	for anSection in paSections
		anRanges + SectionToRange(anSection)
	next
	return anRanges

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
		bResult = TRUE
		for aPair in Content()
			if Q(aPair[1]).IsEqualTo(aPair[2])
				bResult = FALSE
			ok
		next
		return bResult

	  #----------------------------#
	 #  FIRST ITEMS OF EACH PAIR  #
	#----------------------------#

	def FirstItems()

		aResult = []

		for aPair in This.ListOfPairs()
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

	  #-----------------------------#
	 #  SECOND ITEMS OF EACH PAIR  #
	#-----------------------------#

	def SecondItems()

		aResult = []

		for aPair in This.ListOfPairs()
			aResult + aPair[2]
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

	  #--------------------#
	 #  REPLACING A PAIR  #
	#--------------------#

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
		aResult = []

		for aPair in This.ListOfPairs()
			if isNumber(aPair[1]) and isNumber(aPair[2])
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
		
	def Swap()
		aResult = Association([ This.SecondItems(), This.FirstItems() ])
		This.UpdateWith(aResult)

		def SwapQ()
			This.Swap()
			return This

		def SwapItems()
			This.Swap()

			def SwapItemsQ()
				This.SwapItems()
				return This

	def Swapped()
		aResult = This.ListOfPairs()

		for aPair in aResult
			temp = aPair[1]
			aPair[1] = aPair[2]
			aPair[2] = temp
		next

		return aResult

		def ItemsSwapped()
			return This.Swapped()

	  #-------------------------------------#
	 #   REVERSING THE PAIRS OF THE LIST   #
	#-------------------------------------#

	def ReversePairs()	

		aResult = ring_reverse(This.ListOfPairs())

		This.Update( aResult )

		def ReversePairsQ()
			This.ReversePairs()
			return This

			def ReverseQ()
				return This.ReverseItemsQ()

	def ReversedPairs()
		aResult = This.Copy().ReversePairsQ().Content()
		return aResult

		#< @FunctionAlternativeForms

		def PairsReversed()
			return This.ReversedPairs()

		def Reversed()
			return This.ReversedPairs()

		#>

	  #--------------------------------------------------#
	 #   REVERSING ITEMS INSIDE THE PAIRS OF THE LIST   #
	#--------------------------------------------------#

	def ReverseItemsInPairs()
		for aPair in This.ListOfPairs()
			aPair = Q(aPair).Reversed()
		next

		def ReverseItemsInPairsQ()
			This.ReverseItemsInPairs()
			return This

		def ReversePairsContent()
			This.ReverseItemsInPairs()

			def ReversePairsContentQ()
				This.ReversePairsContent()
				return This

	def ItemsInPairsReversed()
		aResult = This.Copy().ReverseItemsInPairsQ().Content()
		return aResult

		def PairsContentReversed()
			return This.ItemsInPairsReversed()

	  #---------------------------------------------------------------#
	 #   CHECKING IF THE PAIRS ARE SECTIONS AND IF THEY ARE SORTED   #
	#---------------------------------------------------------------#

	def IsListOfSections()

		# Each pair is made of numbers

		bIsMadeOfNumbers = TRUE

		for aPair in This.ListOfPairs()
			if NOT StzListQ(aPair).IsMadeOfNumbers()
				bIsMadeOfNumbers = FALSE
				exit
			ok
		next

		# Returning the result

		return bIsMadeOfNumbers

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
		bResult = FALSE
		
		for aPair in This.ListOfPairs()
			if StzListQ(aPair).Contains(pItem)
				bResult = TRUE
				exit
			ok
		next

		return bResult

	  #------------------------------#
	 #   MERGING CONTIGUOUS PAIRS   #
	#------------------------------#

	def MergeContiguous()
		/* EXAMPLE

		o1 = new stzListOfPairs([
			[ 1, 4], [6, 8], [9, 10], [12, 13], [13, 15] ]
		])
		o1.MergeContiguous()
		? o1.Content()
		#--> [ [1, 4], [6, 10], [12, 15] ]

		*/

		aResult = YieldW('{ [This[@i][2], This[@i+1][1]] }',
			:Where = '{ This[@i][2] = This[@i+1][1] + 1 }')

		? aResult
/*
		aResult = []

		nLen = This.NumberOfPairs()
		for i = 1 to nLen - 1
			aCurrentPair = This.Pair(i)
			aNextPair = This.Pair(i+1)

			bContinguous = FALSE

			if aCurrenPair[2] = aNextPair[1] or
			   aCurrenPair[2] = aNextPair[1] - 1
				bContiguous = TRUE
			ok

		
		next
*/
		

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
