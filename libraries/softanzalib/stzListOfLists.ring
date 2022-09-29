func ItemExists(pItem, paList)
	oTempList = new stzList(paList)
	if oTempList.Contains(pItem) 
		return TRUE
	else
		return FALSE
	ok

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

func ListsMerge(paListOfLists)
	return StzListOfListsQ(paListOfLists).Merge()

	func ListsMergeQ(paListOfLists)
		return new stzList( ListsMerge(paListOfLists) )

func ListsFlatten(paListOfLists)
	return StzListOfListsQ(paListOfLists).Flatten()

	func ListsFlattenQ(paListOfLists)
		return new stzList( ListsFlatten(paListOfLists) )

	func ListsMergeAndFlatten(paListOfLists)
		return ListsFlatten(paListOfLists)

		func ListsMergeAndFlattenQ(paListOfLists)
			return new stzList( ListsMergeAndFlatten(paListOfLists) )


class stzListOfLists from stzList

	@aContent = []

	def init(paList)
		if isList(paList) and
		   ( Q(paList).IsEmpty() or Q(paList).IsListOfLists() )

			@aContent = paList

		else
			stzRaise("Can't create the stzListOfLists object!")
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
			stzRaise([
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
		for list in paListOfLists
			@aContent + list
		next

	  #---------------#
	 #   NTH LIST    #
	#---------------#

	def NthList(n)
		return This.ListOfLists()[n]

		#< @FunctionFluentForm
		
		def NthListQ(n)
			return new stzList( This.NthList(n) )

		#>

		#< @FunctionAlternativeForms

		def ListAt(n)
			return This.NthList()

		def ListAtPosition(n)
			return  This.NthList(n)

		#>

	  #------------------#
	 #   LISTS WHERE    #
	#------------------#

	def ListsW(pcCondition)

		cCondition = StzStringQ(pcCondition).RemoveBoundsQ("{","}").Simplified()
		aResult = []

		@i = 0

		for @list in This.ListOfLists()
			@i++

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

		cCondition = StzStringQ(pcCondition).RemoveBoundsQ("{","}").Simplified()
		aResult = []

		@i = 0

		for @list in This.ListOfLists()
			@i++

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

	  #---------------------------------------------------------#
	 #   YIELDING THE RESULT OF A FUNCTION ON ALL THE LISTS    #
	#---------------------------------------------------------#

	def Yield(pcFunc)
		cFunc = StzStringQ(pcFunc).RemoveBoundsQ("{","}").Simplified()
		
		aResult = []
		@i = 0

		for @list in This.ListOfLists()
			@i++
			cCode = "aResult + " + cFunc
			eval(cCode)
		next
		return aResult

		#< @FunctionFluentForm

		def YieldQ(pcFunc)
			return new stzList( This.Yield(pcFunc) )

		#>

	  #-------------------------------------------#
	 #   SIZES, AND SMALLEST AND BIGGEST SIZES   #
	#-------------------------------------------#

	def Sizes()
		return This.Yield('{ len(@list) }')

	def SmallestSize()
		return StzListOfNumbersQ( StzSetQ(This.Sizes()).Content() ).Min()

		def MinSize()
			return This.SmallestSize()

	def BiggestSize()
		return StzListOfNumbersQ( StzSetQ(This.Sizes()).Content() ).Max()

		def MaxSize()
			return This.BiggestSize()

	def ListsHaveSameNumberOfItems()
		bResult = TRUE
		
		for i = 2 to This.NumberOfLists()
			if len( This.NthList(i) ) != len( This.NthList(i-1) )
				bResult = FALSE
				exit
			ok
		next

		return bResult

		def ListsHaveSameSize()
			return This.ListsHaveSameNumberOfItems()

	  #--------------------------------#
	 #   SMALLEST AND BIGGEST LISTS   #
	#--------------------------------#

	def SmallestLists()
		return This.ListsW('{ len(@list) = This.SmallestSize() }')

	def BiggestLists()
		return This.ListsW('{ len(@list) = This.BiggestSize() }')


	def FindSmallestLists()
		return This.PositionsW('{ len(@list) = This.SmallestSize() }')

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

		for aList in This.ListOfLists()
			if len(aList) >= n
				aResult + aList[n]
			ok
		next

		return aResult

		#< @FunctionFluentForm

		def ItemsAtPositionNQ(n)
			return This.ItemsAtPositionNQR(n, :stzList)

		def ItemsAtPositionsNQR(n, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParam()
				pcReturnType = pcReturnType[2]
			ok

			if NOT isString(pcReturnType)
				stzRaise("Incorrect param! pcReturnType must be a string.")
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.ItemsAtPositionN(n) )

			on :stzListOfLists
				return new stzListOfLists( This.ItemsAtPositionN(n) )

			on :stzListOfPairs
				return new stzListOfPairs( This.ItemsAtPositionN(n) )

			other
				stzRaise("Unsupported return type!")
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

	  #-----------------------------------------#
	 #   REVERSING THE THE ITEMS OF THE LIST   #
	#-----------------------------------------#

	# To avoid confusion, it's better to use the alternative forms
	# ReverseItems() and ItemsReversed()

	def ReverseLists()	

		aResult = []
		
		for i = This.NumberOfLists() to 1 step -1
			aResult + This[i]
		next

		This.Update( aResult )

		def ReverseListsQ()
			This.ReverseLists()
			return This

			def ReverseQ()
				return This.ReverseListsQ()

		def ReverseItems()
			This.ReverseLists()

			def ReverseItemsQ()
				This.ReverseItems()
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
		i = 0
		for aList in This.ListOfLists()
			i++
			@aContent[i] = Q(aList).Reversed()
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
		return This.IndexOnPosition()

	def IndexOnPosition()
		return This.IndexOn(:Position)

	def IndexOnNumberOfOccurrence()
		return This.IndexOn(:NumberOfOccurrence)

		def IndexOnNumberOfOccurrences()
			return This.IndexOnNumberOfOccurrence()

	def IndexOn(pcOn) # pcOn can be :NumberOfOccurrence(s) or :Position
		/*
		Problem:

			Let:

			a1 = [ "A", "A", "B", "C" ]
			a2 = [ "B", "A", "C", "B", "A", "X" ]

			Getting the index of each list alone is simply done
			by calling the IndexOn() method of stzList, so we get:

			Index(a1) --> [ :A = 2, :B = 1, :C = 1 ]
		   	Index(a2) --> [ :A = 2, :B = 1, :C = 1, :X = 1 ]

			What we need is to make the Index of these TWO lists
			togehtor so we can have this:

			[ :A = [2,2] , :B = [1,2] , :C = [1,1] , :X = [0,1] ]

			Note: we can do it for any number of lists...
		*/

		aIndexes = []
		for list in This.Content()
			oTempList = new stzList( list )
			aIndexes + oTempList.IndexOn(pcOn)
		next
		// aIndexes => [ [ :A = 2, :B = 1, :C = 1 ],
		//		 [ :A = 2, :B = 1, :C = 1, :X = 1 ] ]	


		aKeys = This.MergeAndRemoveDuplicates()
		// aKeys => [ :A, :B, :C, :X ]

		
		aResult = []
		for key in aKeys
			aValues = []
			i=0
			for aIndex in aIndexes
				i++
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
					for nPosition in aPositions
						aPair = [ i, nPosition]
						aValues + aPair
					next
				ok
			next
			aResult + [ key, aValues ]
		next
		// aIndex => [ :A = [2,2] , :B = [1,2] , :C = [1,1] , :X = [0,1] ]

		return aResult

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

	  #------------------------------------------#
	 #   OCCURRENCE  OF AN ENTRY IN THE INDEX   #
	#------------------------------------------#

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

	  #--------------------------#
	 #   MERGING & FLATTENING   #
	#--------------------------#

	def Merge() # Breaks if an items is of type Object!
		
		aMerged = []

		for aList in This.ListOfLists()
			for item in aList
				aMerged + item
			next
		next

		return aMerged

	def MergeQ()
		return new stzList( This.Merge() )

	def Merged()
		return This.Merge()

	def Flatten()
		aFlattened = []

		for list in This.ListOfLists()
			aFlattened + StzListQ(list).Flattened()
		next

		aResult = []
		for list in aFlattened
			for item in list
				aResult + item
			next
		next

		return aResult
		
		#< @FunctionFluentForm

		def FlattenQ()
			return new stzList( This.Flatten() )
	
		#>

		#< @FunctionAlternativeFormForm

		func MergeAndFlatten()
			return This.Flatten()

			#< @FunctionFluentForm

			func MergeAndFlattenQ()
				return new stzList( This.MergeAndFlatten() )

			#>
		#>

	def Flattened()
		return This.Flatten()

	def MergedAndFlattened()
		return This.MergeAndFlatten()

	  #------------------#
	 #   CONTAINMENT    #
	#------------------#

	def ContainsItem(pItem)
		bResult = FALSE
		for list in This.ListOfLists()
			oStzList = new stzList(list)
			if oStzList.Contains(pItem)
				bResult = TRUE
				exit
			ok
		next
		return bResult

	def ListsContainingItem(pItem)
		aResult = []
		for list in This.ListOfLists()
			oStzList = new stzList(list)
			if oStzList.Contains(pItem)
				aResult + list
			ok
		next
		return aResult

	  #----------------------------------#
	 #   INTERSECTION & COMMON ITEMS    #
	#----------------------------------#

	def HaveSameContent()
		// TODO

	def CommonItems()
		return This.Intersection()

	def Intersection()
		/*
		The intersection between a list of lists (ie their common item) is
		given by the duplicated items of the merged list of all those lists.
		*/
		oStzList = new stzList(This.Merge())
		return oStzList.DuplicatedItems()

	  #---------------------#
	 #   TO OTHER TYPES    #
	#---------------------#

	def ToStzList()
		return new stzList( This.Content() )

	def ToStzListQ()
		return new stzList( This.Content() )

	def ToListOfStrings()
		aResult = []

		for list in This.ListOfLists()
			aResult + @@( list ) # @@ --> ComputableForm( list )
		next

		return aResult

		def Stringify()
			return This.ToListOfStrings()

	def ToStzListOfStrings()
		return new stzListOfStrings( This.Stringify() )

	  #-----------#
	 #   MISC.   #
	#-----------#
		
	def ToListsInString()
		acResult = []
		for aList in This.ListOfLists()
			acResult + StzListQ(aList).ToListInString()
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
		for aList in This.ListOfLists()
			acResult + StzListQ(aList).ToListInStringInShortForm()
		next

		return acResult

		def ToListInStringInShortFormQ()
			return new stzString( This.ToListInStringInShortForm() )

		def ToListInShortForm()
			return This.ToListInStringInShortForm()

			def ToListInShortFormQ()
				return new stzString( This.ToListInShortForm() )

		def ToListInString@C()
			return This.ToListInStringInShortForm()
	
			def ToListInString@CQ()
				return new stzString( This.ToListInString@C() )
