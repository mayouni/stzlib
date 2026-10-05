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

# Holds a text as meaning rather than characters and answers natural-language questions about it: stems, tags, entities, tone, keywords, summaries, readability.
#
# A stzString is raw characters; a stzText carries meaning. It builds on stzStringText, which
# already gives Words, Sentences, the counts and the content, and adds the meaning layer, all
# computed by the engine: Snowball stemming in 25 languages and lemmatization in three, WordNet
# synonyms and hypernyms, VADER sentiment, Penn Treebank part-of-speech tags with chunking and a
# nested parse tree, rule-based named entities, stopwords and Flesch readability, RAKE key phrases,
# TextRank keywords and summaries, and language detection. Two groups upgrade themselves when a
# model is loaded for the process: the semantic group (Embedding, SemanticSimilarityWith, Classify,
# MostSimilarSentenceTo, NamedEntities) uses embeddings and a transformer NER head, and the
# generative pair (SummarizedAbstractively, AnswerAbout) asks a language model. With no model loaded
# they fall back to word overlap or answer an empty value, so a call never needs a model to run,
# with one exception noted on SummarizedAbstractively. The word-list methods work on one word or one
# sentence at a time and are only as good as the rule-based tagger. Known gaps today, each carried
# as a warning on its method: SummarizedAbstractively raises error R19 without a model,
# NamedEntities merges a capitalized word after a full stop into the previous entity, and
# EntityTypeOf and ClassifiedAs pick the first candidate on a tie.
#
#   receiver   o1 = new stzText("The food was terrible. I love this wonderful place.")
#   example    ? o1.Sentiment()
#              #--> "positive"
#              ? @@( o1.Nouns() )
#              #--> [ "food", "place" ]
#   see        stzString, stzStringText, stzListOfTexts
class stzText from stzStringText

	# Inherits @oString + the STRUCTURAL text layer from stzStringText:
	# Words(), Sentences(), NumberOfWords/Sentences/Chars(), Content(), Engine(),
	# WordsAndTheirCounts(), MostFrequentWords(). This class adds the MEANING layer.

	  #==========================================================#
	 #   STEMMING (Snowball, 25 languages)                      #
	#==========================================================#
	# Returns the text with every word cut to its Snowball stem in a given language; an unknown language gives English stems.
	#
	#   returns    text, such as "run dog were jump happili over better fenc."
	#   note       A stem need not be a real word, and punctuation stays; an argument that is not
	#              text gives English stems
	#   see        Stemmed, StemmedWordsInLanguage, SupportedStemmerLanguages
	#@ aka  Reduce inflected words to their stem ("running"->"run"). Stemmed() defaults to English; *InLanguage(cLang) selects one of the 25 Snowball languages.
	def StemmedInLanguage(pcLang)
		if NOT isString(pcLang) pcLang = "english" ok
		_pStem_ = StzEngineStringStemmed(This.Engine(), pcLang)
		_cStem_ = StzEngineStringData(_pStem_)
		StzEngineStringFree(_pStem_)
		return _cStem_

	# Returns the text with every word cut to its English stem, so running becomes run.
	#
	#   returns    text, such as "run dog were jump happili over better fenc."
	#   note       Stem is the same method; stems like happili are not words, which is what
	#              separates this from the dictionary form
	#   see        StemmedInLanguage, StemmedWords, Lemmatized
	#@ aka  The text with every word reduced to its root/stem ("running" -> "run").
	def Stemmed()
		return This.StemmedInLanguage("english")

		def Stem()
			return This.Stemmed()

	# Returns the stem of each word, as a list, in a given language; an unknown language gives English stems.
	#
	#   returns    a list of text, one stem per word
	#   note       A text that is not in the language gets stems that are barely changed
	#   see        StemmedWords, StemmedInLanguage
	def StemmedWordsInLanguage(pcLang)
		if NOT isString(pcLang) pcLang = "english" ok
		return StzEngineStringStemWordsList(This.Engine(), pcLang)

	# Returns the English stem of each word, as a list.
	#
	#   returns    a list of text, one stem per word
	#   note       WordsStemmed is the same method
	#   see        StemmedWordsInLanguage, Stemmed
	def StemmedWords()
		return This.StemmedWordsInLanguage("english")

		def WordsStemmed()
			return This.StemmedWords()

	# Returns the names of the 25 languages that have a Snowball stemmer.
	#
	#   returns    a list of 25 text values, english first
	#   see        StemmedInLanguage
	def SupportedStemmerLanguages()
		return [ "english", "arabic", "basque", "catalan", "danish",
			"dutch", "finnish", "french", "german", "greek", "hindi",
			"hungarian", "indonesian", "irish", "italian", "lithuanian",
			"nepali", "norwegian", "portuguese", "romanian", "russian",
			"spanish", "swedish", "tamil", "turkish" ]

	# Returns the names of the languages that have a dictionary-form reducer: english, french and arabic.
	#
	#   returns    a list of 3 text values
	#   see        LemmatizedInLanguage
	def SupportedLemmaLanguages()
		return [ "english", "french", "arabic" ]

	  #==========================================================#
	 #   WORDNET (synonyms + hypernyms)                         #
	#==========================================================#
	# Returns the WordNet words of the same meaning, all senses mixed, for a text that is one word; [ ] for a phrase or an unknown word.
	#
	#   returns    a list of text
	#   note       The text is looked up as a whole, so only a single word answers; for dog the list
	#              holds hound, frankfurter and andiron together, because every sense counts.
	#              SynonymsQ and SynonymsQQ give the list as an object
	#   see        Hypernyms, IsSynonymOf, HasSynonyms
	#@ aka  Words with the same or a similar meaning (synonyms, from WordNet).
	def Synonyms()
		return StzEngineStringSynonymsList(This.Engine())

		# Q-ladder: Q -> basic stzList; QQ -> stzListOfStrings (synonyms are
		# lexical WORDS, so no text rung).
		def SynonymsQ()
			return new stzList(This.Synonyms())

		def SynonymsQQ()
			return new stzListOfStrings(This.Synonyms())

	# Returns the broader WordNet terms, all senses mixed, for a text that is one word; [ ] for an unknown word or one without a parent.
	#
	#   returns    a list of text
	#   note       For dog the list holds canine and domestic animal but also fellow and villain,
	#              because every sense counts
	#   see        Synonyms
	#@ aka  More general "is-a" parent words for the term (dog -> animal), from WordNet.
	def Hypernyms()
		return StzEngineStringHypernymsList(This.Engine())

		def HypernymsQ()
			return new stzList(This.Hypernyms())

		def HypernymsQQ()
			return new stzListOfStrings(This.Hypernyms())

	# TRUE if WordNet lists the other word as meaning the same as the text, ignoring case; a word is never its own synonym.
	#
	#   returns    TRUE or FALSE; FALSE when the argument is not text
	#   note       The text must be a single word, as with the lookup itself
	#   see        Synonyms, HasSynonyms
	def IsSynonymOf(pcOther)
		if NOT isString(pcOther) return 0 ok
		return StzEngineStringAreSynonyms(This.Engine(), pcOther) = 1

	# TRUE if WordNet knows at least one word of the same meaning.
	#
	#   returns    TRUE or FALSE
	#   see        Synonyms, IsSynonymOf
	def HasSynonyms()
		return len(This.Synonyms()) > 0

	  #==========================================================#
	 #   LEMMATIZATION (dictionary form)                        #
	#==========================================================#
	# Returns the text with every word reduced to its dictionary form in english, french or arabic; another language gives English.
	#
	#   returns    text, such as "le cheval manger un pommer rouge" for French "les chevaux
	#              mangeaient des pommes rouges"
	#   note       An argument that is not text gives English
	#   see        Lemmatized, AutoLemmatized, SupportedLemmaLanguages
	#@ aka  The text lemmatized in the given language.
	def LemmatizedInLanguage(pcLang)
		if NOT isString(pcLang) pcLang = "english" ok
		_pLem_ = StzEngineStringLemmatized(This.Engine(), pcLang)
		_cLem_ = StzEngineStringData(_pLem_)
		StzEngineStringFree(_pLem_)
		return _cLem_

	# Returns the text with every word reduced to its English dictionary form, so were becomes be and fences becomes fence.
	#
	#   returns    text, such as "run dog be jump happily over well fence."
	#   note       Lemma is the same method; unlike stemming the result is made of real words, but
	#              better can come out as well
	#   see        LemmatizedInLanguage, Stemmed, AutoLemmatized
	#@ aka  base form, dictionary form, root word, canonical form, normalize words
	#@ see  Stemmed, AutoLemmatized
	#@ aka  The text with every word reduced to its dictionary base form / lemma ("better" -> "good", "ran" -> "run"). Smarter than stemming.
	def Lemmatized()
		return This.LemmatizedInLanguage("english")

		def Lemma()
			return This.Lemmatized()

	# Returns the dictionary form of each word, as a list, in english, french or arabic; another language gives English.
	#
	#   returns    a list of text, one form per word
	#   see        LemmatizedWords, LemmatizedInLanguage
	#@ aka  The lemma of each word, in the given language.
	def LemmatizedWordsInLanguage(pcLang)
		if NOT isString(pcLang) pcLang = "english" ok
		return StzEngineStringLemmatizeWordsList(This.Engine(), pcLang)

	# Returns the English dictionary form of each word, as a list.
	#
	#   returns    a list of text, one form per word
	#   note       WordsLemmatized is the same method
	#   see        LemmatizedWordsInLanguage, Lemmatized
	#@ aka  The lemma of each word (English).
	def LemmatizedWords()
		return This.LemmatizedWordsInLanguage("english")

		def WordsLemmatized()
			return This.LemmatizedWords()

	  #==========================================================#
	 #   SENTIMENT (VADER)                                      #
	#==========================================================#
	# Returns the VADER compound score of the whole text, from -1 for the most negative to +1 for the most positive; 0 for an empty text.
	#
	#   returns    a number between -1 and 1
	#   note       SentimentCompound is the same method; The food was terrible. scores -0.48
	#   see        Sentiment, PositiveScore, NegativeScore
	#@ aka  The overall sentiment score (compound polarity) in [-1, 1]: negative to positive.
	def SentimentScore()
		return StzEngineStringSentiment(This.Engine(), 0)

		def SentimentCompound()
			return This.SentimentScore()

	# Returns the tone of the text as "positive" at a score of 0.05 or more, "negative" at -0.05 or less, and "neutral" in between.
	#
	#   returns    text: positive, negative or neutral
	#   note       The table is made of wood. is neutral
	#   see        SentimentScore, SentimentExplained
	#@ aka  mood, emotion, feeling, attitude, opinion, how positive or negative
	#@ out  string: "positive" | "negative" | "neutral"
	#@ eg   Q("The food was terrible.").Text().Sentiment()   #--> "negative"
	#@ see  SentimentScore, IsPositive, IsNegative
	#@ aka  The overall tone/mood of the text as "positive", "negative", or "neutral".
	def Sentiment()
		_nScore_ = This.SentimentScore()
		if _nScore_ >= 0.05
			return "positive"
		but _nScore_ <= -0.05
			return "negative"
		else
			return "neutral"
		ok

	# Returns the share of the text that VADER counts as positive, between 0 and 1.
	#
	#   returns    a number between 0 and 1
	#   note       The three shares add up to about 1
	#   see        NegativeScore, NeutralScore, SentimentScore
	#@ aka  The positive sentiment score of the text (VADER).
	def PositiveScore()
		return StzEngineStringSentiment(This.Engine(), 1)

	# Returns the share of the text that VADER counts as negative, between 0 and 1.
	#
	#   returns    a number between 0 and 1
	#   note       The three shares add up to about 1
	#   see        PositiveScore, NeutralScore, SentimentScore
	#@ aka  The negative sentiment score of the text (VADER).
	def NegativeScore()
		return StzEngineStringSentiment(This.Engine(), 2)

	# Returns the share of the text that VADER counts as neither positive nor negative, between 0 and 1.
	#
	#   returns    a number between 0 and 1
	#   note       The three shares add up to about 1
	#   see        PositiveScore, NegativeScore, SentimentScore
	#@ aka  The neutral sentiment score of the text (VADER).
	def NeutralScore()
		return StzEngineStringSentiment(This.Engine(), 3)

	# TRUE if the sentiment score reaches +0.05.
	def IsPositive()
		_nIpS_ = This.SentimentScore()
		_bIp_ = 0
		if _nIpS_ >= 0.05 _bIp_ = 1 ok
		# EVIDENTIALITY: confidence = |compound| (capped at 1)
		$nStzLastCertainty = fabs(_nIpS_)
		if $nStzLastCertainty > 1 $nStzLastCertainty = 1 ok
		$cStzLastWhyB = StzEvidentialVerdict(_bIp_, $nStzLastCertainty) +
			": positive in tone"
		return _bIp_

	# TRUE if the sentiment score is -0.05 or below.
	def IsNegative()
		_nInS_ = This.SentimentScore()
		_bIn_ = 0
		if _nInS_ <= -0.05 _bIn_ = 1 ok
		$nStzLastCertainty = fabs(_nInS_)
		if $nStzLastCertainty > 1 $nStzLastCertainty = 1 ok
		$cStzLastWhyB = StzEvidentialVerdict(_bIn_, $nStzLastCertainty) +
			": negative in tone"
		return _bIn_

	# Returns the verdict with its evidence: the overall label and score, then the positive and the negative words with their VADER weights.
	#
	#   returns    a list of three entries: [ "overall", label, score ], [ "positive_words", [ [
	#              word, weight ] ... ] ] and [ "negative_words", [ [ word, weight ] ... ] ]
	#   note       It is a list, not a sentence; for The food was terrible. the negative words are [
	#              [ "terrible", -2.1 ] ]
	#   see        Sentiment, SentimentScore
	#@ aka  The sentiment verdict as a human-readable sentence.
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
	# Returns the Penn Treebank part-of-speech tag of each word, in word order.
	#
	#   returns    a list of text, such as "DT", "JJ", "NN", "VBZ"
	#   note       PartOfSpeechTags is the same method; the tagger is rule-based and can be wrong,
	#              for example brown fox comes out as JJ NN NN
	#   see        TaggedWords, WordsThatAre
	#@ aka  The part-of-speech tag (noun, verb, adjective...) for each word.
	def POSTags()
		return StzEngineStringPosTagsList(This.Engine())

		def PartOfSpeechTags()
			return This.POSTags()

	# Returns each word paired with its part-of-speech tag, in word order.
	#
	#   returns    a list of [ word, tag ] pairs
	#   note       WordsWithPOS is the same method; the first pair of Running dogs is [ "Running",
	#              "VBG" ]
	#   see        POSTags, Chunks
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

	# Returns the runs of words whose tags fit a pattern of Penn tags, scanning left to right and taking the longest run.
	#
	#   pcTagPattern   Penn tags separated by spaces, each with an optional quantifier ? * or +,
	#                  matched by prefix and without regard to case
	#   returns        a list of text, one per run; [ ] for an empty pattern
	#   note           The tag NN also covers NNS and NNP; DT? JJ* NN+ finds The quick brown fox and
	#                  the lazy dog
	#   see            NounPhrases, ParseTree, TaggedWords
	#@ aka  POS-PATTERN CHUNKING (R3, the NLTK offensive): PATTERNS OVER TAGS. ? Q("The quick brown fox...").TextQ().Chunks("DT? JJ* NN+") #--> [ "The quick brown fox", "the lazy dog" ] Grammar: Penn tags separated by spaces, each with an optional quantifier -- ? (0/1), * (0+), + (1+), none (exactly 1). A tag matches by PREFIX (NN covers NN/NNS/NNP/NNPS). Covers NLTK's RegexpParser chunking with a cleaner gra
	def Chunks(pcTagPattern)
		_aUnits_ = This._ChunkUnits(pcTagPattern)
		_nU_ = len(_aUnits_)
		if _nU_ = 0
			return []
		ok
		_aTW_ = This.TaggedWords()
		_nW_ = len(_aTW_)
		_acOut_ = []
		_i_ = 1
		while _i_ <= _nW_
			_j_ = _i_
			_bOk_ = 1
			for _u_ = 1 to _nU_
				_cTag_ = _aUnits_[_u_][1]
				_cQ_ = _aUnits_[_u_][2]
				if _cQ_ = "?"
					if _j_ <= _nW_ and This._TagMatch(_aTW_[_j_][2], _cTag_)
						_j_++
					ok
				but _cQ_ = "*"
					while _j_ <= _nW_ and This._TagMatch(_aTW_[_j_][2], _cTag_)
						_j_++
					end
				but _cQ_ = "+"
					if _j_ <= _nW_ and This._TagMatch(_aTW_[_j_][2], _cTag_)
						_j_++
						while _j_ <= _nW_ and This._TagMatch(_aTW_[_j_][2], _cTag_)
							_j_++
						end
					else
						_bOk_ = 0
						exit
					ok
				else
					if _j_ <= _nW_ and This._TagMatch(_aTW_[_j_][2], _cTag_)
						_j_++
					else
						_bOk_ = 0
						exit
					ok
				ok
			next
			if _bOk_ = 1 and _j_ > _i_
				_cChunk_ = ""
				for _k_ = _i_ to _j_ - 1
					if _cChunk_ != ""
						_cChunk_ += " "
					ok
					_cChunk_ += _aTW_[_k_][1]
				next
				_acOut_ + _cChunk_
				_i_ = _j_
			else
				_i_++
			ok
		end
		return _acOut_

	# CONSTITUENCY PARSING (R3, the level above chunking): the NESTED phrase
	# structure, not flat chunks. A CASCADED PHRASE GRAMMAR -- rules applied
	# in order, later rules naming phrases (NP/VP/PP) built by earlier ones,
	# so the tree gains real depth (S -> VP -> PP -> NP -> leaf).
	#   ? Q("The quick brown fox jumps over the lazy dog").TextQ().ParseTree()
	#   #--> (S (NP The/DT quick/JJ brown/JJ fox/NN)
	#   #       (VP jumps/VBZ (PP over/IN (NP the/DT lazy/JJ dog/NN))))
	# ParseTree() = the bracket string (data); ParseTreeQ() = the navigable
	# stzParseTree object (Phrases/Subtrees/Leaves/Height/Show).
	def ParseTreeQ()
		return This.ParseTreeWithQ(This._DefaultGrammar())

	# Returns the nested phrase structure of the text as a bracket string, built with a default grammar of NP, PP and VP phrases.
	#
	#   returns    text, such as "(S (NP The/DT quick/JJ brown/NN fox/NN) (VP jumps/VBZ (PP over/IN
	#              (NP the/DT lazy/JJ dog/NN))))"
	#   note       Words that fit no phrase hang directly under S; ParseTreeQ gives the navigable
	#              stzParseTree object
	#   see        ParseTreeWithQ, Chunks, NounPhrases
	def ParseTree()
		return This.ParseTreeQ().ToBracket()

	# Returns a stzParseTree built by applying your own cascade of phrase rules, in order, over the tagged words.
	#
	#   paGrammar   a list of [ label, tag pattern ] rules, where a later rule may use an earlier
	#               label as a tag
	#   returns     a stzParseTree; its ToBracket method gives the bracket string
	#   note        An empty grammar gives a flat tree with every word under S
	#   warning     A grammar that is not a list raises error R5
	#   see         ParseTree, Chunks
	#@ aka  custom cascade: paGrammar = [ [ label, "TAG-pattern" ], ... ]
	def ParseTreeWithQ(paGrammar)
		_aTW_ = This.TaggedWords()
		_aNodes_ = []
		_nW_ = len(_aTW_)
		for _i_ = 1 to _nW_
			_oLeaf_ = new stzParseTree(StzUpper("" + _aTW_[_i_][2]))
			_oLeaf_.SetWord(_aTW_[_i_][1])
			_aNodes_ + _oLeaf_
		next
		_aNodes_ = This._ApplyCascade(_aNodes_, paGrammar)
		# root the remaining forest under a single S (the sentence)
		_oRoot_ = new stzParseTree("S")
		_nN_ = len(_aNodes_)
		for _i_ = 1 to _nN_
			_oRoot_.AddChild(_aNodes_[_i_])
		next
		return _oRoot_

	# Returns the noun phrases of the text: an optional determiner, adjectives, then one or more nouns.
	#
	#   returns    a list of text, such as "A big red car" and "the old station"
	#   note       It is Chunks with the pattern DT? JJ* NN+
	#   see        Chunks, ParseTree
	#@ aka  the flagship sugar: DT? JJ* NN+ -- the classic noun-phrase shape
	def NounPhrases()
		return This.Chunks("DT? JJ* NN+")

	#-- the cascade engine (shared quantifier logic with the chunker) --------

	def _DefaultGrammar()
		return [
			[ "NP", "DT? PRP$? CD* JJ* NN+" ],   # a noun phrase (NN+ covers NNP)
			[ "NP", "PRP" ],                      # a pronoun is a noun phrase
			[ "PP", "IN NP" ],                    # preposition + noun phrase
			[ "VP", "VB RB* NP? PP*" ]            # verb (+ object) (+ modifiers)
		]

	def _ApplyCascade(paNodes, paGrammar)
		_aNodes_ = paNodes
		_nR_ = len(paGrammar)
		for _r_ = 1 to _nR_
			_aUnits_ = This._ChunkUnits(paGrammar[_r_][2])
			_aNodes_ = This._ApplyRule(_aNodes_, paGrammar[_r_][1], _aUnits_)
		next
		return _aNodes_

	# one greedy pass of a rule over the node stream: matched spans become a
	# new phrase node labeled pcLabel; unmatched nodes pass through unchanged
	def _ApplyRule(paNodes, pcLabel, paUnits)
		_nN_ = len(paNodes)
		_nU_ = len(paUnits)
		_aOut_ = []
		_i_ = 1
		while _i_ <= _nN_
			_j_ = _i_
			_bOk_ = 1
			for _u_ = 1 to _nU_
				_cTag_ = paUnits[_u_][1]
				_cQ_ = paUnits[_u_][2]
				if _cQ_ = "?"
					if _j_ <= _nN_ and This._TagMatch(paNodes[_j_].Label(), _cTag_)
						_j_++
					ok
				but _cQ_ = "*"
					while _j_ <= _nN_ and This._TagMatch(paNodes[_j_].Label(), _cTag_)
						_j_++
					end
				but _cQ_ = "+"
					if _j_ <= _nN_ and This._TagMatch(paNodes[_j_].Label(), _cTag_)
						_j_++
						while _j_ <= _nN_ and This._TagMatch(paNodes[_j_].Label(), _cTag_)
							_j_++
						end
					else
						_bOk_ = 0
						exit
					ok
				else
					if _j_ <= _nN_ and This._TagMatch(paNodes[_j_].Label(), _cTag_)
						_j_++
					else
						_bOk_ = 0
						exit
					ok
				ok
			next
			if _bOk_ = 1 and _j_ > _i_
				_oPhrase_ = new stzParseTree(pcLabel)
				for _k_ = _i_ to _j_ - 1
					_oPhrase_.AddChild(paNodes[_k_])
				next
				_aOut_ + _oPhrase_
				_i_ = _j_
			else
				_aOut_ + paNodes[_i_]
				_i_++
			ok
		end
		return _aOut_

	def _ChunkUnits(pcPattern)
		_acToks_ = StzSplit(ring_trim("" + pcPattern), " ")
		_aUnits_ = []
		_nT_ = len(_acToks_)
		for _t_ = 1 to _nT_
			_cTok_ = ring_trim(_acToks_[_t_])
			if _cTok_ = ""
				loop
			ok
			_cLast_ = StzRight(_cTok_, 1)
			if _cLast_ = "?" or _cLast_ = "*" or _cLast_ = "+"
				_aUnits_ + [ StzUpper(StzLeft(_cTok_, StzLen(_cTok_) - 1)), _cLast_ ]
			else
				_aUnits_ + [ StzUpper(_cTok_), "" ]
			ok
		next
		return _aUnits_

	def _TagMatch(pcWordTag, pcPatTag)
		# prefix semantics: NN covers NN/NNS/NNP/NNPS
		return StzLeft(StzUpper("" + pcWordTag), StzLen(pcPatTag)) = pcPatTag

	  #==========================================================#
	 #   NAMED-ENTITY RECOGNITION                               #
	#==========================================================#
	# Returns the people, companies and places found in the text as [ entity, type ] pairs, using a neural NER model if loaded, else rules.
	#
	#   returns    a list of [ entity, type ] pairs with types such as PERSON, ORGANIZATION,
	#              LOCATION and ENTITY; [ ] when there is none
	#   note       Entities is the same method; Barack Obama visited Microsoft in Paris. gives [
	#              "Barack Obama", "PERSON" ] and [ "Microsoft", "ORGANIZATION" ]
	#   warning    The rule-based recognizer joins a capitalized word that follows a full stop to
	#              the entity before it, so Paris. Angela Merkel comes out as one ENTITY (seen on
	#              three texts)
	#   see        EntitiesOfType, NeuralEntities, RegisterNamedEntities
	#@ aka  who and what is mentioned, people places organizations, proper names
	#@ see  PersonNames, Organizations, Locations, EntitiesOfType
	#@ aka  NamedEntities() -- [[entity, type], ...]. Upgrades to TRANSFORMER NER (a BERT token-classification head) when a NER-head GGUF is loaded (StzUseNeuralModel with e.g. bert-base-NER); otherwise the rule-based engine NER. Both emit the same PERSON/ORGANIZATION/LOCATION type vocabulary, so PersonNames()/ Organizations()/Locations() and EntitiesOfType() work either way.
	def NamedEntities()
		if StzHasNeuralNerModel()
			return This.NeuralEntities()
		ok
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

		# Returns the [ entity, type ] pairs from the loaded transformer NER model, and an empty list when none is loaded.
		#
		#   returns    a list of [ entity, type ] pairs; [ ] without a model
		#   note       Run without a model here, so only the empty answer was seen
		#   see        NamedEntities
		#@ aka  NeuralEntities() -- the transformer-NER result explicitly: [[entity, type], ...] via the loaded NER-head model; [] if none is loaded (DATA).
		def NeuralEntities()
			if StzEngineNeuralModelHasNer() != 1 return [] ok
			_nNueN_ = StzEngineNeuralNer(This.Content())
			_aNueOut_ = []
			for _iNue_ = 0 to _nNueN_ - 1
				_aNueOut_ + [ StzEngineNeuralNerText(_iNue_), StzEngineNeuralNerType(_iNue_) ]
			next
			return _aNueOut_

		def Entities()
			return This.NamedEntities()

	# Adds the named entities to the shared world store of the process, marked with the source ner, and tells how many were new.
	#
	#   returns    a number; 5 the first time for two sentences with five entities, 0 when repeated
	#   note       It changes the shared world store, not the text; EntitiesToWorld is the same
	#              method
	#   see        NamedEntities
	#@ aka  Register this text's named entities into the shared world ($oWorldEntities) -- EXPLICIT by design: NER over arbitrary text must never pollute the world silently. Returns how many were NEW.
	def RegisterNamedEntities()
		_aRne_ = This.NamedEntities()
		_nRne_ = len(_aRne_)
		_nAdded_ = 0
		for _iRne_ = 1 to _nRne_
			_nAdded_ += StzKnowXT(_aRne_[_iRne_][1], _aRne_[_iRne_][2],
			                      [ [ "source", "ner" ] ])
		next
		return _nAdded_

		def EntitiesToWorld()
			return This.RegisterNamedEntities()

	# Returns the entity names of one type, in text order; the type must be written exactly.
	#
	#   returns    a list of text; [ ] for a type that is absent or written in another case
	#   note       EntitiesOfType("PERSON") finds Barack Obama while "person" finds nothing
	#   see        NamedEntities, PersonNames
	#@ aka  The named entities of one type (e.g. "PERSON") mentioned in the text.
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

	# Returns the entity names typed PERSON.
	#
	#   returns    a list of text
	#   see        EntitiesOfType, Organizations, Locations
	#@ aka  The people (person names) mentioned in the text.
	def PersonNames()
		return This.EntitiesOfType("PERSON")

	# Returns the entity names typed ORGANIZATION.
	#
	#   returns    a list of text
	#   see        EntitiesOfType, PersonNames, Locations
	#@ aka  The organizations and companies mentioned in the text.
	def Organizations()
		return This.EntitiesOfType("ORGANIZATION")

	# Returns the entity names typed LOCATION.
	#
	#   returns    a list of text
	#   see        EntitiesOfType, PersonNames, Organizations
	#@ aka  The places and locations mentioned in the text.
	def Locations()
		return This.EntitiesOfType("LOCATION")

	# Returns the candidate type whose meaning is closest to an entity name; an empty string when an argument has the wrong type.
	#
	#   pcEntity   the entity name to type
	#   paTypes    the list of candidate type names, each text
	#   returns    text, one of the candidate types
	#   note       A loaded neural model ranks the candidates by meaning, which was not available
	#              here
	#   warning    Without a neural model a short name scores 0 against every candidate, so the
	#              first candidate always wins (Microsoft gets city when city is listed first)
	#   see        EntitiesTypedAs, Classify
	# --- Embedding-based entity typing (neural upgrade) --------------------
	#@ aka  The rule-based NER above detects + coarsely types spans. These re-TYPE an entity against ARBITRARY, user-defined types BY MEANING (zero-shot, via the neural model when loaded; lexical fallback otherwise) -- so the type set adapts to any domain, and "Paris" the city vs the person is disambiguated by meaning. (A real token-classification NER-head GGUF, once available, plugs onto the per-token engine
	def EntityTypeOf(pcEntity, paTypes)
		if NOT (isString(pcEntity) and isList(paTypes)) return "" ok
		_oEtoT_ = new stzText(pcEntity)
		return _oEtoT_.ClassifiedAs(paTypes)

	# Returns each named entity with the best candidate type for it, as [ entity, type ] pairs; [ ] when the types are not a list.
	#
	#   paTypes    the list of candidate type names, each text
	#   returns    a list of [ entity, type ] pairs
	#   note       Needs a loaded neural model to choose by meaning
	#   warning    Without a neural model every entity gets the first candidate (all five entities
	#              of one text came out as city)
	#   see        EntityTypeOf, NamedEntities
	#@ aka  EntitiesTypedAs(types) -- every detected entity re-typed against `types` by meaning: [[entity, best_type], ...] (DATA).
	def EntitiesTypedAs(paTypes)
		if NOT isList(paTypes) return [] ok
		_aEtaAll_ = This.NamedEntities()
		_aEtaOut_ = []
		_nEtaN_ = len(_aEtaAll_)
		for _iEta_ = 1 to _nEtaN_
			_cEtaEnt_ = _aEtaAll_[_iEta_][1]
			_aEtaOut_ + [ _cEtaEnt_, This.EntityTypeOf(_cEtaEnt_, paTypes) ]
		next
		return _aEtaOut_

		# Q-ladder: Q -> basic stzList; QQ -> stzListOfPairs.
		def EntitiesTypedAsQ(paTypes)
			return new stzList(This.EntitiesTypedAs(paTypes))

		def EntitiesTypedAsQQ(paTypes)
			return new stzListOfPairs(This.EntitiesTypedAs(paTypes))

	  #==========================================================#
	 #   STOPWORDS + READABILITY                                #
	#==========================================================#
	# Returns the words that are not stopwords, in order, keeping their case.
	#
	#   returns    a list of text
	#   note       Keywords is the same method; The food was terrible. gives [ "food", "terrible" ]
	#   see        WithoutStopwords, IsStopword
	#@ aka  The meaningful content words, with common stopwords (the, a, of...) removed.
	def ContentWords()
		return StzEngineStringContentWordsList(This.Engine())

		def Keywords()
			return This.ContentWords()

	# Returns the content words joined by single spaces, with the stopwords and the punctuation dropped.
	#
	#   returns    text, such as "food terrible"
	#   see        ContentWords, IsStopword
	#@ aka  The text with the stopwords removed.
	def WithoutStopwords()
		_pWs_ = StzEngineStringWithoutStopwords(This.Engine())
		_cWs_ = StzEngineStringData(_pWs_)
		StzEngineStringFree(_pWs_)
		return _cWs_

	# TRUE if the text is a stopword.
	def IsStopword()
		return StzEngineStringIsStopword(This.Engine()) = 1

	# Returns the Flesch reading-ease score, higher meaning easier to read; 0 for an empty text.
	#
	#   returns    a number, such as 75.88 for The food was terrible.
	#   note       FleschReadingEase is the same method
	#   see        ReadabilityGrade, ReadabilityExplained
	#@ aka  How easy the text is to read as a Flesch reading-ease score (higher = easier).
	def ReadingEase()
		return StzEngineStringReadability(This.Engine(), 0)

		def FleschReadingEase()
			return This.ReadingEase()

	# Returns the US school grade needed to read the text, by the Flesch-Kincaid formula; 0 for an empty text.
	#
	#   returns    a number, such as 3.67 for The food was terrible.
	#   note       FleschKincaidGrade is the same method
	#   see        ReadingEase, ReadabilityExplained
	#@ aka  The US school grade level needed to read the text (Flesch-Kincaid grade).
	def ReadabilityGrade()
		return StzEngineStringReadability(This.Engine(), 1)

		def FleschKincaidGrade()
			return This.ReadabilityGrade()

	# Returns the readability measures as [ name, value ] pairs: words, sentences, words_per_sentence, reading_ease and grade_level.
	#
	#   returns    a list of five [ name, value ] pairs
	#   note       It is a list of numbers, not a sentence; an empty text gives zeros
	#   see        ReadingEase, ReadabilityGrade
	#@ aka  The readability verdict as a human-readable sentence.
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

	# Returns the n best multi-word key phrases by the RAKE method, best first; n of 0 or less gives all of them.
	#
	#   n          how many phrases to return, 0 or less for all
	#   returns    a list of text
	#   note       KeyPhrasesXT adds the score; the sample text gives quick brown fox jumps first
	#   see        TopKeyPhrase, RankedKeywords
	#@ aka  main topics, themes, subjects, what it is about, important phrases, main ideas, key ideas, key points, the gist
	#@ see  RankedKeywords, TopKeyPhrase
	#@ aka  The n most important multi-word key phrases (main topics/themes) in the text.
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

	# Returns the best key phrase of the text, or an empty string when there is none.
	#
	#   returns    text
	#   see        KeyPhrases
	#@ aka  The single best key phrase of the text.
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

	# Returns the n most important single words by the TextRank method, best first; n of 0 or less gives all of them.
	#
	#   n          how many words to return, 0 or less for all
	#   returns    a list of text
	#   note       RankedKeywordsXT adds the score
	#   see        KeyPhrases
	#@ aka  The n most important single keywords, ranked by importance (TextRank).
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

	# Returns the n most important sentences by TextRank, or by embedding similarity with a model; n of 0 or less gives every sentence.
	#
	#   n          how many sentences to keep
	#   returns    a list of text, one per sentence
	#   note       With a loaded model the answer keeps the original order of the text
	#   see        SummarizedIn, KeyPhrases
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

	# Returns the n most important sentences joined by single spaces, as a short extractive summary.
	#
	#   n          how many sentences to keep
	#   returns    text
	#   note       Summary is the same method; n of 0 or less gives the whole text
	#   see        SummarySentences, SummarizedAbstractively
	#@ aka  summarize, summarise, shorten, condense, brief, briefly, tldr, gist, key points
	#@ see  SummarySentences, KeyPhrases
	#@ aka  A short summary of the text in n sentences (extractive: the most important sentences, joined). Summary(n) is the alias.
	def SummarizedIn(n)
		_oSmz_ = new stzListOfStrings(This.SummarySentences(n))
		return _oSmz_.JoinedUsing(" ")

		def Summary(n)
			return This.SummarizedIn(n)

	  #==========================================================#
	 #   POS-AWARE WORD FILTERS                                 #
	#==========================================================#
	# Returns the words whose Penn tag starts with the given tag, in text order.
	#
	#   pcPenn     a Penn tag or the start of one, such as NN or VB
	#   returns    a list of text; [ ] when the argument is not text
	#   note       The match is by prefix, so NN gives NNS and NNP words too
	#   see        POSTags, TaggedWords
	#@ aka  The words carrying the given Penn part-of-speech tag.
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

	# Returns the words whose tag starts with NN: the naming words, proper names included.
	#
	#   returns    a list of text
	#   note       Tagger mistakes carry over, so brown can appear among them
	#   see        ProperNouns, WordsThatAre
	#@ aka  The nouns (naming words: people, things, ideas) in the text.
	def Nouns()
		return This.WordsThatAre("NN")

		def NounsQ()
			return new stzList(This.Nouns())

	# Returns the words tagged NNP, the capitalized names, one word each.
	#
	#   returns    a list of text
	#   note       Barack Obama gives Barack and Obama as two words
	#   see        Nouns, NamedEntities
	#@ aka  The proper nouns (capitalized names) in the text.
	def ProperNouns()
		return This.WordsThatAre("NNP")

	# Returns the action words, those whose tag starts with VB, in all their forms.
	#
	#   returns    a list of text
	#   note       Modal words such as can are tagged MD and are not included
	#   see        WordsThatAre, POSTags
	#@ aka  The verbs (action words) in the text.
	def Verbs()
		return This.WordsThatAre("VB")

		def VerbsQ()
			return new stzList(This.Verbs())

	# Returns the describing words, those whose tag starts with JJ.
	#
	#   returns    a list of text
	#   note       The tag JJ also covers JJR and JJS
	#   see        WordsThatAre, Adverbs
	#@ aka  The adjectives (describing words) in the text.
	def Adjectives()
		return This.WordsThatAre("JJ")

		def AdjectivesQ()
			return new stzList(This.Adjectives())

	# Returns the words tagged RB, the ones that tell how, when or where.
	#
	#   returns    a list of text
	#   see        WordsThatAre, Adjectives
	#@ aka  The adverbs (how/when/where modifiers) in the text.
	def Adverbs()
		return This.WordsThatAre("RB")

	# Returns the words whose tag starts with PRP, such as I and it.
	#
	#   returns    a list of text
	#   see        WordsThatAre
	#@ aka  The pronouns (he, she, it, they...) in the text.
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

	# Returns the sentences whose tone equals the one asked for, in text order.
	#
	#   pcPolarity   positive or negative or neutral, written in any case
	#   returns      a list of text; [ ] when the argument is not text
	#   note         Each sentence is judged alone, so The quick brown fox jumps over the lazy dog.
	#                comes out negative because of lazy
	#   see          PositiveSentences, NegativeSentences, Sentiment
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

	# Returns the sentences whose tone is positive, in text order.
	#
	#   returns    a list of text
	#   see        SentencesThatAre, MostPositiveSentence
	def PositiveSentences()
		return This.SentencesThatAre("positive")

	# Returns the sentences whose tone is negative, in text order.
	#
	#   returns    a list of text
	#   see        SentencesThatAre, MostNegativeSentence
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

	# Returns the sentence with the highest sentiment score, the first one on a tie; an empty string for an empty text.
	#
	#   returns    text
	#   see        PositiveSentences, MostNegativeSentence
	def MostPositiveSentence()
		return This._BestSentenceBy(1)

	# Returns the sentence with the lowest sentiment score, the first one on a tie; an empty string for an empty text.
	#
	#   returns    text
	#   see        NegativeSentences, MostPositiveSentence
	def MostNegativeSentence()
		return This._BestSentenceBy(-1)

	# Returns the sentence closest to a query, by embeddings with a neural model or by word overlap without; the first when none overlap.
	#
	#   pcQuery    the text to compare every sentence with
	#   returns    text; an empty string for an empty text or a query that is not text
	#   note       MostSemanticallySimilarSentenceTo is the same method
	#   see        SemanticSimilarityWith, SummarySentences
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
			if len(_aMsQEmb_) = 0 _bMsSem_ = 0 ok
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
	# TRUE if a neural embedding model is loaded for the whole process, which turns the lexical comparisons into comparisons of meaning.
	#
	#   returns    TRUE or FALSE; FALSE here, where none was loaded
	#   note       IsSemanticModelReady is the same method
	#   see        Embedding, SemanticSimilarityWith
	#@ aka  Upgrades text similarity from lexical bag-of-words to true MEANING via a runtime neural model (load one process-wide with StzNeuralModelQ(path)). With no model loaded these degrade gracefully to the lexical path, so code keeps working and auto-improves once a model is present.
	def HasSemanticModel()
		return StzHasNeuralModel()

		def IsSemanticModelReady()
			return This.HasSemanticModel()

	# Returns the sentence-embedding vector of the text from the loaded model, as a list of numbers.
	#
	#   returns    a list of numbers; [ ] when no model is loaded
	#   note       EmbeddingVector is the same method
	#   see        HasSemanticModel, SemanticSimilarityWith
	#@ aka  Embedding() -- this text's sentence-embedding vector (list of floats) via the loaded model; [] if none is loaded (DATA, per Softanza's Q rule).
	def Embedding()
		if NOT This.HasSemanticModel() return [] ok
		return _StzEmbedInto(This.Content())

		def EmbeddingVector()
			return This.Embedding()

	def EmbeddingQ()
		return new stzList(This.Embedding())

	# Returns the cosine similarity of this text and another, from the embeddings when a model is loaded and from shared words otherwise.
	#
	#   returns    a number from -1 to 1; 0 when the argument is not text
	#   note       Without a model it only sees shared words: the same sentence gives 1 and
	#              unrelated words give 0; SemanticSimilarityTo is the same method
	#   see        IsSemanticallySimilarTo, ComparedTo
	#@ aka  SemanticSimilarityWith(other) -- cosine of the two texts' embeddings in [-1, 1]; falls back to lexical cosine when no model is loaded (DATA).
	def SemanticSimilarityWith(pcOther)
		if NOT isString(pcOther) return 0 ok
		return StzSemanticSimilarity(This.Content(), pcOther)

		def SemanticSimilarityTo(pcOther)
			return This.SemanticSimilarityWith(pcOther)

	# Raises error R19 today when no generative model is loaded, instead of falling back to the extractive summary.
	#
	#   returns    a one-sentence text from a loaded generative model; nothing without one, as error
	#              R19 is raised
	#   note       With a model it asks the model for one short sentence; that path was read from
	#              the body and not run
	#   warning    Raises error R19 without a generative model (checked on three texts): the
	#              fallback calls Summary without its sentence count
	#   see        SummarizedIn, AnswerAbout
	# --- ABSTRACTIVE ops (generative decoder; falls back to extractive) ---
	#@ aka  IsSemanticallySimilarTo(other, threshold) -- TRUE if the meaning-similarity meets the threshold (default 0.5). GENERATE a fresh summary of the text (not sentence extraction). When no generative model is loaded, degrades to the extractive Summary.
	def SummarizedAbstractively()
		if StzHasGenerativeModel() = 0
			return This.Summary()
		ok
		_cP_ = "Summarize the following text in one short sentence:" +
			char(10) + char(10) + This.Content()
		return StzAskModel(_cP_, 60)

		def SummarizedAbstractivelyQ()
			return new stzString(This.SummarizedAbstractively())

	# Asks the loaded generative model a question with the text as its context and returns the short answer.
	#
	#   pcQuestion   the question to ask about the text
	#   returns      text; an empty string when no model is loaded or the question is not text
	#   note         Run without a model here, so only the empty answer was seen
	#   see          SummarizedAbstractively, Classify
	#@ aka  ANSWER a question ABOUT the text (grounded generation): the text is the context, the question is asked over it. "" when no model / no text.
	def AnswerAbout(pcQuestion)
		if StzHasGenerativeModel() = 0 return "" ok
		if NOT isString(pcQuestion) return "" ok
		_cP_ = "Context:" + char(10) + This.Content() + char(10) + char(10) +
			"Question: " + pcQuestion + char(10) + "Answer briefly:"
		return StzAskModel(_cP_, 60)

		def AnswerAboutQ(pcQuestion)
			return new stzString(This.AnswerAbout(pcQuestion))

	# TRUE if the similarity of the two texts reaches a threshold.
	#
	#   pnThreshold   the lowest similarity that counts, 0.5 when it is not a number
	#   returns       TRUE or FALSE
	#   note          The verdict also leaves its confidence and a reason in the evidence globals of
	#                 the process
	#   see           SemanticSimilarityWith
	def IsSemanticallySimilarTo(pcOther, pnThreshold)
		if NOT isNumber(pnThreshold) pnThreshold = 0.5 ok
		_nIssScore_ = This.SemanticSimilarityWith(pcOther)
		_bIss_ = 0
		if _nIssScore_ >= pnThreshold _bIss_ = 1 ok
		# EVIDENTIALITY: the verdict carries its confidence
		if _bIss_ = 1
			$nStzLastCertainty = _nIssScore_
		else
			$nStzLastCertainty = 1 - _nIssScore_
		ok
		$cStzLastWhyB = StzEvidentialVerdict(_bIss_, $nStzLastCertainty) +
			": semantically similar to " + @@(pcOther)
		return _bIss_

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
	 #   ZERO-SHOT CLASSIFICATION                               #
	#==========================================================#
	# Returns the candidate labels with a similarity score, best first, with no training; labels that are not text are skipped.
	#
	#   paLabels   the list of candidate labels, each text
	#   returns    a list of [ label, score ] pairs; [ ] when the labels are not a list
	#   note       The score is embedding similarity with a model and word overlap without one;
	#              richer labels such as about sports separate better
	#   see        ClassifiedAs, ClassificationConfidence
	#@ aka  Classify this text against ARBITRARY candidate labels with no training: rank each label by how closely its MEANING matches the text (embedding cosine when a model is loaded, else lexical). Pass richer label strings (e.g. "about sports") for sharper separation.
	def Classify(paLabels)
		if NOT isList(paLabels) return [] ok
		_cClText_ = This.Content()
		_aClOut_ = []
		_nClN_ = len(paLabels)
		for _iCl_ = 1 to _nClN_
			if isString(paLabels[_iCl_])
				_nClSim_ = StzSemanticSimilarity(_cClText_, paLabels[_iCl_])
				_aClOut_ + [ paLabels[_iCl_], _nClSim_ ]
			ok
		next
		return This._SortPairsByScoreDesc(_aClOut_)

		def ClassificationOf(paLabels)
			return This.Classify(paLabels)

		# Q-ladder: Q -> basic stzList; QQ -> stzListOfPairs (it is a list of pairs).
		def ClassifyQ(paLabels)
			return new stzList(This.Classify(paLabels))

		def ClassifyQQ(paLabels)
			return new stzListOfPairs(This.Classify(paLabels))

	# Returns the best-matching candidate label, an empty string when there is none.
	#
	#   paLabels   the list of candidate labels, each text
	#   returns    text
	#   warning    On a tie, which is common without a neural model, the first label wins
	#   see        Classify, ClassificationConfidence
	#@ aka  ClassifiedAs(labels) -- the single best-matching label (DATA, a string).
	def ClassifiedAs(paLabels)
		_aCaR_ = This.Classify(paLabels)
		if len(_aCaR_) = 0 return "" ok
		# EVIDENTIALITY: the label carries the top score as confidence
		$nStzLastCertainty = _aCaR_[1][2]
		$cStzLastWhyB = Evidentially() + " " + @@(_aCaR_[1][1])
		return _aCaR_[1][1]

		def ClassifiedAsQ(paLabels)
			return new stzString(This.ClassifiedAs(paLabels))

	# Returns the score of the winning label, between -1 and 1, or 0 when there is none.
	#
	#   paLabels   the list of candidate labels, each text
	#   returns    a number
	#   see        Classify, ClassifiedAs
	#@ aka  The score (similarity) the winning label got, in [-1, 1] (DATA).
	def ClassificationConfidence(paLabels)
		_aCcR_ = This.Classify(paLabels)
		if len(_aCcR_) = 0 return 0 ok
		return _aCcR_[1][2]

	# Selection-sort [label, score] pairs by DESCENDING score (label count is
	# small; avoids the list-sort ABI caveats). Private.
	def _SortPairsByScoreDesc(paPairs)
		_aSpP_ = paPairs
		_nSpN_ = len(_aSpP_)
		for _iSp_ = 1 to _nSpN_ - 1
			_nSpMax_ = _iSp_
			for _jSp_ = _iSp_ + 1 to _nSpN_
				if _aSpP_[_jSp_][2] > _aSpP_[_nSpMax_][2]
					_nSpMax_ = _jSp_
				ok
			next
			if _nSpMax_ != _iSp_
				_aSpTmp_ = _aSpP_[_iSp_]
				_aSpP_[_iSp_] = _aSpP_[_nSpMax_]
				_aSpP_[_nSpMax_] = _aSpTmp_
			ok
		next
		return _aSpP_

	  #==========================================================#
	 #   LANGUAGE DETECTION                                     #
	#==========================================================#
	# Returns the name of the tongue the text is written in, in lowercase, or unknown when it cannot tell.
	#
	#   returns    text, such as english, french or arabic; unknown for an empty text, and also for
	#              a text the detector cannot decide on (two sentences full of names gave unknown)
	#   note       DetectedLanguage is the same method
	#   see        AutoStemmed, AutoLemmatized
	#@ aka  what language, which tongue, detect language, idiom, locale
	#@ aka  Detect which natural language the text is written in.
	def Language()
		_pLg_ = StzEngineStringDetectLanguage(This.Engine())
		_cLg_ = StzEngineStringData(_pLg_)
		StzEngineStringFree(_pLg_)
		return _cLg_

		def DetectedLanguage()
			return This.Language()

	# Returns the text reduced to dictionary forms in its own detected tongue, English when that is unknown.
	#
	#   returns    text
	#   note       A French text comes out as le cheval manger un pommer rouge
	#   see        Language, LemmatizedInLanguage
	#@ aka  The text lemmatized in its own detected language.
	def AutoLemmatized()
		_cAlLg_ = This.Language()
		if _cAlLg_ = "unknown" _cAlLg_ = "english" ok
		return This.LemmatizedInLanguage(_cAlLg_)

	# Returns the text cut to stems in its own detected tongue, English when that is unknown.
	#
	#   returns    text
	#   note       A French text comes out as le cheval mang de pomm roug
	#   see        Language, StemmedInLanguage
	#@ aka  The text stemmed in its own detected language.
	def AutoStemmed()
		_cAsLg_ = This.Language()
		if _cAsLg_ = "unknown" _cAsLg_ = "english" ok
		return This.StemmedInLanguage(_cAsLg_)

	  #==========================================================#
	 #   PROFILE + STYLOMETRY                                   #
	#==========================================================#
	# Returns a content profile as eight [ name, value ] pairs, from the tongue and the word count to the top keywords and the entities.
	#
	#   returns    a list of eight [ name, value ] pairs
	#   note       top_keywords holds the five most frequent words once the stopwords are dropped
	#   see        StyleProfile, NamedEntities
	#@ aka  A content profile of the text (keywords, entities, sentiment...).
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

	# Returns the ratio of different words to all words, between 0 and 1; 0 for an empty text.
	#
	#   returns    a number
	#   note       TypeTokenRatio is the same method; the the the the gives 0.25
	#   see        StyleProfile
	#@ aka  Vocabulary richness: the ratio of unique words to total words (type-token ratio).
	def LexicalDiversity()
		_nLdTotal_ = This.NumberOfWords()
		if _nLdTotal_ = 0 return 0 ok
		_oLdLow_ = new stzString(@oString.Lowercased())
		_aLdUniq_ = _oLdLow_.WordsAndTheirCounts()
		return len(_aLdUniq_) / _nLdTotal_

		def TypeTokenRatio()
			return This.LexicalDiversity()

	# Returns a style profile as [ name, value ] pairs: avg_word_length, avg_words_per_sentence and lexical_diversity.
	#
	#   returns    a list of three [ name, value ] pairs
	#   see        Profile, LexicalDiversity
	#@ aka  A style profile of the text (word lengths, variety...).
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
	# Returns one line for each occurrence of a word, ignoring case: the word with up to a number of words on each side.
	#
	#   nWindow    how many words to take on each side of the word
	#   returns    a list of text; [ ] when the word is absent or not text
	#   note       A window of 0 gives the word alone
	#   warning    A window that is not a number raises error R41
	#   see        InContext
	#@ aka  The occurrences of the word with n words of context around each.
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

	# Returns every occurrence of a word with 5 words of context on each side, as in a concordance.
	#
	#   returns    a list of text, one line per occurrence
	#   note       Concordance is the same method
	#   see        InContextWithWindow
	#@ aka  Every occurrence of a word shown with its surrounding context (a concordance / keyword-in-context view).
	def InContext(pcWord)
		return This.InContextWithWindow(pcWord, 5)

		def Concordance(pcWord)
			return This.InContext(pcWord)

	# Returns how this text and another compare, as pairs: similarity, sentiment_delta, grade_delta and shared_keywords.
	#
	#   returns    a list of four [ name, value ] pairs; [ ] when the argument is not text
	#   note       The two deltas are this text minus the other one; shared_keywords lists the
	#              content words both texts hold
	#   see        SemanticSimilarityWith, SentimentScore
	#@ aka  Compare this text with another: their similarity, sentiment difference, readability difference, and shared keywords.
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
	# Prints the words with their tags as word/TAG on one line, then hands the text object back.
	#
	#   returns    the text object, so calls can be chained
	#   note       The printed line looks like The/DT food/NN was/VBD terrible/JJ
	#   see        TaggedWords, ShowEntities
	#@ aka  Print each word with its part-of-speech tag.
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

	# Prints the text with every named entity wrapped as [entity:TYPE], then hands the text object back.
	#
	#   returns    the text object, so calls can be chained
	#   note       The wrapping is a plain replace, so an entity inside a longer word is wrapped
	#              there too
	#   see        NamedEntities, ShowTagged
	#@ aka  Print the named entities found in the text.
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

	# Prints one line per sentence, as (tone score) followed by the sentence, then hands the text object back.
	#
	#   returns    the text object, so calls can be chained
	#   note       The first line looks like (negative -0.53) The food was terrible!
	#   see        Sentiment, ShowTagged
	#@ aka  Print the sentiment of each sentence.
	def ShowSentiment()
		_aSsSt_ = This.Sentences()
		_nSsN_ = len(_aSsSt_)
		for _iSs_ = 1 to _nSsN_
			_oSsS_ = new stzText(_aSsSt_[_iSs_])
			? "(" + _oSsS_.Sentiment() + " " + _oSsS_.SentimentScore() + ") " + _aSsSt_[_iSs_]
		next
		return This
