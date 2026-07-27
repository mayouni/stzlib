load "../../stzBase.ring"
load "../_narrated.ring"

# K NEAREST, NOT N SORTED (numeric phase 5).
#
# The plan's line for this phase reads "clustering / KNN / logistic / trees -> engine,
# over resident buffers -- these are the classic distance-and-reduce kernels that SIMD
# and threads were made for". So KNN was measured with that in mind, expecting the
# distance computation to be the thing worth moving.
#
# It was not. Classifying ONE point against ten thousand examples took 17.9 seconds,
# and twenty queries took 357. Split at 10000 examples of 16 dimensions:
#
#     the distances themselves        0.032 s
#     the full insertion sort        11.769 s
#     a bounded K=5 selection         0.003 s
#
# THE DISTANCES WERE 0.3% OF IT. Classify() computed every distance -- fine, that is
# what KNN is -- and then INSERTION SORTED ALL TEN THOUSAND to read the first five off
# the front. Insertion sort is O(N^2). The complete ordering of the other 9995 was
# computed and discarded, and it cost 3900 times what finding the five costs.
#
# Fixing that in Ring took twenty queries from 357.753 s to 1.173 s. AND THAT WAS THE
# WRONG PLACE TO STOP -- correct complexity in an interpreter is still an interpreter.
# The rest of this file records what the second pass found, which is that the bridge,
# not the arithmetic, was everything that remained. Four measurements, same algorithm:
#
#     one distance per crossing, sorting all N        357.753 s
#     one distance per crossing, bounded selection      1.173 s
#     whole matrix marshalled inside every query        2.254 s   <-- WORSE
#     matrix flattened once, re-sent per query          0.679 s
#     matrix RESIDENT, query crosses alone              0.630 s
#     ...and Examples() off the hot path                0.085 s
#
# THREE OF THOSE STEPS WERE ME GUESSING WRONG. Sending the whole matrix per query is
# the right shape and made it worse, because 160000 list appends now happened per
# query for data that never changes. Making the dataset resident -- phase 3's keystone
# -- barely moved it, because that was not the cost either. The cost was
# `@oDs.Examples()`: RING COPIES A LIST WHEN A METHOD RETURNS IT, so asking the
# dataset for its examples handed back all ten thousand rows on every single query.
# 0.581 s of a 0.598 s run: 97% of what was left, in a line that looks like an
# accessor. Each step was measured rather than reasoned about, and each time the
# reasoning had been wrong.
#
#     2000 examples x 8 dim, 20 queries      15.018 s  ->  0.012 s    1250x
#     10000 examples x 16 dim, 20 queries   357.753 s  ->  0.085 s    4200x
#
# WHY NO SUITE CAUGHT IT: every KNN fixture in this library has about six rows, where
# N^2 and N*K are the same number. A quadratic is invisible until it is enormous, and
# the fixtures were chosen to be readable.
#
# THE TIE RULE IS THE DELICATE PART, and it is why the scenarios below spend most of
# their assertions on ties rather than on speed. The old code was a STABLE insertion
# sort: it shifted only while the neighbour was STRICTLY greater, so examples at equal
# distance kept the order they appeared in the training set, and that order decided
# the vote whenever the K-th and (K+1)-th neighbours were equidistant. The bounded
# selection walks left under the same strict comparison and rejects a candidate that
# merely EQUALS the current worst -- which is the same decision the stable sort made,
# reached without ordering anything else. Checked by dumping every verdict, neighbour
# list, index and distance for k = 1..8 on a set built entirely out of ties, plus
# k > N, plus 120 classifications over a larger set, and diffing. The diff was empty.

