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

# StzNeuralModelQ(cPath) -- construct a model object and load the GGUF at
# cPath. ONE creation function, named for its class + Q (the house rule).
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
# --- GENERATIVE model (llama-family decoder GGUF) --------------------------
# TRUE when the loaded model can GENERATE text (a causal decoder: SmolLM2,
# Qwen2.5, TinyLlama...). The same single engine slot as embeddings/NER.
func StzHasGenerativeModel()
	if StzEngineNeuralModelLoaded() = 0
		return 0
	ok
	return StzEngineNeuralHasGenerator()

	func @StzHasGenerativeModel()
		return StzHasGenerativeModel()

# Greedy (deterministic) generation from a RAW prompt. "" when no
# generative model is loaded.
func StzGenerate(pcPrompt, pnMaxNewTokens)
	if StzHasGenerativeModel() = 0
		return ""
	ok
	if NOT isNumber(pnMaxNewTokens) or pnMaxNewTokens < 1
		pnMaxNewTokens = 64
	ok
	return StzEngineNeuralGenerate(pcPrompt, pnMaxNewTokens)

# Generation with SAMPLING knobs, as a named-options list:
#   [ :MaxTokens = 64, :Temperature = 0, :TopP = 0.95, :TopK = 40, :Seed = 42 ]
# Temperature 0 = greedy (deterministic); a temperature with a SEED is
# reproducible too (same prompt + options + seed -> same text).
func StzGenerateXT(pcPrompt, paOptions)
	if StzHasGenerativeModel() = 0
		return ""
	ok
	_nMax_ = 64
	_nTemp_ = 0
	_nTopP_ = 0.95
	_nTopK_ = 40
	_nSeed_ = 42
	if isList(paOptions)
		_n_ = len(paOptions)
		for _i_ = 1 to _n_
			if isList(paOptions[_i_]) and len(paOptions[_i_]) = 2 and isString(paOptions[_i_][1])
				_cK_ = lower(paOptions[_i_][1])
				if _cK_ = "maxtokens"
					_nMax_ = paOptions[_i_][2]
				but _cK_ = "temperature"
					_nTemp_ = paOptions[_i_][2]
				but _cK_ = "topp"
					_nTopP_ = paOptions[_i_][2]
				but _cK_ = "topk"
					_nTopK_ = paOptions[_i_][2]
				but _cK_ = "seed"
					_nSeed_ = paOptions[_i_][2]
				ok
			ok
		next
	ok
	return StzEngineNeuralGenerateXT(pcPrompt, _nMax_, _nTemp_, _nTopP_, _nTopK_, _nSeed_)

	func @StzGenerateXT(pcPrompt, paOptions)
		return StzGenerateXT(pcPrompt, paOptions)

# Ask with sampling options (ChatML-wrapped).
func StzAskModelXT(pcQuestion, paOptions)
	return StzGenerateXT(StzChatPrompt("", pcQuestion), paOptions)

# --- STREAMING: token-by-token generation ------------------------------
# StzStartGeneration(prompt, options) opens a session; each StzNextToken()
# returns the next decoded chunk ("" when finished) -- show progress,
# react mid-generation, or stop early by just not calling again.
func StzStartGeneration(pcPrompt, paOptions)
	if StzHasGenerativeModel() = 0
		return 0
	ok
	_nMax_ = 64
	_nTemp_ = 0
	_nTopP_ = 0.95
	_nTopK_ = 40
	_nSeed_ = 42
	if isList(paOptions)
		_n_ = len(paOptions)
		for _i_ = 1 to _n_
			if isList(paOptions[_i_]) and len(paOptions[_i_]) = 2 and isString(paOptions[_i_][1])
				_cK_ = lower(paOptions[_i_][1])
				if _cK_ = "maxtokens"
					_nMax_ = paOptions[_i_][2]
				but _cK_ = "temperature"
					_nTemp_ = paOptions[_i_][2]
				but _cK_ = "topp"
					_nTopP_ = paOptions[_i_][2]
				but _cK_ = "topk"
					_nTopK_ = paOptions[_i_][2]
				but _cK_ = "seed"
					_nSeed_ = paOptions[_i_][2]
				ok
			ok
		next
	ok
	return StzEngineNeuralGenStart(pcPrompt, _nMax_, _nTemp_, _nTopP_, _nTopK_, _nSeed_)

# The next decoded token text of the open session ("" when finished).
func StzNextToken()
	if StzEngineNeuralGenNext() = 0
		return ""
	ok
	return StzEngineNeuralGenChunk()

func StzGenerationActive()
	return StzEngineNeuralGenActive()

# The ChatML prompt shape the small instruct models are trained on.
func StzChatPrompt(pcSystem, pcUser)
	if NOT isString(pcSystem) or pcSystem = ""
		pcSystem = "You are a helpful assistant. Answer briefly."
	ok
	return "<|im_start|>system" + char(10) + pcSystem + "<|im_end|>" + char(10) +
		"<|im_start|>user" + char(10) + pcUser + "<|im_end|>" + char(10) +
		"<|im_start|>assistant" + char(10)

