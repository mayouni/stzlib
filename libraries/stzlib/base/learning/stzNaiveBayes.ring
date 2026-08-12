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

	# THE MODEL LIVES IN THE ENGINE (numeric phase 5, second pass).
	#
	# Two passes got here. The first replaced Ring hash-lists bumped through HasKey
	# -- 12.497 s to train on ONE HUNDRED thirty-word documents -- with ring_find
	# scans, 142x faster and still a linear scan over a key list the size of the
	# vocabulary. 3000 documents took 3.647 s.
	#
	# But only about two thirds of that was counting. The rest was _TokensOf(),
	# which built a whole stzText object per document just to reach the word
	# iterator. Moving the counting alone would have left that floor in place, so
	# tokenization moved with it and the model became resident.
	#
	# THE TOKENIZATION IS THE SAME TOKENIZATION, and it had to be. stzText.Words()
	# goes through str_extract_words, which walks UAX#29 word segmentation, and
	# _TokensOf lowercased each token with StzLower. bayes.zig uses that same
	# WordIter and the same case fold -- ASCII byte-wise, everything else through
	# the full Unicode fold. A whitespace split would have agreed on "the cat sat"
	# and quietly built a different model on "don't", "3.14", "word2vec" and every
	# CJK document.
	#
	#     100 documents    12.497 s -> 0.007 s
	#     3000 documents    3.647 s (post-pass-1) -> 0.049 s
	#
	# @pModel is the handle. Labels() and Classify() read through it; nothing on
	# this side counts anything any more.
	@pModel = ""
	@cWhy = ""

	def init()
		@pModel = StzEngineBayesNew()
		if @pModel = ""
			stzraise("The engine refused to create the model.")
		ok

	def Train(pcText, pcLabel)
		# the label is folded HERE, once per document, because that is where it was
		# folded before -- StzLower(ring_trim(...)) -- and the engine is given the
		# result rather than the rule
		_cL_ = StzLower(ring_trim("" + pcLabel))
		if StzEngineBayesTrain(@pModel, "" + pcText, _cL_) = 0
			stzraise("The engine refused the document.")
		ok
		return This

	def Labels()
		return StzEngineBayesLabels(@pModel)

	def NumberOfDocuments()
		_a_ = StzEngineBayesStats(@pModel)
		return _a_[1]

	def VocabularySize()
		_a_ = StzEngineBayesStats(@pModel)
		return _a_[2]

	def Classify(pcText)
		_aSt_ = StzEngineBayesStats(@pModel)
		if _aSt_[1] = 0
			stzraise("Can't classify: train me first (Train(text, label)).")
		ok

		_acLabels_ = StzEngineBayesLabels(@pModel)
		_anScores_ = StzEngineBayesScores(@pModel, "" + pcText)
		if NOT isList(_anScores_) or len(_anScores_) != len(_acLabels_)
			stzraise("The engine refused the classification.")
		ok

		# the winner is the FIRST strict maximum in label order, which is how this
		# class has always broken a tie -- first label trained wins
		_cBest_ = ""
		_nBest_ = 0
		_bFirst_ = 1
		_cScores_ = ""
		_nL_ = len(_acLabels_)
		for _l_ = 1 to _nL_
			if _cScores_ != ""
				_cScores_ += ", "
			ok
			_cScores_ += "'" + _acLabels_[_l_] + "' " + _anScores_[_l_]
			if _bFirst_ = 1 or _anScores_[_l_] > _nBest_
				_nBest_ = _anScores_[_l_]
				_cBest_ = _acLabels_[_l_]
				_bFirst_ = 0
			ok
		next

		@cWhy = "log-scores: " + _cScores_ + " -- best: '" + _cBest_ + "'"
		$nStzLastCertainty = 1
		$cStzLastWhyB = @cWhy
		return _cBest_

	def Why()
		return @cWhy

	# _TokensOf() USED TO BE HERE and is deliberately gone. It built a stzText per
	# document to reach Words(), then lowercased each token -- about a third of the
	# training cost, and a second place where the tokenization rule lived. bayes.zig
	# walks the same UAX#29 iterator str_extract_words walks, so there is one
	# tokenizer rather than two that agree until one is touched.
