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

# Holds a collection of texts and counts their words, scores texts with a bigram language model and ranks the terms of each document by TF-IDF.
#
# Your texts are the corpus: pass one text or a list of texts, each one a document, and nothing is
# downloaded. The counting itself runs in the Zig engine, built on the first question and kept up to
# date as documents are added; FreeModel releases it. Words are cut and lowercased by the engine
# with Unicode rules, so Hebrew, Arabic and emoji count like any other word. Documents are numbered
# from 1. A stzString or stzText is not needed to build one, and the corpus is the entry object of
# the corpora shelf of the linguistic domain.
#
#   receiver   o1 = new stzCorpus([ "the fox jumps over the dog", "the dog sleeps", "שלום עולם שלום"
#              ])
#   example    ? o1.NumberOfDocuments()
#              #--> 3
#              ? o1.FreqOf("the")
#              #--> 3
#              ? o1.FreqOf("שלום")
#              #--> 2
#              ? @@( o1.MostFrequent(1) )
#              #--> [ [ "the", 3 ] ]
#   see        stzText, stzWordStream, stzString
class stzCorpus from stzObject

	@acDocs = []
	@nModel = 0       # engine-resident corpus model (0 = not yet built)

	# Builds a corpus from one text or a list of texts; empty and non-text entries are dropped without a message.
	#
	#   p          a text, or a list of texts, each one a document
	#   returns    nothing; the object is built
	#   note       the engine model is not built here but at the first question
	#   see        AddDocument
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

	# Appends one text to the corpus as a new document, and feeds it to the engine model if that model already exists.
	#
	#   pcText     the text of the new document
	#   returns    nothing; use AddDocumentQ to chain
	#   note       newlines in the text are turned into spaces when it reaches the model, so a
	#              document stays one document
	#   see        AddDocumentQ, Documents
	def AddDocument(pcText)
		if isString(pcText) and pcText != ""
			@acDocs + pcText

			# Push the document into the LIVE model rather than throwing the
			# model away.
			#
			# Invalidating meant the next query retrained on the WHOLE corpus
			# -- re-cleaning every document and re-joining them Ring-side,
			# then re-counting engine-side. So the loop a corpus is actually
			# built with, "add a document, ask a question", was O(docs^2):
			# 400 documents took 1.89s where 100 took 0.12s.
			#
			# The counts are cumulative and train() is itself a loop of the
			# same per-document step, so adding one at a time yields exactly
			# the model a full retrain would.
			if @nModel != 0
				stzengine_ngram_add_doc(@nModel, StzReplace(pcText, nl, " "))
			ok
		ok

		def AddDocumentQ(pcText)
			This.AddDocument(pcText)
			return This

	# Returns the documents of the corpus as they were given, in order.
	#
	#   returns    a list of texts
	#   note       documents are numbered from 1 in TfOf, TfIdfOf and TopTermsOf
	#   see        NumberOfDocuments, AddDocument
	def Documents()
		return @acDocs

	# Returns how many documents the corpus holds.
	#
	#   returns    a number
	#   see        Documents
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

	# Frees the engine model of the corpus. The next question builds it again from all the documents.
	#
	#   returns    nothing
	#   note       Ring has no destructors, so a program that is done with a large corpus calls it;
	#              nothing is lost, since the texts stay in the object
	#   see        FreeLm
	#@ aka  Ring has no destructors -- free the engine model explicitly when done.
	def FreeModel()
		if @nModel != 0
			try
				stzengine_ngram_free(@nModel)
			catch
			done
			@nModel = 0
		ok

		# Frees the engine model of the corpus, under the name the language model part of this class used to have.
		#
		#   returns    nothing
		#   see        FreeModel
		def FreeLm()   # kept: the LM used to own the handle by this name
			This.FreeModel()

	# Returns how many words, repeats included, the whole corpus has.
	#
	#   returns    a number
	#   note       words are cut and lowercased by the engine, with Unicode rules
	#   see        VocabularySize, FreqOf
	#@ aka  -- vocabulary & frequency -------------------------------------------
	def NumberOfWords()
		return stzengine_ngram_token_count(This._ModelHandle())

	# Returns every distinct word of the corpus, lowercased.
	#
	#   returns    a list of texts, in no particular order
	#   note       for the words by rank use MostFrequent
	#   see        VocabularySize, MostFrequent
	def Vocabulary()
		return stzengine_ngram_vocab(This._ModelHandle())

	# Returns how many distinct words the corpus has.
	#
	#   returns    a number
	#   see        Vocabulary, NumberOfWords
	def VocabularySize()
		return stzengine_ngram_vocab_size(This._ModelHandle())

	# Returns how many times a word occurs in the whole corpus, ignoring case; 0 when it is absent.
	#
	#   pcWord     the word to count
	#   returns    a number
	#   note       counted in every document together; for one document use TfOf
	#   see        MostFrequent, NumberOfDocumentsWith
	def FreqOf(pcWord)
		return stzengine_ngram_uni_count(This._ModelHandle(), "" + pcWord)

	# Returns the n commonest words with their counts, the highest first.
	#
	#   n          how many words to return
	#   returns    a list of [ word, count ] pairs; [ ] when n is 0
	#   note       words with equal counts come in no fixed order
	#   see        FreqOf, Vocabulary
	#@ aka  top-n words by count, as [ word, count ] pairs (engine-sorted)
	def MostFrequent(n)
		return stzengine_ngram_most_frequent(This._ModelHandle(), n)

	# Returns the chance that pcW2 follows pcW1 in this corpus, smoothed so that a pair never seen still gets a small chance.
	#
	#   pcW1       the first word of the pair
	#   pcW2       the word that should follow it
	#   returns    a number between 0 and 1
	#   note       the smoothing is Laplace: (count of the pair + 1) / (count of pcW1 + vocabulary
	#              size)
	#   see        LogProbability, Perplexity
	#@ aka  -- the n-gram language model (Laplace-smoothed bigrams) --------------
	def BigramProbability(pcW1, pcW2)
		return stzengine_ngram_bigram_prob(This._ModelHandle(), "" + pcW1, "" + pcW2)

	# Returns the natural logarithm of the chance of a whole text under the bigram model; it is 0 or negative, and nearer 0 means likelier.
	#
	#   pcText     the text to score
	#   returns    a number, 0 or negative
	#   see        Perplexity, BigramProbability
	def LogProbability(pcText)
		return stzengine_ngram_log_prob(This._ModelHandle(), "" + pcText)

	# Returns how surprising a text is to the corpus, as exp of minus the average log chance per word pair; lower means more like the corpus.
	#
	#   pcText     the text to score
	#   returns    a number, 1 or more; 0 when the text has fewer than two words
	#   note       a text of 0 or 1 word answers 0, which reads as the best score and means no score
	#   see        LogProbability
	#@ aka  perplexity = exp( -avg log P ) -- LOWER means more in-domain. The scalar formula is Ring's to craft; the log-probability under it is the engine's.
	def Perplexity(pcText)
		_oT_ = new stzText("" + pcText)
		_nW_ = len(_oT_.Words())
		if _nW_ < 2
			return 0
		ok
		return exp( - This.LogProbability(pcText) / (_nW_ - 1) )

	# Returns in how many documents a word occurs at least once (its document frequency).
	#
	#   pcWord     the word to look for
	#   returns    a number
	#   see        IdfOf, FreqOf
	#@ aka  -- TF-IDF (the vectorizer feeding the ML floor) ----------------------
	def NumberOfDocumentsWith(pcWord)   # document frequency
		return stzengine_ngram_df(This._ModelHandle(), "" + pcWord)

	# Returns how many times a word occurs in one document, counted from 1.
	#
	#   pcWord     the word to count
	#   nDoc       the document number, from 1
	#   returns    a number; 0 when the word is absent or the document number is out of range
	#   note       a document number that does not exist (0 or too large) answers 0 and raises
	#              nothing
	#   see        TfIdfOf, FreqOf
	def TfOf(pcWord, nDoc)
		return stzengine_ngram_tf(This._ModelHandle(), "" + pcWord, nDoc)

	# Returns the smoothed inverse document frequency of a word: log of (1 + documents) / (1 + documents holding it), plus 1.
	#
	#   pcWord     the word whose rarity is asked
	#   returns    a number; the largest for a word that is in no document
	#   see        TfIdfOf, NumberOfDocumentsWith
	#@ aka  smoothed idf = log( (1+D) / (1+df) ) + 1 -- computed engine-side, so the formula lives in ONE place and TopTermsOf cannot drift from it.
	def IdfOf(pcWord)
		return stzengine_ngram_idf(This._ModelHandle(), "" + pcWord)

	# Returns the weight of a word in one document: its count there times its inverse document frequency.
	#
	#   pcWord     the word to weigh
	#   nDoc       the document number, from 1
	#   returns    a number
	#   see        TfOf, IdfOf, TopTermsOf
	def TfIdfOf(pcWord, nDoc)
		return This.TfOf(pcWord, nDoc) * This.IdfOf(pcWord)

	# Returns the n most distinctive words of one document, the highest TF-IDF weight first.
	#
	#   nDoc       the document number, from 1
	#   n          how many words to return
	#   returns    a list of [ word, weight ] pairs; [ ] when the document number does not exist
	#   note       fewer than n pairs when the document has fewer distinct words
	#   see        TfIdfOf
	#@ aka  the document's most DISTINCTIVE terms by TF-IDF (engine-sorted), as [ word, tfidf ] pairs
	def TopTermsOf(nDoc, n)
		return stzengine_ngram_top_terms(This._ModelHandle(), nDoc, n)
