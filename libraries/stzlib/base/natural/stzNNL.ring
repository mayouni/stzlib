#---------------------------------------------------------------------------#
#  stzNNL -- Near-Natural Language 2.0: the renovated device layer           #
#                                                                            #
#  See doc/design/NNL_REVIEW.md. This file holds the GLOBAL side of the      #
#  NNL devices: the expectation register (the anaphoric-ellipsis context     #
#  generalized with COMPARATIVE MODES) and the accountability register       #
#  (WhyB -- every B-comparison explains itself). The chainable devices       #
#  live on stzObject (marked NNL sections at the end of stzObject.ring);     #
#  the noun surface (VowelN/VowelNB/...) is GENERATED there from the         #
#  semantic lexicon.                                                         #
#---------------------------------------------------------------------------#

# THE EXPECTATION REGISTER -- the discourse context of NNL:
#   "has a length of 4 ... and ONLY 1 vowel"       -> :Exactly
#   "with AT LEAST 2 vowels"                       -> :AtLeast
#   "containing ABOUT 100 items"                   -> :About (vagueness!)
#   "with BETWEEN 3 and 5 words"                   -> :Between
# SetLastValue() (stzNaturalCode) stores WHAT is expected; the mode says
# HOW to compare. Every *NB()/*B() device compares through the register
# and records its explanation in $cStzLastWhyB.

$cStzExpectMode = :Exactly
$nStzExpectTol = 0
$cStzLastWhyB = ""
$nStzLastCertainty = 1   # EVIDENTIALITY: how confidently the last verdict is known
$aStzAskAnswers = []   # Q4: the session ask-record (see the funcs below)

func ExpectExactly(n)
	SetLastValue(n)
	$cStzExpectMode = :Exactly

func ExpectAtLeast(n)
	SetLastValue(n)
	$cStzExpectMode = :AtLeast

func ExpectAtMost(n)
	SetLastValue(n)
	$cStzExpectMode = :AtMost

func ExpectMoreThan(n)
	SetLastValue(n)
	$cStzExpectMode = :MoreThan

func ExpectLessThan(n)
	SetLastValue(n)
	$cStzExpectMode = :LessThan

func ExpectAbout(n)
	ExpectAboutXT(n, 0.1)

func ExpectAboutXT(n, nTolerance)
	SetLastValue(n)
	$cStzExpectMode = :About
	$nStzExpectTol = nTolerance

func ExpectBetween(n1, n2)
	SetLastValue([ n1, n2 ])
	$cStzExpectMode = :Between

# THE ACCOUNTABILITY SURFACE -- two scopes, two names (the archived
# WhyChainStopped precedent: explanations live ON the chain):
#
#   CHAIN-LOCAL (the real device): o.WhyAnswered() -- the reason of the
#   last check THIS object answered; oFalse.WhyStopped() -- why the chain
#   stopped at a false premise. Two interleaved chains never lie to each
#   other. A live object answers WhyStopped() with "the chain is not
#   stopped", exactly like the archive.
#
#   DETACHED (console/test convenience): Why() -- the last check anywhere
#   in the session, read from the process register. Handy right after a
#   `? o.SomethingNB()` line; NOT reliable across interleaved chains --
#   use the chain-local forms in real code.
# NAMING: never WhyB -- the B suffix is RESERVED by the NNL grammar for
# boolean-returning devices; Why* is the explanation family.

# THE EVIDENTIAL REGISTER -- natural language marks not only WHAT is
# true but HOW CONFIDENTLY the speaker knows it. Deterministic checks
# are CERTAIN (1); the semantic verdicts (similarity, zero-shot
# classification, sentiment) carry their graded score. The evidential
# ADVERB verbalizes the bands: certainly / probably / apparently.

func Certainty()
	return $nStzLastCertainty

	func @Certainty()
		return $nStzLastCertainty

func Evidentially()
	return StzEvidentialAdverb($nStzLastCertainty)

	func HowCertain()
		return StzEvidentialAdverb($nStzLastCertainty)

func StzEvidentialAdverb(nConf)
	if NOT isNumber(nConf)
		return "apparently"
	ok
	if nConf >= 0.85
		return "certainly"
	ok
	if nConf >= 0.60
		return "probably"
	ok
	return "apparently"

# verbalize a graded verdict: "certainly yes" / "apparently not"
func StzEvidentialVerdict(bYes, nConf)
	_cEv_ = StzEvidentialAdverb(nConf)
	if bYes = 1
		return _cEv_ + " yes"
	ok
	return _cEv_ + " not"

func Why()
	return $cStzLastWhyB

	func @Why()
		return $cStzLastWhyB

# THE SESSION ASK-RECORD (Q4 convergence) -- every question FRAME records
# its answer here, so a run of questions folds exactly like a narration's
# interrogative record: several IsQ() gates, then one verdict.

func AnswersSoFar()
	return $aStzAskAnswers

func AllYesSoFar()
	_n_ = len($aStzAskAnswers)
	if _n_ = 0
		return FALSE
	ok
	for _i_ = 1 to _n_
		_v_ = $aStzAskAnswers[_i_]
		if isNumber(_v_) and _v_ = 0
			return FALSE
		ok
	next
	return TRUE

func AnyYesSoFar()
	_n_ = len($aStzAskAnswers)
	for _i_ = 1 to _n_
		_v_ = $aStzAskAnswers[_i_]
		if NOT ( isNumber(_v_) and _v_ = 0 )
			return TRUE
		ok
	next
	return FALSE

func ClearAnswers()
	$aStzAskAnswers = []
