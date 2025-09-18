


func StzFalseObjectQ()
	return new stzFalseObject

	func 0Object()
		return new stzFalseObject

	func AFalseObject()
		return new stzFalseObject

	func FalseObject()
		return new stzFalseObject

	func FALSE()
		return new stzFalseObject

	func FALSEQ()
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
		return 0

		def Value()
			return Content()

	def StzType()
		return :stzFalseObject

	#--

	def Where(pcCondition)
		return 0

		def W(pcCondition)
			return 0

	#--

	def IsEqualToCS(p, pCaseSensitive)
		return 0

		#< @FunctionFluentForm

		def IsEqualToCSQ(p, pCaseSensitie)
			return This

		#>

		#< @FunctionAlternativeForms

		def EqualToCS(p, pCaseSensitive)
			return 0

			def EqualToCSQ(p, pCaseSensitive)
				return This

		def EqualsCS(p, pCaseSensitive)
			return 0

			def EqualCSQ(p, pCaseSensitive)
				return This

		#>

	#-- WITHOUT CASESENSITIVITY

	def IsEqualTo(p)
		return 0

		#< @FunctionFluentForm

		def IsEqualToQ(p)
			return This

		#>

		#< @FunctionAlternativeForms

		def EqualTo(p)
			return 0

			def EqualToQ(p)
				return This

		def Equals(p)
			return 0

			def EqualQ(p)
				return This

		#>

	def IsDividableBy(n)
		return 0

		def IsDividableByQ(n)
			return This

		def DividableBy(n)
			return 0

			def DividableByQ(n)
				return This

		def IsDivisibleBy(n)
			return 0

			def IsDivisibleByQ()
				return This

		def DivisibleBy(n)
			return 0

			def DivisibleByQ(n)
				return This
