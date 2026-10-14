# R4 step 3 -- stzKMeans: THE UNSUPERVISED WIN (post matrix-hygiene)
# Lloyd's k-means over numeric vectors. DETERMINISTIC by design
# (LAW 3): centroids seed from the first K distinct points, so two
# runs agree -- shuffle upstream if you want randomized restarts.
#
#   oKM = new stzKMeans([ [1,1], [1.2,0.9], [8,8], [7.9,8.1] ])
#   oKM.SetK(2)
#   oKM.Run(50)
#   ? oKM.Clusters()      # index groups
#   ? oKM.Centroids()
#   ? oKM.ClusterOf([7.5, 8.0])

# Groups numeric vectors into k clusters by Lloyd's k-means, deterministically, with the whole run done in the engine.
#
# Centroids are seeded from the first k distinct points, so two runs agree and nothing is random;
# shuffle the vectors upstream for randomised restarts. Each iteration assigns every point to its
# nearest centroid and moves the centroids, stopping when no assignment changes or the iteration
# limit is reached. An empty cluster keeps its centroid. Because the seeding is fixed, an unlucky
# order can settle in a poor local minimum, which Inertia shows.
#
#   receiver   o1 = new stzKMeans([ [1, 1], [1.2, 0.9], [8, 8], [7.9, 8.1] ])
#   example    o1.SetK(2)
#              o1.Run(50)
#              ? @@( o1.Clusters() )
#              #--> [ [ 1, 2 ], [ 3, 4 ] ]
#              ? o1.ClusterOf([ 7.5, 8.0 ])
#              #--> 2
#              ? o1.Iterations()
#              #--> 3
#   see        stzKnn, stzTrainingSet
class stzKMeans from stzObject

	@aVecs = []
	@nK = 2
	@aCentroids = []
	@aAssign = []
	@nIterations = 0
	@nInertia = 0
	@cWhy = ""

	# Builds a clusterer over a list of numeric vectors; the number of clusters defaults to 2.
	#
	#   paVectors   a list of lists of numbers
	#   returns     nothing; the object is built
	#   see         SetK, Run
	def init(paVectors)
		if isList(paVectors)
			_n_ = len(paVectors)
			for _i_ = 1 to _n_
				if isList(paVectors[_i_])
					@aVecs + paVectors[_i_]
				ok
			next
		ok

	# Sets how many clusters to find.
	#
	#   n          the number of clusters, 1 or more
	#   returns    the clusterer itself, so calls chain
	#   note       a value below 1 is ignored without a message and the earlier value stays
	#   see        Run
	def SetK(n)
		if n >= 1
			@nK = n
		ok
		return This

	# Computes the clusters by Lloyd's k-means, seeding the centroids with the first k distinct points, and stops when no assignment changes.
	#
	#   nMaxIter   the most iterations allowed
	#   returns    the clusterer itself, so calls chain
	#   note       deterministic: two runs on the same data agree, and a point equidistant from two
	#              centroids goes to the lower-numbered one; with a poor seed the result can be a
	#              poor local minimum
	#   warning    raises an error when there are fewer vectors than clusters, when the vectors
	#              differ in width, or when there are fewer distinct points than clusters
	#   see        Clusters, Centroids, Inertia
	def Run(nMaxIter)
		_nV_ = len(@aVecs)
		if _nV_ < @nK
			stzraise("Fewer vectors (" + _nV_ + ") than clusters (" + @nK + ").")
		ok

		# THE WHOLE RUN IN ONE CROSSING (numeric phase 5, second pass).
		#
		# What was here: a seeding scan, then per iteration an assignment pass and a
		# centroid update, with This._Dist() called once per (point, centroid). Since
		# phase 5 slice 3 that distance is the engine's -- which was right for having
		# ONE definition, and wrong for the loop around it, because each call
		# marshalled two vectors across the bridge to do a handful of subtractions.
		# The crossings, not the arithmetic, were the cost: N x K per iteration.
		#
		# cluster.zig now runs seeding, every assignment pass and every centroid
		# update behind a single call, and it makes the SAME decisions:
		#
		#   * seeding is still the first K DISTINCT points in input order -- no
		#     randomness, so two runs on the same data agree, which this library
		#     treats as a law rather than a nicety;
		#   * a point equidistant from two centroids still goes to the LOWER-numbered
		#     one, because the comparison is still strict `<`;
		#   * an EMPTY cluster still keeps its centroid rather than being re-seeded;
		#   * convergence is still "no assignment changed", checked before the update,
		#     so the reported iteration count is unchanged.
		#
		# Measured, 10000 points x 16 dimensions into 5 clusters: 0.985 s -> 0.031 s.
		_nDim_ = len(@aVecs[1])
		for _i_ = 1 to _nV_
			if len(@aVecs[_i_]) != _nDim_
				stzraise("Vector " + _i_ + " has " + len(@aVecs[_i_]) +
					" dimension(s) but the set is " + _nDim_ + " wide.")
			ok
		next

		# THE FLATTENING TAX (2026-09-10). The rows used to be appended one number
		# at a time into a flat list before the call -- 5,120,000 appends at
		# 20,000 x 256, 1.2 s of a 1.4 s call whose engine part was 0.23 s. The
		# bridge walks the rows itself now; the vectors go as they are.
		_aRes_ = StzEngineKMeansRun(@aVecs, _nV_, _nDim_, @nK, nMaxIter)
		if NOT isList(_aRes_) or len(_aRes_) < 3
			stzraise("The engine refused the run (" + _nV_ + " x " + _nDim_ + ").")
		ok

		@nIterations = _aRes_[1]
		_nSeeded_ = _aRes_[2]
		if _nSeeded_ < @nK
			stzraise("Not enough DISTINCT points to seed " + @nK + " clusters.")
		ok
		# the inertia comes back with the run: it used to be one bridge crossing
		# per point (StzEngineSimEuclidean), 20,000 of them at 20,000 points
		@nInertia = _aRes_[3]

		# [ iters, seeded, inertia, centroids (K x dim), assignments (N) ]
		@aCentroids = []
		_nAt_ = 3
		for _c_ = 1 to @nK
			_aC_ = []
			for _d_ = 1 to _nDim_
				_nAt_++
				_aC_ + _aRes_[_nAt_]
			next
			@aCentroids + _aC_
		next
		@aAssign = []
		for _i_ = 1 to _nV_
			_nAt_++
			@aAssign + _aRes_[_nAt_]
		next

		@cWhy = "converged in " + @nIterations + " iteration(s); inertia " +
			This.Inertia()
		$cStzLastWhyB = @cWhy
		$nStzLastCertainty = 1
		return This

	# Returns the members of each cluster, as positions in the input list.
	#
	#   returns    a list with one list of numbers per cluster; empty lists before Run
	#   see        Centroids, ClusterOf
	#@ aka  one pass over the assignments, not one per cluster: k scans of n were 1.28 M steps at 20,000 points into 64 (256 ms); one scan is 20,000
	def Clusters()
		_aOut_ = []
		for _c_ = 1 to @nK
			_aOut_ + []
		next
		_n_ = len(@aAssign)
		for _i_ = 1 to _n_
			_c_ = @aAssign[_i_]
			if _c_ > 0
				_aOut_[_c_] + _i_
			ok
		next
		return _aOut_

	# Returns the centre of each cluster.
	#
	#   returns    a list of vectors, one per cluster; empty before Run
	#   see        Clusters, ClusterOf
	def Centroids()
		return @aCentroids

	# Returns the number of the nearest cluster for a new vector, by Euclidean distance to the centroids.
	#
	#   paVector   the vector to place
	#   returns    a number from 1 to k
	#   note       a vector shorter or longer than the centroids is compared over their common
	#              length
	#   warning    raises an error telling to call Run first
	#   see        Centroids, Run
	def ClusterOf(paVector)
		if len(@aCentroids) = 0
			stzraise("Run() me first.")
		ok
		_nBest_ = 1
		_nBD_ = This._Dist(paVector, @aCentroids[1])
		for _c_ = 2 to @nK
			_nD_ = This._Dist(paVector, @aCentroids[_c_])
			if _nD_ < _nBD_
				_nBD_ = _nD_
				_nBest_ = _c_
			ok
		next
		return _nBest_

	# Returns the total squared distance of the points to their centroids, the quality number of the run.
	#
	#   returns    a number; 0 before Run
	#   see        Iterations, Why
	#@ aka  total within-cluster squared distance -- the quality number, computed by the engine at the end of the run over the same distance (cluster.zig)
	def Inertia()
		return @nInertia

	# Returns how many iterations the last Run took.
	#
	#   returns    a number
	#   see        Run, Inertia
	def Iterations()
		return @nIterations

	# Returns a sentence saying how the last Run ended, with the iteration count and the inertia.
	#
	#   returns    a text; empty before Run
	#   see        Iterations, Inertia
	def Why()
		return @cWhy

	# ONE DEFINITION OF DISTANCE (phase 5 slice 3 of the numeric foundation).
	#
	# This was a hand-rolled Ring loop, and stzKnn had a second copy of the same
	# loop. similarity.zig has had a vectorised, tested Euclidean distance since
	# phase 4 slice 6, so there were three. That is the shape this plan keeps
	# finding -- the variance divisor, the summation, the centered sum of squares,
	# the negligible threshold -- and the cure is always the same: ask the one
	# authority.
	#
	# MEASURED, since phase 3 established that a one-shot engine call is no faster
	# than Ring when marshalling dominates. Here it is not close:
	#
	#     N x dims       ring loop    engine call
	#     1000 x 8        0.001s       0s
	#     5000 x 16       0.015s       0.002s
	#     20000 x 32      0.111s       0.014s      8x
	#
	# Marshalling 32 doubles is cheaper than 32 interpreted loop steps, so the
	# crossing pays for itself even per point. Below a few thousand points both are
	# free -- the authority argument alone would justify this; the speed is a bonus.
	#
	# THE RAGGED CASE IS KEPT DELIBERATELY. This loop truncated to the shorter
	# vector, and nothing validates vector lengths on the way in, so that truncation
	# is load-bearing rather than decorative. The engine bridge REFUSES a length
	# mismatch and answers 0 -- which here would read as "these points are
	# identical", the worst possible wrong answer. So the common case (equal
	# lengths) goes straight through, and the ragged case slices first, preserving
	# the old behaviour exactly.
	def _Dist(paA, paB)
		_nA_ = len(paA)
		_nB_ = len(paB)

		if _nA_ = _nB_
			return StzEngineSimEuclidean(paA, paB)
		ok

		# ragged: compare over the common prefix, as this method always has
		_n_ = _nA_
		if _nB_ < _n_
			_n_ = _nB_
		ok
		_aTA_ = []
		_aTB_ = []
		for _iDs_ = 1 to _n_
			_aTA_ + paA[_iDs_]
			_aTB_ + paB[_iDs_]
		next
		return StzEngineSimEuclidean(_aTA_, _aTB_)
