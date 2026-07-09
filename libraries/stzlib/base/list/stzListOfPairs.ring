
#TODO
# Add CaseSensitivity

func StzListOfPairsQ(paLists)
	return new stzListOfPairs(paLists)

func RangeToSection(pnStart, pnRange)
	if NOT ( isNumber(pnStart) and isNumber(pnRange) )
		StzRaise("Incorrect param type! pnStart and pnRange must be noth numbers.")
	ok

	_aResult_ = [ pnStart, pnStart + pnRange - 1 ]
	return _aResult_


	func @RangeToSection(pnStart, pnRange)
		return RangeToSection(pnStart, pnRange)

func RangesToSections(panRanges)
	#TODO //
	# Replace for/in by for

	#UPDATE
	# Done!

	if CheckingParams()
		if not isList(panRanges)
			StzRaise("Incorrect param type! panRanges must be a list.")
		ok
	ok

	_nLen_ = len(panRanges)
	_anSections_ = []

	for i = 1 to _nLen_
		_anSections_ + @RangeToSection(panRanges[i][1], panRanges[i][2])
	next

	return _anSections_

func SectionToRange(n1, n2)
	if NOT (isNumber(n1) and isNumber(n2))
		StzRaise("Incorrect param types! n1 and n2 must be both numbers.")
	ok

	_anResult_ = [ n1, n2 - n1 + 1 ]
	return _anResult_

	func @SectionToRange(n1, n2)
		return SectionToRange(n1, n2)

func SectionsToRanges(paSections)
	#TODO //
	# Replace for/in by for

	#UPDATE
	# Done!

	if CheckingParams()
		if not isList(paSections)
			StzRaise("Incorrect param type! paSections must be a list.")
		ok
	ok

	_nLen_ = len(paSections)
	_anRanges_ = []
	
	for i = 1 to _nLen_
		_anRanges_ + @SectionToRange(paSections[i][1], paSections[i][2])
	next

	return _anRanges_

func ListThatHasMoreNumberOfItems(paList1, paList2)
	_oList1_ = new stzList(aList1)
	if _oList1_.HasMoreNumberOfItemsThen(paList2)
		return paList1
	else
		return paList2
	ok

