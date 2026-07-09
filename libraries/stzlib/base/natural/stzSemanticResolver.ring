#---------------------------------------------------------------------------#
#  stzSemanticResolver -- ONE lexicon shared by the natural-programming     #
#  stack (stzNatural execution) and the reflection stack (Ask/Explain)      #
#                                                                           #
#  THE UNIFICATION PROTOTYPE. Softanza held the same lexical fact --        #
#  "these surface words mean this canonical action" -- in three copies:     #
#                                                                           #
#     1. stzNatural's :semantic_mappings ("uppercase" -> METHOD_UPPERCASE)  #
#     2. stzNaturalCode's _ActionsXT form glossary (Uppercase, Uppercased,  #
#        IsUppercased, InUppercase, Uppercasing -- one action, five forms)  #
#     3. the #@ aka retrieval tags in class sources ("all caps, capitals")  #
#                                                                           #
#  This file merges the three into ONE semantic-ID-keyed lexicon, then      #
#  exposes StzResolveSemantic(word): the fallback stzNatural consults for   #
#  words missing from its dictionary. Lexical IDF scoring decides first     #
#  (deterministic, no model needed); when a neural model is loaded, an      #
#  embedding rescue catches paraphrases that share no surface token.        #
#                                                                           #
#  Net effect: Naturally("Create a string with 'softanza' Capitals it")     #
#  executes METHOD_UPPERCASE although "capitals" appears nowhere in the     #
#  semantic dictionary -- it is recovered from the Uppercase #@ aka tags.   #
#---------------------------------------------------------------------------#

$aStzSemLexicon = []        # [ [ cSemanticId, cBagOfWords ], ... ]
$bStzSemLexiconBuilt = FALSE
$aStzSemResolveMemo = []    # [ [ cWord, cResolvedId ], ... ] (failures memoized as "")

$aStzSemHarvestRecs = []    # cached reflect harvest [ name, desc, aka, owner, class ]
$bStzSemHarvested = FALSE
$bStzSemOpsGrown = FALSE    # $aSemanticOperations grown from the harvest yet?
$aStzSemExactNames = []     # [ [ lowered stz_method, semantic_id ], ... ]
$aStzSemOpIds = []          # flat id list backing _StzSemOpKnown (ring_find speed)
$nStzSemCacheSig = 0        # cache signature (combined source sizes)
$aStzSemLangLex = []        # multilingual packs: [ [ cCode, aBags, aExact ], ... ]

#--

# The reflect harvest of the three natural-facing classes, cached once and
# shared by the operation growth AND the lexicon build.

func _StzSemHarvest()
	if $bStzSemHarvested
		return $aStzSemHarvestRecs
	ok
	_aCls_ = [ "stzString", "stzList", "stzNumber" ]
	for _i_ = 1 to 3
		_aH_ = _StzHarvestChain(_aCls_[_i_])
		_nH_ = len(_aH_)
		for _j_ = 1 to _nH_
			_aRec_ = _aH_[_j_]
			while len(_aRec_) < 4
				_aRec_ + ""
			end
			_aRec_ + _aCls_[_i_]
			$aStzSemHarvestRecs + _aRec_
		next
	next
	$bStzSemHarvested = TRUE
	return $aStzSemHarvestRecs

# GROW $aSemanticOperations FROM THE HARVEST. Every ACTIVE-form method of
# stzString / stzList / stzNumber with arity <= 2 becomes an executable
# METHOD_* operation -- the active form is exactly Naturally()'s semantic
# model (transform one object through steps), so passives, predicates,
# fluents and the other forms stay out. Hand-authored operations are never
# overridden. Also (re)builds the exact-name map used by the resolver.

