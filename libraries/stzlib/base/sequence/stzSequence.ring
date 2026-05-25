#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSEQUENCE                 #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : Sequence generator class backed by the      #
#                  Softanza Engine (stz_sequence module).       #
#                  Modes: step, repeat, bounce.                 #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  #=============#
 #  FUNCTIONS  #
#=============#

# Sequence modes (matching engine)
$STZ_SEQ_STEP    = 0
$STZ_SEQ_REPEAT  = 1
$STZ_SEQ_BOUNCE  = 2

func StzSequenceQ(cName, nStart, nStep, nMode)
	return new stzSequence(cName, nStart, nStep, nMode)

func IsStzSequence(pObj)
	if isObject(pObj) and classname(pObj) = "stzsequence"
		return 1
	else
		return 0
	ok

	func @IsStzSequence(pObj)
		return IsStzSequence(pObj)


  /////////////////
 ///   CLASS   ///
/////////////////

class stzSequence

	@cName = ""

	  #--------------#
	 #     INIT     #
	#--------------#

	def init(cName, nStart, nStep, nMode)

		if CheckingParams()
			if NOT isString(cName) or cName = ""
				StzRaise("Can't create stzSequence! cName must be a non-empty string.")
			ok
			if NOT isNumber(nStart)
				StzRaise("Incorrect param! nStart must be a number.")
			ok
			if NOT isNumber(nStep)
				StzRaise("Incorrect param! nStep must be a number.")
			ok
			if NOT isNumber(nMode)
				StzRaise("Incorrect param! nMode must be 0 (step), 1 (repeat), or 2 (bounce).")
			ok
		ok

		@cName = cName
		nResult = StzEngineSeqCreate(cName, nStart, nStep, nMode)

		if nResult < 0
			StzRaise("Can't create stzSequence! Engine returned error code: " + nResult)
		ok

	  #--------------#
	 #     NAME     #
	#--------------#

	def Name()
		return @cName

	  #-------------------------------#
	 #     BOUNDS                    #
	#-------------------------------#

	def SetBounds(nMin, nMax)
		if CheckingParams()
			if NOT isNumber(nMin) or NOT isNumber(nMax)
				StzRaise("Incorrect params! nMin and nMax must be numbers.")
			ok
		ok

		nResult = StzEngineSeqSetBounds(@cName, nMin, nMax)
		if nResult < 0
			StzRaise("Can't set bounds! Sequence not found.")
		ok

		def SetBoundsQ(nMin, nMax)
			This.SetBounds(nMin, nMax)
			return This

	  #-------------------------------#
	 #     ITERATION                 #
	#-------------------------------#

	def NextValue()
		return StzEngineSeqNext(@cName)

		def Advance()
			return This.NextValue()

	def Current()
		return StzEngineSeqCurrent(@cName)

		def Value()
			return This.Current()

	def Iteration()
		return StzEngineSeqIteration(@cName)

		def IterationNumber()
			return This.Iteration()

	def NextNValues(n)
		if CheckingParams()
			if NOT isNumber(n) or n < 1
				StzRaise("Incorrect param! n must be a positive number.")
			ok
		ok

		aResult = []
		for i = 1 to n
			aResult + This.NextValue()
		next i
		return aResult

		def AdvanceN(n)
			return This.NextNValues(n)

	  #-------------------------------#
	 #     RESET AND CLEANUP         #
	#-------------------------------#

	def Reset()
		StzEngineSeqReset(@cName)

		def ResetQ()
			This.Reset()
			return This

	def Destroy()
		StzEngineSeqDestroy(@cName)
