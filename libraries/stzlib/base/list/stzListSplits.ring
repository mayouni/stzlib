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

class stzListSplits

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

			if ring_len(pItemOrPos) = 2 and isString(pItemOrPos[1]) and
			   ( pItemOrPos[1] = :At or
			     pItemOrPos[1] = :AtPosition )

				return This.SplitAtCS(pItemOrPos[2], pCaseSensitive)
			ok

			if ring_len(pItemOrPos) = 2 and isString(pItemOrPos[1]) and
			   ( pItemOrPos[1] = :Before or
			     pItemOrPos[1] = :BeforePosition )

				return This.SplitBeforeCS(pItemOrPos[2], pCaseSensitive)
			ok

			if ring_len(pItemOrPos) = 2 and isString(pItemOrPos[1]) and
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
		_nPanPosLen_2 = ring_len(panPos)
		for _iSap_ = 1 to _nPanPosLen_2
			_aSapAdj_ + (panPos[_iSap_] - 1)
		next

		_pSapList_ = StzEngineMarshalList(@oList.Content())
		_pSapPos_ = StzEngineMarshalList(_aSapAdj_)
		_pSapResult_ = StzEngineListSplitAt(_pSapList_, _pSapPos_)
		_aSapResult_ = StzEngineContentFromList(_pSapResult_)
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
		_nPanPosLen_ = ring_len(panPos)
		for _iSad_ = 1 to _nPanPosLen_
			_aSadAdj_ + (panPos[_iSad_] - 1)
		next

		_pSadList_ = StzEngineMarshalList(@oList.Content())
		_pSadPos_ = StzEngineMarshalList(_aSadAdj_)
		_pSadResult_ = StzEngineListSplitAt(_pSadList_, _pSadPos_)
		_aSadResult_ = StzEngineContentFromList(_pSadResult_)
		StzEngineListFree(_pSadResult_)
		StzEngineListFree(_pSadPos_)
		StzEngineListFree(_pSadList_)

		return _aSadResult_

		def SplittedAtThesePositions(panPos)
			return This.SplittedAtPositions(panPos)

	  #======================================#
	 #  SPLITTING BEFORE A GIVEN POSITION   #
	#======================================#

	def SplitBeforePosition(n)
		# Engine-backed: stz_list_split_before
		_pSbpList_ = StzEngineMarshalList(@oList.Content())
		_pSbpResult_ = StzEngineListSplitBefore(_pSbpList_, n)
		_aSbpResult_ = StzEngineContentFromList(_pSbpResult_)
		StzEngineListFree(_pSbpResult_)
		StzEngineListFree(_pSbpList_)

		@oList.UpdateWith(_aSbpResult_)

		def SplitBeforePositionQ(n)
			This.SplitBeforePosition(n)
			return This

	def SplittedBeforePosition(n)
		_pSbdList_ = StzEngineMarshalList(@oList.Content())
		_pSbdResult_ = StzEngineListSplitBefore(_pSbdList_, n)
		_aSbdResult_ = StzEngineContentFromList(_pSbdResult_)
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
			if ring_len(_anSbcPos_) > 0
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

	def SplitAfterPosition(n)
		# Engine-backed: stz_list_split_after
		_pSfpList_ = StzEngineMarshalList(@oList.Content())
		_pSfpResult_ = StzEngineListSplitAfter(_pSfpList_, n)
		_aSfpResult_ = StzEngineContentFromList(_pSfpResult_)
		StzEngineListFree(_pSfpResult_)
		StzEngineListFree(_pSfpList_)

		@oList.UpdateWith(_aSfpResult_)

		def SplitAfterPositionQ(n)
			This.SplitAfterPosition(n)
			return This

	def SplittedAfterPosition(n)
		_pSfdList_ = StzEngineMarshalList(@oList.Content())
		_pSfdResult_ = StzEngineListSplitAfter(_pSfdList_, n)
		_aSfdResult_ = StzEngineContentFromList(_pSfdResult_)
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
			if ring_len(_anSacPos_) > 0
				# Split after the last occurrence found
				This.SplitAfterPosition(_anSacPos_[ring_len(_anSacPos_)])
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

	def SplitAtPosition(n)
		# "Split at position N" = split before position N
		This.SplitBeforePosition(n)

		def SplitAtPositionQ(n)
			This.SplitAtPosition(n)
			return This

	def SplittedAtPosition(n)
		return This.SplittedBeforePosition(n)

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

	def SplitToNParts(n)
		# Compute chunk size: ceiling(NumberOfItems / n)
		_nSnpLen_ = This.NumberOfItems()
		if n <= 0 or _nSnpLen_ = 0
			return
		ok

		_nSnpChunk_ = floor(_nSnpLen_ / n)
		if _nSnpLen_ % n > 0
			_nSnpChunk_ = _nSnpChunk_ + 1
		ok

		# Use engine split_to_parts_of_n with computed chunk size
		_pSnpList_ = StzEngineMarshalList(@oList.Content())
		_pSnpResult_ = StzEngineListSplitToPartsOfN(_pSnpList_, _nSnpChunk_)
		_aSnpResult_ = StzEngineContentFromList(_pSnpResult_)
		StzEngineListFree(_pSnpResult_)
		StzEngineListFree(_pSnpList_)

		@oList.UpdateWith(_aSnpResult_)

		def SplitToNPartsQ(n)
			This.SplitToNParts(n)
			return This

	def SplittedToNParts(n)
		_nSndLen_ = This.NumberOfItems()
		if n <= 0 or _nSndLen_ = 0
			return []
		ok

		_nSndChunk_ = floor(_nSndLen_ / n)
		if _nSndLen_ % n > 0
			_nSndChunk_ = _nSndChunk_ + 1
		ok

		_pSndList_ = StzEngineMarshalList(@oList.Content())
		_pSndResult_ = StzEngineListSplitToPartsOfN(_pSndList_, _nSndChunk_)
		_aSndResult_ = StzEngineContentFromList(_pSndResult_)
		StzEngineListFree(_pSndResult_)
		StzEngineListFree(_pSndList_)

		return _aSndResult_

	  #=================================#
	 #  SPLITTING TO PARTS OF N ITEMS  #
	#=================================#

	def SplitToPartsOfNItems(n)
		# Engine-backed: stz_list_split_to_parts_of_n
		_pSpnList_ = StzEngineMarshalList(@oList.Content())
		_pSpnResult_ = StzEngineListSplitToPartsOfN(_pSpnList_, n)
		_aSpnResult_ = StzEngineContentFromList(_pSpnResult_)
		StzEngineListFree(_pSpnResult_)
		StzEngineListFree(_pSpnList_)

		@oList.UpdateWith(_aSpnResult_)

		def SplitToPartsOfNItemsQ(n)
			This.SplitToPartsOfNItems(n)
			return This

		def SplitToPartsOf(n)
			This.SplitToPartsOfNItems(n)

			def SplitToPartsOfQ(n)
				This.SplitToPartsOf(n)
				return This

	def SplittedToPartsOfNItems(n)
		_pSpdList_ = StzEngineMarshalList(@oList.Content())
		_pSpdResult_ = StzEngineListSplitToPartsOfN(_pSpdList_, n)
		_aSpdResult_ = StzEngineContentFromList(_pSpdResult_)
		StzEngineListFree(_pSpdResult_)
		StzEngineListFree(_pSpdList_)

		return _aSpdResult_

		def SplittedToPartsOf(n)
			return This.SplittedToPartsOfNItems(n)

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

	# SplitWXT / SplittedWXT -- narrative-test aliases over the W form.
	def SplitWXT(pcCondition)
		This.SplitW(pcCondition)

		def SplitWXTQ(pcCondition)
			This.SplitWXT(pcCondition)
			return This

	def SplittedWXT(pcCondition)
		return This.SplittedW(pcCondition)

	# SplitAtWXT(pcCondition) -- split AT the positions where the
	# predicate is true (i.e. the matching elements become break
	# points). Same semantics as SplitW; aliased here for the
	# "SplitAt+W" narrative spelling.
	def SplitAtWXT(pcCondition)
		This.SplitW(pcCondition)

		def SplitAtWXTQ(pcCondition)
			This.SplitAtWXT(pcCondition)
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
