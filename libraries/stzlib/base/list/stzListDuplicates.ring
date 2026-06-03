#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTDUPLICATES          #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List duplicates subclass -- finding,        #
#                  removing, counting duplicates.               #
#                  For aliases, use stzListDuplicatesXT.        #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzListDuplicates

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
			StzRaise("Can't create stzListDuplicates! Parameter must be a list or stzList object.")
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
		return new stzListDuplicates( @oList.Content() )

	def UpdateWith(paNewContent)
		@oList.UpdateWith(paNewContent)

	def List()
		return @oList.List()

	def RemoveItemAtPosition(n)
		@oList.RemoveItemAtPosition(n)

	def FindAllCS(pItem, pCaseSensitive)
		return @oList.FindAllCS(pItem, pCaseSensitive)

	  #===============================#
	 #  FINDING DUPLICATED ITEMS    #
	#===============================#

	def FindDuplicatesCS(pCaseSensitive)
		_pFdList_ = @oList._EngineListFromContent()
		_cFdResult_ = StzEngineListFindDuplicatesCS(_pFdList_, pCaseSensitive)
		StzEngineListFree(_pFdList_)

		if _cFdResult_ = ""
			return []
		ok

		_aFdParts_ = StzSplit(_cFdResult_, ",")
		_nFdLen_ = ring_len(_aFdParts_)
		_anFdResult_ = []
		for _iFd_ = 1 to _nFdLen_
			@AddItem(_anFdResult_, 0 + _aFdParts_[_iFd_])
		next
		return _anFdResult_

	def FindDuplicates()
		return This.FindDuplicatesCS(1)

	  #===============================#
	 #  DUPLICATED ITEMS            #
	#===============================#

	def DuplicatedItemsCS(pCaseSensitive)
		_anDiPos_ = This.FindDuplicatesCS(pCaseSensitive)
		_aDiContent_ = This.Content()
		_nDiLen_ = ring_len(_anDiPos_)

		_aDiResult_ = []
		for _iDi_ = 1 to _nDiLen_
			@AddItem(_aDiResult_, _aDiContent_[_anDiPos_[_iDi_]])
		next

		return _aDiResult_

	def DuplicatedItems()
		return This.DuplicatedItemsCS(1)

	  #=====================================#
	 #  REMOVING DUPLICATES               #
	#=====================================#

	def RemoveDuplicatesCS(pCaseSensitive)
		# Engine-backed deduplication
		_pRdList_ = @oList._EngineListFromContent()
		StzEngineListRemoveDuplicatesCS(_pRdList_, pCaseSensitive)
		This.UpdateWith(@oList._ContentFromEngineList(_pRdList_))
		StzEngineListFree(_pRdList_)

		def RemoveDuplicatesCSQ(pCaseSensitive)
			This.RemoveDuplicatesCS(pCaseSensitive)
			return This

	def RemoveDuplicates()
		This.RemoveDuplicatesCS(1)

		def RemoveDuplicatesQ()
			This.RemoveDuplicates()
			return This

	  #=====================================#
	 #  WITHOUT DUPLICATION               #
	#=====================================#

	def WithoutDuplicationCS(pCaseSensitive)
		aResult = This.Copy().RemoveDuplicatesCSQ(pCaseSensitive).Content()
		return aResult

	def WithoutDuplication()
		return This.WithoutDuplicationCS(1)

		def WithoutDuplicates()
			return This.WithoutDuplication()

	  #=================================#
	 #  HAS DUPLICATES                #
	#=================================#

	def HasDuplicatesCS(pCaseSensitive)
		anPos = This.FindDuplicatesCS(pCaseSensitive)
		return ring_len(anPos) > 0

	def HasDuplicates()
		return This.HasDuplicatesCS(1)

		def ContainsDuplicates()
			return This.HasDuplicates()

		def ContainsDuplicatedItems()
			return This.HasDuplicates()

		def ContainsDuplicatedItemsCS(pCaseSensitive)
			return This.HasDuplicatesCS(pCaseSensitive)

	  #========================================#
	 #  NUMBER OF DUPLICATES                 #
	#========================================#

	def NumberOfDuplicatesCS(pCaseSensitive)
		return ring_len(This.FindDuplicatesCS(pCaseSensitive))

	def NumberOfDuplicates()
		return This.NumberOfDuplicatesCS(1)

	  #=================================================#
	 #  FINDING DUPLICATES OF A SPECIFIC ITEM          #
	#=================================================#

	def FindDuplicatesOfCS(pItem, pCaseSensitive)
		_anFdoPos_ = This.FindAllCS(pItem, pCaseSensitive)
		_nFdoLen_ = ring_len(_anFdoPos_)

		if _nFdoLen_ <= 1
			return []
		ok

		_aFdoResult_ = []
		for _iFdo_ = 2 to _nFdoLen_
			@AddItem(_aFdoResult_, _anFdoPos_[_iFdo_])
		next

		return _aFdoResult_

	def FindDuplicatesOf(pItem)
		return This.FindDuplicatesOfCS(pItem, 1)

	  #=================================================#
	 #  UNIQUE ITEMS (WITHOUT DUPLICATES)              #
	#=================================================#

	def UniqueItemsCS(pCaseSensitive)
		return This.WithoutDuplicationCS(pCaseSensitive)

	def UniqueItems()
		return This.UniqueItemsCS(1)

		def Unique()
			return This.UniqueItems()

	  #========================================#
	 #  FINDING NON DUPLICATED ITEMS         #
	#========================================#

	def FindNonDuplicatedItemsCS(pCaseSensitive)
		_pFndList_ = @oList._EngineListFromContent()
		_cFndResult_ = StzEngineListFindNonDuplicatedCS(_pFndList_, pCaseSensitive)
		StzEngineListFree(_pFndList_)

		if _cFndResult_ = ""
			return []
		ok

		_aFndParts_ = StzSplit(_cFndResult_, ",")
		_nFndLen_ = ring_len(_aFndParts_)
		_anFndResult_ = []
		for _iFnd_ = 1 to _nFndLen_
			@AddItem(_anFndResult_, 0 + _aFndParts_[_iFnd_])
		next
		return _anFndResult_

	def FindNonDuplicatedItems()
		return This.FindNonDuplicatedItemsCS(1)

	  #========================================#
	 #  NON DUPLICATED ITEMS                 #
	#========================================#

	def NonDuplicatedItemsCS(pCaseSensitive)
		_anNdiPos_ = This.FindNonDuplicatedItemsCS(pCaseSensitive)
		_aNdiContent_ = This.Content()
		_nNdiLen_ = ring_len(_anNdiPos_)
		_aNdiResult_ = []
		for _iNdi_ = 1 to _nNdiLen_
			@AddItem(_aNdiResult_, _aNdiContent_[_anNdiPos_[_iNdi_]])
		next
		return _aNdiResult_

	def NonDuplicatedItems()
		return This.NonDuplicatedItemsCS(1)

	  #========================================#
	 #  ITEMS DUPLICATED EXACTLY N TIMES     #
	#========================================#

	def ItemsDuplicatedNTimesCS(n, pCaseSensitive)
		_pIdnList_ = @oList._EngineListFromContent()
		_pIdnFreqs_ = StzEngineListFrequenciesCS(_pIdnList_, pCaseSensitive)
		StzEngineListFree(_pIdnList_)

		_aIdnRaw_ = StzEngineContentFromList(_pIdnFreqs_)
		StzEngineListFree(_pIdnFreqs_)

		_nIdnLen_ = ring_len(_aIdnRaw_)
		_aIdnResult_ = []
		_iIdn_ = 1
		for _kIdn_ = 1 to _nIdnLen_ / 2
			_cIdnKey_ = _aIdnRaw_[_iIdn_]
			_nIdnCount_ = _aIdnRaw_[_iIdn_ + 1]
			if _nIdnCount_ = n
				@AddItem(_aIdnResult_, _cIdnKey_)
			ok
			_iIdn_ += 2
		next
		return _aIdnResult_

	def ItemsDuplicatedNTimes(n)
		return This.ItemsDuplicatedNTimesCS(n, 1)

	  #========================================#
	 #  MOST DUPLICATED ITEM                 #
	#========================================#

	def MostDuplicatedItemCS(pCaseSensitive)
		_pMdiList_ = @oList._EngineListFromContent()
		_pMdiFreqs_ = StzEngineListFrequenciesCS(_pMdiList_, pCaseSensitive)
		StzEngineListFree(_pMdiList_)

		_aMdiRaw_ = StzEngineContentFromList(_pMdiFreqs_)
		StzEngineListFree(_pMdiFreqs_)

		_nMdiLen_ = ring_len(_aMdiRaw_)
		_nMdiMax_ = 0
		_cMdiResult_ = ""
		_iMdi_ = 1
		for _kMdi_ = 1 to _nMdiLen_ / 2
			_cMdiKey_ = _aMdiRaw_[_iMdi_]
			_nMdiCount_ = _aMdiRaw_[_iMdi_ + 1]
			if _nMdiCount_ > _nMdiMax_
				_nMdiMax_ = _nMdiCount_
				_cMdiResult_ = _cMdiKey_
			ok
			_iMdi_ += 2
		next
		return _cMdiResult_

	def MostDuplicatedItem()
		return This.MostDuplicatedItemCS(1)

	  #========================================#
	 #  REMOVE NTH DUPLICATE                 #
	#========================================#

	def RemoveNthDuplicateCS(n, pItem, pCaseSensitive)
		anPos = This.FindDuplicatesOfCS(pItem, pCaseSensitive)
		if n >= 1 and n <= ring_len(anPos)
			ring_remove(This.List(), anPos[n])
		ok

		def RemoveNthDuplicateCSQ(n, pItem, pCaseSensitive)
			This.RemoveNthDuplicateCS(n, pItem, pCaseSensitive)
			return This

	def RemoveNthDuplicate(n, pItem)
		This.RemoveNthDuplicateCS(n, pItem, 1)
