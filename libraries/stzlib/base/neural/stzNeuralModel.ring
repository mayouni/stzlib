#--------------------------------------------------------------#
#      SOFTANZA LIBRARY (V1.2) - STZNEURALMODEL                 #
#--------------------------------------------------------------#
#                                                              #
#   Description  : stzNeuralModel -- an instantiable NEURAL      #
#                  MODEL loaded at RUNTIME from a GGUF file       #
#                  (e.g. a BERT sentence-embedding model like     #
#                  all-MiniLM-L6-v2). Unlike the classical         #
#                  @embedFile'd tables, neural models are large    #
#                  and load from disk. Exposes the model's          #
#                  architecture + hyperparameters; (next milestone) #
#                  its embedding forward pass.                       #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#

# StzNeuralModel(cPath) / StzNeuralModelQ(cPath) -- construct a model object and
# load the GGUF at cPath (constructor globals: both return the object).
func StzNeuralModel(pcPath)
	return new stzNeuralModel(pcPath)

func StzNeuralModelQ(pcPath)
	return new stzNeuralModel(pcPath)

# StzUseNeuralModel(cPath) -- load a neural embedding model process-wide (into
# the engine's single active slot) so the text-meaning layer (stzText) and the
# string-list similarity ops transparently upgrade from lexical bag-of-words to
# true semantic embeddings. Returns the stzNeuralModel object.
func StzUseNeuralModel(pcPath)
	return new stzNeuralModel(pcPath)

# TRUE if a runtime neural embedding model is currently loaded and ready.
func StzHasNeuralModel()
	return StzEngineNeuralModelLoaded() = 1 and StzEngineNeuralModelNEmbd() > 0

# The Softanza models directory (sibling of engine/: libraries/stzlib/models).
func StzModelsDir()
	_e_ = $cEngineDir
	if isString(_e_) and len(_e_) >= 7 and right(_e_, 7) = "/engine"
		return left(_e_, len(_e_) - 7) + "/models"
	ok
	return ""

# StzAutoLoadNeuralModel() -- zero-config enablement: if no model is loaded, load
# the first *.gguf found in the models/ dir. Returns TRUE if a model is now ready.
# A user just drops a GGUF into libraries/stzlib/models/ and semantic retrieval
# turns on -- no path to hardcode.
func StzAutoLoadNeuralModel()
	if StzHasNeuralModel() return TRUE ok
	_d_ = StzModelsDir()
	if _d_ = "" or NOT direxists(_d_) return FALSE ok
	_aE_ = dir(_d_)
	_n_ = len(_aE_)
	for _i_ = 1 to _n_
		if _aE_[_i_][2] = 0 and len(_aE_[_i_][1]) >= 5 and right(lower(_aE_[_i_][1]), 5) = ".gguf"
			StzUseNeuralModel(_d_ + "/" + _aE_[_i_][1])
			return StzHasNeuralModel()
		ok
	next
	return FALSE

# TRUE if the loaded model carries a token-classification NER head (e.g. a
# bert-base-NER GGUF) -- then stzText.NamedEntities() upgrades to transformer NER.
func StzHasNeuralNerModel()
	return StzEngineNeuralModelLoaded() = 1 and StzEngineNeuralModelHasNer() = 1

# TRUE if the loaded model is a cross-encoder reranker (e.g. jina-reranker GGUF).
func StzHasRerankerModel()
	return StzEngineNeuralModelLoaded() = 1 and StzEngineNeuralModelHasReranker() = 1

# StzRerank(query, docs) -- rank docs by relevance to the query, [[doc, score],
# ...] sorted by DESCENDING relevance. Uses a CROSS-ENCODER (joint query+doc
# scoring, the accurate reranking approach) when a reranker head is loaded, else
# falls back to bi-encoder/lexical semantic similarity. The retrieve-then-rerank
# second stage.
func StzRerank(pcQuery, paDocs)
	if NOT (isString(pcQuery) and isList(paDocs)) return [] ok
	_bXEnc_ = StzHasRerankerModel()
	_aScored_ = []
	_nD_ = len(paDocs)
	for i = 1 to _nD_
		if isString(paDocs[i])
			if _bXEnc_
				_nS_ = StzEngineNeuralRerank(pcQuery, paDocs[i])
			else
				_nS_ = StzSemanticSimilarity(pcQuery, paDocs[i])
			ok
			_aScored_ + [ paDocs[i], _nS_ ]
		ok
	next
	# selection sort by descending score (doc count is small)
	_nSc_ = len(_aScored_)
	for i = 1 to _nSc_ - 1
		_iMax_ = i
		for j = i + 1 to _nSc_
			if _aScored_[j][2] > _aScored_[_iMax_][2] _iMax_ = j ok
		next
		if _iMax_ != i
			_tmp_ = _aScored_[i]
			_aScored_[i] = _aScored_[_iMax_]
			_aScored_[_iMax_] = _tmp_
		ok
	next
	return _aScored_

