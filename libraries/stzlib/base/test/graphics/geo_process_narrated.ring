load "../../stzBase.ring"
decimals(4)

# GE7d -- POINT PROCESSES AS THINGS, AND NULL MODELS THAT ARE NOT CSR.
#
# GE7a could already ask whether a pattern is clustered. It asked by
# simulating complete spatial randomness, which is the least interesting
# question in the subject: almost nothing real is a uniform scatter, so
# rejecting CSR tells a reader what they could see by looking.
#
# The question worth asking is against a model that already explains
# something -- "more clustered than seed dispersal alone?", "clustered
# beyond where the people already are?" -- and that needs a process to be a
# NAMED, PARAMETERISED THING a caller can hand to the envelope.
#
# HOW THIS FILE IS ARGUED. A simulator is the second-easiest thing to get
# invisibly wrong, after a geodesy library: it produces plausible-looking
# points whatever it does, and a picture of a wrong process looks exactly
# like a picture of a right one. So the expectations here come from four
# places that owe the implementation nothing:
#
#   1. THE DEFINING PROPERTY of the distribution -- a Poisson count has
#      mean equal to its variance, and that is what separates it from the
#      binomial it is so often confused with.
#   2. A CLOSED FORM derived independently -- Matern II's saturating
#      intensity, (1 - exp(-t))/(pi r2), which says where the ceiling is
#      without simulating a single point.
#   3. AN ANALYTIC RATIO the surface itself fixes -- an intensity rising
#      linearly must put three times as many points in the upper half as
#      the lower, whatever code places them.
#   4. SELF-CONSISTENCY, which is the one that matters most: a process's
#      OWN patterns must fall inside its OWN envelope at about the nominal
#      rate. It is the check that caught the real defect in this plane --
#      see section 6 -- and no amount of looking at output would have.

nOk = 0  nBad = 0  nSec = 0

# ---------------------------------------------------------------------
sec("THE SEVEN, and what makes each a MECHANISM rather than a shape")

aKinds = StzGeoProcesses()
? "   " + len(aKinds) + " processes: " + _PJoin(aKinds)
chk("A POINT PROCESS IS A NAMED THING, not a generator buried in a method " +
    "-- which is what lets one be handed to an envelope as the null model",
    len(aKinds) = 7 and _PHas(aKinds, "Poisson") and _PHas(aKinds, "Thomas"))
chk("THREE OF THEM PLACE POINTS WITHOUT REGARD TO ONE ANOTHER and four do " +
    "not. The three are the honest nulls -- anything a statistic sees in " +
    "their output is chance; the four have an interaction built in and are " +
    "what a caller tests FOR",
    NOT StzGeoProcess(:Poisson).HasInteraction() and
    NOT StzGeoProcess(:Binomial).HasInteraction() and
    NOT StzGeoProcess(:Inhomogeneous).HasInteraction() and
    StzGeoProcess(:MaternCluster).HasInteraction() and
    StzGeoProcess(:Thomas).HasInteraction() and
    StzGeoProcess(:MaternII).HasInteraction() and
    StzGeoProcess(:SSI).HasInteraction())
chk("...and the two kinds of interaction are named apart: two processes " +
    "CLUSTER and two INHIBIT, which are opposite claims about a mechanism",
    StzGeoProcess(:Thomas).IsClustering() and
    StzGeoProcess(:SSI).IsInhibiting() and
    NOT StzGeoProcess(:Thomas).IsInhibiting())
chk("NEGATIVE: a mechanism nobody named is REFUSED and not quietly " +
    "Poisson -- silently substituting the weak null for a misspelt strong " +
    "one would turn a careful test into the useless one and say nothing",
    _PRefuses("Neyman"))

# ---------------------------------------------------------------------
sec("THE POISSON COUNT, against the property that defines it")

# MEAN EQUALS VARIANCE is the Poisson distribution. It is also exactly what
# distinguishes it from the binomial, whose variance at a fixed n is zero.
# RING CANNOT INDEX A LIST LITERAL IN PLACE -- `[ 1, 2 ][k]` is a type
# error, not a subscript -- so each of these is named first.
aLams = [ 0.5, 5, 50, 900 ]
for k = 1 to len(aLams)
	nLam = aLams[k]
	aS = _PMoments(nLam, 6000)
	? "   lambda " + nLam + ": mean " + aS[1] + ", variance " + aS[2]
