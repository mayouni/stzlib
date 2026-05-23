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
		_pPfList = @oList._EngineListFromContent()
		if _pPfList != NULL
			_pPfResult = StzEngineListMapExpr(_pPfList, pcAction)
			if _pPfResult != NULL
				@oList.UpdateWith(@oList._ContentFromEngineList(_pPfResult))
				StzEngineListFree(_pPfResult)
			ok
			StzEngineListFree(_pPfList)
			return
		ok
		aContent = @oList.Map(pcAction)
		@oList.UpdateWith(aContent)

		def PerformQ(pcAction)
			This.Perform(pcAction)
			return This

	def PerformOn(panPos, pcAction)
		aAll = @oList.Map(pcAction)
		aContent = @oList.Content()
		nLen = len(panPos)
		for i = 1 to nLen
			nPos = panPos[i]
			if nPos >= 1 and nPos <= len(aContent)
				aContent[nPos] = aAll[nPos]
			ok
		next
		@oList.UpdateWith(aContent)

		def PerformOnQ(panPos, pcAction)
			This.PerformOn(panPos, pcAction)
			return This

		def PerformOnPositions(panPos, pcAction)
			This.PerformOn(panPos, pcAction)

	def PerformW(pcCondition, pcAction)
		anPos = @oList.FindW(pcCondition)
		This.PerformOn(anPos, pcAction)

		def PerformWQ(pcCondition, pcAction)
			This.PerformW(pcCondition, pcAction)
			return This

	def Yield(pcYielder)
		_pYdList = @oList._EngineListFromContent()
		if _pYdList != NULL
			_pYdResult = StzEngineListMapExpr(_pYdList, pcYielder)
			if _pYdResult != NULL
				_aYdContent = @oList._ContentFromEngineList(_pYdResult)
				StzEngineListFree(_pYdResult)
				StzEngineListFree(_pYdList)
				return _aYdContent
			ok
			StzEngineListFree(_pYdList)
		ok
		return @oList.Map(pcYielder)

		def YieldQ(pcYielder)
			return new stzList(This.Yield(pcYielder))

	def YieldOn(panPos, pcYielder)
		aAll = @oList.Map(pcYielder)
		nLen = len(panPos)
		aResult = []
		for i = 1 to nLen
			nPos = panPos[i]
			if nPos >= 1 and nPos <= len(aAll)
				aResult + aAll[nPos]
			ok
		next
		return aResult

	def YieldW(pcCondition, pcYielder)
		anPos = @oList.FindW(pcCondition)
		return This.YieldOn(anPos, pcYielder)

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
