
/*
	A constraint is an conditional statement applied to
	a given object that resrticts the change of its content.

	Say you have a StzString object containing "hello!":

		StzStringQ("hello!")

	And that you want to avoid updating it with any capital letters
	(i.e. you want it to stay always in lowercase!)

	Then you add a constraint to that object like this:

		StzStringQ("hello!") {
			EnforceConstraint('{ @.IsLowercase }')

			# Your other code here...
		}

	Now, if one tries to break the law and update it with uppercase,
	the object self-protection mechanism want't let him do so:

		StzStringQ("hello!") {
			EnforceConstraint('{ @.IsUppercase }')

			# Try to break the law:
			UpdateWith("HELLO!")

			#--> Softanza complains and raises an error!
		}

*/

func StzConstraintQ(pObject, pConstraint)
	return new stzConstraint(pObject, pConstraint)

func IsConstraint(pObject, pcConstraint)
	if NOT isObject(pObject)
		return 0
	ok

	if isString(pcConstraint)
		@ = pObject

		_cConstraint_ = _StzConstraintBody(pcConstraint)
		if _cConstraint_ = ""
			StzRaise("Constraint can't be empty!")
		ok

		_cCode_ = "if " + _cConstraint_ + char(10) +
				char(9) + "// Do nothing!" + char(10) +
			"ok"

		try
			eval(_cCode_)
			return 1
		catch
			return 0
		done
	else
		return 0
	ok

	func @IsConstraint(pObject, pcConstraint)
		return IsConstraint(pObject, pcConstraint)

# The condition of a constraint text, ready to be put after an if: the ends are trimmed and ONE pair of
# braces enclosing the whole text is taken off. Inner braces are left alone.
func _StzConstraintBody(pcConstraint)
	_cBody_ = StzTrim(pcConstraint)
	_nBodyLen_ = StzLen(_cBody_)
	if _nBodyLen_ >= 2
		_cFirst_ = StzLeft(_cBody_, 1)
		_cLast_ = StzRight(_cBody_, 1)
		if _cFirst_ = "{" and _cLast_ = "}"
			_cBody_ = StzTrim(StzMid(_cBody_, 2, _nBodyLen_ - 2))
		ok
	ok
	return _cBody_


