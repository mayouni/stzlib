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

# A finite state machine kept in the engine: add states and transitions, send events, and read the state the machine is in.
#
# Declare the states, then the transitions as [ from, event, to ]. Send follows the matching
# transition and answers the new state. The first state added is the starting state. Mistakes are
# not reported by the machine: an event that matches no transition, a SetState to an unknown state
# and a transition naming an unknown state are all ignored without an error, so check CurrentState
# after the call that matters.
#
#   receiver   o1 = new stzStateMachine("door") o1.AddStates([ "closed", "open", "locked" ])
#              o1.AddTransitions([ [ "closed", "open", "open" ], [ "open", "close", "closed" ], [
#              "closed", "lock", "locked" ] ])
#   example    ? o1.CurrentState()
#              #--> closed
#              ? o1.Send("open")
#              #--> open
#              ? o1.Send("lock")
#              #--> open
#              ? o1.NumberOfTransitions()
#              #--> 3
#   see        stzPattern, stzDeployment
class stzStateMachine from stzObject

	@cName = ""
	@nHandle = -1

	  #--------------#
	 #     INIT     #
	#--------------#

	# Creates an empty finite state machine in the engine, identified by a name.
	#
	#   cName      the machine's name, a non-empty text
	#   returns    nothing; the object is built
	#   warning    a name that is empty or not a text raises an error
	#   see        AddState, AddTransition
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

	# Returns the name the machine was created with.
	#
	#   returns    a text
	#   see        init
	def Name()
		return @cName

	  #-------------------------------#
	 #     STATES AND TRANSITIONS    #
	#-------------------------------#

	# Adds a state to the machine; the first state added becomes the current one.
	#
	#   cState     the name of the state, a non-empty text
	#   returns    nothing; use AddStateQ to chain
	#   note       an empty or non-text name raises an error
	#   warning    adding a name twice counts it twice in NumberOfStates
	#   see        AddStates, SetState, NumberOfStates
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

	# Adds several states in the order given, by calling AddState for each.
	#
	#   paStates   a list of state names, each a non-empty text
	#   returns    nothing
	#   see        AddState
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

	# Adds a transition that moves the machine from one state to another when an event is sent.
	#
	#   cFrom      the state the transition leaves
	#   cEvent     the event that triggers it
	#   cTo        the state it arrives in
	#   returns    nothing; use AddTransitionQ to chain
	#   note       all three must be texts, else an error is raised
	#   warning    a transition naming a state that was not added is silently dropped:
	#              NumberOfTransitions does not grow and nothing is raised
	#   see        AddTransitions, Send
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

	# Adds several transitions, each given as a [ from, event, to ] list.
	#
	#   paTransitions   a list of [ cFrom, cEvent, cTo ] lists
	#   returns         nothing
	#   see             AddTransition
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

	# Forces the machine into a state without going through a transition.
	#
	#   cState     the name of the state to enter
	#   returns    nothing; use SetStateQ to chain
	#   warning    an unknown state is silently ignored and the current state stays: the error the
	#              code intends is never raised
	#   see        CurrentState, Send
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

	# Returns the name of the state the machine is in; empty before any state is added.
	#
	#   returns    a text
	#   see        SetState, Send
	def CurrentState()
		return StzEngineFsmCurrentState(@nHandle)

		def State()
			return This.CurrentState()

	  #-------------------#
	 #     EVENTS        #
	#-------------------#

	# Feeds an event to the machine, which follows the matching transition from its current state, and returns the state it is in after.
	#
	#   cEvent     the event to send, a non-empty text
	#   returns    the name of the current state, a text
	#   note       an empty or non-text event raises an error
	#   warning    an event with no transition from the current state is silently ignored and the
	#              state stays: the error the code intends is never raised; checked with two
	#              unmatched events
	#   see        CurrentState, AddTransition
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

	# Returns how many states were added.
	#
	#   returns    a number
	#   see        AddState
	def NumberOfStates()
		return StzEngineFsmStateCount(@nHandle)

		def StateCount()
			return This.NumberOfStates()

		def CountStates()
			return This.NumberOfStates()

	# Returns how many transitions were accepted by the engine.
	#
	#   returns    a number
	#   see        AddTransition
	def NumberOfTransitions()
		return StzEngineFsmTransitionCount(@nHandle)

		def TransitionCount()
			return This.NumberOfTransitions()

		def CountTransitions()
			return This.NumberOfTransitions()

	  #-------------------#
	 #     CLEANUP       #
	#-------------------#

	# Frees the engine machine and marks the object unusable.
	#
	#   returns    nothing
	#   warning    afterwards CurrentState answers an empty text
	#   see        init
	def Destroy()
		if @nHandle >= 0
			StzEngineFsmDestroy(@nHandle)
			@nHandle = -1
		ok
