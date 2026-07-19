# R4 step 3 -- stzLogisticRegression: THE FIRST GRADIENT-TRAINED MODEL
# Binary logistic regression by batch gradient descent -- the floor's
# door into trainable models (the trainer doctrine in miniature:
# epochs, learning rate, a loss that goes DOWN). Deterministic: zero
# weight init, fixed order -- reproducible runs (LAW 3).
#
#   oLR = new stzLogisticRegression(oTrainingSet)   # 2 labels exactly
#   oLR.SetLearningRate(0.5)
#   oLR.Train(200)
#   ? oLR.Classify([1, 0])   ? oLR.Probability([1, 0])   ? oLR.Why()

class stzLogisticRegression from stzObject

	@oTs = NULL
	@aW = []
	@nB = 0
	@nLr = 0.1
	@acLabels = []
	@nEpochs = 0
	@cWhy = ""
	@bTrained = 0

	def init(poTrainingSet)
		@oTs = poTrainingSet
		@acLabels = @oTs.Labels()
		if len(@acLabels) != 2
			stzraise("Binary logistic regression needs exactly 2 labels (got " +
				len(@acLabels) + ").")
		ok

	# THE HELD SET IS LIVE THROUGH HERE. Ring COPIES an object into an
	# attribute, so the set handed to the constructor is a SNAPSHOT: growing
	# the caller's own object afterwards would NOT reach this learner. Grow it
	# through this accessor -- oLearner.TrainingSetQ().AddExample(...) -- which
	# reaches the real held set (accessor + method call is live in Ring).
	def TrainingSetQ()
		return @oTs

	def SetLearningRate(n)
		if n > 0
			@nLr = n
		ok
		return This

	def Train(nEpochs)
		_aEx_ = @oTs.Examples()
		_nEx_ = len(_aEx_)
		_nF_ = @oTs.NumberOfFeatures()
		@aW = []
		for _i_ = 1 to _nF_
			@aW + 0
		next
		@nB = 0
		for _e_ = 1 to nEpochs
			for _i_ = 1 to _nEx_
				_nY_ = 0
				if _aEx_[_i_][2] = @acLabels[2]
					_nY_ = 1
				ok
				_nP_ = This._Sigmoid(This._Score(_aEx_[_i_][1]))
				_nErr_ = _nY_ - _nP_
				for _f_ = 1 to _nF_
					@aW[_f_] += @nLr * _nErr_ * _aEx_[_i_][1][_f_]
				next
				@nB += @nLr * _nErr_
			next
		next
		@nEpochs = nEpochs
		@bTrained = 1
		return This

	def Probability(paFeatures)
		if @bTrained = 0
			stzraise("Train() me first.")
		ok
		return This._Sigmoid(This._Score(paFeatures))

	def Classify(paFeatures)
		_nP_ = This.Probability(paFeatures)
		_cOut_ = @acLabels[1]
		if _nP_ >= 0.5
			_cOut_ = @acLabels[2]
		ok
		@cWhy = "P('" + @acLabels[2] + "') = " + _nP_ + " after " + @nEpochs +
			" epoch(s) -> '" + _cOut_ + "' (weights " + @@(@aW) + ", bias " + @nB + ")"
		$cStzLastWhyB = @cWhy
		$nStzLastCertainty = 1
		return _cOut_

	def Weights()
		return @aW

	def Bias()
		return @nB

	# How well the model fits the data it was TRAINED on.
	#
	# This exists because the way this class fails is SILENT and CONFIDENT.
	# Gradient descent on UNSCALED features diverges: with values in the tens
	# of thousands and the default learning rate, each weight update is
	# thousands wide, the sigmoid saturates, and the model settles on a
	# confidently WRONG answer -- Probability() returns exactly 1 or 0, which
	# reads as certainty. Measured on identical data: features 1000..79000
	# gave weights [5350, 5350] and misclassified a training-range point,
	# while the SAME data scaled to 0..1 gave weights [8.06, 8.06] and
	# answered correctly.
	#
	# Needing standardised features is the normal requirement for stochastic
	# gradient descent, not a defect here -- but nothing surfaced the failure.
	# This does: a diverged model scores around chance on data it has already
	# seen, where a converged one scores near 1.
	def TrainingAccuracy()
		if NOT @bTrained
			return 0
		ok

		_aTaEx_ = @oTs.Examples()
		_nTaLen_ = len(_aTaEx_)

		if _nTaLen_ = 0
			return 0
		ok

		_acTaPred_ = []
		_acTaTruth_ = []

		for _iTa_ = 1 to _nTaLen_
			_acTaPred_ + This.Classify(_aTaEx_[_iTa_][1])
			_acTaTruth_ + _aTaEx_[_iTa_][2]
		next

		return StzAccuracy(_acTaPred_, _acTaTruth_)

	def Why()
		return @cWhy

	def _Score(paFeatures)
		_nZ_ = @nB
		_nF_ = len(@aW)
		for _i_ = 1 to _nF_
			_nZ_ += @aW[_i_] * paFeatures[_i_]
		next
		return _nZ_

	def _Sigmoid(nZ)
		if nZ > 35
			return 1
		ok
		if nZ < -35
			return 0
		ok
		return 1 / (1 + exp(-nZ))
