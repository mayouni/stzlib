# STZVECTORINDEX -- approximate nearest neighbours, with the loss measured.
#
# The last integration gap the numeric retro named: the library had exact k-NN
# (O(n) per query) and no vector index, so semantic search over a large corpus was
# not practical.
#
# -- WHAT AN APPROXIMATE INDEX HAS TO PROVE --
#
# An exact algorithm is judged on whether it is right. An approximate one is judged
# on HOW WRONG IT IS, which means a guard that only checks "it returned ten things"
# proves nothing at all. So this suite measures RECALL against the exact full scan --
# the fraction of the true nearest neighbours actually returned -- and pins the
# properties that make such a measurement meaningful:
#
#   * recall RISES WITH THE BUDGET, monotonically, and reaches 1.0 when the budget
#     covers the corpus (the approximate path degenerates to the exact one);
#   * more TREES give better recall at the same budget;
#   * the index is DETERMINISTIC given its seed, so a recall figure reproduces
#     instead of being a different number every run;
#   * every DISTANCE returned is exact and every ORDER is correct -- the trees only
#     nominate candidates, so the sole possible error is an omission.
#
# Everything below is run for real against the built library.

load "../../stzBase.ring"
load "../_narrated.ring"

decimals(6)

# a deterministic cloud, so every number in this file reproduces
aVecs = VixCloud(800, 16, 12345)
oIx = new stzVectorIndex(aVecs)

aQueries = []
for i = 1 to 20
	aQueries + aVecs[i * 7]
next

Scenario("What it returns is exact, even though WHICH it returns is approximate")
	Then("the corpus is indexed", oIx.Count(), 800)
	Then("...at the right width", oIx.Dimensions(), 16)

	# a stored vector must find ITSELF first, at distance zero. If an index cannot
	# do this it is not approximate, it is broken.
	aR = oIx.Search(aVecs[42], 5)
	Then("a stored vector finds itself first", aR[1][1], 42)
	Then("...at distance zero", VixNear(aR[1][2], 0), TRUE)

	# THE TREES ONLY NOMINATE. Every distance reported is recomputed exactly against
	# the stored vector, so the numbers are true distances and the order is a true
	# ordering -- the only error an approximate index can make here is leaving
	# someone out, never misreporting who it found.
	Then("every distance returned is the true distance",
	     VixDistancesExact(aVecs, aVecs[42], aR), TRUE)
	Then("...and they come back nearest-first", VixAscending(aR), TRUE)
EndScenario()

Scenario("RECALL IS MEASURED, and it rises with the budget")
	# The budget is the dial: how many candidates to examine before reranking.
	nLo = oIx.RecallAgainstExact(aQueries, 10, 30)
	nMid = oIx.RecallAgainstExact(aQueries, 10, 150)
	nHi = oIx.RecallAgainstExact(aQueries, 10, 400)
	nFull = oIx.RecallAgainstExact(aQueries, 10, 800)

	Then("a small budget already finds a third of the neighbours", nLo > 0.25, TRUE)
	Then("...a bigger one finds more", nMid > nLo, TRUE)
	Then("...and more still", nHi >= nMid, TRUE)

	# WHEN THE BUDGET COVERS THE CORPUS THE APPROXIMATION DISAPPEARS. This is the
	# anchor that makes the whole dial trustworthy: at the limit the structure
	# cannot miss anything, so a recall below 1.0 anywhere else is the budget
	# talking and not a defect in the search.
	Then("a budget covering the corpus misses nothing at all", VixNear(nFull, 1), TRUE)

	# and the loss at a small budget is a real loss, not a rounding artefact --
	# stated plainly so nobody mistakes this for an exact index
	Then("...while a small budget genuinely does miss some", nLo < 1, TRUE)
EndScenario()

