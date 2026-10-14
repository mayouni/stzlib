#---------------------------------------------------------------------------#
#  stzConstraints -- the MODALITY frontier on a constraints substrate        #
#                                                                            #
#  DEONTIC MODALITY made computational: what a value CAN be and what a       #
#  kind MUST be, decided by declared CONSTRAINTS -- deterministic,           #
#  descriptor-based (the same @is<X> dispatch as IsAXT), accountable.        #
#                                                                            #
#      ConstrainQ("score").ToBeQ(:Number).AndQ().ToBeQ(:Positive)            #
#      ? CanQ(42).BeA("score")        #--> 1                                 #
#      ? CanQ(-5).BeA("score")        #--> 0 ; Why() names the constraint    #
#      ? MustQ("score").BeA(:Number)  #--> 1  (entailment)                   #
#      ? Q(42).QualifiesAsQ("score")  #--> live chain (or a false premise    #
#                                          that knows WhyStopped)            #
#                                                                            #
#  The historical seed is honored: common/stzConstraint.ring (the            #
#  author's per-object EnforceConstraint design) remains the OBJECT-level    #
#  guard; this file adds the KIND-level registry the modal verbs need.      #
#  Can/Must are QUESTIONS: their verdicts join the session ask-record.       #
#---------------------------------------------------------------------------#

$aStzKindConstraints = []   # entries: [ kind-name, descriptor ]

func ConstrainQ(pcKind)
	return new stzKindConstraint(pcKind)

func ConstraintsOn(pcKind)
	_cK_ = StzLower(trim(pcKind))
	_aOut_ = []
	_n_ = len($aStzKindConstraints)
	for _i_ = 1 to _n_
		if $aStzKindConstraints[_i_][1] = _cK_
			_aOut_ + $aStzKindConstraints[_i_][2]
		ok
	next
	return _aOut_

func DropConstraints(pcKind)
	_cK_ = StzLower(trim(pcKind))
	_aKeep_ = []
	_n_ = len($aStzKindConstraints)
	for _i_ = 1 to _n_
		if $aStzKindConstraints[_i_][1] != _cK_
			_aKeep_ + $aStzKindConstraints[_i_]
		ok
	next
	$aStzKindConstraints = _aKeep_

# the modal QUESTION openers (sentence-initial inversion, like IsQ)

func CanQ(pValue)
	return new stzCan(pValue)

func MustQ(pcKind)
	return new stzMust(pcKind)

# does a value satisfy one descriptor? (the IsAXT dispatch, typed)
func _StzKindHolds(pValue, pcDesc)
	_vKh_ = pValue
	_bKh_ = 0
	try
		eval("_bKh_ = @is" + pcDesc + "(_vKh_)")
	catch
		StzRaise("Unknown constraint descriptor :" + pcDesc +
			" -- no @is" + pcDesc + "() predicate exists.")
	done
	return _bKh_

# a small predicate the constraint vocabulary naturally needs
func IsPositive(n)
	return isNumber(n) and n > 0

	func @IsPositive(n)
		return IsPositive(n)

# --- the declaration: "Constrain score to be a number and to be even" ---

# Declares what a kind of value must be, as a list of constraints kept for the whole process.
#
# ConstrainQ("score").ToBeQ(:Number).AndQ().ToBeQ(:Positive) declares that a score is a number and
# positive. A descriptor names a predicate: Number is checked by @isnumber, Positive by @ispositive.
# The declarations are read by stzCan, for possibility, and stzMust, for necessity. ConstraintsOn
# lists a kind's descriptors and DropConstraints forgets them.
#
#   receiver   o1 = ConstrainQ("scoreA")
#   example    o1.ToBeQ(:Number).AndQ().ToBeQ(:Positive)
#              ? ConstraintsOn("scoreA")[2]
#              #--> positive
#              ? o1.Kind()
#              #--> scorea
#   see        stzCan, stzMust, ConstraintsOn
class stzKindConstraint

	@cKind = ""

	# Starts the declaration of constraints for a kind of value, such as score; the kind is trimmed and lowercased.
	#
	#   pcKind     the name of the kind to constrain
	#   returns    nothing; the object is built
	#   see        ToBeQ, Kind
	def init(pcKind)
		@cKind = StzLower(trim(pcKind))

	# Declares that values of the kind must satisfy a descriptor, such as Number or Positive; declaring the same descriptor twice keeps one.
	#
	#   pcDesc     the descriptor, matched to a predicate named @is followed by it
	#   returns    the declaration itself, so calls chain
	#   note       the constraints of a kind are global to the process, read in the order declared
	#   warning    an unknown descriptor is not refused here: it raises Unknown constraint
	#              descriptor later, when a value is checked against it
	#   see        AndQ, Kind, stzCan
	def ToBeQ(pcDesc)
		_cD_ = StzLower(trim("" + pcDesc))
		_n_ = len($aStzKindConstraints)
		for _i_ = 1 to _n_
			if $aStzKindConstraints[_i_][1] = @cKind and
			   $aStzKindConstraints[_i_][2] = _cD_
				return This
			ok
		next
		$aStzKindConstraints + [ @cKind, _cD_ ]
		return This

	# Returns the declaration itself, so that ToBeQ can be chained after it for readability.
	#
	#   returns    the declaration itself
	#   see        ToBeQ
	def AndQ()
		return This

	# Returns the kind this declaration constrains, trimmed and in lower case.
	#
	#   returns    a text such as score
	#   see        ToBeQ
	def Kind()
		return @cKind

