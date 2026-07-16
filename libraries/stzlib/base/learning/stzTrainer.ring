# R4 step 3 -- stzTrainer: LOSS GOES DOWN, AND YOU CAN WATCH IT
# Stochastic gradient descent with backprop over stzNeuralNetwork,
# MSE loss, a recorded loss HISTORY (the training is accountable:
# Why() reports epochs, final loss, and the descent).
#
#   oTr = new stzTrainer()
#   oTr.SetLearningRate(0.5)
#   oTr.Train(oNN, aInputs, aTargets, 2000)   # oNN mutates IN PLACE
#   ? oTr.FinalLoss()  ? oTr.Why()
#
# ALIASING NOTE (the bug this shape avoids): storing the network in a
# trainer ATTRIBUTE copies it (Ring: attribute store copies objects) --
# training would perfect a private clone while the caller's network
# stayed untouched. PARAMS are by-reference, so the network arrives
# per-call and its AdoptLayers() write-back reaches the real object.

class stzTrainer from stzObject

	@nLr = 0.1
	@aLossHistory = []
	@nEpochs = 0
	@cWhy = ""

	def init()

	def SetLearningRate(n)
		if n > 0
			@nLr = n
		ok
		return This

	# paInputs = [ [x...] ... ], paTargets = [ [y...] ... ]
	def Train(poNet, paInputs, paTargets, nEpochs)
		_nN_ = len(paInputs)
		if _nN_ = 0 or len(paTargets) != _nN_
			stzraise("Inputs and targets must align (got " + _nN_ + " / " +
				len(paTargets) + ").")
		ok
		@aLossHistory = []
		_aLayers_ = poNet.Layers()
		_nL_ = len(_aLayers_)
		for _e_ = 1 to nEpochs
			_nLoss_ = 0
			for _s_ = 1 to _nN_
				# forward over the WORKING copy (Ring copies lists on
				# reads: @oNet._Forward would see frozen weights -- the
				# bug that froze XOR's loss at 0.26)
				_aFwd_ = This._ForwardLocal(poNet, _aLayers_, paInputs[_s_])
				_aActs_ = _aFwd_[:activations]
				_aZs_ = _aFwd_[:zs]
				_aOut_ = _aActs_[_nL_ + 1]
				_nO_ = len(_aOut_)
				# output delta by pairing:
				#  SOFTMAX + categorical cross-entropy -> delta = a - y,
				#    loss = -sum y*log(a) (multi-class; the clean gradient);
				#  SIGMOID + binary cross-entropy   -> delta = a - y,
				#    loss = squared error report (the a(1-a) MSE factor
				#    strangles gradients -- the constant-0.5 XOR saddle);
				#  anything else keeps the MSE derivative.
				_aDelta_ = []
				_cOutAct_ = _aLayers_[_nL_][2]
				for _o_ = 1 to _nO_
					_nErr_ = _aOut_[_o_] - paTargets[_s_][_o_]
					if _cOutAct_ = "softmax"
						if paTargets[_s_][_o_] > 0
							_nA_ = _aOut_[_o_]
							if _nA_ < 0.000000000001
								_nA_ = 0.000000000001
							ok
							_nLoss_ += -paTargets[_s_][_o_] * log(_nA_)
						ok
						_aDelta_ + _nErr_
					but _cOutAct_ = "sigmoid"
						_nLoss_ += _nErr_ * _nErr_
						_aDelta_ + _nErr_
					else
						_nLoss_ += _nErr_ * _nErr_
						_aDelta_ + ( _nErr_ * poNet._ActDeriv(_cOutAct_,
							_aZs_[_nL_][_o_], _aOut_[_o_]) )
					ok
				next
				# backwards through the layers
				for _l_ = _nL_ to 1 step -1
					_nU_ = _aLayers_[_l_][1]
					_aPrevA_ = _aActs_[_l_]
					_nP_ = len(_aPrevA_)
					# next layer's delta before touching weights
					_aNextDelta_ = []
					if _l_ > 1
						for _p_ = 1 to _nP_
							_nD_ = 0
							for _u_ = 1 to _nU_
								_nD_ += _aLayers_[_l_][3][_u_][_p_] * _aDelta_[_u_]
							next
							_nD_ *= poNet._ActDeriv(_aLayers_[_l_ - 1][2],
								_aZs_[_l_ - 1][_p_], _aActs_[_l_][_p_])
							_aNextDelta_ + _nD_
						next
					ok
					# SGD update
					for _u_ = 1 to _nU_
						for _p_ = 1 to _nP_
							_aLayers_[_l_][3][_u_][_p_] -= @nLr * _aDelta_[_u_] * _aPrevA_[_p_]
						next
						_aLayers_[_l_][4][_u_] -= @nLr * _aDelta_[_u_]
					next
					_aDelta_ = _aNextDelta_
				next
			next
			@aLossHistory + (_nLoss_ / _nN_)
		next
		# write the trained weights back into the network object
		poNet.AdoptLayers(_aLayers_)
		@nEpochs = nEpochs
		_nFirst_ = @aLossHistory[1]
		_nLast_ = @aLossHistory[len(@aLossHistory)]
		@cWhy = "trained " + nEpochs + " epoch(s), lr " + @nLr +
			": loss " + _nFirst_ + " -> " + _nLast_
		$cStzLastWhyB = @cWhy
		$nStzLastCertainty = 1
		return This

	# forward pass over a caller-held layer copy (same math as the
	# network's _Forward; activations via the network's _Act)
	def _ForwardLocal(poNet, paLayers, paInput)
		_aActs_ = []
		_aZs_ = []
		_aCur_ = paInput
		_aActs_ + _aCur_
		_nL_ = len(paLayers)
		for _l_ = 1 to _nL_
			_nU_ = paLayers[_l_][1]
			_cAct_ = paLayers[_l_][2]
			_aZ_ = []
			_aA_ = []
			for _u_ = 1 to _nU_
				_nZ_ = paLayers[_l_][4][_u_]
				_nP_ = len(_aCur_)
				for _p_ = 1 to _nP_
					_nZ_ += paLayers[_l_][3][_u_][_p_] * _aCur_[_p_]
				next
				_aZ_ + _nZ_
				_aA_ + poNet._Act(_cAct_, _nZ_)
			next
			if _cAct_ = "softmax"
				_aA_ = poNet._Softmax(_aZ_)
			ok
			_aZs_ + _aZ_
			_aActs_ + _aA_
			_aCur_ = _aA_
		next
		return [ :activations = _aActs_, :zs = _aZs_ ]

	def LossHistory()
		return @aLossHistory

	def FinalLoss()
		if len(@aLossHistory) = 0
			return 0
		ok
		return @aLossHistory[len(@aLossHistory)]

	def Why()
		return @cWhy
