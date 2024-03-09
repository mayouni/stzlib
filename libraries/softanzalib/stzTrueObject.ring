

func StzTrueObjectQ()
	return new stzTrueObject

	func TrueObject()
		return new stzTrueObject

	func ATrueObject()
		return new stzTrueObject

	
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

	def IsEqualToCS(p, pCaseSensitive)
		return TRUE

		def ISEqualTo(p)
			return TRUE
