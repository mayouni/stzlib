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

# Classifies a text from the words of labelled texts, with Laplace smoothing and a score for every label.
#
# Your labelled texts train it: no download and no model file. The model is multinomial naive Bayes
# over word counts, kept in the engine, which tokenizes by Unicode word segmentation and folds case,
# so text in any script is counted the same way. Classify returns the label with the highest log-
# score, and Why lists the score of every label so that the decision can be read. A text made of
# words never seen is decided by the label proportions alone.
#
#   receiver   o1 = new stzNaiveBayes()
#   example    o1.Train("great food and lovely staff", "positive")
#              o1.Train("cold soup, rude waiter", "negative")
#              o1.Train("lovely evening and great dishes", "positive")
#              ? o1.Classify("lovely evening, great dishes")
#              #--> positive
#              ? o1.Classify("rude cold waiter")
#              #--> negative
#              ? o1.NumberOfDocuments()
#              #--> 3
#   see        stzTrainingSet, stzLogisticRegression, stzText
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

	# Builds an empty multinomial naive Bayes text classifier whose model lives in the engine.
	#
	#   returns    nothing; the object is built
	#   see        Train, Classify
	def init()
		@pModel = StzEngineBayesNew()
		if @pModel = ""
			stzraise("The engine refused to create the model.")
		ok

	# Adds one labelled text to the model, counting its words under the label.
	#
	#   pcText     the document
	#   pcLabel    its class, trimmed and folded to lower case
	#   returns    the classifier itself, so calls chain
	#   note       words are found by Unicode word segmentation and folded to lower case, so Hebrew,
	#              Arabic and CJK text work; an empty label is accepted as a label of its own
	#   see        Classify, Labels
	def Train(pcText, pcLabel)
		# the label is folded HERE, once per document, because that is where it was
		# folded before -- StzLower(ring_trim(...)) -- and the engine is given the
		# result rather than the rule
		_cL_ = StzLower(ring_trim("" + pcLabel))
		if StzEngineBayesTrain(@pModel, "" + pcText, _cL_) = 0
			stzraise("The engine refused the document.")
		ok
		return This

	# Returns the labels seen so far, in the order they were first trained.
	#
	#   returns    a list of text in lower case; empty before any Train
	#   see        Train, NumberOfDocuments
	def Labels()
		return StzEngineBayesLabels(@pModel)

	# Returns how many texts were trained.
	#
	#   returns    a number
	#   see        Train, VocabularySize
	def NumberOfDocuments()
		_a_ = StzEngineBayesStats(@pModel)
		return _a_[1]

	# Returns how many distinct words the model has seen.
	#
	#   returns    a number
	#   see        NumberOfDocuments
	def VocabularySize()
		_a_ = StzEngineBayesStats(@pModel)
		return _a_[2]

	# Returns the label whose Laplace-smoothed log-score is highest for a text.
	#
	#   pcText     the text to classify
	#   returns    a text, the best label
	#   note       a tie goes to the label trained first; a text of unseen words is decided by the
	#              label priors alone
	#   warning    raises an error telling to train first
	#   see        Why, Train
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

	# Returns the log-score of every label for the last text and the best one.
	#
	#   returns    a text such as log-scores: 'positive' -9.00, 'negative' -11.93 -- best:
	#              'positive'; empty before the first Classify
	#   see        Classify
	def Why()
		return @cWhy

	# _TokensOf() USED TO BE HERE and is deliberately gone. It built a stzText per
	# document to reach Words(), then lowercased each token -- about a third of the
	# training cost, and a second place where the tokenization rule lived. bayes.zig
	# walks the same UAX#29 iterator str_extract_words walks, so there is one
	# tokenizer rather than two that agree until one is touched.
