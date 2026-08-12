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
	@bFitted = 0
	@aEmbedding = []
	@anKL = []
	@nDensityLambda = 0   # 0 = ordinary t-SNE -- see PreserveDensity()
	@bDensityAuto = 0 # PreserveDensity() picks by mode; SetDensityWeight() does not
	@nDensitySlope = 0
	@nDensityIntercept = 0
	@anNewRadii = []
	# the data the fit actually saw (post-PCA when reducing). The classic transform
	# measures a new row against THE SAME data the map was built from, so a raw row
	# would be the wrong space as well as possibly the wrong width.
	@aPreparedX = []
	@nDensityFrac = 0.3
	@anLocalRadii = []
	@nDensityCorrelation = 0
	@oPca = ""
	@bParametric = 0
	@nPreparedDim = 0     # the width the fit actually saw (post-PCA when reducing)
	@anHidden = [ 50, 20 ]
	@nLearningRate = 0.01
@anShape = []
	@anWeights = []
	@anDecShape = []      # the inverse decoder -- see LearnInverse()
	@anDecWeights = []
	@anDecHidden = [ 64, 64 ]
	@nDecEpochs = 15000
	@nDecRate = 0.02

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
		@bParametric = 1

		def LearnMappingQ()
			This.LearnMapping()
			return This

	def SkipMapping()
		@bParametric = 0

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
		# WHAT USED TO BE A REFUSAL HERE, AND WHY IT IS NOT ONE ANY MORE.
		#
		# t-SNE AS PUBLISHED HAS NO TRANSFORM. It optimises the positions of the points
		# it was given and nothing else, so a new point has no position and the
		# algorithm offers no way to give it one. That is a true statement about the
		# method, and this method used to stop there.
		#
		# But "the algorithm does not provide one" is not "one cannot be built". What
		# UMAP does for a new point can be done here with t-SNE's OWN objective: freeze
		# the training map, give the new row the same kind of neighbour distribution
		# the fit gave every training row, and minimise the same KL over that single
		# position. Every ingredient was already defined; only the paper declined to
		# combine them.
		#
		# SO THIS IS A CONSTRUCTED EXTENSION AND INHERITS THE PROPERTIES OF ONE. It is
		# APPROXIMATE. Measured, putting all fifty training rows back through it: mean
		# displacement 0.23 of the typical inter-point distance, with half landing
		# nearest their own fitted position. UMAP's published transform gives 0.20 and
		# a quarter; the parametric variant gives zero and all of them, because there
		# the forward pass IS the embedding.
		#
		# Use LearnMapping() when the transform must be exact. Use this when you want
		# the classic layout and can accept a placement that is near rather than on.
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
		if @nPcaDims > 0 and @oPca != ""
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

		if @bParametric
			_aOut_ = StzEnginePtsneTransform(@anShape, @anWeights, _aNew_, _nM_, @nDims)
		else
			# THE CONSTRUCTED EXTENSION: the training map frozen, the same KL minimised
			# over one position at a time.
			_aTrainY_ = []
			for _i_ = 1 to @nRows
				for _j_ = 1 to @nDims
					_aTrainY_ + @aEmbedding[_i_][_j_]
				next
			next
			_bDens_ = 0
			if @nDensityLambda > 0 and @nDensitySlope != 0
				_bDens_ = 1
			ok
			_aOut_ = StzEngineTsneTransform(@aPreparedX, @nRows, @nPreparedDim,
				_aTrainY_, @nDims, _aNew_, _nM_, @nPerplexity, 200, 100,
				@nDensitySlope, @nDensityIntercept, _bDens_)
		ok
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

		# the classic extension measures each new row against the training data on its
		# way past, and hands the radii back with the placement -- see NewLocalRadii()
		@anNewRadii = []
		if len(_aOut_) >= _nAt_ + _nM_
			for _i_ = 1 to _nM_
				_nAt_++
				@anNewRadii + _aOut_[_nAt_]
			next
		ok
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
		@bDensityAuto = 1

		def PreserveDensityQ()
			This.PreserveDensity()
			return This

	def IgnoreDensity()
		@nDensityLambda = 0
		@bDensityAuto = 0

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
			@bDensityAuto = 0
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
	# the radii of the rows the last Transform() placed. The classic extension measures
	# them on its way past; the parametric one cannot, so there it stays empty and
	# LocalRadiiOf() is the way to ask.
	def NewLocalRadii()
		return @anNewRadii

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
		# THE SAME SPACE THE FIT SAW, which is not the space the caller passes.
		#
		# MEASURED, and it was wrong: with a PCA pre-step the fit's own radii are
		# computed on the SCORES (training maximum 0.548874) while this measured the
		# RAW rows (0.337416) -- and 0.337416 was exactly what the no-PCA run produced,
		# which is the tell. The whole out-of-distribution check is "compare the new
		# radius against the training range", so two different unit systems make that
		# comparison meaningless: it can call an outlier familiar or a familiar row
		# strange, depending only on how the components happened to scale.
		#
		# So the new rows go through the SAME PCA the fit used, and are measured
		# against the SAME prepared data. This is the second time in this module that
		# a seam had two computations where it needed one -- see StzEmbeddingPrepare.
		_nW_ = @nCols
		if @nPcaDims > 0 and @oPca != ""
			_aS_ = @oPca.Transform(paRows)
			_aFlat_ = []
			for _i_ = 1 to _nM_
				for _j_ = 1 to @nPreparedDim
					_aFlat_ + _aS_[_i_][_j_]
				next
			next
			_nW_ = @nPreparedDim
		ok
		_nK_ = 15
		if _nK_ > @nRows
			_nK_ = @nRows
		ok
		_aR_ = StzEngineLocalRadiiOfNew(@aPreparedX, @nRows, _nW_, _aFlat_, _nM_, _nK_)
		if NOT isList(_aR_)
			stzraise("The engine refused the measurement.")
		ok
		return _aR_

	# -- THE INVERSE TRANSFORM: from the picture back to the data --
	#
	# Call it AFTER Fit(). It trains a decoder g(y) ~ x against the frozen embedding,
	# so the map already looked at is left exactly as it was.
	#
	# IT WORKS FOR BOTH VARIANTS HERE, free-form and parametric, because the decoder
	# never inverts the encoder: it regresses (position, row) pairs, and both variants
	# have both halves. (A refusal on that point stood briefly in stzUMAP and was wrong.)
	#
	# -- WHETHER YOU NEED IT, WHICH IS MEASURABLE --
	#
	# The alternative is no model: given a point in the map, return the nearest training
	# row. A LOOKUP'S ERROR IS THE SAMPLING GAP -- it hands back a stored row, so it can
	# never be closer to the truth than the nearest row happens to be. A DECODER'S ERROR
	# IS ITS OWN APPROXIMATION ERROR, which owes nothing to sampling density. Whichever
	# is smaller wins.
	#
	# MEASURED on one curve through six dimensions, inverting midpoints between
	# consecutive embedded rows (where the curve gives a true answer):
	#
	#     fit                24 points          90 points
	#                      dec    lookup      dec    lookup
	#     t-SNE           0.1066  0.9025    0.2993  0.7634
	#     t-SNE param     0.0685  0.9186    0.0212  0.2446
	#     UMAP            0.5450  1.1516    0.0858  0.2673
	#     UMAP param      0.2191  0.9886    0.6529  0.4654   <- the only loss
	#
	# THE DECODER WINS IN SEVEN OF EIGHT CELLS, and parametric t-SNE is the best
	# inverter of the four by some way. Which also kills a tidy explanation I offered
	# earlier -- that a parametric encoder is constrained to be smooth and therefore
	# settles somewhere contorted and hard to invert. Parametric t-SNE is parametric and
	# inverts BEST. Invertibility varies by algorithm, thirtyfold across these four, and
	# is not predicted by whether the encoder is a network.
	#
	# -- AND THE LIMIT NO SETTING REMOVES --
	#
	# Two dimensions cannot hold six. The inverse recovers what the embedding KEPT and
	# invents the rest: a plausible row for a location, never a recovered one.
	def LearnInverse()
		This._MustBeFitted()
		_aY_ = []
		for _i_ = 1 to @nRows
			for _j_ = 1 to @nDims
				_aY_ + @aEmbedding[_i_][_j_]
			next
		next
		_aX_ = []
		for _i_ = 1 to @nRows
			for _j_ = 1 to @nPreparedDim
				_aX_ + @aPreparedX[(_i_ - 1) * @nPreparedDim + _j_]
			next
		next
		_aR_ = StzEngineEmbeddingDecoder(_aY_, _aX_, @nRows, @nDims, @nPreparedDim,
			@anDecHidden, @nDecRate, @nDecEpochs, @nSeed)
		if NOT isList(_aR_) or len(_aR_) < 3
			stzraise("The engine refused to train the inverse.")
		ok
		_nSh_ = _aR_[1]
		_nWt_ = _aR_[2]
		_nAt_ = 3
		@anDecShape = []
		for _i_ = 1 to _nSh_
			_nAt_++
			@anDecShape + _aR_[_nAt_]
		next
		@anDecWeights = []
		for _i_ = 1 to _nWt_
			_nAt_++
			@anDecWeights + _aR_[_nAt_]
		next

		def LearnInverseQ()
			This.LearnInverse()
			return This

	def HasInverse()
		return len(@anDecWeights) > 0

	def SetInverseLayers(paWidths)
		if isList(paWidths) and len(paWidths) > 0
			@anDecHidden = paWidths
		ok

		def SetInverseLayersQ(paWidths)
			This.SetInverseLayers(paWidths)
			return This

	# a decoder is a REGRESSION problem and wants far more epochs than the embedding
	# itself did -- measured, [32,32] at 3000 was three times WORSE than a plain lookup
	# and [64,64] at 40000 a third better
	def SetInverseEpochs(n)
		if n > 0
			@nDecEpochs = n
		ok

		def SetInverseEpochsQ(n)
			This.SetInverseEpochs(n)
			return This

	# TAKE POINTS IN THE MAP, RETURN ROWS IN THE DATA. The points need not be positions
	# of training rows -- somewhere between two clusters is exactly the question worth
	# asking, and the answer is a plausible row for that location.
	def Inverse(paPoints)
		This._MustBeFitted()
		if NOT This.HasInverse()
			stzraise("Call LearnInverse() first -- the inverse is a second model, " +
				"trained against the finished embedding, and it does not come with " +
				"the fit.")
		ok
		if NOT isList(paPoints) or len(paPoints) = 0
			stzraise("Give me a list of points in the embedding.")
		ok
		_nM_ = len(paPoints)
		_aP_ = []
		for _i_ = 1 to _nM_
			if NOT isList(paPoints[_i_]) or len(paPoints[_i_]) != @nDims
				stzraise("Point " + _i_ + " has " + len(paPoints[_i_]) +
					" coordinate(s); this map has " + @nDims + ".")
			ok
			for _j_ = 1 to @nDims
				_aP_ + paPoints[_i_][_j_]
			next
		next
		_aOut_ = StzEnginePtsneTransform(@anDecShape, @anDecWeights, _aP_, _nM_, @nPreparedDim)
		if NOT isList(_aOut_) or len(_aOut_) < _nM_ * @nPreparedDim
			stzraise("The engine refused the inversion.")
		ok
		_aRes_ = []
		_nAtI_ = 0
		for _i_ = 1 to _nM_
			_aRow_ = []
			for _j_ = 1 to @nPreparedDim
				_nAtI_++
				_aRow_ + _aOut_[_nAtI_]
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
		@aPreparedX = _aX_

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
		@nDensitySlope = 0
		@nDensityIntercept = 0
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
		@bFitted = 1

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
			@bDensityAuto = 0
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
		@bFitted = 1

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
	@bFitted = 0
	@aEmbedding = []
	@nA = 0
	@nB = 0
	@oPca = ""
	@aPrepared = []       # the data the fit actually saw (post-PCA when reducing)
	@nPreparedDim = 0
	@anLabels = []        # empty for the ordinary fit -- see LearnFromLabels()
	@nTargetWeight = 0.5
	@nDensityLambda = 0   # 0 = ordinary UMAP -- see PreserveDensity()
	@bDensityAuto = 0 # PreserveDensity() picks by mode; SetDensityWeight() does not
	@bParametric = 0  # see LearnMapping()
	@anDecShape = []      # the inverse decoder -- see LearnInverse()
	@anDecWeights = []
	@anDecHidden = [ 64, 64 ]
	@nDecEpochs = 15000
	@nDecRate = 0.02
	@anHidden = [ 50, 20 ]
	@nLearningRate = 0.01
	@anShape = []
	@anWeights = []
	@nDensityFrac = 0.3
