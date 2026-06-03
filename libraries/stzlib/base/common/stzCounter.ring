func IsCounterNamedParamList(paParams)
	if NOT isList(paParams)
		return 0
	ok

	# The validator's allowed-keys list was missing :WhenYouReach
	# (the init() method honours it at line 42 but the validator
	# rejected it). Length cap was 4 but there are 5 valid keys;
	# raised to 5.
	nLen = len(paParams)
	if nLen >= 1 and nLen <= 5 and
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

class stzCounter from stzObject
	@nStartAt = 1
	@nAfterYouSkip = 0
	@nWhenYouReach = 0
	@nRestartAt = 0
	@nStep = 1

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

	#-- Counting (engine-backed, Ring-list-shaped).
	#
	# Returns a Ring list of N values produced by cycling through
	# (@nStartAt, @nStep) under the wrap-around modes :WhenYouReach
	# and :AfterYouSkip. The cycle itself is built by the Zig
	# engine in O(N) (see ring_bridge_intseq.zig), then marshalled
	# into a Ring list via the engine bridge. Callers see a plain
	# list and never need to know an engine handle existed.
	#
	# The previous Ring-only loop (aResult + n inside a class
	# method) was O(N^2) on Ring 1.26 because the attribute table
	# is re-walked per append; the engine path is the only correct
	# implementation now and is named with the natural Softanza
	# verbs (Counting / Count / CountTo / CountingTo). The
	# engine-flavoured *Seq aliases that existed during the
	# bring-up phase have been retired -- callers that genuinely
	# want the raw stzIntSeq handle (e.g. for streaming Sum/Min/Max
	# over a billion-element cycle without materialising) can call
	# the dedicated _Handle accessor below.

	def Counting(nNumber)
		_pHandle_ = This._CountingHandle(nNumber)
		_anResult_ = StzEngineIntSeqToRingList(_pHandle_)
		StzEngineIntSeqFree(_pHandle_)
		return _anResult_

		def CountingTo(nNumber)
			return This.Counting(nNumber)

		def Count(nNumber)
			return This.Counting(nNumber)

		def CountTo(nNumber)
			return This.Counting(nNumber)

	# Internal: build the engine-side IntSeq and return its handle.
	# Caller is responsible for either materialising via
	# StzEngineIntSeqToRingList + StzEngineIntSeqFree, OR wrapping
	# in stzIntSeq which owns the handle and frees it on Release().

	def _CountingHandle(nNumber)
		if isList(nNumber) and Q(nNumber).IsToNamedParam()
			nNumber = nNumber[2]
		ok
		if NOT isNumber(nNumber)
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
			@nStartAt, @nStep, _nCycleParam_, @nRestartAt, nNumber, _nMode_
		)

	# CountingQ: returns a live stzIntSeq wrapping the engine handle.
	# Use this when you want engine-fast Sum/Min/Max/At/Len without
	# materialising to a Ring list. The Q suffix is the Softanza
	# convention for "give me the wrapping object", same as
	# StzStringQ etc. -- it is NOT engine-flavoured naming.

	def CountingQ(nNumber)
		return new stzIntSeq( This._CountingHandle(nNumber) )

		def CountQ(nNumber)
			return This.CountingQ(nNumber)

		def CountToQ(nNumber)
			return This.CountingQ(nNumber)

		def CountingToQ(nNumber)
			return This.CountingQ(nNumber)

	def CountingXT(nNumber, paReturnNth)
		/* Example
		o1 = new stzCounter([
			:StartAt = 1,
			:WhenYouReach = 5,
			:RestartAt = 1
		])

		? o1.CountToXT(9, :ReturnNth = 7)
		#--> 2
		*/

		if isList(nNumber) and Q(nNumber).IsToNamedParam()
			nNumber = nNumber[2]
		ok

		if NOT isNumber(nNumber)
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
				paReturnNth = nNumber
			ok
		ok

		if NOT ( isNumber(paReturnNth) and paReturnNth > 0 )
			StzRaise("Incorrect param type! paReturnNth must be a non null number.")
		ok

		nResult = This.Counting(nNumber)[ paReturnNth ]
		return nResult

		#< @FunctionAlternativeForms

		def CountingToXT(nNumber, paReturnNth)
			return This.CountingXT(nNumber, paReturnNth)

		def CountXT(nNumber, paReturnNth)
			return This.CountingXT(nNumber, paReturnNth)

		def CountToXT(nNumber, paReturnNth)
			return This.CountingXT(nNumber, paReturnNth)

		#>
