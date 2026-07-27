# stzTSNE and stzUMAP -- nonlinear embeddings for LOOKING at data, on top of PCA.
#
#   oT = new stzTSNE(aData)
#   oT.ReduceWithPCA(30)        # the standard first step -- see below
#   oT.SetPerplexity(30)
#   oT.Fit()
#   ? oT.Embedding()            # n rows of 2 coordinates
#
#   oU = new stzUMAP(aData)
#   oU.ReduceWithPCA(30)
#   oU.SetNeighbors(15)
#   oU.Fit()
#   ? oU.Embedding()
#
# ── WHAT THESE ARE, AND HOW THEY DIFFER FROM PCA ──
#
# PCA answers "which directions carry the most variance" with a map that is LINEAR,
# DETERMINISTIC and REVERSIBLE: the components mean something, new data projects into
# the same space, and distances survive. t-SNE and UMAP answer a different question --
# "which points are NEAR each other" -- and pay for it with a map that is nonlinear,
# stochastic and one-way. They exist to make a PICTURE.
#
# ── WHY PCA FIRST, AND WHY IT IS NOT JUST A SPEED TRICK ──
#
# The standard pipeline is PCA to about 30-50 dimensions, then t-SNE or UMAP to 2.
# ReduceWithPCA(30) does exactly that. It helps twice:
#
#   * SPEED. Both algorithms compute distances between every pair of points, and
#     the cost of one distance is linear in the dimension. Going from 784 features
#     to 30 makes that part twenty-five times cheaper.
#   * NOISE. In high dimensions, distance is dominated by the accumulated noise of
#     hundreds of weakly-informative features -- everything drifts equidistant, and
#     the neighbourhoods the embedding is built from become arbitrary. Dropping to
#     the components that carry real variance makes "near" mean something again.
#
# It is not free: PCA is linear, so any structure that lives entirely in the
# discarded components is gone before the nonlinear step ever sees it. Keeping
# enough components that the retained variance is high is the guard against that,
# and ExplainedVarianceRatio() on the inner PCA reports it.
#
# ── HOW TO READ THE PICTURE, WHICH IS WHERE PEOPLE GO WRONG ──
#
#   * DISTANCES ARE NOT MEANINGFUL. Two clusters drawn far apart are not "more
#     different" than two drawn close together. Both algorithms optimise a
#     neighbourhood probability, not a distance.
#   * CLUSTER SIZES ARE NOT MEANINGFUL. A tight group and a diffuse one can come out
#     the same size, because the kernels deliberately expand dense regions.
#   * THE PARAMETERS CHANGE THE PICTURE. Perplexity (t-SNE) and n_neighbors (UMAP)
#     dial between local detail and global shape. There is no correct value, only a
#     question being asked -- and looking at two settings is better practice than
#     trusting one.
#   * IT IS STOCHASTIC. The seed is an input, not an implementation detail. Both
#     classes seed deterministically so two runs agree; change SetSeed() to see how
#     much of your picture is the data and how much is the arrangement.
#
# ── PLACING NEW POINTS: THREE DIFFERENT ANSWERS ──
#
# ORDINARY t-SNE cannot. It optimises the POSITIONS of the points it was given, so
# there is no function anywhere in it and nothing to apply to a new point. Transform()
# raises, and says which of the two things below to do instead.
#
# UMAP CAN, because it builds a NEIGHBOUR GRAPH and a graph extends. Transform() finds
# the new point's nearest training neighbours, gives it its own local metric, starts
# it at the weighted average of their embedded positions and refines it with the
# training layout HELD FIXED. It re-optimises one point against a frozen map.
#
# PARAMETRIC t-SNE CAN, and differently: LearnMapping() trains a NEURAL NETWORK
# f(x) -> R^2 against the same KL objective instead of optimising free coordinates
# (van der Maaten 2009). The embedding IS f(X), so Transform() is ONE FORWARD PASS --
# nothing is optimised, nothing is stochastic, and transforming the training data
# reproduces the training embedding EXACTLY rather than approximately.
#
# THE PARAMETRIC VARIANT COSTS SOMETHING, and the paper says so too: the embedding is
# generally somewhat WORSE than ordinary t-SNE on the same data. Free coordinates can
# go anywhere; a network's outputs are limited to what the network can express, so the
# optimiser searches a smaller space. You are trading some quality of the picture for
# the ability to place new points in it.
#
# UMAP builds a NEIGHBOUR GRAPH, and a graph extends. A new point's edges to the
# training points are computable, and the training layout is already a solution those
# edges can be optimised against -- so stzUMAP.Transform() finds the new point's
# nearest training neighbours, gives it its own local metric, starts it at the
# weighted average of their embedded positions, and refines it with the training
# layout HELD FIXED.
#
# WHAT TRANSFORM IS NOT: it is not the same as having included the point in the
# original fit. The map does not rearrange to accommodate it. A point belonging to
# structure the fit never saw will be placed among whichever training points are
# least far away -- confidently, and wrongly. It answers "where does this sit in the
# map I already have", not "what would the map have looked like with this in it".

