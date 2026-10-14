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

# Fits a binary logistic regression on numeric features and answers the probability of the second label.
#
# Training runs in the engine by gradient descent for the number of epochs given. The model needs
# exactly two labels; the one that appears second in the training set is the positive class.
# Probability answers its chance, Classify applies the 0.5 threshold, and Why states the weights
# behind the last answer. Scale features of very different sizes first. TrainingAccuracy scores the
# model on its own training examples, which says it learned them and not that it will generalise.
#
#   receiver   o1 = new stzLogisticRegression(new stzTrainingSet([ [[1.0, 1.0], "low"], [[1.5, 0.8],
#              "low"], [[0.8, 1.2], "low"], [[8.0, 8.0], "high"], [[7.5, 8.5], "high"], [[8.2, 7.9],
#              "high"] ]))
#   example    o1.Train(200)
#              ? o1.Classify([8, 8])
#              #--> high
#              ? o1.Classify([1, 1])
#              #--> low
#              ? o1.TrainingAccuracy()
#              #--> 1
#              ? o1.Probability([8, 8]) > 0.9
#              #--> 1
#   see        stzTrainingSet, stzNaiveBayes, stzNeuralNetwork
class stzLogisticRegression from stzObject

	@oTs = ""
	@aW = []
	@nB = 0
	@nLr = 0.1
	@acLabels = []
	@nEpochs = 0
	@cWhy = ""
	@bTrained = 0

	# Builds a binary logistic regression over a training set; the set must hold exactly two labels.
	#
	#   poTrainingSet   a stzTrainingSet of numeric features with two labels
	#   returns         nothing; the object is built
	#   note            the second label to appear is the positive class that Probability measures
	#   warning         raises an error naming the count when the set has one label or more than two
	#   see             Train, TrainingSetQ
	def init(poTrainingSet)
		@oTs = poTrainingSet
		@acLabels = @oTs.Labels()
		if len(@acLabels) != 2
			stzraise("Binary logistic regression needs exactly 2 labels (got " +
				len(@acLabels) + ").")
		ok

	# Returns the training set the model holds.
	#
	#   returns    a stzTrainingSet
	#   see        Train
	#@ aka  THE HELD SET IS LIVE THROUGH HERE. Ring COPIES an object into an attribute, so the set handed to the constructor is a SNAPSHOT: growing the caller's own object afterwards would NOT reach this learner. Grow it through this accessor -- oLearner.TrainingSetQ().AddExample(...) -- which reaches the real held set (accessor + method call is live in Ring).
	def TrainingSetQ()
		return @oTs

	# Sets the step size of the gradient descent.
	#
	#   n          the learning rate, above 0
	#   returns    the model itself, so calls chain
	#   note       a value of 0 or less is ignored without a message
	#   see        Train
	def SetLearningRate(n)
		if n > 0
			@nLr = n
		ok
		return This

	# Fits the weights and the bias by gradient descent in the engine, for a fixed number of epochs.
	#
	#   nEpochs    the number of passes over the examples
	#   returns    the model itself, so calls chain
	#   note       training again refits from zero; with 0 epochs the weights stay 0 and every
	#              probability is 0.5
	#   warning    raises an error for an empty set and for an example whose width differs from the
	#              first
	#   see        Probability, TrainingAccuracy
	#@ aka  THE LOOP RUNS IN THE ENGINE (numeric phase 5), and the arithmetic is deliberately unchanged rather than merely equivalent.
	def Train(nEpochs)
		_aEx_ = @oTs.Examples()
		_nEx_ = len(_aEx_)
		_nF_ = @oTs.NumberOfFeatures()

		if _nEx_ = 0 or _nF_ = 0
			stzraise("Can't train on an empty training set.")
		ok

		# Flatten, and check every row on the way past.
		#
		# THE OLD LOOP TRUNCATED RAGGED DATA IN SILENCE. NumberOfFeatures() is the
		# width of the FIRST example, and the loop indexed every other row to that
		# width: a 3-feature row among 2-feature rows trained as though its third
		# feature did not exist, and a SHORTER row would have raised a bare Ring
		# "Array Access (Index out of range)" from inside the update. The engine
		# refuses a length mismatch outright -- and a refusal is only safe if the
		# caller handles it, so the width is checked here where the row number can
		# still be named.
		_aX_ = []
		_aY_ = []
		for _i_ = 1 to _nEx_
			_aRow_ = _aEx_[_i_][1]
			if len(_aRow_) != _nF_
				stzraise("Example " + _i_ + " has " + len(_aRow_) +
					" feature(s) but the set is " + _nF_ + " wide. " +
					"Every example must have the same features.")
			ok
			# THE FLATTENING TAX (2026-09-10): one append per example row
			_aX_ + _aRow_
			if _aEx_[_i_][2] = @acLabels[2]
				_aY_ + 1
			else
				_aY_ + 0
			ok
		next

		_aFit_ = StzEngineLogisticTrain(_aX_, _aY_, _nEx_, _nF_, @nLr, nEpochs)
		if NOT isList(_aFit_) or len(_aFit_) != _nF_ + 1
			stzraise("The engine refused the fit (" + _nEx_ + " examples x " +
				_nF_ + " features).")
		ok

		@aW = []
		for _f_ = 1 to _nF_
			@aW + _aFit_[_f_]
		next
		@nB = _aFit_[_nF_ + 1]

		@nEpochs = nEpochs
		@bTrained = 1
		return This

	# Returns the model's probability that a feature list belongs to the positive class, the second label.
	#
	#   paFeatures   the numbers describing the thing to score, as many as the model was fitted on
	#   returns      a number from 0 to 1
	#   warning      raises an error telling to call Train first, and one naming the width when the
	#                query does not match
	#   see          Probabilities, Classify
	#@ aka  SCORED BY THE RULE IT WAS FITTED BY. This goes through the engine too, and not for speed -- one row is dominated by marshalling. It is here because Ring's exp and Zig's exp agree only to within an ulp, and a model whose predictions come from a slightly different function than its fit is a question nobody should have to think about. One definition, both ends.
	def Probability(paFeatures)
		if @bTrained = 0
			stzraise("Train() me first.")
		ok

		# used to be a bare Ring "Array Access (Index out of range)" from inside
		# the dot product, which named neither the model nor the caller's mistake
		if NOT isList(paFeatures) or len(paFeatures) != len(@aW)
			stzraise("This model was fitted on " + len(@aW) +
				" feature(s); you gave it " + len(paFeatures) + ".")
		ok

		_aP_ = StzEngineLogisticPredict(paFeatures, 1, len(@aW), @aW, @nB)
		if NOT isList(_aP_) or len(_aP_) != 1
			stzraise("The engine refused the prediction.")
		ok
		return _aP_[1]

	# Returns the probability for many feature lists in one call into the engine.
	#
	#   paRows     a list of feature lists, each as wide as the fitted model
	#   returns    a list of numbers, one per row; an empty list for no rows
	#   warning    raises an error telling to call Train first, and one naming the row of the wrong
	#              width
	#   see        Probability
	#@ aka  Probabilities for many rows in ONE crossing. TrainingAccuracy() below is the reason this exists: it scores every training example, and a round trip per row would have made the diagnostic cost more than the fit it diagnoses.
	def Probabilities(paRows)
		if @bTrained = 0
			stzraise("Train() me first.")
		ok
		_nD_ = len(@aW)
		_nM_ = len(paRows)
		if _nM_ = 0
			return []
		ok

		_aFlat_ = []
		for _i_ = 1 to _nM_
			if NOT isList(paRows[_i_]) or len(paRows[_i_]) != _nD_
				stzraise("Row " + _i_ + " has " + len(paRows[_i_]) +
					" feature(s); this model was fitted on " + _nD_ + ".")
			ok
		next

		# THE FLATTENING TAX (2026-09-10): the rows go as they are
		_aP_ = StzEngineLogisticPredict(paRows, _nM_, _nD_, @aW, @nB)
		if NOT isList(_aP_) or len(_aP_) != _nM_
			stzraise("The engine refused the prediction.")
		ok
		return _aP_

	# Returns the label the model predicts: the second label when its probability reaches 0.5, else the first.
	#
	#   paFeatures   the numbers describing the thing to classify
	#   returns      a text, the label
	#   warning      raises the errors of Probability
	#   see          Probability, Why
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

	# Returns the fitted weights, one per feature.
	#
	#   returns    a list of numbers; empty before Train
	#   see        Bias
	def Weights()
		return @aW

	# Returns the fitted bias, the term added to the weighted sum.
	#
	#   returns    a number; 0 before Train
	#   see        Weights
	def Bias()
		return @nB

	# Returns the share of the training examples the model labels correctly.
	#
	#   returns    a number from 0 to 1; 0 before Train
	#   see        Classify, Train
	#@ aka  How well the model fits the data it was TRAINED on.
	def TrainingAccuracy()
		if NOT @bTrained
			return 0
		ok

		_aTaEx_ = @oTs.Examples()
		_nTaLen_ = len(_aTaEx_)

		if _nTaLen_ = 0
			return 0
		ok

		# one crossing for the whole set, not one per example -- and Classify()'s
		# threshold repeated here rather than called, so that scoring the training
		# set does not leave @cWhy describing whichever example happened to be last
		_aTaRows_ = []
		_acTaTruth_ = []
		for _iTa_ = 1 to _nTaLen_
			_aTaRows_ + _aTaEx_[_iTa_][1]
			_acTaTruth_ + _aTaEx_[_iTa_][2]
		next

		_anTaP_ = This.Probabilities(_aTaRows_)
		_acTaPred_ = []
		for _iTa_ = 1 to _nTaLen_
			if _anTaP_[_iTa_] >= 0.5
				_acTaPred_ + @acLabels[2]
			else
				_acTaPred_ + @acLabels[1]
			ok
		next

		return StzAccuracy(_acTaPred_, _acTaTruth_)

	# Returns the last answer of Classify as text: the probability, the epochs, the label chosen, the weights and the bias.
	#
	#   returns    a text; empty before the first Classify
	#   see        Classify
	def Why()
		return @cWhy

	# _Score() and _Sigmoid() USED TO LIVE HERE and are deliberately gone.
	#
	# Once the fit moved into `logistic.zig`, keeping a second copy of the score
	# and the sigmoid in Ring would have meant two definitions of the same
	# quantity -- the exact shape this numeric phase keeps finding and paying for
	# (the variance divisor, the summation, the centered sum of squares, the
	# negligible threshold, Euclidean distance). They would have agreed today and
	# drifted the first time either was touched, and the drift would have shown up
	# as a model whose predictions disagreed with its own training. Probability()
	# and Probabilities() ask the engine, which is where the fit happens.
