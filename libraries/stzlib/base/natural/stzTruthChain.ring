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


class stzTruthChain from stzObject

	@pValue
	@aAtoms = []       # [ combinator, negate, kind, arg ]  (first combinator = seed)
	@cWhy = ""

	def init(pValue)
		@pValue = pValue

	# --- descriptor atoms ------------------------------------------------
	def IsA(pDesc)
		return This._Add("seed", 0, "is", pDesc)
	def IsAn(pDesc)
		return This.IsA(pDesc)
	def IsNotA(pDesc)
		return This._Add("seed", 1, "is", pDesc)

	def AndIsA(pDesc)
		return This._Add("and", 0, "is", pDesc)
	def AndIsAn(pDesc)
		return This.AndIsA(pDesc)
	def AndIsNotA(pDesc)
		return This._Add("and", 1, "is", pDesc)

	def OrIsA(pDesc)
		return This._Add("or", 0, "is", pDesc)
	def OrIsAn(pDesc)
		return This.OrIsA(pDesc)
	def OrIsNotA(pDesc)
		return This._Add("or", 1, "is", pDesc)

	# --- contains atoms --------------------------------------------------
	def Containing(pArg)
		return This._Add("seed", 0, "contains", pArg)
	def AndContaining(pArg)
		return This._Add("and", 0, "contains", pArg)
	def OrContaining(pArg)
		return This._Add("or", 0, "contains", pArg)
	def AndNotContaining(pArg)
		return This._Add("and", 1, "contains", pArg)
	def OrNotContaining(pArg)
		return This._Add("or", 1, "contains", pArg)

	def _Add(pcComb, bNot, pcKind, pArg)
		_cComb_ = pcComb
		if len(@aAtoms) = 0 _cComb_ = "seed" ok
		@aAtoms + [ _cComb_, bNot, pcKind, pArg ]
		return This

	# --- closers ---------------------------------------------------------
	# Fold the atoms LEFT-TO-RIGHT (the natural reading of a boolean
	# narrative: "a and b or c" = ((a and b) or c)). One pass, no eval of
	# user code -- each atom is a lexicon-resolved descriptor / contains
	# test. Records Why + marks the verdict CERTAIN (deterministic).
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

	def Why()
		if @cWhy = "" This.Holds() ok
		return @cWhy

	def NumberOfAtoms()
		return len(@aAtoms)

	def Content()
		return @aAtoms
