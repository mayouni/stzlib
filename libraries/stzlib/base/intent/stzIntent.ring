#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZINTENT                   #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : Intent management class backed by the       #
#                  Softanza Engine (stz_intent module).         #
#                  Named intents with params and priority.      #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  #=============#
 #  FUNCTIONS  #
#=============#

func StzIntentQ(cName, nPriority)
	return new stzIntent(cName, nPriority)

func IsStzIntent(pObj)
	if isObject(pObj) and classname(pObj) = "stzintent"
		return 1
	else
		return 0
	ok

	func @IsStzIntent(pObj)
		return IsStzIntent(pObj)


  /////////////////
 ///   CLASS   ///
/////////////////

class stzIntent

	@nHandle = -1
	@cName = ""

	  #--------------#
	 #     INIT     #
	#--------------#

	def init(cName, nPriority)
		if CheckingParams()
			if NOT isString(cName) or cName = ""
				StzRaise("Can't create stzIntent! cName must be a non-empty string.")
			ok
			if NOT isNumber(nPriority)
				StzRaise("Incorrect param! nPriority must be a number.")
			ok
		ok

		@cName = cName
		@nHandle = StzEngineIntentCreate(cName, nPriority)
		if @nHandle < 0
			StzRaise("Can't create stzIntent! Engine returned error.")
		ok

	  #-------------------------------#
	 #     PARAMETERS                #
	#-------------------------------#

	def SetParam(cName, cValue)
		if CheckingParams()
			if NOT isString(cName) or NOT isString(cValue)
				StzRaise("Incorrect params! cName and cValue must be strings.")
			ok
		ok

		nResult = StzEngineIntentSetParam(@nHandle, cName, cValue)
		if nResult < 0
			StzRaise("Can't set param! Param slots full.")
		ok

		def SetParamQ(cName, cValue)
			This.SetParam(cName, cValue)
			return This

	def GetParam(cName)
		return StzEngineIntentGetParam(@nHandle, cName)

		def Param(cName)
			return This.GetParam(cName)

	def NumberOfParams()
		return StzEngineIntentParamCount(@nHandle)

		def ParamCount()
			return This.NumberOfParams()

	  #-------------------------------#
	 #     PRIORITY                  #
	#-------------------------------#

	def Priority()
		return StzEngineIntentPriority(@nHandle)

	  #-------------------------------#
	 #     CLEANUP                   #
	#-------------------------------#

	def Destroy()
		if @nHandle >= 0
			StzEngineIntentDestroy(@nHandle)
			@nHandle = -1
		ok
