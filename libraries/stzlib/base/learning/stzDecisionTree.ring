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

# Learns a decision tree over categorical features by ID3 and explains each answer as the path it followed.
#
# The tree splits on the feature with the greatest information gain and ends in the majority label.
# It is the most explainable learner of the module: Why narrates the exact path of the last
# classification, and ToGraph returns the tree as a real stzGraph that the rest of the library can
# query. Feature values compare without regard to case. A value never seen during training falls to
# the majority label of the node it reached, and Why says so. The build runs in the engine; the
# choices are deterministic, with the first feature to reach the highest gain winning a tie. Numeric
# features are treated as categories, so each distinct number is its own value.
#
#   receiver   o1 = new stzDecisionTree(new stzTrainingSet([ [["sunny", "high"], "no"], [["sunny",
#              "normal"], "yes"], [["rainy", "high"], "no"], [["overcast", "high"], "yes"],
#              [["rainy", "normal"], "yes"] ]))
#   example    o1.SetFeatureNames([ "outlook", "humidity" ])
#              o1.Train()
#              ? o1.Classify([ "sunny", "high" ])
#              #--> no
#              ? o1.Why()
#              #--> humidity='high' -> outlook='sunny' -> 'no'
#              ? o1.Classify([ "Rainy", "normal" ])
#              #--> yes
#   see        stzTrainingSet, stzGraph, stzNaiveBayes
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

	# Builds an untrained decision tree over a training set of categorical features.
	#
	#   poTrainingSet   a stzTrainingSet
	#   returns         nothing; the object is built
	#   see             Train, TrainingSetQ
	def init(poTrainingSet)
		@oTs = poTrainingSet

	# Returns the training set the tree holds, the one to grow if more examples are wanted.
	#
	#   returns    a stzTrainingSet
	#   warning    growing the set you passed to the constructor does not reach the tree, because it
	#              keeps a copy; grow it here and call Train again
	#   see        Train
	#@ aka  THE HELD SET IS LIVE THROUGH HERE. Ring COPIES an object into an attribute, so the set handed to the constructor is a SNAPSHOT: growing the caller's own object afterwards would NOT reach this learner. Grow it through this accessor -- oLearner.TrainingSetQ().AddExample(...) -- which reaches the real held set (accessor + method call is live in Ring).
	def TrainingSetQ()
		return @oTs

	# Sets a name for each feature, so that Why and ToGraph can speak of outlook instead of f1.
	#
	#   pacNames   a list of text, one name per feature in the order of the examples
	#   returns    the tree itself, so calls chain
	#   note       an unnamed feature is called f1, f2 and so on
	#   see        Why, ToGraph
	def SetFeatureNames(pacNames)
		@acNames = pacNames
		return This

	# Builds the tree by ID3, choosing at each node the feature with the greatest information gain; the build runs in the engine.
	#
	#   returns    the tree itself, so calls chain
	#   note       values compare without regard to case; calling it again rebuilds the tree from
	#              the set
	#   warning    raises an error for an empty set, for examples with no features, and for an
	#              example whose width differs from the first one, naming it
	#   see        Classify, Tree
	#@ aka  THE CASE FOLD HAPPENS ONCE HERE, not at every node (numeric phase 5).
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

	# Returns the learned tree as nested lists: [ :feature, :branches, :default ] for a decision and [ :leaf ] for an answer.
	#
	#   returns    a nested list; :feature is the position of the feature, :branches a list of [
	#              value, subtree ] pairs, :default the majority label
	#   note       an untrained tree answers an empty list
	#   see        ToGraph, Classify
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

	# Returns the label the tree gives to a feature list, and keeps the path it followed for Why.
	#
	#   paFeatures   the feature values, in the order of the training examples
	#   returns      a text, the label
	#   note         values compare without regard to case
	#   warning      raises an error telling to call Train first; a value never seen at a node falls
	#                to that node's majority label, which Why says
	#   see          Why, Train
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

	# Returns the path of the last classification as text, such as humidity='high' -> outlook='sunny' -> 'no'.
	#
	#   returns    a text; empty before the first Classify
	#   note       an unseen value is marked in the path with unseen value and the default it fell
	#              to
	#   see        Classify, SetFeatureNames
	def Why()
		return @cWhy

	# Returns the learned tree as a real graph of decision nodes, value edges and leaf nodes.
	#
	#   returns    a stzGraph; nodes n1, n2 and so on, each with a kind (decision or leaf) and a
	#              label
	#   note       the graph can be queried like any other graph
	#   warning    raises an error telling to call Train first
	#   see        Tree, SetFeatureNames
	#@ aka  the learned model as a REAL stzGraph: decision nodes + labeled value edges + leaf nodes -- queryable like any other graph
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
