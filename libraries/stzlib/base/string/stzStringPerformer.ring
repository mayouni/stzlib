#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSTRINGPERFORMER          #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String performer -- Wraps stzString via     #
#                  composition. Higher-order operations         #
#                  (perform, yield) on chars.                   #
#                  For aliases, use stzStringPerformerXT.       #
#   Version      : V0.9 (2026)                                #
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
		nLen = @oString.NumberOfChars()
		_cCode_ = _StzStripBraces(pcAction)
		for @i = 1 to nLen
			eval(_cCode_)
		next

		def PerformQ(pcAction)
			This.Perform(pcAction)
			return This

	  #======================================================#
	 #   PERFORM ACTION ON SPECIFIC POSITIONS               #
	#======================================================#

	def PerformOn(panPos, pcAction)
		nLen = len(panPos)
		_cCode_ = _StzStripBraces(pcAction)
		for i = 1 to nLen
			@i = panPos[i]
			eval(_cCode_)
		next

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
		nLen = @oString.NumberOfChars()
		_cCode_ = _StzStripBraces(pcYielder)
		aResult = []
		for @i = 1 to nLen
			aResult + eval(_cCode_)
		next
		return aResult

	  #======================================================#
	 #   YIELD FROM SPECIFIC POSITIONS                      #
	#======================================================#

	def YieldOn(panPos, pcYielder)
		nLen = len(panPos)
		_cCode_ = _StzStripBraces(pcYielder)
		aResult = []
		for i = 1 to nLen
			@i = panPos[i]
			aResult + eval(_cCode_)
		next
		return aResult

	  #======================================================#
	 #   YIELD WITH CONDITION                               #
	#======================================================#

	def YieldW(pcCondition, pcYielder)
		anPos = This.FindCharsW(pcCondition)
		return This.YieldOn(anPos, pcYielder)
