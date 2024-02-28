#---------------------------------------------------------------------------#
# 		    SOFTANZA LIBRARY (V1.0) - STZLISTOFLISTS		    #
#		An accelerative library for Ring applications		    #
#---------------------------------------------------------------------------#
#									    #
# 	Description : The class for managing lists of lists (2DLists)       #
#	Version	    : V1.0 (2020-2023)				            #
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

func AllListsHaveSameSize(paListOfLists)
	if CheckParams()
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
	if CheckParams()
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
	if CheckParams()
	
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

	
func IsListOfLists(paList)
	if CheckParams()
		if NOT isList(paList)
			StzRaise("Incorrect param type!")
		ok
	ok

	bResult = TRUE
	nLen = len(paList)

	for i = 1 to nLen
		if NOT isList(paList[i])
			bResult = FALSE
			exit
		ok
	next i

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfLists(paList)
		return IsListOfLists(paList)

	func ListIsListOfLists(paList)
		return IsListOfLists(paList)

	#--

	func IsAListOfLists(paList)
		return IsListOfLists(paList)

	func @IsAListOfLists(paList)
		return IsListOfLists(paList)

	func ListIsAListOfLists(paList)
		return IsListOfLists(paList)

	#>

func StzListsQ(paList)
	return new stzLists(paList)

func Stz2DListQ(paList)
	return new stz2DList(paList)

  #=========#
 #  CLASS  #
#=========#

class stzLists from stzListOfLists

class stz2DList from stzListOfLists