# Pairs an object with a condition, written as Ring code in a text, that the object is expected to obey, and checks it on demand.
#
# The condition says @ for the guarded object: '{ @.IsLowercase() }' or the same without braces. The
# braces are optional and only one enclosing pair is taken off. A constraint is built even when the object
# does not obey the condition (CheckConstraint answers 0 then); it is refused only when the condition cannot
# run on the object at all.
#
#   receiver   o1 = new stzConstraint(StzStringQ("hello"), "{ @.IsLowercase() }")
#   example    ? o1.CheckConstraint()
#              #--> 1
#   warning    the condition text is EXECUTED AS CODE, once when the constraint is built and again at
#              each check: build constraints only from text that comes from a trusted source, never
#              from user input. The constraint keeps its own COPY of the object, so a later change to
#              the original is not seen by the check. Forms the class does not offer: there is no
#              named :Of / :On argument form, and no condition longer than one expression
#   see        stzCCode
class stzConstraint from stzObject
	@oObject
	@cConstraint
	@cConstraintName
	@cLastError
	
	# Builds a constraint from the object to guard and the condition text, refusing a condition that cannot run on that object.
	#
	#   pObject       the object the constraint guards; the constraint keeps a copy of it
	#   pConstraint   the condition as Ring code in a text, braced or not, such as '{ @.IsLowercase() }',
	#                 where @ stands for the object
	#   returns       nothing; the constraint is built, unnamed
	#   note          a condition the object does not obey is accepted, only one that cannot run on it is
	#                 refused; the condition is run once here to find out
	#   warning       the text is executed as Ring code: give it only trusted text. A pObject that is not
	#                 an object or a pConstraint that is not a text raises Incorrect types of object
	#                 params!, an empty condition raises Constraint can't be empty!, and a condition
	#                 that raises on the object (a syntax error, a missing method) raises Constraint
	#                 can't be evaluated on the given object!
	#   see           IsConstraint
	def init( pObject, pConstraint )
		if NOT ( isObject(pObject) and isString(pConstraint) )
			StzRaise("Incorrect types of object params!")
		ok

		if NOT IsConstraint(pObject, pConstraint)
			StzRaise("Constraint can't be evaluated on the given object!")
		ok

		@oObject = pObject
		@cConstraint = pConstraint
		@cConstraintName = ""
		@cLastError = ""

	# Returns the condition text exactly as it was given, braces included.
	#
	#   returns    a text
	#   see        Object
	def Content()
		return @cConstraint

		def Value()
			return This.Content()

	def Constraint()
		return This.Content()

	# Returns the guarded object, the one the condition is checked against.
	#
	#   returns    the object
	def Object()
		return @oObject

	# Returns the label given to the constraint, or an empty text when it has none.
	#
	#   returns    a text
	#   note       it is the constraint's own label, set with SetName; VarName, the variable name every
	#              object carries, is a different field and is not changed by SetName
	#   see        SetName
	def Name()
		return @cConstraintName

		def NameQ()
			return new stzString( This.Name() )

	# Gives the constraint a label that Name reads back, replacing any earlier one.
	#
	#   pcName     the label as a text; an empty text clears it
	#   returns    nothing; SetNameQ returns the constraint for chaining
	#   warning    a label that is not a text raises Incorrect param type! pcName must be a string.
	#   see        Name
	def SetName(pcName)
		if NOT isString(pcName)
			StzRaise("Incorrect param type! pcName must be a string.")
		ok

		@cConstraintName = pcName

		def SetNameQ(pcName)
			This.SetName(pcName)
			return This

	# Returns the Ring code that tests the condition on @ and raises Constraint unverified! when it fails.
	#
	#   returns    a text of Ring code: the condition without its braces, inside an if, with a branch
	#              that raises when the condition is false
	#   note       the text is trimmed and one enclosing pair of braces is taken off, so braced,
	#              unbraced and multi-line forms of the same condition give the same code
	#   warning    the code is run by CheckConstraint, so it is as trusted as the condition text
	#   see        CheckConstraint
	def Expression()

		_cCode_ = "if " + _StzConstraintBody(@cConstraint) + char(10) +
				char(9) + " // Pass" + char(10) +
			"else" + char(10) +
				char(9) + "StzRaise('Constraint unverified!')" + char(10) +
			"ok"

		return _cCode_

	# Tells whether the guarded object obeys the condition, 1 when it does and 0 when it does not.
	#
	#   returns    1 or 0
	#   note       0 also covers a condition that raises when it is run (the object failed inside the
	#              condition); Verdict and LastError tell that case apart from a plain violation
	#   see        Verdict, Expression
	def CheckConstraint()

		_cVerdict_ = This.Verdict()
		if _cVerdict_ = "holds"
			return 1
		ok
		return 0

	# Runs the check and says what happened: holds, violated, or broken when the condition itself raised.
	#
	#   returns    "holds" when the object obeys the condition, "violated" when the condition ran and
	#              answered no, "broken" when running it raised an error of its own
	#   note       the Ring error of a broken check is kept for LastError; a holding or a violated check
	#              clears it. A condition that raises the exact text Constraint unverified! is read as
	#              a violation
	#   see        LastError, CheckConstraint
	def Verdict()

		@ = This.Object()
		@cLastError = ""

		try
			eval(This.Expression())
			return "holds"
		catch
			_cErr_ = StzTrim(cCatchError)
			if _cErr_ = "Constraint unverified!"
				return "violated"
			ok
			@cLastError = _cErr_
			return "broken"
		done

	# Returns the Ring error kept by the last check that was broken, or an empty text.
	#
	#   returns    a text; empty before any check, after a check that holds, and after a violated one
	#   see        Verdict
	def LastError()
		return @cLastError
