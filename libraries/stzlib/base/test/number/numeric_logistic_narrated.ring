load "../../stzBase.ring"
load "../_narrated.ring"

# LOGISTIC REGRESSION COMES DOWN FROM RING (numeric phase 5).
#
# THE FIRST THING WAS TO CHECK THE PLAN'S CLAIM, because the last time this phase
# moved an algorithm the plan named the wrong line. The simplex went into the engine
# and a 40-variable model improved by 0.6% -- 95% of its time was a string re-parse
# nobody had profiled. So before writing any Zig, the old Ring training loop was
# hoisted BY HAND: the label comparison done once instead of once per epoch, and the
# feature row read in place instead of passed as an argument (Ring copies a list into
# a parameter). On 5000 examples x 16 features x 100 epochs:
#
#     as it shipped                        10.0 s
#     hoisted, still pure Ring              5.0 s      -- and bit-identical weights
#
# Half the cost was interpreter overhead, and half was arithmetic that no amount of
# Ring-side care removes. THAT is what justified the move. Measured after:
#
#     200   x 4  x 50  epochs             0.002 s
#     5000  x 16 x 100 epochs             0.062 s      -- from 10.0 s, 161x
#     20000 x 32 x 100 epochs             0.706 s      -- previously out of reach
#
# THE ARITHMETIC IS UNCHANGED, NOT MERELY EQUIVALENT, and that distinction is the
# whole design of `logistic.zig`. Gradient descent is a feedback loop: this step's
# weights decide the next step's gradient, so a last-bit difference does not stay a
# last-bit difference. The class promises reproducible runs. So the updates stay
# sequential per example (this is SGD -- the weights move before the next example is
# scored), the dot product accumulates in index order even though a lane-parallel
# reduction would be faster, and the saturation cutoff stays at |z| > 35.
#
# ONLY THE WEIGHT UPDATE VECTORISES, and only because it can: `w[f] += c * x[f]` is
# elementwise, so no accumulation crosses lanes and no reassociation is possible --
# the vector and scalar forms compute the same expression, bit for bit. Half the
# inner work vectorises free and half must not, and knowing which is which is the
# engineering.
#
# ONE THING COULD NOT BE HELD FIXED: Ring's `exp` is the C library's, the engine's is
# Zig's, and they agree only to within an ulp. Rather than assume that away, it was
# measured against the old loop reproduced verbatim -- see the scenario below.

Scenario("the fit is the same fit -- and the residue is measured, not assumed")
	# The old Ring loop reproduced verbatim, versus the engine, on identical data.
	#
	# THE FIRST READING OF THIS WAS WRONG, and the way it was wrong is worth
	# keeping. Printed under `decimals(14)` the drift showed as 0.00000000000000
	# at one and ten epochs, and the obvious assertion -- "identical to the last
	# bit" -- was written and FAILED. The value was never zero; the display had
	# truncated it. So the honest measurement is by ORDER OF MAGNITUDE, which no
	# display mode can hide:
	#
	#     1 epoch      1e-16     one ulp: exp has been called 400 times
	#     2 epochs     1e-16
	#     10 epochs    1e-15
	#     100 epochs   1e-14
	#     500 epochs   1e-14
	#
	# That is exactly the predicted shape. Ring's exp is the C library's and the
	# engine's is Zig's; they agree to within an ulp, so the difference appears
	# immediately, and because gradient descent feeds each step into the next it
	# does not stay an ulp -- it grows about a decade per five hundred epochs on
	# this problem. Against weights of magnitude 1 to 10 that is 1e-16 relative
	# growing to 1e-15, far below anything a probability, a classification or a
	# reported weight can express, and it is the ONLY difference: everything that
	# could be held fixed -- update order, summation order, saturation cutoff --
	# was held fixed deliberately.
	aD = MakeData(400, 6)
	oTs = new stzTrainingSet(aD)

	Then("1 epoch: agrees to 1e-15", DriftAt(oTs, 400, 6, 1) < 0.000000000000001, TRUE)
	Then("...and is NOT exactly zero -- exp is the one thing that could not match",
	     DriftAt(oTs, 400, 6, 1) > 0, TRUE)
	Then("10 epochs: still under 1e-14", DriftAt(oTs, 400, 6, 10) < 0.00000000000001, TRUE)
	Then("100 epochs: under 1e-13", DriftAt(oTs, 400, 6, 100) < 0.0000000000001, TRUE)
	Then("500 epochs: still under 1e-13 -- the growth is slow",
	     DriftAt(oTs, 400, 6, 500) < 0.0000000000001, TRUE)
	# and the part that matters to a user: the MODEL is the same model
	Then("...and both loops classify identically at 500 epochs",
	     SameVerdicts(oTs, 400, 6, 500), TRUE)
