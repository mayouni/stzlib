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

	# PERF NOTE (Ring 1.26):
	# Counting() builds a list of N cycled values. We tested two
	# implementations on Ring 1.26 and both scale as O(N^2):
	#
	# 1. Ring-side loop with `aResult + n` (the current code below).
	#    Reference: 0.91 s for N=1,000,000 on Ring 1.23. On 1.26 the
	#    same body takes >60 s for N=100,000 because class-method-
	#    local `aResult + n` walks the object attribute table.
	#
	# 2. Engine bridge `StzEngineCounterFill` -- a Zig function that
	#    builds the list in one C call via ring_list_adddouble. Was
	#    expected to win big but turned out NO FASTER than (1): each
	#    `ring_list_adddouble` call appears O(N) at the Ring C-API
	#    level (probably re-walking pLast). FFI per-call overhead
	#    dominates.
	#
	# The engine entry point is wired (see ring_bridge_sequence.zig)
	# and remains available for callers that benefit at smaller N,
	# but the production hot path stays on the Ring loop because
	# it's the simpler, equally-fast option until either Ring fixes
	# ring_list_adddouble or we add a true batch-fill C API.
	#
	# Modular test 05_softanza_1M_perf.ring records the 0.91 s
	# Ring-1.23 baseline as the regression target.

	def Counting(nNumber)
		if CheckingParams()
			if isList(nNumber) and Q(nNumber).IsToNamedParam()
				nNumber = nNumber[2]
			ok

			if NOT isNumber(nNumber)
				StzRaise("Incorrect param type! nNumber must be a number.")
			ok
		ok

		aResult = []
		n =  @nStartAt

		if @nWhenYouReach != 0

			for i = @nStartAt to nNumber step @nStep

				if i = @nWhenYouReach
					n = @nRestartAt
				ok

				aResult + n
				n++
				if n = @nWhenYouReach
					n = @nRestartAt
				ok

			next

		but @nAfterYouSkip != 0

			for i = @nStartAt to nNumber step @nStep

				if i % (@nAfterYouSkip + 1) = 0
					n = @nRestartAt
				ok

				aResult + n
				n++
				if n = @nAfterYouSkip + 1
					n = @nRestartAt
				ok

			next

		ok

		return aResult

		#< @FunctionAlternativeForms

		def CountingTo(nNumber)
			return This.Counting(nNumber)

		def Count(nNumber)
			return This.Counting(nNumber)

		def CountTo(nNumber)
			return This.Counting(nNumber)

		#>

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
