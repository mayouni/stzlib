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

	def Train()
		_aEx_ = @oTs.Examples()
		if len(_aEx_) = 0
			stzraise("Can't train on an empty training set.")
		ok
		_acIdx_ = []
		_nF_ = @oTs.NumberOfFeatures()
		for _i_ = 1 to _nF_
			_acIdx_ + _i_
		next
		@aTree = This._Build(_aEx_, _acIdx_)
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

	def _Build(paEx, pacIdx)
		_cMaj_ = This._Majority(paEx)
		# pure node -> leaf
		if This._IsPure(paEx)
			return [ :leaf = paEx[1][2] ]
		ok
		# no features left -> majority leaf
		if len(pacIdx) = 0
			return [ :leaf = _cMaj_ ]
		ok
		# best feature by information gain
		_nBase_ = This._Entropy(paEx)
		_nBestF_ = pacIdx[1]
		_nBestGain_ = -1
		_nI_ = len(pacIdx)
		for _i_ = 1 to _nI_
			_nGain_ = _nBase_ - This._SplitEntropy(paEx, pacIdx[_i_])
			if _nGain_ > _nBestGain_
				_nBestGain_ = _nGain_
				_nBestF_ = pacIdx[_i_]
			ok
		next
		# split on the winner
		_acVals_ = This._ValuesOf(paEx, _nBestF_)
		_acRest_ = []
		for _i_ = 1 to _nI_
			if pacIdx[_i_] != _nBestF_
				_acRest_ + pacIdx[_i_]
			ok
		next
		_aBranches_ = []
		_nV_ = len(_acVals_)
		for _v_ = 1 to _nV_
			_aSub_ = This._Subset(paEx, _nBestF_, _acVals_[_v_])
			_aBranches_ + [ _acVals_[_v_], This._Build(_aSub_, _acRest_) ]
		next
		return [ :feature = _nBestF_, :branches = _aBranches_, :default = _cMaj_ ]

	def _IsPure(paEx)
		_n_ = len(paEx)
		for _i_ = 2 to _n_
			if paEx[_i_][2] != paEx[1][2]
				return 0
			ok
		next
		return 1

	def _Majority(paEx)
		_aC_ = []
		_n_ = len(paEx)
		for _i_ = 1 to _n_
			if HasKey(_aC_, paEx[_i_][2])
				_aC_[paEx[_i_][2]] = _aC_[paEx[_i_][2]] + 1
			else
				_aC_[paEx[_i_][2]] = 1
			ok
		next
		_cBest_ = ""
		_nBest_ = -1
		_nC_ = len(_aC_)
		for _i_ = 1 to _nC_
			if _aC_[_i_][2] > _nBest_
				_nBest_ = _aC_[_i_][2]
				_cBest_ = _aC_[_i_][1]
			ok
		next
		return _cBest_

	def _Entropy(paEx)
		_aC_ = []
		_n_ = len(paEx)
		for _i_ = 1 to _n_
			if HasKey(_aC_, paEx[_i_][2])
				_aC_[paEx[_i_][2]] = _aC_[paEx[_i_][2]] + 1
			else
				_aC_[paEx[_i_][2]] = 1
			ok
		next
		_nH_ = 0
		_nC_ = len(_aC_)
		for _i_ = 1 to _nC_
			_nP_ = _aC_[_i_][2] / _n_
			_nH_ -= _nP_ * (log(_nP_) / log(2))
		next
		return _nH_

	def _SplitEntropy(paEx, nF)
		_acVals_ = This._ValuesOf(paEx, nF)
		_nH_ = 0
		_n_ = len(paEx)
		_nV_ = len(_acVals_)
		for _v_ = 1 to _nV_
			_aSub_ = This._Subset(paEx, nF, _acVals_[_v_])
			_nH_ += (len(_aSub_) / _n_) * This._Entropy(_aSub_)
		next
		return _nH_

	def _ValuesOf(paEx, nF)
		_acOut_ = []
		_n_ = len(paEx)
		for _i_ = 1 to _n_
			_cV_ = StzLower("" + paEx[_i_][1][nF])
			if ring_find(_acOut_, _cV_) = 0
				_acOut_ + _cV_
			ok
		next
		return _acOut_

	def _Subset(paEx, nF, pcVal)
		_aOut_ = []
		_n_ = len(paEx)
		for _i_ = 1 to _n_
			if StzLower("" + paEx[_i_][1][nF]) = pcVal
				_aOut_ + paEx[_i_]
			ok
		next
		return _aOut_

	def _NameOf(nF)
		if nF <= len(@acNames)
			return "" + @acNames[nF]
		ok
		return "f" + nF
