func IsCounterNamedParamList(paParams)
	if isList(paParams) and
	   StzNumberQ( Q(paParams).NumberOfItems() ).IsBetween(1, 4) and

	   Q(paParams).IsHashList() and
	   StzHashListQ(paParams).KeysQ().IsMadeOfSome([ :StartAt, :AfterYouSkip, :RestartAt, :Step ])
	
			return TRUE
		else
			return FALSE
		ok

func StzCounterQ(paParams)
	return new stzCounter(paParams)

class stzCounter from stzObject
	@nStartAt = 1
	@nAfterYouSkip = 0
	@nRestartAt = 0
	@nStep = 1

	def init(paParams)

		if isList(paParams) and
		   IsCounterNamedParamList(paParams)

			if paParams[ :StartAt ] != NULL
				@nStartAt = paParams[ :StartAt ]
			ok

			if paParams[ :AfterYouSkip ] != NULL
				@nAfterYouSkip = paParams[ :AfterYouSkip ]
			ok
	
			if paParams[ :WhenYouReach ] != NULL
				@nAfterYouSkip = paParams[ :WhenYouReach ] - 1
			ok

			if paParams[ :RestartAt ] != NULL
				@nRestartAt = paParams[ :RestartAt ]
			ok
	
			if paParams[ :Step ] != NULL
				@nStep = paParams[ :Step ]
			else
				@nStep = 1
			ok

		but IsEmptyList(paParams)
			# Do nothing, defaults are used

		else
			stzRaise(stzCounterError(:CanNotCreateCounter))
		ok		

	def Counting(nNumber)
		if isList(nNumber) and Q(nNumber).IsToNamedParam()
			nNumber = nNumber[2]
		ok

		if NOT isNumber(nNumber)
			stzRaise("Incorrect param type! nNumber must be a number.")
		ok

		aResult = []
		n =  @nStartAt

		for i = @nStartAt to nNumber step @nStep

			if i % (@nAfterYouSkip + 1) = 0
				n = @nRestartAt
			ok

			aResult + n
			n++
		end

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
			stzRaise("Incorrect param type! nNumber must be a number.")
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
			stzRaise("Incorrect param type! paReturnNth must be a non null number.")
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