next
chk("A POISSON COUNT HAS MEAN EQUAL TO ITS VARIANCE, over four orders of " +
    "magnitude. That identity IS the distribution, so it is the one thing " +
    "worth testing and the one thing a wrong implementation cannot fake",
    _PMomentsAgree(0.5) and _PMomentsAgree(5) and _PMomentsAgree(50))
chk("...INCLUDING ABOVE 700, where exp(-lambda) underflows and Knuth's " +
    "method stops working. It is handled by SPLITTING and not by an " +
    "approximation: a Poisson variable is the sum of independent Poisson " +
    "variables whose rates add, so a rate of 900 is two draws. That is the " +
    "definition of the distribution, not a trick",
    _PMomentsAgree(900))

# ---------------------------------------------------------------------
sec("POISSON AND BINOMIAL ARE NOT THE SAME NULL")

oSq = StzGeoFeaturesFromJson(_SquareJson())
oOne = StzGeoPoints([ 0.5, 0.5 ], oSq)
nArea = oOne.AreaKm2()
? "   the window is " + nArea + " km2"

aP = _PCounts(StzGeoCSR(0.02), oOne, 120)
oBin = StzGeoProcess(:Binomial)
oBin.SetCount(246)
aB = _PCounts(oBin, oOne, 120)
? "   Poisson  mean " + aP[1] + ", sd " + aP[2] + " (sqrt of the mean is " + sqrt(aP[1]) + ")"
? "   Binomial mean " + aB[1] + ", sd " + aB[2]
chk("A POISSON PROCESS'S COUNT IS RANDOM AND ITS SD IS THE ROOT OF ITS " +
    "MEAN. That is what makes it Poisson -- not what follows once the " +
    "points are placed",
    fabs(aP[2] - sqrt(aP[1])) / sqrt(aP[1]) < 0.2)
chk("A BINOMIAL PROCESS'S COUNT IS EXACTLY FIXED -- sd zero. It is what " +
    "GE7a's envelope has been simulating all along without saying so, and " +
    "it has STRICTLY LESS VARIANCE, so its band is narrower than the one a " +
    "reader assumes they are looking at",
    aB[2] = 0 and aP[2] > 5)

# ---------------------------------------------------------------------
sec("AN INHOMOGENEOUS PROCESS FOLLOWS ITS SURFACE")

# The surface rises linearly from zero in the west to its maximum in the
# east. The integral of x over the upper half is three times the integral
# over the lower half -- so three times the points, whatever code places
# them, and no part of that expectation comes from this engine.
oInh = StzGeoProcess(:Inhomogeneous)
oInh.SetIntensityGrid(_RampGrid(), _RampValues())
aHalves = _PHalves(oInh, oOne, 30)
? "   west " + aHalves[1] + " points, east " + aHalves[2] + ", ratio " +
  (aHalves[2] / aHalves[1])
chk("AN INTENSITY RISING LINEARLY PUTS THREE TIMES AS MANY POINTS IN THE " +
    "UPPER HALF AS THE LOWER, because the integral of x says so. This is " +
    "the null model that says 'the pattern follows the population', and " +
    "without it every disease map is significantly clustered",
    fabs(aHalves[2] / aHalves[1] - 3) < 0.15)
chk("...and its expected count is its SURFACE'S MEAN times the area, " +
    "which is the only place an inhomogeneous rate lives. Reading a scalar " +
    "intensity instead answered ZERO, and the envelope sized its buffer " +
    "from that",
    fabs(oInh.ExpectedCount(nArea, nArea) - 0.025 * nArea) / (0.025 * nArea) < 0.05)

# ---------------------------------------------------------------------
sec("MATERN II AND SSI LOOK ALIKE AND ARE NOT")

