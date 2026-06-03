#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSTRINGPERFORMER          #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String performer -- Wraps stzString via     #
#                  composition. Higher-order operations        #
#                  (perform, yield) on chars.                  #
#                  For aliases, use stzStringPerformerXT.      #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzStringPerformer

	@oString

	def init(pStrOrStzStrObj)
		if isString(pStrOrStzStrObj)
			@oString = new stzString(pStrOrStzStrObj)
		but isObject(pStrOrStzStrObj)
			@oString = pStrOrStzStrObj
		else
			StzRaise("Can't create stzStringPerformer! Parameter must be a string or stzString object.")
		ok

	def Content()
		return @oString.Content()

	def NumberOfChars()
		return @oString.NumberOfChars()

	def IsEmpty()
		return @oString.IsEmpty()

	  #======================================================#
	 #   PERFORM ACTION ON EACH CHAR                        #
	#======================================================#

	def Perform(pcAction)
		cStr = @oString.Content()
		StzEngineStringMapChars(cStr, _StzStripBraces(pcAction))

		def PerformQ(pcAction)
			This.Perform(pcAction)
			return This

	  #======================================================#
	 #   PERFORM ACTION ON SPECIFIC POSITIONS               #
	#======================================================#

	def PerformOn(panPos, pcAction)
		cStr = @oString.Content()
		pList = StzEngineStringMapChars(cStr, _StzStripBraces(pcAction))
		if pList != NULL
			StzEngineListFree(pList)
		ok

		def PerformOnQ(panPos, pcAction)
			This.PerformOn(panPos, pcAction)
			return This

	  #======================================================#
	 #   PERFORM WITH CONDITION                             #
	#======================================================#

	def PerformW(pcCondition, pcAction)
		anPos = This.FindCharsW(pcCondition)
		This.PerformOn(anPos, pcAction)

		def PerformWQ(pcCondition, pcAction)
			This.PerformW(pcCondition, pcAction)
			return This

	  #======================================================#
	 #   YIELD (COLLECT) FROM EACH CHAR                     #
	#======================================================#

	def Yield(pcYielder)
		cStr = @oString.Content()
		pList = StzEngineStringMapChars(cStr, _StzStripBraces(pcYielder))
		if pList = NULL return [] ok

		aResult = StzEngineContentFromList(pList)
		StzEngineListFree(pList)
		return aResult

	  #======================================================#
	 #   YIELD FROM SPECIFIC POSITIONS                      #
	#======================================================#

	def YieldOn(panPos, pcYielder)
		aAll = This.Yield(pcYielder)
		aResult = []
		nLen = ring_len(panPos)
		for i = 1 to nLen
			n = panPos[i]
			if n >= 1 and n <= ring_len(aAll)
				aResult + aAll[n]
			ok
		next
		return aResult

	  #======================================================#
	 #   YIELD WITH CONDITION                               #
	#======================================================#

	def YieldW(pcCondition, pcYielder)
		anPos = This.FindCharsW(pcCondition)
		return This.YieldOn(anPos, pcYielder)

