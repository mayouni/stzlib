
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

		_cConstraint_ = StzStringQ(pcConstraint).RemoveTheseBoundsQ("{","}").RemoveFirstBoundQ(NL).Simplified()
		if _cConstraint_ = ""
			StzRaise("Constraint can't be empty!")
		ok

		_cCode_ = "if " + _cConstraint_ + NL +
				TAB + "// Do nothing!" + NL +
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

class stzConstraint from stzObject
	@oObject
	@cConstraint
	@cConstraintName
	
	def init( pObject, pConstraint )
		if isObject(pObject) and IsConstraint(pObject, pConstraint)

			@oObject = pObject
			@cConstraint = pConstraint

		else
			StzRaise("Incorrect types of object params!")
		ok

	def Content()
		return @cConstraint

		def Value()
			return This.Content()

	def Constraint()
		return This.Content()

	def Object()
		return @oObject

	def Name()
		return @cConstraintName

	def Expression()

		_cCode_ = "if " + _cConstraint_ + NL +
				TAB + " // Pass" + NL +
			"else" + NL +
				TAB + "StzRaise('Constraint unverified!')" + NL +
			"ok"

		return _cCode_

	def CheckConstraint()

		@ = This.Object()

		try
			eval(This.Expression())
			return 1
		catch
			return 0
		done
