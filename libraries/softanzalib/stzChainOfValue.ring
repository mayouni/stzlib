
$bRandomPass = TRUE
$pStopValue = NULL

$bExecuteCode = FALSE

$cValueInitiator = NULL

$cOneOrManyLoops = :One
$bRequiresStopValue = FALSE

func Whatever(p)
	$cValueInitiator = :Whatever

	$cOneOrManyLoops = :One
	$bRequiresStopValue = FALSE

	$bExecuteCode = TRUE

	return new stzChainOfValue(p)

func OnlyWhen(p)
	$cValueInitiator = :OnlyWhen

	$cOneOrManyLoops = :One
	$bRequiresStopValue = FALSE

	$bExecuteCode = TRUE

	return new stzChainOfValue(p)

func Until(p)
	$cValueInitiator = :Until

	$cOneOrManyLoops = :Many
	$bRequiresStopValue = FALSE

	$bExecuteCode = TRUE

	return new stzChainOfValue(p)

func Since(p)
	$cValueInitiator = :Since

	$cOneOrManyLoops = :Many

	$bRequiresStopValue = TRUE
	$bExecuteCode = FALSE

	return new stzChainOfValue(p)

func SometimesWhen(p)
	$cValueInitiator = :SometimesWhen

	$cOneOrManyLoops = :One
	$bRequiresStopValue = FALSE

	$bRandomPass = random(1)

	$bExecuteCode = TRUE

	return new stzChainOfValue(p)

func ThisValue(pValue)
	return new stzChainOfValue(pValue)
		
class stzChainOfValue from stzObject
	@cVarName
	@pValue
	@cType

	Is
	IsNot
	_Not
	_Do
	Execute
	Becomes

	@bChainStopped = FALSE
	@aWhyChainStopped = [ "Because..." ]

	@cCode = NULL
	@bCodeHasBeenCalled = FALSE

	@cCodeStatus = :NotYetExecuted # :HasBeenExecuted
	@aWhyCodeNotExecuted = [ "Because..." ]

	@cCodeCaller = NULL
	@cCodeExecutor = NULL

	@bNegateNext = FALSE

	@bBecomesIsUsedBeforeDoThis = FALSE

	#----------------------

	def init(pcVarName)
