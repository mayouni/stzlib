

func StzTrueObjectQ()
	return new stzTrueObject

	func TrueObject()
		return new stzTrueObject

	func ATrueObject()
		return new stzTrueObject

	func StzTrueQ()
		return new stzTrueObject

	func True()
		return new stzTrueObject

	func TrueQ()
		return new stzTrueObject

class stzTrue from stzTrueObject

class stzTrueObject from stzObject

	@cVarName = :@trueobject

	def Content()
		return TRUE

		def Value()
			return Content()

	def Where(pcCondition)
		return FALSE

		def W(pcCondition)
			return FALSE

	def IsEqualToCSQ(p, pCaseSensitie)
		return This

		def IsEqualToQ(p)
			return This

		def EqualsQ(p)
			return This

	def IsEqualToCS(p, pCaseSensitive)
		return TRUE

		def IsEqualTo(p)
			return TRUE

		def Equals(p)
			return TRUE

	def StzType()
		return :stzTrueObject
