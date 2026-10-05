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
			if BothAreEqualCS(paList[_iIe], pItem, 1)
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

	_nLen_ = len(paListOfLists)

	if _nLen_ < 2
		return paListOfLists
	ok

	_aResult_ = paListOfLists[1]

	for i = 2 to _nLen_
		_nLenList_ = len(paListOfLists[i])
		for j = 1 to _nLenList_
			_aResult_ + paListOfLists[i][j]
		next j
	next

	return _aResult_

	func ListsMergeQ(paListOfLists)
		return new stzList( ListsMerge(paListOfLists) )

	func Merge(paListOfLists)
		return ListsMerge(paListOfLists)

	func @Merge(paListOfLists)
		return ListsMerge(paListOfLists)

func Association(paLists)

	if CheckingParams()
	
		if NOT ( isList(paLists) and @IsListOfLists(paLists) )
			StzRaise("Incorrect param type! paLists must be a list of lists.")
		ok

	ok

	if len(paLists) < 2
		StzRaise("Can't proceed! paLists must contain at least two lists.")
	ok

	_nLen_ = len(paLists)

	# Counting the sizes of each list

	_anLen_ = []
	for i = 1 to _nLen_
		_anLen_ + len(paLists[i])
	next

	# Unifiying the sizes of all the lists

	_nMax_ = Max(_anLen_)

	for i = 1 to _nLen_

		if _anLen_[i] < _nMax_
			for j = _anLen_[i] + 1 to _nMax_
				paLists[i] + ""
			next
		ok
	next

	# Doing the association

	_aResult_ = []

	for i = 1 to _nMax_
		_aList_ = []
		for j = 1 to _nLen_

			_aList_ + paLists[j][i]
		next
		_aResult_ + _aList_
	next

	return _aResult_

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
	_aResult_ = StzListOfListsQ(paLists).CommonItemsCS(pCaseSensitive)
	return _aResult_

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

# Is another name for stzListOfLists, so every method and every form is the same.
#
# Use whichever name reads better at the call site; the class adds nothing of its own.
#
#   receiver   o1 = new stzLists([ [ 1, 2, 3 ], [ 4, 5 ], [ 6 ] ])
#   example    ? @@( o1.Cols() )
#              #--> [ [ 1, 4, 6 ], [ 2, 5 ], [ 3 ] ]
#   see        stzListOfLists
class stzLists from stzListOfLists

