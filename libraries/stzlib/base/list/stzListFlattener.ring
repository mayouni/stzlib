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
			_n_aDfhTempLen_ = ring_len(_aDfhTemp_)
			for _jDfh_ = 1 to _n_aDfhTempLen_
				add(_aDfhResult_, _aDfhTemp_[_jDfh_])
			next
		else
			add(_aDfhResult_, paList[_iDfh_])
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
			_n_aFdhTempLen_ = ring_len(_aFdhTemp_)
			for _jFdh_ = 1 to _n_aFdhTempLen_
				add(_aFdhResult_, _aFdhTemp_[_jFdh_])
			next
		else
			add(_aFdhResult_, paList[_iFdh_])
		ok
	next
	return _aFdhResult_


  /////////////////
 ///   CLASS   ///
/////////////////

class stzListFlattener

	@oList

	  #===================#
	 #   INITIALIZATION  #
	#===================#

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

	def Content()
		return @oList.Content()

	def NumberOfItems()
		return @oList.NumberOfItems()

	def IsEmpty()
		return @oList.IsEmpty()

	def Copy()
		return new stzListFlattener( @oList.Content() )

	def Update(paNewContent)
		@oList.UpdateWith(paNewContent)

	def UpdateWith(paNewContent)
		@oList.UpdateWith(paNewContent)

	def List()
		return @oList.List()

	def ToSet()
		return UCS(This.Content(), 1)

	  #============================#
	 #     FLATTENING THE LIST    #
	#============================#

	def Flatten()
		_aFlContent_ = This.Content()
		_nFlLen_ = This.NumberOfItems()

		_aFlResult_ = []
		_aFlTemp_ = []

		for _iFl_ = 1 to _nFlLen_

			if isList(_aFlContent_[_iFl_])

				_aFlTemp_ = Q(_aFlContent_[_iFl_]).Flattened()
				_nFlLenTemp_ = ring_len(_aFlTemp_)

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

	def Flattened()
		_aFldResult_ = This.Copy().FlattenQ().Content()
		return _aFldResult_

	  #=======================================#
	 #     ASSOCIATE WITH AN ANOTHER LIST    #
	#=======================================#

	def AssociateWith(paOtherList)

		if NOT isList(paOtherList)
			StzRaise("Incorrect param type!")
		ok

		_aAwResult_ = []
		_nAwLen_  = This.NumberOfItems()
		_nAwLenOther_ = ring_len(paOtherList)

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

	def AssociatedWith(paOtherList)
		_aAwdResult_ = This.Copy().AssociateWithQ(paOtherList).Content()
		return _aAwdResult_

	  #===============================#
	 #     TYPE CONVERSION          #
	#===============================#

	def ToStzTable()
		return new stzTable( This.Content() )

	def ToStzGrid()
		return new stzGrid( This.Content() )

	def ToStzSet()
		return new stzSet( This.ToSet() )

	def ToStzListOfNumbers()
		return new stzListOfNumbers( This.Content() )

	def ToStzListOfLists()
		return new stzListOfLists(This.Content())

	def ToStzListOfPairs()
		return new stzListOfPairs(This.Content())

	def ToStzListOfStrings()
		return new stzListOfStrings(This.Content())

	def ToStzHashList()
		return new stzHashList( This.List() )

	  #=====================================#
	 #     STRINGIFYING THE LIST          #
	#=====================================#

	def Stringify()
		_aSfContent_ = This.Content()
		_nSfLen_ = ring_len(_aSfContent_)

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

	def HasRepeatedLeadingItemsCS(pCaseSensitive)
		_aHrlLead_ = This.RepeatedLeadingItemsCS(pCaseSensitive)

		if ring_len(_aHrlLead_) > 0
			return 1
		else
			return 0
		ok

		def HasLeadingItems()
			return This.HasRepeatedLeadingItemsCS(1)

	def RepeatedLeadingItemsCS(pCaseSensitive)
		_aRliContent_ = This.Content()
		_nRliLen_ = ring_len(_aRliContent_)

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

	def RepeatedLeadingItems()
		return This.RepeatedLeadingItemsCS(1)

	def HasRepeatedTrailingItemsCS(pCaseSensitive)
		_aHrtTrail_ = This.RepeatedTrailingItemsCS(pCaseSensitive)

		if ring_len(_aHrtTrail_) > 0
			return 1
		else
			return 0
		ok

	def RepeatedTrailingItemsCS(pCaseSensitive)
		_aRtiContent_ = This.Content()
		_nRtiLen_ = ring_len(_aRtiContent_)

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

	def RepeatedTrailingItems()
		return This.RepeatedTrailingItemsCS(1)

	  #=======================================#
	 #     DEEP FLATTENING THE LIST          #
	#=======================================#

	def DeepFlatten()
		_pDfList_ = @oList._EngineListFromContent()
		_pDfResult_ = StzEngineListDeepFlatten(_pDfList_)
		StzEngineListFree(_pDfList_)
		This.Update(StzEngineContentFromList(_pDfResult_))
		StzEngineListFree(_pDfResult_)

		def DeepFlattenQ()
			This.DeepFlatten()
			return This

	def DeepFlattened()
		_pDfdList_ = @oList._EngineListFromContent()
		_pDfdResult_ = StzEngineListDeepFlatten(_pDfdList_)
		StzEngineListFree(_pDfdList_)
		_aDfdResult_ = StzEngineContentFromList(_pDfdResult_)
		StzEngineListFree(_pDfdResult_)
		return _aDfdResult_

	  #=======================================#
	 #     FLATTENING TO A GIVEN DEPTH       #
	#=======================================#

	def FlattenToDepth(n)
		_pFtdList_ = @oList._EngineListFromContent()
		_pFtdResult_ = StzEngineListFlattenToDepth(_pFtdList_, n)
		StzEngineListFree(_pFtdList_)
		This.Update(StzEngineContentFromList(_pFtdResult_))
		StzEngineListFree(_pFtdResult_)

		def FlattenToDepthQ(n)
			This.FlattenToDepth(n)
			return This

	def FlattenedToDepth(n)
		_pFtddList_ = @oList._EngineListFromContent()
		_pFtddResult_ = StzEngineListFlattenToDepth(_pFtddList_, n)
		StzEngineListFree(_pFtddList_)
		_aFtddResult_ = StzEngineContentFromList(_pFtddResult_)
		StzEngineListFree(_pFtddResult_)
		return _aFtddResult_

	  #=======================================#
	 #     PAIRED (GROUP INTO PAIRS)         #
	#=======================================#

	def Paired()
		_pPdList_ = @oList._EngineListFromContent()
		_pPdResult_ = StzEngineListPaired(_pPdList_)
		StzEngineListFree(_pPdList_)
		_aPdResult_ = StzEngineContentFromList(_pPdResult_)
		StzEngineListFree(_pPdResult_)
		return _aPdResult_

	  #=======================================#
	 #     CHUNKED (GROUP INTO N-SIZE)       #
	#=======================================#

	def Chunked(n)
		_pCkList_ = @oList._EngineListFromContent()
		_pCkResult_ = StzEngineListChunked(_pCkList_, n)
		StzEngineListFree(_pCkList_)
		_aCkResult_ = StzEngineContentFromList(_pCkResult_)
		StzEngineListFree(_pCkResult_)
		return _aCkResult_

	  #=======================================#
	 #     INTERLEAVE WITH ANOTHER LIST      #
	#=======================================#

	def InterleavedWith(paOther)
		_aIwContent_ = This.Content()
		_nIwLen1_ = ring_len(_aIwContent_)
		_nIwLen2_ = ring_len(paOther)
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

	def Objectified()
		_aObContent_ = This.Content()
		_nObLen_ = ring_len(_aObContent_)
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