Scenario("the answer is the same answer, tie for tie")
	# Twelve points around the origin, with DELIBERATE duplicates: [1,0] appears
	# twice as "b" and [0,1] twice as "c", so the 2nd through 5th neighbours of the
	# origin are all at distance 1 and the vote depends entirely on the tie rule.
	aTied = [
		[ [0,0], "a" ], [ [1,0], "b" ], [ [0,1], "c" ], [ [-1,0], "d" ],
		[ [0,-1], "e" ], [ [1,0], "b" ], [ [0,1], "c" ], [ [2,0], "f" ],
		[ [0,2], "g" ], [ [1,1], "h" ], [ [-1,-1], "i" ], [ [1,-1], "j" ] ]

	Then("k=1 finds the exact point", VerdictAt(aTied, 1), "a")
	# at k=5 the four tied neighbours are b, c, d, e -- one vote each -- and 'a' at
	# distance 0 breaks it, because first-seen order puts it first
	Then("k=5 lands on the nearest of a five-way split", VerdictAt(aTied, 5), "a")
	Then("k=3 too", VerdictAt(aTied, 3), "a")
	# and at k=8 it flips to 'b', because 'b' is now in the window TWICE (examples
	# #2 and #6 are both [1,0]) while 'a' is there once -- 2/8 beats 1/8. Worth
	# pinning precisely because it is the counter-intuitive one: widening k moved
	# the answer AWAY from the exact match. Verified against the pre-change
	# implementation, which answers 'b' here too.
	Then("k=8 flips to the duplicated neighbour, 2 votes against 1",
	     VerdictAt(aTied, 8), "b")
	Then("...and says so", StzFindFirst("'b' (2/8)", WhyAt(aTied, 8)) > 0, TRUE)

	# the neighbour list is the real evidence: same members, same order, same
	# distances, same original indices
	Then("the nearest is example #1 at distance 0",
	     StzFindFirst("#1 'a' (d=0", WhyAt(aTied, 5)) > 0, TRUE)
	Then("...then the tied ones in the order they were given",
	     StzFindFirst("#2 'b'", WhyAt(aTied, 5)) > 0, TRUE)
	Then("...#3 before #4", StzFindFirst("#3 'c'", WhyAt(aTied, 5)) > 0, TRUE)
	Then("...and the vote is reported as a fraction of k",
	     StzFindFirst("/5)", WhyAt(aTied, 5)) > 0, TRUE)
EndScenario()

Scenario("the edges the bounded form could have broken")
	# k larger than the whole set: the old code sorted N and took min(k, N).
	oSmall = new stzTrainingSet([ [ [1], "x" ], [ [2], "y" ] ])
	oK = new stzKnn(oSmall)
	oK.SetK(99)
	Then("k > N still answers", oK.Classify([1.4]), "x")
	Then("...using every example there is", StzFindFirst("the 2 nearest", oK.Why()) > 0, TRUE)

	# a single example
	oOne = new stzTrainingSet([ [ [5,5], "only" ] ])
	oK1 = new stzKnn(oOne)
	oK1.SetK(3)
	Then("one example is the answer", oK1.Classify([0,0]), "only")

	# an empty set must still refuse
	Then("an empty dataset refuses", RaisesEmpty(), TRUE)

	# the FARTHEST point must never win: the guard that rejects a candidate equal
	# to the current worst is the one that could have let this through
	oFar = new stzTrainingSet([
		[ [0,0], "near" ], [ [0.1,0], "near" ], [ [100,100], "far" ] ])
	oKf = new stzKnn(oFar)
	oKf.SetK(2)
	Then("the far point is not in the top 2", StzFindFirst("'far'", WhyOf(oKf, [0,0])) = 0, TRUE)
	Then("...and does not win", oKf.Classify([0,0]), "near")
EndScenario()

