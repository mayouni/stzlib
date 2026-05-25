#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZCONTEXT                  #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : Nested scope context class backed by the    #
#                  Softanza Engine (stz_context module).        #
#                  Key-value pairs with parent inheritance.     #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  #=============#
 #  FUNCTIONS  #
#=============#

func StzContextQ(cName)
	return new stzContext(cName)

func IsStzContext(pObj)
	if isObject(pObj) and classname(pObj) = "stzcontext"
		return 1
	else
		return 0
	ok

	func @IsStzContext(pObj)
		return IsStzContext(pObj)


  /////////////////
 ///   CLASS   ///
/////////////////

class stzContext

	@nHandle = -1
	@cName = ""

	  #--------------#
	 #     INIT     #
	#--------------#

	def init(cName)
		if isList(cName) and len(cName) = 2
			# init(cName, nParentHandle) form
			@cName = cName[1]
			@nHandle = StzEngineContextCreate(@cName, cName[2])
		else
			if CheckingParams()
				if NOT isString(cName) or cName = ""
					StzRaise("Can't create stzContext! cName must be a non-empty string.")
				ok
			ok
			@cName = cName
			@nHandle = StzEngineContextCreate(cName, -1)
		ok

		if @nHandle < 0
			StzRaise("Can't create stzContext! Engine returned error.")
		ok

	  #-------------------------------#
	 #     KEY-VALUE PAIRS           #
	#-------------------------------#

	def Set(cKey, cValue)
		if CheckingParams()
			if NOT isString(cKey) or NOT isString(cValue)
				StzRaise("Incorrect params! cKey and cValue must be strings.")
			ok
		ok

		nResult = StzEngineContextSet(@nHandle, cKey, cValue)
		if nResult < 0
			StzRaise("Can't set context value! Pair slots full.")
		ok

		def SetQ(cKey, cValue)
			This.Set(cKey, cValue)
			return This

	def Get(cKey)
		return StzEngineContextGet(@nHandle, cKey)

		def Value(cKey)
			return This.Get(cKey)

	def Has(cKey)
		nResult = StzEngineContextHas(@nHandle, cKey)
		if nResult = 1
			return 1
		else
			return 0
		ok

		def Contains(cKey)
			return This.Has(cKey)

	  #-------------------------------#
	 #     INFO                      #
	#-------------------------------#

	def Name()
		return @cName

	def Handle()
		return @nHandle

	def NumberOfPairs()
		return StzEngineContextPairCount(@nHandle)

		def PairCount()
			return This.NumberOfPairs()

	  #-------------------------------#
	 #     CHILD CONTEXT             #
	#-------------------------------#

	def CreateChild(cChildName)
		return new stzContext([cChildName, @nHandle])

	  #-------------------------------#
	 #     CLEANUP                   #
	#-------------------------------#

	def Destroy()
		if @nHandle >= 0
			StzEngineContextDestroy(@nHandle)
			@nHandle = -1
		ok