Scenario("...and more trees beat fewer, at the same budget")
	# One tree loses whatever falls on the far side of its splitting planes.
	# Independent trees split differently, so a neighbour missed in one is usually
	# found in another. That is the entire reason this is a forest.
	oOne = new stzVectorIndex(aVecs)
	oOne.SetTrees(1)
	oMany = new stzVectorIndex(aVecs)
	oMany.SetTrees(16)

	nR1 = oOne.RecallAgainstExact(aQueries, 10, 150)
	nR16 = oMany.RecallAgainstExact(aQueries, 10, 150)
	Then("sixteen trees recall more than one", nR16 > nR1, TRUE)
	Then("...and one tree is still better than nothing", nR1 > 0.1, TRUE)
EndScenario()

Scenario("...and the same seed gives the same forest")
	# A RECALL FIGURE IS ONLY MEANINGFUL IF IT REPRODUCES. The forest is random, so
	# without a seed every run would report a different number and none of the
	# assertions above would mean anything.
	oA = new stzVectorIndex(aVecs)
	oA.SetSeed(99)
	oB = new stzVectorIndex(aVecs)
	oB.SetSeed(99)
	aRA = oA.SearchWithBudget(aVecs[100], 8, 60)
	aRB = oB.SearchWithBudget(aVecs[100], 8, 60)
	Then("two indexes with one seed answer identically", VixSameHits(aRA, aRB), TRUE)

	# a different seed may disagree about WHICH near neighbours it found, but its
	# distances are still exact and still ordered -- approximation changes the
	# selection, never the arithmetic
	oC = new stzVectorIndex(aVecs)
	oC.SetSeed(1234)
	aRC = oC.SearchWithBudget(aVecs[100], 8, 60)
	Then("...and a different seed is still internally exact",
	     VixDistancesExact(aVecs, aVecs[100], aRC) and VixAscending(aRC), TRUE)
EndScenario()

Scenario("Cosine compares DIRECTION, Euclidean compares POSITION")
	# Text embeddings are compared by direction: two documents about the same thing
	# point the same way, and one being "longer" is an artefact of how it was
	# encoded, not a difference in meaning.
	#
	# Vector 1 and vector 2 point the SAME WAY -- 2 is just ten times longer.
	aSmall = [ [1,0,0], [10,0,0], [0.9,0.9,0], [0,0,1] ]

	oEuc = new stzVectorIndex(aSmall)
	aE = oEuc.SearchExact([1,0,0], 2)
	Then("Euclidean picks the physically closest point", aE[1][1], 1)
	Then("...and passes over the long one in the same direction", aE[2][1], 3)

	oCos = new stzVectorIndex(aSmall)
	oCos.SetMetric(:Cosine)
	aC = oCos.SearchExact([1,0,0], 2)
	Then("cosine treats the long vector as a perfect match",
	     (aC[1][1] = 1 and aC[2][1] = 2) or (aC[1][1] = 2 and aC[2][1] = 1), TRUE)
	Then("...reading back a similarity of exactly 1",
	     VixNear(oCos.CosineFromDistance(aC[1][2]), 1), TRUE)

	# and the orthogonal vector is the least similar thing in the corpus
	aC4 = oCos.SearchExact([0,0,1], 1)
	Then("...while an orthogonal query finds the orthogonal vector", aC4[1][1], 4)
EndScenario()

Scenario("The awkward corpora do not break it")
	# asking for more neighbours than exist gives what exists, not an error
	oTiny = new stzVectorIndex([ [1,2], [3,4] ])
	Then("k larger than the corpus returns the whole corpus",
	     len(oTiny.Search([1,2], 10)), 2)

	# a single vector
	oOne = new stzVectorIndex([ [5,5] ])
	Then("a one-vector index answers with that vector", oOne.Search([9,9], 3)[1][1], 1)

	# MANY IDENTICAL VECTORS. Every splitting plane degenerates -- two sampled
	# points that coincide define no plane -- so the build has to terminate anyway
	# instead of recursing forever on a split that separates nothing.
	aDup = []
	for i = 1 to 200
		aDup + [7, 7]
	next
	oDup = new stzVectorIndex(aDup)
	aRD = oDup.Search([7,7], 3)
	Then("200 identical vectors still build and search", len(aRD), 3)
	Then("...all at distance zero", VixNear(aRD[1][2], 0) and VixNear(aRD[3][2], 0), TRUE)

	# and a ragged corpus is refused, with the offending row named
	Then("vectors of different widths are refused", VixRefusesRagged(), TRUE)