func StzGrowSemanticOperations()

	if $bStzSemOpsGrown
		return
	ok
	$bStzSemOpsGrown = TRUE

	# flat id list -- _StzSemOpKnown must stay O(ring_find), not a hashlist
	# scan, or growth goes quadratic over ~2000 candidates
	$aStzSemOpIds = []
	_nOps_ = len($aSemanticOperations)
	for _i_ = 1 to _nOps_
		$aStzSemOpIds + $aSemanticOperations[_i_][:semantic_id]
	next

	# warm start: grown ops + final lexicon bags persisted under doc/
	# (harvesting + arity-scanning three big sources costs seconds; the
	# cache signature is the combined source size, so any edit rebuilds)
	$nStzSemCacheSig = _StzSemCacheSig()
	if _StzSemLoadCache($nStzSemCacheSig)
		_StzSemBuildExactMap()
		return
	ok

	_aRecs_ = _StzSemHarvest()
	_nR_ = len(_aRecs_)

	# CONSTRUCT-AND-VERIFY: only names that are REAL methods of a live
	# instance may become operations (the harvest can carry phantom names
	# from nested defs and parent-file noise -- calling those would R14).
	_aLive_ = []
	_aLive_ + [ "stzstring", _StzSemMethodsOf("new stzString('')") ]
	_aLive_ + [ "stzlist",   _StzSemMethodsOf("new stzList([])") ]
	_aLive_ + [ "stznumber", _StzSemMethodsOf("new stzNumber(0)") ]

	# arity maps per owner class, built lazily (one source pass each)
	_aArity_ = []    # [ [ ownerLower, aMap ], ... ]

	for _i_ = 1 to _nR_
		_aRec_ = _aRecs_[_i_]
		_cName_ = _aRec_[1]

		if NOT isalpha(_cName_) or StzLen(_cName_) < 3
			loop
		ok
		# Ring/class plumbing is never a natural action
		if ring_find([ "init", "operator", "braceend", "bracestart" ], lower(_cName_)) > 0
			loop
		ok
		# The function-forms grammar decides the operation KIND:
		#   active / deep / plural      -> "action" (mutates the object)
		#   passive / predicate / IsNot -> "query"  (RETURNS a value: the
		#      result concept -- "Is it empty", "its Reversed copy")
		#   fluent (Q) is excluded: its purpose is chaining, and natural
		#      sequencing already chains; extended/conditional/statement
		#      (XT/W/X) carry special parameter grammars -- out for now.
		_aForm_ = _StzFormOf(_cName_)
		_cKind_ = ""
		if ring_find([ "active", "deep", "plural" ], _aForm_[1]) > 0
			_cKind_ = "action"
		but ring_find([ "passive", "predicate", "negative" ], _aForm_[1]) > 0
			_cKind_ = "query"
		ok
		if _cKind_ = ""
			loop
		ok
		# must be callable on a live instance of the harvested class
		_aClsMeths_ = []
		_nLv_ = len(_aLive_)
		for _v_ = 1 to _nLv_
			if _aLive_[_v_][1] = lower(_aRec_[5])
				_aClsMeths_ = _aLive_[_v_][2]
				exit
			ok
		next
		if ring_find(_aClsMeths_, lower(_cName_)) = 0
			loop
		ok

		_cId_ = "METHOD_" + upper(_cName_)
		_nAt_ = ring_find($aStzSemOpIds, _cId_)   # index-aligned with ops
		if _nAt_ > 0
			# same verb proven callable on ANOTHER class (RemoveDuplicates
			# lives on both stzString and stzList): widen :applies_to of
			# the grown op so the codegen guard admits both. NB: read-
			# modify-write -- Ring copies lists on plain assignment.
			if HasKey($aSemanticOperations[_nAt_], :grown)
				_aTo_ = $aSemanticOperations[_nAt_][:applies_to]
				if ring_find(_aTo_, _aRec_[5]) = 0
					_aTo_ + _aRec_[5]
					$aSemanticOperations[_nAt_][:applies_to] = _aTo_
				ok
			ok
			loop
		ok

		_cOwner_ = _aRec_[4]
		if _cOwner_ = ""
			_cOwner_ = _aRec_[5]
		ok
		_aMap_ = _StzSemArityMapFor(_aArity_, _cOwner_)
		_nAr_ = _StzSemArityLookup(_aMap_, lower(_cName_))
		if _nAr_ < 0 or _nAr_ > 2
			loop
		ok

		_cSig_ = "@var." + _cName_ + "("
		for _k_ = 1 to _nAr_
			_cSig_ += "@param" + _k_
			if _k_ < _nAr_
				_cSig_ += ", "
			ok
		next
		_cSig_ += ")"

		_aOp_ = []
		_aOp_ + [ "semantic_id", _cId_ ]
		_aOp_ + [ "stz_method", _cName_ ]
		_aOp_ + [ "stz_signature", _cSig_ ]
		_aOp_ + [ "applies_to", [ _aRec_[5] ] ]
		if _nAr_ > 0
			_aOp_ + [ "requires_params", _nAr_ ]
		ok
		_aOp_ + [ "kind", _cKind_ ]
		_aOp_ + [ "grown", 1 ]
		$aSemanticOperations + _aOp_
		$aStzSemOpIds + _cId_
	next

	_StzSemBuildExactMap()

	func @StzGrowSemanticOperations()
		StzGrowSemanticOperations()

# Exact-name map over ALL operations (hand-authored + grown): the resolver
# prefers a deterministic exact hit over IDF scoring, so base verbs can
# never be lost to score ties as the lexicon grows.

func _StzSemBuildExactMap()
	$aStzSemExactNames = []
	_nOps_ = len($aSemanticOperations)
	for _i_ = 1 to _nOps_
		_aOp_ = $aSemanticOperations[_i_]
		if HasKey(_aOp_, :stz_method)
			$aStzSemExactNames + [ lower(_aOp_[:stz_method]), _aOp_[:semantic_id] ]
		ok
	next

# One source pass per owner class: [ [ lowered def name, arity ], ... ].

func _StzSemArityMapFor(paMemo, pcOwner)
	_cKey_ = lower(pcOwner)
	_n_ = len(paMemo)
	for _i_ = 1 to _n_
		if paMemo[_i_][1] = _cKey_
			return paMemo[_i_][2]
		ok
	next
	_aMap_ = []
	_cSrc_ = _StzResolveSource(pcOwner)
	if _cSrc_ != "" and fexists(_cSrc_)
		_aLines_ = str2list(read(_cSrc_))
		_nL_ = len(_aLines_)
		for _i_ = 1 to _nL_
			_cT_ = trim(_aLines_[_i_])
			if len(_cT_) >= 4 and lower(left(_cT_, 4)) = "def "
				_cDefName_ = lower(_StzDefName(_cT_))
				_nAr_ = 0
				_p1_ = substr(_cT_, "(")
				if _p1_ > 0
					_p2_ = _StzLastPos(_cT_, ")")
					if _p2_ > _p1_ + 1
						_cP_ = substr(_cT_, _p1_ + 1, _p2_ - _p1_ - 1)
						if trim(_cP_) != ""
							_nAr_ = len(_StzSplitOnChar(_cP_, ","))
						ok
					ok
				ok
				_aMap_ + [ _cDefName_, _nAr_ ]
			ok
		next
	ok
	paMemo + [ _cKey_, _aMap_ ]
	return _aMap_