@anLocalRadii = []
	@nDensityCorrelation = 0
	@nDensitySlope = 0
	@nDensityIntercept = 0
	@anNewRadii = []
	# the data the fit actually saw (post-PCA when reducing). The classic transform
	# measures a new row against THE SAME data the map was built from, so a raw row
	# would be the wrong space as well as possibly the wrong width.
	@aPreparedX = []

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
		@bDensityAuto = 1

		def PreserveDensityQ()
			This.PreserveDensity()
			return This

	def IgnoreDensity()
		@nDensityLambda = 0
		@bDensityAuto = 0

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
			@bDensityAuto = 0
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

	# -- PARAMETRIC UMAP: let a network hold the map --
	#
	# Sainburg, McInnes and Gentner (2021). The objective does not change at all -- the
	# same fuzzy neighbour graph, the same a/b curve, the same attraction along an edge
	# and repulsion from sampled non-neighbours. What changes is where the answer is
	# allowed to live: instead of moving free coordinates, the layout becomes f(x; W)
	# and the same gradient is pushed back into the weights.
	#
	# -- WHAT IT BUYS --
	#
	# A TRANSFORM THAT IS EXACT. A training row put back through Transform() returns
	# the number it was fitted to; measured displacement 0.0000000000. The ordinary
	# transform re-optimises against a frozen map and gives 0.807 on the same data,
	# with only a quarter of rows landing nearest their own position.
	#
	# -- WHAT IT COSTS --
	#
	# The layout can only be as good as a FUNCTION of x can be. Free coordinates put
	# any point anywhere; a network must send nearby inputs to nearby outputs, so
	# anything the data does not express smoothly cannot be drawn.
	#
	# AND IT INHERITS THE PARAMETRIC BLINDNESS. A row far outside the training range
	# saturates onto an ordinary-looking position -- measured at 0.000001 from a
	# legitimate row. The exactness and the blindness are the same property seen twice.
	# Use LocalRadiiOf() for that; it asks the data, not the model.
	# -- AND WHAT IT DOES TO SUPERVISION, WHICH IS THE PART THAT SURPRISES --
	#
	# Supervision still applies: labels reshape the neighbour graph before any optimiser
	# sees it, so LearnFromLabels() works here exactly as it does for the free-form fit.
	# What differs is HOW MUCH OF IT SURVIVES.
	#
	# MEASURED on randomly placed rows with alternating labels -- data with no class
	# structure at all, so any separation is supervision's doing:
	#
	#     one dataset        free-form  1.179 -> 2.413   (x2.05)
	#                       parametric  1.191 -> 1.635   (x1.37)
	#     another            free-form  0.987 -> 1.597   (x1.62)
	#                       parametric  0.972 -> 1.046   (x1.08)
	#
	# Same direction both times, magnitude quite different -- so the honest claim is
	# that supervision reaches a learned map only PARTLY, not that it barely arrives.
	#
	# THE REASON IS THE PARAMETERISATION, and it cannot be tuned away. y = f(x) is
	# smooth, so two rows close together in x MUST come out close together in y. Free
	# coordinates answer to nothing and can put interleaved points wherever the labels
	# ask; a function cannot. Checked rather than assumed: eight times the parameters
	# and seven times the training buy nothing (2x24/400 -> 1.046, 2x64/1500 -> 0.965,
	# 3x128/3000 -> 1.029).
	#
	# So if the point of supervising is to pull apart classes the geometry does NOT
	# already separate, use SkipMapping() and take the free-form fit -- and give up the
	# exact transform. That is the trade, stated rather than discovered later.
	def LearnMapping()
		@bParametric = 1

		def LearnMappingQ()
			This.LearnMapping()
			return This

	def SkipMapping()
		@bParametric = 0

		def SkipMappingQ()
			This.SkipMapping()
			return This

	def IsParametric()
		return @bParametric

	def SetHiddenLayers(paWidths)
		if isList(paWidths) and len(paWidths) > 0
			@anHidden = paWidths
		ok

		def SetHiddenLayersQ(paWidths)
			This.SetHiddenLayers(paWidths)
			return This

	def HiddenLayers()
		return @anHidden

	# the NETWORK's step size. The free-form optimiser's decaying alpha has no
	# counterpart in the gradient here, so the schedule belongs to the weights.
	#
	# MEASURED, and the reason the gradient is AVERAGED per point rather than summed:
	# with a summed epoch gradient a point's step was proportional to how many edges
	# touched it, and at a learning rate only twice the default every point of a
	# cluster collapsed onto the same output -- while the separation ratio reported
	# 6471293, which reads like a triumph. Averaging made the whole range 0.005 to 0.05
	# behave. A summary ratio is never evidence on its own.
	def SetLearningRate(n)
		if n > 0
			@nLearningRate = n
		ok

		def SetLearningRateQ(n)
			This.SetLearningRate(n)
			return This

	def LearningRate()
		return @nLearningRate

	# -- THE INVERSE TRANSFORM: from the picture back to the data --
	#
	# Everything else here runs one way, data to embedding. This runs the other, and it
	# is the only direction needing a second model, because the forward map threw
	# information away and nothing gets it back.
	#
	# Call it AFTER Fit(). It trains a decoder g(y) ~ x against the frozen embedding, so
	# the map you already looked at is left exactly as it was. (The paper's variant can
	# instead train the whole thing as an autoencoder, which makes the embedding more
	# invertible and LESS faithful to the neighbourhood structure -- a real trade, and
	# one that changes the picture underneath you.)
	#
	# -- WHETHER YOU NEED IT AT ALL, WHICH IS MEASURABLE --
	#
	# The obvious alternative is no model: given a point in the map, return the nearest
	# training row. THE RULE THAT DECIDES BETWEEN THEM:
	#
	#   A LOOKUP'S ERROR IS THE SAMPLING GAP. It returns a stored row, so it can never
	#   be closer to the truth than the nearest row happens to be.
	#
	#   A DECODER'S ERROR IS ITS OWN APPROXIMATION ERROR, which has nothing to do with
	#   how densely the data was sampled.
	#
	#   Whichever is smaller wins.
	#
	# MEASURED on one curve through six dimensions, inverting midpoints between
	# consecutive embedded rows (where the curve gives a true answer):
	#
	#     fit           points     decoder    lookup
	#     free-form        24       0.5450    1.1516
	#     free-form        90       0.0858    0.2673
	#     parametric       24       0.2191    0.9886
	#     parametric       90       0.6529    0.4654    <- the only loss
	#
	# The lookup's error rises as the gaps widen, exactly as the rule says. But note
	# WHICH cell the decoder loses in, because an earlier version of this note said
	# "densely sampled data, skip the model" and that was measured on the parametric fit
	# ALONE. On a free-form embedding the decoder wins at 90 points too, and by threefold.
	#
	# THE REASON IS WORTH KNOWING. A free-form layout answers to nothing, so the
	# optimiser is free to lay a curve out cleanly and y -> x comes out a well-behaved
	# function. A parametric encoder is CONSTRAINED to be smooth in x, and the embedding
	# it settles on can be more contorted -- harder to invert, not easier. At 90 points
	# the free-form decoder scores 0.0858 against the parametric one's 0.6529, sevenfold
	# better on identical data.
	#
	# So the rule stands and the recommendation drawn from it did not: train the decoder
	# unless the data is dense AND the fit is parametric.
	#
	# -- AND THE LIMIT THAT NO SETTING REMOVES --
	#
	# Two dimensions cannot hold thirty. The inverse recovers what the embedding KEPT
	# and invents the rest. It is a plausible row for a location, never a recovered one.
	def LearnInverse()
		This._MustBeFitted()
		# A REFUSAL USED TO STAND HERE, and it was wrong. I reasoned that a free-form
		# fit has "no map to invert, only a list of positions" -- but the decoder never
		# inverts the encoder. It is a separate model regressed on (position, row)
		# pairs, and a free-form fit has both halves exactly as a parametric one does.
		# How the positions were arrived at is not its business.
		_aY_ = []
		for _i_ = 1 to @nRows
			for _j_ = 1 to @nDims
				_aY_ + @aEmbedding[_i_][_j_]
			next
		next
		_aX_ = []
		for _i_ = 1 to @nRows
			for _j_ = 1 to @nPreparedDim
				_aX_ + @aPrepared[(_i_ - 1) * @nPreparedDim + _j_]
			next
		next
		_aR_ = StzEngineEmbeddingDecoder(_aY_, _aX_, @nRows, @nDims, @nPreparedDim,
			@anDecHidden, @nDecRate, @nDecEpochs, @nSeed)
		if NOT isList(_aR_) or len(_aR_) < 3
			stzraise("The engine refused to train the inverse.")
		ok
		_nSh_ = _aR_[1]
		_nWt_ = _aR_[2]
		_nAt_ = 3
		@anDecShape = []
		for _i_ = 1 to _nSh_
			_nAt_++
			@anDecShape + _aR_[_nAt_]
		next
		@anDecWeights = []
		for _i_ = 1 to _nWt_
			_nAt_++
			@anDecWeights + _aR_[_nAt_]
		next

		def LearnInverseQ()
			This.LearnInverse()
			return This

	def HasInverse()
		return len(@anDecWeights) > 0

	def SetInverseLayers(paWidths)
		if isList(paWidths) and len(paWidths) > 0
			@anDecHidden = paWidths
		ok

		def SetInverseLayersQ(paWidths)
			This.SetInverseLayers(paWidths)
			return This

	# CAPACITY DECIDED THIS ONE, and a first reading of an undertrained net nearly sent
	# me the wrong way. Reconstruction error against a nearest-row lookup at 0.9155:
	#
	#     [32,32]   3000 epochs   2.4977    <- three times WORSE than the lookup
	#     [64,64]   3000          0.8947
	#     [64,64]  15000          0.6314
	#     [64,64]  40000          0.5771    <- a third BETTER
	#
	# Hence the defaults of [64,64] and 15000. A decoder is a regression problem and
	# wants far more epochs than the embedding itself did.
	def SetInverseEpochs(n)
		if n > 0
			@nDecEpochs = n
		ok

		def SetInverseEpochsQ(n)
			This.SetInverseEpochs(n)
			return This

	# TAKE POINTS IN THE MAP, RETURN ROWS IN THE DATA.
	#
	# The points do not have to be positions of training rows -- somewhere between two
	# clusters is exactly the question worth asking, and the answer is a plausible row
	# for that location rather than a recovered one.
	def Inverse(paPoints)
		This._MustBeFitted()
		if NOT This.HasInverse()
			stzraise("Call LearnInverse() first -- the inverse is a second model, " +
				"trained against the finished embedding, and it does not come with " +
				"the fit.")
		ok
		if NOT isList(paPoints) or len(paPoints) = 0
			stzraise("Give me a list of points in the embedding.")
		ok
		_nM_ = len(paPoints)
		_aP_ = []
		for _i_ = 1 to _nM_
			if NOT isList(paPoints[_i_]) or len(paPoints[_i_]) != @nDims
				stzraise("Point " + _i_ + " has " + len(paPoints[_i_]) +
					" coordinate(s); this map has " + @nDims + ".")
			ok
			for _j_ = 1 to @nDims
				_aP_ + paPoints[_i_][_j_]
			next
		next
		_aOut_ = StzEnginePtsneTransform(@anDecShape, @anDecWeights, _aP_, _nM_, @nPreparedDim)
		if NOT isList(_aOut_) or len(_aOut_) < _nM_ * @nPreparedDim
			stzraise("The engine refused the inversion.")
		ok
		_aRes_ = []
		_nAt3_ = 0
		for _i_ = 1 to _nM_
			_aRow_ = []
			for _j_ = 1 to @nPreparedDim
				_nAt3_++
				_aRow_ + _aOut_[_nAt3_]
			next
			_aRes_ + _aRow_
		next
		return _aRes_

	def Fit()
		_a_ = This._PreparedData()
		_aX_ = _a_[1]
		_nD_ = _a_[2]
		# kept because Transform() must measure a new point against THE SAME data the
		# fit saw -- which is the PCA scores when reducing, not the raw features
		@aPrepared = _aX_
		@nPreparedDim = _nD_

		if @bParametric
			This._FitParametric(_aX_, _nD_)
			return
		ok

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
		@bFitted = 1

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
		if @nPcaDims > 0 and @oPca != ""
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
		if @bParametric
			# a forward pass, and EXACT -- see LearnMapping()
			_aOut_ = StzEnginePtsneTransform(@anShape, @anWeights, _aNew_, _nM_, @nDims)
			if NOT isList(_aOut_) or len(_aOut_) < _nM_ * @nDims
				stzraise("The engine refused the placement.")
			ok
			_aRes_ = []
			_nAt2_ = 0
			for _i_ = 1 to _nM_
				_aRow_ = []
				for _j_ = 1 to @nDims
					_nAt2_++
					_aRow_ + _aOut_[_nAt2_]
				next
				_aRes_ + _aRow_
			next
			# the network cannot see an outlier, so the radii come from the DATA
			@anNewRadii = This.LocalRadiiOf(paRows)
			return _aRes_
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

	# THE SAME NUMBERS WITHOUT PLACING ANYTHING, measured against the TRAINING DATA.
	#
	# It has to be the data rather than the map, and the parametric variant is why: a
	# network saturates, so a row far outside the training range comes back 0.000001
	# from a legitimate one. The training set has not saturated -- 356 units from
	# anything is 356 units from anything.
	def LocalRadiiOf(paRows)
		This._MustBeFitted()
		if NOT isList(paRows) or len(paRows) = 0
			stzraise("Give me a list of rows.")
		ok
		_nM2_ = len(paRows)
		_aF2_ = []
		for _i_ = 1 to _nM2_
			if NOT isList(paRows[_i_]) or len(paRows[_i_]) != @nCols
				stzraise("Row " + _i_ + " has " + len(paRows[_i_]) +
					" value(s); this model was fitted on " + @nCols + ".")
			ok
			for _j_ = 1 to @nCols
				_aF2_ + paRows[_i_][_j_]
			next
		next
		# THE SAME SPACE THE FIT SAW, which is not the space the caller passes.
		#
		# MEASURED, and it was wrong: with a PCA pre-step the fit's own radii are
		# computed on the SCORES (training maximum 0.548874) while this measured the
		# RAW rows (0.337416) -- and 0.337416 was exactly what the no-PCA run produced,
		# which is the tell. The whole out-of-distribution check is "compare the new
		# radius against the training range", so two different unit systems make that
		# comparison meaningless: it can call an outlier familiar or a familiar row
		# strange, depending only on how the components happened to scale.
		#
		# So the new rows go through the SAME PCA the fit used, and are measured
		# against the SAME prepared data. This is the second time in this module that
		# a seam had two computations where it needed one -- see StzEmbeddingPrepare.
		_nW2_ = @nCols
		if @nPcaDims > 0 and @oPca != ""
			_aS2_ = @oPca.Transform(paRows)
			_aF2_ = []
			for _i_ = 1 to _nM2_
				for _j_ = 1 to @nPreparedDim
					_aF2_ + _aS2_[_i_][_j_]
				next
			next
			_nW2_ = @nPreparedDim
		ok
		_nK2_ = @nNeighbors
		if _nK2_ > @nRows
			_nK2_ = @nRows
		ok
		_aR2_ = StzEngineLocalRadiiOfNew(@aPrepared, @nRows, _nW2_, _aF2_, _nM2_, _nK2_)
		if NOT isList(_aR2_)
			stzraise("The engine refused the measurement.")
		ok
		return _aR2_

	def _FitParametric(paX, nD)
		# -- DENSITY ON A LEARNED MAP IS LARGELY REDUNDANT, and that is the finding --
		#
		# MEASURED on two clusters differing twentyfold in spread:
		#
		#     lambda    correlation    drawn ratio
		#      ~0          0.9940          865.6      <- NO density term at all
		#      0.1         0.9940          865.1
		#      2           0.9940          862.5
		#      10          0.9942         1013.4
		#
		# Plain parametric UMAP already scores 0.994. The density term moves it by two
		# ten-thousandths. A network is a smooth function of its input, so it cannot
		# tear the space: relative spreads carry through on their own, and there is
		# almost nothing left for an explicit term to add. This is the same result the
		# parametric t-SNE work reached from the other side.
		#
		# THE MAGNITUDE IS ANOTHER MATTER ENTIRELY. The true ratio is 22.1 and the
		# drawn one is 865 -- a fortyfold OVERSHOOT. Standardising by the global spread
		# makes a tight cluster nearly a single point to the network, and the map draws
		# it that way. So "density preserved" here means the ORDERING, emphatically not
		# the scale, and the correlation being 0.994 says nothing about the second.
		#
		# The weight resolves small on this path for the same reason it does in stzTSNE:
		# a network's few hundred weights are SHARED by every point, so a strong term
		# deforms the whole function rather than one region. An explicit
		# SetDensityWeight() is obeyed as given.
		_nLam_ = @nDensityLambda
		if @bDensityAuto
			_nLam_ = 0.1
			# record it, so DensityWeight() and Why() report what was used
			@nDensityLambda = _nLam_
			@bDensityAuto = 0
		ok
		_aRes_ = StzEnginePumap(paX, @nRows, nD, @anHidden, @nNeighbors, @nDims,
			@nMinDist, @nSpread, @nEpochs, @nLearningRate, @nSeed,
			@anLabels, @nTargetWeight, _nLam_, @nDensityFrac)
		if NOT isList(_aRes_) or len(_aRes_) < 5
			stzraise("Parametric UMAP refused this run. It needs at least 3 points, " +
				"a neighbour count between 2 and " + (@nRows - 1) + ", and at least " +
				"one hidden layer.")
		ok

		@nDims = _aRes_[1]
		@nA = _aRes_[2]
		@nB = _aRes_[3]
		_nSh_ = _aRes_[4]
		_nWt_ = _aRes_[5]
		_nAt_ = 5

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
		@bFitted = 1

	def Why()
		This._MustBeFitted()
		_c_ = "UMAP"
		if @bParametric
			_c_ += " (parametric, " + len(@anHidden) + " hidden layer(s))"
		ok
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
