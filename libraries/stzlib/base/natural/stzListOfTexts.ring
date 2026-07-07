#--------------------------------------------------------------#
#      SOFTANZA LIBRARY (V1.2) - STZLISTOFTEXTS                 #
#   An accelerative library for Ring applications, and more!    #
#--------------------------------------------------------------#
#                                                              #
#   Description  : stzListOfTexts -- a list of TEXTS, i.e. of     #
#                  fragments that CARRY MEANING (sentences,       #
#                  paragraphs, documents). Where stzListOfStrings  #
#                  offers the usual LEXICAL string-list ops that   #
#                  any standard library has, stzListOfTexts adds   #
#                  the NATURAL (meaning) processing ops: rank by   #
#                  semantic similarity, filter by sentiment, ...   #
#                  In Softanza a "string" is just characters; a    #
#                  "text" is a string elevated to MEANING -- so    #
#                  these NLP list ops belong here, NOT on          #
#                  stzListOfStrings. (A list of sentences is a     #
#                  stzListOfTexts; a list of words stays a         #
#                  stzListOfStrings -- lexical, not semantic.)     #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)        #
#                                                              #
#--------------------------------------------------------------#

func StzListOfTexts(paList)
	return new stzListOfTexts(paList)

func StzListOfTextsQ(paList)
	return new stzListOfTexts(paList)

# A list of texts IS a list of strings PLUS meaning ops, so it extends
# stzStringList -- inheriting Content/NthString/Joined/ThatContain/Longest/
# MostSimilarTo (Jaro-Winkler) etc. -- and adds the natural layer below.
class stzListOfTexts from stzStringList

	  #==========================================================#
	 #   MEANING-BASED SELECTION (natural processing)          #
	#==========================================================#
	# These are what make a list of TEXTS more than a list of strings. They read
	# the MEANING of each fragment (semantic similarity, sentiment), so a fluent
	# chain like Q(text).SentencesQ().MostSimilarByMeaning(query) / .ThatAre(
	# :Positive) works. Semantic ops upgrade to neural embeddings when a model is
	# loaded (StzUseNeuralModel(path)), else degrade to lexical -- see
	# StzSemanticSimilarity().

	# The text most similar to pcQuery by MEANING. Uses the loaded neural model's
	# sentence embeddings when one is present, else lexical WORD-OVERLAP cosine --
	# the right notion for sentences/documents. (The inherited MostSimilarTo() uses
	# Jaro-Winkler CHARACTER similarity, better for fuzzy word/typo matching.)
	def MostSimilarByMeaning(pcQuery)
		if NOT isString(pcQuery) return "" ok
		_nMsN_ = len(@acContent)
		if _nMsN_ = 0 return "" ok
		_cMsBest_ = ""
		_nMsBest_ = -2
		for _iMs_ = 1 to _nMsN_
			_nMsSim_ = StzSemanticSimilarity(@acContent[_iMs_], pcQuery)
			if _nMsSim_ > _nMsBest_
				_nMsBest_ = _nMsSim_
				_cMsBest_ = @acContent[_iMs_]
			ok
		next
		return _cMsBest_

		def MostSimilarByMeaningQ(pcQuery)
			return new stzText(This.MostSimilarByMeaning(pcQuery))

	# The texts whose sentiment label matches "positive"/"negative"/"neutral".
	def ThatAre(pcPolarity)
		if NOT isString(pcPolarity) return [] ok
		_cTaWant_ = StzLower(pcPolarity)
		_aTaOut_ = []
		_nTaN_ = len(@acContent)
		for _iTa_ = 1 to _nTaN_
			_oTa_ = new stzText(@acContent[_iTa_])
			if _oTa_.Sentiment() = _cTaWant_
				_aTaOut_ + @acContent[_iTa_]
			ok
		next
		return _aTaOut_

		def ThatAreQ(pcPolarity)
			return new stzListOfTexts(This.ThatAre(pcPolarity))

	# A copy stays a list of TEXTS (override the base, which returns stzStringList).
	def Copy()
		return new stzListOfTexts(@acContent)
