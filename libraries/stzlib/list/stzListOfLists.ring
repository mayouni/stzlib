#---------------------------------------------------------------------------#
# 		    SOFTANZA LIBRARY (V1.0) - STZLISTOFLISTS		    #
#		An accelerative library for Ring applications		    #
#---------------------------------------------------------------------------#
#									    #
# 	Description : The class for managing lists of lists (2DLists)       #
#	Version	    : V1.0 (2020-2024)				            #
#	Author	    : Mansour Ayouni (kalidianow@gmail.com)		    #
#									    #
#---------------------------------------------------------------------------#

  #=============#
 #  FUNCTIONS  #
#=============#

func StzListOfListsQ(paList)
	return new stzListOfLists(paList)

	func Stz2DList(paList)
		return StzListOfListsQ(paList)

func ItemExists(pItem, paList)
	oTempList = new stzList(paList)
	if oTempList.Contains(pItem) 
		return TRUE
	else
		return FALSE
	ok

func AllListsHaveSameSize(paListOfLists)
	if CheckingParams()
		if NOT ( isList(paListOfLists) and
			 len(paListOfLists) > 1 and
			 IsListOfLists(paListOfLists) )

			StzRaise("Incorrect param type! paListOfLists must be a list of lists.")
		ok
	ok

	nLen = len(paListOfLists)	
	nSize = len(paListOfLists[1])
	bResult = TRUE

	for i = 2 to nLen
		if len(paListOfLists[i]) != nSize
			bResult = FALSE
			exit
		ok
	next

	return bResult

	func ListsHaveSameSize(paListofLists)
		return AllListsHaveSameSize(paListOfLists)

	func AllListsHaveSameNumberOfItems(paListOfLists)
		return AllListsHaveSameSize(paListOfLists)

	func ListsHaveSameNumberOfItems(paListOfLists)
		return AllListsHaveSameSize(paListOfLists)

func ListsMerge(paListOfLists)
	if CheckingParams()
		if NOT ( isList(paListOfLists) and @IsListOfLists(paListOfLists) )
			StzRaise("Incorrect param type! paListOfLists must be a list of lists.")
		ok
	ok

	nLen = len(paListOfLists)

	if nLen < 2
		return paListOfLists
	ok

	aResult = paListOfLists[1]

	for i = 2 to nLen
		nLenList = len(paListOfLists[i])
		for j = 1 to nLenList
			aResult + paListOfLists[i][j]
		next j
	next

	return aResult

	func ListsMergeQ(paListOfLists)
		return new stzList( ListsMerge(paListOfLists) )

	func Merge(paListOfLists)
		return ListsMerge(paListOfLists)

	func @Merge(paListOfLists)
		return ListsMerge(paListOfLists)

func Association(paLists)
	if CheckingParams()
	
		if NOT ( isList(paLists) and Q(paLists).IsListOfLists() )
			StzRaise("Incorrect param type! paLists must be a list of lists.")
		ok

	ok

	if len(paLists) < 2
		StzRaise("Can't proceed! paLists must contain at least two lists.")
	ok

	nLen = len(paLists)

	# Counting the sizes of each list

	anLen = []
	for i = 1 to nLen
		anLen + len(paLists[i])
	next

	# Unifiying the sizes of all the lists

	nMax = Max(anLen)

	for i = 1 to nLen

		if anLen[i] < nMax
			for j = anLen[i] + 1 to nMax
				paLists[i] + NULL
			next
		ok
	next

	# Doing the association

	aResult = []

	for i = 1 to nMax
		aList = []
		for j = 1 to nLen

			aList + paLists[j][i]
		next
		aResult + aList
	next

	return aResult

	#< @FunctionAlternativeForm

	func @Association(paLists)
		return Association(paLists)

	#>

	#< @FunctionMisspelledForm

	func Associattion(paLists)
		return Association(paLists)

	func Associaton(paLists)
		return Association(paLists)

	#--

	func @Associattion(paLists)
		return Association(paLists)

	func@ Associaton(paLists)
		return Association(paLists)

	#>

func CommonItemsCS(paLists, pCaseSensitive)
	aResult = StzListOfListsQ(paLists).CommonItemsCS(pCaseSensitive)
	return aResult

	func IntersectionCS(paLists, pCaseSensitive)
		return CommonItemsCS(paList, pCaseSensitive)

	#--

	func @CommonItemsCS(paLists, pCaseSensitive)
		return CommonItemsCS(paLists, pCaseSensitive)

	func @IntersectionCS(paLists, pCaseSensitive)
		return CommonItemsCS(paList, pCaseSensitive)

func CommonItems(paLists)
	return CommonItemsCS(paLists, TRUE)

	func Intersection(paLists)
		return CommonItems(paLists)

	#--

	func @CommonItems(paLists)
		return CommonItems(paLists)

	func @Intersection(paLists)
		return CommonItems(paLists)

func StzListsQ(paList)
	return new stzLists(paList)

func Stz2DListQ(paList)
	return new stz2DList(paList)

#--

func AreContiguous(paListOfLists)
	return StzListOfListsQ(paListOfLists).AreContiguous()

	func AreContinuous(paListOfLists)
		return AreContiguous(paListOfLists)

	func AreConsecutive(paListOfLists)
			return AreContiguous(paListOfLists)

	#--

	func @AreContiguous(paListOfLists)
		return AreContiguous(paListOfLists)

	func @AreContinuous(paListOfLists)
		return AreContiguous(paListOfLists)

	func @AreConsecutive(paListOfLists)
			return IsContiguous(paListOfLists)

  #=========#
 #  CLASS  #
#=========#

class stzLists from stzListOfLists

class stz2DList from stzListOfLists

