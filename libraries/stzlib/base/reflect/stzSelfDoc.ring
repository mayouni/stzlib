#--------------------------------------------------------------#
#      SOFTANZA LIBRARY (V1.2) - STZSELFDOC                     #
#   An accelerative library for Ring applications, and more!    #
#--------------------------------------------------------------#
#                                                              #
#   Description  : stzSelfDoc -- SELF-DESCRIBING objects. It      #
#                  harvests a Softanza class's methods + their    #
#                  doc-comments straight from the SOURCE, then    #
#                  lets you ASK about them in plain English and   #
#                  EXPLAIN them -- powered by the neural tier's    #
#                  embeddings (2c) + cross-encoder (2h), NOT a     #
#                  heavy LLM. The knowledge already lives in the   #
#                  library; this indexes and queries it. Enables   #
#                  near-natural programming: describe intent, get   #
#                  the operation. Deterministic, zero hallucination.#
#   Author       : Mansour Ayouni (kalidianow@gmail.com)        #
#                                                              #
#--------------------------------------------------------------#

# StzDoc(cClassNameOrPath) -- the self-doc of a class (by name or source path).
func StzDoc(pcTarget)
	return new stzSelfDoc(pcTarget)

func StzSelfDoc(pcTarget)
	return new stzSelfDoc(pcTarget)

func StzSelfDocQ(pcTarget)
	return new stzSelfDoc(pcTarget)