# Ask the loaded instruct model a question (ChatML-wrapped, greedy).
func StzAskModel(pcQuestion, pnMaxNewTokens)
	return StzGenerate(StzChatPrompt("", pcQuestion), pnMaxNewTokens)

	func @StzAskModel(pcQuestion, pnMaxNewTokens)
		return StzAskModel(pcQuestion, pnMaxNewTokens)

# --- MULTI-TURN CHAT (KV reuse) ---------------------------------------
# A conversation that processes its history ONCE: the first turn prefills
# system+user, each later turn APPENDS to the KV cache instead of
# re-feeding the transcript. StzNeuralChatQ(cSystemPrompt) opens a session --
# ONE creation function, named for its class + Q (the house rule); pass "" for
# the default system prompt.
func StzNeuralChatQ(pcSystem)
	if ring_trim("" + pcSystem) = ""
		return new stzNeuralChat("You are a helpful assistant. Answer briefly.")
	ok
	return new stzNeuralChat(pcSystem)

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

		# TRUE if this model can GENERATE text (a causal decoder).
		def IsGenerative()
			return StzHasGenerativeModel()

		# Greedy generation from a raw prompt ("" when not generative).
		def Generate(pcPrompt, pnMaxNewTokens)
			return StzGenerate(pcPrompt, pnMaxNewTokens)

		# Ask the instruct model a question (ChatML-wrapped, greedy).
		def AnswerTo(pcQuestion, pnMaxNewTokens)
			return StzAskModel(pcQuestion, pnMaxNewTokens)

			def AnswerToQ(pcQuestion, pnMaxNewTokens)
				return new stzString(This.AnswerTo(pcQuestion, pnMaxNewTokens))

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


#---------------------------------------------------------------------------#
#  stzNeuralChat -- a multi-turn conversation with KV-cache reuse            #
#---------------------------------------------------------------------------#
# The transcript is processed ONCE: turn 1 prefills system + user; each
# Say() after that APPENDS only the new turn to the KV cache and generates.
# Sampling knobs carry across turns (SetTemperature/SetSeed/...).

class stzNeuralChat from stzObject

	@cSystem = ""
	@bStarted = 0
	@nMaxTokens = 96
	@nTemperature = 0
	@nTopP = 0.95
	@nTopK = 40
	@nSeed = 42
	@aTurns = []   # [ [role, text], ... ] the transcript (for Show/History)

	def init(pcSystem)
		if isString(pcSystem) and pcSystem != ""
			@cSystem = pcSystem
		else
			@cSystem = "You are a helpful assistant. Answer briefly."
		ok

	def SetTemperature(n) @nTemperature = n
	def SetTopP(n) @nTopP = n
	def SetTopK(n) @nTopK = n
	def SetSeed(n) @nSeed = n
	def SetMaxTokens(n) @nMaxTokens = n

	# Say(userText) -> the assistant's reply. First call prefills
	# system+user; later calls append only the new turn.
	def Say(pcUser)
		if StzHasGenerativeModel() = 0 return "" ok
		if NOT isString(pcUser) return "" ok
		@aTurns + [ "user", pcUser ]
		if @bStarted = 0
			_cPrompt_ = "<|im_start|>system" + char(10) + @cSystem + "<|im_end|>" + char(10) +
				"<|im_start|>user" + char(10) + pcUser + "<|im_end|>" + char(10) +
				"<|im_start|>assistant" + char(10)
			@bStarted = 1
			_cReply_ = StzEngineNeuralGenerateXT(_cPrompt_, @nMaxTokens,
				@nTemperature, @nTopP, @nTopK, @nSeed)
		else
			# the assistant's own last reply is already in the cache; close it
			# and open the next user+assistant turn -- APPEND, no reset
			_cCont_ = "<|im_end|>" + char(10) +
				"<|im_start|>user" + char(10) + pcUser + "<|im_end|>" + char(10) +
				"<|im_start|>assistant" + char(10)
			_cReply_ = StzEngineNeuralGenerateCont(_cCont_, @nMaxTokens,
				@nTemperature, @nTopP, @nTopK, @nSeed)
		ok
		@aTurns + [ "assistant", _cReply_ ]
		return _cReply_

		def SayQ(pcUser)
			return new stzString(This.Say(pcUser))

	def NumberOfTurns()
		return len(@aTurns)

	def History()
		return @aTurns

	# how many tokens the conversation occupies in the KV cache
	def CachedTokens()
		return StzEngineNeuralGenCached()

	def Content()
		return @aTurns

	def Show()
		_n_ = len(@aTurns)
		for _i_ = 1 to _n_
			? @aTurns[_i_][1] + ": " + @aTurns[_i_][2]
		next
		return This
