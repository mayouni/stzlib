


func StzFalseObjectQ()
	return new stzFalseObject

	func 0Object()
		return new stzFalseObject

	func AFalseObject()
		return new stzFalseObject

	# NNL 2.0: a false premise CARRIES the object it judged, so the
	# conditional mood can recover it -- .Otherwise(:Trim) runs on the
	# origin and hands the live chain back.
	func AFalseObjectXT(poOrigin)
		_oFo_ = new stzFalseObject
		_oFo_.SetOrigin(poOrigin)
		# P2: the chain-local main travels through the false branch too
		if isObject(poOrigin) and
		   StzFindFirst("nnlmainraw", ring_methods(poOrigin)) > 0 and
		   isObject(poOrigin.NNLMainRaw())
			_oFo_.SetNNLMain(poOrigin.NNLMainRaw())
		ok
		return _oFo_

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
	@oNNLOrigin = 0
	@cNNLWhyStopped = "a premise in the chain did not hold"

	def Content()
		return 0

		def Value()
			return Content()

	def StzType()
		return :stzFalseObject

	#-- NNL 2.0 (see doc/design/NNL_REVIEW.md) -----------------------------
	# The false premise as a DISCOURSE object: it remembers what it judged
	# (origin), it absorbs every counting/comparison device with an honest
	# explanation, and it powers the CONDITIONAL MOOD.

	def SetOrigin(poObj)
		@oNNLOrigin = poObj

	def Origin()
		return @oNNLOrigin

	# the CHAIN-STOPPED explanation (the user-facing debug surface, per
	# the WhyChainStopped precedent): recorded at the failing check
	def SetWhyStopped(pcWhy)
		@cNNLWhyStopped = pcWhy

	def WhyStopped()
		return @cNNLWhyStopped

		def WhyCheckFailed()
			return @cNNLWhyStopped

	# conditional mood on the FALSE branch: IfSo skips, Otherwise recovers
	def IfSo(pAction)
		return This

		def IfSoQ(pAction)
			return This

	def Otherwise(pAction)
		if isObject(@oNNLOrigin)
			@oNNLOrigin._NNLDo(pAction)
			return @oNNLOrigin
		ok
		return This

		def OtherwiseQ(pAction)
			return This.Otherwise(pAction)

	# every NNL counting/comparison device answers 0 through here, and
	# says why -- the monad absorbs the SURFACE without hiding the truth
	def _NNLNounCount(pcMethod)
		$cStzLastWhyB = "no: the premise before was already false"
		return 0

	def _NNLCountIs(pcMethod)
		$cStzLastWhyB = "no: the premise before was already false"
		return 0

	def _NNLValueIs(pcMethod)
		$cStzLastWhyB = "no: the premise before was already false"
		return 0

	def WasEver(pcDesc)
		$cStzLastWhyB = "no: the premise before was already false"
		return 0

	def WasNever(pcDesc)
		$cStzLastWhyB = "no: the premise before was already false"
		return 0

	def UsedToBe(pcDesc)
		$cStzLastWhyB = "no: the premise before was already false"
		return 0

	def IsStill(pcDesc)
		$cStzLastWhyB = "no: the premise before was already false"
		return 0

	def VerifyConstraint(pcName)
		$cStzLastWhyB = "no: the premise before was already false"
		return 0

	def VerifyConstraints()
		$cStzLastWhyB = "no: the premise before was already false"
		return 0

	def ApplyConstraints()
		return This

	def EnforceConstraint(pcName, pRule)
		return This

	def EnforceConstraints()
		return This

	def EnforceConstraintWhile(pcName, pRule, pCond)
		return This

	def EnforceConstraintUntil(pcName, pRule, pCond)
		return This

	def RelaxConstraints()
		return This

	def QualifiesAs(pcKind)
		$cStzLastWhyB = "no: the premise before was already false"
		return 0

	def QualifiesAsQ(pcKind)
		return This

	def _NNLImmutable(pcMethod, paParams)
		$cStzLastWhyB = "no: the premise before was already false"
		return This

	def _NNLExpectCompare(nActual)
		$cStzLastWhyB = "no: the premise before was already false"
		return 0
	#-----------------------------------------------------------------------

	#-- Fluent boolean short-circuit: every check stays FALSE; AndQ/OrQ keep the
	#-- chain going (so StartsWithXTQ(a).AndQ().EndsWithXT(b) is FALSE when a fails).

	def AndQ()
		return This

	# Q3: on a FALSE premise, OR gives the SECOND disjunct its chance --
	# the carried origin comes back to life ("is a number OR a string")
	def OrQ()
		if isObject(@oNNLOrigin)
			return @oNNLOrigin
		ok
		return This

	# under neither...nor a failing predicate is what KEEPS the chain
	# alive -- but once false for another reason, false absorbs
	def NorQ()
		return This

	def BothQ()
		return This

	def IsEitherQ()
		return This

	def IsNeitherQ()
		return This

	def NeitherQ()
		return This

	def EachQ()
		return This

	def AnyQ()
		return This

	def NoneQ()
		return This

	def EachItemQ()
		return This

	def AnyItemQ()
		return This

	def NoItemQ()
		return This

	def ANumberQ()
		return This

	def AStringQ()
		return This

	def AListQ()
		return This

	def AnObjectQ()
		return This

	def ACharQ()
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
