
$bRandomPass = 1
$pStopValue = ""

$bExecuteCode = 0

$cValueInitiator = ""

$cOneOrManyLoops = :One
$bRequiresStopValue = 0

func Whatever(p)
	$cValueInitiator = :Whatever

	$cOneOrManyLoops = :One
	$bRequiresStopValue = 0

	$bExecuteCode = 1

	return new stzChainOfValue(p)

func OnlyWhen(p)
	$cValueInitiator = :OnlyWhen

	$cOneOrManyLoops = :One
	$bRequiresStopValue = 0

	$bExecuteCode = 1

	return new stzChainOfValue(p)

func Until(p)
	$cValueInitiator = :Until

	$cOneOrManyLoops = :Many
	$bRequiresStopValue = 0

	$bExecuteCode = 1

	return new stzChainOfValue(p)

func Since(p)
	$cValueInitiator = :Since

	$cOneOrManyLoops = :Many

	$bRequiresStopValue = 1
	$bExecuteCode = 0

	return new stzChainOfValue(p)

func SometimesWhen(p)
	$cValueInitiator = :SometimesWhen

	$cOneOrManyLoops = :One
	$bRequiresStopValue = 0

	$bRandomPass = StzEngineRandomInt(0, 1)

	$bExecuteCode = 1

	return new stzChainOfValue(p)

func ThisValue(pValue)
	return new stzChainOfValue(pValue)
		
