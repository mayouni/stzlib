#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZRESOURCE                 #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : Resource tracker class backed by the        #
#                  Softanza Engine (stz_resource module).       #
#                  Register, acquire, release, detect leaks.    #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  #=============#
 #  FUNCTIONS  #
#=============#

# Resource states (matching engine)
$STZ_RES_FREE     = 0
$STZ_RES_ACQUIRED = 1

func StzResourceQ()
	return new stzResource()

func IsStzResource(pObj)
	if isObject(pObj) and classname(pObj) = "stzresource"
		return 1
	else
		return 0
	ok

	func @IsStzResource(pObj)
		return IsStzResource(pObj)


  /////////////////
 ///   CLASS   ///
/////////////////

class stzResource

	  #--------------#
	 #     INIT     #
	#--------------#

	def init()
		# Engine manages global resource store

	  #-------------------------------#
	 #     REGISTER AND MANAGE       #
	#-------------------------------#

	def Register(cName, cType)
		if CheckingParams()
			if NOT isString(cName) or cName = ""
				StzRaise("Incorrect param! cName must be a non-empty string.")
			ok
			if NOT isString(cType)
				StzRaise("Incorrect param! cType must be a string.")
			ok
		ok

		nResult = StzEngineResRegister(cName, cType)
		if nResult < 0
			StzRaise("Can't register resource! Slots full.")
		ok
		return nResult

		def RegisterQ(cName, cType)
			This.Register(cName, cType)
			return This

	def Acquire(cName)
		nResult = StzEngineResAcquire(cName)
		if nResult < 0
			StzRaise("Can't acquire resource '" + cName + "'! Not found or already acquired.")
		ok

		def AcquireQ(cName)
			This.Acquire(cName)
			return This

	def Release(cName)
		nResult = StzEngineResRelease(cName)
		if nResult < 0
			StzRaise("Can't release resource '" + cName + "'! Not found or not acquired.")
		ok

		def ReleaseQ(cName)
			This.Release(cName)
			return This

	  #-------------------------------#
	 #     QUERY                     #
	#-------------------------------#

	def State(cName)
		return StzEngineResState(cName)

	def IsAcquired(cName)
		return This.State(cName) = $STZ_RES_ACQUIRED

	def IsFree(cName)
		return This.State(cName) = $STZ_RES_FREE

	def AcquireCount(cName)
		return StzEngineResAcquireCount(cName)

	  #-------------------------------#
	 #     LEAK DETECTION            #
	#-------------------------------#

	def NumberOfLeaks()
		return StzEngineResLeakedCount()

		def LeakedCount()
			return This.NumberOfLeaks()

	def HasLeaks()
		return This.NumberOfLeaks() > 0

	  #-------------------------------#
	 #     COUNTING AND CLEANUP      #
	#-------------------------------#

	def Count()
		return StzEngineResCount()

		def NumberOfResources()
			return This.Count()

	def Unregister(cName)
		StzEngineResUnregister(cName)

	def Clear()
		StzEngineResClear()
