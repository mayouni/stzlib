#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTFLATTENER           #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List flattener subclass -- flattening,      #
#                  type conversion, associating operations.     #
#                  For aliases, use stzListFlattenerXT.         #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///  FUNCTIONS ///
/////////////////

func _DeepFlattenHelper(paList)
	# Recursive: Ring func locals are NOT shared across recursive
	# call frames in practice (verified empirically; the var rename
	# was sufficient -- save/restore not needed).
	_aDfhResult_ = []
	_nDfhLen_ = len(paList)
	for _iDfh_ = 1 to _nDfhLen_
		if isList(paList[_iDfh_])
			_aDfhTemp_ = _DeepFlattenHelper(paList[_iDfh_])
			_n_aDfhTempLen_ = len(_aDfhTemp_)
			for _jDfh_ = 1 to _n_aDfhTempLen_
				_aDfhResult_ + _aDfhTemp_[_jDfh_]
			next
		else
			_aDfhResult_ + paList[_iDfh_]
		ok
	next
	return _aDfhResult_

func _FlattenDepthHelper(paList, nDepth)
	if nDepth = 0
		return paList
	ok
	_aFdhResult_ = []
	_nFdhLen_ = len(paList)
	for _iFdh_ = 1 to _nFdhLen_
		if isList(paList[_iFdh_])
			_aFdhTemp_ = _FlattenDepthHelper(paList[_iFdh_], nDepth - 1)
			_n_aFdhTempLen_ = len(_aFdhTemp_)
			for _jFdh_ = 1 to _n_aFdhTempLen_
				_aFdhResult_ + _aFdhTemp_[_jFdh_]
			next
		else
			_aFdhResult_ + paList[_iFdh_]
		ok
	next
	return _aFdhResult_


  /////////////////
 ///   CLASS   ///
/////////////////

