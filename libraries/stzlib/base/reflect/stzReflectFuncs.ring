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
# NOTE: whole-file harvest -- grabs every def regardless of which class owns it.
# For multi-class files use _StzHarvestClass(file, name) instead.
func _StzHarvestMethods(pcFile)
	_aLines_ = str2list(read(pcFile))
	return _StzHarvestRange(_aLines_, 1, len(_aLines_))

# Harvest ONLY the methods of class pcName within pcFile (a file may hold several
# classes -- stzObject.ring alone holds many). Scans from that class's `class`
# line to the next `class`/`func` declaration. Empty pcName => whole file.
func _StzHarvestClass(pcFile, pcName)
	_aLines_ = str2list(read(pcFile))
	_nLen_ = len(_aLines_)
	if NOT (isString(pcName) and pcName != "")
		return _StzHarvestRange(_aLines_, 1, _nLen_)
	ok
	_cNL_ = lower(pcName)
	for _i_ = 1 to _nLen_
		if _StzIsClassLineNamed(trim(_aLines_[_i_]), _cNL_)
			_nEnd_ = _nLen_
			for _j_ = _i_ + 1 to _nLen_
				if _StzIsClassOrFuncDecl(trim(_aLines_[_j_]))
					_nEnd_ = _j_ - 1
					exit
				ok
			next
			return _StzHarvestRange(_aLines_, _i_ + 1, _nEnd_)
		ok
	next
	return []

# The shared harvest loop, over a line range [nStart, nEnd]. Tracks the enclosing
# SECTION title (from boxed `#==#` headers) so a method with no doc-comment of its
# own still gets a coarse semantic anchor -- e.g. every method under the "SENTIMENT
# (VADER)" box is at least tagged with that, far better than its name alone. This
# lifts undocumented methods library-wide with no per-method editing.
func _StzHarvestRange(paLines, nStart, nEnd)
	_aMethods_ = []
	_cDesc_ = ""
	_cSection_ = ""
	if nStart < 1 nStart = 1 ok
	if nEnd > len(paLines) nEnd = len(paLines) ok
	for _i_ = nStart to nEnd
		_cTrim_ = trim(paLines[_i_])
		if len(_cTrim_) >= 4 and lower(left(_cTrim_, 4)) = "def "
			_cName_ = _StzDefName(_cTrim_)
			if _cName_ != "" and left(_cName_, 1) != "_"
				_cD_ = trim(_cDesc_)
				if _cD_ = "" _cD_ = _cSection_ ok
				_aMethods_ + [ _cName_, _cD_ ]
			ok
			_cDesc_ = ""
		but len(_cTrim_) >= 1 and left(_cTrim_, 1) = "#"
			if right(_cTrim_, 1) = "#"   # a boxed line: a border OR a section title
				_cInner_ = ""
				if len(_cTrim_) >= 3 _cInner_ = trim(substr(_cTrim_, 2, len(_cTrim_) - 2)) ok
				_cTitle_ = _StzSectionTitle(_cInner_)
				if _cTitle_ != "" _cSection_ = _cTitle_ ok
				_cDesc_ = ""
			else
				_cDesc_ += " " + trim(substr(_cTrim_, 2, len(_cTrim_) - 1))
			ok
		else
			if _cTrim_ != "" _cDesc_ = "" ok   # code breaks the comment block
		ok
	next
	return _aMethods_

# Extract a section TITLE from the inner text of a boxed header line: strip the
# border runs (= - # * space/tab) off both ends; "" if only border chars remain
# (a plain separator). Keeps parentheticals/digits ("stemming (snowball, 25 ...)").
func _StzSectionTitle(pcInner)
	_c_ = pcInner
	while len(_c_) > 0 and _StzIsBorderChar(left(_c_, 1))
		_c_ = substr(_c_, 2, len(_c_) - 1)
	end
	while len(_c_) > 0 and _StzIsBorderChar(right(_c_, 1))
		_c_ = left(_c_, len(_c_) - 1)
	end
	if _StzHasLetter(_c_) return lower(_c_) ok
	return ""

func _StzIsBorderChar(pc)
	return pc = "=" or pc = "-" or pc = " " or pc = "#" or pc = "*" or pc = char(9)

func _StzHasLetter(pcStr)
	_n_ = len(pcStr)
	for _i_ = 1 to _n_
		_a_ = ascii(pcStr[_i_])
		if (_a_ >= 65 and _a_ <= 90) or (_a_ >= 97 and _a_ <= 122) return TRUE ok
	next
	return FALSE

