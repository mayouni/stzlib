#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTPERFORMER           #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List performer subclass -- higher-order    #
#                  perform and yield operations.               #
#                  For aliases, use stzListPerformerXT.         #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzListPerformer

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
			StzRaise("Can't create stzListPerformer! Parameter must be a list or stzList object.")
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

	  #===============================#
	 #     PERFORM / YIELD           #
	#===============================#

	def Perform(pcAction)
		_pPfList_ = @oList._EngineListFromContent()
		if _pPfList_ != NULL
			_pPfResult_ = StzEngineListMapExpr(_pPfList_, pcAction)
			if _pPfResult_ != NULL
				@oList.UpdateWith(@oList._ContentFromEngineList(_pPfResult_))
				StzEngineListFree(_pPfResult_)
			ok
			StzEngineListFree(_pPfList_)
			return
		ok
		_aPfContent_ = @oList.Map(pcAction)
		@oList.UpdateWith(_aPfContent_)

		def PerformQ(pcAction)
			This.Perform(pcAction)
			return This

	def PerformOn(panPos, pcAction)
		_aPoAll_ = @oList.Map(pcAction)
		_aPoContent_ = @oList.Content()
		_nPoLen_ = ring_len(panPos)
		for _iPo_ = 1 to _nPoLen_
			_nPoPos_ = panPos[_iPo_]
			if _nPoPos_ >= 1 and _nPoPos_ <= ring_len(_aPoContent_)
				_aPoContent_[_nPoPos_] = _aPoAll_[_nPoPos_]
			ok
		next
		@oList.UpdateWith(_aPoContent_)

		def PerformOnQ(panPos, pcAction)
			This.PerformOn(panPos, pcAction)
			return This

		def PerformOnPositions(panPos, pcAction)
			This.PerformOn(panPos, pcAction)

	def PerformW(pcCondition, pcAction)
		_anPwPos_ = @oList.FindW(pcCondition)
		This.PerformOn(_anPwPos_, pcAction)

		def PerformWQ(pcCondition, pcAction)
			This.PerformW(pcCondition, pcAction)
			return This

	def Yield(pcYielder)
		_pYdList_ = @oList._EngineListFromContent()
		if _pYdList_ != NULL
			_pYdResult_ = StzEngineListMapExpr(_pYdList_, pcYielder)
			if _pYdResult_ != NULL
				_aYdContent_ = @oList._ContentFromEngineList(_pYdResult_)
				StzEngineListFree(_pYdResult_)
				StzEngineListFree(_pYdList_)
				return _aYdContent_
			ok
			StzEngineListFree(_pYdList_)
		ok
		return @oList.Map(pcYielder)

		def YieldQ(pcYielder)
			return new stzList(This.Yield(pcYielder))

	def YieldOn(panPos, pcYielder)
		_aYoAll_ = @oList.Map(pcYielder)
		_nYoLen_ = ring_len(panPos)
		_aYoResult_ = []
		for _iYo_ = 1 to _nYoLen_
			_nYoPos_ = panPos[_iYo_]
			if _nYoPos_ >= 1 and _nYoPos_ <= ring_len(_aYoAll_)
				@AddItem(_aYoResult_, _aYoAll_[_nYoPos_])
			ok
		next
		return _aYoResult_

	def YieldW(pcCondition, pcYielder)
		_anYwPos_ = @oList.FindW(pcCondition)
		return This.YieldOn(_anYwPos_, pcYielder)

	  #======================================================#
	 #   YIELD ON POSITIONS Q                               #
	#======================================================#

	def YieldOnQ(panPos, pcYielder)
		return new stzList(This.YieldOn(panPos, pcYielder))

	def YieldWQ(pcCondition, pcYielder)
		return new stzList(This.YieldW(pcCondition, pcYielder))

	  #======================================================#
	 #   PERFORM ON EACH WITH INDEX                         #
	#======================================================#

	def PerformOnEachItemAndItsPosition(pcAction)
		This.Perform(pcAction)

		def PerformOnEachItemAndItsPositionQ(pcAction)
			This.PerformOnEachItemAndItsPosition(pcAction)
			return This

	  #======================================================#
	 #   YIELD PAIRS [POSITION, ITEM]                       #
	#======================================================#

	def YieldPairs(pcYielder)
		return @oList.Map(pcYielder)
