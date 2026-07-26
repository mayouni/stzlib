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
	@acKeys = []          # keys parallel to the pairs _CountAll returns

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

	# THE RETURNED SHAPE IS UNCHANGED -- a list of [ key, count ] pairs, which is
	# what FrequentItemsets() and Rules() index as _aC_[i][1] and _aC_[i][2]. What
	# changed is how a key is FOUND.
	#
	# This used to be a Ring hash-list bumped through HasKey, and it cost 16.1
	# seconds for two hundred six-item transactions (47.6 for six hundred). The
	# same idiom was the whole cost of stzNaiveBayes and of this library's decision
	# tree; measured there, `HasKey` + write-through-the-key is 479x a ring_find
	# scan on identical work, and it degrades as distinct keys accumulate while the
	# scan barely notices. Apriori is the worst case for it because the key space
	# IS the answer: every singleton, pair and triple in every transaction.
	#
	# @acKeys holds the same keys in the same order as the returned pairs, so a
	# lookup is one scan of a flat string list. _CountOf() reads it, which is why
	# it is an attribute rather than a local -- Rules() calls _CountAll() and then
	# asks for antecedent counts out of the result it was given.
	def _CountAll()
		_aC_ = []
		@acKeys = []
		_nT_ = len(@aTx)
		for _t_ = 1 to _nT_
			_acT_ = This._Sorted(@aTx[_t_])
			_nI_ = len(_acT_)
			for _i_ = 1 to _nI_
				_cA_ = _acT_[_i_]
				_nK_ = ring_find(@acKeys, _cA_)
				if _nK_ = 0
					@acKeys + _cA_
					_aC_ + [ _cA_, 1 ]
				else
					_aC_[_nK_][2]++
				ok
				for _j_ = _i_ + 1 to _nI_
					_cB_ = _cA_ + "|" + _acT_[_j_]
					_nK_ = ring_find(@acKeys, _cB_)
					if _nK_ = 0
						@acKeys + _cB_
						_aC_ + [ _cB_, 1 ]
					else
						_aC_[_nK_][2]++
					ok
					for _k_ = _j_ + 1 to _nI_
						_cC_ = _cB_ + "|" + _acT_[_k_]
						_nK_ = ring_find(@acKeys, _cC_)
						if _nK_ = 0
							@acKeys + _cC_
							_aC_ + [ _cC_, 1 ]
						else
							_aC_[_nK_][2]++
						ok
					next
				next
			next
		next
		return _aC_

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
		_nK_ = ring_find(@acKeys, _cKey_)
		if _nK_ > 0
			return paC[_nK_][2]
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
