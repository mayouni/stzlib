#---------------------------------------------------------------------------#
# 		    SOFTANZA LIBRARY (V0.9) - STZLISTOFLISTS		    #
#		An accelerative library for Ring applications		    #
#---------------------------------------------------------------------------#
#									    #
# 	Description : The class for managing lists of lists (2DLists)       #
#	Version	    : V0.9 (2020-2024)				            #
#	Author	    : Mansour Ayouni (kalidianow@gmail.com)		    #
#									    #
#---------------------------------------------------------------------------#

  #=============#
 #  FUNCTIONS  #
#=============#

func StzListOfListsQ(paList)
	return new stzListOfLists(paList)

func ItemExists(pItem, paList)
	# Engine-backed containment check
	_pIeList = StzEngineMarshalList(paList)
	if isString(pItem)
		_nIeResult = StzEngineListContainsStringCS(_pIeList, pItem, 1)
	else
		# For non-string items, fall back to Ring loop
		_nIeResult = 0
		_nIeLen = len(paList)
		for _iIe = 1 to _nIeLen
			if paList[_iIe] = pItem
				_nIeResult = 1
				exit
			ok
		next
	ok
	StzEngineListFree(_pIeList)
	return _nIeResult

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
				paLists[i] + ""
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

	func Associate(paList)
		return Association(paLists)

	func @Associate(paList)
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

func Pairify(paPairOfLists) # A @SpecializedForm of Association()

	# EXAMPLE
	# Pairify([ "A", "B", "C" ], [ 1, 2, 3 ])
	#--> [ [ "A", 1 ], [ "B", "2" ], [ "C", 3 ])

	if NOT ( isList(paPairOfLists) and len(paPairOfLists) = 2 and
		isList(paPairOfLists[1]) and isList(paPairOfLists[2]) )

		StzRaise("Incorrect param type! paListOf2Lists must be a pair of lists.")
	ok

	# Take a copy of the two lists (for safety)

	_aList1_ = paPairOfLists[1]
	_aList2_ = paPairOfLists[2]

	# Adjusting the size of the two lists

	_nLen1_ = len(_aList1_)
	_nLen2_ = len(_aList2_)
	_nDiff_ = Abs(_nLen1_ - _nLen2_)

	if _nLen1_ < _nLen2_
		for @i = 1 to _nDiff_
			_aList1_ + ""
		next
	else
		for @i = 1 to _nDiff_
			_aList2_ + _NULL
		next
	ok

	_nLen_ = len(_aList1_)

	# Doing the job

	_aResult_ = []

	for @i = 1 to _nLen_
		_aResult_ + [ _aList1_[@i], _aList2_[@i] ]
	next

	return _aResult_

	func @Pairify(paPairOfLists)
		return Pairify(paPairOfLists)

func CommonItemsCS(paLists, pCaseSensitive)
	aResult = StzListOfListsQ(paLists).CommonItemsCS(pCaseSensitive)
	return aResult

	func IntersectionCS(paLists, pCaseSensitive)
		return CommonItemsCS(paList, pCaseSensitive)

	func CommonCS(paLists, pCaseSensitive)
		return CommonItemsCS(paLists, pCaseSensitive)

	#--

	func @CommonItemsCS(paLists, pCaseSensitive)
		return CommonItemsCS(paLists, pCaseSensitive)

	func @IntersectionCS(paLists, pCaseSensitive)
		return CommonItemsCS(paList, pCaseSensitive)

func CommonItems(paLists)
	return CommonItemsCS(paLists, 1)

	func Intersection(paLists)
		return CommonItems(paLists)

	func Common(paLists)
		return CommonItems(paLists)

	#--

	func @CommonItems(paLists)
		return CommonItems(paLists)

	func @Intersection(paLists)
		return CommonItems(paLists)

func StzListsQ(paList)
	return new stzLists(paList)

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

