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

# Embed through whatever model the engine currently holds -- the engine is
# single-model process-wide, so this is a free function, not a method that
# would copy a wrapper per call (the finder lesson). It stands ABOVE the
# class on purpose: in Ring a func written after a class in the same file
# becomes a METHOD of that class -- this one was, and was reachable only
# from inside the index (found by the GS4 guard, 2026-09-09).
func StzNeuralEmbeddingOf(pcText)
	StzNeuralVariantsSync()
	_nDim_ = StzEngineNeuralEmbed(pcText)
	if _nDim_ = 0 return [] ok
	_aVec_ = []
	for _i_ = 0 to _nDim_ - 1
		_aVec_ + StzEngineNeuralEmbedAt(_i_)
	next
	return _aVec_

class stzSemanticIndex from stzObject

	@acTexts = []
	@aVecs = []
	@nDim = 0
	@pDataset = ""
	# GS4 (SOFTANZA_GPU_PLAN.md): the GPU route. When the corpus earned it
	# -- the shared "pairdist" calibration, shaped or flat, consulted BEFORE
	# any device exists -- the vectors go resident on the device as f32 once,
	# and every search moves d floats in and k pairs out through the same
	# pairdist + top-k kernels the vector index seam runs. The CPU resident
	# dataset stays built: it is the truth and the fallback, and a refusal
	# anywhere on the GPU path drops to it silently, counted by the engine.
	@nGpuCorpus_ = 0
	@nGpuQuery_ = 0
	@nGpuDist_ = 0
	@bGpuTried_ = 0

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

	# Index a text with an embedding the CALLER already has -- another model,
	# a cache, a wire -- so the index never insists on embedding it again.
	# The vector must be L2-normalised (the score formula assumes it) and of
	# the index's dimension.
	def AddEmbedded(pcText, paVec)
		if NOT isString(pcText) or pcText = ""
			StzRaise("AddEmbedded: give me a non-empty string.")
		ok
		if NOT isList(paVec) or len(paVec) = 0
			StzRaise("AddEmbedded: give me the text's embedding as a list of numbers.")
		ok
		if @nDim = 0
			@nDim = len(paVec)
		but len(paVec) != @nDim
			StzRaise("AddEmbedded: this embedding has " + len(paVec) +
			         " dims, the index holds " + @nDim + ".")
		ok
		@acTexts + pcText
		@aVecs + paVec
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

	# The stored embeddings, 1-based rows -- so a caller (or a guard) can
	# recompute a cosine independently of the search path.
	def Vectors()
		return @aVecs

	# Is the corpus resident on the GPU right now? Silent seams still owe
	# an honest answer to whoever asks.
	def UsesGpu()
		return (@nGpuCorpus_ > 0)

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
		return This.SearchByVectorXT(_aQ_, n)

	# The same search from a query embedding the caller already holds (the
	# companion of AddEmbedded). ONE search path serves both doors: the
	# route -- CPU resident dataset or GPU resident corpus -- is decided
	# here and nowhere else.
	def SearchByVectorXT(paQ, n)
		if NOT isList(paQ) or len(paQ) != @nDim
			StzRaise("SearchByVector: the query embedding must have " + @nDim + " dims.")
		ok
		if NOT (isNumber(n) and n >= 1)
			StzRaise("SearchByVector: n must be a positive number.")
		ok
		if This.Count() = 0
			return []
		ok
		_aQ_ = paQ
		This._EnsureDataset()
		if @pDataset = ""
			return []
		ok
		# the GPU route, when the corpus is resident there; a refusal on
		# the way ("" back) drops the device buffers and the CPU answers
		if @nGpuCorpus_ > 0
			_aG_ = This._QueryGpu(_aQ_, n)
			if isList(_aG_)
				return _aG_
			ok
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
		# a new corpus re-opens the GPU question
		This._DropGpu()
		@bGpuTried_ = 0

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
		# THE FLATTENING TAX (2026-09-10): the vectors go to the resident dataset
		# and to the device upload as rows; both doorways walk them
		@pDataset = StzEngineClusterDataNew(@aVecs, _nN_, @nDim)
		This._EnsureGpu(@aVecs, _nN_)

	# ---- GS4: the GPU route -------------------------------------------------

	# Build-time gate, the vector index seam's shape exactly: the threshold
	# is consulted BEFORE the device (Init costs ~300 ms; a small corpus must
	# never pay it) -- shaped class first, flat line where the class was
	# never measured; then the device, the per-adapter truth, the canonical
	# gate, and the upload. One refusal anywhere = no GPU, no thrash.
	#
	# THE KEY IS THIS SEAM'S OWN, "knn_resident", NOT the GPU op's. A line
	# is a comparison against a CPU ALTERNATIVE, and this face's alternative
	# is the multicore tier's SIMD top-k (cluster.topK, M4), not the vector
	# index's scan the "pairdist" line was measured against. Measured
	# 2026-09-09 on the RTX 3050 at 384 dims: the GPU route LOSES to it at
	# n = 1,000, 4,000 and 16,000 (0.34x, 0.80x, 0.31x). So there is NO
	# seed: an uncalibrated key routes CPU by the engine's own rule, and
	# the seam stays dark until a calibration on some hardware finds a
	# win. test/neural/gs4_knn_ladder_probe.ring is that measurement.
	def _EnsureGpu(paFlat, nN)
		if @bGpuTried_
			return
		ok
		@bGpuTried_ = 1
		if StzEngineGpuCalibGet("knn_resident") = 0
			StzGpuLoadCalibrationDefault()
		ok
		if StzEngineGpuCalibRouteShaped("knn_resident", nN, @nDim) = 0
			return
		ok
		if StzEngineGpuIsAvailable() = 0
			StzEngineGpuInit($cStzGpuRuntime)
		ok
		if StzEngineGpuIsAvailable() = 1
			StzGpuLoadCalibrationForAdapter()
		ok
		if StzEngineGpuShouldDispatchShaped("knn_resident", nN, @nDim) = 0
			return
		ok
		@nGpuCorpus_ = StzEngineGpuBufferNew(nN * @nDim * 4)
		if @nGpuCorpus_ = 0
			return
		ok
		if StzEngineGpuBufferUploadList(@nGpuCorpus_, paFlat) != 0
			This._DropGpu()
			return
		ok
		@nGpuQuery_ = StzEngineGpuBufferNew(@nDim * 4)
		@nGpuDist_ = StzEngineGpuBufferNew(nN * 4)
		if @nGpuQuery_ = 0 or @nGpuDist_ = 0
			This._DropGpu()
		ok

	# One search on the resident corpus: query up (d floats), pairdist
	# (1 x n), top-k selected ENGINE-side. The kernel ranks on SQUARED
	# distance, so the cosine is 1 - d2/2 directly (the CPU path's KnnTopKOn
	# returns the euclidean distance and squares it). "" on any refusal.
	def _QueryGpu(paQ, nK)
		if StzEngineGpuBufferUploadList(@nGpuQuery_, paQ) != 0
			This._DropGpu()
			return ""
		ok
		_nN_ = len(@aVecs)
		if StzEngineGpuOpPairDist(@nGpuQuery_, @nGpuCorpus_, @nGpuDist_, 1, _nN_, @nDim) != 0
			This._DropGpu()
			return ""
		ok
		_aFlat_ = StzEngineGpuOpTopK(@nGpuDist_, _nN_, nK)
		if _aFlat_[1] != 0
			This._DropGpu()
			return ""
		ok
		_aOut_ = []
		_nP_ = (len(_aFlat_) - 1) / 2
		for _i_ = 1 to _nP_
			_nIdx_ = _aFlat_[(_i_ - 1) * 2 + 2] + 1     # engine 0-based
			_nD2_ = _aFlat_[(_i_ - 1) * 2 + 3]
			_aOut_ + [ @acTexts[_nIdx_], 1 - _nD2_ / 2, _nIdx_ ]
		next
		return _aOut_

	def _DropGpu()
		if @nGpuCorpus_ > 0
			StzEngineGpuBufferFree(@nGpuCorpus_)
			@nGpuCorpus_ = 0
		ok
		if @nGpuQuery_ > 0
			StzEngineGpuBufferFree(@nGpuQuery_)
			@nGpuQuery_ = 0
		ok
		if @nGpuDist_ > 0
			StzEngineGpuBufferFree(@nGpuDist_)
			@nGpuDist_ = 0
		ok
