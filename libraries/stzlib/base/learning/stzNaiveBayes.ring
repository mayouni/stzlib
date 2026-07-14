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

	@aLabelDocs = []      # [ label, count-of-docs ]
	@aLabelWords = []     # [ label, total-word-count ]
	@aCounts = []         # [ "label|word", count ]
	@acVocab = []
	@nDocs = 0
	@cWhy = ""

	def init()

	def Train(pcText, pcLabel)
		_cL_ = StzLower(ring_trim("" + pcLabel))
		_acW_ = This._TokensOf(pcText)
		_nW_ = len(_acW_)
		if HasKey(@aLabelDocs, _cL_)
			@aLabelDocs[_cL_] = @aLabelDocs[_cL_] + 1
		else
			@aLabelDocs[_cL_] = 1
		ok
		for _i_ = 1 to _nW_
			_cKey_ = _cL_ + "|" + _acW_[_i_]
			if HasKey(@aCounts, _cKey_)
				@aCounts[_cKey_] = @aCounts[_cKey_] + 1
			else
				@aCounts[_cKey_] = 1
			ok
			if HasKey(@aLabelWords, _cL_)
				@aLabelWords[_cL_] = @aLabelWords[_cL_] + 1
			else
				@aLabelWords[_cL_] = 1
			ok
			if ring_find(@acVocab, _acW_[_i_]) = 0
				@acVocab + _acW_[_i_]
			ok
		next
		@nDocs++
		return This

	def Labels()
		return keys(@aLabelDocs)

	def Classify(pcText)
		if @nDocs = 0
			stzraise("Can't classify: train me first (Train(text, label)).")
		ok
		_acW_ = This._TokensOf(pcText)
		_nW_ = len(_acW_)
		_acLabels_ = keys(@aLabelDocs)
		_nL_ = len(_acLabels_)
		_nV_ = len(@acVocab)

		_cBest_ = ""
		_nBest_ = 0
		_bFirst_ = 1
		_cScores_ = ""
		for _l_ = 1 to _nL_
			_cL_ = _acLabels_[_l_]
			# log prior + sum log P(word|label), Laplace-smoothed
			_nScore_ = log( @aLabelDocs[_cL_] / @nDocs )
			_nTotal_ = @aLabelWords[_cL_]
			for _w_ = 1 to _nW_
				_nC_ = 0
				if HasKey(@aCounts, _cL_ + "|" + _acW_[_w_])
					_nC_ = @aCounts[_cL_ + "|" + _acW_[_w_]]
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