# The lowered method names of a live instance (Ring's methods() is the
# ground truth of callability).

func _StzSemMethodsOf(pcNewExpr)
	_aOut_ = []
	try
		eval("_oObj_ = " + pcNewExpr)
		_aM_ = methods(_oObj_)
		_nM_ = len(_aM_)
		for _i_ = 1 to _nM_
			_aOut_ + lower(_aM_[_i_])
		next
	catch
	done
	return _aOut_

func _StzSemArityLookup(paMap, pcName)
	_n_ = len(paMap)
	for _i_ = 1 to _n_
		if paMap[_i_][1] = pcName
			return paMap[_i_][2]
		ok
	next
	return -1

func StzSemanticLexicon()

	if $bStzSemLexiconBuilt
		return $aStzSemLexicon
	ok

	# grow $aSemanticOperations from the harvest FIRST, so every source
	# below (and the bags themselves) covers the grown operations too
	StzGrowSemanticOperations()

	_aBags_ = []

	# -- Source 0: each operation's own method name, camel-split ("MultiplyBy"
	# -> "multiply by"), so grown verbs are findable by their name words.

	_nOps_ = len($aSemanticOperations)
	for _i_ = 1 to _nOps_
		_aOp_ = $aSemanticOperations[_i_]
		_cId_ = _aOp_[:semantic_id]
		if left(_cId_, 7) = "METHOD_" and HasKey(_aOp_, :stz_method)
			_StzSemBagAdd(_aBags_, _cId_, lower(_StzSplitCamel(_aOp_[:stz_method])))
		ok
	next

	# -- Source 1: invert the English :semantic_mappings (authoritative seed).
	# Only action-like IDs take part: resolving an unknown word to an OBJECT_*
	# or VALUE_INDICATOR could corrupt program structure, so those are excluded.

	_nL_ = len($aLanguageDefinitions)
	for _i_ = 1 to _nL_
		_aLang_ = $aLanguageDefinitions[_i_]
		if _aLang_[:code] != "en"
			loop
		ok
		_aMaps_ = _aLang_[:semantic_mappings]
		_nM_ = len(_aMaps_)
		for _j_ = 1 to _nM_
			_cId_ = _aMaps_[_j_][:semantic]
			if _StzSemIdEligible(_cId_)
				_StzSemBagAdd(_aBags_, _cId_, _aMaps_[_j_][:natural])
			ok
		next
	next

	# -- Source 2: the _ActionsXT form glossary (stzNaturalCode.ring). Each
	# entry lists the FORM FAMILY of one canonical action (active, passive,
	# interrogative, progressive...) -- fold every form into the action's bag.

	_nA_ = len(_ActionsXT)
	for _i_ = 1 to _nA_
		_cId_ = "METHOD_" + upper(_ActionsXT[_i_][1])
		if NOT _StzSemOpKnown(_cId_)
			loop
		ok
		_aForms_ = _ActionsXT[_i_][2]
		_nF_ = len(_aForms_)
		for _j_ = 1 to _nF_
			_StzSemBagAdd(_aBags_, _cId_, lower(_aForms_[_j_]))
		next
	next

	# -- Source 3: the #@ aka retrieval tags, harvested from the class sources
	# by the reflect layer. Each record's aka is folded into the operation of
	# its form-family BASE (Uppercased / IsUppercased -> METHOD_UPPERCASE),
	# exactly the _ActionsXT lesson: all forms of one action share the ID.

	_aRecs_ = _StzSemHarvest()
	_nR_ = len(_aRecs_)

	for _j_ = 1 to _nR_
		_aRec_ = _aRecs_[_j_]
		if len(_aRec_) < 3 or _aRec_[3] = ""
			loop
		ok
		_aCands_ = _StzSemBaseCands(_aRec_[1])
		_nC_ = len(_aCands_)
		for _k_ = 1 to _nC_
			_cId_ = "METHOD_" + upper(_aCands_[_k_])
			if _StzSemOpKnown(_cId_)
				_StzSemBagAdd(_aBags_, _cId_, _aRec_[3])
				exit
			ok
		next
	next

	$aStzSemLexicon = _aBags_
	$bStzSemLexiconBuilt = TRUE
	_StzSemSaveCache($nStzSemCacheSig)
	return $aStzSemLexicon

	func @StzSemanticLexicon()
		return StzSemanticLexicon()

#--- CACHE (grown operations + final lexicon bags) ------------------------
# Lives in natural/cache/ -- a natural-module artifact travels WITH the
# module (the natural stack is slated to move into the engine later).

func _StzSemCachePath()
	_cB_ = _StzBaseDir()
	if _cB_ = ""
		return ""
	ok
	_cDir_ = _cB_ + "/natural/cache"
	try
		StzMakeDir(_cDir_)
	catch
	done
	return _cDir_ + "/semantic_ops.stzcache"

# Signature = combined byte size of the three harvested sources; any edit
# to them changes the size and forces a rebuild.

func _StzSemCacheSig()
	_n_ = 0
	_aCls_ = [ "stzString", "stzList", "stzNumber" ]
	for _i_ = 1 to 3
		_cSrc_ = _StzResolveSource(_aCls_[_i_])
		if _cSrc_ != "" and fexists(_cSrc_)
			_n_ += len(read(_cSrc_))
		ok
	next
	return _n_

