


func StzFalseObjectQ()
	return new stzFalseObject

	func _FALSE_Object()
		return new stzFalseObject

	func AFalseObject()
		return new stzFalseObject

	func _FALSE_()
		return new stzFalseObject

	func _FALSE_Q()
		return new stzFalseObject

	func StzFalseQ()
		return new stzFalseObject

#< @ClassMisspelledForms

class stzFalsObject from stzFalseObject
class stzFlaseObject from stzFalseObject

#>

class stzFalse from stzFalseObject

class stzFalseObject from stzObject
	@cVarName = :@falseobject

	def Content()
		return _FALSE_

		def Value()
			return Content()

	def StzType()
		return :stzFalseObject

	#--

	def Where(pcCondition)
		return _FALSE_

		def W(pcCondition)
			return _FALSE_

	#--

	def IsEqualToCS(p, pCaseSensitive)
		return _FALSE_

		#< @FunctionFluentForm

		def IsEqualToCSQ(p, pCaseSensitie)
			return This

		#>

		#< @FunctionAlternativeForms

		def EqualToCS(p, pCaseSensitive)
			return _FALSE_

			def EqualToCSQ(p, pCaseSensitive)
				return This

		def EqualsCS(p, pCaseSensitive)
			return _FALSE_

			def EqualCSQ(p, pCaseSensitive)
				return This

		#>

	#-- WITHOUT CASESENSITIVITY

	def IsEqualTo(p)
		return _FALSE_

		#< @FunctionFluentForm

		def IsEqualToQ(p)
			return This

		#>

		#< @FunctionAlternativeForms

		def EqualTo(p)
			return _FALSE_

			def EqualToQ(p)
				return This

		def Equals(p)
			return _FALSE_

			def EqualQ(p)
				return This

		#>

	def IsDividableBy(n)
		return _FALSE_

		def IsDividableByQ(n)
			return This

		def DividableBy(n)
			return _FALSE_

			def DividableByQ(n)
				return This

		def IsDivisibleBy(n)
			return _FALSE_

			def IsDivisibleByQ()
				return This

		def DivisibleBy(n)
			return _FALSE_

			def DivisibleByQ(n)
				return This
