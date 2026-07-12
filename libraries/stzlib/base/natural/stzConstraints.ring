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

class stzKindConstraint

	@cKind = ""

	def init(pcKind)
		@cKind = StzLower(trim(pcKind))

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

	def AndQ()
		return This

	def Kind()
		return @cKind

# --- "Can 42 be a score?" -- possibility against the constraints ---

class stzCan

	@pValue = ""

	def init(pValue)
		@pValue = pValue

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

class stzMust

	@cKind = ""

	def init(pcKind)
		@cKind = StzLower(trim(pcKind))

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
