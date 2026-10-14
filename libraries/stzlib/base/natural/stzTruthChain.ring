#---------------------------------------------------------------------------#
#  stzTruthChain -- Floor-2 sugar: the readable boolean narrative,           #
#                   REBUILT THIN on the resolver + descriptor dispatch        #
#                                                                            #
#  The design's option (a) for stzChainOfTruth (NATURAL_VISION 3.2): the     #
#  distinctive boolean-NARRATIVE surface is worth keeping, but its old guts   #
#  were per-step eval() of user strings -- the pattern retired everywhere     #
#  else. This rebuild is eval-free at the step level: every predicate word    #
#  resolves through the ONE lexicon to a DESCRIPTOR, and the whole chain      #
#  folds once through the deterministic @is<X> dispatch (the same path the    #
#  constraints + modality substrate uses). Deterministic, hence CERTAIN in    #
#  the evidential register; accountable -- Why() narrates the verdict.        #
#                                                                            #
#      ? TruthOf("ring").IsA(:Lowercase).AndIsA(:Latin)                       #
#            .AndContaining("g").Holds()          #--> 1                      #
#      ? TruthOf(42).IsA(:Positive).AndIsA(:Even).Holds()   #--> 1            #
#      ? TruthOf("Ring").IsA(:Lowercase).OrIsA(:Uppercase).Holds()  #--> 1    #
#---------------------------------------------------------------------------#

# Open a truth-narrative about a value.
func TruthOf(pValue)
	return new stzTruthChain(pValue)

	func @TruthOf(pValue)
		return new stzTruthChain(pValue)

func TruthChainOf(pValue)
	return new stzTruthChain(pValue)

# --- one atom's verdict against the value: a DESCRIPTOR test (@is<desc>,
#     resolved through the lexicon) or a CONTAINS test. No user-string eval.
func _StzTruthAtomHolds(pValue, pcKind, pArg)
	if pcKind = "is"
		return _StzKindHolds(pValue, pArg)
	ok
	if pcKind = "contains"
		if isString(pValue)
			return len(StzFindCS(pArg, pValue, 1)) > 0
		but isList(pValue)
			return ring_find(pValue, pArg) > 0
		ok
		return 0
	ok
	return 0

# a readable descriptor label for the Why narration
func _StzTruthAtomLabel(pcComb, bNot, pcKind, pArg)
	_cC_ = ""
	if pcComb = "and" _cC_ = "and " ok
	if pcComb = "or" _cC_ = "or " ok
	_cN_ = ""
	if bNot = 1 _cN_ = "not " ok
	if pcKind = "is"
		return _cC_ + "is " + _cN_ + StzLower("" + pArg)
	ok
	return _cC_ + _cN_ + "containing " + @@(pArg)