func _StzSemLoadCache(nSig)
	_cPath_ = _StzSemCachePath()
	if _cPath_ = "" or NOT fexists(_cPath_)
		return FALSE
	ok
	_c_ = read(_cPath_)
	if _c_ = ""
		return FALSE
	ok
	_aLines_ = str2list(_c_)
	if len(_aLines_) < 1
		return FALSE
	ok
	_cSig_ = trim(_aLines_[1])
	if len(_cSig_) < 6 or left(_cSig_, 5) != "SIG2 "
		return FALSE
	ok
	if number(substr(_cSig_, 6, len(_cSig_) - 5)) != nSig
		return FALSE
	ok
	_aBags_ = []
	_nl_ = len(_aLines_)
	for _i_ = 2 to _nl_
		_ln_ = _aLines_[_i_]
		if trim(_ln_) = ""
			loop
		ok
		_aP_ = _StzSplitOnChar(_ln_, char(1))
		if _aP_[1] = "OP" and len(_aP_) >= 7
			_aOp_ = []
			_aOp_ + [ "semantic_id", _aP_[2] ]
			_aOp_ + [ "stz_method", _aP_[3] ]
			_aOp_ + [ "stz_signature", _aP_[4] ]
			_aOp_ + [ "applies_to", _StzSplitOnChar(_aP_[5], ";") ]
			_nAr_ = number(_aP_[6])
			if _nAr_ > 0
				_aOp_ + [ "requires_params", _nAr_ ]
			ok
			_aOp_ + [ "kind", _aP_[7] ]
			_aOp_ + [ "grown", 1 ]
			$aSemanticOperations + _aOp_
			$aStzSemOpIds + _aP_[2]
		but _aP_[1] = "LX" and len(_aP_) >= 3
			_aBags_ + [ _aP_[2], _aP_[3] ]
		ok
	next
	if len(_aBags_) = 0
		return FALSE
	ok
	$aStzSemLexicon = _aBags_
	$bStzSemLexiconBuilt = TRUE
	return TRUE

func _StzSemSaveCache(nSig)
	_cPath_ = _StzSemCachePath()
	if _cPath_ = ""
		return
	ok
	_c_ = "SIG2 " + nSig + nl
	_nOps_ = len($aSemanticOperations)
	for _i_ = 1 to _nOps_
		_aOp_ = $aSemanticOperations[_i_]
		if NOT HasKey(_aOp_, :grown)
			loop
		ok
		_nAr_ = 0
		if HasKey(_aOp_, :requires_params)
			_nAr_ = _aOp_[:requires_params]
		ok
		_cKind_ = "action"
		if HasKey(_aOp_, :kind)
			_cKind_ = _aOp_[:kind]
		ok
		_aTo_ = _aOp_[:applies_to]
		_cTo_ = ""
		_nTo_ = len(_aTo_)
		for _k_ = 1 to _nTo_
			_cTo_ += _aTo_[_k_]
			if _k_ < _nTo_
				_cTo_ += ";"
			ok
		next
		_c_ += "OP" + char(1) + _aOp_[:semantic_id] + char(1) +
		       _aOp_[:stz_method] + char(1) + _aOp_[:stz_signature] + char(1) +
		       _cTo_ + char(1) + _nAr_ + char(1) + _cKind_ + nl
	next
	_nB_ = len($aStzSemLexicon)
	for _i_ = 1 to _nB_
		_cBag_ = StzReplace($aStzSemLexicon[_i_][2], nl, " ")
		_c_ += "LX" + char(1) + $aStzSemLexicon[_i_][1] + char(1) + _cBag_ + nl
	next
	try
		write(_cPath_, _c_)
	catch
	done

# Resolve one natural word (or short phrase) to a canonical semantic ID.
# Returns "" when nothing wins CLEARLY -- ambiguity must degrade to a
# literal, never to a guessed action.