# --- "Can 42 be a score?" -- possibility against the constraints ---

# Answers whether a value can be a given kind, by checking it against every constraint declared for the kind.
#
# CanQ(42).BeA("score") is 1 when 42 satisfies all the constraints of score. The verdict is certain,
# since a check is deterministic, it joins the session's ask-record, and Why() says which constraint
# failed. A kind with no declared constraint answers 0 and says nothing is known about it.
#
#   receiver   ConstrainQ("scoreB").ToBeQ(:Number).ToBeQ(:Positive) o1 = CanQ(42)
#   example    ? o1.BeA("scoreB")
#              #--> 1
#              ? CanQ(-5).BeA("scoreB")
#              #--> 0
#              ? Why()
#              #--> no: -5 is not positive (constraint 2 of 'scoreb')
#   see        stzMust, stzKindConstraint, Why
class stzCan

	@pValue = ""

	# Starts the question whether a value can be a given kind, keeping the value to check.
	#
	#   pValue     the value to check against the constraints of a kind
	#   returns    nothing; the object is built
	#   see        BeA
	def init(pValue)
		@pValue = pValue

	# TRUE if the value satisfies every constraint declared for the kind; the reason is left for Why and the verdict joins the ask-record.
	#
	#   pcKind     the kind, such as score, matched without regard to case
	#   returns    1 or 0, numbers; 0 when the kind has no constraint
	#   note       BeAn and Be are the same call; the certainty is always 1, the check being
	#              deterministic
	#   warning    an unknown descriptor among the constraints raises Unknown constraint descriptor
	#   see        stzMust, stzKindConstraint
	def BeA(pcKind)
		# EVIDENTIALITY: constraint checks are deterministic -- CERTAIN
		$nStzLastCertainty = 1
		_cK_ = StzLower(trim(pcKind))
		_aC_ = ConstraintsOn(_cK_)
		_nC_ = len(_aC_)
		if _nC_ = 0
			$cStzLastWhyB = "no: nothing is known about being a '" + _cK_ +
				"' (no constraints were declared)"
			$aStzAskAnswers + 0
			return 0
		ok
		for _i_ = 1 to _nC_
			if NOT _StzKindHolds(@pValue, _aC_[_i_])
				$cStzLastWhyB = "no: " + @@(@pValue) + " is not " +
					_aC_[_i_] + " (constraint " + _i_ + " of '" + _cK_ + "')"
				$aStzAskAnswers + 0
				return 0
			ok
		next
		$cStzLastWhyB = "yes: " + @@(@pValue) + " satisfies all " + _nC_ +
			" constraints of '" + _cK_ + "'"
		$aStzAskAnswers + 1
		return 1

		def BeAn(pcKind)
			return This.BeA(pcKind)

		def Be(pcKind)
			return This.BeA(pcKind)

# --- "Must a score be a number?" -- necessity is ENTAILMENT ---

# Answers whether a kind must be something, by looking the descriptor up among the constraints declared for the kind.
#
# MustQ("score").BeA(:Number) is 1 when being a number is one of the declared constraints of score:
# necessity is entailment, and no value is involved. A kind with no declared constraint answers 0.
# Why() gives the reason and the verdict joins the ask-record.
#
#   receiver   ConstrainQ("scoreC").ToBeQ(:Number) o1 = MustQ("scoreC")
#   example    ? o1.BeA(:Number)
#              #--> 1
#              ? o1.BeA(:Even)
#              #--> 0
#   see        stzCan, stzKindConstraint, Why
class stzMust

	@cKind = ""

	# Starts the question whether a kind must be something, keeping the kind.
	#
	#   pcKind     the kind, trimmed and lowercased
	#   returns    nothing; the object is built
	#   see        BeA
	def init(pcKind)
		@cKind = StzLower(trim(pcKind))

	# TRUE if the descriptor is among the constraints declared for the kind, which is what necessity means here; the reason is left for Why.
	#
	#   pcDesc     the descriptor, such as Number, matched without regard to case
	#   returns    1 or 0, numbers; 0 when the kind has no constraint
	#   note       BeAn and Be are the same call; no value is checked, only the declared list
	#   see        stzCan, stzKindConstraint
	def BeA(pcDesc)
		$nStzLastCertainty = 1
		_cD_ = StzLower(trim("" + pcDesc))
		_aC_ = ConstraintsOn(@cKind)
		_nC_ = len(_aC_)
		if _nC_ = 0
			$cStzLastWhyB = "no: nothing is known about being a '" +
				@cKind + "' (no constraints were declared)"
			$aStzAskAnswers + 0
			return 0
		ok
		if ring_find(_aC_, _cD_) > 0
			$cStzLastWhyB = "yes: a '" + @cKind + "' must be " + _cD_ +
				" (declared constraint)"
			$aStzAskAnswers + 1
			return 1
		ok
		$cStzLastWhyB = "no: nothing constrains a '" + @cKind +
			"' to be " + _cD_
		$aStzAskAnswers + 0
		return 0

		def BeAn(pcDesc)
			return This.BeA(pcDesc)

		def Be(pcDesc)
			return This.BeA(pcDesc)
