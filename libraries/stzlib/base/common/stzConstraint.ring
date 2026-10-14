
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

		_cConstraint_ = StzStringQ(pcConstraint).RemoveTheseBoundsQ("{","}").RemoveFirstBoundQ(char(10)).Simplified()
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

# Meant to pair an object with a condition that must always hold for it, such as a string that must stay lowercase.
#
# WARNING: no stzConstraint can be built today. The constructor calls IsConstraint, which calls
# RemoveFirstBoundQ on a string, a method that stzString does not have, so every construction raises
# R14. Once built it would also fail: Expression reads an unassigned variable and CheckConstraint
# always answers 0. The class is not used anywhere else in the library.
#
#   receiver   o1 = StzStringQ("hello")
#   example    ? o1.IsLowercase()
#              #--> 1
#   see        stzCCode
class stzConstraint from stzObject
	@oObject
	@cConstraint
	@cConstraintName
	
	# Raises error R14 today instead of building a constraint from an object and a condition.
	#
	#   pObject       the object the constraint guards
	#   pConstraint   the condition as text, such as '{ @.IsLowercase() }'
	#   returns       nothing; it raises
	#   note          checked with a string object, a list object, a braced and an unbraced text;
	#                 the methods below were run on a subclass that fills the two fields itself
	#   warning       every call with an object and a text raises R14 Calling Method without
	#                 definition: removefirstboundq, thrown by IsConstraint; any other argument
	#                 raises Incorrect types of object params, so no stzConstraint can be built
	#                 today
	#   see           IsConstraint
	def init( pObject, pConstraint )
		if isObject(pObject) and IsConstraint(pObject, pConstraint)

			@oObject = pObject
			@cConstraint = pConstraint

		else
			StzRaise("Incorrect types of object params!")
		ok

	# Returns the condition text exactly as it was given, braces included.
	#
	#   returns    a text
	#   warning    the object cannot be built today because init raises, so this method was run on a
	#              subclass that sets the fields itself
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

	# Returns the name of the constraint, which nothing sets today.
	#
	#   returns    an empty text
	#   warning    always empty: the field it reads is never assigned anywhere in the class
	#   see        Content
	def Name()
		return @cConstraintName

	# Raises error R24 today instead of returning the Ring code that tests the condition.
	#
	#   returns    nothing; it raises
	#   warning    reads a variable _cConstraint_ that is never assigned (the field is
	#              @cConstraint), so it raises R24 Using uninitialized variable on every call
	#   see        CheckConstraint
	def Expression()

		_cCode_ = "if " + _cConstraint_ + char(10) +
				char(9) + " // Pass" + char(10) +
			"else" + char(10) +
				char(9) + "StzRaise('Constraint unverified!')" + char(10) +
			"ok"

		return _cCode_

	# Returns 0 on every call today, whether or not the guarded object obeys the condition.
	#
	#   returns    0
	#   warning    always 0: the evaluation runs inside a try, and Expression raises first, so the
	#              failure is swallowed and reported as a broken constraint; checked on an object
	#              that obeys the condition and one that does not
	#   see        Expression
	def CheckConstraint()

		@ = This.Object()

		try
			eval(This.Expression())
			return 1
		catch
			return 0
		done
