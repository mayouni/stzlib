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

	def _Dist(paA, paB)
		_n_ = len(paA)
		if len(paB) < _n_
			_n_ = len(paB)
		ok
		_nS_ = 0
		for _i_ = 1 to _n_
			_nD_ = paA[_i_] - paB[_i_]
			_nS_ += _nD_ * _nD_
		next
		return sqrt(_nS_)
