#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTSPLITS              #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List splits subclass -- split operations.   #
#                  Engine-backed via stz_list_split_* C ABI.   #
#                  For aliases, use stzListSplitsXT.            #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzListSplits from stzObject

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
			StzRaise("Can't create stzListSplits! Parameter must be a list or stzList object.")
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

	  #========================================#
	 #    SPLITTING : THE GENERIC FUNCTION    #
	#========================================#

	def SplitCS(pItemOrPos, pCaseSensitive)

		if isList(pItemOrPos)

			if len(pItemOrPos) = 2 and isString(pItemOrPos[1]) and
			   ( pItemOrPos[1] = :At or
			     pItemOrPos[1] = :AtPosition )

				return This.SplitAtCS(pItemOrPos[2], pCaseSensitive)
			ok

			if len(pItemOrPos) = 2 and isString(pItemOrPos[1]) and
			   ( pItemOrPos[1] = :Before or
			     pItemOrPos[1] = :BeforePosition )

				return This.SplitBeforeCS(pItemOrPos[2], pCaseSensitive)
			ok

			if len(pItemOrPos) = 2 and isString(pItemOrPos[1]) and
			   ( pItemOrPos[1] = :After or
			     pItemOrPos[1] = :AfterPosition )

				return This.SplitAfterCS(pItemOrPos[2], pCaseSensitive)
			ok

		ok

		return This.SplitAtCS(pItemOrPos, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def Split(pItemOrPos)
		return This.SplitCS(pItemOrPos, 1)

		def SplitQ(pItemOrPos)
			This.Split(pItemOrPos)
			return This

	  #=====================================================#
	 #  SPLITTING AT POSITIONS -- THE FOUNDATIONAL METHOD  #
	#=====================================================#

	def SplitAtPositions(panPos)
		# Engine-backed: marshal list + positions, call split_at
		# INDEX_BASE=1: convert 1-based positions to 0-based for engine
		_aSapAdj_ = []
		_nPanPosLen_2 = len(panPos)
		for _iSap_ = 1 to _nPanPosLen_2
			_aSapAdj_ + (panPos[_iSap_] - 1)
		next

		_pSapList_ = StzEngineMarshalList(@oList.Content())
		_pSapPos_ = StzEngineMarshalList(_aSapAdj_)
		_pSapResult_ = StzEngineListSplitAt(_pSapList_, _pSapPos_)
		_aSapResult_ = StzEngineListContentToRingList(_pSapResult_)
		StzEngineListFree(_pSapResult_)
		StzEngineListFree(_pSapPos_)
		StzEngineListFree(_pSapList_)

		@oList.UpdateWith(_aSapResult_)

		def SplitAtPositionsQ(panPos)
			This.SplitAtPositions(panPos)
			return This

		def SplitAtThesePositions(panPos)
			This.SplitAtPositions(panPos)

			def SplitAtThesePositionsQ(panPos)
				This.SplitAtThesePositions(panPos)
				return This

	def SplittedAtPositions(panPos)
		# INDEX_BASE=1: convert to 0-based for engine
		_aSadAdj_ = []
		_nPanPosLen_ = len(panPos)
		for _iSad_ = 1 to _nPanPosLen_
			_aSadAdj_ + (panPos[_iSad_] - 1)
		next

		_pSadList_ = StzEngineMarshalList(@oList.Content())
		_pSadPos_ = StzEngineMarshalList(_aSadAdj_)
		_pSadResult_ = StzEngineListSplitAt(_pSadList_, _pSadPos_)
		_aSadResult_ = StzEngineListContentToRingList(_pSadResult_)
		StzEngineListFree(_pSadResult_)
		StzEngineListFree(_pSadPos_)
		StzEngineListFree(_pSadList_)

		return _aSadResult_

		def SplittedAtThesePositions(panPos)
			return This.SplittedAtPositions(panPos)

	  #======================================#
	 #  SPLITTING BEFORE A GIVEN POSITION   #
	#======================================#

	def SplitBeforePosition(_n_)
		# Engine-backed: stz_list_split_before
		_pSbpList_ = StzEngineMarshalList(@oList.Content())
		_pSbpResult_ = StzEngineListSplitBefore(_pSbpList_, _n_)
		_aSbpResult_ = StzEngineListContentToRingList(_pSbpResult_)
		StzEngineListFree(_pSbpResult_)
		StzEngineListFree(_pSbpList_)

		@oList.UpdateWith(_aSbpResult_)

		def SplitBeforePositionQ(_n_)
			This.SplitBeforePosition(_n_)
			return This

	def SplittedBeforePosition(_n_)
		_pSbdList_ = StzEngineMarshalList(@oList.Content())
		_pSbdResult_ = StzEngineListSplitBefore(_pSbdList_, _n_)
		_aSbdResult_ = StzEngineListContentToRingList(_pSbdResult_)
		StzEngineListFree(_pSbdResult_)
		StzEngineListFree(_pSbdList_)

		return _aSbdResult_

	  #===================================#
	 #  SPLITTING BEFORE A GIVEN ITEM    #
	#===================================#

	def SplitBeforeCS(pItem, pCaseSensitive)
		if isNumber(pItem)
			This.SplitBeforePosition(pItem)
		else
			_anSbcPos_ = @oList.FindAllCS(pItem, pCaseSensitive)
			if len(_anSbcPos_) > 0
				This.SplitAtPositions(_anSbcPos_)
			ok
		ok

		def SplitBeforeCSQ(pItem, pCaseSensitive)
			This.SplitBeforeCS(pItem, pCaseSensitive)
			return This

	def SplitBefore(pItem)
		return This.SplitBeforeCS(pItem, 1)

		def SplitBeforeQ(pItem)
			This.SplitBefore(pItem)
			return This

	  #=====================================#
	 #  SPLITTING AFTER A GIVEN POSITION   #
	#=====================================#

	def SplitAfterPosition(_n_)
		# Engine-backed: stz_list_split_after
		_pSfpList_ = StzEngineMarshalList(@oList.Content())
		_pSfpResult_ = StzEngineListSplitAfter(_pSfpList_, _n_)
		_aSfpResult_ = StzEngineListContentToRingList(_pSfpResult_)
		StzEngineListFree(_pSfpResult_)
		StzEngineListFree(_pSfpList_)

		@oList.UpdateWith(_aSfpResult_)

		def SplitAfterPositionQ(_n_)
			This.SplitAfterPosition(_n_)
			return This

	def SplittedAfterPosition(_n_)
		_pSfdList_ = StzEngineMarshalList(@oList.Content())
		_pSfdResult_ = StzEngineListSplitAfter(_pSfdList_, _n_)
		_aSfdResult_ = StzEngineListContentToRingList(_pSfdResult_)
		StzEngineListFree(_pSfdResult_)
		StzEngineListFree(_pSfdList_)

		return _aSfdResult_

	  #=================================#
	 #  SPLITTING AFTER A GIVEN ITEM   #
	#=================================#

	def SplitAfterCS(pItem, pCaseSensitive)
		if isNumber(pItem)
			This.SplitAfterPosition(pItem)
		else
			_anSacPos_ = @oList.FindAllCS(pItem, pCaseSensitive)
			if len(_anSacPos_) > 0
				# Split after the last occurrence found
				This.SplitAfterPosition(_anSacPos_[len(_anSacPos_)])
			ok
		ok

		def SplitAfterCSQ(pItem, pCaseSensitive)
			This.SplitAfterCS(pItem, pCaseSensitive)
			return This

	def SplitAfter(pItem)
		return This.SplitAfterCS(pItem, 1)

		def SplitAfterQ(pItem)
			This.SplitAfter(pItem)
			return This

	  #==================================#
	 #  SPLITTING AT A GIVEN POSITION   #
	#==================================#

	def SplitAtPosition(_n_)
		# "Split at position N" = split before position N
		This.SplitBeforePosition(_n_)

		def SplitAtPositionQ(_n_)
			This.SplitAtPosition(_n_)
			return This

	def SplittedAtPosition(_n_)
		return This.SplittedBeforePosition(_n_)

	  #================================#
	 #  SPLITTING AT A GIVEN ITEM     #
	#================================#

	def SplitAtCS(pItem, pCaseSensitive)
		if isNumber(pItem)
			This.SplitAtPosition(pItem)
		else
			_anSatPos_ = @oList.FindAllCS(pItem, pCaseSensitive)
			This.SplitAtPositions(_anSatPos_)
		ok

		def SplitAtCSQ(pItem, pCaseSensitive)
			This.SplitAtCS(pItem, pCaseSensitive)
			return This

	def SplitAt(pItem)
		return This.SplitAtCS(pItem, 1)

		def SplitAtQ(pItem)
			This.SplitAt(pItem)
			return This

	def SplittedAtCS(pItem, pCaseSensitive)
		if isNumber(pItem)
			return This.SplittedAtPosition(pItem)
		ok
		_anSadcPos_ = @oList.FindAllCS(pItem, pCaseSensitive)
		return This.SplittedAtPositions(_anSadcPos_)

	def SplittedAt(pItem)
		return This.SplittedAtCS(pItem, 1)

	  #==============================#
	 #  SPLITTING TO N EQUAL PARTS  #
	#==============================#

	def SplitToNParts(_n_)
		# Mutator form: divide into n parts (see SplittedToNParts).
		@oList.UpdateWith( This.SplittedToNParts(_n_) )

		def SplitToNPartsQ(_n_)
			This.SplitToNParts(_n_)
			return This

	def SplittedToNParts(_n_)
		# Divide the list into n parts of as-equal-as-possible size: the
		# documented "/ n -> n parts" contract ([1..6] -> [[1,2],[3,4],[5,6]],
		# 3 items / 3 -> [[a],[b],[c]]). The remainder is front-loaded -- the
		# first (len mod n) parts get one extra item (numpy array_split
		# convention). This is distinct from SplittedToPartsOfNItems, which
		# chunks by a fixed SIZE. The old ceil-chunk approximation produced
		# the wrong count when n was close to len (e.g. 7 items / 5).
		_nSndLen_ = This.NumberOfItems()
		if _n_ <= 0 or _nSndLen_ = 0
			return []
		ok
		_n_ = floor(_n_)
		_aSrc_ = @oList.Content()
		_aSndResult_ = []
		_nBase_ = floor(_nSndLen_ / _n_)
		_nRem_ = _nSndLen_ % _n_
		_iCur_ = 1
		for _iSp_ = 1 to _n_
			_nSz_ = _nBase_
			if _iSp_ <= _nRem_
				_nSz_ = _nSz_ + 1
			ok
			if _nSz_ = 0
				loop
			ok
			_aPart_ = []
			_iEnd_ = _iCur_ + _nSz_ - 1
			for _jSp_ = _iCur_ to _iEnd_
				_aPart_ + _aSrc_[_jSp_]
			next
			_aSndResult_ + _aPart_
			_iCur_ = _iEnd_ + 1
		next

		return _aSndResult_

	  #=================================#
	 #  SPLITTING TO PARTS OF N ITEMS  #
	#=================================#

	def SplitToPartsOfNItems(_n_)
		# Engine-backed: stz_list_split_to_parts_of_n
		_pSpnList_ = StzEngineMarshalList(@oList.Content())
		_pSpnResult_ = StzEngineListSplitToPartsOfN(_pSpnList_, _n_)
		_aSpnResult_ = StzEngineListContentToRingList(_pSpnResult_)
		StzEngineListFree(_pSpnResult_)
		StzEngineListFree(_pSpnList_)

		@oList.UpdateWith(_aSpnResult_)

		def SplitToPartsOfNItemsQ(_n_)
			This.SplitToPartsOfNItems(_n_)
			return This

		def SplitToPartsOf(_n_)
			This.SplitToPartsOfNItems(_n_)

			def SplitToPartsOfQ(_n_)
				This.SplitToPartsOf(_n_)
				return This

	def SplittedToPartsOfNItems(_n_)
		_pSpdList_ = StzEngineMarshalList(@oList.Content())
		_pSpdResult_ = StzEngineListSplitToPartsOfN(_pSpdList_, _n_)
		_aSpdResult_ = StzEngineListContentToRingList(_pSpdResult_)
		StzEngineListFree(_pSpdResult_)
		StzEngineListFree(_pSpdList_)

		return _aSpdResult_

		def SplittedToPartsOf(_n_)
			return This.SplittedToPartsOfNItems(_n_)

	  #===============================#
	 #  SPLITTING USING A CONDITION  #
	#===============================#

	def SplitW(pcCondition)
		_anSwPos_ = @oList.FindW(pcCondition)
		This.SplitAtPositions(_anSwPos_)

		def SplitWQ(pcCondition)
			This.SplitW(pcCondition)
			return This

	def SplittedW(pcCondition)
		_anSwdPos_ = @oList.FindW(pcCondition)
		return This.SplittedAtPositions(_anSwdPos_)

	# SplitW / SplittedW -- narrative-test aliases over the W form.



	# SplitAtW(pcCondition) -- split AT the positions where the
	# predicate is true (i.e. the matching elements become break
	# points). Same semantics as SplitW; aliased here for the
	# "SplitAt+W" spelling.
	def SplitAtW(pcCondition)
		This.SplitW(pcCondition)

		def SplitAtWQ(pcCondition)
			This.SplitAtW(pcCondition)
			return This

	  #===================================#
	 #  SPLITTING USING A GIVEN PACER    #
	#===================================#

	def SplitAtPacer(nPace, nStart)
		# Generate positions at the given pace
		_anPcrPos_ = []
		_nPcrLen_ = This.NumberOfItems()
		_iPcr_ = nStart
		while _iPcr_ <= _nPcrLen_
			_anPcrPos_ + _iPcr_
			_iPcr_ = _iPcr_ + nPace
		end

		This.SplitAtPositions(_anPcrPos_)

		def SplitAtPacerQ(nPace, nStart)
			This.SplitAtPacer(nPace, nStart)
			return This

	def SplittedAtPacer(nPace, nStart)
		_anSdpcrPos_ = []
		_nSdpcrLen_ = This.NumberOfItems()
		_iSdpcr_ = nStart
		while _iSdpcr_ <= _nSdpcrLen_
			_anSdpcrPos_ + _iSdpcr_
			_iSdpcr_ = _iSdpcr_ + nPace
		end

		return This.SplittedAtPositions(_anSdpcrPos_)

	# SplitAtCSZZ(pItem, pCaseSensitive): each split-section as [start, end].
	def SplitAtCSZZ(pItem, pCaseSensitive)
		_l_ = @oList.List()
		_nL_ = len(_l_)
		_aPos_ = []
		for _i_ = 1 to _nL_
			if BothAreEqualCS(_l_[_i_], pItem, pCaseSensitive) _aPos_ + _i_ ok
		next
		_aR_ = []
		_nPL_ = len(_aPos_)
		_prev_ = 0
		for _i_ = 1 to _nPL_
			_aR_ + [ _prev_ + 1, _aPos_[_i_] - 1 ]
			_prev_ = _aPos_[_i_]
		next
		_aR_ + [ _prev_ + 1, _nL_ ]
		return _aR_
