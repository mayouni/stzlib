

func StzTrueObjectQ()
	return new stzTrueObject

	func _TRUE_Object()
		return new stzTrueObject

	func ATrueObject()
		return new stzTrueObject

		func TrueObject()
			return new stzTrueObject

	func StzTrueQ()
		return new stzTrueObject

	func _TRUE_()
		return new stzTrueObject

	func _TRUE_Q()
		return new stzTrueObject

class stzTrue from stzTrueObject

class stzTrueObject from stzObject

	@cVarName = :@trueobject

	def Content()
		return _TRUE_

		def Value()
			return Content()

	def Where(pcCondition)
		return _FALSE_

		def W(pcCondition)
			return _FALSE_

	def IsEqualToCSQ(p, pCaseSensitie)
		return This

		def IsEqualToQ(p)
			return This

		def EqualsQ(p)
			return This

	def IsEqualToCS(p, pCaseSensitive)
		return _TRUE_

		def IsEqualTo(p)
			return _TRUE_

		def Equals(p)
			return _TRUE_

	def StzType()
		return :stzTrueObject