class stzListOfLists from stzList

	@aContent = []

	def init(paList)

		if CheckingParams()

			if NOT isList(paList) 
				StzRaise("Can't create the object! You must provide a list.")
			ok
	
			bOk = TRUE
			nLen = len(paList)
	
			for i = 1 to nLen
				if NOT isList(paList[i])
					bOk = FALSE
				ok
			next
	
			if NOT bOk
				StzRaise("Can't create the object! You must provide a list of lists!")
			ok

		ok

		if len(paList) = 0
			@aContent = [ paList ]
		else
			@aContent = paList
		ok

		if KeepingHistory() = TRUE
			This.AddHistoricValue(This.Content())
		ok

	  #-------------#
	 #   GENERAL   #
	#-------------#

	def Content()
		return @aContent

		def Value()
			return Content()

	def Copy()
		return new stzListOflists(This.Content())

	def ListOfLists()
		return This.Content()

		def 2Dlist()
			return This.Content()

	def NumberOfLists()
		return len(@aContent)

	  #-------------------------------#
	 #   UPDATING THE LIST OF LISTS  #
	#-------------------------------#

	def Update(paList)
		if CheckingParams() = TRUE
			if isList(paList) and Q(paList).IsWithOrByOrUsingNamedParam()
				paList = paList[2]
			ok

			if NOT @IsListOfLists(paList)
				StzRaise("Incorrect param type! paList must be a list of lists.")
			ok
		ok

		@aContent = paList

		if KeepingHisto() = TRUE
			This.AddHistoricValue(This.Content())  # From the parent stzObject
		ok

		#< @FunctionAlternativeForms

		def UpdateWith(paList)
			This.Update(paList)
	
		def UpdateBy(paList)
			This.Update(paList)

		def UpdateUsing(paList)
			This.Update(paList)

		#>

	def Updated(paList)
		return paList

		#< @FunctionAlternativeForms

		def UpdatedWith(paList)
			return This.Updated(paList)

		def UpdatedBy(paList)
			return This.Updated(paList)

		def UpdatedUsing(paList)
			return This.Updated(paList)

		#>

	  #-----------------#
	 #   ADDING LISTS  #
	#-----------------#

	def AddList(paList)
		aTempContent = This.Content()
		This.UpdateWith(aTempContent + paList)

	def AddMany(paListOfLists)
		if CheckingParams()
			if NOT ( isList(paListOfLists) and Q(paListOfLists).IsListOfLists() )
				StzRaise("Incorrect param type! paListOfLists must be a list of lists.")
			ok
		ok

		aContent = This.Content()

		nLen = len(paListOfLists)
		for i = 1 to nLen
			aContent + paListOfLists[i]
		next

		This.UpdateWith(aContent)

		def AddManyLists(paListOfLists)
			This.AddMany(paListOfLists)

	  #---------------#
	 #   NTH LIST    #
	#---------------#

	def NthList(n)
		if CheckingParams()

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

		ok

		aResult = This.Content()[n]
		return aResult

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

	  #------------------------------------#
	 #  FINDING AN ITEM INSIDE THE LISTS  #
	#------------------------------------#

	def FindInListsCS(pItem, pCaseSensitive)
		nLen = len(@aContent)
		aResult = []

		for i = 1 to nLen
			anPos = @FindAllCS( @aContent[i], pItem, pCaseSensitive)
			nLenPos = len(anPos)
			atemp = []
			for j = 1 to nLenPos
				aResult + [ i, anPos[j] ]
			next
		next

		return aResult

		#< @FunctionAlternativeForms

		def FindItemInListsCS(pItem, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindInLists(pItem)
		return This.FindInListsCS(pItem, TRUE)
	
		#< @FunctionAlternativeForms

		def FindItemInLists(pItem)
			return This.FindInLists(pItem)

		#>

	  #--------------------------------------#
	 #  FINDING A SUBLIST INSIDE THE LISTS  #
	#--------------------------------------#

	def FindSubListInListsCS(paSubList, pCaseSensitive)
		StzRaise("Function non implemented yet!")

	  #======================#
	 #   POSITIONS WHERE    #
	#======================#

	def PositionsW(pcCondition)

		cCondition = StzStringQ(pcCondition).RemoveTheseBoundsQ("{", "}").Simplified()
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

		def FindListsW(pcCondition)
			return This.PositionsW(pcCondition)

			def FindListsWQ(pcCondition)
				return new stzList(This.PositionsWhere(pcCondition))

		def FindListsWhere(pcCondition)
			return This.PositionsW(pcCondition)

			def FindListsWhereQ(pcCondition)
				return new stzList(This.PositionsWhere(pcCondition))

		#>

		#TODO // XT form should be implemented in the same way as in stzList
		# Temprorarily we implement them as alternatives of the normal form

		def PositionWXT(pcCondition)
			return This.PositionW(pcCondition)

		def FindListsWXT(pcCondition)
			return This.PositionsW(pcCondition)


	  #------------------#
	 #   LISTS WHERE    #
	#------------------#

	def ListsW(pcCondition)

		cCondition = StzStringQ(pcCondition).RemoveTheseBoundsQ("{", "}").Simplified()
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

			def ListsWhereQ(pcCondition)
				return new stzList(This.ListsWhere(pcCondition))

		def ListsWXT(pcCondition)
			return This.ListsW(pcCondition)

		#>

	  #-----------------------------#
	 #  LISTS WHERE -- Z/EXTENDED  #
	#-----------------------------#

	def ListsWZ(pcCondition)
		aListsW = This.ListsW(pcCondition)
		anPosW  = This.PositionsW(pcCondition)

		aResult = @Association([ aListsW, anPosW ])

		return aResult

		#< @FunctionFluentForm

		def ListsWZQ(pcCondition)
			return new stzList( This.ListsWZ(pcCondition) )

		#>

		#< @FunctionAlternativeForm

		def ListsWhereZ(pcCondition)
			return This.ListsWZ(pcCondition)

			def ListsWhereZQ(pcCondition)
				return new stzList(This.ListsWhereZ(pcCondition))

		def ListsWXTZ(pcCondition)
			return This.ListsWXT(pcCondition)

		#>

	  #==========================================#
	 #   GETTING THE SIZES OF THE INNER LISTS   #
	#==========================================#

	def Sizes()
		
		aContent = This.ListOfLists()
		nLen = len(aContent)

		anResult = []

		for i = 1 to nLen
			anResult + len(aContent[i])
		next

		return anResult

		#< @FunctionAlternativeForms

		def ListsSizes()
			return This.Sizes()

		def SizeOfEachList()
			return This.Sizes()

		#--

		def ListsNumbersOfItems()
			return This.Sizes()

		def NumbersOfItems()
			return This.Sizes()

		def NumberOfItemsOfEachList()
			return This.Sizes()

		#>

	  #-----------------------------------------------#
	 #  CHECKING IF LISTS HAVE SAME NUMBER OF ITEMS  #
	#-----------------------------------------------#

	def ListsHaveSameNumberOfItems()
	
		aContent = This.Content()
		nLen = len(aContent)

		if nLen = 0
			StzRaise("Can't check inner lists! Because the list is empty.")

		but nLen = 1
			return TRUE
		ok

		nLenList = len(aContent[1])
		bResult = TRUE

		for i = 2 to nLen
			if len( aContent[i] ) != nLenList
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

		def IsUniform()
			return This.ListsHaveSameNumberOfItems()

		#--

		def HaveSameNumberOfItems()
			return This.ListsHaveSameNumberOfItems()

		def HasSameNumbersOfItems()
			return This.ListsHaveSameNumberOfItems()

		def ContainsSameNumberOfItems()
			return This.ListsHaveSameNumberOfItems()

		#--

		def ListsHaveSameSize()
			return This.ListsHaveSameNumberOfItems()

		def HaveSameSize()
			return This.ListsHaveSameNumberOfItems()

		def HasSameSizes()
			return This.ListsHaveSameNumberOfItems()

		#--

		def AllListsHaveSameSizes()
			return This.ListsHaveSameNumberOfItems()

		def AllListsHaveSameSize()
			return This.ListsHaveSameNumberOfItems()

		def AllListsHaveSameNumberOfItems()
			return This.ListsHaveSameNumberOfItems()

		#--

		def Is2DList()
			return This.ListsHaveSameNumberOfItems()

		def IsA2DList()
			return This.ListsHaveSameNumberOfItems()

		def IsGrid()
			return This.ListsHaveSameNumberOfItems()

		def IsAGrid()
			return This.ListsHaveSameNumberOfItems()

		#>

	  #--------------------#
	 #   SMALLEST LISTS   #
	#--------------------#

	def FindSmallestLists()

		aContent = This.Content()
		nLen = len(aContent)

		anResult = []
		nMin = This.SmallestSize()

		for i = 1 to nLen

			if len(aContent[i]) = nMin
				anResult + i
			ok

		next

		return anResult

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

	def SmallestLists()
		aResult = This.ItemsAtPositions( This.FindSmallestLists() )
		return aResult

	#--

	def SmallestListsZ()
		aResult = Association([ This.SmallestLists(), This.FindSmallestLists() ])
		return aResult

	  #-------------------#
	 #   BIGGEST LISTS   #
	#-------------------#

	def FindBiggestLists()

		aContent = This.Content()
		nLen = len(aContent)
		nMax = This.BiggestSize()

		anResult = []

		for i = 1 to nLen
			if len(aContent[i]) = nMax
				anResult + i
			ok
		next

		return anResult

		#< @FunctionAlternativeForms

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

		#>

	#TODO
	# add* "big", "great", and "large" as alternatives all over the library

	def BiggestLists()
		anPos = This.FindBiggestLists()
		aResult = This.ItemsAtPositions(anPos)
		return aResult

		#< @FuntionAlternativeForms

		def GreatestLists()
			return This.BiggestLists()

		def LargestLists()
			return This.BiggestLists()

		#>

	def BiggestListsZ()
		aResult = Association([ This.BiggestLists(), This.FindBiggestLists() ])
		return aResult

		#< @FuntionAlternativeForms

		def GreatestListsZ()
			return This.BiggestListsZ()

		def LargestListsZ()
			return This.BiggestListsZ()

		#--

		def BiggestListsAndTheirPositions()
			return This.BiggestListsZ()

		def LargestListsAndTheirPositions()
			return This.BiggestListsZ()

		#>

	  #---------------------#
	 #   LISTS OF SIZE N   #
	#---------------------#

	def FindListsOfSizeN(n)
		
		aContent = This.Content()
		nLen = len(aContent)

		anResult = []

		for i = 1 to nLen
			if len(aContent[i]) = n
				anResult + i
			ok
		next

		return anResult

		#< @FunctionAlternativeForms

		def FindListsOfSize(n)
			return This.FindListsOfSizeN(n)

		def PositionsOfListsOfSizeN(n)
			return This.FindListsOfSizeN(n)

		def PositionsOfListsOfSize(n)
			return This.FindListsOfSizeN(n)

		#>

	def ListsOfSizeN(n)

		anPos = This.FindListsOfSizeN(n)
		aResult = This.ItemsAtPositions(anPos)
		return aResult

		#< @FunctionAlternativeForm

		def ListsOfSize(n)
			return This.ListsOfSizeN(n)

		#>

	  #------------------------------------------------------#
	 #  FINDING THE MISSING POSITIONS IN THE LIST OF LISTS  #
	#======================================================#

	func FindMissingItems()
		nMin = This.MinSize()
		nMaxSize = This.MaxSize()
	
		aContent = This.Content()
		nLen = len(aContent)
	
		aResult = []
		for i = 1 to nLen
			nLenList = len(aContent[i])
			if nLenList < nMaxSize
				for j = nLenList + 1 to nMaxSize
					aResult + [ i, j ]
				next
			ok
		next
	
		return aResult

		#< @FunctionAlternativeForms

		def FindMissing()
			return This.FindMissingItems()

		def FindMissingPositions()
			return This.FindMissingItems()

		def MissingPositions()
			return This.FindMissingItems()

		#>

	  #-----------------------------------------------------------------#
	 #  GETTING THE NUMBER OF MISSING POSISITONS IN THE LIST OF LISTS  #
	#-----------------------------------------------------------------#

	def NumberOfMissingItems()

		nMin = This.MinSize()
		nMaxSize = This.MaxSize()
	
		aContent = This.Content()
		nLen = len(aContent)
	
		nResult = 0
		for i = 1 to nLen
			nLenList = len(aContent[i])
			if nLenList < nMaxSize
				nResult += (nMaxSize - nLenList)
			ok
		next
	
		return nResult

		#< @FunctionAlternativeForms

		def NumberOfMissingPositions()
			return This.NumberOfMissingItems()

		def HowManyMissingItems()
			return This.NumberOfMissingItems()

		def HowManyMissingPositions()
			return This.NumberOfMissingItems()

		def HowManyMissing()
			return This.NumberOfMissingItems()

		#>

	  #--------------------------#
	 #   ITEMS AT POSITION N    #
	#==========================#

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

		#< @FunctionAlternativeForms

		def FindSmallest()
			return This.FindSmallestList()

		def FindMinList()
			return This.FindSmallestList()

		#>

	def SmallestList()
		#NOTE
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

		#< @FunctionAlternativeForms

		def Smallest()
			return This.SmallestList()

		def MinList()
			return This.SmallestList()

		#>

	def SmallestListZ()
		aResult = [ This.SmallestList(), This.FindSmallestList() ]
		return aResult

		#< @FunctionAlternativeForms

		def SmallestZ()
			return This.SmallestListZ()

		def SmallestListAndItsPosition()
			return This.SmallestListZ()

		def MinListAndItsPosition()
			return This.SmallestListZ()

		#>

	  #-------------------------#
	 #  SIZE OF SMALLEST LIST  #
	#-------------------------#

	def SizeOfSmallestList()
		nResult = len( This.SmallestList() )
		return nResult

		#< @FunctionAlternativeForms

		def SmallestListSize()
			return This.SizeOfSmallestList()

		def SmallestSize()
			return This.SizeOfSmallestList()

		def MinSize()
			return This.SizeOfSmallestList()

		#>

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

		#< @FunctionAlternativeForms

		def FindLargest()
			return This.FindLargestList()

		def FindMaxList()
			return This.FindLargestList()

		#>

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

		#< @FunctionAlternativeForms

		def BiggestList()
			return This.LargestList()

		def Largest()
			return This.LargestList()

		def Biggest()
			return This.LargestList()

		def MaxList()
			return This.LargestList()

		#>

	def LargestListZ()
		aResult = [ This.LargestList(), This.FindLargestList() ]
		return aResult

		#< @FunctionAlternativeForms

		def BiggestListZ()
			return This.LargestListZ()

		def LargestZ()
			return This.LargestListZ()

		def BiggestZ()
			return This.LargestListZ()

		def MaxListZ()
			return This.LargestListZ()

		#--

		def LargestListAndItsPosition()
			return This.LargestListZ()

		def BiggestListAndItsPosition()
			return This.LargestListZ()

		def LargestAndItsPosition()
			return This.LargestListZ()

		def BiggestAndItsPosition()
			return This.LargestListZ()

		def MaxListAndItsPosition()
			return This.LargestListZ()

		#>

	  #------------------------#
	 #  SIZE OF LARGEST LIST  #
	#------------------------#

	def SizeOfLargestList()
		nResult = len( This.LargestList() )
		return nResult

		#< @FunctionAlternativeForms

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
	
		def MaxSize()
			return This.SizeOfLargestList()

		def MaxNumberOfItems()
			return This.SizeOfLargestList()

		def LargestNumberOfItems()
			return This.SizeOfLargestList()

		def BiggestNumberOfItems()
			return This.SizeOfLargestList()

		#>

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

		#< @FuntionFluentForm

		def ExtendQ()
			This.Extend()
			return This

		#>

		#< @FunctionAlternativeForm

		def ExtendEachList()
			This.Extend()

			def ExtendEachListQ()
				return This.ExtendQ()

		def Adjust()
			This.Extend()

			def AdjustQ()
				return This.ExtendQ()

		def Justify()
			This.Extend()

			def JustifyQ()
				return This.ExtendQ()

		#>

	def Extended()
		aResult = This.Copy().ExtendQ().Content()
		return aResult

		#< @FunctionAlternativeForms

		def EachListExtended()
			return This.Extended()

		def Adjusted()
			return This.Extended()

		def Justified()
			return This.Extended()

		#>

	  #----------------------------------------------------------------#
	 #  EXTENDING (EACH LIST IN) THE LIST OF LISTS WITH A GIVEN ITEM  #
	#----------------------------------------------------------------#

	def ExtendXT(pItem)
		This.ExtendToXT( This.SizeOfLargestList(), pItem )

		#< @FuntionFluentForm

		def ExtendXTQ()
			This.ExtendXT()
			return This

		#>

		#< @FunctionAlternativeForm

		def ExtendEachListXT(pItem)
			This.ExtendXT(pItem)

			def ExtendEachListXTQ(pItem)
				return This.ExtendXTQ(pItem)

		def JustifyXT(pItem)
			This.ExtendXT(pItem)

			def JustifyXTQ(pItem)
				return This.ExtendXTQ(pItem)

		#--

		def ExtendWith(pItem)
			This.ExtendXT(pItem)

			def ExtendWithQ(pItem)
				return This.ExtendXTQ(pItem)

		def ExtendEachListWith(pItem)
			This.ExtendWith(pItem)

			def ExtendEachListWithQ(pItem)
				return This.ExtendWithQ(pItem)

		def JustifyWith(pItem)
			This.ExtendWith(pItem)

			def JustifyWithQ(pItem)
				return This.ExtendWithQ(pItem)

		#>

	def ExtendedXT(pItem)
		aResult = This.Copy().ExtendXTQ().Content()
		return aResult

		#< @FunctionAlternativeForms

		def EachListExtendedXT(pItem)
			return This.ExtendedXT(pItem)

		def JustifiedXT(pItem)
			return This.ExtendedXT(pItem)

		#--

		def ExtendedWith(pItem)
			return This.ExtendedXT(pItem)

		def EachListExtendedWith(pItem)
			return This.ExtendedXT(pItem)

		def JustifiedWith(pItem)
			return This.ExtendedXT(pItem)

		#>

	  #------------------------------------------------------------------------------------#
	 #  EXTENDING (EACH LIST IN) THE LIST OF LISTS TO A GIVEN POSITION WITH A NULL VALUE  #
	#------------------------------------------------------------------------------------#

	def ExtendTo(n)
		This.ExtendToXT(n, NULL)

		#< @FunctionFluentForm

		def ExtendToQ(n)
			This.ExtendTo(n)
			return This

		#>

		#< @FunctionAlternativeForm

		def ExtendToPosition(n)
			if NOT isNumber(n)
				StzRaise("Incorrect param type! n must be a number.")
			ok

			This.ExtendTo(n)

			def ExtendToPositionQ(n)
				return This.ExtendToQ(n)
		#>


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
		if CheckingParams()
			if isList(n) and Q(n).IsPositionNamedParam()
				n = n[2]
			ok
	
			if NOT isNumber(n)
				StzRaise("Incorrect param type! n must be a number.")
			ok
	
			if isList(pItem) and Q(pItem).IsUsingOrWithOrByNamedParam()
				pItem = pItem[2]
			ok
	
			if isString(pItem) and
			    	ring_find([
					:ItemsRepeated, :RepeatingItems,
					:RepeatedItems, :ByRepeatingItems
				], pItem) > 0
	
				This.ExtendToByRepeatingItems(n)
				return
			ok
		ok

		# Doing the job

		nLen = This.NumberOfLists()
		for i = 1 to nLen
			nSize = This.SizeOfList(i)

			aTemp = This.NthList(i)
			for j = 1 to n - nSize
				aTemp + pItem
			next

			This.ReplaceAt(i, aTemp)

		next

		#< @FuntionFluentForm

		def ExtendToXTQ(n, pItem)
			This.ExtendToXT(n, pItem)
			return This

		#>

		#< @FunctionAlternativeForm

		def ExtendToPositionXT(n, pItem)
			This.ExtendToXT(n, pItem)

		#>

	def ExtendedToXT(n, pItem)
		aResult = This.Copy().ExtendToXTQ(n, pItem).Content()
		return aResult

		def ExtendedToPositionXT(n, pItem)
			if NOT isNumber(n)
				StzRaise("Incorrect param type! n must be a number.")
			ok

			return This.ExtendedToXT(n, pItem)	

	  #---------------------------------------------------------------------------------------#
	 #  EXTENDING THE LIST OF LISTS TO A GIVEN POSITION BY REPEATING THE ITEMS OF EACH LIST  #
	#---------------------------------------------------------------------------------------#

	def ExtendToByRepeatingItems(n)
		aContent = This.Content()
		nLen = len(aContent)

		aResult = []

		for i = 1 to nLen
			aResult + Q(aContent[i]).ExtendedToByRepeatingItems(n)
		next

		This.UpdateWith(aResult)

		#< @FunctionFluentForm

		def ExtendToByRepeatingItemsQ(n)
			This.ExtendToByRepeatingItems(n)
			return This

		#>

		#< @FunctionAlternativeForm

		def ExtendToWithItemsRepeated(n)
			This.ExtendedToByRepeatingItems(n)

			def ExtendToWithItemsRepeatedQ(n)
				return This.ExtendToByRepeatingItemsQ(n)

		#>

	def ExtendedToByRepeatingItems(n)
		aResult = This.Copy().ExtendToByRepeatingItemsQ(n).Content()
		return aResul

		#< @FunctionAlternativeForm

		def ExtendedToWithItemsRepeated(n)
			This.ExtendedToByRepeatingItems(n)

		#>

	  #----------------------------------------------------------#
	 #  EXTENDING THE LIST OF LISTS TO THE SIZE OF LARGER LIST  #
	#----------------------------------------------------------#

	def ExtendByRepeatingItems()
		This.ExtendToByRepeatingItems( This.SizeOfLargestList() )

		#< @FunctionFluentForm

		def ExtendByRepeatingItemsQ()
			This.ExtendByRepeatingItems()
			return This

		#>

		#< @FunctionAlternativeForms

		def ExtendWithItemsRepeated()
			This.ExtendByRepeatingItems()

			def ExtendWithItemsRepeatedQ()
				return This.ExtendByRepeatingItemsQ()

		def ExtendByItemsRepeated()
			This.ExtendByRepeatingItems()

			def ExtendByItemsRepeatedQ()
				return This.ExtendByRepeatingItemsQ()

		#>

	def ExtendedByRepeatingItems()
		aResult = This.Copy().ExtendByRepeatingItemsQ().Content()
		return aResult

		#< @FunctionAlternativeForms

		def ExtendedWithItemsRepeated()
			return This.ExtendedByRepeatingItems()

		def ExtendedByItemsRepeated()
			return This.ExtendedByRepeatingItems()

		#>

	  #-------------------------------------------------------------------------#
	 #  EXTENDIND THE LIST OF LISTS TO A GIVEN POSITION USING THE GIVEN ITEMS  #
	#-------------------------------------------------------------------------#

	def ExtendToWithItemsIn(n, paItems)
		aContent = This.Content()
		nLen = len(aConten)

		aResult = []

		for i = 1 to nLen
			aResult + Q(aContent[i]).ExtendedToWithItemsIn(n, paItems)
		next

		This.UpdateWith(aResult)


		def ExtendToWithItemsInQ(n, paItems)
			This.ExtendToWithItemsIn(n, paItems)
			return This

		def ExtendToUsingItemsIn(n, paItems)
			This.ExtendToWithItemsIn(n, paItems)

			def ExtendToUsingItemsInQ(n, paItems)
				return This.ExtendToWithItemsInQ(n, paItems)

	def ExtendedToWithItemsIn(n, paItems)
		aResult = This.Copy().ExtendToWithItemsInQ(n, paItems).Content()
		return aResult

		def ExtendedToUsingItemsIn(n, paItems)
			return This.ExtendedToWithItemsIn(n, paItems)

	  #-----------------------------------------------------#
	 #  EXTENDIND THE LIST OF LISTS USING THE GIVEN ITEMS  #
	#-----------------------------------------------------#

	def ExtendWithItemsIn(paItems)
		This.ExtendToWithItemsIn( This.SizeOfLargestList(), paItems)

		def ExtendWithItemsInQ(paItems)
			This.ExtendWithItemsIn(paItems)
			return This

		def ExtendUsingItemsIn(paItems)
			This.ExtendWithItemsIn(paItems)

			def ExtendUsingItemsInQ(paItems)
				return This.ExtendWithItemsInQ(paItems)

	def ExtendedWithItemsIn(paItems)
		aResult = This.Copy().ExtendWithItemsInQ(paItems).Content()
		return aResult

		def ExtendedUsingItemsIn(paItems)
			return This.ExtendedWithItemsIn(paItems)

	  #================================#
	 #  SHRINKING THE LIST OF LISTS   #
	#================================#

	def Shrink()
		This.ShrinkTo( This.SizeOfSmallestList() )

		def ShrinkQ()
			This.Shrink()
			return This

		#< @FunctionAlternativeForms

		def AdjustToSmallest()
			This.Shrink()

		def AdjustToSmallestSize()
			This.Shrink()

		def AdjustToSmallestList()
			This.Shrink()

		def AdjustToMin()
			This.Shrink()

		def AdjustToMinSize()
			This.Shrink()

		def AdjustToMinList()
			This.Shrink()

		#>

	def Shrinked()
		aResult = This.Copy().ShrinkQ().Content()
		return aResult

		#< @FunctionAlternativeForms

		def AdjustedToSmallest()
			This.Shrinked()

		def AdjustedToSmallestSize()
			This.Shrinked()

		def AdjustedToSmallestList()
			This.Shrinked()

		def AdjustedToMin()
			This.Shrinked()

		def AdjustedToMinSize()
			This.Shrinked()

		def AdjustedToMinList()
			This.Shrinked()

		#>

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
				This.ReplaceAt(i, aTemp)
			ok

		next

		def ShrinkToQ(n)
			This.ShrinkTp(n)
			return This

		#< @FunctionAlternativeForm

		def ShrinkToPosition(n)
			This.ShrinkTo(n)

		#>

	def ShrinkedTo(n)
		aResult = This.Copy().ShrinkToQ(n).Content()
		return aResult

		def ShrinkedToPosition(n)
			if NOT isNumber(n)
				StzRaise("Incorrect param type! n must be a number.")
			ok

			return This.ShrinkedTo(n)

		def AdjustedTo(n)
			This.ShrinkedTo(n)

		def AdjustedToPosition(n)
			This.ShrinkedTo(n)

	  #--------------------------------------------------------------------------------------#
	 #  SHRINKING (EACH LIST IN) THE LIST OF LISTS TO A GIVEN POSITION USING A GIVEN VALUE  #
	#--------------------------------------------------------------------------------------#

	def ShrinkToWith(n, pWith)

		if CheckingParams()

			if isList(n) and Q(n).IsToOrToPosition(n)
				n = n[2]
			ok
	
			if NOT isNumber(n)
				StzRaise("Incorrect param type! n must be a number.")
			ok
	
			if isList(pWith) and Q(pWith).IsWithOrByOrUsingNamedParam()
				pWith = pWith[2]
			ok

		ok

		aContent = This.Content()
		nLen = len(aContent)
		nLargest = This.SizeOfLargestList()

		aResult = []

		for i = 1 to nLen
			nLenList = len(aContent[i])

			if n > nLargest
				loop
			ok

			if n < nLenList
				aResult + Q(aContent[i]).ShrinkedTo(n)

			else
				aResult + Q(aContent[i]).ExtendtedToWith(n, pWith)
				#NOTE this a misspelled form --> Extend(t)edToWith
			ok
		next

		This.UpdateWith(aResult)


		def ShrinkToWithQ(n, pWith)
			This.ShrinkToWith(n, pWith)
			return This

		#< @FunctionAlternativeForms

		def ShrinkToUsing(n, pUsing)
			This.ShrinkToWith(n, pWith)

		def ShrinkToBy(n, pBy)
			This.ShrinkToWith(n, pWith)

		#--

		def AdjustToWith(n, pWith)
			This.ShrinkToWith(n, pWith)

		def AdjustToUsing(n, pWith)
			This.ShrinkToWith(n, pWith)

		def AdjustToBy(n, pBy)
			This.ShrinkToWith(n, pWith)

		#>

	def ShrinkedToWith(n, pWith)
		aResult = This.Copy().ShrinkToWithQ(n, pWith).Content()
		return aResult

		#< @FunctionAlternativeForms

		def ShrinkedToUsing(n, pUsing)
			return This.ShrinkedToWith(n, pWith)

		def ShrinkedToBy(n, pBy)
			return This.ShrinkedToWith(n, pWith)

		#--

		def AdjustedToWith(n, pWith)
			This.ShrinkedToWith(n, pWith)

		def AdjustedToUsing(n, pWith)
			This.ShrinkedToWith(n, pWith)

		def AdjustedToBy(n, pBy)
			This.ShrinkedToWith(n, pWith)

		#>

	  #-----------------------------------------------------------------------------#
	 #  ADJUSTING THE LIST OF LISTS TO A GIVEN NUMBER OF ITEMS USING A GIVEN ITEM  #
	#-----------------------------------------------------------------------------#

	def AdjustXT(n, pWith)
	
		if CheckingParams()
	
			if isList(n) and Q(n).IsToNamedParam()
				n = n[2]
			ok
		
			if isList(pWith) and Q(pWith).IsOneOfTheseNamedParams([ :With, :By, :Using ])
				pWith = pWith[2]
			ok
		ok
	
		This.AdjustToUsing(n, pWith)

		def AdjustXTQ(n, pWith)
			This.AdjustXT(n, pWith)
			return This

		def ShrinkXT(n, pWith)
			This.AdjustXT(n, pWith)

			def ShrinkXTQ(n, pWith)
				return This.AdjustXTQ(n, pWith)

	def AdjustedXT(n, pWith)
		aResult = This.Copy().AdjustXTQ(n, pWith).Content()
		return aResult

		def ShrinkedXT(n, pWith)
			return This.AdjustedXT(n, pWith)

	  #========================================#
	 #   ASSOCIATING THE LISTS ITEM BY ITEM   #
	#========================================#

	def Associate()
		This.Update( @Association(This.Content()) )

		def AssociateQ()
			This.Associate()
			return This

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

		def ReverseItems()
			This.ReverseLists()


		def ReverseListsQ()
			This.ReverseLists()
			return This

		def Reverse()
			This.ReverseLists()

			def ReverseQ()
				return This.ReverseListsQ()

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

		aReversed = This.Content()

		for i = 1 to nLen
			aReversed[i] = Q(aListOfLists[i]).Reversed()
		next

		This.UpdateWith(aReversed)

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

	def IndexCS(pCaseSensitive)
		if isList(pCaseSensitive) and Q(pCaseSensitive).IsCaseSensitiveNamedParam()
			pCaseSensitive = pCaseSensitive[2]
		ok

		if NOT ( isNumber(pCaseSensitive) and (pCaseSensitive = 0 or pCaseSensitive = 1) )
			StzRaise("Incorrect param type! pCaseSensitive must be TRUE or FALSE.")
		ok

		aLists = @aContent

		if pCaseSensitive = FALSE
			aLists = This.Lowercased()
		ok

		nLenLists = len(aLists)

		# Early cheks

		if nLenLists = 0
			return []
		ok

		# Doing the job

		aItems = This.FlattenedQ().WithoutDuplicationCS(pCaseSensitive)
		nLenItems = len(aItems)

		aResult = []
	
		for i = 1 to nLenItems
			anPos = []

			for j = 1 to nLenLists
				nLen = len(aLists[j])
				for w = 1 to nLen
					if ring_type(aLists[j][w]) = ring_type(aItems[i]) and
					   aLists[j][w] = aItems[i]

						anPos + j
					ok
				next
			next

			aResult + [ aItems[i], anPos ]

		next

		return aResult

		def IndexCSQ()
			return This.IndexCSQR(pCaseSensitive, :stzList)

		def IndexCSQR(pCaseSensitive, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.IndexCS(pCaseSensitive) )

			on :stzHashList
				return new stzHashList( This.IndexCS(pCaseSensitive) )

			on :stzListOfLists
				return new stzListOfLists( This.IndexCS(pCaseSensitive) )

			other
				StzRaise("Unsupported return type!")
			off

	def IndexedCS(pCaseSensitive)
		return This.IndexCS(pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def Index()
		return This.IndexCS(TRUE)

		def IndexQ()
			return This.IndexQR(:stzList)

		def IndexQR(pcReturnType)
			return This.IndexCSQR(TRUE, pcReturnType)

	def Indexed()
		return This.Index()

	  #--------------------#
	 #   INDEXING -- XT   #
	#--------------------#

	def IndexCSXT(pCaseSensitive)
		if isList(pCaseSensitive) and Q(pCaseSensitive).IsCaseSensitiveNamedParam()
			pCaseSensitive = pCaseSensitive[2]
		ok

		if NOT ( isNumber(pCaseSensitive) and (pCaseSensitive = 0 or pCaseSensitive = 1) )
			StzRaise("Incorrect param type! pCaseSensitive must be TRUE or FALSE.")
		ok

		aLists = @aContent

		if pCaseSensitive = FALSE
			aLists = This.Lowercased()
		ok

		nLenLists = len(aLists)

		# Early cheks

		if nLenLists = 0
			return []
		ok

		# Doing the job

		aItems = This.FlattenedQ().WithoutDuplicationCS(pCaseSensitive)
		nLenItems = len(aItems)

		aResult = []
	
		for i = 1 to nLenItems
			aPos = []

			for j = 1 to nLenLists
				nLen = len(aLists[j])
				for w = 1 to nLen
					if ring_type(aLists[j][w]) = ring_type(aItems[i]) and
					   aLists[j][w] = aItems[i]

						aPos + [ j, w ]
					ok
				next
			next

			aResult + [ aItems[i], aPos ]

		next

		return aResult

		def IndexCSXTQ()
			return This.IndexCSXTQR(pCaseSensitive, :stzList)

		def IndexCSXTQR(pCaseSensitive, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.IndexCSXT(pCaseSensitive) )

			on :stzHashList
				return new stzHashList( This.IndexCSXT(pCaseSensitive) )

			on :stzListOfLists
				return new stzListOfLists( This.IndexCSXT(pCaseSensitive) )

			other
				StzRaise("Unsupported return type!")
			off

	def IndexedCSXT(pCaseSensitive)
		return This.IndexCSXT(pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def IndexXT()
		return This.IndexCSXT(TRUE)

		def IndexXTQ()
			return This.IndexXTQR(:stzList)

		def IndexXTQR(pcReturnType)
			return This.IndexCSXTQR(TRUE, pcReturnType)

	def IndexedXT()
		return This.IndexXT()

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

		def HowManyEntry()
			return len(o1.IndexOn(:Position)[pEntry])

		def HowManyEntries()
			return len(o1.IndexOn(:Position)[pEntry])

	def NthOccurrenceOfEntry(n, pEntry)
		return o1.IndexOn(:Position)[pEntry][n]

		def NthOccurrencesOfEntry(n, pEntry)
			return This.NthOccurrenceOfEntry(n, pEntry)

	def FirstOccurrenceOfEntry(pEntry)
		return NthOccurrenceOfEntry(1, pEntry)

	def LastOccurrenceOfEntry(pEntry)
		return NthOccurrenceOfEntry(This.NumberOfOccurrenceOfEntry(pEntry), pEntry)

	  #========================================================#
	 #   CHECKING IF THE LIST OF LISTS CONTAINS A GIVEN ITEM  #
	#========================================================#

	def ContainsItemCS(pItem, pCaseSensitive)
		bResult = FALSE
		aListOfLists = This.ListOfLists()
		nLen = len(aListOfLists)

		for i = 1 to nLen
			oStzList = new stzList( aListOfLists[i] )
			if oStzList.ContainsCS(pItem, pCaseSensitive)
				bResult = TRUE
				exit
			ok
		next

		return bResult

	#-- WITHOUT CASESENSITIVITY

	def ContainsItem(pItem)
		return This.ContainsItemCS(pItem, :CaseSensitive)

	  #---------------------------------------------#
	 #  GETTING THE LISTS CONTAINING A GIVEN ITEM  #
	#---------------------------------------------#

	def ListsContainingItemCS(pItem, pCaseSensitive)
		aResult = []
		aListOfLists = This.ListOfLists()
		nLen = len(aListOfLists)

		for i = 1 to nLen
			oStzList = new stzList(aListOfLists[i])
			if oStzList.ContainsCS(pItem, pCaseSensitive)
				aResult + aListOfLists[i]
			ok
		next
		return aResult

	#-- WITHOUT CASESENSITIVITY

	def ListsContainingItem(pItem)
		return This.ListsContainingItemCS(pItem, TRUE)

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
		return This.EachListContainsCS(pItem, TRUE)

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

	  #==============================================#
	 #  GETTING A MERGED COPY OF THE LIST OF LISTS  #
	#==============================================#

	def Merge()
		StzRaise("Can't merge the list of lists! Instead you can return a merged copy of it using Merged()")

		def MergeQ()
			StzRaise("Can't merge the list of lists! Instead you can return a merged copy of it using Merged()")

	def Merged()
		aContent = This.Content()
		aResult = @Merge(@aContent)
		return aResult

	  #----------------------------------------#
	 #  GETTING A FLATTENED COPY OF THE LIST  #
	#----------------------------------------#

	def Flatten()
		StzRaise("Can't flatten the list of lists! Instead you can return a flattend copy of it using Flattened()")

		def FlattenQ()
			StzRaise("Can't flatten the list of lists! Instead you can return a flattend copy of it using Flattened()")

	def Flattened()
		return This.ToStzList().Flattened()

		def FlattenedQ()
			return new stzList( This.Flattened() )

	  #===========================================================#
	 #  CHECKING IF THE SIZE OF EACH ITEM EQUALS A GIVEN NUMBER  #
	#===========================================================#

	def SizeOfEach@Is(n)
		aContent = This.Content()
		nLen = len(aContent)

		nResult = TRUE

		for i = 1 to nLen
			if len(aContent[i]) != n
				bResult = FALSE
				exit
			ok
		next

		return nResult

		#< @FunctionalternativeForms

		def TheSizeOfEach@Is(n)
			return This.SizeOfEach@Is(n)

		def TheSizeInEach@Is(n)
			return This.SizeOfEach@Is(n)

		def TheSizeOfEach@IsEqualTo(n)
			return This.SizeOfEach@Is(n)

		def TheSizeInEach@IsEqualTo(n)
			return This.SizeOfEach@Is(n)

		def SizeOfEachListEquals(n)
			return This.SizeOfEach@Is(n)

		def SizeInEachListEquals(n)
			return This.SizeOfEach@Is(n)

		def SizeOfEach@IsEqualTo(n)
			return This.SizeOfEach@Is(n)

		def SizeInEach@IsEqualTo(n)
			return This.SizeOfEach@Is(n)

		def TheSizeOfEachListEquals(n)
			return This.SizeOfEach@Is(n)

		def TheSizeInEachListEquals(n)
			return This.SizeOfEach@Is(n)

		def EachListHasTheSize(n)
			return This.SizeOfEach@Is(n)

		def EachListHasSize(n)
			return This.SizeOfEach@Is(n)

		def EachListHasItsSizeEqualTo(n)
			return This.SizeOfEach@Is(n)

		def EachListHasThisSize(n)
			return This.SizeOfEach@Is(n)

		def EachListHasThisSameSize(n)
			return This.SizeOfEach@Is(n)

		#--

		def TheNumberOfItemsOfEach@Is(n)
			return This.SizeOfEach@Is(n)

		def TheNumberOfItemsInEach@Is(n)
			return This.SizeOfEach@Is(n)

		def TheNumberOfItemsOfEach@IsEqualTo(n)
			return This.SizeOfEach@Is(n)

		def TheNumberOfItemsInEach@IsEqualTo(n)
			return This.SizeOfEach@Is(n)

		def NumberOfItemsOfEachListEquals(n)
			return This.SizeOfEach@Is(n)

		def NumberOfItemsInEachListEquals(n)
			return This.SizeOfEach@Is(n)

		def NumberOfItemsOfEach@IsEqualTo(n)
			return This.SizeOfEach@Is(n)

		def NumberOfItemsInEach@IsEqualTo(n)
			return This.SizeOfEach@Is(n)

		def TheNumberOfItemsOfEachListEquals(n)
			return This.SizeOfEach@Is(n)

		def TheNumberOfCharsInEachStringEquals(n)
			return This.SizeOfEach@Is(n)

		def EachListHasTheNumberOfItems(n)
			return This.SizeOfEach@Is(n)

		def EachListHasNumberOfItems(n)
			return This.SizeOfEach@Is(n)

		def EachListHasItsNumberOfItemsEqualTo(n)
			return This.SizeOfEach@Is(n)

		def EachListItemHasThisNumberOfItems(n)
			return This.SizeOfEach@Is(n)

		def EachListItemHasThisSameNumberOfItems(n)
			return This.SizeOfEach@Is(n)

		#>

	  #===================================#
	 #  CHECKING IF ALL LISTS ARE EQUAL  #
	#===================================#

	def AllListsAreEqualCS(pCaseSensitive)
		return This.AllItemsAreEqualCS(pCaseSensitive) # Inherited from stzList

		def AllListsAreMadeOfSameItemsCS(pCaseSensitive)
			return This.AllListsAreEqualCS(pCaseSensitive)

		def AllListsAreMadeOfTheSameItemsCS(pCaseSensitive)
			return This.AllListsAreEqualCS(pCaseSensitive)

		#--

		def ListsAreEqualCS(pCaseSensitie)
			return This.AllListsAreEqualCS(pCaseSensitive)

		def ListsAreMadeOfSameItemsCS(pCaseSensitive)
			return This.AllListsAreEqualCS(pCaseSensitive)

		def ListsAreMadeOfTheSameItemsCS(pCaseSensitive)
			return This.AllListsAreEqualCS(pCaseSensitive)

		#--

		def IsMadeOfSameListCS(pCaseSensitive)
			return This.AllListsAreEqualCS(pCaseSensitive)

		def IsMadeOfTheSameListCS(pCaseSensitive)
			return This.AllListsAreEqualCS(pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def AllListsAreEqual()
		return This.AllListsAreEqualCS(TRUE)

		def AllListsAreMadeOfSameItems()
			return This.AllListsAreEqual()

		def AllListsAreMadeOfTheSameItems()
			return This.AllListsAreEqual()

		#--

		def ListsAreEqual()
			return This.AllListsAreEqual()

		def ListsAreMadeOfSameItems()
			return This.AllListsAreEqual()

		def ListsAreMadeOfTheSameItems()
			return This.AllListsAreEqual()

		#--

		def IsMadeOfSameList()
			return This.AllListsAreEqual()

		def IsMadeOfTheSameList()
			return This.AllListsAreEqual()

	  #======================================#
	 #  COMMON ITEMS BETWEEN ALL THE LISTS  #
	#======================================#

	def CommonItemsCS(pCaseSensitive)
		if isList(pCaseSensitive) and Q(pCaseSensitive).IsCaseSensitiveNamedParam()
			pCaseSensitive = pCaseSensitive[2]
		ok

		if NOT ( isNumber(pCaseSensitive) and (pCaseSensitive = 0 or pCaseSensitive = 1) )
			StzRaise("Incorrect param type! pCaseSensitive must be TRUE or FALSE.")
		ok

		aLists = @aContent

		if pCaseSensitive = FALSE
			aLists = This.Lowercased()
		ok

		nLenLists = len(aLists)

		# Early cheks

		if nLenLists = 0
			return []

		but This.AllListsAreEqualCS(pCaseSensitive)
			return aLists[1]
		ok

		# Doing the job

		aItems = StzListQ(aLists).FlattenQ().WithoutDuplicationCS(pCaseSensitive)
		nLenItems = len(aItems)

		aResult = []
	
		for i = 1 to nLenItems

			bExistsInAllLists = TRUE
			for j = 1 to nLenLists

				if ring_find(aLists[j], aItems[i]) = 0
					bExistsInAllLists = FALSE
					exit
				ok
			next
			if bExistsInAllLists
				aResult + aItems[i]
			ok
		next

		return aResult

		def IntersectionCS(pCaseSensitive)
			return This.CommonItemsCS(pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def CommonItems()
		return This.CommonItemsCS(TRUE)

		def Intersection()
			return This.CommonItems()

	  #================================================#
	 #  GETTING THE NTH COLOUMN IN THE LIST OF LISTS  #
	#================================================#

	def Cols()
		nLen = This.NumberOfCols()
		aResult = []

		for i = 1 to nLen
			aResult + This.Col(i)
		next

		return aResult

		def Columns()
			return This.Cols()

	def NumberOfColumns()
		nResult = This.MaxSize()
		return nResult

		#< @FunctionAlternativeForms

		def NumberOfCols()
			return This.NumberOfColumns()

		def CountColumns()
			return This.NumberOfColumns()

		def CountCols()
			return This.NumberOfColumns()

		def HowManyColumns()
			return This.NumberOfColumns()

		def HowManyCols()
			return This.NumberOfColumns()

		#>

	def NthcolumnXT(n) # Adds NULL if size of innerlist < n
		if CheckingParams()
			if NOT isNumber(n)
				StzRaise("Incorrect param type! n must be a number.")
			ok
		ok

		nLen = len(@aContent)
	
		if EarlyCheck()
			if nLen = 0
				return []
			ok

			if n < 1 or n > This.NumberOfCols()
				return []
			ok
		ok

		# Doing the job

		aResult = []

		for i = 1 to nLen
			nLenList = len(@aContent[i])
			if nLenList >= n
				aResult + @aContent[i][n]
			else
				aResult + NULL
			ok
		next

		return aResult

		#< @FunctionFluentForm

		def NthColumnXTQ(n)
			return new stzList(This.NthColumnXT(n))

		#>

		#< @FunctionAlternativeForm

		def NthColXT(n)
			return This.NthColumnXT(n)

			def NthColXTQ(n)
				return This.NthColumnXTQ(n)

		def ColXT(n)
			return This.NthColumnXT(n)

			def ColXTQ(n)
				return This.NthColumnXTQ(n)

		#>

	def NthColumn(n)
		if CheckingParams()
			if NOT isNumber(n)
				StzRaise("Incorrect param type! n must be a number.")
			ok
		ok

		nLen = len(@aContent)

		if EarlyCheck()
			if nLen = 0
				return []
			ok

			if n < 1 or n > This.NumberOfCols()
				return []
			ok
		ok

		# Doing the job

		aResult = []

		for i = 1 to nLen
			nLenList = len(@aContent[i])
			if n <= nLenList
				aResult + @aContent[i][n]
			ok
		next

		return aResult

		#< @FunctionFluentForm

		def NthColumnQ(n)
			return new stzList(This.NthColumn(n))

		#>

		#< @FunctionAlternativeForm

		def NthCol(n)
			return This.NthColumn(n)

			def NthColQ(n)
				return This.NthColumnQ(n)

		def NthItems(n)
			return This.NthColumn(n)

			def NthItemsQ(n)
				return This.NthColumnQ(n)

		def Col(n)
			return This.NthColumn(n)

			def ColQ(n)
				return This.NthColumnQ(n)

		#>

	def FirstColumn()
		return This.NthColumn(1)

		#< @FunctionFluentForm

		def FirstColumnQ()
			return new stzList(This.FirstColumn())

		#>

		#< @FunctionAlternativeForm

		def FirstCol()
			return This.FirstColumn()

			def FirstColQ()
				return This.FirstColumnQ()

		def FirstItems()
			return This.NthColumn(1)

			def FirstItemsQ()
				return This.NthColumnQ(1)

		#>

	def LastColumn()
		return This.NthColumn(This.NumberOfColumns())

		#< @FunctionFluentForm

		def LastColumnQ()
			return new stzList(This.LastColumn())

		#>

		#< @FunctionAlternativeForm

		def LastCol()
			return This.LastColumn()

			def LastColQ()
				return This.LastColumnQ()

		def LastItems()
			return This.LastColumn()

			def LastItemsQ()
				return This.LastColumnQ()

		#>

	  #==========================================#
	 #  ADDING A COLUMN AT THE END OF THE LIST  #
	#==========================================#

	def AddCol(paList)
		/* EXAMPLE

		o1 = new stzListOfLists([
			[ 1 ],
			[ "one", "two" ],
			[ ]
		])
		
		o1.AddCol([ 2, "three", 0 ])
		? @@NL( o1.Content() )
		#--> [
		#	[ 1, 2 ],
		#	[ "one", "two", "three" ],
		#	[ 0 ]
		# ]

		*/

		if CheckingParams()
			if NOT isList(paList)
				StzRaise("Incorrect param! paList must be a list.")
			ok
		ok

		nLenList = len(paList)
		if nLenList = 0
			return
		ok

		aContent = This.Content()
		nLenContent = len(aContent)

		if nLenList > 1 and nLenContent = 1 and len(aContent[1]) = 0
			
			for i = 1 to nLen - 1
				aContent + []
			next
		ok

		nMin = Min([ nLenContent, nLenList ])

		for i = 1 to nMin
			aContent[i] + paList[i]
		next

		This.UpdateWith(aContent)

	  #------------------------------------------------------#
	 #  ADDING A COLUMN AT THE END OF THE LIST -- EXTENDED  #
	#------------------------------------------------------#
	# Justifies the lists and then adds the column

	def AddColXT(paList)
		/* EXAMPLE

		o1 = new stzListOfLists([
			[ 1 ],
			[ "one", "two" ],
			[ ]
		])
		
		o1.AddCol([ 2, "three", 0 ])
		? @@NL( o1.Content() )
		#--> [
		#	[ 1, 2 ],
		#	[ "one", "two", "three" ],
		#	[ 0 ]
		# ]

		*/

		if CheckingParams()
			if NOT isList(paList)
				StzRaise("Incorrect param! paList must be a list.")
			ok
		ok

		This.Justify()

		aContent = This.Content()
		nLen = len(aContent)

		for i = 1 to nLen
			aContent[i] + paList[i]
		next	

		This.UpdateWith(aContent)

	  #==================================#
	 #  SORTING NTH LIST IN  ASCENDING  #
	#==================================#

	def SortNthList(n)
		aContent = This.Content()
		aSorted = @SortList(aContent[n])
		aContent[n] = aSorted

		This.UpdateWith(aContent)


		def SortNthListQ(n)
			This.SortNthList(n)
			return This

		def SortupNthList(n)
			This.SortNthList(n)

			def SortupNthListQ(n)
				return This.SortNthListQ(n)

		def SortUpNthListInAscending(n)
			This.SortNthList(n)

			def SortUpNthListInAscendingQ(n)
				return This.SortNthListQ(n)

	def NthListSorted(n)
		aResult = This.Copy().SortNthListInAscendingQ().Content()

		def NthListSortedUp(n)
			return NthListSorted(n)

		def NthListSortedInAscending(n)
			return NthListSorted(n)

	  #----------------------------------#
	 #  SORTING NTH LIST IN DESCENDING  #
	#----------------------------------#

	def SortDownNthList(n)
		aContent = This.Content()
		aSorted = ring_reverse( @SortList(aContent[n]) )
		aContent[n] = aSorted

		This.UpdateWith(aContent)


		def SortDownNthListQ(n)
			This.SortDownNthList(n)
			return This

		def SortNthListInDescending(n)
			This.SortDownNthList(n)

			def SortNthListInDescendingQ(n)
				return This.SortNthListQ(n)

	def NthListSortedDown(n)
		aResult = This.Copy().SortDownNthListQ(n).Content()
		return aResult

		def NthListSortedInDescending(n)
			return NthListSortedDown(n)

	  #--------------------------------------------------------------------------#
	 #  CHECKING IF THE LIST OF LISTS IS SORTED IN ASCENDING ON THE NTH COLUMN  #
	#--------------------------------------------------------------------------#

	def IsSortedInAscending()
		return This.IsSortedInAscendingOn(1)

		def IsSortedUp()
			return This.IsSortedInAscending()

		def IsSorted()
			return This.IsSortedInAscending()

	def IsSortedInAscendingOn(n)
		bResult = This.ColQ(n).IsSortedInAscending()
		return bResult

		def IsSortedOnUp(n)
			return This.IsSortedInAscendingDown(n)

		def IsSortedOn(n)
			return This.IsSortedInAscendingDown(n)

	  #---------------------------------------------------------------------------#
	 #  CHECKING IF THE LIST OF LISTS IS SORTED IN DESCENDING ON THE NTH COLUMN  #
	#---------------------------------------------------------------------------#

	def IsSortedInDescending()
		return This.IsSortedOnInDescending(1)

		def IsSortedDown()
			return This.IsSortedInDescending()

	def IsSortedOnInDescending(n)
		bResult = This.ColQ(n).IsSortedInDescending()
		return bResult

		def IsSortedOnDown(n)
			return This.IsSortedInDescendingDown(n)

	  #----------------------------------#
	 #  SORTING THE LISTS IN ASCENDING  #
	#==================================#

	def Sort()
		This.SortOn(1)

		#< @FunctionFluentForm

		def SortQ()
			This.Sort()
			return This

		#>

		#< @FunctionAlternativeForms

		def SortInAscending()
			This.Sort()

			def SortInAscendingQ()
				return This.SortQ()

		#--

		def SortUp()
			This.Sort()

			def SortUpQ()
				return This.SortQ()

		#>

	def Sorted()
		aResult = This.Copy().SortQ().Content()
		return aResult

		def SortedInAscending()
			return This.Sorted()

		def SortedUp()
			return This.Sorted()

	  #-----------------------------------#
	 #  SORTING THE LISTS IN DESCENDING  #
	#-----------------------------------#

	def SortDown()
		This.SortOnDown(1)

		#< @FunctionFluentForm

		def SortDownQ()
			This.SortDown()
			return This

		#>

		#< @FunctionAlternativeForm

		def SortInDescending()
			This.SortDown()

			def SortInDescendingQ()
				return This.SortDownQ()

		#>

	def SortedDown()
		aResult = This.Copy().SortDownQ().Content()
		return aResult

		def SortedInDescending()
			return This.SortedDown()

	  #-----------------------------------------------#
	 #  SORTING THE LIST OF LISTS ON A GIVEN COLUMN  #
	#===============================================#

	def SortOn(n)

		aResult = @SortListsOn(This.Content(), n)

		This.UpdateWith(aResult)

		#< @FunctionFluentForm

		def SortOnQ(n)
			This.SortOn(n)
			return This

		#>

		#< @FunctionAlternativeForms

		def SortOnUp(n)
			This.SortOn(n)

			def SortOnUpQ(n)
				This.SortOn(n)
				return This

		def SortOnInAscending(n)
			This.SortOn(n)

			def SortOnInAscendingQ(n)
				return This.SortOnQ(n)

		#>

	def SortedOn(n)
		aResult = This.Copy().SortOnQ(n).Content()

		return aResult

		def SortedOnUp(n)
			return This.SortedOn(n)

		def SortedOnInAscending(n)
			return This.SortedOn(n)

	  #-------------------------------------------------------------#
	 #  SORTING THE LIST OF LISTS IN DESCENDING ON A GIVEN COLUMN  #
	#-------------------------------------------------------------#

	def SortOnDown(n)
		aResult = ring_reverse( This.SortedOn(n) )
		This.UpdateWith(aResult)

		#< @FunctionFluentForm

		def SortOnDownQ(n)
			This.SortOnDown(n)
			return This

		#>

		#< @FunctionAlternativeForms

		def SortOnInDescending(n)
			This.SortDown(n)

			def SortOnInDescendingQ(n)
				return This.SortOnDownQ(n)

		#>

	def SortedOnDown(n)
		aResult = This.Copy().SortOnDownQ(n).Content()

		return aResult

		def SortedOnInDescending(n)
			return This.SortedOnDown(n)

	  #---------------------------------------------------------------#
	 #  SORTING THE LISTS BY AN EVALUATED EXPRESSION - IN ASCENDING  #
	#===============================================================#
 	#note
	# Bu default the sorting is made by evaluating the first column

	def SortBy(pcExpr)
		This.SortOnBy(1, pcExpr)

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
		aResult = This.Copy().SortByQ(pcExpr).Content()
		return aResult

		def SortedByInAscending(pcExpr)
			return This.SortedBy(pcExpr)

		def SortedByUp(pcExpr)
			return This.SortedBy(pcExpr)

	  #------------------------------------------------------#
	 #  SORTING THE LISTS BY AN EXPRESSION - IN DESCENDING  #
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
		aResult = This.Copy().SortByInDescendingQ(pcExpr).Content()
		return aResult

		def SortedByDown(pcExpr)
			return This.SortedByInDescending(pcExpr)

	  #--------------------------------------------------------------------------------------#
	 #  SORTING THE LISTS BY AN EXPRESSION EVALUATED AGAINST A GIVEN COLUMN - IN ASCENDING  #
	#======================================================================================#

	def SortOnByXT(nCol, pcExpr) #TODO
	#--> returns a hashlist with the evaluated expression
		StzRaise("Non implemented yet!")

	def SortOnBy(nCol, pcExpr)

		aContent = This.Content()
		nLen = len(aContent)

		aCol = This.Col(nCol)
		nLenCol = len(aCol)

		cCode = 'value = (' + StzStringQ(pcExpr).TrimQ().TheseBoundsRemoved("{","}") + ')'

		aResult = []

		for @i = 1 to nLenCol
			@item = aCol[@i]
			eval(cCode)
			ring_insert(aContent[@i], 1, value)
		next

		This.UpdateWith( @SortLists(aContent) )
		This.RemoveCol(1)
		
		#< @FunctionFluentForm

		def SortOnByQ(nCol, pcExpr)
			This.SortOnBy(ncol, pcExpr)
			return This

		#>

		#< @FunctionAlternativeForms

		def SortOnByInAscending(nCol, pcExpr)
			This.SortOnBy(nCol, pcExpr)

			def SortOnByInAscendingQ(nCol, pcExpr)
				return This.SortOnByQ(nCol, pcExpr)

		def SortOnByUp(nCol, pcExpr)
			This.SortOnBy(nCol, pcExpr)

			def SortOnByUQ(nCol, pcExpr)
				return This.SortOnByQ(nCol, pcExpr)

		#>

	def SortedOnBy(nCol, pcExpr)
		aResult = This.Copy().SortOnByQ(nCol, pcExpr).Content()
		return aResult

		def SortedOnByInAscending(nCol, pcExpr)
			return This.SortedOnBy(nCol, pcExpr)

		def SortedOnByUp(nCol, pcExpr)
			return This.SortedOnBy(nCol, pcExpr)

	  #---------------------------------------------------------------------------------------#
	 #  SORTING THE LISTS BY AN EXPRESSION EVALUATED AGAINST A GIVEN COLUMN - IN DESCENDING  #
	#---------------------------------------------------------------------------------------#

	def SortOnByInDescending(nCol, pcExpr)
		This.SortOnByInAscending(nCol, pcExpr)
		This.Reverse()

		def SortOnByInDescendingQ(nCol, pcExpr)
			This.SortOnByInDescending(nCol, pcExpr)
			return This

		def SortOnByDown(nCol, pcExpr)
			This.SortOnByInDescending(nCol, pcExpr)

			def SortOnByDownQ(nCol, pcExpr)
				return This.SortOnByInDescendingQ(nCol, pcExpr)

	def SortedOnByInDescending(nCol, pcExpr)
		aResult = This.Copy().SortOnByInDescendingQ(nCol, pcExpr).Content()
		return aResult

		def SortedOnByDown(nCol, pcExpr)
			return This.SortedOnByInDescending(nCol, pcExpr)

	  #===========================================#
	 #  REMOVING DUPLICATES INSIDE THE NTH LIST  #
	#===========================================#

	def RemoveDuplicatesInNthList(n)
		aContent = This.Content()
		aContent[n] = @WithoutDuplicates(aContent[n])
		This.UpdateWith(aContent)


		def RemoveDuplicatesInNthListQ(n)
			This.RemoveDuplicatesInNthList(n)
			return

	def DuplicatesInNthListRemoved(n)
		aResult = This.Copy().RemoveDuplicatesInNthListQ(n).Content()
		return aResult

		def WithoutDuplicatesInNthList(n)
			return This.DuplicatesInNthListRemoved(n)

		def WithoutDuplicationInNthList(n)
			return This.DuplicatesInNthListRemoved(n)

		def WithoutDuplicationsInNthList(n)
			return This.DuplicatesInNthListRemoved(n)

	  #--------------------------------------------#
	 #  REMOVING DUPLICATES INSIDE ALL THE LISTS  #
	#--------------------------------------------#

	def RemoveDuplicatesInLists()
		aContent = This.Content()
		nLen = len(aContent)

		for i = 1 to nLen
			aContent[i] = @WithoutDuplicates(@aContent[i])
		next

		This.UpdateWith(aContent)


		def RemoveDuplicatesInListsQ()
			This.RemoveDuplicatesInLists()
			return This

	def DuplicatesInListsRemoved()
		aResult = This.RemoveDuplicatesInListsQ().Content()
		return aResult

		#< @FunctionAlternativeForms

		def WithoutDuplicatesInLists()
			return This.DuplicatesInListsRemoved()

		def WithoutDuplicationsInLists()
			return This.DuplicatesInListsRemoved()

		def WithoutDuplicationInLists()
			return This.DuplicatesInListsRemoved()
 
		#>
	
	  #=================================#
	 #  CLASSIFYING THE LIST OF LISTS  #
	#=================================#

	#NOTE
	# Classification is performed on the first column by default
	# ~> to make it on another column, use ClassifyOn(nCol)

	def Classify()
		acContent = This.FirstColQ().StringifyNamedObjectsQ().Lowercased()

		nLen = len(acContent)
		anPosUndefined = []
		acSeen = []

		aResult = []

		for i = 1 to nLen

			if isString(acContent[i])

				if acContent[i] = :@NullObject or
				   acContent[i] = :@TrueObject or
				   acContent[i] = :@FalseObject

					anPosUndefined + i
					loop
				ok

				nLenList = len(@aContent[i])

				if ring_find(acSeen, acContent[i]) = 0
					aResult + [ acContent[i], [] ]

					for j = 2 to nLenlist
						aResult[ acContent[i] ] + @aContent[i][j]
					next

					acSeen + acContent[i]

				else

					for j = 2 to nLenList
						aResult[ acContent[i] ] + @aContent[i][j]
					next
					
				ok
			else
				anPosUndefined + i
			ok
		next

		nLenUndefined = len(anPosUndefined)
		if nLenUndefined > 0
			aResult + [ :@Undefined, [] ]
	
			
			for i = 1 to nLenUndefined
				nPos = anPosUndefined[i]
				nLenList = len(@aContent[nPos])
	
				for j = 2 to nLenList
					aResult[ :@Undefined ] + @aContent[nPos][j]
				next
			next
		ok

		return aResult

		#< @FunctionFluentForms

		def ClassifyQ()
			return This.ClassifyQR(:stzList)

		def ClassifyQR(pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.Classify() )

			on :stzListOfHashList
				return new stzHashList( This.Classify() )

			other
				StzRaise("Unssupported return type!")

			off
		#>

		#< @FunctionAlternativeForm

		def classified()
			return this.classify()

		#>

	  #------------------------------------------------#
	 #  CLASSIFYING THE LIST BASED ON THE NTH COLUMN  #
	#------------------------------------------------#

	def ClassifyOn(pnColNumber)
		oCopy = This.Copy().MoveColQ(pnColNumber, 1)
		aResult = oCopy.Classify()
		return aResult

		#< @FunctionFluentForms

		def ClassifyOnQ(pnColNumber)
			return This.ClassifyOnQR(pnColNumber, :stzList)

		def ClassifyOnQR(pnColNumber, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.ClassifyOn(pnColNumber) )

			on :stzListOfHashList
				return new stzHashList( This.ClassifyOn(pnColNumber) )

			other
				StzRaise("Unssupported return type!")

			off
		#>

		#< @FunctionAlternativeForm

		def ClassifiedOn(pnColNumber)
			return This.classifyOn(pnColNumber)

		#--

		def ClassifyOnCol(pnColNumber)
			return This.classifyOn(pnColNumber)

		def ClassifiedOnCol(pnColNumber)
			return This.classifyOn(pnColNumber)

		def ClassifyOnColumn(pnColNumber)
			return This.classifyOn(pnColNumber)

		def ClassifiedOnColumn(pnColNumber)
			return This.classifyOn(pnColNumber)
 
		#>

	  #----------------------------------------------------------#
	 #  CLASSIFYING THE LIST OF LISTS USING A GIVEN EXPRESSION  #
	#----------------------------------------------------------#

	def ClassifyBy(pcExpr)
		return This.ClassifyOnBy(1, pcExpr)

		#< @FunctionFluentForms

		def ClassifyByQ(pcExpr)
			return This.ClassifyByQR(pcExpr, :stzList)

		def ClassifyByQR(pcExpr, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.ClassifyBy(pcExpr) )

			on :stzListOfHashList
				return new stzHashList( This.ClassifyBy(pcExpr) )

			other
				StzRaise("Unssupported return type!")

			off
		#>

	def ClassifiedBy(pcExpr)
		return This.ClassifyBy(pcExpr)

	  #----------------------------------------------------------------------------#
	 #  CLASSIFYING THE LIST OF LISTS ON A GIVEN COLUMN USING A GIVEN EXPRESSION  #
	#----------------------------------------------------------------------------#

	def ClassifyOnBy(nCol, pcExpr)

		if CheckingParams()
			if NOT isNumber(nCol)
				StzRaise("Incorrect param type! n must be a number.")
			ok

			if NOT isString(pcExpr)
				StzRaise("Incorrect param type! pcExpr must be a string.")
			ok

			if NOT StzStringQ(pcExpr).ContainsCS("@item", FALSE)
				StzRaise("Syntax error! pcExpr must contain the keword @item.")
			ok
		ok

		cCode = 'value = (' + StzStringQ(pcExpr).TrimQ().TheseBoundsRemoved("{", "}") + ')'

		aContent = This.Content()

		aCol = This.Col(nCol)
		nLenCol = len(aCol)

		aResult = []

		for @i = 1 to nLenCol
			@item = aCol[@i]
			eval(cCode)
			ring_insert(aContent[@i], nCol, value)
		next

		aResult = StzListOfListsQ(aContent).
				RemoveColQ(nCol+1).
				ClassifyOn(nCol)

		return aResult

	  #===============================================#
	 #  MOVING A COLUMN FROM A POSITION TO AN OTHER  #
	#===============================================#

	def MoveCol(n1, n2)

		if CheckingParams()
			if NOT (isNumber(n1) and isNumber(n2))
				StzRaise("Incorrect param type! n1 and n2 must be both numbers.")
			ok
		ok

		# Early checks

		if n1 = n2
			return
		ok

		nNumberOfCols = This.NumberOfCols()

		if n1 < 1 or n1 > nNumberOfCols
			return
		ok

		if n2 < 1 or n2 > nNumberOfCols
			return
		ok

		# Doing the job

		aContent = This.Content()
		nLen = len(aContent)

		for i = 1 to nLen
			nLenList = len(aContent[i])
			if n1 <= nLenList and n2 <= nLenList
				@Move(aContent[i], n1, n2)
			ok
		next

		This.UpdateWith(aContent)


		#< @FunctionFluentForm

		def MoveColQ(n1, n2)
			This.MoveCol(n1, n2)
			return This

		#>

		#< @FunctionAlternativeForm

		def MoveColumn(n1, n2)
			This.MoveCol(n1, n2)

			def MoveColumnQ(n1, n2)
				return This.MoveColQ(n1, n2)

		def MoveNthItems(n1, n2)
			This.MoveCol(n1, n2)

			def MoveNthItemsQ(n1, n2)
				return This.MoveColQ(n1, n2)

		#>

	def ColMoved(n1, n2)
		aResult = This.Copy().MoveColQ(n1, n2).Content()
		return aResult

		def ColumnMoved(n1, n2)
			return This.ColMoved(n1, n2)

		def NthItemsMoved(n1, n2)
			return This.ColMoved(n1, n2)

	  #=============================================#
	 #  SWAPPING TWO COLUMNS IN THE LIST OF LISTS  #
	#=============================================#

	def SwapCols(n1, n2)
		if CheckingParams()

			if isList(n1) and Q(n1).IsOneOfTheseNamedParams([
				:From, :FromPosition,
				:Between, :BetweenPosition, :BetweenPositions ])
				
				n1 = n1[2]
			ok

			if isList(n2) and Q(n2).IsOneOfTheseNamedParams([
				:To, :ToPosition, :And, :AndPosition ])
				
				n1 = n2[2]
			ok

			if NOT (isNumber(n1) and isNumber(n2))
				StzRaise("Incorrect param type! n1 and n2 must be both numbers.")
			ok
		ok

		# Early checks

		if n1 = n2
			return
		ok

		nNumberOfCols = This.NumberOfCols()

		if n1 < 1 or n1 > nNumberOfCols
			return
		ok

		if n2 < 1 or n2 > nNumberOfCols
			return
		ok

		# Doing the job

		aContent = This.Content()
		nLen = len(aContent)

		for i = 1 to nLen
			nLenList = len(aContent[i])
			if n1 <= nLenList and n2 <= nLenList
				ring_swap(aContent[i], n1, n2)
			ok
		next

		This.UpdateWith(aContent)


		#< @FunctionFluentForm

		def SwapColsQ(n1, n2)
			This.SwapCols(n1, n2)
			return This

		#>

		#< @FunctionAlternativeForms

		def SwapColumns(n1, n2)
			This.SwapCols(n1, n2)

			def SwapColumnsQ(n1, n2)
				return This.SwapColsQ(n1, n2)

		#--

		def SwapNthItems(n1, n2)
			This.SwapCols(n1, n2)

			def SwapNthItemsQ(n1, n2)
				return This.SwapColsQ(n1, n2)

		#>

	def ColsSwapped(n1, n2)
		aResult = This.Copy().SwapCols(n1, n2).Content()
		return aResult

		def ColumnsSwapped(n1, n2)
			return This.ColsSwapped(n1, n2)

		def NthItemsSwapped(n1, n2)
			return This.ColsSwapped(n1, n2)

	  #===========================================#
	 #  INSERTING A COLUMN IN THE LIST OF LISTS  #
	#===========================================#

	def InsertCol(n, paColData)
		if CheckingParams()

			if NOT isList(paColData)
				StzRaise("Incorrect param type! paColData must be a list.")
			ok

			if isList(n) and Q(n).IsAtOrAtPositionNamedParams()
				n = n[2]
			ok

			if NOT isNumber(n)
				StzRaise("Incorrect param type! n must be a number.")
			ok
		ok

		# Early check

		nNumberOfCols = This.NumberOfCols()

		if n < 1 or n > nNumberOfCols
			return
		ok

		# Doing the job

		aContent = This.Content()
		nLen = len(aContent)
		nLenCol = len(paColData)

		for i = 1 to nLen
			nLenList = len(aContent[i])

			item = NULL
			if i <= nLenCol
				item = paColData[i]
			ok

			if n <= nLenList
				ring_insert(aContent[i], n, item)
			ok

		next

		This.UpdateWith(aContent)


		#< @FunctionFluentForm

		def InsertColQ(n, paColData)
			This.InsertCol(n, paColData)
			return This

		#>

		#< @FunctionAlternativeForms

		def InsertItems(n, paColData)
			This.InsertCol(n, paColData)

			def InsertItemsQ(n, paColData)
				return This.InsertColQ(n, paColData)

		#>

	  #=================================================#
	 #  REMOVING A COLUMN FROM FROM THE LIST OF LISTS  #
	#=================================================#
	
	def RemoveCol(n)
		if CheckingParams()
			if isList(n) and Q(n).IsAtOrAtPositionNamedParam()
				n = n[2]
			ok

			if NOT isNumber(n)
				StzRaise("Incorrect param type! n must be a number.")
			ok
		ok

		# Early Check

		aContent = This.Content()
		nLen = len(aContent)

		if n < 1 or n > nLen
			return
		ok

		# Doing the job

		for i = 1 to nLen
			nLenList = len(aContent[i])
			if n <= nLenList
				ring_remove(aContent[i], n)
			ok
		next

		This.UpdateWith(aContent)


		#< @FunctionFluentForm

		def RemoveColQ(n)
			This.RemoveCol(n)
			return This

		#>

		#< @FunctionAlternativeForms

		def RemoveNthCol(n)
			This.RemoveCol(n)

			def RemoveNthColQ(n)
				return This.RemoveColQ(n)

		def RemoveColumn(n)
			This.RemoveCol(n)

			def RemoveColumnQ(n)
				return This.RemoveColQ(n)

		def RemoveNthColumn(n)
			This.RemoveCol(n)

			def RemoveNthColumnQ(n)
				return This.RemoveColQ(n)

		def RemoveNthItems(n)
			This.RemoveCol(n)

			def RemoveNthItemsQ(n)
				return This.RemoveColQ(n)

		#>

	def ColRemoved(n)
		aResult = This.Copy().RemoveColQ(n).Content()
		return aResult

		#< @FunctionAlternativeForms

		def NthColRemoved(n)
			return This.ColRemoved(n)

		def ColumnRemoved(n)
			return This.ColRemoved(n)

		def NthColumnRemoved(n)
			return This.ColRemoved(n)

		def NthItemsRemoved(n)
			return This.ColRemoved(n)

		#>

	  #------------------------------------------------#
	 #  REMOVING MANY COLUMNS FROM THE LIST OF LISTS  #
	#------------------------------------------------#

	def RemoveCols(anColNumbers)
		if CheckingParams()
			if isList(anColNumbers) and Q(anColNumbers).IsAtOrAtPositionsNamedParams()
				anColNumbers = anColNumbers[2]
			ok

			if NOT ( isList(anColNumbers) and @IsListOfNumbers(anColNumbers) )
				StzRaise("Incorrect param type! anColNumbers must be a list of numbers.")
			ok
		ok

		aContent = This.Content()
		nLen = len(aContent)

		anColNumbers = ring_sort(anColNumbers)
		nLenCols = len(anColNumbers)

		for i = nLenCols to 1 step -1
			n = anColNumbers[i]
			for j = 1 to nLen
				nLenList = len(aContent[j])
				if n <= nLenList
					ring_remove(aContent[j], n)
				ok
			next
		next

		This.UpdateWith(aContent)


		#< @FunctionFluentForm

		def RemoveColsQ(anColNumbers)
			This.RemoveCols(anColNumbers)
			return This

		#>

		#< @FunctionAlternativeForms

		def RemoveTheseCols(anColNumbers)
			This.RemoveCols(anColNumbers)

			def RemoveTheseColqQ(anColNumbers)
				return This.RemoveColsQ(n)

		def RemoveManyCols(anColNumbers)
			This.RemoveCols(anColNumbers)

			def RemoveManyColqQ(anColNumbers)
				return This.RemoveColsQ(n)

		def RemoveColumns(anColNumbers)
			This.RemoveCols(anColNumbers)

			def RemoveColumnsQ(anColNumbers)
				This.RemoveColumns(anColNumbers)
				return This

		def RemoveTheseColumns(anColNumbers)
			This.RemoveTheseCols(anColNumbers)

			def RemoveTheseColumnsQ(anColNumbers)
				return This.RemoveCoslQ(anColNumbers)

		def RemoveManyColumns(anColNumbers)
			This.RemoveTheseCols(anColNumbers)

			def RemoveManyColumnsQ(anColNumbers)
				return This.RemoveCoslQ(anColNumbers)
	
		#>

	def ColsRemoved(anColNumbers)
		aResult = This.Copy().RemoveColsQ(anColNumbers).Content()
		return aResult

		#< @FunctionAlternativeForms

		def TheseColsRemoved(anColNumbers)
			return This.ColsRemoved(anColNumbers)

		def ManyColsRemoved(anColNumbers)
			return This.ColsRemoved(anColNumbers)

		def ColumnsRemoved(anColNumbers)
			return This.ColsRemoved(anColNumbers)

		def ManyColumnsRemoved(anColNumbers)
			return This.ColsRemoved(anColNumbers)

		def TheseColumnsRemoved(anColNumbers)
			return This.ColsRemoved(anColNumbers)

		#>

	  #===========================================#
	 #  REPLACING A COLUMN IN THE LIST OF LISTS  #
	#===========================================#

	def ReplaceCol(n, paColData)

		if CheckingParams()
			if isList(paColData) and Q(paColData).IsWithOrByNamedParam()
				paColData = paColData[2]
			ok

			if NOT isList(paColData)
				StzRaise("Incorrect param type! paColData must be a list.")
			ok

			if isList(n) and Q(n).IsAtOrAtPositionNamedParams()
				n = n[2]
			ok

			if NOT isNumber(n)
				StzRaise("Incorrect param type! n must be a number.")
			ok
		ok

		# Early check

		nNumberOfCols = This.NumberOfCols()

		if n < 1 or n > nNumberOfCols
			return
		ok

		# Doing the job

		aContent = This.Content()
		nLen = len(aContent)
		nLenCol = len(paColData)

		for i = 1 to nLen
			nLenList = len(aContent[i])

			item = NULL
			if i <= nLenCol
				item = paColData[i]
			ok

			if n <= nLenList
				aContent[i][n] = item
			ok

		next

		This.UpdateWith(aContent)


		#< @FunctionFluentForm

		def ReplaceColQ(n, paColData)
			This.ReplaceCol(n, paColData)
			return This

		#>

		#< @FunctionAlternativeForms

		def ReplaceItems(n, paColData)
			This.ReplaceCol(n, paColData)

			def ReplaceItemsQ(n, paColData)
				return This.ReplaceColQ(n, paColData)

		#>		

	  #-----------------------------------------------#
	 #  REPLACING MANY COLUMNS IN THE LIST OF LISTS  #
	#-----------------------------------------------#

	def ReplaceCols(panColNumbers, paColData)

		if CheckingParams()
			if NOT (isList(panColNumbers) and @IsListOfNumbers(panColNumbers))
				StzRaise("Incorrect param type! panColNumbers must be a list of numbers.")
			ok
		ok

		nLen = len(panColNumbers)

		for i = 1 to nLen
			this.ReplaceCol(panColNumbers[i], paColData)
		next

	  #==================================================#
	 #  TRANSFORMING THE LIST OF LISTS TO OTHER FORMS   #
	#==================================================#
		
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
		cList = @@(This.Content())
		oStr = new stzString(cList)
		cResult = oStr.ToListInShortForm()
		return cResult

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

	def ToStzList()
		return new stzList( This.Content() )

	def ToStzListQ()
		return new stzList( This.Content() )

	def ToListOfStrings() #TODO // Do we need it? compare with stzList.Stringified()
		aResult = []
		aListOfLists = This.ListOfLists()
		nLen = len(aListOfLists)

		for i = 1 to nLen 
			aResult + @@( aListOfLists[i] ) # @@ --> ComputableForm( list )
		next

		return aResult


	def IsListOfPairs()
		aContent = This.Content()
		nLen = len(aContent)

		bResult = TRUE

		for i = 1 to nLen
			if NOT (isList(aContent[i]) and len(aContent[i]) = 2)
				bResult = FALSE
				exit
			ok
		next

		return bResult

	def ToStzListOfpairs()
		if This.IsListOfPairs()
			return new stzListOfPairs(This.Content())
		else
			StzRaise("Can't transform the list of lists into a list of pairs! Lists are not all pairs.")
		ok

	  #--------------------------------------#
	 #  GETTING THE SPEEDUP OF THE NUMBERS  #
	#======================================#

	def SpeedUp()
		anNumbers = This.Content()

		n1 = anNumbers[1]
		n2 = anNumbers[2]

		nResult = n1 / n2

		return nResult

		def SpeedUpX()
			return This.SpeedUp()

	  #-------------------------------------------------#
	 #  GETTING THE GAIN FACTOR FROM NUMBER TO NUMBER  #
	#-------------------------------------------------#

	def GainFactor()
		anNumbers = This.Content()

		n1 = anNumbers[1]
		n2 = anNumbers[2]

		nResult = n2 / n1

		return nResult
	
		def GainX()
			return This.GainFactor()
	
	  #========================================#
	 #  CHECKING IF THE LISTS ARE CONTIGUOUS  #
	#========================================#

	func AreContiguous()

		bResult = TRUE
		nLen = len(@aContent)

		for i = 1 to nLen

			aList = @aContent[i]
			nLenList = len(aList)

			if nLenList > 2

				if @IsListOfNumbers(aList)
					for j = 2 to nLenList
						if NOT aList[j] = aList[j-1] + 1
							bResult = FALSE
							exit
						ok
					next
	
				but @IsListOfChars(aList)
					for j = 2 to nLenList
						if NOT ascii(aList[j]) = ascii(aList[j-1]) + 1
							bResult = FALSE
							exit
						ok
					next
				ok
			ok

			if bResult = FALSE
				exit
			ok

		next
	
		return bResult

		def AreContinuous()
			return This.AreContiguous()
	
		def AreConsecutive()
			return This.AreContiguous()
	
		#--
	
		def @AreContiguous(paList)
			return This.AreContiguous()
	
		def @AreContinuous()
			return This.AreContiguous()
	
		def @AreConsecutive()
			return This.AreContiguous()

	  #==================================#
	 #  FINDING A SUBLIST IN THE LISTS  #
	#==================================#

	def FindSubListCS(paItems, pCaseSensitive)

		if CheckingParams()
			if NOT isList(paItems)
				StzRaise("Incorrect param type! paItems must be a list.")
			ok

			if len(paItems) < 2
				StzRaise("Incorrect param value! paItems must contain at least two items.")
			ok
		ok

		aAdjusted = This.Adjusted()
		nLen = len(aAdjusted)

		aResult = []

		for i = 1 to nLen

			anPos = StzListQ(aAdjusted[i]).FindSubListCS(paItems, pCaseSensitive)
			
			if len(anPos) > 0
				aResult + [ i, anPos ]
			ok

		next

		return aResult

		def FindContiguousItemsCS(paItems, pCaseSensitive)
			return This.FindSubListCS(paItems, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindSubList(paItems)
		return This.FindSubListCS(paItems, TRUE)

		def FindContiguousItems(paItems)
			return This.FindSubList(paItems)
