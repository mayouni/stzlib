# R4 step 0 -- stzApriori: EXPLAINABLE IF-THEN RULES from transactions
# Frequent itemsets (levelwise, floor tier: singles/pairs/triples --
# the classic basket sizes) and association rules with support +
# confidence. Every rule reads as knowledge: "IF espresso THEN
# tiramisu (confidence 0.75)" -- ready for the knowledge graph.
#
#   oA = new stzApriori([ ["bread","butter"], ["bread","jam"], ... ])
#   ? oA.FrequentItemsets(2)
#   ? oA.Rules(2, 0.6)

class stzApriori from stzObject

	@aTx = []       # transactions: lists of lowered item strings

	def init(paTransactions)
		if isList(paTransactions)
			_n_ = len(paTransactions)
			for _i_ = 1 to _n_
				if isList(paTransactions[_i_])
					_acT_ = []
					_nI_ = len(paTransactions[_i_])
					for _j_ = 1 to _nI_
						_cIt_ = StzLower(ring_trim("" + paTransactions[_i_][_j_]))
						if _cIt_ != "" and ring_find(_acT_, _cIt_) = 0
							_acT_ + _cIt_
						ok
					next
					@aTx + _acT_
				ok
			next
		ok

	def NumberOfTransactions()
		return len(@aTx)

	# [ [ items(list), count ] ... ] with count >= nMinCount,
	# itemset sizes 1..3 (the floor; larger sets = engine tier later)
	def FrequentItemsets(nMinCount)
		_aC_ = This._CountAll()
		_aOut_ = []
		_n_ = len(_aC_)
		for _i_ = 1 to _n_
			if _aC_[_i_][2] >= nMinCount
				_aOut_ + [ StzSplit(_aC_[_i_][1], "|"), _aC_[_i_][2] ]
			ok
		next
		return _aOut_

	# association rules [ :if, :then, :support, :confidence ] from the
	# frequent pairs and triples, confidence-filtered
	def Rules(nMinCount, nMinConf)
		_aC_ = This._CountAll()
		_aRules_ = []
		_n_ = len(_aC_)
		for _i_ = 1 to _n_
			if _aC_[_i_][2] < nMinCount
				loop
			ok
			_acItems_ = StzSplit(_aC_[_i_][1], "|")
			_nSz_ = len(_acItems_)
			if _nSz_ < 2
				loop
			ok
			# each item in turn is the consequent; the rest the antecedent
			for _t_ = 1 to _nSz_
				_acIf_ = []
				for _k_ = 1 to _nSz_
					if _k_ != _t_
						_acIf_ + _acItems_[_k_]
					ok
				next
				_nIfCount_ = This._CountOf(_aC_, _acIf_)
				if _nIfCount_ > 0
					_nConf_ = _aC_[_i_][2] / _nIfCount_
					if _nConf_ >= nMinConf
						_aRules_ + [ :if = _acIf_, :then = _acItems_[_t_],
							:support = _aC_[_i_][2], :confidence = _nConf_ ]
					ok
				ok
			next
		next
		return _aRules_

	#-- internals -----------------------------------------------------------

	def _CountAll()
		_aC_ = []
		_nT_ = len(@aTx)
		for _t_ = 1 to _nT_
			_acT_ = This._Sorted(@aTx[_t_])
			_nI_ = len(_acT_)
			for _i_ = 1 to _nI_
				This._BumpKey(_aC_, _acT_[_i_])
				for _j_ = _i_ + 1 to _nI_
					This._BumpKey(_aC_, _acT_[_i_] + "|" + _acT_[_j_])
					for _k_ = _j_ + 1 to _nI_
						This._BumpKey(_aC_, _acT_[_i_] + "|" + _acT_[_j_] + "|" + _acT_[_k_])
					next
				next
			next
		next
		return _aC_

	def _BumpKey(paC, pcKey)
		if HasKey(paC, pcKey)
			paC[pcKey] = paC[pcKey] + 1
		else
			paC[pcKey] = 1
		ok

	def _CountOf(paC, pacItems)
		_cKey_ = ""
		_acS_ = This._Sorted(pacItems)
		_n_ = len(_acS_)
		for _i_ = 1 to _n_
			if _cKey_ != ""
				_cKey_ += "|"
			ok
			_cKey_ += _acS_[_i_]
		next
		if HasKey(paC, _cKey_)
			return paC[_cKey_]
		ok
		return 0

	def _Sorted(pacItems)
		_ac_ = []
		_n_ = len(pacItems)
		for _i_ = 1 to _n_
			_ac_ + pacItems[_i_]
		next
		for _i_ = 2 to _n_
			_cE_ = _ac_[_i_]
			_j_ = _i_ - 1
			while _j_ >= 1
				# strcmp, NOT ">": Ring's > on strings coerces numerically
				if strcmp(_ac_[_j_], _cE_) > 0
					_ac_[_j_ + 1] = _ac_[_j_]
					_j_--
				else
					exit
				ok
			end
			_ac_[_j_ + 1] = _cE_
		next
		return _ac_
