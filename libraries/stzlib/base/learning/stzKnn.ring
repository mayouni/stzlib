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
		# distance to every example (N-dim Euclidean; the engine
		# stzSimilarity list form is 3-bound today -- engine backlog)
		_aScored_ = []
		for _i_ = 1 to _nEx_
			_nD_ = This._Dist(paFeatures, _aEx_[_i_][1])
			_aScored_ + [ _nD_, _aEx_[_i_][2], _i_ ]
		next

		# insertion sort ascending by distance
		for _i_ = 2 to _nEx_
			_aE_ = _aScored_[_i_]
			_j_ = _i_ - 1
			while _j_ >= 1
				if _aScored_[_j_][1] > _aE_[1]
					_aScored_[_j_ + 1] = _aScored_[_j_]
					_j_--
				else
					exit
				ok
			end
			_aScored_[_j_ + 1] = _aE_
		next

		# majority vote among the K nearest
		_nTake_ = @nK
		if _nTake_ > _nEx_
			_nTake_ = _nEx_
		ok
		_aVotes_ = []
		_cNear_ = ""
		for _i_ = 1 to _nTake_
			_cL_ = _aScored_[_i_][2]
			if HasKey(_aVotes_, _cL_)
				_aVotes_[_cL_] = _aVotes_[_cL_] + 1
			else
				_aVotes_[_cL_] = 1
			ok
			if _cNear_ != ""
				_cNear_ += ", "
			ok
			_cNear_ += "#" + _aScored_[_i_][3] + " '" + _cL_ + "' (d=" +
				_aScored_[_i_][1] + ")"
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
