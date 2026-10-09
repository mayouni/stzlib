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

# The last constrained run's numbers. Declared HERE, at load, rather than
# on first write: Ring raises R24 on reading a global that was never
# assigned, so a caller who asks StzLastGrammarRun() before any grammar
# has been used deserves zeros rather than an error.
$aStzLastGrammarRun = [ :judged = 0, :masked = 0, :steps = 0, :stalled = 0, :complete = 0 ]
# GK2b: the matmul verdicts are pushed into the neural DLL once -- see StzNeuralVariantsSync()
$bStzNeuralVariantsSynced_ = 0

# StzNeuralModelQ(cPath) -- construct a model object and load the GGUF at
# cPath. ONE creation function, named for its class + Q (the house rule).
func StzNeuralModelQ(pcPath)
	return new stzNeuralModel(pcPath)

# NOTE: there is no StzNeuralModelQ() global. "Using" a model IS the object's
# own act -- StzNeuralModelQ(cPath) constructs it and its LoadFrom() loads the
# GGUF into the engine's single active slot, which is what makes the text-meaning
# layer (stzText) and the similarity ops upgrade from lexical to semantic:
#     oModel = StzNeuralModelQ(cPath)      # construct + load (+ activate)
#     oModel.LoadFrom(cOtherPath)          # or point it at another GGUF later
# A global verb here would only obscure whose act it is.

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
	if StzHasNeuralModel() return 1 ok
	_d_ = StzModelsDir()
	if _d_ = "" or NOT direxists(_d_) return 0 ok
	_aE_ = dir(_d_)
	_n_ = len(_aE_)
	for _i_ = 1 to _n_
		if _aE_[_i_][2] = 0 and len(_aE_[_i_][1]) >= 5 and right(lower(_aE_[_i_][1]), 5) = ".gguf"
			StzNeuralModelQ(_d_ + "/" + _aE_[_i_][1])
			return StzHasNeuralModel()
		ok
	next
	return 0

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
#
# And one knob that is not about sampling at all:
#   [ :Grammar = cGBNF ]
# installs a GBNF grammar at the sampler, so a token whose bytes cannot
# continue it is never drawn. Read StzLastGrammarRun() afterwards for
# what masking did, and StzConstrainedDecodingStatus() for what it does
# NOT cover -- shape, never value, never truth.
func StzGenerateXT(pcPrompt, paOptions)
	if StzHasGenerativeModel() = 0
		return ""
	ok
	_nMax_ = 64
	_nTemp_ = 0
	_nTopP_ = 0.95
	_nTopK_ = 40
	_nSeed_ = 42
	_cGrammar_ = ""
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
				but _cK_ = "grammar"
					_cGrammar_ = "" + paOptions[_i_][2]
				ok
			ok
		next
	ok
	# --- GRAMMAR-CONSTRAINED DECODING -------------------------------
	# With :Grammar = <GBNF text>, a token whose bytes cannot continue
	# the grammar is never drawn -- the violation is UNEMITTABLE rather
	# than caught after the fact. The grammar constrains SHAPE only:
	# it cannot say "this number is between 0 and 130", and it cannot
	# make a wrong answer right. StzOutputSchemaQ(...).ToGBNF() writes
	# the text; UnenforcedByGrammar() lists what it does not carry.
	if _cGrammar_ != ""
		_rcG_ = StzEngineNeuralSetGrammar(_cGrammar_)
		if _rcG_ != 0
			stzraise("StzGenerateXT: the grammar was refused (code " +
				_rcG_ + ") -- " + StzEngineNeuralGrammarRefusal())
		ok
	ok

	_cOut_ = StzEngineNeuralGenerateXT(pcPrompt, _nMax_, _nTemp_, _nTopP_, _nTopK_, _nSeed_)

	# What masking actually did, read BEFORE the grammar is uninstalled --
	# a caller who cannot see the numbers cannot tell a constrained run
	# from an unconstrained one, and that is the claim this rung exists
	# to make checkable.
	if _cGrammar_ != ""
		$aStzLastGrammarRun = [
			:masked   = StzEngineNeuralGrammarMasked(),
			:judged   = StzEngineNeuralGrammarJudged(),
			:steps    = StzEngineNeuralGrammarSteps(),
			:stalled  = StzEngineNeuralGrammarStalled(),
			:complete = StzEngineNeuralGrammarComplete()
		]
		StzEngineNeuralClearGrammar()
	ok
	return _cOut_

	func @StzGenerateXT(pcPrompt, paOptions)
		return StzGenerateXT(pcPrompt, paOptions)

