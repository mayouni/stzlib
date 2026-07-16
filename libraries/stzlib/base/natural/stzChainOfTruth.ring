
/*
	LEGACY SURFACE -- FROZEN (NATURAL_VISION step 4 decision, 2026-07-10).

	The chain-of-truth IDEA lives on as INTERROGATIVE NARRATIONS in the
	stzNatural engine: a narration that asks several questions records
	every answer --

		Naturally("Create a string with 'ring' " +
		          "Is it lowercase ? Does it contain 'g' ?").AllYes()
		#--> 1  (see also Answers() / AnyYes())

	which is this class's semantics rebuilt on the ONE semantic lexicon
	(no per-step eval of user strings). This file stays for backward
	compatibility of the _()... surface and its test corpus; do not grow
	it -- add new predicate vocabulary to the lexicon instead.

	--- original narrative ---

	A chain of the truth is a Ring expression you can use any where in
	your code to simplify the 1/FALSE expressions.

	Hence, you become able to write a code like this:

	if _("ring").IsA(:String).Which(:IsLowercase).Containing(TheLetter("g")).AndHaving('FirstChar() = "r"')._
	
		? "Got it!"
	else
		? "Sorry. May be next time..."
	ok

	This makes the code so natural and understandable.

	stzChainOfTruth is a component of the Natural-coding framework proposed by SoftanzaLib.
	Other components are: stzChainOfValue, stzChainOfCode, and stzNaturalCode.

*/

# $oWorldEntities and WorldEntities() moved to stzListOfEntities.ring
# (NATURAL_VISION step 3): the world is shared, not owned by this surface.

# Initiates the chain of value by accepting a value
# and returns a ChainOfTruth object that we can work on
func _(p)
	return new stzChainOfTruth(p)

# Useful functions for natural-coding #TODO add others

func TheLetter(c)
	if isString(c) and @IsChar(c) and StzCharQ(c).IsLetter()
		return c
	else
		return 0
	ok

	func TheLetterQ(c)
		return new stzChar(TheLetter(c))

func TheLetters(acChars)

	_acChars_ = acChars

	if isList(_acChars_)
		_nLen_ = len(_acChars_)
		_last_ = _acChars_[_nLen_]

		if isList(_last_) and len(_last_) = 2 and
		   isString(_last_[1]) and _last_[1] = :And

			del(_acChars_, _nLen_)
			_acChars_ + _last_[2]
		ok

		if @IsListOfLetters(acChars)
			return _acChars_
		ok

	else
		return 0
	ok

	func TheLettersQ(acChars)
		return new stzList(TheLetters(acChars))

