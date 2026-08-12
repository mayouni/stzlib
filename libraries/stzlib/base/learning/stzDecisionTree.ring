# R4 step 0 -- stzDecisionTree: THE MOST EXPLAINABLE LEARNER (ID3)
# A decision tree over CATEGORICAL features: entropy + information
# gain, majority leaves. Why() narrates the exact decision path, and
# ToGraph() emits a REAL stzGraph -- the learned model IS a graph the
# whole foundation can query (foundations compose, LAW 5).
#
#   oT = new stzDecisionTree(oTrainingSet)
#   oT.SetFeatureNames([ "outlook", "humidity" ])
#   oT.Train()
#   ? oT.Classify([ "sunny", "high" ])   #--> "no"
#   ? oT.Why()   #--> outlook='sunny' -> humidity='high' -> 'no'

class stzDecisionTree from stzObject

	@oTs = ""
	@acNames = []
	@aTree = []
	@cWhy = ""
	@bTrained = 0
	@nNodeSeq = 0
	@acValues = []  # distinct folded feature values, position = engine code + 1
	@acLabels = []  # distinct labels, likewise
	@aNodeAt = []   # the engine's flat nodes, while _Rebuild walks them
	@acRaw = []     # raw strings already folded, and...
	@anRawCode = [] # ...the code each resolved to -- see Train()

	def init(poTrainingSet)
		@oTs = poTrainingSet

	# THE HELD SET IS LIVE THROUGH HERE. Ring COPIES an object into an
	# attribute, so the set handed to the constructor is a SNAPSHOT: growing
	# the caller's own object afterwards would NOT reach this learner. Grow it
	# through this accessor -- oLearner.TrainingSetQ().AddExample(...) -- which
	# reaches the real held set (accessor + method call is live in Ring).
	def TrainingSetQ()
		return @oTs

	def SetFeatureNames(pacNames)
		@acNames = pacNames
		return This

	# THE CASE FOLD HAPPENS ONCE HERE, not at every node (numeric phase 5).
	#
	# ID3 compares categorical values case-insensitively, so "Sunny" and "sunny"
	# are one value. The fold used to live inside _ValuesOf() and _Subset(), which
	# means every row was re-folded once per (node, feature) pair -- and the value
	# never changes. Profiled on 4000 examples x 8 features:
	#
	#     _ValuesOf x20 over the set          0.338 s
	#     _Subset   x20 over the set          0.356 s
	#     StzLower  x20 alone                 0.297 s   <-- of that
	#     the same loops without it           0.022 s
	#
	# The fold was THIRTEEN TIMES the cost of the loop containing it, because
	# StzLower builds two engine string objects and frees them -- five bridge
	# crossings to lowercase one character. Folding the whole set once costs
	# 0.129 s and the inner loops drop 4.2x.
	#
	# Third time this phase has found this shape: the CSV module's per-cell regex
	# recompile, the linear solver's per-variable re-parse, and now this. The
	# expensive line is rarely the one the plan names -- the plan said "trees ->
	# engine", and the tree was never the problem.
	def Train()
		_aEx_ = @oTs.Examples()
		if len(_aEx_) = 0
			stzraise("Can't train on an empty training set.")
		ok

		_nF_ = @oTs.NumberOfFeatures()
		if _nF_ = 0
			stzraise("Can't train on examples with no features.")
		ok

		# ONE PASS: fold, INTERN, and check the width.
		#
		# The fold was already here (it used to happen at every node, which was 13x
		# the loop containing it). Interning is the new part and it is what lets the
		# build run in the engine: a categorical value's identity is all ID3 needs,
		# so once "sunny" is known to be value 3 nothing downstream has to compare a
		# string again. The scan that assigns the code is the same scan that folded.
		#
		# The width check is free here and was absent before -- a row narrower than
		# the first raised a bare Ring "Array Access (Index out of range)" from
		# inside _ValuesOf, and a wider one was silently ignored.
		@acValues = []
		@acLabels = []
		@acRaw = []
		@anRawCode = []
		_aFeatCodes_ = []
		_aLabelCodes_ = []
		_nEx_ = len(_aEx_)
		for _i_ = 1 to _nEx_
			_aRow_ = _aEx_[_i_][1]
			if len(_aRow_) != _nF_
				stzraise("Example " + _i_ + " has " + len(_aRow_) +
					" feature(s) but the set is " + _nF_ + " wide. " +
					"Every example must have the same features.")
			ok
			for _f_ = 1 to _nF_
				# FOLD EACH DISTINCT STRING ONCE, not each occurrence. StzLower
				# costs five bridge crossings (it builds two engine string objects
				# and frees them), and a categorical column has a handful of
				# distinct values repeated thousands of times -- 40000 x 10 was
				# 400000 folds of three actual strings. @acRaw remembers the code
				# each RAW form resolved to, so "Sunny" and "sunny" are folded once
				# each and then never again.
				_cRaw_ = "" + _aRow_[_f_]
				_nRaw_ = ring_find(@acRaw, _cRaw_)
				if _nRaw_ > 0
					_aFeatCodes_ + @anRawCode[_nRaw_]
				else
					_cV_ = StzLower(_cRaw_)
					_nAt_ = ring_find(@acValues, _cV_)
					if _nAt_ = 0
						@acValues + _cV_
						_nAt_ = len(@acValues)
					ok
					@acRaw + _cRaw_
					@anRawCode + (_nAt_ - 1)
					_aFeatCodes_ + (_nAt_ - 1)
				ok
			next
			_cL_ = _aEx_[_i_][2]
			_nAt_ = ring_find(@acLabels, _cL_)
			if _nAt_ = 0
				@acLabels + _cL_
				_nAt_ = len(@acLabels)
			ok
			_aLabelCodes_ + (_nAt_ - 1)
		next

		# THE BUILD RUNS IN THE ENGINE (numeric phase 5, second pass).
		#
		# The first pass fixed three real Ring-side mistakes here -- the per-node
		# fold, copied example rows, and the HasKey counting idiom -- and took
		# 4000 x 8 from 1.434s to 0.308s. That was worth doing and was the wrong
		# place to stop: 40000 x 10 still took 3.965s of arithmetic that is not
		# hard. tree.zig makes the same choices, and they are choices a user SEES:
		# the first feature to reach the maximum gain wins, the majority label is
		# the first to reach the maximum count in the order labels appear in that
		# SUBSET, branch values come out in first-seen order, and a pure node
		# becomes a leaf before the no-features-left case.
		_aFlat_ = StzEngineTreeId3(_aFeatCodes_, _aLabelCodes_, _nEx_, _nF_,
			len(@acLabels), len(@acValues))
		if NOT isList(_aFlat_) or len(_aFlat_) < 1
			stzraise("The engine refused the build (" + _nEx_ + " x " + _nF_ + ").")
		ok

		@aTree = This._Rebuild(_aFlat_)
		@bTrained = 1
		return This

	def Tree()
		return @aTree

	# Turn the engine's flat node array back into the nested shape this class has
	# always published -- [ :feature=, :branches=, :default= ] and [ :leaf= ] -- so
	# Tree(), Classify() and ToGraph() are untouched by the move. Codes become
	# strings again here, and nowhere else.
	def _Rebuild(paFlat)
		_nCount_ = paFlat[1]
		# read every node into [ kind, ... ] first, so a child can be resolved
		# whatever order it appears in
		@aNodeAt = []
		_nAt_ = 1
		for _i_ = 1 to _nCount_
			_nAt_++
			_nKind_ = paFlat[_nAt_]
			if _nKind_ = 0
				_nAt_++
				@aNodeAt + [ 0, paFlat[_nAt_] ]
			else
				_nF_ = paFlat[_nAt_ + 1]
				_nDef_ = paFlat[_nAt_ + 2]
				_nB_ = paFlat[_nAt_ + 3]
				_nAt_ += 3
				_aBr_ = []
				for _b_ = 1 to _nB_
					_aBr_ + [ paFlat[_nAt_ + 1], paFlat[_nAt_ + 2] ]
					_nAt_ += 2
				next
				@aNodeAt + [ 1, _nF_, _nDef_, _aBr_ ]
			ok
		next
		return This._NodeFrom(1)

	def _NodeFrom(n)
		_aN_ = @aNodeAt[n]
		if _aN_[1] = 0
			return [ :leaf = @acLabels[_aN_[2] + 1] ]
		ok
		_aBr_ = []
		_nB_ = len(_aN_[4])
		for _b_ = 1 to _nB_
			_aBr_ + [ @acValues[_aN_[4][_b_][1] + 1], This._NodeFrom(_aN_[4][_b_][2]) ]
		next
		return [ :feature = _aN_[2] + 1, :branches = _aBr_,
			:default = @acLabels[_aN_[3] + 1] ]

	def Classify(paFeatures)
		if @bTrained = 0
			stzraise("Train() me first.")
		ok
		_aNode_ = @aTree
		_cPath_ = ""
		_nGuard_ = 0
		while HasKey(_aNode_, "feature") and _nGuard_ < 50
			_nGuard_++
			_nF_ = _aNode_[:feature]
			_cV_ = StzLower("" + paFeatures[_nF_])
			if _cPath_ != ""
				_cPath_ += " -> "
			ok
			_cPath_ += This._NameOf(_nF_) + "='" + _cV_ + "'"
			_aNext_ = []
			_aBr_ = _aNode_[:branches]
			_nB_ = len(_aBr_)
			for _b_ = 1 to _nB_
				if _aBr_[_b_][1] = _cV_
					_aNext_ = _aBr_[_b_][2]
					exit
				ok
			next
			if len(_aNext_) = 0
				# unseen value: fall to the node's majority default
				@cWhy = _cPath_ + " (unseen value) -> default '" +
					_aNode_[:default] + "'"
				$cStzLastWhyB = @cWhy
				$nStzLastCertainty = 1
				return _aNode_[:default]
			ok
			_aNode_ = _aNext_
		end
		@cWhy = _cPath_ + " -> '" + _aNode_[:leaf] + "'"
		$cStzLastWhyB = @cWhy
		$nStzLastCertainty = 1
		return _aNode_[:leaf]

	def Why()
		return @cWhy

	# the learned model as a REAL stzGraph: decision nodes + labeled
	# value edges + leaf nodes -- queryable like any other graph
	def ToGraph()
		if @bTrained = 0
			stzraise("Train() me first.")
		ok
		_oG_ = new stzGraph("decisiontree")
		@nNodeSeq = 0
		This._GraphWalk(_oG_, @aTree, "")
		return _oG_

	def _GraphWalk(poG, paNode, pcParent)
		@nNodeSeq++
		_cId_ = "n" + @nNodeSeq
		if HasKey(paNode, "leaf")
			poG.AddNode(_cId_)
			poG.SetNodeProperty(_cId_, "kind", "leaf")
			poG.SetNodeProperty(_cId_, "label", paNode[:leaf])
		else
			poG.AddNode(_cId_)
			poG.SetNodeProperty(_cId_, "kind", "decision")
			poG.SetNodeProperty(_cId_, "label", This._NameOf(paNode[:feature]))
		ok
		if pcParent != ""
			poG.AddEdgeXTT(pcParent, _cId_, "branch", [])
		ok
		if HasKey(paNode, "branches")
			_aBr_ = paNode[:branches]
			_nB_ = len(_aBr_)
			_cMyId_ = _cId_
			for _b_ = 1 to _nB_
				This._GraphWalk(poG, _aBr_[_b_][2], _cMyId_)
			next
		ok

	#-- ID3 ----------------------------------------------------------------
	#
	# THE RING IMPLEMENTATION USED TO BE HERE and is deliberately gone: _Build,
	# _IsPure, _Counts, _Majority, _Entropy, _SplitEntropy, _ValuesOf and _Subset,
	# about 120 lines. Once the build moved to tree.zig, keeping them would have
	# meant TWO definitions of ID3 in one class -- the shape this numeric phase has
	# paid for over and over (the variance divisor, the summation, the centered sum
	# of squares, the negligible threshold, Euclidean distance, the score and the
	# sigmoid in stzLogisticRegression). They would have agreed on the day they were
	# written and drifted the first time either was touched, and the drift would
	# have surfaced as a tree that disagreed with itself about which feature it
	# split on.
	#
	# What remains on this side is the part that is genuinely Ring's: turning the
	# examples into codes once (_Rebuild's counterpart in Train), and turning the
	# engine's flat node array back into the nested [ :feature=, :branches= ]
	# structure this class publishes. Classify() and ToGraph() never knew.

	def _NameOf(nF)
		if nF <= len(@acNames)
			return "" + @acNames[nF]
		ok
		return "f" + nF
