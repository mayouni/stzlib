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

# Trains a stzNeuralNetwork by stochastic gradient descent and keeps the loss of every epoch, so the descent can be watched.
#
# The network arrives with each Train call and is changed in place, because an attribute would hold
# a private copy and training would perfect a clone. The loop and the backpropagation run in the
# engine; the trained weights are written back through AdoptLayers. The trainer records the loss
# history, and Why sums the run up: the epochs, the rate, and the first and last loss. Learning is
# deterministic for a given seed and data.
#
#   receiver   o1 = new stzTrainer() o2 = new stzNeuralNetwork([ :Inputs = 2 ])
#   example    o2.AddDenseLayer(4, :Tanh)
#              o2.AddDenseLayer(1, :Sigmoid)
#              o1.SetLearningRate(0.5)
#              o1.Train(o2, [ [0,0], [0,1], [1,0], [1,1] ], [ [0], [1], [1], [0] ], 2000)
#              ? len(o1.LossHistory())
#              #--> 2000
#              ? o1.LossHistory()[1] > o1.FinalLoss()
#              #--> 1
#              ? o2.Predict([0, 1])[1] > 0.9
#              #--> 1
#   see        stzNeuralNetwork, stzLogisticRegression, stzTrainingSet
class stzTrainer from stzObject

	@nLr = 0.1
	@aLossHistory = []
	@nEpochs = 0
	@cWhy = ""

	# Builds a trainer with the learning rate at 0.1 and no history.
	#
	#   returns    nothing; the object is built
	#   see        SetLearningRate, Train
	def init()

	# Sets the step size of the gradient descent.
	#
	#   n          the learning rate, above 0
	#   returns    the trainer itself, so calls chain
	#   note       a value of 0 or less is ignored without a message
	#   see        Train
	def SetLearningRate(n)
		if n > 0
			@nLr = n
		ok
		return This

	# Trains a network in place by backpropagation in the engine, recording the loss of every epoch.
	#
	#   poNet       the stzNeuralNetwork to train, which is changed
	#   paInputs    a list of input lists
	#   paTargets   a list of target lists, as wide as the output layer
	#   nEpochs     the number of passes, at least 1
	#   returns     the trainer itself, so calls chain
	#   note        the update rule is the output-layer delta of a minus y, whatever the loss
	#               reported; a softmax output uses cross-entropy and the other outputs report
	#               squared error
	#   warning     raises an error naming the cause when inputs and targets differ in number, the
	#               epochs are below 1, the network has no layers, or a sample or target has the
	#               wrong width
	#   see         LossHistory, Why
	#@ aka  paInputs = [ [x...] ... ], paTargets = [ [y...] ... ] THE TRAINING LOOP RUNS IN THE ENGINE (numeric phase 6, slice 3).
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
		next

		# THE FLATTENING TAX (2026-09-10): inputs and targets go as rows
		_aRes_ = StzEngineNNTrain(_aShape_, _aW_, paInputs, paTargets, _nN_, @nLr, nEpochs)
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

	# Returns the loss at every epoch of the last Train, in order.
	#
	#   returns    a list of numbers; empty before Train
	#   see        FinalLoss, Why
	def LossHistory()
		return @aLossHistory

	# Returns the loss at the last epoch of the last Train.
	#
	#   returns    a number; 0 before Train
	#   see        LossHistory
	def FinalLoss()
		if len(@aLossHistory) = 0
			return 0
		ok
		return @aLossHistory[len(@aLossHistory)]

	# Returns a sentence with the epochs, the learning rate and the first and last loss of the last Train.
	#
	#   returns    a text such as trained 2000 epoch(s), lr 0.50: loss 0.40 -> 0.00; empty before
	#              Train
	#   see        LossHistory, FinalLoss
	def Why()
		return @cWhy