func StzResolveSemantic(pcWord)

	if NOT isString(pcWord)
		return ""
	ok

	_w_ = lower(trim(pcWord))

	if StzLen(_w_) < 3
		return ""
	ok

	# @define / recall@ markers stay dictionary-only
	if left(_w_, 1) = "@" or right(_w_, 1) = "@"
		return ""
	ok

	# memo (failures included, so repeated unknowns cost nothing)
	_nMemo_ = len($aStzSemResolveMemo)
	for _i_ = 1 to _nMemo_
		if $aStzSemResolveMemo[_i_][1] = _w_
			return $aStzSemResolveMemo[_i_][2]
		ok
	next

	_aLex_ = StzSemanticLexicon()
	_nLex_ = len(_aLex_)
	if _nLex_ = 0
		return ""
	ok

	# -- Exact pass: the word IS an operation's method name. Deterministic
	# and immune to score ties, however large the grown lexicon gets.
	_nEx_ = len($aStzSemExactNames)
	for _i_ = 1 to _nEx_
		if $aStzSemExactNames[_i_][1] = _w_
			_cId_ = $aStzSemExactNames[_i_][2]
			$aStzSemResolveMemo + [ _w_, _cId_ ]
			return _cId_
		ok
	next

	_aTexts_ = []
	for _i_ = 1 to _nLex_
		_aTexts_ + _aLex_[_i_][2]
	next

	# -- Lexical pass: IDF scoring over the merged bags (deterministic).
	_aScores_ = _StzLexScoreAllIdf(_w_, _aTexts_)
	_nBest_ = 0
	_nSecond_ = 0
	_nBestIdx_ = 0
	_nS_ = len(_aScores_)
	for _i_ = 1 to _nS_
		_n_ = _aScores_[_i_][2]
		if _n_ > _nBest_
			_nSecond_ = _nBest_
			_nBest_ = _n_
			_nBestIdx_ = _aScores_[_i_][1]
		but _n_ > _nSecond_
			_nSecond_ = _n_
		ok
	next

	_cResolved_ = ""
	if _nBest_ > 0 and _nBest_ > _nSecond_   # strict unique winner only
		_cResolved_ = _aLex_[_nBestIdx_][1]
	ok

	# -- Neural rescue: only when lexical found nothing and a model is loaded.
	# Catches paraphrases sharing no surface token ("curved" -> rounded).
	if _cResolved_ = "" and StzHasNeuralModel()
		_nBest_ = 0
		_nSecond_ = 0
		_nBestIdx_ = 0
		for _i_ = 1 to _nLex_
			_n_ = StzSemanticSimilarity(_w_, _aLex_[_i_][2])
			if _n_ > _nBest_
				_nSecond_ = _nBest_
				_nBest_ = _n_
				_nBestIdx_ = _i_
			but _n_ > _nSecond_
				_nSecond_ = _n_
			ok
		next
		if _nBest_ >= 0.55 and (_nBest_ - _nSecond_) >= 0.05
			_cResolved_ = _aLex_[_nBestIdx_][1]
		ok
	ok

	$aStzSemResolveMemo + [ _w_, _cResolved_ ]
	return _cResolved_

	func @StzResolveSemantic(pcWord)
		return StzResolveSemantic(pcWord)

#--- MULTILINGUAL PACKS ----------------------------------------------------
# A language pack is a DATA block keyed by the SAME semantic IDs as English:
# one semantic core, many linguistic skins (the stzNatural design promise).
# Registering a pack feeds three layers at once:
#   1. $aLanguageDefinitions (ToSemantic: exact dictionary words)
#   2. a per-language EXACT-PHRASE map (multi-word naturalness --
#      "enlève les doublons" / "أزل التكرارات" -> METHOD_REMOVEDUPLICATES)
#   3. per-language word BAGS (single-word fallback -- "doublons" alone)
# Because the map is ID-keyed, packs cover GROWN operations for free.
# ($aStzSemLangLex is declared with the top-of-file globals.)

# Register (or replace) a natural language at devtime OR runtime.
# aDef = [ :code, :name, :script, :ignored_words, :semantic_mappings,
#          :phrases = [ [ :semantic = ID, :words = "phrase, phrase, ..." ], ... ] ]

func StzAddNaturalLanguage(aDef)

	if NOT ( isList(aDef) and HasKey(aDef, :code) and HasKey(aDef, :name) )
		StzRaise("Incorrect param! aDef must be a language definition with at least :code and :name.")
	ok
	_cCode_ = StzLower(aDef[:code])

	# upsert into the dictionary-side definitions
	_bDone_ = FALSE
	_nL_ = len($aLanguageDefinitions)
	for _i_ = 1 to _nL_
		if StzLower($aLanguageDefinitions[_i_][:code]) = _cCode_
			$aLanguageDefinitions[_i_] = aDef
			_bDone_ = TRUE
			exit
		ok
	next
	if NOT _bDone_
		$aLanguageDefinitions + aDef
	ok

	# build the resolver-side lexicon from :phrases
	_aIgn_ = []
	if HasKey(aDef, :ignored_words)
		_aI_ = aDef[:ignored_words]
		_nI_ = len(_aI_)
		for _i_ = 1 to _nI_
			_aIgn_ + StzLower(_aI_[_i_])
		next
	ok

	# MORPHOLOGY (optional): languages where articles attach as prefixes
	# (Arabic al-, French l'/d') and pronouns attach as suffixes (Arabic
	# -ha/-hu). Tokens are CANONICALIZED (affixes stripped) on BOTH the
	# registration side and the query side, so the writer may say
	# "remove-its-duplicates" as ONE inflected word and still match.
	_aArt_ = []
	if HasKey(aDef, :prefix_articles)
		_aArt_ = aDef[:prefix_articles]
	ok
	_aSuf_ = []
	if HasKey(aDef, :suffix_pronouns)
		_aSuf_ = aDef[:suffix_pronouns]
	ok
	# attached conjunctions (Arabic wa-/fa- glue to the NEXT word:
	# "wa-iqlib-ha") -- stripped before the article
	_aConj_ = []
	if HasKey(aDef, :prefix_conjunctions)
		_aConj_ = aDef[:prefix_conjunctions]
	ok
	# marks deleted ANYWHERE in a token before matching: Arabic tashkeel
	# (tanween, fatha, shadda, ...) and the tatweel stretch character --
	# writers use them freely ("qa'imatan" with tanween, "bi--" stretched)
	_aMarks_ = []
	if HasKey(aDef, :strip_marks)
		_aMarks_ = aDef[:strip_marks]
	ok

	_aBags_ = []
	_aExact_ = []
	if HasKey(aDef, :phrases)
		_aPh_ = aDef[:phrases]
		_nP_ = len(_aPh_)
		for _i_ = 1 to _nP_
			_cId_ = _aPh_[_i_][:semantic]
			_aVars_ = _StzSplitOnChar(_aPh_[_i_][:words], ",")
			_nV_ = len(_aVars_)
			for _j_ = 1 to _nV_
				_aTok_ = _StzSemLangTokens(_aVars_[_j_], _aIgn_, _aArt_, _aSuf_, _aConj_, _aMarks_)
				if len(_aTok_) = 0
					loop
				ok
				_cJoin_ = ""
				_cBag_ = ""
				_nT_ = len(_aTok_)
				for _k_ = 1 to _nT_
					_cJoin_ += _aTok_[_k_]
					_cBag_ += _aTok_[_k_]
					if _k_ < _nT_
						_cBag_ += " "
					ok
				next
				_StzSemLangExactAdd(_aExact_, _cJoin_, _cId_)
				_StzSemBagAdd(_aBags_, _cId_, _cBag_)
			next
		next
	ok

	# upsert the language lexicon (morphology kept for query-side canon)
	_aEntry_ = [ _cCode_, _aBags_, _aExact_, _aArt_, _aSuf_, _aConj_, _aMarks_ ]
	_bDone_ = FALSE
	_nX_ = len($aStzSemLangLex)
	for _i_ = 1 to _nX_
		if $aStzSemLangLex[_i_][1] = _cCode_
			$aStzSemLangLex[_i_] = _aEntry_
			_bDone_ = TRUE
			exit
		ok
	next
	if NOT _bDone_
		$aStzSemLangLex + _aEntry_
	ok
	return TRUE

	func @StzAddNaturalLanguage(aDef)
		return StzAddNaturalLanguage(aDef)

