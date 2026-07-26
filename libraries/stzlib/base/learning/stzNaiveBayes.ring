# R4 step 0 -- stzNaiveBayes: THE TEXT LEARNER (ties into linguistic/)
# Multinomial naive Bayes over word counts, Laplace-smoothed --
# tiny, explainable, and the classifier that completes the R3 corpus
# story: your labeled texts train it, no downloads, no model files.
#
#   oNB = new stzNaiveBayes()
#   oNB.Train("great food and lovely staff", "positive")
#   oNB.Train("cold soup, rude waiter", "negative")
#   ? oNB.Classify("lovely evening, great dishes")   #--> "positive"
#   ? oNB.Why()

class stzNaiveBayes from stzObject

	# PARALLEL NAME/VALUE LISTS, NOT RING HASH-LISTS -- see the note on Train().
	# @acLabels is the authority for label order; @anLabelDocs and @anLabelWords
	# are indexed by the SAME position, so one ring_find serves both.
	@acLabels = []        # distinct labels, first-seen order
	@anLabelDocs = []     # docs seen per label, by label position
	@anLabelWords = []    # total words per label, by label position
	@acCountKeys = []     # "label|word"
	@anCountVals = []     # its count, by the same position
	@acVocab = []
	@nDocs = 0
	@cWhy = ""

	def init()

	# THE HASH-LIST IDIOM WAS THE WHOLE COST OF THIS CLASS.
	#
	# Training on ONE HUNDRED thirty-word documents took 12.5 seconds, and six
	# hundred took 82. Profiled rather than guessed at, because the obvious suspect
	# -- the tokenizer, which builds a stzText per document -- turned out to be
	# nothing:
	#
	#     tokenising 100 documents                    0.045 s
	#     HasKey-counting their 3000 tokens           4.789 s     (800 keys)
	#     the same 3000 into a ring_find list         0.010 s
	#
	# FOUR HUNDRED AND SEVENTY-NINE TIMES, on identical work, and this class ran
	# three of those blocks per word. Ring's `HasKey(list, key)` followed by
	# `list[key] = ...` is not a hash lookup that stays flat: writing through the
	# key appears to invalidate the index, so the next HasKey pays to rebuild it,
	# and the cost climbs with the number of distinct keys. Measured separately: 2
	# distinct keys 1.5 s, 50 distinct keys 12.9 s -- 8.5x worse for 25x the keys,
	# where a linear scan went 0.054 s to 0.068 s and barely noticed.
	#
	# So the maps below are parallel name/value lists scanned with ring_find --
	# which is exactly what @acVocab already did, so this makes the counts as fast
	# as the vocabulary always was. Training 100 documents: 12.5 s -> 0.06 s.
	#
	# For a very large vocabulary a scan is not the final answer either; the right
	# structure would be a real hash keyed by (label, vocabulary position). That is
	# a design change, and this is not: the behaviour and the arithmetic are
	# unchanged, which the guard checks by comparing classifications.
	def Train(pcText, pcLabel)
		_cL_ = StzLower(ring_trim("" + pcLabel))
		_acW_ = This._TokensOf(pcText)
		_nW_ = len(_acW_)

		_nLi_ = ring_find(@acLabels, _cL_)
		if _nLi_ = 0
			@acLabels + _cL_
			@anLabelDocs + 1
			@anLabelWords + 0
			_nLi_ = len(@acLabels)
		else
			@anLabelDocs[_nLi_]++
		ok

		for _i_ = 1 to _nW_
			_cKey_ = _cL_ + "|" + _acW_[_i_]
			_nKi_ = ring_find(@acCountKeys, _cKey_)
			if _nKi_ = 0
				@acCountKeys + _cKey_
				@anCountVals + 1
			else
				@anCountVals[_nKi_]++
			ok
			@anLabelWords[_nLi_]++
			if ring_find(@acVocab, _acW_[_i_]) = 0
				@acVocab + _acW_[_i_]
			ok
		next
		@nDocs++
		return This

	# same list, same first-seen order that keys(@aLabelDocs) produced
	def Labels()
		return @acLabels

	def Classify(pcText)
		if @nDocs = 0
			stzraise("Can't classify: train me first (Train(text, label)).")
		ok
		_acW_ = This._TokensOf(pcText)
		_nW_ = len(_acW_)
		_acLabels_ = @acLabels
		_nL_ = len(_acLabels_)
		_nV_ = len(@acVocab)

		_cBest_ = ""
		_nBest_ = 0
		_bFirst_ = 1
		_cScores_ = ""
		for _l_ = 1 to _nL_
			_cL_ = _acLabels_[_l_]
			# log prior + sum log P(word|label), Laplace-smoothed
			_nScore_ = log( @anLabelDocs[_l_] / @nDocs )
			_nTotal_ = @anLabelWords[_l_]
			for _w_ = 1 to _nW_
				_nC_ = 0
				_nKi_ = ring_find(@acCountKeys, _cL_ + "|" + _acW_[_w_])
				if _nKi_ > 0
					_nC_ = @anCountVals[_nKi_]
				ok
				_nScore_ += log( (_nC_ + 1) / (_nTotal_ + _nV_) )
			next
			if _cScores_ != ""
				_cScores_ += ", "
			ok
			_cScores_ += "'" + _cL_ + "' " + _nScore_
			if _bFirst_ = 1 or _nScore_ > _nBest_
				_nBest_ = _nScore_
				_cBest_ = _cL_
				_bFirst_ = 0
			ok
		next

		@cWhy = "log-scores: " + _cScores_ + " -- best: '" + _cBest_ + "'"
		$nStzLastCertainty = 1
		$cStzLastWhyB = @cWhy
		return _cBest_

	def Why()
		return @cWhy

	def _TokensOf(pcText)
		_oT_ = new stzText("" + pcText)
		_acRaw_ = _oT_.Words()
		_acOut_ = []
		_n_ = len(_acRaw_)
		for _i_ = 1 to _n_
			_acOut_ + StzLower(_acRaw_[_i_])
		next
		return _acOut_