# Inhibition by DELETION against inhibition by REFUSAL. Matern II thins a
# pattern that already exists, so it has a CEILING; SSI builds one up, so
# it packs. Reporting "a hard-core model" without saying which is
# reporting a number without its units.
? "   Matern II, 4 km core, as the proposed rate rises:"
aSat = []
aRates = [ 0.02, 0.2, 2, 20 ]
for k = 1 to len(aRates)
	nLam = aRates[k]
	o = StzGeoProcess(:MaternII)
	o.SetIntensityQ(nLam).SetHardCoreKm(4)
	n = _PMeanCount(o, oOne, 8)
	aSat + n
	? "     proposed " + nLam + "/km2 -> " + n + " survive  (the closed form says " +
	  (StzGeoMaternIICeiling(nLam, 4) * nArea) + ")"
next
chk("MATERN II SATURATES: raising the proposal rate a THOUSANDFOLD moves " +
    "the survivors by a few per cent and no further, because past a point " +
    "every extra proposed point deletes as many as it adds",
    aSat[4] / aSat[2] < 1.15 and aSat[2] / aSat[1] > 1.3)
chk("...AND THE CEILING IS A CLOSED FORM, not a number read off a " +
    "simulation: (1 - exp(-t))/(pi r2) with t the rate times the disc. It " +
    "and the measurement agree within the edge effect -- a point near the " +
    "boundary has fewer older neighbours, so it survives more often than " +
    "the infinite-plane formula allows",
    fabs(aSat[4] - StzGeoMaternIICeiling(20, 4) * nArea) /
        (StzGeoMaternIICeiling(20, 4) * nArea) < 0.1)
oSsi = StzGeoProcess(:SSI)
oSsi.SetCountQ(100000).SetHardCoreKm(4)
nPacked = _PMeanCount(oSsi, oOne, 4)
? "   SSI asked for 100000 at the same 4 km -> " + nPacked + " packed in"
chk("SEQUENTIAL INHIBITION PACKS PAST MATERN II'S CEILING -- more than " +
    "twice as many in the same window with the same core. Its points are " +
    "not a thinning of anything, which is why the two are different " +
    "models and not two names for one",
    nPacked > aSat[4] * 1.8)

# ---------------------------------------------------------------------
sec("A PROCESS'S OWN PATTERNS FALL INSIDE ITS OWN BAND -- the check that bit")

# THIS IS THE ASSERTION THAT FOUND THE REAL DEFECT IN THIS PLANE.
#
# With 39 simulations the band is the smallest and largest of 39, so an
# independent 40th draw lands outside about one time in twenty. Any process
# whose own output escapes its own envelope more often than that has an
# envelope that is not its own.
#
# The first version failed at ONE HUNDRED PER CENT, on every process. The
# cause was two definitions of L in one library: GE7a's L() answers the
# CENTRED form, sqrt(K/pi) MINUS r, and the new envelope answered the
# uncentred one -- so the observed value and the band were on different
# scales and could never meet. Both halves looked entirely reasonable read
# on their own, every generated picture looked right, and nothing but this
# check would have found it.
aSelf = [ "Poisson", "Binomial", "MaternCluster", "Thomas", "MaternII" ]
for k = 1 to len(aSelf)
	cK = aSelf[k]
	aR = _PEscapeRate(_PMake(cK), oSq, oOne, 12)
	? "   " + cK + ": " + aR[1] + " of " + aR[2] + " radius-checks outside (" +
	  (100 * aR[1] / aR[2]) + " per cent)"
	chk(cK + "'S OWN PATTERNS FALL INSIDE " + cK + "'S OWN BAND at about " +
	    "the nominal rate -- which is the only evidence that the envelope " +
	    "is the process's and not some other process's",
	    aR[1] / aR[2] < 0.2)
next

# ---------------------------------------------------------------------
sec("AND THE VERDICT AGAINST A REAL NULL SAYS SOMETHING")

oM = StzGeoProcess(:MaternCluster)
oM.SetParentIntensityQ(0.002).SetMeanChildrenQ(25).SetRadiusKm(8)
oObs = StzGeoPoints(oM.GenerateIn(oOne, 4242), oSq)
aRad = [ 2, 4, 8, 16 ]
aVsCsr = StzGeoCSR(oObs.DensityPerKm2()).VerdictOn(oObs, aRad, 39, 99, :L)
aVsOwn = oM.VerdictOn(oObs, aRad, 39, 99, :L)
? "   " + oObs.Count() + " points from a Matern cluster process"
? "   against CSR:          " + aVsCsr[:verdict]
? "   against its own kind: " + aVsOwn[:verdict]
chk("AGAINST CSR THE PATTERN IS 'SIGNIFICANTLY CLUSTERED' AT EVERY SCALE " +
    "-- which is true, useless, and what every paper reports. Seeds fall " +
    "near their parent; nobody thought otherwise",
    len(aVsCsr[:above]) = len(aRad))
