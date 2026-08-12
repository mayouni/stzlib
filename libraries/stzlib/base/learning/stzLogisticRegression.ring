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

	@oTs = ""
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

	# THE LOOP RUNS IN THE ENGINE (numeric phase 5), and the arithmetic is
	# deliberately unchanged rather than merely equivalent.
	#
	# Gradient descent is a feedback loop -- each step's weights decide the next
	# step's gradient -- so a last-bit difference does not stay a last-bit
	# difference, it compounds. This class promises reproducible runs, and moving
	# the loop is only allowed to keep that promise. So `logistic.zig` keeps the
	# updates sequential per example, accumulates the dot product in index order
	# (a lane-parallel reduction would be faster and would change every model),
	# and saturates at the same |z| > 35. Only the weight update vectorises, and
	# only because `w[f] += c * x[f]` is elementwise: lane width cannot change an
	# individual result.
	#
	# Measured, 5000 examples x 16 features x 100 epochs: 10.0s -> 0.062s (161x),
	# and 20000 x 32 x 100 -- previously out of reach -- in 0.71s. Hoisting the old
	# Ring loop by hand (the label test done once instead of once per epoch, the
	# feature row never passed as an argument) gave 5.0s with bit-identical
	# weights, so half of what was paid was interpreter overhead and half was
	# arithmetic. The engine collects both.
	#
	# The drift against the old loop was measured, not assumed, and it is never
	# zero: 1e-16 after ONE epoch, 1e-15 at ten, 1e-14 at a hundred and still
	# 1e-14 at five hundred. That is the one thing that could not be held fixed --
	# Ring's exp is the C library's, the engine's is Zig's, they agree to within
	# an ulp, and gradient descent feeds each step into the next so the difference
	# grows about a decade per five hundred epochs. Against weights of magnitude
	# 1 to 10 it stays around 1e-15 relative, and both loops classify identically.
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
			for _f_ = 1 to _nF_
				_aX_ + _aRow_[_f_]
			next
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

	# SCORED BY THE RULE IT WAS FITTED BY. This goes through the engine too, and
	# not for speed -- one row is dominated by marshalling. It is here because
	# Ring's exp and Zig's exp agree only to within an ulp, and a model whose
	# predictions come from a slightly different function than its fit is a
	# question nobody should have to think about. One definition, both ends.
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

	# Probabilities for many rows in ONE crossing. TrainingAccuracy() below is the
	# reason this exists: it scores every training example, and a round trip per
	# row would have made the diagnostic cost more than the fit it diagnoses.
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
			for _f_ = 1 to _nD_
				_aFlat_ + paRows[_i_][_f_]
			next
		next

		_aP_ = StzEngineLogisticPredict(_aFlat_, _nM_, _nD_, @aW, @nB)
		if NOT isList(_aP_) or len(_aP_) != _nM_
			stzraise("The engine refused the prediction.")
		ok
		return _aP_

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