func StzHasLanguagePack(pcLang)
	_c_ = StzLower(pcLang)
	_n_ = len($aStzSemLangLex)
	for _i_ = 1 to _n_
		if $aStzSemLangLex[_i_][1] = _c_
			return TRUE
		ok
	next
	return FALSE

	func @StzHasLanguagePack(pcLang)
		return StzHasLanguagePack(pcLang)

func StzNaturalLanguages()
	_aOut_ = []
	_n_ = len($aLanguageDefinitions)
	for _i_ = 1 to _n_
		_aOut_ + $aLanguageDefinitions[_i_][:code]
	next
	return _aOut_

	func @StzNaturalLanguages()
		return StzNaturalLanguages()

# Language-aware resolution: English uses the full unified lexicon
# (dictionary + _ActionsXT + aka + grown names); pack languages use their
# registered exact map + word-membership over the pack bags. Deterministic
# and script-agnostic (plain token equality -- no stemming assumptions).

func StzResolveSemanticInLang(pcLang, pcWord)

	_cLang_ = StzLower(pcLang)
	if _cLang_ = "en"
		return StzResolveSemantic(pcWord)
	ok
	_aLex_ = _StzSemLangEntry(_cLang_)
	if len(_aLex_) = 0 or NOT isString(pcWord)
		return ""
	ok
	_w_ = StzLower(trim(pcWord))
	if StzLen(_w_) < 2
		return ""
	ok

	# canonical form: marks deleted, attached conjunction/article/pronoun
	# suffix stripped, so the inflected Arabic "wa-reverse-it" or
	# "its-duplicates" (with tanween) matches its base
	_w_ = _StzSemLangNorm(_w_, _aLex_[7])
	_w_ = _StzSemLangCanon(_w_, _aLex_[4], _aLex_[5], _aLex_[6])

	# the language's own DICTIONARY, consulted with the canonical form:
	# a pronoun-suffixed dictionary verb resolves without any pack phrase
	# (action-like ids only -- structural ids stay dictionary-exact)
	_cId_ = _StzSemLangMappingGet(_cLang_, _w_, _aLex_)
	if _cId_ != ""
		StzGrowSemanticOperations()
		return _cId_
	ok

	# exact single-word / joined-phrase hit
	_cId_ = _StzSemLangExactGet(_aLex_[3], _w_)
	if _cId_ != ""
		# a pack can target a GROWN id -- make sure the operations
		# table is grown before codegen looks the id up
		StzGrowSemanticOperations()
		return _cId_
	ok

	# membership over the pack bags (strict unique winner)
	_aBags_ = _aLex_[2]
	_nB_ = len(_aBags_)
	_cBest_ = ""
	_nHits_ = 0
	for _i_ = 1 to _nB_
		if ring_find(_StzSplitOnChar(_aBags_[_i_][2], " "), _w_) > 0
			_nHits_++
			_cBest_ = _aBags_[_i_][1]
		ok
	next
	if _nHits_ = 1
		StzGrowSemanticOperations()
		return _cBest_
	ok
	return ""

	func @StzResolveSemanticInLang(pcLang, pcWord)
		return StzResolveSemanticInLang(pcLang, pcWord)

# Exact joined-phrase lookup, language-aware (used by phrase resolution).

func StzSemanticExactIdInLang(pcLang, pcJoined)
	_cLang_ = StzLower(pcLang)
	if _cLang_ = "en"
		return StzSemanticExactId(pcJoined)
	ok
	_aLex_ = _StzSemLangEntry(_cLang_)
	if len(_aLex_) = 0
		return ""
	ok
	_cId_ = _StzSemLangExactGet(_aLex_[3], StzLower(trim(pcJoined)))
	if _cId_ != ""
		# grown ids need the grown operations table at codegen time
		StzGrowSemanticOperations()
	ok
	return _cId_

	func @StzSemanticExactIdInLang(pcLang, pcJoined)
		return StzSemanticExactIdInLang(pcLang, pcJoined)

