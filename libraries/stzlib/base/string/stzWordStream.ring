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

# Counts words over text fed in chunks, keeping only the table of distinct words in the engine, so a very large input costs only its vocabulary.
#
# Build one with new stzWordStream(), or StzWordStreamCSQ(1) for a case-sensitive count. Feed or
# FeedMany add chunks at any time; TopWords, WordsAndTheirCounts, MostFrequentWord and the totals
# can be asked between feeds and the feeding goes on. Words are cut by Unicode word rules
# (punctuation dropped, emoji not words, Hebrew and Arabic whole) and, by default, counted without
# regard to case. The counter lives in the engine: call Free when done. SetCaseSensitive discards
# what was fed, so set the case mode first.
#
#   receiver   o1 = new stzWordStream()
#   example    o1.Feed("the cat and the hat")
#              ? o1.TotalWords()
#              #--> 5
#              o1.Feed("THE end")
#              ? @@( o1.TopWords(2) )
#              #--> [ [ "the", 3 ], [ "cat", 1 ] ]
#              ? o1.DistinctWords()
#              #--> 5
#              o1.Free()
#   see        stzStringWords, stzCorpus
class stzWordStream from stzObject

	@pEngine = ""

	# Creates an empty word counter in the engine, case-insensitive by default, to be fed with chunks of text.
	#
	#   returns    nothing; the counter now exists
	#   warning    the counter lives in the engine until Free is called, since Ring has no
	#              destructors
	#   see        Feed, SetCaseSensitive, Free
	#@ aka  Default = case-INsensitive (folded counting). For case-sensitive accumulation use StzWordStreamCS(1) or .SetCaseSensitive(1) before feeding.
	def init()
		@pEngine = StzEngineStringWordStreamNew(0)

	# Chooses whether words that differ only by case count as different words, and starts a fresh empty counter.
	#
	#   pCaseSensitive   1 to count The and the apart, 0 to fold them
	#   returns          the same object, so calls chain
	#   note             StzWordStreamCS(1) builds a case-sensitive one in a single call
	#   warning          Discards everything fed so far: call it before the first Feed; after it
	#                    TotalWords answers 0
	#   see              Feed, StzWordStreamCS
	#@ aka  Reconfigure case-sensitivity. Only meaningful BEFORE any Feed -- it discards the (empty) accumulator and starts a fresh one.
	def SetCaseSensitive(pCaseSensitive)
		if @pEngine != ""
			StzEngineStringWordStreamFree(@pEngine)
		ok
		@pEngine = StzEngineStringWordStreamNew( @CaseSensitive(pCaseSensitive) )
		return This

	# Returns the engine handle of the counter, for the engine functions that take it.
	#
	#   returns    a handle, or "" after Free
	#   note       not meant for normal use
	#   see        Free
	def Engine()
		return @pEngine

	  #------------------#
	 #   FEEDING DATA    #
	#------------------#

	# Adds the words of a chunk of text to the counts, which accumulate over all the chunks.
	#
	#   pcChunk    a text
	#   returns    the same object, so calls chain
	#   note       FeedChunk and Add are the same method; words are cut by Unicode word rules, so
	#              punctuation is left out and emoji are not words
	#   see        FeedMany, TotalWords
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

	# Returns the n most frequent words fed so far, each with its count, the most frequent first.
	#
	#   n          how many words to return
	#   returns    a list of [ word, count ] pairs; [ ] before anything is fed
	#   note       with case folding a word is shown as it first appeared: feeding the cat, then
	#              The, gives the with 2
	#   see        WordsAndTheirCounts, MostFrequentWords
	#@ aka  [[word, count], ...] over EVERYTHING fed so far, top-N by count.
	def TopWords(n)
		return This._Drain( StzEngineStringWordStreamTop(@pEngine, n) )

	# Returns every different word fed so far with its count, in the order the words first appeared.
	#
	#   returns    a list of [ word, count ] pairs
	#   note       the counts add up to TotalWords
	#   see        TopWords, DistinctWords
	#@ aka  [[word, count], ...] over everything fed, in first-appearance order.
	def WordsAndTheirCounts()
		return This._Drain( StzEngineStringWordStreamTop(@pEngine, 0) )

	# Returns just the n most frequent words, without their counts, the most frequent first.
	#
	#   n          how many words to return
	#   returns    a list of texts
	#   see        TopWords, MostFrequentWord
	#@ aka  Just the words of the top-N (drops the counts).
	def MostFrequentWords(n)
		_aRes_ = This.TopWords(n)
		_aOut_ = []
		# NOT nL: Ring is case-insensitive, so that name IS the NL newline
		# constant, and this line replaced it with a number for the whole
		# process. Calling MostFrequentWords() left every later use of NL
		# raising "Bad parameter type!" somewhere else entirely.
		_nLen_ = len(_aRes_)
		for i = 1 to _nLen_
			_aOut_ + _aRes_[i][1]
		next
		return _aOut_

	# Returns the single most frequent word fed so far.
	#
	#   returns    a text; "" before anything is fed
	#   note       a tie goes to the word that appeared first
	#   see        MostFrequentWords
	def MostFrequentWord()
		_aRes_ = This.TopWords(1)
		if len(_aRes_) = 0
			return ""
		ok
		return _aRes_[1][1]

	# Returns how many words have been fed in all, repeats included.
	#
	#   returns    a number
	#   note       NumberOfWords is the same method; it answers 0 after Free
	#   see        DistinctWords
	#@ aka  Total tokens fed (with multiplicity).
	def TotalWords()
		return StzEngineStringWordStreamTotal(@pEngine)

		def NumberOfWords()
			return This.TotalWords()

	# Returns how many different words have been fed.
	#
	#   returns    a number
	#   note       VocabularySize and NumberOfDistinctWords are the same method
	#   see        TotalWords
	#@ aka  Size of the vocabulary (distinct words) accumulated so far.
	def DistinctWords()
		return StzEngineStringWordStreamDistinct(@pEngine)

		def VocabularySize()
			return This.DistinctWords()

		def NumberOfDistinctWords()
			return This.DistinctWords()

	  #------------------#
	 #   LIFECYCLE       #
	#------------------#

	# Releases the engine counter, which Ring cannot do by itself; safe to call twice.
	#
	#   returns    nothing
	#   note       afterwards the queries answer 0 or [ ] and Feed has no effect: do not use the
	#              object again
	#   see        Release
	#@ aka  Ring has no destructors -- free the engine-side accumulator explicitly when done (safe to call more than once).
	def Free()
		if @pEngine != ""
			StzEngineStringWordStreamFree(@pEngine)
			@pEngine = ""
		ok

		# Releases the engine counter, exactly as Free does.
		#
		#   returns    nothing
		#   see        Free
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
		_n_ = StzEngineWordFreqCount(pRes)
		for _i_ = 1 to _n_
			_pW_ = StzEngineWordFreqWord(pRes, _i_)
			_cW_ = StzEngineStringData(_pW_)
			StzEngineStringFree(_pW_)
			_aOut_ + [ _cW_, StzEngineWordFreqNum(pRes, _i_) ]
		next
		StzEngineWordFreqFree(pRes)
		return _aOut_