# StzSemanticSimilarity(cA, cB) -- similarity of two texts in [-1, 1]. Uses the
# loaded model's sentence embeddings (cosine == dot, since L2-normalized) when a
# model is present; otherwise degrades gracefully to lexical bag-of-words cosine.
# The single source of truth for "how similar do these two texts MEAN?".
func StzSemanticSimilarity(pcA, pcB)
	if NOT (isString(pcA) and isString(pcB)) return 0 ok
	if StzHasNeuralModel()
		_aA_ = _StzEmbedInto(pcA)
		_aB_ = _StzEmbedInto(pcB)
		_nLen_ = len(_aA_)
		if _nLen_ = 0 or len(_aB_) != _nLen_ return 0 ok
		_nDot_ = 0
		for i = 1 to _nLen_
			_nDot_ += _aA_[i] * _aB_[i]
		next
		return _nDot_
	ok
	_oA_ = new stzString(pcA)
	return _oA_.CosineSimilarityWith(pcB)

# Run one forward pass and copy the embedding out of the engine's single g_emb
# buffer into a fresh Ring list (so a second embed doesn't clobber the first).
func _StzEmbedInto(pcText)
	_nDim_ = StzEngineNeuralEmbed(pcText)
	_aVec_ = []
	for i = 0 to _nDim_ - 1
		_aVec_ + StzEngineNeuralEmbedAt(i)
	next
	return _aVec_

class stzNeuralModel from stzNeural

	@cPath = ""

	def init(pcPath)
		if isString(pcPath) and pcPath != ""
			This.LoadFrom(pcPath)
		ok

	  #==========================================================#
	 #   LOAD / UNLOAD (runtime GGUF)                           #
	#==========================================================#
	# (Named LoadFrom, not Load -- "Load" collides with Ring's load keyword.)
	def LoadFrom(pcPath)
		if NOT isString(pcPath) return FALSE ok
		@cPath = pcPath
		return StzEngineNeuralModelLoad(pcPath) = 1

		def Open(pcPath)
			return This.LoadFrom(pcPath)

	def IsLoaded()
		return StzEngineNeuralModelLoaded() = 1

	def Unload()
		StzEngineNeuralModelFree()
		@cPath = ""
		return This

	def Path()
		return @cPath

	  #==========================================================#
	 #   ARCHITECTURE + HYPERPARAMETERS                         #
	#==========================================================#
	def Arch()
		return StzEngineNeuralModelArch()

		def Architecture()
			return This.Arch()

	def EmbeddingDim()
		return StzEngineNeuralModelNEmbd()

	def NumberOfLayers()
		return StzEngineNeuralModelNLayers()

	def NumberOfHeads()
		return StzEngineNeuralModelNHeads()

	def ContextLength()
		return StzEngineNeuralModelNCtx()

	def VocabSize()
		return StzEngineNeuralModelNVocab()

	def NumberOfTensors()
		return StzEngineNeuralModelNTensors()

	# Content() = what the model IS: its architecture + hyperparameters as
	# [key, value] data. Show() renders it (Softanza Show = visualize Content).
	def Content()
		return [
			[ "arch", This.Arch() ],
			[ "embedding_dim", This.EmbeddingDim() ],
			[ "layers", This.NumberOfLayers() ],
			[ "heads", This.NumberOfHeads() ],
			[ "context_length", This.ContextLength() ],
			[ "vocab_size", This.VocabSize() ],
			[ "tensors", This.NumberOfTensors() ]
		]

		def Info()
			return This.Content()

	def Show()
		if NOT This.IsLoaded()
			? "stzNeuralModel [ not loaded ]"
			return This
		ok
		? "stzNeuralModel [ " + This.Arch() +
		  "  dim=" + This.EmbeddingDim() +
		  "  layers=" + This.NumberOfLayers() +
		  "  vocab=" + This.VocabSize() + " ]"
		return This

		  #==========================================================#
		 #   FORWARD PASS -- sentence embeddings                    #
		#==========================================================#
		# EmbeddingOf(cText) -- run the BERT forward pass (embeddings + N
		# transformer layers + mean-pool + L2-normalize) and return the
		# sentence-embedding vector as a list of EmbeddingDim() floats (DATA).
		def EmbeddingOf(pcText)
			if NOT isString(pcText) return [] ok
			_nDim_ = StzEngineNeuralEmbed(pcText)
			if _nDim_ = 0 return [] ok
			_aVec_ = []
			for i = 0 to _nDim_ - 1
				_aVec_ + StzEngineNeuralEmbedAt(i)
			next
			return _aVec_

			def Embedding(pcText)
				return This.EmbeddingOf(pcText)

		# WordPiece token ids for cText (with [CLS]..[SEP]) -- DATA.
		def Tokenize(pcText)
			if NOT isString(pcText) return [] ok
			_nCount_ = StzEngineNeuralTokenize(pcText)
			_aIds_ = []
			for i = 0 to _nCount_ - 1
				_aIds_ + StzEngineNeuralTokenAt(i)
			next
			return _aIds_

		# Cosine similarity of two texts' embeddings, in [-1, 1] (DATA). The
		# vectors are already L2-normalized, so cosine = dot product.
		def SemanticSimilarityBetween(pcA, pcB)
			_aA_ = This.EmbeddingOf(pcA)
			_aB_ = This.EmbeddingOf(pcB)
			_nLen_ = len(_aA_)
			if _nLen_ = 0 or len(_aB_) != _nLen_ return 0 ok
			_nDot_ = 0
			for i = 1 to _nLen_
				_nDot_ += _aA_[i] * _aB_[i]
			next
			return _nDot_
