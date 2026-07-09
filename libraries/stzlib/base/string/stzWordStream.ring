# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
#    SOFTANZA LIBRARY (Zdrive) - V1.0                              #
#    (c) Mansour Ayouni (kalidianow@gmail.com)                    #
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
#                                                                  #
#    stzWordStream -- streaming / incremental word-frequency       #
#                                                                  #
#    Bounded-memory word counting over text too large (or too      #
#    live) to hold at once. Feed chunks, query top-N / totals at   #
#    any point, keep feeding. State lives ENGINE-SIDE (Zig) and    #
#    is bounded by the vocabulary size, not the input size -- a    #
#    multi-GB log costs only its distinct-word table.              #
#                                                                  #
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

func StzWordStreamQ()
	return new stzWordStream()

	func StzWordStream()
		return new stzWordStream()

func StzWordStreamCSQ(pCaseSensitive)
	_oStream_ = new stzWordStream()
	_oStream_.SetCaseSensitive(pCaseSensitive)
	return _oStream_

	func StzWordStreamCS(pCaseSensitive)
		return StzWordStreamCSQ(pCaseSensitive)

class stzWordStream from stzObject

	@pEngine = NULL

	# Default = case-INsensitive (folded counting). For case-sensitive
	# accumulation use StzWordStreamCS(1) or .SetCaseSensitive(1) before feeding.
	def init()
		@pEngine = StzEngineStringWordStreamNew(0)

	# Reconfigure case-sensitivity. Only meaningful BEFORE any Feed -- it
	# discards the (empty) accumulator and starts a fresh one.
	def SetCaseSensitive(pCaseSensitive)
		if @pEngine != NULL
			StzEngineStringWordStreamFree(@pEngine)
		ok
		@pEngine = StzEngineStringWordStreamNew( @CaseSensitive(pCaseSensitive) )
		return This

	def Engine()
		return @pEngine

	  #------------------#
	 #   FEEDING DATA    #
	#------------------#

	def Feed(pcChunk)
		if isString(pcChunk)
			StzEngineStringWordStreamFeed(@pEngine, pcChunk)
		ok
		return This

		def FeedChunk(pcChunk)
			return This.Feed(pcChunk)

		def Add(pcChunk)
			return This.Feed(pcChunk)

	def FeedMany(paChunks)
		if isList(paChunks)
			_nLen_ = len(paChunks)
			for i = 1 to _nLen_
				if isString(paChunks[i])
					StzEngineStringWordStreamFeed(@pEngine, paChunks[i])
				ok
			next
		ok
		return This

		def FeedChunks(paChunks)
			return This.FeedMany(paChunks)

	  #------------------#
	 #   QUERYING       #
	#------------------#

	# [[word, count], ...] over EVERYTHING fed so far, top-N by count.
	def TopWords(n)
		return This._Drain( StzEngineStringWordStreamTop(@pEngine, n) )

	# [[word, count], ...] over everything fed, in first-appearance order.
	def WordsAndTheirCounts()
		return This._Drain( StzEngineStringWordStreamTop(@pEngine, 0) )

	# Just the words of the top-N (drops the counts).
	def MostFrequentWords(n)
		_aRes_ = This.TopWords(n)
		_aOut_ = []
		nL = len(_aRes_)
		for i = 1 to nL
			_aOut_ + _aRes_[i][1]
		next
		return _aOut_

	def MostFrequentWord()
		_aRes_ = This.TopWords(1)
		if len(_aRes_) = 0
			return ""
		ok
		return _aRes_[1][1]

	# Total tokens fed (with multiplicity).
	def TotalWords()
		return StzEngineStringWordStreamTotal(@pEngine)

		def NumberOfWords()
			return This.TotalWords()

	# Size of the vocabulary (distinct words) accumulated so far.
	def DistinctWords()
		return StzEngineStringWordStreamDistinct(@pEngine)

		def VocabularySize()
			return This.DistinctWords()

		def NumberOfDistinctWords()
			return This.DistinctWords()

	  #------------------#
	 #   LIFECYCLE       #
	#------------------#

	# Ring has no destructors -- free the engine-side accumulator explicitly
	# when done (safe to call more than once).
	def Free()
		if @pEngine != NULL
			StzEngineStringWordStreamFree(@pEngine)
			@pEngine = NULL
		ok

		def Release()
			This.Free()

	  #------------------#
	 #   PRIVATE        #
	#------------------#

	# Drain a StzWordFreqResult handle into [[word, count], ...] (same shape as
	# stzString.WordsAndTheirCounts) and free the result. The accumulator itself
	# is NOT consumed -- you can keep feeding and re-query.
	def _Drain(pRes)
		_aOut_ = []
		n = StzEngineWordFreqCount(pRes)
		for i = 1 to n
			pW = StzEngineWordFreqWord(pRes, i)
			_cW_ = StzEngineStringData(pW)
			StzEngineStringFree(pW)
			_aOut_ + [ _cW_, StzEngineWordFreqNum(pRes, i) ]
		next
		StzEngineWordFreqFree(pRes)
		return _aOut_
