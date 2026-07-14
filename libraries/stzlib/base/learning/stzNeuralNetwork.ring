# R4 step 3 -- stzNeuralNetwork: A NETWORK YOU DECLARE LIKE A SENTENCE
# (LAW 4 -- OpenNN's lesson, Softanza's surface):
#
#   oNN = new stzNeuralNetwork([ :Inputs = 2 ])
#   oNN.AddDenseLayer(4, :Tanh)
#   oNN.AddDenseLayer(1, :Sigmoid)
#   ? oNN.Predict([1, 0])
#
# Floor tier: a pure-Ring multilayer perceptron with SEEDED,
# REPRODUCIBLE weight init (LAW 3: two runs agree; SetSeed to vary).
# The ggml backward pass (the R4 step-2 bridge) upgrades training
# behind the same surface later. Training lives in stzTrainer.

class stzNeuralNetwork from stzObject

	@nInputs = 0
	@aLayers = []      # [ [ units, activation, W(units x prev), b(units) ] ]
	@nSeed = 42

	def init(paSpec)
		if isList(paSpec) and HasKey(paSpec, :Inputs)
			@nInputs = paSpec[:Inputs]
		but isNumber(paSpec)
			@nInputs = paSpec
		ok
		if @nInputs < 1
			stzraise("Declare the inputs: new stzNeuralNetwork([ :Inputs = n ])")
		ok

	def SetSeed(n)
		@nSeed = n
		return This

	def AddDenseLayer(nUnits, pcActivation)
		_cAct_ = StzLower("" + pcActivation)
		if ring_find([ "relu", "sigmoid", "tanh", "linear" ], _cAct_) = 0
			stzraise("Unknown activation '" + _cAct_ + "' -- use :ReLU, :Sigmoid, :Tanh or :Linear.")
		ok
		_nPrev_ = @nInputs
		if len(@aLayers) > 0
			_nPrev_ = @aLayers[len(@aLayers)][1]
		ok
		# INIT RULING (empirically searched, 2026-07-14): weights AND
		# biases draw from +-1 uniform. Zero biases + shrunk weights sat
		# on XOR's symmetric saddle at EVERY seed (verified identically
		# in Ring and Python); random biases + full scale escape it.
		_aW_ = []
		for _i_ = 1 to nUnits
			_aRow_ = []
			for _j_ = 1 to _nPrev_
				_aRow_ + ((This._NextRand01() - 0.5) * 2)
			next
			_aW_ + _aRow_
		next
		_aB_ = []
		for _i_ = 1 to nUnits
			_aB_ + ((This._NextRand01() - 0.5) * 2)
		next
		@aLayers + [ nUnits, _cAct_, _aW_, _aB_ ]
		return This

	def NumberOfLayers()
		return len(@aLayers)

	def NumberOfInputs()
		return @nInputs

	def Layers()
		return @aLayers

	# the trainer pushes trained weights back through here (Ring copies
	# lists on reads -- see the aliasing doctrine)
	def AdoptLayers(paLayers)
		@aLayers = paLayers
		return This

	# R4 step 8 -- GGUF EXPORT: the trained network written in the
	# format neural/ reads (arch 'stz-mlp'; tensors blk.N.weight
	# [units x prev] row-major + blk.N.bias). Softanza writes what it
	# reads -- the foundry's artifact loop closes.
	def ExportToGguf(pcFile, pcName)
		if len(@aLayers) = 0
			stzraise("Nothing to export: add layers first.")
		ok
		if StzRight(pcFile, 5) != ".gguf"
			pcFile += ".gguf"
		ok
		if StzEngineNeuralGgufBegin("stz-mlp", "" + pcName) != 1
			stzraise("GGUF export session could not start.")
		ok
		_nL_ = len(@aLayers)
		for _l_ = 1 to _nL_
			_nU_ = @aLayers[_l_][1]
			_aW_ = @aLayers[_l_][3]
			_nP_ = len(_aW_[1])
			_aFlat_ = []
			for _u_ = 1 to _nU_
				for _p_ = 1 to _nP_
					_aFlat_ + _aW_[_u_][_p_]
				next
			next
			if StzEngineNeuralGgufAddTensor("blk." + _l_ + ".weight",
					_nU_, _nP_, _aFlat_) != 1
				StzEngineNeuralGgufAbort()
				stzraise("Tensor export failed at layer " + _l_ + " (weight).")
			ok
			if StzEngineNeuralGgufAddTensor("blk." + _l_ + ".bias",
					1, _nU_, @aLayers[_l_][4]) != 1
				StzEngineNeuralGgufAbort()
				stzraise("Tensor export failed at layer " + _l_ + " (bias).")
			ok
		next
		if StzEngineNeuralGgufWrite(pcFile) != 1
			stzraise("GGUF write failed for '" + pcFile + "'.")
		ok
		return pcFile

	def Predict(paInput)
		_aFwd_ = This._Forward(paInput)
		return _aFwd_[:activations][len(_aFwd_[:activations])]

	# forward pass keeping everything backprop needs
	def _Forward(paInput)
		_aActs_ = []       # activations per layer (input first)
		_aZs_ = []         # pre-activations per layer
		_aCur_ = paInput
		_aActs_ + _aCur_
		_nL_ = len(@aLayers)
		for _l_ = 1 to _nL_
			_nU_ = @aLayers[_l_][1]
			_cAct_ = @aLayers[_l_][2]
			_aZ_ = []
			_aA_ = []
			for _u_ = 1 to _nU_
				_nZ_ = @aLayers[_l_][4][_u_]
				_nP_ = len(_aCur_)
				for _p_ = 1 to _nP_
					_nZ_ += @aLayers[_l_][3][_u_][_p_] * _aCur_[_p_]
				next
				_aZ_ + _nZ_
				_aA_ + This._Act(_cAct_, _nZ_)
			next
			_aZs_ + _aZ_
			_aActs_ + _aA_
			_aCur_ = _aA_
		next
		return [ :activations = _aActs_, :zs = _aZs_ ]

	def _Act(pcKind, nZ)
		if pcKind = "relu"
			if nZ > 0
				return nZ
			ok
			return 0
		but pcKind = "sigmoid"
			if nZ > 35
				return 1
			ok
			if nZ < -35
				return 0
			ok
			return 1 / (1 + exp(-nZ))
		but pcKind = "tanh"
			return tanh(nZ)
		ok
		return nZ

	def _ActDeriv(pcKind, nZ, nA)
		if pcKind = "relu"
			if nZ > 0
				return 1
			ok
			return 0
		but pcKind = "sigmoid"
			return nA * (1 - nA)
		but pcKind = "tanh"
			return 1 - nA * nA
		ok
		return 1

	# seeded LCG (Park-Miller 16807): reproducible weight init (LAW 3),
	# symmetry broken. The multiplier is chosen for RING'S DOUBLES:
	# 16807 * 2^31 < 2^53, so the product never loses integer bits
	# (the classic 1103515245 multiplier OVERFLOWS doubles and
	# degenerates -- found live: every seed produced the same net).
	def _NextRand01()
		if @nSeed <= 0
			@nSeed = 42
		ok
		@nSeed = (@nSeed * 16807) % 2147483647
		return @nSeed / 2147483647
