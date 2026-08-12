#--------------------------------------------------------------#
#          SOFTANZA LIBRARY (V0.9) - STZSEMANTICINDEX          #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : Semantic search over texts -- the numeric   #
#                  retro's last item, closed. BERT sentence    #
#                  embeddings (stzNeuralModel / neural_embed)  #
#                  + a RESIDENT engine dataset + exact top-k.  #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#

# The pipeline, and why each piece is the one it is:
#
#   EMBED   stzNeuralModel.EmbeddingOf() -- the engine's full BERT forward
#           pass (WordPiece -> N transformer layers -> mean-pool -> L2
#           normalize). The engine holds ONE loaded model process-wide, so
#           this class does not own a model; it asks whatever is loaded.
#   STORE   vectors live in a RESIDENT engine dataset (ClusterDataNew) --
#           embedded once at Add time, marshalled once at Build time, and
#           queries never re-cross the corpus (the residency law: the drain
#           is the cost, so keep the data on the engine side).
#   SEARCH  exact top-k on the resident dataset (KnnTopKOn, the M4-threaded
#           scan). On L2-NORMALIZED vectors euclidean distance is monotone
#           with cosine -- d^2 = 2 - 2cos -- so the ranking is the cosine
#           ranking and the score reported IS the cosine: 1 - d^2/2.
#           Exact, not approximate: a corpus of thousands answers in
#           microseconds; the ANN forest (StzEngineAnnBuild) is the
#           documented upgrade path when a corpus outgrows that.
#
# Usage:
#   oM = new stzNeuralModel("models/all-MiniLM-L6-v2.Q8_0.gguf")
#   oIdx = new stzSemanticIndex([])
#   oIdx.AddTexts([ "The oven must be preheated...", "The compiler...", ... ])
#   aHits = oIdx.Search("How do I bake bread?", 3)
#   # -> [ [cText, nCosineScore, nPosition], ... ] best first

class stzSemanticIndex from stzObject

	@acTexts = []
	@aVecs = []
	@nDim = 0
	@pDataset = ""

	def init(paTexts)
		if isList(paTexts) and len(paTexts) > 0
			This.AddTexts(paTexts)
		ok

	  #-----------------------------------#
	 #   FEEDING THE INDEX               #
	#-----------------------------------#

	# Embeds at ADD time (the model must be loaded), so a bad text fails
	# loudly here and not in the middle of a search.
	def AddText(pcText)
		if NOT isString(pcText) or pcText = ""
			StzRaise("AddText: give me a non-empty string.")
		ok
		if NOT StzEngineNeuralModelLoaded()
			StzRaise("AddText: no embedding model is loaded. Load one first: " +
			         "new stzNeuralModel(cPathToGgufFile).")
		ok
		_aVec_ = StzNeuralEmbeddingOf(pcText)
		if len(_aVec_) = 0
			StzRaise("AddText: the model returned no embedding for this text.")
		ok
		if @nDim = 0
			@nDim = len(_aVec_)
		but len(_aVec_) != @nDim
			StzRaise("AddText: embedding dim changed mid-index (model swapped?).")
		ok
		@acTexts + pcText
		@aVecs + _aVec_
		This._InvalidateDataset()
		return This

	def AddTexts(paTexts)
		if NOT isList(paTexts)
			StzRaise("AddTexts: give me a list of strings.")
		ok
		_n_ = len(paTexts)
		for _i_ = 1 to _n_
			This.AddText(paTexts[_i_])
		next
		return This

	def Count()
		return len(@acTexts)

	def Texts()
		return @acTexts

	def EmbeddingDim()
		return @nDim

	  #-----------------------------------#
	 #   SEARCHING                       #
	#-----------------------------------#

	# Top-n semantically closest texts: [ [cText, nCosine, nPosition], ... ]
	# best first. nCosine is in [-1, 1]; 1 means "the same meaning" and a
	# query that IS one of the indexed texts scores ~1 against itself.
	def SearchXT(pcQuery, n)
		if NOT isString(pcQuery) or pcQuery = ""
			StzRaise("Search: give me a non-empty query string.")
		ok
		if NOT (isNumber(n) and n >= 1)
			StzRaise("Search: n must be a positive number.")
		ok
		if This.Count() = 0
			return []
		ok
		_aQ_ = StzNeuralEmbeddingOf(pcQuery)
		if len(_aQ_) = 0
			return []
		ok
		This._EnsureDataset()
		if @pDataset = ""
			return []
		ok
		# interleaved [idx, dist, idx, dist ...], idx 1-based, best first
		_aRaw_ = StzEngineKnnTopKOn(@pDataset, _aQ_, n)
		_aOut_ = []
		_nPairs_ = len(_aRaw_) / 2
		for _i_ = 1 to _nPairs_
			_nIdx_ = _aRaw_[2 * _i_ - 1]
			_nDist_ = _aRaw_[2 * _i_]
			# unit vectors: d^2 = 2 - 2 cos  ->  cos = 1 - d^2 / 2
			_nScore_ = 1 - (_nDist_ * _nDist_) / 2
			_aOut_ + [ @acTexts[_nIdx_], _nScore_, _nIdx_ ]
		next
		return _aOut_

	def Search(pcQuery)
		return This.SearchXT(pcQuery, 5)

	# The single best text (or "" on an empty index).
	def Closest(pcQuery)
		_aHits_ = This.SearchXT(pcQuery, 1)
		if len(_aHits_) = 0 return "" ok
		return _aHits_[1][1]

	  #-----------------------------------#
	 #   LIFECYCLE                       #
	#-----------------------------------#

	# Ring has no destructors (the residency lesson): free the resident
	# dataset explicitly when done with the index.
	def Close()
		This._InvalidateDataset()
		@acTexts = []
		@aVecs = []
		@nDim = 0

	def _InvalidateDataset()
		if @pDataset != ""
			StzEngineClusterDataFree(@pDataset)
			@pDataset = ""
		ok

	# Marshal the accumulated vectors into the resident dataset ONCE; every
	# search after that crosses only the query vector.
	def _EnsureDataset()
		if @pDataset != ""
			return
		ok
		_nN_ = len(@aVecs)
		if _nN_ = 0 or @nDim = 0
			return
		ok
		_aFlat_ = []
		for _i_ = 1 to _nN_
			for _j_ = 1 to @nDim
				_aFlat_ + @aVecs[_i_][_j_]
			next
		next
		@pDataset = StzEngineClusterDataNew(_aFlat_, _nN_, @nDim)

# Embed through whatever model the engine currently holds -- the engine is
# single-model process-wide, so this is a free function, not a method that
# would copy a wrapper per call (the finder lesson).
func StzNeuralEmbeddingOf(pcText)
	_nDim_ = StzEngineNeuralEmbed(pcText)
	if _nDim_ = 0 return [] ok
	_aVec_ = []
	for _i_ = 0 to _nDim_ - 1
		_aVec_ + StzEngineNeuralEmbedAt(_i_)
	next
	return _aVec_
