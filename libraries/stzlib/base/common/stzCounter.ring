func IsCounterNamedParamList(paParams)
	if NOT isList(paParams)
		return 0
	ok

	nLen = len(paParams)
	if nLen >= 1 and nLen <= 4 and 
	   IsHashList(paParams) and
	   StzHashListQ(paParams).KeysQ().IsMadeOfSome([ :StartAt, :AfterYouSkip, :RestartAt, :Step ])
	
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

			if paParams[ :StartAt ] != ""
				@nStartAt = paParams[ :StartAt ]
			ok

			if paParams[ :AfterYouSkip ] != ""
				@nAfterYouSkip = paParams[ :AfterYouSkip ]
			ok
	
			if paParams[ :WhenYouReach ] != ""

				@nWhenYouReach = paParams[ :WhenYouReach ]
			ok

			if paParams[ :RestartAt ] != ""
				@nRestartAt = paParams[ :RestartAt ]
			ok
	
			if paParams[ :Step ] != ""
				@nStep = paParams[ :Step ]
			else
				@nStep = 1
			ok

		but IsEmptyList(paParams)
			# Do nothing, defaults are used

		else
			StzRaise(stzCounterError(:CanNotCreateCounter))
		ok		

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
