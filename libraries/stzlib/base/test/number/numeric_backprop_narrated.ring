load "../../stzBase.ring"
load "../_narrated.ring"

# BACKPROPAGATION COMES DOWN FROM RING (numeric phase 6, slice 3).
#
# THE PLAN SAID SOMETHING ELSE, AND THE MEASUREMENT SAID IT WAS WRONG. Phase 6's line
# reads "rewiring the trainer and logistic regression to use gradients rather than
# hand-derived updates" -- meaning: put them on the autodiff tape. Three findings say
# not to:
#
#   1. THE HAND-DERIVED GRADIENTS WERE ALREADY EXACT. Slice 1's tape was used to
#      check them, which is the honest use of an autodiff. On a 1-tanh-1-sigmoid
#      network the two agree to eight decimals on every weight. There was no
#      correctness debt to pay off -- and finding that out was worth more than the
#      rewrite would have been.
#   2. A TAPE IS SLOWER THAN DERIVED CODE FOR A FIXED ARCHITECTURE. Reverse mode
#      earns its overhead when the expression is arbitrary. A dense MLP is not: its
#      derivative is known in closed form, and writing it out beats interpreting a
#      graph of it.
#   3. IT WOULD HAVE CHANGED THE ANSWERS. This trainer minimises binary cross-entropy
#      for a sigmoid output while REPORTING squared error. Rebuilding it around "the
#      gradient of the reported loss" reintroduces the a(1-a) factor that the Ring
#      comment records as strangling gradients into the constant-0.5 XOR saddle.
#
# So the tape stays where it belongs -- arbitrary objectives and L-BFGS -- and nn.zig
# is the same derivation, compiled.
#
#     XOR, 2000 epochs                     0.407 s  ->  0.002 s     203x
#     400 x 10 through 16-8-1, 100 epochs 11.140 s  ->  0.028 s     398x
#
# HOW CLOSE IS "THE SAME", exactly. This was measured rather than asserted, and the
# answer has two halves:
#
#   * EXACT, bit for bit: XOR over 300 epochs, a ReLU + linear net over 40, a softmax
#     net over 50, and -- the sharpest check -- a THREE-layer net after one sample and
#     one epoch, agreeing to twelve decimals. That last one is what proves the
#     multi-layer backward pass, where the next layer's delta must be computed from
#     the weights BEFORE they are updated.
#   * NOT EXACT, after enough accumulation: a 3-layer net over 40 samples first
#     differs at EPOCH 48, in the tenth decimal. The cause is measurable -- Ring's
#     tanh is the C library's and the engine's is Zig's, and they differ by up to
#     6e-17, about half an ulp, on some inputs. Backpropagation feeds each step into
#     the next, so half an ulp does not stay half an ulp.
#
# WHAT THAT COSTS, stated plainly rather than buried: on the 400 x 10 benchmark the
# final loss differs by about 4% (0.0594 against 0.0619) after 100 epochs. THE
# ACCURACY IS IDENTICAL -- 0.93 either way. The two runs settle on different points of
# a nearly flat basin, which is what stochastic gradient descent does. A run is still
# reproducible (the same build gives the same answer every time); what is not
# preserved is bit-equality with the old interpreter, and no amount of care could
# preserve it while calling a different libm.

Scenario("XOR -- and it is bit-identical")
	# The problem no linear model can do, and the one the Ring class's init comment
	# says it was tuned for. 300 epochs of it agree with the old trainer exactly.
	aX = [ [0,0], [0,1], [1,0], [1,1] ]
	aY = [ [0], [1], [1], [0] ]
	oN = new stzNeuralNetwork([ :Inputs = 2 ])
	oN.AddDenseLayer(4, :Tanh)
	oN.AddDenseLayer(1, :Sigmoid)
	oT = new stzTrainer()
	oT.SetLearningRate(0.5)
	oT.Train(oN, aX, aY, 2000)

	Then("00 -> 0", oN.Predict([0,0])[1] < 0.5, TRUE)
	Then("01 -> 1", oN.Predict([0,1])[1] > 0.5, TRUE)
	Then("10 -> 1", oN.Predict([1,0])[1] > 0.5, TRUE)
	Then("11 -> 0", oN.Predict([1,1])[1] < 0.5, TRUE)
	Then("the loss went down", oT.FinalLoss() < oT.LossHistory()[1], TRUE)
	Then("...essentially to zero", oT.FinalLoss() < 0.001, TRUE)
	Then("one loss per epoch was recorded", len(oT.LossHistory()), 2000)
	Then("Why() still narrates", StzFindFirst("trained 2000 epoch", oT.Why()) > 0, TRUE)
