


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

# Stands for a premise that did not hold: the object a failed natural chain returns, which keeps the chain going without turning true.
#
# A check written as a chain, such as Q("AnnIE").AtMost(2).VowelNBQ(), answers a stzFalseObject when
# it fails, so the next words of the sentence can still be read without raising an error. It carries
# two things: the sentence that tells why the chain stopped (WhyStopped) and the object that was
# judged (Origin). Every counting, comparing and quantifier device answers 0 or the false object
# itself, so a false premise absorbs the rest of the chain. Two devices bring it back to life:
# Otherwise runs an action on the origin and returns it, and OrQ returns the origin so a second
# alternative is tried. A false object has the content 0. A chain that fails without giving a reason
# reads a premise in the chain did not hold. To build one honestly, let a real check fail; SetOrigin
# and SetWhyStopped build one by hand.
#
#   receiver   o1 = Q("AnnIE").AtMost(2).VowelNBQ()
#   example    ? o1.WhyStopped()
#              #--> no: expected atmost 2, found 3
#              ? o1.Content()
#              #--> 0
#              ? o1.IfSo(:Uppercase).Content()
#              #--> 0
#              ? o1.Otherwise(:Lowercase).Content()
#              #--> annie
#   see        stzObject, stzObjectGuard, stzString
class stzFalseObject from stzObject
	@cVarName = :@falseobject
	@oNNLOrigin = 0
	@cNNLWhyStopped = "a premise in the chain did not hold"

	# Returns 0, the value of a failed premise, whatever the chain asked before.
	#
	#   returns    the number 0
	#   note       Value is the same call; the object itself is truthy as an object, so test Content
	#              or StzType, not the object
	#   see        Value, StzType
	def Content()
		return 0

		# Returns 0, the value of a failed premise.
		#
		#   returns    the number 0
		#   see        Content
		def Value()
			return Content()

	# Returns the name that tells a false object from the live object a passing chain hands on.
	#
	#   returns    the text stzFalseObject
	#   note       compare with :stzFalseObject; a passing chain answers the type of the object it
	#              judged
	#   see        Content, WhyStopped
	def StzType()
		return :stzFalseObject

	# Stores the object whose check failed, so that Otherwise and OrQ can hand it back.
	#
	#   poObj      the object that was judged and failed the premise
	#   returns    nothing
	#   note       the failing check records it for you: call it only to build a false object by
	#              hand
	#   see        Origin, Otherwise, OrQ
	#@ aka  -- NNL 2.0 (see doc/design/NNL_REVIEW.md) ----------------------------- The false premise as a DISCOURSE object: it remembers what it judged (origin), it absorbs every counting/comparison device with an honest explanation, and it powers the CONDITIONAL MOOD.
	def SetOrigin(poObj)
		@oNNLOrigin = poObj

	# Returns the object that failed the premise, or 0 for a false object built bare.
	#
	#   returns    the judged object, or the number 0
	#   note       it is the live object itself, not a copy: changing it changes what Otherwise
	#              returns
	#   see        SetOrigin, Otherwise
	def Origin()
		return @oNNLOrigin

	# Records the sentence that tells why the chain stopped.
	#
	#   pcWhy      the reason, as one sentence
	#   returns    nothing
	#   note       the failing check writes it, for example no: expected atmost 2, found 3
	#   see        WhyStopped, SetOrigin
	#@ aka  the CHAIN-STOPPED explanation (the user-facing debug surface, per the WhyChainStopped precedent): recorded at the failing check
	def SetWhyStopped(pcWhy)
		@cNNLWhyStopped = pcWhy

	# Returns the sentence that tells why the chain stopped.
	#
	#   returns    a text
	#   note       when the failing check gave no reason it reads a premise in the chain did not
	#              hold, as after IsAQ(:Number) on a text
	#   see        SetWhyStopped, WhyCheckFailed, Origin
	def WhyStopped()
		return @cNNLWhyStopped

		# Returns the sentence that tells which check failed and what it found.
		#
		#   returns    a text
		#   note       it is the same call as WhyStopped
		#   see        WhyStopped
		def WhyCheckFailed()
			return @cNNLWhyStopped

	# Skips the action, because the premise before it was false, and returns the false object.
	#
	#   pAction    the action that would run on the object if the premise held, and it is not run
	#              here
	#   returns    the false object itself
	#   note       on a live object the pair works the other way round
	#   see        Otherwise, OrQ
	#@ aka  conditional mood on the FALSE branch: IfSo skips, Otherwise recovers
	def IfSo(pAction)
		return This

		def IfSoQ(pAction)
			return This

	# Runs the action on the object that failed the premise and returns that object, so the chain goes on live.
	#
	#   pAction    the action to run on the failed object, for example :Lowercase
	#   returns    the origin object; the false object itself when it has no origin
	#   note       the origin is changed in place:
	#              Q("AnnIE").AtMost(2).VowelNBQ().Otherwise(:Lowercase) leaves annie behind
	#   see        IfSo, Origin, OrQ
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

	# Answers 0 and notes that the premise before was already false.
	#
	#   pcDesc     the past state asked about, as text (not read)
	#   returns    the number 0
	#   note       it also sets the global explanation to no: the premise before was already false
	#   see        WasNever, UsedToBe, IsStill
	def WasEver(pcDesc)
		$cStzLastWhyB = "no: the premise before was already false"
		return 0

	# Answers 0 and notes that the premise before was already false.
	#
	#   pcDesc     the past state asked about, as text (not read)
	#   returns    the number 0
	#   note       the answer is 0 on a false object even though never is vacuously true, because
	#              the whole chain is already false
	#   see        WasEver, UsedToBe
	def WasNever(pcDesc)
		$cStzLastWhyB = "no: the premise before was already false"
		return 0

	# Answers 0 and notes that the premise before was already false.
	#
	#   pcDesc     the past state asked about, as text (not read)
	#   returns    the number 0
	#   see        WasEver, IsStill
	def UsedToBe(pcDesc)
		$cStzLastWhyB = "no: the premise before was already false"
		return 0

	# Answers 0 and notes that the premise before was already false.
	#
	#   pcDesc     the state asked about, as text (not read)
	#   returns    the number 0
	#   see        WasEver, UsedToBe
	def IsStill(pcDesc)
		$cStzLastWhyB = "no: the premise before was already false"
		return 0

	# Answers 0 and notes that the premise before was already false; the constraint is not looked up.
	#
	#   pcName     the name of the constraint to check (not read)
	#   returns    the number 0
	#   see        VerifyConstraints, QualifiesAs
	def VerifyConstraint(pcName)
		$cStzLastWhyB = "no: the premise before was already false"
		return 0

	# Answers 0 and notes that the premise before was already false; no constraint is checked.
	#
	#   returns    the number 0
	#   see        VerifyConstraint
	def VerifyConstraints()
		$cStzLastWhyB = "no: the premise before was already false"
		return 0

	# Does nothing and returns the false object, so the chain goes on.
	#
	#   returns    the false object itself
	#   see        EnforceConstraints, RelaxConstraints
	def ApplyConstraints()
		return This

	# Does nothing and returns the false object; the constraint is not enforced.
	#
	#   pcName     the name of the constraint (not read)
	#   pRule      the rule of the constraint (not read)
	#   returns    the false object itself
	#   see        EnforceConstraints, VerifyConstraint
	def EnforceConstraint(pcName, pRule)
		return This

	# Does nothing and returns the false object; no constraint is enforced.
	#
	#   returns    the false object itself
	#   see        EnforceConstraint, ApplyConstraints
	def EnforceConstraints()
		return This

	# Does nothing and returns the false object; the constraint is not enforced.
	#
	#   pcName     the name of the constraint (not read)
	#   pRule      the rule of the constraint (not read)
	#   pCond      the condition that would keep it enforced (not read)
	#   returns    the false object itself
	#   see        EnforceConstraintUntil, EnforceConstraint
	def EnforceConstraintWhile(pcName, pRule, pCond)
		return This

	# Does nothing and returns the false object; the constraint is not enforced.
	#
	#   pcName     the name of the constraint (not read)
	#   pRule      the rule of the constraint (not read)
	#   pCond      the condition that would end it (not read)
	#   returns    the false object itself
	#   see        EnforceConstraintWhile, EnforceConstraint
	def EnforceConstraintUntil(pcName, pRule, pCond)
		return This

	# Does nothing and returns the false object; no constraint is relaxed.
	#
	#   returns    the false object itself
	#   see        EnforceConstraints, ApplyConstraints
	def RelaxConstraints()
		return This

	# Answers 0 and notes that the premise before was already false.
	#
	#   pcKind     the kind asked about, as text (not read)
	#   returns    the number 0
	#   see        VerifyConstraint, WasEver
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
	# Returns the false object itself, so a chain written with and stays false.
	#
	#   returns    the false object itself
	#   see        OrQ, NorQ
	#-----------------------------------------------------------------------
	#@ aka  -- Fluent boolean short-circuit: every check stays FALSE; AndQ/OrQ keep the -- chain going (so StartsWithXTQ(a).AndQ().EndsWithXT(b) is FALSE when a fails).
	def AndQ()
		return This

	# Returns the object that failed, alive again, so the second alternative gets its chance; the false object itself when it has no origin.
	#
	#   returns    the origin object, or the false object
	#   note       Q("hello").IsAQ(:Number).OrQ().IsAQ(:String) answers a stzString; it is the only
	#              Q-form here that turns the chain live
	#   see        AndQ, Otherwise, Origin
	#@ aka  Q3: on a FALSE premise, OR gives the SECOND disjunct its chance -- the carried origin comes back to life ("is a number OR a string")
	def OrQ()
		if isObject(@oNNLOrigin)
			return @oNNLOrigin
		ok
		return This

	# Returns the false object itself, so a chain written with nor stays false.
	#
	#   returns    the false object itself
	#   see        NeitherQ, OrQ
	#@ aka  under neither...nor a failing predicate is what KEEPS the chain alive -- but once false for another reason, false absorbs
	def NorQ()
		return This

	# Returns the false object itself, so a chain written with both stays false.
	#
	#   returns    the false object itself
	#   see        AndQ
	def BothQ()
		return This

	def IsEitherQ()
		return This

	# Returns the false object itself, so a chain written with neither stays false.
	#
	#   returns    the false object itself
	#   see        NeitherQ, NorQ
	def IsNeitherQ()
		return This

	# Returns the false object itself, so a chain written with neither stays false.
	#
	#   returns    the false object itself
	#   see        IsNeitherQ, NorQ
	def NeitherQ()
		return This

	# Returns the false object itself; a quantifier on a failed chain opens no figure.
	#
	#   returns    the false object itself
	#   see        AnyQ, NoneQ, EachItemQ
	def EachQ()
		return This

	# Returns the false object itself; a quantifier on a failed chain opens no figure.
	#
	#   returns    the false object itself
	#   see        EachQ, NoneQ
	def AnyQ()
		return This

	# Returns the false object itself; a quantifier on a failed chain opens no figure.
	#
	#   returns    the false object itself
	#   see        EachQ, AnyQ
	def NoneQ()
		return This

	# Returns the false object itself; a quantifier on a failed chain opens no figure.
	#
	#   returns    the false object itself
	#   see        EachQ, AnyItemQ
	def EachItemQ()
		return This

	# Returns the false object itself; a quantifier on a failed chain opens no figure.
	#
	#   returns    the false object itself
	#   see        AnyQ, EachItemQ
	def AnyItemQ()
		return This

	# Returns the false object itself; a quantifier on a failed chain opens no figure.
	#
	#   returns    the false object itself
	#   see        NoneQ, EachItemQ
	def NoItemQ()
		return This

	# Returns the false object itself, so a type phrase on a failed chain stays false.
	#
	#   returns    the false object itself
	#   see        AStringQ, AListQ
	def ANumberQ()
		return This

	# Returns the false object itself, so a type phrase on a failed chain stays false.
	#
	#   returns    the false object itself
	#   see        ANumberQ, AListQ
	def AStringQ()
		return This

	# Returns the false object itself, so a type phrase on a failed chain stays false.
	#
	#   returns    the false object itself
	#   see        ANumberQ, AStringQ
	def AListQ()
		return This

	# Returns the false object itself, so a type phrase on a failed chain stays false.
	#
	#   returns    the false object itself
	#   see        ANumberQ, AStringQ
	def AnObjectQ()
		return This

	# Returns the false object itself, so a type phrase on a failed chain stays false.
	#
	#   returns    the false object itself
	#   see        AStringQ, ANumberQ
	def ACharQ()
		return This

	# Answers 0 for any prefix, because the chain before it already failed.
	#
	#   p          the prefix asked about (not read)
	#   returns    the number 0
	#   see        StartsWithAny, EndsWith
	def StartsWith(p)
		return 0

	def StartsWithXT(p)
		return 0

	# Answers 0 for any list of prefixes, because the chain before it already failed.
	#
	#   p          the prefixes asked about (not read)
	#   returns    the number 0
	#   see        StartsWith, EndsWithAny
	def StartsWithAny(p)
		return 0

	def StartsWithXTQ(p)
		return This

	# Answers 0 for any suffix, because the chain before it already failed.
	#
	#   p          the suffix asked about (not read)
	#   returns    the number 0
	#   see        EndsWithAny, StartsWith
	def EndsWith(p)
		return 0

	def EndsWithXT(p)
		return 0

	# Answers 0 for any list of suffixes, because the chain before it already failed.
	#
	#   p          the suffixes asked about (not read)
	#   returns    the number 0
	#   see        EndsWith, StartsWithAny
	def EndsWithAny(p)
		return 0

	def EndsWithXTQ(p)
		return This

	# Answers 0 for any condition, because the chain before it already failed; the condition is not evaluated.
	#
	#   pcCondition   the condition text (not evaluated)
	#   returns       the number 0
	#   note          on the guard a passing type test returns, the same call evaluates the
	#                 condition
	#   see           W
	#@ aka  --
	def Where(pcCondition)
		return 0

		# Answers 0 for any condition, because the chain before it already failed; the condition is not evaluated.
		#
		#   pcCondition   the condition text (not evaluated)
		#   returns       the number 0
		#   see           Where
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

			# Returns the false object itself; no comparison is made, with or without case.
			#
			#   p          the value it would be compared with (not read)
			#   returns    the false object itself
			#   see        IsEqualTo, EqualQ
			def EqualCSQ(p, pCaseSensitive)
				return This

	# Answers 0 for any value, because the chain before it already failed.
	#
	#   p          the value it would be compared with (not read)
	#   returns    the number 0
	#   see        EqualTo, Equals, EqualCSQ
		#>
	#@ aka  -- WITHOUT CASESENSITIVITY
	def IsEqualTo(p)
		return 0

		#< @FunctionFluentForm

		def IsEqualToQ(p)
			return This

		# Answers 0 for any value, because the chain before it already failed.
		#
		#   p          the value it would be compared with (not read)
		#   returns    the number 0
		#   see        IsEqualTo, Equals
		#>
		#< @FunctionAlternativeForms
		def EqualTo(p)
			return 0

			def EqualToQ(p)
				return This

		# Answers 0 for any value, because the chain before it already failed.
		#
		#   p          the value it would be compared with (not read)
		#   returns    the number 0
		#   see        IsEqualTo, EqualTo
		def Equals(p)
			return 0

			# Returns the false object itself; no comparison is made.
			#
			#   p          the value it would be compared with (not read)
			#   returns    the false object itself
			#   see        EqualCSQ, IsEqualTo
			def EqualQ(p)
				return This

	# Answers 0 for any divisor, because the chain before it already failed.
	#
	#   n          the divisor (not read)
	#   returns    the number 0
	#   see        DividableBy, IsDivisibleBy
		#>
	def IsDividableBy(n)
		return 0

		def IsDividableByQ(n)
			return This

		# Answers 0 for any divisor, because the chain before it already failed.
		#
		#   n          the divisor (not read)
		#   returns    the number 0
		#   see        IsDividableBy, DivisibleBy
		def DividableBy(n)
			return 0

			def DividableByQ(n)
				return This

		# Answers 0 for any divisor, because the chain before it already failed.
		#
		#   n          the divisor (not read)
		#   returns    the number 0
		#   see        IsDividableBy, DivisibleBy
		def IsDivisibleBy(n)
			return 0

			def IsDivisibleByQ()
				return This

		# Answers 0 for any divisor, because the chain before it already failed.
		#
		#   n          the divisor (not read)
		#   returns    the number 0
		#   see        IsDivisibleBy, DividableBy
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
