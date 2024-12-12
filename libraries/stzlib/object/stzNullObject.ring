#------------------------#
#  STZNULLOBJECT CLASS   #
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

class stzNullObject from stzObject
	
	@cVarName = :@nullobject

	def Content()
		return NULL

		def Value()
			return Content()

	def Where(pcCondition)
		return NULL

		def W(pcCondition)
			return NULL

	def IsEqualToCSQ(p, pCaseSensitie)
		return This

		def IsEqualToQ(p)
			return This

		def EqualsQ(p)
			return This

	def IsEqualToCS(p, pCaseSensitive)
		return _FALSE_

		def IsEqualTo(p)
			return _FALSE_

		def Equals(p)
			return _FALSE_

	def StzType()
		return :stzNullObject
