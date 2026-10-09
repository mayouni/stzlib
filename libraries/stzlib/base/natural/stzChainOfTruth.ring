
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

# Wraps one value in a chain of near-natural questions, such as _("ring").Is(:String)._, whose closing underscore answers 1 or 0.
#
# Each step (Is, Which, Where) puts one question to the value and tags the chain true or false, and
# returns the chain, so steps read as a sentence; the closing _ attribute returns 1 or 0. A chain
# that was tagged false stays false: later steps do not run, so build a new chain for a new
# question. The surface is frozen legacy: the same idea lives on as interrogative narrations in
# stzNatural, and part of this class does not work today: the negative forms (IsNot, IsNotAn,
# IsNotThe, IsNotA), Containing, ContainingNo, the function-call forms of Is and IsA, and the
# ordinal forms (st, nd, rd, th, Nth).
#
#   receiver   o1 = _("Ring")
#   example    ? o1.Is(:String)._
#              #--> 1
#              ? _("Ring").Is(:Lowercase)._
#              #--> 0
#              ? _(1234).Is(:Number).Which(:IsEven)._
#              #--> 1
#              ? _("Ring").Where('NumberOfChars() = 4')._
#              #--> 1
#              ? _("Ring").Is(:Number).Where('NumberOfChars() = 4')._
#              #--> 0
#   see        stzChainOfValue, stzObject
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

	# Builds a chain around one value of any type and wraps it in the library object of its type, so the chain can ask that object questions.
	#
	#   p          the value the chain reasons about: a number, a text, a list or an object
	#   returns    nothing; the object is built
	#   note       the chain is a frozen legacy surface; new vocabulary belongs to the interrogative
	#              narrations of stzNatural
	#   warning    the chain is usually built by the function _( ), as in _("ring").Is(:String)._
	#   see        Value, StzObjectQ
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
	
	# Returns the value the chain was built with, unchanged.
	#
	#   returns    the held value, of any type
	#   see        StzObjectQ, get_
	def Value()
		return @pValue

	def _Type()
		return ring_type(@pValue)

	# Returns the library object that wraps the held value: a stzNumber, stzString, stzList or stzObject.
	#
	#   returns    an object
	#   note       the questions of Which and Where are put to this object
	#   see        Value, Where
	#@ aka  The stz object this chain reasons about -- an OBJECT, hence Q.
	def StzObjectQ()
		return @oStzObject

	  #-------------------------------#
	 #   CONTROLLING CHAIN PROCESS   #
	#-------------------------------#

	# Returns whether the next step of the chain is read as its opposite.
	#
	#   returns    1 or 0
	#   note       it is 0 in every chain tested, since no step sets it
	#   see        NeightherFunction, IsNeighther
	def ShouldBeNegated()
		return @bNegateNext

	# Returns the name of the method Nor will call, as set by IsNeighther, IsNor or ContainingNo.
	#
	#   returns    a text such as isnot; empty text until one of them is used
	#   see        Nor, IsNeighther
	def NeightherFunction()
		return @cNeightherFunction

	# Returns whether the chain has not yet reached a verdict.
	#
	#   returns    1 while no step has decided, 0 once the chain is tagged true or false
	#   see        ShouldReturnTRUE, ShouldReturnFALSE, SetChainToReturn
	def ShouldContinue()
		if @bSouldContinue = 1
			return 1

		else
			return 0
		ok
	
	# Returns whether the last step tagged the chain as true.
	#
	#   returns    1 or 0
	#   see        ShouldReturnFALSE, SetChainToReturn, get_
	def ShouldReturnTRUE()
		if @bShouldReturnTRUE = 1 
			return 1

		else
			return 0
		ok

	# Returns whether a step tagged the chain as false, which makes every later step stay false.
	#
	#   returns    1 or 0
	#   see        ShouldReturnTRUE, SetChainToReturn, get_
	def ShouldReturnFALSE()
		if @bShouldReturnFALSE = 1
			return 1

		else
			return 0
		ok

	# Tags the chain with its verdict: 1 for true, 0 for false, or :CONTINUE to clear it.
	#
	#   p          the verdict, 1 or 0, or :CONTINUE
	#   returns    nothing
	#   note       after 0 every later step answers false whatever it tests, so a chain cannot be
	#              reused once it failed
	#   warning    any other value changes nothing
	#   see        ShouldReturnTRUE, ShouldReturnFALSE, get_
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

	# Tests the held value against a type word, a trait word, a value or a list of trait words, tags the chain true or false and returns it.
	#
	#   pThing     what to test: a type such as :String, a trait such as :Lowercase, a value equal
	#              to the held one, or a list of traits that must all hold
	#   returns    the chain itself; close it with the _ attribute to read 1 or 0
	#   note       a value is equal to the held one without regard to case; an unknown word gives a
	#              false chain, not an error
	#   warning    the form with a function call such as 'LetterOf("HUSSEIN")' raises error R13
	#              Object is required, because the call builds a chain with the name _ which inside
	#              the class is an attribute; once the chain is false, later steps stay false
	#   see        IsA, IsThe, Which, get_
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

			# FOLD CASE ONCE, AT THE DOOR. Ring lowercases a :Symbol
			# (`:String` IS the string "string") and ring_methods()
			# answers in lowercase -- while Ring's string `=` is
			# CASE-SENSITIVE. So every comparison below used to match
			# only when the caller wrote the symbol form: `Is(:String)`
			# answered 1 and `Is("String")` answered 0, silently, by
			# falling through to the default. Same for the method
			# branch: the needle "isUppercase" never met the method
			# name "isuppercase".
			# The VALUE comparisons above deliberately keep their own
			# casing -- this fold is only for TYPE and METHOD names.
			_cThing_ = StzLower(pThing)

			# Case of the 4 native ring types
			if _cThing_ = :Number and This._Type() = "NUMBER"
				bResult = 1

			but _cThing_ = :String and This._Type() = "STRING"
				bResult = 1

			but _cThing_ = :List and This._Type() = "LIST"
				bResult = 1

			but _cThing_ = :Object and This._Type() = "OBJECT"
				bResult = 1

			# Case of a stz object method
			but StzFindFirst("is" + _cThing_, ring_methods(This.StzObjectQ())) > 0
				# Example: _("A").Is( :Uppercase )
	
				# This.StzObjectQ(), like the other eval'd calls in this class
				# (see the ones built further down). A bare StzObject() here
				# named the method as it was BEFORE it took its Q -- and a
				# name inside an eval'd STRING is invisible to a rename sweep,
				# so it went on compiling and died at run time with R3.
				_cCode_ = 'bResult = This.StzObjectQ().Is' + pThing + '()'
				eval(_cCode_)
	
			# Case of a function call
			but (StzFindFirst("(", pThing) > 1 and StzFindFirst(")", pThing) > 0 and StringNumberOfOccurrence(pThing, "(") = 1 and StringNumberOfOccurrence(pThing, ")") = 1 and StzFindFirst("(", pThing) < StzFindFirst(")", pThing) and StzRight(pThing, 1) = ")")
				# Example: _("H").Is('LetterOf("HUSSEIN")')._

				_cCode_ = 'bResult = _(' + ComputableForm(This.Value()) + ').Q.Is' + pThing
				eval(_cCode_)

			else
				# Case of an eventual function call
				_cCode_ = pThing
				try
					eval(_cCode_)
				catch
					bResult = 0
				done
			ok

		# Case of a list of strings
		but  @IsListOfStrings(pThing)
			# Example:
			# ? _(["A","B","C"]).Is([ :AListOfStrings, :AListOfChars, :AListOfLetters ]).AtTheSameTime._

			# same case fold as the scalar branch: ring_methods()
			# answers lowercase, and `=` is case-sensitive
			bIsListOfMethods = 1
			nThing2Len = len(pThing)
			for iLoopThing2 = 1 to nThing2Len
				str = StzLower(pThing[iLoopThing2])
				if NOT ( StzFindFirst("is" + str, ring_methods(This.StzObjectQ())) > 0 )
					bIsListOfMethods = 0
					exit
				ok
			next

			if bIsListOfMethods
				bResult = 1
				nThing1Len = len(pThing)
				for iLoopThing1 = 1 to nThing1Len
					str = pThing[iLoopThing1]
					# NOT `_(...)` HERE. `_` is a bare class ATTRIBUTE
					# (the magic chain-closer declared in the class
					# head), so inside this class `_(x)` is not the
					# global constructor at all -- it resolves to the
					# attribute and the next method call dies with R13
					# "Object is required". Build the sub-chain
					# explicitly, and give it its own statement (a
					# method chained onto a `new` expression is the
					# other half of that same R13).
					# This block had never RUN before the case fold
					# above: its guard could not pass while
					# "isAListOfStrings" was matched against lowercase
					# method names, so fixing the fold unmasked it.
					_oSubChain_ = new stzChainOfTruth(This.Value())
					_oSubChain_.Is(str)
					if NOT _oSubChain_._
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

		# Returns 0 whatever it is asked, because it negates the chain object that Is returns instead of its verdict.
		#
		#   pThing     what to test, as for Is
		#   returns    0
		#   warning    tested with "ring" against :Number and against :String, and both answered 0,
		#              where the first should be true
		#   see        Is, IsNotThe, IsNotAn
		#< @FunctionNegativeForm
		def IsNot(pThing)
			bResult = This.Is(pThing)
			return NOT bResult

		#>

		def AndA(pThing)
			return This.Is(pThing)

	def AndThe(pThing)
		return This.IsThe(pThing)

	# Tests the held value like Is, with a rule for function calls ending in in or of; for any other word it behaves exactly like Is.
	#
	#   pThing     what to test, as for Is
	#   returns    the chain itself; close it with the _ attribute to read 1 or 0
	#   warning    the form 'LetterOf("HUSSEIN")' raises error R3 Calling Function without
	#              definition: functionnamefinishes..., because the helper it calls has another name
	#   see        Is, IsNotA, IsNotAn
	def IsA(pThing)

		# Captures expressions like this: _("H").IsA('LetterOf("HUSSEIN")')._
		# Returns 0 for any other expression.

		# Managing the special semantic meaning of IsA()
		if isString(pThing) and
		   (StzFindFirst("(", pThing) > 1 and StzFindFirst(")", pThing) > 0 and StringNumberOfOccurrence(pThing, "(") = 1 and StringNumberOfOccurrence(pThing, ")") = 1 and StzFindFirst("(", pThing) < StzFindFirst(")", pThing) and StzRight(pThing, 1) = ")") and
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
			_cCode_ = 'bResult = _(' + ComputableForm(This.Value()) + ').Q.Is' + _cFunCode_
	
			#--> Example of generated code:
			# bResult = _("H").Q.IsLetterOf("HUSSEIN")

			# Which invoques the IsLetterOf() method from stzString

			# Now, we evaluate that code and get 1 or 0
			# as produced, normally, by the @ softanza object
			
			eval(_cCode_)

			# Let's leverage the result we got to apply the sepeciefic
			# semantics of IsA() as explained above

			_cValue_ = FunctionParam(pThing)
			_cMethod_ = StzLeft(_cFuncName_, StzLen(_cFuncName_) - 2)
			_cIsMethod_ = "is" + _cMethod_
			_cIsMethodCall_ = _cIsMethod_ + "()"
			_cCode_ = "bPass = _(" + ComputableForm(_cValue_) + ").Q.NumberOfItemsW('{ _(@item).Q." + _cIsMethodCall_ + " }') > 1"

				eval(_cCode_)
	

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

		# Raises error R24 on every call, because its body reads the name pThing while its parameter is called pcThing.
		#
		#   pcThing    what to test
		#   returns    nothing, since it always raises
		#   warning    tested with :Number and with :String, and both raised error R24 Using
		#              uninitialized variable: pthing
		#   see        IsA, IsNotAn
		#---
		def IsNotA(pcThing)
			bResult = This.IsA(pThing)
			return NOT bResult
	
		def IsAn(pThing)
			return This.IsA(pThing)
	
		# Returns 0 whatever it is asked, because it negates the chain object that IsAn returns instead of its verdict.
		#
		#   pThing     what to test, as for Is
		#   returns    0
		#   warning    tested with :Object and with :String, and both answered 0
		#   see        IsA, IsNot
		def IsNotAn(pThing)
			bResult = This.IsAn(pThing)
			return NOT bResult

	def IsThe(pThing)
		return This.Is(pThing)

	# Returns 0 whatever it is asked, because it negates the chain object that IsThe returns instead of its verdict.
	#
	#   pThing     what to test, as for Is
	#   returns    0
	#   warning    tested against "rang" and against "ring" for the value "ring", and both answered
	#              0
	#   see        Is, IsNot
	def IsNotThe(pThing)
		bResult = This.IsThe(pThing)
		return NOT bResult

	def IsTheOnly(pThing)
		return This.IsThe(pThing)

	# Records that the next Nor call is a negative test, ignores its argument and returns the chain.
	#
	#   pcThing    a word that is not used
	#   returns    the chain itself
	#   warning    the argument is not tested, so IsNeighther(:Number) does not check that the value
	#              is not a number
	#   see        Nor, IsNor, NeightherFunction
	def IsNeighther(pcThing)
		@cNeightherFunction = :IsNot
		return This

	# Records that the next Nor call is a negative test, ignores its argument and returns the chain.
	#
	#   pcThing    a word that is not used
	#   returns    the chain itself
	#   note       the same call as IsNeighther
	#   warning    the argument is not tested
	#   see        Nor, IsNeighther, NeightherFunction
	def IsNor(pcThing)
		@cNeightherFunction = :IsNot
		return This

	# Calls one method of the wrapped object on the held value, such as :IsEven, tags the chain with the answer and returns it.
	#
	#   pcMethod   the name of the method to call on the wrapped object, with or without its
	#              brackets
	#   returns    the chain itself; close it with the _ attribute to read 1 or 0
	#   note       once the chain is false, later steps stay false
	#   warning    a name that does not exist raises a Syntax Error naming Which
	#   see        Where, Is, get_
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

		_cCode_ = 'bResult = This.StzObjectQ().' + pcMethod

		if NOT (StzFindFirst("(", pcMethod) > 1 and StzFindFirst(")", pcMethod) > 0 and StringNumberOfOccurrence(pcMethod, "(") = 1 and StringNumberOfOccurrence(pcMethod, ")") = 1 and StzFindFirst("(", pcMethod) < StzFindFirst(")", pcMethod) and StzRight(pcMethod, 1) = ")")
			_cCode_ += "()"
		ok

		try
			eval(_cCode_)
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

	# Evaluates a condition on the wrapped object, such as NumberOfChars() = 4, tags the chain with the answer and returns it.
	#
	#   pcCondition   a Ring condition about the wrapped object, written without braces and starting
	#                 with one of its methods
	#   returns       the chain itself; close it with the _ attribute to read 1 or 0
	#   note          Having and That are the same call
	#   warning       a condition between braces, as '{ NumberOfChars() = 4 }', raises Syntax error!
	#                 Check the condition, because the braces are sent to the evaluator; an invalid
	#                 condition raises the same error
	#   see           Which, Containing, get_
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

		_cCode_ = "if This.StzObjectQ()." + _cCondition_ + char(10) +
			"	" + "bResult = 1" + char(10) +
			"else" + char(10) +
			"	bResult = 0" + char(10) +
			"ok"

		try
			eval(_cCode_)
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

	# Raises error Syntax error today for any text or list, instead of tagging the chain with whether the value holds p.
	#
	#   p          the item the value should contain
	#   returns    nothing, since it raises; a number gives the chain tagged false
	#   note       Contains and IsContaining are the same call
	#   warning    tested with a text and with a list, and both raised Syntax error! Check the
	#              condition you provided, because it builds the condition between braces and Where
	#              refuses braces
	#   see        Where, ContainingNo
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

	# Raises error Syntax error today for any text or list, instead of tagging the chain with whether the value lacks p.
	#
	#   p          the item the value should not contain
	#   returns    nothing, since it raises; a number gives the chain tagged false
	#   note       ContainsNo, DoesNotContain and IsContainingNo are the same call
	#   warning    tested with a text and with a list, and both raised Syntax error! Check the
	#              condition you provided, for the same reason as Containing
	#   see        Where, Containing
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

	# Calls the method named by NeightherFunction with p and returns its answer, which is always 0 today.
	#
	#   p          the thing to test, as for Is
	#   returns    0
	#   warning    tested after IsNeighther and IsNor, and the answer was 0 in both, since the
	#              method it calls is IsNot
	#   see        IsNeighther, NeightherFunction
		#>
	def Nor(p)
		_cCode_ = 'bResult = This.' + This.NeightherFunction() + '(p)'
		eval(_cCode_)

		return bResult

	# Raises error R13 for a number ending in 1, instead of returning the nth item of a call such as 'LetterOf("HUSSEIN")'.
	#
	#   pcThing    a function call as text, such as 'LetterOf("HUSSEIN")'
	#   returns    nothing for a number that does not end in 1 or for a non-number; raises error R13
	#              otherwise
	#   warning    with 21 it raised R13 Object is required, as Nth does
	#   see        Nth, nd, rd, th
	#------------------
	def st(pcThing)
		if This._Type() = "NUMBER" and
		   StzRight(''+ This.Value(), 1) = "1"

			return This.Nth(pcThing)
		ok

	# Raises error R13 for a number ending in 2, instead of returning the nth item of a call such as 'LetterOf("HUSSEIN")'.
	#
	#   pcThing    a function call as text, such as 'LetterOf("HUSSEIN")'
	#   returns    nothing for a number that does not end in 2 or for a non-number; raises error R13
	#              otherwise
	#   warning    with 2 it raised R13 Object is required, as Nth does
	#   see        Nth, st, rd, th
	def nd(pcThing)
		if This._Type() = "NUMBER" and
		   StzRight(''+ This.Value(), 1) = "2"

			return This.nth(pcThing)
		ok

	# Raises error R13 for a number ending in 3, instead of returning the nth item of a call such as 'LetterOf("HUSSEIN")'.
	#
	#   pcThing    a function call as text, such as 'LetterOf("HUSSEIN")'
	#   returns    nothing for a number that does not end in 3 or for a non-number; raises error R13
	#              otherwise
	#   warning    with 3 it raised R13 Object is required, as Nth does
	#   see        Nth, st, nd, th
	def rd(pcThing)
		if This._Type() = "NUMBER" and
		   StzRight(''+ This.Value(), 1) = "3"

			return This.nth(pcThing)
		ok

	# Raises error R13 for a number ending in 4 to 9 or 0, instead of returning the nth item of a call such as 'LetterOf("HUSSEIN")'.
	#
	#   pcThing    a function call as text, such as 'LetterOf("HUSSEIN")'
	#   returns    nothing for a number that ends in 1, 2 or 3 or for a non-number; raises error R13
	#              otherwise
	#   warning    with 7 and with 12 it raised R13 Object is required, as Nth does
	#   see        Nth, st, nd, rd
	def th(pcThing)
		/* Example:

		_(7).nth('LetterOf("HUSSEIN")').Q 	#--> "N"

		*/
		if This._Type() = "NUMBER" and
		   (0+ StzRight(''+ This.Value(), 1)) > 1

			return This.nth(pcThing)

		ok

	# Raises error R13 Object is required today for a number, instead of returning the nth item such as the 7th letter of HUSSEIN.
	#
	#   pcThing    a function call as text, such as 'LetterOf("HUSSEIN")'
	#   returns    nothing for a non-number; raises error R13 for a number
	#   warning    the call NthLetterOf(7, "HUSSEIN") on its own works and answers N; the failure is
	#              in the last line of the method, which builds the result with the name _, an
	#              attribute inside the class
	#   see        st, nd, rd, th
	def Nth(pcThing)

		This.SetChainToReturn(:Value)

		if This._Type() = "NUMBER"

			pcThing = StringSimplified(pcThing)

			_cCode_ = 'result = Nth' + pcThing
	
			_oStzString_ = new stzString(_cCode_)
			_n_ = _oStzString_.FindFirst("(")
	
			_cCode_ = StzLeft(_cCode_, _n_) + "" + This.Value() + ", " + StzMid(_cCode_, _n_ + 1, StzLen(_cCode_) - _n_)

			eval(_cCode_)

			return _( result )
		ok

	#------------------

	def get@()
		return This.StzObjectQ()

		def getQ()
			return This.StzObjectQ()

	# Returns 1 if the chain was tagged true, 0 if false, and the held value if no step decided; it answers the closing underscore.
	#
	#   returns    1, 0 or the held value
	#   note       _("ring").Is(:String)._ reads this method
	#   see        Is, Which, Where, get_@
	def get_()
		if This.ShouldReturnTRUE()
			return 1
			
		but This.ShouldReturnFALSE()
			return 0

		else
			return This.Value()

		ok

	# Returns the held value in the form Ring code would write it, such as "ring" with its quotes; it runs when the _@ attribute is read.
	#
	#   returns    a text
	#   note       a number 5 gives the text 5 and a list gives its bracketed form
	#   see        get_, Value
	def get_@
		return ComputableForm( This.Value() )

	# Returns the chain unchanged, so the words AmongOthers can sit in a sentence without effect.
	#
	#   returns    the chain itself
	#   see        getAtTheSameTime, Is
	def getAmongOthers
		return This

	# Returns the chain unchanged, so the words AtTheSameTime can follow a list of traits in Is without effect.
	#
	#   returns    the chain itself
	#   see        getAmongOthers, Is
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

	# Returns the text between the first brackets of a call written as text, quotes included.
	#
	#   pcFunctionCall   a call as text, such as 'LetterOf("HUSSEIN")'
	#   returns          a text; '"HUSSEIN"' for 'LetterOf("HUSSEIN")'
	#   note             private; run through a subclass
	#   see              pvtFunctionName, pvtFunctionParamType
	def pvtFunctionParam( pcFunctionCall )
		_oStzStr_ = new stzString(pcFunctionCall)

		_n1_ = _oStzStr_.FindFirstOccurrence("(") + 1
		_n2_ = _oStzStr_.FindFirstOccurrence(")") - 1

		return StzMid(pcFunctionCall, _n1_, _n2_ - _n1_ + 1)


	# Returns the part of a call written as text that comes before its first bracket.
	#
	#   pcFunctionCall   a call as text, such as 'LetterOf("HUSSEIN")'
	#   returns          a text; LetterOf for 'LetterOf("HUSSEIN")'
	#   note             private; run through a subclass
	#   see              pvtFunctionParam
	def pvtFunctionName( pcFunctionCall )
		_oStzStr_ = new stzString(pcFunctionCall)

		_n_ = _oStzStr_.FindFirstOccurrence("(") - 1

		return StzLeft(pcFunctionCall, _n_)

	# Returns 1 when the called name ends in in or of, whatever list it is given.
	#
	#   pcFunctionCall   a call as text
	#   paSubStr         the endings meant to be tested, which are ignored
	#   returns          1 or 0
	#   note             private; run through a subclass
	#   warning          the list paSubStr is ignored: the endings in and of are fixed in the code,
	#                    so [ "per" ] does not make Upper("H") answer 1
	#   see              pvtFunctionName
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

	# Returns the type of the first argument of a call written as text: STRING, LIST or NUMBER.
	#
	#   pcFunctionCall   a call as text, such as 'LetterOf("HUSSEIN")'
	#   returns          the text STRING, LIST or NUMBER
	#   note             private; run through a subclass
	#   warning          an argument that is not quoted, bracketed or numeric, such as F(abc),
	#                    raises error R41 Invalid numeric string, so the OBJECT answer in the code
	#                    is unreachable
	#   see              pvtFunctionParam, pvtFunctionParamTypeIsOneOfThese
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

	# Returns 1 when the type of the first argument of a call written as text is in the given list.
	#
	#   pcFunctionCall   a call as text
	#   paSubStr         the list of type names to look in, such as [ "STRING", "LIST" ]
	#   returns          1 or 0
	#   note             private; run through a subclass
	#   see              pvtFunctionParamType
	def pvtFunctionParamTypeIsOneOfThese( pcFunctionCall, paSubStr )
		_cType_ = pvtFunctionParamType(pcFunctionCall)
		return StzFindFirst(_cType_, paSubStr) > 0