EndScenario()

Scenario("and it still learns what it used to")
	o = new stzLogisticRegression(new stzTrainingSet([
		[ [0.0], "lo" ], [ [0.1], "lo" ], [ [0.2], "lo" ],
		[ [0.8], "hi" ], [ [0.9], "hi" ], [ [1.0], "hi" ] ]))
	o.Train(300)

	Then("the weight has the sign the data implies", o.Weights()[1] > 0, TRUE)
	Then("low input -> low class", o.Classify([0.05]), "lo")
	Then("high input -> high class", o.Classify([0.95]), "hi")
	Then("...and the boundary sits between them",
	     o.Probability([0.05]) < 0.5 and o.Probability([0.95]) > 0.5, TRUE)
	Then("it fits its own training data", o.TrainingAccuracy(), 1)
	Then("Why() still narrates", StzFindFirst("P('hi')", o.Why()) > 0, TRUE)
EndScenario()

Scenario("an untrained model still refuses, and zero epochs is still uninformed")
	oU = new stzLogisticRegression(new stzTrainingSet([
		[ [1,2], "a" ], [ [3,4], "b" ] ]))
	Then("Probability before Train raises", Raises1(oU), TRUE)

	oZ = new stzLogisticRegression(new stzTrainingSet([
		[ [1,2], "a" ], [ [3,4], "b" ] ]))
	oZ.Train(0)
	Then("Train(0) leaves the first weight at zero", oZ.Weights()[1], 0)
	Then("...and the second", oZ.Weights()[2], 0)
	Then("...and the bias", oZ.Bias(), 0)
	# a model that has learned nothing should say so, and a half is how it says it
	Then("...so every probability is a half", oZ.Probability([1,2]), 0.5)
	Then("...whatever you ask it", oZ.Probability([99,-99]), 0.5)
EndScenario()

Scenario("two silent failures are now diagnoses -- this is the point of the slice")
	# RAGGED DATA. NumberOfFeatures() is the width of the FIRST example, and the old
	# loop indexed every other row to that width. A 3-feature row among 2-feature
	# rows trained as though its third feature did not exist -- no error, no warning,
	# a quietly different model. The engine refuses a length mismatch outright, and
	# a refusal is only useful if the caller handles it, so the row is named.
	Then("a wider row is refused, not truncated", RaisesTrain([
		[ [1,2], "a" ], [ [3,4,5], "b" ], [ [0,1], "a" ] ]), TRUE)
	Then("...and a narrower one too", RaisesTrain([
		[ [1,2,3], "a" ], [ [3,4], "b" ], [ [0,1,1], "a" ] ]), TRUE)
	Then("...naming which example is wrong", StzFindFirst("Example 2", WhyTrain([
		[ [1,2], "a" ], [ [3,4,5], "b" ], [ [0,1], "a" ] ])) > 0, TRUE)
	Then("...and how wide the set is", StzFindFirst("2 wide", WhyTrain([
		[ [1,2], "a" ], [ [3,4,5], "b" ], [ [0,1], "a" ] ])) > 0, TRUE)

	# WRONG ARITY AT CLASSIFY TIME. This used to escape as a bare Ring
	# "Array Access (Index out of range)" thrown from inside the dot product,
	# which named neither the model nor what the caller did wrong.
	oA = new stzLogisticRegression(new stzTrainingSet([
		[ [1,2,3], "a" ], [ [4,5,6], "b" ] ]))
	oA.Train(5)
	Then("too few features is refused", RaisesP(oA, [1,2]), TRUE)
	Then("...and too many", RaisesP(oA, [1,2,3,4]), TRUE)
	Then("...and none at all", RaisesP(oA, []), TRUE)
	Then("...saying what the model was fitted on",
	     StzFindFirst("fitted on 3", WhyP(oA, [1,2])) > 0, TRUE)
	Then("...and what it got instead",
	     StzFindFirst("you gave it 2", WhyP(oA, [1,2])) > 0, TRUE)
	Then("the right arity of course still works", oA.Probability([1,2,3]) > 0, TRUE)
