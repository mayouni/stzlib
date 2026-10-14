func IsCounterNamedParamList(paParams)
	if NOT isList(paParams)
		return 0
	ok

	# The validator's allowed-keys list was missing :WhenYouReach
	# (the init() method honours it at line 42 but the validator
	# rejected it). Length cap was 4 but there are 5 valid keys;
	# raised to 5.
	_nLen_ = len(paParams)
	if _nLen_ >= 1 and _nLen_ <= 5 and
	   IsHashList(paParams) and
	   StzHashListQ(paParams).KeysQ().IsMadeOfSome([ :StartAt, :AfterYouSkip, :WhenYouReach, :RestartAt, :Step ])

			return 1
	else
		return 0
	ok

	func @IsCounterNamedParamList(paParams)
		return IsCounterNamedParamList(paParams)

func StzCounterQ(paParams)
	return new stzCounter(paParams)

# Counts in cycles: it starts at a number, steps by a number, and starts over when a limit is reached or after a number of values.
#
# Give it a hashlist of options and ask for the first N numbers. :WhenYouReach names the value at
# which the count restarts, :AfterYouSkip names how many values to skip before it restarts, and
# :RestartAt is the value it restarts from. The options :StartAt and :Step alone are not enough
# today: without one of the two cycle options every number comes out as 0.
#
#   receiver   o1 = new stzCounter([ :StartAt = 1, :WhenYouReach = 4, :RestartAt = 0 ])
#   example    ? @@( o1.Counting(10) )
#              #--> [ 1, 2, 3, 0, 1, 2, 3, 0, 1, 2 ]
#   see        stzIntSeq
class stzCounter from stzObject
	@nStartAt = 1
	@nAfterYouSkip = 0
	@nWhenYouReach = 0
	@nRestartAt = 0
	@nStep = 1

	# Builds a cyclic counter from a hashlist of options that say where to start, how far to step and when to start over.
	#
	#   paParams   a hashlist with any of :StartAt, :Step, :WhenYouReach, :AfterYouSkip and
	#              :RestartAt, for example [ :StartAt = 1, :WhenYouReach = 4, :RestartAt = 0 ]
	#   returns    nothing; the object is built
	#   see        Counting
	def init(paParams)

		if isList(paParams) and
		   IsCounterNamedParamList(paParams)

			if HasKey(paParams, :StartAt)
				@nStartAt = paParams[ :StartAt ]
			ok

			if HasKey(paParams, :AfterYouSkip)
				@nAfterYouSkip = paParams[ :AfterYouSkip ]
			ok
	
			if HasKey(paParams, :WhenYouReach)

				@nWhenYouReach = paParams[ :WhenYouReach ]
			ok

			if HasKey(paParams, :RestartAt)
				@nRestartAt = paParams[ :RestartAt ]
			ok
	
			if HasKey(paParams, :Step)
				@nStep = paParams[ :Step ]
			else
				@nStep = 1
			ok

		but IsEmptyList(paParams)
			# Do nothing, defaults are used

		else
			StzRaise(stzCounterError(:CanNotCreateCounter))
		ok		

	# Returns the first N numbers the counter produces, as a list, restarting at RestartAt each time a cycle ends.
	#
	#   _nNumber_   how many numbers to produce, or [ :To = n ]
	#   returns     a list of numbers
	#   note        with :WhenYouReach = 4 and :RestartAt = 0 the count runs 1, 2, 3, 0, 1, 2, 3, 0;
	#               with :AfterYouSkip = 2 it runs 1, 2, 0, 1, 2, 0
	#   warning     without :WhenYouReach or :AfterYouSkip every number is 0 today, whatever
	#               :StartAt and :Step say (checked with three different option sets)
	#   see         init
	#@ aka  -- Counting (engine-backed, Ring-list-shaped).
	def Counting(_nNumber_)
		_pHandle_ = This._CountingHandle(_nNumber_)
		_anResult_ = StzEngineIntSeqToRingList(_pHandle_)
		StzEngineIntSeqFree(_pHandle_)
		return _anResult_

		def CountingTo(_nNumber_)
			return This.Counting(_nNumber_)

		def Count(_nNumber_)
			return This.Counting(_nNumber_)

		def CountTo(_nNumber_)
			return This.Counting(_nNumber_)

	# Internal: build the engine-side IntSeq and return its handle.
	# Caller is responsible for either materialising via
	# StzEngineIntSeqToRingList + StzEngineIntSeqFree, OR wrapping
	# in stzIntSeq which owns the handle and frees it on Release().

	def _CountingHandle(_nNumber_)
		if isList(_nNumber_) and Q(_nNumber_).IsToNamedParam()
			_nNumber_ = _nNumber_[2]
		ok
		if NOT isNumber(_nNumber_)
			StzRaise("Counting: nNumber must be a number.")
		ok

		_nMode_ = 0
		_nCycleParam_ = 0
		if @nWhenYouReach != 0
			_nMode_ = 1
			_nCycleParam_ = @nWhenYouReach
		but @nAfterYouSkip != 0
			_nMode_ = 2
			_nCycleParam_ = @nAfterYouSkip
		ok

		return StzEngineIntSeqCreateCycle(
			@nStartAt, @nStep, _nCycleParam_, @nRestartAt, _nNumber_, _nMode_
		)

	# CountingQ: returns a live stzIntSeq wrapping the engine handle.
	# Use this when you want engine-fast Sum/Min/Max/At/Len without
	# materialising to a Ring list. The Q suffix is the Softanza
	# convention for "give me the wrapping object", same as
	# StzStringQ etc. -- it is NOT engine-flavoured naming.

	def CountingQ(_nNumber_)
		return new stzIntSeq( This._CountingHandle(_nNumber_) )

		def CountQ(_nNumber_)
			return This.CountingQ(_nNumber_)

		def CountToQ(_nNumber_)
			return This.CountingQ(_nNumber_)

		def CountingToQ(_nNumber_)
			return This.CountingQ(_nNumber_)

	def CountingXT(_nNumber_, paReturnNth)
		/* Example
		_o1_ = new stzCounter([
			:StartAt = 1,
			:WhenYouReach = 5,
			:RestartAt = 1
		])

		? _o1_.CountToXT(9, :ReturnNth = 7)
		#--> 2
		*/

		if isList(_nNumber_) and Q(_nNumber_).IsToNamedParam()
			_nNumber_ = _nNumber_[2]
		ok

		if NOT isNumber(_nNumber_)
			StzRaise("Incorrect param type! nNumber must be a number.")
		ok

		if isList(paReturnNth) and
			( Q(paReturnNth).IsReturnNthNamedParam() or
			  Q(paReturnNth).IsReturnNamedParam() or
			  Q(paReturnNth).IsAndReturnNthNamedParam() or
			  Q(paReturnNth).IsAndReturnNamedParam() or

 			Q(paReturnNth).IsReturningNthNamedParam() or
			  Q(paReturnNth).IsReturningNamedParam() or
			  Q(paReturnNth).IsAndReturningNthNamedParam() or
			  Q(paReturnNth).IsAndReturningNamedParam()
			)

			paReturnNth = paReturnNth[2]
		ok

		if isString(paReturnNth)
			if paReturnNth = :First
				paReturnNth = 1

			but paReturnNth = :Last
				paReturnNth = _nNumber_
			ok
		ok

		if NOT ( isNumber(paReturnNth) and paReturnNth > 0 )
			StzRaise("Incorrect param type! paReturnNth must be a non null number.")
		ok

		_nResult_ = This.Counting(_nNumber_)[ paReturnNth ]
		return _nResult_

		#< @FunctionAlternativeForms

		def CountingToXT(_nNumber_, paReturnNth)
			return This.CountingXT(_nNumber_, paReturnNth)

		def CountXT(_nNumber_, paReturnNth)
			return This.CountingXT(_nNumber_, paReturnNth)

		def CountToXT(_nNumber_, paReturnNth)
			return This.CountingXT(_nNumber_, paReturnNth)

		#>
