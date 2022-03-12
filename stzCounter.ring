func IsCounterParamList(paParams)
	return StzListQ(paParams).IsCounterParamList()

func StzCounterQ(paParams)
	return new stzCounter(paParams)

class stzCounter from stzObject
	@nStartAt = 1
	@nAfterYouSkip = 9
	@nRestartAt = 0
	@nStep = 1

	def init(paParams)

		if isList(paParams) and
		   IsCounterParamList(paParams)

			if paParams[ :StartAt ] != NULL
				@nStartAt = paParams[ :StartAt ]
			ok

			if paParams[ :AfterYouSkip ] != NULL
				@nAfterYouSkip = paParams[ :AfterYouSkip ]
			ok
	
			if paParams[ :RestartAt ] != NULL
				@nRestartAt = paParams[ :RestartAt ]
			ok
	
			if paParams[ :Step ] != NULL
				@nStep = paParams[ :Step ]
			ok

		but IsEmptyList(paParams)
			# Do nothing, defaults are used

		else
			raise(stzCounterError(:CanNotCreateCounter))
		ok		

	def CountTo(nNumber)
		return This.CountingTo(nNumber)[ len(This.CountingTo(nNumber)) ]

	def CountingTo(nNumber)
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