EndScenario()

Scenario("one definition of the score -- Probability agrees with the fit")
	# _Score() and _Sigmoid() used to exist in Ring alongside the ones in the
	# engine. Two definitions of one quantity is the shape this phase keeps paying
	# for, and here it would have surfaced as a model whose predictions disagreed
	# with its own training. The Ring copies are gone.
	o = new stzLogisticRegression(new stzTrainingSet(MakeData(50, 3)))
	o.Train(100)

	# the bulk path and the single path must be the SAME function
	aRows = [ [0.1,0.2,0.3], [0.9,0.8,0.7], [0.5,0.5,0.5] ]
	aBulk = o.Probabilities(aRows)
	Then("bulk and single agree exactly, row 1", aBulk[1], o.Probability(aRows[1]))
	Then("...row 2", aBulk[2], o.Probability(aRows[2]))
	Then("...row 3", aBulk[3], o.Probability(aRows[3]))

	# and a probability is a probability
	Then("every value is in [0,1]",
	     aBulk[1] >= 0 and aBulk[1] <= 1 and aBulk[2] >= 0 and aBulk[2] <= 1, TRUE)
	Then("a ragged bulk row is refused too", RaisesBulk(o, [ [1,2,3], [1,2] ]), TRUE)
EndScenario()

Scenario("the divergence this class documents is REAL, and still surfaced")
	# Not fixed here, and deliberately so: needing standardised features is the
	# normal requirement of stochastic gradient descent, not a defect in this class.
	# What matters is that it is VISIBLE, because the way it fails is silent and
	# confident -- the model returns probabilities of exactly 1 and 0, which read as
	# certainty, while classifying at chance. TrainingAccuracy() is the instrument.
	aRaw = []
	aScaled = []
	for i = 1 to 40
		v = i * 2000
		cL = "lo"
		if i > 20
			cL = "hi"
		ok
		aRaw + [ [ v, v ], cL ]
		aScaled + [ [ v/80000, v/80000 ], cL ]
	next

	oRaw = new stzLogisticRegression(new stzTrainingSet(aRaw))
	oRaw.Train(200)
	oScaled = new stzLogisticRegression(new stzTrainingSet(aScaled))
	oScaled.Train(200)

	Then("unscaled features diverge -- weights in the thousands",
	     oRaw.Weights()[1] > 1000, TRUE)
	Then("...and the model scores at chance on data it has SEEN",
	     oRaw.TrainingAccuracy() <= 0.5, TRUE)
	Then("the same data scaled converges", oScaled.Weights()[1] < 100, TRUE)
	Then("...and gets it right", oScaled.TrainingAccuracy(), 1)
	Then("...which is what makes the failure visible rather than silent",
	     oScaled.TrainingAccuracy() > oRaw.TrainingAccuracy(), TRUE)
EndScenario()

Summary()

