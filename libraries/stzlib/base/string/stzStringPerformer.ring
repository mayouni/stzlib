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

class stzStringPerformer from stzObject

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
		_cStr_ = @oString.Content()
		StzEngineStringMapChars(_cStr_, _StzStripBraces(pcAction))

		def PerformQ(pcAction)
			This.Perform(pcAction)
			return This

	  #======================================================#
	 #   PERFORM ACTION ON SPECIFIC POSITIONS               #
	#======================================================#

	def PerformOn(panPos, pcAction)
		_cStr_ = @oString.Content()
		pList = StzEngineStringMapChars(_cStr_, _StzStripBraces(pcAction))
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
		_anPos_ = This.FindCharsW(pcCondition)
		This.PerformOn(_anPos_, pcAction)

		def PerformWQ(pcCondition, pcAction)
			This.PerformW(pcCondition, pcAction)
			return This

	  #======================================================#
	 #   YIELD (COLLECT) FROM EACH CHAR                     #
	#======================================================#

	def Yield(pcYielder)
		_cStr_ = @oString.Content()
		pList = StzEngineStringMapChars(_cStr_, _StzStripBraces(pcYielder))
		if pList = NULL return [] ok

		_aResult_ = StzEngineContentFromList(pList)
		StzEngineListFree(pList)
		return _aResult_

	  #======================================================#
	 #   YIELD FROM SPECIFIC POSITIONS                      #
	#======================================================#

	def YieldOn(panPos, pcYielder)
		_aAll_ = This.Yield(pcYielder)
		_aResult_ = []
		_nLen_ = len(panPos)
		for i = 1 to _nLen_
			_n_ = panPos[i]
			if _n_ >= 1 and _n_ <= len(_aAll_)
				_aResult_ + _aAll_[_n_]
			ok
		next
		return _aResult_

	  #======================================================#
	 #   YIELD WITH CONDITION                               #
	#======================================================#

	def YieldW(pcCondition, pcYielder)
		_anPos_ = This.FindCharsW(pcCondition)
		return This.YieldOn(_anPos_, pcYielder)

