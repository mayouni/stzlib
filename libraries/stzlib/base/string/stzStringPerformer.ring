#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSTRINGPERFORMER          #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String performer subclass -- higher-order   #
#                  operations (perform, yield) on chars.        #
#                  For aliases, use stzStringPerformerXT.       #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzStringPerformer from stzString

	  #======================================================#
	 #   PERFORM ACTION ON EACH CHAR                        #
	#======================================================#

	def Perform(pcAction)
		cStr = This.Content()
		nLen = This.NumberOfChars()
		_cCode_ = StzStringQ(pcAction).TrimQ().BoundsRemoved("{","}")
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
		_cCode_ = StzStringQ(pcAction).TrimQ().BoundsRemoved("{","}")
		for i = 1 to nLen
			@i = panPos[i]
			eval(_cCode_)
		next

	  #======================================================#
	 #   YIELD (COLLECT) FROM EACH CHAR                     #
	#======================================================#

	def Yield(pcYielder)
		cStr = This.Content()
		nLen = This.NumberOfChars()
		_cCode_ = StzStringQ(pcYielder).TrimQ().BoundsRemoved("{","}")
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
		_cCode_ = StzStringQ(pcYielder).TrimQ().BoundsRemoved("{","}")
		aResult = []
		for i = 1 to nLen
			@i = panPos[i]
			aResult + eval(_cCode_)
		next
		return aResult