class stzListOfLists from stzList

	@aContent = []

	def init(paList)

		if CheckParams()

		if NOT ( isList(paList) and
		  	 ( len(paList) = 0 or @IsListOfLists(paList) ) )

			StzRaise("Can't create the stzListOfLists object! You must provide a list that is empty or a list of lists.")
		ok

		ok

		@aContent = paList

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
		if isList(paList) and Q(paList).IsWithOrByOrUsingNamedParam()
			paList = paList[2]

			if NOT Q(paList).IsListOfLists(paList)
				StzRaise("Incorrect param type! paList must be a list of lists.")
			ok
		ok

		@aContent = paList

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
		@aContent + paList

	def AddMany(paListOfLists)
		if CheckParams()
			if NOT ( isList(paListOfLists) and Q(paListOfLists).IsListOfLists() )
				StzRaise("Incorrect param type! paListOfLists must be a list of lists.")
			ok
		ok

		nLen = len(paListOfLists)
		for i = 1 to nLen
			@aContent + paListOfLists[i]
		next

		def AddManyLists(paListOfLists)
			This.AddMany(paListOfLists)

	  #---------------#
	 #   NTH LIST    #
	#---------------#

	def NthList(n)
		if CheckParams()

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

			#< @FunctionFluentForm

			def ListsWhereQ(pcCondition)
				return new stzList(This.ListsWhere(pcCondition))

			#>
		#>

	  #----------------------#
	 #   POSITIONS WHERE    #
	#----------------------#

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

	  #------------------------------------------#
	 #   GETTING THE SIZES OF THE INNER LISTS   #
	#------------------------------------------#

	def Sizes()
		
		aContent = This.ListOfLists()
		nLen = len(aContent)

		anResult = []

		for i = 1 to nLen
			aResult + len(aContent[i])
		next

		return aResult

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

		bResult = TRUE

		for i = 2 to nLen
			if len( aContent ) != len( aContent[i-1] )
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

	# TODO: adds "big", "great", and "large" as alternatives all over the library
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

	def SmallestListZ()
		aResult = [ This.SmallestList(), This.FindSmallestList() ]
		return aResult

		def SmallestZ()
			return This.SmallestListZ()

		def SmallestListAndItsPosition()
			return This.SmallestListZ()

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

		#--

		def LargestListAndItsPosition()
			return This.LargestListZ()

		def BiggestListAndItsPosition()
			return This.LargestListZ()

		def LargestAndItsPosition()
			return This.LargestListZ()

		def BiggestAndItsPosition()
			return This.LargestListZ()

		#>

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

		#>

	def Extended()
		aResult = This.Copy().ExtendQ().Content()
		return aResult

		def EachListExtended()
			return This.Extended()

		def Adjusted()
			return This.Extended()

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

		def ExtendEachListXT()
			This.ExtendXT()

			def ExtendEachListXTQ()
				return This.ExtendXTQ()
		#>

	def ExtendedXT()
		aResult = This.Copy().ExtendXTQ().Content()
		return aResult

		def EachListExtendedXT()
			return This.ExtendedXT()

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
		if CheckParams()
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
			    	Q(pItem).IsOneOfThese([
					:ItemsRepeated, :RepeatingItems,
					:RepeatedItems, :ByRepeatingItems
				])
	
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

		if CheckParams()

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
				# Note this a misspelled form --> Extend(t)edToWith
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
	
		if CheckParams()
	
			if isList(n) and Q(n).IsToNamedParam()
				n = n[2]
			ok
		
			if isList(pWith) and Q(pWith).IsOneOfThese([ :With, :By, :Using ])
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

	def IndexCS(pCaseSensitive)
		if isList(pCaseSensitive) and Q(pCaseSensitive).IsCaseSensitiveNamedParam()
			pCaseSensitive = pCaseSensitive[2]
		ok

		if NOT @IsBoolean(pCaseSensitive)
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
			return This.IndexCSQR(:stzList, pCaseSensitive)

		def IndexCSQR(pcReturnType, pCaseSensitive)
			switch pcReturnType
			on :stzList
				return new stzList( This.IndexCS(pCaseSensitive) )

			on :stzHashList
				return new stzHashList( This.IndexCS(pCaseSensitive) )

			on :stzListOfLists
				return new stzListOfLists( This.IndexCS(pCaseSensitive) )

			other
				StzRaise("Insupported return type!")
			off

	def IndexedCS(pCaseSensitive)
		return This.IndexCS(pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def Index()
		return This.IndexCS(TRUE)

		def IndexQ()
			return This.IndexQR(:stzList)

		def IndexQR(pcReturnType)
			return This.IndexCSQR(pcReturnType, TRUE)

	def Indexed()
		return This.Index()

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
		return @Merge(@aContent)

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

	def SizeOfEachListIs(n)
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

		def TheSizeOfEachListIs(n)
			return This.SizeOfEachListIs(n)

		def TheSizeInEachListIs(n)
			return This.SizeOfEachListIs(n)

		def TheSizeOfEachListIsEqualTo(n)
			return This.SizeOfEachListIs(n)

		def TheSizeInEachListIsEqualTo(n)
			return This.SizeOfEachListIs(n)

		def SizeOfEachListEquals(n)
			return This.SizeOfEachListIs(n)

		def SizeInEachListEquals(n)
			return This.SizeOfEachListIs(n)

		def SizeOfEachListIsEqualTo(n)
			return This.SizeOfEachListIs(n)

		def SizeInEachListIsEqualTo(n)
			return This.SizeOfEachListIs(n)

		def TheSizeOfEachListEquals(n)
			return This.SizeOfEachListIs(n)

		def TheSizeInEachListEquals(n)
			return This.SizeOfEachListIs(n)

		def EachListHasTheSize(n)
			return This.SizeOfEachListIs(n)

		def EachListHasSize(n)
			return This.SizeOfEachListIs(n)

		def EachListHasItsSizeEqualTo(n)
			return This.SizeOfEachListIs(n)

		def EachListHasThisSize(n)
			return This.SizeOfEachListIs(n)

		def EachListHasThisSameSize(n)
			return This.SizeOfEachListIs(n)

		#--

		def TheNumberOfItemsOfEachListIs(n)
			return This.SizeOfEachListIs(n)

		def TheNumberOfItemsInEachListIs(n)
			return This.SizeOfEachListIs(n)

		def TheNumberOfItemsOfEachListIsEqualTo(n)
			return This.SizeOfEachListIs(n)

		def TheNumberOfItemsInEachListIsEqualTo(n)
			return This.SizeOfEachListIs(n)

		def NumberOfItemsOfEachListEquals(n)
			return This.SizeOfEachListIs(n)

		def NumberOfItemsInEachListEquals(n)
			return This.SizeOfEachListIs(n)

		def NumberOfItemsOfEachListIsEqualTo(n)
			return This.SizeOfEachListIs(n)

		def NumberOfItemsInEachListIsEqualTo(n)
			return This.SizeOfEachListIs(n)

		def TheNumberOfItemsOfEachListEquals(n)
			return This.SizeOfEachListIs(n)

		def TheNumberOfCharsInEachStringEquals(n)
			return This.SizeOfEachListIs(n)

		def EachListHasTheNumberOfItems(n)
			return This.SizeOfEachListIs(n)

		def EachListHasNumberOfItems(n)
			return This.SizeOfEachListIs(n)

		def EachListHasItsNumberOfItemsEqualTo(n)
			return This.SizeOfEachListIs(n)

		def EachListItemHasThisNumberOfItems(n)
			return This.SizeOfEachListIs(n)

		def EachListItemHasThisSameNumberOfItems(n)
			return This.SizeOfEachListIs(n)

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

		if NOT @IsBoolean(pCaseSensitive)
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

	  #==========================================#
	 #  SORTING THE LIST OF LISTS IN ASCENDING  #
	#==========================================#

	def SortNthList(n)
		aSorted = StzListQ(This.Content()[n]).Sorted()
		@aContent[n] = aSorted

	def Sort()
		nLen = This.NumberOfLists()
		for i = 1 to nLen
			This.SortNthList(i)
		next

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

		def SortLists()
			This.Sort()

			def SortListsQ()
				return This.SortQ()

		def SortListsInAscending()
			This.Sort()

			def SortListsInAscendingQ()
				return This.SortQ()
		#>

	def Sorted()
		aResult = This.Copy().SortQ().Content()
		return aResult

		def SortedInAscending()
			return This.Sorted()		

		def ListsSorted()
			return This.Sorted()

		def ListsSortedInAscending()
			return This.Sorted()

	  #-------------------------------------------#
	 #  SORTING THE LIST OF LISTS IN DESCENDING  #
	#-------------------------------------------#

	def SortInDescending()
		aResult = ring_reverse( This.SortedInAscending() )
		This.UpdateWith(aResult)

		#< @FunctionFluentForm

		def SortInDescendingQ()
			This.SortInDescending()
			return This

		#>

		#< @FunctionAlternativeForm

		def SortListsInDescending()
			This.SortInDescending()

			def SortListsInDescendingQ()
				return This.SortInDescendingQ()

		#>

	def SortedInDescendning()
		aResult = This.Copy().SortInDescendingQ().Content()
		return aResult

		def ListsSortedInDescending()
			return This.SortedInDescendning()

	  #-----------------------------------------------#
	 #  SORTING THE LIST OF LISTS BY A GIVEN COLUMN  #
	#===============================================#
	# TODO: Sorting by many columns

	def SortBy(n)
		This.UpdateBy(This.SortedBy(n))

	def SortedBy(n)
		if This.IsEmpty()
			return
		ok

		aShrinked = This.Shrinked()
		nLen = len(ashrinked[1])
		if nLen = 0
			return
		ok

		aSorted = ring_sortXT(aShrinked, n)
		return aSorted

	  #======================================================================#
	 #  FINDING EXTRA-ITEMS BASED ON LISTS HAVING SMALLEST NUMBER OF ITEMS  #
	#======================================================================#

	def FindExtraItems()
		aContent = This.Content()
		nLen = len(aContent)

		nMin = This.SmallestSize()

		aResult = []

		for i = 1 to nLen

			anPos = []

			nLenList = len(aContent[i])
			if nLenList > nMin
				anPos = (nMin + 1) : nLenList
			ok

			aResult + [ i, anPos ]
		next

		return aResult

		def FindExtraItemsZ()
			return This.FindExtraItems()

	  #----------------------------------------------------------------------#
	 #  GETTING EXTRA-ITEMS BASED ON LISTS HAVING SMALLEST NUMBER OF ITEMS  #
	#----------------------------------------------------------------------#
	# The logical inverse of Shrinked()

	def ExtraItems()

		aContent = This.Content()

		aPos = This.FindExtraItems()
		nLen = len(aPos)

		aResult = []

		for i = 1 to nLen
			aItems = []
			nLenItems = len(aPos[i][2])

			for j = 1 to nLenItems
				aItems + aContent[i][aPos[i][2][j]]
			next

			aResult + aItems
		next

		return aResult

	  #--------------------------------------------------#
	 #  GETTING EXTRA-ITEMS ALONG WITH THEIR POSITIONS  #
	#--------------------------------------------------#

	def ExtraItemsZ()
		aResult = Associtation([ This.ExtraItems(), This.FindExtraItems() ])
		return aResult

		def ExtraItemsAndTheirPositions()
			return This.ExtraItemsZ()

	  #===========================================#
	 #  REMOVING DUPLICATES INSIDE THE NTH LIST  #
	#===========================================#

	def RemoveDuplicatesInNthList(n)
		@aContent[n] = @WithoutDuplicates(@aContent[n])

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
		nLen = len(@aContent)

		for i = 1 to nLen
			@aContent[i] = @WithoutDuplicates(@aContent[i])
		next

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

	def ToStzList() # NOTE: normally, we don't need it since stzList is the mother class
		return new stzList( This.Content() )

	def ToStzListQ()
		return new stzList( This.Content() )

	def ToListOfStrings() # TODO: Do we need it? compare with stzList.Stringified()
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