# RING FILE ORDER: functions must be defined BEFORE classes in the same file --
# a `func` after a `class` is never seen, and the call fails at runtime with R3
# "Calling Function without definition". So the shared helpers come first.

# ── shared helpers, so the two classes cannot drift apart on the things they agree
#    about: what valid data looks like, and how the PCA pre-step runs ──

func StzEmbeddingCheckData(paData)
	if NOT isList(paData) or len(paData) = 0
		stzraise("Give me a list of samples, each a list of feature values.")
	ok
	if NOT isList(paData[1]) or len(paData[1]) = 0
		stzraise("Each sample must be a list of at least one feature value.")
	ok
	_nR_ = len(paData)
	_nC_ = len(paData[1])
	for _i_ = 1 to _nR_
		if NOT isList(paData[_i_]) or len(paData[_i_]) != _nC_
			stzraise("Sample " + _i_ + " has " + len(paData[_i_]) +
				" value(s) but the first has " + _nC_ + ". " +
				"Every sample must describe the same features.")
		ok
	next
	return [ _nR_, _nC_ ]

# ONE definition of the PCA pre-step, shared by both classes -- the shape this
# numeric work keeps finding is two copies of one rule drifting apart.
#
# Returns [ flattened data, dimension ]. When no reduction is asked for, or when the
# data already has fewer features than components requested, the data passes through
# unchanged rather than being padded to a size it does not have.
func StzEmbeddingPrepare(poOwner, paData, nRows, nCols, nPcaDims)
	if nPcaDims <= 0 or nPcaDims >= nCols
		_aFlat_ = []
		for _i_ = 1 to nRows
			for _j_ = 1 to nCols
				_aFlat_ + paData[_i_][_j_]
			next
		next
		return [ _aFlat_, nCols ]
	ok

	_oP_ = new stzPCA(paData)
	# CENTER, not standardize: the features going into an embedding are usually one
	# measurement type (pixels, counts, an embedding vector), and scaling each to
	# unit variance would amplify the near-constant ones into noise. A caller who
	# needs correlation PCA can run stzPCA themselves and pass the scores in.
	_oP_.Center()
	_oP_.Fit()
	poOwner._AdoptPCA(_oP_)

	# THROUGH Transform(), NOT Scores(). Both give the components of the training
	# data and they agree to about eight decimals -- but they are computed two
	# different ways (U*S against (x-mean)*V), so the last bits differ. Since
	# Transform() is what a NEW row will go through, using it here too makes the fit
	# input and the transform input the SAME computation, and a training row then
	# transforms back to its position EXACTLY rather than nearly. One definition,
	# for the usual reason.
	_aS_ = _oP_.Transform(paData)
	_nK_ = nPcaDims
	if _nK_ > len(_aS_[1])
		_nK_ = len(_aS_[1])
	ok

	_aFlat_ = []
	for _i_ = 1 to nRows
		for _j_ = 1 to _nK_
			_aFlat_ + _aS_[_i_][_j_]
		next
	next
	return [ _aFlat_, _nK_ ]


