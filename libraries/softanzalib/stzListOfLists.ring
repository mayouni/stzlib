#---------------------------------------------------------------------------#
# 		    SOFTANZA LIBRARY (V1.0) - STZLISTOFLISTS		    #
#		An accelerative library for Ring applications		    #
#---------------------------------------------------------------------------#
#									    #
# 	Description	: The core class for managing lists of lists        #
#	Version		: V1.0 (2020-2022)				    #
#	Author		: Mansour Ayouni (kalidianow@gmail.com)		    #
#									    #
#---------------------------------------------------------------------------#

func StzListOfListsQ(paList)
	return new stzListOfLists(paList)

func LL(p)
	if isList(p)
		return StzListQ(p).OnlyLists()

	but isString(p) and Q(p).IsListInString()
		aResult = Q(p).ToListQ().OnlyLists()
		return aResult

	but isNumber(p)
		aResult = []
		for i = 1 to p
			aResult + []
		next
		return aResult

	ok

	func LLQ(p)
		return Q(LL(p))

		func QLL(p)
			return LLQ(p)

	func LoL(p)
		return LL(p)

		func LoLQ(p)
			return LLQ(p)

func ItemExists(pItem, paList)
	oTempList = new stzList(paList)
	if oTempList.Contains(pItem) 
		return TRUE
	else
		return FALSE
	ok

func ListsMerge(paListOfLists)
	return StzListOfListsQ(paListOfLists).Merged()

	func ListsMergeQ(paListOfLists)
		return new stzList( ListsMerge(paListOfLists) )

func ListsFlatten(paListOfLists)
	return StzListOfListsQ(paListOfLists).Flattened()


func Association(paLists)
	if NOT ( isList(paLists) and Q(paLists).IsListOfLists() )
		StzRaise("Incorrect param type! paLists must be a list of lists.")
	ok

	if len(paLists) < 2
		StzRaise("Can't proceed! paLists must contain at least two lists.")
	ok

	aFirstList = paLists[1]
	aLastList = paLists[ len(paLists) ]

	if isList(aFirstList) and Q(aFirstList).IsOfNamedParam()
		paLists[1] = aFirstList[2]
	ok

	if isList(aLastList) and Q(aLastList).IsAndOrWithNamedParam()
		paLists[ len(paLists) ] = aLastList[2]
	ok

	aResult = StzListOfListsQ(paLists).Associated()
	return aResult

