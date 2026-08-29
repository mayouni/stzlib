load "../../stzBase.ring"
load "../_narrated.ring"

# Phase 4 of the numeric foundation, sixth slice: SIMILARITY.
#
# The plan listed this as a performance item -- "similarity.zig's six functions are
# scalar loops and are on the hot path for every embedding comparison in the NLP
# and neural tiers". Investigating found the performance claim was WRONG and a
# correctness problem underneath it that the plan had not noticed.
#
# THE CLAIM WAS WRONG. `ring_bridge_similarity.zig` exposed only fixed
# THREE-dimension variants -- `...Cosine3(a1,a2,a3, b1,b2,b3)` -- so Ring could not
# hand the module an embedding at all. Even `CosineFromLists`, which takes lists,
# insisted on exactly three elements and unpacked them into the 3-argument form. The
# module was unreachable from the hot path it was supposed to be on.
#
# AND UNDERNEATH IT, A SILENT ZERO. Every function in similarity.zig began
#
#     if (dim <= 0 or dim > 1024) return 0.0;
#
# Not an error. Not a clamp. A silent 0.0 -- which for a cosine means "completely
# unrelated". Two IDENTICAL 1536-dimension vectors would have scored 0. And 1024 is
# exactly where real sentence embeddings live: 384, 768, 1024, 1536.
#
# The two defects were each other's cover. The cap never fired because the bridge
# was too narrow; the bridge was never widened because nothing needed it. Widening
# the bridge alone would have converted a latent trap into a live one, so both are
# fixed in this slice, and the guard below checks the cap is gone at every dimension
# a real model produces.

Scenario("the cap is gone, and it was a silent zero rather than an error")
	oS = new stzSimilarity()

	# A vector is perfectly similar to itself. At every dimension -- including the
	# ones that used to answer 0.
	_aNDim150_ = [ 384, 768, 1024, 1536, 4096 ]
	_nNDim150_ = len(_aNDim150_)
	for _iNDim150_ = 1 to _nNDim150_
		nDim = _aNDim150_[_iNDim150_]
		av = []
		for i = 1 to nDim
			av + ((i % 17) + 1)
		next
		Then("dim " + nDim + ": cosine with itself is 1",
		     Rnd9(oS.CosineFromLists(av, av)), 1)
		Then("dim " + nDim + ": distance from itself is 0",
		     Rnd9(oS.EuclideanFromLists(av, av)), 0)
	next
	# above 1024 every one of these was 0.0 -- "unrelated" for a vector and itself.
EndScenario()

Scenario("...and the list surface accepts a real embedding at all")
	oS = new stzSimilarity()
	# CosineFromLists used to raise "both lists must contain exactly 3 numbers".
	av = []
	for i = 1 to 300
		av + (i * 0.5)
	next
	aw = []
	for i = 1 to 300
		aw + (600 - i * 0.5)
	next
	Then("a 300-dimension cosine comes back in range",
	     oS.CosineFromLists(av, aw) <= 1 and oS.CosineFromLists(av, aw) >= -1, TRUE)

	Then("the three-argument forms are untouched, since they are published",
	     CosineSimilarity3(1, 0, 0, 1, 0, 0), 1)
	Then("...and the class's own", Rnd9(oS.Cosine3(0, 1, 0, 1, 0, 0)), 0)

	Given("vectors of different dimension, where the question is meaningless")
	Then("it raises rather than comparing what it can",
	     RaisesPair([1, 2, 3], [1, 2]), TRUE)
	Then("...and an empty vector raises too", RaisesPair([], []), TRUE)
EndScenario()

Scenario("the metrics themselves, against arithmetic anyone can check")
	oS = new stzSimilarity()
	Then("dot of [1,2,3] and [4,5,6] is 4+10+18", oS.Dot([1,2,3], [4,5,6]), 32)
	Then("euclidean from the origin to (3,4) is 5",
	     oS.EuclideanFromLists([0,0], [3,4]), 5)
	Then("manhattan of [1,2,3] to [4,6,3] is 3+4+0",
	     oS.ManhattanFromLists([1,2,3], [4,6,3]), 7)
	Then("the magnitude of [3,4] is 5", oS.MagnitudeOf([3,4]), 5)
	Then("...and normalising it gives the unit vector",
	     @@(oS.NormalizedList([3,4])), "[ 0.60, 0.80 ]")
	Then("a zero vector has no direction, so it is returned unchanged",
	     @@(oS.NormalizedList([0,0])), "[ 0, 0 ]")
