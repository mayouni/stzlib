
/*
	A chain of the truth is a Ring expression you can use any where in
	your code to simplify the TRUE/FALSE expressions.

	Hence, you become able to write a code like this:

	if _("ring").IsA(:String).Which(:IsLowercase).Containing(TheLetter("g")).Having('FirstChar() = "r"')._
	
		? "Got it!"
	else
		? "Sorry. May be next time..."
	ok

	This makes the code so natural and understandable.

	stzChainOfTruth is a component of the Natural-coding framework proposed by SoftanzaLib.
	Other components are: stzChainOfValue, stzChainOfCode, and stzNaturalCode.

*/

$oWorldEntities = new stzListOfEntities

func WorldEntities()
	return oWorldEntities

# Initiates the chain of value by accepting a value
# and returns a ChainOfTruth object that we can work on
func _(p)
	return new stzChainOfTruth(p)

func TheLetter(c)
	if isString(c) and StringIsChar(c) and StzCharQ(c).IsLetter()
		return c
	else
		return FALSE
	ok

func The(pcThing)
	/* Example:
		? The('Letter("G")')	--> "G"		_("G").IsA(:Letter)._
		? The('Letter("*")')	--> FALSE	_("*").IsA(:Letter)._
		? The('Number(5)')	--> 5		_(5).IsA(:Number)._
		? The('List([]')	--> []		_([]).IsA(:List)._
	*/