# Tells a boolean narrative about a value, claim by claim, and folds it once into a certain yes or no with its reason.
#
# TruthOf(value) opens the chain; IsA, AndIsA and OrIsA add claims about its kind, and Containing
# and its And and Or forms add claims about what it holds. Holds folds the claims from left to
# right, so a and b or c reads as (a and b) or c, with no evaluated user text: each kind is a
# descriptor resolved to an @is predicate. Why() narrates the verdict. Start the chain with exactly
# one IsA, IsNotA or Containing.
#
#   receiver   o1 = TruthOf("ring")
#   example    o1.IsA(:Lowercase).AndIsA(:Latin).AndContaining("g")
#              ? o1.Holds()
#              #--> 1
#              ? o1.Why()
#              #--> yes: "ring" is lowercase and is latin and containing "g"
#              ? TruthOf("Ring").IsA(:Lowercase).OrIsA(:Uppercase).Holds()
#              #--> 0
#   see        TruthOf, stzCan, stzQuestion
class stzTruthChain from stzObject

	@pValue
	@aAtoms = []       # [ combinator, negate, kind, arg ]  (first combinator = seed)
	@cWhy = ""

	# Opens a truth narrative about a value, with no atom yet.
	#
	#   pValue     the value the narrative is about, a text, a number or a list
	#   returns    nothing; the object is built
	#   see        IsA, Holds
	def init(pValue)
		@pValue = pValue

	# Starts the narrative with the claim that the value is of a kind, named by a descriptor such as Lowercase, Latin or Positive.
	#
	#   pDesc      the descriptor, matched to a predicate named @is followed by it
	#   returns    the chain itself, so calls chain
	#   note       IsAn is the same call
	#   warning    an unknown descriptor raises Unknown constraint descriptor when Holds runs, not
	#              here; a second IsA does not extend the narrative but starts it again, so only the
	#              last starter and what follows decide, while Why still lists both
	#   see        AndIsA, OrIsA, Holds
	# --- descriptor atoms ------------------------------------------------
	def IsA(pDesc)
		return This._Add("seed", 0, "is", pDesc)
	def IsAn(pDesc)
		return This.IsA(pDesc)
	# Starts the narrative with the claim that the value is not of a kind.
	#
	#   pDesc      the descriptor that must fail
	#   returns    the chain itself, so calls chain
	#   see        IsA, AndIsNotA, Holds
	def IsNotA(pDesc)
		return This._Add("seed", 1, "is", pDesc)

	# Adds a claim that must hold too: the verdict so far and this kind.
	#
	#   pDesc      the descriptor that must also hold
	#   returns    the chain itself, so calls chain
	#   note       the chain is folded from left to right, so a and b or c reads as (a and b) or c;
	#              AndIsAn is the same call
	#   see        IsA, OrIsA
	def AndIsA(pDesc)
		return This._Add("and", 0, "is", pDesc)
	def AndIsAn(pDesc)
		return This.AndIsA(pDesc)
	# Adds a claim that must hold too: the verdict so far and not this kind.
	#
	#   pDesc      the descriptor that must also fail
	#   returns    the chain itself, so calls chain
	#   see        AndIsA, OrIsNotA
	def AndIsNotA(pDesc)
		return This._Add("and", 1, "is", pDesc)

	# Adds an alternative: the verdict so far or this kind.
	#
	#   pDesc      the descriptor that may hold instead
	#   returns    the chain itself, so calls chain
	#   note       OrIsAn is the same call
	#   see        OrIsNotA, AndIsA
	def OrIsA(pDesc)
		return This._Add("or", 0, "is", pDesc)
	def OrIsAn(pDesc)
		return This.OrIsA(pDesc)
	# Adds an alternative: the verdict so far or not this kind.
	#
	#   pDesc      the descriptor that may fail instead
	#   returns    the chain itself, so calls chain
	#   see        OrIsA, AndIsNotA
	def OrIsNotA(pDesc)
		return This._Add("or", 1, "is", pDesc)

	# Starts the narrative with the claim that the text contains a part, or that the list contains an item.
	#
	#   pArg       the part of the text or the item of the list to look for
	#   returns    the chain itself, so calls chain
	#   note       the same starting rule as IsA
	#   warning    the search is case-sensitive; a number as the value never contains anything
	#   see        AndContaining, OrContaining, Holds
	# --- contains atoms --------------------------------------------------
	def Containing(pArg)
		return This._Add("seed", 0, "contains", pArg)
	# Adds a claim that must hold too: the verdict so far and the value contains the part.
	#
	#   pArg       the part or item that must be present
	#   returns    the chain itself, so calls chain
	#   see        Containing, AndNotContaining
	def AndContaining(pArg)
		return This._Add("and", 0, "contains", pArg)
	# Adds an alternative: the verdict so far or the value contains the part.
	#
	#   pArg       the part or item that may be present instead
	#   returns    the chain itself, so calls chain
	#   see        Containing, OrNotContaining
	def OrContaining(pArg)
		return This._Add("or", 0, "contains", pArg)
	# Adds a claim that must hold too: the verdict so far and the value lacks the part.
	#
	#   pArg       the part or item that must be absent
	#   returns    the chain itself, so calls chain
	#   see        AndContaining, OrNotContaining
	def AndNotContaining(pArg)
		return This._Add("and", 1, "contains", pArg)
	# Adds an alternative: the verdict so far or the value lacks the part.
	#
	#   pArg       the part or item that may be absent instead
	#   returns    the chain itself, so calls chain
	#   see        OrContaining, AndNotContaining
	def OrNotContaining(pArg)
		return This._Add("or", 1, "contains", pArg)

	def _Add(pcComb, bNot, pcKind, pArg)
		_cComb_ = pcComb
		if len(@aAtoms) = 0 _cComb_ = "seed" ok
		@aAtoms + [ _cComb_, bNot, pcKind, pArg ]
		return This

	# Folds the claims once from left to right and returns the verdict; the reason is kept for Why and the verdict is certain.
	#
	#   returns    1 or 0, numbers; 0 with no claim at all
	#   note       IsTrue and Verdict are the same call
	#   warning    raises when a descriptor names no predicate
	#   see        Why, IsA
	# --- closers ---------------------------------------------------------
	#@ aka  Fold the atoms LEFT-TO-RIGHT (the natural reading of a boolean narrative: "a and b or c" = ((a and b) or c)). One pass, no eval of user code -- each atom is a lexicon-resolved descriptor / contains test. Records Why + marks the verdict CERTAIN (deterministic).
	def Holds()
		$nStzLastCertainty = 1
		_n_ = len(@aAtoms)
		if _n_ = 0
			@cWhy = "no atoms: nothing to decide"
			$cStzLastWhyB = @cWhy
			return 0
		ok
		_bAcc_ = 0
		_cNarr_ = ""
		for _i_ = 1 to _n_
			_cComb_ = @aAtoms[_i_][1]
			_bNot_ = @aAtoms[_i_][2]
			_bA_ = _StzTruthAtomHolds(@pValue, @aAtoms[_i_][3], @aAtoms[_i_][4])
			if _bNot_ = 1
				if _bA_ = 1 _bA_ = 0 else _bA_ = 1 ok
			ok
			if _cComb_ = "seed"
				_bAcc_ = _bA_
			but _cComb_ = "and"
				_bAcc_ = (_bAcc_ = 1 and _bA_ = 1)
			but _cComb_ = "or"
				_bAcc_ = (_bAcc_ = 1 or _bA_ = 1)
			ok
			if _cNarr_ != "" _cNarr_ += " " ok
			_cNarr_ += _StzTruthAtomLabel(_cComb_, _bNot_, @aAtoms[_i_][3], @aAtoms[_i_][4])
		next
		if _bAcc_ = 1
			@cWhy = "yes: " + @@(@pValue) + " " + _cNarr_
		else
			@cWhy = "no: " + @@(@pValue) + " is not (" + _cNarr_ + ")"
		ok
		$cStzLastWhyB = @cWhy
		return _bAcc_

		def IsTrue()
			return This.Holds()

		def Verdict()
			return This.Holds()

	# Returns the narrated verdict, deciding it first if Holds has not run.
	#
	#   returns    a text such as yes: "ring" is lowercase and is latin
	#   see        Holds
	def Why()
		if @cWhy = "" This.Holds() ok
		return @cWhy

	# Returns how many claims the narrative holds.
	#
	#   returns    a number
	#   see        Content
	def NumberOfAtoms()
		return len(@aAtoms)

	# Returns the claims, each as [ combinator, negated, kind, argument ], the first being the seed.
	#
	#   returns    a list of four-item lists
	#   see        NumberOfAtoms, Holds
	def Content()
		return @aAtoms
