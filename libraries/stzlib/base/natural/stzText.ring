#--------------------------------------------------------------#
#      SOFTANZA LIBRARY (V1.2) - STZTEXT (TEXT DOMAIN)          #
#   An accelerative library for Ring applications, and more!    #
#--------------------------------------------------------------#
#                                                              #
#   Description  : stzText -- text as MEANING, the natural-       #
#                  language operations on text. (What others      #
#                  call "NLP" is just natural operations applied  #
#                  to text, so it lives in the natural/ domain.)  #
#                  In Softanza a "string" is raw characters; a    #
#                  "text" CARRIES MEANING: words, sentences,      #
#                  sentiment, entities, topics, semantics.        #
#                  stzText (from stzStringText) is where every    #
#                  such operation lives; stzString.Text() bridges #
#                  a string into this domain. All engine-backed.  #
#   Version      : V1.2 (2026)                                  #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)        #
#                                                              #
#--------------------------------------------------------------#

# StzText() / StzTextQ() globals live in string/stzStringFunc.ring.

class stzText from stzStringText

	# Inherits @oString + the STRUCTURAL text layer from stzStringText:
	# Words(), Sentences(), NumberOfWords/Sentences/Chars(), Content(), Engine(),
	# WordsAndTheirCounts(), MostFrequentWords(). This class adds the MEANING layer.

	  #==========================================================#
	 #   STEMMING (Snowball, 25 languages)                      #
	#==========================================================#
	# Reduce inflected words to their stem ("running"->"run"). Stemmed() defaults
	# to English; *InLanguage(cLang) selects one of the 25 Snowball languages.
	def StemmedInLanguage(pcLang)
		if NOT isString(pcLang) pcLang = "english" ok
		_pStem_ = StzEngineStringStemmed(This.Engine(), pcLang)
		_cStem_ = StzEngineStringData(_pStem_)
		StzEngineStringFree(_pStem_)
		return _cStem_

	def Stemmed()
		return This.StemmedInLanguage("english")

		def Stem()
			return This.Stemmed()

	def StemmedWordsInLanguage(pcLang)
		if NOT isString(pcLang) pcLang = "english" ok
		return StzEngineStringStemWordsList(This.Engine(), pcLang)

	def StemmedWords()
		return This.StemmedWordsInLanguage("english")

		def WordsStemmed()
			return This.StemmedWords()

	def SupportedStemmerLanguages()
		return [ "english", "arabic", "basque", "catalan", "danish",
			"dutch", "finnish", "french", "german", "greek", "hindi",
			"hungarian", "indonesian", "irish", "italian", "lithuanian",
			"nepali", "norwegian", "portuguese", "romanian", "russian",
			"spanish", "swedish", "tamil", "turkish" ]

	def SupportedLemmaLanguages()
		return [ "english", "french", "arabic" ]

	  #==========================================================#
	 #   WORDNET (synonyms + hypernyms)                         #
	#==========================================================#
	def Synonyms()
		return StzEngineStringSynonymsList(This.Engine())

		# Q-ladder: Q -> basic stzList; QQ -> stzListOfStrings (synonyms are
		# lexical WORDS, so no text rung).
		def SynonymsQ()
			return new stzList(This.Synonyms())

		def SynonymsQQ()
			return new stzListOfStrings(This.Synonyms())

	def Hypernyms()
		return StzEngineStringHypernymsList(This.Engine())

		def HypernymsQ()
			return new stzList(This.Hypernyms())

		def HypernymsQQ()
			return new stzListOfStrings(This.Hypernyms())

	def IsSynonymOf(pcOther)
		if NOT isString(pcOther) return FALSE ok
		return StzEngineStringAreSynonyms(This.Engine(), pcOther) = 1

	def HasSynonyms()
		return len(This.Synonyms()) > 0

	  #==========================================================#
	 #   LEMMATIZATION (dictionary form)                        #
	#==========================================================#
	def LemmatizedInLanguage(pcLang)
		if NOT isString(pcLang) pcLang = "english" ok
		_pLem_ = StzEngineStringLemmatized(This.Engine(), pcLang)
		_cLem_ = StzEngineStringData(_pLem_)
		StzEngineStringFree(_pLem_)
		return _cLem_

	def Lemmatized()
		return This.LemmatizedInLanguage("english")

		def Lemma()
			return This.Lemmatized()

	def LemmatizedWordsInLanguage(pcLang)
		if NOT isString(pcLang) pcLang = "english" ok
		return StzEngineStringLemmatizeWordsList(This.Engine(), pcLang)

	def LemmatizedWords()
		return This.LemmatizedWordsInLanguage("english")

		def WordsLemmatized()
			return This.LemmatizedWords()

	  #==========================================================#
	 #   SENTIMENT (VADER)                                      #
	#==========================================================#
	def SentimentScore()
		return StzEngineStringSentiment(This.Engine(), 0)

		def SentimentCompound()
			return This.SentimentScore()

	def Sentiment()
		_nScore_ = This.SentimentScore()
		if _nScore_ >= 0.05
			return "positive"
		but _nScore_ <= -0.05
			return "negative"
		else
			return "neutral"
		ok

	def PositiveScore()
		return StzEngineStringSentiment(This.Engine(), 1)

	def NegativeScore()
		return StzEngineStringSentiment(This.Engine(), 2)

	def NeutralScore()
		return StzEngineStringSentiment(This.Engine(), 3)

	def IsPositive()
		return This.SentimentScore() >= 0.05

	def IsNegative()
		return This.SentimentScore() <= -0.05

	def SentimentExplained()
		_nSeScore_ = This.SentimentScore()
		_cSeLabel_ = This.Sentiment()
		_aSeRaw_ = StzEngineStringSentimentExplainedList(This.Engine())
		_aSePos_ = []
		_aSeNeg_ = []
		_nSeN_ = len(_aSeRaw_)
		for _iSe_ = 1 to _nSeN_
			_aSePair_ = StzSplit(_aSeRaw_[_iSe_], char(1))
			if len(_aSePair_) = 2
				_nSeV_ = StzNumber(_aSePair_[2])
				if _nSeV_ > 0
					_aSePos_ + [ _aSePair_[1], _nSeV_ ]
				but _nSeV_ < 0
					_aSeNeg_ + [ _aSePair_[1], _nSeV_ ]
				ok
			ok
		next
		return [
			[ "overall", _cSeLabel_, _nSeScore_ ],
			[ "positive_words", _aSePos_ ],
			[ "negative_words", _aSeNeg_ ]
		]

	  #==========================================================#
	 #   PART-OF-SPEECH TAGGING (Penn Treebank)                 #
	#==========================================================#
	def POSTags()
		return StzEngineStringPosTagsList(This.Engine())

		def PartOfSpeechTags()
			return This.POSTags()

	def TaggedWords()
		_aTwWords_ = This.Words()
		_aTwTags_  = This.POSTags()
		_aTwOut_ = []
		_nTwN_ = len(_aTwWords_)
		if len(_aTwTags_) < _nTwN_ _nTwN_ = len(_aTwTags_) ok
		for _iTw_ = 1 to _nTwN_
			_aTwOut_ + [ _aTwWords_[_iTw_], _aTwTags_[_iTw_] ]
		next
		return _aTwOut_

		def WordsWithPOS()
			return This.TaggedWords()

	  #==========================================================#
	 #   NAMED-ENTITY RECOGNITION                               #
	#==========================================================#
	def NamedEntities()
		_aNeRaw_ = StzEngineStringNamedEntitiesList(This.Engine())
		_aNeOut_ = []
		_nNeN_ = len(_aNeRaw_)
		for _iNe_ = 1 to _nNeN_
			_aNePair_ = StzSplit(_aNeRaw_[_iNe_], char(1))
			if len(_aNePair_) = 2
				_aNeOut_ + [ _aNePair_[1], _aNePair_[2] ]
			ok
		next
		return _aNeOut_

		def Entities()
			return This.NamedEntities()

	def EntitiesOfType(pcType)
		_aEtAll_ = This.NamedEntities()
		_aEtOut_ = []
		_nEtN_ = len(_aEtAll_)
		for _iEt_ = 1 to _nEtN_
			if _aEtAll_[_iEt_][2] = pcType
				_aEtOut_ + _aEtAll_[_iEt_][1]
			ok
		next
		return _aEtOut_

	def PersonNames()
		return This.EntitiesOfType("PERSON")

	def Organizations()
		return This.EntitiesOfType("ORGANIZATION")

	def Locations()
		return This.EntitiesOfType("LOCATION")

	  #==========================================================#
	 #   STOPWORDS + READABILITY                                #
	#==========================================================#
	def ContentWords()
		return StzEngineStringContentWordsList(This.Engine())

		def Keywords()
			return This.ContentWords()

	def WithoutStopwords()
		_pWs_ = StzEngineStringWithoutStopwords(This.Engine())
		_cWs_ = StzEngineStringData(_pWs_)
		StzEngineStringFree(_pWs_)
		return _cWs_

	def IsStopword()
		return StzEngineStringIsStopword(This.Engine()) = 1

	def ReadingEase()
		return StzEngineStringReadability(This.Engine(), 0)

		def FleschReadingEase()
			return This.ReadingEase()

	def ReadabilityGrade()
		return StzEngineStringReadability(This.Engine(), 1)

		def FleschKincaidGrade()
			return This.ReadabilityGrade()

	def ReadabilityExplained()
		_nReWords_ = This.NumberOfWords()
		_nReSent_  = This.NumberOfSentences()
		_nReWps_ = 0
		if _nReSent_ > 0 _nReWps_ = _nReWords_ / _nReSent_ ok
		return [
			[ "words", _nReWords_ ],
			[ "sentences", _nReSent_ ],
			[ "words_per_sentence", _nReWps_ ],
			[ "reading_ease", This.ReadingEase() ],
			[ "grade_level", This.ReadabilityGrade() ]
		]

	  #==========================================================#
	 #   KEY-PHRASE EXTRACTION (RAKE)                           #
	#==========================================================#
	def KeyPhrasesXT(n)
		_aKpRaw_ = StzEngineStringKeyPhrasesList(This.Engine(), n)
		_aKpOut_ = []
		_nKpN_ = len(_aKpRaw_)
		for _iKp_ = 1 to _nKpN_
			_aKpPair_ = StzSplit(_aKpRaw_[_iKp_], char(1))
			if len(_aKpPair_) = 2
				_aKpOut_ + [ _aKpPair_[1], StzNumber(_aKpPair_[2]) ]
			ok
		next
		return _aKpOut_

	def KeyPhrases(n)
		_aKpL_ = This.KeyPhrasesXT(n)
		_aKpJust_ = []
		_nKpL_ = len(_aKpL_)
		for _iKpL_ = 1 to _nKpL_
			_aKpJust_ + _aKpL_[_iKpL_][1]
		next
		return _aKpJust_

		# Q-ladder: Q -> basic stzList; QQ -> stzListOfTexts (a key PHRASE is a
		# multi-word unit that carries meaning, i.e. a text).
		def KeyPhrasesQ(n)
			return new stzList(This.KeyPhrases(n))

		def KeyPhrasesQQ(n)
			return new stzListOfTexts(This.KeyPhrases(n))

	def TopKeyPhrase()
		_aTkp_ = This.KeyPhrases(1)
		if len(_aTkp_) = 0 return "" ok
		return _aTkp_[1]

	  #==========================================================#
	 #   TEXTRANK (graph keywords + extractive summary)         #
	#==========================================================#
	def RankedKeywordsXT(n)
		_aKwRaw_ = StzEngineStringTextRankKeywordsList(This.Engine(), n)
		_aKwOut_ = []
		_nKwN_ = len(_aKwRaw_)
		for _iKw_ = 1 to _nKwN_
			_aKwPair_ = StzSplit(_aKwRaw_[_iKw_], char(1))
			if len(_aKwPair_) = 2
				_aKwOut_ + [ _aKwPair_[1], StzNumber(_aKwPair_[2]) ]
			ok
		next
		return _aKwOut_

	def RankedKeywords(n)
		_aKwL_ = This.RankedKeywordsXT(n)
		_aKwJust_ = []
		_nKwL_ = len(_aKwL_)
		for _iKwL_ = 1 to _nKwL_
			_aKwJust_ + _aKwL_[_iKwL_][1]
		next
		return _aKwJust_

		# Q-ladder: Q -> basic stzList; QQ -> stzListOfStrings (keywords are
		# single lexical WORDS).
		def RankedKeywordsQ(n)
			return new stzList(This.RankedKeywords(n))

		def RankedKeywordsQQ(n)
			return new stzListOfStrings(This.RankedKeywords(n))

	def SummarySentences(n)
		# When a neural model is loaded, rank sentences by EMBEDDING similarity
		# (TextRank over a cosine graph) -- semantically stronger than the engine's
		# word-overlap TextRank. Else fall back to the engine.
		if This.HasSemanticModel()
			return This._EmbeddingSummarySentences(n)
		ok
		return StzEngineStringSummarizeList(This.Engine(), n)

		# Q-ladder: Q -> basic stzList; QQ -> stzListOfTexts (summary SENTENCES
		# carry meaning).
		def SummarySentencesQ(n)
			return new stzList(This.SummarySentences(n))

		def SummarySentencesQQ(n)
			return new stzListOfTexts(This.SummarySentences(n))

	# Embedding-based extractive summary: embed each sentence, build a cosine
	# similarity graph, rank by TextRank (PageRank), return the top-n sentences in
	# ORIGINAL document order.
	def _EmbeddingSummarySentences(n)
		_aSsAll_ = This.Sentences()
		_nSsN_ = len(_aSsAll_)
		if _nSsN_ = 0 return [] ok
		if n <= 0 n = 1 ok
		if n >= _nSsN_ return _aSsAll_ ok

		_aSsEmb_ = []
		for _iSs_ = 1 to _nSsN_
			_oSsT_ = new stzText(_aSsAll_[_iSs_])
			_aSsEmb_ + _oSsT_.Embedding()
		next

		_aSsScore_ = This._TextRankScores(_aSsEmb_)
		_aSsIdx_ = This._TopNIndices(_aSsScore_, n)

		_aSsOut_ = []
		for _iSs_ = 1 to _nSsN_
			if StzContains(_aSsIdx_, _iSs_)
				_aSsOut_ + _aSsAll_[_iSs_]
			ok
		next
		return _aSsOut_

	# PageRank (damping 0.85, 40 iters) over the sentence cosine graph. Vectors
	# are L2-normalized so cosine = dot; negative cosines clamp to 0.
	def _TextRankScores(paEmb)
		_nTrN_ = len(paEmb)
		if _nTrN_ = 0 return [] ok

		_aTrW_ = []
		_aTrRowSum_ = []
		for _iTr_ = 1 to _nTrN_
			_aTrRow_ = []
			_nTrSum_ = 0
			for _jTr_ = 1 to _nTrN_
				if _iTr_ = _jTr_
					_aTrRow_ + 0
				else
					_nTrC_ = This._EmbeddingDot(paEmb[_iTr_], paEmb[_jTr_])
					if _nTrC_ < 0 _nTrC_ = 0 ok
					_aTrRow_ + _nTrC_
					_nTrSum_ += _nTrC_
				ok
			next
			_aTrW_ + _aTrRow_
			_aTrRowSum_ + _nTrSum_
		next

		_nTrD_ = 0.85
		_aTrScore_ = []
		for _iTr_ = 1 to _nTrN_ _aTrScore_ + (1.0 / _nTrN_) next
		for _kTr_ = 1 to 40
			_aTrNew_ = []
			for _iTr_ = 1 to _nTrN_
				_nTrAcc_ = 0
				for _jTr_ = 1 to _nTrN_
					if _jTr_ != _iTr_ and _aTrRowSum_[_jTr_] > 0
						_nTrAcc_ += ( _aTrW_[_jTr_][_iTr_] / _aTrRowSum_[_jTr_] ) * _aTrScore_[_jTr_]
					ok
				next
				_aTrNew_ + ( (1 - _nTrD_) / _nTrN_ + _nTrD_ * _nTrAcc_ )
			next
			_aTrScore_ = _aTrNew_
		next
		return _aTrScore_

	# Indices (1-based) of the n highest scores; ties broken by earlier index.
	def _TopNIndices(paScore, n)
		_nTnN_ = len(paScore)
		_aTnChosen_ = []
		for _cTn_ = 1 to n
			_nTnBest_ = -1
			_nTnBestIx_ = 0
			for _iTn_ = 1 to _nTnN_
				if NOT StzContains(_aTnChosen_, _iTn_) and paScore[_iTn_] > _nTnBest_
					_nTnBest_ = paScore[_iTn_]
					_nTnBestIx_ = _iTn_
				ok
			next
			if _nTnBestIx_ > 0 _aTnChosen_ + _nTnBestIx_ ok
		next
		return _aTnChosen_

	def SummarizedIn(n)
		_oSmz_ = new stzListOfStrings(This.SummarySentences(n))
		return _oSmz_.JoinedUsing(" ")

		def Summary(n)
			return This.SummarizedIn(n)

	  #==========================================================#
	 #   POS-AWARE WORD FILTERS                                 #
	#==========================================================#
	def WordsThatAre(pcPenn)
		if NOT isString(pcPenn) return [] ok
		_aWtWords_ = This.Words()
		_aWtTags_  = This.POSTags()
		_aWtOut_ = []
		_nWtN_ = len(_aWtWords_)
		if len(_aWtTags_) < _nWtN_ _nWtN_ = len(_aWtTags_) ok
		for _iWt_ = 1 to _nWtN_
			if StzStartsWith(_aWtTags_[_iWt_], pcPenn)
				_aWtOut_ + _aWtWords_[_iWt_]
			ok
		next
		return _aWtOut_

		def WordsThatAreQ(pcPenn)
			return new stzList(This.WordsThatAre(pcPenn))

	def Nouns()
		return This.WordsThatAre("NN")

		def NounsQ()
			return new stzList(This.Nouns())

	def ProperNouns()
		return This.WordsThatAre("NNP")

	def Verbs()
		return This.WordsThatAre("VB")

		def VerbsQ()
			return new stzList(This.Verbs())

	def Adjectives()
		return This.WordsThatAre("JJ")

		def AdjectivesQ()
			return new stzList(This.Adjectives())

	def Adverbs()
		return This.WordsThatAre("RB")

	def Pronouns()
		return This.WordsThatAre("PRP")

	  #==========================================================#
	 #   SENTENCE FILTERS (sentiment / similarity)              #
	#==========================================================#
	# Q-ladder (called on a stzText): Q -> basic stzList; QQ -> stzListOfTexts
	# IMMEDIATELY -- in the text layer there is no "string" rung above, a sentence
	# of a text IS a text. So the natural ops chain via SentencesQQ():
	# Q(str).TextQ().SentencesQQ().ThatAre(:Positive) / .MostSimilarByMeaning(query).
	# (On a stzString the ladder is stzList -> stzListOfStrings -> stzListOfTexts.)
	def SentencesQ()
		return new stzList(This.Sentences())

	def SentencesQQ()
		return new stzListOfTexts(This.Sentences())

	# Words are LEXICAL even inside a text -> QQ stops at stzListOfStrings.
	def WordsQQ()
		return new stzListOfStrings(This.Words())

	def SentencesThatAre(pcPolarity)
		if NOT isString(pcPolarity) return [] ok
		_cStWant_ = StzLower(pcPolarity)
		_aStAll_ = This.Sentences()
		_aStOut_ = []
		_nStN_ = len(_aStAll_)
		for _iSt_ = 1 to _nStN_
			_oStS_ = new stzText(_aStAll_[_iSt_])
			if _oStS_.Sentiment() = _cStWant_
				_aStOut_ + _aStAll_[_iSt_]
			ok
		next
		return _aStOut_

	def PositiveSentences()
		return This.SentencesThatAre("positive")

	def NegativeSentences()
		return This.SentencesThatAre("negative")

	def _BestSentenceBy(nSign)
		_aBsAll_ = This.Sentences()
		_nBsN_ = len(_aBsAll_)
		if _nBsN_ = 0 return "" ok
		_cBsBest_ = _aBsAll_[1]
		_oBs1_ = new stzText(_cBsBest_)
		_nBsBest_ = _oBs1_.SentimentScore() * nSign
		for _iBs_ = 2 to _nBsN_
			_oBs_ = new stzText(_aBsAll_[_iBs_])
			_nBsS_ = _oBs_.SentimentScore() * nSign
			if _nBsS_ > _nBsBest_
				_nBsBest_ = _nBsS_
				_cBsBest_ = _aBsAll_[_iBs_]
			ok
		next
		return _cBsBest_

	def MostPositiveSentence()
		return This._BestSentenceBy(1)

	def MostNegativeSentence()
		return This._BestSentenceBy(-1)

	def MostSimilarSentenceTo(pcQuery)
		if NOT isString(pcQuery) return "" ok
		_aMsAll_ = This.Sentences()
		_nMsN_ = len(_aMsAll_)
		if _nMsN_ = 0 return "" ok

		# Prefer semantic (embedding) ranking when a neural model is loaded;
		# otherwise fall back to lexical bag-of-words cosine. When semantic, the
		# query is embedded once and each sentence compared by dot product.
		_bMsSem_ = This.HasSemanticModel()
		_aMsQEmb_ = []
		if _bMsSem_
			_oMsQ_ = new stzText(pcQuery)
			_aMsQEmb_ = _oMsQ_.Embedding()
			if len(_aMsQEmb_) = 0 _bMsSem_ = FALSE ok
		ok

		_cMsBest_ = ""
		_nMsBest_ = -2
		for _iMs_ = 1 to _nMsN_
			if _bMsSem_
				_oMsS_ = new stzText(_aMsAll_[_iMs_])
				_nMsSim_ = This._EmbeddingDot(_oMsS_.Embedding(), _aMsQEmb_)
			else
				_oMs_ = new stzString(_aMsAll_[_iMs_])
				_nMsSim_ = _oMs_.CosineSimilarityWith(pcQuery)
			ok
			if _nMsSim_ > _nMsBest_
				_nMsBest_ = _nMsSim_
				_cMsBest_ = _aMsAll_[_iMs_]
			ok
		next
		return _cMsBest_

		def MostSemanticallySimilarSentenceTo(pcQuery)
			return This.MostSimilarSentenceTo(pcQuery)

	  #==========================================================#
	 #   SEMANTIC LAYER (neural embeddings)                     #
	#==========================================================#
	# Upgrades text similarity from lexical bag-of-words to true MEANING via a
	# runtime neural model (load one process-wide with StzUseNeuralModel(path)).
	# With no model loaded these degrade gracefully to the lexical path, so code
	# keeps working and auto-improves once a model is present.

	# TRUE if a runtime embedding model is loaded and ready.
	def HasSemanticModel()
		return StzHasNeuralModel()

		def IsSemanticModelReady()
			return This.HasSemanticModel()

	# Embedding() -- this text's sentence-embedding vector (list of floats) via
	# the loaded model; [] if none is loaded (DATA, per Softanza's Q rule).
	def Embedding()
		if NOT This.HasSemanticModel() return [] ok
		return _StzEmbedInto(This.Content())

		def EmbeddingVector()
			return This.Embedding()

	def EmbeddingQ()
		return new stzList(This.Embedding())

	# SemanticSimilarityWith(other) -- cosine of the two texts' embeddings in
	# [-1, 1]; falls back to lexical cosine when no model is loaded (DATA).
	def SemanticSimilarityWith(pcOther)
		if NOT isString(pcOther) return 0 ok
		return StzSemanticSimilarity(This.Content(), pcOther)

		def SemanticSimilarityTo(pcOther)
			return This.SemanticSimilarityWith(pcOther)

	# IsSemanticallySimilarTo(other, threshold) -- TRUE if the meaning-similarity
	# meets the threshold (default 0.5).
	def IsSemanticallySimilarTo(pcOther, pnThreshold)
		if NOT isNumber(pnThreshold) pnThreshold = 0.5 ok
		return This.SemanticSimilarityWith(pcOther) >= pnThreshold

	# Dot product of two equal-length vectors (0 if empty/mismatched). Private
	# helper for embedding cosine (vectors arrive L2-normalized).
	def _EmbeddingDot(paA, paB)
		if NOT (isList(paA) and isList(paB)) return 0 ok
		_nEdN_ = len(paA)
		if _nEdN_ = 0 or len(paB) != _nEdN_ return 0 ok
		_nEdDot_ = 0
		for _iEd_ = 1 to _nEdN_
			_nEdDot_ += paA[_iEd_] * paB[_iEd_]
		next
		return _nEdDot_

	  #==========================================================#
	 #   LANGUAGE DETECTION                                     #
	#==========================================================#
	def Language()
		_pLg_ = StzEngineStringDetectLanguage(This.Engine())
		_cLg_ = StzEngineStringData(_pLg_)
		StzEngineStringFree(_pLg_)
		return _cLg_

		def DetectedLanguage()
			return This.Language()

	def AutoLemmatized()
		_cAlLg_ = This.Language()
		if _cAlLg_ = "unknown" _cAlLg_ = "english" ok
		return This.LemmatizedInLanguage(_cAlLg_)

	def AutoStemmed()
		_cAsLg_ = This.Language()
		if _cAsLg_ = "unknown" _cAsLg_ = "english" ok
		return This.StemmedInLanguage(_cAsLg_)

	  #==========================================================#
	 #   PROFILE + STYLOMETRY                                   #
	#==========================================================#
	def Profile()
		_oPfNoStop_ = new stzString(This.WithoutStopwords())
		_aPfTop_ = _oPfNoStop_.MostFrequentWords(5)
		_aPfKw_ = []
		_nPfT_ = len(_aPfTop_)
		for _iPf_ = 1 to _nPfT_
			_aPfKw_ + _aPfTop_[_iPf_][1]
		next
		return [
			[ "language", This.Language() ],
			[ "words", This.NumberOfWords() ],
			[ "sentences", This.NumberOfSentences() ],
			[ "reading_grade", This.ReadabilityGrade() ],
			[ "sentiment", This.Sentiment() ],
			[ "lexical_diversity", This.LexicalDiversity() ],
			[ "top_keywords", _aPfKw_ ],
			[ "entities", This.NamedEntities() ]
		]

	def LexicalDiversity()
		_nLdTotal_ = This.NumberOfWords()
		if _nLdTotal_ = 0 return 0 ok
		_oLdLow_ = new stzString(@oString.Lowercased())
		_aLdUniq_ = _oLdLow_.WordsAndTheirCounts()
		return len(_aLdUniq_) / _nLdTotal_

		def TypeTokenRatio()
			return This.LexicalDiversity()

	def StyleProfile()
		_aSpWords_ = This.Words()
		_nSpWords_ = len(_aSpWords_)
		_nSpChars_ = 0
		for _iSp_ = 1 to _nSpWords_
			_nSpChars_ += StzLen(_aSpWords_[_iSp_])
		next
		_nSpAvgLen_ = 0
		if _nSpWords_ > 0 _nSpAvgLen_ = _nSpChars_ / _nSpWords_ ok
		return [
			[ "avg_word_length", _nSpAvgLen_ ],
			[ "avg_words_per_sentence", @oString.AverageWordsPerSentence() ],
			[ "lexical_diversity", This.LexicalDiversity() ]
		]

	  #==========================================================#
	 #   CONCORDANCE + COMPARISON                               #
	#==========================================================#
	def InContextWithWindow(pcWord, nWindow)
		if NOT isString(pcWord) return [] ok
		_aIcWords_ = This.Words()
		_cIcTarget_ = StzLower(pcWord)
		_aIcOut_ = []
		_nIcN_ = len(_aIcWords_)
		for _iIc_ = 1 to _nIcN_
			if StzLower(_aIcWords_[_iIc_]) = _cIcTarget_
				_nIcA_ = _iIc_ - nWindow
				if _nIcA_ < 1 _nIcA_ = 1 ok
				_nIcB_ = _iIc_ + nWindow
				if _nIcB_ > _nIcN_ _nIcB_ = _nIcN_ ok
				_cIcLine_ = ""
				for _jIc_ = _nIcA_ to _nIcB_
					_cIcLine_ += _aIcWords_[_jIc_]
					if _jIc_ < _nIcB_ _cIcLine_ += " " ok
				next
				_aIcOut_ + _cIcLine_
			ok
		next
		return _aIcOut_

	def InContext(pcWord)
		return This.InContextWithWindow(pcWord, 5)

		def Concordance(pcWord)
			return This.InContext(pcWord)

	def ComparedTo(pcOther)
		if NOT isString(pcOther) return [] ok
		_oCmOther_ = new stzText(pcOther)
		# Semantic similarity when a neural model is loaded, else lexical cosine.
		_nCmSim_   = StzSemanticSimilarity(This.Content(), pcOther)
		_nCmSentA_ = This.SentimentScore()
		_nCmSentB_ = _oCmOther_.SentimentScore()
		_nCmGrA_   = This.ReadabilityGrade()
		_nCmGrB_   = _oCmOther_.ReadabilityGrade()

		_aCmA_ = StzListOfStringsQ(This.ContentWords()).Lowercased()
		_aCmB_ = StzListOfStringsQ(_oCmOther_.ContentWords()).Lowercased()
		_aCmShared_ = []
		_nCmA_ = len(_aCmA_)
		for _iCm_ = 1 to _nCmA_
			_cCmW_ = _aCmA_[_iCm_]
			if StzContains(_aCmB_, _cCmW_) and NOT StzContains(_aCmShared_, _cCmW_)
				_aCmShared_ + _cCmW_
			ok
		next
		return [
			[ "similarity", _nCmSim_ ],
			[ "sentiment_delta", _nCmSentA_ - _nCmSentB_ ],
			[ "grade_delta", _nCmGrA_ - _nCmGrB_ ],
			[ "shared_keywords", _aCmShared_ ]
		]

	  #==========================================================#
	 #   ANNOTATED DISPLAY                                      #
	#==========================================================#
	def ShowTagged()
		_aShTw_ = This.TaggedWords()
		_cShOut_ = ""
		_nShN_ = len(_aShTw_)
		for _iSh_ = 1 to _nShN_
			_cShOut_ += _aShTw_[_iSh_][1] + "/" + _aShTw_[_iSh_][2]
			if _iSh_ < _nShN_ _cShOut_ += " " ok
		next
		? _cShOut_
		return This

	def ShowEntities()
		_aSeeNe_ = This.NamedEntities()
		_cSeeOut_ = This.Content()
		_nSeeN_ = len(_aSeeNe_)
		for _iSee_ = 1 to _nSeeN_
			_cSeeEnt_ = _aSeeNe_[_iSee_][1]
			_cSeeTy_  = _aSeeNe_[_iSee_][2]
			_cSeeOut_ = StzReplace(_cSeeOut_, _cSeeEnt_, "[" + _cSeeEnt_ + ":" + _cSeeTy_ + "]")
		next
		? _cSeeOut_
		return This

	def ShowSentiment()
		_aSsSt_ = This.Sentences()
		_nSsN_ = len(_aSsSt_)
		for _iSs_ = 1 to _nSsN_
			_oSsS_ = new stzText(_aSsSt_[_iSs_])
			? "(" + _oSsS_.Sentiment() + " " + _oSsS_.SentimentScore() + ") " + _aSsSt_[_iSs_]
		next
		return This