#--- multilingual private helpers

func _StzSemLangEntry(pcCode)
	_n_ = len($aStzSemLangLex)
	for _i_ = 1 to _n_
		if $aStzSemLangLex[_i_][1] = pcCode
			return $aStzSemLangLex[_i_]
		ok
	next
	return []

# Content tokens of a pack phrase: lowered, marks stripped, this
# language's ignored words dropped, then CANONICALIZED (attached
# conjunction, article and pronoun suffix stripped). Script-agnostic.

func _StzSemLangTokens(pcPhrase, paIgnored, paArticles, paSuffixes, paConjunctions, paMarks)
	_aRaw_ = _StzSplitOnChar(trim(pcPhrase), " ")
	_aOut_ = []
	_n_ = len(_aRaw_)
	for _i_ = 1 to _n_
		_w_ = _StzSemLangNorm(StzLower(trim(_aRaw_[_i_])), paMarks)
		if _w_ = "" or ring_find(paIgnored, _w_) > 0
			loop
		ok
		_aOut_ + _StzSemLangCanon(_w_, paArticles, paSuffixes, paConjunctions)
	next
	return _aOut_

# Delete the language's marks (diacritics, tatweel) ANYWHERE in a token.

func _StzSemLangNorm(pcWord, paMarks)
	_w_ = pcWord
	_n_ = len(paMarks)
	for _i_ = 1 to _n_
		_w_ = StzReplace(_w_, paMarks[_i_], "")
	next
	return _w_

# The canonical (affix-free) form of a token: one attached ARTICLE prefix
# (Arabic al-, French l'/d') and one PRONOUN suffix (Arabic -ha/-hu/-hum)
# stripped, codepoint-safe, only while the remainder keeps >= 2 codepoints.
# Applied identically at registration AND query time, so both sides always
# meet on the same form.

# NB: deliberately BYTE-based (Ring's left/right/len): an affix is stripped
# only after an exact whole-affix byte match, which is UTF-8-safe -- while
# StzLeft/StzRight take BYTE counts although StzLen counts codepoints, so
# mixing them corrupts multibyte words (the trap this replaces). The >= 2
# remainder guard counts CODEPOINTS (StzLen) so it means two real letters.

func _StzSemLangCanon(pcWord, paArticles, paSuffixes, paConjunctions)
	# attached conjunction first (wa-al-takrarat -> al-takrarat), then
	# the article, then the pronoun suffix
	_w_ = _StzSemStripPrefix(pcWord, paConjunctions)
	_w_ = _StzSemStripPrefix(_w_, paArticles)
	_n_ = len(paSuffixes)
	for _i_ = 1 to _n_
		_cS_ = paSuffixes[_i_]
		_nS_ = len(_cS_)
		if len(_w_) > _nS_ and right(_w_, _nS_) = _cS_
			_cRest_ = left(_w_, len(_w_) - _nS_)
			if StzLen(_cRest_) >= 2
				_w_ = _cRest_
				exit
			ok
		ok
	next
	return _w_

func _StzSemStripPrefix(pcWord, paPrefixes)
	_w_ = pcWord
	_n_ = len(paPrefixes)
	for _i_ = 1 to _n_
		_cA_ = paPrefixes[_i_]
		_nA_ = len(_cA_)
		if len(_w_) > _nA_ and left(_w_, _nA_) = _cA_
			_cRest_ = right(_w_, len(_w_) - _nA_)
			if StzLen(_cRest_) >= 2
				return _cRest_
			ok
		ok
	next
	return _w_

# The engine's per-token seams (identity for English and for languages
# without morphology data). NORM deletes marks only (safe before ignored-
# word and dictionary checks); CANON = norm + affix stripping (for joins
# and fallback matching).

func StzSemLangNormToken(pcLang, pcWord)
	_cLang_ = StzLower(pcLang)
	if _cLang_ = "en"
		return pcWord
	ok
	_aLex_ = _StzSemLangEntry(_cLang_)
	if len(_aLex_) = 0
		return pcWord
	ok
	return _StzSemLangNorm(pcWord, _aLex_[7])

	func @StzSemLangNormToken(pcLang, pcWord)
		return StzSemLangNormToken(pcLang, pcWord)

func StzSemLangCanonToken(pcLang, pcWord)
	_cLang_ = StzLower(pcLang)
	if _cLang_ = "en"
		return pcWord
	ok
	_aLex_ = _StzSemLangEntry(_cLang_)
	if len(_aLex_) = 0
		return pcWord
	ok
	_w_ = _StzSemLangNorm(pcWord, _aLex_[7])
	return _StzSemLangCanon(_w_, _aLex_[4], _aLex_[5], _aLex_[6])

	func @StzSemLangCanonToken(pcLang, pcWord)
		return StzSemLangCanonToken(pcLang, pcWord)

# Consult a language's OWN semantic_mappings with a canonical form --
# action-like ids only (a canonicalized noun must never resolve to an
# OBJECT_* and corrupt program structure). The mapping word is
# canonicalized the SAME way, so both sides always meet.

