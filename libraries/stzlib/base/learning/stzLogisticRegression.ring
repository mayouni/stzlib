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
