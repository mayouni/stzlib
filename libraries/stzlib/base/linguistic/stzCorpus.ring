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
	@aUni = []        # [ word, count ] hash
	@aBi = []         # [ "w1 w2", count ] hash
	@nTokens = 0
	@bCounted = 0

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
		return This

	def Documents()
		return @acDocs

	def NumberOfDocuments()
		return len(@acDocs)

	#-- counting ----------------------------------------------------------

	def _EnsureCounts()
		if @bCounted
			return
		ok
		@aUni = []
		@aBi = []
		@nTokens = 0
		_nD_ = len(@acDocs)
		for _d_ = 1 to _nD_
			_oT_ = new stzText(@acDocs[_d_])
			_acW_ = _oT_.Words()
			_nW_ = len(_acW_)
			for _w_ = 1 to _nW_
				_cW_ = StzLower(_acW_[_w_])
				This._Bump(:uni, _cW_)
				@nTokens++
				if _w_ < _nW_
					This._Bump(:bi, _cW_ + " " + StzLower(_acW_[_w_ + 1]))
				ok
			next
		next
		@bCounted = 1

	def _Bump(pcWhich, pcKey)
		if pcWhich = :uni
			if HasKey(@aUni, pcKey)
				@aUni[pcKey] = @aUni[pcKey] + 1
			else
				@aUni[pcKey] = 1
			ok
		else
			if HasKey(@aBi, pcKey)
				@aBi[pcKey] = @aBi[pcKey] + 1
			else
				@aBi[pcKey] = 1
			ok
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

	def BigramProbability(pcW1, pcW2)
		This._EnsureCounts()
		_cW1_ = StzLower(ring_trim("" + pcW1))
		_cW2_ = StzLower(ring_trim("" + pcW2))
		_nBi_ = 0
		if HasKey(@aBi, _cW1_ + " " + _cW2_)
			_nBi_ = @aBi[_cW1_ + " " + _cW2_]
		ok
		_nUni_ = 0
		if HasKey(@aUni, _cW1_)
			_nUni_ = @aUni[_cW1_]
		ok
		_nV_ = len(@aUni)
		return (_nBi_ + 1) / (_nUni_ + _nV_)

	def LogProbability(pcText)
		This._EnsureCounts()
		_oT_ = new stzText("" + pcText)
		_acW_ = _oT_.Words()
		_nW_ = len(_acW_)
		if _nW_ < 2
			return 0
		ok
		_nLog_ = 0
		for _i_ = 1 to _nW_ - 1
			_nLog_ += log(This.BigramProbability(_acW_[_i_], _acW_[_i_ + 1]))
		next
		return _nLog_

	# perplexity = exp( -avg log P ) -- LOWER is more in-domain
	def Perplexity(pcText)
		_oT_ = new stzText("" + pcText)
		_nW_ = len(_oT_.Words())
		if _nW_ < 2
			return 0
		ok
		return exp( - This.LogProbability(pcText) / (_nW_ - 1) )
