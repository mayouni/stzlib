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

class stzKMeans from stzObject

	@aVecs = []
	@nK = 2
	@aCentroids = []
	@aAssign = []
	@nIterations = 0
	@cWhy = ""

	def init(paVectors)
		if isList(paVectors)
			_n_ = len(paVectors)
			for _i_ = 1 to _n_
				if isList(paVectors[_i_])
					@aVecs + paVectors[_i_]
				ok
			next
		ok

	def SetK(n)
		if n >= 1
			@nK = n
		ok
		return This

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
		_aFlat_ = []
		for _i_ = 1 to _nV_
			if len(@aVecs[_i_]) != _nDim_
				stzraise("Vector " + _i_ + " has " + len(@aVecs[_i_]) +
					" dimension(s) but the set is " + _nDim_ + " wide.")
			ok
			for _d_ = 1 to _nDim_
				_aFlat_ + @aVecs[_i_][_d_]
			next
		next

		_aRes_ = StzEngineKMeansRun(_aFlat_, _nV_, _nDim_, @nK, nMaxIter)
		if NOT isList(_aRes_) or len(_aRes_) < 2
			stzraise("The engine refused the run (" + _nV_ + " x " + _nDim_ + ").")
		ok

		@nIterations = _aRes_[1]
		_nSeeded_ = _aRes_[2]
		if _nSeeded_ < @nK
			stzraise("Not enough DISTINCT points to seed " + @nK + " clusters.")
		ok

		# [ iters, seeded, centroids (K x dim), assignments (N) ]
		@aCentroids = []
		_nAt_ = 2
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

	def Clusters()
		_aOut_ = []
		for _c_ = 1 to @nK
			_aG_ = []
			_n_ = len(@aAssign)
			for _i_ = 1 to _n_
				if @aAssign[_i_] = _c_
					_aG_ + _i_
				ok
			next
			_aOut_ + _aG_
		next
		return _aOut_

	def Centroids()
		return @aCentroids

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

	# total within-cluster squared distance -- the quality number
	def Inertia()
		_nS_ = 0
		_n_ = len(@aVecs)
		for _i_ = 1 to _n_
			if @aAssign[_i_] > 0
				_nD_ = This._Dist(@aVecs[_i_], @aCentroids[@aAssign[_i_]])
				_nS_ += _nD_ * _nD_
			ok
		next
		return _nS_

	def Iterations()
		return @nIterations

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