EndScenario()

Scenario("...and end to end: this is what semantic search looks like")
	# THE INTENDED CONSUMER. text/ has no embedding pipeline yet, so nothing in the
	# library is rewired onto this index today -- what follows is the usage pattern
	# it exists for, run for real.
	#
	# Four "documents" as vectors, two of them about the same thing (nearly parallel)
	# and two unrelated. A query close to the first pair must retrieve that pair.
	aDocs = [
		[ 0.90, 0.10, 0.05, 0.00 ],   # 1: topic A
		[ 0.88, 0.14, 0.02, 0.01 ],   # 2: topic A, phrased differently
		[ 0.05, 0.02, 0.91, 0.10 ],   # 3: topic B
		[ 0.00, 0.01, 0.08, 0.95 ]    # 4: topic C
	]
	oSearch = new stzVectorIndex(aDocs)
	oSearch.SetMetric(:Cosine)

	aHits = oSearch.Search([ 0.89, 0.12, 0.03, 0.00 ], 2)
	Then("a query on topic A retrieves both topic-A documents",
	     (aHits[1][1] = 1 or aHits[1][1] = 2) and (aHits[2][1] = 1 or aHits[2][1] = 2),
	     TRUE)
	Then("...and both are highly similar",
	     oSearch.CosineFromDistance(aHits[1][2]) > 0.99, TRUE)

	# a query on topic C must NOT retrieve topic A first -- the point of the index
	aHitC = oSearch.Search([ 0.00, 0.00, 0.10, 0.98 ], 1)
	Then("a query on topic C retrieves topic C", aHitC[1][1], 4)
EndScenario()

Summary()

#-- helpers (Vix-prefixed: short names collide with library globals) -----------

func VixNear(nX, nY)
	return fabs(nX - nY) < 0.000001

# a deterministic linear-congruential cloud: same seed, same corpus, every run
func VixCloud(nRows, nDim, nSeed)
	_vR_ = []
	_vS_ = nSeed
	for _vi_ = 1 to nRows
		_vRow_ = []
		for _vj_ = 1 to nDim
			_vS_ = (_vS_ * 1103515245 + 12345) % 2147483648
			_vRow_ + ((_vS_ % 2000) / 1000.0 - 1.0)
		next
		_vR_ + _vRow_
	next
	return _vR_

func VixSqDist(paA, paB)
	_vd_ = 0
	_vn_ = len(paA)
	for _vk_ = 1 to _vn_
		_vt_ = paA[_vk_] - paB[_vk_]
		_vd_ += _vt_ * _vt_
	next
	return _vd_

# every reported distance must equal the true distance to that vector
func VixDistancesExact(paCorpus, paQuery, paHits)
	_vn_ = len(paHits)
	for _vi_ = 1 to _vn_
		_vWant_ = VixSqDist(paQuery, paCorpus[paHits[_vi_][1]])
		if fabs(_vWant_ - paHits[_vi_][2]) > 0.0000001
			return FALSE
		ok
	next
	return TRUE

func VixAscending(paHits)
	_vn_ = len(paHits)
	for _vi_ = 2 to _vn_
		if paHits[_vi_][2] < paHits[_vi_ - 1][2]
			return FALSE
		ok
	next
	return TRUE

func VixSameHits(paA, paB)
	if len(paA) != len(paB)
		return FALSE
	ok
	_vn_ = len(paA)
	for _vi_ = 1 to _vn_
		if paA[_vi_][1] != paB[_vi_][1]
			return FALSE
		ok
	next
	return TRUE

func VixRefusesRagged()
	_vb_ = FALSE
	try
		_vo_ = new stzVectorIndex([ [1,2,3], [4,5] ])
		_vo_.Search([1,2,3], 1)
	catch
		_vb_ = TRUE
	done
	return _vb_
