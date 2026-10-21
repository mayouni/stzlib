# Shared by the engine-generation guards (pool, window, termination).
#
# The engine has ONE model slot, and StzAutoLoadNeuralModel() takes the first
# *.gguf in dir() order -- the embedding model, on Windows. A guard that is
# about a particular DECODER must therefore load that decoder by name, and
# SKIP, saying so, when the file is not on disk (*.gguf is git-ignored; see
# models/MODELS.md for what each is and where it comes from).
#
# Load AFTER stzBase.ring. Globals and functions use the $_mp / _mp prefix.

$_mpModelsDir = "../../../models/"

# The file name of the first model whose name contains cNeedle, or "".
func _mpFind(cNeedle)
	_aE_ = []
	try _aE_ = dir($_mpModelsDir) catch done
	_n_ = len(_aE_)
	for _i_ = 1 to _n_
		if _aE_[_i_][2] = 0 and right(lower(_aE_[_i_][1]), 5) = ".gguf" and
		   StzFindFirst(lower(cNeedle), lower(_aE_[_i_][1])) > 0
			return _aE_[_i_][1]
		ok
	next
	return ""

# Load the model whose name contains cNeedle into the single slot.
# TRUE when a generative model is now resident.
func _mpLoad(cNeedle)
	_cF_ = _mpFind(cNeedle)
	if _cF_ = "" return 0 ok
	StzNeuralModelQ($_mpModelsDir + _cF_)
	return StzHasGenerativeModel()

# n sentences of filler, each a fixed ~14 tokens, none of which names the secret.
func _mpFiller(nSentences)
	_c_ = ""
	for _i_ = 1 to nSentences
		_c_ += "The tide table for the harbour lists the hour of every high water. "
	next
	return _c_

# The secret-word probe: a SYSTEM message at the head, filler, the question last.
# A model that reads the whole prompt answers PINEAPPLE; a model whose prompt
# lost its head cannot.
func _mpSecretPrompt(nFiller)
	_cSys_ = "The secret word is PINEAPPLE. When asked for the secret word, answer with exactly that word and nothing else."
	_cUser_ = _mpFiller(nFiller) + "What is the secret word?"
	return StzChatPrompt(_cSys_, _cUser_)

# Token count of a prompt, by the generator's own tokenizer.
func _mpTokens(cPrompt)
	return StzEngineNeuralGenTokenize(cPrompt)

# Ask the secret-word probe with nFiller sentences of filler; answer at most
# nMax tokens. Returns [ nPromptTokens, cAnswer ].
func _mpAsk(nFiller, nMax)
	_cP_ = _mpSecretPrompt(nFiller)
	_nT_ = _mpTokens(_cP_)
	_cA_ = StzGenerate(_cP_, nMax)
	return [ _nT_, _cA_ ]

func _mpLines(cText)
	# the non-blank lines of cText
	_aOut_ = []
	_aL_ = split(cText, char(10))
	_n_ = len(_aL_)
	for _i_ = 1 to _n_
		if len(trim(_aL_[_i_])) > 0 add(_aOut_, trim(_aL_[_i_])) ok
	next
	return _aOut_

func _mpMostRepeated(cText)
	# how many times the most repeated non-blank line occurs
	_aL_ = _mpLines(cText)
	_nBest_ = 0
	_n_ = len(_aL_)
	for _i_ = 1 to _n_
		_c_ = 0
		for _j_ = 1 to _n_
			if _aL_[_j_] = _aL_[_i_] _c_++ ok
		next
		if _c_ > _nBest_ _nBest_ = _c_ ok
	next
	return _nBest_


# Ask a Qwen3 chat model with thinking switched off (the empty think block), greedy.
func _mpQwen3Ask(cQuestion, nMax)
	_cP_ = "<|im_start|>user" + char(10) + cQuestion + "<|im_end|>" + char(10) + "<|im_start|>assistant" + char(10) + "<think>" + char(10) + char(10) + "</think>" + char(10) + char(10)
	return StzGenerate(_cP_, nMax)


# Ask a Granite chat model (its own role markers), greedy.
func _mpGraniteAsk(cQuestion, nMax)
	_cP_ = "<|start_of_role|>user<|end_of_role|>" + cQuestion + "<|end_of_text|>" + char(10) + "<|start_of_role|>assistant<|end_of_role|>"
	return StzGenerate(_cP_, nMax)
