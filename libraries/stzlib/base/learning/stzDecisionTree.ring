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

	@oTs = NULL
	@acNames = []
	@aTree = []
	@cWhy = ""
	@bTrained = 0
	@nNodeSeq = 0
	@aNorm = []    # examples with every feature value case-folded ONCE

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

		# One pass: fold every value, and check the width while we are here.
		# The width check is free at this point and was absent before -- a row
		# narrower than the first raised a bare Ring "Array Access (Index out of
		# range)" from inside _ValuesOf, and a wider one was silently ignored.
		@aNorm = []
		_nEx_ = len(_aEx_)
		for _i_ = 1 to _nEx_
			_aRow_ = _aEx_[_i_][1]
			if len(_aRow_) != _nF_
				stzraise("Example " + _i_ + " has " + len(_aRow_) +
					" feature(s) but the set is " + _nF_ + " wide. " +
					"Every example must have the same features.")
			ok
			_aFolded_ = []
			for _f_ = 1 to _nF_
				_aFolded_ + StzLower("" + _aRow_[_f_])
			next
			@aNorm + [ _aFolded_, _aEx_[_i_][2] ]
		next

		_acFeat_ = []
		for _i_ = 1 to _nF_
			_acFeat_ + _i_
		next
		_aPos_ = []
		for _i_ = 1 to _nEx_
			_aPos_ + _i_
		next
		@aTree = This._Build(_aPos_, _acFeat_)
		@bTrained = 1
		return This

	def Tree()
		return @aTree

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

	# THE RECURSION CARRIES ROW NUMBERS, NOT ROWS.
	#
	# _Subset() used to return a list of copied example rows, and ID3 subsets at
	# every node of every level -- so the whole training set was copied once per
	# level, and Ring copies a list again when returning it from a method. That is
	# why the win from the two fixes above shrank as n grew. Measured at n = 4000,
	# 20 passes:
	#
	#     appending 4000 rows                0.176 s
	#     appending 4000 row NUMBERS         0.008 s      22x
	#     reading a value through the index  0.024 s
	#     reading it directly                0.021 s      the index costs 14%
	#
	# So the indirection is nearly free on the read side and removes the copy
	# entirely on the write side. Every helper below takes a list of positions
	# into @aNorm; @aNorm itself is built once by Train() and never copied.
	def _Build(paPos, pacFeat)
		_cMaj_ = This._Majority(paPos)
		# pure node -> leaf
		if This._IsPure(paPos)
			return [ :leaf = @aNorm[paPos[1]][2] ]
		ok
		# no features left -> majority leaf
		if len(pacFeat) = 0
			return [ :leaf = _cMaj_ ]
		ok
		# best feature by information gain
		_nBase_ = This._Entropy(paPos)
		_nBestF_ = pacFeat[1]
		_nBestGain_ = -1
		_nI_ = len(pacFeat)
		for _i_ = 1 to _nI_
			_nGain_ = _nBase_ - This._SplitEntropy(paPos, pacFeat[_i_])
			if _nGain_ > _nBestGain_
				_nBestGain_ = _nGain_
				_nBestF_ = pacFeat[_i_]
			ok
		next
		# split on the winner
		_acVals_ = This._ValuesOf(paPos, _nBestF_)
		_acRest_ = []
		for _i_ = 1 to _nI_
			if pacFeat[_i_] != _nBestF_
				_acRest_ + pacFeat[_i_]
			ok
		next
		_aBranches_ = []
		_nV_ = len(_acVals_)
		for _v_ = 1 to _nV_
			_aSub_ = This._Subset(paPos, _nBestF_, _acVals_[_v_])
			_aBranches_ + [ _acVals_[_v_], This._Build(_aSub_, _acRest_) ]
		next
		return [ :feature = _nBestF_, :branches = _aBranches_, :default = _cMaj_ ]

	def _IsPure(paPos)
		_n_ = len(paPos)
		if _n_ = 0
			return 1
		ok
		_cFirst_ = @aNorm[paPos[1]][2]
		for _i_ = 2 to _n_
			if @aNorm[paPos[_i_]][2] != _cFirst_
				return 0
			ok
		next
		return 1

	# ONE DEFINITION OF THE LABEL COUNT, and it is where the time was going.
	#
	# _Majority() and _Entropy() each carried a byte-for-byte identical counting
	# loop -- the shape this numeric phase keeps paying for -- and both used the
	# Ring idiom
	#
	#     if HasKey(aC, key) : aC[key] = aC[key] + 1 else aC[key] = 1
	#
	# which is THE dominant cost of training. Measured over 4000 examples, 20 runs:
	#
	#                              2 labels      50 labels
	#     HasKey idiom              1.515 s       12.858 s
	#     parallel lists below      0.054 s        0.068 s
	#                                 28x            189x
	#
	# Note the second column. The linear scan barely notices going from 2 distinct
	# labels to 50 (0.054 -> 0.068), while the HasKey form gets EIGHT AND A HALF
	# TIMES WORSE -- so whatever it is doing on a Ring list, it is not a hash
	# lookup that stays flat. A scan over a handful of distinct labels wins easily,
	# and it wins by more the more labels there are.
	#
	# Insertion order is preserved (first-seen), so _Majority's strict `>` still
	# breaks ties toward the label seen first -- exactly as before.
	def _Counts(paPos)
		_acN_ = []
		_anC_ = []
		_n_ = len(paPos)
		for _i_ = 1 to _n_
			_cL_ = @aNorm[paPos[_i_]][2]
			_k_ = ring_find(_acN_, _cL_)
			if _k_ = 0
				_acN_ + _cL_
				_anC_ + 1
			else
				_anC_[_k_]++
			ok
		next
		return [ _acN_, _anC_ ]

	def _Majority(paPos)
		_aCm_ = This._Counts(paPos)
		_acNm_ = _aCm_[1]
		_anCm_ = _aCm_[2]
		_cBest_ = ""
		_nBest_ = -1
		_nC_ = len(_acNm_)
		for _i_ = 1 to _nC_
			if _anCm_[_i_] > _nBest_
				_nBest_ = _anCm_[_i_]
				_cBest_ = _acNm_[_i_]
			ok
		next
		return _cBest_

	def _Entropy(paPos)
		_n_ = len(paPos)
		if _n_ = 0
			return 0
		ok
		_aCe_ = This._Counts(paPos)
		_anCe_ = _aCe_[2]
		_nH_ = 0
		_nC_ = len(_anCe_)
		for _i_ = 1 to _nC_
			_nP_ = _anCe_[_i_] / _n_
			_nH_ -= _nP_ * (log(_nP_) / log(2))
		next
		return _nH_

	def _SplitEntropy(paPos, nF)
		_acVals_ = This._ValuesOf(paPos, nF)
		_nH_ = 0
		_n_ = len(paPos)
		_nV_ = len(_acVals_)
		for _v_ = 1 to _nV_
			_aSub_ = This._Subset(paPos, nF, _acVals_[_v_])
			_nH_ += (len(_aSub_) / _n_) * This._Entropy(_aSub_)
		next
		return _nH_

	# The values in @aNorm are ALREADY folded -- Train() does it once. So no
	# StzLower here: doing it per visit is what made this the hot line.
	def _ValuesOf(paPos, nF)
		_acOut_ = []
		_n_ = len(paPos)
		for _i_ = 1 to _n_
			_cV_ = @aNorm[paPos[_i_]][1][nF]
			if ring_find(_acOut_, _cV_) = 0
				_acOut_ + _cV_
			ok
		next
		return _acOut_

	def _Subset(paPos, nF, pcVal)
		_aOut_ = []
		_n_ = len(paPos)
		for _i_ = 1 to _n_
			if @aNorm[paPos[_i_]][1][nF] = pcVal
				_aOut_ + paPos[_i_]
			ok
		next
		return _aOut_

	def _NameOf(nF)
		if nF <= len(@acNames)
			return "" + @acNames[nF]
		ok
		return "f" + nF
