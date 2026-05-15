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
		aContent = This.Content()
		nLen = len(aContent)
		_cCode_ = StzStringQ(pcAction).TrimQ().BoundsRemoved("{","}")
		for @i = 1 to nLen
			eval(_cCode_)
		next

		def PerformQ(pcAction)
			This.Perform(pcAction)
			return This

	def PerformOn(panPos, pcAction)
		aContent = This.Content()
		nLen = len(panPos)
		_cCode_ = StzStringQ(pcAction).TrimQ().BoundsRemoved("{","}")
		for i = 1 to nLen
			@i = panPos[i]
			eval(_cCode_)
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
		aContent = This.Content()
		nLen = len(aContent)
		_cCode_ = StzStringQ(pcYielder).TrimQ().BoundsRemoved("{","}")
		aResult = []
		for @i = 1 to nLen
			aResult + eval(_cCode_)
		next
		return aResult

		def YieldQ(pcYielder)
			return new stzList(This.Yield(pcYielder))

	def YieldOn(panPos, pcYielder)
		nLen = len(panPos)
		_cCode_ = StzStringQ(pcYielder).TrimQ().BoundsRemoved("{","}")
		aResult = []
		for i = 1 to nLen
			@i = panPos[i]
			aResult + eval(_cCode_)
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
		aContent = This.Content()
		nLen = len(aContent)
		_cCode_ = StzStringQ(pcAction).TrimQ().BoundsRemoved("{","}")
		for @i = 1 to nLen
			@item = aContent[@i]
			eval(_cCode_)
		next

		def PerformOnEachItemAndItsPositionQ(pcAction)
			This.PerformOnEachItemAndItsPosition(pcAction)
			return This

	  #======================================================#
	 #   YIELD PAIRS [POSITION, ITEM]                       #
	#======================================================#

	def YieldPairs(pcYielder)
		aContent = This.Content()
		nLen = len(aContent)
		_cCode_ = StzStringQ(pcYielder).TrimQ().BoundsRemoved("{","}")
		aResult = []
		for @i = 1 to nLen
			@item = aContent[@i]
			aResult + eval(_cCode_)
		next
		return aResult
