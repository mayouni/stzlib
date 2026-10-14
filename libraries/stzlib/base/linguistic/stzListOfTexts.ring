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

func StzListOfTextsQ(paList)
	return new stzListOfTexts(paList)

# Holds a list of sentences or documents and selects among them by meaning: closest to a query, ranked for a query, or by sentiment.
#
# A list of texts is a list of strings that carries meaning, so it inherits everything of
# stzStringList (Content, NthString, Joined, ThatContain, Longest) and adds the natural layer. Build
# one with new stzListOfTexts(aList) or StzListOfTextsQ(aList); the sentence splitters of stzText
# answer a plain stzList, so wrap their result. Without a neural model the meaning methods fall back
# to word overlap, and the sentiment scorer reads English only; a model loaded through
# StzNeuralModelQ upgrades the similarity and ranking.
#
#   receiver   o1 = new stzListOfTexts([ "The cat sat on the mat.", "I love this wonderful sunny
#              day!", "This is terrible and I hate it." ])
#   example    ? o1.MostSimilarByMeaning("a cat on a mat")
#              #--> The cat sat on the mat.
#              ? @@( o1.ThatAre("positive") )
#              #--> [ "I love this wonderful sunny day!" ]
#              ? o1.MostRelevantTo("wonderful day")
#              #--> I love this wonderful sunny day!
#   see        stzStringList, stzText, stzListOfStrings
class stzListOfTexts from stzStringList

	  #==========================================================#
	 #   MEANING-BASED SELECTION (natural processing)          #
	#==========================================================#
	# Returns the text of the list closest in meaning to a query: by neural sentence embeddings when a model is loaded, else by shared words.
	#
	#   pcQuery    the sentence or phrase to compare with
	#   returns    a text; "" when the list is empty or the query is not a text
	#   note       the word-overlap fallback knows nothing of synonyms: "a cat on a mat" finds the
	#              cat sentence and "feline" would not; ties go to the earlier text
	#   see        MostRelevantTo, RankedForQuery
	#@ aka  These are what make a list of TEXTS more than a list of strings. They read the MEANING of each fragment (semantic similarity, sentiment), so a fluent chain like Q(text).SentencesQ().MostSimilarByMeaning(query) / .ThatAre( :Positive) works. Semantic ops upgrade to neural embeddings when a model is loaded (StzNeuralModelQ(path)), else degrade to lexical -- see StzSemanticSimilarity().
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

	# Returns the texts of the list whose sentiment is the given polarity.
	#
	#   pcPolarity   the sentiment label to keep: "positive", "negative" or "neutral", in any case
	#   returns      a list of texts, in their order; [ ] when none match or the polarity is not a
	#                text
	#   warning      the sentiment scorer is English (VADER): clearly positive French, Arabic and
	#                German sentences all come out neutral, so ThatAre("positive") finds none of
	#                them
	#   see          MostSimilarByMeaning
	#@ aka  The texts whose sentiment label matches "positive"/"negative"/"neutral".
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

	  #==========================================================#
	 #   CROSS-ENCODER RERANKING                               #
	#==========================================================#
	# Returns every text with its relevance score to a query, the most relevant first.
	#
	#   pcQuery    the question or keywords the texts are ranked for
	#   returns    a list of [ text, score ] pairs; [ ] for an empty list
	#   note       a cross-encoder is used when a reranker model is loaded, else lexical similarity,
	#              where texts sharing no word with the query all score 0
	#   see        MostRelevantTo, MostSimilarByMeaning
	#@ aka  Rank these texts (candidate documents) by relevance to a query. Uses a CROSS-ENCODER (joint query+doc scoring) when a reranker GGUF is loaded (StzUseNeuralModel with e.g. jina-reranker), else bi-encoder/lexical similarity. The accurate second stage of retrieve-then-rerank.
	def RankedForQuery(pcQuery)
		return StzRerank(pcQuery, @acContent)

		# Q-ladder: Q -> stzList; QQ -> stzListOfPairs.
		def RankedForQueryQ(pcQuery)
			return new stzList(This.RankedForQuery(pcQuery))

		def RankedForQueryQQ(pcQuery)
			return new stzListOfPairs(This.RankedForQuery(pcQuery))

	# Returns the single text of the list best ranked for a query.
	#
	#   pcQuery    the question or keywords to rank for
	#   returns    a text; "" when the list is empty
	#   see        RankedForQuery
	#@ aka  The single most relevant text to the query (DATA, a string).
	def MostRelevantTo(pcQuery)
		_aMrR_ = This.RankedForQuery(pcQuery)
		if len(_aMrR_) = 0 return "" ok
		return _aMrR_[1][1]

	# Returns an independent copy of the list that is still a list of texts, so its meaning methods stay available.
	#
	#   returns    a new stzListOfTexts
	#@ aka  A copy stays a list of TEXTS (override the base, which returns stzStringList).
	def Copy()
		return new stzListOfTexts(@acContent)
