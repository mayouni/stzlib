


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

	#-- Fluent boolean short-circuit: every check stays FALSE; AndQ/OrQ keep the
	#-- chain going (so StartsWithXTQ(a).AndQ().EndsWithXT(b) is FALSE when a fails).

	def AndQ()
		return This

	def OrQ()
		return This

	def StartsWith(p)
		return 0

	def StartsWithXT(p)
		return 0

	def StartsWithAny(p)
		return 0

	def StartsWithXTQ(p)
		return This

	def EndsWith(p)
		return 0

	def EndsWithXT(p)
		return 0

	def EndsWithAny(p)
		return 0

	def EndsWithXTQ(p)
		return This

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

#-----------------------------------------------------------------#
#  WHOLE-OBJECT CONDITION GUARD                                    #
#-----------------------------------------------------------------#
# Returned by the passing branch of a type-guard like IsAPairQ():
# a truthy guard whose .Where(cond) evaluates the condition ONCE
# with the type keyword (@pair, @list, @string, @number, @object)
# bound to the WHOLE object -- so @pair[1] means the pair's first
# element, not "index into each item". (A FAILING type-guard returns
# a stzFalseObject instead, whose .Where(cond) -> 0.) This is what
# makes  o.IsAPairQ().Where('isString(@pair[1]) and isNumber(@pair[2])')
# answer TRUE for the pair [ :x, 5 ].

class stzObjectGuard from stzObject
	@oObj
	@cKeyword

	def init(poObj, pcKeyword)
		@oObj = poObj
		@cKeyword = pcKeyword

	def Content()
		return @oObj.Content()

		def Value()
			return This.Content()

	def Object()
		return @oObj

	def Keyword()
		return @cKeyword

	def Where(pcCondition)
		#-- Bind every whole-object keyword to the whole receiver, so
		#-- @pair[1] -> This[1]. The condition is then item-invariant; a
		#-- single engine-backed CheckW over the object answers TRUE/FALSE.
		_cWogCond_ = pcCondition
		_aWogKw_ = [ "@pair", "@list", "@string", "@number", "@object" ]
		_nWogKw_ = len(_aWogKw_)
		for _iWog_ = 1 to _nWogKw_
			_cWogCond_ = StzReplace(_cWogCond_, _aWogKw_[_iWog_], "This")
		next
		return @oObj.CheckW(_cWogCond_)

		def W(pcCondition)
			return This.Where(pcCondition)
