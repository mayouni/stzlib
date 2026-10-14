

func StzTrueObjectQ()
	return new stzTrueObject

	func 1Object()
		return new stzTrueObject

	func ATrueObject()
		return new stzTrueObject

		func TrueObject()
			return new stzTrueObject

	func StzTrueQ()
		return new stzTrueObject

	func TRUE()
		return new stzTrueObject

	func TRUEQ()
		return new stzTrueObject

class stzTrue from stzTrueObject

# Is an object that holds the value 1 and is equal to everything, as the passing counterpart of the null object.
#
# Its content is 1 and every comparison with it answers 1, whatever the other side is; its Where
# answers 0 because it has nothing to filter. TRUE(), TrueObject(), ATrueObject(), StzTrueQ() and
# StzTrueObjectQ() return one, and stzTrue is another name of the class. Build it without
# parentheses: new stzTrueObject.
#
#   receiver   o1 = new stzTrueObject
#   example    ? o1.Content()
#              #--> 1
#              ? o1.IsEqualTo("anything")
#              #--> 1
#              ? o1.Where("x > 1")
#              #--> 0
#   see        stzNullObject, stzFalseObject, TRUE
class stzTrueObject from stzObject

	@cVarName = :@trueobject

	# Returns 1, which is the true object's content.
	#
	#   returns    1, a number
	#   see        Value, Where
	def Content()
		return 1

		# Returns the same 1 as Content.
		#
		#   returns    1, a number
		#   see        Content
		def Value()
			return Content()

	# Returns 0 whatever the condition says; the condition is not evaluated.
	#
	#   pcCondition   a condition, ignored
	#   returns       0, a number
	#   see           W, stzNullObject
	def Where(pcCondition)
		return 0

		# Returns 0 whatever the condition says, like Where.
		#
		#   pcCondition   a condition, ignored
		#   returns       0, a number
		#   see           Where
		def W(pcCondition)
			return 0

	def IsEqualToCSQ(p, pCaseSensitie)
		return This

		def IsEqualToQ(p)
			return This

		def EqualsQ(p)
			return This

	def IsEqualToCS(p, pCaseSensitive)
		return 1

		# Returns 1 for every argument, whatever it is: the true object is equal to everything.
		#
		#   p          the value to compare, ignored
		#   returns    1, a number
		#   note       IsEqualToCS gives the same answer, and IsEqualToQ and IsEqualToCSQ return the
		#              object so a chain goes on
		#   see        Equals, IsEqualToQ
		def IsEqualTo(p)
			return 1

		# Returns 1 for every argument, as IsEqualTo does.
		#
		#   p          the value to compare, ignored
		#   returns    1, a number
		#   note       EqualsQ returns the object so a chain goes on
		#   see        IsEqualTo
		def Equals(p)
			return 1

	# Returns the type name of the object, stzTrueObject, as a symbol.
	#
	#   returns    the symbol stztrueobject
	#   see        Content
	def StzType()
		return :stzTrueObject