# Reshapes a list: opens nested lists, pairs and chunks the items, finds repeated ends, and hands the list to the typed list classes.
#
# A flattener is built over a list with new stzListFlattener(aList) or StzListFlattenerQ(aList);
# stzList has its own Flatten methods and does not build one. It works on its own copy, so the list
# you passed is never changed. The verbs (Flatten, DeepFlatten, FlattenToDepth, AssociateWith)
# reshape the held list in place and return nothing, the Q form returning the flattener so calls
# chain; the past-tense forms (Flattened, DeepFlattened, FlattenedToDepth, AssociatedWith) return
# the new list and leave the flattener alone. Read the held list with Content. Flatten and
# DeepFlatten open every level; FlattenToDepth opens only n levels. Paired, Chunked,
# InterleavedWith, Stringify and Objectified return a new list and never change the held one. The
# ToStz methods hand the content to the typed class named: ToStzGrid needs a pair [ columns, rows ]
# and raises an error for other content. The repeated-items methods return the copies after the
# first item (or before the last), so a run of three gives two. Text items of any script (Hebrew,
# Arabic, emoji) are kept whole.
#
#   receiver   o1 = new stzListFlattener([ 1, [ 2, [ 3, [ 4 ] ] ], "a" ])
#   example    ? @@( o1.Flattened() )
#              #--> [ 1, 2, 3, 4, "a" ]
#              ? @@( o1.FlattenedToDepth(1) )
#              #--> [ 1, 2, [ 3, [ 4 ] ], "a" ]
#              o2 = new stzListFlattener([ 1, 2, 2, 3, 3, 3 ])
#              ? @@( o2.Paired() )
#              #--> [ [ 1, 2 ], [ 2, 3 ], [ 3, 3 ] ]
#              ? @@( o2.RepeatedTrailingItems() )
#              #--> [ 3, 3 ]
#              o3 = new stzListFlattener([ "שלום", [ "مرحبا", [ "😀" ] ] ])
#              ? @@( o3.FlattenedToDepth(1) )
#              #--> [ "שלום", "مرحبا", [ "😀" ] ]
#   see        stzList, stzListSorter, stzListParser
class stzListFlattener from stzObject

	@oList

	  #===================#
	 #   INITIALIZATION  #
	#===================#

	# Builds a flattener over a list, given as a list or as a stzList object.
	#
	#   pListOrObj   the list to reshape, or a stzList whose content is copied, any other value
	#                raises an error
	#   returns      nothing; the object is built
	#   note         the flattener works on its own copy: editing it never changes the list or the
	#                stzList you passed in
	#   see          Content, Flattened
	def init(pListOrObj)
		if isList(pListOrObj)
			@oList = new stzList(pListOrObj)
		but isObject(pListOrObj)
			@oList = pListOrObj
		else
			StzRaise("Can't create stzListFlattener! Parameter must be a list or stzList object.")
		ok

	  #===============================#
	 #     CONTENT ACCESS            #
	#===============================#

	# Returns the list as it stands now, after the in-place edits made so far.
	#
	#   returns    a list
	#   see        NumberOfItems, Flattened
	def Content()
		return @oList.Content()

	# Returns how many items the list holds at its top level.
	#
	#   returns    a number
	#   note       a nested list counts as one item
	#   see        Content, IsEmpty
	def NumberOfItems()
		return @oList.NumberOfItems()

	# TRUE if the list holds no item.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   see        NumberOfItems, Content
	def IsEmpty()
		return @oList.IsEmpty()

	# Returns a new flattener over a copy of the list.
	#
	#   returns    a stzListFlattener
	#   note       editing the copy leaves this flattener alone
	#   see        Content, Flattened
	def Copy()
		return new stzListFlattener( @oList.Content() )

	# Replaces the list held by the flattener with another list.
	#
	#   paNewContent   the list that becomes the content
	#   returns        nothing; the content changes
	#   note           the same call as UpdateWith
	#   see            UpdateWith, Content
	def Update(paNewContent)
		@oList.UpdateWith(paNewContent)

	# Replaces the list held by the flattener with another list.
	#
	#   paNewContent   the list that becomes the content
	#   returns        nothing; the content changes
	#   see            Update, Content
	def UpdateWith(paNewContent)
		@oList.UpdateWith(paNewContent)

	# Returns the held list as a plain Ring list.
	#
	#   returns    a list
	#   see        Content
	def List()
		return @oList.List()

	# Returns the items without duplicates, keeping the order of first appearance.
	#
	#   returns    a list
	#   note       [ 1, 2, 2, 3, 3, 3 ] gives [ 1, 2, 3 ]
	#   see        ToStzSet
	def ToSet()
		return UCS(This.Content(), 1)

	  #============================#
	 #     FLATTENING THE LIST    #
	#============================#

	# Replaces the held list by its items with every nested list opened, however deep, in place.
	#
	#   returns    nothing; the content changes. FlattenQ returns the flattener for chaining
	#   note       it gives the same result as DeepFlatten
	#   see        Flattened, DeepFlatten, FlattenToDepth
	def Flatten()
		_aFlContent_ = This.Content()
		_nFlLen_ = This.NumberOfItems()

		_aFlResult_ = []
		_aFlTemp_ = []

		for _iFl_ = 1 to _nFlLen_

			if isList(_aFlContent_[_iFl_])

				_aFlTemp_ = Q(_aFlContent_[_iFl_]).Flattened()
				_nFlLenTemp_ = len(_aFlTemp_)

				for _jFl_ = 1 to _nFlLenTemp_
					@AddItem(_aFlResult_, _aFlTemp_[_jFl_])
				next
			else
				@AddItem(_aFlResult_, _aFlContent_[_iFl_])
			ok
		next

		This.Update(_aFlResult_)

		def FlattenQ()
			This.Flatten()
			return This

	# Returns the items with every nested list opened, however deep, leaving the flattener unchanged.
	#
	#   returns    a list
	#   note       [ 1, [ 2, [ 3 ] ] ] gives [ 1, 2, 3 ]; Hebrew, Arabic and emoji items are kept
	#              whole
	#   see        Flatten, DeepFlattened, FlattenedToDepth
	def Flattened()
		_aFldResult_ = This.Copy().FlattenQ().Content()
		return _aFldResult_

	  #=======================================#
	 #     ASSOCIATE WITH AN ANOTHER LIST    #
	#=======================================#

	# Pairs each item of the held list with the item at the same position of another list, in place.
	#
	#   paOtherList   the list whose items are paired in, a list that is too short pads the pairs
	#                 with an empty text, and extra items are dropped
	#   returns       nothing; the content changes. AssociateWithQ returns the flattener for
	#                 chaining
	#   note          an error is raised when paOtherList is not a list
	#   see           AssociatedWith, InterleavedWith
	def AssociateWith(paOtherList)

		if NOT isList(paOtherList)
			StzRaise("Incorrect param type!")
		ok

		_aAwResult_ = []
		_nAwLen_  = This.NumberOfItems()
		_nAwLenOther_ = len(paOtherList)

		_aAwContent_ = This.Content()

		for _iAw_ = 1 to _nAwLen_
			_otherAwItem_ = ""
			if _iAw_ <= _nAwLenOther_
				_otherAwItem_ = paOtherList[_iAw_]
			ok

			@AddItem(_aAwResult_, [ _aAwContent_[_iAw_], _otherAwItem_ ])
		next

		This.Update( _aAwResult_ )

		def AssociateWithQ(paOtherList)
			This.AssociateWith(paOtherList)
			return This

	# Returns the items of the held list each paired with the item at the same position of another list, leaving the flattener unchanged.
	#
	#   paOtherList   the list whose items are paired in, extra items are dropped
	#   returns       a list of [ item, other item ] pairs; an empty text stands for a missing other
	#                 item
	#   note          [ x, y, z ] with [ 1, 2 ] gives [ x, 1 ], [ y, 2 ], [ z, "" ]
	#   see           AssociateWith, InterleavedWith
	def AssociatedWith(paOtherList)
		_aAwdResult_ = This.Copy().AssociateWithQ(paOtherList).Content()
		return _aAwdResult_

	  #===============================#
	 #     TYPE CONVERSION          #
	#===============================#

	# Builds a stzTable from the held list: the first row names the columns and the rows after it fill them.
	#
	#   returns    a stzTable
	#   note       [ [ NAME, AGE ], [ Ann, 30 ], [ Bob, 25 ] ] gives a table with the columns NAME
	#              and AGE
	#   see        ToStzListOfLists, ToStzHashList
	def ToStzTable()
		return new stzTable( This.Content() )

	# Builds a stzGrid whose size is the held list, which must be a pair [ columns, rows ] of numbers.
	#
	#   returns    a stzGrid
	#   note       an error is raised for any other content, such as a list of lists; the grid holds
	#              no data of its own
	#   see        ToStzTable
	def ToStzGrid()
		return new stzGrid( This.Content() )

	# Builds a stzSet from the held list, dropping duplicates.
	#
	#   returns    a stzSet
	#   note       [ 3, 1, 2, 2 ] gives the set 3, 1, 2
	#   see        ToSet
	def ToStzSet()
		return new stzSet( This.ToSet() )

	# Builds a stzListOfNumbers over the held list.
	#
	#   returns    a stzListOfNumbers
	#   note       the content is passed as it is
	#   see        ToStzListOfStrings, ToStzListOfLists
	def ToStzListOfNumbers()
		return new stzListOfNumbers( This.Content() )

	# Builds a stzListOfLists over the held list.
	#
	#   returns    a stzListOfLists
	#   note       the content is passed as it is
	#   see        ToStzListOfPairs, ToStzTable
	def ToStzListOfLists()
		return new stzListOfLists(This.Content())

	# Builds a stzListOfPairs over the held list.
	#
	#   returns    a stzListOfPairs
	#   note       the content is passed as it is
	#   see        ToStzListOfLists, ToStzHashList
	def ToStzListOfPairs()
		return new stzListOfPairs(This.Content())

	# Builds a stzListOfStrings over the held list.
	#
	#   returns    a stzListOfStrings
	#   note       the content is passed as it is
	#   see        ToStzListOfNumbers
	def ToStzListOfStrings()
		return new stzListOfStrings(This.Content())

	# Builds a stzHashList from the held list of [ key, value ] pairs.
	#
	#   returns    a stzHashList
	#   note       [ [ a, 1 ], [ b, 2 ] ] gives the hash list a to 1, b to 2
	#   see        ToStzListOfPairs
	def ToStzHashList()
		return new stzHashList( This.List() )

	  #=====================================#
	 #     STRINGIFYING THE LIST          #
	#=====================================#

	# Returns each item written as text, the way @@ writes it, in a list.
	#
	#   returns    a list of texts, one per item
	#   note       a text item keeps its double quotes in the result and a nested list becomes its
	#              bracketed text, so [ 1, "a", [ 2, 3 ] ] gives [ "1", "\"a\"", "[ 2, 3 ]" ];
	#              Stringified is the same call
	#   see        Objectified
	def Stringify()
		_aSfContent_ = This.Content()
		_nSfLen_ = len(_aSfContent_)

		_acSfResult_ = []
		for _iSf_ = 1 to _nSfLen_
			@AddItem(_acSfResult_, @@(_aSfContent_[_iSf_]))
		next

		return _acSfResult_

		def Stringified()
			return This.Stringify()

	  #=======================================#
	 #     REPEATED LEADING/TRAILING ITEMS  #
	#=======================================#

	# TRUE if the first item occurs again right after itself, comparing with or without case.
	#
	#   pCaseSensitive   1 to compare with case, 0 to ignore it
	#   returns          TRUE or FALSE, as 1 or 0
	#   note             [ A, a, a, b ] is TRUE with 0 and FALSE with 1
	#   see              RepeatedLeadingItems, HasRepeatedTrailingItemsCS
	def HasRepeatedLeadingItemsCS(pCaseSensitive)
		_aHrlLead_ = This.RepeatedLeadingItemsCS(pCaseSensitive)

		if len(_aHrlLead_) > 0
			return 1
		else
			return 0
		ok

		# TRUE if the first item occurs again right after itself, comparing with case.
		#
		#   returns    TRUE or FALSE, as 1 or 0
		#   note       the name says leading items, but it asks whether the first item is repeated,
		#              as HasRepeatedLeadingItemsCS(1) does
		#   see        HasRepeatedLeadingItemsCS, RepeatedLeadingItems
		def HasLeadingItems()
			return This.HasRepeatedLeadingItemsCS(1)

	def RepeatedLeadingItemsCS(pCaseSensitive)
		_aRliContent_ = This.Content()
		_nRliLen_ = len(_aRliContent_)

		if _nRliLen_ <= 1
			return []
		ok

		_cRliFirst_ = @@(_aRliContent_[1])
		if pCaseSensitive = 0
			_cRliFirst_ = StzLower(_cRliFirst_)
		ok

		_aRliResult_ = []
		for _iRli_ = 2 to _nRliLen_
			_cRliItem_ = @@(_aRliContent_[_iRli_])
			if pCaseSensitive = 0
				_cRliItem_ = StzLower(_cRliItem_)
			ok

			if _cRliItem_ = _cRliFirst_
				@AddItem(_aRliResult_, _aRliContent_[_iRli_])
			else
				exit
			ok
		next

		return _aRliResult_

	# Returns the copies of the first item that follow it directly, not counting the first itself.
	#
	#   returns    a list; empty when the first item is not repeated or the list has one item
	#   note       [ 7, 7, 7 ] gives [ 7, 7 ], two copies for a run of three; RepeatedLeadingItemsCS
	#              takes the case flag; items are compared as written text, so nested lists can
	#              repeat too
	#   see        HasRepeatedLeadingItemsCS, RepeatedTrailingItems
	def RepeatedLeadingItems()
		return This.RepeatedLeadingItemsCS(1)

	# TRUE if the last item occurs again right before itself, comparing with or without case.
	#
	#   pCaseSensitive   1 to compare with case, 0 to ignore it
	#   returns          TRUE or FALSE, as 1 or 0
	#   note             [ b, A, a ] is TRUE with 0 and FALSE with 1
	#   see              RepeatedTrailingItems, HasRepeatedLeadingItemsCS
	def HasRepeatedTrailingItemsCS(pCaseSensitive)
		_aHrtTrail_ = This.RepeatedTrailingItemsCS(pCaseSensitive)

		if len(_aHrtTrail_) > 0
			return 1
		else
			return 0
		ok

	def RepeatedTrailingItemsCS(pCaseSensitive)
		_aRtiContent_ = This.Content()
		_nRtiLen_ = len(_aRtiContent_)

		if _nRtiLen_ <= 1
			return []
		ok

		_cRtiLast_ = @@(_aRtiContent_[_nRtiLen_])
		if pCaseSensitive = 0
			_cRtiLast_ = StzLower(_cRtiLast_)
		ok

		_aRtiResult_ = []
		for _iRti_ = _nRtiLen_ - 1 to 1 step -1
			_cRtiItem_ = @@(_aRtiContent_[_iRti_])
			if pCaseSensitive = 0
				_cRtiItem_ = StzLower(_cRtiItem_)
			ok

			if _cRtiItem_ = _cRtiLast_
				@AddItem(_aRtiResult_, _aRtiContent_[_iRti_])
			else
				exit
			ok
		next

		_oRtiTemp_ = new stzList(_aRtiResult_)
		_pRtiTmp_ = _oRtiTemp_._EngineListFromContent()
		StzEngineListReverse(_pRtiTmp_)
		_aRtiReversed_ = _oRtiTemp_._ContentFromEngineList(_pRtiTmp_)
		StzEngineListFree(_pRtiTmp_)
		return _aRtiReversed_

	# Returns the copies of the last item that stand directly before it, not counting the last itself.
	#
	#   returns    a list; empty when the last item is not repeated or the list has one item
	#   note       [ 1, 2, 2, 3, 3, 3 ] gives [ 3, 3 ]; RepeatedTrailingItemsCS takes the case flag
	#   see        HasRepeatedTrailingItemsCS, RepeatedLeadingItems
	def RepeatedTrailingItems()
		return This.RepeatedTrailingItemsCS(1)

	  #=======================================#
	 #     DEEP FLATTENING THE LIST          #
	#=======================================#

	# Replaces the held list by its items with every nested list opened, however deep, in place.
	#
	#   returns    nothing; the content changes. DeepFlattenQ returns the flattener for chaining
	#   see        DeepFlattened, Flatten, FlattenToDepth
	def DeepFlatten()
		_pDfList_ = @oList._EngineListFromContent()
		_pDfResult_ = StzEngineListDeepFlatten(_pDfList_)
		StzEngineListFree(_pDfList_)
		This.Update(StzEngineListContentToRingList(_pDfResult_))
		StzEngineListFree(_pDfResult_)

		def DeepFlattenQ()
			This.DeepFlatten()
			return This

	# Returns the items with every nested list opened, however deep, leaving the flattener unchanged.
	#
	#   returns    a list
	#   note       [ 1, [ 2, [ 3, [ 4 ] ] ] ] gives [ 1, 2, 3, 4 ]
	#   see        DeepFlatten, FlattenedToDepth
	def DeepFlattened()
		_pDfdList_ = @oList._EngineListFromContent()
		_pDfdResult_ = StzEngineListDeepFlatten(_pDfdList_)
		StzEngineListFree(_pDfdList_)
		_aDfdResult_ = StzEngineListContentToRingList(_pDfdResult_)
		StzEngineListFree(_pDfdResult_)
		return _aDfdResult_

	  #=======================================#
	 #     FLATTENING TO A GIVEN DEPTH       #
	#=======================================#

	# Opens the nested lists down to a given number of levels only, in place.
	#
	#   n          how many levels of nesting to open, 0 changes nothing
	#   returns    nothing; the content changes. FlattenToDepthQ returns the flattener for chaining
	#   note       1 opens the lists that sit directly in the list: [ 1, [ 2, [ 3 ] ] ] becomes [ 1,
	#              2, [ 3 ] ]
	#   see        FlattenedToDepth, DeepFlatten
	def FlattenToDepth(n)
		_pFtdList_ = @oList._EngineListFromContent()
		_pFtdResult_ = StzEngineListFlattenToDepth(_pFtdList_, n)
		StzEngineListFree(_pFtdList_)
		This.Update(StzEngineListContentToRingList(_pFtdResult_))
		StzEngineListFree(_pFtdResult_)

		def FlattenToDepthQ(n)
			This.FlattenToDepth(n)
			return This

	# Returns the items with the nested lists opened down to a given number of levels, leaving the flattener unchanged.
	#
	#   n          how many levels of nesting to open, 0 returns the content as it is
	#   returns    a list
	#   note       with 2 the list [ 1, [ 2, [ 3, [ 4 ] ] ] ] gives [ 1, 2, 3, [ 4 ] ]
	#   see        FlattenToDepth, DeepFlattened
	def FlattenedToDepth(n)
		_pFtddList_ = @oList._EngineListFromContent()
		_pFtddResult_ = StzEngineListFlattenToDepth(_pFtddList_, n)
		StzEngineListFree(_pFtddList_)
		_aFtddResult_ = StzEngineListContentToRingList(_pFtddResult_)
		StzEngineListFree(_pFtddResult_)
		return _aFtddResult_

	  #=======================================#
	 #     PAIRED (GROUP INTO PAIRS)         #
	#=======================================#

	# Returns the items grouped in consecutive pairs, the last pair holding one item when the count is odd.
	#
	#   returns    a list of pairs; the last may hold a single item
	#   note       [ 1, 2, 2, 3, 3, 3 ] gives [ 1, 2 ], [ 2, 3 ], [ 3, 3 ]; [ 1, 2, 3, 4, 5 ] ends
	#              with [ 5 ]; the pairs do not overlap
	#   see        Chunked, AssociatedWith
	def Paired()
		_pPdList_ = @oList._EngineListFromContent()
		_pPdResult_ = StzEngineListPaired(_pPdList_)
		StzEngineListFree(_pPdList_)
		_aPdResult_ = StzEngineListContentToRingList(_pPdResult_)
		StzEngineListFree(_pPdResult_)
		return _aPdResult_

	  #=======================================#
	 #     CHUNKED (GROUP INTO N-SIZE)       #
	#=======================================#

	# Returns the items cut into consecutive groups of n, the last group holding what is left.
	#
	#   n          the size of each group
	#   returns    a list of lists; an empty list when n is 0
	#   note       n larger than the list gives one group holding everything
	#   see        Paired, InterleavedWith
	def Chunked(n)
		_pCkList_ = @oList._EngineListFromContent()
		_pCkResult_ = StzEngineListChunked(_pCkList_, n)
		StzEngineListFree(_pCkList_)
		_aCkResult_ = StzEngineListContentToRingList(_pCkResult_)
		StzEngineListFree(_pCkResult_)
		return _aCkResult_

	  #=======================================#
	 #     INTERLEAVE WITH ANOTHER LIST      #
	#=======================================#

	# Returns the items of the held list and of another list taken alternately, starting with the held list.
	#
	#   paOther    the list whose items alternate with the held ones, the surplus of the longer list
	#              is appended
	#   returns    a list
	#   note       [ a ] with [ 1, 2, 3 ] gives [ a, 1, 2, 3 ]
	#   see        AssociatedWith, Paired
	def InterleavedWith(paOther)
		_aIwContent_ = This.Content()
		_nIwLen1_ = len(_aIwContent_)
		_nIwLen2_ = len(paOther)
		_nIwMax_ = _nIwLen1_
		if _nIwLen2_ > _nIwMax_
			_nIwMax_ = _nIwLen2_
		ok

		_aIwResult_ = []
		for _iIw_ = 1 to _nIwMax_
			if _iIw_ <= _nIwLen1_
				@AddItem(_aIwResult_, _aIwContent_[_iIw_])
			ok
			if _iIw_ <= _nIwLen2_
				@AddItem(_aIwResult_, paOther[_iIw_])
			ok
		next

		return _aIwResult_

	  #=======================================#
	 #     OBJECTIFIED (ITEMS AS OBJECTS)    #
	#=======================================#

	# Returns the items as objects: a text as a stzString, a number as a stzNumber and a list as a stzList.
	#
	#   returns    a list of objects; any other item is kept as it is
	#   see        Stringify, Flattened
	def Objectified()
		_aObContent_ = This.Content()
		_nObLen_ = len(_aObContent_)
		_aoObResult_ = []

		for _iOb_ = 1 to _nObLen_
			if isString(_aObContent_[_iOb_])
				@AddItem(_aoObResult_, new stzString(_aObContent_[_iOb_]))
			but isNumber(_aObContent_[_iOb_])
				@AddItem(_aoObResult_, new stzNumber(_aObContent_[_iOb_]))
			but isList(_aObContent_[_iOb_])
				@AddItem(_aoObResult_, new stzList(_aObContent_[_iOb_]))
			else
				@AddItem(_aoObResult_, _aObContent_[_iOb_])
			ok
		next

		return _aoObResult_