class stzTSNE from stzObject

	@aData = []
	@nRows = 0
	@nCols = 0
	@nPerplexity = 30
	@nDims = 2
	@nIterations = 1000
	@nSeed = 42
	@nPcaDims = 0
	@bFitted = FALSE
	@aEmbedding = []
	@anKL = []
	@oPca = NULL
	@bParametric = FALSE
	@nPreparedDim = 0     # the width the fit actually saw (post-PCA when reducing)
	@anHidden = [ 50, 20 ]
	@nLearningRate = 0.01
	@anShape = []
	@anWeights = []

	def init(paData)
		_a_ = StzEmbeddingCheckData(paData)
		@aData = paData
		@nRows = _a_[1]
		@nCols = _a_[2]

	def NumberOfSamples()
		return @nRows

	def NumberOfFeatures()
		return @nCols

	# ── the dials ──

	# Roughly "how many neighbours should count". The original paper suggests 5..50,
	# and the result IS sensitive to it: small values see fine structure and can
	# fragment a real cluster, large values see the broad shape and can merge two.
	def SetPerplexity(n)
		if n > 0
			@nPerplexity = n
		ok

		def SetPerplexityQ(n)
			This.SetPerplexity(n)
			return This

	def Perplexity()
		return @nPerplexity

	def SetDimensions(n)
		if n >= 1
			@nDims = n
		ok

		def SetDimensionsQ(n)
			This.SetDimensions(n)
			return This

	def SetIterations(n)
		if n > 0
			@nIterations = n
		ok

		def SetIterationsQ(n)
			This.SetIterations(n)
			return This

	def SetSeed(n)
		@nSeed = n

		def SetSeedQ(n)
			This.SetSeed(n)
			return This

	# PCA to n dimensions before embedding -- the standard pipeline. See the note at
	# the top of this file for why it is two benefits and one cost.
	def ReduceWithPCA(n)
		if n >= 1
			@nPcaDims = n
		ok

		def ReduceWithPCAQ(n)
			This.ReduceWithPCA(n)
			return This

	def SkipPCA()
		@nPcaDims = 0

		def SkipPCAQ()
			This.SkipPCA()
			return This

	def UsesPCA()
		return @nPcaDims > 0

	# the inner analysis, when there was one -- so a caller can ask how much variance
	# survived the reduction before reading anything into the picture
	def PCAQ()
		return @oPca

	# ── the parametric variant, which is what gives t-SNE a Transform() ──

	# LEARN A MAP instead of a layout: train a network f(x) -> R^dims against the same
	# KL objective (van der Maaten 2009). The embedding becomes f(X), so a new point
	# is one forward pass.
	#
	# IT IS A TRADE, not an upgrade. The embedding is generally somewhat worse than
	# ordinary t-SNE, because free coordinates can go anywhere and a network's outputs
	# are limited to what it can express.
	def LearnMapping()
		@bParametric = TRUE

		def LearnMappingQ()
			This.LearnMapping()
			return This

	def SkipMapping()
		@bParametric = FALSE

		def SkipMappingQ()
			This.SkipMapping()
			return This

	def IsParametric()
		return @bParametric

	# The hidden layer widths. The output layer is always LINEAR and as wide as the
	# embedding, because a coordinate is unbounded and squashing it through a tanh
	# would cap the layout at a box.
	def SetHiddenLayers(paWidths)
		if isList(paWidths) and len(paWidths) > 0
			@anHidden = paWidths
		ok

		def SetHiddenLayersQ(paWidths)
			This.SetHiddenLayers(paWidths)
			return This

	def HiddenLayers()
		return @anHidden

	def SetLearningRate(n)
		if n > 0
			@nLearningRate = n
		ok

		def SetLearningRateQ(n)
			This.SetLearningRate(n)
			return This

	# PLACE POINTS THE FIT NEVER SAW -- one forward pass through the learned network.
	#
	# Only available after LearnMapping(). Ordinary t-SNE has no map to apply, and
	# manufacturing one by re-running the optimisation would be a different answer
	# wearing the same name.
	def Transform(paRows)
		This._MustBeFitted()
		if NOT @bParametric
			stzraise("Ordinary t-SNE has no map to apply -- it optimises the " +
				"positions of the points it was given, so there is nothing to " +
				"place a new point with. Call LearnMapping() before Fit() to train " +
				"a network instead (parametric t-SNE), or use stzUMAP, whose " +
				"neighbour graph extends to new points.")
		ok
		if NOT isList(paRows) or len(paRows) = 0
			stzraise("Give me a list of rows to place.")
		ok

		_nM_ = len(paRows)
		for _i_ = 1 to _nM_
			if NOT isList(paRows[_i_]) or len(paRows[_i_]) != @nCols
				stzraise("Row " + _i_ + " has " + len(paRows[_i_]) +
					" value(s); this model was fitted on " + @nCols + ".")
			ok
		next

		# THROUGH THE SAME PCA, when there was one -- the network's inputs are the
		# components, so a raw row would be the wrong shape and the wrong space
		# THE REDUCED WIDTH, NOT ALL THE COMPONENTS. stzPCA.Transform() returns a
		# score per component it computed -- min(samples, features) of them -- while
		# the fit was given only the first @nPreparedDim. Taking all of them here fed
		# the network a wider input than it was trained on, and the guard caught it:
		# training rows stopped transforming back to their own positions.
		_aNew_ = []
		if @nPcaDims > 0 and @oPca != NULL
			_aS_ = @oPca.Transform(paRows)
			for _i_ = 1 to _nM_
				for _j_ = 1 to @nPreparedDim
					_aNew_ + _aS_[_i_][_j_]
				next
			next
		else
			for _i_ = 1 to _nM_
				for _j_ = 1 to @nCols
					_aNew_ + paRows[_i_][_j_]
				next
			next
		ok

		_aOut_ = StzEnginePtsneTransform(@anShape, @anWeights, _aNew_, _nM_, @nDims)
		if NOT isList(_aOut_) or len(_aOut_) != _nM_ * @nDims
			stzraise("The engine refused the placement.")
		ok

		_aRes_ = []
		_nAt_ = 0
		for _i_ = 1 to _nM_
			_aRow_ = []
			for _j_ = 1 to @nDims
				_nAt_++
				_aRow_ + _aOut_[_nAt_]
			next
			_aRes_ + _aRow_
		next
		return _aRes_

	def Fit()
		_a_ = This._PreparedData()
		_aX_ = _a_[1]
		_nD_ = _a_[2]
		# kept because Transform() must feed the network the SAME width the fit
		# trained on -- see the note there
		@nPreparedDim = _nD_

		if @bParametric
			This._FitParametric(_aX_, _nD_)
			return
		ok

		_aRes_ = StzEngineTsne(_aX_, @nRows, _nD_, @nPerplexity, @nDims,
			@nIterations, @nSeed)
		if NOT isList(_aRes_) or len(_aRes_) < 2
			stzraise("t-SNE refused this run. A perplexity of " + @nPerplexity +
				" needs more than " + @nPerplexity + " points (there are " +
				@nRows + "), and at least 3 points are needed at all.")
		ok

		@nDims = _aRes_[1]
		_nIt_ = _aRes_[2]
		_nAt_ = 2
		@anKL = []
		for _i_ = 1 to _nIt_
			_nAt_++
			@anKL + _aRes_[_nAt_]
		next
		@aEmbedding = []
		for _i_ = 1 to @nRows
			_aRow_ = []
			for _j_ = 1 to @nDims
				_nAt_++
				_aRow_ + _aRes_[_nAt_]
			next
			@aEmbedding + _aRow_
		next
		@bFitted = TRUE

		def FitQ()
			This.Fit()
			return This

	def IsFitted()
		return @bFitted

	def Embedding()
		This._MustBeFitted()
		return @aEmbedding

	# The objective, per iteration. Worth looking at: an embedding is stochastic, and
	# this is the only evidence the optimisation went anywhere.
	def KLHistory()
		This._MustBeFitted()
		return @anKL

	def FinalKL()
		This._MustBeFitted()
		return @anKL[len(@anKL)]

	def Why()
		This._MustBeFitted()
		_c_ = "t-SNE"
		if @bParametric
			_c_ += " (parametric, " + len(@anHidden) + " hidden layer(s))"
		ok
		_c_ += " of " + @nRows + " point(s) into " + @nDims + " dimension(s), " +
			"perplexity " + @nPerplexity + ", " + len(@anKL) + " iterations"
		if @nPcaDims > 0
			_c_ += ", after PCA to " + @nPcaDims + " component(s)"
		ok
		_c_ += "; KL " + @anKL[1] + " -> " + @anKL[len(@anKL)]
		return _c_

	def _FitParametric(paX, nD)
		_aRes_ = StzEnginePtsne(paX, @nRows, nD, @anHidden, @nPerplexity,
			@nDims, @nIterations, @nLearningRate, @nSeed)
		if NOT isList(_aRes_) or len(_aRes_) < 4
			stzraise("Parametric t-SNE refused this run. A perplexity of " +
				@nPerplexity + " needs more than " + @nPerplexity + " points " +
				"(there are " + @nRows + "), and at least one hidden layer.")
		ok

		@nDims = _aRes_[1]
		_nEp_ = _aRes_[2]
		_nSh_ = _aRes_[3]
		_nWt_ = _aRes_[4]
		_nAt_ = 4

		@anKL = []
		for _i_ = 1 to _nEp_
			_nAt_++
			@anKL + _aRes_[_nAt_]
		next
		@anShape = []
		for _i_ = 1 to _nSh_
			_nAt_++
			@anShape + _aRes_[_nAt_]
		next
		@anWeights = []
		for _i_ = 1 to _nWt_
			_nAt_++
			@anWeights + _aRes_[_nAt_]
		next
		@aEmbedding = []
		for _i_ = 1 to @nRows
			_aRow_ = []
			for _j_ = 1 to @nDims
				_nAt_++
				_aRow_ + _aRes_[_nAt_]
			next
			@aEmbedding + _aRow_
		next
		@bFitted = TRUE

	def _PreparedData()
		return StzEmbeddingPrepare(This, @aData, @nRows, @nCols, @nPcaDims)

	def _AdoptPCA(o)
		@oPca = o

	def _MustBeFitted()
		if NOT @bFitted
			stzraise("Fit() me first.")
		ok


