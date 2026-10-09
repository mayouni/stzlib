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

# THE PERSISTED k-NN VARIANT ROWS reach the stats DLL here (GS6e). The foundry
# records its verdict under the op name "umap_knn" in the GPU calibration file
# (stz_gpu.ring replays that file into its own tables at load); the stats DLL
# has its own device and its own table, so the rows are pushed across once, at
# the first fit -- order-proof, whichever loader ran first.
$bStzUmapKnnVariantsSynced_ = 0

func StzUmapKnnVariantsSync()
	if $bStzUmapKnnVariantsSynced_
		return
	ok
	$bStzUmapKnnVariantsSynced_ = 1
	# the persisted rows are read from the default calibration file first: it
	# loads without a device, fill-only, and a process that never opened the
	# stzGpu face has not replayed it yet
	StzGpuLoadCalibrationDefault()
	_aRows_ = StzGpuVariants()
	_n_ = len(_aRows_)
	for _i_ = 1 to _n_
		_r_ = _aRows_[_i_]
		if _r_[1] = "umap_knn"
			# rows are [ op, k, n, d, variant ]
			StzEngineUmapKnnVariantSet(_r_[3], _r_[4], _r_[2], _r_[5])
		ok
	next

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
# Returns [ the data as ROWS, dimension ]. When no reduction is asked for, or when
# the data already has fewer features than components requested, the data passes
# through unchanged rather than being padded to a size it does not have.
#
# THE FLATTENING TAX (2026-09-10). This used to append every number into a flat
# list before the engine call -- n*d appends in Ring, which at 16,384 x 8 or
# 20,000 x 256 outweighed the fit itself once the fit ran on the device. The
# bridge walks rows itself now, so the rows go as they are; what this returns is
# consumed only by engine calls, which take either shape.
# AND IT RETURNS A REFERENCE, NOT A COPY. Ring copies a list on every assignment
# -- measured 2026-09-10: one copy of 16,384 x 8 rows is 20-200 ms, of 20,000 x
# 256 rows 700 ms -- and there were three between Fit() and the engine call
# (the wrap, the unwrap, the member). ref() makes each of them free; the rows
# stay alive by reference counting, verified across a function return.
func StzEmbeddingPrepare(poOwner, paData, nRows, nCols, nPcaDims)
	if nPcaDims <= 0 or nPcaDims >= nCols
		return [ ref(paData), nCols ]
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

	if _nK_ = len(_aS_[1])
		return [ ref(_aS_), _nK_ ]
	ok
	# fewer components than the scores carry: the rows are cut to width, as rows
	_aCut_ = []
	for _i_ = 1 to nRows
		_aRow_ = []
		for _j_ = 1 to _nK_
			_aRow_ + _aS_[_i_][_j_]
		next
		_aCut_ + _aRow_
	next
	return [ ref(_aCut_), _nK_ ]


