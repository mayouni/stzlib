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
	@nDensityLambda = 0   # 0 = ordinary t-SNE -- see PreserveDensity()
	@bDensityAuto = FALSE # PreserveDensity() picks by mode; SetDensityWeight() does not
	@nDensityFrac = 0.3
	@anLocalRadii = []
	@nDensityCorrelation = 0
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

	# -- DENSITY PRESERVATION (den-SNE) --
	#
	# THE SAME TERM AS densMAP, from the same paper, over the same definition of a local
	# radius. What it fixes here is worse than what it fixed there.
	#
	# MEASURED: on data whose two clusters differ TWENTYFOLD in spread, plain t-SNE
	# returns a density correlation of -0.186, +0.099, +0.125, -0.048, +0.168 across
	# five seeds. Scattered around ZERO, negative as often as not. So t-SNE cluster
	# sizes are not merely unreliable -- they are NOISE, and a conclusion drawn from
	# them is a conclusion drawn from the initialisation. (Plain UMAP at least came out
	# consistently positive at +0.226: weak, but pointing the right way.)
	#
	# The Student-t kernel is why: its heavy tail is what solves the crowding problem,
	# and it does that by letting every cluster settle at whatever size the repulsion
	# allows, regardless of how tight the cluster actually was.
	#
	# -- THE DIAL, WHICH HAS AN UNSTABLE BAND --
	#
	#     lambda   seed 42   seed 7   seed 1234
	#      0.5      0.902    0.896     0.827      stable
	#      1.0      0.957    0.965     0.900      stable  <- the default
	#      1.5      0.980    0.894     0.705      widening
	#      2.0     -0.646    0.480     0.910      WILD
	#      4.0      0.938    0.936     0.933      stable again
	#
	# ON THAT DATASET, at lambda 2, THE OUTCOME WAS DECIDED BY THE SEED -- anywhere from
	# -0.65 to +0.91 on identical inputs. A density term of middling strength can drive
	# an oscillation that the adaptive gains then amplify, and the layout settles
	# anti-correlated. Past about 4 it settles again because the term simply dominates,
	# but by then the separation between clusters has collapsed from 7.13 to near 1.
	#
	# THE BAND IS NOT AT A FIXED PLACE, which is the part that matters. On a second
	# dataset the same sweep was well behaved throughout (0.94 at 0.5, 0.90 at 1, 0.97
	# at 10) and nothing was unstable anywhere. So lambda cannot be set once and
	# trusted: WHERE IT WORKS DEPENDS ON THE DATA.
	#
	# WHICH IS WHY DensityCorrelation() IS PART OF THE SURFACE RATHER THAN AN INTERNAL.
	# It is not a diagnostic for the curious -- it is the only way to know the term did
	# what you asked, and a low or negative value means the picture is not
	# density-preserving no matter what was requested. Check it.
	#
	# The default 1.0 is a starting point measured to be reasonable on both datasets,
	# not a guarantee. Note also that stzUMAP's density dial was cleanly MONOTONE and
	# defaults to 2.0 -- same term, different optimiser, and the shape belongs to the
	# optimiser rather than to the term.
	#
	# -- AND HERE THE COST ARRIVES ITEMISED --
	#
	# t-SNE reports its own objective, so unlike UMAP the price is directly visible:
	# KL rises from 0.291 to 0.443 at the default. That is neighbourhood fidelity being
	# spent on density fidelity, in the units of the thing given up.
	def PreserveDensity()
		@nDensityLambda = 1.0
		@bDensityAuto = TRUE

		def PreserveDensityQ()
			This.PreserveDensity()
			return This

	def IgnoreDensity()
		@nDensityLambda = 0
		@bDensityAuto = FALSE

		def IgnoreDensityQ()
			This.IgnoreDensity()
			return This

	def IsDensityPreserving()
		return @nDensityLambda > 0

	# 0 turns the term off EXACTLY -- bit-for-bit the ordinary fit, not a near one.
	# Values between about 1.5 and 3 are the unstable band described above.
	def SetDensityWeight(n)
		if n >= 0
			@nDensityLambda = n
			@bDensityAuto = FALSE
		ok

		def SetDensityWeightQ(n)
			This.SetDensityWeight(n)
			return This

	def DensityWeight()
		return @nDensityLambda

	# the FINAL fraction of iterations during which the term runs. Late on purpose, and
	# for a reason t-SNE has that UMAP does not: EARLY EXAGGERATION multiplies P by 12
	# for the first quarter of the run to force gaps open, so density measured during it
	# would preserve a scale the algorithm is about to throw away.
	def SetDensityPhase(n)
		if n > 0 and n <= 1
			@nDensityFrac = n
		ok

		def SetDensityPhaseQ(n)
			This.SetDensityPhase(n)
			return This

	def DensityPhase()
		return @nDensityFrac

	# how far the term got. NOT a percentage -- an embedding with every density rank
	# backwards still scores around -0.6 rather than -1.
	def DensityCorrelation()
		return @nDensityCorrelation

	# THE ORIGINAL-SPACE LOCAL RADIUS PER POINT: how far each row sits, on average, from
	# the neighbours it is joined to. A DATA PRODUCT -- it ranks rows by isolation with
	# no reference to the embedding, and costs nothing because the term computes it.
	#
	# Weighted here by t-SNE's joint distribution where stzUMAP weights by the fuzzy
	# graph. Two different weightings of the same neighbourhoods, agreeing on which rows
	# are dense.
	def LocalRadii()
		return @anLocalRadii

	# THE OUT-OF-DISTRIBUTION CHECK, and for the parametric variant it is not optional.
	#
	# MEASURED, and the reason this method exists: a row at (20,20,20,20) transforms to
	# (-2.1100, -9.7090) and a row at (200,200,200,200) -- ten times further out in
	# every coordinate than anything the fit ever saw -- transforms to (-2.1118,
	# -9.7117). Three thousandths apart. Bounded activations send everything past a
	# certain magnitude to the same place, so the transform is not merely inaccurate on
	# unfamiliar input, it is STRUCTURALLY BLIND to it, and it fails SILENTLY: what
	# comes back is a perfectly ordinary looking pair of coordinates.
	#
	# So the answer cannot come from the network. This measures the new rows against
	# THE TRAINING DATA, where 356 units from anything is 356 units from anything
	# whatever a model believes. Compare against LocalRadii(): a value far outside that
	# range is a row the map has no business being asked about.
	#
	# Available whether or not the fit preserved density, because it is a property of
	# the data rather than of the map.
	def LocalRadiiOf(paRows)
		This._MustBeFitted()
		if NOT isList(paRows) or len(paRows) = 0
			stzraise("Give me a list of rows.")
		ok
		_nM_ = len(paRows)
		_aFlat_ = []
		for _i_ = 1 to _nM_
			if NOT isList(paRows[_i_]) or len(paRows[_i_]) != @nCols
				stzraise("Row " + _i_ + " has " + len(paRows[_i_]) +
					" value(s); this model was fitted on " + @nCols + ".")
			ok
			for _j_ = 1 to @nCols
				_aFlat_ + paRows[_i_][_j_]
			next
		next
		_aTrain_ = []
		for _i_ = 1 to @nRows
			for _j_ = 1 to @nCols
				_aTrain_ + @aData[_i_][_j_]
			next
		next
		_nK_ = 15
		if _nK_ > @nRows
			_nK_ = @nRows
		ok
		_aR_ = StzEngineLocalRadiiOfNew(_aTrain_, @nRows, @nCols, _aFlat_, _nM_, _nK_)
		if NOT isList(_aR_)
			stzraise("The engine refused the measurement.")
		ok
		return _aR_

	def Fit()
		_a_ = This._PreparedData()
		_aX_ = _a_[1]
		_nD_ = _a_[2]
		# kept because Transform() must feed the network the SAME width the fit
		# trained on -- see the note there
		@nPreparedDim = _nD_

		if @bParametric
			# The refusal that used to stand here is gone, and deservedly: the density
			# gradient is computed on the network's OUTPUTS, and a network takes an
			# output delta and chains it back through its weights like any other. So
			# the term does not act on coordinates the network happens to have
			# produced -- it teaches the network to produce different ones.
			#
			# WHICH IS HOW den-SNE GETS A TRANSFORM AT ALL. The classic algorithm has
			# none: it optimises the points it was given, and a new point has no
			# position. Here the network IS the map, so the transform is a forward pass
			# and is density-preserving BY CONSTRUCTION rather than by a correction
			# applied afterwards -- and exact, not approximate, unlike UMAP's.
			This._FitParametric(_aX_, _nD_)
			return
		ok

		_aRes_ = StzEngineTsne(_aX_, @nRows, _nD_, @nPerplexity, @nDims,
			@nIterations, @nSeed, @nDensityLambda, @nDensityFrac)
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

		# the density block is APPENDED, and only when it was asked for -- so its
		# absence is the signal that this was an ordinary fit, not a failed one
		@anLocalRadii = []
		@nDensityCorrelation = 0
		if @nDensityLambda > 0 and len(_aRes_) >= _nAt_ + 1 + @nRows
			_nAt_++
			@nDensityCorrelation = _aRes_[_nAt_]
			for _i_ = 1 to @nRows
				_nAt_++
				@anLocalRadii + _aRes_[_nAt_]
			next
		ok
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
		if @nDensityLambda > 0
			_c_ += " (density-preserving, weight " + @nDensityLambda + ")"
		ok
		_c_ += " of " + @nRows + " point(s) into " + @nDims + " dimension(s), " +
			"perplexity " + @nPerplexity + ", " + len(@anKL) + " iterations"
		if @nPcaDims > 0
			_c_ += ", after PCA to " + @nPcaDims + " component(s)"
		ok
		_c_ += "; KL " + @anKL[1] + " -> " + @anKL[len(@anKL)]
		return _c_

	def _FitParametric(paX, nD)
		# THE PARAMETRIC MODE NEEDS A MUCH SMALLER WEIGHT, and this is measured rather
		# than tuned by feel. On one dataset the classic default of 1.0 gives +0.992
		# here; on another it gives -0.913, fully inverted, while 0.01 to 0.3 all give
		# 0.98 or better. A network has a few hundred weights SHARED by every point, so
		# an over-strong term does not distort one region -- it deforms the whole
		# function, and the map turns inside out.
		#
		# Only when the caller said PreserveDensity() and left it at that. An explicit
		# SetDensityWeight() is obeyed exactly, including into the range that inverts:
		# it is a stated choice, and the correlation will say what came of it.
		_nLam_ = @nDensityLambda
		if @bDensityAuto
			_nLam_ = 0.1
			# and record it, so DensityWeight() and Why() report the weight that was
			# actually used rather than the one that was asked for
			@nDensityLambda = _nLam_
			@bDensityAuto = FALSE
		ok
		_aRes_ = StzEnginePtsne(paX, @nRows, nD, @anHidden, @nPerplexity,
			@nDims, @nIterations, @nLearningRate, @nSeed,
			_nLam_, @nDensityFrac)
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

		@anLocalRadii = []
		@nDensityCorrelation = 0
		if _nLam_ > 0 and len(_aRes_) >= _nAt_ + 1 + @nRows
			_nAt_++
			@nDensityCorrelation = _aRes_[_nAt_]
			for _i_ = 1 to @nRows
				_nAt_++
				@anLocalRadii + _aRes_[_nAt_]
			next
		ok
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
	@anLabels = []        # empty for the ordinary fit -- see LearnFromLabels()
	@nTargetWeight = 0.5
	@nDensityLambda = 0   # 0 = ordinary UMAP -- see PreserveDensity()
	@nDensityFrac = 0.3
