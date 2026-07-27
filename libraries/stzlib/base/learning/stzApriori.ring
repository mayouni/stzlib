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
	@acItems = []         # distinct items in strcmp order -- position = code + 1

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
	# THE COUNT RUNS IN THE ENGINE (numeric phase 5, second pass).
	#
	# The first pass replaced a Ring hash-list bumped through HasKey -- 16.124 s for
	# two hundred transactions -- with a ring_find scan, which was 393x faster and
	# still a LINEAR SCAN over a key list that grows to every singleton, pair and
	# triple in the data. Fine at 640 keys, not fine at ten thousand: 5000
	# transactions still took 0.941 s. A scan was the right answer in Ring, where
	# the alternative was 479x worse. Here the right answer is an actual hash.
	#
	# ITEMS BECOME CODES IN strcmp ORDER, and that ordering is the load-bearing
	# part. _Sorted() below orders a basket's items with strcmp before the key
	# "a|b|c" is built, so {milk, bread} keys as "bread|milk" however it was
	# written. Assigning codes in strcmp order makes integer order the same order,
	# so the engine sorting codes reproduces it exactly.
	#
	# Insertion order is preserved because it is PUBLISHED -- FrequentItemsets()
	# returns itemsets in first-counted order and the suite asserts that "bread"
	# comes first -- so apriori.zig records the order keys arrive in and generates
	# them with Ring's exact loop nesting.
	def _CountAll()
		_nT_ = len(@aTx)
		if _nT_ = 0
			@acKeys = []
			return []
		ok

		# distinct items, then sorted by strcmp so the code IS the sort key
		_acDistinct_ = []
		for _t_ = 1 to _nT_
			_aOne_ = @aTx[_t_]
			for _i_ = 1 to len(_aOne_)
				_cIt_ = "" + _aOne_[_i_]
				if ring_find(_acDistinct_, _cIt_) = 0
					_acDistinct_ + _cIt_
				ok
			next
		next
		@acItems = This._Sorted(_acDistinct_)

		# transactions as codes, back to back, with an offset per transaction
		_aCodes_ = []
		_aOffsets_ = [ 0 ]
		_nAt_ = 0
		for _t_ = 1 to _nT_
			_aOne_ = @aTx[_t_]
			for _i_ = 1 to len(_aOne_)
				_aCodes_ + (ring_find(@acItems, "" + _aOne_[_i_]) - 1)
				_nAt_++
			next
			_aOffsets_ + _nAt_
		next

		_aFlat_ = StzEngineAprioriCount(_aCodes_, _aOffsets_, _nT_)
		if NOT isList(_aFlat_)
			stzraise("The engine refused the count (" + _nT_ + " transactions).")
		ok

		# [ size, c1, c2, c3, count ] * k  ->  [ [ "a|b|c", count ] ... ]
		_aC_ = []
		@acKeys = []
		_nRec_ = len(_aFlat_) / 5
		for _r_ = 1 to _nRec_
			_nB_ = (_r_ - 1) * 5
			_nSz_ = _aFlat_[_nB_ + 1]
			_cKey_ = @acItems[_aFlat_[_nB_ + 2] + 1]
			if _nSz_ >= 2
				_cKey_ += "|" + @acItems[_aFlat_[_nB_ + 3] + 1]
			ok
			if _nSz_ >= 3
				_cKey_ += "|" + @acItems[_aFlat_[_nB_ + 4] + 1]
			ok
			@acKeys + _cKey_
			_aC_ + [ _cKey_, _aFlat_[_nB_ + 5] ]
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