class stzUMAP from stzObject

	@aData = []
	@nRows = 0
	@nCols = 0
	@nNeighbors = 15
	@nDims = 2
	@nMinDist = 0.1
	@nSpread = 1.0
	@nEpochs = 200
	@nSeed = 42
	@nPcaDims = 0
	@bFitted = FALSE
	@aEmbedding = []
	@nA = 0
	@nB = 0
	@oPca = NULL
	@aPrepared = []       # the data the fit actually saw (post-PCA when reducing)
	@nPreparedDim = 0

	def init(paData)
		_a_ = StzEmbeddingCheckData(paData)
		@aData = paData
		@nRows = _a_[1]
		@nCols = _a_[2]

	def NumberOfSamples()
		return @nRows

	def NumberOfFeatures()
		return @nCols

	# THE LOCAL/GLOBAL DIAL. Small values see fine structure and fragment; large
	# values see the broad shape and smear detail. The reference implementation
	# defaults to 15.
	def SetNeighbors(n)
		if n >= 2
			@nNeighbors = n
		ok

		def SetNeighborsQ(n)
			This.SetNeighbors(n)
			return This

	def Neighbors()
		return @nNeighbors

	# How tightly points may pack. Smaller packs tighter, which makes clusters look
	# more separated -- an appearance you are choosing, not a finding.
	def SetMinDistance(n)
		if n >= 0
			@nMinDist = n
		ok

		def SetMinDistanceQ(n)
			This.SetMinDistance(n)
			return This

	def SetSpread(n)
		if n > 0
			@nSpread = n
		ok

		def SetSpreadQ(n)
			This.SetSpread(n)
			return This

	def SetDimensions(n)
		if n >= 1
			@nDims = n
		ok

		def SetDimensionsQ(n)
			This.SetDimensions(n)
			return This

	def SetEpochs(n)
		if n > 0
			@nEpochs = n
		ok

		def SetEpochsQ(n)
			This.SetEpochs(n)
			return This

	def SetSeed(n)
		@nSeed = n

		def SetSeedQ(n)
			This.SetSeed(n)
			return This

	def ReduceWithPCA(n)
		if n >= 1
			@nPcaDims = n
		ok

		def ReduceWithPCAQ(n)
			This.ReduceWithPCA(n)
			return This

	def SkipPCA()
		@nPcaDims = 0

		def SkipPCAQ()
			This.SkipPCA()
			return This

	def UsesPCA()
		return @nPcaDims > 0

	def PCAQ()
		return @oPca

	def Fit()
		_a_ = This._PreparedData()
		_aX_ = _a_[1]
		_nD_ = _a_[2]
		# kept because Transform() must measure a new point against THE SAME data the
		# fit saw -- which is the PCA scores when reducing, not the raw features
		@aPrepared = _aX_
		@nPreparedDim = _nD_

		_aRes_ = StzEngineUmap(_aX_, @nRows, _nD_, @nNeighbors, @nDims,
			@nMinDist, @nSpread, @nEpochs, @nSeed)
		if NOT isList(_aRes_) or len(_aRes_) < 3
			stzraise("UMAP refused this run. It needs at least 3 points and a " +
				"neighbour count between 2 and " + (@nRows - 1) + " (asked for " +
				@nNeighbors + ", with " + @nRows + " points).")
		ok

		@nDims = _aRes_[1]
		@nA = _aRes_[2]
		@nB = _aRes_[3]
		_nAt_ = 3
		@aEmbedding = []
		for _i_ = 1 to @nRows
			_aRow_ = []
			for _j_ = 1 to @nDims
				_nAt_++
				_aRow_ + _aRes_[_nAt_]
			next
			@aEmbedding + _aRow_
		next
		@bFitted = TRUE

		def FitQ()
			This.Fit()
			return This

	def IsFitted()
		return @bFitted

	def Embedding()
		This._MustBeFitted()
		return @aEmbedding

	# The fitted similarity curve 1/(1 + a*d^(2b)). Reported because a and b are
	# DERIVED from min_dist and spread by a least-squares fit rather than given, and
	# a caller may reasonably want to see what their setting turned into.
	def CurveParameters()
		This._MustBeFitted()
		return [ :a = @nA, :b = @nB ]

	# PLACE POINTS THE FIT NEVER SAW into the existing map.
	#
	# The new rows go through exactly what the training rows went through: the same
	# PCA (when one was used), then their nearest training neighbours, their own rho
	# and sigma, an initial position at the weighted average of those neighbours'
	# coordinates, and a short refinement with THE TRAINING LAYOUT HELD FIXED. A map
	# that shifted under every lookup would not be a map.
	#
	# This is not a refit. See the note at the top of this file for what that costs.
	def Transform(paRows)
		This._MustBeFitted()
		if NOT isList(paRows) or len(paRows) = 0
			stzraise("Give me a list of rows to place.")
		ok
		_nM_ = len(paRows)
		for _i_ = 1 to _nM_
			if NOT isList(paRows[_i_]) or len(paRows[_i_]) != @nCols
				stzraise("Row " + _i_ + " has " + len(paRows[_i_]) +
					" value(s); this model was fitted on " + @nCols + ".")
			ok
		next

		# THROUGH THE SAME PCA, when there was one. Projecting new rows with their own
		# centering -- or not projecting them at all -- would measure them against the
		# training data in a different space, and every neighbour would be wrong.
		_aNew_ = []
		if @nPcaDims > 0 and @oPca != NULL
			_aS_ = @oPca.Transform(paRows)
			for _i_ = 1 to _nM_
				for _j_ = 1 to @nPreparedDim
					_aNew_ + _aS_[_i_][_j_]
				next
			next
		else
			for _i_ = 1 to _nM_
				for _j_ = 1 to @nCols
					_aNew_ + paRows[_i_][_j_]
				next
			next
		ok

		_aFlatY_ = []
		for _i_ = 1 to @nRows
			for _j_ = 1 to @nDims
				_aFlatY_ + @aEmbedding[_i_][_j_]
			next
		next

		_nK_ = @nNeighbors
		if _nK_ > @nRows
			_nK_ = @nRows
		ok

		_aOut_ = StzEngineUmapTransform(@aPrepared, @nRows, @nPreparedDim,
			_aFlatY_, @nDims, _aNew_, _nM_, _nK_, @nA, @nB, 30, @nSeed)
		if NOT isList(_aOut_) or len(_aOut_) != _nM_ * @nDims
			stzraise("The engine refused the placement.")
		ok

		_aRes_ = []
		_nAt_ = 0
		for _i_ = 1 to _nM_
			_aRow_ = []
			for _j_ = 1 to @nDims
				_nAt_++
				_aRow_ + _aOut_[_nAt_]
			next
			_aRes_ + _aRow_
		next
		return _aRes_

	def Why()
		This._MustBeFitted()
		_c_ = "UMAP of " + @nRows + " point(s) into " + @nDims + " dimension(s), " +
			@nNeighbors + " neighbours, min distance " + @nMinDist +
			", " + @nEpochs + " epochs"
		if @nPcaDims > 0
			_c_ += ", after PCA to " + @nPcaDims + " component(s)"
		ok
		return _c_

	def _PreparedData()
		return StzEmbeddingPrepare(This, @aData, @nRows, @nCols, @nPcaDims)

	def _AdoptPCA(o)
		@oPca = o

	def _MustBeFitted()
		if NOT @bFitted
			stzraise("Fit() me first.")
		ok