? locals()
		@cVarName = pcVarName

		cCode = '@pValue = ' + @cVarName
		eval(cCode)
		
		@cType = ring_type(@pValue)

		Is = This
		IsNot = This
		Not_ = This
		Do_ = This
		Execute = This
		Becomes = This

	#----------------------

	def VarName()
		return @cVarName

	def Value()
		return @pValue

	def _Type()
		return @cType

	def Copy()
		return new stzChainOfValue( This.VarName() )

	def Update(pValue)
		if isList(pValue) and
		   ( StzListQ(pValue).IsWithNamedParam() or StzListQ(pValue).IsUsingNamedParam() )

			pValue = pValue[2]

		ok

		@pValue = pValue

	def Code()
		return @cCode

	def StopValue()
		return $pStopValue

	#----------------------

	def getIs()
		@bNegateNext = FALSE
		@cOneOrManyLoops = :One

		return This

	def getIsNot()
		@bNegateNext = TRUE
		@cOneOrManyLoops = :One

		return This

	def get_Not()
		@bNegateNext = TRUE
		@cOneOrManyLoops = :One

		return This

	def getBecomes()
		@bNegateNext = FALSE
		$cOneOrManyLoops = :Many

		return This

	#------------------

	def _Which()
		return This.ToStzObject()

		#< @FunctionAlternativeForm

	def _That()
		return This.ToStzObject()

	def _AND()
		return This.ToStzObject()

	def _OR()
		return This.ToStzObject()

	def _But()
		return This.ToStzObject()

	#-------------------

	def Is(pValue)

		@cOneOrManyLoops = :One

		switch This.ValueInitiator()
		on :Whatever
			This.StopChain([ 'Because there is a semantic error: "Whatever" does not support using "Is()" after it!' ])
			return This

		on :Until

			if NOT BothHaveSameType( This.Value(), pValue )	 
				This.StopChain([ "Because value provided has not same type as main value!" ])
				return This
			ok

			if AreBothEqual( This.Value(), pValue )	 
				This.StopChain([ "Because values are equal and :Until is reatched!" ])
				return This
			ok

			$pStopValue = pValue
			
		on :OnlyWhen
			if NOT BothHaveSameType( This.Value(), pValue )	 
				This.StopChain([ "Because value provided has not same type as main value!" ])
				return This
			ok

			if NOT AreBothEqual( This.Value(), pValue )	 
				This.StopChain([ "Because value provided is not equal to main value!" ])
				return This
			ok

		on :SometimesWhen

			IF NOT AreBothEqual( This.Value(), pValue )

				This.StopChain([ "Because equality will never happen, since values are actually different!" ])
				return This
			ok

			if $bRandomPass = FALSE
				This.StopChain([ "Well, because values are equal but, you'r not lucky ;)!" ])
				return This
			ok

		on :Since
			IF NOT AreBothEqual( This.Value(), pValue )
				This.StopChain([ "This Since() chain is not enclenched because values are different!" ])
				return This
			ok

			$bExecuteCode = FALSE		
		off

		return This

		#< @FunctionAlternativeForm

		def IsEqualTo(pValue)
			return This.Is(pValue)

		#>

	def Becomes(pValue)
		if This.CodeHasBeenCalled()
			@bBecomesIsUsedBeforeDoThis = FALSE
		else
			@bBecomesIsUsedBeforeDoThis = TRUE
		ok

		$pStopValue = pValue

		if @bBecomesIsUsedBeforeDoThis

	
			If NOT BothHaveSameType( pValue, This.Value() )
				This.StopChain([ "Because target value has no same type as main value!" ])
	
			ok
	
			if AreBothEqual( This.Value(), $pStopValue )
				This.StopChain([ "Because target value has been reatched!" ])
			ok
			
			@cOneOrManyLoops = :Many

		else # --> Becomes() is used AFTER DoThis()

			if This.ValueInitiator() = :Since

				$bExecuteCode = TRUE
				@cCodeExecutor = :Becomes

				@cCode = 'if ' + This.VarName() + ' = This.StopValue()' + NL +
					TAB + 'return This' + NL +
					'else' + NL +
					TAB + This.Code() + NL +
				'ok'
	
				This.DoThis(This.Code())
			ok
		ok

		return This

		#< @FunctionAlternativeForm

		def BecomesEqualTo(pValue)
			return This.Becomes(pValue)

		#>

	def BecomesIsUsedBeforeDoThis()
		return @bBecomesIsUsedBeforeDoThis

	def BecomesIsUsedAfterDoThis()
		return NOT @bBecomesIsUsedBeforeDoThis

	#-------------------

	def StopWhen(p)
		eval('$pStopValue = ' + ComputableForm(p))
		return This

	def DoThis(pcCode)
		@cCode = StzStringQ(pcCode).TrimQ().BoundsRemoved("{","}")

		@bCodeHasBeenCalled = TRUE
		@cCodeCaller = :Dothis

		if This.ChainStatus() = :Ongoing

			if $bExecuteCode = TRUE
	
				if $cOneOrManyLoops = :One
					eval(This.Code())
					@cCodeStatus = :HasBeenExecuted
					@cCodeExecutor = :DoThis
					$bExecuteCode = FALSE
					
				else
					
					While NOT BothAreEqual(This.Value(), $pStopValue )		      
						eval(This.Code())
						@cCodeStatus = :HasBeenExecuted
						@cCodeExecutor = :DoThis

						eval('This.Update(' + This.VarName() + ')')
					end
				ok

			else #  $bExecuteCode = FALSE

				 @aWhyCodeNotExecuted = [ 'Because "Since(:v)" requires "DoThis(:v)" not to execute until it knows where it should stop, using "StopWhen().Becomes()"!' ]

			ok

		ok

		return This

		#< @FunctionAlternativeForms

		def Do_(pcCode)
			This.DoThis(pcCode)
	
		#>

	def GetDo_()
		$bExecuteCode = TRUE
		return This

		#< @FunctionAlternativeForm

		def GetCodeExecute()
			return GetDo_()

		#>

	def This_(cCode)
		if $bExecuteCode
			DoThis(cCode)
		ok

	#-----------------

	def ValueInitiator()
		return $cValueInitiator

	def StopChain( paStopInfo )
		@bChainStopped = TRUE
		@aWhyChainStopped = paStopInfo

	def ChainStatus()
		if @bChainStopped = TRUE
			return :Stopped
		else
			return :Ongoing
		ok

	def WhyChainIsStopped()
		if This.ChainStatus() = :Stopped
			return @aWhyChainStopped
		else
			return "Chain is not stopped!"
		ok

		def WhyChainStopped()
			return This.WhyChainIsStopped()

	def OneOrManyLoops()
		return $cOneOrManyLoops

	def RequiresStopValue()
		return $bRequiresStopValue

	def CodeStatus()
		return @cCodeStatus

	def WhyCodeNotYetExecuted()
		if This.CodeStatus() = :NotYetExecuted
			if @bCodeHasBeenCalled
				return @aWhyCodeNotExecuted
			else
				return [ 'Code has not been called yet (using "DoThis()")' ]
			ok
		else
			return [ 'Code has been executed!' ]
		ok

		def WhyCodeHasNotBeenExecuted()
			return WhyCodeNotYetExecuted()

	def CodeHasBeenCalled()
		return @bCodeHasBeenCalled

	def CodeHasBeenExecuted()
		if This.CodeStatus() = :HasBeenExecuted
			return TRUE
		else
			return FALSE
		ok

	def CodeIsStillWaitingForExecution()
		if This.CodeHasBeenExecuted()
			return FALSE
		else
			return TRUE
		ok

	#-------------------

	def ToStzObject()
		switch Upper(type(This.Value()))
		on "NUMBER"
			return new stzList(This.Value())
		on "STRING"
			return new stzString(This.Value())
		on "LIST"
			return new stzList(This.Value())
		on "OBJECT"
			return new stzObject(This.Value())
		off

	#----------------------

	def IsANumber()

		if upper(This._Type()) = "NUMBER"	
			return This
		else

			return This
		ok

		#< @FunctionFluentForm

		def IsANumberQ()

			if $bRandomPass = FALSE
				This.StopChain()
				return This
			ok
	
			if NOT @bNegateNext
				if NOT isNumber(This.Value())
					This.StopChain()
					return This
				ok
			else
				if isNumber(This.Value())
					This.StopChain()
					return This
				ok

			ok
	
			return This

		#>

		#< @FunctionAlternativeForm

		def ANumber()
			return This.IsANumber()

			#< @FunctionAlternativeForm

			def ANumberQ()
				return This.IsANumberQ()

			#>

		#>

		#< @FunctionNegativeForm

		def IsNotANumber()
			return NOT This.IsANumber()

			#< @FunctionFluentForm

			def IsNotANumberQ()
				if isNumber(This.Value())
					This.StopChain()
					return This
				ok

				return This

			#>

		def NotANumber()
			return This.IsNotANumber()

			#< @FunctionFluentForm

			def NotANumberQ()
				return This.IsNotANumberQ()

			#>

		#>

	#----------------------

	def IsAString()
		if upper(This._Type()) = "STRING"
			return TRUE
		else
			return FALSE
		ok


		#< @FunctionFluentForm

		def IsAStringQ()

			if NOT @bNegateNext
				if NOT isString(This.Value())
					This.StopChain()
					return This
				ok
			else
				if isString(This.Value())
					This.StopChain()
					return This
				ok

			ok
	
			return This

		#>

		#< @FunctionNegativeForm

		def IsNotAString()
			return NOT This.IsAString()

			#< @FunctionFluentForm

			def IsNotAStringQ()
				if isString(This.Value())
					This.StopChain()
					return This
				ok

				return This

			#>

		def NotAString()
			return This.IsNotAString()

			#< @FunctionFluentForm

			def NotAStringQ()
				return This.IsNotAStringQ()

			#>

		#>

		#< @FunctionAlternativeForm

		def AString()
			return This.IsAString()

			#< @FunctionAlternativeForm

			def AStringQ()
				return This.IsAStringQ()

			#>

		#>

	#----------------------

	def IsAList()

	#----------------------

	def IsAnObject()

