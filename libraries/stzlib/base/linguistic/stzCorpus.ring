# R3 -- stzCorpus: THE CORPORA SHELF'S ENTRY OBJECT (LAW 1)
# A corpus = a collection of documents the linguistic domain can count,
# query, and MODEL. Zero setup, zero downloads (the NLTK contrast:
# no nltk.download zoo -- your texts ARE the corpus).
#
#   oC = new stzCorpus([ cDoc1, cDoc2, ... ])   # or one string
#   oC.AddDocument(cText)
#   ? oC.Vocabulary()  ? oC.FreqOf("the")  ? oC.MostFrequent(5)
#
# N-GRAM LANGUAGE MODELING (the NLTK nltk.lm counterpart, floor tier):
#   ? oC.BigramProbability("the", "fox")   # Laplace-smoothed
#   ? oC.LogProbability("the fox jumps")   # sum of log bigram probs
#   ? oC.Perplexity("the fox jumps")       # the classic LM metric
# HONESTY: counts are Ring-side -- the small/mid-corpus floor. The
# engine-side counting tier (million-token corpora) is the next rung;
# the surface stays identical when it lands.

class stzCorpus from stzObject

	@acDocs = []
	@aUni = []        # [ word, count ] hash (vocabulary / frequency / TF-IDF)
	@aDocUni = []     # per-document [ word, count ] hashes (TF-IDF)
	@nTokens = 0
	@bCounted = 0

	@nLmHandle = 0    # engine-resident n-gram model (0 = not yet trained)

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
			@bCounted = 0
		ok

		def AddDocumentQ(pcText)
			This.AddDocument(pcText)
			return This

	def Documents()
		return @acDocs

	def NumberOfDocuments()
		return len(@acDocs)

	#-- counting ----------------------------------------------------------

	# Per-word and per-document unigram counts feed the vocabulary/frequency
	# stats and TF-IDF below. (The n-gram LM does NOT come through here -- it
	# is owned by the engine; see BigramProbability.)
	def _EnsureCounts()
		if @bCounted
			return
		ok
		@aUni = []
		@aDocUni = []
		@nTokens = 0
		_nD_ = len(@acDocs)
		for _d_ = 1 to _nD_
			_oT_ = new stzText(@acDocs[_d_])
			_acW_ = _oT_.Words()
			_nW_ = len(_acW_)
			_aDU_ = []
			for _w_ = 1 to _nW_
				_cW_ = StzLower(_acW_[_w_])
				This._Bump(:uni, _cW_)
				@nTokens++
				if HasKey(_aDU_, _cW_)
					_aDU_[_cW_] = _aDU_[_cW_] + 1
				else
					_aDU_[_cW_] = 1
				ok
			next
			@aDocUni + _aDU_
		next
		@bCounted = 1

	def _Bump(pcWhich, pcKey)
		if HasKey(@aUni, pcKey)
			@aUni[pcKey] = @aUni[pcKey] + 1
		else
			@aUni[pcKey] = 1
		ok

	def NumberOfWords()
		This._EnsureCounts()
		return @nTokens

	def Vocabulary()
		This._EnsureCounts()
		return keys(@aUni)

	def VocabularySize()
		return len(This.Vocabulary())

	def FreqOf(pcWord)
		This._EnsureCounts()
		_cW_ = StzLower(ring_trim("" + pcWord))
		if HasKey(@aUni, _cW_)
			return @aUni[_cW_]
		ok
		return 0

	def MostFrequent(n)
		This._EnsureCounts()
		_aPairs_ = []
		_nLen_ = len(@aUni)
		for _i_ = 1 to _nLen_
			_aPairs_ + [ @aUni[_i_][1], @aUni[_i_][2] ]
		next
		# insertion-sort descending by count (small vocab floor)
		for _i_ = 2 to _nLen_
			_aE_ = _aPairs_[_i_]
			_j_ = _i_ - 1
			while _j_ >= 1
				if _aPairs_[_j_][2] < _aE_[2]
					_aPairs_[_j_ + 1] = _aPairs_[_j_]
					_j_--
				else
					exit
				ok
			end
			_aPairs_[_j_ + 1] = _aE_
		next
		_aOut_ = []
		_nTake_ = n
		if _nTake_ > _nLen_
			_nTake_ = _nLen_
		ok
		for _i_ = 1 to _nTake_
			_aOut_ + _aPairs_[_i_]
		next
		return _aOut_

	#-- the n-gram language model (Laplace-smoothed bigrams) --------------
	#
	# The ENGINE owns this model, end to end. The corpus is counted in a Zig
	# hash map (O(tokens)); a Ring hashlist would be a linear scan per token
	# (~O(tokens * vocab)) and cannot carry a real corpus. Ring is a thin
	# consumer here: it hands the engine the raw documents and asks questions.
	# The engine tokenises, lowercases (Unicode-correct, via utf8proc) and
	# counts -- Ring never touches the tokens.
	#
	#   P(w2|w1) = (count(w1 w2) + 1) / (count(w1) + V)   -- Laplace smoothing

	def BigramProbability(pcW1, pcW2)
		return stzengine_ngram_bigram_prob(This._LmHandle(), "" + pcW1, "" + pcW2)

	def LogProbability(pcText)
		return stzengine_ngram_log_prob(This._LmHandle(), "" + pcText)

	# perplexity = exp( -avg log P ) -- LOWER means more in-domain. The scalar
	# formula is Ring's to craft; the log-probability under it is the engine's.
	def Perplexity(pcText)
		_oT_ = new stzText("" + pcText)
		_nW_ = len(_oT_.Words())
		if _nW_ < 2
			return 0
		ok
		return exp( - This.LogProbability(pcText) / (_nW_ - 1) )

	# The engine-resident model, trained on first use. The engine is a HARD
	# dependency for this heavy work: if its DLL is not loaded, the model is
	# simply unavailable -- we raise a clear message rather than fall back to
	# counting a corpus in Ring.
	def _LmHandle()
		if @nLmHandle != 0
			return @nLmHandle
		ok
		try
			@nLmHandle = stzengine_ngram_train(JoinXT(@acDocs, nl))
		catch
			stzraise("The n-gram language model needs the stz_natlang engine (stz_natlang.dll is not loaded).")
		done
		return @nLmHandle

	# Ring has no destructors -- free the engine model explicitly when done.
	def FreeLm()
		if @nLmHandle != 0
			try
				stzengine_ngram_free(@nLmHandle)
			catch
			done
			@nLmHandle = 0
		ok

	#-- TF-IDF (R4 step 0: the vectorizer feeding the ML floor) -----------

	def TfOf(pcWord, nDoc)
		This._EnsureCounts()
		_cW_ = StzLower(ring_trim("" + pcWord))
		if nDoc < 1 or nDoc > len(@aDocUni)
			return 0
		ok
		if HasKey(@aDocUni[nDoc], _cW_)
			return @aDocUni[nDoc][_cW_]
		ok
		return 0

	def IdfOf(pcWord)
		This._EnsureCounts()
		_cW_ = StzLower(ring_trim("" + pcWord))
		_nIn_ = 0
		_nD_ = len(@aDocUni)
		for _d_ = 1 to _nD_
			if HasKey(@aDocUni[_d_], _cW_)
				_nIn_++
			ok
		next
		# smoothed idf -- never divides by zero, never negative
		return log( (1 + _nD_) / (1 + _nIn_) ) + 1

	def TfIdfOf(pcWord, nDoc)
		return This.TfOf(pcWord, nDoc) * This.IdfOf(pcWord)

	# the document's most DISTINCTIVE terms (not just frequent ones)
	def TopTermsOf(nDoc, n)
		This._EnsureCounts()
		if nDoc < 1 or nDoc > len(@aDocUni)
			return []
		ok
		_aDU_ = @aDocUni[nDoc]
		_aPairs_ = []
		_nLen_ = len(_aDU_)
		for _i_ = 1 to _nLen_
			_aPairs_ + [ _aDU_[_i_][1], This.TfIdfOf(_aDU_[_i_][1], nDoc) ]
		next
		for _i_ = 2 to _nLen_
			_aE_ = _aPairs_[_i_]
			_j_ = _i_ - 1
			while _j_ >= 1
				if _aPairs_[_j_][2] < _aE_[2]
					_aPairs_[_j_ + 1] = _aPairs_[_j_]
					_j_--
				else
					exit
				ok
			end
			_aPairs_[_j_ + 1] = _aE_
		next
		_aOut_ = []
		_nTake_ = n
		if _nTake_ > _nLen_
			_nTake_ = _nLen_
		ok
		for _i_ = 1 to _nTake_
			_aOut_ + _aPairs_[_i_]
		next
		return _aOut_
