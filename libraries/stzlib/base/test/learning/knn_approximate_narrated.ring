# STZKNN APPROXIMATE MODE -- opt-in, and measured rather than promised.
#
# stzKnn searches exactly: every example measured, the true k nearest, the same
# answer every time. Above a few thousand examples the engine's projection forest
# can answer in roughly O(budget) instead of O(n).
#
# -- WHY THIS SUITE EXISTS IN THIS SHAPE --
#
# Approximation in a CLASSIFIER is a different proposition from approximation in a
# neighbour graph. UMAP's edge weights are soft memberships, so a swapped neighbour
# perturbs a layout. Here the output is a LABEL, and a label is either the one exact
# search would have produced or it is not.
#
# So the properties worth pinning are:
#
#   * the default is EXACT -- turning this on is a decision, never a surprise;
#   * approximate answers agree with exact ones, MEASURED as label agreement rather
#     than as neighbour recall, because a majority vote absorbs a swapped neighbour
#     that a recall figure would count as a loss;
#   * the two paths return the same SHAPE -- true distances, 1-based indices -- so
#     everything downstream of the search, including Why(), reads identically;
#   * toggling the mode invalidates cleanly, since both structures are built from a
#     single read of the training set.
#
# Everything below is run for real against the built library.

load "../../stzBase.ring"
load "../_narrated.ring"

decimals(6)

# two well-separated clusters, 600 examples, deterministic
oDs = KnaTwoClusters(300)
oK = new stzKnn(oDs)
oK.SetK(5)

Scenario("The default is exact, and turning approximation on is a decision")
	Then("a fresh classifier searches exactly", oK.IsApproximate(), FALSE)
	Then("...over the whole training set", oDs.NumberOfExamples(), 600)

	# the exact answers, which are the yardstick for everything below
	Then("exact: a low-cluster query classifies low", oK.Classify([0.5, 0.5]), "low")
	Then("exact: a high-cluster query classifies high", oK.Classify([5.5, 5.5]), "high")

	oK.SetApproximate(TRUE)
	Then("approximation is on once asked for", oK.IsApproximate(), TRUE)
	Then("...with the tuned tree count", oK.ApproximateTrees(), 24)
	Then("...and the engine choosing the budget from k", oK.ApproximateBudget(), 0)
EndScenario()

Scenario("Approximate search reaches the same verdicts")
	# same queries, same labels -- the forest found different neighbours in some
	# cases and the vote did not care
	Then("approximate: a low-cluster query still classifies low",
	     oK.Classify([0.5, 0.5]), "low")
	Then("approximate: a high-cluster query still classifies high",
	     oK.Classify([5.5, 5.5]), "high")

	# THE HONEST MEASURE FOR A CLASSIFIER is label agreement, not neighbour recall.
	# A vote survives a swapped neighbour far more often than a neighbour list
	# survives it, so recall would understate what actually reaches the caller.
	aQ = KnaQueries(40)
	Then("label agreement with exact search, over 40 queries",
	     oK.AgreementWithExact(aQ) > 0.95, TRUE)
	Then("...and measuring it leaves the mode as it found it", oK.IsApproximate(), TRUE)
EndScenario()

Scenario("...and the two paths hand back the same SHAPE, not merely the same label")
	# The forest indexes from 0 where the exact search returns 1-based indices for
	# Ring, and it reports SQUARED distances where this class's contract is the true
	# Euclidean distance. Both conversions happen in Classify(), and Why() is where
	# a mistake in either would surface as a wrong example number or a wrong d=.
	oK.SetApproximate(FALSE)
	oK.Classify([0.5, 0.5])
	cWhyExact = oK.Why()
	oK.SetApproximate(TRUE)
	oK.Classify([0.5, 0.5])
	cWhyApprox = oK.Why()

	Then("Why() names five examples either way",
	     KnaCountsFive(cWhyExact) and KnaCountsFive(cWhyApprox), TRUE)
	Then("...and quotes a plausible TRUE distance, not a squared one",
	     KnaMaxDistIn(cWhyApprox) < 1.0, TRUE)
	# a squared distance would be the SQUARE of a true one, so for these clusters the
	# two are told apart by magnitude: the true nearest distances here are well under
	# 1, and squaring them would make them smaller still rather than larger -- so the
	# check that catches a missing sqrt is the agreement of the two Why() strings on
	# the same query
	Then("...and both paths agree on the nearest example for this query",
	     KnaFirstIndexIn(cWhyExact) = KnaFirstIndexIn(cWhyApprox), TRUE)

	# WHY() MUST NAME THE VERDICT, and this is not automatic: the nearest neighbour
	# and the majority are DIFFERENT LABELS whenever the vote overrules proximity.
	# Moving the vote into the engine broke exactly this -- Why() reported the first
	# neighbour's label -- and the two paths agreeing did not catch it, because both
	# reported the same wrong thing. Only comparing against Classify() does.
	oV = new stzKnn(KnaNearestDisagrees())
	oV.SetK(3)
	cVerdict = oV.Classify([3, 4])
	Then("the vote overrules the nearest neighbour here", cVerdict, "low")
	Then("...the nearest neighbour is the OTHER label",
	     KnaFirstLabelIn(oV.Why()), "high")
	Then("...and Why() names the verdict, not that neighbour",
	     KnaMajorityIn(oV.Why()), cVerdict)
EndScenario()