chk("AGAINST THE PROCESS THAT ACTUALLY MADE IT the same pattern is " +
    "CONSISTENT AT EVERY SCALE. That is the answer a reader can use: the " +
    "clustering is explained, and there is nothing left to explain",
    len(aVsOwn[:above]) = 0 and len(aVsOwn[:below]) = 0)
oTight = StzGeoProcess(:MaternCluster)
oTight.SetParentIntensityQ(0.0004).SetMeanChildrenQ(125).SetRadiusKm(3)
oT2 = StzGeoPoints(oTight.GenerateIn(oOne, 808), oSq)
aVsTight = oM.VerdictOn(oT2, aRad, 39, 99, :L)
? "   a TIGHTER pattern against the same null: " + aVsTight[:verdict]
chk("NEGATIVE: AND A GENUINELY TIGHTER PATTERN STILL ESCAPES that same " +
    "null -- so the model has not been made unfalsifiable by being made " +
    "realistic, which is the thing to check whenever a null stops being CSR",
    len(aVsTight[:above]) >= 3)
chk("THE VERDICT CARRIES ITS SCALES AND ITS SIMULATION COUNT, because " +
    "'clustered' without a range is not a finding -- a wood can be " +
    "clustered at ten metres and regular at fifty -- and a band's width " +
    "depends on how many simulations drew it",
    aVsCsr[:sims] = 39 and aVsCsr[:null] = "Poisson" and
    StzFindFirst("km", aVsCsr[:verdict]) > 0)

# ---------------------------------------------------------------------
sec("THINNING: turning an OBSERVED pattern into a null model")

aThin = StzEngineGeoProcessThin(oObs.Points(), 0.5, 31)
? "   " + oObs.Count() + " points thinned at p=0.5 -> " + (len(aThin) / 2)
chk("INDEPENDENT THINNING KEEPS EACH POINT WITH PROBABILITY p, deciding " +
    "separately for each -- so about half survive, and the number is " +
    "itself random rather than exactly half",
    len(aThin) / 2 > oObs.Count() * 0.4 and len(aThin) / 2 < oObs.Count() * 0.6)
chk("...and every surviving point is one of the originals, in order. A " +
    "thinned pattern has the SAME intensity surface and the SAME " +
    "clustering, so whatever a statistic still sees in it was caused by " +
    "neither -- which is the entire reason to thin",
    _PIsSubsequence(aThin, oObs.Points()))

? ""
? "=========================================================="
? " " + nOk + " ok, " + nBad + " failed"
? "=========================================================="

func chk pcWhat, pbOk
	if pbOk
		nOk++
		? "  ok   " + pcWhat
	else
		nBad++
		? "  FAIL " + pcWhat
	ok

func sec pcWhat
	nSec++
	? ""
	? "-- " + nSec + ". " + pcWhat + " --"

func _PJoin paList
	_o_ = ""
	for _i_ = 1 to len(paList)
		if _i_ > 1  _o_ += ", "  ok
		_o_ += paList[_i_]
	next
	return _o_

func _PHas paList, pcName
	for _i_ = 1 to len(paList)
		if paList[_i_] = pcName  return TRUE  ok
	next
	return FALSE

func _PRefuses pcName
	try
		StzGeoProcess(pcName)
		return FALSE
	catch
		return TRUE
	done

func _SquareJson()
	return '{"type":"FeatureCollection","features":[{"type":"Feature",' +
		'"properties":{"name":"Square"},"geometry":{"type":"Polygon",' +
		'"coordinates":[[[0,0],[1,0],[1,1],[0,1],[0,0]]]}}]}'

# an intensity surface rising linearly west to east, 0 to 0.05 per km2
func _RampGrid()
	return [ 0, 0, 0.05, 0.05, 21, 21 ]