func ListThatHasLessNumberOfItems(paList1, paList2)
	_oList1_ = new stzList(paList1)
	if _oList1_.HasLessNumberOfItems(:Then = paList2)
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
		if CheckingParams()
			if NOT ( isList(paLists) and @IsListOfPairs(paLists) )
				StzRaise("Can't create the StzListOfPairs object! You must provide a list of pairs.")
			ok
		ok

		@aContent = paLists


	def Content()
		return @aContent

		def Value()
			return Content()

	def Copy()
		return new stzListOfPairs( This.Content() )

	def ListOfPairs()
		return This.Content()

	def UpdateWith(paListOfPairs)
		if isList(paListOfPairs) and @IsListOfPairs(paListOfPairs)
			@aContent = paListOfPairs

		else
			StzRaise("Can't update the stzListOfPairs object! The value you provided is not a list of pairs.")
		ok

	def UpdatePairWith(n, paNewPair)
		if CheckingParams()
			if NOT (isNumber(n) and ( n = 1 or n = 2 ) )
				StzRaise("Incorrect param type! n must be a number equal to 1 or 2.")
			ok

			if NOT isList(paNewPair) and len(paNewPair) = 2
				StzRaise("Incorrect param type! paNewPair must be a list of 2 items.")
			ok
		ok

		_aContent_ = This.Content()
		_aContent_[n] = paNewPair
		This.UpdateWith(_aContent_)


		#< @FunctionAlternativeForms

		def UpdateNthPairWith(n, paNewPair)
			This.UpdatePairWith(n, paNewPair)

		def UpdatePairN(n, paNewPair)
			This.UpdatePairWith(n, paNewPair)

		def UpdatePair(n, paNewPair)
			This.UpdatePairWith(n, paNewPair)

		def UpdateNthPair(n, paNewPair)
			This.UpdatePairWith(n, paNewPair)

		#>

	def UpdateFirstPairWith(paNewPair)
		This.UpdatePairWith(1, paNewPair)

		def UpdatePair1With(paNewPair)
			This.UpdateFirstPairWith(paNewPair)

		def UpdateFirstPair(paNewPair)
			UpdateFirstPairWith(paNewPair)

		def UpdatePair1(paNewPair)
			This.UpdateFirstPairWith(paNewPair)

	def UpdateSecondPairWith(paNewPair)
		This.UpdatePairWith(2, paNewPair)

		def UpdatePair2With(paNewPair)
			This.UpdateSecondPairWith(paNewPair)

		def UpdateSecondPair(paNewPair)
			UpdateSecondPairWith(paNewPair)

		def UpdatePair2(paNewPair)
			This.UpdateSecondPairWith(paNewPair)

	def ToStzList()
		return new stzList( This.Content() )

	  #-------------------------------#
	 #  GETTING THE NUMBER OF PAIRS  #
	#-------------------------------#

	def NumberOfPairs()
		_nResult_ = len(@aContent)
		return _nResult_

	  #------------------------#
	 #  GETTING THE NTH PAIR  #
	#------------------------#

	def PairAt(n)
		return Content()[n]

		def PairAtQ(n)
			return This.PairAtQRT(n, :stzList)

		def PairAtQRT(n, pcReturnType)
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

			def PairQRT(n, pcReturnType)
				return This.PairAtQRT(n, pcReturnType)

	  #-------------------------------------------------#
	 #  FINDING POSITIONS OF A GIVEN PAIR IN THE LIST  #
	#-------------------------------------------------#

	def FindPair(paPair)
		# Was `This.FindItem(paPair)` -- FindItem isn't defined on
		# this class, stzListOfLists, or stzList. The whole method
		# raised R14 on every call. Route to the inherited Find that
		# accepts any value (including a 2-elem list literal).
		return This.FindFirst(paPair)

	  #------------------------------------------------------------------#
	 #  FINDING POSITIONS OF A VALUE IN THE LIST OF FIRST/SECOND ITEMS  #
	#------------------------------------------------------------------#

	def FindInFirstItems(pValue)
		_anResult_ = This.FirstItemsQ().Find(pValue)
		return _anResult_

	def FindInSecondItems(pValue)
		_anResult_ = This.SecondItemsQ().Find(pValue)
		return _anResult_

	  #---------------------------------------------#
	 #  CHECKING IF PAIRS ARE MADE OF EQUAL ITEMS  #
	#---------------------------------------------#

	def PairsAreMadeOfEqualItems()
		# Inverted-logic bug: was setting bResult = 0 when items ARE
		# equal; should be when items are NOT equal. Returned the
		# wrong answer on every call (including the typical
		# "yes, all pairs are equal" case).
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		_bResult_ = 1

		for i = 1 to _nLen_
			if NOT Q(_aContent_[i][1]).IsEqualTo(_aContent_[i][2])
				_bResult_ = 0
			ok
		next
		return _bResult_

	  #----------------------------#
	 #  FIRST ITEMS OF EACH PAIR  #
	#============================#

	def FirstItems()
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		_aResult_ = []

		for i = 1 to _nLen_
			_aResult_ + _aContent_[i][1]
		next

		return _aResult_

		#< @FunctionFluentForm

		def FirstItemsQ()
			return This.FirstItemsQRT(:stzList)

		def FirstItemsQRT(pcReturnType)
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
		_aResult_ = This.FirstItemsQ().WithoutDuplication()
		return _aResult_

		#< @FunctionFluentForm

		def FirstItemsUQ()
			return This.FirstItemsUQRT(:stzList)

		def FirstItemsUQRT(pcReturnType)
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
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		_aResult_ = []

		for i = 1 to _nLen_
			_aResult_ + _aContent_[i][2]
		next

		return _aResult_

		#< @FunctionFluentForm

		def SecondItemsQ()
			return This.SecondItemsQRT(:stzList)

		def SecondItemsQRT(pcReturnType)
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

		#--

		def LastItems()
			return This.SecondItems()

		def LastItemsOfEachPair()
			return This.SecondItems()

		def LastItemsInEachPair()
			return This.SecondItems()

		def LastValues()
			return This.SecondItems()

		def LastValuesOfEachPair()
			return This.SecondItems()

		def LastValuesInEachPair()
			return This.SecondItems()

		#>

	  #-----------------------------------------------------#
	 #  SECOND ITEMS OF EACH PAIR -- WITHOUT DUPPLICATION  #
	#-----------------------------------------------------#

	def SecondItemsU()
		_aResult_ = This.SecondItemsQ().WithoutDuplication()
		return _aResult_

		#< @FunctionFluentForm

		def SecondItemsUQ()
			return This.SecondItemsUQRT(:stzList)

		def SecondItemsUQRT(pcReturnType)
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
		if isList(paNewPair) and IsPair(paNewPair)
			This.UpdateNthPairWith(n, paNewPair)
		ok

		def ReplacePairQ(n, paNewPair)
			This.ReplacePair(n, paNewPair)
			return This

	def PairReplaced(n, paNewPair)
		_aResult_ = This.Copy().ReplacePairQ(n, paNewPair).Content()
		return _aResult_

	  #==============================#
	 #  SORTING PAIRS IN ASCENDING  #
	#==============================#

	def StringifyItems()
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		_aResult_ = []

		for i = 1 to _nLen_
			_aResult_ + [ Q(_aContent_[i][1]).Stringified(), Q(_aContent_[i][2]).Stringified() ]
		next

		This.Update(_aResult_)

		def StringifyItemsQ()
			This.StringifyItems()
			return This

	def ItemsStringified()
		_aResult_ = This.Copy().StringifyItemsQ().Content()
		return _aResult_

	  #=========================================#
	 #  SORTING THE LIST OF PAIRS IN ASCENDING  #
	#==========================================#


	def Sort()
		This.SortOn(1)

		def SortQ()
			This.Sort()
			return This

		def SortUp()
			This.Sort()

			def SortUpQ()
				return This.SortQ()

		def SortInAscending()
			This.Sort()

			def SortInAscendingQ()
				return This.SortQ()

	def Sorted()
		_aResult_ = This.Copy().SortQ().Content()
		return _aResult_

		def SortedInAscending()
			return This.Sorted()

		def SortedUp()
			return This.Sorted()

	  #-------------------------------------------#
	 #  SORTING THE LIST OF PAIRS IN DESCENDING  #
	#-------------------------------------------#

	def SortDown()
		This.SortOnDown(1)

		def SortDownQ()
			This.SortDown()
			return This

		def SortInDescending()
			This.SortDown()

			def SortInDescendingQ()
				return This.SortDownQ()

	def SortedDown()
		_aResult_ = This.Copy().SortDownQ().Content()
		return _aResult_

		def SortedInDescending()
			return This.Sorted()

	  #------------------------------------------------------------------#
	 #  SORTING THE PAIRS ON NTH (FIRST OR SECOND) COLUMN IN ASCENDING  #
	#==================================================================#

	def SortOn(n)
		_aResult_ = @SortOn(This.Content(), n)
		This.UpdateWith(_aResult_)

		#< @FunctionFluentForm

		def SortOnQ(n)
			This.SortOn(n)
			return This

		#>

		#< @FunctionAlternativeForms

		def SortOnInAscending(n)
			This.SortOn(n)

			def SortOnInAscendingQ(n)
				return This.SortOnQ(n)

		def SortOnUp(n)
			This.SortOn(n)

			def SortOnUpQ(n)
				return This.SortOnQ(n)

		#--

		def SortInAscendingOn(n)
			This.SortOn(n)

			def SortInAscendingOnQ(n)
				return This.SortOnQ(n)

		def SortUpOn(n)
			This.SortOn(n)

			def SortUpOnQ(n)
				return This.SortOnQ(n)

		#>

	def SortedOn(n)
		_aResult_ = This.Copy().SortOnQ(n).Content()
		return _aResult_

		#< @FunctionAlternativeForms

		def SortedOnInAscending(n)
			return This.SortedOn(n)

		def SortedOnUp(n)
			return This.SortedOn(n)

		#--

		def SortedInAscendingOn(n)
			return This.SortedOn(n)

		def SortedUpOn(n)
			return This.SortedOn(n)

		#>

	  #---------------------------------------------------------#
	 #  SORTING THE PAIRS DOWN ON NTH (FIRST OR SECOND) ITEMS  #
	#=========================================================#

	def SortOnInDescending(n)
		# Split the chain -- Ring's parser raises R13 on
		# `new stzList(...).Reversed()` (method-call directly off a
		# `new` expression). Same pattern fixed in
		# stzListOfNumbers.SortInDescending earlier this session.
		_aSoidAsc_ = This.SortedOnInAscending(n)
		_oSoidTmp_ = new stzList(_aSoidAsc_)
		_aSoidResult_ = _oSoidTmp_.Reversed()
		This.UpdateWith(_aSoidResult_)

		#< @FunctionFluentForm

		def SortOnInDescendingQ(n)
			This.SortOnInDescending(n)
			return This

		#>

		#< @FunctionAlternativeForms

		def SortInDescendingOn(n)
			This.SortOnInDescending(n)

			def SortInDescendingOnQ(n)
				return This.SortOnInDescendingQ(n)

		def SortOnDown(n)
			This.SortOnInDescending(n)

			def SortOnDownQ(n)
				return This.SortOnInDescendingQ(n)

		def SortDownOn(n)
			This.SortOnInDescending(n)

			def SortDownOnQ(n)
				return This.SortOnInDescendingQ(n)

		#>

	def SortedOnInDescending(n)
		_aResult_ = This.Copy().SortOnInDescendingQ(n).Content()
		return _aResult_

		#< @FunctionAlternativeForms

		def SortedInDescendingOn(n)
			return This.SortedOnInDescending(n)

		def SortedOnDown(n)
			return This.SortedOnInDescending(n)

		def SortedDownOn(n)
			return This.SortedOnInDescending(n)

		#>

	  #---------------------------------------------------------------#
	 #  SORTING THE PAIRS BY AN EVALUATED EXPRESSION - IN ASCENDING  #
	#===============================================================#
 
	def SortBy(pcExpr)

		if NOT (isString(pcExpr) and Q(pcExpr).ContainsCS("@pair", 0))
			StzRaise("Incorrect param! pcExpr must be a string containing @pair keyword.")
		ok

		pcExpr = Q(pcExpr).ReplaceQ("@pair", "@item").Content()

		_aContent_ = This.ToStzList().SortedBy(pcExpr)
		This.UpdateWith(_aContent_)

		#< @FunctionFluentForm

		def SortByQ(pcExpr)
			This.SortBy(pcExpr)
			return This

		#>

		#< @FunctionAlternativeForms

		def SortByInAscending(pcExpr)
			This.SortBy(pcExpr)

			def SortByInAscendingQ(pcExpr)
				return This.SortByQ(pcExpr)

		def SortByUp(pcExpr)
			This.SortBy(pcExpr)

			def SortByUpQ(pcExpr)
				return This.SortByQ(pcExpr)

		#>

	def SortedBy(pcExpr)
		_aResult_ = This.Copy().SortByQ(pcExpr).Content()
		return _aResult_

		def SortedByInAscending(pcExpr)
			return This.SortedBy(pcExpr)

		def SortedByUp(pcExpr)
			return This.SortedBy(pcExpr)

	  #------------------------------------------------------#
	 #  SORTING THE PAIRS BY AN EXPRESSION - IN DESCENDING  #
	#------------------------------------------------------#
 
	def SortByInDescending(pcExpr)
		This.SortByInAscending(pcExpr)
		This.Reverse()

		def SortByInDescendingQ(pcExpr)
			This.SortByInDescending(pcExpr)
			return This

		def SortByDown(pcExpr)
			This.SortByInDescending(pcExpr)

			def SortByDownQ(pcExpr)
				return This.SortByInDescendingQ(pcExpr)

	def SortedByInDescending(pcExpr)
		_aResult_ = This.Copy().SortByInDescendingQ(pcExpr).Content()
		return _aResult_

		def SortedByDown(pcExpr)
			return This.SortedByInDescending(pcExpr)

	  #==================================================================#
	 #  RETURNING AN EXPANDED LIST OF NUMBERS OUT OF THE LIST OF PAIRS  #
	#==================================================================#

	def ExpandedIfPairsOfNumbers()
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		_aResult_ = []

		for i = 1 to _nLen_
			if isNumber(_aContent_[i][1]) and isNumber(_aContent_[i][2])
				_aResult_ + StzListQ(_aContent_[i]).ExpandedIfPairOfNumbers()
			ok
		next

		return _aResult_

		#< @FunctionFluentForm

		def ExpandedIfPairsOfNumbersQ()
			return This.ExpandedIfPairsOfNumbersQRT(:stzList)

		def ExpandedIfPairsOfNumbersQRT(pcReturnType)
			if isList(pcReturnType) and IsOneOfTheseNamedParamsList(pcReturnType, [ :ReturnedAs, :ReturnAs ])
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
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)
		_aResult_ = []

		for i = 1 to _nLen_
			_aResult_ + [ _aContent_[i][2], _aContent_[i][1] ]
		next

		This.UpdateWith(_aResult_)

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

		#--

		def SwapPairs()
			This.SwapItems()

			def SwapPairsQ()
				return This.SwapItemsQ()

		def ReversePairs()
			This.SwapItems()

			def ReversePairsQ()
				return This.SwapItemsQ()

		def InversePairs()
			This.SwapItems()

			def InversePairsQ()
				return This.SwapItemsQ()

		#--

		def Reverse()
			This.SwapItems()

			def ReverseQ()
				return This.SwapItemsQ()

		def Inverse()
			This.SwapItems()

			def InverseQ()
				return This.SwapItemsQ()

		def Swap()
			This.SwapItems()

			def SwapQ()
				return This.SwapItemsQ()

		#>

	def ItemsSwapped()
		_aResult_ = This.Copy().SwapItemsQ().Content()
		return _aResult_

		#< @FunctionAlternativeForms

		def ItemsReversed()
			return This.ItemsSwapped()

		def ItemsInversed()
			return This.ItemsSwapped()

		#--

		def PairsSwapped()
			return This.ItemsSwapped()

		def PairsReversed()
			return This.ItemsSwapped()

		def PairsInversed()
			return This.ItemsSwapped()

		#--

		def Reversed()
			return This.ItemsSwapped()

		def Inversed()
			return This.ItemsSwapped()

		def Swapped()
			return This.ItemsSwapped()

		#>

	  #---------------------------------------------------------------#
	 #   CHECKING IF THE PAIRS ARE SECTIONS AND IF THEY ARE SORTED   #
	#---------------------------------------------------------------#
	#--> Each pair is made of numbers

	def IsListOfSections()

		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)	

		_bResult_ = 1

		for i = 1 to _nLen_
			if NOT @IsListOfNumbers(_aContent_[i])
				_bIsMadeOfNumbers_ = 0
				exit
			ok
		next

		return _bResult_

	def IsSortedListOfSections()

		if This.IsListOfSectionsSortedInAscending() or
		   This.IsListOfSectionsSortedInDescending()

			return 1

		else
			return 0
		ok

	def IsListOfSectionsSortedInAscending()

		_bResult_ = 0

		If This.IsListOfSections() and
		   This.ToStzList().MergeQ().IsSortedInAscending()

				_bResult_ = 1

		ok

		return _bResult_

	def IsListOfSectionsSortedInDescending()

		_bResult_ = 0
		_aSwapped_ = This.Swapped()

		If This.IsListOfSections() and
		   StzListQ(_aSwapped_).MergeQ().IsSortedInDescending()

				_bResult_ = 1

		ok

		return _bResult_

	  #---------------------------------------------#
	 #   CHECHKING IF AN ITEM EXISTS IN ANY PAIR   #
	#---------------------------------------------#

	def ContainsInAnyPair(pItem)
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		_bResult_ = 0
		
		for i = 1 to _nLen_
			if ListContains(_aContent_[i], pItem)
				_bResult_ = 1
				exit
			ok
		next

		return _bResult_

		#< @FunctionAlternativeForms

		def ContainsThisInAnyPair(pItem)
			return This.ContainsInAnyPair(pItem)

		def ContainsInAllPairs(pItem)
			return This.ContainsInAnyPair(pItem)

		def ContainsThisInAllPairs(pItem)
			return This.ContainsInAnyPair(pItem)

		def ContainsInside(pItem)
			return This.ContainsInAnyPair(pItem)

		def ContainsThisInside(pItem)
			return This.ContainsInAnyPair(pItem)

		#>

	  #===================================================#
	 #  CHECKING IF THE TWO VALUES ARE ANOGRAMS STRINGS  #
	#===================================================#

	def AreAnagramsCS(pCaseSensitive)

		_val1_ = This.FirstValue()
		_val2_ = This.SecondValue()

		if @BothAreStrings(_val1_, _val2_) and
		   Q(_val1_).IsAnagramOfCS(_val2_, pCaseSensitive)

			return 1
		else
			return 0
		ok

	def AreAnagrams()
		return This.AreAnagramsCS(1)

	  #===============================================#
	 #  CHECKING IF THE FIRST ITEMS ARE ALL NUMBERS  #
	#===============================================#

	def FirstItemsAreNumbers()
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		_bResult_ = 1

		for i = 1 to _nLen_
			if NOT isNumber(_aContent_[i][1])
				_bResult_ = 0
				exit
			ok
		next

		return _bResult_

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
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		_bResult_ = 1

		for i = 1 to _nLen_
			if NOT isString(_aContent_[i][1])
				_bResult_ = 0
				exit
			ok
		next

		return _bResult_

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
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		_bResult_ = 1

		for i = 1 to _nLen_
			if NOT @IsChar(_aContent_[i][1])
				_bResult_ = 0
				exit
			ok
		next

		return _bResult_

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
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		_bResult_ = 1

		for i = 1 to _nLen_
			if NOT isList(_aContent_[i][1])
				_bResult_ = 0
				exit
			ok
		next

		return _bResult_

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
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		_bResult_ = 1

		for i = 1 to _nLen_
			if NOT isObject(_aContent_[i][1])
				_bResult_ = 0
				exit
			ok
		next

		return _bResult_

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
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		_bResult_ = 1

		for i = 1 to _nLen_
			if NOT @IsStzObject(_aContent_[i][1])
				_bResult_ = 0
				exit
			ok
		next

		return _bResult_

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
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		_bResult_ = 1

		for i = 1 to _nLen_
			if NOT @IsStzChar(_aContent_[i][1])
				_bResult_ = 0
				exit
			ok
		next

		return _bResult_

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
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		_bResult_ = 1

		for i = 1 to _nLen_
			if NOT @IsStzString(_aContent_[i][1])
				_bResult_ = 0
				exit
			ok
		next

		return _bResult_

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
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		_bResult_ = 1

		for i = 1 to _nLen_
			if NOT @IsStzNumber(_aContent_[i][1])
				_bResult_ = 0
				exit
			ok
		next

		return _bResult_

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
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		_bResult_ = 1

		for i = 1 to _nLen_
			if NOT @IsStzList(_aContent_[i][1])
				_bResult_ = 0
				exit
			ok
		next

		return _bResult_

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
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		_bResult_ = 1

		for i = 1 to _nLen_
			if NOT @IsStzHashList(_aContent_[i][1])
				_bResult_ = 0
				exit
			ok
		next

		return _bResult_

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
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		_bResult_ = 1

		for i = 1 to _nLen_
			if NOT isNumber(_aContent_[i][2])
				_bResult_ = 0
				exit
			ok
		next

		return _bResult_

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
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		_bResult_ = 1

		for i = 1 to _nLen_
			if NOT isString(_aContent_[i][2])
				_bResult_ = 0
				exit
			ok
		next

		return _bResult_

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
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		_bResult_ = 1

		for i = 1 to _nLen_
			if NOT @IsChar(_aContent_[i][2])
				_bResult_ = 0
				exit
			ok
		next

		return _bResult_

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
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		_bResult_ = 1

		for i = 1 to _nLen_
			if NOT isList(_aContent_[i][2])
				_bResult_ = 0
				exit
			ok
		next

		return _bResult_

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
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		_bResult_ = 1

		for i = 1 to _nLen_
			if NOT isObject(_aContent_[i][2])
				_bResult_ = 0
				exit
			ok
		next

		return _bResult_

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
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		_bResult_ = 1

		for i = 1 to _nLen_
			if NOT @IsStzObject(_aContent_[i][2])
				_bResult_ = 0
				exit
			ok
		next

		return _bResult_

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
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		_bResult_ = 1

		for i = 1 to _nLen_
			if NOT @IsStzChar(_aContent_[i][2])
				_bResult_ = 0
				exit
			ok
		next

		return _bResult_

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
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		_bResult_ = 1

		for i = 1 to _nLen_
			if NOT @IsStzString(_aContent_[i][2])
				_bResult_ = 0
				exit
			ok
		next

		return _bResult_

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
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		_bResult_ = 1

		for i = 1 to _nLen_
			if NOT @IsStzNumber(_aContent_[i][2])
				_bResult_ = 0
				exit
			ok
		next

		return _bResult_

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
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		_bResult_ = 1

		for i = 1 to _nLen_
			if NOT @IsStzList(_aContent_[i][2])
				_bResult_ = 0
				exit
			ok
		next

		return _bResult_

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
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		_bResult_ = 1

		for i = 1 to _nLen_
			if NOT @IsStzHashList(_aContent_[i][2])
				_bResult_ = 0
				exit
			ok
		next

		return _bResult_

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

		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		_aHash_ = []

		for i = 1 to _nLen_
			_aHash_ + [ _aContent_[i][1], [ _aContent_[i][2] ] ]
		next

		_oResult_ = new stzHashList(_aHash_)
		return _oResult_


	def ToStzListOfSections()
		return new stzListOfSections(This.Content())

	def ToStzSetOfSections()
		return new stzSetOfSections(This.Content())