class stzListOfLists from stzList

	@aContent = []

	def init(paList)

		if isList(paList) and
		   ( Q(paList).IsEmpty() or Q(paList).IsListOfLists() )

			@aContent = paList

		else
			StzRaise("Can't create the stzListOfLists object!")
		ok

	  #--------------#
	 #   GENERAL    #
	#--------------#

	def Content()
		return @aContent

	def ListOfLists()
		return This.Content()

	def Copy()
		oCopy = new stzListOfLists( This.Content() )
		return oCopy

	def NumberOfLists()
		return len(@aContent)

	def Update( paList )

		if isList(paList) and Q(paList).IsListOfLists()

			@aContent = paList

		else
			StzRaise([
				:File = "stzListOfLists (541) > Update()",
				:What = "Can't update the list of lists!",
				:Why  = "The value you provided is not a list of lists."
			])
		ok

	  #----------------#
	 #   ADD LISTS    #
	#----------------#

	def AddList(paList)
		@aContent + paList

	def AddMany(paListOfLists)
		nLen = len(paListOfLists)
		for i = 1 to nLen
			@aContent + paListOfLists[i]
		next

	  #---------------#
	 #   NTH LIST    #
	#---------------#

	def NthList(n)
		if isString(n)
			if n = :First or n = :FirstList
				n = 1

			but n = :First or n = :FirstList
				n = This.NumberOfLists()

			ok
		ok

		if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		return This.ListOfLists()[n]

		#< @FunctionFluentForm
		
		def NthListQ(n)
			return new stzList( This.NthList(n) )

		#>

		#< @FunctionAlternativeForms

		def ListAt(n)
			return This.NthList()

			def ListAtQ(n)
				return This.NthListQ(n)

		def ListAtPosition(n)
			return This.NthList(n)

			def ListAtPositionQ(n)
				return This.NthListQ(n)

		#>

	def FirstList()
		return This.NthList(1)

	def LastList()
		return This.NthList( This.NumberOfLists() )

	  #------------------#
	 #   LISTS WHERE    #
	#------------------#

	def ListsW(pcCondition)

		cCondition = StzStringQ(pcCondition).RemoveBoundsQ(["{","}"]).Simplified()
		aResult = []

		aListOfLists = This.ListOfLists()
		nLen = len(aListOfLists)

		for @i = 1 to nLen 
			@list = aListOfLists[@i]

			@item = @list # Allows using both @list and @item in the user's script
			cCode = "if " + cCondition + NL +
				TAB + "aResult + @list" + NL +
			"ok"

			eval(cCode)
		next

		return aResult

		#< @FunctionFluentForm

		def ListsWQ(pcCondition)
			return new stzList( This.ListsW(pcCondition) )

		#>

		#< @FunctionAlternativeForm

		def ListsWhere(pcCondition)
			return This.ListsW(pcCondition)

			#< @FunctionFluentForm

			def ListsWhereQ(pcCondition)
				return new stzList(This.ListsWhere(pcCondition))

			#>
		#>

	  #----------------------#
	 #   POSITIONS WHERE    #
	#----------------------#

	def PositionsW(pcCondition)

		cCondition = StzStringQ(pcCondition).RemoveBoundsQ(["{","}"]).Simplified()
		aResult = []

		aListOfLists = This.ListOfLists()
		nLen = len(aListOfLists)

		for @i = 1 to nLen 
			@list = aListOfLists[@i]

			@item = @list # Allows using both @list and @item in the user's script
			cCode = "if " + cCondition + NL +
				TAB + "aResult + @i" + NL +
			"ok"

			eval(cCode)
		next

		return aResult

		#< @FunctionFluentForm

		def PositionsWQ(pcCondition)
			return new stzList( This.PositionsW(pcCondition) )

		#>

		#< @FunctionAlternativeForm

		def PositionsWhere(pcCondition)
			return This.PositionsW(pcCondition)

			#< @FunctionFluentForm

			def PositionsWhereQ(pcCondition)
				return new stzList(This.PositionsWhere(pcCondition))

			#>
		#>

	  #-------------------------------------------#
	 #   SIZES, AND SMALLEST AND BIGGEST SIZES   #
	#-------------------------------------------#

	def Sizes()
		aResult = []
		aListOfLists = This.ListOfLists()
		nLen = len(aListOfLists)

		for i = 1 to nLen
			aResult + len(aListOfLists[i])
		next

		return aResult

	def ListsHaveSameNumberOfItems()
		bResult = TRUE
		
		for i = 2 to This.NumberOfLists()
			if len( This.NthList(i) ) != len( This.NthList(i-1) )
				bResult = FALSE
				exit
			ok
		next

		return bResult

		#< @FunctionAlternativeForms

		def IsHomologuous()
			return This.ListsHaveSameNumberOfItems()

		def IsHomolog()
			return This.ListsHaveSameNumberOfItems()

		#--

		def HaveSameNumberOfItems()
			return This.ListsHaveSameNumberOfItems()

		def HasSameNumbersOfItems()
			return This.ListsHaveSameNumberOfItems()

		#--

		def ListsHaveSameSize()
			return This.ListsHaveSameNumberOfItems()

		def HaveSameSize()
			return This.ListsHaveSameNumberOfItems()

		def HasSameSizes()
			return This.ListsHaveSameNumberOfItems()

		#>

	  #--------------------------------#
	 #   SMALLEST AND BIGGEST LISTS   #
	#--------------------------------#

	def SmallestLists()

		nLen = This.NumberOfLists()
		nSmallestSize = This.SmallestSize()

		aResult = []

		for i = 1 to nLen
			nLenList = This.SizeOfList(i)

			if nLenList = nSmallestSize
				aResult + This.NthList(i)
				# WARNING: You can't say List(i) because
				# the class inherits stzList that contains
				# the same fuction!
			ok
		next

		return aResult

	# TODO: adds "big", "great", and "large" as alternatives al over the library
	def BiggestLists()
		aListOfLists = This.Content()
		nLen = len(aListOfLists)
		nBiggestSize = This.BiggestSize()

		aResult = []

		for i = 1 to nLen
			aList = aListOfLists[i]
			nLenList = len(aList)

			if nLenList = nBiggestSize
				aResult + aList
			ok
		next

		return aResult

		def GreatestLists()
			return This.BiggestLists()

		def LargestLists()
			return This.BiggestLists()

	def FindSmallestLists()

		aListOfLists = This.Content()
		nLen = len(aListOfLists)

		aResult = []
		nSmallestSize = This.SmallestSize()

		for i = 1 to nLen
			aList = aListOfLists[i]
			nLenList = len(aList)

			if nLenList = nSmallestSize
				aResult + i
			ok

		next

		return aResult

		def FindMinLists()
			return This.FindSmallestLists()

		def PositionsOfSmallestLists()
			return This.FindSmallestLists()

		def SmallestListsPositions()
			return This.FindSmallestLists()

		def PositionsOfMinLists()
			return This.FindSmallestLists()

		def MinListsPositions()
			return This.FindSmallestLists()

	def FindBiggestLists()
		return This.PositionsW('{ len(@list) = This.BiggestSize() }')

		def FindMaxLists()
			return This.FindBiggestLists()

		def PositionsOfBiggestLists()
			return This.FindBiggestLists()

		def BiggestListsPositions()
			return This.FindBiggestLists()

		def PositionsOfMaxLists()
			return This.FindBiggestLists()

		def MaxListsPositions()
			return This.FindBiggestLists()

		#--

		def FindGeatestLists()
			return This.FindBiggestLists()

		def PositionsOfGreatestLists()
			return This.FindBiggestLists()

		def GreatestListsPositions()
			return This.FindBiggestLists()

		#--

		def FindLargestLists()
			return This.FindBiggestLists()

		def PositionsOfLargestLists()
			return This.FindBiggestLists()

		def LargestListsPositions()
			return This.FindBiggestLists()

	  #---------------------#
	 #   LISTS OF SIZE N   #
	#---------------------#

	def ListsOfSizeN(n)
		return This.ListsW('{ len(@list) = ' + n + ' }')

		#< @FunctionAlternativeForm

		def ListsOfSize(n)
			return This.ListsOfSizeN(n)

		#>

	def PositionsOfListsOfSizeN(n)
		return This.PositionsW('{ len(@list) = ' + n + ' }')

		#< @FunctionAlternativeForm

		def ListsOfSizeNPositions(n)
			return This.PositionsOfListsOfSizeN(n)

		def PositionsOfListsOfSize(n)
			return This.PositionsOfListsOfSizeN(n)

		#>

	  #--------------------------#
	 #   ITEMS AT POSITION N    #
	#--------------------------#

	def ItemsAtPositionN(n)
		aResult = []

		aListOfLists = This.ListOfLists()
		nLen = len(aListOfLists)

		for i = 1 to nLen
			aList = aListOfLists[i]
			if len(aList) >= n
				aResult + aList[n]
			ok
		next

		return aResult

		#< @FunctionFluentForm

		def ItemsAtPositionNQ(n)
			return This.ItemsAtPositionNQR(n, :stzList)

		def ItemsAtPositionsNQR(n, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			if NOT isString(pcReturnType)
				StzRaise("Incorrect param! pcReturnType must be a string.")
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.ItemsAtPositionN(n) )

			on :stzListOfLists
				return new stzListOfLists( This.ItemsAtPositionN(n) )

			on :stzListOfPairs
				return new stzListOfPairs( This.ItemsAtPositionN(n) )

			other
				StzRaise("Unsupported return type!")
			off

		#>

		#< @FunctionAlternativeForms

		def ItemsAt(n)
			return This.ItemsAtPositionN(n)

			def ItemsAtQ(n)
				return This.ItemsAtPositionNQR(n, :stzList)

			def ItemsAtQR(n, pcReturnType)
				return This.ItemsAtPositionNQR(n, pcReturnType)

		def ItemsAtPosition(n)
			return This.ItemsAtPositionN(n)

			def ItemsAtPositionQ(n)
				return This.ItemsAtPositionQR(n, :stzList)

			def ItemsAtPositionQR(n, pcReturnType)
				return This.ItemsAtPositionQR(n, pcReturnType)

		def ListsAtPositionN(n)
			return This.ItemsAtPositionN(n)

			def ListsAtPositionNQ(n)
				return This.ListsAtPositionNQR(n, :stzList)

			def ListsAtPositionNQR(n, pcReturnType)
				return This.ListsAtPositionNQR(n, pcReturnType)

		def ListsAt(n)
			return This.ItemsAtPositionN(n)

			def ListsAtQ(n)
				return This.ListsAtQR(n, :stzList)

			def ListsAtQR(n, pcReturnType)
				return This.ListsAtQR(n, pcReturnType)

		def ListsAtPosition(n)
			return This.ItemsAtPositionN(n)

			def ListsAtPositionQ(n)
				return This.ListsAtPositionQR(n, :stzList)

			def ListsAtPositionQR(n, pcReturnType)
				return This.ListsAtPositionQR(n, pcReturnType)

		#>

	  #=================#
	 #  SMALLEST LIST  #
	#=================#

	def FindSmallestList()
		nLen = This.NumberOfLists()
		if nLen = 0
			return NULL

		but nLen = 1
			return This.NthList(1)
		ok

		nResult = 1
		for i = 2 to nLen
			if len( This.NthList(i) ) < len( This.NthList(nResult) )
				nResult = i
			ok
		next

		return nResult

		def FindSmallest()
			return This.FindSmallestList()

	def SmallestList()
		# Returns the smallest list
		# If they are many, returns only the first
		# To return them all, use SmallestLists()

		nLen = This.NumberOfLists()
		if nLen = 0
			return NULL

		but nLen = 1
			return This.NthList(1)
		ok

		nPos = 1
		for i = 2 to nLen
			if len( This.NthList(i) ) < len( This.NthList(nPos) )
				nPos = i
			ok
		next

		aResult = This.NthList(nPos)
		return aResult

		def Smallest()
			return This.SmallestList()

	  #-------------------------#
	 #  SIZE OF SMALLEST LIST  #
	#-------------------------#

	def SizeOfSmallestList()
		nResult = len( This.SmallestList() )
		return nResult

		def SmallestListSize()
			return This.SizeOfSmallestList()

		def SmallestSize()
			return This.SizeOfSmallestList()

	  #----------------#
	 #  LARGEST LIST  #
	#----------------#

	def FindLargestList()
		nLen = This.NumberOfLists()
		if nLen = 0
			return NULL

		but nLen = 1
			return This.NthList(1)
		ok

		nResult = 1
		for i = 2 to nLen
			if len( This.NthList(i) ) > len( This.NthList(nResult) )
				nResult = i
			ok
		next

		return nResult

		def FindLargest()
			return This.FindLargestList()

	def LargestList()
		
		nLen = This.NumberOfLists()
		if nLen = 0
			return NULL

		but nLen = 1
			return This.NthList(1)
		ok

		nPos = 1
		for i = 2 to nLen
			if len( This.NthList(i) ) > len( This.NthList(nPos) )
				nPos = i
			ok
		next

		aResult = This.NthList(nPos)
		return aResult


		def BiggestList()
			return This.LargestList()

		def Largest()
			return This.LargestList()

		def Biggest()
			return This.LargestList()

	  #------------------------#
	 #  SIZE OF LARGEST LIST  #
	#------------------------#

	def SizeOfLargestList()
		nResult = len( This.LargestList() )
		return nResult

		def LargestListSize()
			return This.SizeOfLargestList()

		def LargestSize()
			return This.SizeOfLargestList()

		def SizeOfBiggestList()
			return This.SizeOfLargestList()

		def BiggestListSize()
			return This.SizeOfLargestList()

		def BiggestSize()
			return This.SizeOfLargestList()
	
	  #---------------------#
	 #  SIZE OF NTH LIST   #
	#---------------------#

	def SizeOfList(n)
		nResult = len( This.NthList(n) )
		return nResult

		def Size(n)
			return This.SizeOfList(n)

		def SizeOfNthList(n)
			return This.SizeOfList(n)

		def NumberOfItemsOfList(n)
			return This.SizeOfList(n)

	  #==============================================#
	 #  EXTENDING (EACH LIST IN) THE LIST OF LISTS  #
	#==============================================#

	def Extend()
		This.ExtendTo( This.SizeOfLargestList() )

		#< @FunctionFluentForm

		def ExtendQ()
			This.Extend()
			return This

		#>

		#< @FunctionAlternativeForm

		def ExtendEachList()
			This.Extend()

			def ExtendEachListQ()
				This.ExtendEachList()
				return This

		#>

	def Extended()
		aResult = This.Copy().ExtendQ().Content()
		return aResult

		def ExtendedEachList()
			return This.Extended()

	  #----------------------------------------------------------------#
	 #  EXTENDING (EACH LIST IN) THE LIST OF LISTS WITH A GIVEN ITEM  #
	#----------------------------------------------------------------#

	def ExtendXT(pItem)
		This.ExtendToXT( This.SizeOfLargestList(), pItem )

		#< @FunctionFluentForm

		def ExtendXTQ(pItem)
			This.ExtendXT(pItem)
			return This

		#>

		#< @FunctionAlternativeForm

		def ExtendEachListXT(pItem)
			This.ExtendXT(pItem)

			def ExtendEachListXTQ(pItem)
				This.ExtendEachListXT(pItem)
				return This

		#>

	def ExtendedXT(pItem)
		aResult = This.Copy().ExtendXTQ(pItem).Content()
		return aResult

		def ExtendedEachListXT(pItem)
			return This.ExtendedXT(pItem)

	  #------------------------------------------------------------------------------------#
	 #  EXTENDING (EACH LIST IN) THE LIST OF LISTS TO A GIVEN POSITION WITH A NULL VALUE  #
	#------------------------------------------------------------------------------------#

	def ExtendTo(n)
		This.ExtendToXT(n, NULL)

		def ExtendToQ(n)
			This.ExtendTo(n)
			return This

		def ExtendToPosition(n)
			if NOT isNumber(n)
				StzRaise("Incorrect param type! n must be a number.")
			ok

			This.ExtendTo(n)

	def ExtendedTo(n)
		aResult = This.Copy().ExtendToQ(n).Content()
		return aResult

		def ExtendedToPosition(n)
			if NOT isNumber(n)
				StzRaise("Incorrect param type! n must be a number.")
			ok

			return This.ExtendedTo(n)	

	  #------------------------------------------------------------------------------------#
	 #  EXTENDING (EACH LIST IN) THE LIST OF LISTS TO A GIVEN POSITION WITH A GIVEN ITEM  #
	#------------------------------------------------------------------------------------#

	def ExtendToXT(n, pItem)
		if isList(n) and Q(n).IsPositionNamedParam()
			n = n[2]
		ok

		if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		if isList(pItem) and Q(pItem).IsUsingOrWithOrByNamedParam()
			pItem = pItem[2]
		ok

		# Doing the job

		nLen = This.NumberOfLists()
		for i = 1 to nLen
			nSize = This.SizeOfList(i)

			aTemp = This.NthList(i)
			for j = 1 to n - nSize
				aTemp + pItem
			next

			This.ReplaceItemAt(i, aTemp)

		next

		#< @FunctionFluentForm

		def ExtendToXTQ(n, pItem)
			This.ExtendToXT(n, pItem)
			return This

		#>

		#< @FunctionAlternativeForm

		def ExtendToPositionXT(n, pItem)
			This.ExtendToXT(n, pItem)

			def ExtendToPositionXTQ(n, pItem)
				This.ExtendToPositionXT(n, pItem)
				return This

		#>

	def ExtendedToXT(n, pItem)
		aResult = This.Copy().ExtendToQ(n).Content()
		return aResult

		def ExtendedToPositionXT(n, pItem)
			if NOT isNumber(n)
				StzRaise("Incorrect param type! n must be a number.")
			ok

			return This.ExtendedToXT(n, pItem)	

	  #================================#
	 #  SHRINKING THE LIST OF LISTS   #
	#================================#

	def Shrink()
		This.ShrinkTo( This.SizeOfSmallestList() )

		def ShrinkQ()
			This.Shrink()
			return This

	def Shrinked()
		aResult = This.Copy().ShrinkQ().Content()
		return aResult

	  #------------------------------------------------------------------#
	 #  SHRINKING (EACH LIST IN) THE LIST OF LISTS TO A GIVEN POSITION  #
	#------------------------------------------------------------------#

	def ShrinkTo(n)
		if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		nLen = This.NumberOfLists()
		for i = 1 to nLen
			nSize = This.SizeOfList(i)

			aTemp = []
			if n < nSize
				aTemp = This.NthListQ(i).Section(1, n)
				This.ReplaceItemAt(i, aTemp)
			ok

		next

		#< @FunctionFluentForm

		def ShrinkToQ(n)
			This.ShrinkTo(n)
			return This

		#>

		#< @FunctionAlternativeForm

		def ShrinkToPosition(n)
			This.ShrinkTo(n)

			def ShrinkToPositionQ(n)
				This.ShrinkToPosition(n)
				return This

		#>

	def ShrinkedTo(n)
		aResult = This.Copy().ShrinkToQ(n).Content()
		return aResult

		def ShrinkedToPosition(n)
			if NOT isNumber(n)
				StzRaise("Incorrect param type! n must be a number.")
			ok

			return This.ShrinkedTo(n)

	  #========================================#
	 #   ASSOCIATING THE LISTS ITEM BY ITEM   #
	#========================================#

	def Associate()
		if This.IsEmpty() or This.NumberOfLists() = 1
			StzRaise("Can't proceed! The list must contain at least 2 lists.")
		ok

		if This.AllItemsAreEmptyLists()
			StzRaise("Can't associate empty lists!")
		ok

		This.Extend()

		nLen = This.NumberOfLists()
		nItems = len(This.FirstList())

		aResult = []

		for i = 1 to nItems

			aTempList = []

			for j = 1 to nLen
				aTempList + This.NthList(j)[i]
			next

			aResult + aTempList
		next

		This.Update(aResult)

		#< @functionFluentForm

		def AssociateQ()
			This.Associate()
			return This

		#>

	def Associated()
		aResult = This.Copy().AssociateQ().Content()
		return aResult

	  #-------------------------------------#
	 #   REVERSING THE ITEMS OF THE LIST   #
	#-------------------------------------#

	# To avoid confusion, it's better to use the alternative forms
	# ReverseItems() and ItemsReversed()

	def ReverseLists()

		aResult = ring_reverse(This.ListOfLists())

		This.Update( aResult )

		def ReverseListsQ()
			This.ReverseLists()
			return This

		def ReverseItems()
			This.ReverseLists()

			def ReverseItemsQ()
				This.ReverseItems()
				return This

		def Reverse()
			This.ReverseLists()

			def ReverseQ()
				This.Reverse()
				return This

	def ReversedLists()
		aResult = This.Copy().ReverseListsQ().Content()
		return aResult

		#< @FunctionAlternativeForms

		def ListsReversed()
			return This.ReversedLists()

		def Reversed()
			return This.ReversedLists()

		def ReversedItems()
			return This.ReversedLists()

		#>

	  #--------------------------------------#
	 #   REVERSING ITEMS INSIDE THE LISTS   #
	#--------------------------------------#

	def ReverseItemsInLists()
		aListOfLists = This.ListOfLists()
		nLen = len(aListOfLists)

		for i = 1 to nLen
			@aContent[i] = Q(aListOfLists[i]).Reversed()
		next

		def ReverseItemsInListsQ()
			This.ReverseItemsInLists()
			return This

		def ReverseListsContent()
			This.ReverseItemsInLists()

			def ReverseListsContentQ()
				This.ReverseListsContent()
				return This

	def ItemsInListsReversed()
		aResult = This.Copy().ReverseItemsInListsQ().Content()
		return aResult

		def ListsContentReversed()
			return This.ItemsInListsReversed()

	  #---------------#
	 #   INDEXING    #
	#---------------#

	def Index()
		return This.IndexByPosition()

	def Indexed()
		return This.Index()

	#--

	def IndexByPosition()
		return This.IndexBy(:Position)

		def IndexOnPosition()
			return This.IndexByPosition()

	def IndexedByPosition()
		return This.IndexByPosition()

		def IndexedOnPosition()
			return This.IndexedByPosition()

	#--

	def IndexNyNumberOfOccurrence()
		return This.IndexBy(:NumberOfOccurrence)

		def IndexByNumberOfOccurrences()
			return This.IndexByNumberOfOccurrence()

		def IndexOnNumberOfOccurrence()
			return This.IndexByNumberOfOccurrence()

		def IndexOnNumberOfOccurrences()
			return This.IndexByNumberOfOccurrence()

	def IndexedByNumberOfOccurrence()
		return This.IndexByNumberOfOccurrence()

		def IndexedByNumberOfOccurrences()
			return This.IndexedByNumberOfOccurrence()

		def IndexedOnNumberOfOccurrence()
			return This.IndexedByNumberOfOccurrence()

		def IndexedOnNumberOfOccurrences()
			return This.IndexedByNumberOfOccurrence()

	#--

	def IndexBy(pcOn) # pcOn can be :NumberOfOccurrence(s) or :Position
		/*
		Problem:

			Let:

			a1 = [ "A", "A", "B", "C" ]
			a2 = [ "B", "A", "C", "B", "A", "X" ]

			Getting the index of each list alone, by number of
			occurrence for example, is simply done by calling
			the method IndexBy(:NumberOfOccurrence) of stzList,
			so we get:

			Index(a1) --> [ :A = 2, :B = 1, :C = 1 ]
		   	Index(a2) --> [ :A = 2, :B = 1, :C = 1, :X = 1 ]

			What we need is to make the Index of these TWO lists
			togethor so we can have:

			[ :A = [2,2] , :B = [1,2] , :C = [1,1] , :X = [0,1] ]

			Note: we shloumd be able tp do it for any number of lists...
		*/

		aIndexes = []
		aListOfLists = This.Content()
		nLen = len(aListOfLists)

		for i = 1 to nLen
			oTempList = new stzList( aListOfLists[i] )
			aIndexes + oTempList.IndexBy(pcOn)
		next
		// aIndexes => [ [ :A = 2, :B = 1, :C = 1 ],
		//		 [ :A = 2, :B = 1, :C = 1, :X = 1 ] ]	


		aKeys = This.ToStzList().MergeQ().DuplicatesRemoved()
		// aKeys => [ :A, :B, :C, :X ]
		
		nLenKeys = len(aKeys)
		nLenIndexes = len(aIndexes)
		aResult = []

		for i = 1 to nLenKeys
			key = aKeys[i]
			aValues = []

			for v = 1 to nLenIndexes
				aIndex = aIndexes[v]
				value = aIndex[key]
				
				if pcOn = :NumberOfOccurrence or pcOn = :NumberOfOccurrences
					if isString(value) and value = NULL
						value = 0
					ok

					aValues + value

				but pcOn = :Position
					aPositions = value
					/* aPositions = [ 1, 3 , 2 ]
					   => [ (i,1) , (i,3) , (i,2) ]
					*/
					nLenPositions = len(aPositions)

					for q = 1 to nLenPositions 
						aValues + [ v, aPositions[q] ]
					next
				ok
			next
			aResult + [ key, aValues ]
		next
		// aIndex => [ :A = [2,2] , :B = [1,2] , :C = [1,1] , :X = [0,1] ]

		return aResult

		def IndexOn(pcOn)
			return This.IndexBy(pcOn)

	def IndexedBy(pcOn)
		return This.IndexBy(pcOn)

		def IndexedOn(pcOn)
			return This.IndexedBy(pcOn)

	  #------------#
	 #   ENTRY    #
	#------------#

	def EntryByPosition(pEntry)
		return This.Entry(pEntry, :ByPosition)

	def EntryByNumberOfOccurrence(pEntry)
		return This.Entry(pEntry, :ByNumberOfOccurrence)

		def EntryByNumberOfOccurrences(pEntry)
			return This.EntryByNumberOfOccurrence(pEntry)

	def Entry(pEntry,pcBy)
		if pcBy = :ByPosition
			return This.IndexOn(:Position)[pEntry]

		but pcBy = :ByNumberOfOccurrence or pcBy = :ByNumberOfOccurrences
			return This.IndexOn(:NumberOfOccurrence)[pEntry]
		ok

	  #-----------------------------------------#
	 #   OCCURRENCE OF AN ENTRY IN THE INDEX   #
	#-----------------------------------------#

	def NumberOfOccurrenceOfEntry(pEntry)
		return len(o1.IndexOn(:Position)[pEntry])

		def NumberOfOccurrencesOfEntry(pEntry)
			return This.NumberOfOccurrenceOfEntry(pEntry)

	def NthOccurrenceOfEntry(n, pEntry)
		return o1.IndexOn(:Position)[pEntry][n]

		def NthOccurrencesOfEntry(n, pEntry)
			return This.NthOccurrenceOfEntry(n, pEntry)

	def FirstOccurrenceOfEntry(pEntry)
		return NthOccurrenceOfEntry(1, pEntry)

	def LastOccurrenceOfEntry(pEntry)
		return NthOccurrenceOfEntry(This.NumberOfOccurrenceOfEntry(pEntry), pEntry)

	  #------------------#
	 #   CONTAINMENT    #
	#------------------#

	def ContainsItem(pItem)
		bResult = FALSE
		aListOfLists = This.ListOfLists()
		nLen = len(aListOfLists)

		for i = 1 to nLen
			oStzList = new stzList( aListOfLists[i] )
			if oStzList.Contains(pItem)
				bResult = TRUE
				exit
			ok
		next

		return bResult

	def ListsContainingItem(pItem)
		aResult = []
		aListOfLists = This.ListOfLists()
		nLen = len(aListOfLists)

		for i = 1 to nLen
			oStzList = new stzList(aListOfLists[i])
			if oStzList.Contains(pItem)
				aResult + list
			ok
		next
		return aResult

	  #-----------------------------------------------------#
	 #   MERGING THE LISTS AND RETURNING ONE MERGED LIST   #
	#-----------------------------------------------------#

	def Merge()

		aResult = []
		nLenLists = This.NumberOfLists()
		aContent = This.Content()

		for i = 1 to nLenLists
			aList = aContent[i]
			nLenList = len(aList)

			for v = 1 to nLenList
				aResult + aList[v]
			next
		next

		return aResult

		def MergeQ()
			return This.MergeQR(:stzList)

		def MergeQR(pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.Merged() )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.Merged() )

			on :stzListOfStrings
				return new stzListOfStrings( This.Merged() )

			on :stzListOfChars
				return new stzListOfChars( This.Merged() )

			on :stzListOfPairs
				return new stzListOfPairs( This.Merged() )

			on :stzListOfLists
				return new stzListOfLists( This.Merged() )

			other
				StzRaise("Unsupported return type!")
			off
	def Merged()
		return This.Merge()

	  #-----------------------------------------------------------#
	 #   FLATTENING THE LISTS AND RETURNING ONE FLATTENED LIST   #
	#-----------------------------------------------------------#

	def Flatten()
		aResult = This.ToStzList().Flattened()
		return aResult

		def FlattenQ()
			return This.FlattenQR(:stzList)

		def FlattenQR(pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.Flattened() )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.Flattened() )

			on :stzListOfStrings
				return new stzListOfStrings( This.Flattened() )

			on :stzListOfChars
				return new stzListOfChars( This.Flattened() )

			on :stzListOfPairs
				return new stzListOfPairs( This.Flattened() )

			on :stzListOfLists
				return new stzListOfLists( This.Flattened() )

			other
				StzRaise("Unsupported return type!")
			off

	def Flattened()
		return This.Flatten()

	  #------------------------------------------------#
	 #  CHECKING IF A GIVEN ITEM EXISTS IN ALL LISTS  #
	#------------------------------------------------#

	def EachListContainsCS(pItem, pCaseSensitive)
		bResult = TRUE
		aLists = This.Content()
		nLen = len(aLists)

		for i = 1 to nLen
			if NOT Q(aLists[i]).ContainsCS(pItem, pCaseSensitive)
				bResult = FALSE
				exit
			ok
		next

		return bResult

		#< @FunctionAlternativeForms

		def ContainsItemInAllListsCS(pItem, pCaseSensitive)
			return This.EachListContainsCS(pItem, pCaseSensitive)

		def ContainsItemInEachListCS(pItem, pCaseSensitive)
			return This.EachListContainsCS(pItem, pCaseSensitive)

		def ItemExistsInAllListsCS(pItem, pCaseSensitive)
			return This.EachListContainsCS(pItem, pCaseSensitive)

		def ItemIsCommonToAllListsCS(pItem, pCaseSensitive)
			return This.EachListContainsCS(pItem, pCaseSensitive)

		def AllListsContainCS(pItem, pCaseSensitive)
			return This.EachListContainsCS(pItem, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def EachListContains(pItem)
		return This.EachListContainsCS(pItem, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def ContainsItemInAllLists(pItem)
			return This.EachListContains(pItem)

		def ContainsItemInEachList(pItem)
			return This.EachListContains(pItem)

		def ItemExistsInAllLists(pItem)
			return This.EachListContains(pItem)

		def ItemIsCommonToAllLists(pItem)
			return This.EachListContains(pItem)

		def AllListsContain(pItem)
			return This.EachListContains(pItem)

		#>

	  #--------------------------------------#
	 #  COMMON ITEMS BETWEEN ALL THE LISTS  #
	#--------------------------------------#

	def CommonItemsCS(pCaseSensitive)
		aResult = This.FlattenQ().Duplicates()
		return aResult

		def IntersectionCS(pCaseSensitive)
			return This.CommonItemsCS(pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def CommonItems()
		return This.CommonItemsCS(:CaseSensitive = TRUE)

		def Intersection()
			return This.CommonItems()

	  #---------------------#
	 #   TO OTHER TYPES    #
	#---------------------#

	def ToStzList()
		return new stzList( This.Content() )

	def ToStzListQ()
		return new stzList( This.Content() )

	def ToListOfStrings()
		aResult = []
		aListOfLists = This.ListOfLists()
		nLen = len(aListOfLists)

		for i = 1 to nLen 
			aResult + @@( aListOfLists[i] ) # @@ --> ComputableForm( list )
		next

		return aResult

	def ToStzListOfStrings()
		if This.IsListOfStrings()
			return new stzListOfStrings( This.Content() )
		ok

	  #-----------#
	 #   MISC.   #
	#-----------#
		
	def stzType()
		return :stzListOfLists

	def ToListsInString()
		acResult = []
		aListOfLists = This.ListOfLists()
		nLen = len(aListOfLists)

		for i = 1 to nLen
			acResult + StzListQ(aListOfLists[i]).ToListInString()
		next

		return acResult

		def ToListsInStringQ()
			return new stzString( This.ToListsInString() )

		def ToListInStringInNormalForm()
			return This.ToListsInString()

			def ToListInStringInNormalFormQ()
				return new stzString( This.ToListInStringInNormalForm() )

		def ToListInNormalForm()
			return This.ToListsInString()

			def ToListInNormalFormQ()
				return new stzString( This.ToListInNormalForm() )

	def ToListInStringInShortForm()
		acResult = []
		aListOfLists = This.ListOfLists()
		nLen = len(aListOfLists)

		for i = 1 to len(aListOfLists)
			acResult + StzListQ(aListOfLists[i]).ToListInStringInShortForm()
		next

		return acResult

		def ToListInStringInShortFormQ()
			return new stzString( This.ToListInStringInShortForm() )

		def ToListInShortForm()
			return This.ToListInStringInShortForm()

			def ToListInShortFormQ()
				return new stzString( This.ToListInShortForm() )

		def ToListInStringSF()
			return This.ToListInStringInShortForm()
	
			def ToListInStringSFQ()
				return new stzString( This.ToListInStringSF() )
