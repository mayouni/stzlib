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

# Classifies a point by the majority label of its k nearest training examples, with no training step and a full explanation.
#
# The purest explainable classifier: nothing is fitted, and Why lists the neighbours that voted with
# their distances. The search is exact by default and runs in the engine; the resident index
# rebuilds when examples have been added through TrainingSetQ. Approximate search is an opt-in
# switch because the library cannot know how many queries will follow, and because it may change an
# answer; AgreementWithExact measures the cost on your own queries. Features are compared by
# Euclidean distance, so scale them first when their units differ.
#
#   receiver   o1 = new stzKnn(new stzTrainingSet([ [[5.1, 3.5], "setosa"], [[4.9, 3.0], "setosa"],
#              [[5.0, 3.4], "setosa"], [[6.5, 2.8], "virginica"], [[6.3, 3.3], "virginica"], [[6.7,
#              3.0], "virginica"] ]))
#   example    o1.SetK(3)
#              ? o1.Classify([5.0, 3.4])
#              #--> setosa
#              ? o1.Classify([6.4, 3.0])
#              #--> virginica
#              ? o1.Why()
#              #--> the 3 nearest examples were: #4 'virginica' (d=0.22), #6 'virginica' (d=0.30), #5 'virginica' (d=0.32) -- majority: 'virginica' (3/3)
#   see        stzTrainingSet, stzKMeans, stzNaiveBayes
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
	# Builds a k-nearest-neighbours classifier over a training set; nothing is trained and k starts at 3.
	#
	#   poDataset   a stzTrainingSet
	#   returns     nothing; the object is built
	#   see         SetK, Classify
	#@ aka  a different thing whenever the vote overrules proximity
	def init(poDataset)
		@oDs = poDataset

	# Returns the training set the classifier holds, the one to grow if more examples are wanted.
	#
	#   returns    a stzTrainingSet
	#   warning    growing the set you passed to the constructor does not reach the classifier,
	#              because it keeps a copy; grow it here, and the next Classify sees it
	#   see        Classify
	#@ aka  THE HELD SET IS LIVE THROUGH HERE. Ring COPIES an object into an attribute, so the set handed to the constructor is a SNAPSHOT: growing the caller's own object afterwards would NOT reach this learner. Grow it through this accessor -- oLearner.TrainingSetQ().AddExample(...) -- which reaches the real held set (accessor + method call is live in Ring).
	def TrainingSetQ()
		return @oDs

	# Sets how many nearest examples vote.
	#
	#   n          the number of neighbours, 1 or more
	#   returns    the classifier itself, so calls chain
	#   note       a value below 1 is ignored without a message and the earlier k stays
	#   see        K, Classify
	def SetK(n)
		if n >= 1
			@nK = n
		ok
		return This

	# Switches between exact search and an approximate one through a projection forest in the engine.
	#
	#   bFlag      1 for approximate search, 0 for exact
	#   returns    the classifier itself, so calls chain
	#   note       off by default: it pays only above a few thousand examples and many queries, and
	#              it can change an answer; AgreementWithExact measures that on your queries
	#   warning    raises an error unless the flag is exactly 1 or 0
	#   see        IsApproximate, AgreementWithExact
	#@ aka  ── APPROXIMATE SEARCH: OPT-IN, AND DELIBERATELY NOT AUTOMATIC ──
	def SetApproximate(bFlag)
		if bFlag != 1 and bFlag != 0
			stzraise("SetApproximate: TRUE or FALSE.")
		ok
		if bFlag != @bApprox_
			@bApprox_ = bFlag
			This._DropResident()
		ok
		return This

	# TRUE if approximate search is on.
	#
	#   returns    TRUE or FALSE; FALSE by default
	#   see        SetApproximate
	def IsApproximate()
		return @bApprox_

	# Sets how many trees the approximate index uses: more trees give better recall and a larger, slower index.
	#
	#   n          the number of trees, 1 or more
	#   returns    the classifier itself, so calls chain
	#   note       the default is 24
	#   warning    raises an error for a number below 1
	#   see        ApproximateTrees, SetApproximateBudget
	#@ aka  More trees, better recall, bigger index and a slower build.
	def SetApproximateTrees(n)
		if n < 1
			stzraise("SetApproximateTrees: at least one tree.")
		ok
		@nAnnTrees_ = n
		This._DropResident()
		return This

	# Sets how many candidates the approximate search examines per query before true distances decide.
	#
	#   n          the candidate count, 0 or more
	#   returns    the classifier itself, so calls chain
	#   note       it is the recall dial
	#   warning    raises an error for a negative number
	#   see        ApproximateBudget, SetApproximateTrees
	#@ aka  Candidates examined per query before the true distances decide. 0 lets the engine scale it from k. This is the recall dial.
	def SetApproximateBudget(n)
		if n < 0
			stzraise("SetApproximateBudget: a non-negative budget.")
		ok
		@nAnnBudget_ = n
		This._DropResident()
		return This

	# Returns the number of trees set for the approximate index.
	#
	#   returns    a number; 24 by default
	#   see        SetApproximateTrees
	def ApproximateTrees()
		return @nAnnTrees_

	# Returns the candidate budget set for the approximate search.
	#
	#   returns    a number; 0 means the engine chooses
	#   see        SetApproximateBudget
	def ApproximateBudget()
		return @nAnnBudget_

	# Returns the share of the given queries on which approximate and exact search give the same label.
	#
	#   paQueries   a non-empty list of feature lists, each as wide as the training examples
	#   returns     a number from 0 to 1
	#   note        the honest measure for a classifier: a vote often survives a swapped neighbour,
	#               so the label is compared and not the neighbour list
	#   warning     raises an error for an empty list or a query of the wrong width, naming it
	#   see         SetApproximate, Classify
	#@ aka  THE HONEST MEASURE FOR A CLASSIFIER: not how many neighbours the forest missed, but how often the LABEL still came out the same. Those are very different numbers -- a majority vote absorbs a swapped neighbour that a neighbour-recall figure would count as a loss -- and the label is what the caller actually receives.
	def AgreementWithExact(paQueries)
		if NOT isList(paQueries) or len(paQueries) = 0
			stzraise("AgreementWithExact: give me a non-empty list of queries.")
		ok
		This._Ensure()
		_nDim_ = @oDs.NumberOfFeatures()
		_nQ_ = len(paQueries)
		for _i_ = 1 to _nQ_
			if NOT isList(paQueries[_i_]) or len(paQueries[_i_]) != _nDim_
				stzraise("AgreementWithExact: query " + _i_ + " is not " + _nDim_ +
					" feature(s) wide.")
			ok
		next
		# THE FLATTENING TAX (2026-09-10): the queries go as rows; the bridge walks them
		_nR_ = StzEngineKnnModelAgreement(@pModel_, paQueries, _nQ_, @nK, @nAnnBudget_)
		if _nR_ < 0
			stzraise("AgreementWithExact: the engine refused the comparison.")
		ok
		return _nR_

	# Returns how many neighbours vote.
	#
	#   returns    a number; 3 by default
	#   see        SetK
	def K()
		return @nK

	# Returns the majority label among the k training examples nearest to a feature list, by Euclidean distance.
	#
	#   paFeatures   the numbers describing the thing to classify, as many as the training examples
	#                have
	#   returns      a text, the label
	#   note         the search runs in the engine and rebuilds when examples were added
	#   warning      raises an error for an empty training set and for a query of the wrong width; a
	#                tie goes to the label that appeared first in the training set
	#   see          Why, SetK
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

	# Returns the neighbours behind the last answer, each with its number and distance, and the vote.
	#
	#   returns    a text such as the 3 nearest examples were: #3 'setosa' (d=0), ... -- majority:
	#              'setosa' (3/3); empty before the first Classify
	#   see        Classify
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
		# THE FLATTENING TAX (2026-09-10): the examples' feature rows are gathered
		# as ROWS (one append per example, not one per number) and the bridge
		# walks them
		_aRows_ = []
		_anCodes_ = []
		_acAlpha_ = []
		for _i_ = 1 to _nEx_
			_aRow_ = _aEx_[_i_][1]
			if len(_aRow_) != _nDim_
				stzraise("Example " + _i_ + " has " + len(_aRow_) +
					" feature(s) but the dataset is " + _nDim_ + " wide.")
			ok
			_aRows_ + _aRow_
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
		@pModel_ = StzEngineKnnModelNew(_aRows_, _nEx_, _nDim_, _anCodes_,
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
