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

# Holds a small feed-forward network of dense layers, with seeded weights, forward prediction and a GGUF export.
#
# A network is declared by its input width and grown layer by layer, each layer with relu, sigmoid,
# tanh, linear or softmax activation. The first weights come from a seeded generator, so the same
# seed and layers always give the same network. Predict runs the forward pass. Training is the job
# of stzTrainer, which learns in the engine and writes the layers back through AdoptLayers into this
# same object. ExportToGguf writes the parameters to a file.
#
#   receiver   o1 = new stzNeuralNetwork([ :Inputs = 2 ])
#   example    o1.SetSeed(7)
#              o1.AddDenseLayer(3, :Tanh)
#              o1.AddDenseLayer(1, :Sigmoid)
#              ? o1.NumberOfLayers()
#              #--> 2
#              ? o1.Layers()[1][1]
#              #--> 3
#              ? len(o1.Predict([0.5, -0.5]))
#              #--> 1
#   see        stzTrainer, stzLogisticRegression, stzTrainingSet
class stzNeuralNetwork from stzObject

	@nInputs = 0
	@aLayers = []      # [ [ units, activation, W(units x prev), b(units) ] ]
	@nSeed = 42

	# Builds an empty feed-forward network that takes a fixed number of inputs and has no layers yet.
	#
	#   paSpec     a hash list [ :Inputs = n ] or a number n, the width of the input
	#   returns    nothing; the object is built
	#   warning    raises an error when the number of inputs is missing or below 1
	#   see        AddDenseLayer, Predict
	def init(paSpec)
		if isList(paSpec) and HasKey(paSpec, :Inputs)
			@nInputs = paSpec[:Inputs]
		but isNumber(paSpec)
			@nInputs = paSpec
		ok
		if @nInputs < 1
			stzraise("Declare the inputs: new stzNeuralNetwork([ :Inputs = n ])")
		ok

	# Sets the seed of the generator that gives the layers their first weights, so a network can be rebuilt identically.
	#
	#   n          the seed, a positive number
	#   returns    the network itself, so calls chain
	#   note       it acts on layers added afterwards; the same seed and the same layers give the
	#              same network
	#   see        AddDenseLayer
	def SetSeed(n)
		@nSeed = n
		return This

	# Adds a fully connected layer after the last one, with weights and biases drawn from the seeded generator between -1 and 1.
	#
	#   nUnits         the number of neurons in the layer
	#   pcActivation   relu, sigmoid, tanh, linear or softmax, in any case
	#   returns        nothing; use AddDenseLayerQ to chain
	#   note           the layer reads as many inputs as the previous layer has units
	#   warning        raises an error naming the choices for another activation
	#   see            Layers, Predict
	def AddDenseLayer(nUnits, pcActivation)
		_cAct_ = StzLower("" + pcActivation)
		if ring_find([ "relu", "sigmoid", "tanh", "linear", "softmax" ], _cAct_) = 0
			stzraise("Unknown activation '" + _cAct_ + "' -- use :ReLU, :Sigmoid, :Tanh, :Linear or :Softmax.")
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

		def AddDenseLayerQ(nUnits, pcActivation)
			This.AddDenseLayer(nUnits, pcActivation)
			return This

	# Returns how many layers the network has.
	#
	#   returns    a number
	#   see        AddDenseLayer
	def NumberOfLayers()
		return len(@aLayers)

	# Returns the width of the input.
	#
	#   returns    a number
	#   see        init
	def NumberOfInputs()
		return @nInputs

	# Returns the layers with their parameters.
	#
	#   returns    a list of [ units, activation, weights, biases ] rows; the weights are units by
	#              previous width
	#   see        AdoptLayers, Predict
	def Layers()
		return @aLayers

	# Replaces all the layers with the given ones, the way a trainer writes back what it learned.
	#
	#   paLayers   a list in the shape that Layers returns
	#   returns    the network itself, so calls chain
	#   note       nothing is checked: the shapes must match the inputs
	#   see        Layers
	#@ aka  the trainer pushes trained weights back through here (Ring copies lists on reads -- see the aliasing doctrine)
	def AdoptLayers(paLayers)
		@aLayers = paLayers
		return This

	# Writes the weights and biases of every layer to a GGUF file, and returns the path written.
	#
	#   pcFile     the path of the file to write
	#   pcName     the model name stored in the file
	#   returns    a text, the path, with .gguf added when missing
	#   note       the file holds one weight tensor and one bias tensor per layer
	#   warning    raises an error when there are no layers or the engine cannot write the file
	#   see        Layers
	#@ aka  R4 step 8 -- GGUF EXPORT: the trained network written in the format neural/ reads (arch 'stz-mlp'; tensors blk.N.weight [units x prev] row-major + blk.N.bias). Softanza writes what it reads -- the foundry's artifact loop closes.
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
			# THE FLATTENING TAX (2026-09-10): the weight matrix goes as rows
			if StzEngineNeuralGgufAddTensor("blk." + _l_ + ".weight",
					_nU_, _nP_, _aW_) != 1
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

	# Returns the output of the last layer for an input, by a forward pass.
	#
	#   paInput    the list of input values
	#   returns    a list of numbers, one per unit of the last layer; the input itself when there
	#              are no layers
	#   warning    an input longer than the network takes raises error R2, and a shorter one is
	#              accepted with the missing values counted as absent
	#   see        AddDenseLayer
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
			# softmax is a WHOLE-LAYER activation (normalizes across units),
			# so it can't be computed per-unit like the others -- rebuild
			# the layer's activations from the full pre-activation vector.
			if _cAct_ = "softmax"
				_aA_ = This._Softmax(_aZ_)
			ok
			_aZs_ + _aZ_
			_aActs_ + _aA_
			_aCur_ = _aA_
		next
		return [ :activations = _aActs_, :zs = _aZs_ ]

	# numerically stable softmax over a layer's pre-activations (subtract
	# the max before exp -- exp(700+) overflows Ring's doubles otherwise).
	def _Softmax(paZ)
		_n_ = len(paZ)
		_nMax_ = paZ[1]
		for _i_ = 2 to _n_
			if paZ[_i_] > _nMax_
				_nMax_ = paZ[_i_]
			ok
		next
		_aE_ = []
		_nSum_ = 0
		for _i_ = 1 to _n_
			_nV_ = exp(paZ[_i_] - _nMax_)
			_aE_ + _nV_
			_nSum_ += _nV_
		next
		for _i_ = 1 to _n_
			_aE_[_i_] = _aE_[_i_] / _nSum_
		next
		return _aE_

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