# TRUE when this build enforces a grammar AT THE SAMPLER. Ask before
# reporting an answer as grammar-constrained: a compiled grammar and a
# constrained sampler are two different things.
func StzConstrainedDecodingSupported()
	return StzEngineGbnfDecodingSupported()

# What constrained decoding does, and what it does NOT do. Read it once.
func StzConstrainedDecodingStatus()
	return StzEngineGbnfDecodingStatus()

#--- the grammar on its own, with no model in the way ------------------
# Checking a grammar, and asking whether a piece of text satisfies it,
# needs no vocabulary and no GGUF. So these three answer without one --
# which is also what lets a caller VALIDATE a grammar before spending a
# model call on it.
#
# They drive the same machine the sampler uses. That is safe because a
# generation call is synchronous: nothing runs between its tokens. Do not
# call them from a streaming loop opened with StzStartGeneration().

# "" when this build can enforce the grammar; otherwise the refusal,
# naming the construct it could not take.
func StzGrammarRefusal(pcGBNF)
	if StzEngineGrammarSet("" + pcGBNF) = 0
		return ""
	ok
	return StzEngineGrammarRefusal()

# Does cText satisfy the grammar WHOLE -- a complete sentence of it?
# A legal PREFIX is not enough: "city: Paris" alone answers 0 when the
# grammar also demands a country line.
func StzGrammarAccepts(pcGBNF, pcText)
	if StzEngineGrammarSet("" + pcGBNF) != 0
		stzraise("StzGrammarAccepts: " + StzEngineGrammarRefusal())
	ok
	if StzEngineGrammarAccept("" + pcText) = 0
		return 0
	ok
	return StzEngineGrammarCanEnd()

# Could cText still GROW into a sentence of the grammar? This is the
# question the sampler asks of every candidate token, and the answer that
# separates a legal prefix from a dead end.
func StzGrammarCouldContinue(pcGBNF, pcText)
	if StzEngineGrammarSet("" + pcGBNF) != 0
		stzraise("StzGrammarCouldContinue: " + StzEngineGrammarRefusal())
	ok
	return StzEngineGrammarCanAccept("" + pcText)

# The last constrained run, as numbers:
#   :judged   -- candidate tokens the grammar looked at
#   :masked   -- how many of them it refused
#   :steps    -- tokens actually emitted
#   :stalled  -- 1 when some step had NO legal token (generation stopped
#                there; it did not quietly emit something else)
#   :complete -- 1 when the grammar was SATISFIED where generation ended,
#                0 when the token budget cut it off mid-structure
func StzLastGrammarRun()
	if NOT isList($aStzLastGrammarRun)
		return [ :judged = 0, :masked = 0, :steps = 0, :stalled = 0, :complete = 0 ]
	ok
	return $aStzLastGrammarRun

# Ask with sampling options (ChatML-wrapped).
func StzAskModelXT(pcQuestion, paOptions)
	return StzGenerateXT(StzChatPrompt("", pcQuestion), paOptions)

