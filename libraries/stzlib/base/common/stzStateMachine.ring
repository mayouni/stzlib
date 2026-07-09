#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSTATEMACHINE             #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : Finite state machine class backed by the    #
#                  Softanza Engine (stz_statemachine module).   #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  #=============#
 #  FUNCTIONS  #
#=============#

func StzStateMachineQ(cName)
	return new stzStateMachine(cName)

func IsStzStateMachine(pObj)
	if isObject(pObj) and classname(pObj) = "stzstatemachine"
		return 1
	else
		return 0
	ok

	func IsAStzStateMachine(pObj)
		return IsStzStateMachine(pObj)

	func @IsStzStateMachine(pObj)
		return IsStzStateMachine(pObj)


  /////////////////
 ///   CLASS   ///
/////////////////

class stzStateMachine from stzObject

	@cName = ""
	@nHandle = -1

	  #--------------#
	 #     INIT     #
	#--------------#

	def init(cName)

		if CheckingParams()
			if NOT isString(cName) or cName = ""
				StzRaise("Can't create stzStateMachine! cName must be a non-empty string.")
			ok
		ok

		@cName = cName
		@nHandle = StzEngineFsmCreate(cName)

		if @nHandle < 0
			StzRaise("Can't create stzStateMachine! Engine returned error code: " + @nHandle)
		ok

	  #--------------#
	 #     NAME     #
	#--------------#

	def Name()
		return @cName

	  #-------------------------------#
	 #     STATES AND TRANSITIONS    #
	#-------------------------------#

	def AddState(cState)
		if CheckingParams()
			if NOT isString(cState) or cState = ""
				StzRaise("Incorrect param! cState must be a non-empty string.")
			ok
		ok

		_nResult_ = StzEngineFsmAddState(@nHandle, cState)
		if _nResult_ < 0
			StzRaise("Can't add state! Engine returned error code: " + _nResult_)
		ok

		def AddStateQ(cState)
			This.AddState(cState)
			return This

	def AddStates(paStates)
		if CheckingParams()
			if NOT isList(paStates)
				StzRaise("Incorrect param! paStates must be a list of strings.")
			ok
		ok

		_nLen_ = len(paStates)
		for i = 1 to _nLen_
			This.AddState(paStates[i])
		next

		def AddStatesQ(paStates)
			This.AddStates(paStates)
			return This

	def AddTransition(cFrom, cEvent, cTo)
		if CheckingParams()
			if NOT isString(cFrom) or NOT isString(cEvent) or NOT isString(cTo)
				StzRaise("Incorrect params! cFrom, cEvent, and cTo must be strings.")
			ok
		ok

		_nResult_ = StzEngineFsmAddTransition(@nHandle, cFrom, cEvent, cTo)
		if _nResult_ < 0
			StzRaise("Can't add transition! Engine returned error code: " + _nResult_)
		ok

		def AddTransitionQ(cFrom, cEvent, cTo)
			This.AddTransition(cFrom, cEvent, cTo)
			return This

	def AddTransitions(paTransitions)
		if CheckingParams()
			if NOT isList(paTransitions)
				StzRaise("Incorrect param! paTransitions must be a list of [from, event, to] lists.")
			ok
		ok

		_nLen_ = len(paTransitions)
		for i = 1 to _nLen_
			_aTr_ = paTransitions[i]
			This.AddTransition(_aTr_[1], _aTr_[2], _aTr_[3])
		next

		def AddTransitionsQ(paTransitions)
			This.AddTransitions(paTransitions)
			return This

	  #-------------------#
	 #     CURRENT STATE #
	#-------------------#

	def SetState(cState)
		if CheckingParams()
			if NOT isString(cState) or cState = ""
				StzRaise("Incorrect param! cState must be a non-empty string.")
			ok
		ok

		_nResult_ = StzEngineFsmSetState(@nHandle, cState)
		if _nResult_ < 0
			StzRaise("Can't set state! State may not exist.")
		ok

		def SetStateQ(cState)
			This.SetState(cState)
			return This

	def CurrentState()
		return StzEngineFsmCurrentState(@nHandle)

		def State()
			return This.CurrentState()

	  #-------------------#
	 #     EVENTS        #
	#-------------------#

	def Send(cEvent)
		if CheckingParams()
			if NOT isString(cEvent) or cEvent = ""
				StzRaise("Incorrect param! cEvent must be a non-empty string.")
			ok
		ok

		_nResult_ = StzEngineFsmSend(@nHandle, cEvent)
		if _nResult_ < 0
			StzRaise("Can't send event '" + cEvent + "'! No matching transition from current state.")
		ok

		return This.CurrentState()

		def SendQ(cEvent)
			This.Send(cEvent)
			return This

		def Trigger(cEvent)
			return This.Send(cEvent)

		def TriggerQ(cEvent)
			This.Send(cEvent)
			return This

	  #-------------------#
	 #     COUNTING      #
	#-------------------#

	def NumberOfStates()
		return StzEngineFsmStateCount(@nHandle)

		def StateCount()
			return This.NumberOfStates()

		def CountStates()
			return This.NumberOfStates()

	def NumberOfTransitions()
		return StzEngineFsmTransitionCount(@nHandle)

		def TransitionCount()
			return This.NumberOfTransitions()

		def CountTransitions()
			return This.NumberOfTransitions()

	  #-------------------#
	 #     CLEANUP       #
	#-------------------#

	def Destroy()
		if @nHandle >= 0
			StzEngineFsmDestroy(@nHandle)
			@nHandle = -1
		ok
