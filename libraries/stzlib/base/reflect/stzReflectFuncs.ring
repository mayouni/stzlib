#--------------------------------------------------------------#
#      SOFTANZA LIBRARY (V1.2) - STZ REFLECT FUNCS              #
#--------------------------------------------------------------#
#   Shared, pure-function helpers for the reflection domain     #
#   (stzSelfDoc + stzLibDoc): source harvesting, class->source  #
#   resolution, method-text building, and the semantic RANKING  #
#   brain (reranker > embeddings > lexical). Kept in a class-    #
#   free file loaded BEFORE the reflect classes so BOTH can call #
#   them -- a `func` defined after a `class` is not visible to   #
#   another file's class. Also dodges the class-scope len()/     #
#   trim() R20 gotcha.                                           #
#--------------------------------------------------------------#

# Session cache for class-name -> source-file resolution (top-level init: reading
# an uninitialized $global raises R24, so it must exist before any func runs).
$aStzClassSrcCache = []

func _StzMethodText(paMethod)
	_c_ = _StzSplitCamel(paMethod[1])
	if paMethod[2] != ""
		_c_ += ". " + paMethod[2]
	ok
	return _c_

# The runtime class name of an object. A GLOBAL wrapper because inside a class
# with a ClassName() method, a bare `classname(This)` resolves to that method
# (case-insensitive) and raises R20; here at global scope it's the builtin.
func _StzClassNameOf(pObj)
	return classname(pObj)

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

# The SHARED ranking brain (used by stzSelfDoc AND stzLibDoc). Score `paTexts`
# (each a method's "name-as-words + description") against a question with the best
# available model, newest-first strategy:
#   - a RERANKER head loaded -> lexical-narrow to a pool, then CROSS-ENCODE that
#     pool (retrieve-then-rerank; needs only the reranker, never two models);
#   - an EMBEDDING model + a prebuilt vector index -> bi-encoder cosine;
#   - neither -> lexical bag-of-words cosine (zero-setup).
# Returns [[idx, score], ...] sorted desc, top n.
func _StzRankMethodTexts(pcQuestion, paTexts, paVectors, n)
	_nT_ = len(paTexts)
	_aSc_ = []
	if StzHasRerankerModel()
		_aCand_ = _StzLexicalTopKIdx(pcQuestion, paTexts, 25)
		_nc_ = len(_aCand_)
		for _i_ = 1 to _nc_
			_idx_ = _aCand_[_i_]
			_aSc_ + [ _idx_, StzEngineNeuralRerank(pcQuestion, paTexts[_idx_]) ]
		next
	but StzHasNeuralModel() and len(paVectors) = _nT_
		_qv_ = _StzEmbedInto(pcQuestion)
		for _i_ = 1 to _nT_
			_aSc_ + [ _i_, _StzDotVec(_qv_, paVectors[_i_]) ]
		next
	else
		_oQ_ = new stzString(pcQuestion)
		for _i_ = 1 to _nT_
			_aSc_ + [ _i_, _oQ_.CosineSimilarityWith(paTexts[_i_]) ]
		next
	ok
	return _StzTopNScored(_aSc_, n)

# Model-free lexical prefilter: indices of the top-k texts by bag-of-words cosine.
func _StzLexicalTopKIdx(pcQuestion, paTexts, k)
	_oQ_ = new stzString(pcQuestion)
	_aSc_ = []
	_n_ = len(paTexts)
	for _i_ = 1 to _n_
		_aSc_ + [ _i_, _oQ_.CosineSimilarityWith(paTexts[_i_]) ]
	next
	_aTop_ = _StzTopNScored(_aSc_, k)
	_aIdx_ = []
	_nt_ = len(_aTop_)
	for _i_ = 1 to _nt_
		_aIdx_ + _aTop_[_i_][1]
	next
	return _aIdx_

