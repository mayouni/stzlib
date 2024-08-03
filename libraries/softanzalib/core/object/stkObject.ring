
func StzCoreObjectQ(p)
	return new stzCoreObject(p)

	func StkObjectQ(p)
		return new stzCoreObject(p)

class stkObject from stzCoreObject

class stzCoreObject
	@content

	def init(pOpject)
		if NOT isObject(pObject)
			raise("Incorrect param type! pObject must be an object.")
		ok

		@content= pObject

	def Content()
		return @content

	def Copy()
		return new stzCoreObject(@content)	

	def StzType()
		return "stzobject"

	def IsStzObject()
		return TRUE

	