# --- STREAMING: token-by-token generation ------------------------------
# StzStartGeneration(prompt, options) opens a session; each StzNextToken()
# returns the next decoded chunk ("" when finished) -- show progress,
# react mid-generation, or stop early by just not calling again.
#
# :Grammar is NOT accepted here, and is REFUSED rather than ignored. A
# streaming session has no end hook, so nothing would uninstall the
# grammar afterwards and the next unrelated generation would inherit it.
# Constrain a blocking call (StzGenerateXT) instead.
func StzStartGeneration(pcPrompt, paOptions)
	if isList(paOptions)
		_nG_ = len(paOptions)
		for _iG_ = 1 to _nG_
			if isList(paOptions[_iG_]) and len(paOptions[_iG_]) = 2 and
			   isString(paOptions[_iG_][1]) and lower(paOptions[_iG_][1]) = "grammar"
				stzraise("StzStartGeneration: :Grammar is not supported for a " +
					"STREAMING session -- there is no end hook to uninstall it, and " +
					"a grammar left installed would silently constrain the next " +
					"generation. Use StzGenerateXT([:Grammar = ...]) instead.")
			ok
		next
	ok
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
#
# pcUser is UNTRUSTED text and passes through StzChatSafeText first: it
# used to go between the markers as it came, so a user who typed
# <|im_end|> followed by <|im_start|>system wrote a system turn of their
# own. pcSystem is the developer's own text and is placed as given.
func StzChatPrompt(pcSystem, pcUser)
	if NOT isString(pcSystem) or pcSystem = ""
		pcSystem = "You are a helpful assistant. Answer briefly."
	ok
	return "<|im_start|>system" + char(10) + pcSystem + "<|im_end|>" + char(10) +
		"<|im_start|>user" + char(10) + StzChatSafeText(pcUser) + "<|im_end|>" + char(10) +
		"<|im_start|>assistant" + char(10)

# Untrusted text made safe to place inside a chat prompt: every control-
# token opener "<|" -- and "<" + U+FF5C, the full-width bar some model families
# use -- becomes "< |", so no special token (<|im_start|>, <|im_end|>,
# <|endoftext|>, <|eot_id|>, <|start_header_id|>, ...) can be written
# into the prompt by the text. The words stay readable; only the marker
# is broken. Deliberately wider than ChatML's three tokens: a model's
# special tokens share the opener, not a list we could keep current.
func StzChatSafeText(pcText)
	_c_ = "" + pcText
	_c_ = StzReplace(_c_, "<|", "< |")
	_c_ = StzReplace(_c_, "<" + char(239) + char(189) + char(156), "< " + char(239) + char(189) + char(156))
	return _c_

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
		# One engine call rather than a Ring loop over 384-1536 elements. The
		# engine's dot product is vectorised (phase 4 slice 6); more to the point,
		# a Ring `for` over an embedding is one interpreter step per dimension.
		#
		# This is the identity the comment above relies on: for L2-normalised
		# vectors the dot product IS the cosine. similarity.zig's test suite pins
		# that identity directly.
		return StzEngineSimDotProduct(_aA_, _aB_)
	ok
	_oA_ = new stzString(pcA)
	return _oA_.CosineSimilarityWith(pcB)

# Run one forward pass and copy the embedding out of the engine's single g_emb
# buffer into a fresh Ring list (so a second embed doesn't clobber the first).
func _StzEmbedInto(pcText)
	StzNeuralVariantsSync()
	_nDim_ = StzEngineNeuralEmbed(pcText)
	_aVec_ = []
	for i = 0 to _nDim_ - 1
		_aVec_ + StzEngineNeuralEmbedAt(i)
	next
	return _aVec_