# Holds a non-empty list of lists and answers questions about its rows and columns, sizes, padding, sorting and column edits.
#
# A stzListOfLists wraps a Ring list whose every item is a list, the lists being allowed to differ
# in size. Reach for it to treat the lists as rows of a table without the weight of stzTable: take a
# column (NthColumn), pad the short rows (Extend, AdjustWith), cut them (Shrink, ShrinkTo), sort the
# rows on a column (SortOn), find an item inside the rows (FindManyInLists) or edit a column
# (InsertCol, ReplaceCol). Active forms change the lists in place, passive forms (the ones ending in
# ed) return a changed copy as a plain list of lists. Item searches are case-sensitive. A number of
# methods carry a warning today: several families (the Entry methods, RemoveCols, Classify, the
# repeating forms of Extend) raise an error because the code behind them calls something that does
# not exist.
#
#   receiver   o1 = new stzListOfLists([ [ 1, 2, 3 ], [ 4, 5 ], [ 6 ] ])
#   example    ? @@( o1.Cols() )
#              #--> [ [ 1, 4, 6 ], [ 2, 5 ], [ 3 ] ]
#   see        stzList, stzTable, stzList2D
class stzListOfLists from stzList

	@aContent = []

	# Builds the object from a non-empty list whose every item is itself a list; anything else raises an error.
	#
	#   returns    nothing; the object is built
	#   note       an empty list, or a list holding a non-list, is refused
	#@ aka  Build the list-of-lists from the given Ring list.
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

	# Returns the lists as a plain Ring list of lists.
	#
	#   returns    a list of lists
	#   see        Value, ListOfLists
	#@ aka  The raw list of lists.
	def Content()
		return @aContent

		# Returns the held lists as a plain Ring list of lists, the same answer as the content.
		#
		#   returns    a list of lists
		#   see        Content
		#@ aka  The raw list of lists (same as Content).
		def Value()
			return Content()

	# Returns a new stzListOfLists holding the same lists; changing it leaves the original alone.
	#
	#   returns    a stzListOfLists
	#   see        ToStzList
	#@ aka  A new stzListOfLists with the same sublists.
	def Copy()
		return new stzListOflists(This.Content())

	# Same as Content: the raw list of lists.
	def ListOfLists()
		return This.Content()

	# Returns how many lists the object holds.
	#
	#   returns    a number
	#   see        Sizes
	#@ aka  How many sublists the list holds.
	def NumberOfLists()
		return len(@aContent)

	  #-------------------------------#
	 #   UPDATING THE LIST OF LISTS  #
	#-------------------------------#

	# Replaces all the lists by a new list of lists, in place.
	#
	#   paList     the new list of lists, or :With = list
	#   returns    nothing; the content changes
	#   note       raises an error when the argument is not a list of lists
	#   see        Updated
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

		# Replaces all the lists by a new list of lists, in place.
		#
		#   paList     the new list of lists, or :With = list
		#   returns    nothing; the content changes
		#   note       raises an error when the argument is not a list of lists
		#   see        Update
		#< @FunctionAlternativeForms
		def UpdateWith(paList)
			This.Update(paList)
	
		# Replaces all the lists by a new list of lists, in place.
		#
		#   paList     the new list of lists, or :By = list
		#   returns    nothing; the content changes
		#   note       raises an error when the argument is not a list of lists
		#   see        Update
		def UpdateBy(paList)
			This.Update(paList)

		# Replaces all the lists by a new list of lists, in place.
		#
		#   paList     the new list of lists, or :Using = list
		#   returns    nothing; the content changes
		#   note       raises an error when the argument is not a list of lists
		#   see        Update
		def UpdateUsing(paList)
			This.Update(paList)

	# Returns the given list as it is, without checking it; the object is unchanged.
	#
	#   paList     the list to hand back
	#   returns    the list that was given
	#   note       the body only returns its argument: nothing is validated and the object keeps its
	#              lists
	#   see        Update
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

	# Appends one list after the last list, in place.
	#
	#   paList     the list to append
	#   returns    nothing; the content changes
	#   note       the result must still be a list of lists, so a non-list raises an error
	#   see        AddManyLists
	#@ aka  Add the given list at the end (mutating).
	def AddList(paList)
		_aAlContent_ = This.Content()
		This.UpdateWith(_aAlContent_ + paList)

	# Add each of the given lists at the end (mutating).
	def AddMany(paListOfLists)
		if CheckingParams()
			if NOT ( isList(paListOfLists) and @IsListOfLists(paListOfLists) )
				StzRaise("Incorrect param type! paListOfLists must be a list of lists.")
			ok
		ok

		_aAmContent_ = This.Content()

		_nAmLen_ = len(paListOfLists)
		for _iAm_ = 1 to _nAmLen_
			@AddItem(_aAmContent_, paListOfLists[_iAm_])
		next

		This.UpdateWith(_aAmContent_)

		# Appends each of the given lists after the last list, in place.
		#
		#   paListOfLists   the lists to append
		#   returns         nothing; the content changes
		#   note            raises an error when the argument is not a list of lists
		#   see             AddList
		def AddManyLists(paListOfLists)
			This.AddMany(paListOfLists)

	  #---------------#
	 #   NTH LIST    #
	#---------------#

	# Returns the list at a position; :First and :Last are accepted for the ends.
	#
	#   _n_        the position, 1 for the first list
	#   returns    a list
	#   note       raises an error for position 0, a negative position or a position past the end
	#   see        FirstList, LastList
	#@ aka  The sublist at position n.
	def NthList(_n_)
		if CheckingParams()

			if isString(_n_)
				if _n_ = :First or _n_ = :FirstList
					_n_ = 1

				but _n_ = :Last or _n_ = :LastList
					_n_ = This.NumberOfLists()

				ok
			ok

			if NOT isNumber(_n_)
				StzRaise("Incorrect param type! n must be a number.")
			ok

		ok

		_aNlResult_ = This.Content()[_n_]
		return _aNlResult_

		#< @FunctionFluentForm
		
		def NthListQ(_n_)
			return new stzList( This.NthList(_n_) )

		# Raises error R19 today instead of returning the list at a position.
		#
		#   _n_        the position of the list
		#   returns    nothing today
		#   warning    known defect: it calls NthList without passing the position, so the call
		#              raises error R19; ListAtPosition works
		#   see        NthList
		#>
		#< @FunctionAlternativeForms
		def ListAt(_n_)
			return This.NthList()

			def ListAtQ(_n_)
				return This.NthListQ(_n_)

		def ListAtPosition(_n_)
			return This.NthList(_n_)

			def ListAtPositionQ(_n_)
				return This.NthListQ(_n_)

	# Returns the list that comes first among the lists, as a plain list.
	#
	#   returns    a list
	#   see        LastList, NthList
		#>
	#@ aka  The first sublist.
	def FirstList()
		return This.NthList(1)

	# Returns the list that comes last among the lists, as a plain list.
	#
	#   returns    a list
	#   see        FirstList, NthList
	#@ aka  The last sublist.
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

	# Returns [ list, position ] pairs for every occurrence of a text item inside the lists; the match is case-sensitive.
	#
	#   pItem      the text item to look for
	#   returns    a list of [ list position, position in the list ] pairs
	#   note       [ ] when the item is absent
	#   warning    known defect: a number item, or a list that holds numbers, makes the engine
	#              search raise an error
	#   see        FindManyInLists, ContainsItem
		#>
	#@ aka  -- WITHOUT CASESENSITIVITY
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

	# Returns [ list, position ] pairs for every occurrence of any of the given items inside the lists.
	#
	#   paItems    the items to look for
	#   returns    a list of [ list position, position in the list ] pairs
	#   see        FindInLists
		#>
	#@ aka  -- WITHOUT CASESENSITIVITY
	def FindManyInLists(paItems)
		return This.FindManyInListsCS(paItems, 1)
	
		# Raises error R24 today instead of returning where several items occur inside the lists.
		#
		#   paItems    the items to look for
		#   returns    nothing today
		#   warning    known defect: the body passes a variable called pItem, which is never set, so
		#              the call raises error R24
		#   see        FindManyInLists
		#< @FunctionAlternativeForms
		def FindItemsInLists(paItems)
			return This.FindManyInLists(pItem)

		#>

	  #--------------------------------------#
	 #  FINDING A SUBLIST INSIDE THE LISTS  #
	#======================================#

	# Raises an error on purpose today: the search for a sublist inside the lists is not written yet.
	#
	#   paSubList        the sublist to look for
	#   pCaseSensitive   1 to compare with case, 0 to ignore it
	#   returns          nothing today
	#   warning          known defect: the body only raises "Function non implemented yet!";
	#                    FindSubList does the job
	#   see              FindSubList
	def FindSubListInListsCS(paSubList, pCaseSensitive) #TODO
		StzRaise("Function non implemented yet!")

	# Raises error R14 today instead of returning where a sublist occurs in the lists.
	#
	#   paSubList   the sublist to look for
	#   returns     nothing today
	#   warning     known defect: it calls FindSubListInListCS, which is defined nowhere;
	#               FindSubList does the job
	#   see         FindSubList
	def FindSubListInList(paSubList)
		return This.FindSubListInListCS(paSubList, pCaseSensitive)

	  #======================#
	 #   POSITIONS WHERE    #
	#======================#

	# Raises error R24 today instead of returning the positions of the lists that meet a condition.
	#
	#   pcCondition   a condition on @list, the current list
	#   returns       nothing today
	#   warning       known defect: the body collects into a variable named _aResult_ while the
	#                 evaluated code writes to aResult, which is never set, so the call raises error
	#                 R24
	#   see           FindSmallestLists
	#@ aka  The positions of the sublists satisfying the W condition.
	def PositionsW(pcCondition)

		_cPwCondition_ = StringSimplified(_StzStripBraces(pcCondition))
		_aResult_ = []  # MUST stay bare -- referenced by user-supplied eval(cCode) below

		_aPwLists_ = This.ListOfLists()
		_nPwLen_ = len(_aPwLists_)

		for @i = 1 to _nPwLen_
			@list = _aPwLists_[@i]

			@item = @list # Allows using both @list and @item in the user's script
			_cPwCode_ = "if " + _cPwCondition_ + char(10) +
				char(9) + "aResult + @i" + char(10) +
			"ok"

			eval(_cPwCode_)
		next

		return _aResult_

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




	  #------------------#
	 #   LISTS WHERE    #
	#------------------#

	# The sublists satisfying the W condition.
	def ListsW(pcCondition)

		_cLwCondition_ = StringSimplified(_StzStripBraces(pcCondition))
		_aResult_ = []  # MUST stay bare -- referenced by user-supplied eval(cCode) below

		_aLwLists_ = This.ListOfLists()
		_nLwLen_ = len(_aLwLists_)

		for @i = 1 to _nLwLen_
			@list = _aLwLists_[@i]

			@item = @list # Allows using both @list and @item in the user's script
			_cLwCode_ = "if " + _cLwCondition_ + char(10) +
				char(9) + "aResult + @list" + char(10) +
			"ok"

			eval(_cLwCode_)
		next

		return _aResult_

		#< @FunctionFluentForm

		def ListsWQ(pcCondition)
			return new stzList( This.ListsW(pcCondition) )

		#>

		#< @FunctionAlternativeForm

		def ListsWhere(pcCondition)
			return This.ListsW(pcCondition)

			def ListsWhereQ(pcCondition)
				return new stzList(This.ListsWhere(pcCondition))


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


		#>

	  #==========================================#
	 #   GETTING THE SIZES OF THE INNER LISTS   #
	#==========================================#

	# Returns the number of items of each list, in order.
	#
	#   returns    a list of numbers
	#   see        NumberOfLists, SizeOfList
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

	# TRUE if every list holds as many items as the first one.
	#
	#   returns    TRUE or FALSE
	#   see        Sizes
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

	# Returns the positions of every list that has the fewest items.
	#
	#   returns    a list of positions
	#   see        SmallestLists, FindBiggestLists
	#@ aka  The positions of the shortest sublists.
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

	# Returns every list that has the fewest items.
	#
	#   returns    a list of lists
	#   see        FindSmallestLists, SmallestList
	#@ aka  The shortest sublists.
	def SmallestLists()
		_aSlResult_ = This.ItemsAtPositions( This.FindSmallestLists() )
		return _aSlResult_

	#--

	# The shortest sublists along with their positions.
	def SmallestListsZ()
		_aSlzResult_ = Association([ This.SmallestLists(), This.FindSmallestLists() ])
		return _aSlzResult_

	  #-------------------#
	 #   BIGGEST LISTS   #
	#-------------------#

	# Returns the positions of every list that has the most items.
	#
	#   returns    a list of positions
	#   see        BiggestLists, FindSmallestLists
	#@ aka  The positions of the longest sublists.
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

	# Returns every list that has the most items.
	#
	#   returns    a list of lists
	#   see        FindBiggestLists, LargestList
		#>
	#TODO
	#@ aka  add* "big", "great", and "large" as alternatives all over the library
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

	# Returns the positions of the lists that hold exactly n items.
	#
	#   _n_        the number of items wanted
	#   returns    a list of positions
	#   see        ListsOfSizeN
	def FindListsOfSizeN(_n_)

		_aFlsContent_ = This.Content()
		_nFlsLen_ = len(_aFlsContent_)

		_anFlsResult_ = []

		for _iFls_ = 1 to _nFlsLen_
			if len(_aFlsContent_[_iFls_]) = _n_
				@AddItem(_anFlsResult_, _iFls_)
			ok
		next

		return _anFlsResult_

		#< @FunctionAlternativeForms

		def FindListsOfSize(_n_)
			return This.FindListsOfSizeN(_n_)

		def PositionsOfListsOfSizeN(_n_)
			return This.FindListsOfSizeN(_n_)

		def PositionsOfListsOfSize(_n_)
			return This.FindListsOfSizeN(_n_)

	# Returns the lists that hold exactly n items.
	#
	#   _n_        the number of items wanted
	#   returns    a list of lists
	#   see        FindListsOfSizeN
		#>
	def ListsOfSizeN(_n_)

		_anLsnPos_ = This.FindListsOfSizeN(_n_)
		_aLsnResult_ = This.ItemsAtPositions(_anLsnPos_)
		return _aLsnResult_

		#< @FunctionAlternativeForm

		def ListsOfSize(_n_)
			return This.ListsOfSizeN(_n_)

		#>

	  #------------------------------------------------------#
	 #  FINDING THE MISSING POSITIONS IN THE LIST OF LISTS  #
	#======================================================#

	# Returns the [ list, position ] places that a shorter list lacks compared with the longest list.
	#
	#   returns    a list of [ list position, item position ] pairs
	#   see        NumberOfMissingItems, ExtraItems
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

	# Returns how many items the shorter lists lack in total compared with the longest list.
	#
	#   returns    a number
	#   see        FindMissingItems
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

	# Returns the item at position n of every list that has one.
	#
	#   _n_        the position inside each list
	#   returns    a list of items
	#   note       lists shorter than n are skipped, so the answer can be shorter than the object;
	#              position 0 raises an error
	#   see        NthColumn
	def ItemsAtPositionN(_n_)
		_aIapnResult_ = []

		_aIapnLists_ = This.ListOfLists()
		_nIapnLen_ = len(_aIapnLists_)

		for _iIapn_ = 1 to _nIapnLen_
			_aIapnList_ = _aIapnLists_[_iIapn_]
			if len(_aIapnList_) >= _n_
				@AddItem(_aIapnResult_, _aIapnList_[_n_])
			ok
		next

		return _aIapnResult_

		#< @FunctionFluentForm

		def ItemsAtPositionNQ(_n_)
			return This.ItemsAtPositionNQRT(_n_, :stzList)

		# Returns the items at position n of the lists, as an object of the requested type.
		#
		#   _n_            the position inside each list
		#   pcReturnType   the type wanted, :stzList, :stzListOfLists or :stzListOfPairs
		#   returns        a stzList, stzListOfLists or stzListOfPairs
		#   note           any other type raises "Unsupported return type!"
		#   see            ItemsAtPositionN
		def ItemsAtPositionsNQRT(_n_, pcReturnType)
			if isList(pcReturnType) and IsOneOfTheseNamedParamsList(pcReturnType,[ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			if NOT isString(pcReturnType)
				StzRaise("Incorrect param! pcReturnType must be a string.")
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.ItemsAtPositionN(_n_) )

			on :stzListOfLists
				return new stzListOfLists( This.ItemsAtPositionN(_n_) )

			on :stzListOfPairs
				return new stzListOfPairs( This.ItemsAtPositionN(_n_) )

			other
				StzRaise("Unsupported return type!")
			off

		#>

		#< @FunctionAlternativeForms

		def ItemsAt(_n_)
			return This.ItemsAtPositionN(_n_)

			def ItemsAtQ(_n_)
				return This.ItemsAtPositionNQRT(_n_, :stzList)

			def ItemsAtQRT(_n_, pcReturnType)
				return This.ItemsAtPositionNQRT(_n_, pcReturnType)

		def ItemsAtPosition(_n_)
			return This.ItemsAtPositionN(_n_)

			def ItemsAtPositionQ(_n_)
				return This.ItemsAtPositionQRT(_n_, :stzList)

			def ItemsAtPositionQRT(_n_, pcReturnType)
				return This.ItemsAtPositionQRT(_n_, pcReturnType)

		def ListsAtPositionN(_n_)
			return This.ItemsAtPositionN(_n_)

			def ListsAtPositionNQ(_n_)
				return This.ListsAtPositionNQRT(_n_, :stzList)

			def ListsAtPositionNQRT(_n_, pcReturnType)
				return This.ListsAtPositionNQRT(_n_, pcReturnType)

		def ListsAt(_n_)
			return This.ItemsAtPositionN(_n_)

			def ListsAtQ(_n_)
				return This.ListsAtQRT(_n_, :stzList)

			def ListsAtQRT(_n_, pcReturnType)
				return This.ListsAtQRT(_n_, pcReturnType)

		def ListsAtPosition(_n_)
			return This.ItemsAtPositionN(_n_)

			def ListsAtPositionQ(_n_)
				return This.ListsAtPositionQRT(_n_, :stzList)

			def ListsAtPositionQRT(_n_, pcReturnType)
				return This.ListsAtPositionQRT(_n_, pcReturnType)

		#>

	  #=================#
	 #  SMALLEST LIST  #
	#=================#

	# Returns the position of the first list that has the fewest items.
	#
	#   returns    a position
	#   see        SmallestList, FindLargestList
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

	# Returns the first list that has the fewest items.
	#
	#   returns    a list
	#   see        FindSmallestList, SmallestLists
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

	# Returns how many items the shortest list holds.
	#
	#   returns    a number
	#   see        SizeOfLargestList
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

	# Returns the position of the first list that has the most items.
	#
	#   returns    a position
	#   see        LargestList, FindSmallestList
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

	# Returns the first list that has the most items.
	#
	#   returns    a list
	#   see        FindLargestList, BiggestLists
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

	# Returns how many items the longest list holds.
	#
	#   returns    a number
	#   see        SizeOfSmallestList
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

	# Returns how many items the list at a position holds.
	#
	#   _n_        the position of the list
	#   returns    a number
	#   note       raises an error for a position that does not exist
	#   see        Sizes
	def SizeOfList(_n_)
		_nSolnResult_ = len( This.NthList(_n_) )
		return _nSolnResult_

		def Size(_n_)
			return This.SizeOfList(_n_)

		def SizeOfNthList(_n_)
			return This.SizeOfList(_n_)

		def NumberOfItemsOfList(_n_)
			return This.SizeOfList(_n_)

	  #==============================================#
	 #  EXTENDING (EACH LIST IN) THE LIST OF LISTS  #
	#==============================================#

	# Pads every shorter list with empty text up to the size of the longest list, in place.
	#
	#   returns    nothing; the content changes
	#   see        Extended, ExtendWith
	def Extend()
		This.ExtendTo( This.SizeOfLargestList() )

		#< @FuntionFluentForm

		def ExtendQ()
			This.Extend()
			return This

		# Pads every shorter list with empty text up to the size of the longest list, in place.
		#
		#   returns    nothing; the content changes
		#   see        Extend
		#>
		#< @FunctionAlternativeForm
		def ExtendEachList()
			This.Extend()

			def ExtendEachListQ()
				return This.ExtendQ()

		# Pads every shorter list with empty text up to the size of the longest list, in place.
		#
		#   returns    nothing; the content changes
		#   see        Extend
		def Expand()
			This.Extend()

			def ExpandQ()
				return This.ExtendQ()

		# Pads every shorter list with empty text up to the size of the longest list, in place.
		#
		#   returns    nothing; the content changes
		#   see        Extend
		def ExpandEachList()
			This.Extend()

			def ExpandEachListQ()
				return This.ExtendQ()

		# Pads every shorter list with empty text up to the size of the longest list, in place.
		#
		#   returns    nothing; the content changes
		#   see        Extend
		def Stretch()
			This.Extend()

			def StretchQ()
				return This.ExtendQ()

		# Pads every shorter list with empty text up to the size of the longest list, in place.
		#
		#   returns    nothing; the content changes
		#   see        Extend
		def StretchEachList()
			This.Extend()

			def StretchEachListQ()
				return This.ExtendQ()

		# Pads every shorter list with empty text up to the size of the longest list, in place.
		#
		#   returns    nothing; the content changes
		#   see        Extend, AdjustTo
		#@ aka  --
		def Adjust()
			This.Extend()

			def AdjustQ()
				return This.ExtendQ()

		# Pads every shorter list with empty text up to the size of the longest list, in place.
		#
		#   returns    nothing; the content changes
		#   see        Extend
		def Justify()
			This.Extend()

			def JustifyQ()
				return This.ExtendQ()

	# Returns a copy where every shorter list is padded with empty text to the size of the longest; the object is unchanged.
	#
	#   returns    a list of lists
	#   see        Extend
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

		# Pads every shorter list with the given item up to the size of the longest list, in place.
		#
		#   pItem      the item to pad with
		#   returns    nothing; the content changes
		#   see        Extend, ExtendTo
		def ExtendWith(pItem)
			This.ExtendXT(pItem)

			def ExtendWithQ(pItem)
				return This.ExtendXTQ(pItem)

		# Pads every shorter list with the given item up to the size of the longest list, in place.
		#
		#   pItem      the item to pad with
		#   returns    nothing; the content changes
		#   see        ExtendWith
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

		# Pads every shorter list with the given item up to the size of the longest list, in place.
		#
		#   pItem      the item to pad with
		#   returns    nothing; the content changes
		#   see        ExtendWith
		def StretchWith(pItem)
			This.ExtendXT(pItem)

			def StretchWithQ(pItem)
				return This.ExtendXTQ(pItem)

		# Pads every shorter list with the given item up to the size of the longest list, in place.
		#
		#   pItem      the item to pad with
		#   returns    nothing; the content changes
		#   see        ExtendWith
		def StretchEachListWith(pItem)
			This.ExtendWith(pItem)

			def StretchEachListWithQ(pItem)
				return This.ExtendWithQ(pItem)

		# Pads every shorter list with the given item up to the size of the longest list, in place.
		#
		#   pItem      the item to pad with
		#   returns    nothing; the content changes
		#   see        ExtendWith
		#@ aka  --
		def CompleteXT(pItem)
			This.ExtendXT(pItem)

			def CompleteXTQ(pItem)
				return This.ExtendXTQ(pItem)

		# Pads every shorter list with the given item up to the size of the longest list, in place.
		#
		#   pItem      the item to pad with
		#   returns    nothing; the content changes
		#   see        ExtendWith
		def CompleteEachListXT(pItem)
			This.ExtendXT(pItem)

			def CompleteEachListXTQ(pItem)
				return This.ExtendXTQ(pItem)

		# Pads every shorter list with the given item up to the size of the longest list, in place.
		#
		#   pItem      the item to pad with
		#   returns    nothing; the content changes
		#   see        ExtendWith
		def CompleteWith(pItem)
			This.ExtendXT(pItem)

			def CompleteWithQ(pItem)
				return This.ExtendXTQ(pItem)

		# Pads every shorter list with the given item up to the size of the longest list, in place.
		#
		#   pItem      the item to pad with
		#   returns    nothing; the content changes
		#   note       a misspelling of CompleteEachListWith, kept as an alias
		#   see        ExtendWith
		def ComplteEachListWith(pItem)
			This.ExtendXT(pItem)

			def CompleteEachListWithQ(pItem)
				return This.ExtendXTQ(pItem)

		#--

		def JustifyXT(pItem)
			This.ExtendXT(pItem)

			def JustifyXTQ(pItem)
				return This.ExtendXTQ(pItem)

		# Pads every shorter list with the given item up to the size of the longest list, in place.
		#
		#   pItem      the item to pad with
		#   returns    nothing; the content changes
		#   see        ExtendWith
		def JustifyEachListXT(pItem)
			This.ExtendXT(pItem)

			def JustifyEachListXTQ(pItem)
				return This.ExtendXTQ(pItem)

		# Pads every shorter list with the given item up to the size of the longest list, in place.
		#
		#   pItem      the item to pad with
		#   returns    nothing; the content changes
		#   see        ExtendWith
		def JustifyWith(pItem)
			This.ExtendXT(pItem)

			def JustifyWithQ(pItem)
				return This.ExtendXTQ(pItem)

		# Raises error R24 or R20 today instead of padding every shorter list with a given item.
		#
		#   returns    nothing today
		#   warning    known defect: the def line declares no parameter yet the body reads pItem, so
		#              a call without an argument raises error R24 and a call with one raises error
		#              R20; JustifyWith works
		#   see        JustifyWith
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

	# Pads every list shorter than n with empty text up to n items, in place.
	#
	#   _n_        the size to reach
	#   returns    nothing; the content changes
	#   note       lists already n items long, or longer, are left as they are
	#   see        ExtendedTo, ExtendWith
	def ExtendTo(_n_)
		This.ExtendToXT(_n_, "")


		#< @FunctionFluentForm

		def ExtendToQ(_n_)
			This.ExtendTo(_n_)
			return This

		# Pads every list shorter than n with empty text up to n items, in place.
		#
		#   _n_        the size to reach
		#   returns    nothing; the content changes
		#   see        ExtendTo
		#>
		#< @FunctionAlternativeForm
		def ExtendToPosition(_n_)
			if NOT isNumber(_n_)
				StzRaise("Incorrect param type! n must be a number.")
			ok

			This.ExtendTo(_n_)

			def ExtendToPositionQ(_n_)
				return This.ExtendToQ(_n_)

		# Pads every list shorter than n with empty text up to n items, in place.
		#
		#   _n_        the size to reach
		#   returns    nothing; the content changes
		#   see        ExtendTo
		#@ aka  ==
		def StretchTo(_n_)
			This.ExtendTo(_n_)

			def StretchToQ(_n_)
				return This.ExtendToQ(_n_)

		# Pads every list shorter than n with empty text up to n items, in place.
		#
		#   _n_        the size to reach
		#   returns    nothing; the content changes
		#   see        ExtendTo
		def StretchToPosition(_n_)
			This.ExtendToPosition(_n_)

			def StretchToPositionQ(_n_)
				return This.ExtendToPositionQ(_n_)

	# Returns a copy where every list shorter than n is padded with empty text to n items; the object is unchanged.
	#
	#   _n_        the size to reach
	#   returns    a list of lists
	#   see        ExtendTo
		#>
	def ExtendedTo(_n_)
		_aExtdtResult_ = This.Copy().ExtendToQ(_n_).Content()
		return _aExtdtResult_

		# Returns a copy where every list shorter than n is padded with empty text to n items; the object is unchanged.
		#
		#   _n_        the size to reach
		#   returns    a list of lists
		#   see        ExtendTo
		def ExtendedToPosition(_n_)
			if NOT isNumber(_n_)
				StzRaise("Incorrect param type! n must be a number.")
			ok

			return This.ExtendedTo(_n_)	

		def StretchedTo(_n_)
			return This.ExtendedTo(_n_)

		def StretchedToPosition(_n_)
			return This.ExtendedToPosition(_n_)

	  #------------------------------------------------------------------------------------#
	 #  EXTENDING (EACH LIST IN) THE LIST OF LISTS TO A GIVEN POSITION WITH A GIVEN ITEM  #
	#------------------------------------------------------------------------------------#

	def ExtendToXT(_n_, pItem)
		if CheckingParams()
			if isList(_n_) and Q(_n_).IsPositionNamedParam()
				_n_ = _n_[2]
			ok
	
			if NOT isNumber(_n_)
				StzRaise("Incorrect param type! n must be a number.")
			ok
	
			if isList(pItem) and Q(pItem).IsUsingOrWithOrByNamedParam()
				pItem = pItem[2]
			ok
	
			if isString(pItem) and
			    	StzFindFirst(pItem, [
					:ItemsRepeated, :RepeatingItems,
					:RepeatedItems, :ByRepeatingItems
				]) > 0
	
				This.ExtendToByRepeatingItems(_n_)
				return
			ok
		ok

		# Doing the job

		_nExtxLen_ = This.NumberOfLists()
		for _iExtx_ = 1 to _nExtxLen_
			_nExtxSize_ = This.SizeOfList(_iExtx_)

			_aExtxTemp_ = This.NthList(_iExtx_)
			for _jExtx_ = 1 to _n_ - _nExtxSize_
				@AddItem(_aExtxTemp_, pItem)
			next

			This.ReplaceAt(_iExtx_, _aExtxTemp_)

		next

		#< @FuntionFluentForm

		def ExtendToXTQ(_n_, pItem)
			This.ExtendToXT(_n_, pItem)
			return This

		#>

		#< @FunctionAlternativeForm

		def ExtendToPositionXT(_n_, pItem)
			This.ExtendToXT(_n_, pItem)

		#--

		def StretchToXT(_n_, pItem)
			This.ExtendToXT(_n_, pItem)

			def StretchToXTQ(_n_, pItem)
				return This.ExtendToXTQ(_n_, pItem)

		def StretchToPositionXT(_n_, pItem)
			This.ExtendToPositionXT(_n_, pItem)

			def StretchToPositionXTQ(_n_, pItem)
				return This.ExtendToPositionXTQ(_n_, pItem)

		#>

	def ExtendedToXT(_n_, pItem)
		_aEdtxResult_ = This.Copy().ExtendToXTQ(_n_, pItem).Content()
		return _aEdtxResult_

		#< @FunctionAlternativeForm

		def ExtendedToPositionXT(_n_, pItem)
			if NOT isNumber(_n_)
				StzRaise("Incorrect param type! n must be a number.")
			ok

			return This.ExtendedToXT(_n_, pItem)	

		#--

		def StretchedToXT(_n_, pItem)
			return This.ExtendedToXT(_n_, pItem)

		def StretchedToPositionXT(_n_, pItem)
			return This.ExtendedToPositionXT(_n_, pItem)

		#>


	  #---------------------------------------------------------------------------------------#
	 #  EXTENDING THE LIST OF LISTS TO A GIVEN POSITION BY REPEATING THE ITEMS OF EACH LIST  #
	#---------------------------------------------------------------------------------------#

	# Raises error R14 today instead of padding each list to n items by repeating its own items.
	#
	#   _n_        the size to reach
	#   returns    nothing today
	#   warning    known defect: it asks a plain list for ExtendedToByRepeatingItems, a method that
	#              list does not have, so the call raises error R14
	#   see        ExtendTo
	#TODO // Add Stretch and Expand alternatives to all remaining methods
	def ExtendToByRepeatingItems(_n_)
		_aEtbrContent_ = This.Content()
		_nEtbrLen_ = len(_aEtbrContent_)

		_aEtbrResult_ = []

		for _iEtbr_ = 1 to _nEtbrLen_
			@AddItem(_aEtbrResult_, Q(_aEtbrContent_[_iEtbr_]).ExtendedToByRepeatingItems(_n_))
		next

		This.UpdateWith(_aEtbrResult_)

		#< @FunctionFluentForm

		def ExtendToByRepeatingItemsQ(_n_)
			This.ExtendToByRepeatingItems(_n_)
			return This

		# Raises error R14 today instead of padding each list to n items by repeating its own items.
		#
		#   _n_        the size to reach
		#   returns    nothing today
		#   warning    known defect: it asks a plain list for ExtendedToByRepeatingItems, a method
		#              that list does not have, so the call raises error R14
		#   see        ExtendTo
		#>
		#< @FunctionAlternativeForm
		def ExtendToWithItemsRepeated(_n_)
			This.ExtendedToByRepeatingItems(_n_)

			def ExtendToWithItemsRepeatedQ(_n_)
				return This.ExtendToByRepeatingItemsQ(_n_)

	# Raises error R14 today instead of returning a copy padded to n items by repeating each list's own items.
	#
	#   _n_        the size to reach
	#   returns    nothing today
	#   warning    known defect: it asks a plain list for ExtendedToByRepeatingItems, a method that
	#              list does not have, so the call raises error R14
	#   see        ExtendedTo
		#>
	def ExtendedToByRepeatingItems(_n_)
		_aEdbrResult_ = This.Copy().ExtendToByRepeatingItemsQ(_n_).Content()
		return _aEdbrResult_

		# Raises error R14 today instead of returning a copy padded to n items by repeating each list's own items.
		#
		#   _n_        the size to reach
		#   returns    nothing today
		#   warning    known defect: it asks a plain list for ExtendedToByRepeatingItems, a method
		#              that list does not have, so the call raises error R14
		#   see        ExtendedTo
		#< @FunctionAlternativeForm
		def ExtendedToWithItemsRepeated(_n_)
			This.ExtendedToByRepeatingItems(_n_)

		# Word-order alias used by narrative tests.
		def ExtendedToByRepeating(_n_)
			return This.ExtendedToByRepeatingItems(_n_)

	# Returns, for each list, the positions of its items that lie beyond the length of the first list.
	#
	#   returns    a list of [ list position, positions ] pairs
	#   note       the first list always gets an empty set of positions
	#   see        ExtraItems, FindMissingItems
		#>
	#@ aka  FindExtraItems / ExtraItems: relative to row 1's length, return the positions (FindExtraItems) or values (ExtraItems) of each row's items that lie BEYOND row 1's length. Row 1 itself gets an empty section.
	def FindExtraItems()
		_aData_ = This.Content()
		_nRows_ = len(_aData_)
		if _nRows_ = 0 return [] ok
		_nBase_ = len(_aData_[1])
		_aRes_ = []
		for _i_ = 1 to _nRows_
			_nLen_ = len(_aData_[_i_])
			_aPositions_ = []
			if _nLen_ > _nBase_
				for _j_ = _nBase_ + 1 to _nLen_
					_aPositions_ + _j_
				next
			ok
			_aRes_ + [ _i_, _aPositions_ ]
		next
		return _aRes_

	# Returns, for each list, the items that lie beyond the length of the first list.
	#
	#   returns    a list of lists of items
	#   note       the first list always gets an empty list
	#   see        FindExtraItems
	def ExtraItems()
		_aData_ = This.Content()
		_nRows_ = len(_aData_)
		if _nRows_ = 0 return [] ok
		_nBase_ = len(_aData_[1])
		_aRes_ = []
		for _i_ = 1 to _nRows_
			_aRow_ = _aData_[_i_]
			_nLen_ = len(_aRow_)
			_aExtra_ = []
			if _nLen_ > _nBase_
				for _j_ = _nBase_ + 1 to _nLen_
					_aExtra_ + _aRow_[_j_]
				next
			ok
			_aRes_ + _aExtra_
		next
		return _aRes_

	# ToListInString -- default text form. Delegate to the short form
	# (matches the narrative-test expectation).
	def ToListInString()
		return This.ToListInStringInShortForm()

		def ToListInStringQ()
			return new stzString(This.ToListInString())

	  #----------------------------------------------------------#
	 #  EXTENDING THE LIST OF LISTS TO THE SIZE OF LARGER LIST  #
	#----------------------------------------------------------#

	# Raises error R14 today instead of padding every list to the longest size by repeating its own items.
	#
	#   returns    nothing today
	#   warning    known defect: it ends in ExtendedToByRepeatingItems, a method a plain list does
	#              not have, so the call raises error R14
	#   see        Extend
	def ExtendByRepeatingItems()
		This.ExtendToByRepeatingItems( This.SizeOfLargestList() )

		#< @FunctionFluentForm

		def ExtendByRepeatingItemsQ()
			This.ExtendByRepeatingItems()
			return This

		# Raises error R14 today instead of padding every list to the longest size by repeating its own items.
		#
		#   returns    nothing today
		#   warning    known defect: it ends in ExtendedToByRepeatingItems, a method a plain list
		#              does not have, so the call raises error R14
		#   see        Extend
		#>
		#< @FunctionAlternativeForms
		def ExtendWithItemsRepeated()
			This.ExtendByRepeatingItems()

			def ExtendWithItemsRepeatedQ()
				return This.ExtendByRepeatingItemsQ()

		# Raises error R14 today instead of padding every list to the longest size by repeating its own items.
		#
		#   returns    nothing today
		#   warning    known defect: it ends in ExtendedToByRepeatingItems, a method a plain list
		#              does not have, so the call raises error R14
		#   see        Extend
		def ExtendByItemsRepeated()
			This.ExtendByRepeatingItems()

			def ExtendByItemsRepeatedQ()
				return This.ExtendByRepeatingItemsQ()

	# Raises error R14 today instead of returning a copy padded to the longest size by repeating each list's own items.
	#
	#   returns    nothing today
	#   warning    known defect: it ends in ExtendedToByRepeatingItems, a method a plain list does
	#              not have, so the call raises error R14
	#   see        Extended
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

	# Raises error R14 today instead of padding each list to n items with the given items in turn.
	#
	#   _n_        the size to reach
	#   paItems    the items to pad with
	#   returns    nothing today
	#   warning    known defect: it asks a plain list for ExtendedToWithItemsIn, a method that list
	#              does not have, so the call raises error R14
	#   see        ExtendToWith
	def ExtendToWithItemsIn(_n_, paItems)
		_aEtwiContent_ = This.Content()
		_nEtwiLen_ = len(_aEtwiContent_)

		_aEtwiResult_ = []

		for _iEtwi_ = 1 to _nEtwiLen_
			@AddItem(_aEtwiResult_, Q(_aEtwiContent_[_iEtwi_]).ExtendedToWithItemsIn(_n_, paItems))
		next

		This.UpdateWith(_aEtwiResult_)


		def ExtendToWithItemsInQ(_n_, paItems)
			This.ExtendToWithItemsIn(_n_, paItems)
			return This

		# Raises error R14 today instead of padding each list to n items with the given items in turn.
		#
		#   _n_        the size to reach
		#   paItems    the items to pad with
		#   returns    nothing today
		#   warning    known defect: it asks a plain list for ExtendedToWithItemsIn, a method that
		#              list does not have, so the call raises error R14
		#   see        ExtendTo
		def ExtendToUsingItemsIn(_n_, paItems)
			This.ExtendToWithItemsIn(_n_, paItems)

			def ExtendToUsingItemsInQ(_n_, paItems)
				return This.ExtendToWithItemsInQ(_n_, paItems)

	# Raises error R14 today instead of returning a copy padded to n items with the given items in turn.
	#
	#   _n_        the size to reach
	#   paItems    the items to pad with
	#   returns    nothing today
	#   warning    known defect: it asks a plain list for ExtendedToWithItemsIn, a method that list
	#              does not have, so the call raises error R14
	#   see        ExtendedTo
	def ExtendedToWithItemsIn(_n_, paItems)
		_aEtwiResult2_ = This.Copy().ExtendToWithItemsInQ(_n_, paItems).Content()
		return _aEtwiResult2_

		def ExtendedToUsingItemsIn(_n_, paItems)
			return This.ExtendedToWithItemsIn(_n_, paItems)

	  #-----------------------------------------------------#
	 #  EXTENDIND THE LIST OF LISTS USING THE GIVEN ITEMS  #
	#-----------------------------------------------------#

	# Raises error R14 today instead of padding every list to the longest size with the given items in turn.
	#
	#   paItems    the items to pad with
	#   returns    nothing today
	#   warning    known defect: it ends in ExtendedToWithItemsIn, a method a plain list does not
	#              have, so the call raises error R14
	#   see        ExtendWith
	def ExtendWithItemsIn(paItems)
		This.ExtendToWithItemsIn( This.SizeOfLargestList(), paItems)

		def ExtendWithItemsInQ(paItems)
			This.ExtendWithItemsIn(paItems)
			return This

		# Raises error R14 today instead of padding every list to the longest size with the given items in turn.
		#
		#   paItems    the items to pad with
		#   returns    nothing today
		#   warning    known defect: it ends in ExtendedToWithItemsIn, a method a plain list does
		#              not have, so the call raises error R14
		#   see        ExtendWith
		def ExtendUsingItemsIn(paItems)
			This.ExtendWithItemsIn(paItems)

			def ExtendUsingItemsInQ(paItems)
				return This.ExtendWithItemsInQ(paItems)

	# Raises error R14 today instead of returning a copy padded to the longest size with the given items in turn.
	#
	#   paItems    the items to pad with
	#   returns    nothing today
	#   warning    known defect: it ends in ExtendedToWithItemsIn, a method a plain list does not
	#              have, so the call raises error R14
	#   see        Extended
	def ExtendedWithItemsIn(paItems)
		_aEwiResult_ = This.Copy().ExtendWithItemsInQ(paItems).Content()
		return _aEwiResult_

		def ExtendedUsingItemsIn(paItems)
			return This.ExtendedWithItemsIn(paItems)

	  #================================#
	 #  SHRINKING THE LIST OF LISTS   #
	#================================#

	# Cuts every list down to the size of the shortest list, in place.
	#
	#   returns    nothing; the content changes
	#   see        Shrinked, ShrinkTo
	def Shrink()
		This.ShrinkTo( This.SizeOfSmallestList() )

		def ShrinkQ()
			This.Shrink()
			return This

		# Cuts every list down to the size of the shortest list, in place.
		#
		#   returns    nothing; the content changes
		#   see        Shrink
		#< @FunctionAlternativeForms
		def AdjustToSmallest()
			This.Shrink()

		# Cuts every list down to the size of the shortest list, in place.
		#
		#   returns    nothing; the content changes
		#   see        Shrink
		def AdjustToSmallestSize()
			This.Shrink()

		# Cuts every list down to the size of the shortest list, in place.
		#
		#   returns    nothing; the content changes
		#   see        Shrink
		def AdjustToSmallestList()
			This.Shrink()

		# Cuts every list down to the size of the shortest list, in place.
		#
		#   returns    nothing; the content changes
		#   see        Shrink
		def AdjustToMin()
			This.Shrink()

		# Cuts every list down to the size of the shortest list, in place.
		#
		#   returns    nothing; the content changes
		#   see        Shrink
		def AdjustToMinSize()
			This.Shrink()

		# Cuts every list down to the size of the shortest list, in place.
		#
		#   returns    nothing; the content changes
		#   see        Shrink
		def AdjustToMinList()
			This.Shrink()

	# Returns a copy with every list cut to the size of the shortest; the object is unchanged.
	#
	#   returns    a list of lists
	#   see        Shrink
		#>
	def Shrinked()
		_aSkResult_ = This.Copy().ShrinkQ().Content()
		return _aSkResult_

		# Returns nothing today instead of a copy with every list cut to the size of the shortest.
		#
		#   returns    nothing today
		#   warning    known defect: the body calls Shrinked but has no return, so the answer is
		#              lost; Shrinked works
		#   see        Shrinked
		#< @FunctionAlternativeForms
		def AdjustedToSmallest()
			This.Shrinked()

		# Returns nothing today instead of a copy with every list cut to the size of the shortest.
		#
		#   returns    nothing today
		#   warning    known defect: the body calls Shrinked but has no return, so the answer is
		#              lost; Shrinked works
		#   see        Shrinked
		def AdjustedToSmallestSize()
			This.Shrinked()

		# Returns nothing today instead of a copy with every list cut to the size of the shortest.
		#
		#   returns    nothing today
		#   warning    known defect: the body calls Shrinked but has no return, so the answer is
		#              lost; Shrinked works
		#   see        Shrinked
		def AdjustedToSmallestList()
			This.Shrinked()

		# Returns nothing today instead of a copy with every list cut to the size of the shortest.
		#
		#   returns    nothing today
		#   warning    known defect: the body calls Shrinked but has no return, so the answer is
		#              lost; Shrinked works
		#   see        Shrinked
		def AdjustedToMin()
			This.Shrinked()

		# Returns nothing today instead of a copy with every list cut to the size of the shortest.
		#
		#   returns    nothing today
		#   warning    known defect: the body calls Shrinked but has no return, so the answer is
		#              lost; Shrinked works
		#   see        Shrinked
		def AdjustedToMinSize()
			This.Shrinked()

		# Returns nothing today instead of a copy with every list cut to the size of the shortest.
		#
		#   returns    nothing today
		#   warning    known defect: the body calls Shrinked but has no return, so the answer is
		#              lost; Shrinked works
		#   see        Shrinked
		def AdjustedToMinList()
			This.Shrinked()

		#>

	  #------------------------------------------------------------------#
	 #  SHRINKING (EACH LIST IN) THE LIST OF LISTS TO A GIVEN POSITION  #
	#------------------------------------------------------------------#


	# Cuts every list longer than n down to its first n items, in place.
	#
	#   _n_        the size to cut to
	#   returns    nothing; the content changes
	#   note       shorter lists are left as they are
	#   see        ShrinkedTo, Shrink
	def ShrinkTo(_n_)
		#TODO // Review implementation for performance and history tracing

		if NOT isNumber(_n_)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		_nSktLen_ = This.NumberOfLists()
		for _iSkt_ = 1 to _nSktLen_
			_nSktSize_ = This.SizeOfList(_iSkt_)

			_aSktTemp_ = []
			if _n_ < _nSktSize_
				_aSktTemp_ = This.NthListQ(_iSkt_).Section(1, _n_)
				This.ReplaceAt(_iSkt_, _aSktTemp_)
			ok

		next

		def ShrinkToQ(_n_)
			This.ShrinkTo(_n_) ### Fixed: was misspelled "ShrinkTp"
			return This

		# Cuts every list longer than n down to its first n items, in place.
		#
		#   _n_        the size to cut to
		#   returns    nothing; the content changes
		#   see        ShrinkTo
		#< @FunctionAlternativeForm
		def ShrinkToPosition(_n_)
			This.ShrinkTo(_n_)

	# Returns a copy with every list cut to its first n items; the object is unchanged.
	#
	#   _n_        the size to cut to
	#   returns    a list of lists
	#   see        ShrinkTo
		#>
	def ShrinkedTo(_n_)
		_aSkdtResult_ = This.Copy().ShrinkToQ(_n_).Content()
		return _aSkdtResult_

		# Returns a copy with every list cut to its first n items; the object is unchanged.
		#
		#   _n_        the size to cut to
		#   returns    a list of lists
		#   see        ShrinkTo
		def ShrinkedToPosition(_n_)
			if NOT isNumber(_n_)
				StzRaise("Incorrect param type! n must be a number.")
			ok

			return This.ShrinkedTo(_n_)

	  #--------------------------------------------------------------------------------------#
	 #  SHRINKING (EACH LIST IN) THE LIST OF LISTS TO A GIVEN POSITION USING A GIVEN VALUE  #
	#--------------------------------------------------------------------------------------#

	# Cuts every list longer than n down to its first n items, in place, and never uses the given item.
	#
	#   _n_        the size to cut to
	#   pItem      an item that is not used today
	#   returns    nothing; the content changes
	#   warning    known defect: the padding loop never runs, and when n is greater than the longest
	#              list every list is dropped and the content becomes empty
	#   see        ShrinkTo
	def ShrinkToWith(_n_, pItem)

		if CheckingParams()

			if isList(_n_) and Q(_n_).IsToOrToPosition(_n_)
				_n_ = _n_[2]
			ok
	
			if NOT isNumber(_n_)
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

			if _n_ > _nSkwLargest_
				loop
			ok

			if _n_ < _nSkwInner_

				_aSkwTemp_ = []
				for _jSkw_ = 1 to _n_
					@AddItem(_aSkwTemp_, _aSkwContent_[_iSkw_][_jSkw_])
				next

				@AddItem(_aSkwResult_, _aSkwTemp_)

			else
				_aSkwTemp_ = _aSkwContent_[_iSkw_]
				_nSkwDiff_ = _nSkwInner_ - _n_

				for _kSkw_ = 1 to _nSkwDiff_
					@AddItem(_aSkwTemp_, pItem)
				next

				@AddItem(_aSkwResult_, _aSkwTemp_)
			ok
		next

		This.UpdateWith(_aSkwResult_)

		#< @FunctionFluentForm

		def ShrinkToWithQ(_n_, pItem)
			This.ShrinkToWith(_n_, pItem)
			return This

		# Cuts every list longer than n down to its first n items, in place, and never uses the given item.
		#
		#   _n_        the size to cut to
		#   pItem      an item that is not used today
		#   returns    nothing; the content changes
		#   warning    known defect: the padding loop never runs, and when n is greater than the
		#              longest list every list is dropped and the content becomes empty
		#   see        ShrinkTo
		#>
		#< @FunctionAlternativeForms
		def ShrinkToUsing(_n_, pItem)
			This.ShrinkToWith(_n_, pItem)

			def ShrinkToUsingQ(_n_, pItem)
				return This.ShrinkToWithQ(_n_, pItem)

		def ShrinkXT(_n_, pItem)
			This.ShrinkToWith(_n_, pItem)

			def ShrinkXTQ(_n_, pItem)
				return This.ShrinkToWithQ(_n_, pItem)

	# Returns a copy with every list cut to its first n items; the given item is never used.
	#
	#   _n_        the size to cut to
	#   pWith      an item that is not used today
	#   returns    a list of lists
	#   warning    known defect: when n is greater than the longest list every list is dropped and
	#              the answer is empty
	#   see        ShrinkedTo
		#>
	def ShrinkedToWith(_n_, pWith)
		_aSktwResult_ = This.Copy().ShrinkToWithQ(_n_, pWith).Content()
		return _aSktwResult_

		# Returns a copy with every list cut to its first n items; the given item is never used.
		#
		#   _n_        the size to cut to
		#   pUsing     an item that is not used today
		#   returns    a list of lists
		#   warning    known defect: when n is greater than the longest list every list is dropped
		#              and the answer is empty
		#   see        ShrinkedTo
		#< @FunctionAlternativeForms
		def ShrinkedToUsing(_n_, pUsing)
			return This.ShrinkedToWith(_n_, pUsing) ### Fixed: was passing undefined pWith

		# Returns a copy with every list cut to its first n items; the given item is never used.
		#
		#   _n_        the size to cut to
		#   pBy        an item that is not used today
		#   returns    a list of lists
		#   warning    known defect: when n is greater than the longest list every list is dropped
		#              and the answer is empty
		#   see        ShrinkedTo
		def ShrinkedToBy(_n_, pBy)
			return This.ShrinkedToWith(_n_, pBy) ### Fixed: was passing undefined pWith

		#>

	  #-----------------------------------------------------------------------------#
	 #  ADJUSTING THE LIST OF LISTS TO A GIVEN NUMBER OF ITEMS USING A GIVEN ITEM  #
	#-----------------------------------------------------------------------------#

	# Pads every shorter list with the given item up to the size of the longest list, in place.
	#
	#   pItem      the item to pad with
	#   returns    nothing; the content changes
	#   see        AdjustedWith, Extend
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

		# Pads every shorter list with the given item up to the size of the longest list, in place.
		#
		#   pItem      the item to pad with
		#   returns    nothing; the content changes
		#   see        AdjustWith
		def AdjustUsing(pItem)
			This.AdjustWith(pItem)

			def AdjustUsingQ(pItem)
				return This.AdjustWithQ(pItem)

	# Returns a copy with every shorter list padded with the given item to the size of the longest; the object is unchanged.
	#
	#   pItem      the item to pad with
	#   returns    a list of lists
	#   see        AdjustWith
	def AdjustedWith(pItem)
		_aAdwdResult_ = This.Copy().AdjustWithQ(pItem).Content()
		return _aAdwdResult_

		def AdjustedUsing(pItem)
			return This.AdjustedWith(pItem)

	# Pads every list shorter than n with empty text, and cuts every longer list, so each holds exactly n items, in place.
	#
	#   _n_        the size every list gets
	#   returns    nothing; the content changes
	#   see        AdjustedTo, AdjustToWith
	#---
	def AdjustTo(_n_)
		This.AdjustXT(_n_, "")

		def AdjustToQ(_n_)
			This.AdjustTo(_n_)
			return This

		# Pads every list shorter than n with empty text, and cuts every longer list, so each holds exactly n items, in place.
		#
		#   _n_        the size every list gets
		#   returns    nothing; the content changes
		#   see        AdjustTo
		def AdjustToPosition(_n_)
			This.AdjustTo(_n_)

			def AdjustToPositionQ(_n_)
				return This.AdjustToQ(_n_)

	# Returns a copy where every list holds exactly n items, padded with empty text or cut; the object is unchanged.
	#
	#   _n_        the size every list gets
	#   returns    a list of lists
	#   see        AdjustTo
	def AdjustedTo(_n_)
		_aAdtResult_ = This.Copy().AdjustToQ(_n_).Content() ### Fixed: .Conten() typo
		return _aAdtResult_

		def AdjustedToPosition(_n_)
			return This.AdjustedTo(_n_)

	#---

	def AdjustXT(_n_, pItem)

		if CheckingParams()

			if isList(_n_) and Q(_n_).IsToOrToPosition(_n_)
				_n_ = _n_[2]
			ok
	
			if NOT isNumber(_n_)
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

			if _nAdxInner_ = _n_
				@AddItem(_aAdxResult_, _aAdxContent_[_iAdx_])
				loop
			ok

			_nAdxDiff_ = Abs( _nAdxInner_ - _n_ )

			if _nAdxInner_ < _n_

				_aAdxTemp_ = _aAdxContent_[_iAdx_]

				for _jAdx_ = 1 to _nAdxDiff_
					@AddItem(_aAdxTemp_, pItem)
				next

			else

				_aAdxTemp_ = []

				for _kAdx_ = 1 to _n_
					@AddItem(_aAdxTemp_, _aAdxContent_[_iAdx_][_kAdx_]) ### Fixed: was [_iAdx_] only
				next

			ok

			@AddItem(_aAdxResult_, _aAdxTemp_)

		next

		This.UpdateWith(_aAdxResult_)


		#< @FunctionFluentForm

		def AdjustXTQ(_n_, pItem)
			This.AdjustXT(_n_, pItem)
			return This
		#>

		def AdjustToXT(_n_, pItem)
			This.AdjustXT(_n_, pItem)

			def AdjustToXTQ(_n_, pItem)
				return This.AdjustXTQ(_n_, pItem)

		# Pads every list shorter than n with the given item, and cuts every longer list, so each holds exactly n items, in place.
		#
		#   _n_        the size every list gets
		#   pItem      the item to pad with
		#   returns    nothing; the content changes
		#   see        AdjustTo
		def AdjustToWith(_n_, pItem)
			This.AdjustXT(_n_, pItem)

			def AdjustToWithQ(_n_, pItem)
				return This.AdjustXTQ(_n_, pItem)

	def AdjustedXT(_n_, pItem)
		_aAdxdResult_ = This.Copy().AdjustXTQ(_n_, pItem).Content()
		return _aAdxdResult_

		def AdjustedToXT(_n_, pItem)
			return This.AdjustedXT(_n_, pItem)


		def AdjustedToWith(_n_, pItem)
			return This.AdjustedXT(_n_, pItem)

	  #========================================#
	 #   ASSOCIATING THE LISTS ITEM BY ITEM   #
	#========================================#

	# Replaces the lists by their columns: the first items together, then the second items, and so on; gaps become empty text.
	#
	#   returns    nothing; the content changes
	#   note       raises an error for a single list
	#   see        Associated, Pairify
	def Associate()
		This.Update( @Association(This.Content()) )

		def AssociateQ()
			This.Associate()
			return This

	# Returns the columns of the lists as lists, gaps filled with empty text; the object is unchanged.
	#
	#   returns    a list of lists
	#   note       raises an error for a single list
	#   see        Associate
	def Associated()
		_aAsResult_ = This.Copy().AssociateQ().Content()
		return _aAsResult_

	  #----------------------------#
	 #  PAIRIFYING THE TWO LISTS  #
	#----------------------------#

	# Replaces exactly two lists by [ item, item ] pairs taken position by position, in place.
	#
	#   returns    nothing; the content changes
	#   note       raises an error unless the object holds exactly two lists of the same size
	#   see        Pairified, Associate
	def Pairify()
		This.UpdateWith( @Pairify(This.Content()) )

		def PairifyQ()
			This.Pairify() ### Fixed: was "Parify" typo
			return This

	# Returns the pairs [ item of the first list, item of the second list ]; the object is unchanged.
	#
	#   returns    a list of pairs
	#   note       raises an error unless the object holds exactly two lists of the same size
	#   see        Pairify, Associated
	def Pairified()
		_aPaResult_ = This.Copy().PairifyQ().Content()
		return _aPaResult_

	  #-------------------------------------#
	 #   REVERSING THE ITEMS OF THE LIST   #
	#-------------------------------------#

	# Reverses the order of the lists, in place; the items inside each list keep their order.
	#
	#   returns    nothing; the content changes
	#   see        ReversedLists, ReverseItemsInLists
	#@ aka  To avoid confusion, it's better to use the alternative forms ReverseItems() and ItemsReversed()
	def ReverseLists()

		_oRvlTemp_ = new stzList(This.ListOfLists())
		_aRvlResult_ = _oRvlTemp_.Reversed()

		This.Update( _aRvlResult_ )

		# Reverses the order of the lists, in place; the items inside each list keep their order.
		#
		#   returns    nothing; the content changes
		#   see        ReverseLists
		def ReverseItems()
			This.ReverseLists()


		def ReverseListsQ()
			This.ReverseLists()
			return This

		# Reverses the order of the lists, in place; the items inside each list keep their order.
		#
		#   returns    nothing; the content changes
		#   see        ReverseLists
		def Reverse()
			This.ReverseLists()

			def ReverseQ()
				return This.ReverseListsQ()

	# Returns the lists in reverse order; the object is unchanged.
	#
	#   returns    a list of lists
	#   see        ReverseLists
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

	# Reverses the items inside each list, in place; the lists keep their order.
	#
	#   returns    nothing; the content changes
	#   see        ItemsInListsReversed, ReverseLists
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

		# Reverses the items inside each list, in place; the lists keep their order.
		#
		#   returns    nothing; the content changes
		#   see        ReverseItemsInLists
		def ReverseListsContent()
			This.ReverseItemsInLists()

			def ReverseListsContentQ()
				This.ReverseListsContent()
				return This

	# Returns a copy with the items inside each list reversed; the object is unchanged.
	#
	#   returns    a list of lists
	#   see        ReverseItemsInLists
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

	# Returns [ item, [ list positions ] ] pairs: each distinct item with the positions of the lists that hold it.
	#
	#   returns    a list of [ item, positions ] pairs
	#   note       the match is case-sensitive; an item found twice in one list gives that list
	#              position twice
	#   see        FindInLists, FindManyInLists
	#@ aka  -- WITHOUT CASESENSITIVITY
	def Index()
		return This.IndexCS(1)

		def IndexQ()
			return This.IndexQRT(:stzList)

		def IndexQRT(pcReturnType)
			return This.IndexCSQRT(1, pcReturnType)

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
			return This.IndexCSXTQRT(1, pcReturnType)

	def IndexedXT()
		return This.IndexXT()

	  #------------#
	 #   ENTRY    #
	#------------#

	# Raises error R14 today instead of returning the index entry of an item by position.
	#
	#   pEntry     the item whose entry is wanted
	#   returns    nothing today
	#   warning    known defect: it calls IndexOn, which is defined nowhere, so the call raises
	#              error R14
	#   see        Index
	def EntryByPosition(pEntry)
		return This.Entry(pEntry, :ByPosition)

	# Raises error R14 today instead of returning the index entry of an item by its number of occurrences.
	#
	#   pEntry     the item whose entry is wanted
	#   returns    nothing today
	#   warning    known defect: it calls IndexOn, which is defined nowhere, so the call raises
	#              error R14
	#   see        Index
	def EntryByNumberOfOccurrence(pEntry)
		return This.Entry(pEntry, :ByNumberOfOccurrence)

		def EntryByNumberOfOccurrences(pEntry)
			return This.EntryByNumberOfOccurrence(pEntry)

	# Raises error R14 today instead of returning the index entry of an item, by position or by number of occurrences.
	#
	#   pEntry     the item whose entry is wanted
	#   pcBy       :ByPosition or :ByNumberOfOccurrence
	#   returns    nothing today
	#   warning    known defect: it calls IndexOn, which is defined nowhere, so the call raises
	#              error R14 for either mode; any other pcBy returns empty text
	#   see        Index
	def Entry(pEntry,pcBy)
		if pcBy = :ByPosition
			return This.IndexOn(:Position)[pEntry]

		but pcBy = :ByNumberOfOccurrence or pcBy = :ByNumberOfOccurrences
			return This.IndexOn(:NumberOfOccurrence)[pEntry]
		ok

	  #-----------------------------------------#
	 #   OCCURRENCE OF AN ENTRY IN THE INDEX   #
	#-----------------------------------------#

	# Raises error R14 today instead of returning how many times an item occurs.
	#
	#   pEntry     the item to count
	#   returns    nothing today
	#   warning    known defect: it calls IndexOn, which is defined nowhere, so the call raises
	#              error R14
	#   see        Index
	def NumberOfOccurrenceOfEntry(pEntry)
		return len(This.IndexOn(:Position)[pEntry]) ### Fixed: was bare o1

		def NumberOfOccurrencesOfEntry(pEntry)
			return This.NumberOfOccurrenceOfEntry(pEntry)

		# Raises error R14 today instead of returning how many times an item occurs.
		#
		#   pEntry     the item to count
		#   returns    nothing today
		#   warning    known defect: it calls IndexOn, which is defined nowhere, so the call raises
		#              error R14
		#   see        Index
		def HowManyEntry(pEntry)
			return len(This.IndexOn(:Position)[pEntry]) ### Fixed: was bare o1 + missing pEntry param

		# Raises error R14 today instead of returning how many times an item occurs.
		#
		#   pEntry     the item to count
		#   returns    nothing today
		#   warning    known defect: it calls IndexOn, which is defined nowhere, so the call raises
		#              error R14
		#   see        Index
		def HowManyEntries(pEntry)
			return len(This.IndexOn(:Position)[pEntry]) ### Fixed: was bare o1 + missing pEntry param

	# Raises error R14 today instead of returning where an item occurs for the nth time.
	#
	#   _n_        which occurrence
	#   pEntry     the item to look for
	#   returns    nothing today
	#   warning    known defect: it calls IndexOn, which is defined nowhere, so the call raises
	#              error R14
	#   see        Index
	def NthOccurrenceOfEntry(_n_, pEntry)
		return This.IndexOn(:Position)[pEntry][_n_] ### Fixed: was bare o1

		def NthOccurrencesOfEntry(_n_, pEntry)
			return This.NthOccurrenceOfEntry(_n_, pEntry)

	# Raises error R14 today instead of returning where an item first occurs.
	#
	#   pEntry     the item to look for
	#   returns    nothing today
	#   warning    known defect: it calls IndexOn, which is defined nowhere, so the call raises
	#              error R14
	#   see        Index
	def FirstOccurrenceOfEntry(pEntry)
		return This.NthOccurrenceOfEntry(1, pEntry) ### Fixed: was bare call

	# Raises error R14 today instead of returning where an item last occurs.
	#
	#   pEntry     the item to look for
	#   returns    nothing today
	#   warning    known defect: it calls IndexOn, which is defined nowhere, so the call raises
	#              error R14
	#   see        Index
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

	# TRUE if the item occurs inside at least one of the lists; the match is case-sensitive.
	#
	#   pItem      the item to look for
	#   returns    TRUE or FALSE
	#   see        ListsContainingItem, EachListContains
	#@ aka  -- WITHOUT CASESENSITIVITY
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

	# Returns the lists that hold the item; the match is case-sensitive.
	#
	#   pItem      the item to look for
	#   returns    a list of lists
	#   see        ContainsItem
	#@ aka  -- WITHOUT CASESENSITIVITY
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

	# TRUE if the item occurs inside every list; the match is case-sensitive.
	#
	#   pItem      the item to look for
	#   returns    TRUE or FALSE
	#   see        ContainsItem
		#>
	#@ aka  -- WITHOUT CASESENSITIVITY
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

	# Raises an error on purpose: the lists cannot be merged in place, use the passive form instead.
	#
	#   returns    nothing today
	#   warning    known defect: the body only raises "Can't merge the list of lists! ... use
	#              Merged()"
	#   see        Merged
	def Merge()
		StzRaise("Can't merge the list of lists! Instead you can return a merged copy of it using Merged()")

		def MergeQ()
			StzRaise("Can't merge the list of lists! Instead you can return a merged copy of it using Merged()")

	# Returns the items of all the lists joined into one flat list; the object is unchanged.
	#
	#   returns    a list of items
	#   see        Flattened, Merge
	def Merged()
		_aMgResult_ = @Merge(@aContent)
		return _aMgResult_

	  #----------------------------------------#
	 #  GETTING A FLATTENED COPY OF THE LIST  #
	#----------------------------------------#

	# Raises an error on purpose: the lists cannot be flattened in place, use the passive form instead.
	#
	#   returns    nothing today
	#   warning    known defect: the body only raises "Can't flatten the list of lists! ... use
	#              Flattened()"
	#   see        Flattened
	def Flatten()
		StzRaise("Can't flatten the list of lists! Instead you can return a flattend copy of it using Flattened()")

		def FlattenQ()
			StzRaise("Can't flatten the list of lists! Instead you can return a flattend copy of it using Flattened()")

	# Returns the items of all the lists joined into one flat list; the object is unchanged.
	#
	#   returns    a list of items
	#   see        Merged, Flatten
	def Flattened()
		return This.ToStzList().Flattened()

		def FlattenedQ()
			return new stzList( This.Flattened() )

	  #===========================================================#
	 #  CHECKING IF THE SIZE OF EACH ITEM EQUALS A GIVEN NUMBER  #
	#===========================================================#

	# TRUE if every list holds exactly n items.
	#
	#   _n_        the number of items each list should hold
	#   returns    TRUE or FALSE
	#   see        Sizes, ListsHaveSameNumberOfItems
	def SizeOfEach@Is(_n_)
		_aSeContent_ = This.Content()
		_nSeLen_ = len(_aSeContent_)

		_bSeResult_ = 1 ### Fixed: was nResult=1 but inner branch set bResult=0 (different var)

		for _iSe_ = 1 to _nSeLen_
			if len(_aSeContent_[_iSe_]) != _n_
				_bSeResult_ = 0
				exit
			ok
		next

		return _bSeResult_

		# TRUE if every list holds exactly n items.
		#
		#   _n_        the number of items each list should hold
		#   returns    TRUE or FALSE
		#   see        Sizes, ListsHaveSameNumberOfItems
		#< @FunctionalternativeForms
		def TheSizeOfEach@Is(_n_)
			return This.SizeOfEach@Is(_n_)

		# TRUE if every list holds exactly n items.
		#
		#   _n_        the number of items each list should hold
		#   returns    TRUE or FALSE
		#   see        Sizes, ListsHaveSameNumberOfItems
		def TheSizeInEach@Is(_n_)
			return This.SizeOfEach@Is(_n_)

		# TRUE if every list holds exactly n items.
		#
		#   _n_        the number of items each list should hold
		#   returns    TRUE or FALSE
		#   see        Sizes, ListsHaveSameNumberOfItems
		def TheSizeOfEach@IsEqualTo(_n_)
			return This.SizeOfEach@Is(_n_)

		# TRUE if every list holds exactly n items.
		#
		#   _n_        the number of items each list should hold
		#   returns    TRUE or FALSE
		#   see        Sizes, ListsHaveSameNumberOfItems
		def TheSizeInEach@IsEqualTo(_n_)
			return This.SizeOfEach@Is(_n_)

		# TRUE if every list holds exactly n items.
		#
		#   _n_        the number of items each list should hold
		#   returns    TRUE or FALSE
		#   see        Sizes, ListsHaveSameNumberOfItems
		def SizeOfEachListEquals(_n_)
			return This.SizeOfEach@Is(_n_)

		# TRUE if every list holds exactly n items.
		#
		#   _n_        the number of items each list should hold
		#   returns    TRUE or FALSE
		#   see        Sizes, ListsHaveSameNumberOfItems
		def SizeInEachListEquals(_n_)
			return This.SizeOfEach@Is(_n_)

		# TRUE if every list holds exactly n items.
		#
		#   _n_        the number of items each list should hold
		#   returns    TRUE or FALSE
		#   see        Sizes, ListsHaveSameNumberOfItems
		def SizeOfEach@IsEqualTo(_n_)
			return This.SizeOfEach@Is(_n_)

		# TRUE if every list holds exactly n items.
		#
		#   _n_        the number of items each list should hold
		#   returns    TRUE or FALSE
		#   see        Sizes, ListsHaveSameNumberOfItems
		def SizeInEach@IsEqualTo(_n_)
			return This.SizeOfEach@Is(_n_)

		# TRUE if every list holds exactly n items.
		#
		#   _n_        the number of items each list should hold
		#   returns    TRUE or FALSE
		#   see        Sizes, ListsHaveSameNumberOfItems
		def TheSizeOfEachListEquals(_n_)
			return This.SizeOfEach@Is(_n_)

		# TRUE if every list holds exactly n items.
		#
		#   _n_        the number of items each list should hold
		#   returns    TRUE or FALSE
		#   see        Sizes, ListsHaveSameNumberOfItems
		def TheSizeInEachListEquals(_n_)
			return This.SizeOfEach@Is(_n_)

		# TRUE if every list holds exactly n items.
		#
		#   _n_        the number of items each list should hold
		#   returns    TRUE or FALSE
		#   see        Sizes, ListsHaveSameNumberOfItems
		def EachListHasTheSize(_n_)
			return This.SizeOfEach@Is(_n_)

		# TRUE if every list holds exactly n items.
		#
		#   _n_        the number of items each list should hold
		#   returns    TRUE or FALSE
		#   see        Sizes, ListsHaveSameNumberOfItems
		def EachListHasSize(_n_)
			return This.SizeOfEach@Is(_n_)

		# TRUE if every list holds exactly n items.
		#
		#   _n_        the number of items each list should hold
		#   returns    TRUE or FALSE
		#   see        Sizes, ListsHaveSameNumberOfItems
		def EachListHasItsSizeEqualTo(_n_)
			return This.SizeOfEach@Is(_n_)

		# TRUE if every list holds exactly n items.
		#
		#   _n_        the number of items each list should hold
		#   returns    TRUE or FALSE
		#   see        Sizes, ListsHaveSameNumberOfItems
		def EachListHasThisSize(_n_)
			return This.SizeOfEach@Is(_n_)

		# TRUE if every list holds exactly n items.
		#
		#   _n_        the number of items each list should hold
		#   returns    TRUE or FALSE
		#   see        Sizes, ListsHaveSameNumberOfItems
		def EachListHasThisSameSize(_n_)
			return This.SizeOfEach@Is(_n_)

		# TRUE if every list holds exactly n items.
		#
		#   _n_        the number of items each list should hold
		#   returns    TRUE or FALSE
		#   see        Sizes, ListsHaveSameNumberOfItems
		#@ aka  --
		def TheNumberOfItemsOfEach@Is(_n_)
			return This.SizeOfEach@Is(_n_)

		# TRUE if every list holds exactly n items.
		#
		#   _n_        the number of items each list should hold
		#   returns    TRUE or FALSE
		#   see        Sizes, ListsHaveSameNumberOfItems
		def TheNumberOfItemsInEach@Is(_n_)
			return This.SizeOfEach@Is(_n_)

		# TRUE if every list holds exactly n items.
		#
		#   _n_        the number of items each list should hold
		#   returns    TRUE or FALSE
		#   see        Sizes, ListsHaveSameNumberOfItems
		def TheNumberOfItemsOfEach@IsEqualTo(_n_)
			return This.SizeOfEach@Is(_n_)

		# TRUE if every list holds exactly n items.
		#
		#   _n_        the number of items each list should hold
		#   returns    TRUE or FALSE
		#   see        Sizes, ListsHaveSameNumberOfItems
		def TheNumberOfItemsInEach@IsEqualTo(_n_)
			return This.SizeOfEach@Is(_n_)

		# TRUE if every list holds exactly n items.
		#
		#   _n_        the number of items each list should hold
		#   returns    TRUE or FALSE
		#   see        Sizes, ListsHaveSameNumberOfItems
		def NumberOfItemsOfEachListEquals(_n_)
			return This.SizeOfEach@Is(_n_)

		# TRUE if every list holds exactly n items.
		#
		#   _n_        the number of items each list should hold
		#   returns    TRUE or FALSE
		#   see        Sizes, ListsHaveSameNumberOfItems
		def NumberOfItemsInEachListEquals(_n_)
			return This.SizeOfEach@Is(_n_)

		# TRUE if every list holds exactly n items.
		#
		#   _n_        the number of items each list should hold
		#   returns    TRUE or FALSE
		#   see        Sizes, ListsHaveSameNumberOfItems
		def NumberOfItemsOfEach@IsEqualTo(_n_)
			return This.SizeOfEach@Is(_n_)

		# TRUE if every list holds exactly n items.
		#
		#   _n_        the number of items each list should hold
		#   returns    TRUE or FALSE
		#   see        Sizes, ListsHaveSameNumberOfItems
		def NumberOfItemsInEach@IsEqualTo(_n_)
			return This.SizeOfEach@Is(_n_)

		# TRUE if every list holds exactly n items.
		#
		#   _n_        the number of items each list should hold
		#   returns    TRUE or FALSE
		#   see        Sizes, ListsHaveSameNumberOfItems
		def TheNumberOfItemsOfEachListEquals(_n_)
			return This.SizeOfEach@Is(_n_)

		# TRUE if every list holds exactly n items.
		#
		#   _n_        the number of items each list should hold
		#   returns    TRUE or FALSE
		#   see        Sizes, ListsHaveSameNumberOfItems
		def TheNumberOfCharsInEachStringEquals(_n_)
			return This.SizeOfEach@Is(_n_)

		# TRUE if every list holds exactly n items.
		#
		#   _n_        the number of items each list should hold
		#   returns    TRUE or FALSE
		#   see        Sizes, ListsHaveSameNumberOfItems
		def EachListHasTheNumberOfItems(_n_)
			return This.SizeOfEach@Is(_n_)

		# TRUE if every list holds exactly n items.
		#
		#   _n_        the number of items each list should hold
		#   returns    TRUE or FALSE
		#   see        Sizes, ListsHaveSameNumberOfItems
		def EachListHasNumberOfItems(_n_)
			return This.SizeOfEach@Is(_n_)

		# TRUE if every list holds exactly n items.
		#
		#   _n_        the number of items each list should hold
		#   returns    TRUE or FALSE
		#   see        Sizes, ListsHaveSameNumberOfItems
		def EachListHasItsNumberOfItemsEqualTo(_n_)
			return This.SizeOfEach@Is(_n_)

		# TRUE if every list holds exactly n items.
		#
		#   _n_        the number of items each list should hold
		#   returns    TRUE or FALSE
		#   see        Sizes, ListsHaveSameNumberOfItems
		def EachListItemHasThisNumberOfItems(_n_)
			return This.SizeOfEach@Is(_n_)

		# TRUE if every list holds exactly n items.
		#
		#   _n_        the number of items each list should hold
		#   returns    TRUE or FALSE
		#   see        Sizes, ListsHaveSameNumberOfItems
		def EachListItemHasThisSameNumberOfItems(_n_)
			return This.SizeOfEach@Is(_n_)

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

	# TRUE if every list holds the same items in the same order as the first one; the match is case-sensitive.
	#
	#   returns    TRUE or FALSE
	#   see        CommonItems, ListsHaveSameNumberOfItems
	#@ aka  -- WITHOUT CASESENSITIVITY
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
			_aCiCommon_ = StzEngineListContentToRingList(_pCiResult_)
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

	# Returns the items that occur in every list; the match is case-sensitive.
	#
	#   returns    a list of items
	#   note       [ ] when no item is shared
	#   see        AllListsAreEqual, ContainsItem
	#@ aka  -- WITHOUT CASESENSITIVITY
	def CommonItems()
		return This.CommonItemsCS(1)

		def Intersection()
			return This.CommonItems()

	  #================================================#
	 #  GETTING THE NTH COLOUMN IN THE LIST OF LISTS  #
	#================================================#

	# Returns the columns: the first items of the lists, then the second items, and so on, without padding the short lists.
	#
	#   returns    a list of lists
	#   note       a list too short for a column is skipped in it
	#   see        NthColumn, Associated
	def Cols()
		_nClLen_ = This.NumberOfCols()
		_aClResult_ = []

		for _iCl_ = 1 to _nClLen_
			@AddItem(_aClResult_, This.Col(_iCl_))
		next

		return _aClResult_

		def Columns()
			return This.Cols()

	# Returns how many columns there are, which is the size of the longest list.
	#
	#   returns    a number
	#   see        Cols, SizeOfLargestList
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

	def NthcolumnXT(_n_) # Adds NULL if size of innerlist < n
		if CheckingParams()
			if NOT isNumber(_n_)
				StzRaise("Incorrect param type! n must be a number.")
			ok
		ok

		_nNcxLen_ = len(@aContent)

		if EarlyCheck()
			if _nNcxLen_ = 0
				return []
			ok

			if _n_ < 1 or _n_ > This.NumberOfCols()
				return []
			ok
		ok

		# Doing the job

		_aNcxResult_ = []

		for _iNcx_ = 1 to _nNcxLen_
			_nNcxInner_ = len(@aContent[_iNcx_])
			if _nNcxInner_ >= _n_
				@AddItem(_aNcxResult_, @aContent[_iNcx_][_n_])
			else
				@AddItem(_aNcxResult_, "")
			ok
		next

		return _aNcxResult_

		#< @FunctionFluentForm

		def NthColumnXTQ(_n_)
			return new stzList(This.NthColumnXT(_n_))

		#>

		#< @FunctionAlternativeForm

		def NthColXT(_n_)
			return This.NthColumnXT(_n_)

			def NthColXTQ(_n_)
				return This.NthColumnXTQ(_n_)

		def ColXT(_n_)
			return This.NthColumnXT(_n_)

			def ColXTQ(_n_)
				return This.NthColumnXTQ(_n_)

	# Returns the items at position n of the lists that have one, in list order.
	#
	#   _n_        the column position, 1 for the first
	#   returns    a list of items
	#   note       [ ] for a column that does not exist; short lists are skipped, so the answer can
	#              be shorter than the object
	#   see        Cols, ItemsAtPositionN
		#>
	def NthColumn(_n_)
		if CheckingParams()
			if NOT isNumber(_n_)
				StzRaise("Incorrect param type! n must be a number.")
			ok
		ok

		_nNcLen_ = len(@aContent)

		if EarlyCheck()
			if _nNcLen_ = 0
				return []
			ok

			if _n_ < 1 or _n_ > This.NumberOfCols()
				return []
			ok
		ok

		# Doing the job

		_aNcResult_ = []

		for _iNc_ = 1 to _nNcLen_
			_nNcInner_ = len(@aContent[_iNc_])
			if _n_ <= _nNcInner_
				@AddItem(_aNcResult_, @aContent[_iNc_][_n_])
			ok
		next

		return _aNcResult_

		#< @FunctionFluentForm

		def NthColumnQ(_n_)
			return new stzList(This.NthColumn(_n_))

		#>

		#< @FunctionAlternativeForm

		def NthCol(_n_)
			return This.NthColumn(_n_)

			def NthColQ(_n_)
				return This.NthColumnQ(_n_)

		def NthItems(_n_)
			return This.NthColumn(_n_)

			def NthItemsQ(_n_)
				return This.NthColumnQ(_n_)

		def Col(_n_)
			return This.NthColumn(_n_)

			def ColQ(_n_)
				return This.NthColumnQ(_n_)

	# Returns the first item of every list.
	#
	#   returns    a list of items
	#   see        LastColumn, NthColumn
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

		# Returns the first item of every list.
		#
		#   returns    a list of items
		#   see        FirstColumn
		def FirstItems()
			return This.NthColumn(1)

			def FirstItemsQ()
				return This.NthColumnQ(1)

	# Returns the items at the last column position, which only the longest lists have.
	#
	#   returns    a list of items
	#   see        FirstColumn, NumberOfColumns
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

	# Appends the given values as a new last column, one value to the end of each list in turn, in place.
	#
	#   paList     the values, the first going to the first list
	#   returns    nothing; the content changes
	#   note       an empty paList does nothing; with fewer values than lists the remaining lists
	#              are left unchanged
	#   see        InsertCol, ReplaceCol
	def AddCol(paList)
		/* EXAMPLE

		_o1_ = new stzListOfLists([
			[ 1 ],
			[ "one", "two" ],
			[ ]
		])
		
		_o1_.AddCol([ 2, "three", 0 ])
		? @@NL( _o1_.Content() )
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

		_o1_ = new stzListOfLists([
			[ 1 ],
			[ "one", "two" ],
			[ ]
		])
		
		_o1_.AddCol([ 2, "three", 0 ])
		? @@NL( _o1_.Content() )
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

	# Sorts the items inside the list at position n, in ascending order, in place.
	#
	#   _n_        the position of the list to sort
	#   returns    nothing; the content changes
	#   note       the other lists are not touched
	#   see        NthListSorted, SortLists
	def SortNthList(_n_)
		_aSnContent_ = This.Content()
		_aSnSorted_ = @SortList(_aSnContent_[_n_])
		_aSnContent_[_n_] = _aSnSorted_

		This.UpdateWith(_aSnContent_)


		def SortNthListQ(_n_)
			This.SortNthList(_n_)
			return This

		# Sorts the items inside the list at position n, in ascending order, in place.
		#
		#   _n_        the position of the list to sort
		#   returns    nothing; the content changes
		#   see        SortNthList
		def SortupNthList(_n_)
			This.SortNthList(_n_)

			def SortupNthListQ(_n_)
				return This.SortNthListQ(_n_)

		# Sorts the items inside the list at position n, in ascending order, in place.
		#
		#   _n_        the position of the list to sort
		#   returns    nothing; the content changes
		#   see        SortNthList
		def SortUpNthListInAscending(_n_)
			This.SortNthList(_n_)

			def SortUpNthListInAscendingQ(_n_)
				return This.SortNthListQ(_n_)

	# Returns a copy of the lists in which the list at position n is sorted ascending; the object is unchanged.
	#
	#   _n_        the position of the list to sort
	#   returns    a list of lists
	#   see        SortNthList
	def NthListSorted(_n_)
		_aNlsResult_ = This.Copy().SortNthListQ(_n_).Content() ### Fixed: was bad method name + missing arg + no return
		return _aNlsResult_

		def NthListSortedUp(_n_)
			return This.NthListSorted(_n_)

		def NthListSortedInAscending(_n_)
			return This.NthListSorted(_n_)

	  #----------------------------------#
	 #  SORTING NTH LIST IN DESCENDING  #
	#----------------------------------#

	# Raises error R13 today instead of sorting the list at position n in descending order, in place.
	#
	#   _n_        the position of the list to sort
	#   returns    nothing today
	#   warning    known defect: the body chains .Reversed() directly onto new stzList(...), which
	#              Ring answers with error R13
	#   see        SortNthList
	def SortDownNthList(_n_)
		_aSdnContent_ = This.Content()
		_aSdnSorted_ = new stzList(@SortList(_aSdnContent_[_n_])).Reversed()
		_aSdnContent_[_n_] = _aSdnSorted_

		This.UpdateWith(_aSdnContent_)


		def SortDownNthListQ(_n_)
			This.SortDownNthList(_n_)
			return This

		# Raises error R13 today instead of sorting the list at position n in descending order, in place.
		#
		#   _n_        the position of the list to sort
		#   returns    nothing today
		#   warning    known defect: it calls SortDownNthList, which raises error R13
		#   see        SortNthList
		def SortNthListInDescending(_n_)
			This.SortDownNthList(_n_)

			def SortNthListInDescendingQ(_n_)
				return This.SortNthListQ(_n_)

	# Raises error R13 today instead of returning a copy with the list at position n sorted descending.
	#
	#   _n_        the position of the list to sort
	#   returns    nothing today
	#   warning    known defect: it calls SortDownNthList, which raises error R13
	#   see        NthListSorted
	def NthListSortedDown(_n_)
		_aNlsdResult_ = This.Copy().SortDownNthListQ(_n_).Content()
		return _aNlsdResult_

		def NthListSortedInDescending(_n_)
			return This.NthListSortedDown(_n_)

	  #--------------------------------------------------------------------------#
	 #  CHECKING IF THE LIST OF LISTS IS SORTED IN ASCENDING ON THE NTH COLUMN  #
	#--------------------------------------------------------------------------#

	# TRUE if the first items of the lists are in ascending order.
	#
	#   returns    TRUE or FALSE
	#   see        IsSortedInAscendingOn, IsSortedInDescending
	def IsSortedInAscending()
		return This.IsSortedInAscendingOn(1)

		def IsSortedUp()
			return This.IsSortedInAscending()

		def IsSorted()
			return This.IsSortedInAscending()

	# TRUE if the items at position n of the lists are in ascending order.
	#
	#   _n_        the column position to test
	#   returns    TRUE or FALSE
	#   see        IsSortedInAscending
	def IsSortedInAscendingOn(_n_)
		_bIsaoResult_ = This.ColQ(_n_).IsSortedInAscending()
		return _bIsaoResult_

		def IsSortedUpOn(_n_)
			return This.IsSortedInAscendingOn(_n_)

		def IsSortedOn(_n_)
			return This.IsSortedInAscendingOn(_n_)

	  #---------------------------------------------------------------------------#
	 #  CHECKING IF THE LIST OF LISTS IS SORTED IN DESCENDING ON THE NTH COLUMN  #
	#---------------------------------------------------------------------------#

	# TRUE if the first items of the lists are in descending order.
	#
	#   returns    TRUE or FALSE
	#   see        IsSortedInDescendingOn, IsSortedInAscending
	def IsSortedInDescending()
		return This.IsSortedInDescendingOn(1)

		def IsSortedDown()
			return This.IsSortedInDescending()

	# TRUE if the items at position n of the lists are in descending order.
	#
	#   _n_        the column position to test
	#   returns    TRUE or FALSE
	#   see        IsSortedInDescending
	def IsSortedInDescendingOn(_n_)
		_bIsdoResult_ = This.ColQ(_n_).IsSortedInDescending()
		return _bIsdoResult_

		# TRUE if the items at position n of the lists are in descending order.
		#
		#   _n_        the column position to test
		#   returns    TRUE or FALSE
		#   see        IsSortedInDescendingOn
		def IsSortedDownOn(_n_)
			return This.IsSortedInDescendingOn(_n_) ### Fixed: was IsSortedInDescendingDown (nonexistent)

	  #----------------------------------#
	 #  SORTING THE LISTS IN ASCENDING  #
	#==================================#

	# Sorts the lists ascending by their first item, in place.
	#
	#   returns    nothing; the content changes
	#   see        Sorted, SortOn
	def Sort()
		This.SortOn(1)

		#< @FunctionFluentForm

		def SortQ()
			This.Sort()
			return This

		# Sorts the lists ascending by their first item, in place.
		#
		#   returns    nothing; the content changes
		#   see        Sort
		#>
		#< @FunctionAlternativeForms
		def SortInAscending()
			This.Sort()

			def SortInAscendingQ()
				return This.SortQ()

		# Sorts the lists ascending by their first item, in place.
		#
		#   returns    nothing; the content changes
		#   see        Sort
		#@ aka  --
		def SortUp()
			This.Sort()

			def SortUpQ()
				return This.SortQ()

	# Returns the lists sorted ascending by their first item; the object is unchanged.
	#
	#   returns    a list of lists
	#   see        Sort
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

	# Sorts the lists descending by their first item, in place.
	#
	#   returns    nothing; the content changes
	#   see        SortedDown, Sort
	def SortDown()
		This.SortOnDown(1)

		#< @FunctionFluentForm

		def SortDownQ()
			This.SortDown()
			return This

		# Sorts the lists descending by their first item, in place.
		#
		#   returns    nothing; the content changes
		#   see        SortDown
		#>
		#< @FunctionAlternativeForm
		def SortInDescending()
			This.SortDown()

			def SortInDescendingQ()
				return This.SortDownQ()

	# Returns the lists sorted descending by their first item; the object is unchanged.
	#
	#   returns    a list of lists
	#   see        SortDown
		#>
	def SortedDown()
		_aSdwResult_ = This.Copy().SortDownQ().Content()
		return _aSdwResult_

		def SortedInDescending()
			return This.SortedDown()

	  #-----------------------------------------------#
	 #  SORTING THE LIST OF LISTS ON A GIVEN COLUMN  #
	#===============================================#

	# Sorts the lists ascending by the item at position n, in place.
	#
	#   _n_        the column position to sort on
	#   returns    nothing; the content changes
	#   see        SortedOn, SortDownOn
	def SortOn(_n_)

		_aSoResult_ = @SortListsOn(This.Content(), _n_)

		This.UpdateWith(_aSoResult_)

		#< @FunctionFluentForm

		def SortOnQ(_n_)
			This.SortOn(_n_)
			return This

		# Sorts the lists ascending by the item at position n, in place.
		#
		#   _n_        the column position to sort on
		#   returns    nothing; the content changes
		#   see        SortOn
		#>
		#< @FunctionAlternativeForms
		def SortOnUp(_n_)
			This.SortOn(_n_)

			def SortOnUpQ(_n_)
				This.SortOn(_n_)
				return This

		# Sorts the lists ascending by the item at position n, in place.
		#
		#   _n_        the column position to sort on
		#   returns    nothing; the content changes
		#   see        SortOn
		def SortInAscendingOn(_n_)
			This.SortOn(_n_)

			def SortInAscendingOnQ(_n_)
				return This.SortOnQ(_n_)

	# Sorts the lists descending by the item at position n, in place.
	#
	#   _n_        the column position to sort on
	#   returns    nothing; the content changes
	#   see        SortDownOn
		#>
	#@ aka  SortOnDown / SortDescendingOn -- alias used by external narratives. Wraps SortDownOn which lives below.
	def SortOnDown(_n_)
		This.SortDownOn(_n_)

		def SortOnDownQ(_n_)
			This.SortDownOn(_n_)
			return This

	# Returns the lists sorted ascending by the item at position n; the object is unchanged.
	#
	#   _n_        the column position to sort on
	#   returns    a list of lists
	#   see        SortOn
	def SortedOn(_n_)
		_aSdoResult_ = This.Copy().SortOnQ(_n_).Content()

		return _aSdoResult_

		def SortedUpOn(_n_)
			return This.SortedOn(_n_)

		def SortedInAscendingOn(_n_)
			return This.SortedOn(_n_)

	  #-------------------------------------------------------------#
	 #  SORTING THE LIST OF LISTS IN DESCENDING ON A GIVEN COLUMN  #
	#-------------------------------------------------------------#

	# Sorts the lists descending by the item at position n, in place.
	#
	#   _n_        the column position to sort on
	#   returns    nothing; the content changes
	#   see        SortedDownOn, SortOn
	def SortDownOn(_n_)
		# Ring chaining `new stzList(x).Method()` parses ambiguously --
		# evaluate the construction first, then call the method.
		_oSdoTmp_ = new stzList( This.SortedOn(_n_) )
		_aSdoResult_ = _oSdoTmp_.Reversed()
		This.UpdateWith(_aSdoResult_)

		#< @FunctionFluentForm

		def SortDownOnQ(_n_)
			This.SortDownOn(_n_)
			return This

		# Sorts the lists descending by the item at position n, in place.
		#
		#   _n_        the column position to sort on
		#   returns    nothing; the content changes
		#   see        SortDownOn
		#>
		#< @FunctionAlternativeForms
		def SortInDescendingOn(_n_)
			This.SortDownOn(_n_) ### Fixed: was This.SortDown(n) -- missing On

			def SortInDescendingOnQ(_n_)
				return This.SortDownOnQ(_n_)

	# Returns the lists sorted descending by the item at position n; the object is unchanged.
	#
	#   _n_        the column position to sort on
	#   returns    a list of lists
	#   see        SortDownOn
		#>
	def SortedDownOn(_n_)
		_aSddoResult_ = This.Copy().SortDownOnQ(_n_).Content()

		return _aSddoResult_

		def SortedInDescendingOn(_n_)
			return This.SortedDownOn(_n_)

		# Word-order alias used by narrative tests: SortedOnDown(n)
		# == SortedDownOn(n) -- same descending sort on column n.
		def SortedOnDown(_n_)
			return This.SortedDownOn(_n_)

		def SortedOnUp(_n_)
			return This.SortedOn(_n_)

	  #---------------------------------------------------------------#
	 #  SORTING THE LISTS BY AN EVALUATED EXPRESSION - IN ASCENDING  #
	#===============================================================#
	# Sorts the lists in place by an expression evaluated on their first item, smallest first.
	#
	#   pcExpr     an expression on @item, the first item of each list
	#   returns    nothing; the content changes
	#   see        SortedBy, SortOnBy
	#@ aka  note Bu default the sorting is made by evaluating the first column
	def SortBy(pcExpr)
		This.SortOnBy(1, pcExpr)

		#< @FunctionFluentForm

		def SortByQ(pcExpr)
			This.SortBy(pcExpr)
			return This

		# Sorts the lists in place by an expression evaluated on their first item, smallest first.
		#
		#   pcExpr     an expression on @item, the first item of each list
		#   returns    nothing; the content changes
		#   see        SortBy
		#>
		#< @FunctionAlternativeForms
		def SortInAscendingBy(pcExpr)
			This.SortBy(pcExpr)

			def SortInAscendingByQ(pcExpr)
				return This.SortByQ(pcExpr)

		# Sorts the lists in place by an expression evaluated on their first item, smallest first.
		#
		#   pcExpr     an expression on @item, the first item of each list
		#   returns    nothing; the content changes
		#   see        SortBy
		def SortUpBy(pcExpr)
			This.SortBy(pcExpr)

			def SortUpByQ(pcExpr)
				return This.SortByQ(pcExpr)

	# Returns the lists sorted by an expression evaluated on their first item, smallest first; the object is unchanged.
	#
	#   pcExpr     an expression on @item, the first item of each list
	#   returns    a list of lists
	#   see        SortBy
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
 
	# Sorts the lists in place by an expression evaluated on their first item, largest first.
	#
	#   pcExpr     an expression on @item, the first item of each list
	#   returns    nothing; the content changes
	#   see        SortBy
	def SortInDescendingBy(pcExpr)
		This.SortInAscendingBy(pcExpr)
		This.Reverse()

		def SortInDescendingByQ(pcExpr)
			This.SortInDescendingBy(pcExpr)
			return This

		# Sorts the lists in place by an expression evaluated on their first item, largest first.
		#
		#   pcExpr     an expression on @item, the first item of each list
		#   returns    nothing; the content changes
		#   see        SortInDescendingBy
		def SortDownBy(pcExpr)
			This.SortInDescendingBy(pcExpr)

			def SortDownByQ(pcExpr)
				return This.SortInDescendingByQ(pcExpr)

	# Returns the lists sorted by an expression evaluated on their first item, largest first; the object is unchanged.
	#
	#   pcExpr     an expression on @item, the first item of each list
	#   returns    a list of lists
	#   see        SortedBy
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

	# Sorts the lists in place by an expression evaluated on the item at position n, smallest first.
	#
	#   nCol       the column position to evaluate on
	#   pcExpr     an expression on @item, the item at that position
	#   returns    nothing; the content changes
	#   see        SortedOnBy, SortBy
	def SortOnBy(nCol, pcExpr)

		_aSobContent_ = This.Content()
		_nSobLen_ = len(_aSobContent_)

		_aSobCol_ = This.Col(nCol)
		_nSobLenCol_ = len(_aSobCol_)

		_cSobCode_ = '_value_ = (' + _StzStripBraces(pcExpr) + ')'

		for @i = 1 to _nSobLenCol_
			@item = _aSobCol_[@i]
			eval(_cSobCode_)
			ring_insert(_aSobContent_[@i], 1, _value_)
		next

		This.UpdateWith( @SortLists(_aSobContent_) )
		This.RemoveCol(1)

		#< @FunctionFluentForm

		def SortOnByQ(nCol, pcExpr)
			This.SortOnBy(nCol, pcExpr) ### Fixed: was bare `ncol` lowercase (works in Ring case-insensitive but unsafe)
			return This

		# Sorts the lists in place by an expression evaluated on the item at position n, smallest first.
		#
		#   nCol       the column position to evaluate on
		#   pcExpr     an expression on @item, the item at that position
		#   returns    nothing; the content changes
		#   see        SortOnBy
		#>
		#< @FunctionAlternativeForms
		def SortInAscendingOnBy(nCol, pcExpr)
			This.SortOnBy(nCol, pcExpr)

			def SortInAscendingOnByQ(nCol, pcExpr)
				return This.SortOnByQ(nCol, pcExpr)

		# Sorts the lists in place by an expression evaluated on the item at position n, smallest first.
		#
		#   nCol       the column position to evaluate on
		#   pcExpr     an expression on @item, the item at that position
		#   returns    nothing; the content changes
		#   see        SortOnBy
		def SortUpOnBy(nCol, pcExpr)
			This.SortOnBy(nCol, pcExpr)

			def SortOnByUQ(nCol, pcExpr)
				return This.SortOnByQ(nCol, pcExpr)

	# Returns the lists sorted by an expression evaluated on the item at position n, smallest first; the object is unchanged.
	#
	#   nCol       the column position to evaluate on
	#   pcExpr     an expression on @item, the item at that position
	#   returns    a list of lists
	#   see        SortOnBy
		#>
	def SortedOnBy(nCol, pcExpr)
		_aSobdResult_ = This.Copy().SortOnByQ(nCol, pcExpr).Content()
		return _aSobdResult_

		def SortedInAscendingOnBy(nCol, pcExpr)
			return This.SortedOnBy(nCol, pcExpr)

		# Returns the lists sorted by an expression evaluated on the item at position n, smallest first; the object is unchanged.
		#
		#   nCol       the column position to evaluate on
		#   pcExpr     an expression on @item, the item at that position
		#   returns    a list of lists
		#   see        SortedOnBy
		def SortedUpOnBy(nCol, pcExpr)
			return This.SortedOnBy(nCol, pcExpr) ### Fixed: was SortedByOn (nonexistent)

	  #---------------------------------------------------------------------------------------#
	 #  SORTING THE LISTS BY AN EXPRESSION EVALUATED AGAINST A GIVEN COLUMN - IN DESCENDING  #
	#---------------------------------------------------------------------------------------#

	# Sorts the lists in place by an expression evaluated on the item at position n, largest first.
	#
	#   nCol       the column position to evaluate on
	#   pcExpr     an expression on @item, the item at that position
	#   returns    nothing; the content changes
	#   see        SortOnBy
	def SortInDescendingOnBy(nCol, pcExpr)
		This.SortInAscendingOnBy(nCol, pcExpr)
		This.Reverse()

		def SortInDescendingOnByQ(nCol, pcExpr)
			This.SortInDescendingOnBy(nCol, pcExpr)
			return This

		# Sorts the lists in place by an expression evaluated on the item at position n, largest first.
		#
		#   nCol       the column position to evaluate on
		#   pcExpr     an expression on @item, the item at that position
		#   returns    nothing; the content changes
		#   see        SortInDescendingOnBy
		def SortDownOnBy(nCol, pcExpr)
			This.SortInDescendingOnBy(nCol, pcExpr)

			def SortDownOnByQ(nCol, pcExpr)
				return This.SortInDescendingOnByQ(nCol, pcExpr)

	# Returns the lists sorted by an expression evaluated on the item at position n, largest first; the object is unchanged.
	#
	#   nCol       the column position to evaluate on
	#   pcExpr     an expression on @item, the item at that position
	#   returns    a list of lists
	#   see        SortedOnBy
	def SortedInDescendingOnBy(nCol, pcExpr)
		_aSidobResult_ = This.Copy().SortInDescendingOnByQ(nCol, pcExpr).Content()
		return _aSidobResult_

		def SortedDownOnBy(nCol, pcExpr)
			return This.SortedInDescendingOnBy(nCol, pcExpr)

	  #===========================================#
	 #  REMOVING DUPLICATES INSIDE THE NTH LIST  #
	#===========================================#

	# Removes the repeated items inside the list at position n, in place.
	#
	#   _n_        the position of the list to clean
	#   returns    nothing; the content changes
	#   note       the other lists are not touched
	#   see        RemoveDuplicatesInLists, DuplicatesInNthListRemoved
	def RemoveDuplicatesInNthList(_n_)
		_aRdnContent_ = This.Content()
		_aRdnContent_[_n_] = @WithoutDuplicates(_aRdnContent_[_n_])
		This.UpdateWith(_aRdnContent_)


		def RemoveDuplicatesInNthListQ(_n_)
			This.RemoveDuplicatesInNthList(_n_)
			return This ### Fixed: was bare `return` -- fluent form returned NULL

	# Returns a copy in which the list at position n has no repeated items; the object is unchanged.
	#
	#   _n_        the position of the list to clean
	#   returns    a list of lists
	#   see        RemoveDuplicatesInNthList
	def DuplicatesInNthListRemoved(_n_)
		_aDnrResult_ = This.Copy().RemoveDuplicatesInNthListQ(_n_).Content()
		return _aDnrResult_

		def WithoutDuplicatesInNthList(_n_)
			return This.DuplicatesInNthListRemoved(_n_)

		def WithoutDuplicationInNthList(_n_)
			return This.DuplicatesInNthListRemoved(_n_)

		def WithoutDuplicationsInNthList(_n_)
			return This.DuplicatesInNthListRemoved(_n_)

	  #--------------------------------------------#
	 #  REMOVING DUPLICATES INSIDE ALL THE LISTS  #
	#--------------------------------------------#

	# Removes the repeated items inside every list, in place.
	#
	#   returns    nothing; the content changes
	#   see        RemoveDuplicatesInNthList, DuplicatesInListsRemoved
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

	# Returns a copy in which no list has repeated items; the object is unchanged.
	#
	#   returns    a list of lists
	#   see        RemoveDuplicatesInLists
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

	# Raises error R14 today instead of grouping the other items under the distinct first items.
	#
	#   returns    nothing today
	#   warning    known defect: the body asks the first column for StringifyNamedObjectsQ, which
	#              does not exist, so the call raises error R14
	#   see        ClassifyOn
	#@ aka  NOTE Classification is performed on the first column by default ~> to make it on another column, use ClassifyOn(nCol)
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

				if StzFindFirst(_acClSeen_, _acClContent_[_iCl_]) = 0
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

	# Raises error R14 today instead of grouping the items under the distinct items of one column.
	#
	#   pnColNumber   the column position that gives the classes
	#   returns       nothing today
	#   warning       known defect: it moves the column first and then calls Classify, which raises
	#                 error R14
	#   see           Classify
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

	# Raises error R14 today instead of grouping the lists by the value of an expression on the first item.
	#
	#   pcExpr     an expression on @item, the first item of each list
	#   returns    nothing today
	#   warning    known defect: the call ends in Classify, which raises error R14
	#   see        Classify
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

	# Raises error R14 today instead of grouping the lists by the value of an expression on one column.
	#
	#   nCol       the column position to evaluate on
	#   pcExpr     an expression on @item, the item at that position
	#   returns    nothing today
	#   warning    known defect: the call ends in Classify, which raises error R14
	#   see        Classify
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

		_cCobCode_ = '_value_ = (' + _StzStripBraces(pcExpr) + ')'

		_aCobContent_ = This.Content()

		_aCobCol_ = This.Col(nCol)
		_nCobLenCol_ = len(_aCobCol_)

		for @i = 1 to _nCobLenCol_
			@item = _aCobCol_[@i]
			eval(_cCobCode_)
			ring_insert(_aCobContent_[@i], nCol, _value_)
		next

		_aCobResult_ = StzListOfListsQ(_aCobContent_).
				RemoveColQ(nCol+1).
				ClassifyOn(nCol)

		return _aCobResult_

	  #===============================================#
	 #  MOVING A COLUMN FROM A POSITION TO AN OTHER  #
	#===============================================#

	# Moves the column at position n1 to position n2 in every list that has both, in place.
	#
	#   _n1_       the column to move
	#   _n2_       the position it moves to
	#   returns    nothing; the content changes
	#   note       positions outside the columns, or equal, change nothing; lists too short for
	#              either are skipped
	#   see        ColMoved, SwapCols
	def MoveCol(_n1_, _n2_)

		if CheckingParams()
			if NOT (isNumber(_n1_) and isNumber(_n2_))
				StzRaise("Incorrect param type! n1 and n2 must be both numbers.")
			ok
		ok

		# Early checks

		if _n1_ = _n2_
			return
		ok

		_nMcCols_ = This.NumberOfCols()

		if _n1_ < 1 or _n1_ > _nMcCols_
			return
		ok

		if _n2_ < 1 or _n2_ > _nMcCols_
			return
		ok

		# Doing the job

		_aMcContent_ = This.Content()
		_nMcLen_ = len(_aMcContent_)

		for _iMc_ = 1 to _nMcLen_
			_nMcInner_ = len(_aMcContent_[_iMc_])
			if _n1_ <= _nMcInner_ and _n2_ <= _nMcInner_
				@Move(_aMcContent_[_iMc_], _n1_, _n2_)
			ok
		next

		This.UpdateWith(_aMcContent_)


		#< @FunctionFluentForm

		def MoveColQ(_n1_, _n2_)
			This.MoveCol(_n1_, _n2_)
			return This

		# Moves the column at position n1 to position n2 in every list that has both, in place.
		#
		#   _n1_       the column to move
		#   _n2_       the position it moves to
		#   returns    nothing; the content changes
		#   see        MoveCol
		#>
		#< @FunctionAlternativeForm
		def MoveColumn(_n1_, _n2_)
			This.MoveCol(_n1_, _n2_)

			def MoveColumnQ(_n1_, _n2_)
				return This.MoveColQ(_n1_, _n2_)

		# Moves the column at position n1 to position n2 in every list that has both, in place.
		#
		#   _n1_       the column to move
		#   _n2_       the position it moves to
		#   returns    nothing; the content changes
		#   see        MoveCol
		def MoveNthItems(_n1_, _n2_)
			This.MoveCol(_n1_, _n2_)

			def MoveNthItemsQ(_n1_, _n2_)
				return This.MoveColQ(_n1_, _n2_)

	# Returns a copy with the column at position n1 moved to position n2; the object is unchanged.
	#
	#   _n1_       the column to move
	#   _n2_       the position it moves to
	#   returns    a list of lists
	#   see        MoveCol
		#>
	def ColMoved(_n1_, _n2_)
		_aCmResult_ = This.Copy().MoveColQ(_n1_, _n2_).Content()
		return _aCmResult_

		def ColumnMoved(_n1_, _n2_)
			return This.ColMoved(_n1_, _n2_)

		def NthItemsMoved(_n1_, _n2_)
			return This.ColMoved(_n1_, _n2_)

	  #=============================================#
	 #  SWAPPING TWO COLUMNS IN THE LIST OF LISTS  #
	#=============================================#

	# Exchanges the columns at positions n1 and n2 in every list that has both, in place.
	#
	#   _n1_       the first column
	#   _n2_       the second column
	#   returns    nothing; the content changes
	#   note       positions outside the columns, or equal, change nothing; lists too short for
	#              either are skipped
	#   see        ColsSwapped, MoveCol
	def SwapCols(_n1_, _n2_)
		if CheckingParams()

			if isList(_n1_) and IsOneOfTheseNamedParamsList(_n1_, [
				:From, :FromPosition,
				:Between, :BetweenPosition, :BetweenPositions ])

				_n1_ = _n1_[2]
			ok

			if isList(_n2_) and IsOneOfTheseNamedParamsList(_n2_, [
				:To, :ToPosition, :And, :AndPosition ])

				_n2_ = _n2_[2] ### Fixed: was `n1 = n2[2]` -- assigned to wrong var, dropped n2 named-param unwrap
			ok

			if NOT (isNumber(_n1_) and isNumber(_n2_))
				StzRaise("Incorrect param type! n1 and n2 must be both numbers.")
			ok
		ok

		# Early checks

		if _n1_ = _n2_
			return
		ok

		_nScCols_ = This.NumberOfCols()

		if _n1_ < 1 or _n1_ > _nScCols_
			return
		ok

		if _n2_ < 1 or _n2_ > _nScCols_
			return
		ok

		# Doing the job

		_aScContent_ = This.Content()
		_nScLen_ = len(_aScContent_)

		for _iSc_ = 1 to _nScLen_
			_nScInner_ = len(_aScContent_[_iSc_])
			if _n1_ <= _nScInner_ and _n2_ <= _nScInner_
				# Inline swap -- ring_swap calls swap() which is shadowed
				# by user-defined func Swap(p1, p2) in stzFuncs.ring
				_scTmp_ = _aScContent_[_iSc_][_n1_]
				_aScContent_[_iSc_][_n1_] = _aScContent_[_iSc_][_n2_]
				_aScContent_[_iSc_][_n2_] = _scTmp_
			ok
		next

		This.UpdateWith(_aScContent_)


		#< @FunctionFluentForm

		def SwapColsQ(_n1_, _n2_)
			This.SwapCols(_n1_, _n2_)
			return This

		# Exchanges the columns at positions n1 and n2 in every list that has both, in place.
		#
		#   _n1_       the first column
		#   _n2_       the second column
		#   returns    nothing; the content changes
		#   see        SwapCols
		#>
		#< @FunctionAlternativeForms
		def SwapColumns(_n1_, _n2_)
			This.SwapCols(_n1_, _n2_)

			def SwapColumnsQ(_n1_, _n2_)
				return This.SwapColsQ(_n1_, _n2_)

		# Exchanges the columns at positions n1 and n2 in every list that has both, in place.
		#
		#   _n1_       the first column
		#   _n2_       the second column
		#   returns    nothing; the content changes
		#   see        SwapCols
		#@ aka  --
		def SwapNthItems(_n1_, _n2_)
			This.SwapCols(_n1_, _n2_)

			def SwapNthItemsQ(_n1_, _n2_)
				return This.SwapColsQ(_n1_, _n2_)

	# Returns a copy with the columns at positions n1 and n2 exchanged; the object is unchanged.
	#
	#   _n1_       the first column
	#   _n2_       the second column
	#   returns    a list of lists
	#   see        SwapCols
		#>
	def ColsSwapped(_n1_, _n2_)
		_aCsResult_ = This.Copy().SwapColsQ(_n1_, _n2_).Content() ### Fixed: was calling non-fluent SwapCols (returns NULL)
		return _aCsResult_

		def ColumnsSwapped(_n1_, _n2_)
			return This.ColsSwapped(_n1_, _n2_)

		def NthItemsSwapped(_n1_, _n2_)
			return This.ColsSwapped(_n1_, _n2_)

	  #===========================================#
	 #  INSERTING A COLUMN IN THE LIST OF LISTS  #
	#===========================================#

	# Inserts a new column before position n, one value per list, in place.
	#
	#   _n_         the position the new column takes
	#   paColData   the values, the first going to the first list
	#   returns     nothing; the content changes
	#   note        n must be an existing column, so nothing is appended after the last one; lists
	#               too short for n are skipped; missing values become empty text
	#   see         RemoveCol, AddCol
	def InsertCol(_n_, paColData)
		if CheckingParams()

			if NOT isList(paColData)
				StzRaise("Incorrect param type! paColData must be a list.")
			ok

			if isList(_n_) and Q(_n_).IsAtOrAtPositionNamedParams()
				_n_ = _n_[2]
			ok

			if NOT isNumber(_n_)
				StzRaise("Incorrect param type! n must be a number.")
			ok
		ok

		# Early check

		_nIcCols_ = This.NumberOfCols()

		if _n_ < 1 or _n_ > _nIcCols_
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

			if _n_ <= _nIcInner_
				ring_insert(_aIcContent_[_iIc_], _n_, _icItem_)
			ok

		next

		This.UpdateWith(_aIcContent_)


		#< @FunctionFluentForm

		def InsertColQ(_n_, paColData)
			This.InsertCol(_n_, paColData)
			return This

		# Inserts a new column before position n, one value per list, in place.
		#
		#   _n_         the position the new column takes
		#   paColData   the values, the first going to the first list
		#   returns     nothing; the content changes
		#   see         InsertCol
		#>
		#< @FunctionAlternativeForms
		def InsertItems(_n_, paColData)
			This.InsertCol(_n_, paColData)

			def InsertItemsQ(_n_, paColData)
				return This.InsertColQ(_n_, paColData)

		#>

	  #=================================================#
	 #  REMOVING A COLUMN FROM FROM THE LIST OF LISTS  #
	#=================================================#
	
	# Removes the item at position n from every list that has one, in place; nothing happens when n exceeds the NUMBER OF LISTS.
	#
	#   _n_        the column position to remove
	#   returns    nothing; the content changes
	#   warning    known defect: the early check compares n with the number of lists instead of the
	#              number of columns, so with 2 lists of 3 items RemoveCol(3) does nothing
	#   see        ColRemoved, RemoveCols
	def RemoveCol(_n_)
		if CheckingParams()
			if isList(_n_) and Q(_n_).IsAtOrAtPositionNamedParam()
				_n_ = _n_[2]
			ok

			if NOT isNumber(_n_)
				StzRaise("Incorrect param type! n must be a number.")
			ok
		ok

		# Early Check

		_aRcContent_ = This.Content()
		_nRcLen_ = len(_aRcContent_)

		if _n_ < 1 or _n_ > _nRcLen_
			return
		ok

		# Doing the job

		for _iRc_ = 1 to _nRcLen_
			_nRcInner_ = len(_aRcContent_[_iRc_])
			if _n_ <= _nRcInner_
				ring_remove(_aRcContent_[_iRc_], _n_)
			ok
		next

		This.UpdateWith(_aRcContent_)


		#< @FunctionFluentForm

		def RemoveColQ(_n_)
			This.RemoveCol(_n_)
			return This

		# Removes the item at position n from every list that has one, in place; nothing happens when n exceeds the NUMBER OF LISTS.
		#
		#   _n_        the column position to remove
		#   returns    nothing; the content changes
		#   warning    known defect: the early check compares n with the number of lists instead of
		#              the number of columns
		#   see        RemoveCol
		#>
		#< @FunctionAlternativeForms
		def RemoveNthCol(_n_)
			This.RemoveCol(_n_)

			def RemoveNthColQ(_n_)
				return This.RemoveColQ(_n_)

		# Removes the item at position n from every list that has one, in place; nothing happens when n exceeds the NUMBER OF LISTS.
		#
		#   _n_        the column position to remove
		#   returns    nothing; the content changes
		#   warning    known defect: the early check compares n with the number of lists instead of
		#              the number of columns
		#   see        RemoveCol
		def RemoveColumn(_n_)
			This.RemoveCol(_n_)

			def RemoveColumnQ(_n_)
				return This.RemoveColQ(_n_)

		# Removes the item at position n from every list that has one, in place; nothing happens when n exceeds the NUMBER OF LISTS.
		#
		#   _n_        the column position to remove
		#   returns    nothing; the content changes
		#   warning    known defect: the early check compares n with the number of lists instead of
		#              the number of columns
		#   see        RemoveCol
		def RemoveNthColumn(_n_)
			This.RemoveCol(_n_)

			def RemoveNthColumnQ(_n_)
				return This.RemoveColQ(_n_)

		# Removes the item at position n from every list that has one, in place; nothing happens when n exceeds the NUMBER OF LISTS.
		#
		#   _n_        the column position to remove
		#   returns    nothing; the content changes
		#   warning    known defect: the early check compares n with the number of lists instead of
		#              the number of columns
		#   see        RemoveCol
		def RemoveNthItems(_n_)
			This.RemoveCol(_n_)

			def RemoveNthItemsQ(_n_)
				return This.RemoveColQ(_n_)

	# Returns a copy without the column at position n; the object is unchanged, but the same early check applies.
	#
	#   _n_        the column position to remove
	#   returns    a list of lists
	#   warning    known defect: it calls RemoveCol, so n greater than the number of lists removes
	#              nothing
	#   see        RemoveCol
		#>
	def ColRemoved(_n_)
		_aCrResult_ = This.Copy().RemoveColQ(_n_).Content()
		return _aCrResult_

		#< @FunctionAlternativeForms

		def NthColRemoved(_n_)
			return This.ColRemoved(_n_)

		def ColumnRemoved(_n_)
			return This.ColRemoved(_n_)

		def NthColumnRemoved(_n_)
			return This.ColRemoved(_n_)

		def NthItemsRemoved(_n_)
			return This.ColRemoved(_n_)

		#>

	  #------------------------------------------------#
	 #  REMOVING MANY COLUMNS FROM THE LIST OF LISTS  #
	#------------------------------------------------#

	# Raises error R14 today instead of removing several columns at once, in place.
	#
	#   _anColNumbers_   the column positions to remove
	#   returns          nothing today
	#   warning          known defect: the argument check calls IsAtOrAtPositionsNamedParams, which
	#                    is defined nowhere, so the call raises error R14
	#   see              RemoveCol
	def RemoveCols(_anColNumbers_)
		if CheckingParams()
			if isList(_anColNumbers_) and Q(_anColNumbers_).IsAtOrAtPositionsNamedParams()
				_anColNumbers_ = _anColNumbers_[2]
			ok

			if NOT ( isList(_anColNumbers_) and @IsListOfNumbers(_anColNumbers_) )
				StzRaise("Incorrect param type! anColNumbers must be a list of numbers.")
			ok
		ok

		_aRcsContent_ = This.Content()
		_nRcsLen_ = len(_aRcsContent_)

		_oChain_ = new stzList(_anColNumbers_)

		_anColNumbers_ = _oChain_.Sorted()
		_nRcsLenCols_ = len(_anColNumbers_)

		for _iRcs_ = _nRcsLenCols_ to 1 step -1
			_nRcsN_ = _anColNumbers_[_iRcs_]
			for _jRcs_ = 1 to _nRcsLen_
				_nRcsInner_ = len(_aRcsContent_[_jRcs_])
				if _nRcsN_ <= _nRcsInner_
					ring_remove(_aRcsContent_[_jRcs_], _nRcsN_)
				ok
			next
		next

		This.UpdateWith(_aRcsContent_)


		#< @FunctionFluentForm

		def RemoveColsQ(_anColNumbers_)
			This.RemoveCols(_anColNumbers_)
			return This

		# Raises error R14 today instead of removing several columns at once, in place.
		#
		#   _anColNumbers_   the column positions to remove
		#   returns          nothing today
		#   warning          known defect: it calls RemoveCols, which raises error R14
		#   see              RemoveCol
		#>
		#< @FunctionAlternativeForms
		def RemoveTheseCols(_anColNumbers_)
			This.RemoveCols(_anColNumbers_)

			# Raises error R14 today instead of removing several columns and returning the object.
			#
			#   _anColNumbers_   the column positions to remove
			#   returns          nothing today
			#   note             a misspelling of RemoveTheseColsQ, kept as an alias
			#   warning          known defect: it calls RemoveColsQ, which raises error R14
			#   see              RemoveCol
			def RemoveTheseColqQ(_anColNumbers_)
				return This.RemoveColsQ(_anColNumbers_) ### Fixed: was passing bare `n` (undefined)

		# Raises error R14 today instead of removing several columns at once, in place.
		#
		#   _anColNumbers_   the column positions to remove
		#   returns          nothing today
		#   warning          known defect: it calls RemoveCols, which raises error R14
		#   see              RemoveCol
		def RemoveManyCols(_anColNumbers_)
			This.RemoveCols(_anColNumbers_)

			# Raises error R14 today instead of removing several columns and returning the object.
			#
			#   _anColNumbers_   the column positions to remove
			#   returns          nothing today
			#   note             a misspelling of RemoveManyColsQ, kept as an alias
			#   warning          known defect: it calls RemoveColsQ, which raises error R14
			#   see              RemoveCol
			def RemoveManyColqQ(_anColNumbers_)
				return This.RemoveColsQ(_anColNumbers_) ### Fixed: was bare `n` (undefined)

		# Raises error R14 today instead of removing several columns at once, in place.
		#
		#   _anColNumbers_   the column positions to remove
		#   returns          nothing today
		#   warning          known defect: it calls RemoveCols, which raises error R14
		#   see              RemoveCol
		def RemoveColumns(_anColNumbers_)
			This.RemoveCols(_anColNumbers_)

			def RemoveColumnsQ(_anColNumbers_)
				This.RemoveColumns(_anColNumbers_)
				return This

		# Raises error R14 today instead of removing several columns at once, in place.
		#
		#   _anColNumbers_   the column positions to remove
		#   returns          nothing today
		#   warning          known defect: it calls RemoveCols, which raises error R14
		#   see              RemoveCol
		def RemoveTheseColumns(_anColNumbers_)
			This.RemoveTheseCols(_anColNumbers_)

			def RemoveTheseColumnsQ(_anColNumbers_)
				return This.RemoveColsQ(_anColNumbers_) ### Fixed: was RemoveCoslQ (typo)

		# Raises error R14 today instead of removing several columns at once, in place.
		#
		#   _anColNumbers_   the column positions to remove
		#   returns          nothing today
		#   warning          known defect: it calls RemoveCols, which raises error R14
		#   see              RemoveCol
		def RemoveManyColumns(_anColNumbers_)
			This.RemoveTheseCols(_anColNumbers_)

			def RemoveManyColumnsQ(_anColNumbers_)
				return This.RemoveColsQ(_anColNumbers_) ### Fixed: was RemoveCoslQ (typo)
	
	# Raises error R14 today instead of returning a copy without several columns.
	#
	#   _anColNumbers_   the column positions to remove
	#   returns          nothing today
	#   warning          known defect: it calls RemoveCols, which raises error R14
	#   see              ColRemoved
		#>
	def ColsRemoved(_anColNumbers_)
		_aCrdResult_ = This.Copy().RemoveColsQ(_anColNumbers_).Content()
		return _aCrdResult_

		#< @FunctionAlternativeForms

		def TheseColsRemoved(_anColNumbers_)
			return This.ColsRemoved(_anColNumbers_)

		def ManyColsRemoved(_anColNumbers_)
			return This.ColsRemoved(_anColNumbers_)

		def ColumnsRemoved(_anColNumbers_)
			return This.ColsRemoved(_anColNumbers_)

		def ManyColumnsRemoved(_anColNumbers_)
			return This.ColsRemoved(_anColNumbers_)

		def TheseColumnsRemoved(_anColNumbers_)
			return This.ColsRemoved(_anColNumbers_)

		#>

	  #===========================================#
	 #  REPLACING A COLUMN IN THE LIST OF LISTS  #
	#===========================================#

	# Replaces the item at position n of every list that has one by the given values, one per list, in place.
	#
	#   _n_         the column position to replace
	#   paColData   the new values, the first going to the first list
	#   returns     nothing; the content changes
	#   note        n must be an existing column; missing values become empty text; lists too short
	#               for n are skipped
	#   see         InsertCol, ReplaceCols
	def ReplaceCol(_n_, paColData)

		if CheckingParams()
			if isList(paColData) and Q(paColData).IsWithOrByNamedParam()
				paColData = paColData[2]
			ok

			if NOT isList(paColData)
				StzRaise("Incorrect param type! paColData must be a list.")
			ok

			if isList(_n_) and Q(_n_).IsAtOrAtPositionNamedParams()
				_n_ = _n_[2]
			ok

			if NOT isNumber(_n_)
				StzRaise("Incorrect param type! n must be a number.")
			ok
		ok

		# Early check

		_nRpcCols_ = This.NumberOfCols()

		if _n_ < 1 or _n_ > _nRpcCols_
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

			if _n_ <= _nRpcInner_
				_aRpcContent_[_iRpc_][_n_] = _rpcItem_
			ok

		next

		This.UpdateWith(_aRpcContent_)


		#< @FunctionFluentForm

		def ReplaceColQ(_n_, paColData)
			This.ReplaceCol(_n_, paColData)
			return This

		# Replaces the item at position n of every list that has one by the given values, one per list, in place.
		#
		#   _n_         the column position to replace
		#   paColData   the new values, the first going to the first list
		#   returns     nothing; the content changes
		#   see         ReplaceCol
		#>
		#< @FunctionAlternativeForms
		def ReplaceItems(_n_, paColData)
			This.ReplaceCol(_n_, paColData)

			def ReplaceItemsQ(_n_, paColData)
				return This.ReplaceColQ(_n_, paColData)

		#>		

	  #-----------------------------------------------#
	 #  REPLACING MANY COLUMNS IN THE LIST OF LISTS  #
	#-----------------------------------------------#

	# Replaces several columns by the same values, one per list, in place.
	#
	#   panColNumbers   the column positions to replace
	#   paColData       the values every one of those columns receives
	#   returns         nothing; the content changes
	#   see             ReplaceCol
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
		
	# Returns the type name of the object, in lowercase.
	#
	#   returns    text, "stzlistoflists"
	#   see        ToStzList
	def stzType()
		return :stzListOfLists

	# Returns each list wrapped in a stzList.
	#
	#   returns    a list of stzList objects
	#   see        ToStzList
	def ToListOfStzLists()

		_aoTlsResult_ = []
		_nTlsLen_ = len(@aContent)

		for _iTls_ = 1 to _nTlsLen_
			@AddItem(_aoTlsResult_, new stzList(@aContent[_iTls_]))
		next

		return _aoTlsResult_

	# Returns each list written as text, in a plain list.
	#
	#   returns    a list of strings
	#   see        ToListOfStrings
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

	# Raises error R21 today instead of returning the lists written as one short text.
	#
	#   returns    nothing today
	#   warning    known defect: it concatenates the written lists with an operator that does not
	#              accept them, so the call raises error R21
	#   see        ToListsInString
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

	# Returns the lists as a stzList whose items are the lists.
	#
	#   returns    a stzList
	#   see        ToListOfStzLists, Copy
	def ToStzList()
		return new stzList( This.Content() )

	def ToStzListQ()
		return new stzList( This.Content() )

	# Returns each list written as text, in a plain list.
	#
	#   returns    a list of strings
	#   see        ToListsInString
	def ToListOfStrings() #TODO // Do we need it? compare with stzList.Stringified()
		_aTosResult_ = []
		_aTosLists_ = This.ListOfLists()
		_nTosLen_ = len(_aTosLists_)

		for _iTos_ = 1 to _nTosLen_
			@AddItem(_aTosResult_, @@( _aTosLists_[_iTos_] )) # @@ --> ComputableForm( list )
		next

		return _aTosResult_


	# TRUE if every list holds exactly two items.
	#
	#   returns    TRUE or FALSE
	#   see        ToStzListOfpairs
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

	# Returns the lists as a stzListOfPairs; raises an error unless every list is a pair.
	#
	#   returns    a stzListOfPairs
	#   note       raises an error when some list does not hold exactly two items
	#   see        IsListOfPairs
	def ToStzListOfpairs()
		if This.IsListOfPairs()
			return new stzListOfPairs(This.Content())
		else
			StzRaise("Can't transform the list of lists into a list of pairs! Lists are not all pairs.")
		ok

	# Raises error R11 today instead of returning the lists as a list of pairs of numbers.
	#
	#   returns    nothing today
	#   warning    known defect: the class stzListOfPairsOfNumbers is defined nowhere, so the call
	#              raises error R11
	#   see        ToStzListOfpairs
	def ToStzListOfpairsOfNumbers()
		if This.IsListOfPairsOfNumbers()
			return new stzListOfPairsOfNumbers(This.Content())
		else
			StzRaise("Can't transform the list of lists into a list of pairs of numbers! Lists are not all pairs of numbers.")
		ok

	  #--------------------------------------#
	 #  GETTING THE SPEEDUP OF THE NUMBERS  #
	#======================================#

	# Raises error R21 today instead of dividing the first number by the second.
	#
	#   returns    nothing today
	#   warning    known defect: the body treats the first two lists as numbers and divides them,
	#              which raises error R21
	#   see        GainFactor
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

	# Raises error R21 today instead of dividing the second number by the first.
	#
	#   returns    nothing today
	#   warning    known defect: the body treats the first two lists as numbers and divides them,
	#              which raises error R21
	#   see        SpeedUp
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

	# TRUE if every list of more than two items is made of consecutive numbers, or of consecutive chars.
	#
	#   returns    TRUE or FALSE
	#   note       lists of one or two items are not checked; a list mixing text and numbers raises
	#              an error
	#   see        IsListOfPairs
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
	
		# TRUE if every list of more than two items is made of consecutive numbers, or of consecutive chars.
		#
		#   paList     ignored
		#   returns    TRUE or FALSE
		#   note       the argument is not used
		#   see        AreContiguous
		#@ aka  --
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

	# Returns [ list position, [ start positions ] ] pairs for each list that holds the given items in a row.
	#
	#   paItems    the items to look for, at least two
	#   returns    a list of [ list position, start positions ] pairs
	#   note       the match is case-sensitive; fewer than two items raises an error
	#   see        FindInLists
	#@ aka  -- WITHOUT CASESENSITIVITY
	def FindSubList(paItems)
		return This.FindSubListCS(paItems, 1)

		def FindContiguousItems(paItems)
			return This.FindSubList(paItems)

	  #====================#
	 #  SORINT THE LISTS  #
	#====================#

	# Sorts the items inside every list, ascending, in place.
	#
	#   returns    nothing; the content changes
	#   see        ListsSorted, SortNthList
	def SortLists()
		_aSltContent_ = This.Content()
		_nSltLen_ = len(_aSltContent_)

		_aSltResult_ = []

		for _iSlt_ = 1 to _nSltLen_
			@AddItem(_aSltResult_, @Sort(_aSltContent_[_iSlt_]))
		next

		This.UpdateWith(_aSltResult_)

		# Sorts the items inside every list, ascending, in place, and returns the object for chaining.
		#
		#   returns    the object itself
		#   see        SortLists
		def SortListQ()
			This.SortLists()
			return This

	# Returns a copy with the items inside every list sorted ascending; the object is unchanged.
	#
	#   returns    a list of lists
	#   see        SortLists
	def ListsSorted()
		_aLsResult_ = This.Copy().SortListQ().Content()
		return _aLsResult_
