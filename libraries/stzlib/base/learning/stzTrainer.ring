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
	# THE TRAINING LOOP RUNS IN THE ENGINE (numeric phase 6, slice 3).
	#
	# The plan's line for this phase says "rewire the trainer and logistic
	# regression to use gradients rather than hand-derived updates". The
	# measurement says otherwise, so this does something else and records why:
	#
	#   1. THE HAND-DERIVED GRADIENTS WERE ALREADY EXACT. Slice 1's autodiff tape
	#      was used to check them -- the honest use of an autodiff -- and on a
	#      1-tanh-1-sigmoid network the two agree to eight decimals on every
	#      weight. There was no correctness debt here to pay off.
	#   2. A TAPE IS SLOWER THAN DERIVED CODE FOR A FIXED ARCHITECTURE. Reverse
	#      mode earns its overhead when the expression is arbitrary; a dense MLP
	#      is not, and its derivative is known in closed form.
	#   3. IT WOULD HAVE CHANGED THE ANSWERS. This trainer minimises binary
	#      cross-entropy for a sigmoid output while REPORTING squared error (see
	#      the delta rules below, kept verbatim in nn.zig). Rebuilding it around
	#      "the gradient of the reported loss" reintroduces the a(1-a) factor that
	#      the original comment records as strangling gradients into the
	#      constant-0.5 XOR saddle.
	#
	# So the tape stays where it belongs -- arbitrary objectives and L-BFGS -- and
	# nn.zig is this same derivation, compiled. Measured on 400 samples x 10
	# features through a 16-8-1 network, 100 epochs: 11.14 s -> 0.06 s.
	#
	# THE DELTA RULES ARE UNCHANGED and are worth restating because they are a
	# choice, not a detail:
	#   softmax + categorical cross-entropy -> delta = a - y, loss = -sum y*log(a)
	#   sigmoid + binary cross-entropy      -> delta = a - y, loss REPORTED as
	#                                          squared error
	#   anything else                       -> the squared-error derivative
	def Train(poNet, paInputs, paTargets, nEpochs)
		_nN_ = len(paInputs)
		if _nN_ = 0 or len(paTargets) != _nN_
			stzraise("Inputs and targets must align (got " + _nN_ + " / " +
				len(paTargets) + ").")
		ok
		if nEpochs < 1
			stzraise("Train me for at least one epoch.")
		ok

		_aLayers_ = poNet.Layers()
		_nL_ = len(_aLayers_)
		if _nL_ = 0
			stzraise("This network has no layers -- AddDenseLayer first.")
		ok

		_nIn_ = poNet.NumberOfInputs()
		_nOut_ = _aLayers_[_nL_][1]

		# shape + weights, in the engine's layout: per layer W row-major then b
		_acKinds_ = [ "relu", "sigmoid", "tanh", "linear", "softmax" ]
		_aShape_ = [ _nIn_, _nL_ ]
		_aW_ = []
		_nPrev_ = _nIn_
		for _l_ = 1 to _nL_
			_nU_ = _aLayers_[_l_][1]
			_nCode_ = ring_find(_acKinds_, _aLayers_[_l_][2]) - 1
			if _nCode_ < 0
				stzraise("Unknown activation '" + _aLayers_[_l_][2] + "'.")
			ok
			_aShape_ + _nU_
			_aShape_ + _nCode_
			for _u_ = 1 to _nU_
				for _pp_ = 1 to _nPrev_
					_aW_ + _aLayers_[_l_][3][_u_][_pp_]
				next
			next
			for _u_ = 1 to _nU_
				_aW_ + _aLayers_[_l_][4][_u_]
			next
			_nPrev_ = _nU_
		next

		# samples, flattened, checked on the way past -- a ragged row used to
		# raise a bare Ring index error from inside the forward pass
		_aX_ = []
		_aY_ = []
		for _i_ = 1 to _nN_
			if NOT isList(paInputs[_i_]) or len(paInputs[_i_]) != _nIn_
				stzraise("Sample " + _i_ + " has " + len(paInputs[_i_]) +
					" input(s) but the network takes " + _nIn_ + ".")
			ok
			if NOT isList(paTargets[_i_]) or len(paTargets[_i_]) != _nOut_
				stzraise("Target " + _i_ + " has " + len(paTargets[_i_]) +
					" value(s) but the output layer has " + _nOut_ + ".")
			ok
			for _d_ = 1 to _nIn_
				_aX_ + paInputs[_i_][_d_]
			next
			for _d_ = 1 to _nOut_
				_aY_ + paTargets[_i_][_d_]
			next
		next

		_aRes_ = StzEngineNNTrain(_aShape_, _aW_, _aX_, _aY_, _nN_, @nLr, nEpochs)
		if NOT isList(_aRes_) or len(_aRes_) != nEpochs + len(_aW_)
			stzraise("The engine refused the training run.")
		ok

		@aLossHistory = []
		for _e_ = 1 to nEpochs
			@aLossHistory + _aRes_[_e_]
		next

		# the trained weights, back into the layer structure the class publishes
		_nAt_ = nEpochs
		_nPrev_ = _nIn_
		for _l_ = 1 to _nL_
			_nU_ = _aLayers_[_l_][1]
			for _u_ = 1 to _nU_
				for _pp_ = 1 to _nPrev_
					_nAt_++
					_aLayers_[_l_][3][_u_][_pp_] = _aRes_[_nAt_]
				next
			next
			for _u_ = 1 to _nU_
				_nAt_++
				_aLayers_[_l_][4][_u_] = _aRes_[_nAt_]
			next
			_nPrev_ = _nU_
		next

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