# THE PERSISTED MATMUL VERDICTS reach the neural DLL here (GK2b). The foundry
# records a winner per (m, n, k) class under the op name "matmul" in the GPU
# calibration file (stz_gpu.ring replays it into stz_gpu.dll's table at load);
# the neural DLL owns its own device and its own table, so the rows are pushed
# across once, before the first embedding -- order-proof, whichever loader ran
# first. The backbone then compiles the winner with its bias fused.
func StzNeuralVariantsSync()
	if $bStzNeuralVariantsSynced_
		return
	ok
	$bStzNeuralVariantsSynced_ = 1
	# the persisted rows are read from the default calibration file first: it
	# loads without a device, fill-only, and a process that never opened the
	# stzGpu face has not replayed it yet
	StzGpuLoadCalibrationDefault()
	_aRows_ = StzGpuVariants()
	_n_ = len(_aRows_)
	for _i_ = 1 to _n_
		_r_ = _aRows_[_i_]
		if _r_[1] = "matmul" or _r_[1] = "attention"
			# rows are [ op, m, n, d, variant ] -- (m, n, k) for matmul,
			# (tokens, width, head_dim) for attention
			StzEngineNeuralVariantSet(_r_[1], _r_[2], _r_[3], _r_[4], _r_[5])
		ok
	next

# --- MODEL DIGESTS ----------------------------------------------------
# A GGUF file is opened only when its SHA-256 matches a RECORDED digest --
# checked in the engine before the GGUF parser reads a byte. A digest is
# recorded either in this process (StzExpectModelDigest, or automatically
# for a file this process exported) or in a SHA256SUMS file beside the
# model, in the standard sha256sum format. No recorded digest is a
# refusal: trusting a model is an explicit act, StzTrustModel().

# The file's SHA-256, 64 lowercase hex characters ("" if unreadable).
func StzModelDigest(pcPath)
	return StzEngineModelDigest("" + pcPath)

# Pin the digest a model must have, for this process -- the form to use
# with a digest published alongside the model.
func StzExpectModelDigest(pcPath, pcHex)
	return StzEngineModelExpect("" + pcPath, "" + pcHex) = 1

# TRUST a model as it is on disk now: record its digest in SHA256SUMS
# beside it (replacing any earlier line for the same file), so this and
# later processes may load it. Returns the digest. Do this for a file whose
# origin you have checked -- it is a statement, not a formality.
func StzTrustModel(pcPath)
	_cHex_ = StzModelDigest(pcPath)
	if _cHex_ = ""
		stzraise("Cannot trust '" + pcPath + "': the file cannot be read.")
	ok
	_cDir_ = StzEnginePathDirname("" + pcPath)
	if _cDir_ = ""  _cDir_ = "."  ok
	_cName_ = StzEnginePathBasename("" + pcPath)
	_cSums_ = _cDir_ + "/SHA256SUMS"
	_cOut_ = ""
	if fexists(_cSums_)
		_acLines_ = StzSplit(read(_cSums_), char(10))
		_n_ = len(_acLines_)
		for _i_ = 1 to _n_
			_cL_ = StzReplace(_acLines_[_i_], char(13), "")
			if ring_trim(_cL_) = ""  loop  ok
			_cTail_ = ring_trim(StzMidToEnd(_cL_, 65))
			if _cTail_ = _cName_ or _cTail_ = "*" + _cName_  loop  ok
			_cOut_ += _cL_ + char(10)
		next
	ok
	_cOut_ += _cHex_ + "  " + _cName_ + char(10)
	write(_cSums_, _cOut_)
	StzExpectModelDigest(pcPath, _cHex_)
	return _cHex_

# Why the last model load was refused: 0 ok, -1 unreadable or not a GGUF,
# -2 the digest does not match the recorded one, -3 no digest recorded.
func StzModelLoadStatus()
	return StzEngineNeuralModelLoadStatus()