Scenario("...and it is no longer quadratic")
	# Deliberately loose: the thresholds are many times the measured values, so this
	# fails when the sort comes back, not because a machine is busy.
	aBig = []
	for i = 1 to 4000
		v = []
		s = 0
		for d = 1 to 8
			x = ((i * 37 + d * 11) % 100) / 100
			v + x
			s += x
		next
		cL = "lo"
		if s > 4
			cL = "hi"
		ok
		aBig + [ v, cL ]
	next
	oTs = new stzTrainingSet(aBig)
	oK = new stzKnn(oTs)
	oK.SetK(5)
	q = []
	for d = 1 to 8
		q + 0.5
	next

	t0 = clock()
	for r = 1 to 10
		v = oK.Classify(q)
	next
	nT = (clock() - t0) / clockspersecond()
	Then("10 queries over 4000 examples in under 5s -- it was ~60", nT < 5, TRUE)
	Then("...and the answer is still a real label",
	     v = "lo" or v = "hi", TRUE)

	# GROWTH IS THE POINT, not the absolute number: doubling N must roughly double
	# the work, not quadruple it. A quadratic would show up here as a ratio near 4.
	aHalf = []
	for i = 1 to 2000
		aHalf + aBig[i]
	next
	oTs2 = new stzTrainingSet(aHalf)
	oK2 = new stzKnn(oTs2)
	oK2.SetK(5)
	t0 = clock()
	for r = 1 to 10
		v = oK2.Classify(q)
	next
	nH = (clock() - t0) / clockspersecond()
	Then("halving N roughly halves the time -- not quarters it",
	     nH = 0 or (nT / nH) < 3, TRUE)
EndScenario()

Scenario("k-means runs entirely in the engine now")
	# First pass left this alone -- no ordering anywhere, so it was not in KNN's
	# trouble -- but it had the same bridge problem: This._Dist() once per (point,
	# centroid, iteration), which is N*K*iters crossings to do a few subtractions
	# each. cluster.kmeansRun does seeding, every assignment pass and every centroid
	# update behind ONE call: 10000 x 16 into 5 clusters, 0.985 s -> 0.076 s.
	#
	# It makes the same decisions, and they are decisions rather than details: the
	# first K DISTINCT points seed it (no randomness -- two runs agree), a point
	# equidistant from two centroids goes to the LOWER-numbered one, an empty
	# cluster keeps its centroid, and convergence is still "no assignment changed"
	# checked before the update, so the iteration count is unchanged. Verified by
	# diffing centroids to ten decimals, cluster memberships, inertia, iteration
	# counts, truncated maxIter runs and both refusal messages against the Ring
	# implementation. The diff was empty.
	aV = []
	for i = 1 to 3000
		v = []
		for d = 1 to 8
			v + (((i * 37 + d * 11) % 100) / 100)
		next
		aV + v
	next
	oKm = new stzKMeans(aV)
	oKm.SetK(4)
	t0 = clock()
	oKm.Run(20)
	nKm = (clock() - t0) / clockspersecond()

	Then("3000 points cluster in under 5s", nKm < 5, TRUE)
	Then("every point is assigned", len(oKm.Clusters()), 4)
	Then("...and the assignment covers the set", TotalIn(oKm.Clusters()), 3000)
	Then("centroids have the data's dimension", len(oKm.Centroids()[1]), 8)
	Then("...and it says how it converged",
	     StzFindFirst("converged in", oKm.Why()) > 0, TRUE)
EndScenario()

Summary()

func VerdictAt(aD, k)
	oT = new stzTrainingSet(aD)
	o = new stzKnn(oT)
	o.SetK(k)
	return o.Classify([0,0])

func WhyAt(aD, k)
	oT = new stzTrainingSet(aD)
	o = new stzKnn(oT)
	o.SetK(k)
	o.Classify([0,0])
	return o.Why()

func WhyOf(o, aQ)
	o.Classify(aQ)
	return o.Why()

func RaisesEmpty()
	b = FALSE
	try
		oT = new stzTrainingSet([])
		o = new stzKnn(oT)
		o.SetK(3)
		v = o.Classify([1,2])
	catch
		b = TRUE
	done
	return b

func TotalIn(aClusters)
	n = 0
	for i = 1 to len(aClusters)
		n += len(aClusters[i])
	next
	return n