class stzListOfLists from stzList

	@aContent = []

	def init(paList)

		if CheckingParams()

			if NOT isList(paList)
				StzRaise("Can't create the stzListOfLists object! You must provide a list.")
			ok

			_bInitOk_ = 1
			_nInitLen_ = len(paList)

			for _iInit_ = 1 to _nInitLen_
				if NOT isList(paList[_iInit_])
					_bInitOk_ = 0
				ok
			next

			if NOT _bInitOk_
				StzRaise("Can't create the stzListOfLists object! You must provide a list of lists!")
			ok

		ok

		if len(paList) = 0
			StzRaise("Can't create the stzListOfLists object! You must provide a non empty list.")
		ok

		@aContent = paList

		if KeepingHistory() = 1
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

	def NumberOfLists()
		return len(@aContent)

	  #-------------------------------#
	 #   UPDATING THE LIST OF LISTS  #
	#-------------------------------#

	def Update(paList)
		if CheckingParams() = 1
			if isList(paList) and Q(paList).IsWithOrByOrUsingNamedParam()
				paList = paList[2]
			ok

			if NOT @IsListOfLists(paList)
				StzRaise("Incorrect param type! paList must be a list of lists.")
			ok
		ok

		@aContent = paList

		if KeepingHisto() = 1
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
		_aAlContent_ = This.Content()
		This.UpdateWith(_aAlContent_ + paList)

	def AddMany(paListOfLists)
		if CheckingParams()
			if NOT ( isList(paListOfLists) and Q(paListOfLists).IsListOfLists() )
				StzRaise("Incorrect param type! paListOfLists must be a list of lists.")
			ok
		ok

		_aAmContent_ = This.Content()

		_nAmLen_ = len(paListOfLists)
		for _iAm_ = 1 to _nAmLen_
			@AddItem(_aAmContent_, paListOfLists[_iAm_])
		next

		This.UpdateWith(_aAmContent_)

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

				but n = :Last or n = :LastList
					n = This.NumberOfLists()

				ok
			ok

			if NOT isNumber(n)
				StzRaise("Incorrect param type! n must be a number.")
			ok

		ok

		_aNlResult_ = This.Content()[n]
		return _aNlResult_

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
	#====================================#

	def FindInListsCS(pItem, pCaseSensitive)

		if isList(pItem)
			return This.FindManyInListsCS(pItem, pCaseSensitive)
		ok

		_nFilLen_ = len(@aContent)
		_aFilResult_ = []

		for _iFil_ = 1 to _nFilLen_
			_anFilPos_ = @FindAllCS( @aContent[_iFil_], pItem, pCaseSensitive)
			_nFilLenPos_ = len(_anFilPos_)
			for _jFil_ = 1 to _nFilLenPos_
				@AddItem(_aFilResult_, [ _iFil_, _anFilPos_[_jFil_] ])
			next
		next

		return _aFilResult_

		#< @FunctionAlternativeForms

		def FindItemInListsCS(pItem, pCaseSensitive)
			return This.FindInListsCS(pItem, pCaseSensitive)

		def FindItemInsideCS(pItem, pCaseSensitive)
			return This.FindInListsCS(pItem, pCaseSensitive)

		def FindInsideCS(pItem, pCaseSensitive)
			return This.FindInListsCS(pItem, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindInLists(pItem)
		return This.FindInListsCS(pItem, 1)
	
		#< @FunctionAlternativeForms

		def FindItemInLists(pItem)
			return This.FindInLists(pItem)

		def FindItemInside(pItem)
			return This.FindInLists(pItem)

		def FindInside(pItem)
			return This.FindInLists(pItem)

		#>

	  #---------------------------------------#
	 #  FINDING MANY ITEMS INSIDE THE LISTS  #
	#---------------------------------------#

	def FindManyInListsCS(paItems, pCaseSensitive)

		if CheckParams()
			if NOT isList(paItems)
				StzRaise("Incorrect param type! paItems must be a list.")
			ok
		ok

		_aFmilItems_ = U(paItems)  # dedup -- kept for backward-compat (was computed-then-discarded)

		_nFmilLen_ = len(@aContent)
		_aoFmilLists_ = This.ToListOfStzLists()
		_aFmilResult_ = []

		for _iFmil_ = 1 to _nFmilLen_
			_anFmilPos_ = _aoFmilLists_[_iFmil_].FindManyCS(paItems, pCaseSensitive)
			_nFmilLenPos_ = len(_anFmilPos_)
			for _jFmil_ = 1 to _nFmilLenPos_
				@AddItem(_aFmilResult_, [ _iFmil_, _anFmilPos_[_jFmil_] ])
			next
		next

		return _aFmilResult_

		#< @FunctionAlternativeForms

		def FindItemsInListsCS(paItems, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindManyInLists(paItems)
		return This.FindManyInListsCS(paItems, 1)
	
		#< @FunctionAlternativeForms

		def FindItemsInLists(paItems)
			return This.FindManyInLists(pItem)

		#>

	  #--------------------------------------#
	 #  FINDING A SUBLIST INSIDE THE LISTS  #
	#======================================#

	def FindSubListInListsCS(paSubList, pCaseSensitive) #TODO
		StzRaise("Function non implemented yet!")

	def FindSubListInList(paSubList)
		return This.FindSubListInListCS(paSubList, pCaseSensitive)

	  #======================#
	 #   POSITIONS WHERE    #
	#======================#

	def PositionsW(pcCondition)

		_cPwCondition_ = StringSimplified(_StzStripBraces(pcCondition))
		aResult = []  # MUST stay bare -- referenced by user-supplied eval(cCode) below

		_aPwLists_ = This.ListOfLists()
		_nPwLen_ = len(_aPwLists_)

		for @i = 1 to _nPwLen_
			@list = _aPwLists_[@i]

			@item = @list # Allows using both @list and @item in the user's script
			_cPwCode_ = "if " + _cPwCondition_ + NL +
				TAB + "aResult + @i" + NL +
			"ok"

			eval(_cPwCode_)
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

		_cLwCondition_ = StringSimplified(_StzStripBraces(pcCondition))
		aResult = []  # MUST stay bare -- referenced by user-supplied eval(cCode) below

		_aLwLists_ = This.ListOfLists()
		_nLwLen_ = len(_aLwLists_)

		for @i = 1 to _nLwLen_
			@list = _aLwLists_[@i]

			@item = @list # Allows using both @list and @item in the user's script
			_cLwCode_ = "if " + _cLwCondition_ + NL +
				TAB + "aResult + @list" + NL +
			"ok"

			eval(_cLwCode_)
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
		_aLwzListsW_ = This.ListsW(pcCondition)
		_anLwzPosW_  = This.PositionsW(pcCondition)

		_aLwzResult_ = @Association([ _aLwzListsW_, _anLwzPosW_ ])

		return _aLwzResult_

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

		_aSzContent_ = This.ListOfLists()
		_nSzLen_ = len(_aSzContent_)

		_anSzResult_ = []

		for _iSz_ = 1 to _nSzLen_
			@AddItem(_anSzResult_, len(_aSzContent_[_iSz_]))
		next

		return _anSzResult_

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

		_aLhsContent_ = This.Content()
		_nLhsLen_ = len(_aLhsContent_)

		if _nLhsLen_ = 0
			StzRaise("Can't check inner lists! Because the list is empty.")

		but _nLhsLen_ = 1
			return 1
		ok

		_nLhsInner_ = len(_aLhsContent_[1])
		_bLhsResult_ = 1

		for _iLhs_ = 2 to _nLhsLen_
			if len( _aLhsContent_[_iLhs_] ) != _nLhsInner_
				_bLhsResult_ = 0
				exit
			ok
		next

		return _bLhsResult_

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

		def IsList2D()
			return This.ListsHaveSameNumberOfItems()

		def IsAList2D()
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

		_aFslContent_ = This.Content()
		_nFslLen_ = len(_aFslContent_)

		_anFslResult_ = []
		_nFslMin_ = This.SmallestSize()

		for _iFsl_ = 1 to _nFslLen_

			if len(_aFslContent_[_iFsl_]) = _nFslMin_
				@AddItem(_anFslResult_, _iFsl_)
			ok

		next

		return _anFslResult_

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
		_aSlResult_ = This.ItemsAtPositions( This.FindSmallestLists() )
		return _aSlResult_

	#--

	def SmallestListsZ()
		_aSlzResult_ = Association([ This.SmallestLists(), This.FindSmallestLists() ])
		return _aSlzResult_

	  #-------------------#
	 #   BIGGEST LISTS   #
	#-------------------#

	def FindBiggestLists()

		_aFblContent_ = This.Content()
		_nFblLen_ = len(_aFblContent_)
		_nFblMax_ = This.BiggestSize()

		_anFblResult_ = []

		for _iFbl_ = 1 to _nFblLen_
			if len(_aFblContent_[_iFbl_]) = _nFblMax_
				@AddItem(_anFblResult_, _iFbl_)
			ok
		next

		return _anFblResult_

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
		_anBlPos_ = This.FindBiggestLists()
		_aBlResult_ = This.ItemsAtPositions(_anBlPos_)
		return _aBlResult_

		#< @FuntionAlternativeForms

		def GreatestLists()
			return This.BiggestLists()

		def LargestLists()
			return This.BiggestLists()

		#>

	def BiggestListsZ()
		_aBlzResult_ = Association([ This.BiggestLists(), This.FindBiggestLists() ])
		return _aBlzResult_

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

		_aFlsContent_ = This.Content()
		_nFlsLen_ = len(_aFlsContent_)

		_anFlsResult_ = []

		for _iFls_ = 1 to _nFlsLen_
			if len(_aFlsContent_[_iFls_]) = n
				@AddItem(_anFlsResult_, _iFls_)
			ok
		next

		return _anFlsResult_

		#< @FunctionAlternativeForms

		def FindListsOfSize(n)
			return This.FindListsOfSizeN(n)

		def PositionsOfListsOfSizeN(n)
			return This.FindListsOfSizeN(n)

		def PositionsOfListsOfSize(n)
			return This.FindListsOfSizeN(n)

		#>

	def ListsOfSizeN(n)

		_anLsnPos_ = This.FindListsOfSizeN(n)
		_aLsnResult_ = This.ItemsAtPositions(_anLsnPos_)
		return _aLsnResult_

		#< @FunctionAlternativeForm

		def ListsOfSize(n)
			return This.ListsOfSizeN(n)

		#>

	  #------------------------------------------------------#
	 #  FINDING THE MISSING POSITIONS IN THE LIST OF LISTS  #
	#======================================================#

	func FindMissingItems()
		_nFmiMin_ = This.MinSize()
		_nFmiMax_ = This.MaxSize()

		_aFmiContent_ = This.Content()
		_nFmiLen_ = len(_aFmiContent_)

		_aFmiResult_ = []
		for _iFmi_ = 1 to _nFmiLen_
			_nFmiInner_ = len(_aFmiContent_[_iFmi_])
			if _nFmiInner_ < _nFmiMax_
				for _jFmi_ = _nFmiInner_ + 1 to _nFmiMax_
					@AddItem(_aFmiResult_, [ _iFmi_, _jFmi_ ])
				next
			ok
		next

		return _aFmiResult_

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

		_nNmiMin_ = This.MinSize()
		_nNmiMax_ = This.MaxSize()

		_aNmiContent_ = This.Content()
		_nNmiLen_ = len(_aNmiContent_)

		_nNmiResult_ = 0
		for _iNmi_ = 1 to _nNmiLen_
			_nNmiInner_ = len(_aNmiContent_[_iNmi_])
			if _nNmiInner_ < _nNmiMax_
				_nNmiResult_ += (_nNmiMax_ - _nNmiInner_)
			ok
		next

		return _nNmiResult_

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
		_aIapnResult_ = []

		_aIapnLists_ = This.ListOfLists()
		_nIapnLen_ = len(_aIapnLists_)

		for _iIapn_ = 1 to _nIapnLen_
			_aIapnList_ = _aIapnLists_[_iIapn_]
			if len(_aIapnList_) >= n
				@AddItem(_aIapnResult_, _aIapnList_[n])
			ok
		next

		return _aIapnResult_

		#< @FunctionFluentForm

		def ItemsAtPositionNQ(n)
			return This.ItemsAtPositionNQRT(n, :stzList)

		def ItemsAtPositionsNQRT(n, pcReturnType)
			if isList(pcReturnType) and IsOneOfTheseNamedParamsList(pcReturnType,[ :ReturnedAs, :ReturnAs ])
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
				return This.ItemsAtPositionNQRT(n, :stzList)

			def ItemsAtQRT(n, pcReturnType)
				return This.ItemsAtPositionNQRT(n, pcReturnType)

		def ItemsAtPosition(n)
			return This.ItemsAtPositionN(n)

			def ItemsAtPositionQ(n)
				return This.ItemsAtPositionQRT(n, :stzList)

			def ItemsAtPositionQRT(n, pcReturnType)
				return This.ItemsAtPositionQRT(n, pcReturnType)

		def ListsAtPositionN(n)
			return This.ItemsAtPositionN(n)

			def ListsAtPositionNQ(n)
				return This.ListsAtPositionNQRT(n, :stzList)

			def ListsAtPositionNQRT(n, pcReturnType)
				return This.ListsAtPositionNQRT(n, pcReturnType)

		def ListsAt(n)
			return This.ItemsAtPositionN(n)

			def ListsAtQ(n)
				return This.ListsAtQRT(n, :stzList)

			def ListsAtQRT(n, pcReturnType)
				return This.ListsAtQRT(n, pcReturnType)

		def ListsAtPosition(n)
			return This.ItemsAtPositionN(n)

			def ListsAtPositionQ(n)
				return This.ListsAtPositionQRT(n, :stzList)

			def ListsAtPositionQRT(n, pcReturnType)
				return This.ListsAtPositionQRT(n, pcReturnType)

		#>

	  #=================#
	 #  SMALLEST LIST  #
	#=================#

	def FindSmallestList()
		_nFslLen_ = This.NumberOfLists()
		if _nFslLen_ = 0
			return ""

		but _nFslLen_ = 1
			return This.NthList(1)
		ok

		_nFslResult_ = 1
		for _iFsl_ = 2 to _nFslLen_
			if len( This.NthList(_iFsl_) ) < len( This.NthList(_nFslResult_) )
				_nFslResult_ = _iFsl_
			ok
		next

		return _nFslResult_

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

		_nSltLen_ = This.NumberOfLists()
		if _nSltLen_ = 0
			return ""

		but _nSltLen_ = 1
			return This.NthList(1)
		ok

		_nSltPos_ = 1
		for _iSlt_ = 2 to _nSltLen_
			if len( This.NthList(_iSlt_) ) < len( This.NthList(_nSltPos_) )
				_nSltPos_ = _iSlt_
			ok
		next

		_aSltResult_ = This.NthList(_nSltPos_)
		return _aSltResult_

		#< @FunctionAlternativeForms

		def Smallest()
			return This.SmallestList()

		def MinList()
			return This.SmallestList()

		#>

	def SmallestListZ()
		_aSlzSingleResult_ = [ This.SmallestList(), This.FindSmallestList() ]
		return _aSlzSingleResult_

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
		_nSosResult_ = len( This.SmallestList() )
		return _nSosResult_

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
		_nFllLen_ = This.NumberOfLists()
		if _nFllLen_ = 0
			return ""

		but _nFllLen_ = 1
			return This.NthList(1)
		ok

		_nFllResult_ = 1
		for _iFll_ = 2 to _nFllLen_
			if len( This.NthList(_iFll_) ) > len( This.NthList(_nFllResult_) )
				_nFllResult_ = _iFll_
			ok
		next

		return _nFllResult_

		#< @FunctionAlternativeForms

		def FindLargest()
			return This.FindLargestList()

		def FindMaxList()
			return This.FindLargestList()

		#>

	def LargestList()

		_nLgLen_ = This.NumberOfLists()
		if _nLgLen_ = 0
			return ""

		but _nLgLen_ = 1
			return This.NthList(1)
		ok

		_nLgPos_ = 1
		for _iLg_ = 2 to _nLgLen_
			if len( This.NthList(_iLg_) ) > len( This.NthList(_nLgPos_) )
				_nLgPos_ = _iLg_
			ok
		next

		_aLgResult_ = This.NthList(_nLgPos_)
		return _aLgResult_

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
		_aLgzResult_ = [ This.LargestList(), This.FindLargestList() ]
		return _aLgzResult_

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
		_nSolResult_ = len( This.LargestList() )
		return _nSolResult_

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
		_nSolnResult_ = len( This.NthList(n) )
		return _nSolnResult_

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

		def Expand()
			This.Extend()

			def ExpandQ()
				return This.ExtendQ()

		def ExpandEachList()
			This.Extend()

			def ExpandEachListQ()
				return This.ExtendQ()

		def Stretch()
			This.Extend()

			def StretchQ()
				return This.ExtendQ()

		def StretchEachList()
			This.Extend()

			def StretchEachListQ()
				return This.ExtendQ()

		#--

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
		_aExtdResult_ = This.Copy().ExtendQ().Content()
		return _aExtdResult_

		#< @FunctionAlternativeForms

		def EachListExtended()
			return This.Extended()

		def Expanded()
			return This.Extended()

		def EachListExpanded()
			return This.Extended()

		def Stretched()
			return This.Extended()

		def EachListStretched()
			return This.Extended()

		#--

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

		def ExtendXTQ(pItem)
			This.ExtendXT(pItem)
			return This

		#>

		#< @FunctionAlternativeForm

		def ExtendEachListXT(pItem)
			This.ExtendXT(pItem)

			def ExtendEachListXTQ(pItem)
				return This.ExtendXTQ(pItem)

		def ExtendWith(pItem)
			This.ExtendXT(pItem)

			def ExtendWithQ(pItem)
				return This.ExtendXTQ(pItem)

		def ExtendEachListWith(pItem)
			This.ExtendWith(pItem)

			def ExtendEachListWithQ(pItem)
				return This.ExtendWithQ(pItem)

		#--

		def StretchXT(pItem)
			This.ExtendXT(pItem)

			def StretchXTQ(pItem)
				return This.ExtendXTQ(pItem)

		def StretchEachListXT(pItem)
			This.ExtendXT(pItem)

			def StretchEachListXTQ(pItem)
				return This.ExtendXTQ(pItem)

		def StretchWith(pItem)
			This.ExtendXT(pItem)

			def StretchWithQ(pItem)
				return This.ExtendXTQ(pItem)

		def StretchEachListWith(pItem)
			This.ExtendWith(pItem)

			def StretchEachListWithQ(pItem)
				return This.ExtendWithQ(pItem)

		#--

		def CompleteXT(pItem)
			This.ExtendXT(pItem)

			def CompleteXTQ(pItem)
				return This.ExtendXTQ(pItem)

		def CompleteEachListXT(pItem)
			This.ExtendXT(pItem)

			def CompleteEachListXTQ(pItem)
				return This.ExtendXTQ(pItem)

		def CompleteWith(pItem)
			This.ExtendXT(pItem)

			def CompleteWithQ(pItem)
				return This.ExtendXTQ(pItem)

		def ComplteEachListWith(pItem)
			This.ExtendXT(pItem)

			def CompleteEachListWithQ(pItem)
				return This.ExtendXTQ(pItem)

		#--

		def JustifyXT(pItem)
			This.ExtendXT(pItem)

			def JustifyXTQ(pItem)
				return This.ExtendXTQ(pItem)

		def JustifyEachListXT(pItem)
			This.ExtendXT(pItem)

			def JustifyEachListXTQ(pItem)
				return This.ExtendXTQ(pItem)

		def JustifyWith(pItem)
			This.ExtendXT(pItem)

			def JustifyWithQ(pItem)
				return This.ExtendXTQ(pItem)

		def JustifyEachListWith()
			This.ExtendXT(pItem)

			def JustiffyEachListWithQ(pItem)
				return This.ExtendXTQ(pItem)

		#>

	def ExtendedXT(pItem)
		_aExdxResult_ = This.Copy().ExtendXTQ(pItem).Content()
		return _aExdxResult_

		#< @FunctionAlternativeForms

		def EachListExtendedXT(pItem)
			return This.ExtendedXT(pItem)

		#--

		def ExtendedWithXT(pItem)
			return This.ExtendedXT(pItem)

		def EachListExtendedWith(pItem)
			return This.ExtendedXT(pItem)

		#==

		def StretchedXT(pItem)
			return This.ExtendedXT(pItem)

		def EachListStretchedXT(pItem)
			return This.ExtendedXT(pItem)

		#--

		def StretchedWithXT(pItem)
			return This.ExtendedXT(pItem)

		def EachListStretchedWith(pItem)
			return This.ExtendedXT(pItem)

		#==

		def JustifiedXT(pItem)
			return This.ExtendedXT(pItem)

		def EachListJustifiedXT(pItem)
			return This.ExtendedXT(pItem)

		#==

		def JustifiedWith(pItem)
			return This.ExtendedXT(pItem)

		def EachListJustifiedWith(pItem)
			return This.ExtendedXT(pItem)

		#>

	  #------------------------------------------------------------------------------------#
	 #  EXTENDING (EACH LIST IN) THE LIST OF LISTS TO A GIVEN POSITION WITH A NULL VALUE  #
	#------------------------------------------------------------------------------------#

	def ExtendTo(n)
		This.ExtendToXT(n, "")


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

		#==

		def StretchTo(n)
			This.ExtendTo(n)

			def StretchToQ(n)
				return This.ExtendToQ(n)

		def StretchToPosition(n)
			This.ExtendToPosition(n)

			def StretchToPositionQ(n)
				return This.ExtendToPositionQ(n)

		#>


	def ExtendedTo(n)
		_aExtdtResult_ = This.Copy().ExtendToQ(n).Content()
		return _aExtdtResult_

		def ExtendedToPosition(n)
			if NOT isNumber(n)
				StzRaise("Incorrect param type! n must be a number.")
			ok

			return This.ExtendedTo(n)	

		def StretchedTo(n)
			return This.ExtendedTo(n)

		def StretchedToPosition(n)
			return This.ExtendedToPosition(n)

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
			    	StzFind([
					:ItemsRepeated, :RepeatingItems,
					:RepeatedItems, :ByRepeatingItems
				], pItem) > 0
	
				This.ExtendToByRepeatingItems(n)
				return
			ok
		ok

		# Doing the job

		_nExtxLen_ = This.NumberOfLists()
		for _iExtx_ = 1 to _nExtxLen_
			_nExtxSize_ = This.SizeOfList(_iExtx_)

			_aExtxTemp_ = This.NthList(_iExtx_)
			for _jExtx_ = 1 to n - _nExtxSize_
				@AddItem(_aExtxTemp_, pItem)
			next

			This.ReplaceAt(_iExtx_, _aExtxTemp_)

		next

		#< @FuntionFluentForm

		def ExtendToXTQ(n, pItem)
			This.ExtendToXT(n, pItem)
			return This

		#>

		#< @FunctionAlternativeForm

		def ExtendToPositionXT(n, pItem)
			This.ExtendToXT(n, pItem)

		#--

		def StretchToXT(n, pItem)
			This.ExtendToXT(n, pItem)

			def StretchToXTQ(n, pItem)
				return This.ExtendToXTQ(n, pItem)

		def StretchToPositionXT(n, pItem)
			This.ExtendToPositionXT(n, pItem)

			def StretchToPositionXTQ(n, pItem)
				return This.ExtendToPositionXTQ(n, pItem)

		#>

	def ExtendedToXT(n, pItem)
		_aEdtxResult_ = This.Copy().ExtendToXTQ(n, pItem).Content()
		return _aEdtxResult_

		#< @FunctionAlternativeForm

		def ExtendedToPositionXT(n, pItem)
			if NOT isNumber(n)
				StzRaise("Incorrect param type! n must be a number.")
			ok

			return This.ExtendedToXT(n, pItem)	

		#--

		def StretchedToXT(n, pItem)
			return This.ExtendedToXT(n, pItem)

		def StretchedToPositionXT(n, pItem)
			return This.ExtendedToPositionXT(n, pItem)

		#>


	  #---------------------------------------------------------------------------------------#
	 #  EXTENDING THE LIST OF LISTS TO A GIVEN POSITION BY REPEATING THE ITEMS OF EACH LIST  #
	#---------------------------------------------------------------------------------------#

	#TODO // Add Stretch and Expand alternatives to all remaining methods

	def ExtendToByRepeatingItems(n)
		_aEtbrContent_ = This.Content()
		_nEtbrLen_ = len(_aEtbrContent_)

		_aEtbrResult_ = []

		for _iEtbr_ = 1 to _nEtbrLen_
			@AddItem(_aEtbrResult_, Q(_aEtbrContent_[_iEtbr_]).ExtendedToByRepeatingItems(n))
		next

		This.UpdateWith(_aEtbrResult_)

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
		_aEdbrResult_ = This.Copy().ExtendToByRepeatingItemsQ(n).Content()
		return _aEdbrResult_

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
		_aExbrResult_ = This.Copy().ExtendByRepeatingItemsQ().Content()
		return _aExbrResult_

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
		_aEtwiContent_ = This.Content()
		_nEtwiLen_ = len(_aEtwiContent_)

		_aEtwiResult_ = []

		for _iEtwi_ = 1 to _nEtwiLen_
			@AddItem(_aEtwiResult_, Q(_aEtwiContent_[_iEtwi_]).ExtendedToWithItemsIn(n, paItems))
		next

		This.UpdateWith(_aEtwiResult_)


		def ExtendToWithItemsInQ(n, paItems)
			This.ExtendToWithItemsIn(n, paItems)
			return This

		def ExtendToUsingItemsIn(n, paItems)
			This.ExtendToWithItemsIn(n, paItems)

			def ExtendToUsingItemsInQ(n, paItems)
				return This.ExtendToWithItemsInQ(n, paItems)

	def ExtendedToWithItemsIn(n, paItems)
		_aEtwiResult2_ = This.Copy().ExtendToWithItemsInQ(n, paItems).Content()
		return _aEtwiResult2_

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
		_aEwiResult_ = This.Copy().ExtendWithItemsInQ(paItems).Content()
		return _aEwiResult_

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
		_aSkResult_ = This.Copy().ShrinkQ().Content()
		return _aSkResult_

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
		#TODO // Review implementation for performance and history tracing

		if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		_nSktLen_ = This.NumberOfLists()
		for _iSkt_ = 1 to _nSktLen_
			_nSktSize_ = This.SizeOfList(_iSkt_)

			_aSktTemp_ = []
			if n < _nSktSize_
				_aSktTemp_ = This.NthListQ(_iSkt_).Section(1, n)
				This.ReplaceAt(_iSkt_, _aSktTemp_)
			ok

		next

		def ShrinkToQ(n)
			This.ShrinkTo(n) ### Fixed: was misspelled "ShrinkTp"
			return This

		#< @FunctionAlternativeForm

		def ShrinkToPosition(n)
			This.ShrinkTo(n)

		#>

	def ShrinkedTo(n)
		_aSkdtResult_ = This.Copy().ShrinkToQ(n).Content()
		return _aSkdtResult_

		def ShrinkedToPosition(n)
			if NOT isNumber(n)
				StzRaise("Incorrect param type! n must be a number.")
			ok

			return This.ShrinkedTo(n)

	  #--------------------------------------------------------------------------------------#
	 #  SHRINKING (EACH LIST IN) THE LIST OF LISTS TO A GIVEN POSITION USING A GIVEN VALUE  #
	#--------------------------------------------------------------------------------------#

	def ShrinkToWith(n, pItem)

		if CheckingParams()

			if isList(n) and Q(n).IsToOrToPosition(n)
				n = n[2]
			ok
	
			if NOT isNumber(n)
				StzRaise("Incorrect param type! n must be a number.")
			ok
	
			if isList(pItem) and Q(pItem).IsWithOrByOrUsingNamedParam()
				pItem = pItem[2]
			ok

		ok

		_aSkwContent_ = This.Content()
		_nSkwLen_ = len(_aSkwContent_)
		_nSkwLargest_ = This.SizeOfLargestList()

		_aSkwResult_ = []

		for _iSkw_ = 1 to _nSkwLen_
			_nSkwInner_ = len(_aSkwContent_[_iSkw_])

			if n > _nSkwLargest_
				loop
			ok

			if n < _nSkwInner_

				_aSkwTemp_ = []
				for _jSkw_ = 1 to n
					@AddItem(_aSkwTemp_, _aSkwContent_[_iSkw_][_jSkw_])
				next

				@AddItem(_aSkwResult_, _aSkwTemp_)

			else
				_aSkwTemp_ = _aSkwContent_[_iSkw_]
				_nSkwDiff_ = _nSkwInner_ - n

				for _kSkw_ = 1 to _nSkwDiff_
					@AddItem(_aSkwTemp_, pItem)
				next

				@AddItem(_aSkwResult_, _aSkwTemp_)
			ok
		next

		This.UpdateWith(_aSkwResult_)

		#< @FunctionFluentForm

		def ShrinkToWithQ(n, pItem)
			This.ShrinkToWith(n, pItem)
			return This

		#>

		#< @FunctionAlternativeForms

		def ShrinkToUsing(n, pItem)
			This.ShrinkToWith(n, pItem)

			def ShrinkToUsingQ(n, pItem)
				return This.ShrinkToWithQ(n, pItem)

		def ShrinkXT(n, pItem)
			This.ShrinkToWith(n, pItem)

			def ShrinkXTQ(n, pItem)
				return This.ShrinkToWithQ(n, pItem)

		#>

	def ShrinkedToWith(n, pWith)
		_aSktwResult_ = This.Copy().ShrinkToWithQ(n, pWith).Content()
		return _aSktwResult_

		#< @FunctionAlternativeForms

		def ShrinkedToUsing(n, pUsing)
			return This.ShrinkedToWith(n, pUsing) ### Fixed: was passing undefined pWith

		def ShrinkedToBy(n, pBy)
			return This.ShrinkedToWith(n, pBy) ### Fixed: was passing undefined pWith

		#>

	  #-----------------------------------------------------------------------------#
	 #  ADJUSTING THE LIST OF LISTS TO A GIVEN NUMBER OF ITEMS USING A GIVEN ITEM  #
	#-----------------------------------------------------------------------------#

	def AdjustWith(pItem)

		if CheckingParams()

			if isList(pItem) and Q(pItem).IsWithOrByOrUsingNamedParam()
				pItem = pItem[2]
			ok

		ok

		_aAdwContent_ = This.Content()
		_nAdwLen_ = len(_aAdwContent_)
		_nAdwLargest_ = This.SizeOfLargestList()

		_aAdwResult_ = []

		for _iAdw_ = 1 to _nAdwLen_

			_nAdwInner_ = len(_aAdwContent_[_iAdw_])

			if _nAdwInner_ = _nAdwLargest_
				@AddItem(_aAdwResult_, _aAdwContent_[_iAdw_])
				loop
			ok

			_nAdwDiff_ = Abs( _nAdwInner_ - _nAdwLargest_ )

			if _nAdwInner_ < _nAdwLargest_

				_aAdwTemp_ = _aAdwContent_[_iAdw_]

				for _jAdw_ = 1 to _nAdwDiff_
					@AddItem(_aAdwTemp_, pItem)
				next

			else

				_aAdwTemp_ = []

				for _kAdw_ = 1 to _nAdwLargest_
					@AddItem(_aAdwTemp_, _aAdwContent_[_iAdw_][_kAdw_]) ### Fixed: was [_iAdw_] not [_iAdw_][_kAdw_]
				next

			ok

			@AddItem(_aAdwResult_, _aAdwTemp_)

		next

		This.UpdateWith(_aAdwResult_)

		def AdjustWithQ(pItem)
			This.AdjustWith(pItem)
			return This

		def AdjustUsing(pItem)
			This.AdjustWith(pItem)

			def AdjustUsingQ(pItem)
				return This.AdjustWithQ(pItem)

	def AdjustedWith(pItem)
		_aAdwdResult_ = This.Copy().AdjustWithQ(pItem).Content()
		return _aAdwdResult_

		def AdjustedUsing(pItem)
			return This.AdjustedWith(pItem)

	#---

	def AdjustTo(n)
		This.AdjustXT(n, "")

		def AdjustToQ(n)
			This.AdjustTo(n)
			return This

		def AdjustToPosition(n)
			This.AdjustTo(n)

			def AdjustToPositionQ(n)
				return This.AdjustToQ(n)

	def AdjustedTo(n)
		_aAdtResult_ = This.Copy().AdjustToQ(n).Content() ### Fixed: .Conten() typo
		return _aAdtResult_

		def AdjustedToPosition(n)
			return This.AdjustedTo(n)

	#---

	def AdjustXT(n, pItem)

		if CheckingParams()

			if isList(n) and Q(n).IsToOrToPosition(n)
				n = n[2]
			ok
	
			if NOT isNumber(n)
				StzRaise("Incorrect param type! n must be a number.")
			ok
	
			if isList(pItem) and Q(pItem).IsWithOrByOrUsingNamedParam()
				pItem = pItem[2]
			ok

		ok

		_aAdxContent_ = This.Content()
		_nAdxLen_ = len(_aAdxContent_)

		_aAdxResult_ = []

		for _iAdx_ = 1 to _nAdxLen_

			_nAdxInner_ = len(_aAdxContent_[_iAdx_])

			if _nAdxInner_ = n
				@AddItem(_aAdxResult_, _aAdxContent_[_iAdx_])
				loop
			ok

			_nAdxDiff_ = Abs( _nAdxInner_ - n )

			if _nAdxInner_ < n

				_aAdxTemp_ = _aAdxContent_[_iAdx_]

				for _jAdx_ = 1 to _nAdxDiff_
					@AddItem(_aAdxTemp_, pItem)
				next

			else

				_aAdxTemp_ = []

				for _kAdx_ = 1 to n
					@AddItem(_aAdxTemp_, _aAdxContent_[_iAdx_][_kAdx_]) ### Fixed: was [_iAdx_] only
				next

			ok

			@AddItem(_aAdxResult_, _aAdxTemp_)

		next

		This.UpdateWith(_aAdxResult_)


		#< @FunctionFluentForm

		def AdjustXTQ(n, pItem)
			This.AdjustXT(n, pItem)
			return This
		#>

		def AdjustToXT(n, pItem)
			This.AdjustXT(n, pItem)

			def AdjustToXTQ(n, pItem)
				return This.AdjustXTQ(n, pItem)

		def AdjustToWith(n, pItem)
			This.AdjustXT(n, pItem)

			def AdjustToWithQ(n, pItem)
				return This.AdjustXTQ(n, pItem)

	def AdjustedXT(n, pItem)
		_aAdxdResult_ = This.Copy().AdjustXTQ(n, pItem).Content()
		return _aAdxdResult_

		def AdjustedToXT(n, pItem)
			return This.AdjustedXT(n, pItem)


		def AdjustedToWith(n, pItem)
			return This.AdjustedXT(n, pItem)

	  #========================================#
	 #   ASSOCIATING THE LISTS ITEM BY ITEM   #
	#========================================#

	def Associate()
		This.Update( @Association(This.Content()) )

		def AssociateQ()
			This.Associate()
			return This

	def Associated()
		_aAsResult_ = This.Copy().AssociateQ().Content()
		return _aAsResult_

	  #----------------------------#
	 #  PAIRIFYING THE TWO LISTS  #
	#----------------------------#

	def Pairify()
		This.UpdateWith( @Pairify(This.Content()) )

		def PairifyQ()
			This.Pairify() ### Fixed: was "Parify" typo
			return This

	def Pairified()
		_aPaResult_ = This.Copy().PairifyQ().Content()
		return _aPaResult_

	  #-------------------------------------#
	 #   REVERSING THE ITEMS OF THE LIST   #
	#-------------------------------------#

	# To avoid confusion, it's better to use the alternative forms
	# ReverseItems() and ItemsReversed()

	def ReverseLists()

		_oRvlTemp_ = new stzList(This.ListOfLists())
		_aRvlResult_ = _oRvlTemp_.Reversed()

		This.Update( _aRvlResult_ )

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
		_aRvldResult_ = This.Copy().ReverseListsQ().Content()
		return _aRvldResult_

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
		_aRiilLists_ = This.ListOfLists()
		_nRiilLen_ = len(_aRiilLists_)

		_aRiilReversed_ = This.Content()

		for _iRiil_ = 1 to _nRiilLen_
			_aRiilReversed_[_iRiil_] = Q(_aRiilLists_[_iRiil_]).Reversed()
		next

		This.UpdateWith(_aRiilReversed_)

		def ReverseItemsInListsQ()
			This.ReverseItemsInLists()
			return This

		def ReverseListsContent()
			This.ReverseItemsInLists()

			def ReverseListsContentQ()
				This.ReverseListsContent()
				return This

	def ItemsInListsReversed()
		_aIilrResult_ = This.Copy().ReverseItemsInListsQ().Content()
		return _aIilrResult_

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
			StzRaise("Incorrect param type! pCaseSensitive must be 1 or FALSE.")
		ok

		_aIxLists_ = @aContent

		if pCaseSensitive = 0
			_aIxLists_ = This.Lowercased()
		ok

		_nIxLenLists_ = len(_aIxLists_)

		# Early cheks

		if _nIxLenLists_ = 0
			return []
		ok

		# Doing the job

		_aIxItems_ = This.FlattenedQ().WithoutDuplicationCS(pCaseSensitive)
		_nIxLenItems_ = len(_aIxItems_)

		_aIxResult_ = []

		for _iIx_ = 1 to _nIxLenItems_
			_anIxPos_ = []

			for _jIx_ = 1 to _nIxLenLists_
				_nIxInnerLen_ = len(_aIxLists_[_jIx_])
				for _wIx_ = 1 to _nIxInnerLen_
					if ring_type(_aIxLists_[_jIx_][_wIx_]) = ring_type(_aIxItems_[_iIx_]) and
					   _aIxLists_[_jIx_][_wIx_] = _aIxItems_[_iIx_]

						@AddItem(_anIxPos_, _jIx_)
					ok
				next
			next

			@AddItem(_aIxResult_, [ _aIxItems_[_iIx_], _anIxPos_ ])

		next

		return _aIxResult_

		def IndexCSQ()
			return This.IndexCSQRT(pCaseSensitive, :stzList)

		def IndexCSQRT(pCaseSensitive, pcReturnType)
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
		return This.IndexCS(1)

		def IndexQ()
			return This.IndexQRT(:stzList)

		def IndexQRT(pcReturnType)
			return This.IndexCSQRT(TRUE, pcReturnType)

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
			StzRaise("Incorrect param type! pCaseSensitive must be 1 or FALSE.")
		ok

		_aIxxLists_ = @aContent

		if pCaseSensitive = 0
			_aIxxLists_ = This.Lowercased()
		ok

		_nIxxLenLists_ = len(_aIxxLists_)

		# Early cheks

		if _nIxxLenLists_ = 0
			return []
		ok

		# Doing the job

		_aIxxItems_ = This.FlattenedQ().WithoutDuplicationCS(pCaseSensitive)
		_nIxxLenItems_ = len(_aIxxItems_)

		_aIxxResult_ = []

		for _iIxx_ = 1 to _nIxxLenItems_
			_aIxxPos_ = []

			for _jIxx_ = 1 to _nIxxLenLists_
				_nIxxInnerLen_ = len(_aIxxLists_[_jIxx_])
				for _wIxx_ = 1 to _nIxxInnerLen_
					if ring_type(_aIxxLists_[_jIxx_][_wIxx_]) = ring_type(_aIxxItems_[_iIxx_]) and
					   _aIxxLists_[_jIxx_][_wIxx_] = _aIxxItems_[_iIxx_]

						@AddItem(_aIxxPos_, [ _jIxx_, _wIxx_ ])
					ok
				next
			next

			@AddItem(_aIxxResult_, [ _aIxxItems_[_iIxx_], _aIxxPos_ ])

		next

		return _aIxxResult_

		def IndexCSXTQ()
			return This.IndexCSXTQRT(pCaseSensitive, :stzList)

		def IndexCSXTQRT(pCaseSensitive, pcReturnType)
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
		return This.IndexCSXT(1)

		def IndexXTQ()
			return This.IndexXTQRT(:stzList)

		def IndexXTQRT(pcReturnType)
			return This.IndexCSXTQRT(TRUE, pcReturnType)

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
		return len(This.IndexOn(:Position)[pEntry]) ### Fixed: was bare o1

		def NumberOfOccurrencesOfEntry(pEntry)
			return This.NumberOfOccurrenceOfEntry(pEntry)

		def HowManyEntry(pEntry)
			return len(This.IndexOn(:Position)[pEntry]) ### Fixed: was bare o1 + missing pEntry param

		def HowManyEntries(pEntry)
			return len(This.IndexOn(:Position)[pEntry]) ### Fixed: was bare o1 + missing pEntry param

	def NthOccurrenceOfEntry(n, pEntry)
		return This.IndexOn(:Position)[pEntry][n] ### Fixed: was bare o1

		def NthOccurrencesOfEntry(n, pEntry)
			return This.NthOccurrenceOfEntry(n, pEntry)

	def FirstOccurrenceOfEntry(pEntry)
		return This.NthOccurrenceOfEntry(1, pEntry) ### Fixed: was bare call

	def LastOccurrenceOfEntry(pEntry)
		return This.NthOccurrenceOfEntry(This.NumberOfOccurrenceOfEntry(pEntry), pEntry) ### Fixed: was bare call

	  #========================================================#
	 #   CHECKING IF THE LIST OF LISTS CONTAINS A GIVEN ITEM  #
	#========================================================#

	def ContainsItemCS(pItem, pCaseSensitive)
		_bCicResult_ = 0
		_aCicLists_ = This.ListOfLists()
		_nCicLen_ = len(_aCicLists_)

		for _iCic_ = 1 to _nCicLen_
			_oCicList_ = new stzList( _aCicLists_[_iCic_] )
			if _oCicList_.ContainsCS(pItem, pCaseSensitive)
				_bCicResult_ = 1
				exit
			ok
		next

		return _bCicResult_

	#-- WITHOUT CASESENSITIVITY

	def ContainsItem(pItem)
		return This.ContainsItemCS(pItem, 1) ### Fixed: was passing symbol :CaseSensitive instead of 1

	  #---------------------------------------------#
	 #  GETTING THE LISTS CONTAINING A GIVEN ITEM  #
	#---------------------------------------------#

	def ListsContainingItemCS(pItem, pCaseSensitive)
		_aLciResult_ = []
		_aLciLists_ = This.ListOfLists()
		_nLciLen_ = len(_aLciLists_)

		for _iLci_ = 1 to _nLciLen_
			_oLciList_ = new stzList(_aLciLists_[_iLci_])
			if _oLciList_.ContainsCS(pItem, pCaseSensitive)
				@AddItem(_aLciResult_, _aLciLists_[_iLci_])
			ok
		next
		return _aLciResult_

	#-- WITHOUT CASESENSITIVITY

	def ListsContainingItem(pItem)
		return This.ListsContainingItemCS(pItem, 1)

	  #------------------------------------------------#
	 #  CHECKING IF A GIVEN ITEM EXISTS IN ALL LISTS  #
	#------------------------------------------------#

	def EachListContainsCS(pItem, pCaseSensitive)
		_bElcResult_ = 1
		_aElcLists_ = This.Content()
		_nElcLen_ = len(_aElcLists_)

		for _iElc_ = 1 to _nElcLen_
			if NOT Q(_aElcLists_[_iElc_]).ContainsCS(pItem, pCaseSensitive)
				_bElcResult_ = 0
				exit
			ok
		next

		return _bElcResult_

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
		return This.EachListContainsCS(pItem, 1)

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
		_aMgResult_ = @Merge(@aContent)
		return _aMgResult_

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
		_aSeContent_ = This.Content()
		_nSeLen_ = len(_aSeContent_)

		_bSeResult_ = 1 ### Fixed: was nResult=1 but inner branch set bResult=0 (different var)

		for _iSe_ = 1 to _nSeLen_
			if len(_aSeContent_[_iSe_]) != n
				_bSeResult_ = 0
				exit
			ok
		next

		return _bSeResult_

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
		return This.AllListsAreEqualCS(1)

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

		_aCiContent_ = This.Content()
		if len(_aCiContent_) = 0 return [] ok
		if len(_aCiContent_) = 1 return _aCiContent_[1] ok

		# Engine-backed pairwise intersection (O(n log n) per pair)
		_nCiCsFlag_ = CaseSensitive(pCaseSensitive)

		_aCiCommon_ = _aCiContent_[1]
		_nCiLen_ = len(_aCiContent_)

		for _iCi_ = 2 to _nCiLen_
			_pCiListA_ = StzEngineMarshalList(_aCiCommon_)
			_pCiListB_ = StzEngineMarshalList(_aCiContent_[_iCi_])
			_pCiResult_ = StzEngineListIntersectionCS(_pCiListA_, _pCiListB_, _nCiCsFlag_)
			_aCiCommon_ = StzEngineContentFromList(_pCiResult_)
			StzEngineListFree(_pCiResult_)
			StzEngineListFree(_pCiListB_)
			StzEngineListFree(_pCiListA_)

			if len(_aCiCommon_) = 0
				return []
			ok
		next

		return _aCiCommon_


		def IntersectionCS(pCaseSensitive)
			return This.CommonItemsCS(pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def CommonItems()
		return This.CommonItemsCS(1)

		def Intersection()
			return This.CommonItems()

	  #================================================#
	 #  GETTING THE NTH COLOUMN IN THE LIST OF LISTS  #
	#================================================#

	def Cols()
		_nClLen_ = This.NumberOfCols()
		_aClResult_ = []

		for _iCl_ = 1 to _nClLen_
			@AddItem(_aClResult_, This.Col(_iCl_))
		next

		return _aClResult_

		def Columns()
			return This.Cols()

	def NumberOfColumns()
		_nNocResult_ = This.MaxSize()
		return _nNocResult_

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

		_nNcxLen_ = len(@aContent)

		if EarlyCheck()
			if _nNcxLen_ = 0
				return []
			ok

			if n < 1 or n > This.NumberOfCols()
				return []
			ok
		ok

		# Doing the job

		_aNcxResult_ = []

		for _iNcx_ = 1 to _nNcxLen_
			_nNcxInner_ = len(@aContent[_iNcx_])
			if _nNcxInner_ >= n
				@AddItem(_aNcxResult_, @aContent[_iNcx_][n])
			else
				@AddItem(_aNcxResult_, "")
			ok
		next

		return _aNcxResult_

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

		_nNcLen_ = len(@aContent)

		if EarlyCheck()
			if _nNcLen_ = 0
				return []
			ok

			if n < 1 or n > This.NumberOfCols()
				return []
			ok
		ok

		# Doing the job

		_aNcResult_ = []

		for _iNc_ = 1 to _nNcLen_
			_nNcInner_ = len(@aContent[_iNc_])
			if n <= _nNcInner_
				@AddItem(_aNcResult_, @aContent[_iNc_][n])
			ok
		next

		return _aNcResult_

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

		_nAcLenList_ = len(paList)
		if _nAcLenList_ = 0
			return
		ok

		_aAcContent_ = This.Content()
		_nAcLenContent_ = len(_aAcContent_)

		if _nAcLenList_ > 1 and _nAcLenContent_ = 1 and len(_aAcContent_[1]) = 0

			for _iAc1_ = 1 to _nAcLenList_ - 1 ### Fixed: was `nLen - 1` -- undefined nLen
				@AddItem(_aAcContent_, [])
			next
		ok

		_nAcMin_ = @Min([ _nAcLenContent_, _nAcLenList_ ])

		for _iAc2_ = 1 to _nAcMin_
			_aAcContent_[_iAc2_] + paList[_iAc2_]
		next

		This.UpdateWith(_aAcContent_)

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

		_aAcxContent_ = This.Content()
		_nAcxLen_ = len(_aAcxContent_)

		for _iAcx_ = 1 to _nAcxLen_
			_aAcxContent_[_iAcx_] + paList[_iAcx_]
		next

		This.UpdateWith(_aAcxContent_)

	  #==================================#
	 #  SORTING NTH LIST IN  ASCENDING  #
	#==================================#

	def SortNthList(n)
		_aSnContent_ = This.Content()
		_aSnSorted_ = @SortList(_aSnContent_[n])
		_aSnContent_[n] = _aSnSorted_

		This.UpdateWith(_aSnContent_)


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
		_aNlsResult_ = This.Copy().SortNthListQ(n).Content() ### Fixed: was bad method name + missing arg + no return
		return _aNlsResult_

		def NthListSortedUp(n)
			return This.NthListSorted(n)

		def NthListSortedInAscending(n)
			return This.NthListSorted(n)

	  #----------------------------------#
	 #  SORTING NTH LIST IN DESCENDING  #
	#----------------------------------#

	def SortDownNthList(n)
		_aSdnContent_ = This.Content()
		_aSdnSorted_ = new stzList(@SortList(_aSdnContent_[n])).Reversed()
		_aSdnContent_[n] = _aSdnSorted_

		This.UpdateWith(_aSdnContent_)


		def SortDownNthListQ(n)
			This.SortDownNthList(n)
			return This

		def SortNthListInDescending(n)
			This.SortDownNthList(n)

			def SortNthListInDescendingQ(n)
				return This.SortNthListQ(n)

	def NthListSortedDown(n)
		_aNlsdResult_ = This.Copy().SortDownNthListQ(n).Content()
		return _aNlsdResult_

		def NthListSortedInDescending(n)
			return This.NthListSortedDown(n)

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
		_bIsaoResult_ = This.ColQ(n).IsSortedInAscending()
		return _bIsaoResult_

		def IsSortedUpOn(n)
			return This.IsSortedInAscendingOn(n)

		def IsSortedOn(n)
			return This.IsSortedInAscendingOn(n)

	  #---------------------------------------------------------------------------#
	 #  CHECKING IF THE LIST OF LISTS IS SORTED IN DESCENDING ON THE NTH COLUMN  #
	#---------------------------------------------------------------------------#

	def IsSortedInDescending()
		return This.IsSortedInDescendingOn(1)

		def IsSortedDown()
			return This.IsSortedInDescending()

	def IsSortedInDescendingOn(n)
		_bIsdoResult_ = This.ColQ(n).IsSortedInDescending()
		return _bIsdoResult_

		def IsSortedDownOn(n)
			return This.IsSortedInDescendingOn(n) ### Fixed: was IsSortedInDescendingDown (nonexistent)

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
		_aSdResult_ = This.Copy().SortQ().Content()
		return _aSdResult_

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
		_aSdwResult_ = This.Copy().SortDownQ().Content()
		return _aSdwResult_

		def SortedInDescending()
			return This.SortedDown()

	  #-----------------------------------------------#
	 #  SORTING THE LIST OF LISTS ON A GIVEN COLUMN  #
	#===============================================#

	def SortOn(n)

		_aSoResult_ = @SortListsOn(This.Content(), n)

		This.UpdateWith(_aSoResult_)

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

		def SortInAscendingOn(n)
			This.SortOn(n)

			def SortInAscendingOnQ(n)
				return This.SortOnQ(n)

		#>

	def SortedOn(n)
		_aSdoResult_ = This.Copy().SortOnQ(n).Content()

		return _aSdoResult_

		def SortedUpOn(n)
			return This.SortedOn(n)

		def SortedInAscendingOn(n)
			return This.SortedOn(n)

	  #-------------------------------------------------------------#
	 #  SORTING THE LIST OF LISTS IN DESCENDING ON A GIVEN COLUMN  #
	#-------------------------------------------------------------#

	def SortDownOn(n)
		_aSdoResult_ = new stzList(This.SortedOn(n)).Reversed()
		This.UpdateWith(_aSdoResult_)

		#< @FunctionFluentForm

		def SortDownOnQ(n)
			This.SortDownOn(n)
			return This

		#>

		#< @FunctionAlternativeForms

		def SortInDescendingOn(n)
			This.SortDownOn(n) ### Fixed: was This.SortDown(n) -- missing On

			def SortInDescendingOnQ(n)
				return This.SortDownOnQ(n)

		#>

	def SortedDownOn(n)
		_aSddoResult_ = This.Copy().SortDownOnQ(n).Content()

		return _aSddoResult_

		def SortedInDescendingOn(n)
			return This.SortedDownOn(n)

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

		def SortInAscendingBy(pcExpr)
			This.SortBy(pcExpr)

			def SortInAscendingByQ(pcExpr)
				return This.SortByQ(pcExpr)

		def SortUpBy(pcExpr)
			This.SortBy(pcExpr)

			def SortUpByQ(pcExpr)
				return This.SortByQ(pcExpr)

		#>

	def SortedBy(pcExpr)
		_aSbResult_ = This.Copy().SortByQ(pcExpr).Content()
		return _aSbResult_

		def SortedInAscendingBy(pcExpr)
			return This.SortedBy(pcExpr)

		def SortedUpBy(pcExpr)
			return This.SortedBy(pcExpr)

	  #------------------------------------------------------#
	 #  SORTING THE LISTS BY AN EXPRESSION - IN DESCENDING  #
	#------------------------------------------------------#
 
	def SortInDescendingBy(pcExpr)
		This.SortInAscendingBy(pcExpr)
		This.Reverse()

		def SortInDescendingByQ(pcExpr)
			This.SortInDescendingBy(pcExpr)
			return This

		def SortDownBy(pcExpr)
			This.SortInDescendingBy(pcExpr)

			def SortDownByQ(pcExpr)
				return This.SortInDescendingByQ(pcExpr)

	def SortedInDescendingBy(pcExpr)
		_aSidbResult_ = This.Copy().SortInDescendingByQ(pcExpr).Content()
		return _aSidbResult_

		def SortedDownBy(pcExpr)
			return This.SortedInDescendingBy(pcExpr)

	  #--------------------------------------------------------------------------------------#
	 #  SORTING THE LISTS BY AN EXPRESSION EVALUATED AGAINST A GIVEN COLUMN - IN ASCENDING  #
	#======================================================================================#

	def SortOnByXT(nCol, pcExpr) #TODO
	#--> returns a hashlist with the evaluated expression
		StzRaise("Non implemented yet!")

	def SortOnBy(nCol, pcExpr)

		_aSobContent_ = This.Content()
		_nSobLen_ = len(_aSobContent_)

		_aSobCol_ = This.Col(nCol)
		_nSobLenCol_ = len(_aSobCol_)

		_cSobCode_ = 'value = (' + _StzStripBraces(pcExpr) + ')'

		for @i = 1 to _nSobLenCol_
			@item = _aSobCol_[@i]
			eval(_cSobCode_)
			ring_insert(_aSobContent_[@i], 1, value)
		next

		This.UpdateWith( @SortLists(_aSobContent_) )
		This.RemoveCol(1)

		#< @FunctionFluentForm

		def SortOnByQ(nCol, pcExpr)
			This.SortOnBy(nCol, pcExpr) ### Fixed: was bare `ncol` lowercase (works in Ring case-insensitive but unsafe)
			return This

		#>

		#< @FunctionAlternativeForms

		def SortInAscendingOnBy(nCol, pcExpr)
			This.SortOnBy(nCol, pcExpr)

			def SortInAscendingOnByQ(nCol, pcExpr)
				return This.SortOnByQ(nCol, pcExpr)

		def SortUpOnBy(nCol, pcExpr)
			This.SortOnBy(nCol, pcExpr)

			def SortOnByUQ(nCol, pcExpr)
				return This.SortOnByQ(nCol, pcExpr)

		#>

	def SortedOnBy(nCol, pcExpr)
		_aSobdResult_ = This.Copy().SortOnByQ(nCol, pcExpr).Content()
		return _aSobdResult_

		def SortedInAscendingOnBy(nCol, pcExpr)
			return This.SortedOnBy(nCol, pcExpr)

		def SortedUpOnBy(nCol, pcExpr)
			return This.SortedOnBy(nCol, pcExpr) ### Fixed: was SortedByOn (nonexistent)

	  #---------------------------------------------------------------------------------------#
	 #  SORTING THE LISTS BY AN EXPRESSION EVALUATED AGAINST A GIVEN COLUMN - IN DESCENDING  #
	#---------------------------------------------------------------------------------------#

	def SortInDescendingOnBy(nCol, pcExpr)
		This.SortInAscendingOnBy(nCol, pcExpr)
		This.Reverse()

		def SortInDescendingOnByQ(nCol, pcExpr)
			This.SortInDescendingOnBy(nCol, pcExpr)
			return This

		def SortDownOnBy(nCol, pcExpr)
			This.SortInDescendingOnBy(nCol, pcExpr)

			def SortDownOnByQ(nCol, pcExpr)
				return This.SortInDescendingOnByQ(nCol, pcExpr)

	def SortedInDescendingOnBy(nCol, pcExpr)
		_aSidobResult_ = This.Copy().SortInDescendingOnByQ(nCol, pcExpr).Content()
		return _aSidobResult_

		def SortedDownOnBy(nCol, pcExpr)
			return This.SortedInDescendingOnBy(nCol, pcExpr)

	  #===========================================#
	 #  REMOVING DUPLICATES INSIDE THE NTH LIST  #
	#===========================================#

	def RemoveDuplicatesInNthList(n)
		_aRdnContent_ = This.Content()
		_aRdnContent_[n] = @WithoutDuplicates(_aRdnContent_[n])
		This.UpdateWith(_aRdnContent_)


		def RemoveDuplicatesInNthListQ(n)
			This.RemoveDuplicatesInNthList(n)
			return This ### Fixed: was bare `return` -- fluent form returned NULL

	def DuplicatesInNthListRemoved(n)
		_aDnrResult_ = This.Copy().RemoveDuplicatesInNthListQ(n).Content()
		return _aDnrResult_

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
		_aRdlContent_ = This.Content()
		_nRdlLen_ = len(_aRdlContent_)

		for _iRdl_ = 1 to _nRdlLen_
			_aRdlContent_[_iRdl_] = @WithoutDuplicates(@aContent[_iRdl_])
		next

		This.UpdateWith(_aRdlContent_)


		def RemoveDuplicatesInListsQ()
			This.RemoveDuplicatesInLists()
			return This

	def DuplicatesInListsRemoved()
		_aDlrResult_ = This.Copy().RemoveDuplicatesInListsQ().Content() ### Fixed: was missing .Copy() so it mutated self
		return _aDlrResult_

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
		_acClContent_ = This.FirstColQ().StringifyNamedObjectsQ().Lowercased()

		_nClLen_ = len(_acClContent_)
		_anClPosU_ = []
		_acClSeen_ = []

		_aClResult_ = []

		for _iCl_ = 1 to _nClLen_

			if isString(_acClContent_[_iCl_])

				if _acClContent_[_iCl_] = :@NullObject or
				   _acClContent_[_iCl_] = :@TrueObject or
				   _acClContent_[_iCl_] = :@FalseObject

					@AddItem(_anClPosU_, _iCl_)
					loop
				ok

				_nClInner_ = len(@aContent[_iCl_])

				if StzFind(_acClSeen_, _acClContent_[_iCl_]) = 0
					@AddItem(_aClResult_, [ _acClContent_[_iCl_], [] ])

					for _jCl_ = 2 to _nClInner_
						_aClResult_[ _acClContent_[_iCl_] ] + @aContent[_iCl_][_jCl_]
					next

					@AddItem(_acClSeen_, _acClContent_[_iCl_])

				else

					for _jCl2_ = 2 to _nClInner_
						_aClResult_[ _acClContent_[_iCl_] ] + @aContent[_iCl_][_jCl2_]
					next

				ok
			else
				@AddItem(_anClPosU_, _iCl_)
			ok
		next

		_nClLenU_ = len(_anClPosU_)
		if _nClLenU_ > 0
			@AddItem(_aClResult_, [ :@Undefined, [] ])

			for _kCl_ = 1 to _nClLenU_
				_nClPos_ = _anClPosU_[_kCl_]
				_nClInnerU_ = len(@aContent[_nClPos_])

				for _wCl_ = 2 to _nClInnerU_
					_aClResult_[ :@Undefined ] + @aContent[_nClPos_][_wCl_]
				next
			next
		ok

		return _aClResult_

		#< @FunctionFluentForms

		def ClassifyQ()
			return This.ClassifyQRT(:stzList)

		def ClassifyQRT(pcReturnType)
			if isList(pcReturnType) and IsOneOfTheseNamedParamsList(pcReturnType,[ :ReturnedAs, :ReturnAs ])
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
		_oCloCopy_ = This.Copy().MoveColQ(pnColNumber, 1)
		_aCloResult_ = _oCloCopy_.Classify()
		return _aCloResult_

		#< @FunctionFluentForms

		def ClassifyOnQ(pnColNumber)
			return This.ClassifyOnQRT(pnColNumber, :stzList)

		def ClassifyOnQRT(pnColNumber, pcReturnType)
			if isList(pcReturnType) and IsOneOfTheseNamedParamsList(pcReturnType,[ :ReturnedAs, :ReturnAs ])
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
			return This.ClassifyByQRT(pcExpr, :stzList)

		def ClassifyByQRT(pcExpr, pcReturnType)
			if isList(pcReturnType) and IsOneOfTheseNamedParamsList(pcReturnType,[ :ReturnedAs, :ReturnAs ])
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

			if NOT StringContainsCS(pcExpr, "@item", 0)
				StzRaise("Syntax error! pcExpr must contain the keword @item.")
			ok
		ok

		_cCobCode_ = 'value = (' + _StzStripBraces(pcExpr) + ')'

		_aCobContent_ = This.Content()

		_aCobCol_ = This.Col(nCol)
		_nCobLenCol_ = len(_aCobCol_)

		for @i = 1 to _nCobLenCol_
			@item = _aCobCol_[@i]
			eval(_cCobCode_)
			ring_insert(_aCobContent_[@i], nCol, value)
		next

		_aCobResult_ = StzListOfListsQ(_aCobContent_).
				RemoveColQ(nCol+1).
				ClassifyOn(nCol)

		return _aCobResult_

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

		_nMcCols_ = This.NumberOfCols()

		if n1 < 1 or n1 > _nMcCols_
			return
		ok

		if n2 < 1 or n2 > _nMcCols_
			return
		ok

		# Doing the job

		_aMcContent_ = This.Content()
		_nMcLen_ = len(_aMcContent_)

		for _iMc_ = 1 to _nMcLen_
			_nMcInner_ = len(_aMcContent_[_iMc_])
			if n1 <= _nMcInner_ and n2 <= _nMcInner_
				@Move(_aMcContent_[_iMc_], n1, n2)
			ok
		next

		This.UpdateWith(_aMcContent_)


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
		_aCmResult_ = This.Copy().MoveColQ(n1, n2).Content()
		return _aCmResult_

		def ColumnMoved(n1, n2)
			return This.ColMoved(n1, n2)

		def NthItemsMoved(n1, n2)
			return This.ColMoved(n1, n2)

	  #=============================================#
	 #  SWAPPING TWO COLUMNS IN THE LIST OF LISTS  #
	#=============================================#

	def SwapCols(n1, n2)
		if CheckingParams()

			if isList(n1) and IsOneOfTheseNamedParamsList(n1, [
				:From, :FromPosition,
				:Between, :BetweenPosition, :BetweenPositions ])

				n1 = n1[2]
			ok

			if isList(n2) and IsOneOfTheseNamedParamsList(n2, [
				:To, :ToPosition, :And, :AndPosition ])

				n2 = n2[2] ### Fixed: was `n1 = n2[2]` -- assigned to wrong var, dropped n2 named-param unwrap
			ok

			if NOT (isNumber(n1) and isNumber(n2))
				StzRaise("Incorrect param type! n1 and n2 must be both numbers.")
			ok
		ok

		# Early checks

		if n1 = n2
			return
		ok

		_nScCols_ = This.NumberOfCols()

		if n1 < 1 or n1 > _nScCols_
			return
		ok

		if n2 < 1 or n2 > _nScCols_
			return
		ok

		# Doing the job

		_aScContent_ = This.Content()
		_nScLen_ = len(_aScContent_)

		for _iSc_ = 1 to _nScLen_
			_nScInner_ = len(_aScContent_[_iSc_])
			if n1 <= _nScInner_ and n2 <= _nScInner_
				# Inline swap -- ring_swap calls swap() which is shadowed
				# by user-defined func Swap(p1, p2) in stzFuncs.ring
				_scTmp_ = _aScContent_[_iSc_][n1]
				_aScContent_[_iSc_][n1] = _aScContent_[_iSc_][n2]
				_aScContent_[_iSc_][n2] = _scTmp_
			ok
		next

		This.UpdateWith(_aScContent_)


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
		_aCsResult_ = This.Copy().SwapColsQ(n1, n2).Content() ### Fixed: was calling non-fluent SwapCols (returns NULL)
		return _aCsResult_

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

		_nIcCols_ = This.NumberOfCols()

		if n < 1 or n > _nIcCols_
			return
		ok

		# Doing the job

		_aIcContent_ = This.Content()
		_nIcLen_ = len(_aIcContent_)
		_nIcLenCol_ = len(paColData)

		for _iIc_ = 1 to _nIcLen_
			_nIcInner_ = len(_aIcContent_[_iIc_])

			_icItem_ = ""
			if _iIc_ <= _nIcLenCol_
				_icItem_ = paColData[_iIc_]
			ok

			if n <= _nIcInner_
				ring_insert(_aIcContent_[_iIc_], n, _icItem_)
			ok

		next

		This.UpdateWith(_aIcContent_)


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

		_aRcContent_ = This.Content()
		_nRcLen_ = len(_aRcContent_)

		if n < 1 or n > _nRcLen_
			return
		ok

		# Doing the job

		for _iRc_ = 1 to _nRcLen_
			_nRcInner_ = len(_aRcContent_[_iRc_])
			if n <= _nRcInner_
				ring_remove(_aRcContent_[_iRc_], n)
			ok
		next

		This.UpdateWith(_aRcContent_)


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
		_aCrResult_ = This.Copy().RemoveColQ(n).Content()
		return _aCrResult_

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

		_aRcsContent_ = This.Content()
		_nRcsLen_ = len(_aRcsContent_)

		_oChain_ = new stzList(anColNumbers)

		anColNumbers = _oChain_.Sorted()
		_nRcsLenCols_ = len(anColNumbers)

		for _iRcs_ = _nRcsLenCols_ to 1 step -1
			_nRcsN_ = anColNumbers[_iRcs_]
			for _jRcs_ = 1 to _nRcsLen_
				_nRcsInner_ = len(_aRcsContent_[_jRcs_])
				if _nRcsN_ <= _nRcsInner_
					ring_remove(_aRcsContent_[_jRcs_], _nRcsN_)
				ok
			next
		next

		This.UpdateWith(_aRcsContent_)


		#< @FunctionFluentForm

		def RemoveColsQ(anColNumbers)
			This.RemoveCols(anColNumbers)
			return This

		#>

		#< @FunctionAlternativeForms

		def RemoveTheseCols(anColNumbers)
			This.RemoveCols(anColNumbers)

			def RemoveTheseColqQ(anColNumbers)
				return This.RemoveColsQ(anColNumbers) ### Fixed: was passing bare `n` (undefined)

		def RemoveManyCols(anColNumbers)
			This.RemoveCols(anColNumbers)

			def RemoveManyColqQ(anColNumbers)
				return This.RemoveColsQ(anColNumbers) ### Fixed: was bare `n` (undefined)

		def RemoveColumns(anColNumbers)
			This.RemoveCols(anColNumbers)

			def RemoveColumnsQ(anColNumbers)
				This.RemoveColumns(anColNumbers)
				return This

		def RemoveTheseColumns(anColNumbers)
			This.RemoveTheseCols(anColNumbers)

			def RemoveTheseColumnsQ(anColNumbers)
				return This.RemoveColsQ(anColNumbers) ### Fixed: was RemoveCoslQ (typo)

		def RemoveManyColumns(anColNumbers)
			This.RemoveTheseCols(anColNumbers)

			def RemoveManyColumnsQ(anColNumbers)
				return This.RemoveColsQ(anColNumbers) ### Fixed: was RemoveCoslQ (typo)
	
		#>

	def ColsRemoved(anColNumbers)
		_aCrdResult_ = This.Copy().RemoveColsQ(anColNumbers).Content()
		return _aCrdResult_

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

		_nRpcCols_ = This.NumberOfCols()

		if n < 1 or n > _nRpcCols_
			return
		ok

		# Doing the job

		_aRpcContent_ = This.Content()
		_nRpcLen_ = len(_aRpcContent_)
		_nRpcLenCol_ = len(paColData)

		for _iRpc_ = 1 to _nRpcLen_
			_nRpcInner_ = len(_aRpcContent_[_iRpc_])

			_rpcItem_ = ""
			if _iRpc_ <= _nRpcLenCol_
				_rpcItem_ = paColData[_iRpc_]
			ok

			if n <= _nRpcInner_
				_aRpcContent_[_iRpc_][n] = _rpcItem_
			ok

		next

		This.UpdateWith(_aRpcContent_)


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

		_nRpsLen_ = len(panColNumbers)

		for _iRps_ = 1 to _nRpsLen_
			this.ReplaceCol(panColNumbers[_iRps_], paColData)
		next

	  #==================================================#
	 #  TRANSFORMING THE LIST OF LISTS TO OTHER FORMS   #
	#==================================================#
		
	def stzType()
		return :stzListOfLists

	def ToListOfStzLists()

		_aoTlsResult_ = []
		_nTlsLen_ = len(@aContent)

		for _iTls_ = 1 to _nTlsLen_
			@AddItem(_aoTlsResult_, new stzList(@aContent[_iTls_]))
		next

		return _aoTlsResult_

	def ToListsInString()
		_acTlisResult_ = []
		_aTlisLists_ = This.ListOfLists()
		_nTlisLen_ = len(_aTlisLists_)

		for _iTlis_ = 1 to _nTlisLen_
			@AddItem(_acTlisResult_, @@(_aTlisLists_[_iTlis_]))
		next

		return _acTlisResult_

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
		_cTlissList_ = @@(This.Content())
		_oTlissStr_ = new stzString(_cTlissList_)
		_cTlissResult_ = _oTlissStr_.ToListInShortForm()
		return _cTlissResult_

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
		_aTosResult_ = []
		_aTosLists_ = This.ListOfLists()
		_nTosLen_ = len(_aTosLists_)

		for _iTos_ = 1 to _nTosLen_
			@AddItem(_aTosResult_, @@( _aTosLists_[_iTos_] )) # @@ --> ComputableForm( list )
		next

		return _aTosResult_


	def IsListOfPairs()
		_aIlpContent_ = This.Content()
		_nIlpLen_ = len(_aIlpContent_)

		_bIlpResult_ = 1

		for _iIlp_ = 1 to _nIlpLen_
			if NOT (isList(_aIlpContent_[_iIlp_]) and len(_aIlpContent_[_iIlp_]) = 2)
				_bIlpResult_ = 0
				exit
			ok
		next

		return _bIlpResult_

	def ToStzListOfpairs()
		if This.IsListOfPairs()
			return new stzListOfPairs(This.Content())
		else
			StzRaise("Can't transform the list of lists into a list of pairs! Lists are not all pairs.")
		ok

	def ToStzListOfpairsOfNumbers()
		if This.IsListOfPairsOfNumbers()
			return new stzListOfPairsOfNumbers(This.Content())
		else
			StzRaise("Can't transform the list of lists into a list of pairs of numbers! Lists are not all pairs of numbers.")
		ok

	  #--------------------------------------#
	 #  GETTING THE SPEEDUP OF THE NUMBERS  #
	#======================================#

	def SpeedUp()
		_anSuNumbers_ = This.Content()

		_nSuN1_ = _anSuNumbers_[1]
		_nSuN2_ = _anSuNumbers_[2]

		_nSuResult_ = _nSuN1_ / _nSuN2_

		return _nSuResult_

		def SpeedUpX()
			return This.SpeedUp()

	  #-------------------------------------------------#
	 #  GETTING THE GAIN FACTOR FROM NUMBER TO NUMBER  #
	#-------------------------------------------------#

	def GainFactor()
		_anGfNumbers_ = This.Content()

		_nGfN1_ = _anGfNumbers_[1]
		_nGfN2_ = _anGfNumbers_[2]

		_nGfResult_ = _nGfN2_ / _nGfN1_

		return _nGfResult_
	
		def GainX()
			return This.GainFactor()
	
	  #========================================#
	 #  CHECKING IF THE LISTS ARE CONTIGUOUS  #
	#========================================#

	func AreContiguous()

		_bAcResult_ = 1
		_nAcLen_ = len(@aContent)

		for _iAc_ = 1 to _nAcLen_

			_aAcList_ = @aContent[_iAc_]
			_nAcInner_ = len(_aAcList_)

			if _nAcInner_ > 2

				if @IsListOfNumbers(_aAcList_)
					for _jAcN_ = 2 to _nAcInner_
						if NOT _aAcList_[_jAcN_] = _aAcList_[_jAcN_-1] + 1
							_bAcResult_ = 0
							exit
						ok
					next

				but @IsListOfChars(_aAcList_)
					for _jAcC_ = 2 to _nAcInner_
						if NOT ascii(_aAcList_[_jAcC_]) = ascii(_aAcList_[_jAcC_-1]) + 1
							_bAcResult_ = 0
							exit
						ok
					next
				ok
			ok

			if _bAcResult_ = 0
				exit
			ok

		next

		return _bAcResult_

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

		_aFslAdj_ = This.Adjusted()
		_nFslLen_ = len(_aFslAdj_)

		_aFslResult_ = []

		for _iFsl_ = 1 to _nFslLen_

			_anFslPos_ = StzListQ(_aFslAdj_[_iFsl_]).FindSubListCS(paItems, pCaseSensitive)

			if len(_anFslPos_) > 0
				@AddItem(_aFslResult_, [ _iFsl_, _anFslPos_ ])
			ok

		next

		return _aFslResult_

		def FindContiguousItemsCS(paItems, pCaseSensitive)
			return This.FindSubListCS(paItems, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindSubList(paItems)
		return This.FindSubListCS(paItems, 1)

		def FindContiguousItems(paItems)
			return This.FindSubList(paItems)

	  #====================#
	 #  SORINT THE LISTS  #
	#====================#

	def SortLists()
		_aSltContent_ = This.Content()
		_nSltLen_ = len(_aSltContent_)

		_aSltResult_ = []

		for _iSlt_ = 1 to _nSltLen_
			@AddItem(_aSltResult_, @Sort(_aSltContent_[_iSlt_]))
		next

		This.UpdateWith(_aSltResult_)

		def SortListQ()
			This.SortLists()
			return This

	def ListsSorted()
		_aLsResult_ = This.Copy().SortListQ().Content()
		return _aLsResult_