# Loads a neural model from a GGUF file at runtime and exposes its architecture, embeddings, token ids and, for a decoder, generation.
#
# The model goes into the engine single active slot, so the text-meaning layer and the similarity
# operations upgrade from lexical to semantic while one is loaded. A file loads only when its
# SHA-256 digest was recorded as trusted (StzTrustModel, or StzExpectModelDigest for one process):
# otherwise LoadFrom answers FALSE and LoadStatus says why. With all-MiniLM-L6-v2 loaded it reports
# arch bert, embedding width 384, 6 layers, 12 heads and a vocabulary of 30522; EmbeddingOf then
# returns a unit-length 384-number vector, and SemanticSimilarityBetween is the dot product of two
# of them. An embedding model cannot generate: Generate and AnswerTo give an empty text unless a
# decoder model such as SmolLM2 is loaded. Everything answers empty or 0 while no model is loaded.
#
#   receiver   o1 = new stzNeuralModel("")
#   example    ? o1.IsLoaded()
#              #--> 0
#              ? @@(o1.EmbeddingOf("hello"))
#              #--> [ ]
#              ? o1.LoadFrom("no-such-model.gguf")
#              #--> 0
#              ? o1.LoadStatus()
#              #--> -1
#   see        stzNeuralChat, stzOutputSchema, stzLLMFunction
class stzNeuralModel from stzNeural

	@cPath = ""

	# Builds a model object, and loads the GGUF file at the given path when the path is a non-empty text.
	#
	#   pcPath     the path of a GGUF model file, or an empty text to build the object without
	#              loading
	#   returns    nothing; the object is built
	#   note       an unrecorded model digest refuses the load without an error: ask IsLoaded
	#              afterwards
	#   see        LoadFrom, IsLoaded
	def init(pcPath)
		if isString(pcPath) and pcPath != ""
			This.LoadFrom(pcPath)
		ok

	  #==========================================================#
	 #   LOAD / UNLOAD (runtime GGUF)                           #
	#==========================================================#
	# Loads a GGUF model file into the engine single active model slot, if its SHA-256 digest was recorded as trusted.
	#
	#   pcPath     the path of a GGUF model file
	#   returns    TRUE if the model loaded, FALSE if refused
	#   note       the path is kept even when the load was refused; trust a model first with
	#              StzTrustModel or StzExpectModelDigest
	#   warning    a refusal gives FALSE and no error; LoadStatus says why (-1 unreadable, -2 digest
	#              mismatch, -3 no digest recorded), and a path that is not text gives FALSE
	#   see        LoadStatus, IsLoaded, Unload
	#@ aka  (Named LoadFrom, not Load -- "Load" collides with Ring's load keyword.)
	def LoadFrom(pcPath)
		if NOT isString(pcPath) return 0 ok
		@cPath = pcPath
		# refused unless the file's digest was recorded -- see StzTrustModel
		return StzEngineNeuralModelLoad(pcPath) = 1

	# Returns why the last load was accepted or refused.
	#
	#   returns    a number: 0 loaded, -1 unreadable or not a GGUF, -2 digest differs from the
	#              recorded one, -3 no digest recorded
	#   see        LoadFrom, IsLoaded
	#@ aka  Why the last LoadFrom was refused (0 ok, -1 unreadable, -2 digest mismatch, -3 no recorded digest).
	def LoadStatus()
		return StzEngineNeuralModelLoadStatus()

		def Open(pcPath)
			return This.LoadFrom(pcPath)

	# TRUE if a model is loaded in the engine slot.
	#
	#   returns    TRUE or FALSE
	#   note       the slot is shared by the whole process, so it answers for any model loaded, not
	#              only this object
	#   see        LoadFrom, Unload
	def IsLoaded()
		return StzEngineNeuralModelLoaded() = 1

	# Frees the model from the engine slot and forgets the path.
	#
	#   returns    the model object itself, so calls chain
	#   note       the slot is shared by the whole process, so it frees whatever model is loaded
	#   see        LoadFrom, IsLoaded
	def Unload()
		StzEngineNeuralModelFree()
		@cPath = ""
		return This

	# Returns the path given to the last LoadFrom.
	#
	#   returns    a text; empty before any load and after Unload
	#   see        LoadFrom
	def Path()
		return @cPath

	  #==========================================================#
	 #   ARCHITECTURE + HYPERPARAMETERS                         #
	#==========================================================#
	# Returns the architecture name of the loaded model, such as bert.
	#
	#   returns    a text; empty when no model is loaded
	#   see        Content, EmbeddingDim
	def Arch()
		return StzEngineNeuralModelArch()

		def Architecture()
			return This.Arch()

	# Returns the width of the sentence embedding the loaded model produces.
	#
	#   returns    a number; 0 when no model is loaded, 384 for all-MiniLM-L6-v2
	#   see        EmbeddingOf, Content
	def EmbeddingDim()
		return StzEngineNeuralModelNEmbd()

	# Returns how many transformer layers the loaded model has.
	#
	#   returns    a number; 0 when no model is loaded
	#   see        NumberOfHeads, Content
	def NumberOfLayers()
		return StzEngineNeuralModelNLayers()

	# Returns how many attention heads each layer of the loaded model has.
	#
	#   returns    a number; 0 when no model is loaded
	#   see        NumberOfLayers, Content
	def NumberOfHeads()
		return StzEngineNeuralModelNHeads()

	# Returns the longest token sequence the loaded model accepts.
	#
	#   returns    a number; 0 when no model is loaded
	#   see        Tokenize, Content
	def ContextLength()
		return StzEngineNeuralModelNCtx()

	# Returns how many tokens the vocabulary of the loaded model holds.
	#
	#   returns    a number; 0 when no model is loaded
	#   see        Tokenize, Content
	def VocabSize()
		return StzEngineNeuralModelNVocab()

	# Returns how many weight tensors the loaded model file holds.
	#
	#   returns    a number; 0 when no model is loaded
	#   see        Content
	def NumberOfTensors()
		return StzEngineNeuralModelNTensors()

	# Returns the model architecture and hyperparameters as data.
	#
	#   returns    a list of [ key, value ] rows: arch, embedding_dim, layers, heads,
	#              context_length, vocab_size and tensors
	#   see        Show, Arch
	#@ aka  Content() = what the model IS: its architecture + hyperparameters as [key, value] data. Show() renders it (Softanza Show = visualize Content).
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

	# Prints a one-line summary of the loaded model, or says that none is loaded.
	#
	#   returns    the model object itself, so calls chain
	#   see        Content, IsLoaded
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
		# Runs the forward pass and returns the sentence embedding of a text, unit length.
		#
		#   pcText     the sentence to embed
		#   returns    a list of EmbeddingDim numbers; [ ] when no model is loaded, for a text that
		#              is not text and for an empty text
		#   note       the vector has length one, so the dot product of two of them is their cosine
		#   see        SemanticSimilarityBetween, Tokenize, EmbeddingDim
		#@ aka  EmbeddingOf(cText) -- run the BERT forward pass (embeddings + N transformer layers + mean-pool + L2-normalize) and return the sentence-embedding vector as a list of EmbeddingDim() floats (DATA).
		def EmbeddingOf(pcText)
			if NOT isString(pcText) return [] ok
			StzNeuralVariantsSync()
			_nDim_ = StzEngineNeuralEmbed(pcText)
			if _nDim_ = 0 return [] ok
			_aVec_ = []
			for i = 0 to _nDim_ - 1
				_aVec_ + StzEngineNeuralEmbedAt(i)
			next
			return _aVec_

			def Embedding(pcText)
				return This.EmbeddingOf(pcText)

		# Returns the WordPiece token ids of a text, with the start and end markers.
		#
		#   pcText     the text to split into tokens
		#   returns    a list of numbers; [ ] when no model is loaded or the text is not text
		#   note       an embedding model gives ids such as 101 first and 102 last
		#   see        EmbeddingOf, VocabSize
		#@ aka  WordPiece token ids for cText (with [CLS]..[SEP]) -- DATA.
		def Tokenize(pcText)
			if NOT isString(pcText) return [] ok
			_nCount_ = StzEngineNeuralTokenize(pcText)
			_aIds_ = []
			for i = 0 to _nCount_ - 1
				_aIds_ + StzEngineNeuralTokenAt(i)
			next
			return _aIds_

		# TRUE if the loaded model can generate text, which an embedding model cannot.
		#
		#   returns    TRUE or FALSE
		#   see        Generate, AnswerTo
		#@ aka  TRUE if this model can GENERATE text (a causal decoder).
		def IsGenerative()
			return StzHasGenerativeModel()

		# Continues a raw prompt greedily with the loaded generative model, up to a number of new tokens.
		#
		#   pcPrompt         the raw prompt text to continue
		#   pnMaxNewTokens   the most tokens to add, 64 when not a positive number
		#   returns          a text; empty when no generative model is loaded
		#   see              AnswerTo, IsGenerative
		#@ aka  Greedy generation from a raw prompt ("" when not generative).
		def Generate(pcPrompt, pnMaxNewTokens)
			return StzGenerate(pcPrompt, pnMaxNewTokens)

		# Asks the loaded instruct model a question, wrapped as a ChatML prompt, answering greedily.
		#
		#   pcQuestion       the question
		#   pnMaxNewTokens   the most tokens to add, 64 when not a positive number
		#   returns          a text; empty when no generative model is loaded
		#   note             AnswerToQ gives the answer as a stzString
		#   see              Generate, IsGenerative
		#@ aka  Ask the instruct model a question (ChatML-wrapped, greedy).
		def AnswerTo(pcQuestion, pnMaxNewTokens)
			return StzAskModel(pcQuestion, pnMaxNewTokens)

			def AnswerToQ(pcQuestion, pnMaxNewTokens)
				return new stzString(This.AnswerTo(pcQuestion, pnMaxNewTokens))

		# Returns the cosine similarity of the embeddings of two texts, from -1 to 1.
		#
		#   pcA        the first text
		#   pcB        the second text
		#   returns    a number; 0 when no model is loaded
		#   note       for all-MiniLM-L6-v2, a sentence with itself gives 1, two paraphrases about
		#              0.6 and unrelated sentences near 0
		#   see        EmbeddingOf, StzSemanticSimilarity
		#@ aka  Cosine similarity of two texts' embeddings, in [-1, 1] (DATA). The vectors are already L2-normalized, so cosine = dot product.
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

