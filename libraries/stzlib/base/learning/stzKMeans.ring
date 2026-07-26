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

		# deterministic seeding: the first K DISTINCT points
		@aCentroids = []
		for _i_ = 1 to _nV_
			if len(@aCentroids) >= @nK
				exit
			ok
			_bDup_ = 0
			_nC_ = len(@aCentroids)
			for _c_ = 1 to _nC_
				if This._Dist(@aVecs[_i_], @aCentroids[_c_]) = 0
					_bDup_ = 1
					exit
				ok
			next
			if _bDup_ = 0
				_aCopy_ = @aVecs[_i_]
				@aCentroids + _aCopy_
			ok
		next
		if len(@aCentroids) < @nK
			stzraise("Not enough DISTINCT points to seed " + @nK + " clusters.")
		ok

		@aAssign = []
		for _i_ = 1 to _nV_
			@aAssign + 0
		next

		@nIterations = 0
		for _it_ = 1 to nMaxIter
			@nIterations = _it_
			# assign
			_bChanged_ = 0
			for _i_ = 1 to _nV_
				_nBest_ = 1
				_nBD_ = This._Dist(@aVecs[_i_], @aCentroids[1])
				for _c_ = 2 to @nK
					_nD_ = This._Dist(@aVecs[_i_], @aCentroids[_c_])
					if _nD_ < _nBD_
						_nBD_ = _nD_
						_nBest_ = _c_
					ok
				next
				if @aAssign[_i_] != _nBest_
					@aAssign[_i_] = _nBest_
					_bChanged_ = 1
				ok
			next
			if _bChanged_ = 0
				exit
			ok
			# update
			_nDim_ = len(@aVecs[1])
			for _c_ = 1 to @nK
				_aSum_ = []
				for _d_ = 1 to _nDim_
					_aSum_ + 0
				next
				_nIn_ = 0
				for _i_ = 1 to _nV_
					if @aAssign[_i_] = _c_
						_nIn_++
						for _d_ = 1 to _nDim_
							_aSum_[_d_] += @aVecs[_i_][_d_]
						next
					ok
				next
				if _nIn_ > 0
					for _d_ = 1 to _nDim_
						_aSum_[_d_] /= _nIn_
					next
					@aCentroids[_c_] = _aSum_
				ok
			next
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