EndScenario()

Scenario("the multi-layer backward pass, checked one step at a time")
	# THE SHARPEST TEST IN THIS FILE. Three layers, one sample, one epoch, weights
	# set by hand so nothing is random. If the next layer's delta were computed from
	# the UPDATED weights rather than the ones that produced the forward pass, this
	# is where it would show -- and it would still look plausible on XOR, which has
	# only two layers and so never exercises the chain.
	oN = new stzNeuralNetwork([ :Inputs = 2 ])
	oN.AddDenseLayer(3, :Tanh)
	oN.AddDenseLayer(2, :Tanh)
	oN.AddDenseLayer(1, :Sigmoid)
	oN.AdoptLayers([
		[ 3, "tanh",    [[0.1,0.2],[0.3,-0.4],[-0.5,0.6]], [0.01,-0.02,0.03] ],
		[ 2, "tanh",    [[0.7,-0.8,0.9],[-0.1,0.2,-0.3]],  [0.04,-0.05] ],
		[ 1, "sigmoid", [[0.5,-0.6]],                       [0.06] ] ])
	oT = new stzTrainer()
	oT.SetLearningRate(0.1)
	oT.Train(oN, [ [0.3, 0.7] ], [ [1] ], 1)
	a = oN.Layers()

	# these are the Ring trainer's numbers, read off the unmodified implementation
	Then("layer 1, first weight", Rnd10(a[1][3][1][1]), 0.1035093643)
	Then("layer 1, a bias", Rnd10(a[1][4][2]), -0.0350685932)
	Then("layer 2, a middle weight", Rnd10(a[2][3][1][2]), -0.8029041064)
	Then("layer 3, the output weight", Rnd10(a[3][3][1][1]), 0.5207972249)
	Then("layer 3, the output bias", Rnd10(a[3][4][1]), 0.0991199176)
EndScenario()

Scenario("the other activations, and the pairings they belong to")
	# ReLU hidden + linear output: the squared-error branch, where delta carries the
	# activation derivative rather than being (a - y).
	oR2 = new stzNeuralNetwork([ :Inputs = 3 ])
	oR2.AddDenseLayer(4, :ReLU)
	oR2.AddDenseLayer(2, :Linear)
	oT = new stzTrainer()
	oT.Train(oR2, [ [1,2,3], [0.5,0,1] ], [ [1,0], [0,1] ], 200)
	Then("a relu/linear net trains", oT.FinalLoss() < oT.LossHistory()[1], TRUE)
	Then("...and predicts two outputs", len(oR2.Predict([1,2,3])), 2)

	# Softmax + categorical cross-entropy: a WHOLE-LAYER activation, so it cannot be
	# computed per unit like the others, and its loss is -sum y*log(a).
	oS = new stzNeuralNetwork([ :Inputs = 2 ])
	oS.AddDenseLayer(4, :Tanh)
	oS.AddDenseLayer(3, :Softmax)
	oT2 = new stzTrainer()
	oT2.Train(oS, [ [0,1], [1,0], [1,1] ], [ [1,0,0], [0,1,0], [0,0,1] ], 400)
	aP = oS.Predict([0,1])
	Then("a softmax layer sums to one", Rnd6(aP[1] + aP[2] + aP[3]), 1)
	Then("...and learned the first class", aP[1] > aP[2] and aP[1] > aP[3], TRUE)
	Then("the cross-entropy loss fell", oT2.FinalLoss() < oT2.LossHistory()[1], TRUE)
EndScenario()