# Watches one variable of the caller and runs a piece of code only if the variable meets a condition, written as a near-natural chain.
#
# A chain is born from an initiator function (Whatever, OnlyWhen, Until, Since, SometimesWhen) that
# names the variable as a symbol, and each link returns the chain itself: Is compares the value,
# DoThis runs the code. A link that is not satisfied does not raise an error, it stops the chain:
# ChainStatus then answers stopped, WhyChainStopped carries the reasons as a list of texts, and
# DoThis on a stopped chain runs nothing. OnlyWhen runs the code once when the values are equal;
# Until repeats it until the variable equals the stop value; Since waits for Becomes to name where
# it ends. The loop mode, the run flag and the stop value are shared by every chain of the process,
# and a new initiator call resets them. The value held is a snapshot taken when the chain is built.
# IsANumber, IsNotANumber, IsAList, IsAnObject and ToStzObject on a number do not work today.
#
#   receiver   v = 5; o1 = OnlyWhen(:v).Is(5)
#   example    ? o1.ChainStatus()
#              #--> ongoing
#              o1.DoThis('{ v = v + 10 }')
#              ? v
#              #--> 15
#              ? o1.CodeStatus()
#              #--> hasbeenexecuted
#              ? @@( OnlyWhen(:v).Is(6).WhyChainStopped() )
#              #--> [ "Because value provided is not equal to main value!" ]
#              Until(:v).Is(20).DoThis('{ v = v + 1 }')
#              ? v
#              #--> 20
#   see        stzChainOfTruth, stzObject
class stzChainOfValue from stzObject
	@cVarName
	@pValue
	@cType

	Is
	_IsNot_
	_Not
	_Do
	_Execute_
	Becomes

	@bChainStopped = 0
	@aWhyChainStopped = [ "Because..." ]

	@cCode = ""
	@bCodeHasBeenCalled = 0

	@cCodeStatus = :NotYetExecuted # :HasBeenExecuted
	@aWhyCodeNotExecuted = [ "Because..." ]

	@cCodeCaller = ""
	@cCodeExecutor = ""

	@bNegateNext = 0

	@bBecomesIsUsedBeforeDoThis = 0

	# Builds a chain over the caller's variable named by the text, reading its value now; an unknown name starts the chain already stopped.
	#
	#   pcVarName   the NAME of the caller's variable the chain watches, as text, such as :v for the
	#               variable v
	#   returns     nothing; the object is built
	#   note        when the variable does not exist the chain is stopped and WhyChainStopped names
	#               it, so no error is raised
	#   warning     the initiator functions Whatever, OnlyWhen, Until, Since and SometimesWhen build
	#               the chain for you and also set the shared flags that decide whether the code
	#               runs once or in a loop
	#   see         VarName, Value, ChainStatus
	#----------------------
	def init(pcVarName)
		@cVarName = pcVarName

		# Resolve the wrapped variable from the caller's scope by
		# evaluating '@pValue = <name>'. If the caller forgot to set
		# <name> first, Ring raises R24. We catch and start the chain
		# in 'stopped' state so the user-facing API (Is / DoThis /
		# WhyChainStopped) can still report a clean diagnostic
		# instead of bringing the whole process down.
		_cCode_ = '@pValue = ' + @cVarName
		try
			eval(_cCode_)
		catch
			@pValue = ""
			@bChainStopped = 1
			@aWhyChainStopped = [
				"Because the variable " + @cVarName +
				" is not defined in the caller's scope."
			]
		done

		@cType = ring_type(@pValue)

		Is = This
		_IsNot_ = This
		_Not__ = This
		Do_ = This
		_Execute_ = This
		Becomes = This

	# Returns the name of the caller's variable that this chain watches.
	#
	#   returns    a text
	#   see        Value, Copy
	#----------------------
	def VarName()
		return @cVarName

	# Returns the value read from the watched variable when the chain was built, or the last value given to Update.
	#
	#   returns    the held value, of any type
	#   note       it is a snapshot: changing the caller's variable afterwards does not change it
	#   see        Update, VarName
	def Value()
		return @pValue

	def _Type()
		return @cType

	# Builds a new chain over the same variable name, reading the variable's current value again.
	#
	#   returns    a new stzChainOfValue
	#   warning    the copy forgets Update: it holds what the caller's variable holds now, not the
	#              value given to Update
	#   see        VarName, Value
	def Copy()
		return new stzChainOfValue( This.VarName() )

	  #-------------------------------#
	 #  UPDATING THE CHAIN OF VALUE  #
	#-------------------------------#

	# Replaces the value the chain holds; the caller's variable is left as it is.
	#
	#   pValue     the new value to hold
	#   returns    nothing; use UpdateQ to chain
	#   note       UpdateQ is the same call and returns the chain
	#   see        UpdateWith, Updated, Value
	def Update(pValue)
		if CheckingParams() = 1
			if isList(pValue) and Q(pValue).IsWithOrByOrUsingNamedParam()
				_cNewCode_ = _cNewCode_[2]
			ok
		ok

		@pValue = pValue

		if KeepingHisto() = 1
			This.AddHistoricValue(This.Content())  # From the parent stzObject
		ok

		#< @FunctionFluentForm

		def UpdateQ(pValue)
			This.Update(pValue)
			return This

		# Replaces the value the chain holds; the caller's variable is left as it is.
		#
		#   pValue     the new value to hold
		#   returns    nothing; use UpdateWithQ to chain
		#   note       the same call as Update
		#   see        Update, UpdateBy
		#>
		#< @FunctionAlternativeForms
		def UpdateWith(pValue)
			This.Update(pValue)

			def UpdateWithQ(pValue)
				return This.UpdateQ(pValue)
	
		# Replaces the value the chain holds; the caller's variable is left as it is.
		#
		#   pValue     the new value to hold
		#   returns    nothing; use UpdateByQ to chain
		#   note       the same call as Update
		#   see        Update, UpdateUsing
		def UpdateBy(pValue)
			This.Update(pValue)

			def UpdateByQ(pValue)
				return This.UpdateQ(pValue)

		# Replaces the value the chain holds; the caller's variable is left as it is.
		#
		#   pValue     the new value to hold
		#   returns    nothing; use UpdateUsingQ to chain
		#   note       the same call as Update
		#   see        Update, UpdateWith
		def UpdateUsing(pValue)
			This.Update(pValue)

			def UpdateUsingQ(pValue)
				return This.UpdateQ(pValue)

	# Returns the value it is given, unchanged, and touches neither the chain nor the caller's variable.
	#
	#   pValue     the value to hand back
	#   returns    the same value as the argument
	#   note       UpdatedWith, UpdatedBy and UpdatedUsing are the same call
	#   see        Update, Value
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

	# Returns the text of the code given to the last DoThis, with its surrounding braces removed.
	#
	#   returns    a text; empty before any DoThis
	#   see        DoThis, CodeStatus
	def Code()
		return @cCode

	# Returns the value at which a looping chain stops, as last set by Until(...).Is, Becomes or StopWhen.
	#
	#   returns    the stop value, of any type; empty text before one is set
	#   note       it is shared by every chain of the process, not kept per chain
	#   see        StopWhen, Becomes, OneOrManyLoops
	def StopValue()
		return $pStopValue

	# Returns the chain after switching off negation and one-pass mode; it runs when the Is attribute of the chain is read.
	#
	#   returns    the chain itself, so calls chain
	#   note       reading Whatever(:v).Is and then calling DoThis is the near-natural form of this
	#              call
	#   see        Is, getIsNot
	#----------------------
	def getIs()
		@bNegateNext = 0
		@cOneOrManyLoops = :One

		return This

	# Returns the chain after switching negation on and one-pass mode; it is meant to run when the IsNot attribute is read.
	#
	#   returns    the chain itself, so calls chain
	#   warning    reading the attribute IsNot raises error R12 property not found, because the
	#              attribute is named _IsNot_; call getIsNot() itself to get the chain
	#   see        getIs, get_Not
	def getIsNot()
		@bNegateNext = 1
		@cOneOrManyLoops = :One

		return This

	# Returns the chain after switching negation on and one-pass mode; it runs when the _Not attribute is read.
	#
	#   returns    the chain itself, so calls chain
	#   see        getIsNot, getIs
	def get_Not()
		@bNegateNext = 1
		@cOneOrManyLoops = :One

		return This

	# Returns the chain after putting the process in many-loops mode; it runs when the Becomes attribute is read.
	#
	#   returns    the chain itself, so calls chain
	#   note       the loop mode is a flag shared by every chain
	#   see        Becomes, OneOrManyLoops
	def getBecomes()
		@bNegateNext = 0
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

	# Compares the held value with pValue and stops the chain when the initiator's condition is not met; otherwise lets it go on.
	#
	#   pValue     the value the held value must equal, of the same type
	#   returns    the chain itself, so calls chain
	#   note       IsEqualTo and Equals are the same call
	#   warning    with Whatever the call always stops the chain, with the reason that Whatever does
	#              not support Is; with Until the chain stops when the values are equal, and
	#              otherwise remembers pValue as the stop value
	#   see        WhyChainStopped, OnlyWhen, Until, Since
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

			if $bRandomPass = 0
				This.StopChain([ "Well, because values are equal but, you'r not lucky ;)!" ])
				return This
			ok

		on :Since
			IF NOT AreBothEqual( This.Value(), pValue )
				This.StopChain([ "This Since() chain is not enclenched because values are different!" ])
				return This
			ok

			$bExecuteCode = 0		
		off

		return This

		#< @FunctionAlternativeForm

		def IsEqualTo(pValue)
			return This.Is(pValue)

		def Equals(pValue)
			return This.Is(pValue)

	# Sets the value at which the chain stops looping, or, after DoThis on a Since chain, runs the stored code until the variable reaches it.
	#
	#   pValue     the value the variable must reach, of the same type as the held value
	#   returns    the chain itself, so calls chain
	#   note       BecomesEqualTo is the same call
	#   warning    before DoThis, the chain stops when the types differ or when the held value
	#              already equals pValue, with the reason in WhyChainStopped
	#   see        StopWhen, DoThis, Since
		#>
	def Becomes(pValue)
		if This.CodeHasBeenCalled()
			@bBecomesIsUsedBeforeDoThis = 0
		else
			@bBecomesIsUsedBeforeDoThis = 1
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

				$bExecuteCode = 1
				@cCodeExecutor = :Becomes

				@cCode = 'if ' + This.VarName() + ' = This.StopValue()' + char(10) +
					char(9) + 'return This' + char(10) +
					'else' + char(10) +
					char(9) + This.Code() + char(10) +
				'ok'
	
				This.DoThis(This.Code())
			ok
		ok

		return This

		#< @FunctionAlternativeForm

		def BecomesEqualTo(pValue)
			return This.Becomes(pValue)

	# TRUE if Becomes was called before any DoThis, which makes it set the stop value instead of running code.
	#
	#   returns    1 or 0
	#   note       0 until Becomes is called
	#   see        BecomesIsUsedAfterDoThis, Becomes
		#>
	def BecomesIsUsedBeforeDoThis()
		return @bBecomesIsUsedBeforeDoThis

	# TRUE if Becomes was not called before DoThis, which is also the answer when it was never called.
	#
	#   returns    1 or 0
	#   see        BecomesIsUsedBeforeDoThis, Becomes
	def BecomesIsUsedAfterDoThis()
		return NOT @bBecomesIsUsedBeforeDoThis

	# Sets the value at which a looping chain stops, then returns the chain.
	#
	#   p          the stop value, of any type
	#   returns    the chain itself, so calls chain
	#   note       the stop value is shared by every chain of the process
	#   see        StopValue, Becomes
	#-------------------
	def StopWhen(p)
		eval('$pStopValue = ' + ComputableForm(p))
		return This

	# Runs the code given as text, once or in a loop, when the chain is still ongoing; a stopped chain runs nothing.
	#
	#   pcCode     the Ring code to run, as text, usually between braces such as '{ v++ }'
	#   returns    the chain itself, so calls chain
	#   note       the braces are removed, the code is evaluated in the caller's scope, and the
	#              watched variable is re-read after each pass
	#   warning    the code runs once after OnlyWhen, Whatever or SometimesWhen, and repeats until
	#              the variable equals the stop value after Until; after it ran once the shared run
	#              flag is off and a later DoThis only stores its code
	#   see        Do_, Code, CodeStatus, Until
	def DoThis(pcCode)
		@cCode = _StzStripBraces(pcCode)

		@bCodeHasBeenCalled = 1
		@cCodeCaller = :Dothis

		if This.ChainStatus() = :Ongoing

			if $bExecuteCode = 1
	
				if $cOneOrManyLoops = :One
					eval(This.Code())
					@cCodeStatus = :HasBeenExecuted
					@cCodeExecutor = :DoThis
					$bExecuteCode = 0
					
				else
					
					While NOT BothAreEqual(This.Value(), $pStopValue )		      
						eval(This.Code())
						@cCodeStatus = :HasBeenExecuted
						@cCodeExecutor = :DoThis

						eval('This.Update(' + This.VarName() + ')')
					end
				ok

			else #  $bExecuteCode = 0

				 @aWhyCodeNotExecuted = [ 'Because "Since(:v)" requires "DoThis(:v)" not to execute until it knows where it should stop, using "StopWhen().Becomes()"!' ]

			ok

		ok

		return This

		# Runs the code given as text, once or in a loop, when the chain is still ongoing; a stopped chain runs nothing.
		#
		#   pcCode     the Ring code to run, as text, usually between braces
		#   returns    the chain itself, so calls chain
		#   note       the same call as DoThis
		#   see        DoThis, Code
		#< @FunctionAlternativeForms
		def Do_(pcCode)
			This.DoThis(pcCode)
	
	# Returns the chain after switching on the shared flag that allows code to run.
	#
	#   returns    the chain itself, so calls chain
	#   see        DoThis, This_
		#>
	def GetDo_()
		$bExecuteCode = 1
		return This

		# Returns the chain after switching on the shared flag that allows code to run.
		#
		#   returns    the chain itself, so calls chain
		#   note       the same call as GetDo_
		#   see        GetDo_, DoThis
		#< @FunctionAlternativeForm
		def GetCodeExecute()
			return GetDo_()

	# Runs the code through DoThis only when the shared run flag is on, and does nothing otherwise.
	#
	#   _cCode_    the Ring code to run, as text
	#   returns    nothing
	#   see        DoThis, GetDo_
		#>
	def This_(_cCode_)
		if $bExecuteCode
			DoThis(_cCode_)
		ok

	# Returns the name of the function that opened the chain, in lower case.
	#
	#   returns    a text such as whatever, onlywhen, until, since or sometimeswhen
	#   note       it is a process-wide value: the last initiator called, not a property of this
	#              chain
	#   see        OneOrManyLoops, RequiresStopValue
	#-----------------
	def ValueInitiator()
		return $cValueInitiator

	# Stops the chain and keeps the given reasons, so that nothing later runs.
	#
	#   paStopInfo   the list of reasons, usually one text such as [ "Because ..." ]
	#   returns      nothing
	#   note         a stopped chain stays stopped
	#   see          ChainStatus, WhyChainStopped
	def StopChain( paStopInfo )
		@bChainStopped = 1
		@aWhyChainStopped = paStopInfo

	# Returns whether the chain is still allowed to run code.
	#
	#   returns    the text ongoing or stopped
	#   see        StopChain, WhyChainStopped
	def ChainStatus()
		if @bChainStopped = 1
			return :Stopped
		else
			return :Ongoing
		ok

	# Returns the reasons a chain was stopped, or a text saying it was not.
	#
	#   returns    a list of texts when stopped; the text Chain is not stopped! otherwise
	#   note       WhyChainStopped is the same call
	#   see        ChainStatus, StopChain
	def WhyChainIsStopped()
		if This.ChainStatus() = :Stopped
			return @aWhyChainStopped
		else
			return "Chain is not stopped!"
		ok

		def WhyChainStopped()
			return This.WhyChainIsStopped()

	# Returns whether the next DoThis runs the code once or in a loop.
	#
	#   returns    the text one or many
	#   note       it is shared by every chain of the process
	#   see        ValueInitiator, DoThis
	def OneOrManyLoops()
		return $cOneOrManyLoops

	# Returns 1 when the initiator needs a stop value before its code can run, which only Since does.
	#
	#   returns    1 or 0
	#   note       it is shared by every chain of the process
	#   see        StopValue, Becomes
	def RequiresStopValue()
		return $bRequiresStopValue

	# Returns whether the code given to DoThis has run.
	#
	#   returns    the text notyetexecuted or hasbeenexecuted
	#   see        CodeHasBeenExecuted, WhyCodeNotYetExecuted
	def CodeStatus()
		return @cCodeStatus

	# Returns the reason the code has not run yet, or a text saying it has run.
	#
	#   returns    a list holding one text
	#   note       WhyCodeHasNotBeenExecuted is the same call
	#   warning    when DoThis was called on a stopped chain the reason is the placeholder
	#              Because... and not the reason the chain stopped; ask WhyChainStopped for that
	#   see        CodeStatus, CodeHasBeenCalled
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

		# Returns the reason the code has not run yet, or a text saying it has run.
		#
		#   returns    a list holding one text
		#   note       the same call as WhyCodeNotYetExecuted
		#   see        WhyCodeNotYetExecuted, CodeStatus
		def WhyCodeHasNotBeenExecuted()
			return WhyCodeNotYetExecuted()

	# TRUE if DoThis was called on this chain, whether or not the code then ran.
	#
	#   returns    1 or 0
	#   see        CodeHasBeenExecuted, DoThis
	def CodeHasBeenCalled()
		return @bCodeHasBeenCalled

	# TRUE if the code given to DoThis has run.
	#
	#   returns    1 or 0
	#   see        CodeStatus, CodeIsStillWaitingForExecution
	def CodeHasBeenExecuted()
		if This.CodeStatus() = :HasBeenExecuted
			return 1
		else
			return 0
		ok

	# TRUE if the code given to DoThis has not run, which includes the case where DoThis was never called.
	#
	#   returns    1 or 0
	#   see        CodeHasBeenExecuted, CodeStatus
	def CodeIsStillWaitingForExecution()
		if This.CodeHasBeenExecuted()
			return 0
		else
			return 1
		ok

	# Returns the held value wrapped in the library object of its type: a stzString for a text, a stzList for a list, a stzObject for an object.
	#
	#   returns    a stzString, a stzList or a stzObject
	#   warning    raises error Can't create the stzList object, paList must be a list, when the
	#              held value is a number, because the number is passed to stzList; use Value for
	#              numbers
	#   see        Value
	#-------------------
	def ToStzObject()
		switch Upper(ring_type(This.Value()))
		on "NUMBER"
			return new stzList(This.Value())
		on "STRING"
			return new stzString(This.Value())
		on "LIST"
			return new stzList(This.Value())
		on "OBJECT"
			return new stzObject(This.Value())
		off

	# Returns the chain itself whatever the value holds, so it does not answer today whether the value is a number.
	#
	#   returns    the chain itself
	#   warning    tested with a number, a text and a list: the answer is always the chain, never 1
	#              or 0
	#   see        IsNotANumber, IsAString
	#----------------------
	def IsANumber()

		if StzUpper(This._Type()) = "NUMBER"	
			return This
		else

			return This
		ok

		#< @FunctionFluentForm

		def IsANumberQ()

			if $bRandomPass = 0
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

		# Returns 0 whatever the value holds, because it negates the chain object that IsANumber returns.
		#
		#   returns    0
		#   warning    tested with a number, a text and a list: the answer is always 0, even for a
		#              text
		#   see        IsANumber, IsNotAString
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

	# TRUE if the held value is a text.
	#
	#   returns    1 or 0
	#   note       AString is the same call
	#   see        IsNotAString, IsANumber
			#>
		#>
	#----------------------
	def IsAString()
		if StzUpper(This._Type()) = "STRING"
			return 1
		else
			return 0
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

		# TRUE if the held value is not a text.
		#
		#   returns    1 or 0
		#   note       NotAString is the same call
		#   see        IsAString, IsNotANumber
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

	# Returns nothing today: the method has an empty body and does not test the value.
	#
	#   returns    nothing
	#   warning    tested with a number, a text and a list: the answer is always an empty text
	#   see        IsANumber, IsAString
			#>
		#>
	#----------------------
	def IsAList()

	# Returns nothing today: the method has an empty body and does not test the value.
	#
	#   returns    nothing
	#   warning    tested with a number and a text: the answer is always an empty text
	#   see        IsAList, IsAString
	#----------------------
	def IsAnObject()

