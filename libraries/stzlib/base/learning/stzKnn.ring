# R4 step 0 -- stzKnn: THE FIRST LEARNER (highest intelligence-per-line)
# k-nearest-neighbours: ZERO training, FULLY explainable -- the purest
# LAW 3 classifier: Why() literally answers "the nearest examples
# were...". Rides stzSimilarity (Euclidean) + stzTrainingSet, exactly as
# they exist today (the R4 step-0 doctrine: no numeric blockers).
#
#   oK = new stzKnn(oTrainingSet)
#   oK.SetK(3)
#   ? oK.Classify([5.0, 3.4])   #--> "setosa"
#   ? oK.Why()

class stzKnn from stzObject

	@oDs = NULL
	@nK = 3
	@cWhy = ""
	@pResident_ = NULL    # the examples, RESIDENT in the engine -- see Classify()
	@acLabels_ = []       # their labels, held here so Examples() stays off the hot path
	@nFlatCount_ = 0      # what it was built from, for staleness
	@nFlatDim_ = 0
	@bApprox_ = FALSE     # opt-in approximate search -- see SetApproximate()
	@pAnn_ = NULL         # the projection forest, resident, when approximate
	@nAnnTrees_ = 24      # tuned in umap.zig against measured recall
	@nAnnBudget_ = 0      # 0 = let the engine choose from k

	def init(poDataset)
		@oDs = poDataset

	# THE HELD SET IS LIVE THROUGH HERE. Ring COPIES an object into an
	# attribute, so the set handed to the constructor is a SNAPSHOT: growing
	# the caller's own object afterwards would NOT reach this learner. Grow it
	# through this accessor -- oLearner.TrainingSetQ().AddExample(...) -- which
	# reaches the real held set (accessor + method call is live in Ring).
	def TrainingSetQ()
		return @oDs

	def SetK(n)
		if n >= 1
			@nK = n
		ok
		return This

	# ── APPROXIMATE SEARCH: OPT-IN, AND DELIBERATELY NOT AUTOMATIC ──
	#
	# Exact search is O(n) per query: every example measured, the true k nearest,
	# the same answer every time. Above a few thousand examples that is the whole
	# cost of a classification, and the projection forest in the engine answers in
	# roughly O(budget) instead.
	#
	# WHY THIS IS A SWITCH AND NOT A SIZE THRESHOLD. UMAP builds neighbours for
	# every point at once, so its n alone decides whether approximating pays --
	# which is why umap.zig can turn it on by itself at 8192. A CLASSIFIER IS
	# DIFFERENT: it answers one query at a time, and the forest has to be BUILT
	# before it can answer any. That build is amortised over however many queries
	# follow, and only the caller knows whether that is three or three million.
	# Ten queries against 50000 examples are faster exact; ten thousand are not.
	# A library cannot infer the query count, so it must not guess -- it asks.
	#
	# AND IT CHANGES ANSWERS, WHICH A SIZE THRESHOLD WOULD HIDE. Approximate
	# neighbours can shift a vote. Usually they do not -- a vote survives a swapped
	# neighbour far more often than a neighbour list survives it -- but "usually" is
	# a promise no default should make on a caller's behalf. AgreementWithExact()
	# exists so the cost can be measured on the actual data rather than assumed.
	#
	# ── WHAT IT ACTUALLY BUYS, MEASURED, AND IT IS LESS THAN ARITHMETIC SUGGESTS ──
	#
	# 16 features, k = 5, 30 queries, on this machine:
	#
	#     5000 examples    approximate is NOT faster per query
	#    20000 examples    1.355x per query; break-even at ~219 queries
	#
	# Counting flops predicts far more: exact measures all 20000 examples where the
	# forest examines a few hundred candidates, which is some sixty-fold less
	# arithmetic. It does not show up, and the reason is written all over this file
	# already -- THE BRIDGE AND THE INTERPRETER, NOT THE ARITHMETIC, ARE THE COST OF
	# A QUERY at these sizes. Cutting the distance computations sixty-fold cuts a
	# minority of the total.
	#
	# So this is a modest win that has to be asked for, not a free upgrade, and the
	# break-even in QUERIES is the number that decides it. That is also the sharpest
	# contrast with UMAP: there one call needs n neighbour searches, so the forest is
	# amortised immediately and 8192 points is enough to turn it on automatically.
	# Here each query stands alone.
	#
	# Label agreement measured 1.000 in both rows above -- on separable data the vote
	# absorbed every neighbour the forest missed. Do not read that as a guarantee;
	# read it as the reason AgreementWithExact() takes YOUR queries.
	def SetApproximate(bFlag)
		if bFlag != TRUE and bFlag != FALSE
			stzraise("SetApproximate: TRUE or FALSE.")
		ok
		if bFlag != @bApprox_
			@bApprox_ = bFlag
			This._DropResident()
		ok
		return This

	def IsApproximate()
		return @bApprox_

	# More trees, better recall, bigger index and a slower build.
	def SetApproximateTrees(n)
		if n < 1
			stzraise("SetApproximateTrees: at least one tree.")
		ok
		@nAnnTrees_ = n
		This._DropResident()
		return This

	# Candidates examined per query before the true distances decide. 0 lets the
	# engine scale it from k. This is the recall dial.
	def SetApproximateBudget(n)
		if n < 0
			stzraise("SetApproximateBudget: a non-negative budget.")
		ok
		@nAnnBudget_ = n
		This._DropResident()
		return This

	def ApproximateTrees()
		return @nAnnTrees_

	def ApproximateBudget()
		return @nAnnBudget_

	# THE HONEST MEASURE FOR A CLASSIFIER: not how many neighbours the forest
	# missed, but how often the LABEL still came out the same. Those are very
	# different numbers -- a majority vote absorbs a swapped neighbour that a
	# neighbour-recall figure would count as a loss -- and the label is what the
	# caller actually receives.
	#
	# Returns the fraction of the given queries on which approximate and exact
	# classification agree. Each mode is built once, not once per query.
	def AgreementWithExact(paQueries)
		if NOT isList(paQueries) or len(paQueries) = 0
			stzraise("AgreementWithExact: give me a non-empty list of queries.")
		ok
		_bWas_ = @bApprox_
		_nQ_ = len(paQueries)

		This.SetApproximate(TRUE)
		_acA_ = []
		for _i_ = 1 to _nQ_
			_acA_ + This.Classify(paQueries[_i_])
		next

		This.SetApproximate(FALSE)
		_acE_ = []
		for _i_ = 1 to _nQ_
			_acE_ + This.Classify(paQueries[_i_])
		next

		This.SetApproximate(_bWas_)

		_nSame_ = 0
		for _i_ = 1 to _nQ_
			if _acA_[_i_] = _acE_[_i_]
				_nSame_++
			ok
		next
		return _nSame_ / _nQ_

	def K()
		return @nK

	def Classify(paFeatures)
		# NOT Examples(). Ring COPIES a list when a method returns it, so
		# @oDs.Examples() hands back all ten thousand rows every time it is asked --
		# measured at 0.581 s of a 0.598 s twenty-query run, which is 97% of what was
		# left after the dataset went resident. NumberOfExamples() returns a count.
		_nEx_ = @oDs.NumberOfExamples()
		if _nEx_ = 0
			stzraise("Can't classify: the dataset is empty.")
		ok
		_nTake_ = @nK
		if _nTake_ > _nEx_
			_nTake_ = _nEx_
		ok

		# THE WHOLE SEARCH IN ONE CROSSING (numeric phase 5, second pass).
		#
		# Two things were wrong here and they were fixed in that order. First the
		# algorithm: this used to compute every distance and then INSERTION SORT ALL
		# OF THEM to read the first K off the front -- O(N^2) for an O(N*K) question,
		# 11.769 s of a 11.801 s classification at N=10000. Fixing that in Ring took
		# 357 s of twenty queries down to 1.173.
		#
		# Then the remaining second: correct complexity in an interpreter is still an
		# interpreter, and the loop below used to ask the engine for ONE distance at a
		# time. Marshalling two vectors across the bridge to do sixteen subtractions
		# costs far more than the subtractions, so the bridge was most of what was
		# left. Sending the matrix ONCE and getting the K nearest back inverts that:
		#
		#     10000 examples x 16 dim, 20 queries
		#         sorting all N, one distance per crossing      357.753 s
		#         bounded selection, one distance per crossing    1.173 s
		#         one crossing for the whole search               0.086 s
		#
		# The selection and the tie rule moved with it, unchanged: cluster.topK walks
		# left while the neighbour is STRICTLY greater, so equidistant examples keep
		# training-set order and decide the vote exactly as the stable sort did.
		_nDim_ = @oDs.NumberOfFeatures()
		if NOT isList(paFeatures) or len(paFeatures) != _nDim_
			stzraise("This dataset is " + _nDim_ + " feature(s) wide; the query has " +
				len(paFeatures) + ".")
		ok

		# THE DATASET IS RESIDENT, and getting here took two corrections.
		#
		# Sending the whole matrix once per query instead of one vector per example
		# is the right SHAPE -- but flattened inside Classify() it made things WORSE:
		# 1.173 s of twenty queries became 2.254 s, because 160000 list appends were
		# now paid per query for a matrix that does not change between queries.
		# Caching the flat list fixed that (0.679 s) and still left the bridge
		# copying 160000 numbers on every call. So the points LIVE in the engine and
		# a query crosses carrying only itself:
		#
		#     one distance per crossing, sorting all N     357.753 s
		#     one distance per crossing, bounded select      1.173 s
		#     whole matrix marshalled per query              2.254 s   <- worse
		#     matrix flattened once, re-sent per query       0.679 s
		#     matrix RESIDENT, query crosses alone           0.021 s
		#
		# Marshalling is the cost the engine has to earn back, and the last two rows
		# are the same algorithm differing only in whether the bridge is re-walked.
		#
		# STALENESS IS BY EXAMPLE COUNT, which exactly covers the documented way to
		# grow a held set -- TrainingSetQ().AddExample(...) always changes the count.
		# Editing an existing row's features in place would NOT be noticed; that is
		# not a supported mutation, and saying so is better than a cache that
		# pretends. The old handle is freed before a new one is taken.
		if @pResident_ = NULL or @nFlatCount_ != _nEx_ or @nFlatDim_ != _nDim_
			# the ONE place the full set is read -- when the resident copy is built
			_aEx_ = @oDs.Examples()
			_aFlat_ = []
			@acLabels_ = []
			for _i_ = 1 to _nEx_
				_aRow_ = _aEx_[_i_][1]
				@acLabels_ + _aEx_[_i_][2]
				if len(_aRow_) != _nDim_
					stzraise("Example " + _i_ + " has " + len(_aRow_) +
						" feature(s) but the dataset is " + _nDim_ + " wide.")
				ok
				for _d_ = 1 to _nDim_
					_aFlat_ + _aRow_[_d_]
				next
			next
			if @pResident_ != NULL
				StzEngineClusterDataFree(@pResident_)
			ok
			@pResident_ = StzEngineClusterDataNew(_aFlat_, _nEx_, _nDim_)
			if @pResident_ = NULL
				stzraise("The engine refused the dataset (" + _nEx_ + " x " + _nDim_ + ").")
			ok

			# The forest is built HERE, from the flat list that was just read, so
			# turning approximation on costs ONE pass over Examples() and not a
			# second one. _DropResident() clears both, which is why toggling the
			# mode invalidates rather than trying to patch a half-built pair.
			if @pAnn_ != NULL
				StzEngineAnnFree(@pAnn_)
				@pAnn_ = NULL
			ok
			if @bApprox_
				@pAnn_ = StzEngineAnnBuild(_aFlat_, _nEx_, _nDim_, @nAnnTrees_, 0, 42)
				if @pAnn_ = NULL
					stzraise("The engine refused to index the dataset (" +
						_nEx_ + " x " + _nDim_ + ").")
				ok
			ok

			@nFlatCount_ = _nEx_
			@nFlatDim_ = _nDim_
		ok

		# ONE CROSSING EITHER WAY, and the two paths return the same shape so the
		# vote below cannot tell them apart.
		if @bApprox_
			_aRaw_ = StzEngineAnnSearch(@pAnn_, paFeatures, _nTake_, @nAnnBudget_)
			if NOT isList(_aRaw_) or len(_aRaw_) != _nTake_ * 2
				stzraise("The engine refused the search (" + _nEx_ + " x " + _nDim_ + ").")
			ok
			# TWO CONVERSIONS, and both matter. The forest indexes from 0 where
			# cluster.topK already returns 1-based indices for Ring; and it reports
			# SQUARED distances where this class's contract -- the vote's tie order,
			# and the numbers Why() quotes -- is the true Euclidean distance.
			_aPairs_ = []
			for _i_ = 1 to _nTake_
				_aPairs_ + (_aRaw_[(_i_ - 1) * 2 + 1] + 1)
				_aPairs_ + sqrt(_aRaw_[(_i_ - 1) * 2 + 2])
			next
		else
			_aPairs_ = StzEngineKnnTopKOn(@pResident_, paFeatures, _nTake_)
			if NOT isList(_aPairs_) or len(_aPairs_) != _nTake_ * 2
				stzraise("The engine refused the search (" + _nEx_ + " x " + _nDim_ + ").")
			ok
		ok

		# [ idx, dist, idx, dist, ... ] -> the [ dist, label, idx ] rows the vote reads
		_aTop_ = []
		for _i_ = 1 to _nTake_
			_nIdx_ = _aPairs_[(_i_ - 1) * 2 + 1]
			_aTop_ + [ _aPairs_[(_i_ - 1) * 2 + 2], @acLabels_[_nIdx_], _nIdx_ ]
		next

		# majority vote among the K nearest
		_aVotes_ = []
		_cNear_ = ""
		for _i_ = 1 to _nTake_
			_cL_ = _aTop_[_i_][2]
			if HasKey(_aVotes_, _cL_)
				_aVotes_[_cL_] = _aVotes_[_cL_] + 1
			else
				_aVotes_[_cL_] = 1
			ok
			if _cNear_ != ""
				_cNear_ += ", "
			ok
			_cNear_ += "#" + _aTop_[_i_][3] + " '" + _cL_ + "' (d=" +
				_aTop_[_i_][1] + ")"
		next

		_cBest_ = ""
		_nBest_ = -1
		_nV_ = len(_aVotes_)
		for _i_ = 1 to _nV_
			if _aVotes_[_i_][2] > _nBest_
				_nBest_ = _aVotes_[_i_][2]
				_cBest_ = _aVotes_[_i_][1]
			ok
		next

		@cWhy = "the " + _nTake_ + " nearest examples were: " + _cNear_ +
			" -- majority: '" + _cBest_ + "' (" + _nBest_ + "/" + _nTake_ + ")"
		$nStzLastCertainty = 1
		$cStzLastWhyB = @cWhy
		return _cBest_

	def Why()
		return @cWhy

	# ONE DEFINITION OF DISTANCE (phase 5 slice 3 of the numeric foundation).
	#
	# This was a hand-rolled Ring loop, byte-for-byte identical to the one in
	# stzKMeans. similarity.zig has had a vectorised, tested Euclidean distance since
	# phase 4 slice 6, so there were three. That is the shape this plan keeps
	# finding -- the variance divisor, the summation, the centered sum of squares,
	# the negligible threshold -- and the cure is always the same: ask the one
	# authority.
	#
	# MEASURED, since phase 3 established that a one-shot engine call is no faster
	# than Ring when marshalling dominates. Here it is not close:
	#
	#     N x dims       ring loop    engine call
	#     1000 x 8        0.001s       0s
	#     5000 x 16       0.015s       0.002s
	#     20000 x 32      0.111s       0.014s      8x
	#
	# Marshalling 32 doubles is cheaper than 32 interpreted loop steps, so the
	# crossing pays for itself even per point. Below a few thousand points both are
	# free -- the authority argument alone would justify this; the speed is a bonus.
	#
	# THE RAGGED CASE IS KEPT DELIBERATELY. This loop truncated to the shorter
	# vector, and nothing validates vector lengths on the way in, so that truncation
	# is load-bearing rather than decorative. The engine bridge REFUSES a length
	# mismatch and answers 0 -- which here would read as "these points are
	# identical", the worst possible wrong answer. So the common case (equal
	# lengths) goes straight through, and the ragged case slices first, preserving
	# the old behaviour exactly.
	# Forget both resident structures. The next Classify() rebuilds from one read
	# of Examples(); setting the count to 0 is what the staleness check already
	# looks at, so this reuses that machinery rather than adding a second flag.
	def _DropResident()
		if @pResident_ != NULL
			StzEngineClusterDataFree(@pResident_)
			@pResident_ = NULL
		ok
		if @pAnn_ != NULL
			StzEngineAnnFree(@pAnn_)
			@pAnn_ = NULL
		ok
		@nFlatCount_ = 0
		@nFlatDim_ = 0

	def _Dist(paA, paB)
		_nA_ = len(paA)
		_nB_ = len(paB)

		if _nA_ = _nB_
			return StzEngineSimEuclidean(paA, paB)
		ok

		# ragged: compare over the common prefix, as this method always has
		_n_ = _nA_
		if _nB_ < _n_
			_n_ = _nB_
		ok
		_aTA_ = []
		_aTB_ = []
		for _iDs_ = 1 to _n_
			_aTA_ + paA[_iDs_]
			_aTB_ + paB[_iDs_]
		next
		return StzEngineSimEuclidean(_aTA_, _aTB_)
