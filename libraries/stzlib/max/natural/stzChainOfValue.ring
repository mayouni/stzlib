
$bRandomPass = _TRUE_
$pStopValue = _NULL_

$bExecuteCode = _FALSE_

$cValueInitiator = _NULL_

$cOneOrManyLoops = :One
$bRequiresStopValue = _FALSE_

func Whatever(p)
	$cValueInitiator = :Whatever

	$cOneOrManyLoops = :One
	$bRequiresStopValue = _FALSE_

	$bExecuteCode = _TRUE_

	return new stzChainOfValue(p)

func OnlyWhen(p)
	$cValueInitiator = :OnlyWhen

	$cOneOrManyLoops = :One
	$bRequiresStopValue = _FALSE_

	$bExecuteCode = _TRUE_

	return new stzChainOfValue(p)

func Until(p)
	$cValueInitiator = :Until

	$cOneOrManyLoops = :Many
	$bRequiresStopValue = _FALSE_

	$bExecuteCode = _TRUE_

	return new stzChainOfValue(p)

func Since(p)
	$cValueInitiator = :Since

	$cOneOrManyLoops = :Many

	$bRequiresStopValue = _TRUE_
	$bExecuteCode = _FALSE_

	return new stzChainOfValue(p)

func SometimesWhen(p)
	$cValueInitiator = :SometimesWhen

	$cOneOrManyLoops = :One
	$bRequiresStopValue = _FALSE_

	$bRandomPass = random(1)

	$bExecuteCode = _TRUE_

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

	@bChainStopped = _FALSE_
	@aWhyChainStopped = [ "Because..." ]

	@cCode = _NULL_
	@bCodeHasBeenCalled = _FALSE_

	@cCodeStatus = :NotYetExecuted # :HasBeenExecuted
	@aWhyCodeNotExecuted = [ "Because..." ]

	@cCodeCaller = _NULL_
	@cCodeExecutor = _NULL_

	@bNegateNext = _FALSE_

	@bBecomesIsUsedBeforeDoThis = _FALSE_

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

	  #-------------------------------#
	 #  UPDATING THE CHAIN OF VALUE  #
	#-------------------------------#

	def Update(pValue)
		if CheckingParams() = _TRUE_
			if isList(pValue) and Q(pValue).IsWithOrByOrUsingNamedParam()
				cNewCode = cNewCode[2]
			ok
		ok

		@pValue = pValue

		if KeepingHisto() = _TRUE_
			This.AddHistoricValue(This.Content())  # From the parent stzObject
		ok

		#< @FunctionFluentForm

		def UpdateQ(pValue)
			This.Update(pValue)
			return This

		#>

		#< @FunctionAlternativeForms

		def UpdateWith(pValue)
			This.Update(pValue)

			def UpdateWithQ(pValue)
				return This.UpdateQ(pValue)
	
		def UpdateBy(pValue)
			This.Update(pValue)

			def UpdateByQ(pValue)
				return This.UpdateQ(pValue)

		def UpdateUsing(pValue)
			This.Update(pValue)

			def UpdateUsingQ(pValue)
				return This.UpdateQ(pValue)

		#>

	def Updated(pValue)
		return pValue

		#< @FunctionAlternativeForms

		def UpdatedWith(pValue)
			return This.Updated(pValue)

		def UpdatedBy(pValue)
			return This.Updated(pValue)

		def UpdatedUsing(pValue)
			return This.Updated(pValue)

		#>

	  #------------------------------------------#
	 #  GETTING THE CODE OF THE CHAIN OF VALUE  #
	#------------------------------------------#

	def Code()
		return @cCode

	def StopValue()
		return $pStopValue

	#----------------------

	def getIs()
		@bNegateNext = _FALSE_
		@cOneOrManyLoops = :One

		return This

	def getIsNot()
		@bNegateNext = _TRUE_
		@cOneOrManyLoops = :One

		return This

	def get_Not()
		@bNegateNext = _TRUE_
		@cOneOrManyLoops = :One

		return This

	def getBecomes()
		@bNegateNext = _FALSE_
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

			if $bRandomPass = _FALSE_
				This.StopChain([ "Well, because values are equal but, you'r not lucky ;)!" ])
				return This
			ok

		on :Since
			IF NOT AreBothEqual( This.Value(), pValue )
				This.StopChain([ "This Since() chain is not enclenched because values are different!" ])
				return This
			ok

			$bExecuteCode = _FALSE_		
		off

		return This

		#< @FunctionAlternativeForm

		def IsEqualTo(pValue)
			return This.Is(pValue)

		def Equals(pValue)
			return This.Is(pValue)

		#>

	def Becomes(pValue)
		if This.CodeHasBeenCalled()
			@bBecomesIsUsedBeforeDoThis = _FALSE_
		else
			@bBecomesIsUsedBeforeDoThis = _TRUE_
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

		else #--> Becomes() is used AFTER DoThis()

			if This.ValueInitiator() = :Since

				$bExecuteCode = _TRUE_
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
		@cCode = StzStringQ(pcCode).TrimQ().TheseBoundsRemoved("{","}")

		@bCodeHasBeenCalled = _TRUE_
		@cCodeCaller = :Dothis

		if This.ChainStatus() = :Ongoing

			if $bExecuteCode = _TRUE_
	
				if $cOneOrManyLoops = :One
					eval(This.Code())
					@cCodeStatus = :HasBeenExecuted
					@cCodeExecutor = :DoThis
					$bExecuteCode = _FALSE_
					
				else
					
					While NOT BothAreEqual(This.Value(), $pStopValue )		      
						eval(This.Code())
						@cCodeStatus = :HasBeenExecuted
						@cCodeExecutor = :DoThis

						eval('This.Update(' + This.VarName() + ')')
					end
				ok

			else #  $bExecuteCode = _FALSE_

				 @aWhyCodeNotExecuted = [ 'Because "Since(:v)" requires "DoThis(:v)" not to execute until it knows where it should stop, using "StopWhen().Becomes()"!' ]

			ok

		ok

		return This

		#< @FunctionAlternativeForms

		def Do_(pcCode)
			This.DoThis(pcCode)
	
		#>

	def GetDo_()
		$bExecuteCode = _TRUE_
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
		@bChainStopped = _TRUE_
		@aWhyChainStopped = paStopInfo

	def ChainStatus()
		if @bChainStopped = _TRUE_
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
			return _TRUE_
		else
			return _FALSE_
		ok

	def CodeIsStillWaitingForExecution()
		if This.CodeHasBeenExecuted()
			return _FALSE_
		else
			return _TRUE_
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

			if $bRandomPass = _FALSE_
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

		#< @FunctionPassiveForm

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
			return _TRUE_
		else
			return _FALSE_
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

		#< @FunctionPassiveForm

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

