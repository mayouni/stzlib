#------------------------#
#  STZ""OBJECT CLASS   #
#------------------------#

# Made firstly, just to be used in instanciating objects
# that do nothing, when I am writing test samples, so
# I am not obliged to write a class under the sample code,
# but evolauted to be used in sophisticaded ways while
# crafting chains of thoughts and natural-coding!


/* EXAMPLE

The Q(v) function elevates the value v to its corresponding
softanza type. So, it returns a stzNumber(v) object if v is
a number, a stzString(v) object if v is a string, a stzList(v)
if v is a list, or a stzObject(v) if v is an object.

After the softanza object is returned, we can expect it's data
type by using the method Type().

Here is an example:

	obj = new Person
	? Q(obj).Type()	#--> :Object
	
	class Person

To avoid writing a class every time I have to make a sample like this,
I made this stzNullObject class, so I can write just:

	obj = new stzNullObject # Or simply obj = NullObject()
	? Q(obj).Type()	#--> :Object
*/

func StzNullObjectQ()
	return new stzNullObject

	func NullObject()
		return new stzNullObject

	func ANullObject()
		return new stzNullObject

	func Null()
		return new stzNullObject

	func NullQ()
		return new stzNullObject

	func StzNullQ()
		return new stzNullObject

# Is an object that does nothing and holds nothing, for samples that need an object without writing a class.
#
# Its content is an empty text, its Where answers an empty text, and it is equal to nothing, not
# even to itself. NullObject(), ANullObject(), Null(), NullQ() and StzNullObjectQ() all return one.
# Build it without parentheses: new stzNullObject. Its counterpart that is equal to everything is
# stzTrueObject.
#
#   receiver   o1 = new stzNullObject
#   example    ? o1.IsEqualTo("")
#              #--> 0
#              ? isString(o1.Where("x > 1"))
#              #--> 1
#              ? o1.StzType()
#              #--> stznullobject
#   see        stzTrueObject, stzFalseObject, NullObject
class stzNullObject from stzObject
	
	@cVarName = :@nullobject

	# Returns an empty text, which is the null object's content.
	#
	#   returns    an empty text
	#   see        Value, Where
	def Content()
		return ""

		# Returns the same empty text as Content.
		#
		#   returns    an empty text
		#   see        Content
		def Value()
			return Content()

	# Returns an empty text whatever the condition says; the condition is not evaluated.
	#
	#   pcCondition   a condition, ignored
	#   returns       an empty text
	#   see           W, stzTrueObject
	def Where(pcCondition)
		return ""

		# Returns an empty text whatever the condition says, like Where.
		#
		#   pcCondition   a condition, ignored
		#   returns       an empty text
		#   see           Where
		def W(pcCondition)
			return ""

	def IsEqualToCSQ(p, pCaseSensitie)
		return This

		def IsEqualToQ(p)
			return This

		def EqualsQ(p)
			return This

	def IsEqualToCS(p, pCaseSensitive)
		return 0

		# Returns 0 for every argument, even for the null object itself: null is equal to nothing.
		#
		#   p          the value to compare, ignored
		#   returns    0, a number
		#   note       IsEqualToCS gives the same answer, and IsEqualToQ and IsEqualToCSQ return the
		#              null object so a chain goes on
		#   see        Equals, IsEqualToQ
		def IsEqualTo(p)
			return 0

		# Returns 0 for every argument, as IsEqualTo does.
		#
		#   p          the value to compare, ignored
		#   returns    0, a number
		#   note       EqualsQ returns the null object so a chain goes on
		#   see        IsEqualTo
		def Equals(p)
			return 0

	# Returns the type name of the object, stzNullObject, as a symbol.
	#
	#   returns    the symbol stznullobject
	#   see        Content
	def StzType()
		return :stzNullObject
