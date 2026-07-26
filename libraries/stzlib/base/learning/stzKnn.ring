# R4 step 0 -- stzKnn: THE FIRST LEARNER (highest intelligence-per-line)
# k-nearest-neighbours: ZERO training, FULLY explainable -- the purest
# LAW 3 classifier: Why() literally answers "the nearest examples
# were...". Rides stzSimilarity (Euclidean) + stzTrainingSet, exactly as
# they exist today (the R4 step-0 doctrine: no numeric blockers).
#
#   oK = new stzKnn(oTrainingSet)
#   oK.SetK(3)
#   ? oK.Classify([5.0, 3.4])   #--> "setosa"
#   ? oK.Why()

class stzKnn from stzObject

	@oDs = NULL
	@nK = 3
	@cWhy = ""

	def init(poDataset)
		@oDs = poDataset

	# THE HELD SET IS LIVE THROUGH HERE. Ring COPIES an object into an
	# attribute, so the set handed to the constructor is a SNAPSHOT: growing
	# the caller's own object afterwards would NOT reach this learner. Grow it
	# through this accessor -- oLearner.TrainingSetQ().AddExample(...) -- which
	# reaches the real held set (accessor + method call is live in Ring).
	def TrainingSetQ()
		return @oDs

	def SetK(n)
		if n >= 1
			@nK = n
		ok
		return This

	def K()
		return @nK

	def Classify(paFeatures)
		_aEx_ = @oDs.Examples()
		_nEx_ = len(_aEx_)
		if _nEx_ = 0
			stzraise("Can't classify: the dataset is empty.")
		ok
		_nTake_ = @nK
		if _nTake_ > _nEx_
			_nTake_ = _nEx_
		ok

		# K NEAREST, NOT N SORTED (numeric phase 5).
		#
		# This used to compute every distance and then INSERTION SORT ALL OF THEM,
		# to read the first K off the front. Insertion sort is O(N^2), and K is
		# three, or five, or ten -- the ordering of the other 9990 was computed and
		# thrown away. Profiled on 10000 examples of 16 dimensions, one query:
		#
		#     the distances themselves        0.032 s
		#     the full insertion sort        11.769 s
		#     the bounded selection below     0.003 s
		#
		# THE SORT WAS 99.7% OF A CLASSIFICATION, and 3900x the work that replaced
		# it. Classifying one point against ten thousand took 17.9 seconds; twenty
		# queries took 357. No suite noticed because the fixtures have six rows.
		#
		# @aTop is held sorted ascending and never grows past K. A candidate is
		# considered only if there is room or it beats the current worst, and it
		# walks left while the neighbour is STRICTLY greater -- so equal distances
		# keep the order they arrived in, exactly as the stable insertion sort did.
		# That matters: it is what decides the vote when the K-th and (K+1)-th
		# examples are the same distance away.
		_aTop_ = []
		for _i_ = 1 to _nEx_
			_nD_ = This._Dist(paFeatures, _aEx_[_i_][1])
			_nHave_ = len(_aTop_)
			if _nHave_ < _nTake_ or _nD_ < _aTop_[_nHave_][1]
				_p_ = _nHave_ + 1
				while _p_ > 1 and _aTop_[_p_ - 1][1] > _nD_
					_p_--
				end
				if _nHave_ < _nTake_
					_aTop_ + [ 0, "", 0 ]
					_nHave_++
				ok
				for _m_ = _nHave_ to _p_ + 1 step -1
					_aTop_[_m_] = _aTop_[_m_ - 1]
				next
				_aTop_[_p_] = [ _nD_, _aEx_[_i_][2], _i_ ]
			ok
		next

		# majority vote among the K nearest
		_aVotes_ = []
		_cNear_ = ""
		for _i_ = 1 to _nTake_
			_cL_ = _aTop_[_i_][2]
			if HasKey(_aVotes_, _cL_)
				_aVotes_[_cL_] = _aVotes_[_cL_] + 1
			else
				_aVotes_[_cL_] = 1
			ok
			if _cNear_ != ""
				_cNear_ += ", "
			ok
			_cNear_ += "#" + _aTop_[_i_][3] + " '" + _cL_ + "' (d=" +
				_aTop_[_i_][1] + ")"
		next

		_cBest_ = ""
		_nBest_ = -1
		_nV_ = len(_aVotes_)
		for _i_ = 1 to _nV_
			if _aVotes_[_i_][2] > _nBest_
				_nBest_ = _aVotes_[_i_][2]
				_cBest_ = _aVotes_[_i_][1]
			ok
		next

		@cWhy = "the " + _nTake_ + " nearest examples were: " + _cNear_ +
			" -- majority: '" + _cBest_ + "' (" + _nBest_ + "/" + _nTake_ + ")"
		$nStzLastCertainty = 1
		$cStzLastWhyB = @cWhy
		return _cBest_

	def Why()
		return @cWhy

	# ONE DEFINITION OF DISTANCE (phase 5 slice 3 of the numeric foundation).
	#
	# This was a hand-rolled Ring loop, byte-for-byte identical to the one in
	# stzKMeans. similarity.zig has had a vectorised, tested Euclidean distance since
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
