func ItemExists(pItem, paList)
	oTempList = new stzList(paList)
	if oTempList.Contains(pItem) 
		return TRUE
	else
		return FALSE
	ok

func StzListOfListsQ(paList)
	return new stzListOfLists(paList)

func ListsMerge(paListOfLists)
	return StzListOfListsQ(paListOfLists).Merge()

func ListsFlatten(paListOfLists)
	return StzListOfListsQ(paListOfLists).Flatten()

	func ListsMergeAndFlatten(paListOfLists)
		return ListsFlatten(paListOfLists)


class stzListOfLists from stzObject

	@aContent = []

	def init(paList)

		for list in paList
			@aContent + list
		next

	  #--------------#
	 #   GENERAL    #
	#--------------#

	def Content()
		return @aContent

	def ListOfLists()
		return Content()

	def Copy()
		oCopy = new stzListOfLists( This.Content() )
		return oCopy

	def NumberOfLists()
		return len(@aContent)

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

	def BiggestSize()
		return StzListOfNumbersQ( StzSetQ(This.Sizes()).Content() ).Max()

	  #--------------------------------#
	 #   SMALLEST AND BIGGEST LISTS   #
	#--------------------------------#

	def SmallestLists()
		return This.ListsW('{ len(@list) = This.SmallestSize() }')

	def BiggestLists()
		return This.ListsW('{ len(@list) = This.BiggestSize() }')

	def PositionsOfSmallestLists()
		return This.PositionsW('{ len(@list) = This.SmallestSize() }')

	def PositionsOfBiggestLists()
		return This.PositionsW('{ len(@list) = This.BiggestSize() }')

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
		for list in Content()
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

	  #-----------------#
	 #   OCCURRENCE    #
	#-----------------#

	def NumberOfOccurrenceOfEntry(pEntry)
		return len(o1.IndexOn(:Position)[pEntry])

		def NumberOfOccurrencesOfEntry(pEntry)
			return This.NumberOfOccurrenceOfEntry(pEntry)

	def NthOccurrenceOfEntry(n, pEntry)
		return o1.IndexOn(:Position)[pEntry][n]

		def NthOccurrencesOfEntry(n, pEntry)
			return This.NthOccurrenceOfEntry(n, pEntry)

	def FirstOccurrenceOfEntry(pEntry)
		return NthOccurenceOfEntry(1, pEntry)

	def LastOccurrenceOfEntry(pEntry)
		return NthOccurrenceOfEntry(This.NumberOfOccurrenceOfEntry(pEntry), pEntry)

	  #----------------------#
	 #   MERGE & FLATTEN    #
	#----------------------#

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

