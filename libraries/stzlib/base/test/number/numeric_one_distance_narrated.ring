load "../../stzBase.ring"
load "../_narrated.ring"

# Phase 5 of the numeric foundation, third slice: ONE DEFINITION OF DISTANCE.
#
# stzKMeans and stzKnn each carried a hand-rolled Euclidean distance -- byte-for-byte
# identical Ring loops -- while similarity.zig has had a vectorised, tested one since
# phase 4 slice 6. Three definitions of one quantity.
#
# That is the shape this plan keeps finding: the variance divisor (phase 0, where two
# modules genuinely disagreed), the summation (phase 3, where they gave different
# answers for the same 1001 numbers), the centered sum of squares (phase 4 slice 3,
# written five times), the negligible threshold (phase 4 slice 9, where rank and the
# condition number contradicted each other). Here the three agreed -- but agreement
# by coincidence is what the earlier cases had too, right up until they stopped.
#
# MEASURED BEFORE MOVING, since phase 3 established that a one-shot engine call is no
# faster than Ring when marshalling dominates:
#
#     N x dims       ring loop    engine call
#     1000 x 8        0.001s       0s
#     5000 x 16       0.015s       0.002s
#     20000 x 32      0.111s       0.014s      8x
#
# Marshalling 32 doubles is cheaper than 32 interpreted loop steps, so the crossing
# pays even per point. Below a few thousand points both are free, and the authority
# argument alone would have justified it.
#
# THE RAGGED CASE IS THE INTERESTING PART. Both loops truncated to the shorter vector,
# and nothing validates vector lengths on the way in, so that truncation is
# load-bearing. The engine bridge REFUSES a length mismatch and answers 0 -- which for
# a distance reads as "these two points are identical", the worst wrong answer
# available. So the common case goes straight through and the ragged case slices
# first, preserving the old behaviour exactly.

Scenario("the three definitions agree, and now there is only one")
	oK = new stzKMeans([ [0,0], [3,4] ])
	Then("a 3-4-5 triangle, through kmeans", oK._Dist([0,0], [3,4]), 5)

	oTS = new stzTrainingSet([])
	oTS.AddExample([1,1], "near")
	oTS.AddExample([9,9], "far")
	oN = new stzKnn(oTS)
	Then("...and through knn", oN._Dist([0,0], [3,4]), 5)

	Then("...and through the engine directly",
	     StzEngineSimEuclidean([0,0], [3,4]), 5)

	# a case with no round answer, so agreement cannot be luck
	aA = [ 1.5, -2.25, 7.75, 0.5 ]
	aB = [ -3.25, 4.5, 1.25, -6.5 ]
	Then("an awkward pair agrees between kmeans and knn",
	     Rnd9(oK._Dist(aA, aB)), Rnd9(oN._Dist(aA, aB)))
	Then("...and with the engine", Rnd9(oK._Dist(aA, aB)),
	     Rnd9(StzEngineSimEuclidean(aA, aB)))

	Then("a point is at zero distance from itself", oK._Dist(aA, aA), 0)
	Then("distance is symmetric", oK._Dist(aA, aB), oK._Dist(aB, aA))
EndScenario()

Scenario("the RAGGED case, where the engine alone would have said 'identical'")
	# Nothing validates vector lengths on input, so mismatched vectors do reach the
	# distance. Both loops compared over the common prefix; the engine bridge refuses
	# a mismatch and returns 0.
	oK = new stzKMeans([ [0,0], [1,1] ])

	Then("the engine ALONE answers 0 for a length mismatch -- 'identical'",
	     StzEngineSimEuclidean([0,0,99], [3,4]), 0)

	Then("...but the method still compares the common prefix, as it always did",
	     oK._Dist([0,0,99], [3,4]), 5)
	Then("...whichever side is longer", oK._Dist([0,0], [3,4,99]), 5)

	oTSr = new stzTrainingSet([])
	oTSr.AddExample([1,1], "near")
	oNr = new stzKnn(oTSr)
	Then("knn does the same", oNr._Dist([0,0,99], [3,4]), 5)
	# THE POINT: routing to a shared authority is only safe if the authority's
	# REFUSALS are handled. A distance of 0 does not mean "cannot compare" -- it
	# means "the same point", and k-means would have collapsed a cluster onto it.
EndScenario()

Scenario("and the algorithms above it still behave")
	# k-means on two obvious clusters, which must separate regardless of how the
	# distance is computed.
	oK = new stzKMeans([ [1,1], [1.2,0.9], [8,8], [7.9,8.1] ])
	oK.SetK(2)
	oK.Run(50)
	aC = oK.Clusters()
	Then("two clusters come back", len(aC), 2)
	Then("...and the far point lands with the far group",
	     oK.ClusterOf([7.5, 8.0]), oK.ClusterOf([8, 8]))
	Then("...while the near point does not",
	     oK.ClusterOf([1, 1]) != oK.ClusterOf([8, 8]), TRUE)

	# knn on a labelled set
	oSet = new stzTrainingSet([])
	oSet.AddExample([1,1], "near")
	oSet.AddExample([1.1,0.9], "near")
	oSet.AddExample([9,9], "far")
	oSet.AddExample([9.1,8.9], "far")
	oKnn = new stzKnn(oSet)
	oKnn.SetK(1)
	Then("a query near the origin is classified 'near'", oKnn.Classify([1.05,1]), "near")
	Then("...and one out at nine is 'far'", oKnn.Classify([8.9,9]), "far")
EndScenario()

Summary()

func Rnd9(n)
	return ceil(n * 1000000000 - 0.5) / 1000000000