func _StzSemLangMappingGet(pcCode, pcCanon, paLex)
	_n_ = len($aLanguageDefinitions)
	for _i_ = 1 to _n_
		_aDef_ = $aLanguageDefinitions[_i_]
		if StzLower(_aDef_[:code]) != pcCode
			loop
		ok
		if NOT HasKey(_aDef_, :semantic_mappings)
			return ""
		ok
		_aM_ = _aDef_[:semantic_mappings]
		_nM_ = len(_aM_)
		for _j_ = 1 to _nM_
			_cW_ = _StzSemLangNorm(StzLower(_aM_[_j_][:natural]), paLex[7])
			_cW_ = _StzSemLangCanon(_cW_, paLex[4], paLex[5], paLex[6])
			if _cW_ = pcCanon and _StzSemIdEligible(_aM_[_j_][:semantic])
				return _aM_[_j_][:semantic]
			ok
		next
		return ""
	next
	return ""

# Add an exact entry; a joined phrase claimed by TWO different ids is
# ambiguous -- kill it (safety over coverage, same strict-winner spirit).

func _StzSemLangExactAdd(paExact, pcJoined, pcId)
	_n_ = len(paExact)
	for _i_ = 1 to _n_
		if paExact[_i_][1] = pcJoined
			if paExact[_i_][2] != pcId
				paExact[_i_][2] = ""
			ok
			return
		ok
	next
	paExact + [ pcJoined, pcId ]

func _StzSemLangExactGet(paExact, pcJoined)
	_n_ = len(paExact)
	for _i_ = 1 to _n_
		if paExact[_i_][1] = pcJoined
			return paExact[_i_][2]
		ok
	next
	return ""

# Deterministic exact-name lookup: is this (joined) word EXACTLY an
# operation's method name? Powers multi-word phrase resolution ("remove
# duplicates" -> removeduplicates -> METHOD_REMOVEDUPLICATES). Triggers
# the lazy growth on first use.

func StzSemanticExactId(pcWord)
	if NOT isString(pcWord) or pcWord = ""
		return ""
	ok
	StzSemanticLexicon()
	_w_ = lower(trim(pcWord))
	_n_ = len($aStzSemExactNames)
	for _i_ = 1 to _n_
		if $aStzSemExactNames[_i_][1] = _w_
			return $aStzSemExactNames[_i_][2]
		ok
	next
	return ""

	func @StzSemanticExactId(pcWord)
		return StzSemanticExactId(pcWord)

# Introspection: all candidates with their lexical scores, best first.

func StzResolveSemanticXT(pcWord)

	if NOT isString(pcWord)
		return []
	ok

	_aLex_ = StzSemanticLexicon()
	_nLex_ = len(_aLex_)
	_aTexts_ = []
	for _i_ = 1 to _nLex_
		_aTexts_ + _aLex_[_i_][2]
	next

	_aScores_ = _StzLexScoreAllIdf(lower(trim(pcWord)), _aTexts_)
	_aOut_ = []
	_nS_ = len(_aScores_)
	for _i_ = 1 to _nS_
		if _aScores_[_i_][2] > 0
			_aOut_ + [ _aLex_[_aScores_[_i_][1]][1], _aScores_[_i_][2] ]
		ok
	next

	_aOut_ = reverse(SortListsOn(_aOut_, 2))   # best first
	return _aOut_

	func @StzResolveSemanticXT(pcWord)
		return StzResolveSemanticXT(pcWord)

#--- PRIVATE HELPERS

# Only action-like IDs may be fallback targets: structural IDs (OBJECT_*,
# CREATE_OBJECT, VALUE_INDICATOR, CONTEXT_IGNORED) would corrupt programs.

func _StzSemIdEligible(pcId)
	if left(pcId, 7) = "METHOD_" or left(pcId, 9) = "MODIFIER_" or
	   left(pcId, 7) = "OUTPUT_"
		return TRUE
	ok
	return FALSE

func _StzSemOpKnown(pcId)
	# fast path: the flat id list maintained by StzGrowSemanticOperations()
	if len($aStzSemOpIds) > 0
		return ring_find($aStzSemOpIds, pcId) > 0
	ok
	_n_ = len($aSemanticOperations)
	for _i_ = 1 to _n_
		if $aSemanticOperations[_i_][:semantic_id] = pcId
			return TRUE
		ok
	next
	return FALSE

func _StzSemBagAdd(paBags, pcId, pcWords)
	if pcWords = ""
		return
	ok
	_n_ = len(paBags)
	for _i_ = 1 to _n_
		if paBags[_i_][1] = pcId
			paBags[_i_][2] += " " + pcWords
			return
		ok
	next
	paBags + [ pcId, pcWords ]

# The candidate form-family BASE words of a method name, lowercased --
# the operation a record's aka should fold into. Uppercased -> uppercase;
# IsUppercased -> (strip the predicate is/are/has) -> uppercase; fluent
# UppercaseQ -> uppercase. Reuses the reflect form grammar.

func _StzSemBaseCands(pcName)
	_aF_ = _StzFormOf(pcName)
	if _aF_[1] = "predicate" or _aF_[1] = "negative"
		if _aF_[2] = ""
			return []
		ok
		_aOut_ = [ _aF_[2] ]
		_aDeeper_ = _StzSiblingBases(_aF_[2])
		_nD_ = len(_aDeeper_)
		for _i_ = 1 to _nD_
			if ring_find(_aOut_, _aDeeper_[_i_]) = 0
				_aOut_ + _aDeeper_[_i_]
			ok
		next
		return _aOut_
	ok
	return _StzSiblingBases(pcName)