# Top-n of [idx, score] pairs by descending score (selection sort; small n).
func _StzTopNScored(paScored, n)
	_aP_ = paScored
	_nn_ = len(_aP_)
	_nTop_ = n
	if _nTop_ > _nn_ _nTop_ = _nn_ ok
	for _i_ = 1 to _nTop_
		_iMax_ = _i_
		for _j_ = _i_ + 1 to _nn_
			if _aP_[_j_][2] > _aP_[_iMax_][2] _iMax_ = _j_ ok
		next
		if _iMax_ != _i_
			_t_ = _aP_[_i_]
			_aP_[_i_] = _aP_[_iMax_]
			_aP_[_iMax_] = _t_
		ok
	next
	_aOut_ = []
	for _i_ = 1 to _nTop_ _aOut_ + _aP_[_i_] next
	return _aOut_

# Resolve a class name to its source file (cached per session). Fast path:
# Softanza's file-per-class convention (<name>.ring in a base subfolder).
# Fallback: scan each subfolder's .ring files for a `class <name>` declaration,
# so classes whose FILE name differs from the class name resolve too (e.g.
# stzListOfStrings lives in stzStringList.ring, stzChar in stzStringChar.ring).
func _StzResolveSource(pcName)
	_cKey_ = lower(pcName)
	_nc_ = len($aStzClassSrcCache)
	for _i_ = 1 to _nc_
		if $aStzClassSrcCache[_i_][1] = _cKey_ return $aStzClassSrcCache[_i_][2] ok
	next
	_cPath_ = _StzResolveSourceScan(pcName)
	$aStzClassSrcCache + [ _cKey_, _cPath_ ]
	return _cPath_

func _StzResolveSourceScan(pcName)
	_cBase_ = _StzBaseDir()
	if _cBase_ = "" return "" ok
	_cRoot_ = _cBase_ + "/" + pcName + ".ring"
	if fexists(_cRoot_) return _cRoot_ ok
	_aEntries_ = dir(_cBase_)
	_n_ = len(_aEntries_)
	# fast path: file named exactly like the class
	for _i_ = 1 to _n_
		if _aEntries_[_i_][2] = 1
			_cCand_ = _cBase_ + "/" + _aEntries_[_i_][1] + "/" + pcName + ".ring"
			if fexists(_cCand_) return _cCand_ ok
		ok
	next
	# fallback: content scan for `class <name>` (file name != class name)
	_cNameLower_ = lower(pcName)
	for _i_ = 1 to _n_
		if _aEntries_[_i_][2] = 1
			_cHit_ = _StzScanFolderForClass(_cBase_ + "/" + _aEntries_[_i_][1], _cNameLower_)
			if _cHit_ != "" return _cHit_ ok
		ok
	next
	return ""

func _StzScanFolderForClass(pcFolder, pcNameLower)
	_aF_ = dir(pcFolder)
	_n_ = len(_aF_)
	for _i_ = 1 to _n_
		if _aF_[_i_][2] = 0 and _StzEndsWith(lower(_aF_[_i_][1]), ".ring")
			_cPath_ = pcFolder + "/" + _aF_[_i_][1]
			if _StzFileHasClass(lower(read(_cPath_)), pcNameLower)
				return _cPath_
			ok
		ok
	next
	return ""

# TRUE if lowercased content declares `class <name>` (name followed by a word
# boundary, so "stzListOfStrings" doesn't match "stzListOfStringsError").
func _StzFileHasClass(pcContentLower, pcNameLower)
	_needle_ = "class " + pcNameLower
	if substr(pcContentLower, _needle_ + " ") > 0 return TRUE ok
	if substr(pcContentLower, _needle_ + nl) > 0 return TRUE ok
	if substr(pcContentLower, _needle_ + char(13)) > 0 return TRUE ok
	if substr(pcContentLower, _needle_ + char(9)) > 0 return TRUE ok
	return FALSE

func _StzEndsWith(pcStr, pcSuffix)
	_ls_ = len(pcSuffix)
	if len(pcStr) < _ls_ return FALSE ok
	return right(pcStr, _ls_) = pcSuffix