# Draws a map of high-dimensional samples in 2 dimensions in which points that are near in the data stay near, using t-SNE.
#
# Built for LOOKING at data, not for measuring it: the map is nonlinear, random and one-way,
# distances and cluster sizes in it mean nothing, and the perplexity changes the picture, so try two
# values. The usual pipeline is ReduceWithPCA(30) then Fit. The run is seeded: the same SetSeed
# gives the same embedding, a different one a different layout. Fit refuses a perplexity that is not
# below the number of samples, so small data needs SetPerplexity first (the default is 30). Ordinary
# t-SNE can place new rows with Transform only approximately; LearnMapping switches to the
# parametric variant, whose Transform is exact for the training rows. PreserveDensity adds a term
# that makes cluster size more readable, and LearnInverse trains a network that goes back from the
# map to the data. Trustworthiness is the witness that the picture invented no neighbours.
#
#   receiver   o1 = new stzTSNE([ [0,0,0], [0.1,0,0.1], [0,0.2,0], [0.2,0.1,0.1], [0.1,0.2,0.2],
#              [0.2,0.2,0], [5,5,5], [5.1,5,5.1], [5,5.2,5], [5.2,5.1,5.1], [5.1,5.2,5.2],
#              [5.2,5.2,5] ])
#   example    o1.SetPerplexity(3)
#              o1.SetIterations(120)
#              o1.Fit()
#              ? o1.IsFitted()
#              #--> 1
#              ? len(o1.Embedding())
#              #--> 12
#              ? o1.Trustworthiness() > 0.5
#              #--> 1
#   see        stzUMAP, stzPCA
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

	# Builds a t-SNE embedding job around a table of samples, one list of feature values per sample.
	#
	#   paData     the samples, a list of equal-length lists of numbers
	#   returns    nothing; the object is built
	#   warning    an empty list, a sample that is not a list, or samples of different widths raise
	#              an error naming the first bad sample
	#   see        Fit, SetPerplexity, ReduceWithPCA
	def init(paData)
		_a_ = StzEmbeddingCheckData(paData)
		@aData = paData
		@nRows = _a_[1]
		@nCols = _a_[2]

	# Returns how many samples the job was built with.
	#
	#   returns    a number
	#   see        NumberOfFeatures, Embedding
	def NumberOfSamples()
		return @nRows

	# Returns how many feature values each sample has.
	#
	#   returns    a number
	#   see        NumberOfSamples
	def NumberOfFeatures()
		return @nCols

	# Sets the perplexity, roughly how many neighbours should count for each point; 30 by default.
	#
	#   n          the perplexity, a number above 0, anything else is ignored
	#   returns    nothing; use SetPerplexityQ to chain
	#   note       small values show fine structure and can split a real cluster, large values show
	#              the broad shape and can merge two
	#   warning    Fit refuses to run when the perplexity is not smaller than the number of samples
	#   see        Perplexity, Fit
	#@ aka  ── the dials ──
	def SetPerplexity(n)
		if n > 0
			@nPerplexity = n
		ok

		def SetPerplexityQ(n)
			This.SetPerplexity(n)
			return This

	# Returns the perplexity in force.
	#
	#   returns    a number; 30 by default
	#   see        SetPerplexity
	def Perplexity()
		return @nPerplexity

	# Sets how many coordinates each point gets in the embedding; 2 by default.
	#
	#   n          the number of output dimensions, 1 or more, anything else is ignored
	#   returns    nothing; use SetDimensionsQ to chain
	#   see        Fit, Embedding
	def SetDimensions(n)
		if n >= 1
			@nDims = n
		ok

		def SetDimensionsQ(n)
			This.SetDimensions(n)
			return This

	# Sets how many optimisation steps the fit takes; 1000 by default.
	#
	#   n          the number of iterations, above 0, anything else is ignored
	#   returns    nothing; use SetIterationsQ to chain
	#   note       few iterations leave the layout unsettled, and the coordinates large
	#   see        Fit, KLHistory
	def SetIterations(n)
		if n > 0
			@nIterations = n
		ok

		def SetIterationsQ(n)
			This.SetIterations(n)
			return This

	# Sets the number that starts the random generator, so a run can be repeated or varied; 42 by default.
	#
	#   n          the starting number
	#   returns    nothing; use SetSeedQ to chain
	#   note       the same value gives the same embedding, a different one gives a different layout
	#   see        Fit
	def SetSeed(n)
		@nSeed = n

		def SetSeedQ(n)
			This.SetSeed(n)
			return This

	# Asks for a PCA down to n dimensions before the embedding, the usual first step; off by default.
	#
	#   n          the number of components to keep, 1 or more, anything else is ignored
	#   returns    nothing; use ReduceWithPCAQ to chain
	#   note       it speeds up the distances and removes noise, at the cost of any structure the
	#              discarded components held
	#   warning    when n is not below the number of features the data goes through unchanged and no
	#              PCA is run
	#   see        SkipPCA, UsesPCA, PCAQ
	#@ aka  PCA to n dimensions before embedding -- the standard pipeline. See the note at the top of this file for why it is two benefits and one cost.
	def ReduceWithPCA(n)
		if n >= 1
			@nPcaDims = n
		ok

		def ReduceWithPCAQ(n)
			This.ReduceWithPCA(n)
			return This

	# Turns off the PCA step, so the fit uses the raw features.
	#
	#   returns    nothing; use SkipPCAQ to chain
	#   see        ReduceWithPCA, UsesPCA
	def SkipPCA()
		@nPcaDims = 0

		def SkipPCAQ()
			This.SkipPCA()
			return This

	# TRUE if a PCA reduction has been requested.
	#
	#   returns    TRUE or FALSE
	#   see        ReduceWithPCA, PCAQ
	def UsesPCA()
		return @nPcaDims > 0

	# Returns the PCA that the last fit ran before embedding, so its explained variance can be read.
	#
	#   returns    a stzPCA object; "" before a fit that used PCA
	#   see        ReduceWithPCA, UsesPCA
	#@ aka  the inner analysis, when there was one -- so a caller can ask how much variance survived the reduction before reading anything into the picture
	def PCAQ()
		return @oPca

	# Switches to the parametric variant, which trains a neural network from features to coordinates instead of moving free points.
	#
	#   returns    nothing; use LearnMappingQ to chain
	#   note       training rows transform back to their own embedding exactly (largest difference 0
	#              on twelve points)
	#   warning    it trades some picture quality for the ability to place new points exactly
	#   see        SkipMapping, Transform, SetHiddenLayers
	#@ aka  ── the parametric variant, which is what gives t-SNE a Transform() ──
	def LearnMapping()
		@bParametric = 1

		def LearnMappingQ()
			This.LearnMapping()
			return This

	# Switches back to the ordinary t-SNE, where points move freely.
	#
	#   returns    nothing; use SkipMappingQ to chain
	#   see        LearnMapping, IsParametric
	def SkipMapping()
		@bParametric = 0

		def SkipMappingQ()
			This.SkipMapping()
			return This

	# TRUE if the parametric variant is switched on.
	#
	#   returns    TRUE or FALSE
	#   see        LearnMapping, SkipMapping
	def IsParametric()
		return @bParametric

	# Sets the widths of the hidden layers of the network of the parametric variant; 50 and 20 by default.
	#
	#   paWidths   the layer widths, a list of numbers, an empty list or another value is ignored
	#   returns    nothing; use SetHiddenLayersQ to chain
	#   see        HiddenLayers, LearnMapping
	#@ aka  The hidden layer widths. The output layer is always LINEAR and as wide as the embedding, because a coordinate is unbounded and squashing it through a tanh would cap the layout at a box.
	def SetHiddenLayers(paWidths)
		if isList(paWidths) and len(paWidths) > 0
			@anHidden = paWidths
		ok

		def SetHiddenLayersQ(paWidths)
			This.SetHiddenLayers(paWidths)
			return This

	# Returns the hidden layer widths of the parametric variant.
	#
	#   returns    a list of numbers; [ 50, 20 ] by default
	#   see        SetHiddenLayers
	def HiddenLayers()
		return @anHidden

	# Sets the step size of the network of the parametric variant; 0.01 by default.
	#
	#   n          the learning rate, above 0, anything else is ignored
	#   returns    nothing; use SetLearningRateQ to chain
	#   see        LearnMapping, SetHiddenLayers
	def SetLearningRate(n)
		if n > 0
			@nLearningRate = n
		ok

		def SetLearningRateQ(n)
			This.SetLearningRate(n)
			return This

	# Places new rows in the existing map, one forward pass of the network for the parametric variant, a constrained optimisation otherwise.
	#
	#   paRows     the new samples, each with as many feature values as the training samples
	#   returns    a list of coordinate rows, one per new row
	#   note       the map does not rearrange for the new point: a point unlike the training data is
	#              still placed among the nearest training points
	#   warning    it raises Fit() me first. before a fit, and an error naming the row when a row
	#              has the wrong width or the list is empty; for the ordinary variant the placement
	#              is approximate, near the right place rather than on it
	#   see        LearnMapping, NewLocalRadii, LocalRadiiOf
	#@ aka  PLACE POINTS THE FIT NEVER SAW -- one forward pass through the learned network.
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

	# Turns on the density term (den-SNE) so denser regions are drawn tighter; the weight becomes 1, or 0.1 when parametric.
	#
	#   returns    nothing; use PreserveDensityQ to chain
	#   note       it makes cluster size more readable, at the cost of some separation between
	#              clusters
	#   see        IgnoreDensity, SetDensityWeight, DensityCorrelation
	#@ aka  -- DENSITY PRESERVATION (den-SNE) --
	def PreserveDensity()
		@nDensityLambda = 1.0
		@bDensityAuto = 1

		def PreserveDensityQ()
			This.PreserveDensity()
			return This

	# Turns the density term off.
	#
	#   returns    nothing; use IgnoreDensityQ to chain
	#   see        PreserveDensity, IsDensityPreserving
	def IgnoreDensity()
		@nDensityLambda = 0
		@bDensityAuto = 0

		def IgnoreDensityQ()
			This.IgnoreDensity()
			return This

	# TRUE if the density weight is above 0.
	#
	#   returns    TRUE or FALSE
	#   see        PreserveDensity, DensityWeight
	def IsDensityPreserving()
		return @nDensityLambda > 0

	# Sets how hard the density term pushes; 0 turns it off exactly.
	#
	#   n          the weight, 0 or more, a negative value is ignored
	#   returns    nothing; use SetDensityWeightQ to chain
	#   note       with 0 the embedding is identical to the ordinary fit, value for value (twelve
	#              points, same seed)
	#   see        DensityWeight, PreserveDensity
	#@ aka  0 turns the term off EXACTLY -- bit-for-bit the ordinary fit, not a near one. Values between about 1.5 and 3 are the unstable band described above.
	def SetDensityWeight(n)
		if n >= 0
			@nDensityLambda = n
			@bDensityAuto = 0
		ok

		def SetDensityWeightQ(n)
			This.SetDensityWeight(n)
			return This

	# Returns the weight of the density term.
	#
	#   returns    a number; 0 by default
	#   see        SetDensityWeight, IsDensityPreserving
	def DensityWeight()
		return @nDensityLambda

	# Sets the last fraction of the iterations during which the density term is active; 0.3 by default.
	#
	#   n          the fraction, above 0 and at most 1, anything else is ignored
	#   returns    nothing; use SetDensityPhaseQ to chain
	#   see        DensityPhase, SetDensityWeight
	#@ aka  the FINAL fraction of iterations during which the term runs. Late on purpose, and for a reason t-SNE has that UMAP does not: EARLY EXAGGERATION multiplies P by 12 for the first quarter of the run to force gaps open, so density measured during it would preserve a scale the algorithm is about to throw away.
	def SetDensityPhase(n)
		if n > 0 and n <= 1
			@nDensityFrac = n
		ok

		def SetDensityPhaseQ(n)
			This.SetDensityPhase(n)
			return This

	# Returns the fraction of the iterations during which the density term runs.
	#
	#   returns    a number; 0.3 by default
	#   see        SetDensityPhase
	def DensityPhase()
		return @nDensityFrac

	# Returns how closely the drawn local radii follow the original ones at the end of a fit with the density term on.
	#
	#   returns    a number from -1 to 1; 0 when the term is off or before a fit
	#   note       it is a correlation, not a percentage
	#   see        PreserveDensity, LocalRadii
	#@ aka  how far the term got. NOT a percentage -- an embedding with every density rank backwards still scores around -0.6 rather than -1.
	def DensityCorrelation()
		return @nDensityCorrelation

	# Returns the average distance of each sample to its neighbours in the original space, as measured by a fit with the density term on.
	#
	#   returns    a list of numbers, one per sample; [ ] when the term is off
	#   see        DensityCorrelation, LocalRadiiOf
	#@ aka  THE ORIGINAL-SPACE LOCAL RADIUS PER POINT: how far each row sits, on average, from the neighbours it is joined to. A DATA PRODUCT -- it ranks rows by isolation with no reference to the embedding, and costs nothing because the term computes it.
	def LocalRadii()
		return @anLocalRadii

	# Returns the local radii of the rows placed by the last Transform.
	#
	#   returns    a list of numbers, one per placed row; [ ] before any Transform
	#   note       a large value warns that a new row lies outside the region the map was fitted on
	#   see        Transform, LocalRadiiOf
	#@ aka  THE OUT-OF-DISTRIBUTION CHECK, and for the parametric variant it is not optional.
	def NewLocalRadii()
		return @anNewRadii

	# Returns how far each given row sits from its neighbours in the training data, without placing anything.
	#
	#   paRows     the rows to measure, each with as many feature values as the training samples
	#   returns    a list of numbers, one per row
	#   warning    it raises before a fit and for rows of the wrong width
	#   see        NewLocalRadii, Transform
	def LocalRadiiOf(paRows)
		This._MustBeFitted()
		if NOT isList(paRows) or len(paRows) = 0
			stzraise("Give me a list of rows.")
		ok
		_nM_ = len(paRows)
		_aFlat_ = ref(paRows)
		for _i_ = 1 to _nM_
			if NOT isList(paRows[_i_]) or len(paRows[_i_]) != @nCols
				stzraise("Row " + _i_ + " has " + len(paRows[_i_]) +
					" value(s); this model was fitted on " + @nCols + ".")
			ok
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
			# THE FLATTENING TAX (2026-09-10): the scores go as rows, cut to the
			# fitted width only when the PCA carries more components than the fit used
			_aFlat_ = ref(_aS_)
			if @nPreparedDim < len(_aS_[1])
				_aFlat_ = []
				for _i_ = 1 to _nM_
					_aRow_ = []
					for _j_ = 1 to @nPreparedDim
						_aRow_ + _aS_[_i_][_j_]
					next
					_aFlat_ + _aRow_
				next
			ok
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

	# Trains a second network that maps points of the embedding back to rows of data.
	#
	#   returns    nothing; use LearnInverseQ to chain
	#   warning    it needs a fitted job; training is slow with the default 15000 epochs, so a small
	#              job sets SetInverseEpochs first
	#   see        Inverse, HasInverse, SetInverseLayers
	#@ aka  -- THE INVERSE TRANSFORM: from the picture back to the data --
	def LearnInverse()
		This._MustBeFitted()
		# THE FLATTENING TAX (2026-09-10): the embedding goes as rows
		_aY_ = ref(@aEmbedding)
		# the prepared data is rows; the bridge walks them
		_aR_ = StzEngineEmbeddingDecoder(_aY_, @aPreparedX, @nRows, @nDims, @nPreparedDim,
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

	# TRUE if an inverse network has been trained.
	#
	#   returns    TRUE or FALSE
	#   see        LearnInverse, Inverse
	def HasInverse()
		return len(@anDecWeights) > 0

	# Sets the hidden layer widths of the inverse network; 64 and 64 by default.
	#
	#   paWidths   the layer widths, a list of numbers, an empty list or another value is ignored
	#   returns    nothing; use SetInverseLayersQ to chain
	#   see        LearnInverse, SetInverseEpochs
	def SetInverseLayers(paWidths)
		if isList(paWidths) and len(paWidths) > 0
			@anDecHidden = paWidths
		ok

		def SetInverseLayersQ(paWidths)
			This.SetInverseLayers(paWidths)
			return This

	# Sets how many epochs the inverse network trains for; 15000 by default.
	#
	#   n          the number of epochs, above 0, anything else is ignored
	#   returns    nothing; use SetInverseEpochsQ to chain
	#   see        LearnInverse, SetInverseLayers
	#@ aka  a decoder is a REGRESSION problem and wants far more epochs than the embedding itself did -- measured, [32,32] at 3000 was three times WORSE than a plain lookup and [64,64] at 40000 a third better
	def SetInverseEpochs(n)
		if n > 0
			@nDecEpochs = n
		ok

		def SetInverseEpochsQ(n)
			This.SetInverseEpochs(n)
			return This

	# Returns rows of data for points of the embedding, using the inverse network.
	#
	#   paPoints   points of the map, each with as many coordinates as the embedding
	#   returns    a list of rows, one per point
	#   note       the rows come back in the space the fit saw, so with a PCA step they are PCA
	#              scores, not the original features
	#   warning    it raises before LearnInverse, and for a point with the wrong number of
	#              coordinates
	#   see        LearnInverse, HasInverse
	#@ aka  TAKE POINTS IN THE MAP, RETURN ROWS IN THE DATA. The points need not be positions of training rows -- somewhere between two clusters is exactly the question worth asking, and the answer is a plausible row for that location.
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

	# Runs the embedding of the samples, and stores the coordinates and the cost history.
	#
	#   returns    nothing; use FitQ to chain
	#   warning    it raises an error when the perplexity is too large for the number of samples,
	#              and when there are fewer than 3 samples
	#   see        Embedding, IsFitted, Why
	def Fit()
		_a_ = This._PreparedData()
		_aX_ = ref(_a_[1])
		_nD_ = _a_[2]
		# kept because Transform() must feed the network the SAME width the fit
		# trained on -- see the note there; by reference, not by copy
		@nPreparedDim = _nD_
		@aPreparedX = ref(_a_[1])

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

	# TRUE if Fit has run.
	#
	#   returns    TRUE or FALSE
	#   see        Fit
	def IsFitted()
		return @bFitted

	# Returns the coordinates of every sample after the fit.
	#
	#   returns    a list with one list of coordinates per sample
	#   note       distances and cluster sizes in the picture are not meaningful, only which points
	#              are near
	#   warning    it raises Fit() me first. before a fit
	#   see        Fit, Trustworthiness
	def Embedding()
		This._MustBeFitted()
		return @aEmbedding

	# Returns how faithful the embedding is to the neighbourhoods of the original data, from 0 to 1, looking at 5 neighbours.
	#
	#   returns    a number from 0 to 1; 1 means no false neighbour was invented
	#   note       two separated clusters of six points gave about 0.83 with only 120 iterations
	#   warning    it raises before a fit
	#   see        TrustworthinessAt, Embedding
	#@ aka  THE WITNESS (Venna & Kaski 2006, as scikit-learn computes it): 1.0 when the embedding invented no neighbour; every neighbour a point gained in the map that was not among its k nearest in the input is charged by how far down the input ordering it really sat. Needs only the data the fit saw and the embedding -- no labels, no generator -- and it is the number the field compares on. Computed by the en
	def Trustworthiness()
		return This.TrustworthinessAt(5)

	# Returns the trustworthiness of the embedding for a chosen number of neighbours.
	#
	#   nK         how many nearest neighbours to compare
	#   returns    a number from 0 to 1
	#   warning    it raises before a fit
	#   see        Trustworthiness
	def TrustworthinessAt(nK)
		This._MustBeFitted()
		return StzEngineEmbeddingTrustworthiness(@aPreparedX, @nRows, @nPreparedDim, @aEmbedding, @nDims, nK, 0)

	# Returns the cost of the optimisation at each iteration, the only evidence of how the run went.
	#
	#   returns    a list of numbers, one per iteration
	#   note       the list has as many entries as the iterations
	#   warning    it raises before a fit
	#   see        FinalKL, SetIterations
	#@ aka  The objective, per iteration. Worth looking at: an embedding is stochastic, and this is the only evidence the optimisation went anywhere.
	def KLHistory()
		This._MustBeFitted()
		return @anKL

	# Returns the cost at the last iteration.
	#
	#   returns    a number
	#   warning    it raises before a fit
	#   see        KLHistory
	def FinalKL()
		This._MustBeFitted()
		return @anKL[len(@anKL)]

	# Returns one sentence describing the fit: variant, size, perplexity, iterations, PCA step and the cost from first to last iteration.
	#
	#   returns    a text
	#   warning    it raises before a fit
	#   see        Fit, KLHistory
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


# Draws a map of high-dimensional samples in 2 dimensions from a neighbour graph, using UMAP, and can place new rows in it.
#
# Built for LOOKING at data, not for measuring it: distances and cluster sizes in the map mean
# nothing, and the neighbour count changes the picture, so try two values. The usual pipeline is
# ReduceWithPCA(30) then Fit. The default of 15 neighbours needs more than 15 samples, so small data
# needs SetNeighbors first. The neighbour graph is held in the engine after the first Fit: changing
# the minimum distance, the spread, the epochs or the seed redoes the layout only, while changing
# the neighbours, the labels or the PCA step drops the graph. LearnFromLabels reweights the graph
# with known classes, and the separation it gives is an input, not a finding. Unlike t-SNE,
# Transform places new rows against the frozen map, and LearnMapping makes that exact for the
# training rows. PreserveDensity adds the densMAP term, and LearnInverse trains a network that goes
# back from the map to the data.
#
#   receiver   o1 = new stzUMAP([ [0,0,0], [0.1,0,0.1], [0,0.2,0], [0.2,0.1,0.1], [0.1,0.2,0.2],
#              [0.2,0.2,0], [5,5,5], [5.1,5,5.1], [5,5.2,5], [5.2,5.1,5.1], [5.1,5.2,5.2],
#              [5.2,5.2,5] ])
#   example    o1.SetNeighbors(4)
#              o1.SetEpochs(100)
#              o1.Fit()
#              ? o1.HasGraph()
#              #--> 1
#              ? len(o1.Embedding())
#              #--> 12
#              ? o1.Trustworthiness() > 0.9
#              #--> 1
#   see        stzTSNE, stzPCA
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
	# THE GRAPH OUTLIVES THE FIT (GS6d). The neighbour graph -- the k-NN, the local
	# metric, the fuzzy union, supervision -- is the expensive, data-shaped half of
	# a fit; the layout is the cheap half and is what min_dist, spread, epochs and
	# the seed change. The graph lives in the engine under this handle from the
	# first Fit() on, and a second Fit() with a new min_dist is the layout alone.
	# Anything that changes the graph -- the neighbour count, the labels, the
	# target weight, the PCA width -- drops it; the next Fit() rebuilds.
	@hGraph_ = ""

	# Builds a UMAP embedding job around a table of samples, one list of feature values per sample.
	#
	#   paData     the samples, a list of equal-length lists of numbers
	#   returns    nothing; the object is built
	#   warning    an empty list, a sample that is not a list, or samples of different widths raise
	#              an error naming the first bad sample
	#   see        Fit, SetNeighbors, ReduceWithPCA
	def init(paData)
		_a_ = StzEmbeddingCheckData(paData)
		@aData = paData
		@nRows = _a_[1]
		@nCols = _a_[2]

	# Returns how many samples the job was built with.
	#
	#   returns    a number
	#   see        NumberOfFeatures, Embedding
	def NumberOfSamples()
		return @nRows

	# Returns how many feature values each sample has.
	#
	#   returns    a number
	#   see        NumberOfSamples
	def NumberOfFeatures()
		return @nCols

	# TRUE if the neighbour graph of a fit is still held in the engine.
	#
	#   returns    TRUE or FALSE
	#   note       it is false before a fit and after any setting that changes the graph
	#   see        GraphInfo, ReleaseGraph, Fit
	def HasGraph()
		return @hGraph_ != ""

	# Returns the size of the held neighbour graph: points, width, neighbours and edges.
	#
	#   returns    a list of four numbers; [ ] before a fit
	#   note       twelve points of three features with 4 neighbours gave 12, 3, 4 and 26
	#   see        HasGraph, SetNeighbors
	#@ aka  [ points, width, neighbours, edges ] of the resident graph, or [] before a fit
	def GraphInfo()
		if @hGraph_ = ""
			return []
		ok
		return StzEngineUmapGraphInfo(@hGraph_)

	# Gives the held neighbour graph back to the engine; the next fit builds it again.
	#
	#   returns    nothing; use ReleaseGraphQ to chain
	#   see        HasGraph, Fit
	#@ aka  Give the engine's graph back. The next Fit() builds it again.
	def ReleaseGraph()
		This._DropGraph()

		def ReleaseGraphQ()
			This._DropGraph()
			return This

	def _DropGraph()
		if @hGraph_ != ""
			StzEngineUmapGraphFree(@hGraph_)
			@hGraph_ = ""
		ok

	# Sets how many neighbours each point looks at, the dial between local detail and global shape; 15 by default.
	#
	#   n          the number of neighbours, 2 or more, anything else is ignored
	#   returns    nothing; use SetNeighborsQ to chain
	#   note       small values fragment clusters, large values smear detail
	#   warning    the graph is dropped; Fit refuses to run when the number is not below the number
	#              of samples (15 neighbours on 12 samples)
	#   see        Neighbors, Fit
	#@ aka  THE LOCAL/GLOBAL DIAL. Small values see fine structure and fragment; large values see the broad shape and smear detail. The reference implementation defaults to 15.
	def SetNeighbors(n)
		This._DropGraph()
		if n >= 2
			@nNeighbors = n
		ok

		def SetNeighborsQ(n)
			This.SetNeighbors(n)
			return This

	# Returns the number of neighbours in force.
	#
	#   returns    a number; 15 by default
	#   see        SetNeighbors
	def Neighbors()
		return @nNeighbors

	# Sets how tightly points may pack in the embedding; 0.1 by default.
	#
	#   n          the minimum distance, 0 or more, a negative value is ignored
	#   returns    nothing; use SetMinDistanceQ to chain
	#   note       a smaller value makes clusters look more separated, an appearance you choose
	#              rather than a finding; the graph is kept, so only the layout is redone
	#   see        SetSpread, Fit
	#@ aka  How tightly points may pack. Smaller packs tighter, which makes clusters look more separated -- an appearance you are choosing, not a finding.
	def SetMinDistance(n)
		if n >= 0
			@nMinDist = n
		ok

		def SetMinDistanceQ(n)
			This.SetMinDistance(n)
			return This

	# Sets the scale of the embedding that the minimum distance is measured against; 1 by default.
	#
	#   n          the spread, above 0, anything else is ignored
	#   returns    nothing; use SetSpreadQ to chain
	#   see        SetMinDistance, CurveParameters
	def SetSpread(n)
		if n > 0
			@nSpread = n
		ok

		def SetSpreadQ(n)
			This.SetSpread(n)
			return This

	# Sets how many coordinates each point gets in the embedding; 2 by default.
	#
	#   n          the number of output dimensions, 1 or more, anything else is ignored
	#   returns    nothing; use SetDimensionsQ to chain
	#   see        Fit, Embedding
	def SetDimensions(n)
		if n >= 1
			@nDims = n
		ok

		def SetDimensionsQ(n)
			This.SetDimensions(n)
			return This

	# Sets how many optimisation passes the layout takes; 200 by default.
	#
	#   n          the number of epochs, above 0, anything else is ignored
	#   returns    nothing; use SetEpochsQ to chain
	#   see        Fit
	def SetEpochs(n)
		if n > 0
			@nEpochs = n
		ok

		def SetEpochsQ(n)
			This.SetEpochs(n)
			return This

	# Sets the number that starts the random generator, so a run can be repeated or varied; 42 by default.
	#
	#   n          the starting number
	#   returns    nothing; use SetSeedQ to chain
	#   note       the same value gives the same embedding (twelve points), and the graph is kept
	#   see        Fit
	def SetSeed(n)
		@nSeed = n

		def SetSeedQ(n)
			This.SetSeed(n)
			return This

	# Asks for a PCA down to n dimensions before the embedding, the usual first step; off by default.
	#
	#   n          the number of components to keep, 1 or more, anything else is ignored
	#   returns    nothing; use ReduceWithPCAQ to chain
	#   note       it removes noise and speeds up the distances, at the cost of any structure the
	#              discarded components held
	#   warning    the graph is dropped; when n is not below the number of features the data goes
	#              through unchanged
	#   see        SkipPCA, UsesPCA, PCAQ
	def ReduceWithPCA(n)
		This._DropGraph()
		if n >= 1
			@nPcaDims = n
		ok

		def ReduceWithPCAQ(n)
			This.ReduceWithPCA(n)
			return This

	# Turns off the PCA step, so the fit uses the raw features.
	#
	#   returns    nothing; use SkipPCAQ to chain
	#   warning    the graph is dropped
	#   see        ReduceWithPCA, UsesPCA
	def SkipPCA()
		This._DropGraph()
		@nPcaDims = 0

		def SkipPCAQ()
			This.SkipPCA()
			return This

	# TRUE if a PCA reduction has been requested.
	#
	#   returns    TRUE or FALSE
	#   see        ReduceWithPCA, PCAQ
	def UsesPCA()
		return @nPcaDims > 0

	# Returns the PCA that the last fit ran before embedding, so its explained variance can be read.
	#
	#   returns    a stzPCA object; "" before a fit that used PCA
	#   see        ReduceWithPCA, UsesPCA
	def PCAQ()
		return @oPca

	# Gives one known label per sample so that the neighbour graph weakens links between different classes; -1 marks an unknown label.
	#
	#   paLabels   a list with one label per sample
	#   returns    nothing; use LearnFromLabelsQ to chain
	#   note       it does not classify anything: the separation of the classes is an input, not
	#              evidence that they are separable
	#   warning    the graph is dropped; a list of the wrong length raises an error giving both
	#              lengths
	#   see        IgnoreLabels, SetTargetWeight, IsSupervised
	#@ aka  ── SUPERVISION: let known labels reshape the graph ──
	def LearnFromLabels(paLabels)
		This._DropGraph()
		if NOT isList(paLabels) or len(paLabels) != @nRows
			stzraise("Give me one label per sample -- " + @nRows + " of them, " +
				"got " + len(paLabels) + ". Use -1 where the label is unknown.")
		ok
		@anLabels = paLabels

		def LearnFromLabelsQ(paLabels)
			This.LearnFromLabels(paLabels)
			return This

	# Forgets the labels, so the fit is unsupervised again.
	#
	#   returns    nothing; use IgnoreLabelsQ to chain
	#   warning    the graph is dropped
	#   see        LearnFromLabels, IsSupervised
	def IgnoreLabels()
		This._DropGraph()
		@anLabels = []

		def IgnoreLabelsQ()
			This.IgnoreLabels()
			return This

	# TRUE if labels have been given.
	#
	#   returns    TRUE or FALSE
	#   see        LearnFromLabels, IgnoreLabels
	def IsSupervised()
		return len(@anLabels) > 0

	# Returns the labels given to LearnFromLabels.
	#
	#   returns    a list; [ ] when there are none
	#   see        LearnFromLabels
	def Labels()
		return @anLabels

	# Sets how much the labels count against the data's own structure; 0.5 by default.
	#
	#   n          the weight from 0 to 1, anything else is ignored
	#   returns    nothing; use SetTargetWeightQ to chain
	#   warning    the graph is dropped; more weight is not more separation (a code comment reports
	#              a peak near 0.2, not run here)
	#   see        TargetWeight, LearnFromLabels
	#@ aka  HOW MUCH TO TRUST THE LABELS against the data's own structure. 0 ignores them; the reference implementation's default is 0.5.
	def SetTargetWeight(n)
		This._DropGraph()
		if n >= 0 and n <= 1
			@nTargetWeight = n
		ok

		def SetTargetWeightQ(n)
			This.SetTargetWeight(n)
			return This

	# Returns the weight given to the labels.
	#
	#   returns    a number; 0.5 by default
	#   see        SetTargetWeight
	def TargetWeight()
		return @nTargetWeight

	# Turns on the density term (densMAP) so denser regions are drawn tighter; the weight becomes 2, or 0.1 when parametric.
	#
	#   returns    nothing; use PreserveDensityQ to chain
	#   note       it makes cluster size more readable, at the cost of some separation between
	#              clusters
	#   see        IgnoreDensity, SetDensityWeight, DensityCorrelation
	#@ aka  -- DENSITY PRESERVATION (densMAP) --
	def PreserveDensity()
		@nDensityLambda = 2.0
		@bDensityAuto = 1

		def PreserveDensityQ()
			This.PreserveDensity()
			return This

	# Turns the density term off.
	#
	#   returns    nothing; use IgnoreDensityQ to chain
	#   see        PreserveDensity, IsDensityPreserving
	def IgnoreDensity()
		@nDensityLambda = 0
		@bDensityAuto = 0

		def IgnoreDensityQ()
			This.IgnoreDensity()
			return This

	# TRUE if the density weight is above 0.
	#
	#   returns    TRUE or FALSE
	#   see        PreserveDensity, DensityWeight
	def IsDensityPreserving()
		return @nDensityLambda > 0

	# Sets how hard the density term pushes; 0 turns it off exactly.
	#
	#   n          the weight, 0 or more, a negative value is ignored
	#   returns    nothing; use SetDensityWeightQ to chain
	#   note       with 0 the embedding is identical to the ordinary fit, value for value (twelve
	#              points, same seed)
	#   see        DensityWeight, PreserveDensity
	#@ aka  how hard to push. 0 turns the term off entirely, and does so EXACTLY -- the run is bit-for-bit the ordinary fit rather than a near one.
	def SetDensityWeight(n)
		if n >= 0
			@nDensityLambda = n
			@bDensityAuto = 0
		ok

		def SetDensityWeightQ(n)
			This.SetDensityWeight(n)
			return This

	# Returns the weight of the density term.
	#
	#   returns    a number; 0 by default
	#   see        SetDensityWeight, IsDensityPreserving
	def DensityWeight()
		return @nDensityLambda

	# Sets the last fraction of the epochs during which the density term is active; 0.3 by default.
	#
	#   n          the fraction, above 0 and at most 1, anything else is ignored
	#   returns    nothing; use SetDensityPhaseQ to chain
	#   see        DensityPhase, SetDensityWeight
	#@ aka  the FINAL fraction of epochs during which the term is active. It is switched on late deliberately: on a random start the embedded radii are noise, so their correlation with anything is noise, and its gradient is noise with a lever arm.
	def SetDensityPhase(n)
		if n > 0 and n <= 1
			@nDensityFrac = n
		ok

		def SetDensityPhaseQ(n)
			This.SetDensityPhase(n)
			return This

	# Returns the fraction of the epochs during which the density term runs.
	#
	#   returns    a number; 0.3 by default
	#   see        SetDensityPhase
	def DensityPhase()
		return @nDensityFrac

	# Returns how closely the drawn local radii follow the original ones at the end of a fit with the density term on.
	#
	#   returns    a number from -1 to 1; 0 when the term is off or before a fit
	#   note       it is a correlation, not a percentage
	#   see        PreserveDensity, LocalRadii
	#@ aka  HOW FAR THE TERM ACTUALLY GOT: the correlation between original and embedded log-radii at the end of the run. Reported rather than hidden because it is the only evidence the extra work achieved anything.
	def DensityCorrelation()
		return @nDensityCorrelation

	# Returns the average distance of each sample to its neighbours in the original space, as measured by a fit with the density term on.
	#
	#   returns    a list of numbers, one per sample; [ ] when the term is off
	#   see        DensityCorrelation, LocalRadiiOf
	#@ aka  THE ORIGINAL-SPACE LOCAL RADIUS PER POINT -- how far each row sits, on average, from the neighbours it is joined to. Small means it sits in a crowd.
	def LocalRadii()
		return @anLocalRadii

	# Switches to parametric UMAP, which trains a neural network from features to coordinates instead of moving free points.
	#
	#   returns    nothing; use LearnMappingQ to chain
	#   note       training rows transform back to their own embedding exactly (largest difference 0
	#              on twelve points)
	#   see        SkipMapping, Transform, SetHiddenLayers
	#@ aka  -- PARAMETRIC UMAP: let a network hold the map --
	def LearnMapping()
		@bParametric = 1

		def LearnMappingQ()
			This.LearnMapping()
			return This

	# Switches back to the ordinary UMAP, where points move freely.
	#
	#   returns    nothing; use SkipMappingQ to chain
	#   see        LearnMapping, IsParametric
	def SkipMapping()
		@bParametric = 0

		def SkipMappingQ()
			This.SkipMapping()
			return This

	# TRUE if the parametric variant is switched on.
	#
	#   returns    TRUE or FALSE
	#   see        LearnMapping, SkipMapping
	def IsParametric()
		return @bParametric

	# Sets the widths of the hidden layers of the network of the parametric variant; 50 and 20 by default.
	#
	#   paWidths   the layer widths, a list of numbers, an empty list or another value is ignored
	#   returns    nothing; use SetHiddenLayersQ to chain
	#   see        HiddenLayers, LearnMapping
	def SetHiddenLayers(paWidths)
		if isList(paWidths) and len(paWidths) > 0
			@anHidden = paWidths
		ok

		def SetHiddenLayersQ(paWidths)
			This.SetHiddenLayers(paWidths)
			return This

	# Returns the hidden layer widths of the parametric variant.
	#
	#   returns    a list of numbers; [ 50, 20 ] by default
	#   see        SetHiddenLayers
	def HiddenLayers()
		return @anHidden

	# Sets the step size of the network of the parametric variant; 0.01 by default.
	#
	#   n          the learning rate, above 0, anything else is ignored
	#   returns    nothing; use SetLearningRateQ to chain
	#   see        LearningRate, LearnMapping
	#@ aka  the NETWORK's step size. The free-form optimiser's decaying alpha has no counterpart in the gradient here, so the schedule belongs to the weights.
	def SetLearningRate(n)
		if n > 0
			@nLearningRate = n
		ok

		def SetLearningRateQ(n)
			This.SetLearningRate(n)
			return This

	# Returns the step size of the network of the parametric variant.
	#
	#   returns    a number; 0.01 by default
	#   see        SetLearningRate
	def LearningRate()
		return @nLearningRate

	# Trains a second network that maps points of the embedding back to rows of data.
	#
	#   returns    nothing; use LearnInverseQ to chain
	#   warning    it needs a fitted job; training is slow with the default 15000 epochs, so a small
	#              job sets SetInverseEpochs first
	#   see        Inverse, HasInverse, SetInverseLayers
	#@ aka  -- THE INVERSE TRANSFORM: from the picture back to the data --
	def LearnInverse()
		This._MustBeFitted()
		# A REFUSAL USED TO STAND HERE, and it was wrong. I reasoned that a free-form
		# fit has "no map to invert, only a list of positions" -- but the decoder never
		# inverts the encoder. It is a separate model regressed on (position, row)
		# pairs, and a free-form fit has both halves exactly as a parametric one does.
		# How the positions were arrived at is not its business.
		# THE FLATTENING TAX (2026-09-10): the embedding goes as rows
		_aY_ = ref(@aEmbedding)
		# the prepared data is rows; the bridge walks them
		_aR_ = StzEngineEmbeddingDecoder(_aY_, @aPrepared, @nRows, @nDims, @nPreparedDim,
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

	# TRUE if an inverse network has been trained.
	#
	#   returns    TRUE or FALSE
	#   see        LearnInverse, Inverse
	def HasInverse()
		return len(@anDecWeights) > 0

	# Sets the hidden layer widths of the inverse network; 64 and 64 by default.
	#
	#   paWidths   the layer widths, a list of numbers, an empty list or another value is ignored
	#   returns    nothing; use SetInverseLayersQ to chain
	#   see        LearnInverse, SetInverseEpochs
	def SetInverseLayers(paWidths)
		if isList(paWidths) and len(paWidths) > 0
			@anDecHidden = paWidths
		ok

		def SetInverseLayersQ(paWidths)
			This.SetInverseLayers(paWidths)
			return This

	# Sets how many epochs the inverse network trains for; 15000 by default.
	#
	#   n          the number of epochs, above 0, anything else is ignored
	#   returns    nothing; use SetInverseEpochsQ to chain
	#   see        LearnInverse, SetInverseLayers
	#@ aka  CAPACITY DECIDED THIS ONE, and a first reading of an undertrained net nearly sent me the wrong way. Reconstruction error against a nearest-row lookup at 0.9155:
	def SetInverseEpochs(n)
		if n > 0
			@nDecEpochs = n
		ok

		def SetInverseEpochsQ(n)
			This.SetInverseEpochs(n)
			return This

	# Returns rows of data for points of the embedding, using the inverse network.
	#
	#   paPoints   points of the map, each with as many coordinates as the embedding
	#   returns    a list of rows, one per point
	#   note       the rows come back in the space the fit saw, so with a PCA step they are PCA
	#              scores, not the original features
	#   warning    it raises before LearnInverse, and for a point with the wrong number of
	#              coordinates
	#   see        LearnInverse, HasInverse
	#@ aka  TAKE POINTS IN THE MAP, RETURN ROWS IN THE DATA.
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

	# Builds the neighbour graph if none is held, then lays the points out, and stores the coordinates.
	#
	#   returns    nothing; use FitQ to chain
	#   note       with the parametric variant switched on, a network is trained instead
	#   warning    it raises an error when the neighbour count is not between 2 and one less than
	#              the number of samples; a second fit that only changes the minimum distance,
	#              spread, epochs or seed reuses the graph
	#   see        Embedding, IsFitted, HasGraph, Why
	def Fit()
		_a_ = This._PreparedData()
		_aX_ = ref(_a_[1])
		_nD_ = _a_[2]
		# kept because Transform() must measure a new point against THE SAME data the
		# fit saw -- which is the PCA scores when reducing, not the raw features;
		# by reference, not by copy
		@aPrepared = ref(_a_[1])
		@nPreparedDim = _nD_

		if @bParametric
			This._FitParametric(_aX_, _nD_)
			return
		ok

		# the graph once, the layout per fit -- see @hGraph_
		if @hGraph_ = ""
			StzUmapKnnVariantsSync()
			@hGraph_ = StzEngineUmapGraphBuild(_aX_, @nRows, _nD_, @nNeighbors, @anLabels, @nTargetWeight)
			if @hGraph_ = ""
				stzraise("UMAP refused this run. It needs at least 3 points and a " +
					"neighbour count between 2 and " + (@nRows - 1) + " (asked for " +
					@nNeighbors + ", with " + @nRows + " points).")
			ok
		ok
		_aRes_ = StzEngineUmapRunOnGraph(@hGraph_, @nDims, @nMinDist, @nSpread,
			@nEpochs, @nSeed, @nDensityLambda, @nDensityFrac)
		if NOT isList(_aRes_) or len(_aRes_) < 3
			stzraise("UMAP refused this layout (" + @nRows + " points, " + @nDims + " dims).")
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

	# TRUE if Fit has run.
	#
	#   returns    TRUE or FALSE
	#   see        Fit
	def IsFitted()
		return @bFitted

	# Returns the coordinates of every sample after the fit.
	#
	#   returns    a list with one list of coordinates per sample
	#   note       distances and cluster sizes in the picture are not meaningful, only which points
	#              are near
	#   warning    it raises Fit() me first. before a fit
	#   see        Fit, Trustworthiness
	def Embedding()
		This._MustBeFitted()
		return @aEmbedding

	# Returns how faithful the embedding is to the neighbourhoods of the original data, from 0 to 1, looking at 5 neighbours.
	#
	#   returns    a number from 0 to 1; 1 means no false neighbour was invented
	#   note       two separated clusters of six points gave 0.96
	#   warning    it raises before a fit
	#   see        TrustworthinessAt, Embedding
	#@ aka  THE WITNESS -- see stzTSNE.Trustworthiness(); the same engine call on the data the fit saw (the PCA scores when reducing) and the embedding
	def Trustworthiness()
		return This.TrustworthinessAt(5)

	# Returns the trustworthiness of the embedding for a chosen number of neighbours.
	#
	#   nK         how many nearest neighbours to compare
	#   returns    a number from 0 to 1
	#   warning    it raises before a fit
	#   see        Trustworthiness
	def TrustworthinessAt(nK)
		This._MustBeFitted()
		return StzEngineEmbeddingTrustworthiness(@aPrepared, @nRows, @nPreparedDim, @aEmbedding, @nDims, nK, 0)

	# Returns the two numbers a and b of the curve 1/(1 + a*d^(2b)) that the fit derived from the minimum distance and the spread.
	#
	#   returns    a list of [ key, value ] pairs, a and b
	#   note       the values were a = 1.58 and b = 0.90 for the defaults
	#   warning    it raises before a fit
	#   see        SetMinDistance, SetSpread
	#@ aka  The fitted similarity curve 1/(1 + a*d^(2b)). Reported because a and b are DERIVED from min_dist and spread by a least-squares fit rather than given, and a caller may reasonably want to see what their setting turned into.
	def CurveParameters()
		This._MustBeFitted()
		return [ :a = @nA, :b = @nB ]

	# Places new rows in the existing map, by a forward pass when parametric, otherwise by refining each point against the frozen layout.
	#
	#   paRows     the new samples, each with as many feature values as the training samples
	#   returns    a list of coordinate rows, one per new row
	#   note       the map does not rearrange for the new point: a point unlike the training data is
	#              still placed among the nearest training points
	#   warning    it raises Fit() me first. before a fit, and an error naming the row when a row
	#              has the wrong width or the list is empty
	#   see        LearnMapping, NewLocalRadii, LocalRadiiOf
	#@ aka  PLACE POINTS THE FIT NEVER SAW into the existing map.
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

	# Returns the local radii of the rows placed by the last Transform.
	#
	#   returns    a list of numbers, one per placed row; [ ] before any Transform
	#   note       a large value warns that a new row lies outside the region the map was fitted on
	#   see        Transform, LocalRadiiOf
	#@ aka  THE LOCAL RADII OF THE ROWS THE LAST Transform() PLACED. How far each new row sits, on average, from the training rows nearest it -- IN THE ORIGINAL SPACE.
	def NewLocalRadii()
		return @anNewRadii

	# Returns how far each given row sits from its neighbours in the training data, without placing anything.
	#
	#   paRows     the rows to measure, each with as many feature values as the training samples
	#   returns    a list of numbers, one per row
	#   warning    it raises before a fit and for rows of the wrong width
	#   see        NewLocalRadii, Transform
	#@ aka  THE SAME NUMBERS WITHOUT PLACING ANYTHING, measured against the TRAINING DATA.
	def LocalRadiiOf(paRows)
		This._MustBeFitted()
		if NOT isList(paRows) or len(paRows) = 0
			stzraise("Give me a list of rows.")
		ok
		_nM2_ = len(paRows)
		_aF2_ = ref(paRows)
		for _i_ = 1 to _nM2_
			if NOT isList(paRows[_i_]) or len(paRows[_i_]) != @nCols
				stzraise("Row " + _i_ + " has " + len(paRows[_i_]) +
					" value(s); this model was fitted on " + @nCols + ".")
			ok
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
			# THE FLATTENING TAX (2026-09-10): the scores go as rows, cut only when needed
			_aF2_ = ref(_aS2_)
			if @nPreparedDim < len(_aS2_[1])
				_aF2_ = []
				for _i_ = 1 to _nM2_
					_aRow_ = []
					for _j_ = 1 to @nPreparedDim
						_aRow_ + _aS2_[_i_][_j_]
					next
					_aF2_ + _aRow_
				next
			ok
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

	# Returns one sentence describing the fit: variant, size, neighbours, minimum distance, epochs and PCA step.
	#
	#   returns    a text
	#   warning    it raises before a fit
	#   see        Fit
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
