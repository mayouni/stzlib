# R3 -- stzCorpus: THE CORPORA SHELF'S ENTRY OBJECT (LAW 1)
# A corpus = a collection of documents the linguistic domain can count,
# query, and MODEL. Zero setup, zero downloads (the NLTK contrast:
# no nltk.download zoo -- your texts ARE the corpus).
#
#   oC = new stzCorpus([ cDoc1, cDoc2, ... ])   # or one string
#   oC.AddDocument(cText)
#   ? oC.Vocabulary()  ? oC.FreqOf("the")  ? oC.MostFrequent(5)
#
# N-GRAM LANGUAGE MODELING (the NLTK nltk.lm counterpart):
#   ? oC.BigramProbability("the", "fox")   # Laplace-smoothed
#   ? oC.LogProbability("the fox jumps")   # sum of log bigram probs
#   ? oC.Perplexity("the fox jumps")       # the classic LM metric
#
# ENGINE-OWNED: every operation that scales with the corpus -- counting,
# vocabulary, frequency, the LM, TF-IDF -- runs in the Zig engine (a real
# hash map, O(tokens)). stzCorpus is a thin consumer: it hands the engine
# the documents and asks. Nothing corpus-scale is counted in Ring.

class stzCorpus from stzObject

	@acDocs = []
	@nModel = 0       # engine-resident corpus model (0 = not yet built)

	def init(p)
		if isString(p)
			if p != ""
				@acDocs + p
			ok
		but isList(p)
			_n_ = len(p)
			for _i_ = 1 to _n_
				if isString(p[_i_]) and p[_i_] != ""
					@acDocs + p[_i_]
				ok
			next
		ok

	def AddDocument(pcText)
		if isString(pcText) and pcText != ""
			@acDocs + pcText
			This._InvalidateModel()   # the corpus changed -- rebuild on next query
		ok

		def AddDocumentQ(pcText)
			This.AddDocument(pcText)
			return This

	def Documents()
		return @acDocs

	def NumberOfDocuments()
		return len(@acDocs)

	#-- the corpus model: EVERYTHING that scales lives in the engine ------
	#
	# stzCorpus is a THIN CONSUMER. The corpus is counted in a Zig hash map
	# (O(tokens)); a Ring hashlist would be a linear scan per token
	# (~O(tokens * vocab)) and cannot carry a real corpus. So Ring hands the
	# engine the raw documents and asks questions: the engine tokenises,
	# lowercases (Unicode-correct via utf8proc), counts, sorts, and computes
	# TF-IDF. Ring never touches a token. The engine is a HARD dependency for
	# this heavy work -- if its DLL is not loaded we raise a clear message,
	# never fall back to counting a corpus in Ring.

	# The engine-resident model, built on first use and cached.
	def _ModelHandle()
		if @nModel != 0
			return @nModel
		ok
		# Guarantee each document is exactly ONE engine document: strip any
		# internal newline (it would otherwise read as a document boundary).
		# This is light input-prep, not corpus analytics.
		_aClean_ = []
		_nD_ = len(@acDocs)
		for _d_ = 1 to _nD_
			_aClean_ + StzReplace(@acDocs[_d_], nl, " ")
		next
		try
			@nModel = stzengine_ngram_train(JoinXT(_aClean_, nl))
		catch
			stzraise("stzCorpus needs the stz_natlang engine (stz_natlang.dll is not loaded).")
		done
		return @nModel

	def _InvalidateModel()
		This.FreeModel()

	# Ring has no destructors -- free the engine model explicitly when done.
	def FreeModel()
		if @nModel != 0
			try
				stzengine_ngram_free(@nModel)
			catch
			done
			@nModel = 0
		ok

		def FreeLm()   # kept: the LM used to own the handle by this name
			This.FreeModel()

	#-- vocabulary & frequency -------------------------------------------

	def NumberOfWords()
		return stzengine_ngram_token_count(This._ModelHandle())

	def Vocabulary()
		return stzengine_ngram_vocab(This._ModelHandle())

	def VocabularySize()
		return stzengine_ngram_vocab_size(This._ModelHandle())

	def FreqOf(pcWord)
		return stzengine_ngram_uni_count(This._ModelHandle(), "" + pcWord)

	# top-n words by count, as [ word, count ] pairs (engine-sorted)
	def MostFrequent(n)
		return stzengine_ngram_most_frequent(This._ModelHandle(), n)

	#-- the n-gram language model (Laplace-smoothed bigrams) --------------
	#
	#   P(w2|w1) = (count(w1 w2) + 1) / (count(w1) + V)   -- Laplace smoothing

	def BigramProbability(pcW1, pcW2)
		return stzengine_ngram_bigram_prob(This._ModelHandle(), "" + pcW1, "" + pcW2)

	def LogProbability(pcText)
		return stzengine_ngram_log_prob(This._ModelHandle(), "" + pcText)

	# perplexity = exp( -avg log P ) -- LOWER means more in-domain. The scalar
	# formula is Ring's to craft; the log-probability under it is the engine's.
	def Perplexity(pcText)
		_oT_ = new stzText("" + pcText)
		_nW_ = len(_oT_.Words())
		if _nW_ < 2
			return 0
		ok
		return exp( - This.LogProbability(pcText) / (_nW_ - 1) )

	#-- TF-IDF (the vectorizer feeding the ML floor) ----------------------

	def NumberOfDocumentsWith(pcWord)   # document frequency
		return stzengine_ngram_df(This._ModelHandle(), "" + pcWord)

	def TfOf(pcWord, nDoc)
		return stzengine_ngram_tf(This._ModelHandle(), "" + pcWord, nDoc)

	# smoothed idf = log( (1+D) / (1+df) ) + 1 -- computed engine-side, so the
	# formula lives in ONE place and TopTermsOf cannot drift from it.
	def IdfOf(pcWord)
		return stzengine_ngram_idf(This._ModelHandle(), "" + pcWord)

	def TfIdfOf(pcWord, nDoc)
		return This.TfOf(pcWord, nDoc) * This.IdfOf(pcWord)

	# the document's most DISTINCTIVE terms by TF-IDF (engine-sorted),
	# as [ word, tfidf ] pairs
	def TopTermsOf(nDoc, n)
		return stzengine_ngram_top_terms(This._ModelHandle(), nDoc, n)
