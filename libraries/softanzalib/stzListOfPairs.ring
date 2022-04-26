
func StzListOfPairsQ(paLists)
	return new stzListOfPairs(paLists)

func RangeToSection(paRange)
	if isList(paRange) and Q(paRange).IsPairOfNumbers()
		n1 = paRange[1]
		n2 = paRange[2]

		aResult = [ n1, n1 + n2 - 1 ]
		return aResult
	else
		stzRaise("Incorrect param! paRange must be a pair of numbers.")
	ok

func SectionToRange(paRange)
	if isList(paRange) and Q(paRange).IsPairOfNumbers()
		n1 = paRange[1]
		n2 = paRange[2]

		aResult = [ n1, n2 - n1 + 1 ]
		return aResult
	else
		stzRaise("Incorrect param! paRange must be a pair of numbers.")
	ok

func ListThatHasMoreNumberOfItems(paList1, paList2)
	oList1 = new stzList(aList1)
	if oList1.HasMoreNumberOfItemsThen(paList2)
		return paList1
	else
		return paList2
	ok

func ListThatHasLessNumberOfItems(paList1, paList2)
	oList1 = new stzList(paList1)
	if oList1.HasLessNumberOfItemsThen(paList2)
		return paList1
	else
		return paList2
	ok

class stzListOfPairs from stzList
	@aContent = []

	def init(paLists)
		if isList(paLists) and
		   ( Q(paLists).IsEmpty() or Q(paLists).IsListOfPairs() )

			@aContent = paLists

		ok


	def Content()
		return @aContent

	def Pair()
		return This.Content()

	def ListOfPairs()
		return This.Content()

	def Copy()
		return new stzPair( This.Content() )

	def ToStzList()
		return new stzList( This.Pair() )

	def NumberOfPairs()
		return len(@aContent)

	def PairAt(n)
		return Content()[n]

	def FindPair(aPair)
		return This.ToStzList().FindItem(paPair)

	def PairsAreMadeOfEqualItems()
		bResult = TRUE
		for aPair in Content()
			if Q(aPair[1]).IsEqualTo(aPair[2])
				bResult = FALSE
			ok
		next
		return bResult

	def IsSortable()
		/*
		TODO
		*/

	def SortInAscending()

		/* TODO */

		def SortInAscendingQ()
			This.SortInAscending()
			return This

	def SortInDescending()

		/* TODO */

		def SortInDescendingQ()
			This.SortInDescending()
			return This

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
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.ExpandedIfPairsOfNumbers() )

			on :stzListOfLists
				return new stzListOfLists( This.ExpandedIfPairsOfNumbers() )

			other
				stzRaise("Unsupported type!")
			off
				
		#>

	  #-------------------------------------------------#
	 #   SWAPPING THE ITEMS IN THE PAIRS OF THE LIST   #
	#-------------------------------------------------#
		
	def Swap()
		aResult = []
		for aPair in This.ListOfPairs()
			temp = aPair[1]
			aPair[1] = aPair[2]
			aPair[2] = temp
		next

		def SwapQ()
			This.Swap()
			return This

	def Swapped()
		aResult = This.ListOfPairs()

		for aPair in aResult
			temp = aPair[1]
			aPair[1] = aPair[2]
			aPair[2] = temp
		next

		return aResult

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
		   This.ToStzList().MergeQ().IsSortedInAscending()

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