EndScenario()

Scenario("the identities a similarity measure has to satisfy")
	oS = new stzSimilarity()
	aA = [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12 ]
	aB = [ 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ]

	Then("cosine is symmetric",
	     Rnd9(oS.CosineFromLists(aA, aB)), Rnd9(oS.CosineFromLists(aB, aA)))

	aNeg = []
	nLen = len(aA)
	for i = 1 to nLen
		aNeg + (-aA[i])
	next
	Then("a vector against its own negation is exactly -1",
	     Rnd9(oS.CosineFromLists(aA, aNeg)), -1)

	# THE PROPERTY THAT MAKES COSINE THE RIGHT CHOICE FOR EMBEDDINGS: it measures
	# an angle, so scaling a vector cannot change it -- while a distance changes.
	aScaled = []
	for i = 1 to nLen
		aScaled + (aA[i] * 100)
	next
	Then("scaling by 100 leaves the cosine untouched",
	     Rnd9(oS.CosineFromLists(aA, aB)), Rnd9(oS.CosineFromLists(aScaled, aB)))
	Then("...but the euclidean distance grows",
	     oS.EuclideanFromLists(aScaled, aB) > oS.EuclideanFromLists(aA, aB), TRUE)

	Then("manhattan is never less than euclidean",
	     oS.ManhattanFromLists(aA, aB) >= oS.EuclideanFromLists(aA, aB), TRUE)

	# The identity StzSemanticSimilarity depends on: for L2-normalised vectors the
	# DOT PRODUCT is the cosine. That is why the neural path can use a dot product
	# and call the result a similarity -- and why its Ring loop could be replaced
	# with one engine call.
	Then("for unit vectors, dot == cosine",
	     Rnd9(oS.Dot(oS.NormalizedList(aA), oS.NormalizedList(aB))),
	     Rnd9(oS.CosineFromLists(aA, aB)))
EndScenario()

Scenario("vectorised, and the gain is bigger here than anywhere else in phase 4")
	# Measured over 200 000 cosines at ReleaseSafe:
	#
	#     dim 384    scalar  33.4ms   @Vector(8)   9.7ms   3.44x
	#     dim 768    scalar  66.9ms   @Vector(8)  18.3ms   3.66x
	#     dim 1536   scalar 135.2ms   @Vector(8)  40.1ms   3.37x
	#
	# The best ratio of the phase, and for a reason worth knowing: COSINE
	# ACCUMULATES THREE QUANTITIES PER ELEMENT LOADED -- the dot product and both
	# squared magnitudes -- so it is compute-bound. A plain dot product reads two
	# arrays to do one multiply-add and is bandwidth-bound, which is why it gained
	# only 1.2x in slice 2. Arithmetic per byte loaded is what decides whether SIMD
	# pays.
	oS = new stzSimilarity()
	av = []
	aw = []
	for i = 1 to 768
		av + ((i % 31) + 0.5)
		aw + ((i % 17) + 0.25)
	next

	nT0 = clock()
	for k = 1 to 2000
		n = oS.CosineFromLists(av, aw)
	next
	nT1 = clock()
	Then("2000 cosines over 768 dimensions stay under a second",
	     ((nT1 - nT0) / clockspersecond()) < 1, TRUE)
	Then("...and the answer is in range", n <= 1 and n >= -1, TRUE)

	# Jaccard is deliberately NOT vectorised: it merges two sorted runs, which is
	# inherently sequential. Contorting it into lanes would cost clarity for
	# nothing.
EndScenario()

Summary()

func RaisesPair(aA, aB)
	bR = FALSE
	oS = new stzSimilarity()
	try
		nIgnored = oS.CosineFromLists(aA, aB)
	catch
		bR = TRUE
	done
	return bR

func Rnd9(n)
	return ceil(n * 1000000000 - 0.5) / 1000000000