# Harvest a class's FULL method surface: its own methods + everything it inherits
# up the domain chain (child overrides parent by name), STOPPING before the
# universal root stzObject -- whose common-ground/reflection methods (Doc/Ask/
# Content...) are not domain capability and would flood every class. This is what
# makes "explain an object AND ITS METHODS" complete: e.g. stzMatrix now surfaces
# the stzListOfLists ops it inherits. Returns [ [name, desc, ownerClass], ... ].
func _StzHarvestChain(pcName)
	_aOut_ = []
	_aSeen_ = []
	_cCur_ = pcName
	_nGuard_ = 0
	while isString(_cCur_) and _cCur_ != "" and _nGuard_ < 15
		_nGuard_++
		if lower(_cCur_) = "stzobject" exit ok
		_cSrc_ = _StzResolveSource(_cCur_)
		if _cSrc_ = "" or NOT fexists(_cSrc_) exit ok
		_aM_ = _StzHarvestClass(_cSrc_, _cCur_)
		_nM_ = len(_aM_)
		for _i_ = 1 to _nM_
			_cKey_ = lower(_aM_[_i_][1])
			if ring_find(_aSeen_, _cKey_) = 0
				_aSeen_ + _cKey_
				_aOut_ + [ _aM_[_i_][1], _aM_[_i_][2], _cCur_ ]
			ok
		next
		_cParent_ = _StzParentOf(_cCur_)
		if isString(_cParent_) and lower(_cParent_) = lower(_cCur_) exit ok
		_cCur_ = _cParent_
	end
	return _aOut_

# The parent class of pcName (the `from X` in its `class` decl), "" if none / root.
func _StzParentOf(pcName)
	_cSrc_ = _StzResolveSource(pcName)
	if _cSrc_ = "" or NOT fexists(_cSrc_) return "" ok
	_aLines_ = str2list(read(_cSrc_))
	_cNL_ = lower(pcName)
	_n_ = len(_aLines_)
	for _i_ = 1 to _n_
		_cT_ = trim(_aLines_[_i_])
		if _StzIsClassLineNamed(_cT_, _cNL_)
			_aTok_ = _StzWords(_cT_)
			if len(_aTok_) >= 4 and lower(_aTok_[3]) = "from"
				return _aTok_[4]
			ok
			return ""
		ok
	next
	return ""

# TRUE if a trimmed line is `class <pcNameLower> ...` (Ring allows `Class` too).
func _StzIsClassLineNamed(pcTrim, pcNameLower)
	if len(pcTrim) < 6 return FALSE ok
	if lower(left(pcTrim, 6)) != "class " return FALSE ok
	_aTok_ = _StzWords(pcTrim)
	if len(_aTok_) >= 2 and lower(_aTok_[2]) = pcNameLower return TRUE ok
	return FALSE

# TRUE if a trimmed line opens a new class or func declaration (block boundary).
func _StzIsClassOrFuncDecl(pcTrim)
	if len(pcTrim) >= 6 and lower(left(pcTrim, 6)) = "class " return TRUE ok
	if len(pcTrim) >= 5 and lower(left(pcTrim, 5)) = "func " return TRUE ok
	return FALSE

# Split a string on whitespace (space/tab/CR) into words.
func _StzWords(pcStr)
	_aOut_ = []
	_cCur_ = ""
	_n_ = len(pcStr)
	for _i_ = 1 to _n_
		_c_ = pcStr[_i_]
		if _c_ = " " or _c_ = char(9) or _c_ = char(13)
			if _cCur_ != ""
				_aOut_ + _cCur_
				_cCur_ = ""
			ok
		else
			_cCur_ += _c_
		ok
	next
	if _cCur_ != ""
		_aOut_ + _cCur_
	ok
	return _aOut_

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
	return _StzRankMethodTextsBonus(pcQuestion, paTexts, paVectors, n, [])

# As above, plus an optional per-text additive BONUS (paBonus[i], same length as
# paTexts). Callers use it to give an object's OWN methods a small prior over the
# generic ones it inherits: when you ask an object about ITSELF, its purpose-built
# methods should win near-ties against inherited utilities (a terse-named inherited
# method must not beat a well-matched own method on a stopword). The bonus is small,
# so it only tips genuine ties -- a strongly-matching inherited method still wins.
func _StzRankMethodTextsBonus(pcQuestion, paTexts, paVectors, n, paBonus)
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
	if isList(paBonus) and len(paBonus) = _nT_
		_ns_ = len(_aSc_)
		for _i_ = 1 to _ns_
			_aSc_[_i_][2] += paBonus[ _aSc_[_i_][1] ]
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