class stzSelfDoc

	@cName = ""       # class name (e.g. "stzText")
	@cSource = ""     # resolved source file path
	@aMethods = []    # [ [name, description], ... ] harvested public methods
	@aVectors = []    # per-method embedding (lazy; only when a model is loaded)
	@bIndexed = FALSE

	def init(pcTarget)
		if NOT isString(pcTarget)
			StzRaise("stzSelfDoc needs a class name or a source path.")
		ok
		if _StzLooksLikePath(pcTarget)
			@cSource = pcTarget
			@cName = _StzNameFromPath(pcTarget)
		else
			@cName = pcTarget
			@cSource = _StzResolveSource(pcTarget)
		ok
		if @cSource != "" and fexists(@cSource)
			@aMethods = _StzHarvestMethods(@cSource)
		ok

	  #==========================================================#
	 #   INTROSPECTION                                          #
	#==========================================================#
	def ClassName()
		return @cName

	def Source()
		return @cSource

	def NumberOfMethods()
		return len(@aMethods)

	def MethodNames()
		_aMn_ = []
		_nN_ = len(@aMethods)
		for _i_ = 1 to _nN_
			_aMn_ + @aMethods[_i_][1]
		next
		return _aMn_

	def HasMethod(pcName)
		return This._IndexOf(pcName) > 0

	def DescriptionOf(pcName)
		_ix_ = This._IndexOf(pcName)
		if _ix_ = 0 return "" ok
		return @aMethods[_ix_][2]

	  #==========================================================#
	 #   EXPLAIN (deterministic, templated -- no model)        #
	#==========================================================#
	# ExplainMethod(name) -- a plain-language explanation of one method (DATA,
	# a string): its name + doc-comment (or a name-derived phrase if undocumented).
	def ExplainMethod(pcName)
		_ix_ = This._IndexOf(pcName)
		if _ix_ = 0
			return "No method '" + pcName + "' in " + @cName + "."
		ok
		_cD_ = @aMethods[_ix_][2]
		if _cD_ = ""
			_cD_ = "(" + _StzSplitCamel(@aMethods[_ix_][1]) + ")"
		ok
		return @aMethods[_ix_][1] + " -- " + _cD_

	def Show()
		? "stzSelfDoc [ " + @cName + " : " + len(@aMethods) + " methods ]"
		return This

	  #==========================================================#
	 #   ASK (semantic -- embeddings/reranker or lexical)      #
	#==========================================================#
	# Ask(question) -- the methods whose MEANING best matches a plain-English
	# question, as [ [name, score, description], ... ] best first (DATA). Uses the
	# loaded embedding model (2c) when present, else lexical similarity -- so it
	# works with zero setup and sharpens with a model. The near-natural-
	# programming entry: describe what you want, get the operation.
	def Ask(pcQuestion)
		return This.AskFor(pcQuestion, 3)

	def AskFor(pcQuestion, n)
		if NOT isString(pcQuestion) return [] ok
		_nM_ = len(@aMethods)
		if _nM_ = 0 return [] ok
		if NOT isNumber(n) or n < 1 n = 3 ok

		_aScored_ = []
		if StzHasNeuralModel()
			This._EnsureIndex()
			_qv_ = _StzEmbedInto(pcQuestion)
			for _i_ = 1 to _nM_
				_aScored_ + [ _i_, _StzDotVec(_qv_, @aVectors[_i_]) ]
			next
		else
			for _i_ = 1 to _nM_
				_aScored_ + [ _i_, StzSemanticSimilarity(pcQuestion, _StzMethodText(@aMethods[_i_])) ]
			next
		ok

		# selection sort by descending score, take top n
		_nS_ = len(_aScored_)
		_nTop_ = n
		if _nTop_ > _nS_ _nTop_ = _nS_ ok
		for _i_ = 1 to _nTop_
			_iMax_ = _i_
			for _j_ = _i_ + 1 to _nS_
				if _aScored_[_j_][2] > _aScored_[_iMax_][2] _iMax_ = _j_ ok
			next
			if _iMax_ != _i_
				_tmp_ = _aScored_[_i_]
				_aScored_[_i_] = _aScored_[_iMax_]
				_aScored_[_iMax_] = _tmp_
			ok
		next

		_aOut_ = []
		for _i_ = 1 to _nTop_
			_ix_ = _aScored_[_i_][1]
			_aOut_ + [ @aMethods[_ix_][1], _aScored_[_i_][2], @aMethods[_ix_][2] ]
		next
		return _aOut_

	# The single best-matching method name for a question (DATA, a string).
	def BestMethodFor(pcQuestion)
		_aR_ = This.AskFor(pcQuestion, 1)
		if len(_aR_) = 0 return "" ok
		return _aR_[1][1]

	#-- private -------------------------------------------------
	def _IndexOf(pcName)
		if NOT isString(pcName) return 0 ok
		_cL_ = lower(pcName)
		_nN_ = len(@aMethods)
		for _i_ = 1 to _nN_
			if lower(@aMethods[_i_][1]) = _cL_ return _i_ ok
		next
		return 0

	def _EnsureIndex()
		if @bIndexed return ok
		@aVectors = []
		_nN_ = len(@aMethods)
		for _i_ = 1 to _nN_
			@aVectors + _StzEmbedInto(_StzMethodText(@aMethods[_i_]))
		next
		@bIndexed = TRUE

#===================================================================#
#  GLOBAL HELPERS (kept out of class scope to dodge the len()/trim() #
#  R20 gotcha; also reusable by a future engine-side harvester)      #
#===================================================================#

# The text embedded/compared for a method: its name as words + its description.
func _StzMethodText(paMethod)
	_c_ = _StzSplitCamel(paMethod[1])
	if paMethod[2] != ""
		_c_ += ". " + paMethod[2]
	ok
	return _c_

# Dot product of two equal-length vectors (embeddings are L2-normalized).
func _StzDotVec(paA, paB)
	if NOT (isList(paA) and isList(paB)) return 0 ok
	_n_ = len(paA)
	if _n_ = 0 or len(paB) != _n_ return 0 ok
	_s_ = 0
	for _i_ = 1 to _n_
		_s_ += paA[_i_] * paB[_i_]
	next
	return _s_

# "MostSimilarByMeaning" -> "most similar by meaning" (better for embedding/match).
func _StzSplitCamel(pcName)
	_cOut_ = ""
	_n_ = len(pcName)
	for _i_ = 1 to _n_
		_c_ = pcName[_i_]
		_nC_ = ascii(_c_)
		if _i_ > 1 and _nC_ >= 65 and _nC_ <= 90
			_cOut_ += " "
		ok
		_cOut_ += _c_
	next
	return lower(_cOut_)

