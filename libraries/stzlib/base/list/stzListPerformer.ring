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

class stzListPerformer from stzList

	def Perform(pcAction)
		@aContent = This.Map(pcAction)

		def PerformQ(pcAction)
			This.Perform(pcAction)
			return This

	def PerformOn(panPos, pcAction)
		aAll = This.Map(pcAction)
		nLen = len(panPos)
		for i = 1 to nLen
			nPos = panPos[i]
			if nPos >= 1 and nPos <= len(@aContent)
				@aContent[nPos] = aAll[nPos]
			ok
		next

		def PerformOnQ(panPos, pcAction)
			This.PerformOn(panPos, pcAction)
			return This

		def PerformOnPositions(panPos, pcAction)
			This.PerformOn(panPos, pcAction)

	def PerformW(pcCondition, pcAction)
		anPos = This.FindW(pcCondition)
		This.PerformOn(anPos, pcAction)

		def PerformWQ(pcCondition, pcAction)
			This.PerformW(pcCondition, pcAction)
			return This

	def Yield(pcYielder)
		return This.Map(pcYielder)

		def YieldQ(pcYielder)
			return new stzList(This.Yield(pcYielder))

	def YieldOn(panPos, pcYielder)
		aAll = This.Map(pcYielder)
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
		anPos = This.FindW(pcCondition)
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
		return This.Map(pcYielder)