@anLocalRadii = []
	@nDensityCorrelation = 0
	@nDensitySlope = 0
	@nDensityIntercept = 0
	@anNewRadii = []

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

	# ── SUPERVISION: let known labels reshape the graph ──
	#
	# WHAT THIS DOES, because the name promises more than it is. It does NOT learn a
	# classifier and does not predict anything. It REWEIGHTS the neighbour graph the
	# unsupervised algorithm already built: an edge between two points of different
	# classes is made weak, so the layout stops trying to keep them together.
	#
	# Pass one label per sample. A label of -1 means UNKNOWN -- its edges are damped
	# rather than crushed, which is what makes the semi-supervised case work instead
	# of forcing every row to be classified.
	#
	# ── THE WARNING, WHICH MATTERS MORE THAN THE MECHANISM ──
	#
	# A supervised embedding WILL separate your classes. That is what you asked for.
	# It is therefore NOT evidence that the classes are separable, and the picture
	# must never be shown as if it were -- the separation is an input, not a finding.
	# What it is genuinely good for: seeing structure WITHIN classes you already
	# trust, and laying out data whose grouping is not in question so that something
	# else can be looked at.
	def LearnFromLabels(paLabels)
		if NOT isList(paLabels) or len(paLabels) != @nRows
			stzraise("Give me one label per sample -- " + @nRows + " of them, " +
				"got " + len(paLabels) + ". Use -1 where the label is unknown.")
		ok
		@anLabels = paLabels

		def LearnFromLabelsQ(paLabels)
			This.LearnFromLabels(paLabels)
			return This

	def IgnoreLabels()
		@anLabels = []

		def IgnoreLabelsQ()
			This.IgnoreLabels()
			return This

	def IsSupervised()
		return len(@anLabels) > 0

	def Labels()
		return @anLabels

	# HOW MUCH TO TRUST THE LABELS against the data's own structure. 0 ignores them;
	# the reference implementation's default is 0.5.
	#
	# MEASURED, and it is not the shape one would assume: separation rises to about
	# 0.2 and then FALLS, and beyond ~0.9 the setting stops meaning anything at all
	# because the penalty underflows. Crushing every cross-class edge fragments the
	# graph -- points lose most of their neighbours and the classes come apart into
	# pieces instead of two groups. More supervision is not more separation.
	def SetTargetWeight(n)
		if n >= 0 and n <= 1
			@nTargetWeight = n
		ok

		def SetTargetWeightQ(n)
			This.SetTargetWeight(n)
			return This

	def TargetWeight()
		return @nTargetWeight

	# -- DENSITY PRESERVATION (densMAP) --
	#
	# WHAT IT FIXES. Ordinary UMAP preserves NEIGHBOURHOODS and not DENSITY, which is
	# why every honest description of it -- including this one -- tells you that cluster
	# SIZE means nothing. Measured on two clusters whose spreads differ twentyfold,
	# plain UMAP draws them 1.17 times apart. A 20x fact, rendered as 17%.
	#
	# Narayan, Berger and Cho (Nature Biotechnology 2021) add one term: give each point
	# a local radius -- the membership-weighted mean squared distance to the neighbours
	# it is actually joined to -- and ask the layout to keep the original and embedded
	# radii CORRELATED. Cluster size then becomes readable.
	#
	# -- WHAT YOU MAY READ OFF THE RESULT, AND WHAT YOU MAY NOT --
	#
	# The objective is a CORRELATION, so the supported claim is "denser regions are
	# drawn tighter THAN sparser ones". The unsupported one is "area is proportional to
	# density": at the paper default the twentyfold difference above still comes out at
	# 1.31, and only an extreme setting gets it near the truth.
	#
	# -- AND IT IS A TRADE, WHICH THE DEFAULT HIDES BY BEING SMALL --
	#
	# Measured, with the true ratio 19.96:
	#
	#     lambda    correlation    drawn ratio    cluster separation
	#       0          0.226           1.17             7.36
	#       2          0.436           1.31             6.28
	#      30          0.871           1.81             5.85
	#     300          0.993          23.83             1.44
	#
	# Getting the density right COSTS the separation between groups -- the term buys
	# room by spending what the layout was using to hold clusters apart. There is no
	# setting that is simply better: a high lambda answers "how dense is each region"
	# at the expense of "how many groups are there", and the second is usually why the
	# plot was opened. (Note this dial IS monotone, unlike SetTargetWeight() -- do not
	# carry either shape over to the other.)
	def PreserveDensity()
		@nDensityLambda = 2.0

		def PreserveDensityQ()
			This.PreserveDensity()
			return This

	def IgnoreDensity()
		@nDensityLambda = 0
		@bDensityAuto = FALSE

		def IgnoreDensityQ()
			This.IgnoreDensity()
			return This

	def IsDensityPreserving()
		return @nDensityLambda > 0

	# how hard to push. 0 turns the term off entirely, and does so EXACTLY -- the run
	# is bit-for-bit the ordinary fit rather than a near one.
	def SetDensityWeight(n)
		if n >= 0
			@nDensityLambda = n
			@bDensityAuto = FALSE
		ok

		def SetDensityWeightQ(n)
			This.SetDensityWeight(n)
			return This

	def DensityWeight()
		return @nDensityLambda

	# the FINAL fraction of epochs during which the term is active. It is switched on
	# late deliberately: on a random start the embedded radii are noise, so their
	# correlation with anything is noise, and its gradient is noise with a lever arm.
	def SetDensityPhase(n)
		if n > 0 and n <= 1
			@nDensityFrac = n
		ok

		def SetDensityPhaseQ(n)
			This.SetDensityPhase(n)
			return This

	def DensityPhase()
		return @nDensityFrac

	# HOW FAR THE TERM ACTUALLY GOT: the correlation between original and embedded
	# log-radii at the end of the run. Reported rather than hidden because it is the
	# only evidence the extra work achieved anything.
	#
	# It is NOT a percentage. An embedding that gets every density rank BACKWARDS can
	# still score around -0.6 rather than -1, because reversing an order is not the
	# same as negating it.
	def DensityCorrelation()
		return @nDensityCorrelation

	# THE ORIGINAL-SPACE LOCAL RADIUS PER POINT -- how far each row sits, on average,
	# from the neighbours it is joined to. Small means it sits in a crowd.
	#
	# This is a DATA PRODUCT, not a by-product of drawing: it ranks rows by isolation
	# and is meaningful with no reference to the embedding at all. Use it to find
	# outliers or to weight a downstream model. It costs nothing extra, because the
	# density term has to compute it anyway.
	def LocalRadii()
		return @anLocalRadii

	def Fit()
		_a_ = This._PreparedData()
		_aX_ = _a_[1]
		_nD_ = _a_[2]
		# kept because Transform() must measure a new point against THE SAME data the
		# fit saw -- which is the PCA scores when reducing, not the raw features
		@aPrepared = _aX_
		@nPreparedDim = _nD_

		_aRes_ = StzEngineUmap(_aX_, @nRows, _nD_, @nNeighbors, @nDims,
			@nMinDist, @nSpread, @nEpochs, @nSeed, @anLabels, @nTargetWeight,
			@nDensityLambda, @nDensityFrac)
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

		# the density block is APPENDED, and only when it was asked for -- so its
		# absence is the signal that this was an ordinary fit, not a failed one
		@anLocalRadii = []
		@nDensityCorrelation = 0
		if @nDensityLambda > 0 and len(_aRes_) >= _nAt_ + 1 + @nRows
			_nAt_++
			@nDensityCorrelation = _aRes_[_nAt_]
			for _i_ = 1 to @nRows
				_nAt_++
				@anLocalRadii + _aRes_[_nAt_]
			next
			if len(_aRes_) >= _nAt_ + 2
				@nDensitySlope = _aRes_[_nAt_ + 1]
				@nDensityIntercept = _aRes_[_nAt_ + 2]
			ok
		ok
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

		# THE FIT'S DENSITY CONTRACT, CARRIED TO POINTS IT NEVER SAW.
		#
		# Without this the object keeps two contracts at once: the map says a point's
		# distance from its neighbours means density, and then new points are placed by
		# a rule that ignores density entirely. MEASURED, on a map whose own density
		# correlation was 0.81: a new row sitting 356 units from anything in the
		# training set -- 6700 times further out than a tight-cluster row -- was drawn
		# 1.03 times further out. Indistinguishable from an ordinary member.
		#
		# The mechanism cannot be the fit's, because the fit maximises a CORRELATION
		# over every point and one new point has nothing to correlate against. What
		# carries over is the LINE the fit leaves behind, which extrapolates.
		_bDens_ = 0
		if @nDensityLambda > 0 and @nDensitySlope != 0
			_bDens_ = 1
		ok
		_aOut_ = StzEngineUmapTransform(@aPrepared, @nRows, @nPreparedDim,
			_aFlatY_, @nDims, _aNew_, _nM_, _nK_, @nA, @nB, 30, @nSeed,
			@nDensitySlope, @nDensityIntercept, _bDens_)
		if NOT isList(_aOut_) or len(_aOut_) < _nM_ * @nDims
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

		# the new rows' own local radii come back with the placement, always -- see
		# NewLocalRadii()
		@anNewRadii = []
		for _i_ = 1 to _nM_
			_nAt_++
			@anNewRadii + _aOut_[_nAt_]
		next
		return _aRes_

	# THE LOCAL RADII OF THE ROWS THE LAST Transform() PLACED. How far each new row
	# sits, on average, from the training rows nearest it -- IN THE ORIGINAL SPACE.
	#
	# This is the counterpart of LocalRadii() for unseen data, and it is the piece worth
	# having even if the picture is never drawn. A value far outside the training range
	# says the model is being asked about a region it has no evidence for. The training
	# rows here span roughly 0.006 to 1.8; a genuinely unfamiliar row measured 356.
	#
	# Computed whether or not density preservation is on, because it is a property of
	# the data rather than of the placement, and it costs nothing -- the transform has
	# to measure those distances anyway.
	def NewLocalRadii()
		return @anNewRadii

	# the same numbers for rows you have not placed, without placing them
	def LocalRadiiOf(paRows)
		This.Transform(paRows)
		return @anNewRadii

	def Why()
		This._MustBeFitted()
		_c_ = "UMAP"
		if len(@anLabels) > 0
			_c_ += " (supervised, target weight " + @nTargetWeight + ")"
		ok
		if @nDensityLambda > 0
			_c_ += " (density-preserving, weight " + @nDensityLambda + ")"
		ok
		_c_ += " of " + @nRows + " point(s) into " + @nDims + " dimension(s), " +
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