# Harvest [ [name, description], ... ] from a Softanza source file: each public
# `def Name(...)` with the doc-comment block immediately above it. Section header
# boxes (#===#) are not descriptions. Private methods (leading _) are skipped.
func _StzHarvestMethods(pcFile)
	_cContent_ = read(pcFile)
	_aLines_ = str2list(_cContent_)
	_aMethods_ = []
	_cDesc_ = ""
	_nLen_ = len(_aLines_)
	for _i_ = 1 to _nLen_
		_cTrim_ = trim(_aLines_[_i_])
		if len(_cTrim_) >= 4 and lower(left(_cTrim_, 4)) = "def "
			_cName_ = _StzDefName(_cTrim_)
			if _cName_ != "" and left(_cName_, 1) != "_"
				_aMethods_ + [ _cName_, trim(_cDesc_) ]
			ok
			_cDesc_ = ""
		but len(_cTrim_) >= 1 and left(_cTrim_, 1) = "#"
			if right(_cTrim_, 1) = "#"   # a boxed header/separator line
				_cDesc_ = ""
			else
				_cDesc_ += " " + trim(substr(_cTrim_, 2, len(_cTrim_) - 1))
			ok
		else
			if _cTrim_ != "" _cDesc_ = "" ok   # code breaks the comment block
		ok
	next
	return _aMethods_

func _StzDefName(pcDefLine)   # "def Name(pa, pb)" -> "Name"
	_cRest_ = trim(substr(pcDefLine, 4, len(pcDefLine) - 3))
	_cName_ = ""
	_n_ = len(_cRest_)
	for _i_ = 1 to _n_
		_c_ = _cRest_[_i_]
		if _c_ = "(" or _c_ = " " exit ok
		_cName_ += _c_
	next
	return _cName_

func _StzLooksLikePath(pcT)
	return substr(pcT, ".ring") > 0 or substr(pcT, "/") > 0 or substr(pcT, "\") > 0

func _StzNameFromPath(pcPath)
	# last path segment without extension
	_c_ = pcPath
	_p_ = max([ _StzLastPos(_c_, "/"), _StzLastPos(_c_, "\") ])
	if _p_ > 0 _c_ = substr(_c_, _p_ + 1, len(_c_) - _p_) ok
	_e_ = substr(_c_, ".ring")
	if _e_ > 0 _c_ = left(_c_, _e_ - 1) ok
	return _c_

func _StzLastPos(pcStr, pcCh)
	_pos_ = 0
	_n_ = len(pcStr)
	for _i_ = 1 to _n_
		if pcStr[_i_] = pcCh _pos_ = _i_ ok
	next
	return _pos_

# Softanza's base/ source dir, derived from the auto-discovered $cEngineDir.
func _StzBaseDir()
	_cE_ = $cEngineDir
	if NOT isString(_cE_) or _cE_ = "" return "" ok
	if len(_cE_) >= 7 and right(_cE_, 7) = "/engine"
		return left(_cE_, len(_cE_) - 7) + "/base"
	ok
	return _cE_ + "/../base"

# Resolve a class name to its source file by scanning the base/ subfolders for
# <name>.ring (Softanza's file-per-class convention).
func _StzResolveSource(pcName)
	_cBase_ = _StzBaseDir()
	if _cBase_ = "" return "" ok
	_cRoot_ = _cBase_ + "/" + pcName + ".ring"
	if fexists(_cRoot_) return _cRoot_ ok
	_aEntries_ = dir(_cBase_)
	_n_ = len(_aEntries_)
	for _i_ = 1 to _n_
		if _aEntries_[_i_][2] = 1   # a subdirectory
			_cCand_ = _cBase_ + "/" + _aEntries_[_i_][1] + "/" + pcName + ".ring"
			if fexists(_cCand_) return _cCand_ ok
		ok
	next
	return ""