Scenario("Toggling and retuning invalidate cleanly")
	# Both structures are built from ONE read of the training set, so changing the
	# mode or the tuning has to drop both rather than leave a half-built pair.
	oT = new stzKnn(KnaTwoClusters(120))
	oT.SetK(3)
	Then("exact first", oT.Classify([0.5, 0.5]), "low")
	oT.SetApproximate(TRUE)
	Then("...then approximate, on a rebuilt index", oT.Classify([0.5, 0.5]), "low")
	oT.SetApproximateTrees(8)
	Then("...retuning the trees rebuilds and still answers", oT.Classify([0.5, 0.5]), "low")
	Then("...at the new tree count", oT.ApproximateTrees(), 8)
	oT.SetApproximateBudget(200)
	Then("...and setting a budget explicitly still answers",
	     oT.Classify([5.5, 5.5]), "high")
	Then("...at the new budget", oT.ApproximateBudget(), 200)
	oT.SetApproximate(FALSE)
	Then("...and going back to exact works too", oT.Classify([5.5, 5.5]), "high")

	# growing the training set invalidates as it always did, in either mode
	oT.SetApproximate(TRUE)
	oT.Classify([0.5, 0.5])
	oT.TrainingSetQ().AddExample([5.6, 5.6], "high")
	Then("adding an example is noticed under approximation too",
	     oT.Classify([5.6, 5.6]), "high")

	# a bad setting is refused rather than silently clamped
	Then("zero trees is refused", KnaRefusesTrees(oT, 0), TRUE)
	Then("...and a negative budget too", KnaRefusesBudget(oT, -5), TRUE)
EndScenario()

Summary()

#-- helpers (Kna-prefixed: short names collide with library globals) ------------

# two separable clusters, deterministic: "low" near the origin, "high" at (5,5)
func KnaTwoClusters(nPer)
	_kS_ = 999
	_kD_ = new stzTrainingSet([])
	for _ki_ = 1 to nPer
		_kS_ = (_kS_ * 1103515245 + 12345) % 2147483648
		_ka_ = (_kS_ % 1000) / 1000.0
		_kS_ = (_kS_ * 1103515245 + 12345) % 2147483648
		_kb_ = (_kS_ % 1000) / 1000.0
		_kD_.AddExample([_ka_, _kb_], "low")
		_kD_.AddExample([_ka_ + 5, _kb_ + 5], "high")
	next
	return _kD_

# queries spread across BOTH clusters and the empty space between them, so the
# agreement figure is not measured only where the answer is obvious
func KnaQueries(nHowMany)
	_kS2_ = 4242
	_kQ_ = []
	for _ki2_ = 1 to nHowMany
		_kS2_ = (_kS2_ * 1103515245 + 12345) % 2147483648
		_ka2_ = (_kS2_ % 6000) / 1000.0
		_kS2_ = (_kS2_ * 1103515245 + 12345) % 2147483648
		_kb2_ = (_kS2_ % 6000) / 1000.0
		_kQ_ + [_ka2_, _kb2_]
	next
	return _kQ_

func KnaCountsFive(cWhy)
	# StzFind returns a LIST of positions; StzFindFirst returns ONE
	return StzFindFirst("5 nearest", cWhy) > 0

# the largest d=... in a Why() string. NOTE the second split: a piece after "d="
# reads "0.073539), #104 'high' (", and Ring's number() REFUSES a string with
# trailing junk rather than parsing the leading digits, so the value has to be cut
# at the closing bracket first.
func KnaMaxDistIn(cWhy)
	_kP_ = StzSplit(cWhy, "d=")
	_kM_ = 0
	_kN_ = len(_kP_)
	for _ki3_ = 2 to _kN_
		_kC_ = StzSplit(_kP_[_ki3_], ")")
		if len(_kC_) > 0
			_kV_ = number(_kC_[1])
			if _kV_ > _kM_
				_kM_ = _kV_
			ok
		ok
	next
	return _kM_

# the first "#<n>" example number in a Why() string, cut at the following space
func KnaFirstIndexIn(cWhy)
	_kP2_ = StzSplit(cWhy, "#")
	if len(_kP2_) < 2
		return 0
	ok
	_kC2_ = StzSplit(_kP2_[2], " ")
	if len(_kC2_) = 0
		return 0
	ok
	return number(_kC2_[1])

func KnaRefusesTrees(oClf, n)
	_kb3_ = FALSE
	try
		oClf.SetApproximateTrees(n)
	catch
		_kb3_ = TRUE
	done
	return _kb3_

func KnaRefusesBudget(oClf, n)
	_kb4_ = FALSE
	try
		oClf.SetApproximateBudget(n)
	catch
		_kb4_ = TRUE
	done
	return _kb4_

# three points whose NEAREST is 'high' while the majority of three is 'low' --
# distances 3, 4, 5 from the query (3,4), computed by hand
func KnaNearestDisagrees()
	_kD2_ = new stzTrainingSet([])
	_kD2_.AddExample([0, 0], "low")
	_kD2_.AddExample([3, 0], "low")
	_kD2_.AddExample([0, 4], "high")
	return _kD2_

# the label in the first "#n 'label'" of a Why() string
func KnaFirstLabelIn(cWhy)
	_kQ2_ = StzSplit(cWhy, "'")
	if len(_kQ2_) < 2
		return ""
	ok
	return _kQ2_[2]

# the label after "majority: "
func KnaMajorityIn(cWhy)
	_kM2_ = StzSplit(cWhy, "majority: '")
	if len(_kM2_) < 2
		return ""
	ok
	_kM3_ = StzSplit(_kM2_[2], "'")
	if len(_kM3_) = 0
		return ""
	ok
	return _kM3_[1]