func MakeData(nEx, nF)
	aD = []
	for i = 1 to nEx
		aF = []
		s = 0
		for f = 1 to nF
			v = ((i * 37 + f * 11) % 100) / 100
			aF + v
			s += v
		next
		cL = "no"
		if s > nF / 2
			cL = "yes"
		ok
		aD + [ aF, cL ]
	next
	return aD

# the old Ring loop, verbatim, so the comparison is against what actually shipped
func DriftAt(oTs, nEx, nF, nEp)
	o = new stzLogisticRegression(oTs)
	o.Train(nEp)
	aWe = o.Weights()
	nBe = o.Bias()

	acL = oTs.Labels()
	aE = oTs.Examples()
	aW = []
	for f = 1 to nF
		aW + 0
	next
	nB = 0
	nLr = 0.1
	for e = 1 to nEp
		for i = 1 to nEx
			nY = 0
			if aE[i][2] = acL[2]
				nY = 1
			ok
			nZ = nB
			for f = 1 to nF
				nZ += aW[f] * aE[i][1][f]
			next
			if nZ > 35
				nP = 1
			but nZ < -35
				nP = 0
			else
				nP = 1 / (1 + exp(-nZ))
			ok
			nErr = nY - nP
			for f = 1 to nF
				aW[f] += nLr * nErr * aE[i][1][f]
			next
			nB += nLr * nErr
		next
	next

	nMax = fabs(nB - nBe)
	for f = 1 to nF
		d = fabs(aW[f] - aWe[f])
		if d > nMax
			nMax = d
		ok
	next
	return nMax

# the drift is in the last bits; the DECISIONS must be identical
func SameVerdicts(oTs, nEx, nF, nEp)
	o = new stzLogisticRegression(oTs)
	o.Train(nEp)
	aE = oTs.Examples()
	acL = oTs.Labels()

	aW = []
	for f = 1 to nF
		aW + 0
	next
	nB = 0
	nLr = 0.1
	for e = 1 to nEp
		for i = 1 to nEx
			nY = 0
			if aE[i][2] = acL[2]
				nY = 1
			ok
			nZ = nB
			for f = 1 to nF
				nZ += aW[f] * aE[i][1][f]
			next
			if nZ > 35
				nP = 1
			but nZ < -35
				nP = 0
			else
				nP = 1 / (1 + exp(-nZ))
			ok
			nErr = nY - nP
			for f = 1 to nF
				aW[f] += nLr * nErr * aE[i][1][f]
			next
			nB += nLr * nErr
		next
	next

	for i = 1 to nEx
		nZ = nB
		for f = 1 to nF
			nZ += aW[f] * aE[i][1][f]
		next
		if nZ > 35
			nP = 1
		but nZ < -35
			nP = 0
		else
			nP = 1 / (1 + exp(-nZ))
		ok
		cRing = acL[1]
		if nP >= 0.5
			cRing = acL[2]
		ok
		if o.Classify(aE[i][1]) != cRing
			return FALSE
		ok
	next
	return TRUE

func Raises1(o)
	b = FALSE
	try
		v = o.Probability([1,2])
	catch
		b = TRUE
	done
	return b

func RaisesTrain(aD)
	b = FALSE
	try
		o = new stzLogisticRegression(new stzTrainingSet(aD))
		o.Train(5)
	catch
		b = TRUE
	done
	return b

func WhyTrain(aD)
	c = ""
	try
		o = new stzLogisticRegression(new stzTrainingSet(aD))
		o.Train(5)
	catch
		c = cCatchError
	done
	return c

func RaisesP(o, aF)
	b = FALSE
	try
		v = o.Probability(aF)
	catch
		b = TRUE
	done
	return b

func WhyP(o, aF)
	c = ""
	try
		v = o.Probability(aF)
	catch
		c = cCatchError
	done
	return c

func RaisesBulk(o, aRows)
	b = FALSE
	try
		v = o.Probabilities(aRows)
	catch
		b = TRUE
	done
	return b