func _RampValues()
	_v_ = []
	for _j_ = 0 to 20
		for _i_ = 0 to 20
			_v_ + (0.05 * _i_ / 20)
		next
	next
	return _v_

func _PMoments pnLambda, pnRuns
	_s_ = 0
	_q_ = 0
	for _i_ = 1 to pnRuns
		_k_ = StzPoissonCount(pnLambda, 700000 + _i_ * 7919)
		_s_ += _k_
		_q_ += _k_ * _k_
	next
	_m_ = _s_ / pnRuns
	return [ _m_, _q_ / pnRuns - _m_ * _m_ ]

func _PMomentsAgree pnLambda
	_a_ = _PMoments(pnLambda, 6000)
	if _a_[1] <= 0  return FALSE  ok
	return fabs(_a_[1] - pnLambda) / pnLambda < 0.06 and
	       fabs(_a_[2] - pnLambda) / pnLambda < 0.14

func _PCounts poProc, poPoints, pnRuns
	_s_ = 0
	_q_ = 0
	for _i_ = 1 to pnRuns
		_n_ = len(poProc.GenerateIn(poPoints, 300000 + _i_ * 104729)) / 2
		_s_ += _n_
		_q_ += _n_ * _n_
	next
	_m_ = _s_ / pnRuns
	_v_ = _q_ / pnRuns - _m_ * _m_
	if _v_ < 0  _v_ = 0  ok
	return [ _m_, sqrt(_v_) ]

func _PMeanCount poProc, poPoints, pnRuns
	_s_ = 0
	for _i_ = 1 to pnRuns
		_s_ += len(poProc.GenerateIn(poPoints, 22000 + _i_ * 6151)) / 2
	next
	return _s_ / pnRuns

func _PHalves poProc, poPoints, pnRuns
	_w_ = 0
	_e_ = 0
	for _i_ = 1 to pnRuns
		_a_ = poProc.GenerateIn(poPoints, 55000 + _i_ * 3571)
		for _k_ = 1 to len(_a_) / 2
			if _a_[_k_ * 2 - 1] < 0.5  _w_++  else  _e_++  ok
		next
	next
	if _w_ = 0  _w_ = 1  ok
	return [ _w_, _e_ ]

func _PMake pcKind
	_o_ = StzGeoProcess(pcKind)
	if pcKind = "Poisson"
		_o_.SetIntensity(0.02)
	but pcKind = "Binomial"
		_o_.SetCount(246)
	but pcKind = "MaternCluster"
		_o_.SetParentIntensityQ(0.0008).SetMeanChildrenQ(25).SetRadiusKm(8)
	but pcKind = "Thomas"
		_o_.SetParentIntensityQ(0.0008).SetMeanChildrenQ(25).SetSigmaKm(4)
	but pcKind = "MaternII"
		_o_.SetIntensityQ(0.05).SetHardCoreKm(4)
	but pcKind = "SSI"
		_o_.SetCountQ(200).SetHardCoreKm(4)
	ok
	return _o_

func _PEscapeRate poProc, poWindow, poPoints, pnRuns
	_out_ = 0
	_tot_ = 0
	_r_ = [ 2, 4, 8, 16 ]
	for _s_ = 1 to pnRuns
		_pts_ = poProc.GenerateIn(poPoints, 1000 + _s_ * 37)
		if len(_pts_) < 40  loop  ok
		_e_ = poProc.EscapesOf(StzGeoPoints(_pts_, poWindow), _r_, 39, 500000 + _s_ * 13, :L)
		for _i_ = 1 to len(_e_)
			_tot_++
			if _e_[_i_] != 0  _out_++  ok
		next
	next
	if _tot_ = 0  return [ 1, 1 ]  ok
	return [ _out_, _tot_ ]

# every kept point is one of the originals, and in the original order
func _PIsSubsequence paKept, paAll
	_j_ = 1
	for _i_ = 1 to len(paKept) / 2
		_found_ = FALSE
		while _j_ <= len(paAll) / 2
			if paAll[_j_ * 2 - 1] = paKept[_i_ * 2 - 1] and
			   paAll[_j_ * 2] = paKept[_i_ * 2]
				_found_ = TRUE
				_j_++
				exit
			ok
			_j_++
		end
		if NOT _found_  return FALSE  ok
	next
	return TRUE