class stzChainOfTruth from stzObject
	# This attribute holds the value provided by the user between ()
	@pValue

	# These attributes hold the state of the chain
	@bSouldContinue = 1	#TODO // is it really useful?
	@bShouldReturnTRUE = 0
	@bShouldReturnFALSE = 0

	# This attribute helps in managing the functions
	# containing NOT in their semantics and that negates
	# the logic of the rest of the chain
	@bNegateNext = 0

	# This attribute manages the functions that support
	# nor/neighter semantics
	@cNeightherFunction = ""

	# This attribute holds the softanza object corresponding
	# to the value managed by the chain (so the user can use
	# any of the supported methods in thoses objects)
	@oStzObject

	# @ and _ magic attributes: dont't remove them ;)!

	_	# Used to close the chain and return the 1 or 0 result

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
		
		switch ring_type(p)
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
		return ring_type(@pValue)

	# The stz object this chain reasons about -- an OBJECT, hence Q.
	def StzObjectQ()
		return @oStzObject

	  #-------------------------------#
	 #   CONTROLLING CHAIN PROCESS   #
	#-------------------------------#

	def ShouldBeNegated()
		return @bNegateNext

	def NeightherFunction()
		return @cNeightherFunction

	def ShouldContinue()
		if @bSouldContinue = 1
			return 1

		else
			return 0
		ok
	
	def ShouldReturnTRUE()
		if @bShouldReturnTRUE = 1 
			return 1

		else
			return 0
		ok

	def ShouldReturnFALSE()
		if @bShouldReturnFALSE = 1
			return 1

		else
			return 0
		ok

	def SetChainToReturn(p) # 1, 0, :CONTINUE
		switch p
		on :CONTINUE
			@bSouldContinue = 1
		   	@bShouldReturnTRUE = 0
		   	@bShouldReturnFALSE = 0

		on 1
			@bSouldContinue = 0
		   	@bShouldReturnTRUE = 1
		   	@bShouldReturnFALSE = 0
			
		on 0
			@bSouldContinue = 0
		   	@bShouldReturnTRUE = 0
		   	@bShouldReturnFALSE = 1

		off

	  #---------------------------------------------------------------#
	 #   CHECKING THE VALUE IDENTITY WITH Is(), IsA(), and IsThe()   #
	#---------------------------------------------------------------#

	def Is(pThing)


		/* Examples

		_(89).Is(:Number)._	#--> TRUE
		_("G").Is(:Letter)._ 	#--> TRUE

		_("H").Is('LetterOf("HUSSEIN")')._	#--> TRUE

		_o1_ = new Person
		_(:o1).Is(:Object)	#--> TRUE
		class Person
		*/

		if This.ShouldReturnFalse()
			This.SetChainToReturn(0)
			return This
		ok

		@bNegateNext = 0

		bResult = 0

		# Case of equality
		if BothAreEqual(pThing, This.Value())

			bResult = 1

		but BothAreStrings( pThing, This.Value() ) and
		    StzLower(pThing) = StzLower(This.Value())
			bResult = 1

		# Case of a string
		but isString(pThing)

			# Case of the 4 native ring types
			if pThing = :Number and This._Type() = "NUMBER"
				bResult = 1
	
			but pThing = :String and This._Type() = "STRING"
				bResult = 1
	
			but pThing = :List and This._Type() = "LIST"
				bResult = 1
	
			but pThing = :Object and This._Type() = "OBJECT"
				bResult = 1

			# Case of a stz object method
			but StzFindFirst( methods(This.StzObjectQ()), "is" + pThing ) > 0
				# Example: _("A").Is( :Uppercase )
	
				cCode = 'bResult = StzObject().Is' + pThing + '()'
				eval(cCode)
	
			# Case of a function call
			but (StzFindFirst(pThing, "(") > 1 and StzFindFirst(pThing, ")") > 0 and StringNumberOfOccurrence(pThing, "(") = 1 and StringNumberOfOccurrence(pThing, ")") = 1 and StzFindFirst(pThing, "(") < StzFindFirst(pThing, ")") and StzRight(pThing, 1) = ")")
				# Example: _("H").Is('LetterOf("HUSSEIN")')._

				cCode = 'bResult = _(' + ComputableForm(This.Value()) + ').Q.Is' + pThing
				eval(cCode)

			else
				# Case of an eventual function call
				cCode = pThing
				try
					eval(cCode)
				catch
					bResult = 0
				done
			ok

		# Case of a list of strings
		but  @IsListOfStrings(pThing)
			# Example:
			# ? _(["A","B","C"]).Is([ :AListOfStrings, :AListOfChars, :AListOfLetters ]).AtTheSameTime._

			bIsListOfMethods = 1
			nThing2Len = len(pThing)
			for iLoopThing2 = 1 to nThing2Len
				str = pThing[iLoopThing2]
				if NOT ( StzFindFirst( methods(This.StzObjectQ()), "is" + str ) > 0 )
					bIsListOfMethods = 0
					exit
				ok
			next

			if bIsListOfMethods
				bResult = 1
				nThing1Len = len(pThing)
				for iLoopThing1 = 1 to nThing1Len
					str = pThing[iLoopThing1]
					if NOT _(This.Value()).Is(str)._
						bResult = 0
						exit
					ok
				next
			ok

		ok

		# Tagging the chain object with the result (1 or 0)
		# and returning the object itself (not 1 or 0)
		if bResult
			This.SetChainToReturn(1)
		else
			This.SetChainToReturn(0)
		ok

		return This

		#< @FunctionNegativeForm

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
		# Returns 0 for any other expression.

		# Managing the special semantic meaning of IsA()
		if isString(pThing) and
		   (StzFindFirst(pThing, "(") > 1 and StzFindFirst(pThing, ")") > 0 and StringNumberOfOccurrence(pThing, "(") = 1 and StringNumberOfOccurrence(pThing, ")") = 1 and StzFindFirst(pThing, "(") < StzFindFirst(pThing, ")") and StzRight(pThing, 1) = ")") and
		   FunctionNameFinishesWithOneOfThese( pThing, [ "in", "of" ] ) and
		   FunctionParamTypeIsOneOfThese( pThing, [ "STRING", "LIST" ] )

			/*
			IsA() has a special semantic meaning that we should
			manage with care. Let's explain it by example:

			_("H").IsA('LetterOf("HUSSEIN")')._

			--> Should return 1, because H is one of the
			letters of the string HUSSEIN: There is at least
			one other letter in addition to H, so IsA('Letter')
			becomes semantically relevant.)

			However, when we say:
			_("H").IsA('LetterOf("---H---")')._

			--> This returns 0, Because H is the only, and only
			letter, in the string HUSSEIN: IsA() is then
			semantically NOT relevant!
			*/

			if This.ShouldReturnFalse()
				This.SetChainToReturn(0)
				return This
			ok
	
			@bNegateNext = 0

			# Avoiding that the method name be the same as isNumber(),
			# isString(), isList() or isObject() which are preserved
			# by Ring (instead we have IsAString(), IsANumber(),
			# IsAList(), and IsAnObject methods)

			_cFuncName_ = FunctionName(pThing)

			_cTempType_ = StzUpper(StzLeft(_cFuncName_, StzLen(_cFuncName_) - 2))
			if _cTempType_ = "NUMBER" or _cTempType_ = "STRING" or _cTempType_ = "LIST"
				_cFuncName_ = "A" + _cFuncName_

			but _cTempType_ = "OBJECT"
				_cFuncName_ = "An" + _cFuncName_
			
			ok

			_cFunCode_ = _cFuncName_ + '(' + FunctionParam(pThing) + ')'
			cCode = 'bResult = _(' + ComputableForm(This.Value()) + ').Q.Is' + _cFunCode_
	
			#--> Example of generated code:
			# bResult = _("H").Q.IsLetterOf("HUSSEIN")

			# Which invoques the IsLetterOf() method from stzString

			# Now, we evaluate that code and get 1 or 0
			# as produced, normally, by the @ softanza object
			
			eval(cCode)

			# Let's leverage the result we got to apply the sepeciefic
			# semantics of IsA() as explained above

			_cValue_ = FunctionParam(pThing)
			_cMethod_ = StzLeft(_cFuncName_, StzLen(_cFuncName_) - 2)
			_cIsMethod_ = "is" + _cMethod_
			_cIsMethodCall_ = _cIsMethod_ + "()"
			cCode = "bPass = _(" + ComputableForm(_cValue_) + ").Q.NumberOfItemsW('{ _(@item).Q." + _cIsMethodCall_ + " }') > 1"

				eval(cCode)
	

			if bResult = 1 and bPass
				This.SetChainToReturn(1)
			else
				This.SetChainToReturn(0)
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
			
			--> returns 1
		*/

		if This.ShouldBeNegated()
			if This.ShouldReturnFalse()
				This.SetchainToReturn(1)
			but This.ShouldReturnTrue()
				This.SetChainToReturn(0)
			ok
		ok

		if This.ShouldReturnFalse()
			This.SetChainToReturn(0)
			return This
		ok

		pcMethod = StringSimplified(pcMethod)

		cCode = 'bResult = This.StzObjectQ().' + pcMethod

		if NOT (StzFindFirst(pcMethod, "(") > 1 and StzFindFirst(pcMethod, ")") > 0 and StringNumberOfOccurrence(pcMethod, "(") = 1 and StringNumberOfOccurrence(pcMethod, ")") = 1 and StzFindFirst(pcMethod, "(") < StzFindFirst(pcMethod, ")") and StzRight(pcMethod, 1) = ")")
			cCode += "()"
		ok

		try
			eval(cCode)
		catch
			StzRaise("Syntax Error. check the code you provided as a param of Which()...")
		done

		if This.ShouldBeNegated()

			bResult = NOT bResult
		ok

		if bResult = 1
			This.SetChainToReturn(1)
		else
			This.SetChainToReturn(0)
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
			
			--> Returns 1
		*/

		if This.ShouldBeNegated()
			if This.ShouldReturnFalse()
				This.SetchainToReturn(1)
			but This.ShouldReturnTrue()
				This.SetChainToReturn(0)
			ok
		ok

		if This.ShouldReturnFalse()
			This.SetChainToReturn(0)
			return This
		ok

		_cCondition_ = StringSimplified(pcCondition)

		cCode = "if This.StzObjectQ()." + _cCondition_ + NL +
			"	" + "bResult = 1" + NL +
			"else" + NL +
			"	bResult = 0" + NL +
			"ok"

		try
			eval(cCode)
		catch
			StzRaise("Syntax error! Check the condition you provided in the parma.")
		done

		if This.ShouldBeNegated()
			bResult = NOT bResult
		ok

		if bResult = 1
			This.SetChainToReturn(1)
		else
			This.SetChainToReturn(0)
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

		--> Returns 1
		*/

		if This.ShouldBeNegated()
			if This.ShouldReturnFalse()
				This.SetchainToReturn(1)
			but This.ShouldReturnTrue()
				This.SetChainToReturn(0)
			ok
		ok

		if This.ShouldReturnFalse()
			This.SetChainToReturn(0)
			return This
		ok

		if isNumber(This.Value())
			This.SetChainToReturn(0)
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

		--> Returns 1
		*/

		if This.ShouldBeNegated()
			if This.ShouldReturnFalse()
				This.SetchainToReturn(1)
			but This.ShouldReturnTrue()
				This.SetChainToReturn(0)
			ok
		ok

		if This.ShouldReturnFalse()
			This.SetChainToReturn(0)
			return This
		ok

		@cNeightherFunction = :ContainingNo

		if isNumber(This.Value())
			This.SetChainToReturn(0)
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
		   StzRight(''+ This.Value(), 1) = "1"

			return This.Nth(pcThing)
		ok

	def nd(pcThing)
		if This._Type() = "NUMBER" and
		   StzRight(''+ This.Value(), 1) = "2"

			return This.nth(pcThing)
		ok

	def rd(pcThing)
		if This._Type() = "NUMBER" and
		   StzRight(''+ This.Value(), 1) = "3"

			return This.nth(pcThing)
		ok

	def th(pcThing)
		/* Example:

		_(7).nth('LetterOf("HUSSEIN")').Q 	#--> "N"

		*/
		if This._Type() = "NUMBER" and
		   (0+ StzRight(''+ This.Value(), 1)) > 1

			return This.nth(pcThing)

		ok

	def Nth(pcThing)

		This.SetChainToReturn(:Value)

		if This._Type() = "NUMBER"

			pcThing = StringSimplified(pcThing)

			cCode = 'result = Nth' + pcThing
	
			_oStzString_ = new stzString(cCode)
			_n_ = _oStzString_.FindFirst("(")
	
			cCode = StzLeft(cCode, _n_) + "" + This.Value() + ", " + StzMid(cCode, _n_ + 1, StzLen(cCode) - _n_)

			eval(cCode)

			return _( result )
		ok

	#------------------

	def get@()
		return This.StzObjectQ()

		def getQ()
			return This.StzObjectQ()

	def get_()
		if This.ShouldReturnTRUE()
			return 1
			
		but This.ShouldReturnFALSE()
			return 0

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

		if @IsHashList(paEntity)
			if NOT StzHashListQ(paEntity).ContainsKey(:name)
				insert(paEntity, 0, :name = This.Value())
			ok

			_oEntity_ = new stzEntity(paEntity)
			$oWorldEntities.AddEntity(_oEntity_.Content()) 
			return _oEntity_
		else
			This.SetChainToReturnFALSE()
			return This
		ok

	  #----------------------------------#
	 #   PRIVATE KITCHEN OF THE CLASS   #
	#----------------------------------#

	PRIVATE

	def pvtFunctionParam( pcFunctionCall )
		_oStzStr_ = new stzString(pcFunctionCall)

		_n1_ = _oStzStr_.FindFirstOccurrence("(") + 1
		_n2_ = _oStzStr_.FindFirstOccurrence(")") - 1

		return StzMid(pcFunctionCall, _n1_, _n2_ - _n1_ + 1)


	def pvtFunctionName( pcFunctionCall )
		_oStzStr_ = new stzString(pcFunctionCall)

		_n_ = _oStzStr_.FindFirstOccurrence("(") - 1

		return StzLeft(pcFunctionCall, _n_)

	def pvtFunctionNameFinishesWithOneOfThese( pcFunctionCall, paSubStr )
		/*
		pvtFunctionNameContainsOneOfThese( pThing, [ "in", "of" ], :AtTheEnd )
		*/

		_cFuncName_ = pvtFunctionName(pcFunctionCall)
		_cLast2Chars_ = StzLower(StzRight(_cFuncName_, 2))

		if _cLast2Chars_ = "in" or _cLast2Chars_ = "of"
			return 1
		else
			return 0
		ok

	def pvtFunctionParamType( pcFunctionCall )
		_cParam_ = pvtFunctionParam(pcFunctionCall)

		if StzLen(_cParam_) >= 2 and StzLeft(_cParam_, 1) = '"' and StzRight(_cParam_, 1) = '"'
			_cType_ = "STRING"

		but StzLen(_cParam_) >= 2 and StzLeft(_cParam_, 1) = "[" and StzRight(_cParam_, 1) = "]"
			_cType_ = "LIST"

		but isNumber(0+ _cParam_) and _cParam_ != ""
			_cType_ = "NUMBER"
	
		else
			_cType_ = "OBJECT"
		ok

		return _cType_

	def pvtFunctionParamTypeIsOneOfThese( pcFunctionCall, paSubStr )
		_cType_ = pvtFunctionParamType(pcFunctionCall)
		return StzFindFirst(paSubStr, _cType_) > 0
