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

# Generates numbers one by one from a start and a step, counting on, repeating between bounds or bouncing between them.
#
# Build one with new stzSequence(name, start, step, mode); the counter lives in the engine under its
# name, so give each sequence its own name and call Destroy when finished. Modes are 0 (count on
# without end), 1 (repeat between the bounds set by SetBounds) and 2 (bounce between them).
# NextValue answers the value it stands on and then moves, so the first call gives the start. Values
# are whole numbers: a fraction in the start or the step is cut silently.
#
#   receiver   o1 = new stzSequence("w15demo", 10, 5, 0)
#   example    ? o1.NextValue()
#              #--> 10
#              ? o1.Current()
#              #--> 15
#              ? @@( o1.NextNValues(3) )
#              #--> [ 15, 20, 25 ]
#              o1.Reset()
#              ? o1.Iteration()
#              #--> 0
#              o1.Destroy()
#   see        stzNumber, stzListOfNumbers
class stzSequence from stzObject

	@cName = ""

	  #--------------#
	 #     INIT     #
	#--------------#

	# Creates a named number sequence in the engine, from a start value, a step and a mode: 0 counts on, 1 repeats, 2 bounces.
	#
	#   cName      the unique name of the sequence, a non-empty text
	#   nStart     the first value
	#   nStep      the amount added each time
	#   nMode      0 for step, 1 for repeat, 2 for bounce
	#   returns    nothing; the sequence now exists in the engine under its name
	#   note       the engine keeps the sequence until Destroy; a second object built with a name
	#              already in use shares that counter and its own start and step are ignored (start
	#              100 on a counter standing at 20 still answers 20)
	#   warning    A start or a step that has a fraction is silently cut to a whole number: start
	#              2.5 gives 2, step 0.5 gives 0 so the value never moves, step 1.5 gives 1; a name
	#              that is empty or a value that is not a number raises an error
	#   see        SetBounds, NextValue, Destroy
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
		_nResult_ = StzEngineSeqCreate(cName, nStart, nStep, nMode)

		if _nResult_ < 0
			StzRaise("Can't create stzSequence! Engine returned error code: " + _nResult_)
		ok

	  #--------------#
	 #     NAME     #
	#--------------#

	# Returns the name the sequence was created with.
	#
	#   returns    a text
	#   see        init
	def Name()
		return @cName

	  #-------------------------------#
	 #     BOUNDS                    #
	#-------------------------------#

	# Sets the lowest and highest values a repeating or bouncing sequence moves between.
	#
	#   nMin       the lowest value
	#   nMax       the highest value
	#   returns    nothing; use SetBoundsQ to chain
	#   note       bounds act in modes 1 and 2 only: a mode-0 sequence given bounds 2 and 4 from 1
	#              still counts 1 to 5; mode 1 with bounds 1 to 3 gives 1 2 3 1 2 3 and mode 2 gives
	#              1 2 3 2 1 2 3 2
	#   see        init, NextValue
	def SetBounds(nMin, nMax)
		if CheckingParams()
			if NOT isNumber(nMin) or NOT isNumber(nMax)
				StzRaise("Incorrect params! nMin and nMax must be numbers.")
			ok
		ok

		_nResult_ = StzEngineSeqSetBounds(@cName, nMin, nMax)
		if _nResult_ < 0
			StzRaise("Can't set bounds! Sequence not found.")
		ok

		def SetBoundsQ(nMin, nMax)
			This.SetBounds(nMin, nMax)
			return This

	  #-------------------------------#
	 #     ITERATION                 #
	#-------------------------------#

	# Returns the value the sequence stands on and then moves it by one step, so the first call answers the start.
	#
	#   returns    a number
	#   note       Advance is the same method; Current shows the value the next call will return
	#   see        Current, NextNValues
	def NextValue()
		return StzEngineSeqNext(@cName)

		def Advance()
			return This.NextValue()

	# Returns the value the next NextValue will return, without moving the sequence.
	#
	#   returns    a number
	#   note       Value is the same method; after Destroy it answers 0
	#   see        NextValue, Iteration
	def Current()
		return StzEngineSeqCurrent(@cName)

		def Value()
			return This.Current()

	# Returns how many times the sequence has been moved since its creation or last Reset.
	#
	#   returns    a number
	#   note       IterationNumber is the same method
	#   see        Current, Reset
	def Iteration()
		return StzEngineSeqIteration(@cName)

		def IterationNumber()
			return This.Iteration()

	# Returns the next n values in order and moves the sequence n steps.
	#
	#   n          how many values to take, at least 1
	#   returns    a list of n numbers
	#   note       n below 1 raises "Incorrect param! n must be a positive number."
	#   see        NextValue
	def NextNValues(n)
		if CheckingParams()
			if NOT isNumber(n) or n < 1
				StzRaise("Incorrect param! n must be a positive number.")
			ok
		ok

		_aResult_ = []
		for i = 1 to n
			_aResult_ + This.NextValue()
		next
		return _aResult_

	  #-------------------------------#
	 #     RESET AND CLEANUP         #
	#-------------------------------#

	# Puts the sequence back at its start value and its iteration count at 0, keeping its bounds.
	#
	#   returns    nothing; use ResetQ to chain
	#   see        NextValue, Destroy
	def Reset()
		StzEngineSeqReset(@cName)

		def ResetQ()
			This.Reset()
			return This

	# Removes the sequence from the engine, which Ring cannot do by itself.
	#
	#   returns    nothing
	#   note       afterwards Current and NextValue answer 0 and SetBounds is silent: do not use the
	#              object again
	#   see        Reset
	def Destroy()
		StzEngineSeqDestroy(@cName)
