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

	@oDs = ""
	@nK = 3
	@cWhy = ""
	@pModel_ = ""       # the CLASSIFIER, resident in the engine -- see Classify()
	@acAlphabet_ = []     # the distinct labels, in first-appearance order; the engine
	                      # works in codes and this maps a code back to its label
	@nFlatCount_ = 0      # what it was built from, for staleness
	@nFlatDim_ = 0
	@bApprox_ = 0     # opt-in approximate search -- see SetApproximate()
	@nAnnTrees_ = 24      # tuned in umap.zig against measured recall
	@nAnnBudget_ = 0      # 0 = let the engine choose from k
	@aWhyRows_ = []       # [ idx, dist, code ] per consulted neighbour, for Why()
	@nWhyVotes_ = 0
	@nWhyUsed_ = 0
	@nWhyWin_ = 0         # the WINNING code -- not the first neighbour's, which is
	                      # a different thing whenever the vote overrules proximity

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
		if bFlag != 1 and bFlag != 0
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
		This._Ensure()
		_nDim_ = @oDs.NumberOfFeatures()
		_aFlat_ = []
		_nQ_ = len(paQueries)
		for _i_ = 1 to _nQ_
			if NOT isList(paQueries[_i_]) or len(paQueries[_i_]) != _nDim_
				stzraise("AgreementWithExact: query " + _i_ + " is not " + _nDim_ +
					" feature(s) wide.")
			ok
			for _d_ = 1 to _nDim_
				_aFlat_ + paQueries[_i_][_d_]
			next
		next
		_nR_ = StzEngineKnnModelAgreement(@pModel_, _aFlat_, _nQ_, @nK, @nAnnBudget_)
		if _nR_ < 0
			stzraise("AgreementWithExact: the engine refused the comparison.")
		ok
		return _nR_

	def K()
		return @nK

	def Classify(paFeatures)
		# A THIN FACE OVER ONE ENGINE CALL.
		#
		# This method used to do the deciding: it took the k nearest back from the
		# engine, looked each label up, tallied the votes, broke the tie and built the
		# explanation -- and every other language over this engine would have had to
		# write that same loop, with its own tie rule. It is now knn.zig's job, so a
		# Python or C face gets the identical verdict for free.
		#
		# It was also where the time went. 20000 examples x 16 features, k = 5: the
		# search cost 0.09 ms and the Ring post-processing 0.89 ms -- ninety percent of
		# the query was the interpreter finishing a half-done operation. Reshaping the
		# Ring side could have recovered part of that; moving the operation recovers it
		# for every binding at once, which is the reason to do it.
		#
		# What is left here is what a face is FOR: validate, cross once, marshal.
		_nEx_ = @oDs.NumberOfExamples()
		if _nEx_ = 0
			stzraise("Can't classify: the dataset is empty.")
		ok
		_nDim_ = @oDs.NumberOfFeatures()
		if NOT isList(paFeatures) or len(paFeatures) != _nDim_
			stzraise("This dataset is " + _nDim_ + " feature(s) wide; the query has " +
				len(paFeatures) + ".")
		ok

		This._Ensure()

		_aV_ = StzEngineKnnModelClassify(@pModel_, paFeatures, @nK, @nAnnBudget_)
		if NOT isList(_aV_) or len(_aV_) < 3
			stzraise("The engine refused the search (" + _nEx_ + " x " + _nDim_ + ").")
		ok

		# [ winCode, winVotes, used, (idx, dist, code) * used ]
		_nWin_ = _aV_[1]
		_nVotes_ = _aV_[2]
		_nUsed_ = _aV_[3]

		# THE EXPLANATION IS BUILT ONLY IF ASKED FOR. The ingredients are kept and
		# Why() assembles the sentence, so a caller who never asks pays nothing --
		# the string used to be concatenated on every single classification.
		@aWhyRows_ = []
		for _i_ = 1 to _nUsed_
			_b_ = 3 + (_i_ - 1) * 3
			@aWhyRows_ + [ _aV_[_b_ + 1] + 1, _aV_[_b_ + 2], _aV_[_b_ + 3] ]
		next
		@nWhyVotes_ = _nVotes_
		@nWhyUsed_ = _nUsed_
		@nWhyWin_ = _nWin_
		@cWhy = ""

		$nStzLastCertainty = 1
		$cStzLastWhyB = ""
		return @acAlphabet_[_nWin_ + 1]

	def Why()
		if @cWhy != ""
			return @cWhy
		ok
		if @nWhyUsed_ = 0
			return ""
		ok
		_cNear_ = ""
		for _i_ = 1 to @nWhyUsed_
			if _cNear_ != ""
				_cNear_ += ", "
			ok
			_cNear_ += "#" + @aWhyRows_[_i_][1] + " '" +
				@acAlphabet_[@aWhyRows_[_i_][3] + 1] + "' (d=" +
				@aWhyRows_[_i_][2] + ")"
		next
		# the majority is the VERDICT's code. Reading the first neighbour's label
		# instead would agree with it only when proximity and the vote happen to
		# coincide -- on [0,0] [3,0] [0,4] classified from (3,4) the nearest is
		# 'high' and the majority is 'low', and the first version of this line said
		# 'high'.
		@cWhy = "the " + @nWhyUsed_ + " nearest examples were: " + _cNear_ +
			" -- majority: '" + @acAlphabet_[@nWhyWin_ + 1] + "' (" +
			@nWhyVotes_ + "/" + @nWhyUsed_ + ")"
		$cStzLastWhyB = @cWhy
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
		if @pModel_ != ""
			StzEngineKnnModelFree(@pModel_)
			@pModel_ = ""
		ok
		@nFlatCount_ = 0
		@nFlatDim_ = 0

	# Build the engine-side classifier, once, from ONE read of Examples().
	#
	# STALENESS IS BY EXAMPLE COUNT, which exactly covers the documented way to grow a
	# held set -- TrainingSetQ().AddExample(...) always changes the count. Editing an
	# existing row in place would NOT be noticed; that is not a supported mutation, and
	# saying so is better than a cache that pretends.
	#
	# INTERNING HAPPENS HERE because it is marshalling, not algorithm: the engine
	# compares and tallies label CODES and never sees a string, which is what keeps a
	# host's text representation out of it. Codes are assigned in first-appearance
	# order, so the engine's smallest-code-wins tie rule resolves in favour of the
	# label seen first in the training set.
	def _Ensure()
		_nEx_ = @oDs.NumberOfExamples()
		_nDim_ = @oDs.NumberOfFeatures()
		if @pModel_ != "" and @nFlatCount_ = _nEx_ and @nFlatDim_ = _nDim_
			return
		ok
		This._DropResident()

		# the ONE place the full set is read
		_aEx_ = @oDs.Examples()
		_aFlat_ = []
		_anCodes_ = []
		_acAlpha_ = []
		for _i_ = 1 to _nEx_
			_aRow_ = _aEx_[_i_][1]
			if len(_aRow_) != _nDim_
				stzraise("Example " + _i_ + " has " + len(_aRow_) +
					" feature(s) but the dataset is " + _nDim_ + " wide.")
			ok
			for _d_ = 1 to _nDim_
				_aFlat_ + _aRow_[_d_]
			next
			_cL_ = "" + _aEx_[_i_][2]
			_nCode_ = -1
			_nA_ = len(_acAlpha_)
			for _j_ = 1 to _nA_
				if _acAlpha_[_j_] = _cL_
					_nCode_ = _j_ - 1
					exit
				ok
			next
			if _nCode_ = -1
				_acAlpha_ + _cL_
				_nCode_ = len(_acAlpha_) - 1
			ok
			_anCodes_ + _nCode_
		next

		_bA_ = 0
		if @bApprox_
			_bA_ = 1
		ok
		@pModel_ = StzEngineKnnModelNew(_aFlat_, _nEx_, _nDim_, _anCodes_,
			len(_acAlpha_), _bA_, @nAnnTrees_, 42)
		if @pModel_ = ""
			stzraise("The engine refused the dataset (" + _nEx_ + " x " + _nDim_ + ").")
		ok
		@acAlphabet_ = _acAlpha_
		@nFlatCount_ = _nEx_
		@nFlatDim_ = _nDim_

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