# Holds a multi-turn conversation with a loaded decoder model, processing the transcript once and appending each new turn to the cache.
#
# The first Say fills the cache with the system prompt and the user turn; each later Say appends
# only the new turn instead of re-reading the transcript. Sampling knobs (temperature, top-p, top-k,
# seed, token budget) set before a turn carry across the following turns. Text from the user is made
# safe before it enters the prompt, so a control token typed by the user cannot open a turn of its
# own. It needs a generative model loaded in the engine: with none, Say gives an empty text and
# records nothing.
#
#   receiver   o1 = new stzNeuralChat("be terse")
#   example    ? o1.NumberOfTurns()
#              #--> 0
#              ? len(o1.History())
#              #--> 0
#              ? o1.CachedTokens()
#              #--> 0
#   see        stzNeuralModel, StzNeuralChatQ, stzLLMFunction
class stzNeuralChat from stzObject

	@cSystem = ""
	@bStarted = 0
	@nMaxTokens = 96
	@nTemperature = 0
	@nTopP = 0.95
	@nTopK = 40
	@nSeed = 42
	@aTurns = []   # [ [role, text], ... ] the transcript (for Show/History)

	# Builds a chat session with a system prompt, or a default brief-answer prompt when none is given.
	#
	#   pcSystem   the system prompt that frames every answer
	#   returns    nothing; the object is built
	#   see        Say, SetTemperature
	def init(pcSystem)
		if isString(pcSystem) and pcSystem != ""
			@cSystem = pcSystem
		else
			@cSystem = "You are a helpful assistant. Answer briefly."
		ok

	# Sets the sampling temperature that later turns use; 0 is greedy and deterministic.
	#
	#   n          the temperature, from 0 upward
	#   returns    nothing
	#   note       the knobs carry across turns
	#   see        SetSeed, SetTopP, Say
	def SetTemperature(n) @nTemperature = n
	# Sets the nucleus-sampling mass that later turns use.
	#
	#   n          the cumulative probability to sample from, up to 1
	#   returns    nothing
	#   note       the default is 0.95
	#   see        SetTopK, SetTemperature
	def SetTopP(n) @nTopP = n
	# Sets how many of the likeliest tokens later turns sample from.
	#
	#   n          the number of candidate tokens
	#   returns    nothing
	#   note       the default is 40
	#   see        SetTopP, SetTemperature
	def SetTopK(n) @nTopK = n
	# Sets the random seed, so that the same turn with the same knobs gives the same text.
	#
	#   n          the seed number
	#   returns    nothing
	#   note       the default is 42
	#   see        SetTemperature
	def SetSeed(n) @nSeed = n
	# Sets the most tokens a reply may hold.
	#
	#   n          the token budget of one reply
	#   returns    nothing
	#   note       the default is 96
	#   see        Say
	def SetMaxTokens(n) @nMaxTokens = n

	# Sends a user turn and returns the assistant reply, adding only the new turn to the cached conversation.
	#
	#   pcUser     the user turn
	#   returns    a text, the reply; empty, with nothing recorded, when no generative model is
	#              loaded or the turn is not text
	#   note       the user text is made safe first, so a control token such as <
	#   see        History, NumberOfTurns, CachedTokens
	#@ aka  Say(userText) -> the assistant's reply. First call prefills system+user; later calls append only the new turn.
	def Say(pcUser)
		if StzHasGenerativeModel() = 0 return "" ok
		if NOT isString(pcUser) return "" ok
		@aTurns + [ "user", pcUser ]
		# the user's text is untrusted: no control token may pass through it
		_cSafe_ = StzChatSafeText(pcUser)
		if @bStarted = 0
			_cPrompt_ = "<|im_start|>system" + char(10) + @cSystem + "<|im_end|>" + char(10) +
				"<|im_start|>user" + char(10) + _cSafe_ + "<|im_end|>" + char(10) +
				"<|im_start|>assistant" + char(10)
			@bStarted = 1
			_cReply_ = StzEngineNeuralGenerateXT(_cPrompt_, @nMaxTokens,
				@nTemperature, @nTopP, @nTopK, @nSeed)
		else
			# the assistant's own last reply is already in the cache; close it
			# and open the next user+assistant turn -- APPEND, no reset
			_cCont_ = "<|im_end|>" + char(10) +
				"<|im_start|>user" + char(10) + _cSafe_ + "<|im_end|>" + char(10) +
				"<|im_start|>assistant" + char(10)
			_cReply_ = StzEngineNeuralGenerateCont(_cCont_, @nMaxTokens,
				@nTemperature, @nTopP, @nTopK, @nSeed)
		ok
		@aTurns + [ "assistant", _cReply_ ]
		return _cReply_

		def SayQ(pcUser)
			return new stzString(This.Say(pcUser))

	# Returns how many turns the transcript holds, counting user and assistant turns each.
	#
	#   returns    a number; 0 before the first answered turn
	#   see        History, Say
	def NumberOfTurns()
		return len(@aTurns)

	# Returns the transcript as rows, oldest first.
	#
	#   returns    a list of [ role, text ] rows, role being user or assistant
	#   see        NumberOfTurns, Content
	def History()
		return @aTurns

	# Returns how many tokens the conversation occupies in the engine cache.
	#
	#   returns    a number; 0 when nothing is cached
	#   see        Say
	#@ aka  how many tokens the conversation occupies in the KV cache
	def CachedTokens()
		return StzEngineNeuralGenCached()

	# Returns the transcript, as History does.
	#
	#   returns    a list of [ role, text ] rows
	#   see        History, Show
	def Content()
		return @aTurns

	# Prints the transcript, one line per turn as role: text.
	#
	#   returns    the chat itself, so calls chain
	#   see        History
	def Show()
		_n_ = len(@aTurns)
		for _i_ = 1 to _n_
			? @aTurns[_i_][1] + ": " + @aTurns[_i_][2]
		next
		return This