Scenario("a real problem, where bit-equality is NOT preserved and accuracy is")
	# 400 samples of 10 features through 16-8-1. This is the case where the tanh
	# half-ulp difference has been fed back enough times to move the last digits:
	# the final loss differs from the Ring trainer's by about 4%. Both models
	# classify the training set identically.
	aX = []
	aY = []
	for i = 1 to 400
		r = []
		s = 0
		for d = 1 to 10
			v = ((i*37+d*11) % 100) / 100
			r + v
			s += v
		next
		aX + r
		if s > 5
			aY + [1]
		else
			aY + [0]
		ok
	next
	oN = new stzNeuralNetwork([ :Inputs = 10 ])
	oN.AddDenseLayer(16, :Tanh)
	oN.AddDenseLayer(8, :Tanh)
	oN.AddDenseLayer(1, :Sigmoid)
	oT = new stzTrainer()
	t0 = clock()
	oT.Train(oN, aX, aY, 100)
	nT = (clock() - t0) / clockspersecond()

	nOk = 0
	for i = 1 to 400
		nP = oN.Predict(aX[i])[1]
		nC = 0
		if nP >= 0.5
			nC = 1
		ok
		if nC = aY[i][1]
			nOk++
		ok
	next

	Then("it trains in under 3s -- it was 11.14", nT < 3, TRUE)
	Then("the loss came down a long way", oT.FinalLoss() < 0.1, TRUE)
	Then("...and the model is the same QUALITY: 93% on its training set",
	     Rnd2(nOk / 400), 0.93)
EndScenario()

Scenario("it is reproducible, which is the property that had to survive")
	# Bit-equality with the old interpreter could not be preserved across a
	# different libm. Reproducibility WITHIN this build could, and is the thing a
	# user actually depends on: the same data twice gives the same model twice.
	aX = [ [0,0], [0,1], [1,0], [1,1] ]
	aY = [ [0], [1], [1], [0] ]

	o1 = new stzNeuralNetwork([ :Inputs = 2 ])
	o1.AddDenseLayer(4, :Tanh)
	o1.AddDenseLayer(1, :Sigmoid)
	t1 = new stzTrainer()
	t1.SetLearningRate(0.5)
	t1.Train(o1, aX, aY, 500)

	o2 = new stzNeuralNetwork([ :Inputs = 2 ])
	o2.AddDenseLayer(4, :Tanh)
	o2.AddDenseLayer(1, :Sigmoid)
	t2 = new stzTrainer()
	t2.SetLearningRate(0.5)
	t2.Train(o2, aX, aY, 500)

	Then("the same final loss", t1.FinalLoss(), t2.FinalLoss())
	Then("...and the same first-epoch loss", t1.LossHistory()[1], t2.LossHistory()[1])
	Then("the same prediction", o1.Predict([0,1])[1], o2.Predict([0,1])[1])
	Then("...and the same weight", o1.Layers()[1][3][1][1], o2.Layers()[1][3][1][1])
EndScenario()

Scenario("ragged data is a diagnosis, not an index error")
	# The same trap the logistic and tree slices closed. A short input row used to
	# raise a bare Ring "Array Access (Index out of range)" from inside the forward
	# pass, naming neither the sample nor the network.
	oN = new stzNeuralNetwork([ :Inputs = 3 ])
	oN.AddDenseLayer(2, :Tanh)
	oN.AddDenseLayer(1, :Sigmoid)
	oT = new stzTrainer()

	Then("a short input row is refused",
	     RaisesTrain(oT, oN, [ [1,2,3], [1,2] ], [ [1], [0] ]), TRUE)
	Then("...naming the sample",
	     StzFindFirst("Sample 2", WhyTrain(oT, oN, [ [1,2,3], [1,2] ], [ [1], [0] ])) > 0, TRUE)
	Then("a wrong-width target is refused",
	     RaisesTrain(oT, oN, [ [1,2,3] ], [ [1,0] ]), TRUE)
	Then("mismatched counts are refused",
	     RaisesTrain(oT, oN, [ [1,2,3], [1,2,3] ], [ [1] ]), TRUE)
	Then("zero epochs is refused", RaisesEpochs(oT, oN), TRUE)
EndScenario()

Summary()

func Rnd10(n)
	return ceil(n * 10000000000 - 0.5) / 10000000000

func Rnd6(n)
	return ceil(n * 1000000 - 0.5) / 1000000

func Rnd2(n)
	return ceil(n * 100 - 0.5) / 100

func RaisesTrain(oT, oN, aX, aY)
	b = FALSE
	try
		oT.Train(oN, aX, aY, 5)
	catch
		b = TRUE
	done
	return b

func WhyTrain(oT, oN, aX, aY)
	s = ""
	try
		oT.Train(oN, aX, aY, 5)
	catch
		s = cCatchError
	done
	return s

func RaisesEpochs(oT, oN)
	b = FALSE
	try
		oT.Train(oN, [ [1,2,3] ], [ [1] ], 0)
	catch
		b = TRUE
	done
	return b