class stzChainOfTruth from stzObject
	# This attribute holds the value provided by the user between ()
	@pValue

	# These attributes hold the state of the chain
	@bSouldContinue = TRUE	# TODO: is it really useful?
	@bShouldReturnTRUE = FALSE
	@bShouldReturnFALSE = FALSE

	# This attribute helps in managing the functions
	# containing NOT in their semantics and that negates
	# the logic of the rest of the chain
	@bNegateNext = FALSE

	# This attribute manages the functions that support
	# nor/neighter semantics
	@cNeightherFunction = NULL

	# This attribute holds the softanza object corresponding
	# to the value managed by the chain (so the user can use
	# any of the supported methods in thoses objects)
	@oStzObject

	# @ and _ magic attributes: dont't remove them ;)!

	_	# Used to close the chain and return the TRUE or FALSE result

	_@	# Used to return the value in ComputableForm (ie as they should
		# appear in Ring code)

	@	# Used to return the stzObject related to the value
	Q	# Same as @ (to be consistent with the Q we use at the end of methods

	# Some (passive) semantic decorators: whenever they appear in the
	# chain, they just return the chain object
	AtTheSameTime
	AmongOthers

	  #----------------------------#
	 #   INITIALIZING THE CHAIN   #
	#----------------------------#

	def init(p)
		@pValue = p
		
		switch type(p)
		on "NUMBER"
			@oStzObject = new stzNumber(This.Value())

		on "STRING"
			@oStzObject = new stzString(This.Value())

		on "LIST"
			@oStzObject = new stzList(This.Value())

		on "OBJECT"
			@oStzObject = new stzObject(This.Value())
		off
	
	def Value()
		return @pValue

	def _Type()
		return type(@pValue)

	def StzObject()
		return @oStzObject

	  #-------------------------------#
	 #   CONTROLLING CHAIN PROCESS   #
	#-------------------------------#

	def ShouldBeNegated()
		return @bNegateNext

	def NeightherFunction()
		return @cNeightherFunction

	def ShouldContinue()
		if @bSouldContinue = TRUE
			return TRUE

		else
			return FALSE
		ok
	
	def ShouldReturnTRUE()
		if @bShouldReturnTRUE = TRUE 
			return TRUE

		else
			return FALSE
		ok

	def ShouldReturnFALSE()
		if @bShouldReturnFALSE = TRUE
			return TRUE

		else
			return FALSE
		ok

	def SetChainToReturn(p) # TRUE, FALSE, :CONTINUE
		switch p
		on :CONTINUE
			@bSouldContinue = TRUE
		   	@bShouldReturnTRUE = FALSE
		   	@bShouldReturnFALSE = FALSE

		on TRUE
			@bSouldContinue = FALSE
		   	@bShouldReturnTRUE = TRUE
		   	@bShouldReturnFALSE = FALSE
			
		on FALSE
			@bSouldContinue = FALSE
		   	@bShouldReturnTRUE = FALSE
		   	@bShouldReturnFALSE = TRUE

		off

	  #---------------------------------------------------------------#
	 #   CHECKING THE VALUE IDENTITY WITH Is(), IsA(), and IsThe()   #
	#---------------------------------------------------------------#

	def Is(pThing)


		/* Examples

		_(89).Is(:Number)._	# --> TRUE
		_("G").Is(:Letter)._ 	# --> TRUE

		_("H").Is('LetterOf("HUSSEIN")')._	# --> TRUE

		o1 = new Person
		_(:o1).Is(:Object)	# --> TRUE
		class Person
		*/

		if This.ShouldReturnFalse()
			This.SetChainToReturn(FALSE)
			return This
		ok

		@bNegateNext = FALSE

		bResult = FALSE

		# Case of equality
		if BothAreEqual(pThing, This.Value())

			bResult = TRUE

		but BothAreStrings( pThing, This.Value() ) and
		    StzStringQ(pThing).Lowercased() = StzStringQ(This.Value()).Lowercased()
			bResult = TRUE

		# Case of a string
		but isString(pThing)

			# Case of the 4 native ring types
			if pThing = :Number and This._Type() = "NUMBER"
				bResult = TRUE
	
			but pThing = :String and This._Type() = "STRING"
				bResult = TRUE
	
			but pThing = :List and This._Type() = "LIST"
				bResult = TRUE
	
			but pThing = :Object and This._Type() = "OBJECT"
				bResult = TRUE

			# Case of a stz object method
			but StzStringQ("is" + pThing).ExistsIn( methods(This.StzObject()) )
				# Example: _("A").Is( :Uppercase )
	
				cCode = 'bResult = StzObject().Is' + pThing + '()'
				eval(cCode)
	
			# Case of a function call
			but StzStringQ(pThing).IsAlmostAFunctionCall()
				# Example: _("H").Is('LetterOf("HUSSEIN")')._

				cCode = 'bResult = _(' + ComputableForm(This.Value()) + ').@.Is' + pThing
				eval(cCode)

			else
				# Case of an eventual function call
				cCode = pThing
				try
					eval(cCode)
				catch
					bResult = FALSE
				done
			ok

		# Case of a list of strings
		but  ListIsListOfStrings(pThing)
			# Example:
			# ? _(["A","B","C"]).Is([ :AListOfStrings, :AListOfChars, :AListOfLetters ]).AtTheSameTime._

			bIsListOfMethods = TRUE
			for str in pThing
				if NOT StzStringQ("is" + str).ExistsIn( methods(This.StzObject()) )
					bIsListOfMethods = FALSE
					exit
				ok
			next

			if bIsListOfMethods
				bResult = TRUE
				for str in pThing

					if NOT _(This.Value()).Is(str)._
						bResult = FALSE
						exit
					ok
				next
			ok

		ok

		# Tagging the chain object with the result (TRUE or FALSE)
		# and returning the object itself (not TRUE or FALSE)
		if bResult
			This.SetChainToReturn(TRUE)
		else
			This.SetChainToReturn(FALSE)
		ok

		return This

		#< @FunctionNegationForm

		def IsNot(pThing)
			bResult = This.Is(pThing)
			return NOT bResult

		#>

		def AndA(pThing)
			return This.Is(pThing)

	def AndThe(pThing)
		return This.IsThe(pThing)

	def IsA(pThing)

		# Captures expressions like this: _("H").IsA('LetterOf("HUSSEIN")')._
		# Returns FALSE for any other expression.

		# Managing the special semantic meaning of IsA()
		if isString(pThing) and
		   StzStringQ(pThing).IsAlmostAFunctionCall() and
		   FunctionNameFinishesWithOneOfThese( pThing, [ "in", "of" ] ) and
		   FunctionParamTypeIsOneOfThese( pThing, [ "STRING", "LIST" ] )

			/*
			IsA() has a special semantic meaning that we should
			manage with care. Let's explain it by example:

			_("H").IsA('LetterOf("HUSSEIN")')._

			--> Should return TRUE, because H is one of the
			letters of the string HUSSEIN: There is at least
			one other letter in addition to H, so IsA('Letter')
			becomes semantically relevant.)

			However, when we say:
			_("H").IsA('LetterOf("---H---")')._

			--> This returns FALSE, Because H is the only, and only
			letter, in the string HUSSEIN: IsA() is then
			semantically NOT relevant!
			*/

			if This.ShouldReturnFalse()
				This.SetChainToReturn(FALSE)
				return This
			ok
	
			@bNegateNext = FALSE

			# Avoiding that the method name be the same as isNumber(),
			# isString(), isList() or isObject() which are preserved
			# by Ring (instead we have IsAString(), IsANumber(),
			# IsAList(), and IsAnObject methods)

			cFuncName = FunctionName(pThing)

			oTempType = StzStringQ(cFuncName).SectionQ(1, -3).UppercaseQ()
			if oTempType.IsOneOfThese([ "NUMBER", "STRING", "LIST" ])
				cFuncName = "A" + cFuncName

			but oTempType.Content() = "OBJECT"
				cFuncName = "An" + cFuncName
			
			ok

			cFunCode = cFuncName + '(' + FunctionParam(pThing) + ')'
			cCode = 'bResult = _(' + ComputableForm(This.Value()) + ').@.Is' + cFunCode
	
			# --> Example of generated code:
			# bResult = _("H").@.IsLetterOf("HUSSEIN")

			# Which invoques the IsLetterOf() method from stzString

			# Now, we evaluate that code and get TRUE or FALSE
			# as produced, normally, by the @ softanza object
			
			eval(cCode)

			# Let's leverage the result we got to apply the sepeciefic
			# semantics of IsA() as explained above

			cValue = FunctionParam(pThing)
			cMethod = StzStringQ(cFuncName).Section(1, -3)
			cIsMethod = "is" + cMethod
			cIsMethodCall = cIsMethod + "()"
			cCode = "bPass = _(" + ComputableForm(cValue) + ").@.NumberOfItemsW('{ _(@item).@." + cIsMethodCall + " }') > 1"

				eval(cCode)
	

			if bResult = TRUE and bPass
				This.SetChainToReturn(TRUE)
			else
				This.SetChainToReturn(FALSE)
			ok
	
			return This			

		# In all other cases, the IsA() behaves exactly like Is()
		else
			return This.Is(pThing)

		ok

		#---

		def IsNotA(pcThing)
			bResult = This.IsA(pThing)
			return NOT bResult
	
		def IsAn(pThing)
			return This.IsA(pThing)
	
		def IsNotAn(pThing)
			bResult = This.IsAn(pThing)
			return NOT bResult

	def IsThe(pThing)
		return This.Is(pThing)

	def IsNotThe(pThing)
		bResult = This.IsThe(pThing)
		return NOT bResult

	def IsTheOnly(pThing)
		return This.IsThe(pThing)

	def IsNeighther(pcThing)
		@cNeightherFunction = :IsNot
		return This

	def IsNor(pcThing)
		@cNeightherFunction = :IsNot
		return This

	def Which(pcMethod)

		/* Example:
			? _(1234).IsANumber().Which(:IsEven)
			
			--> returns TRUE
		*/

		if This.ShouldBeNegated()
			if This.ShouldReturnFalse()
				This.SetchainToReturn(TRUE)
			but This.ShouldReturnTrue()
				This.SetChainToReturn(FALSE)
			ok
		ok

		if This.ShouldReturnFalse()
			This.SetChainToReturn(FALSE)
			return This
		ok

		pcMethod = StzStringQ(pcMethod).Simplified()

		cCode = 'bResult = This.StzObject().' + pcMethod

		if NOT StzStringQ(pcMethod).IsAlmostAFunctionCall()
			cCode += "()"
		ok

		try
			eval(cCode)
		catch
			stzRaise("Syntax Error. check the code you provided as a param of Which()...")
		done

		if This.ShouldBeNegated()

			bResult = NOT bResult
		ok

		if bResult = TRUE
			This.SetChainToReturn(TRUE)
		else
			This.SetChainToReturn(FALSE)
		ok

		return This

		#< @FunctionAlternativeForm

		def _Which()
			return This.Which()

		def _But()
			return This.Which()

		#>

	  #---------------------------------------#
	 #   CHECKING A CONDITION ON THE VALUE   #
	#---------------------------------------#

	def Where(pcCondition)
		/* Example

			? _("Ring").IsAString().Where('{ NumberOfItems() = 4 }')
			
			--> Returns TRUE
		*/

		if This.ShouldBeNegated()
			if This.ShouldReturnFalse()
				This.SetchainToReturn(TRUE)
			but This.ShouldReturnTrue()
				This.SetChainToReturn(FALSE)
			ok
		ok

		if This.ShouldReturnFalse()
			This.SetChainToReturn(FALSE)
			return This
		ok

		cCondition = StzStringQ(pcCondition).Simplified()

		cCode = "if This.StzObject()." + cCondition + NL +
			"	" + "bResult = TRUE" + NL +
			"else" + NL +
			"	bResult = FALSE" + NL +
			"ok"

		try
			eval(cCode)
		catch
			stzRaise("Syntax error! Check the condition you provided in the parma.")
		done

		if This.ShouldBeNegated()
			bResult = NOT bResult
		ok

		if bResult = TRUE
			This.SetChainToReturn(TRUE)
		else
			This.SetChainToReturn(FALSE)
		ok

		return This
		
		#< @FunctionAlternativeForm

		def Having(pcCondition)
			return This.Where(pcCondition)

		def That(pcCondition)
			return This.Where(pcCondition)

		def _That(pcCondition)
			return This.Where(pcCondition)
		#>

	  #--------------------------#
	 #   CHECKING CONTAINMENT   #
	#--------------------------#

	def Containing(p)
		/* Example

		? _("Ring").IsAString().Containing("in")

		--> Returns TRUE
		*/

		if This.ShouldBeNegated()
			if This.ShouldReturnFalse()
				This.SetchainToReturn(TRUE)
			but This.ShouldReturnTrue()
				This.SetChainToReturn(FALSE)
			ok
		ok

		if This.ShouldReturnFalse()
			This.SetChainToReturn(FALSE)
			return This
		ok

		if isNumber(This.Value())
			This.SetChainToReturn(FALSE)
			return This
		ok

		if isString(p)
			p = '"' + p + '"'
		ok

		bResult = This.Where('{ Contains(' + p + ') }')

		if This.ShouldBeNegated()
			bResult = NOt bResult
		ok

		return bResult

		#< @FunctionAlternativeForms

		def Contains(p)
			return This.Containing(p)

		def IsContaining(p)
			return This.Containing(p)

		#>

	def ContainingNo(p)
		/* Example

		? _("Ring").IsAString().ContainingNo("xyz")

		--> Returns TRUE
		*/

		if This.ShouldBeNegated()
			if This.ShouldReturnFalse()
				This.SetchainToReturn(TRUE)
			but This.ShouldReturnTrue()
				This.SetChainToReturn(FALSE)
			ok
		ok

		if This.ShouldReturnFalse()
			This.SetChainToReturn(FALSE)
			return This
		ok

		@cNeightherFunction = :ContainingNo

		if isNumber(This.Value())
			This.SetChainToReturn(FALSE)
			return This
		ok

		if isString(p)
			p = '"' + p + '"'
		ok

		bResult = This.Where('{ ContainsNo(' + p + ') }')

		if This.ShouldBeNegated()
			bResult = NOt bResult
		ok

		return bResult

		#< @FunctionAlternativeForms

		def ContainsNo(p)
			return This.ContainingNo(p)

		def ContainsNeighther(p)
			return This.ContainingNo(p)

		def IsContainingNo(p)
			return This.ContainingNo(p)

		def DoesNotContain(p)
			return This.ContainingNo(p)

		def ContainingNeighther(p)
			return This.ContainingNo(p)

		#>

	def Nor(p)
		cCode = 'bResult = This.' + This.NeightherFunction() + '(p)'
		eval(cCode)

		return bResult

	#------------------

	def st(pcThing)
		if This._Type() = "NUMBER" and
		   StzStringQ(''+ This.Value()).LastChar() = "1"

			return This.Nth(pcThing)
		ok

	def nd(pcThing)
		if This._Type() = "NUMBER" and
		   StzStringQ(''+ This.Value()).LastChar() = "2"

			return This.nth(pcThing)
		ok

	def rd(pcThing)
		if This._Type() = "NUMBER" and
		   StzStringQ(''+ This.Value()).LastChar() = "3"

			return This.nth(pcThing)
		ok

	def th(pcThing)
		/* Example:
	
		_(7).nth('LetterOf("HUSSEIN")').@ 	# --> "N"
	
		*/
		if This._Type() = "NUMBER" and
		   (0+ StzStringQ(''+ This.Value()).LastChar()) > 1

			return This.nth(pcThing)

		ok

	def Nth(pcThing)

		This.SetChainToReturn(:Value)

		if This._Type() = "NUMBER"

			pcThing = StzStringQ(pcThing).Simplified()

			cCode = 'result = Nth' + pcThing
	
			oStzString = new stzString(cCode)
			n = oStzString.FindFirst("(")
	
			cCode = StzStringQ(cCode).InsertAfterQ( n, ""+ This.Value() + ", ").Content()

			eval(cCode)

			return _( result )
		ok

	#------------------

	def get@()
		return This.StzObject()

		def getQ()
			return This.StzObject()

	def get_()
		if This.ShouldReturnTRUE()
			return TRUE
			
		but This.ShouldReturnFALSE()
			return FALSE

		else
			return This.Value()

		ok

	def get_@
		return ComputableForm( This.Value() )

	def getAmongOthers
		return This

	#--------------------

	def getAtTheSameTime()
		return This

	def _@(paEntity)
		if NOT isString(This.Value())
			This.SetChainToReturnFALSE()
			return This
		ok

		if ListisHashList(paEntity)
			if NOT StzHashListQ(paEntity).ContainsKey(:name)
				insert(paEntity, 0, :name = This.Value())
			ok

			oEntity = new stzEntity(paEntity)
			$oWorldEntities.AddEntity(oEntity.Content()) 
			return oEntity
		else
			This.SetChainToReturnFALSE()
			return This
		ok

	  #----------------------------------#
	 #   PRIVATE KITCHEN OF THE CLASS   #
	#----------------------------------#

	PRIVATE

	def pvtFunctionParam( pcFunctionCall )
		oStzStr = new stzString(pcFunctionCall)

		n1 = oStzStr.FindFirstOccurrence("(") + 1
		n2 = oStzStr.FindFirstOccurrence(")") - 1

		return StzStringQ(pcFunctionCall).SectionQ(n1, n2).Content()


	def pvtFunctionName( pcFunctionCall )
		oStzStr = new stzString(pcFunctionCall)

		n = oStzStr.FindFirstOccurrence("(") - 1

		return StzStringQ(pcFunctionCall).SectionQ(1, n).Content()

	def pvtFunctionNameFinishesWithOneOfThese( pcFunctionCall, paSubStr )
		/*
		pvtFunctionNameContainsOneOfThese( pThing, [ "in", "of" ], :AtTheEnd )
		*/

		cLast2Chars = StzStringQ(pvtFunctionName(pcFunctionCall)).NLastCharsQ(2).Lowercased()

		if cLast2Chars = "in" or cLast2Chars = "of"
			return TRUE
		else
			return FALSE
		ok

	def pvtFunctionParamType( pcFunctionCall )
		cParam = pvtFunctionParam(pcFunctionCall)

		if StzStringQ( cParam ).IsBoundedBy('"','"')
			cType = "STRING"
	
		but StzStringQ( cParam ).IsBoundedBy("[","]")
			cType = "LIST"
	
		but StzStringQ( cParam).IsNumberInString()
			cType = "NUMBER"
	
		else
			cType = "OBJECT"
		ok

		return cType

	def pvtFunctionParamTypeIsOneOfThese( pcFunctionCall, paSubStr )
		cType = pvtFunctionParamType(pcFunctionCall)
		return StzStringQ(cType).IsOneOfThese(paSubStr)
